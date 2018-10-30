/*********************************************************************
* Last Modified by   : Grazitti 
* Modified Date      : 28-April-18
* Purpose            : #01009688 Consolidate Support Engineer Fields on Entitlement
* Line numbers       : 119,146,147,149,162,163,165,178,198,219,229,230,231,232,233,300,310

**********************************************************************/

/*************************************************************
Latest Change - 16/9/2017 by graziti support team.
Line - 190
Reason - Excluded Customer Care user from notifications.

******************************************************/


trigger sendAuthorizedContactAddedEmail on Authorized_Contact__c (after insert, after update) {

    //Authroized Contact Entitlement => AdminContactId Map
    List<Id> entitlementLst = new List<ID>();
    Map<Id, Id> authEntl_AdminContMap = new Map<Id,Id>(); //Entitlement to Authorized User Map        
    for(Authorized_Contact__c AuthCnt : Trigger.New) {        
        if(Trigger.IsInsert){ 
            if(AuthCnt.Entitlement__c != null && AuthCnt.Customer_Admin__c != true && AuthCnt.Contact__c != null ) {     
                entitlementLst.add(AuthCnt.Entitlement__c);        
            }
        }
    }
    if(entitlementLst.isEmpty() == FALSE){
        List<Authorized_Contact__c> authAdminContactLst = new List<Authorized_Contact__c>();    
        authAdminContactLst = [SELECT Id, Contact__c, Entitlement__c FROM Authorized_Contact__c WHERE Entitlement__c in :entitlementLst AND Customer_Admin__c = true];        
        if(authAdminContactLst.isEmpty() == FALSE) {
      
        //rizvan code starts       
        List<id> Conlist= new List<id>();  
        for(Authorized_Contact__c authdmin : authAdminContactLst) {                
            Conlist.add(authdmin.Contact__c);     
        }
        System.debug('Conlist-->'+Conlist);
        Map<Id, Id> contUserMAp= new Map<Id,Id>(); 
        list<user> ConUSer = [select id,contactId FROM User WHERE isActive = true AND contactId != NULL AND ContactId IN :Conlist];
        System.debug('ConUSer -->'+ConUSer );
        for(user aa : ConUSer) {                
            contUserMAp.put(aa.contactId ,aa.id);     
        }                
        // rizvan ends
        System.debug('contUserMAp-->'+contUserMAp);
        
            for(Authorized_Contact__c authdmin : authAdminContactLst) {
                if(authdmin.Contact__c != NULL && contUserMAp.containsKey(authdmin.Contact__c)) {
                    authEntl_AdminContMap.put(authdmin.Entitlement__c ,contUserMAp.get(authdmin.Contact__c));      
                }
            }
                    
            Id templateId = [SELECT ID from EmailTemplate Where DeveloperName = 'Support_AuthContact_Added_Notice_VF' Limit 1].Id;   
            Id FROM_EMAIL_ID = [select Id from OrgWideEmailAddress where DisplayName = 'Marketo Customer Support' Limit 1].Id;                  
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            
            for(Authorized_Contact__c AuthCnt : Trigger.New) {        
                if(Trigger.IsInsert){ 
                    if(AuthCnt.Entitlement__c != null && AuthCnt.Customer_Admin__c != true && AuthCnt.Contact__c != null) {
                        if(authEntl_AdminContMap.containsKey(AuthCnt.Entitlement__c)) {
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setTemplateId(templateId);
                        email.setTargetObjectId(authEntl_AdminContMap.get(AuthCnt.Entitlement__c)); //Set UserId
                        email.setWhatId(AuthCnt.Id);
                        email.setSaveAsActivity(false);
                        email.setOrgWideEmailAddressId(FROM_EMAIL_ID);                                                        
                        emails.add(email);
                        }
                    }
                }
            }                       
            if(emails.isEmpty() == FALSE) { 
                 Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(emails);                   
            }
        }    
    }  
      
    /* Part code onboarding emails by Grazitti(Rizvan).*/ 
    if(Label.enableOnboardingOnAuth=='Yes'){
        try{
            map<Id,id> EntitlementToAuthMap = new map<Id,id>();
            list<id> EmailReadAuthConList = new list<id>();
            list<id> VideoWatchAuthConList = new list<id>();    
            list<id> FirstReminderAuthConList  = new list<id>();
            list<id> SecondReminderAuthConList = new list<id>();    
            list<id> SMforNewAuthOrNewAuthAdmin = new list<id>();    
            
            for(Authorized_Contact__c AuthCnt : trigger.new) {
                if(trigger.isupdate) {
                    if(AuthCnt.Email_read__c == true && trigger.oldmap.get(AuthCnt.id).Email_read__c == false){
                        EmailReadAuthConList.add(AuthCnt.id);   
                    } 
                    if(AuthCnt.Video_Seen__c == true && trigger.oldmap.get(AuthCnt.id).Video_Seen__c == false){
                        VideoWatchAuthConList.add(AuthCnt.id);
                    }
                    if(AuthCnt.First_Reminder_Req__c == true && trigger.oldmap.get(AuthCnt.id).First_Reminder_Req__c == false){
                        FirstReminderAuthConList.add(AuthCnt.id);
                    }
                    if(AuthCnt.Second_Reminder_Req__c == true && trigger.oldmap.get(AuthCnt.id).Second_Reminder_Req__c == false){
                        SecondReminderAuthConList.add(AuthCnt.id);
                    }                         
                } 
                if(trigger.isInsert){ 
                    if(AuthCnt.Entitlement__c != null && AuthCnt.contact__c != null) {    
                        EntitlementToAuthMap.put(AuthCnt.Entitlement__c, AuthCnt.id);
                        SMforNewAuthOrNewAuthAdmin.add(AuthCnt.id);        
                    }           
                }
            }
            
            system.debug('EntitlementToAuthMap===>'+EntitlementToAuthMap);
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
            
            if(!EntitlementToAuthMap.isEmpty()){
                map<id, Entitlement> authidToEntitlmntMap = new map <id, Entitlement>();
                Set<String> businessEnts = new Set<String>(Label.Business_Entitlement_Types.split(','));
                
                for(Entitlement tmp : [select id,AssignedSupportPOC__c,AssignedSupportPOC__r.email, Support_Region__c, Account.CAM_Owner__r.email, Account.New_Business_Account_Executive__r.email from entitlement where id in :EntitlementToAuthMap.keyset() AND Type In:businessEnts AND AssignedSupportPOC__c!=null AND AssignedSupportPOC__c!='']){
                    authidToEntitlmntMap.put(EntitlementToAuthMap.get(tmp.id),tmp);        
                }
                system.debug('authidToEntitlmntMap===>'+authidToEntitlmntMap);
                if(!authidToEntitlmntMap.keyset().isEmpty()){
                   Id OnbordingTemplate = Label.OnboardingNotificationToCustomer; 
                    for(Authorized_Contact__c temp : trigger.new) {     
                        if(authidToEntitlmntMap.containskey(temp.id) && temp.Customer_Admin__c ==false && temp.Contact__c != null){
                            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                            if(authidToEntitlmntMap.get(temp.id).Support_Region__c == 'Japan'){ 
                                OnbordingTemplate = Label.Japanese_Onboarding_Notification;   
                                email.setTemplateId(OnbordingTemplate);
                            }else{
                                email.setTemplateId(OnbordingTemplate);
                            }
                            email.setTargetObjectId(temp.Contact__c); //Set UserId
                            email.setBccAddresses(new List<String>{authidToEntitlmntMap.get(temp.id).AssignedSupportPOC__r.email});
                            email.setWhatId(temp.id);
                            email.setSaveAsActivity(false);
                            email.setOrgWideEmailAddressId('0D250000000Kz9OCAS');                                                        
                            emails.add(email);
                        }
                    }
                }       
            }
            
            //Notification about onboarding email read by customer to NSM
            if(!EmailReadAuthConList.isEmpty()){
                for(Authorized_Contact__c  AuthCon : [select id, Contact__c, Entitlement__r.AssignedSupportPOC__c,Entitlement__r.AssignedSupportPOC__r.name, Contact__r.name, Entitlement__r.name, Contact__r.Account.name  from Authorized_Contact__c where id in : EmailReadAuthConList limit 10000]){
                    if(AuthCon.Entitlement__r != null && AuthCon.Entitlement__r.AssignedSupportPOC__c != null){
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setTargetObjectId(AuthCon.Entitlement__r.AssignedSupportPOC__c);
                        email.setSaveAsActivity(false);
                        email.setOrgWideEmailAddressId('0D250000000Kz9OCAS'); 
                        email.setSubject('Onboarding Email is read by customer');
                        String body = 'Dear '+AuthCon.Entitlement__r.AssignedSupportPOC__r.name+', <br/><br/> New Authorised contact '+AuthCon.Contact__r.name+' added on Entitlement {'+AuthCon.Entitlement__r.name+'}  has read the onboarding email. Check details:<br/><br/> Contact Name: '+AuthCon.Contact__r.name+'<br/> Account Name:'+AuthCon.Contact__r.Account.name+ '<br/> Entitlement Name:'+AuthCon.Entitlement__r.name+'<br/><br/> Best Regards,<br/> Marketo Support';           
                        email.setHtmlBody(body);                                                       
                        emails.add(email);   
                    }
                   
                }
            }
            
            if(!VideoWatchAuthConList.isEmpty()) {
                for(Authorized_Contact__c  AuthCon : [select id, Contact__c, Entitlement__r.AssignedSupportPOC__c,Entitlement__r.AssignedSupportPOC__r.name, Contact__r.name,Entitlement__r.name, Contact__r.Account.name  from Authorized_Contact__c where id in : VideoWatchAuthConList limit 10000]){
                    if(AuthCon.Entitlement__r != null && AuthCon.Entitlement__r.AssignedSupportPOC__c != null){
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setTargetObjectId(AuthCon.Entitlement__r.AssignedSupportPOC__c);
                        email.setSaveAsActivity(false);
                        email.setSubject('Onboarding video is watched by customer');
                        String body = 'Dear '+AuthCon.Entitlement__r.AssignedSupportPOC__r.name+', <br/><br/> New Authorised contact '+AuthCon.Contact__r.name+' added on Entitlement{'+AuthCon.Entitlement__r.name+'}  has watched the onboarding video. Check details:<br/><br/> Contact Name: '+AuthCon.Contact__r.name+'<br/> Account Name:'+AuthCon.Contact__r.Account.name+ '<br/> Entitlement Name:'+AuthCon.Entitlement__r.name+'<br/><br/> Best Regards,<br/> Marketo Support';           
                        email.setHtmlBody(body);
                        email.setOrgWideEmailAddressId('0D250000000Kz9OCAS');                                                        
                        emails.add(email);   
                    } 
                }
            }
            
            if(!FirstReminderAuthConList.isEmpty()){
                Id OnbordingReminder = SupportEmailSettings__c.getInstance('Onboarding Reminder Notification').RecordId__c;            
                for(Authorized_Contact__c  temp : [select id,Customer_Admin__c, Contact__c, Entitlement__r.Support_Region__c, Entitlement__r.AssignedSupportPOC__c,Entitlement__r.AssignedSupportPOC__r.name, Contact__r.name,Entitlement__r.name, Contact__r.Account.name  from Authorized_Contact__c where id in : FirstReminderAuthConList limit 10000]){
                    if(temp.Contact__c != null){
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        if(temp.Entitlement__r.Support_Region__c == 'Japan'){ 
                        id OnbordingTemplate = Label.Japanese_Onboarding_Reminder;   // put reminder label here.
                        email.setTemplateId(OnbordingTemplate);
                    }else{
                        email.setTemplateId(OnbordingReminder);
                    }
                    email.setTargetObjectId(temp.Contact__c); //Set UserId
                    email.setWhatId(temp.id);
                    email.setSaveAsActivity(false);
                    email.setOrgWideEmailAddressId('0D250000000Kz9OCAS');                                                        
                    emails.add(email);
                    }
                   
                }
            }
            
            if(!SecondReminderAuthConList.isEmpty()) {
                for(Authorized_Contact__c  AuthCon : [select id, Contact__c, Contact__r.account.CAM_Owner__c, Contact__r.account.CAM_Owner__r.Name, Entitlement__r.AssignedSupportPOC__c,Entitlement__r.AssignedSupportPOC__r.name, Contact__r.name,Entitlement__r.name, Contact__r.Account.name  from Authorized_Contact__c where id in : SecondReminderAuthConList limit 10000]){
                    if(AuthCon.Contact__r != null && AuthCon.Contact__r.account.CAM_Owner__c != null && AuthCon.Contact__r.account.CAM_Owner__c != Label.CustomerSupportUserId){
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setTargetObjectId(AuthCon.Contact__r.account.CAM_Owner__c);
                        email.setSaveAsActivity(false);
                        email.setSubject('Onboarding Email not read');
                        String body = 'Dear '+AuthCon.Contact__r.account.CAM_Owner__r.Name+', <br/><br/> New Authorised contact '+AuthCon.Contact__r.name+' added on Entitlement{'+AuthCon.Entitlement__r.name+'}  has not read the onboarding Email. Check details:<br/><br/> Contact Name: '+AuthCon.Contact__r.name+'<br/> Account Name:'+AuthCon.Contact__r.Account.name+ '<br/> Entitlement Name:'+AuthCon.Entitlement__r.name+'<br/><br/> Best Regards,<br/> Marketo Support';           
                        email.setHtmlBody(body);
                        email.setOrgWideEmailAddressId('0D250000000Kz9OCAS');                                                        
                        emails.add(email);   
                    } 
                }
            }
            
            system.debug('emails===>'+emails);
            if(emails.isEmpty() == FALSE) { 
                Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(emails);                   
            }
            
            if((!SMforNewAuthOrNewAuthAdmin.isEmpty() && label.EnableSMforNewAuthOrNewAuthAdmin == 'True') || Test.isRunningTest()) {
                list<case> SMcaseforAuthCon = new list<case>();
                for(Authorized_Contact__c temp : [select id,Customer_Admin__c, Entitlement__r.name, contact__r.accountid, contact__c, contact__r.Name, Entitlement__r.type, Entitlement__r.asset.Purpose__c, Entitlement__r.AssignedSupportPOC__c from Authorized_Contact__c where id in: SMforNewAuthOrNewAuthAdmin and ( Entitlement__r.type = 'Premier' OR Entitlement__r.type = 'Premier Plus' OR Entitlement__r.type = 'Elite' ) and Entitlement__r.asset.Purpose__c != 'Sandbox'  limit 10000]){
                    string sub;
                    string des;
                    string owner;
                    des = temp.contact__r.name+ ' has been assigned as an Authorized User for their account. Using your knowledge of the customer and account history, please evaluate the best form of outreach to make. If this is a test user, agency user, or similar user, then no outreach may be necessary. Below is some sample text to get you started –do not copy/paste this message.\r\n \r\nPlease use the following procedure\r\n-Email the user directly from your outlook\r\n-Subject line: Welcome to Marketo Premier Support\r\n-Sample body:\r\n“Hi <customer Name>,\r\nMy name is <your name>, I am your named support engineer. I will be your primary point of contact for case resolution and support, although I may not always be the person directly handling every case. With premier support you are entitled to 24x5 support, along with accelerated SLAs. If you need to reach out, you have a few options:\r\n-Log a case through our portal at support.marketo.com\r\n-Give us a call: 650-276-2303\r\n-Chat with us: Also accessible through support.marketo.com –look for the ‘chat now’ banner on the right\r\n-Email: support@marketo.com (This is much more reliable than emailing me directly)\r\n \r\nPremier support provides a number of benefits, but one service in particular that I’d like to make sure you know about is our mentor sessions. These are 30-60 minute engagements that you can use to get help with feature adoption, extended how-to scenarios, new release tours, or even just a sanity check. To request a mentor session we have a widget available at support.marketo.com on the right hand side of the window, but you can also file a case through the portal to make the request.\r\nI look forward to working with you,\r\n<your name>”\r\n \r\nAdditional considerations:\r\n-Make this as personal as possible\r\n-Talk about the current state of affairs of their instance or account, if appropriate\r\n-Suggest a mentor sessions for a new release, or anything else relevant\r\n-Introduce them to their CAM if they are a good candidate for smooth transitions';                    
                    if(temp.Customer_Admin__c){
                        sub  = 'A new Support Admin has been assigned to '+ temp.Entitlement__r.name;                               
                    }else {            
                        sub  = 'A new Authorized Contact has been added to '+ temp.Entitlement__r.name;                        
                    }
                    system.debug('AssignedSupportPOC__c===>'+temp.Entitlement__r.AssignedSupportPOC__c);
                    if( (temp.Entitlement__r.type == 'Premier' || temp.Entitlement__r.type == 'Premier Plus') && temp.Entitlement__r.AssignedSupportPOC__c!=null ) {
                        owner = temp.Entitlement__r.AssignedSupportPOC__c;
                    }else if(temp.Entitlement__r.type == 'Elite'  && temp.Entitlement__r.AssignedSupportPOC__c!= null){
                        owner = temp.Entitlement__r.AssignedSupportPOC__c;
                    }else{
                        owner = '00G50000001R8aQ';
                    }
                    case SMcase = new case(
                        Accountid = temp.contact__r.accountid,
                        Contactid = temp.contact__c,
                        ownerid = owner,
                        problem_type__c ='Account Notification',
                        Category__c     = 'New Authorized Contact',
                        Subject = sub,
                        Description = des,
                        recordtypeid = '012W00000008qrC' 
                    );
                    SMcaseforAuthCon.add(SMcase);            
                }
                system.debug('emails===>'+SMcaseforAuthCon);
                if(!SMcaseforAuthCon.isEmpty()) {
                    insert SMcaseforAuthCon;
                }
                
            }
        }catch (Exception e) {
            system.debug('Exception =======>'+e);
            CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);
        }     
        /* Part code onboarding emails by Grazitti(Rizvan).*/
    }
    if((Trigger.isInsert && Label.EliteProactiveProjectSwitch == 'Yes') || Test.isRunningTest()){
        Set<Id> entitlementLs = new Set<Id>();
        list<Case> casesTobeInserted = new list<case>();      
        for(Authorized_Contact__c AuthCnt : trigger.New){ 
            if(AuthCnt.Entitlement__c != null && AuthCnt.Contact__c != null ) {   
                entitlementLs.add(AuthCnt.Entitlement__c);  
            }
        }
        if(entitlementLs.isEmpty() == FALSE){
            Set<String> entTypes = new Set<String>(Label.EliteTypeCustomers.Split(';'));    
            for(Authorized_Contact__c authCon :[SELECT Id, Proactive_Email__c, Contact__c,Contact__r.email, Entitlement__c,Entitlement__r.name FROM Authorized_Contact__c WHERE Entitlement__c IN : entitlementLs AND Entitlement__r.Status='Active' AND Entitlement__r.type IN :entTypes  AND Proactive_Email__c = True and id in : trigger.New]){
                Case proCase = new Case();
                proCase.ContactId = authCon.contact__c;
                proCase.Problem_Type__c = 'Elite Services';
                proCase.Category__c = 'Kick Off Call';
                proCase.Subject = 'New authorized contact';
                proCase.description = 'New authorized contact added on '+authCon.Entitlement__r.name; 
                proCase.Origin = 'Email'; 
                proCase.Status = 'New'; 
                proCase.Priority = 'P3';
                proCase.OnPortalAvailable__c = true;
                proCase.recordtypeId = Label.ProActiveCaseRecTypeId;
                proCase.ownerId = Label.ProActiveUserId;
                casesTobeInserted.add(proCase);
            }      
            if(!casesTobeInserted.isEmpty()) {
                try{insert casesTobeInserted;}catch(Exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}          
            }
        }
    }
     //Kamal code starts here
    if(Trigger.isInsert){
        try{
            Map<Id,Authorized_Contact__c> contMap = new Map<Id,Authorized_Contact__c>();
            Map<Id,Boolean> contBooMap = new Map<Id,Boolean>(); 
            List<Case> caseList = new List<case>();
            List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
            
            
            for(Authorized_Contact__c authcont : [SELECT Id, Name, Contact__c, Entitlement__r.AccountId, Entitlement__r.AssignedSupportPOC__r.Name, Entitlement__r.AssignedSupportPOC__c, Entitlement__r.AssignedSupportPOC__r.Email FROM Authorized_Contact__c WHERE Id =: Trigger.New AND Entitlement__r.Type IN ('Premier','Premier Plus')]){
                contMap.put(authcont.Contact__c,authcont);
            }
            
            for(Case c : [SELECT Id, ContactId FROM Case WHERE Problem_Type__c = 'Account Notification' AND Category__c = 'Introduction Video' AND RecordTypeId =: Label.ProActiveCaseRecTypeId AND ContactId =: contMap.keySet()]){
                contBooMap.put(c.ContactId,true);
            }
            
            for(Authorized_Contact__c auth : contMap.values()){
                if(!contBooMap.ContainsKey(auth.Contact__c) && contBooMap.get(auth.Contact__c) != true){
                    if(auth.Entitlement__r.AssignedSupportPOC__c!= Null){
                        Case procase = new Case(OwnerId = Label.ProActiveUserId, RecordTypeId = Label.ProActiveCaseRecTypeId, Origin = 'Proactive', Status = 'Closed', Priority = 'P3', AccountId = auth.Entitlement__r.AccountId, ContactId = auth.Contact__c, Problem_Type__c = 'Account Notification', Category__c = 'Introduction Video', Subject = 'Introduction Video Sent', Description = 'A welcome email and introduction video was sent to the authorized Admin.' );
                        caseList.add(procase);
                        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                        mail.setTargetObjectId(auth.Contact__c);
                        mail.setWhatId(auth.id);
                        mail.setOrgWideEmailAddressId('0D238000000TQIa');
                        mail.setReplyTo(auth.Entitlement__r.AssignedSupportPOC__r.Email);
                        mail.setTemplateId(Label.ETNotificationToNewPremierCustomers); 
                        mail.setUseSignature(false); 
                        mail.setBccSender(false); 
                        mail.setSaveAsActivity(false);  
                        emailList.add(mail);
                    }
                }
            }
            if(!caseList.isempty()) Insert caseList;
            if(!emailList.isempty()) Messaging.sendEmail(emailList, false); 
        }catch(Exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
    }
    //Kamal code ends here
    /****************************************************************************************
        Below code is written to Create Jive users for Bizible customer only...
    ******************************************************************************************/
    if((Trigger.isAfter && Trigger.isInsert && System.isBatch() == False && System.isFuture()== False && Support_Switches__c.getInstance('BizibleSupportSwitch') != null && Support_Switches__c.getInstance('BizibleSupportSwitch').isActive__c == 'Yes') || Test.isRunningTest()){
        try{
            Set<Id> authContactIds = new Set<Id>();
            Set<Id> finalAuthContactIds = new Set<Id>();
            Set<String> bizibleEntilements = new Set<String>(Label.Bizible_Entitlement_Types.split(','));
            
            for(Authorized_Contact__c ac : Trigger.new){
                if(ac.contact__c != null) authContactIds.add(ac.Id);
            }
            
            if(!authContactIds.isEmpty()){
                for(Authorized_Contact__c con : [Select id,contact__c,Contact__r.account.Bizible_Customer__c from Authorized_Contact__c where Id IN: authContactIds and contact__r.account.Bizible_Customer__c = True and entitlement__r.type IN : bizibleEntilements]){
                    finalAuthContactIds.add(con.Id);
                }
            }
            
            if(!finalAuthContactIds.isEmpty() && finalAuthContactIds.Size() > 0){
                if(finalAuthContactIds.Size() > 6){
                    JiveBizibleContactSync b = new JiveBizibleContactSync(finalAuthContactIds); 
                    database.executebatch(b,30);
                }
                else if(finalAuthContactIds.Size() < 6){
                    JiveBizibleContactSync.callJiveApi(finalAuthContactIds);
                }
            }
        }
        catch(Exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
    }
}