public class SolrMarketoSuppCaseCreateSrchCntlr {

    public XMLDom xmlResult;
    public List<resultElement> results{get;set;}
    public String searchText{get;set;}
    public Integer numberOfResults{get;set;}
    public List<Integer> paginationList{get;set;}
    public Integer currentPage{get; set;}
    public String sortBy{get;set;}
    public String solrServerURL = System.label.solrapiurl;
 
    public List<resultElement> knbResults{get;set;}
    public List<resultElement> discussionResults{get;set;}

    public List<resultElement> resResults{get;set;}
    
    public boolean showMoreKnb{get;set;}
    public boolean showMoreDiscussion{get;set;}
    public boolean showMoreRes{get;set;}
    
    public String  genericPageSize = '4';
    
    public SolrMarketoSuppCaseCreateSrchCntlr() {
        searchText= (ApexPages.currentPage().getParameters().get('searchText') != null)?ApexPages.currentPage().getParameters().get('searchText'):'';
        System.Debug('searchText++++++++++'+searchText);
    }
        
    public PageReference initialize() {
      searchText         = (ApexPages.currentPage().getParameters().get('searchText') != null)?ApexPages.currentPage().getParameters().get('searchText'):'';
      String dCategoryFq = (ApexPages.currentPage().getParameters().get('dcategory') != null && ApexPages.currentPage().getParameters().get('dcategory') != '')?'&fq=dcategory:'+EncodingUtil.urlEncode(ApexPages.currentPage().getParameters().get('dcategory'),'UTF-8'):'';      
      if(searchText == '') {searchText='*:*';}
      
      String top_category = (ApexPages.currentPage().getParameters().get('top_category') != null)?ApexPages.currentPage().getParameters().get('top_category'):'';
      sortBy              = (ApexPages.currentPage().getParameters().get('sortby') != null)?ApexPages.currentPage().getParameters().get('sortby'):'';
      String getResults   =  ApexPages.currentPage().getParameters().get('get_results') != null?ApexPages.currentPage().getParameters().get('get_results'):'';
      System.Debug('SORTBY--'+sortBy+'');
      String sortByQueryString = '';
      if(sortBy == 'lastmodified') {
          sortByQueryString = '&sort=lastmodified+desc';
      } else if (sortBy == 'viewcount') {
          sortByQueryString = '&sort=viewcount+desc';
      }      
      String sortByForProfiles = '&sort=lastmodified+desc';      
      if (top_category == 'all') {
          List <String>top_categories  = new List<String>{'&fq=top_category:Article+top_category:Tutorial+top_category:Video+top_category:Deepdive', '&fq=top_category:Discussion', '&fq=top_category:Resource'};  
          String SolrApiUrl  =  solrServerURL+'/select?userType='+userinfo.getUserType()+'&userId='+userinfo.getUserId()+'&fl=lastmodified,sfdcid,title,top_category,child_category&indent=on&version=2.2&facet=on&facet.field=top_category&start=0&rows='+genericPageSize+'&';
          Map<String, HTTPResponse> categoryReponseMap = new Map<String,HTTPResponse>();
          for (String top_category_temp:top_categories) {
            String encodedURL = '';
            if (searchText != '*:*') {
               encodedURL = SolrApiUrl + 'defType=dismax&pf=keywords^500.0&qf=keywords+title^8.0+summary^6.0+body^4.0&q='+EncodingUtil.urlEncode(searchText, 'UTF-8')+''+sortByQueryString+top_category_temp+dCategoryFq;
            } else {
               encodedURL = SolrApiUrl + 'q='+searchText+''+sortByQueryString+top_category_temp+dCategoryFq;
            }
            
            //sops-60
            if(System.Label.SolrIsTypeofChannelSet == 'True')            
            encodedURL += '&fq=-typeofchannel:Internal'+'&';      
              
            categoryReponseMap.put(top_category_temp, makeAPIRequest(encodedURL));
            //system.debug('categoryRespondingMap==>' + categoryReponseMap);
            if (categoryReponseMap.get(top_category_temp) == null) {
                notifySolrDownEvent();                
                return null;
            }
          }
          getGenericResults(top_categories, categoryReponseMap);        
       }       
       return null;       
    }
    
    public void notifySolrDownEvent(){ //__TEMPORARY_FUNCTION_TO_MONITOR_SOLR_DOWN_EVENT__
        Solr_Status__c solrStatus = [Select Name,IsSolrDown__c from Solr_Status__c Limit 1];
        if(solrStatus.IsSolrDown__c == false){
            try{
                Messaging.SingleEmailMessage solrBreakDownEmail  = new Messaging.SingleEmailMessage();
                String[] emailRecipient = new String[]{'vishals@grazitti.com'};
                solrBreakDownEmail.setToAddresses(emailRecipient);
                solrBreakDownEmail.setReplyTo('vishals@grazitti.com');
                solrBreakDownEmail.setSenderDisplayName('Marketo- SOLR IS DOWN ');
                solrBreakDownEmail.setSubject('Solr Is Down Please Fix It ASAP');
                solrBreakDownEmail.setHtmlBody('Dear Administrator, Solr is down and flag "Is Solr Down" is set to true. ,So as to recieve mails of further breakdowns<br /><br /> Thanks<br />Grazitti Interactive');
                Messaging.sendEmail(new Messaging.Email[] { solrBreakDownEmail  });
                solrStatus.IsSolrDown__c = true;
                update solrStatus;
                }
            catch(EmailException e){
                System.debug(e.getMessage());
            }
        }
    }
        
