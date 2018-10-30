public class MarketoGTTRegistrationController {
    
    private static final string API_KEY          = System.Label.LMS_GTT_API_KEY;////'EoSKT9giTs2KQ1u4WtZf7TH6T7jo02DQ';
    private static final string API_USERNAME     = System.Label.LMS_GTT_USERNAME;//'vish03525@yahoo.co.in';////'vish03525@yahoo.co.in';
    private static final string API_PASSWORD     = System.Label.LMS_GTT_PASSWORD;//'vishal85';'university13';//'vishal85';//
    private static final string CITRIX_BASE_URL  = 'https://api.citrixonline.com';
    private static final string PREM_USER_GRP    = System.label.PremiumEducationCatalogPublicGroup;
    
    
    public  Integer registrationStatusCode {get;set;}
    
    private TrainingInfoWrapper trainInfoWrapper; 
    
    
    public PageReference Register() {
        // 1.Get logged in user details
        // 2.Authenticate with the GTT API
        // 3.Register logged in user to training with id in page parameters
        
        // if user is not subscribed to public user group the return
        Group PremiumUserGroup = [Select Id from Group where DeveloperName = :PREM_USER_GRP limit 1]; 
        
        Integer memberCount = Database.countQuery('Select count() From GroupMember g where g.GroupId=\''+PremiumUserGroup.Id+'\' and UserOrGroupId=\''+Userinfo.getUserId()+'\'');
        if (memberCount == 0) {
            registrationStatusCode = 403;
            //System.Debug('API__REG_RESPONSE'+response.getBody()+' '+registrationStatusCode );
            return Page.SeasonPassRegistration;
        } 
        
        HTTPResponse response;
        HttpRequest req  = new HttpRequest();
        req.setEndPoint(CITRIX_BASE_URL+'/oauth/access_token?user_id='+API_USERNAME+'&password='+API_PASSWORD+'&grant_type=password&client_id='+API_KEY);
        req.setMethod('GET');
        Http http = new Http();
        if (!Test.isRunningTest()) {
            response = http.send(req);
        } else {
            response = new HTTPResponse();
            String testData = '{"access_token":"test", "expires_in":"test", "refresh_token":"test", "organizer_key":"test", "account_key":"test", "account_type":"test", "firstName":"test", "lastName":"test", "email":"test", "platform":"test"}';
            response.setBody(testData);
        }
        APIInfoWrapper apiInfo = new APIInfoWrapper();
        apiInfo                = (APIInfoWrapper)JSON.deserialize(response.getBody(),APIInfoWrapper.class);
        System.Debug('API_INFO'+apiInfo);
        
        // Register logged in user to training with id in page parameters
        String training_id = ApexPages.currentPage().getParameters().get('tr_id'); 
        req.setEndPoint(CITRIX_BASE_URL+'/G2T/rest/organizers/'+apiInfo.organizer_key+'/trainings/'+training_id+'/registrants');
        req.setMethod('POST');
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Authorization', apiInfo.access_token);
        req.setBody('{"email":"'+UserInfo.getUserEmail()+'","givenName":"'+UserInfo.getFirstName()+'","surname":"'+UserInfo.getLastName()+'"}');
        
        System.Debug('__REQ_BODY__'+req.getBody());
        trainInfoWrapper = new TrainingInfoWrapper();
        if (!Test.isRunningTest()) {
            response  = http.send(req);
            if (response.getStatus() == 'Created') {
                trainInfoWrapper = (TrainingInfoWrapper)JSON.deserialize(response.getBody(),TrainingInfoWrapper.class);
            }
        } else {
            response = new HTTPResponse();
            String testData = '{"joinUrl":"test.com","confirmationUrl":"test","registrantKey":"test"}';
            response.setBody(testData);
            trainInfoWrapper = (TrainingInfoWrapper)JSON.deserialize(response.getBody(),TrainingInfoWrapper.class);
            //return response ;      
        }
        registrationStatusCode = response.getStatusCode();
        System.Debug('API__REG_RESPONSE'+response.getBody()+' '+registrationStatusCode );
        
        return null;
    }
    
    public Class APIInfoWrapper{
        public String access_token;
        public String expires_in;
        public String refresh_token;
        public String organizer_key;
        public String account_key;
        public String account_type;
        public String firstName;
        public String lastName;
        public String email;
        public String platform;
    }
    
    public class  TrainingInfoWrapper{
        public String joinUrl;             
        public String confirmationUrl;   
        public String registrantKey;    
    }

}