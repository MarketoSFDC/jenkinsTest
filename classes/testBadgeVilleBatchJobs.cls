@istest
class testBadgeVilleBatchJobs{  
    /*
    @isTest public static void testBadgeVilleCallsBVBoulderLogic() 
    {    
        Test.startTest();
        
        Account acct = new Account(name='test account');
        insert acct;
        List<Contact> insrtCnt = new List<Contact>();

        Contact ct1 = new Contact(AccountId=acct.Id,lastname='testing1',firstname='apex',BL__SynchWithBoulderLogic__c = true);
        insrtCnt.add(ct1);
        Contact ct2 = new Contact(AccountId=acct.Id,lastname='testing2',firstname='apex',BL__SynchWithBoulderLogic__c =true);
        insrtCnt.add(ct2);
        Contact ct3 = new Contact(AccountId=acct.Id,lastname='testing3',firstname='apex',BL__SynchWithBoulderLogic__c = true);
        insrtCnt.add(ct3);
        insert (insrtCnt);
        
        
                
        List<Id> cnts = new List<Id>();
        cnts.add(ct1.Id);
        cnts.add(ct2.Id);
        cnts.add(ct3.Id);
                
        test.stopTest();                     
        
    }   
    
    */
    
    public static testmethod void testBadgeVilleCallsYearly() 
    {
        Test.startTest();
        Account acct = new Account(name='test account');
        insert acct;
        Contact ct = new Contact(AccountId=acct.Id,lastname='testing1',firstname='apex');
        insert ct; 
          
             
        List<CampaignMember> CM = new List<CampaignMember>();
        Campaign c = new Campaign(Name = 'TestingXYZ',  Type = 'Blog', StartDate =  Date.Today(),EndDate = Date.Today().addDays(100), Status = 'New');
        insert c;        
        CampaignMember cmp = new CampaignMember( CampaignId = c.Id, ContactId = ct.Id, Status = 'Attended');
        CM.add(cmp);
        insert CM;        
       
        test.stopTest();                     
    }   
    
    
    @isTest public static void testBadgeVilleCallsMonthly() 
    {
        Test.startTest();        
        Account acct = new Account(name='test account');
        insert acct;
        Contact ct = new Contact(AccountId=acct.Id,lastname='testing',firstname='apex');
        insert ct;
        Contact ct2 = new Contact(AccountId=acct.Id,lastname='testing2',firstname='apex2');
        insert ct2;

        //Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];         
        
        List<CampaignMember> CM = new List<CampaignMember>();
        Campaign c = new Campaign(Name = 'User Group Attendees',  Type = 'Blog', StartDate =  Date.Today(),EndDate = Date.Today().addDays(30), Status = 'New');
        insert c;        
        
        CampaignMember cmp = new CampaignMember( CampaignId = c.Id, ContactId = ct.Id, Status = 'Sent');

        CampaignMember cmp2 = new CampaignMember( CampaignId = c.Id, ContactId = ct2.Id, Status = 'Sent');
        CM.add(cmp);
        CM.add(cmp2);

        insert CM;                    

        test.stopTest();                     

    } 
    public static testmethod void testBVCallsAdvocateProgSignUps() 
    {
       Test.startTest();        
        Account acct = new Account(name='test account');
        insert acct;
        Contact ct = new Contact(AccountId=acct.Id,lastname='testing',firstname='apex');
        insert ct;
        Contact ct2 = new Contact(AccountId=acct.Id,lastname='testing2',firstname='apex2');
        insert ct2;

        //Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];         
        
        List<CampaignMember> CM = new List<CampaignMember>();
        //Campaign c = new Campaign(Name = 'User Group Attendees',  Type = 'Blog', StartDate =  Date.Today(),EndDate = Date.Today().addDays(30), Status = 'New');
        //insert c;        
        String AdvocateProgramSignUpsId = Label.AdvocateProgramSignUps;
        CampaignMember cmp = new CampaignMember( CampaignId = AdvocateProgramSignUpsId , ContactId = ct.Id, Status = 'Attended');

        CampaignMember cmp2 = new CampaignMember( CampaignId = AdvocateProgramSignUpsId , ContactId = ct2.Id, Status = 'Attended');
        CM.add(cmp);
        CM.add(cmp2);

        insert CM;                    

        test.stopTest();                     
                    
    }  
    
    
       
}