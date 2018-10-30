/* ***********************************************************************************************
Created By  : Jade Global Inc.
Created On  : 30th November 2017
Description : Handler Expense Report Trigger(pse__Expense_Report__c ) events 

* *********************************************************************************************** */

public class Trigger_Expense_Report_Handler{

    public static void afterInsertHandler(List<pse__Expense_Report__c > newList){
      
       Trigger_Expense_Report_Helper.SetAllSharingSettingsForProject(newList);
       
    }//End of afterInsertHandler Method
    
    
}