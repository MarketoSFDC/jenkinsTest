/**************************************************************************************************************************************
Company Name  :Jade Global Inc.
Created Date  :10th February 2018
Apex Class    :SF_Utility_TestClass
**************************************************************************************************************************************/

@isTest
public class SF_Utility_TestClass{

    static testmethod void  SF_UtilityFutureMethod(){
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
       // SF_Utility.UpdateRecordsFromIntacctResponse(milestone_list[0].id,'pse__Milestone__c','success',null); 
        
        //Error Another Method
       // SF_Utility.UpdateRecordsFromIntacctResponse('aEl1g0000008a0R','pse__Milestone__c','success',null); 
        
        list<Integration_Event__e> platformEventList     = new list<Integration_Event__e>();
        
        Integration_Event__e platformEvent               = new Integration_Event__e();
        platformEvent.Type__c                            = 'Intacct Event Response';
        platformEvent.Payload_Format__c                  = 'JSON'; 
        platformEvent.Action__c                          = 'Update Project in Intacct';
        platformEvent.sObjectType__c                     = 'pse__Proj__c'; 
        platformEvent.Payload__c                         = PlatformResponse;
        platformEventList.add(platformEvent);     
        
        Test.startTest();
        
        
       
        // Publish test event
        list<Database.SaveResult> sr = EventBus.publish(platformEventList);
        Test.stopTest(); 
        Type t = Type.forName('SF_Utility');
        dynamicMethodHandlerInterface Handler = (dynamicMethodHandlerInterface)t.newInstance();   
        Handler.dynamicMethodHandler(platformEventList); 
        
        string ProjectId   = '"' + project_list[0].id +'"';
        string milestoneId = '"' + milestone_list[0].id + '"';
    //    string payload  = '{"Name": "Test Project0","pse__Stage__c": "Planned", "pse__Start_Date__c":"2018-02-05 00:00:00", "pse__End_Date__c":"2018-02-20 00:00:00", "Id":'+milestoneId +',"int_Intacct_Record_No__c":"12355", "pse__Is_Active__c":"true"}';   
      string payload  = '{"Name": "Test Project0","Id":'+milestoneId +',"int_Intacct_Record_No__c":"12355"}';   
        Integration_Event_Log__c IntLog    = new Integration_Event_Log__c();

        IntLog.Debug__c                    =   'Too many SOQL';
        IntLog.Payload__c                  =    payload ;
        IntLog.Payload_Format__c           =   'JSON';
        IntLog.sObjectType__c              =   'pse__Proj__c'; 
        IntLog.Type__c                     =   'Intacct Event Response'; 
        IntLog.Action__c                   =   'Update Milestone in Intacct';

        insert IntLog;
        
        SF_Utility.UpdateSobjectRecord(payload,'pse__Milestone__c','Update Milestone in Intacct','Intacct Event Response',IntLog.id);
       
    }
    static testmethod void UpdateSobjectRecord(){
    List<Account> acc_list = TestCPQUtilityClass.createAccounts(1);
        List<Contact> contact_list = TestCPQUtilityClass.createContacts(acc_list, 1);
        List<opportunity> opp_list = TestCPQUtilityClass.createOpportunities(acc_list,1);
        List<Asset>Asset_List= new List<Asset>();
        insert acc_list; 
        insert contact_list;
        opp_list[0].StageName='Not Contacted';
        insert opp_list;
        Asset AssetRecord = new Asset(Name='TestAsset', Accountid=acc_list[0].id,Status='Active',Latest_Opportunity__c=Opp_list[0].id,Munchkin_ID__c='ASDFGBHJMM');
        Asset_List.add(AssetRecord);  
        insert Asset_List;
        string assetId = '"' + Asset_List[0].id + '"';
             String payload = JSON.serialize(Asset_List[0]);
        String Payload1='{"Id":'+assetId +',"Status":"Locked"}';
        Integration_Event__e IntegrationEvent = new  Integration_Event__e();
        IntegrationEvent.Payload__c = payload;
        IntegrationEvent.sObjectType__c = 'Asset';
        IntegrationEvent.Payload_Format__c = 'JSON';
        Database.SaveResult resultsOfIntegrationEventResponse = EventBus.publish(IntegrationEvent);
        Integration_Event_Log__c IntLog    = new Integration_Event_Log__c();

        IntLog.Debug__c                    =   'Too many SOQL';
        IntLog.Payload__c                  =    payload1 ;
        IntLog.Payload_Format__c           =   'JSON';
        IntLog.sObjectType__c              =   'Asset'; 
        IntLog.Type__c                     =   'SPA Event Response'; 
        IntLog.Action__c                   =   'Update Asset in Salesforce';
        
        insert IntLog;
        
        SF_Utility.UpdateSobjectRecord(payload1,'Asset','Update Asset in Salesforce','SPA Event Response',IntLog.id);
        Payload1='{"Id":'+assetId +',"Status":"Active"}';
        IntLog.Payload__c                  =    payload1 ;
        update IntLog;
        SF_Utility.UpdateSobjectRecord(payload1,'Asset','Update Asset in Salesforce','SPA Event Response',IntLog.id);
        
    }
    static testmethod void Sf_Utility_UpdateRecord(){
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
        SF_Utility.UpdateRecordsFromIntacctResponse(milestone_list[0].id,'pse__Milestone__c','success',null); 
        
        //Error Another Method
        SF_Utility.UpdateRecordsFromIntacctResponse('aEl1g0000008a0R','pse__Milestone__c','success',null); 
        /*
        list<Integration_Event__e> platformEventList     = new list<Integration_Event__e>();
        
        Integration_Event__e platformEvent               = new Integration_Event__e();
        platformEvent.Type__c                            = 'Intacct Event Response';
        platformEvent.Payload_Format__c                  = 'JSON'; 
        platformEvent.Action__c                          = 'Update Project in Intacct';
        platformEvent.sObjectType__c                     = 'pse__Proj__c'; 
        platformEvent.Payload__c                         = PlatformResponse;
        platformEventList.add(platformEvent);     
        
        Test.startTest();
        
        
       
        // Publish test event
        list<Database.SaveResult> sr = EventBus.publish(platformEventList);
        Test.stopTest(); 
        Type t = Type.forName('SF_Utility');
        dynamicMethodHandlerInterface Handler = (dynamicMethodHandlerInterface)t.newInstance();   
        Handler.dynamicMethodHandler(platformEventList); 
        
        string ProjectId = '"' + project_list[0].id +'"';
        string payload  = '{"Name": "Test Project0", "pse__Project_Type__c":"Customer Project", "pse__Stage__c": "Planned", "pse__Start_Date__c":"2018-02-05 00:00:00", "pse__End_Date__c":"2018-02-20 00:00:00", "Id":'+ProjectId +',"int_Intacct_Record_No__c":"12355", "pse__Is_Active__c":"true"';   
        Integration_Event_Log__c IntLog    = new Integration_Event_Log__c();

        IntLog.Debug__c                    =   'Too many SOQL';
        IntLog.Payload__c                  =    payload ;
        IntLog.Payload_Format__c           =   'JSON';
        IntLog.sObjectType__c              =   'pse__Proj__c'; 
        IntLog.Type__c                     =   'Intacct Event Response'; 
        IntLog.Action__c                   =   'Update Project in Intacct';

        insert IntLog;
        
        SF_Utility.UpdateSobjectRecord(payload,'pse__Proj__c','Update Project in Intacct','Intacct Event Response','a1F1g000000OkQo');
       */
    }
     static testmethod void Sf_Utility_UpdateErrorRecord(){
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
        
        //Error Another Method
        SF_Utility.UpdateRecordsFromIntacctResponse('aEl1g0000008a0R','test','success',null); 

    }
}