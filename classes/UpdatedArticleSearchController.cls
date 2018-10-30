/*
Name: UpdatedArticleSearchController 
Created Date: 06/05/2012
Major Change Date: 08/20/2014
Second Major Change Date: 22/05/2017
Usage: To search articles and relate them to a case.
*/
public class UpdatedArticleSearchController {
    
    public Integer currResourcePgNum{get; set;}
    public String caseId {get; set;}
    public String searchText {get; set;}
    public String selectedLang {get; set;}
    public Case caseRecord {get;set;}
    public Integer pageNum{get;set;}
    public Source src{get;set;}
    public List<resultelement> jiveResults{get;set;}
    public List<resultelement> docsResults{get;set;}
    public List<resultelement> helpResults{get;set;}
    public List<resultelement> developerResults{get;set;}
    public List<resultelement> mktoCentralResults{get;set;}
    public List<resultelement> results{get;set;}
    public string attachedArticles{get;set;}
    public String solrServerURL = System.label.solrapiurl;
    public String confluencSearchUrl = System.label.Confluence_Search_Url;
    public String jiveSearchUrl = System.label.Jive_Search_URL;
    public String mktoSearchUrl = System.label.MarketoCentralUrl;
    public XMLDom xmlResult;
    public Integer numberOfResults{get;set;}
    public List<Integer> paginationList{get;set;}
    public Integer currentPage{get; set;}
    public Static Integer MAX_PAGE_SIZE = 10;
    public Integer currResourcePageNum{get;set;}        
    public String channelType{get;set;}    
    public String selectedArticleIds{get;set;}
    public CaseArticleSearchLinks__c caStRecord{get;set;}
    public List<ArticleWrap> docsList;
    public string attachedDocs{get;set;}
    public List<ArticleWrap>jiveList;
    public string attachedLinks{get;set;}
    public Boolean hasNextPage{get;set;}
    public Boolean hasPrevPage{get;set;}
    public Integer nextIndex{get;set;}    
    public Integer prevIndex{get;set;}    
    public Integer startIndex{get;set;}   
    public string artTitle{get;set;}
    public Boolean isPagReqd;
    public Boolean searchOption{get;set;}
    public Id caseIdFromConsole{get;set;}
    public String baseUrl{get;set;}
    public Integer counter {get;set;}
    
    public UpdatedArticleSearchController (ApexPages.StandardController controller){        
        jiveResults = new List<resultelement>();
        docsResults= new List<resultelement>();
        developerResults = new List<resultelement>();
        mktoCentralResults = new List<resultelement>();
        helpResults = new List<resultelement>();
        caseIdFromConsole = null;
        selectedArticleIds = '';
        src = new Source();
        src.Nation = true;
        src.Help = true;
        src.Docs = true;
        isPagReqd = true;
        searchOption = false;
        currentPage  = 0;
        numberOfResults  = 0;
        if(!test.isRunningTest()){
            src.Developer=false;
            src.Central=false;
        }
        else{
            src.Developer=true;
            src.Central=true;
        }  
        hasPrevPage = false;
        hasNextPage = false;
        baseUrl = url.getsalesforcebaseurl().toexternalform();
        caStRecord  = new CaseArticleSearchLinks__c();
        channelType  = ApexPages.currentPage().getParameters().get('channelType')!=null?ApexPages.currentPage().getParameters().get('channelType'):'Community';
        startIndex  = ApexPages.currentPage().getParameters().get('startIndex')!=null?Integer.valueof(ApexPages.currentPage().getParameters().get('startIndex')):0;
        currResourcePageNum = 1;
        caseRecord = (Case)controller.getRecord();
        currentPage = ApexPages.currentPage().getParameters().get('page')!=null?integer.valueof(ApexPages.currentPage().getParameters().get('page')):0;
        if(searchText == null) searchText = ApexPages.currentPage().getParameters().get('searchText') != null?ApexPages.currentPage().getParameters().get('searchText'):'';
        String test = System.currentPageReference().getParameters().get('id');
        counter = 3;
        searchKnowledgeRecords();
    }    
    public UpdatedArticleSearchController () { hasPrevPage=false; hasNextPage=false;startIndex=0;MAX_PAGE_SIZE = 10;}    
    public void resourceArticleNext() {
        currResourcePageNum = currResourcePageNum + 1;
    }
    public void resourceArticlePrev() {
        currResourcePageNum = currResourcePageNum - 1;
    }
    
