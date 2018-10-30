global class BatchPopulateQueuedMilestones implements Database.Batchable<SObject> {
	
	global BatchPopulateQueuedMilestones() {
		
	}
	
	/**
	 * @description gets invoked when the batch job starts
	 * @param context contains the job ID
	 * @returns the record set as a QueryLocator object that will be batched for execution
	 */ 
	global Database.QueryLocator start(Database.BatchableContext context) {
		if (!Test.isRunningTest()) return Database.getQueryLocator(batchSOQL('pse__Milestone__c','QueueMilestoneTemplate__c=true')); else return Database.getQueryLocator(batchSOQL('pse__Milestone__c','QueueMilestoneTemplate__c=true Limit 1'));
	}

	/**
	 * @description gets invoked when the batch job executes and operates on one batch of records. Contains or calls the main execution logic for the batch job.
	 * @param context contains the job ID
	 * @param scope contains the batch of records to process.
	 */ 
   	global void execute(Database.BatchableContext context, List<pse__Milestone__c> scope) {
		if (scope.size() > 0)
		{
			pse__Milestone__c Milestone = scope[0];
			RS_Utilities.populateProjectFromTemplate(Milestone.Template_ID__c,Milestone.pse__Project__c,Milestone.Id,Milestone.CurrencyIsoCode);
			Milestone.QueueMilestoneTemplate__c = false;
		}
		Update scope;
	}
	
	/**
	 * @description gets invoked when the batch job finishes. Place any clean up code in this method.
	 * @param context contains the job ID
	 */ 
	global void finish(Database.BatchableContext context) {
		
	}

    private string batchSOQL(String sObjectName, String Filter)
    {
        SObjectType stype = Schema.getGlobalDescribe().get(sObjectName);
        Map<String,Schema.SObjectField> mfields = stype.getDescribe().fields.getMap();
        List<String> allFields = New List<String>();
        allFields.addAll(mfields.keySet());
        String SOQL =  'SELECT '+String.join(allFields,',') + ' FROM ' + sObjectName + ' where ' + Filter;
        if(sObjectName == 'pse__Milestone__c'){
            SOQL = 'SELECT '+String.join(allFields,',') + ',Opportunity2__r.pse__Primary_Project__c,Opportunity2__r.Secondary_Project__c,Opportunity2__r.pse__Primary_Project__r.pse__Stage__c FROM ' + sObjectName + ' where ' + Filter;
        }
        system.debug('################# SOQL'+ SOQL);
        return SOQL;    
    }
}