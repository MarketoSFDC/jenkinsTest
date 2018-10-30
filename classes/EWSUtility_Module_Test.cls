// test class form EWS module
/*********************************************************************
* Last Modified by   : Grazitti 
* Modified Date      : 28-April-18
* Purpose            : #01009688 Consolidate Support Engineer Fields on Entitlement
* Line numbers       : 121,126,281

**********************************************************************/
@isTest
private class EWSUtility_Module_Test{
    
    static testMethod void eWSUtility() {
        
        integer randomInt = (integer)(100.0 * Math.random());
        integer randomInt1 = (integer)(100.0 * Math.random());
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User usr = new User(LastName = 'test'+randomInt,
                           FirstName='example',
                           Alias = 'jex'+randomInt,
                           Email = 'exampleGraztest@asdf.com',
                           Username = 'example'+randomInt+'.test@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert usr;
        
        User usr1 = new User(LastName = 'test'+randomInt1,
                           FirstName='example',
                           Alias = 'jex'+randomInt1,
                           Email = 'exampleGraztest@asdf.com',
                           Username = 'example'+randomInt1+'.test@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert usr1;
         
        Support_Trigger_Settings__c TestCodeForOLDTrigger = new Support_Trigger_Settings__c(name='Case Optimized Trigger Enabled',Enable_Optimized_Trigger__c=True);
        insert TestCodeForOLDTrigger;
        
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Unit Test Corp'));
        accounts.add(new Account(Name = 'Unit Test LLC'));
        accounts.add(new Account(Name = 'Parent Company Inc'));
        insert accounts;
        
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = accounts[0].Id, FirstName = 'Tess', LastName = 'Dachshund'));
        contacts.add(new Contact(AccountId = accounts[0].Id, FirstName = 'Grachus', LastName = 'Dachshund'));
        contacts.add(new Contact(AccountId = accounts[1].Id, FirstName = 'Pete', LastName = 'Dachshund'));
        contacts.add(new Contact(AccountId = accounts[1].Id, FirstName = 'Alphonse', LastName = 'Dachshund'));
        contacts.add(new Contact(AccountId = accounts[1].Id, FirstName = 'Alphonse', LastName = 'Dachshund',NPS_Score__c=6));
        contacts.add(new Contact(AccountId = accounts[1].Id, FirstName = 'Alphonse', LastName = 'Dachshund',NPS_Score__c=9));
        insert contacts;
        
        List<EWS_Point_Table__c> ewsPointsList = new List<EWS_Point_Table__c>();
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'P2 Case',Type__c= 'Support',Driver__c='Relationship',Sub_Driver__c= 'P2 Case'));       
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'P1 Condition',Type__c= 'Support',Driver__c='Product Experience',Sub_Driver__c= 'P1 Condition'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Positive NPS',Type__c= 'CSM',Driver__c='Direct Communication',Sub_Driver__c= 'Positive NPS'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Half-Yearly Review',Type__c= 'Product',Driver__c='Product Experience',Sub_Driver__c= 'Product SitMan'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'New CSM',Type__c= 'CSM',Driver__c='Relationship',Sub_Driver__c= 'New CSM'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Temperature Change',Type__c= 'CSM',Driver__c='Relationship',Sub_Driver__c= 'Temperature Change'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Renewal Soon',Type__c= 'CSM',Driver__c='Relationship',Sub_Driver__c= 'Renewal Soon'));   
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'New NSE',Type__c= 'Support',Driver__c='Relationship',Sub_Driver__c= 'New NSE')); 
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'New Admin',Type__c= 'CSM',Driver__c='Relationship',Sub_Driver__c= 'New Admin'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'New Authorized Contact',Type__c= 'CSM',Driver__c='Relationship',Sub_Driver__c= 'New Authorized Contact'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Blacklist',Type__c= 'Support',Driver__c='Product Experience',Sub_Driver__c= 'Blacklist'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'CSATs with entry of "Product"',Type__c= 'Product',Driver__c='Product Experience',Sub_Driver__c= 'Product SitMan'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Sitman with Entry "Product"',Type__c= 'Product',Driver__c='Product Experience',Sub_Driver__c= 'Product SitMan'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Case Closed "Reffered to Ideas"',Type__c= 'Product',Driver__c='Product Experience',Sub_Driver__c= 'Product Support Case'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Sitman Filled',Type__c= 'Support',Driver__c='Direct Communication',Sub_Driver__c= 'Sitman Filled'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Positive CSAT',Type__c= 'Support',Driver__c='Direct Communication',Sub_Driver__c= 'Positive CSAT'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Negative CSAT',Type__c= 'Support',Driver__c='Direct Communication',Sub_Driver__c= 'Negative CSAT'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Negative NPS',Type__c= 'CSM',Driver__c='Direct Communication',Sub_Driver__c= 'Negative NPS'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Escalated to SME',Type__c= 'Support',Driver__c='Case Handling',Sub_Driver__c= 'Escalated to SME'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Escalated to Engineering',Type__c= 'Support',Driver__c='Case Handling',Sub_Driver__c= 'Escalated to Engineering'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Excessive (2+) Reopens',Type__c= 'Support',Driver__c='Case Handling',Sub_Driver__c= 'Excessive Reopens'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Aging: 10 days',Type__c= 'Support',Driver__c='Time to Resolution',Sub_Driver__c= 'Aging: 10 days'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Aging: 30 days',Type__c= 'Support',Driver__c='Time to Resolution',Sub_Driver__c= 'Aging: 30 days'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Aging: 60 days',Type__c= 'Support',Driver__c='Time to Resolution',Sub_Driver__c= 'Aging: 60 days'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Aging: 100 days',Type__c= 'Support',Driver__c='Time to Resolution',Sub_Driver__c= 'Aging: 100 days'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Inactivity: Low Logins',Type__c= 'CSM',Driver__c='Usage',Sub_Driver__c= 'Inactivity: Logins'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Inactivity: Low Email sends',Type__c= 'CSM',Driver__c='Usage',Sub_Driver__c= 'Low Email Sends'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Case Opened: Volatile Subject',Type__c= 'CSM',Driver__c='Usage',Sub_Driver__c= 'Case Opened: Volatile Subject'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Mentor Session',Type__c= 'Support',Driver__c='Service Consumed',Sub_Driver__c= 'Mentor Session'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Half-Yearly Review',Type__c= 'Support',Driver__c='Service Consumed',Sub_Driver__c= 'Half-Yearly Review'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Renewed',Type__c= 'CSM',Driver__c='Service Consumed',Sub_Driver__c= 'Renewed'));
        insert ewsPointsList;
        
        List<Case> caseList = new List<Case>();
        caseList.add(new Case(ContactId = contacts[0].Id,subject='Feature Request',Escalated_to_SME__c=True, AccountId = accounts[0].Id,Priority='P2',Status='New',Problem_Type__c='Feature Request',Close_Reason__c='Resolved',Sub_Category__c='Scheduling',Category__c='Marketing Activities', Situation_Contact__c = contacts[0].id));
        caseList.add(new Case(ContactId = contacts[0].Id,subject='Feature Request',Escalated_to_SME__c=True, AccountId = accounts[0].Id,Priority='P2',Status='New',Problem_Type__c='Feature Request',Close_Reason__c='Resolved',Sub_Category__c='Scheduling',Category__c='Marketing Activities', Situation_Contact__c = contacts[0].id,recordTypeId='01250000000UK1E',Situation_Account__c= accounts[1].Id));
        caseList.add(new Case(ContactId = contacts[0].Id,subject='Feature Request',JIRA_Num__c='123456',Escalated_to_SME__c=True, AccountId = accounts[0].Id,Priority='P2',Status='New',Problem_Type__c='Feature Request',Close_Reason__c='Resolved',Sub_Category__c='Scheduling',Category__c='Marketing Activities', Situation_Contact__c = contacts[0].id,recordTypeId='01250000000UJwx'));  
        caseList.add(new Case(ContactId = contacts[0].Id,subject='Feature', AccountId = accounts[0].Id,Priority='P1',Status='New',Sub_Category__c='Scheduling',Category__c='Marketing Activities', Situation_Contact__c = contacts[0].id,recordTypeId='01250000000UJwx'));  
        caseList.add(new Case(ContactId = contacts[0].Id,subject='Feature', AccountId = accounts[0].Id,Priority='P2',Status='New',Sub_Category__c='Scheduling',Category__c='Marketing Activities', Situation_Contact__c = contacts[0].id,recordTypeId='01250000000UJwx'));
        caseList.add(new Case(ContactId = contacts[0].Id, AccountId = accounts[0].Id,Priority='P1',Status='New',Problem_Type__c='Feature Request',Close_Reason__c='Resolved',Sub_Category__c='Scheduling',Category__c='Marketing Activities',Situation_Contact__c = contacts[0].id,recordTypeId='01250000000UJwx'));  
        insert caseList;
        Test.startTest();
        List<Case> caseToUpdateList1 = new List<Case>();
        caseToUpdateList1.add(new Case(Id=caseList[1].Id,JIRA_Num__c='123456',ContactId = contacts[0].Id,subject='Feature',Close_Reason__c = 'Referred to Ideas',Problem_Type__c='Bug',Accept_Reject_Notes__c='test notes', AccountId = accounts[0].Id,Priority='P1',Sub_Category__c='Boomi',Status='Closed',Category__c='Other',Situation_Contact__c = contacts[0].id,recordTypeId='01250000000UJwx'));
        caseToUpdateList1.add(new Case(Id=caseList[0].Id,JIRA_Num__c='123456',ContactId = contacts[0].Id,subject='Feature',Close_Reason__c = 'Referred to Ideas',Problem_Type__c='Bug',Accept_Reject_Notes__c='test notes', AccountId = accounts[0].Id,Priority='P1',Sub_Category__c='Boomi',Status='Closed',Category__c='Product Functionality',Situation_Contact__c = contacts[0].id,recordTypeId='01250000000UJwx'));
        caseToUpdateList1.add(new Case(Id=caseList[2].Id,JIRA_Num__c='123456',ContactId = contacts[0].Id,subject='Feature',Close_Reason__c = 'Referred to Ideas',Problem_Type__c='Bug',Accept_Reject_Notes__c='test notes', AccountId = accounts[0].Id,Priority='P1',Sub_Category__c='Boomi',Status='New',Category__c='Product Functionality',Situation_Contact__c = contacts[0].id,recordTypeId='01250000000UJwx'));
        update caseToUpdateList1;
        
        List<Case> caseToUpdateList2 = new List<Case>();
        caseToUpdateList2.add(new Case(Id=caseToUpdateList1[1].Id,ContactId = contacts[0].Id,subject='Feature',Close_Reason__c='Suggestion Provided (Soft Close)',Problem_Type__c='How-To', AccountId = accounts[0].Id,Priority='P1',No_Of_Times_Case_Re_opened__c=3,Sub_Category__c='Segments',Status='Reopened',Category__c='Deliverability',Situation_Contact__c = contacts[0].id,recordTypeId='01250000000UJwx'));
        
        update caseToUpdateList2; 
        
        List<CSatSurveyFeedback__c> cSatSurveyFeedbackList = new List<CSatSurveyFeedback__c>();
        cSatSurveyFeedbackList.add(new CSatSurveyFeedback__c(Question_1__c='5',Account__c=accounts[0].Id,Contact__c=contacts[0].Id));
        cSatSurveyFeedbackList.add(new CSatSurveyFeedback__c(Question_1__c='2',Account__c=accounts[0].Id,Contact__c=contacts[0].Id));
        insert cSatSurveyFeedbackList;
        
        List<Entitlement> entitlementList = new List<Entitlement>();
        entitlementList.add(new Entitlement(Name='test',AccountId=accounts[0].Id,AssignedSupportPOC__c=usr.Id));
        
        insert entitlementList;
        
        List<Entitlement> entitlementListToUpdate = new List<Entitlement>();
        entitlementListToUpdate.add(new Entitlement(Id=entitlementList[0].Id,AssignedSupportPOC__c=usr1.Id,Support_Admin_Contact__c=contacts[0].Id));
        update entitlementListToUpdate;
        
        
        List<Authorized_Contact__c> authContactList = new List<Authorized_Contact__c>();
        authContactList.add(new Authorized_Contact__c(Entitlement__c=entitlementList[0].Id,Contact__c=contacts[0].Id));
        authContactList.add(new Authorized_Contact__c(Entitlement__c=entitlementList[0].Id,Contact__c=contacts[0].Id));
        insert authContactList;
        Test.stopTest();
        
        delete [SELECT Id FROM Activities__c LIMIT 1];
        
        
    }
    
    static testMethod void EWSActivityUsageCreater(){
        integer randomInt = (integer)(100.0 * Math.random());
        integer randomInt1 = (integer)(100.0 * Math.random());
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        User usr = new User(LastName = 'test'+randomInt,
                           FirstName='example',
                           Alias = 'jex'+randomInt,
                           Email = 'exampleGraztest@asdf.com',
                           Username = 'example'+randomInt+'.test@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert usr;
        
        User usr1 = new User(LastName = 'test'+randomInt1,
                           FirstName='example',
                           Alias = 'jex'+randomInt1,
                           Email = 'exampleGraztest@asdf.com',
                           Username = 'example'+randomInt1+'.test@asdf.com',
                           ProfileId = profileId.id,
                           TimeZoneSidKey = 'GMT',
                           LanguageLocaleKey = 'en_US',
                           EmailEncodingKey = 'UTF-8',
                           LocaleSidKey = 'en_US'
                           );
        insert usr1;
        
        Integer i = 0;
        try{i = Integer.valueOf(Label.Account_Renewal_Days);}catch(exception e){i=90;}
        Date todayDatePlusOne = Date.today().addDays(i);
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Unit Test Corp',Acct_Renewal_Date__c=todayDatePlusOne,CAM_Owner__c=usr1.Id,Temperature__c='Green'));
        accounts.add(new Account(Name = 'Unit Test Corp',Acct_Renewal_Date__c=todayDatePlusOne));
        insert accounts;
        
        List<Account> accToUpdate = new List<Account>();
        accToUpdate.add(new Account(Id=accounts[0].Id,CAM_Owner__c=usr.Id,Temperature__c='Yellow',Spam_Trap_Full_Detail__c='test spam'));
        update accToUpdate;
        
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = accounts[0].Id, FirstName = 'Tess', LastName = 'Dachshund'));
        insert contacts;
        
        List<Case> caseList = new List<Case>();
        caseList.add(new Case(ContactId = contacts[0].Id,subject='Feature Request',Escalated_to_SME__c=True, AccountId = accounts[0].Id,Priority='P2',Status='New',Problem_Type__c='Feature Request',Close_Reason__c='Resolved',Sub_Category__c='Scheduling',Category__c='Microsoft Dynamics', Situation_Contact__c = contacts[0].id));
       // caseList.add(new Case(ContactId = contacts[0].Id,subject='Feature Request',Escalated_to_SME__c=True, AccountId = accounts[0].Id,Priority='P2',Status='New',Problem_Type__c='Feature Request',Close_Reason__c='Resolved',Sub_Category__c='Scheduling',Category__c='Marketing Activities', Situation_Contact__c = contacts[0].id));
       // caseList.add(new Case(ContactId = contacts[0].Id,subject='Feature Request',Escalated_to_SME__c=True, AccountId = accounts[0].Id,Priority='P2',Status='New',Problem_Type__c='Feature Request',Close_Reason__c='Resolved',Sub_Category__c='Scheduling',Category__c='Marketing Activities', Situation_Contact__c = contacts[0].id));
       // caseList.add(new Case(ContactId = contacts[0].Id,subject='Feature Request',Escalated_to_SME__c=True, AccountId = accounts[0].Id,Priority='P2',Status='New',Problem_Type__c='Feature Request',Close_Reason__c='Resolved',Sub_Category__c='Scheduling',Category__c='Marketing Activities', Situation_Contact__c = contacts[0].id));
        insert caseList;
        
        List<JBCXM__UsageData__c> usageDataList = new List<JBCXM__UsageData__c>();
        usageDataList.add(new JBCXM__UsageData__c(sessioncount__c =50,Marketo_Users__c=500,JBCXM__Account__c=accounts[0].Id,leadcount__c=100,emailsentcount__c=20));
        usageDataList.add(new JBCXM__UsageData__c(sessioncount__c =50,Marketo_Users__c=500,JBCXM__Account__c=accounts[0].Id,leadcount__c=100,emailsentcount__c=20));
        usageDataList.add(new JBCXM__UsageData__c(sessioncount__c =50,Marketo_Users__c=500,JBCXM__Account__c=accounts[1].Id,leadcount__c=10,emailsentcount__c=20));
       // caseList.add(new Case(ContactId = contacts[0].Id,subject='Feature Request',Escalated_to_SME__c=True, AccountId = accounts[0].Id,Priority='P2',Status='New',Problem_Type__c='Feature Request',Close_Reason__c='Resolved',Sub_Category__c='Scheduling',Category__c='Marketing Activities', Situation_Contact__c = contacts[0].id));
       // caseList.add(new Case(ContactId = contacts[0].Id,subject='Feature Request',Escalated_to_SME__c=True, AccountId = accounts[0].Id,Priority='P2',Status='New',Problem_Type__c='Feature Request',Close_Reason__c='Resolved',Sub_Category__c='Scheduling',Category__c='Marketing Activities', Situation_Contact__c = contacts[0].id));
       // caseList.add(new Case(ContactId = contacts[0].Id,subject='Feature Request',Escalated_to_SME__c=True, AccountId = accounts[0].Id,Priority='P2',Status='New',Problem_Type__c='Feature Request',Close_Reason__c='Resolved',Sub_Category__c='Scheduling',Category__c='Marketing Activities', Situation_Contact__c = contacts[0].id));
        insert usageDataList;
        
        Test.setCreatedDate(caseList[0].Id, Date.today().addDays(-100));
      //  Test.setCreatedDate(caseList[1].Id, Date.today().addDays(-60));
      //  Test.setCreatedDate(caseList[2].Id, Date.today().addDays(-30));
      //  Test.setCreatedDate(caseList[3].Id, Date.today().addDays(-10));
        String sch = '0 0 23 * * ?';
        
        Activities__c ac = new Activities__c();
        ac.Account__c = accounts[0].Id;
        ac.Name = 'test';
       // ac.EWS_Point__c = ewsPointsList[0].Id;
     //   ac.Description__c = 'test des';
        insert ac;
        Test.setCreatedDate(ac.Id, Date.today().addDays(-250));
        
        EWSActivityScheduler sh1 = new EWSActivityScheduler();
        EWSActivityUsageCreaterScheduler sh2 = new EWSActivityUsageCreaterScheduler();
        System.schedule('Test Territory Check', sch, sh1);
        System.schedule('Test Usage', sch, sh2);
        Database.executeBatch(new EWSActivityUsageCreater()); 
        
    }
    public static testmethod void EWSDashboardControllerTestMethod(){
    
        Profile p =[SELECT ID FROM Profile Where Name='Standard User'];
        User u1 = new user(Alias = 'standt', Email='standard@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Tesing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='marketotestusers2@testorg.com');
        insert u1;
        
        User u2 = new user(Alias = 'andt', Email='standarser@tesrg.com', 
            EmailEncodingKey='UTF-8', LastName='Tesin', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='marketotestusers@testrg.com');
        insert u2;
        
        List<EWS_Point_Table__c> ewsPointsList = new List<EWS_Point_Table__c>();
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'P2 Case',Type__c= 'Support',Driver__c='Relationship',Sub_Driver__c= 'P2 Case'));       
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'P1 Condition',Type__c= 'Support',Driver__c='Product Experience',Sub_Driver__c= 'P1 Condition'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Positive NPS',Type__c= 'CSM',Driver__c='Direct Communication',Sub_Driver__c= 'Positive NPS'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Half-Yearly Review',Type__c= 'Product',Driver__c='Product Experience',Sub_Driver__c= 'Product SitMan'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'New CSM',Type__c= 'CSM',Driver__c='Relationship',Sub_Driver__c= 'New CSM'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Temperature Change',Type__c= 'CSM',Driver__c='Relationship',Sub_Driver__c= 'Temperature Change'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Renewal Soon',Type__c= 'CSM',Driver__c='Relationship',Sub_Driver__c= 'Renewal Soon'));   
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'New NSE',Type__c= 'Support',Driver__c='Relationship',Sub_Driver__c= 'New NSE')); 
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'New Admin',Type__c= 'CSM',Driver__c='Relationship',Sub_Driver__c= 'New Admin'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'New Authorized Contact',Type__c= 'CSM',Driver__c='Relationship',Sub_Driver__c= 'New Authorized Contact'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Blacklist',Type__c= 'Support',Driver__c='Product Experience',Sub_Driver__c= 'Blacklist'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'CSATs with entry of "Product"',Type__c= 'Product',Driver__c='Product Experience',Sub_Driver__c= 'Product SitMan'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Sitman with Entry "Product"',Type__c= 'Product',Driver__c='Product Experience',Sub_Driver__c= 'Product SitMan'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Case Closed "Reffered to Ideas"',Type__c= 'Product',Driver__c='Product Experience',Sub_Driver__c= 'Product Support Case'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Sitman Filled',Type__c= 'Support',Driver__c='Direct Communication',Sub_Driver__c= 'Sitman Filled'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Positive CSAT',Type__c= 'Support',Driver__c='Direct Communication',Sub_Driver__c= 'Positive CSAT'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Negative CSAT',Type__c= 'Support',Driver__c='Direct Communication',Sub_Driver__c= 'Negative CSAT'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Negative NPS',Type__c= 'CSM',Driver__c='Direct Communication',Sub_Driver__c= 'Negative NPS'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Escalated to SME',Type__c= 'Support',Driver__c='Case Handling',Sub_Driver__c= 'Escalated to SME'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Escalated to Engineering',Type__c= 'Support',Driver__c='Case Handling',Sub_Driver__c= 'Escalated to Engineering'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Excessive (2+) Reopens',Type__c= 'Support',Driver__c='Case Handling',Sub_Driver__c= 'Excessive Reopens'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Aging: 10 days',Type__c= 'Support',Driver__c='Time to Resolution',Sub_Driver__c= 'Aging: 10 days'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Aging: 30 days',Type__c= 'Support',Driver__c='Time to Resolution',Sub_Driver__c= 'Aging: 30 days'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Aging: 60 days',Type__c= 'Support',Driver__c='Time to Resolution',Sub_Driver__c= 'Aging: 60 days'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Aging: 100 days',Type__c= 'Support',Driver__c='Time to Resolution',Sub_Driver__c= 'Aging: 100 days'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Inactivity: Low Logins',Type__c= 'CSM',Driver__c='Usage',Sub_Driver__c= 'Inactivity: Logins'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Inactivity: Low Email sends',Type__c= 'CSM',Driver__c='Usage',Sub_Driver__c= 'Low Email Sends'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Case Opened: Volatile Subject',Type__c= 'CSM',Driver__c='Usage',Sub_Driver__c= 'Case Opened: Volatile Subject'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Mentor Session',Type__c= 'Support',Driver__c='Service Consumed',Sub_Driver__c= 'Mentor Session'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Half-Yearly Review',Type__c= 'Support',Driver__c='Service Consumed',Sub_Driver__c= 'Half-Yearly Review'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Renewed',Type__c= 'CSM',Driver__c='Service Consumed',Sub_Driver__c= 'Renewed'));
        insert ewsPointsList;
        
        Account acc = new Account();
        acc.Name ='Test Account';
        acc.Temperature__c = 'Red';
        Insert acc;
        
        Entitlement et = new Entitlement();
        et.Name = 'Test Entitlement';
        et.Type = 'Priemier';
        et.AssignedSupportPOC__c = u1.Id;
        et.AccountId = acc.Id;
        Insert et;
        
        Asset ast = new Asset();
        ast .Accounting_Renewal_Date__c = date.today();
        ast.Name = 'Test Asset';
        ast.AccountId = acc.Id;
        Insert ast ;
        
        EWS_Point_Table__c ew = new EWS_Point_Table__c();
        ew.Activate__c = true;
        ew.Driver__c = 'Relationship';
        ew.Points__c = 10;
        ew.Points__c = 0.12;
        ew.Type__c = 'Support';
        
        Activities__c act = new Activities__c();
        act.Type__c = 'Support';
        act.Account__c = acc.Id;
        insert act;
        
        Apexpages.currentPage().getParameters().put('Paramtervalue',acc.Id);
        
        EWSDashboardController ews = new EWSDashboardController();
        ews.accAction();
        EWSDashboardController.getScoreTypeData();
        EWSDashboardController.getRecentThreshold();
        EWSDashboardController.getSplitTeamData();
        EWSDashboardController.getSplitDriverData();
        EWSDashboardController.getScoreTrentsData();
        EWSDashboardController.getWeek26CategoryCases();
        EWSDashboardController.getJiraCases();
        EWSDashboardController.getWeekthreeCases();
        ews.closePopup();
        ews.showPopup();
        ews.closePopupEmail();
        ews.showPopupEmail();
        ews.getActivePoints();
        ews.selectedPoint = ewsPointsList[0].Id;
        ews.pointSelected();
        ews.insertActivity();
        ews.selectedPoint = 'None';
        ews.pointSelected();
        ews.insertActivity();
        ews.sendFeedBack();
        ews.breakDownKey = '';
        ews.report1 = '';
        ews.report2 = '';
        ews.report3 = '';
        ews.report4 = '';
        ews.report5 = '';
        ews.emailsentcount = 0;
        ews.sessioncount = 0;
        ews.changedatavaluecount = 0;
    } 
}