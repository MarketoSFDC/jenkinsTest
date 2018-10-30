@isTest 
private class autoGiveCertificationTriggerTest {
    static testMethod void validateautoGiveCertificationTrigger() {
       

        Account A = new Account(Name= 'Test Account');
        Insert A;

        Contact C = new Contact(AccountId = A.Id, LeadSource = 'PPC', FirstName = 'First', LastName = 'Last');
        Insert C;
        
        Certification_History__c CH = new Certification_History__c(Account__c= A.Id, Certification_Contact__c= C.Id, Exam_Result__c = 'Pass', Date_Passed_Exam__c = date.today(), Certification_Level__c = 'Marketo Certified Expert');
        Insert CH;
        
        Certification_History__c CH2 = new Certification_History__c(Account__c= A.Id, Certification_Contact__c= C.Id, Exam_Result__c = 'Pass', Date_Passed_Exam__c = date.today(), Certification_Level__c = 'Marketo Certified Expert');
        Insert CH2;
        
        CH2.Date_Exam_Taken__c = date.today();
        Update CH2;
        
        Account A1 = new Account(Name= 'Test Account');
        Insert A1;

        Contact C1 = new Contact(AccountId = A.Id, LeadSource = 'PPC', FirstName = 'First', LastName = 'Last');
        Insert C1;
        
         Certification_History__c CH1 = new Certification_History__c(Account__c= A1.Id, Certification_Contact__c= C1.Id, Exam_Result__c = 'Pass', Date_Passed_Exam__c = date.today(), Certification_Level__c = 'Marketo Analytics');
        Insert CH1;
         
        CH1.Date_Exam_Taken__c = date.today();
        Update CH1;
        
    }   
}