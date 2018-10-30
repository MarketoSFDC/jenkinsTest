global class ProactometerScheduler implements Schedulable {
    // This test runs a scheduled job at midnight Sept. 3rd. 2022
    
    global void execute(SchedulableContext ctx) {
        if(Support_Switches__c.getInstance('ProactometerBatchSwitch')!= null && Support_Switches__c.getInstance('ProactometerBatchSwitch').isActive__c == 'Yes'){
            ProactometerBatch cqrb = new ProactometerBatch();
            database.executebatch(cqrb,200);
        }
        
    }     
}