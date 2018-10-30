/* *******************************************************************
* Crated By: Priyanka Shende on 22nd May 2017, Jade global Inc.
* Purpose  : For sending the SF Contact details to Intacct system

*Modified By: Sumit Bhatt, Grazitti Interactive
*Purpose: REF: #APPS-18580# Update Test Classes
*Tracking: One cn track the changes by searching ticket number in code 
********************************************************************* */
Global class SFContactToIntacct {
    //Intacct Details
    public Static String INTACCT_SENDER_ID              = Label.Intacct_senderid;
    public Static String INTACCT_SENDER_PASSWORD        = Label.Intacct_sender_password;
    public Static String INTACCT_SENDER_CONTROLID       = Label.Intacct_sender_controlid;
    public Static String INTACCT_AUTH_USERID            = Label.Intacct_auth_useid;
    public Static String INTACCT_AUTH_COMPANYID         = Label.Intacct_auth_companyid;
    public Static String INTACCT_AUTH_PASSWORD          = Label.Intacct_auth_password;
    public Static String INTACCT_FUNCTION_CONTROLID     = Label.Intacct_function_controlid;
    public Static string INTACCT_ENDPOINT               = Label.Intacct_endpoint;
    public Static String CLOSED_WON_OPPTY               = Label.OPPORTUNITY_STAGE_CLOSED_WON;
    public static Id OpportunityId;
    public static String STATUS_SF_ERROR_FLAGGED        = Label.ProvisionErrorStatus;
    public static String STATUS_ERROR                   = Label.Provisioning_Exception_Status;
    public static String STATUS_COMPLETED               = Label.Status_Completed;
    public static map<Id,String> mapIdWithIntacctStatus = new map<Id,String>(); 
    public static map<String,String> ConIdStatus        = new map<String,String>(); 
    public static Map<Id,Boolean> ContactWithJPYFlag    = new Map<Id,Boolean>();
    public static String JAPAN_IN_ENGLISH               = 'Japan';
    public static String JAPAN_IN_JAPNIES               = '日本';

    public static void getOpportunityIds(List<Opportunity> newlist, Map<Id,Opportunity> oldMap){
        List<Id> OppId=new List<Id>();
        for(Opportunity opp: newlist){
                       
            if((opp.StageName != oldMap.get(opp.Id).StageName  && opp.StageName == CLOSED_WON_OPPTY && opp.pricebook2Id == SteelBrickCPQPricebook__c.getOrgDefaults().ID__c && opp.Ghost__c != TRUE && opp.Migration__c != TRUE) || Test.isRunningTest()){
                OppId.add(opp.id);
            }//End of If
            
        }//End of For
		
        //APPS-18580
        // if(!OppId.isEmpty()){
        if(!OppId.isEmpty() && !System.isBatch() && !System.isFuture()){//modified it because of System.AsyncException:
		//APPS-18580
            sendContactDetailsToIntacct(OppId);
        }//End of If
        
    }//End of OpportunityIds
    
    @future(callout=true) 
    webservice static  void sendContactDetailsToIntacct(List <Id> OppId){
       
            Map<Id,List<contact>> oppIdAndContactList= new map<Id,List<contact>>();
            List<Contact> updateContactAfterSentToIntacct=new list<Contact>();
            List<Opportunity> UpdateOpporunityList=new List<Opportunity>();
            Map<Id,Opportunity> UpdateOpporunityMap= new map<Id,Opportunity>();
            List<Opportunity> ListOfOpptys=new List<Opportunity>();
            Set<Id> ErrorOpportunitites=new Set<Id>();
            Set<Id> UpdateOpporunitySet=new Set<Id>();
            set<Id> contactIds=new set<Id>(); 
            map<Id,Contact> contactMap= new map<Id,Contact>();
            map<Id,Contact> syncedcontactMap= new map<Id,Contact>();
            List<Contact> ContactList=new List<Contact>();
            //This map used to identify the current contact is JPY or Not(Contact, JPY Checkbox)
            
            
         try{   
            List<SBQQ__Quote__c> primaryQuoteList = [SELECT Id,Bill_To_Contact__c,Japan_Country_Checkbox__c,Ship_To_Contact__c,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.Id from SBQQ__Quote__c WHERE SBQQ__Opportunity2__c IN: OppId AND SBQQ__Primary__c=TRUE AND Bill_To_Contact__c!=null AND Ship_To_Contact__c!=null];
                        
            
            for(SBQQ__Quote__c primaryQuote: primaryQuoteList){
                contactIds.add(primaryQuote.Bill_To_Contact__c);
                contactIds.add(primaryQuote.Ship_To_Contact__c);
                if(primaryQuote.Japan_Country_Checkbox__c==true){
                    ContactWithJPYFlag.put(primaryQuote.Bill_To_Contact__c,primaryQuote.Japan_Country_Checkbox__c);ContactWithJPYFlag.put(primaryQuote.Ship_To_Contact__c,primaryQuote.Japan_Country_Checkbox__c);
                    }
            }//End of for
            
            
            for(Contact con:[SELECT id,Name,Account.Name,Account_Name_Local__c,Salutation,firstName,Contact_Synced_to_Intacct__c,lastName,HomePhone,phone,MobilePhone,OtherPhone,fax,Email,Account.SDR_Owner_Email_Address__c,Account.CAM_Email_Address__c,MailingCity,MailingCountry,MailingPostalCode,MailingStreet,MailingState,Intacct_Record_No__c FROM CONTACT WHERE ID In : contactIds]){
                
                if(con.Contact_Synced_to_Intacct__c==false){
                    contactMap.put(con.id,con);
                    ContactList.add(con);
                }
                else if(con.Contact_Synced_to_Intacct__c==true){               
                    syncedcontactMap.put(con.id,con);               
                }
                
            }//End of For
            
           
            if(!syncedcontactMap.isEmpty()){
                for(SBQQ__Quote__c primaryQuote: primaryQuoteList){
               
                 Opportunity OppInstance=new Opportunity() ;
                 if(primaryQuote.SBQQ__Opportunity2__c!=null){
                     if(UpdateOpporunityMap.containsKey(primaryQuote.SBQQ__Opportunity2__c)){
                        OppInstance=UpdateOpporunityMap.get(primaryQuote.SBQQ__Opportunity2__c);
                     }else 
                        OppInstance.Id=primaryQuote.SBQQ__Opportunity2__r.Id;
                
                     UpdateOpporunitySet.add(OppInstance.Id);
                     
                     if(syncedcontactMap.containsKey(primaryQuote.Bill_To_Contact__c)){     
                         OppInstance.Bill_to_Contact_Id__c=primaryQuote.Bill_To_Contact__c;
                     }
                     if(syncedcontactMap.containsKey(primaryQuote.Ship_To_Contact__c)){             
                        OppInstance.Ship_to_Contact_Id__c=primaryQuote.Ship_To_Contact__c;
                     
                     }
                     
                     if(OppInstance.Id!=null){
                        UpdateOpporunityMap.put(OppInstance.Id,OppInstance);
                     }
                     
                }
                }
            }
          if(!contactMap.isEmpty()){
            
            list<Contact> BillToShipToContact=new list<Contact>();
            set<Id> ProcessedConId=new set<Id>();
            for(SBQQ__Quote__c primaryQuote: primaryQuoteList){
                OpportunityId=primaryQuote.SBQQ__Opportunity2__c;
                Contact Bill_To_Contact= new Contact();
                Contact Ship_To_Contact= new Contact();
                if(contactMap.containsKey(primaryQuote.Bill_To_Contact__c) && !ProcessedConId.contains(primaryQuote.Bill_To_Contact__c)) {
                    BillToShipToContact.add(contactMap.get(primaryQuote.Bill_To_Contact__c));
                    ProcessedConId.add(primaryQuote.Bill_To_Contact__c);
                }
                if( contactMap.containsKey(primaryQuote.Ship_To_Contact__c) && !ProcessedConId.contains(primaryQuote.Ship_To_Contact__c)){
                    BillToShipToContact.add(contactMap.get(primaryQuote.Ship_To_Contact__c));
                    ProcessedConId.add(primaryQuote.Ship_To_Contact__c);
                 }
                   
               
                string XMLBody;
                XMLBody=getXML(BillToShipToContact);
               
                
                //call to intacct
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
                // Prepare response/request
                HTTPResponse hTTPRes;
                
                HTTP http = new HTTP();
                hTTPRes = http.send(req);
                system.debug('Http Response =================='+hTTPRes);
                
                                           
                //Store the status code retured from intacct 
                integer status_code = hTTPRes.getStatusCode(); 
                system.debug('Get Body  =================='+hTTPRes.getBody()); 
                                   
                                               
                Opportunity OppObject=new Opportunity();
                if(primaryQuote.SBQQ__Opportunity2__c!=null){
                    if(UpdateOpporunityMap.containsKey(primaryQuote.SBQQ__Opportunity2__c)){
                          OppObject=UpdateOpporunityMap.get(primaryQuote.SBQQ__Opportunity2__c);
                    }
                    OppObject.Id=primaryQuote.SBQQ__Opportunity2__r.Id;
                    UpdateOpporunitySet.add(OppObject.Id);
                    
                }
                
                if (status_code == 200){
                
                //********
                    String xmlString= hTTPRes.getBody();
                    Dom.Document domDoc = new Dom.Document();
                    domDoc.load(xmlString);
                    Dom.XMLNode Root = domDoc.getRootElement();
                   
                    
                    Dom.XMLNode[] ChildOfOp=root.getChildElement('operation',null).getChildElements();
                                    
                    
                    if(ChildOfOp.size()==3){
                        Dom.XMLNode Contact1Res=ChildOfOp[1];
                        String Contact1Status = Contact1Res.getChildElement('status', null).getText();
                        if(Contact1Status=='Success'){
                            String Contact1ID = Contact1Res.getChildElement('key', null).getText();
                            ConIdStatus.put(Contact1ID,Contact1Status);
                         }else if(Contact1Status=='Failure'){
                            ContactList[0].Contact_Status_To_Intacct__c='Failed To Insert';
                    
                        Dom.XMLNode[] ChildOfError=root.getChildElement('operation',null).getChildElement('result',null).getChildElement('errormessage',null).getChildElements();
                  
                        Dom.XMLNode Error1=ChildOfError[0];
                                       
                        String ErrorDesc1=Error1.getChildElement('description', null).getText();
                                        
                        String ErrorDesc2=Error1.getChildElement('description2', null).getText();
                                            
                        ContactList[0].Intacct_Sync_Error__c=ErrorDesc1!=null && ErrorDesc2!=null ? 'ERROR :'+ErrorDesc1+ErrorDesc2 : ErrorDesc1!=null && ErrorDesc2==null? 'ERROR :'+ErrorDesc1 : ErrorDesc1==null && ErrorDesc2!=null ? 'ERROR :'+ErrorDesc2 : ContactList[0].Intacct_Sync_Error__c;                    
                                                
                        updateContactAfterSentToIntacct.add(ContactList[0]);
                        
                }
  
                        

                        Dom.XMLNode Contact2Res=ChildOfOp[2];
                        String Contact2Status = Contact2Res.getChildElement('status', null).getText();
                        if(Contact2Status=='Success'){
                            String Contact2ID  = Contact2Res.getChildElement('key', null).getText();
                            ConIdStatus.put(Contact2ID,Contact2Status);
                         }else if(Contact2Status=='Failure'){
                            ContactList[1].Contact_Status_To_Intacct__c='Failed To Insert';
                    
                        Dom.XMLNode[] ChildOfError=root.getChildElement('operation',null).getChildElement('result',null).getChildElement('errormessage',null).getChildElements();
                  
                        Dom.XMLNode Error1=ChildOfError[0];
                                        
                        String ErrorDesc1=Error1.getChildElement('description', null).getText();
                                        
                        String ErrorDesc2=Error1.getChildElement('description2', null).getText();
                                           
                        ContactList[1].Intacct_Sync_Error__c=ErrorDesc1!=null && ErrorDesc2!=null ? 'ERROR :'+ErrorDesc1+ErrorDesc2 : ErrorDesc1!=null && ErrorDesc2==null? 'ERROR :'+ErrorDesc1 : ErrorDesc1==null && ErrorDesc2!=null ? 'ERROR :'+ErrorDesc2 : ContactList[1].Intacct_Sync_Error__c;
                    
                                                
                        updateContactAfterSentToIntacct.add(ContactList[1]);
                        
                }
  
                        
                    }
                    else if(ChildOfOp.size()==2){
                        Dom.XMLNode Contact1Res=ChildOfOp[1];
                        String Contact1Status = Contact1Res.getChildElement('status', null).getText();
                        if(Contact1Status=='Success'){
                            String Contact1ID = Contact1Res.getChildElement('key', null).getText();
                            ConIdStatus.put(Contact1ID,Contact1Status);

                        }
                        else if(Contact1Status=='Failure'){
                            ContactList[0].Contact_Status_To_Intacct__c='Failed To Insert';
                    
                        Dom.XMLNode[] ChildOfError=root.getChildElement('operation',null).getChildElement('result',null).getChildElement('errormessage',null).getChildElements();
                  
                        Dom.XMLNode Error1=ChildOfError[0];
                
                        String ErrorDesc1=Error1.getChildElement('description', null).getText();
                                         
                        String ErrorDesc2=Error1.getChildElement('description2', null).getText();
                        
                    
                        ContactList[0].Intacct_Sync_Error__c=ErrorDesc1!=null && ErrorDesc2!=null ? 'ERROR :'+ErrorDesc1+ErrorDesc2 : ErrorDesc1!=null && ErrorDesc2==null? 'ERROR :'+ErrorDesc1 : ErrorDesc1==null && ErrorDesc2!=null ? 'ERROR :'+ErrorDesc2 : ContactList[0].Intacct_Sync_Error__c;                    
                                               
                        updateContactAfterSentToIntacct.add(ContactList[0]);
                        
                }
  
                    }
                    

                     //********
                
                    if(ChildOfOp.size()-1==ConIdStatus.size() && OppObject!=null && !ConIdStatus.IsEmpty()){
                        OppObject.Bill_to_Contact_Id__c=primaryQuote.Bill_To_Contact__c;
                        OppObject.Ship_to_Contact_Id__c=primaryQuote.Ship_To_Contact__c;
                        OppObject.Intacct_Sync_Status__c=STATUS_COMPLETED;
                        Contact con=new Contact();
                        for(ID Id1:ConIdStatus.keySet()){
                            if(!contactMap.IsEmpty() && contactMap.containsKey(Id1)){
                                con=contactMap.get(Id1);
                                con.Contact_Synced_to_Intacct__c=true;
                                con.Contact_Status_To_Intacct__c='Successfully Inserted';
                                con.Intacct_Sync_Error__c='No Errors';
                                updateContactAfterSentToIntacct.add(con); 
                            
                            }
                        
                        }
                        
                    }
                    else {OppObject.Intacct_Sync_Status__c=STATUS_ERROR; }
                    
                }else{
                   OppObject.Intacct_Sync_Status__c=STATUS_ERROR;  
                }
                
                if(OppObject!=null){
                    UpdateOpporunityMap.put(OppObject.Id,OppObject);
                                       
                }//End of If
            
                                              
            }//End Of for
            
         }//End of contact map
            if(!UpdateOpporunityMap.isEmpty() && !UpdateOpporunitySet.isEmpty()){
                    for(Id opId:UpdateOpporunitySet){
                        if(UpdateOpporunityMap.containsKey(opId)){
                            UpdateOpporunityList.add(UpdateOpporunityMap.get(opId));
                        }
                    
                    }
                }
           
            if(!UpdateOpporunityList.isEmpty()){
                update UpdateOpporunityList;
            }//End of UpdateOpporunityList
           
            if(!updateContactAfterSentToIntacct.isEmpty()){
                update updateContactAfterSentToIntacct;
              
            }//End of If
        }
        Catch(Exception e){
            System.debug('Exception Found =================='+e.getMessage());
            System.debug('Exception Found =================='+e.getLineNumber());
            System.debug('Exception Found =================='+e.getcause());
            Set<Id> OppSet=new Set<ID>();
            OppSet.add(OpportunityId);
            UpdateOppWithErrorMsg(OppSet);
        }//End of Catch
        
    }//End of sendContactDetailsToIntacct
    public static void UpdateOppWithErrorMsg(Set<Id> ErrorOppIds){
        List<Opportunity> ListOfOpptys=new List<Opportunity>();
        for(Id IdObj :ErrorOppIds){
            Opportunity OppObject=new Opportunity();
            OppObject.Id=IdObj;
            OppObject.Intacct_Sync_Status__c=STATUS_SF_ERROR_FLAGGED;
            ListOfOpptys.add(OppObject);
        }
        if(!ListOfOpptys.isEmpty()){
            update ListOfOpptys;
        }
    }//End Of UpdateOppWithErrorMsg
    
    //Method to update Contact
     @future(callout=true) 
      webservice static  void UpdateContactToIntacct(Id ConId){
        List<Contact> ContactList=new List<Contact>();
        try{
                //Get Contact for Update
                ContactList=[SELECT id,Name,Account.Name,Salutation,Account_Name_Local__c,firstName,Contact_Synced_to_Intacct__c,lastName,HomePhone,phone,MobilePhone,OtherPhone,fax,Email,Account.SDR_Owner_Email_Address__c,Account.CAM_Email_Address__c,MailingCity,MailingCountry,MailingPostalCode,MailingStreet,MailingState,Intacct_Record_No__c FROM CONTACT WHERE ID =:ConId AND Contact_Synced_to_Intacct__c=True];
            
                string XMLBody;
            
                if(!ContactList.isEmpty()){
                    
                    XMLBody=getXML(ContactList);
                }
            
                //call to intacct
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
                // Prepare response/request
                HTTPResponse hTTPRes;
                HTTP http = new HTTP();
                hTTPRes = http.send(req);
                system.debug('Http Response =================='+hTTPRes);
                //Store the status code retured from intacct 
                integer status_code = hTTPRes.getStatusCode(); 
                system.debug('Http Response =================='+hTTPRes);
                system.debug('Get Body  =================='+hTTPRes.getBody()); 
                system.debug('status_code  =================='+status_code); 
                
                //Update Contact updation status
                String xmlString= hTTPRes.getBody();
                Dom.Document domDoc = new Dom.Document();
                domDoc.load(xmlString);
                Dom.XMLNode Root = domDoc.getRootElement();
                
                    
                Dom.XMLNode[] ChildOfOp=root.getChildElement('operation',null).getChildElements();
                             
                Dom.XMLNode Contact1Res=ChildOfOp[1];
                 
                String ContactStatus = Contact1Res.getChildElement('status', null).getText();
                 
                 
                 if(ContactStatus=='Success'){
                    ContactList[0].Contact_Status_To_Intacct__c='Updated Successfully';
                    ContactList[0].Intacct_Sync_Error__c='No Errors';
                    
                    
                }
                else if(ContactStatus=='Failure'){
                    ContactList[0].Contact_Status_To_Intacct__c='Failed To Update';
                    
                                        
                    Dom.XMLNode[] ChildOfError=root.getChildElement('operation',null).getChildElement('result',null).getChildElement('errormessage',null).getChildElements();
                  
                    Dom.XMLNode Error1=ChildOfError[0];
                                    
                    String ErrorDesc1=Error1.getChildElement('description', null).getText();
                                     
                    String ErrorDesc2=Error1.getChildElement('description2', null).getText();
                                       
                    ContactList[0].Intacct_Sync_Error__c=ErrorDesc1!=null && ErrorDesc2!=null ? 'ERROR :'+ErrorDesc1+ErrorDesc2 : ErrorDesc1!=null && ErrorDesc2==null? 'ERROR :'+ErrorDesc1 : ErrorDesc1==null && ErrorDesc2!=null ? 'ERROR :'+ErrorDesc2 : ContactList[0].Intacct_Sync_Error__c;
                                        
                }
                   
                  
                if(!ContactList.isEmpty()){
                    Update ContactList;
                }
                        
            }Catch(Exception e){
                System.debug('Exception Found =================='+e.getMessage());
                System.debug('Exception Found =================='+e.getLineNumber());
                System.debug('Exception Found =================='+e.getcause());     
            
            }//End of Catch
      
    }// End Of UpdateContactToIntacct()
    
    //Generate XML with the help of Contact
    public static String getXml(List<Contact> conList){
        
        XmlStreamWriter w = new XmlStreamWriter();
        w.writeStartDocument('UTF-8', '1.0');
        w.writeStartElement(null, 'request', null);        
        w.writeStartElement(null, 'control', null);
        w.writeStartElement(null, 'senderid', null);
        w.writeCharacters(INTACCT_SENDER_ID);
        w.writeEndElement(); //end of senderid
        w.writeStartElement(null, 'password', null);
        w.writeCharacters(INTACCT_SENDER_PASSWORD);
        w.writeEndElement(); //end of password
        w.writeStartElement(null, 'controlid', null);
        w.writeCharacters(INTACCT_SENDER_CONTROLID);
        w.writeEndElement(); //end of controlid
        w.writeStartElement(null, 'uniqueid', null);
        w.writeCharacters('false');
        w.writeEndElement(); //end of uniqueid
        w.writeStartElement(null, 'dtdversion', null);
        w.writeCharacters('2.1');
        w.writeEndElement(); //end of dtdversion
        w.writeStartElement(null, 'includewhitespace', null);
        w.writeCharacters('false');
        w.writeEndElement(); //end of includewhitespace
        w.writeEndElement(); //end of control        
        w.writeStartElement(null, 'operation', null);
        w.writeStartElement(null, 'authentication', null);
        w.writeStartElement(null, 'login', null);
        w.writeStartElement(null, 'userid', null);
        w.writeCharacters(INTACCT_AUTH_USERID);
        w.writeEndElement(); //end of userid
        w.writeStartElement(null, 'companyid', null);
        w.writeCharacters(INTACCT_AUTH_COMPANYID);
        w.writeEndElement(); //end of companyid
        w.writeStartElement(null, 'password', null);
        w.writeCharacters(INTACCT_AUTH_PASSWORD);
        w.writeEndElement(); //end of password
        w.writeEndElement(); //end of login
        w.writeEndElement(); //end of authentication        
        w.writeStartElement(null, 'content', null);
        for(Contact con:conList){
                       
            w.writeStartElement(null, 'function', null);
            w.writeAttribute(null, null, 'controlid', INTACCT_FUNCTION_CONTROLID);
            if(con.Contact_Synced_to_Intacct__c==False){
                 w.writeStartElement(null, 'create_contact', null);
                 w.writeStartElement(null, 'contactname', null);
                 w.writeCharacters(con.Name==null?'':con.id);
                 w.writeEndElement(); //end of contactname 
            }
            else if(con.Contact_Synced_to_Intacct__c==True)
            {
                w.writeStartElement(null, 'update_contact', null);
                w.writeAttribute(null, null, 'contactname', con.id);
            }
            w.writeStartElement(null, 'printas', null);
            w.writeCharacters(con.Account_Name_Local__c==null?con.Account.Name:con.Account_Name_Local__c);
            w.writeEndElement(); //end of printas 
            w.writeStartElement(null, 'companyname', null);
            if(ContactWithJPYFlag.containsKey(con.id) || con.Account_Name_Local__c!=null){
                w.writeCharacters(con.Account_Name_Local__c==null?con.Account.Name:con.Account_Name_Local__c);
            }
             else{
                  w.writeCharacters(con.Account.Name==null?'':con.Account.Name);
             }//End of If
            
            w.writeEndElement(); //end of companyname 
            w.writeStartElement(null, 'prefix', null);
            w.writeCharacters(con.Salutation==null?'':con.Salutation);
            w.writeEndElement(); //end of prefix  
            w.writeStartElement(null, 'firstname', null);
            w.writeCharacters(con.firstName==null?'':con.firstName);
            w.writeEndElement(); //end of firstname 
            w.writeStartElement(null, 'lastname', null);
            w.writeCharacters(con.lastname==null?'':con.lastname);
            w.writeEndElement(); //end of lastname  
            w.writeStartElement(null, 'phone1', null);
            w.writeCharacters(con.HomePhone==null?'':con.HomePhone);
            w.writeEndElement(); //end of phone1 
            w.writeStartElement(null, 'phone2', null);
            w.writeCharacters(con.Phone==null?'':con.Phone);
            w.writeEndElement(); //end of phone2  
            w.writeStartElement(null, 'cellphone', null);
            w.writeCharacters(con.MobilePhone==null?'':con.MobilePhone);
            w.writeEndElement(); //end of cellphone  
            w.writeStartElement(null, 'pager', null);
            w.writeCharacters(con.OtherPhone==null?'':con.OtherPhone);
            w.writeEndElement(); //end of pager   
            w.writeStartElement(null, 'fax', null);
            w.writeCharacters(con.fax==null?'':con.fax);
            w.writeEndElement(); //end of fax
            w.writeStartElement(null, 'email1', null);
            w.writeCharacters(con.Email==null?'':con.Email);
            w.writeEndElement(); //end of email1
            w.writeStartElement(null, 'mailaddress', null);
            w.writeStartElement(null, 'address1', null);
            string address1=con.MailingStreet;
            w.writeCharacters(address1==null?'':address1);
            w.writeEndElement(); //end of address1
            w.writeStartElement(null, 'city', null);
            w.writeCharacters(con.MailingCity==null?'':con.MailingCity);
            w.writeEndElement(); //end of city
            w.writeStartElement(null, 'state', null);
            w.writeCharacters(con.MailingState==null?'':con.MailingState);
            w.writeEndElement(); //end of state
            w.writeStartElement(null, 'zip', null);
            w.writeCharacters(con.MailingPostalCode==null?'':con.MailingPostalCode);
            w.writeEndElement(); //end of zip
            w.writeStartElement(null, 'country', null);
            if(con.MailingCountry==JAPAN_IN_ENGLISH || con.MailingCountry==JAPAN_IN_JAPNIES ){
                w.writeCharacters(JAPAN_IN_ENGLISH);
            }else{
                w.writeCharacters(con.MailingCountry==null?'':con.MailingCountry);
            }
            w.writeEndElement(); //end of country
            w.writeEndElement(); //end of mailaddress
            w.writeEndElement(); //end of create_contact
            w.writeEndElement(); //end of function  
            system.debug('w======================'+w);
            system.debug('xWWWmlOutput======================'+ w.getXmlString());
        }
        w.writeEndElement(); //end of content          
        w.writeEndElement(); //end of operation
        w.writeEndElement(); //end of request
        w.writeEndDocument();
        String xmlOutput = w.getXmlString();
        w.close();
        system.debug('xmlOutput======================'+xmlOutput);
        return xmlOutput;
    }//End of getXml
}