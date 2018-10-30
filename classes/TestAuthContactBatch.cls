Public Class TestAuthContactBatch implements Database.Batchable <sObject>{

    public Database.QueryLocator start(Database.BatchableContext BC){
        String query = 'Select id,contact__c,contact__r.firstname,contact__r.lastname,contact__r.email,contact__r.accountid,entitlement__c from Authorized_Contact__c where password__c = null AND contact__r.account.Bizible_customer__c = true AND entitlement__r.type IN (\'Bizible Business\',\'Bizible Online\') limit 10';
        return Database.getQueryLocator(query);    
    }
    
    public void execute(Database.BatchableContext BC, List<Authorized_Contact__c> scope){
       List<Authorized_Contact__c> alist = new List<Authorized_Contact__c>();
       for(Authorized_Contact__c ac : scope){
           Authorized_Contact__c a = new Authorized_Contact__c();
           a.contact__c = ac.contact__c;
           a.entitlement__c = ac.entitlement__c;
           alist.add(a);
       }
       Insert alist;
    }
    public void finish(Database.BatchableContext BC){
    
    }
}