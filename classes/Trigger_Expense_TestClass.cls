/* ***********************************************************************************************
Created By  : Jade Global Inc.
Created On  : 10th February 2018
Description : 1. To test Trigger_Expense_Handler and Trigger_Expense_Helper .

* *********************************************************************************************** */
@isTest
public class Trigger_Expense_TestClass {
    static testMethod void SetAllSharingSettingsForProject(){
        List<Account> account_list = TestCPQUtilityClass.createAccounts(1);
        List<Contact> contact_list = TestCPQUtilityClass.createContacts(account_list, 1);
        List<Opportunity> opp_list = TestCPQUtilityClass.createOpportunities(account_list,1);
        List<pse__Proj__c> project_list = TestCPQUtilityClass.createProject(opp_list, 1);
        insert account_list;
        /*for(Contact con: contact_list){
            con.pse__Salesforce_User__c = UserInfo.getUserId();
        }*/
        insert contact_list;
        insert opp_list ; 
        project_list[0].pse__Is_Active__c = true; 
        insert project_list ;
        
        List<pse__Expense__c> expense_list = TestCPQUtilityClass.createExpenseList(project_list,contact_list, 1);
        /*
        for(pse__Expense__c expense : expense_list ){
           expense.pse__Project__c = project_list[0].id;
           expense.pse__Admin_Global_Edit__c = true;
           expense.pse__Audit_Notes__c = 'test test test test';
           expense.pse__Resource__c =  contact_list[0].id; 
        }
        */
        test.startTest();
        if(!expense_list.isEmpty()){
            insert expense_list;
        }
        test.stopTest();
        
    }
}