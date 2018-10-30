trigger MKT_UpdateTotalHoursCurriculum on lmscons__Curriculum__c (after insert, after update) {
	List<lmscons__Curriculum__c> updatedCurriculum = new List<lmscons__Curriculum__c>();
	List<lmscons__Curriculum__c> newCurriculumList = new List<lmscons__Curriculum__c>();
	Map<Id, Decimal> oldCurriculumMap = new Map<Id, Decimal>();
	Set<Id> CurriculumIds = new Set<Id>();
	try {
		if (Trigger.isInsert) {
			for (lmscons__Curriculum__c newCurriculum : trigger.new) {
				CurriculumIds.Add(newCurriculum.Id);
			}
		}
		if (Trigger.isUpdate) {
			for (lmscons__Curriculum__c oldCurriculum : trigger.old) {
				oldCurriculumMap.put(oldCurriculum.Id, oldCurriculum.lmscons__Duration__c);
			}
			for (lmscons__Curriculum__c newCurriculumItem : trigger.new) {
				newCurriculumList.Add(newCurriculumItem);
			}
			for (lmscons__Curriculum__c newCurriculumItem : newCurriculumList) {
				if (oldCurriculumMap.containsKey(newCurriculumItem.Id) && newCurriculumItem.lmscons__Duration__c != oldCurriculumMap.get(newCurriculumItem.Id)) {
					CurriculumIds.Add(newCurriculumItem.Id);
				}
			}
		}
		List<lmscons__Curriculum__c> CurriculumList = [SELECT Id, lmscons__Duration__c, MKT_Total_hours__c FROM lmscons__Curriculum__c WHERE ID IN :CurriculumIds];
		for (lmscons__Curriculum__c newCurriculumItem : CurriculumList) {
			if (newCurriculumItem.lmscons__Duration__c != NULL) {
				String TotalHours = '';
				Decimal TotalHoursDec = newCurriculumItem.lmscons__Duration__c;
				if (TotalHoursDec < 60) {
					TotalHours = String.valueOf(TotalHoursDec) + 'min';
				}
				else {
					TotalHours = String.valueOf(TotalHoursDec.divide(60, 1, System.RoundingMode.UP)) + 'h';
				}
				newCurriculumItem.MKT_Total_hours__c = TotalHours;
				updatedCurriculum.Add(newCurriculumItem);
			}
			else {
				newCurriculumItem.MKT_Total_hours__c = NULL;
				updatedCurriculum.Add(newCurriculumItem);
			}
		}
		if (updatedCurriculum.size() > 0) {
			update updatedCurriculum;
		}

	}
	catch (Exception e) {

	}
}