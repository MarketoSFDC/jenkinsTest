/**
 * Class Case Comment Handler
 *
 * Trigger Handler for the Case Comment SObject. This class implements the ITrigger
 * interface to help ensure the trigger code is bulkified and all in one place.
 */
public class CaseCommentHandler implements ITrigger
{   
    // Member variable to hold the Id's of parent Cases 'in use'
    private Set<Id> m_MileStoneCaseIds = new Set<Id>();
    list<caseComment> InternalCommentNotificationList = new list<caseComment>(); 
    list<Case> updatecase = new list<Case>();       
    // Member variable
    private static Boolean isAlreadyProcessing = false;
    private Boolean isPrimary = false;
    public CustomMileStoneUtil m_ObjCMSU;
    
    // Constructor
    public CaseCommentHandler()
    {
        System.debug('CaseCommentHandler constructor called ==>');    
        if(isAlreadyProcessing == false) {
            isPrimary = true;
            isAlreadyProcessing = true;
        } 
        m_ObjCMSU = new CustomMileStoneUtil();
    }

    /**
     * bulkBefore
     *
     * This method is called prior to execution of a BEFORE trigger. Use this to cache
     * any data required into maps prior execution of the trigger.
     */
    public void bulkBefore(){
        try{
            if((Trigger.isInsert && Support_Switches__c.getInstance('duplicateCommentSwitch') != null && Support_Switches__c.getInstance('duplicateCommentSwitch').isActive__c == 'Yes') || Test.isRunningTest()){
                CaseCommentFunction.duplicateCommentValidation();
            }
        }
        catch(Exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);} 
 

    }
    
    public void bulkAfter() {
        if(isPrimary != true) return;
        if(Trigger.isInsert &&  Support_Switches__c.getInstance('SecuredDomainSSL') != null && Support_Switches__c.getInstance('SecuredDomainSSL').isActive__c == 'Yes'){
            CaseCommentFunction.createProactiveCaseForSSLDomain(Trigger.New);
        } 
        System.debug('CC bulkAfter called ==>');
        if(Trigger.isInsert) {   
            boolean res = CustomMileStoneUtil.setCaseCommentErrors();
            System.debug('case comment error returned==> ' + res);
            //Short circuit for live version
            if(res == false) return;                                
            //Note: Test if this breaks nor not
            //m_MileStoneCaseIds = CustomMileStoneUtil.getCaseIdsforMileStones();                        
            //System.debug('case comment m_MileStoneCaseIds==> ' + m_MileStoneCaseIds);                        
            try{m_ObjCMSU = CustomMileStoneUtil.CustomMilestoneOnCaseCommentsClone();} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);} 
            System.debug('case comment m_ObjCMSU ==> ' + m_ObjCMSU);    
            try{InternalCommentNotificationList = CustomMileStoneUtil.InternalCommentList();} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}  
            System.debug('case comment InternalCommentNotificationList ==> ' + InternalCommentNotificationList);                 
        }
        
        if( ((Trigger.isInsert || Trigger.isdelete || Trigger.isUpdate) && system.isBatch() == false && system.Isfuture() == false && Label.CaseCommentHandler == 'Yes') || Test.isRunningTest()) {  
            try{
                system.debug('##After Update 1');
                Map<Id,String> parentMap = new Map<Id,String>();
                Map<Id,String> parentMapFinal = new Map<Id,String>();
                if(trigger.isAfter && trigger.isinsert){
                    for(Object casC1: Trigger.New){
                        casecomment ccObj = (casecomment) casC1;
                        if(ccObj.parentId != null && ccObj.isPublished == True && ccObj.createdbyId !=Label.JiveSyncSafeUserId && ccObj.createdbyId != Label.Case_Admin) parentMap.put(ccObj.parentId,'Insert');
                    }
                }
                if(trigger.isAfter && trigger.isUpdate){
                    for(Object casC1: Trigger.New){
                        casecomment ccObj = (casecomment) casC1;
                        CaseComment oldMap = (CaseComment)Trigger.OldMap.get(ccObj.Id);    
                        if(ccObj.parentId != null && oldMap.isPublished == False && ccObj.isPublished == True && ccObj.createdbyId !=Label.JiveSyncSafeUserId && ccObj.createdbyId != Label.Case_Admin) parentMap.put(ccObj.parentId,'Insert');
                    }
                }
                if(trigger.isDelete){
                    for(Object casC1 : Trigger.Old){
                        casecomment ccObj = (casecomment) casC1;
                        if(ccObj.parentId != null && ccObj.isPublished == True && ccObj.createdbyId !=Label.JiveSyncSafeUserId && ccObj.createdbyId != Label.Case_Admin) parentMap.put(ccObj.parentId,'Delete');
                    }
                }
                if(parentMap.isEmpty() == False){
                    for(CaseComment cc : [Select id,parentId,createdbyId,createdby.email from casecomment where ParentId IN : parentMap.keySet() and createdby.email Like '%marketo.com%' and parent.recordtypeId =: Label.supportcaserecordtypeid]){
                        if(parentMap.ContainsKey(cc.parentId)) parentMapFinal.put(cc.parentId,parentMap.get(cc.parentId));
                    }
                }
                if(parentMapFinal.isEmpty() == False) CaseTriggerFunction.updateCaseOnCC(parentMapFinal); //method called 

            }catch(Exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        }
        if((Trigger.isInsert && Label.EliteProactiveProjectSwitch == 'Yes') || Test.isRunningTest()){ 
            try{
                Set<Id> parentIds = new Set<Id>();
                for(Object casC1: Trigger.New){
                    casecomment ccObj = (casecomment) casC1;
                    if(ccObj.parentid != null){
                        parentIds.add(ccObj.parentId);
                    }
                  }
                 updatecase = CaseTriggerFunctionUpdated.updateOwnerToTAMproactive(parentIds);
                 if(updatecase.Size()>0){
                     update updatecase;
                 }
            }
            catch(Exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        }
        
        
     }   
    public void beforeInsert(SObject so)
    {
        System.debug('CC beforeInsert called ==>');
    }
    
    public void beforeUpdate(SObject oldSo, SObject so)
    {
        System.debug('CC beforeUpdate called ==>');    
    }
    
    /**
     * beforeDelete
     *
     * This method is called iteratively for each record to be deleted during a BEFORE
     * trigger.
     */
    public void beforeDelete(SObject so)
    {   
        // Cast the SObject to an CaseComment
        System.debug('CC beforeDelete called ==>');
    }
    
    public void afterInsert(SObject so)
    {
        System.debug('CC afterInsert called ==>');        
    }
    
    public void afterUpdate(SObject oldSo, SObject so)
    {
        System.debug('CC afterUpdate called ==>');    
    }
    
    public void afterDelete(SObject so)
    {
        System.debug('CC afterDelete called ==>');
    }
    
    /**
     * andFinally
     *
     * This method is called once all records have been processed by the trigger. Use this 
     * method to accomplish any final operations such as creation or updates of other records.
     */
    public void andFinally() {
        
        if(isPrimary != true) return;
        
        //do all post operations here.       
        String tmpStr = '';
        if(Trigger.isBefore) tmpStr += ' Before ';    
        if(Trigger.isAfter)  tmpStr += ' After '; 
        if(Trigger.isInsert) tmpStr += ' Insert ';    
        if(Trigger.isUpdate) tmpStr += ' Update ';    
        if(Trigger.isDelete) tmpStr += ' Delete ';  
        System.debug('CC andFinally called for ======>' + tmpStr);     
        System.debug('CC andFinally called======>InternalCommentNotificationList ' + InternalCommentNotificationList);
        System.debug('CC andFinally called for First Response======>m_MileStoneCaseIds ' + m_MileStoneCaseIds);
        System.debug('CC andFinally called======>m_ObjCMSU ' + m_ObjCMSU);
                  
        if(InternalCommentNotificationList != NULL && InternalCommentNotificationList.IsEmpty() == False) {
            try{CustomMileStoneUtil.InternalCommentNotification(InternalCommentNotificationList);} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        }
        /*
        // complete any First response records
        if(m_MileStoneCaseIds != null && m_MileStoneCaseIds.isEmpty() == FALSE) {
            //CustomMileStoneUtil.completeMilestone(m_MileStoneCaseIds, 'First Response', System.now());
        }        
        */
        //update case set next due date.
        if(m_ObjCMSU != Null && m_ObjCMSU.m_milestonesToBeUpdatedOrInserted != null && m_ObjCMSU.m_milestonesToBeUpdatedOrInserted.isEmpty() == False) {
            try{Upsert m_ObjCMSU.m_milestonesToBeUpdatedOrInserted;} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        }
        if(m_ObjCMSU != Null && m_ObjCMSU.m_casesToBeUpdated != null && m_ObjCMSU.m_casesToBeUpdated.isEmpty() == False) {
            CaseHandler.isUpdatingCase = true; //don't run case triggers.
            try{Update m_ObjCMSU.m_casesToBeUpdated;} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        }               
        System.debug('isPrimary ==> '+ isPrimary + ' isAlreadyProcessing==> ' + isAlreadyProcessing); 
        if(isPrimary == true && isAlreadyProcessing == true) {
            isAlreadyProcessing = false;
        }        
    }    
}