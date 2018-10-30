public class CustomMilestone{
    public static Boolean skipFirstTimeCodeExecution         = FALSE;
    public static Boolean firstRunInCase                     = TRUE;
    public static Boolean firstRunInCaseComment              = TRUE;
    public static Boolean firstRunInCaseMilestone            = TRUE;
    public static Boolean firstTimeRunInGainsight            = TRUE;
    public static List<SLA__c> SLAs;
    public static Map<id, integer> BusinessHoursMap = new Map<id, integer>{'01m50000000H7Qz' => 24, '01m50000000H7R9' => 9, '01m50000000H7R4' => 9, '01m500000004FoA' => 12, '01m50000000H7RE' => 24};
    
    public CustomMilestone(){
        slas  = [Select Support_Level__c, First_Response_NOM__c, Case_Update_Milestone_NOM__c, Priority__c, Resolution_NOM__c from SLA__c]; 
    }   
    
    public static Case_Update_Milestones__c firstResponseMilestone(Case caseCreated, Integer numOfMinutes){
        Case_Update_Milestones__c newCaseUpdateMilestone = new Case_Update_Milestones__c();
        Integer PriorityLevel = Integer.valueof(caseCreated.Priority.substringAfter('P'));  
            newCaseUpdateMilestone.Case__c                          = caseCreated.id;
            newCaseUpdateMilestone.Milestone_Type__c                = 'First Response';
            newCaseUpdateMilestone.Start_Date__c                    = System.now();
        If(caseCreated.Origin == 'phone'){
            newCaseUpdateMilestone.OwnerId                          = string.valueOf(caseCreated.OwnerId).startsWith('00G') ? '00550000001y4AfAAI' : caseCreated.OwnerId;
            newCaseUpdateMilestone.Completed__c                     = TRUE;
            newCaseUpdateMilestone.Completion_Date__c               = System.Now(); 
        } else{
            newCaseUpdateMilestone.Target_Date__c                   = numOfMinutes!= null && priorityLevel != 1?BusinessHours.addGmt(caseCreated.BusinessHoursId, newCaseUpdateMilestone.Start_Date__c, numOfMinutes*60000) : newCaseUpdateMilestone.Start_Date__c.addMinutes(numOfMinutes); 
            newCaseUpdateMilestone.Duration__c                      = numOfMinutes!= null?numOfMinutes+'':null;
            newCaseUpdateMilestone.OwnerId                          = recordTypeIdAsPerRequest('SupEmailAndSupPortRecTypeId').contains(caseCreated.RecordTypeId)?System.Label.Case_Admin:caseCreated.OwnerId;
        }
        return newCaseUpdateMilestone;       
    }
    
    public static Case_Update_Milestones__c ResolutionMilestone(Case caseCreated, Integer numOfMinutes){
        Case_Update_Milestones__c newCaseUpdateMilestone = new Case_Update_Milestones__c();
        Integer PriorityLevel = Integer.valueof(caseCreated.Priority.substringAfter('P'));  
            newCaseUpdateMilestone.Case__c                          = caseCreated.id;
            newCaseUpdateMilestone.Milestone_Type__c                = 'Resolution Response';
            newCaseUpdateMilestone.Start_Date__c                    = System.now();
            newCaseUpdateMilestone.Target_Date__c                   = numOfMinutes!= null && priorityLevel != 1?BusinessHours.addGmt(caseCreated.BusinessHoursId, newCaseUpdateMilestone.Start_Date__c, numOfMinutes*60000) : newCaseUpdateMilestone.Start_Date__c.addMinutes(numOfMinutes); 
            newCaseUpdateMilestone.Duration__c                      = numOfMinutes!= null?numOfMinutes+'':null;
            newCaseUpdateMilestone.OwnerId                          = recordTypeIdAsPerRequest('SupEmailAndSupPortRecTypeId').contains(caseCreated.RecordTypeId)?System.Label.Case_Admin:caseCreated.OwnerId;
        
        return newCaseUpdateMilestone;       
    }
    
    public static Case_Update_Milestones__c reopenResolMil(case singleCase) {
        
        Integer slaMinutes = getSlaHours(singleCase.Priority,singleCase.Support_Level__c).Resolution_NOM__c.intValue();
        Case_Update_Milestones__c ResolMil = new Case_Update_Milestones__c();
        ResolMil = [select id, Duration__c, Start_Date__c, Target_Date__c, Completion_Date__c, Completed__c, update__c, AutoComplete__c, Violation__c from Case_Update_Milestones__c where case__c =:singleCase.id and  Milestone_Type__c ='Resolution Response'];
         
        ResolMil.Duration__c                          = slaMinutes!= null?slaMinutes+'':null;
        ResolMil.Start_Date__c                        = system.now();
        ResolMil.Target_Date__c                       = slaMinutes!= null && Integer.valueof(singleCase.Priority.substringAfter('P')) != 1?BusinessHours.addGmt(singleCase.BusinessHoursId, System.now(), slaMinutes*60000) : ResolMil.Start_Date__c.addMinutes(slaMinutes);     
        ResolMil.Completion_Date__c                   = null;
        ResolMil.Completed__c                         = FALSE;
        ResolMil.update__c                            = FALSE;
        ResolMil.AutoComplete__c                      = FALSE;
        ResolMil.Violation__c                         = FALSE;
        return ResolMil; 
    }

    
    public static Case_Update_Milestones__c firstRespMilesFrmEntChng(Case caseCreated, Integer numOfMinutes){
        Boolean IS_FIRST_RESPONSE_POSTED = caseCreated.First_Response_Post_Time__c == Null ? FALSE : TRUE;
        Case_Update_Milestones__c newCaseUpdateMilestone = new Case_Update_Milestones__c();
        Integer PriorityLevel = Integer.valueof(caseCreated.Priority.substringAfter('P'));  
        newCaseUpdateMilestone.Case__c                          = caseCreated.id;
        newCaseUpdateMilestone.Milestone_Type__c                = 'First Response';
        newCaseUpdateMilestone.OwnerId                          = string.valueOf(caseCreated.OwnerId).startsWith('00G') ? '00550000001y4AfAAI' : caseCreated.OwnerId;
        If(caseCreated.Origin == 'phone'){
            newCaseUpdateMilestone.Start_Date__c                    = caseCreated.CreatedDate;
            newCaseUpdateMilestone.Completed__c                     = TRUE;
            newCaseUpdateMilestone.Completion_Date__c               = caseCreated.CreatedDate;  
        } else{
            newCaseUpdateMilestone.Start_Date__c                    = caseCreated.CreatedDate;
            newCaseUpdateMilestone.Target_Date__c                   = numOfMinutes!= null && priorityLevel != 1?BusinessHours.addGmt(caseCreated.BusinessHoursId, newCaseUpdateMilestone.Start_Date__c, numOfMinutes*60000) : newCaseUpdateMilestone.Start_Date__c.addMinutes(numOfMinutes); 
            newCaseUpdateMilestone.Duration__c                      = numOfMinutes!= null?numOfMinutes+'':null; //Riz from system npw to null
            newCaseUpdateMilestone.Completion_Date__c               = IS_FIRST_RESPONSE_POSTED ? caseCreated.First_Response_Post_Time__c : NULL;
            newCaseUpdateMilestone.Completed__c                     = IS_FIRST_RESPONSE_POSTED;
            newCaseUpdateMilestone.Violation__c                     = newCaseUpdateMilestone.Completion_Date__c > newCaseUpdateMilestone.Target_Date__c ? TRUE : FALSE;  
        }
        return newCaseUpdateMilestone;       
    }
        
    public static Case_Update_Milestones__c updOpenFirstRespCaseMile(Case updatedCase, Case_Update_Milestones__c firstRespMilestone){
        Integer slaMinutes = getSlaHours(updatedCase.Priority,updatedCase.Support_Level__c).First_Response_NOM__c.intValue();  
            system.debug('SLA1----->'+slaMinutes);        
        Case_Update_Milestones__c updateFirstRespMile = new Case_Update_Milestones__c(Id= firstRespMilestone.Id);
        updateFirstRespMile.Duration__c                            = slaMinutes!= null?slaMinutes+'':null;
        updateFirstRespMile.Target_Date__c                         = slaMinutes!= null && Integer.valueof(updatedCase.Priority.substringAfter('P')) != 1?BusinessHours.addGmt(updatedCase.BusinessHoursId, System.now(), slaMinutes*60000) : firstRespMilestone.Start_Date__c.addMinutes(slaMinutes);
        //Need to analys its reason
        updateFirstRespMile.update__c                              = TRUE;
        //Needs to analyse its reason
        return updateFirstRespMile;  
    }
 
    public static Case_Update_Milestones__c updResolutionCaseMile(Case updatedCase, Case_Update_Milestones__c firstRespMilestone) {
        Integer slaMinutes = getSlaHours(updatedCase.Priority, updatedCase.Support_Level__c).Resolution_NOM__c.intValue();  
        system.debug('SLA1----->'+slaMinutes);        
        Case_Update_Milestones__c updateFirstRespMile = new Case_Update_Milestones__c(Id= firstRespMilestone.Id);
        updateFirstRespMile.Duration__c                            = slaMinutes!= null?slaMinutes+'':null;
        updateFirstRespMile.Target_Date__c                         = slaMinutes!= null && Integer.valueof(updatedCase.Priority.substringAfter('P')) != 1?BusinessHours.addGmt(updatedCase.BusinessHoursId, System.now(), slaMinutes*60000) : firstRespMilestone.Start_Date__c.addMinutes(slaMinutes);
        //Need to analys its reason
        updateFirstRespMile.update__c                              = TRUE;
        //Needs to analyse its reason
        return updateFirstRespMile;  
    }   
        
     public static Case_Update_Milestones__c updOpenCaseUpdateMile(Case_Update_Milestones__c caseUpdateMilestone, String isUpdatedFrom){
        Case_Update_Milestones__c updateCaseUpdateMile = new Case_Update_Milestones__c(Id= caseUpdateMilestone.Id);
        updateCaseUpdateMile.Completion_Date__c                   = System.now();
        updateCaseUpdateMile.Completed__c                         = TRUE;
        updateCaseUpdateMile.update__c                            = TRUE;
        updateCaseUpdateMile.AutoComplete__c                      = isUpdatedFrom == 'CASE TRIGGER' ? TRUE : FALSE;
        updateCaseUpdateMile.Violation__c                         = isUpdatedFrom == 'CASE TRIGGER' ? FALSE :  updateCaseUpdateMile.Completion_Date__c > caseUpdateMilestone.Target_Date__c ? TRUE:FALSE ;
        return updateCaseUpdateMile; 
    }
    
    public static Case_Update_Milestones__c updOpenCaseUpdateMile(Case_Update_Milestones__c caseUpdateMilestone, Boolean isCaseClosed){
        Case_Update_Milestones__c updateCaseUpdateMile = new Case_Update_Milestones__c(Id= caseUpdateMilestone.Id);
        String statusUpdatedTo = isCaseClosed == TRUE ? 'Closed' : 'IgnoreCaseStatus';
        updateCaseUpdateMile.Completion_Date__c                   = System.now();
        updateCaseUpdateMile.Completed__c                         = TRUE;
        updateCaseUpdateMile.update__c                            = TRUE;
        If(statusUpdatedTo == 'IgnoreCaseStatus' ){
            updateCaseUpdateMile.AutoComplete__c                  = TRUE;
            updateCaseUpdateMile.Violation__c                     = FALSE;
        }else{
            updateCaseUpdateMile.Violation__c                     = updateCaseUpdateMile.Completion_Date__c > caseUpdateMilestone.Target_Date__c ? TRUE:FALSE ;
        }
        return updateCaseUpdateMile; 
    }
    
    public static list<Case_Update_Milestones__c> updOpenCaseUpdateMilelist(list<Case_Update_Milestones__c> caseUpdateMilestone, Boolean isCaseClosed){
        list<Case_Update_Milestones__c> caseUpdateMilestoneList = new list<Case_Update_Milestones__c>();
        for(Case_Update_Milestones__c  temp: caseUpdateMilestone) {         
            if(temp.Milestone_Type__c != 'Resolution Response') {
                String statusUpdatedTo = isCaseClosed == TRUE ? 'Closed' : 'IgnoreCaseStatus';
                temp.Completion_Date__c                   = System.now();
                temp.Completed__c                         = TRUE;
                temp.update__c                            = TRUE;
                If(statusUpdatedTo == 'IgnoreCaseStatus' ){
                    temp.AutoComplete__c                  = TRUE;
                    temp.Violation__c                     = FALSE;
                }else{
                    temp.Violation__c                     = temp.Completion_Date__c > temp.Target_Date__c ? TRUE:FALSE ;
                }                
            }else if(temp.Milestone_Type__c == 'Resolution Response' && isCaseClosed == TRUE) { 
            
                temp.Completion_Date__c                   = System.now();
                temp.Completed__c                         = TRUE;
                temp.update__c                            = TRUE;
                temp.Violation__c                     = temp.Completion_Date__c > temp.Target_Date__c ? TRUE:FALSE ;
            }
            caseUpdateMilestoneList.add(temp);          
        }
        return caseUpdateMilestoneList; 
    }
    
  /*  public static Case_Update_Milestones__c updOpenCaseUpdateMileOwner(Id milestoneId, Id caseOwnerId){
        Case_Update_Milestones__c updateCaseUpdateMile = new Case_Update_Milestones__c(Id = milestoneId, OwnerId = caseOwnerId);
        return updateCaseUpdateMile;
    }
    */
    public static list<Case_Update_Milestones__c> UpdateMileOwner(list <Case_Update_Milestones__c>milestoneIdList, Id caseOwnerId) {
        list<Case_Update_Milestones__c> ownerupdatedLIst = new list<Case_Update_Milestones__c>();
        for(Case_Update_Milestones__c temp : milestoneIdList) {
            temp.OwnerId = caseOwnerId;    
            ownerupdatedLIst.add(temp);    
        }
        return ownerupdatedLIst;
    }
    
    
    
    public static Case_Update_Milestones__c insertCaseUpdateMilestone(Case caseLinkedToCaseMilestone, UpdateOperations updateAction){
        Integer slaMinutes;
        Case_Update_Milestones__c newCaseUpdateMilestone            = new Case_Update_Milestones__c();
        If(caseLinkedToCaseMilestone.Support_Level__c != Null){
            slaMinutes = getSlaHours(caseLinkedToCaseMilestone.Priority, caseLinkedToCaseMilestone.Support_Level__c).Case_Update_Milestone_NOM__c.intValue();
             if(!(caseLinkedToCaseMilestone.Support_Level__c == 'AMEX Custom' && caseLinkedToCaseMilestone.priority == 'P2')){           
                 slaMinutes = (slaMinutes * BusinessHoursMap.get(caseLinkedToCaseMilestone.BusinessHoursid))/24;
             }
            system.debug('SLA2----->'+slaMinutes); 
            If(updateAction.isCasePriorityIncreased)
                slaMinutes = getSlaHours(caseLinkedToCaseMilestone.Priority, caseLinkedToCaseMilestone.Support_Level__c).First_Response_NOM__c.intValue();
            system.debug('SLA2----->'+slaMinutes);
  
              
            newCaseUpdateMilestone.Case__c                          = caseLinkedToCaseMilestone.id;
            newCaseUpdateMilestone.Milestone_Type__c                = 'Case Update';
            newCaseUpdateMilestone.Start_Date__c                    = updateAction.isEntitChangedToOtherEntit || updateAction.isEntitPopulatedForFirstTime ? caseLinkedToCaseMilestone.Last_Public_Comment_Date_Time__c : System.now();
            newCaseUpdateMilestone.OwnerId                          = string.valueOf(caseLinkedToCaseMilestone.OwnerId).startsWith('00G') ? '00550000001y4AfAAI' : caseLinkedToCaseMilestone.OwnerId;
            newCaseUpdateMilestone.Target_Date__c                   = slaMinutes != null && Integer.valueof(caseLinkedToCaseMilestone.Priority.substringAfter('P')) != 1?BusinessHours.addGmt(caseLinkedToCaseMilestone.BusinessHoursId, newCaseUpdateMilestone.Start_Date__c, slaMinutes*60000) : newCaseUpdateMilestone.Start_Date__c.addMinutes(slaMinutes); 
            newCaseUpdateMilestone.Duration__c                      = slaMinutes != null ? slaMinutes+'':null;
            //newCaseUpdateMilestone.Completed__c                     = getIgnoreCaseStatuses().contains(caseLinkedToCaseMilestone.status) ? TRUE : FALSE;
            //newCaseUpdateMilestone.Completion_Date__c               = getIgnoreCaseStatuses().contains(caseLinkedToCaseMilestone.status) ? newCaseUpdateMilestone.Start_Date__c : NULL;
        }
        return newCaseUpdateMilestone;                            
    }
    
    public static Case_Update_Milestones__c insertCaseUpdateMilestone(Case caseLinkedToCaseMilestone){
        Integer slaMinutes = getSlaHours(caseLinkedToCaseMilestone.Priority, caseLinkedToCaseMilestone.Support_Level__c).Case_Update_Milestone_NOM__c.intValue();
         if(!(caseLinkedToCaseMilestone.Support_Level__c == 'AMEX Custom' && caseLinkedToCaseMilestone.priority == 'P2')){            
             slaMinutes = (slaMinutes * BusinessHoursMap.get(caseLinkedToCaseMilestone.BusinessHoursid))/24;
         }
        system.debug('SLA3----->'+slaMinutes);
        
        Case_Update_Milestones__c newCaseUpdateMilestone        = new Case_Update_Milestones__c();
        newCaseUpdateMilestone.Case__c                          = caseLinkedToCaseMilestone.id;
        newCaseUpdateMilestone.Milestone_Type__c                = 'Case Update';
        newCaseUpdateMilestone.Start_Date__c                    = System.now();
        newCaseUpdateMilestone.OwnerId                          = string.valueOf(caseLinkedToCaseMilestone.OwnerId).startsWith('00G') ? '00550000001y4AfAAI' : caseLinkedToCaseMilestone.OwnerId;
        newCaseUpdateMilestone.Target_Date__c                   = slaMinutes != null && Integer.valueof(caseLinkedToCaseMilestone.Priority.substringAfter('P')) != 1?BusinessHours.addGmt(caseLinkedToCaseMilestone.BusinessHoursId, newCaseUpdateMilestone.Start_Date__c, slaMinutes*60000) : newCaseUpdateMilestone.Start_Date__c.addMinutes(slaMinutes);
        newCaseUpdateMilestone.Duration__c                      = slaMinutes != null ? slaMinutes+'':null;
        return newCaseUpdateMilestone;                            
    }
        
    Public static SLA__c getSlaHours(String priority, String Supportlevel) {
            for (SLA__c sla : slas) {
                If (sla.priority__c == priority && sla.Support_Level__c == Supportlevel) {
                    return sla;
                    break;
                }
            }
        return null;
    }
    
        
    
    public static Case updateNextUpdateDueDateOnCase(Id caseIdReceived, DateTime targetDateOfMilestone){
        Case caseUnderProcessing                               = new Case(Id = caseIdReceived);
        caseUnderProcessing.NextUpdateDueFrmCUM__c             = targetDateOfMilestone; 
        return caseUnderProcessing;
    }
    
    public static set<String> getIgnoreCaseStatuses(){
        Set<String> ignoreCaseStatuses    = new set<String>(Case_Statuses__c.getInstance('Case Status').Ignore_Case_Status_Values__c.split(','));
        return ignoreCaseStatuses;
    }
    
    public static set<String> getNonIgnoreCaseStatuses(){
        Set<String> nonIgnoreCaseStatuses = new set<String>(Case_Statuses__c.getInstance('Case Status').Non_Ignore_Case_Status_Values__c.split(','));
        return nonIgnoreCaseStatuses;
    }
    
    public static Boolean isDynamicMilestoneEnabled(){
        if(CustomMilestoneSettings__c.getInstance('Custom Milestone') == NULL || CustomMilestoneSettings__c.getInstance('Custom Milestone').Custom_Milestone_Active__c != true)
        { 
            return false;
        
        } else {
        
            return true;   
        }
        /*
        Map<String,CustomMilestoneSettings__c> myMap           = new Map<String,CustomMilestoneSettings__c>();
        myMap = CustomMilestoneSettings__c.getAll();
        if(myMap.size() != 0 || myMap.get('Custom Milestone').Custom_Milestone_Active__c == TRUE) 
            return TRUE;
        else
            return FALSE;
        */
    }
    
    public static set<String> getlistOfSituationManagRecordIds(){
        return recordTypeIdAsPerRequest('SM_RecordType_Ids');
    }
    
    public static Set<String> recordTypeIdAsPerRequest(String requestedCustSettings){
        Set<String> recordTypesIdOnRequest              = new set<String>(CaseRecordOrTypeIds__c.getInstance(requestedCustSettings).ReferenceIds__c.split(';'));
        return recordTypesIdOnRequest;
    }
   
    public static DateTime getTargetDate(Case localCase, Integer duration){
        DateTime targetDate                                   = BusinessHours.AddGMT(localCase.BusinessHoursId, localCase.CreatedDate, duration*60000);
        return targetDate;
    }
    
    public static Boolean isAdminUser(Id commentOwnerId){
        Boolean isAdminUser = System.Label.Case_Admin ==  commentOwnerId? TRUE : FALSE ;
        return isAdminUser;
    }
    
    public static Set<String> getSetOfCaseAdmins(){
        Set<String> setOfCaseAdminIds       = new Set<String>();
        for(CaseAdmin__c tempCaseAdmin : [Select CaseAdminId__c from CaseAdmin__c]){
            setOfCaseAdminIds.add(tempCaseAdmin.CaseAdminId__c);
        } 
        return setOfCaseAdminIds;
    }
    
    public static Map<Id, List<Case_Update_Milestones__c>> getMapOfCaseIdToCaseUpdteMile(List<Id> parentCaseIds){
        Map<Id, List<Case_Update_Milestones__c>> caseIdToListOfCaseMilestones = new Map<Id, List<Case_Update_Milestones__c>>();
        List<Case_Update_Milestones__c> milestones  = [Select Id, Case__c,Target_Date__c from Case_Update_Milestones__c where Case__c IN : parentCaseIds and Completed__c = FALSE and Milestone_Type__c != 'Resolution Response' ];
        for (Case_Update_Milestones__c milestone : milestones) {
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
    
    public static Map<Id, List<Case_Update_Milestones__c>> getMapOfCaseIdToFirstRespMile(List<Id> parentCaseIds){
        Map<Id, List<Case_Update_Milestones__c>> caseIdToListOfCaseMilestones = new Map<Id, List<Case_Update_Milestones__c>>();
        List<Case_Update_Milestones__c> milestones  = [Select Id, Case__c,Target_Date__c, Completed__c from Case_Update_Milestones__c where Case__c IN : parentCaseIds and Milestone_Type__c = 'First Response' and Completed__c = TRUE Limit 1];
        return caseIdToListOfCaseMilestones;
    }
    
    public static Map<Id,Case> getMapOfCaseIdToCase(List<Id> caseIds){
        Map<Id,Case> caseIdToCase = new Map<Id,Case>([Select Id, First_Response_Post_Time__c, Priority, BusinessHoursId, Support_Level__c, IsClosed, ownerid, NextUpdateDueFrmCUM__c,status,Entitlement.BusinessHoursId  from Case where id IN : caseIds ]);
        return caseIdToCase;
    }
}