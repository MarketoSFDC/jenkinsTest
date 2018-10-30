/*****************************************************************************
Created By    : Jade Global Inc
Created Date  : 19th May 2018
Purpose       : This is test class for "AssetAutoDeProvisioning" class
******************************************************************************/

@isTest
global class SPAErrorCalloutMock implements HttpCalloutMock {
   
   global HttpResponse respond(HttpRequest req) {
       
        String XMLSucessbody = '<?xml version="1.0" encoding="UTF-8"?><response><control><status>Error</status><senderid>marketo</senderid><controlid>testRequestId</controlid><uniqueid>false</uniqueid><dtdversion>3.0</dtdversion></control><operation><authentication><status>success</status><userid>SFDC_API</userid><companyid>marketo-sandbox2</companyid><sessiontimestamp>2017-12-17T21:56:40-08:00</sessiontimestamp></authentication><result><status>success</status><function>create</function><controlid>3G2DFC86-9899-4283-360X-C789142D2801</controlid><data listtype="objects" count="1"><projectresources><RECORDNO>65787</RECORDNO></projectresources></data></result></operation></response>';
        
        // Create a fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody('{"Id":"02i0m00000","Munchkin Id":"ASDFGBHJMM","Status":"Error","Churn Status":"Cancelled","Churn Message":"Error"}');
        res.setStatusCode(400);
        return res; 
    }
}