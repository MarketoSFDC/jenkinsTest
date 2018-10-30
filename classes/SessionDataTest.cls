@isTest 
public class SessionDataTest{
    static testMethod void SessionTest(){ 
        SessionData sd = new SessionData();
        string jsn = '{"sessionId": "1e6b0180-406e-4496-b86a-3f552cd4d90f_135030","userId": "6jbris2becwse0yt70vjzrotv0","organizationId": "e4c24cce-9022-4845-b594-3b494297aed7","serverTime": "2015-07-23T10:43:27.5341531Z","licenseType": "Full"}';
        
        SessionData.parse(jsn);
    }
}