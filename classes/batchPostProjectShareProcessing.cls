global class batchPostProjectShareProcessing implements Database.Batchable<SObject> { global batchPostProjectShareProcessing() { } global Database.QueryLocator start(Database.BatchableContext context) { return Database.getQueryLocator('SELECT debug_flag__c, Id, Name, Delegated_Project_Manager__r.pse__Salesforce_User__c,pse__Project_Manager__r.pse__Salesforce_User__c FROM pse__Proj__c where (Delegated_Project_Manager__c != null OR pse__Project_Manager__c != null)'); } global void execute(Database.BatchableContext context, List<pse__Proj__c> scope) { Set<Id> LIds = new Set<Id>(); pse__Proj__c Proj = scope[0]; Set<Id> Ids = new Set<Id>(); String projectId = Proj.Id; try{ if (Proj.Delegated_Project_Manager__r.pse__Salesforce_User__c != null) Ids.add(Proj.Delegated_Project_Manager__r.pse__Salesforce_User__c); if (Ids.size() > 0 ) ShareUtilities.SetAllSharingSettingsForProjectBatchMode(ProjectId,Ids); Ids = new Set<Id>(); if (Proj.pse__Project_Manager__r.pse__Salesforce_User__c != null) Ids.add(Proj.pse__Project_Manager__r.pse__Salesforce_User__c); if (Ids.size() > 0 ) ShareUtilities.SetAllSharingSettingsForProjectBatchMode(ProjectId,Ids); List<pse__Assignment__c> Assignments = [Select Id, ResourceSalesforceId__c from pse__Assignment__c where pse__Project__c =: ProjectId AND ResourceSalesforceID__c != null AND ResourceSalesforceID__c != '']; for (pse__Assignment__c Assignment: Assignments) { LIds.add(Assignment.ResourceSalesforceID__c); } if (LIds.size()>0) ShareUtilities.AddLimitedSharingSettingsforResourceBatchMode(ProjectId,LIds); } catch (Exception e){ Proj.debug_flag__c = true; Update Proj; } } global void finish(Database.BatchableContext context) { } public static void run() { Integer batchSize = 1; batchPostProjectShareProcessing batchable = new batchPostProjectShareProcessing(); Database.executeBatch(batchable,batchSize); } }
/*
global class batchPostProjectShareProcessing implements Database.Batchable<SObject> {
	
	global batchPostProjectShareProcessing() {
		
	}
	
	 // @description gets invoked when the batch job starts
	 // @param context contains the job ID
	 // @returns the record set as a QueryLocator object that will be batched for execution

	global Database.QueryLocator start(Database.BatchableContext context) {
		return Database.getQueryLocator('SELECT debug_flag__c, Id, Name, Delegated_Project_Manager__r.pse__Salesforce_User__c,pse__Project_Manager__r.pse__Salesforce_User__c FROM pse__Proj__c where (Delegated_Project_Manager__c != null OR pse__Project_Manager__c != null)');
	}


	 // @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 // @param context contains the job ID
	 // @param scope contains the batch of records to process.
 
   	global void execute(Database.BatchableContext context, List<pse__Proj__c> scope) {
		Set<Id> LIds = new Set<Id>();
		
		pse__Proj__c Proj = scope[0];
		Set<Id> Ids = new Set<Id>();
		String projectId = Proj.Id;
		try{
		if (Proj.Delegated_Project_Manager__r.pse__Salesforce_User__c != null) Ids.add(Proj.Delegated_Project_Manager__r.pse__Salesforce_User__c);		
		if (Ids.size() > 0 ) ShareUtilities.SetAllSharingSettingsForProjectBatchMode(ProjectId,Ids);
		Ids = new Set<Id>();
		if (Proj.pse__Project_Manager__r.pse__Salesforce_User__c != null) Ids.add(Proj.pse__Project_Manager__r.pse__Salesforce_User__c);
		if (Ids.size() > 0 ) ShareUtilities.SetAllSharingSettingsForProjectBatchMode(ProjectId,Ids);

		List<pse__Assignment__c> Assignments = [Select Id, ResourceSalesforceId__c from pse__Assignment__c where pse__Project__c =: ProjectId AND ResourceSalesforceID__c != null AND ResourceSalesforceID__c != ''];

		for (pse__Assignment__c Assignment: Assignments)
		{
			LIds.add(Assignment.ResourceSalesforceID__c);
		}
		if (LIds.size()>0) ShareUtilities.AddLimitedSharingSettingsforResourceBatchMode(ProjectId,LIds);
		}
		catch (Exception e){
			Proj.debug_flag__c = true;
			Update Proj;
		}
	}
	
	 // @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 // @param context contains the job ID
 
	global void finish(Database.BatchableContext context) {
		
	}

	public static void run()
	{
		Integer batchSize = 1;
		batchPostProjectShareProcessing batchable = new batchPostProjectShareProcessing();
		Database.executeBatch(batchable,batchSize);		
	}
}
*/