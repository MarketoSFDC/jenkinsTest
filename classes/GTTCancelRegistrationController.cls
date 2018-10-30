public class GTTCancelRegistrationController{
    
    public Map<Integer, String> errorMap {get;set;}
    
    
    public pageReference init(){
    
        String TRAININGKEY   = '';
        String REGISTRANTKEY = '';
        string query = 'SELECT ID';
        GTT_Registrant__c registrant;
        GoToTraining_Attendance__c attendee;
        
        if(ApexPages.currentPage().getParameters().containsKey('registrantId')){
            string regId = ApexPages.currentPage().getParameters().get('registrantId');
            registrant = new GTT_Registrant__c(Id=regId);
        }else if(ApexPages.currentPage().getParameters().containsKey('studentId')){
            string regId = ApexPages.currentPage().getParameters().get('studentId');
            attendee = new GoToTraining_Attendance__c (Id=regId);
        }
        
        TRAININGKEY = ApexPages.currentPage().getParameters().get('trainingKey');
        REGISTRANTKEY = ApexPages.currentPage().getParameters().get('registrantKey');
        GoToTrainingAuthenticatorWithUtils authentication = new GoToTrainingAuthenticatorWithUtils(); 
        if(authentication.isAuthenticated){ 
            string ORGANIZERKEY = authentication.ORGANIZERKEY;
            string ACCESSTOKEN  = authentication.ACCESSTOKEN;
            string cancelRegistrationUrl  = GoToTrainingAuthenticatorWithUtils.gttRegistrationApiBaseUrl+ORGANIZERKEY+'/trainings/'+TRAININGKEY+'/registrants/'+REGISTRANTKEY+'?oauth_token='+ACCESSTOKEN;
            HTTPResponse cancelInResponse = GoToTrainingAuthenticatorWithUtils.makeAPIRequest(cancelRegistrationUrl,'DELETE');
            Integer statusCode = cancelInResponse.getStatusCode();
            if(statusCode == 204){
                PageReference pageRef;
                if(registrant != null && registrant.Id != null){
                    registrant.Registrant_Status__c = 'Cancelled';
                    registrant.GTT_Cancellation_History__c = 'Registration is cancelled by- '+Userinfo.getName()+'('+Userinfo.getUserId()+')';
                    update registrant;
                    pageRef = new PageReference('/'+registrant.Id);
                }else if(attendee != null && attendee.Id != null){
                    attendee.Registration_Status__c = 'Cancelled';
                    attendee.GTT_Cancellation_History__c = 'Registration is cancelled by- '+Userinfo.getName()+'('+Userinfo.getUserId()+')';
                    update attendee;
                    pageRef = new PageReference('/'+attendee.Id);
                }
                return pageRef;
            }else{   
                errorMap = new Map<Integer, String>();         
                errorMap.put(cancelInResponse.getStatusCode(), cancelInResponse.getStatus());
            }
        }
        
        return null;
    }
    
    //https://api.citrixonline.com/G2T/rest/organizers/ 
    //(link is external){organizerKey}/trainings/{trainingKey}/registrants/{registrantKey}
}