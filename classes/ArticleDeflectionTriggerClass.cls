public class ArticleDeflectionTriggerClass {
    @future(callout=true)
    public static void makeCallout(Set<Id> articleIds){
         try{
            List<Article_Deflection__c> listToInsert = new List<Article_Deflection__c>();
            List<Article_Deflection__c> articleRecordList = [select id,Article_ID__c,Customer_Response_For_Yes__c,Customer_Response_For_No__c from Article_Deflection__c where id = :articleIds];
            for(Article_Deflection__c art: [select id,Article_ID__c from Article_Deflection__c where id = :articleIds and Article_ID__c != null]){
                  HttpRequest request  = new HttpRequest();
                  HTTPResponse response = new  HTTPResponse();
                  Http http = new Http();
                  request.setMethod('GET');
                  request.setTimeOut(25000);
                  request.setEndPoint('https://www.nation.marketo.com/api/core/v3/contents/'+art.Article_ID__c+'');
                  String JSONContentOld = '';
                  if(!Test.isRunningTest()){
                      response = http.send(request);
                      JSONContentOld = response.getBody();
                  }
                  else{
                      response.setBody('{"entityType":"document","id":"2584","resources":{"entitlements":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/contents/136259/entitlements"},"abuseReports":{"allowed":["POST"],"ref":"https://nation.marketo.com/api/core/v3/contents/136259/abuseReports"},"outcomeTypes":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/contents/136259/outcomeTypes"},"childOutcomeTypes":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/contents/136259/childOutcomeTypes"},"followingIn":{"allowed":["GET","POST"],"ref":"https://nation.marketo.com/api/core/v3/contents/136259/followingIn"},"editHTML":{"allowed":["GET"],"ref":"https://nation.marketo.com/docs/DOC-2584/edit"},"attachments":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/attachments/contents/136259"},"comments":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/contents/136259/comments"},"read":{"allowed":["DELETE","POST"],"ref":"https://nation.marketo.com/api/core/v3/contents/136259/read"},"followers":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/contents/136259/followers"},"pdf":{"allowed":["GET"],"ref":"https://nation.marketo.com/docs/DOC-2584-tracking-lead-sources-using-utm-parameters.pdf"},"versions":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/versions/136259"},"self":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/contents/136259"},"html":{"allowed":["GET"],"ref":"https://nation.marketo.com/docs/DOC-2584-tracking-lead-sources-using-utm-parameters"}},"content":{"text":"abc","editable":false,"type":"text/html"},"status":"published","subject":"Tracking Lead Sources Using UTM Parameters","visibility":"place","restrictComments":true,"editDisabled":false,"updater":{"id":"158374","resources":{"reports":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/people/158374/@reports"},"followingIn":{"allowed":["GET","POST"],"ref":"https://nation.marketo.com/api/core/v3/people/158374/followingIn"},"images":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/people/158374/images"},"activity":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/people/158374/activities"},"manager":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/people/158374/@manager"},"social":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/people/158374/@social"},"recognition":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/people/158374/@recognition"},"trendingContent":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/people/158374/@trendingContent"},"trendingPlaces":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/people/158374/@trendingPlaces"},"avatar":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/people/158374/avatar?a=1009"},"followers":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/people/158374/@followers"},"colleagues":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/people/158374/@colleagues"},"following":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/people/158374/@following"},"members":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/members/people/158374"},"self":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/people/158374"},"html":{"allowed":["GET"],"ref":"https://nation.marketo.com/people/vishals"}},"displayName":"Vishal Sharma","jive":{"enabled":true,"externalContributor":false,"username":"vishals","visible":true},"name":{"familyName":"Sharma","formatted":"Vishal Sharma","givenName":"Vishal"},"type":"person","typeCode":3}}');
                      JSONContentOld = response.getBody();
                  }
                  Article_Deflection__c  adObj = new Article_Deflection__c(id=art.Id);
                  Map<String, Object> mainMap = (Map<String, Object>)JSON.deserializeUntyped(JSONContentOld);
                  if(mainMap.ContainsKey('subject')){
                    adObj.Title__c = String.valueOf(mainMap.get('subject'));
                    if(mainMap.ContainsKey('resources')){
                        Map<String, Object> urlMain = (Map<String, Object>) mainMap.get('resources');  
                        Map<String,Object> htmlurl = (Map<String, Object>) urlMain.get('html'); 
                        if(htmlurl.ContainsKey('ref'))adObj.Article_Link__c = String.ValueOf(htmlurl.get('ref'));
                     }
                     listToInsert.add(adObj);
                 }  Database.Update(listToInsert,false); 
            }
        }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}      
    
    }
}