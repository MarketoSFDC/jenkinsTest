@isTest(SeeAllData=true)

private class CustomMilestoneTestCode{
    Static Case caseAvailableAfterInsert;
    
  
    public static Case createCase(){
        RecordType supportCase = [Select Id From RecordType where SobjectType='Case' and Name = 'Support Cases']; 
        List<Authorized_Contact__c> authorizedContact    = new List<Authorized_Contact__c>([Select Entitlement__c, Entitlement__r.AssetId, Contact__c, Entitlement__r.Asset.Munchkin_Id__c From Authorized_Contact__c where Entitlement__r.Status = 'Active' Limit 1]);
        Case caseObj = new Case(Problem_Type__c = 'How-To',Category__c = 'Design Studio',Sub_Category__c = 'Other' ,Status = 'Working', Priority = 'P4', Subject = 'Test', SuppliedEmail = 'test@test.com',Description = 'Test Description', Origin = 'Web', ContactId = authorizedContact[0].Contact__c, recordTypeId = supportCase.Id);  
        return caseObj;  
            
    }
    
    static testMethod Void insrtFirstRespMilesOnCaseCreate(){
        
        Case caseToBeInserted = createCase();
        System.Debug('______caseToBeInserted_____'+caseToBeInserted);
        insert caseToBeInserted;
        CaseComment tempCaseComment = new CaseComment(
                    ParentId    = caseToBeInserted.Id,
                    CommentBody = 'This Is Test Case Comment',
                    IsPublished = TRUE);  
        insert tempCaseComment;
        Test.StartTest();
        caseAvailableAfterInsert = caseToBeInserted;
        System.Debug('______caseAvailableAfterInsert_____'+caseAvailableAfterInsert);
        updatePriorityOfInsertedCase();
        createCaseUpdateMilestone();
        Test.StopTest();  
        
    }

     static void updatePriorityOfInsertedCase(){
        CustomMilestone.firstRunInCase = TRUE;
        System.Debug('________caseAvailableBeforeInsert_________'+caseAvailableAfterInsert);
        
        Case updateCasePririty = caseAvailableAfterInsert;
        updateCasePririty.Priority = 'P1';
        update updateCasePririty;
        updateStatusFromNonIgnoreToIgnoreStatus();
        System.Debug('________caseAvailableAfterInsert_________'+updateCasePririty);
     }
     
     static void updateStatusFromNonIgnoreToIgnoreStatus(){
        CustomMilestone.firstRunInCase = TRUE;
        System.Debug('________caseAvailableBeforeInsert_________'+caseAvailableAfterInsert);
        
        Case updateCaseStatus = caseAvailableAfterInsert;
        updateCaseStatus.Status = 'Awaiting Customer Input';
        update updateCaseStatus;
        System.Debug('________updateCaseStatus_________'+updateCaseStatus);
     }
     
     static void createCaseUpdateMilestone(){
         Case_Update_Milestones__c milestoneUnderProcessing = new Case_Update_Milestones__c();
         milestoneUnderProcessing.Case__c                     = caseAvailableAfterInsert.Id;
         insert milestoneUnderProcessing;
         Case_Update_Milestones__c milestoneUnderProcessingV1 = new Case_Update_Milestones__c(Id=milestoneUnderProcessing.Id);
         milestoneUnderProcessing.Completed__c                = true;
         milestoneUnderProcessing.AutoComplete__c             = true; 
         milestoneUnderProcessing.update__c                   = false;
         update milestoneUnderProcessing;
         
         Case_Update_Milestones__c milestoneToBeViolated   = new Case_Update_Milestones__c();
         milestoneToBeViolated.Completed__c                = FALSE;
         milestoneToBeViolated.Target_Date__c              = System.now().addMinutes(-45);
         milestoneToBeViolated.Case__c                     = caseAvailableAfterInsert.Id;
         milestoneToBeViolated.Milestone_Type__c           = 'Case Update';                      
         Insert milestoneToBeViolated;
         CustomMilestoneUsedInScheduler.UpdateCaseUpdateMilestoneViaScheduler();
     }
     
     static testMethod void testMicrosoftEnt(){        
        List<Authorized_Contact__c> authorizedContact    = new List<Authorized_Contact__c>([Select Entitlement__c, Entitlement__r.AssetId, Contact__c, Contact__r.AccountId, Entitlement__r.Asset.Munchkin_Id__c From Authorized_Contact__c where Entitlement__r.Status = 'Active' Limit 1]);
        Entitlement en = new Entitlement(id = authorizedContact[0].Entitlement__c, Type = 'Microsoft');    
        update en;
        Test.StartTest();
        Case tempCase = new case(Origin='Web',ContactId = authorizedContact[0].Contact__c, AccountId = authorizedContact[0].Contact__r.AccountId, subject='Test Case',description='asd',Problem_Type__c='Community',Category__c='General Questions',Priority='P1',Status = 'Awaiting Customer Input',EntitlementId = en.Id);        
        System.Debug('Case at time of creation'+tempCase);
        insert tempCase;  
        Test.StopTest();   
    
     }
    
}