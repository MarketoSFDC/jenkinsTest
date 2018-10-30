@isTest
public class BatchPopulateQueuedMilestones_Test  {
    
	@isTest
	private static void Test_BatchPopulateQueuedMilestones()
    {
        List<Account> account_list = TestCPQUtilityClass.createAccounts(1);
        List<Opportunity> opp_list = TestCPQUtilityClass.createOpportunities(account_list,2);
        List<pse__Proj__c> project_list = TestCPQUtilityClass.createProject(opp_list, 2);
        List<pse__Milestone__c> Milestone_list = TestCPQUtilityClass.createMilestone(project_list,2);
        List<Product2> Product_list = TestCPQUtilityClass.createCustomProducts(2);
        
        insert account_list; 
        
       opp_list[0].Type='New Business';
        insert opp_list;
        
        for(pse__Proj__c Proj: project_list)
        {
        proj.pse__Is_Template__c= true;
        proj.pse__Is_Active__c = true; 
        }
        insert project_list; //Insert Project
       
        
        Product_list[0].Services_Project_Template__c=project_list[0].id;
        Product_list[1].Services_Project_Template__c=project_list[1].id;
        opp_list[0].pse__Primary_Project__c=project_list[0].id;
        opp_list[0].Secondary_Project__c=project_list[0].id;
        opp_list[1].Type='Upsell/Crossell';
        opp_list[1].pse__Primary_Project__c=project_list[0].id;
        opp_list[1].Secondary_Project__c=project_list[1].id;
        insert Product_list; 
        update opp_list;
            project_list[1].pse__Opportunity__c=opp_list[1].id;
            project_list[1].Primary_Project__c=project_list[0].id;
            update project_list;   
       
        for(pse__Milestone__c MilestoneRecord: Milestone_list) 
        {
            MilestoneRecord.pse__Project__c = project_list[0].Id ;
            MilestoneRecord.pse__Admin_Global_Edit__c = true;
            MilestoneRecord.pse__Audit_Notes__c = 'test Milestone';
            MilestoneRecord.Opportunity2__c= opp_list[0].id;
            MilestoneRecord.Product__c=Product_list[0].id;
            MilestoneRecord.QueueMilestoneTemplate__c = True; 
        }
        Milestone_list[1].Opportunity2__c= opp_list[1].id;
        insert Milestone_list;
          
        Test.startTest();  
			BatchPopulateQueuedMilestones batchable = new BatchPopulateQueuedMilestones();
			Database.executeBatch(batchable,1);
        test.stopTest();
        
        
    }
}