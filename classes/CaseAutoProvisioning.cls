/* ********************************************************************************************************************
* Created By    : Priyanka Shende on 5th July 2017, Jade Global Inc.
* Purpose       : Created this class to Send cases to SPA system.
* Last Modified By  : Priyanka Shende on 4th October 2017, jade Global Inc.
* Purpose       : 1. Pick Provision cases by 30 min scheduler
2. If prior opportunity ghost then checks the Account -> Latest Closed won Opportunity (Not Split Ghost and Migration)

* LastModified By : Priyanka Shende on 1st August 2018, Jade Global Inc.
* Purpose         : APPS-20694: Change quantity associated with Life Cycle Modeler

* LastModified By : Priyanka Shende on 1st August 2018, Jade Global Inc.
* Purpose         : APPS-15434: APPS-12258 Adding non SPA products to Custom Setting

* Last Modified By: Jade Global Inc, on 8th September 2018
* Purpose         : To handle Phoenix Provisioning Scenarios
                    Added Phoenix Quote Group Check
* ********************************************************************************************************** */
public class CaseAutoProvisioning {
    public static Map<Id,String> OptyAndMunchkinId                                              = new Map<Id,String>();
    public static Set<Id> PriorOpportunityIds                                                   = new Set<Id>();
    public static Set<Id> OpportunityIds                                                        = new Set<Id>();
    public static Set<Id> CaseSendToSPA                                                         = new Set<Id>();  
    public static String  MunchkinId;
    public static Map<String,double> priorOptyProductCodeQtyMap                                 = new Map<string,double>();
    public static map<String,Product_SKU_Engineering_Code__c>prodCodeToEngCodeCustomSetting     = new Map<String,Product_SKU_Engineering_Code__c>();
    public static final String certName                                                         = Label.OAP_certName;
    public static final String endpoint                                                         = Label.OAP_endpoint;
    public static final String endpoint_token                                                   = Label.OAP_endpoint_token; 
    public static Map<Id,List<Asset>> AccountWithAssetMap                                       = new Map<Id,List<Asset>>();
    public static Set<String> MunchkinIds                                                       = new Set<String>();
    public static Set<String> AccountPrefix                                                     = new Set<String>();
    public static Set<Id> priorOptyContractIds                                                  = new Set<Id>();
    public static map<Id,String> CaseIdWithProvisionStatus                                      = new map<Id,String>(); //To update all Cases with Provision Status
    public static map<id,string> caseIdWithSPAParameters                                        = new map<id,string>();
    public static set<id> AccountIds                                                            = new Set<id>();
    public static Map<id,Case> caseMap                                                          = new Map<id,Case>();
    public Static Map<Id,Boolean> OpportunityWithMDQFlag                                        = new Map<Id,Boolean>();
    public Static Map<Id,Id> OpportunityWithContract                                            = new Map<Id,Id>();
    public Static Map<Id,String> AccountWithPRODPrefix                                          = new Map<Id,String>();
    public Static String PURPOSE_PRODUCTION                                                     = 'Production';
    public Static String PURPOSE_RUBIKS_PRODUCTION                                              = 'Rubiks Production';
    public Static String PROVISION_STATUS_NEW                                                   = 'New';
    Public Static String RECORD_TYPE                                                            = 'Provisioning_Cases_Record_Type';
    public static list<String> EngineeringCodeList= new list<String>();
    
    public static void processCases()
    {
        List<Case> CaseList                             = new List<Case>(); 
        List<Id> CaseIdList                             = new List<Id>();   
        
        //prepare the case list
        CaseList=[SELECT id,subject,Added_Products__c,Segment_Index__c,Quantity_Change_on_Existing_Products__c,Account_String__c,Dropped_Products__c,AccountId,Account.name,Opportunity__c,Opportunity__r.Type,Opportunity__r.Prior_Opportunity__c FROM Case WHERE Provision_Status__c=:PROVISION_STATUS_NEW AND Send_Case_to_SPA__c=true AND RecordType.developername=:RECORD_TYPE order by createdDate desc limit 100];
        
        if(!CaseList.isEmpty()){
            for(Case CSList: CaseList){
                if(CSList.Added_Products__c!=null || CSList.Quantity_Change_on_Existing_Products__c!=null || CSList.Dropped_Products__c!=null ){
                    CaseSendToSPA.add(CSList.id); 
                }//End of If
            }//End of CaseList For
        }//End of If
        system.debug('###################### CaseSendToSPA'+CaseSendToSPA);
        
        //Divide the case list in 10 
        if(!CaseSendToSPA.isEmpty()){
            
            CaseIdList.addAll(CaseSendToSPA);
            final Integer maxRecords = 100; //Total
            final Integer maxBatchSize = 10; //Per batch callout
            
            // Counter
            Integer recordsProcessed = 0;
            // In batches of maxBatchSize, processAutoProvisioning while items remain
            while(recordsProcessed < maxRecords && CaseIdList.size() > 0)
            {
                // Batch id list
                List<Id> batchCaseIds = new List<Id>();
                
                // Batches of maxBatchSize (or less, if less exist)
                Integer batchSize = maxBatchSize;
                
                if(batchSize > (maxRecords - recordsProcessed))
                {
                    batchSize = (maxRecords - recordsProcessed);
                }//End of If
                
                for(Integer j = 0; j < batchSize; j++)
                {
                    if(CaseIdList.size() > 0)
                    {
                        batchCaseIds.add(CaseIdList[0]);
                        CaseIdList.remove(0);
                        recordsProcessed += 1;
                    }
                }//End of batch size For 
                
                if(batchCaseIds.size() > 0)
                {
                    system.debug('batchCaseIds================'+batchCaseIds);               
                    // Send batch to @Future method
                    processCaseAutoProvisioningBatch(batchCaseIds);
                }//End of If
                else
                {
                    break;
                }
            }//End of record processing If
        }//End of Case Id IF
        
    }//End of Process Cases Method
    
