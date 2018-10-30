@isTest
private class TestActivitiesTriggerHandler{

   public static testmethod void testonTask(){
        List<UserRole> URole = [SELECT id from UserRole where Name = :Label.CAMRoleName limit 1];
      
        Account acc = Utility.insertAccountInTestClasses();
        insert acc;
        Contact con = Utility.insertContactInTestClasses(acc.ID);
        con.firstname='tesing';
		insert con;
        
        List<User> user =[SELECT id from User where UserRoleId =: URole[0].id and isactive = true limit 1];
        
        Lead ld = new Lead(Firstname = 'Test', lastName = 'Test',Company = 'Test Company', Status = 'Customer',Email='a@b.com');
        insert ld;
        Opportunity Opp = Utility.insertOpportunityInTestClasses(acc.id, null, 'A - Qualify', 'New Business',Date.Today(), system.today().addDays(1),system.today().addDays(7), null);               
        insert Opp;
        Task tsk1 = new Task(OwnerID = user[0].Id, Subject = 'Test Event', Status = 'In Progress',Priority = 'Low',WhoID= ld.id,CurrencyIsoCode = 'USD');
        insert tsk1;
        Task tsk2= new Task(ID=tsk1.ID);
        update tsk2;
        Task tsk3 = new Task(OwnerID = user[0].Id, Subject = 'Test Event', Status = 'In Progress',Priority = 'Low',WhatID= Opp.id,CurrencyIsoCode = 'USD');
        insert tsk3;
        Task tsk4= new Task(ID=tsk3.ID);
        update tsk4;
        
        Campaign c1 = new Campaign(Name='Test Campaign Sales Line', IsActive=true);
        insert c1;
        List <CampaignMember> lcm = new List <CampaignMember>();
        CampaignMember cm1 = new CampaignMember(CampaignId= c1.Id, LeadId= ld.Id );
        lcm.add(cm1);
        CampaignMember cm2 = new CampaignMember(CampaignId= c1.Id, ContactId= con.Id);
        lcm.add(cm2);
        insert lcm;
        
        Event ev1= new Event(OwnerID = user[0].Id, Subject = 'Test Event', StartDateTime = Date.Today(),EndDateTime= Date.Today(),WhoID= ld.id);
        insert ev1;
        event ev2 = new event(ID=ev1.ID);
        update ev2;
        Event ev3 = new Event(OwnerID = user[0].Id, Subject = 'Test Event', StartDateTime = Date.Today(),EndDateTime= Date.Today(),WhatID= Opp.id);
        insert ev3;
        event ev4 = new event(ID=ev3.ID);
        update ev4;
        
        List <Event> lstevn = new List <Event>();
        Event ev5 = new Event(OwnerID = user[0].Id, Subject = 'Meeting', StartDateTime = Date.Today(),EndDateTime= Date.Today(),WhoID= ld.id);
        lstevn.add(ev5);
        Event ev6 = new Event(OwnerID = user[0].Id, Subject = 'Meeting', StartDateTime = Date.Today(),EndDateTime= Date.Today(),WhoID= con.id);
        lstevn.add(ev6);
        insert lstevn ;
        
        Event ev7= new Event(OwnerID = user[0].Id, Subject = 'Vorsight', Meeting_Status__c = 'Completed', StartDateTime = Date.Today(),EndDateTime= Date.Today(),WhoID= con.id);
        insert ev7;
        
        delete tsk2;
        delete ev1;
   }
}