@isTest
public class LegalAgreementsTestDataFactory {   

    /***************
    Internal Classes
    ****************/
    public class PickListInfo {
        public List<String> values {get; set;}
        public String defaultValue {get; set;}

        public picklistInfo(List<String> picklistValues, String defValue) {
            values = picklistValues;
            defaultValue = defValue;
        }
    }    

    /*************
    Public Methods
    **************/
    public static PickListInfo getPickListInfo(SObjectField field) {
        String defaultValue = null;        
        List<String> pickListValuesList = new List<String>();
        Schema.DescribeFieldResult fieldResult = field.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        for (Schema.PicklistEntry pickListVal : ple) {
            if (pickListVal.isDefaultValue()) defaultValue = pickListVal.getLabel();
            pickListValuesList.add(pickListVal.getLabel());
        }
        return new PickListInfo(pickListValuesList, defaultValue);
    }    

    public static String getPickListDefaultOrFirstValue(SObjectField field) {

        PickListInfo plInfo = getPickListInfo(field);
        if (plInfo == null || (plInfo.defaultValue == null && plInfo.values.IsEmpty())) 
            return null;

        if (plInfo.defaultValue != null) 
            return plInfo.defaultValue;
        else
            return plInfo.values[0];
    }

    public static Map<Id, RecordTypeInfo> getObjectActiveAvailableRecordTypesMap(DescribeSObjectResult objectResult) {
        Map<Id, RecordTypeInfo> recordTypeIdToRecordTypeInfoMap = new Map<Id, RecordTypeInfo>();
        List<Schema.RecordTypeInfo> recordTypeInfos = objectResult.getRecordTypeInfos();
        system.debug('recordTypeInfo==========' +recordTypeInfos);
        for (Schema.RecordTypeInfo rti : recordTypeInfos) {
            if (rti.isActive() && rti.isAvailable()) {
                recordTypeIdToRecordTypeInfoMap.put(rti.getRecordTypeId(), rti);
            }
        }
        return recordTypeIdToRecordTypeInfoMap;
    }

    public static Map<Id, String> getLegalAgreementsRecordTypesMapForClauseBundles() {

        Map<Id, RecordTypeInfo> recordTypeIdToNameMap = getObjectActiveAvailableRecordTypesMap(Schema.SObjectType.Legal_Agreements__c);
        PickListInfo legalAgreementTypePickListInfo = getPickListInfo(APXT_Redlining__Clause_Bundle__c.Legal_Agreement_Type__c);

        Map<Id, String> returnMap = new Map<Id, String>();
        for (Id recordTypeId : recordTypeIdToNameMap.keySet()) {
            String recordTypeName = recordTypeIdToNameMap.get(recordTypeId).getName();
            for (String name : legalAgreementTypePickListInfo.values) {
                if (recordTypeName  == name) {
                    returnMap.put(recordTypeId, recordTypeName)                    ;
                }
            }
        }

        return returnMap;
    }
   
    public static void createClauseBundle(String legalAgreementType, String versions, Integer numClausesPerBundle, Boolean isInsuranceExhibit, Boolean containsSLA, String year, Id congaTemplate) {

        if (numClausesPerBundle == 0) return;

        // Create clauses
        List<APXT_Redlining__Clause__c> clauses = new List<APXT_Redlining__Clause__c>();
        for (Integer i = 0; i < numClausesPerBundle; i++) {
            Integer o = i + 1;            
            APXT_Redlining__Clause__c clause = new APXT_Redlining__Clause__c(
                Name = 'Test Clause ' + o,
                APXT_Redlining__Text__c = 'Test Clause Text',
                APXT_Redlining__Text_Rich__c = 'Test Clause Text',
                Regional_vs_Universal__c = 'Universal'
            );
            clauses.add(clause);
        }
        insert clauses;

        // Create clause bundle
        APXT_Redlining__Clause_Bundle__c clauseBundle = new APXT_Redlining__Clause_Bundle__c(
            Name = 'Test Clause Bundle',
            Legal_Agreement_Type__c = legalAgreementType,
            Version__c = versions,
            Is_Insurance_Exhibit__c = isInsuranceExhibit,
            Contains_SLA__c = containsSLA,
            Year__c = year,
            Conga_Template__c = congaTemplate
        );
        insert clauseBundle;

        // Create bundled clauses
        List<APXT_Redlining__Bundle_Clause__c> bundledClauses = new List<APXT_Redlining__Bundle_Clause__c>();
        Integer order = 0;
        for (APXT_Redlining__Clause__c clause : clauses) {
            APXT_Redlining__Bundle_Clause__c bc = new APXT_Redlining__Bundle_Clause__c(
                APXT_Redlining__Clause_Bundle__c = clauseBundle.Id, 
                APXT_Redlining__Clause__c = clause.Id,
                APXT_Redlining__Order__c = order++
            );
            bundledClauses.add(bc);
        }
        insert bundledClauses;
    }

    public static List<Account> createAccounts(Integer numAccounts, String shippingCountry) {        

        List<Account> accounts = new List<Account>();
        for (Integer i = 0; i < numAccounts; i++) {
            accounts.add(new Account(
                Name = 'Test Account ' + i,
                ShippingCountry = shippingCountry
            ));
        }
        if (!accounts.isEmpty()) insert accounts;
        return accounts;
    }

    public static List<Opportunity> createOpportunities(List<Account> accounts, Integer numOpportunities) {
       
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Account account : accounts) {
            for (Integer i = 0; i < numOpportunities; i++) {
                Opportunity opp = new Opportunity(
                    Name = String.Format('{0} Opp. # {1}', new String[] {account.Name, String.valueOf(i)}),
                    AccountId = account.Id,
                    Rep_Create_ARR__c = 100000,
                    StageName = getPickListDefaultOrFirstValue(Opportunity.StageName),
                    CloseDate = System.today(),
                    MainCompetitor__c = getPickListDefaultOrFirstValue(Opportunity.MainCompetitor__c)
                );
                opportunities.add(opp);
            }
        }
        if (!opportunities.isEmpty()) insert opportunities;
        return opportunities;
    }

    public static List<SBQQ__Quote__c> createQuotes(List<Opportunity> opportunities, Id quoteRecordTypeId) {
        List<SBQQ__Quote__c> quotes = new List<SBQQ__Quote__c>();
        for (Opportunity opp : opportunities) {
            SBQQ__Quote__c myQuote = new SBQQ__Quote__c(
                RecordTypeId = quoteRecordTypeId,
                SBQQ__Account__c = opp.AccountId,
                SBQQ__Opportunity2__c = opp.Id,
                SBQQ__StartDate__c = System.today()
            );
            quotes.add(myQuote);
        }
        if (!quotes.isEmpty()) insert quotes;
        return quotes;
    }

    public static List<APXTConga4__Conga_Template__c> createCongaTemplates(String congaTemplateType, Integer numTemplates) {
        List<APXTConga4__Conga_Template__c> congaTemplates = new List<APXTConga4__Conga_Template__c>();
        for (Integer i = 0; i < numTemplates; i++) {
            congaTemplates.add(
                new APXTConga4__Conga_Template__c(
                    APXTConga4__Name__c = 'Test Template ' + i,
                    APXTConga4__Template_Type__c = congaTemplateType
                )
            );
        }
        if (!congaTemplates.isEmpty()) insert congaTemplates;
        return congaTemplates;
    }

}