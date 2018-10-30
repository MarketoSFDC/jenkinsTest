@IsTest
(seealldata = true)
public class PhoenixARRTestClass {
    
    
    static testmethod void testit1()
    {
        SBQQ__Quote__c quote = [SELECT Id, SBQQ__Opportunity2__c from SBQQ__Quote__c where id = 'aAp38000000HSr0'];
        update quote;
        List<PhoenixARR__e> PlatformEventList = new List<PhoenixARR__e>();
        PhoenixARR__e PE = new PhoenixARR__e(Opportunity_Id__c = quote.SBQQ__Opportunity2__c);
        PlatformEventList.add(PE);
        List<Database.SaveResult> results = EventBus.publish(PlatformEventList);
        Trigger_PhoenixPE_Helper.PerformActionOnQuoteRecord(PlatformEventList);
        Trigger_PhoenixPE_Handler.afterInsertHandler(PlatformEventList);
        phoenixRenewalARR.phoenixRenewalARRcalc(quote.SBQQ__Opportunity2__c);
        Test.getEventBus().deliver();
    }

}