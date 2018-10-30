/*********************************************************************
* Last Modified by   : Grazitti 
* Modified Date      : 28-April-18
* Purpose            : #01009688 Consolidate Support Engineer Fields on Entitlement
* Line numbers       : 38,65

**********************************************************************/

trigger CreateSitManRecordSurveyFeedback on CSatSurveyFeedback__c (after insert,after update){
    if(label.updateCaseP1Flag == 'Yes' && UserInfo.getUserId() == Label.Disable_Trigger_WF_UserId) return;
    Map<Id,Id> surveyFeedbackIdToCaseId = new Map<Id,Id>();
    List<Case> parentCaseToUpdate = new List<Case>();
    Set<Id> parentCaseIds = new Set<Id>();
    
    try {
        if((Test.isRunningTest() || Label.EWSActivator == 'YES') && Trigger.isInsert || trigger.isUpdate){EWSUtility.createrEWSActivitiesForCSatSurveyFeedbacks();}
    }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
    //Code EWS Starts Added on Sep 29, 2016 - Grazitti Interactive
    
    if(Trigger.isInsert){
        Set<Id> caseIds = new Set<Id>();  
        Set<Id> OwnerUsrIds = new Set<Id>();//List of case owners    
        Datetime nextUpdateDue = BusinessHours.addGmt('01m50000000H7QzAAK', System.now(), 2*24*60*60000);        
        Id smSupportId = '01250000000UK1EAAW';        

        for (CSatSurveyFeedback__c newSurvyFeedbck : Trigger.new ){
            surveyFeedbackIdToCaseId.put(newSurvyFeedbck.Id,newSurvyFeedbck.Case__c);            
            caseIds.add(newSurvyFeedbck.Case__c);
            if(newSurvyFeedbck.Case__c != null && Support_Switches__c.getInstance('CSATTrigger') != null && Support_Switches__c.getInstance('CSATTrigger').isActive__c == 'Yes') parentCaseIds.add(newSurvyFeedbck.Case__c);
        }
        if(!parentCaseIds.isEmpty()){
            for(Case cse : [Select id,Csat_Survey_Sent_For_Parent_Case__c from case where recordtypeId =: Label.SupportCaseRecordTypeId and Id In:parentCaseIds limit 1]){
                cse.Csat_Survey_Sent_For_Parent_Case__c = true;
                parentCaseToUpdate.add(cse);
            }
        }
        
        Map<Id,Case> myCasesMap = new Map<Id,Case>([SELECT ID,ParentID,CaseNumber,OwnerId, Entitlement.AssignedSupportPOC__c, Entitlement.Type, Entitlement.Support_Region__c From Case Where Id in:caseIds]);
        for(Id myCaseK : myCasesMap.keySet()) {
            if(myCasesMap.get(myCaseK).OwnerId != null && !(myCasesMap.get(myCaseK).OwnerId+'').startsWith('00G'))
                OwnerUsrIds.Add(myCasesMap.get(myCaseK).OwnerId);
        }
        
        //Case owners if not be queue for surveyed case        
        MAP<ID,User> nonQueueUsrs = new Map<Id,User>([SELECT ID, ManagerId FROM USER WHERE ID In :OwnerUsrIds AND ManagerId != NULL]);          
        Set<ID> managerIds = new Set<Id>();
        for(User tmpUser : nonQueueUsrs.values()) { managerIds.add(tmpUser.ManagerId); }
        MAP<ID,User> smOwnerManagerUsrs = new Map<Id,User>([SELECT ID FROM USER WHERE isActive = true and ID In :managerIds]);
        List<Case> newCases = new List<Case>();

        for ( CSatSurveyFeedback__c newSurvyFeedbck : Trigger.new ) {
            if(newSurvyFeedbck.Question_1__c == '1' || newSurvyFeedbck.Question_1__c == '2') { //If not satisfied
                if(myCasesMap.ContainsKey(newSurvyFeedbck.Case__c)) { //Check for map key failure
                    String smSub = 'Dissatisfied Survey Response on Case # ' + myCasesMap.get(newSurvyFeedbck.Case__c).CaseNumber;                            
                    String smDesc = '';
                    if(newSurvyFeedbck.Question_7__c != null && newSurvyFeedbck.Question_7__c != '') smDesc = newSurvyFeedbck.Question_7__c;
                    else if(newSurvyFeedbck.Comments_2__c!= null && newSurvyFeedbck.Comments_2__c!= '') smDesc = newSurvyFeedbck.Comments_2__c;
                    else if(newSurvyFeedbck.Comments_10__c!= null && newSurvyFeedbck.Comments_10__c!= '') smDesc = newSurvyFeedbck.Comments_10__c;
                    String smParentId = myCasesMap.get(newSurvyFeedbck.Case__c).Id;                    
                    //Get current case owner's manager id as new sm case owner id for non queue owners
                    if(nonQueueUsrs.containsKey(myCasesMap.get(newSurvyFeedbck.Case__c).OwnerId) && nonQueueUsrs.get(myCasesMap.get(newSurvyFeedbck.Case__c).OwnerId).ManagerId != null) {
                        if(myCasesMap.get(newSurvyFeedbck.Case__c).Entitlement.Support_Region__c == 'Japan' || smOwnerManagerUsrs.containsKey(nonQueueUsrs.get(myCasesMap.get(newSurvyFeedbck.Case__c).OwnerId).ManagerId)) {
                            String smManagerId = nonQueueUsrs.get(myCasesMap.get(newSurvyFeedbck.Case__c).OwnerId).ManagerId;                            
                            if(myCasesMap.get(newSurvyFeedbck.Case__c).Entitlement.Type == 'Business') {
                                Case cs = new Case(Situation_Account__c=newSurvyFeedbck.Account__c,Situation_Contact__c=newSurvyFeedbck.Contact__c, Subject=smSub, Description=smDesc, Problem_Type__c = 'Survey Follow-up', RecordTypeId=smSupportId, ParentId = smParentId, OwnerId=smManagerId, /*AssignedSupportPOC__c = myCasesMap.get(newSurvyFeedbck.Case__c).Entitlement.AssignedSupportPOC__c,*/ CSAT_Next_Update_Due__c = nextUpdateDue);
                                 if(System.Label.BypassCSATContactSupManager != 'Yes') cs.CSAT_Next_Update_Due__c = nextUpdateDue; 
                                newCases.add(cs);            
                            } else {
                                Case cs = new Case(Situation_Account__c=newSurvyFeedbck.Account__c,Situation_Contact__c=newSurvyFeedbck.Contact__c, Subject=smSub, Description=smDesc, Problem_Type__c = 'Survey Follow-up', RecordTypeId=smSupportId, ParentId = smParentId, OwnerId=smManagerId, CSAT_Next_Update_Due__c = nextUpdateDue);
                                if(System.Label.BypassCSATContactSupManager != 'Yes') cs.CSAT_Next_Update_Due__c = nextUpdateDue;
                                newCases.add(cs);            
                            }                                                        
                        }
                    }
                }
            }
        }
        if(newCases.size() > 0) {
            insert newCases;
        }
        Try{
            if(parentCaseToUpdate != null && parentCaseToUpdate.Size() > 0){
                update parentCaseToUpdate;
            }
        }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
       
    }
    
    if(surveyFeedbackIdToCaseId.isEmpty() == false) {
        CSatSurvey.updateCSatOwners(surveyFeedbackIdToCaseId);
    }
}