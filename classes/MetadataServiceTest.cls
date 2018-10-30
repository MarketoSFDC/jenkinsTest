@isTest  
private class MetadataServiceTest
{    
    private class WebServiceMockImpl implements WebServiceMock 
    {
        public void doInvoke(
            Object stub, Object request, Map<String, Object> response,
            String endpoint, String soapAction, String requestName,
            String responseNS, String responseName, String responseType) 
        {
            if(request instanceof MetadataService.retrieve_element)
                response.put('response_x', new MetadataService.retrieveResponse_element());
            else if(request instanceof MetadataService.checkDeployStatus_element)
                response.put('response_x', new MetadataService.checkDeployStatusResponse_element());
            else if(request instanceof MetadataService.listMetadata_element)
                response.put('response_x', new MetadataService.listMetadataResponse_element());
            else if(request instanceof MetadataService.checkRetrieveStatus_element)
                response.put('response_x', new MetadataService.checkRetrieveStatusResponse_element());
            else if(request instanceof MetadataService.describeMetadata_element)
                response.put('response_x', new MetadataService.describeMetadataResponse_element());
            else if(request instanceof MetadataService.deploy_element)
                response.put('response_x', new MetadataService.deployResponse_element());
            else if(request instanceof MetadataService.updateMetadata_element)
                response.put('response_x', new MetadataService.updateMetadataResponse_element());
            else if(request instanceof MetadataService.renameMetadata_element)
                response.put('response_x', new MetadataService.renameMetadataResponse_element());
            else if(request instanceof  MetadataService.cancelDeploy_element)
                response.put('response_x', new MetadataService.cancelDeployResponse_element());
            else if(request instanceof  MetadataService.deleteMetadata_element)
                response.put('response_x', new MetadataService.deleteMetadataResponse_element());
            else if(request instanceof  MetadataService.upsertMetadata_element)
                response.put('response_x', new MetadataService.upsertMetadataResponse_element());
            else if(request instanceof  MetadataService.createMetadata_element)
                response.put('response_x', new MetadataService.createMetadataResponse_element());
            else if(request instanceof  MetadataService.deployRecentValidation_element)
                response.put('response_x', new MetadataService.deployRecentValidationResponse_element());
            else if(request instanceof MetadataService.describeValueType_element)
                response.put('response_x', new MetadataService.describeValueTypeResponse_element());
            else if(request instanceof MetadataService.checkRetrieveStatus_element)
                response.put('response_x', new MetadataService.checkRetrieveStatusResponse_element());
            return;
        }
    }    
        
    @IsTest
    private static void coverGeneratedCodeCRUDOperations()
    {   
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations     
        Test.startTest();    
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        Test.stopTest();
    }
    
    @IsTest
    private static void coverGeneratedCodeFileBasedOperations1()
    {       
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations    
        Test.startTest();     
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        metaDataPort.retrieve(null);
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.listMetadata(null, null);
        metaDataPort.describeMetadata(null);
        metaDataPort.deploy(null, null);
        metaDataPort.checkDeployStatus(null, false);
        metaDataPort.updateMetadata(null);
        metaDataPort.renameMetadata(null, null, null);
        metaDataPort.cancelDeploy(null);
        Test.stopTest();
    }

    @IsTest
    private static void coverGeneratedCodeFileBasedOperations2()
    {       
        // Null Web Service mock implementation
        System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
        // Only required to workaround a current code coverage bug in the platform
        MetadataService metaDataService = new MetadataService();
        // Invoke operations     
        Test.startTest();    
        MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
        metaDataPort.deleteMetadata(null, null);
        metaDataPort.upsertMetadata(null);
        metaDataPort.createMetadata(null);
        metaDataPort.deployRecentValidation(null);
        metaDataPort.describeValueType(null);
        metaDataPort.checkRetrieveStatus(null, null);
        Test.stopTest();
    }
        
