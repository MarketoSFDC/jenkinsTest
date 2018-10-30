global class BatchUpdateOpportunityOwner implements Database.Batchable<sObject> {

public Set<Id> accIds = new Set<Id>();
public Map<Id,Account> accMap = new Map<Id,Account>();
    
global BatchUpdateOpportunityOwner (Set<Id> accountIds, Map<Id,Account> accountListsMap){
    accIds = accountIds;
    accMap = accountListsMap;
    system.debug('BatchUpdateOpportunityOwner ');
}

global List<Opportunity> start(Database.BatchableContext BC) {
    system.debug('start');
    return new List<Opportunity>([Select Id,OwnerId,AccountId,Account.CAM_Owner__c,Account.CRT_Owner__c from Opportunity where AccountId IN : accIds and StageName != 'Closed Won' and StageName != 'Closed Lost' and Type = 'Renewal']);
}

global void execute(Database.BatchableContext BC, List<Opportunity> relatedOpportunity) {
    system.debug('relatedOpportunity'+relatedOpportunity);
    List<opportunity> lstOppo2update = new List<opportunity>();
    Map<Id,Id> mapId2Opp = new Map<Id,Id>();
    
    for(Opportunity opp : relatedOpportunity){
        //CRT_Owner condition added by Cassandrea Steiner on 10.17.17 for APPS-15482
        if(opp.Account.CRT_Owner__c != null && opp.OwnerId != opp.Account.CRT_Owner__c){
            opp.OwnerId = opp.Account.CRT_Owner__c;
        }else if (opp.Account.CRT_Owner__c == null && opp.Account.CAM_Owner__c != null){ 
        opp.OwnerId = opp.Account.CAM_Owner__c;
        }
        lstOppo2update.add(opp);
    }
    if(!lstOppo2update.isEmpty()){
        system.debug('2UpdateBatch'+lstOppo2update);
        Database.Update(lstOppo2update,true);
    }
}

global void finish(Database.BatchableContext BC){

}

}