@isTest(SeeAllData=True)
public class Marketo_TestCodes{

    Public static testmethod void test_Marteko() {
        User usr1 = Marketo_TestCodes.TestUser();
        usr1.UserName='test1@marketo.com';
        usr1.IsActive=true;
        
        insert usr1;
        usr1.IsActive=false;
        update usr1;
        
        User usr2 = Marketo_TestCodes.TestUser();
        usr2.UserName='test2@marketo.com';
        usr2.IsActive=false;
        insert usr2;
        
        usr2.IsActive=true;
        update usr2;
    }
    
    public static user TestUser(){
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator' limit 1]; 
        User u = new User(Alias = 'standt', Email='test@marketo.com', EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, TimeZoneSidKey='America/Los_Angeles');
        return u;
    }
    
    Public static testmethod void test_Marteko1(){
        List<Account> accts = new List<Account>();
        for(Integer i=0;i<3;i++) {
            Account a = new Account(Name='Acme' + i, 
            BillingCity='San Francisco');
            accts.add(a);
        }
        insert accts;
        accts[0].ParentId = accts[1].id;
        accts[0].CAM_Assign_Status__c = 'Pending CAM Group Assignment';
        Update accts[0];
    }
    
    public static testMethod void test_EmailNotification() {   
         
        List<Authorized_Contact__c> authorizedContact = new List<Authorized_Contact__c>([Select Entitlement__r.Id,Entitlement__c, Entitlement__r.AssetId, Contact__c,Contact__r.accountid, Entitlement__r.Asset.Munchkin_Id__c From Authorized_Contact__c where Entitlement__r.Status = 'Active' and  Entitlement__r.Type in ('Elite','Premier') Limit 1]);
        asset tempasset = new asset(name='test', asset_type__c ='Subscription',accountid=  authorizedContact[0].Contact__r.accountid);
        insert tempasset;
        asset tempaddon = new asset(name='test',asset_type__c ='Add On',status = 'Expired',accountid=  authorizedContact[0].Contact__r.accountid,Parent_Instance__c = tempasset.id);
        insert tempaddon ;
        Case caseObj = new Case(Problem_Type__c = 'How-To',Assetid=tempasset.id, EntitlementId = authorizedContact[0].Entitlement__r.Id,Case_Issue__c = 'Analytics' ,Case_Sub_Issue__c='MFM', Category__c = 'Design Studio',Sub_Category__c = 'Other' ,Status = 'Working', Priority = 'P4', Subject = 'Test', SuppliedEmail = 'test@test.com',Description = 'Test Description', Origin = 'Web', ContactId = authorizedContact[0].Contact__c, recordTypeId = '01250000000UJwxAAG');
        insert caseObj;        
        List<Case> targetCases= new List<Case>(); targetCases.add(caseObj);
        List<Id> entitlementIds = new List<Id>(); entitlementIds.add(authorizedContact[0].Entitlement__r.Id);        
        CaseTriggerUtility.emailToNamSupEngOrTechAcctMan(targetCases,entitlementIds);           
        CaseTriggerUtility.isValidRecordTypeId('01250000000UJwxAAG');
        CaseTriggerUtility.returnCaseRecordTypeId('Support Cases');
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(caseObj);              
        ApexPages.currentPage().getParameters().put('id', caseObj.Id);   
        CustomCasePage myPg =  new CustomCasePage();            
        myPg.supportRedirect();
        return;    
    }
    
    public static testMethod void testEmailAndVideoTrackController() {
        contact cont = new contact(lastname = 'testname',email = 'test@marketo.com');
        insert cont;
        Test.StartTest();
        PageReference pageRef = Page.OnboardingEmailTracking;
        Test.setCurrentPage(pageRef);                  
        
        list<Authorized_Contact__c>auth = [select id from Authorized_Contact__c where Contact__c!=null and Entitlement__c!= null and Entitlement__r.type = 'Business'];
        system.debug('auth ==>' + cont.Id);       
        Authorized_Contact_Onboarding__c abc = new Authorized_Contact_Onboarding__c();            
        abc.Authorized_Contact_Id__c = cont.id;
        abc.Video_last_open__c = system.now();
        abc.Video_Seen__c = true;
        abc.Video_Seen_Time__c = system.now();
        abc.No_of_times_Video_open__c = 5;
        abc.Email_Read__c = true;
        abc.Email_Date_Opened__c =system.now();
        abc.No_of_times_email_open__c =5;
        abc.Email_Last_Opened__c =system.now();
        insert abc;        
        
        ApexPages.currentPage().getParameters().put('id',abc.Id);             
        system.debug('abc.id==>' + abc.id);
        EmailAndVideoTrackController controller1 = new EmailAndVideoTrackController();
        controller1.UpdateAuth();            
        system.debug('abc ==>' + abc.Authorized_Contact_Id__c);       
        ApexPages.currentPage().getParameters().put('id',abc.Authorized_Contact_Id__c);             
        system.debug('abc.id==>' + abc.id);
        EmailAndVideoTrackController controller = new EmailAndVideoTrackController();
        controller.UpdateAuth();
        controller.VideoTrack();
        Test.StopTest();

    }
       
