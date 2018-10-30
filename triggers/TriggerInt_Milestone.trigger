/* ***********************************************************************************************
Created By  : Suraj Makandar, Jade Global Inc.
Created On  : 27th November 2017

Last ModifiedBy : Priyanka Shende, Jade Global Inc.on 31st Jan 2018
Purpose         : Handle Before Insert Event 
* *********************************************************************************************** */

trigger TriggerInt_Milestone on pse__Milestone__c (before Insert,before update,after Insert,after Update) {
     if(!(SalesTriggersUtility.marketoTriggerManager.Deactivate_Milestone_Triggers__c)){
          if(trigger.isBefore){
              if(trigger.isUpdate){
                  TriggerInt_Milestone_Handler.beforeUpdateHandler(trigger.new,trigger.newmap,trigger.old,trigger.oldmap);
              }
          }
          if(trigger.isAfter){
            if(trigger.isInsert){
                TriggerInt_Milestone_Handler.afterInsertHandler(trigger.new,trigger.old,trigger.newmap,trigger.oldmap);
            }else if(trigger.isUpdate){
                TriggerInt_Milestone_Handler.afteUpdateHandler(trigger.new,trigger.old,trigger.newmap,trigger.oldmap);
            }
        }
    }//End of iF block of trigger by pass using custom setting

}