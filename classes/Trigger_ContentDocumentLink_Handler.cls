/**
* @author Conga Services
* @date 
* @version 1.00
* @description Trigger_ContentDocumentLink_Handler - [Description]
*/
public with sharing class Trigger_ContentDocumentLink_Handler {

	public static void afterInsertUpdateHandler(List<ContentDocumentLink> cdlList){
       Trigger_ContentDocumentLink_Helper.checkForSync(cdlList);
    }
		
}