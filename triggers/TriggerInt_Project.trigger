/* ***********************************************************************************************
Created By  : Priyanka Shende, Jade Global Inc.
Created On  : 3rd November 2017
Description : Publish platform event based on the project record created or updated 

* *********************************************************************************************** */

trigger TriggerInt_Project on pse__Proj__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
        if(!(SalesTriggersUtility.marketoTriggerManager.Deactivate_Project_Triggers__c)){

          // Handle pse__Proj__c object before insert event
          
          if(trigger.isBefore){
               if(trigger.isInsert){
                    TriggerInt_Project_Handler.beforeInsertHandler(Trigger.new, Trigger.newMap);
                }
                else if(trigger.isUpdate){
                    TriggerInt_Project_Handler.beforeUpdateHandler(Trigger.new, Trigger.newMap, Trigger.old,Trigger.oldMap);
                }
                if(trigger.isDelete){
                    // Befor delete logic...AWAITING FOR A PROCESS.....
                }
          }//End of isBefore events
          else{
               if(trigger.isInsert){
                   
                   /*-----------------------------------------------------------------------------------------------------------
                      AFTER INSERT Event ---- PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER INSERTING THE RECORDS
                   --------------------------------------------------------------------------------------------------------------- */
                   TriggerInt_Project_Handler.afterInsertHandler(Trigger.new, Trigger.newMap, Trigger.oldMap, Trigger.old);
                   
                }
                else if(trigger.isUpdate){
                
                  /*-----------------------------------------------------------------------------------------------------------
                      AFTER Update Event ---- PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER INSERTING THE RECORDS
                  --------------------------------------------------------------------------------------------------------------- */  
                  TriggerInt_Project_Handler.afterUpdateHandler(trigger.new,Trigger.newMap,trigger.old,Trigger.oldMap);
                  
                }
                /* if(trigger.isDelete){
                   //After delete logic......AWAITING FOR A PROCESS..... 
                }
                if(trigger.isUnDelete){
                    //After undelete logic......AWAITING FOR A PROCESS.....
                } */
          }//End of isAfter events
        }
}