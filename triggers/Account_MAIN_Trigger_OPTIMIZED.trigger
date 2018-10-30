/**
GOAL OF THIS TRIGGER IS TO CONSOLIDATE ALL TRIGGERS INTO SINGLE ONE. 
THIS TRIGGER WILL BE LOGIC LESS, EVENT DRIVEN ONLY. ALL LOGIC WILL WILL BE PERFORMED IN
CORRESPONDING HANDLER AND HELPER ROUTINS.
**PLEASE DO NOT CREATE ANY OTHER TRIGGER, ADD YOUR LOGIC IN HANDLER AND HELPER.
DESIGNED BY: GRAZITTI 
**/

/*********************************************************************
* Last Modified By   : Sumit Bhatt(Grazitti) 11th Jan 2018
* Reference          : *APPS-11571# Create Different fields on Custom Setting Marketo Trigger Management
**************************************************************************/

trigger Account_MAIN_Trigger_OPTIMIZED on Account (before insert, before update, before delete, after insert, after update, after delete){
   
   /**@@ 
      - CODE ADDED BY GRAZITTI TO ENABLE/DISABLE TRIGGER WITHOUT ANY APEX CHANGE AND DEPLOYMENT.
      - MANAGE HERE:- Setup --> Custom Setting --> Marketo Trigger Management --> Manage --> Checkbox "Deactivate Account Triggers"
    @@**/
   if(!(SalesTriggersUtility.marketoTriggerManager.Deactivate_Account_Triggers__c))    
   {
       if(!Account_MAIN_TriggerHandler.isAccountTriggerExecuted){
            if(trigger.isBefore){
                /****** HANDLES ALL BEFORE EVENTS ******/
                if(trigger.isInsert){
                    /****** HANDLES ALL THE BEFORE INSERT EVENTS ******/
                    Account_MAIN_TriggerHandler.beforeInsertHandlerInBulk(trigger.new , trigger.newMap);
                }else if(trigger.isUpdate){
                    /****** HANDLES ALL THE BEFORE UPDATE EVENTS ******/
                    Account_MAIN_TriggerHandler.beforeUpdateHandlerInBulk(trigger.new , trigger.newMap, trigger.old, trigger.oldMap);
                }else {
                    /****** HANDLES ALL THE BEFORE DELETE EVENTS ******/
                    Account_MAIN_TriggerHandler.beforeDeleteHandlerInBulk(trigger.new , trigger.newMap);
                }   
            }else if(trigger.isAfter){
                /****** HANDLES ALL AFTER EVENTS ******/
                if(trigger.isInsert){
                    /****** HANDLES ALL THE AFTER INSERT EVENTS ******/
                    Account_MAIN_TriggerHandler.afterInsertHandlerInBulk(trigger.new , trigger.newMap);
                }else if(trigger.isUpdate){
                    /****** HANDLES ALL THE AFTER UPDATE EVENTS ******/
                    Account_MAIN_TriggerHandler.afterUpdateHandlerInBulk(trigger.new , trigger.newMap, trigger.old, trigger.oldMap);
                }else {
                    /****** HANDLES ALL THE AFTER DELETE EVENTS ******/
                    Account_MAIN_TriggerHandler.afterDeleteHandlerInBulk(trigger.old, trigger.oldMap);
                }
            }
        }
   }
}