@isTest
private class LegalAgreementsServiceTest {

    @TestSetup 
    static void setup() {
        //Legal_Agreements_Settings__c customSetting = new Legal_Agreements_Settings__c(Triggers_Enabled__c = true);        
        //insert customSetting;
        
        List<Country__c> countryToInsert = new List<Country__c>();
        
        Country__c cc = new Country__c();
        cc.Name = 'USA';
        cc.CurrencyIsoCode = 'USD';
        cc.Country_Registered_Office_Address__c = 'test';
        cc.Region__c = 'North America';
        cc.Marketo_Entity_Conga__c = 'EMEA';
        cc.Marketo_Entity__c = 'Marketo, Inc.';
        countryToInsert.add(cc);
        
         Country__c cc1 = new Country__c();
        cc1.Name = 'Madrid';
        cc1.CurrencyIsoCode = 'USD';
        cc1.Country_Registered_Office_Address__c = 'test';
        cc1.Region__c = 'North America';
        cc1.Marketo_Entity_Conga__c = 'EMEA';
        cc1.Marketo_Entity__c = 'Marketo, Inc.';
        countryToInsert.add(cc1);
        insert countryToInsert;
    }

    @isTest 
    static void testLegalAgrementWithSingleVersionClauseBundle() {
        
        Integer numClauses = 5;
        Boolean isInsuranceExhibit = false;
        Boolean includeSLA = false;
        String year = null;
        Id congaTemplate = null;
        
        Map<Id, String> legalAgreementsRecordTypeMap = LegalAgreementsTestDataFactory.getLegalAgreementsRecordTypesMapForClauseBundles();
        System.assert(legalAgreementsRecordTypeMap.size() > 0 );
        Id legalAgreementRecordTypeId = new List<Id>(legalAgreementsRecordTypeMap.keySet())[0];
        String legalAgreementRecordType = legalAgreementsRecordTypeMap.get(legalAgreementRecordTypeId);

        String region = LegalAgreementsTestDataFactory.getPickListDefaultOrFirstValue(Legal_Agreements__c.Version__c);
        System.assert(region != null);

        Test.startTest();
        LegalAgreementsTestDataFactory.createClauseBundle(legalAgreementRecordType, region, numClauses, isInsuranceExhibit, includeSLA, year, congaTemplate);
        Legal_Agreements__c la = new Legal_Agreements__c(
            Name = 'Test LA',
            RecordTypeId = legalAgreementRecordTypeId,
            Version__c = region
        );
        insert la;
        Test.stopTest();

        Set<Id> legalAgreements = new Set<Id>();
        legalAgreements.add(la.Id);
        Map<Id, List<APXT_Redlining__Managed_Clause__c>> legalAgreementIdToManagedClausesMap = getManagedClausesForLegalAgreements(legalAgreements);
        System.assertEquals(1, legalAgreementIdToManagedClausesMap.size());
        System.assertEquals(numClauses, legalAgreementIdToManagedClausesMap.get(la.Id).size());
    }

    @isTest 
    static void testLegalAgrementWithMultipleVersionClauseBundle() {

        Integer numClauses = 5;
        Boolean isInsuranceExhibit = false;
        Boolean includeSLA = false;
        String year = null;
        Id congaTemplate = null;

        Map<Id, String> legalAgreementsRecordTypeMap = LegalAgreementsTestDataFactory.getLegalAgreementsRecordTypesMapForClauseBundles();
        System.assert(legalAgreementsRecordTypeMap.size() > 1 );
        Id legalAgreementRecordTypeId = new List<Id>(legalAgreementsRecordTypeMap.keySet())[0];
        String legalAgreementRecordType = legalAgreementsRecordTypeMap.get(legalAgreementRecordTypeId);

        LegalAgreementsTestDataFactory.PickListInfo regionInfo = LegalAgreementsTestDataFactory.getPickListInfo(Legal_Agreements__c.Version__c);
        System.assert(regionInfo.values.size() > 1);
        String regions = regionInfo.values[0] + ';' + regionInfo.values[1];
        String region = LegalAgreementsTestDataFactory.getPickListDefaultOrFirstValue(Legal_Agreements__c.Version__c);
        LegalAgreementsTestDataFactory.createClauseBundle(legalAgreementRecordType, regions, numClauses, isInsuranceExhibit, includeSLA, year,congaTemplate);        
        
        Test.startTest();
        system.debug('legalAgreementRecordTypeId'+ legalAgreementRecordTypeId);
        Legal_Agreements__c la = new Legal_Agreements__c(
            Name = 'Test LA',            
            RecordTypeId = legalAgreementRecordTypeId,
            Version__c = region
        );
        insert la;
        Test.stopTest();

        Set<Id> legalAgreements = new Set<Id>();
        legalAgreements.add(la.Id);
        Map<Id, List<APXT_Redlining__Managed_Clause__c>> legalAgreementIdToManagedClausesMap = getManagedClausesForLegalAgreements(legalAgreements);
        System.assertEquals(1, legalAgreementIdToManagedClausesMap.size());
        System.assertEquals(numClauses, legalAgreementIdToManagedClausesMap.get(la.Id).size());        
    }

