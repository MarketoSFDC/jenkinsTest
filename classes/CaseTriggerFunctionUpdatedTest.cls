@isTest()
public class CaseTriggerFunctionUpdatedTest{
    
       public static void createCusSetting(){
           List<Support_Switches__c> swList = New List<Support_Switches__c>();
           Support_Switches__c sw1 = new Support_Switches__c();
           sw1.Name = 'AccessMarketoSupportEasy';
           sw1.Isactive__C = 'Phase1';
           swList.add(sw1);
           Support_Switches__c sw2 = new Support_Switches__c();
           sw2.Name = 'AfterHoursRedistribution';
           sw2.Isactive__C = 'Yes';
           swList.add(sw2);
           
           Support_Switches__c sw3 = new Support_Switches__c();
           sw3.Name = 'DedicatedTamSla';
           sw3.Isactive__C = 'Yes';
           swList.add(sw3);
           
           Support_Switches__c sw4 = new Support_Switches__c();
           sw4.Name = 'duplicateCommentSwitch';
           sw4.Isactive__C = 'Yes';
           swList.add(sw4);           
           
           Support_Switches__c sw5 = new Support_Switches__c();
           sw5.Name = 'enableAssignmentRule';
           sw5.Isactive__C = 'Yes';
           swList.add(sw5);
           
           Support_Switches__c sw6 = new Support_Switches__c();
           sw6.Name = 'ProactiveOpenCasesBatchSwitch';
           sw6.Isactive__C = 'Yes';
           swList.add(sw6);
           
           Support_Switches__c sw7 = new Support_Switches__c();
           sw7.Name = 'ProactometerBatchSwitch';
           sw7.Isactive__C = 'Yes';
           swList.add(sw7);
           
           Support_Switches__c sw8 = new Support_Switches__c();
           sw8.Name = 'UpdateTier3OwnerField';
           sw8.Isactive__C = 'Yes';
           swList.add(sw8);
           
           Support_Switches__c sw9 = new Support_Switches__c();
           sw9.Name = 'updateEscalationOwner';
           sw9.Isactive__C = 'Yes';
           swList.add(sw9);
           
           Support_Switches__c sw10 = new Support_Switches__c();
           sw10.Name = 'CSMOwnerForCERSwitch';
           sw10.Isactive__C = 'Yes';
           swList.add(sw10);
           
           Support_Switches__c sw11 = new Support_Switches__c();
           sw11.Name = 'SecuredDomainSSL';
           sw11.Isactive__C = 'Yes';
           swList.add(sw11);
           
           Support_Switches__c sw12 = new Support_Switches__c();
           sw12.Name = 'BizibleSupportSwitch';
           sw12.Isactive__C = 'Yes';
           swList.add(sw12);
           
           insert swList;
           SupportEmailSettings__c ss = new SupportEmailSettings__c();
           ss.name = 'Marketo Support Feedback';
           ss.RecordId__c = '0D250000000KzBPCA0';
           ss.type__c = 'OrgWideEmailAddresses';
           insert ss;
           
       }
       
