public class LegalAgreementsService {

    /*commented because error move to label
    public static final String ERROR_LEGAL_AGREEMENT_RECORD_TYPE = 'Unable to get legal agreement record type.';
    public static final String ERROR_LEGAL_AGREEMENT_REGION = 'Unable to get the corresponding region.';
   */


    /**************
    Private Methods
    ***************/

    /*
    * @description Returns map for legal agreements id and corresponding clause bundles list.
    */
    private static Map<Id, List<APXT_Redlining__Clause_Bundle__c>> getClauseBundleForLegalAgreements(List<Legal_Agreements__c> legalAgreements) {

        Map<Id, List<APXT_Redlining__Clause_Bundle__c>> legalAgreementsIdToClauseBundleMap = new Map<Id, List<APXT_Redlining__Clause_Bundle__c>>();

        Map<Id, String> legalAgreementsRecordTypeMap = getLegalAgreementsRecordTypes();
        Map<Legal_Agreements__c, String> legalAgreementsToRecordTypeNameMap = new Map<Legal_Agreements__c, String>();
        for (Legal_Agreements__c la : legalAgreements) {
            if (la.RecordTypeId != null) {
                legalAgreementsToRecordTypeNameMap.put(la, legalAgreementsRecordTypeMap.get(la.RecordTypeId));
            }
        }

        if (legalAgreementsToRecordTypeNameMap.isEmpty()) return legalAgreementsIdToClauseBundleMap; 

        List<APXT_Redlining__Clause_Bundle__c> clauseBundlesByLegalAgreementsType = getClauseBundlesByLegalAgreementsType(legalAgreementsToRecordTypeNameMap.values());       

        if (clauseBundlesByLegalAgreementsType.isEmpty()) return legalAgreementsIdToClauseBundleMap;

        Map<String, String> legalAgreementTypeToLatestYearMap = getLegalAgreementTypeNameToLatestYearMap();
        
        for (Legal_Agreements__c la : legalAgreementsToRecordTypeNameMap.keySet()) {
            Integer clauseBundleNumber = 0; // To admit just one bundle. if more than one is admited for the same criteria, remove this variable.
            Integer clauseBundleInsuranceExhibitNumber = 0; // To admit just one insurance exhibit bundle. if more than one is admited for the same criteria, just remove this variable.
            List<APXT_Redlining__Clause_Bundle__c> clauseBundlesForLegalAgreement = new List<APXT_Redlining__Clause_Bundle__c>();                            
            for (APXT_Redlining__Clause_Bundle__c cb : clauseBundlesByLegalAgreementsType) {
                if (clauseBundleNumber < 1 && checkBundleSelectionCriteria(legalAgreementsToRecordTypeNameMap.get(la), la, cb, legalAgreementTypeToLatestYearMap)) {
                    clauseBundlesForLegalAgreement.add(cb);
                    clauseBundleNumber++;
                }
                if (clauseBundleInsuranceExhibitNumber < 1 && checkInsuranceExhibitBundleSelectionCriteria(legalAgreementsToRecordTypeNameMap.get(la), la, cb)) {
                    clauseBundlesForLegalAgreement.add(cb);
                    clauseBundleInsuranceExhibitNumber++;
                }
                if (clauseBundleNumber == 1 && clauseBundleInsuranceExhibitNumber == 1) break;
            }
            if (clauseBundlesForLegalAgreement.size() > 0) legalAgreementsIdToClauseBundleMap.put(la.Id, clauseBundlesForLegalAgreement);
        }

        return legalAgreementsIdToClauseBundleMap;
    }

    /*
    * @description To find version in multiple selection picklist.
    */
    private static Boolean checkVersion(String versionList, String version) {
        if (versionList == null) return false;
        for (String v : versionList.split(';')) {
            if (v == version)
                return true;
        }
        return false;
    }

