public class JiveKCScontroller {
    public string title{get;set;}
    public string IssueDescription{get;set;}
    public string WhoThisSolutionAppliesTo{get;set;}    
    public string IssueResolution{get;set;}
    public string Metadata{get;set;}
    public string spaceValue {get;set;}
    public string jiveUserId;
    public string jiveGetUserInfoUrl;
    public Blob headerValue;
    public string categories {get;set;}
    public List<SelectOption> options {get;set;}
   
    public JiveKCScontroller(){
        title = '';
        IssueDescription='';
        WhoThisSolutionAppliesTo ='';
        IssueResolution ='';
        Metadata='';  
        jiveUserId='';   
        jiveGetUserInfoUrl = '';
        options = new List<SelectOption>();
    }
    public void getCategories(){
       
        jiveGetUserInfoUrl = 'https://marketoemployee.jiveon.com/api/core/v3/people/email/';
        HttpRequest reqCheck = new HttpRequest();   
        HttpResponse resCheckOld = new HttpResponse();
        Http httpCheckOld = new Http();
        headerValue = Blob.valueOf(label.mktoCentralCredentials);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        reqCheck.setHeader('Authorization', authorizationHeader);
        reqCheck.setHeader('content-type', 'application/json');
        reqCheck.setHeader('Accept', 'application/json');
        reqCheck.setTimeout(120000); 
        reqCheck.setEndpoint('https://marketoemployee.jiveon.com/api/core/v3/places/10540/categories/');
        reqCheck.setMethod('GET'); 
        String JSONContentOld = '';     
        try {
            if(Test.isRunningTest() == false){
                resCheckOld =  httpCheckOld.send(reqCheck);           
                System.debug('resCheckOld'+resCheckOld.getBody());
                JSONContentOld = resCheckOld.getBody();            
            } 
        }catch(System.CalloutException e){
                System.debug('Callout error: '+ e);            
        } 
        JSONContentOld = JSONContentOld.remove('throw \'allowIllegalResourceCall is false.\';');
        if(String.IsNotBlank(JSONContentOld)){
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(JSONContentOld);
            Map<String, Object> nameMap = (Map<String, Object>)m;
            for(object keyStr : nameMap.values()) {
                for(object o : (List<Object>)keyStr){
                   Map<String,object> dd = (Map<String, Object>)o;
                   for(String s : dd.keySet()){
                       if(s == 'name'){
                         options.add(new SelectOption(String.valueOf(dd.get(s)),String.valueOf(dd.get(s))));
                       }
                   }
                }
            }
        }    
    }
    