    public PageReference checkBoxCounter(){
        counter = 0;
        if(src.Nation == true)  counter  =1;
        if(src.Docs == true)    counter +=1;
        if(src.Central == true) counter +=1;
        if(src.Developer== true)  counter +=1;
        if(src.Help == true)    counter +=1;
        searchKnowledgeRecords();
        return null;
    }
   
    public PageReference searchKnowledgeRecords() {  
        if(caseIdFromConsole != null && string.isNotBlank(caseIdFromConsole)){
            caseRecord = new Case();
            caseRecord = [Select id from case where id =:caseIdFromConsole];
        }             
        currResourcePageNum = currentPage ;
        Integer caseCount = [select COUNT() from Case where id = :caseRecord.Id];        
        if(caseCount > 0) {
            caseRecord = [select Subject from Case where id = :caseRecord.id];
            if((searchText == null || searchText.Trim() == '' ) && caseRecord.Subject != null)
                searchText = caseRecord.Subject;
            if(searchText == null && caseRecord.Subject == null)
                searchText = '';
        }        
        if(searchText.trim().length() < 2) {
            //ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 'Search text length should be more than one'));
            return null;
        }        
        /* fetch the results from SOlr API */
        // Get the top_categories to be fetched
        list <String> top_categories  = new list<string>{'Resource'};
        string sortByQueryString = '';
        string dCategoryFq       = '';                       
        //create top_categories query
        string top_category_query = '&fq='; 
        system.debug('top_CATEGORIRES_'+top_categories.size()+ ' ' + top_categories);
        if (top_categories.size() > 0) {
            for (String top_category_temp :top_categories) {
                top_category_query += 'top_category:'+top_category_temp+'+';  
            }
        }        
        string encodedURL = '';        
        results = new List<resultelement>();
        jiveResults = new List<resultelement>();
        mktoCentralResults = new List<resultelement>();
        docsResults = new List<resultelement>();
        developerResults = new List<resultelement>();
        HTTPResponse response = new HTTPResponse();
        if(src.Docs){    
            String srch = searchText;
                if(searchText.Contains('docs.marketo.com') && !searchText.Contains('?pageId=')){
                    isPagReqd = true;
                    srch = srch.Substring(srch.IndexOf('DOCS/')+5);
                    srch = srch.replace('+',' ');
                    encodedURL  = confluencSearchUrl + EncodingUtil.urlEncode('\"'+ srch + '\"', 'UTF-8') + '&where=DOCS&type=page&user=&pageSize='+MAX_PAGE_SIZE+'&highlight=false&sessionUuid=0-0-0-0&startIndex='+(currentPage*MAX_PAGE_SIZE);
                    response = makeAPIRequest(encodedURL,'');                    
                }
                else if(searchText.Contains('docs.marketo.com') && searchText.Contains('?pageId=')){
                        srch = srch.substring(srch.indexof('pageId=')+7);
                        encodedURL  = 'https://docs.marketo.com/rest/api/content/'+srch+'?expand=body.view';
                        isPagReqd = false;
                        response = makeAPIRequest(encodedURL,''); 
                }
                else{
                    isPagReqd = true;
                    if(searchOption){
                        encodedURL  = confluencSearchUrl + EncodingUtil.urlEncode('\"'+srch+'\"', 'UTF-8') + '&where=DOCS&type=page&user=&pageSize='+MAX_PAGE_SIZE+'&highlight=false&sessionUuid=0-0-0-0&startIndex='+(currentPage*MAX_PAGE_SIZE);
                    }
                    else{
                        encodedURL  = confluencSearchUrl + EncodingUtil.urlEncode(srch, 'UTF-8') + '&where=DOCS&type=page&user=&pageSize='+MAX_PAGE_SIZE+'&highlight=false&sessionUuid=0-0-0-0&startIndex='+(currentPage*MAX_PAGE_SIZE);
                    }
                    response = makeAPIRequest(encodedURL,'');
                }
                if(response != null){
                   confCategorySpecificResults(response);
                   createConfWrapper();
                } 
        } 
        if(src.Nation){
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
                        encodedUrl = jiveSearchUrl + '(' + EncodingUtil.urlEncode('\"'+searchText+'\"', 'UTF-8')+')' +'&abridged=false&count='+MAX_PAGE_SIZE+'&startIndex='+startIndex;   
                    }
                    else{
                        encodedUrl = jiveSearchUrl + '(' + EncodingUtil.urlEncode(searchText, 'UTF-8')+')' +'&abridged=false&count='+MAX_PAGE_SIZE+'&startIndex='+startIndex;      
                    }                   
                    response = makeAPIRequest(encodedURL,'');
                }
                if(response != null){
                   jiveCategorySpecificResults(response);
                   createJiveWrapper();
                }
        }
        if(src.Central){
            if(searchText.Contains('marketoemployee') && searchText.Contains('DOC-')){
                String srch = searchText;
                srch = srch.substring(srch.indexof('DOC-')+4);
                srch = srch.substring(0,4);
                Integer docId = Integer.ValueOf(srch);
                encodedURL  =  'https://marketoemployee.jiveon.com/api/core/v3/search/contents?filter=entityDescriptor(102,'+docId+')&pageSize='+MAX_PAGE_SIZE+'&highlight=false&sessionUuid=0-0-0-0&startIndex='+(currentPage*MAX_PAGE_SIZE);
                response = makeAPIRequest(encodedURL,''); 
            }
            else{
                if(searchOption){
                    encodedUrl = mktoSearchUrl + '(' + EncodingUtil.urlEncode('\"'+searchText+'\"', 'UTF-8')+')' +'&abridged=false&count='+MAX_PAGE_SIZE+'&startIndex='+startIndex;   
                }
                else{
                    encodedUrl = mktoSearchUrl + '(' + EncodingUtil.urlEncode(searchText, 'UTF-8')+')' +'&abridged=false&count='+MAX_PAGE_SIZE+'&startIndex='+startIndex;      
                }                   
                response = makeAPIRequest(encodedURL,String.ValueOf(label.mktoCentralCredentials));
            }
            if(response != null){
               marketoCentralSpecificResults(response);
               //createCentralWrapper();
            }
        } 
        if(src.Developer){
           if(searchOption){
                encodedUrl = label.Developer + EncodingUtil.urlEncode('\"'+searchText+'\"', 'UTF-8')+'' +'&engine_key=zcW4zxTVviMt78GM3KPC&document_types%5B%5D=posts&per_page='+MAX_PAGE_SIZE+'&current_page='+startIndex;      
               response = makeAPIRequest(encodedURL,'');
           }
           else{
               encodedUrl = label.Developer + EncodingUtil.urlEncode(searchText, 'UTF-8')+'' +'&engine_key=zcW4zxTVviMt78GM3KPC&document_types%5B%5D=posts&per_page='+MAX_PAGE_SIZE+'&current_page='+startIndex;      
               response = makeAPIRequest(encodedURL,'');
           }
            if(response != null){
                developerSpecificResults(response);
                createConfWrapper();
            }
        }
        if(src.Help){
           if(searchOption){
                   
               encodedUrl = 'https://marketo2049.zendesk.com/api/v2/help_center/articles/search.json?query='+EncodingUtil.urlEncode('\"'+searchText+'\"', 'UTF-8')+'&per_page=10';
               system.debug('@@Help ' +encodedUrl);
               response = makeAPIRequest(encodedURL,'');
           }
           else{
               encodedUrl = 'https://marketo2049.zendesk.com/api/v2/help_center/articles/search.json?query='+EncodingUtil.urlEncode(searchText, 'UTF-8')+'&per_page=10';
               response = makeAPIRequest(encodedURL,'');
           }
           if(response != null){
                helpSpecificResults(response);
                createConfWrapper();
            }
        }  
                                                           
        return null;
    }
    
   
    public void createJiveWrapper(){
       List<Case_Confluence_Article__c> jiveLst = new List<Case_Confluence_Article__c>();
       if(caseIdFromConsole != null && string.isNotBlank(caseIdFromConsole)){
            jiveLst = [select Case__c, DocsUrlLink__c from Case_Confluence_Article__c where isJiveArticle__c = true AND Case__c = :caseIdFromConsole];
       }
       else{
           jiveLst = [select Case__c, DocsUrlLink__c from Case_Confluence_Article__c where isJiveArticle__c = true AND Case__c = :caseRecord.id];
       }
        attachedLinks = '__';
        for(Case_Confluence_Article__c ca :jiveLst) {            
            attachedLinks += ca.DocsUrlLink__c+'__';
        }               
        System.Debug('attachedDocs+++++'+attachedLinks);        
    } 
    public void createCentralWrapper(){
       List<Case_Confluence_Article__c> jiveLst = new List<Case_Confluence_Article__c>();
       if(caseIdFromConsole != null && string.isNotBlank(caseIdFromConsole)){
            jiveLst = [select Case__c, DocsUrlLink__c from Case_Confluence_Article__c where isJiveArticle__c = true AND Case__c = :caseIdFromConsole];
       }
       else{
           jiveLst = [select Case__c, DocsUrlLink__c from Case_Confluence_Article__c where isJiveArticle__c = true AND Case__c = :caseRecord.id];
       }
        attachedLinks = '__';
        for(Case_Confluence_Article__c ca :jiveLst) {            
            attachedLinks += ca.DocsUrlLink__c+'__';
        }               
        System.Debug('attachedDocs+++++'+attachedLinks);        
    }        
    public void createConfWrapper(){
        List<Case_Confluence_Article__c> confList = new List<Case_Confluence_Article__c>();
        if(caseIdFromConsole != null && string.isNotBlank(caseIdFromConsole)){
            confList = [select Case__c, DocsUrlLink__c from Case_Confluence_Article__c where isJiveArticle__c = false AND Case__c = :caseIdFromConsole];
        }
        else{
             confList = [select Case__c, DocsUrlLink__c from Case_Confluence_Article__c where isJiveArticle__c = false AND Case__c = :caseRecord.id];
        }
        attachedDocs = '__';                           
        for(Case_Confluence_Article__c ca :confList) {
            attachedDocs += ca.DocsUrlLink__c+'__';
        }
        System.Debug('attachedDocs+++++'+attachedDocs);               
    }
    
    public void refreshWrapper(){
        searchKnowledgeRecords();                   
    }      
    
     public void attachArticles() {             
        try {
            List<Case_Confluence_Article__c> chkRecords = new List<Case_Confluence_Article__c>();
            Boolean isJiveArticle = false;
            String uniqueUrl = ''; 
            if(selectedArticleIds == 'Nation' && jiveResults[0].url !='' && jiveResults[0].title !=''){
                uniqueUrl = jiveResults[0].url+'_'+jiveResults[0].title;
                isJiveArticle = true;
            }
            else if(selectedArticleIds == 'Docs' && docsResults[0].url !='' && docsResults[0].title !=''){
                uniqueUrl = docsResults[0].url+'_'+docsResults[0].title;
            }
            else if(selectedArticleIds == 'Developer' && developerResults[0].url !='' && developerResults[0].title !=''){
                uniqueUrl = developerResults[0].url+'_'+developerResults[0].title;
            }
            else if(selectedArticleIds == 'Central' && mktoCentralResults[0].url !='' && mktoCentralResults[0].title !=''){
                uniqueUrl = mktoCentralResults[0].url+'_'+mktoCentralResults[0].title;
            }
            
            if(caseIdFromConsole != null && string.isNotBlank(caseIdFromConsole)){
                chkRecords = [SELECT ID,Unique_url_id__c From Case_Confluence_Article__c Where Case__c =:caseIdFromConsole AND Unique_url_id__c = : uniqueUrl AND isJiveArticle__c = :isJiveArticle Limit 1];
            }
            else{
                chkRecords = [SELECT ID,Unique_url_id__c From Case_Confluence_Article__c Where Case__c =:caseRecord.id AND Unique_url_id__c = : uniqueUrl AND isJiveArticle__c = :isJiveArticle Limit 1];
            }
            System.debug('!!!!!!!a'+chkRecords);
            Case_Confluence_Article__c caRecord = new Case_Confluence_Article__c();
                if(chkRecords.isEmpty()){
                    if(caseIdFromConsole != null && string.isNotBlank(caseIdFromConsole)){
                        caRecord.Case__c = caseIdFromConsole;
                    }
                    else{
                        caRecord.Case__c = caseRecord.id;
                    }
                    caRecord.isJiveArticle__C = isJiveArticle;
                    if(uniqueUrl !=''){
                        caRecord.Unique_url_id__c = uniqueUrl;
                    }
                    if(selectedArticleIds == 'Nation' &&jiveResults[0].url !='' ){
                        caRecord.DocsUrlLink__c = jiveResults[0].url;
                    }
                    if(selectedArticleIds == 'Docs' &&docsResults[0].url !='' ){
                        caRecord.DocsUrlLink__c = docsResults[0].url;
                    }
                    if(selectedArticleIds == 'Developer' &&developerResults[0].url !='' ){
                        caRecord.DocsUrlLink__c = developerResults[0].url;
                    }
                    if(selectedArticleIds == 'Central' &&mktoCentralResults[0].url !='' ){
                        caRecord.DocsUrlLink__c = mktoCentralResults[0].url;
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
            List<Case_Confluence_Article__c> caList = new List<Case_Confluence_Article__c>();
            Boolean isJiveArticle = false;
            String uniqueUrl = '';
            if(selectedArticleIds == 'Nation' && jiveResults[0].url !='' && jiveResults[0].title !=''){
                uniqueUrl = jiveResults[0].url+'_'+jiveResults[0].title;
                isJiveArticle = true;
            }
            else if(selectedArticleIds == 'Docs' && docsResults[0].url !='' && docsResults[0].title !=''){
                uniqueUrl = docsResults[0].url+'_'+docsResults[0].title;
            }
            else if(selectedArticleIds == 'Developer' && developerResults[0].url !='' && developerResults[0].title !=''){
                uniqueUrl = developerResults[0].url+'_'+developerResults[0].title;
            }
            else if(selectedArticleIds == 'Central' && mktoCentralResults[0].url !='' && mktoCentralResults[0].title !=''){
                uniqueUrl = mktoCentralResults[0].url+'_'+mktoCentralResults[0].title;
            }
            if(caseIdFromConsole != null && string.isNotBlank(caseIdFromConsole)){
                 caList = [SELECT ID,Unique_url_id__c From Case_Confluence_Article__c Where Case__c =:caseIdFromConsole AND Unique_url_id__c = : uniqueUrl AND isJiveArticle__c = :isJiveArticle Limit 1];
            }
            else{
                caList = [SELECT ID,Unique_url_id__c From Case_Confluence_Article__c Where Case__c =:caseRecord.id AND Unique_url_id__c = : uniqueUrl AND isJiveArticle__c = :isJiveArticle Limit 1];
            }
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
        req.setEndPoint(encodedURL);
        req.setMethod('GET');
        Http http = new Http();
        if(authString != ''){
            Blob headerValue = Blob.valueOf(authString);
            String authorizationHeader = 'Basic ' +
            EncodingUtil.base64Encode(headerValue);
            req.setHeader('Authorization', authorizationHeader);
            req.setHeader('content-type', 'application/json');
            req.setHeader('Accept', 'application/json');   
        }             
        if(!Test.isRunningTest()){
            req.setTimeout(25000);
            response  = http.send(req);
            system.Debug('REQUEST'+req);
            if(response.getStatus() == 'OK') {
                return response;
            } else {
                return null;
            }
        } else {
            response = new HTTPResponse();                        
            if(authString != '') //jive search test result
                response.setBody('{"itemsPerPage":5,"links":{"next":"https://nation.marketo.com/api/core/v3/search/contents?collapse=false&sort=relevanceDesc&fields=subject%2Cid%2Ccontent&filter=type%28document%29&filter=search%28landing%29&origin=unknown&highlight=false&socialSearch=false&returnScore=false&count=5&startIndex=10"},"list":[{"id":"1124","resources":{"versions":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/versions/1261"},"html":{"allowed":["GET"],"ref":"https://nation.marketo.com/docs/DOC-1124"}},"index":"0","uuid":"97b7eb32-df87-4c55-b074-44d1fe3480e5","content":{"text":"<body><div><p><span>This course on Marketo Landing Page templates walks you through the creation of a custom landing page template.</span></p></div></body>","editable":false,"type":"text/html"},"subject":"Advanced Landing Page Template Development","type":"document"},{"id":"1194","resources":{"versions":{"allowed":["GET"],"ref" : "https://nation.marketo.com/api/core/v3/versions/1393"},"html":{"allowed":["GET"],,"ref" : "https://nation.marketo.com/docs/DOC-1194"}},"index":"1","content":{"text":"<body><div><p><span>Here is a list of all the ways leads can get into Marketo.</span></p></div></body>","editable":false,"type":"text/html"},"subject":"How Do Leads Get Into Marketo?","type":"document"},{"id":"1210","resources":{"versions":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/versions/1432"},"html":{"allowed":["GET"],"ref":"https://nation.marketo.com/docs/DOC-1210"}},"index":"2","content":{"text":"<body><div><p><span><strong>Issue:</strong></span></p></div></body>", "editable":false,"type":"text/html"},"subject":"Content in Landing Page not staying in position","type":"document"},{"id":"1286","resources":{"versions":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/versions/1543"},"html":{"allowed":["GET"],"ref":"https://nation.marketo.com/docs/DOC-1286"}},"index":"3","content":{"text":"<body><div><p>This standard landing page template was submitted by Marketo customer Veeam.This is a customer submitted template that has not been modified by Marketo.It is recommended that you have an HTML proficient person edit and fine tune the code before using.</div></body>","editable":false,"type":"text/html"},"subject":"Standard Landing Page Template: Veeam","type":"file"},{"id":"1094","resources":{"versions":{"allowed":["GET"],"ref":"https://nation.marketo.com/api/core/v3/versions/1284"},"html":{"allowed":["GET"],"ref":"https://nation.marketo.com/docs/DOC-1094"}},"index":"4","content":{"text":"<body><div><h3><span><strong>Question</strong></span></h3></div></body>","editable":false,"type":"text/html"},"subject":"How to remove Munchkin from landing pages","type":"document"}],"startIndex":5}');
            else //docs search test result
                response.setBody('{"results":[{"id":2359734,"title":"Preview a Landing Page with Dynamic Content (Landing Pages)","bodyTextHighlights":"Use Dynamic Content in a Landing Page Preview a Landing Page Preview your landing page after adding dynamic content in order to verify. Select a landing page and click…","url":"/pages/viewpage.action?pageId=2359734&src=search","searchResultContainer":{"name":"Marketo Docs","url":"/display/DOCS"},"friendlyDate":"Sep 25, 2014","contentType":"page","metadata":{}},{"id":2359732,"title":"Use Dynamic Content in a Landing Page (Landing Pages)","bodyTextHighlights":"Create a Segmentation Create a Landing Page Add a New Form to a Landing Page Using Dynamic Content in Landing Pages engages your leads with targeted information. Add…","url":"/pages/viewpage.action?pageId=2359732&src=search","searchResultContainer":{"name":"Marketo Docs","url":"/display/DOCS"},"friendlyDate":"Jan 20, 2015","contentType":"page","metadata":{}},{"id":2359710,"title":"Approve, Unapprove or Delete a Landing Page","bodyTextHighlights":"Landing pages are in draft mode until you approve them. Approval makes pages available in the rest of the system. When you edit an approved landing page, Marketo saves…","url":"/display/DOCS/Approve,+Unapprove+or+Delete+a+Landing+Page?src=search","searchResultContainer":{"name":"Marketo Docs","url":"/display/DOCS"},"friendlyDate":"Nov 21, 2014","contentType":"page","metadata":{}},{"id":2359716,"title":"Preview a Landing Page","bodyTextHighlights":"You probably want to see what a landing page you are working on looks like before making it live. Preview a Landing Page Select a landing page and click Preview Page…","url":"/display/DOCS/Preview+a+Landing+Page?src=search","searchResultContainer":{"name":"Marketo Docs","url":"/display/DOCS"},"friendlyDate":"Sep 25, 2014","contentType":"page","metadata":{}},{"id":2359535,"title":"Preview a Landing Page with Dynamic Content","bodyTextHighlights":"Use Dynamic Content in a Landing Page Preview a Landing Page Preview your landing page after adding dynamic content in order to verify. Select a landing page…","url":"/display/DOCS/Preview+a+Landing+Page+with+Dynamic+Content?src=search","searchResultContainer":{"name":"Marketo Docs","url":"/display/DOCS"},"friendlyDate":"Sep 16, 2014","contentType":"page","metadata":{}}],"total":255,"archivedResultsCount":0,"uuid":"ce98f3c0-771c-437b-b1f3-c485b1172a4c","timeSpent":10}');
            return response;        
        }
    }       
    
    public void jiveCategorySpecificResults(HTTPResponse res){
        system.Debug('CAT SPECIFIC RESULTS');
        jiveResults = new List<resultelement>();
        string confluence_results = res.getBody();
        String JSONContent = res.getBody(); 
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
            if(currentPage != NULL) paginationList = createPagination(paginationStart, numberOfResults, MAX_PAGE_SIZE, currentPage);
            if(jsonMap.containsKey('links')) {
                Map<String,Object> jsonInrMap = (Map<String, Object>)jsonMap.get('links');
                if(jsonInrMap.containsKey('next')) { hasNextPage = true; nextIndex = startIndex +MAX_PAGE_SIZE;}
                if(jsonInrMap.containsKey('previous')) { hasPrevPage = true; prevIndex = startIndex-MAX_PAGE_SIZE; }
            }
            List<Object> jsonResults = (List<Object>) jsonMap.get('list'); 
            System.debug('results==>' + jsonResults.size());
            this.jiveResults = parseJiveDom(jsonResults); 
            System.debug('jiveResults==>' + this.jiveResults);       
        }                                                
    }
    public void marketoCentralSpecificResults(HTTPResponse res){
        system.Debug('marketoCentralSpecificResultsSPECIFIC RESULTS');
        mktoCentralResults = new List<resultelement>();
        string confluence_results = res.getBody();
        String JSONContent = res.getBody(); 
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
            this.mktoCentralResults = parseCentralDom(jsonResults);           
        }                                                
    }

     public void confCategorySpecificResults(HTTPResponse res) {
        System.Debug('CAT SPECIFIC RESULTS');
        results = new List<resultelement>();
        docsResults = new List<resultelement>();
 
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
                    paginationList = createPagination(paginationStart, numberOfResults, MAX_PAGE_SIZE, currentPage);
                    List<Object> jsonResults = (List<Object>) jsonMap.get('results'); 
                    System.debug('results==>' + jsonResults.size());
                    this.docsResults = parseConflDom(jsonResults);
                    system.debug('docsResults---->>>>'+docsResults);           
                                                                
                if(isPagReqd){
                    paginationList = createPagination(paginationStart, numberOfResults, MAX_PAGE_SIZE, currentPage);
                }
             }
            List<Object> jsonResults = new List<Object>();
            if(isPagReqd){
                jsonResults =  (List<Object>) jsonMap.get('results'); 
                this.docsResults = parseConflDom(jsonResults);    
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
                docsResults.add(resultNode); 
            }         
        }                                                
    }
    
    public void developerSpecificResults(HTTPResponse res) {
        results = new List<resultelement>();
        developerResults = new List<resultelement>();
        string confluence_results = res.getBody();
        String JSONContent = res.getBody();        
        if(Test.isRunningTest()){
            JSONContent = '{"record_count":10,"records":{"posts":[{"timestamp":"2016-06-30T21:02:43Z","tags":null,"object_type":"page","body":"Sales Person Endpoint","id":"123","title":"test","url":"www.test.com","updated_at":"2016-06-30T21:02:43Z"}]}}';
        }
        if(JSONContent.contains('{"errors":[{"error":"not found"}]}')) {
            //No REsult found   
            System.debug('No Articles Found');                                                                                                      
        } else {
            JSONParser parser = JSON.createParser(JSONContent);
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(JSONContent); 
            //system.debug('Dev jsonMap==>>'+jsonMap);
            numberOfResults            = integer.ValueOf(jsonMap.get('total_result_count'));
            Integer paginationStart    = 0;
            if(currentPage != NULL){}
                //paginationList = createPagination(paginationStart, numberOfResults, MAX_PAGE_SIZE, currentPage);
            Map<String, Object> jsonMap2 = (Map<String, Object>) jsonMap.get('records');
            List<Object> jsonResults = (List<Object>) jsonMap2.get('posts'); 
            this.developerResults = parseDeveloperDom(jsonResults);      
        }                                                
    }
    public void helpSpecificResults(HTTPResponse res) {
        results = new List<resultelement>();
        helpResults = new List<resultelement>();
        string confluence_results = res.getBody();
        String JSONContent = res.getBody();        
        if(Test.isRunningTest()){
            JSONContent = '{"record_count":10,"records":{"posts":[{"timestamp":"2016-06-30T21:02:43Z","tags":null,"object_type":"page","body":"Sales Person Endpoint","id":"123","title":"test","url":"www.test.com","updated_at":"2016-06-30T21:02:43Z"}]}}';
        }
        if(JSONContent.contains('{"errors":[{"error":"not found"}]}')) {
            //No REsult found   
            System.debug('No Articles Found');                                                                                                      
        } else {
            JSONParser parser = JSON.createParser(JSONContent);
            Map<String, Object> jsonMap = (Map<String, Object>)JSON.deserializeUntyped(JSONContent); 
            if(jsonMap.ContainsKey('results')){
                 List<Object> jsonResults = (List<Object>) jsonMap.get('results'); 
                 this.helpResults = parseHelpDom(jsonResults);    
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
        jiveResults = new List<resultelement>();        
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
                system.debug('aman ' +resultNode.summary);
            }
            jiveResults.add(resultNode); 
        }                        
        return jiveResults;    
    }
    public List<resultelement> parseCentralDom(List<Object> docNodesList) {
        results = new List<resultelement>();
        mktoCentralResults = new List<resultelement>();        
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
                system.debug('aman ' +resultNode.summary);
            }
            mktoCentralResults.add(resultNode); 
        }                        
        return mktoCentralResults;    
    }
    
    public List<resultelement> parseConflDom(List<Object> docNodesList) {
        results = new List<resultelement>();  
        docsResults = new List<resultelement>();       
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
            artTitle = resultNode.title;
            resultNode.typeofchannel = channelType;
            resultNode.lastmodified = (string)resMap.get('friendlyDate');
            docsResults.add(resultNode); 
        }                        
        return docsResults;    
    }
    
    public List<resultelement> parseDeveloperDom(List<Object> docNodesList) {
        developerResults = new List<resultelement>();       
        for(Object result : docNodesList) {            
            resultelement resultNode = new resultelement();
            Map<String, Object> resMap = (Map<String, Object>) result;                                                                   
            resultNode.sfdc_id = String.valueof(resMap.get('id'));
            resultNode.summary = GlobalFunctions.getShortBody((string) resMap.get('body'));
            resultNode.title = (string)resMap.get('title');
            resultNode.url = (string)resMap.get('url');
            resultNode.typeofchannel = 'Developer';
            resultNode.lastmodified = (string)resMap.get('updated_at');
            developerResults.add(resultNode); 
        }                        
        return developerResults ;    
    }
    public List<resultelement> parseHelpDom(List<Object> docNodesList) {
        results = new List<resultelement>();  
        HelpResults = new List<resultelement>();       
        for(Object result : docNodesList){ 
            resultelement resultNode = new resultelement();
            Map<String, Object> resMap = (Map<String, Object>) result; 
            if(resMap.ContainsKey('html_url')){
                resultNode.url = (string)resMap.get('html_url');
                system.debug('######Url ' +resultNode.url);
            }
            if(resMap.ContainsKey('title')){
                system.debug(resMap.get('title'));
                resultNode.title = (string)resMap.get('title');
            }
            if(resMap.ContainsKey('body')){
                system.debug(GlobalFunctions.getShortBody((String)resMap.get('body')));
                resultNode.summary = GlobalFunctions.getShortBody((string) resMap.get('body'));
            }
            resultNode.typeofchannel = 'Help';                                                        
            //resultNode.sfdc_id = String.valueof(resMap.get('id'));
            HelpResults.add(resultNode); 
        }                        
        return HelpResults;    
    }
              
    public class resultelement{
        public String title                {get; set;}
        public String url                  {get; set;}
        public String summary              {get; set;}
        public String sfdc_id              {get; set;}
        public String top_category         {get; set;}
        public String child_category       {get; set;}
        public String lastmodified         {get; set;}
        public List<String> dataCategories {get; set;}
        public String typeofchannel        {get; set;}
        public Boolean isSelected          {get; set;}
    }
    
    public class Source {
        public boolean Nation    {get; set;}
        public boolean Docs      {get; set;}
        public boolean Developer {get; set;}
        public boolean Central   {get; set;}
        public boolean Help      {get; set;}
    }
    
    public Integer getLastPageNumber(){
        system.debug('numberOfResults, MAX_PAGE_SIZE=>' + numberOfResults + ' ' + MAX_PAGE_SIZE);
        if(numberOfResults == null) numberOfResults  = 0;
        if (math.mod(numberOfResults, MAX_PAGE_SIZE) == 0) {
            return (numberOfResults/MAX_PAGE_SIZE)-1;
        } else {
            return numberOfResults/MAX_PAGE_SIZE;
        }
    }
    
    public List<Integer> createPagination(Integer start, Integer totalResults, Integer pagesize, Integer curPageNo) {
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