    /*
    * @description To check criteria for bundle selection that not is an insurance exhibit.
    */
    private static Boolean checkBundleSelectionCriteria(String legalAgreementRecordType, Legal_Agreements__c la, APXT_Redlining__Clause_Bundle__c cb, Map<String, String> legalAgreementTypeToLatestYearMap) {
        Boolean includeYear = false;
        String year = null;
        if (la.Year__c == null && legalAgreementTypeToLatestYearMap.containsKey(legalAgreementRecordType)) {
            includeYear = true;
            year = legalAgreementTypeToLatestYearMap.get(legalAgreementRecordType);
        }
        if (la.Year__c != null && legalAgreementTypeToLatestYearMap.containsKey(legalAgreementRecordType)) {
            includeYear = true;
            year = la.Year__c;
        }
        if (includeYear) {
            Return 
                legalAgreementRecordType == cb.Legal_Agreement_Type__c && 
                checkVersion(cb.Version__c, la.Version__c) && 
                la.Include_SLA__c == cb.Contains_SLA__c && 
                (cb.Is_Insurance_Exhibit__c == null || cb.Is_Insurance_Exhibit__c == false) &&
                cb.Year__c == year;
        }
        else {
            Return 
                legalAgreementRecordType == cb.Legal_Agreement_Type__c && 
                checkVersion(cb.Version__c, la.Version__c) && 
                la.Include_SLA__c == cb.Contains_SLA__c && 
                (cb.Is_Insurance_Exhibit__c == null || cb.Is_Insurance_Exhibit__c == false);
        }
    }

    /*
    * @description To check criteria for bundle selection that is an insurance exhibit.
    */
    private static Boolean checkInsuranceExhibitBundleSelectionCriteria(String legalAgreementRecordType, Legal_Agreements__c la, APXT_Redlining__Clause_Bundle__c cb) {
        Return 
            la.Include_Insurance_Exhibit__c != null && 
            la.Include_Insurance_Exhibit__c && 
            cb.Is_Insurance_Exhibit__c && 
            legalAgreementRecordType == cb.Legal_Agreement_Type__c && 
            checkVersion(cb.Version__c, la.Version__c) && cb.Is_Insurance_Exhibit__c != null;
    }


