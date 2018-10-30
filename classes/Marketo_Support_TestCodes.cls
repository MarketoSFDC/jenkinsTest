/************************************************************************
Updated by: Jade Global Inc.
Updated On: 4th June 2017
Updated for: 
# Reference: Removed reference of Profile.Id = '00e50000000z3VuAAI' and  Profile.Id = '00e50000000z3Vv'
# Jira Ticket: APPS-13173: Tasks in the Requirement document for Sprint 4
*************************************************************************/

@isTest(SeeAllData=True)
public class Marketo_Support_TestCodes{
    public static user testuser = [select id,name from user where isActive = true and (profile.id='00e50000000zJpI')  limit 1];
    static void TestCodeForOLDTrigger() {
        Support_Trigger_Settings__c TestCodeForOLDTrigger = Support_Trigger_Settings__c.getInstance('Case Optimized Trigger Enabled');
        if(TestCodeForOLDTrigger.Enable_Optimized_Trigger__c != False){
            upsert new Support_Trigger_Settings__c(
            id = TestCodeForOLDTrigger.Id,
            Name = 'Case Optimized Trigger Enabled',
            Enable_Optimized_Trigger__c = False
            );   // DISABLE THE OLD CASE TRIGGER FOR CODE COVERAGE ISSUE
        }
        TestCodeForOLDTrigger.Enable_Optimized_Trigger__c = False;    
          
    }
          
    static void testCaseRelatedArticleList() {
        TestCodeForOLDTrigger();          
        Case cs1 = createCase();        
        insert cs1;    
        
        CaseComment cCmnt = new CaseComment(ParentId = cs1.Id, isPublished = True,commentBody = 'testing comment');
        CustomMilestone.firstRunInCaseComment = true;
        insert cCmnt; 
          
        // set up some test data to work with        
        Case_Related_Article_List__c csRltdLst =  new Case_Related_Article_List__c ();
        csRltdLst.Case__c = cs1.Id;
        csRltdLst.Article_Link1__c = 'http://www.google.com';csRltdLst.Article_Title1__c = 'google1';        
        csRltdLst.Article_Link2__c = 'http://www.google.com';csRltdLst.Article_Title2__c = 'google2';
        csRltdLst.Article_Link3__c = 'http://www.google.com';csRltdLst.Article_Title3__c = 'google3';                
        csRltdLst.Article_Link4__c = 'http://www.google.com';csRltdLst.Article_Title4__c = 'google4';                
        csRltdLst.Article_Link5__c = 'http://www.google.com';csRltdLst.Article_Title5__c = 'google5';                
        csRltdLst.Article_Link6__c = 'http://www.google.com';csRltdLst.Article_Title6__c = 'google6';        
        csRltdLst.Article_Link7__c = 'http://www.google.com';csRltdLst.Article_Title7__c = 'google7';        
        csRltdLst.Article_Link8__c = 'http://www.google.com';csRltdLst.Article_Title8__c = 'google8';
        insert csRltdLst;                                 
        Test.setCurrentPage(Page.CaseRelatedArticleList);
        CaseRelatedArticleList  controller = new CaseRelatedArticleList(new ApexPages.StandardController(cs1));
    }
    
    
    public static testMethod void EmailNotificationToTSE(){
        TestCodeForOLDTrigger();
        List<Case> caseList = new List<Case>([Select id, P1_Service_Notification_Sent_Initiated__c, CreatedDate, OwnerId, CaseNumber, (Select Id, CaseId, CreatedDate, Field, OldValue, NewValue From Histories Where Field = 'Priority' ORDER BY CreatedDate DESC LIMIT 1) from Case where (isClosed = false and Priority = 'P1' AND P1_Service_Restored_Time_Visible__c = Null) ]);
        Case cs1 = Marketo_Support_TestCodes.createCase();
        cs1.Email_List__c = 'test@mail.com,test2@mail.com';
        insert cs1;
        cs1.ownerid=testuser.id;
        cs1.Email_List__c='';//'test3@mail.com,test4@mail.com';
        update cs1;
        
        Out_Of_Office__c myTestOoo = new Out_Of_Office__c(Tse_name__c =testuser.Id ,Due_Date__c= system.today()+2,StartDate__c =system.today(),EndDate__c=system.today(),Time__c='00:00',EndTime__c='23:00',Frequency__c='2 Hours',TimeZone__c ='(GMT+05:30) India Standard Time (Asia/Kolkata)',Time_Zone__c ='(GMT+05:30) India Standard Time (Asia/Kolkata)',StartDateString__c = '2014-07-08 01:00:00',EndDAteString__c='2020-07-08 01:00:00',FirstRunComplete__c= false);
        insert myTestOoo ;
        //PageReference pageRef3 = new pagereference('/apex/OnDemandPage?MyVariable='+testuser.id);
        OndemandController temp = new OndemandController();
        temp.GetCases();        
                
        PageReference pageRef3 = Page.OnDemandPage;
        ApexPages.currentPage().getParameters().put('MyVariable', testuser.id);
             
        temp = new OndemandController();    
        Test.setCurrentPage(pageRef3);               
        temp.GetCases();
        temp.AssignToQueue();
        temp.AssignToMe();
        temp.Assign();
        temp.AssignToTSE();
        temp.disablebutton = true;
        temp.TSEName = testuser.id;
        temp.username = testuser.name ;
        
        Case cs2 = Marketo_Support_TestCodes.createCase();
        cs2.P1_Service_Notification_Sent_Initiated__c = system.now();
        insert cs2;
        caseList.add(cs1);
        caseList.add(cs2);        
        EmailNotificationToTSE.FetchValidCasedForNotification(); 
            
    }
    
