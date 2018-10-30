/**@@
#TRIGGER NAME          :    TriggerInt_Assignement 
#HANDLER CLASS NAME    :    TriggerInt_Assignement_Handler
#HELPER CLASS NAME     :    TriggerInt_Assignment_Helper
#DESCRIPTION           :    This Trigger will handles all the trigger events and make call to the Handler class to handling the appropriate logic.
#DESIGNED BY           :    Jade Global
@@**/

trigger TriggerInt_Assignement on pse__Assignment__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    if(!(SalesTriggersUtility.marketoTriggerManager.Deactivate_Assignment_Triggers__c)){
        if(trigger.isBefore){
            if(trigger.isInsert){ 
                TriggerInt_Assignement_Handler.beforeInsertHandler(trigger.new, trigger.newMap);
            }
            else if(trigger.isUpdate){
                TriggerInt_Assignement_Handler.beforeUpdateHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            }
            /*else if(trigger.isDelete){
                // Before insert logic...AWAITING FOR A PROCESS.....
                TriggerInt_Assignement_Handler.beforeDeleteHandler(trigger.old, trigger.oldMap);
            }*/
        }else{
            if(trigger.isInsert){
               TriggerInt_Assignement_Handler.afterInsertHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            }
            else if(trigger.isUpdate){
                TriggerInt_Assignement_Handler.afterUpdateHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            }
            /*else if(trigger.isDelete){
                  // Before insert logic...AWAITING FOR A PROCESS.....
                TriggerInt_Assignement_Handler.afterDeleteHandler(trigger.new, trigger.old, trigger.oldMap);
            }
            else if(trigger.isUnDelete){
                  // Before insert logic...AWAITING FOR A PROCESS.....
                TriggerInt_Assignement_Handler.afterUnDeleteHandler(trigger.new, trigger.newMap);
            }*/ 
        }
    }
}