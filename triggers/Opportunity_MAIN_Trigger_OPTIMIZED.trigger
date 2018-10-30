/**@@
#TRIGGER NAME          :    Opportunity_MAIN_Trigger_OPTIMIZED
#HANDLER CLASS NAME    :    Trigger_Opportunity_Handler
#HELPER CLASS NAME     :    Trigger_Opportunity_Helper
#DESCRIPTION           :    This Tigger will handles all the trigger events and make call to the Handler class to handling the appropriate logic.
#DESIGNED BY           :    Grazitti Interactive
@@**/

/*********************************************************************
* Last Modified By   : Sumit Bhatt(Grazitti) 11th Jan 2018
* Reference          : *APPS-11571# Create Different fields on Custom Setting Marketo Trigger Management
**************************************************************************/

trigger Opportunity_MAIN_Trigger_OPTIMIZED on Opportunity (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
    
    /**@@ 
      - CODE ADDED BY GRAZITTI TO ENABLE/DISABLE TRIGGER WITHOUT ANY APEX CHANGE AND DEPLOYMENT.
      - MANAGE HERE:- Setup --> Custom Setting --> Marketo Trigger Management --> Manage --> Checkbox "Deactivate Opportunity Triggers"
    @@**/
    
    //Added by Jade
    //Date : 30th Sep 2016
    //To avoid the execution of opportunity Trigger for New Business Opportunity created by Amends Process by Steelbrick
    //list<Opportunity> ListOfOpportunitiesToBeProcessed = new list<Opportunity>();
    
    if(!(SalesTriggersUtility.marketoTriggerManager.Deactivate_Opportunity_Triggers__c)){
    
        //######## Commented by Jade For Amends Decommissioning ###########
        /*if(!Trigger.isDelete && !Trigger.isUnDelete){
            for(Opportunity Oppty: Trigger.new){
                if(!Oppty.Name.Contains(label.Amendment_for_contract) ){
                    ListOfOpportunitiesToBeProcessed.add(Oppty);
                }//End of IF
            }//End of FOR
        }//End of IF
        */
        
        if(trigger.isBefore){
            if(trigger.isInsert){
                Trigger_Opportunity_Handler.beforeInsertHandler(Trigger.new, trigger.newMap);
            }
            else if(trigger.isUpdate){
                Trigger_Opportunity_Handler.beforeUpdateHandler(Trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            }
            if(trigger.isDelete){
                Trigger_Opportunity_Handler.beforeDeleteHandler(trigger.old, trigger.oldMap);
            }
        }else{
            if(trigger.isInsert){
                Trigger_Opportunity_Handler.afterInsertHandler(Trigger.new, trigger.newMap);
            }
            else if(trigger.isUpdate){
                Trigger_Opportunity_Handler.afterUpdateHandler(Trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            }
            if(trigger.isDelete){
                Trigger_Opportunity_Handler.afterDeleteHandler(trigger.old, trigger.oldMap);
            }
            if(trigger.isUnDelete){
                //...AWAITING FOR A PROCESS.....
            }
        }
    }
}