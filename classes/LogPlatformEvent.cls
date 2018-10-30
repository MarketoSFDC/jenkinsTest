/* ***********************************************************************************************
Company Name  :Jade Global Inc.
Created Date  :10th February 2018
Description : Maintain the the platform event record as a log

Last Modified By : Priyanka Shende, on 13th April 2018
Description      : Populated value in Scheduled Date field(System.Now.addMinutes(20))

Last Modified By: Jade Global Inc On 19th May 2018
Updated for: Added as part of Collection Lock Requirement, added changes for Asset Object.

Last Modified By : Snehal Khot, on 6th June 2018
Description      : set Created_Date_5_Min__c after 15 minutes of CreatedDate

Last ModifiedBy : Priyanka Shende, Jade Global Inc. on 12th July 2018
Purpose         : Sometimes Intacct Record No not populating on Record so we have creating in progress Log - APPS-20979 
************************************************************************************************/

public class LogPlatformEvent {
    
    /***************************************************************
    * Method name   :createIntegrationEventLog
    * Return type   :void
    * Purpose       :Creating Integration_Event_Log__c record for sobject after publishing of platform event.
    *                 
    *****************************************************************/
    public static void createIntegrationEventLog(List<Integration_Event__e> IntegrationEvents){
        List<Integration_Event_Log__c>  IntegrationLogList           =  new List<Integration_Event_Log__c>();
        List<Integration_Event_Log__c>  InProgressIntegrationLogList =  new List<Integration_Event_Log__c>();
        
        For(Integration_Event__e IE :IntegrationEvents){
            Map<String,String> HashMap = Generate_XML.ReplaceMap(IE.Payload__c);
            
            Integration_Event_Log__c IntegraionObj    =   new Integration_Event_Log__c();
            If(HashMap.containsKey('Id')){
                IntegraionObj.Name                    =   HashMap.get('Id'); 
            }
            
            //Adding Record Name to Integration Log
            /*if(HashMap.containsKey('Name')){
                IntegraionObj.Record_Name__c          =   HashMap.get('Name');
            }*/
            IntegraionObj.Debug__c                    =   IE.Debug__c;
            IntegraionObj.Payload__c                  =   IE.Payload__c;
            IntegraionObj.Payload_Format__c           =   IE.Payload_Format__c;
            IntegraionObj.sObjectType__c              =   IE.sObjectType__c;
            IntegraionObj.Type__c                     =   IE.Type__c;
            IntegraionObj.Action__c                   =   IE.Action__c;
            IntegraionObj.Account_Id__c               =   IE.Account_Id__c;
            /***************************************************************
            *   Last Modified By : Snehal Khot, on 6th June 2018
            *   Description      : set Created_Date_5_Min__c after 15 minutes of CreatedDate
            ***************************************************************/
            if(IE.sObjectType__c=='Asset'){
                IntegraionObj.Created_Date_5_Min__c      =   system.now().addMinutes(15); 
            }
			// Last ModifiedBy : Priyanka Shende, Jade Global Inc. on 12th July 2018
            // Purpose         : Sometimes Intacct Record No not populating on Record so we have creating in progress Log - APPS-20979 
            if(IE.Action__c=='Update Project in Salesforce'){
                IntegraionObj.Scheduled_Date__c     = System.now().addMinutes(20);
                IntegraionObj.Integration_Status__c = 'In Progress';
            }
            IntegrationLogList.add(IntegraionObj);
            system.debug('############# IE.Action__c'+IE.Action__c);

        } 
        System.debug('IntegrationLogList==='+IntegrationLogList);
        if(!IntegrationLogList.isEmpty()){
            Insert IntegrationLogList;
        }
    }//End of method createIntegrationEventLog
    
