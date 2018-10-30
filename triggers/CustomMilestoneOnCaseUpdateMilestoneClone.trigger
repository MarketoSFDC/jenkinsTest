trigger CustomMilestoneOnCaseUpdateMilestoneClone on Case_Update_Milestones__c (before Update) {
    TRY{
        List<Id> parentCaseIds                             = new List<Id>();
        List<Case_Update_Milestones__c> milestonesUpdated  = new List<Case_Update_Milestones__c>();
        Map<Id,Case> caseIdToCase                          = new Map<Id,Case>();
        List<Case_Update_Milestones__c> newMilestones      = new List<Case_Update_Milestones__c>();
        
        // DYNAMIC MILESTONE ENABLED MODULE BEGINS HERE
        If(CustomMilestone.isDynamicMilestoneEnabled() != true)
            return;
        // DYNAMIC MILESTONE ENABLED MODULE ENDS HERE
        
        // TRIGGER ALREADY EXECUTED MODULE BEGINS HERE
            if(CustomMilestone.firstRunInCaseMilestone == false ) {return;}
               CustomMilestone.firstRunInCaseMilestone = false;
        // TRIGGER ALREADY EXECUTED MODULE BEGINS HERE
       
        for(Case_Update_Milestones__c currentCaseUpdateMile : Trigger.New){
            parentCaseIds.add(CurrentCaseUpdateMile.Case__c);
            milestonesUpdated.add(currentCaseUpdateMile);     
        }
    
        caseIdToCase                               = CustomMilestone.getMapOfCaseIdToCase(parentCaseIds);
        CustomMilestone callConstrForIntialization = new CustomMilestone();
        
        for(Case_Update_Milestones__c milestoneUnderProcessing : milestonesUpdated){
            If(milestoneUnderProcessing.Completed__c == true
                && milestoneUnderProcessing.AutoComplete__c == true 
                    && milestoneUnderProcessing.update__c == false
                        && milestoneUnderProcessing.Milestone_Type__c != 'First Response'
                            && caseIdToCase.get(milestoneUnderProcessing.Case__c).IsClosed == false){ // added by Riz
                    newMilestones.add(CustomMilestone.insertCaseUpdateMilestone(caseIdToCase.get(milestoneUnderProcessing.Case__c)));
            }        
        }
        If(!newMilestones.isEmpty())
            insert newMilestones;
    } CATCH(Exception ex){
        System.Debug('_______EXCEPTION________'+ex);
    }
}