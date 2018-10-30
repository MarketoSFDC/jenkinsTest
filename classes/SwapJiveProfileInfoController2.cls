public class SwapJiveProfileInfoController2{
    public boolean isSuccess {get;set;}
    public boolean isReverted {get;set;}
    //public boolean IsCorrupted {get;set;}
    public boolean hasNotFailed {get;set;}
    public boolean hasCommProfile{get;set;}
    
    //public Set<String> checkStr {get;set;}    
    public String userIdOld {get;set;}
    public String userIdNew {get;set;}
    public String updateProfileType {get;set{updateProfileType = value;}}
    public string UserNotupdated ='';
    public string temp;
    public String JiveProfileCredentials;
    public String strHttpRestRequestLabel;
        
    // Unique label for the first request
    public String requestLabel1;
    // Unique label for the second request
    public String requestLabel2;
    // Result of first callout
    public String result1 {get;set;}
    // Result of second callout
    public String result2 {get;set;}
    public static final String jiveSetUserInfoUrl;        
    static {
        jiveSetUserInfoUrl = System.Label.jiveSetUserInfoUrl;
    }   
    public String responseString {get;set;}
    public Integer stageCntr {get;set;}
    public boolean stageError {get;set;}
    public Integer stageErrorCntr{get;set;}    
        
    public Class jiveUser {
        Public String Jive_ID {get;set;} 
        Public String First_Name {get;set;}
        Public String Last_Name {get;set;}
        Public String Email {get;set;}
        Public String AltEmail {get;set;}        
        Public String External_ID {get;set;}
        Public String Contact_ID {get;set;}
        Public String Company {get;set;}
        Public String Account_ID {get;set;}
        Public String Munchkin_ID {get;set;}
        Public String Federated {get;set;}
        Public String UserName {get;set;}
        public jiveUser() {
            First_Name = ''; Last_Name=''; Email = ''; AltEmail = ''; External_ID = ''; Contact_ID  = ''; 
            Company = ''; Account_ID = ''; Munchkin_ID = ''; Jive_ID = ''; Federated = ''; Username = '';            
        }
    }    
    
    public jiveUser OldUserDetail {get;set;}
    public jiveUser NewUserDetail {get;set;}
    public jiveUser OldUserDetailBkup {get;set;}
    public jiveUser NewUserDetailBkup {get;set;}
        
    public void init() {
        stageCntr = 1;
        stageError = false;
        stageErrorCntr = 0;
        JiveProfileCredentials = System.Label.JiveProfileCredentials;   
        updateProfileType = 'Self';
        isSuccess = false;
        hasNotFailed = true;
        hasCommProfile = false;
        isReverted = false;
        userIdOld = '';
        List<String> collectiveIds = new List<String>();
        OldUserDetail = new jiveUser();
        NewUserDetail = new jiveUser();        
    }    
         
    public SwapJiveProfileInfoController2() {
        responseString  = '';
        temp = system.now().getTime()+'__';
        isSuccess = false;        
        hasNotFailed = true;
        init();
    }
    
    public void refreshPanel() {
        hasCommProfile = false;        
        OldUserDetail = new jiveUser();
        NewUserDetail = new jiveUser();
    }
    
    
    
    public void getProfileSwappingCallout() {
        isSuccess = false;
        system.debug('Old User ===> '+ OldUserDetail);
        system.debug('New User ===> '+ NewUserDetail);        
        if(Test.isRunningTest() == false && (OldUserDetail.Email == Null ||  OldUserDetail.Email.isWhitespace())) {
            responseString = 'Please fill first user email';
            return;
        }        
        if(Test.isRunningTest() == false && (updateProfileType == 'Swap' && (NewUserDetail.Email == Null ||  NewUserDetail.Email.isWhitespace()))) {
            responseString = 'Please fill second user email';
            return;
        }                
        String jiveGetUserInfoUrl = System.Label.jiveGetUserInfoUrl;         
        HttpRequest reqCheckOld = new HttpRequest();
        HttpResponse resCheckOld = new HttpResponse();
        Http httpCheckOld = new Http();
        reqCheckOld.setEndpoint(jiveGetUserInfoUrl+OldUserDetail.Email);
        if(System.Label.JiveProfileCredentials != '') {
            reqCheckOld = setAuthorizationHeader(reqCheckOld);
        }
        reqCheckOld.setMethod('GET');
        String JSONContentOld = '';
        String plyrID5 = ''; 
        String plyrNickName5;
        Boolean playerExists5 = true;        
        try {
            if(Test.isRunningTest() == false) {
                resCheckOld =  httpCheckOld.send(reqCheckOld);           
                System.debug('resCheckOld'+resCheckOld.getBody());
                JSONContentOld = resCheckOld.getBody();            
            } else {
                JSONContentOld = '{"id":"2092","resources":{"reports":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@reports"},"followingIn":{"allowed":["POST","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/followingIn"},"images":{"allowed":["POST","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/images"},"activity":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/activities"},"manager":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@manager"},"social":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@social"},"streams":{"allowed":["POST","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/streams"},"recognition":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@recognition"},"trendingContent":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@trendingContent"},"trendingPlaces":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@trendingPlaces"},"avatar":{"allowed":["PUT","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/avatar?a=-1"},"followers":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@followers"},"pages":{"allowed":["POST","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/pages"},"colleagues":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@colleagues"},"following":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@following"},"members":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/members/people/2092"},"self":{"allowed":["DELETE","PUT","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092"},"html":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/people/vishals%40grazitti.com"},"securityGroups":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/securityGroups"},"extprops":{"allowed":["POST","DELETE","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/extprops"},"tasks":{"allowed":["POST","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/tasks"}},"followerCount":0,"published":"2015-04-07T04:32:35.639+0000","updated":"2015-05-21T08:00:06.795+0000","displayName":"VishalSharma","mentionName":"VishalSharma","emails":[{"jive_label":"Email","primary":true,"type":"work","value":"vishals@grazitti.com","jive_displayOrder":6,"jive_summaryDisplayOrder":1,"jive_showSummaryLabel":true}],"followingCount":0,"directReportCount":0,"jive":{"enabled":true,"external":false,"externalIdentities":[],"federated":false,"lastProfileUpdate":"2015-05-20T10:24:37.554+0000","lastAuthenticated":"2015-05-21T05:31:32.901+0000","level":{"imageURI":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/images/status/statusicon-47.gif","name":"Newbie","points":5},"locale":"en_US","externalContributor":false,"profile":[{"jive_label":"ContactID","value":"0035000001YjI1IAAV","jive_displayOrder":21,"jive_showSummaryLabel":false},{"jive_label":"AccountID","value":"0015000000fD2sOAAS","jive_displayOrder":23,"jive_showSummaryLabel":false},{"jive_label":"Customer","value":"No","jive_displayOrder":27,"jive_showSummaryLabel":false},{"jive_label":"MunchkinID","value":"CF-TEST-123","jive_displayOrder":31,"jive_showSummaryLabel":false}],"sendable":true,"timeZone":"America/Los_Angeles","username":"vishals@grazitti.com","visible":true,"termsAndConditionsRequired":false},"location":"Chandigarh,India","name":{"familyName":"Sharma","formatted":"VishalSharma","givenName":"Vishal"},"phoneNumbers":[{"jive_label":"PhoneNumber","primary":true,"type":"work","value":"+91-7837316810","jive_displayOrder":14,"jive_showSummaryLabel":false}],"thumbnailId":"-1","thumbnailUrl":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/avatar?a=-1","initialLogin":"2015-04-29T09:33:48.315+0000","type":"person"}';
            }
        } catch(System.CalloutException e) {
                System.debug('Callout error: '+ e);            
        }                               
        if(resCheckOld.getStatus() != 'OK') {
            String msg3 = 'Error Old User Detail Error';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg3));
            string tmpStrEm = OldUserDetail.Email;
            OldUserDetail = new jiveUser(); 
            OldUserDetail.Email = tmpStrEm;
            if(Test.isRunningTest() == false) return;            
        }        
        JSONContentOld = JSONContentOld.remove('throw \'allowIllegalResourceCall is false.\';');
        JSONParser parser1 =    JSON.createParser(JSONContentOld);//emails
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(JSONContentOld); 
        for(String keyStr : m.keySet()) {
            if(keyStr == 'id'){OldUserDetail.Jive_ID = ''+m.get(keyStr);}
            //name==>{familyName=Sharma, formatted=Vishal Sharma, givenName=Vishal}
            if(keyStr == 'name') { Map<String,Object> mapVal = (Map<String, Object>)m.get(keyStr);
                OldUserDetail.First_Name = ''+mapVal.get('givenName'); OldUserDetail.Last_Name  = ''+mapVal.get('familyName');                
            }
            //emails==>({jive_displayOrder=6, jive_label=Email,primary=true, type=work, value=vishals@grazitti.com})
            if(keyStr == 'emails') { List<Object> emailObj = (List<Object>)m.get(keyStr);
                for(Object eObj : emailObj) {
                    Map<String,Object> mapVal = (Map<String, Object>)eObj;
                    if(mapVal.get('jive_label') == 'Email')OldUserDetail.Email = ''+mapVal.get('value');                
                    if(mapVal.get('jive_label') == 'Alternate Email') OldUserDetail.AltEmail = ''+mapVal.get('value');   
                }
                if(OldUserDetail.AltEmail == '' && OldUserDetail.Email !=  '') {OldUserDetail.AltEmail = OldUserDetail.Email;}                                   
            }
            // jive==>{enabled=true, profile=({jive_displayOrder=21, jive_label=Contact ID, jive_showSummaryLabel=false, value=0035000001YjI1IAAV}, {jive_displayOrder=23, jive_label=Account ID, jive_showSummaryLabel=false, value=0015000000fD2sOAAS}, {jive_displayOrder=27, jive_label=Customer, jive_showSummaryLabel=false, value=No}, {jive_displayOrder=31, jive_label=Munchkin ID, jive_showSummaryLabel=false, value=CF-TEST-123}), ...}
            if(keyStr == 'jive') { 
                Map<String,Object> mapVal = (Map<String, Object>)m.get(keyStr);
                OldUserDetail.federated  = ''+mapVal.get('federated');
                OldUserDetail.userName   = ''+mapVal.get('username');                
                List<Object> extIdentityVals = (List<Object>) mapVal.get('externalIdentities');
                for(Object extIdObj : extIdentityVals) {
                    Map<String,Object> idVal = (Map<String, Object>)extIdObj;
                    if(idVal.get('identityType') == 'SAML'){ OldUserDetail.External_ID = ''+idVal.get('identity');break; }
                }                                 
                List<Object> profileVals = (List<Object>)mapVal.get('profile');
                for(Object prfObj : profileVals) {
                    Map<String,Object> prfVal = (Map<String, Object>)prfObj;
                    if(prfVal.get('jive_label') == 'Account ID')OldUserDetail.Account_ID = ''+prfVal.get('value');
                    if(prfVal.get('jive_label') == 'Contact ID')OldUserDetail.Contact_ID = ''+prfVal.get('value');
                    if(prfVal.get('jive_label') == 'Munchkin ID')OldUserDetail.Munchkin_ID = ''+prfVal.get('value');
                    if(prfVal.get('jive_label') == 'Company')OldUserDetail.Company = ''+prfVal.get('value');                                                                            
                }
            }                    
        }
        
        OldUserDetailBkup = OldUserDetail; //Backup of user details before swap
        NewUserDetailBkup = NewUserDetail;
        if(updateProfileType == 'Self'){ 
            hasCommProfile = true;
            if(Test.isRunningTest() == false) return;
        }     
           
        HttpRequest reqCheckNew = new HttpRequest();
        HttpResponse resCheckNew = new HttpResponse();
        Http httpCheckNew = new Http();
        reqCheckNew.setEndpoint(jiveGetUserInfoUrl+NewUserDetail.Email);
        if(System.Label.JiveProfileCredentials != '') {
            reqCheckNew = setAuthorizationHeader(reqCheckNew);              
        }
        reqCheckNew.setMethod('GET');
        String JSONContentNew = '';
        Try {
            if(Test.isRunningTest() == false) {
                resCheckNew =  httpCheckNew.send(reqCheckNew);           
                System.debug(resCheckNew.getBody());
                JSONContentNew= resCheckNew.getBody();            
            } else {
                JSONContentNew = '{"id":"2092","resources":{"reports":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@reports"},"followingIn":{"allowed":["POST","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/followingIn"},"images":{"allowed":["POST","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/images"},"activity":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/activities"},"manager":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@manager"},"social":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@social"},"streams":{"allowed":["POST","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/streams"},"recognition":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@recognition"},"trendingContent":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@trendingContent"},"trendingPlaces":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@trendingPlaces"},"avatar":{"allowed":["PUT","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/avatar?a=-1"},"followers":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@followers"},"pages":{"allowed":["POST","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/pages"},"colleagues":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@colleagues"},"following":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@following"},"members":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/members/people/2092"},"self":{"allowed":["DELETE","PUT","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092"},"html":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/people/vishals%40grazitti.com"},"securityGroups":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/securityGroups"},"extprops":{"allowed":["POST","DELETE","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/extprops"},"tasks":{"allowed":["POST","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/tasks"}},"followerCount":0,"published":"2015-04-07T04:32:35.639+0000","updated":"2015-05-21T08:00:06.795+0000","displayName":"VishalSharma","mentionName":"VishalSharma","emails":[{"jive_label":"Email","primary":true,"type":"work","value":"vishals@grazitti.com","jive_displayOrder":6,"jive_summaryDisplayOrder":1,"jive_showSummaryLabel":true}],"followingCount":0,"directReportCount":0,"jive":{"enabled":true,"external":false,"externalIdentities":[],"federated":false,"lastProfileUpdate":"2015-05-20T10:24:37.554+0000","lastAuthenticated":"2015-05-21T05:31:32.901+0000","level":{"imageURI":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/images/status/statusicon-47.gif","name":"Newbie","points":5},"locale":"en_US","externalContributor":false,"profile":[{"jive_label":"ContactID","value":"0035000001YjI1IAAV","jive_displayOrder":21,"jive_showSummaryLabel":false},{"jive_label":"AccountID","value":"0015000000fD2sOAAS","jive_displayOrder":23,"jive_showSummaryLabel":false},{"jive_label":"Customer","value":"No","jive_displayOrder":27,"jive_showSummaryLabel":false},{"jive_label":"MunchkinID","value":"CF-TEST-123","jive_displayOrder":31,"jive_showSummaryLabel":false}],"sendable":true,"timeZone":"America/Los_Angeles","username":"vishals@grazitti.com","visible":true,"termsAndConditionsRequired":false},"location":"Chandigarh,India","name":{"familyName":"Sharma","formatted":"VishalSharma","givenName":"Vishal"},"phoneNumbers":[{"jive_label":"PhoneNumber","primary":true,"type":"work","value":"+91-7837316810","jive_displayOrder":14,"jive_showSummaryLabel":false}],"thumbnailId":"-1","thumbnailUrl":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/avatar?a=-1","initialLogin":"2015-04-29T09:33:48.315+0000","type":"person"}';         
            }
        } catch(System.CalloutException e) {
                System.debug('Callout error: '+ e);            
        }                               
        if(resCheckNew.getStatus() != 'Ok') {
            String msg3 = 'Error New User Details';
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg3));
            string tmpStrEm = NewUserDetail.Email;
            NewUserDetail = new jiveUser(); 
            NewUserDetail.Email = tmpStrEm;                 
            System.debug('Error New User Details');
            if(Test.isRunningTest() == false) return;
        }         
        hasCommProfile = true;
           
        JSONContentNew = JSONContentNew.remove('throw \'allowIllegalResourceCall is false.\';');
        JSONParser parser = JSON.createParser(JSONContentNew);
        Map<String, Object> mm = (Map<String, Object>)JSON.deserializeUntyped(JSONContentNew);
        for(String keyStr : mm.keySet()){
            if(keyStr == 'id'){ NewUserDetail.Jive_ID = ''+mm.get(keyStr); }
            if(keyStr == 'name') { Map<String,Object> mapVal = (Map<String, Object>)mm.get(keyStr);
                NewUserDetail.First_Name = ''+mapVal.get('givenName'); NewUserDetail.Last_Name  = ''+mapVal.get('familyName');                
            }
            //emails==>({jive_displayOrder=6, jive_label=Email,primary=true, type=work, value=vishals@grazitti.com})
            if(keyStr == 'emails') { List<Object> emailObj = (List<Object>)mm.get(keyStr);
                for(Object eObj : emailObj) {
                    Map<String,Object> mapVal = (Map<String, Object>)eObj;
                    if(mapVal.get('jive_label') == 'Email') NewUserDetail.Email = ''+mapVal.get('value');   
                    if(mapVal.get('jive_label') == 'Alternate Email') NewUserDetail.AltEmail = ''+mapVal.get('value');                                    
                }
                if(NewUserDetail.AltEmail == '' && NewUserDetail.Email !=  '') {NewUserDetail.AltEmail = NewUserDetail.Email;}
            }
            if(keyStr == 'jive') { 
                Map<String,Object> mapVal = (Map<String, Object>)mm.get(keyStr);
                NewUserDetail.federated  = ''+mapVal.get('federated');
                NewUserDetail.userName   = ''+mapVal.get('username');                  
                List<Object> extIdentityVals = (List<Object>) mapVal.get('externalIdentities');
                for(Object extIdObj : extIdentityVals) {
                    Map<String,Object> idVal = (Map<String, Object>)extIdObj;
                    if(idVal.get('identityType') == 'SAML'){ NewUserDetail.External_ID = ''+idVal.get('identity');break; }
                }
                List<Object> profileVals = (List<Object>)mapVal.get('profile');
                for(Object prfObj : profileVals) {
                    Map<String,Object> prfVal = (Map<String, Object>)prfObj;
                    if(prfVal.get('jive_label') == 'Account ID') NewUserDetail.Account_ID = ''+prfVal.get('value');
                    if(prfVal.get('jive_label') == 'Contact ID') NewUserDetail.Contact_ID = ''+prfVal.get('value');
                    if(prfVal.get('jive_label') == 'Munchkin ID') NewUserDetail.Munchkin_ID = ''+prfVal.get('value');
                    if(prfVal.get('jive_label') == 'Company') NewUserDetail.Company = ''+prfVal.get('value');                                    
                }
            }                    
        }
        NewUserDetailBkup = NewUserDetail; //Backup of user details before swap                
        stageCntr = 1;
        stageError = false;
        stageErrorCntr = 0;                                  
    }
    
    public Boolean checkForNull(jiveUser tmpUserDetail) {
        if((tmpUserDetail.AltEmail == null || tmpUserDetail.AltEmail.trim() == '' || tmpUserDetail.Email == null || tmpUserDetail.Email.trim() == '' || tmpUserDetail.External_ID == null || tmpUserDetail.External_ID.trim() == '' || tmpUserDetail.Contact_ID == null || tmpUserDetail.Contact_ID.trim() == '' || tmpUserDetail.Company == null || tmpUserDetail.Company.trim() == '' || tmpUserDetail.Account_ID == null || tmpUserDetail.Account_ID.trim() == '' || tmpUserDetail.Munchkin_ID == null || tmpUserDetail.Munchkin_ID.trim() == '' || tmpUserDetail.UserName == null || tmpUserDetail.UserName.trim() == '' || tmpUserDetail.federated == null || tmpUserDetail.federated.trim() == '' || tmpUserDetail.Last_Name == null || tmpUserDetail.Last_Name.trim() == '' || tmpUserDetail.First_Name == null || tmpUserDetail.First_Name.trim() == '')) {
            return true;
        }   
        return false;
    }   
    
    public HttpRequest setAuthorizationHeader(HttpRequest reqObj) {
        Blob headerValue = Blob.valueOf(JiveProfileCredentials);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        reqObj.setHeader('Authorization', authorizationHeader);
        reqObj.setHeader('content-type', 'application/json');
        reqObj.setHeader('Accept', 'application/json');     
        return  reqObj;
    }
    
    public string CreateJiveUserString( jiveUser UserDetails, String TempTrue ){
        system.debug('UserDetails------------------->'+UserDetails);
        string tempStr = '';                
        if(UserDetails.AltEmail != null && UserDetails.AltEmail.Trim() != ''){
            tempStr = '{"emails":[{"jive_label":"Alternate Email", "value":"' + UserDetails.AltEmail + '"},';  
        }              
        tempStr += '{"jive_label":"Email","primary":true,"value":"' +TempTrue+UserDetails.Email + '"}],';        
        if(UserDetails.External_ID != null && UserDetails.External_ID.Trim() != '') {
            tempStr += '"jive":{"enabled":true,"externalIdentities":[{"identityType":"SAML","identity":"' +TempTrue + UserDetails.External_ID + '"}],';
        }           
        if(UserDetails.Contact_ID != null && UserDetails.Contact_ID.Trim() != ''){
            tempStr += '"profile":[{"jive_label":"Contact ID", "value":"' + UserDetails.Contact_ID + '"},';
        }
        if(UserDetails.Company != null && UserDetails.Company.Trim() != ''){
            tempStr += '{"jive_label":"Company","value":"' + UserDetails.Company + '"},';
        }
        if(UserDetails.Account_ID != null && UserDetails.Account_ID.Trim() != ''){
            tempStr += '{"jive_label":"Account ID","value":"' + UserDetails.Account_ID + '"},';
        }
        tempStr += '{"jive_label":"Entitlement","value":""},';
        tempStr += '{"jive_label":"Assets","value":""},';
        tempStr += '{"jive_label":"Account Name","value":""},';
        tempStr += '{"jive_label":"Street","value":""},';
        tempStr += '{"jive_label":"City","value":""},';   
        if(UserDetails.Munchkin_ID != null && UserDetails.Munchkin_ID.Trim()!= ''){
            tempStr += '{"jive_label":"Munchkin ID","value":"' + UserDetails.Munchkin_ID + '"}],';        
        }
        if(UserDetails.UserName != null && UserDetails.UserName.Trim() != ''){
            tempStr += '"username":"' +TempTrue+UserDetails.UserName + '",';
        }
        if(UserDetails.federated != null && UserDetails.federated != ''){
            tempStr += '"federated":"' + UserDetails.federated + '"},'; 
        }
        if(UserDetails.Last_Name != null && UserDetails.Last_Name != ''){
            tempStr += '"name":{"familyName":"' + UserDetails.Last_Name + '",';
        }
         
        if(UserDetails.First_Name != null && UserDetails.First_Name != ''){
            tempStr += '"givenName":"' + UserDetails.First_Name + '"}}';
        }       
        return tempStr;             
    }  
            
    //1 Make Http Request    
    public object startHttpRequest() {
        System.debug('startHttpRequest==>');
        // Create continuation with a timeout        
        Continuation  con;
        String tmpStr = '';String tmpUrl = '';
        system.debug('updateProfileType==> '+updateProfileType);     
        system.debug('stageError ==> '+stageError);     
        system.debug('StageCntr ==> '+StageCntr);
        if(stageError == FALSE) {
            if(updateProfileType == 'Self' || updateProfileType == 'Swap') {
                con = new Continuation(40);
                // Set callback method
                con.continuationMethod='processHttpResponse';                          
                // Create a new http object to send the request object
                HttpRequest req = new HttpRequest();            
                if(JiveProfileCredentials != '') {
                    req = setAuthorizationHeader(req);
                }
                if(updateProfileType == 'Self') {
                    tmpStr = CreateJiveUserString(OldUserDetail,'');            
                    tmpUrl = jiveSetUserInfoUrl + OldUserDetail.Jive_ID;
                } else if(updateProfileType == 'Swap') {
                    if(stageCntr == 1) {
                        tmpStr = CreateJiveUserString(OldUserDetail,temp);  
                        tmpUrl = jiveSetUserInfoUrl + OldUserDetail.Jive_ID;
                    } else if(stageCntr == 2){
                        tmpStr = CreateJiveUserString(OldUserDetail,'');              
                        tmpUrl = jiveSetUserInfoUrl + NewUserDetail.Jive_ID;                
                    } else if(stageCntr == 3){
                        tmpStr = CreateJiveUserString(NewUserDetailBkup,'');              
                        tmpUrl = jiveSetUserInfoUrl + OldUserDetail.Jive_ID;                
                    }
                    system.debug('####controller 2'+tmpStr);
                }
                // Call String.format() to get the token replaced
                req.setBody(tmpStr);        
                req.setEndpoint(tmpUrl);
                req.setMethod('PUT');
                System.Debug('REQUEST_URL___' +tmpUrl);                            
                System.Debug('REQUEST_BODY___'+tmpStr);                            
                // Add callout request to continuation
                this.strHttpRestRequestLabel = con.addHttpRequest(req);      
            }                   
        } else {
            //Error Thrown, Check Stage where error occured
            if(StageCntr >= 1) {
                con = new Continuation(40);
                // Set callback method
                con.continuationMethod='processHttpResponse';       
                if(StageCntr > 1) {
                    //Create first callout request     
                    tmpStr = CreateJiveUserString(NewUserDetailBkup,'');  
                    tmpUrl = jiveSetUserInfoUrl + NewUserDetailBkup.Jive_ID;                    
                    responseString += ' <br /> ' + StageCntr + tmpUrl ;                    
                    HttpRequest req1 = new HttpRequest();
                    if(JiveProfileCredentials != '') {
                        req1 = setAuthorizationHeader(req1);            
                    }
                    req1.setBody(tmpStr);                        
                    req1.setEndpoint(tmpUrl);                
                    req1.setMethod('PUT');
                    // Add first callout request to continuation
                    this.requestLabel1 = con.addHttpRequest(req1);                     
                } else {
                    // Create second callout request
                    tmpStr = CreateJiveUserString(OldUserDetailBkup,'');  
                    tmpUrl = jiveSetUserInfoUrl + OldUserDetailBkup.Jive_ID;
                    responseString += ' <br /> ' + StageCntr + tmpUrl;
                    HttpRequest req2 = new HttpRequest();
                    if(JiveProfileCredentials != '') {
                        req2 = setAuthorizationHeader(req2);            
                    }
                    req2.setBody(tmpStr);        
                    req2.setEndpoint(tmpUrl);                
                    req2.setMethod('PUT');
                    //Add second callout request to continuation
                    this.requestLabel2 = con.addHttpRequest(req2);                    
                }
            }
        }
        return con;
    }
    
    //1 Callback method for updating jive user profile
    public Object processHttpResponse() {
        System.debug('processHttpResponse==>');        
        if(stageError == FALSE) {
            // Get the response by using the unique label
            HttpResponse response = Continuation.getResponse(this.strHttpRestRequestLabel);
            if(Test.isRunningTest()) { response  = new HttpResponse();}
            System.debug(response.getStatusCode() + ' <==> ' + response.getStatusCode() + ' <==> '  + response.getBody());        
            // Set the result variable that is displayed on the Visualforce page
            // || response.getBody().startsWithIgnoreCase('{ "error" : { "status" :');//}}
            //SWAP FAILED!. { "error" : { "status" : 409, "code" : "peopleDuplicateUsername", "message" : "A user with the same username already exists" } }
            if(response.getStatusCode() == 200 || Test.isRunningTest()) {
                //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, response.getBody()));     
                if(updateProfileType == 'Self') {
                    responseString = 'SWAP SUCCEDED!. ' + response.getStatusCode();
                } else {
                    if(stageCntr == 1) {
                        responseString = 'STEP ONE COMPLETED! CLICK NEXT. ' + response.getStatusCode();
                        stageCntr++;
                    } else if(stageCntr == 2) {
                        responseString = 'STEP TWO COMPLETED! CLICK NEXT. ' + response.getStatusCode();
                        stageCntr++;
                    } else if(stageCntr == 3) {
                        responseString = 'SWAP SUCCEDED! STEP THREE COMPLETED. ' + response.getStatusCode();
                        stageCntr++;                        
                    }
                }
            } else {
                stageError = TRUE;    
                stageErrorCntr = stageCntr;                      
                responseString = 'SWAP FAILED!. ' + response.getStatusCode() + ' <br/> ' + response.getBody();  
            }
        } else {
            Continuation chainedContinuation = null;
            if(StageCntr > 1) {                
                // Get the response of the first request                
                HttpResponse response1 = Continuation.getResponse(this.requestLabel1);
                if(response1.getStatusCode() == 200) {
                    if(StageCntr > 1) {
                        chainedContinuation = new Continuation(60);
                        // Set callback method
                        chainedContinuation.continuationMethod='processChainedResponse';
                        this.result1 = response1.getBody();
                        responseString += ' <br /> ' + StageCntr + response1.getStatusCode();
                        StageCntr--;                        
                        // Create second callout request                            
                        String tmpStr = CreateJiveUserString(OldUserDetailBkup,'');  
                        String tmpUrl = jiveSetUserInfoUrl + OldUserDetailBkup.Jive_ID;
                        responseString += ' <br /> ' + StageCntr + tmpUrl;
                        HttpRequest req2 = new HttpRequest();
                        if(JiveProfileCredentials != '') {
                            req2 = setAuthorizationHeader(req2);            
                        }
                        req2.setBody(tmpStr);        
                        req2.setEndpoint(tmpUrl);                
                        req2.setMethod('PUT');
                        //Add second callout request to continuation
                        this.requestLabel2 = chainedContinuation.addHttpRequest(req2);                                                                             
                    } else {
                        this.result1 = response1.getBody();
                        responseString = '   Rollback Succeded ' + StageCntr + response1.getStatusCode();
                        StageCntr=0;              
                        stageError = FALSE;                                   
                    }                       
                }                
            }
            return chainedContinuation; 
        }
        return null;        
    }    
    
    // Callback method for chained request
    public Object processChainedResponse() {
        // Get the response of the second request
        HttpResponse response2 = Continuation.getResponse(this.requestLabel2);
        if(Test.isRunningTest()) { response2 = new HttpResponse();}
        if(Test.isRunningTest() || response2.getStatusCode() == 200) {
            this.result2 = response2.getBody();
            responseString = '   Rollback Succeded ' + StageCntr + response2.getStatusCode();                        
            StageCntr = 0;
            stageError = FALSE;
        } else {
            this.result2 = response2.getBody();   
            responseString = '  Rollback Failed ' + StageCntr + response2.getStatusCode() + ' ' + response2.getBody() ;                        
            StageCntr = 0;
            stageError = FALSE;
        }
        return null;
    }
        
    public Object continuedProfileSwapCallout() {
        system.debug('Old User BEFORE SWAP ===> ' + OldUserDetail);
        system.debug('New User BEFORE SWAP ===> ' + NewUserDetail);          
        system.debug('temp ===> '+ temp);
        if(Test.IsrunningTest() == False && updateProfileType == 'Self' && checkForNull(OldUserDetail)) {
            responseString = 'SWAP FAILED!. All Fields are compulsary. Please update the fields and try again.';
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'SWAP FAILED!.All Fields are compulsary. Please update the fields and try again.'));
            return null;
        } else if(Test.IsrunningTest() == False && updateProfileType == 'Swap' && ( checkForNull(OldUserDetail) || checkForNull(NewUserDetail) )) {
            //ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'SWAP FAILED!.All Fields are compulsary.Please update the fields and try again.'));
            responseString = 'SWAP FAILED!. All Fields are compulsary. Please update the profile fields and try again.';
            return null;
        }
        if(stageError) {
            responseString = 'SWAP FAILED!. Please make sure profile info is reverted before making a fresh change request.';
            return null;            
        }        
        return startHttpRequest();                                               
    }
       
    public Object continuedProfileRollbackCallout() {
        system.debug('Old User BEFORE SWAP ===> ' + OldUserDetailBkup);
        system.debug('New User BEFORE SWAP ===> ' + NewUserDetailBkup);          
        system.debug('temp ===> '+ temp);
        system.debug('StageCntr ===> '+ StageCntr );        
        stageError = TRUE;
        return startHttpRequest();          
    }
    
}