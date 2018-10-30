/*********************************************************************************************************
Created By    : Jade Global Inc
Created Date  : 19th May 2018
Purpose       : #Send Account for suspension approval
                #Send Email after Collection Status changed to Send 10 day notice,Account Locked

LastModifiedBy: Priyanka Shende, Jade Global Inc On 24th May 2018
Purpose       : Added "Credit & Collections Analyst" in CC

LastModifiedBy: Snehal, Jade Global Inc On 6th June 2018
Purpose       : Added "provisioning@marketo.com" in CC.
                Added method sendEmailOnError() and code in catch to send email notificetion once we got error on sending Email after Account Locked and send 10 Days
                
LastModifiedBy: Priyanka Shende, Jade Global Inc on 1st August 2018
Purpose       : Handle Primary Contact -> Email Null Scenario - If Primary Contact -> Email = Null then sending Plain Text

LastModifiedBy: Priyanka Shende, Jade Global Inc on 22nd August 2018
Purpose       : APPS-21688 : Account Unlock Process		

**********************************************************************************************************/

Global class AssetDeprovisioningProcesses{
    Public static List<Account> AccList=new List<Account>();
    Public static string ErrorMsgException;
        //Method id created to submit Account for Suspension Approval
        webservice static void submitRecordForSuspensionApproval( Id AccountId){     
                       
            Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();

            req1.setObjectId(AccountId); 
                    
            // Submit the approval request
            req1.setProcessDefinitionNameOrId('Account_Suspension_Approval_Process');

            Approval.ProcessResult result = Approval.process(req1);
                    
            System.assert(result.isSuccess()); 
            
            // Unlock Account
            Approval.unLock(AccountId);         
               
             
        }//End of submitRecordForSuspensionApproval        
         
        //Method is invocked by process builders written to send Email notification for Account Lock and Send 10 days notice  
        @InvocableMethod(label='Notify About Account Locked' description='Notify About Account Locked')
        public static void validateIntLogForAccountLockAlert(List<Id> IntLogId){
            //Check request is submitted for Account[Send 10 days notice]
            if(IntLogId[0].getSobjectType()==Schema.Account.SObjectType){
                NotifyAboutAccountLocked(IntLogId);
            }//End of If
            else{
                //Request is submitted for Integration Event Log[Account Lock]
                list<Integration_Event_Log__c> IntLogObjList = [SELECT id,Account_Id__c FROM Integration_Event_Log__c WHERE Id IN :IntLogId AND Account_Id__c !=null  LIMIT 1];
                 
                if(!IntLogObjList.isEmpty()){
                    NotifyAboutAccountLocked(new list<id>{IntLogObjList[0].Account_Id__c});
                }//End of IF block
            }//End of Else
          
       }//End of method validateIntLogForAccountLockAlert
       
        //Method is invocked by process builders written to send Email notification for Account Lock and Send 10 days notice
        public static void NotifyAboutAccountLocked(List<Id> AccountId){
            
            List<Contact> ConList=new List<Contact>();
            List<String> sendTo = new List<String>();
            List<String> ccTo = new List<String>();
            
            
            Id AccId=AccountId[0];
            system.debug('AccountId[0]'+AccountId[0]);
            Messaging.SingleEmailMessage mail =new Messaging.SingleEmailMessage();
         

         try{ 
         
            //Query related Account - Added Account Unlock Process fields
            AccList=[Select Id,Name,Credit_Collections_Analyst__c,Credit_Collections_Analyst__r.Email,Accounting_Email__c,CAM_Owner__c,CAM_Owner__r.Email,Collection_Status__c,Secondary_E_mail__c  from Account where  ID =: AccId AND Credit_Collections_Analyst__c!=null AND Credit_Collections_Analyst__r.Email!=null AND Collection_Status__c IN('Account Locked','Send 10 days notice','Account Unlocked')];
                
            Credit_Collections_Analyst__c AnalystUser =new Credit_Collections_Analyst__c();
            
            if(!AccList.isEmpty()){ 
                //Check Account credit analyst is present in Credit_Collections_Analyst__c cutom setting 
                AnalystUser = Credit_Collections_Analyst__c.getValues(AccList[0].Credit_Collections_Analyst__c);
            }
            system.debug('AnalystUser'+'AnalystUser');
            
            if(!AccList.isEmpty() && AnalystUser!=null){
                
                //Query related Primary Contacts
                //Handle Primary Contact -> Email Null Scenario - If Primary Contact -> Email = Null then sending Plain Text
                ConList=[select id,AccountId, Email,CE_Primary_Marketo_User__c,Account.Name,Account.Account_Contact_Full_Name__c from Contact where AccountId =: AccId AND CE_Primary_Marketo_User__c = true AND Email!=null];
                system.debug('******ConList**********'+ConList);
                
                
                List<Messaging.SingleEmailMessage> mails = 
                new List<Messaging.SingleEmailMessage>();  
                
                //Set who the email is sent from
                mail.setSenderDisplayName(AccList[0].Credit_Collections_Analyst__r.Email);
                mail.setReplyTo(AccList[0].Credit_Collections_Analyst__r.Email);               
            
                
                if(!String.isBlank(AccList[0].Secondary_E_mail__c)){
                    if(AccList[0].Secondary_E_mail__c.contains(','))
                    {
                        sendTo=AccList[0].Secondary_E_mail__c.split(',');
                    }else if(AccList[0].Secondary_E_mail__c.contains(';')){
                        sendTo=AccList[0].Secondary_E_mail__c.split(';');
                    }
                    else
                        sendTo.add(AccList[0].Secondary_E_mail__c);
                        
                    system.debug('******sendTo**********'+sendTo);
                }//End of If   
                
                //Set ToAddresses
                if(AccList[0].Accounting_Email__c!=null){
                    sendTo.add(AccList[0].Accounting_Email__c);
                }//End of If
                  
                if(!ConList.IsEmpty()){
                    system.debug('########## ConList[0].Id'+ConList[0].Id);
                    system.debug('########## ConList[0].AccountId'+ConList[0].AccountId);
                    mail.setTargetObjectId(ConList[0].Id);
                    mail.setWhatId(ConList[0].AccountId);
                    for(Contact cont:ConList){
                        sendTo.add(cont.Email);                        
                    }                    
                }//End of if
               
                    
                
                
                system.debug('******sendTo**********'+sendTo);
                
                
                if(!sendTo.isEmpty())               
                mail.setToAddresses(sendTo);   
             
                //Set CcAddresses
                ccTo.add('sodell@marketo.com'); 
              
                /***********************************************************************************
                *LastModifiedBy: Snehal, Jade Global Inc On 6th June 2018
                *Purpose       : Added "provisioning@marketo.com" in CC
                ***********************************************************************************/
                
                if(AccList[0].Collection_Status__c == 'Account Locked'){
                    ccTo.add('provisioning@marketo.com');
                }
                //Added "Credit & Collections Analyst" in CC
                if(AccList[0].Credit_Collections_Analyst__c!=null && AccList[0].Credit_Collections_Analyst__r.Email!=null){
                    ccTo.add(AccList[0].Credit_Collections_Analyst__r.Email);
                }
                if(AccList[0].CAM_Owner__c!=null && AccList[0].CAM_Owner__r.Email!=null){
                    ccTo.add(AccList[0].CAM_Owner__r.Email); 
                }//End of if 
                mail.setCcAddresses(ccTo);                     
                    
                system.debug('******ccTo**********'+ccTo);
                
                List<EmailTemplate> AccLockedEmailTemp=new List<EmailTemplate>();
                AccLockedEmailTemp=[SELECT Body,HtmlValue,Id,IsActive,Name,Subject,DeveloperName FROM EmailTemplate where DeveloperName IN ('Provisioning_Notification_ForLock','Provisioning_Cust_Notify_forlock_notice','Provisioning_Notification_ForUnLock') AND IsActive=True];
                
                map<String,Id> MapOfEmailTemplate=new map<String,Id>();
                if(!AccLockedEmailTemp.isEmpty() && !AccList.isEmpty() ){
                    for(EmailTemplate emailTemp:AccLockedEmailTemp){
                        MapOfEmailTemplate.put(emailTemp.DeveloperName,emailTemp.Id);
                    }//End of for
                }//End of AccLockedEmailTemp If
                
                //Set EmailTemplate
                if(!AccLockedEmailTemp.isEmpty() )
                {
                    if(AccList[0].Collection_Status__c == 'Account Locked' && !ConList.IsEmpty() ){
                        mail.setTemplateId(MapOfEmailTemplate.get('Provisioning_Notification_ForLock'));
                    }//End of if
                    else if(AccList[0].Collection_Status__c == 'Account Locked' && ConList.IsEmpty() ){
                        String body=getEmailBodyAccLocked();
                        
                        mail.setPlainTextBody(body);
                        mail.setSubject('[Account Locked] - Marketo – Account Suspension – Immediate Attention Required');
                    
                    }
                    else if(AccList[0].Collection_Status__c == 'Account Unlocked' && !ConList.IsEmpty()){
                        mail.setTemplateId(MapOfEmailTemplate.get('Provisioning_Notification_ForUnLock'));
                    }//End of else
                    else if(AccList[0].Collection_Status__c == 'Account Unlocked' && ConList.IsEmpty() ){
                        String body=getEmailBodyAccUnLocked();
                
                        mail.setPlainTextBody(body);
                        mail.setSubject('[Account Unlocked] - Marketo – Account Suspension – Immediate Attention Required');
                    
                    }
                    else if(AccList[0].Collection_Status__c == 'Send 10 days notice' && !ConList.IsEmpty()){
                        mail.setTemplateId(MapOfEmailTemplate.get('Provisioning_Cust_Notify_forlock_notice'));
                    }//End of else
                    else if(AccList[0].Collection_Status__c == 'Send 10 days notice' && ConList.IsEmpty() ){
                        String body=getEmailBodySend10DaysNotice();
                
                        mail.setPlainTextBody(body);
                        mail.setSubject('Marketo – Past Due Account Balance and Potential Suspension.');
                    
                    }
                    
                    //system.debug('******mail.setTemplateId**********'+mail.setTemplateId());
                    
                }//End of AccLockedEmailTemp if
                   
                 
                mails.add(mail);
                system.debug('******mails**********'+mails);
               
                string mailInfo=string.valueOf(mail);
                //Send Email
                if( !sendTo.isEmpty() || !ccTo.isEmpty()){
                    Messaging.sendEmail(mails);
                    system.debug('******Email send**********');                    
                     
                     //Store Error log in Integration Event Log Object
                      LogPlatformEvent.createErrorLog(  AccList[0].Collection_Status__c+' email has been send successfully', 'Account', 'Send an email after ' + AccList[0].Collection_Status__c, mailInfo, 'Send Email Notification', AccList[0].Id, null);
                }//End of If
                
            }//End of AccList If
        }//End of try block
        catch(Exception ex){
            System.debug('Exception Found =================='+ex.getMessage());
            System.debug('Exception Found =================='+ex.getLineNumber());
            System.debug('Exception Found =================='+ex.getcause());
            
            ErrorMsgException = 'Cause : '+ ex.getCause() +'\n•    Error Line Number : '+ ex.getLineNumber() +'\n•    Message : '+ ex.getMessage() + '\n•    StackTrace : '+ ex.getStackTraceString() +'\n•    Exception Type : '+ ex.getTypeName();
            
            string mailInfo=string.valueOf(mail); 
            sendEmailOnError();
            
            //Store Error log in Integration Event Log Object
            LogPlatformEvent.createErrorLog( ErrorMsgException, 'Account', 'Send an email after ' + AccList[0].Collection_Status__c, mailInfo, 'Send Email Notification', AccList[0].Id, null);
            
        }//End of Catch block
        
     }//End of NotifyAboutAccountLocked method  
     
     public static string getEmailBodyAccLocked(){
        
        string Body=
        'Dear Customer,'+'\n\n'+'Your Marketo Account has been suspended due to a past due account balance.  While your account is  suspended, no campaigns or programs will be sent from your Marketo instance during the account suspension. Please do not contact Customer Support as the past due balance must be resolved with Client Financial Services.'+'\n\n'+'Wire payment is required for restoration of service and is to be directed to the following Marketo bank account:'+'\n\n\t'+'•    Bank: Silicon Valley Bank'+'\n\t'+'•    Address: 3003 Tasman Drive / Santa Clara, CA 95054'+'\n\t'+'•    Routing Number: 121140399'+'\n\t'+'•    Account Number: 3300513258'+'\n\n'+'Please note - payment is not considered received until Marketo confirms receipt in the designated account above.  Once confirmed, the account will be submitted for service restoration and will occur within 24 hours.'+'\n\n'+'To further assist you, please contact collections@marketo.com .'+'\n\n'+'Best regards,'+'\n'+'Collections Team'+'\n'+'collections@marketo.com,'+'\n'+'Marketo, Inc.';
        
        system.debug('Body******'+Body);
        return Body;
     
     }
     public static string getEmailBodyAccUnLocked(){
        
        string Body=
        'Dear Customer,'+'\n\n'+'Account service has been submitted for reinstatement as payment has been received by Marketo for your past due balance.  Please allow up to 48 business hours for account service to be reinstated.  If service is not restored within 48 hours, please contact your Customer Success Manager'+'\n\n'+'Please be aware your next invoice is due and payment is to be received at that time to avoid future account suspension.'+'\n\n'+'In the future, please contact your assigned Credit/Collection Analyst, collections@marketo.com .'+'\n\n'+'Best regards,'+'\n'+'Steven Odell'+'\n'+'Manager – Accounts Receivable'+'\n'+'Marketo, Inc.';
        
        system.debug('Body******'+Body);
        return Body;
     
     }
     
     public static string getEmailBodySend10DaysNotice(){
        
        string Body=
        'Dear Customer,'+'\n\n'+'As of today, your Marketo account is past due (Insert past due account balance) and is subject to suspension per our agreement.  If there is an issue preventing payment, please let us know so we may assist in resolution.'+'\n\n'+'To further assist you, please contact collections@marketo.com to discuss the account’s past due balance and how we may assist in resolution.'+'\n\n'+'If we do not hear from you and/or have not received payment, your account is subject to suspension on (10 days from date of this email).'+'\n\n'+'Thank you in advance for your prompt response and attention to this matter, it is greatly appreciated.'+'\n\n'+'Best regards,'+'\n'+'Collections Team'+'\n'+'collections@marketo.com,'+'\n'+'Marketo, Inc.';
        
        system.debug('Body******'+Body);
        return Body;
     
     }
     /***********************************************************************************
                *LastModifiedBy: Snehal, Jade Global Inc On 6th June 2018
                *Purpose       : Added method sendEmailOnError() and code in catch to send email  notificetion once we got error on sending Email after Account Locked and send 10 Days
     ***********************************************************************************/
   
      public static void sendEmailOnError(){
      
            Messaging.SingleEmailMessage Singlemail =new Messaging.SingleEmailMessage();            
            List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
            
            List<SendCollectionLockNotificationToUser__c> ListOfUsers = SendCollectionLockNotificationToUser__c.getall().values();
            
            List<String> EmailIdsOfUser=new List<String>();
            
            string body='While sending -'+AccList[0].Collection_Status__c+ ' email notification'+' follwing error has been occured, '+'\n\n•    Account Link: https://'+URL.getSalesforceBaseUrl().getHost()+'/'+AccList[0].Id+'\n•    AccountName: '+AccList[0].Name+'\n•    Error: '+ErrorMsgException+'\n\n'+'Best regards';
            
            for(SendCollectionLockNotificationToUser__c usr:ListOfUsers){
                EmailIdsOfUser.add(usr.Email_Id__c);
            }
            
            if(!EmailIdsOfUser.IsEmpty()){
                Singlemail.setToAddresses(EmailIdsOfUser); 
                Singlemail.setPlainTextBody(body);
                Singlemail.setSubject(AccList[0].Collection_Status__c+' email notification Error');
                mailList.add(Singlemail);
                Messaging.sendEmail(mailList);
            }
      
      }// End of sendEmailOnError() method

}//End of Class