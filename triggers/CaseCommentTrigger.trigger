trigger CaseCommentTrigger on CaseComment (after delete, after insert, after update, before delete, before insert, before update)
{
    /*******
    - CODE ADDED BY GRAZITTI TO ENABLE/DISABLE SUPPORT OPTIMIZED TRIGGER WITHOUT ANY APEX CHANGE AND DEPLOYMENT.
    - MANAGE HERE:- Setup --> Custom Setting --> Support Trigger Settings --> Manage --> Checkbox "Case Optimized Trigger Enabled"
    *******/
	if(UserInfo.getUserId() == Label.Disable_Trigger_WF_UserId) return;
    if(Support_Trigger_Settings__c.getInstance('Case Optimized Trigger Enabled') == null || !Support_Trigger_Settings__c.getInstance('Case Optimized Trigger Enabled').Enable_Optimized_Trigger__c) return; 

    TriggerFactory.createHandler(CaseComment.sObjectType);
}