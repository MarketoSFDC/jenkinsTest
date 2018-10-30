public class CaseUtils {

    @future(callout = true) 
    public static  void sendCaseNotificationWithJiveEnabled(List<Id>  idOfCasesCreatedViaEmail, String authString) {
        system.debug('caseIds-----'+idOfCasesCreatedViaEmail);
        List<Case_Related_Article_List__c> artList = new List<Case_Related_Article_List__c>();
        Map<Id,Case> caseParsedMap;        

        if(authString.trim() != '') caseParsedMap = new Map<Id,Case>([Select Id, ContactId, Subject, Origin, Thread_Id__c, CaseNumber, Contact.Name, Contact.Email, CC_Email_001a__c,CC_Email_002a__c,CC_Email_003a__c,CC_Email_004a__c,CC_Email_005a__c,CC_Email_006a__c,CC_Email_007a__c,CC_Email_008a__c,CC_Email_009a__c,CC_Email_010a__c from Case where Origin = 'Web' AND id IN : idOfCasesCreatedViaEmail]);
        else caseParsedMap = new Map<Id,Case>([Select Id, ContactId, Subject, Origin, Thread_Id__c, CaseNumber, Contact.Name, Contact.Email, CC_Email_001a__c,CC_Email_002a__c,CC_Email_003a__c,CC_Email_004a__c,CC_Email_005a__c,CC_Email_006a__c,CC_Email_007a__c,CC_Email_008a__c,CC_Email_009a__c,CC_Email_010a__c from Case where (Origin = 'Email' OR Origin = 'Answer Service') AND id IN : idOfCasesCreatedViaEmail]);
        
        for(Case caseParser : caseParsedMap.values()) {
            List<ArticleSearchController.resultElement> confArticleList = new List<ArticleSearchController.resultElement>();
            List<ArticleSearchController.resultElement> jiveArticleList = new List<ArticleSearchController.resultElement>();
            Case_Related_Article_List__c ArticleToBeAdded = new Case_Related_Article_List__c();
            ArticleToBeAdded.Case__c = caseParser.Id;
            ArticleToBeAdded.Contact_Email__c = caseParser.Contact.Email;  
            ArticleToBeAdded.Contact__c = caseParser.ContactId;     
            ArticleToBeAdded.CC_Email_001a__c = caseParser.CC_Email_001a__c;                             
            ArticleToBeAdded.CC_Email_002a__c = caseParser.CC_Email_002a__c;     
            ArticleToBeAdded.CC_Email_003a__c = caseParser.CC_Email_003a__c;     
            ArticleToBeAdded.CC_Email_004a__c = caseParser.CC_Email_004a__c;     
            ArticleToBeAdded.CC_Email_005a__c = caseParser.CC_Email_005a__c;     
            ArticleToBeAdded.CC_Email_006a__c = caseParser.CC_Email_006a__c;     
            ArticleToBeAdded.CC_Email_007a__c = caseParser.CC_Email_007a__c;     
            ArticleToBeAdded.CC_Email_008a__c = caseParser.CC_Email_008a__c;     
            ArticleToBeAdded.CC_Email_009a__c = caseParser.CC_Email_009a__c;     
            ArticleToBeAdded.CC_Email_010a__c = caseParser.CC_Email_010a__c;     

            String encodedURLConf = System.label.Confluence_Search_Url + EncodingUtil.urlEncode(caseParser.Subject, 'UTF-8') + '&where=DOCS&type=page&user=&pageSize=5&highlight=false&sessionUuid=0-0-0-0&startIndex=0';
            String encodedURLJive = System.label.Jive_Search_URL + '(' + EncodingUtil.urlEncode(caseParser.Subject, 'UTF-8')+')' +'&abridged=false&count=5&startIndex=0';      
            HTTPResponse responseConf;HTTPResponse responseJive;    
            /*HttpRequest reqConf  = new HttpRequest();HttpRequest reqJive  = new HttpRequest();
            Http httpConf = new Http(); Http httpJive = new Http();
            reqConf.setEndPoint(encodedURLConf);reqConf.setMethod('GET');responseConf = new HTTPResponse();
            responseConf = httpConf.send(reqConf);System.Debug('REQUEST'+req);
            if(responseConf.getStatus() != 'OK')responseConf  = null;
            Blob headerValue = Blob.valueOf(authString);
            String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
            reqJive.setHeader('Authorization', authorizationHeader);
            reqJive.setHeader('content-type', 'application/json');
            reqJive.setHeader('Accept', 'application/json');                         
            reqJive.setEndPoint(encodedURLJive);
            reqJive.setMethod('GET');
            responseJive  = new HTTPResponse();
            responseJive  = httpJive.send(reqJive);                
            if(responseJive.getStatus() != 'OK') responseJive = null;            
            //jive search result
            responseJive.setBody('{"itemsPerPage":5,"links":{"next":"https://nation.marketo.com/api/core/v3/search/contents?collapse=false&sort=relevanceDesc&fields=subject%2Cid%2Ccontent&filter=type%28document%29&filter=search%28landing%29&origin=unknown&highlight=false&socialSearch=false&returnScore=false&count=5&startIndex=10"},"list":[{"id":"1124","resources":{"versions":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/versions/1261"},"html":{"allowed":["GET"],"ref":"https://nation.marketo.com/docs/DOC-1124"}},"index":"0","uuid":"97b7eb32-df87-4c55-b074-44d1fe3480e5","content":{"text":"<body><div><p><span>This course on Marketo Landing Page templates walks you through the creation of a custom landing page template.</span></p></div></body>","editable":false,"type":"text/html"},"subject":"Advanced Landing Page Template Development","type":"document"},{"id":"1194","resources":{"versions":{"allowed":["GET"],"ref" : "https://nation.marketo.com/api/core/v3/versions/1393"},"html":{"allowed":["GET"],,"ref" : "https://nation.marketo.com/docs/DOC-1194"}},"index":"1","content":{"text":"<body><div><p><span>Here is a list of all the ways leads can get into Marketo.</span></p></div></body>","editable":false,"type":"text/html"},"subject":"How Do Leads Get Into Marketo?","type":"document"},{"id":"1210","resources":{"versions":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/versions/1432"},"html":{"allowed":["GET"],"ref":"https://nation.marketo.com/docs/DOC-1210"}},"index":"2","content":{"text":"<body><div><p><span><strong>Issue:</strong></span></p></div></body>", "editable":false,"type":"text/html"},"subject":"Content in Landing Page not staying in position","type":"document"},{"id":"1286","resources":{"versions":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/versions/1543"},"html":{"allowed":["GET"],"ref":"https://nation.marketo.com/docs/DOC-1286"}},"index":"3","content":{"text":"<body><div><p>This standard landing page template was submitted by Marketo customer Veeam.This is a customer submitted template that has not been modified by Marketo.It is recommended that you have an HTML proficient person edit and fine tune the code before using.</div></body>","editable":false,"type":"text/html"},"subject":"Standard Landing Page Template: Veeam","type":"file"},{"id":"1094","resources":{"versions":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/versions/1284"},"html":{"allowed":["GET"],"ref":"https://nation.marketo.com/docs/DOC-1094"}},"index":"4","content":{"text":"<body><div><h3><span><strong>Question</strong></span></h3></div></body>","editable":false,"type":"text/html"},"subject":"How to remove Munchkin from landing pages","type":"document"}],"startIndex":5}');
            //docs search result
            responseConf.setBody('{"results":[{"id":2359734,"title":"Preview a Landing Page with Dynamic Content (Landing Pages)","bodyTextHighlights":"Use Dynamic Content in a Landing Page Preview a Landing Page Preview your landing page after adding dynamic content in order to verify. Select a landing page and click…","url":"/pages/viewpage.action?pageId=2359734&src=search","searchResultContainer":{"name":"Marketo Docs","url":"/display/DOCS"},"friendlyDate":"Sep 25, 2014","contentType":"page","metadata":{}},{"id":2359732,"title":"Use Dynamic Content in a Landing Page (Landing Pages)","bodyTextHighlights":"Create a Segmentation Create a Landing Page Add a New Form to a Landing Page Using Dynamic Content in Landing Pages engages your leads with targeted information. Add…","url":"/pages/viewpage.action?pageId=2359732&src=search","searchResultContainer":{"name":"Marketo Docs","url":"/display/DOCS"},"friendlyDate":"Jan 20, 2015","contentType":"page","metadata":{}},{"id":2359710,"title":"Approve, Unapprove or Delete a Landing Page","bodyTextHighlights":"Landing pages are in draft mode until you approve them. Approval makes pages available in the rest of the system. When you edit an approved landing page, Marketo saves…","url":"/display/DOCS/Approve,+Unapprove+or+Delete+a+Landing+Page?src=search","searchResultContainer":{"name":"Marketo Docs","url":"/display/DOCS"},"friendlyDate":"Nov 21, 2014","contentType":"page","metadata":{}},{"id":2359716,"title":"Preview a Landing Page","bodyTextHighlights":"You probably want to see what a landing page you are working on looks like before making it live. Preview a Landing Page Select a landing page and click Preview Page…","url":"/display/DOCS/Preview+a+Landing+Page?src=search","searchResultContainer":{"name":"Marketo Docs","url":"/display/DOCS"},"friendlyDate":"Sep 25, 2014","contentType":"page","metadata":{}},{"id":2359535,"title":"Preview a Landing Page with Dynamic Content","bodyTextHighlights":"Use Dynamic Content in a Landing Page Preview a Landing Page Preview your landing page after adding dynamic content in order to verify. Select a landing page…","url":"/display/DOCS/Preview+a+Landing+Page+with+Dynamic+Content?src=search","searchResultContainer":{"name":"Marketo Docs","url":"/display/DOCS"},"friendlyDate":"Sep 16, 2014","contentType":"page","metadata":{}}],"total":255,"archivedResultsCount":0,"uuid":"ce98f3c0-771c-437b-b1f3-c485b1172a4c","timeSpent":10}');                                
            */                                         
            ArticleSearchController caseArtContlr = new ArticleSearchController ();                                        
            try {                    
                responseConf = caseArtContlr.makeAPIRequest(encodedURLConf,'');                                         
            } catch (Exception ex) {
                System.Debug('Exception==>' + ex);                    
                responseConf  = null;
            }
            if(authString.trim() != ''){ 
                try {
                    responseJive = caseArtContlr.makeAPIRequest(encodedURLJive,authString);                                            
                } catch (Exception ex) {
                    System.Debug('Exception==>' + ex);                    
                    responseJive = null;
                }
            }                                                                                                                                                      
             
            try {
                if(responseConf != NULL) {
                    caseArtContlr.confCategorySpecificResults(responseConf);
                    confArticleList.addAll(caseArtContlr.results);             
                }
                if(responseJive != NULL){
                    caseArtContlr.jiveCategorySpecificResults(responseJive);
                    jiveArticleList.addAll(caseArtContlr.results);
                }    
            } catch (Exception ex) {
                System.Debug('Exception==>' + ex);                    
            }
                                     
            System.Debug('___RESULTS___'+confArticleList);
            System.Debug('___RESULTS___'+jiveArticleList);

            Integer Count = 1; String commentText = '';
            for(ArticleSearchController.resultElement confArticleParser : confArticleList) {
                if(confArticleParser.sfdc_id != '' && Count <= 8) {
                    String helpArticleLink = System.label.Confluence_ViewPage_BaseUrl+confArticleParser.sfdc_id;
                    commentText  +=  Count + '. ' + confArticleParser.title + ' ' + helpArticleLink + '\r\n'; 
                    ArticleToBeAdded.put('Article_Title'+Count+'__c',confArticleParser.title);
                    ArticleToBeAdded.put('Article_Link'+Count+'__c',helpArticleLink);   
                    Count++;                      
                    /*
                    if(Count == 1){
                        ArticleToBeAdded.Article_Title1__c = confArticleParser.title;
                        ArticleToBeAdded.Article_Link1__c  = helpArticleLink;                        
                    } else if(Count == 2){                    
                        ArticleToBeAdded.Article_Title2__c = confArticleParser.title;
                        ArticleToBeAdded.Article_Link2__c  = helpArticleLink;                        
                    } else if(Count == 3){                    
                        ArticleToBeAdded.Article_Title3__c = confArticleParser.title;
                        ArticleToBeAdded.Article_Link3__c  = helpArticleLink;                        
                    } else if(Count == 4){                    
                        ArticleToBeAdded.Article_Title4__c = confArticleParser.title;
                        ArticleToBeAdded.Article_Link4__c  = helpArticleLink;                        
                    } else if(Count == 5){                    
                        ArticleToBeAdded.Article_Title5__c = confArticleParser.title;
                        ArticleToBeAdded.Article_Link5__c  = helpArticleLink;                        
                    } else if(Count == 6){                    
                        ArticleToBeAdded.Article_Title6__c = confArticleParser.title;
                        ArticleToBeAdded.Article_Link6__c  = helpArticleLink;                        
                    } else if(Count == 7){                    
                        ArticleToBeAdded.Article_Title7__c = confArticleParser.title;
                        ArticleToBeAdded.Article_Link7__c  = helpArticleLink;                        
                    } else if(Count == 8){                    
                        ArticleToBeAdded.Article_Title8__c = confArticleParser.title;
                        ArticleToBeAdded.Article_Link8__c  = helpArticleLink;                        
                    }*/                
                    
                }                                                    
            }      
            
            for(ArticleSearchController.resultElement jiveArticleParser : jiveArticleList) {
                if(jiveArticleParser.sfdc_id != '' && Count <=8 ) {                      
                    String helpArticleLink = System.label.Jive_ViewPage_BaseUrl+jiveArticleParser.sfdc_id;
                    commentText  +=  Count + '. ' + jiveArticleParser.title + ' ' + helpArticleLink + '\r\n';                     
                    ArticleToBeAdded.put('Article_Title'+Count +'__c',jiveArticleParser.title);
                    ArticleToBeAdded.put('Article_Link'+Count+'__c',helpArticleLink);      
                    Count++;              
                    /*if(Count == 1){
                        ArticleToBeAdded.Article_Title1__c = jiveArticleParser.title;
                        ArticleToBeAdded.Article_Link1__c  = helpArticleLink;                        
                    } else if(Count == 2){                    
                        ArticleToBeAdded.Article_Title2__c = jiveArticleParser.title;
                        ArticleToBeAdded.Article_Link2__c  = helpArticleLink;                        
                    } else if(Count == 3){                    
                        ArticleToBeAdded.Article_Title3__c = jiveArticleParser.title;
                        ArticleToBeAdded.Article_Link3__c  = helpArticleLink;                        
                    } else if(Count == 4){                    
                        ArticleToBeAdded.Article_Title4__c = jiveArticleParser.title;
                        ArticleToBeAdded.Article_Link4__c  = helpArticleLink;                        
                    } else if(Count == 5){                    
                        ArticleToBeAdded.Article_Title5__c = jiveArticleParser.title;
                        ArticleToBeAdded.Article_Link5__c  = helpArticleLink;                        
                    }
                    else if(Count == 6){                    
                        ArticleToBeAdded.Article_Title6__c = jiveArticleParser.title;
                        ArticleToBeAdded.Article_Link6__c  = helpArticleLink;                        
                    }
                    else if(Count == 7){                    
                        ArticleToBeAdded.Article_Title7__c = jiveArticleParser.title;
                        ArticleToBeAdded.Article_Link7__c  = helpArticleLink;                        
                    }
                    else if(Count == 8){                    
                        ArticleToBeAdded.Article_Title8__c = jiveArticleParser.title;
                        ArticleToBeAdded.Article_Link8__c  = helpArticleLink;                        
                    }*/                                    
                                                                        
                }
            }
            If(ArticleToBeAdded.Case__c != NULL) artList.add(ArticleToBeAdded);
        }
        If(artList.isEmpty() == FALSE)  insert artList;                                                  
    }    
}