    /*
    * @description Add to the unit of work the records for managed clauses creation.
    */
    private static void createManagedClauses(Map<Id,Legal_Agreements__c> newLegalAgreementsMap, fflib_SObjectUnitOfWork uow) {
        Map<Id, List<APXT_Redlining__Clause_Bundle__c>> legalAgreementIdToClauseBundlesMap = getClauseBundleForLegalAgreements(newLegalAgreementsMap.values());
        if (legalAgreementIdToClauseBundlesMap.size() == 0) return;

        // get the clauses for the bundles
        Set<Id> clauseBundleIds = new Set<Id>();
        for(Id legalAgreementId : legalAgreementIdToClauseBundlesMap.keySet()) {
            List<APXT_Redlining__Clause_Bundle__c> clauseBundles = legalAgreementIdToClauseBundlesMap.get(legalAgreementId);
            for(APXT_Redlining__Clause_Bundle__c clauseBundle : clauseBundles) {
                clauseBundleIds.add(clauseBundle.Id);
            }

        }

        // get the bundled clauses
        List<APXT_Redlining__Bundle_Clause__c> bundleClauses = getBundleClausesByBundleIds(clauseBundleIds);
        Map<Id,List<APXT_Redlining__Bundle_Clause__c>> clauseIdToBundleClauses = new Map<Id,List<APXT_Redlining__Bundle_Clause__c>>();
        for(APXT_Redlining__Bundle_Clause__c bundleClause : bundleClauses) {
            if(!clauseIdToBundleClauses.containsKey(bundleClause.APXT_Redlining__Clause_Bundle__c)) clauseIdToBundleClauses.put(bundleClause.APXT_Redlining__Clause_Bundle__c, new List<APXT_Redlining__Bundle_Clause__c>());
            clauseIdToBundleClauses.get(bundleClause.APXT_Redlining__Clause_Bundle__c).add(bundleClause);
        }
        
        Map<Id, Id> legalAgreementsIdToCongaTemplateIdMap = New Map<Id, Id>();

        for (Id legalAgreementsId : newLegalAgreementsMap.keySet()) {
            
            List<APXT_Redlining__Clause_Bundle__c> bundles = legalAgreementIdToClauseBundlesMap.get(legalAgreementsId);
            if(bundles == null || bundles.size() == 0) continue;

            Decimal maxBundleClauseOrder = 0;
            String composerTemplate = null;
            Boolean overwriteTemplate = true;
        
            for (APXT_Redlining__Clause_Bundle__c bundle : bundles) {

                List<APXT_Redlining__Bundle_Clause__c> bundledClauses = clauseIdToBundleClauses.get(bundle.Id); 
                if (bundledClauses == null) continue;

                for (APXT_Redlining__Bundle_Clause__c bundledClause : bundledClauses) {

                    if (bundledClause.APXT_Redlining__Order__c > maxBundleClauseOrder) maxBundleClauseOrder = bundledClause.APXT_Redlining__Order__c;

                    APXT_Redlining__Clause__c clause = bundledClause.APXT_Redlining__Clause__r;
                    APXT_Redlining__Managed_Clause__c newClause = new APXT_Redlining__Managed_Clause__c(Parent_aCk__c = legalAgreementsId);
                    if (clause.APXT_Redlining__Latest_Revision__c != null) {
                        newClause.APXT_Redlining__Clause_Revision__c = clause.APXT_Redlining__Latest_Revision__c;               
                        newClause.APXT_Redlining__Latest_Revision_Text__c = clause.APXT_Redlining__Latest_Revision__r.APXT_Redlining__Text__c;
                        newClause.APXT_Redlining__Text_Rich__c = clause.APXT_Redlining__Latest_Revision__r.APXT_Redlining__Text_Rich__c;
                    }

                    newClause.APXT_Redlining__Label__c = clause.Name;                   

                    Decimal bundleClauseOrder = bundledClause.APXT_Redlining__Order__c;
                    if (bundle.Is_Insurance_Exhibit__c != null && bundle.Is_Insurance_Exhibit__c) {
                        maxBundleClauseOrder+=1;
                        bundleClauseOrder = maxBundleClauseOrder;
                    }
                    newClause.APXT_Redlining__Order__c = bundleClauseOrder;
                    
                    uow.registerNew(newClause);
                }

                if (bundle.Conga_Template__c != null && bundle.Is_Insurance_Exhibit__c != null && !bundle.Is_Insurance_Exhibit__c && overwriteTemplate) {
                    composerTemplate = bundle.Conga_Template__c;
                }
                if (bundle.Conga_Template__c != null && bundle.Is_Insurance_Exhibit__c != null && bundle.Is_Insurance_Exhibit__c) {
                    composerTemplate = bundle.Conga_Template__c;                   
                    overwriteTemplate = false;
                }
            }

            if (composerTemplate != null)
                legalAgreementsIdToCongaTemplateIdMap.put(legalAgreementsId, composerTemplate);


            // legalAgreementsIdToNextExhibitLetterMap.put(legalAgreementsId, bundle.Next_Exhibit_Letter__c); // deprecated, for next exhibit letter functionality.
        }

        /* 
        // deprecated, for next exhibit letter functionality.
        if (legalAgreementsIdToNextExhibitLetterMap.size() > 0 ) {
            List<Legal_Agreements__c> legalAgreementsToUpdateNextExhibitLetter = getLegalAgreementsById(legalAgreementsIdToNextExhibitLetterMap.keySet());
            for (Legal_Agreements__c la :legalAgreementsToUpdateNextExhibitLetter) {
                la.Next_Exhibit_Letter__c = legalAgreementsIdToNextExhibitLetterMap.get(la.Id);
            }
            uow.registerDirty(legalAgreementsToUpdateNextExhibitLetter);
        }
        */

        if (legalAgreementsIdToCongaTemplateIdMap.size() > 0) {
            List<Legal_Agreements__c> legalAgreementsToUpdateComposerTemplateId = getLegalAgreementsById(legalAgreementsIdToCongaTemplateIdMap.keySet());
            for (Legal_Agreements__c la :legalAgreementsToUpdateComposerTemplateId) {
                la.Composer_Template_ID__c = legalAgreementsIdToCongaTemplateIdMap.get(la.Id);
            }
            uow.registerDirty(legalAgreementsToUpdateComposerTemplateId);
        }

        
    }

