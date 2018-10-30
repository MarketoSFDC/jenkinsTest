global class CaseQualityPopulateListMonthlyScheduled implements Schedulable {
    // This test runs a scheduled job at midnight Sept. 3rd. 2022
    
    global void execute(SchedulableContext ctx) {
        if(Label.CaseQualityReviewSwitch == 'Yes'){
            CaseQualityReviewBatchApex cqrb = new CaseQualityReviewBatchApex();
            database.executebatch(cqrb,60);
        }
        
    }     
}