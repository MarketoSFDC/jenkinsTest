/*
Name                    - DynamAssignSolutionTrigger
Created By              - Sumit Dayama
Created Date            - 03/07/2018
 
* CHANGE LOG
 * DEVELOPER NAME             CHANGE DESCRIPTION                      MODIFY DATE
 * ------------------------------------------------------------------------------
 * Appirio               Created class                           2018/03/07
 * Appirio               Updated class                           2018/03/30
 * Cassandrea Steiner - I updated this trigger to not run on update, as that was the intended design - 5/4/2018
*/

trigger DynamAssignSolutionTrigger on Dynamic_Assignment_Solution__c (after insert, after update) {
	DynamicAssignmentSolutionBatch batchObject = New DynamicAssignmentSolutionBatch();
    if(Trigger.isAfter && Trigger.isInsert){
        //HANDLE ALL OPERATIONS AFTER INSERT IN BULK
        System.debug('New Dynamic Assignment Solution');
        batchObject.initializesolution(Trigger.newMap.values());
    	Database.executeBatch(batchObject);
    }
}