    @IsTest
    private static void coverGeneratedCodeTypes()
    {              
        // Reference types
        Test.startTest();       
        new MetadataService();
        new MetadataService.listMetadataResponse_element();
        new MetadataService.CustomLabel();
        Test.stopTest();
    }
     @IsTest
    private static void coverGeneratedCodeTypes1(){
    
        MetadataService metaDataService = new MetadataService();
        // Invoke operations    
        Test.startTest();     
        MetadataService.DeployResult DeployResultnew1                   = new MetadataService.DeployResult();  
        MetadataService.RetrieveResult IReadResult1                     = new MetadataService.RetrieveResult(); 
        MetadataService.DeleteResult DeleteResult1                      = new MetadataService.DeleteResult(); 
        MetadataService.SaveResult  SaveResult1                         = new MetadataService.SaveResult(); 
        MetadataService.Error Error1                                    = new MetadataService.Error(); 
        MetadataService.DescribeMetadataObject DescribeMetadataObject1  = new MetadataService.DescribeMetadataObject(); 
        MetadataService.RetrieveMessage RetrieveMessage1                = new MetadataService.RetrieveMessage(); 
        MetadataService.ValueTypeField ValueTypeField1                  = new MetadataService.ValueTypeField(); 
        MetadataService.LogInfo LogInfo1                                = new MetadataService.LogInfo(); 
        MetadataService.Package_x  Package_x1                           = new MetadataService.Package_x(); 
        MetadataService.ExtendedErrorDetails  ExtendedErrorDetails1     = new MetadataService.ExtendedErrorDetails();                 
        MetadataService.DeployMessage DeployMessage1                    = new MetadataService.DeployMessage(); 
        MetadataService.RunTestsResult RunTestsResult1                  = new MetadataService.RunTestsResult(); 
        MetadataService.PicklistEntry PicklistEntry1                    = new MetadataService.PicklistEntry(); 
        MetadataService.ProfileObjectPermissions ProfileObjectPermissions1   = new MetadataService.ProfileObjectPermissions();  
        MetadataService.PackageTypeMembers PackageTypeMembers1          = new MetadataService.PackageTypeMembers(); 
        MetadataService.CodeCoverageResult CodeCoverageResult1          = new MetadataService.CodeCoverageResult(); 
        MetadataService.CodeCoverageWarning CodeCoverageWarning1        = new MetadataService.CodeCoverageWarning(); 
        MetadataService.RunTestFailure RunTestFailure1                  = new MetadataService.RunTestFailure(); 
        MetadataService.RunTestSuccess RunTestSuccess1                  = new MetadataService.RunTestSuccess(); 
        MetadataService.CodeLocation CodeLocation1                      = new MetadataService.CodeLocation(); 
        MetadataService.DeployDetails DeployDetails1                    = new MetadataService.DeployDetails();
        MetadataService.ListMetadataQuery ListMetadataQuery1            = new MetadataService.ListMetadataQuery(); 
        MetadataService.DeployOptions DeployOptions1                    = new MetadataService.DeployOptions(); 
        MetadataService.RetrieveRequest  RetrieveRequest1               = new MetadataService.RetrieveRequest();         
        MetadataService.FileProperties    FileProperties1               = new MetadataService.FileProperties(); 
        MetadataService.DescribeValueTypeResult  DescribeValueTypeResult1  = new MetadataService.DescribeValueTypeResult(); 
        MetadataService.DebuggingInfo_element DebuggingInfo_element1       = new MetadataService.DebuggingInfo_element();  
        MetadataService.DebuggingHeader_element DebuggingHeader_element1   = new MetadataService.DebuggingHeader_element();  
        MetadataService.CallOptions_element CallOptions_element1           = new MetadataService.CallOptions_element();  
        MetadataService.AllOrNoneHeader_element AllOrNoneHeader_element1   = new MetadataService.AllOrNoneHeader_element();  
        MetadataService.deleteMetadata_element deleteMetadata_element1     = new MetadataService.deleteMetadata_element();  
        MetadataService.readMetadata_element readMetadata_element1         = new MetadataService.readMetadata_element();  
        MetadataService.UpsertResult  UpsertResult1                        = new MetadataService.UpsertResult();  
        MetadataService.AsyncResult   AsyncResult1                         = new MetadataService.AsyncResult();  
        MetadataService.CancelDeployResult CancelDeployResult1             = new MetadataService.CancelDeployResult();  
        MetadataService.DescribeMetadataResult DescribeMetadataResult1     = new MetadataService.DescribeMetadataResult();  
        
        
        
         Test.stopTest();
    
    }

  
}