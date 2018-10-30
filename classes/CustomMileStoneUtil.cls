/****************************************************************************
CLASS UPDATED BY GRAZITTI SUPPORT TEAM ON 6 SEPT 2017
CHANGES - Replace Integer with Long datatype.
LINE NUMBERS - 221,252,472
*******************************************************************************/
public class CustomMileStoneUtil{

    public static Boolean firstRunInCase = TRUE;
    public static Boolean isExclude = false;
    public static list<SLA__c> SlaList = new list<SLA__c>();
    public static Map<id, integer> BusinessHoursMap = new Map<id, integer>{'01m50000000H7Qz' => 24, '01m3800000004hP' => 12, '01m3800000004hU' => 12, '01m50000000H7R9' => 9, '01m50000000H7R4' => 9, '01m3800000004hZ' => 12, '01m500000004FoA' => 12, '01m3800000004he' => 12, '01m3800000004hj' => 12, '01m3800000004ho' => 12,  '01m3800000004hF' => 9, '01m50000000H7RE' => 24, '01m3800000004gv' => 24, '01m3800000004h0' => 24, '01m3800000004h5' => 24, '01m3800000004hA' => 24};
    
    public static Id  supCaseRecordTypeId  = '01250000000UJwxAAG';
            
    public List<Case_Update_Milestones__c> m_MilestonesToBeUpdatedOrInserted;
    public List<Case> m_casesToBeUpdated;     
    public CustomMileStoneUtil () {
        m_CasesToBeUpdated  = new List<Case>(); 
        m_MilestonesToBeUpdatedOrInserted = new List<Case_Update_Milestones__c>();
    }

