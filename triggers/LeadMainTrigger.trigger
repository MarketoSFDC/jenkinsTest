trigger LeadMainTrigger on Lead (before insert, before update, after update) {
    
    if(trigger.isBefore){
        if(Trigger.isInsert){
            if(!LeadMainTriggerHandler.isBeforeInsertDone){
                LeadMainTriggerHandler.isBeforeInsertDone = true;
                LeadMainTriggerHandler.BeforeInsertHandler(Trigger.new);
            }
        }
        if(Trigger.isUpdate){
            if(!LeadMainTriggerHandler.isBeforeUpdateDone){
                LeadMainTriggerHandler.isBeforeUpdateDone = true;
                LeadMainTriggerHandler.BeforeUpdateHandler(Trigger.new, Trigger.oldMap);
            }
        }
    }
    if(Trigger.isAfter){
        LeadMainTriggerHandler.SetPrimaryContact(Trigger.new, Trigger.oldMap);
    }
}