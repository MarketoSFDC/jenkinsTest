/***************************************************************************************************
* Created by         : Snehal Khot
* Created Date       : 31st Jan 2018
* Purpose            : This class is created to send dummy error response to SFContactToIntacctTest Class
***************************************************************************************************/

@isTest 
global class SFContactToIntacctErrorMockTest implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response.
        string XMLBody='<?xml version="1.0" encoding="UTF-8"?><response><control><status>Failure</status><senderid>marketo</senderid><controlid>testRequestId</controlid><uniqueid>false</uniqueid><dtdversion>2.1</dtdversion></control><operation><authentication><status>Failure</status><userid>SFDC_API</userid><companyid>marketo-copy</companyid><sessiontimestamp>2018-01-29T03:49:22-08:00</sessiontimestamp></authentication><result><status>Failure</status><function>update_contact</function><controlid>testControlId</controlid><key>0031g000004i5OMAAY</key></result></operation></response>';
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setBody(XMLBody);
        res.setStatusCode(200);
        return res;
       
    }
}