    /*
    * @description Returns map for legal agreements whose manage bundles has to be deleted.
    */
    private static Map<Id, Legal_Agreements__c> getLegalAgreementsMapForManagedBundleDeletion(Map<Id, Legal_Agreements__c> newLegalAgreementsMap, Map<Id, Legal_Agreements__c> oldLegalAgreementsMap) {
        Map<Id, Legal_Agreements__c> legalAgreementsToProcess = new Map<Id, Legal_Agreements__c>();     
        if (oldLegalAgreementsMap == null || oldLegalAgreementsMap.size() == 0) return legalAgreementsToProcess;
        
        Legal_Agreements__c oldLegalAgreement;
        for (Legal_Agreements__c newLegalAgreement : newLegalAgreementsMap.values()) {
            oldLegalAgreement = oldLegalAgreementsMap.get(newLegalAgreement.Id);
            if (newLegalAgreement.RecordType != oldLegalAgreement.RecordType || 
                newLegalAgreement.Version__c != oldLegalAgreement.Version__c ||  
                newLegalAgreement.Include_SLA__c != oldLegalAgreement.Include_SLA__c || 
                newLegalAgreement.Include_Insurance_Exhibit__c != oldLegalAgreement.Include_Insurance_Exhibit__c ||
                newLegalAgreement.Year__c != oldLegalAgreement.Year__c) {
                legalAgreementsToProcess.put(newLegalAgreement.Id, newLegalAgreement);
            }
        }

        return legalAgreementsToProcess;
    }

    /*
    * @description Deletes managed clauses for legal agreements in the set. For use with unit of work. // This is not working well with UOW.
    */
    /*
    private static void deleteManagedClauses(Set<Id> legalAgreementsIds, fflib_SObjectUnitOfWork uow) {
        List<APXT_Redlining__Managed_Clause__c> managedClauses = getManagedClauses(legalAgreementsIds);     
        if (managedClauses.size() > 0) uow.registerDeleted(managedClauses);
    }
    */

    /*
    * @description Builds legal agreement name.
    */
    private static String buildLegalAgreementsName(String recordTypeName, String accountName) {
        String year = String.valueOf(Date.Today().Year());
        return String.Format('{0} - {1} {2}', new String[] {accountName, recordTypeName, year});
    }


    /*
    * @description Clears Next_Exhibit_Letter__c field for Legal_Agreements__c records whose managed clause are deleted. // deprecated, for next exhibit letter functionality.
    */
    /*
    private static void clearLegalAgreementsNextExhibitLetter(Set<Id> legalAgreementsIds, fflib_SObjectUnitOfWork uow) {
        List<Legal_Agreements__c> legalAgreements = getLegalAgreementsById(legalAgreementsIds);
        if (legalAgreements.size() == 0) return;
        for (Legal_Agreements__c la :legalAgreements) {
            la.Next_Exhibit_Letter__c = null;
        }
        uow.registerDirty(legalAgreements);
    }
    */

    /*
    * @description Returns a legal agreement record type name to lastest bundle year map.
    */
    private static Map<String, String> getLegalAgreementTypeNameToLatestYearMap() {
        Map<String, String> legalAgreementTypeNameToLastestYearMap = new Map<String, String>();
        List<APXT_Redlining__Clause_Bundle__c> clauseBundlesWithYear = getClauseBundlesWithYear();
        for (APXT_Redlining__Clause_Bundle__c clauseBundle : clauseBundlesWithYear) {
            if (!legalAgreementTypeNameToLastestYearMap.containsKey(clauseBundle.Legal_Agreement_Type__c)) {
                legalAgreementTypeNameToLastestYearMap.put(clauseBundle.Legal_Agreement_Type__c, clauseBundle.Year__c);
            }
        }
        return legalAgreementTypeNameToLastestYearMap;        
    }

