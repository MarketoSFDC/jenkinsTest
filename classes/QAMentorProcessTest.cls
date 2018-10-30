@isTest
public class QAMentorProcessTest{

    @isTest static void TSEBatchTest(){
    
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'stand', Email='standser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing12345', LanguageLocaleKey = 'en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='standardus12345er@testorg.com',TSE_Date__c = System.Today());
        
        Mentor_TSE_Table__c tse = new Mentor_TSE_Table__c();
        tse.Mentor_Name__c = u.Id;
        tse.Trainee_Name__c = u.Id;
        insert tse;
        
        Case cse = new Case();
        cse.recordtypeId = Label.SupportCaseRecordTypeId;
        cse.Priority = 'P1'; 
        cse.subject = 'test';
        cse.status = 'Closed';
        cse.Category__c = 'ToutApp';
        cse.Problem_Type__c = 'How-to';
        cse.Sub_Category__c = 'Munchkin';
        cse.Close_Reason__c = 'Resolved';
        insert cse;
        
        casecomment cm = new casecomment(parentid=cse.Id);
        insert cm;
        
        TSE_Score_Card__c score = new TSE_Score_Card__c();
        score.Case__c = cse.Id;
         
        insert score;
         
        Database.executeBatch(new TSEQualityBatch(),5);
        Iterable<Mentor_TSE_Table__c> QL;
        Database.BatchableContext BC;
        List<Mentor_TSE_Table__c> AcctList = new List<Mentor_TSE_Table__c>();
        TSEQualityBatch AU = new TSEQualityBatch();
        QL = AU.start(bc);
        AU.execute(BC, new List<Mentor_TSE_Table__c>{tse});
        TSEQualityBatch.sendEmailFirstReminderToMentor(new Set<Mentor_TSE_Table__c>{tse});
        AU.finish(BC); 
        
        TSECasesFromPreviousWeekController tseWeek = new TSECasesFromPreviousWeekController();
        tseWeek.ActivityLogManagerNew = tse.Id;
        tseWeek.getWeekMap();  
           
        PageReference pRef = Page.TSECaseEvaluationForm;
        Test.setCurrentPage(pRef);
        ApexPages.currentPage().getParameters().put('userId', Userinfo.getUserId());  
        ApexPages.currentPage().getParameters().put('activityLogId', tse.Id);      
        ApexPages.StandardController sc=new ApexPages.StandardController(cse);
        TSECaseEvaluationFormController over = new TSECaseEvaluationFormController(sc); 
        over.saveScoreCard();
        over.startEvaluation();
        
        CaseQualityWeeklyScheduled cc = new CaseQualityWeeklyScheduled();
        cc.execute(null);
        
    }
}