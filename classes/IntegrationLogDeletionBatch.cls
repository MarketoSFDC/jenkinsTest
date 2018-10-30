/**************************************************************************************************************************************
* Batch Apex Class: IntegrationLogDeletionBatch
* Created by Jade Global
---------------------------------------------------------------------------------------------------------------------------------------
* Purpose/Methods:
* - Scheduler class for Batch Class - "IntegrationLogDeletionBatchScheduler"
* - Scheduled Batch Job Name 		- "DeleteSevenDaysOlderIntLog"
---------------------------------------------------------------------------------------------------------------------------------------
* History:
* - VERSION     DEVELOPER NAME          DATE                         DETAIL FEATURES
    1.0         Jade Global             10th February 2018           INITIAL DEVELOPMENT
**************************************************************************************************************************************/
global class IntegrationLogDeletionBatch implements Database.Batchable<sObject>{
   global final String Query;
   
   //Default constructor, creates the query to fetch N days older Integration Log
   global IntegrationLogDeletionBatch(){
       if(!test.isRunningTest())
       {
           Query = 'SELECT Id FROM Integration_Event_Log__c WHERE CreatedDate != LAST_N_DAYS:' + Label.IntegrationLogDeletionDay;
       }
      else
      {
          Query = 'SELECT Id FROM Integration_Event_Log__c';
      }
   }
   
   //QueryLocation method to fetch the records using the specified querys
   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator(query);
   }
	
   //Deleting the Integration Log data
   global void execute(Database.BatchableContext BC, List<sObject> scope){
      if(!scope.isEmpty())
       delete scope;
   }

   global void finish(Database.BatchableContext BC){

   }

}