@istest
public class QuoteCustomApprovalControllerTest{
     static testmethod void mytest(){
         Account TestAcc1 = new Account(Name='Test Account');
         TestAcc1.BillingCity = 'NewYork';
         TestAcc1.BillingCountry = 'United States';
         TestAcc1.BillingStreet = 'Test Street';
         TestAcc1.BillingState ='Test Billing State';
         TestAcc1.BillingPostalCode ='12345';
         TestAcc1.ShippingCity ='Pune';
         TestAcc1.ShippingCountry ='India';
         TestAcc1.ShippingPostalCode = '12345';
         TestAcc1.ShippingState = '';
         TestAcc1.ShippingStreet = 'Test Shipping Street';
         insert TestAcc1;
               
         Opportunity opp = new Opportunity(Name = 'Test Opportunity',AccountId = TestAcc1.id, StageName = 'Discovery', MainCompetitor__c ='Act-On',Rep_Create_ARR__c = 10, CloseDate=System.Today());
         insert opp;
         
         Quote quote = new Quote(Name = 'Test Quote', OpportunityId = opp.id);
         insert quote;
         QuoteCustomApprovalController cs = new QuoteCustomApprovalController();
         /*ApexPages.StandardController con = new ApexPages.StandardController(quote);
         ApexPages.CurrentPage().getParameters().put('id',quote.id);
         Test.StartTest();
         QuoteCustomApprovalController qc = new QuoteCustomApprovalController(con);
         qc.updateApprovalStatus();
         Test.StopTest();*/
     }
}