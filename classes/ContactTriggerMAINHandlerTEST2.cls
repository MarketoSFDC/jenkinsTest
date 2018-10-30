@isTest
public class ContactTriggerMAINHandlerTEST2{

    @TestSetup static void Method1(){
		// SalesTriggersUtility.marketoTriggerManager.Activate_Legacy_Triggers__c = False;
        SalesTriggersUtility.Settruevaluesfortest();
        Account a = Utility.insertAccountInTestClasses();
        insert a;
        List<Contact> ContactLists = new List<Contact>();
        
        Contact con = new Contact();
        
        Contact l = new Contact();
        l.LastName = '12Test1Contact 1';
        l.email = 'test@test.com';
        l.LeadSource = 'Blog';
        l.AccountId = a.Id;
        l.Customer_Role__c = 'Decision Maker;End User;Executive Sponsor;Influencer;Power User';
        l.Touch_Stage__c = 'Untouched';
        l.NMQLA__c = True;
        l.Act_Now__c = True;
        l.Fresh_Lead__c = True;
        l.Call_Now__c = True;
        l.Last_Act_Now_Date__c = Date.today().addDays(5);
        l.Last_Call_Now_Date__c = Date.today().addDays(4);
        l.Last_NMQLA_Created_Date__c = Date.today().addDays(3);
        l.Fresh_Lead_Date__c = Date.today().addDays(1);
        ContactLists.add(l);
        
        Contact l2 = new Contact();
        l2.LastName = '12Test1Contact 2';
        l2.email = 'test@test.com';
        l2.LeadSource = 'Blog';
        l2.AccountId = a.Id;
        l2.Customer_Role__c = 'Decision Maker;End User;Executive Sponsor;Influencer;Power User';
        l2.Touch_Stage__c = 'Untouched';
        l2.NMQLA__c = True;
        l2.Fresh_Lead__c = True;
        l2.Call_Now__c = True;
        l2.Last_Act_Now_Date__c = Date.today().addDays(5);
        l2.Last_Call_Now_Date__c = Date.today().addDays(4);
        l2.Last_NMQLA_Created_Date__c = Date.today().addDays(3);
        l2.Fresh_Lead_Date__c = Date.today().addDays(1);
        ContactLists.add(l2);
        
        Contact l3 = new Contact();
        l3.LastName = '12Test1Contact 3';
        l3.email = 'test@test.com';
        l3.LeadSource = 'Blog';
        l3.AccountId = a.Id;
        l3.Customer_Role__c = 'Decision Maker;End User;Executive Sponsor;Influencer;Power User';
        l3.Touch_Stage__c = 'Untouched';
        l3.NMQLA__c = True;
        l3.Fresh_Lead__c = True;
        l3.Last_Act_Now_Date__c = Date.today().addDays(5);
        l3.Last_Call_Now_Date__c = Date.today().addDays(4);
        l3.Last_NMQLA_Created_Date__c = Date.today().addDays(3);
        l3.Fresh_Lead_Date__c = Date.today().addDays(1);
        ContactLists.add(l3);
        
        Contact l4 = new Contact();
        l4.LastName = '12Test1Contact 4';
        l4.email = 'test@test.com';
        l4.LeadSource = 'Blog';
        l4.AccountId = a.Id;
        l4.Customer_Role__c = 'Decision Maker;End User;Executive Sponsor;Influencer;Power User';
        l4.Touch_Stage__c = 'Untouched';
        l4.Fresh_Lead__c = True;
        l4.Last_Act_Now_Date__c = Date.today().addDays(5);
        l4.Last_Call_Now_Date__c = Date.today().addDays(4);
        l4.Last_NMQLA_Created_Date__c = Date.today().addDays(3);
        l4.Fresh_Lead_Date__c = Date.today().addDays(1);
        ContactLists.add(l4);
        
        if(ContactLists != null && !ContactLists.isEmpty()){
            insert ContactLists;
        }
        
    }
        
                
      
    
    static TestMethod void Method2(){
       //SalesTriggersUtility.marketoTriggerManager.Activate_Legacy_Triggers__c = False;
	    SalesTriggersUtility.Settruevaluesfortest();

        List<Contact> NewContactList = new List<Contact>();
        for(Contact ld : [Select Id,Touch_Stage__c from Contact Where LastName Like '12Test1Contact%' ]){
            ld.Touch_Stage__c = 'Stage 1';
            ld.Email ='a@a.com';
            ld.FirstName ='AAAA';
            ld.lastName ='ppppp';
            ld.title ='aaaaa11';
            ld.Phone= '12333';
            
            NewContactList.add(ld);
        }
        if(NewContactList != null && !NewContactList.isEmpty()){
            update NewContactList;
        }
    }
}