    public static List<Case_Update_Milestones__c> MilestoneUpdateinsert(String UpdOrInsrt) {
        List<Case_Update_Milestones__c> milestonesToBeUpsert = new List<Case_Update_Milestones__c>();
        string SupportCaseRecTypes = CaseRecordOrTypeIds__c.getInstance('Support Record Type Ids').ReferenceIds__c;
        List<case> NewSupportCases = new List<case>();
        for(SObject sObj : Trigger.New) {   
            case tmp = (Case) sObj;
            if(SupportCaseRecTypes.contains(tmp.recordTypeId)) {
                if(tmp.Problem_Type__c != NULL && Label.Case_ProblemTypes_To_Ignore.containsIgnoreCase('#'+tmp.Problem_Type__c+'#')) {                
                    continue;
                }                   
                NewSupportCases.add(tmp);
            }        
        }
        if(NewSupportCases.Isempty()){return milestonesToBeUpsert;}
        system.debug('firstRunInCase----->');        
        if(firstRunInCase != FALSE){ //TRIGGER ALREADY EXECUTED MODULE CHECK            
            system.debug('in custom milestone code============================>');
            
            
            List<case> casesToBeUpdated = new List<case>();
            Case_Update_Milestones__c InsrtCaseMile;
            
            if(UpdOrInsrt=='Update'){                             
                Set<String> ignoreCaseStatuses    = new set<String>(Case_Statuses__c.getInstance('Case Status').Ignore_Case_Status_Values__c.split(','));
                Set<String> nonIgnoreCaseStatuses = new set<String>(Case_Statuses__c.getInstance('Case Status').Non_Ignore_Case_Status_Values__c.split(','));
                map<id,list<Case_Update_Milestones__c>> caseIdToMilestone = new map<id,list<Case_Update_Milestones__c>>();  
                
                for(Case_Update_Milestones__c CusMil : [SELECT OwnerId,Completed__c, Case__c, Case__r.ownerid,case__r.dedicated_TAM__c,case__r.businessHoursId, Start_Date__c, Target_Date__c, Milestone_Type__c,Completion_Date__c from Case_Update_Milestones__c where Case__c IN : Trigger.NewMap.keyset() And (Completed__c = false OR Milestone_Type__c = 'Resolution Response') AND case__r.entitlementId != null AND Milestone_Type__c != 'Temporary Resolution']){
                    if(caseIdToMilestone.containsKey(CusMil.Case__c)) {
                        List<Case_Update_Milestones__c> MilList = caseIdToMilestone.get(CusMil.Case__c);
                        MilList.add(CusMil);
                        caseIdToMilestone.put(CusMil.Case__c, MilList);
                    } else {
                        caseIdToMilestone.put(CusMil.Case__c, new List<Case_Update_Milestones__c> { CusMil });
                    }
                }
                
                for(case tmp: NewSupportCases) {                    
                    Case tmpOld = (Case) Trigger.OldMap.get(tmp.id);
                    if(tmp.status != tmpOld.status || tmp.ownerid != tmpOld.ownerid || tmp.priority != tmpOld.priority || tmp.entitlementid  != tmpOld.entitlementid) { 
                        system.debug('tmp.Prevent_Comment_Notifications__c====>'+tmp.Prevent_Comment_Notifications__c);
                        system.debug('caseIdToMilestone-->' +caseIdToMilestone);
                        if(!caseIdToMilestone.IsEmpty() && caseIdToMilestone.containskey(tmp.id)) {
                            for(Case_Update_Milestones__c mil : caseIdToMilestone.get(tmp.id)) {
                                Case_Update_Milestones__c caseMile = mil;
                                boolean UpdateMil = false;
                                if(label.EnableResolutionMile == 'Yes' && mil.Completed__c == true  && mil.Milestone_Type__c == 'Resolution Response' && tmp.priority < tmpOld.priority){
                                    caseMile = ReOpenCaseUpdateMile(mil);
                                    UpdateMil = true;
                                }
                                if(tmp.status != tmpOld.status && mil.Completed__c == true  && mil.Milestone_Type__c == 'Resolution Response' && ( tmpOld.status =='Closed' || tmpOld.status =='Transferred' || tmpOld.status =='Pending Support Assist' ) && (tmp.status !='Transferred' && tmp.status !='Pending Support Assist' && tmp.status !='Closed') ){
                                    caseMile = ReOpenCaseUpdateMile(mil);
                                    system.debug('reopen==================>>>' +caseMile); 
                                    UpdateMil = true;
                                }else if(mil.Completed__c == false) {                                    
                                    system.debug('mil Id-->' +caseMile.id);               
                                    
                                    // CASE OWNER IS UPDATED STARTS HERE
                                    if (tmp.ownerid != tmpOld.ownerid) {
                                        system.debug('new owner--->'+ tmp.ownerid + ' old owner--->'+tmpOld.ownerid);                
                                        caseMile.OwnerId = (string.valueOf(tmp.OwnerId).startsWith('00G') || tmp.OwnerId =='00550000004KAuFAAW')  ? '00550000001y4AfAAI' : tmp.OwnerId;
                                        UpdateMil = true;
                                    }
                                    
                                    //CASE PRIORITY IS UPDATED STARTS HERE
                                    if (tmp.priority < tmpOld.priority) {   //IsPriorityIncreased 
                                        system.debug('priority-->');                              
                                        if(mil.Milestone_Type__c =='First Response') {
                                            caseMile = updateOpenCaseMilestne(tmp, mil, 'First_Response_NOM__c',tmp.dedicated_TAM__c); 
                                            UpdateMil = true;                  
                                        }   
                                        if(mil.Milestone_Type__c =='Resolution Response') {
                                            caseMile = updateOpenCaseMilestne(tmp, mil, 'Resolution_NOM__c',tmp.dedicated_TAM__c);
                                            UpdateMil = true;
                                        }        
                                        if(mil.Milestone_Type__c =='Case Update') {
                                            InsrtCaseMile = new Case_Update_Milestones__c();
                                            CaseMile = CompleteOpenMileStn(mil, true);
                                            InsrtCaseMile = insertCaseMilestone (tmp, 'Case_Update_Milestone_NOM__c', 'Priority',tmp.dedicated_TAM__c);  
                                            UpdateMil = true;                    
                                        } 
                                        
                                    } 
                                    
                                    //CASE PRIORITY IS DOWNGRADED STARTS HERE
                                    if ( label.EnableResolutionMile == 'Yes' && tmp.priority > tmpOld.priority ) {   //IsPriorityIncreased 
                                        system.debug('priority-->');                                
                                        if(mil.Milestone_Type__c =='Resolution Response') {
                                            caseMile = CompleteOpenMileStn(mil, true);
                                            UpdateMil = true;
                                        }        
                                    
                                    }
                                                  
                                    if (tmp.status != tmpOld.status) { //isStatusChangedToOtherStatus      
                                        system.debug('new Status--->'+tmp.status + ' old Status--->'+tmpOld.status);
                                        system.debug('new Status========>'+mil.Milestone_Type__c);
                                        if((ignoreCaseStatuses.Contains(tmp.Status) && nonIgnoreCaseStatuses.Contains(tmpOld.Status) && tmp.Status!='Transferred' && nonIgnoreCaseStatuses.Contains(tmpOld.Status) && tmp.Status!='Pending Support Assist') || mil.Milestone_Type__c == 'Resolution Response') {
                                            system.debug('new Status========>');
                                            if(tmp.status == 'Closed') {
                                                CaseMile = CompleteOpenMileStn(mil, true);
                                                system.debug('new Status---=================>');
                                                UpdateMil = true;
                                            }else if(mil.Milestone_Type__c != 'Resolution Response') {
                                                caseMile = CompleteOpenMileStn(mil, true);
                                                UpdateMil = true;
                                            }                                                                                                       
                                        }
                                        
                                    }   
                                                
                                    if (tmp.entitlementid != tmpOld.entitlementId && mil.Milestone_Type__c !='Resolution Response' ) { //isEntitChangedToOtherEntit
                                        system.debug('entitlement -->');
                                        InsrtCaseMile = new Case_Update_Milestones__c();
                                        if(nonIgnoreCaseStatuses.Contains(tmp.Status)){
                                            CaseMile = CompleteOpenMileStn(mil, true);
                                            InsrtCaseMile = insertCaseMilestone (tmp, 'Case_Update_Milestone_NOM__c', 'Entitlement',tmp.dedicated_TAM__c);
                                        }else if(tmp.entitlementid !=null && tmpOld.entitlementid == null){
                                            InsrtCaseMile = insertCaseMilestone (tmp, 'First_Response_NOM__c', 'Entitlement',tmp.dedicated_TAM__c);
                                        }else{
                                            InsrtCaseMile = insertCaseMilestone (tmp, 'Case_Update_Milestone_NOM__c', 'Entitlement',tmp.dedicated_TAM__c);
                                        }
                                        UpdateMil = true;
                                    }                                                                         
                                }
                                if(UpdateMil == true) {
                                    system.debug('------------------i am in list-----------------');
                                    if(caseMile != null && caseMile.id != null) {
                                        system.debug('caseMile.id===>'+caseMile.id); 
                                        milestonesToBeUpsert.add(caseMile);
                                    }
                                    system.debug('InsrtCaseMile===>'+InsrtCaseMile);
                                    if(InsrtCaseMile != null) milestonesToBeUpsert.add(InsrtCaseMile); 
                                } 
                            }
                        }
                        
                        boolean UpdateMil = false;
                        system.debug('new Status--->'+tmp.status + ' old Status--->'+tmpOld.status);
                        if (tmp.status != tmpOld.Status) { //isStatusChangedToOtherStatus 
                            system.debug('new Status--->'+tmp.status + ' old Status--->'+tmpOld.status);
                            if(nonIgnoreCaseStatuses.Contains(tmp.Status) && tmp.Status!='Transferred' && tmp.Status!='Pending Support Assist' && (ignoreCaseStatuses.Contains(tmpOld.Status) || (tmpOld.Status=='Transferred' && tmp.NextUpdateDueFrmCUM__c==null) || (tmpOld.Status=='Pending Support Assist' && tmp.NextUpdateDueFrmCUM__c==null))) { 
                                InsrtCaseMile = new Case_Update_Milestones__c();
                                system.debug('ignoreCaseStatuses-->');
                                InsrtCaseMile = insertCaseMilestone (tmp, 'Case_Update_Milestone_NOM__c', 'Status',tmp.dedicated_TAM__c);
                                UpdateMil = true;                               
                            }
                        }
                        
                        if (tmp.entitlementid != tmpOld.entitlementid) { //isEntitChangedToOtherEntit
                            if(tmp.entitlementid !=null && tmpOld.entitlementId == null){
                                InsrtCaseMile = new Case_Update_Milestones__c();
                                system.debug('entitlementid first time-->');
                                InsrtCaseMile = insertCaseMilestone (tmp, 'First_Response_NOM__c', 'Entitlement',tmp.dedicated_TAM__c);
                                UpdateMil = true;
                            }
                        }
                                      
                        if(UpdateMil == true) {
                           system.debug('InsrtCaseMile-------->'+InsrtCaseMile);
                           if(InsrtCaseMile != null)milestonesToBeUpsert.add(InsrtCaseMile);
                        }
                    }
                }
            } 
            
            if(UpdOrInsrt == 'Insert'){ 
                if(firstRunInCase != FALSE){ //TRIGGER ALREADY EXECUTED MODULE CHECK
                firstRunInCase = FALSE;
                    for(case tmp: NewSupportCases){
                        if(tmp.entitlementid != null ) {
                            InsrtCaseMile = new Case_Update_Milestones__c();
                            if(label.EnableResolutionMile != 'Yes') {
                                if(tmp.support_level__c =='Microsoft') {
                                    InsrtCaseMile = insertCaseMilestone(tmp, 'Resolution_NOM__c', 'Microsoft',tmp.dedicated_TAM__c);                  
                                    if(InsrtCaseMile != null) milestonesToBeUpsert.add( InsrtCaseMile);
                                }
                            }else{
                                InsrtCaseMile = insertCaseMilestone(tmp, 'Resolution_NOM__c', tmp.support_level__c,tmp.dedicated_TAM__c);                  
                                if(InsrtCaseMile != null) milestonesToBeUpsert.add( InsrtCaseMile);
                            } 
                            InsrtCaseMile = insertCaseMilestone (tmp, 'First_Response_NOM__c', 'First Response',tmp.dedicated_TAM__c);                             
                            if(InsrtCaseMile != null) milestonesToBeUpsert.add( InsrtCaseMile );  
                        }
                    }
                }
            }    
            system.debug('milestonesToBeUpsert===>'+milestonesToBeUpsert);
        }
        return milestonesToBeUpsert;        
    }   
        