    public string getJiveUserId(){
     
        String jiveGetUserInfoUrl = (spaceValue == 'Internal') ? System.Label.jiveGetUserInfoUrl_Internal : System.Label.jiveGetUserInfoUrl;        
        HttpRequest reqCheck = new HttpRequest();   
        HttpResponse resCheckOld = new HttpResponse();
        Http httpCheckOld = new Http();
        String headerValueToConvert = (spaceValue == 'Internal') ? System.Label.Jive_KCS_Credentials_Internal : System.Label.Jive_KCS_Credentials;        
        headerValue = Blob.valueOf(headerValueToConvert);        
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        reqCheck.setHeader('Authorization', authorizationHeader);
        reqCheck.setHeader('content-type', 'application/json');
        reqCheck.setHeader('Accept', 'application/json');
        reqCheck.setTimeout(120000); 
        
        reqCheck.setEndpoint(jiveGetUserInfoUrl+userinfo.getuserEmail());
        reqCheck.setMethod('GET'); 
        String JSONContentOld = '';     
        try {
            if(Test.isRunningTest() == false) {
                resCheckOld =  httpCheckOld.send(reqCheck);           
                System.debug('resCheckOld'+resCheckOld.getBody());
                JSONContentOld = resCheckOld.getBody();            
            } else {
                JSONContentOld = '{"id":"2092","resources":{"reports":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@reports"},"followingIn":{"allowed":["POST","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/followingIn"},"images":{"allowed":["POST","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/images"},"activity":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/activities"},"manager":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@manager"},"social":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@social"},"streams":{"allowed":["POST","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/streams"},"recognition":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@recognition"},"trendingContent":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@trendingContent"},"trendingPlaces":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@trendingPlaces"},"avatar":{"allowed":["PUT","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/avatar?a=-1"},"followers":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@followers"},"pages":{"allowed":["POST","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/pages"},"colleagues":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@colleagues"},"following":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@following"},"members":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/members/people/2092"},"self":{"allowed":["DELETE","PUT","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092"},"html":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/people/vishals%40grazitti.com"},"securityGroups":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/securityGroups"},"extprops":{"allowed":["POST","DELETE","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/extprops"},"tasks":{"allowed":["POST","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/tasks"}},"followerCount":0,"published":"2015-04-07T04:32:35.639+0000","updated":"2015-05-21T08:00:06.795+0000","displayName":"VishalSharma","mentionName":"VishalSharma","emails":[{"jive_label":"Email","primary":true,"type":"work","value":"vishals@grazitti.com","jive_displayOrder":6,"jive_summaryDisplayOrder":1,"jive_showSummaryLabel":true}],"followingCount":0,"directReportCount":0,"jive":{"enabled":true,"external":false,"externalIdentities":[],"federated":false,"lastProfileUpdate":"2015-05-20T10:24:37.554+0000","lastAuthenticated":"2015-05-21T05:31:32.901+0000","level":{"imageURI":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/images/status/statusicon-47.gif","name":"Newbie","points":5},"locale":"en_US","externalContributor":false,"profile":[{"jive_label":"ContactID","value":"0035000001YjI1IAAV","jive_displayOrder":21,"jive_showSummaryLabel":false},{"jive_label":"AccountID","value":"0015000000fD2sOAAS","jive_displayOrder":23,"jive_showSummaryLabel":false},{"jive_label":"Customer","value":"No","jive_displayOrder":27,"jive_showSummaryLabel":false},{"jive_label":"MunchkinID","value":"CF-TEST-123","jive_displayOrder":31,"jive_showSummaryLabel":false}],"sendable":true,"timeZone":"America/Los_Angeles","username":"vishals@grazitti.com","visible":true,"termsAndConditionsRequired":false},"location":"Chandigarh,India","name":{"familyName":"Sharma","formatted":"VishalSharma","givenName":"Vishal"},"phoneNumbers":[{"jive_label":"PhoneNumber","primary":true,"type":"work","value":"+91-7837316810","jive_displayOrder":14,"jive_showSummaryLabel":false}],"thumbnailId":"-1","thumbnailUrl":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/avatar?a=-1","initialLogin":"2015-04-29T09:33:48.315+0000","type":"person"}';
            }
        }catch(System.CalloutException e){
                System.debug('Callout error: '+ e);            
        } 
        JSONContentOld = JSONContentOld.remove('throw \'allowIllegalResourceCall is false.\';');
        if(String.isNotBlank(JSONContentOld)){
            Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(JSONContentOld);
                for(String keyStr : m.keySet()) {
                    if(keyStr == 'id'){
                    jiveUserId = ''+m.get(keyStr);
                }
            }
        }    
        return jiveUserId;
    }
   
