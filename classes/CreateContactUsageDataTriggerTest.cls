@istest
public class CreateContactUsageDataTriggerTest{
    static testmethod void mytest(){
        Account TestAcc1 = new Account(Name='Test Account');
        insert TestAcc1;
        
        GS_4Weekly_Usage_Data__c accUsageData = new GS_4Weekly_Usage_Data__c(
            Name = 'Test Acc Usage Data',
            Account__c = TestAcc1.id,
            Acct_Prefix__c = 'Test Acc Pre',
            Date__c = System.Today()
        );
        insert accUsageData;
        
        Test.StartTest();
        Contact con1 = new Contact(
            FirstName = 'Test First Name', 
            LastName = 'Test Last Name', 
            AccountId = TestAcc1.Id,
            Marketo_End_User__c = TRUE/*,
            Marketo_Usage_Report_Opt_In__c = TRUE*/
        );
        insert con1;
        
        GS_4Weekly_Usage_Data_Contact__c conUsageData = new GS_4Weekly_Usage_Data_Contact__c(
            Name = 'Test Acc Usage Data',
            Account__c = TestAcc1.id,
            Acct_Prefix__c = 'Test Acc Pre',
            Date__c = System.Today()
        );
        insert conUsageData;
        
        con1.User_Type_Admin__c = TRUE;
        update con1;
        
        Test.StopTest();
    }
}