/** Goal&Description : This TRIGGER will handle all the trigger events and give call to handler class for running the approriate logic. To avoid multiple trigger on Task object. 
**/
trigger TaskTriggerMAIN on Task(before insert, before update, before delete, after insert, after update) {
    
    if(trigger.isBefore) {
        if(trigger.isInsert){
            ActivitiesTriggerHandler.taskBeforeInsertHandler(Trigger.new);        
        }else       
        if(trigger.isUpdate) {
            ActivitiesTriggerHandler.taskBeforeUpdateHandler(Trigger.new, trigger.oldMap);    
        }else 
        if(trigger.isDelete) {
            ActivitiesTriggerHandler.taskBeforeDeleteHandler(Trigger.Old);
        }
    }else if(trigger.isAfter){
        if(trigger.isInsert){
            ActivitiesTriggerHandler.TaskAfterInsertHandler(Trigger.new); 
            ActivitiesTriggerHandler.addInternalCommentForTask(Trigger.new);
        }else if(trigger.isUpdate){
            ActivitiesTriggerHandler.TaskAfterUpdateHandler(Trigger.new);  
        }else if(trigger.isDelete){
            //waiting....             
        }       
    }
 
}