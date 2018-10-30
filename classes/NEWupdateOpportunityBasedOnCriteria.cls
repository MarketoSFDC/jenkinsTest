/* *********************************************************************************
Last Modified By: Jade Team on 19th April 2018, JIRA: APPS-18492 
Purpose         : Added OR Condition If Prior Opty->Master Sub End Date != Prior Opty->Primary Quote-> MKTO Effective End Date then
                  Opp Plan of Record Renewal Date = Prior Opty->Primary Quote-> MKTO Effective End Date else remaning logic as it is
                  Opp Plan of Record Renewal Date = Master Sub End Date

Last Modified By: Jade Global Inc On 19th May 2018
Updated for: Added as part of Winaback automation, added code to avoid overriding of Renewal Opportunity Owner.

* Last modified By : Tushar Misri, Grazitti Interactive, 10th Aug 2018
* Purpose          : APPS-20840, Field Cleanup Project - Phase One
                     Fields which are being commented out:
                     Parent_Opportunity_Quarterly_Deals__c 
					 
* Last Modified By: Jade Global Inc, on 8th September 2018
* Purpose         : To handle Phoenix Provisioning Scenarios
                   - Opportunity Record Type change Previous 'Renewal Sales' - new check 'Renewal'
************************************************************************************************/
public class NEWupdateOpportunityBasedOnCriteria {

    public static Boolean isFromTriggerCloneOppBasedonCriteria = false;
    public static Map <Id, List<OpportunityContactRole>> OpConRole;
    public static Map <Id, List<OpportunityLineItem>> opptyWithLineItemMap;
    public static Map <Id, List<Asset>> oppAssets;
    public static List<Asset> assetsToBeUpdated;
    public static Map<Id, Id> oppNew_map = new Map<Id, Id>();
	
    public static Id RenewalSalesId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
    public static Id ClosedWonId    = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Closed Won').getRecordTypeId();
    
    public static string renewalOpportunityDefaultOwnerId;
    
    /*
    public static string getRenewalOpptyDefaultOwner(){
        string defaultOwnerId = System.Label.Default_Renewal_Opportunity_Owner_ID;
        if(defaultOwnerId != null && defaultOwnerId.startsWith('005')){
            return defaultOwnerId;
        }
        return UserInfo.getUserId();
    }*/

    public static string getRenewalOpptyDefaultOwner(List<Opportunity> currentOppty){       
        string defaultOwnerId = '';     
        for(Opportunity opp : currentOppty){  
				/*Last Modified By: Jade Global Inc On 19th May 2018
				Updated for: Added as part of Winaback automation, added code to avoid overriding of Renewal Opportunity Owner. Added condition - opp.Is_Winback_Created__c==false*/
				
                if(opp.Type == 'New Business'){     
                    if(opp.Account.CAM_Owner__c != null ){      
                        defaultOwnerId = opp.Account.CAM_Owner__c;      
                    }else if(opp.Account.CAM_Group__c == 'EM' || opp.Account.CAM_Group__c == 'ENT'){        
                        defaultOwnerId = System.Label.Default_Opp_Owner1;       
                    }else{      
                        defaultOwnerId = System.Label.Default_Opp_Owner2;       
                    }       
                }else if(opp.Type == 'Renewal' && opp.Is_Winback_Created__c==false){    
                    if(opp.Account.CAM_Owner__c != null ){      
                        defaultOwnerId = opp.Account.CAM_Owner__c;      
                    }else{
                        defaultOwnerId = opp.OwnerId;       
                    }   
                }       
        }       
        if(defaultOwnerId != null || defaultOwnerId != ''){     
            return defaultOwnerId;      
        }else{      
            return UserInfo.getUserId();        
        }       
    }
    
