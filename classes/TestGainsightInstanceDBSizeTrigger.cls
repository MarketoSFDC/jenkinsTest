/******************************
** File:    TestGainsightInstanceDBSizeTrigger.cls
** Desc:    Test Method for GainsightInstanceDBSizeTrigger JBCXM__UsageData__c Trigger
** Auth:    Rob Begley
** Date:    1.30.14
**************************
** Change History
**************************
** PR   Date        Author      Description 
** --   --------    -------     ------------------------------------
*******************************/

@isTest
private class TestGainsightInstanceDBSizeTrigger
{

    static testMethod void GainsightInstanceDBSizeTriggerTest()
    {
        
        Account A = new Account(Name='Test 1');
        insert A;

        // Customer Status
        JBCXM__Picklist__c PL = new JBCXM__Picklist__c(JBCXM__Active__c=true, JBCXM__Category__c='Customer Status',JBCXM__SystemName__c='ActiveCustomer',Name='Active');
        insert PL;

        JBCXM__CustomerInfo__c CI = new JBCXM__CustomerInfo__c(JBCXM__Account__c=A.Id,JBCXM__Status__c=PL.Id);
        insert CI;
        
        Asset NewAs = new Asset(Name='Test',AccountId=A.Id,Maximum_Database_Size__c=10000,Munchkin_ID__c='123-ABC');
        insert NewAs;
        
        Contract con = new Contract(AccountId = A.Id, Total_Contact_Records__c = 100);
        insert con;
        
        JBCXM__UsageData__c UD = new JBCXM__UsageData__c(JBCXM__Account__c=A.Id,JBCXM__Date__c=Date.Today(),JBCXM__InstanceId__c='123-ABC',JBCXM__InstanceName__c='Test',Name='INSTANCELEVEL');
        insert UD;
        
        UD.JBCXM__InstanceId__c='';

        update UD;
           
    }
}