    @isTest 
    static void testLegalAgreementWithInsuranceExhibit() {

        Integer numClauses = 2;
        Boolean isInsuranceExhibit = true;
        Boolean includeSLA = false;
        String year = null;
        Id congaTemplate = null;

        
        Map<Id, String> legalAgreementsRecordTypeMap = LegalAgreementsTestDataFactory.getLegalAgreementsRecordTypesMapForClauseBundles();
        System.assert(legalAgreementsRecordTypeMap.size() > 0 );
        Id legalAgreementRecordTypeId = new List<Id>(legalAgreementsRecordTypeMap.keySet())[0];
        String legalAgreementRecordType = legalAgreementsRecordTypeMap.get(legalAgreementRecordTypeId);

        String region = LegalAgreementsTestDataFactory.getPickListDefaultOrFirstValue(Legal_Agreements__c.Version__c);
        System.assert(region != null);

        LegalAgreementsTestDataFactory.createClauseBundle(legalAgreementRecordType, region, numClauses, !isInsuranceExhibit, includeSLA, year, congaTemplate);        
        LegalAgreementsTestDataFactory.createClauseBundle(legalAgreementRecordType, region, numClauses, isInsuranceExhibit, includeSLA, year, congaTemplate);                
       
        Test.startTest();
        Legal_Agreements__c la = new Legal_Agreements__c(
            Name = 'Test LA',
            RecordTypeId = legalAgreementRecordTypeId,
            Version__c = region,
            Include_Insurance_Exhibit__c = true
        );
        insert la;
        Test.stopTest();

        Set<Id> legalAgreements = new Set<Id>();
        legalAgreements.add(la.Id);
        Map<Id, List<APXT_Redlining__Managed_Clause__c>> legalAgreementIdToManagedClausesMap = getManagedClausesForLegalAgreements(legalAgreements);
        System.assertEquals(1, legalAgreementIdToManagedClausesMap.size());
        System.assertEquals(numClauses * 2, legalAgreementIdToManagedClausesMap.get(la.Id).size());        
    }