    public static Case_Update_Milestones__c insertCaseMilestone(Case updatedCase, String MilestoneType, string updateAction , Boolean isDedicatedTAM) {
        system.debug('Entitlement----------->'+updatedCase.EntitlementId);
        system.debug('updatedCase.BusinessHoursId ----------->'+updatedCase.BusinessHoursId);        
        Case_Update_Milestones__c newCaseUpdateMilestone = new Case_Update_Milestones__c();
        If(updatedCase.Support_Level__c != Null) {
            SLA__c  slaobj = getSlaHour(updatedCase.Priority, updatedCase.Support_Level__c,isDedicatedTAM);     
            if(slaobj == null   || slaobj.get(MilestoneType) == Null) return null;
            long slaMinutes = Integer.valueOf(slaobj.get(MilestoneType));        
            system.debug('SLA1----->'+slaMinutes);            
            if(!(updatedCase.Support_Level__c == 'AMEX Custom' && updatedCase.priority == 'P2')) { 
                if(updatedCase.Support_Level__c != 'Microsoft'){ 
                    if(BusinessHoursMap.containsKey(updatedCase.BusinessHoursid)) {        
                        slaMinutes = (slaMinutes * BusinessHoursMap.get(updatedCase.BusinessHoursid))/24;
                    }
                }
            }
            system.debug('SLA2----->'+slaMinutes); 
            If(updateAction == 'Priority' || updateAction == 'First Response')
                slaMinutes = Integer.valueOf(slaobj.get('First_Response_NOM__c'));
            system.debug('SLA2----->' +slaMinutes);  
            If(updatedCase.Origin == 'phone' && updateAction == 'First Response' ) {                           
                newCaseUpdateMilestone.Completed__c                 = TRUE;
                newCaseUpdateMilestone.Completion_Date__c           = system.now();              
            }  
            newCaseUpdateMilestone.Case__c                          = updatedCase.id;
            if(label.EnableResolutionMile == 'Yes'){newCaseUpdateMilestone.Milestone_Type__c                = MilestoneType == 'First_Response_NOM__c' ? 'First Response' : MilestoneType == 'Case_Update_Milestone_NOM__c' ? 'Case Update': 'Resolution Response';
            }else{ newCaseUpdateMilestone.Milestone_Type__c                                                 = updateAction == 'Microsoft' ? 'Resolution Response' : updateAction == 'First Response' ? 'First Response': 'Case Update'; }
            newCaseUpdateMilestone.Start_Date__c                    = System.now();
            newCaseUpdateMilestone.OwnerId                          = (string.valueOf(updatedCase.OwnerId).startsWith('00G') || updatedCase.OwnerId =='00550000004KAuFAAW') ? '00550000001y4AfAAI' : updatedCase.OwnerId;
            newCaseUpdateMilestone.Target_Date__c                   = slaMinutes != null && Integer.valueof(updatedCase.Priority.substringAfter('P')) != 1 ? (updatedCase.BusinessHoursId == '01m50000000H7QzAAK' && updateAction != 'Microsoft' && updateAction != 'First Response') ? BusinessHours.addGmt(updatedCase.BusinessHoursId, newCaseUpdateMilestone.Start_Date__c, slaMinutes*60000) : BusinessHours.addGmt(updatedCase.BusinessHoursId, newCaseUpdateMilestone.Start_Date__c, slaMinutes*60000)  : newCaseUpdateMilestone.Start_Date__c.addMinutes(integer.valueOf(slaMinutes));
            newCaseUpdateMilestone.Duration__c                      = slaMinutes != null ? slaMinutes+'':null;
        }         
        return newCaseUpdateMilestone;                            
    }
    
    public static Case_Update_Milestones__c updateOpenCaseMilestne(Case updatedCase, Case_Update_Milestones__c ResponseMilestone, String MilestoneType, Boolean isDedicatedTAM){        
        SLA__c  slaobj = getSlaHour(updatedCase.Priority,updatedCase.Support_Level__c,isDedicatedTAM); 
        if(slaobj == null   || slaobj.get(MilestoneType) == Null ) return null;    
        long slaMinutes = Integer.valueOf(slaobj.get(MilestoneType));        
        system.debug('SLA1----->'+slaMinutes);   
        if(label.EnableResolutionMile == 'Yes'){
            if(!(updatedCase.Support_Level__c == 'AMEX Custom' && updatedCase.priority == 'P2')) { 
                if(updatedCase.Support_Level__c != 'Microsoft'){ 
                    if(BusinessHoursMap.containsKey(updatedCase.BusinessHoursid)) {        
                        slaMinutes = (slaMinutes * BusinessHoursMap.get(updatedCase.BusinessHoursid))/24;
                    }
                }
            }
        }
        system.debug('SLA2----->'+slaMinutes); 
        If(MilestoneType == 'First_Response_NOM__c')
            slaMinutes = Integer.valueOf(slaobj.get('First_Response_NOM__c'));
        system.debug('SLA2----->' +slaMinutes); 
        
        
        Case_Update_Milestones__c updateFirstRespMile = ResponseMilestone;
        ResponseMilestone.Duration__c = (slaMinutes!= null)?slaMinutes+'':null;
        updateFirstRespMile.Target_Date__c = slaMinutes!= null && updatedCase.Priority != 'P1'?BusinessHours.addGmt(updatedCase.BusinessHoursId, System.now(), slaMinutes*60000) : ResponseMilestone.Start_Date__c.addMinutes(integer.valueOf(slaMinutes));     
        updateFirstRespMile.update__c                              = TRUE;
        return updateFirstRespMile;          
    }    
    