    static testMethod void Calculate_Duration_In_Hours(){
        TestCodeForOLDTrigger();
        Calculate_Duration_In_Hours.duration_between_two_date_times(system.now(), system.now().addDays(3));
    }
    
    static testMethod void SendEmailForP1ServiceBreach(){
         TestCodeForOLDTrigger();
         Test.StartTest();
         SendEmailForP1ServiceBreach sh1 = new SendEmailForP1ServiceBreach();
         Datetime sysTime = System.now().addSeconds( 3600 );      
         String chronExpression = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();
         System.schedule( 'P1BreachTrackerTest' + sysTime, chronExpression, sh1);
         Test.stopTest();
    }
    
    static testMethod void updateSalesCases (){
        TestCodeForOLDTrigger();
        Test.StartTest();
        //*Sales_Ops_Control__c salesCustomSetting = new Sales_Ops_Control__c(Name = 'Enable Sales Ops', IsEnabled__c = true);
        //insert salesCustomSetting;
        Case salesCase =  createSalesCase();
        insert salesCase;
        CaseTriggerUtility.firstRunInUpdateSalesCase = true;
        Case salesCase1 =  createSalesCase();
        salesCase1.Origin ='Email';
        salesCase1.SuppliedEmail= Userinfo.getUserEmail();
        salesCase1.Requester_Name__c = testuser.Id;
        insert salesCase1;
        CaseTriggerUtility.firstRunInUpdateSalesCase = true;
        salesCase.Requester_Name__c = Userinfo.getUserId();
        update salesCase;
        Test.stopTest();        
    }
    

    static testMethod void caseUpdateMilestoneOnCasesTest(){
        TestCodeForOLDTrigger();
        case caseLinkedToCaseMilestone = createCase();
        insert caseLinkedToCaseMilestone;
        
        CSatSurvey.executionFlag = false;
        caseLinkedToCaseMilestone.status = 'Closed'; 
        caseLinkedToCaseMilestone.Close_Reason__c = 'Resolved';
        update caseLinkedToCaseMilestone;
    }
    
    static testMethod void updateCasePriority(){
        TestCodeForOLDTrigger();
        Case caseToBeUpdated   = createCase();
        insert caseToBeUpdated;
        caseToBeUpdated.Priority = 'P1';
        caseToBeUpdated.To_Be_New_Case_Created__c = true;

        update caseToBeUpdated;        
    }

    
    static testMethod void Test_Case_Report_Scheduler(){
        
        Test.startTest();
        TestCodeForOLDTrigger();
        CustomCaseReportSchedulable scheduled = new CustomCaseReportSchedulable ();
        scheduled.execute(null);                
        Test.stopTest(); 
    } 
    
      
    static testMethod void Test_Case_Age_Notifier(){
        Test.startTest();
        TestCodeForOLDTrigger();
        CaseAgedNotifyEmailScheduler schedulable = new CaseAgedNotifyEmailScheduler();
        schedulable.execute(null);
        Test.stopTest(); 
    }
    
