/* ********************************************************************************************************************
* Created this class to Send Subscriptions along with Assets to SPA system.
* Created Date: Dec 23, 2015
* Created By: Jade Team
* Last Modified By: Jade Team, on 3rd May 2017
* Purpose: APPS-12802: Munchkin ID is Null - for sending Sandbox and Partner Instance assets to SPA 
* Last Modified By : Priyanka Shende, Jade Global Inc On 15th May 2017
* Purpose          : If the opportunity type is New Business then Send the sub prod code with Qty to SPA 
* Line No          :  464, 565
* Last Modified By : Priyanka Shende, Jade Global Inc on 25th May 2017
* Purpose          : Changed the argLevel population logic, checking product code from asset, Commented the OLI For Loop
* Line No          : 407 to 412 , 418 to 448(Commented OLI For Loop)
* Last Modified By : Priyanka Shende, Jade Global Inc on 5th June 2017
* Purpose          : 1. SPA fields Validation while send to SPA
*                    2. If Mandatory SPA field is blank then mark the Asset Status as SF Error
* Line No          : 612 to 639 and 741 to 743 and 565 to 569

* Last modified By : Priyanka Shende, Jade Global Inc on 16th May 2018
* Purpose          : If UserName contains Special Character '+' sign then replace with '%2B', JIRA Ticket: LM-110209
*
* Last modified By : Priyanka Shende, Jade Global Inc on 12th July 2018
* Purpose          : No dev sandbox for ReminderMedia in SFDC  APPS-14609 
*                    (If Purpose = 'Partner Sandbox' then sending its related production asset subscriptions to SPA

* Last modified By : Priyanka Shende, Jade Global Inc on 1st August  2018
* Purpose          : 1. Change quantity associated with Life Cycle Modeler : APPS-20694
                     2. APPS-15434: Adding non SPA products to Custom Setting

* Last Modified By : Jade Global Inc, on 8th September 2018
* Purpose          : To handle Phoenix Provisioning Scenarios
					 Added check for Phoenix Pricebooks and for checking Opportunity->Quote-> Group Line Item
*******************************************************************************************************************/

public class AssetAutoProvisioning{
    public static boolean isFirstRun = true;
    public static map<Id,String> mapIdWithProvisionStatus = new map<Id,String>(); //To update all Assets with Provision Status
    public static Map<Id,Opportunity> mapOppIdWithOpp;
    public static map<Id,Decimal> mapOLWithSalesInsight;
    public static map<Id,Decimal> mapOLWithOutlook;
    public static map<String,AssetProductFamilyAutoProvisioning__c> mapProductCodeFiltering = AssetProductFamilyAutoProvisioning__c.getAll();
    public static Map<Id,List<SBQQ__Subscription__c>> ContractIdSubscriptionsMap = new Map<Id,List<SBQQ__Subscription__c>>();
    public static Map<Id,Id> oppIdContractIdMap = new Map<Id,Id>();
    public static map<id,string> assIdWithSPAParameters;
    //Custom Label for Product Codes
    public static String PARTNER_INSTANCE_PRODUCT_CODE = Label.Partner_Instance_Product_Code;
    public static String DEVELOPER_SANDBOX_INSTANCE_PRODUCT_CODE = Label.Developer_Sandbox_Instance_Product_Code;
    public static String SANDBOX_INSTANCE_PRODUCT_CODE = Label.Sandbox_Instance_Product_Code;
    public static String PROVISION_STATUS_SF_ERROR = Label.ProvisionErrorStatus;
    public static String PROVISION_STATUS_ERROR=Label.Provisioning_Exception_Status;
    public static Id AssetId; 
    public static Map<Id,Asset> AssetMap=new Map<Id,Asset>();
    public static string LCMEnggCode    	    = Label.Life_Cycle_Maodeler_Engg_Code; 
    public static string LCMProdCode    	    = 'PROD-APPS-LCM';
    public static string AdditionalModelProdCode    = 'PROD-APPS-LCM-MOD';
    // Process list of Assets for auto-provisioning 
    public static void processAssets()
    {
        List<Id> assId = new List<Id>();
        List<Asset> lstAss = new List<Asset>();
        set<id> AssetIds = new set<id>();
        map<id,list<Asset>> contractWithAsset  = new map<id,list<Asset>>();
        Set<Id> contractIdSet = new Set<Id>();
        // Get Assets where, Asset_Type__c = 'Instance' and Provision_Status__c = 'New'
        /* On 23rd March 2017 Jade Team added condition in where clause to exclude feature renewals from SPA Call. 
           APPS-12245 : Feature Renewals should not be picked up in SPA - query result too large unnecessarily 
        */  
        // Added Migration check by Jade Team for excluding Exodus assets form Provisioning automation 
        lstAss = [Select Id ,Contract__c,Product2.ProductCode,purpose__c,RecordType.Name,Opportunity__c from Asset where Asset_Type__c = 'Instance' and Provision_Status__c = 'New' and RecordType.Name='CPQ Instance Asset' AND Provisioning_Type__c!='Migration' AND ((Opportunity__r.Type!='Renewal' OR Contract__r.SBQQ__Opportunity__r.Type!='Renewal') OR (Contract__c!=null AND Contract__r.SBQQ__Opportunity__r.Type='Renewal' AND Contract__r.SBQQ__Quote__c!=null AND (Contract__r.SBQQ__Quote__r.Rubiks_Quote__c =true OR Contract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c = true))) limit 100];
        if(!lstAss.isEmpty()){
            for(Asset asse : lstAss){
               // assId.add(asse.Id);
                AssetIds.add(asse.id);
                if(asse.Contract__c!=null){
                    //Prepare map of contract Id and its asset
                    if(contractWithAsset.containsKey(asse.Contract__c)){
                        contractWithAsset.get(asse.Contract__c).add(asse);
                    }
                    else{
                        contractWithAsset.put(asse.Contract__c,new list<Asset>{asse});
                    }
                }// End of Contract If        
            }//End of lstAss For  
        }//End of lstAssIf
        system.debug('contractWithAsset===========' + contractWithAsset);
        
        if(!contractWithAsset.isEmpty()){
            for(id contractid:contractWithAsset.keyset()){
                boolean RTPAssetPresent;
                list<Asset> contraAsset = contractWithAsset.get(contractid);
                if(!contraAsset.isEmpty()){
                     for(Asset conAsset : contraAsset){
                         if(conAsset.Product2.ProductCode.contains('RTP')){
                             RTPAssetPresent = true;
                         }
                     }
                }//End of Contract Asset If
                if(contraAsset.size() >1 && RTPAssetPresent == true){
                    for(Asset conAsset : contraAsset){
                        if(conAsset.Product2.ProductCode.contains('RTP') && RTPAssetPresent){
                            AssetIds.remove(conAsset.id);
                        }//End of RTP If
                    }//End of Contract Asset If
                }//End of Contract Asset If
            }// End of For
        }//End of If
        if(!AssetIds.isEmpty()){
            assId.addAll(AssetIds);
            final Integer maxRecords = 100; //Total
            final Integer maxBatchSize = 10; //Per batch callout
            // Counter
            Integer recordsProcessed = 0;
            // In batches of maxBatchSize, processAutoProvisioning while items remain
            while(recordsProcessed < maxRecords && assId.size() > 0)
            {
                // Batch id list
                List<Id> batchAssetIds = new List<Id>();
                
                // Batches of maxBatchSize (or less, if less exist)
                Integer batchSize = maxBatchSize;
                
                if(batchSize > (maxRecords - recordsProcessed))
                {
                    batchSize = (maxRecords - recordsProcessed);
                }
                
                for(Integer j = 0; j < batchSize; j++)
                {
                    if(assId.size() > 0)
                    {
                        batchAssetIds.add(assId[0]);
                        assId.remove(0);
                        recordsProcessed += 1;
                    }
                }//End of batch size For 
                
                if(batchAssetIds.size() > 0)
                {
                    system.debug('batchAssetIds================'+batchAssetIds);               
                    // Send batch to @Future method
                    processAssetAutoProvisioningBatch(batchAssetIds);
                }
                else
                {
                    break;
                }
            }//End of record processing If
        }//End of Asset Id IF
    
    }//End of Process Asset Method
     
