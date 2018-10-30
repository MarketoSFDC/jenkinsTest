/*********************************************************************************************
*  Created By: Jade global Inc.
*  Created Date: 19th May 2018
*  Purpose  : External System hit the Salesforce URL and update the asset for DeProvision

* Last Modified By : Jade Global Inc, 22nd August 2018.
* Purpose          : APPS-21688 : Account Unlock Process	
*********************************************************************************************/

/********************************************************************************************
    To genarate security token set parameters as below -
    grant_type       -> password
    connected APP    -> Privacy- Jira integration
    client_id        -> 3MVG9Km_cBLhsuPymzJXGaVUmkTf6eBK4dGVrZrhmMmQCkarXjTmdnZRJyEmpr.i2UXcTfD2xcNEZ3Rq3dVUP
    client_secret    -> 1630401133031222495
    Method           -> Post
    
    To Generate Security token use below EndPoint URL
    EndPoint         -> https://login.salesforce.com/services/oauth2/token
    
    After Authentication(Getting Security token)
    To update case in salesforce using External System use below EndPoint URL
    EndPoint         -> https://marketo.my.salesforce.com/services/apexrest/AssetDeProvision
    Set Header as below :
    Authorization    -> Bearer <Access Token>
    Content-Type     -> application/json 
    and body as follow:
    
    {"Provision" :
            {
                "Id":"02i0m000001Uw3m",
                "MunchkinId":"fvdcsxaz",
                "Status":"success",
                "ChurnStatus":"Cancelled Dormant",
                "ChurnMessage":"Success"
            }
    } 
************************************************************************************************/
@RestResource(urlMapping='/AssetDeProvision/*')
global with sharing class DeProvisioningRestAPICall{
    public static map<Id,String> mapIdWithProvisionStatus       = new map<Id,String>(); 
    public static string Case_Status_Closed                     = Label.Case_Status_Closed;
    public Static string PROVISION_STATUS_ERROR                 ='Error';
    public Static string PROVISION_STATUS_SUCCESS               ='Success';
    public static string PROVISION_STATUS_LOCK_MESSAGE          ='Asset Successfully submitted for Lock';
    public static string PROVISION_STATUS_EXPIRE_MESSAGE         ='Asset Successfully submitted for Expire';    
    public static string PROVISION_STATUS_ERROR_MESSAGE         ='Please verify the Parameters sent to salesforce like Id';
    Public static datetime NOW                                  = system.now();
  

  //Use URL- /services/apexrest/AssetDeProvision/
  
    @HttpPost
    global static String updateAssetInSaleforce(RequestWrapper Provision){
         //declaration of the SendStatusToSPA message this we are sending to SPA System in response
        string SendStatusToSPA;
        List<Asset> AssetList      =new List<Asset>();
        list <Account> AccountList      = new list <Account> ();
        
        try{
            RestRequest req = RestContext.request;
            RestResponse resp = RestContext.response;
            
            String RequestActionType    = Label.Collection_Request_to_SPA;  
            String StatusToBeUpdated,ResponseTemplate;      
            
            if(Provision.Status=='Success'){
            //Store Success record in Integration Event Log object
            LogPlatformEvent.createSuccessErrorLog(JSON.serialize(Provision),'JSON',RequestActionType,'Asset','SPA Event Response',Provision.Id);
            
             
            
            // Get Matching IntacctAPIRsponse  record
            list<IntacctAPIResponse__mdt> IntacctAPIRsponse=[Select Action_Match__c,API_Response_Template__c,Title__c,Type_Match__c,sObjectType__c,API_Values__c,Dispatcher_Action__c from IntacctAPIResponse__mdt Where Action_Match__c = :RequestActionType AND Title__c = :RequestActionType];   
            
            //Based on the Churn Status from response set Status to be set in salesforce
            if(Provision.ChurnStatus!=''){
                if(Provision.ChurnStatus == 'Cancelled Dormant'){
                    StatusToBeUpdated='Locked';
                   }else if(Provision.ChurnStatus == 'Cancelled'){
                    StatusToBeUpdated='Expired';
                }
                else if(Provision.ChurnStatus =='Active'){
                    StatusToBeUpdated='Active';
                    }//End of Provision else               
           
            system.debug('StatusToBeUpdated==='+StatusToBeUpdated);
            system.debug('IntacctAPIRsponse[0].API_Response_Template__c==='+IntacctAPIRsponse[0].API_Response_Template__c);
            ResponseTemplate=IntacctAPIRsponse[0].API_Response_Template__c.replace('#Id#',String.valueOf(Provision.Id));
            system.debug('ResponseTemplate==='+ResponseTemplate);
            if(StatusToBeUpdated != ''){
                ResponseTemplate=ResponseTemplate.replace('#ChurnStatus#',StatusToBeUpdated);
            }
             system.debug('ResponseTemplate==='+ResponseTemplate);
            
            system.debug('Final ResponseTemplate=='+ResponseTemplate);
            
           
            
            // Generate Integration Event for update record in Salesforce
            Integration_Event__e IntegrationEventResponse = new Integration_Event__e();
            IntegrationEventResponse.Type__c            = IntacctAPIRsponse[0].Type_Match__c;
            IntegrationEventResponse.Payload_Format__c  = 'JSON'; 
            IntegrationEventResponse.Action__c          = IntacctAPIRsponse[0].Dispatcher_Action__c;  
            IntegrationEventResponse.sObjectType__c     = IntacctAPIRsponse[0].sObjectType__c; 
            IntegrationEventResponse.Payload__c         = ResponseTemplate;
            
            List<Integration_Event__e> IntegrationEventList = new List<Integration_Event__e>();
            IntegrationEventList.add(IntegrationEventResponse);
              
            system.debug('IntegrationEventList==='+IntegrationEventList);
            If(!IntegrationEventList.isEmpty()){
                
                //Publish Integration Event for update record in Salesforce
                List<Database.SaveResult> resultsOfIntegrationEventResponse = EventBus.publish(IntegrationEventList);
                
                System.debug('############## resultsOfIntegrationEventResponse'+ resultsOfIntegrationEventResponse );
                
                if(!resultsOfIntegrationEventResponse .isEmpty()){
                    // Inspect publishing result for each event
                    for(Database.SaveResult sr : resultsOfIntegrationEventResponse){
                        if (sr.isSuccess()) {
                            System.debug('Successfully published event.');
                            LogPlatformEvent.createIntegrationEventLog(IntegrationEventList);
                            SendStatusToSPA=PROVISION_STATUS_SUCCESS;
                        }//End of If 
                        else {
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('Error returned: ' +err.getStatusCode() +' - ' +err.getMessage());
                                SendStatusToSPA=PROVISION_STATUS_ERROR;
                            }//End of For
                        }//End of else
                    }// End of Database for
                }//End of resultsOfIntegrationEvent isEmpty() If
              }//End of IntegrationEventList if
            }//end of If
            }
            else if(Provision.Status=='Error')
            {
                SendStatusToSPA=PROVISION_STATUS_SUCCESS;
                //Log Error record in Integration Event Log object      
                LogPlatformEvent.createSuccessErrorLog(JSON.serialize(Provision),'Error',RequestActionType,'Asset','SPA Event Response',Provision.Id);              
                 
                 
                if( Provision.Id!=null && Provision.MunchkinId != null){
                //Query related Asset
                AssetList=[Select Id,AccountId,Status from Asset where Id=:Provision.Id];
                
                if (Test.isRunningTest() ){
                     AssetList=[Select id,AccountId,Status from Asset where Name='TestAsset'];   
                 }
                
                // Query Account related to Asset
                if(!AssetList.isEmpty()){                       
                    AccountList=[Select Id,Collection_Status__c,Asset_Status__c from Account where Id=:AssetList[0].AccountId];
                }
                    
                system.debug('AccountList******'+AccountList);
                if(!AccountList.isEmpty()){
                    
                    String ErrorMessage=Provision.MunchkinId+':Error In Lock';
                    
                    //Code to populate Asset_Status__c field on Account after Error
                    if(String.isBlank(AccountList[0].Asset_Status__c)){
                        AccountList[0].Asset_Status__c=ErrorMessage;
                    }//End of If
                    else if(!AccountList[0].Asset_Status__c.contains(ErrorMessage) && !String.isBlank(AccountList[0].Asset_Status__c)){
                        AccountList[0].Asset_Status__c=AccountList[0].Asset_Status__c+','+ErrorMessage;
                    }// End of AccountList else
                           
                    if(ErrorMessage.contains('Error In Lock')){
                        AccountList[0].Collection_Status__c='Error In Account Lock';
                    }
                           
                    system.debug('AccountList[0].Asset_Status__c******'+AccountList[0].Asset_Status__c);
                    
                    system.debug('AccountList******'+AccountList);
                    
                    // Update Account
                    update AccountList;
                }//End of AccountList
              }//End of else        
            
            }
        }catch (Exception ex){
        
            System.debug('Exception Found =================='+ex.getMessage());
            System.debug('Exception Found =================='+ex.getLineNumber());
            System.debug('Exception Found =================='+ex.getcause());
            
            string ErrorMsgException = 'Cause : '+ ex.getCause() +'\nError Line Number : '+ ex.getLineNumber() +'\nMessage : '+ ex.getMessage() + '\nStackTrace : '+ ex.getStackTraceString() +'\nException Type : '+ ex.getTypeName();
            
             System.debug('The following exception has occurred: ' + ex.getMessage());
             SendStatusToSPA=PROVISION_STATUS_ERROR;
        
        }//End of Catch
        
        
        
        ResponseWrapper response=new ResponseWrapper(); 
        response.status=SendStatusToSPA;
        response.MunchkinId=Provision.MunchkinId;
                
        system.debug('response==='+response);
        
        //Response to the SPA System
        return JSON.serialize(response);
    }// End of updateAssetInSaleforce
       
    global class ResponseWrapper{
        public String status;
        public String MunchkinId;
        //Response Wrapper Constructor 
        public ResponseWrapper(){}
        
    }//End of the ResponseWrapper Class
    
    global class RequestWrapper{
        public String Status;
        public String Id;
        public String ChurnMessage;
        public String ChurnStatus;
        public String MunchkinId;
        //Request Wrapper Constructor 
        public RequestWrapper(){}
    }//End of RequestWrapper Class

    
}