    static testMethod void Test_NoArticleFoundNotification() {
        TestCodeForOLDTrigger();
        NoArticleFoundNotification testCtrl = new NoArticleFoundNotification();
        testCtrl.parentCaseId = [SELECT ID from Case Where recordtypeId = '01250000000UJwx' AND Entitlement.Id != NULL order by createdDate desc Limit 1][0].Id; 
        testCtrl.CmtparentCaseId = testCtrl.parentCaseId;
        testCtrl.getMileStoneForEmailNotification();
        testCtrl.getLastComments();
        testCtrl.getLastInternalComments();
        testCtrl.msgLocation = 'Top';
        testCtrl.TempName = 'Notification - Case Received (RTP) SLA';
        testCtrl.getDynamicEmailMessage();                
    }
    static testmethod void Test_customerPortalReports(){
        TestCodeForOLDTrigger();    
        customerPortalReports tmp = new customerPortalReports();
        //tmp.initData();
    }

    public static testMethod void testSwapProfile() {
        TestCodeForOLDTrigger();
        PageReference pageRef = Page.SwapJiveProfileInfo;
        Test.setCurrentPage(pageRef);                
        SwapJiveProfileInfoController controller = new SwapJiveProfileInfoController();
        controller.init();
        controller.getUserDetails();
        controller.getFields();
        controller.getInActiveUsers();
        controller.refreshPanel();
        controller.swap();
        controller.getProfileSwappingCallout();
        controller.automateProfileSwappingCallout();      
    }
       
    public static testMethod void testMyController() {
        TestCodeForOLDTrigger();
        Out_Of_Office__c myTestOoo = new Out_Of_Office__c(Tse_name__c =testuser.id ,Due_Date__c= system.today()+2,StartDate__c =system.today(),EndDate__c=system.today(),Time__c='00:00',EndTime__c='23:00',Frequency__c='2 Hours',Time_Zone__c ='(GMT+05:30) India Standard Time (Asia/Kolkata)',StartDateString__c = '2014-07-08 01:00:00',EndDAteString__c='2020-07-08 01:00:00',FirstRunComplete__c= false);
        insert myTestOoo ;
        PageReference testPage = new pagereference('/apex/OutOfOfficeEdit');
        Test.setCurrentPage(testPage);
        ApexPAges.StandardController sc = new ApexPages.StandardController(myTestOoo);
        OooList temp = new OooList(sc);
        temp.GetsaveList();
         temp.search();
         temp.Newpage();
         temp.OnDemandPage();
         //id OooId = myTestOoo.id;
         temp.deleteOoo();
    }
    
    public static testMethod void testMyController1() { 
        TestCodeForOLDTrigger();       
        Out_Of_Office__c myTestOoo = new Out_Of_Office__c(Tse_name__c =testuser.Id ,Due_Date__c= system.today()+2,StartDate__c =system.today(),EndDate__c=system.today(),Time__c='00:00',EndTime__c='23:00',Frequency__c='2 Hours',TimeZone__c ='(GMT+05:30) India Standard Time (Asia/Kolkata)',Time_Zone__c ='(GMT+05:30) India Standard Time (Asia/Kolkata)',StartDateString__c = '2014-07-08 01:00:00',EndDAteString__c='2020-07-08 01:00:00',FirstRunComplete__c= false);
        insert myTestOoo ;
        PageReference pageRef1 = Page.OooEdit;
        Test.setCurrentPage(pageRef1);
        ApexPAges.StandardController sc = new ApexPages.StandardController(myTestOoo);
        OooExtnsn temp = new OooExtnsn(sc);
        temp.BacktoOoo();
        temp.UpdateOoo();                
    }
    
