/* Class Name  : AssetTriggerHelper
   Created By  : Abhijeet Baneka (Jade Global Inc)
   Description : This class will handle all the trigger events and give call to helper class for running the approriate logic. 
   Date Created: 06/02/2015
   Last Modified By : Jade Team on 20th May 2017
   Purpose          : Modified class to handle below scenarios- 
                      1. Code Optimization
                      2. Populate Production Asset on Sandbox.
                      3. on Upsell Populate current opportunity as contracts opportunity.
 /****************************************************************
 * Last Modified By   : Rajesh Wani,Jade Global
 * Last Modified Date : 2nd June 2017
 * Changes            : 1. Populate Data Center from related Opportunity
 *                      line 283-287
 * Last modified By : Priyanka Shende, Jade Global Inc on 12th July 2018
 * Purpose          : No dev sandbox for ReminderMedia in SFDC - APPS-14609 
                      If Asset Product Code is PROD-PLAT-DEVSAND-INST then set Asset Purpose as 'Partner Sandbox'
 * ***************************************************************/                      


public class AssetTriggerHelper{
    public static boolean BypassUpdateRubixSubscriptionsMethod =false;
    
    static Set<String> rubixProdCode=new Set<String>(); 
    static Set<String> rubixSandboxCodes=new Set<String>();
   
