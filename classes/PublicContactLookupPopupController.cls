public class PublicContactLookupPopupController
{
    private integer counter = 0;  //keeps track of the offset
    private integer list_size = 8; //sets the page size or number of rows
    public integer total_size = 0; //used to show user the total size of the list
    private integer upperLimit = 2000;
    public List<Contact> AuthCont {get; set;}
    
    public PublicContactLookupPopupController () {
        runQuery();
    }
                
    public PageReference runQuery() {
        AuthCont = new List<Contact>();
        total_size = 0;
        try {            
            //String selPhNo = ApexPages.currentPage().getParameters().get('phNo');
            //system.debug('selPhNo==>' + selPhNo + '  ' + ApexPages.currentPage().getParameters().get('phNo'));
            String selEmAdd = ApexPages.currentPage().getParameters().get('emAdd');
            system.debug('selEmAdd==>' + selEmAdd  + '  ' + ApexPages.currentPage().getParameters().get('emAdd'));
            Set<Id> contactIds = new Set<Id>();
            List<Id> AuthcontactIds = new List<Id>();
            string srchField = '%'+selEmAdd+'%';    
            system.debug('srchField==>' + srchField  );     
            if(selEmAdd != NULL && selEmAdd != '') {
                total_size =  [SELECT count() from Contact WHERE Account.Type !='Ex-Customer' AND Account.Type !='Ex-Partner' AND (Email like : srchField)];
                AuthCont = new List<Contact>([SELECT Id, Name, AccountId, Account.Name from Contact where Account.Type !='Ex-Customer' AND Account.Type !='Ex-Partner' AND (Email like : srchField) ORDER BY Name LIMIT :list_size offset :counter]);
                system.debug(total_size + 'AuthCont ==>' + AuthCont );
            }
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
 
    public Boolean getDisableNext() { 
        //this will disable the next and end buttons
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