global class competitorLeadReportController{
       
    public String  similarDomains;
    public competitorLeadReportController(){
        String accWebsite = ApexPages.currentPage().getParameters().get('website');
        //System.debug('__________website _________'+accWebsite );
        
        /* Get the domain name out of Website */ 
        //string HTML_TAG_PATTERN = '^(http://)?(www.)?(.*)?$';
        string HTML_TAG_PATTERN = '^(http://)?(www.)?([^/]*)(.)*$';
        Pattern myPattern = Pattern.compile(HTML_TAG_PATTERN);
        Matcher myMatcher = myPattern.matcher(accWebsite); 
        String  domain = '';
        while (myMatcher.find()) {
            domain =  myMatcher.group(3);
            //System.debug('+++++myMatcher++++++'+myMatcher.group(3));
        }
        getwebsiteCompititors(domain);
       // redirectToLeadReport();
       // getReportRecords();
    }
    
    /*Get Competitoris List*/
    public void getwebsiteCompititors(String domain){
        if (domain == '') {
            similarDomains = '';
            
        } else {
            JSONObject jResponse;
            HttpRequest req = new HttpRequest();
            req.setEndPoint('http://www.similarsitesearch.com/api/similar/'+domain);
            req.setMethod('GET');
            Http http = new Http();            

            if (domain == '__TEST_WEBSITE__') {  /*Since webcallouts dont work in TestMethods*/
               jResponse = new JSONObject('{"num":20,"status":"ok","r0":"http:\\/\\/www.excite.com\\/","r1":"http:\\/\\/www.mahalo.com\\/"}');
            } else {
                HTTPResponse res = http.send(req);
                //System.debug('res ----->'+res );
                //Parse the json response
                if(res.getStatusCode() == 404){
                    similarDomains = '';
                    return;
                }
                jResponse = new JSONObject(res.getBody());            
            }
            similarDomains = '';
            String  parsedDomain;
            System.debug('jResponse.length-----------'+jResponse.length());
            If(jResponse.length()>2){
                for(Integer index=0; index < jResponse.length()-2 ; index++) {
                    String websiteDomain = jResponse.getString('r'+ index).subString(9); //Strips http:\/\/
                    websiteDomain = websiteDomain.replace('\\','');
                    string HTML_TAG_PATTERN = '^(www.)?(.*)?\\/';
                    Pattern myPattern = Pattern.compile(HTML_TAG_PATTERN);
                    //System.debug('___jsson_resp___'+j.getString('r'+ index));
                    //system.debug('websiteDomain =============>'+websiteDomain );
                    Matcher myMatcher = myPattern.matcher(websiteDomain );       
                    while (myMatcher.find()) {
                        parsedDomain =  myMatcher.group(2);
                    }
                    similarDomains +=  parsedDomain+ ',';
                    
                }
                similarDomains = similarDomains.subString(0,similarDomains.lastindexof(',')); //Remove the extra comma at last
            }
            else{
                similarDomains = domain;
               // similarDomains = similarDomains.subString(0,similarDomains.lastindexof(','));
            }
           System.debug('similarDomains -----------'+similarDomains );
        }
   }
  
   public PageReference redirectToLeadReport(){
   System.debug('similarDomains -----------'+similarDomains );
        // Get the Results from 
        pageReference pg = new pageReference('/'+System.Label.competitorLeadReportId+'?pv0='+similarDomains);
        pg.setRedirect(true);
        return pg;
   }

   public PageReference redirectToContactReport(){
        System.debug('similarDomains -----------'+similarDomains );
        // Get the Results from 
        pageReference pg = new pageReference('/'+System.Label.competitorContactReportId+'?pv0='+similarDomains);
        pg.setRedirect(true);
        return pg;
   }
   
   public static testMethod void myUnitTest() {
      PageReference pg = Page.competitorsContactReport; 
      pg.getParameters().put('website', '__TEST_WEBSITE__');
         
      Test.setCurrentPage(pg);
      competitorLeadReportController c = new competitorLeadReportController();      
      c.redirectToContactReport(); 
      c.redirectToLeadReport();    
  
    }      
   
}