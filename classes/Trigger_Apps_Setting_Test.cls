@isTest
public class Trigger_Apps_Setting_Test {
	
    public static testmethod void testSettingInsert(){
        Account testAccount = new Account(Name = 'Test');
        insert testAccount;
        AppsSetting__c setting = new AppsSetting__c(Name='Test',
                                                     Bizible_Account_Id__c = testAccount.Id,
                                                   UniqueId__c = 'Test');
        insert setting;
    }
}