    @future(Callout=True)
    public static void processCaseAutoProvisioningBatch(List<Id> CaseIds){
        
        List<Case> CaseList                                     =   new List<Case>();
        //For phoenix Group Count below set is created
        Set<id> ContractQuoteSet                                =   new set<id>();
        //MapOfOpptyAndGroupCount ->Created this Map For Phoenix 
        Map<Id,set<id>> MapOfOpptyAndGroup             =   new Map<Id,set<id>>();
        Map<Id,Decimal> MapOfOpptyAndInstanceRollup             =   new Map<Id,Decimal>();
        Map<String,String> MapOfAcctPrefixtoMuchkin             =   new Map<String,String>();
        Map<Id,list<SBQQ__Subscription__c>> ContractwithSubMap  =   new Map<Id,list<SBQQ__Subscription__c>>();
        List<Case> ProcessCaseList                              =   new list<Case>();                                                    
        Map<String,double> OpportunityWithSegmentIndex          =   new Map<String,double>(); 
        Map<id, string> OptyWithContractAcctPrifix              =   new Map<id, string>();
        
        //Map<string,map<string,string>> OptyWithMunchkin = new Map<string,map<string,string>>();
        map<string,string> assetIdAndMunchkin                   = new map<string,string>();
        map<id,string> assetAndMunchkinID                       = new map<id,string>();
        Set<id> MDQContractIds                                  = new Set<id>();
        //CurrentOptyAndGroupCount ->Created this Map For Phoenix 
        map<id,set<id>> CurrentOptyAndGroup            = new map<id,set<id>>();
        map<id,double> CurrentOptyAndInstanceRollup             = new map<id,double>();
        //Prior Opportunity Ghost- Need to Consider latest closed won New Business or Renewal from Account
        Set<Id> GhostOptyAccountIds                             = new Set<Id>();
        Map<Id,Id> AccountWithPriorOpportunity                  = new Map<Id,Id>();
        
        //Case list - sending to provisioning - Renewal, Upsell and New Business MDQ
        CaseList=[SELECT id,Subscriptions__c,SPA_Parameters__c,subject,Added_Products__c,Segment_Index__c,Added_Dropped_QtyChange__c,Account_String__c,Quantity_Change_on_Existing_Products__c,Dropped_Products__c,AccountId,Account.name,Opportunity__c,Opportunity__r.Type,Opportunity__r.Prior_Opportunity__c,Opportunity__r.SBQQ__AmendedContract__c,Opportunity__r.SBQQ__RenewedContract__c,Opportunity__r.Account_String__c,Opportunity__r.Prior_Opportunity__r.Ghost__c,opportunity__r.SBQQ__RenewedContract__r.SBQQ__Opportunity__c,Opportunity__r.SBQQ__AmendedContract__r.SBQQ__Opportunity__c  FROM Case WHERE id IN:CaseIds AND Provision_Status__c=:PROVISION_STATUS_NEW AND RecordType.developername='Provisioning_Cases_Record_Type' limit 100];
        
        system.debug('############## CaseList'+CaseList);
        
        //Iterate Case
        if(!CaseList.isEmpty()){
            for(Case CSList: CaseList){
                //MDQ New Business sending Case to Provisioning
                //prepare the set of the Current Opportunity Ids         
                if(CSList.Opportunity__c!=null){
                    OpportunityIds.add(CSList.Opportunity__c);
                }
                
                //prepare the set of the Prior Opportunity Ids
                if(CSList.Opportunity__r.Prior_Opportunity__c!=null && (CSList.Segment_Index__c==null || CSList.Segment_Index__c==1)  && CSList.Opportunity__r.Prior_Opportunity__r.Ghost__c==false){
                    //if upsell -> Amended Contract-> Opportunity
                    if(CSList.Opportunity__r.type==label.OPPORTUNITY_TYPE_UPSELL_CROSSELL && CSList.Opportunity__r.SBQQ__AmendedContract__c!=null && CSList.Opportunity__r.SBQQ__AmendedContract__r.SBQQ__Opportunity__c!=null){
                        PriorOpportunityIds.add(CSList.Opportunity__r.SBQQ__AmendedContract__r.SBQQ__Opportunity__c);
                    }
                    //if renewal -> renewed Contract-> Opportunity
                    else if(CSList.Opportunity__r.type==label.OPPORTUNITY_TYPE_RENEWAL && CSList.Opportunity__r.SBQQ__RenewedContract__c!=null && CSList.Opportunity__r.SBQQ__RenewedContract__r.SBQQ__Opportunity__c!=null){
                        PriorOpportunityIds.add(CSList.Opportunity__r.SBQQ__RenewedContract__r.SBQQ__Opportunity__c);
                    }else if(CSList.Opportunity__r.Prior_Opportunity__c!=null){
                        PriorOpportunityIds.add(CSList.Opportunity__r.Prior_Opportunity__c);
                    }
                }//End Of If
                //If Prior Opportunity is Ghost Opportunity then we are taking prior Opportunity from Account(Latest Closed Won Opty - New Business or Renewal)
                else if(CSList.Opportunity__r.Prior_Opportunity__c!=null && CSList.Opportunity__r.Prior_Opportunity__r.Ghost__c==True){
                    GhostOptyAccountIds.add(CSList.AccountId);
                }//End of Else If
                
                system.debug('Prior Opportunity Ids ############'+PriorOpportunityIds);
                //Prepare Account Ids Set
                if(CSList.AccountId!=null){
                    AccountIds.add(CSList.AccountId);
                }//End of If
                double priorSegmentIndex=null;
                //populate the prior segment index based on the case segment index field
                if((CSList.Segment_Index__c!=null || CSList.Segment_Index__c!=1)){
                    String OptyWithSegmentIndex=null;
                    if(CSList.Segment_Index__c > 1){
                        priorSegmentIndex = CSList.Segment_Index__c - 1; 
                        OptyWithSegmentIndex = CSList.Opportunity__c +';'+ priorSegmentIndex;
                    }
                    if(priorSegmentIndex!=null){
                        OpportunityWithSegmentIndex.put(OptyWithSegmentIndex, priorSegmentIndex);
                    }
                }//End of If
                system.debug('########### OpportunityWithSegmentIndex'+OpportunityWithSegmentIndex);
            }//End of CaseList For
            
            // Prepare map of Account with Prior Opportunity
            for(Opportunity Opp :[SELECT id,Name,AccountId,type FROM Opportunity WHERE AccountId IN: GhostOptyAccountIds AND (Type=:Label.OPPORTUNITY_TYPE_NEW_BUSINESS OR Type=:Label.OPPORTUNITY_TYPE_RENEWAL) AND IsWon = TRUE AND Ghost__c=FALSE AND Split_Opportunities__c=null AND Migration__c=FALSE ORDER BY Actual_Close_Date__c desc]){
                if(!AccountWithPriorOpportunity.containsKey(Opp.AccountId)){
                    AccountWithPriorOpportunity.put(Opp.AccountId,Opp.id);
                }//End of If
            }//End of For
            
            //Prepare the set of Prior Opportunity Ids
            if(!AccountWithPriorOpportunity.values().isEmpty()){
                for(Id OptyId: AccountWithPriorOpportunity.values()){
                    PriorOpportunityIds.add(OptyId);
                }//End of For 
            }//End of If
            if(!OpportunityIds.isEmpty() || !PriorOpportunityIds.isEmpty()){
                for(Contract con: [SELECT id,SBQQ__Opportunity__c,SBQQ__Quote__c,SBQQ__Quote__r.MDQ_Quote__c,Primary_Asset__r.Acct_Prefix__c,SBQQ__Quote__r.Instance_Rollup__c,SBQQ__Quote__r.SBQQ__LineItemsGrouped__c From Contract WHERE (SBQQ__Opportunity__c IN : PriorOpportunityIds OR SBQQ__Opportunity__c IN : OpportunityIds)]){
                    
                    // If Opportunity -> Quote is MDQ then used the current opportunity
                    if(OpportunityIds.contains(con.SBQQ__Opportunity__c)){
                        OpportunityWithMDQFlag.put(con.SBQQ__Opportunity__c,con.SBQQ__Quote__r.MDQ_Quote__c);
                        OpportunityWithContract.put(con.SBQQ__Opportunity__c,con.Id);
                        if(con.Primary_Asset__r.Acct_Prefix__c!=null){
                            OptyWithContractAcctPrifix.put(con.SBQQ__Opportunity__c,con.Primary_Asset__r.Acct_Prefix__c);
                        }
                        // This condition is added as part of phoenix
                        if(con.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c==false)
                        CurrentOptyAndInstanceRollup.put(con.SBQQ__Opportunity__c,con.SBQQ__Quote__r.Instance_Rollup__c);
                    }//End of Current Opportunity
                    
                    //If Opportunity -> quote is not MDQ then take Prior Opportunity
                    if(PriorOpportunityIds.contains(con.SBQQ__Opportunity__c)){ 
                        priorOptyContractIds.add(con.id);
                        // This condition is added as part of phoenix
                        if(con.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c==false)
                        MapOfOpptyAndInstanceRollup.put(con.SBQQ__Opportunity__c,con.SBQQ__Quote__r.Instance_Rollup__c);
                    }//end of If
                    // This code added as part of phoenix 
                    if(con.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c){
                     ContractQuoteSet.add(con.SBQQ__Quote__c);
                    }
                    //Current Opportunity and Prior Opportunity check -Used for MDQ
                    if(con.SBQQ__Quote__r.MDQ_Quote__c==true){
                        MDQContractIds.add(con.id);
                    }//End of If
                    system.debug('############# MDQContractIds'+MDQContractIds);
                }//End of Contract For
            }//End of If
            
            // This code added as part of phoenix 
            if(ContractQuoteSet.size()>0){
            for(SBQQ__QuoteLineGroup__c gr: [Select id, Name, SBQQ__Quote__c,SBQQ__Quote__r.SBQQ__Opportunity2__c, SBQQ__Account__c from SBQQ__QuoteLineGroup__c where SBQQ__Quote__c in : ContractQuoteSet]){
                // If Opportunity -> Quote is MDQ then used the current opportunity
                if(OpportunityIds.contains(gr.SBQQ__Quote__r.SBQQ__Opportunity2__c)){
                    if(CurrentOptyAndGroup.containskey(gr.SBQQ__Quote__r.SBQQ__Opportunity2__c)){
                     CurrentOptyAndGroup.get(gr.SBQQ__Quote__r.SBQQ__Opportunity2__c).add(gr.id);
                    }
		    else{
                     CurrentOptyAndGroup.put(gr.SBQQ__Quote__r.SBQQ__Opportunity2__c,new set<id>{gr.id});
                    }
                }
                //If Opportunity -> quote is not MDQ then take Prior Opportunity
                if(PriorOpportunityIds.contains(gr.SBQQ__Quote__r.SBQQ__Opportunity2__c)){
                    if(MapOfOpptyAndGroup.containskey(gr.SBQQ__Quote__r.SBQQ__Opportunity2__c)){
                     MapOfOpptyAndGroup.get(gr.SBQQ__Quote__r.SBQQ__Opportunity2__c).add(gr.id);
                    }
                    else{
                     MapOfOpptyAndGroup.put(gr.SBQQ__Quote__r.SBQQ__Opportunity2__c,new set<id>{gr.id});
                    }
                }
            }
           }
            if(!CaseList.isEmpty()){
                for(Case CSList: CaseList){
                    Boolean OpportunityQuoteMDQFlag =False; 
                    if(OpportunityWithMDQFlag.containsKey(CSList.Opportunity__c)){
                        OpportunityQuoteMDQFlag=OpportunityWithMDQFlag.get(CSList.Opportunity__c);
                    }
                    if(CSList.Added_Products__c!=null || CSList.Quantity_Change_on_Existing_Products__c!=null || CSList.Dropped_Products__c!=null){
                        ProcessCaseList.add(CSList); 
                    }//End of If
                    
                    // Account prefix from account
                    if(CSList.Account_String__c!=null && CSList.Account_String__c.contains(',')){
                        for(String key : CSList.Account_String__c.split(','))
                        {
                            AccountPrefix.add(key.trim());
                        }//End of If
                    }else if(CSList.Account_String__c!=null){
                        AccountPrefix.add(CSList.Account_String__c.trim()); 
                    }//End Of If
                    else if(OpportunityQuoteMDQFlag==true){
                        string acctPrefixForMDQ=null;
                        if(CSList.Opportunity__r.Type==Label.OPPORTUNITY_TYPE_NEW_BUSINESS){
                            if(OptyWithContractAcctPrifix.containsKey(CSList.Opportunity__c)){
                                acctPrefixForMDQ = OptyWithContractAcctPrifix.get(CSList.Opportunity__c);
                            }
                        }//End of If
                        else if(CSList.Opportunity__r.Type==Label.OPPORTUNITY_TYPE_RENEWAL){
                            acctPrefixForMDQ = CSList.Opportunity__r.Account_String__c;
                        }//End of If
                        
                        if(acctPrefixForMDQ!=null){
                            AccountPrefix.add(acctPrefixForMDQ.trim()); 
                        }//End of If
                        
                        system.debug('########## AccountPrefix'+AccountPrefix);
                    }//End of else If
                    
                }//End of For
            }//End of If
            
        }//End of If
        
        //If asset not created for renewal then taking the prefix from asset
        for(Asset ast: [SELECT id,AccountId,Opportunity__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.MKTO_Product_Name__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c,Latest_Opportunity__c,Acct_Prefix__c,Munchkin_ID__c,Status From Asset where Acct_Prefix__c IN:AccountPrefix AND Munchkin_ID__c!=null AND AccountId IN: AccountIds AND Status!='Expired']){
            assetIdAndMunchkin.put(ast.Munchkin_ID__c,ast.id);
            assetAndMunchkinID.put(ast.id,ast.Munchkin_ID__c);
            MapOfAcctPrefixtoMuchkin.put(ast.Acct_Prefix__c,ast.Munchkin_ID__c);
            if(ast.Munchkin_ID__c!=null){
                if(AccountWithAssetMap.containsKey(ast.AccountId)){
                    AccountWithAssetMap.get(ast.AccountId).add(ast);
                }else{
                    AccountWithAssetMap.put(ast.AccountId,new list<Asset>{ast}); 
                }
                
            }//End of if
        }//End of 
        
        //If asset is created for renewal then taking the account prefix from asset history as prefix moved from old to new asset
        map<id,string> oldAssetWithMunckin =new  map<id,string>();
        for(AssetHistory AssetList:[SELECT AssetId,Field,Id,IsDeleted,NewValue,OldValue, Asset.Acct_Prefix__c, Asset.Munchkin_ID__c FROM AssetHistory where Asset.accountid IN : AccountIds]){
            string acctPrefix= String.valueOf(AssetList.OldValue);
            if(!assetIdAndMunchkin.values().isempty()){
                for(string munchkin: assetIdAndMunchkin.keyset()){
                    if(AssetList.OldValue==munchkin){
                        assetIdAndMunchkin.put(munchkin,AssetList.Assetid);
                        oldAssetWithMunckin.put(AssetList.Assetid,munchkin);
                        MapOfAcctPrefixtoMuchkin.put(AssetList.Asset.Acct_Prefix__c,AssetList.Asset.Munchkin_ID__c);
                    }//End of If 
                }//End of For
            }//End of If
        }//End of For Loop
        
        
        // Consider only those OLI for which Product Code lays in Custom Setting - Product SKU Engineering Code(Product_SKU_Engineering_Code__c)   
        for(Product_SKU_Engineering_Code__c skuEngCodeRec :Product_SKU_Engineering_Code__c.getAll().values()){
            if(skuEngCodeRec.Product_Code__c != null && skuEngCodeRec.Engineering_Code__c != null && skuEngCodeRec.No_Need_To_Send_To_SPA__c==False){
                prodCodeToEngCodeCustomSetting.put(skuEngCodeRec.Product_Code__c,skuEngCodeRec);
                EngineeringCodeList.add(skuEngCodeRec.Engineering_Code__c);
            }// End of If               
        }//End of For
        
        List<SBQQ__Subscription__c> singleInstanceSub = new List<SBQQ__Subscription__c>();
        map<string,List<SBQQ__Subscription__c>> MunchkinIdAndSubscription = new map<string,List<SBQQ__Subscription__c>>();
        
        //Prepare Prior Opportunity subscription list
        for(SBQQ__Subscription__c Sub: [SELECT id,SBQQ__Contract__c,Production_Asset__r.Provisioning_Type__c,Production_Asset__r.Acct_Prefix__c,Production_Asset__c,Production_Asset__r.Munchkin_ID__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c,Subscription_Product_Code__c,SBQQ__Product__r.Name,SBQQ__Quantity__c,SBQQ__SegmentQuantity__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.MKTO_Product_Name__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.MDQ_Quote__c,SBQQ__SegmentEndDate__c,SBQQ__Contract__r.EndDate,SBQQ__SegmentIndex__c,SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c FROM SBQQ__Subscription__c WHERE Subscription_Product_Code__c IN :prodCodeToEngCodeCustomSetting.keySet() AND (SBQQ__Contract__c IN:priorOptyContractIds OR SBQQ__Contract__c IN:MDQContractIds)]){
            //Multi-instance scenario
            if(Sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c > 1.0 || (MapOfOpptyAndGroup.containskey(sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c) && MapOfOpptyAndGroup.get(sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c).size()>1)){
                string munchkinAsset;
                if(oldAssetWithMunckin.containsKey(Sub.Production_Asset__c)){
                    munchkinAsset = oldAssetWithMunckin.get(Sub.Production_Asset__c);
                }else if(assetAndMunchkinID.containsKey(Sub.Production_Asset__c)){
                    munchkinAsset = assetAndMunchkinID.get(Sub.Production_Asset__c);
                }//End of MunchkinId Else If
                
                if(MunchkinIdAndSubscription.containsKey(munchkinAsset)){
                    MunchkinIdAndSubscription.get(munchkinAsset).add(sub);
                }else{
                    MunchkinIdAndSubscription.put(munchkinAsset, new list<SBQQ__Subscription__c>{Sub});
                }
            }//End of If
            //Single Instance Scenario
            else{
                double priorSegmentIndex=null;  
                singleInstanceSub.add(Sub);
                string OptyWithSegmentIndex = Sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c + ';'+ Sub.SBQQ__SegmentIndex__c;
                if(OpportunityWithSegmentIndex.containsKey(OptyWithSegmentIndex)){
                    priorSegmentIndex=OpportunityWithSegmentIndex.get(OptyWithSegmentIndex);
                }//End of If
                
                if(ContractwithSubMap.containsKey(Sub.SBQQ__Contract__c)){
                    ContractwithSubMap.get(Sub.SBQQ__Contract__c).add(sub);
                }//End of If
                else{
                    ContractwithSubMap.put(Sub.SBQQ__Contract__c,new list<SBQQ__Subscription__c>{sub});
                }//End of Else
                
            }//End of Else
            system.debug('########## MunchkinIdAndSubscription'+MunchkinIdAndSubscription);
            
        }//End of Subscription For Loop 
        system.debug('#################### ProcessCaseList'+ProcessCaseList);
        
        //Iterate CaseList
        if(!ProcessCaseList.isEmpty()){
            
            for(Case caseObj: ProcessCaseList){
                Set<string> AcctPrefixSet = new Set<string>();
                Set<string> munchkinidSet = new Set<string>();
                
                Boolean OpportunityQuoteMDQFlag =False; 
                if(OpportunityWithMDQFlag.containsKey(caseObj.Opportunity__c)){
                    OpportunityQuoteMDQFlag=OpportunityWithMDQFlag.get(caseObj.Opportunity__c);
                }
                // Account prefix from account
                if(caseObj.Account_String__c!=null && caseObj.Account_String__c.contains(',')){
                    for(String key : caseObj.Account_String__c.split(','))
                    {
                        AcctPrefixSet.add(key.trim());
                    }//End of If
                }else if(caseObj.Account_String__c!=null){
                    AcctPrefixSet.add(caseObj.Account_String__c.trim()); 
                }//End Of If
                //New Business Case Account Prefix requested not populate
                else if(OpportunityQuoteMDQFlag==true){
                    string acctPrefixForMDQ;
                    if(caseObj.Opportunity__r.Type==Label.OPPORTUNITY_TYPE_NEW_BUSINESS){
                        if(OptyWithContractAcctPrifix.containsKey(caseObj.Opportunity__c)){
                            acctPrefixForMDQ = OptyWithContractAcctPrifix.get(caseObj.Opportunity__c);
                        }
                    }
                    else if(caseObj.Opportunity__r.Type==Label.OPPORTUNITY_TYPE_RENEWAL){
                        acctPrefixForMDQ = caseObj.Opportunity__r.Account_String__c;
                    }
                    
                    if(acctPrefixForMDQ!=null){
                        AcctPrefixSet.add(acctPrefixForMDQ.trim()); 
                    }
                    
                }
                
                system.debug('########### AcctPrefixSet'+AcctPrefixSet);
                for(string str : AcctPrefixSet){
                    If(MapOfAcctPrefixtoMuchkin.containsKey(str)){
                        munchkinidSet.add(MapOfAcctPrefixtoMuchkin.get(str));
                    }
                }
                
                system.debug('Munchkin Id ############'+munchkinidSet);
                String ProdEngCode,ProdCodeQty;
                string prodCodeToEngCode,prodCodeToQty;
                
                double InstanceRollup;
                double GroupCount;
                // This logic added as part of Phoenix Provisioning
                if(CurrentOptyAndInstanceRollup.containsKey(caseObj.Opportunity__c)){
                    InstanceRollup = CurrentOptyAndInstanceRollup.get(caseObj.Opportunity__c);
                }
                if(CurrentOptyAndGroup.containsKey(caseObj.Opportunity__c)){
                    GroupCount = CurrentOptyAndGroup.get(caseObj.Opportunity__c).size();
                }
                system.debug('Instance Rollup ############'+InstanceRollup);
                
                
                //Single Instance
                //This condition is added as part of Phoenix Provisioning
                if(munchkinidSet.size() == 1 && (InstanceRollup==1.0|| GroupCount==1.0 || caseObj.Opportunity__r.Type==Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL || OpportunityQuoteMDQFlag==true)){
                    string singelInstanceMunchkin;
                    for (string munchkin : munchkinidSet) {
                        singelInstanceMunchkin=munchkin;
                    }
                    Map<String,SBQQ__Subscription__c> MapPrdctCodeandSub = new Map<String,SBQQ__Subscription__c>();
                    list<SBQQ__Subscription__c> ExistingSubList = new list<SBQQ__Subscription__c> ();
                    
                    id Contractid;
                    if(caseObj.Opportunity__r.type!=Label.OPPORTUNITY_TYPE_NEW_BUSINESS && (caseObj.Segment_Index__c==null || caseObj.Segment_Index__c==1)){
                        contractid=(caseObj.Opportunity__r.SBQQ__AmendedContract__c!=null)?caseObj.Opportunity__r.SBQQ__AmendedContract__c:caseObj.Opportunity__r.SBQQ__RenewedContract__c;
                    }
                    else if(OpportunityWithContract.containsKey(caseObj.Opportunity__c)){
                        contractid=OpportunityWithContract.get(caseObj.Opportunity__c);
                    }
                    if(Contractid!=null && ContractwithSubMap.containskey(Contractid)){
                        ExistingSubList = ContractwithSubMap.get(Contractid);
                    }  
                    ProdEngCode=''; 
                    ProdCodeQty='';
                    
                    //Iterate subscription to handle the Single, Multi instance and MDQ Scenario
                    for(SBQQ__Subscription__c sub: ExistingSubList){
                        If(MapPrdctCodeandSub.containskey(sub.Subscription_Product_Code__c)){
                            // This condition added to handle the MDQ Scenario
                            if((sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.MDQ_Quote__c==false && !OpportunityIds.contains(sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c)) || (sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.MDQ_Quote__c==true && ((caseObj.Segment_Index__c==null || caseObj.Segment_Index__c==1) && !OpportunityIds.contains(sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c) && (sub.SBQQ__SegmentEndDate__c==sub.SBQQ__Contract__r.EndDate || sub.SBQQ__SegmentIndex__c==null)) ||((caseObj.Segment_Index__c!=null || caseObj.Segment_Index__c!=1) && (caseObj.Segment_Index__c!=null && (caseObj.Segment_Index__c-1)==sub.SBQQ__SegmentIndex__c)))){
                                double SubscriptionQuantity = (sub.SBQQ__SegmentQuantity__c==null)? MapPrdctCodeandSub.get(sub.Subscription_Product_Code__c).SBQQ__Quantity__c + sub.SBQQ__Quantity__c: MapPrdctCodeandSub.get(sub.Subscription_Product_Code__c).SBQQ__Quantity__c +sub.SBQQ__SegmentQuantity__c;
                                MapPrdctCodeandSub.get(sub.Subscription_Product_Code__c).SBQQ__Quantity__c = SubscriptionQuantity;
                            }
                        }else{
                            // This condition added to handle the MDQ Scenario
                            if((sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.MDQ_Quote__c==false && !OpportunityIds.contains(sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c)) || (sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.MDQ_Quote__c==true && ((caseObj.Segment_Index__c==null || caseObj.Segment_Index__c==1) && !OpportunityIds.contains(sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c) && (sub.SBQQ__SegmentEndDate__c==sub.SBQQ__Contract__r.EndDate || sub.SBQQ__SegmentIndex__c==null)) ||((caseObj.Segment_Index__c!=null || caseObj.Segment_Index__c!=1) && (caseObj.Segment_Index__c!=null && (caseObj.Segment_Index__c-1)==sub.SBQQ__SegmentIndex__c)))){
                                MapPrdctCodeandSub.put(sub.Subscription_Product_Code__c,sub);
                            }
                        }
                    }
                    
                    //Iterate Subscriptions map
                    for(SBQQ__Subscription__c sub: MapPrdctCodeandSub.values()){
                        double SubscriptionQuantity = sub.SBQQ__SegmentQuantity__c ==null? sub.SBQQ__Quantity__c : sub.SBQQ__SegmentQuantity__c;
                        if(prodCodeToEngCodeCustomSetting.containsKey(sub.Subscription_Product_Code__c)){
                            if(prodCodeToEngCodeCustomSetting.get(sub.Subscription_Product_Code__c).Dont_Consider_Engineering_Code__c==false){
                                if(ProdEngCode=='' && SubscriptionQuantity > 0 ){
                                    ProdEngCode=prodCodeToEngCodeCustomSetting.get(sub.Subscription_Product_Code__c).Engineering_Code__c+':'+SubscriptionQuantity * prodCodeToEngCodeCustomSetting.get(sub.Subscription_Product_Code__c).Quantity_Multiple__c;
                                }
                                else if(SubscriptionQuantity > 0 ){
                                    ProdEngCode=ProdEngCode+','+prodCodeToEngCodeCustomSetting.get(sub.Subscription_Product_Code__c).Engineering_Code__c+':'+SubscriptionQuantity * prodCodeToEngCodeCustomSetting.get(sub.Subscription_Product_Code__c).Quantity_Multiple__c;
                                }
                                
                            }else if(prodCodeToEngCodeCustomSetting.get(sub.Subscription_Product_Code__c).Dont_Consider_Engineering_Code__c==true){
                                if(ProdCodeQty=='' && SubscriptionQuantity > 0 ){
                                    ProdCodeQty=prodCodeToEngCodeCustomSetting.get(sub.Subscription_Product_Code__c).Engineering_Code__c+':'+SubscriptionQuantity*prodCodeToEngCodeCustomSetting.get(sub.Subscription_Product_Code__c).Quantity_Multiple__c;
                                }
                                else if(SubscriptionQuantity > 0 ){
                                    ProdCodeQty=ProdCodeQty+','+prodCodeToEngCodeCustomSetting.get(sub.Subscription_Product_Code__c).Engineering_Code__c+':'+SubscriptionQuantity*prodCodeToEngCodeCustomSetting.get(sub.Subscription_Product_Code__c).Quantity_Multiple__c;
                                }
                            } 
                        }//End of If        
                    }//End of For  
                    
                    Map<String, String> AddedDroppedProduct = new Map<String, String>();
                    if(caseObj.Added_Products__c!=null){
                        AddedDroppedProduct.put('Added Products',caseObj.Added_Products__c);
                    }
                    if(caseObj.Quantity_Change_on_Existing_Products__c!=null){
                        AddedDroppedProduct.put('Quantity Products',caseObj.Quantity_Change_on_Existing_Products__c);
                    }
                    if(caseObj.Dropped_Products__c!=null){
                        AddedDroppedProduct.put('Dropped Products',caseObj.Dropped_Products__c);
                    }
                    
                    Map<String,String> AddedDroppedProductSendToSPA = addedDroppedAndQuantityChangedProducts(AddedDroppedProduct);
                    system.debug('######### AddedDroppedProductSendToSPA'+AddedDroppedProductSendToSPA);
                    string AddedProductSendToSPA,QuantityChangesProductSendTOSPA,DropedProductSendToSPA;
                    if(AddedDroppedProductSendToSPA.containsKey('Added Products')){
                        AddedProductSendToSPA = AddedDroppedProductSendToSPA.get('Added Products');
                    }
                    if(AddedDroppedProductSendToSPA.containsKey('Dropped Products')){
                        DropedProductSendToSPA = AddedDroppedProductSendToSPA.get('Dropped Products');
                    }
                    if(AddedDroppedProductSendToSPA.containsKey('Quantity Products')){
                        QuantityChangesProductSendTOSPA = AddedDroppedProductSendToSPA.get('Quantity Products');
                    }
                    system.debug('############### ProdEngCode'+ProdEngCode);
                    system.debug('############### ProdCodeQty'+ProdCodeQty);
                    Map<String,String> Params=new Map<String,String>();
                    Params.put('argSubProdEngCode',ProdEngCode!=null?ProdEngCode:'');
                    Params.put('argSubProdCodeQty',ProdCodeQty!=null?ProdCodeQty:'');                 
                    Params.put('argAddedProducts',AddedProductSendToSPA!=null?AddedProductSendToSPA:'');
                    Params.put('argQuantityChangedOnExistingProduct',QuantityChangesProductSendTOSPA!=null?QuantityChangesProductSendTOSPA:'');
                    Params.put('argDroppedProducts',DropedProductSendToSPA!=null?DropedProductSendToSPA:'');
                    Params.put('argAccountName',caseObj.Account.name);
                    Params.put('argMunchkinId',singelInstanceMunchkin);
                    Params.put('argProvisioningType',Label.PROVISIONING_TYPE_CHANGE_REQUEST);
                    Params.put('argSFDCCaseID',caseObj.Id);
                    Params.put('argOpportunityID',caseObj.Opportunity__c);
                    Params.put('argToken',CaseAutoProvisioning.endpoint_token);
                    Params.put('argSessionToken',String.valueOf(Crypto.getRandomInteger()));
                    
                    callAPI(Params,caseObj);
                }//End of Single Instance If
                //Multi Instance 
                //This condition is added as part of phoenix 
                else if(munchkinidSet.size() > 1 || InstanceRollup > 1.0 || GroupCount>1){
                    
                    Map<String, map<String,String>> AddedDroppedQtyChangeProduct;
                    if(caseObj.Added_Dropped_QtyChange__c!=null){
                        AddedDroppedQtyChangeProduct = (Map<String,map<String,String>>) JSON.deserialize(caseObj.Added_Dropped_QtyChange__c, Map<String,map<String,String>>.class);   
                    }
                    for(string munchkin : munchkinidSet) {
                        Map<String,SBQQ__Subscription__c> MapofPrdctCodeandSub = new Map<String,SBQQ__Subscription__c>();
                        ProdEngCode ='';
                        ProdCodeQty ='';
                        if(MunchkinIdAndSubscription.containskey(munchkin)){
                            for(SBQQ__Subscription__c sub: MunchkinIdAndSubscription.get(munchkin)){
                                If(MapofPrdctCodeandSub.containskey(sub.Subscription_Product_Code__c)){
                                    MapofPrdctCodeandSub.get(sub.Subscription_Product_Code__c).SBQQ__Quantity__c = MapofPrdctCodeandSub.get(sub.Subscription_Product_Code__c).SBQQ__Quantity__c + sub.SBQQ__Quantity__c;
                                }else{
                                    MapofPrdctCodeandSub.put(sub.Subscription_Product_Code__c,sub);
                                }
                            }
                            
                        }//End of If  
                        list<SBQQ__Subscription__c> ExistingSub = new list<SBQQ__Subscription__c> ();
                        ExistingSub = MapofPrdctCodeandSub.values();
                        
                        //Handle single to multi Instance Scenario
                        //This condition is added as part of phoenix 
                        if((MapOfOpptyAndInstanceRollup.containsKey(CaseObj.Opportunity__r.Prior_Opportunity__c) && MapOfOpptyAndInstanceRollup.get(CaseObj.Opportunity__r.Prior_Opportunity__c) == 1.0) ||(MapOfOpptyAndGroup.containsKey(CaseObj.Opportunity__r.Prior_Opportunity__c) && MapOfOpptyAndGroup.get(CaseObj.Opportunity__r.Prior_Opportunity__c).size() == 1.0 ) && (InstanceRollup > 1 || GroupCount>1)){
                            ExistingSub.clear();
                            ExistingSub= singleInstanceSub;
                        }
                        
                        //Iterate Subscription List to handle multi instance scenario
                        for(SBQQ__Subscription__c sub: ExistingSub){
                            double SubscriptionQuantity = sub.SBQQ__SegmentQuantity__c ==null? sub.SBQQ__Quantity__c : sub.SBQQ__SegmentQuantity__c; 
                            if(prodCodeToEngCodeCustomSetting.get(sub.Subscription_Product_Code__c).Dont_Consider_Engineering_Code__c==false){
                                if(ProdEngCode=='' && sub.SBQQ__Quantity__c > 0){
                                    ProdEngCode=prodCodeToEngCodeCustomSetting.get(sub.Subscription_Product_Code__c).Engineering_Code__c+':'+ SubscriptionQuantity * prodCodeToEngCodeCustomSetting.get(sub.Subscription_Product_Code__c).Quantity_Multiple__c;
                                }
                                else if(sub.SBQQ__Quantity__c > 0){
                                    ProdEngCode=ProdEngCode+','+prodCodeToEngCodeCustomSetting.get(sub.Subscription_Product_Code__c).Engineering_Code__c+':'+ SubscriptionQuantity * prodCodeToEngCodeCustomSetting.get(sub.Subscription_Product_Code__c).Quantity_Multiple__c;
                                }
                                
                            }else if(prodCodeToEngCodeCustomSetting.get(sub.Subscription_Product_Code__c).Dont_Consider_Engineering_Code__c==true){
                                
                                if(ProdCodeQty=='' && sub.SBQQ__Quantity__c > 0){
                                    ProdCodeQty=prodCodeToEngCodeCustomSetting.get(sub.Subscription_Product_Code__c).Engineering_Code__c+':'+ SubscriptionQuantity * prodCodeToEngCodeCustomSetting.get(sub.Subscription_Product_Code__c).Quantity_Multiple__c;
                                }
                                else if(sub.SBQQ__Quantity__c > 0){
                                    ProdCodeQty=ProdCodeQty+','+prodCodeToEngCodeCustomSetting.get(sub.Subscription_Product_Code__c).Engineering_Code__c+':'+ SubscriptionQuantity * prodCodeToEngCodeCustomSetting.get(sub.Subscription_Product_Code__c).Quantity_Multiple__c;
                                }
                            }  
                        }//End of Subscription  
                        
                        
                        String AddedProduct,DropedProduct,QuantityChangesProduct;
                        Map<String, String> AddedDroppedProduct = new Map<String, String>();
                        
                        if(AddedDroppedQtyChangeProduct.containskey(munchkin)){
                            AddedProduct='';
                            if(AddedDroppedQtyChangeProduct.get(munchkin).containskey('Added Products')){
                                AddedProduct=AddedDroppedQtyChangeProduct.get(munchkin).get('Added Products');
                                AddedDroppedProduct.put('Added Products',AddedProduct);
                            }
                            DropedProduct='';
                            if(AddedDroppedQtyChangeProduct.get(munchkin).containskey('Dropped Products')){
                                DropedProduct=AddedDroppedQtyChangeProduct.get(munchkin).get('Dropped Products');
                                AddedDroppedProduct.put('Dropped Products',DropedProduct);
                            }
                            QuantityChangesProduct='';
                            if(AddedDroppedQtyChangeProduct.get(munchkin).containskey('QuantityChangedProduct')){
                                QuantityChangesProduct=AddedDroppedQtyChangeProduct.get(munchkin).get('QuantityChangedProduct');
                                AddedDroppedProduct.put('Quantity Products',QuantityChangesProduct);
                            }
                            
                        }//End of Added,Dropped and Quantity cahanged products
                        
                        Map<string,string> AddedDroppedProductSendToSPA= addedDroppedAndQuantityChangedProducts(AddedDroppedProduct);
                        system.debug('######### AddedDroppedProductSendToSPA'+AddedDroppedProductSendToSPA);
                        string AddedProductSendToSPA,QuantityChangesProductSendTOSPA,DropedProductSendToSPA;
                        if(AddedDroppedProductSendToSPA.containsKey('Added Products')){
                            AddedProductSendToSPA = AddedDroppedProductSendToSPA.get('Added Products');
                        }
                        if(AddedDroppedProductSendToSPA.containsKey('Dropped Products')){
                            DropedProductSendToSPA = AddedDroppedProductSendToSPA.get('Dropped Products');
                        }
                        if(AddedDroppedProductSendToSPA.containsKey('Quantity Products')){
                            QuantityChangesProductSendTOSPA = AddedDroppedProductSendToSPA.get('Quantity Products');
                        }
                        
                        Map<String,String> Params=new Map<String,String>();
                        Params.put('argSubProdEngCode',ProdEngCode!=null?ProdEngCode:'');
                        Params.put('argSubProdCodeQty',ProdCodeQty!=null?ProdCodeQty:'');
                        Params.put('argAddedProducts',AddedProductSendToSPA!=null?AddedProductSendToSPA:'');
                        Params.put('argQuantityChangedOnExistingProduct',QuantityChangesProductSendTOSPA!=null?QuantityChangesProductSendTOSPA:'');
                        Params.put('argDroppedProducts',DropedProductSendToSPA!=null?DropedProductSendToSPA:'');
                        Params.put('argAccountName',caseObj.Account.name);
                        Params.put('argMunchkinId',munchkin);
                        Params.put('argProvisioningType',Label.PROVISIONING_TYPE_CHANGE_REQUEST);
                        Params.put('argSFDCCaseID',caseObj.Id);
                        Params.put('argOpportunityID',caseObj.Opportunity__c);
                        Params.put('argToken',CaseAutoProvisioning.endpoint_token);
                        Params.put('argSessionToken',String.valueOf(Crypto.getRandomInteger()));
                        
                        callAPI(Params,caseObj);
                        System.debug(munchkin);
                    }  
                }//End of Multi Instance
                else if(munchkinidSet.isEmpty()){
                    String status='SF Error';
                    updateCase(caseObj,status);  
                }//End of Else If
            }//End of CaseList For
            //Update Case provision Status
            updateCasesProvisioningStatus();
            
        }//End of isEmpty If
        
    }//End of processCaseAutoProvisioningBatch Class
    