    @isTest
    static void testLegalAgreementWithRecordTypeYear() {

        Integer numClauses = 2;
        Boolean isInsuranceExhibit = false;
        Boolean includeSLA = false;
        Id congaTemplate = null;
               
        Map<Id, String> legalAgreementsRecordTypeMap = LegalAgreementsTestDataFactory.getLegalAgreementsRecordTypesMapForClauseBundles();
        System.assert(legalAgreementsRecordTypeMap.size() > 0 );
        Id legalAgreementRecordTypeId = new List<Id>(legalAgreementsRecordTypeMap.keySet())[0];
        String legalAgreementRecordType = legalAgreementsRecordTypeMap.get(legalAgreementRecordTypeId);

        String year = LegalAgreementsTestDataFactory.getPickListDefaultOrFirstValue(Legal_Agreements__c.Year__c);
        System.assert(year != null);        

        String region = LegalAgreementsTestDataFactory.getPickListDefaultOrFirstValue(Legal_Agreements__c.Version__c);
        System.assert(region != null);

        LegalAgreementsTestDataFactory.createClauseBundle(legalAgreementRecordType, region, numClauses, isInsuranceExhibit, includeSLA, year, congaTemplate);        

        Test.startTest();
        List<Legal_Agreements__c> newLAs = new List<Legal_Agreements__c>();
        newLAs.add(
            new Legal_Agreements__c(
                Name = 'Test LA',
                RecordTypeId = legalAgreementRecordTypeId,
                Version__c = region,
                Year__c = year
            )
        ); // setting explicitly year
        newLAs.add(
            new Legal_Agreements__c(
                Name = 'Test LA',
                RecordTypeId = legalAgreementRecordTypeId,
                Version__c = region
            )
        ); // without specifiying year
        insert newLAs;
        Test.stopTest();

        Set<Id> legalAgreements = new Set<Id>();
        for (Legal_Agreements__c la : newLAs) {
            legalAgreements.add(la.Id);
        }
        Map<Id, List<APXT_Redlining__Managed_Clause__c>> legalAgreementsIdToManagedClausesMap = getManagedClausesForLegalAgreements(legalAgreements);
        System.assertEquals(2, legalAgreementsIdToManagedClausesMap.size());
        for (Legal_Agreements__c la : newLAs) {        
            System.assertEquals(numClauses, legalAgreementsIdToManagedClausesMap.get(la.Id).size());        
        }
    }    

    @isTest 
    static void testLegalAgreementBundleChangeAndDeletion() {
       
        Map<Id, String> legalAgreementsRecordTypeMap = LegalAgreementsTestDataFactory.getLegalAgreementsRecordTypesMapForClauseBundles();
        System.assert(legalAgreementsRecordTypeMap.size() > 1 );
        List<Id> legalAgreementRecordTypeIds = new List<Id>(legalAgreementsRecordTypeMap.keySet());

        LegalAgreementsTestDataFactory.PickListInfo regionInfo = LegalAgreementsTestDataFactory.getPickListInfo(Legal_Agreements__c.Version__c);
        System.assert(regionInfo.values.size() > 1);

        Integer firstBundleClausesNumber = 2;
        Integer secondBundleClausesNumber = 4;
        Boolean isInsuranceExhibit = false;
        Boolean includeSLA = false;
        String year = null;

        String congaTemplateType = LegalAgreementsTestDataFactory.getPickListDefaultOrFirstValue(APXTConga4__Conga_Template__c.APXTConga4__Template_Type__c);
        System.assert(congaTemplateType != null);

        List<APXTConga4__Conga_Template__c> congaTemplates = LegalAgreementsTestDataFactory.createCongaTemplates(congaTemplateType, 2);
        System.assertEquals(2, congaTemplates.size());
        
        LegalAgreementsTestDataFactory.createClauseBundle(legalAgreementsRecordTypeMap.get(legalAgreementRecordTypeIds[0]), regionInfo.values[0], firstBundleClausesNumber, isInsuranceExhibit, includeSLA, year, congaTemplates[0].Id);
        
        isInsuranceExhibit = true;
        LegalAgreementsTestDataFactory.createClauseBundle(legalAgreementsRecordTypeMap.get(legalAgreementRecordTypeIds[0]), regionInfo.values[1], secondBundleClausesNumber, isInsuranceExhibit, includeSLA, year, congaTemplates[1].Id);

        Test.startTest();        
        List<Legal_Agreements__c> newLAs = new List<Legal_Agreements__c>();
        newLAs.add(
            new Legal_Agreements__c(
                Name = 'Test LA',
                RecordTypeId = legalAgreementRecordTypeIds[0],
                Version__c = regionInfo.values[0],
                Include_Insurance_Exhibit__c = false)
        );
        newLAs.add(
            new Legal_Agreements__c(
                Name = 'Test LA',
                RecordTypeId = legalAgreementRecordTypeIds[0],
                Version__c = regionInfo.values[1],
                Include_Insurance_Exhibit__c = true)
        );
        insert newLAs;        

        Set<Id> legalAgreementsIds = new Set<Id>();
        for (Legal_Agreements__c la : newLAs) {
            legalAgreementsIds.add(la.Id);
        }
        Map<Id, Legal_Agreements__c> legalAgreementsMap = getLegalAgreementsMap(legalAgreementsIds);

        // check clause bundle clauses number        
        Map<Id, List<APXT_Redlining__Managed_Clause__c>> legalAgreementIdToManagedClausesMap = getManagedClausesForLegalAgreements(legalAgreementsIds);
        for (Id laId : legalAgreementsIds) {
            if (legalAgreementsMap.get(laId).Include_Insurance_Exhibit__c)
                System.assertEquals(secondBundleClausesNumber, legalAgreementIdToManagedClausesMap.get(laId).size());            
            else
                System.assertEquals(firstBundleClausesNumber, legalAgreementIdToManagedClausesMap.get(laId).size());                        
        }        

        //check conga template assignment
        for (Id laId : legalAgreementsMap.keySet()) {
            if (legalAgreementsMap.get(laId).Include_Insurance_Exhibit__c)
                System.assertEquals(congaTemplates[1].Id, legalAgreementsMap.get(laId).Composer_Template_ID__c);
            else
                System.assertEquals(congaTemplates[0].Id, legalAgreementsMap.get(laId).Composer_Template_ID__c);
        }

        for (Legal_Agreements__c la : newLAs) {
            if (!la.Include_Insurance_Exhibit__c) {
                la.Version__c = regionInfo.values[1];
                la.Include_Insurance_Exhibit__c = true;
            }
        }
        update newLAs;        

        // check clause bundle clauses number after update.
        legalAgreementIdToManagedClausesMap = getManagedClausesForLegalAgreements(legalAgreementsIds);
        for (Legal_Agreements__c la : newLAs) {   
            System.assertEquals(secondBundleClausesNumber, legalAgreementIdToManagedClausesMap.get(la.Id).size());
        }

        delete newLAs;

        Test.stopTest();

    }

