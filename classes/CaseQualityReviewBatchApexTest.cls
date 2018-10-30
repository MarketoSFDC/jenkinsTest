@isTest
public class CaseQualityReviewBatchApexTest {

    @isTest(seealldata = true)
    public static void caseQualitybatch(){
        List<User> us1 = [Select Id,FirstName,Name,Case_Quality_Reviews_Count__c,manager.firstname,manager.Id, manager.profile.name from User Where Profile.id ='00e50000000zJpI' and isActive = True AND (NOT UserRole.Name like '%lead%') AND (NOT UserRole.Name like '%manager%') AND (NOT UserRole.Name like '%tam%') limit 1];
        User us2 = [Select Id from User Where Alias='DMayberr'];
        
        List<Manger_Activity_Log__c> ml = new List<Manger_Activity_Log__c>();
        Manger_Activity_Log__c tempManObj = new Manger_Activity_Log__c();
        tempManObj.SupportManager__c = us2.Id;
        tempManObj.TseName__c = us1[0].Id;
        tempManObj.Evaluation_Started__c = date.newinstance(System.now().year(), System.now().month(), System.now().day());
        tempManObj.Evaluation_Ended__c = tempManObj.Evaluation_Started__c.addDays(30);
        tempManObj.Status__c = 'Completed';
        tempManObj.Status_Changed_For_Manager_Activity_Log__c = true;
        ml.add(tempManObj);
        insert ml; 
        
        List<case> csList = new List<case>(); 
        case cs = new case();
        cs.status ='Closed';
        cs.Priority ='P1';
        csList.add(cs);
        insert csList;
        
        Map<String,List<Case>> mp = new Map<String,List<Case>>();
        mp.put('Closed', csList);
      
            
        CaseQualityReviewBatchApex cq = new CaseQualityReviewBatchApex();
        cq.execute(null,us1);
    	cq.insertManagerActivityLog(us1);
        cq.updateManagerActivityLog(ml);
        cq.attachCaseListWithManActLog(ml);
        cq.CaseBucketToCaseListV1(csList,5);
        cq.caseIdToStatusInEngineerEscalMap(csList);
        cq.finalMapRoutine('Closed',mp);
        cq.insertCasesForNextMonOrForFirstTime(mp,ml[0].id);
        
       
    }
     @isTest(seealldata = true)
    public static void Schedulerclass(){
        CaseQualityPopulateListMonthlyScheduled cqp = new CaseQualityPopulateListMonthlyScheduled();
        cqp.execute(null);
    }
}