    /*
    * @description 
    */
    private static Set<Id> getObjectIdsForPrefix(String prefix, Set<Id> objectIds) {
        Set<Id> objectIdsForPrefix = new Set<Id>();
        for(Id objectId : objectIds) {
            if(String.valueOf(objectId).startsWith(prefix)) {
                objectIdsForPrefix.add(objectId);
            }
        }

        return objectIdsForPrefix;
    }

    /*************
    Public Methods
    **************/

    /*
    * @description Returns Map containing active and available record types for legal agreements.
    */
    public static Map<Id, String> getLegalAgreementsRecordTypes() {
        Map<Id, String> recordTypeMap = new Map<Id, String>();
        List<Schema.RecordTypeInfo> recordTypeInfos = Schema.SObjectType.Legal_Agreements__c.getRecordTypeInfos();
        for (Schema.RecordTypeInfo rti : recordTypeInfos) {
            if (rti.isActive() && rti.isAvailable()) {
                recordTypeMap.put(rti.getRecordTypeId(), rti.getName());
            }
        }
        return recordTypeMap;
    }

    /*
    * @description Deletes managed clauses for legal agreements in the set. For use directly from trigger.
    */
    public static void deleteManagedClauses(Set<Id> legalAgreementsIds) {
        List<APXT_Redlining__Managed_Clause__c> managedClauses = getManagedClauses(legalAgreementsIds);
        if (managedClauses.size() > 0) delete managedClauses;
    }

    /*
    * @description Process legal agreements for managed clauses creation/deletion. This is the main method called from trigger.
    */
    public static void processManagedClausesForLegalAgreements(Map<Id,Legal_Agreements__c> newLegalAgreementsMap, Map<Id,Legal_Agreements__c> oldLegalAgreementsMap) {

        Map<Id,Legal_Agreements__c> legalAgreementsMapsToDeleteManagedClauses = null;
        if (oldLegalAgreementsMap != null && oldLegalAgreementsMap.size() > 0) {
            legalAgreementsMapsToDeleteManagedClauses = getLegalAgreementsMapForManagedBundleDeletion(newLegalAgreementsMap, oldLegalAgreementsMap);        
        }
        
        fflib_SObjectUnitOfWork uow = new fflib_SObjectUnitOfWork(
            new Schema.SObjectType[] {
                APXT_Redlining__Managed_Clause__c.SObjectType,
                APXT_Redlining__Managed_Clause_Revision__c.SObjectType,
                Legal_Agreements__c.SObjectType
            }
        );

        SavePoint sp = Database.setSavePoint();
        try {
            if (oldLegalAgreementsMap != null && oldLegalAgreementsMap.size() > 0) {
                if (legalAgreementsMapsToDeleteManagedClauses != null && legalAgreementsMapsToDeleteManagedClauses.size() > 0 ) {
                    deleteManagedClauses(legalAgreementsMapsToDeleteManagedClauses.keySet());
                    createManagedClauses(legalAgreementsMapsToDeleteManagedClauses, uow);
                }
            }
            else {
                createManagedClauses(newLegalAgreementsMap, uow);
            }
            
            uow.commitWork();
        } 
        catch (Exception e) {
            Database.rollback(sp);
            throw e;
        }       
    }

