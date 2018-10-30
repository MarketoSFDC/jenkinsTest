public  class CaseMilestoneCustSuccess
{
    public static Id caseId{get;set;}
    public static List<Case_Update_Milestones__c> getcsmilestone(){
        List<Case_Update_Milestones__c> cum = new List<Case_Update_Milestones__c>();
        for(Case_Update_Milestones__c cm : [SELECT id,Completed__c,Milestone_Type__c,Start_Date__c, Target_Date__c FROM Case_Update_Milestones__c WHERE Case__c =: caseId]){
            if(cm.Milestone_Type__c == 'First Response' && !cm.Completed__c) cum.add(cm);
            else if(cm.Milestone_Type__c == 'Case Update' && !cm.Completed__c) cum.add(cm);
        }
        return cum;
    }
}