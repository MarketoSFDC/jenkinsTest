public class ghostcaseController{
                     
    public id caseId              {get;set {caseId = value;}}   
    public string Action          {get;set;}
    public string accGhostAccess  {get;set;}
    public string caseGhostAccess {get;set;}
    public string conEmail        {get;set;}
    public string language        {get;set;}
    public boolean isAdmin;
             
    public string getDynamicHtml() {     
        list<Case> cs = [select id, contactId, contact.Email, Case_Ghost_Access__c, Account.Account_Ghost_Access__c, Contact.Preferred_Language__c from case where id=:caseId];
        if(cs!= null && cs.size() > 0){
            if(cs[0].Account.Account_Ghost_Access__c == null) accGhostAccess = 'All Cases'; 
            else accGhostAccess = cs[0].Account.Account_Ghost_Access__c;
            caseGhostAccess = cs[0].Case_Ghost_Access__c;      
            conEmail =  cs[0].contact.Email;
            language =  cs[0].contact.Preferred_Language__c ;
            list<Authorized_Contact__c > ac = [Select id, Entitlement__c, Entitlement__r.Status, customer_admin__c From Authorized_Contact__c where Contact__c != null AND Contact__c = :cs[0].ContactId AND Entitlement__r.status = 'Active' ];
            if(ac != null && ac.size() > 0) isAdmin = ac[0].customer_admin__c;          
        }
        if((accGhostAccess == null || accGhostAccess == 'All Cases' || accGhostAccess == 'Approval Needed' || (accGhostAccess == 'Never' && isAdmin == true)) && caseGhostAccess == 'Denied') Action = 'Allow';
        else if((accGhostAccess == null || accGhostAccess == 'All Cases' || accGhostAccess == 'Approval Needed' || (accGhostAccess == 'Never' && isAdmin == true)) && caseGhostAccess == 'Allowed') Action = 'Deny';
        else if(accGhostAccess =='Never' && caseGhostAccess == 'Allowed' && isAdmin == false) Action = 'Request Deny';
        else if(accGhostAccess =='Never' && caseGhostAccess == 'Denied' && isAdmin == false) Action = 'Request Allow';
        
        return '';            
    }  

}