    public HTTPResponse makeAPIRequest(String encodedURL) {
        HTTPResponse response;
        HttpRequest req  = new HttpRequest();
        req.setEndPoint(encodedURL );
        req.setMethod('GET');
        Http http = new Http();
        req.setClientCertificateName('MktoCommunityProd');
        
        if (!Test.isRunningTest()) {
            response  = http.send(req);
            System.Debug('REQUESTISTHERE'+req);
            if (response.getStatus() == 'OK') {
                System.debug('RESPONSEISTHERE'+response);
                return response;
            } else {
                return null;
            }
        } else {
            response = new HTTPResponse();
            response.setBody('<?xml version="1.0" encoding="UTF-8"?><response><lst name="responseHeader"><int name="status">0</int><int name="QTime">0</int><lst name="params"><str name="fl">sfdcid,type,title,body,summary,lastmodified,top_category</str><str name="q">*:*</str><arr name="fq"><str>top_category:Idea</str><str>sfdcid:087W00000004GG2IAM</str></arr></lst></lst><result name="response" numFound="1" start="0"><doc><str name="sfdcid">087W00000004GG2IAM</str><str name="title">Test Idea</str><str name="summary">Test Idea</str><str name="body">Testing comments on ideas! Test Comment2 Test Comment Test Comment 12_02_13 </str><str name="lastmodified">2013-02-12T12:45:23.000Z</str><str name="top_category">Idea</str></doc></result></response>');
            return response;        
        }
    }
    
    public void getGenericResults(List<String> top_categories, Map<String,HTTPResponse> res){
        results = new List<resultElement>();

        // Get the top_categories to be fetched
        knbResults                = new List<resultElement>();
        discussionResults         = new List<resultElement>();
        resResults                = new List<resultElement>();
        
        for(String top_category:top_categories) {
            results = new List<resultElement>();
            string solr_results = res.get(top_category).getBody();
            //System.debug('LWE_results '+solr_results );
            xmlResult = new XMLDom(solr_results );
            //System.debug('dom-->'+xmlResult );
            xmldom.element xmlResultNode = xmlResult.getElementByTagName('result');
            numberOfResults            = integer.ValueOf(xmlResultNode.getAttribute('numFound'));
            Integer paginationStart    = integer.ValueOf(xmlResultNode.getAttribute('start'));
            List<xmldom.element> docNodesList = xmlResultNode.getElementsByTagName('doc');
            results = parseSolrDom(docNodesList);
            System.Debug('TOP_CATEGORY'+top_category);
            if (top_category.contains('Discussion')) {
                discussionResults.addAll(results);
                if(numberOfResults > integer.valueOf(genericPageSize)){
                    showMoreDiscussion = true;
                }               
            } else If(top_category.contains('Resource')) {
                    resResults.addAll(results);
                    if(numberOfResults > integer.valueOf(genericPageSize)){
                        showMoreRes = true;
                    }
            } else{
                    knbResults.addAll(results);
                    if(numberOfResults > integer.valueOf(genericPageSize)){
                        showMoreKnb = true;
                    }    
            }           
        } 
        System.debug('DSC_SIZE'+discussionResults.size()); System.debug('KNB_SIZE'+knbResults.size());
        System.debug('resResults_SIZE'+resResults.size());
    }
    
    public void categorySpecificResults(HTTPResponse res) {
        System.Debug('CAT SPECIFIC RESULTS');
        results = new List<resultElement>();
        string solr_results = res.getBody();
        System.debug('LWE_results '+solr_results );
        xmlResult = new XMLDom(solr_results);
        //System.debug('dom-->'+xmlResult );
        xmldom.element xmlResultNode = xmlResult.getElementByTagName('result');
        //System.Debug('NODES'+xmlResultNode);
        numberOfResults            = integer.ValueOf(xmlResultNode.getAttribute('numFound'));
        Integer paginationStart    = integer.ValueOf(xmlResultNode.getAttribute('start'));
        paginationList = createPaginationList(numberOfResults, currentPage, 10);

        System.debug('numberOfResults -->'+numberOfResults );
        List<xmldom.element> docNodesList = xmlResultNode.getElementsByTagName('doc');
        //Integer count=0;
        System.Debug('DOC LIST SIZE'+docNodesList.size());
        results = parseSolrDom(docNodesList);
        System.debug('SOLR Results'+results);
        System.debug('Results-->'+results);
    }
    