    // LastModified By : Priyanka Shende on 1st August 2018, Jade Global Inc.
    // Purpose         : APPS-15434: APPS-12258 Adding non SPA products to Custom Setting
    public static map<String,String> addedDroppedAndQuantityChangedProducts(map<String,String> addedDroppedQtyChangeProducts){
        
        String Added_Products,Dropped_Products,Quantity_Change_on_Existing_Products;
        
        if(addedDroppedQtyChangeProducts.containsKey('Added Products')){
            Added_Products = addedDroppedQtyChangeProducts.get('Added Products');
        }// End of If
        if(addedDroppedQtyChangeProducts.containsKey('Dropped Products')){
            Dropped_Products = addedDroppedQtyChangeProducts.get('Dropped Products');
        }// End of If
        if(addedDroppedQtyChangeProducts.containsKey('Quantity Products')){
            Quantity_Change_on_Existing_Products = addedDroppedQtyChangeProducts.get('Quantity Products');
        }// End of If
        // Added this logic as per the APPS-20694 - Change quantity associated with Life Cycle Modeler
        List<String> ColonSepratedProduct=new List<String>();
        String AddedProductString='';
        if(Added_Products!=null){
            for(String str: (Added_Products).split(',', 0)){
                system.debug('*****AfterSplitString*****'+str);
                ColonSepratedProduct=str.split(':',2);
                if(EngineeringCodeList.Contains(ColonSepratedProduct[0])){
                    if(AddedProductString==''){                               
                        AddedProductString=ColonSepratedProduct[0]+':'+ColonSepratedProduct[1];
                    }else{                               
                        AddedProductString=AddedProductString+','+ColonSepratedProduct[0]+':'+ColonSepratedProduct[1];
                    }   
                }
            }
        }//End of Added If
        System.debug('***AddedProductstring***'+AddedProductString);
        ColonSepratedProduct.clear();
        String DroppedProductString='';
        if(Dropped_Products!=null){
            for(String str: (Dropped_Products).split(',', 0)){
                ColonSepratedProduct=str.split(':',2);
                if(EngineeringCodeList.Contains(ColonSepratedProduct[0])){
                    if(DroppedProductString==''){                               
                        DroppedProductString=ColonSepratedProduct[0]+':'+ColonSepratedProduct[1];
                    }else{                               
                        DroppedProductString=DroppedProductString+','+ColonSepratedProduct[0]+':'+ColonSepratedProduct[1];
                    }   
                }
            }
        }
        System.debug('***DroppedProductstring***'+DroppedProductString);
        ColonSepratedProduct.clear();
        String QuantityChangedString='';
        if(Quantity_Change_on_Existing_Products!=null){
            for(String str: (Quantity_Change_on_Existing_Products).split(',', 0)){
                ColonSepratedProduct=str.split(':',2);
                if(EngineeringCodeList.Contains(ColonSepratedProduct[0])){
                    if(QuantityChangedString==''){                               
                        QuantityChangedString=ColonSepratedProduct[0]+':'+ColonSepratedProduct[1];
                    }else{                               
                        QuantityChangedString=QuantityChangedString+','+ColonSepratedProduct[0]+':'+ColonSepratedProduct[1];
                    }   
                }
            }
        }//End of Quantity Change If
        map<String,String> addedDroppedProductsSendToSPA = new map<String,String>();
        if(AddedProductString!=null){
            addedDroppedProductsSendToSPA.put('Added Products',AddedProductString);
        }
        if(DroppedProductString!=null){
            addedDroppedProductsSendToSPA.put('Dropped Products',DroppedProductString);
        }
        if(QuantityChangedString!=null){
            addedDroppedProductsSendToSPA.put('Quantity Products',QuantityChangedString);
        }
        
        return addedDroppedProductsSendToSPA;
    }
    
