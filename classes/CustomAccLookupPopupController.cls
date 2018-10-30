//
// Custom controller for lookup example popup page
//
public class CustomAccLookupPopupController
{
    public String query {get; set;}
    public List<Account> accounts {get; set;}
    public Account selAccount {get; set;}
    public String userType{get;set;} 
    public String accPrefix {get;set;}  
    public String accMunchkinId {get;set;} 
    public String accName{get;set;}  

    private Id myAccId = null;
    private integer counter=0;  //keeps track of the offset
    private integer list_size=30; //sets the page size or number of rows
    public  integer total_size; //used to show user the total size of the list
    private integer upperLimit = 2000;    
    private String partnerName = '';
    private String partnerId = '';
    
    public CustomAccLookupPopupController (ApexPages.StandardController controller) {
        total_size = 0;
        selAccount = new Account();        
        Set<String> byPassList = new Set<String>();
        byPassList.addAll(System.Label.Internal_Case_Create_Page_Access_Email_List.split(','));
        List<User> currentUser = [Select id, ContactId, Contact.Is_Authorized_Contact__c, Email, Contact.Account.Type, Contact.Account.Id, Contact.Account.Name from User Where Id =: UserInfo.getUserId()];
        if(!currentUser.isEmpty()) {            
            if(currentUser[0].Email.endsWithIgnoreCase('@marketo.com') ||  byPassList.contains(currentUser[0].Email)) {
                UserType = 'Internal';
            }         
        }
    }        
    
    public PageReference runQuery() {    
        system.debug('query++++'+query + ' accPrefix+++' +accPrefix + ' accMunchkinId++++' + accMunchkinId+ ' accName++++' + accName);
        
        
        string tmpQuery = ''; String tmpAccPrefix = ''; String tmpAccMunchkinId = ''; String tmpAccName = '';
        total_size = 0; accounts = new List<Account>();
        try {
            if(UserType == 'Internal') {
                if(accPrefix.trim().length() > 1 || accMunchkinId.trim().length() >1 || accName.trim().length() >1) {
                    if(accPrefix.trim() != '')  tmpAccPrefix  = '%' + accPrefix + '%';
                    if(accMunchkinId.trim() != '')  tmpAccMunchkinId   = '%' + accMunchkinId + '%';  
                    if(accName.trim() != '')  tmpAccName  = '%' + accName + '%';                 
                    if(tmpAccPrefix != '' && tmpAccMunchkinId != '' && tmpAccName !='' ) {
                        accounts = new List<Account>([SELECT Id,Name from Account Where Id in(SELECT AccountId From Asset Where Munchkin_Id__c != Null AND (Acct_Prefix__c like :tmpAccPrefix OR Munchkin_Id__c like: tmpAccMunchkinId OR Name like: tmpAccName))]);
                    } else if(tmpAccPrefix != '') {
                        accounts = new List<Account>([SELECT Id,Name from Account Where Id in(SELECT AccountId From Asset Where Munchkin_Id__c != Null AND Acct_Prefix__c like :tmpAccPrefix)]);
                    } else if(tmpAccMunchkinId != '') {
                        accounts = new List<Account>([SELECT Id,Name from Account Where Id in(SELECT AccountId From Asset Where Munchkin_Id__c != Null AND Munchkin_Id__c like: tmpAccMunchkinId)]);
                    } else if(tmpAccName != '') {
                    system.debug('tmpAccName =====>'+tmpAccName );
                        accounts = new List<Account>([SELECT Id,Name from Account Where Id in(SELECT AccountId From Asset Where Munchkin_Id__c != Null AND Account.Name like: tmpAccName)]);
                        //system.debug('accounts =====>'+ SELECT Id,Name from Account Where Id in(SELECT AccountId From Asset Where Munchkin_Id__c != Null AND Name like tmpAccName;
                    } 
                     system.debug('accounts =====>'+accounts );                                       
                    total_size =  accounts.size();
                     system.debug('total_size =====>'+total_size );                    
                    //tmpQuery = '%' + query + '%';                       
                    //total_size =  [SELECT count() from Account Where name like : tmpQuery and Type IN ('Customer','Partner','Customer & Partner') Limit :upperLimit];
                    //accounts = new List<Account>([SELECT id, Name, billingstreet, billingcity, billingpostalcode, Owner.Name from Account Where name like : tmpQuery AND Type IN ('Customer','Partner','Customer & Partner') ORDER BY Name LIMIT :list_size offset :counter]);                    
                } else { 
                    total_size = 0;
                    accounts.clear();
                }
            } else {
                total_size = 0;
                accounts.clear();
            }            
        } catch (Exception ex) {
            total_size = 0;
            accounts = new List<account>();
            accounts.clear();
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please Fill Search String.');
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
        return counter/list_size +1;
    } 
    public Integer getTotalPages() {
        if ( math.mod(total_size, list_size) == 0 ) 
            return (total_size/list_size);
        else 
            return (total_size/list_size)+1;        
    }           
}