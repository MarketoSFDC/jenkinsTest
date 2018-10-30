/*******Class CaseHandler******
##1. Trigger Handler for the Case SObject. This class implements the ITrigger 
##2.interface to help ensure the trigger code is bulkified and all in one place.  
*/
public class CaseHandler implements ITrigger {   
    //static variables
    public static Boolean isUpdatingCase                                =     false;
    private static Boolean isBeforeInsertProcessing                     =     false;    
    private static Boolean isAfterInsertProcessing                      =     false;    
    private static Boolean isBeforeInsertProcessing2                    =     false;
    public static Boolean firstRunSendInitialResponseNotificationtoTSE  =     True;
    public static Boolean isInsertingNewCase                            =     false;
    public static Boolean IsNonAuthCase                                 =     false;
    
    //member variables  
    private Boolean isPrimary                                       =     false;
    private Boolean isSecondary                                     =     false;   
    Map<Id,Id> myNonP1CaseToEntIdMap                                =     new Map<Id,Id>();    
    Map<Id, String> SituationEmailToCase                            =     new Map<Id, String>(); 
    private List<Case> m_NewCases                                   =     new List<Case>();
    private Set<Id> closeResMileStoneCaseIds                        =     new Set<Id>();
    private Set<Id> closeFirRMileStoneCaseIds                       =     new Set<Id>();
    private List<Case_Update_Milestones__c> milestonesToBeUpsert    =     new List<Case_Update_Milestones__c>(); 
    private List<case> CaseListtobeUpdated                          =     new List<case>(); 
    private map<id, date> caseTargetDateMap                         =     new map<id, date>();
    private Map<case, id> EltPrmCaseAndEntMap                       =     new Map<case, id>();
    private List<Account> acList                                    =     new List<Account>();
    Private case ProactiveMonitoringCase;
    private Map<String, List<String>> languageToCaseIdMap; //For CSAT Survey
    //private CaseTriggerFunction.caseIdToBusinessHrsMap cID;
    //private CaseTriggerFunction.caseAstEntAuthRedirect caseConfig;
    private List<Case> setValidValuesForSalesCases;
    private Map<String,List<JBCXM__Alert__c>> recordsToReturn = new Map<String,List<JBCXM__Alert__c>>();
    //private CaseComment CCom;        
    public static Boolean isInsertingCComment = false;
    //private List<CaseComment> insertSmDetailComment;  
    private List<CaseComment> insertCaseComment = new list<CaseComment>();
    public List<Case> NeedsReplyNotificationCases = new List<Case>(); 
    public List<Case> updateTier3ForClosedParent= new List<Case>(); 
    public List<Case_OwnerShip_History__c> CreateOwerHistroy = new List<Case_OwnerShip_History__c>();
    public List<Case> ifRequestManagerReviewChecked = new List<Case>();
    public List<Case> CasesOpenedForSecondTimeList= new List<Case>();
    Map<Id,List<EWSUtility.activityInfoWrapper>> accountIdsForEWSMap = new Map<Id,List<EWSUtility.activityInfoWrapper>>();
    public List<Case> updateJiraInfoTier3 = new List<Case>();
    public List<CaseComment> addCaseCommentTotier3Parent= new List<CaseComment>();
    public List<case> updateStatusToNeedsReplytier3Parent= new List<case>();
    public List<case> tierFieldUpdateCases = new List<case>();
    public List<case> sslCaseToInsert = new List<case>();
    public List<case> tier3CaseListtobeUpdated                          =     new List<case>();
    public List<CaseTeamTemplateRecord> insertCaseTeam=     new List<CaseTeamTemplateRecord>();
    public List<Case_Update_Milestones__c> cmToComplete = new List<Case_Update_Milestones__c>();
    public List<Case_Update_Milestones__c> newMilestoneToUpsert = new List<Case_Update_Milestones__c>();
    
    // Constructor
    public CaseHandler() {
        System.debug('CaseHandler Constructor Called==>');
        if(isBeforeInsertProcessing == false){
            isPrimary = true;
            isBeforeInsertProcessing = true;
        } 
        else if(isBeforeInsertProcessing2 == false && isSecondary == false){
            isSecondary = true;
            isBeforeInsertProcessing2 = true;
        }        
    }

    /** bulkBefore ** This method is called prior to execution of a BEFORE trigger. Use this to cache * any data required into maps prior execution of the trigger.*/
    public void bulkBefore() {
        System.Debug('bulkBefore called for isPrimary ======> ' + isPrimary);
        if(isPrimary != true) return;        
        
        if (Trigger.isDelete) {
            System.debug('bulkBefore Delete Called==>');
        } 
        if (Trigger.IsInsert) {
            try {    
                set<string> caseEmail  = new set<string>();
                for (Sobject tmoObj : trigger.new){
                    Case c = (case)tmoObj;
                    if(c.SuppliedEmail != null && (c.recordtypeId == label.DLVR_Cases_RecordType || c.recordtypeId == label.SIServiceRequestRecordType || c.recordTypeId == Label.tier3RecordTypeId)){
                        caseEmail.add(c.SuppliedEmail);
                    }
                }
                if(caseEmail != null && caseEmail.IsEmpty()==False){
                    map<String,Id> uMap = new map<String,Id>();
                    for(user usr :[select id, email from user where email =: caseEmail limit 1]){
                        uMap.put(usr.email, usr.id);       
                    }
                    for (Sobject tmoObj : trigger.new){
                        Case c = (case)tmoObj;
                        if( c.SuppliedEmail != null && uMap.containskey(c.SuppliedEmail) ){
                            c.Requester_Name__c = uMap.get(c.SuppliedEmail);
                        }
                    }
                }       
            } catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}    
        } 
       
