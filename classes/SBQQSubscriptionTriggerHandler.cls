/*********************************************************************
* Created by         : Rajesh Wani
* Created Date       : 30th December  2014
* Last Modified By   : Rajesh Wani 2nd January  2015
* Purpose            : This is used as 
                       1. Handler class for Subscription object trigger.    
                       2. To calculate and update the contract rollup fields
                          from Subscription record based on criteria set in custom setting. 
 * Last Modified By  : Jade Team on 3rd May 2017
 * Purpose           : On partner instance populating purpose as 'Rubiks Production'(For this added product code in custom setting)
                       This change impacting on old to new logic, we have revisted the old to new logic, modified SOQL Query 
                       Added order by clause for pick existing asset details and map them to new, production instance asset first
  * Last Modified By : Jade global Inc on 12th May 2017
  * Purpose          : Code Optimization  
  * Last Modified By : Priyanka Shende, Jade Global Inc on 25th May 2017
  * Purpose          :1.  In rubiks to rubiks scenario mark provisioning status as completed
  *                   2. Remove the Sandbox - On Hold(Provisioning Status) Logic
  * Line No          :1484 to 1497 and  1504 to 1517
  
  * Last Modified By : Priyanka Shende, Jade global Inc on 7th June 2017
  * Purpose          : 1. Expired asset not pick in old to new conversion.
  *                    2. Old to New conversion not execute on Upsell Opty Closed Won

  *****************************************************************************************
  * Last Modified By   : Rajesh Wani, Jade global Inc
  * Last Modified Date : 8th June 2017
  * Purpose            : 1.Avoid creating duplicate entitlement on closure of Upsell Opportunity
  *                      2.APPS-12454
  * Change             : 696(Added Type field in SOQL),857-889 lines  * 
  * *****************************************************************************************
  * Last Modified By   : Priyanka Shende, Jade global Inc
  * Last Modified Date : 2nd August 2017
  * Purpose            : 1. If Asset not created for Multi Instance Renewal Opportunity then populate the Production Asset on Subscription from its OLI -> Renewed Subscription -> Production Asset
  * Modified/Added Lines:729,925 to 931
  * 
  * Modified By         : Priyanka Shende, Jade Global Inc
  * Modified Date       : 5th July 2017 
  * Purpose             : 1. When a renewal is closed  Do not create a new entitlement unless there is change in support type. 
  *                       2. If the Support type is same, Update the end date on existing entitlement
  *                       3. If the Support type is same, populate the Current Subscription and asset on existing entitlement
  *                       4. While creating new entitlement, auth contacts need not be carried over.
************************************************************************/
/**********************************************************************************
  * Modified By         : Tushar Misri, Grazitti Interactive
  * Modified Date       : 20th November,2017  - APPS-16908
  * Purpose             : 1. Created New Labels instead of Hardcoded values
              2. Updated the code for the New Entitlement Record Type related to SVC-CONS-DEDUP Product.  
  *                      On Lines Lines 48,70-74,1311 - 1330
  /**********************************************************************************
  * Modified By         : Jade Global ,Inc
  * Modified Date       : 17th February,2018  - APPS-18497
  * Purpose             : 1. Expiring old Emntitlement and moveing Auth Contact ,open cases to New Entitlement during renewal(Exodus,Legacy to Rubiks)
              2. new method MoveAuthorizedContactAndCases at line 1715 -1821  
  *                      On Lines 1459-1464,1509-1514,1703-1706
  *
  * Modified By         : Priyanka Shende, Jade Global Inc, on 13th April 2018
  * Purpose             : If Production Asset not created after closure of the current opportunity then we are populating Production Asset on Subscription from    Prior Contract -> Primary Asset(Current Opportunity -> Renewed Contract -> Primary Asset)
  
  * Modified By         : Priyanka Shende, Jade Global Inc, on 6th June 2018
  * Purpose             : To Handle MDQ Scenario - JIRA - APPS-20524
  ***********************************************************************************
  * Modified By         : Sumit Bhatt, Grazitti Interactive
  * Modified Date       : 16th May,2018 - #APPS 19030#
  * Purpose             : Added the functionality to move the "Assigned Support POC" and "POC Type" From last expired support entitlement entitlement to new support entitlement being made, when there is not an active entitlement with same type existing on the same account.
  * Tracking            : One can track the changes in the code by searching the ticket number in code
  
  * Last Modified By: Jade Global Inc, on 8th September 2018
  * Purpose         : To handle Phoenix Provisioning Scenarios
                    - Handled old to new converion scenario for phoenix provisioning
					- Populate asset on subscription based on Group
  ***********************************************************************************/
public class SBQQSubscriptionTriggerHandler {
    Id SupportRecordTypeId  = Entitlement.sObjectType.getDescribe().getRecordTypeInfosByName().get('Support').getRecordTypeId();
    Id EducationRecordTypeId  = Entitlement.sObjectType.getDescribe().getRecordTypeInfosByName().get('Education').getRecordTypeId() ;
    map<string,id> productCodeToOppProdId = new map<string,id>();
    //Added for APPS-16908 //
    Id EduSubscription  = Entitlement.sObjectType.getDescribe().getRecordTypeInfosByName().get('PS Subscription Service').getRecordTypeId() ;
  
    Map<Id,Id> currentOppPriorOppMap = new Map<Id,Id>();
    Map<Id,Id> contractCurrentOppMap = new Map<Id,Id>();
    Map<Id,List<Asset>> priorOppIdAssetsMap = new Map<Id,List<Asset>>();
    // Variables used while Entitlement creation
    Set<Id> mappedAssetSet = new Set<Id>();
    Map<Id,List<Asset>> contractToAssetsMap = new Map<Id,List<Asset>>();
    Map<String,Decimal> prodCodeToProdQtyMap = new Map<String,Decimal>();
    Set<Id> contractIdsForAssetUpdate = new Set<Id>();
    Map<Id,String> ContractAndProdAssetPurposeMap = new Map<Id,String>();
    public static String RUBIKS_PRODUCTION_PRODUCT_CODE = Label.Rubiks_Production_Product_Code;
    public static String PARTNER_INSTANCE_PRODUCT_CODE  = Label.Partner_Instance_Product_Code;
    public static string UPSELL_CROSSELL_OPPORTUNITY    = Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL;
    public static string ASSET_TYPE                     = Label.Asset_Type;
    public static set<Id>EntitlementIdsForAuthContact   = new set<Id>();
    set<Id> AccountId=new set<Id>();
    List<Entitlement> PriorEntList=new List<Entitlement>();
    Map<Id,Entitlement>MapOfAccToPriorEnt=new Map<Id,Entitlement>();
  Map<Id,Entitlement>MapOfAccToPriorExpiredEnt=new Map<Id,Entitlement>(); //#APPS 19030# created a map to store last expired entitlement for the account.
    //Start - Added for APPS-16908 //
    public static string SUPPORT_RECORDTYPE             = Label.SUPPORT;
    public static string EDUCATION_RECORDTYPE           = Label.EDUCATION;
    public static string EDU_SUBSCRIPTION_RECORDTYPE    = Label.EDU_SUBSCRIPTION;
    //End - Added for APPS-16908 //

    public void SubscriptionTriggerHandler(list<SBQQ__Subscription__c> newSubcription,map<id,SBQQ__Subscription__c> OldSubMap){
       
       //To check Trigger is Before or After       
       if(Trigger.isAfter){
             
             // Start of Insert trigger
            if(Trigger.isInsert){
                   
                set<id> ContractIds = new Set<id>();
                set<id> subscriptionIdsForEntitlement = new Set<id>();
                set<id> accountIds = new set<id>();
                set<Id> subId      = new set<Id>();
                for(SBQQ__Subscription__c sub : newSubcription){
                    //TO check contract is present or not on Subscription
                    subId.add(sub.id);
                    if(sub.SBQQ__Contract__c != NULL){
                        ContractIds.add(sub.SBQQ__Contract__c);
                    }//End of IF loop
                    if(sub.Subscription_Product_Code__c != NULL){
                        subscriptionIdsForEntitlement.add(sub.Id);
                    }//End of IF
                    accountIds.add(sub.SBQQ__Account__c);
                    
                }//End of FOR loop
                
                /***CODE ADDED TO POPULATE PRODUCTS INFO ON ACCOUNT- BY GRAZITTI**/
                if(!accountIds.isEmpty()){
                    SBQQContractAndSubscriptionTriggerHelper.updateAccountRec(accountIds,newSubcription);
                }//End of IF
                
                // Method call --> updateRollUpContractFields to calculate and update the contract roll-up fields.
                if(!ContractIds.isEmpty()){
                    system.debug('isInsert updateRollUpContractFields Called');
                    updateRollUpContractFields(ContractIds);
                }//End of IF
                
        // Method call --> createEntitlements .
                if(!subscriptionIdsForEntitlement.isEmpty()){
                    system.debug('isInsert createEntitlements');
                    createEntitlements(subscriptionIdsForEntitlement,ContractIds);
                }//End of IF
                
                //Modified By : Jade global
                //Purpose     : 1. For Upsell/Crossell opportunity bypass the updateAseet() method
                //              2. Bypass LP Sandbox from production if condition (Added !ContainsKey('Sandbox'))
               
                /* Modified By : Jade Global - Added where clouse on 3rd April 2017
                   Purpose     : Bypass the Update Asset Logic on New business and Upsell Clouser 
                                Old to New Asset conversion is available in UpdateAsset Method.
                */          
               if(!ContractIds.isEmpty()){
                  list <SBQQ__Subscription__c> SubList=[SELECT id,SBQQ__StartDate__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Rubiks_Quote__c,SBQQ__Product__r.productcode,SBQQ__Contract__c,SBQQ__Contract__r.SBQQ__Opportunity__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Opportunity_Type__c from SBQQ__Subscription__c WHERE SBQQ__Contract__c IN : ContractIds]; 
                
                  Boolean notUpsellSubcri = false;
                  for(SBQQ__Subscription__c subScri :SubList){
                      if(subId.contains( subScri.id) && subScri.SBQQ__QuoteLine__r.SBQQ__Quote__r.Opportunity_Type__c!=UPSELL_CROSSELL_OPPORTUNITY){
                         notUpsellSubcri = true;
                      }
                  }
                  
                  if(notUpsellSubcri == TRUE){
                    system.debug('Inside If ######');
                    UpdateAsset(ContractIds);
                  }//End If
                  else{
                      set<Id> QuoteIds=new set<Id>();
                      if(!SubList.isEmpty()){
                        for(SBQQ__Subscription__c sub : SubList){
                          if(sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.Opportunity_Type__c==UPSELL_CROSSELL_OPPORTUNITY && sub.SBQQ__QuoteLine__r.SBQQ__Quote__c!=null){
                              QuoteIds.add(sub.SBQQ__QuoteLine__r.SBQQ__Quote__c);
                          }
                        }
                      }
                      system.debug('######### QuoteIds'+QuoteIds);
                     
                      list<Asset> astList=[SELECT id,accountid,Asset_Type__c,name,Purpose__c,Associated_Bundle__c,SBQQ__CurrentSubscription__c,Contract__c,Contract__r.Primary_Asset__c,Contract__r.Primary_Asset__r.purpose__c,recordtypeid,Product2.ProductCode,status,Acct_Prefix__c,POD__c,Munchkin_ID__c,Opportunity__c,Provision_Status__c,Latest_Opportunity__c FROM Asset WHERE SBQQ__QuoteLine__r.SBQQ__Quote__c IN : QuoteIds];
                      list<Asset> assetListToUpdate=new list<Asset>();
                      if(!astList.isEmpty()){
                          for(Asset ast: astList){
                               for(SBQQ__Subscription__c sub : SubList){
                                  
                                  system.debug('ast.recordtypeid #####'+ast.recordtypeid);
                                  if(((sub.SBQQ__Product__r.productcode).contains('BNDL') && sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.Rubiks_Quote__c == TRUE) || (sub.SBQQ__Product__r.productcode == ast.Associated_Bundle__c && ast.Asset_Type__c == ASSET_TYPE)){
                                       system.debug('############ Inside If');
                                        ast.SBQQ__CurrentSubscription__c = sub.Id;
                                        ast.InstallDate= sub.SBQQ__StartDate__c;
                                        assetListToUpdate.add(ast);
                                        break;
                                  }//End of IF 
                                  system.debug('after if'+assetListToUpdate);
                               }
                          }
                      }
                      system.debug('######### assetListToUpdate'+assetListToUpdate);
                      if(!assetListToUpdate.isEmpty()){
                          update assetListToUpdate;
                      }
                  }//End of else 
                }//End of IF

            }//End of After Insert Trigger
            
            // Start of Update trigger
            else if(Trigger.isUpdate){
                set<id> ContractIds = new Set<id>();
                set<id> subscriptionIdsForEntitlement = new Set<id>();
                set<id> accountIds = new set<id>();
                
                for(SBQQ__Subscription__c sub : newSubcription){

                    //To check if contract or Quantity is changed or not.
                    if(( sub.SBQQ__Contract__c!= OldSubMap.get(sub.id).SBQQ__Contract__c) || ( sub.SBQQ__Quantity__c != OldSubMap.get(sub.id).SBQQ__Quantity__c)||(sub.Subscription_MCV__c != OldSubMap.get(sub.id).Subscription_MCV__c)){
                         
                        if(sub.SBQQ__Contract__c==null &&  OldSubMap.get(sub.id).SBQQ__Contract__c!=null){
                            ContractIds.add(OldSubMap.get(sub.id).SBQQ__Contract__c);
                        }//End of IF
                        if(sub.SBQQ__Contract__c!=null){
                            ContractIds.add(sub.SBQQ__Contract__c);
                        }//End of IF
                    }//End of IF loop
                    if(sub.SBQQ__TerminatedDate__c!=null && sub.SBQQ__TerminatedDate__c !=OldSubMap.get(sub.id).SBQQ__TerminatedDate__c ){
                         subscriptionIdsForEntitlement.add(sub.Id);
                    }//End of IF
                    
                    //if(sub.SBQQ__Product__c != null && sub.SBQQ__Product__c!= OldSubMap.get(sub.id).SBQQ__Product__c){
                        accountIds.add(sub.SBQQ__Account__c);
                    //}
                    
                }//End of FOR loop
                
                /***CODE ADDED TO POPULATE PRODUCTS INFO ON ACCOUNT- BY GRAZITTI**/
                if(!accountIds.isEmpty()){
                    SBQQContractAndSubscriptionTriggerHelper.updateAccountRec(accountIds,newSubcription);
                }//End of IF
                
                // Method call --> updateRollUpContractFields to calculate and update the contract rollup fields.
                if(!ContractIds.isEmpty()){
                    system.debug('isUpdate updateRollUpContractFields Called');
                    updateRollUpContractFields(ContractIds);
                }//End of IF
                // Method call --> UpdateEntitlement to update the end date of Entitlement.
                if(!subscriptionIdsForEntitlement.isEmpty()){
                    system.debug('Update createEntitlements');
                    UpdateEntitlement(subscriptionIdsForEntitlement);
                }//End of IF loop
                 
            }//End of After Update Trigger
            //Start of Delete trigger
            else if(Trigger.isDelete){
                set<id> ContractIds = new Set<id>();
                set<id> accountIds = new set<id>();
                
                for(SBQQ__Subscription__c sub : OldSubMap.values()){
                    
                     accountIds.add(sub.SBQQ__Account__c);//POPULATE PRODUCT INFO ON ACCOUNT
                     //TO check contract is present or not on Subscription
                    if(sub.SBQQ__Contract__c != NULL){
                        ContractIds.add(sub.SBQQ__Contract__c);
                    }//End of IF loop
                    
                }//End of FOR loop
                
                // Method call --> updateRollUpContractFields to calculate and update the contract rollup fields.
                if(!ContractIds.isEmpty()){
                    updateRollUpContractFields(ContractIds);
                }//End of IF
                
                 /***CODE ADDED TO POPULATE PRODUCTS INFO ON ACCOUNT- BY GRAZITTI**/
                if(!accountIds.isEmpty()){
                    SBQQContractAndSubscriptionTriggerHelper.updateAccountRec(accountIds,newSubcription);
                }//End of IF
                
            }//End of After Delete Trigger.
        }//End of After Trigger
        
    //Start of BEFORE EVENT 
    else if(Trigger.isBefore){
         if(Trigger.isInsert){
          set<id> ContractIds               = new Set<id>();
          list<SBQQ__Subscription__c> newSubscriptionList  = new list<SBQQ__Subscription__c>(); 
          for(SBQQ__Subscription__c sub : newSubcription){

            //TO check contract is present or not on Subscription
            if(sub.SBQQ__Contract__c != NULL){
              ContractIds.add(sub.SBQQ__Contract__c);
              newSubscriptionList.add(sub);
            }//End of IF loop
          }//End of FOR loop
                     
                     // Call to method =>updateSubscriptionRecord to update the new Subscription
                     if(!ContractIds.isEmpty() && !newSubscriptionList.isEmpty()){
                         updateSubscriptionRecord(newSubscriptionList,ContractIds);
                     }
         }//End of Before insert trigger

         if(Trigger.isUpdate){
            
            String contractid='';
            Map<String,String> ql_to_sub=new Map<String,String>();
            for(SBQQ__Subscription__c sub : newSubcription){
                contractid=sub.SBQQ__Contract__c;
                ql_to_sub.put(sub.SBQQ__QuoteLine__c, sub.id);
            }//End of FOR

            //Create a Map of Most Recent Support SKU
            String support_prefix='SUP-BASE%';
            Map<String,String> support_map=new Map<String,String>();
            Set<ID> old_support=new Set<ID>();
            list<SBQQ__Subscription__c> newSubSupportList=new list<SBQQ__Subscription__c>([Select id, Subscription_Product_Code__c, SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__c, SBQQ__Quantity__c from SBQQ__Subscription__c where SBQQ__Contract__c=:contractid and Subscription_Product_Code__c LIKE :support_prefix Order BY CreatedDate DESC]);

            system.debug(newSubSupportList);
            


            for(SBQQ__Subscription__c sub:newSubSupportList){
                String code_requiredby='';
                if(sub.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__c==NULL){
                        code_requiredby=sub.Subscription_Product_Code__c + ql_to_sub.get(sub.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c);
                    }else{
                        code_requiredby=sub.Subscription_Product_Code__c + sub.SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__UpgradedSubscription__c;
                    }//End of IF-ELSE
                
                system.debug(code_requiredby);
                if(!support_map.containsKey(code_requiredby)){
                    support_map.put(code_requiredby,sub.id);
                }else{
                    old_support.add(sub.id);
                }//End of IF-ELSE
            }//End of FOR

            system.debug(support_map);

            for(SBQQ__Subscription__c sub : newSubcription){
                if(old_support.contains(sub.id)){
                    sub.SBQQ__Quantity__c=0;
                }//End of IF
            }//End of FOR

        }//End of Before Update
    }//End of Before trigger
    }//End of Method SubscriptionTriggerHandler
  
