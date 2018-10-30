@isTest(SeeAllData=True)
public class ProactiveCasesSchedulerClassTest{
        static testmethod void ProactiveCaseTest(){
        Test.StartTest();
        ProactiveCaseBatchClass upc =  new ProactiveCaseBatchClass(); 
        ID batchprocessid = Database.executeBatch(upc);
        ProactiveCasesSchedulerClass sc = new ProactiveCasesSchedulerClass();
        sc.execute(null);
        Test.StopTest();
    }
}