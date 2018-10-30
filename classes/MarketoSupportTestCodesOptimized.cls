@isTest(SeeAllData=True)
public class MarketoSupportTestCodesOptimized{

    public static user testuser = [select id,name from user where isActive = true and profile.id = '00e50000000zJpI' limit 1];

    static void TestCodeForNewTrigger() {
        Support_Trigger_Settings__c TestCodeForOLDTrigger = Support_Trigger_Settings__c.getInstance('Case Optimized Trigger Enabled');
        TestCodeForOLDTrigger.Enable_Optimized_Trigger__c = False;         
    }
    
     
    public static testmethod void testCustomAccLookupPopupController(){
        Test.StartTest();                
        Account acc = new Account(Name = 'Test', Type='Customer', recordtypeid='01250000000ULb7');
        insert acc;
        List<Authorized_Contact__c> authorizedContact    = new List<Authorized_Contact__c>([Select Entitlement__c, Entitlement__r.AssetId, Contact__c, Entitlement__r.Asset.Munchkin_Id__c, Entitlement__r.Asset.Acct_Prefix__c, Contact__r.AccountId,Contact__r.Id From Authorized_Contact__c where Entitlement__r.Status = 'Active' Limit 1]);
        ApexPages.StandardController testObject = new ApexPages.StandardController(acc);
        CustomAccLookupPopupController CustomAccLookupPopupControllerObj = new CustomAccLookupPopupController(testObject);
        //CustomAccLookupPopupControllerObj.selAccount = acc;
        CustomAccLookupPopupControllerObj.query = 'test';
        CustomAccLookupPopupControllerObj.accPrefix= authorizedContact[0].Entitlement__r.Asset.Acct_Prefix__c;
        CustomAccLookupPopupControllerObj.accMunchkinId= '';                
        CustomAccLookupPopupControllerObj.runQuery();
        
        CaseTriggerFunction.setContactRedirectFuture( authorizedContact[0].Contact__r.id);
        CaseTriggerFunction.setContactRedirect( authorizedContact[0].Contact__r.id);
        
        CustomAccLookupPopupControllerObj.accPrefix= '';
        CustomAccLookupPopupControllerObj.accMunchkinId= authorizedContact[0].Entitlement__r.Asset.Munchkin_Id__c;                
        CustomAccLookupPopupControllerObj.runQuery();

        CustomAccLookupPopupControllerObj.accPrefix= authorizedContact[0].Entitlement__r.Asset.Acct_Prefix__c;
        CustomAccLookupPopupControllerObj.accMunchkinId= authorizedContact[0].Entitlement__r.Asset.Munchkin_Id__c;                
        CustomAccLookupPopupControllerObj.runQuery();
        
        
        CustomAccLookupPopupControllerObj.Beginning();
        CustomAccLookupPopupControllerObj.Previous();
        CustomAccLookupPopupControllerObj.Next();
        CustomAccLookupPopupControllerObj.End() ;
        CustomAccLookupPopupControllerObj.getDisablePrevious();
        CustomAccLookupPopupControllerObj.getDisableNext();
        CustomAccLookupPopupControllerObj.getTotal_size();
        CustomAccLookupPopupControllerObj.getPageNumber();
        CustomAccLookupPopupControllerObj.getTotalPages();
        Test.StopTest();       
    } 
     
   
    public static testMethod void testPublicCaseCreatePage() {
        List<Authorized_Contact__c> authorizedContact    = new List<Authorized_Contact__c>([Select Entitlement__c, Entitlement__r.AssetId, Contact__c, Entitlement__r.Asset.Munchkin_Id__c, Contact__r.AccountId,Contact__r.Id From Authorized_Contact__c where Entitlement__r.Status = 'Active' Limit 1]);
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
        tmpCtrl.createNagiosCase(); 
        tmpCtrl.NagiosCase.AccountId = authorizedContact[0].Contact__r.AccountId;
        tmpCtrl.NagiosCase.ContactId = authorizedContact[0].Contact__r.Id;        
        tmpCtrl.accOnBehalf = authorizedContact[0].Contact__r.AccountId;
        tmpCtrl.contactOnBehalf = authorizedContact[0].Contact__r.Id;
        tmpCtrl.NagiosCase.AccountId = authorizedContact[0].Contact__r.AccountId;
        tmpCtrl.NagiosCase.ContactId = authorizedContact[0].Contact__r.Id;        
        tmpCtrl.NagiosCase.Case_Creator_Contact__c = authorizedContact[0].Contact__c;
        tmpCtrl.NagiosCase.Subject = 'Test';
        tmpCtrl.NagiosCase.Description = 'Test';        
        tmpCtrl.NagiosCase.Priority = 'P2';
        tmpCtrl.NagiosCase.ContactId = authorizedContact[0].Contact__r.Id;
        tmpCtrl.createNagiosCase();
        //tmpCtrl.createSMCase();
        return; 
               
    }
    
