@isTest 
private class SalesInvAftTrigTest{
    static testMethod void salesInvTest(){
        Account acc = new Account(Name = 'Test Account', BillingState = 'CA', BillingCountry = 'US', Type = 'Customer');        
        acc.BillingStreet = 'Test Street';  
        acc.RecordTypeId = '01250000000ULb7';      
        acc.BillingPostalCode ='12345';
        acc.ShippingCity ='Pune';
        acc.ShippingCountry ='India';
        acc.ShippingPostalCode = '12345';
        acc.ShippingState = 'Maharashtra';
        acc.ShippingStreet = 'Test Shipping Street';  
        acc.Accounting_Email__c = 'test@gmail.com';
        acc.Accounting_Contact_First_Name__c = 'FirstName';
        acc.Accounting_Contact_Last_Name__c = 'LastName';
        acc.Website = 'www.google.com';
        insert acc;
        Opportunity opp = new Opportunity(Name='Test Opp1',AccountId=acc.id,type='New Business',
           CloseDate=date.today(),StageName='Negotiation',Rep_Create_ARR__c = 10,MainCompetitor__c = 'Act-On',ownerid=UserInfo.getUserId());
        insert opp;
        Sales_Invoice__c salesinv1 = new Sales_Invoice__c (Payment_Status__c = 'Approved', Account__c=acc.id, Opportunity__c=opp.id,
           Document_Type__c = 'Test');
        insert salesinv1;
        salesinv1.Document_Type__c = 'Test1';
        update salesinv1;
        Sales_Invoice__c salesinv2 = new Sales_Invoice__c (Payment_Status__c = 'Partially Paid', Account__c=acc.id,  Opportunity__c=opp.id,
           Document_Type__c = 'Revenue Recognition Activation');
        insert salesinv2;
        delete salesinv2;
    }
}