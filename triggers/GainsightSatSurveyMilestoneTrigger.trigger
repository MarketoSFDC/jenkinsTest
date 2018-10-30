trigger GainsightSatSurveyMilestoneTrigger on CSatSurveyFeedback__c (after insert) 
{
 if(label.updateCaseP1Flag == 'Yes' && UserInfo.getUserId() == Label.Disable_Trigger_WF_UserId) return;
    try
    {
        Set<id> AccountIDSet = new Set<id>();
        Set<Id> SurveySet = new Set<Id> ();
        Set<Id> CaseSet = new Set<Id>();        
        Map<string, CSatSurveyFeedback__c> SurveyList = new Map<string, CSatSurveyFeedback__c>();
        Map<string, JBCXM__CustomerInfo__c> CustInfoMap = new Map<string, JBCXM__CustomerInfo__c>();
        List<JBCXM__Milestone__c> MilestonesToInsert = new List<JBCXM__Milestone__c>();
        Map<string, string> ContactMap  = new Map<string, string>();
        Map<Id, CSatSurveyFeedback__c> CaseSurveyMap = new Map<Id, CSatSurveyFeedback__c>();
        Map<String,JBCXM__PickList__c> MilestonePicklistMap = new Map<String,JBCXM__PickList__c>();
        Map<Id, DateTime> CaseMap = new Map<Id, DateTime>();

        for(CSatSurveyFeedback__c SF : Trigger.new)
        {
            SurveySet.add(SF.Id);
            
            AccountIDSet.add(SF.Account__c);
                               
            CaseSet.add(SF.Case__c);
        }

       
        for(Case C : [SELECT Id, ClosedDate FROM Case WHERE Id IN :CaseSet])
        {
            CaseMap.put(C.Id,C.ClosedDate);
        }

        for(Contact C : [SELECT Id, Name FROM Contact WHERE AccountId IN :AccountIDSet])
        {
            ContactMap.put(C.Id, C.Name);
        }

        for (JBCXM__CustomerInfo__c CI : [SELECT Id,JBCXM__Account__c FROM JBCXM__CustomerInfo__c WHERE JBCXM__Account__c IN :AccountIDSet ])
        {
            CustInfoMap.put(CI.JBCXM__Account__c, CI);
        }

        for(JBCXM__PickList__c PL : [SELECT Id,JBCXM__SystemName__c FROM JBCXM__PickList__c WHERE JBCXM__Category__c='Milestones' AND JBCXM__SystemName__c='CSAT Support Survey '])
        {
            MilestonePicklistMap.put(PL.JBCXM__SystemName__c,PL);   
        }

        for(CSatSurveyFeedback__c SF : Trigger.new)
        {
            if(CustInfoMap.containskey(SF.Account__c))
            {
                JBCXM__Milestone__c M   = new JBCXM__Milestone__c();
                M.JBCXM__Milestone__c   = MilestonePicklistMap.containsKey('CSAT Support Survey ') ? MilestonePicklistMap.get('CSAT Support Survey  ').Id : null;
                M.JBCXM__Account__c     = SF.Account__c;
                M.JBCXM__Comment__c     = (ContactMap.containsKey(SF.Contact__c) ? ContactMap.get(SF.Contact__c) : null) + ' filled out a Customer Satisfaction Survey with an overall score of ' + SF.Question_1__c;
                M.JBCXM__Date__c        = (CaseMap.containsKey(SF.Case__c) ? CaseMap.get(SF.Case__c).Date() : Date.Today());
                
                MilestonesToInsert.add(M);
                    
            }
        }

        if(MilestonesToInsert.size() > 0)
        {
             insert MilestonesToInsert;
        }   
    }
    catch (Exception e) 
    {
        JBCXM__Log__c errorLog = New JBCXM__Log__c(JBCXM__ExceptionDescription__c   = 'Received a '+e.getTypeName()+' at line No. '+e.getLineNumber()+' while running the Trigger to create a Milestone for CSAT Survey',
                                                   JBCXM__LogDateTime__c            = datetime.now(),
                                                   JBCXM__SourceData__c             = e.getMessage(),
                                                   JBCXM__SourceObject__c           = 'Case',
                                                   JBCXM__Type__c                   = 'GainsightSatSurveyMilestoneTrigger');
        insert errorLog;
        system.Debug(errorLog.JBCXM__ExceptionDescription__c);
        system.Debug(errorLog.JBCXM__SourceData__c);
    }

}