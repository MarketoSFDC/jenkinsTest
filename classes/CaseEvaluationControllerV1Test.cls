@isTest(SeeAllData = true)
public class CaseEvaluationControllerV1Test {
    public static testmethod void Evaluation(){
            User us1 = [Select Id, Name from User Where Alias='BGomes'];
            User us2 = [Select Id from User Where Alias='DMayberr'];

            Manger_Activity_Log__c tempManObj = new Manger_Activity_Log__c();
            tempManObj.SupportManager__c = us2.Id;
            tempManObj.TseName__c = us1.Id;
            tempManObj.Evaluation_Started__c = date.newinstance(System.now().year(), System.now().month(), System.now().day());
            tempManObj.Evaluation_Ended__c = tempManObj.Evaluation_Started__c.addDays(30);
            tempManObj.Status__c = 'Completed';
            tempManObj.Status_Changed_For_Manager_Activity_Log__c = true;
            insert tempManObj; 
            
            Case tempCaseForCaseQualityReview = new Case();
            insert tempCaseForCaseQualityReview;
            
            Store_Cases_For_Month__c tempStoreCases = new Store_Cases_For_Month__c();
            tempStoreCases.Cases_From_Previous_Month__c = true;
            tempStoreCases.Evaluation_Status__c = 'Evaluate';
            tempStoreCases.Manger_Activity_Log__c  = tempManObj.Id;
            tempStoreCases.Filter_Criteria__c = 'On Demand';
            tempStoreCases.Case__c = tempCaseForCaseQualityReview.Id;
            insert tempStoreCases;
            
            Store_Cases_For_Month__c tempStoreCases1 = new Store_Cases_For_Month__c();
            tempStoreCases1.Cases_From_Previous_Month__c = true;
            tempStoreCases1.Evaluation_Status__c = 'Evaluate';
            tempStoreCases1.Manger_Activity_Log__c  = tempManObj.Id;
            tempStoreCases1.Filter_Criteria__c = 'Closed';
            tempStoreCases1.Case__c = tempCaseForCaseQualityReview.Id;        
            insert tempStoreCases1;
            
            Support_Score_Card__c sc = new Support_Score_Card__c();
            sc.Case__c = tempCaseForCaseQualityReview.Id;
            sc.Manger_Activity_Log__c = tempManObj.id;
            sc.Status__c = 'Completed';
            sc.Evaluated_By__c = UserInfo.getUserId();
            insert sc;
        
           
            PageReference pageRef1 = Page.CaseEvaluationForm;
            Test.setCurrentPage(pageRef1);
            pageRef1.getParameters().put('userName', us1.Name);
            pageRef1.getParameters().put('activityLogId', tempManObj.Id);
            pageRef1.getParameters().put('userId', us1.Id);
        
            ApexPages.StandardController scs = new ApexPages.StandardController(tempCaseForCaseQualityReview);
            CaseEvaluationControllerV1 testAccPlan = new CaseEvaluationControllerV1(scs);
          testAccPlan.saveScoreCard();
          testAccPlan.startEvaluation();
         
            CaseEvaluationControllerV1 testCaseEvalObj = new CaseEvaluationControllerV1();
            testCaseEvalObj.getCaseListBasedOnFilterCriteria();
            testCaseEvalObj.showOnDemandCase();
            testCaseEvalObj.backToTSESelect();       
        }
}