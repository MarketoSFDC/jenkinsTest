@isTest
private class TestGainsightContactTrigger {
    
    @isTest static void TestUpdate() 
    {
        Account A = new Account(Name='Test');
        insert A;
        
        JBCXM__PickList__c PL = new JBCXM__PickList__c(JBCXM__Active__c=true,JBCXM__Category__c='Customer Status',JBCXM__SystemName__c='ActiveCustomer',Name='Active');
        insert PL;

        JBCXM__PickList__c PL2 = new JBCXM__PickList__c(JBCXM__Active__c=true,JBCXM__Category__c='Milestones',JBCXM__SystemName__c='Foundation Classroom',Name='Active');
        insert PL2;

        JBCXM__PickList__c PL3 = new JBCXM__PickList__c(JBCXM__Active__c=true,JBCXM__Category__c='Milestones',JBCXM__SystemName__c='Foundation Virtual',Name='Active');
        insert PL3;
        
        JBCXM__CustomerInfo__c CI = new JBCXM__CustomerInfo__c(JBCXM__Account__c=A.Id,JBCXM__ASV__c=0,JBCXM__MRR__c=0,JBCXM__Status__c=PL.Id);
        insert CI; 
        
        Contact C = new Contact(FirstName='Test',LastName='Gainsight',AccountId=A.Id,EDU_Foundation_Classroom_Attended__c=Date.Today(),EDU_Foundation_Virtual_Attended__c=Date.Today());
        insert C;
                
        C.EDU_Foundation_Classroom_Attended__c=Date.Today().addDays(8);
        update C;

        C.EDU_Foundation_Virtual_Attended__c=Date.Today().addDays(5);
        update C;
        
        Contact C1 = new Contact(FirstName='Test',LastName='Gainsight',AccountId=A.Id,EDU_Foundation_Classroom_Attended__c=Date.Today(),EDU_Foundation_Virtual_Attended__c=Date.Today());
        insert C1;
        delete C1;
    }
}