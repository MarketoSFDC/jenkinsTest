@isTest//(seeAllData= True)
public class Test_ContractTriggerMain{
    static testmethod void UpdateContractOfAccountTest(){
        Account acc = new Account(Name='test Account for trigger',ownerid = UserInfo.getUserId(),Target_Account_1__c = 'Enterprise Target');
        acc.SDR_Owner_Picklist__c = 'Vishal Sharma';
        insert acc; 
        
        Contract cont = new Contract();
        cont.AccountId = acc.Id;
        cont.CurrencyIsoCode = 'USD';
        //cont.Status = 'Draft';
        cont.StartDate = System.Today();
        cont.ContractTerm = 1;
        insert cont;
        cont.StartDate = System.Today().addDays(-30);
        update cont;
        
        Product2 prod = new Product2(Name = 'Test Product', ProductCode = 'TESTPROD', isActive=TRUE, MA_or_RTP__c = 'MA');
        insert prod;
        
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c(SBQQ__Contract__c=cont.Id,SBQQ__Account__c=acc.Id,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =prod.Id);
        insert sub;
        
        ScheduleActiveExpiredSubscription saes = new ScheduleActiveExpiredSubscription();
         saes.execute(NULL);
    }
}