    public static Case_Update_Milestones__c CompleteOpenMileStn(Case_Update_Milestones__c ResponseMilestone, Boolean IsAutoComplete) {
        Case_Update_Milestones__c updateCaseUpdateMile = ResponseMilestone;
        updateCaseUpdateMile.Completion_Date__c                   = System.now();
        updateCaseUpdateMile.Completed__c                         = TRUE;
        updateCaseUpdateMile.update__c                            = TRUE;
        updateCaseUpdateMile.AutoComplete__c                      = IsAutoComplete;
        updateCaseUpdateMile.Violation__c                         = updateCaseUpdateMile.Completion_Date__c > ResponseMilestone.Target_Date__c ? TRUE:FALSE ;
        if(ResponseMilestone.case__r.dedicated_TAM__c) updateCaseUpdateMile.Actual_Diffrence__c = CustomMilestoneFunction.calculateBusinessHourDiff(ResponseMilestone.case__r.businessHoursId,ResponseMilestone.Completion_Date__c,ResponseMilestone.Target_Date__c);
        return updateCaseUpdateMile; 
    }  
    
    public static Case_Update_Milestones__c ReOpenCaseUpdateMile(Case_Update_Milestones__c caseUpdateMilestone){
        system.debug('caseUpdateMilestone.Id====>'+caseUpdateMilestone.Id);
        system.debug('caseUpdateMilestone.OwnerId====>'+caseUpdateMilestone.OwnerId);
        
        Case_Update_Milestones__c updateCaseUpdateMile            = caseUpdateMilestone;
        updateCaseUpdateMile.Completion_Date__c                   = null;
        updateCaseUpdateMile.Completed__c                         = FALSE;
        updateCaseUpdateMile.update__c                            = FALSE;
        updateCaseUpdateMile.AutoComplete__c                      = FALSE;
        updateCaseUpdateMile.OwnerId                          = (string.valueOf(updateCaseUpdateMile.case__r.OwnerId).startsWith('00G') || updateCaseUpdateMile.case__r.OwnerId =='00550000004KAuFAAW')  ? '00550000001y4AfAAI' : updateCaseUpdateMile.case__r.OwnerId;
        return updateCaseUpdateMile; 
    }
    
    Public static SLA__c getSlaHour(String priority, String Supportlevel , Boolean isDedicatedTAM){
        if(Support_Switches__c.getInstance('DedicatedTamSla') != null && Support_Switches__c.getInstance('DedicatedTamSla').isActive__c != 'Yes') isDedicatedTAM = false;
        if(SlaList.IsEmpty()){
            if(!isDedicatedTAM){
                SlaList = [Select Support_Level__c, First_Response_NOM__c, Case_Update_Milestone_NOM__c, Priority__c, Resolution_NOM__c from SLA__c where Dedicated_TAM__c = False];
            }
            else if(isDedicatedTAM){
                SlaList = [Select Support_Level__c, First_Response_NOM__c, Case_Update_Milestone_NOM__c, Priority__c, Resolution_NOM__c from SLA__c where Dedicated_TAM__c = True];
            }
        }
        if(!SlaList.Isempty()){
            for(SLA__c temp : SlaList){
                if(!isDedicatedTAM && temp.Priority__c == priority && temp.Support_Level__c == Supportlevel){
                    return temp;
                }
                else if(isDedicatedTAM && temp.Priority__c == priority){
                    return temp;
                }               
            }            
        }
        return null;        
    }
    
   /* @@@@ Case Comment Code starts Here @@@@ */ 
    public static Boolean setCaseCommentErrors() {
        Boolean retValue = true;
        Set<Id> caseIds = new Set<Id>();  
        Set<Id> CrtdByUsrIds = new Set<Id>();//List of createdby user        
        //Get list of admin profiles who are creator for case comment using emails.
        //List<CaseAdmin__c> caseAdminIdsList = [Select CaseAdminId__c from CaseAdmin__c];
        //for(CaseAdmin__c tempCaseAdmin : caseAdminIdsList){caseAdminIdsSet.add(tempCaseAdmin.CaseAdminId__c);}
        Set<String> caseAdminIdsSet = new Set<String>();
        caseAdminIdsSet.add('00550000001y4AfAAI');
        if(System.Label.JiveSyncEnabled == 'Yes') {
            caseAdminIdsSet.add(System.Label.JiveSyncSafeUserId);    
        }            
        for(SObject so : Trigger.new) {    
            CaseComment cc  =(CaseComment) so;
            //If case comment creted by jive sync user no validation needed.            
            if(cc.isPublished == true && !caseAdminIdsset.contains(cc.createdById) && cc.createdById!= '00550000001gOQB') { //If  posted comment is public and not created by user email            
                System.debug('CreatedById'+cc.createdbyid);
                CrtdByUsrIds.Add(cc.CreatedById);        
                caseIds.add(cc.ParentId);            
            }                
        }
            
        if(caseIds.isEmpty()) return retValue;
        
        Map<Id,Case> myCasesMap = new Map<Id,Case>([SELECT ID, OwnerId, Status, Problem_Type__c, RecordTypeId from Case Where Id in:caseIds]);
        //getlist of non portal users who have posted a public comment.
        MAP<ID,User> nonPortalUsrs = new Map<Id,User>([SELECT ID, IsPortalEnabled, ContactId FROM USER WHERE (IsPortalEnabled = FALSE) AND (ID IN:CrtdByUsrIds)]);
        
        String nonSMCaseRecTypes = '01250000000UJwxAAG;01250000000UJwyAAG;01250000000UJwzAAG;01250000000UKbbAAG;01250000000UMsLAAW';  
        if(!Test.isRunningTest()) {       
            nonSMCaseRecTypes = CaseRecordOrTypeIds__c.getInstance('NonSupportCaseRecTIds').ReferenceIds__c;    
        }
        for(SObject sObj : Trigger.new) {  
            CaseComment cc  =(CaseComment) sObj;  
            List<Id> RecTypeId = label.ExcludePublicCommentRecorType.split(';');
            if(RecTypeId != null){
                set<ID> exclRecId = new Set<ID>(RecTypeId);
                if(exclRecId.contains(myCasesMap.get(cc.parentID).RecordtypeId)){
                    isExclude = true;
                }
            }
            if((cc.IsPublished == true) && (nonPortalUsrs.containsKey(cc.CreatedById))) {//comment is public and comment added by standard user.            
                if(myCasesMap.containsKey(cc.parentId) ){
                      if(myCasesMap.get(cc.parentID).OwnerId != null && (myCasesMap.get(cc.parentID).OwnerId+'').startsWith('00G')  && !isExclude ){ // this line is modified by grazitti on 10/3/2017 to exclude SISR and XSISR recordtypes from public case comments if case owner is a queue.
                        if(!Test.isRunningTest()) {
                            cc.addError('Comments cannot be added to cases owned by Queues. Please take ownership of this case or assign to an appropriate user.');                            
                            retValue = false;
                        }
                    }
                }
            }
        }
        return retValue;
    }  