    static set<String> rubiksPartnerSandboxCodes= new Set<String>();   
      
    
    public static void updateAssetAndContracts(list<Asset> newAsset) {
        if(Trigger.isBefore){
            if(Trigger.isInsert){
              set<id> SubscriptionIds   = new Set<id>();     // Set to store the subscription Ids
              set<id> AccountIds        = new Set<id>();     // Set to store the Account Ids
              list<Asset> newAssetList  = new list<Asset>(); // A List of Asset 
              set<id> quoteLineIds      = new Set<id>();  
              set<id> productIds        = new Set<id>(); 
              Map<String, Schema.SObjectType> sObjectMap = Schema.getGlobalDescribe() ;
              Schema.SObjectType s = sObjectMap.get('Asset') ; // getting Sobject Type
              Schema.DescribeSObjectResult resSchema = s.getDescribe() ;
              Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName(); 
              Id assetCPQInstanceId     = recordTypeInfo.get(system.label.AssetRecordTypeNameCPQInstance).getRecordTypeId();
              Id assetCPQNonInstanceId  = recordTypeInfo.get(system.label.AssetRecordTypeNameCPQNonInstance).getRecordTypeId();
              Id assetOrgAssetId        = recordTypeInfo.get(system.label.AssetRecordTypeNameOriginalAssets).getRecordTypeId();

                for(Asset at: newAsset){

                   // Set updateAssetFlag to a default value False
                   boolean updateAssetFlag = false;
                   
                    if(at.Product_Code__c != null && at.Product_Code__c.toUpperCase().contains('INST')){
                          at.Asset_Type__c ='Instance';
                    }//End of IF block
                     
                    // To check if Current Subscription is present on Asset or not 
                    if(at.SBQQ__CurrentSubscription__c!=null){
                        SubscriptionIds.add(at.SBQQ__CurrentSubscription__c);
                        updateAssetFlag = true;
                    }//End of IF block
                     at.RecordTypeId = assetOrgAssetId;
                    if(at.SBQQ__QuoteLine__c!=Null){
                         quoteLineIds.add(at.SBQQ__QuoteLine__c);
                         updateAssetFlag = true;
                         at.RecordTypeId = assetCPQNonInstanceId;
                         if(at.Asset_Type__c =='Instance'){
                            at.RecordTypeId = assetCPQInstanceId;
                            }//End of IF Block
                        }//End of IF Block
           
                    if(at.Product2id!=null){
                        productIds.add(at.Product2id);
                        updateAssetFlag = true;
                    }//End of IF Block
                    // To check if AccountIds Set has any records or not
                    if(at.Accountid !=null){
                        AccountIds.add(at.AccountId);
                        updateAssetFlag = true;
                    }//End of IF
                  if(updateAssetFlag = true){
                      newAssetList.add(at);
                  }//End of IF block
                  if(at.Account_Name__c!=null && at.Product_Name__c!=null ){
                      at.name = at.Account_Name__c+' '+ at.Product_Name__c;
                      system.debug('######### Asset Name ###########'+at.name);
           	  }//End of IF Block
                  
                  
              }//End of FOR loop
              
              // Call updateAsset Method if the List is Not Empty
              if(!newAssetList.isEmpty()){
                   
                  updateAsset(newAssetList,SubscriptionIds,AccountIds,quoteLineIds,productIds);
              }//End of IF block
              
            }//End of IF

            //*************************************************************
            //Code added by Jade on 16th Feb, 2016
            //This is added to populate the Asset Name as Account Prefix + Purpose of the asset
            //*************************************************************
            else if(Trigger.isUpdate){
                for(Asset ast : newAsset){
                    if(ast.Acct_prefix__c != Null && ast.purpose__c != Null && (ast.Asset_Type__c == 'Instance' || ast.Asset_Type__c == 'Subscription')){
                        String astName = ast.Acct_prefix__c + ' ' + ast.purpose__c;
                        if(ast.Name != astName){
                            ast.Name = astName;
                        }//End of Inner IF
                    }//End of IF
                }//End of FOR
            }//End of Before Update
            
        }//End of Before trigger
        if(Trigger.isAfter){
            if(Trigger.isInsert){
                 map<id,Asset> contractToAssetMap = new map<id,Asset>();
                for(Asset aset : newAsset){
                    // Added by Abhijeet Baneka to remove sandboxes to set as primary asset. DAte : 9 Nov 2015
                    if(aset.Contract__c!=null && aset.Asset_Type__c =='Instance' && aset.Purpose__c !='Sandbox'){  
                        system.debug('###### aset.Contract__c'+aset.Contract__c);
                        
                        //Prepare map to populate production asset on Contract
                        if(aset.Purpose__c!=null && aset.Purpose__c.contains('Production') &&  (aset.Product_Code__c=='PROD-APPS-INST' || !aset.Product_Code__c.contains('RTP')) && aset.Contract__c!=null){
                                contractToAssetMap.put(aset.Contract__c, aset);
                        }//End Of IF Block
                        else if(!contractToAssetMap.containsKey(aset.Contract__c)){    
                            contractToAssetMap.put(aset.Contract__c, aset);
                        }//End of Else If
                        
                    }//End of IF
                }//End of FOR loop
                system.debug('contractToAssetMap============='+contractToAssetMap);
              
                // Call updateContract Method if the List is Not Empty
                if(!contractToAssetMap.isEmpty()){
                    UpdateContract(contractToAssetMap);
                }//End of IF loop
            }//End of After Insert Trigger
        }//End of After Trigger
    }//End of updateAssetAndContracts

