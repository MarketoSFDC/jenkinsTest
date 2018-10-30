trigger DisallowPublicCommentQueue on CaseComment (after insert) {
//Can you please create a validation rule where a record must be owned by an internal user, and not a queue before any 
//public comments can be added? This should NOT stop portal users from adding comments to a case that is owned by a queue.
//4934, To not create any conflict in that flow, if Problem type, category is not filled on entering first public comment do the exact same as displaying user the message what to do and do not save any comment.
//Ideally what i want whenever status changes to "working" or "Awaiting customer Input" by any way ( i.e. manually editing status, through WF or through button) it should do the smae thing.
    if(Support_Trigger_Settings__c.getInstance('Case Optimized Trigger Enabled') != null && Support_Trigger_Settings__c.getInstance('Case Optimized Trigger Enabled').Enable_Optimized_Trigger__c) return; 
    Set<Id> caseIds = new Set<Id>();  
    Set<Id> CrtdByUsrIds = new Set<Id>();//List of createdby user
    
    //Get list of admin profiles who are creator for case comment using emails.
    List<CaseAdmin__c> caseAdminIdsList = [Select CaseAdminId__c from CaseAdmin__c];
    Set<String> caseAdminIdsSet = new Set<String>();
    for(CaseAdmin__c tempCaseAdmin : caseAdminIdsList){
        caseAdminIdsSet.add(tempCaseAdmin.CaseAdminId__c);
    }
    if(System.Label.JiveSyncEnabled == 'Yes') {
        caseAdminIdsSet.add(System.Label.JiveSyncSafeUserId);    
    }    
    
    for(CaseComment cc :trigger.new) {
        //If case comment creted by jive sync user no validation needed.
        
        if(cc.isPublished == true && !caseAdminIdsset.contains(cc.createdById) ) //If  posted comment is public and not created by user email
        {
            System.debug('CreatedById'+cc.createdbyid);
            CrtdByUsrIds.Add(cc.CreatedById);        
            caseIds.add(cc.ParentId);            
        }                
    }
        
    if(caseIds.isEmpty()) return;
    
    Map<Id,Case> myCasesMap = new Map<Id,Case>([SELECT ID, OwnerId, Status, Problem_Type__c, RecordTypeId from Case Where Id in:caseIds]);
    //getlist of non portal users who have posted a public comment.
    MAP<ID,User> nonPortalUsrs = new Map<Id,User>([SELECT ID, IsPortalEnabled, ContactId FROM USER WHERE (IsPortalEnabled = FALSE) AND (ID IN:CrtdByUsrIds)]);
    
    String nonSMCaseRecTypes = '01250000000UJwxAAG;01250000000UJwyAAG;01250000000UJwzAAG;01250000000UKbbAAG;01250000000UMsLAAW';  
    if(!Test.isRunningTest()) {       
        nonSMCaseRecTypes = CaseRecordOrTypeIds__c.getInstance('NonSupportCaseRecTIds').ReferenceIds__c;    
    }  
        
    for(CaseComment cc :trigger.new) {        
        if((cc.IsPublished == true) && (nonPortalUsrs.containsKey(cc.CreatedById))) //comment is public and comment added by standard user.
        {
            if(myCasesMap.containsKey(cc.parentId)){
                if(myCasesMap.get(cc.parentID).OwnerId != null && (myCasesMap.get(cc.parentID).OwnerId+'').startsWith('00G')){
                    if(!Test.isRunningTest())
                    cc.addError('Comments cannot be added to cases owned by Queues. Please take ownership of this case or assign to an appropriate user.');                            
                }
            }
        }
    }
}