    public static testMethod void testMyController2() {
        TestCodeForOLDTrigger();        
        Out_Of_Office__c myTestOoo = new Out_Of_Office__c(Tse_name__c =testuser.Id ,Due_Date__c= system.today()+2,StartDate__c =system.today(),EndDate__c=system.today(),Time__c='00:00',EndTime__c='23:00',Frequency__c='2 Hours',TimeZone__c ='(GMT+05:30) India Standard Time (Asia/Kolkata)',Time_Zone__c ='(GMT+05:30) India Standard Time (Asia/Kolkata)',StartDateString__c = '2014-07-08 01:00:00',EndDAteString__c='2020-07-08 01:00:00',FirstRunComplete__c= false);
        insert myTestOoo ;
        //id usrid = [select id from user limit 1].id;
        PageReference pageRef2 = new pagereference('/apex/OutOfOffice?MyVariable='+testuser.id );
        Test.setCurrentPage(pageRef2);
        ApexPAges.StandardController sc = new ApexPages.StandardController(myTestOoo);
        OutOfOfficeExtnsion temp = new OutOfOfficeExtnsion(sc);   
        temp.BacktoOoo();
        temp.save();     
    }
    

    
    public static testMethod void testMyScehduler123() { 
        TestCodeForOLDTrigger();
        //RecordType supportCase = [Select Id From RecordType where SobjectType='Case' and Name = 'Support Cases' Limit 1];
        //List<Case> myCases = [SELECT ID, OwnerID from Case where isClosed = FALSE and RecordTypeId = :supportCase.Id LIMIT 1];
        //user testuser1 = [select id from user where isActive = true  limit 1];        
        //Case cs1 = Marketo_Support_TestCodes.createCase();insert cs1;cs1.OwnerId = testuser.Id;update cs1;
        
        Out_Of_Office__c myTestOoo = new Out_Of_Office__c(Tse_name__c =testuser.Id ,Due_Date__c= system.today()+2,StartDate__c =system.today(),EndDate__c=system.today(),Time__c='00:00',EndTime__c='23:00',Frequency__c='2 Hours',TimeZone__c ='(GMT+05:30) India Standard Time (Asia/Kolkata)',Time_Zone__c ='(GMT+05:30) India Standard Time (Asia/Kolkata)',StartDateString__c = '2014-07-08 01:00:00',EndDAteString__c='2020-07-08 01:00:00',FirstRunComplete__c= false);
        insert myTestOoo ; 
        Test.startTest();
        UpdateCaseOwnerOfOooSchdlr temp = new UpdateCaseOwnerOfOooSchdlr();            
        temp.execute(null);
        
        myTestOoo.FirstRunComplete__c= true;
        update myTestOoo;
        temp.execute(null);
        
        myTestOoo.Due_Date__c= system.now()-2;
        myTestOoo.Frequency__c='30 Min';
        update myTestOoo;
        temp.execute(null);
        Test.stopTest();
    }

    public static testMethod void testPublicCaseCreatePage() {
        TestCodeForOLDTrigger();
        List<Authorized_Contact__c> authorizedContact    = new List<Authorized_Contact__c>([Select Entitlement__c, Entitlement__r.AssetId, Contact__c, Entitlement__r.Asset.Munchkin_Id__c From Authorized_Contact__c where Entitlement__r.Status = 'Active' Limit 1]);
        PageReference pageRef = Page.PublicContactLookupPopup;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('phNo', '111');       
        PublicContactLookupPopupController tmpCont = new PublicContactLookupPopupController();
        tmpCont.runQuery();
        tmpCont.Beginning();tmpCont.Previous();
        tmpCont.Next();tmpCont.End();tmpCont.getDisablePrevious();tmpCont.getDisableNext();
        tmpCont.getTotal_size();tmpCont.getPageNumber();tmpCont.getTotalPages();        
        
        PublicCaseCreatePageCtrl tmpCtrl = new PublicCaseCreatePageCtrl();
        tmpCtrl.accessPwd = 'testing123';        
        tmpCtrl.checkPwd();
        tmpCtrl.submitCase();
        tmpCtrl.selContactId = authorizedContact[0].Contact__c;        
        tmpCtrl.submitCase();        
        return;        
    } 
    
    static testMethod void EntAssetAttched() { 
        TestCodeForOLDTrigger();       
        Case TestCase = new Case(Status = 'New', Priority = 'P3', Subject = 'Test',Description = 'Test Description', Origin = 'Email', Case_Issue__c = 'Design Studio' ,Case_Sub_Issue__c='Social Campaign', recordTypeId = '01250000000UJwx');
        insert  TestCase; 
    }
    
