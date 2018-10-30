/****************************************
Last Modified by: Sumit Bhatt,Grazitti
Purpose: Added the check in query to exclude the Account with business units Present in the custom setting Exclude_Business_Unit [Ticket REF: APPS-17080]
****************************************/

global class ScheduleBatchUpdateContactOwner implements Schedulable{
    
    public static Map<Id,Account> accMap = new Map<Id,Account>();
    map<string,Exclude_Business_Units__c> BUMap=Exclude_Business_Units__c.getAll();
    
    global void execute(schedulablecontext sc){
        if(accMap.isEmpty() || accMap == null){
            for(Account acc : [ SELECT ID, OwnerId, Owner.isActive, SDR_Owner_Picklist__c, LS_Deal_Score__c, LS_Account_Score__c, Target_Account_1__c FROM Account WHERE LastModifiedDate = Today and (Not Business_Unit__c IN : BUMap.keyset()) LIMIT 10000]){
                accMap.put(acc.Id, acc);
            }
        }
        if(!accMap.isEmpty()){
            BatchUpdateContactOwner batchUpdt = new BatchUpdateContactOwner (accMap.keySet(), accMap);
            ID batchprocessid = Database.executeBatch(batchUpdt,100);
        }
    }
}

/*
ScheduleBatchUpdateContactOwner obj = new ScheduleBatchUpdateContactOwner();
String sch = '0 0 * * * ?';
system.schedule('ScheduleBatchUpdateContactOwner', sch, obj);
*/