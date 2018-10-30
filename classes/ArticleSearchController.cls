/*
Name: ArticleSearchController
Created Date: 06/05/2012
Major Change Date: 08/20/2014
Usage: To search articles and relate them to a case.
*/
public class ArticleSearchController {
    public Integer currResourcePgNum{get; set;}
    public String caseId {get; set;}
    public String searchText {get; set;}
    public String selectedLang {get; set;}
    public Case caseRecord {get;set;}
    public Integer pageNum{get;set;}
    public List<resultelement> results{get;set;}
    public string attachedArticles{get;set;}
    public String solrServerURL = System.label.solrapiurl;
    public String confluencSearchUrl = System.label.Confluence_Search_Url;
    public String jiveSearchUrl = System.label.Jive_Search_URL;
    public XMLDom xmlResult;
    public Integer numberOfResults{get;set;}
    public List<Integer> paginationList{get;set;}
    public Integer currentPage{get; set;}
    public Static Integer MAX_PAGE_SIZE = 10;
    public Integer currResourcePageNum{get;set;}        
    public String channelType{get;set;}    
    public String selectedArticleIds {get;set;}
    public CaseArticleSearchLinks__c caStRecord {get;set;}
    public List<ArticleWrap> docsList;
    public string attachedDocs {get;set;}
    public List<ArticleWrap> jiveList;
    public string attachedLinks {get;set;}
    public Boolean hasNextPage{get;set;}
    public Boolean hasPrevPage{get;set;}
    public Integer nextIndex{get;set;}    
    public Integer prevIndex{get;set;}    
    public Integer startIndex{get;set;} 
    public Boolean isPagReqd;
    public Boolean searchOption{get;set;}
    public String testing{get;set;}
    public ArticleSearchController(ApexPages.StandardController controller) {
        hasPrevPage = false;
        hasNextPage = false;
        isPagReqd = true;
        searchOption = false;
        currentPage  = 0;
        testing= '';
        numberOfResults  = 0;         
        caStRecord  = new CaseArticleSearchLinks__c();
        channelType  = ApexPages.currentPage().getParameters().get('channelType')!=null?ApexPages.currentPage().getParameters().get('channelType'):'Community';
        startIndex  = ApexPages.currentPage().getParameters().get('startIndex')!=null?Integer.valueof(ApexPages.currentPage().getParameters().get('startIndex')):0;
        currResourcePageNum = 1;
        caseRecord = (Case)controller.getRecord();
        currentPage = ApexPages.currentPage().getParameters().get('page')!=null?integer.valueof(ApexPages.currentPage().getParameters().get('page')):0;
        if(searchText == null) {
            searchText = ApexPages.currentPage().getParameters().get('searchText') != null?ApexPages.currentPage().getParameters().get('searchText'):'';
        }
        searchKnowledgeRecords();
    }    
    public ArticleSearchController() { hasPrevPage=false; hasNextPage=false;startIndex=0;MAX_PAGE_SIZE = 5;isPagReqd = true;}    
    public void resourceArticleNext() {
        currResourcePageNum = currResourcePageNum + 1;
    }
    public void resourceArticlePrev() {
        currResourcePageNum = currResourcePageNum - 1;
    }
    
