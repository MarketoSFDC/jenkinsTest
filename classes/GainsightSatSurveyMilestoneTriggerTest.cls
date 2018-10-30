@isTest 
private class GainsightSatSurveyMilestoneTriggerTest {
    static testMethod void validateGainsightSatSurveyMilestoneTrigger() {
       

        
        List<JBCXM__Milestone__c> MilestoneList = new List<JBCXM__Milestone__c>();

        Account A = new Account(Name= 'Test Account');
        Insert A;

        Contact C = new Contact(AccountId = A.Id, LeadSource = 'PPC', FirstName = 'First', LastName = 'Last');
        Insert C;

        JBCXM__CustomerInfo__c CI = new JBCXM__CustomerInfo__c(JBCXM__Account__c=A.Id);
        Insert CI;

        JBCXM__Picklist__c PL = new JBCXM__Picklist__c(Name = 'Test PL', JBCXM__Category__c = 'Milestone' , JBCXM__SystemName__c = 'Satisfaction Survey');
        Insert PL;

        Case CS = new Case(AccountId = A.Id, ContactId= C.Id,  Status = 'Closed');
        Insert CS;

        CSatSurveyFeedback__c CSV = new CSatSurveyFeedback__c(Account__c = A.Id, Contact__c = C.Id, Case__c = CS.Id, Question_1__c = '4' );
        Insert CSV;
        

        

        

        for(JBCXM__Milestone__c M : [SELECT Id FROM JBCXM__Milestone__c WHERE Id != null])
            {
                MilestoneList.add(M);
            }

        System.assertEquals(1, MilestoneList.size());


    }   
}