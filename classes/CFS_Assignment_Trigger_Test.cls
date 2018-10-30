@isTest
public class CFS_Assignment_Trigger_Test {
    @testSetup
    static void setup(){
        //create Module
        lmscons__Training_Content__c module = new lmscons__Training_Content__c ();
        insert module;
        //create Course
        lmscons__Training_Path__c  course = new lmscons__Training_Path__c();
        insert course;
        //create Learning Path
        lmscons__Learning_Path__c lp = new lmscons__Learning_Path__c();
        insert lp;
        //create Curriculum
        lmscons__Curriculum__c curriculum = new lmscons__Curriculum__c();
        insert curriculum;
        //create Development Plan
        lmsilt__Development_Plan__c devPlan = new lmsilt__Development_Plan__c (); 
        insert devPlan;
        //create Content License
        lmscons__Training_Content_License__c tcl = new lmscons__Training_Content_License__c (lmscons__Training_Content__c=module.id);
        insert tcl;
        //create Transcript
        lmscons__Transcript__c transcript = new lmscons__Transcript__c(lmscons__Trainee__c = TestDataUtility.createUser(null, true).id);
        insert transcript;
        //create Training User License
        lmscons__Training_User_License__c license = new lmscons__Training_User_License__c(lmscons__Content_License__c=tcl.id);
        insert license;
        //create Assignment 1
        lmscons__Transcript_Line__c testAssignment1 = new lmscons__Transcript_Line__c(lmscons__Transcript__c=transcript.id, lmscons__Training_User_License__c=license.id, lmscons__Score__c='1');
        insert testAssignment1;
        //create Course Assignment
        lmscons__Training_Path_Assignment_Progress__c courseAssignment = new lmscons__Training_Path_Assignment_Progress__c(lmscons__Transcript__c=transcript.id, lmscons__Training_Path__c=course.id);
        insert courseAssignment;
        //create Learning Path Assignment
        lmscons__Learning_Path_Assignment__c lpAssignment = new lmscons__Learning_Path_Assignment__c(lmscons__Transcript__c=transcript.id, lmscons__Learning_Path__c=lp.id);
        insert lpAssignment;
        //create Curriculum Assignment
        lmscons__Curriculum_Assignment__c curriculumAssignment = new lmscons__Curriculum_Assignment__c(lmscons__Transcript__c=transcript.id, lmscons__Curriculum__c=curriculum.id);
        insert curriculumAssignment;
        //create Development Plan Assignment
        lmsilt__Development_Plan_Assignment__c  devPlanAssignment = new lmsilt__Development_Plan_Assignment__c (lmsilt__Transcript__c=transcript.id, lmsilt__Development_Plan__c=devPlan.id);
        insert devPlanAssignment;
        //create Assignment 2
        lmscons__Transcript_Line__c testAssignment2 = new lmscons__Transcript_Line__c(lmscons__Transcript__c=transcript.id, lmscons__Training_User_License__c=license.id, lmscons__Course_Assignment__c=courseAssignment.id, lmscons__Learning_Path_Assignment__c=lpAssignment.id, lmscons__Curriculum_Assignment__c=curriculumAssignment.id, lmsilt__Dev_Plan_Assignment__c=devPlanAssignment.id);
        insert testAssignment2;
    }
    
    @isTest
    static void testPositive() {
        //get Assignment
        lmscons__Transcript_Line__c testAssignment = [SELECT id, Sub_Assignment__c 
                                                      FROM lmscons__Transcript_Line__c
                                                      WHERE lmscons__Course_Assignment__c!=null
                                                      LIMIT 1];
        //this should be a sub-assignment
        System.assertEquals(true, testAssignment.Sub_Assignment__c);
        
        //get Course Assignment
        lmscons__Training_Path_Assignment_Progress__c courseAssignment = [SELECT id, Sub_Assignment__c 
                                                                          FROM lmscons__Training_Path_Assignment_Progress__c
                                                                          LIMIT 1];
        //this should be a sub-assignment
        System.assertEquals(true, courseAssignment.Sub_Assignment__c);
        
        //get Learning Path Assignment
        lmscons__Learning_Path_Assignment__c lpAssignment = [SELECT id, Sub_Assignment__c 
                                                             FROM lmscons__Learning_Path_Assignment__c
                                                             LIMIT 1];
        //this should be a sub-assignment
        System.assertEquals(true, lpAssignment.Sub_Assignment__c);
        
        //get Curriculum Assignment
        lmscons__Curriculum_Assignment__c curriculumAssignment = [SELECT id, Sub_Assignment__c 
                                                                  FROM lmscons__Curriculum_Assignment__c
                                                                  LIMIT 1];
        //this should be a sub-assignment
        System.assertEquals(true, curriculumAssignment.Sub_Assignment__c);       
    }
    
    @isTest
    static void testNegative() {
        //get Assignment
        lmscons__Transcript_Line__c testAssignment = [SELECT id, Sub_Assignment__c 
                                                      FROM lmscons__Transcript_Line__c
                                                      WHERE lmscons__Score__c = '1'
                                                      LIMIT 1];
        //this should not be a sub-assignment
        System.assertEquals(false, testAssignment.Sub_Assignment__c);
    }
}