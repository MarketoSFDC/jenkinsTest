public class pureCloudCaseAttachment {

    //BASIC METHOD TO CALL OUT TO AWS TO NOTIFY THEM TO GO GET MY ATTACHMENTS!
	@future
    (callout = true)
    public static void callOutAWS(string localUID, string caseID, string filename)   
    	{
     	string url = 'https://support-case.marketo.com:4000/Support/attachFile?';
     	HttpRequest req = new HttpRequest();
     	req.setEndpoint(url + 'localUID=' + localUID + '&caseId=' + caseId + '&filename=' + filename);
     	req.setMethod('GET');
     	Http http = new Http();
     	HTTPResponse res = http.send(req);
     	string responseBody = res.getBody();
        jsonResponse rep = New jsonResponse();
        rep = (jsonResponse)json.deserialize(responseBody, jsonResponse.class);
        system.debug(rep);    
    	}
    
    public class jsonResponse  
    {
    string flag;
    }



}