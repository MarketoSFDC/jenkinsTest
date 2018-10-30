/****************************************************
Class Name: SituationcaseRedirect 
Author: Bikram - Grazitti
Created Date: 19/02/2013
Usage: This class is used for redirecting to correct case/sm-case create page.
*****************************************************/
public with sharing class SituationcaseRedirect {

    private ApexPages.StandardController controller;
    public String retURL {get; set;}
    public String saveNewURL {get; set;}
    public String rType {get; set;}
    public String cancelURL {get; set;}
    public String ent {get; set;}
    public String confirmationToken {get; set;}
    public String accountID {get; set;}
    public String contactID {get; set;}
    
    public RecordType SMRecordType{get;set;}    
    public SituationcaseRedirect(ApexPages.StandardController controller) {
    
        this.controller = controller;
        retURL = ApexPages.currentPage().getParameters().get('retURL');
        rType = ApexPages.currentPage().getParameters().get('RecordType');
        cancelURL = ApexPages.currentPage().getParameters().get('cancelURL');
        ent = ApexPages.currentPage().getParameters().get('ent');
        confirmationToken = ApexPages.currentPage().getParameters().get('_CONFIRMATIONTOKEN');
        saveNewURL = ApexPages.currentPage().getParameters().get('save_new_url');
        accountID = ApexPages.currentPage().getParameters().get('def_account_id');
        contactID = ApexPages.currentPage().getParameters().get('def_contact_id');
        SMRecordType = new RecordType();
        try {
            SMRecordType = [select id, Name from RecordType where sObjectType = 'Case' and Id = :rType LIMIT 1];        
        }
        catch (Exception ex) {
            SMRecordType = null;
        }    
    }
    
    public PageReference redirect() {
    
        PageReference returnURL;
        // Redirect if Record Type corresponds to custom VisualForce page
        //IF(rType =='01250000000UKpsAAG' || rType =='01250000000UKa9AAG' || rType=='01250000000UK1EAAW')         
        IF(SMRecordType != null)
        {
            if(SMRecordType.Name.equals('Situation Management - Services')){
                 returnURL = new PageReference('/apex/SituationServicesCreate?type=serv');            
            }
            // else if(SMRecordType.Name.equals('Situation Management - Support Feedback')) {
                 //returnURL = new PageReference('/apex/SituationFeedbackCreate?type=feed');            
            //} 
            //else if(SMRecordType.Name.equals('Situation Management - Support')) {
                //returnURL = new PageReference('/apex/SituationSupportCreate?type=supp');
            //} 
            else {
                returnURL = new PageReference('/500/e');
            }
        }        
        ELSE 
        {
            returnURL = new PageReference('/500/e');
        }
        
        returnURL.getParameters().put('retURL', retURL);
        returnURL.getParameters().put('RecordType', rType);
        returnURL.getParameters().put('cancelURL', cancelURL);
        returnURL.getParameters().put('ent', ent);
        returnURL.getParameters().put('_CONFIRMATIONTOKEN', confirmationToken);
        returnURL.getParameters().put('save_new_url', saveNewURL);
        returnURL.getParameters().put('nooverride', '1');
    
        IF (accountID != null){
            returnURL.getParameters().put('def_account_id', accountID);
        }
        IF (contactID != null){
            returnURL.getParameters().put('def_contact_id', contactID);
        }
        returnURL.setRedirect(true);
        return returnURL;
    }
    
    @isTest(SeeAllData=true)
    public static void testCaseRedirect()
    {
        Test.startTest();
        Case caseObj = new Case(Status = 'New', Priority = 'P3', Subject = 'Test', Description = 'Test Description');
        insert caseObj;          
        
        PageReference pg = Page.SituationcaseRedirect;
        Test.setCurrentPage(pg);
        RecordType SMRecordType = [select id, Name from RecordType where sObjectType = 'Case' and Id = '01250000000UK1E' LIMIT 1]; 
        
        ApexPages.currentPage().getParameters().put('def_account_id', '0015000000Xu1Kc');        
        ApexPages.currentPage().getParameters().put('RecordType', '01250000000UK1E');        
        ApexPages.currentPage().getParameters().put('retURL', '2F0035000000pkKJe');        
        ApexPages.currentPage().getParameters().put('def_contact_id', '0035000000pkKJe');     
        ApexPages.currentPage().getParameters().put('sfdc.override', '1');        
        ApexPages.currentPage().getParameters().put('save_new', '1');   
        ApexPages.currentPage().getParameters().put('ent', 'Case');  
        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj); 
        SituationcaseRedirect ctrl = new SituationcaseRedirect(sc);
        ctrl.redirect();            
        Test.stopTest();
    }
    
}