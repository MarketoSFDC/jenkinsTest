trigger Populate_SupportAdmin_NameEmail on Authorized_Contact__c (after insert, after update, after delete) {
    
    // Authroized ContactId => ContactId Map
    Map<String, Id> upDtAuthContListTrue = new Map<String,Id>();    
    Map<String, Id> upDtAuthContListFalse = new Map<String,Id>();       
    Map<String, Id> delAuthContListTrue = new Map<String,Id>();    
    
    //Delete Trigger
    if( Trigger.isDelete ) {
        for(Authorized_Contact__c AuthCnt : trigger.old)
        {
            if( AuthCnt.Entitlement__c != null  && AuthCnt.Customer_Admin__c == true  && AuthCnt.Contact__c != null )
                delAuthContListTrue.put(AuthCnt.Entitlement__c,null);        
        }    
    
    } else {     //Insert Update Trigger
      
        for (Authorized_Contact__c AuthCnt : Trigger.New) {
        
            if(Trigger.IsInsert){ //Insert Trigger set true list
                if(AuthCnt.Entitlement__c != null && AuthCnt.Customer_Admin__c == true && AuthCnt.Contact__c != null) {
                    upDtAuthContListTrue.put(AuthCnt.Entitlement__c,AuthCnt.Contact__c);        
                }
            } else { // Update Trigger  
                Boolean isChanged = False;                
                
                if( AuthCnt.Customer_Admin__c != Trigger.oldMap.get(AuthCnt.Id).Customer_Admin__c) { //If admin status changed thru check box
                    
                    //Set True list
                    if (AuthCnt.Entitlement__c != null && AuthCnt.Customer_Admin__c == true && AuthCnt.Contact__c != null) { 
                        upDtAuthContListTrue.put(AuthCnt.Entitlement__c,AuthCnt.Contact__c); 
                
                    } else if(AuthCnt.Entitlement__c != null && AuthCnt.Customer_Admin__c == false && AuthCnt.Contact__c != null) {
                        //Else set False List
                        upDtAuthContListFalse.put(AuthCnt.Entitlement__c,NULL);                      
                    }                                        
                }
            }    
        }            
    }

    Set<String> myAuthContactsUpdated = new Set<String>(); // Add all items to run for query
    myAuthContactsUpdated.AddAll(upDtAuthContListTrue.keySet());    
    myAuthContactsUpdated.AddAll(upDtAuthContListFalse.keySet()); 
    myAuthContactsUpdated.AddAll(delAuthContListTrue.keySet()); 
    
    
    List<Entitlement> updateEntitlements = new List<Entitlement>();    
    List<Entitlement> tobeUpdatedEntitlements = new List<Entitlement>();
    tobeUpdatedEntitlements  = [SELECT Id, Support_Admin_Contact__c from Entitlement where ID in :myAuthContactsUpdated and status = 'active'];
    for(Entitlement myEntl : tobeUpdatedEntitlements) {
        if(upDtAuthContListTrue.containsKey(myEntl.Id)) {
            myEntl.Support_Admin_Contact__c = upDtAuthContListTrue.get(myEntl.Id);
            updateEntitlements.Add(myEntl);
        } else if(upDtAuthContListFalse.containsKey(myEntl.Id) || delAuthContListTrue.containsKey(myEntl.Id)) {            
            myEntl.Support_Admin_Contact__c = null;
            updateEntitlements.Add(myEntl);        
        }        
    }
    
    //finally run the update query.
    if(!updateEntitlements.isEmpty()) { Update updateEntitlements; }               
    
    
}