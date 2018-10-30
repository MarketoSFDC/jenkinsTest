/*
Created By: Jade Global Inc
Description: To test Inv_ConvergeProjectDataOnOpportunity Class
Created Date : 30th Jan 2018
*/

@isTest
public class Inv_ConvergeProjectDataOnOpp_TestClass {
    static testMethod void ConvergeProjectDataOnOpportunity(){
            List<Account> account_list = TestCPQUtilityClass.createAccounts(1);
            List<Contact> contact_list = TestCPQUtilityClass.createContacts(account_list, 1);
            List<Opportunity> opp_list = TestCPQUtilityClass.createOpportunities(account_list,1);
            List<pse__Proj__c> project_list = TestCPQUtilityClass.createProject(opp_list, 2);
            List<pse__Milestone__c> milestone_list = TestCPQUtilityClass.createMilestone(project_list, 1); 
            List<pse__Budget__c> budget_list =  TestCPQUtilityClass.createBudgetList(project_list , 1);     
            insert account_list;
            for(Contact con: contact_list){
            con.pse__Salesforce_User__c = UserInfo.getUserId();
            }
            insert contact_list;
            insert opp_list;
            
            project_list[0].pse__Is_Active__c = true; 
            project_list[1].pse__Is_Active__c = true; 
            insert project_list;
            
            for(pse__Budget__c budget : budget_list ){
                budget.pse__Project__c = project_list[0].Id ;
                budget.pse__Admin_Global_Edit__c = true;
                budget.pse__Audit_Notes__c = 'test test test test';
            }
            insert budget_list;
            
            for(pse__Milestone__c milestone : milestone_list){
                milestone.pse__Project__c = project_list[0].Id ;
                milestone.pse__Admin_Global_Edit__c = true;
                milestone.pse__Audit_Notes__c = 'test test test test';
            }
            insert milestone_list;
            
            project_list[0].pse__Opportunity__c = opp_list[0].Id;
            project_list[0].Primary_Project__c = project_list[1].Id;
            
            update project_list;
               
            Inv_ConvergeProjectDataOnOpportunity newInst = new Inv_ConvergeProjectDataOnOpportunity(); 
             
                     
            List<Inv_ConvergeProjectDataOnOpportunity.PBInputs> pbInputs = new List<Inv_ConvergeProjectDataOnOpportunity.PBInputs>();
            Inv_ConvergeProjectDataOnOpportunity.PBInputs pbInput1 = new Inv_ConvergeProjectDataOnOpportunity.PBInputs();
            
          //  Inv_ConvergeProjectDataOnOpportunity.PBInputs pbInput2 = new Inv_ConvergeProjectDataOnOpportunity.PBInputs();
            
            pbInput1.OppId = opp_list[0].Id;
          
            pbInputs.add(pbInput1);
           // pbInputs.add(pbInput2);
            test.startTest();
            if(!pbInputs.isEmpty()){
                Inv_ConvergeProjectDataOnOpportunity.ConvergeProjectDataOnOpportunity(pbInputs);
            }
            test.stopTest();
    }
}