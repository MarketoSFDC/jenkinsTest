@isTest
private class Create_New_Agreement_Controller_Test {

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
            
            Quote quot = new Quote();
            quot.ContactId = c.Id;
            quot.Name='TestQuote';
            quot.OpportunityId = Opp.Id;
            insert quot;
            
            ApexPages.currentPage().getParameters().put('quoteId',quot.id);
            Create_New_Agreement_Controller agreementCont = new Create_New_Agreement_Controller();
            agreementCont.doRedirect();
            agreementCont.redirectToSelectQuotePdf();
            agreementCont.redirectToSignAgreement();

            

	}

}