@IsTest
(seealldata=true)

public class BillingSchedule_Test2 {

    
    static testmethod void test1()
    {
        string qid = 'aAp38000000PVwN';
        PageReference p=Page.SBQQ__PreviewDocument;
        Test.setCurrentPageReference(p); 
        System.currentPageReference().getParameters().put('qid', qid); 
        billingScheduleVFComponentController controller = new billingScheduleVFComponentController() ;
        controller = new billingScheduleVFComponentController() ;
        qid = 'aAp38000000PX7f';
        System.currentPageReference().getParameters().put('qid', qid);
        controller = new billingScheduleVFComponentController() ;
    }
}