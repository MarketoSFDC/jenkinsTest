global class CustomerCommunicationBatch implements Database.Batchable<sObject> {
    
    global Set<Id> ccaId;
    global Boolean isWorkFlowNeeded;
    
    global CustomerCommunicationBatch (Set<Id> ccAIdss,Boolean isWFRNeeded){
        ccaId = ccAIdss;
        isWorkFlowNeeded = isWFRNeeded;
    }
    global Database.QueryLocator start(Database.BatchableContext BC) { 
       String query = 'SELECT id,' + Label.MassEmailToContacts + ',IsWorkflow__c,TSE_Email__c,TSE__c,TSE__r.EMail, TSE__r.Name,Customer_Communication__r.Email_Behalf_Of_Tse__c, Email_Sent__c,Account__c,Entitlement__c,Case_Creation__c,Customer_Communication__r.Create_Cases__c,Customer_Communication__r.Description__c,Customer_Communication__r.From_Address__c,Customer_Communication__r.Subject__c,Customer_Communication__r.From_Address_Name__c,Customer_Communication__r.Send_Email__c FROM Customer_Communication_Action__c WHERE Id IN: ccaId';
       System.debug('&&&&& '+query  + Database.getQueryLocator(query));
       return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Customer_Communication_Action__c> ccAList) {
        try{          
            List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
            List<Case> caseList = new List<Case>();
            List<Customer_Communication_Action__c> ccAListToUpdate = new List<Customer_Communication_Action__c>();
            map<string,id> mapEmailtoOwdId = new map<string,id>();
            for(OrgWideEmailAddress owd : [select id, Address from OrgWideEmailAddress]){
                mapEmailtoOwdId.put(owd.Address,owd.id);
            }       
            for(Customer_Communication_Action__c ccA : ccAList){
                if(ccA.Customer_Communication__r.Create_Cases__c != null){
                    case cs = new case (Subject = ccA.Customer_Communication__r.Subject__c, Description = ccA.Customer_Communication__r.Description__c.replaceAll('<[^>]+>',' '), ContactId = ccA.Contact__c, Email_List__c = '', priority = 'P3', Origin = 'Internal', status = 'New',AccountId = ccA.Account__c,EntitlementId = ccA.Entitlement__c);
                    cs.Recordtypeid = (ccA.Customer_Communication__r.Create_Cases__c == 'Support Case') ? Label.SupportCaseRecTypeId : Label.ProActiveCaseRecTypeId;
                    ccA.Case_Creation__c = true;
                    caseList.add(cs);                                        
                }
                if(ccA.Customer_Communication__r.Send_Email__c){                
                    ccA.Email_Sent__c = true;
                    if(isWorkFlowNeeded) ccA.IsWorkflow__c = true;                                        
                    else{
                        List<id> ccTo = new List<id>();   
                        if(label.enableCCForTest != 'No') ccTo.add(label.enableCCForTest);
                                           
                        for(Integer i=1; i<= 20;i++){
                            string fieldName = '';                                
                            fieldName = 'Contact_'+i+'__c';
                            String relationShipName = 'Contact_'+i+'__r';
                            Contact temp = (Contact)ccA.getSobject(relationShipName);                                                               
                            if(ccA.get(fieldName) != null && !temp.IsEmailBounced){
                                id conId = (id)ccA.get(fieldName);
                                ccTo.add(conId);
                            }else{
                                break;
                            } 
                              
                        }
                        
                        Contact temp = (Contact)ccA.getSobject('Contact__r');
                        if(temp != null && temp.IsEmailBounced == false){
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setCharset('UTF-8');                                                   
                            if(ccA.Customer_Communication__r.From_Address__c!= null && ccA.TSE__c == null){                                                 
                                if(mapEmailtoOwdId.containskey(ccA.Customer_Communication__r.From_Address__c)){                                 
                                    mail.setOrgWideEmailAddressId(mapEmailtoOwdId.get(ccA.Customer_Communication__r.From_Address__c));
                                }else if(ccA.Customer_Communication__r.From_Address__c != null){
                                    if(ccA.Customer_Communication__r.From_Address_Name__c != null) mail.setSenderDisplayName(ccA.Customer_Communication__r.From_Address_Name__c);
                                    mail.setReplyTo(ccA.Customer_Communication__r.From_Address__c);
                                }                        
                            }
                            
                            if(ccA.Customer_Communication__r.Email_Behalf_Of_Tse__c == true && ccA.TSE__c != null ) {
                                mail.setReplyTo(ccA.TSE__r.Email);
                                mail.setSenderDisplayName(ccA.TSE__r.Name);
                            }else if(ccA.Customer_Communication__r.From_Address__c == null){
                                mail.setOrgWideEmailAddressId('0D250000000Kz9OCAS');
                            }                        
                            mail.setTargetObjectId(ccA.Contact__c);
                            mail.setCcAddresses(ccTo);                    
                            mail.setHtmlBody('<html><body><center><table align="center"  cellspacing="0" cellpadding="0" width="600" style="background-color:#ffffff;width:600px;margin:0 auto;"> <tr><td colspan="2" height="70px" style="height:70px;text-align:right;vertical-align:middle;"> <img border="0" style="float:right;" src="http://surveygizmolibrary.s3.amazonaws.com/library/203494/Marketo_Support_XtraSmall.jpg" alt="Marketo Support XtraSMall Logo"/> </td></tr><tr valign="top"><td colspan="2" style="background-color:#6666CC;height:5px;"></td> </tr><tr valign="top"><td colspan="2" style="padding-top: 25px;padding-bottom: 25px;">'+ccA.Customer_Communication__r.Description__c+'</td></tr><tr valign="top"><td colspan="2" style="background-color:#6666CC;height:5px;"></td> </tr><tr valign="top"><td colspan="2"></td></tr><tr><td height="70px" style="height:70px;text-align:left;vertical-align:top;"> <img width="90%" border="0" style="float:left;" src="https://marketo--c.na32.content.force.com/servlet/servlet.ImageServer?id=01538000001pCFy&oid=00D500000006sHb&lastMod=1457436143000" alt="Marketo Support XtraSMall Logo"/> </td><td height="70px" style="height:70px;text-align:right;vertical-align:top;"> <img width="90%" border="0" style="float:right;" src="https://marketo--c.na32.content.force.com/servlet/servlet.ImageServer?id=01538000002CYgu&oid=00D500000006sHb&lastMod=1462450983000" alt="Marketo Support XtraSMall Logo" /> </td><p style="display:none;"><img style="height:1px;width:1px;" src="http://marketo.force.com/community/CustomerCommunicationTracking?id='+ccA.Id+'" alt="."/></p> </tr></table></center></body></html>');
                            mail.setSubject(ccA.Customer_Communication__r.Subject__c);
                            mail.setSaveAsActivity(false);
                            mails.add(mail);
                        }
                        
                    }                
                }
                ccAListToUpdate.add(ccA);
            }
            if(!mails.isEmpty())  Messaging.sendEmail(mails);   
            if(!caseList.isEmpty()) insert caseList;
            if(!ccAListToUpdate.isEmpty()) update ccAListToUpdate;
        
        }
        catch(Exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}  
    }
                
    global void finish(Database.BatchableContext BC){
        
    }
}