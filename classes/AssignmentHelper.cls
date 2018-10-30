/**
* (c) 2018 Appirio, Inc
* 
* 
* Description : An apex class used as Helper class for DynamicAssignmentSolutionBatch and UserTriggerHandler Class.
* Purpose : Its takes the list of Users and Map of Dynamic Assignment Solution and assign training to List of Users.
* Created By : Ishan Chawla
* Created Date : March 26th 2018
* CHANGE LOG
* DEVELOPER NAME             CHANGE DESCRIPTION                      MODIFY DATE
* ------------------------------------------------------------------------------
* Appirio               Created class                           2018/03/30
* Cassandrea Steiner - added comments - 5/4/2018
* --------------------------------------------------------------------------------------
**/
public with sharing class AssignmentHelper implements Queueable, Database.AllowsCallouts {
    Map < Dynamic_Assignment_Solution__c, List < User >> userDynamicAssignmentMap = new Map < Dynamic_Assignment_Solution__c, List < User >> (); 
    
    //instantiates the userDynamicAssignmentMap
    public void AssignmentHelper1(Map<Dynamic_Assignment_Solution__c,List<User>> userDynamicAssignmentMap1)
    {
        userDynamicAssignmentMap = userDynamicAssignmentMap1;
        System.debug('Triggered by trigger');
    }
    
    //This will take the matching training/user maps and make the external callout to assign training
    public void execute(QueueableContext Context){
        System.debug('Value of map ' + userDynamicAssignmentMap);
        for(Dynamic_Assignment_Solution__c dynamicAssignment:userDynamicAssignmentMap.keySet()){
            Map < String, Object > Data = new Map < String, Object > ();
            if(userDynamicAssignmentMap.get(dynamicAssignment)!=Null){
                //Course Assignment
                if(dynamicAssignment.Course__c!=Null){
                    Data.put('MethodName', 'AssignCourse');
                    Data.put('UsersList', userDynamicAssignmentMap.get(dynamicAssignment));
                    Data.put('CourseId', dynamicAssignment.Course__c);
                    if(!Test.isRunningTest()){
                        lmscons.LMSUtil.InvokePackageMethod(Data);//API call to assign Course to users
                    }
                }
                //Curriculum Assignment
                else if(dynamicAssignment.Curriculum__c!=Null){
                    Data.put('MethodName', 'AssignCurriculum');
                    Data.put('UsersList', userDynamicAssignmentMap.get(dynamicAssignment));
                    Data.put('CurriculumId', dynamicAssignment.Curriculum__c);
                    if(!Test.isRunningTest()){
                        lmscons.LMSUtil.InvokePackageMethod(Data);//API call to assign Curriculum to users
                    }
                }
                //Development Plan Assignment
                else if(dynamicAssignment.Development_Plan__c!=Null){
                    Data.put('MethodName', 'assignDevelopmentPlan');
                    Data.put('DevelopmentPlanId', dynamicAssignment.Development_Plan__c);
                    Data.put('UsersList', userDynamicAssignmentMap.get(dynamicAssignment));
                    if(!Test.isRunningTest()){
                        lmsilt.ILTUtil.InvokePackageMethod(Data); //API call to assign Development Plan to users
                    }
                }
                //Learning Path Assignment
                else if(dynamicAssignment.Learning_Path__c!=Null){
                    Data.put('MethodName', 'AssignLearningPath');
                    Data.put('UsersList', userDynamicAssignmentMap.get(dynamicAssignment));
                    Data.put('LearningPathId', dynamicAssignment.Learning_Path__c);
                    if(!Test.isRunningTest()){
                        lmscons.LMSUtil.InvokePackageMethod(Data); //API call to assign Learning Path to users
                    }
                }
                //Module Assignment
                else if(dynamicAssignment.Module__c!=Null) {
                    Data.put('MethodName', 'AssignModule');
                    Data.put('UsersList', userDynamicAssignmentMap.get(dynamicAssignment));
                    Data.put('ModuleId', dynamicAssignment.Module__c);
                    if(!Test.isRunningTest()){
                        lmscons.LMSUtil.InvokePackageMethod(Data); //API call to assign Module to users
                    }
                }
                //Quiz Assignment
                else if(dynamicAssignment.Quizzes__c!=Null){
                    Data.put('MethodName', 'AssignQuiz');
                    Data.put('UsersList', userDynamicAssignmentMap.get(dynamicAssignment));
                    Data.put('QuizId', dynamicAssignment.Quizzes__c);
                    if(!Test.isRunningTest()){
                        lmscons.LMSUtil.InvokePackageMethod(Data); //API call to assign Quiz to users
                    }
                }
                //Event Assignment
                else if(dynamicAssignment.Event__c!=Null){
                    Data.put('MethodName', 'AssignEvent');
                    Data.put('EventId', dynamicAssignment.Event__c);
                    Data.put('UsersList', userDynamicAssignmentMap.get(dynamicAssignment));
                    if(!Test.isRunningTest()){
                        lmsilt.ILTUtil.InvokePackageMethod(Data);    //API call to assign Event to users
                    }
                }
                //Class Enrollment
                else if(dynamicAssignment.Class__c!=Null){
                    Set<Id> userIdSet = new Set<Id>();
                    for(User u:userDynamicAssignmentMap.get(dynamicAssignment)){
                        userIdSet.add(u.Id);
                    }
                    Map<Id,Set<Id>> classToUserIds = new Map<Id,Set<Id> >();
                    classToUserIds.put(dynamicAssignment.Class__c, userIdSet); 
                    Data.put('MethodName', 'EnrollUsersToClass');
                    Data.put('ClassUserData', classToUserIds);
                    if(!Test.isRunningTest()){
                        lmsilt.ILTUtil.InvokePackageMethod(Data);  //API call to assign Class to users
                    }
                }
            }
        }  
    }
}