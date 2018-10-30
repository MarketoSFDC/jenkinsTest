/*********************************************************************
* Last Modified By   : Sumit Bhatt(Grazitti) 11th Jan 2018
* Reference          : *APPS-11571# Create Different fields on Custom Setting Marketo Trigger Management
**************************************************************************/

trigger ContractTriggerMain on Contract (after update, before insert) {
	/**@@ 
      - CODE ADDED BY GRAZITTI TO ENABLE/DISABLE TRIGGER WITHOUT ANY APEX CHANGE AND DEPLOYMENT.
      - MANAGE HERE:- Setup --> Custom Setting --> Marketo Trigger Management --> Manage --> Checkbox "Deactivate Contract Triggers"
    @@**/
    if(!(SalesTriggersUtility.marketoTriggerManager.Deactivate_Contract_Triggers__c)){
        System.debug('ENTERED IN TRIGGER ContractTriggerMain *****************');
        if(trigger.isBefore){
            if(trigger.isInsert){
                ContractTriggerMainHandler.isBeforeInsertHandler(trigger.new, trigger.newmap);
            }
            /*
            if(trigger.isUpdate){
                ContractTriggerMainHandler.isBeforeUpdateHandler(trigger.new, trigger.newmap, trigger.old, trigger.oldmap);
            }
            if(trigger.isDelete){
                ContractTriggerMainHandler.isBeforeDeleteHandler(trigger.new, trigger.newmap);
            }
            */
        }
      
            if(trigger.isAfter){
    /*        if(trigger.isInsert){
                ContractTriggerMainHandler.isAfterInsertHandler(trigger.new, trigger.newmap);
            }
    */        if(trigger.isUpdate){
                ContractTriggerMainHandler.isAfterUpdateHandler(trigger.new, trigger.newmap, trigger.old, trigger.oldmap);
            }
    /*        if(trigger.isDelete){
                ContractTriggerMainHandler.isAfterDeleteHandler(trigger.new, trigger.newmap);
            }
    */    }
    } // TriggerSwitch ends here
}