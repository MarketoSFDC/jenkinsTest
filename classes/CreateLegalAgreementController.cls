public with sharing class CreateLegalAgreementController {
    @TestVisible private final Id objectId;

   /* commented because error move tgo custom label
    public final String UNABLE_TO_CREATE_LA = 'Unable to create legal agreement.';
    public final String UNABLE_TO_CREATE_LA_REASON = 'Unable to create legal agreement. Reason: ';    
   */  

    public Id legalAgreementsRecordTypeId {get; set;}
    public String clauseBundleYear {get; set;}

    /**********
    Constructors
    ***********/
    public CreateLegalAgreementController() {
        objectId = ApexPages.currentPage().getParameters().get('id');
        this.clauseBundleYear = null;
    }

    /****************
    Public Properties
    *****************/
    public List<SelectOption> getLegalAgreementsRecordTypes() {
        List<SelectOption> recordTypes = new List<SelectOption>();
        for (RecordType rt : recordTypesForLegalAgreements) {
            recordTypes.Add(new SelectOption(rt.Id, rt.Name));
        }
        return recordTypes;
    }

    public List<SelectOption> getYearsForClauseBundle() {
        List<SelectOption> years = new List<SelectOption>();        
        for (String year : clauseBundleYears) {
            years.Add(new SelectOption(year, year));
        }
        return years;
    }

    public Boolean isValid {
        get {
            return this.objectId != null && this.legalAgreementsRecordTypeId != null;
        }
    }

    public Boolean clauseBundleHasYears {
        get {
            return !clauseBundleYears.isEmpty();
        }
    }

    /*************
    Public Methods
    **************/
    public PageReference generateLegalAgreement() {
        try {

            Map<Id, LegalAgreementsService.LegalAgreementRecordTypeExtendedInfo> objectIdToLegalAgreementRecordTypeExtendedInfoMap = new Map<Id, LegalAgreementsService.LegalAgreementRecordTypeExtendedInfo>();
            LegalAgreementsService.LegalAgreementRecordTypeExtendedInfo extendedInfo = new LegalAgreementsService.LegalAgreementRecordTypeExtendedInfo();
            extendedInfo.legalAgreementRecordTypeId = this.legalAgreementsRecordTypeId;
            if (this.clauseBundleYear != null) extendedInfo.year = this.clauseBundleYear;
            objectIdToLegalAgreementRecordTypeExtendedInfoMap.put(objectId, extendedInfo);

            Map<Id, LegalAgreementsService.LegalAgreementCreationInfo> objectIdToLegalAgreementCreationInfoMap = LegalAgreementsService.generateLegalAgreement(objectIdToLegalAgreementRecordTypeExtendedInfoMap);

            if (objectIdToLegalAgreementCreationInfoMap.IsEmpty()) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, Label.UNABLE_TO_CREATE_LA));
            }
            else if (objectIdToLegalAgreementCreationInfoMap.get(objectId).legalAgreementId == null ) {
                ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, String.Format(Label.UNABLE_TO_CREATE_LA_REASON, new String[] {objectIdToLegalAgreementCreationInfoMap.get(objectId).errorMessage})));           
            }
            else {
                return new PageReference('/' + objectIdToLegalAgreementCreationInfoMap.get(objectId).legalAgreementId);
            }
        }
        catch (Exception e) {
             ApexPages.addMessage(new ApexPages.message(ApexPages.Severity.ERROR, String.Format(Label.UNABLE_TO_CREATE_LA_REASON, new String[] {e.getMessage()})));
        }
        return null;
    }    

    public PageReference valuesChanged() {
        return null;
    }

    public PageReference cancel() {
        return new PageReference('/' + objectId);
    }    

    /********
    Selectors
    *********/
    public List<RecordType> recordTypesForLegalAgreements {
        get {
            if(recordTypesForLegalAgreements == null) {            
                List<Id> recordTypeIds = new List<Id>();
                List<Schema.RecordTypeInfo> recordTypeInfos = Schema.SObjectType.Legal_Agreements__c.getRecordTypeInfos();
                for (Schema.RecordTypeInfo rti : recordTypeInfos) {
                    if (rti.isActive() && rti.isAvailable()) {
                        recordTypeIds.add(rti.getRecordTypeId());
                        if (rti.isDefaultRecordTypeMapping()) this.legalAgreementsRecordTypeId = rti.getRecordTypeId();
                    }
                }
                if (recordTypeIds.size() > 0 ) {
                    recordTypesForLegalAgreements = [
                        SELECT 
                            Id, 
                            Name, 
                            Description 
                        FROM RecordType 
                        WHERE Id IN :recordTypeIds];
                }
                else
                    recordTypesForLegalAgreements = new List<RecordType>();
            }
            return recordTypesForLegalAgreements;
        }
        private set;
    }

    public List<String> clauseBundleYears {
        get {
            clauseBundleYears = new List<String>();
            if (this.legalAgreementsRecordTypeId != null) {
                Map<Id, RecordType> legalAgreementsRecordTypeMap = LegalAgreementsService.getRecordTypesMapByIds(new List<Id> {this.legalAgreementsRecordTypeId});
                if (!legalAgreementsRecordTypeMap.isEmpty()) {
                    RecordType legalAgreementRecordType = legalAgreementsRecordTypeMap.get(this.legalAgreementsRecordTypeId);
                    if (legalAgreementRecordType != null) {
                        List<APXT_Redlining__Clause_Bundle__c> clauseBundles = [
                            SELECT 
                                Id, 
                                Year__c
                            FROM APXT_Redlining__Clause_Bundle__c 
                            WHERE 
                                Legal_Agreement_Type__c = :legalAgreementRecordType.Name AND 
                                Year__c != NULL
                            ORDER BY Year__c DESC];
                        if (!clauseBundles.isEmpty()) {
                            this.clauseBundleYear = clauseBundles[0].Year__c;
                            for (APXT_Redlining__Clause_Bundle__c clauseBundle : clauseBundles) {
                                clauseBundleYears.add(clauseBundle.Year__c);
                            }
                        }
                    }
                }
            }
            return clauseBundleYears;
        }
        private set;
    }
}