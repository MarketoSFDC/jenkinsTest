/**-------------------------------------------------------------------------------------------------------
DESCRIPTION: 
MANAGED BY: GRAZITTI
--------------------------------------------------------------------------------------------------------**/
/*********************************************************************
* Last Modified By   : Sumit Bhatt(Grazitti) 11th Jan 2018
* Reference          : *APPS-11571# Create Different fields on Custom Setting Marketo Trigger Management
**************************************************************************/

Trigger Entitlement_MAIN_Trigger_OPTIMIZED on Entitlement(before insert, before update, after insert, after update) { 
    
    /**@@ 
      - CODE ADDED BY GRAZITTI TO ENABLE/DISABLE TRIGGER WITHOUT ANY APEX CHANGE AND DEPLOYMENT.
      - MANAGE HERE:- Setup --> Custom Setting --> Marketo Trigger Management --> Manage --> Checkbox "Dectivate Entitlement Triggers"
    @@**/
    //Disable trigger for specific user by Grazitti.
    system.debug('------- Enter Trigger -------');
    if(label.updateCaseP1Flag == 'Yes' && UserInfo.getUserId() == Label.Disable_Trigger_WF_UserId) return;
    system.debug('------ Trigger Running ------');
    
    if(!(SalesTriggersUtility.marketoTriggerManager.Deactivate_Entitlements_Triggers__c)){
        if(!Entitlement_MAIN_Trigger_Helper.isEntitlement_MAIN_TriggerExecuted){   
            if (trigger.isBefore){ 
                if(trigger.isInsert){   
                    Entitlement_MAIN_Trigger_Helper.beforeInsertHandlerInBulk(trigger.new);
                  }else 
                if(trigger.isUpdate){
                    Entitlement_MAIN_Trigger_Helper.beforeUpdateHandlerInBulk(trigger.new, trigger.newMap, trigger.oldMap);
                     
                }else if(trigger.isDelete){
                    //....AWAITING FOR A NEW PROCESS....
                }
            }else 
            if(Trigger.isAfter){
                
                if(trigger.isInsert){
                    Entitlement_MAIN_Trigger_Helper.afterInsertHandlerInBulk(trigger.new, trigger.newMap);
                }else 
                if(trigger.isUpdate){
                    Entitlement_MAIN_Trigger_Helper.afterUpdateHandlerInBulk(trigger.new, trigger.newMap, trigger.oldMap);
                }else if(trigger.isDelete){
                    //....AWAITING FOR A NEW PROCESS....
                }
             }
         } 
     }      
}