    /*public static testMethod void testEmailAndVideoTrackController1() {
        Account acc = new Account(name = 'test');
    
        contact cont = new contact(lastname = 'testname',email = 'test@marketo.com',accountId = acc.id);
        insert cont;
        Test.StartTest();

        PageReference pageRef = Page.OnboardingVideoTrack;
        Test.setCurrentPage(pageRef);                  
        
        list<Authorized_Contact__c >auth = [select id, Entitlement__c,contact__c from Authorized_Contact__c where Contact__c!=null and Entitlement__c!= null and Entitlement__r.type = 'Business'];
        auth[0].First_Reminder_Req__c =true;
        auth[0].Second_Reminder_Req__c=true;
        update auth[0];
        
        Authorized_Contact__c  Authr = new Authorized_Contact__c();
        Authr.contact__c = auth[0].contact__c;
        Authr.Entitlement__c = auth[0].Entitlement__c;
        insert Authr;

        system.debug('auth ==>' + cont.Id);              
        Authorized_Contact_Onboarding__c abc = new Authorized_Contact_Onboarding__c();            
        abc.Authorized_Contact_Id__c = cont.id;
        abc.Video_last_open__c = system.now();
        abc.Video_Seen__c = true;
        abc.Video_Seen_Time__c = system.now();
        abc.No_of_times_Video_open__c = 5;
        abc.Email_Read__c = true;
        abc.Email_Date_Opened__c =system.now();
        abc.No_of_times_email_open__c =5;
        abc.Email_Last_Opened__c =system.now();
        
        insert abc;
        //Test.setCurrentPageReference(new PageReference('Page.OnboardingVideoTrack')); 
        
        system.debug('abc ==>' + abc.Id);               
        ApexPages.currentPage().getParameters().put('id',abc.Id);        
        EmailAndVideoTrackController controller1 = new EmailAndVideoTrackController();         
        controller1.VideoTrack();
        
        system.debug('abc ==>' + abc.Id);               
        ApexPages.currentPage().getParameters().put('id',abc.Authorized_Contact_Id__c);        
        //System.currentPageReference().getParameters().put('id',abc.id);     
        EmailAndVideoTrackController controller = new EmailAndVideoTrackController();         
        controller.VideoTrack();
        Test.stopTest();
    }*/
    
    
    public Static testmethod void testupdatetier3Case7(){
        Test.StartTest();  
        string tierRecId = System.Label.tier3RecordTypeId;        
        string SuppRecId = System.Label.SupportCaseId; 
        case tier3case1 = [select id,parentId from case where recordtypeid =:tierRecId and status!='Closed' limit 1];
        case Suppcase = [select id,parentId,JIRA_Num__c from case where recordtypeid =:tierRecId and parentid=:tier3case1.parentid limit 1];
        Suppcase.JIRA_Num__c = 'Test321'; 
        update Suppcase;
        Test.StopTest();
    }
    
    public Static testmethod void TestTier3Ctrl(){  
        Test.StartTest();  
        case caseObj = new case();
        caseobj = [select id from case where recordtypeid = '01250000000UJwx' and Entitlementid!=null limit 1];
        ApexPages.currentPage().getParameters().put('id',caseObj.id);
        ApexPages.StandardController stdCase = new ApexPages.StandardController(caseObj);
        Tier3caseController CaseController  = new Tier3caseController(stdCase);     
        CaseController.populateTier3Section();
        Test.StopTest();    
    }
    
