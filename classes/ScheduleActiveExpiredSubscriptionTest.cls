@IsTest
public class ScheduleActiveExpiredSubscriptionTest {

    public static testMethod Void TestScheduleActiveExpiredSubscription(){
       
        Account acc = Utility.insertAccountInTestClasses();
        insert acc;
        contact con = Utility.insertContactInTestClasses(acc.id);
        insert con;
        opportunity opp = Utility.insertOpportunityInTestClasses(acc.id, con.Id, 'Discovery', 'New Business',Date.Today(), system.today().addDays(1),system.today().addDays(7), null);
        insert opp;
        List<Product2> prod2= TestCPQUtilityClass.createCustomProducts(1);
        prod2[0].Visible_To_Customer__c = True;
        insert prod2[0];
        Contract contract1 = new Contract(Name='Test Contract ', AccountId=acc.Id,SBQQ__Opportunity__c = opp.Id, StartDate=System.today());
        insert contract1;
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c(SBQQ__Contract__c=contract1.Id,SBQQ__Account__c=acc.Id,SBQQ__Quantity__c=3, SBQQ__Product__c =prod2[0].Id);   
        insert sub1;
        Test.StartTest();
        ScheduleActiveExpiredSubscription sh1 = new ScheduleActiveExpiredSubscription();    
        sh1.execute(Null);
        Test.stopTest();    
   }
}