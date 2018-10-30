/*****************************************************************************
Created By    : Jade Global Inc
Created Date  : 19th May 2018
Purpose       : APPS-17767:Collection Lock Requirement
                Send request to SPA for Account Lock
Last Modified By : Jade Global Inc, 22nd August 2018.
Purpose          : APPS-21688 : Account Unlock Process      

******************************************************************************/
Global class AssetAutoDeProvisioning implements dynamicMethodHandlerInterface{
    public static final String certName     = Label.OAP_certName;
    public static string payloadFormat      = 'JSON';
    public static string INTACCT_ENDPOINT   = Label.Intacct_endpoint;
    public static final String endpoint     = Label.AssetChurnEndpoint;
   
    //Method is created to handle the dynamic method calling scenario
    Public static void dynamicMethodHandler(List<Integration_Event__e> newList){
        DeProvisionAssetInSPA(newList);
        system.debug('newList@@@@'+newList);
    }
    
    //Method is used to create JSON body and make SPA callout 
    public static void DeProvisionAssetInSPA(list<Integration_Event__e> platformEventList){
    
        // Query all records from Intacct API Request
        list<IntacctAPIRequest__mdt> IntacctAPIRequest=[Select Action_Match__c,API_Request_Template__c,Title__c,Type_Match__c,API_Version__c from IntacctAPIRequest__mdt];
    
        system.debug('IntacctAPIRequest#####'+IntacctAPIRequest);
   
        for(Integration_Event__e IntegrationEvent : platformEventList){ 
            system.debug('IntegrationEvent.Payload__c!!!!!!!!'+IntegrationEvent.Payload__c);
            
            //Create map of payload 
            Map<String,String> HashMap = Generate_XML.ReplaceMap(IntegrationEvent.Payload__c);      
            String recordId = '';   
            
            if(HashMap.containsKey('Id')){
                recordId = HashMap.get('Id');
                system.debug('recordId!!!!!!!!!!!!!'+recordId);
            }   
            
         try{                   
            
            // If payload type is JSON 
            if(IntegrationEvent.Payload_Format__c == payloadFormat){
                for(IntacctAPIRequest__mdt APIRequest :IntacctAPIRequest){
                    //Check condition before creating JSON and callout 
                    system.debug('APIRequest.Action_Match__c====='+APIRequest.Action_Match__c);
                          
                    system.debug('IntegrationEvent.Payload__c====='+IntegrationEvent.Payload__c);
                    
                    //Check Action and Type of Integration Event and API Request
                    if(APIRequest.Action_Match__c == IntegrationEvent.Action__c && APIRequest.Type_Match__c== IntegrationEvent.Type__c){
                        
                        //Get JSON body 
                        String JSONBody=Generate_XML.xmlBuild(APIRequest.API_Request_Template__c,IntegrationEvent.Payload__c,APIRequest.API_Version__c);
                            
                        system.debug('JSONBody'+JSONBody);
                             
                        //send callout to SPA
                        SPAAPICall(JSONBody,APIRequest.Action_Match__c,APIRequest.Title__c,IntegrationEvent.Payload__c,IntegrationEvent.sObjectType__c);  
                                
                        //Store Request details in Integration Event Log Object
                        LogPlatformEvent.createIntacctRequestLog(JSONBody,APIRequest.Action_Match__c,IntegrationEvent.sObjectType__c,'SPA JSON Raw Data Request',recordId);                            
                    }// End Of APIRequest If
                }// End of IntacctAPIRequest__mdt For
            }//End of IntegrationEvent If
        }catch(Exception ex){
            System.debug('Exception Found =================='+ex.getMessage());
            System.debug('Exception Found =================='+ex.getLineNumber());
            System.debug('Exception Found =================='+ex.getcause());
            
            string ErrorMsgException = 'Cause : '+ ex.getCause() +'\nError Line Number : '+ ex.getLineNumber() +'\nMessage : '+ ex.getMessage() + '\nStackTrace : '+ ex.getStackTraceString() +'\nException Type : '+ ex.getTypeName();
            
            //Store Error log in Integration Event Log Object
            LogPlatformEvent.createErrorLog( ErrorMsgException, IntegrationEvent.sObjectType__c, IntegrationEvent.Action__c, IntegrationEvent.Payload__c, IntegrationEvent.Type__c, recordId, null);
            
        }// End of Catch    
           
        }// End of Integration_Event__e for
     
    }// End of DeProvisionAssetInSPA Method
    
    // Method is created to make callout to SPA
    @future(callout=true)
    public static void SPAAPICall(string JSONBody,String RequestActionType,String RequestTitle,String ReqPayload,String sObjectcType){
        
        Map<String,String> HashMap      = Generate_XML.ReplaceMap(ReqPayload);
        Map<String,String> SPAResponse  = new Map<String,String>();
        list <Account> AccountList      = new list <Account> ();
        list <Asset> AssetList          = new list <Asset> ();
        List<Integration_Event__e> IntegrationEventList = new List<Integration_Event__e>();
        Integration_Event__e IntegrationEventResponse = new Integration_Event__e();
        string Status='';
        Id recordId;
        string ResponseTemplate;
    try{    
        If(HashMap.containsKey('Id')){
            recordId = HashMap.get('Id');
            system.debug('Object Id=='+recordId);
        }     
        
        system.debug('HashMap@@@'+HashMap);
        system.debug('Munchkin_ID__c Id=='+HashMap.get('Munchkin_ID__c'));
       
       //To test code after connection UNCOMMENT line no 99 to 118 , COMMENT line no 120 to 126
       //Create HTTP request
        HTTPRequest req = new HttpRequest();
        HTTPResponse hTTPRes;
        req.setTimeout(120000);
        system.debug('JSONBody ###############'+JSONBody);
        string SPACallBody = JSONBody.replace('\r\n','&');
        string finalSPACallBody = SPACallBody.replaceAll('(\\s+)', '');
        system.debug('SPACallBody ############'+SPACallBody);
        req.setBody(SPACallBody);
        req.setEndpoint(AssetAutoDeProvisioning.endpoint);
        // Set method to POST
        req.setMethod('POST');  
        if (!Test.isRunningTest() )
        {
            if( AssetAutoDeProvisioning.certName != null) {
            req.setClientCertificateName(AssetAutoDeProvisioning.certName);
            }
        }
        system.debug('req@@@'+req);
        HTTP http = new HTTP();
        
        //Send http call out to SPA
        hTTPRes = http.send(req);
        integer status_code = hTTPRes.getStatusCode();
        String responseJSONString= hTTPRes.getBody();
        
        system.debug('responseJSONString  =================='+responseJSONString);
        system.debug('status_code  =================='+status_code); 
            // To check Churn status for error message - Added as part of Unlock Process
            SPAResponse=Generate_XML.ReplaceMap(responseJSONString);
            system.debug('SPAResponse  =================='+SPAResponse);
       
        // Check Response is Success
        
        if(status_code == 200 ){
            system.debug('Asset is successfully sent to SPA, Asset will get update in saleforce based on SPA response');
       
        }//End of StatusCode If
        else if(!responseJSONString.contains('#')){
        
        //Log Error record in Integration Event Log object      
        LogPlatformEvent.createSuccessErrorLog(responseJSONString,'Error',RequestActionType,sObjectcType,'SPA Event Response',recordId);
        if (Test.isRunningTest() ){
             AssetList=[Select id,AccountId,Status,Munchkin_ID__c from Asset where Name='TestAsset'];   
             HashMap.put('id',AssetList[0].id);
             HashMap.put('Munchkin_ID__c',AssetList[0].Munchkin_ID__c);
         }
        if( !HashMap.isEmpty() && HashMap.containsKey('Id') && HashMap.containsKey('Munchkin_ID__c')){
        //Query related Asset
        AssetList=[Select Id,AccountId,Status from Asset where Id=:HashMap.get('Id')];

        // Query Account related to Asset
        if(!AssetList.isEmpty()){                       
            AccountList=[Select Id,Collection_Status__c,Asset_Status__c from Account where Id=:AssetList[0].AccountId];
        }
            
        system.debug('AccountList******'+AccountList);
        if(!AccountList.isEmpty()){
                        // To check whether error is in lock or Unlock
                        String ErrorMessage=SPAResponse.get('Churn Status')=='Active'? SPAResponse.get('Munchkin Id')+':Error In Lock':SPAResponse.get('Munchkin Id')+ ':Error In Unlock';
                        system.debug('ErrorMessage'+ErrorMessage);
                        //Code to populate Asset_Status__c field on Account after Error
                        if(String.isBlank(AccountList[0].Asset_Status__c)){
                            AccountList[0].Asset_Status__c=ErrorMessage;
                        }//End of If
                        else if(!AccountList[0].Asset_Status__c.contains(ErrorMessage) && !String.isBlank(AccountList[0].Asset_Status__c)){
                            if(AccountList[0].Asset_Status__c.contains(SPAResponse.get('Munchkin Id')+':Locked Successfully')  )
                            {
                                
                                AccountList[0].Asset_Status__c=AccountList[0].Asset_Status__c.replace(SPAResponse.get('Munchkin Id')+':Locked Successfully',ErrorMessage);
                            }//End of If
                            else if(AccountList[0].Asset_Status__c.contains(SPAResponse.get('Munchkin Id')+':Unlocked Successfully' ))
                            {
                                AccountList[0].Asset_Status__c=AccountList[0].Asset_Status__c.replace(SPAResponse.get('Munchkin Id')+':Unlocked Successfully',ErrorMessage);
                            }else
                                AccountList[0].Asset_Status__c=AccountList[0].Asset_Status__c+','+ErrorMessage;
                        }// End of AccountList else
                        
                        if(ErrorMessage.contains('Error In Lock')){
                            AccountList[0].Collection_Status__c='Error In Account Lock';
                        }
                        else{
                            AccountList[0].Collection_Status__c='Error In Account Unlock';
                        }      
                        system.debug('AccountList[0].Asset_Status__c******'+AccountList[0].Asset_Status__c);
                        
                        system.debug('AccountList******'+AccountList);
                        
                        // Update Account
                        update AccountList;
                    }//End of AccountList
                }//End of else
            }
        }
        catch(Exception ex){
            System.debug('Exception Found =================='+ex.getMessage());
            System.debug('Exception Found =================='+ex.getLineNumber());
            System.debug('Exception Found =================='+ex.getcause());
            
            string ErrorMsgException = 'Cause : '+ ex.getCause() +'\nError Line Number : '+ ex.getLineNumber() +'\nMessage : '+ ex.getMessage() + '\nStackTrace : '+ ex.getStackTraceString() +'\nException Type : '+ ex.getTypeName();
            
                       
    }// End of Catch
        
    }// End of SPAAPICall method
    
    // Method called by process builder once Account get Approved
    @InvocableMethod(label='Callout To Lock Asset' description='Make Callout To Unlock All Asset related to Account')
    
    public static void CollectionLockRequest(List<Id> AccountId){
        PublishPlatformEventForAsset(AccountId[0],'Lock');
        system.debug('PublishPlatformEventForAsset********');
     }//End of CollectionLockRequest method
    
    /* Method to publish platform event for each Asset to be locked
       This method is calling from process builder "Send Request to Lock Account",
       button "Lock Account"    
    */
    
    
    WebService static void PublishPlatformEventForAsset(Id AccountId,String RequestType){
     
     List<Asset> AssetList      =new List<Asset>();
     Set<Id> AssetId            =new Set<Id>();       
        List<Asset> AssetToBeProccessed=new List<Asset>();  
     List<Integration_Event__e> IntegrationEventList  = new List<Integration_Event__e>(); 
     String Event_Type          = Label.Platform_Event_Type;
     String Payload_Format      = Label.Platform_Event_Payload_Format;
     String CollectionAction    = Label.Collection_Request_to_SPA;  
        String CollectionUnlockAction = Label.Collection_Unlock_Request_to_SPA;
     
     // Query all Active Assets
        AssetList=[SELECT Account.Name,Opportunity__c,Opportunity__r.Type,Contract__c,Opportunity__r.StageName,Latest_Opportunity__r.StageName,Contract__r.SBQQ__Quote__r.Rubiks_Quote__c,Id,Name,AccountId,Acct_Prefix__c,Munchkin_ID__c,Provisioning_Type__c,Contract_End_Date__c,Asset_Type__c,Status,Collections_Analyst_Email__c,account.Credit_Collections_Analyst__r.email FROM Asset WHERE (Status='Active' OR Status='Locked') AND Munchkin_ID__c!=null AND AccountId=:AccountId order by createdDate ];   
     
     if(!AssetList.isEmpty()){        
        // If Request is for lock then update churn type='Collection Lock'  
        for(Asset ass:AssetList){
            if(RequestType=='Lock'){
                if(ass.Status=='Active'){
                    ass.Churn_Type__c='Collection Lock';
                    ass.Collections_Analyst_Email__c   = ass.account.Credit_Collections_Analyst__r.email;
                    AssetToBeProccessed.add(ass);
                }//End of If
            }//End of If
            // If Request is for Unlock then update churn type='Collection Lock'
            else if(RequestType=='Unlock'){
                if(ass.Status=='Locked'){
                    ass.Churn_Type__c='Collection Unlock';
                    ass.Collections_Analyst_Email__c   = ass.account.Credit_Collections_Analyst__r.email;
                    AssetToBeProccessed.add(ass);
                }//End of If
            }//End of else
        }//End of For
            
            if(!AssetToBeProccessed.isEmpty()){ 
                for(Asset asst:AssetToBeProccessed){
                    system.debug('ass@@@@'+asst);
                    // Create Integration Event per Asset
                    
                    Integration_Event__e IntegrationEvent= new Integration_Event__e();
                    IntegrationEvent.Type__c            = Event_Type;
                    IntegrationEvent.Payload_Format__c  = Payload_Format;
                    IntegrationEvent.sObjectType__c     = 'Asset'; 
                    IntegrationEvent.Payload__c         = JSON.serialize(asst);
                    IntegrationEvent.Account_Id__c      = asst.AccountId;
                    if(asst.Churn_Type__c=='Collection Lock')
                    {
                     IntegrationEvent.Action__c          = CollectionAction;
                    }
                    else
                    {
                     IntegrationEvent.Action__c          = CollectionUnlockAction;
                    }
                    //Add Platform Event record in List 
                    IntegrationEventList.add(IntegrationEvent); 
                }//End of If
            }//End of If
            system.debug('IntegrationEventListIntegrationEventList'+IntegrationEventList);
            
            //update AssetToBeProccessed;
            update AssetToBeProccessed;
            
            if(!IntegrationEventList.isEmpty()){             
                // Publish Integration Event per Asset
                List<Database.SaveResult> resultsOfIntegrationEvent = EventBus.publish(IntegrationEventList);
                system.debug('############## resultsOfIntegrationEvent '+ resultsOfIntegrationEvent );
                if(!resultsOfIntegrationEvent .isEmpty()){
                    // Inspect publishing result for each event
                    for(Database.SaveResult sr : resultsOfIntegrationEvent){
                        if (sr.isSuccess()) {
                            System.debug('Successfully published event.');
                            LogPlatformEvent.createIntegrationEventLog(IntegrationEventList);
                        }//End of If 
                        else {
                            for(Database.Error err : sr.getErrors()) {
                                System.debug('Error returned: ' +err.getStatusCode() +' - ' +err.getMessage());
                            }//End of For
                        }//End of else
                    }//End of For
                }//End of resultsOfIntegrationEvent isEmpty() If            
            }//End of If
        }//End of AssetList if
    }//End of PublishPlatformEventForAsset method   
}//End of Class