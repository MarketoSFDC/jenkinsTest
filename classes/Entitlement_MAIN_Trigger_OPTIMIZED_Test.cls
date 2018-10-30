/**----------------------
WRITTEN BY: GRAZITTI
GOAL: TO COVER THE CODE COVERAGE ON NEW OPTIMIZED TRIGGER ON ENETTILEMENT
-------------------------**/
/*********************************************************************
* Last Modified by   : Grazitti Support 
* Modified Date      : 28-April-18
* Purpose            : #01009688 Consolidate Support Engineer Fields on Entitlement
* Line numbers       : 38,56,74,101,144,164,172,213,215,225,246,264,289

**********************************************************************/
@isTest
public class Entitlement_MAIN_Trigger_OPTIMIZED_Test{

    @testSetup static void getUserDataafterInser(){
        //SalesTriggersUtility.marketoTriggerManager.Activate_Legacy_Triggers__c = False;
        SalesTriggersUtility.Setvaluesfortest();
        User newUser =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'Ayush123', 'Sharma', '123456');
        insert newUSer;      
        
        Account acc = new Account();
                acc.Name = 'Test Account For Entitlement1';
                 acc.CAM_Owner__c = Userinfo.getUserId();
        insert acc;
        
        RobinRoundNSM1__c setting = new RobinRoundNSM1__c();
        setting.name = 'NSMcheckbox';
        setting.NSMrobin__c = true;
        setting.Counter__c = 1;
        insert setting;
        
