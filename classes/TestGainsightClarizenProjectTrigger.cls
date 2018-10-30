/* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
********************************************************************************************************************* */
@isTest
private class TestGainsightClarizenProjectTrigger 
{
    @isTest static void TestUpdate() 
    {
        Account A = new Account(Name='Test');
        insert A;
        
        JBCXM__PickList__c PL = new JBCXM__PickList__c(JBCXM__Active__c=true,JBCXM__Category__c='Customer Status',JBCXM__SystemName__c='ActiveCustomer',Name='Active');
        insert PL;

        JBCXM__PickList__c PL2 = new JBCXM__PickList__c(JBCXM__Active__c=true,JBCXM__Category__c='Milestones',JBCXM__SystemName__c='Proj Due',Name='Active');
        insert PL2;

        JBCXM__PickList__c PL3 = new JBCXM__PickList__c(JBCXM__Active__c=true,JBCXM__Category__c='Milestones',JBCXM__SystemName__c='Proj Start',Name='Active');
        insert PL3;

        JBCXM__PickList__c PL4 = new JBCXM__PickList__c(JBCXM__Active__c=true,JBCXM__Category__c='Milestones',JBCXM__SystemName__c='Proj Compl',Name='Active');
        insert PL4;
        
        JBCXM__CustomerInfo__c CI = new JBCXM__CustomerInfo__c(JBCXM__Account__c=A.Id,JBCXM__ASV__c=0,JBCXM__MRR__c=0,JBCXM__Status__c=PL.Id);
        insert CI;

        A.JBCXM__CustomerInfo__c = CI.Id;
        update A; 
        
		/* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
		
        clzV5__Clarizen_Project__c CP = new clzV5__Clarizen_Project__c(clzV5__CLZ_Customer__c=A.Id,CLZ_C_ProjectFamily__c='MLMLP',clzV5__CLZ_ProjectType__c='QS',clzV5__CLZ_StartDate__c=Date.Today(),clzV5__CLZ_DueDate__c=Date.Today());
        insert CP;

        CP.Closeout_Date_Completed__c = Date.Today();
        update CP;
		********************************************************************************************************************* */
    }
}