    // Method to Query and Update Contract
    Public static void updateAsset(list<Asset> newAsset,set<id> SubscriptionId,set<id> AccIds,set<id> quoteLineIds,set<id> productIds){
        map<id,SBQQ__Subscription__c> subScriptionMap  = new map<id,SBQQ__Subscription__c>();
        map<id,Account>               AccountMap       = new map<id,Account>();
        map<id,SBQQ__QuoteLine__c>    QuoteLineMap     = new map<id,SBQQ__QuoteLine__c>();
        map<id,Product2>              productMap       = new map<id,Product2>();
        set<id>                       contractIds      = new set<id>();
        map<id,contract>              contractMap      = new map<id,contract>();
        Map<String, Schema.SObjectType> sObjectMap = Schema.getGlobalDescribe() ;
        Schema.SObjectType s    = sObjectMap.get('Asset') ; // getting Sobject Type
        Schema.DescribeSObjectResult resSchema = s.getDescribe() ;
        Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName(); 
        Id assetCPQInstanceId                            = recordTypeInfo.get(system.label.AssetRecordTypeNameCPQInstance).getRecordTypeId();
        Id assetCPQNonInstanceId                         = recordTypeInfo.get(system.label.AssetRecordTypeNameCPQNonInstance).getRecordTypeId();
        list<Asset> UpdateOldAsset                       = new list<Asset>();
        list<Asset> UpdateOldAssetList                   = new list<Asset>();
        set<id>               priorOpportunityIds        = new set<id>();
        map<id,Opportunity>    priorOpportunityMap       = new map<id,Opportunity>();
        map<id,id>   contractToPriorOpptyMap             = new map<id,id>();
        // Check if the Subscription set is not null and then Query to retrieve related fields and store in the Subscription map 
                             
                             //set product code
                             for(RubiksProdCode__c rubProdCode :RubiksProdCode__c.getAll().values()){
            if(rubProdCode.Product_Code__c != null){
                rubixProdCode.add(rubProdCode.Product_Code__c);
            }//End of IF Block                
        }//End of For Loop
       
                             //get all rubik sandbox codes from custom setting
                             for(RubiksSandboxCodes__c rubSandboxCode :RubiksSandboxCodes__c.getAll().values()){
            if(rubSandboxCode.Product_Code__c != null){
                rubixSandboxCodes.add(rubSandboxCode.Product_Code__c);
            }//End of IF Block               
        }//End of For Loop
        
        //get all rubik partner sandbox code from custom metadata
        for(Rubiks_Partner_Sandbox_Product_Codes__c partnerSandbox:[SELECT id,Product_Code__c FROM Rubiks_Partner_Sandbox_Product_Codes__c]){
            if(partnerSandbox.Product_Code__c!=null){
                rubiksPartnerSandboxCodes.add(partnerSandbox.Product_Code__c);
            }//End of If
        }//End of for
        
        if(!SubscriptionId.isEmpty()){
            subScriptionMap         = new map<id,SBQQ__Subscription__c>([SELECT id,
                                                                                SBQQ__Contract__c,SBQQ__Product__c,Product_Name__c,SBQQ__Contract__r.SBQQ__Opportunity__r.Migration__c
                                                                         FROM SBQQ__Subscription__c
                                                                         WHERE Id IN : SubscriptionId AND SBQQ__Contract__c!=null
                                                                        ]);
        }//End of IF
      
        // Check if the AccountId set is not null and then Query to retrieve related fields and store in the Account map
        if(!AccIds.isEmpty()){
           AccountMap              = new map<id,Account>([SELECT id,
                                                              (SELECT id,StartDate,EndDate,SBQQ__Opportunity__c,SBQQ__Opportunity__r.Prior_Opportunity__c, SBQQ__RenewalOpportunity__c,SBQQ__Opportunity__r.Migration__c FROM Contracts ORDER BY LastModifiedDate DESC LIMIT 1)
                                                           FROM Account
                                                           WHERE Id IN : AccIds
                                                          ]);
        }//End of IF block
        if(!quoteLineIds.isEmpty()){
                 QuoteLineMap        = new map<id,SBQQ__QuoteLine__c>([SELECT id,SBQQ__Quote__r.Order_Type__c,SBQQ__Quote__r.SBQQ__Opportunity2__c,SBQQ__Quote__r.SBQQ__Opportunity2__r.Data_Center__c FROM SBQQ__QuoteLine__c WHERE Id IN : quoteLineIds]);
       
        }//End of IF block
        if(!productIds.isEmpty()){
                 productMap          = new map<id,Product2>([SELECT id,Product_SubFamily2__c,Family,(SELECT id,SBQQ__OptionalSKU__c,SBQQ__OptionalSKU__r.Productcode,
                                                                                              SBQQ__ConfiguredSKU__c,SBQQ__ConfiguredSKU__r.Productcode 
                                                                                             FROM SBQQ__OptionalFor__r)
                                                              
                                                             FROM Product2
                                                             WHERE Id IN : productIds
                                                          ]);
        }//End of IF block
        for(Asset aset :newAsset){
             if(aset.SBQQ__CurrentSubscription__c!=null && subScriptionMap.containsKey(aset.SBQQ__CurrentSubscription__c)){
                 aset.Contract__c = subScriptionMap.get(aset.SBQQ__CurrentSubscription__c).SBQQ__Contract__c;
             }//End of IF
            
	    else if(aset.AccountId!=null && AccountMap.containsKey(aset.AccountId) ){
                   Account acc      =  AccountMap.get(aset.AccountId);
                    if(!Acc.Contracts.isEmpty()){
                        system.debug('#############Acc'+Acc);
                        Contract con      =  Acc.Contracts[0];
                        aset.Contract__c   =  con.id;
                        //Code Added by Jade on 18th Jan 2017
                        system.debug('###### aset.SBQQ__QuoteLine__c'+aset.SBQQ__QuoteLine__c);
                        //Code modified by jade on 11th May 2017 
                        //Purpose - to populate Contract opportuniy on upsell and renewal assets
                       if(aset.SBQQ__QuoteLine__c!=null && con.SBQQ__Opportunity__c!=null){
                              aset.Opportunity__c          =  con.SBQQ__Opportunity__c;
                              system.debug('###### aset.Opportunity__c    '+aset.Opportunity__c);
                        }//End of IF
                        
                        aset.Latest_Opportunity__c     =  con.SBQQ__RenewalOpportunity__c;
                        
                        //Code Added by jade to set the asset.Provisioning_Type_c = "Migration" and asset.Provision_Status_c = 'New'
                        if(con.SBQQ__Opportunity__r.Migration__c==true ||(aset.SBQQ__CurrentSubscription__c!=null &&subScriptionMap.get(aset.SBQQ__CurrentSubscription__c).SBQQ__Contract__r.SBQQ__Opportunity__r.Migration__c==true ) ){
                            aset.Provisioning_Type__c='Migration';
                            aset.Provision_Status__c  = 'New';
                        }//End of If Block
                                                    
                        contractIds.add(aset.Contract__c);
                         if(con.SBQQ__Opportunity__r.Prior_Opportunity__c!=null){
                            priorOpportunityIds.add(con.SBQQ__Opportunity__r.Prior_Opportunity__c);
                            contractToPriorOpptyMap.put(con.id,con.SBQQ__Opportunity__r.Prior_Opportunity__c);
                        }//End Of If
                    }//End of IF
                   
            }//End of ELSE IF
            if(aset.Product2Id !=null &&  productMap.containsKey(aset.Product2Id)  ){
                product2 product = productMap.get(aset.Product2Id);
                if(product.Product_SubFamily2__c != null){
                    if(product.Product_SubFamily2__c.contains('Sandbox')){
                        aset.Purpose__c ='Sandbox';
                    }//End of IF
                }//End of IF
                if(product.Family!=null &&  aset.Asset_Type__c !='Instance' && (product.Family =='Support' || product.Family =='Education' || product.Family =='Services')){
                    aset.Asset_Type__c ='Service Product';
                  
                    if(product.Family =='Support'){
                        aset.Asset_Type__c ='Support Product';
                    }//End of If
                    else if(product.Family =='Education'){
                       aset.Asset_Type__c ='Education Product';
                    }//End of If
                }//End of IF loop                                               
                
             }//End of IF block of Purpose Sandbox update
            if(aset.Asset_Type__c =='Instance'&& aset.purpose__c != 'Sandbox' && aset.SBQQ__QuoteLine__c!=Null && !QuoteLineMap.isempty() && QuoteLineMap.containsKey(aset.SBQQ__QuoteLine__c)){
                 SBQQ__QuoteLine__c  quote = QuoteLineMap.get(aset.SBQQ__QuoteLine__c);
                 if(quote.SBQQ__Quote__r.Order_Type__c!=null ){
                     aset.purpose__c = 'Production';
                     aset.purpose__c = quote.SBQQ__Quote__r.Order_Type__c.contains('Trial')?'Trail':aset.purpose__c;
                     aset.purpose__c = quote.SBQQ__Quote__r.Order_Type__c.contains('Internal')?'Internal':aset.purpose__c;
                 }
                 if(aset.purpose__c == 'Production'){
                     aset.Supported_Instance__c = true;
                 }
            }//End of IF block
      
            // Last modified By : Priyanka Shende, Jade Global Inc on 12th July 2018
 	    // Purpose          : No dev sandbox for ReminderMedia in SFDC - APPS-14609 
            // If Asset Product Code is PROD-PLAT-DEVSAND-INST then set Asset Purpose as 'Partner Sandbox'
            if(rubixProdCode.contains(aset.Product_Code__c)){
                aset.Purpose__c='Rubiks Production';
            }else if(rubixSandboxCodes.contains(aset.Product_Code__c)){
                aset.Purpose__c='Sandbox';
            }else if(rubiksPartnerSandboxCodes.contains(aset.Product_Code__c)){
                 aset.Purpose__c='Partner Sandbox';
            }//End of IF
             /****************************************************************
             * Last Modified By   : Rajesh Wani,Jade Global
             * Last Modified Date : 2nd June 2017
             * Changes            : 1. Populate Data Center from related Opportunity
             * 
             * ***************************************************************/
            if(aset.Asset_Type__c =='Instance' && aset.SBQQ__QuoteLine__c!=Null && !QuoteLineMap.isempty() && QuoteLineMap.containsKey(aset.SBQQ__QuoteLine__c)){
                  if(QuoteLineMap.get(aset.SBQQ__QuoteLine__c).SBQQ__Quote__r.SBQQ__Opportunity2__r.Data_Center__c!=null){
                     system.debug('##################### Data Center'+QuoteLineMap.get(aset.SBQQ__QuoteLine__c).SBQQ__Quote__r.SBQQ__Opportunity2__r.Data_Center__c);
                     aset.Data_Center__c    = QuoteLineMap.get(aset.SBQQ__QuoteLine__c).SBQQ__Quote__r.SBQQ__Opportunity2__r.Data_Center__c;
                  }//End of IF block of Data_Center__c null check
            }//End of IF block of 
        }//End of FOR loop
   
        
    }//End of Method updateAsset
    
