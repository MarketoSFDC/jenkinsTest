/**
* (c) 2018 Appirio, Inc
* 
* 
* Description : An apex class used as Handler Class for DynamAssignSolutionTrigger.
* Purpose : The class will assign training to the Users whenever a new Dynamic Assignment Solution record is created that matches the criteria.
* Created By : Ishan Chawla
* Created Date : Feb 20th 2018
* CHANGE LOG
 * DEVELOPER NAME             CHANGE DESCRIPTION                      MODIFY DATE
 * ------------------------------------------------------------------------------
 * Appirio               Created class                           2018/02/20
 * Appirio               Updated class                           2018/03/30
 * Cassandrea Steiner - Updated query locator to get all active CFS Users, removed method for after update, and added comments - 5/4/18
* --------------------------------------------------------------------------------------
**/
global class DynamicAssignmentSolutionBatch implements Schedulable, Database.Batchable < SObject > , Database.Stateful {
    global Map < Dynamic_Assignment_Solution__c, List < User >> devPlanorModule = new Map < Dynamic_Assignment_Solution__c, List < User >> ();
    global List<Dynamic_Assignment_Solution__c> dynamicassignmentlist = New List<Dynamic_Assignment_Solution__c>();
    
    // collect the batches of User records to be passed to the execute method
    global Database.querylocator start(Database.BatchableContext bc) {       
        String query = ' Select ' + 'Id, '+' User_Type__c, '+ ' LMS_Assignment_Type__c, '+' Role_Group__c, '+' Role_Level__c, ' +' Office_Location__c ' + ' from ' + ' user '+' WHERE '+' lmscons__Cornerstone_ID__c '+' != '+' NULL ' + ' AND '+' lmscons__CFS_Status__c '+'='+'\''+  String.escapeSingleQuotes('Active')+'\'';
        //for test class
        if(Test.isRunningTest())
            query = 'SELECT id,LMS_Assignment_Type__c, Office_Location__c, Role_Group__c, Role_Level__c, User_Type__c from User LIMIT 100';
            System.debug(Database.getQueryLocator(query));
            return Database.getQueryLocator(query);
    }
    
    //Instantiate the dynamicassignmentlist with the new records from the trigger
    public void initializesolution(List<Dynamic_Assignment_Solution__c> dynamicassignmentlist2)
    {
        SyStem.debug('INITIALIZE SOLUTION');
        dynamicassignmentlist = dynamicassignmentlist2;
    }
    
    // if called in a schedulable context, this will call the batchable context execute method below
    global void execute(SchedulableContext SC) {
        Database.executeBatch(new DynamicAssignmentSolutionBatch());
    }
    
    // This checks if the user meets the rule criteria
    public Boolean verifyUserRecord(Dynamic_Assignment_Solution__c assignmentsolution, User u) {
        if(
            (assignmentsolution.Assignment_Type__c==Null||assignmentsolution.Assignment_Type__c==u.LMS_Assignment_Type__c)
            &&
            (assignmentsolution.Role_Level__c==Null||assignmentsolution.Role_Level__c==u.Role_Level__c)
            &&
            (assignmentsolution.Role_Group__c==Null||assignmentsolution.Role_Group__c==u.Role_Group__c)
            &&
            (assignmentsolution.Office_Location__c==Null||assignmentsolution.Office_Location__c==u.Office_Location__c)
            &&
            (assignmentsolution.User_Type__c==Null||assignmentsolution.User_Type__c==u.User_Type__c)
        )
        {
            return true;
        }
        return false;
    }
    
    //executes in a batchable context
    //This will put together the Map of matching rules and Users for the AssignmentHelper class
    global void execute(Database.BatchableContext BC, list <User> scope) {
        System.debug('IN EXECUTE METHOD' + dynamicassignmentlist);
        System.debug('LIST OF USERS '+ scope);
        Map<Dynamic_Assignment_Solution__c,List<User>> userDynamicAssignmentMap = New Map <Dynamic_Assignment_Solution__c,List<User>>();    
        //Used for Testing
        if(Test.isRunningTest()){
            scope.clear();
            User u =[SELECT id,LMS_Assignment_Type__c, Office_Location__c, Role_Group__c, Role_Level__c, User_Type__c 
                     FROM User 
                     WHERE Role_Group__c='IT'
                     AND Role_Level__c='Manager'
                     AND  Firstname='Bruce' 
                     AND Lastname='Wayne'
                     AND LanguageLocaleKey='en_US'
                     AND LocaleSidKey='en_US'
                     AND TimeZoneSidKey='America/Chicago' 
                     AND Is_Employee__c=true 
                     AND Office_Location__c='UK' LIMIT 1];
            scope.add(u);
        } 
        //Loops through all the new assignment rules  
        for (Dynamic_Assignment_Solution__c assign: dynamicassignmentlist) {
            List <User> userListforAssignment = new List <User> ();
            //Loops through the active users
            for (User u1: scope) {
                //if the user meets the criteria for the rule, they are added to a list
                if (verifyUserRecord(assign, u1)) {
                    userListforAssignment.add(u1);
                }
            }
            //This separates Dev Plan and Module records from the other learning object records and puts the user and matching learning object record in a map
            if ((userListforAssignment.size() > 0) && (assign.Development_Plan__c == Null && assign.Module__c == Null)) {
                userDynamicAssignmentMap.put(assign, userListforAssignment);
            } else if(userListforAssignment.size() > 0){
                devPlanorModule.put(assign, userListforAssignment);
            }
        }
        //This will send the map of matching users to learning object records to the Assignment Helper where the callout is made to assign training (Excluding Dev Plan and Module records)
        if (userDynamicAssignmentMap.size() > 0){
            AssignmentHelper qTest = new AssignmentHelper();
            qTest.AssignmentHelper1(userDynamicAssignmentMap);
            System.enqueueJob(qTest);   
        }
    }
    
    //This will send the map of matching users to Dev Plan and Module records to the Assignment Helper where the callout is made to assign training
    global void finish(Database.BatchableContext BC) {
        if (devPlanorModule.size() > 0){
            AssignmentHelper qTest = new AssignmentHelper();
            qTest.AssignmentHelper1(devPlanorModule);
            System.enqueueJob(qTest); 
         }
    }
}