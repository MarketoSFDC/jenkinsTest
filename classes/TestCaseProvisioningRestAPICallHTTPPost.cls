@istest
public class TestCaseProvisioningRestAPICallHTTPPost{

 static testMethod void  updateMethodTest(){
   
   List<Account> testAccRecordList = TestCPQUtilityClass.createAccounts(1);
   INSERT testAccRecordList;
   
   List<Opportunity> testOpportunityRecordsList = TestCPQUtilityClass.createOpportunities(testAccRecordList,1);
   INSERT testOpportunityRecordsList;
   
   List<Case> testCaseRecordsList = TestCPQUtilityClass.createCases(testOpportunityRecordsList,1);
   INSERT testCaseRecordsList;
   
   string testStr = '{"Provision":{"Id":\"testCaseRecordsList[0].id\","Status":"WARNING","Message":"Test Message"}}';
   
   
   CaseProvisioningRestAPICall reqst=new CaseProvisioningRestAPICall();
   String JsonMsg=JSON.serialize(testStr);
   Test.startTest();

   RestRequest req = new RestRequest(); 
   RestResponse res = new RestResponse();

    req.requestURI = 'https://marketo--staging.cs50.my.salesforce.com/services/apexrest/CaseProvision';  //Request URL
    req.httpMethod = 'POST';//HTTP Request Type
    req.requestBody = Blob.valueof(JsonMsg);
    RestContext.request = req;
    RestContext.response= res;
	
	CaseProvisioningRestAPICall.ProvisionCase();
	
	//####################
	
	CaseProvisioningRestAPICall.RequestWrapper reqWrapper = new CaseProvisioningRestAPICall.RequestWrapper();
	reqWrapper.Id = testCaseRecordsList[0].id;
	reqWrapper.Status = 'Success';
	reqWrapper.Message = 'Test Message';
	
    CaseProvisioningRestAPICall.updateProvisionCase(reqWrapper);
	
	if(!testCaseRecordsList.isEmpty()){
		testCaseRecordsList[0].Status = 'Success';
		testCaseRecordsList[0].SPA_Message__c = 'Provisioning Successfull';
		
		update testCaseRecordsList;
	}
	
	//####################
	
	CaseProvisioningRestAPICall.RequestWrapper reqWrapper1 = new CaseProvisioningRestAPICall.RequestWrapper();
	reqWrapper1.Id = testCaseRecordsList[0].id;
	reqWrapper1.Status = 'Success';
	reqWrapper1.Message = null;
	
    CaseProvisioningRestAPICall.updateProvisionCase(reqWrapper1);
	
	if(!testCaseRecordsList.isEmpty()){
		testCaseRecordsList[0].Status = 'Success';
		testCaseRecordsList[0].SPA_Message__c = 'Provisioning Successfull';
		
		update testCaseRecordsList;
	}
	//####################
	
	CaseProvisioningRestAPICall.RequestWrapper reqWrapper2 = new CaseProvisioningRestAPICall.RequestWrapper();
	reqWrapper2.Id = testCaseRecordsList[0].id;
	reqWrapper2.Status = 'Success';
	reqWrapper2.Message = 'Test Message';
	
    CaseProvisioningRestAPICall.updateProvisionCase(reqWrapper);
	
	if(!testCaseRecordsList.isEmpty()){
		testCaseRecordsList[0].Status = 'Completed';
		testCaseRecordsList[0].SPA_Message__c = 'Provisioning Successfull';
		
		update testCaseRecordsList;
	}

    Test.stopTest();

   }
}