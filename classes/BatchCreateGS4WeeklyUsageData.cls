global class BatchCreateGS4WeeklyUsageData implements Database.Batchable<sObject>{
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator('select id, Usage_Data_Key_Indexed__c, JBCXM__Account__c, JBCXM__InstanceId__c, Year__c, Week_Group4_Number__c, Week_Number__c, Is_Updated__c FROM JBCXM__UsageData__c WHERE Is_Updated__c = FALSE');
    }

    global void execute(Database.BatchableContext BC, List<JBCXM__UsageData__c> usageDataList){
        Set<String> usageDataKeySet = new Set<String>();
        Set<Id> accountIdSet = new Set<Id>();
        Set<String> instanceIdSet = new Set<String>();
        Set<integer> yearSet = new Set<integer>();
        
        for(JBCXM__UsageData__c usageData :usageDataList){
             if(usageData.JBCXM__InstanceId__c != null && math.mod(integer.valueOf(usageData.Week_Number__c), 4)==0){
                 if(usageData.Usage_Data_Key_Indexed__c != null){
                     usageDataKeySet.add(usageData.Usage_Data_Key_Indexed__c);
                     accountIdSet.add(usageData.JBCXM__Account__c);
                     instanceIdSet.add(usageData.JBCXM__InstanceId__c);
                     yearSet.add(integer.valueOf(usageData.Year__c));
                     yearSet.add(integer.valueOf(usageData.Year__c)-1);
                 }    
             }
        }
        
        CreateAccConGSUsageDataController createAccConUsageDataCon = new CreateAccConGSUsageDataController();
        createAccConUsageDataCon.CreateAccContactGSUsageData(usageDataKeySet, accountIdSet, instanceIdSet, yearSet);
        
        for(JBCXM__UsageData__c usageData :usageDataList){
            usageData.Is_Updated__c = TRUE;
        }
        update usageDataList;
    }

    global void finish(Database.BatchableContext BC){
        AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems, CreatedBy.FirstName, 
        CreatedBy.Email FROM AsyncApexJob WHERE Id = :BC.getJobId()];
        
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        String[] toAddresses = new String[] {a.CreatedBy.Email};
        mail.setToAddresses(toAddresses);
        mail.setSubject('Usage Data Batch Execution Results');
        mail.setPlainTextBody
        ('Dear ' + a.CreatedBy.FirstName + ', \n \n' +
        'The Usage Data batch job has processed ' + a.TotalJobItems +
        ' batches with '+ a.NumberOfErrors + ' failures.\n\n' +
        'Please check the Apex Jobs queue for more details');
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
    }
}