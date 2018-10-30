trigger CallBatchCreateGS4WeeklyUsageData on Usage_Data_Load_Detail__c (after insert) {
    boolean callBatchFlag = FALSE;
    for(Usage_Data_Load_Detail__c uDataLoadDetail :Trigger.new){
        if(uDataLoadDetail.Start_Batch_Process__c == TRUE){
            callBatchFlag = TRUE;
        }
    }
    
    if(callBatchFlag == TRUE){     
        BatchCreateGS4WeeklyUsageData batchCreateAccConUData = new BatchCreateGS4WeeklyUsageData();
        database.executeBatch(batchCreateAccConUData, 10);
    }
}