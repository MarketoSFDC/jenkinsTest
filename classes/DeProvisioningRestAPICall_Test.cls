/*********************************************************************************************
*  Created By: Jade global Inc.
*  Created Date: 19th May 2018
*  Purpose  : Test class for "DeProvisioningRestAPICall" class
*********************************************************************************************/

@isTest
public class DeProvisioningRestAPICall_Test {

    static testMethod void updateAssetInsalesforce(){
        List<Account> acc_list = TestCPQUtilityClass.createAccounts(1);
        
        Test.startTest();
        Insert acc_list;
        Asset AssetRecord= new Asset();
        AssetRecord.Name='Test Asset';
        AssetRecord.Accountid=acc_list[0].id;
        insert AssetRecord;
        
        String RequestActionType    = Label.Collection_Request_to_SPA; 
        String StatusToBeUpdated,ResponseTemplate; 

        DeProvisioningRestAPICall.RequestWrapper reqst=new DeProvisioningRestAPICall.RequestWrapper();

        //reqst.Id='02i0m000001Uw3m';
        reqst.Id=AssetRecord.id;
        reqst.MunchkinId = '149-sf-12';
        reqst.Status='Success';
        reqst.ChurnStatus = 'Cancelled Dormant';
        reqst.ChurnMessage = 'Success';

        String JsonMsg=JSON.serialize(reqst);

        list<IntacctAPIResponse__mdt> IntacctAPIRsponse=[Select Action_Match__c,API_Response_Template__c,Title__c,Type_Match__c,sObjectType__c,API_Values__c,Dispatcher_Action__c from IntacctAPIResponse__mdt Where Action_Match__c = :RequestActionType AND Title__c = :RequestActionType];   

        //As Per Best Practice it is important to instantiate the Rest Context 

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;

        DeProvisioningRestAPICall.ResponseWrapper resp =new DeProvisioningRestAPICall.ResponseWrapper(); 
        String resppp=DeProvisioningRestAPICall.updateAssetInSaleforce(reqst); //Call the Method of the Class with Proper       Constructor 
        // System.assert(resp.statusMessage.contains('Test success message'));//Assert the response has message as expected 
        // System.assert(resp.statusCode.contains('Done'));
        // System.assert(resp.acct.Id!=null);//Assert that the Account is inserted and has Id
        Test.stopTest();

    }//end of method updateAssetInsalesforce
    
    static testMethod void updateAssetInsalesforce1(){
               
        List<Account> accList = TestCPQUtilityClass.createAccounts(1);
        insert accList;

        Test.startTest();

        String RequestActionType    = Label.Collection_Request_to_SPA; 
        String StatusToBeUpdated,ResponseTemplate; 

        DeProvisioningRestAPICall.RequestWrapper reqst=new DeProvisioningRestAPICall.RequestWrapper();
        
        Asset newAsset = new Asset(Name = 'testasset', Acct_Prefix__c = 'testtt', Munchkin_ID__c = 'test123', AccountId = accList[0].Id);
        insert newAsset;
        
        reqst.Id=newAsset.Id;
        reqst.MunchkinId = '149-sf-12';
        reqst.Status='Error';
        reqst.ChurnStatus = 'Cancelled';
        reqst.ChurnMessage = 'Error';

        String JsonMsg=JSON.serialize(reqst);

        list<IntacctAPIResponse__mdt> IntacctAPIRsponse=[Select Action_Match__c,API_Response_Template__c,Title__c,Type_Match__c,sObjectType__c,API_Values__c,Dispatcher_Action__c from IntacctAPIResponse__mdt Where Action_Match__c = :RequestActionType AND Title__c = :RequestActionType];   

        //As Per Best Practice it is important to instantiate the Rest Context 

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/DemoUrl';  //Request URL
        req.httpMethod = 'POST';//HTTP Request Type
        req.requestBody = Blob.valueof(JsonMsg);
        RestContext.request = req;
        RestContext.response= res;

        DeProvisioningRestAPICall.ResponseWrapper resp =new DeProvisioningRestAPICall.ResponseWrapper(); 
        String resppp=DeProvisioningRestAPICall.updateAssetInSaleforce(reqst); //Call the Method of the Class with Proper       Constructor 
        // System.assert(resp.statusMessage.contains('Test success message'));//Assert the response has message as expected 
        // System.assert(resp.statusCode.contains('Done'));
        // System.assert(resp.acct.Id!=null);//Assert that the Account is inserted and has Id
        Test.stopTest();

    }//end of method updateAssetInsalesforce
}//end of class DeProvisioningRestAPICall_Test