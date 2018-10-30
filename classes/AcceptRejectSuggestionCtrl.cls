/****************************************************
Class Name: AcceptRejectSuggestionCtrl
Author: ClearTeask
Created Date: 5/26/2012
Usage: This class is used accept/ reject suggestion and create task when email is sent to customer.
*****************************************************/
public class AcceptRejectSuggestionCtrl {
    private Case caseRec;
    
    public acceptRejectSuggestionCtrl(ApexPages.StandardController ctrl) {
        caseRec = (Case)ctrl.getRecord();
    }
    
    /* metod to update case */
    public PageReference updateCaseStatus() {
        String suggestion = ApexPages.currentPage().getParameters().get('suggestion');
        Task objTask = new Task();
        
        if(suggestion != null && suggestion.equalsIgnoreCase('accept'))
            caseRec.Status = 'Closed';
            caseRec.Close_Reason__c = 'Resolved';
            
        if(suggestion != null && suggestion.equalsIgnoreCase('reject'))
            caseRec.Status = 'Working';
            
        if(suggestion != null && suggestion.equalsIgnoreCase('sendemail')) {
            caseRec.Send_Email__c = true;
            objTask.OwnerId = UserInfo.getUserId();
            objTask.Subject='Email sent to customer';
            objTask.Status = 'Completed';
            objTask.WhatId = caseRec.id;
        }
        
        try {
            update caseRec;
            insert objTask;
        } catch(Exception e) {
            ApexPages.addMessages(e);
        }
        PageReference pgRef = new PageReference('/' + caseRec.id);
        pgRef.setRedirect(true);
        return pgRef;
    }
}