    static testMethod void testMicrosoftEnt(){
        TestCodeForOLDTrigger();
        List<Authorized_Contact__c> authorizedContact    = new List<Authorized_Contact__c>([Select Entitlement__c, Entitlement__r.AssetId, Contact__c, Contact__r.AccountId, Entitlement__r.Asset.Munchkin_Id__c From Authorized_Contact__c where Entitlement__r.Status = 'Active' Limit 1]);
        Entitlement en = new Entitlement(id = authorizedContact[0].Entitlement__c, Type = 'Microsoft');    
        update en;
        
        Case tempCase = new case(OwnerId = testUser.Id,Origin='Web',ContactId = authorizedContact[0].Contact__c, AccountId = authorizedContact[0].Contact__r.AccountId, subject='Test Case',description='asd',Problem_Type__c='Community',Category__c='General Questions',Priority='P3',Status = 'Awaiting Customer Input',EntitlementId = en.Id);        
        System.Debug('Case at time of creation'+tempCase);
        insert tempCase;     
    
    }

    static testMethod void testCustomMilestone() {
        TestCodeForOLDTrigger();
        List<Authorized_Contact__c> authorizedContact    = new List<Authorized_Contact__c>([Select Entitlement__c, Entitlement__r.AssetId, Contact__c, Contact__r.AccountId, Entitlement__r.Asset.Munchkin_Id__c From Authorized_Contact__c where Entitlement__r.Status = 'Active' Limit 1]);
        Entitlement en = new Entitlement(id = authorizedContact[0].Entitlement__c, Type = 'Microsoft');    
        update en;
        
        Case tempCase = new case(OwnerId = testUser.Id,Origin='Web', ContactId = authorizedContact[0].Contact__c, AccountId = authorizedContact[0].Contact__r.AccountId, subject='Test Case',description='asd',Problem_Type__c='Community',Category__c='General Questions',Priority='P1',Status = 'New',EntitlementId = en.Id, BusinessHoursId = '01m50000000H7RE');        
        System.Debug('Case at time of creation'+tempCase);
        insert tempCase;     
        
        Case caseLinkedToCaseMilestone = [SELECT ID,Status, Support_Level__c, Priority,BusinessHoursId,OwnerId,First_Response_Post_Time__c,Origin,CreatedDate from case where id =:tempCase.Id limit 1];
        CustomMilestone c1 = new CustomMilestone();
        
        Case_Update_Milestones__c tmpCUPOpr = CustomMilestone.insertCaseUpdateMilestone(caseLinkedToCaseMilestone);
        Case_Update_Milestones__c tmpCUPOpr3 = CustomMilestone.updOpenFirstRespCaseMile(caseLinkedToCaseMilestone, tmpCUPOpr);
       
        caseLinkedToCaseMilestone.status = 'Closed'; 
        caseLinkedToCaseMilestone.Close_Reason__c = 'Resolved';
        update caseLinkedToCaseMilestone;
      
        Case_Update_Milestones__c tmpCUPOpr2 =  CustomMilestone.insertCaseUpdateMilestone(caseLinkedToCaseMilestone);
        CustomMilestone.updResolutionCaseMile(caseLinkedToCaseMilestone, tmpCUPOpr2);
        
        CustomMileStone.updOpenCaseUpdateMile(tmpCUPOpr2,true);
        
        tempCase.status = 'Reopened'; tempCase.Close_Reason__c = '';
        update tempCase;
        
        CustomMilestone.updOpenCaseUpdateMile(tmpCUPOpr2,'test');
        
        CustomMilestone.updOpenCaseUpdateMilelist(new List<Case_Update_Milestones__c>{tmpCUPOpr2},true);
        
        UpdateOperations tmpUpd = new UpdateOperations(caseLinkedToCaseMilestone, tempCase);
        
        
                
        CustomMilestone cMst = new CustomMilestone();
        CustomMilestone.firstResponseMilestone(tempCase, 60);
        CustomMilestone.ResolutionMilestone(tempCase, 1440);
        //CustomMilestone.reopenResolMil(caseLinkedToCaseMilestone );
        CustomMilestone.firstRespMilesFrmEntChng(caseLinkedToCaseMilestone, 60);  
        CustomMilestone.getSetOfCaseAdmins();       
        CustomMilestone.getMapOfCaseIdToCaseUpdteMile(new List<Id>{caseLinkedToCaseMilestone .Id});
        CustomMilestone.getMapOfCaseIdToFirstRespMile(new List<Id>{caseLinkedToCaseMilestone .Id});
        CustomMilestone.getMapOfCaseIdToCase(new List<Id>{caseLinkedToCaseMilestone .Id});
        CustomMilestone.isAdminUser(testUser.id);        
        
        
        
        
        
        
        //CustomMilestone.getTargetDate(tempCase, 60);
        
        
        
        //CustomMilestone.insertCaseUpdateMilestone(caseLinkedToCaseMilestone,tmpUpd);

    }
    
