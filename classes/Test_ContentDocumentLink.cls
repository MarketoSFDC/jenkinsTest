/**
* @author Conga Services
* @date 
* @version 1.00
* @description Test_ContentDocumentLink  - Test class for the ContentDocumentLink classes
*/
@isTest
public with sharing class Test_ContentDocumentLink {
	
	/**
	* @description testMethod1 - Test Happy Path of code
	*/
	public static testMethod void testMethod1() {
		Id CaseRecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Tier 3 Cases').getRecordTypeId();
		Case c = new Case();
		c.RecordTypeId = CaseRecordTypeId;
		insert c;

		ContentVersion contentVersion = new ContentVersion(
			Title = 'Tester',
			PathOnClient = 'Tester.jpg',
			VersionData = Blob.valueOf('Test Content'),
			IsMajorVersion = true
		);
		insert contentVersion;    
		List<ContentDocument> documents = [SELECT Id, Title, LatestPublishedVersionId FROM ContentDocument];

		Test.startTest();
			ContentDocumentLink cdl = New ContentDocumentLink();
			cdl.LinkedEntityId = c.id;
			cdl.ContentDocumentId = documents[0].Id;
			cdl.shareType = 'V';
			insert cdl;
		Test.stopTest();
	}
	
}