    public static testMethod void testEscalateFormToManager() {
        /*case tescase = [select id,OwnerId, Contact.name, account.name, accountID, Contact.Id from case where recordtypeid = '01250000000UK1E' and contactid!=null limit 1];
        ApexPages.StandardController sc = new ApexPages.StandardController(tescase);
        PublicCaseCreatePageCtrl ctr = new PublicCaseCreatePageCtrl(sc);
        ctr.refreshPanel();
        ctr.createSMCase();*/
    }

    public static testmethod void testCustomContactLookupPopupController() {
        Test.StartTest();
        Account acc = new Account(Name = 'Test', Type='Customer', recordtypeid='01250000000ULb7');
        insert acc;
        
        List<Authorized_Contact__c> authorizedContact    = new List<Authorized_Contact__c>([Select Entitlement__c, Entitlement__r.AssetId, Contact__c, Entitlement__r.Asset.Munchkin_Id__c, Contact__r.AccountId,Contact__r.Id From Authorized_Contact__c where Entitlement__r.Status = 'Active' Limit 1]);

        Contact con = new Contact(LastName = 'Test', AccountId = acc.id, Email = 'test@test.com', Customer_Portal_User__c = true, Munchkin_Id__c = authorizedContact[0].Entitlement__r.Asset.Munchkin_Id__c);
        insert con;
                
        ApexPages.StandardController testObject = new ApexPages.StandardController(con);
        CustomContactLookupPopupController CustomContactLookupPopupControllerObj = new CustomContactLookupPopupController(testObject);
        CustomContactLookupPopupControllerObj.selAccount = acc;
        CustomContactLookupPopupControllerObj.query = 'test';
        CustomContactLookupPopupControllerObj.runQuery();
        CustomContactLookupPopupControllerObj.Beginning();
        CustomContactLookupPopupControllerObj.Previous();
        CustomContactLookupPopupControllerObj.Next();
        CustomContactLookupPopupControllerObj.End() ;
        CustomContactLookupPopupControllerObj.getDisablePrevious();
        CustomContactLookupPopupControllerObj.getDisableNext();
        CustomContactLookupPopupControllerObj.getTotal_size();
        CustomContactLookupPopupControllerObj.getPageNumber();
        CustomContactLookupPopupControllerObj.getTotalPages();
        Test.StopTest();       
    }     
    
    
    
    public static Case TestCreateSupportCase(){
        TestCodeForNewTrigger();
        //RecordType supportCase = [Select Id From RecordType where SobjectType='Case' and Name = 'Support Cases']; 
        Id supportCaseId = CaseTriggerFunction.returnCaseRecordTypeId('Support Cases');
        List<Authorized_Contact__c> authorizedContact = new List<Authorized_Contact__c>([Select Entitlement__c, Entitlement__r.AssetId, Contact__c,Contact__r.accountid, Entitlement__r.Asset.Munchkin_Id__c From Authorized_Contact__c where Entitlement__r.Status = 'Active' and Entitlement__r.type = 'Elite' Limit 1]);
        asset tempasset = new asset(name='test', asset_type__c ='Subscription', accountid = authorizedContact[0].Contact__r.accountid);
        insert tempasset;
        asset tempaddon = new asset(name ='test',asset_type__c ='Add On',status = 'Expired',accountid=  authorizedContact[0].Contact__r.accountid,Parent_Instance__c = tempasset.id);
        insert tempaddon ;
        Case caseObj = new Case(Problem_Type__c = 'How-To', Assetid=tempasset.id, Case_Issue__c = 'Analytics' ,Case_Sub_Issue__c='MFM', Category__c = 'Design Studio',Sub_Category__c = 'Other' ,Status = 'New', Subject = 'Test', SuppliedEmail = 'test@test.com',Description = 'Test Description', Origin = 'Web', ContactId = authorizedContact[0].Contact__c, recordTypeId = supportCaseId, priority = 'P3');
        return caseObj;
    }