    @future(callout=true)
    public static void processAssetAutoProvisioningBatch(List<Id> assetIds){
    
    try{
        List<String> lstPrdCode = new List<String>();
        //GET the SteelBrick pricebook ID stored in the custom setting
        SteelBrickCPQPricebook__c SBPB = SteelBrickCPQPricebook__c.getOrgDefaults();
        
        Set<Id> oppIds = new Set<Id>();
        List<Asset> lstAsset = new List<Asset>();
        Set<Id> assetIdSet = new Set<Id>(); 
        map<id,id> assetWithOpptyId  = new map<id,id>();
        //Declaring varibales for subscription fields by SP
        string Lang = '';string Locale = '';string Time_Zone = '';
        
        mapOppIdWithOpp = new Map<Id,Opportunity>();
        mapOLWithSalesInsight = new Map<Id,Decimal>();
        mapOLWithOutlook = new Map<Id,Decimal>();
        Set<Id> setLMSANDolId= new Set<Id>();
        String attachmentName ='';
        
        // Get All Subscriptions associated with Assets - assetIdSet
        Map<Id,List<SBQQ__Subscription__c>> assetToSubscriptionsMap = new Map<Id,List<SBQQ__Subscription__c>>();        
        // Map of Product Code to Engineering Code
        //Map<String,String> prodCodeToEngCode = new Map<String,String>(); 
        Map<String,Product_SKU_Engineering_Code__c> prodCodeToEngCode = new Map<String,Product_SKU_Engineering_Code__c>();
        
        //Contract ids of Asset     
        set<id> contractIds  = new set<id>();       
        //Requiredby id and related list of Subscriptions used in sending Engineering Code      
        map<id,list<SBQQ__Subscription__c>>  reqByIdwithSubs  = new map<id,list<SBQQ__Subscription__c>>();
        //map of group and list of subscriptions
        map<id,list<SBQQ__Subscription__c>>  grpIdwithSubs  = new map<id,list<SBQQ__Subscription__c>>();    
        
         assIdWithSPAParameters = new map<id,string>();
        if(AssetProductFamilyAutoProvisioning__c.getAll().values()!=null){
            for(AssetProductFamilyAutoProvisioning__c asset: AssetProductFamilyAutoProvisioning__c.getAll().values()){
                lstPrdCode.add(asset.Name);
            }//End Of For
        }//End of If
        
        String outlookPlugIn = AssetProductFamilyAutoProvisioning__c.getInstance('Outlook plug-in').Product_Code__c;
        String salesInsight = AssetProductFamilyAutoProvisioning__c.getInstance('Sales Insight').Product_Code__c;
        
        // Get All Assets associated - assetIds
        /* On 23rd March 2017 Jade Team added condition in where clause to exclude feature renewals from SPA Call. 
           APPS-12245 : Feature Renewals should not be picked up in SPA - query result too large unnecessarily 
        */ 
        for(Asset thisAsset :[SELECT id,Opportunity__r.type,Name, Contract__c,Product2.ProductCode, Contract__r.Primary_Asset__c,Contract__r.Primary_Asset__r.Purpose__c,Purpose__c, Provision_Status__c, Asset_Type__c, Production_Asset__r.Purpose__c, Production_Asset__c, SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c,Munchkin_ID__c,Provisioning_Type__c,Opportunity__r.SBQQ__PrimaryQuote__r.Rubiks_Quote__c,Contract__r.SBQQ__Quote__r.Rubiks_Quote__c,Opportunity__c,Contract__r.SBQQ__Opportunity__c,SBQQ__LatestQuoteLine__c,SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Rubiks_Quote__c,SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.Rubiks_Quote__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.MDQ_Quote__c,Contract__r.SBQQ__Quote__r.MDQ_Quote__c,SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.MDQ_Quote__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.Instance_Number__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.type,SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c,Contract__r.SBQQ__Quote__r.Instance_Rollup__c,Data_Center__c , Contract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c,SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c FROM Asset WHERE Id IN : assetIds AND (((Opportunity__r.Type!=null AND Opportunity__r.Type!='Renewal') OR (Contract__r.SBQQ__Opportunity__r.Type!=null AND Contract__r.SBQQ__Opportunity__r.Type!='Renewal'))OR(Contract__r.SBQQ__Opportunity__r.Type!=null AND Contract__r.SBQQ__Opportunity__r.Type='Renewal' AND (Contract__c!=null AND Contract__r.SBQQ__Opportunity__r.Type='Renewal' AND Contract__r.SBQQ__Quote__c!=null AND (Contract__r.SBQQ__Quote__r.Rubiks_Quote__c =true OR Contract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c = true ))))]){  
            lstAsset.add(thisAsset); 
            AssetMap.put(thisAsset.id,thisAsset);
            if(thisAsset.Purpose__c != null && thisAsset.Purpose__c == 'Rubiks Production' && thisAsset.Product2!=null && thisAsset.Product2.ProductCode!=null && thisAsset.Product2.ProductCode!='PROD-PLAT-PARTINST-INST'){                
                assetIdSet.add(thisAsset.Id);
            }else if((thisAsset.Purpose__c.contains('Sandbox') && thisAsset.Production_Asset__c != null && thisAsset.Production_Asset__r.Purpose__c =='Rubiks Production')){
                 assetIdSet.add(thisAsset.Production_Asset__c);
            }else if((thisAsset.Product2.ProductCode!=null && thisAsset.Product2!=null && thisAsset.Product2.ProductCode=='PROD-PLAT-PARTINST-INST' && thisAsset.Purpose__c!=null && (thisAsset.Purpose__c=='Production' || thisAsset.Purpose__c == 'Rubiks Production') && thisAsset.Contract__r.Primary_Asset__r.Purpose__c!=null && thisAsset.Contract__r.Primary_Asset__r.Purpose__c.contains('Production') && thisAsset.Contract__r.Primary_Asset__c!=null)){
                assetIdSet.add(thisAsset.Contract__r.Primary_Asset__c);
            }
            
            if(thisAsset.Contract__c!=null){        
                contractIds.add(thisAsset.Contract__c);     
            }
        }//End Of For
        system.debug('List Of asset---------'+lstAsset);
        system.debug('assetIdSet***************'+assetIdSet);       

        // Consider only those Subscriptions for which Product Code lays in Custom Setting - Product SKU Engineering Code(Product_SKU_Engineering_Code__c)   
        //Modified by Jade on 13th April 2017 - In Product_SKU_Engineering_Code__c custom setting All products available - related to Engineering code and Quantity.
        //New flag added for Quantity products, if the quantity flag is true then those products not consider for Engineering code      
        for(Product_SKU_Engineering_Code__c skuEngCodeRec :Product_SKU_Engineering_Code__c.getAll().values()){
            if(skuEngCodeRec.Product_Code__c != null && skuEngCodeRec.Engineering_Code__c != null && skuEngCodeRec.No_Need_To_Send_To_SPA__c==False){
                prodCodeToEngCode.put(skuEngCodeRec.Product_Code__c,skuEngCodeRec);
            }                
        }
        system.debug('prodCodeToEngCode**************************'+prodCodeToEngCode);                      
        // Get All Subscriptions of these Assets and pass only those for which Product Code present in custom setting - Product_SKU_Engineering_Code__c     
        
        for(SBQQ__Subscription__c sub :[Select SBQQ__Product__r.ProductCode, Production_Asset__r.Product_Code__c, Production_Asset__c, Production_Asset__r.Purpose__c, SBQQ__Contract__r.SBQQ__Opportunity__c  , Subscription_Product_Code__c , SBQQ__Product__c , SBQQ__Quantity__c ,SBQQ__SegmentQuantity__c, SBQQ__Product__r.Product_Type__c ,  Id,SBQQ__StartDate__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c,Instance_Number__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c , SBQQ__QuoteLine__r.SBQQ__Group__c FROM SBQQ__Subscription__c WHERE SBQQ__Contract__c IN : contractIds AND SBQQ__Quantity__c >=1]){
            if(prodCodeToEngCode.containsKey(sub.Subscription_Product_Code__c)){
                if(assetToSubscriptionsMap.containsKey(sub.Production_Asset__c)){
                    assetToSubscriptionsMap.get(sub.Production_Asset__c).add(sub);
                }else{
                    assetToSubscriptionsMap.put(sub.Production_Asset__c, new List<SBQQ__Subscription__c>{sub});
                }
            }
            
            if(sub.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c!=null){       
                 if(reqByIdwithSubs.containsKey(sub.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c)){       
                     reqByIdwithSubs.get(sub.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c).add(sub);      
                 }//End of IF loop      
                 else{      
                     reqByIdwithSubs.put(sub.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,new list<SBQQ__Subscription__c>{sub});      
                 }//End of Else loop        
            }//End of IF block
            //populate values in  grpIdwithSubs
            else if(sub.SBQQ__QuoteLine__r.SBQQ__Group__c!=null){
                if(grpIdwithSubs.containsKey(sub.SBQQ__QuoteLine__r.SBQQ__Group__c)){       
                     grpIdwithSubs.get(sub.SBQQ__QuoteLine__r.SBQQ__Group__c).add(sub);      
                 }//End of IF loop      
                 else{      
                     grpIdwithSubs.put(sub.SBQQ__QuoteLine__r.SBQQ__Group__c,new list<SBQQ__Subscription__c>{sub});      
                 }//End of Else loop 
            }
        } //End of subscription For
        
        system.debug('Subscriptions ready to provisioning assetToSubscriptionsMap***********' + assetToSubscriptionsMap);                     
        if(!lstAsset.isEmpty()){
            for(Asset a : lstAsset){
                 if(a.Opportunity__c!=null ){
                    oppIds.add(a.Opportunity__c); 
                     assetWithOpptyId.put(a.id,a.Opportunity__c);
                }else if(a.Contract__c!=null && a.Contract__r.SBQQ__Opportunity__c!=null){
                    oppIds.add(a.Contract__r.SBQQ__Opportunity__c); 
                     assetWithOpptyId.put(a.id,a.Contract__r.SBQQ__Opportunity__c);
                }else if(a.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c!=null){
                  oppIds.add(a.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c); 
                    assetWithOpptyId.put(a.id,a.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c);
                }
                else if(a.SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c!=null){
                    oppIds.add(a.SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c); 
                    assetWithOpptyId.put(a.id,a.SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c);
                }   
            }//End of FOR loop
        }//End Of assetList null check IF   
        
        // only consider oppies that have oppy line itmes that require a provisioning action
        //Added 6 new fields in below soql 3 for Opp and 3 for Oplineitems by SP
        List<Opportunity> mlmOps = [
                                    SELECT  o.Id,o.type,o.SBQQ__PrimaryQuote__r.Name, o.Name, o.Account.Name, o.ContractId, o.Account.Website, o.Primary_Marketo_User_Email__c,o.SBQQ__PrimaryQuote__r.Rubiks_Quote__c,o.Primary_Marketo_User_Lookup__r.FirstName, 
                                    o.Primary_Marketo_User_Lookup__r.LastName, o.MP_Purpose__c, o.MP_Reseller_Partner__c,o.Subscription_Language__c,o.Subscription_Locale__c,Subscription_Time_Zone__c,o.Sub_End_Date__c,o.Sub_Start_Date__c,pricebook2Id, 
                                    (SELECT ol.Id, ol.Name, ol.Product_Type__c, ol.Users__c, ol.MLM_Edition__c, ol.Instance_Number__c, ol.Related_Asset__c,Subscription_Language__c,Subscription_Locale__c,Subscription_Time_Zone__c,   
                                    ol.PricebookEntry.Product2.Name, ol.PricebookEntry.Product2.Family, ol.PricebookEntry.Product2.ProductCode,ol.SBQQ__QuoteLine__c,ol.SBQQ__QuoteLine__r.SBQQ__Quote__r.Rubiks_Quote__c,ol.SBQQ__QuoteLine__r.SBQQ__Quote__r.MDQ_Quote__c  
                                    FROM o.OpportunityLineItems ol WHERE ol.PricebookEntry.Product2.ProductCode IN :lstPrdCode )            
                                    FROM Opportunity o WHERE o.Id IN :oppIds];
									
        System.debug('List of Opportuntiy------'+mlmOps);
        if(!mlmOps.isEmpty()){
            for(Opportunity o : mlmOps){
				if(o.pricebook2id==SBPB.ID__c || (SBPB.Phoenix_Price_Books__c.contains(o.pricebook2Id))){
					mapOppIdWithOpp.put(o.Id,o);
					if(!o.OpportunityLineItems.isEmpty()){
						for(OpportunityLineItem opplineItems : o.OpportunityLineItems){
							
							if(opplineItems.PricebookEntry.Product2.ProductCode == 'LM-SAND'){
								setLMSANDolId.add(o.Id);
							}
							if(opplineItems.PricebookEntry.Product2.ProductCode == salesInsight && opplineItems.Users__c!=null){
								
								if(mapOLWithSalesInsight.containsKey(o.Id)){
									Decimal i = mapOLWithSalesInsight.get(o.Id) + opplineItems.Users__c;
									mapOLWithSalesInsight.put(o.Id,i);      
								}
								else{
									mapOLWithSalesInsight.put(o.Id,opplineItems.Users__c);  
								}
							}
							if(opplineItems.PricebookEntry.Product2.ProductCode == outlookPlugIn && opplineItems.Users__c!=null){
								if(mapOLWithOutlook.containsKey(o.Id)){
									Decimal j = mapOLWithOutlook.get(o.Id) + opplineItems.Users__c;
									mapOLWithOutlook.put(o.Id,opplineItems.Users__c);
								}
								else{
									mapOLWithOutlook.put(o.Id,opplineItems.Users__c);  
								}
							}
						}//End Of OLI FOR
					}//End of OLI If
				}//End of If 
            } //End of Opportunity List For
        }//End of opportunity If null check
        // iterate through assets and call api if needed
        if(!lstAsset.isEmpty()){
        for(Asset ast : lstAsset){
                AssetId=ast.Id;
                boolean MDQQuote= false;
                if((ast.SBQQ__QuoteLine__c!=null && (ast.SBQQ__QuoteLine__r.SBQQ__Quote__r.MDQ_Quote__c==true || ast.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c == true))||(ast.Contract__c!=null && (ast.Contract__r.SBQQ__Quote__r.MDQ_Quote__c==true || ast.Contract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c == true))||(ast.SBQQ__LatestQuoteLine__c!=null && (ast.SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.MDQ_Quote__c==true || ast.SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c == true))){
                    MDQQuote =true;
                }
                attachmentName = ast.Name;
                Map<String, String> params =  new Map<String, String>();
                String subEngCodesToSPAString = ''; 
                String subEngCodesQtyToSPAString = '';
                
                Id assetOpportunityid ;
                
                assetOpportunityid =(ast.Opportunity__c!=null)?ast.Opportunity__c:null; 
                
                assetOpportunityid =(assetOpportunityid ==null && ast.Contract__c!=null && ast.Contract__r.SBQQ__Opportunity__c!=null)?ast.Contract__r.SBQQ__Opportunity__c:assetOpportunityid ; 
                
                assetOpportunityid =(assetOpportunityid ==null && ast.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c!=null)?ast.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c:assetOpportunityid ; 
                
                assetOpportunityid =(assetOpportunityid ==null && ast.SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c!=null)?ast.SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c:assetOpportunityid ; 
                
                system.debug('#################### assetOpportunityid'+assetOpportunityid);
                //set product code from asset
                params.put('argProdCode', ast.Product2.ProductCode == null ? '' : ast.Product2.ProductCode);
        
                // Rubiks check for Renewal and Upsell/Crossell Opportunity
                boolean RubiksQuote =false;
                if(ast.Opportunity__r.Type == 'New Business' || ((ast.Opportunity__r.Type== 'Renewal' && ( ast.Contract__r.SBQQ__Quote__r.Rubiks_Quote__c==true || ast.SBQQ__QuoteLine__r.SBQQ__Quote__r.Rubiks_Quote__c==true || ast.SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.Rubiks_Quote__c==true || ast.Contract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c == true)) || (ast.Opportunity__r.Type =='Upsell/Crossell' && (ast.Contract__r.SBQQ__Quote__r.Rubiks_Quote__c==true || ast.SBQQ__QuoteLine__r.SBQQ__Quote__r.Rubiks_Quote__c==true || ast.SBQQ__LatestQuoteLine__r.SBQQ__Quote__r.Rubiks_Quote__c==true || ast.Contract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c == true))))
                {
                    RubiksQuote=true; 
                    system.debug('################## '+RubiksQuote);
                }
                system.debug('Asset Id ###############'+ast.id);
                
                if(assetOpportunityid!=null && RubiksQuote && mapOppIdWithOpp.containsKey(assetOpportunityid)){
                    Opportunity opp = mapOppIdWithOpp.get(assetOpportunityid);
                    System.debug('Processing oppy [' + opp.Id + ']');
                   
                    // Assign non-null Opportunity values to placeholder vars
                    String AccountName = opp.Account.Name;
                    AccountName = AccountName.trim();
                    AccountName = AccountName.replaceAll('[^a-zA-Z0-9 ]','');
                    if(AccountName.length() > 58){
                        AccountName = AccountName.substring(0,58);
                    }
                    System.debug('$%$%$%$%$%$%$ : '+AccountName);
                    //params.put('argName', opp.Account.Name == null ? '' : opp.Account.Name);
                    params.put('argName', AccountName == null ? '' : AccountName);
                    //**************************************
                    
                    params.put('argHomePage', opp.Account.Website == null ? '' : opp.Account.Website);
          
          /* *****************************************************************************************************************
          * Last modified By : Priyanka Shende, Jade Global Inc on 16th May 2018
          * Purpose          : If UserName contains Special Character '+' sign then replace with '%2B', JIRA Ticket: LM-110209
          * *******************************************************************************************************************/
                    params.put('argUserName', opp.Primary_Marketo_User_Email__c == null ? '' : opp.Primary_Marketo_User_Email__c.replace('+','%2B'));
                    
                    if(opp.Primary_Marketo_User_Lookup__r != null)
                    {
                        params.put('argFirstName', opp.Primary_Marketo_User_Lookup__r.FirstName);
                        params.put('argLastName',  opp.Primary_Marketo_User_Lookup__r.LastName);
                    }else{
                        params.put('argFirstName', '');
                        params.put('argLastName',  '');
                    }
                    
                    // Rubiks requirement - If Sandbox asset, Purpose = 'Sandbox'
                    // If Production asset, Purpose = 'Production'
                    // params.put('argPurpose', opp.MP_Purpose__c == null ? '' : opp.MP_Purpose__c);
                    
                    // Setting the parameters 
                    
                    //Renewal Requirement - munchkin id for SPA call 
                    if(ast.Purpose__c != 'Sandbox' && (ast.Id!=null && assetToSubscriptionsMap.containsKey(ast.Id)) || ((ast.Contract__r.Primary_Asset__c!=null && assetToSubscriptionsMap.containsKey(ast.Contract__r.Primary_Asset__c))&& ast.Opportunity__r.type!=null && ast.Opportunity__r.type=='Renewal' && ast.Munchkin_ID__c!=null )){
                           params.put('argMunchkinID',ast.Munchkin_ID__c==null ? '' : ast.Munchkin_ID__c);
                            system.debug('ast.Munchkin_ID__c###############' + ast.Munchkin_ID__c);
                    }
            
                    system.debug('Params -------------'+params);
                    //Renewal Requirement - Provisioning Type for SPA call
                    params.put('argProvisioningType',ast.Provisioning_Type__c==null ? '' : ast.Provisioning_Type__c);
                    
                    params.put('argPurpose', ast.Purpose__c == null ? '' : ast.Purpose__c);

                    params.put('argChanelPartner', opp.MP_Reseller_Partner__c == null ? '' : opp.MP_Reseller_Partner__c);
                
                    params.put('argLevel','Marketo - Lite');
                    
                    //params.put('argProdCode', '');
                    params.put('argOppyId', '');
                    params.put('argInstanceNumber', String.valueOf(0));
                    params.put('argAsset', '');
                    params.put('argSessionId', String.valueOf(Crypto.getRandomInteger()));
                
                    params.put('argSandbox', '0');
                    if (setLMSANDolId.contains(opp.Id)){
                        System.debug('oppy [' + opp.Id + '] has a sandbox line item');
                        params.put('argSandbox', '1');
                    }else{
                        System.debug('oppy [' + opp.Id + '] has a no sandbox line item');
                    }

                    params.put('argOutlookSeats', '0');
                    params.put('argSalesforceSeats', '0');
                    
                    // Put the sum of User Count for Sales Insight.
                    // if the list is empty, fall back to the default value.
                    if(mapOLWithSalesInsight.containsKey(opp.Id)){
                        System.debug('oppy [' + opp.Id + '] has a salesinsight line item');
                        params.put('argSalesforceSeats', String.valueOf(mapOLWithSalesInsight.get(opp.Id)));
                        params.put('argOutlookSeats', String.valueOf(mapOLWithSalesInsight.get(opp.Id)));
                    }else{
                        System.debug('oppy [' + opp.Id + '] has a no salesinsight line item');
                    }
                   
                    // Put the sum of User Count for Outlook Seat Line.
                    if (mapOLWithOutlook.containsKey(opp.Id)){
                        System.debug('oppy [' + opp.Id + '] has a outlook seat line item');
                        params.put('argOutlookSeats',  String.valueOf(mapOLWithOutlook.get(opp.Id)));
                    }else{
                        System.debug('oppy [' + opp.Id + '] has a no outlook seat line item');
                    }
                    
                   // Lang = opp.Subscription_Language__c!=null ? opp.Subscription_Language__c : '';
                   // Locale = opp.Subscription_Locale__c!=null ? opp.Subscription_Locale__c : '';
                   // Time_Zone = opp.Subscription_Time_Zone__c!=null ? opp.Subscription_Time_Zone__c : '';
                    system.debug('######'+opp.OpportunityLineItems.Size());
                    
                    //Adding Params for Subscription Lang,Locale and Time zone  values
                    params.put('argSubLang',opp.Subscription_Language__c!=null ? opp.Subscription_Language__c : '');
                    params.put('argSubLocale',opp.Subscription_Locale__c!=null ? opp.Subscription_Locale__c : '' );
                    params.put('argSubTZone',opp.Subscription_Time_Zone__c!=null ? opp.Subscription_Time_Zone__c : '');                                              
                    if(ast.Opportunity__r.Type==Label.OPPORTUNITY_TYPE_NEW_BUSINESS){
                        params.put('dc',ast.Data_Center__c!=null ? ast.Data_Center__c : '');                                              
                    }
                    params.put('argLevel', mapProductCodeFiltering.get(ast.Product2.ProductCode).ArgLevel__c);
                    system.debug('ast.Product2.ProductCode='+ast.Product2.ProductCode);
                    // Need clarification on Instance Number
                    // set argInstanceNumber 
                    //params.put('argInstanceNumber', ol.Instance_Number__c == null? '': String.valueOf(ol.Instance_Number__c));
                    
                    
                    id prodAsetId=ast.Id;
                    if(ast.Purpose__c !=null && ((ast.Purpose__c == 'Rubiks Production' && assetToSubscriptionsMap.containsKey(ast.Id)) || (ast.Purpose__c.contains('Sandbox') && assetToSubscriptionsMap.containsKey(ast.Production_Asset__c)) || (ast.Product2!=null && ast.Product2.ProductCode!=null && ast.Product2.ProductCode=='PROD-PLAT-PARTINST-INST' && (ast.Purpose__c=='Production' || ast.Purpose__c=='Rubiks Production') && ast.Contract__r.Primary_Asset__r.Purpose__c!=null && ast.Contract__r.Primary_Asset__r.Purpose__c.contains('Production')))){
                          if(ast.Purpose__c.contains('Sandbox') && ast.Production_Asset__c!=null && assetToSubscriptionsMap.containsKey(ast.Production_Asset__c)){
                            prodAsetId=ast.Production_Asset__c;
                          }//End of IF block of SANDBOX Asset block from Production_Asset__c
                          else if(/* ast.Contract__r.SBQQ__Quote__r.Instance_Rollup__c==1 * &&*/ ast.Product2.ProductCode!=null && ast.Product2!=null && ast.Product2.ProductCode=='PROD-PLAT-PARTINST-INST' && (ast.Purpose__c=='Production' || ast.Purpose__c=='Rubiks Production') && ast.Contract__r.Primary_Asset__c!=null && ast.Contract__r.Primary_Asset__r.Purpose__c!=null && ast.Contract__r.Primary_Asset__r.Purpose__c.contains('Production')){
                          prodAsetId=ast.Contract__r.Primary_Asset__c;
                          }//End of IF block of PARTNER Asset;Get Production Asset id from Conract Primary_Asset__c
                        system.debug('###### opp.Type'+opp.Type);
                        
                        list<SBQQ__Subscription__c> SubscriptionList = new list<SBQQ__Subscription__c>(); 
                         if(assetToSubscriptionsMap.containsKey(prodAsetId)){
                           SubscriptionList= assetToSubscriptionsMap.get(prodAsetId);
                        }
                        
                         system.debug('SUBLIST=================================' +reqByIdwithSubs.get( ast.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c));

                        system.debug('astREQBYID=================================' +ast.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c);
                        //This is used to get Subscriptions related to the Requiredby's Requiredby  present on Partner Asset
                        if(ast.Contract__r.SBQQ__Quote__r.Instance_Rollup__c>1 && ast.Product2.ProductCode=='PROD-PLAT-PARTINST-INST' &&  reqByIdwithSubs.containsKey( ast.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c)){
                           
                            SubscriptionList.clear();
                            SubscriptionList =reqByIdwithSubs.get( ast.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RequiredBy__c);
                            
                        }
                        else if(ast.Contract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c = True && ast.Product2.ProductCode=='PROD-PLAT-PARTINST-INST' && grpIdwithSubs.containsKey(ast.SBQQ__QuoteLine__r.SBQQ__Group__c)){
                            SubscriptionList.clear();
                            SubscriptionList = grpIdwithSubs.get(ast.SBQQ__QuoteLine__r.SBQQ__Group__c);
                        }
                        map<String,Double> ProdCodeWithQty = new map<String,Double>();
                        
                        if(!SubscriptionList.isEmpty()){
                            for(SBQQ__Subscription__c sub :SubscriptionList){
                                // Populate subscription in ProdCodeWithQty map
                                if(sub.SBQQ__Quantity__c!=null){
                                    ProdCodeWithQty.put(sub.SBQQ__Product__r.ProductCode,sub.SBQQ__Quantity__c);
                                }//End of If
                                
                                //This if loop is used to send ENG codes for RENEWAL opportunity 
                                system.debug('########Label.OPPORTUNITY_TYPE_RENEWAL'+Label.OPPORTUNITY_TYPE_RENEWAL);
                                if(((prodCodeToEngCode.containsKey(sub.SBQQ__Product__r.ProductCode) && MDQQuote ==false)||(MDQQuote ==TRUE && sub.SBQQ__StartDate__c<= opp.Sub_Start_Date__c)) && (opp.Type== Label.OPPORTUNITY_TYPE_RENEWAL || ast.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.type==Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL) && prodCodeToEngCode.get(sub.SBQQ__Product__r.ProductCode).Dont_Consider_Engineering_Code__c==false){
                                    system.debug('########## Inside New Business'+Label.OPPORTUNITY_TYPE_RENEWAL);
                                    if(subEngCodesToSPAString == '' || subEngCodesToSPAString == null){
                                        subEngCodesToSPAString = prodCodeToEngCode.get(sub.SBQQ__Product__r.ProductCode).Engineering_Code__c;
                                    }else{
                                        subEngCodesToSPAString = subEngCodesToSPAString + ',' + prodCodeToEngCode.get(sub.SBQQ__Product__r.ProductCode).Engineering_Code__c;
                                    }                       
                                }//End of IF block for sending ENG codes only for RENEWAL opportunity  
                                //This is used to send ENG codes with Quantity for NEW BUSINESS opportunity 
                                else if(((prodCodeToEngCode.containsKey(sub.SBQQ__Product__r.ProductCode) && MDQQuote ==false)||(MDQQuote ==TRUE && sub.SBQQ__StartDate__c<= opp.Sub_Start_Date__c)) && prodCodeToEngCode.get(sub.SBQQ__Product__r.ProductCode).Dont_Consider_Engineering_Code__c==false && opp.Type==Label.OPPORTUNITY_TYPE_NEW_BUSINESS &&  ast.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.type==Label.OPPORTUNITY_TYPE_NEW_BUSINESS){
                                    system.debug('##########Inside the new business');
                                    Product_SKU_Engineering_Code__c ProdSKU =prodCodeToEngCode.get(sub.SBQQ__Product__r.ProductCode);
                                    system.debug('########## ProdSKU '+ProdSKU );
                                    // We have added below logic as per the APPS-20694- Change quantity associated with Life Cycle Modeler JIRA
                                    if((subEngCodesToSPAString == '' || subEngCodesToSPAString == null) && ProdSKU.Engineering_Code__c!=LCMEnggCode){
                                        subEngCodesToSPAString = ProdSKU.Engineering_Code__c +':'+ sub.SBQQ__Quantity__c*ProdSKU.Quantity_Multiple__c;
                                    }else if(ProdSKU.Engineering_Code__c != LCMEnggCode){
                                        subEngCodesToSPAString = subEngCodesToSPAString + ',' + ProdSKU.Engineering_Code__c +':'+ sub.SBQQ__Quantity__c*ProdSKU.Quantity_Multiple__c;
                                    }                       
                                }//End of IF block for sending ENG codes with Quantity  for NEW BUSINESS opportunity 
                                
                                /*This is used to send Quantity for Manual product for NEW BUSINESS opportunity only
                                  Pass Engineering code with quantity where the Dont_Consider_Engineering_Code__c = TRUE
                                */
                                if(((prodCodeToEngCode.containsKey(sub.SBQQ__Product__r.ProductCode) && MDQQuote ==false)||(MDQQuote ==TRUE && sub.SBQQ__StartDate__c<= opp.Sub_Start_Date__c)) && prodCodeToEngCode.get(sub.SBQQ__Product__r.ProductCode).Dont_Consider_Engineering_Code__c==true && opp.Type==Label.OPPORTUNITY_TYPE_NEW_BUSINESS &&  ast.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.type==Label.OPPORTUNITY_TYPE_NEW_BUSINESS){
                                    system.debug('Inside true condition #######');
                                     system.debug('Inside TRUE condition Product Code'+sub.SBQQ__Product__r.ProductCode);
                                     Product_SKU_Engineering_Code__c ProdSKU =prodCodeToEngCode.get(sub.SBQQ__Product__r.ProductCode);
                                    // We have added below logic as per the APPS-20694- Change quantity associated with Life Cycle Modeler JIRA
                                    if((subEngCodesQtyToSPAString == '' || subEngCodesQtyToSPAString == null) && ProdSKU.Engineering_Code__c != LCMEnggCode){
                                        subEngCodesQtyToSPAString = ProdSKU.Engineering_Code__c+':'+ sub.SBQQ__Quantity__c*ProdSKU.Quantity_Multiple__c;
                                    }else if(ProdSKU.Engineering_Code__c != LCMEnggCode){
                                        subEngCodesQtyToSPAString = subEngCodesQtyToSPAString + ',' + ProdSKU.Engineering_Code__c+':'+ sub.SBQQ__Quantity__c*ProdSKU.Quantity_Multiple__c;
                                    }         
                                }//End of IF block for send Quantity for Manual product for NEW BUSINESS opportunity only 
                            }//End of Subcription FOR loop
                            // LCM Product Send to SPA - Quantity = 1 + Additional Module Quantity
                            if(ProdCodeWithQty.containsKey(LCMProdCode)){
                                if(ProdCodeWithQty.containsKey(AdditionalModelProdCode)){
                                    double LCMQty = 1.0 + ProdCodeWithQty.get(AdditionalModelProdCode);
                                    if(subEngCodesQtyToSPAString == '' || subEngCodesQtyToSPAString == null){
                                        subEngCodesQtyToSPAString = prodCodeToEngCode.get(LCMProdCode).Engineering_Code__c+':'+ LCMQty;
                                    }else{
                                        subEngCodesQtyToSPAString = subEngCodesQtyToSPAString + ','+ prodCodeToEngCode.get(LCMProdCode).Engineering_Code__c+':'+ LCMQty;
                                    }
                                }else{
                                    if(subEngCodesQtyToSPAString == '' || subEngCodesQtyToSPAString == null){
                                        subEngCodesQtyToSPAString = prodCodeToEngCode.get(LCMProdCode).Engineering_Code__c+':'+ 1;
                                    }else{
                                        subEngCodesQtyToSPAString = subEngCodesQtyToSPAString + ','+ prodCodeToEngCode.get(LCMProdCode).Engineering_Code__c+':'+ 1; 
                                    }
                                }
                            }//End of If
                    }//End of IF of Subcription list Empty check
                    }//End of Rubik Asset IF block          
                    //Add engineering code + Quantity
                    system.debug('########## subProdEngCodes'+ subEngCodesToSPAString);
                    system.debug('########## subEngCodesToSPAString'+ subEngCodesToSPAString);
                    params.put('subProdEngCodes',subEngCodesToSPAString); 
                    //Add Quantity 
                    /* 
                        This condition added by Jade on 15th may 2017
                        Purpose - If the opportunity type is New Business then Send the sub prod code with Qty to SPA 
                    */
                    if(opp.type==Label.OPPORTUNITY_TYPE_NEW_BUSINESS){
                        params.put('subProdCodeQty',subEngCodesQtyToSPAString); 
                    }
                    // Call provisioning method
                    system.debug('ast.Id=================FOR==================='+ast.Id);
                    provision(opp,params,ast.Id,attachmentName);
                }//End of If
               
              }//End Of Asset List For
            
           }//End of Asset List If
           system.debug('Inside try');
           updateAssetsProvisioningStatus();
           // End of Logic
        }catch(Exception e){
            system.debug('Inside catch');
            updateAssetsProvisioningStatus();
            updateStatusAsError(AssetId);
            system.debug('Exception #####'+e);
        }   
    }//End of processAssetAutoProvisioningBatch future method
    public static void updateStatusAsError(Id AssetId){
        Asset AssetObj=new Asset();
        AssetObj.Id=AssetId;
        AssetObj.Provision_Status__c = PROVISION_STATUS_ERROR ;
        Update AssetObj;
        
    }
    
