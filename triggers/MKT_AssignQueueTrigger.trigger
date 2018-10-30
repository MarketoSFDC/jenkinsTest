trigger MKT_AssignQueueTrigger on MKT_AssignQueue__c (before insert) {
    public Integer JobsSizeLimit = 4;
    System.debug('MKT_AssignQueueTrigger start =============');
    private Integer JobsSize;
    List<AsyncApexJob> StartedJobsList = [SELECT TotalJobItems, Status, ParentJobId, JobType, Id, ApexClass.Name, ApexClassId FROM AsyncApexJob WHERE Jobtype = 'BatchApex' AND ( Status = 'Queued' OR Status = 'Processing')];
    JobsSize = StartedJobsList.Size();
    List<MKT_AssignQueue__c> ProccessingAssignList = new List<MKT_AssignQueue__c>();
    //if (JobsSize == JobsSizeLimit ) return;
    Map<String, AsyncApexJob> ClassNameJobItemMap = new Map<String, AsyncApexJob>();
    for (AsyncApexJob StartedJob :StartedJobsList) {
        ClassNameJobItemMap.Put(StartedJob.ApexClass.Name, StartedJob);
    }
    Integer JobsSizeTemp = JobsSize;
    for (MKT_AssignQueue__c AssignQueueItem : trigger.new) {
        if (JobsSizeTemp >= JobsSizeLimit) break;
        if(AssignQueueItem.MKT_Status__c == 'Pending' && !ClassNameJobItemMap.containsKey(AssignQueueItem.MKT_ApexClassName__c)) {
            ProccessingAssignList.Add(AssignQueueItem);
            JobsSizeTemp ++;
        }
    }
    List<MKT_AssignQueue__c> AssignListForUpdate = new List<MKT_AssignQueue__c>();
    Set<String> ClassNameJobSet = new Set<String>();
    for(MKT_AssignQueue__c AssignQueueItem :ProccessingAssignList) {
        if (JobsSize >=  JobsSizeLimit) break;
        if (AssignQueueItem.MKT_ApexClassName__c == 'MKT_BatchAssign') {
            if(AssignQueueItem.MKT_SerializedData__c != NULL && AssignQueueItem.MKT_SerializedData__c != '' && !ClassNameJobSet.contains(AssignQueueItem.MKT_ApexClassName__c)) {
                Set<String> NewOrderItemsSet = (Set<String>)JSON.deserialize(AssignQueueItem.MKT_SerializedData__c, Set<String>.class );
                System.debug('MKT_AssignQueueTrigger NewOrderItems ============='+NewOrderItemsSet);
                /*List<kumocomm__OrderItem__c> NewOrderItems = [SELECT Id, MKT_Class__c, kumocomm__Amount__c, kumocomm__Order__c, kumocomm__Product__c, kumocomm__Quantity__c, kumocomm__Order__r.kumocomm__Contact__c FROM kumocomm__OrderItem__c WHERE Id IN  :NewOrderItemsSet];
                MKT_BatchAssign b = new MKT_BatchAssign();
                b.recs = NewOrderItems;
                Set<String> ClassIdsB = new Set<String>();
                for (kumocomm__OrderItem__c NewOrderItemB :NewOrderItems) {
                    if (NewOrderItemB.MKT_Class__c != NULL) ClassIdsB.Add(NewOrderItemB.MKT_Class__c);
                }
                b.ClassIds = ClassIdsB;
                Id batchprocessid = Database.executeBatch(b, 1);*/
                AssignQueueItem.MKT_Status__c = 'Proccessing';
                //AssignQueueItem.MKT_AsyncApexJobId__c = batchprocessid;
                AssignListForUpdate.Add(AssignQueueItem);
                ClassNameJobSet.Add(AssignQueueItem.MKT_ApexClassName__c);
                System.debug('MKT_AssignQueueTrigger AssignListForUpdate ============='+AssignListForUpdate);
            }
        }
        if (AssignQueueItem.MKT_ApexClassName__c == 'BatchRegisterForTraining') {
            if (AssignQueueItem.MKT_SerializedData__c != NULL && AssignQueueItem.MKT_SerializedData__c != '' && !ClassNameJobSet.contains(AssignQueueItem.MKT_ApexClassName__c)) {
                String Query = (String)JSON.deserialize(AssignQueueItem.MKT_SerializedData__c, String.class);
                System.debug('BatchRegisterForTraining Query ============='+Query);
                lmsilt.BatchRegisterForTraining b = new lmsilt.BatchRegisterForTraining();
                b.Query = Query;
                Id batchprocessid = Database.executeBatch(b, 1);
                AssignQueueItem.MKT_Status__c = 'Proccessing';
                AssignQueueItem.MKT_AsyncApexJobId__c = batchprocessid;
                AssignListForUpdate.Add(AssignQueueItem);
                ClassNameJobSet.Add(AssignQueueItem.MKT_ApexClassName__c);
                System.debug('BatchRegisterForTraining AssignListForUpdate ============='+AssignListForUpdate);
            }
        }
        /*if (AssignQueueItem.MKT_ApexClassName__c == 'BatchUpdateWebEx') {
            if (AssignQueueItem.MKT_SerializedData__c != NULL && AssignQueueItem.MKT_SerializedData__c != '' && !ClassNameJobSet.contains(AssignQueueItem.MKT_ApexClassName__c)) {
                String Query = (String)JSON.deserialize(AssignQueueItem.MKT_SerializedData__c, String.class);
                System.debug('BatchUpdateWebEx Query ============='+Query);
                lmsilt.BatchUpdateWebEx b = new lmsilt.BatchUpdateWebEx();
                b.Query = Query;
                Id batchprocessid = Database.executeBatch(b, 1);
                AssignQueueItem.MKT_Status__c = 'Proccessing';
                AssignQueueItem.MKT_AsyncApexJobId__c = batchprocessid;
                AssignListForUpdate.Add(AssignQueueItem);
                ClassNameJobSet.Add(AssignQueueItem.MKT_ApexClassName__c);
                System.debug('BatchUpdateWebEx AssignListForUpdate ============='+AssignListForUpdate);
            }
        }*/
        if (AssignQueueItem.MKT_ApexClassName__c == 'BatchUnRegisterForTraining') {
            if (AssignQueueItem.MKT_SerializedData__c != NULL && AssignQueueItem.MKT_SerializedData__c != '' && !ClassNameJobSet.contains(AssignQueueItem.MKT_ApexClassName__c)) {
                String Query = (String)JSON.deserialize(AssignQueueItem.MKT_SerializedData__c, String.class);
                System.debug('BatchUnRegisterForTraining Query ============='+Query);
                lmsilt.BatchUnRegisterForTraining b = new lmsilt.BatchUnRegisterForTraining();
                b.Query = Query;
                Id batchprocessid = Database.executeBatch(b, 1);
                AssignQueueItem.MKT_Status__c = 'Proccessing';
                AssignQueueItem.MKT_AsyncApexJobId__c = batchprocessid;
                AssignListForUpdate.Add(AssignQueueItem);
                ClassNameJobSet.Add(AssignQueueItem.MKT_ApexClassName__c);
                System.debug('BatchUnRegisterForTraining AssignListForUpdate ============='+AssignListForUpdate);
            }
        }
    }
    try {
        HelperWithoutSharing.StartAssignJob();
    }
    catch (Exception e) {}

    //if(AssignListForUpdate.Size() > 0) update AssignListForUpdate;





}