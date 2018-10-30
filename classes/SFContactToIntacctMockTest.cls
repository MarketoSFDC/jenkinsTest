/***************************************************************************************************
* Created by         : Snehal Khot
* Created Date       : 29th Jan 2018
* Purpose            : This class is created to send dummy sucess response to SFContactToIntacctTest Class
***************************************************************************************************/
@isTest 
global class SFContactToIntacctMockTest implements HttpCalloutMock {
    global HTTPResponse respond(HTTPRequest req) {
        // Create a fake response.
        string XMLBody='<?xml version="1.0" encoding="UTF-8"?><response><control><status>success</status><senderid>marketo</senderid><controlid>testRequestId</controlid><uniqueid>false</uniqueid><dtdversion>2.1</dtdversion></control><operation><authentication><status>success</status><userid>SFDC_API</userid><companyid>marketo-copy</companyid><sessiontimestamp>2018-01-31T05:36:00-08:00</sessiontimestamp></authentication><result><status>success</status><function>create_contact</function><controlid>testControlId</controlid><key>0031g000004iaEvAAI</key></result><result><status>success</status><function>create_contact</function><controlid>testControlId</controlid><key>0031g000004iaF5AAI</key></result></operation></response>';        
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'text/xml');
        res.setBody(XMLBody);
        res.setStatusCode(200);
        return res;
       
    }
}