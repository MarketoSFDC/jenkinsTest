global class VistaAssetExpiredSchedule implements Schedulable {
	/* Scheduled run job to expire assets */
	global void execute(SchedulableContext sc) {
		VistaAssetExpiredBatchable b = new VistaAssetExpiredBatchable();
		database.executeBatch(b);
	}
}