       @testSetup static void InsertCaseMethod(){
        Test.StartTest();
        createCusSetting();        
        Support_Trigger_Settings__c setting = new Support_Trigger_Settings__c();
        setting .Enable_Optimized_Trigger__c = true;
        setting.Name = 'Case Optimized Trigger Enabled';
        insert setting;
        
        Case_Statuses__c cst = new Case_Statuses__c();
        cst.Name = 'Case Status';
        cst.Ignore_Case_Status_Values__c = 'New,Needs Reply';
        cst.Non_Ignore_Case_Status_Values__c ='Awaiting Customer Input,Closed';
        insert cst;
        
        User newUser =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser', 'Mkto', 'cfsId');
        newUser.ManagerId = UserInfo.getUserId();
        insert newUSer;
         
        
        Account acct = new Account();
        acct.Name = 'TestAccounterOptimised';
        acct.Sales_Region__c      = 'North America';
        acct.CAM_Owner__c = newUser.Id;
        acct.CAM_Group__c = 'AMER-SB+L60K';
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
        insert cse;
        
        Case cs = new Case();
        cs.recordtypeId = Label.tier3RecordTypeId;
        cs.Category__c = 'ToutApp';
        cs.Problem_Type__c = 'How-to';
        cs.Sub_Category__c = 'Munchkin';
        cs.parentId = cse.Id;
        cs.status = 'New';
        insert cs;
        
        Case_Update_Milestones__c cm = new Case_Update_Milestones__c();
        cm.case__c = cse.Id;
        cm.ownerId = cse.OwnerId;
        cm.Start_Date__c = system.now();
        cm.Duration__c = '3600';
        cm.Milestone_Type__c = 'First Response';
        insert cm;
        
        Case_Update_Milestones__c cm2 = new Case_Update_Milestones__c();
        cm2.case__c = cse.Id;
        cm2.ownerId = cse.OwnerId;
        cm2.Start_Date__c = system.now();
        cm2.Duration__c = '3600';
        cm2.Milestone_Type__c = 'Case Update';
        insert cm2;
        test.stopTest();
        
        Case_Update_Milestones__c cm3 = new Case_Update_Milestones__c();
        cm3.case__c = cse.Id;
        cm3.ownerId = cse.OwnerId;
        cm3.Start_Date__c = system.now();
        cm3.Duration__c = '3600';
        cm3.Milestone_Type__c = 'Resolution Response';
        insert cm3;
        
        Global_SLA__c sla2 = new Global_SLA__c();
        sla2.Priority__c = 'P1';
        sla2.Recordtype_Id__c = Label.SupportCaseRecordTypeId;
        sla2.Resolution_Time__c = 4000;
        sla2.First_Response_Time__c = 5000;
        sla2.Case_Update_Milestone_Time__c = 6000;
        sla2.Support_Level__c = 'Elite';
        insert sla2;
        
        Global_SLA__c sla3 = new Global_SLA__c();
        sla3.Priority__c = 'P2';
        sla3.Recordtype_Id__c = Label.SupportCaseRecordTypeId;
        sla3.Resolution_Time__c = 4000;
        sla3.First_Response_Time__c = 5000;
        sla3.Case_Update_Milestone_Time__c = 6000;
        sla3.Support_Level__c = 'Elite';
        insert sla3;
        
        Global_SLA__c sla = new Global_SLA__c();
        sla.Priority__c = 'P3';
        sla.Recordtype_Id__c = Label.SupportCaseRecordTypeId;
        sla.Resolution_Time__c = 4000;
        sla.First_Response_Time__c = 5000;
        sla.Case_Update_Milestone_Time__c = 6000;
        sla.Support_Level__c = 'Elite';
        insert sla;
                  
       }
        @isTest static void testMethod1(){
            test.startTest();
            Case cs = [Select id,subject from case where subject = 'test'];
            cs.subject = 'testing';
            cs.status = 'Reopened';
            cs.OwnerId = UserInfo.getUserId();
            cs.RecordtypeId = Label.SupportCaseRecordTypeId;
            cs.Category__c = 'ToutApp';
            cs.Problem_Type__c = 'How-to';
            cs.Sub_Category__c = 'Munchkin';
            update cs;
            
            Case_Update_Milestones__c cm = [select id,Milestone_Type__c from Case_Update_Milestones__c where Milestone_Type__c = 'First Response' limit 1];
            cm.Milestone_Type__c = 'Case Update';
            cm.case__c = cs.Id;
            update cm;
            //CaseTriggerFunctionUpdated.IncCodeCoverage();
            test.stopTest();
        }
        @isTest static void testMethod2(){
            test.startTest();
            createCusSetting();
            
            contact con = new contact(lastname = 'testingg');
            insert con;
            Case cse = new Case();
            cse.recordtypeId = Label.SupportCaseRecordTypeId;
            cse.ContactId = con.Id;
            cse.Category__c = 'ToutApp';
            cse.Problem_Type__c = 'How-to';
            cse.Sub_Category__c = 'Munchkin';
            cse.Last_Public_Comment_Date_Time__c = System.Now();
            cse.status = 'Closed';
            insert cse;
            CaseTriggerFunctionUpdated.createCaseComment(new List<Case>{cse});
            
            cse.Last_Public_Comment_Date_Time__c = System.Now().addminutes(5);
            cse.status = 'Reopened';
            update cse;
            test.stopTest();
        
        }
        @isTest static void testMethod3(){
        test.startTest();
        createCusSetting();
        
        contact con2 = [select id from contact where lastname = 'TestCon2Optimised1' limit 1];
        Case cse = new Case();
        cse.recordtypeId = Label.SupportCaseRecordTypeId;
        cse.ContactId = con2.Id;
        cse.Priority = 'P3'; 
        cse.subject = 'test';
        cse.status = 'Closed';
        cse.Category__c = 'ToutApp';
        cse.Problem_Type__c = 'How-to';
        cse.Sub_Category__c = 'Munchkin';
        cse.entitlementId = null;
        insert cse;
        
        cse.priority = 'P2';
        update cse;
        
        Case_Update_Milestones__c cm3 = new Case_Update_Milestones__c();
        cm3.case__c = cse.Id;
        cm3.Start_Date__c = system.now();
        cm3.Duration__c = '3600';
        cm3.Milestone_Type__c = 'Resolution Response';
        
        insert cm3;
        cm3.Actual_Completion_Date__c = System.Now();
        update cm3;
        test.stopTest();
        }
        