  //This method id used to update the Subscription__c record
    public void updateSubscriptionRecord(list<SBQQ__Subscription__c> newSubscriptionList,set<id> ContractIds){
        map<id,Contract> ContractMap = new map<id,Contract>([SELECT id ,name , SBQQ__Quote__r.Renewal_Uplift_pct__c,account.Partner_Type__c,SBQQ__Quote__r.Order_Type__c,Primary_Asset__c,SBQQ__Quote__r.Rubiks_Quote__c,SBQQ__Quote__r.Instance_Rollup__c,CreatedDate,ContractNumber,SBQQ__Opportunity__r.SBQQ__RenewedContract__r.Primary_Asset__c,SBQQ__Opportunity__r.SBQQ__RenewedContract__c,SBQQ__Opportunity__c,SBQQ__Quote__r.SBQQ__LineItemsGrouped__c,(SELECT id,SBQQ__QuoteLine__c,Purpose__c,Asset_Type__c,SBQQ__QuoteLine__r.Instance_Number__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,SBQQ__QuoteLine__r.SBQQ__Group__c   FROM Assets__r WHERE  Purpose__c = 'Rubiks Production' AND Product_Code__c='PROD-APPS-INST'  AND SBQQ__QuoteLine__r.SBQQ__RequiredBy__c!=null) FROM Contract WHERE Id IN :ContractIds]);
        //Map of product code and its related custom setting record
        map<string,list<Entitlement_Product_Code_Criteria__c>> productCodesMap = new  map<string,list<Entitlement_Product_Code_Criteria__c>>();
        
        set<id> QuoteIds                    = new set<id>();
        map<id,id> QLIWithRequiredByID      = new map<id,id>();
        map<id,id> QLIWithGroupID           = new map<id,id>();
        map<id,id> asetWithQLIRequiredByID  = new map<id,id>();
        map<id,id> asetWithQLIGroupID  = new map<id,id>();
        for(Contract cont: ContractMap.values()){
            if(cont.SBQQ__Quote__c!=null &&  (cont.SBQQ__Quote__r.Instance_Rollup__c>1 ||cont.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c==true)){
                QuoteIds.add(cont.SBQQ__Quote__c);
                if(!cont.Assets__r.isEmpty() ){
                    for(Asset aset:cont.Assets__r){
                        asetWithQLIRequiredByID.put(aset.SBQQ__QuoteLine__r.SBQQ__RequiredBy__c,aset.id);
                        if(aset.SBQQ__QuoteLine__r.SBQQ__Group__c!=null){
                            asetWithQLIGroupID.put(aset.SBQQ__QuoteLine__r.SBQQ__Group__c,aset.id);
                        }
                    }//End of FOR of Asset
                }//End of IF of Asset Empty check
            }
        }//End of FOR of Contract
        
        Map<Id,Id> QLIWithRenewedSubscriptionAsset =  new  Map<Id,Id>();
        Map<Id,Id> QLIWithRequiredBy               =  new  Map<Id,Id>();
        if(!QuoteIds.isEmpty()){
            for(SBQQ__QuoteLine__c QLI : [SELECT id,SBQQ__RequiredBy__c,SBQQ__RenewedSubscription__r.Production_Asset__c,SBQQ__Quote__r.Instance_Rollup__c,SBQQ__Group__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Bundled__c  =false AND SBQQ__Quote__c IN :QuoteIds ]){
                if(!asetWithQLIRequiredByID.isEmpty()){
                    QLIWithRequiredByID.put(QLI.id,QLI.SBQQ__RequiredBy__c);
                }//End of If
                if(!asetWithQLIGroupID.isEmpty() && QLI.SBQQ__Group__c!=null){
                    QLIWithGroupID.put(QLI.id,QLI.SBQQ__Group__c);
                }
                QLIWithRequiredBy.put(QLI.id,QLI.SBQQ__RequiredBy__c);
                
                if(QLI.SBQQ__RenewedSubscription__r.Production_Asset__c!=null){
                    QLIWithRenewedSubscriptionAsset.put(QLI.SBQQ__RequiredBy__c,QLI.SBQQ__RenewedSubscription__r.Production_Asset__c);
                }//End of If
            }//End of FOR of SBQQ__QuoteLine__c
        }//End of IF 
        
        //To get all custom setting records
        for(Entitlement_Product_Code_Criteria__c conProduct :Entitlement_Product_Code_Criteria__c.getAll().values()){
            if(conProduct.Product_Code__c != null ){ 
                if(productCodesMap.containsKey(conProduct.Product_Code__c)){
                    productCodesMap.get(conProduct.Product_Code__c).add(conProduct);
                }//End of IF
                else{
                    productCodesMap.put(conProduct.Product_Code__c,new list<Entitlement_Product_Code_Criteria__c>{conProduct});
                }//End of ELSE
            }//End of IF
        }//End of FOR
        for(SBQQ__Subscription__c sub : newSubscriptionList){
            //TO check contract is present or not on Subscription
            if(!ContractMap.isEmpty() && sub.SBQQ__Contract__c != NULL && ContractMap.containskey(sub.SBQQ__Contract__c)){
                Contract contra = ContractMap.get(sub.SBQQ__Contract__c);
                if(contra.SBQQ__Quote__r.Renewal_Uplift_pct__c!=null){
                    sub.SBQQ__RenewalUpliftRate__c = double.valueOf(contra.SBQQ__Quote__r.Renewal_Uplift_pct__c);
                }
                
               /*************************/
                //Added by Jade on 27th March 2017 on 2nd may 2017
                //Reference: APPS-12553 && APPS-12526
                // Production Asset population logic modified by Jade Team on 17th May 2017 to Handle Multi Instance scenario
                if(contra.SBQQ__Quote__r.Rubiks_Quote__c == TRUE && contra.SBQQ__Quote__r.Instance_Rollup__c ==1 && contra.Primary_Asset__c != null && !(sub.SBQQ__ProductName__c.contains('Bundle'))){
          // If Production Asset not created after closure of the current opportunity then we are populating Production Asset on Subscription from Prior Contract -> Primary Asset(Current Opportunity -> Renewed Contract -> Primary Asset)
                    // Modified By : Jade Global Inc, on 12th April 2018, Reference - APPS-18898
           Id ProductionAsset;
                   if(contra.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c==false){
                        if(ContractMap.get(sub.SBQQ__Contract__c).Primary_Asset__c != null){
                            ProductionAsset = ContractMap.get(sub.SBQQ__Contract__c).Primary_Asset__c;
                        }else if(contra.SBQQ__Opportunity__r.SBQQ__RenewedContract__c!=null && contra.SBQQ__Opportunity__r.SBQQ__RenewedContract__r.Primary_Asset__c!=null){
                            ProductionAsset = contra.SBQQ__Opportunity__r.SBQQ__RenewedContract__r.Primary_Asset__c;    
                        }
                        sub.Production_Asset__c = ProductionAsset;
                   }
                 
                    system.debug('######sub.Production_Asset__c ############'+sub.Production_Asset__c);
                }//End of IF
                else if(contra.SBQQ__Quote__r.Rubiks_Quote__c == TRUE && !contra.Assets__r.isEmpty() && !(sub.SBQQ__ProductName__c.contains('Bundle')) && !asetWithQLIRequiredByID.isEmpty() && !QLIWithRequiredByID.isEmpty() && contra.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c==false){
                       
                         if(sub.SBQQ__QuoteLine__c!=null && QLIWithRequiredByID.containsKey(sub.SBQQ__QuoteLine__c) ){
                            id QLIReqById = QLIWithRequiredByID.get(sub.SBQQ__QuoteLine__c);
                            if(asetWithQLIRequiredByID.containsKey(QLIReqById)){
                                sub.Production_Asset__c = asetWithQLIRequiredByID.get(QLIReqById);
                                
                            }
                         }
                       
                }//End of ELSE IF for Production_Asset__c 
                /* *****************************************************************************************
                 * Last Modified By   : Priyanka Shende, Jade global Inc
                 * Last Modified Date : 2nd August 2017
                 * Purpose            : 1. If Asset not created for Multi Instance Renewal Opportunity then populate the Production Asset on Subscription from its OLI -> Renewed Subscription -> Production Asset
                 ***************************************************************************************** */
                else if(contra.SBQQ__Quote__r.Rubiks_Quote__c == TRUE && !(sub.SBQQ__ProductName__c.contains('Bundle')) &&  QLIWithRequiredBy.containsKey(sub.SBQQ__QuoteLine__c) && contra.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c==false){
                     id QLIReqById = QLIWithRequiredBy.get(sub.SBQQ__QuoteLine__c);
                     if(QLIWithRenewedSubscriptionAsset.containsKey(QLIReqById)){
                        sub.Production_Asset__c = QLIWithRenewedSubscriptionAsset.get(QLIReqById);
                     }
                     system.debug('sub.Production_Asset__c ############'+sub.Production_Asset__c);
                }//End of If
                
               if(contra.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c==true && !QLIWithGroupID.isEmpty() && QLIWithGroupID.containsKey(sub.SBQQ__QuoteLine__c)){
                     sub.Production_Asset__c =contra.Primary_Asset__c!=null?contra.Primary_Asset__c:sub.Production_Asset__c;
                     id QuoteGroupById = QLIWithGroupID.get(sub.SBQQ__QuoteLine__c);
                     if(asetWithQLIGroupID.containsKey(QuoteGroupById)){
                          sub.Production_Asset__c =asetWithQLIGroupID.get(QuoteGroupById);
                     }
               }
            }//End of IF loop
             sub.Auth_Contacts_from_Custom_Setting__c =0;
             
               if(productCodesMap.containsKey(sub.Subscription_Product_Code__c) && !ContractMap.isEmpty() && sub.SBQQ__Contract__c!=null && ContractMap.containsKey(sub.SBQQ__Contract__c)){
                   for(Entitlement_Product_Code_Criteria__c conProduct :productCodesMap.get(sub.Subscription_Product_Code__c)){

                       Contract contrct=   ContractMap.get(sub.SBQQ__Contract__c);
                       if( conProduct.Account_Partner_Type__c!=null && contrct.Account.Partner_Type__c!=null && conProduct.Order_Type__c!=null && contrct.Account.Partner_Type__c.contains(conProduct.Account_Partner_Type__c) && contrct.SBQQ__Quote__r.Order_Type__c==conProduct.Order_Type__c){
                           sub.Auth_Contacts_from_Custom_Setting__c =conProduct.Num_of_Allowed_Auth_Contacts__c;
                       System.debug('1st Loop SUB ==========' +sub);
                           System.debug('1st Loop conProduct ==========' +conProduct);
                           break;
                    }//End of IF
                       else if ( conProduct.Account_Partner_Type__c==null && conProduct.Order_Type__c!=null && contrct.SBQQ__Quote__r.Order_Type__c==conProduct.Order_Type__c){
                           sub.Auth_Contacts_from_Custom_Setting__c =conProduct.Num_of_Allowed_Auth_Contacts__c;
                           System.debug('2nd Loop SUB ==========' +sub);
                           System.debug('2nd Loop conProduct ==========' +conProduct);
                    }//End of else if
                }//End of FOR

                }//End of IF Block  
            
        }//End of FOR loop
      
    }//End of Method => updateSubscriptionRecord()
    /**************************************************
     *  This method calls from subscription Trigger handler
     *  Parameter : Sett of Contract ids 
     *  Purpose   : To roll up all contract fields store in custom setting grouping up by Contract
     *            
     * *************************************************/
    public void updateRollUpContractFields(set<id> ContractIds){
        //This is used to update Contract list
        list<Contract> updateContractList  = new  list<Contract>();
        //This map is used to get contract.
        map<id,Contract> contractMap       = new  map<id,Contract>();
       // This map is used to group the subscription by contract ids
        map<id,list<SBQQ__Subscription__c>> contractWithSubMap  = new   map<id,list<SBQQ__Subscription__c>>();
        //List of all records store in custom setting Contract_Roll_Up_With_Product_Code__c
        list<Contract_Roll_Up_With_Product_Code__c> ContractCodeList = new list<Contract_Roll_Up_With_Product_Code__c>();
        //Map of product code and its related custom setting record where Need_To_Check_Criteria__c = True
        map<string,Contract_Roll_Up_With_Product_Code__c> productCodesMap = new  map<string,Contract_Roll_Up_With_Product_Code__c>();
        //Map of subscription field  and its related custom setting record where Need_To_Check_Criteria__c = false
        map<string,list<Contract_Roll_Up_With_Product_Code__c>> subFieldMap = new  map<string,list<Contract_Roll_Up_With_Product_Code__c>>();
        list<Contract_Roll_Up_With_Product_Code__c> NoCriteriaContractRollUp = new list<Contract_Roll_Up_With_Product_Code__c>();
        
        Set<Id> QualifiedCustomSettingRecords = new Set<Id>();
        
        // Get Additional Authorized Contact Product Code from Label
        string AddAuthContactCode = Label.Additional_Support_Product_Code_Of_subscription;
        // This map is used to group the Additional Contact subscription by contract ids
        map<id,list<SBQQ__Subscription__c>> contractWithAddContactSubMap  = new   map<id,list<SBQQ__Subscription__c>>();
        
         //To get all custom setting record
        for(Contract_Roll_Up_With_Product_Code__c conProduct :Contract_Roll_Up_With_Product_Code__c.getAll().values()){
            if(conProduct.Product_Code__c != null && conProduct.Need_To_Check_Criteria__c){
                // To check if Product_Code__c contain more than 1 code seperated by " , "
                if(conProduct.Product_Code__c.contains(',')){
                    // TO get all codes by splitting the Product_Code__c
                    list<string> codLst = conProduct.Product_Code__c.split(',');
                   
                    for(String code :codLst){
                         code=code.trim();
                         productCodesMap.put(code,conProduct);
                    }//End of FOR loop
                    
                }//End of IF loop
                else {
                  productCodesMap.put(conProduct.Product_Code__c.trim(),conProduct);
                }//End of ELSE loop
                ContractCodeList.add(conProduct);
            }//End of IF loop of Product_Code__c code null check
            else if(conProduct.Subscription_Field__c !=null  && conProduct.Need_To_Check_Criteria__c== false){
                if(subFieldMap.containskey(conProduct.Subscription_Field__c.trim())){
                 subFieldMap.get(conProduct.Subscription_Field__c.trim()).add(conProduct);
                }//End of IF
                else{
                    subFieldMap.put(conProduct.Subscription_Field__c.trim(),new list<Contract_Roll_Up_With_Product_Code__c>{conProduct});
                }//End of Else
                NoCriteriaContractRollUp.add(conProduct);
                ContractCodeList.add(conProduct);
            }//End of else if
        }//End of FOR loop
        system.debug('subFieldMap=========='+subFieldMap);
        //This FOR loop is used to initialize the Contract roll-up fields to 0.
        for(id conid : ContractIds){
            Contract con = new Contract(id= conid);
            for(Contract_Roll_Up_With_Product_Code__c conProduct : ContractCodeList){
                if(conProduct.Fieldname__c!=null){
                    con.put(conProduct.Fieldname__c,0);
                }//End of IF
            }//End of FOR
            contractMap.put(con.id,con);

            
        }//End of FOR loop
         system.debug('contractMap=========='+contractMap);
        try{
            //Get subscription records related to contracts with product codes stored in Custom setting
            list<SBQQ__Subscription__c> SucbcriptionList = [SELECT id,name,
                                                                   SBQQ__Quantity__c,
                                                                   SBQQ__Contract__c,
                                                                   Subscription_Product_Code__c,
                                                                   SBQQ__Product__r.Included_Marketing_Users__c,
                                                                   Subscription_MCV__c,
                                                                   Subscription_ACV__c,
                                                                   Include_in_Maintenance__c,
                                                                   of_Allowed_Authorized_Contacts__c,
                                                                   SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Type,
                                                                   SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName,
                                                                   SBQQ__Contract__r.SBQQ__Opportunity__r.SBQQ__RenewedContract__r.Primary_Asset__c,
                                                                   SBQQ__Contract__r.Primary_Asset__c
                                                            FROM   SBQQ__Subscription__c
                                                            WHERE  SBQQ__Contract__c IN: ContractIds
                                                            AND    (Subscription_Product_Code__c IN :productCodesMap.keyset() OR Subscription_MCV__c!=null OR Subscription_ACV__c!=null OR Subscription_Product_Code__c=:AddAuthContactCode) Order By CreatedDate ASC
                                                           ];
            if(!SucbcriptionList.isEmpty()){
               
                // To fill-up the onne to many map "contractWithSubMap"
                for(SBQQ__Subscription__c sub : SucbcriptionList){
                    
                     if(sub.Subscription_Product_Code__c!=AddAuthContactCode){
                        if( contractWithSubMap.containsKey(sub.SBQQ__Contract__c) ){
                             contractWithSubMap.get(sub.SBQQ__Contract__c).add(sub);
                        }else{
                            contractWithSubMap.put(sub.SBQQ__Contract__c,new list<SBQQ__Subscription__c>{sub});
                        }//End of IF-ELSE
                    }//end of IF
                   else if(sub.Subscription_Product_Code__c==AddAuthContactCode){
                        if( contractWithAddContactSubMap.containsKey(sub.SBQQ__Contract__c) ){
                             contractWithAddContactSubMap.get(sub.SBQQ__Contract__c).add(sub);
                        }else{
                            contractWithAddContactSubMap.put(sub.SBQQ__Contract__c,new list<SBQQ__Subscription__c>{sub});
                        }//End of IF-ELSE
                    }//End of else if
                 }//End of FOR loop   
                system.debug('contractWithSubMap======================'+contractWithSubMap);
                if(!contractWithSubMap.isEmpty()){
                    
                    // Traverse the contract id from  map  "contractWithSubMap"
                    for(id contractid :contractWithSubMap.keySet()){
                       
                        // Get Contract record from map
                        contract con = contractMap.get(contractid);
                        
                        Map<String, Id> CustomSettingFieldwithIdMap = new Map<String,Id>();
                        
                        // Traverse SBQQ__Subscription__c related to contract
                        for(SBQQ__Subscription__c sub : contractWithSubMap.get(contractid)){
                            /* **********************************************************************
                                Last Modified By: Jade Global on 23rd August 2017
                                Purpose         : After Opty Closed Won - If Asset Not Created then populate Primary Asset On Contract 
                            *********************************************************************** */
                            if(sub.SBQQ__Contract__r.Primary_Asset__c==null && sub.SBQQ__Contract__r.SBQQ__Opportunity__r.SBQQ__RenewedContract__r.Primary_Asset__c!=null){
                                con.Primary_Asset__c = sub.SBQQ__Contract__r.SBQQ__Opportunity__r.SBQQ__RenewedContract__r.Primary_Asset__c;
                              }
                            // Check the Subscription_Product_Code__c not null and code is present in custom setting
                            if( sub.Subscription_Product_Code__c!=null && productCodesMap.containsKey(sub.Subscription_Product_Code__c)){
                                
                                // Get the custom setting records from map "productCodesMap"
                                Contract_Roll_Up_With_Product_Code__c ContractCode = productCodesMap.get(sub.Subscription_Product_Code__c);
                                system.debug('ContractCode ============'+ContractCode.Fieldname__c);
                                CustomSettingFieldwithIdMap.put(ContractCode.Fieldname__c,ContractCode.Id); 
                                system.debug('SubscriptionProduct_Code============'+sub.Subscription_Product_Code__c);
                                // Check the User code of Contract_Roll_Up_With_Product_Code__c record 
                                if(ContractCode.User_Code__c == null && ContractCode.Need_To_Check_Criteria__c  ){
                                    
                                    // Get the field name from Contract_Roll_Up_With_Product_Code__c record 
                                    //Add SBQQ__Quantity__c to the contract field
                                   // Update the contract using put method of Object, to 

                                    integer i = sub.get(ContractCode.Subscription_Field__c)==null? 0:Integer.valueOf(sub.get(ContractCode.Subscription_Field__c));
                                    
                                    con.put(ContractCode.Fieldname__c,Integer.valueOf(Con.get(ContractCode.Fieldname__c))+ i); 
                                    
                                    // Added this if block for Total Support Contacts
                                    if(ContractCode.Fieldname__c == 'Total_Support_Contacts__c' && sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Type == 'Upsell/Crossell' ){
                                        con.put(ContractCode.Fieldname__c,i);
                                    }//End of IF                                        
                                }//End of IF
                                // If user code in not then check if User_Code__c contains the  subscription Included_Marketing_Users__c
                                else if(ContractCode.Product_Code__c.contains(sub.Subscription_Product_Code__c)  && ContractCode.Need_To_Check_Criteria__c ) {
                                    // Get the field name from Contract_Roll_Up_With_Product_Code__c record 
                                    //Add SBQQ__Quantity__c to the contract field
                                   // Update the contract using put method of Object, to 
                                    integer i = sub.get(ContractCode.Subscription_Field__c)==null? 0:Integer.valueOf(sub.get(ContractCode.Subscription_Field__c));
                                    
                                    con.put(ContractCode.Fieldname__c,Integer.valueOf(Con.get(ContractCode.Fieldname__c))+ i);
                                    
                                    // Added this if block for Total Support Contacts
                                    if(ContractCode.Fieldname__c == 'Total_Support_Contacts__c' && sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Type == 'Upsell/Crossell' ){
                                        con.put(ContractCode.Fieldname__c,i);
                                    }//End of IF
                                }//End of ELSE-IF
                                
                            
                            }//End of IF loop
                           
                            if(!NoCriteriaContractRollUp.isEmpty()){
                                for(Contract_Roll_Up_With_Product_Code__c ContractCode : NoCriteriaContractRollUp){
                                    
                                    if(ContractCode.Need_To_Check_Criteria__c == False){
                                        CustomSettingFieldwithIdMap.put(ContractCode.Fieldname__c,ContractCode.Id);
                                        if(ContractCode.Include_in_Maintenance__c == false && ContractCode.SUP_Product_code__c==null){ 
                                            double i = sub.get(ContractCode.Subscription_Field__c)==null? 0:double.valueOf(sub.get(ContractCode.Subscription_Field__c));
                                            
                                             con.put(ContractCode.Fieldname__c,double.valueOf(Con.get(ContractCode.Fieldname__c))+ i);
                                             
                                            // Added this if block for Total Support Contacts
                                            if(ContractCode.Fieldname__c == 'Total_Support_Contacts__c' && sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Type == 'Upsell/Crossell' && sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName == 'Closed Won'){
                                                con.put(ContractCode.Fieldname__c,i);
                                            }//End of IF                                              
                                        }//End of IF
                                        
                                       if(ContractCode.Include_in_Maintenance__c == true && ContractCode.SUP_Product_code__c ==null && sub.Include_in_Maintenance__c==true){ 
                                            double i = sub.get(ContractCode.Subscription_Field__c)==null? 0:double.valueOf(sub.get(ContractCode.Subscription_Field__c));
                                            
                                            con.put(ContractCode.Fieldname__c,double.valueOf(Con.get(ContractCode.Fieldname__c))+ i);
                                            
                                           // Added this if block for Total Support Contacts
                                            if(ContractCode.Fieldname__c == 'Total_Support_Contacts__c' && sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Type == 'Upsell/Crossell' && sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName == 'Closed Won'){
                                                con.put(ContractCode.Fieldname__c,i);
                                            }//End of IF
                                        }//End of IF
                                        
                                        if(sub.Subscription_Product_Code__c!=null && ContractCode.Include_in_Maintenance__c == false && ContractCode.SUP_Product_code__c !=null){
                                            
                                            if(sub.Subscription_Product_Code__c.toLowercase().startsWith(ContractCode.SUP_Product_code__c.toLowercase())){
                                                double i = sub.get(ContractCode.Subscription_Field__c)==null? 0:double.valueOf(sub.get(ContractCode.Subscription_Field__c));
                                                
                                                con.put(ContractCode.Fieldname__c,double.valueOf(Con.get(ContractCode.Fieldname__c))+ i);
                                                
                                                // Added this if block for Total Support Contacts
                                                if(ContractCode.Fieldname__c == 'Total_Support_Contacts__c' && sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Type == 'Upsell/Crossell' && sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.StageName == 'Closed Won'){
                                                    con.put(ContractCode.Fieldname__c,i);
                                                }//End of IF
                                            }//End of IF
                                        }//End of IF
                                    }//End of IF loop
                                }//End of FOR loop
                            }//End of IF block
                             QualifiedCustomSettingRecords.add(con.Id);
                        }//End of FOR loop of Subscription
                        // This is used to multiple the sum of quantity field by respective value stored in custom setting for each  field.
                        for(Contract_Roll_Up_With_Product_Code__c conProduct :ContractCodeList){
                               if(contractWithAddContactSubMap.containsKey(contractid) && conProduct.Fieldname__c == 'Total_Support_Contacts__c' ){
                                 for(SBQQ__Subscription__c subsription :contractWithAddContactSubMap.get(contractid) ){
                                     if(subsription.get(conProduct.Subscription_Field__c)!=null && subsription.get(conProduct.Subscription_Field__c)!=0){
                                       con.put(conProduct.Fieldname__c,double.valueOf(con.get(conProduct.Fieldname__c)) + double.valueOf(subsription.get(conProduct.Subscription_Field__c)));
                                    }//End of IF
                                  }//End of FOR loop of SBQQ__Subscription__c
                             }//End of IF block of contractWithAddContactSubMap Empty check  
                            if(QualifiedCustomSettingRecords.contains(contractid)){
                                if(CustomSettingFieldwithIdMap.containsKey(conProduct.Fieldname__c)  && conProduct.Id == CustomSettingFieldwithIdMap.get(conProduct.Fieldname__c)){
                                
                                con.put(conProduct.Fieldname__c,double.valueOf(con.get(conProduct.Fieldname__c))* double.valueOf(conProduct.Multiplier__c));
                                system.debug('con.get(conProduct.Fieldname__c)*****'+con.get(conProduct.Fieldname__c));
                                system.debug('conProduct.Fieldname__c*****'+conProduct.Fieldname__c);
                                }//End of IF
                            }//End of IF 

                        }//End of FOR loop
            
            //This is used to update the contract status SBQQ__RenewalForecast__c only when subscription is inserted
            if(Trigger.isInsert && con.status!='Activated'){
              con.status                        = 'Activated'; 
	      // Added this logic in workflow
              //con.SBQQ__RenewalForecast__c    = true;
            }//End of If block
            
            
                        // Add the contract record in list for UPDATE
                        updateContractList.add(con);
                        // Remove the contract record from Map 
                        contractMap.remove(con.id);
                    }//End of FOR loop of ID(Contract)
                    
                     
                }//End of IF loop
                
            }//End of IF loop 
             
            // Update list of contract
            if(!ContractIds.isEmpty()){
                 if(!contractMap.values().isEmpty()){
                    updateContractList.addAll(contractMap.values());
                }//End of IF  

                system.debug('BeforeupdateContractList ########'+updateContractList);
                
                update updateContractList;
                
                system.debug('After updateContractList ########'+updateContractList);
            }//End of IF loop
      }//End of TRY block
       
        //Catch block
        catch(Exception ex){
       system.debug('Update of Contract failed==='+ex.getLineNumber()+',Cause='+ex.getCause()+',Message='+ex.getMessage());
            
        }//End of Catch block
       
    }//End of method updateRollUpContractFields 
    
