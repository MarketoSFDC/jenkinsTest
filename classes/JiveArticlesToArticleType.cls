public class JiveArticlesToArticleType{

    public static void method1(){
    integer i = Integer.ValueOf(Label.incrementby100);
    integer k= i+100;
    List<Issue_Solution_Article__kav> isaList = new List<Issue_Solution_Article__kav>();
    List<Article__kav> akList = new List<Article__kav>();
    Set<String> urlSet = new Set<String>();
    Set<String> urlSett = new Set<String>();
    StaticResource sr = [SELECT Id, Body from StaticResource WHERE Name = 'ResponseJiveArt' LIMIT 1];
    String resBody = sr.Body.toString();
    
    for(Issue_Solution_Article__kav ii : [SELECT urlname FROM Issue_Solution_Article__kav]){
        urlSet.add(ii.urlname);
    }
    for(Article__kav iii : [SELECT urlname FROM Article__kav]){
        urlSett.add(iii.urlname);
    }
    Integer j = 0;
    while(i<k){
        HTTPResponse res = new HTTPResponse();
        HttpRequest req  = new HttpRequest();
        req.setHeader('content-type', 'application/json');
        req.setHeader('Accept', 'application/json'); 
        req.setEndPoint('https://www.nation.marketo.com/api/core/v3/contents?filter=place(https://nation.marketo.com/api/core/v3/places/1050)&count=25&type(document)&abridged=false&startIndex='+i+'');
        req.setMethod('GET');
        String JSONContent = '';
        Http http = new Http();
        if(!Test.isRunningTest()){
            res  = http.send(req);
            JSONContent = res.getBody(); 
        }
        else{
             res.setBody(resBody);
             JSONContent = res.getBody();
        }
        JSONContent = JSONContent.remove('throw \'allowIllegalResourceCall is false.\';');                
        if(JSONContent.contains('{"errors":[{"error":"not found"}]}')){
            System.debug('No Articles Found');                                                                                                      
        }
        else{
            JSONParser parser = JSON.createParser(JSONContent);
            Map<String,Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(JSONContent); 
            List<Object> jsonResults = (List<Object>) jsonMap.get('list'); 
            System.debug('results==>' + jsonResults.size());  
            //Integer j = 0;
            for(Object result : jsonResults){  
            String bodyTextHighlights='';String contentType='';String jiveUrl='';String id=''; String title=''; String issueDescription =''; String issueResolution=''; String articleDescription=''; String articleDescriptionn=''; String tags=''; String at; String ir='';
    
            Map<String, Object> resMap = (Map<String, Object>) result; 
            Map<String, Object> urlMain = (Map<String, Object>) resMap.get('resources');  
            Map<String,Object> htmlurl = (Map<String, Object>) urlMain.get('html');
            
            if(htmlurl.ContainsKey('ref')){
            jiveUrl = String.ValueOf(htmlurl.get('ref'));
            } 
            title = GlobalFunctions.getShortBody((string)resMap.get('subject')); 
            List<Object> tagsList = (List<Object>)resMap.get('tags'); 
    
            Map<String, Object> docContent = (Map<String, Object>) resMap.get('content');
            if(docContent.containsKey('text')){
            bodyTextHighlights = (String)docContent.get('text');
            
            for(Object oo :tagsList){
                tags += String.ValueOf(oo)+',';
            }
            tags = tags.removeEnd(',');
    
            if(bodyTextHighlights != Null && bodyTextHighlights.contains('Issue Description') && bodyTextHighlights.contains('Issue Resolution')){
                issueDescription = bodyTextHighlights.substring(bodyTextHighlights.indexOF('Issue Description'),bodyTextHighlights.Indexof('Issue Resolution'));
            }
    
            if(bodyTextHighlights != Null && bodyTextHighlights.contains('Issue Resolution') && bodyTextHighlights.contains('</body>')){
                issueResolution = bodyTextHighlights.substring(bodyTextHighlights.indexOF('Issue Resolution'),bodyTextHighlights.Indexof('</body>'));
            }
            
            if((issueResolution.contains('Is this article helpful')) && (issueResolution.contains('No</a></p><br/></div>'))){
                ir = issueResolution.substring(0,issueResolution.indexOF('Is this article helpful'))+ issueResolution.substring(issueResolution.indexof('</a></p><br/></div>'), issueResolution.Length());
            }
            
            
    
            System.debug('@@@@@@@@is'+issueDescription);
            System.debug(title);
            
            String s12 = title.replaceAll('\\s+', '-');
            String regExp = '[^\\w\\s]';
            String replacement = '-';
            String urlname = s12.replaceAll(regExp, replacement);
            if(urlname.contains('_')){
                urlname = urlname.replaceAll('_',replacement);
            }
            System.debug('@@@@@@fc'+urlname+j);
            if(bodyTextHighlights != Null && bodyTextHighlights.contains('Issue Description')){
                Issue_Solution_Article__kav isa = new Issue_Solution_Article__kav();
                isa.title = title;
                isa.urlname = 'Url-'+urlname+j;
                System.debug('@@@@@fc1'+ isa.urlname);
                isa.Issue__c = issueDescription;
                if(issueResolution.contains('Is this article helpful')){
                isa.Solution__c = ir;
                }else{
                isa.Solution__c = issueResolution;}
                isa.keywords__c = tags;
                system.debug('jjjjjj --> ' +j);
                isaList.add(isa);
            } 
            
            if(bodyTextHighlights != Null && !bodyTextHighlights.contains('Issue Description')){
                articleDescription = bodyTextHighlights.substring(bodyTextHighlights.indexOF('<body>'),bodyTextHighlights.Indexof('</body>'));
                if((articleDescription.contains('Is this article helpful')) && (articleDescription.contains('No</a></p><br/></div>'))){
                    at = articleDescription.substring(0,articleDescription.indexOF('Is this article helpful'))+ articleDescription.substring(articleDescription.indexof('</a></p><br/></div>'), articleDescription.Length());
                }
                
                Article__kav ak = new Article__kav();
                ak.title = title;
                ak.urlname = 'Url-'+urlname+j;
                if(articleDescription.contains('Is this article helpful')){
                ak.Article_Text__c = at;
                }else{
                ak.Article_Text__c = articleDescription;}   
                ak.keywords__c = tags;
                akList.add(ak);
            }
            
            } 
              j++;
            }      
        }
        i+=25;
    }
    system.debug(isaList);
    Insert isaList;
    Insert akList;
    }

}