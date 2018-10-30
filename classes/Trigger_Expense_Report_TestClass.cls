/*
Created By: Jade Global Inc
Description: To test Trigger_Expense_Report_Handler and Trigger_Expense_Report_Helper Class
Created Date : 10th February 2018
*/
@isTest
public class Trigger_Expense_Report_TestClass {
     static testMethod void SetAllSharingSettingsForProject(){
    List<Account> account_list = TestCPQUtilityClass.createAccounts(1);
        List<Contact> contact_list = TestCPQUtilityClass.createContacts(account_list, 1);
        List<Opportunity> opp_list = TestCPQUtilityClass.createOpportunities(account_list,1);
        List<pse__Proj__c> project_list = TestCPQUtilityClass.createProject(opp_list, 1);
        insert account_list;
        
        for(Contact con: contact_list){
            con.pse__Salesforce_User__c = UserInfo.getUserId();
        }
        
        insert contact_list;
        for(pse__Proj__c proj: project_list){
            proj.pse__Is_Active__c = true; 
            proj.pse__Allow_Expenses_Without_Assignment__c = True;
        }
        insert project_list ;
        List<pse__Expense_Report__c > ExpeseReportList= TestCPQUtilityClass.createExpenseReport(project_list,contact_list,1);
        /*for(pse__Expense_Report__c ExpenseReport : ExpeseReportList ){

           ExpenseReport.pse__Resource__c =  contact_list[0].id; 
           ExpenseReport.pse__Admin_Global_Edit__c= true;
           ExpenseReport.pse__Audit_Notes__c = 'test Expense Report';
        } */
        
        test.startTest();
        if(!ExpeseReportList.isEmpty()){
             insert ExpeseReportList;
        }
        test.stopTest();
       
     }
}