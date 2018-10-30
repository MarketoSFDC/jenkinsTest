trigger MKT_UpdateTotalHoursClass on lmsilt__Class__c (after insert, after update) {
	List<lmsilt__Class__c> updatedClasses = new List<lmsilt__Class__c>();
	List<lmsilt__Class__c> newClassesList = new List<lmsilt__Class__c>();
	Map<Id, String> oldClassesMap = new Map<Id, String>();
	Set<Id> ClassesIds = new Set<Id>();
	try {
		if (Trigger.isInsert) {
			for (lmsilt__Class__c newClass : trigger.new) {
				ClassesIds.Add(newClass.Id);
			}
		}
		if (Trigger.isUpdate) {
			for (lmsilt__Class__c oldClass : trigger.old) {
				oldClassesMap.put(oldClass.Id, oldClass.lmsilt__Total_hours__c);
			}
			for (lmsilt__Class__c newClassItem : trigger.new) {
				newClassesList.Add(newClassItem);
			}
			for (lmsilt__Class__c newClassItem : newClassesList) {
				if (oldClassesMap.containsKey(newClassItem.Id) && newClassItem.lmsilt__Total_hours__c != oldClassesMap.get(newClassItem.Id)) {
					ClassesIds.Add(newClassItem.Id);
				}
			}
		}
		List<lmsilt__Class__c> ClassesList = [SELECT Id, lmsilt__Total_hours__c, MKT_Total_hours__c FROM lmsilt__Class__c WHERE ID IN :ClassesIds];
		for (lmsilt__Class__c newClassItem : ClassesList) {
			if (newClassItem.lmsilt__Total_hours__c != NULL && newClassItem.lmsilt__Total_hours__c != '') {
				String TotalHours = newClassItem.lmsilt__Total_hours__c;
				if (TotalHours.contains('h')) {
					String[] TotalHoursSplit = TotalHours.Split('h', 2);
					TotalHours = TotalHoursSplit[0];
				}
				Decimal TotalHoursDec = Decimal.valueOf(TotalHours.replace(',','.'));
				if (TotalHoursDec < 1) {
					TotalHours = String.valueOf((TotalHoursDec*60).setScale(0,System.RoundingMode.UP)) + 'min';
				}
				else {
					String[] TotalHoursSplit = TotalHours.Split(',', 2);
					if (TotalHoursSplit.size() == 1 || TotalHoursSplit[1] == '0') TotalHours = String.valueOf(TotalHoursDec.setScale(0,System.RoundingMode.UP)) + 'h';
					else TotalHours = String.valueOf(TotalHoursDec.setScale(1,System.RoundingMode.UP)) + 'h';
				}
				newClassItem.MKT_Total_hours__c = TotalHours;
				updatedClasses.Add(newClassItem);
			}
			else {
				newClassItem.MKT_Total_hours__c = newClassItem.lmsilt__Total_hours__c;
				updatedClasses.Add(newClassItem);
			}
		}
		if (updatedClasses.size() > 0) {
			update updatedClasses;
		}

	}
	catch (Exception e) {

	}
}