    public PageReference searchKnowledgeRecords(){ 
       try{
           currResourcePageNum = 1;
            Integer caseCount = [select COUNT() from Case where id = :caseRecord.Id];        
            if(caseCount > 0) {
                caseRecord = [select Subject from Case where id = :caseRecord.id];
                if((searchText == null || searchText.Trim() == '' ) && caseRecord.Subject != null)
                    searchText = caseRecord.Subject;
                if(searchText == null && caseRecord.Subject == null)
                    searchText = '';
            }        
            if(searchText.trim().length() < 2) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Search text length should be more than one'));
                return null;
            }        
            List <String> top_categories  = new List<string>{'Resource'};//{'Article','Tutorial','Resource'};
            String sortByQueryString = '';
            String dCategoryFq       = '';
            String top_category_query = '&fq=';
            System.debug('top_CATEGORIRES_'+top_categories.size());
            if (top_categories.size() > 0) {
                for (String top_category_temp :top_categories) {
                    top_category_query += 'top_category:'+top_category_temp+'+';  
                }
            }        
            String chnlType = channelType; 
            String encodedURL = '';        
            HTTPResponse response = new HTTPResponse();
            if(chnlType.trim() == 'Community') { 
                String srch = searchText;
                if(searchText.Contains('docs.marketo.com') && !searchText.Contains('?pageId=')){
                    isPagReqd = true;
                    //srch = srch.substring(srch.indexof('DOCS/')+5,srch.indexof('?src=search'));
                    srch = srch.Substring(srch.IndexOf('DOCS/')+5);
                    srch = srch.replace('+',' ');
                    encodedURL  = confluencSearchUrl + EncodingUtil.urlEncode('\"'+ srch + '\"', 'UTF-8') + '&where=DOCS&type=page&user=&pageSize='+MAX_PAGE_SIZE+'&highlight=false&sessionUuid=0-0-0-0&startIndex='+(currentPage*MAX_PAGE_SIZE);
                    system.debug('&&&&&'+encodedURL );
                    response = makeAPIRequest(encodedURL,'');                    
                }
                else if(searchText.Contains('docs.marketo.com') && searchText.Contains('?pageId=')){
                        //srch = srch.substring(srch.indexof('pageId=')+7,srch.indexof('&src=search'));
                        srch = srch.substring(srch.indexof('pageId=')+7);
                        encodedURL  = 'https://docs.marketo.com/rest/api/content/'+srch+'?expand=body.view';
                        system.debug('&&&&&'+encodedURL );
                        isPagReqd = false;
                        response = makeAPIRequest(encodedURL,''); 
                }
                else{
                    isPagReqd = true;
                    if(searchOption){
                        encodedURL  = confluencSearchUrl + EncodingUtil.urlEncode(srch, 'UTF-8') + '&where=DOCS&type=page&user=&pageSize='+MAX_PAGE_SIZE+'&highlight=false&sessionUuid=0-0-0-0&startIndex='+(currentPage*MAX_PAGE_SIZE);
                    }
                    else{
                        encodedURL  = confluencSearchUrl + EncodingUtil.urlEncode('\"'+srch+'\"', 'UTF-8') + '&where=DOCS&type=page&user=&pageSize='+MAX_PAGE_SIZE+'&highlight=false&sessionUuid=0-0-0-0&startIndex='+(currentPage*MAX_PAGE_SIZE);
                    }
                    response = makeAPIRequest(encodedURL,'');
                }
            }
            else if(chnlType.trim() == 'Internal'){
                if(searchText.Contains('nation.marketo.com') && searchText.Contains('DOC-')){
                    String srch = searchText;
                    srch = srch.substring(srch.indexof('DOC-')+4);
                    srch = srch.substring(0,4);
                    Integer docId = Integer.ValueOf(srch);
                    encodedURL  =  'https://www.nation.marketo.com/api/core/v3/contents?filter=entityDescriptor(102,'+docId+')&pageSize='+MAX_PAGE_SIZE+'&highlight=false&sessionUuid=0-0-0-0&startIndex='+(currentPage*MAX_PAGE_SIZE);
                    response = makeAPIRequest(encodedURL,''); 
                }
                else{
                    if(searchOption){
                        encodedUrl = jiveSearchUrl + '(' + EncodingUtil.urlEncode(searchText, 'UTF-8')+')' +'&abridged=false&count='+MAX_PAGE_SIZE+'&startIndex='+startIndex;      
                        system.debug('encodedUrl && ' +encodedUrl );
                    }
                    else{
                        encodedUrl = jiveSearchUrl + '(' + EncodingUtil.urlEncode('\"'+searchText+'\"', 'UTF-8')+')' +'&abridged=false&count='+MAX_PAGE_SIZE+'&startIndex='+startIndex;   
                        system.debug('encodedUrl && ' +encodedUrl );                        
                    }                   
                    response = makeAPIRequest(encodedURL,'');
                }
            }
            
            results = new List<resultelement>();
            if(response == null ) {           
                return null;//return results;    
            }
            if(chnlType.trim() == 'Community') {
                confCategorySpecificResults(response);
                /*Fetch the results from Confluence Json*/        
                createConfWrapper();                         
            } else {
                /*Fetch the results from Solr API*/        
                jiveCategorySpecificResults(response);
                createJiveWrapper();                                   
            } 
           
       }
       catch(Exception ex){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Please check the url and try again'));
       }
       return null;
    }
    
    public void createJiveWrapper() {
        List<Case_Confluence_Article__c> jiveLst = [select Case__c, DocsUrlLink__c from Case_Confluence_Article__c where isJiveArticle__c = true AND Case__c = :caseRecord.id];
        attachedLinks = '__';
        for(Case_Confluence_Article__c ca :jiveLst) {            
            attachedLinks += ca.DocsUrlLink__c+'__';
        }               
        System.Debug('attachedDocs+++++'+attachedLinks);        
    }        
    public void createConfWrapper() {       
        List<Case_Confluence_Article__c> confList = [select Case__c, DocsUrlLink__c from Case_Confluence_Article__c where isJiveArticle__c = false AND Case__c = :caseRecord.id];
        attachedDocs = '__';                           
        for(Case_Confluence_Article__c ca :confList) {
            attachedDocs += ca.DocsUrlLink__c+'__';
        }
        System.Debug('attachedDocs+++++'+attachedDocs);      
    }
    
    public void refreshWrapper(){
        if(channelType == 'Community')
            createConfWrapper();
        else
            createJiveWrapper();                    
    }      
    
    public void attachArticles() {                 
        try {
            Boolean isJiveArticle = channelType == 'Community'?false:true; 
            String uniqueUrl = '';
            if(results[0].url !='' && results[0].title !=''){
                uniqueUrl = results[0].url+'_'+results[0].title;
            }
            List<Case_Confluence_Article__c> chkRecords = [SELECT ID,Unique_url_id__c From Case_Confluence_Article__c Where Case__c =:caseRecord.id AND Unique_url_id__c = : uniqueUrl AND isJiveArticle__c = :isJiveArticle Limit 1];
            Case_Confluence_Article__c caRecord = new Case_Confluence_Article__c();
                if(chkRecords.isEmpty()){
                    caRecord.Case__c = caseRecord.id;
                    if(results[0].url !=''){
                        caRecord.DocsUrlLink__c = results[0].url;
                    }  
                    caRecord.isJiveArticle__C = isJiveArticle;
                    if(uniqueUrl !=''){
                        caRecord.Unique_url_id__c = uniqueUrl;
                    }
                }
            insert caRecord;                    
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
        }
        refreshWrapper();        
    }
                
    public void deAttachArticles() {
        try {
            String uniqueUrl = '';
            if(results[0].url !='' && results[0].title !=''){
                uniqueUrl = results[0].url+'_'+results[0].title;
            }
            Boolean isJiveArticle = channelType == 'Community'?false:true;
            List<Case_Confluence_Article__c> caList = [SELECT ID,Unique_url_id__c From Case_Confluence_Article__c Where Case__c =:caseRecord.id AND Unique_url_id__c = : uniqueUrl AND isJiveArticle__c = :isJiveArticle Limit 1];
            if(caList != null && caList.size() > 0) {
                delete caList;                
            }
        } catch(Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, e.getMessage()));
        }
        refreshWrapper();        
    }
    
    public List<SelectOption> getLanguageList() {      
        List<SelectOption> options = new List<SelectOption>();
        Schema.DescribeFieldResult language = User.LanguageLocaleKey.getDescribe(); 
        List<Schema.PicklistEntry> lang = language.getPicklistValues();
        for(Schema.PicklistEntry l :lang){
            options.add(new SelectOption(l.getValue(), l.getlabel()));
        }
        return options;
    } 
    
    public Map<String, String> languageStaticMap(){
        Map<String, String> langMap = new Map<String, String>();
        langMap.put('English (UK)', 'en_US');
        langMap.put('German', 'de');
        langMap.put('French', 'fr');
        langMap.put('Spanish', 'es');
        langMap.put('Italian', 'it');
        return langMap;
    }
      
    
    public class ArticleWrap {    
        public String confDocId {get; set;}
        public Boolean isAttach {get; set;}        
        public ArticleWrap(String docId, Boolean isAttach) {
            this.confDocId = docId;
            this.isAttach = isAttach;
        }
    }
    
    public HTTPResponse makeAPIRequest(String encodedURL, String authString) {
        HTTPResponse response;
        HttpRequest req  = new HttpRequest();
        req.setEndPoint(encodedURL );
        req.setMethod('GET');
        Http http = new Http();
        if(authString != '') {
            Blob headerValue = Blob.valueOf(authString);
            String authorizationHeader = 'Basic ' +
            EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('content-type', 'application/json');
            req.setHeader('Accept', 'application/json'); 
        }               
        if (!Test.isRunningTest()) {
            response  = http.send(req);
            //System.Debug('REQUEST'+req);
            if(response.getStatus() == 'OK') {
                return response;
            } else {
                return null;
            }
        } else {
            response = new HTTPResponse();                        
            if(authString != '') //jive search result
                response.setBody('{"itemsPerPage":5,"links":{"next":"https://nation.marketo.com/api/core/v3/search/contents?collapse=false&sort=relevanceDesc&fields=subject%2Cid%2Ccontent&filter=type%28document%29&filter=search%28landing%29&origin=unknown&highlight=false&socialSearch=false&returnScore=false&count=5&startIndex=10"},"list":[{"id":"1124","resources":{"versions":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/versions/1261"},"html":{"allowed":["GET"],"ref":"https://nation.marketo.com/docs/DOC-1124"}},"index":"0","uuid":"97b7eb32-df87-4c55-b074-44d1fe3480e5","content":{"text":"<body><div><p><span>This course on Marketo Landing Page templates walks you through the creation of a custom landing page template.</span></p></div></body>","editable":false,"type":"text/html"},"subject":"Advanced Landing Page Template Development","type":"document"},{"id":"1194","resources":{"versions":{"allowed":["GET"],"ref" : "https://nation.marketo.com/api/core/v3/versions/1393"},"html":{"allowed":["GET"],,"ref" : "https://nation.marketo.com/docs/DOC-1194"}},"index":"1","content":{"text":"<body><div><p><span>Here is a list of all the ways leads can get into Marketo.</span></p></div></body>","editable":false,"type":"text/html"},"subject":"How Do Leads Get Into Marketo?","type":"document"},{"id":"1210","resources":{"versions":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/versions/1432"},"html":{"allowed":["GET"],"ref":"https://nation.marketo.com/docs/DOC-1210"}},"index":"2","content":{"text":"<body><div><p><span><strong>Issue:</strong></span></p></div></body>", "editable":false,"type":"text/html"},"subject":"Content in Landing Page not staying in position","type":"document"},{"id":"1286","resources":{"versions":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/versions/1543"},"html":{"allowed":["GET"],"ref":"https://nation.marketo.com/docs/DOC-1286"}},"index":"3","content":{"text":"<body><div><p>This standard landing page template was submitted by Marketo customer Veeam.This is a customer submitted template that has not been modified by Marketo.It is recommended that you have an HTML proficient person edit and fine tune the code before using.</div></body>","editable":false,"type":"text/html"},"subject":"Standard Landing Page Template: Veeam","type":"file"},{"id":"1094","resources":{"versions":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/versions/1284"},"html":{"allowed":["GET"],"ref":"https://nation.marketo.com/docs/DOC-1094"}},"index":"4","content":{"text":"<body><div><h3><span><strong>Question</strong></span></h3></div></body>","editable":false,"type":"text/html"},"subject":"How to remove Munchkin from landing pages","type":"document"}],"startIndex":5}');
            else //docs search result
                response.setBody('{"results":[{"id":2359734,"title":"Preview a Landing Page with Dynamic Content (Landing Pages)","bodyTextHighlights":"Use Dynamic Content in a Landing Page Preview a Landing Page Preview your landing page after adding dynamic content in order to verify. Select a landing page and click…","url":"/pages/viewpage.action?pageId=2359734&src=search","searchResultContainer":{"name":"Marketo Docs","url":"/display/DOCS"},"friendlyDate":"Sep 25, 2014","contentType":"page","metadata":{}},{"id":2359732,"title":"Use Dynamic Content in a Landing Page (Landing Pages)","bodyTextHighlights":"Create a Segmentation Create a Landing Page Add a New Form to a Landing Page Using Dynamic Content in Landing Pages engages your leads with targeted information. Add…","url":"/pages/viewpage.action?pageId=2359732&src=search","searchResultContainer":{"name":"Marketo Docs","url":"/display/DOCS"},"friendlyDate":"Jan 20, 2015","contentType":"page","metadata":{}},{"id":2359710,"title":"Approve, Unapprove or Delete a Landing Page","bodyTextHighlights":"Landing pages are in draft mode until you approve them. Approval makes pages available in the rest of the system. When you edit an approved landing page, Marketo saves…","url":"/display/DOCS/Approve,+Unapprove+or+Delete+a+Landing+Page?src=search","searchResultContainer":{"name":"Marketo Docs","url":"/display/DOCS"},"friendlyDate":"Nov 21, 2014","contentType":"page","metadata":{}},{"id":2359716,"title":"Preview a Landing Page","bodyTextHighlights":"You probably want to see what a landing page you are working on looks like before making it live. Preview a Landing Page Select a landing page and click Preview Page…","url":"/display/DOCS/Preview+a+Landing+Page?src=search","searchResultContainer":{"name":"Marketo Docs","url":"/display/DOCS"},"friendlyDate":"Sep 25, 2014","contentType":"page","metadata":{}},{"id":2359535,"title":"Preview a Landing Page with Dynamic Content","bodyTextHighlights":"Use Dynamic Content in a Landing Page Preview a Landing Page Preview your landing page after adding dynamic content in order to verify. Select a landing page…","url":"/display/DOCS/Preview+a+Landing+Page+with+Dynamic+Content?src=search","searchResultContainer":{"name":"Marketo Docs","url":"/display/DOCS"},"friendlyDate":"Sep 16, 2014","contentType":"page","metadata":{}}],"total":255,"archivedResultsCount":0,"uuid":"ce98f3c0-771c-437b-b1f3-c485b1172a4c","timeSpent":10}');
            return response;        
        }
    }       
    
    public void jiveCategorySpecificResults(HTTPResponse res) {
        System.Debug('CAT SPECIFIC RESULTS');
        results = new List<resultelement>();
        string confluence_results = res.getBody();
        String JSONContent = res.getBody();
        System.debug(JSONContent); 
        JSONContent = JSONContent.remove('throw \'allowIllegalResourceCall is false.\';');       
        if(Test.isRunningTest()) {
            JSONContent = '{"startIndex":0,"itemsPerPage":1,"links":{"next":"https://example.jiveon.com/api/core/v3/announcements?fields=publishDate%2Ccontent%2Csubject&count=1&startIndex=1"},"list":[{"type":"announcement","publishDate":"2012-08-23T15:16:49.167+0000","content":{"type":"text/html","text":"test announcement"},"subject":"some announcement subject","resources":{"self":{"ref":"https://example.jiveon.com/api/core/v3/announcements/1065","allowed":["DELETE","GET","PUT"]},"html":{"ref":"https://example.jiveon.com/","allowed":["GET"]}},"id":"1065"}]}';
        }                
        if(JSONContent.contains('{"errors":[{"error":"not found"}]}')) {
            //No Result found   
            System.debug('No Articles Found');                                                                                                      
        } else {
            JSONParser parser = JSON.createParser(JSONContent);
            Map<String,Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(JSONContent); 
            numberOfResults            = 0;//integer.ValueOf(jsonMap.get('total'));
            Integer paginationStart    = 0;//integer.ValueOf(xmlResultNode.getAttribute('start'));
            if(currentPage != NULL)
                paginationList = createPagination(paginationStart, numberOfResults, MAX_PAGE_SIZE, currentPage);
            if(jsonMap.containsKey('links')) {
                Map<String,Object> jsonInrMap = (Map<String, Object>)jsonMap.get('links');
                if(jsonInrMap.containsKey('next')) { hasNextPage = true; nextIndex = startIndex +MAX_PAGE_SIZE;}
                if(jsonInrMap.containsKey('previous')) { hasPrevPage = true; prevIndex = startIndex-MAX_PAGE_SIZE; }
            }
            List<Object> jsonResults = (List<Object>) jsonMap.get('list'); 
            System.debug('results==>' + jsonResults.size());
            this.results = parseJiveDom(jsonResults);           
        }                                                
    }

    public void confCategorySpecificResults(HTTPResponse res) {
        System.Debug('CAT SPECIFIC RESULTS');
        results = new List<resultelement>();
        string confluence_results = res.getBody();
        String JSONContent = res.getBody();
        System.debug(JSONContent);        
        if(Test.isRunningTest()) {
            JSONContent = '{"results":[{"id":2359734,"title":"Preview a Landing Page with Dynamic Content (Landing Pages)","bodyTextHighlights":"Use Dynamic Content in a Landing Page Preview a Landing Page Preview your landing page after adding dynamic content in order to verify. Select a landing page and click…","url":"/pages/viewpage.action?pageId=2359734&src=search","searchResultContainer":{"name":"Marketo Docs","url":"/display/DOCS"},"friendlyDate":"Sep 25, 2014","contentType":"page","metadata":{}},{"id":2359732,"title":"Use Dynamic Content in a Landing Page (Landing Pages)","bodyTextHighlights":"Create a Segmentation Create a Landing Page Add a New Form to a Landing Page Using Dynamic Content in Landing Pages engages your leads with targeted information. Add…","url":"/pages/viewpage.action?pageId=2359732&src=search","searchResultContainer":{"name":"Marketo Docs","url":"/display/DOCS"},"friendlyDate":"Jan 20, 2015","contentType":"page","metadata":{}},{"id":2359710,"title":"Approve, Unapprove or Delete a Landing Page","bodyTextHighlights":"Landing pages are in draft mode until you approve them. Approval makes pages available in the rest of the system. When you edit an approved landing page, Marketo saves…","url":"/display/DOCS/Approve,+Unapprove+or+Delete+a+Landing+Page?src=search","searchResultContainer":{"name":"Marketo Docs","url":"/display/DOCS"},"friendlyDate":"Nov 21, 2014","contentType":"page","metadata":{}},{"id":2359716,"title":"Preview a Landing Page","bodyTextHighlights":"You probably want to see what a landing page you are working on looks like before making it live. Preview a Landing Page Select a landing page and click Preview Page…","url":"/display/DOCS/Preview+a+Landing+Page?src=search","searchResultContainer":{"name":"Marketo Docs","url":"/display/DOCS"},"friendlyDate":"Sep 25, 2014","contentType":"page","metadata":{}},{"id":2359535,"title":"Preview a Landing Page with Dynamic Content","bodyTextHighlights":"Use Dynamic Content in a Landing Page Preview a Landing Page Preview your landing page after adding dynamic content in order to verify. Select a landing page…","url":"/display/DOCS/Preview+a+Landing+Page+with+Dynamic+Content?src=search","searchResultContainer":{"name":"Marketo Docs","url":"/display/DOCS"},"friendlyDate":"Sep 16, 2014","contentType":"page","metadata":{}}],"total":255,"archivedResultsCount":0,"uuid":"ce98f3c0-771c-437b-b1f3-c485b1172a4c","timeSpent":10}';
        }
        if(JSONContent.contains('{"errors":[{"error":"not found"}]}')) {
            //No REsult found   
            System.debug('No Articles Found');                                                                                                      
        } else {
            JSONParser parser = JSON.createParser(JSONContent);
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(JSONContent); 
            numberOfResults            = integer.ValueOf(jsonMap.get('total'));
            Integer paginationStart    = 0;//integer.ValueOf(xmlResultNode.getAttribute('start'));
            system.debug('&& '+paginationStart+numberOfResults+MAX_PAGE_SIZE+currentPage);
            if(currentPage != NULL){
                if(isPagReqd){
                    paginationList = createPagination(paginationStart, numberOfResults, MAX_PAGE_SIZE, currentPage);
                }
             }
            List<Object> jsonResults = new List<Object>();
            if(isPagReqd){
                jsonResults =  (List<Object>) jsonMap.get('results'); 
                this.results = parseConflDom(jsonResults);    
            }
            else{
                results = new List<resultelement>();
                resultelement resultNode = new resultelement();
                Map<String, Object> resMap = (Map<String, Object>)jsonMap.get('body');
                Map<String, Object> resMap2 = new  Map<String, Object>();
                if(resMap != null){
                    resMap2 = (Map<String, Object>) resMap.get('view');
                    resultNode.summary =   GlobalFunctions.getShortBody((String)resMap2.get('value')); 
                }
                Map<String, Object> urlMap = (Map<String, Object>)jsonMap.get('_links');
                if(urlMap != null){
                    resultNode.url = String.ValueOf('https://docs.marketo.com'+urlMap.get('webui'));
                }
                resultNode.title = (string)jsonMap.get('title'); 
                resultNode.sfdc_id = (string)jsonMap.get('id');
                resultNode.typeofchannel = 'Community';
                results.add(resultNode); 
            }
                   
        }                                                
    }
    
    public List<resultelement> parseSolrDom(List<xmldom.element> docNodesList) {
        results = new List<resultelement>();        
        System.debug('Inside parseSolrDom-->' + docNodesList.size());        
        for (xmldom.element docNode:docNodesList) {
            //System.debug('__DOC__'+docNode);
            List<xmldom.element> subNodesList = docNode.getElementsByTagName('str');
            resultelement resultNode = new resultelement();
            for(xmldom.element subNode:subNodesList) {
               String nodeName    = subNode.getAttribute('name'); 
               String nodeContent = subNode.textContent();
               if(nodeName=='sfdcid') {
                   resultNode.sfdc_id = nodeContent;
               } else if (nodeName=='summary'){  
                   resultNode.summary = GlobalFunctions.getShortBody(nodeContent);
               } else if (nodeName=='title'){ 
                   resultNode.title = nodeContent;
               } else if (nodeName=='top_category') {
                   resultNode.top_category = nodeContent;
               } else if (nodeName=='child_category') {
                   resultNode.child_category = nodeContent;
               } else if (nodeName=='lastmodified') {
                   resultNode.lastmodified = DateTime.valueOfGmt(String.valueof(nodeContent).substring(0,10)+' 00:00:00 AM').format('MMMMM d, yyyy');
               } else if (nodeName=='typeofchannel') {
                   if(nodeContent=='Internal') { resultNode.typeofchannel = nodeContent;
                   } else { resultNode.typeofchannel = 'External';}
               }
               System.debug('NodeAdded-->'+nodeName + ' nodeContent->' + nodeContent);
            }
            results.add(resultNode); 
        }
        return results;    
    }
    
    public List<resultelement> parseJiveDom(List<Object> docNodesList) {
        results = new List<resultelement>();        
        for(Object result : docNodesList) {            
            resultelement resultNode = new resultelement();
            Map<String, Object> resMap = (Map<String, Object>) result;    
            Map<String, Object> urlMain = (Map<String, Object>) resMap.get('resources');  
            Map<String,Object> htmlurl = (Map<String, Object>) urlMain.get('html'); 
            if(htmlurl.ContainsKey('ref')){
                resultNode.url = String.ValueOf(htmlurl.get('ref'));
            }                      
            String bodyTextHighlights='';String contentType='';String friendlyDate='';String id=''; String title='';                                                
            resultNode.sfdc_id = String.valueof(resMap.get('id'));            
            resultNode.title = (string)resMap.get('subject');            
            resultNode.typeofchannel = 'External';
            resultNode.lastmodified = '';
            Map<String, Object> docContent = (Map<String, Object>) resMap.get('content');
            if(docContent.containsKey('text')){
                resultNode.summary = GlobalFunctions.getShortBody((String)docContent.get('text'));
            }
            results.add(resultNode); 
        }                        
        return results;    
    }
    
    public List<resultelement> parseConflDom(List<Object> docNodesList) {
        results = new List<resultelement>();        
        for(Object result : docNodesList) {            
            resultelement resultNode = new resultelement();
            Map<String, Object> resMap = (Map<String, Object>) result;                       
            String bodyTextHighlights='';String contentType='';String friendlyDate='';String id=''; String title='';                                                
            resultNode.sfdc_id = String.valueof(resMap.get('id'));
            resultNode.summary = GlobalFunctions.getShortBody((string) resMap.get('bodyTextHighlights'));
            resultNode.url = String.ValueOf('https://docs.marketo.com'+resMap.get('url'));
            system.debug('&&& ' +resultnode.url);
            resultNode.top_category = (string)resMap.get('contentType');
            resultNode.title = (string)resMap.get('title');
            resultNode.typeofchannel = 'Community';
            resultNode.lastmodified = (string)resMap.get('friendlyDate');
            results.add(resultNode); 
        }                        
        return results;    
    }
              
    public class resultelement {
        public String title   {get; set;}
        public String url     {get; set;}
        public String summary {get; set;}
        public String sfdc_id {get; set;}
        public String top_category   {get; set;}
        public String child_category {get;set;}
        public String lastmodified {get;set;}
        public List<String> dataCategories{get;set;}
        public String typeofchannel   {get; set;}
        public Boolean isSelected {get;set;}
    }
    
    public Integer getLastPageNumber(){
        system.debug('numberOfResults, MAX_PAGE_SIZE=>' + numberOfResults + ' ' + MAX_PAGE_SIZE);
        if(numberOfResults == null) numberOfResults  = 0;
        if (math.mod(numberOfResults, MAX_PAGE_SIZE) == 0) {
            return (numberOfResults/MAX_PAGE_SIZE)-1;
        } else {
            return numberOfResults/MAX_PAGE_SIZE;
        }
        //Decimal lastPageNumber = Decimal.valueOf(numberOfResults)/Decimal.valueOf(MAX_PAGE_SIZE));
    }
    
    public List<Integer> createPagination (Integer start, Integer totalResults, Integer pagesize, Integer curPageNo) {
       List<Integer> paginationList = new List<Integer>();
       Integer index;
       for (index=curPageNo-3;index<curPageNo;index+=1) {
           if(index<0) 
               continue;           
           paginationList.add(index);
       }
       paginationList.add(currentPage);
       Integer jindex; 
       for (jindex=curPageNo+1;jindex<=curPageNo+3;jindex+=1) {
           Double maxjIndex = Decimal.valueOf(totalResults)/Decimal.valueOf(pageSize);  
           System.Debug('NUMBERS'+Decimal.valueOf(jindex)+' '+Decimal.ValueOf(maxjIndex));
           if(Decimal.valueOf(jindex) >= Decimal.ValueOf(maxjIndex))
               break;
           
           paginationList.add(jindex);
           System.debug('totalResults/pageSize'+maxjIndex);           
       }          
       return paginationList;  
    }         

    public void doNothing() {
        return;
    }            
    
}