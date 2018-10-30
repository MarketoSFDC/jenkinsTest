@isTest
private class Preview_Document_ControllerTest {

	private static testMethod void test() {
	   
	        Account a = Utility.insertAccountInTestClasses();   
            a.BillingCountry = 'United States';
            a.BillingStreet = 'Test Street';
            a.BillingState ='Test Billing State';
            a.BillingPostalCode ='12345';
            a.ShippingCity ='Pune';
            a.ShippingCountry ='India';
            a.ShippingPostalCode = '12345';
            a.ShippingState = '';
            a.ShippingStreet = 'Test Shipping Street';     
            insert a;
            
            Contact c = Utility.insertContactInTestClasses(a.Id);
            insert c;
            
            Opportunity Opp = Utility.insertOpportunityInTestClasses(a.id, c.Id, 'Closed Won', 'Renewal',Date.Today(), system.today().addDays(1),system.today().addDays(7), null);        
            insert Opp;
            
	    	List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
            SBQQ__Quote__c testQuote = new SBQQ__Quote__c(SBQQ__Opportunity2__c = Opp.Id, SBQQ__StartDate__c = System.Today());
    		testQuote.Acct_Prefix_Requested__c = 'Test 123';
    		testQuote.SBQQ__BillingState__c = 'Maharashtra';
    		testQuote.SBQQ__ShippingCountry__c = 'India';
    		quoteList.add(testQuote);
    		
    		insert quoteList;
	    	Preview_Document_Component_Controller.validateGenerateDocument(quoteList[0].Id);

	}

}