    public Static testmethod void testtier3Case1(){
        Test.StartTest();  
        string tierRecId = System.Label.tier3RecordTypeId;
        case tier3case1 = new case(subject='test', description='test', priority='P1', recordtypeid =tierRecId);
        insert tier3case1;
        Test.StopTest();    
    }
    public Static testmethod void testtier3Case2(){
        Test.StartTest();  
        string tierRecId = System.Label.tier3RecordTypeId;
        case tier3case2 = new case(subject='test', description='test', priority='P1', recordtypeid =tierRecId);
        insert tier3case2;
        Test.StopTest();
    }
    public Static testmethod void testtier3Case3(){
        Test.StartTest();  
        string tierRecId = System.Label.tier3RecordTypeId;
        case tier3case3 = new case(subject='test', description='test', priority='P1', recordtypeid =tierRecId);
        insert tier3case3;
        Test.StopTest();
    }
    public Static testmethod void testupdatetier3Case1(){
        Test.StartTest();  
        string tierRecId = System.Label.tier3RecordTypeId;
        case tier3case1 = [select id from case where recordtypeid =:tierRecId limit 1];
        tier3case1.Last_Public_Comment_Date_Time__c = system.now();
        tier3case1.JIRA_Num__c = 'test123';
        tier3case1.status = 'Closed';
        tier3case1.priority = 'P1';
        update tier3case1;
        Test.StopTest();
    }
    public Static testmethod void testupdatetier3Case2(){
        Test.StartTest();  
        string tierRecId = System.Label.tier3RecordTypeId;
        case tier3case1 = [select id from case where recordtypeid =:tierRecId limit 1];
        tier3case1.Last_Public_Comment_Date_Time__c = system.now();
        tier3case1.JIRA_Num__c = 'test123';
        tier3case1.priority = 'P2';
        update tier3case1;
        Test.StopTest();
    }
    public Static testmethod void testupdatetier3Case3(){
        Test.StartTest();  
        string tierRecId = System.Label.tier3RecordTypeId;        
        case tier3case1 = [select id from case where recordtypeid =:tierRecId limit 1];
        tier3case1.JIRA_Num__c = 'test123';
        tier3case1.Last_Public_Comment_Date_Time__c = system.now();
        tier3case1.priority = 'P3';
        update tier3case1;
        Test.StopTest();
    }
    
     public Static testmethod void testupdatetier3Case4(){
        Test.StartTest();  
        string tierRecId = System.Label.tier3RecordTypeId;        
        Case_Update_Milestones__c cm = [select id,case__c from Case_Update_Milestones__c where case__r.recordtypeid =:tierRecId and completed__c =false and Case__c!=null limit 1];
        case tier3case1 = [select id from case where recordtypeid =:tierRecId and id=:cm.case__c limit 1];
        tier3case1.priority = 'P1';
        update tier3case1;
        Test.StopTest();
    }
    public Static testmethod void testupdatetier3Case5(){
        Test.StartTest();  
        string tierRecId = System.Label.tier3RecordTypeId;        
        Case_Update_Milestones__c cm = [select id,Case__c from Case_Update_Milestones__c where case__r.recordtypeid =:tierRecId and completed__c =false and Case__c!=null limit 1];
        case tier3case1 = [select id from case where recordtypeid =:tierRecId and id=:cm.case__c limit 1];
        tier3case1.priority = 'P2';
        update tier3case1;
        Test.StopTest();
    }
    public Static testmethod void testupdatetier3Case6(){
        Test.StartTest();  
        string tierRecId = System.Label.tier3RecordTypeId;        
        Case_Update_Milestones__c cm = [select id,Case__c from Case_Update_Milestones__c where case__r.recordtypeid =:tierRecId and completed__c =false and Case__c!=null limit 1];
        case tier3case1 = [select id from case where recordtypeid =:tierRecId and id=:cm.case__c limit 1];
        tier3case1.priority = 'P3';
        update tier3case1;
        Test.StopTest();
    }
     public static testMethod void CustomerCommunicationTrackTest() {
        contact cont = new contact(lastname = 'testname1',email = 'test@marketo.com');
        insert cont;
        
        Customer_Communication_Action__c ccAObj = new Customer_Communication_Action__c(Contact__c = cont.id);
        insert ccAObj;
        
        Test.StartTest();

        PageReference pageRef = Page.CustomerCommunicationTracking;
        Test.setCurrentPage(pageRef); 
        
        ApexPages.currentPage().getParameters().put('id',ccAObj.Id);
        EmailAndVideoTrackController controller = new EmailAndVideoTrackController();
        controller.CustomerCommunicationTrack();
        controller.VideoTrack();
        Test.StopTest();
    }
    
    
   /* public Static testmethod void increaseTestCov(){
        CaseTriggerFunctionUpdated.IncCodeCoverage();
    }*/
    
}