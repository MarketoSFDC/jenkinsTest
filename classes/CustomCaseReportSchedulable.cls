global class CustomCaseReportSchedulable implements Schedulable {

    global void execute(SchedulableContext context) {
        Set<Id> eliteAccIds = new Set<Id>();        
        //Get list of all active entitlements of type Premier PremierPlus and Elite 
        
        List<Entitlement> entitLst = new List<Entitlement>();
        if(Test.isRunningTest()) // Test running scale to 200  
            entitLst = [SELECT Id, Entitlement_Status__c, Type, Account.Id FROM Entitlement where Type in ('Elite','Premier','Premier Plus','Microsoft','Business') and Entitlement_Status__c = 'Active' AND Account.Account_Sub_Type__c != 'Ex-Customer' AND Account.Partner_Type__c != 'Ex-Partner' order by Account.Id Limit 200];
        else
            entitLst = [SELECT Id, Entitlement_Status__c, Type, Account.Id FROM Entitlement where Type in ('Elite','Premier','Premier Plus','Microsoft','Business') and Entitlement_Status__c = 'Active' AND  Account.Account_Sub_Type__c != 'Ex-Customer' AND Account.Partner_Type__c != 'Ex-Partner' order by Account.Id];
        
        //SELECT Id, Entitlement_Status__c, Type,SLaProcess.Name, Account.Id FROM Entitlement where Entitlement_Status__c = 'ACtive'
        for(Entitlement tmp : entitLst) {
            eliteAccIds.Add(tmp.Account.Id);
        }        
        if(eliteAccIds.isEmpty() == FALSE) {
            CustomCaseReportBatchable cqrb = new CustomCaseReportBatchable(eliteAccIds);            
            if(Test.isRunningTest()) {
                database.executeBatch(cqrb);
            } else {
                //Execute the batch, 5 accs at a time.
                database.executebatch(cqrb,5);
            }
        }
    }
}