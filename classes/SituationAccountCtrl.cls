/****************************************************
Class Name: SituationAccountCtrl
Author: ClearTeask
Created Date: 16/09/2012
Usage: This class is used for show SM case list on Account detail page.
*****************************************************/
public class SituationAccountCtrl {
    
    // situation management records for contact
    public List<Case> caseList {get; set;}
    // case create page url
    public String detailUrl {get; set;}
    // check if case is creatable
    public Boolean isCreateable {get; set;}
    // check if case is updateable
    public Boolean isUpdateable {get; set;}
    // contact object
    Account accRecord;
    
    // check permissions and query situation management records
    public situationAccountCtrl(ApexPages.standardController ctrl) {
        accRecord = (Account)ctrl.getRecord();
        checkPermissions();
        caseList = new List<Case>();
        queryCases(accRecord.id);
    }
    
    // query situation management records
    void queryCases(Id accId) {
        caseList = [select CaseNumber, Subject, ContactId, Priority, Status,
                        CreatedDate, Owner.Name, RecordType.Name
                        from Case where Situation_Account__c = :accId 
                        order by CreatedDate DESC];
    }
    
    // check case permissions
    public void checkPermissions() {
        isCreateable = SituationUtil.caseIsCreateable();
        isUpdateable = SituationUtil.caseIsUpdateable();
    }
    
    // new case page url for record type selection
    public String getURL() {
        accRecord = [select id from Account where id = :accRecord.id];
        String url = '/apex/SituationRecordTypeSelect?page=new_account&accid=' + accRecord.id; 
        return url;
    }
    
    // create page url
    public void goToURL() {
        String recType = ApexPAges.currentPage().getParameters().get('rtname');
        String cid = ApexPAges.currentPage().getParameters().get('cid');
        
        if(recType != null && recType.containsIgnoreCase('Services')) {
            detailUrl = '/apex/SituationServicesCreate?id=' + cid + '&page=edit&type=serv'; 
        } else if(recType != null && recType.containsIgnoreCase('Support')) {
            detailUrl = '/apex/SituationSupportCreate?id=' + cid + '&page=edit&type=supp'; 
        }  
    }
    
    
    
}