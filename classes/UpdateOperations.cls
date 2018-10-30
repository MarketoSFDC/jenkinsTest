public class UpdateOperations{
    public Boolean isCasePriorityIncreased      = False;
    public Boolean isCaseOwnerChanged           = False;
    public Boolean ignoreToNonIgnore            = False;
    public Boolean ignoreToClose                = False;
    public Boolean CaseReopens                  = False;
    public Boolean nonIgnoreToIgnore            = False;
    public Boolean isEntitChangedToOtherEntit   = False;
    public Boolean isEntitPopulatedForFirstTime = False;
    public Case newCaseGlobal;
    public Case oldCaseGlobal;
    
    public updateOperations(Case newCase, Case oldCase){
        newCaseGlobal = newCase;
        oldCaseGlobal = oldCase;
        System.Debug('______newCaseGlobal _______'+newCaseGlobal );
        System.Debug('______oldCaseGlobal _______'+oldCaseGlobal );
        System.Debug('______isPriorityIncreased_______'+isCasePriorityIncreased);
        System.Debug('______isOwnerChanged_______'+isCaseOwnerChanged);
        System.Debug('______ignoreToNonIgnore_______'+ignoreToNonIgnore+'_______nonIgnoreToIgnore________'+nonIgnoreToIgnore+'____ignoreToClose___'+ignoreToClose+ '_____CaseReopens_____'+CaseReopens);
        isPriorityIncreased(); 
        isOwnerChanged();
        isStatusChanged();   
        isEntitlementUpdated(); 
    }
    
    public void isPriorityIncreased(){
        String priorityBeforeInsert                    = oldCaseGlobal.Priority ;
        String priorityAfterInsert                     = newCaseGlobal.Priority ;  
        Integer priorityLevelAfterInsert               = Integer.valueof(priorityAfterInsert.substringAfter('P'));
        Integer priorityLevelBeforeInsert              = Integer.valueof(priorityBeforeInsert.substringAfter('P'));
        isCasePriorityIncreased                        = priorityLevelAfterInsert < priorityLevelBeforeInsert ? True : False; 
        System.Debug('______isCasePriorityIncreased_______'+isCasePriorityIncreased);
    }
    
    public void isStatusChanged(){
        String oldStatusIsTransferred                  = 'Transferred';
        String statusBeforeUpdate                      = oldCaseGlobal.Status;
        String statusAfterUpdate                       = newCaseGlobal.Status ;
        Set<String> nonIgnoreCaseStatuses              = new set<String>(Case_Statuses__c.getInstance('Case Status').Non_Ignore_Case_Status_Values__c.split(','));
        Set<String> ignoreCaseStatuses                 = new set<String>(Case_Statuses__c.getInstance('Case Status').Ignore_Case_Status_Values__c.split(','));
        ignoreToNonIgnore                              = (ignoreCaseStatuses.Contains(statusBeforeUpdate) || oldStatusIsTransferred.Contains(statusBeforeUpdate)) && nonIgnoreCaseStatuses.Contains(statusAfterUpdate) && (!oldStatusIsTransferred.Contains(statusAfterUpdate)) ? True : False;
        nonIgnoreToIgnore                              = nonIgnoreCaseStatuses.Contains(statusBeforeUpdate) && ignoreCaseStatuses.Contains(statusAfterUpdate) ? True : False;  
        ignoreToClose                                  = ignoreCaseStatuses.Contains(statusBeforeUpdate) && statusAfterUpdate == 'Closed' ? True : False; 
        CaseReopens                                    = statusBeforeUpdate =='Closed' && statusAfterUpdate != 'Closed' ? True : False;
        System.Debug('______ignoreToNonIgnore_______'+ignoreToNonIgnore);
        System.Debug('______nonIgnoreToIgnore_______'+nonIgnoreToIgnore );
        System.Debug('______ignoreToClose_______'+nonIgnoreToIgnore );
        System.Debug('______CaseReopens_______'+CaseReopens);
    }
    
    public void isOwnerChanged(){
        String ownerIdAfterInsert                      = newCaseGlobal.OwnerId;
        isCaseOwnerChanged                             = oldCaseGlobal.OwnerId != newCaseGlobal.OwnerId && ! ownerIdAfterInsert.startsWith('00G') ? True : False ;
        System.Debug('______isCaseOwnerChanged________'+isCaseOwnerChanged);
    }
          
    
    public void isEntitlementUpdated(){
        isEntitChangedToOtherEntit                     = (oldCaseGlobal.EntitlementId != newCaseGlobal.EntitlementId) && oldCaseGlobal.EntitlementId != NULL ? TRUE : FALSE;
        isEntitPopulatedForFirstTime                   = oldCaseGlobal.EntitlementId == NULL && newCaseGlobal.EntitlementId != NULL;
    
        System.Debug('______isEntitChangedToOtherEntit________'+isEntitChangedToOtherEntit );
        System.Debug('______isEntitPopulatedForFirstTime_______'+isEntitPopulatedForFirstTime);
    }
}