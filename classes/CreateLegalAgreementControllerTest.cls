@isTest
private class CreateLegalAgreementControllerTest {

    @TestSetup 
    static void setup() {
        
        // create test account.
        List<Account> accounts = LegalAgreementsTestDataFactory.createAccounts(1, 'USA');        
        //System.assertEquals(1, accounts.size());

        // create test opportunity.
        List<Opportunity> opportunities = LegalAgreementsTestDataFactory.createOpportunities(accounts, 1);
        System.assertEquals(1, opportunities.size());

        // get quote record types.
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

        // create test quote.
        List<SBQQ__Quote__c> quotes = LegalAgreementsTestDataFactory.createQuotes(opportunities, quoteRecordTypeId);
        //System.assertEquals(1, quotes.size());

        // enable legal agreements trigger.
        //Legal_Agreements_Settings__c customSetting = new Legal_Agreements_Settings__c(Triggers_Enabled__c = true);        
        //insert customSetting;
        
        
        Country__c cc = new Country__c();
        cc.Name = 'USA';
        cc.CurrencyIsoCode = 'USD';
        cc.Country_Registered_Office_Address__c = 'test';
        cc.Region__c = 'North America';
        insert cc;
        
        Legal_Agreements__c la = new Legal_Agreements__c();
        la.Name = 'Test legal Aggrement';        
        la.Version__c  = 'NA';
        la.Account__c= accounts[0].id;
        la.Opportunity__c = opportunities[0].id;
        la.SBQQ_Quote__c = quotes[0].id;
        la.Year__c = '2012';
        insert la;
    }

    @isTest 
    static void testCreateLegalAgreementFromOpportunity() {
        List<Opportunity> testOpportunities = getTestOpportunities();
        System.assert(testOpportunities.size() > 0);
        Opportunity opportunity = testOpportunities[0];

        String regionName = [SELECT Name, Marketo_Entity_Conga__c,Region__c FROM Country__c  where Name = :opportunity.Account.ShippingCountry][0].Region__c;

        PageReference pageRef = Page.CreateLegalAgreement;
        pageRef.getParameters().put('id', opportunity.Id);
        Test.setCurrentPage(pageRef);     
        CreateLegalAgreementController controller = new CreateLegalAgreementController();

        Test.startTest();
        List<SelectOption> legalAgreementsRecordTypes = controller.getLegalAgreementsRecordTypes();
        System.assertNotEquals(null, controller.objectId);
        System.assertNotEquals(null, controller.legalAgreementsRecordTypeId);

        System.assertEquals(true, controller.isValid);        
        System.assertEquals(false, controller.clauseBundleHasYears);        

        pageRef = controller.generateLegalAgreement();
        Test.stopTest();

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        system.debug('msgs size ============='+ msgs.size());
         //system.debug('msgs is ============='+ msgs);
         System.assertEquals(1, msgs.size());

        List<Legal_Agreements__c> legalAgreements = getLegalAgreementsByOpportunity(opportunity.Id);
        System.assertEquals(1, legalAgreements.size());
        Legal_Agreements__c legalAgreement = legalAgreements[0];
        System.assertEquals(opportunity.Id, legalAgreement.Opportunity__c);
        System.assertEquals(opportunity.AccountId, legalAgreement.Account__c);
        System.assertEquals(controller.legalAgreementsRecordTypeId, legalAgreement.RecordTypeId);
        //System.assertEquals(regionName, legalAgreement.Version__c);
    }    
    
