/**************************************************************************************************************************************
Company Name  :Jade Global Inc.
Created Date  :10th February 2018
Apex Class    :Trigger_Timecard_TestClass
**************************************************************************************************************************************/

@isTest
public class Trigger_Timecard_TestClass{
    
    static testmethod void createTimecard(){
        
        User newUser =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser', 'Mkto', 'cfsId1');
        User testManager =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser2', 'Mkto', 'cfsId2');

        insert testManager;
        string s =[SELECT id ,lmscons__Cornerstone_ID__c FROm User WHERE id =:testManager.id].lmscons__Cornerstone_ID__c;
        
        newUser.ManagerId = testManager.Id;
        newUser.lmscons__Cornerstone_ID__c = s +'1';
        
        insert newUser;
        
        List<Account> account_list                       = TestCPQUtilityClass.createAccounts(2);
        List<Contact> contact_list                       = TestCPQUtilityClass.createContacts(account_list, 2);
        List<opportunity> opportunity_list               = TestCPQUtilityClass.createOpportunities(account_list,1);
        List<pse__Proj__c> project_List                  = TestCPQUtilityClass.createProject(opportunity_list,2); 
       
        List<pse__Schedule__c> schedule_list = TestCPQUtilityClass.createSchedule(1);
        List<pse__Milestone__c> milestone_list           = TestCPQUtilityClass.createMilestone(project_list, 1);
        List<pse__Practice__c> practice_list             = TestCPQUtilityClass.CreatePractice(1);
        List<pse__Timecard_Header__c> timecardheader_list= TestCPQUtilityClass.createTimecardHeader(contact_list,1);
        
       
        List<pse__Timecard__c> timeCardList = TestCPQUtilityClass.createTimecardSplit(timecardheader_list, 1);
        List<pse__Region__c> region_list                 = TestCPQUtilityClass.createRegion(1);
        
        
        
        insert region_list;
        
       // account_list[0].name = 'Marketo';
       // account_list[1].name = 'Marketo';                     
        insert account_list;
        
        contact_list[0].pse__Salesforce_User__c = newUser.Id;
        contact_list[0].pse__Is_Resource__c = true;
        contact_list[0].pse__Is_Resource_Active__c=true;
        
        contact_list[1].pse__Salesforce_User__c = testManager.Id;
        contact_list[1].pse__Is_Resource_Active__c = true;
        contact_list[1].pse__Is_Resource__c = true;
        
        insert contact_list[0];
        insert contact_list[1];
        
        insert opportunity_list;
        
        insert practice_list;
        
        project_List[0].pse__Is_Active__c = True;
        project_list[0].pse__Start_Date__c = Date.today(); 
        project_list[1].pse__Is_Active__c = true;
        project_list[1].pse__Start_Date__c = Date.today(); 
        project_list[0].pse__Project_Manager__c = contact_list[0].Id;
        project_list[0].pse__Practice__c = practice_list[0].Id;
        
        insert project_List;
        
        milestone_list[0].pse__Project__c = project_List[0].Id;
        milestone_list[0].pse__Admin_Global_Edit__c = true;
        milestone_list[0].pse__Audit_Notes__c = 'test test test test';
        milestone_list[0].ffrr_exp__StartDate__c = Date.today();
        
         milestone_list[1].pse__Project__c = project_list[1].Id ;
        milestone_list[1].pse__Admin_Global_Edit__c = true;
        milestone_list[1].pse__Audit_Notes__c = 'test test test test';
        milestone_list[1].ffrr_exp__StartDate__c = Date.today();
        insert milestone_list[0];
        insert milestone_list[1];
        
        project_list[0].pse__Opportunity__c = opportunity_list[0].Id;
        project_list[0].Primary_Project__c = project_list[1].Id;
        project_list[0].pse__Is_Billable__c = true;
        project_list[0].pse__Account__c = account_list[0].id ;
        
        update project_list;
        
              
        System.runAs(newUser){
        
         List<pse__Permission_Control__c> PCs = new List<pse__Permission_Control__c>();
        PCs.add(new pse__Permission_Control__c(pse__Resource__c=contact_list[0].Id,pse__User__c = newUser.Id,pse__Staffing__c=true,pse__Cascading_Permission__c=true,pse__Resource_Request_Entry__c=true,pse__Timecard_Entry__c=true));
        //PCs.add(new pse__Permission_Control__c(pse__Resource__c=contact_list[1].Id,pse__User__c = testManager.Id,pse__Staffing__c=true,pse__Cascading_Permission__c=true,pse__Resource_Request_Entry__c=true,pse__Timecard_Entry__c=true));
        PCs.add(new pse__Permission_Control__c(pse__User__c = newUser.Id,pse__Staffing__c=true,pse__Region__c = region_list[0].Id,pse__Cascading_Permission__c=true,pse__Resource_Request_Entry__c=true,pse__Timecard_Entry__c=true));
        PCs.add(new pse__Permission_Control__c(pse__Project__c = project_list[0].Id,pse__User__c = newUser.Id,pse__Staffing__c=true,pse__Cascading_Permission__c=true,pse__Resource_Request_Entry__c=true,pse__Timecard_Entry__c=true));

        insert PCs;

        insert schedule_list;

        pse__Resource_Request__c testresource = new pse__Resource_Request__c(pse__Project__c = project_list[0].Id,pse__Milestone__c=milestone_list[0].id,pse__Status__c='Draft',pse__Region__c=region_list[0].Id,pse__Resource_Role__c='Business Consultant',pse__SOW_Hours__c=15,pse__Start_Date__c=Date.today(),pse__End_Date__c=Date.today(),External_ID__c='RR0056',pse__Notes__c='Business Consulting');   
        Insert testresource;

        Test.starttest();
            List<pse__Assignment__c> assignment_list =  TestCPQUtilityClass.createAssignment(project_list,contact_list,testresource.Id, 1);
            assignment_list[0].pse__Milestone__c = milestone_list[0].id;
            assignment_list[0].pse__Schedule__c = schedule_list[0].Id;
            System.debug('AL: ' + assignment_list);
            Insert assignment_list[0];

            for (pse__Timecard_Header__c TCH: timecardheader_list)
            {
                TCH.pse__Project__c = project_list[0].Id;
                TCH.pse__Resource__c = contact_list[0].Id;
                TCH.pse__Assignment__c = assignment_list[0].Id;
            }
                   
            Insert timecardheader_list;
            
            pse__Timecard_Header__c TCH =  timecardheader_list[0];
            
            timeCardList = [select Id, Name from pse__Timecard__c where pse__Timecard_Header__c =: TCH.Id];
            
            timeCardList[0].int_IsSyncing__c = true;
            timeCardList[0].Integration_Status__c  = 'In-Progress';
            SF_Utility.isCalloutExecuted = false;
            
            Update  timeCardList;
            
           
        test.stopTest();
      }
    }
       static testmethod void createTimecardDelete(){
        
        User newUser =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser', 'Mkto', 'cfsId1');
        User testManager =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser2', 'Mkto', 'cfsId2');

        insert testManager;
        string s =[SELECT id ,lmscons__Cornerstone_ID__c FROm User WHERE id =:testManager.id].lmscons__Cornerstone_ID__c;
        
        newUser.ManagerId = testManager.Id;
        newUser.lmscons__Cornerstone_ID__c = s +'1';
        
        insert newUser;
        
        List<Account> account_list                       = TestCPQUtilityClass.createAccounts(2);
        List<Contact> contact_list                       = TestCPQUtilityClass.createContacts(account_list, 2);
        List<opportunity> opportunity_list               = TestCPQUtilityClass.createOpportunities(account_list,1);
        List<pse__Proj__c> project_List                  = TestCPQUtilityClass.createProject(opportunity_list,2); 
       
        List<pse__Schedule__c> schedule_list = TestCPQUtilityClass.createSchedule(1);
        List<pse__Milestone__c> milestone_list           = TestCPQUtilityClass.createMilestone(project_list, 1);
        List<pse__Practice__c> practice_list             = TestCPQUtilityClass.CreatePractice(1);
        List<pse__Timecard_Header__c> timecardheader_list= TestCPQUtilityClass.createTimecardHeader(contact_list,1);
        
       
        List<pse__Timecard__c> timeCardList = TestCPQUtilityClass.createTimecardSplit(timecardheader_list, 1);
        List<pse__Region__c> region_list                 = TestCPQUtilityClass.createRegion(1);
        
        
        
        insert region_list;
        
       // account_list[0].name = 'Marketo';
       // account_list[1].name = 'Marketo';                     
        insert account_list;
        
        contact_list[0].pse__Salesforce_User__c = newUser.Id;
        contact_list[0].pse__Is_Resource__c = true;
        contact_list[0].pse__Is_Resource_Active__c=true;
        
        contact_list[1].pse__Salesforce_User__c = testManager.Id;
        contact_list[1].pse__Is_Resource_Active__c = true;
        contact_list[1].pse__Is_Resource__c = true;
        
        insert contact_list[0];
        insert contact_list[1];
        
        insert opportunity_list;
        
        insert practice_list;
        
        project_List[0].pse__Is_Active__c = True;
        project_list[0].pse__Start_Date__c = Date.today(); 
        project_list[1].pse__Is_Active__c = true;
        project_list[1].pse__Start_Date__c = Date.today(); 
        project_list[0].pse__Project_Manager__c = contact_list[0].Id;
        project_list[0].pse__Practice__c = practice_list[0].Id;
        
        insert project_List;
        
        milestone_list[0].pse__Project__c = project_List[0].Id;
        milestone_list[0].pse__Admin_Global_Edit__c = true;
        milestone_list[0].pse__Audit_Notes__c = 'test test test test';
        milestone_list[0].ffrr_exp__StartDate__c = Date.today();
        
         milestone_list[1].pse__Project__c = project_list[1].Id ;
        milestone_list[1].pse__Admin_Global_Edit__c = true;
        milestone_list[1].pse__Audit_Notes__c = 'test test test test';
        milestone_list[1].ffrr_exp__StartDate__c = Date.today();
        insert milestone_list[0];
        insert milestone_list[1];
        
        project_list[0].pse__Opportunity__c = opportunity_list[0].Id;
        project_list[0].Primary_Project__c = project_list[1].Id;
        project_list[0].pse__Is_Billable__c = true;
        project_list[0].pse__Account__c = account_list[0].id ;
        
        update project_list;
        
              
        System.runAs(newUser){
        
         List<pse__Permission_Control__c> PCs = new List<pse__Permission_Control__c>();
        PCs.add(new pse__Permission_Control__c(pse__Resource__c=contact_list[0].Id,pse__User__c = newUser.Id,pse__Staffing__c=true,pse__Cascading_Permission__c=true,pse__Resource_Request_Entry__c=true,pse__Timecard_Entry__c=true));
        //PCs.add(new pse__Permission_Control__c(pse__Resource__c=contact_list[1].Id,pse__User__c = testManager.Id,pse__Staffing__c=true,pse__Cascading_Permission__c=true,pse__Resource_Request_Entry__c=true,pse__Timecard_Entry__c=true));
        PCs.add(new pse__Permission_Control__c(pse__User__c = newUser.Id,pse__Staffing__c=true,pse__Region__c = region_list[0].Id,pse__Cascading_Permission__c=true,pse__Resource_Request_Entry__c=true,pse__Timecard_Entry__c=true));
        PCs.add(new pse__Permission_Control__c(pse__Project__c = project_list[0].Id,pse__User__c = newUser.Id,pse__Staffing__c=true,pse__Cascading_Permission__c=true,pse__Resource_Request_Entry__c=true,pse__Timecard_Entry__c=true));

        insert PCs;

        insert schedule_list;

        pse__Resource_Request__c testresource = new pse__Resource_Request__c(pse__Project__c = project_list[0].Id,pse__Milestone__c=milestone_list[0].id,pse__Status__c='Draft',pse__Region__c=region_list[0].Id,pse__Resource_Role__c='Business Consultant',pse__SOW_Hours__c=15,pse__Start_Date__c=Date.today(),pse__End_Date__c=Date.today(),External_ID__c='RR0056',pse__Notes__c='Business Consulting');   
        Insert testresource;

        Test.starttest();
            List<pse__Assignment__c> assignment_list =  TestCPQUtilityClass.createAssignment(project_list,contact_list,testresource.Id, 1);
            assignment_list[0].pse__Milestone__c = milestone_list[0].id;
            assignment_list[0].pse__Schedule__c = schedule_list[0].Id;
            System.debug('AL: ' + assignment_list);
            Insert assignment_list[0];

            for (pse__Timecard_Header__c TCH: timecardheader_list)
            {
                TCH.pse__Project__c = project_list[0].Id;
                TCH.pse__Resource__c = contact_list[0].Id;
                TCH.pse__Assignment__c = assignment_list[0].Id;
            }
                   
            Insert timecardheader_list;
            
            pse__Timecard_Header__c TCH =  timecardheader_list[0];
            
            timeCardList = [select Id, Name from pse__Timecard__c where pse__Timecard_Header__c =: TCH.Id];            
            Delete  timeCardList;
        test.stopTest();
      }  
        
    }//End of Method
}