global class ScheduleBatchPopulateQueuedMilestones implements Schedulable {
	/**
	 * @description Executes the scheduled Apex job. 
	 * @param sc contains the job ID
	 */ 
	global void execute(SchedulableContext sc) {
		BatchPopulateQueuedMilestones batchable = new BatchPopulateQueuedMilestones();
		Database.executeBatch(batchable,1);		
	}
}