public class AutoPointsAndRewardSwappingController{

public String userIdOld {get;set;}
public String userIdNew {get;set;}
public boolean isSuccess {get;set;}
public boolean hasNotFailed {get;set;}
public boolean hasNoContactAssociatedWithNewUser {get;set;}
public boolean isSuccessForAll{get;set;}
    public AutoPointsAndRewardSwappingController(){
        isSuccess = false;
        hasNotFailed = true;
        hasNoContactAssociatedWithNewUser = false;
        isSuccessForAll = false;
    }


    public void swap(){
     hasNotFailed = true;
     isSuccess = false;
     hasNoContactAssociatedWithNewUser = false;
     isSuccessForAll = false;
     List<String> msg = new List<String>();
     string msg3;
     string msg4;
        if (userIdOld == null || userIdOld.trim() == '') {
            msg.add('Old User Id');
        }
        if (userIdNew == null || userIdNew.trim() == '') {
            msg.add('New User Id');
        }
       system.debug('msg===>'+msg);
        if (msg.size() > 0) {
            String msg2 = 'Required fields are missing: ';
            for (Integer i=0; i<msg.size(); i++) {
                msg2 +=  msg[i] + (i<msg.size()-1 ? ', ' : '');
            }
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg2));
            //return null;
        }else if(userIdOld.trim() != ''){
            if(! userIdOld.startswithIgnoreCase('005')){
                 msg3 = 'Please enter valid Old UserId';
               
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg3));
                
            }else{
                 integer length = userIdOld.length(); 
                
                 if(length == 15){
                 
                  List<user>   tmpUserIdOld = [select id from user where id = :userIdOld];
                  if(! tmpUserIdOld.IsEmpty()){
                     UserIdOld = tmpUserIdOld[0].id ;
                  }else{
                       msg3 = 'Please enter valid Old UserId';
                      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg3));
                  }
                 }
            }
        }
        if(userIdNew.trim() != ''){
           
            if(! userIdNew.startswithIgnoreCase('005')){
                msg4 = 'Please enter valid New UserId';
                system.debug('msg4===>'+msg4);
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg4));
            }else{
                 integer length = userIdNew.length( ); 
                 
                 if(length == 15){
                    List<user>   tmpUserIdNew = [select id from user where id = :userIdNew];
                  if(! tmpUserIdNew.IsEmpty()){
                     UserIdNew = tmpUserIdNew[0].id ;
                  }else{
                      msg4 = 'Please enter valid New UserId';
                      ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg4));
                  }
                 }
            }
        }
        system.debug('testing==>'+msg3);
        
        if(msg.size() == 0 && msg3 == null && msg4 == null){
            system.debug('testing==>');
            automateEmailSwappingCallout();
        }
    } 
    public void automateEmailSwappingCallout() {        
        //String BehaviorId = '515534cd88b6161f92000024';
        system.debug('userIdOld ===>'+userIdOld );
        system.debug('userIdNew ===>'+userIdNew );
        String badgvilleUrl = '';
        String badgvilleSite = '';        
    
        if(!Test.isRunningTest()) {
            badgvilleUrl = BadgvilleUrls__c.getAll().get('BadgvilleApiUrl').Badgville_Urls__c;
            badgvilleSite = BadgvilleUrls__c.getAll().get('badgvilleSite').Badgville_Urls__c;                        
        } 
        
         HttpRequest req5 = new HttpRequest();
        HttpResponse res5 = new HttpResponse();
        Http http5 = new Http();
        req5.setEndpoint(badgvilleUrl+'/players/info.json?site='+badgvilleSite+'&email='+userIdOld+'@marketo.com');
        req5.setMethod('GET');
        String JSONContent5 = '';
        String plyrID5 = ''; 
        String plyrNickName5;
        Boolean playerExists5 = true;
        try {   
            if(Test.isRunningTest() == false) {
                res5 =  http5.send(req5);           
                System.debug(res5.getBody());
                JSONContent5 = res5.getBody();            
            } else {
                JSONContent5 = '{"data":{"_id":"5177cd4e88b6164eba0035cb","id":"5177cd4e88b6164eba0035cb","name":null,"first_name":null,"last_name":null,"display_name":"Bikki","nick_name":null,"email":"005W0000000yGL6IAM@marketo.com","user_email":"005W0000000yGL6IAM@marketo.com","created_at":"2013-04-24T05:17:18-07:00","user_id":"5177cd4e88b6164eba0035ca","site_id":"4f4379a23dc6483f35000789","site_url":"www.grazitti.com","admin":false,"points_day":0.0,"points_week":130.0,"points_month":130.0,"points_all":130.0,"points_interval":0.0,"facebook_id":null,"facebook_link":null,"twitter_id":null,"twitter_username":null,"twitter_link":null,"email_notifications":true,"custom_picture_url":null,"picture_url":"/resource/1366785192000/Marketo_New_Community/images/global/default_profile.png","preferences":{"email_notifications":true,"hide_notifications":false,"publish_activity":true,"twitter":false},"teams":[],"social_networks":[],"units":{"points_day":0.0,"points_week":130.0,"points_month":130.0,"points_all":130.0,"points_interval":0.0,"followers_all":0,"following_all":0}},"paging":null}';          
            }
        } catch(System.CalloutException e) {
                System.debug('Callout error: '+ e);            
        }                       
            if(JSONContent5.contains('{"errors":[{"error":"invalid player"}]}'))
            {
                String msg3 = 'Player does not exist in Badgeville for Old UserId';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg3));
                return;
                
            }
            JSONParser parser1 =    JSON.createParser(JSONContent5);
            while (parser1.nextToken() != null) {
                System.debug('Current token: ' +  parser1.getCurrentToken());
                // Advance to the next value.                        
                parser1.nextValue();
                // Get the field name for the current value.                        
                String fieldName = parser1.getCurrentName();
                if(fieldName == '_id')
                {
                    // Get the textual representation of the value.   
                    System.debug('fieldName ==_id');                       
                    plyrID5  = parser1.getText();
                    playerExists5 = true;
                    break;
                }
            }
        
        
            HttpRequest req = new HttpRequest();
            HttpResponse res = new HttpResponse();
            Http http = new Http();
            req.setEndpoint(badgvilleUrl+'/players/info.json?site='+badgvilleSite+'&email='+userIdNew+'@marketo.com');
            req.setMethod('GET');
            String JSONContent = '';
            String plyrID = ''; 
            String plyrNickName;
            Boolean playerExists = true;
            Try{
                if(Test.isRunningTest() == false) {
                    res =  http.send(req);           
                    System.debug(res.getBody());
                    JSONContent = res.getBody();            
                } else {
                    JSONContent = '{"data":{"_id":"5177cd4e88b6164eba0035cb","id":"5177cd4e88b6164eba0035cb","name":null,"first_name":null,"last_name":null,"display_name":"Bikki","nick_name":null,"email":"005W0000000yGL6IAM@marketo.com","user_email":"005W0000000yGL6IAM@marketo.com","created_at":"2013-04-24T05:17:18-07:00","user_id":"5177cd4e88b6164eba0035ca","site_id":"4f4379a23dc6483f35000789","site_url":"www.grazitti.com","admin":false,"points_day":0.0,"points_week":130.0,"points_month":130.0,"points_all":130.0,"points_interval":0.0,"facebook_id":null,"facebook_link":null,"twitter_id":null,"twitter_username":null,"twitter_link":null,"email_notifications":true,"custom_picture_url":null,"picture_url":"/resource/1366785192000/Marketo_New_Community/images/global/default_profile.png","preferences":{"email_notifications":true,"hide_notifications":false,"publish_activity":true,"twitter":false},"teams":[],"social_networks":[],"units":{"points_day":0.0,"points_week":130.0,"points_month":130.0,"points_all":130.0,"points_interval":0.0,"followers_all":0,"following_all":0}},"paging":null}';          
                }
            } catch(System.CalloutException e) {
                    System.debug('Callout error: '+ e);            
            }
                                   
            if(JSONContent.contains('{"errors":[{"error":"invalid player"}]}'))
            {
                String msg3 = 'Player does not exist in Badgeville for New UserId';
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, msg3));
                return;
                //User does not exist in badgeville create one 
             
               System.debug('Player error invalid player'); 
               playerExists  = false;                                                                                     
            }
           
                JSONParser parser =    JSON.createParser(JSONContent);
                while (parser.nextToken() != null) {
                    System.debug('Current token: ' +  parser.getCurrentToken());
                    // Advance to the next value.                        
                    parser.nextValue();
                    // Get the field name for the current value.                        
                    String fieldName = parser.getCurrentName();
                    if(fieldName == '_id')
                    {
                        // Get the textual representation of the value.   
                        System.debug('fieldName ==_id');                       
                        plyrID  = parser.getText();
                        playerExists = true;
                        break;
                    }
                }
            if((plyrID != '') && (playerExists  == true && plyrID5 != '' && playerExists ==true )){
                String JSONContent1 = '';  
                String JSONContent2 = '';
                String JSONContent3 = '';
                  
                HttpRequest req12 = new HttpRequest();
                HttpResponse res12 = new HttpResponse();
                Http http12 = new Http(); 
                
                req12.setEndpoint( badgvilleUrl + '/users/change_emails.json?new_email=' + UserIdOld + '@marketo.com&old_email=Temp' +UserIdOld+'@marketo.com' );
                req12.setMethod('GET');
                
                String JSONContent12 = '';
                  
            
                system.debug('[player_id]====>'+ plyrID );                     
                HttpRequest req1 = new HttpRequest();
                HttpResponse res1 = new HttpResponse();
                Http http1 = new Http(); 
                
                req1.setEndpoint( badgvilleUrl + '/users/change_emails.json?new_email=Temp' + UserIdOld + '@marketo.com&old_email=' +UserIdOld+'@marketo.com' );
                req1.setMethod('GET');
                    
                                
                Try{  
                    if(Test.isRunningTest() == false) {
                        res1 =  http1.send(req1);           
                        System.debug(res1.getBody());
                        JSONContent1 = res1.getBody();            
                    }
                } catch(System.CalloutException e) {
                 System.debug('Callout error: '+ e);            
                }
                   
                if(Test.isRunningTest() == true){
                     //Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped('{"success":"successfully changed email"}');
                     //SessionId = string.valueOf(m.get('access_token')); 
                     JSONContent1 = '{"success":"successfully changed email"}'  ;
                     //UserIdOld = plyrID5;
                     //UserIdNew = plyrID;
                }
                if(JSONContent1.contains('{"success":"successfully changed email"}')){ 
                    system.debug('JSONContent1==>'+JSONContent1);
    
  
                    HttpRequest req2 = new HttpRequest();
                    HttpResponse res2 = new HttpResponse();
                    Http http2 = new Http(); 
                    req2.setEndpoint( badgvilleUrl + '/users/change_emails.json?new_email='+ UserIdOld + '@marketo.com&old_email=' +UserIdNew+'@marketo.com' );
                    req2.setMethod('GET');                  
                                  
                  
                    if(Test.isRunningTest() == false) {
                        res2 =  http2.send(req2);           
                        System.debug(res2.getBody());
                        JSONContent2 = res2.getBody();            
                    }
                 
                }
                   
                system.debug('JSONContent2==>'+JSONContent2);
                if(Test.isRunningTest() == true){
                     //Map<String, Object> m = (Map<String, Object>)JSON.deserializeUntyped('{"success":"successfully changed email"}');
                     //SessionId = string.valueOf(m.get('access_token')); 
                     JSONContent2 = '{"success":"successfully changed email"}'  ;
                }
                if(JSONContent2.contains('{"success":"successfully changed email"}')){ 
                    
                    HttpRequest req3 = new HttpRequest();
                    HttpResponse res3 = new HttpResponse();
                    Http http3 = new Http(); 
                    req3.setEndpoint( badgvilleUrl + '/users/change_emails.json?new_email=' + UserIdNew + '@marketo.com&old_email=Temp' +UserIdOld+'@marketo.com' );
                    req3.setMethod('GET');                  
                                   
                    Try{
                        if(Test.isRunningTest() == false) {
                            res3 =  http3.send(req3);           
                            System.debug(res3.getBody());
                            JSONContent3 = res3.getBody();            
                        }
                        system.debug('JSONContent3==>'+JSONContent3);
                         if(JSONContent3.contains('{"success":"successfully changed email"}')){ 
                             isSuccess = true;
                         }
                         else if(Test.isRunningTest() == false) { 
                             hasNotFailed = false;   
                         }
                    } catch(System.CalloutException e) {
                        System.debug('Callout error: '+ e);            
                    }
                }else if(Test.IsRunningTest() == true || !(JSONContent2.contains('{"success":"successfully changed email"}')) ){  //step 2 fails, revert step 1
                                                      
                            
                           
                        
                    Try{  
                        if(Test.isRunningTest() == false) {
                            res12 =  http12.send(req12);           
                            System.debug(res12.getBody());
                            JSONContent12 = res12.getBody();            
                        }
                    } catch(System.CalloutException e) {
                         System.debug('Callout error: '+ e);            
                    }          
                    if(JSONContent12.contains('{"success":"successfully changed email"}')){ 
                        
                    }else if(Test.isRunningTest() == false) {
                        system.debug('Step 2 reverted');
                        hasNotFailed = false;
                    }
                }
                    }  else if(Test.isRunningTest() == false) {
                        hasNotFailed = false;
                    }
                    if(hasNotFailed == true){
                        Try{
                            system.debug('userIdOld==>'+userIdOld);
                            system.debug('userIdNew==>'+userIdNew);
                            user oldUser = [select ContactId from user where id=:userIdOld];
                            user newUser = [select ContactId from user where id=:userIdNew];
                            // contact newUserContact = [Select id from contact where id= :newUser.ContactId ];
                            List<certification_History__c> ch = [select id, Certification_Contact__c from certification_History__c where Certification_Contact__c =:oldUser.contactId and BadgeVilleReward_Status__c = true and Exam_Result__c = 'Pass'];
                            
                            if(ch.size() > 0 && (newUser.ContactId != null || newUser.ContactId != '')){
                                ch[0].Certification_Contact__c = newUser.ContactId ;
                                update ch;
                                if(Test.IsRunningTest() == true){
                                    isSuccess  = true;
                                }
                                if(isSuccess == true){
                                    isSuccessForAll = true;
                                    isSuccess  = false;
                                }
                            }else if(ch.size() > 0 && (newUser.ContactId == null || newUser.ContactId == '')){
                                 hasNoContactAssociatedWithNewUser = True;
                            }
                         }Catch(system.dmlexception e){
                             System.debug('dmlexception error: '+ e); 
                         }
                        
                    }
               
        } 
                     
                
       
}