@isTest
public class VistaAssetScheduledUtilityTest {

    static testmethod void assetEffYesterdayTest(){

        // CRON expression is for midnight March 15 2022
        // Because this is a test, job executes
        // immediately after Test.stopTest()
        String CRON_EXP = '0 0 0 15 3 ? 2022';

        Test.startTest();

        // create account
        Account acct = new Account();
        acct.Name = 'Test Method Account';
        acct.BillingCountry = 'USA';
        insert acct;

        // create vista asset
        Customer_Asset__c va = new Customer_Asset__c();
        va.Account__c = acct.Id;
        va.Asset_Status__c = 'Active';
        va.Decommission_Effective_Date__c = Date.today().addDays(-1);
        insert va;

        System.debug('Asset is: ' + va);

        // schedule the test job
        String jobId = System.schedule('ScheduledApexTestClass', CRON_EXP, new VistaAssetScheduledUtility());
        // get the info from the CronTrigger api
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];

        // verify the expressions are correct
        System.assertEquals(CRON_EXP, ct.CronExpression);
        // verify job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // verify next time job will run
        System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));

        // stop test
        Test.stopTest();
        // scheduled job should run after stopTest
        // check results
        Customer_Asset__c asset = [Select Id
                   , Name
                   , Asset_Status__c
                   , Decommission_Effective_Date__c
                   From Customer_Asset__c
                   Where Id = :va.Id];
        System.assertEquals('Decommissioned', asset.Asset_Status__c);
    }

    static testmethod void assetEffTodayTest(){

        // CRON expression is for midnight March 15 2022
        // Because this is a test, job executes
        // immediately after Test.stopTest()
        String CRON_EXP = '0 0 0 15 3 ? 2022';

        Test.startTest();

        // create account
        Account acct = new Account();
        acct.Name = 'Test Method Account';
        acct.BillingCountry = 'USA';
        insert acct;

        // create vista asset
        Customer_Asset__c va = new Customer_Asset__c();
        va.Account__c = acct.Id;
        // Alon Waisman 2017-04-18 (commented out line below because Name isn't writeable
        // va.Name = 'Test Asset';
        va.Asset_Status__c = 'Active';
        va.Decommission_Effective_Date__c = Date.today();
        insert va;

        System.debug('Asset is: ' + va);

        // schedule the test job
        String jobId = System.schedule('ScheduledApexTestClass', CRON_EXP, new VistaAssetScheduledUtility());
        // get the info from the CronTrigger api
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime
                          FROM CronTrigger WHERE id = :jobId];

        // verify the expressions are correct
        System.assertEquals(CRON_EXP, ct.CronExpression);
        // verify job has not run
        System.assertEquals(0, ct.TimesTriggered);
        // verify next time job will run
        System.assertEquals('2022-03-15 00:00:00', String.valueOf(ct.NextFireTime));

        // stop test
        Test.stopTest();
        // scheduled job should run after stopTest
        // check results
        Customer_Asset__c asset = [Select Id
                   , Name
                   , Asset_Status__c
                   , Decommission_Effective_Date__c
                   From Customer_Asset__c
                   Where Id = :va.Id];
        System.assertEquals('Active', asset.Asset_Status__c);
    }
}