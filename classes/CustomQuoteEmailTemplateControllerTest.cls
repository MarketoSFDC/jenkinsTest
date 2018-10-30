@istest
public class CustomQuoteEmailTemplateControllerTest{
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
               
         Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = TestAcc1.id,Rep_Create_ARR__c = 10,MainCompetitor__c = 'Act-On', StageName = 'Discovery', CloseDate=System.Today());
         insert opp;
         
         Quote quote = new Quote(Name = 'Test Quote', OpportunityId = opp.id);
         insert quote;
		 
		 CustomQuoteEmailTemplateController cs = new CustomQuoteEmailTemplateController();
         /*
         Apttus_Approval__Approval_Request__c appReq = new Apttus_Approval__Approval_Request__c();
         insert appReq;         

         CustomQuoteEmailTemplateController cq = new CustomQuoteEmailTemplateController();
         cq.quote = quote;
         cq.approvalRequestId = appReq.Id;
         
         List<QuoteLineItem> quoteLineList = new List<QuoteLineItem>();
        
         quoteLineList = cq.getQuoteLineItems();
         
         Apttus_Approval__Approval_Request__c aa = cq.getApprovalRequest();
         
         List<Apttus_Approval__Approval_Request__c> aaList = cq.getApprovalDetails();
		 */
     }
}