    Public static testMethod void TestEscalationManagerEmailService() { 
        TestCodeForOLDTrigger();       
        // create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        // setup the data for the email
        email.subject = 'Test Email Service';
        email.fromname = 'Test';
        env.fromAddress = 'test@test.com';
        
        // call the email service class and test it with the data in the testMethod
        EscalationManagerCaseHandler emailProcess = new EscalationManagerCaseHandler();
        emailProcess.handleInboundEmail(email, env);

        contact Con = [select id,email from contact where email like '%@marketo.com' limit 1];
        env.fromAddress = Con.email;
        // call the email service class and test it with the data in the testMethod
        emailProcess.handleInboundEmail(email, env);
    }
    

    public static Case createCase(){
        TestCodeForOLDTrigger();
        RecordType supportCase = [Select Id From RecordType where SobjectType='Case' and Name = 'Support Cases']; 
        List<Authorized_Contact__c> authorizedContact    = new List<Authorized_Contact__c>([Select Entitlement__c, Entitlement__r.AssetId, Contact__c,Contact__r.accountid, Entitlement__r.Asset.Munchkin_Id__c From Authorized_Contact__c where Entitlement__r.Status = 'Active' Limit 1]);
        asset tempasset = new asset(name='test', asset_type__c ='Subscription',accountid=  authorizedContact[0].Contact__r.accountid);
        insert tempasset;
        asset tempaddon = new asset(name='test',asset_type__c ='Add On',status = 'Expired',accountid=  authorizedContact[0].Contact__r.accountid,Parent_Instance__c = tempasset.id);
        insert tempaddon ;
        Case caseObj = new Case(Problem_Type__c = 'How-To',Assetid=tempasset.id, Case_Issue__c = 'Analytics' ,Case_Sub_Issue__c='MFM', Category__c = 'Design Studio',Sub_Category__c = 'Other' ,Status = 'Working', Priority = 'P4', Subject = 'Test', SuppliedEmail = 'test@test.com',Description = 'Test Description', Origin = 'Web', ContactId = authorizedContact[0].Contact__c, recordTypeId = supportCase.Id);
        return caseObj;        
    }
    
    static Case createSalesCase(){
        TestCodeForOLDTrigger();
        RecordType salesCase = [Select Id From RecordType where SobjectType='Case' and Name = 'Sales Cases']; 
        Case caseObj = new Case(Status = 'New', Priority = 'P3', Subject = 'Test',Description = 'Test Description', Origin = 'Web', recordTypeId = salesCase.Id);
        return caseObj;        
    }
    
    Public static testMethod void TestCustomMilOnCC() { 
        case testcase = [select id from case where recordtype.id = '01250000000UJwx' and status!='Closed' and SurveyLinkEmailerSent__c = false and Csat_Survey_Sent_For_Parent_Case__c = false and Problem_Type__c != 'Configuration/Set Up' and Category__c != 'Configuration Outreach' limit 1];
        testcase.status = 'Closed';
        testcase.Close_Reason__c = 'Resolved';
        testcase.SurveyLinkEmailerSent__c = false;
        testcase.Csat_Survey_Sent_For_Parent_Case__c = false;
        update testcase;
        
        
    }
        Public static testMethod void TestCaseTriggerUtility() {
            CaseTriggerUtility cs=new CaseTriggerUtility();
            list<case> cases=[select id,EntitlementId,Technical_Account_Manager__c from case where id='5003800000lRvGX' ];
            
            list<entitlement> enti=[select id from entitlement limit 2];
            list <id> eid=new list<id>();
                eid.add('55050000000HUqA');
           //for(entitlement e:enti)
           // {
           //    eid.add(e.id);
           // } 
            CaseTriggerUtility.emailToNamSupEngOrTechAcctMan(cases,eid);
            CaseTriggerUtility.isValidRecordTypeId(eid[0]);
            CaseTriggerUtility.returnCaseRecordTypeId('CS Ops Cases');
        }
        