        public static testmethod void testEmailMessageActions2() {
             
            createCusSetting();
            
            Contact con2 = new Contact();
            con2.LastName = 'TestCoffffn2Optimised1';
            con2.email ='Test2@test111.com';
            con2.LS_Account_Score__c = 88;
            insert con2; 
            test.startTest();
            Case caseObj = new Case(contactid = con2.Id,Subject = 'Test1', Description = 'Description Test1', Status = 'New', recordTypeId = Label.SupportCaseRecordTypeId,Category__c = 'ToutApp',Problem_Type__c = 'How-to',Sub_Category__c = 'Munchkin');
            insert caseObj; 
            test.stopTest();                 
            EmailMessage emailObj = new EmailMessage( ToAddress = 'supportescalations@marketo.com', ParentId = caseObj.Id, subject = 'Test (' + caseObj.Thread_ID__c + ')' , TextBody = 'test test test test test test test test  test');
            insert emailObj; 
            Id usrId = Label.JiveSyncUserId;
            User u = new User(id = usrId);
            System.runAs(u){
                Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
                Attachment attach=new Attachment(parentId = caseObj.Id,Name='Unit Test Attachment',body=bodyBlob,ContentType = 'application/msword',IsPrivate = false, Description = 'Test'); 
                insert attach;  
            }                          
                    
        }
         public static testmethod void testmethod4() {
            createCusSetting();
            Test.StartTest();
            Case cse = [select id,priority from case where subject = 'test' limit 1];
            cse.Priority = 'P3';            
            
            update cse;
            test.stopTest();
         }
         public static testmethod void coverageInc() {
             test.startTest();
             createCusSetting();
            SituationUtil.IncCodeCoverage();
            test.stopTest();   
         }
         