        Entitlement ent2 = new Entitlement();
                    ent2.Name = 'Test Entitlement54321';
                    ent2.EndDate = System.Now().Date().addDays(90);
                    ent2.StartDate = System.Now().Date().addDays(-90);
                    ent2.AccountId = acc.Id;
                    ent2.Type = 'Elite';
                    ent2.AssignedSupportPOC__c = newUSer.Id;
        insert ent2;
    }
    
    static testMethod void insertEntitlementPremier(){
         //SalesTriggersUtility.marketoTriggerManager.Activate_Legacy_Triggers__c = False;
         SalesTriggersUtility.Setvaluesfortest();
        Account acc = new Account();
                acc.Name = 'Test Account For Entitlement2';
                 acc.CAM_Owner__c = Userinfo.getUserId();
        insert acc;
        List<Entitlement> EntLists = new List<Entitlement>();
        Entitlement ent = new Entitlement();
                    ent.Name = 'Test Entitlement';
                    ent.EndDate = System.Now().Date().addDays(90);
                    ent.StartDate = System.Now().Date().addDays(-90);
                    ent.AccountId = acc.Id;
                    ent.Type = 'Premier';
                    ent.AssignedSupportPOC__c = userInfo.getUserId();
        insert ent; 
        update ent;
    }
    static testMethod void insertEntitlementElite(){
       //SalesTriggersUtility.marketoTriggerManager.Activate_Legacy_Triggers__c = False;
       SalesTriggersUtility.Setvaluesfortest();
        Account acc = new Account();
                acc.Name = 'Test Account For Entitlement3';
                 acc.CAM_Owner__c = Userinfo.getUserId();
        insert acc;
        List<Entitlement> EntLists = new List<Entitlement>();
        Entitlement ent = new Entitlement();
                    ent.Name = 'Test Entitlement2';
                    ent.EndDate = System.Now().Date().addDays(90);
                    ent.StartDate = System.Now().Date().addDays(-90);
                    ent.AccountId = acc.Id;
                    ent.Type = 'Elite';
                    ent.AssignedSupportPOC__c = userInfo.getUserId();
        insert ent; 
        update ent;
        
    }
    static testMethod void insertEntitlementBusiness(){
        //SalesTriggersUtility.marketoTriggerManager.Activate_Legacy_Triggers__c = False;
        SalesTriggersUtility.Setvaluesfortest();
        Account acc = new Account();
                acc.Name = 'Test Account For Entitlement4';
                acc.CAM_Owner__c = Userinfo.getUserId();
        insert acc;
       
        Contact ccc = new Contact();
                ccc.LastName = 'Test Account For Entitlement';
                ccc.AccountId = acc.id;
                ccc.email = 'test@gmail.com';
        insert ccc;
        
        
        List<Entitlement> EntLists = new List<Entitlement>();
        Entitlement ent = new Entitlement();
                    ent.Name = 'Test Entitlement4';
                    ent.EndDate = System.Now().Date().addDays(90);
                    ent.StartDate = System.Now().Date().addDays(-90);
                    ent.AccountId = acc.Id;
                    ent.Type = 'Business';
                    ent.AssignedSupportPOC__c = Userinfo.getUserId();
                    ent.Support_Region__c = 'EMEA';
        insert ent; 
        UpdateEntitlements_Trigger.NSMIdNOperation nsmIDwithStatus = new UpdateEntitlements_Trigger.NSMIdNOperation ();
        nsmIDwithStatus.GetNSM_IdAnd_UpdateOperation('NS',true,1,null);
        nsmIDwithStatus.GetNSM_IdAnd_UpdateOperation('NS1',true,2,null);
        nsmIDwithStatus.GetNSM_IdAnd_UpdateOperation('NS1',true,3,null);
        nsmIDwithStatus.GetNSM_IdAnd_UpdateOperation('NS1',true,4,null);
        nsmIDwithStatus.GetNSM_IdAnd_UpdateOperation('NS1',true,5,null);
        
        //list<Authorized_Contact__c >auth = [select id, Entitlement__c,contact__c from Authorized_Contact__c where Contact__c!=null and Entitlement__c!= null limit 1];
        entitlement ent1 = [Select id from entitlement  where Name = 'Test Entitlement54321' limit 1];
        Authorized_Contact__c  Authr = new Authorized_Contact__c ();
        Authr.contact__c = ccc.Id;
        Authr.Entitlement__c = ent.Id;
        Authr.Customer_Admin__c  = true;
        
        insert Authr;
        ent.Support_Region__c = 'North America';
        update ent;
        
        UpdateEntitlements_Trigger.CreateNewCase(Authr);
        
        UpdateEntitlements_Trigger.SendnotificationToBusinessAuthCon(new List<Id>{ent.id});
        UpdateEntitlements_Trigger.BusinessEntCreationEmailtoCAM(new List<Id>{ent.id});

        
        
    }
    static testMethod void insertEntitlementOther(){
         //SalesTriggersUtility.marketoTriggerManager.Activate_Legacy_Triggers__c = False;
         SalesTriggersUtility.Setvaluesfortest();
        Account acc = new Account();
                acc.Name = 'Test Account For Entitlement5';
                 acc.CAM_Owner__c = Userinfo.getUserId();
        insert acc;
        List<Entitlement> EntLists = new List<Entitlement>();
        Entitlement ent = new Entitlement();
                    ent.Name = 'Test Entitlement3';
                    ent.EndDate = System.Now().Date().addDays(90);
                    ent.StartDate = System.Now().Date().addDays(-90);
                    ent.AccountId = acc.Id;
                    ent.Type = 'Internal';
                    ent.AssignedSupportPOC__c = userInfo.getUserId();
        insert ent; 
        update ent;
    }
    static testMethod void insertEntitlementMultiple(){
        //SalesTriggersUtility.marketoTriggerManager.Activate_Legacy_Triggers__c = False;
        SalesTriggersUtility.Setvaluesfortest();
        List<User> userList = new List<User>([Select Id from User Where FirstName = 'Ayush123']);
        Account acc = new Account();
                acc.Name = 'Test Account For Entitlement6';
                acc.Support_Point_Of_Contact__c = UserInfo.getUserId();
                 acc.CAM_Owner__c = Userinfo.getUserId();
        insert acc;
        List<Entitlement> EntLists = new List<Entitlement>();
        Entitlement ent = new Entitlement();
                    ent.Name = 'Test Entitlement4';
                    ent.EndDate = System.Now().Date().addDays(90);
                    ent.StartDate = System.Now().Date().addDays(-90);
                    ent.AccountId = acc.Id;
                    ent.Type = 'Internal';
                    ent.AssignedSupportPOC__c = userInfo.getUserId();
        insert ent; 
        Entitlement ent2 = new Entitlement();
                    ent2.Name = 'Test Entitlement5';
                    ent2.EndDate = System.Now().Date().addDays(90);
                    ent2.StartDate = System.Now().Date().addDays(-90);
                    ent2.AccountId = acc.Id;
                    ent2.Type = 'Elite';
                    ent2.AssignedSupportPOC__c = userList[0].Id;
        insert ent2;
        update ent2;
        delete ent2;
    }
    
    static testMethod void updateEntRec(){
        //SalesTriggersUtility.marketoTriggerManager.Activate_Legacy_Triggers__c = False;
        SalesTriggersUtility.Setvaluesfortest();
        List<Entitlement> entLists = new List<Entitlement>([Select Id from Entitlement Where Name = 'Test Entitlement54321']);
        update entLists;
    }

    static testMethod void insertEntitlementKickoff(){
    
        Profile p1 = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'Testu', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p1.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='testuseringss44@testorg.com'); 
        insert u;
        
         //SalesTriggersUtility.marketoTriggerManager.Activate_Legacy_Triggers__c = False;
         SalesTriggersUtility.Setvaluesfortest();
        Account acc = new Account();
                acc.Name = 'Test Account For Entitlement7';
                acc.CAM_Owner__c = userinfo.getuserid();                
        insert acc;
        
        Contact ccc = new Contact();
                ccc.LastName = 'Test Contact For Entitlement';
                ccc.AccountId = acc.id;
        insert ccc;       
        
        List<Entitlement> EntLists = new List<Entitlement>();
        Entitlement ent = new Entitlement();
                    ent.Name = 'Test Entitlement4';
                    ent.EndDate = System.Now().Date().addDays(90);
                    ent.StartDate = System.Now().Date().addDays(-90);
                    ent.AccountId = acc.Id;
                    ent.Type = 'Premier';
                    ent.AssignedSupportPOC__c = userinfo.getuserid();                               
        insert ent;
        ent.AssignedSupportPOC__c = u.Id;
        update ent;
        Map<id,entitlement> testMap1 = new MAp<id,entitlement> ();
        testMap1.put(ent.id,ent);
        
        Authorized_Contact__c  Authr = new Authorized_Contact__c();
        Authr.contact__c = ccc.Id;
        Authr.Entitlement__c = ent.Id;
        Authr.Customer_Admin__c = True;
        insert Authr;
        ent.AssignedSupportPOC__c = '00550000002QQWu';
        update ent;
        Map<id,entitlement> testMap2 = new Map<id,entitlement> ();
        testMap2.put(ent.id,ent);
        
        UpdateEntitlements_Trigger.SendEmailToNSEForPremiumEntitlements_OnUpdate(testMap2,testMap1);     
        
    } 
    static testMethod void SendEmailToNSEForPremiumEntitlements_OnInsertTest(){
        Account acc = new Account();
        acc.Name = 'Test Account For Entitlement8';
        acc.Support_Point_Of_Contact__c = UserInfo.getUserId();
        acc.CAM_Owner__c = Userinfo.getUserId();
        insert acc;
        List<Entitlement> EntLists = new List<Entitlement>();
        Entitlement ent = new Entitlement();
        ent.Name = 'Test Entitlement4';
        ent.EndDate = System.Now().Date().addDays(90);
        ent.StartDate = System.Now().Date().addDays(-90);
        ent.AccountId = acc.Id;
        ent.Type = 'Premier';
        ent.AssignedSupportPOC__c = userinfo.getuserid();                               
        EntLists.add(ent);
        insert EntLists;
        UpdateEntitlements_Trigger.SendEmailToNSEForPremiumEntitlements_OnInsert(EntLists);
    }
    static testMethod void createSMcaseforPremierEntitlementsTest(){
        Account acc = new Account();
        acc.Name = 'Test Account For Entitlement9';
        acc.Support_Point_Of_Contact__c = UserInfo.getUserId();
        acc.CAM_Owner__c = Userinfo.getUserId();
        insert acc;
        List<Entitlement> EntLists = new List<Entitlement>();
        Entitlement ent = new Entitlement();
        ent.Name = 'Test Entitlement4';
        ent.EndDate = System.Now().Date().addDays(90);
        ent.StartDate = System.Now().Date().addDays(-90);
        ent.AccountId = acc.Id;
        ent.Type = 'Premier';
        ent.AssignedSupportPOC__c = null;                              
        EntLists.add(ent);
        insert EntLists;
        Set<Id> entIds = new Set<Id>();
        for(Entitlement et: EntLists){
            entIds.add(et.Id);
        }
        UpdateEntitlements_Trigger.createSMcaseforPremierEntitlements(entIds);
    }
    static testMethod void NotifyNewPremierCustomerTest(){
        Account acc = new Account();
        acc.Name = 'Test Account For Entitlement10';
        acc.Support_Point_Of_Contact__c = UserInfo.getUserId();
        acc.CAM_Owner__c = Userinfo.getUserId();
        insert acc;
        Contact con = new Contact();
        con.lastname = 'test';
        con.accountid = acc.Id;
        insert con;
        Entitlement ent = new Entitlement();
        ent.Name = 'Test Entitlement4';
        ent.EndDate = System.Now().Date().addDays(90);
        ent.StartDate = System.Now().Date().addDays(-90);
        ent.AccountId = acc.Id;
        ent.Type = 'Elite';
        ent.AssignedSupportPOC__c = userinfo.getuserid();                               
        insert Ent;
        ent.Type = 'Premier';
        update Ent;
        Authorized_Contact__c  Authr = new Authorized_Contact__c();
        Authr.contact__c = con.Id;
        Authr.Entitlement__c = ent.Id;
        insert Authr;
        Map<Id,Id> accMap = new  Map<Id,Id>();
        accMap.put(acc.Id,ent.Id);
        UpdateEntitlements_Trigger.NotifyNewPremierCustomer(new List<Id>{Ent.Id});
        
    }
     static testMethod void ProactiveCaseForSecuredDomainsTest(){
        Account acc = new Account();
        acc.Name = 'Test Account For Entitlement11';
        acc.Support_Point_Of_Contact__c = UserInfo.getUserId();
        acc.CAM_Owner__c = Userinfo.getUserId();
        insert acc;
        Opportunity opp = new Opportunity();
        opp.Name      = 'GRAZITTI TEST OPPORTUNITY 12';
        opp.AccountId = acc.Id;
        opp.Type      = 'Renewal';
        opp.StageName = 'Closed Won';
        opp.Sub_End_Date__c      = System.Today().addMonths(1);
        opp.Amount   = 10000;
        opp.Engagement_Manager__c = UserInfo.getUserId();
        opp.SBQQ__Contracted__c = true;
        opp.Intacct_Sales_Region__c = '';
        opp.Owner_Role_Custom_Text__c = 'ANZ PS';
        opp.Rep_Create_ARR__c=1;
        opp.MainCompetitor__c='Act-On';
        opp.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get(Label.OPPORTUNITY_STAGE_CLOSED_WON).getRecordTypeId();
        opp.CloseDate = System.Now().Date();
        opp.Use_Case__c ='B2B';
        insert opp;
        
        Entitlement ent = new Entitlement();
        ent.Name = 'Test Entitlement4';
        ent.EndDate = System.Now().Date().addDays(90);
        ent.StartDate = System.Now().Date().addDays(-90);
        ent.opportunity__c = opp.Id;
        ent.AccountId = acc.Id;
        ent.Type = 'Secured Landing Pages';               
        insert Ent;
        
        Map<Id,Id> accMap = new  Map<Id,Id>();
        accMap.put(acc.Id,ent.Id);
        UpdateEntitlements_Trigger.ProactiveCaseForSecuredDomains(accMap);
        
    }

}