    /**************************************************
     *  This method calls from subscription Trigger handler
     *  Parameter : Set of Subscription ids 
     *  Purpose   : To Create New Entitlements on Creation Of A Subscription
     *            
     * *************************************************/
    
    public void createEntitlements (set<id> subscriptionIds,set<id> ContractIds){
        
        /****** Start - APPS-9010 For upsell opportunity *******/
        Set<String> entitlementProductCodeCheck = new Set<String>();
        Set<Id> accountIdSet = new Set<Id>();
        Boolean flag = false;
        Map<Id,Set<String>> mapEntProductUpsellCheck = new Map<Id,Set<String>>();
        /****** End *******/
        
        map<string,id> entitlementProcessMap  = new map<string,id>(); // Map of Entitlement
        map<string,id> businessHoursMap       = new map<string,id>(); // Map to store the Id Of Business Hour Field
        // To store the Renewal opportunity ids
        set<id> renewalOppIds                 = new set<id>();
        //
        map<Id,Map<String,List<Entitlement>>> renewalOppToEnt       = new map<Id,Map<String,List<Entitlement>>>();
        
        //List of all records store in custom setting Support Entitlement
        list<Entitlement> EntitlementList = new list<Entitlement>();
            
        //Map of product code and its related custom setting record
        map<string,list<Entitlement_Product_Code_Criteria__c>> productCodesMap = new  map<string,list<Entitlement_Product_Code_Criteria__c>>();
        
        ///Map of contract id and its related active support Entitlement
        map<id,list<Entitlement>> ActiveContractToEntMap = new  map<id,list<Entitlement>>();
       
        set<id> OpportunityIds                = new set<id>();
        
       
    
         string multipleEntitlement =null;
        // Query to obtain Business Hour Id, Name and insert them in the respective Map
        for(BusinessHours bh :[SELECT CreatedById,CreatedDate,FridayEndTime,FridayStartTime,Id,IsActive,IsDefault,Name FROM BusinessHours]){
            businessHoursMap.put(bh.name,bh.id);
        }//End of FOR
         
        // Query to obtain Entitlement Process Id, Name and insert them in the respective Map
        for(SlaProcess sp : [SELECT Description,Id,IsActive,Name FROM SlaProcess]){
            entitlementProcessMap.put(sp.name,sp.id);
        }// End of FOR
        if(!ContractIds.isEmpty()){
            for(contract  con :[SELECT id ,SBQQ__Opportunity__c,SBQQ__Opportunity__r.Prior_Opportunity__c,SBQQ__Opportunity__r.type,AccountId,(SELECT id,type,Status,Subscription__r.Subscription_Product_Code__c,EndDate,RecordType.Name,RecordtypeId FROM Entitlements__r WHERE  recordType.name IN ('Support','Education')) FROM Contract WHERE id IN :ContractIds ]){
                if(con.SBQQ__Opportunity__r.type =='Renewal'){
                    renewalOppIds.add(con.SBQQ__Opportunity__c);
                }//End of IF
                if(!con.Entitlements__r.isEmpty()){
                    list<Entitlement> entList = con.Entitlements__r;
                    ActiveContractToEntMap.put(con.id,entList); 
                }//End of IF
                if(con.SBQQ__Opportunity__c!=null){
                    OpportunityIds.add(con.SBQQ__Opportunity__c);
                }//End of IF
                if(con.AccountId!=null){
                    AccountId.add(con.AccountId);
                    }
               
                contractCurrentOppMap.put(con.id, con.SBQQ__Opportunity__c);
                currentOppPriorOppMap.put(con.SBQQ__Opportunity__c,con.SBQQ__Opportunity__r.Prior_Opportunity__c);
                
            }//End of Contract FOR loop
            
            System.debug('ActiveContractToEntMap***************' + ActiveContractToEntMap);
            System.debug('currentOppPriorOppMap***************' + currentOppPriorOppMap);
                /****************************************************************************************
                  * Modified By   : Snehal Khot, Jade Global Inc
                  * Modified Date : 19th June 2017
                  * Purpose       : To query Named Support Engineer,Named Support Manager fields of Entitlement for APPS-14158 
                  * Modified Lines:729
                  *****************************************************************************************/
        //    if(!renewalOppIds.isEmpty()){
                 for(Entitlement ent :[SELECT id,type,endDate,Has_been_Replaced__c,Subscription_End_Date__c,Processed_for_grace__c,Contract__r.SBQQ__RenewalOpportunity__c,Contract__r.AccountId,Named_Support_Engineer__c,Named_Support_Manager__c,Named_Support_Engineer__r.IsActive,Named_Support_Manager__r.IsActive,recordType.name,RecordtypeId,AccountId,Subscription__r.Subscription_Product_Code__c,status,AssignedSupportPOC__c,AssignedSupportPOC__r.IsActive,POC_Type__c FROM Entitlement WHERE Contract__r.AccountId IN :AccountId  /*AND  status ='Active'*/ AND recordType.name IN ('Support','Education') order by enddate desc]){//#APPS 19030# removed the check of status ='Active' from query as we want expired entitlement also
                    system.debug('Entered');
                     if(ent.status=='Active'){ //#APPS 19030# added the check to run previous code when entitlement status is active so that logic remains intacct
            if(!renewalOppToEnt.containskey(ent.Contract__r.AccountId)){
              renewalOppToEnt.put(ent.Contract__r.AccountId,new Map<String,List<Entitlement>>());
            }
            if(renewalOppToEnt.containskey(ent.Contract__r.AccountId)){
              if(renewalOppToEnt.get(ent.Contract__r.AccountId).containsKey(ent.Type)){
                renewalOppToEnt.get(ent.Contract__r.AccountId).get(ent.Type).add(ent);  
              }else{
                renewalOppToEnt.get(ent.Contract__r.AccountId).put(ent.Type,new List<Entitlement>{ent});    
              }
            }
            if(!MapOfAccToPriorEnt.containsKey(ent.Contract__r.AccountId) && ent.RecordtypeId==SupportRecordTypeId){
              MapOfAccToPriorEnt.put(ent.Contract__r.AccountId,ent);
              system.debug('MapOfAccToPriorEnt@@@@@@@@@'+MapOfAccToPriorEnt);
            }
            system.debug('ent.Contract__r.SBQQ__RenewalOpportunity__c'+ent.Contract__r.SBQQ__RenewalOpportunity__c); 
            system.debug('ent@@@@@@@@@'+ent);
            
          if(!mapEntProductUpsellCheck.isEmpty() && mapEntProductUpsellCheck.containsKey(ent.AccountId)){
            Set<String> temp = mapEntProductUpsellCheck.get(ent.AccountId);
            temp.add(ent.Subscription__r.Subscription_Product_Code__c);
            mapEntProductUpsellCheck.put(ent.AccountId,temp);
          }else{
            mapEntProductUpsellCheck.put(ent.AccountId,new Set<String>{ent.Subscription__r.Subscription_Product_Code__c});
          }//End of IF-ELSE
          System.debug('ent***************' + ent); 
          System.debug('mapEntProductUpsellCheck***************' + mapEntProductUpsellCheck.get(ent.AccountId));
           }
          //#APPS-19030# getting last expired entitlement with each account in MapOfAccToPriorExpiredEnt
                    else if(ent.status=='Expired' && ent.recordtype.name=='Support' && ent.accountid!=null && !MapOfAccToPriorExpiredEnt.containsKey(ent.accountid)){
                          system.debug('orignal -- ent.type---->'+ent.type+'ent.recordtype.name----->'+ent.recordtype.name+'ent.accountid--->'+ent.accountid+'Boolean---->'+!MapOfAccToPriorExpiredEnt.containsKey(ent.accountid));
                          MapOfAccToPriorExpiredEnt.put(ent.accountid,ent);
                    }
                    //APPS-19030
                }//End of FOR
            }//End of IF 
        //}//End of IF
        /* ****************************************************************************
         Modified By : Priyanka Shende, Jade Global Inc, on 6th June 2017
         Modified below SOQL to cover below scenarios:
            1. Expired asset not pick in old to new conversion.
        ******************************************************************************* */
        // Get Assets of Prior Opportunities            
        for(Asset asst :[Select Id,AccountId,Opportunity__c,Latest_Opportunity__c,Opportunity__r.Migration__c,Latest_Opportunity__r.Migration__c,(Select Id, AssetId From Entitlements) From Asset Where Latest_Opportunity__c IN :OpportunityIds and Purpose__c='Production' AND Munchkin_ID__c != null and POD__c != null and Acct_Prefix__c != null and Status='Active']){          
            // Map of Opportunity and it's Assets
            if(priorOppIdAssetsMap.containsKey(asst.Latest_Opportunity__c)){
                priorOppIdAssetsMap.get(asst.Latest_Opportunity__c).add(asst);
            }else{
                priorOppIdAssetsMap.put(asst.Latest_Opportunity__c,new List<Asset>{asst});
            }//End of IF-ELSE
        }//End of FOR
        System.debug('priorOppIdAssetsMap***************' + priorOppIdAssetsMap);
                 
        //To get all custom setting records
        for(Entitlement_Product_Code_Criteria__c conProduct :Entitlement_Product_Code_Criteria__c.getAll().values()){
            if(conProduct.Product_Code__c != null ){ 
                if(productCodesMap.containsKey(conProduct.Product_Code__c)){
                    productCodesMap.get(conProduct.Product_Code__c).add(conProduct);
                }
                else{
                    productCodesMap.put(conProduct.Product_Code__c,new list<Entitlement_Product_Code_Criteria__c>{conProduct});
                }//End of IF-ELSE
            }//End of IF
        }//End of FOR
        System.debug('productCodesMap***************' + productCodesMap);
        
        //Get all Opportunity Product 
        for(OpportunityLineItem oli: [SElECT id,productcode FROM OpportunityLineItem WHERE Opportunityid IN :OpportunityIds]){
            productCodeToOppProdId.put(oli.productcode,oli.id);
        }//End of FOR  

        if(!subscriptionIds.isEmpty()){
         // Added new fields in Query on 6th June 2018 as per MDQ Entitlement code change   
            list<SBQQ__Subscription__c> SubscriList =[SELECT id,name,Subscription_Product_Code__c,SBQQ__Account__c ,SBQQ__Contract__r.SBQQ__Opportunity__r.AccountId,SBQQ__Account__r.Sales_Region__c, SBQQ__Account__r.name,SBQQ__Contract__c,SBQQ__Contract__r.Primary_Asset__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Contract__r.SBQQ__Opportunity__r.Promotional_End_Date__c ,SBQQ__TerminatedDate__c,SBQQ__Contract__r.SBQQ__Opportunity__c,SBQQ__Product__r.Asset_Type__c,SBQQ__Product__r.Family,SBQQ__Contract__r.SBQQ__Opportunity__r.Type,SBQQ__Contract__r.AccountId,SBQQ__Quantity__c,Product_Name__c,SBQQ__Contract__r.account.Partner_Type__c,SBQQ__Contract__r.SBQQ__Quote__r.Order_Type__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.type,SBQQ__SegmentQuantity__c,SBQQ__SegmentStartDate__c,SBQQ__SegmentEndDate__c,Production_Asset__c  FROM SBQQ__Subscription__c WHERE Id IN :subscriptionIds];
            set<id> PreviousEntId = new set<id>();
            
            // Create Map of Contract Id's and it's related Assets
            // Create map of Product Codes and it's Quantity from Subscription. This will needed if any product has multiple entries with different quantity - prodCodeToProdQtyMap.            
            Set<Id> ContractIdSet = new Set<Id>();          
            prodCodeToProdQtyMap.clear();
            for(SBQQ__Subscription__c thisSub :SubscriList){
                if(prodCodeToProdQtyMap.containsKey(thisSub.Subscription_Product_Code__c)){
                    Decimal qtySum = (prodCodeToProdQtyMap.get(thisSub.Subscription_Product_Code__c) != null ? prodCodeToProdQtyMap.get(thisSub.Subscription_Product_Code__c) : 0.0) + thisSub.SBQQ__Quantity__c;
                    prodCodeToProdQtyMap.put(thisSub.Subscription_Product_Code__c,qtySum);          
                }else{
                    prodCodeToProdQtyMap.put(thisSub.Subscription_Product_Code__c, thisSub.SBQQ__Quantity__c);
                }//End of IF-ELSE

                if(thisSub.SBQQ__Contract__c != null){
                    ContractIdSet.add(thisSub.SBQQ__Contract__c);
                }//End of IF
                /**** APPS-9010 ****/
                accountIdSet.add(thisSub.SBQQ__Account__c);
            }//End of FOR
            System.debug('ContractIdSet*****************' + ContractIdSet);
            System.debug('prodCodeToProdQtyMap*****************' + prodCodeToProdQtyMap);
            
            if(!ContractIdSet.isEmpty()){
                for(Asset thisAsset:[Select Id, Contract__c,Purpose__c,Production_Asset__r.purpose__c,Opportunity__r.Migration__c,Latest_Opportunity__r.Migration__c from Asset where Purpose__c like '%Production%' and Contract__c IN :ContractIdSet]){
                    if(contractToAssetsMap.containsKey(thisAsset.Contract__c)){
                        contractToAssetsMap.get(thisAsset.Contract__c).add(thisAsset);
                    }else{
                        contractToAssetsMap.put(thisAsset.Contract__c, new List<Asset>{thisAsset});
                    }//End of IF-ELSE
                }//End of FOR   
            }//End of IF
            System.debug('contractToAssetsMap*****************' + contractToAssetsMap);
            
            /****End - APPS-9010 ****/
      
      /**********APPS-11599 START*********/
            Set <String> educationUnique=new Set <String>();
            /*********APPS-11599 END*********/
      
      for(SBQQ__Subscription__c sub : SubscriList){   
                /* ********************************************************************************
                * Modified By         : Priyanka Shende, Jade Global Inc, on 6th June 2018
                * Purpose             : To Handle MDQ Scenario - JIRA - APPS-20524 
                ********************************************************************************** */             
               Decimal subQuantity = sub.SBQQ__SegmentQuantity__c!=null? sub.SBQQ__SegmentQuantity__c: sub.SBQQ__Quantity__c;
                
                    // To check previous entitlement is present - This IF loop is only execute for  Upsell/Crossell opportunities attached to New Business contract. 
                    if(ActiveContractToEntMap.containsKey(sub.SBQQ__Contract__c) && sub.SBQQ__Contract__r.SBQQ__Opportunity__r.Type!='Renewal' && (Sub.SBQQ__Product__r.Asset_Type__c == 'Support Product' || productCodesMap.containsKey(sub.Subscription_Product_Code__c))){
                        Entitlement preEnt = ActiveContractToEntMap.get(sub.SBQQ__Contract__c)[0];
                        if(subQuantity > 0.0){
                            for(Integer i=0; i<subQuantity; i++){                               
                                Entitlement en = new Entitlement ();                            
                             /*  if(ActiveContractToEntMap.get(sub.SBQQ__Contract__c).size() >= 1 && */if(preEnt.Subscription__r.Subscription_Product_Code__c!=null && preEnt.Subscription__r.Subscription_Product_Code__c != sub.Subscription_Product_Code__c /*&& preEnt.EndDate!= sub.SBQQ__EndDate__c*/){
                                    en.Previous_Entitlement__c = preEnt.id;
                                    en = createEntitlementRecord(en,sub,productCodesMap,entitlementProcessMap,businessHoursMap);
                                    // preEnt.status  = 'Expired';
                                    if(sub.SBQQ__Contract__r.SBQQ__Opportunity__r.Type=='Upsell/Crossell'){
                                        preEnt.enddate = en.startDate.addDays(-1);
                                         EntitlementList.add(preEnt);
                                }//End of IF                                   
                                    /*********APPS-11599 START*********/
                                    if(en.recordtypeid==EducationRecordTypeId){
                                        system.debug('###EDUCATION ENTITLEMENT###'+en);
                                        if (educationUnique.isempty()){
                                            EntitlementList.add(en);
                                            educationUnique.add(en.accountid+'-'+en.Opportunity__c+'-'+sub.SBQQ__Product__c+'-'+sub.Id);
                                             system.debug(educationUnique);
                                        }else if (!educationUnique.contains(en.accountid+'-'+en.Opportunity__c+'-'+sub.SBQQ__Product__c+'-'+sub.Id)){
                                            EntitlementList.add(en);
                                        }
                                    }else{
                                        /* ****************************************************************************
                                        Modified By : Suraj Makandar, Jade Global Inc, on 18th August 2017
                                        Added code to check if previous entitlement with similar type exist
                                        ******************************************************************************* */  
                                        if(renewalOppToEnt.containsKey(sub.SBQQ__Contract__r.AccountId) && !renewalOppToEnt.get(sub.SBQQ__Contract__r.AccountId).containsKey(en.Type)){
                                            EntitlementList.add(en);
                                            system.debug('EntitlementList###'+EntitlementList);
                                        }
                                }//End of ELSE
                                    
                                    /*********APPS-11599 END*********/                                  
                                }//End of IF block - Subscription_Product_Code__c code check
                                //No action needed if there are more than 1 Entitlement is present for contract
                                // Sent Email notification
                                else if(ActiveContractToEntMap.get(sub.SBQQ__Contract__c).size() >1){
                                    multipleEntitlement = multipleEntitlement==null?'Subcription Name ' + sub.name +' < br/>':multipleEntitlement +' Subcription Name ' + sub.name +' < br/>' ;
                            }//End of ELSE-IF
                            } // end of subQuantity for
                        } // end of subQuantity if                                                  
                    }//End of IF block - previous entitlement is present - End of Upsell Loop
                     
                     //This block will execute for New business,Renewal opprtunities and Upsells attached to Renewal Oppoprtunities
                    else if((Sub.SBQQ__Product__r.Asset_Type__c == 'Support Product' || productCodesMap.containsKey(sub.Subscription_Product_Code__c))) {
                    
                  /****************************************************************************************
                  * Last Modified By   : Rajesh Wani, Jade global Inc
                  * Last Modified Date : 8th June 2017
                  * Purpose            : 1.Avoid creating duplicate entitlement on closure of Upsell Opportunity
                  *                      2.APPS-12454
                  *****************************************************************************************/
                   boolean EntExist = false;  
                   boolean selected= false;
                  if(/*ActiveContractToEntMap.containsKey(sub.SBQQ__Contract__c)*/ renewalOppToEnt.containsKey(sub.SBQQ__Contract__r.AccountId) && productCodesMap.containsKey(sub.Subscription_Product_Code__c)){
                        
                         if(sub.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.type == Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL){
                              Entitlement_Product_Code_Criteria__c supEnt ;
                                for(Entitlement_Product_Code_Criteria__c ent :productCodesMap.get(sub.Subscription_Product_Code__c)){
                                    if( ent.Account_Partner_Type__c!=null && ent.Order_Type__c!=null && ent.Account_Partner_Type__c== sub.SBQQ__Contract__r.account.Partner_Type__c && ent.Order_Type__c== sub.SBQQ__Contract__r.SBQQ__Quote__r.Order_Type__c){
                                        supEnt = ent;
                                        selected= true;
                                        System.debug('supEnt**********' + supEnt);
                                    }//End of IF
                                    else if(selected==false && ent.Account_Partner_Type__c==null && ent.Order_Type__c!=null && ent.Order_Type__c==sub.SBQQ__Contract__r.SBQQ__Quote__r.Order_Type__c){
                                        supEnt = ent;
                                        selected= true;
                                        System.debug('supEnt**********' + supEnt);
                                    }//End of ELSE-IF
                                    else if(ent.Account_Partner_Type__c==null && ent.Order_Type__c==null && selected==false){
                                        supEnt = ent;
                                        System.debug('supEnt**********' + supEnt);
                                    }//End of ELSE-IF
                                }//End of FOR loop of Entitlement_Product_Code_Criteria__c
                                
                              if(renewalOppToEnt.containsKey(sub.SBQQ__Contract__r.AccountId) && renewalOppToEnt.get(sub.SBQQ__Contract__r.AccountId).containsKey(supEnt.Type__c)){
                                       EntExist = true;
                                     
                                   }
                         }//End of Upsell opportunity loop
                    }// End of IF block of existing ENT
                        
                    if(subQuantity > 0.0 && EntExist== false){
                            for(Integer i=0; i<subQuantity; i++){                               
                                Entitlement preEnt  = new Entitlement();
                                Entitlement en = new Entitlement (); 
                                List<Entitlement> preEntList = new List<Entitlement>();
                                en = createEntitlementRecord(en,sub,productCodesMap,entitlementProcessMap,businessHoursMap);
                            if(renewalOppToEnt.containsKey(sub.SBQQ__Contract__r.AccountId) && renewalOppToEnt.get(sub.SBQQ__Contract__r.AccountId).containsKey(en.Type)){
                                system.debug('Inside If stmt');
                                preEntList  = renewalOppToEnt.get(sub.SBQQ__Contract__r.AccountId).get(en.Type);
                             }
                         system.debug('################## preEnt'+preEntList);
                         Integer Count=0;
                         if(preEntList.isEmpty()){
                            Count = 1;
                         }else{
                             Count = preEntList.size();
                         }
                         for(Integer j=0;j<count;j++){
                           If(!preEntList.isEmpty()){
                               preEnt = preEntList[j];
                           }
                           System.debug('Entitlement is==='+preEnt);                   
                           boolean preEntitlementCreation= true;
                                
                                if(!mapEntProductUpsellCheck.isEmpty() && mapEntProductUpsellCheck.get(sub.SBQQ__Account__r.Id).contains(sub.Subscription_Product_Code__c) && sub.SBQQ__Contract__r.SBQQ__Opportunity__r.Type=='Upsell/Crossell'){
                                    flag = true;
                            }//End of IF
                                
                                 if(sub.SBQQ__Contract__r.SBQQ__Opportunity__r.Type =='Renewal' /*&&  !renewalOppToEnt.isEmpty()*/ && sub.SBQQ__Contract__r.SBQQ__Opportunity__c!=null && (renewalOppToEnt.containsKey(sub.SBQQ__Contract__r.AccountId) || MapOfAccToPriorExpiredEnt.containsKey(sub.SBQQ__Contract__r.AccountId)) ){// #APPS 19030# - removed the check of !renewalOppToEnt.isEmpty() and added the check of MapOfAccToPriorExpiredEnt.containsKey(sub.SBQQ__Contract__r.AccountId) in or condition with renewalOppToEnt.containsKey(sub.SBQQ__Contract__r.AccountId) as this if condition will not run otherwise in case when the only active entitlement on account is being created
                                    /*************************************************************************************
                                  * Modified By   : Snehal Khot, Jade Global Inc
                                  * Modified Date : 19th June 2017
                                  * Purpose       : On renewal, when we create a new entitlement Carry forward Named Support Engineer and Named Support Manager from previous Entitlement
                                  * Added Lines   : 925 to 931
                                ***********************************************************************************/
                                Entitlement PriorEnt=MapOfAccToPriorEnt.get(sub.SBQQ__Contract__r.AccountId);
                
                /*#APPS 19030# commented the previous code to populate NSE and NSM*/
                                /*If(PriorEnt.Named_Support_Engineer__r.IsActive && en.RecordtypeId==SupportRecordTypeId && PriorEnt!=null){
                                    en.Named_Support_Engineer__c    =!(String.isBlank(PriorEnt.Named_Support_Engineer__c ))?PriorEnt.Named_Support_Engineer__c: en.Named_Support_Engineer__c;
                                }       
                                
                                If(PriorEnt.Named_Support_Manager__r.IsActive && en.RecordtypeId==SupportRecordTypeId && PriorEnt!=null){
                                    en.Named_Support_Manager__c     =!(String.isBlank(PriorEnt.Named_Support_Manager__c ))?PriorEnt.Named_Support_Manager__c : en.Named_Support_Manager__c;
                                }*/
                                // Replaced NSM or NSE with Assigned POC field. It is related to SISR - #01009688 [Changes done by AMan Bisht] //APPS-19030
                                system.debug('en.type---->'+en.id+'ggg'+en.type+'MapOfAccToPriorExpiredEnt'+MapOfAccToPriorExpiredEnt);
                                If(en.RecordtypeId==SupportRecordTypeId && PriorEnt!=null && PriorEnt.AssignedSupportPOC__r.IsActive &&  en.type==PriorEnt.type){
                                    en.AssignedSupportPOC__c =!(String.isBlank(PriorEnt.AssignedSupportPOC__c))?PriorEnt.AssignedSupportPOC__c: en.AssignedSupportPOC__c;
                                    en.POC_Type__c=!(String.isBlank(PriorEnt.POC_Type__c))?PriorEnt.POC_Type__c: en.POC_Type__c;
                                } 
                /*APPS-19030 added the else if condition where it is checked that if there exist any last expired support
                                entitlement with same type that of being newly created and with AssignedSupportPOC and POC_Type__c populated
                                then it will populate the value of AssignedSupportPOC and POC_Type__c to the new entitlement being created */
                                
                                else if(en.RecordtypeId==SupportRecordTypeId && MapOfAccToPriorExpiredEnt.containsKey(en.accountid)){
                                    system.debug('en.type---->'+en.type+'ent.recordtype.name----->'+en.recordtype.name+'ent.accountid--->'+en.accountid+'Boolean---->'+!MapOfAccToPriorExpiredEnt.containsKey(en.accountid));
                                    if(MapOfAccToPriorExpiredEnt.get(en.accountid).type==en.type){
                                        en.AssignedSupportPOC__c =!(String.isBlank(MapOfAccToPriorExpiredEnt.get(en.accountid).AssignedSupportPOC__c))?MapOfAccToPriorExpiredEnt.get(en.accountid).AssignedSupportPOC__c: en.AssignedSupportPOC__c;
                                        en.POC_Type__c=!(String.isBlank(MapOfAccToPriorExpiredEnt.get(en.accountid).POC_Type__c))?MapOfAccToPriorExpiredEnt.get(en.accountid).POC_Type__c: en.POC_Type__c;
                                    }
                                }
                                //APPS-19030
                                /* **************************************************************************
                                    Modified By: Priyanka Shende, Jade Global Inc, on 5th July 2017
                                    Purpose:  1. If the Support type is same, Update the end date on existing entitlement
  *                                           2. If the Support type is same, populate the Current Subscription and asset on existing entitlement
                                 * ************************************************************************* */
                  if(renewalOppToEnt.containsKey(sub.SBQQ__Contract__r.AccountId)){ // #APPS 19030#  Added the chheck of renewalOppToEnt.containsKey(sub.SBQQ__Contract__r.AccountId) on rest of code such that the process remains intacct
                   if(en!=null && en.Type!=null && preEnt.Type!=null && en.Type==preEnt.Type){
                      preEntitlementCreation= false;
                      preEnt.EndDate= sub.SBQQ__EndDate__c;
                      preEnt.AssetId=en.AssetId;
                      preEnt.Subscription__c=sub.id;
                      EntitlementIdsForAuthContact.add(preEnt.id);
                   }
                   if(preEntitlementCreation && !PreviousEntId.contains(PriorEnt.Id)){
                    en.Previous_Entitlement__c             = PriorEnt.id;                             
                    PriorEnt.Has_been_Replaced__c = true;
                    if(PriorEnt.Processed_for_grace__c = true){
                      PriorEnt.Processed_for_grace__c = false;
                      PriorEnt.Enddate           =  PriorEnt.Subscription_End_Date__c;
                      
                    }//End of IF  block
                    EntitlementList.add(PriorEnt);
                    PreviousEntId.add(PriorEnt.Id);
                    }
                    if(preEnt.id != null && !PreviousEntId.contains(preEnt.id)){
                      EntitlementList.add(preEnt);
                      PreviousEntId.add(preEnt.id);
                  }//End of IF
                    }
                                }//End of IF block for Renewal subcription                              
                                
                                // Populate Previous Entitlement on this Entitlement
                            if(en.Previous_Entitlement__c == null && contractCurrentOppMap.containsKey(en.Contract__c) && preEntitlementCreation){
                                    Id currentOppId = contractCurrentOppMap.get(en.Contract__c);
                                    system.debug('currentOppId ===='+currentOppId);
                                    if(currentOppPriorOppMap.containsKey(currentOppId)){
                                        //Id priorOppId = currentOppPriorOppMap.get(currentOppId);
                                        system.debug('PRIOR ===='+priorOppIdAssetsMap.containsKey(currentOppId));
                                        if(priorOppIdAssetsMap.containsKey(currentOppId)){
                                            if(priorOppIdAssetsMap.get(currentOppId).size()==1){
                                                Asset OldAsset = priorOppIdAssetsMap.get(currentOppId)[0];                            
                                                if(oldasset.Entitlements.size() == 1){
                                                    en.Previous_Entitlement__c = oldasset.Entitlements[0].id;
                                                }else if(oldasset.Entitlements.size() > 1){
                                                    // Multiple Entitlements - Check Matching Entitlement Process.
                                                    for(Entitlement oldent : oldasset.Entitlements){
                                                        
                                                            en.Previous_Entitlement__c = oldEnt.id;  
                                                                                                            
                                                    }
                                                }                           
                                            }else{
                                                // Multiple Assets - Need to handle this scenario.
                                        }//End of IF-ELSE
                                    }//End of IF
                                }//End of IF                   
                            }//End of IF
                            if(!flag){
                                /*********APPS-11599 START*********/
                                if(en.recordtypeid==EducationRecordTypeId){
                                    if (educationUnique.isempty()){
                                        if(preEnt.Id==null){
                                        EntitlementList.add(en);
                                        }
                                        /* *************************************************************************************
                                            Modified By : Priyanka Shende, Jade Global Inc, on 5th July 2017
                                            Purpose:  Do not create a new entitlement unless there is change in support type 
                                        * *********************************************************************************** */
                                        else if(en!=null && preEnt!=null && en.Type!=preEnt.Type && en.RecordTypeId==preEnt.RecordTypeId){
                                            EntitlementList.add(en);
                                        }
                                        educationUnique.add(en.accountid+'-'+en.Opportunity__c+'-'+sub.SBQQ__Product__c+'-'+sub.Id);
                                    }else if (!educationUnique.contains(en.accountid+'-'+en.Opportunity__c+'-'+sub.SBQQ__Product__c+'-'+sub.Id)){
                                        if(preEnt.Id==null){
                                            EntitlementList.add(en); 
                                        }
                                        /* *************************************************************************************
                                        Modified By : Priyanka Shende, Jade Global Inc, on 5th July 2017
                                          Purpose:  Do not create a new entitlement unless there is change in support type 
                                        * *********************************************************************************** */
                                        
                                        else if(en!=null && preEnt!=null && en.Type!=preEnt.Type && en.RecordTypeId==preEnt.RecordTypeId){
                                            EntitlementList.add(en);
                                        }
                                    }//End of ELSE-IF
                                }else{
                                    if(preEnt.Id==null){
                                        EntitlementList.add(en); 
                                    }
                                    /* *************************************************************************************
                                     Modified By : Priyanka Shende, Jade Global Inc, on 5th July 2017
                                          Purpose:  Do not create a new entitlement unless there is change in support type 
                                     * *********************************************************************************** */
                                    else if(en!=null && preEnt!=null && en.Type!=preEnt.Type && en.RecordTypeId==preEnt.RecordTypeId){
                                        EntitlementList.add(en);
                                    }
                                }//End of IF-ELSE
                                /*********APPS-11599 END*********/  
                            }//End of IF
                          }//End of FOR
                        }//End of FOR
                    }//End of IF
                }//End of ELSE-IF                                  
            }//End of FOR - SubscriptionList
            
            System.debug('List================================>'+EntitlementList);
            if(!EntitlementList.isEmpty()){
                upsert EntitlementList;
                system.debug('createAuthorizedContact with ent'+EntitlementList);
                createAuthorizedContact(EntitlementList); // Call createAuthorisedContact()
                list<Entitlement> educationEntList = new list<Entitlement>();
                for(Entitlement ent :EntitlementList){
                    if(ent.RecordTypeId == EducationRecordTypeId){
                        system.debug('educationEntList'+educationEntList);
                        educationEntList.add(ent);
                    }//End of IF
                }//End of FOR loop of Entitlement
                
                //creating the Learning_Passport__c for education Entitlement
                if(!educationEntList.isEmpty()){
                    LMS_Util.generateUniqueCode(educationEntList);
                }//End of IF
            }//End of if block
        }//End of IF
            
        //Send email to 
        if(multipleEntitlement !=null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                // Vijay will be providing the email address
                String[] toAddresses = new String[] {'rajesh.wani@jadeglobal.com'}; 
                mail.setToAddresses(toAddresses);
                mail.setSenderDisplayName('Salesforce Administrator');
                mail.setSubject('Multiple Active Entitlement found for Subscription');
                mail.setBccSender(false);
                mail.setUseSignature(false);
                mail.setPlainTextBody('Multiple Active Entitlement found for subscription: ' );

                mail.setHtmlBody(multipleEntitlement);

                // Send the email you have created.
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }//End of if block
            
    } // End of Method createEntitlements        
  
