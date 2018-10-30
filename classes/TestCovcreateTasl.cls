@isTest(seeAllData=true)
public class TestCovcreateTasl{
    public static testmethod void testingtrigger(){

        //SalesTriggersUtility.marketoTriggerManager.Activate_Legacy_Triggers__c = true;
		SalesTriggersUtility.Settruevaluesfortest();
        Trigger_Opportunity_Helper.isBeforeInsertEvent = true;
        Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
        Trigger_Opportunity_Helper.isAfterInsertEvent = true;
        Trigger_Opportunity_Helper.isAfterUpdateEvent = true;

        // role r = [select id from role where name = 'CustomerSuccess'];
        // List<Profile> Pro = [SELECT id from Profile where name = 'Customer Success' limit 1];
        List<UserRole> Ur = [SELECT id from UserRole where Name = :Label.CAMRoleName limit 1];
        List<User> u =[SELECT id from User where UserRoleId =: Ur[0].id and isactive = true limit 1];
        /*User u = new User(alias='standt',email='test@gmail.com',emailencodingkey='UTF-8',
                 lastname='testing',languagelocalekey='en_US',localesidkey='en_US',profileId=Pro[0].id,
                 timezonesidkey='America/Los_Angeles',username='stuser@testorg.com',UserRoleId=Ur[0].id);*/
        //user userr = [select id from user where userRoleId = '00E500000013aUZ' ] ;
        
        
        Account acc= new account();
        acc.name='Test Account';
        acc.CurrencyIsoCode='USD';
        //acc.Customer_Success_Manager__c=u[0].id;
        acc.CSM_Trigger__c = 'Elite/Key' ;
        acc.Date_Became_a_Customer__c = Date.Today();
        insert acc;
        
        Account acc1= new account();
        acc1.name='Test Account';
        acc1.CurrencyIsoCode='USD';
        //acc1.Customer_Success_Manager__c=u[0].id;
        acc1.CSM_Trigger__c = 'Enterprise';
        acc1.Date_Became_a_Customer__c = Date.Today();
        insert acc1;
        
        Account acc2= new account();
        acc2.name='Test Account';
        acc2.CurrencyIsoCode='USD';
        //acc2.Customer_Success_Manager__c=u[0].id;
        acc2.CSM_Trigger__c = 'Standard';
        acc2.Date_Became_a_Customer__c = Date.Today();
        insert acc2;
        
    }
}