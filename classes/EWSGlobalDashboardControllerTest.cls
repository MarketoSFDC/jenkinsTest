/*********************************************************************
* Last Modified by   : Grazitti Support 
* Modified Date      : 28-April-18
* Purpose            : #01009688 Consolidate Support Engineer Fields on Entitlement
* Line numbers       : 87-90,95

**********************************************************************/
@isTest
private class EWSGlobalDashboardControllerTest{
    
    static testMethod void EWSGlobalDashboardController() {
        
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
        entitlementList.add(new Entitlement(Name='test',AccountId=accounts[0].Id,AssignedSupportPOC__c=usr.Id));
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
        
        EWS_Point_Table__c ewsPoints_Test = new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'P2 Case',Type__c= 'Support',Driver__c='Relationship',Sub_Driver__c= 'P2 Case');       
        insert ewsPoints_Test;
         
        Case cas_test = new Case(JIRA_Num__c='123456',ContactId = contacts[0].Id,subject='Feature',Close_Reason__c = 'Referred to Ideas',Problem_Type__c='Bug',Accept_Reject_Notes__c='test notes', AccountId = accounts[0].Id,Priority='P1',Sub_Category__c='Boomi',Status='Closed',Category__c='Other',Situation_Contact__c = contacts[0].id);
        cas_test.RecordTypeId = Label.SituationManagementSupportRecTypeId;
        insert cas_test;
        
        Activities__c act = new Activities__c();
        act.Type__c = 'Support';
        act.Account__c = accounts[0].Id;
        act.Case_Number__c = cas_test.Id;
        act.EWS_Point__c = ewsPoints_Test.Id; 
        insert act;
                
        list<EWSGlobalDashboardController.EWSGlobalDashboardData> dataList = new List<EWSGlobalDashboardController.EWSGlobalDashboardData>();
        EWSGlobalDashboardController.EWSGlobalDashboardData ew = new EWSGlobalDashboardController.EWSGlobalDashboardData();
        ew.theMaxAccCount = 10;
        ew.actionOwner = 'Test';
        ew.actionOwnerId = 'TestId';
        ew.actionItemCaseId = 'TestId';
        ew.actionItemCaseNumber = 'test num';
        ew.theaccId = 'Test Id';
        ew.theaccName = 'Test Name';
        ew.theArr = 0.5;
        ew.theMaxTypeScore = 10;
        ew.theTotalScore = 100;
        ew.theTotalScoreColor = 'Red';
        ew.outReachValue = 'Test';
        ew.theType = 'Testing';
        ew.theTypeScore = 15;
        dataList.add(ew);
        EWSGlobalDashboardController ews = new EWSGlobalDashboardController();

   
    }
    
 
 
}