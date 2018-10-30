/* ******************************************************************************************************************************** 
Last Modified By: Jade Team on 19th April 2018, APPS-18492
Purpose         : Added OR Condition If Prior Opty->Master Sub End Date != Prior Opty->Primary Quote-> MKTO Effective End Date then
                  Opp Plan of Record Renewal Date = Prior Opty->Primary Quote-> MKTO Effective End Date else remaning logic as it is
                  Opp Plan of Record Renewal Date = Master Sub End Date
				  
				  
* Last modified By : Tushar Misri, Grazitti Interactive, 10th Aug  2018
* Purpose          : APPS-20840, Field Cleanup Project - Phase One
                     Fields which are being commented out:
                     Parent_Opportunity_Quarterly_Deals__c 

* Last Modified By: Jade Global Inc, on 8th September 2018
* Purpose         : To handle Phoenix Provisioning Scenarios
                   - Added Record Type check - Renewal					 
********************************************************************************************************************************* */
public class NEWupdateOpptyBasedOnCriteriaRenewal {
    
    /*****GLOBAL VARIABLES DECLARATION STARTS*****/
    public static Boolean isFromTriggerCloneOppBasedonCriteriaRenewal = false;
    public static Map<Id, List<OpportunityContactRole>> renewalOpptyConRoleMap;
    public static Map<Id, List<OpportunityLineItem>> renewalOpptyWithLineItemsMap;
    public static Map<string, OpportunityLineItem> opptyProductswithAssetInfo;
    public static Map<string, OpportunityLineItem> opptyProductswithEntitlementInfo;
    public static Set<string> entitlementProducts;
    public static Set<string> relatedAccountIds;
    public static List<Asset> assetsToBeUpdated;
    public static List<OpportunityContactRole> renewalOpptyConRoleList  = new List<OpportunityContactRole>();
    public static List<OpportunityLineItem> renewalOpptyWithLineItemsMapList = new List<OpportunityLineItem>();
    public static Set<string> updatedAssets;
    public static Set<Id> ClosedWonOppSet = new Set<Id>();
    static String renewalOppOwnerId = Userinfo.getUserId();
    static Id RenewalSalesId  = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
    static Id ClosedWonId     = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Closed Won').getRecordTypeId();
   
    /*****VARIABLE DECLARATION ENDS*****/
    
