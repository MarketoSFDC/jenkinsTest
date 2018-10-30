@isTest 
private class CertificationRewardExpSchedulerTest {
    static testMethod void validateCertificationRewardExpSchedulerClass() {
       

        Account A = new Account(Name= 'Test Account');
        Insert A;

        Contact C = new Contact(AccountId = A.Id, LeadSource = 'PPC', FirstName = 'First', LastName = 'Last');
        Insert C;

        Certification_History__c CH = new Certification_History__c(Account__c= A.Id, Certification_Contact__c= C.Id, Exam_Result__c = 'Pass', Date_Passed_Exam__c = date.today(), Certification_Level__c = 'Marketo Certified Expert', BadgeVilleReward_Status__c = True);
        Insert CH;
        
        date newDate = CH.Date_Passed_Exam__c.addDays(-395);
        CH.Date_Passed_Exam__c = newDate;
        Update CH;
        
        SchedulableContext sc = null;
        CertificationRewardExpirationSchedulable tsc = new CertificationRewardExpirationSchedulable();
        tsc.execute(sc);
     
        
    }   
}