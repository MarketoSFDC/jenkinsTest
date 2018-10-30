global class BatchUncheckUsageDataCheckBox implements Database.Batchable<sObject>{
   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator('select id, Is_Updated__c from JBCXM__UsageData__c');
   }

   global void execute(Database.BatchableContext BC, List<JBCXM__UsageData__c> usageDataList){
     for(JBCXM__UsageData__c usageData : usageDataList){
         usageData.Is_Updated__c = FALSE;
     }
     update usageDataList;
    }

   global void finish(Database.BatchableContext BC){
   }
}