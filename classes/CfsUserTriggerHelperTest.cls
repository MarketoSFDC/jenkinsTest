/**
* (c) 2018 Appirio, Inc
* 
* 
* Description : An Apex Test Class for CfsUserTriggerHelper.
* Created By : Sumit Dayama
* Created Date : March 20th 2018
* CHANGE LOG
* DEVELOPER NAME             CHANGE DESCRIPTION                      MODIFY DATE
* ------------------------------------------------------------------------------
* Appirio               Created class                           2018/03/20
* Appirio               Updated class                           2018/03/30
* Cassandrea Steiner - Added testmethod1 and testmethod2, 2018/8/15
* --------------------------------------------------------------------------------------
**/
@isTest 
private class CfsUserTriggerHelperTest {
    @testSetup 
    static void startsetup() {
        //create test users
        UserRole portalRole = [Select Id From UserRole Where PortalType='None' Limit 1];
        Profile profile = [Select Id from Profile where name='System Administrator'];
        User testUser1 = new User( UserRoleId=portalRole.Id, 
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
                                  Office_Location__c='	United States - Denver');
        Database.insert(testUser1);
        testUser1.Office_Location__c='UK';
        update testUser1;
        User testUser2 = new User( UserRoleId=portalRole.Id, 
                                  ProfileId=profile.Id, 
                                  Username=System.now().millisecond()+'robin@test.com', 
                                  Alias='robin1', Email=System.now().millisecond()+'dick.grayson@wayneenterprises.com', 
                                  EmailEncodingKey='UTF-8', 
                                  Firstname='Dick', 
                                  Lastname='Grayson', 
                                  LanguageLocaleKey='en_US', 
                                  LocaleSidKey='en_US', 
                                  TimeZoneSidKey='America/Chicago',
                                  Is_Employee__c=true,
                                  Role_Change_Date__c=System.today(),
                                  Start_Date__c=System.today(),
                                  Role_Group__c='IT',
                                  Role_Level__c='Individual Contributor',
                                  Office_Location__c='	United States - Denver');
        Database.insert(testUser2);
        
        
        //insert training content and dynamic assignment records
        System.runAs(testUser1){
            lmscons__Training_Path__c course=new lmscons__Training_Path__c(Name='tempCourse');
            Database.insert(course);
            
            lmscons__Training_Content__c Module=New lmscons__Training_Content__c();
            Module.lmscons__Enable_Certificate__c=true;
            Database.Insert(Module);
            lmscons__Training_Path_Item__c courseItem=new lmscons__Training_Path_Item__c(lmscons__Training_Path__c=course.Id, lmscons__Training_Content__c=Module.Id);
            Database.insert(courseItem);
            
            Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Dynamic_Assignment_Solution__c;
            Map<String,Schema.RecordTypeInfo> DynAssignRecordTypeInfo= cfrSchema.getRecordTypeInfosByName(); 
            Id rtId = DynAssignRecordTypeInfo.get('Course').getRecordTypeId();
            
            Dynamic_Assignment_Solution__c das=new Dynamic_Assignment_Solution__c(Name='DynamicAssignmentSolutionTest',Office_Location__c='UK',Role_Group__c='IT',
                                                                                  Role_Level__c='Manager',
                                                                                  User_Type__c='Employee',
                                                                                  Assignment_Type__c='New Hire',
                                                                                  recordTypeId=rtId,
                                                                                  Course__c=course.Id);
            Database.insert(das);
            rtId = DynAssignRecordTypeInfo.get('Modules').getRecordTypeId();
            Dynamic_Assignment_Solution__c das2=new Dynamic_Assignment_Solution__c(Name='DynamicAssignmentSolutionTest2',Office_Location__c='UK',Role_Group__c='IT',
                                                                                   Role_Level__c='Manager',
                                                                                   User_Type__c='Employee',
                                                                                   Assignment_Type__c='New Hire',
                                                                                   recordTypeId=rtId,
                                                                                   Module__c=Module.Id);
            Database.insert(das2);
            
            lmscons__Learning_Path__c learningPath=new lmscons__Learning_Path__c(Name='tempName');
            Database.insert(learningPath);
            lmscons__Training_Content__c Module2=New lmscons__Training_Content__c();
            Module.lmscons__Enable_Certificate__c=true;
            Database.Insert(Module2);
            lmscons__Learning_Path_Item__c learningPathItem=new lmscons__Learning_Path_Item__c(lmscons__Learning_Path__c=learningPath.Id, lmscons__Module__c=Module2.Id);
            Database.Insert(learningPathItem);
            rtId = DynAssignRecordTypeInfo.get('Learning Path').getRecordTypeId();
            Dynamic_Assignment_Solution__c das3=new Dynamic_Assignment_Solution__c(Name='DynamicAssignmentSolutionTest3',Office_Location__c='UK',Role_Group__c='IT',
                                                                                   Role_Level__c='Manager',
                                                                                   User_Type__c='Employee',
                                                                                   Assignment_Type__c='New Hire',
                                                                                   recordTypeId=rtId,
                                                                                   Learning_Path__c=learningPath.Id);
            Database.insert(das3);
            
            lmsilt__Development_Plan__c tempDevPlan=New lmsilt__Development_Plan__c(Name='tempDevPlan');
            Database.insert(tempDevPlan);
            lmsilt__Event__c tempEvent=New lmsilt__Event__c(Name='Temp Event');
            Database.insert(tempEvent);
            lmsilt__Class__c tempClass=New lmsilt__Class__c(Name='test class Class', lmsilt__Event__c=tempEvent.Id);
            Database.insert(tempClass);
            lmscons__Curriculum__c tempCurriculum=New lmscons__Curriculum__c(Name='test class curriculum');
            Database.insert(tempCurriculum);
            lmscons__Curriculum_Item__c tempCurriculumItem=New lmscons__Curriculum_Item__c(lmscons__Curriculum__c=tempCurriculum.Id);
            Database.insert(tempCurriculumItem);
            
            rtId = DynAssignRecordTypeInfo.get('Development Plans').getRecordTypeId();
            Dynamic_Assignment_Solution__c das4=new Dynamic_Assignment_Solution__c(Name='DynamicAssignmentSolutionTest4',Office_Location__c='UK',Role_Group__c='IT',
                                                                                   Role_Level__c='Manager',
                                                                                   User_Type__c='Employee',
                                                                                   Assignment_Type__c='New Hire',
                                                                                   recordTypeId=rtId,
                                                                                   Development_Plan__c=tempDevPlan.Id);         
            Database.insert(das4);
            
            rtId = DynAssignRecordTypeInfo.get('Events').getRecordTypeId();
            Dynamic_Assignment_Solution__c das5=new Dynamic_Assignment_Solution__c(Name='DynamicAssignmentSolutionTest5',Office_Location__c='UK',Role_Group__c='IT',
                                                                                   Role_Level__c='Manager',
                                                                                   User_Type__c='Employee',
                                                                                   Assignment_Type__c='New Hire',
                                                                                   recordTypeId=rtId,
                                                                                   Event__c=tempEvent.Id);          
            Database.insert(das5);
            
            rtId = DynAssignRecordTypeInfo.get('Class').getRecordTypeId();
            Dynamic_Assignment_Solution__c das6=new Dynamic_Assignment_Solution__c(Name='DynamicAssignmentSolutionTest6',Office_Location__c='UK',Role_Group__c='IT',
                                                                                   Role_Level__c='Manager',
                                                                                   User_Type__c='Employee',
                                                                                   Assignment_Type__c='New Hire',
                                                                                   recordTypeId=rtId,
                                                                                   Class__c=tempClass.Id);          
            Database.insert(das6);
            
            rtId = DynAssignRecordTypeInfo.get('Curriculum').getRecordTypeId();
            Dynamic_Assignment_Solution__c das7=new Dynamic_Assignment_Solution__c(Name='DynamicAssignmentSolutionTest7',Office_Location__c='UK',Role_Group__c='IT',
                                                                                   Role_Level__c='Manager',
                                                                                   User_Type__c='Employee',
                                                                                   Assignment_Type__c='New Hire',
                                                                                   recordTypeId=rtId,
                                                                                   Curriculum__c=tempCurriculum.Id);            
            Database.insert(das7);
            
            lmscons__Quiz__c tempquiz=New lmscons__Quiz__c(Name='test class quiz');
            Database.insert(tempquiz);
            
            rtId = DynAssignRecordTypeInfo.get('Quizzes').getRecordTypeId();
            Dynamic_Assignment_Solution__c das8=new Dynamic_Assignment_Solution__c(Name='DynamicAssignmentSolutionTest8',Office_Location__c='UK',Role_Group__c='IT',
                                                                                   Role_Level__c='Manager',
                                                                                   User_Type__c='Employee',
                                                                                   Assignment_Type__c='New Hire',
                                                                                   recordTypeId=rtId,
                                                                                   Quizzes__c=tempquiz.Id);         
            Database.insert(das8);    
        }          
    }
    