    public static void callAPI(Map<String,String> args,Case caseObj){   
        try{
            // Set parameters
            Map<String, String> paramsFinal = new Map<String, String>();
            system.debug('################# Inside the api call');
            // Put Asset Details into Final Parameters Map
            paramsFinal.put('marketo_charonbundle_subposttype[subProdEngCodes]', args.get('argSubProdEngCode'));
            paramsFinal.put('marketo_charonbundle_subposttype[subProdCodeQty]', args.get('argSubProdCodeQty'));
            paramsFinal.put('marketo_charonbundle_subposttype[added]', args.get('argAddedProducts'));
            paramsFinal.put('marketo_charonbundle_subposttype[qtyChange]', args.get('argQuantityChangedOnExistingProduct'));
            paramsFinal.put('marketo_charonbundle_subposttype[dropped]', args.get('argDroppedProducts'));
            paramsFinal.put('marketo_charonbundle_subposttype[name]', args.get('argAccountName'));
            paramsFinal.put('marketo_charonbundle_subposttype[munchkin]', args.get('argMunchkinId'));
            paramsFinal.put('marketo_charonbundle_subposttype[provision_type]', args.get('argProvisioningType'));
            paramsFinal.put('marketo_charonbundle_subposttype[SFDCCaseID]', args.get('argSFDCCaseID'));
            paramsFinal.put('marketo_charonbundle_subposttype[opp_id]', args.get('argOpportunityID'));
            paramsFinal.put('marketo_charonbundle_subposttype[token]', args.get('argToken'));
            paramsFinal.put('marketo_charonbundle_subposttype[session_token]', args.get('argSessionToken'));
            
            
            caseIdWithSPAParameters.put(caseObj.id,paramStringFromMap(paramsFinal,caseObj));
            caseMap.put(caseObj.id,caseObj);
            
            HTTPRequest req=new HTTPRequest();
            HTTPResponse hTTPRes;
            req.setTimeout(120000);       
            if(certName != null) {
                req.setClientCertificateName(certName);
            }
            req.setEndpoint(endpoint);
            req.setMethod('POST');
            req.SetBody(paramStringFromMap(paramsFinal,caseObj));
            HTTP http = new HTTP();
            hTTPRes = http.send(req);
            integer status_code = hTTPRes.getStatusCode();  
            system.debug('########## status_code'+status_code);
            if(status_code == 200){
                CaseIdWithProvisionStatus.put(caseObj.id,'Success'); 
                //updateCase(caseObj,'Success');
            }else{
                //updateCase(caseObj,Label.Provisioning_Exception_Status);
                CaseIdWithProvisionStatus.put(caseObj.id,Label.Provisioning_Exception_Status); 
                
            }
            system.debug('Status Code='+status_code);
            
        }catch(Exception e){
            system.debug('Exception Found='+e);
        }
    }//End of APICall
    