    public List<resultElement> parseSolrDom(List<xmldom.element> docNodesList) {
        results = new List<resultElement>();
        for (xmldom.element docNode:docNodesList) {
            //System.debug('__DOC__'+docNode);
            List<xmldom.element> subNodesList = docNode.getElementsByTagName('str');
            resultElement resultNode = new resultElement();
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
               }
               //System.debug('NodeAdded'+nodeName);
            }
            results.add(resultNode); 
        }
        return results;    
    }
    
    public class resultElement {
        public String title   {get; set;}
        public String summary {get; set;}
        public String sfdc_id {get; set;}
        public String top_category   {get; set;}
        public String child_category {get;set;}
        public String lastmodified {get;set;}
        public List<String> dataCategories{get;set;}
    }
    
    public List<Integer> createPaginationList (Integer totalResults, Integer curPageNo, Integer pagesize) {
        try {
            List<Integer> paginationList = new List<Integer>(); 
            Double totalNumOfPages = math.ceil(Double.valueof(totalResults)/Double.valueof(pagesize));
            System.Debug('totalNumOfPages++++'+totalNumOfPages);
            System.Debug('curPageNo+++'+curPageNo);
            Integer index;
            If(curPageNo < 4 ){
                System.Debug('++++Less than 4');
                for (index=curPageNo-3;index<curPageNo;index+=1) {//Enter Here for first 3 pages
                    if(index<0) {
                        continue;  
                    }
                paginationList.add(index);
                }
            paginationList.add(curPageNo);
            Integer jindex;      
                for (jindex=curPageNo+1;jindex<=6;jindex+=1) {
                    If(jindex >= totalNumOfPages){
                        break;
                    }
                    paginationList.add(jindex);
                }
            }else If(curPageNo >= 4 && curPageNo < totalNumOfPages-3){//Enter here for Pages In Between
                for (index=curPageNo-3;index<curPageNo;index+=1) {
                        if(index<=0) {
                            continue;  
                        }
                    paginationList.add(index);
                    }
                paginationList.add(curPageNo);
                Integer jindex;      
                    for (jindex=curPageNo+1;jindex<=curPageNo+3;jindex+=1) {
                        if(jindex > totalResults/pageSize){
                            break;
                        }
                    paginationList.add(jindex);
                    }
                }
            else {//Enter Here for last 3 pages
                System.Debug('Entered here for last three numbers'+curPageNo);
                Integer tempNum;//Number of digits before last three digits to keep the list count(7) for last three digits
                System.Debug(''+totalNumOfPages);
                If(curPageNo == totalNumOfPages-3){tempNum = 4;}
                If(curPageNo == totalNumOfPages-2){tempNum = 5;}
                If(curPageNo == totalNumOfPages-1){tempNum = 6;}
                If(curPageNo == totalNumOfPages)  {tempNum = 7;}
                for (index=curPageNo-tempNum;index<curPageNo;index+=1) {
                    if(index<=0) {
                        continue;  
                    }
                    paginationList.add(index);
                }
                paginationList.add(curPageNo);
                Integer jindex;      
                for (jindex=curPageNo+1;jindex<=totalNumOfPages+2;jindex+=1) {
                    if(jindex >= totalNumOfPages){
                    break;
                    }
                    paginationList.add(jindex);
                }
            }
            System.Debug('++paginationList++'+paginationList);
        return paginationList;
        }
        catch(Exception ex){
        System.Debug('Exception'+ex);
        list<Integer> defaultList = new list<Integer> {1,2,3,4,5,6,7};
        return defaultList; 
        }
    }    

    
    public static testMethod void myUnitTest() {
    
      Solr_Status__c solrStatus = new Solr_Status__c (Name='Test',IsSolrDown__c = false);
      insert solrStatus;        
      
      PageReference pg = Page.caseSuggest; 
      pg.getParameters().put('page', '0');
      pg.getParameters().put('searchText', 'marketo');
      pg.getParameters().put('sortby', '');
      pg.getParameters().put('top_category', 'Article,Tutorial,Video,Deepdive');
      pg.getParameters().put('get_results', 'true');
      pg.getParameters().put('dcategory', '');
      
      Test.setCurrentPage(pg);
      
      SolrMarketoSuppCaseCreateSrchCntlr  c = new SolrMarketoSuppCaseCreateSrchCntlr();  
      c.initialize();  
      
      PageReference pg1 = Page.SolrSearchPage; 
      pg1.getParameters().put('page', '0');
      pg1.getParameters().put('searchText', 'marketo');
      pg1.getParameters().put('sortby', '');
      pg1.getParameters().put('top_category', 'all');
      pg1.getParameters().put('get_results', 'true');
      pg1.getParameters().put('dcategory', '');
      
      Test.setCurrentPage(pg1);
      SolrMarketoSuppCaseCreateSrchCntlr  c1 = new SolrMarketoSuppCaseCreateSrchCntlr();  
      c1.initialize();  
      c1.createPaginationList(30,3,10);
      c1.createPaginationList(30,5,10);
      c1.createPaginationList(30,15,10);      
      c1.notifySolrDownEvent();
    }    
}