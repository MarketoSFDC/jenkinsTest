trigger AutoCloseMilestone on CaseComment (after insert) {
    if(Support_Trigger_Settings__c.getInstance('Case Optimized Trigger Enabled') != null && Support_Trigger_Settings__c.getInstance('Case Optimized Trigger Enabled').Enable_Optimized_Trigger__c) return; 
    Set<Id> caseIds = new Set<Id>();    
    Set<Id> CrtdByUsrIds = new Set<Id>();//List of createdby user
    for(CaseComment cc :trigger.new) {    
        System.debug('CreatedById'+cc.createdbyid);
        if(cc.IsPublished == FALSE || cc.createdbyid =='005500000014AByAAM' || cc.createdbyid == '00550000001y4AfAAI') continue;
        if(System.Label.JiveSyncEnabled == 'Yes' && cc.CreatedById == System.Label.JiveSyncSafeUserId) continue;        
        CrtdByUsrIds.Add(cc.CreatedById);
    }       
    if(CrtdByUsrIds.isEmpty() == TRUE) return;
    
    //getlist of non portal users.
    MAP<ID,User> nonPortalUser = new Map<Id,User>([SELECT ID, IsPortalEnabled FROM USER WHERE IsPortalEnabled = FALSE AND ID IN:CrtdByUsrIds]);
    for(CaseComment cc :trigger.new) {        
        if(cc.IsPublished && (nonPortalUser.containsKey(cc.CreatedById))) {// 
            caseIds.add(cc.ParentId);
        }
    }      
    if(caseIds.isEmpty() == FALSE) {
        MilestoneUtils.completeMilestone(caseIds, 'First Response', System.now());
    }
}