         static testMethod void testArticleController() {
        Entitlement  demoEntitlement               = [Select id from Entitlement where Name = 'Marketo Demo 17 Internal'];
        List<Contact> tempContact                  = [Select Id, AccountId From Contact where Customer_Portal_User__c = true and Is_Authorized_Contact__c = 'Yes' Limit 1];
        //List<KnowledgeArticleVersion> tmpLst = [SELECT Id,ArticleType from KnowledgeArticleVersion where ArticleType = 'Resources__kav' AND  IsVisibleInCsp = true AND PublishStatus='Online' AND Language ='en_US' limit 10 ];
        //system.debug(tmpLst[0].Id+';'+tmpLst[1].Id+';'+tmpLst[2].Id);        

        System.Debug('tempContact++++'+tempContact[0].Id);
        //List<User> testUser = [Select Id from User Where IsActive = true Limit 1];
        Case tempCase = new case(OwnerId = testUser.Id,Origin='Web',ContactId = tempContact[0].Id, AccountId = tempContact[0].AccountId, subject='Test Case',description='asd',Problem_Type__c='Community',Category__c='General Questions',Priority='P3',Status = 'Awaiting Customer Input',EntitlementId = demoEntitlement.Id);        
        System.Debug('Case at time of creation'+tempCase);
        insert tempCase;
        System.Debug('Case at time of creation'+tempCase);
        pageReference pg = Page.CaseArticleSearch;
        ApexPages.StandardController tempVar = new ApexPages.StandardController(tempCase);
        ApexPages.currentPage().getParameters().put('id', tempCase.Id);
        ApexPages.currentPage().getParameters().put('articleId', '12345');
        //ApexPages.currentPage().getParameters().put('articleId', tmpLst[0].Id);
        ApexPages.currentPage().getParameters().put('searchText', 'nation.marketo.com/DOC-1245');
        ArticleSearchController testArticleSearchController = new ArticleSearchController(tempVar);
        ApexPages.currentPage().getParameters().put('searchText', 'docs.marketo.com?pageId=');
        ArticleSearchController testArticleSearchController2 = new ArticleSearchController(tempVar);
        test.setCurrentPage(pg);
        testArticleSearchController.currResourcePageNum = 1;
        testArticleSearchController.resourceArticleNext();
        testArticleSearchController.resourceArticlePrev();
        testArticleSearchController.getLastPageNumber();
        testArticleSearchController.getLanguageList();
        testArticleSearchController.languageStaticMap();
        testArticleSearchController.refreshWrapper();
        testArticleSearchController.attachArticles();
        testArticleSearchController.deAttachArticles();
    
       // testArticleSearchController.searchText = 'nation.marketo.com/DOCS-5555';
        testArticleSearchController.channelType = 'Internal';
        testArticleSearchController.searchKnowledgeRecords();
        testArticleSearchController.refreshWrapper();        
        ApexPages.currentPage().getParameters().put('articleId', '12345');
        testArticleSearchController.attachArticles();
        testArticleSearchController.deAttachArticles();

        testArticleSearchController.channelType = 'Community';
        testArticleSearchController.searchKnowledgeRecords();
        testArticleSearchController.refreshWrapper();        
        ApexPages.currentPage().getParameters().put('articleId', '12345');
        testArticleSearchController.attachArticles();
        testArticleSearchController.deAttachArticles();

    
        //testArticleSearchController.caStRecord.SearchLink__c = 'test';
        //testArticleSearchController.caStRecord.SearchLinkLabel__c = 'test Link';
        //testArticleSearchController.attachStaticLinks();
        //testArticleSearchController.caStRecord.SearchLink__c = 'www.google.com';
        //testArticleSearchController.attachStaticLinks();        
        //System.debug('==>' + testArticleSearchController.caStRecord.Id);
                
        CaseComment cCmnt = new CaseComment(ParentId = tempCase.Id, isPublished = false,commentBody = 'testing comment');
        insert cCmnt;    
        NoArticleFoundNotification testController = new NoArticleFoundNotification ();
        testController.parentCaseId = tempCase.Id;
        testController.getLastComments();        
        
        PageReference pg3 = Page.addCaseCommentPopup;
         test.setCurrentPage(pg3);
        ApexPages.StandardController tempVar3 = new ApexPages.StandardController(tempCase);
        ApexPages.currentPage().getParameters().put('id', tempCase.Id);
        ApexPages.currentPage().getParameters().put('artIds', 'https://docs.marketo.com/display/DOCS/Understanding Email Testing Options?src=search_Understanding Email Testing Options;https://docs.marketo.com/display/DOCS/Understanding Email Testing Options?src=search_Understanding Email Testing Optionsss');        
        ApexPages.currentPage().getParameters().put('docType','Community');   
        CaseArticleSearchLinkCls testController3 = new CaseArticleSearchLinkCls(tempVar3);        
       
        testController3.saveCaseComment();           
    
        PageReference pg2 = Page.addCaseCommentPopup;
        test.setCurrentPage(pg2);
        ApexPages.StandardController tempVar2 = new ApexPages.StandardController(tempCase);
        ApexPages.currentPage().getParameters().put('id', tempCase.Id);
        ApexPages.currentPage().getParameters().put('artId', 'https://docs.marketo.com/display/DOCS/Understanding Email Testing Options?src=search_Understanding Email Testing Options;https://docs.marketo.com/display/DOCS/Understanding Email Testing Options?src=search_Understanding Email Testing Optionsss');        
        ApexPages.currentPage().getParameters().put('docType','Community');             
        CaseArticleSearchLinkCls testController2 = new CaseArticleSearchLinkCls(tempVar2 );        
       
        testController2.saveCaseComment();
        testController2.saveCaseComment(); //generate exception                
        CaseUtils.sendCaseNotificationWithJiveEnabled(new List<Id>{tempCase.Id},System.Label.Jive_Search_Credentials);
        CaseUtils.sendCaseNotificationWithJiveEnabled(new List<Id>{tempCase.Id},'');
    }
    
