/** Goal&Description : This TRIGGER will handle all the trigger events and give call to handler class for running the approriate logic. To avoid multiple trigger on Event object. 
**/
trigger EventTriggerMAIN on Event(before insert, before update, before delete, after insert, after update, after delete) {
   
    if(trigger.isBefore) {
        if(trigger.isInsert){
            ActivitiesTriggerHandler.eventBeforeInsertHandler(Trigger.new);        
        }else       
        if(trigger.isUpdate) {
            ActivitiesTriggerHandler.eventBeforeUpdateHandler(Trigger.new, trigger.oldMap);    
        }else 
        if(trigger.isDelete) {
            ActivitiesTriggerHandler.eventBeforeDeleteHandler(Trigger.Old);
        }
    }else if(trigger.isAfter) {
        if(trigger.isInsert) {
            ActivitiesTriggerHandler.eventAfterInsertHandler(Trigger.new);                
        }else if(trigger.isUpdate) {
            ActivitiesTriggerHandler.eventAfterUpdateHandler(Trigger.new);        
        }else if(trigger.isDelete) {
            ActivitiesTriggerHandler.eventAfterDeleteHandler(Trigger.Old);                
        }       
    } 

}