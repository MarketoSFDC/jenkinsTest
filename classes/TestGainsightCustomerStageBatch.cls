@isTest
global class TestGainsightCustomerStageBatch implements Schedulable{
	
	static testMethod void GainsightCustomerStageBatch() {

		// --------------- BEGIN SET UP --------------- //

		// Create new Account
		Account A = new Account(
			Name = 'Test Account'
			);
        A.BillingCountry = 'United States';
        A.BillingStreet = 'Test Street';
        A.BillingState ='Test Billing State';
        A.BillingPostalCode ='12345';
        A.ShippingCity ='Pune';
        A.ShippingCountry ='India';
        A.ShippingPostalCode = '12345';
        A.ShippingState = '';
        A.ShippingStreet = 'Test Shipping Street';  
        A.Accounting_Email__c = 'test@gmail.com';
        A.Accounting_Contact_First_Name__c = 'FirstName';
        A.Accounting_Contact_Last_Name__c = 'LastName';
        A.Website = 'www.google.com';
		insert A;

		// Create new Customer Stage Picklist
		JBCXM__Picklist__c CS = new JBCXM__Picklist__c(
			JBCXM__Category__c = 'Customer Stage',
			JBCXM__SystemName__c = 'stage1',
			Name = 'Active',
			JBCXM__Active__c = true
			);
		insert CS;

		// Create new Project Start Milestone Picklist
		JBCXM__Picklist__c plMS = new JBCXM__Picklist__c(
			JBCXM__Category__c = 'Milestones',
			JBCXM__SystemName__c = 'Proj Start',
			Name = 'Milestone Start',
			JBCXM__Active__c = true
			);
		insert plMS;

		// Create new Opportunity
		Opportunity O =  new Opportunity(
			AccountID = A.ID,
			Name = 'Test Opportunity',
			Type = 'Renewal',
			StageName = 'Closed Won',
			CloseDate = Date.today()
			);
		insert O;

		// Create new Customer Info
		JBCXM__CustomerInfo__c CI = new JBCXM__CustomerInfo__c(
			JBCXM__Account__c = A.ID,
			JBCXM__ASV__c = 0,
			JBCXM__MRR__c = 0,
			JBCXM__Stage__c = CS.ID
			);
		insert CI;

		// Create new Milestone
		JBCXM__Milestone__c MS = new JBCXM__Milestone__c(
			JBCXM__Account__c = A.ID,
			JBCXM__Milestone__c = plMS.ID,
			JBCXM__Date__c = Date.today()
			);
		insert MS;

		// ---------------- END SET UP ---------------- //



		Test.startTest();

		database.executebatch(new GainsightCustomerStageBatch(), 1);

		Test.stopTest();

		// Change and update Milestone SystemName to Proj Complete
		plMS.JBCXM__SystemName__c = 'Proj Compl';
		update plMS;

		database.executebatch(new GainsightCustomerStageBatch(A.ID), 1);
	}

	// Test batch scheduling
	static testMethod void GainsightCustStageBatchSchedulableTest() {
		GainsightCustomerStageBatchSchedulable m = new GainsightCustomerStageBatchSchedulable();
		string sch = '0 0 13 ? * SUN';
		system.schedule('Test Schedule', sch, m);
	}

	global void execute(SchedulableContext scMain) {
		database.executebatch(new GainsightCustomerStageBatch(), 1);
	}
}