    static testMethod void testArticleControllerUpdated() {
        Entitlement  demoEntitlement = [Select id from Entitlement where Name = 'Marketo Demo 17 Internal'];
        List<Contact> tempContact = [Select Id, AccountId From Contact where Customer_Portal_User__c = true and Is_Authorized_Contact__c = 'Yes' Limit 1];
        System.Debug('tempContact++++'+tempContact[0].Id);
        Case tempCase = new case(OwnerId = testUser.Id,Origin='Web',ContactId = tempContact[0].Id, AccountId = tempContact[0].AccountId, subject='Test Case',description='asd',Problem_Type__c='Community',Category__c='General Questions',Priority='P3',Status = 'Awaiting Customer Input',EntitlementId = demoEntitlement.Id);        
        System.Debug('Case at time of creation'+tempCase);
        insert tempCase;
        System.Debug('Case at time of creation'+tempCase);
        pageReference pg = Page.CaseArticleSearch;
        ApexPages.StandardController tempVar = new ApexPages.StandardController(tempCase);
        ApexPages.currentPage().getParameters().put('id', tempCase.Id);
        ApexPages.currentPage().getParameters().put('articleId', '12345');
        ApexPages.currentPage().getParameters().put('searchText', 'nation.marketo.com/DOC-1245');
        UpdatedArticleSearchController testUpdatedArticleSearchController = new UpdatedArticleSearchController(tempVar);
        ApexPages.currentPage().getParameters().put('searchText', 'docs.marketo.com?pageId=');
        UpdatedArticleSearchController testUpdatedArticleSearchController2 = new UpdatedArticleSearchController(tempVar);
        test.setCurrentPage(pg);
        testUpdatedArticleSearchController.currResourcePageNum = 1;
        testUpdatedArticleSearchController.resourceArticleNext();
        testUpdatedArticleSearchController.resourceArticlePrev();
        testUpdatedArticleSearchController.getLastPageNumber();
        testUpdatedArticleSearchController.getLanguageList();
        testUpdatedArticleSearchController.languageStaticMap();
        testUpdatedArticleSearchController.refreshWrapper();
        testUpdatedArticleSearchController.attachArticles();
        testUpdatedArticleSearchController.deAttachArticles();    
        testUpdatedArticleSearchController.channelType = 'Internal';
    }
      
    
}