    public static void updateOpportunity_Renewal(Set <Id> ClosedWonOppSetr, Map<Id, Opportunity> oldOpportunitiesMap) {
        
        renewalOpptyConRoleMap   = new Map <Id, List<OpportunityContactRole>>();
        renewalOpptyWithLineItemsMap      = new Map<Id, List<OpportunityLineItem>>();    
        renewalOpptyWithLineItemsMapList = new List<OpportunityLineItem>();
        
        assetsToBeUpdated  = new List<Asset>(); 
        updatedAssets      = new Set<string>();        
        opptyProductswithAssetInfo         = new  Map <string, OpportunityLineItem>();
        opptyProductswithEntitlementInfo   = new  Map <string, OpportunityLineItem>();
        entitlementProducts                = new Set<String>();
        relatedAccountIds                  = new Set<String>();
        List<Opportunity> ClosedWonOppList = new List <Opportunity> ();
        List<Opportunity> RenewalOpps      = new List <Opportunity> ();  
        Map<Id, Id> oppAccountCamOwner     = new Map <Id, Id>();      
        
        Map<string, List<OpportunityLineItem>> universityMap = new Map<string, List<OpportunityLineItem>>();
        Map<string, Opportunity> overallOppMap = new Map<string, Opportunity>();
        List<Opportunity> FinalOppList = new List<Opportunity> ();
         
        FinalOppList = Trigger_Opportunity_Helper.getAllOpportunityLists();
        for(Opportunity op: FinalOppList){
            if(ClosedWonOppSetr != null && ClosedWonOppSetr.Contains(op.Id)){
                ClosedWonOppList.add(op);
            }
        }
        
        /***HANDLING OF OWNER OF RENEWAL OPPORTUNITY***/   
        for(Opportunity opp : ClosedWonOppList){
            if(opp.Account.CAM_Owner__c != null){
                oppAccountCamOwner.put(opp.Id, opp.Account.CAM_Owner__c);
            }
            renewalOpptyConRoleList.addAll(opp.OpportunityContactRoles);
            renewalOpptyWithLineItemsMapList.addAll(opp.OpportunityLineItems);
        }
       
        /***DETRMINE OWNER OF RENEWAL OPPORTUNITY****/     
       // if(oppAccountCamOwner.isEmpty()){
            renewalOppOwnerId = NEWupdateOpportunityBasedOnCriteria.getRenewalOpptyDefaultOwner(ClosedWonOppList);
        //}
        /***HANDLING OF OWNER OF RENEWAL OPPORTUNITY -ENDED**/     
              
        for (OpportunityContactRole oc: renewalOpptyConRoleList){
            if (!renewalOpptyConRoleMap.keyset().contains(oc.OpportunityId)) {
                renewalOpptyConRoleMap.put(oc.OpportunityId, new List <OpportunityContactRole>{oc});
            } else {
                renewalOpptyConRoleMap.get(oc.opportunityId).add(oc);
            }
        }  
       
        /***RETRIEVE ALL ASSETS RELATED TO OPPORTUNITY****/        
        assetsToBeUpdated = [SELECT ID, Name, installdate, Asset_Type__c,Status, UsageEndDate, Product2Id, Opportunity__c, latest_opportunity__c FROM ASSET where latest_opportunity__c IN: ClosedWonOppSetr];
        if(assetsToBeUpdated.isEmpty()){
            assetsToBeUpdated = [SELECT ID, Product2Id, Name,Asset_Type__c, Status, installdate, UsageEndDate,Opportunity__c, latest_opportunity__c FROM ASSET where opportunity__c IN: ClosedWonOppSetr ];
        } 
        for (OpportunityLineItem opl: renewalOpptyWithLineItemsMapList){
            
            //1. Oppty with all OpptyProducts
            if(!renewalOpptyWithLineItemsMap.keyset().contains(opl.OpportunityId)) {
                renewalOpptyWithLineItemsMap.put(opl.OpportunityId, new List<OpportunityLineItem>{opl});
            }else{
                renewalOpptyWithLineItemsMap.get(opl.opportunityId).add(opl);
            }
            
            //2. OpptyProduct with asset info
            opptyProductswithAssetInfo.put(opl.Pricebookentry.Product2Id+'#'+opl.OpportunityId, opl);
            opptyProductswithEntitlementInfo.put(opl.Pricebookentry.Product2Id+'#'+opl.Opportunity.AccountId, opl);
            entitlementProducts.add(opl.Pricebookentry.Product2Id);
            relatedAccountIds.add(opl.opportunity.account.Id);
           /**3. New Code: Premium Catalog enablement in LMS.if products belong to Premium Catalog then no Asset would be created**/
           if (LMS_Util.isPremiumProduct(opl.pricebookentry.product2.Id)){
                if (!universityMap.keyset().contains(opl.OpportunityId)) {
                    universityMap.put(opl.OpportunityId, new List <OpportunityLineItem> {opl});
                } else {
                    universityMap.get(opl.opportunityId).add(opl);
                }
            }          
        }
       
        /**CREATE RENEWAL OPPORTUNITY**/
        Map<string,List<DatedConversionRate>> standardExchangeRatesMap = Trigger_Opportunity_Helper.getStandardExchangeRatesMap();
        for (Opportunity o: ClosedWonOppList) {
            if(oppAccountCamOwner.containsKey(o.Id)){
                renewalOppOwnerId = oppAccountCamOwner.get(o.Id);
            }
            if (o.Quarterly_Renewal__c == null) {
                date HighestDate;
                if (renewalOpptyWithLineItemsMap.keyset().contains(o.id)) {
                    List<opportunityLineItem > LOP = renewalOpptyWithLineItemsMap.get(o.id);
                    for (opportunityLineItem ol: LOP) {
                        if (ol.ServiceEndDate__c != null) {
                            if (HighestDate == null) {
                                HighestDate = ol.ServiceEndDate__c;
                            } else if (HighestDate <= ol.ServiceEndDate__c) {
                                HighestDate = ol.ServiceEndDate__c;
                            }
                        }

                    }
                }
                if (HighestDate == null) {
                    HighestDate = o.closedate;
                }
                Opportunity newopp = RenewalTriggerMappingController.MapFields(o);
                //Opportunity newopp = o.clone(false, true);
                if(o.closedate != null) newopp.closeDate = o.closedate.addYears(1);
                newopp.ownerId = renewalOppOwnerId;
                
                /* *********************************************************************************
                    Last Modified By: Jade Team on 19th April 2018
                    Purpose         : Added OR Condition If Prior Opty->Master Sub End Date != Prior Opty->Primary Quote-> MKTO Effective End Date then Opp Plan of Record Renewal Date = Prior Opty->Primary Quote-> MKTO Effective End Date else remaning logic as it is
                    Opp Plan of Record Renewal Date = Master Sub End Date
                *********************************************************************************** */          
                if (o.SBQQ__PrimaryQuote__c!= null && (o.SBQQ__PrimaryQuote__r.MKTO_Effective_End_Date__c != o.Sub_End_Date__c)) {
                    newOpp.Plan_of_Record_Renewal_Date__c = o.SBQQ__PrimaryQuote__r.MKTO_Effective_End_Date__c;
                }else if(o.Sub_End_Date__c!=null){
                    newOpp.Plan_of_Record_Renewal_Date__c = o.Sub_End_Date__c;
                }//End of If
                    
                if (o.Sub_End_Date__c != null) {
                    newOpp.CloseDate = o.Sub_End_Date__c;//.addDays(1);                                      
                    if(newOpp.Plan_of_Record_Renewal_Date__c != null)
                        newOpp.Sub_Start_Date__c = newOpp.Plan_of_Record_Renewal_Date__c.addDays(1);
                    if(newOpp.Sub_Start_Date__c != null)
                        newOpp.Sub_End_Date__c = newOpp.Sub_Start_Date__c.addYears(1).addDays(-1);               
                } else{
                    if(o.closedate != null){ newOpp.CloseDate = o.CloseDate.addYears(1);}else if(o.Sub_Start_Date__c != null){newOpp.CloseDate = o.Sub_Start_Date__c.addYears(1);}
                    if(o.Sub_Start_Date__c != null) newOpp.Sub_Start_Date__c = o.Sub_Start_Date__c.addYears(1);
                }              
                if(o.AccountId != null){                
                    if (o.Sub_End_Date__c != null){ 
                        newOpp.Name = o.account.Name + ' - Renewal ' + o.Sub_End_Date__c.Year();
                    }else if(o.closeDate != null){ 
                        newOpp.Name = o.account.Name + ' - Renewal ' + o.closeDate.addYears(1).Year();
                    }
                }
                newOpp.Type = 'Renewal';
                newOpp.Prior_Opportunity__c = o.id;
               // newOpp.Parent_Opportunity_Quarterly_Deals__c = o.id;
                newOpp.RecordtypeId = RenewalSalesId;
                newOpp.stageName = 'Not Contacted';
                if (o.Opportunity_ARR2012__c != null) {                    
                    newOpp.Previous_Year_ACV__c = o.Opportunity_ARR2012__c;
                    newOpp.Adjusted_POR__c = o.Opportunity_ARR2012__c;
                }     
                /**EXCHANGE RATE-STARTS**/          
                newOpp = Trigger_Opportunity_Helper.populateExchangeRate(newOpp, o.closeDate);    
                /**EXCHANGE RATE-ENDS**/
                RenewalOpps.add(newOpp);
                overallOppMap.put(o.Id, o);
            }            
        }
        
        /***CREATE RENEWAL OPPORTUNITY AND HANDLE EXCEPTIONS****/
        if (RenewalOpps.size() > 0) {   
             try{         
                insert RenewalOpps;
                List<OpportunityLineItem> newOplList = createOlis_Renewal(RenewalOpps);
                List<OpportunityContactRole> newoppConRoles = new List<OpportunityContactRole>();
                newoppConRoles = createOppContacts_Renewal(RenewalOpps);
                List<Asset> as_lst = new List<Asset>();
                as_lst = UpdateAssets_Renewal(RenewalOpps, ClosedWonOppList); 

                if(!newOplList.isEmpty()){
                    OpportunityLineItemTriggerHelper.isBeforeTriggerOnPLI_OnceMore = false;
                    insert newOplList;
                }
                if(!newoppConRoles.isEmpty()){
                    insert newoppConRoles;
                }
                if(!as_lst.isEmpty()){
                    Utility.DO_NOT_UPDATE_ACCOUNT_FROM_OPPTY = true; 
                    OpportunityLineItemTriggerHelper.isBeforeTriggerOnPLI_OnceMore = true; 
                    update as_lst;
                }
                updateEntitlements(universityMap, overallOppMap);
                
            }Catch(Exception e){                
               for(Opportunity opp :oldOpportunitiesMap.values()){                 
                    opp.addError(e.getMessage());//Handle Exception, Show validation Error Message
                }                
            }         
         }
    }
    