    public static void processOpportunity_NewBusiness(Set <Id> ClosedWonOppSets, Map<Id, Opportunity> oldOpportunitiesMaps){
        List<Opportunity> renewalOpps = new List<Opportunity> ();
        List <OpportunityLineItem> newOplList = new List<OpportunityLineItem > ();
        List<opportunityContactRole> newoppConRoles = new List<OpportunityContactRole> ();
        List<Asset> as_lst    =  new List<Asset>();  
       // renewalOpportunityDefaultOwnerId = getRenewalOpptyDefaultOwner();
        
        try{            
            renewalOpps = updateOpportunity_NewBusiness(ClosedWonOppSets, oldOpportunitiesMaps);
            if(!renewalOpps.isEmpty()){
                insert renewalOpps;
                newOplList = createOlis(renewalOpps);
                newoppConRoles = createOppContacts(renewalOpps);
                as_lst = UpdateAssets(renewalOpps);
                if(newOplList != null && !newOplList.isEmpty()){
                    OpportunityLineItemTriggerHelper.isBeforeTriggerOnPLI_OnceMore = false;
                    insert newOplList;
                }
                if(newoppConRoles != null && !newoppConRoles.isEmpty()){
                    insert newoppConRoles;
                }
                if(as_lst != null && !as_lst.isEmpty()){
                    Utility.DO_NOT_UPDATE_ACCOUNT_FROM_OPPTY = true; 
                    OpportunityLineItemTriggerHelper.isBeforeTriggerOnPLI_OnceMore = true;
                    update as_lst;
                }
                
            }
        }catch(Exception e){                
            for(Opportunity opp : oldOpportunitiesMaps.values()){                 
                if(!opp.toutapp_migrated__c){                 
                    opp.addError(e.getMessage());
                }
            }              
        }
    }
    
       
    public static List<Opportunity> updateOpportunity_NewBusiness(Set <Id> ClosedWonOppSet, Map<Id, Opportunity> oldOpportunitiesMap) {
        
        Integer Q;
        OpConRole = new Map <Id, List<OpportunityContactRole>>();
        Map<Id, String> oppAccountname = new Map<Id, String>();
        oppAssets = new Map<Id, List<Asset>> ();
        assetsToBeUpdated = new List<Asset>();        
        Map<Id, List<Asset>> oppAssets_renew = new Map<Id, List <Asset>>();
        List<Asset> asset_lst = new List<Asset>();
        List<Opportunity> ClosedWonOppList = new List<Opportunity> ();
        List<Opportunity> FinalOppList = new List<Opportunity> ();
        List<Opportunity> renewalOpps = new List<Opportunity> ();
        String dealtypes = Label.Deal_types;
        Set<Id> Acc_Set = new Set <Id>();
        opptyWithLineItemMap = new Map <Id, List<OpportunityLineItem>>();
        
        //****VRAIABLE DECLARATION ENDS*****
        FinalOppList = Trigger_Opportunity_Helper.getAllOpportunityLists();
        for(Opportunity op: FinalOppList){
            if(ClosedWonOppSet != null && ClosedWonOppSet.Contains(op.Id)){
                ClosedWonOppList.add(op);
            }
        }
        
        renewalOpportunityDefaultOwnerId = getRenewalOpptyDefaultOwner(ClosedWonOppList);
        
        for(Opportunity opp : ClosedWonOppList){            
            if(!OpConRole.containsKey(opp.Id)){
                OpConRole.put(opp.id, opp.OpportunityContactRoles);
            }
            if(!opptyWithLineItemMap.containsKey(opp.Id)){
                opptyWithLineItemMap.put(opp.Id, opp.OpportunityLineItems);
            }            
        }
        /***RETRIVE ALL ASSETS******/
        for (Asset a: [SELECT ID, NAME, installdate, UsageEndDate, Opportunity__c FROM ASSET where Opportunity__c in : ClosedWonOppSet]){
            if (!oppAssets.keyset().contains(a.Opportunity__c)) {
                oppAssets.put(a.Opportunity__c, new List <Asset> {a});
            } else {
                oppAssets.get(a.Opportunity__c).add(a);
            }
            assetsToBeUpdated.add(a);
        }
        /***CREATE RENEWAL OPPORTUNITY****/
        Map<string,List<DatedConversionRate>> standardExchangeRatesMap = Trigger_Opportunity_Helper.getStandardExchangeRatesMap();
        for (Opportunity o: ClosedWonOppList) {

            Q = -1;
            if (o.Quarterly_Renewal__c != null) Q = integer.valueof(o.Quarterly_Renewal__c);
            Date EndDate;
            if (Q >= 1) {
                integer aa = 1;
                for (integer a = 0; a < 3; a++) {
                    Opportunity newopp = RenewalTriggerMappingController.MapFields(o);
                    //Opportunity newopp = o.clone(false, true);
                    newopp.Quarterly_Renewal__c = string.valueOf(a + 2);
                    newOpp.Name = o.Name + '-0' + (a + 2) + 'R';
                    newOpp.CloseDate = o.CloseDate.addmonths(aa * 3);
                    newopp.ownerId = renewalOpportunityDefaultOwnerId;
                    /* *********************************************************************************
                        Last Modified By: Jade Team on 19th April 2018
                        Purpose         : Added OR Condition If Prior Opty->Master Sub End Date != Prior Opty->Primary Quote-> MKTO Effective End Date then
                        Opp Plan of Record Renewal Date = Prior Opty->Primary Quote-> MKTO Effective End Date else remaning logic as it is
                        Opp Plan of Record Renewal Date = Master Sub End Date
                    *********************************************************************************** */ 
                    if(o.SBQQ__PrimaryQuote__c !=null && (o.SBQQ__PrimaryQuote__r.MKTO_Effective_End_Date__c!=o.Sub_End_Date__c)){
                        newOpp.Plan_of_Record_Renewal_Date__c = o.SBQQ__PrimaryQuote__r.MKTO_Effective_End_Date__c;
                    } else if(o.Sub_End_Date__c!=null){
                        newOpp.Plan_of_Record_Renewal_Date__c = o.Sub_End_Date__c;
                    }
                    if(o.Sub_End_Date__c != null){                        
                        newOpp.CloseDate = EndDate != null ? EndDate : o.Sub_End_Date__c;
                        /****Added one day to the beginning of the start date for the renewal ****/
                        newOpp.Sub_Start_Date__c = EndDate != null ? EndDate + 1 : o.Sub_End_Date__c + 1;
                        EndDate = EndDate == null ? o.Sub_End_Date__c.addMonths(3) : EndDate.addMonths(3);
                        newOpp.Sub_End_Date__c = EndDate;
                    }else{
                        newOpp.CloseDate = o.CloseDate.addmonths(aa * 3);
                    }
                    newOpp.Type = 'Renewal';
                    newOpp.Prior_Opportunity__c = o.id;
                    //newOpp.Parent_Opportunity_Quarterly_Deals__c = o.id;
                    newOpp.RecordtypeId = RenewalSalesId;                    
                    newOpp.stageName = 'Not Contacted';
                    if (o.Opportunity_ARR2012__c != null){ 
                        newOpp.Previous_Year_ACV__c = o.Opportunity_ARR2012__c / 4; 
                        newOpp.Adjusted_POR__c = o.Opportunity_ARR2012__c / 4; 
                    }                   
                    renewalOpps.add(newOpp);
                    aa++;
                }
            }            
            else if (o.Quarterly_Renewal__c == null) {
                date HighestDate;
                if(opptyWithLineItemMap.keyset().contains(o.id)){                
                    list <opportunityLineItem> opportunityProdutcs = opptyWithLineItemMap.get(o.id);
                    for (opportunityLineItem ol: opportunityProdutcs) {
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
                if(o.closedate != null) newopp.closeDate   = o.closedate.addYears(1);
                
                newopp.ownerId = renewalOpportunityDefaultOwnerId;
                
                /* *********************************************************************************
                    Last Modified By: Jade Team on 19th April 2018
                    Purpose         : Added OR Condition If Prior Opty->Master Sub End Date != Prior Opty->Primary Quote-> MKTO Effective End Date then Opp Plan of Record Renewal Date = Prior Opty->Primary Quote-> MKTO Effective End Date else remaning logic as it isOpp Plan of Record Renewal Date = Master Sub End Date
                *********************************************************************************** */ 
                if(o.SBQQ__PrimaryQuote__c !=null && (o.SBQQ__PrimaryQuote__r.MKTO_Effective_End_Date__c!=o.Sub_End_Date__c)){
                    newOpp.Plan_of_Record_Renewal_Date__c = o.SBQQ__PrimaryQuote__r.MKTO_Effective_End_Date__c;
                } else if(o.Sub_End_Date__c!=null){
                    newOpp.Plan_of_Record_Renewal_Date__c = o.Sub_End_Date__c;
                }
                
                if (o.Sub_End_Date__c != null) {
                    newOpp.CloseDate = o.Sub_End_Date__c;                                       
                    if(newOpp.Plan_of_Record_Renewal_Date__c != null)
                        newOpp.Sub_Start_Date__c = newOpp.Plan_of_Record_Renewal_Date__c.addDays(1);
                    if(newOpp.Sub_Start_Date__c != null)
                        newOpp.Sub_End_Date__c = newOpp.Sub_Start_Date__c.addYears(1).addDays(-1);                                         
                }
                else {
                    if(o.closedate != null){ newOpp.CloseDate = o.CloseDate.addYears(1);}else if(o.Sub_Start_Date__c != null){newOpp.CloseDate = o.Sub_Start_Date__c.addYears(1);}
                    if(o.Sub_Start_Date__c != null) newOpp.Sub_Start_Date__c = o.Sub_Start_Date__c.addYears(1);
                }                
               
                if (o.AccountID != null) {
                    if (o.Sub_End_Date__c != null){
                        newOpp.Name = o.Account.Name + ' - Renewal ' + o.Sub_End_Date__c.Year();
                    }else if(o.closeDate != null){
                        newOpp.Name = o.Account.Name + ' - Renewal ' + o.closeDate.addYears(1).Year();
                    }
                } else {
                    if (test.isrunningtest()) newOpp.Name = 'Test Class';
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
                renewalOpps.add(newOpp);

            }
        }

        if (renewalOpps.size() > 0) { 
            return renewalOpps;
        }
        return null;        
    }
    
    /**create OpportunityLineItems***/    
    public static List<OpportunityLineItem> createOlis(List < Opportunity > Renewal_Opps) {
        Set<String> ProductsWhereQuantityMustBeAsOldOpp = new Set<String>(System.Label.ProductsWhereQuantityMustBeAsOldOpp.split('#'));
        
        Map<Id, Id> oppNewmap = new Map<Id, Id>();
        for (opportunity opp_new: Renewal_Opps) {
            oppNewmap.put(opp_new.Prior_Opportunity__c, opp_new.ID);
        }
        List <OpportunityLineItem > newOplList = new List < OpportunityLineItem > ();
        for (opportunity opp_new: Renewal_Opps) {
            List <OpportunityLineItem > OldOplList = new List < OpportunityLineItem > ();         
            if (opptyWithLineItemMap.containsKey(opp_new.Prior_Opportunity__c) && opptyWithLineItemMap.get(opp_new.Prior_Opportunity__c) != null)
                OldOplList = opptyWithLineItemMap.get(opp_new.Prior_Opportunity__c);
            integer counter = 1;
           for (OpportunityLineItem ol: OldOplList) {
               if (ol.Product_Type__c != 'Services') {
                    OpportunityLineItem newOpl = ol.clone(false, true);
                    if(oppNewmap.containsKey(ol.OpportunityId)) newOpl.OpportunityId = oppNewmap.get(ol.OpportunityId);
                    if(ol.ServiceEndDate__c != null){ 
                        newOpl.ServiceDate =  ol.ServiceEndDate__c.addDays(1);
                    }else{
                       if(ol.ServiceDate !=null) newOpl.ServiceDate = ol.ServiceDate.addYears(1);
                    }
                    newOpl.OLI_ID__C = ol.ID;
                    newopl.Total_ARR_for_RUSF__c = newOpl.Total_ARR__c;
                    if (ProductsWhereQuantityMustBeAsOldOpp.contains(ol.Pricebookentry.Product2.ProductCode)) {
                        newOpl.Months__c = 12;
                        newOpl.Quantity = ol.Quantity;
                    } else {
                        newOpl.Months__c = 12;
                        newOpl.Quantity = 12;
                    }
                    newOpl.Prior_OLI_Name__c = ol.pricebookentry.product2.name + ' for ' + ol.Opportunity.name;
                    if (ol.Opportunity.Quarterly_Renewal__c == null && newOpl.ServiceDate != null){  
                        newOpl.ServiceEndDate__c = newOpl.ServiceDate.addYears(1).addDays(-1);
                    } else if (ol.Opportunity.Quarterly_Renewal__c != null && ol.Opportunity.Sub_End_Date__c != null)
                       newOpl.ServiceEndDate__c = ol.Opportunity.Sub_End_Date__c.addDays(counter * 90);
                    
                    newOplList.add(newOpl);
                    counter++;
                }
            }
            if (newOplList.size() > 0) {       
                return newOplList;         
            }
        }
        return null;
    }

    public static List<Asset> UpdateAssets(List<Opportunity> Renewal_Opps) {
        
        Map<Id, Id> oppNewmap = new Map<Id, Id>();
        List<Asset> as_lst    =  new List<Asset>();  
           
        for (opportunity opp_new: Renewal_Opps) {
            oppNewmap.put(opp_new.Prior_Opportunity__c, opp_new.Id);            
        }
        
        for(Asset ab : assetsToBeUpdated){
            if(oppNewmap.containsKey(ab.Opportunity__c)){
                ab.latest_opportunity__c = oppNewmap.get(ab.Opportunity__c);
                as_lst.add(ab);
            }       
        }
           
        if(!as_lst.isEmpty()) {
            Utility.haveupdatedAssets = false;
            return as_lst;
        }
        return null;        
    }

    public static List<opportunityContactRole> createOppContacts(List < Opportunity > Renewal_Opps) {

        Map<Id, Id> oppNewmap = new Map<Id, Id>();
        for(opportunity opp_new: Renewal_Opps) {
            oppNewmap.put(opp_new.Prior_Opportunity__c, opp_new.Id);
        }
        for (opportunity opp_n: Renewal_Opps) {
            List<opportunityContactRole> oldoppConRoles = new List<OpportunityContactRole> ();
            List<opportunityContactRole> newoppConRoles = new List<OpportunityContactRole> ();
            if (opp_n.Prior_Opportunity__c != null)
                if(OpConRole.containsKey(opp_n.Prior_Opportunity__c) && OpConRole.get(opp_n.Prior_Opportunity__c) != null)
                    oldoppConRoles = OpConRole.get(opp_n.Prior_Opportunity__c);
            for (OpportunityContactRole ol: oldoppConRoles) {
                OpportunityContactRole newOpConRole = ol.clone(false, true);
                if(oppNewmap.containsKey(ol.OpportunityId))
                newOpConRole.OpportunityId = oppNewmap.get(ol.OpportunityId);
                newoppConRoles.add(newOpConRole);
            }

            if (newoppConRoles.size() > 0) {
                return newoppConRoles;
            }

        }
        return null;
    }
    
}