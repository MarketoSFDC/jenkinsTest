/* ***********************************************************************************************
Created By  : Jade Global Inc.
Created On  : 30th November 2017
Description : Helper Expense Report Trigger(pse__Expense_Report__c ) events 

* *********************************************************************************************** */

public class Trigger_Expense_Report_Helper{

      public static void SetAllSharingSettingsForProject(List<pse__Expense_Report__c > newList){
          
             Set<Id> ProjectIds = new Set<Id>();
            for (pse__Expense_Report__c TC: newList){
                ProjectIds.add(TC.pse__Project__c);
            }

            Map<Id,pse__Proj__c> projects = new Map<Id,pse__Proj__c>([Select Id,pse__Project_Manager__r.pse__Salesforce_User__c, Delegated_Project_Manager__r.pse__Salesforce_User__c from pse__Proj__c where ID IN: ProjectIds]);
            Set<Id> Ids = new Set<Id>();

            for (pse__Proj__c project: projects.values()){
                if (project.pse__Project_Manager__r.pse__Salesforce_User__c != null) Ids.add(project.pse__Project_Manager__r.pse__Salesforce_User__c);
                if (project.Delegated_Project_Manager__r.pse__Salesforce_User__c != null) Ids.add(project.Delegated_Project_Manager__r.pse__Salesforce_User__c);
                ShareUtilities.SetAllSharingSettingsForProject(project.Id,Ids);
            }
    
         
       }//End of SetAllSharingSettingsForProject Method
    
    
   
}