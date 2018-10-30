/*********************************************************************
* Last Modified By   : Sumit Bhatt(Grazitti) 11th Jan 2018
* Reference          : *APPS-11571# Create Different fields on Custom Setting Marketo Trigger Management
**************************************************************************/
/**
- GOAL OF THIS TRIGGER IS TO CONSOLIDATE ALL TRIGGERS INTO SINGLE ONE. 
- THIS TRIGGER WILL BE LOGIC LESS, EVENT DRIVEN ONLY. ALL LOGIC WILL WILL BE PERFORMED IN
- CORRESPONDING HANDLER AND HELPER ROUTINS.
**PLEASE DO NOT CREATE ANY OTHER TRIGGER, ADD YOUR LOGIC IN HANDLER AND HELPER.
- DESIGNED BY: GRAZITTI 
**/
trigger Quote_MAIN_Trigger_OPTIMIZED on Quote (before insert,before update, before delete, after insert, after update, after delete) {
    
    /**-- 
      - CODE ADDED BY GRAZITTI TO ENABLE/DISABLE LEGACY TRIGGER WITHOUT ANY APEX CHANGE AND DEPLOYMENT.
      - UPDATE HERE:- Setup --> Custom Setting --> Marketo Trigger Management --> Manage --> Checkbox "Deactivate Legacy Quote Triggers"
    --**/
    
    if(!(SalesTriggersUtility.marketoTriggerManager.Deactivate_Legacy_Quote_Triggers__c)){
    
		if(trigger.isBefore){
			if(trigger.isInsert){
				Quote_MAIN_TriggerHandler_OPTIMIZED.isBeforeInsertHandler(trigger.new);
			}else if(trigger.isUpdate){
				Quote_MAIN_TriggerHandler_OPTIMIZED.isBeforeUpdateHandler(trigger.new, trigger.newMap, trigger.oldMap);
			}else if(trigger.isDelete){
			
			}
		}else
		if(trigger.isAfter){
			if(trigger.isInsert){
				Quote_MAIN_TriggerHandler_OPTIMIZED.isAfterInsertHandler(trigger.new, trigger.newmap);
			}else if(trigger.isUpdate){
				Quote_MAIN_TriggerHandler_OPTIMIZED.isAfterUpdateHandler(trigger.new, trigger.old, trigger.newmap, trigger.oldmap );
			}else if(trigger.isDelete){
				Quote_MAIN_TriggerHandler_OPTIMIZED.isAfterDeleteHandler(trigger.old, trigger.oldmap );
			}
		}
    }
}