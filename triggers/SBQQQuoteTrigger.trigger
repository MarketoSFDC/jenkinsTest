/*********************************************************************
* Created by         : Rajesh Wani
* Created Date       : 5th Jan 2015
* Last Modified By   : Rajesh Wani 5th Jan 2015
* Purpose            : This is used to update the quote fields based on SBQQ__ShippingCountry__c   
**************************************************************************/
 
/*********************************************************************
* Last Modified By   : Sumit Bhatt(Grazitti) 11th Jan 2018
* Reference          : *APPS-11571# Create Different fields on Custom Setting Marketo Trigger Management
**************************************************************************/ 
                  
trigger SBQQQuoteTrigger on SBQQ__Quote__c (before insert,before update, after insert, after update, after delete) {
    /**@@ 
      - CODE ADDED BY GRAZITTI TO ENABLE/DISABLE TRIGGER WITHOUT ANY APEX CHANGE AND DEPLOYMENT.
      - MANAGE HERE:- Setup --> Custom Setting --> Marketo Trigger Management --> Manage --> Checkbox "Deactivate Steelbrick Quote Triggers"
    @@**/
    
   if(!(SalesTriggersUtility.marketoTriggerManager.Deactivate_Steelbrick_Quote_Triggers__c)){
         System.debug('ENTERED IN TRIGGER SBQQQuoteTrigger *****************');
         SBQQQuoteTriggerHandler.QuoteTriggerHandler(trigger.new,trigger.oldmap);
    } // TriggerSwitch ends here 
}