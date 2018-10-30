/****************************************************
Class Name: SituationNewRedirectCtrl
Author: ClearTeask
Created Date: 20/09/2012
Usage: This class is used to redirect to record type selection page depending on tab id.
*****************************************************/
public class SituationNewRedirectCtrl {
    
    // constructor
    public situationNewRedirectCtrl(ApexPages.StandardController ctrl) {
    
    }
    
    // redirect to record type selection page depending on tab id
    public PageReference redirect() {
        String tabId = ApexPages.currentPage().getParameters().get('sfdc.tabName');
        String url = '';
        Situation_Management__c mc = Situation_Management__c.getInstance('TabId');
        if(tabId != null && tabId.equals(mc.Tab_Id__c)) {
            url = '/apex/SituationRecordTypeSelect';
        } else {
            url = '/setup/ui/recordtypeselect.jsp?ent=Case&retURL=' + getObjectKeyPrefix() + '&save_new_url=' + getObjectKeyPrefix() + '%2Fe%3FretURL=' + getObjectKeyPrefix() + '&nooverride=1';
        }
        PageReference pgRef = new PageReference(url);
        pgRef.setRedirect(true);
        return pgRef;
    }
    
    // get object prefix
    public String getObjectKeyPrefix() {
        String casePrefix = Case.SObjectType.getDescribe().getKeyPrefix();
        return casePrefix;
    }
}