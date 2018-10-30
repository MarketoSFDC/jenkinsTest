@isTest
public class SBQQ_QuoteTriggerMainHandlerTest {

    public static testMethod void Method1() {
        Account acc = Utility.insertAccountInTestClasses();
        insert acc;
        Contact con = Utility.insertContactInTestClasses(acc.Id);
        insert con;
        Opportunity opp = Utility.insertOpportunityInTestClasses(acc.Id, con.Id, 'A - Qualify', 'New Business', Date.Today(), Date.Today(), Date.Today(), Date.Today()  );
        insert opp;
        Country__c cu = new Country__c(Name = 'Ireland', CurrencyIsoCode = 'USD',Country_Registered_Office_Address__c='Test');
        insert cu;
        SBQQ__Quote__c sbq = new SBQQ__Quote__c(SBQQ__Account__c = acc.Id, SBQQ__Opportunity2__c = opp.Id, SBQQ__StartDate__c = Date.Today(), SBQQ__Primary__c = True, SBQQ__ShippingCountry__c = 'Ireland' );
        insert sbq;  
    }
    public static testMethod void Method2() {
        Account acc = Utility.insertAccountInTestClasses();
        insert acc;
        Contact con = Utility.insertContactInTestClasses(acc.Id);
        insert con;
        Opportunity opp = Utility.insertOpportunityInTestClasses(acc.Id, con.Id, 'A - Qualify', 'New Business', Date.Today(), Date.Today(), Date.Today(), Date.Today()  );
        insert opp;
        Country__c cu = new Country__c(Name = 'Ireland', CurrencyIsoCode = 'USD',Country_Registered_Office_Address__c='Test');
        insert cu;
        SBQQ__Quote__c sbq2 = new SBQQ__Quote__c(SBQQ__Account__c = acc.Id, SBQQ__Opportunity2__c = opp.Id, SBQQ__StartDate__c = Date.Today(), SBQQ__Primary__c = False, SBQQ__ShippingCountry__c = 'Ireland' );
        insert sbq2;
        sbq2.SBQQ__Primary__c = True;
        update sbq2;   
    }
}