trigger MKT_UpdateTotalHoursCourse on lmscons__Training_Path__c (after insert, after update) {
	List<lmscons__Training_Path__c> updatedCourses = new List<lmscons__Training_Path__c>();
	List<lmscons__Training_Path__c> newCoursesList = new List<lmscons__Training_Path__c>();
	Map<Id, Decimal> oldCoursesMap = new Map<Id, Decimal>();
	Set<Id> CoursesIds = new Set<Id>();
	try {
		if (Trigger.isInsert) {
			for (lmscons__Training_Path__c newCourses : trigger.new) {
				CoursesIds.Add(newCourses.Id);
			}
		}
		if (Trigger.isUpdate) {
			for (lmscons__Training_Path__c oldCourses : trigger.old) {
				oldCoursesMap.put(oldCourses.Id, oldCourses.lmscons__Duration__c);
			}
			for (lmscons__Training_Path__c newCoursesItem : trigger.new) {
				newCoursesList.Add(newCoursesItem);
			}
			for (lmscons__Training_Path__c newCoursesItem : newCoursesList) {
				if (oldCoursesMap.containsKey(newCoursesItem.Id) && newCoursesItem.lmscons__Duration__c != oldCoursesMap.get(newCoursesItem.Id)) {
					CoursesIds.Add(newCoursesItem.Id);
				}
			}
		}
		List<lmscons__Training_Path__c> CoursesList = [SELECT Id, lmscons__Duration__c, MKT_Total_hours__c FROM lmscons__Training_Path__c WHERE ID IN :CoursesIds];
		for (lmscons__Training_Path__c newCoursesItem : CoursesList) {
			if (newCoursesItem.lmscons__Duration__c != NULL) {
				String TotalHours = '';
				Decimal TotalHoursDec = newCoursesItem.lmscons__Duration__c;
				if (TotalHoursDec < 60) {
					TotalHours = String.valueOf(TotalHoursDec) + 'min';
				}
				else {
					TotalHours = String.valueOf(TotalHoursDec.divide(60, 1, System.RoundingMode.UP)) + 'h';
				}
				newCoursesItem.MKT_Total_hours__c = TotalHours;
				updatedCourses.Add(newCoursesItem);
			}
			else {
				newCoursesItem.MKT_Total_hours__c = NULL;
				updatedCourses.Add(newCoursesItem);
			}
		}
		if (updatedCourses.size() > 0) {
			update updatedCourses;
		}

	}
	catch (Exception e) {

	}
}