         public static testmethod void createProactiveCaseSplunkTest() {         
            
            createCusSetting();
            Test.StartTest();
            Account acc = UtilityToCreateTestData.insertAccount();
            Contact con = UtilityToCreateTestData.insertContact(acc.id);
            Asset a = new Asset();
            a.Name = 'TestAsset';
            a.installdate = System.today();
            a.UsageEndDate = System.today().addMonths(1);
            a.AccountId = acc.Id;
            a.ContactId = con.Id;
            a.Purpose__c = 'Production';
            a.Asset_Type__c = 'Subscription';
            a.Acct_Prefix__c = 'Test';
            insert a; 
            
            Entitlement ent2 = new Entitlement();
            ent2.Name = 'Test Entitlement54321';
            ent2.EndDate = System.Now().Date().addDays(90);
            ent2.StartDate = System.Now().Date().addDays(-90);
            ent2.AccountId = acc.Id;
            ent2.Type = 'Elite';
            ent2.AssignedSupportPOC__c = UserInfo.getUserId();
            ent2.assetId = a.Id;
            ent2.Dedicated_TAM__c = true;
            insert ent2;                  
            
            Case cse = new Case();
            cse.subject = 'Splunk Alert: Test Account trigger campaign processing alert - internal';
            cse.recordTypeId = Label.ProActiveCaseRecTypeId;
            cse.AccountId = acc.Id;
            cse.Category__c = 'ToutApp';
            cse.Problem_Type__c = 'How-to';
            cse.Sub_Category__c = 'Munchkin';
            cse.origin = 'Proactive';
            cse.EntitlementId = ent2.Id;
            cse.AssetID = a.Id;
            insert cse; 
            
            Test.StopTest();

            
         }
         public static testmethod void surveyTriggerTest(){
          test.starttest();
             createCusSetting();
           
            Account acc = UtilityToCreateTestData.insertAccount();
            Contact con = UtilityToCreateTestData.insertContact(acc.id);
            Case cs = [Select id,subject from case where subject = 'test'];
            List<CSatSurveyFeedback__c> cSatSurveyFeedbackList = new List<CSatSurveyFeedback__c>();
            cSatSurveyFeedbackList.add(new CSatSurveyFeedback__c(Question_1__c='2',Account__c=acc.Id,Contact__c=con.Id,case__c = cs.Id));
            cSatSurveyFeedbackList.add(new CSatSurveyFeedback__c(Question_1__c='1',Account__c=acc.Id,Contact__c=con.Id,case__c = cs.Id));
            insert cSatSurveyFeedbackList;
            test.stoptest();
            
        }
        public static testMethod void TestIncCodeCoverage() { 
          
          
            Test.startTest();
              createCusSetting();
            Account acc = UtilityToCreateTestData.insertAccount();
            Contact con = UtilityToCreateTestData.insertContact(acc.id);
            CustomMileStoneUtil.IncCodeCoverage();
            eliteCaselist_thisWeek ee = new eliteCaselist_thisWeek ();
            ee.geteliteOpenCaselist();
            ee.geteliteClosedCaselist();
            Entitlement ent2 = new Entitlement();
            ent2.Name = 'Test Entitlement54321';
            ent2.EndDate = System.Now().Date().addDays(90);
            ent2.StartDate = System.Now().Date().addDays(-90);
            ent2.AccountId = acc.Id;
            ent2.Type = 'Elite';
            ent2.AssignedSupportPOC__c = UserInfo.getUserId();
            insert ent2;
            
            Case cs = [Select id,subject from case where subject = 'test'];
            cs.EntitlementId = ent2.Id;
            
            proCaseScheduler p = new proCaseScheduler();
            p.execute(null);
            Test.stopTest();                        
        }
        
