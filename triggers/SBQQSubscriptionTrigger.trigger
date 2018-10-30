/*********************************************************************
* Last Modified By   : Sumit Bhatt(Grazitti) 11th Jan 2018
* Reference          : *APPS-11571# Create Different fields on Custom Setting Marketo Trigger Management
**************************************************************************/
trigger SBQQSubscriptionTrigger on SBQQ__Subscription__c (before insert,before update, after insert,after Update,after Delete) {
	/**@@ 
      - CODE ADDED BY GRAZITTI TO ENABLE/DISABLE TRIGGER WITHOUT ANY APEX CHANGE AND DEPLOYMENT.
      - MANAGE HERE:- Setup --> Custom Setting --> Marketo Trigger Management --> Manage --> Checkbox "Deactivate Subscription Triggers"
    @@**/
    if(!(SalesTriggersUtility.marketoTriggerManager.Deactivate_Subscription_Triggers__c)){
        System.debug('ENTERED IN TRIGGER SBQQSubscriptionTrigger *****************');
        SBQQSubscriptionTriggerHandler subHandler = new SBQQSubscriptionTriggerHandler();
        subHandler.SubscriptionTriggerHandler(trigger.new,trigger.oldMap);
    } // TriggerSwitch ends here   
}