    public static testmethod void insertCase(){
        Test.StartTest();
        TestCodeForNewTrigger();
        case insertUpdate = TestCreateSupportCase();         
        insertUpdate.status = 'Awaiting Customer Input';
        insertUpdate.Email_List__c = 'test@test.com';
        insertUpdate.priority = 'P1';
        insert insertUpdate;
        
        CaseTriggerFunction.SendNeedReplyNotificationToNSEandManager(new List<Case>{insertUpdate});
        insertUpdate.ownerid = testuser.id;
        insertUpdate.status = 'Needs Reply';
        insertUpdate.To_Be_New_Case_Created__c = True;
        Update insertUpdate;      
        caseComment insertTestCC = new caseComment(ParentId = insertUpdate.Id, isPublished = true,commentBody = 'testing comment');
        insert insertTestCC;
        CaseTriggerFunction.SendNeedReplyNotificationToNSEandManager(new List<Case>{insertUpdate}); 
        CaseTriggerFunction.completeMilestoneFuture( new set<id>{insertUpdate.id}, 'First Response', System.now() );
        
        Map<String, List<String>> languageToCaseIdMap = new Map<String, List<String>>();        
        languageToCaseIdMap.put('ENGLISH', new List<String>{insertUpdate.Id+'_'+insertUpdate.ContactId} );
        CaseTriggerFunction.sendSurveyEmails(languageToCaseIdMap);     
        test.stoptest();
    }
    
    public static testmethod void UpdateCase() {
        TestCodeForNewTrigger();
        List<case> insertUpdate = new List<case>([select id from case where (status = 'working' or status = 'Awaiting Customer Input') and Entitlement.type = 'Elite' and priority ='P3' limit 1]);                        
        //CSatSurveyFeedback__c
        
        //isRltdCntctElgblForSurvey = true;
        if(!insertUpdate.isempty()){
            insertUpdate[0].priority = 'P1';
            insertUpdate[0].To_Be_New_Case_Created__c = True;
            insertUpdate[0].status = 'Closed';
            insertUpdate[0].Referral_Service_Request_Notes__c = 'test';
            insertUpdate[0].Category__c = 'Support Feedback';
            insertUpdate[0].SuppliedEmail = 'ab@gmail.com';
            insertUpdate[0].Close_Reason__c = 'Referred to Other Group';//'Resolved'; 
            insertUpdate[0].Problem_Type__c = 'Referred To';
            Test.StartTest();
            Update insertUpdate;
            
            caseComment insertTestCC = new caseComment(ParentId = insertUpdate[0].Id, isPublished = False,commentBody = 'testing comment');
            insert insertTestCC;
            test.stopTest();
        }
    } 
    
    Public static testMethod void EmailToCaseHandler() { 
        //TestCodeForOLDTrigger();       
        //create a new email and envelope object
        Messaging.InboundEmail email = new Messaging.InboundEmail() ;
        Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();
        
        //setup the data for the email
        email.subject = 'Test Email Service';
        email.plainTextBody = 'test@marketo.com#Test Email Service';
        email.fromname = 'Test';
        env.fromAddress = 'test@test.com';
        
        //call the email service class and test it with the data in the testMethod
        EmailToCaseHandler emailProcess = new EmailToCaseHandler();
        emailProcess.handleInboundEmail(email, env);
        
        //wrong syntax error check 
        email.plainTextBody = 'Test Email Service test';
        emailProcess.handleInboundEmail(email, env);

        //contact Con = [select id,email from contact where email like '%@marketo.com' limit 1];
        contact Con = [select id,email,name,accountId from contact where email like '%@marketo.com' limit 1];
        env.fromAddress = Con.email;
        email.plainTextBody = Con.email+'#Test Email Service';
        //call the email service class and test it with the data in the testMethod
        emailProcess.handleInboundEmail(email, env);      
        
    }
    
    public static testmethod void ReopenCase() {
        TestCodeForNewTrigger();    
        Id supportCaseId = CaseTriggerFunction.returnCaseRecordTypeId('Support Cases'); 
        List<case> insertUpdate = [select id from case where status = 'Closed' and problem_type__c != Null and recordtypeid =:supportCaseId limit 1];
        if(!insertUpdate.isempty()){               
            insertUpdate[0].status = 'Reopened';
            test.StartTest();
            Update insertUpdate[0];
            test.stopTest(); 
        } 
    }    
    