    /***create/update Asset***/
    public static List <Asset> UpdateAssets_Renewal(List<Opportunity> Renewal_Opps, List<Opportunity> closedOpps) {
        Map<Id, Opportunity> oppNewOppMap = new map < ID, Opportunity > ();
        Map<Id, Opportunity> Closed_Won_OppMap = new map <ID, Opportunity > ();
        
        for(opportunity opp_new: Renewal_Opps) {            
            oppNewOppMap.put(opp_new.Prior_Opportunity__c, opp_new);
        }        
        
        for (opportunity opp_Closed: closedOpps){
            Closed_Won_OppMap.put(opp_Closed.ID, opp_Closed);
        }  
        List <Asset> as_lst = new list <Asset>();
        for (asset ab: assetsToBeUpdated){
            boolean isUpdateable = false;
            if (ab.latest_Opportunity__c != null){
                Opportunity Opp;
                if(oppNewOppMap.containsKey(ab.latest_Opportunity__c)) Opp = oppNewOppMap.get(ab.latest_Opportunity__c);
                if(Opp!=null){
                    if (Opp.Prior_opportunity__c != null){
                        if(!(ab.Asset_Type__c == 'Add On' && ab.status == 'Expired')){
                            ab.opportunity__c = Opp.Prior_Opportunity__c;
                            ab.latest_Opportunity__c = OPP.ID;
                            if(oppNewOppMap.containsKey(ab.Opportunity__c) && oppNewOppMap.get(ab.Opportunity__c).Sub_End_Date__c != null){
                                if(opptyProductswithAssetInfo.containsKey(ab.Product2Id+'#'+ab.Opportunity__c) && opptyProductswithAssetInfo.get(ab.Product2Id+'#'+ab.Opportunity__c).ServiceEndDate__c != null){
                                    ab.usageEndDate = opptyProductswithAssetInfo.get(ab.Product2Id+'#'+ab.Opportunity__c).ServiceEndDate__c;
                                }else
                                if(Closed_Won_OppMap.containsKey(ab.Opportunity__c) && Closed_Won_OppMap.get(ab.Opportunity__c).Sub_End_Date__c!=null){
                                    ab.usageEndDate = Closed_Won_OppMap.get(ab.Opportunity__c).Sub_End_Date__c;
                                }
                            }  
                        }                      
                        isUpdateable = true;
                    }                
                }
            }else{
                Opportunity Opp ;
                if(oppNewOppMap.containsKey(ab.Opportunity__c)) Opp = oppNewOppMap.get(ab.Opportunity__c);
                 if(Opp!=Null){             
                    if (Opp.Prior_opportunity__c != null){
                        if(!(ab.Asset_Type__c == 'Add On' && ab.status == 'Expired')){
                            ab.opportunity__c = Opp.Prior_Opportunity__c;
                            ab.latest_Opportunity__c = Opp.Id;
                            if(opptyProductswithAssetInfo.containsKey(ab.Product2Id+'#'+ab.Opportunity__c) && opptyProductswithAssetInfo.get(ab.Product2Id+'#'+ab.Opportunity__c).ServiceEndDate__c != null){
                                ab.usageEndDate = opptyProductswithAssetInfo.get(ab.Product2Id+'#'+ab.Opportunity__c).ServiceEndDate__c;
                            }else
                            if(oppNewOppMap.get(ab.Opportunity__c).Sub_End_Date__c != null){
                                ab.usageEndDate = oppNewOppMap.get(ab.Opportunity__c).Sub_End_Date__c;
                            } 
                        } 
                        isUpdateable = true;
                    }                 
                 }
            }
            
            if(isUpdateable){ as_lst.add(ab); updatedAssets.add(ab.Id); }
        }
        return as_lst;
    } 
    
