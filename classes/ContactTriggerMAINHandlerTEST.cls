@isTest
public class ContactTriggerMAINHandlerTEST{
    
    @TestSetup static void Method1(){
        Account a = Utility.insertAccountInTestClasses();
        insert a;
        List<Contact> ContactLists = new List<Contact>();
        
        Contact con = new Contact();
        
        Contact l = new Contact();
        l.LastName = '12Test1Contact 1';
        l.email = 'test@test.com';
        l.LeadSource = 'Blog';
        l.SDR_Owner__c = 'Aara Zakariaei';
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
        l2.SDR_Owner__c = 'Aara Zakariaei';
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
        l3.SDR_Owner__c = 'Aara Zakariaei';
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
        l4.SDR_Owner__c = 'Aara Zakariaei';
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
        
        //APPS-20374
        List<Account> acc_list = TestCPQUtilityClass.createAccounts(1);
        insert acc_list;
        opportunity opp1=new opportunity (name='TestOpp',Rep_create_arr__c=1,stagename='3 - Solution Definition',closedate=system.today());
        insert opp1;
        List<opportunity> opp_list=new list<opportunity>{opp1};
        List<pse__Proj__c> proj_List= TestCPQUtilityClass.createProject(opp_list,1); 
        List<pse__Practice__c> practice_List = TestCPQUtilityClass.CreatePractice(1);
        insert practice_List;
        Account acc = acc_list[0];
        contact con1 = new Contact(FirstName = 'Test1231223', LastName ='Test1', email= 'test@test.com', accountId= acc_list[0].Id,CE_Primary_Marketo_User__c=true);
        insert con1;
        Opportunity opp = opp_list[0];
        pse__Practice__c practice = practice_List[0];
        if(proj_List!=Null && proj_List.size()>0){
            for(pse__Proj__c Proj : proj_List){
                Proj.int_Intacct_Project_Category__c = 'Contract';
                Proj.pse__Practice__c = practice.id;
                Proj.pse__Account__c = acc.id;
                Proj.pse__Opportunity__c = opp.id;
                Proj.pse__Is_Active__c =true;
            }
        }
        insert proj_List;
        //APPS-20374   
    }
    
  static TestMethod void Method2(){
        List<Contact> NewContactList = new List<Contact>();
        map<id,Contact> NewContactList2 = new map<id,Contact>();
        for(Contact ld : [Select Id,Touch_Stage__c,Customer_Role__c from Contact Where LastName Like '12Test1Contact%' ]){
            NewContactList2.put(ld.id,ld);
            ld.Touch_Stage__c = 'Stage 1';
            NewContactList.add(ld);
            
        }
        if(NewContactList != null && !NewContactList.isEmpty()){
            update NewContactList;
        }
        
        try{ContactTriggerMAINHandler.afterDeleteHandler(NewContactList,NewContactList2);} catch(exception e){}
    }
    
    static TestMethod void Method3(){
        List<User> SDRUserList=[SELECT Id,Name,IsActive,Profile.Name,UserRole.Name FROM User where Profile.Name='Sales Development' and IsActive=True limit 4];
        
        List<Lead> leadLists = new List<Lead>();
        Lead l = new Lead();
        l.LastName = '12Test1Lead 1';
        l.Company = 'TestCompany';
        l.Touch_Stage__c = 'Untouched';
        l.NMQLA__c = True;
        l.Act_Now__c = True;
        l.Email  = 'gmackrell@canwest.com.full';
        l.Fresh_Lead__c = True;
        l.Call_Now__c = True;
        l.Last_Act_Now_Date__c = Date.today().addDays(5);
        l.Last_Call_Now_Date__c = Date.today().addDays(4);
        l.Last_NMQLA_Created_Date__c = Date.today().addDays(3);
        l.Fresh_Lead_Date__c = Date.today().addDays(1);
        leadLists.add(l);
        
        if(!leadLists.IsEmpty()){
            insert leadLists;
            
        }
        if(!leadLists.IsEmpty()){
            leadLists[0].OwnerId=SDRUserList[0].Id;
            update leadLists;
        }
        list <lead> newlead=new list <lead>();
        
        for(lead ld : [select id,touch_stage__c from lead]){
            ld.touch_stage__c ='Stage 1';
            newlead.add(ld);        
        }
        Database.LeadConvert lc = new database.LeadConvert();
        
        lc.setLeadId(newlead.get(0).Id); 
        
        LeadStatus convertStatus = [Select Id, MasterLabel from LeadStatus where IsConverted=true limit 1];
        
        lc.setConvertedStatus(convertStatus.MasterLabel); 
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        update newlead;    
    }
    
    static TestMethod void Method4(){
        
        List<Account> AccList=new List<Account>();
        List<Contact> ContList=new List<Contact>();
        
        List<User> SDRUserList=[SELECT Id,Name,IsActive,Profile.Name,UserRole.Name FROM User where Profile.Name='Sales Development' and IsActive=True limit 4];
        
        Account acc = new Account(Name = 'Test Account',Target_Account_1__c = 'Enterprise Target' ,LS_Deal_Score__c=200,LS_Account_Score__c=300,Account_Category__c='2018 Named Account',SDR_Owner_Picklist__c=SDRUserList[0].Name); 
        
        Account acc1= new Account(Name = 'Test Account1',Target_Account_1__c = 'Enterprise Target',SDR_Owner_Picklist__c=SDRUserList[1].Name);
        
        Account acc3= new Account(Name = 'Test Account1',Target_Account_1__c = 'Enterprise Target',SDR_Owner_Picklist__c=SDRUserList[2].Name);
        AccList.add(acc);
        AccList.add(acc1);
        AccList.add(acc3);
        
        if(!AccList.isEmpty()){
            insert AccList;
        }
        
        contact con1 = new Contact(FirstName = 'Test1231223', LastName ='Test1', email= 'tert@tets.com', accountId= AccList[0].Id,LS_Account_Score__c=200);
        
        contact con2 = new Contact(FirstName = 'Test1231224', LastName ='Test2', email= 'tert@tets.com', accountId= AccList[1].Id,Contact_Status__c='Opportunity',LS_Account_Score__c=200);
        
        contact con3 = new Contact(FirstName = 'Test12', LastName ='Test3', email= 'tert@tets.com', accountId= AccList[2].Id,Contact_Status__c='Lead',LS_Account_Score__c=200);
        
        ContList.add(con1);
        ContList.add(con2);
        ContList.add(con3);
        
        if(!ContList.isEmpty()){
            insert ContList;
        }     
    }
    //APPS-20374
    //This is testing the "updatePrimaryUserOnProjects" method in the ContactTriggerMAINHandler
    static TestMethod void Method5(){
        
         contact con1=[select id,CE_Primary_Marketo_User__c from contact where firstname='Test1231223' limit 1];
        //Create a Contact as the Primary Marketo User, which should update the project's Primary Contact
        test.startTest();
        con1.CE_Primary_Marketo_User__c = true;
        System.debug('Primary User: '+ con1.CE_Primary_Marketo_User__c);
        update con1;
        test.stopTest();
        contact testcontact=[select id,CE_Primary_Marketo_User__c from contact where id=:con1.id limit 1];
        system.assertEquals(testcontact.CE_Primary_Marketo_User__c ,true);
        //The Contact marked as the Primary Marketo User should be the Primary Contact on the Project 
        List<pse__Proj__c> updatedProject = [SELECT id, Primary_Contact__c FROM pse__Proj__c];
        system.assertEquals(con1.id, updatedProject[0].Primary_Contact__c);
    }
}