/****************************************************
Class Name: CaseCloseController
Author: ClearTeask
Created Date: 6/7/2012
Usage: This class is used to mass close cases.
*****************************************************/
public class CaseCloseController {

    /*variable for StandardSetController */
    ApexPages.StandardSetController setCon;
    public List<Case> caseList{get;set;}
    public String closingReason{get;set;}
    public Boolean caseSelected{get;set;}
    public List<SelectOption> caseClose {get; set;}
    
    /*Constructor */ 
    public CaseCloseController(ApexPages.StandardSetController controller) {
        caseSelected = true;
        setCon = controller;
        caseClose = new List<SelectOption>();
        caseList = new List<Case>();
        caseList = setCon.getSelected();
        
        if(caseList == null || caseList.size() == 0) {
            caseSelected = false;
        }
        caseCloseOptions();
    }
    
    /* add closing options */
    public void caseCloseOptions() {
        caseClose.add(new SelectOption('Spam', 'Spam'));
        caseClose.add(new SelectOption('Duplicate', 'Duplicate'));
        caseClose.add(new SelectOption('Resolved', 'Resolved'));
    }
    
    /* method to close cases */
    public PageReference closeCase() {
        for(Case c :caseList) {
            c.Status = 'Closed';
            c.Close_Reason__c = closingReason;
        }
        
        try {
            update caseList;
        } catch(Exception e) {
            ApexPages.addMessages(e);
        }
        PageReference pgRef = new PageReference('/500/o');
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    public PageReference doCancel() {
        PageReference pgRef = new PageReference('/500/o');
        pgRef.setRedirect(true);
        return pgRef;
    }
}