@isTest(seeAllData=true)
public class TestLMS_UpdateRosterUserStatusTrigger {
    public static TestMethod void myTest(){
       lmsilt__Event__c evnt = new lmsilt__Event__c(
           Name = 'Test-Event'
       );
       insert evnt;
       
       lmsilt__Class__c clss = new lmsilt__Class__c(
            Name             = 'test Class',
            lmsilt__Event__c = evnt.Id,
            lmsilt__Type__c  = 'Public',
            lmsilt__Start_Date__c = system.today(),
            lmsilt__End_Date__c = system.today().addDays(10)
        
       );
       insert clss;
       Profile p = [select Id from Profile where Name = 'System Administrator' Limit 1];      
       user u = [select Id from user where ProfileId = : p.Id and IsActive = True Limit 1];
       
       lmsilt__Roster__c roster = new lmsilt__Roster__c(
           lmsilt__Class__c = clss.Id,
           lmsilt__Status__c = 'Enrolled',
           lmsilt__Student__c = u.Id
       );
       insert roster;
       
      
       lmsilt__GoToTraining_Session__c rosterSession1 = new lmsilt__GoToTraining_Session__c(
           lmsilt__Class__c  = clss.Id,
           lmsilt__Event__c   = evnt.Id,
           lmsilt__Roster__c = roster.Id,
           lmsilt__User__c   = u.Id,
           lmsilt__Status__c = 'Attended'
       );
       insert rosterSession1;
       lmsilt__GoToTraining_Session__c rosterSession2 = new lmsilt__GoToTraining_Session__c(
           lmsilt__Class__c  = clss.Id,
           lmsilt__Event__c   = evnt.Id,
           lmsilt__Roster__c = roster.Id,
           lmsilt__User__c   = u.Id,
           lmsilt__Status__c = 'Attended'
       );
       insert rosterSession2;
       
       delete rosterSession1;
        
    }
}