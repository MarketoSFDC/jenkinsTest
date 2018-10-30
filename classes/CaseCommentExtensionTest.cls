/*********************************************************************
* Last Modified by   : Grazitti 
* Modified Date      : 28-April-18
* Purpose            : #01009688 Consolidate Support Engineer Fields on Entitlement
* Line numbers       : 121,131,170,181,222,250,284

**********************************************************************/
@isTest()
public class CaseCommentExtensionTest {

     static testmethod void CaseCommentExtensionTestMethod(){
       case c =  new case();
       c.status = 'New';
       c.Problem_Type__c = 'How-to';
       c.Category__c= 'ABN';
       c.Sub_Category__c = 'Munchkin';
       c.recordtypeid =Label.CCareRecordTypeId18;
       insert c;
       
       case c1=  new case();
       c1.status = 'New';
       c1.Problem_Type__c = 'How-to';
       c1.Category__c= 'ABN';
       c1.Sub_Category__c = 'Munchkin';
       c1.recordtypeid =Label.CCareRecordTypeId18;
       insert c1;
       
       Case_Update_Milestones__c cm = new Case_Update_Milestones__c ();
       cm.case__c = c.id;
       cm.Milestone_Type__c = 'First Response';
       cm.Start_Date__c = System.Now();
       cm.Target_Date__c = System.Now().addMinutes(5);
       insert cm;
       
       case c11=  new case();
       c11.status = 'New';
       c11.Problem_Type__c = 'How-to';
       c11.Category__c= 'ABN';
       c11.Sub_Category__c = 'Munchkin';
       c11.recordtypeid =Label.tier3RecordTypeId;
       insert c11;
       
       Case_Update_Milestones__c cm1 = new Case_Update_Milestones__c ();
       cm1.case__c = c11.id;
       cm1.Milestone_Type__c = 'First Response';
       cm1.Start_Date__c = System.Now();
       cm1.Target_Date__c = System.Now().addMinutes(5);
       insert cm1;
       
       cm1.Milestone_Type__c = 'Resolution Response';
       cm1.Completed__c = true;
       update cm1;
       
       Case_Update_Milestones__c cm2 = new Case_Update_Milestones__c ();
       cm2.case__c = c.id;
       cm2.Milestone_Type__c = 'Resolution Response';
       cm2.Start_Date__c = System.Now();
       cm2.Target_Date__c = System.Now().addMinutes(5);
       insert cm2;
      
              
        ApexPages.StandardController controller = new ApexPages.StandardController(c);
        CaseCommentExtension f = new CaseCommentExtension(controller);
        PageReference pgRef = Page.CustomCaseFeed;
        Test.setCurrentPageReference(pgRef);
        f.addPrivateComment();
        f.addPublicComment();
        
        ApexPages.StandardController controller4 = new ApexPages.StandardController(c);
        CaseClosePageController cc = new CaseClosePageController(controller4);
        cc.saveRecords();
        
        ApexPages.StandardController controller2 = new ApexPages.StandardController(c);
        PageReference pgRef2 = Page.RoundProgressBar;
        Test.setCurrentPageReference(pgRef2); 
        System.currentPageReference().getParameters().put('id', c.Id);
        Graph g = new Graph(controller2);
        g.getPieData();
        g.getPieData2();
        g.CallActionPoller();
        
        ApexPages.StandardController controller3 = new ApexPages.StandardController(c1);
        PageReference pgRef3 = Page.RoundProgressBar;
        Test.setCurrentPageReference(pgRef3); 
        System.currentPageReference().getParameters().put('id', c.Id);
        Graph g1 = new Graph(controller3);
        g1.getPieData();
        g1.getPieData2();
        g1.CallActionPoller();
         
   }
   static testmethod void authrosiedTest(){
   SupportEmailSettings__c ss = new SupportEmailSettings__c();
   ss.name = 'Onboarding Reminder Notification';
   ss.RecordId__c = '00X38000001AhvK';
   insert ss;
   
   User newUser =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser', 'Mkto', 'cfsId');
        insert newUSer;
    Account acc = new Account();
                acc.Name = 'Test Account For Entitlement2';
                acc.CAM_Owner__c  = userInfo.getuserId();
        insert acc;
        
        Contact con = new Contact(
                FirstName = 'Tes1t',
                LAstName = 'Test',
                Email = 'test@test.com',
                Accountid =  acc.id   
            );
        insert con;
       
        Entitlement ent4 = new Entitlement();
                    ent4.AccountId = acc.id;
                    //ent4.Asset = as2;
                    ent4.Name = 'Test Entitlement54321';
                    ent4.EndDate = System.Now().Date().addDays(90);
                    ent4.StartDate = System.Now().Date().addDays(-90);
                    ent4.AccountId = acc.Id;
                    ent4.Type = 'Business';
                    ent4.AssignedSupportPOC__c = newUSer.id;
                    insert ent4;
                    
                   
                    
                    Authorized_Contact__c authCon = new Authorized_Contact__c(
                        Customer_Admin__c = false, contact__c = con.id, Entitlement__c = ent4.id,Email_read__c =false
                    ); 
                    insert authCon;
                    authCon.Email_read__c = true;
                    update authCon;
                    system.debug('ppp'+authCon.Entitlement__c +'ppp'+authCon.Entitlement__r.AssignedSupportPOC__c);
                    authCon.Video_Seen__c = true;
                    update authCon;
                    authCon.First_Reminder_Req__c =true;
                    update authcon;
                    authCon.Second_Reminder_Req__c = true;
                    update authCon;
          
   }
   static testmethod void authrosiedTest1(){
       SupportEmailSettings__c ss = new SupportEmailSettings__c();
       ss.name = 'Onboarding Reminder Notification';
       ss.RecordId__c = '00X38000001AhvK';
       insert ss;
       
       User newUser =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser', 'Mkto', 'cfsId');
            insert newUSer;
        Account acc = new Account();
                    acc.Name = 'Test Account For Entitlement2';
                    acc.CAM_Owner__c  = userInfo.getuserId();
            insert acc;
            
            Contact con = new Contact(
                    FirstName = 'Tes1t',
                    LAstName = 'Test',
                    Email = 'test@test.com',
                    Accountid =  acc.id   
                );
            insert con;
           
            Entitlement ent4 = new Entitlement();
                        ent4.AccountId = acc.id;
                        //ent4.Asset = as2;
                        ent4.Name = 'Test Entitlement54321';
                        ent4.EndDate = System.Now().Date().addDays(90);
                        ent4.StartDate = System.Now().Date().addDays(-90);
                        ent4.AccountId = acc.Id;
                        ent4.Type = 'Business';
                        ent4.AssignedSupportPOC__c = newUSer.id;
                        insert ent4;
                        
                       
                        
                        Authorized_Contact__c authCon = new Authorized_Contact__c(
                            Customer_Admin__c = false, contact__c = con.id, Entitlement__c = ent4.id,Email_read__c =false
                        ); 
                        insert authCon;
                        authCon.Email_read__c = true;
                        update authCon;
                        system.debug('ppp'+authCon.Entitlement__c +'ppp'+authCon.Entitlement__r.AssignedSupportPOC__c);
                        authCon.Video_Seen__c = true;
                        update authCon;
                        authCon.First_Reminder_Req__c =true;
                        authCon.Customer_Admin__c =false;
                        update authcon;
                        authCon.Second_Reminder_Req__c = true;
                        authCon.Customer_Admin__c =true;
                        update authCon;
          
   }
        static testmethod void authrosiedTest2(){
        SupportEmailSettings__c ss = new SupportEmailSettings__c();
        ss.name = 'Onboarding Reminder Notification';
        ss.RecordId__c = '00X38000001AhvK';
        insert ss;
        
        User newUser =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser', 'Mkto', 'cfsId');
            insert newUSer;
        Account acc = new Account();
                    acc.Name = 'Test Account For Entitlement2';
                    acc.CAM_Owner__c  = userInfo.getuserId();
            insert acc;
            
            Contact con = new Contact(
                    FirstName = 'Tes1t',
                    LAstName = 'Test',
                    Email = 'test@test.com',
                    Accountid =  acc.id   
                );
            insert con;
           
            Entitlement ent4 = new Entitlement();
                        ent4.AccountId = acc.id;
                        //ent4.Asset = as2;
                        ent4.Name = 'Test Entitlement54321';
                        ent4.EndDate = System.Now().Date().addDays(90);
                        ent4.StartDate = System.Now().Date().addDays(-90);
                        ent4.AccountId = acc.Id;
                        ent4.Type = 'Elite';
                        ent4.AssignedSupportPOC__c = newUSer.id;
                        insert ent4;
                        
                        case c11=  new case();
                        c11.status = 'New';
                        c11.ownerId = UserInfo.getUserId();
                        c11.Problem_Type__c = 'How-to';
                        c11.Category__c= 'ABN';
                        c11.Sub_Category__c = 'Munchkin';
                        c11.priority = 'P1';
                        c11.recordtypeid =Label.supportcaserecordtypeid;
                        c11.EntitlementId = ent4.Id;
                        insert c11;
                        
                        Case_Update_Milestones__c cm = new Case_Update_Milestones__c();
                        cm.Milestone_Type__c = 'Resolution Response';
                        cm.violation__c = false;
                        cm.case__c = c11.Id;
                        insert cm;
                        
                        cm.violation__c = true;
                        update cm;
                        
                        Authorized_Contact__c authCon = new Authorized_Contact__c(
                            Customer_Admin__c = false, contact__c = con.id, Entitlement__c = ent4.id,Email_read__c =false,Proactive_Email__c = True
                        ); 
                        insert authCon;
                        authCon.Email_read__c = true;
                        update authCon;
                        system.debug('ppp'+authCon.Entitlement__c +'ppp'+authCon.Entitlement__r.AssignedSupportPOC__c);
                        authCon.Video_Seen__c = true;
                        update authCon;
                        authCon.First_Reminder_Req__c =true;
                        update authcon;
                        authCon.Second_Reminder_Req__c = true;
                        update authCon; 
                        
              
        }
        static testmethod void authrosiedTest3(){
        User newUser =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser', 'Mkto', 'cfsId');
            insert newUSer;
        Account acc = new Account();
                    acc.Name = 'Test Account For Entitlement2';
                    acc.CAM_Owner__c  = userInfo.getuserId();
            insert acc;
            
            Contact con = new Contact(
                    FirstName = 'Tes1t',
                    LAstName = 'Test',
                    Email = 'test@test.com',
                    Accountid =  acc.id   
                );
            insert con;
           
            Entitlement ent4 = new Entitlement();
                        ent4.AccountId = acc.id;
                        //ent4.Asset = as2;
                        ent4.Name = 'Test Entitlement54321';
                        ent4.EndDate = System.Now().Date().addDays(90);
                        ent4.StartDate = System.Now().Date().addDays(-90);
                        ent4.AccountId = acc.Id;
                        ent4.Type = 'Microsoft';
                        ent4.AssignedSupportPOC__c = newUSer.id;
                        insert ent4;
        case c1=  new case();
        c1.status = 'New';
        c1.Problem_Type__c = 'How-to';
        c1.Category__c= 'ABN';
        c1.Sub_Category__c = 'Munchkin';
        c1.recordtypeid =Label.CCareRecordTypeId18;
        c1.priority = 'P1';
        c1.EntitlementId = ent4.Id;
        insert c1;
        
        Case_Update_Milestones__c cm = new Case_Update_Milestones__c ();
        cm.case__c = c1.id;
        cm.Milestone_Type__c = 'First Response';
        cm.Start_Date__c = System.Now();
        cm.Target_Date__c = System.Now().addMinutes(5);
        cm.Duration__c = '1440';
        insert cm;
        }
        @isTest static void ghostAccess(){
        Support_Trigger_Settings__c setting = new Support_Trigger_Settings__c();
        setting .Enable_Optimized_Trigger__c = true;
        setting.Name = 'Case Optimized Trigger Enabled';
        insert setting;
        Support_Switches__c sw3 = new Support_Switches__c();
        sw3.Name = 'GhostAccess';
        sw3.Isactive__C = 'Yes';
        Insert sw3;
        
        SupportEmailSettings__c see = new SupportEmailSettings__c();
        see.RecordId__c = '00X0x000000M2dP';
        see.Name = 'Marketo Customer Support';
        see.type__c = 'EmailTemplate';
        insert see;
        SupportEmailSettings__c se = new SupportEmailSettings__c();
        se.RecordId__c = '00X0x000000M2dP';
        se.Name = 'GhostAccessRequestAdmin';
        se.type__c = 'EmailTemplate';
        insert se;
        SupportEmailSettings__c sea = new SupportEmailSettings__c();
        sea.RecordId__c = '00X0x000000M2dP';
        sea.Name = 'GhostAccessRequest';
        sea.type__c = 'EmailTemplate';
        insert sea;
        
        
        
        User newUser =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser', 'Mkto', 'cfsId');
        newUser.ManagerId = UserInfo.getUserId();
        insert newUSer;
        
        Account acct = new Account();
        acct.Name = 'TestAccounterOptimised';
        acct.Sales_Region__c      = 'North America';
        acct.CAM_Owner__c = newUser.Id;
        acct.CAM_Group__c = 'AMER-SB+L60K';
        acct.Account_Ghost_Access__c = 'Never';
        acct.Account_Ghost_Access__c ='Never';
        insert acct;
        
        Contact con2 = new Contact();
        con2.LastName = 'TestCon2Optimised1';
        con2.email ='Test2@test.com';
        con2.AccountId = acct.Id;
        con2.LS_Account_Score__c = 88;
        insert con2; 
        
       
        Case cse = new Case();
        cse.AccountId = acct.Id;
        cse.recordtypeId = Label.SupportCaseRecordTypeId;
        cse.ContactId = con2.Id;
        cse.OwnerId = newUSer.Id;
        cse.Priority = 'P1'; 
        cse.subject = 'test';
        cse.status = 'New';
        cse.Category__c = 'ToutApp';
        cse.entitlementId = null;
        cse.Last_Public_Comment_Date_Time__c = System.Now();
        cse.status = 'Closed';
        cse.Ghost_Access_Status__c = 'Contact Requested';
        insert cse;
        
        Test.starttest();
        CaseHandler.isUpdatingCase = false;
        cse.Ghost_Access_Status__c = null;
        update cse;
        
        CaseHandler.isUpdatingCase = false;
        cse.Ghost_Access_Status__c = 'Admin Requested';
        update cse;
        Test.stoptest();
        
        
            
        ApexPages.currentPage().getParameters().put('id', String.valueOf(cse.id));
        ApexPages.currentPage().getParameters().put('status', 'Allowed');
        ApexPages.currentPage().getParameters().put('email', String.valueOf(con2.email));
        ApexPages.currentPage().getParameters().put('isAdmin', 'true');
        
        GhostAccessController cs = new GhostAccessController(); 
        cs.UpdateCaseGhostAccess();

        ApexPages.currentPage().getParameters().put('isAdmin', 'false'); 
        GhostAccessController csc = new GhostAccessController(); 
        csc.UpdateCaseGhostAccess();
        
        ghostcaseController gC = new ghostcaseController();
        gC.caseid = cse.id; 
        gC.getDynamicHtml();
            
    }
        @isTest(SeeAllData=true)
      static void escalatedCase(){
       //CaseTriggerFunctionUpdated.escalatedCase();
       
       User usr1 = [SELECT Id FROM User WHERE Id =: '00550000004KAuFAAW'];
    
        Account acc = new Account(Name = 'TestAccount1', Type = 'Prospect', CurrencyIsoCode = 'USD');
        insert acc;
        Contact con = new Contact(FirstName = 'TestContactF1', LastName = 'TestContactL1', LeadSource = 'Blog', Email = 'testcontactf1@gmail.com', AccountId = acc.Id);
        insert con;
    
       System.runAs(usr1) {
       Case cse1 = new Case(ContactId = con.Id, AccountId = acc.Id, recordTypeId = Label.supportcaserecordtypeid, Status = 'New', Origin = 'Phone', Priority = 'P3', Problem_Type__c = 'Alerts', Category__c = 'Abuse', Subject = 'test subj', Description = 'test desc');
       insert cse1;
       
       Case cs = new Case(ContactId = con.Id, AccountId = acc.Id, recordTypeId = Label.SituationManagementSupportRecTypeId, ParentId = cse1.Id,
       Status = 'New');
       insert cs;
       EveryHourScheduler sc = new EveryHourScheduler();
       sc.execute(null);
      }
    }
    public static testmethod void testCallout() {
        Article_Deflection__c adObj = new Article_Deflection__c();
        adObj.Article_ID__c = 'abc-yes';
        adObj.Article_ID__c = 'abc-no';
        adObj.Custom_Response__c = 'abc';
        adObj.Customer_Response_For_Yes__c = 'Testing';
        adObj.Title__c ='xyz';
        insert adObj;
    }
    public static testmethod void createProactiveCaseForSSLDomainTest() {
        Support_Trigger_Settings__c s = new Support_Trigger_Settings__c();
        s.name = 'Case Optimized Trigger Enabled';
        s.Enable_Optimized_Trigger__c = true;
        Insert s;
        
        Support_Switches__c sw3 = new Support_Switches__c();
        sw3.Name = 'SecuredDomainSSL';
        sw3.Isactive__C = 'Yes';
        Insert sw3;
        
        Case cs = new Case();
        cs.recordtypeId = Label.ProActiveCaseRecTypeId;
        cs.category__c ='SSL Certificate';
        Insert cs;
        
        Case cse = new Case();
        cse.recordtypeId =Label.SupportCaseRecordTypeId;
        cse.category__c = 'SSL';
        cse.Problem_Type__c = 'Configuration/Set-up';
        cse.parentId = cs.Id;
        Insert cse;
        
        CaseComment cc = new CaseComment();
        cc.parentId = cse.Id;
        cc.commentbody = 'Test Comment Body';
        Insert cc;
        
    }
}