    public static void updateAssetsProvisioningStatus(){
        // Logic to update Asset with Provision Status as 'Requested' if successful or 'Error' if failed
        // Start
        list<Asset> updatelstAsset = new list<Asset>();
        system.debug('mapIdWithProvisionStatus================'+mapIdWithProvisionStatus);
        for(Id assId : mapIdWithProvisionStatus.keySet()){
             Asset ass = new Asset(id=assId);
            if(assIdWithSPAParameters.containsKey(assId)){
                ass.SPA_Parameters__c   = assIdWithSPAParameters.get(assId);
            }
            if(mapIdWithProvisionStatus.get(ass.id) =='Success'){
                ass.Provision_Status__c = 'Requested';
            }
            else if(mapIdWithProvisionStatus.get(ass.id) == PROVISION_STATUS_SF_ERROR ){
                ass.Provision_Status__c = PROVISION_STATUS_SF_ERROR;
            }else{
                ass.Provision_Status__c = PROVISION_STATUS_ERROR;
            }
             updatelstAsset.add(ass);
        }//End of FOR loop
        if(!updatelstAsset.isEmpty()){
           AssetTriggerHelper.BypassUpdateRubixSubscriptionsMethod = true;
                update updatelstAsset;   
        }
    }
    //Provision Method  
    public static boolean provision( Opportunity o, Map<String,String> args, Id astId, String attachmentName){
        //args.put('argProdCode', String.valueOf(ol.PricebookEntry.Product2.ProductCode));
        //args.put('argInstanceNumber', ol.Instance_Number__c == null? '': String.valueOf(ol.Instance_Number__c));
        args.put('argAsset', astId);
        args.put('argOppyId', String.valueOf(o.Id));
        system.debug('ast.Id=================provision==================='+astId);
        // Tracking Purpose
        if(args.keySet()!=null){
            for(String thisKey : args.keySet()){            
                System.debug('Before API call method thisKey' + thisKey + ' and value*****'+ args.get(thisKey));
            }       
        }//End of IF
        try{
            boolean ret =  callApi(o,args,astId,attachmentName);
            // reset the sandbox flag, so if there is another subscription prov related line item
            // it doesnt end up creating another sandbox.
            args.put('argSandbox', '0');
            return ret;
        }catch(Exception e){
            
           system.debug('Exception #####'+e);
           return false;
        }
       
    }//End Of provision Method
    
