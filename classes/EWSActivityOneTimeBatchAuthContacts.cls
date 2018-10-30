global class EWSActivityOneTimeBatchAuthContacts{
    public EWSActivityOneTimeBatchAuthContacts(){}
    /*  implements Database.Batchable<sObject> 
    global String Query = 'Select id,createddate,contact__c,contact__r.name, contact__r.accountid from Authorized_Contact__c where contact__r.accountid != null'+(Test.isRunningTest()?' LIMIT 200':'');
    global EWSActivityOneTimeBatchAuthContacts(){}
    global EWSActivityOneTimeBatchAuthContacts(String x){
        Query = x;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<Id,List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>> accountIdsForEWSMap = new Map<Id,List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>>();
        List<Authorized_Contact__c> authContacts = (List<Authorized_Contact__c>)scope;
        for(Authorized_Contact__c ac : authContacts){
            List<EWSActivityOneTimeBatchAccount.activityInfoWrapper> temp = new List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>();
            if(accountIdsForEWSMap.containsKey(ac.contact__r.accountid)) temp = accountIdsForEWSMap.get(ac.contact__r.accountid);                      
                EWSActivityOneTimeBatchAccount.activityInfoWrapper accWrap = new EWSActivityOneTimeBatchAccount.activityInfoWrapper();
                accWrap.name = 'New Authorized Contact';
                accWrap.subDriver = 'New Authorized Contact';
                accWrap.description = ac.contact__r.name +' became a new Authorized Contact';
                accWrap.historyDate = ac.createddate;
                temp.add(accWrap);                        
                accountIdsForEWSMap.put(ac.contact__r.accountid,temp); 
                }
            
            if(accountIdsForEWSMap.size()>0) EWSActivityOneTimeBatchAccount.createrEWSActivities(accountIdsForEWSMap);
        }
        

    
    global void finish(Database.BatchableContext BC){
        EWSActivityOneTimeBatchAccount.sendEmail('EWSActivityOneTimeBatchAuthContacts');
    }
    */
}