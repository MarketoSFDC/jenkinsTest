trigger MKT_UpdateTotalHoursModule on lmscons__Training_Content__c (after insert, after update) {
	List<lmscons__Training_Content__c> updatedModule = new List<lmscons__Training_Content__c>();
	List<lmscons__Training_Content__c> newModuleList = new List<lmscons__Training_Content__c>();
	Map<Id, Decimal> oldModuleMap = new Map<Id, Decimal>();
	Set<Id> ModuleIds = new Set<Id>();
	try {
		if (Trigger.isInsert) {
			for (lmscons__Training_Content__c newModule : trigger.new) {
				ModuleIds.Add(newModule.Id);
			}
		}
		if (Trigger.isUpdate) {
			for (lmscons__Training_Content__c oldModule : trigger.old) {
				oldModuleMap.put(oldModule.Id, oldModule.lmscons__Duration__c);
			}
			for (lmscons__Training_Content__c newModuleItem : trigger.new) {
				newModuleList.Add(newModuleItem);
			}
			for (lmscons__Training_Content__c newModuleItem : newModuleList) {
				if (oldModuleMap.containsKey(newModuleItem.Id) && newModuleItem.lmscons__Duration__c != oldModuleMap.get(newModuleItem.Id)) {
					ModuleIds.Add(newModuleItem.Id);
				}
			}
		}
		List<lmscons__Training_Content__c> ModuleList = [SELECT Id, lmscons__Duration__c, MKT_Total_hours__c FROM lmscons__Training_Content__c WHERE ID IN :ModuleIds];
		for (lmscons__Training_Content__c newModuleItem : ModuleList) {
			if (newModuleItem.lmscons__Duration__c != NULL) {
				String TotalHours = '';
				Decimal TotalHoursDec = newModuleItem.lmscons__Duration__c;
				if (TotalHoursDec < 60) {
					TotalHours = String.valueOf(TotalHoursDec) + 'min';
				}
				else {
					TotalHours = String.valueOf(TotalHoursDec.divide(60, 1, System.RoundingMode.UP)) + 'h';
				}
				newModuleItem.MKT_Total_hours__c = TotalHours;
				updatedModule.Add(newModuleItem);
			}
			else {
				newModuleItem.MKT_Total_hours__c = NULL;
				updatedModule.Add(newModuleItem);
			}
		}
		if (updatedModule.size() > 0) {
			update updatedModule;
		}

	}
	catch (Exception e) {

	}
}