/*********************************************************************
Updated by: Jade Global 
Updated On: 4th June 2017
Updated for: 
  # Reference: APPS-12993:New Code for Contact Ownership
  # Changed functionality for APPS-12993

Updated by: Tushar Misri, Grazitti 
Updated On: 17 th May 2018
Updated for: 
              # Reference: APPS-20040 : Contact Owners Moving 
              # Added the field in the query Account.Business_Unit__c 
              # Added a check for Exclude certain Business Units which performs the update of Contact Owner as Account's SDR Owner - Exclude_Business_Units__c 
************************/


global class BatchUpdateContactOwner implements Database.Batchable<sObject> {

    public List<Contact> updateContact = new List<Contact>();
    public Set<Id> accIds = new Set<Id>();
    public Map<Id,Account> accMap = new Map<Id,Account>();
	public Map<string,Exclude_Business_Units__c> ExcludeBusinessUnitsvalues = Exclude_Business_Units__c.getAll();
    public Set<String> contactStatusValue_DoNotUpdateContactOwner = new Set<String>(System.Label.ContactStatusValue_DoNotUpdateContactOwner.split('#'));
    
    global BatchUpdateContactOwner(Set<Id> accountIds, Map<Id,Account> accountListsMap){
        accIds = accountIds;
        accMap = accountListsMap;
        system.debug('accIds'+accIds);
        system.debug('accMap'+accMap);
    }//End of BatchUpdateContactOwner()
    
    
    global List<Contact> start(Database.BatchableContext BC) {
        
        return new List<Contact>([SELECT OwnerId, Owner.Name, SDR_Owner__c, Account.Target_Account_1__c, Account.SDR_Owner_Picklist__c, Account.OwnerId, Account.Owner.isActive,
// APPS-20040 Added check for Exclude_Business_Units__c (custom Setting)
            /*LS_Deal_Score__c,*/LS_Account_Score__c,AccountId,Contact_Status__c,Account_Category__c,Account.Account_Category__c,Account.SDR_Owner_Lookup__c,SDR_Owner_Look_Up__c,Account.New_Business_Account_Executive__c FROM Contact WHERE ((AccountId IN : accIds OR AccountId IN:accMap.keySet()) and(Not(Account.Business_Unit__c In :ExcludeBusinessUnitsvalues.keySet()))) LIMIT 40000 /*AND Contact_Status__c NOT IN: contactStatusValue_DoNotUpdateContactOwner*/]);
    }//End of Start()
    
    global void execute(Database.BatchableContext BC, List<Contact> relatedContacts) {
       
        List<Contact> contactToBeUpdated    = new List<Contact>();
        Set<Id> contactswithAccSDROwner = new Set<Id>();   
        boolean isUpdateable = false;       
        
        for(contact con : relatedContacts){
                   
           if(con.Account.Account_Category__c!=null||(con.Account.Account_Category__c==null && contactStatusValue_DoNotUpdateContactOwner != null && con.Contact_Status__c!=null && contactStatusValue_DoNotUpdateContactOwner.contains(con.Contact_Status__c ))){
           
                    con.OwnerId = con.account.OwnerId;
                    
                    con.SDR_Owner_Look_Up__c = con.Account.SDR_Owner_Lookup__c; 
                    
                    con.SDR_Owner__c= con.Account.SDR_Owner_Picklist__c;
                    
                    isUpdateable = true;
                    
                       
           }
           
           else if((con.Account.Account_Category__c==null && contactStatusValue_DoNotUpdateContactOwner != null && con.Contact_Status__c!=null && !contactStatusValue_DoNotUpdateContactOwner.contains(con.Contact_Status__c ))){
           
                   con.OwnerId         = con.Account.SDR_Owner_Lookup__c; 
                   con.SDR_Owner_Look_Up__c = con.Account.SDR_Owner_Lookup__c; 
                   con.SDR_Owner__c        = con.Account.SDR_Owner_Picklist__c;
                   isUpdateable = true;  
           
           }
            if(isUpdateable){
                    if(accMap != null && accMap.containsKey(con.AccountId)){
                          con.LS_Account_Score__c = accMap.get(con.AccountId).LS_Account_Score__c;    
                    }//End of If
                    
                    contactToBeUpdated.add(con); 
                    
                }else{
                    if(accMap != null && accMap.containsKey(con.AccountId)){
                        con.LS_Account_Score__c = accMap.get(con.AccountId).LS_Account_Score__c;    
                        contactToBeUpdated.add(con); 
                    }//End of If
                }// End of else               
               
          }// End of For        
        
        Database.update(contactToBeUpdated, false);
        System.Debug('*******BATCH SIZE**'+contactToBeUpdated.Size());
    }// End of execute()
    
    global void finish(Database.BatchableContext BC){
    }// End of finish
    
    
}// End of Class BatchUpdateContactOwner