trigger CaseTrigger on Case (after insert, after update,  before insert, before update) {
    /*******
    - CODE ADDED BY GRAZITTI TO ENABLE/DISABLE SUPPORT OPTIMIZED TRIGGER WITHOUT ANY APEX CHANGE AND DEPLOYMENT.
    - MANAGE HERE:- Setup --> Custom Setting --> Support Trigger Settings --> Manage --> Checkbox "Case Optimized Trigger Enabled"
    *******/
    system.debug('case1======>'+label.updateCaseP1Flag); 
    system.debug('case2======>'+UserInfo.getUserId());
    if(label.updateCaseP1Flag == 'Yes' && UserInfo.getUserId() == Label.Disable_Trigger_WF_UserId) return;
    
    if(Support_Trigger_Settings__c.getInstance('Case Optimized Trigger Enabled') == null || !Support_Trigger_Settings__c.getInstance('Case Optimized Trigger Enabled').Enable_Optimized_Trigger__c) return; 
    system.debug('trigger.new[0].Email_List__c'+trigger.new[0].Email_List__c);
    if(CaseHandler.isUpdatingCase != true){
        system.debug('case trigger called======>'); 
        TriggerFactory.createHandler(Case.sObjectType);
    }else if(trigger.isupdate && trigger.isbefore && trigger.size == 1 && trigger.new[0].Email_List__c!=null && trigger.oldMap.get(trigger.new[0].id).Email_List__c==null && (trigger.new[0].recordTypeId == '01250000000UJwx' || trigger.new[0].recordTypeId == '01250000000UJwz')){
          try{CaseTriggerFunction.parseEmailCCList();} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);} 
    }
}