    @isTest 
    static void testLegalAgreementCreationFromQuote() {

        String testShippingCountryOk = 'USA';
        String testShippingCountryError = 'Madrid';

        // create 2 test accounts
        List<Account> accounts = LegalAgreementsTestDataFactory.createAccounts(2, null);        
        System.assertEquals(2, accounts.size());

        // uptate ShippingCountry value, one with valid value and the other with an invalid value.
        accounts[0].ShippingCountry = testShippingCountryOk;
        accounts[1].ShippingCountry = testShippingCountryError;
        update accounts;

        // create one test opportunity for each account
        List<Opportunity> opportunities = LegalAgreementsTestDataFactory.createOpportunities(accounts, 1);
        System.assertEquals(2, opportunities.size());

        // get quote record types
        Map<Id, RecordTypeInfo> quoteRecordTypeIdToRecordTypeInfoMap = LegalAgreementsTestDataFactory.getObjectActiveAvailableRecordTypesMap(Schema.SObjectType.SBQQ__Quote__c);
        System.assert(quoteRecordTypeIdToRecordTypeInfoMap.size() > 0);

        Id quoteRecordTypeId = null;
        for (RecordTypeInfo rti : quoteRecordTypeIdToRecordTypeInfoMap.values()) {
            if (rti.isDefaultRecordTypeMapping()) {
                quoteRecordTypeId = rti.getRecordTypeId();
                break;
            }
        }
        
        if (quoteRecordTypeId == null) quoteRecordTypeId = new List<Id>(quoteRecordTypeIdToRecordTypeInfoMap.keySet())[0];

        // create one quote for each test opportunity.
        List<SBQQ__Quote__c> quotes = LegalAgreementsTestDataFactory.createQuotes(opportunities, quoteRecordTypeId);
        System.assertEquals(2, quotes.size());
        Set<Id> quoteIds = new Set<Id>();
        
        for (SBQQ__Quote__c q : quotes) {
            quoteIds.add(q.Id);
        }

        // get legal agreements record types.
        Map<Id, String> legalAgreementsRecordTypeMap = LegalAgreementsTestDataFactory.getLegalAgreementsRecordTypesMapForClauseBundles();
        System.assert(legalAgreementsRecordTypeMap.size() > 1 );
        List<Id> legalAgreementRecordTypeIds = new List<Id>(legalAgreementsRecordTypeMap.keySet());

        Map<Id, LegalAgreementsService.LegalAgreementRecordTypeExtendedInfo> quoteIdToLegalAgreementRecordTypeExtendedInfoMap = new Map<Id, LegalAgreementsService.LegalAgreementRecordTypeExtendedInfo>();
        for (Id quoteId : quoteIds) {
            quoteIdToLegalAgreementRecordTypeExtendedInfoMap.put(quoteId, new LegalAgreementsService.LegalAgreementRecordTypeExtendedInfo(legalAgreementRecordTypeIds[0], null));
        }

        Map<Id, SBQQ__Quote__c> quoteMap = getQuoteMap(quoteIds);

        Test.startTest();
        Map<Id, LegalAgreementsService.LegalAgreementCreationInfo> quoteIdToLegalAgreementCreationInfoMap = LegalAgreementsService.generateLegalAgreement(quoteIdToLegalAgreementRecordTypeExtendedInfoMap);                
        Test.stopTest();

        // check results
        for (Id quoteId : quoteIdToLegalAgreementCreationInfoMap.keySet()) {
            if (quoteMap.get(quoteId).SBQQ__Account__r.ShippingCountry.containsignorecase(testShippingCountryError)) {
                System.assert(quoteIdToLegalAgreementCreationInfoMap.get(quoteId).legalAgreementId != null);
                System.assertEquals(null, quoteIdToLegalAgreementCreationInfoMap.get(quoteId).errorMessage);
            }
            else {
                //System.assert(quoteIdToLegalAgreementCreationInfoMap.get(quoteId).legalAgreementId == null);                
               // System.assertEquals(LegalAgreementsService.ERROR_LEGAL_AGREEMENT_REGION, quoteIdToLegalAgreementCreationInfoMap.get(quoteId).errorMessage);
            }
        }
       
    }

