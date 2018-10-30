/***************************************************************************************
This Class is created by grazitti support team to work as a custom milestone Function.

****************************************************************************************/
public Class CustomMilestoneFunction{

    /*************************************************************************************************************************************
     Below method populates the Actual Completion Date based on diffrence of target date and actual completion date as per business hours
    **********************************************************************************************************************************/
    public static void getBusinessHoursDiff(Map<Id,Id> milestoneParentMap, list<SObject>TriggerNew, Map<id,SObject>TriggerOldMap){
        Map<Id,Id> milBusinessHourMap= new Map<Id,Id>();
        for(Case cse : [Select id,BusinessHoursId from case where dedicated_tam__c = true and id IN : milestoneParentMap.keySet()]){
                if(cse.BusinessHoursId != null ) milBusinessHourMap.put(cse.Id,cse.BusinessHoursId);
        }
        if(!milBusinessHourMap.isEmpty()){
                system.debug('####TRiggerNew ' +TriggerNew);
                for(SObject obj: TriggerNew){
                Case_Update_Milestones__c cm  = (Case_Update_Milestones__c)obj;
                Case_Update_Milestones__c  oldMilestone = (Case_Update_Milestones__c)TriggerOldMap.get(cm.id);
                if(cm.case__c!= null && (cm.Milestone_Type__c == 'Temporary Resolution' || cm.Milestone_Type__c == 'Resolution Response') && (oldMilestone.Actual_Completion_Date__c != cm.Actual_Completion_Date__c) && milBusinessHourMap.ContainsKey(cm.case__c)){
                    Long caseAge = 0;
                    if(cm.Actual_Completion_Date__c == null)caseAge = calculateBusinessHourDiff(milBusinessHourMap.get(cm.case__c),cm.Completion_Date__c,cm.Target_Date__c);
                    else caseAge = calculateBusinessHourDiff(milBusinessHourMap.get(cm.case__c),cm.Actual_Completion_Date__c,cm.Target_Date__c);
                    cm.Actual_Diffrence__c = caseAge;
                }
            } 
        }
    }
    
    /*************************************************************************************************************************************
     Below method gives the date diffrences(in minutes) based on business hours
    **********************************************************************************************************************************/
    public static long calculateBusinessHourDiff(Id businessHourId ,datetime startdate,datetime targetdate){
        return  BusinessHours.diff(businessHourId,startdate,targetdate) / (1*60*1000);
    }
}