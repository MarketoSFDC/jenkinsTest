/**
* (c) 2018 Appirio, Inc
* 
* Description : An apex class used as Helper class for the User_Trigger_MAIN_Handler class.
* Purpose : The class will assign CFS ID to the User and assign training to the user.
* Created By : Ishan Chawla
* Created Date : Feb 20th 2018
* CHANGE LOG
* DEVELOPER NAME             CHANGE DESCRIPTION                      MODIFY DATE
* ------------------------------------------------------------------------------
* Appirio               Created class                           2018/02/20
* Appirio               Updated class                           2018/03/30
* Cassandrea Steiner (using Appirio's code updates) - Updated Class to bulkify 
the call to the queueable class - 2018/04/24
* Cassandrea Steiner - renamed class, updated comments, changed call from User trigger to User trigger handler, 
* added additonal criteria and moved code out of @future methods to avoid hitting limits. 
Cassandrea Steiner - added updateManagerCheckbox and assignPermissionSetsAndGroups methods and related logic - 2018/08/15, APPS-20622, APPS-20623, & APPS-20624 
* --------------------------------------------------------------------------------------
**/
public with sharing class CfsUserTriggerHelper {
        
    //This is a flag to indicate that a User is being updated as a manager. This helps get around the 2 trigger execution limit. 
    public static Boolean updateManager = false;
    
    /*After Insert Handler*/
    public static void onAfterInsert(Map<Id, User> userMap) {
        Set<Id>userIdSet=userMap.keySet();
        //Assign CFS Licenses 
        cfsUserFutureMethod(userIdSet);
        //Get the list of Users that can be assigned training
        List<User> userList = [SELECT id,LMS_Assignment_Type__c, Office_Location__c, Role_Group__c, Role_Level__c, User_Type__c 
                            FROM User WHERE id in: userIdSet 
                            AND (User.Profile.UserLicense.Name = 'Salesforce' 
                                 OR User.Profile.UserLicense.Name = 'Salesforce Platform')];
        //Check for matching training assignments and assign
        assignTraining(userList);
                //APPS-20624 - Update the isManager Checkbox
        updateManagerCheckbox(userMap.values());
        //APPS-20622 & APPS-20623 - Assign Permission Sets and Public Groups
        assignPermissionSetsAndGroups(userMap.values());
    }
    /*After Update Handler*/  
    public static void onAfterUpdate(Map<Id,User> userMap, Map<Id,User> userOldMap) { 
        List<User> assignmentUserList = New List<User>(); 
        List<User> managerUserList = New List<User>(); 
        List<User> permissionsUserList = New List<User>(); 
        //Loop through the updated users from the trigger to check for updates to relevant fields
        for(User usr : userMap.values()) {
            //Dynamic Assignment related fields
            if(
                (usr.lmscons__CFS_Status__c == 'Active') && 
                (
                    (usr.Role_Group__c != userOldMap.get(usr.Id).Role_Group__c) 
                    ||
                    (usr.Role_Level__c != userOldMap.get(usr.Id).Role_Level__c) 
                    ||
                    (usr.User_Type__c != userOldMap.get(usr.Id).User_Type__c)
                    ||
                    (usr.LMS_Assignment_Type__c != userOldMap.get(usr.Id).LMS_Assignment_Type__c)
                    ||
                    (usr.Office_Location__c != userOldMap.get(usr.Id).Office_Location__c) 
                    ||
                    (usr.lmscons__CFS_Status__c != userOldMap.get(usr.Id).lmscons__CFS_Status__c)  
                )
            ){
                assignmentUserList.add(usr);    
            }            
            //APPS-20624 - Update the isManager Checkbox if the Manager/Active/isEmployee fields change
            if(
                (usr.ManagerId != userOldMap.get(usr.Id).ManagerId)
                ||
                (usr.IsActive && !userOldMap.get(usr.Id).IsActive)
                ||
                (usr.Is_Employee__c && !userOldMap.get(usr.Id).Is_Employee__c)
            ){
                managerUserList.add(usr);
            }
            //APPS-20622 & APPS-20623 - Create Permission Set Assignments or add to CFS Public Group for standard users and managers
            if(
                (usr.IsActive && !userOldMap.get(usr.Id).IsActive)
                ||
                (usr.Is_Employee__c && !userOldMap.get(usr.Id).Is_Employee__c)
                ||
                (usr.Is_Manager__c && !userOldMap.get(usr.Id).Is_Manager__c)   
            ){
                permissionsUserList.add(usr);
            }
        }
        //Check for matching training assignments and assign
        if(!assignmentUserList.isEmpty()){
            assignTraining(assignmentUserList);
        }
        //APPS-20624 - Update the isManager Checkbox
        if(!managerUserList.isEmpty()){
            System.debug('!managerUserList.isEmpty'); 
            updateManagerCheckbox(managerUserList);
        }
        //APPS-20622 & APPS-20623 - Assign Permission Sets and Public Groups
        if(!permissionsUserList.isEmpty()){
            System.debug('!permissionsUserList');
            assignPermissionSetsAndGroups(permissionsUserList);
        }
    }
    
    /*Helper Methods*/

    // Getting list of eligible Users and Assign them CFS ID
    @future(callout=true) 
    public static void cfsUserFutureMethod(Set<Id> userIdSet) {
        //Get the list of Users that should be activated
        List<User>userList=[SELECT id 
                            FROM User WHERE id in: userIdSet 
                            AND (User.Profile.UserLicense.Name = 'Salesforce' 
                                 OR User.Profile.UserLicense.Name = 'Salesforce Platform')];
        if(userList != null && userList.size()>0) {
            if(!Test.isRunningTest()) {
                //Calling CFS API to assign Cornerstone Id
                lmscons.ConsumerUserWebservice.CreateConsumerUsers(userList, false);
            }      
        }
    }
    
    //This matches users to assignment rules and sends to AssignmentHelper class to assign     
    public static void assignTraining(List<User> userList){
        // This calls to the method below to get a list of all of the Dynamic Assignment Rules
        List<Dynamic_Assignment_Solution__c> Auto_Assignment_List = ExtractData();
        //This calls the method below to match updated users to rules and sends a map of matches to the AssignmentHelper queuable class
        AssignmentHelper qTest = new AssignmentHelper();
        Map<Dynamic_Assignment_Solution__c,List<User>> assignmentMap = AssignLearningObject(Auto_Assignment_List,userList);
        if(!assignmentMap.isEmpty()){
            qTest.AssignmentHelper1(assignmentMap);
            //Enqueue job
            System.enqueueJob(qTest);   
        } 
    }
    
    //This gets a list of all Dynamic Assignment Solution records
    public static List<Dynamic_Assignment_Solution__c>ExtractData() {
        List<Dynamic_Assignment_Solution__c> autoassignmentlist=[SELECT Id, Course__c, Curriculum__c, Development_Plan__c, Learning_Path__c,Module__c, Quizzes__c, Event__c, Class__c, Assignment_Type__c, Office_Location__c, Role_Group__c, Role_Level__c, User_Type__c 
                                                                 FROM Dynamic_Assignment_Solution__c]; 
        return autoassignmentlist;
    }
    
    //This will get a list of Users matching the rule criteria
    public static Map<Dynamic_Assignment_Solution__c,List<User>> AssignLearningObject(List<Dynamic_Assignment_Solution__c> Auto_Assignment_List,List<User> userList)
    {
        Map<Dynamic_Assignment_Solution__c,List<User>> userDynamicAssignmentMap= New Map<Dynamic_Assignment_Solution__c,List<User>> ();
        for(Dynamic_Assignment_Solution__c assignmentsolution: Auto_Assignment_List)
        {            
            List<User> eligibleUsers=New List<User>();
            //This will check if the User's LMS fields match the rule criteria 
            for(User u:userList) {
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
                    //Adding Users to new list
                    eligibleUsers.add(u);
                }
            }
            //Puts the users into a map with their matched assignments
            if(eligibleUsers.size()>0)
            {
                userDynamicAssignmentMap.put(assignmentsolution,eligibleUsers);
            }
        }
        return userDynamicAssignmentMap;
    }
        
    //APPS-20624 - Updates the Is_Manager__c checkbox on the manager of the updated/inserted users
    public static void updateManagerCheckbox (List<User> userList){
        System.debug('Start updateManagerCheckbox method');
        //empty set to hold manager ids
        Set<id> managerIds = new Set<id>();
        //Loop through the updated users from the trigger
        for (User usr : userList) {
            if(usr.IsActive && usr.Is_Employee__c && usr.ManagerId!=NULL){
                ManagerIds.add(usr.ManagerId);
            }
        }
        if(!managerIds.isEmpty()){
            //Get all the users that were identified as managers
            List<User> managerList = new List<User>([SELECT Id, Is_Manager__c
                                                     FROM User
                                                     WHERE Id in :managerIds
                                                     AND IsActive = true]);
            if(!managerList.isEmpty()){
                //Check the isManager checkbox for each manager in the list	
                for(User usr: managerList){
                    usr.Is_Manager__c = true;
                }
                //Make sure manager is assigned permission set and group
                updateManager = true;
                assignPermissionSetsAndGroups(managerList);
                //Update the manager Users using helper method below
                dmlHelper('update', managerList, false);    
            }
        }
    }
    //APPS-20622 & APPS-20623 - Grant Permission Sets to applicable users and assign to CFS Public Groups
    static void assignPermissionSetsAndGroups(List<User> users){
        List <PermissionSetAssignment> permissionSetAssignments = new List<PermissionSetAssignment>();
        List <GroupMember> publicGroupMembers = new List<GroupMember>();
        String userPsLabel = 'CFS Consumer User';
        String managerPsLabel = 'CFS Consumer Manager';
        String employeeGroupLabel = 'CFS_All_Employees';
        String managerGroupLabel = 'CFS_All_Managers';
        
        System.debug('Start assignPermissionSetsAndGroups');
        for (User u : users){
            //Find all the active managers - if a user is updated as a manager in this class, the updateManager flag is checked so this can run without having to rerun the trigger
            If ((u.IsActive && u.Is_Manager__c) || updateManager == true){
                permissionSetAssignments.add(createPermissionSetAssignments(u,managerPsLabel));
                publicGroupMembers.add(createGroupMember(u,managerGroupLabel));
            }
            //Find all the remaining active employees
            Else If(u.IsActive && u.Is_Employee__c){
                permissionSetAssignments.add(createPermissionSetAssignments(u,userPsLabel));
                publicGroupMembers.add(createGroupMember(u,employeeGroupLabel));
            }
        }
        //Insert permission set assignments using helper method below
        if(!permissionSetAssignments.isEmpty()){
            dmlHelper('insert', permissionSetAssignments, false); 
            
        }
        //Insert Gropu Members using helper method below
        if(!publicGroupMembers.isEmpty()){
            dmlHelper('insert', publicGroupMembers, false);
        }
        updateManager = false;
    }
    //APPS-20622 - Create a Permission Set Assignment based on label
    static PermissionSetAssignment createPermissionSetAssignments (User u, String label) {
        System.debug('start createPermissionSetAssignments');
        // Get Permission Set ID
        PermissionSet ps = [SELECT Id,Label FROM PermissionSet WHERE Label = :label LIMIT 1];
        //Create record    
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = ps.id, AssigneeId = u.id);
        return psa;
    }
    
    //APPS-20623 - Create a GroupMember based on label
    static GroupMember createGroupMember (User u, String label){
        //Get Public Group ID
        Group pg = [SELECT Id,Name FROM Group WHERE Name = :label AND Type = 'Regular' LIMIT 1];
        //Create record
        GroupMember gm = new GroupMember(GroupId = pg.id, UserOrGroupId = u.id);
        return gm;
    }
    
    //Utility method to handle DML exceptions
    static void dmlHelper(String dmlType, List<sObject> recordList, Boolean allOrNone){
        System.debug('Start dmlHelper');
        List<Database.SaveResult> srList = new List<Database.SaveResult>();
        try {
            switch on dmlType{
                when 'insert'{
                    srList = database.insert(recordList, allOrNone);
                }when 'update'{
                    srList = database.update(recordList, allOrNone);
                }
            }
            for (Database.SaveResult sr : srList) {
                if (sr.isSuccess()) {
                    // Operation was successful, so get the ID of the record that was processed
                    System.debug('Successful ' + dmlType  +' of ID = ' + sr.getId());
                }
                else {
                    // Operation failed, so get all errors                
                    for(Database.Error err : sr.getErrors()) {
                        System.debug('Unsuccessful ' + dmlType + ' of ID = ' + sr.getId());                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    }
                }
            }
        }catch(Exception ex){
            System.debug('The following exception has occurred: ' + ex.getMessage());
        }
    }
}