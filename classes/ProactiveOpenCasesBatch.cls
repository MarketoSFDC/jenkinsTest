Public Class ProactiveOpenCasesBatch implements Database.Batchable <sObject>{

    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(Label.ProactiveOpenCasesQuery);
    }
    
    public void execute(Database.BatchableContext BC, List<Case> scope){
        Map<Id,List<case>> contCaseMap = new Map<Id,List<case>>();
        List<Case> listToInsert = new List<Case>();
        List<Case> cseList = new List<Case>();
        Set<Id> contactIds = new Set<Id>();
        
        for(Case cseObj : scope){
            contactIds.add(cseObj.contactId);
            if(contCaseMap.containskey(cseObj.contactId)) contCaseMap.get(cseObj.contactId).add(cseObj);
            else contCaseMap.put(cseObj.contactId,new list<case>{cseObj});
        }
        for(Id conId : contactIds){
            if(contCaseMap.containsKey(conId) && contCaseMap.get(conId).size() > 3){
                for(Case cse : contCaseMap.get(conId)){
                    listToInsert.add(new Case(description = 'Muliple Case has been open for the customer :'+cse.contact.name+' Please Take some actions',subject = 'Multiple Cases In Past 15 days',category__c = '3+OpenIssues',status = 'New',problem_type__c = 'Case Notification',accountid = cse.accountId,ownerId = Label.ProactiveQueueId,contactid = cse.contactId,entitlementid = cse.entitlementid,recordtypeId =  Label.ProActiveCaseRecTypeId));
                    break;
                }
            }
        }
        if(listToInsert.isEmpty() == false) Database.insert(listToInsert,false);
    }
    public void finish(Database.BatchableContext BC){
    
    }
}