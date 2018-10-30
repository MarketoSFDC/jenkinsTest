/*****************************************************************************
Created By    : Jade Global Inc
Created Date  : 19th May 2018
Purpose       : Test class for "AssetAutoDeProvisioning"
******************************************************************************/
@isTest
public class AssetAutoDeProvisioning_test {
      @testSetup static void methodName() {
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
     
    
    }
    @isTest static void SPAAPICallSucess() {
        
    String certName     = Label.OAP_certName;
    string payloadFormat      = JSON.serialize('JSON');
    string INTACCT_ENDPOINT   = Label.Intacct_endpoint;
    String endpoint     = Label.OAP_endpoint;

         // Set sucess mock callout class 
        Test.setMock(HttpCalloutMock.class, new SPACalloutMock());
      
        test.startTest();
        List<Asset> Asset_List =[Select id,Name,Accountid,status from asset];
        String payload = JSON.serialize(Asset_List[0]);
        String AssetId = '"' + Asset_List[0].id +'"';
        String Payload1='{"Id":'+AssetId +',"Status":"Locked"}';
        Integration_Event__e IntegrationEvent = new  Integration_Event__e();
        IntegrationEvent.Payload__c = payload;
        IntegrationEvent.sObjectType__c = 'Asset';
        IntegrationEvent.Payload_Format__c = 'JSON';
        Database.SaveResult resultsOfIntegrationEventResponse = EventBus.publish(IntegrationEvent);
        Integration_Event_Log__c IntLog    = new Integration_Event_Log__c();

        IntLog.Debug__c                    =   'Too many SOQL';
        IntLog.Payload__c                  =    payload ;
        IntLog.Payload_Format__c           =   'JSON';
        IntLog.sObjectType__c              =   'Asset'; 
        IntLog.Type__c                     =   'SPA Event Response'; 
        IntLog.Action__c                   =   'Update Asset in Salesforce';

        insert IntLog;
        
        SF_Utility.UpdateSobjectRecord(payload1,'Asset','Update Asset in Salesforce','SPA Event Response',IntLog.id);
       
        List<Integration_Event__e> IntEventList = new List<Integration_Event__e>();
        IntEventList.add(IntegrationEvent);
    list<IntacctAPIRequest__mdt>  APIRequestList = [SELECT Action_Match__c,Title__c,API_Request_Template__c,API_Version__c FROM IntacctAPIRequest__mdt where Action_Match__c = 'Collection Request to SPA'];
        HttpResponse res = new HttpResponse();   
        String XMLBody = Generate_XML.xmlBuild(APIRequestList[0].API_Request_Template__c,IntegrationEvent.Payload__c,APIRequestList[0].API_Version__c);   
        XMLBody = XMLBody.Replace('#Today#',date.today().format());
        AssetAutoDeProvisioning.SPAAPICall(XMLBody,APIRequestList[0].Action_Match__c, APIRequestList[0].Title__c,IntegrationEvent.Payload__c,IntegrationEvent.sObjectType__c); 
      
        AssetAutoDeProvisioning.dynamicMethodHandler(IntEventList);
        List<Id> AccId = new List<Id>();
        AccId.add(Asset_List[0].Accountid);
        AssetAutoDeProvisioning.CollectionLockRequest(AccId);
        Asset_List[0].Status='Locked';
        update Asset_List;
        AssetAutoDeProvisioning.PublishPlatformEventForAsset(AccId[0],'Unlock');
        test.stopTest();
    }
  
  @isTest static void AssetAPICallError() {
    
       
        // Set Error callout class 
        Test.setMock(HttpCalloutMock.class, new SPAErrorCalloutMock());

        List<Asset> Asset_List =[Select id,Name,Accountid from asset];
        String payload = JSON.serialize(Asset_List[0]);
        
        list<IntacctAPIRequest__mdt>  APIRequestList = [SELECT Action_Match__c,Title__c,API_Request_Template__c,API_Version__c FROM IntacctAPIRequest__mdt where Action_Match__c = 'Collection Request to SPA'];
         
        Integration_Event__e IntegrationEvent = new  Integration_Event__e();
        IntegrationEvent.Payload__c = payload;
        IntegrationEvent.sObjectType__c = 'Asset';

        test.startTest();
        Database.SaveResult resultsOfIntegrationEventResponse = EventBus.publish(IntegrationEvent);
       
        HttpResponse res = new HttpResponse();   
         String XMLBody = Generate_XML.xmlBuild(APIRequestList[0].API_Request_Template__c,IntegrationEvent.Payload__c,APIRequestList[0].API_Version__c);   
          XMLBody = XMLBody.Replace('#Today#',date.today().format());
           AssetAutoDeProvisioning.SPAAPICall(XMLBody,APIRequestList[0].Action_Match__c, APIRequestList[0].Title__c,IntegrationEvent.Payload__c,IntegrationEvent.sObjectType__c); 
        
         test.stopTest();
         
    }//End SPAAPICallError
    
}