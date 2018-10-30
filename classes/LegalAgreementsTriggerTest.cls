@isTest
private class LegalAgreementsTriggerTest {

    @TestSetup 
    static void setup() {
		//Legal_Agreements_Settings__c customSetting = new Legal_Agreements_Settings__c(Triggers_Enabled__c = true);        
		//insert customSetting;
    }
    
    @isTest 
    static void testInsertUpdateDelete() {

        Map<Id, String> legalAgreementsRecordTypeMap = LegalAgreementsTestDataFactory.getLegalAgreementsRecordTypesMapForClauseBundles();
        System.assert(legalAgreementsRecordTypeMap.size() > 1 );
        List<Id> legalAgreementsRecordTypeIds = new List<Id>(legalAgreementsRecordTypeMap.keySet());

        String region = LegalAgreementsTestDataFactory.getPickListDefaultOrFirstValue(Legal_Agreements__c.Version__c);
        System.assert(region != null);

        Legal_Agreements__c la = new Legal_Agreements__c(
            Name = 'Test LA',
            RecordTypeId = legalAgreementsRecordTypeIds[0],
            Version__c = region
        );

        Test.startTest();
        
        insert la;
        System.assert(la.Id != null);

        la.RecordTypeId = legalAgreementsRecordTypeIds[1];
        update la;

        delete la;

        Test.stopTest();

    }
    
}