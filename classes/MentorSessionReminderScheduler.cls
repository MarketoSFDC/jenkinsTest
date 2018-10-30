global class MentorSessionReminderScheduler implements Schedulable {  
    //Execute Callled
    global void execute(SchedulableContext context) {
        MentorSessionReminderBatchable msrb = new MentorSessionReminderBatchable();            
        database.executeBatch(msrb);
    }
    //Main method that will handle all the operations
    /*
    public void insertNewEnts() {
        system.debug('Main Method Call ==>');
        // Variable declaration.
        set<Entitlement> listEnts    = new set<Entitlement>();         
        map<Id,Id> entIdToAuthCont  = new map<Id,Id>();        
        Id proactiveCaseRecord = '01238000000E8aV';//'01238000000E8aVAAS'; //prod     
        list<Case> insertCases = new list<Case>();
        for(Entitlement ent: [SELECT id, name, type, named_support_engineer__c, named_support_engineer__r.email, named_support_engineer__r.isActive, technical_account_manager__r.isActive, technical_account_manager__c, technical_account_manager__r.email, (Select id from cases where CreatedDate=THIS_QUARTER AND recordTypeID='01250000000UJwx' AND problem_type__c='Mentoring Session' Limit 1) ,(SELECT Contact__c, Contact__r.AccountId, Contact__r.Account.Name FROM Authorized_Contacts__r WHERE Customer_Admin__c = True Limit 1)  FROM Entitlement WHERE  Status = 'Active' AND Support_Region__c = 'North America' AND Type IN ('Elite','Microsoft', 'Premier', 'Premier Plus','Premier Support US','UPS')]) {
            system.debug('Size==>>'+ ent.cases.size()+' ent==>>'+ent);
            system.debug(ent.Authorized_Contacts__r.size());
            if(ent.cases.size() == 0 && ent.Authorized_Contacts__r.size() > 0) {
                system.debug('ent.named_support_engineer__c==>> '+ent.named_support_engineer__c + ' ' +  ent.named_support_engineer__r.isActive);
                //
                case cs = new case(recordTypeID = proactiveCaseRecord, Problem_Type__c = 'Account Notification',Origin = 'Proactive',Category__c= 'Unused Mentor Session');
                cs.contactID = ent.Authorized_Contacts__r[0].Contact__c;
                if(ent.named_support_engineer__c != null && (ent.type=='Premier' || ent.type=='Premier Plus' || ent.type=='Premier Support US')){
                    system.debug('entered if 1 ==>');
                    cs.OwnerID = ent.named_support_engineer__c;                    
                }                  
                if(ent.technical_account_manager__c != null && (ent.type=='Elite' || ent.type=='UPS' || ent.type=='Microsoft')  ){
                    cs.OwnerID = ent.technical_account_manager__c;                                          
                }                    
                //system.debug('OwnerId==>'+cs.OwnerID +' ContactId==>'+ cs.contactID);
                cs.subject = ent.Name+ ' has not used any mentor sessions this quarter';  
                cs.description = ent.Name+ ' has no recorded mentor sessions on file for this quarter. Please evaluate and reach out as necessary.';      
                insertCases.add(cs);                            
            }        
        } 
        insert insertCases;                                    
    }*/
}