    /*
    * @description Returns a Map that contains the legal agreements generation information for each quote/opportunity. This info includes legal agreement Id and possible error message. For use from page.
    ** This is what actually creates the Legal Agreements from the VF page **
    */
    public static Map<Id, LegalAgreementCreationInfo> generateLegalAgreement(Map<Id, LegalAgreementRecordTypeExtendedInfo> objectIdToLegalAgreementRecordTypeExtendedInfoMap) {
        Map<Id, LegalAgreementCreationInfo> objectIdToLegalAgreementCreationInfoMap  = new Map<Id, LegalAgreementCreationInfo>();

        Map<Id, String> objectIdToShipingCountryMap = New Map<Id, String>();
        Map<Id, String> objectIdToAccountNameMap = New Map<Id, String>();

        // get the quotes
        Set<Id> quoteIds = getObjectIdsForPrefix(SObjectType.SBQQ__Quote__c.keyPrefix, objectIdToLegalAgreementRecordTypeExtendedInfoMap.keySet());                
        Map<Id,SBQQ__Quote__c> quotes = new Map<Id,SBQQ__Quote__c>(getQuotesByIds(quoteIds));
        for (SBQQ__Quote__c q : quotes.values()) {
          // Add check if Account is null it will show error as per the ticket APPS-23175
            if(q.SBQQ__Account__c != null){
                if (q.SBQQ__Account__r.ShippingCountry != null) {
                    String country = q.SBQQ__Account__r.ShippingCountry;
                    String accountName = q.SBQQ__Account__r.Name;
                    objectIdToShipingCountryMap.put(q.Id, country.toLowerCase());
                    objectIdToAccountNameMap.put(q.Id, accountName);
                }
            }
            else{
                 q.addError(label.Legal_Agreement_name_cannot_be_created);
            }
        }

        // get the opportunities
        Set<Id> opportunityIds = getObjectIdsForPrefix(SObjectType.Opportunity.keyPrefix, objectIdToLegalAgreementRecordTypeExtendedInfoMap.keySet());                
        Map<Id,Opportunity> opportunities = new Map<Id,Opportunity>(getOpportunityByIds(opportunityIds));
        for (Opportunity o : opportunities.values()) {
          // Add check if Account is null it will show error as per the ticket APPS-23175
            if(o.Account != null){
                if (o.Account.ShippingCountry != null) {
                    String country = o.Account.ShippingCountry;
                    String accountName = o.Account.Name;
                    objectIdToShipingCountryMap.put(o.Id, country.toLowerCase());
                    objectIdToAccountNameMap.put(o.Id, accountName);
                }
            }
            else{
                o.adderror(label.Legal_Agreement_name_cannot_be_created);
            }
        }

        // map the Account shipping country names to a record in the Country object
        Map<String, Country__c> countryMap = getCountryMap(new Set<String>(objectIdToShipingCountryMap.values()));

        // get the record types
        List<LegalAgreementRecordTypeExtendedInfo> infos = objectIdToLegalAgreementRecordTypeExtendedInfoMap.Values();
        List<Id> recordTypeIds = new List<Id>();
        for (LegalAgreementRecordTypeExtendedInfo info : infos) {
            recordTypeIds.add(info.legalAgreementRecordTypeId);
        }
        Map<Id, RecordType> recordTypesMap = getRecordTypesMapByIds(recordTypeIds);

        List<Legal_Agreements__c> legalAgreements = new List<Legal_Agreements__c>();

        for (Id objectId : objectIdToLegalAgreementRecordTypeExtendedInfoMap.keySet()) {            
            LegalAgreementRecordTypeExtendedInfo extendedInfo = objectIdToLegalAgreementRecordTypeExtendedInfoMap.get(objectId);
            Id legalAgreementRecordTypeId = extendedInfo.legalAgreementRecordTypeId;
            String recordTypeYear = extendedInfo.year;
            //pull the region and legalEntity from the matching Country record
            System.debug('objectIdToShipingCountryMap' + objectIdToShipingCountryMap);
            System.debug('countryMap' + countryMap);
            String region = countryMap.get(objectIdToShipingCountryMap.get(objectId)).Marketo_Entity_Conga__c;
            String legalEntity = countryMap.get(objectIdToShipingCountryMap.get(objectId)).Marketo_Entity__c;
            String accountName = objectIdToAccountNameMap.get(objectId).abbreviate(50);
            
            //generate name
            if (legalAgreementRecordTypeId != null && region != null) {
                String recordTypeName = recordTypesMap.get(legalAgreementRecordTypeId).Name;
                String legalAgreementName = buildLegalAgreementsName(recordTypeName, accountName);

                //generate new Legal Agreement and populate field values 
                Legal_Agreements__c newla = new Legal_Agreements__c(                    
                    Name = legalAgreementName,
                    Version__c = region,
                    RecordTypeId = legalAgreementRecordTypeId,
                    Marketo_Legal_Entity__c = legalEntity
                );
                if(String.valueOf(objectId).startsWith(SObjectType.SBQQ__Quote__c.keyPrefix)) { // is quote
                    SBQQ__Quote__c quote = quotes.get(objectId);
                    newLa.Account__c = quote.SBQQ__Account__c;
                    newLa.SBQQ_Quote__c = quote.Id;
                    newLa.Opportunity__c = quote.SBQQ__Opportunity2__c;
                }
                else if(String.valueOf(objectId).startsWith(SObjectType.Opportunity.keyPrefix)) { // is opportunity
                    Opportunity opportunity = opportunities.get(objectId);
                    newLa.Account__c = opportunity.AccountId;
                    newLa.Opportunity__c = opportunity.Id;
                }
                if (recordTypeYear != null){
                    newLa.Year__c = recordTypeYear;
                }
                legalAgreements.add(newla);
            }
            //If the record type or region are null, the Legal Agreement will not create and an error message will show
            else {
                String errorMessage = null;
                if (legalAgreementRecordTypeId == null) 
                    errorMessage = Label.ERROR_LEGAL_AGREEMENT_RECORD_TYPE;
                if (region == null)
                 errorMessage = errorMessage == null ?  Label.ERROR_LEGAL_AGREEMENT_REGION : errorMessage + '\n' + Label.ERROR_LEGAL_AGREEMENT_REGION;                objectIdToLegalAgreementCreationInfoMap.put(objectId, new LegalAgreementCreationInfo(null, errorMessage));
            }
        }

        if (legalAgreements.isEmpty()) return objectIdToLegalAgreementCreationInfoMap;

        SavePoint sp = Database.setSavePoint();
        try {
            insert legalAgreements;
        } 
        catch (Exception e) {
            Database.rollback(sp);
            throw e;
        }               

        for (Legal_Agreements__c la : legalAgreements) {
            if(la.SBQQ_Quote__c != null)
                objectIdToLegalAgreementCreationInfoMap.put(la.SBQQ_Quote__c, new LegalAgreementCreationInfo(la.Id, null));
            else if(la.Opportunity__c != null)
                objectIdToLegalAgreementCreationInfoMap.put(la.Opportunity__c, new LegalAgreementCreationInfo(la.Id, null));
        }

        return objectIdToLegalAgreementCreationInfoMap;
    }

