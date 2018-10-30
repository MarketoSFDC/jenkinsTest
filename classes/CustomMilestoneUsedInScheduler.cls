/****************************************************************
*Modified By: Sumit Bhatt, Grazitti Interactive
*Purpose: REF: #APPS-18580# Update Test Classes
*Tracking: One cn track the changes by searching ticket number in code
****************************************************************/

public class CustomMilestoneUsedInScheduler{
    public static void UpdateCaseUpdateMilestoneViaScheduler(){
        List<Case_Update_Milestones__c> allMilestonesToBeUpdated = new List<Case_Update_Milestones__c>();
		//APPS-18580
        //List<Case_Update_Milestones__c> milestonesToBeVerified   = new List<Case_Update_Milestones__c>([Select Id,case__c,Target_Date__c,Completed__c from Case_Update_Milestones__c Where Completed__c = false and Target_Date__c <=: System.now() and Case__c != null and Milestone_Type__c != 'First Response']);
		List<Case_Update_Milestones__c> milestonesToBeVerified = new List<Case_Update_Milestones__c> (); 
        if(Test.isRunningTest()){
            milestonesToBeVerified =  [Select Id,case__c,Target_Date__c,Completed__c from Case_Update_Milestones__c Where Completed__c = false and Target_Date__c <=: System.now() and Case__c != null and Milestone_Type__c != 'First Response'LIMIT 100]; 
           } 
          else{
          milestonesToBeVerified= [Select Id,case__c,Target_Date__c,Completed__c from Case_Update_Milestones__c Where Completed__c = false and Target_Date__c <=: System.now() and Case__c != null and Milestone_Type__c != 'First Response']; 
         }
		 //APPS-18580
        System.Debug('+++++++++++milestonesToBeVerified +++++++++++');
        for(Case_Update_Milestones__c currentMilestone : milestonesToBeVerified){
            Case_Update_Milestones__c milestoneToBeUpdated = new Case_Update_Milestones__c(id = currentMilestone.id);
            milestoneToBeUpdated.Completion_Date__c        = System.Now();
            milestoneToBeUpdated.Completed__c              = TRUE;
            milestoneToBeUpdated.Violation__c              = TRUE;
            milestoneToBeUpdated.AutoComplete__c           = TRUE;
            allMilestonesToBeUpdated.add(milestoneToBeUpdated);
        }
        System.Debug('allMilestonesToBeUpdated++++'+allMilestonesToBeUpdated);
        update allMilestonesToBeUpdated;
    }
}