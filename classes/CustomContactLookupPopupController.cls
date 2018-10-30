public without sharing class CustomContactLookupPopupController
{
    private integer counter = 0;  //keeps track of the offset
    private integer list_size = 8; //sets the page size or number of rows
    public integer total_size = 0; //used to show user the total size of the list
    private integer upperLimit = 2000;
    public String query {get; set;}
    public List<Authorized_Contact__c> AuthCont {get; set;}
    public Account selAccount {get; set;}
    public Contact selContact {get;set;}    
    public String userType{get;set;}
    
    public CustomContactLookupPopupController (ApexPages.StandardController controller) {
        Set<String> byPassList = new Set<String>();
        byPassList.addAll(System.Label.Internal_Case_Create_Page_Access_Email_List.split(','));
        List<User> currentUser = [Select id, ContactId,Contact.Is_Authorized_Contact__c, Email, Contact.Account.Type from User Where Id =: UserInfo.getUserId()];
        if(!currentUser.isEmpty()) {
            if(currentUser[0].Email.endsWithIgnoreCase('@marketo.com') ||  byPassList.contains(currentUser[0].Email)){
                UserType = 'Internal';  
                selContact = new Contact();
                runQuery();    
            }
        }
    }
            
    public PageReference runQuery() {
        AuthCont = new List<Authorized_Contact__c>();
        total_size = 0;
        try {
            String selAccountId = ApexPages.currentPage().getParameters().get('accfield');
            system.debug('accfield==>' + selAccountId + '  ' + + ApexPages.currentPage().getParameters().get('accfield'));          
            total_size =  [SELECT count() from Authorized_Contact__c where Entitlement__r.Status = 'Active' AND Entitlement__r.AccountId =: selAccountId Limit :upperLimit];                    
            AuthCont = new List<Authorized_Contact__c>([SELECT Id, Customer_Admin__c, Contact__r.Id,contact__r.Name,Entitlement__r.Asset.Munchkin_ID__c, Entitlement__r.Asset.Acct_Prefix__c from Authorized_Contact__c where Entitlement__r.Status = 'Active' AND Entitlement__r.AccountId =: selAccountId ORDER BY Name LIMIT :list_size offset :counter]);                           
        } catch (Exception ex) {
            total_size = 0;
            AuthCont.clear();
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please Fill Account.');
            ApexPages.addMessage(myMsg);
        }                    
        return null;
    }
    
    public PageReference Beginning() { //user clicked beginning
        counter = 0;
        runQuery();
        return null;
    }
 
    public PageReference Previous() { //user clicked previous button
        counter -= list_size;
        runQuery();
        return null;
    }
 
    public PageReference Next() { //user clicked next button
        counter += list_size;
        runQuery();
        return null;
    }
 
    public PageReference End() { //user clicked end        
        if(Math.Mod(total_size,list_size) == 0)
            counter = total_size-list_size;        
        else
            counter = (total_size/list_size)*list_size;                              
        runQuery();
        return null;
    }
 
    public Boolean getDisablePrevious() {
        //this will disable the previous and beginning buttons
        if (counter>0) return false; else return true;
    }
 
    public Boolean getDisableNext() { //this will disable the next and end buttons
        if (counter + list_size < total_size) return false; else return true;
    } 
    
    public Integer getTotal_size() {        
        return total_size;
    }
     
    public Integer getPageNumber() {
        return counter/list_size + 1;     
    }
 
    public Integer getTotalPages() {        
        if ( math.mod(total_size, list_size) == 0 ) 
            return (total_size/list_size);
        else 
            return (total_size/list_size)+1;        
    }        
}