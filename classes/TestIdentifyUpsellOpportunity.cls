@isTest
public class TestIdentifyUpsellOpportunity{
    
    /*****Code for unit testing ---started*****/
    public static testMethod void testTrigger() {
    Profile p = [select id from profile where name='System Administrator'];
    User user = new User(alias = 'test123', email='test123@noemail.com',
            emailencodingkey='UTF-8', lastname='Testing', languagelocalekey='en_US',
            localesidkey='en_US', profileid = p.Id, country='United States',IsActive =true,
            timezonesidkey='America/Los_Angeles', username='grazittitest@noemail.com');
    insert user;
    Account ac = new Account(
                       Name ='AccTestSMB-2',
                       Business_Unit__c = 'AMER-SB'
                     );
    insert ac;
    Task task = new Task(
                    Subject = 'Call',
                    OwnerId = user.Id,
                    Priority = 'Low',
                    Status = 'Completed',
                    Type = 'CSM - Upsell/Cross sell Services'
                );
    insert task;
    task.WhatId = ac.Id;
    task.type = 'CSM – Upsell/Cross sell Product';
    update task;
    }
}