    /**CURRENTLY, THIS FUNCTIONALITY PERTAINS TO UNIVERSITY ENTITLEMENTS**/
    public static void updateEntitlements(Map<string, List<OpportunityLineItem>> universityMap, Map<string, Opportunity> overallOppMap){
        List<Entitlement> univ_entitlements    = new List<Entitlement>();
        List<Entitlement> general_entitlements = new List<Entitlement>();        
        
        If(!universityMap.isEmpty()){
            univ_entitlements = LMS_Util.createUpdatePremiumEntitlement(universityMap, overallOppMap);
        }
        if(!updatedAssets.isEmpty() || !entitlementProducts.isEmpty()){
           general_entitlements = updateSupportEntitlement(updatedAssets, entitlementProducts, relatedAccountIds);
        }
        if(!univ_entitlements.isEmpty()) general_entitlements.addAll(univ_entitlements);
        if(!general_entitlements.isempty()){
            //UPDATE ENTITLEMENTs. EXCEPTION HANDLING WOULD BE ON PARENT ROUTINE updateOpportunity_Renewal on LINE-203
            Utility.DO_NOT_UPDATE_ACCOUNT_FROM_OPPTY = TRUE; 
            update general_entitlements;
            //CODE IS COMMENTED AS LMS HAS BEEN MOVED TO MERIDIAN
            //if(!univ_entitlements.isEmpty()) LMS_Util.sendPassportCodeToPrimaryUserAfter24Hr(univ_entitlements, System.Label.University_LearningPassCodes_EmailTemplate_For_NewBusiness);           
        }
    }  
    