    /********
    Selectors
    ********/    
    private static Map<Id, List<APXT_Redlining__Managed_Clause__c>> getManagedClausesForLegalAgreements(Set<Id> legalAgreementsIds) {

        Map<Id, List<APXT_Redlining__Managed_Clause__c>> legalAgreementsIdToManagedClausesMap = new Map<Id, List<APXT_Redlining__Managed_Clause__c>>();

        List<APXT_Redlining__Managed_Clause__c> managedClasues = [
            select
                Id,
                Parent_aCk__c
            from APXT_Redlining__Managed_Clause__c
            where Parent_aCk__c IN :legalAgreementsIds
        ];

        for (APXT_Redlining__Managed_Clause__c managedClause : managedClasues) {
            if (legalAgreementsIdToManagedClausesMap.containsKey(managedClause.Parent_aCk__c)) {
                legalAgreementsIdToManagedClausesMap.get(managedClause.Parent_aCk__c).add(managedClause);
            }
            else {
                List<APXT_Redlining__Managed_Clause__c> managedClauses = new List<APXT_Redlining__Managed_Clause__c>();
                managedClauses.add(managedClause);
                legalAgreementsIdToManagedClausesMap.put(managedClause.Parent_aCk__c, managedClauses);
            }
        }

        return legalAgreementsIdToManagedClausesMap;
    }

    private static Map<Id, Legal_Agreements__c> getLegalAgreementsMap(Set<Id> legalAgremeentsIds) {
        return new Map<Id, Legal_Agreements__c>(
            [
                SELECT
                    Id,
                    Composer_Template_ID__c,
                    Include_Insurance_Exhibit__c
                FROM Legal_Agreements__c
                WHERE Id IN :legalAgremeentsIds
            ]
        );
    }

    private static Map<Id, SBQQ__Quote__c> getQuoteMap (Set<Id> quoteIds) {
        return new Map<Id, SBQQ__Quote__c>([
            SELECT
                Id, 
                SBQQ__Account__r.ShippingCountry
            FROM SBQQ__Quote__c
            WHERE Id IN :quoteIds
        ]
        );
    }
}