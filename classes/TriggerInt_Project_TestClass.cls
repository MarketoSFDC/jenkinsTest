/**************************************************************************************************************************************
Company Name  :Jade Global Inc.
Created Date  :10th February 2018
Apex Class    :TriggerInt_Project_TestClass 
**************************************************************************************************************************************/

@isTest
public class TriggerInt_Project_TestClass {
  static testmethod void MapFieldsAndPublishIntegrationPlatformEvent()
    {
        List<Account> acc_list = TestCPQUtilityClass.createAccounts(1);
        List<Contact> contact_list = TestCPQUtilityClass.createContacts(acc_list, 1);
        List<opportunity> opp_list = TestCPQUtilityClass.createOpportunities(acc_list,1);
        List<pse__Proj__c> new_proj_List= TestCPQUtilityClass.createProject(opp_list,1); 
        List<pse__Practice__c> new_practice_List = TestCPQUtilityClass.CreatePractice(1);
        test.startTest();
        insert acc_list;
        contact_list[0].pse__Salesforce_User__c = UserInfo.getUserId();
        insert contact_list;
        insert opp_list;
        insert new_practice_List;
        Account acc = acc_list[0];
        Contact con1 = contact_list[0];
        Opportunity opp = opp_list[0];
        pse__Practice__c practice = new_practice_List[0];
        if(new_proj_List!=Null && new_proj_List.size()>0)
        {
        for(pse__Proj__c Proj : new_proj_List)
        {
            Proj.int_Intacct_Project_Category__c = 'Contract';
            Proj.pse__Practice__c = practice.id;
            Proj.pse__Account__c = acc.id;
            Proj.pse__Project_Manager__c = con1.id;
            Proj.pse__Opportunity__c = opp.id;
        }
    insert new_proj_List;
      }
        test.stopTest();
    }
    static testmethod void afterUpdateHelper()
    {
        List<Account> acc_list = TestCPQUtilityClass.createAccounts(2);
        List<Contact> contact_list = TestCPQUtilityClass.createContacts(acc_list, 2);
        List<opportunity> opp_list = TestCPQUtilityClass.createOpportunities(acc_list,1);
        List<pse__Proj__c> new_proj_List= TestCPQUtilityClass.createProject(opp_list,1); 
        List<pse__Practice__c> new_practice_List = TestCPQUtilityClass.CreatePractice(1);
        
        insert acc_list;
        
        User newUser =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser', 'Mkto', 'cfsId');
        newUser.EmployeeNumber='1345';
        Insert newUSer;
             contact_list[0].pse__Salesforce_User__c = UserInfo.getUserId();
             contact_list[1].pse__Salesforce_User__c = newUSer.id;
             contact_list[0].pse__Is_Resource__c = True;
             contact_list[1].pse__Is_Resource__c = True; 
             contact_list[0].pse__Is_Resource_Active__c = True;
             contact_list[1].pse__Is_Resource_Active__c = True; 
        
        insert contact_list[0];
        insert contact_list[1];
        insert opp_list;
        insert new_practice_List;
        Account acc1 = acc_list[0];
        Contact con1 = contact_list[0];
        pse__Practice__c practice = new_practice_List[0];
        if(new_proj_List!=Null && new_proj_List.size()>0)
        {
        for(pse__Proj__c Proj : new_proj_List)
        {
            Proj.pse__Practice__c = practice.id;
            Proj.pse__Account__c = acc1.id;
           Proj.pse__Project_Manager__c = con1.id;
           Proj.Delegated_Project_Manager__c = con1.id;
            Proj.int_Intacct_Project_Category__c = 'Contract';
        }
        
        insert new_proj_List;
        }
        
        System.debug('--------------'+new_proj_List[0].pse__Project_Manager__c);
        Account acc2 = acc_list[1];
        Contact con2 = contact_list[1];
        
        system.debug('******'+new_proj_List[0]+'******');
        for(pse__Proj__c nProj: new_proj_List )
        {
            nProj.pse__Practice__c = practice.id;
            nProj.pse__Account__c = acc2.id;
            nProj.pse__Project_Manager__c = con2.id;
            nProj.Delegated_Project_Manager__c = con2.id;
            nProj.int_Intacct_Record_No__c = 'test';
            nProj.Delegated_Project_Manager_IDw__c = 'test';
            nProj.Project_Manager_IDw__c = 'test1';
            nProj.int_Intacct_Project_Category__c = 'Contract';
            nProj.Integration_Status__c = 'Success';
            SF_Utility.isCalloutExecuted = false;
            
        }
        System.debug('--------------'+new_proj_List[0].pse__Project_Manager__c);
       
        system.debug('******'+new_proj_List[0]+'******');
         test.startTest();
        update new_proj_List;
        
        test.stopTest();
    }
    