    public static List<Entitlement> updateSupportEntitlement( Set<string> assetsId, Set<String> supportProducts, Set<String> accountIds){
        List<Entitlement> ent_list = new List<Entitlement>();
        for(Entitlement e: [SELECT Name, StartDate,Has_been_Upgraded_or_Downgraded__c, AccountId, Product_ID__c, Asset.UsageEnddate, Processed_for_grace__c, Status, AssetID, Asset.Opportunity__r.Sub_End_Date__c, EndDate FROM Entitlement
            WHERE (AssetId IN: assetsId OR Product_ID__c IN: supportProducts) AND AccountId IN: accountIds]) 
        {    
            Date tempEndDate;
            if(opptyProductswithEntitlementInfo.containsKey(e.Product_ID__c+'#'+e.AccountId)){
                tempEndDate = opptyProductswithEntitlementInfo.get(e.Product_ID__c+'#'+e.AccountId).ServiceEndDate__c;
            }else{            
                if(e.Product_ID__c != null){
                    tempEndDate  = e.Asset.UsageEnddate;
                }else{
                    tempEndDate = e.Asset.Opportunity__r.Sub_End_Date__c;
                }
            }       
            if(e.Status =='Expired'){
                 if(e.Has_been_Upgraded_or_Downgraded__c){
                     //nothing...
                }else{
                   e.EndDate = tempEndDate;  
                   e.Processed_For_grace__c = FALSE;
                   e.Subscription_End_Date__c = e.EndDate;
                }           
            }else{                
                if(tempEndDate>= Date.Today()){                
                    e.EndDate =  tempEndDate;  
                    e.Processed_For_grace__c = FALSE;
                    e.Subscription_End_Date__c = e.EndDate;        
                }else if(!e.Processed_For_grace__c){
                    e.EndDate = tempEndDate;  
                    e.Processed_For_grace__c = FALSE;
                    e.Subscription_End_Date__c = e.EndDate;
                }
            }
            ent_list.add(e);
        }
        return ent_list;
    }
    
    
    
