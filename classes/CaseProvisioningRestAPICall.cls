/* ************************************************************************************************************
*  Crated By: Priyanka Shende on 27th June 2017, Jade global Inc.
*  Purpose  : External System hit the Salesforce URL and update the Provisioning Case
************************************************************************************************************* */
/* ************************************************************************************************************
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
    EndPoint         -> https://marketo.my.salesforce.com/services/apexrest/CaseProvision
    Set Header as below :
    Authorization    -> Bearer <Access Token>
    Content-Type     -> application/json 
    and body as follow:
    Sample Success Body with message
    {"Provision" : 
          {
            "Id":"5004B000004Ekek",
            "Status":"WARNING",
            "Message":"MLM and SFDC Data is correct please proceed with this Case"
          }
    }
    
    
    Sample Error Body
     {"Provision" : 
          {
            "Id":"5004B000004EiXQ",
            "Status":"Error",
            "Message":"SFDC Data is not correct please check all parameters sent to SPA"
          }
    }
    
    Sample Success Body with Message Blank
    {"Provision" : 
          {
            "Id":"5004B000004EhGi",
            "Status":"Completed",
            "Message":""
          }
    }
************************************************************************************************************* */
@RestResource(urlMapping='/CaseProvision/*')
global with sharing class CaseProvisioningRestAPICall{
    public static map<Id,String> mapIdWithProvisionStatus       = new map<Id,String>(); 
    public static string Case_Status_Closed                     = Label.Case_Status_Closed;
    Public Static string PROVISION_STATUS_SUCCESS               ='Success';
    Public Static string PROVISION_STATUS_ERROR                 ='Error';
    Public Static string PROVISION_STATUS_COMPLETED             ='Completed';
    public static string PROVISION_STATUS_SUCCESS_MESSAGE       ='Case Successfully Updated in Salesforce';
    public static string PROVISION_STATUS_COMPLETED_MESSAGE     ='This case is already processed in Salesforce as the provision status of the case is Completed';
    public static string PROVISION_STATUS_ERROR_MESSAGE         ='Please verify the Parameters sent to salesforce like Id';
    public static string CASE_STATUS_CLOSED_MESSAGE             ='This case Status is already Closed';
    Public static datetime NOW                                  = system.now();
    @HttpGet(urlMapping='/sget')
    global static String ProvisionCase(){
        RestRequest req = RestContext.request;
        system.debug('req  #############'+req );
        RestResponse resp = RestContext.response;
        ResponseWrapper response = new ResponseWrapper();
        String paramval = req.params.get('CaseId');
        String paramval2= req.params.get('ProvisioningStatus');
        response.status ='Success';
        response.message = 'hello REST API '+paramval + paramval2;
        return JSON.serialize(response);
    }//End of HttpGet Method

  //Use URL- /services/apexrest/CaseProvision/
  
   @HttpPost
    global static String updateProvisionCase(RequestWrapper Provision){
        //declaration of the updateRecord message this we are sending to SPA System in response
        string updateRecord;
        //declaration of the message string this message we are sending to SPA System in response
        string message;
        try{
                RestRequest req = RestContext.request;
                RestResponse resp = RestContext.response;
                system.debug('ProvisioningStatus = '+Provision.Status);
                system.debug('CaseId ############ = '+Provision.Id);
                String CaseId= Provision.Id; 
                String ProvisionStatus=Provision.Status;
                String ProvisionMessage;
                if(CaseId!=null){
                   Case ProCase=[SELECT id,Provision_Status__c,Status,SPA_Message__c FROM CASE WHERE ID=:CaseId]; 
                   if(ProCase!=null){
                      if(Provision.Status!=null && ProCase.Provision_Status__c!=PROVISION_STATUS_COMPLETED && ProCase.Status!=Case_Status_Closed){ 
                           system.debug('############################## Now'+Now);
                           if(ProCase.SPA_Message__c==null && Provision.Message!=null){
                               ProvisionMessage= Provision.Message + ' ' + Now +'\n';
                           }//End of If
                           else if(Provision.Message!=null){
                               ProvisionMessage= ProCase.SPA_Message__c + '\n'+ Provision.Message+ ' '+ Now + '\n';
                           }//End of Else..If
                           ProCase.Provision_Status__c     = ProvisionStatus; 
                           ProCase.SPA_Message__c          = ProvisionMessage;
                          
                           //Provisioin Case Status Closed Won
                           /* if(ProvisionStatus == PROVISION_STATUS_COMPLETED){
                                ProCase.Status              = Case_Status_Closed;
                            } */
                            
                            //Assign the SAP System Message to salesforce field Message Format = Message + Timestamp
                            ProCase.SPA_Message__c          = ProvisionMessage;
                            
                            //update the record in salesforce with SPA System Values
                            update ProCase;
                            
                            updateRecord =PROVISION_STATUS_SUCCESS;
                      }//End of If
                      else if(ProCase.Provision_Status__c==PROVISION_STATUS_COMPLETED){
                           updateRecord                     = PROVISION_STATUS_COMPLETED;
                      }//End of Else..If
                      else if(ProCase.Status==Case_Status_Closed){
                           updateRecord                     = CASE_STATUS_CLOSED_MESSAGE;
                      }//End of Else..If
                  }
                   
                }
        }
        catch(Exception e){
               System.debug('The following exception has occurred: ' + e.getMessage());
               updateRecord=PROVISION_STATUS_ERROR;
        }
        
        if(updateRecord == PROVISION_STATUS_SUCCESS){
            message = PROVISION_STATUS_SUCCESS_MESSAGE;
        }//End of If
        else if(updateRecord == PROVISION_STATUS_COMPLETED){
            message = PROVISION_STATUS_COMPLETED_MESSAGE;
        }//End of Else..If
        else if(updateRecord == CASE_STATUS_CLOSED_MESSAGE){
            message = CASE_STATUS_CLOSED_MESSAGE;
        }//End of Else..If
        else{
           message =PROVISION_STATUS_ERROR_MESSAGE; 
        }//End of Else
        
        ResponseWrapper response=new ResponseWrapper(); 
        response.status=updateRecord;
        response.message=message;
        
        //Response to the SPA System
        return JSON.serialize(response);
    }//End of Update Provisioning Case - HttpPost Method
       
    global class ResponseWrapper{
        public String status;
        public String message;

        //Response Wrapper Constructor 
        public ResponseWrapper(){}
        
    }//End of the ResponseWrapper Class
    
    global class RequestWrapper{
        public String Status;
        public String Id;
        public String Message;
        //Request Wrapper Constructor 
        public RequestWrapper(){}
    }//End of RequestWrapper Class

    
}