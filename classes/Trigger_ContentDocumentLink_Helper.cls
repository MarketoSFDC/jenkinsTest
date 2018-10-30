/**
* @author Conga Services
* @date 
* @version 1.00
* @description Trigger_ContentDocumentLink_Helper
*/
public with sharing class Trigger_ContentDocumentLink_Helper {
	/**
	* @description Trigger_ContentDocumentLink_Helper - Class containing method logic that is called from the Trigger_ContentDocumentLink_Handler Class
	*/
	public static void CheckForSync(List<ContentDocumentLink> cdlList){
		Set<Id> contentDocumentIds = new Set<Id>();
		List<ContentVersion> cvList = new List<ContentVersion>();
		for(ContentDocumentLink cdl : cdlList){
			if(cdl.LinkedEntity.Type != 'User'){
				contentDocumentIds.add(cdl.ContentDocumentId);
			}
		}
		if(contentDocumentIds.size() > 0){
			cvList = [SELECT Id, ContentDocumentId, IsCongaFile__c FROM ContentVersion WHERE ContentDocumentId IN :contentDocumentIds And IsLatest = true];
		}
        List<ContentVersion> cvToUpdate = new List<ContentVersion>();
		if(cvList.size() > 0){
			for(ContentDocumentLink cdl : cdlList){
				for(ContentVersion cv : cvList){
					if(cdl.ContentDocumentId == cv.ContentDocumentId && cv.IsCongaFile__c == false){
						if(!APXT_Redlining.PlatformDataService.isRecordExcluded(cdl.LinkedEntityId)){
                            cvToUpdate.add(new ContentVersion(Id = cv.Id, IsCongaFile__c = true));
						}
					}		
				}
			}
			if(cvToUpdate.size()>0){
                update cvToUpdate;
            }
		}
	}
}