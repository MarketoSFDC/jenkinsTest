@isTest
public class ScheduleBatchPopulateQueuedMilestones_T {
	
	@isTest
	private static void Test_ScheduleBatchPopulateQueuedMilestones()
	{
		Test.startTest();
		String sch1 = '0 0 * * * ?';
		ScheduleBatchPopulateQueuedMilestones ars1 = new ScheduleBatchPopulateQueuedMilestones();
		system.schedule('Schedule Populate Queued Milestones Batch Run 00:00', sch1, ars1);		
		Test.stopTest();		
	}
}