    // use cert to communicate with mmcweb:
    public static final String certName = Label.OAP_certName;
    //public static final String certName = null;
    public static final String endpoint = Label.OAP_endpoint;
    // Token to acces REST service
    public static final String endpoint_token = Label.OAP_endpoint_token;  
    
    //call API Method
    private static boolean callApi(Opportunity o, Map<String, String> args,Id astId, String attachmentName){
      
            boolean SPAFieldValidation = TRUE;
            if(!args.isEmpty()){
                if(AssetMap.containsKey(astId) && AssetMap.get(astId).SBQQ__QuoteLine__r.SBQQ__Quote__r.Rubiks_Quote__c==TRUE && (args.get('subProdEngCodes')==null || args.get('subProdEngCodes')=='')){
                    SPAFieldValidation = FALSE;
                }else if(o.type==Label.OPPORTUNITY_TYPE_RENEWAL && (args.get('argProvisioningType')==null || args.get('argProvisioningType')=='')){
                    SPAFieldValidation = FALSE;
                }else if(args.get('argUserName')==null || args.get('argUserName')==''){
                     SPAFieldValidation = FALSE;   
                }else if(args.get('argFirstName')==null || args.get('argFirstName')==''){
                    SPAFieldValidation = FALSE;   
                }else if(args.get('argLastName')==null || args.get('argLastName')==''){
                     SPAFieldValidation = FALSE;   
                }else if(args.get('argLevel')==null || args.get('argLevel')==''){
                    SPAFieldValidation = FALSE;   
                }else if(args.get('argPurpose')==null || args.get('argPurpose')==''){
                     SPAFieldValidation = FALSE;   
                }else if(args.get('argOppyId')==null || args.get('argOppyId')==''){
                     SPAFieldValidation = FALSE;   
                }else if(args.get('argAsset')==null || args.get('argAsset')==''){
                    SPAFieldValidation = FALSE;   
                }
                /* *************************************************************************
                  Need to perform the data cleanup of Website then mark this field as Mandatory
                  else if(args.get('argHomePage')==null || args.get('argHomePage')==''){
                    SPAFieldValidation = FALSE;   
                  }
                 ************************************************************************** */
            }//End of arg If
            if(SPAFieldValidation && !args.isEmpty()){
            // Set parameters
            Map<String, String> paramsFinal = new Map<String, String>();
            // Tracking Purpose
            If(args.keySet()!=null){
                for(String thisKey : args.keySet()){            
                    System.debug('in API call method thisKey 2222' + thisKey + ' and value*****'+ args.get(thisKey));
                }
            }//End Of If
            
            // Time for the callout
            
            // Catch callout errors
            HTTPRequest req = new HttpRequest();
            
            // Prepare response/request
            HTTPResponse hTTPRes;
            req.setTimeout(120000);
                
            paramsFinal.put('marketo_charonbundle_subposttype[subProdEngCodes]',args.get('subProdEngCodes'));
            System.debug('paramsFinal before adding asset details 2222************'+ paramsFinal);
            
            /* 
               This condition added by Jade on 15th may 2017
               Purpose - If the opportunity type is New Business then Send the sub prod code with Qty to SPA 
            */
            if(o.type == 'New Business'){
                paramsFinal.put('marketo_charonbundle_subposttype[subProdCodeQty]',args.get('subProdCodeQty'));
                System.debug('paramsFinal before adding asset details after subProdCodeQty************'+ paramsFinal);
            }
            
            //Renewal Requirement
            if(o.type=='Renewal'){
                paramsFinal.put('marketo_charonbundle_subposttype[munchkin]', args.get('argMunchkinID'));
            }
            //Renewal Requirement
            paramsFinal.put('marketo_charonbundle_subposttype[provision_type]', args.get('argProvisioningType'));
                
            // Put Asset Details into Final Parameters Map
            paramsFinal.put('marketo_charonbundle_subposttype[token]', AssetAutoProvisioning.endpoint_token);
            paramsFinal.put('marketo_charonbundle_subposttype[name]', args.get('argName'));
            paramsFinal.put('marketo_charonbundle_subposttype[homepage]', args.get('argHomePage'));
            paramsFinal.put('marketo_charonbundle_subposttype[username]', args.get('argUserName'));
            paramsFinal.put('marketo_charonbundle_subposttype[firstname]', args.get('argFirstName'));
            paramsFinal.put('marketo_charonbundle_subposttype[lastname]', args.get('argLastName'));
            paramsFinal.put('marketo_charonbundle_subposttype[level]', args.get('argLevel'));
            paramsFinal.put('marketo_charonbundle_subposttype[purpose]', args.get('argPurpose'));
            paramsFinal.put('marketo_charonbundle_subposttype[sandbox]', args.get('argSandbox'));
            paramsFinal.put('marketo_charonbundle_subposttype[channel_partner]', args.get('argChanelPartner'));
            paramsFinal.put('marketo_charonbundle_subposttype[outlook_seats]', args.get('argOutlookSeats'));
            paramsFinal.put('marketo_charonbundle_subposttype[salesforce_seats]', args.get('argSalesforceSeats'));
            paramsFinal.put('marketo_charonbundle_subposttype[session_token]', args.get('argSessionId'));
            paramsFinal.put('marketo_charonbundle_subposttype[product_code]', args.get('argProdCode'));
            paramsFinal.put('marketo_charonbundle_subposttype[instance_number]', args.get('argInstanceNumber'));
            paramsFinal.put('marketo_charonbundle_subposttype[opp_id]', args.get('argOppyId'));
            paramsFinal.put('marketo_charonbundle_subposttype[asset]', args.get('argAsset'));
                if(o.Type==Label.OPPORTUNITY_TYPE_NEW_BUSINESS){
                    paramsFinal.put('marketo_charonbundle_subposttype[dc]', args.get('dc'));
                }
                system.debug('ast.Id=================CALL API==================='+args.get('argAsset'));
            //Adding 3 new params Subscription Local,Timezone and Lang
            paramsFinal.put('marketo_charonbundle_subposttype[language]', CommonUtils.getLangCode(args.get('argSubLang')));
            //paramsFinal.put('marketo_charonbundle_subposttype[language]', CommonUtils.getLangCode(args.get('argSubLang')));
            paramsFinal.put('marketo_charonbundle_subposttype[locale]', CommonUtils.getLocCode(args.get('argSubLocale')));
            paramsFinal.put('marketo_charonbundle_subposttype[timezone]', CommonUtils.getTzoneCode(args.get('argSubTZone')));
            System.debug ('param list to be posted 222: ' + paramsFinal);
                
            req.setBody(paramStringFromMap(paramsFinal,attachmentName));
                
            if( AssetAutoProvisioning.certName != null) {
                req.setClientCertificateName(AssetAutoProvisioning.certName);
            }

            // Set endpoint
            req.setEndpoint(AssetAutoProvisioning.endpoint);
                        
            // Set method to POST
            req.setMethod('POST');
            
            // Make the 1st-10th callout
            HTTP http = new HTTP();
                                
            // Only process if not testing
            if(system.Test.isRunningTest() == false)
            {                  
                hTTPRes = http.send(req);
                integer status_code = hTTPRes.getStatusCode();  
                system.debug('Status Code-----------'+status_code);                  
                if (status_code == 200){
                    /***CODE IS COMMENTED--APPS-386===
                    sendEmail('Auto-Provisioning Failure', 
                    'Opportunity ' + o.Name + ' (' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + o.Id + 
                    ') successfully called mmcweb\n' + 'payload:\n' + req.getBody().replace('&', '\n'));
                    **/
                    System.debug('Successfull post to mmcweb===>');
                    mapIdWithProvisionStatus.put(astId,'Success');                        
                }else{
                    /***CODE IS COMMENTED--APPS-386===
                    sendEmail('Auto-Provisioning Success', 
                    'Opportunity ' + o.Name + ' (' + URL.getSalesforceBaseUrl().toExternalForm() + '/' + o.Id + 
                    ') successfully called mmcweb\n' + 'payload:\n' + req.getBody().replace('&', '\n'));
                    ***/
                        mapIdWithProvisionStatus.put(astId,PROVISION_STATUS_ERROR);  
                }
            }
            }//End of SPAFieldValidation IF
            else{
                mapIdWithProvisionStatus.put(astId, PROVISION_STATUS_SF_ERROR);  
            }//End of else
        return true;
            
    }//End Of CallApi
        
