/**
THIS CLASS CONTAINS UTILS AND GENERIC METHOD REFERNCED IN OTHER CLASSES RELATED TO GTT-SFDC INTEGRATION.
CREATED BY: GRAZITTI (NOVEMBER, 2014)
RELATED JIRA TICKET- https://resource.marketo.com/jira/browse/COMM-189
**/

global class GoToTrainingAuthenticatorWithUtils {
    
    public string API_KEY  = System.Label.LMS_GTT_API_KEY;
    public string USERNAME = System.Label.LMS_GTT_USERNAME;
    public string PASSWORD = System.Label.LMS_GTT_PASSWORD;    
    
    public static string gttRegistrationApiBaseUrl = 'https://api.citrixonline.com/G2T/rest/organizers/';
    public static string gttAttendanceApiBaseUrl   = 'https://api.citrixonline.com/G2T/rest/reports/organizers/';
    public static string gttTrainingApiBaseUrl     = 'https://api.citrixonline.com/G2T/rest/organizers/';
    
    public String ACCESSTOKEN  = '';   
    public String REFRESHTOKEN = ''; 
    public String ORGANIZERKEY = '';    
    public String ACCOUNTKEY   = '';
    public String FIRSTNAME    = '';    
    public String LASTNAME     = '';
    public String EMAIL        = '';  
    public Boolean isAuthenticated = false;  
    
    /**
     GENERIC METHOD TO LOGIN IN GTT.
    **/
    public GoToTrainingAuthenticatorWithUtils(){
    
        String encodedURL = 'https://api.citrixonline.com/oauth/access_token?grant_type=password&user_id='+USERNAME+'&password='+PASSWORD+'&client_id='+API_KEY;
        HTTPResponse response = makeAPIRequest(encodedURL, 'GET');
        
        if(response.getBody()=='ERROR'){ isAuthenticated = false; return;}
        
        JSONParser parser = JSON.createParser(response.getBody());
        while (parser.nextToken() != null) {
              system.debug(parser.getText()+'test--'+parser.getCurrentName());
              if(parser.getCurrentName()!= null && parser.getCurrentName()!= parser.getText() && parser.getCurrentName()=='access_token'){
                  ACCESSTOKEN = parser.getText();
               }else
              if(parser.getCurrentName()!= null && parser.getCurrentName()!= parser.getText() && parser.getCurrentName()=='refresh_token'){
                  REFRESHTOKEN = parser.getText(); 
              }else
              if(parser.getCurrentName()!= null && parser.getCurrentName()!= parser.getText() && parser.getCurrentName()=='organizer_key'){
                  ORGANIZERKEY = parser.getText(); 
              }else  
              if(parser.getCurrentName()!= null && parser.getCurrentName()!= parser.getText() && parser.getCurrentName()=='account_key'){
                  ACCOUNTKEY = parser.getText();
              }else
              if(parser.getCurrentName()!= null && parser.getCurrentName()!= parser.getText() && parser.getCurrentName()=='firstName'){
                  FIRSTNAME = parser.getText();
              }else
              if(parser.getCurrentName()!= null && parser.getCurrentName()!= parser.getText() && parser.getCurrentName()=='lastName'){
                  LASTNAME = parser.getText(); 
              }
              else
              if(parser.getCurrentName()!= null && parser.getCurrentName()!= parser.getText() && parser.getCurrentName()=='email'){
                  EMAIL = parser.getText(); 
              }                
        }
        isAuthenticated = true;
        
    } 
     
    /**
    GENERIC METHOD THAT PROCESS A HTTP REQUEST.
    **/
    public static HTTPResponse makeAPIRequest(String encodedURL, String HttpRequestMethod) {
        HTTPResponse response;
        HttpRequest req  = new HttpRequest();
        req.setEndPoint(encodedURL );
        req.setMethod(HttpRequestMethod);
        if(HttpRequestMethod == 'POST'){
            req.setHeader('Charset', 'UTF-8');
            req.setHeader('Content-Length', '512'); 
            req.setHeader('Content-Type', 'text/plain');
            req.setTimeout(20);
        }
        Http http = new Http();
        if (!Test.isRunningTest()) {
            response  = http.send(req);
            
            if(HttpRequestMethod == 'DELETE'){
                return response;
            }
            
            if (response.getStatus() == 'OK') {
                 return response;
            }else{
                response = new HTTPResponse();
                response.setBody('ERROR');
                return response ;
            }
           
        } else {
            response = new HTTPResponse();
            String testData = '[{"email":"jacob.beetham@netcall.com","givenName":"Jacob","surname":"Beetham","status":"APPROVED","registrationDate":"2014-02-10T16:59:07Z","joinUrl":"https://www1.gototraining.com/join/training/6906628824343898624/107890187","confirmationUrl":"https://student.gototraining.com/registration/confirmation.tmpl?registrant=5219031309208607488&training=6906628824343898624","registrantKey":"5219031309208607488"';
            testData += ',"sessionKey":"1460206","trainingName":"Basics 2: Foundation Live-Online","sessionStartTime":"'+DateTime.now().addDays(1).year()+'-'+DateTime.now().addDays(1).month()+'-'+DateTime.now().addDays(1).day()+'T'+DateTime.now().addDays(1).hour()+':'+DateTime.now().addDays(1).minute()+':'+DateTime.now().addDays(1).second()+'Z'+'","sessionEndTime":"'+DateTime.now().addDays(2).year()+'-'+DateTime.now().addDays(2).month()+'-'+DateTime.now().addDays(2).day()+'T'+DateTime.now().addDays(2).hour()+':'+DateTime.now().addDays(2).minute()+':'+DateTime.now().addDays(2).second()+'Z'+'","attendanceCount":5,"duration":147,"organizers":[{"givenName":"Majda","surname":"Anwar","email":"manwar@marketo.com","organizerKey":"100000000001409396"}]';
            testData += ',"timeInSession":7301';
            testData += ',"name":"Basics 2: Foundation Live-Online","description":"Foundation Instructor","timeZone":"America/Los_Angeles","times":[{"startDate":"2014-03-10T16:00:00Z","endDate":"2014-03-10T18:30:00Z"},{"startDate":"2014-03-11T16:00:00Z","endDate":"2014-03-11T18:30:00Z"},{"startDate":"2014-03-12T16:00:00Z","endDate":"2014-03-12T18:30:00Z"},{"startDate":"2014-03-13T16:00:00Z","endDate":"2014-03-13T18:30:00Z"}]';
            testData += '}]';
            response.setBody(testData);
            return response ;      
        }
        return response;
    }
    
     WebService static integer refreshRegistrationInfosInSfdc(String courseId){       
        FetchRegistrationFromGoToTraining registrationInfos = new FetchRegistrationFromGoToTraining(courseId);
        return 1;
    }   
}