        System.debug('bulkBefore Called==>' + isBeforeInsertProcessing);
        isBeforeInsertProcessing = true;
        //Apex Case Validtaion Rules   
        if (Trigger.isDelete == False) {                  
            CaseTriggerFunction.validationOnCaseCheck();                      
        }
        
        try {    
            if(Trigger.isInsert && (label.enableEscalManAutoAsmt=='Yes' || test.IsrunningTest()) ){
                CaseTriggerFunction.escalCaseRedistributionToManager();
            }       
        } catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        
        try {    
            if((Trigger.isUpdate && Support_Switches__c.getInstance('AfterHoursRedistribution') != null && Support_Switches__c.getInstance('AfterHoursRedistribution').isActive__c == 'Yes') || (test.IsrunningTest() && Trigger.isUpdate)){
                CaseTriggerFunctionUpdated.AfterHoursRedistribution();
            }       
        } catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        
        //Add Asset Entitlement to case module starts
        if(Trigger.isInsert || Trigger.isUpdate){
        system.debug('-------Inside Case Handler--------');
            try{CaseTriggerFunction.upDateBusinessHours();} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}  
            try{EWSUtility.eWSEscalatedToSMEchecked();} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}  
            try{CaseTriggerFunction.parseEmailCCList();} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        }
        //Add Asset Entitlement to case module ends
        if(Trigger.isUpdate) {                   
            try{CaseTriggerFunction.UpdateP1ServiceRestoredTimeDuration();} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            try{
                if(label.P1CaseRedistributionEnabled == 'Yes' || test.IsrunningTest() ){
                    CaseTriggerFunction.P1CaseRedistribution();
                }
            } catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        }
                        
        if(Trigger.isUpdate || Trigger.isDelete) {            
            recordsToReturn = CaseTriggerFunction.GainsightCaseTrigger(); 
            if(Trigger.isUpdate) { 
                try{
                    for(SObject sObj: Trigger.New){
                        Case cse = (Case)sObj;
                        if(cse.LastModifiedById == cse.OwnerId && cse.RecordTypeId == label.tier3FullRecordTypeId){
                            cse.Last_Updated_by_Owner__c = System.now();
                        }
                    }
                }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}    
            }                                                            
        } 
        if(Trigger.isbefore && Trigger.isInsert) {  
            system.debug('my method called===>'); 
            try{ 
                if(label.ProactiveSuppLevelCheck== 'Yes' || test.IsrunningTest() ){
                    CaseTriggerFunction.populateProactiveSupportField();
                }        
            } catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}                                                           
        }

        /************************************************************************
            Use This Master For Loop for Before Trigger
        *************************************************************************/
        try{
            Set<Id> contactIds = new Set<Id>();
            Set<Id> contIds = new Set<Id>();
            set<Id> escalateCaseIds = new set<Id>();
            Set<Id> accountIds = new Set<Id>();
            Set<Id> accIds= new Set<Id>();            
            
            Case CaseOld = new Case();
            for(Sobject tmoObj : trigger.new){
                Case csObj = (case)tmoObj;
                
                /**********ASSIGNMENT OF CER CASES TO QUEUE STARTS HERE*******************/
                if(Trigger.isbefore && Trigger.isInsert && Support_Switches__c.getInstance('CERCaseAssignment') != null && Support_Switches__c.getInstance('CERCaseAssignment').isActive__c == 'Yes'){
                    if(csObj.RecordTypeId == Label.CERRecordTypeIdFull && (csObj.AccountType__c == 'Customer' || csObj.AccountType__c == 'Customer & Partner') && csObj.Priority == 'Critical'){
                        csObj.OwnerId = Label.Critical_Accounts_Queue;
                    }
                    else if(csObj.RecordTypeId == Label.CERRecordTypeIdFull){
                        csObj.OwnerId = Label.Enhancement_Request_Queue;
                    }            
                }
                /**********ASSIGNMENT OF CER CASES TO QUEUE ENDS HERE*******************/
                
                if((trigger.isInsert || trigger.isUpdate) && Label.csmSwitch2 == 'Yes') CaseTriggerFunctionUpdated.populateCsmAccountName(csObj);
                if(Trigger.isUpdate){
                    CaseOld= (Case)Trigger.OldMap.get(csObj.Id); 
                }
                if(Trigger.isbefore && Trigger.isInsert && (csObj.recordtypeId == Id.valueOf(Label.SupportCaseRecordTypeId) || csObj.recordtypeId == Id.valueOf(Label.SupportCaseRecordTypeId) || csObj.recordtypeId == '01250000000UJwzAAG' || csObj.recordtypeId =='01250000000UJwyAAG' || csObj.recordtypeId =='01250000000UJwzAAG' || csObj.recordtypeId =='01250000000UKbbAAG') && csObj.Origin != 'Web'){
                    contactIds.add(csObj.ContactId);
                }
                if((trigger.isInsert || (Trigger.isUpdate && csObj.status == 'Closed' && CaseOld.status != 'Closed')) && csObj.Situation_Contact__c != null && csObj.recordtypeId == Label.SupportFeedBackRecTypeId ) contIds.add(csObj.Situation_Contact__c );

               if((Trigger.isInsert || (Trigger.isUpdate && csObj.parentId != CaseOld.parentId) ) && csObj.recordtypeId == Label.SitManSupportRecordTypeId && csObj.parentId != null) escalateCaseIds.add(csObj.parentId);         
               if((Trigger.isInsert && Trigger.isBefore) && csObj.recordtypeId == Label.CERRecordTypeIdFull && csObj.AccountId != null) accountIds.add(csObj.AccountId);
               if(Trigger.isBefore && Trigger.isInsert && csObj.recordtypeId == Label.CERRecordTypeIdFull) accIds.add(csObj.AccountId);               
            }                    
            if((Trigger.isbefore && Trigger.isInsert && !contactIds.IsEmpty() && Support_Switches__c.getInstance('GhostAccess') != null && Support_Switches__c.getInstance('GhostAccess').isActive__c == 'Yes') || test.IsrunningTest() ){
                try{
                    CaseTriggerFunctionUpdated.updateCaseGhostAccess(contactIds);
                }catch(Exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            }
            if((contIds!= null && contIds.isEmpty() == False && Support_Switches__c.getInstance('SMPopulateMilestone') != null && Support_Switches__c.getInstance('SMPopulateMilestone').isActive__c == 'Yes') || Test.isRunningTest()) CaseTRiggerFunctionUpdated.populateEntitlementForSM(contIds);
            if(!escalateCaseIds.isEmpty() && Support_Switches__c.getInstance('updateEscalationOwner') != null && Support_Switches__c.getInstance('updateEscalationOwner').isActive__c == 'Yes') CaseTriggerFunctionUpdated.updateEscalationOwner(escalateCaseIds);          
            if(!accountIds.isEmpty() && Support_Switches__c.getInstance('CSMOwnerForCERSwitch') != null && Support_Switches__c.getInstance('CSMOwnerForCERSwitch').isActive__c == 'Yes') CaseTriggerFunctionUpdated.updateCSMOwnerForCERCases(accountIds);
            if(!accIds.isEmpty()) CaseTriggerFunctionUpdated.UpdateCERAccountSupportLevel(accIds);
        }catch(Exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        /************************************************************************
                        End Of Master For Loop
        *************************************************************************/

    }
    
    public void bulkAfter() {
        System.Debug('bulkAfter called for isPrimary ======> ' + isPrimary);
        if(isPrimary != true) return;
        System.debug('bulkAfter Called==>' + isAfterInsertProcessing);
        isAfterInsertProcessing = true;       
        EltPrmCaseAndEntMap = CaseTriggerFunction.NotifyTechSuppOrNamedSupp();  
        if(Label.CustomCSATSwitch == 'Yes' || Test.isRunningTest())languageToCaseIdMap = CaseTriggerFunction.InitializeSurveySettings();       
        system.debug('languageToCaseIdMap' + languageToCaseIdMap);
        if((trigger.isInsert || trigger.isUpdate) && (Label.csmSwitch == 'Yes'|| Test.isRunningTest()) ){
            if(CaseTriggerFunctionUpdated.updateMilestoneForCustomerSucessCases == false){
                CaseTriggerFunctionUpdated.updateMilestoneForCustomerSucessCases = true;
                try {cmToComplete = CaseTriggerFunctionUpdated.updateMilestoneForCustomerSucessCases();}catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);} 
            }
        }
        
        if((trigger.isInsert || trigger.isUpdate) && Support_Switches__c.getInstance('DedicatedTamSla') != null && Support_Switches__c.getInstance('DedicatedTamSla').isActive__c == 'Yes' ){
            newMilestoneToUpsert = CaseTriggerFunctionUpdated.UpdateMSFTMilestone();
        }
        
         /************************************************************************
            Use This Master For Loop for After Trigger
        *************************************************************************/
        try{ 
            Set<Id> cseIds = new Set<Id>();
            Set<Id> caseIds= new Set<Id>();
            Set<Id> cseIdsForSplunk = new Set<Id>();
            Map<Id,Id> ownerCaseMap = new Map<Id,Id>();
            Map<id,case> caseIdMap = new Map<id,case>();
            list<case> ScAndSaRecordtypecases = new list<case>();
            Case CaseOld = new Case();

            for(Object cse : Trigger.New){
                case casObj = (case) cse;
                 if((Trigger.isInsert && system.isBatch() == false && system.Isfuture() == false && casObj.RecordTypeId == label.CSMRecordTypeId && label.CSM_Owner_Switch == 'Yes') || test.IsrunningTest()){
                    cseIds.add(casObj.Id);
                 }
                 if(Trigger.isUpdate) CaseOld= (Case)Trigger.OldMap.get(casObj.Id); 
                if(trigger.isAfter && trigger.isInsert && Label.caseTeamSwitch == 'Yes'){
                    CaseTeamTemplateRecord ct = new CaseTeamTemplateRecord();
                    ct = CaseTriggerFunctionUpdated.insertCaseTeam(casObj);
                    if(ct != null)insertCaseTeam.add(ct);
                }
                if((Trigger.isInsert && system.isBatch() == false && system.Isfuture() == false && casObj.RecordTypeId == label.SupportCaseRecordTypeId && Support_Switches__c.getInstance('enableAssignmentRule') != null && Support_Switches__c.getInstance('enableAssignmentRule').isActive__c == 'Yes' && casObj.createdbyId != Label.System_Admin_Id && casObj.createdbyId != Label.JiveSyncUserId ) || test.IsrunningTest()) ownerCaseMap.put(casObj.ownerId,casObj.Id);
                
                if((Trigger.isInsert && casObj.recordTypeId == Label.ProActiveCaseRecTypeId && casObj.origin == 'Proactive'&& casObj.subject != null && casObj.subject.contains('Splunk Alert:') && system.isBatch() == false && system.Isfuture() == false && Label.EliteProactiveProjectSwitch == 'Yes') || Test.isRunningTest()){
                    cseIdsForSplunk.add(casObj.Id);
                } 
                
                if((trigger.isInsert || trigger.isUpdate) && Support_Switches__c.getInstance('UpdateTier3OwnerField') != null && Support_Switches__c.getInstance('UpdateTier3OwnerField').isActive__c == 'Yes' && casObj.RecordTypeId == label.tier3FullRecordTypeId && casObj.ParentId != null)  caseIdMap.put(casObj.ParentId, casObj);
                if(Trigger.isAfter && Trigger.isUpdate && casObj.recordTypeId == Label.ProActiveCaseRecTypeId && casObj.category__c == 'SSL Certificate' && CaseOld.reason != casObj.reason && casObj.reason == 'Other') caseIds.add(casObj.Id);
                
        /*************************************  Added code for SA And SC record type  ************************************/
               if(Trigger.isAfter){
                if(Trigger.isinsert){
                if(casObj.recordtypeid == Label.SC_Case_Record_Type_Id || casObj.recordtypeid == Label.SA_Case_Record_Type_Id){
                    ScAndSaRecordtypecases.add(casObj);
                }
                }
                if(Trigger.isupdate){
                if((casObj.recordtypeid == Label.SC_Case_Record_Type_Id && casObj.recordtypeid != CaseOld.recordtypeid)|| (casObj.recordtypeid == Label.SA_Case_Record_Type_Id && casObj.recordtypeid != CaseOld.recordtypeid )){
                    ScAndSaRecordtypecases.add(casObj);
                }
                }
             }
            }  
            if(!ScAndSaRecordtypecases.isempty()){
            CaseTriggerFunctionUpdated.assignmentRuleForScAndSaRecordType(ScAndSaRecordtypecases);
            }
      /**********************************  End of Added code for SA And SC record type  ************************************/
            
  
            if(cseIds.isEmpty() == false && system.isBatch() == false && system.Isfuture() == false)  CaseTriggerFunction.assignCamOwner(cseIds);
            if(ownerCaseMap.isEmpty() == false && system.isBatch() == false && system.Isfuture() == false )  CaseTriggerFunctionUpdated.runCaseOwnerAssignmentRule(ownerCaseMap);
            if(cseIdsForSplunk != null && cseIdsForSplunk.isEmpty() == False) CaseTriggerFunctionUpdated.createProactiveCaseSplunk(cseIdsForSplunk);
            if(!caseIdMap.isEmpty()) tierFieldUpdateCases = CaseTriggerFunctionUpdated.updateTier3CaseNumber(caseIdMap);
            if(!caseIds.isEmpty() && Support_Switches__c.getInstance('SecuredDomainSSL') != null && Support_Switches__c.getInstance('SecuredDomainSSL').isActive__c == 'Yes') sslCaseToInsert  = CaseTriggerFunctionUpdated.createCSMCaseForSSLDomain(caseIds);  
        }catch (Exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);} 
        
        /************************************************************************
                            End Of Master For Loop
        *************************************************************************/ 
        
                 
        if(Trigger.isInsert){
            try {
                if((Test.isRunningTest() || Label.EWSActivator == 'YES') && !EWSUtility.isEwsExecutedInsert){
                    accountIdsForEWSMap = EWSUtility.createrEWSActivitiesForCases();
                    EWSUtility.isEwsExecutedInsert = true;
                }
            
            }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            
            System.debug('bulkAfter Insert Called==>');          
            try {
                if(label.TrackCaseOwnerHistory == 'Yes' || test.IsrunningTest() ){
                    CreateOwerHistroy = CaseTriggerFunction.CreateOwerHistroy();
                }
            } catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            recordsToReturn = CaseTriggerFunction.GainsightCaseTrigger();                                      
            try {
                milestonesToBeUpsert = CustomMileStoneUtil.MilestoneUpdateinsert('Insert');
            } catch (Exception e) {
                system.debug('Exception =======>'+e);
                CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);
            }
            system.debug('milestonesToBeUpser____Insert--->'+milestonesToBeUpsert);
            
            // START ==>>>> SOPS-1198 - Route Default Queue and LP Queue Support Cases to US Queue Automatically 17th Nov, 2016
            try {
                if((label.routeDefaultnLPcasesToUs == 'Yes' || test.IsrunningTest() ) && system.isBatch() == false && system.Isfuture() == false){
                    Datetime pstFmt = system.now();
                    String pstTime = pstFmt.format('yyyy-MM-dd HH:mm:ss', 'PST');
                    integer hours  = integer.valueOf(pstTime.substring(11,13));
                    if(hours >=06  && hours < 24) {
                        //PST time 6AM - 6PM 
                        list<id> routeToUsCases = new list<id>();
                        for(Sobject so : trigger.new) { 
                            Case cn = (Case) so; 
                            system.debug('Ownerid==>>>'+cn.ownerid);
                            system.debug('status==>>>'+cn.status);  
                            if( cn.status == 'New' && (cn.recordtypeid==System.Label.supportcaserecordtypeid || cn.recordtypeid==System.Label.SupportEmail2CaseRecordtypeId || cn.recordtypeid==System.Label.SupportPortalCaseRecordtypeId) ){
                                routeToUsCases.add(cn.id);                        
                            }
                        }
                        if(routeToUsCases !=null && routeToUsCases.IsEmpty()==false) CaseTriggerFunction.routeDefaultnLPcasesToUs(routeToUsCases);                      
                    }                    
                }
            } catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            // END ==>>>> SOPS-1198 - Route Default Queue and LP Queue Support Cases to US Queue Automatically "17th Nov, 2016"
            
            //Set<Case> newEscalSmCase = new Set<Case>();
            List<Case> smCases = new List<Case>();  
            for(Sobject so : Trigger.new) {                           
                Case caseNew = (Case) so;   
                if(caseNew.Origin != null && caseNew.Origin.equals('Phone')) {
                    closeFirRMileStoneCaseIds.add(caseNew.id);                        
                }
                if(caseNew.Origin != null && caseNew.SuppliedEmail != null && caseNew.Origin.equals('TBD')) {
                    SituationEmailToCase.put(caseNew.id, caseNew.SuppliedEmail);
                }                
                system.debug('==>>>>' + caseNew.recordTypeId + ' ' + caseNew.parentId);                                
                if(caseNew.recordTypeId == '01250000000UK1EAAW' && caseNew.Status != 'Closed' && caseNew.parentId != Null) {
                    smCases.add(caseNew);
                }
                if(caseNew.RecordTypeId == System.Label.supportCaseRecordTypeId || caseNew.RecordTypeId == System.Label.supportemail2caserecordtypeid || caseNew.RecordTypeId == System.Label.supportPortalCaseRecordtypeId) {
                    if(caseNew.Priority == 'P1' && caseNew.Support_Level__c == 'Microsoft') {
                        insertCaseComment.Add(new casecomment(IsPublished=false,ParentId=caseNew.Id,CommentBody='Alert: P1 process document ' + System.Label.MicrosoftP1AlertDocLink));
                    }                                    
                }
            }
            if(smCases.isEmpty() == FALSE) {
                List<CaseComment> insertSmDetailComment = new List<CaseComment>();
                CustomMileStoneUtil.getCaseCommentsforSMwithSupportParent(smCases,insertSmDetailComment);                
                if(insertSmDetailComment.isEmpty() == FALSE) {
                    insertCaseComment.addAll(insertSmDetailComment);
                }
            }                                    
        }
        if(Trigger.isUpdate) {
            try { 
               if(Label.P1Extended == 'Yes' && system.isBatch() == false && system.Isfuture() == false){
                   list<id> caseidList = new list<id>();
                   for (object cas : trigger.new){
                        case cas1= (case) cas;
                        Case CaseOld= (Case)Trigger.OldMap.get(cas1.Id); 
                        if((cas1.recordTypeId == System.Label.SupportCaseRecTypeId && CaseOld.status != 'P1 Extended' && cas1.status=='P1 Extended' )){ 
                            caseidList.add(cas1.id);   
                        }
                    }
                    if(caseidList.Isempty()==False) CaseTriggerFunction.P1Extended(caseidList);
                }
            }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            try {
                if((Test.isRunningTest() || Label.EWSActivator == 'YES') && !EWSUtility.isEwsExecutedUpdate){
                    accountIdsForEWSMap = EWSUtility.createrEWSActivitiesForCases();
                    EWSUtility.isEwsExecutedUpdate = true;
                }
            
            }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            try {
                if(label.TrackCaseOwnerHistory == 'Yes' || test.IsrunningTest() ){
                    CreateOwerHistroy = CaseTriggerFunction.CreateOwerHistroy();
                }
            } catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            
            try {
                if( label.EnableTier3 == 'Yes' || test.IsrunningTest() ){               
                    updateJiraInfoTier3= CaseTriggerFunction.updateJiraInfoTier3();
                }
            } catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            
            try {
                if( label.EnableTier3 == 'Yes' || test.IsrunningTest() ){
                    updateStatusToNeedsReplytier3Parent= CaseTriggerFunction.updateStatusToNeedsReplytier3Parent();
                }
            } catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            
            try {
                if( label.EnableTier3 == 'Yes' || test.IsrunningTest() ){
                    if(CaseTriggerFunction.ifCaseClosedForTier3Run == false){
                        CaseTriggerFunction.ifCaseClosedForTier3Run = true;
                    addCaseCommentTotier3Parent= CaseTriggerFunction.addCaseCommentTotier3Parent();
                    }
                }
            } catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}

            try{
                if((label.EnableTier3 == 'Yes' && CaseTriggerFunctionUpdated.recursionSwtichForTier3 == false) || test.IsrunningTest()){
                    CaseTriggerFunctionUpdated.recursionSwtichForTier3 = true;
                    updateTier3ForClosedParent = CaseTriggerFunctionUpdated.updateTier3ForClosedParent();
                }
            }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            
            try {
                if(label.enableReviewCheck== 'Yes' || test.IsrunningTest()){
                    if(CaseTriggerFunction.ifRequestManagerReviewRun == false){
                        CaseTriggerFunction.ifRequestManagerReviewRun = true;
                        ifRequestManagerReviewChecked = CaseTriggerFunction.ifRequestManagerReviewChecked();
                        system.debug('list has0==='+ifRequestManagerReviewChecked );
                    }
                    
                }
            } catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            
           
            
            if(!CaseHandler.isInsertingNewCase) {
                try{m_NewCases = CaseTriggerFunction.CreateNewCaseForAttemptToOpenHardClosedCase();} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}// New case for insert.
            }
            try{milestonesToBeUpsert = CustomMileStoneUtil.MilestoneUpdateinsert('Update');} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);} 
            system.debug('milestonesToBeUpser____Update=====>'+milestonesToBeUpsert);
            for(Sobject so : Trigger.new) {
                SObject oldSo = Trigger.oldMap.get(so.Id);                                  
                Case caseOld = (Case) oldSo; Case caseNew = (Case) so;
                if(caseOld.isClosed == FALSE && caseNew.isClosed == TRUE) {
                    closeResMileStoneCaseIds.add(caseNew.id);    
                }
                //Code snippet Run only when case is updated
                if(caseNew.RecordTypeId == System.Label.supportCaseRecordTypeId || caseNew.RecordTypeId == System.Label.supportemail2caserecordtypeid || caseNew.RecordTypeId == System.Label.supportPortalCaseRecordtypeId) {
                    if(caseNew.Priority == 'P1' && caseNew.Support_Level__c == 'Microsoft'  && (caseOld.Priority != 'P1' || caseOld.Support_Level__c != 'Microsoft')) {
                        insertCaseComment.Add(new casecomment(IsPublished=false,ParentId=caseNew.Id,CommentBody='Alert: P1 process document ' + System.Label.MicrosoftP1AlertDocLink));
                    }
                }
            }
        }
        
        if(trigger.isAfter && trigger.isUpdate && trigger.size == 1) {                  
            
            system.debug('===>1 noArticleCommentsCase==>');
            if(!CaseHandler.isInsertingCComment) {
                try {
                    CaseComment com = CaseTriggerFunction.noArticleComments();
                    if(com != null) insertCaseComment.Add(com);                
                    System.debug('com Value=> ' + com);                
                } catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}                     
            }
            try{
                if(label.Enable_5_Proactive_Cases == 'Yes' || test.IsrunningTest()){
                    if(CaseTriggerFunction.firstRunExecuted == false){
                        CaseTriggerFunction.firstRunExecuted = true;
                        CasesOpenedForSecondTimeList = CaseTriggerFunction.CasesOpenedForSecondTime();
                        system.debug('@@@@@@CasesOpenedForSecondTimeList ' +CasesOpenedForSecondTimeList);
                    }
                    
                }            
            }  catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);} 
            
            if((Support_Switches__c.getInstance('GhostAccess') != null && Support_Switches__c.getInstance('GhostAccess').isActive__c == 'Yes') || test.IsrunningTest()) {
                try{
                    CaseComment cm = CaseTriggerFunctionUpdated.ghostRequestAccess();
                    if(cm.ParentId != null) insertCaseComment.add(cm);
                }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
                
                try{
                    CaseTriggerFunctionUpdated.ghostRequestAccessNotifications();
                } catch(Exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);} 
            }
            
        }

        //updateSalesCases 
        if(Trigger.isInsert || Trigger.isUpdate) {
            acList = CaseTriggerFunction.AccountUpdate();
            if(Trigger.size == 1) { 
                /*system.debug('IsNonAuthCase outside==>'+IsNonAuthCase);
                if(IsNonAuthCase && system.isBatch() == false && system.Isfuture() == false){
                    system.debug('IsNonAuthCase inside==>'+IsNonAuthCase);
                    try {CaseTriggerFunction.NonAuthCaseNotificationToCAM(Trigger.new[0].id);}catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);} 
                }*/
                system.debug('called single case function==>>>>');
                try{
                    if(label.NeedsReplyNotification =='Yes' || test.IsrunningTest() ){
                        NeedsReplyNotificationCases = CaseTriggerFunction.NeedReplyNotifyCases();
                    }
                } catch (Exception e) {
                    CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);
                }                 
                Case caseNew = (Case) trigger.new[0];
                setValidValuesForSalesCases = CaseTriggerFunction.updateSalesCases(); //updateSalesCases                    
                if( (label.CaseMonitoringEnabled == 'True' || Test.IsRunningTest() == True ) && Trigger.isInsert && caseNew.Problem_Type__c!=null && caseNew.Problem_Type__c!='' && caseNew.category__c!=null && caseNew.category__c!=''){ 
                    try{ 
                        ProactiveMonitoringCase = CaseTriggerFunction.ProactiveCaseMonitoring();
                        system.debug('ProactiveMonitoringCase===>1'+ProactiveMonitoringCase);
                    } catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
                }
                if((Test.isRunningTest() ||  label.CaseMonitoringEnabled == 'True') && Trigger.isUpdate && caseNew.Problem_Type__c!=null && caseNew.Problem_Type__c!='' && caseNew.category__c!=null && caseNew.category__c!=''){
                    Case caseOld = (Case) trigger.old[0];
                    if(caseOld.Problem_Type__c != caseNew.Problem_Type__c || caseOld.category__c!= caseNew.category__c) {                     
                        try { 
                            ProactiveMonitoringCase = CaseTriggerFunction.ProactiveCaseMonitoring();
                            system.debug('ProactiveMonitoringCase===>1'+ProactiveMonitoringCase);
                        } catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
                    }
                }
            }
        }
        if(milestonesToBeUpsert !=null && !milestonesToBeUpsert.isEmpty()) {
            system.debug('milestonesToBeUpsert____________Final====>'+milestonesToBeUpsert);
            for(Case_Update_Milestones__c tmp : milestonesToBeUpsert) {
                if(tmp!=null){
                    system.debug('type---->'+tmp.Milestone_Type__c+'-----Completed__c ------>'+tmp.Completed__c);
                    if((tmp.Milestone_Type__c == 'First Response' || tmp.Milestone_Type__c == 'Case Update') && tmp.Completed__c == false && tmp.case__c != NULL){ 
                        system.debug('milestonesToBeUpsert=====>'+tmp );                              
                        case updatecase = new case(id = tmp.case__c, NextUpdateDueFrmCUM__c = tmp.Target_Date__c);
                        CaseListtobeUpdated.add(updatecase);  //update case set next due date.
                    }
                }              
            }  
        }
    }
        
    public void beforeInsert(SObject so) {
        System.debug('beforeInsert Called==>' + so);
    }
    
    public void beforeUpdate(SObject oldSo, SObject so) {
        System.debug('beforeUpdate Called==>' + so);      
    }
    
    /*** beforeDelete ** This method is called iteratively for each record to be deleted during a BEFORE * trigger.*/
    public void beforeDelete(SObject so) {
        System.debug('beforeDelete Called==>' + so);
    }
    
    public void afterInsert(SObject so) {        
         System.debug('afterInsert Called==>' + so);              
    }
    
    public void afterUpdate(SObject oldSo, SObject so) {
        System.debug('afterUpdate Called==>' + so);        
        
    }
    
    public void afterDelete(SObject so) {
        System.debug('afterDelete Called==>' + so);       
    }
    
    /*** andFinally** This method is called once all records have been processed by the trigger. Use this * method to accomplish any final operations such as creation or updates of other records.*/
    public void andFinally() {       
        System.Debug('andFinally called for isPrimary ======> ' + isPrimary); 
        if(isPrimary != True) return;       
        //do all post operations here.       
        String tmpStr = '';
        if(Trigger.isBefore) tmpStr += ' Before ';    
        if(Trigger.isAfter)  tmpStr += ' After '; 
        if(Trigger.isInsert) tmpStr += ' Insert ';    
        if(Trigger.isUpdate) tmpStr += ' Update ';    
        if(Trigger.isDelete) tmpStr += ' Delete ';  
        System.debug('andFinally called for ======>' + tmpStr);     
        System.debug('andFinally called======>EltPrmCaseAndEntMap ' + EltPrmCaseAndEntMap);
        try{
            if((Test.isRunningTest() || Label.EWSActivator == 'YES') && accountIdsForEWSMap != null && !accountIdsForEWSMap.isEmpty()) EWSUtility.createrEWSActivities(accountIdsForEWSMap);
        }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}              
        if(recordsToReturn != Null && recordsToReturn.containsKey('Insert'))    insert recordsToReturn.get('Insert');
        if(recordsToReturn != Null && recordsToReturn.containsKey('Delete'))    delete recordsToReturn.get('Delete');
        if( (label.TrackCaseOwnerHistory == 'Yes' || test.IsrunningTest() ) && CreateOwerHistroy != Null && CreateOwerHistroy.isEmpty() == FALSE ){
            try{upsert CreateOwerHistroy Unique_Id__c;} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        }        
        
        if( label.EnableTier3 == 'Yes' || test.IsrunningTest() ){
            if( updateJiraInfoTier3!= Null && updateJiraInfoTier3.isEmpty() == FALSE ){
                try{update updateJiraInfoTier3;} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            }
        }
        
        if( label.EnableTier3 == 'Yes' || test.IsrunningTest() ){
            if( addCaseCommentTotier3Parent!= Null && addCaseCommentTotier3Parent.isEmpty() == FALSE ){
                try{insert addCaseCommentTotier3Parent;} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            }
        }
        if( label.EnableTier3 == 'Yes' || test.IsrunningTest() ){
            if( updateStatusToNeedsReplytier3Parent != Null && updateStatusToNeedsReplytier3Parent.isEmpty() == FALSE ){
                try{update updateStatusToNeedsReplytier3Parent;} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            }
        }
        if( label.EnableTier3 == 'Yes' || test.IsrunningTest() ){
            if( updateTier3ForClosedParent!= Null && updateTier3ForClosedParent.isEmpty() == FALSE ){
                try{update updateTier3ForClosedParent;} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            }
        }
        
        if((label.enableReviewCheck=='Yes' || test.IsrunningTest() ) && ifRequestManagerReviewChecked != null && ifRequestManagerReviewChecked.isEmpty() == FALSE) { 
            system.debug('entered finally==>');   
            try {insert ifRequestManagerReviewChecked ;system.debug('list has==='+ifRequestManagerReviewChecked );} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}      
        } 
        if(insertCaseTeam!= NULL && insertCaseTeam.isEmpty() == FALSE) {
           try{insert insertCaseTeam;} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);} 
        }

        
        List<Case> CasesTobeUpdated = new List<Case>();
        
        Case allocaDiaCase;//Close this case. Support Case Allocadia.
        if(Trigger.isAfter && Trigger.isInsert && Trigger.Size == 1) {
           try{allocaDiaCase = CaseTriggerFunction.CaseReceivedNotificationEmail();}catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            //if(allocaDiaCase != Null && allocaDiaCase.Id != Null) {CasesTobeUpdated.add(allocaDiaCase);}
        }
        if(EltPrmCaseAndEntMap != NULL && EltPrmCaseAndEntMap.isEmpty() == FALSE) {
            CaseTriggerFunction.emailToNamSupEngOrTechAcctMan(EltPrmCaseAndEntMap);
        }
        
        if(NeedsReplyNotificationCases != NULL && NeedsReplyNotificationCases.isEmpty() == FALSE && (label.NeedsReplyNotification =='Yes' || test.IsrunningTest() )) {
            try{CaseTriggerFunction.SendNeedReplyNotificationToNSEandManager(NeedsReplyNotificationCases);}catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        }
        System.debug('andFinally called======>languageToCaseIdMap ' +languageToCaseIdMap);                
        Set<Id> surveyLinksSent = new Set<Id>();
        if((languageToCaseIdMap != NULL && languageToCaseIdMap.isEmpty() == FALSE && Label.CustomCSATSwitch == 'Yes')) { 
           try{
               surveyLinksSent.AddAll(CaseTriggerFunction.sendSurveyEmails(languageToCaseIdMap)); 
           }catch(Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}        
                       
        }
        System.debug('andFinally called======>closeFirRMileStoneCaseIds ' +closeFirRMileStoneCaseIds );                
        if(closeFirRMileStoneCaseIds != null && closeFirRMileStoneCaseIds.isEmpty() == FALSE && system.isBatch() == false && system.Isfuture() == false) {
            try{CaseTriggerFunction.completeMilestoneFuture(closeFirRMileStoneCaseIds, 'First Response', System.now());} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        }
        
        System.debug('andFinally called======>closeResMileStoneCaseIds ' +closeResMileStoneCaseIds );             
        if(closeResMileStoneCaseIds != null && closeResMileStoneCaseIds.isEmpty() == FALSE) {
            try{CaseTriggerFunction.completeMilestone(closeResMileStoneCaseIds, 'Resolution', System.now());} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        }
        
        system.debug('andFinally called======>m_NewCases==>' + m_NewCases);
        if(m_NewCases != Null && m_NewCases.isEmpty() == False && CaseHandler.isInsertingNewCase != True) { 
            try { CaseHandler.isInsertingNewCase = True; insert m_NewCases;} 
            catch (Exception e) { CaseTriggerFunction.sendEcxeptionMailToDeveloper(e); }
        }
                
        system.debug('andFinally called======>milestonesToBeUpsert==>' + milestonesToBeUpsert);                
        if(milestonesToBeUpsert != Null && milestonesToBeUpsert.isEmpty() == False){        
            try{upsert milestonesToBeUpsert;} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        }
        if( label.EnableTier3 == 'Yes' || test.IsrunningTest() ){
            if(tier3CaseListtobeUpdated!=null && tier3CaseListtobeUpdated.isEmpty() == False){
                try{upsert tier3CaseListtobeUpdated;} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            }
        }  
        try{CasesTobeUpdated = CaseTriggerFunction.createCasesTobeUpdatedList(allocaDiaCase , surveyLinksSent,CaseListtobeUpdated);} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        system.debug('andFinally called======>CasesTobeUpdated==>' + CasesTobeUpdated); 
        if(CasesTobeUpdated != null && CasesTobeUpdated.isEmpty() == False) {        
            for(Case c : CasesTobeUpdated) system.debug('CasesTobeUpdatedDetails====> ' + c );            
            isUpdatingCase = True;//set the recursion check         
            try{update CasesTobeUpdated;} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);} //update case set next due date 
        }
        try{
            if(tierFieldUpdateCases!=null && !tierFieldUpdateCases.isEmpty())
            update tierFieldUpdateCases;
        } catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        if(setValidValuesForSalesCases != NULL && setValidValuesForSalesCases.isEmpty() == False) {
            isUpdatingCase = True; //set the recursion check
            try {
                update setValidValuesForSalesCases; // update sales cases.
            }
            catch(DmlException de){
                System.Debug('***** GOT DML EXCEPTION__'+de.getMessage());
                trigger.new[0].addError(de.getMessage().substring(de.getMessage().indexOf('first error:')+12 , de.getMessage().length()));
            }
            catch(Exception ex){
                system.debug(ex);    
            }            
        }        
        if(!CaseHandler.isInsertingCComment && insertCaseComment != Null) {
            system.debug('andFinally insert Case Comment Called====> ' + insertCaseComment);
            if(insertCaseComment.isEmpty() == FALSE) {
                CaseHandler.isInsertingCComment = true;     
                try{insert insertCaseComment;} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            }
        }
             
        if(ProactiveMonitoringCase!=null){
            system.debug('ProactiveMonitoringCase===>'+ProactiveMonitoringCase);
            try{insert ProactiveMonitoringCase;} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        }
                
        system.debug('andFinally called======>SituationEmailToCase ' + SituationEmailToCase);         
        if(SituationEmailToCase != null && SituationEmailToCase.keySet().size() > 0) {
            try{SituationUtil.updateCase(SituationEmailToCase);} catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        }
        System.debug('isPrimary ==> '+ isPrimary + ' isBeforeInsertProcessing==> ' + isBeforeInsertProcessing ); 
        if(isPrimary == True && isBeforeInsertProcessing == True) {
            isBeforeInsertProcessing = False;
            isBeforeInsertProcessing2 = False;
        }        
        if(acList != NULL && acList.isEmpty() == False){
            try {
                if(!CaseTriggerFunction.AccountUpdateCheck){
                    CaseTriggerFunction.AccountUpdateCheck = True;
                    update acList;                  
                }
            } catch(Exception ex){
                acList[0].addError(ex);     
            }
        }
        if(CasesOpenedForSecondTimeList != null && CasesOpenedForSecondTimeList.Size() > 0){
            try{
                insert CasesOpenedForSecondTimeList;
            }
            catch(Exception e){
                CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);
            }
        }        
        if(cmToComplete != null && cmToComplete.Size() > 0){
            try{
                upsert cmToComplete;
            }catch(Exception e){
                CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);
            }
        } 
        
        try{
            if(newMilestoneToUpsert != null && newMilestoneToUpsert.Size() > 0)upsert newMilestoneToUpsert;
        }catch(Exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}  
        
        try{
            if(sslCaseToInsert!= null && sslCaseToInsert.Size() > 0)Insert sslCaseToInsert;
        }catch(Exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}                                      
                                               
    }      
}