        public static testmethod void testMSFTSLA() {            
            
            Account acc = UtilityToCreateTestData.insertAccount();            
            Contact con = UtilityToCreateTestData.insertContact(acc.id);
            
            Asset a = new Asset();
            a.Name = 'TestAsset';
            a.installdate = System.today();
            a.UsageEndDate = System.today().addMonths(1);
            a.AccountId = acc.Id;
            a.ContactId = con.Id;
            a.Purpose__c = 'Production';
            a.Asset_Type__c = 'Subscription';
            a.Acct_Prefix__c = 'Test';
            insert a;            
           
            Entitlement ent2 = new Entitlement();
            ent2.Name = 'Test Entitlement54321';
            ent2.EndDate = System.Now().Date().addDays(90);
            ent2.StartDate = System.Now().Date().addDays(-90);
            ent2.AccountId = acc.Id;
            ent2.Type = 'Elite';
            ent2.AssignedSupportPOC__c = UserInfo.getUserId();
            ent2.Dedicated_TAM__c = true;
            insert ent2;
            
            Authorized_Contact__c ac = new Authorized_Contact__c(Contact__c = con.id, Entitlement__c = ent2.id);
            insert ac;
            
            List<Global_SLA__c> gSList = new List<Global_SLA__c>();
            Global_SLA__c gS1 = new Global_SLA__c(Priority__c = 'P1', Temporary_Resolution__c = 30, Dedicated_TAM__c = true);
            Global_SLA__c gS2 = new Global_SLA__c(Priority__c = 'P2', Temporary_Resolution__c = 60, Dedicated_TAM__c = true);
            Global_SLA__c gS3 = new Global_SLA__c(Priority__c = 'P3', Temporary_Resolution__c = 120, Dedicated_TAM__c = true);
            gSList.add(gS1);
            gSList.add(gS2);
            gSList.add(gS3);
            Insert gSList ;
            
            createCusSetting();
            List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
            System.assert(bhs.size()==1);
            Test.StartTest();
            Case cse = new Case();
            cse.subject = 'Test Subject';
            cse.status = 'New';
            cse.ContactId = con.id;
            cse.AccountId = acc.id;
            cse.recordTypeId = Label.SupportCaseRecordTypeId;
            cse.AccountId = acc.Id;
            cse.Category__c = 'ToutApp';
            cse.Problem_Type__c = 'How-to';
            cse.Sub_Category__c = 'Munchkin';
            cse.origin = 'Web';
            cse.EntitlementId = ent2.Id;
            cse.AssetID = a.Id;
            cse.BusinessHoursId = bhs[0].id;
            insert cse; 
            
            Case_Update_Milestones__c cm2 = new Case_Update_Milestones__c();
            cm2.case__c = cse.Id;
            cm2.Start_Date__c = system.now();
            cm2.Duration__c = '3600';
            cm2.Milestone_Type__c = 'Temporary Resolution';
            cm2.Completion_Date__c = system.now();
            cm2.Target_Date__c = system.now();
            cm2.Actual_Completion_Date__c = null;
            insert cm2;

            
            
            cm2.Actual_Completion_Date__c = system.Now();
            update cm2;
            cse.After_Hours__c = true;
            cse.status = 'Needs Reply';
            cse.OwnerId = UserInfo.getUserId();
            update cse;
             
            cse.status = 'Temporary solution provided';
            update cse;
            Test.StopTest();
         }
         
