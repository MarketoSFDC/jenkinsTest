// test class form EWS module
@isTest
public class GenerateCalendlyTest{
    public static String fakeRes = '{"data":[{"type":"event_types","id":"GDHEJCLOFQHY6UOE","attributes":{"name":"MS: 60 Minute Meeting","description":null,"color":"#ffddb9","duration":60,"created_at":"2017-07-27T10:30:31Z","updated_at":"2017-07-27T10:30:31Z","slug":"60min-1","active":true,"location":null,"url":"https://calendly.com/jatinn/60min-1"}}]}';
    static testMethod void GenerateCalendly(){
        Profile profileId = [SELECT Id FROM Profile WHERE Name = 'System Administrator' LIMIT 1];
        Integer randomInt1 = (integer)(100.0 * Math.random());
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
        
        Date todayDatePlusOne = Date.today().addDays(1);
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Unit Test Corp',Acct_Renewal_Date__c=todayDatePlusOne,CAM_Owner__c=usr1.Id,Temperature__c='Green'));
        accounts.add(new Account(Name = 'Unit Test Corp',Acct_Renewal_Date__c=todayDatePlusOne));
        insert accounts;
        
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = accounts[0].Id, FirstName = 'Tess', LastName = 'Dachshund',Email='test@ttest.com'));
        insert contacts;
        
        List<Case> caseList = new List<Case>();
        caseList.add(new Case(ContactId = contacts[0].Id,subject='Feature Request',Escalated_to_SME__c=True, AccountId = accounts[0].Id,Priority='P2',Status='New',Problem_Type__c='Feature Request',Close_Reason__c='Resolved',Sub_Category__c='Scheduling',Category__c='Marketing Activities', Situation_Contact__c = contacts[0].id));
        caseList.add(new Case(ContactId = contacts[0].Id,subject='Feature Request',Escalated_to_SME__c=True, AccountId = accounts[0].Id,Priority='P2',Status='New',Problem_Type__c='Feature Request',Close_Reason__c='Resolved',Sub_Category__c='Scheduling',Category__c='Marketing Activities', Situation_Contact__c = contacts[0].id,recordTypeId='01250000000UK1E',Situation_Account__c= accounts[1].Id));
        caseList.add(new Case(ContactId = contacts[0].Id,subject='Feature Request',JIRA_Num__c='123456',Escalated_to_SME__c=True, AccountId = accounts[0].Id,Priority='P2',Status='New',Problem_Type__c='Feature Request',Close_Reason__c='Resolved',Sub_Category__c='Scheduling',Category__c='Marketing Activities', Situation_Contact__c = contacts[0].id,recordTypeId='01250000000UJwx'));  
        caseList.add(new Case(ContactId = contacts[0].Id,subject='Feature', AccountId = accounts[0].Id,Priority='P1',Status='New',Sub_Category__c='Scheduling',Category__c='Marketing Activities', Situation_Contact__c = contacts[0].id,recordTypeId='01250000000UJwx'));  
        caseList.add(new Case(ContactId = contacts[0].Id,subject='Feature', AccountId = accounts[0].Id,Priority='P2',Status='New',Sub_Category__c='Scheduling',Category__c='Marketing Activities', Situation_Contact__c = contacts[0].id,recordTypeId='01250000000UJwx'));
        caseList.add(new Case(ContactId = contacts[0].Id,AccountId = accounts[0].Id,Priority='P1',Status='New',Problem_Type__c='Feature Request',Close_Reason__c='Resolved',Sub_Category__c='Scheduling',Category__c='Marketing Activities',Situation_Contact__c = contacts[0].id,recordTypeId='01250000000UJwx'));  
        insert caseList;
        
        List<Event> eventList = new List<Event>();
        Event ev5 = new Event(OwnerID = usr1.Id, Subject = 'wawesome stuff: MS: EEEEEEEEEE - Calendly - BBFGYJJ643ZGSXJE', StartDateTime = Date.Today(),EndDateTime= Date.Today(),WhatID= caseList[4].id);
        Event ev6 = new Event(whoId=contacts[0].id,OwnerID = usr1.Id, Subject = 'wawesome stuff: MS: EEEEEEEEEE - Calendly - BBFGYJJ643ZGSXJE', StartDateTime = Date.Today(),EndDateTime= Date.Today(),WhatID=null);
        eventList.add(ev5);
        eventList.add(ev6);
        insert eventList;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(caseList[0]);
        GenerateCalendlyController f = new GenerateCalendlyController(controller);
        PageReference pgRef = Page.GenerateCalendly;
        Test.setCurrentPageReference(pgRef);
        f.selectedEventType = '15min'; 
        f.c = Database.query('select id,'+String.join(Label.CalendlyUrlParameters.split(','), ',')+' FROM Case WHERE Id=\''+caseList[0].Id+'\'');
        
             
        f.getEvents();
        f.sendInvite();
        
        CalendlyDynamicMentorSession session = new CalendlyDynamicMentorSession();
        session.caseId = caseList[0].Id;
        //session.contactEmail = 'test@ttest.com';
        //session.firstNamee = 'test';
        //session.lastNamee = 'lastt';
        String x = session.getmentorUrl();
    }
    
}