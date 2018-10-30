/* ***********************************************************************************************
Created By  : Jade Global Inc.
Created On  : 30th November 2017
Description : Handler Expense Trigger(pse__Expense__c) events 

* *********************************************************************************************** */

public class Trigger_Expense_Handler{

    public static void afterInsertHandler(List<pse__Expense__c > newList){
       
       
       Trigger_Expense_Helper.SetAllSharingSettingsForProject(newList);
       
    }//End of afterInsertHandler Method
    
    
}