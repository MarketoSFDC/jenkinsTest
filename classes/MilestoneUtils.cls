public class MilestoneUtils {
    
    public static void completeMilestone(Set<Id> caseIds, String milestoneName, DateTime complDate) {
        List<CaseMilestone> cmsToUpdate = [select Id, completionDate 
                            from CaseMilestone cm 
                        where caseId in :caseIds and cm.MilestoneType.Name=:milestoneName 
                        and completionDate = null limit 1];
                        
        if (cmsToUpdate.isEmpty() == false){
            for (CaseMilestone cm : cmsToUpdate){
                cm.completionDate = complDate;
            }
            try {
                update cmsToUpdate;
            } catch(Exception e) {
                
            }
        } // end if
    }
    
    @future
    public static void completeMilestoneFuture(Set<Id> caseIds, String milestoneName, DateTime complDate) {
        List<CaseMilestone> cmsToUpdate = [select Id, completionDate 
                            from CaseMilestone cm 
                        where caseId in :caseIds and cm.MilestoneType.Name=:milestoneName 
                        and completionDate = null limit 1];
                        
        if (cmsToUpdate.isEmpty() == false){
            for (CaseMilestone cm : cmsToUpdate){
                cm.completionDate = complDate;
            }
            try {
                update cmsToUpdate;
            } catch(Exception e) {
                
            }
        } // end if
    }
}