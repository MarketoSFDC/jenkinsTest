@isTest()
public class sendAuthorizedContactAddedEmailUpdTest{
    static testMethod void testsendAuthorizedContactAddedEmail(){
        Support_Switches__c sw = new Support_Switches__c();
        sw.Name = 'BizibleSupportSwitch';
        sw.Isactive__C = 'Yes';
        insert sw;
        
        Account acct = new Account();
        acct.Name = 'TestAccounterOptimised';
        acct.Bizible_Customer__c = True;
        insert acct;
        
        Contact con2 = new Contact();
        con2.LastName = 'TestCon2Optimised1';
        con2.email ='Test2@test.com';
        con2.AccountId = acct.Id;
        insert con2; 
        
        Entitlement ent2 = new Entitlement();
        ent2.Name = 'Test Entitlement54321';
        ent2.AccountId = acct.Id;
        ent2.Type = 'Bizible Business';
        ent2.AssignedSupportPOC__c = UserInfo.getUserId();
        insert ent2;
        
        List<Authorized_Contact__c> listauth = new List<Authorized_Contact__c>();
        for(Integer i = 0; i<10 ; i++){
            listauth.add(new Authorized_Contact__c(Contact__c = con2.id,Entitlement__c = ent2.id));
        }
        insert listauth;
        Test.startTest();
        Test.stopTest();
        
    }
}