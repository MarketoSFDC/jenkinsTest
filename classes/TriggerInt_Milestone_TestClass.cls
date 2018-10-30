/* ***********************************************************************************************
Company Name  :Jade Global Inc.
Created Date  :10th February 2018
Description   : 1. To test Milestone Trigger .

* *********************************************************************************************** */
@isTest
public class TriggerInt_Milestone_TestClass {
    static testmethod void MapFieldsAndPublishIntegrationPlatformEvent()
    {
        SalesTriggersUtility.marketoTriggerManager.Deactivate_Milestone_Triggers__c= False;
        List<Account> account_list = TestCPQUtilityClass.createAccounts(1);
        List<Contact> contact_list = TestCPQUtilityClass.createContacts(account_list, 1);
        List<Opportunity> opp_list = TestCPQUtilityClass.createOpportunities(account_list,1);
        List<pse__Proj__c> project_list = TestCPQUtilityClass.createProject(opp_list, 1);
        List<pse__Milestone__c> milestone_list = TestCPQUtilityClass.createMilestone(project_list, 1);
        
        insert account_list;
        insert contact_list;
        for(Opportunity opp :opp_list)
        {
            opp.Type = 'New Business';
        }
       insert opp_list;
     
        insert project_list;
        for(pse__Proj__c Proj : project_list)
        {
            Proj.int_Intacct_Record_No__c = '12355';
            Proj.pse__Is_Active__c = True;
        }
        
        update project_list;
        
        pse__Proj__c proj = project_list[0];
        for(pse__Milestone__c milestone : milestone_list)
        {
            milestone.int_IsSyncing__c  = False;
            milestone.int_Intacct_Project_ID_2__c = 'Test';
            milestone.int_Intacct_Project_Category__c = 'Contract';
            milestone.pse__Project__c = proj.id;
        }
        test.startTest();
        Insert milestone_list;
        test.stopTest();
    }
    
    static testMethod void updateMethod()
    {
        SalesTriggersUtility.marketoTriggerManager.Deactivate_Milestone_Triggers__c= False;
        List<Account> account_list = TestCPQUtilityClass.createAccounts(1);
        List<Contact> contact_list = TestCPQUtilityClass.createContacts(account_list, 1);
        List<Opportunity> opp_list = TestCPQUtilityClass.createOpportunities(account_list,1);
        List<pse__Proj__c> project_list = TestCPQUtilityClass.createProject(opp_list, 1);
        List<pse__Milestone__c> milestone_list = TestCPQUtilityClass.createMilestone(project_list, 1);
        
        insert account_list;
        insert contact_list;
        
         insert project_list;
        for(pse__Proj__c Proj : project_list)
        {
            Proj.int_Intacct_Record_No__c = '1234';
            Proj.pse__Is_Active__c = True;
        }
        
        update project_list;
        
        pse__Proj__c proj = project_list[0];
        for(pse__Milestone__c milestone : milestone_list)
        {
            milestone.pse__Project__c = proj.id;
        }
        Insert milestone_list;
        for(pse__Milestone__c milestone : milestone_list)
        {
            milestone.int_IsSyncing__c  = TRUE;
            milestone.int_Intacct_Project_ID_2__c = 'Test';
            milestone.int_Intacct_Project_Category__c = 'Contract'; 
            milestone.Integration_Status__c = 'In-Progress';
            milestone.int_Intacct_Record_No__c = '5634';
            milestone.Copy_from_Template__c = true ;
        }
        test.startTest();
        update milestone_list;
        
        test.stopTest();
        TriggerInt_Milestone_Helper.populateProjectFromTemplateonInsert(milestone_list);
        TriggerInt_Milestone_Helper.populateProjectFromTemplateonUpdate(milestone_list,milestone_list);
    }
}