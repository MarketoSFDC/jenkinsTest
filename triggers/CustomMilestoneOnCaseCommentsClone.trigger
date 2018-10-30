trigger CustomMilestoneOnCaseCommentsClone on CaseComment (after insert) {
    if(Support_Trigger_Settings__c.getInstance('Case Optimized Trigger Enabled') != null && Support_Trigger_Settings__c.getInstance('Case Optimized Trigger Enabled').Enable_Optimized_Trigger__c) return; 
    // DYNAMIC MILESTONE ENABLED MODULE BEGINS HERE
    If(CustomMilestone.isDynamicMilestoneEnabled() != true)
        return;
    // DYNAMIC MILESTONE ENABLED MODULE ENDS HERE
    
    // TRIGGER ALREADY EXECUTED MODULE BEGINS HERE
    if(CustomMilestone.firstRunInCaseComment == false ) {return;}
       CustomMilestone.firstRunInCaseComment = false;
    // TRIGGER ALREADY EXECUTED MODULE BEGINS HERE

    TRY{
        //INITIALIZATION BLOCK STARTS HERE
        List<Id> parentCaseIds                = new List<Id>();
        List<CaseComment> caseCommentsPosted  = new List<CaseComment>();
        List<Id> caseCommentPostedBy          = new List<Id>(); 

        //INITIALIZATION BLOCK ENDS HERE
            
        for(CaseComment tempCaseComment : Trigger.new) {
            if(tempCaseComment.isPublished == False || (system.label.JiveSyncEnabled == 'Yes' && tempCaseComment.CreatedById == system.label.jiveSyncSafeUserID))
                continue;
            parentCaseIds.add(tempCaseComment.ParentId);
            caseCommentsPosted.add(tempCaseComment); 
            caseCommentPostedBy.add(tempCaseComment.CreatedById);  
        }
        if(parentCaseIds.isEmpty() == TRUE) return;
        
        
        //INITIALIZATION BLOCK STARTS HERE
        List<Case_Update_Milestones__c> openCaseUpdateMilestones                     = new List<Case_Update_Milestones__c>();
        Map<Id,Case> caseIdToCase                                                    = new map<Id,Case>();
        Map<Id,List<Case_Update_Milestones__c>> caseIdToCaseUpdtMilestones           = new Map<Id,List<Case_Update_Milestones__c>>();
        List<Case_Update_Milestones__c> milestonesToBeUpdatedOrInserted              = new List<Case_Update_Milestones__c>();
        List<Case> casesToBeUpdated                                                  = new List<Case>();
        Map<Id,List<Case_Update_Milestones__c>> caseIdToFirstResponseMilestones      = new Map<Id,List<Case_Update_Milestones__c>>();
        //INITIALIZATION BLOCK ENDS HERE

        //Fetch the portal user from internal users
        Map<Id,User> idToUser = new Map<Id,User>([Select IsPortalEnabled from User where Id IN :caseCommentPostedBy]);
        
        // Filling up the Sla List 
        CustomMilestone callConstrForIntial = new CustomMilestone();
        // Filling up the Sla List
        
        //POPULATE MAPS FOR USE START HERE
        caseIdToCaseUpdtMilestones         = CustomMilestone.getMapOfCaseIdToCaseUpdteMile(parentCaseIds);
        caseIdToCase                       = CustomMilestone.getMapOfCaseIdToCase(parentCaseIds);
        caseIdToFirstResponseMilestones    = CustomMilestone.getMapOfCaseIdToFirstRespMile(parentCaseIds);
        //POPULATE MAPS FOR USE ENDS HERE
        
        
        for(CaseComment tempCaseComment : caseCommentsPosted){
            //AVOIDABLE CONDITIONS TO BE TAKEN CASE STARTS HERE
            If(!caseIdToCase.ContainsKey(tempCaseComment.ParentId)
                || tempCaseComment.isPublished == False
                    || caseIdToCase.get(tempCaseComment.ParentId).Support_Level__c == NULL 
                        || caseIdToCase.get(tempCaseComment.ParentId).IsClosed
                            || CustomMilestone.getSetOfCaseAdmins().Contains(tempCaseComment.CreatedById)
                                || idToUser.get(tempCaseComment.CreatedById).IsPortalEnabled
                                    || (system.label.JiveSyncEnabled == 'Yes' && tempCaseComment.CreatedById == system.label.jiveSyncSafeUserID)
                                        || (''+(caseIdToCase.get(tempCaseComment.ParentId).OwnerId)).startsWith('00G')
                                ){return;}
            //AVOIDABLE CONDITIONS TO BE TAKEN CARE ENDS HERE
               
                If((caseIdToCaseUpdtMilestones.get(tempCaseComment.ParentId) != NULL && caseIdToCaseUpdtMilestones.get(tempCaseComment.ParentId).SIZE() == 1)){
                    //UPDATE THE EXISTING MILESTONE ON CASE STARTS HERE
                    milestonesToBeUpdatedOrInserted.add(CustomMilestone.updOpenCaseUpdateMile(caseIdToCaseUpdtMilestones.get(tempCaseComment.ParentId)[0], 'CASE COMMENT'));
                    //UPDATE THE EXISTING MILESTONE ON CASE ENDS HERE
                }
                
                // DONOT ADD COMMENT IF CASE EXISTS IN IGNORE CASE STATUS SUCH AS AWAITING CUSTOMER INPUT STARTS HERE
                If(CustomMilestone.getIgnoreCaseStatuses().Contains(caseIdToCase.get(tempCaseComment.ParentId).Status)){return;}
                // DONOT ADD COMMENT IF CASE EXISTS IN IGNORE CASE STATUS SUCH AS AWAITING CUSTOMER INPUT STARTS HERE
                
                //CREATE A NEW CASE UPDATE MILESTONE IF CASE IS NOT IN IGNORE CASE STATUS
                milestonesToBeUpdatedOrInserted.add(CustomMilestone.insertCaseUpdateMilestone(caseIdToCase.get(tempCaseComment.ParentId)));
                //CREATE A NEW CASE UPDATE MILESTONE IF CASE IS NOT IN IGNORE CASE STATUS
                
                //UPDATE NEXT UPDATE DUE DATE ON CASE STARTS HERE
                DateTime targetDate = CustomMilestone.insertCaseUpdateMilestone(caseIdToCase.get(tempCaseComment.ParentId)).Target_Date__c;   
                casesToBeUpdated.add(CustomMilestone.updateNextUpdateDueDateOnCase(tempCaseComment.ParentId, targetDate));  
                //UPDATE NEXT UPDATE DUE DATE ON CASE ENDS HERE
        }
        If(!milestonesToBeUpdatedOrInserted.isEmpty())
            Upsert milestonesToBeUpdatedOrInserted;
        If(!casesToBeUpdated.isEmpty())
            Update casesToBeUpdated;
    } CATCH(Exception ex){
        System.Debug('_______EXCEPTION________'+ex);
    }
}