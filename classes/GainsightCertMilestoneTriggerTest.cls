@isTest 
private class GainsightCertMilestoneTriggerTest {
    static testMethod void validateGainsightCertMilestoneTrigger() {
       

        
        List<JBCXM__Milestone__c> MilestoneList = new List<JBCXM__Milestone__c>();

        Account A = new Account(Name= 'Test Account');
        Insert A;

        Contact C = new Contact(AccountId = A.Id, LeadSource = 'PPC', FirstName = 'First', LastName = 'Last');
        Insert C;

        JBCXM__CustomerInfo__c CI = new JBCXM__CustomerInfo__c(JBCXM__Account__c=A.Id);
        Insert CI;

        JBCXM__Picklist__c PL = new JBCXM__Picklist__c(Name = 'Test PL', JBCXM__Category__c = 'Milestone' , JBCXM__SystemName__c = 'Marketo Certified');
        Insert PL;

        Certification_History__c CH = new Certification_History__c(Account__c= A.Id, Certification_Contact__c= C.Id, Exam_Result__c = 'Pass', Date_Passed_Exam__c = date.today(), Certification_Level__c = 'Marketo Certified Expert');
        Insert CH;

        

        

        

        for(JBCXM__Milestone__c M : [SELECT Id FROM JBCXM__Milestone__c WHERE Id != null])
            {
                MilestoneList.add(M);
            }

        System.assertEquals(1, MilestoneList.size());


    }   
}