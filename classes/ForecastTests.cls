@isTest
private class ForecastTests {

	@isTest
	static void userIdsUnderRoleShouldBeEmptyForLowLevelPerson() {
		UserRole testRole = new UserRole(Name='bottom-dweller');
		insert testRole;
		System.assertEquals(new Id[]{}, Forecast.userIdsUnderRole(testRole.Id));
	}

	@isTest
	static void userIdsUnderRoleShouldOnlyShowUnderMyRole() {
		UserRole ceo = new UserRole(Name='test ceo');
		insert ceo;
		UserRole sales = new UserRole(Name='test sales', ParentRoleId=ceo.Id);
		insert sales;
		UserRole salesRep = new UserRole(Name='test sales rep', ParentRoleId=sales.Id);
		insert salesRep;

	}
	
	@isTest static void getTestUsersShouldNotThrowException() {
		(new Forecast()).getTestUsers();
	}

	// avoid test setup with seeAllData since roles are a given
	@isTest(seeAllData=true) static void rolesUnderRoleShouldGetIdsForCeo() {
		Forecast.rolesUnderRole([select Id from UserRole where Name='CEO' limit 1].Id);
	}

	@isTest
	static void callForecastRowShouldMakeNewRecords() {
        Date testPeriod = Date.newInstance(2000, 1, 1);
        User testUser = new User(Id='005000000000000', Category__c='CS NA', Categories__c='CS NA');
        Forecast__c[] testForecasts = new Forecast__c[]{};
        Forecast.ForecastRowGeneric row = Forecast.forecastRow(testPeriod, testForecasts, testUser, 'Call');
        row.ensureUserEntryForecastRecords(testPeriod, testUser, 'Call');
        System.assertNotEquals(null, row.cells.get(testUser.Category__c), row.cells);
    }
	
	@isTest
	static void addAmountToRowShouldCreateNewCell() {
		Forecast.ForecastRowGeneric row = new Forecast.ForecastRowGeneric('test', false);
		System.assertEquals(null, row.cells.get('test'));
		Forecast.addAmountToRow(row, 'test', 123.0);
		System.assertEquals(123.0, row.cells.get('test').forecast.Amount__c);
	}

	@isTest
	static void bookedForecastRowShouldFilterByCloseDate() {
		System.assertEquals(1, 
			Forecast.bookedForecastRow(
				Date.newInstance(2000, 2, 1),
				new Opportunity[]{
					(Opportunity)JSON.deserialize('{"attributes":{"type":"Opportunity"},"Owner":{"attributes":{"type":"User"},"Category__c":"Corporate"},"Amount":1, "Opportunity_ARR2012__c": 1,"CloseDate":"2000-01-01"}', Opportunity.class),
					(Opportunity)JSON.deserialize('{"attributes":{"type":"Opportunity"},"Owner":{"attributes":{"type":"User"},"Category__c":"Corporate"},"Amount":1, "Opportunity_ARR2012__c": 1,"CloseDate":"2000-02-01"}', Opportunity.class)
				}
			).cells.get('Corporate').forecast.Amount__c
		);
	}

	@isTest
	static void bookedForecastRowShouldAddMultipleOpps() {
		System.assertEquals(2, 
			Forecast.bookedForecastRow(
				Date.newInstance(2000, 2, 1),
				new Opportunity[]{
					(Opportunity)JSON.deserialize('{"attributes":{"type":"Opportunity"},"Owner":{"attributes":{"type":"User"},"Category__c":"Corporate"},"Amount":1, "Opportunity_ARR2012__c": 1,"CloseDate":"2000-02-01"}', Opportunity.class),
					(Opportunity)JSON.deserialize('{"attributes":{"type":"Opportunity"},"Owner":{"attributes":{"type":"User"},"Category__c":"Corporate"},"Amount":1, "Opportunity_ARR2012__c": 1,"CloseDate":"2000-02-01"}', Opportunity.class)
				}
			).cells.get('Corporate').forecast.Amount__c
		);
	}
	
    @isTest
    static void bookedForecastRowShouldNotErrorOnNull() {
    	Forecast.bookedForecastRow(
            Date.newInstance(2000, 2, 1),
            new Opportunity[]{
                new Opportunity(CloseDate=Date.newInstance(2000, 2, 1), Owner=new User(Category__c='Corporate')), // null amount
                new Opportunity(CloseDate=Date.newInstance(2000, 2, 1), Owner=new User(Category__c='Corporate')) // null amount
            }
        );
    } 

    @isTest
    static void forecastRowWithOpportunitiesCountShouldCount() {
    	Forecast.ForecastRowGeneric r = Forecast.forecastRowWithOpportunitiesCount(
    		Date.newInstance(1,1,2000), 
    		new Opportunity[]{
    			new Opportunity(
    				CloseDate = Date.newInstance(1,1,2000),
    				Owner = new User(Category__c='CS NA')
    			)
    		}
    	);
    	System.assertEquals(1, r.cells.get('CS NA').forecast.Amount__c);
    }

	// --- new tests above here

	/*
	@isTest
	static void testForecastRowLoadFromOpportunities() {
		Forecast.ForecastRow r = new Forecast.ForecastRow();
		r.period = Date.newInstance(2013, 1, 1);
		r.updateValuesFromOpportunities(new Opportunity[]{
			new Opportunity(CloseDate=r.period, Amount=1, Owner=new User(Category__c='Corporate')),
			new Opportunity(CloseDate=r.period.addMonths(1), Amount=1, Owner=new User(Category__c='Corporate'))
		});
		System.assertEquals(1, r.corporate.Amount__c);
	}
	*/

