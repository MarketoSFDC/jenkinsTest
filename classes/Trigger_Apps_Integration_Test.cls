@isTest
public class Trigger_Apps_Integration_Test {
    public static testmethod void testIntegrationInsert(){
    	  Account testAccount = new Account(Name='Test');
    	insert testAccount;
        AppsIntegration__c testIntegration = new AppsIntegration__c(Name='Test',
                                                                   Bizible_Account_Id__c = testAccount.Id,
                                                                   AppsIntegrationType__c = 'Facebook',
                                                                   UniqueId__c = 'Test');
        insert testIntegration;
    }
}