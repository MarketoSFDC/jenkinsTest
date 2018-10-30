/*********************************************************************
* Last Modified by   : Grazitti 
* Modified Date      : 28-April-18
* Purpose            : #01009688 Consolidate Support Engineer Fields on Entitlement
* Line numbers       : 20

**********************************************************************/

global class MentorSessionReminderBatchable implements Database.Batchable<Entitlement> {
    public list<Entitlement> entsToTarget;    
    
    public MentorSessionReminderBatchable() {
        entsToTarget = new list<Entitlement>();         
    }
    
    global Iterable<Entitlement> start (database.batchablecontext BC) {
        Integer cntMax = 10000;
        if(Test.isRunningTest()) cntMax = 200;
        Set<String> premierTypes = new Set<String>{'Elite','Microsoft', 'Premier', 'Premier Plus','Premier Support US','UPS'};        
        for(Entitlement ent: [SELECT id, name, type, Account.Name, AssignedSupportPOC__c,AssignedSupportPOC__r.email, AssignedSupportPOC__r.isActive,(Select id from cases where CreatedDate=THIS_QUARTER AND recordTypeID='01250000000UJwx' AND problem_type__c='Mentoring Session' Limit 1) ,(SELECT Contact__c, Contact__r.AccountId, Contact__r.Account.Name FROM Authorized_Contacts__r WHERE Customer_Admin__c = True Limit 1)  FROM Entitlement WHERE  Status = 'Active' AND Support_Region__c = 'North America' AND Type IN :premierTypes Limit :cntMax ]) {
            system.debug('Size==>>'+ ent.cases.size()+' ent==>>'+ent);
            system.debug(ent.Authorized_Contacts__r.size());
            if(ent.cases.size() == 0 && ent.Authorized_Contacts__r.size() > 0) {
                system.debug('ent==>> '+ent);                        
                entsToTarget.add(ent);        
            }
        }
        return (entsToTarget);    
    }  
    
    global void finish(Database.BatchableContext BC){
    
    }
    
    global void execute(Database.BatchableContext BC, List<Entitlement> scope) {
        Id proactiveCaseRecord = '01238000000E8aV';
        list<Case> insertCases = new list<Case>();
        for(Entitlement ent: scope) {
            case cs = new case(recordTypeID = proactiveCaseRecord, Problem_Type__c = 'Account Notification',Origin = 'Proactive',Category__c= 'Unused Mentor Session');
            cs.contactID = ent.Authorized_Contacts__r[0].Contact__c;
            cs.OwnerID = Label.ProActiveUserId;      // proactive User.                
            cs.subject = ent.Name+ ' has not used any mentor sessions this quarter';  
            cs.description = 'An email reminder about unused mentor sessions was sent to the authorized contacts of ' +ent.account.name;      
            cs.Status = 'Closed';
            insertCases.add(cs);   
        }
        if(insertCases != null && insertCases.size() > 0){
            insert insertCases;
        }  
    }
}