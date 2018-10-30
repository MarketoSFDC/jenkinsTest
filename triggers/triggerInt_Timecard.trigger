/**@@
#TRIGGER NAME          :    triggerInt_Timecard 
#HANDLER CLASS NAME    :    Trigger_Timecard_Handler
#HELPER CLASS NAME     :    Trigger_Timecard_Helper
#DESCRIPTION           :    This Trigger will handles all the trigger events and make call to the Handler class to handling the appropriate logic.
#DESIGNED BY           :    Jade Global
#LastModifiedBy        :    Jade Global Inc on 23rd May 2018
#Purpose               :    Handled Delete Event
@@**/
trigger triggerInt_Timecard on pse__Timecard__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(!(SalesTriggersUtility.marketoTriggerManager.Deactivate_Timecard_Split_Triggers__c)){

        if(trigger.isBefore){
            if(trigger.isInsert){
                // Before insert logic...AWAITING FOR A PROCESS.....
            }
            else if(trigger.isUpdate){
                Trigger_Timecard_Handler.beforeUpdateHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            }
            else if(trigger.isDelete){
                // Before delete logic...AWAITING FOR A PROCESS.....
            }
        }else{
            if(trigger.isInsert){
                //After Insert Logic......
                Trigger_Timecard_Handler.afterInsertHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            }
            else if(trigger.isUpdate){
                  Trigger_Timecard_Handler.afterUpdateHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            }
             else if(trigger.isDelete){
                  Trigger_Timecard_Handler.afterDeleteHandler(trigger.new, trigger.old, trigger.oldMap);
            }
            
            }
    }
}