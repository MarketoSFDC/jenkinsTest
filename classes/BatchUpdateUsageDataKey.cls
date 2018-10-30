global class BatchUpdateUsageDataKey implements Database.Batchable<sObject>{
   global Database.QueryLocator start(Database.BatchableContext BC){
      return Database.getQueryLocator('select id, Usage_Data_Key_Indexed__c, JBCXM__Account__c, JBCXM__InstanceId__c, Year__c, Week_Group4_Number__c from JBCXM__UsageData__c');
   }

   global void execute(Database.BatchableContext BC, List<JBCXM__UsageData__c> usageDataList){
     for(JBCXM__UsageData__c usageData : usageDataList){
         usageData.Usage_Data_Key_Indexed__c = usageData.JBCXM__Account__c + '_' + usageData.JBCXM__InstanceId__c + '_' + string.ValueOf(integer.ValueOf(usageData.Year__c)) + '_' + string.ValueOf(integer.valueOf(usageData.Week_Group4_Number__c));
     }
     update usageDataList;
    }

   global void finish(Database.BatchableContext BC){
   }
}