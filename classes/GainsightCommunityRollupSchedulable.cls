global class GainsightCommunityRollupSchedulable implements Schedulable 
{
	static testMethod void GainsightCommunityRollupSchedulableTest() 
    {
        GainsightCommunityRollupSchedulable m = new GainsightCommunityRollupSchedulable();
        string sch = '0 0 13 ? * SUN'; 
        system.schedule('Test Schedule', sch, m);
    }
	
	global void execute(SchedulableContext scMain) 
	{
		database.executebatch(new GainsightCommunityRollupBatch(),1);
	}
}