/*
Created By: Jade Global Inc
Description: To test IntegrationLogDeletionBatch Class
Created Date : 10th February 2018
*/
@isTest
public class IntegrationLogDeletionBatch_TestClass {
    
    static testMethod void IntegrationLogDeletionBatch()
    {
        List<Integration_Event_Log__c> IntegerationEventLogList = TestCPQUtilityClass.createIntegrationEventLog(1);
      
        if(!IntegerationEventLogList.isEmpty())
        {
            
            insert IntegerationEventLogList;
        }
        
        test.startTest();
      
        IntegrationLogDeletionBatch batch = new IntegrationLogDeletionBatch();
     
        Id batchId = Database.executeBatch(batch);
        
       
       IntegrationLogDeletionBatchScheduler new_batch = new IntegrationLogDeletionBatchScheduler();
      
        Id jobId = system.schedule('TestBatch','0 0 0/1 1/1 * ? *',new_batch);
      
        
         test.stopTest();
    }
    
   static testMethod void FF_Objects_UpdateIntegrationLog(){
   
        List<Account> account_list             = TestCPQUtilityClass.createAccounts(1);
        List<Contact> contact_list             = TestCPQUtilityClass.createContacts(account_list, 1);
        List<Opportunity> opp_list             = TestCPQUtilityClass.createOpportunities(account_list,1);
        List<pse__Proj__c> project_list        = TestCPQUtilityClass.createProject(opp_list, 1);
        List<pse__Milestone__c> milestone_list = TestCPQUtilityClass.createMilestone(project_list, 1);
        insert account_list;
        insert contact_list;
        insert opp_list ;
           
        
        for(pse__Proj__c Proj : project_list)
        {
            //Proj.int_Intacct_Record_No__c = '12355';
            Proj.pse__Is_Active__c = True;
        }
        
        insert project_list;    
        
        pse__Proj__c proj = project_list[0];
        
        
        string PlatformResponse = '{"Id":'+ '"'+ project_list[0].id + '"' + ',"int_Intacct_Record_No__c":"182820"}';

        for(pse__Milestone__c milestone : milestone_list)
        {
            milestone.int_IsSyncing__c  = False;
            milestone.int_Intacct_Project_ID_2__c = 'Test';
            milestone.int_Intacct_Project_Category__c = 'Contract';
            milestone.pse__Project__c = proj.id;
        }
        
        Insert milestone_list; 
       
       List<Integration_Event_Log__c> IntegerationEventLogList = TestCPQUtilityClass.createIntegrationEventLog(1);
       
        string ProjectId   = '"' + project_list[0].id +'"';
        string milestoneId = '"' + milestone_list[0].id + '"';
        string payload  = '{"Name": "Test Project0", "pse__Project_Type__c":"Customer Project", "pse__Stage__c": "Planned", "pse__Start_Date__c":"2018-02-05 00:00:00", "pse__End_Date__c":"2018-02-20 00:00:00", "Id":'+milestoneId +',"int_Intacct_Record_No__c":"12355", "pse__Is_Active__c":"true"';
       
        if(!IntegerationEventLogList.isEmpty())
        {
            
            IntegerationEventLogList[0].Name                        =   project_list[0].id;
            IntegerationEventLogList[0].Debug__c                    =   'Too many SOQL';
            IntegerationEventLogList[0].Payload__c                  =    payload ;
            IntegerationEventLogList[0].Payload_Format__c           =   'JSON';
            IntegerationEventLogList[0].sObjectType__c              =   'pse__Proj__c'; 
            IntegerationEventLogList[0].Type__c                     =   'Intacct Event Response'; 
            IntegerationEventLogList[0].Action__c                   =   'Update Salesforce';
            IntegerationEventLogList[0].Integration_Status__c       =    'In Progress';
            
            insert IntegerationEventLogList;
        }
        
       system.debug('*******List*****'+IntegerationEventLogList);
       
       //  Integration_Event_Log__c IntEventLogToBeUpdate = IntegerationEventLogList[0];
        
        List<Integration_Event_Log__c> IntEventLogList =[SELECT Name,Id,Debug__c,Payload__c,Payload_Format__c,sObjectType__c,Type__c,Action__c,Integration_Status__c FROM Integration_Event_Log__c WHERE Name=:IntegerationEventLogList[0].Name AND Action__c like '%Update%' AND Action__c like '%Salesforce%' order by createdDate desc limit 1];
        
        system.debug('*******size*****'+IntEventLogList.size());
        
        test.startTest();
        
               
        FF_Objects_UpdateIntegrationLog.UpdateSobjetFromIntLog(IntEventLogList);
        
        test.stopTest();
   }
    static testMethod void FF_Objects_UpdateIntegrationLogElse(){
   
        List<Account> account_list             = TestCPQUtilityClass.createAccounts(1);
        List<Contact> contact_list             = TestCPQUtilityClass.createContacts(account_list, 1);
        List<Opportunity> opp_list             = TestCPQUtilityClass.createOpportunities(account_list,1);
        List<pse__Proj__c> project_list        = TestCPQUtilityClass.createProject(opp_list, 1);
        List<pse__Milestone__c> milestone_list = TestCPQUtilityClass.createMilestone(project_list, 1);
        insert account_list;
        insert contact_list;
        insert opp_list ;
           
        
        for(pse__Proj__c Proj : project_list)
        {
            //Proj.int_Intacct_Record_No__c = '12355';
            Proj.pse__Is_Active__c = True;
        }
        
        insert project_list;    
        
        pse__Proj__c proj = project_list[0];
        
        
        string PlatformResponse = '{"Id":'+ '"'+ project_list[0].id + '"' + ',"int_Intacct_Record_No__c":"182820"}';

        for(pse__Milestone__c milestone : milestone_list)
        {
            milestone.int_IsSyncing__c  = False;
            milestone.int_Intacct_Project_ID_2__c = 'Test';
            milestone.int_Intacct_Project_Category__c = 'Contract';
            milestone.pse__Project__c = proj.id;
        }
        
        Insert milestone_list; 
       
       List<Integration_Event_Log__c> IntegerationEventLogList = TestCPQUtilityClass.createIntegrationEventLog(1);
       
        string ProjectId   = '"' + project_list[0].id +'"';
        string milestoneId = '"' + milestone_list[0].id + '"';
        string payload  = '{"Name": "Test Project0", "pse__Project_Type__c":"Customer Project", "pse__Stage__c": "Planned", "pse__Start_Date__c":"2018-02-05 00:00:00", "pse__End_Date__c":"2018-02-20 00:00:00", "Id":'+milestoneId +',"int_Intacct_Record_No__c":"12355", "pse__Is_Active__c":"true"';
       
        if(!IntegerationEventLogList.isEmpty())
        {
            
            IntegerationEventLogList[0].Name                        =   milestone_list[0].id;
            IntegerationEventLogList[0].Debug__c                    =   'Too many SOQL';
            IntegerationEventLogList[0].Payload__c                  =    payload ;
            IntegerationEventLogList[0].Payload_Format__c           =   'JSON';
            IntegerationEventLogList[0].sObjectType__c              =   'pse__Proj__c'; 
            IntegerationEventLogList[0].Type__c                     =   'Intacct Event Response'; 
            IntegerationEventLogList[0].Action__c                   =   'Update Salesforce';
            IntegerationEventLogList[0].Integration_Status__c       =    '';
            
            insert IntegerationEventLogList;
        }
        
       system.debug('*******List*****'+IntegerationEventLogList);
       
       //  Integration_Event_Log__c IntEventLogToBeUpdate = IntegerationEventLogList[0];
        
        List<Integration_Event_Log__c> IntEventLogList =[SELECT Name,Id,Debug__c,Payload__c,Payload_Format__c,sObjectType__c,Type__c,Action__c,Integration_Status__c FROM Integration_Event_Log__c WHERE Name=:IntegerationEventLogList[0].Name AND Action__c like '%Update%' AND Action__c like '%Salesforce%' order by createdDate desc limit 1];
        
        system.debug('*******size*****'+IntEventLogList.size());
        system.debug('*******IntEventLogList*****'+IntEventLogList);
        
        test.startTest();        
        FF_Objects_UpdateIntegrationLog.UpdateSobjetFromIntLog(IntEventLogList);
        test.stopTest();
   }
}