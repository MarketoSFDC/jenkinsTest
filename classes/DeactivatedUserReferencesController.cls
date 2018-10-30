public class DeactivatedUserReferencesController{

    public String userId {get; set;}    

    public List<ScheduledComponentDetail> getJobDetails() {        
        set<String> CronJobDetailIds = new set<String>();
        //***RETRIEVE SCHEDULED JOB INFORMATION...        
        for(CronTrigger cron: [SELECT CronJobDetailId, State, OwnerId FROM CronTrigger WHERE OwnerId =: userId ]){
            CronJobDetailIds.add(cron.CronJobDetailId);
        }        
        //***RETRIEVE MORE SPECEFIC INFORMATION OF SCHEDULED JOB... 
        List<ScheduledComponentDetail> sheduledJobs = new List<ScheduledComponentDetail>();
        for(CronJobDetail cronDetail: [SELECT JobType, Name, Id FROM CronJobDetail WHERE Id IN : CronJobDetailIds]){
            ScheduledComponentDetail job = new ScheduledComponentDetail();            
            String jobType = '';
            if(cronDetail.JobType == '0'){
                jobType = ' Data Export';
            }else if(cronDetail.JobType == '3'){
                 jobType = ' Dashboard Refresh';
            }else if(cronDetail.JobType == '4'){
                jobType = ' Analytic Snapshot';
            }else if(cronDetail.JobType == '7'){
                jobType = ' Apex';
            }else if(cronDetail.JobType == '8'){
                jobType = ' Report Run';
            }else if(cronDetail.JobType == '9'){
                jobType = ' Batch Job';
            }            
            job.jobTitle    = EncodingUtil.urlEncode(cronDetail.Name, 'UTF-8');
            job.Id          = cronDetail.Id;
            job.JobType     = jobType ;
            job.updateUrlId = cronDetail.Name;           
            sheduledJobs.add(job);            
        }
        return sheduledJobs;
    }
    
    public class ScheduledComponentDetail{
        public string id {get; set;}
        public String jobTitle {get; set;}
        public String JobType {get; set;}
        public String updateUrlId{get; set;} 
        public ScheduledComponentDetail(){
        
        }
    }
               
}