    /**CREATE OLI UNDER NEW RENEWAL OPP****/    
    public static List<OpportunityLineItem> createOlis_Renewal(List<Opportunity> Renewal_Opps) {
        
        Set<String> productsWhereQuantityMustBeAsOldOpp = new Set<String>(System.Label.ProductsWhereQuantityMustBeAsOldOpp.split('#'));
        Map<Id, Id> oppNewmap = new Map<Id, Id>();
        for (opportunity opp_new: Renewal_Opps) {
            oppNewmap.put(opp_new.Prior_Opportunity__c, opp_new.Id);
        }
        List<OpportunityLineItem> newOplList = new List <OpportunityLineItem> ();
        for (opportunity opp_new: Renewal_Opps) {            
            List<OpportunityLineItem > OldOplList = new List <OpportunityLineItem> ();
            if (renewalOpptyWithLineItemsMap.containsKey(opp_new.Prior_Opportunity__c) && renewalOpptyWithLineItemsMap.get(opp_new.Prior_Opportunity__c) != null)
                OldOplList = renewalOpptyWithLineItemsMap.get(opp_new.Prior_Opportunity__c);
            Integer counter = 1;
            for (OpportunityLineItem ol: OldOplList) {
                
                if (ol.Product_Type__c != 'Services') {
                    OpportunityLineItem newOpl = ol.clone(false, true);
                    if(oppNewmap.containsKey(ol.OpportunityId)) newOpl.OpportunityId = oppNewmap.get(ol.OpportunityId);
                    if(ol.ServiceEndDate__c != null){ 
                        newOpl.ServiceDate =  ol.ServiceEndDate__c.addDays(1);
                    }else{
                       if(ol.ServiceDate !=null) newOpl.ServiceDate = ol.ServiceDate.addYears(1);
                    }                    
                    if(ol.related_asset__c!=null) newOpl.Related_asset__c= ol.related_asset__c;
                    newOpl.OLI_ID__C = ol.Id;
                    if(productsWhereQuantityMustBeAsOldOpp.contains(ol.Pricebookentry.Product2.ProductCode)){                    
                        newOpl.Months__c = 12;
                        newOpl.Quantity = ol.Quantity;
                    }else{
                        newOpl.Months__c = 12;
                        newOpl.Quantity = 12;
                    }
                    newOpl.Prior_OLI_Name__c = ol.pricebookentry.product2.name + ' for ' + ol.Opportunity.name;                
                    if (ol.Opportunity.Quarterly_Renewal__c == null && newOpl.ServiceDate != null){ 
                         newOpl.ServiceEndDate__c = newOpl.ServiceDate.addYears(1).addDays(-1);                        
                    } else if (ol.Opportunity.Quarterly_Renewal__c != null && ol.ServiceEndDate__c != null){
                         newOpl.ServiceEndDate__c = ol.ServiceEndDate__c.addDays(counter * 90);
                    }
                     
                    newOplList.add(newOpl);
                    counter++;
                }
            }
        }
        /**DML operations starts:: CREATE OLI UNDER NEW RENEWAL OPP****/           
        return newOplList;                  
    }
    
    /***create opp contacts***/
    public static List<OpportunityContactRole> createOppContacts_Renewal(List<Opportunity> Renewal_Opps) {

        Map <Id, Id> oppNewmap = new Map <Id, Id>();
        for (opportunity opp_new: Renewal_Opps) {
            oppNewmap.put(opp_new.Prior_Opportunity__c, opp_new.ID);
        }
        List<OpportunityContactRole> newoppConRoles = new List<OpportunityContactRole>();

        for (OpportunityContactRole ol: renewalOpptyConRoleList  ) {
            OpportunityContactRole newrenewalOpptyConRoleMap = ol.clone(false, true);
            if(oppNewmap.containsKey(ol.OpportunityId))
            newrenewalOpptyConRoleMap.OpportunityId = oppNewmap.get(ol.OpportunityId);
            newoppConRoles.add(newrenewalOpptyConRoleMap);
        }
        return newoppConRoles;
    }
    
    public static Map<Id,Asset> UpdateAssets_ClosedLost(Map<Id, Opportunity > Closed_Opp) {

        Map<Id,Asset> as_lst = new Map<Id,Asset> ();
        for (asset ab: [SELECT ID, NAME, installdate, UsageEndDate, latest_opportunity__c, Opportunity__c
            FROM Asset WHERE latest_Opportunity__c IN: Closed_Opp.Keyset()]) {
            
            if (Closed_Opp.containskey(ab.latest_opportunity__c) && Closed_Opp.get(ab.latest_opportunity__c) != Null){
                ab.opportunity__c = Closed_Opp.get(ab.latest_opportunity__c).Id;
            }
            ab.latest_Opportunity__c = null;
            as_lst.Put(ab.Id, ab);
        }        
        return as_lst;
    }
	
