/*********************************************************************
* Last Modified By   : Sumit Bhatt(Grazitti) 11th Jan 2018
* Reference          : *APPS-11571# Create Different fields on Custom Setting Marketo Trigger Management
**************************************************************************/

trigger Contact_Trigger_MAIN_OPTIMIZED on Contact (before insert, before update, after insert, after update, after delete) {

    /**@@ 
      - CODE ADDED BY GRAZITTI TO ENABLE/DISABLE TRIGGER WITHOUT ANY APEX CHANGE AND DEPLOYMENT.
      - MANAGE HERE:- Setup --> Custom Setting --> Marketo Trigger Management --> Manage --> Checkbox "Dectivate Contact Triggers"
    @@**/
    if(!(SalesTriggersUtility.marketoTriggerManager.Deactivate_Contact_Triggers__c)){
    
        if(!ContactTriggerMAINHandler.isTriggerExecuted){
            if(trigger.isBefore){
                if(trigger.isInsert){
                    ContactTriggerMAINHandler.beforeInsertHandler(trigger.new,trigger.newMap);    
                }else if(trigger.isUpdate){
                    ContactTriggerMAINHandler.beforeUpdateHandler(trigger.new,trigger.newMap, trigger.old, trigger.oldMap);
                }
            }else if(trigger.isAfter){
                if(trigger.isInsert){
                    ContactTriggerMAINHandler.afterInsertHandler(trigger.new,trigger.newMap);    
                }else if(trigger.isUpdate){
                    ContactTriggerMAINHandler.afterUpdateHandler(trigger.new,trigger.newMap, trigger.old, trigger.OldMap);  
                }else if(trigger.isDelete){
                    ContactTriggerMAINHandler.afterDeleteHandler(trigger.old, trigger.oldMap);  
                }       
            }
        }
    }
}