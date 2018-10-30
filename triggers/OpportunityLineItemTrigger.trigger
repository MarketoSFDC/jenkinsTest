/* Class Name      : OpportunityLineItemTrliggerHandler 
   Created By      : Abhijeet Baneka (Jade Global Inc)
   Description     : This TRIGGER will handle all the trigger events and give call to handler class for running the approriate logic. 
   Date Created    : 03/02/2015
   Last Modified By: ---NA---
*/
/*********************************************************************
* Last Modified By   : Sumit Bhatt(Grazitti) 11th Jan 2018
* Reference          : *APPS-11571# Create Different fields on Custom Setting Marketo Trigger Management
**************************************************************************/

trigger OpportunityLineItemTrigger on OpportunityLineItem (before insert, before update, before delete,after insert, after update, after delete, after undelete){
	/**@@ 
      - CODE ADDED BY GRAZITTI TO ENABLE/DISABLE LEGACY TRIGGER WITHOUT ANY APEX CHANGE AND DEPLOYMENT.
      - MANAGE HERE:- Setup --> Custom Setting --> Marketo Trigger Management --> Manage --> Checkbox "Deactivate OLI Triggers"
    @@**/
    if(!(SalesTriggersUtility.marketoTriggerManager.Deactivate_OLI_Triggers__c)){
        System.debug('ENTERED IN TRIGGER OpportunityLineItemTrigger*****************');
        //Handler Class for Trigger Logic
        OpportunityLineItemTriggerHandler oliHandler = new OpportunityLineItemTriggerHandler();            
        //************NO Actual Logic handled in Trigger. All execution is handled in OpportunityTriggerHandler class********* 
        //************Please make sure all profiles are given access to the helper and handler class *********   
        
        //All before triggers will run here.  
        if(Trigger.isBefore){
            
            //All before Insert triggers will execute here. 
            if(trigger.isInsert){
                oliHandler.isBeforeInsert(Trigger.new);
            }
            
            //All before Update triggers will execute here. 
            else if(trigger.isUpdate){
                oliHandler.isBeforeUpdate(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap);
            }
            
            //All before Delete triggers will execute here. 
            else if(trigger.isDelete){
                oliHandler.isBeforeDelete(Trigger.old, Trigger.oldMap);
            }
        }
        
        //All after triggers will run here. 
        else if(Trigger.isAfter){
        
            //All after Insert triggers will execute here. 
            if(trigger.isInsert){
                oliHandler.isAfterInsert(Trigger.new, Trigger.newMap);
            }
           
            //All after Update triggers will execute here.
            else if(trigger.isUpdate){
                oliHandler.isAfterUpdate(Trigger.new,Trigger.old,Trigger.newMap,Trigger.oldMap);
            }
           
            //All after delete triggers will execute here.
            else if(trigger.isDelete){
                oliHandler.isAfterDelete(Trigger.old, Trigger.oldMap);
            }
            
            //All after undelete triggers will execute here.
            else if(trigger.isUnDelete){
                oliHandler.isAfterUnDelete(trigger.new,Trigger.newMap);
            }
        }   
    } // TriggerSwitch ends here    
}