         public static testmethod void testcopyEmailToComments() {
            test.starttest();
            Contact con2 = new Contact();
            con2.LastName = 'TestCon2Optigggmised1';
            con2.email ='Test2@testggg.com';
            con2.LS_Account_Score__c = 88;
            insert con2; 
            
            Case caseObj = new Case(contactid = con2.Id,Subject = 'Test1', Description = 'Description Test1', Status = 'New', recordTypeId = Label.SupportCaseRecordTypeId,Category__c = 'ToutApp',Problem_Type__c = 'How-to',Sub_Category__c = 'Munchkin');
            insert caseObj; 
            test.stoptest();      
            EmailMessage emailObj = new EmailMessage( ToAddress = 'supportescalations@marketo.com', ParentId = caseObj.Id, subject = 'Test (' + caseObj.Thread_ID__c + ')' , TextBody = 'test test test test test test test test  test');
            insert emailObj;
                 
            Id usrId = Label.JiveSyncUserId;
            User u = new User(id = usrId);
            System.runAs(u){
                Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
                Attachment attach=new Attachment(parentId = emailObj.Id,Name='Unit Test Attachment',body=bodyBlob,ContentType = 'application/msword',IsPrivate = false, Description = 'Test'); 
                insert attach;  
            }  
            CaseTriggerFunctionUpdated.copyEmailAttachmentToCase(emailObj.Id, caseObj.id);   
                               
                          
        }
        public static testmethod void Tier3ModuleTest() {
              Test.StartTest();  
                case c = new case();
                c.subject = 'Splunk Alert: unitedparcel munchkin alert';
                c.recordtypeId = Label.SupportCaseRecordTypeId;
                insert c;              
                
                
                Case cas= new Case();
                cas.subject = 'Splunk Alert: unitedparcel munchkin alert';
                cas.status = 'New';
                cas.recordTypeId = Label.SupportFeedBackRecTypeId;
                cas.origin = 'Web';
                cas.parentId = c.Id;
                
                insert cas;
             
                Case cse = new Case();
                cse.subject = 'Splunk Alert: unitedparcel munchkin alert';
                cse.status = 'New';
                cse.recordTypeId = Label.tier3RecordTypeId;
                cse.origin = 'Web';
                cse.parentId = c.Id;
                
                insert cse;  
            Test.StopTest();
          }
          
          public static testmethod void sendAuthorizedContactAddedEmailUpdTest() {         
            
            Test.StartTest();
            createCusSetting();
            Account acc = UtilityToCreateTestData.insertAccount();  
            acc.Bizible_Customer__c = True;
            update acc;       
            Contact con = UtilityToCreateTestData.insertContact(acc.id);
            Entitlement ent2 = new Entitlement();
            ent2.Name = 'Test Entitlement54321';
            ent2.AccountId = acc.Id;
            ent2.Type = 'Bizible Business';
            ent2.AssignedSupportPOC__c = UserInfo.getUserId();
            insert ent2;
            
            List<Authorized_Contact__c> listauth = new List<Authorized_Contact__c>();
            for(Integer i = 0; i<10 ; i++){
                listauth.add(new Authorized_Contact__c(Contact__c = con.id,Entitlement__c = ent2.id));
            }
            insert listauth;
            Test.stopTest();
         }
         
         public static testmethod void sendAuthorizedContactAddedEmailTest() {         
            
            Test.StartTest();
            createCusSetting();
            Account acc = UtilityToCreateTestData.insertAccount();  
            acc.Bizible_Customer__c = True;
            update acc;           
            Contact con = UtilityToCreateTestData.insertContact(acc.id);
            Entitlement ent2 = new Entitlement();
            ent2.Name = 'Test Entitlement54321';
            ent2.AccountId = acc.Id;
            ent2.Type = 'Bizible Business';
            ent2.AssignedSupportPOC__c = UserInfo.getUserId();
            insert ent2;
            
            Authorized_Contact__c ac = new Authorized_Contact__c(Contact__c = con.id,Entitlement__c = ent2.id);
            insert ac;
            Test.stopTest();
         }
          
