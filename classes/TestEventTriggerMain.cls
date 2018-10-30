@isTest
private class TestEventTriggerMain{
    @testSetup static void setup(){
    list<Profile> pro = [SELECT id from profile where name = 'Sales User' limit 1];
    List<UserRole> Ur = [SELECT id from UserRole where Name = :Label.CAMRoleName limit 1];
    User u = new User(
     ProfileId  = pro[0].Id,
     FirstName = 'test',
     LastName = 'last',
     Email = 'puser000@amamama.com',
     Username = 'testpuser0@amamama.com',
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
    public static testmethod void testinsertEvent(){
       Account a = Utility.insertAccountInTestClasses();
       insert a;
       Contact c = Utility.insertContactInTestClasses(a.ID);
       insert c;
       
       Lead l = new Lead(Firstname = 'Test',Email ='gmackrell@canwdddest.com', lastName = 'Test',Company = 'Test Company', Status = 'Customer');
       insert l;
       user ur = [select id from user where LastName = 'last' limit 1]; 
       Event e = new Event(OwnerID = ur.ID, Subject = 'Test Event', StartDateTime = Date.Today(),EndDateTime= Date.Today(),WhoID= l.id);
       insert e;
       event ev = new event(ID=e.ID);
       update ev;
       }
}