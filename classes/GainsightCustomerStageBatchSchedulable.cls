global class GainsightCustomerStageBatchSchedulable implements Schedulable {

	global void execute(SchedulableContext scMain) {
		database.executebatch(new GainsightCustomerStageBatch(), 1);
	}
}