@istest
public class BatchCreateGS4WeeklyUsageDataTest{
    @testSetup static void methodName() {
        Account TestAcc1 = new Account(Name='Test Account');
        insert TestAcc1;
        
        
        Contact con1 = new Contact(
            FirstName = 'Test First Name', 
            LastName = 'Test Last Name', 
            AccountId = TestAcc1.Id/*,
            Marketo_Usage_Report_Opt_In__c = TRUE*/
        );
        insert con1;
        
        Asset ast = new Asset(
            Name = 'Test Asset',
            AccountId = TestAcc1.Id,
            Munchkin_ID__c = 'TESTINSTID0123',
            Asset_Type__c = 'Test Type',
            Subscription_Type__c = 'Test Sub',
            Purpose__c = 'Production',
            DKIM__c = 'Configured',
            Branded_Link__c = 'Not Configured',
            Acct_Prefix__c = 'TESTINSTID0123'
        );
        
        insert ast;
        
        Date usageDataDate = Date.newInstance(2013,5,19);
        
        Certification_History__c certHist = new Certification_History__c(
            Account__c = TestAcc1.Id,
            Date_Passed_Exam__c = usageDataDate,
            Exam_Result__c = 'Pass'
        );
        insert certHist;
        
        Case cs = new Case(
            AccountId = TestAcc1.Id,
            Subject = 'Test Case for Usage Data'
        );
        insert cs;
       
        
        List<JBCXM__UsageData__c> usageDataList = new List<JBCXM__UsageData__c>();
        
        for(integer i=0; i<=16; i++){
            JBCXM__UsageData__c usageData = new JBCXM__UsageData__c(
                JBCXM__Date__c = usageDataDate -(i)*7, 
                JBCXM__InstanceId__c = 'TESTINSTID0123',
                JBCXM__InstanceName__c = 'TESTINSTID0123',
                JBCXM__Account__c = TestAcc1.Id
                
            );
            usageDataList.add(usageData);
        }
        
        insert usageDataList;
    }
    static testmethod void mytest(){
        
        
        Test.startTest();
        BatchCreateGS4WeeklyUsageData bcgswud = new BatchCreateGS4WeeklyUsageData ();
        Database.executeBatch(bcgswud,17);
        Test.stopTest();
    }
}