    @isTest 
    static void testCreateLegalAgreementFromQuoteWithoutYear() {

        List<SBQQ__Quote__c> testQuotes = getTestQuotes();
        System.assert(testQuotes.size() > 0);
        SBQQ__Quote__c quote = testQuotes[0];

        String regionName = [SELECT Name, Marketo_Entity_Conga__c,Region__c  FROM Country__c where Name = :quote.SBQQ__Account__r.ShippingCountry][0].Region__c;

        PageReference pageRef = Page.CreateLegalAgreement;
        pageRef.getParameters().put('id',quote.Id);
        Test.setCurrentPage(pageRef);     
        CreateLegalAgreementController controller = new CreateLegalAgreementController();

        Test.startTest();
        List<SelectOption> legalAgreementsRecordTypes = controller.getLegalAgreementsRecordTypes();
        System.assert(controller.legalAgreementsRecordTypeId != null);

        System.assertEquals(true, controller.isValid);        
        System.assertEquals(false, controller.clauseBundleHasYears);        

        pageRef = controller.generateLegalAgreement();
        Test.stopTest();

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        system.debug('msgs size1 ============='+ msgs.size());
        System.assertEquals(1, msgs.size());

        List<Legal_Agreements__c> legalAgreements = getLegalAgreementsByQuote(quote.Id);
        System.assertEquals(1, legalAgreements.size());
        Legal_Agreements__c legalAgreement = legalAgreements[0];
        System.assertEquals(quote.Id, legalAgreement.SBQQ_Quote__c);
        System.assertEquals(quote.SBQQ__Opportunity2__c, legalAgreement.Opportunity__c);
        System.assertEquals(quote.SBQQ__Account__c, legalAgreement.Account__c);
        System.assertEquals(controller.legalAgreementsRecordTypeId, legalAgreement.RecordTypeId);
       // System.assertEquals(regionName, legalAgreement.Version__c);
    }

    @isTest
    static void testCreateLegalAgreementFromQuoteWithYear() {

        String year = LegalAgreementsTestDataFactory.getPickListDefaultOrFirstValue(Legal_Agreements__c.Year__c);
        System.assert(year != null);        

        List<SBQQ__Quote__c> testQuotes = getTestQuotes();
        System.assert(testQuotes.size() > 0);
        SBQQ__Quote__c quote = testQuotes[0];

        String regionName = [SELECT Name, Marketo_Entity_Conga__c,Region__c  FROM Country__c where Name = :quote.SBQQ__Account__r.ShippingCountry][0].Region__c;

        PageReference pageRef = Page.CreateLegalAgreement;
        pageRef.getParameters().put('id',quote.Id);
        Test.setCurrentPage(pageRef);     
        CreateLegalAgreementController controller = new CreateLegalAgreementController();

        List<SelectOption> legalAgreementsRecordTypes = controller.getLegalAgreementsRecordTypes();
        System.assert(controller.legalAgreementsRecordTypeId != null);

        String region = LegalAgreementsTestDataFactory.getPickListDefaultOrFirstValue(Legal_Agreements__c.Version__c);
        System.assert(region != null);        

        Integer numClausesPerBundle = 5;
        Boolean isInsuranceExhibit = false;
        Boolean containsSLA = false;
        Id congaTemplate = null;

        Map<Id, String> legalAgreementsRecordTypesForClauseBundles = LegalAgreementsTestDataFactory.getLegalAgreementsRecordTypesMapForClauseBundles();
        LegalAgreementsTestDataFactory.createClauseBundle(legalAgreementsRecordTypesForClauseBundles.get(controller.legalAgreementsRecordTypeId), region, numClausesPerBundle, isInsuranceExhibit, containsSLA, year, congaTemplate);

        List<String> years = controller.clauseBundleYears;
        System.assertEquals(1, years.size());        
        List<SelectOption> yearOptions = controller.getYearsForClauseBundle();
        System.assertEquals(1, yearOptions.size());

        System.assertEquals(true, controller.isValid);        
        System.assertEquals(true, controller.clauseBundleHasYears);        

        Test.startTest();
        pageRef = controller.generateLegalAgreement();
        Test.stopTest();

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        system.debug('msgs size2 ============='+ msgs.size());
        System.assertEquals(1, msgs.size());

        List<Legal_Agreements__c> legalAgreements = getLegalAgreementsByQuote(quote.Id);
        System.assertEquals(1, legalAgreements.size());       
        Legal_Agreements__c legalAgreement = legalAgreements[0];
        System.assertEquals(quote.Id, legalAgreement.SBQQ_Quote__c);
        System.assertEquals(quote.SBQQ__Opportunity2__c, legalAgreement.Opportunity__c);
        System.assertEquals(quote.SBQQ__Account__c, legalAgreement.Account__c);
        System.assertEquals(controller.legalAgreementsRecordTypeId, legalAgreement.RecordTypeId);
        System.assertEquals(yearOptions[0].getValue(), legalAgreement.Year__c);
        // System.assertEquals(regionName, legalAgreement.Version__c);
    }

