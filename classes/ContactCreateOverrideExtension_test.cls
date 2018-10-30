/**************************************************************************************************************************************
Company Name  :Jade Global Inc.
Created Date  :10th February 2018
Apex Class    :ContactCreateOverrideExtension
**************************************************************************************************************************************/

@istest
Public class ContactCreateOverrideExtension_test {

    //insert account 
    Public static testmethod void  test1(){
        Set<Id> accountsToInsertSet = new Set<Id>();
        map<id, id> AccToCont = new Map<id,id>();
        List<Account> accountsToInsertList = new List<Account>();
        Id RecordTypeIdContact = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('PSA Resource').getRecordTypeId();
        for(Account accnt: TestCPQUtilityClass.createAccounts(2)){
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            accountsToInsertList.add(accnt);
        }
        insert accountsToInsertList;
         
        list<Contact> ContactToInsert = new list<Contact>();
        
        ContactToInsert = TestCPQUtilityClass.createContacts(accountsToInsertList,2);
        ContactToInsert[0].RecordTypeId =  RecordTypeIdContact;
        PageReference pageRef = Page.ContactCreateOverride;
       
        pageRef.getParameters().put('accid', String.valueOf(accountsToInsertList[0].Id));
        Test.setCurrentPage(pageRef);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ContactToInsert[0]);
        ContactCreateOverrideExtension PCFA = new ContactCreateOverrideExtension(sc); 
        boolean reDirectFlag = PCFA.getRedirect();
        Id recTypeId         = PCFA.getRecordTypeId();
    }
}