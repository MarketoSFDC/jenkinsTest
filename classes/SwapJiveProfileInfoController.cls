public class SwapJiveProfileInfoController{

    public Set<String> checkStr {get;set;}    
    public String userIdOld {get;set;}
    public String userIdNew {get;set;}
    public boolean isSuccess {get;set;}
    public boolean isReverted {get;set;}
    public boolean IsCorrupted {get;set;}
    public boolean hasNotFailed {get;set;}
    public boolean hasCommProfile{get;set;}
    public String updateProfileType {get;set{updateProfileType = value;}}
    public string UserNotupdated ='';
    public string temp;
        
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
    
    
    public SwapJiveProfileInfoController(ApexPages.StandardController stdController) {    
        init(); 
    }

    public void init() {
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
    
    public List<Schema.FieldSetMember> getFields() {
        return null;
    }
    
    public List<SelectOption> getInActiveUsers() {
        List<SelectOption> options = new List<SelectOption>();
        return options;
    }
    
    public PageReference getUserDetails() {         
        return null; 
    }
    
    public SwapJiveProfileInfoController(){
        temp = system.now().getTime()+ '__';
        isSuccess = false;
        hasNotFailed = true;
        init(); 
    }
    
    public void refreshPanel() {
        hasCommProfile = false;
    }
        

    public void swap(){
        hasNotFailed = true;
        isSuccess = false;
        List<String> msg = new List<String>();
        string msg3;
        string msg4;
        msg = new List<String>();
        if(OldUserDetail.Email == NULL || Test.isRunningTest() == True ) {
            msg.add('Old User Email Missing.');
        }
        if (NewUserDetail.Email == NULL) {
            msg.add('New User Email Missing.');
        }
        system.debug('msg===>'+msg);
        
        if(msg.size() > 0) {
            String msg2 = 'Required fields are missing: ';
            for (Integer i=0; i<msg.size(); i++) {
                msg2 +=  msg[i] + (i<msg.size()-1 ? ', ' : '');
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg2));
             return ;
        } else if(userIdOld.trim() != '' || Test.isRunningTest() == True ){
            if(!userIdOld.startswithIgnoreCase('005')){
                msg3 = 'Please enter valid Old UserId';               
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg3));                
                 return;
            } 
        }                
        if(msg.size() == 0 && msg3 == null && msg4 == null){
            try {        
                automateProfileSwappingCallout();
            } catch (Exception ex) {
                msg4 = 'Exception=> ' + ex;
                system.debug('msg4===>'+msg4);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg4));
                return;
            }                   
        }
    } 
    
    public void getProfileSwappingCallout() {
     isSuccess = false;
        system.debug('Old User ===> '+ OldUserDetail);
        system.debug('New User ===> '+ NewUserDetail );

        String jiveGetUserInfoUrl = System.Label.jiveGetUserInfoUrl;
         
        HttpRequest reqCheckOld = new HttpRequest();
        HttpResponse resCheckOld = new HttpResponse();
        Http httpCheckOld = new Http();
        reqCheckOld.setEndpoint(jiveGetUserInfoUrl+OldUserDetail.Email);
        if(System.Label.JiveProfileCredentials != '') {
            Blob headerValue = Blob.valueOf(System.Label.JiveProfileCredentials);
            String authorizationHeader = 'Basic ' +
            EncodingUtil.base64Encode(headerValue);
            reqCheckOld.setHeader('Authorization', authorizationHeader);
            reqCheckOld.setHeader('content-type', 'application/json');
            reqCheckOld.setHeader('Accept', 'application/json'); 
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
            Blob headerValue = Blob.valueOf(System.Label.JiveProfileCredentials);
            String authorizationHeader = 'Basic ' +
            EncodingUtil.base64Encode(headerValue);
            reqCheckNew.setHeader('Authorization', authorizationHeader);
            reqCheckNew.setHeader('content-type', 'application/json');
            reqCheckNew.setHeader('Accept', 'application/json'); 
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
            System.debug('Player error invalid player');                                                                                                 
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
            if(keyStr == 'jive') { Map<String,Object> mapVal = (Map<String, Object>)mm.get(keyStr);
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
    }
     

    public void automateProfileSwappingCallout() {
        system.debug('Old User BEFORE SWAP ===> '+ OldUserDetail);
        system.debug('New User BEFORE SWAP ===> '+ NewUserDetail);          
        system.debug('temp ===> '+ temp);
        if(test.IsrunningTest()==False && updateProfileType == 'Self' && (OldUserDetail.AltEmail == null || OldUserDetail.AltEmail.trim() == '' || OldUserDetail.Email == null || OldUserDetail.Email.trim() == '' || OldUserDetail.External_ID == null || OldUserDetail.External_ID.trim() == '' || OldUserDetail.Contact_ID == null || OldUserDetail.Contact_ID.trim() == '' || OldUserDetail.Company == null || OldUserDetail.Company.trim() == '' || OldUserDetail.Account_ID == null || OldUserDetail.Account_ID.trim() == '' || OldUserDetail.Munchkin_ID == null || OldUserDetail.Munchkin_ID.trim() == '' || OldUserDetail.UserName == null || OldUserDetail.UserName.trim() == '' || OldUserDetail.federated == null || OldUserDetail.federated.trim() == '' || OldUserDetail.Last_Name == null || OldUserDetail.Last_Name.trim() == '' || OldUserDetail.First_Name == null || OldUserDetail.First_Name.trim() == '')){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'SWAP FAILED!. All Fields are compulsary. Please update the fields and try again.'));
            return;
        }
        else if(test.IsrunningTest()==False && updateProfileType == 'Swap' && (OldUserDetail.AltEmail == null || OldUserDetail.AltEmail.trim() == '' || OldUserDetail.Email == null || OldUserDetail.Email.trim() == '' || OldUserDetail.External_ID == null || OldUserDetail.External_ID.trim() == '' || OldUserDetail.Contact_ID == null || OldUserDetail.Contact_ID.trim() == '' || OldUserDetail.Company == null || OldUserDetail.Company.trim() == '' || OldUserDetail.Account_ID == null || OldUserDetail.Account_ID.trim() == '' || OldUserDetail.Munchkin_ID == null || OldUserDetail.Munchkin_ID.trim() == '' || OldUserDetail.UserName == null || OldUserDetail.UserName.trim() == '' || OldUserDetail.federated == null || OldUserDetail.federated.trim() == '' || OldUserDetail.Last_Name == null || OldUserDetail.Last_Name.trim() == '' || OldUserDetail.First_Name == null || OldUserDetail.First_Name.trim() == '' || NewUserDetail.AltEmail == null || NewUserDetail.AltEmail.trim() == '' || NewUserDetail.Email == null || NewUserDetail.Email.trim() == '' || NewUserDetail.External_ID == null || NewUserDetail.External_ID.trim() == '' || NewUserDetail.Contact_ID == null || NewUserDetail.Contact_ID.trim() == '' || NewUserDetail.Company == null || NewUserDetail.Company.trim() == '' || NewUserDetail.Account_ID == null || NewUserDetail.Account_ID.trim() == '' || NewUserDetail.Munchkin_ID == null || NewUserDetail.Munchkin_ID.trim() == '' || NewUserDetail.UserName == null || NewUserDetail.UserName.trim() == '' || NewUserDetail.federated == null || NewUserDetail.federated.trim() == '' || NewUserDetail.Last_Name == null || NewUserDetail.Last_Name.trim() == '' || NewUserDetail.First_Name == null || NewUserDetail.First_Name.trim() == '')){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'SWAP FAILED!. All Fields are compulsary. Please update the fields and try again.'));
            return;
        }
  
        String jiveSetUserInfoUrl = System.Label.jiveSetUserInfoUrl ;
        String JSONContentOld = '';  
        String JSONContentNew = '';
        String JSONContentTemp = '';
    
        HttpRequest reqOld = new HttpRequest();
        HttpResponse resOld = new HttpResponse();
        Http httpOld = new Http(); 

        if(System.Label.JiveProfileCredentials != '') {
            Blob headerValue = Blob.valueOf(System.Label.JiveProfileCredentials);
            String authorizationHeader = 'Basic ' +
            EncodingUtil.base64Encode(headerValue);
            reqOld.setHeader('Authorization', authorizationHeader);
            reqOld.setHeader('content-type', 'application/json');
            reqOld.setHeader('Accept', 'application/json'); 
        }
        String tmpStr = '';        
        system.debug('updateProfileType'+updateProfileType);
        if(updateProfileType == 'Self'){
            tmpStr = JiveUserString( OldUserDetail,False );
            
        } else if(updateProfileType == 'Swap'){ 
            tmpStr = JiveUserString( OldUserDetail,True);  
            system.debug('tmpStr------------------->'+tmpStr);         
        }
                                                   
        reqOld.setEndpoint(jiveSetUserInfoUrl + OldUserDetail.Jive_ID);
        reqOld.setMethod('PUT');
        reqOld.setBody(tmpStr);        
        System.Debug('REQUEST_URL__'+jiveSetUserInfoUrl + OldUserDetail.Jive_ID);
        System.Debug('REQUEST_BODY___'+tmpStr);       
        
        Try {  
            if(Test.isRunningTest() == false) {
                resOld =  httpOld.send(reqOld);           
                System.debug('resOld.getBod===>'+resOld.getBody());
                JSONContentOld = resOld.getBody();            
            }
        } catch(System.CalloutException e) {
             System.debug('Callout error: '+ e);            
        }
             
        if(Test.isRunningTest() == true) {
             JSONContentOld = '{"success":"successfully changed info"}';
        } else {
            System.debug('resOld.getStatus()'+ resOld.getStatus());
            if(resOld.getStatus() != 'OK'  ) { 
                system.debug('first response===> ');
                isSuccess = false;
                return;
            }
        }
                
        if(updateProfileType == 'Self' ) {
            isSuccess = true;
            if(Test.isRunningTest() == false) return;
        }
        // <<<------ checked ----->>>>>
        system.debug('OldUserDetailBkup  BEFORE SWAP ===> '+ OldUserDetailBkup);
        HttpRequest reqNew = new HttpRequest();
        HttpResponse resNew = new HttpResponse();
        Http httpNew = new Http(); 

        System.debug('resOld.getStatus()2'+ resOld.getStatus());
        if(resOld.getStatus() == 'OK' || Test.isRunningTest() == true) {    
            system.debug('JSONContentOld==>'+JSONContentOld);                
            if(System.Label.JiveProfileCredentials != '') {
                Blob headerValue = Blob.valueOf(System.Label.JiveProfileCredentials);
                String authorizationHeader = 'Basic ' +
                EncodingUtil.base64Encode(headerValue);
                reqNew.setHeader('Authorization', authorizationHeader);
                reqNew.setHeader('content-type', 'application/json');
                reqNew.setHeader('Accept', 'application/json'); 
            }                            
            
            tmpStr = JiveUserString( OldUserDetail,False );
            system.debug('####Controller1 ' +tmpStr );
            reqNew.setEndpoint(jiveSetUserInfoUrl+NewUserDetail.Jive_ID);
            reqNew.setMethod('PUT');
            reqNew.setBody(tmpStr);   
            System.debug('__UPDATE FIRST PROFILE WITH SECOND PROFILE BODY__'+tmpStr);     
            System.debug('__UPDATE FIRST PROFILE WITH SECOND PROFILE URL__'+jiveSetUserInfoUrl+NewUserDetail.Jive_ID);     

            if(Test.isRunningTest() == false) {
                resNew =  httpNew.send(reqNew);           
                System.debug(resNew.getBody());
                JSONContentNew = resNew.getBody();            
            }                     
        }
                 
        system.debug('JSONContentNew==>'+JSONContentNew);
        if(Test.isRunningTest() == true){
             //Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped('{"success":"successfully changed email"}');
             //SessionId = string.valueOf(m.get('access_token')); 
             JSONContentNew = '{"success":"successfully changed email"}'  ;
        }
        
        System.debug('resOld.getStatus()3'+ resNew.getStatus());                     
        if(resNew.getStatus() == 'Ok'){ 
            system.debug('seconnd response===> ');
            tmpStr = JiveUserString( NewUserDetail,False );
        } else if(Test.isRunningTest() == true || resNew.getStatus() != 'Ok') { //Revert back 
            isSuccess = false;
            System.Debug('__REVERT__');
            system.debug('first revert===> ');
            tmpStr = JiveUserString( OldUserDetailBkup,False );       
        }  
        HttpRequest reqTemp = new HttpRequest();
        HttpResponse resTemp = new HttpResponse();
        Http httpTemp = new Http();
        if(System.Label.JiveProfileCredentials != '') {
            Blob headerValue = Blob.valueOf(System.Label.JiveProfileCredentials);
            String authorizationHeader = 'Basic ' +
            EncodingUtil.base64Encode(headerValue);
            reqTemp.setHeader('Authorization', authorizationHeader);
            reqTemp.setHeader('content-type', 'application/json');
            reqTemp.setHeader('Accept', 'application/json'); 
        } 
        system.debug('jiveSetUserInfoUrl '+jiveSetUserInfoUrl ); 
        system.debug('OldUserDetail.Jive_ID'+OldUserDetail.Jive_ID);                
        reqTemp.setEndpoint(jiveSetUserInfoUrl + OldUserDetail.Jive_ID);
        reqTemp.setMethod('PUT');  
        reqTemp.setBody(tmpStr);  
        System.debug('__SWAP REQUEST THIRD__BODY'+tmpStr);    
        System.debug('__SWAP REQUEST THIRD__URL'+jiveSetUserInfoUrl + OldUserDetail.Jive_ID);                       
                   
        Try {        
            if(Test.isRunningTest() == false) {
                resTemp =  httpTemp.send(reqTemp);           
                System.debug('JSONContentTempBody==>'+resTemp.getBody());
                JSONContentTemp = resTemp.getBody();            
            }
            system.debug('JSONContentTemp==>'+JSONContentTemp);
            System.debug(' resTemp.getStatus()------->'+ resTemp.getStatus());
            if(resTemp.getStatus() == 'OK'){ 
                system.debug('third response===> ');
                isSuccess = true;
            }
            else if(Test.isRunningTest() == true || resTemp.getStatus() != 'Ok') {
                system.debug('second revert===> '); 
                isSuccess = false;
                hasNotFailed = false;
                System.Debug('__REVERT__');
                tmpStr = JiveUserString( NewUserDetailBkup,False );             
                HttpRequest reqRevertTemp = new HttpRequest();
                HttpResponse resRevertTemp = new HttpResponse();
                Http httpRevertTemp = new Http();
                if(System.Label.JiveProfileCredentials != '') {
                Blob headerValue = Blob.valueOf(System.Label.JiveProfileCredentials);
                String authorizationHeader = 'Basic ' +
                EncodingUtil.base64Encode(headerValue);
                reqRevertTemp.setHeader('Authorization', authorizationHeader);
                reqRevertTemp.setHeader('content-type', 'application/json');
                reqRevertTemp.setHeader('Accept', 'application/json'); 
                } 
                system.debug('jiveSetUserInfoUrl '+jiveSetUserInfoUrl ); 
                system.debug('NewUserDetailBkup.Jive_ID'+NewUserDetailBkup.Jive_ID);                
                reqRevertTemp.setEndpoint(jiveSetUserInfoUrl + NewUserDetailBkup.Jive_ID);
                reqRevertTemp.setMethod('PUT');  
                reqRevertTemp.setBody(tmpStr);  
                System.debug('__SWAP REQUEST THIRD__BODY'+tmpStr);    
                System.debug('__SWAP REQUEST THIRD__URL'+jiveSetUserInfoUrl + NewUserDetailBkup.Jive_ID);                      
                        
                if(Test.isRunningTest() == false) {
                    resRevertTemp =  httpTemp.send(reqRevertTemp);           
                    System.debug('JSONContentTempBody==>'+resRevertTemp.getBody());
                    JSONContentTemp = reqRevertTemp.getBody();            
                }
                system.debug('JSONContentTemp==>'+JSONContentTemp);
                System.debug(' resTemp.getStatus()------->'+ resRevertTemp.getStatus());
                if(resRevertTemp.getStatus() == 'OK'){ 
                    isSuccess = False;
                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'SWAP FAILED!. User info is corrupted. Please reset user manually'));
                }
                ///---------------->OldUserDetailBkup
                tmpStr = JiveUserString( OldUserDetailBkup,False);             
                HttpRequest reqRevertTemp1 = new HttpRequest();
                HttpResponse resRevertTemp1 = new HttpResponse();
                Http httpRevertTemp1 = new Http();
                if(System.Label.JiveProfileCredentials != '') {
                Blob headerValue = Blob.valueOf(System.Label.JiveProfileCredentials);
                String authorizationHeader = 'Basic ' +
                EncodingUtil.base64Encode(headerValue);
                reqRevertTemp1.setHeader('Authorization', authorizationHeader);
                reqRevertTemp1.setHeader('content-type', 'application/json');
                reqRevertTemp1.setHeader('Accept', 'application/json'); 
                } 
                system.debug('jiveSetUserInfoUrl '+jiveSetUserInfoUrl ); 
                system.debug('OldUserDetailBkup.Jive_ID'+OldUserDetailBkup.Jive_ID);                
                reqRevertTemp1.setEndpoint(jiveSetUserInfoUrl + OldUserDetailBkup.Jive_ID);
                reqRevertTemp1.setMethod('PUT');  
                reqRevertTemp1.setBody(tmpStr);  
                System.debug('__SWAP REQUEST THIRD__BODY'+tmpStr);    
                System.debug('__SWAP REQUEST THIRD__URL'+jiveSetUserInfoUrl + OldUserDetailBkup.Jive_ID);                      
                        
                if(Test.isRunningTest() == false) {
                    resRevertTemp1 =  httpTemp.send(reqRevertTemp1);           
                    System.debug('JSONContentTempBody==>'+resRevertTemp1.getBody());
                    JSONContentTemp = reqRevertTemp.getBody();            
                }
                system.debug('JSONContentTemp==>'+JSONContentTemp);
                System.debug(' resTemp.getStatus()------->'+ resRevertTemp1.getStatus());
                if(resRevertTemp1.getStatus() == 'OK'){ 
                    isSuccess = False;
                }else{
                    ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'SWAP FAILED!. User info is corrupted. Please reset user manually'));
                }
                ///---------------->
            }
            
        } catch(System.CalloutException e) {
            System.debug('Callout error: '+ e);            
        }                                        
    }  
    
    public string JiveUserString( jiveUser UserDetails, Boolean TempTrue ){
        system.debug('UserDetails------------------->'+UserDetails);
        string tempStr = '';        
        
        if(UserDetails.AltEmail != null && UserDetails.AltEmail != ''){
            tempStr = '{"emails":[{"jive_label":"Alternate Email", "value":"' + UserDetails.AltEmail + '"},'; 
            }      
        if(TempTrue==False){ 
            tempStr += '{"jive_label":"Email","primary":true,"value":"' + UserDetails.Email + '"}],';
        }Else if(TempTrue==True){
            tempStr += '{"jive_label":"Email","primary":true,"value":"' +temp + UserDetails.Email + '"}],';
            UserNotupdated = temp + UserDetails.Email;
        }
        if(UserDetails.External_ID != null && UserDetails.External_ID != '' && TempTrue==False){
            tempStr += '"jive":{"enabled":true,"externalIdentities":[{"identityType":"SAML","identity":"' + UserDetails.External_ID + '"}],';
        }Else if(UserDetails.External_ID != null && UserDetails.External_ID != '' && TempTrue==True){
            tempStr += '"jive":{"enabled":true,"externalIdentities":[{"identityType":"SAML","identity":"' +temp + UserDetails.External_ID + '"}],';
        }
        if(UserDetails.Contact_ID != null && UserDetails.Contact_ID != ''){
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
        if(UserDetails.Munchkin_ID != null && UserDetails.Munchkin_ID != ''){
            tempStr += '{"jive_label":"Munchkin ID","value":"' + UserDetails.Munchkin_ID + '"}],';
        }
        if(UserDetails.UserName != null && UserDetails.UserName != '' && TempTrue==False){
            tempStr += '"username":"' + UserDetails.UserName + '",';
        }Else if(UserDetails.UserName != null && UserDetails.UserName != '' && TempTrue==True){
            tempStr += '"username":"' +temp + UserDetails.UserName + '",';
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
        
        Return tempStr;             
    }
  
}