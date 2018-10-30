@isTest
global class TestGainsightUserGroupBatch implements Schedulable{
	
	static testMethod void GainsightUserGroupBatchTest() {

		// --------------- BEGIN SET UP --------------- //

		// Create new Account
		Account ACC = new Account(
			Name = 'Test Account'
			);
		insert ACC;


		// Create new Customer Info
		JBCXM__CustomerInfo__c CI = new JBCXM__CustomerInfo__c(
			JBCXM__Account__c = ACC.Id,
			JBCXM__MRR__c = 0,
			JBCXM__ASV__c = 0
			);
		insert CI;

		// Create Milestone Picklist
		JBCXM__Picklist__c PL = new JBCXM__Picklist__c(
			JBCXM__Category__c = 'Milestones',
			JBCXM__SystemName__c = 'User Group',
			Name = 'User Group',
			JBCXM__Active__c = true
			);
		insert PL;

		// Create new Milestone
		JBCXM__Milestone__c MS = new JBCXM__Milestone__c(
			JBCXM__Milestone__c = PL.Id,
			JBCXM__Account__c = ACC.Id,
			JBCXM__Date__c = Date.today()
			);
		insert MS;

		// Create new Contact
		Contact CON = new Contact(
			FirstName = 'Test',
			LastName = 'Name',
			AccountId = ACC.Id
			);
		insert CON;

		// Create new Campaign
		Campaign CAM = new Campaign(
			Name = 'Test User Group Attendees',
			StartDate = Date.valueOf('2013-09-01')
			);
		insert CAM;

		// Create new Campaign Member
		CampaignMember CM = new CampaignMember(
			ContactId = CON.Id,
			CampaignId = CAM.Id,
			Status = 'Attended'
			);
		insert CM;

		CM = [SELECT Id,Contact.AccountId,Campaign.StartDate,Campaign.Name FROM CampaignMember WHERE Id =:CM.Id];
		update CM;
		System.Debug('---> Campaign Name = ' + CAM.Name);
		System.Debug('---> Campaign Member Account ID = ' + CM.Contact.AccountId);
		System.Debug('---> Account ID = ' + ACC.Id);
		System.Debug('---> Contacts Account ID = ' + CON.AccountId);

		// ---------------- END SET UP ---------------- //



		Test.startTest();

		database.executebatch(new GainsightUserGroupBatch(), 1);

		Test.stopTest();

		database.executebatch(new GainsightUserGroupBatch(ACC.Id), 1);
	}

	// Test batch scheduling
	static testMethod void GainsightUserGroupBatchScheduleTest() 
	{
		GainsightUserGroupBatchSchedulable m = new GainsightUserGroupBatchSchedulable();
		string sch = '0 0 13 ? * SUN';
		system.schedule('Test Schedule', sch, m);
	}

	global void execute(SchedulableContext scMain) 
	{
		database.executebatch(new GainsightUserGroupBatch(), 1);
	}
}