     // Method to  Update Contract  Primary_Asset__c fields
    public static void UpdateContract(map<id,Asset> contractToAssetMap){
        list<Contract> updateContractList = new list<Contract>();
                system.debug('contractToAssetMap================='+contractToAssetMap);
          
        for(Contract con : [SELECT id,SBQQ__Opportunity__c,Primary_Asset__c ,Primary_Asset__r.Purpose__c,Primary_Asset__r.Opportunity__c  FROM Contract WHERE ID IN :contractToAssetMap.keySet() AND  Primary_Asset__c=null]){
             system.debug('contractToAssetMap ##########'+contractToAssetMap.containsKey(con.id));
             system.debug(' con.Primary_Asset__c ##########'+ con.Primary_Asset__c);
             if(contractToAssetMap.containsKey(con.id)){
                    con.Primary_Asset__c = contractToAssetMap.get(con.id).id;
                    updateContractList.add(con);
                 }//End of IF Block
        }//End of FOR loop
        system.debug('updateContractList================='+updateContractList);
        if(!updateContractList.isEmpty()){
             update updateContractList;
        }//End of IF Block
    }//End of method UpdateContract
    
    public static void Asset_BI_BU_AI_AU(list<Asset> newlist,list<Asset> oldlist) {
        if(Trigger.isAfter && (Trigger.isUpdate || Trigger.isInsert)){
            System.debug('<------------------------------->');
           if(NEWCreateAssetsAndEntitlements.allowAccountUpdateonAssetCreation){
               Utility.DO_NOT_UPDATE_ACCOUNT_FROM_OPPTY = false;
                System.debug('<-------------Inside if for true------------------>');
            }
            if(!Utility.DO_NOT_UPDATE_ACCOUNT_FROM_OPPTY) {
               Utility.DO_NOT_UPDATE_ACCOUNT_FROM_OPPTY = true;
               UpdateAssets.updateAccount(newlist);
               System.debug('<-------------Inside Asset Account update------------------>');
               Utility.isAccountUpdatedFromAssetTrigger = true;
            }
            if(!Utility.haveupdatedAssets){           
                UpdateAssets.UpdateRelatedAsset_On_OLI(newlist);            
                UpdateAssets.updateAddOnAssetsNameAndStatus(newlist);  
                Utility.haveupdatedAssets = true;                           
            }         
        }else if (Trigger.isDelete){   
            UpdateAssets.updateAccount(oldlist); 
        }     
    }//End of Asset_BI_BU_AI_AU
    
    
    //** Added By Grazitti Interactive -- To update the UsageData DataBase Size
    // Method to update usagedata database size from Asset

