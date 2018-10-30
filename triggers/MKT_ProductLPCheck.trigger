trigger MKT_ProductLPCheck on lmscons__Learning_Path__c (before insert, before update) {
	Set<Id> ProductIdsSet = new Set<Id>();
	Map<Id, List<lmscons__Learning_Path__c>> ProductIdsListObjectsMap = new Map<Id, List<lmscons__Learning_Path__c>>();
	Map<Id, List<lmscons__Learning_Path__c>> ProductIdsListObjectsMapOld = new Map<Id, List<lmscons__Learning_Path__c>>();
	Map<Id, Id> ProductIdsObjectsIdMapOld = new Map<Id, Id>();
	if (Trigger.isInsert) {

		for (lmscons__Learning_Path__c NewCourse : trigger.new) {
			if (NewCourse.Product__c != NULL) {
				List<lmscons__Learning_Path__c> CourseList;
				if (ProductIdsListObjectsMap.containsKey(NewCourse.Product__c)) {
					CourseList = ProductIdsListObjectsMap.get(NewCourse.Product__c);
				}
				else {
					CourseList = new List<lmscons__Learning_Path__c>();
				}
				CourseList.Add(NewCourse);
				ProductIdsListObjectsMap.put(NewCourse.Product__c, CourseList);
			}
		}
	}
	if (Trigger.isUpdate) {
		Set<Id> OldProductIdsSet = new Set<Id>();
		for (lmscons__Learning_Path__c OldCourse : trigger.old) {
			if (OldCourse.Product__c != NULL) {
				OldProductIdsSet.Add(OldCourse.Product__c);
				ProductIdsObjectsIdMapOld.put(OldCourse.Id, OldCourse.Product__c);
			}
		}
		for (lmscons__Learning_Path__c NewCourse : trigger.new) {
			if(ProductIdsObjectsIdMapOld.containsKey(NewCourse.Id) && ProductIdsObjectsIdMapOld.get(NewCourse.Id) != NewCourse.Product__c) {
				List<lmscons__Learning_Path__c> CourseList;
				if (ProductIdsListObjectsMapOld.containsKey(ProductIdsObjectsIdMapOld.get(NewCourse.Id))) {
					CourseList = ProductIdsListObjectsMapOld.get(ProductIdsObjectsIdMapOld.get(NewCourse.Id));
				}
				else {
					CourseList = new List<lmscons__Learning_Path__c>();
				}
				CourseList.Add(NewCourse);
				ProductIdsListObjectsMapOld.put(ProductIdsObjectsIdMapOld.get(NewCourse.Id), CourseList);
			}


			if (NewCourse.Product__c != NULL) {
				if (!OldProductIdsSet.contains(NewCourse.Product__c)) {
					List<lmscons__Learning_Path__c> CourseList;
					if (ProductIdsListObjectsMap.containsKey(NewCourse.Product__c)) {
						CourseList = ProductIdsListObjectsMap.get(NewCourse.Product__c);
					}
					else {
						CourseList = new List<lmscons__Learning_Path__c>();
					}
					CourseList.Add(NewCourse);
					ProductIdsListObjectsMap.put(NewCourse.Product__c, CourseList);
				}
			}
		}
	}
	if (ProductIdsListObjectsMapOld.size() > 0) {
		Set<Id> ProductsIdsSet = HelperWithoutSharing.CheckObjectProductsInCart(ProductIdsListObjectsMapOld.keySet());
		if (ProductsIdsSet.size() > 0) {
			List<Id> ProductsIdsList = new List<Id>();
			ProductsIdsList.addAll(ProductsIdsSet);
			for(Id ProdId : ProductsIdsList) {
				if(ProductIdsListObjectsMapOld.containsKey(ProdId)) {
					for (lmscons__Learning_Path__c Coursetem : ProductIdsListObjectsMapOld.get(ProdId)) {
						Coursetem.Product__c.addError(Label.MKT_CheckProductInCartError);
					}
				}
			}
		}
	}
	if (ProductIdsListObjectsMap.size() > 0) {
		Set<Id> ProductsIdsSet = HelperWithoutSharing.CheckObjectProducts(ProductIdsListObjectsMap.keySet());
		if (ProductsIdsSet.size() > 0) {
			List<Id> ProductsIdsList = new List<Id>();
			ProductsIdsList.addAll(ProductsIdsSet);
			for(Id ProdId : ProductsIdsList) {
				if(ProductIdsListObjectsMap.containsKey(ProdId)) {
					for (lmscons__Learning_Path__c Coursetem : ProductIdsListObjectsMap.get(ProdId)) {
						Coursetem.Product__c.addError(Label.MKT_CheckProductError);
					}
				}
			}
		}
	}

}