    // Parse parameters for POST
    private static String paramStringFromMap(Map<String,String> paramst, String attachmentName)
    {
        // Tracking Purpose
        for(String thisKey : paramst.keySet()){            
            System.debug('in API call method thisKey 3333' + thisKey + ' and value*****'+ paramst.get(thisKey));
        }
        
        String returned = '';
        Id assetId = null;
        String assetIdKey = 'marketo_charonbundle_subposttype[asset]';

            for(String key : paramst.keySet())
            {
                if(returned == '')
                {
                    returned = key + '=' + paramst.get(key);
                }
                else 
                {
                    returned =  returned + '&' + key + '=' + paramst.get(key);
                }
                System.debug('processing key 2222: ' + key + ' on Map ' + paramst.get(key));
                
                if(key != null && key == assetIdKey){
                    // Use this assetId in Attachment creation
                    assetId = paramst.get(key);
                }
                //returned += key + '=' + EncodingUtil.urlEncode(paramst.get(key), 'UTF-8');
            }// End of for
        /*
            // Add attachment of this request to Asset record
        
            if(assetId != null){
                Attachment attachment = new Attachment();
                attachment.Body = Blob.valueOf(returned);
                string attachName;
                if(attachmentName.length() >250 )
                    attachName = attachmentName.substring(0,250);
                else if(attachmentName.length()< 250)
                    attachName = attachmentName.substring(0,attachmentName.length());
                System.debug('Attachment Name******' + attachmentName);
                attachment.Name = String.valueOf(attachName + '.txt');
                attachment.ParentId = assetId; 
                insert attachment;
                System.debug('Attachment Inserted on Asset******' + attachment);
                //System.assertEquals(1,2);
            }
        */
        
        if(paramst.containsKey('marketo_charonbundle_subposttype[asset]') ){
            id assetIDForSPA =paramst.get('marketo_charonbundle_subposttype[asset]');
            assIdWithSPAParameters.put(assetIDForSPA, returned);
        }
        System.debug('assIdWithSPAParameters===='+assIdWithSPAParameters);
        System.debug('Final Asset Subscription Provisioning Request**********************' + returned);

        return returned;
       
    } //End Of paramStringFromMap
}