trigger Apps_Integration_Trigger_Main on AppsIntegration__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(trigger.isBefore){
        if(trigger.isInsert || trigger.isUpdate){
            for(AppsIntegration__c integration : Trigger.new){
                if (integration.Bizible_Account_Id__c != NULL){
                    integration.Account__c = integration.Bizible_Account_Id__c;
                }
            }
        }
    }
}