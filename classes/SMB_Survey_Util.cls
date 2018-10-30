global Class SMB_Survey_Util{
    public static Boolean run = true;
   
    public static Boolean runOnce() {
        if(run) {
            run = false;
            return true;
        } else {
            return run;
        }
    }
    
    WebService static integer sendSurvey(String projId){
        SendReminderToOpportunityOwner sendSurvey = new SendReminderToOpportunityOwner(projId);
        sendSurvey.execute(null);
        return 1;
    }

}