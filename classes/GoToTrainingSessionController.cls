public class GoToTrainingSessionController{
    public lmsilt__Session__c sfdcSession ;
    public GoTo_Training_Session__c gttSession {get; set;}
    public GoToTrainingSessionController(ApexPages.StandardController controller) {
        this.sfdcSession = (lmsilt__Session__c)controller.getRecord();
        List<GoTo_Training_Session__c> gttSessions = new List<GoTo_Training_Session__c>();
        gttSessions = [SELECT GoTo_Training_Training_Key__c,
                       GoTo_Training_Session_Start_Time__c,
                       GoTo_Training_Session_End_Time__c, 
                       Event__c ,
                       GTT_Organizer_Key__c,
                       GTT_Organizer_Name__c,
                       SFDC_Session__c,
                       Time_Zone__c,GTT_Number_Of_Student__c, Total_Attended_Student__c,
                       GoTo_Training_Session_Key__c,Class__c,
                       Session_Duration__c, Unique__c,
                       GTT_Organizer_Email__c from GoTo_Training_Session__c Where SFDC_Session__c = :sfdcSession.Id];
        if(gttSessions.isEmpty()){
            gttSession  = new GoTo_Training_Session__c();
        }else{
            gttSession  = gttSessions[0];
            //if(gttSession.GoTo_Training_Training_Key__c != null) FetchAttendanceFromGoToTraining getAttendies = new FetchAttendanceFromGoToTraining(gttSession.SFDC_Session__c);         
        } 
    }
    
    public void init(){
        String sessId = ApexPages.currentPage().getParameters().get('Id');
        FetchAttendanceFromGoToTraining getAttendies = new FetchAttendanceFromGoToTraining(sessId);
    }
    
     public PageReference getAttendanceDetail(){
        String sessId = ApexPages.currentPage().getParameters().get('Id');
        FetchAttendanceFromGoToTraining getAttendies = new FetchAttendanceFromGoToTraining(sessId);
        PageReference pageRef = new PageReference('/'+sessId );
        return pageRef;
    }

}