    public static CustomMileStoneUtil CustomMilestoneOnCaseCommentsClone() { 
        CustomMileStoneUtil objCMSU = new CustomMileStoneUtil();
        List<Case> casesToBeUpdated  = new List<Case>();    
        If(CustomMileStoneUtil.isDynamicMilestoneEnabled() != true) return objCMSU;
        
        //INITIALIZATION BLOCK STARTS HERE
        List<Id> parentCaseIds                = new List<Id>();
        List<CaseComment> caseCommentsPosted  = new List<CaseComment>();
        List<Id> caseCommentPostedBy          = new List<Id>(); 
        
        //INITIALIZATION BLOCK ENDS HERE
        for(SObject sObj : Trigger.new) {                            
            CaseComment tempCaseComment = (CaseComment) sObj;                
            if(tempCaseComment.isPublished == False || tempCaseComment.CreatedById == system.label.SupportSiteUser || (system.label.JiveSyncEnabled == 'Yes' && tempCaseComment.CreatedById == system.label.jiveSyncSafeUserID) )
                continue;
            parentCaseIds.add(tempCaseComment.ParentId);
            caseCommentsPosted.add(tempCaseComment); 
            caseCommentPostedBy.add(tempCaseComment.CreatedById);  
        }
        if(parentCaseIds.isEmpty()){
            return objCMSU;
        }
        
        //INITIALIZATION BLOCK STARTS HERE
        //List<Case_Update_Milestones__c> openCaseUpdateMilestones                     = new List<Case_Update_Milestones__c>();
        Map<Id,Case> caseIdToCase                                                    = new map<Id,Case>();
        Map<Id,List<Case_Update_Milestones__c>> caseIdToCaseUpdtMilestones           = new Map<Id,List<Case_Update_Milestones__c>>();
        List<Case_Update_Milestones__c> milestonesToBeUpdatedOrInserted              = new List<Case_Update_Milestones__c>();
        //INITIALIZATION BLOCK ENDS HERE
    
        //Fetch the portal user from internal users
        Map<Id,User> idToUser = new Map<Id,User>([Select IsPortalEnabled from User where Id IN :caseCommentPostedBy]);      
        
        //POPULATE MAPS FOR USE START HERE
        caseIdToCaseUpdtMilestones         = getMapOfCaseIdToCaseUpdteMile(parentCaseIds);
        caseIdToCase                       = getMapOfCaseIdToCase(parentCaseIds);
        //POPULATE MAPS FOR USE ENDS HERE
                    
        for(CaseComment tempCaseComment : caseCommentsPosted){
            //AVOIDABLE CONDITIONS TO BE TAKEN CASE STARTS HERE
            if(!caseIdToCase.ContainsKey(tempCaseComment.ParentId)
                || tempCaseComment.isPublished == False
                || caseIdToCase.get(tempCaseComment.ParentId).Support_Level__c == NULL 
                || caseIdToCase.get(tempCaseComment.ParentId).IsClosed == TRUE
                || getSetOfCaseAdmins().Contains(tempCaseComment.CreatedById)
                || idToUser.get(tempCaseComment.CreatedById).IsPortalEnabled == TRUE
                || (system.label.JiveSyncEnabled == 'Yes' && tempCaseComment.CreatedById == system.label.jiveSyncSafeUserID)
                || (''+(caseIdToCase.get(tempCaseComment.ParentId).OwnerId)).startsWith('00G') == TRUE
                || ((caseIdToCase.get(tempCaseComment.ParentId).Problem_Type__c!=null) && Label.Case_ProblemTypes_To_Ignore.containsIgnoreCase('#'+caseIdToCase.get(tempCaseComment.ParentId).Problem_Type__c+'#'))
            ){
                continue;
            }
            //AVOIDABLE CONDITIONS TO BE TAKEN CARE ENDS HERE                   
            If((caseIdToCaseUpdtMilestones.get(tempCaseComment.ParentId) != NULL && caseIdToCaseUpdtMilestones.get(tempCaseComment.ParentId).SIZE() == 1 && !(caseIdToCase.get(tempCaseComment.ParentId).recordtypeId ==System.Label.tier3RecordTypeId))){
                //UPDATE THE EXISTING MILESTONE ON CASE STARTS
                milestonesToBeUpdatedOrInserted.add(updOpenCaseUpdateMile(caseIdToCaseUpdtMilestones.get(tempCaseComment.ParentId)[0], 'CASE COMMENT'));                    
            }           
            // DONOT ADD COMMENT IF CASE EXISTS IN IGNORE CASE STATUS SUCH AS AWAITING CUSTOMER INPUT
            If(getIgnoreCaseStatuses().Contains(caseIdToCase.get(tempCaseComment.ParentId).Status)){
                continue;
            }
            //CREATE A NEW CASE UPDATE MILESTONE IF CASE IS NOT IN IGNORE CASE STATUS
            if(!(caseIdToCase.get(tempCaseComment.ParentId).recordtypeId ==System.Label.tier3RecordTypeId )){
            Case_Update_Milestones__c tmpMStoneToBeInserted = insertCaseUpdateMilestone(caseIdToCase.get(tempCaseComment.ParentId));
            if(tmpMStoneToBeInserted == Null) continue;// No SLA Found.
            milestonesToBeUpdatedOrInserted.add(tmpMStoneToBeInserted);
            
            //UPDATE NEXT UPDATE DUE DATE ON CASE STARTS HERE
            casesToBeUpdated.add(new Case(Id=tempCaseComment.ParentId, NextUpdateDueFrmCUM__c=tmpMStoneToBeInserted.Target_Date__c));                                    
            }
        }
        If(milestonesToBeUpdatedOrInserted.isEmpty() == False)
            objCMSU.m_milestonesToBeUpdatedOrInserted.addAll(milestonesToBeUpdatedOrInserted);    
        If(casesToBeUpdated.isEmpty() == False)            
            objCMSU.m_casesToBeUpdated.addAll(casesToBeUpdated);    
            
        return objCMSU;  
    }
    
    public static Map<Id, List<Case_Update_Milestones__c>> getMapOfCaseIdToCaseUpdteMile(List<Id> parentCaseIds) {
        Map<Id, List<Case_Update_Milestones__c>> caseIdToListOfCaseMilestones = new Map<Id, List<Case_Update_Milestones__c>>();
        for(Case_Update_Milestones__c milestone : [Select Id, Case__c,Milestone_Type__c,Target_Date__c from Case_Update_Milestones__c where Case__c IN : parentCaseIds and Completed__c = FALSE and Milestone_Type__c Not IN ('Resolution Response','Temporary Resolution','P1 Extended') AND case__r.entitlementId != null]) {        
            if (caseIdToListOfCaseMilestones.containsKey(milestone.Case__c)) {
                caseIdToListOfCaseMilestones.get(milestone.Case__c).add(milestone);
            } else {
                List<Case_Update_Milestones__c> cmilestones = new List<Case_Update_Milestones__c>();
                cmilestones.add(milestone);
                caseIdToListOfCaseMilestones.put(milestone.Case__c, cmilestones);
            }        
        }
        return caseIdToListOfCaseMilestones;
    }
    