    public static testmethod void testMSFTSLA2() {            
        
        Account acc = UtilityToCreateTestData.insertAccount();            
        Contact con = UtilityToCreateTestData.insertContact(acc.id);
        
        Asset a = new Asset();
        a.Name = 'TestAsset';
        a.installdate = System.today();
        a.UsageEndDate = System.today().addMonths(1);
        a.AccountId = acc.Id;
        a.ContactId = con.Id;
        a.Purpose__c = 'Production';
        a.Asset_Type__c = 'Subscription';
        a.Acct_Prefix__c = 'Test';
        insert a;            
       
        Entitlement ent2 = new Entitlement();
        ent2.Name = 'Test Entitlement54321';
        ent2.EndDate = System.Now().Date().addDays(90);
        ent2.StartDate = System.Now().Date().addDays(-90);
        ent2.AccountId = acc.Id;
        ent2.Type = 'Elite';
        ent2.AssignedSupportPOC__c = UserInfo.getUserId();
        ent2.assetId = a.Id;
        ent2.Dedicated_TAM__c = true;
        insert ent2;
        
        Authorized_Contact__c ac = new Authorized_Contact__c(Contact__c = con.id, Entitlement__c = ent2.id);
        insert ac;
        
        List<Global_SLA__c> gSList = new List<Global_SLA__c>();
        Global_SLA__c gS1 = new Global_SLA__c(Priority__c = 'P1', Temporary_Resolution__c = 30, Dedicated_TAM__c = true);
        Global_SLA__c gS2 = new Global_SLA__c(Priority__c = 'P2', Temporary_Resolution__c = 60, Dedicated_TAM__c = true);
        Global_SLA__c gS3 = new Global_SLA__c(Priority__c = 'P3', Temporary_Resolution__c = 120, Dedicated_TAM__c = true);
        gSList.add(gS1);
        gSList.add(gS2);
        gSList.add(gS3);
        Insert gSList ;
        
        createCusSetting();
        List<BusinessHours> bhs=[select id from BusinessHours where IsDefault=true];
        System.assert(bhs.size()==1);
        
        Test.StartTest();
        Case cse = new Case();
        cse.subject = 'Test Subject';
        cse.status = 'New';
        cse.ContactId = con.id;
        cse.AccountId = acc.id;
        cse.recordTypeId = Label.SupportCaseRecordTypeId;
        cse.AccountId = acc.Id;
        cse.Category__c = 'ToutApp';
        cse.Problem_Type__c = 'How-to';
        cse.Sub_Category__c = 'Munchkin';
        cse.origin = 'Web';
        cse.EntitlementId = ent2.Id;
        cse.AssetID = a.Id;
        cse.BusinessHoursId = bhs[0].id;
        insert cse; 
        
        Case_Update_Milestones__c cm2 = new Case_Update_Milestones__c();
        cm2.case__c = cse.Id;
        cm2.Start_Date__c = system.now();
        cm2.Duration__c = '3600';
        cm2.Milestone_Type__c = 'Temporary Resolution';
        cm2.Actual_Completion_Date__c = null;
        insert cm2;
        Map<Id,Id> milestoneParentMap = new Map<Id,Id>();
        milestoneParentMap.put(cse.Id,cm2.id);
        list<SObject> TriggerNew = new list<SObject>();
        SObject cmmmm = (SObject) cm2;
        TriggerNew.add(cmmmm);
        cm2.Actual_Completion_Date__c = system.now();
        update cm2;
        SObject cmmmmm = (SObject) cm2;
        Map<Id,SObject > OldMap = new Map<Id,SObject>();
        OldMap.put(cm2.id, cmmmm);
        CustomMilestoneFunction.getBusinessHoursDiff(milestoneParentMap,TriggerNew,OldMap);
        Test.StopTest();
     }   
    @isTest static void testMethod10(){
        test.startTest();
        Account acct = new Account();
        acct.Name = 'TestAccounterOptimised12345';
        acct.Sales_Region__c      = 'North America';
        acct.CAM_Owner__c = UserInfo.getUserId();
        acct.CAM_Group__c = 'AMER-SB+L60K';
        insert acct;
        
        Case cs = [Select id,subject from case where subject = 'test'];
        cs.subject = 'testing';
        cs.status = 'Reopened';
        cs.OwnerId = UserInfo.getUserId();
        cs.RecordtypeId = Label.CERRecordTypeIdFull;
        cs.Category__c = 'ToutApp';
        cs.Problem_Type__c = 'How-to';
        cs.Sub_Category__c = 'Munchkin';
        cs.accountid = acct.id;
        update cs;
        test.stopTest();
    }  
}