    public static testmethod void DowngradeCase() {
        TestCodeForNewTrigger();    
        Id supportCaseId = CaseTriggerFunction.returnCaseRecordTypeId('Support Cases'); 
        List<case> insertUpdate = [select id from case where status != 'Closed'  and problem_type__c != Null and priority != 'P3' and EntitlementId!=null and recordtypeid =:supportCaseId limit 1];
        if(!insertUpdate.isempty()){               
            insertUpdate[0].priority= 'P3';
            test.StartTest();
            Update insertUpdate[0];
            test.stopTest(); 
        } 
    }
    
    public static testMethod void updateSalesCases(){
        TestCodeForNewTrigger();    
        Id salesCaseId = CaseTriggerFunction.returnCaseRecordTypeId('Sales Cases');
        List<Case> salesCase = [select id from case where recordtypeid =:salesCaseId and origin != 'Email' limit 1];             
        if(!salesCase.isempty()){
            salesCase[0].Requester_Name__c = Userinfo.getUserId();
            salesCase[0].Sales_Ops_Category__c = 'Other';
            salesCase[0].SuppliedEmail = 'ab@gmail.com';
            update salesCase[0];
        }
    }
    
    public static testMethod void updateSalesCases1(){     
        TestCodeForNewTrigger();       
        Case salesCase1 =  createSalesCase();
        salesCase1.Requester_Role__c = Userinfo.getUserId();
        salesCase1.Requester_Profile__c = UserInfo.getProfileId();
        salesCase1.Requester_Manager__c = UserInfo.getFirstName();
        //salesCase1.SuppliedEmail= Userinfo.getUserEmail();
        insert salesCase1;
        try{
            TriggerFactory.createHandler(Authorized_Contact__c.Case.sObjectType);
        } catch(Exception ex) {
        
        }
        customMilestoneUtil.getIgnoreCaseStatuses();
        customMilestoneUtil.getSetOfCaseAdmins();
    }
     
    public static testMethod void createContractExpryRemindrCases() {            
        List<Authorized_Contact__c> authorizedContact = new List<Authorized_Contact__c>([Select Entitlement__c, Entitlement__r.AssetId, Contact__c,Contact__r.accountid, Entitlement__r.Asset.Munchkin_Id__c, Entitlement__r.Contract_Review_Date__c From Authorized_Contact__c where Customer_Admin__c = True AND Entitlement__r.Status = 'Active' and Entitlement__r.type in ('Elite','Premier') Limit 1]);
        Date tmpDate=Date.Today().addMonths(-6);
        Entitlement ent = new Entitlement(id = authorizedContact[0].Entitlement__r.Id, StartDate = tmpDate);
        update ent;
        ContractExpiryReminderCaseScheduler c1 = new ContractExpiryReminderCaseScheduler ();
        c1.execute(null);        
    }    
           
    static Case createSalesCase(){
        Id salesCaseId = CaseTriggerFunction.returnCaseRecordTypeId('Sales Cases'); 
        Case caseObj = new Case(Status = 'New', Priority = 'P3', Subject = 'Test',Description = 'Test Description', Origin = 'Email', recordTypeId = salesCaseId);
        return caseObj;        
    }
    
    public static testMethod void testSwapProfile2() {        
        PageReference pageRef = Page.SwapJiveProfileInfo;
        Test.setCurrentPage(pageRef);                
        SwapJiveProfileInfoController2 controller = new SwapJiveProfileInfoController2();
        controller.init();
        //controller.getUserDetails();
        //controller.getFields();
        controller.refreshPanel();        
        controller.updateProfileType = 'Self';
        controller.getProfileSwappingCallout();
        controller.checkForNull(controller.OldUserDetail);
        controller.continuedProfileSwapCallout();
        controller.updateProfileType = 'Swap';
        controller.getProfileSwappingCallout();
        controller.continuedProfileSwapCallout();
        controller.stageCntr = 2;    
        controller.continuedProfileSwapCallout(); 
        controller.stageCntr = 3;           
        controller.continuedProfileSwapCallout();                
        controller.processHttpResponse();                  
        controller.stageError = True;
        controller.stageCntr = 2;    
        controller.continuedProfileRollbackCallout();
        controller.processChainedResponse();           
        controller.stageCntr = 2;    
        controller.processHttpResponse();                                    
    }    
    
    
    public static testMethod void UtilityTest() { 
        try{
            integer integ = 1/0;
        }catch(Exception e) {
            CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);     
        }
        
