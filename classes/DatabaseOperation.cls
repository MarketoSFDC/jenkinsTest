/**
    TO OVERRIDE THE STANDARD DML OPERATION- IN ORDER TO CONTROL THE EXECUTION- MINIMIZE THE CPU TIME
    -ON DEMAND INVOCATION OF TRIGGER ON ACCOUNT, OPPORTUNITY, CONTACT THAT CUASES LONG RUNNIG EXECUTION CYCLE WITHOYT ANY NEED
**/
public class DatabaseOperation {

    public static void updateAccount(List<Account> accountList, boolean deactivateAllTrigger, boolean optAllOrNone) {
        if(!accountList.isEmpty()){
            if(deactivateAllTrigger){
                Account_MAIN_TriggerHandler.isAccountTriggerExecuted = True;
                Utility.isFutureUpdate = false; 
                Utility.haveRunAlertDatanyzeUpdate = true;  
                Utility.isUpdateContactOwnerAsAccountOwnerRunningOnceMore = true;
                RecurssionOnOppandAccount.isFromupdateUserBadgeTag= false;
            }
            if(optAllOrNone){
                update accountList;
            }else {
                database.update(accountList, false);
            }
        }
    }
    
    public static void updateOpportunity(List<Opportunity> opptyList, boolean deactivateAllTrigger, boolean optAllOrNone){
        if(!opptyList.isEmpty()){
            if(deactivateAllTrigger){
                Trigger_Opportunity_Helper.isBeforeUpdateEvent     = true;
                Trigger_Opportunity_Helper.isAfterUpdateEvent      = true;
            }
            if(optAllOrNone){
                update opptyList;
            }else {
                database.update(opptyList, false);
            }
        }
    
    }
    
    public static void updateOpportunityLineItem(List<OpportunityLineItem> OpptyLineItemList, boolean deactivateAllTrigger, boolean optAllOrNone) {
        if(!OpptyLineItemList.isEmpty()){
            if(deactivateAllTrigger){
                 //LIST OF TRIGGERS TO DEACTIVATE
            }
            if(optAllOrNone){
                update OpptyLineItemList;
            }else {
                database.update(OpptyLineItemList, false);
            }
        }
    }
    
    public static void updateContact(List<Contact> contactToBeUpdatedList, boolean deactivateAllTrigger, boolean optAllOrNone) {
        if(!contactToBeUpdatedList.isEmpty()){
            if(deactivateAllTrigger){
                // LIST OF TRIGGERS TO DEACTIVATE
                ContactTriggerMAINHandler.isTriggerExecuted = True;// Disable the ContactTriggerMAIN
            }
            if(optAllOrNone){
                update contactToBeUpdatedList;
            }else {
                database.update(contactToBeUpdatedList, false);
            }
        }
    }
    
     public static void updateAsset(List<Asset> AssetToBeUpdatedList, boolean deactivateAllTrigger, boolean optAllOrNone) {
        if(!AssetToBeUpdatedList.isEmpty()){
            if(deactivateAllTrigger){
                // LIST OF TRIGGERS TO DEACTIVATE
               Utility.isAssetTriggerExecutedFromOppty = True;// Disable AssetTriggerMAIN
            }
            if(optAllOrNone){
                update AssetToBeUpdatedList;
            }else {
                database.update(AssetToBeUpdatedList, false);
            }
        }
    }
    
}