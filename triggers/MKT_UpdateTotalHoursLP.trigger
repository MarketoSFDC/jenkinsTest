trigger MKT_UpdateTotalHoursLP on lmscons__Learning_Path__c (after insert, after update) {
	List<lmscons__Learning_Path__c> updatedLP = new List<lmscons__Learning_Path__c>();
	List<lmscons__Learning_Path__c> newLPList = new List<lmscons__Learning_Path__c>();
	Map<Id, Decimal> oldLPMap = new Map<Id, Decimal>();
	Set<Id> LPIds = new Set<Id>();
	try {
		if (Trigger.isInsert) {
			for (lmscons__Learning_Path__c newLP : trigger.new) {
				LPIds.Add(newLP.Id);
			}
		}
		if (Trigger.isUpdate) {
			for (lmscons__Learning_Path__c oldLP : trigger.old) {
				oldLPMap.put(oldLP.Id, oldLP.lmscons__Duration__c);
			}
			for (lmscons__Learning_Path__c newLPItem : trigger.new) {
				newLPList.Add(newLPItem);
			}
			system.Debug('LPList===='+newLPList);
			system.Debug('oldLPMap===='+oldLPMap);
			for (lmscons__Learning_Path__c newLPItem : newLPList) {
				if (oldLPMap.containsKey(newLPItem.Id) && newLPItem.lmscons__Duration__c != oldLPMap.get(newLPItem.Id)) {
					LPIds.Add(newLPItem.Id);
				}
			}
		}
		List<lmscons__Learning_Path__c> LPList = [SELECT Id, lmscons__Duration__c, MKT_Total_hours__c FROM lmscons__Learning_Path__c WHERE ID IN :LPIds];
		for (lmscons__Learning_Path__c newLPItem : LPList) {
			if (newLPItem.lmscons__Duration__c != NULL) {
				String TotalHours = '';
				Decimal TotalHoursDec = newLPItem.lmscons__Duration__c;
				if (TotalHoursDec < 60) {
					TotalHours = String.valueOf(TotalHoursDec) + 'min';
				}
				else {
					TotalHours = String.valueOf(TotalHoursDec.divide(60, 1, System.RoundingMode.UP)) + 'h';
				}
				newLPItem.MKT_Total_hours__c = TotalHours;
				updatedLP.Add(newLPItem);
			}
			else {
				newLPItem.MKT_Total_hours__c = NULL;
				updatedLP.Add(newLPItem);
			}
		}
		system.Debug('updatedLP===='+updatedLP);
		system.Debug('LPList===='+LPList);
		if (updatedLP.size() > 0) {
			update updatedLP;
		}

	}
	catch (Exception e) {

	}
}