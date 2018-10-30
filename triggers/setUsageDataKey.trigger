trigger setUsageDataKey on JBCXM__UsageData__c (before Insert, before update) {
    for(JBCXM__UsageData__c usageData :Trigger.new){
        usageData.Usage_Data_Key_Indexed__c = usageData.JBCXM__Account__c + '_' + usageData.JBCXM__InstanceId__c + '_' + string.ValueOf(integer.ValueOf(usageData.Year__c)) + '_' + string.ValueOf(integer.valueOf(usageData.Week_Group4_Number__c));
    }
    
    InitializeUsageDataController IUD = new InitializeUsageDataController();
    IUD.InitializeUsageData(Trigger.new);
}