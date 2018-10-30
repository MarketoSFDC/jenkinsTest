global class GainsightFeaturesBatchSchedulable implements Schedulable {

	global void execute(SchedulableContext scMain) {
		database.executebatch(new GainsightFeaturesBatch(), 1);
	}
}