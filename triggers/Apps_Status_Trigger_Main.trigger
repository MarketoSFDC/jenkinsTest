trigger Apps_Status_Trigger_Main on AppsStatus__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (trigger.isBefore){
        if(trigger.isInsert || trigger.isUpdate){
            for(AppsStatus__c status : Trigger.new){
                if (status.Bizible_Account_Id__c != NULL){
                    status.Account__c = status.Bizible_Account_Id__c;
                }
            }
        }
    }
}