    @isTest
    static void testPageErrors() {
        List<Account> accounts = new list<Account>(); 
        Account aa = new Account();
        aa.Name = 'testfortest234';
        aa.ShippingCountry = 'USA';
        accounts.add(aa);
        if(accounts!= null){
        insert accounts;
        }
        System.assertEquals(1, accounts.size());

        List<Opportunity> opportunities = LegalAgreementsTestDataFactory.createOpportunities(accounts, 1);
        System.assertEquals(1, opportunities.size());

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

        List<SBQQ__Quote__c> quotes = LegalAgreementsTestDataFactory.createQuotes(opportunities, quoteRecordTypeId);
        System.assertEquals(1, quotes.size());
        SBQQ__Quote__c quote = quotes[0];

        PageReference pageRef = Page.CreateLegalAgreement;
        pageRef.getParameters().put('id',quote.Id);
        Test.setCurrentPage(pageRef);     
        CreateLegalAgreementController controller = new CreateLegalAgreementController();

        List<SelectOption> legalAgreementsRecordTypes = controller.getLegalAgreementsRecordTypes();
        System.assert(controller.legalAgreementsRecordTypeId != null);

        String region = LegalAgreementsTestDataFactory.getPickListDefaultOrFirstValue(Legal_Agreements__c.Version__c);
        System.assert(region != null);        

        Integer numClausesPerBundle = 5;
        Boolean isInsuranceExhibit = false;
        Boolean containsSLA = false;
        Id congaTemplate = null;
        String year = null;

        Map<Id, String> legalAgreementsRecordTypesForClauseBundles = LegalAgreementsTestDataFactory.getLegalAgreementsRecordTypesMapForClauseBundles();
        LegalAgreementsTestDataFactory.createClauseBundle(legalAgreementsRecordTypesForClauseBundles.get(controller.legalAgreementsRecordTypeId), region, numClausesPerBundle, isInsuranceExhibit, containsSLA, year, congaTemplate);

        Test.startTest();
        pageRef = controller.generateLegalAgreement();
        Test.stopTest();

        List<Apexpages.Message> msgs = ApexPages.getMessages();
        for (Apexpages.Message m : msgs) {
            //System.assert(m.getSummary().contains(LegalAgreementsService.ERROR_LEGAL_AGREEMENT_REGION));
        }
    }

    @isTest
    static void testOthers() {
        List<SBQQ__Quote__c> testQuotes = getTestQuotes();
        System.assert(testQuotes.size() > 0);
        SBQQ__Quote__c quote = testQuotes[0];

        PageReference pageRef = Page.CreateLegalAgreement;
        pageRef.getParameters().put('id',quote.Id);
        Test.setCurrentPage(pageRef);     
        CreateLegalAgreementController controller = new CreateLegalAgreementController();

        Test.startTest();
        PageReference valuesChangedPageRef = controller.valuesChanged();
        PageReference cancelPageRef = controller.cancel();
        Test.stopTest();

        System.assertEquals(null, valuesChangedPageRef);
        System.assertNotEquals(null, cancelPageRef);
    }

    
    /********
    Selectors
    *********/
    private static List<SBQQ__Quote__c> getTestQuotes() {
        return [
            SELECT
                Id,
                SBQQ__Account__c,
                SBQQ__Account__r.ShippingCountry,
                SBQQ__Opportunity2__c
            FROM SBQQ__Quote__c
        ];
    }

    private static List<Opportunity> getTestOpportunities() {
        return [
            SELECT
                Id,
                AccountId,
                Account.ShippingCountry
            FROM Opportunity where Account.ShippingCountry!= null
        ];
    }    

    private static List<Legal_Agreements__c> getLegalAgreementsByQuote(Id quoteId) {
        return [
            SELECT
                Id,
                Account__c,                
                Opportunity__c,
                SBQQ_Quote__c,
                RecordTypeId,
                RecordType.Name,
                Version__c,
                Year__c
            FROM Legal_Agreements__c
            WHERE SBQQ_Quote__c = :quoteId
        ];
    }

    private static List<Legal_Agreements__c> getLegalAgreementsByOpportunity(Id opportunityId) {
        return [
            SELECT
                Id,
                Account__c,
                Opportunity__c,
                RecordTypeId,
                RecordType.Name,                
                Version__c,
                Year__c
            FROM Legal_Agreements__c
            WHERE Opportunity__c = :opportunityId
        ];
    }    
    
}