    /***************
    Internal Classes
    ****************/
    
    public class LegalAgreementCreationInfo {
        public Id legalAgreementId {get; set;}
        public String errorMessage {get; set;}

        public LegalAgreementCreationInfo(Id laId, String errMessage) {
            this.legalAgreementId = laId;
            this.errorMessage = errMessage;
        }

        public LegalAgreementCreationInfo() {
            this.legalAgreementId = null;
            this.errorMessage = null;
        }
    }

    public class LegalAgreementRecordTypeExtendedInfo {
        public Id legalAgreementRecordTypeId {get; set;}
        public String year {get; set;}

        public LegalAgreementRecordTypeExtendedInfo(Id recordTypeId, String yearValue) {
            this.legalAgreementRecordTypeId = recordTypeId;
            this.year = yearValue;
        }

        public LegalAgreementRecordTypeExtendedInfo() {
            this.legalAgreementRecordTypeId = null;
            this.year = null;
        }
    }

    /********
    Selectors
    *********/
    private static List<APXT_Redlining__Managed_Clause__c> getManagedClauses(Set<Id> legalAgreementsIds) {
        return [
            SELECT Id
              FROM APXT_Redlining__Managed_Clause__c
             WHERE Parent_aCk__c IN :legalAgreementsIds];
    }