   // This Method is used to add Required fields in the newly Created Entitlement Record
    public Entitlement createEntitlementRecord(Entitlement en,SBQQ__Subscription__c sub, map<string,List<Entitlement_Product_Code_Criteria__c>> productCodesMap, map<string,id> entitlementProcessMap, map<string,id> businessHoursMap){
        
        en.AccountId = sub.SBQQ__Account__c;
        en.name = sub.SBQQ__Account__r.name ;
        en.Contract__c = sub.SBQQ__Contract__c;
        
        
        // Create one titlement for each subscription logic.
        // Check whether there is one entry for a product. For multiple product entries controller will go into else part
        if((prodCodeToProdQtyMap.containsKey(sub.Subscription_Product_Code__c) && contractToAssetsMap.containsKey(sub.SBQQ__Contract__c) && prodCodeToProdQtyMap.get(sub.Subscription_Product_Code__c) == 1  && (contractToAssetsMap.get(sub.SBQQ__Contract__c).size() == 1 || (prodCodeToProdQtyMap.get(sub.Subscription_Product_Code__c) < contractToAssetsMap.get(sub.SBQQ__Contract__c).size()))) || (!contractToAssetsMap.ContainsKey(sub.SBQQ__Contract__c) && sub.SBQQ__Contract__r.Primary_Asset__c!=null)){
           // en.AssetId = sub.SBQQ__Contract__r.Primary_Asset__c;
            en.AssetId = sub.Production_Asset__c;
        }else if(prodCodeToProdQtyMap.containsKey(sub.Subscription_Product_Code__c) && contractToAssetsMap.containsKey(sub.SBQQ__Contract__c) && prodCodeToProdQtyMap.get(sub.Subscription_Product_Code__c) > 1 ){
            List<Asset> assetList = contractToAssetsMap.get(sub.SBQQ__Contract__c);
            for(Asset thisAsset :assetList){
                if(!mappedAssetSet.contains(thisAsset.Id)){
                    en.AssetId = thisAsset.Id;
                    mappedAssetSet.add(thisAsset.Id);
                    break;
                }//End of IF
            }//End of FOR                       
        }else{
            // Handle scenario where Number of Assets are greater than Subscription Quantity.
        }//End of ELSE
            
        System.debug('mappedAssetSet**********' + mappedAssetSet);
        
        en.Subscription__c = sub.Id;
        /* ********************************************************************************
        * Modified By         : Priyanka Shende, Jade Global Inc, on 6th June 2018
        * Purpose             : To Handle MDQ Scenario - JIRA - APPS-20524 
        ********************************************************************************** */ 
        en.StartDate = sub.SBQQ__SegmentStartDate__c!=null ? sub.SBQQ__SegmentStartDate__c : sub.SBQQ__StartDate__c;
        en.EndDate = sub.SBQQ__SegmentEndDate__c!=null ? sub.SBQQ__SegmentEndDate__c : sub.SBQQ__EndDate__c;
        en.Promotional_Reference_Date__c = sub.SBQQ__Contract__r.SBQQ__Opportunity__r.Promotional_End_Date__c;
        en.recordTypeId = SupportRecordTypeId;
        en.OK_to_Add__c = true; //default TRUE
        en.Support_Region__c = sub.SBQQ__Account__r.Sales_Region__c;       
       
        if(sub.SBQQ__TerminatedDate__c != null && sub.SBQQ__TerminatedDate__c < system.today()){
            en.Subscription_Status__c = 'Expired';
        }//End of IF

        if( productCodesMap.containsKey(sub.Subscription_Product_Code__c)){
            // Create Entitlements
            list<Entitlement_Product_Code_Criteria__c> supEntList = productCodesMap.get(sub.Subscription_Product_Code__c);
            Entitlement_Product_Code_Criteria__c supEnt; 
            boolean selected= false;
            for(Entitlement_Product_Code_Criteria__c ent :supEntList){
                if( ent.Account_Partner_Type__c!=null && ent.Order_Type__c!=null && ent.Account_Partner_Type__c== sub.SBQQ__Contract__r.account.Partner_Type__c && ent.Order_Type__c== sub.SBQQ__Contract__r.SBQQ__Quote__r.Order_Type__c){
                    supEnt = ent;
                    selected= true;
                }//End of IF
                else if(selected==false && ent.Account_Partner_Type__c==null && ent.Order_Type__c!=null && ent.Order_Type__c==sub.SBQQ__Contract__r.SBQQ__Quote__r.Order_Type__c){
                    supEnt = ent;
                    selected= true;
                }//End of ELSE-IF
                else if(ent.Account_Partner_Type__c==null && ent.Order_Type__c==null && selected==false){
                    supEnt = ent;
                }//End of ELSE-IF
            }//End of FOR loop of Entitlement_Product_Code_Criteria__c

            System.debug('supEnt**********' + supEnt);

            en.name = sub.SBQQ__Account__r.name+' ' + (supEnt != null ? supEnt.Type__c : null);

            If(supEnt != NULL){
                en.Type = supEnt.Type__c;          

                if(supEnt.Entitlement_Process__c != null && entitlementProcessMap.containsKey(supEnt.Entitlement_Process__c)){
                    en.SlaProcessId = entitlementProcessMap.get(supEnt.Entitlement_Process__c);
                }//End of IF
                if(supEnt.Business_Hours__c != null && businessHoursMap.containsKey(supEnt.Business_Hours__c)){
                    en.BusinessHoursId = businessHoursMap.get(supEnt.Business_Hours__c);
                }//End of IF 
                if(supEnt.Record_Type__c == EDUCATION_RECORDTYPE){
        //if(supEnt.Record_Type__c == 'Education'){ Added for APPS-16908
                    en.recordTypeId        = EducationRecordTypeId;
                    en.AssetId             = null;
                    en.Opportunity__c      = sub.SBQQ__Contract__r.SBQQ__Opportunity__c;
                    en.Quantity__c         = sub.SBQQ__Quantity__c; 
                    en.Catalog__c          = System.Label.Premium_Education_Catalog_Id;
                    en.Products__c         = sub.Product_Name__c;
                    if(!productCodeToOppProdId.isEmpty() && productCodeToOppProdId.containskey(sub.Subscription_Product_Code__c)){
                        en.Opportunity_Product__c = productCodeToOppProdId.get(sub.Subscription_Product_Code__c);
                    }//End of IF
                }//End of IF
        /***** START - Added for APPS-16908 *****/
         else if(supEnt.Record_Type__c == EDU_SUBSCRIPTION_RECORDTYPE){
                    en.recordTypeId        = EduSubscription;
                    en.Opportunity__c      = sub.SBQQ__Contract__r.SBQQ__Opportunity__c;
                    en.Quantity__c         = sub.SBQQ__Quantity__c; 
                    en.Products__c         = sub.Product_Name__c;
                }//End of ELSE-IF
        /***** END - Added for APPS-16908 *****/
        else if(supEnt.Record_Type__c == SUPPORT_RECORDTYPE){
                //else if(supEnt.Record_Type__c == 'Support'){ Added for APPS-16908
                    en.recordTypeId =SupportRecordTypeId;
                }//End of ELSE-IF
            }//End of If - supEnt != NULL

        }//End of IF block of productCodesMap containsKey check
          
        string locale = 'Local Hours ('+ en.Support_Region__c+')';
      
        if(en.Support_Region__c!=null && en.BusinessHoursId == null && businessHoursMap.containsKey(locale)){
            en.BusinessHoursId = businessHoursMap.get(locale);
        }//End of IF
        
        return en;
        
    }//End of Method  createEntitlementRecord
       
