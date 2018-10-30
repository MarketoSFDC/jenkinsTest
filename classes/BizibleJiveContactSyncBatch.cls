/*************************************************************
Created By - Grazitti Support Team
Purpose - To Sync Jive API for Bizible Customers
****************************************************************/

Public Class BizibleJiveContactSyncBatch implements Database.Batchable<sObject>,Database.AllowsCallouts{

    public Database.QueryLocator start(Database.BatchableContext BC){
        Datetime last24Hours = System.now().addHours(-24);
        String query = 'Select id,contact__c,contact__r.firstname,contact__r.lastname,contact__r.email,contact__r.accountid,entitlement__c from Authorized_Contact__c where createddate >: last24Hours AND password__c = null AND contact__r.account.Bizible_customer__c = true AND entitlement__r.type IN (\'Bizible Business\',\'Bizible Online\')';
        return Database.getQueryLocator(query);    
    }
    
    public void execute(Database.BatchableContext BC, List<Authorized_Contact__c> scope){
       try{
           JiveBizibleContactSync.performJiveApiCall(scope);
       }
       catch(Exception e){
           CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);
       }
    }
    public void finish(Database.BatchableContext BC){
    
    }
}