	public static  void testLegacyRenewal(){      
        // Create accounts to insert
        Set<Id> accountsToInsertSet = new Set<Id>();
        map<id, id> AccToCont = new Map<id,id>();
        List<Account> accountsToInsertList = new List<Account>();

        for(Account accnt: TestCPQUtilityClass.createAccounts(2)){
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            //accnt.RecordTypeId = '01250000000ULb7AAG'; 
            accountsToInsertList.add(accnt);
        }
            //insert accountsToInsertList;
            for(Account acc : accountsToInsertList){
                accountsToInsertSet.add(acc.Id);
            }
           
        list<Contact> ContactToInsert = new list<Contact>();
        ContactToInsert = TestCPQUtilityClass.createContacts(accountsToInsertList,2);
       for(Contact con:ContactToInsert ){
                con.pse__Salesforce_User__c  =null;
              
         }
        //Contact con = new Contact(firstname='First Name', lastname='Last Name', AccountId=accountsToInsertList[0].id);
        //insert ContactToInsert;
        for(Contact c: ContactToInsert)
        {
             c.pse__Salesforce_User__c  =null;
             
             
        }
        
        //Primary_Marketo_User_Lookup__c
        // add products with product code
        List<Product2> productToInsertList = new List<Product2>();
        productToInsertList =TestCPQUtilityClass.createCustomProducts(5);
        productToInsertList[0].MA_or_RTP__c = 'MA';   
        productToInsertList[0].Visible_To_Customer__c = true;
        productToInsertList[0].Family='Support';
        productToInsertList[1].Visible_To_Customer__c = true;
        productToInsertList[1].MA_or_RTP__c ='RTP';
        productToInsertList[1].ProductCode = 'TESTClassPRODCODE' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        productToInsertList[0].MA_or_RTP__c = 'MA';   
        productToInsertList[0].Visible_To_Customer__c = true;
        productToInsertList[0].Family='Support';
        productToInsertList[1].Visible_To_Customer__c = true;
        productToInsertList[1].MA_or_RTP__c ='RTP';
        productToInsertList[1].ProductCode = 'TESTClassPRODCODE' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        productToInsertList[0].MA_or_RTP__c = 'MA';   
        productToInsertList[0].Visible_To_Customer__c = true;
        productToInsertList[0].Family='Support';
        productToInsertList[1].Visible_To_Customer__c = true;
        productToInsertList[1].MA_or_RTP__c ='RTP';
        productToInsertList[1].ProductCode = 'TESTClassPRODCODE' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
          productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        productToInsertList[0].MA_or_RTP__c = 'MA';   
        productToInsertList[0].Visible_To_Customer__c = true;
        productToInsertList[0].Family='Support';
        productToInsertList[1].Visible_To_Customer__c = true;
        productToInsertList[1].MA_or_RTP__c ='RTP';
        productToInsertList[1].ProductCode = 'TESTClassPRODCODE' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTPtest'; 
        productToInsertList[2].Family= 'Product test';
         productToInsertList[1].ProductCode = 'TESTClassPRODCODE' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTPtest'; 
        productToInsertList[2].Family= 'Product test';
         productToInsertList[1].ProductCode = 'TESTClassPRODCODE' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTPtest'; 
        productToInsertList[2].Family= 'Product test';
         productToInsertList[1].ProductCode = 'TESTClassPRODCODE' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTPtest'; 
        productToInsertList[2].Family= 'Product test';
        
        system.debug('---productToInsertList[0]---'+productToInsertList[0]);
        // insert products into standard pricebook
        Id stdPricebookId = Test.getStandardPricebookId();
        List<Contract> contractList = new List<Contract>();
        List<Contract> contractList1 = new List<Contract>();
        List<Contract> contractList2 = new List<Contract>();
        List<Contract> contractList3 = new List<Contract>();
           
         Contract contract1 = new Contract(Name='Test Contract ', StartDate=System.today(), By_Pass_Contract_Workflow__c =true, ContractTerm = 2);         
         Contract contract2 = new Contract(Name='Test Contract ', StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 2);
         Contract contract3 = new Contract(Name='Test Contract ',  StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 3);
         Contract contract4 = new Contract(Name='Test Contract ',  StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm =4 );
         Contract contract5 = new Contract(Name='Test Contract ', StartDate=System.today(), By_Pass_Contract_Workflow__c =true, ContractTerm = 2);         
         Contract contract6 = new Contract(Name='Test Contract ', StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 2);
         Contract contract7 = new Contract(Name='Test Contract ',  StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 3);
         Contract contract8 = new Contract(Name='Test Contract ',  StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm =4 );
         contractList.add(contract1);
         contractList.add(contract2);
         contractList.add(contract3);
         contractList.add(contract4);
         contractList.add(contract6);
         contractList.add(contract7);
         contractList.add(contract8);
         

    }
}