    static testMethod void populateFieldOnProject()
    {
        List<Account> acc_list = TestCPQUtilityClass.createAccounts(1);
        List<Contact> contact_list = TestCPQUtilityClass.createContacts(acc_list, 1);
        List<opportunity> opp_list = TestCPQUtilityClass.createOpportunities(acc_list,1);
        List<pse__Proj__c> new_proj_List= TestCPQUtilityClass.createProject(opp_list,1); 
        List<pse__Practice__c> new_practice_List = TestCPQUtilityClass.CreatePractice(1);
     
        insert acc_list;
        contact_list[0].pse__Salesforce_User__c = UserInfo.getUserId();
        insert contact_list;
        insert opp_list;
        insert new_practice_List;
        Account acc = acc_list[0];
        Contact con1 = contact_list[0];
        Opportunity opp = opp_list[0];
        pse__Practice__c practice = new_practice_List[0];
        if(new_proj_List!=Null && new_proj_List.size()>0)
        {
        for(pse__Proj__c Proj : new_proj_List)
        {
            Proj.int_Intacct_Project_Category__c = 'Contract';
            Proj.pse__Practice__c = practice.id;
            Proj.pse__Account__c = acc.id;
            Proj.pse__Project_Manager__c = con1.id;
            Proj.pse__Opportunity__c = opp.id;
        }
        insert new_proj_List;
      }
      
        system.debug('******'+new_proj_List[0]+'******');
        for(pse__Proj__c Proj: new_proj_List )
        {
          
            Proj.int_Intacct_Project_Category__c = 'Contract';
            Proj.pse__Practice__c = practice.id;
            Proj.pse__Account__c = acc.id;
            Proj.pse__Project_Manager__c = con1.id;
            Proj.pse__Opportunity__c = opp.id;
            Proj.Delegated_Project_Manager_IDw__c = 'test';
            Proj.Project_Manager_IDw__c = 'test1';
            Proj.int_Intacct_Record_No__c = '123456';
            Proj.Integration_Status__c = 'Success';
            SF_Utility.isCalloutExecuted = false;
        }
        test.startTest();
        system.debug('******'+new_proj_List[0]+'******');
        update new_proj_List;
        
        test.stopTest();
    }
    
    static testMethod void updateProjectManager(){
        List<Account> acc_list = TestCPQUtilityClass.createAccounts(2);
        List<Contact> contact_list = TestCPQUtilityClass.createContacts(acc_list, 2);
        List<opportunity> opp_list = TestCPQUtilityClass.createOpportunities(acc_list,1);
        List<pse__Proj__c> new_proj_List= TestCPQUtilityClass.createProject(opp_list,1); 
        List<pse__Practice__c> new_practice_List = TestCPQUtilityClass.CreatePractice(1);
     
        insert acc_list;
        
        User newUser =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser', 'Mkto', 'cfsId');
        newUser.EmployeeNumber='1345';
        Insert newUSer;
        
        contact_list[0].pse__Salesforce_User__c = UserInfo.getUserId();
        contact_list[0].pse__Is_Resource__c = True;
        contact_list[0].pse__Is_Resource_Active__c = True;
        contact_list[1].pse__Salesforce_User__c = newUSer.id;
        contact_list[1].pse__Is_Resource__c = True;
        contact_list[1].pse__Is_Resource_Active__c = True;
        insert contact_list[0];
        insert contact_list[1];
        insert opp_list;
        insert new_practice_List;
        
        for(pse__Proj__c Proj : new_proj_List){
            Proj.pse__Practice__c = new_practice_List[0].id;
            Proj.pse__Account__c = acc_list[0].id;
            Proj.pse__Project_Manager__c = contact_list[0].id;
        }
        insert new_proj_List;
       
      //    system.assertEquals(0,Proj_list.size());
        test.startTest();
        for(pse__Proj__c Proj : new_proj_List ) {
            Proj.pse__Practice__c = new_practice_List[0].id;
            Proj.pse__Account__c = acc_list[1].id;
            Proj.pse__Project_Manager__c = contact_list[1].id;
          //  Proj.Delegated_Project_Manager__c = contact_list[0].id;
           // Proj.Project_Manager_IDw__c = 'test';
          //  Proj.Delegated_Project_Manager_IDw__c = 'testing';
           // Proj.int_Intacct_Project_Category__c = 'Contract';
        }
        
        
        
        test.stopTest();
        update new_proj_List;
        List<pse__Proj__c> Proj_list = [select Name from pse__Proj__c where pse__Project_Manager__c=Null];
        system.assertEquals(0,Proj_list.size());
   
    }
    
}