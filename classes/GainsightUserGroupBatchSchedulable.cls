global class GainsightUserGroupBatchSchedulable implements Schedulable {

	global void execute(SchedulableContext scMain) {
		database.executebatch(new GainsightUserGroupBatch(), 1);
	}
}