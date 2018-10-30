public class JIRAFetchIssuesController{
    private String jiraURL;
    private String systemId;
    private String objectType;
    private String objectId;
    private String username;
    private String password;
    private String issuesJson;
 
    public JIRAFetchIssuesController(ApexPages.StandardController stdController) {
        Case theCase = (Case)stdController.getRecord();
        this.objectId = theCase.id; 
        //Change these variables based on your JIRA instance configuration
        this.jiraURL = 'https://resource.marketo.com/jira';
        //this.jiraURL = 'https://199.15.214.52/jira';//sandbox
        this.systemId = '3';
        this.objectType = 'Case';
        this.username = 'bikram_thapa';
        this.password = 'M00n$hin3!';
        this.issuesJson = callRestEndPoint();
    }
 
 
    public String getIssuesJSON(){
        return this.issuesJson;
    }
 
    public List<JIRAIssue> getIssues(){
        List<String> issueLinks = new List<String>();
         return null;
        //Parse JSON response
        List<JIRAIssue> result = (List<JIRAIssue>)JSON.deserialize(this.issuesJson , LIST<JIRAIssue>.class);
        return result;
    }
 
    private String callRestEndpoint() {
 
        //Construct HTTP request and response
        HttpRequest req = new HttpRequest();
        HttpResponse res = new HttpResponse();
        Http http = new Http();
 
        //Construct Authorization and Content header
        Blob headerValue = Blob.valueOf(this.username+':'+ this.password);
        String authorizationHeader = 'Basic ' + EncodingUtil.base64Encode(headerValue);
        req.setHeader('Authorization', authorizationHeader);
        req.setHeader('Content-Type','application/json');
 
        //Construct Endpoint
        String endpoint = jiraURL+'/rest/customware/connector/1.0/'+
        this.systemId+'/'+ this.objectType+'/'+objectId+'/issue/fetch.json';
 
        //Set Method and Endpoint and Body
        req.setMethod('GET');
        req.setEndpoint(endpoint);
 
        String result = '';
        try {
           //Make a request to JIRA
           if(!Test.isRunningTest())
           {
               res = http.send(req);
               result = res.getBody();
           } else {
               result = '[{"SUMMARY":"Description Changed1","customfield_11169":null,"customfield_10243":null,"customfield_10244":null,"customfield_10245":null,"customfield_10246":null,"customfield_10240":null,"customfield_10241":null,"customfield_10231":null,"customfield_10242":"bud","customfield_10230":null,"customfield_10229":null,"customfield_10225":null,"customfield_11560":null,"customfield_10226":null,"customfield_10041":["bikram_thapa","kesparza"],"customfield_10227":null,"customfield_10040":null,"TYPE":"Escalation","AFFECTED_VERSIONS":[],"DESCRIPTION":"Information for testing jira integration1.","customfield_10224":null,"customfield_10223":null,"customfield_10222":null,"customfield_10221":null,"customfield_10220":null,"CREATED":1389595547000,"customfield_11203":null,"customfield_10053":null,"customfield_11200":null,"customfield_10191":null,"UPDATED":1391510974000,"customfield_10052":null,"REMAINING_ESTIMATE":null,"TIME_SPENT":null,"customfield_10364":null,"customfield_10365":null,"customfield_10159":null,"customfield_10361":null,"customfield_10362":null,"customfield_10260":null,"customfield_10363":null,"PROJECT":"DLVR","customfield_10963":null,"customfield_10965":null,"KEY":"DLVR-6423","customfield_10966":null,"customfield_10210":null,"customfield_10967":null,"customfield_10969":null,"customfield_10203":null,"customfield_10204":null,"customfield_10066":null,"customfield_10161":null,"customfield_10205":null,"customfield_10065":null,"customfield_10160":null,"customfield_10067":null,"URL":"https://resource.marketo.com/jira/browse/DLVR-6423","LABELS":["qliktech"],"PRIORITY":"Trivial","customfield_10202":"Customer Request","ASSIGNEE":"kesparza","customfield_12263":"P3: Normal Priority","customfield_10961":"Single Customer","customfield_10960":null,"customfield_12464":"500W0000002UFI5IAO,500W0000002UFHWIA4","customfield_12463":["500W0000002USyY","500W0000002UFHW","500W0000002UFI5","500W0000002UFHW","500W0000002UFI5","500W0000002UFHW","500W0000002UFI5","500W0000002UFHW","500W0000002UFI5","500W0000002UFHW","500W0000002UFI5","500W0000002UFHW","500W0000002UFI5","500W0000002UFHW","500W0000002UFI5","500W0000002UFHW","500W0000002USyY","500W0000002UFHW","500W0000002UFI5","500W0000002UFHW","500W0000002UFI5","500W0000002UFHW","500W0000002UFI5","500W0000002UFHW","500W0000002UFI5","500W0000002UFHW","500W0000002UFI5","500W0000002UFHW","500W0000002UFI5","500W0000002UFHW","500W0000002UFI5","500W0000002UFHW"],"customfield_12461":"http://staging-marketo.cs13.force.com/community/JiraCaseDetailPage?id=500W0000002UFI5","customfield_10175":null,"customfield_10661":null,"COMPONENTS":[],"customfield_10860":null,"customfield_10861":"0.0","customfield_10144":null,"customfield_10001":null,"customfield_10000":null,"customfield_11795":null,"DUE_DATE":null,"customfield_10099":null,"customfield_11192":null,"customfield_10869":null,"customfield_10868":"Open","customfield_10867":"None","customfield_11194":null,"customfield_10866":"Open","customfield_10865":"Open","customfield_10155":null,"customfield_11191":null,"customfield_10864":"Open","customfield_10863":"Open","customfield_10156":null,"ORIGINAL_ESTIMATE":null,"customfield_11204":null,"customfield_11197":null,"customfield_11196":null,"customfield_11199":null,"customfield_10460":null,"customfield_11198":null,"customfield_11780":null,"customfield_11969":null,"REPORTER":"bikram_thapa","STATUS":"Open","customfield_10122":"Marketo","customfield_10123":"Green","RESOLUTION":"Unresolved","customfield_10125":"qliktech","customfield_11184":null,"customfield_11183":null,"customfield_10121":"00202274","customfield_12018":"V2","customfield_10020":null,"customfield_11972":null,"customfield_11973":null,"customfield_11970":null,"customfield_11971":null,"customfield_11975":null,"customfield_11974":null,"customfield_11362":null,"customfield_11976":null,"customfield_11361":null,"customfield_11978":null,"FIX_VERSIONS":[],"customfield_11360":"87208","customfield_11462":null,"customfield_11461":null,"customfield_11460":null,"customfield_11171":null,"customfield_11170":null,"customfield_11175":null,"customfield_11174":null,"customfield_10030":null,"customfield_11765":"Article","DATE_RESOLVED":null,"customfield_11176":null,"ENVIRONMENT":null}]';
           }
        } catch(System.CalloutException e) {
           result = res.toString();
        }
        //system.debug(result); 
        return result; 
    }
 
    //JIRA Issue Object
    class JIRAIssue{
        public String summary {get;}
        public String project {get;}
        public String reporter {get;}
        public String key {get;}
        public String status {get;}
        public String resolution {get;}
        public String url {get;}
        public String type {get;}
        public String assignee {get;}
        public String description {get;}
        public String priority {get;}
        public String due_date {get;}
 
    }
 
 
}