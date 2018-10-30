/*********************************************************************
* Last Modified By   : Sumit Bhatt(Grazitti) 11th Jan 2018
* Reference          : *APPS-11571# Create Different fields on Custom Setting Marketo Trigger Management
**************************************************************************/
/**@@
    #USE THIS TRIGGER TO WRITE ALL THE ACTION NEEDED ON QUOTELINEITEM OBJECT**
    #PLEASE ADD YOUR LOGIC IN HANDLER CLASS RATHER THAN THIS TRIGGER.
    #CREATED BY: Marketo IT (GRAZITTI)
@@**/
trigger QuoteLineItem_MAIN_Trigger_OPTIMIZED on QuoteLineItem (before insert, before update, before delete, after insert, after update, after delete) {
    
    /**@@ 
      - CODE ADDED BY GRAZITTI TO ENABLE/DISABLE TRIGGER WITHOUT ANY APEX CHANGE AND DEPLOYMENT.
      - MANAGE HERE:- Setup --> Custom Setting --> Marketo Trigger Management --> Manage --> Checkbox "Deactivate Legacy QLI Triggers"
    @@**/
    if(!(SalesTriggersUtility.marketoTriggerManager.Deactivate_Legacy_QLI_Triggers__c)){
    
        if(!QuoteLineItem_MAIN_TriggerHandler.isQuoteLineItem_MAIN_Trigger_Executed){    
            if(Trigger.isBefore){
                if(Trigger.isInsert ){
                    //QuoteLineItem_MAIN_TriggerHandler.beforeInsertTrigger(trigger.new);
                }else if(Trigger.isUpdate){
                   // QuoteLineItem_MAIN_TriggerHandler.beforeUpdateTrigger(trigger.new);
                }
            }else           
            if(Trigger.isAfter){    
                if(Trigger.isInsert ){
                    QuoteLineItem_MAIN_TriggerHandler.afterInsertTriggerInBulk(trigger.new, trigger.newMap);
                }else if(Trigger.isUpdate){
                    QuoteLineItem_MAIN_TriggerHandler.afterUpdateTriggerInBulk(trigger.new, trigger.newMap, trigger.oldMap);
                }else if(trigger.isDelete){
                    QuoteLineItem_MAIN_TriggerHandler.afterDeleteTriggerInBulk(trigger.old);
                }
            } 
        }
        
    }
}