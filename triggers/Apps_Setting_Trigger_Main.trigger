trigger Apps_Setting_Trigger_Main on AppsSetting__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if (trigger.isBefore){
        if(trigger.isInsert || trigger.isUpdate){
            for(AppsSetting__c setting : Trigger.new){
                if (setting.Bizible_Account_Id__c != NULL){
                    setting.Account__c = setting.Bizible_Account_Id__c;
                }
            }
        }
    }
}