        list<case> cas = [select Id,status from Case where Entitlementid !=null And recordtypeId = '01250000000UJwx' and status = 'Needs Reply' limit 1];
        cas[0].status = 'Needs Reply';
        update cas[0];
                          
    }
    
    public static testMethod void P1caseBullkTest() { 
        batchcaseP1Update btch = new batchcaseP1Update();
        Database.executeBatch(btch, 200);                          
    }
    
    public static testMethod void TestIncCodeCoverage() { 
        CustomMileStoneUtil.IncCodeCoverage();                         
    }
    
    public static testMethod void MentorSessionReminderSchedulerTest() {            
       MentorSessionReminderScheduler c1 = new MentorSessionReminderScheduler();
        c1.execute(null); 
        
        list<id> caslist = new list<id>();
        for(case cs: [select id from case where (ownerid = '00G50000001QuPs' OR ownerid = '00G50000001TQqY') And status = 'New' limit 2 ]){
            caslist.add(cs.id);
        }
        CaseTriggerFunction.routeDefaultnLPcasesToUs(caslist);
    }
      static testMethod void CaseQualityReviewTestMethod(){
        User us1 = [Select Id,Case_Quality_Reviews_Count__c,Name from User Where Alias='BGomes'];
        User us2 = [Select Id,Case_Quality_Reviews_Count__c,Name from User Where Alias='DMayberr'];
        
        CaseQualityReviewBatchApex cqrb = new CaseQualityReviewBatchApex();
        List<User> completeTseList = [Select Id, Case_Quality_Reviews_Count__c,Name, ManagerId, Manager.FirstName  from User Where (Profile.Id = '00e50000000zJpI') AND isActive = True Limit 1];
        cqrb.execute(null, completeTseList);
        System.Debug('_____User 1______'+us1);
        System.RunAs(us2) {
            GetUsersBasedOnRoleHeirarchyCtrl tempObject = new GetUsersBasedOnRoleHeirarchyCtrl();
            tempObject.setstate('');
            tempObject.setUserId(us1.Id);
            tempObject.runQuery();
            tempObject.methodOne();

            Manger_Activity_Log__c tempManObj = new Manger_Activity_Log__c();
            tempManObj.SupportManager__c = us2.Id;
            tempManObj.TseName__c = us1.Id;
            tempManObj.Evaluation_Started__c = date.newinstance(System.now().year(), System.now().month(), System.now().day());
            tempManObj.Evaluation_Ended__c = tempManObj.Evaluation_Started__c.addDays(30);
            tempManObj.Status__c = 'Completed';
            tempManObj.Status_Changed_For_Manager_Activity_Log__c = true;
            insert tempManObj; 
            
            tempObject.PerformReview();    
            PageReference pageRef = Page.CaseEvaluationV1;
            Test.setCurrentPage(pageRef);
            ApexPages.currentPage().getParameters().put('userName', us1.Name);
            ApexPages.currentPage().getParameters().put('activityLogId', tempManObj.Id);
            ApexPages.currentPage().getParameters().put('userId', us1.Id);
            CaseEvaluationControllerV1 testCaseEvalObj = new CaseEvaluationControllerV1();
            
            testCaseEvalObj.getCaseListBasedOnFilterCriteria();

            ApexPages.currentPage().getParameters().put('Casenumber', ' ');
            System.debug('___Casenumber______'+ApexPages.currentPage().getParameters().get('Casenumber'));
            CaseLookupController testLoopObj = new CaseLookupController();
            testLoopObj.searchGo();            
        }
    }
     /*static testmethod void TestEmailNotificationToManager(){
         User us1 = [Select Id,Case_Quality_Reviews_Count__c,Name from User Where Alias='BGomes'];
         User us2 = [Select Id,Case_Quality_Reviews_Count__c,Name from User Where Alias='DMayberr'];
         Set<id> userIds = new Set<id>();
         userIds.add(us1.id);
         userIds.add(us2.id);
         
         Manger_Activity_Log__c tempManObj = new Manger_Activity_Log__c();
         tempManObj.SupportManager__c = us2.Id;
         tempManObj.TseName__c = us1.Id;
         tempManObj.Evaluation_Started__c = date.newinstance(System.now().year(), System.now().month(), System.now().day());
         tempManObj.Evaluation_Ended__c = tempManObj.Evaluation_Started__c.addDays(30);
         tempManObj.Status__c = 'Completed';
         tempManObj.Status_Changed_For_Manager_Activity_Log__c = true;
         insert tempManObj; 
        
         EmailNotificationToManager ent = new EmailNotificationToManager();
         EmailNotificationToManager.sendEmailReminder(userIds);
         EmailNotificationToManager.sendEmailFirstReminder(userIds);
         EmailNotificationToManager.fetchDefaulterManager();
         EmailNotificationToManager.fetchFreshReviewsForManager();
         
    }*/
     static testmethod void ProactiveCaseTest(){
        Test.StartTest();
        ProactiveCaseBatchClass upc =  new ProactiveCaseBatchClass(); 
        ID batchprocessid = Database.executeBatch(upc);
        ProactiveCasesSchedulerClass sc = new ProactiveCasesSchedulerClass();
        sc.execute(null);
        Test.StopTest();
       
    }
     static testmethod void ifRequestManagerReviewCheckedTest(){
        /*case cse = [select id,DescriptionNeeded__c from case where status != 'closed' and Request_Manager_Review__c = false limit 1];
        cse.status = 'Closed';
        cse.Request_Manager_Review__c = true;
        cse.DescriptionNeeded__c = 'testing';
        update cse;
        CaseTriggerFunction.ifRequestManagerReviewChecked();*/
        Test.startTest();
        case cs = [select id,Accountid,Account.CAM_Owner__c from case where Accountid != null and Account.CAM_Owner__c != null limit 1];
        //CaseTriggerFunction.NonAuthCaseNotificationToCAM(cs.Id);
        Test.stopTest();
        
    }
     static testmethod void CasesOpenedForSecondTimeTest(){
        Test.StartTest();
        case c = [Select id,contactId,Subject,Description,casenumber,status, category__c, AccountId, (select OldValue, NewValue from Histories where Field = 'Status') parentid, Ownerid, Entitlement.Technical_Account_Manager__c, Entitlement.Named_support_Engineer__c from case where recordtypeId = '01250000000UJwx' and status ='Closed' and Entitlement.type in ('Premier', 'Premier Plus') and isNSECaseOwner__c=false AND (Entitlement.Named_support_Engineer__c!=null OR Entitlement.Technical_Account_Manager__c!=null) limit 1];
        c.status = 'Open';
        update c;
        case cas = [Select id,contactId,Subject,Description,casenumber,status, category__c, AccountId, (select OldValue, NewValue from Histories where Field = 'Status') parentid, Ownerid, Entitlement.Technical_Account_Manager__c, Entitlement.Named_support_Engineer__c from case where id =:c.id and recordtypeId = '01250000000UJwx' and status!='Closed' and Entitlement.type in ('Premier', 'Premier Plus') and isNSECaseOwner__c=false AND (Entitlement.Named_support_Engineer__c!=null OR Entitlement.Technical_Account_Manager__c!=null) limit 1];
        CaseTriggerFunction.CasesOpenedForSecondTime();
        Test.StopTest();
       
    }
    static testmethod void updateBusinessHoursTest(){
        Test.StartTest();
        case cs = new case();
        cs.Problem_type__c = 'Security Report';
        cs.origin ='Security';
        cs.Category__c = 'Other';
        cs.Priority = 'P3';
        cs.Security_Origin_External__c = True;
        try{
            insert cs;
        }catch(Exception e){
            system.debug(e.getMessage());
        }
        
        Test.StopTest(); 
    }
    static testmethod void InitializeSurveySettingsTest(){
        Test.StartTest();
        Entitlement et = [select id from entitlement where type ='elite' and Entitlement.Named_support_engineer__c !=null limit 1];
        case cs = new case();
        cs.SurveyLinkEmailerSent__c = false;
        cs.RecordTypeId = '01250000000UJwx';
        cs.Close_Reason__c = 'Resolved';
        cs.Problem_Type__c ='How-To';
        cs.Category__c ='Email';
        cs.Entitlementid = et.id;
        try{
            insert cs;
        }catch(Exception e){
            system.debug(e.getMessage());
        }
        Test.StopTest(); 
    }
   static testmethod void emailToNamSupEngOrTechAcctManTest(){
        Test.StartTest();
        Map<Case,Id> caseMap = new Map<Case,Id>();
        Map<Id,String> cseMap = new Map<Id,String>();
        List<Id> csList = new List<Id>();
        for(Case c : [Select id,entitlementId,ownerid  from case where entitlementId != null limit 1]){
            caseMap.put(c,c.entitlementId);
            cseMap.put(c.Id,'Insert');
            csList.add(c.Id);
        }
        CaseTriggerFunction.emailToNamSupEngOrTechAcctMan(caseMap);
        CaseTriggerFunction.updateCaseOnCC(cseMap);
        CaseTriggerFunction.P1Extended(csList);
        CaseTriggerFunction.routeDefaultnLPcasesToUs(csList);
        Test.StopTest(); 
    }
     
}