/*********************************************************************
* Last Modified By   : Sumit Bhatt(Grazitti) 11th Jan 2018
* Reference          : *APPS-11571# Create Different fields on Custom Setting Marketo Trigger Management
**************************************************************************/
/**
#USE THIS TRIGGER TO WRITE ALL THE ACTION NEEDED ON USER OBJECT**
#PLEASE ADD OTHER EVENT AS PER YOUR NEED
CREATED BY: Marketo IT (GRAZITTI)
**/
trigger User_MAIN_Trigger_OPTIMIZED on User (before insert, before update, after insert, after update) {
    /**@@ 
      - CODE ADDED BY GRAZITTI TO ENABLE/DISABLE TRIGGER WITHOUT ANY APEX CHANGE AND DEPLOYMENT.
      - MANAGE HERE:- Setup --> Custom Setting --> Marketo Trigger Management --> Manage --> Checkbox "Deactivate User Triggers"
    @@**/
    if(!(SalesTriggersUtility.marketoTriggerManager.Deactivate_User_Triggers__c)){
    
        if(!User_Trigger_MAIN_Helper.isTrigger_User_NEW_Executed){
            if(Trigger.isBefore){
                if(Trigger.isInsert ){
                    //HANDLE ALL OPERATIONS BEFORE INSERT IN BULK
                    User_Trigger_MAIN_Handler.beforeInsertTrigger(trigger.new);
                }else if(Trigger.isUpdate){
                    //HANDLE ALL OPERATIONS BEFORE UPDATE IN BULK
                    User_Trigger_MAIN_Handler.beforeUpdateTrigger(trigger.new);
                }
            }else           
            if(Trigger.isAfter){    
                if(Trigger.isInsert ){
                    //HANDLE ALL OPERATIONS AFTER INSERT IN BULK
                    User_Trigger_MAIN_Handler.afterInsertTrigger(trigger.newMap);
                }else if(Trigger.isUpdate){
                    //HANDLE ALL OPERATIONS AFTER INSERT IN BULK
                    User_Trigger_MAIN_Handler.afterUpdateTrigger(trigger.new, trigger.newMap, trigger.oldMap);
                }
            }
        } 
        
    }
}