global class CaseQualityWeeklyScheduled implements Schedulable {
    // This test runs a scheduled job at midnight Sept. 3rd. 2022
    
    global void execute(SchedulableContext ctx) {
        if(Label.CaseQualityReviewSwitch == 'Yes'){
            TSEQualityBatch cqrb = new TSEQualityBatch();
            database.executebatch(cqrb,60);
        }
        
    }     
}