    public static void UpdateUsageDataDataBaseSize(List<Asset> newAssets){
        Map<String, Integer> MunchkinIdMap = new Map<String, Integer>();
        Set<ID> accIDs = new Set<ID>();
        List<JBCXM__UsageData__c> usageList = new List<JBCXM__UsageData__c>();
        
        for(Asset ast : newAssets){
            if(ast.Munchkin_ID__c != Null){
                MunchkinIdMap.put(ast.Munchkin_ID__c,ast.Maximum_Database_Size__c != Null ?ast.Maximum_Database_Size__c.intValue():0);
            }
            if(ast.AccountID != Null){
                accIDs.add(ast.AccountID);
            }
        }
        for(JBCXM__UsageData__c  ju : [SELECT ID, Name, JBCXM__InstanceId__c, DatabaseSize__c FROM JBCXM__UsageData__c WHERE Name =: 'INSTANCELEVEL' AND JBCXM__Account__c != Null AND JBCXM__Account__c IN: accIDs AND JBCXM__InstanceId__c =: MunchkinIdMap.keySet()]){
            
            if(MunchkinIdMap.containsKey(ju.JBCXM__InstanceId__c)){
                ju.DatabaseSize__c = MunchkinIdMap.get(ju.JBCXM__InstanceId__c);
            }
            usageList.add(ju);
        }
        if(!usageList.isEmpty()){
            try{
                update usageList;    
            }
            Catch(Exception e){
                System.Debug('****'+e.getMessage());
            }
        }
    }//End of UpdateUsageDataDataBaseSize