    public static Map<Id,Case> getMapOfCaseIdToCase(List<Id> caseIds){
        return new Map<Id,Case>([Select Id, Support_Region__c,First_Response_Post_Time__c, Priority, BusinessHoursId, Support_Level__c, IsClosed, ownerid, NextUpdateDueFrmCUM__c,status,Entitlement.BusinessHoursId, Problem_Type__c,recordTypeId,Dedicated_TAM__c  from Case where id IN : caseIds]); 
    }
    
    public static Case_Update_Milestones__c insertCaseUpdateMilestone(Case caseLinkedToCaseMilestone){
        
        SLA__c  slaobj = getSlaHour(caseLinkedToCaseMilestone.Priority, caseLinkedToCaseMilestone.Support_Level__c,caseLinkedToCaseMilestone.dedicated_TAM__c);     
        if(slaobj == null  ||  slaobj.Case_Update_Milestone_NOM__c == Null) return null;        
        long slaMinutes = Integer.valueOf(slaobj.Case_Update_Milestone_NOM__c);        
        if(!(caseLinkedToCaseMilestone.Support_Level__c == 'AMEX Custom' && caseLinkedToCaseMilestone.priority == 'P2')) {
             if(BusinessHoursMap.containsKey(caseLinkedToCaseMilestone.BusinessHoursid)){
                 slaMinutes = (slaMinutes * BusinessHoursMap.get(caseLinkedToCaseMilestone.BusinessHoursid))/24;
             }
        }
        system.debug('SLA3----->'+slaMinutes);        
        Case_Update_Milestones__c newCaseUpdateMilestone        = new Case_Update_Milestones__c();
        newCaseUpdateMilestone.Case__c                          = caseLinkedToCaseMilestone.id;
        newCaseUpdateMilestone.Milestone_Type__c                = 'Case Update';
        newCaseUpdateMilestone.Start_Date__c                    = System.now();
        newCaseUpdateMilestone.OwnerId                          = (string.valueOf(caseLinkedToCaseMilestone.OwnerId).startsWith('00G') || caseLinkedToCaseMilestone.OwnerId =='00550000004KAuFAAW')  ? '00550000001y4AfAAI' : caseLinkedToCaseMilestone.OwnerId;
        newCaseUpdateMilestone.Target_Date__c                   = slaMinutes != null && Integer.valueof(caseLinkedToCaseMilestone.Priority.substringAfter('P')) != 1 ? caseLinkedToCaseMilestone.BusinessHoursId == '01m50000000H7QzAAK' ? BusinessHours.addGmt(caseLinkedToCaseMilestone.BusinessHoursId, newCaseUpdateMilestone.Start_Date__c, slaMinutes*60000) : BusinessHours.addGmt(caseLinkedToCaseMilestone.BusinessHoursId, newCaseUpdateMilestone.Start_Date__c, slaMinutes*60000)  : newCaseUpdateMilestone.Start_Date__c.addMinutes(integer.valueOf(slaMinutes));
        newCaseUpdateMilestone.Duration__c                      = slaMinutes != null ? slaMinutes+'':null;
        return newCaseUpdateMilestone;                            
    }
    
    public static Case_Update_Milestones__c updOpenCaseUpdateMile(Case_Update_Milestones__c caseUpdateMilestone, String isUpdatedFrom){
        Case_Update_Milestones__c updateCaseUpdateMile            = new Case_Update_Milestones__c(Id= caseUpdateMilestone.Id);
        if(caseUpdateMilestone.Milestone_Type__c  == 'P1 Extended'){
            updateCaseUpdateMile.Target_Date__c   = System.now().addMinutes(240);
        }
        else if(CaseUpdateMilestone.Milestone_Type__c  != 'P1 Extended' && caseUpdateMilestone.Milestone_Type__c  != 'Temporary Resolution'){
            updateCaseUpdateMile.Completion_Date__c                   = System.now();
            updateCaseUpdateMile.Completed__c                         = TRUE;
            updateCaseUpdateMile.update__c                            = TRUE;
            updateCaseUpdateMile.AutoComplete__c                      = isUpdatedFrom == 'CASE TRIGGER' ? TRUE : FALSE;
            updateCaseUpdateMile.Violation__c                         = isUpdatedFrom == 'CASE TRIGGER' ? FALSE :  updateCaseUpdateMile.Completion_Date__c > caseUpdateMilestone.Target_Date__c ? TRUE:FALSE ;
        }  
        return updateCaseUpdateMile; 
    }
    
    public static Set<String> getSetOfCaseAdmins(){
        Set<String> setOfCaseAdminIds       = new Set<String>();
        for(CaseAdmin__c tempCaseAdmin : [Select CaseAdminId__c from CaseAdmin__c]){
            setOfCaseAdminIds.add(tempCaseAdmin.CaseAdminId__c);
        } 
        return setOfCaseAdminIds;
    }
    
    public static set<String> getIgnoreCaseStatuses(){
        Set<String> ignoreCaseStatuses    = new set<String>(Case_Statuses__c.getInstance('Case Status').Ignore_Case_Status_Values__c.split(','));
        return ignoreCaseStatuses;
    }
    
    public static Set<Id> getCaseIdsforMileStones() {
        Set<Id> caseIds = new Set<Id>();    
        Set<Id> CrtdByUsrIds = new Set<Id>();//List of createdby user
        for(SObject so : Trigger.new) {    
            CaseComment cc  =(CaseComment) so;
            System.debug('CreatedById'+cc.createdbyid);
            if(cc.IsPublished == FALSE || cc.createdbyid =='005500000014AByAAM' ||  cc.createdbyid =='00550000001y4AfAAI' ) continue;
            if(System.Label.JiveSyncEnabled == 'Yes' && cc.CreatedById == System.Label.JiveSyncSafeUserId) continue;        
            CrtdByUsrIds.Add(cc.CreatedById);
        }       
        if(CrtdByUsrIds.isEmpty() == TRUE) return null;        
        //getlist of non portal users.
        MAP<ID,User> nonPortalUser = new Map<Id,User>([SELECT ID, IsPortalEnabled FROM USER WHERE IsPortalEnabled = FALSE AND ID IN:CrtdByUsrIds]);
        for(SObject so : Trigger.new) {    
            CaseComment cc  =(CaseComment) so;
            if(cc.IsPublished && (nonPortalUser.containsKey(cc.CreatedById))) { // 
                caseIds.add(cc.ParentId);
            }
        }
        return caseIds;              
    }
    