    private static String paramStringFromMap(Map<String,String> params,Case caseObj){
        String returned = '';
        for(String key : params.keySet())
        {
            if(returned == '')
            {
                returned = key + '=' + params.get(key);
            }
            else 
            {
                returned =  returned + '&' + key + '=' + params.get(key);
            }
        }
        return returned;
    }//End of paramStringFromMap method
    
    public static void updateCase(Case caseObj, String status){
        if(status == 'Success'){
            caseObj.Provision_Status__c='Success';
        }else if(status == 'Error'){
            caseObj.Provision_Status__c='Error';
        }
        else if(status == 'SF Error'){
            caseObj.Provision_Status__c='SF Error';
        }
        try{
            update caseObj;
        }catch(Exception e){
            system.debug('Exception Found');
        }
    }
    
    public static void updateCasesProvisioningStatus(){
        // Logic to update Asset with Provision Status as 'Requested' if successful or 'Error' if failed
        // Start
        list<Case> updatelstCase = new list<Case>();
        
        for(Id CaseId : CaseIdWithProvisionStatus.keySet()){
            Case cs = new Case(id=CaseId);
            if(caseIdWithSPAParameters.containsKey(CaseId)){
                string SPAParameters;
                if(caseMap.containsKey(CaseId)){
                    SPAParameters = caseMap.get(CaseId).SPA_Parameters__c;
                }
                
                if(SPAParameters==null){
                    cs.SPA_Parameters__c = caseIdWithSPAParameters.get(CaseId);
                }else{
                    
                    cs.SPA_Parameters__c= SPAParameters + '\n' + caseIdWithSPAParameters.get(CaseId);
                }
            }
            if(CaseIdWithProvisionStatus.get(cs.id) =='Success'){
                cs.Provision_Status__c = 'Requested';
            }
            else if(CaseIdWithProvisionStatus.get(cs.id) == Label.Provisioning_Exception_Status ){
                cs.Provision_Status__c = Label.Provisioning_Exception_Status;
            }else{
                cs.Provision_Status__c = Label.ProvisionErrorStatus;
            }
            updatelstCase.add(cs);
        }//End of FOR loop
        if(!updatelstCase.isEmpty()){
            update updatelstCase;   
        }
    }
}