   public static void updateRubixSubscriptions(List<Asset> newAsset){
             
             
      //Prepare set of rubik sandbox codes from custom setting
      
      for(RubiksSandboxCodes__c rubSandboxCode :RubiksSandboxCodes__c.getAll().values()){
         if(rubSandboxCode.Product_Code__c != null){
                rubixSandboxCodes.add(rubSandboxCode.Product_Code__c);
          }//End of IF               
      }//End of For Loop
                                   
      //set of the contractIds
      Set<Id> ContractIds = new Set<Id>();
      
      //map of contract id and its details  
      Map<Id,Contract> ContractIdAndDetailsMap = new Map<Id,Contract>();
      set<id> QuoteIds                    = new set<id>();
      map<id,id> QLIWithRequiredByID      = new map<id,id>();
      map<id,id> asetWithQLIRequiredByID  = new map<id,id>();
    
      
      if(BypassUpdateRubixSubscriptionsMethod==false){

          for(Asset asst:newAsset){
                if(asst.Contract__c!=null && rubixSandboxCodes.contains(asst.Product_Code__c) && asst.Production_Asset__c==null){
                    ContractIds.add(asst.Contract__c);  
                }//End of If Loop
          }//End of For loop
          system.debug('ContractIds #######' + ContractIds);
          if(!ContractIds.isEmpty()){
              for(Contract con :[SELECT id,Primary_Asset__c,SBQQ__Quote__c,SBQQ__Quote__r.Instance_Rollup__c,SBQQ__Quote__r.Rubiks_Quote__c,(SELECT id,SBQQ__QuoteLine__c,Purpose__c,Asset_Type__c,SBQQ__QuoteLine__r.Instance_Number__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__c   FROM Assets__r WHERE  Purpose__c = 'Rubiks Production' AND Product_Code__c='PROD-APPS-INST'  AND SBQQ__QuoteLine__r.SBQQ__RequiredBy__c!=null) FROM Contract WHERE Id IN : ContractIds AND Primary_Asset__c!=null]){
                    ContractIdAndDetailsMap.put(con.id,con);
                 if(con.SBQQ__Quote__c!=null &&  con.SBQQ__Quote__r.Instance_Rollup__c>1 && con.SBQQ__Quote__r.Rubiks_Quote__c==True){
                    QuoteIds.add(con.SBQQ__Quote__c);
                        if(!con.Assets__r.isEmpty() ){
                            for(Asset aset:con.Assets__r){
                                asetWithQLIRequiredByID.put(aset.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,aset.id);
                            }//End of FOR of Asset
                        }//End of IF of Asset Empty check
                   }
              }//End of For Loop
              
            if(!QuoteIds.isEmpty() ){
                for(SBQQ__QuoteLine__c QLI : [SELECT id,SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Bundled__c  =false AND SBQQ__Quote__c IN :QuoteIds ]){
                    QLIWithRequiredByID.put(QLI.id,QLI.SBQQ__RequiredBy__c);
                }//End of FOR of SBQQ__QuoteLine__c
            }//End of IF 
              system.debug('ContractIdAndDetailsMap ########' + ContractIdAndDetailsMap);
              
                  for(Asset asst: newAsset){
                      if( ContractIdAndDetailsMap.containsKey(asst.Contract__c) && (rubixSandboxCodes.contains(asst.Product_Code__c) || rubiksPartnerSandboxCodes.contains(asst.Product_Code__c)) && asst.Production_Asset__c==null){
                        contract cont = ContractIdAndDetailsMap.get(asst.Contract__c); 
                        if(cont.SBQQ__Quote__r.Rubiks_Quote__c==True && (rubixSandboxCodes.contains(asst.Product_Code__c) || rubiksPartnerSandboxCodes.contains(asst.Product_Code__c)) ){
                            if(cont.SBQQ__Quote__r.Instance_Rollup__c==1){
                                asst.Production_Asset__c=cont.Primary_Asset__c;
                            }
                            else if(asst.SBQQ__QuoteLine__c!=null && QLIWithRequiredByID.containsKey(asst.SBQQ__QuoteLine__c)){
                                 id QLIReqById = QLIWithRequiredByID.get(asst.SBQQ__QuoteLine__c);
                                if(asetWithQLIRequiredByID.containsKey(QLIReqById)){
                                    asst.Production_Asset__c = asetWithQLIRequiredByID.get(QLIReqById);
                                    
                                }
                            }
                        }//End of If
                      }//End of IF of asst.Production_Asset__c Null for Sandbox
                  }//End of For Loop of Asset
          }//End of IF block of ContractIds Empty check
      }//End of If Loop
      
    }// end of updateRubixSubscriptions method  
    
    
    // BELOW METHOD POPULATE THE MAXIMUM DATA BASE SIZE FROM THE REALTED PRODUCT RECORD
    public static void PopulateMaxDBOnAsset(List<Asset> newList){
        for(Asset ast : newList){
            if(ast.DB_Size_from_Related_Product__c != null){
                ast.Maximum_Database_Size__c = ast.DB_Size_from_Related_Product__c;
            }//End of If Loop
        }//End of For Loop
    }//End of PopulateMaxDBOnAsset 
    
}//End of Class