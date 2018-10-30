@isTest
public class Lead_Trigger_Test{
    static testmethod void mytest(){
        Lead ld = new Lead(FirstName = 'Test First Name', LastName = 'Test Last Name', Email = 'test@test.com', Company = 'Test Comp');
        /*insert ld;
        Test.startTest();
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(ld.id);
        lc.setConvertedStatus('Customer');
        lc.setDoNotCreateOpportunity(true);
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        System.assert(lcr.isSuccess());
        Test.stopTest();*/
    }
}