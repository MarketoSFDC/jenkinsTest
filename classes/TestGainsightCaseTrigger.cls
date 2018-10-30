@isTest
private class TestGainsightCaseTrigger {
	
	static testMethod void GainsightCaseTriggerTest() {

		// --------------- BEGIN SET UP --------------- //

		// Create new Account
		Account A = new Account(
			Name = 'Test Account'
			);
		insert A;

		// Create new Customer Status Picklist
		JBCXM__Picklist__c plCS = new JBCXM__Picklist__c(
			JBCXM__Category__c = 'Customer Status',
			JBCXM__SystemName__c = 'ActiveCustomer',
			JBCXM__Active__c = true,
			Name = 'TEST Customer Status PL'
			);
		insert plCS;

		// Create new Customer Info
		JBCXM__CustomerInfo__c CI = new JBCXM__CustomerInfo__c(
			JBCXM__Account__c = A.ID,
			JBCXM__Status__c = plCS.ID,
			JBCXM__MRR__c = 0,
			JBCXM__ASV__c = 0
			);
		insert CI;

		// Create Alert Severity Picklist
		JBCXM__Picklist__c plASev = new JBCXM__Picklist__c(
			JBCXM__Category__c = 'Alert Severity',
			JBCXM__SystemName__c = 'alertseverity1'
			);
		insert plASev;

		// Create Alert Status Picklist
		JBCXM__Picklist__c plAStat = new JBCXM__Picklist__c(
			JBCXM__Category__c = 'Alert Status',
			JBCXM__SystemName__c = 'ID'
			);
		insert plAStat;

		// Create Alert Type Picklist
		JBCXM__Picklist__c plAT = new JBCXM__Picklist__c(
			JBCXM__Category__c = 'Alert Type',
			JBCXM__SystemName__c = 'Customer Concern'
			);
		insert plAT;

		// Create Alert Reason Picklist
		JBCXM__Picklist__c plAR = new JBCXM__Picklist__c(
			JBCXM__Category__c = 'Alert Reason',
			JBCXM__SystemName__c = 'OpenCase'
			);
		insert plAR;

		// ---------------- END SET UP ---------------- //



		// Create new Case and test isInsert
		Case C = new Case(
			AccountID = A.ID,
			Priority = 'P1'
			);
		insert C;

		// Update Case priority to anything other than P1, then back to P1
		C.Priority = 'P2';
		update C;
		C.Priority = 'P1';

		// Test updating Case to priority P1
		test.startTest();
		update C;
		test.stopTest();

		// Test isDelete
		delete C;
	}
}