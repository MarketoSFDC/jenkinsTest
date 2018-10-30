trigger Sync_with_CC on Legal_Agreements__c (after insert, after update, after delete, after undelete) {
    if(!(SalesTriggersUtility.marketoTriggerManager.Deactivate_Legal_Agreement_Triggers__c)){
        APXT_Redlining.PlatformDataService.sendData(Trigger.old, Trigger.new);
    }
}