	/*
	@isTest
	static void testForecastRowLoadFromForecastRecords() {
		Forecast.ForecastRow r = new Forecast.ForecastRow();
		r.period = Date.newInstance(2013, 1, 1);
		r.updateValuesFromForecasts(new Forecast__c[]{
			new Forecast__c(Period__c=r.period, Amount__c=1, Category__c='Corporate'),
			new Forecast__c(Period__c=r.period.addMonths(-1), Amount__c=1, Category__c='Corporate'), // last quarter
			new Forecast__c(Period__c=r.period.addMonths(1), Amount__c=1, Category__c='Corporate'), // later this quarter
			new Forecast__c(Period__c=r.period.addMonths(3), Amount__c=1, Category__c='Corporate') // next quarter
		});
		System.assertEquals(1, r.corporate.Amount__c);
	}
	*/

	@isTest
	static void testUserOverride() {
		// selecting existing user because user insert takes 10 seconds
		User u = [select Id from User where IsActive = true and Id != :UserInfo.getUserId() limit 1];

		PageReference pr = Page.Forecast;
		pr.getParameters().put('userId', u.Id);
		Test.setCurrentPage(pr);

		Forecast controller = new Forecast();

		System.assertEquals(u.Id, controller.getUser().Id);
	}
	/*
	@isTest
	static void testBookedRowsFromOwnedOpp() {
		User u = new User();
		Forecast.ForecastRow[] rows = Forecast.bookedForecastRows(Date.newInstance(2013, 1, 1), u, new Opportunity[]{
			new Opportunity(Amount = 1, CloseDate = Date.newInstance(2013, 1, 1), Owner = new User(Category__c='Corporate')),
			new Opportunity(Amount = 1, CloseDate = Date.newInstance(2013, 1, 1), Owner = new User(Category__c='Corporate'))
		});
		System.assertNotEquals(null, rows);
		System.assertEquals(4, rows.size()); // 3 month rows and a qtd row
		System.debug('IGOTHERE: ' + rows);
		System.assertEquals(2, rows[0].corporate.Amount__c); // second slice in rows because first is a header
	}
	*/
	@isTest
	static void testQuarterNumber() {
		System.assertEquals(1, Forecast.quarterNumber(Date.newInstance(2013, 1, 1)));  // jan
		System.assertEquals(1, Forecast.quarterNumber(Date.newInstance(2013, 2, 1)));  // feb
		System.assertEquals(1, Forecast.quarterNumber(Date.newInstance(2013, 3, 1)));  // mar
		System.assertEquals(2, Forecast.quarterNumber(Date.newInstance(2013, 4, 1)));  // apr
		System.assertEquals(4, Forecast.quarterNumber(Date.newInstance(2013, 12, 1)));  // dec
	}

	@isTest	
	static void testQuarterMonthNumber() {
		System.assertEquals(1, Forecast.quarterMonthNumber(Date.newInstance(2013, 1, 1)));  // jan
		System.assertEquals(2, Forecast.quarterMonthNumber(Date.newInstance(2013, 2, 1)));  // feb
		System.assertEquals(3, Forecast.quarterMonthNumber(Date.newInstance(2013, 3, 1)));  // mar
		System.assertEquals(1, Forecast.quarterMonthNumber(Date.newInstance(2013, 4, 1)));  // apr
	}

	@isTest
	static void testLowerForecastLevels() {
		System.assertNotEquals(new String[]{}, Forecast.forecastLevelsBelow(null));
		System.assertEquals(new String[]{}, Forecast.forecastLevelsBelow('AE'));
	}

	@isTest
	static void testSubtract() {
		Forecast.ForecastRowGeneric left = new Forecast.ForecastRowGeneric('left', false);
		Forecast.ForecastCellGeneric leftA = new Forecast.ForecastCellGeneric();
		leftA.forecast = new Forecast__c(Amount__c=100);
		left.cells.put('A', leftA);
		Forecast.ForecastRowGeneric right = new Forecast.ForecastRowGeneric('right', false);
		Forecast.ForecastCellGeneric rightA = new Forecast.ForecastCellGeneric();
		rightA.forecast = new Forecast__c(Amount__c=95);
		right.cells.put('A', rightA);
		System.assertEquals(5, Forecast.subtract(left, right).cells.get('A').forecast.Amount__c);
	}

	// helpers

	// TODO move to TestUtil class

	private static Opportunity generateOpportunityWon(Account testAccount, User u) {
		Opportunity o = new Opportunity(
			AccountId = testAccount.Id,
			Name = 'test',
			Amount = 1,
			CloseDate = Date.today(),
			StageName = [select Id, MasterLabel from OpportunityStage where IsClosed = false and IsActive = true order by DefaultProbability asc limit 1].MasterLabel
		);
		return o;
	}

	private static Profile getSystemAdministratorProfileCache;
	public static Profile getSystemAdministratorProfile() {
		if (getSystemAdministratorProfileCache == null) {
			getSystemAdministratorProfileCache = [select Id, Name from Profile where Name = 'System Administrator'];
		}
		return getSystemAdministratorProfileCache;
	}

	public static User createUser() {
		User testUser = generateUser();
		insert testUser;
		return testUser;
	}

	public static User generateUser() {
		return new User(
			LastName = 'testing',
			UserName = 'testing@testing.com',
			profileId = getSystemAdministratorProfile().Id,
			alias = 'testing',
			email = 'testing@testing.com',
			emailEncodingKey = 'ISO-8859-1',
			languageLocaleKey = 'en_US',
			localeSidKey = 'en_US',
			timeZoneSidKey = 'America/Los_Angeles'
		);
	}

	public static Account createAccount() {
		Account a = generateAccount();
		insert a;
		return a;
	}

	public static Account generateAccount() {
		return new Account(
			Name = 'test'
		);
	}
}