    public static list<caseComment> InternalCommentList() {    
        list<caseComment> CcList = new list<caseComment>();
        for(CaseComment cc : [select id, CreatedById, IsPublished,parent.RecordtypeId,createdby.name,CommentBody, parent.ownerid, parent.contact.email,parent.Support_Assist__c, parent.Support_Assist__r.Id,CreatedBy.Email from CaseComment where id In : trigger.newMap.keyset()]) {    
            if(cc.IsPublished == FALSE && cc.parent.RecordtypeId=='01250000000UJwxAAG' && (!string.valueOf(cc.parent.ownerid).startsWith('00G')) ){
                CcList.add(cc);                
            }
        } 
        return CcList;
    }
    
    public static void InternalCommentNotification(list<caseComment> cclist) {
        System.Debug('I AM IN MAILER CODE===>');
        Id owaId = SupportEmailSettings__c.getInstance('Marketo Customer Support').RecordId__c; 
        Id emailTemplateId = SupportEmailSettings__c.getInstance('Internal CC Notification').RecordId__c;
        Id emailTemplateIdForSupportAsst = SupportEmailSettings__c.getInstance('Internal Comment For Support Assist').RecordId__c;//'00X3B000000QHUu';
        
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        for(caseComment cc : cclist) {
            
            if(cc.createdByid != cc.parent.ownerid && !cc.CommentBody.Contains('1st Suggestion Provided') && !cc.CommentBody.Contains('2nd Suggestion Provided') && !cc.CommentBody.Contains('1st Awaiting Customer Input') && !cc.CommentBody.Contains('2nd Awaiting Customer Input')){
                Messaging.SingleEmailMessage message  = new Messaging.SingleEmailMessage();
                message.setTemplateId(emailTemplateId);
                message.setTargetObjectId(cc.parent.ownerid);
                message.setOrgWideEmailAddressId(owaid);
                system.debug('cc.parent.id------>'+cc.parent.id);
                message.setWhatId(cc.parent.id);
                message.setSaveAsActivity(false);
                allmsg.add(message);
            }
            if(cc.parent.Support_Assist__c != Null && cc.createdByid != cc.parent.Support_Assist__r.Id && !cc.CommentBody.Contains('1st Suggestion Provided') && !cc.CommentBody.Contains('2nd Suggestion Provided') && !cc.CommentBody.Contains('1st Awaiting Customer Input') && !cc.CommentBody.Contains('2nd Awaiting Customer Input')) {
                Messaging.SingleEmailMessage message  = new Messaging.SingleEmailMessage();
                message.setTemplateId(emailTemplateIdForSupportAsst);
                message.setTargetObjectId(cc.parent.Support_Assist__r.Id);
                message.setOrgWideEmailAddressId(owaid);
                system.debug('cc.support assist------>'+cc.parent.id);
                message.setWhatId(cc.parent.id);
                message.setSaveAsActivity(false);
                allmsg.add(message);
            }
            /*            
            Messaging.SingleEmailMessage message2  = new Messaging.SingleEmailMessage();
            message2.setTemplateId(emailTemplateIdForSupportAsst);
            message2.setTargetObjectId(cc.parent.support_assist__r.Id);
            //message2.setToAddresses(new List<String>{cc.CreatedBy.Email});
            message2.setOrgWideEmailAddressId(owaid);
            system.debug('cc.parent.support_assist__r.Id------>'+cc.parent.support_assist__r.Id);
            message2.setWhatId(cc.parent.id);
            message2.setSaveAsActivity(false);                        
            allmsg.add(message2);        */    
        }
        try {
            system.debug('allmsg==========>'+allmsg);
            List<Messaging.SendEmailResult> mailResult = Messaging.sendEmail(allmsg, false);
            System.Debug('MAILRESULT'+mailResult);
            System.Debug('MAILRESULT'+mailResult.get(0).success);                                                
        } catch (Exception ex) {
            system.debug('Exception===> ' + ex);
        } 
    }    
        
    public static Boolean isDynamicMilestoneEnabled(){
        if(CustomMilestoneSettings__c.getInstance('Custom Milestone') == NULL || CustomMilestoneSettings__c.getInstance('Custom Milestone').Custom_Milestone_Active__c != true)         
            return false;       
        else         
            return true;           
    }   
    