    //This is used to update the Entitlement related to the subscription
    public void UpdateEntitlement(set<id> subScribtionIds){
        list<Entitlement> updateEntitlementList = new list<Entitlement>();
        for(Entitlement en:[SELECT id,status,EndDate, Subscription__c,Subscription__r.SBQQ__TerminatedDate__c,Subscription_End_Date__c FROM Entitlement WHERE Subscription__c IN :subScribtionIds AND Enddate !=null AND Subscription__r.SBQQ__TerminatedDate__c !=null]){
            if(en.Subscription__r.SBQQ__TerminatedDate__c!=null && en.enddate!=null && en.EndDate > en.Subscription__r.SBQQ__TerminatedDate__c ){
                en.EndDate = en.Subscription__r.SBQQ__TerminatedDate__c;
                updateEntitlementList.add(en);
            }//End of IF 
        }//End of FOR loop
        if(!updateEntitlementList.isEmpty()){
            update updateEntitlementList;
        }//End of IF loop
    }//End of Method UpdateEntitlement
    
    //This is used to update the Asset 
    public void UpdateAsset(set<id> contractIds){
       
        if(!contractIds.isEmpty()){
        
            list<Asset> updateassetList = new list<Asset>();
             Map<String, Schema.SObjectType> sObjectMap = Schema.getGlobalDescribe() ;
            Schema.SObjectType s = sObjectMap.get('Asset') ; // getting Sobject Type
            Schema.DescribeSObjectResult resSchema = s.getDescribe() ;
            Map<String,Schema.RecordTypeInfo> recordTypeInfo = resSchema.getRecordTypeInfosByName(); 
            Id assetCPQInstanceId     = recordTypeInfo.get(system.label.AssetRecordTypeNameCPQInstance).getRecordTypeId();
            
            // Modified by: Jade Team on 3rd May 2016 - Purpose to handle old to new scneario(map Production Instance First) - Added where clause in query
            // Modified by: Jade Team on 5th  May 2018 - Purpose to query the entitlement related to the contract 
            map<id,contract> contractMap = new map<id,contract>([SELECT id,startdate,name,SBQQ__Opportunity__c,SBQQ__Opportunity__r.Prior_Opportunity__c,SBQQ__Opportunity__r.type,SBQQ__Opportunity__r.SBQQ__RenewedContract__c ,SBQQ__RenewalOpportunity__c,SBQQ__Quote__r.Rubiks_Quote__c,Primary_Asset__c,Primary_Asset__r.purpose__c,SBQQ__Quote__r.SBQQ__LineItemsGrouped__c,(SELECT id,name, SBQQ__Contract__c,SBQQ__Product__c,SBQQ__Product__r.productcode,Product_Name__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__QuoteLine__c,Subscription_Product_Code__c FROM SBQQ__Subscriptions__r),(SELECT id,accountid,name,Purpose__c,Associated_Bundle__c,SBQQ__CurrentSubscription__c,Contract__c,Contract__r.Primary_Asset__c,Contract__r.Primary_Asset__r.purpose__c,recordtypeid,Product2.ProductCode,status,Acct_Prefix__c,POD__c,Munchkin_ID__c,Opportunity__c,Provision_Status__c,Latest_Opportunity__c,Opportunity__r.Migration__c,Latest_Opportunity__r.Migration__c, Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c,Contract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c FROM Assets__r order by Product_Code__c),(SELECT id,name,StartDate,EndDate,Status FROM Entitlements__r WHERE Status='Active') FROM Contract WHERE id IN : contractIds]);
            
            set<id> renewedContractIds = new set<id>();
            set<id> futureOpptyids                       = new set<id>();
            for(contract contra: contractMap.values()){
                if(contra.SBQQ__Opportunity__r.type =='Renewal' && contra.SBQQ__Opportunity__r.SBQQ__RenewedContract__c!=null){
                    renewedContractIds.add(contra.SBQQ__Opportunity__r.SBQQ__RenewedContract__c);
                }//End of IF
                if(contra.SBQQ__Opportunity__c !=null){
                    futureOpptyids.add(contra.SBQQ__Opportunity__c);
                }//End of IF
            }//End of FOR loop

            map<id,contract> RenewedcontractMap = new map<id,contract>([SELECT id,startdate,name,SBQQ__Opportunity__c,SBQQ__Opportunity__r.Prior_Opportunity__c,SBQQ__Opportunity__r.type,SBQQ__Opportunity__r.SBQQ__RenewedContract__c ,SBQQ__Quote__r.SBQQ__LineItemsGrouped__c,(SELECT id,name, SBQQ__Contract__c,SBQQ__Product__c,SBQQ__Product__r.productcode,Product_Name__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__QuoteLine__c,Subscription_Product_Code__c FROM SBQQ__Subscriptions__r),(SELECT id,name,Purpose__c,Associated_Bundle__c,SBQQ__CurrentSubscription__c,Contract__c,recordtypeid ,Product2.ProductCode,Opportunity__r.Migration__c,Latest_Opportunity__r.Migration__c,Contract__r.Primary_Asset__c,Contract__r.Primary_Asset__r.purpose__c, Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c,
            Contract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c FROM Assets__r) FROM Contract WHERE id IN : renewedContractIds]);
            
            map<id,list<Asset>> PriorOpptyToAssetMap      = new  map<id,list<Asset>>();
            map<id,list<Asset>> PriorOpptyToPartnerAssetMap      = new  map<id,list<Asset>>();
            map<id,list<Asset>> PriorOpptyToSANDAssetMap  = new  map<id,list<Asset>>();
            map<id,list<Asset>> PriorOpptyToRTPAssetMap   = new  map<id,list<Asset>>();
            map<id,Asset> assetMap                        = new  map<id,Asset>();
            set<id> oldAssetIds                           = new set<id>();
            boolean oldToNewAssetUpdate                   = false;
            list<Entitlement> updateEntitlementListWithNewAsset = new list<Entitlement>();
            Map<Id,Id> OldEntIdWithNewEntId = new Map<Id,Id>();

            if(!currentOppPriorOppMap.isEmpty()){
                /* ****************************************************************************
                    Modified By : Priyanka Shende, Jade Global Inc, on 6th June 2017
                    Modified below SOQL to cover below scenarios:
                        1. Expired asset not pick in old to new conversion.
                ******************************************************************************* */
                for(Asset Aset:[SELECT id ,Contract__c,Purpose__c,Production_Asset__r.purpose__c,status,Acct_Prefix__c,POD__c,UsageEndDate,Munchkin_ID__c,Opportunity__c,InstallDate,Subscription_Type__c,Product_Code__c,Product2.ProductCode,Associated_Bundle__c,latest_Opportunity__c,Contract__r.SBQQ__Quote__r.Rubiks_Quote__c,Opportunity__r.Migration__c,Latest_Opportunity__r.Migration__c,Contract__r.Primary_Asset__c,Contract__r.Primary_Asset__r.purpose__c,Contract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c,Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c,(SELECT id,assetid,StartDate,EndDate FROM Entitlements ) FROM Asset WHERE (Opportunity__c IN :currentOppPriorOppMap.values() OR Latest_Opportunity__c IN : futureOpptyids) AND  Acct_Prefix__c!= null and Status='Active']){
                    // Modified by Jade Team on 20th April 2016 for Production Asset
                    if(aset.Purpose__c!=null && aset.Purpose__c.contains('Production') && aset.Munchkin_ID__c!=null){
                        if(PriorOpptyToAssetMap.containsKey(Aset.Opportunity__c)){
                            PriorOpptyToAssetMap.get(Aset.Opportunity__c).add(aset);
                        }//End of IF
                        else{
                            PriorOpptyToAssetMap.put(Aset.Opportunity__c,new list<Asset>{aset});
                        }//End of ELSE
                        if(Aset.latest_Opportunity__c !=null){
                            if(PriorOpptyToAssetMap.containsKey(Aset.latest_Opportunity__c)){
                                PriorOpptyToAssetMap.get(Aset.latest_Opportunity__c).add(aset);
                            }//End of IF
                            else{
                                PriorOpptyToAssetMap.put(Aset.latest_Opportunity__c,new list<Asset>{aset});
                            }//End of ELSE
                        }//End of IF
                    }//End of IF
                    if(Aset.Subscription_Type__c=='Real Time Personalization'){
                        if(PriorOpptyToRTPAssetMap.containsKey(Aset.Opportunity__c)){
                            PriorOpptyToRTPAssetMap.get(Aset.Opportunity__c).add(aset);
                        }//End of IF
                        else{
                            PriorOpptyToRTPAssetMap.put(Aset.Opportunity__c,new list<Asset>{aset});
                        }//End of ELSE
                        if(Aset.latest_Opportunity__c !=null){
                            if(PriorOpptyToRTPAssetMap.containsKey(Aset.latest_Opportunity__c)){
                                PriorOpptyToRTPAssetMap.get(Aset.latest_Opportunity__c).add(aset);
                            }//End of IF
                            else{
                                PriorOpptyToRTPAssetMap.put(Aset.latest_Opportunity__c,new list<Asset>{aset});
                            }//End of ELSE
                        }//End of IF
                    }//End of IF
                    if(aset.Purpose__c =='Sandbox'){
                        if(PriorOpptyToSANDAssetMap.containsKey(Aset.Opportunity__c)){
                            PriorOpptyToSANDAssetMap.get(Aset.Opportunity__c).add(aset);
                        }//End of IF
                        else{
                            PriorOpptyToSANDAssetMap.put(Aset.Opportunity__c,new list<Asset>{aset});
                        }//End of ELSE
                        if(Aset.latest_Opportunity__c !=null){
                            if(PriorOpptyToSANDAssetMap.containsKey(Aset.latest_Opportunity__c)){
                                PriorOpptyToSANDAssetMap.get(Aset.latest_Opportunity__c).add(aset);
                            }//End of IF
                            else{
                                PriorOpptyToSANDAssetMap.put(Aset.latest_Opportunity__c,new list<Asset>{aset});
                            }//End of ELSE
                        }//End of IF
                    }//End of IF
                }//End of FOR
            }//End of IF block of PriorOppoty 
            
            system.debug('contractMap==============='+contractMap);
            system.debug('PriorOpptyToRTPAssetMap==='+PriorOpptyToRTPAssetMap);
            system.debug('PriorOpptyToAssetMap==='+PriorOpptyToAssetMap);
            system.debug('PriorOpptyToSANDAssetMap==='+PriorOpptyToSANDAssetMap);
            
            
           
            for(contract contra: contractMap.values()){
                system.debug('contra.Assets__r==============='+contra.Assets__r);
                if(!contra.Assets__r.isempty() ){ 
                  for(Asset  aset : contra.Assets__r){
                    system.debug('contra.SBQQ__Subscriptions__r==============='+contra.SBQQ__Subscriptions__r);
                    
                     //To Update the New Steel Brick Asset by Old Asset fields
                     if(aset.accountid!=null && aset.Contract__c!=null &&  contra.SBQQ__Opportunity__c!=null /* && contra.SBQQ__Opportunity__r.Prior_Opportunity__c!=null*/){
                         system.debug('aset.Product2.ProductCode========'+aset.Product2.ProductCode);
                        
                         if(aset.Product2.ProductCode!=null && !aset.Product2.ProductCode.contains('SAND') && (( contra.SBQQ__Opportunity__r.Prior_Opportunity__c!=null && PriorOpptyToAssetMap.containsKey(contra.SBQQ__Opportunity__r.Prior_Opportunity__c) ) || PriorOpptyToAssetMap.containsKey(contra.SBQQ__Opportunity__c)) && !aset.Product2.ProductCode.contains('RTP') && aset.Purpose__c!=null && aset.Purpose__c.contains('Production')){
                             list<AssetSortByInstalledEndDate> AssetSortByDateList  = new list<AssetSortByInstalledEndDate>();
                               list<Asset> ProdAssetList = new list<asset>();
                               map<id,Asset> oldAssetMap = new map<id,asset>();
                              if(PriorOpptyToAssetMap.containsKey(contra.SBQQ__Opportunity__r.Prior_Opportunity__c)){
                                  ProdAssetList.addAll(PriorOpptyToAssetMap.get(contra.SBQQ__Opportunity__r.Prior_Opportunity__c));
                                  system.debug('ProdAssetList======PRIOR========='+ProdAssetList);
                                  
                                }//End of IF
                              if(PriorOpptyToAssetMap.containsKey(contra.SBQQ__Opportunity__c)){
                                   ProdAssetList.addAll(PriorOpptyToAssetMap.get(contra.SBQQ__Opportunity__c));
                                    system.debug('ProdAssetList======CURR========='+ProdAssetList);
                                 
                                }//End of IF
                              for(Asset OldAsset :ProdAssetList){
                                  oldAssetMap.put(OldAsset.id,OldAsset);
                                }//End of FOR
                              system.debug('oldAssetMap======CURR========='+oldAssetMap);
                                for(Asset OldAsset :oldAssetMap.values()){ 
                                     if(OldAsset.Acct_Prefix__c!=null ){
                                        AssetSortByDateList.add(new AssetSortByInstalledEndDate(OldAsset));
                                        system.debug('OldAsset======OldAsset========='+OldAsset);
                                    }//End of IF
                                 }//End of Asset FOR Loop
                              //Modified by :Rajesh Wani,8th Dec 2015 to avoid the Exception in below lines
                              // Added IF condition to check the list AssetSortByDateList
                             if(!AssetSortByDateList.isEmpty()){
                                   AssetSortByDateList.sort();
                                   system.debug('AssetSortByDateList======OldAsset========='+AssetSortByDateList);
                                   Asset OldAssetOpp  = AssetSortByDateList[0].asst;
                                   updateassetList.addAll(populateOldAssetData(new list<Asset>{aset,OldAssetOpp}));
                                   System.debug('@@@@@@@@ 1 @@@@@@@@@ : '+updateassetList);
                                     if(oldAssetMap.containsKey(OldAssetOpp.id)){
                                          Asset OldAssetOppWithEnt  = oldAssetMap.get(OldAssetOpp.id);
                                         if(!OldAssetOppWithEnt.Entitlements.isEmpty()){
                                             for(Entitlement ent :OldAssetOppWithEnt.Entitlements){
                                                 ent.assetid= aset.id;
                                            for(Entitlement  e : contra.Entitlements__r){
                                                //Compairing old Entitlement dates with new Entitlement dates
                                                if( ent.StartDate<=e.StartDate && ent.EndDate==e.EndDate ){
                                                    //Expire old Entitlement
                                                    ent.EndDate=(system.Today()-1 < ent.StartDate)? system.Today():system.Today()-1;
                                                    OldEntIdWithNewEntId.put(ent.Id,e.Id);
                                                }//End of If
                                            }//End of FOR loop of e
                                                 updateEntitlementListWithNewAsset.add(ent);
                                             }//End of FOR loop of Ent
                                        }//End of IF
                                     }//End of IF block
                                   assetMap.put(OldAssetOpp.id,OldAssetOpp);
                                   assetMap.put(aset.id,aset);
                                   oldToNewAssetUpdate = true;
                             }//End IF block 
                                 
                        
       }else if(aset.Product2.ProductCode!=null && aset.Product2.ProductCode.contains('RTP') && ((contra.SBQQ__Opportunity__r.Prior_Opportunity__c!=null && PriorOpptyToRTPAssetMap.containsKey(contra.SBQQ__Opportunity__r.Prior_Opportunity__c) )|| PriorOpptyToRTPAssetMap.containsKey(contra.SBQQ__Opportunity__c)) ){
                             list<Asset> RTPProdAssetList  = new list<Asset>(); 
                             list<AssetSortByInstalledEndDate> RTPAssetSortByDateList  = new list<AssetSortByInstalledEndDate>();
                              map<id,Asset> oldAssetMap = new map<id,asset>();
                              if(PriorOpptyToRTPAssetMap.containsKey(contra.SBQQ__Opportunity__r.Prior_Opportunity__c)){
                                  RTPProdAssetList.addAll(PriorOpptyToRTPAssetMap.get(contra.SBQQ__Opportunity__r.Prior_Opportunity__c));
                                }//End of IF
                              else if(PriorOpptyToRTPAssetMap.containsKey(contra.SBQQ__Opportunity__c)){
                                   RTPProdAssetList.addAll(PriorOpptyToRTPAssetMap.get(contra.SBQQ__Opportunity__c));
                                }//End of ELSE-IF
                              for(Asset OldAsset :RTPProdAssetList){
                                  oldAssetMap.put(OldAsset.id,OldAsset);
                                }//End of FOR
                             for(Asset OldAsset :oldAssetMap.values()){
                                     if(OldAsset.Acct_Prefix__c!=null ){
                                        RTPAssetSortByDateList.add(new AssetSortByInstalledEndDate(OldAsset));
                                    }//End of IF
                                 }//End of Asset FOR Loop
                            //Modified by :Rajesh Wani,8th Dec 2015 to avoid the Exception in below lines
                            // Added IF condition to check the 
                             if(!RTPAssetSortByDateList.isEmpty()){
                   //modified by Jade Team on 12th April 2017, added sort statement
                 RTPAssetSortByDateList.sort();
                                 Asset OldAsset = RTPAssetSortByDateList[0].asst;
                                 updateassetList.addAll(populateOldAssetData(new list<Asset>{aset,OldAsset}));
                                 System.debug('@@@@@@@@ 2 @@@@@@@@@ : '+updateassetList);
                                  if(oldAssetMap.containsKey(OldAsset.id)){
                                          Asset OldAssetOppWithEnt  = oldAssetMap.get(OldAsset.id);
                                        system.debug('Old Ent==============='+OldAssetOppWithEnt.Entitlements);
                                         if(!OldAssetOppWithEnt.Entitlements.isEmpty()){
                                             for(Entitlement ent :OldAssetOppWithEnt.Entitlements){
                                                 ent.assetid= aset.id;
                                                for(Entitlement  e : contra.Entitlements__r){ 
                                                //Comparing old Entitlement dates with new Entitlement dates
                                                    if( ent.StartDate<=e.StartDate && ent.EndDate==e.EndDate ){
                                                        //Expire old Entitlement
                                                        ent.EndDate=(system.Today()-1 < ent.StartDate)? system.Today():system.Today()-1;
                                                        //add old entitlement id with its correct entitlement id
                                                        OldEntIdWithNewEntId.put(ent.Id,e.Id);
                                                    }//End of IF
                                                }//End of FOR loop of e
                                                 updateEntitlementListWithNewAsset.add(ent);
                                             }//End of FOR loop of Ent
                                        }//End of IF
                                   }//End of IF block
                                  assetMap.put(oldAsset.id,oldAsset);
                                  assetMap.put(aset.id,aset);
                                  oldToNewAssetUpdate = true;
                             }//End If block
                              
                         }
                         else if (aset.Product2.ProductCode!=null && aset.Product2.ProductCode.contains('SAND') && ((contra.SBQQ__Opportunity__r.Prior_Opportunity__c!=null && PriorOpptyToSANDAssetMap.containsKey(contra.SBQQ__Opportunity__r.Prior_Opportunity__c)) || PriorOpptyToSANDAssetMap.containsKey(contra.SBQQ__Opportunity__c))){
                           list<Asset> SandAssetList = new list<asset>();
                           Map<Id,Asset> oldsandboxAssetMap = new Map<Id,Asset>();
                           list<AssetSortByInstalledEndDate> sandboxAssetSortByDateList  = new list<AssetSortByInstalledEndDate>();
   
                              if(PriorOpptyToSANDAssetMap.containsKey(contra.SBQQ__Opportunity__r.Prior_Opportunity__c)){
                                  SandAssetList.addAll(PriorOpptyToSANDAssetMap.get(contra.SBQQ__Opportunity__r.Prior_Opportunity__c));
                                }//End of IF
                              else if(PriorOpptyToSANDAssetMap.containsKey(contra.SBQQ__Opportunity__c)){
                                   SandAssetList.addAll(PriorOpptyToSANDAssetMap.get(contra.SBQQ__Opportunity__c));
                                }//End of ELSE-IF
                              for(Asset OldAsset :SandAssetList){
                                  oldsandboxAssetMap.put(OldAsset.id,OldAsset);
                                }//End of FOR
                             // Sort Sandbox Assets
                             for(Asset OldAsset :oldsandboxAssetMap.values()){
                                 if(OldAsset.Acct_Prefix__c!=null ){
                                     sandboxAssetSortByDateList.add(new AssetSortByInstalledEndDate(OldAsset));
                                    }//End of IF
                                }//End of Asset FOR Loop                                                         
                                Asset oldSandAsset;
                                if(!sandboxAssetSortByDateList.isEmpty()){
                                    sandboxAssetSortByDateList.sort();
                                    oldSandAsset = sandboxAssetSortByDateList[0].asst;
                                    updateassetList.addAll(populateOldAssetData(new list<Asset>{aset,oldSandAsset}));
                                    System.debug('@@@@@@@@ 3 @@@@@@@@@ : '+updateassetList);
                                    assetMap.put(oldSandAsset.id,oldSandAsset);
                                    assetMap.put(aset.id,aset);
                                    oldToNewAssetUpdate = true; 
                                }//End of IF
                            }//End of ELSE-IF                                                
                        }//End of Asset check for Prior Opportunity
                        for(SBQQ__Subscription__c sub :  contra.SBQQ__Subscriptions__r){

                            //************************* InstallDate Logic For Rubiks Quotes *************
                            //For Rubik Asset to Populate InstallDate
                            //Below If Loop added by Jade for APPS-7452 on 7th April 2016 
                            if(contra.SBQQ__Quote__c != Null){
                                if(contra.SBQQ__Quote__r.Rubiks_Quote__c == TRUE || (aset.Latest_Opportunity__c==null || aset.Opportunity__c==null)){
                                    Asset asetToUpdate = aset;
                                    if(assetMap.containskey(aset.id)){
                                        asetToUpdate  = assetMap.get(aset.id);
                                    }//End Of IF
                                    if(oldToNewAssetUpdate==false){
                                        asetToUpdate.InstallDate =  contra.StartDate;
                                    }//End Of IF

                                    asetToUpdate.Latest_Opportunity__c = contra.SBQQ__RenewalOpportunity__c;

                                    if((sub.SBQQ__Product__r.productcode).contains('BNDL') && contra.SBQQ__Quote__r.Rubiks_Quote__c == TRUE){
                                        asetToUpdate.SBQQ__CurrentSubscription__c = sub.Id;
                                    }//End of IF

                                    if(!assetMap.containskey(asetToUpdate.id)){
                                        updateassetList.add(asetToUpdate);
                                        assetMap.put(asetToUpdate.id,asetToUpdate);
                                    }//End Of IF    
                                }//End of IF                     
                            }//End Of MAIN IF
                            //************************* InstallDate Logic For Rubiks Quotes Ends************* 

                            else if(sub.SBQQ__Product__r.productcode == aset.Associated_Bundle__c && aset.recordtypeid == assetCPQInstanceId){

                                Asset asetNew = aset;
                                if(assetMap.containskey(aset.id)){
                                    asetNew  = assetMap.get(aset.id);
                                }//End of IF
                                asetNew.SBQQ__CurrentSubscription__c = sub.Id;
                                if(oldToNewAssetUpdate==false){
                                    asetNew.InstallDate                  =  sub.SBQQ__StartDate__c;
                                }//End of IF

                                system.debug('updateassetList=======SUB=BEFORE========'+updateassetList);
                                if(!assetMap.containskey(aset.id)){
                                    updateassetList.add(asetNew);
                                }//End of IF
                                system.debug('updateassetList=======SUB===AFTER======'+updateassetList);

                                break;
                            }//End of IF block
                        }//End of FOr loop of SBQQ__ProductOption__c
                    }//End of For loop of asset
                }//End of IF  loop of asset
                if(contra.SBQQ__Opportunity__r.type=='Renewal' && contra.SBQQ__Opportunity__r.SBQQ__RenewedContract__c!=null){
                        if( RenewedcontractMap.containsKey(contra.SBQQ__Opportunity__r.SBQQ__RenewedContract__c)){
                             contract RenewalContra =  RenewedcontractMap.get(contra.SBQQ__Opportunity__r.SBQQ__RenewedContract__c);
                              if(!RenewalContra.Assets__r.isempty() ){
                                 id renewalContractid;
                                for(Asset  aset : RenewalContra.Assets__r){
                                    
                                    Asset asetNew = aset;
                                    if(assetMap.containskey(aset.id)){
                                        asetNew  = assetMap.get(aset.id);
                                }//End of IF
                                    for(SBQQ__Subscription__c sub :  contra.SBQQ__Subscriptions__r){
                                        
                                        if(sub.SBQQ__Product__r.productcode == aset.Associated_Bundle__c && aset.recordtypeid == assetCPQInstanceId){
                                            aset.SBQQ__CurrentSubscription__c = sub.Id;
                                              if(oldToNewAssetUpdate==false){
                                                asetNew.InstallDate                  =  sub.SBQQ__StartDate__c;
                                        }//End of IF
                                           
                                            asetNew.Contract__c                  =  contra.id;
                                         
                                            renewalContractid                 = contra.id;
                                            if(!assetMap.containskey(aset.id)){
                                                updateassetList.add(asetNew);
                                        }//End of IF
                                           
                                              
                                            break;
                                            
                                        }//End of IF block
                                    }//End of FOr loop of SBQQ__ProductOption__c
                                    
                                }//End of FOR loop of asset
                                if(renewalContractid!=null && !updateassetList.isEmpty()){
                                    for(Asset aset : RenewalContra.Assets__r){
                                        system.debug('aset==============================='+aset);
                                         Asset asetNew = aset;
                                        if(assetMap.containskey(aset.id)){
                                            asetNew  = assetMap.get(aset.id);
                                    }//End of IF
                                       
                                       if( aset.Contract__c != renewalContractid){
                                         aset.Contract__c   = renewalContractid;
                                           if( !RenewedcontractMap.containsKey(contra.SBQQ__Opportunity__r.SBQQ__RenewedContract__c)){
                                               contract Renewalcontract = RenewedcontractMap.get(contra.SBQQ__Opportunity__r.SBQQ__RenewedContract__c);
                                               
                                                system.debug('Renewalcontract.SBQQ__Subscriptions__r==============================='+Renewalcontract.SBQQ__Subscriptions__r);
                                               
                                               for(SBQQ__Subscription__c sub :  Renewalcontract.SBQQ__Subscriptions__r){
                                                   if(aset.Product2.ProductCode == sub.Subscription_Product_Code__c){
                                                     asetNew.SBQQ__QuoteLine__c  =sub.SBQQ__QuoteLine__c;
                                                }//End of IF
                                            }//End of FOR
                                        }//End of IF
                                           if(!assetMap.containskey(aset.id)){
                                                updateassetList.add(asetNew);
                                        }//End of IF
                                    }//End of IF
                                }//End of FOR
                            }//End of IF
                        }//End of IF Block of asset 
                    }//End of IF
                
                }//End of Renewal Contract block
            }//End of Contract FOR loop
            system.debug('updateassetList================'+updateassetList);

            
           list<asset> oldassetstoupdate= new list<asset>();
           list<asset> newassetstoupdate= new list<asset>();
           
                for(Asset ast : updateassetList){ 
                     if(ast.Contract__c == NULL || (ast.Acct_Prefix__c == null && ast.Munchkin_ID__c == null)){                
                          oldassetstoupdate.add(ast);  
                     } else{                        
                         newassetstoupdate.add(ast);
                }//End of IF-ELSE
            }//End of FOR
                if(!oldassetstoupdate.isEmpty()){           
                    update oldassetstoupdate;
            }//End of IF
                System.debug('oldassetstoupdate****************'+oldassetstoupdate);
            
               if(!newassetstoupdate.isEmpty()){  
               System.debug('@@@@@@@@@@@@@@@@@ newassetstoupdate @@@@@@@@@@@@@@@ : '+newassetstoupdate);
               system.debug('updateEntitlementListWithNewAsset================'+updateEntitlementListWithNewAsset);
               
                update newassetstoupdate;
            }//End of IF
              System.debug('newassetstoupdate****************'+newassetstoupdate);
            
            //Updating Entitlement changing Old Asset to New Asset
            if(!updateEntitlementListWithNewAsset.isEmpty()){
                update updateEntitlementListWithNewAsset;
                if(!OldEntIdWithNewEntId.isEmpty()){
                    //Move Authorized Contacts And Cases of old Entitlement to new Entitlement
                    MoveAuthorizedContactAndCases(OldEntIdWithNewEntId);
                }//End of IF
            }//End of IF
            }//End of IF block
        //End of IF block of Contracts 
     
        
    }//End of Method UpdateAsset
    
