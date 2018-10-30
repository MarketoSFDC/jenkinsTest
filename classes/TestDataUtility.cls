/**
* (c) 2018 Appirio, Inc
* 
* 
* Description : An apex class used to create Dummy Data for Test classes.
* Created By : Sumit Dayama
* Created Date : Feb 20th 2018
* CHANGE LOG
 * DEVELOPER NAME             CHANGE DESCRIPTION                      MODIFY DATE
 * ------------------------------------------------------------------------------
 * Appirio               Created class                           2018/02/21
 * Appirio               Updated class                           2018/03/30
* --------------------------------------------------------------------------------------
**/
public with sharing class TestDataUtility {

    //Create Development Plan Task
    public static lmsilt__Development_Plan_Task__c createDevPlanTask(Boolean isInsert) {
        Id RecordTypeIdDevPlan = Schema.SObjectType.lmsilt__Development_Plan_Task__c.getRecordTypeInfosByName().get('Accreditation').getRecordTypeId();
        lmsilt__Development_Plan_Task__c devplan = new lmsilt__Development_Plan_Task__c();
        devplan.Name = 'Dev Plan';
        devplan.recordtypeid = RecordTypeIdDevPlan; 
        devplan.lmsilt__Task_Manager__c = 'Self';
        devplan.lmsilt__Description__c = 'Description';
        devplan.lmsilt__URL__c = 'https://marketo--lms2018--c.cs68.visual.force.com/apex/Custom_Attachment';
        if(isInsert){    
            insert devplan;
        }
        return devplan;
    }
    //Create Accreditation Approval
    public static Accreditation_Approval__c createAccApp( Boolean isInsert) {
        Accreditation_Approval__c accApp = new Accreditation_Approval__c();
        accApp.Name = 'Test Approval';
        accApp.File_Title__c = 'Test';
        accApp.Status__c = 'Pass';
        if(isInsert){    
            insert accApp;
        }
        return accApp;
    }
    //Create User 
    public static User createUser(User u, Boolean isInsert) {
        List<Profile> profiles = [Select Id From Profile where Name = 'System Administrator'];
        if(u == null) {
            u = new User();
        }
        //u.ContactId =con.Id;
        u.Email = 'foobar@example.test.nkc.co.jp';
        u.CommunityNickname = 'foobar@example.test.com';
        u.UserName = 'foobar@example.test.com';
        u.FirstName = 'Foo';
        u.lmscons__CFS_Status__c = 'Not CFS user';
        u.LastName = 'Bar';
        u.Alias = 'foo';
        u.ProfileId = profiles.get(0).Id; 
        if(String.isEmpty(u.EmailEncodingKey)) {
            u.EmailEncodingKey = 'UTF-8';
        }
        if(String.isEmpty(u.LanguageLocaleKey)){
            u.LanguageLocaleKey = 'ja';
        }
        if(String.isEmpty(u.LocaleSidKey)){
            u.LocaleSidKey = 'en_US';
        }
        if(String.isEmpty(u.TimeZoneSidKey)){
            u.TimeZoneSidKey = 'Asia/Tokyo';
        }
        if(isInsert) {
            insert u;
        }
        
        return u;
    }
    
    public static List<Dynamic_Assignment_Solution__c> createDynamicAssignmentSolution(Integer i)
    {
        List<Dynamic_Assignment_Solution__c> das= new List<Dynamic_Assignment_Solution__c>();
        for(Integer j=0; j<i; j++){
        Dynamic_Assignment_Solution__c das1=new Dynamic_Assignment_Solution__c(Name='DynamicAssignmentSolutionTest',Office_Location__c='UK',Role_Group__c='IT',Role_Level__c='Manager',User_Type__c='Employee',Assignment_Type__c='New Hire');
        das.add(das1);
        }
        return das;
    }
    
    Public static List<Id> createLearningObjects()
    {
    List<Id> listToReturn =New List<Id>();
    lmscons__Training_Path__c course=new lmscons__Training_Path__c(Name='tempCourse');
    Database.insert(course);
    listToReturn.add(course.Id);
    lmscons__Training_Content__c Module=New lmscons__Training_Content__c();
    Module.lmscons__Enable_Certificate__c=true;
    Database.Insert(Module);
    lmscons__Training_Path_Item__c courseItem=new lmscons__Training_Path_Item__c(lmscons__Training_Path__c=course.Id, lmscons__Training_Content__c=Module.Id);
    Database.insert(courseItem);
    listToReturn.add(Module.Id);
    lmscons__Learning_Path__c learningPath=new lmscons__Learning_Path__c(Name='tempName');
    Database.insert(learningPath);
    lmscons__Training_Content__c Module2=New lmscons__Training_Content__c();
    Module.lmscons__Enable_Certificate__c=true;
    Database.Insert(Module2);
    lmscons__Learning_Path_Item__c learningPathItem=new lmscons__Learning_Path_Item__c(lmscons__Learning_Path__c=learningPath.Id, lmscons__Module__c=Module2.Id);
    Database.Insert(learningPathItem);
    listToReturn.add(learningPath.Id);
    lmsilt__Development_Plan__c tempDevPlan=New lmsilt__Development_Plan__c(Name='tempDevPlan');
    Database.insert(tempDevPlan);
    listToReturn.add(tempDevPlan.Id);
    lmsilt__Event__c tempEvent=New lmsilt__Event__c(Name='Temp Event');
    Database.insert(tempEvent);
    listToReturn.add(tempEvent.Id);
    lmsilt__Class__c tempClass=New lmsilt__Class__c(Name='test class Class', lmsilt__Event__c=tempEvent.Id);
    Database.insert(tempClass);
    listToReturn.add(tempClass.Id);
    lmscons__Curriculum__c tempCurriculum=New lmscons__Curriculum__c(Name='test class curriculum');
    Database.insert(tempCurriculum);
    lmscons__Curriculum_Item__c tempCurriculumItem=New lmscons__Curriculum_Item__c(lmscons__Curriculum__c=tempCurriculum.Id);
    Database.insert(tempCurriculumItem);
    listToReturn.add(tempCurriculum.Id);
    lmscons__Quiz__c tempquiz=New lmscons__Quiz__c(Name='test class quiz');
    Database.insert(tempquiz);
    listToReturn.add(tempquiz.Id);
    return listToReturn;
    }
    
    
    
    
}