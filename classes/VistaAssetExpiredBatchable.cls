global class VistaAssetExpiredBatchable implements Database.Batchable<sObject> {
	/* batch job to expire assets that ended in the past */
	Date dt = System.Today();
	String query = 'SELECT Id, Asset_Status__c, Quantity__c, Decommission_Effective_Date__c FROM Customer_Asset__c WHERE Asset_Status__c = \'Active\' AND ((Term_End_Date__c <: dt AND Term_End_Date__c != null) OR (Quantity__c = 0 and Term_Start_Date__c <=: dt) OR (Decommission_Effective_Date__c <=: dt))';
 
	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Customer_Asset__c> scope) {
		for(Customer_Asset__c a: scope) {
			if(a.Quantity__c == 0 || a.Decommission_Effective_Date__c <= dt) {
				a.Asset_Status__c = 'Decommissioned';
			} else {
				a.Asset_Status__c = 'Expired';
			}
		}
		update scope;
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}