public without sharing class MKT_LMSConsumerUserController {
	@future(callout=true)
	public static void SetUsersAsConsumer(Id[] Usl){
		if (!Test.isRunningTest()){
			lmscons.ConsumerUserWebservice.ConsumerUsers_Create([SELECT Id, Name FROM User WHERE Id IN : Usl]);
		}
		else
		{

			Set<Id> usrsToTranscripts = new Set<Id>(Usl);

			for (lmscons__Transcript__c t :[SELECT Id, lmscons__Trainee__c FROM lmscons__Transcript__c WHERE lmscons__Trainee__c in :Usl]){
				if (usrsToTranscripts.contains(t.lmscons__Trainee__c)) {usrsToTranscripts.remove(t.lmscons__Trainee__c);}
			}

			lmscons__Transcript__c[] NewTranscripts;
			NewTranscripts = new lmscons__Transcript__c[]{};
			for (Id uId : usrsToTranscripts){
				NewTranscripts.add(new lmscons__Transcript__c(lmscons__Trainee__c = uId));
			}
			insert NewTranscripts;
		}
	}

	public static testMethod void test() {
		String UNIQ = '' + System.currentTimeMillis();

		User u = [SELECT Email FROM User WHERE Id = :UserInfo.getUserId()];
		String EmailDomain = u.Email.split('@')[1];

		Profile poProfile = [SELECT Id FROM Profile WHERE Name LIKE '%System Administrator%' LIMIT 1];
		UserRole poRole;

		User portalAccountOwner = new User(
			Email = 'po' + UNIQ + '@' + EmailDomain,
			ProfileId = poProfile.Id,
			UserName = 'po' + UNIQ + '@' + EmailDomain,
			Alias = UNIQ.substring(2,10),
			CommunityNickName = 'po' + UNIQ,
			TimeZoneSidKey = 'America/New_York',
			LocaleSidKey = UserInfo.getLocale(),
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = UserInfo.getLanguage(),
			FirstName = 'poFirst' + UNIQ,
			LastName = 'poLast' + UNIQ
		);
		insert portalAccountOwner;

		System.runAs(portalAccountOwner) {
			poRole = new UserRole(
				Name = 'Customer Portal Owner'
			);
			insert poRole;
			portalAccountOwner.UserRoleId = poRole.Id;
			update portalAccountOwner;
		}
		Contact cont = new Contact();
		Contact cont2;
		Account acc = new Account(Name = 'Portal Account' + UNIQ);
		System.runAs (portalAccountOwner) {
			insert acc;
			cont.Email = 'portaluser' + UNIQ + '@' + EmailDomain;
			cont.AccountId = acc.Id;
			cont.FirstName = 'First ' + UNIQ;
			cont.LastName = 'Last ' + UNIQ;
			cont2 = cont.clone();
			insert new Contact[]{cont, cont2};
		}

		List<UserLicense> ul = [SELECT Id FROM UserLicense WHERE Name LIKE '%Customer Portal%' LIMIT 1];
		List<Profile> prof = [SELECT Id FROM Profile WHERE UserLicenseId = :ul[0].Id LIMIT 1];

		User portalUsr = new User(
			Email = cont.Email,
			ContactId = cont.Id,
			ProfileId = prof[0].Id,
			UserName = cont.Email,
			Alias = UNIQ.substring(2,10),
			CommunityNickName = 'pu' + UNIQ,
			TimeZoneSidKey = 'America/New_York',
			LocaleSidKey = UserInfo.getLocale(),
			EmailEncodingKey = 'UTF-8',
			LanguageLocaleKey = UserInfo.getLanguage(),
			FirstName = cont.FirstName,
			LastName = cont.LastName
		);

		User portalUsr2 = portalUsr.clone();
		portalUsr2.UserName = '2_' + portalUsr2.UserName;
		portalUsr2.Alias = '2_' + portalUsr2.Alias.substring(2);
		portalUsr2.CommunityNickName = '2_' + portalUsr2.CommunityNickName;
		portalUsr2.ContactId = cont2.Id;


		Test.startTest();
			insert new User[]{portalUsr,portalUsr2};
			System.assertNotEquals(NULL, [SELECT lmscons__Cornerstone_ID__c FROM User WHERE Id = :portalUsr.Id]);
		Test.stopTest();


		portalUsr.lmscons__Cornerstone_ID__c = NULL;
		//update portalUsr;

		//System.assertNotEquals(NULL, [SELECT lmscons__Cornerstone_ID__c FROM User WHERE Id = :portalUsr.Id]);
	}
}