/**************************************************************************************************************************************
Company Name  :Jade Global Inc.
Created Date  :10th February 2018
Apex Class    :Intacct_API_Test
**************************************************************************************************************************************/

@isTest
public class Intacct_API_Test {
    
    @isTest static void IntacctAPICallSucess() {
       
        // Set sucess mock callout class 
        Test.setMock(HttpCalloutMock.class, new IntacctCalloutMock());
    
        List<Account> acc_list = TestCPQUtilityClass.createAccounts(1);
        List<Contact> contact_list = TestCPQUtilityClass.createContacts(acc_list, 1);
        List<opportunity> opp_list = TestCPQUtilityClass.createOpportunities(acc_list,1);
        List<pse__Proj__c> new_proj_List= TestCPQUtilityClass.createProject(opp_list,1); 
        List<pse__Practice__c> new_practice_List = TestCPQUtilityClass.CreatePractice(1);
     
        insert acc_list;
        insert contact_list;
        insert opp_list;
        insert new_practice_List;
        
        Account acc = acc_list[0];
        Contact con1 = contact_list[0];
        Opportunity opp = opp_list[0];
        pse__Practice__c practice = new_practice_List[0];
        
        if(new_proj_List!=Null && new_proj_List.size()>0){
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
        
        
        String payload = JSON.serialize(new_proj_List[0]);
        
        list<IntacctAPIRequest__mdt>  APIRequestList = [SELECT Action_Match__c,Title__c,API_Request_Template__c,API_Version__c FROM IntacctAPIRequest__mdt where Action_Match__c = 'Create Project in Intacct'];
         
        Integration_Event__e IntegrationEvent = new  Integration_Event__e();
        IntegrationEvent.Payload__c = payload;
        IntegrationEvent.sObjectType__c = 'pse__Proj__c';
        test.startTest();
        Database.SaveResult resultsOfIntegrationEventResponse = EventBus.publish(IntegrationEvent);
       
        HttpResponse res = new HttpResponse();   
         String XMLBody = Generate_XML.xmlBuild(APIRequestList[0].API_Request_Template__c,IntegrationEvent.Payload__c,APIRequestList[0].API_Version__c);   
          XMLBody = XMLBody.Replace('#Today#',date.today().format());
         Intacct_API.IntacctAPICall(XMLBody,APIRequestList[0].Action_Match__c, APIRequestList[0].Title__c,IntegrationEvent.Payload__c,IntegrationEvent.sObjectType__c); 
        
         test.stopTest();
    }//End IntacctAPICallSucess
    
    @isTest static void IntacctAPICallError() {
       
        // Set Error callout class 
        Test.setMock(HttpCalloutMock.class, new IntacctErrorCalloutMock());
    
        List<Account> acc_list = TestCPQUtilityClass.createAccounts(1);
        List<Contact> contact_list = TestCPQUtilityClass.createContacts(acc_list, 1);
        List<opportunity> opp_list = TestCPQUtilityClass.createOpportunities(acc_list,1);
        List<pse__Proj__c> new_proj_List= TestCPQUtilityClass.createProject(opp_list,1); 
        List<pse__Practice__c> new_practice_List = TestCPQUtilityClass.CreatePractice(1);
     
        insert acc_list;
        insert contact_list;
        insert opp_list;
        insert new_practice_List;
        
        Account acc = acc_list[0];
        Contact con1 = contact_list[0];
        Opportunity opp = opp_list[0];
        pse__Practice__c practice = new_practice_List[0];
        
        if(new_proj_List!=Null && new_proj_List.size()>0){
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
        
        
        String payload = JSON.serialize(new_proj_List[0]);
        
        list<IntacctAPIRequest__mdt>  APIRequestList = [SELECT Action_Match__c,Title__c,API_Request_Template__c,API_Version__c FROM IntacctAPIRequest__mdt where Action_Match__c = 'Create Project in Intacct'];
         
        Integration_Event__e IntegrationEvent = new  Integration_Event__e();
        IntegrationEvent.Payload__c = payload;
        IntegrationEvent.sObjectType__c = 'pse__Proj__c';
        test.startTest();
        Database.SaveResult resultsOfIntegrationEventResponse = EventBus.publish(IntegrationEvent);
       
        HttpResponse res = new HttpResponse();   
         String XMLBody = Generate_XML.xmlBuild(APIRequestList[0].API_Request_Template__c,IntegrationEvent.Payload__c,APIRequestList[0].API_Version__c);   
          XMLBody = XMLBody.Replace('#Today#',date.today().format());
         Intacct_API.IntacctAPICall(XMLBody,APIRequestList[0].Action_Match__c, APIRequestList[0].Title__c,IntegrationEvent.Payload__c,IntegrationEvent.sObjectType__c); 
        
         test.stopTest();
         
    }//End IntacctAPICallError
    
}//Intacct_API_Test