    //Move Authorized Contacts And Cases of old Entitlement to new Entitlement
    public static void MoveAuthorizedContactAndCases(Map<Id,Id> OldEntIdWithNewEntId) {
       try{

            Set<Id> OldEntIdSet= new Set<Id>();
            Set<Id> NewEntIdSet= new Set<Id>();
            list<Authorized_Contact__c> AuthConListOld= new list<Authorized_Contact__c>();
            list<Case> CaseToBeUpdate= new list<Case>();
            list<Case> CaseList= new list<Case>();          
            list<Authorized_Contact__c> AuthConListToBeUpdate= new list<Authorized_Contact__c>();
            Set<Id> EntWithAdmin= new Set<Id>();
            Set<Id> AlreadyAdded= new Set<Id>();  
            map<Id,Entitlement> EntMap=new map<Id,Entitlement>();
            Set<Id> EntilementToBeUpdate= new Set<Id>();
            List<Entitlement> EntilementToBeUpdateList= new List<Entitlement>();
            //take all old expired entitlement ids
            OldEntIdSet=OldEntIdWithNewEntId.keySet();
            
            if(!OldEntIdSet.isEmpty()){
                for(Id entId:OldEntIdSet){
                    //take all new entitlement id
                    NewEntIdSet.add(OldEntIdWithNewEntId.get(entId));
                }
            }
            
            
            
            //query all old and new Entitlement and its related authorized contacts and cases
            List<Entitlement> NewEntList=[SELECT AccountId,Account.Name,AssetId,Asset.Opportunity__c,Asset.Opportunity__r.Type,Asset_Status__c,Contract__c,SlaProcess.Name,EndDate,Name,Processed_for_grace__c,Subscription_End_Date__c,Entitlement_Status__c,Id,StartDate,Status,createdDate,Contract__r.StartDate,Contract__r.EndDate,Contract__r.SBQQ__Quote__r.SBQQ__PriceBook__c,Opportunity__r.Migration__c,Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Primary_Marketo_User_Lookup__c,(Select id, Entitlement__r.AccountId,Entitlement__c,Customer_Admin__c,Entitlement__r.AssetId,Entitlement__r.StartDate,Entitlement__r.EndDate,Entitlement__r.Account.Name,Contact__r.Account.Name,Contact__r.AccountId From Authorized_Contacts__r ),(Select id,EntitlementId,AccountId,Status,Entitlement.AssetId,Entitlement.StartDate,Entitlement.EndDate,Entitlement.Account.Name from Cases where Status!='Closed') FROM Entitlement WHERE ID IN:NewEntIdSet OR  ID IN:OldEntIdSet];
            
            
            //Code added to check new entitlement having customer admin in authorized contact 
            for(Entitlement en:NewEntList){
                    EntMap.put(en.Id,en);       
                if(NewEntIdSet.contains(en.Id) && en.Status=='Active'){    
                    if(en.Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Primary_Marketo_User_Lookup__c != null){
                        EntWithAdmin.add(en.Id);
                    }// End Of If Loop
                }// End Of If Loop
            }// End Of For Loop
        
            
            for(Entitlement en:NewEntList){  
                if(OldEntIdSet.contains(en.Id) && en.Status=='Expired'){
                        AuthConListOld=en.Authorized_Contacts__r;
                        CaseList=en.Cases;
                        //code added to move authorized contacts
                        if(!AuthConListOld.IsEmpty()){
                            for(Authorized_Contact__c ac:AuthConListOld){
                                
                                if(ac.Customer_Admin__c==true && OldEntIdWithNewEntId.containsKey(ac.Entitlement__c) && EntWithAdmin.contains(OldEntIdWithNewEntId.get(ac.Entitlement__c))  ){
                                    ac.Customer_Admin__c=false;
                                    ac.Entitlement__c=OldEntIdWithNewEntId.get(ac.Entitlement__c);
                                    AuthConListToBeUpdate.add(ac);
                                }// End Of If Loop                
                                else if(OldEntIdWithNewEntId.containsKey(ac.Entitlement__c)){ 
                                    ac.Entitlement__c=OldEntIdWithNewEntId.get(ac.Entitlement__c);
                                    AuthConListToBeUpdate.add(ac);
                                }// End Of If Loop            
                            }// End Of If Loop
                        }// End Of If Loop
                        //code added to move Cases
                        if(!CaseList.IsEmpty()){
                            for(Case cs:CaseList){
                                if(OldEntIdWithNewEntId.containsKey(cs.EntitlementId)){
                                    cs.EntitlementId=OldEntIdWithNewEntId.get(cs.EntitlementId);
                                    CaseToBeUpdate.add(cs);
                                }// End Of If Loop
                            }// End Of for Loop
                        }// End Of If Loop            
                }// End Of If Loop   
            }// End Of for Loop
            
            if(!AuthConListToBeUpdate.isEmpty()){
                Database.SaveResult[] SRCon = Database.update( AuthConListToBeUpdate, False);
                for(Integer i=0;i<SRCon.size();i++){
                    if(!SRCon[i].isSuccess()){
                        EntilementToBeUpdate.add(AuthConListToBeUpdate[i].Entitlement__c);
                    }//End of If loop
                }//ENd of For Loop
            }//End of If Block
            if(!CaseToBeUpdate.isEmpty()){
                Database.SaveResult[] SRCase = Database.update( CaseToBeUpdate, False);
                for(Integer i=0;i<SRCase.size();i++){
                    if(!SRCase[i].isSuccess()){
                        EntilementToBeUpdate.add(CaseToBeUpdate[i].EntitlementId);
                    }//End of If look
                }//End of For
            }//End of If Loop
            
            for(Entitlement en:NewEntList){
                if(EntilementToBeUpdate.contains(en.Id)){
                    en.Failed_AuthCon_Case_Update__c=True;
                    EntilementToBeUpdateList.add(en);
                }//End of If loop
            }//End of For loop
             
            if(!EntilementToBeUpdateList.isEmpty()){
                Update EntilementToBeUpdateList;
            }//End of If Loop
        
        }//End Of try Block
        catch(Exception e){
                System.debug('Exception Found =================='+e.getMessage());
                System.debug('Exception Found =================='+e.getLineNumber());
                System.debug('Exception Found =================='+e.getcause()); 
        }//End of catch block
    }//End of method MoveAuthorizedContactAndCases()
    public static void createAuthorizedContact(List<Entitlement> entList) {
        
           Id SupportRecordTypeId  = Entitlement.sObjectType.getDescribe().getRecordTypeInfosByName().get('Support').getRecordTypeId() ;

        // Collect Entitlement Ids
        Set<Id> entitlementIdsSet = new Set<Id>();
        Set<Id> prevEntitlementIdsSet = new Set<Id>();
        for(Entitlement ent:entList){
            entitlementIdsSet.add(ent.Id);
            if(ent.Previous_Entitlement__c != null){
                prevEntitlementIdsSet.add(ent.Previous_Entitlement__c);
            }//End of IF
        }//End of FOR
        list<Authorized_Contact__c> AuthContact=new list<Authorized_Contact__c>();
        for(Authorized_Contact__c autContact :[SELECT Entitlement__c,Contact__c FROM Authorized_Contact__c WHERE Entitlement__c IN : entitlementIdsSet]){
            if(!EntitlementIdsForAuthContact.contains(autContact.Entitlement__c)){
          entitlementIdsSet.remove(autContact.Entitlement__c);
            }else{
                autContact.Customer_Admin__c = false;
                AuthContact.add(autContact);
            }
        }//End of FOR
        /****************************************************************************************
          Modified By : Priyanka Shende, Jade Global Inc, on 5th July 2017
          Purpose     : Renewal opp primary contact becomes admin 
         *************************************************************************************** */
        if(!AuthContact.isEmpty()){
            update AuthContact;
        }
        Map<Id,List<Authorized_Contact__c>> entIdAuthContactsMap = new Map<Id,List<Authorized_Contact__c>>();
        for(Authorized_Contact__c autContact :[SELECT id,Entitlement__c,Contact__c FROM Authorized_Contact__c WHERE Entitlement__c IN :prevEntitlementIdsSet]){
            if(entIdAuthContactsMap.containsKey(autContact.Entitlement__c)){
                entIdAuthContactsMap.get(autContact.Entitlement__c).add(autContact);
            }else{
                entIdAuthContactsMap.put(autContact.Entitlement__c,new List<Authorized_Contact__c>{autContact});
            }//End of IF-ELSE
        }//End of FOR
        
        // Create Authorized Contacts
        List<Authorized_Contact__c> authorizedContactList = new List<Authorized_Contact__c>();
        Authorized_Contact__c ac;
        for(Entitlement ent: [Select id,Previous_Entitlement__c, Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Type,Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Primary_Marketo_User_Lookup__c, Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__c FROM Entitlement WHERE id IN : entitlementIdsSet AND Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Primary_Marketo_User_Lookup__c != null AND RecordTypeId=:SupportRecordTypeId]){                       
            ac = new Authorized_Contact__c();                   
            ac.Contact__c = ent.Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__Opportunity2__r.Primary_Marketo_User_Lookup__c;                   
            ac.Entitlement__c = ent.id;
            ac.Customer_Admin__c = true;
            authorizedContactList.add(ac);  
        }//End of FOR 
        system.debug('authorizedContactList'+authorizedContactList);
        // Insert Authorized Contacts
        if(!authorizedContactList.isEmpty()){
            try{
                insert authorizedContactList;
            }catch(ListException listExcept){
                System.debug(listExcept.getMessage()); 
            }//End of Try-Catch       
        }//End of IF   
} // End - createAuthorizedContact()      