    /***************************************************************
    * Method name   :createSuccessErrorLog
    * Return type   :void
    * Purpose       :Creating Integration_Event_Log__c record from Response from Intacct.
                     Getting called from Class:Intacct_API,Method :IntacctAPICall
    *                 
    *****************************************************************/
    public static void createSuccessErrorLog(String Payload,String ResponseType,String RequestActionType,String sObjectcType,String IntegrationEventType,Id ObjId){
         String ResponseResult ;
        Integration_Event_Log__c IntegraionObj    =   new Integration_Event_Log__c();
        IntegraionObj.Name                        =   ObjId;
        IntegraionObj.Payload__c                  =   Payload;
        IntegraionObj.sObjectType__c              =   sObjectcType;
        IntegraionObj.Type__c                     =   IntegrationEventType;
        IntegraionObj.Action__c                   =   RequestActionType;
        Map<String,String> SPAResponse            = new Map<String,String>();
		
		//Added as part of Collection Lock Requirement, added changes for Asset Object.
        if(sObjectcType=='Asset'){
            IntegraionObj.Payload_Format__c           =   'JSON';
        
        }
        else
            IntegraionObj.Payload_Format__c           =   'XML';
        
        
        If(ResponseType == 'Success'){
            IntegraionObj.Debug__c   = 'Success';
        }else If(ResponseType == 'Error'){
            if(sObjectcType!='Asset'){
            XPath xp                =  new XPath(Payload);
            ResponseResult   =  xp.getText('/response/operation/result/errormessage/error/description2');
            system.debug('ResponseResult =='+ResponseResult);
            IntegraionObj.Debug__c   =  ResponseResult;
            SF_Utility.UpdateRecordsFromIntacctResponse(IntegraionObj.Name,IntegraionObj.sObjectType__c,ResponseType ,ResponseResult);
            }
			/***********************************************************************************************
				Last Modified By: Jade Global Inc On 19th May 2018
				Updated for: Added as part of Collection Lock Requirement, added changes for Asset Object.
			***********************************************************************************************/
            
			else if (sObjectcType=='Asset'){
           
            if(Payload.contains('ChurnMessage')){
                SPAResponse=Generate_XML.ReplaceMap(Payload);
                ResponseResult=SPAResponse.get('ChurnMessage');
                IntegraionObj.Debug__c  = ResponseResult;
                system.debug('IntegraionObj.Debug__c =='+IntegraionObj.Debug__c);
            }else if(Payload!=null){
                ResponseResult=Payload;
                IntegraionObj.Debug__c  = Payload;
                system.debug('IntegraionObj.Debug__c =='+IntegraionObj.Debug__c);
            }
            SF_Utility.UpdateRecordsFromIntacctResponse(IntegraionObj.Name,IntegraionObj.sObjectType__c,ResponseType ,ResponseResult);
            
            }
            
            

        }
        Insert IntegraionObj;
        
    }//End of method createSuccessErrorLog
    
    /***************************************************************
    * Method name   :createErrorLog
    * Return type   :void
    * Purpose       :Creating Integration_Event_Log__c record if exception occur in apex.
                     Getting called from Class:Intacct_API and SF_Utility   
    *                 
    *****************************************************************/
    public static void createErrorLog(String str, String sObjectType, String action, String payload, String type, String recordId, String IntegrationStatus){
        Integration_Event_Log__c IntegraionObj    =   new Integration_Event_Log__c();
        IntegraionObj.Name                        =   recordId;
        IntegraionObj.Payload__c                  =   payload;
        IntegraionObj.sObjectType__c              =   sObjectType;
        IntegraionObj.Type__c                     =   type;
        IntegraionObj.Action__c                   =   action;
        IntegraionObj.Integration_Status__c       =   IntegrationStatus;
    
        /* *********************************************************************************************** 
    Last Modified By : Priyanka Shende, on 13th April 2018
    Description      : Populated value in Scheduled Date field(System.Now.addMinutes(20))
    * *********************************************************************************************** */
    if(IntegrationStatus!=null){
            IntegraionObj.Scheduled_Date__c       =   System.now().addMinutes(20);
        }
        IntegraionObj.Debug__c                    = str;
     if(sObjectType=='Asset'){
            IntegraionObj.Payload_Format__c           =   'JSON';
        
        }
        else
     IntegraionObj.Payload_Format__c           =   'XML';
        /*  IntegraionObj.Debug__c                    =   'Cause : '+ ex.getCause() + 
                                                      '\nError Line Number : '+ ex.getLineNumber() + 
                                                      '\nMessage : '+ ex.getMessage() + 
                                                      '\nStackTrace : '+ ex.getStackTraceString() + 
                                                      '\nException Type : '+ ex.getTypeName();*/
                                                      
        Insert IntegraionObj;
    }//End of method createErrorLog
    
    /***************************************************************
    * Method name   :createIntacctRequestLog
    * Return type   :void
    * Purpose       :Creating Integration_Event_Log__c record for XML request body for call out.
                     Getting called from Class:Intacct_API   
    *                 
    *****************************************************************/
     public static void createIntacctRequestLog(String Payload,String RequestActionType,String sObjectcType,String IntegrationEventType,Id ObjId){
        Integration_Event_Log__c IntegraionObj    =   new Integration_Event_Log__c();
        IntegraionObj.Name                        =   ObjId;
        IntegraionObj.Payload__c                  =   Payload;
        IntegraionObj.sObjectType__c              =   sObjectcType;
        IntegraionObj.Type__c                     =   IntegrationEventType;
        IntegraionObj.Action__c                   =   RequestActionType;
        if(sObjectcType=='Asset'){
            IntegraionObj.Payload_Format__c           =   'JSON';
        
        }
        else
        {
            IntegraionObj.Payload_Format__c           =   'XML';
            
        }
        
        
        //Adding Record Name to Integration Log
        /*Map<String,String> HashMap = Generate_XML.ReplaceMap(Payload);
        if(HashMap.containsKey('Name')){
            IntegraionObj.Record_Name__c          =   HashMap.get('Name');
        }*/
         
        Insert IntegraionObj;
         system.debug('IntegraionObj=='+IntegraionObj);
    }
    
}