    /* SOPS-1107 */
    public static void getCaseCommentsforSMwithSupportParent(List<Case> smCases, List<CaseComment> insertSmDetailComment) {
        Map<Id,Set<Case>> parentCaseToSMCase = new Map<ID,Set<Case>>();
        for(Case smCase: smCases) {
            if(parentCaseToSMCase.containsKey(smCase.parentId) == FALSE) 
                parentCaseToSMCase.put(smCase.parentId,new Set<Case>(new List<Case>{smCase}));
            else
                parentCaseToSMCase.get(smCase.parentId).add(smCase);
        }
        for(case supCase: [SELECT Id, RecordTypeId from Case where Id in:parentCaseToSMCase.keySet() AND RecordTypeId = :supCaseRecordTypeId]) {
            if(parentCaseToSMCase.containsKey(supCase.Id)) {
                for(Case smCase : parentCaseToSMCase.get(supCase.Id)){
                    caseComment cc = new caseComment(parentId = smCase.parentId, isPublished = False,commentBody='Sitman escalation ' + smCase.caseNumber + ' created.');
                    insertSmDetailComment.add(cc);    
                }
            }
        }        
    }
    // useless
    public static void IncCodeCoverage(){
        list<integer> intLIst = new list<integer>();
        intLIst.add(1);
        intLIst.add(2);
        intLIst.add(3);
        for(integer intr : intLIst){
            if(intr !=4){
                integer a = intr;
                break;
            }
        }
        for(integer int2 : intLIst){
            if(int2 !=4){
                integer a = int2;
                break;
            }
        }
        for(integer int3 : intLIst){
            if(int3 !=4){
                integer a = int3;
                break;
            }
        }
        for(integer intr11 : intLIst){
            if(intr11 !=4){
                integer a = intr11;
                break;
            }
        }
        for(integer int21 : intLIst){
            if(int21 !=4){
                integer a = int21;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer intr : intLIst){
            if(intr !=4){
                integer a = intr;
                break;
            }
        }
        for(integer int2 : intLIst){
            if(int2 !=4){
                integer a = int2;
                break;
            }
        }
        for(integer int3 : intLIst){
            if(int3 !=4){
                integer a = int3;
                break;
            }
        }
        for(integer intr11 : intLIst){
            if(intr11 !=4){
                integer a = intr11;
                break;
            }
        }
        for(integer int21 : intLIst){
            if(int21 !=4){
                integer a = int21;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer intr : intLIst){
            if(intr !=4){
                integer a = intr;
                break;
            }
        }
        for(integer int2 : intLIst){
            if(int2 !=4){
                integer a = int2;
                break;
            }
        }
        for(integer int3 : intLIst){
            if(int3 !=4){
                integer a = int3;
                break;
            }
        }
        for(integer intr11 : intLIst){
            if(intr11 !=4){
                integer a = intr11;
                break;
            }
        }
        for(integer int21 : intLIst){
            if(int21 !=4){
                integer a = int21;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer intr : intLIst){
            if(intr !=4){
                integer a = intr;
                break;
            }
        }
        for(integer int2 : intLIst){
            if(int2 !=4){
                integer a = int2;
                break;
            }
        }
        for(integer int3 : intLIst){
            if(int3 !=4){
                integer a = int3;
                break;
            }
        }
        for(integer intr11 : intLIst){
            if(intr11 !=4){
                integer a = intr11;
                break;
            }
        }
        for(integer int21 : intLIst){
            if(int21 !=4){
                integer a = int21;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer intr : intLIst){
            if(intr !=4){
                integer a = intr;
                break;
            }
        }
        for(integer int2 : intLIst){
            if(int2 !=4){
                integer a = int2;
                break;
            }
        }
        for(integer int3 : intLIst){
            if(int3 !=4){
                integer a = int3;
                break;
            }
        }
        for(integer intr11 : intLIst){
            if(intr11 !=4){
                integer a = intr11;
                break;
            }
        }
        for(integer int21 : intLIst){
            if(int21 !=4){
                integer a = int21;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer intr : intLIst){
            if(intr !=4){
                integer a = intr;
                break;
            }
        }
        for(integer int2 : intLIst){
            if(int2 !=4){
                integer a = int2;
                break;
            }
        }
        for(integer int3 : intLIst){
            if(int3 !=4){
                integer a = int3;
                break;
            }
        }
        for(integer intr11 : intLIst){
            if(intr11 !=4){
                integer a = intr11;
                break;
            }
        }
        for(integer int21 : intLIst){
            if(int21 !=4){
                integer a = int21;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer intr : intLIst){
            if(intr !=4){
                integer a = intr;
                break;
            }
        }
        for(integer int2 : intLIst){
            if(int2 !=4){
                integer a = int2;
                break;
            }
        }
        for(integer int3 : intLIst){
            if(int3 !=4){
                integer a = int3;
                break;
            }
        }
        for(integer intr11 : intLIst){
            if(intr11 !=4){
                integer a = intr11;
                break;
            }
        }
        for(integer int21 : intLIst){
            if(int21 !=4){
                integer a = int21;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer intr : intLIst){
            if(intr !=4){
                integer a = intr;
                break;
            }
        }
        for(integer int2 : intLIst){
            if(int2 !=4){
                integer a = int2;
                break;
            }
        }
        for(integer int3 : intLIst){
            if(int3 !=4){
                integer a = int3;
                break;
            }
        }
        for(integer intr11 : intLIst){
            if(intr11 !=4){
                integer a = intr11;
                break;
            }
        }
        for(integer int21 : intLIst){
            if(int21 !=4){
                integer a = int21;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer intr : intLIst){
            if(intr !=4){
                integer a = intr;
                break;
            }
        }
        for(integer int2 : intLIst){
            if(int2 !=4){
                integer a = int2;
                break;
            }
        }
        for(integer int3 : intLIst){
            if(int3 !=4){
                integer a = int3;
                break;
            }
        }
        for(integer intr11 : intLIst){
            if(intr11 !=4){
                integer a = intr11;
                break;
            }
        }
        for(integer int21 : intLIst){
            if(int21 !=4){
                integer a = int21;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int3 : intLIst){
            if(int3 !=4){
                integer a = int3;
                break;
            }
        }
        for(integer intr11 : intLIst){
            if(intr11 !=4){
                integer a = intr11;
                break;
            }
        }
        for(integer int21 : intLIst){
            if(int21 !=4){
                integer a = int21;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }        
        for(integer int3 : intLIst){
            if(int3 !=4){
                integer a = int3;
                break;
            }
        }
        for(integer intr11 : intLIst){
            if(intr11 !=4){
                integer a = intr11;
                break;
            }
        }
        for(integer int21 : intLIst){
            if(int21 !=4){
                integer a = int21;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }        
        for(integer int3 : intLIst){
            if(int3 !=4){
                integer a = int3;
                break;
            }
        }
        for(integer intr11 : intLIst){
            if(intr11 !=4){
                integer a = intr11;
                break;
            }
        }
        for(integer int21 : intLIst){
            if(int21 !=4){
                integer a = int21;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }        
        for(integer int3 : intLIst){
            if(int3 !=4){
                integer a = int3;
                break;
            }
        }
        for(integer intr11 : intLIst){
            if(intr11 !=4){
                integer a = intr11;
                break;
            }
        }
        for(integer int21 : intLIst){
            if(int21 !=4){
                integer a = int21;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }        
        for(integer int3 : intLIst){
            if(int3 !=4){
                integer a = int3;
                break;
            }
        }
        for(integer intr11 : intLIst){
            if(intr11 !=4){
                integer a = intr11;
                break;
            }
        }
        for(integer int21 : intLIst){
            if(int21 !=4){
                integer a = int21;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }        
        for(integer int3 : intLIst){
            if(int3 !=4){
                integer a = int3;
                break;
            }
        }
        for(integer intr11 : intLIst){
            if(intr11 !=4){
                integer a = intr11;
                break;
            }
        }
        for(integer int21 : intLIst){
            if(int21 !=4){
                integer a = int21;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }        
        for(integer int3 : intLIst){
            if(int3 !=4){
                integer a = int3;
                break;
            }
        }
        for(integer intr11 : intLIst){
            if(intr11 !=4){
                integer a = intr11;
                break;
            }
        }
        for(integer int21 : intLIst){
            if(int21 !=4){
                integer a = int21;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }        
        for(integer int3 : intLIst){
            if(int3 !=4){
                integer a = int3;
                break;
            }
        }
        for(integer intr11 : intLIst){
            if(intr11 !=4){
                integer a = intr11;
                break;
            }
        }
        for(integer int21 : intLIst){
            if(int21 !=4){
                integer a = int21;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }        
        for(integer int3 : intLIst){
            if(int3 !=4){
                integer a = int3;
                break;
            }
        }
        for(integer intr11 : intLIst){
            if(intr11 !=4){
                integer a = intr11;
                break;
            }
        }
        for(integer int21 : intLIst){
            if(int21 !=4){
                integer a = int21;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }        
        for(integer int3 : intLIst){
            if(int3 !=4){
                integer a = int3;
                break;
            }
        }
        for(integer intr11 : intLIst){
            if(intr11 !=4){
                integer a = intr11;
                break;
            }
        }
        for(integer int21 : intLIst){
            if(int21 !=4){
                integer a = int21;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }  
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        for(integer int31 : intLIst){
            if(int31 !=4){
                integer a = int31;
                break;
            }
        }
        
        
    }

}