    public list<Asset> populateOldAssetData(list<Asset> populateAssetRec){
        list<Asset> UpdateAsset  = new   list<Asset>();
        Asset    aset;
        Asset OldAsset;
        //prepare contract and its primary asset map
        if(!populateAssetRec.isEmpty()){
            for(Asset ast: populateAssetRec){
                if(ast.Contract__c!=null & ast.Contract__r.Primary_Asset__r.purpose__c!=null){
                    ContractAndProdAssetPurposeMap.put(ast.Contract__c,ast.Contract__r.Primary_Asset__r.purpose__c);
                }//End of IF
                system.debug('########ContractAndProdAssetPurposeMap'+ContractAndProdAssetPurposeMap);
            }//End of FOR
        }//End of IF
        system.debug('########After loop ContractAndProdAssetPurposeMap'+ContractAndProdAssetPurposeMap);
        aset   = populateAssetRec[0];
        OldAsset  = populateAssetRec[1];
        
           aset.Acct_Prefix__c       = OldAsset.Acct_Prefix__c;
           aset.POD__c               = OldAsset.POD__c;
           aset.Munchkin_ID__c       = OldAsset.Munchkin_ID__c;
           aset.InstallDate          =  oldAsset.InstallDate;
           aset.name                 = aset.Acct_Prefix__c +'-'+aset.Purpose__c;
        //Added check by Jade Team on 4th may 2017
        //Purpose - exclude migration assets - on migration asset not set the provisioning status as completed, we are provisioning migration asset manually.   
        if(aset.Opportunity__r.Migration__c!=True){
            aset.Provision_Status__c  = 'Completed';
        }//End of IF

        system.debug('######## ContractAndProdAssetPurposeMap.get(aset.Contract__c)'+ContractAndProdAssetPurposeMap.get(aset.Contract__c));
        system.debug('##### aset.purpose__c'+aset.purpose__c);
        system.debug('##### oldAsset.Contract__r.SBQQ__Quote__r.Rubiks_Quote__c'+oldAsset.Contract__r.SBQQ__Quote__r.Rubiks_Quote__c);
        system.debug('##### oldAsset.Contract__c'+ oldAsset.Contract__c);
        if((aset.Opportunity__r.Migration__c!=True ) && ((aset.purpose__c=='Rubiks Production' && (aset.Contract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c==false || aset.Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c == false) && oldAsset.purpose__c=='Production')||(aset.purpose__c=='Sandbox' && ContractAndProdAssetPurposeMap.containsKey(aset.Contract__c) && ContractAndProdAssetPurposeMap.get(aset.Contract__c)=='Rubiks Production' &&  (oldAsset.Contract__r.SBQQ__Quote__r.Rubiks_Quote__c==false || oldAsset.Contract__c==null)))){
            aset.Provisioning_Type__c='Legacy to Rubiks';
            aset.Provision_Status__c  = 'New';
        }//End of IF
        
        if((aset.Opportunity__r.Migration__c!=True ) && aset.Contract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c==false && (oldAsset.Contract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c==false || aset.Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c == false) && ((aset.purpose__c=='Rubiks Production' && oldAsset.purpose__c=='Rubiks Production')||(aset.purpose__c=='Sandbox' && ContractAndProdAssetPurposeMap.containsKey(aset.Contract__c) && ContractAndProdAssetPurposeMap.get(aset.Contract__c)=='Rubiks Production' && (oldAsset.Contract__r.SBQQ__Quote__r.Rubiks_Quote__c==true)))){
            aset.Provisioning_Type__c='Rubiks to Rubiks';
        }//End of IF 
        //Added by Jade to populate provisioning type for Phoenix assets
        if(oldAsset.Contract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c == TRUE && (aset.Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c == TRUE || aset.Contract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c == TRUE )){
            aset.Provisioning_Type__c='Phoenix to Phoenix';
            aset.Provision_Status__c  = 'Completed';
        }
        if(oldAsset.Contract__r.SBQQ__Quote__r.Rubiks_Quote__c == TRUE && (aset.Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c == TRUE || aset.Contract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c == TRUE)){
            aset.Provisioning_Type__c='Rubiks to Phoenix';
            aset.Provision_Status__c  = 'Completed';
        }
        if(((oldAsset.Contract__r.SBQQ__Quote__r.Rubiks_Quote__c == False && aset.Contract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c == FALSE) || oldAsset.Contract__c==null) && (aset.Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c == TRUE || aset.Contract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c == TRUE)){
            aset.Provisioning_Type__c='Legacy to Phoenix';
            aset.Provision_Status__c  = 'Completed';
        }
        
        OldAsset.Status           = 'Expired'; 
        OldAsset.Acct_Prefix__c   = null;
        OldAsset.Munchkin_ID__c   = null;
        OldAsset.POD__c           = null;
          
           UpdateAsset.add(aset);
           UpdateAsset.add(OldAsset);
       
        /********APPS-10505*********/
           if(OldAsset!=null){
           for(Asset ast : [SELECT Id, Status from Asset WHERE (Asset_Type__c = 'Add On' or ((Asset_Type__c = '' or Asset_Type__c =null) and Maximum_Database_Size__c!=null))  AND Status ='Active' AND Parent_Instance__c =:  OldAsset.id]){
                   system.debug('-------------->>>>QUERY-------------->>>>'+ ast);
                   ast.Status = 'Expired';
                   UpdateAsset.add(ast);  
            }//End of FOR
        }//End of IF
        /*********APPS-10505*******/

        return UpdateAsset;
    }//END of method populateOldAsset
       
    
}//End of class