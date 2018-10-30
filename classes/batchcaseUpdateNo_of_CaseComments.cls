/*****************************************************************
*Modified By: Sumit Bhatt, Grazitti Interactive
*Purpose: REF: #APPS-18580# Update Test Classes
*Tracking: One cn track the changes by searching ticket number in code
*****************************************************************/
global class batchcaseUpdateNo_of_CaseComments implements Database.Batchable<sobject> {
  
    global Database.QueryLocator start(Database.BatchableContext bc){
        Id userId = userInfo.getUserID();
        // String query = '';
      //APPS-18580
        //return Database.getQueryLocator(system.label.BatchCCQuery);
    return Database.getQueryLocator(system.label.BatchCCQuery+(Test.isRunningTest() ? ' LIMIT 200' : ''));
    //APPS-18580
    }
      
    global void execute(Database.BatchableContext bc, List<case> scope) {
        CaseHandler.isUpdatingCase = true;
        for(case cas : scope) {
            cas.No_of_CaseComments__c = cas.casecomments.size();
        }
        Database.update(scope,false);
    }
      
    global void finish(Database.BatchableContext bc) {
      
    }
}