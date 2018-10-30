@isTest
private class ExcludeDocumentTypesTriggerTest{

    static testMethod void testTrigger(){
        Excluded_Sales_Order_Document_Type__c edt = new Excluded_Sales_Order_Document_Type__c(Name = 'Non-Standard Billing');
        insert edt;
        
        Account acc = new Account (Name = 'Test Account');
        acc.BillingCity = 'NewYork';
        acc.BillingCountry = 'United States';
        acc.BillingStreet = 'Test Street';
        acc.BillingState ='Test Billing State';
        acc.BillingPostalCode ='12345';
        acc.ShippingCity ='Pune';
        acc.ShippingCountry ='India';
        acc.ShippingPostalCode = '12345';
        acc.ShippingState = '';
        acc.ShippingStreet = 'Test Shipping Street';
        insert acc;
        
        String recordTypeId = [select id from RecordType where Name = 'Trial' and SObjectType = 'Opportunity'].id;
        
        Opportunity opp = new Opportunity (AccountId = acc.id, Name = 'Test Opportunity', RecordTypeId = recordTypeId, 
                                            StageName = 'Discovery',Rep_Create_ARR__c = 10,MainCompetitor__c = 'Act-On', CloseDate = System.Today());
        insert opp;
        
        Sales_Order__c salesOrder = new Sales_Order__c(Opportunity__c = opp.id, Document_Type__c = 'Non-Standard Billing');
        insert salesOrder;
    }
    
    static testMethod void testTrigger2(){
        Excluded_Sales_Order_Document_Type__c edt = new Excluded_Sales_Order_Document_Type__c(Name = 'Non-Standard Billing');
        insert edt;
    
        Account acc = new Account (Name = 'Test Account');
        acc.BillingCity = 'NewYork';
        acc.BillingCountry = 'United States';
        acc.BillingStreet = 'Test Street';
        acc.BillingState ='Test Billing State';
        acc.BillingPostalCode ='12345';
        acc.ShippingCity ='Pune';
        acc.ShippingCountry ='India';
        acc.ShippingPostalCode = '12345';
        acc.ShippingState = '';
        acc.ShippingStreet = 'Test Shipping Street';
        insert acc;
        
        String recordTypeId = [select id from RecordType where Name = 'Trial' and SObjectType = 'Opportunity'].id;
        
        Opportunity opp = new Opportunity (AccountId = acc.id, Name = 'Test Opportunity',Rep_Create_ARR__c = 10,MainCompetitor__c = 'Act-On', RecordTypeId = recordTypeId, 
                                            StageName = 'Discovery', CloseDate = System.Today());
        insert opp;
          
        
        Sales_Order__c salesOrder = new Sales_Order__c(Opportunity__c = opp.id, Document_Type__c = 'Sales Order New');
        insert salesOrder;
    }
    
}