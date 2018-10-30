/*****************************************************
  * Last Modified By : Jade Team on 11th May 2017
  * Purpose          : commented method populatePrimaryAssetOnContract to not populate the Primary asset on Renewal Contract
  *                    This is handle in Asset trigger.
  *************************************************/
public class ContractTriggerMainHandler{

    public static void isBeforeInsertHandler(List<Contract> newTrigger, Map<Id,Contract> newTriggerMap){

    }
    public static void isBeforeUpdateHandler(List<Contract> newTrigger, Map<Id,Contract> newTriggerMap, List<Contract> oldTrigger, Map<Id, Contract> oldTriggerMap){    }
    public static void isBeforeDeleteHandler(List<Contract> newTrigger, Map<Id,Contract> newTriggerMap){    }
    
    public static void isAfterInsertHandler(List<Contract> newTrigger, Map<Id,Contract> newTriggerMap){
        Map<Id, Decimal> accIdsForGiansightDBSize = new Map<Id, Decimal>();
        for(Contract cot : newTrigger){
            if(cot.Total_Contact_Records__c != null){
                accIdsForGiansightDBSize.put(cot.AccountId, cot.Total_Contact_Records__c);
            }
        }
        
        // Update maximum database size on Account.
        if(!accIdsForGiansightDBSize.isEmpty()){
            SBQQContractAndSubscriptionTriggerHelper.updateProductInfoOnAccountORDatabaseSize(new Set<Id>(), accIdsForGiansightDBSize);
        }
    }
    
    //AFTER UPDATE HNDLER
    public static void isAfterUpdateHandler(List<Contract> newTrigger, Map<Id,Contract> newTriggerMap, List<Contract> oldTrigger, Map<Id, Contract> oldTriggerMap){
        List<SBQQ__Subscription__c> newSubcription = new List<SBQQ__Subscription__c>();
        Set<Id> accIdsForProductInfo     = new Set<Id>();
        Map<Id, Decimal> accIdsForGiansightDBSize = new Map<Id, Decimal>();
        for(Contract cot : newTrigger){
            if(cot.EndDate != oldTriggerMap.get(cot.Id).EndDate){
                 accIdsForProductInfo.add(cot.AccountId);
            }
            if(cot.Total_Contact_Records__c != oldTriggerMap.get(cot.Id).Total_Contact_Records__c){
                accIdsForGiansightDBSize.put(cot.AccountId, cot.Total_Contact_Records__c);
            }
        }
        
        // Update Product Field on Account Depending Upon Active Subscriptions. Also update gainsight database size 
        if(!accIdsForProductInfo.isEmpty() || !accIdsForGiansightDBSize.isEmpty()){
            SBQQContractAndSubscriptionTriggerHelper.updateProductInfoOnAccountORDatabaseSize(accIdsForProductInfo,accIdsForGiansightDBSize);
        }
    }
    
    //AFTER DELETE HNDLER
    public static void isAfterDeleteHandler(List<Contract> newTrigger, Map<Id,Contract> newTriggerMap){    }   
   
}