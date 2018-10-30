@isTest(SeeAllData=True)
public class CasetriggerFunctionExtendedTest {
    static testMethod void batchForCaseCommentUpdates() {        
        Test.startTest();
            batchcaseUpdateNo_of_CaseComments obj = new batchcaseUpdateNo_of_CaseComments();
            DataBase.executeBatch(obj);            
        Test.stopTest();
    }
}