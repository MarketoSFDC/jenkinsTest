@isTest
public class QuoteSegmentStartDateBatch_Schedule_Test{
    public static testMethod void testMethodForQuoteSegmentBatch_Schedule(){
        Test.StartTest();
        QuoteSegmentStartDateBatch_Schedule sh1 = new QuoteSegmentStartDateBatch_Schedule();      
        String sch = '0  00 1 3 * ?';
        system.schedule('Test', sch, sh1);
        Test.stopTest();
    }
}