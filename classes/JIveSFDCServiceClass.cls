@RestResource(urlMapping='/JIveSFDCServiceClass')
global class JIveSFDCServiceClass {

@HttpPost
    global static String parseWebhhokData() {
        try{
        if(system.label.JiveSyncEnable =='True' || test.isrunningtest() == True){
            system.debug('ser-Agent====>'+RestContext.request.headers.get('User-Agent'));
            system.debug('request header ====>'+RestContext.request.headers);
            string jiveAgent = RestContext.request.headers.get('User-Agent');
            if(test.isrunningtest() == false && !jiveAgent.contains(system.label.UserAgentid) )  return 'Not Authorized';

            map<integer,object> JiveUpdatedRecordUrlObjMap = new map<integer,object>();
            List<object> JiveUpdatedRecordUrlObj = new List<object>();
            JiveURLAndOperation JiveInfo = new JiveURLAndOperation();
            String dataFromJive = '';
            system.debug('test string====>'+RestContext.response);
            
            List<Jive_User__c> inertJiveUserList = new List<Jive_User__c>();
            list<contact> contactdetailsToUpdate = new list<contact>();
            list<Jive_User__c> jiveUserDetailsToUpdate = new list<Jive_User__c>();
            
            if(!test.isRunningtest()){
                dataFromJive = RestContext.request.requestBody.tostring();
            }else{
                dataFromJive = '[{"webhook": "https://marketo-ext.jiveon.com/api/core/v3/webhooks/1041","activity": {"verb": "jive:user_profile_modified","object": {"id": "https://marketo-ext.jiveon.com/api/core/v3/people/55675"},"timestamp": "2015-12-09T09:48:25.396+0000","jive": {"objectID": 55675, "objectType": 3}}}]';
            }
            system.debug('dataFromJive--->'+dataFromJive);

            List<Object> JIveDataDes = (List<Object>)JSON.deserializeUntyped(dataFromJive);
            if(JIveDataDes !=null && JIveDataDes.isEmpty()==false){
                integer icheck=0;
                for(Object temp : JIveDataDes){    
                    icheck++;
                    system.debug('icheck is: '+String.valueOf(icheck));
                    Map <String,Object> PersonID = (Map <String,Object>) temp;
                    if (PersonID != null && PersonID.keyset().isEmpty() == false) {
                        for (string keyStr2 : PersonID.keyset()){
                            if (keyStr2 == 'activity') {
                                Map < String, Object > PersonID2 = (Map < String, Object >)
                                PersonID.get(keyStr2);
                                if (PersonID2 != null && PersonID2.keyset().isEmpty() == false) {
                                    for (string keyStr3 : PersonID2.keyset()){
                                        if (keyStr3 == 'verb') {
                                            system.debug('jive operation===>' + PersonID2.get(keyStr3));
                                            string
                                            OPR = (string)
                                            PersonID2.get(keyStr3);
                                            if (OPR == 'jive:user_account_disabled' || OPR == 'jive:user_account_deleted') {
                                                JiveInfo.Activated = True;
                                            } else {
                                                JiveInfo.Activated = False;
                                            }
                                        }
                                        if (keyStr3 == 'jive') {
                                            Map < String, Object > objectIDMap = (Map < String, Object >)
                                            PersonID2.get(keyStr3);
                                            system.debug('objectIDMap=====>' + objectIDMap);
                                            if (objectIDMap != null && objectIDMap.keyset().contains('objectID')) { //check for null
                                                JiveInfo.JiveID = integer.valueof(objectIDMap.get('objectID'));
                                                JiveInfo.Url = System.Label.MarketoDomainURL + JiveInfo.JiveID;
                                                system.debug('JiveInfo.JiveID=====>' + JiveInfo.JiveID);
                                            }
                                        }
                                    }
                                    system.debug('jive object==>' + JiveInfo);
                                    if(JiveInfo.JiveID != null && !JiveUpdatedRecordUrlObjMap.containsKey(JiveInfo.JiveID)){                                    
                                        JiveUpdatedRecordUrlObjMap.put(JiveInfo.JiveID, JiveInfo);
                                    }
                                }
                            }
                        }
                    }
                }

            }
            if(JiveUpdatedRecordUrlObjMap!=null && JiveUpdatedRecordUrlObjMap.values().isEmpty()==false){
                JiveUpdatedRecordUrlObj = JiveUpdatedRecordUrlObjMap.values();
            }
            system.debug('JiveUpdatedRecordUrlObj-->'+JiveUpdatedRecordUrlObj );
            system.debug('JiveUpdatedRecordUrlObj  SIzeeeeeeee-->'+JiveUpdatedRecordUrlObj.size());
            set<integer> jiveIdsList = new set<integer>();
            for(object JivePersonInfoUrl : JiveUpdatedRecordUrlObjMap.values()) {
                //try{                    
                    JIveSFDCServiceClass.JiveURLAndOperation JiveOps = (JIveSFDCServiceClass.JiveURLAndOperation) JivePersonInfoUrl;
                    boolean Activated = JiveOps.Activated;
                    integer JIveID =  JiveOps.JiveID;
                    if(jiveIdsList.contains(JIveID)){
                        continue;
                    }else{
                        jiveIdsList.add(JIveID);
                    }
                    system.debug('Activated===>'+Activated +'---'+JIveID);
                    if(!Activated) {
                        jiveUser UserDetail = new jiveUser();
                        HttpRequest reqCheckOld = new HttpRequest();
                        HttpResponse resCheckOld = new HttpResponse();
                        Http httpCheckOld = new Http();
                        String JiveUrl = JiveOps.Url;
                        system.debug('JiveUrl-->'+JiveUrl);
                        reqCheckOld.setEndpoint(JiveUrl);
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
                            resCheckOld =  httpCheckOld.send(reqCheckOld); //// error line
                            JSONContentOld = resCheckOld.getBody();
                        }else {
                            JSONContentOld = '{"id":"91254","resources":{"reports":{"allowed":["GET"],"ref":"https://marketo-ext.jiveon.com/api/core/v3/people/5567505/@reports"},"followingIn":{"allowed":["POST","GET"],"ref":"https://marketo-ext.jiveon.com/api/core/v3/people/556750/followingIn"},"images":{"allowed":["POST","GET"],"ref":"https://marketo-ext.jiveon.com/api/core/v3/people/556750/images"},"activity":{"allowed":["GET"],"ref":"https://marketo-ext.jiveon.com/api/core/v3/people/556750/activities"},"manager":{"allowed":["GET"],"ref":"https://marketo-ext.jiveon.com/api/core/v3/people/556750/@manager"},"social":{"allowed":["GET"],"ref":"https://marketo-ext.jiveon.com/api/core/v3/people/556750/@social"},"roles":{"allowed":["GET"],"ref":"https://marketo-ext.jiveon.com/api/core/v3/people/556750/roles"},"streams":{"allowed":["POST","GET"],"ref":"https://marketo-ext.jiveon.com/api/core/v3/people/556750/streams"},"recognition":{"allowed":["GET"],"ref":"https://marketo-ext.jiveon.com/api/core/v3/people/556750/@recognition"},"trendingContent":{"allowed":["GET"],"ref":"https://marketo-ext.jiveon.com/api/core/v3/people/556750/@trendingContent"},"profilePrivacy":{"allowed":["GET"],"ref":"https://marketo-ext.jiveon.com/api/core/v3/people/556750/profilePrivacy"},"trendingPlaces":{"allowed":["GET"],"ref":"https://marketo-ext.jiveon.com/api/core/v3/people/556750/@trendingPlaces"},"avatar":{"allowed":["PUT","GET"],"ref":"https://marketo-ext.jiveon.com/api/core/v3/people/556750/avatar?a=1030"},"followers":{"allowed":["GET"],"ref":"https://marketo-ext.jiveon.com/api/core/v3/people/556750/@followers"},"pages":{"allowed":["POST","GET"],"ref":"https://marketo-ext.jiveon.com/api/core/v3/people/556750/pages"},"colleagues":{"allowed":["GET"],"ref":"https://marketo-ext.jiveon.com/api/core/v3/people/556750/@colleagues"},"following":{"allowed":["GET"],"ref":"https://marketo-ext.jiveon.com/api/core/v3/people/556750/@following"},"members":{"allowed":["GET"],"ref":"https://marketo-ext.jiveon.com/api/core/v3/members/people/556750"},"self":{"allowed":["PUT","GET","DELETE"],"ref":"https://marketo-ext.jiveon.com/api/core/v3/people/556750"},"html":{"allowed":["GET"],"ref":"https://marketo-ext.jiveon.com/people/bikram"},"securityGroups":{"allowed":["GET"],"ref":"https://marketo-ext.jiveon.com/api/core/v3/people/556750/securityGroups"},"extprops":{"allowed":["POST","GET","DELETE"],"ref":"https://marketo-ext.jiveon.com/api/core/v3/people/556750/extprops"}},"followerCount":0,"followed":false,"published":"2015-08-18T14:31:56.657+0000","updated":"2015-12-09T09:49:11.377+0000","displayName":"Test Test 2","mentionName":"Test Test 2","emails":[{"jive_label":"Alternate Email","value":"rizvanm@grazitti.com","jive_displayOrder":16,"jive_summaryDisplayOrder":-1,"jive_showSummaryLabel":true},{"jive_label":"Email","primary":true,"type":"work","value":"rizvanm@grazitti.com","jive_displayOrder":7,"jive_summaryDisplayOrder":1,"jive_showSummaryLabel":true}],"followingCount":0,"directReportCount":0,"jive":{"enabled":true,"external":false,"externalIdentities":[{"identityType":"SAML","identity":"temp"}],"federated":false,"lastProfileUpdate":"2015-12-09T09:49:11.370+0000","lastAuthenticated":"2015-12-07T09:42:02.849+0000","level":{"description":"Level 0","imageURI":"","name":"Level 0","points":0},"locale":"en_US","externalContributor":false,"profile":[{"jive_label":"Title","value":"QA556","jive_displayOrder":0,"jive_showSummaryLabel":false},{"jive_label":"Company","value":"CF Test","jive_displayOrder":1,"jive_showSummaryLabel":false},{"jive_label":"Certification","values":["Marketo Certified Analytics","Marketo Certified Consultant","Marketo Certified Expert"],"jive_displayOrder":2,"jive_showSummaryLabel":false},{"jive_label":"Expertise","values":["Test 2","Marketo Sales Insight"],"jive_displayOrder":3,"jive_summaryDisplayOrder":0,"jive_showSummaryLabel":false},{"jive_label":"Certification Level","values":["Marketo Certified Expert"],"jive_displayOrder":5,"jive_showSummaryLabel":false},{"jive_label":"Accomplishments","values":["Evangelist (name TBD)"],"jive_displayOrder":5,"jive_showSummaryLabel":false},{"jive_label":"Twitter","value":"Test6_Twitter5","jive_displayOrder":11,"jive_summaryDisplayOrder":0,"jive_showSummaryLabel":false},{"jive_label":"Who I market to","values":["Consumers","Businesses"],"jive_displayOrder":13,"jive_showSummaryLabel":false},{"jive_label":"Street","value":"Phase 22","jive_displayOrder":17,"jive_summaryDisplayOrder":0,"jive_showSummaryLabel":false},{"jive_label":"State (SKW)","value":"Panchkulaaa","jive_displayOrder":18,"jive_showSummaryLabel":false},{"jive_label":"City","value":"Haryanaaaa","jive_displayOrder":19,"jive_showSummaryLabel":false},{"jive_label":"Zip Code/ Postal Code","value":"112233000","jive_displayOrder":20,"jive_showSummaryLabel":false},{"jive_label":"State/ Province","value":"Haryanaaa, chandigarhhh","jive_displayOrder":21,"jive_showSummaryLabel":false},{"jive_label":"Contact ID","value":"0035000001StN3T","jive_displayOrder":23,"jive_showSummaryLabel":false},{"jive_label":"Account Name","value":"CF-Test","jive_displayOrder":24,"jive_summaryDisplayOrder":0,"jive_showSummaryLabel":false},{"jive_label":"Account ID","value":"0015000000fD2sOAAS","jive_displayOrder":26,"jive_showSummaryLabel":false},{"jive_label":"Join Date","value":"08/18/2015","jive_displayOrder":27,"jive_showSummaryLabel":false},{"jive_label":"Customer","value":"No","jive_displayOrder":29,"jive_showSummaryLabel":false},{"jive_label":"Employee","value":"No","jive_displayOrder":30,"jive_summaryDisplayOrder":0,"jive_showSummaryLabel":false},{"jive_label":"Partner","value":"No","jive_displayOrder":31,"jive_showSummaryLabel":false},{"jive_label":"Munchkin ID","value":"666","jive_displayOrder":32,"jive_showSummaryLabel":false},{"jive_label":"Language","value":"English","jive_displayOrder":34,"jive_showSummaryLabel":false},{"jive_label":"Authorized","value":"Yes","jive_displayOrder":36,"jive_summaryDisplayOrder":0,"jive_showSummaryLabel":false},{"jive_label":"Certificaton","value":"Preferred Services-Agency","jive_displayOrder":37,"jive_showSummaryLabel":false},{"jive_label":"CAM Owner","value":"00550000001y4AfAAI","jive_displayOrder":38,"jive_summaryDisplayOrder":0,"jive_showSummaryLabel":false},{"jive_label":"Engagement Mgr Owner","value":"00550000001y4AfAAI","jive_displayOrder":39,"jive_showSummaryLabel":false},{"jive_label":"Account SpendGrade","value":"D","jive_displayOrder":40,"jive_summaryDisplayOrder":0,"jive_showSummaryLabel":false},{"jive_label":"Sales Region","value":"Other","jive_displayOrder":41,"jive_summaryDisplayOrder":0,"jive_showSummaryLabel":false},{"jive_label":"Assets","value":"02i50000004wLgMAAU","jive_displayOrder":42,"jive_showSummaryLabel":false},{"jive_label":"Support Region","value":"Latin America","jive_displayOrder":43,"jive_summaryDisplayOrder":0,"jive_showSummaryLabel":false},{"jive_label":"Named Support Engineer","value":"00550000002QQWuAAO","jive_displayOrder":45,"jive_summaryDisplayOrder":0,"jive_showSummaryLabel":false},{"jive_label":"Named Support Manager","value":"00550000002QQWuAAO","jive_displayOrder":46,"jive_summaryDisplayOrder":0,"jive_showSummaryLabel":false},{"jive_label":"Technical Account Manager","value":"00550000002QQWuAAO","jive_displayOrder":47,"jive_summaryDisplayOrder":0,"jive_showSummaryLabel":false},{"jive_label":"Account Type","value":"Customer & Partner","jive_displayOrder":48,"jive_summaryDisplayOrder":0,"jive_showSummaryLabel":false},{"jive_label":"POD","value":"BikramPOD","jive_displayOrder":50,"jive_showSummaryLabel":false},{"jive_label":"Entitlement","value":"55050000000GoEbAAK","jive_displayOrder":51,"jive_showSummaryLabel":false},{"jive_label":"Support Level","value":"Premier ","jive_displayOrder":53,"jive_showSummaryLabel":false}],"sendable":true,"timeZone":"America/Los_Angeles","username":"bikram","visible":true,"status":"registered"},"location":"Punjab","name":{"familyName":"Test 2","formatted":"Test Test 2","givenName":"Test"},"phoneNumbers":[{"jive_label":"Phone Number","primary":true,"type":"work","value":"1111111111","jive_displayOrder":14,"jive_showSummaryLabel":false},{"jive_label":"Mobile Phone","value":"55555555","jive_displayOrder":15,"jive_summaryDisplayOrder":0,"jive_showSummaryLabel":false}],"thumbnailId":"1030","thumbnailUrl":"https://marketo-ext.jiveon.com/api/core/v3/people/556750/avatar?a=1030","initialLogin":"2015-08-18T14:35:27.697+0000","type":"person","typeCode":3}';
                        }
                        System.debug('resCheckOld---------->'+JSONContentOld);
                        JSONContentOld = JSONContentOld.replace('throw \'allowIllegalResourceCall is false.\';','');
                        JSONParser parser1 =    JSON.createParser(JSONContentOld);
                        Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped(JSONContentOld);
                        for(String keyStr : m.keySet()) {
                            if(keyStr == 'jive') {
                                Map<String,Object> mapVal = (Map<String, Object>)m.get(keyStr);
                                system.debug('Active=====>'+mapVal.get('enabled'));
                                if(mapVal.get('enabled')!=true) return null;
                                system.debug('Activeeeeeeeeeeeeeeee=====>'+mapVal.get('enabled'));
                                Map<String,Object> mapVal2 = (Map<String, Object>)m.get(keyStr);
                                object levelVals = (object)mapVal2.get('level');
                                map<string, object> pointsMap = (Map<String, Object>)levelVals;
                                if(pointsMap != null && pointsMap.get('points')!=null) UserDetail.jive_points= ''+pointsMap.get('points');
                                List<Object> profileVals = (List<Object>)mapVal2.get('profile');
                                for(Object prfObj : profileVals) {
                                    Map<String,Object> prfVal = (Map<String, Object>)prfObj;
                                    if(prfVal.get('jive_label') == 'Title')UserDetail.Title = ''+prfVal.get('value');
                                    if(prfVal.get('jive_label') == 'Munchkin ID')UserDetail.Munchkin_ID = ''+prfVal.get('value');
                                    if(prfVal.get('jive_label') == 'Twitter')UserDetail.Twitter_Username = ''+prfVal.get('value');
                                    if(prfVal.get('jive_label') == 'Street')UserDetail.Jive_Street = ''+prfVal.get('value');
                                    if(prfVal.get('jive_label') == 'POD')UserDetail.Pod = ''+prfVal.get('value');
                                    //if(prfVal.get('jive_label') == 'Contact ID')UserDetail.Contact_Id = ''+prfVal.get('value');

                                    if(prfVal.get('jive_label') == 'City')UserDetail.jive_city = ''+prfVal.get('value');
                                    if(prfVal.get('jive_label') == 'State/ Province')UserDetail.jive_state = ''+prfVal.get('value');
                                    if(prfVal.get('jive_label') == 'Country')UserDetail.jive_country = ''+prfVal.get('value');
                                    if(prfVal.get('jive_label') == 'Zip Code/ Postal Code')UserDetail.jive_zip = ''+prfVal.get('value');

                                    if(prfVal.get('jive_label') == 'Expertise')  {
                                        List<Object> myobj = (List<Object>)  prfVal.get('values');
                                        for(Object obj : myobj){
                                            UserDetail.jive_Expertise+= (string)obj + ';';
                                        }
                                    }
                                    if(prfVal.get('jive_label') == 'Accomplishments')  {
                                        List<Object> myobj = (List<Object>)  prfVal.get('values');
                                        for(Object obj : myobj){
                                            UserDetail.jive_Accomplishments += (string) obj + ';';
                                        }
                                    }
                                    if(prfVal.get('jive_label') == 'Certification Level')  {
                                        List<Object> myobj = (List<Object>)  prfVal.get('values');
                                        for(Object obj : myobj){
                                            UserDetail.jive_Certification += (string) obj + ';';
                                        }
                                    }
                                }
                            }

                            if(keyStr == 'id'){UserDetail.Jive_ID = ''+m.get(keyStr);}
                            if(keyStr == 'location'){UserDetail.jive_location = ''+m.get(keyStr);}
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
                            if(keyStr == 'emails') {
                                List<Object> emailObj = (List<Object>)m.get(keyStr);
                                for(Object eObj : emailObj) {
                                    Map<String,Object> mapVal1 = (Map<String, Object>)eObj;
                                    if(UserDetail.NewEmail == '' || UserDetail.NewEmail == null){
                                        if(mapVal1.get('jive_label') == 'Email' && mapVal1.get('primary') == true)
                                            UserDetail.Email = ''+mapVal1.get('value');
                                    }
                                }
                            }

                        }

                        if(UserDetail.Email ==null || UserDetail.Email=='') return null;
                        boolean isUpdateCon =false;
                        list<contact> contactdetails = new list<contact>([select name, mailingCity, mailingState, mailingCountry, jive_city__c,Jive_Street__c, jive_Accomplishments__c, jive_Expertise__c, jive_Certification__c, jive_state__c, jive_country__c, Jive_ZipCode__c, jive_location__c, jive_points__c, jive_id__c, FirstName, lastName, Title, MobilePhone, Phone, Munchkin_ID__c, Marketo_POD__c, Email  from contact where email = :UserDetail.Email limit 1]);
                        if(contactdetails.isEmpty()) return null;
                        system.debug('contactdetails======>'+contactdetails);
                        if(contactdetails.isEmpty() == FALSE) {
                            UserDetail.Contact_Id = contactdetails[0].Id;
                            if(contactdetails[0].FirstName != UserDetail.First_Name) {
                                contactdetails[0].FirstName = UserDetail.First_Name;
                                isUpdateCon =true;
                            }
                            if(contactdetails[0].lastName != UserDetail.Last_Name) {
                                contactdetails[0].lastName  = UserDetail.Last_Name ;
                                isUpdateCon =true;
                            }
                            if(contactdetails[0].Email != UserDetail.Email) {
                                contactdetails[0].Email = UserDetail.Email;
                                isUpdateCon =true;
                            }
                            system.debug('contact title ==>'+contactdetails[0].Title);
                            system.debug('jive title ==>'+UserDetail.Title);
                            if( contactdetails[0].Title != UserDetail.Title && UserDetail.Title!=null && UserDetail.Title!='') {
                                contactdetails[0].Title = UserDetail.Title;
                                isUpdateCon =true;
                            }
                            if(contactdetails[0].MobilePhone != UserDetail.MobilePhone) {
                                contactdetails[0].MobilePhone   = UserDetail.MobilePhone;
                                isUpdateCon = true;
                            }
                            if(contactdetails[0].Munchkin_ID__c != UserDetail.Munchkin_ID) {
                                contactdetails[0].Munchkin_ID__c = UserDetail.Munchkin_ID;
                                isUpdateCon =true;
                            }
                            if(contactdetails[0].Phone != UserDetail.Phone) {
                                contactdetails[0].Phone = UserDetail.Phone;
                                isUpdateCon =true;
                            }
                            if(contactdetails[0].Marketo_POD__c != UserDetail.POD) {
                                contactdetails[0].Marketo_POD__c = UserDetail.POD;
                                isUpdateCon =true;
                            }
                        }

                        boolean isUpdateJIveUser =false;
                        integer TempjiveId = Integer.valueof(UserDetail.Jive_ID);
                        list<Jive_User__c> jiveUserDetails = new list<Jive_User__c>([select id, Contact__c,Disabled__c, Contact__r.mailingCity, Contact__r.mailingState, Contact__r.mailingCountry, Jive_Email__c, jive_city__c,  jive_Accomplishments__c, jive_Expertise__c,  jive_state__c, jive_country__c, jive_points__c, jive_id__c from Jive_User__c where jive_id__c = :TempjiveId limit 1]);
                        system.debug('jiveUserDetails--------------->'+jiveUserDetails);
                        if(jiveUserDetails.isEmpty() == FALSE) {
                            if(jiveUserDetails[0].jive_city__c != UserDetail.jive_city) {
                                jiveUserDetails[0].jive_city__c = UserDetail.jive_city;
                                isUpdateJIveUser =true;
                            }
                            if(jiveUserDetails[0].jive_state__c != UserDetail.jive_state) {
                                jiveUserDetails[0].jive_state__c = UserDetail.jive_state;
                                isUpdateJIveUser =true;
                            }
                            if(jiveUserDetails[0].jive_country__c!= UserDetail.jive_country) {
                                jiveUserDetails[0].jive_country__c= UserDetail.jive_country;
                                isUpdateJIveUser =true;
                            }
                            system.debug('UserDetail.jive_city--------------->'+ UserDetail.jive_city);
                            system.debug('UserDetail.jive_state--------------->'+ UserDetail.jive_state);
                            system.debug('UserDetail.jive_country--------------->'+ UserDetail.jive_country);
                            if((UserDetail.jive_city =='' || UserDetail.jive_city ==null) && (UserDetail.jive_state =='' || UserDetail.jive_state ==null) && (UserDetail.jive_country =='' || UserDetail.jive_country ==null)){
                                system.debug('contactdetails city--------------->'+ contactdetails[0].mailingCity);
                                jiveUserDetails[0].jive_city__c    = contactdetails[0].mailingCity;
                                jiveUserDetails[0].jive_state__c   = contactdetails[0].mailingState;
                                jiveUserDetails[0].jive_country__c = contactdetails[0].mailingCountry;
                                isUpdateJIveUser =true;
                            }
                            if(jiveUserDetails[0].jive_points__c!= integer.valueof(UserDetail.jive_points)) {
                                jiveUserDetails[0].jive_points__c= integer.valueof(UserDetail.jive_points);
                                isUpdateJIveUser =true;
                            }
                            if(jiveUserDetails[0].jive_id__c!= integer.valueof(UserDetail.Jive_ID) && test.isrunningtest()==False) {
                                jiveUserDetails[0].jive_id__c= integer.valueof(UserDetail.Jive_ID);
                                isUpdateJIveUser =true;
                            }
                            if(jiveUserDetails[0].Jive_Email__c!= UserDetail.Email) {
                                jiveUserDetails[0].Jive_Email__c= UserDetail.Email;
                                isUpdateJIveUser =true;
                            }
                            if(jiveUserDetails[0].jive_Expertise__c != UserDetail.jive_Expertise) {
                                jiveUserDetails[0].jive_Expertise__c = UserDetail.jive_Expertise;
                                isUpdateJIveUser =true;
                            }
                            if(jiveUserDetails[0].jive_Accomplishments__c != UserDetail.jive_Accomplishments) {
                                jiveUserDetails[0].jive_Accomplishments__c = UserDetail.jive_Accomplishments;
                                isUpdateJIveUser =true;
                            }
                            if(jiveUserDetails[0].jive_Certification__c != UserDetail.jive_Certification) {
                                jiveUserDetails[0].jive_Certification__c = UserDetail.jive_Certification;
                                isUpdateJIveUser =true;
                            }
                            if(jiveUserDetails[0].Contact__c != UserDetail.Contact_Id) {
                                jiveUserDetails[0].Contact__c = UserDetail.Contact_Id;
                                isUpdateJIveUser =true;
                            }
                            system.debug('Activated========>'+Activated);
                            if(jiveUserDetails[0].Disabled__c != Activated) {
                                jiveUserDetails[0].Disabled__c = Activated;
                                isUpdateJIveUser = true;
                            }
                        }
                        if(jiveUserDetails.isEmpty() == TRUE || test.IsRunningTest() ){
                            string city    =  UserDetail.jive_city;
                            string state   =  UserDetail.jive_state;
                            string country =  UserDetail.jive_country;
                            if((city =='' || city ==null) && (state =='' || state ==null) && (country =='' || country ==null)){
                                city    = contactdetails[0].mailingCity;
                                state   = contactdetails[0].mailingState;
                                country  = contactdetails[0].mailingCountry;

                            }
                            Jive_User__c InertJiveUser = new Jive_User__c(
                                Disabled__c = Activated,
                                Contact__c = UserDetail.Contact_Id,
                                jive_city__c = city,
                                jive_Accomplishments__c = UserDetail.jive_Accomplishments,
                                jive_Certification__c = UserDetail.jive_Certification,
                                jive_Expertise__c = UserDetail.jive_Expertise,
                                Jive_Email__c= UserDetail.Email,
                                jive_id__c= integer.valueof(UserDetail.Jive_ID),
                                jive_points__c= (UserDetail.jive_points=='' || UserDetail.jive_points==null)? 0: integer.valueof(UserDetail.jive_points),
                                jive_state__c   = state,
                                jive_country__c = country
                            );
                            //try{
                                if (InertJiveUser.geolocation__Latitude__s == null && (InertJiveUser.jive_city__c!= null || InertJiveUser.jive_state__c!= null)) {
                                    InertJiveUser = GeoLocationCallouts.getLocation(InertJiveUser);
                                }
                            /*}catch(exception e){
                                system.debug('error in Geolocation Callout: '+ e);
                                sendEcxeptionMailToDeveloper(e,JSONContentOld);
                            }*/
                            if(!inertJiveUserList.contains(InertJiveUser)) inertJiveUserList.add(InertJiveUser); ///// update-----1
                        }

                        if(isUpdateJIveUser){
                            system.debug('jiveUserDetails--->'+jiveUserDetails);
                            //try{
                                if (jiveUserDetails[0].geolocation__Latitude__s == null && (jiveUserDetails[0].jive_city__c!= null || jiveUserDetails[0].jive_state__c!= null)) {
                                    Jive_User__c temp = GeoLocationCallouts.getLocation(jiveUserDetails[0]);
                                    jiveUserDetails = new list<Jive_User__c>();
                                    jiveUserDetails.add(temp);
                                }
                            /*}catch(exception e) {

                            }*/
                            if(!inertJiveUserList.contains(jiveUserDetails[0])) inertJiveUserList.add(jiveUserDetails[0]); ///// update----- 2
                        }

                        if(isUpdateCon) {
                            system.debug('contactdetails--->'+contactdetails);
                            //try{
                                if(!contactdetailsToUpdate.contains(contactdetails[0])) contactdetailsToUpdate.add(contactdetails[0]); ///// update----- 3
                            /*}catch(exception e){
                                sendEcxeptionMailToDeveloper(e,JSONContentOld);
                            }*/
                        }
                    }else {
                        for(Jive_User__c temp : [select id, Disabled__c, jive_id__c from Jive_User__c where jive_id__c =:JIveID  limit 1]){
                            temp.Disabled__c =true;
                            if(!inertJiveUserList.contains(temp)) inertJiveUserList.add(temp);
                        }

                    }

                /*}catch(exception e){
                    system.debug('Exception====>>>>'+e);
                    sendEcxeptionMailToDeveloper(e,'NOT FOUND-----');
                }*/
            }
            if(!inertJiveUserList.IsEmpty()){
                //try{
                    upsert inertJiveUserList jive_id__c;
                /*}catch(exception e){
                    system.debug('Exception====>>>>'+e);
                    sendEcxeptionMailToDeveloper(e,'----inertJiveUserList-----');
                }*/
            }
            if(!contactdetailsToUpdate.IsEmpty()){
                //try{
                    update contactdetailsToUpdate;
                /*}catch(exception e){
                    system.debug('Exception====>>>>'+e);
                    sendEcxeptionMailToDeveloper(e,'----contactdetailsToUpdate-----');
                }*/
            }
            

        }
        }catch(exception e){
            system.debug('Exception====>>>>'+e);
            sendEcxeptionMailToDeveloper(e,'----contactdetailsToUpdate-----');
        }
        return 'I can see the response';
    }

    global class JiveURLAndOperation {
    global string Url;
    global integer JiveID;
    global boolean Activated;
}

    public static void sendEcxeptionMailToDeveloper(Exception e, string details){
       system.debug('line number==>'+e.getMessage());
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {'rizvanm@grazitti.com'};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Support Case Optimized trigger Exception');
       mail.setPlainTextBody(details +'\n'+e+'\n'+e.getStackTraceString());
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });   
    }

}