    public void publishArticleInJive(){
        title = title.replace('"', '\\"');
        System.debug('Form Data=>'+categories + ',' +title+','+IssueDescription+','+WhoThisSolutionAppliesTo+','+IssueResolution+','+Metadata);string finalMetadata = '';       
        if(System.Label.JiveProfileCredentials != '') {            
            if(test.isRunningTest() ) Metadata = 'Test';
            if(Metadata!=null && Metadata!=''){
                for(string tag: Metadata.split(',')){
                    if(finalMetadata == ''){
                        finalMetadata = '"tags":["'+tag+'"';
                    }else{
                        finalMetadata += ',"'+tag+'"';
                    }
                }
                if(finalMetadata != ''){
                    finalMetadata += ']';
                }
                if(spaceValue == 'Internal'){
                    finalMetadata += ',';                    
                    if(String.isNotBlank(categories)){
                        categories = categories.substringBetween('[',']').replaceAll(', ', ',');
                        String categoriesToSend = '"categories":["';
                        categoriesToSend += String.join(categories.split(','), '","');                      
                        categoriesToSend += '"]';
                        System.debug('............'+categoriesToSend);
                        finalMetadata += categoriesToSend;
                    }
                }
            }    
        }
        string body = '<b>Issue Description</b><br/>' +IssueDescription+ '<br/><br/><b>Issue Resolution</b><br/> '+IssueResolution + '<br/><br/><b>Who This Solution Applies To </b><br/>'+WhoThisSolutionAppliesTo ;       
        body = body.replace('\r\n', '<br/>');
        body = body.replace('\"', '\\"');
        system.debug('body==>>'+body);
        string jiveId = getJiveUserId(); //fetch userId from Jive
        system.debug('jiveId## ' +jiveId);
        HttpRequest reqCheck = new HttpRequest();
        HttpResponse responseFromJive = new HttpResponse();
        Http httpCheck = new Http();                
        string JiveUrl = spaceValue == 'Internal' ? System.Label.Jive_Content_Api_Internal : System.Label.Jive_Content_Api;        
        string jiveStr;
        string PlaceURL = spaceValue == 'Internal' ? System.Label.Kcs_Place_URL_Internal : System.Label.Kcs_Place_URL;
        if(finalMetadata != ''){
            if(String.IsNotBlank(jiveId)){
                jiveStr = '{"content":{"type":"text/html","text":"'+body+'"},"subject":"'+title+'","type":"document","parent" :"'+PlaceURL+'", "onBehalfOf":{"email":"'+userinfo.getuserEmail()+'"},"authorship":"open","authors":[{"id":"'+jiveId+'"}],'+finalMetadata+'}';
            }
            else{
                jiveStr = '{"content":{"type":"text/html","text":"'+body+'"},"subject":"'+title+'","type":"document","parent" :"'+PlaceURL+'", "onBehalfOf":{"email":"'+userinfo.getuserEmail()+'"},'+finalMetadata+'}';
            }
        }else{
            if(String.IsNotBlank(jiveId)) jiveStr = '{"content":{"type":"text/html","text":"'+body+'"},"subject":"'+title+'","type":"document","parent" :"'+PlaceURL+'", "onBehalfOf":{"email":"'+userinfo.getuserEmail()+'"},"authorship":"open","authors":[{"id":"'+jiveId+'"}]}';
            else jiveStr = '{"content":{"type":"text/html","text":"'+body+'"},"subject":"'+title+'","type":"document","parent" :"'+PlaceURL+'", "onBehalfOf":{"email":"'+userinfo.getuserEmail()+'"}}';
        }
        System.debug('$$jiveStr ' +jiveStr);
        String headerValueToConvert = (spaceValue == 'Internal') ? System.Label.Jive_KCS_Credentials_Internal : System.Label.Jive_KCS_Credentials;        
        Blob headerValue = Blob.valueOf(headerValueToConvert);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        reqCheck.setHeader('Authorization', authorizationHeader);
        reqCheck.setHeader('content-type', 'application/json');
        reqCheck.setHeader('Accept', 'application/json');
        reqCheck.setBody(jiveStr);
        reqCheck.setTimeout(120000);        
        reqCheck.setEndpoint(JiveUrl);
        reqCheck.setMethod('POST');
        Integer statusCode= 0; 
        if(Test.isRunningTest() == false){          
            responseFromJive =  httpCheck.send(reqCheck);
            statusCode = responseFromJive.getStatusCode();
         }
        if(statusCode ==201) ApexPages.addmessage(new ApexPages.message(ApexPages.severity.CONFIRM,'Your Article has been successfully posted'));
        else if(statusCode ==409) ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'ERROR: Article with the same TITLE already exists. Please try again using different title'));
        else ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Error: Some error occur. Please try again.'));
    }
}