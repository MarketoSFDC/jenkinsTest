global class ProactiveOpenCasesScheduler implements Schedulable {
    // This test runs a scheduled job at midnight Sept. 3rd. 2022
    
    global void execute(SchedulableContext ctx) {
            if(Support_Switches__c.getInstance('ProactiveOpenCasesBatchSwitch')!= null && Support_Switches__c.getInstance('ProactiveOpenCasesBatchSwitch').isActive__c == 'Yes'){
            ProactiveOpenCasesBatch cqrb = new ProactiveOpenCasesBatch();
            database.executebatch(cqrb,200);
        }
        
    }     
}