@isTest
public class VistaAssetExpiredBatchableTest {

    static testmethod void testSchedule() {
        List<Customer_Asset__c> custAcc= new List<Customer_Asset__c>();
        Customer_Asset__c caExpire = setupCustomerAsset();
        caExpire.Term_End_Date__c = System.today().addDays(-1);
        custAcc.add(caExpire);       
       //insert caExpire;
        
        Customer_Asset__c caNonExpire = setupCustomerAsset();
        caNonExpire.Term_End_Date__c = System.today().addDays(2);
        custAcc.add(caNonExpire); 
        //insert caNonExpire;
        
        Customer_Asset__c caDecomm = setupCustomerAsset();
        caDecomm.Decommission_Effective_Date__c = System.today();
        custAcc.add(caDecomm); 
        //insert caDecomm;
        
        Customer_Asset__c caNonDecomm = setupCustomerAsset();
        caNonDecomm.Decommission_Effective_Date__c = System.today().addDays(2);
        custAcc.add(caNonDecomm); 
        //insert caNonDecomm;
        
        insert custAcc;
        
        DateTime future = system.now().addMinutes(1);
        Integer year = future.year();
        Integer month = future.month();
        Integer day = future.day();
        Integer hour = future.hour();
        Integer minute = future.minute();
        Integer second = future.second();
        String cron_exp = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?' + ' ' + year;            

        Test.startTest();
        VistaAssetExpiredSchedule scheduler = new VistaAssetExpiredSchedule();
        String jobId = System.schedule('testBasicScheduledApex',
                                       cron_exp, scheduler);
        
        // Get the information from the CronTrigger API object
        CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
                          NextFireTime
                          FROM CronTrigger WHERE id = :jobId];
        
        // Verify the expressions are the same
        System.assertEquals(cron_exp, 
                            ct.CronExpression);
        

        
        // Verify the job has not run
        System.assertEquals(0, ct.TimesTriggered);
        scheduler.execute(null);
        Test.stopTest();
        
        Map<Id, Customer_Asset__c> queriedCustomerAssetMap = new Map<Id, Customer_Asset__c>([SELECT Id, Asset_Status__c FROM Customer_Asset__c]);
        system.assertEquals(queriedCustomerAssetMap.get(caExpire.Id).Asset_Status__c, 'Expired');
        system.assertEquals(queriedCustomerAssetMap.get(caDecomm.Id).Asset_Status__c, 'Decommissioned');
        system.assertEquals(queriedCustomerAssetMap.get(caNonDecomm.Id).Asset_Status__c, 'Active');
        system.assertEquals(queriedCustomerAssetMap.get(caNonExpire.Id).Asset_Status__c, 'Active');   
    }
    private static Customer_Asset__c setupCustomerAsset() {
        VistaAssetHelperUtil util = new VistaAssetHelperUtil();
        Account a = util.createAccount('testacctBatchable');
        Customer_Asset__c ca = new Customer_Asset__c(Quantity__c = 1, Account__c = a.Id, Asset_Status__c = 'Active', Term_Start_Date__c = System.today().addDays(-365));
        return ca; 
        
    }
}