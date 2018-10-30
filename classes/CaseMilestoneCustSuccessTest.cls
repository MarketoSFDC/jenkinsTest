@isTest
public class CaseMilestoneCustSuccessTest{

    public static testmethod void SuccessTest(){
        Case cse = new Case();
        cse.recordtypeId = Label.SupportCaseRecordTypeId;
        cse.Priority = 'High'; 
        cse.subject = 'test';
        cse.status = 'New';
        cse.Category__c = 'ToutApp';
        cse.Last_Public_Comment_Date_Time__c = System.Now();
        cse.status = 'Closed';
        insert cse;
        Case_Update_Milestones__c cm = new Case_Update_Milestones__c();
        cm.case__c = cse.Id;
        cm.Start_Date__c = system.now();
        cm.Target_Date__c =system.now().addHours(2);
        cm.Duration__c = '3600';
        cm.Milestone_Type__c = 'First Response';
        cm.Completed__c = false;
        insert cm;
        CaseMilestoneCustSuccess.caseId = cse.Id;
        CaseMilestoneCustSuccess.getcsmilestone();
    }


}