    //Added for APPS-20622 & APPS-20624
    //This tests that the isManager checkbox is checked when a user is assigned as a manager of another user
    @isTest 
    static void testmethod1() {
        //Update existing test user
        User testUpdateUser = [SELECT Id, ManagerID FROM User WHERE Alias='robin1' LIMIT 1];
        User testManager = [SELECT Id, Is_Manager__c from User WHERE Alias='batman1' LIMIT 1];
        testUpdateUser.ManagerID = testManager.Id;
        //Create new user
        Profile profile = [Select Id from Profile where name='System Administrator'];
        User testNewUser = new User(ProfileId=profile.Id, 
                                    Username=System.now().millisecond()+'robin2@test.com', 
                                    Alias='robin2', Email=System.now().millisecond()+'dick.grayson@wayneenterprises.com', 
                                    EmailEncodingKey='UTF-8', 
                                    Firstname='Dick', 
                                    Lastname='Grayson', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Chicago',
                                    Is_Employee__c=true);
		testNewUser.ManagerID = testUpdateUser.Id;
        
        Test.startTest();
        Database.update(testUpdateUser);
        Database.insert(testNewUser);
        Test.stopTest();
        
        testUpdateUser = [SELECT Id, Is_Manager__c FROM User WHERE Alias='robin1' LIMIT 1];
        testManager = [SELECT Id, Is_Manager__c from User WHERE Alias='batman1' LIMIT 1];
        System.assert(testManager.Is_Manager__c);
        System.assert(testUpdateUser.Is_Manager__c);
    }
        //This tests that a new user and their manager get assigned to the CFS permission sets and groups
    @isTest 
    static void testmethod2() {
        //Get an existing test user to use as a manager
        User testUpdateUser = [SELECT Id FROM User WHERE Alias='robin1' LIMIT 1];
        //Create a new user
        Profile profile = [Select Id from Profile where name='System Administrator'];
        User testNewUser = new User(ProfileId=profile.Id, 
                                    Username=System.now().millisecond()+'robin2@test.com', 
                                    Alias='robin2', Email=System.now().millisecond()+'dick.grayson@wayneenterprises.com', 
                                    EmailEncodingKey='UTF-8', 
                                    Firstname='Dick', 
                                    Lastname='Grayson', 
                                    LanguageLocaleKey='en_US', 
                                    LocaleSidKey='en_US', 
                                    TimeZoneSidKey='America/Chicago',
                                    Is_Employee__c=true);
		testNewUser.ManagerID = testUpdateUser.Id;
        
        //insert new user
        Test.startTest();
        Database.insert(testNewUser);
        Test.stopTest();

        //establish Permission Set and Group variables
        testNewUser = [SELECT Id FROM User WHERE Alias='robin2' LIMIT 1];
        PermissionSet psUser = [SELECT Id FROM PermissionSet WHERE Label = 'CFS Consumer User' LIMIT 1];
        PermissionSet psManager = [SELECT Id FROM PermissionSet WHERE Label = 'CFS Consumer Manager' LIMIT 1];
        Group pgEmployees = [SELECT Id FROM Group WHERE Name = 'CFS_All_Employees' AND Type = 'Regular' LIMIT 1];
        Group pgManagers = [SELECT Id FROM Group WHERE Name = 'CFS_All_Managers' AND Type = 'Regular' LIMIT 1];
        PermissionSetAssignment psUserAssignment = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId = :psUser.id AND AssigneeId = :testNewUser.id LIMIT 1];
        PermissionSetAssignment psManagerAssignment = [SELECT Id FROM PermissionSetAssignment WHERE PermissionSetId = :psManager.id AND AssigneeId = :testUpdateUser.id LIMIT 1];
        GroupMember pgEmployeesAssignment = [SELECT Id FROM GroupMember WHERE GroupId = :pgEmployees.id AND UserOrGroupId = :testNewUser.id LIMIT 1];
        GroupMember pgManagersAssignment = [SELECT Id FROM GroupMember WHERE GroupId = :pgManagers.id AND UserOrGroupId = :testUpdateUser.id LIMIT 1];

        //Confirm permission set and group assignments exist
        System.assertNotEquals(null, psUserAssignment);
        System.assertNotEquals(null, psManagerAssignment);
        System.assertNotEquals(null, pgEmployeesAssignment);
        System.assertNotEquals(null, pgManagersAssignment);
    }
}