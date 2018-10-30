@isTest
public class Sync_with_CC_Test {

	public static testMethod void TestMethod1(){
        Legal_Agreements__c la = new Legal_Agreements__c();
        Test.startTest();
            insert la;
            update la;
            delete la;
            undelete la;
        Test.stopTest();
	}
    
}