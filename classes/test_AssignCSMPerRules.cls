@istest
public class test_AssignCSMPerRules{
@testSetup static void setup(){
    list<Profile> pro = [SELECT id from profile where name = 'Sales User'];
    List<UserRole> Ur = [SELECT id from UserRole where Name = :Label.CAMRoleName limit 1];
    User u = new User(
     ProfileId  = pro[0].Id,
     LastName = 'last',
     Email = 'putest00@testa.com',
     Username = 'test000@testfullcopy.com',
     CompanyName = 'TEST',
     Title = 'title',
     Alias = 'alias',
     TimeZoneSidKey = 'America/Los_Angeles',
     EmailEncodingKey = 'UTF-8',
     LanguageLocaleKey = 'en_US',
     LocaleSidKey = 'en_US',
     UserRoleId = Ur[0].Id,
     IsActive = TRUE
    );
    insert u;
    }
   static testmethod void mytest(){
       user u = [select id from user where lastName = 'last' limit 1];
    
    Assignment_Rule__c arule1=new Assignment_Rule__c(Rule_Name__c = 'Account CSM Assignment', 
           Business_Unit__c='APAC - Channel', Country__c = 'CA', Country_Code__c = 'n/a',
           State__c = 'n/a', State_Code__c = 'NC', Zip5__c = 'n/a', User__c=u.Id, Type__c='Customer');
      insert arule1;   
       
       
    Account TestAcc1 = new Account(Name='Test Account', type='Customer',RecordTypeId = '01250000000ULb7');
    insert TestAcc1;
    
    Account TestAcc3 = new Account(Name='Test Account', type='prospect',RecordTypeId = '01250000000ULc5', Business_Unit__c = 'APAC - Channel');
    insert TestAcc3;
    
    TestAcc3.type= 'Customer';
    TestAcc3.RecordTypeId = '01250000000ULb7';
    
    update TestAcc3;
   }
}