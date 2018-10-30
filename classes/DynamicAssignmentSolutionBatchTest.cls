/**
* (c) 2018 Appirio, Inc
* 
* 
* Description : An apex test class for DynamicAssignmentSolutionBatch.
* Created By : Ishan Chawla
* Created Date : March 27th 2018
* CHANGE LOG
* DEVELOPER NAME             CHANGE DESCRIPTION                      MODIFY DATE
* ------------------------------------------------------------------------------
* Appirio               Created class                           2018/03/27
* Appirio               Updated class                           2018/03/30
* --------------------------------------------------------------------------------------
**/
@isTest 
private class DynamicAssignmentSolutionBatchTest {
    @testSetup 
    static void startsetup() {
        UserRole portalRole=[Select Id From UserRole Where PortalType='None' Limit 1];
        Profile profile=[Select Id from Profile where name='System Administrator'];
        User portalAccountOwner1=new User( UserRoleId=portalRole.Id, 
                                          ProfileId=profile.Id, 
                                          Username=System.now().millisecond()+'batman@test.com', 
                                          Alias='batman1', Email=System.now().millisecond()+'bruce.wayne@wayneenterprises.com', 
                                          EmailEncodingKey='UTF-8', 
                                          Firstname='Bruce', 
                                          Lastname='Wayne', 
                                          LanguageLocaleKey='en_US', 
                                          LocaleSidKey='en_US', 
                                          TimeZoneSidKey='America/Chicago',
                                          Is_Employee__c=true,
                                          Role_Change_Date__c=System.today(),
                                          Start_Date__c=System.today(),
                                          Role_Group__c='IT',
                                          Role_Level__c='Manager',
                                          Office_Location__c='United States - Denver',
            							  lmscons__CFS_Status__c = 'Active');
        Database.insert(portalAccountOwner1);
        System.runAs ( portalAccountOwner1)        
        {
            List<Id> learningObjId=TestDataUtility.createLearningObjects(); 
            List<Dynamic_Assignment_Solution__c> das = TestDataUtility.createDynamicAssignmentSolution(8);
            das.get(0).Course__c=learningObjId.get(0);
            das.get(1).Module__c=learningObjId.get(1);
            das.get(2).Learning_Path__c=learningObjId.get(2);
            das.get(3).Development_Plan__c=learningObjId.get(3);
            das.get(4).Event__c=learningObjId.get(4);
            das.get(5).Class__c=learningObjId.get(5);
            das.get(6).Curriculum__c=learningObjId.get(6);
            das.get(7).Quizzes__c=learningObjId.get(7);
            Database.insert(das);
            das.get(7).Assignment_Type__c='New Hire';
            Update das;
        }
        portalAccountOwner1.Office_Location__c='UK';
        update portalAccountOwner1;
    }
    
    @isTest 
    static void testmethod1() {}
    
}