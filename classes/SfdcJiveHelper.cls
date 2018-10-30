global class SfdcJiveHelper implements Database.Batchable<contact>, Database.AllowsCallouts{   
    public static boolean RunIntegrationTriggerOnce = false;
    public static boolean RunIntegrationTriggerOnceOnAuthCon = false;
    public static boolean RunIntegrationTriggerOnceEnt = false;
    public static boolean RunIntegrationTriggerOnceAcc = false;
    public static boolean RUntriggerByJIveCode = false;
    List<Contact> ConToTarget;
    map<id, string> ConIdEmailMap = new map<id, string>();
    map<id, string> ConIDStringMap = new map<id, string>();
    map<id,id> ConAssetId;
    map<id,id> ConEntitlementId;
    map<id,String> IsAuthConMap;
    map<id,String> ConSupportLevelMap;
    
    global SfdcJiveHelper(map<id, string> ConIdEmail, map<id, string> ConIDString) {        
        system.debug('Constructor called ----->');
        ConIdEmailMap  =  ConIdEmail;
        ConIDStringMap =  ConIDString;
        ConAssetId = new map<id,id>();
        ConEntitlementId = new map<id,id>();
        IsAuthConMap = new map<id,String>();
        ConSupportLevelMap = new map<id,String>();
        ConToTarget = new List<Contact>();
    } 
    
    global Iterable<Contact> start (database.batchablecontext BC) {
        Map<Id, Contact> tmpCons ;         
        if(test.IsRunningTest()){
            tmpCons = new Map<Id, Contact>([SELECT ID, Is_Authorized_Contact__c, Email from Contact Where Id in :ConIdEmailMap.keyset() Limit 1]);
            ConToTarget.AddAll(tmpCons.values());     
        }else{
            tmpCons = new Map<Id, Contact>([SELECT ID, Is_Authorized_Contact__c, Email from Contact Where Id in :ConIdEmailMap.keyset()]);
            ConToTarget.AddAll(tmpCons.values()); 
        }
        system.debug('ConToTargetsize----->'+ConToTarget.size());
        system.debug('ConToTarget----->'+ConToTarget);
               
        return (ConToTarget);    
    }  
    
    global void finish(Database.BatchableContext BC) {
    
    }
    
    global void execute(Database.BatchableContext BC, List<Contact> scope) {
        system.debug('execute called: ' + scope);
        map<string, string> ConEmailStringMap;
        Set<Id> ValidConIds = new Set<Id>();
        for(Contact Con : scope) {
            ConEmailStringMap = new map<string, string> ();
            ValidConIds.add(Con.Id);
            ConEmailStringMap.put(ConIdEmailMap.get(Con.id), ConIDStringMap.get(Con.id));
            system.debug('ConEmailStringMap----->'+ConEmailStringMap);
            getProfileSwappingCallout(ConEmailStringMap, Con);
        }
    }
    
    public Static String parseContentfromTag(String startTag, String endTag, String TextBody) {
        integer Start = TextBody.indexOf(startTag);
        integer StartLoc = Start + startTag.length();
        integer EndLoc = TextBody.indexOf(endTag);
        String content = TextBody.substring(StartLoc, EndLoc);
        system.debug('content ' + content);
        return content;
    }
    
    public void getProfileSwappingCallout(map<string, string> FinalConEmailStringMap, contact ConIdUnderProcessing) {        
            system.debug('ConIdUnderProcessing.Is_Authorized_Contact__c--->'+ConIdUnderProcessing.Is_Authorized_Contact__c);           
            IsAuthConMap.put(ConIdUnderProcessing.id, ConIdUnderProcessing.Is_Authorized_Contact__c);                    
        
        
        for(Authorized_Contact__c authCon : [select id, Entitlement__c, Entitlement__r.type, Contact__c, Entitlement__r.Assetid from Authorized_Contact__c where Contact__c in :ConIdEmailMap.keyset()]){
            ConAssetId.put(authCon.Contact__c, authCon.Entitlement__r.assetId);
            ConEntitlementId.put(authCon.Contact__c, authCon.Entitlement__c);
            ConSupportLevelMap.put(authCon.Contact__c, authCon.Entitlement__r.type);                                           
        }
        system.debug('FinalConEmailStringMap------------>'+FinalConEmailStringMap);
        system.debug('ConAssetId ----->'+ConAssetId );
        system.debug('ConEntitlementId ----->'+ConEntitlementId );
        system.debug('IsAuthConMap----->'+IsAuthConMap);
        string EmailStr;
        for(string tmp :  FinalConEmailStringMap.keyset()) {
            EmailStr = tmp;
            break;
        }
        list<string> TmpSTr = FinalConEmailStringMap.values();
        //contact ConUnderProcessing = FinalConIdEmailMap.get();
        system.debug('TmpSTr------------>'+TmpSTr); 
        jiveUser UserDetail = new jiveUser(); 
        //Contact Fields assignment
        if( TmpSTr[0].contains('#Email#') ){
            UserDetail.Email                                                            =     parseContentfromTag('#Email#', '#Email1#', TmpSTr[0]);
        }else{
            UserDetail.Email                                                            =     EmailStr;
        }
        if( TmpSTr[0].contains('#NewEmail#') )UserDetail.NewEmail                       =     parseContentfromTag('#NewEmail#', '#NewEmail1#', TmpSTr[0]);
        if( TmpSTr[0].contains('#FirstName#') )UserDetail.First_Name                    =     parseContentfromTag('#FirstName#', '#FirstName1#', TmpSTr[0]);
        if( TmpSTr[0].contains('#lastName#') )UserDetail.Last_Name                      =     parseContentfromTag('#lastName#', '#lastName1#', TmpSTr[0]);
        if( TmpSTr[0].contains('#MunchkinID#') )UserDetail.Munchkin_ID                  =     parseContentfromTag('#MunchkinID#', '#MunchkinID1#', TmpSTr[0]);
        if( TmpSTr[0].contains('#title#') )UserDetail.title                             =     parseContentfromTag('#title#', '#title1#', TmpSTr[0]);
        if( TmpSTr[0].contains('#Phone#') )UserDetail.Phone                             =     parseContentfromTag('#Phone#', '#Phone1#', TmpSTr[0]);
        if( TmpSTr[0].contains('#MobilePhone#') )UserDetail.MobilePhone                 =     parseContentfromTag('#MobilePhone#', '#MobilePhone1#', TmpSTr[0]);
        if( TmpSTr[0].contains('#TwitterName#') )UserDetail.Twitter_Username            =     parseContentfromTag('#TwitterName#', '#TwitterName1#', TmpSTr[0]);
        //Entitlement Fields assignment
        if( TmpSTr[0].contains('#SupportRegion#') )UserDetail.SupportRegion             =     parseContentfromTag('#SupportRegion#', '#SupportRegion1#', TmpSTr[0]);
        if( TmpSTr[0].contains('#NSE#') )UserDetail.NSE                                 =     parseContentfromTag('#NSE#', '#NSE1#', TmpSTr[0]);
        if( TmpSTr[0].contains('#NSM#') )UserDetail.NSM                                 =     parseContentfromTag('#NSM#', '#NSM1#', TmpSTr[0]);
        if( TmpSTr[0].contains('#TAM#') )UserDetail.TAM                                 =     parseContentfromTag('#TAM#', '#TAM1#', TmpSTr[0]);
        //Account Fields assignment
        if( TmpSTr[0].contains('#Type#') )UserDetail.Type                               =     parseContentfromTag('#Type#', '#Type1#', TmpSTr[0]);
        if( TmpSTr[0].contains('#PartnerType#') )UserDetail.PartnerType                 =     parseContentfromTag('#PartnerType#', '#PartnerType1#', TmpSTr[0]);
        if( TmpSTr[0].contains('#CAMowner#') )UserDetail.CAMowner                       =     parseContentfromTag('#CAMowner#', '#CAMowner1#', TmpSTr[0]);
        if( TmpSTr[0].contains('#EngagementMgrOwner#') )UserDetail.EngagementMgrOwner   =     parseContentfromTag('#EngagementMgrOwner#', '#EngagementMgrOwner1#', TmpSTr[0]);
        if( TmpSTr[0].contains('#AccountSpendGrade#') )UserDetail.AccountSpendGrade     =     parseContentfromTag('#AccountSpendGrade#', '#AccountSpendGrade1#', TmpSTr[0]);
        if( TmpSTr[0].contains('#SalesRegion#') )UserDetail.SalesRegion                 =     parseContentfromTag('#SalesRegion#', '#SalesRegion1#', TmpSTr[0]);
        if( TmpSTr[0].contains('#POD#') )UserDetail.POD                                 =     parseContentfromTag('#POD#', '#POD1#', TmpSTr[0]);
        system.debug('---------------->'+UserDetail);
        
        String jiveGetUserInfoUrl = System.Label.jiveGetUserInfoUrl;         
        HttpRequest reqCheckOld = new HttpRequest();
        HttpResponse resCheckOld = new HttpResponse();
        Http httpCheckOld = new Http();
        reqCheckOld.setEndpoint(jiveGetUserInfoUrl + UserDetail.Email);
        String JSONContentOld = '';
        
        if(System.Label.JiveProfileCredentials != '') {
            Blob headerValue = Blob.valueOf(System.Label.JiveProfileCredentials);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            reqCheckOld.setHeader('Authorization', authorizationHeader);
            reqCheckOld.setHeader('content-type', 'application/json');
            reqCheckOld.setHeader('Accept', 'application/json'); 
        } 
        
        reqCheckOld.setMethod('GET');
        Boolean playerExists5 = true;  
        if(Test.isRunningTest() == false) {          
            resCheckOld =  httpCheckOld.send(reqCheckOld);            
            System.debug('resCheckOld.getBod'+resCheckOld.getBody());
            JSONContentOld = resCheckOld.getBody();
        }else {
            JSONContentOld = '{"id":"2092","resources":{"reports":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@reports"},"followingIn":{"allowed":["POST","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/followingIn"},"images":{"allowed":["POST","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/images"},"activity":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/activities"},"manager":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@manager"},"social":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@social"},"streams":{"allowed":["POST","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/streams"},"recognition":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@recognition"},"trendingContent":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@trendingContent"},"trendingPlaces":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@trendingPlaces"},"avatar":{"allowed":["PUT","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/avatar?a=-1"},"followers":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@followers"},"pages":{"allowed":["POST","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/pages"},"colleagues":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@colleagues"},"following":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/@following"},"members":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/members/people/2092"},"self":{"allowed":["DELETE","PUT","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092"},"html":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/people/vishals%40grazitti.com"},"securityGroups":{"allowed":["GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/securityGroups"},"extprops":{"allowed":["POST","DELETE","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/extprops"},"tasks":{"allowed":["POST","GET"],"ref":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/tasks"}},"followerCount":0,"published":"2015-04-07T04:32:35.639+0000","updated":"2015-05-21T08:00:06.795+0000","displayName":"VishalSharma","mentionName":"VishalSharma","emails":[{"jive_label":"Email","primary":true,"type":"work","value":"vishals@grazitti.com","jive_displayOrder":6,"jive_summaryDisplayOrder":1,"jive_showSummaryLabel":true}],"followingCount":0,"directReportCount":0,"jive":{"enabled":true,"external":false,"externalIdentities":[],"federated":false,"lastProfileUpdate":"2015-05-20T10:24:37.554+0000","lastAuthenticated":"2015-05-21T05:31:32.901+0000","level":{"imageURI":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/images/status/statusicon-47.gif","name":"Newbie","points":5},"locale":"en_US","externalContributor":false,"profile":[{"jive_label":"ContactID","value":"0035000001YjI1IAAV","jive_displayOrder":21,"jive_showSummaryLabel":false},{"jive_label":"AccountID","value":"0015000000fD2sOAAS","jive_displayOrder":23,"jive_showSummaryLabel":false},{"jive_label":"Customer","value":"No","jive_displayOrder":27,"jive_showSummaryLabel":false},{"jive_label":"MunchkinID","value":"CF-TEST-123","jive_displayOrder":31,"jive_showSummaryLabel":false}],"sendable":true,"timeZone":"America/Los_Angeles","username":"vishals@grazitti.com","visible":true,"termsAndConditionsRequired":false},"location":"Chandigarh,India","name":{"familyName":"Sharma","formatted":"VishalSharma","givenName":"Vishal"},"phoneNumbers":[{"jive_label":"PhoneNumber","primary":true,"type":"work","value":"+91-7837316810","jive_displayOrder":14,"jive_showSummaryLabel":false}],"thumbnailId":"-1","thumbnailUrl":"https://jivesoftware-marketo5.jivelandia.com/api/core/v3/people/2092/avatar?a=-1","initialLogin":"2015-04-29T09:33:48.315+0000","type":"person"}';
        }           
        System.debug('resCheckOld---------->'+JSONContentOld);
        JSONContentOld = JSONContentOld.remove('throw \'allowIllegalResourceCall is false.\';');
        JSONParser parser1 =    JSON.createParser(JSONContentOld);//emails
        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(JSONContentOld);
        System.debug('Object---------->'+m);
        for(String keyStr : m.keySet()) {
            if(keyStr == 'id'){UserDetail.Jive_ID = ''+m.get(keyStr);}            
                if(keyStr == 'name') {
                Map<String,Object> mapVal = (Map<String, Object>)m.get(keyStr);
                if(UserDetail.First_Name =='' || UserDetail.First_Name ==null){
                    UserDetail.First_Name = ''+mapVal.get('givenName');
                }
                if(UserDetail.Last_Name =='' || UserDetail.Last_Name == null){
                     UserDetail.Last_Name  = ''+mapVal.get('familyName');                
                }
            } 
            if(keyStr == 'phoneNumbers'){
                List<Object> phoneNumbersVals = (List<Object>)m.get(keyStr);
                for(Object PHnObj : phoneNumbersVals) {
                    Map<String,Object> PhnVal = (Map<String, Object>)PHnObj;
                    if(UserDetail.Phone  =='' || UserDetail.Phone  ==null){
                        if(PhnVal.get('jive_label') == 'Phone Number' )UserDetail.Phone  = ''+PhnVal.get('value');
                    }
                    if(UserDetail.MobilePhone =='' || UserDetail.MobilePhone ==null){
                        if(PhnVal.get('jive_label') == 'Mobile Phone')UserDetail.MobilePhone = ''+PhnVal.get('value');  
                    }                                                                          
                } 
            }
            system.debug('tip-----------'+keyStr)  ;
                     
            if(keyStr == 'emails') { 
            List<Object> emailObj = (List<Object>)m.get(keyStr);
                for(Object eObj : emailObj) {
                    Map<String,Object> mapVal = (Map<String, Object>)eObj;
                    if(UserDetail.NewEmail =='' || UserDetail.NewEmail ==null){
                        if(mapVal.get('jive_label') == 'Email')UserDetail.Email = ''+mapVal.get('value'); 
                    }               
                    if(mapVal.get('jive_label') == 'Alternate Email') UserDetail.AltEmail = ''+mapVal.get('value');   
                }
                if(UserDetail.AltEmail == '' && UserDetail.Email !=  '') {UserDetail.AltEmail = UserDetail.Email;}                                   
            }
            if(keyStr == 'jive') { 
                Map<String,Object> mapVal = (Map<String, Object>)m.get(keyStr);
                UserDetail.federated  = ''+mapVal.get('federated');
                UserDetail.userName   = ''+mapVal.get('username');                
                List<Object> extIdentityVals = (List<Object>) mapVal.get('externalIdentities');
                for(Object extIdObj : extIdentityVals) {
                    Map<String,Object> idVal = (Map<String, Object>)extIdObj;
                    if(idVal.get('identityType') == 'SAML'){ UserDetail.External_ID = ''+idVal.get('identity');break; }
                } 
                if (UserDetail.External_ID ==null ||UserDetail.External_ID =='' )  {
                    UserDetail.External_ID = 'temp';
                }                            
                List<Object> profileVals = (List<Object>)mapVal.get('profile');
                for(Object prfObj : profileVals) {
                system.debug('tip1-----------'+prfObj)  ;
                    Map<String,Object> prfVal = (Map<String, Object>)prfObj;
                    if(prfVal.get('jive_label') == 'Account ID' )UserDetail.Account_ID = ''+prfVal.get('value');
                    if(prfVal.get('jive_label') == 'Contact ID')UserDetail.Contact_ID = ''+prfVal.get('value');
                    if(UserDetail.Munchkin_ID=='' || UserDetail.Munchkin_ID==null){
                        if(prfVal.get('jive_label') == 'Munchkin ID')UserDetail.Munchkin_ID = ''+prfVal.get('value');
                    }
                    if(UserDetail.Company=='' || UserDetail.Company ==null){
                        if(prfVal.get('jive_label') == 'Company')UserDetail.Company = ''+prfVal.get('value');  
                    }  
                    if(prfVal.get('jive_label') == 'Assets')UserDetail.Jive_Asset = ''+prfVal.get('value');
                    if(prfVal.get('jive_label') == 'Entitlement')UserDetail.Jive_Entitlement = ''+prfVal.get('value');
                    if(prfVal.get('jive_label') == 'Authorized')UserDetail.Jive_IsAUthCon = ''+prfVal.get('value');
                    if(prfVal.get('jive_label') == 'Support Level')UserDetail.Jive_SupportLevel = ''+prfVal.get('value');
                                                                                             
                }
            }                           
        }
        system.debug('UserDetail---->'+UserDetail);
        if(UserDetail.AltEmail == null || UserDetail.AltEmail.trim() == '' || UserDetail.Email == null || UserDetail.Email.trim() == '' || UserDetail.External_ID == null || UserDetail.External_ID.trim() == '' || UserDetail.Contact_ID == null || UserDetail.Contact_ID.trim() == '' || UserDetail.Company == null || UserDetail.Company.trim() == '' || UserDetail.Account_ID == null || UserDetail.Account_ID.trim() == '' || UserDetail.Munchkin_ID == null || UserDetail.Munchkin_ID.trim() == '' || UserDetail.UserName == null || UserDetail.UserName.trim() == '' || UserDetail.federated == null || UserDetail.federated.trim() == '' || UserDetail.Last_Name == null || UserDetail.Last_Name.trim() == '' || UserDetail.First_Name == null || UserDetail.First_Name.trim() == ''){
           // sendEmail(UserDetail.Email, 'Missing required Fields: JIve profile update failed as some required fields are missing');
            
        }
        
        String jiveSetUserInfoUrl = System.Label.jiveSetUserInfoUrl ;
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
        system.debug('UserDetail------------------->'+UserDetail);
        string tempStr = '';        
        
        if(UserDetail.AltEmail != null && UserDetail.AltEmail != ''){
            tempStr = '{"emails":[{"jive_label":"Alternate Email", "value":"' + UserDetail.AltEmail + '"},';  
        }
        if(UserDetail.NewEmail != null && UserDetail.NewEmail != ''){     
            tempStr += '{"jive_label":"Email","primary":true,"value":"' + UserDetail.NewEmail + '"}],';
        }else{
            tempStr += '{"jive_label":"Email","primary":true,"value":"' + UserDetail.Email + '"}],';
        }
        tempStr +='"phoneNumbers":[{"jive_label":"Phone Number", "value":"' + UserDetail.Phone + '"},'; 
        tempStr +='{"jive_label":"Mobile Phone","primary":true,"value":"' + UserDetail.MobilePhone + '"}],';
    
        if(UserDetail.External_ID != null && UserDetail.External_ID != ''){
            tempStr += '"jive":{"enabled":true,"externalIdentities":[{"identityType":"SAML","identity":"' + UserDetail.External_ID + '"}],';
        }
        if(UserDetail.Contact_ID != null && UserDetail.Contact_ID != ''){
            tempStr += '"profile":[{"jive_label":"Contact ID", "value":"' + UserDetail.Contact_ID + '"},';
        }
        if(UserDetail.Company != null && UserDetail.Company != ''){
            tempStr += '{"jive_label":"Company","value":"' + UserDetail.Company + '"},';
        }
        if(UserDetail.Account_ID != null && UserDetail.Account_ID != ''){
            tempStr += '{"jive_label":"Account ID","value":"' + UserDetail.Account_ID + '"},';
        }
        if(UserDetail.Title != null && UserDetail.Title != ''){
            tempStr += '{"jive_label":"Title","value":"' + UserDetail.Title + '"},';
        }
        if(UserDetail.Twitter_Username != null && UserDetail.Twitter_Username != ''){
            tempStr += '{"jive_label":"Twitter","value":"' + UserDetail.Twitter_Username + '"},';
        }
        if(UserDetail.CAMowner != null && UserDetail.CAMowner != ''){
            tempStr += '{"jive_label":"CAM Owner","value":"' + UserDetail.CAMowner + '"},';
        }
        if(UserDetail.PartnerType != null && UserDetail.PartnerType != ''){
            tempStr += '{"jive_label":"Partner Type","value":"' + UserDetail.PartnerType + '"},';
        }        
        if(UserDetail.EngagementMgrOwner != null && UserDetail.EngagementMgrOwner != ''){
            tempStr += '{"jive_label":"Engagement Mgr Owner","value":"' + UserDetail.EngagementMgrOwner + '"},';
        }
        if(UserDetail.AccountSpendGrade != null && UserDetail.AccountSpendGrade != ''){
            tempStr += '{"jive_label":"Account SpendGrade","value":"' + UserDetail.AccountSpendGrade + '"},';
        }
        if(UserDetail.SalesRegion != null && UserDetail.SalesRegion != ''){
            tempStr += '{"jive_label":"Sales Region","value":"' + UserDetail.SalesRegion + '"},';
        }
        if(UserDetail.SupportRegion != null && UserDetail.SupportRegion != ''){
            tempStr += '{"jive_label":"Support Region","value":"' + UserDetail.SupportRegion + '"},';
        }
        if(UserDetail.NSE != null && UserDetail.NSE != ''){
            tempStr += '{"jive_label":"Named Support Engineer","value":"' + UserDetail.NSE + '"},';
        }
        if(UserDetail.Type != null && UserDetail.Type != ''){
            tempStr += '{"jive_label":"Account Type","value":"' + UserDetail.Type + '"},';
        }
        if(UserDetail.NSM != null && UserDetail.NSM != ''){
            tempStr += '{"jive_label":"Named Support Manager","value":"' + UserDetail.NSM+ '"},';
        }
        if(UserDetail.POD != null && UserDetail.POD != ''){
            tempStr += '{"jive_label":"POD","value":"' + UserDetail.POD+ '"},';
        }
        system.debug('UserDetail.Jive_Asset --> '+UserDetail.Jive_Asset );
        system.debug('ConIdUnderProcessing.id----' + ConIdUnderProcessing.id);
        system.debug('UserDetail----' + UserDetail);
        
        system.debug('ConAssetId.get(ConIdUnderProcessing.id) --> '+ConAssetId.get(ConIdUnderProcessing.id) );
            System.debug('Awesome--->');
            tempStr += '{"jive_label":"Assets","value":"' + ConAssetId.get(ConIdUnderProcessing.id)+ '"},';
        
        system.debug('UserDetail.Jive_Entitlement--> '+UserDetail.Jive_Entitlement );
        system.debug('ConEntitlementId.get(ConIdUnderProcessing.id)--> '+ConEntitlementId.get(ConIdUnderProcessing.id) );
            tempStr += '{"jive_label":"Entitlement","value":"' + ConEntitlementId.get(ConIdUnderProcessing.id)+ '"},';
        
        system.debug('UserDetail.Jive_IsAUthCon--> '+UserDetail.Jive_IsAUthCon);
        system.debug('IsAuthConMap.get(ConIdUnderProcessing.id)--> '+IsAuthConMap.get(ConIdUnderProcessing.id)); 
            tempStr += '{"jive_label":"Authorized","value":"' + IsAuthConMap.get(ConIdUnderProcessing.id)+ '"},';
        
        system.debug('UserDetail.Jive_SupportLevel--> '+UserDetail.Jive_SupportLevel);
        system.debug('ConSupportLevelMap.get(ConIdUnderProcessing.id)--> '+ConSupportLevelMap.get(ConIdUnderProcessing.id)); 
        if(ConSupportLevelMap.get(ConIdUnderProcessing.id) !=  UserDetail.Jive_SupportLevel) {
            tempStr += '{"jive_label":"Support Level","value":"' + ConSupportLevelMap.get(ConIdUnderProcessing.id)+ '"},';
        }  
             
        if(UserDetail.TAM != null && UserDetail.TAM != ''){
            tempStr += '{"jive_label":"Technical Account Manager","value":"' + UserDetail.TAM + '"},';
        }
        if(UserDetail.Munchkin_ID != null && UserDetail.Munchkin_ID != ''){
            tempStr += '{"jive_label":"Munchkin ID","value":"' + UserDetail.Munchkin_ID + '"}],';
        }
        if(UserDetail.UserName != null && UserDetail.UserName != '') {
            tempStr += '"username":"' + UserDetail.UserName + '",';
        }
        if(UserDetail.federated != null && UserDetail.federated != '') {
            tempStr += '"federated":"' + UserDetail.federated + '"},'; 
        }     
        if(UserDetail.Last_Name != null && UserDetail.Last_Name != ''){
            tempStr += '"name":{"familyName":"' + UserDetail.Last_Name + '",';
        }  
        if(UserDetail.First_Name != null && UserDetail.First_Name != ''){
            tempStr += '"givenName":"' + UserDetail.First_Name + '"}}';
        }

        system.debug('string----------------->'+tempStr);
        system.debug('UserDetail.Jive_ID----------------->'+UserDetail.Jive_ID);
        reqOld.setEndpoint(jiveSetUserInfoUrl + UserDetail.Jive_ID);        
        reqOld.setMethod('PUT');
        if(Test.isRunningTest() == false) {
            reqOld.setBody(tempStr);              
            resOld =  httpOld.send(reqOld);
            
        }           
        System.debug('resOld.getBod'+resOld.getBody());             
        
    }
    
     public static void sendEcxeptionMailToDeveloper(string e){
       system.debug('line number==>'+e);
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {'ServiceCloudTeam@grazitti.com'};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Support Case Optimized trigger Exception');
       mail.setPlainTextBody(e);
       try{Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });}catch(exception ex){}    
    }
}