/* ***********************************************************************************************
Company Name  :Jade Global Inc.
Created Date  :10th February 2018
Description : API Call to Intacct

* *********************************************************************************************** */
public class Intacct_API  implements dynamicMethodHandlerInterface{
   public static string payloadFormat  =  'JSON';
     
    //Intacct Details
    public static String Payload_Format                 = Label.Platform_Event_Response_Payload_Format;
    public static String Intacct_Event_Response         = Label.Intacct_Event_Response;
    public static String Event_Action_Response          = Label.Response_Platform_Event_Action;
    public static String PSE_Project                    = 'pse__Proj__c'; 
    public Static string INTACCT_ENDPOINT               = Label.Intacct_endpoint;

    /***************************************************************
    * Method name   :dynamicMethodHandler
    * Return type   :void
    * Purpose       :Method is created to handle the dynamic method calling from Platform event trigger.
                       
    *****************************************************************/
    
    Public static void dynamicMethodHandler(List<Integration_Event__e> newList){
         System.debug('Inside Intacct_API Method class');
         Create_Project_in_Intacct(newList);
    }//End of method dynamicMethodHandler
    
    /***************************************************************
    * Method name   :Create_Project_in_Intacct
    * Return type   :void
    * Purpose       :Method is used for,
                     1.Getting platform event as input
                     2.Generate XML for Insert/Update call out to Intacct
                     3.Calling future method for actual call out
                     4.Creating Integration_Event_Log__c  record with XML body
    *****************************************************************/
    // For Testing purpose we have commented the /*list<Integration_Event__e> platformEventList */ as we are not able to query on the Platform Event after, testing will uncomment this line and will remove the - list<Integration_Event_Log__c> platformEventList 
    public static void Create_Project_in_Intacct(list<Integration_Event__e> platformEventList /* list<Integration_Event_Log__c> platformEventList*/){
    
        list<IntacctAPIRequest__mdt> IntacctAPIRequest=[Select Action_Match__c,API_Request_Template__c,API_Request__c,Title__c,Type_Match__c,API_Version__c from IntacctAPIRequest__mdt];
        system.debug('IntacctAPIRequest=='+IntacctAPIRequest);
        
        //Iterate platform event List - for testing purpose we are iterating on the Integration_Event_Log__c file as we are testing this using the developer console custom script after testing will remove
        
         for(Integration_Event__e IntegrationEvent : platformEventList){ 
        /*for(Integration_Event_Log__c IntegrationEvent : platformEventList){ */ 
            //List of sObject type
            List<sObject>  sobjectList = new List<sObject>();
             
             Map<String,String> HashMap = Generate_XML.ReplaceMap(IntegrationEvent.Payload__c);
             String recordId = '';
             If(HashMap.containsKey('Id')){
                 recordId = HashMap.get('Id');
             }
            try{
                // If payload type is JSON 
                if(IntegrationEvent.Payload_Format__c == payloadFormat){
                  
                    //Iterate on IntacctAPIRequest CustomMetadata Object
                    for(IntacctAPIRequest__mdt APIRequest : IntacctAPIRequest){
                        System.debug('APIRequest Metadata record=='+APIRequest);
                        //Check condition before creating XML and callout 
                        system.debug('IntegrationEvent.Action__c==='+IntegrationEvent.Action__c);
                        system.debug('IntegrationEvent.Type__c====='+IntegrationEvent.Type__c);
                        if(APIRequest.Action_Match__c == IntegrationEvent.Action__c && APIRequest.Type_Match__c== IntegrationEvent.Type__c){
                               system.debug('Action and Type Matched');
                            //Prepare the xml file
                            String XMLBody = Generate_XML.xmlBuild(APIRequest.API_Request_Template__c,IntegrationEvent.Payload__c,APIRequest.API_Version__c);    
                            XMLBody = XMLBody.Replace('#Today#',date.today().format());
                            system.debug('############ XMLBody'+XMLBody);
                
                             if(!Test.isRunningTest()){
                                //send callout to intacct
                                IntacctAPICall(XMLBody,APIRequest.Action_Match__c,APIRequest.Title__c,IntegrationEvent.Payload__c,IntegrationEvent.sObjectType__c);   
                            }      
                            //Store Request details in Integration Event Log Object
                            LogPlatformEvent.createIntacctRequestLog(XMLBody,APIRequest.Action_Match__c,IntegrationEvent.sObjectType__c,'Intacct XML Raw Data Request',recordId);
                    
                        }//End of If 
                    }//End of APIRequest For
                    
                }// End of If check    
            }catch(Exception ex){
                  string ErrorMsgException = 'Cause : '+ ex.getCause() + 
                                                      '\nError Line Number : '+ ex.getLineNumber() + 
                                                      '\nMessage : '+ ex.getMessage() + 
                                                      '\nStackTrace : '+ ex.getStackTraceString() + 
                                                      '\nException Type : '+ ex.getTypeName();
                LogPlatformEvent.createErrorLog( ErrorMsgException, IntegrationEvent.sObjectType__c, IntegrationEvent.Action__c, IntegrationEvent.Payload__c, IntegrationEvent.Type__c, recordId, null);
            }
        }//End of Integration Event For
    }//End of Create_Project_in_Intacct method
    
    
     /***************************************************************
    * Method name   :IntacctAPICall
    * Return type   :void
    * Purpose       :Method is used for,
                     1.Doing callout to Intacct
                     2.Creating Integration_Event_Log__c  record from response
                     3.Creating Integration_Event__e from response either update salesfore or next callout
    *****************************************************************/
    @future(callout=true)
    public static void IntacctAPICall(string XMLBody,String RequestActionType,String RequestTitle,String ReqPayload,String sObjectcType){
        //code to Get Project Id from XML BOdy
        Map<String,String> HashMap = Generate_XML.ReplaceMap(ReqPayload);
        Id recordId;
        If(HashMap.containsKey('Id')){
            recordId = HashMap.get('Id');
        }
        system.debug('Object Id=='+recordId);
        
        //callout to intacct
        HTTPRequest req = new HttpRequest();
        req.setTimeout(120000);
        req.setBody(XMLBody);
        system.debug('XML Body  =================='+XMLBody);
                        
        // Set endpoint
        req.setEndpoint(INTACCT_ENDPOINT);
                        
        // Set method to POST
        req.setMethod('POST');
        req.setHeader('Content-Type', 'text/xml');
        req.setHeader('Authorization', 'OAuth '  + UserInfo.getSessionId());
        
        HTTP http = new HTTP();
        
        // Prepare response/request
        HTTPResponse hTTPRes = http.send(req);
        system.debug('Http Response =================='+hTTPRes);
            
        //Store the status code retured from intacct 
        integer status_code = hTTPRes.getStatusCode(); 
        
        system.debug('Get Body  =================='+hTTPRes.getBody()); 
        
        //TO check reponse Status
        String respnseXMLString= hTTPRes.getBody();

        XPath xp        = new XPath(respnseXMLString);
        String ResponseResult  =  xp.getText(Label.Intacct_Response_Status_XPATH);
        system.debug('ResponseResult==='+ResponseResult);
        system.debug('Label==='+Label.Intacct_Response_Status_XPATH);
        
        SF_Utility.isCalloutExecuted =true;
        if(status_code == 200 && ResponseResult == 'Success'){
             

            //Log Success record in Integration Event Log object
            LogPlatformEvent.createSuccessErrorLog(respnseXMLString,'Success',RequestActionType,sObjectcType,'Intacct Event Response',recordId);
            
            //get the response body
            // get Matching IntacctAPIRsponse  record
            List<Integration_Event__e> IntegrationEventList   = new List<Integration_Event__e>();
            list<IntacctAPIResponse__mdt> IntacctAPIRsponse=[Select Action_Match__c,API_Response_Template__c,Title__c,Type_Match__c,sObjectType__c,API_Values__c,Dispatcher_Action__c from IntacctAPIResponse__mdt Where Action_Match__c = :RequestActionType AND Title__c = :RequestTitle];
            IF(!IntacctAPIRsponse.isEmpty()){
            Map<String,String> MapOfAPIValues = new Map<String,String>();
            for(String APIValue :IntacctAPIRsponse[0].API_Values__c.split(',')){
                
                //Get The XPATH Expression from API Value
                String[] Str = APIValue.split(':');
                //Remove Unwanted texts
                String XPathExp  = Str[1].remove('/text()"}');
                XPathExp         = XPathExp.remove('"');
                system.debug('XPathExp==='+XPathExp);
                //Get Value using XPATH expression
               String ExpResult = xp.getText(XPathExp);
                
                MapOfAPIValues.put(Str[0],ExpResult);
            }
               system.debug('MapOfAPIValues==='+MapOfAPIValues);
                String ResponseTemplate = IntacctAPIRsponse[0].API_Response_Template__c;
                If(!MapOfAPIValues.isEmpty()){
                    for(String APIValue :MapOfAPIValues.keySet()){
                        String TextToReplace = APIValue.remove('\"');
                        TextToReplace =  TextToReplace.remove('{');
                        TextToReplace = '"#'+TextToReplace+'#"';
                        system.debug('removed string=='+TextToReplace);
                        ResponseTemplate = ResponseTemplate.replace(TextToReplace,'"'+MapOfAPIValues.get(APIValue)+'"');
                    }
            }
                system.debug('FIRST ResponseTemplate=='+ResponseTemplate);
                system.debug('FIRST ReqPayload=='+ReqPayload);
           
            ResponseTemplate =  ResponseTemplate.remove('{');
            ResponseTemplate =  ResponseTemplate.remove('}');    
            ResponseTemplate =  '{"Id":"'+recordId+'",'+ResponseTemplate+'}'; 
          
            system.debug('Final ResponseTemplate=='+ResponseTemplate);
            Integration_Event__e IntegrationEventResponse     = new Integration_Event__e();
            IntegrationEventResponse.Type__c                  = IntacctAPIRsponse[0].Type_Match__c;
            IntegrationEventResponse.Payload_Format__c        = 'JSON'; 
            IntegrationEventResponse.Action__c                = IntacctAPIRsponse[0].Dispatcher_Action__c;  
            IntegrationEventResponse.sObjectType__c           = IntacctAPIRsponse[0].sObjectType__c; 
            IntegrationEventResponse.Payload__c               = ResponseTemplate;
            IntegrationEventList.add(IntegrationEventResponse);
          }
         system.debug('IntegrationEventList==='+IntegrationEventList);
         If(!IntegrationEventList.isEmpty()){
           List<Database.SaveResult> resultsOfIntegrationEventResponse = EventBus.publish(IntegrationEventList);
           System.debug('############## resultsOfIntegrationEventResponse'+ resultsOfIntegrationEventResponse );
             if(!resultsOfIntegrationEventResponse .isEmpty()){
                // Inspect publishing result for each event
                for(Database.SaveResult sr : resultsOfIntegrationEventResponse){
                    if (sr.isSuccess()) {
                        System.debug('Successfully published event.');
                        LogPlatformEvent.createIntegrationEventLog(IntegrationEventList);
                    }//End of If 
                    else {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('Error returned: ' +err.getStatusCode() +' - ' +err.getMessage());
                        }//End of For
                    }//End of else
                }
            }//End of resultsOfIntegrationEvent isEmpty() If
          }
        }//End of StatusCode If
        else{
            //Log Error record in Integration Event Log object      
            LogPlatformEvent.createSuccessErrorLog(respnseXMLString,'Error',RequestActionType,sObjectcType,'Intacct Event Response',recordId);
        }
    }//End of IntacctAPICall
    
}//End of Class