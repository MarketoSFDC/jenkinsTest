@istest
public class BatchUpdateUsageDataKeyTest{
    static testmethod void mytest(){
        Account TestAcc1 = new Account(Name='Test Account');
        insert TestAcc1;
        
        Contact con1 = new Contact(
            FirstName = 'Test First Name', 
            LastName = 'Test Last Name', 
            AccountId = TestAcc1.Id,
            Marketo_End_User__c = TRUE
        );
        insert con1;
        
        Date usageDataDate = Date.newInstance(2013,3,24);
        
        List<JBCXM__UsageData__c> usageDataList = new List<JBCXM__UsageData__c>();
        
        JBCXM__UsageData__c usageData1 = new JBCXM__UsageData__c(
            JBCXM__Date__c = usageDataDate, 
            JBCXM__InstanceId__c = 'TESTINSTID0123',
            JBCXM__InstanceName__c = 'TESTINSTID0123',
            JBCXM__Account__c = TestAcc1.Id
            
        );
        usageDataList.add(usageData1);
        
        JBCXM__UsageData__c usageData2 = new JBCXM__UsageData__c(
            JBCXM__Date__c = usageDataDate - 7, 
            JBCXM__InstanceId__c = 'TESTINSTID0123',
            JBCXM__InstanceName__c = 'TESTINSTID0123',
            JBCXM__Account__c = TestAcc1.Id
            
        );
        usageDataList.add(usageData2);
        
        JBCXM__UsageData__c usageData3 = new JBCXM__UsageData__c(
            JBCXM__Date__c = usageDataDate -14, 
            JBCXM__InstanceId__c = 'TESTINSTID0123',
            JBCXM__InstanceName__c = 'TESTINSTID0123',
            JBCXM__Account__c = TestAcc1.Id
        );
        usageDataList.add(usageData3);
        
        JBCXM__UsageData__c usageData4 = new JBCXM__UsageData__c(
            JBCXM__Date__c = usageDataDate -21, 
            JBCXM__InstanceId__c = 'TESTINSTID0123',
            JBCXM__InstanceName__c = 'TESTINSTID0123',
            JBCXM__Account__c = TestAcc1.Id
            
        );
        usageDataList.add(usageData4);
        
        insert usageDataList;
        
        Test.startTest();
        BatchUpdateUsageDataKey buudk = new BatchUpdateUsageDataKey();
        Database.executeBatch(buudk,10);
        Test.stopTest();
    }
}