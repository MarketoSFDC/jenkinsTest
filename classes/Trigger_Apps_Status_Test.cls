@isTest
public class Trigger_Apps_Status_Test {
	
    public static testmethod void testStatusInsert(){
        Account testAccount = new Account(Name = 'Test');
        insert testAccount;
        AppsStatus__c testStatus = new AppsStatus__c(Name='Test',
                                                    Bizible_Account_Id__c = testAccount.Id,
                                                    UniqueId__c = 'Test',
                                                    AppsModifiedDate__c = Date.Today(),
                                                    AppsProgressDate__c = Date.Today());
        insert testStatus;
    }
}