    private static List<APXT_Redlining__Clause_Bundle__c> getClauseBundlesByLegalAgreementsType(List<String> legalAgreementsTypes)  {
        return [
            SELECT 
                Id, 
                Legal_Agreement_Type__c, 
                Version__c, 
                Contains_SLA__c, 
                Is_Insurance_Exhibit__c,
                // Next_Exhibit_Letter__c, // deprecated, for next exhibit letter functionality.
                Conga_Template__c,
                Year__c
            FROM APXT_Redlining__Clause_Bundle__c
            WHERE Legal_Agreement_Type__c IN :legalAgreementsTypes
            ORDER BY Legal_Agreement_Type__c,Is_Insurance_Exhibit__c
        ];            
    }

    private static List<APXT_Redlining__Bundle_Clause__c> getBundleClausesByBundleIds(Set<Id> bundleIds)  {
        return [
            SELECT
                Id,
                APXT_Redlining__Clause__c,
                APXT_Redlining__Clause_Bundle__c,
                APXT_Redlining__Clause__r.Name, 
                APXT_Redlining__Clause__r.APXT_Redlining__Latest_Revision__c, 
                APXT_Redlining__Clause__r.APXT_Redlining__Latest_Revision__r.APXT_Redlining__Text__c,
                APXT_Redlining__Clause__r.APXT_Redlining__Latest_Revision__r.APXT_Redlining__Text_Rich__c,
                APXT_Redlining__Clause__r.APXT_Redlining__Text__c, 
                APXT_Redlining__Clause__r.APXT_Redlining__Text_Rich__c,
                APXT_Redlining__Order__c
            FROM APXT_Redlining__Bundle_Clause__c
            WHERE APXT_Redlining__Clause_Bundle__c IN :bundleIds
        ];           
    }

    private static List<Legal_Agreements__c> getLegalAgreementsById(Set<Id> legalAgreementsIds) {
        return [
            SELECT 
                Id,
                Composer_Template_ID__c             
            FROM Legal_Agreements__c
            WHERE Id IN :legalAgreementsIds
        ];
    }

    private static List<SBQQ__Quote__c> getQuotesByIds (Set<Id> quoteIds) {
        return [
            SELECT
                Id,
                SBQQ__Account__c,
                SBQQ__Account__r.ShippingCountry,
                SBQQ__Account__r.Name,
                SBQQ__Opportunity2__c
            FROM SBQQ__Quote__c
            WHERE Id IN :quoteIds
        ];
    }

    private static List<Opportunity> getOpportunityByIds (Set<Id> opportunityIds) {
        return [
            SELECT
                Id,
                AccountId,
                Account.ShippingCountry,
                Account.Name
            FROM Opportunity
            WHERE Id IN :opportunityIds
        ];
    }

    public static Map<String, Country__c> getCountryMap(Set<String> countries) {
        
        Map<String, Country__c> countryMap = new Map<String, Country__c>();

        //get all the records from the Country object
        List<Country__c> countryList = [
            SELECT
                Name,
                Marketo_Entity_Conga__c,
                Marketo_Entity__c
            FROM Country__c 
        ];
        //map the Countries to the names provided - these will match Account shipping country names
        if(!countryList.isEmpty()){
            for(String country : countries) {
                for (Country__c ctr : countryList) {
                    if(country.equalsIgnoreCase(ctr.Name)) {
                        countryMap.put(ctr.Name.toLowerCase(), ctr);
                    }
                }
            }
        }
        return countryMap;
    }

    public static Map<Id, RecordType> getRecordTypesMapByIds(List<Id> recordTypeIds) {
        return new Map<Id, RecordType>([
            SELECT 
                Id, 
                Name 
            FROM RecordType 
            WHERE Id IN :recordTypeIds
        ]);
    }    

    private static List<APXT_Redlining__Clause_Bundle__c> getClauseBundlesWithYear() {
        return [
            SELECT 
                Legal_Agreement_Type__c,
                Year__c
            FROM APXT_Redlining__Clause_Bundle__c
            WHERE Year__c != null
            ORDER BY Year__c DESC
        ];
    }
}