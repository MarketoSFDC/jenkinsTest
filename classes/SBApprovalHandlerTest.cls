@istest
(seealldata = true)
public class SBApprovalHandlerTest {
/****************************************************
Class Name: SBApprovalHandlerTest
Author: Brian Cherry
Created Date: 4/5/2018
Usage: Test class for SBApprovalHandler controller
************************************************************************/ 
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
        Test.startTest();

        ApexPages.currentPage().getParameters().put('id', quotesToBeInsertedList[0].id);
        QuoteExtController Quotest = new QuoteExtController();
        PageReference onSubmitpage = Quotest.onSubmit();
        PageReference onPreviewpage = Quotest.onPreview();
        List<sbaa__Approval__c> approvals = [SELECT ID from sbaa__Approval__c where CreatedDate = Last_N_Days:30 LIMIT 30];
        system.debug(approvals.size());
        system.assertnotEquals(null, approvals);
        List<ID> ids = new List<Id>();
        for (sbaa__approval__c a :approvals)
        {
            ids.add(a.id);
        }
        SBapprovalHandler.processApprovalEmails(ids);
        List<String> Emails = New List<String>();
        Set<String> groupIds = new Set<String>();
        Id templateid = '00X50000001fLWg';
        Id approvalid = approvals[0].id;
        groupIds.add('00G50000002J5Lg');
        emails.add('bcherry@marketo.com');
       
        SBapprovalHandler.sendEmailsFuture(approvalId,Emails,groupIds,templateId); 
        Test.stopTest();
    }
    
}