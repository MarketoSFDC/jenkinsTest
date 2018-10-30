/****************************************************
Class Name: QuoteExtControllerTest
Author: Rajesh wani
Created Date: 3rd April 2015
Usage: Test class for QuoteExtController controller
************************************************************************/
@istest
public class QuoteExtControllerTest {
    
    public static testmethod void QuoteExtTest(){
        // Insert Accounts
        List<Account> accountsToBeInsertedList = new List<Account>();
        accountsToBeInsertedList = TestCPQUtilityClass.createAccounts(1);
        for(Account accnt :accountsToBeInsertedList){
            accnt.name = 'Marketo Inc';
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
        }
        accountsToBeInsertedList[0].ABN_No__c=null;
       
        insert accountsToBeInsertedList;
        
        // Insert Opportunities
        List<Opportunity> OpptyToBeInsertedList = new List<Opportunity>();
        OpptyToBeInsertedList = TestCPQUtilityClass.createOpportunities(accountsToBeInsertedList,1);
        OpptyToBeInsertedList[0].type='Upsell';
      
        insert OpptyToBeInsertedList;
        
        
        // Insert Quotes
        List<SBQQ__Quote__c> quotesToBeInsertedList = new List<SBQQ__Quote__c>();
        quotesToBeInsertedList = TestCPQUtilityClass.createQuotes(OpptyToBeInsertedList,1);
        quotesToBeInsertedList[0].SBQQ__ShippingCountry__c=null;               
        quotesToBeInsertedList[0].SBQQ__Opportunity2__c=OpptyToBeInsertedList[0].Id;
       
        insert quotesToBeInsertedList;       
        //QuoteExtController Quotest = new QuoteExtController(new ApexPages.StandardController(quotesToBeInsertedList[0]));
        ApexPages.currentPage().getParameters().put('id', quotesToBeInsertedList[0].id);
        QuoteExtController Quotest = new QuoteExtController();
        PageReference onSubmitpage = Quotest.onSubmit();
        PageReference onRecallpage = Quotest.onRecall();
        PageReference onPreviewpage = Quotest.onPreview();
        
    }//End of method

}