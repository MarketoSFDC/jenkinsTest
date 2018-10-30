//
// (c) 2014 Appirio, Inc.
//
// Test class for LMSCertificate
//
// Dec 12th, 2014   Rahul Mittal    Original(T-339605)
//CHANGE LOG
// DEVELOPER NAME             CHANGE DESCRIPTION                      MODIFY DATE
// ------------------------------------------------------------------------------
// Appirio               Created class                           2018/03/07
// Appirio               Updated class                           2018/03/30
//
@isTest
private class Test_LMSCertificate {
  //Method to test with lmscons__Training_Path_Assignment_Progress object
  static testMethod void testLMSCertificateWithProgress() {
    User testUser = createUser(true);
    system.runAs(testUser) {
      //Create test records
      lmscons__Training_Path__c  testCourse = new lmscons__Training_Path__c();
      testCourse.Name = 'test Record';
      testCourse.lmscons__Enable_Certificate__c = true;
      insert testCourse;

      lmscons__Transcript__c testTranscript = new lmscons__Transcript__c ();
      testTranscript.lmscons__Trainee__c = testUser.Id;
      testTranscript.lmscons__Trainee_User_Profile__c = 'Appirio Employee';
      insert testTranscript;

      lmscons__Training_Path_Assignment_Progress__c testLmscons = new lmscons__Training_Path_Assignment_Progress__c();
      testLmscons.lmscons__Transcript__c = testTranscript.Id;
      testLmscons.lmscons__Training_Path__c = testCourse.Id;
      testLmscons.lmscons__StatusPicklist__c = 'Completed';
      testLmscons.lmscons__Completion_Date__c = Date.today();
      insert testLmscons;

      Test.startTest();
        PageReference pageRef = Page.MarketoCert;
            Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testLmscons.Id);
        LMSCertificate controller = new LMSCertificate();
        system.assert(controller.UserName != null);
      Test.stopTest();
    }
  }

  //Method to test with lmscons__Transcript_Line object
  static testMethod void testLMSCertificateWithLine() {
    User testUser = createUser(true);
    system.runAs(testUser) {
      //Create test records
      lmscons__Training_Path__c  testCourse = new lmscons__Training_Path__c();
      testCourse.Name = 'test Record';
      testCourse.lmscons__Enable_Certificate__c = true;
      insert testCourse;

      lmscons__Transcript__c testTranscript = new lmscons__Transcript__c ();
      testTranscript.lmscons__Trainee__c = testUser.Id;
      testTranscript.lmscons__Trainee_User_Profile__c = 'Appirio Employee';
      insert testTranscript;

      lmscons__Training_Content__c testContent = new lmscons__Training_Content__c();
      testContent.lmscons__Enable_Certificate__c = true;
      testContent.lmscons__Module_Type__c = 'Module';
      insert testContent;

      lmscons__Training_Content_License__c testConLicense = new lmscons__Training_Content_License__c();
      testConLicense.lmscons__Training_Content__c = testContent.Id;
      testConLicense.lmscons__License_Period__c = 'Indefinite';
      insert testConLicense;

      lmscons__Training_User_License__c testUserLicense = new lmscons__Training_User_License__c();
      testUserLicense.lmscons__Content_License__c = testConLicense.Id;
      insert testUserLicense;

      lmscons__Transcript_Line__c testLine = new lmscons__Transcript_Line__c();
      testLine.lmscons__Status__c = 'In Progress';
      testLine.lmscons__Percent_Complete__c = 100.00;
      testLine.lmscons__Completion_Date__c = Date.today();
      testLine.lmscons__Training_User_License__c = testUserLicense.Id;
      testLine.lmscons__Transcript__c = testTranscript.Id;
      insert testLine;

      Test.startTest();
        PageReference pageRef = Page.MarketoCert;
            Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testLine.Id);
        LMSCertificate controller = new LMSCertificate();
        system.assert(controller.UserName != null);
      Test.stopTest();
    }
  }

  //Method to test with lmscons__Curriculum_Assignment object
  static testMethod void testLMSCertificateWithAssignment() {
    User testUser = createUser(true);
    system.runAs(testUser) {
      //Create test records
      lmscons__Training_Path__c  testCourse = new lmscons__Training_Path__c();
      testCourse.Name = 'test Record';
      testCourse.lmscons__Enable_Certificate__c = true;
      insert testCourse;

      lmscons__Curriculum__c testCurriculum = new lmscons__Curriculum__c ();
      testCurriculum.lmscons__Enable_Certificate__c = true;
      insert testCurriculum;

      lmscons__Transcript__c testTranscript = new lmscons__Transcript__c ();
      testTranscript.lmscons__Trainee__c = testUser.Id;
      testTranscript.lmscons__Trainee_User_Profile__c = 'Appirio Employee';
      insert testTranscript;

      lmscons__Curriculum_Assignment__c testAssignment = new lmscons__Curriculum_Assignment__c();
      testAssignment.lmscons__Transcript__c = testTranscript.Id;
      testAssignment.lmscons__Curriculum__c = testCurriculum.Id;
      testAssignment.lmscons__Status__c = 'Completed';
      testAssignment.lmscons__Completion_Date__c = Date.today();
      insert testAssignment;

      Test.startTest();
        PageReference pageRef = Page.MarketoCert;
            Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testAssignment.Id);
        LMSCertificate controller = new LMSCertificate();
        system.assert(controller.UserName != null);
      Test.stopTest();
    }
  }

  //Method to test with lmscons__Learning_Path_Assignment object
  static testMethod void testLMSCertificateWithPath() {
    User testUser = createUser(true);
    system.runAs(testUser) {
      //Create test records
      lmscons__Training_Path__c  testCourse = new lmscons__Training_Path__c();
      testCourse.Name = 'test Record';
      testCourse.lmscons__Enable_Certificate__c = true;
      insert testCourse;

      lmscons__Learning_Path__c testLearningPath = new lmscons__Learning_Path__c ();
      testLearningPath.Name = 'test';
      testLearningPath.lmscons__Enable_Certificate__c = true;
      insert testLearningPath;

      lmscons__Transcript__c testTranscript = new lmscons__Transcript__c ();
      testTranscript.lmscons__Trainee__c = testUser.Id;
      testTranscript.lmscons__Trainee_User_Profile__c = 'Appirio Employee';
      insert testTranscript;

      lmscons__Learning_Path_Assignment__c testPath = new lmscons__Learning_Path_Assignment__c();
      testPath.lmscons__Transcript__c = testTranscript.Id;
      testPath.lmscons__Learning_Path__c = testLearningPath.Id;
      testPath.lmscons__Status__c = 'Completed';
      testPath.lmscons__Completion_Date__c = Date.today();
      insert testPath;

      Test.startTest();
        PageReference pageRef = Page.MarketoCert;
            Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('id', testPath.Id);
        LMSCertificate controller = new LMSCertificate();
        String CompletionDate = controller.CompletionDate;
        DateTime ExpiryDate = controller.ExpiryDate;
        DateTime TodayDate = controller.TodayDate;
        String UserName = controller.UserName;
        String FName = controller.FName;
        String LName = controller.LName;
        String Title = controller.Title;
        system.assert(controller.UserName != null);
      Test.stopTest();
    }
  }

  //Method to test with Other scenarios
  static testMethod void testLMSCertificateWithOther() {
    User testUser = createUser(true);
    Test.startTest();
      PageReference pageRef = Page.MarketoCert;
          Test.setCurrentPage(pageRef);
      ApexPages.currentPage().getParameters().put('id', '12232434');
      LMSCertificate controller = new LMSCertificate();
      system.assert(controller.UserName == null);
    Test.stopTest();
  }

  //Method to create test user record
  private static User createUser(boolean isInsert) {
    List<Profile> profileList = [select id from Profile where Name='System Administrator' limit 1];
        Id profileId;
        User usr;
        if(profileList.get(0) != null) {
            profileId = profileList.get(0).Id;
        }

        usr= new User();
        usr.Email              = 'test'+ Integer.valueOf(Math.random()) +'@test.com';
        usr.Username           = 'test' + Integer.valueOf(Math.random()) + '@testuser.com';
        usr.LastName           = 'test' ;
        usr.Alias              = 'test' ;
        usr.ProfileId          = profileId ;
        usr.LanguageLocaleKey  = 'en_US';
        usr.LocaleSidKey       = 'en_US';
        usr.TimeZoneSidKey     = 'America/Chicago';
        usr.EmailEncodingKey   = 'UTF-8';
        if(isInsert) insert usr;
        return usr ;
  }
}