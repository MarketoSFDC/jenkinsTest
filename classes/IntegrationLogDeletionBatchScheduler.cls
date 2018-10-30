/**************************************************************************************************************************************
Company Name  :Jade Global Inc.
Created Date  :10th February 2018
Apex Class	  :IntegrationLogDeletionBatchScheduler
**************************************************************************************************************************************/

global class IntegrationLogDeletionBatchScheduler implements Schedulable {
	global void execute(SchedulableContext sc) {
      Database.executeBatch(new IntegrationLogDeletionBatch());
    }
}