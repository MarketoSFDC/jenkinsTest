/* Class Name      : AssetTriggerHandler 
   Created By      : Abhijeet Baneka (Jade Global Inc)
   Description     : This TRIGGER will handle all the trigger events and give call to handler class for running the approriate logic. 
   Date Created    : 31/1/2015
   Last Modified By: ---NA---
*/

/*********************************************************************
* Last Modified By   : Sumit Bhatt(Grazitti) 11th Jan 2018
* Reference          : *APPS-11571# Create Different fields on Custom Setting Marketo Trigger Management
**************************************************************************/

trigger AssetTriggerMAIN on Asset (before insert, before update, before delete,after insert, after update, after delete, after undelete){
    
    //THIS CHECK IS USED TO PREVENT EXECUTION OF ASSET TRIGGER MULTIPLE TIMES WHEN OPPORTUNITY IS CLOSED. THIS IS NOT USED FOR RECURSION HANDLING ON ASSET (ADDED BY GRAZITTI)
    if(Utility.isAssetTriggerExecutedFromOppty) return;
     /**@@ 
      - CODE ADDED BY GRAZITTI TO ENABLE/DISABLE TRIGGER WITHOUT ANY APEX CHANGE AND DEPLOYMENT.
      - MANAGE HERE:- Setup --> Custom Setting --> Marketo Trigger Management --> Manage --> Checkbox "Deactivate Asset Triggers"
    @@**/
    if(!(SalesTriggersUtility.marketoTriggerManager.Deactivate_Asset_Triggers__c)){
        System.debug('ENTERED IN TRIGGER AssetTriggerMAIN *****************');
         //Handler Class for Trigger Logic
        AssetTriggerHandler aHandler = new AssetTriggerHandler ();
        
        
        //************NO Actual Logic handled in Trigger. All execution is handled in AssetTriggerHandler class********* 
        //************Please make sure all profiles are given access to the helper and handler class *********   
        
        //All before triggers will run here.  
        if(Trigger.isBefore){
            
            //All before Insert triggers will execute here. 
            if(trigger.isInsert){
                aHandler.isBeforeInsert(Trigger.new);
            }
            
            //All before Update triggers will execute here. 
            else if(trigger.isUpdate){
                aHandler.isBeforeUpdate(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap);
            }
            
            //All before Delete triggers will execute here. 
            else if(trigger.isDelete){
                aHandler.isBeforeDelete(Trigger.old, Trigger.oldMap);
            }
        }
        
        //All after triggers will run here. 
        else if(Trigger.isAfter){
        
            //All after Insert triggers will execute here. 
            if(trigger.isInsert){
                aHandler.isAfterInsert(Trigger.new, Trigger.newMap);
            }
           
            //All after Update triggers will execute here.
            else if(trigger.isUpdate){
                aHandler.isAfterUpdate(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap);
            }
           
            //All after delete triggers will execute here.
            else if(trigger.isDelete){
                aHandler.isAfterDelete(Trigger.old, Trigger.oldMap);
            }
            
            //All after undelete triggers will execute here.
            else if(trigger.isUnDelete){
                aHandler.isAfterUnDelete(trigger.new,Trigger.newMap);
            }
        } 
    } // TriggerSwitch ends here 
   
}