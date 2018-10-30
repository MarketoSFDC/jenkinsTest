/*********************************************************************
* Last Modified by   : Grazitti 
* Modified Date      : 28-April-18
* Purpose            : #01009688 Consolidate Support Engineer Fields on Entitlement
* Line numbers       : 116,130,154,170,189,190,203,204,223,236,237,272,276,277,278,297,298,310,311,312,326,354,372,379,408,442

**********************************************************************/

/**********************
Last Modified By     : Suraj Makandar, Jade Global Inc, 
 Last Modified Date  : on 7th August 2017
 Purpose             : Populate the Named_Support_Manager__c value irrespective of the type and carried over from old to new entitlement.
 
Latest Change - 16/9/2017 by graziti support team.
Line - 412
Reason - Excluded Customer Care user from notifications.
*********************/
public class UpdateEntitlements_Trigger {

    public static Set<String> businessEnts = new Set<String>(Label.Business_Entitlement_Types.split(','));
    public static void addPremiumUsersToUniversityGroup(List<Entitlement> triggerNew, Map<Id, Entitlement> triggerOldMap, Boolean isInsert, boolean isUpdate){
       /* Set<String> educationalAccounts   = new Set<String>();
        Set<String> expiredEntitlements   = new Set<String>();
        Id UNIV_RECORDTYPE_ID = LMS_Util.LMSEntRecordTypeId;
        
        for(Entitlement ent : triggerNew){
            if(ent.recordTypeId == UNIV_RECORDTYPE_ID  && ent.Opportunity__c!= null)
            {   
                if(isInsert){
                    if(ent.Status != 'Expired')
                        educationalAccounts.add(ent.AccountId);
                    
                }else if(isUpdate){
                    if(triggerOldMap.get(ent.Id).Status == 'Expired' && ent.Status != 'Expired'){
                        educationalAccounts.add(ent.AccountId);
                    }else if(triggerOldMap.get(ent.Id).Status != 'Expired' && ent.Status == 'Expired'){
                        expiredEntitlements.add(ent.Id);
                    }
                }
            }
        }
        //DELETE OR REMOVE USER FROM PREMIUM CATALOG GROUP. WE PERFORM THIS ACTION USING FUTURE METHOD.
        if(!System.isFuture()){
            if(!educationalAccounts.isEmpty())
                LMS_Util.addUserToPublicGroup(educationalAccounts, System.Label.PremiumEducationCatalogPublicGroup);
            if(!expiredEntitlements.isEmpty()){
                LMS_Util.deleteUserFromGroup(expiredEntitlements);
            }
        }    
        */
    }
    
    //Added sops-968
    public class NSMIdNOperation {
        public boolean updateCustomSettings;
        public Id NSMId;
        public Integer Counter;
        public NSMIdNOperation(){
            updateCustomSettings  = true;
            NSMId = Null;
            Counter = 1;
        }
        
        
        
        public NSMIdNOperation GetNSM_IdAnd_UpdateOperation(String SupportRegion, Boolean NSMrobin, Integer Count,Map<Id,Boolean> usrMap){
            if(SupportRegion =='North America'){
                if(NSMrobin){
                   if(usrMap.get(System.Label.TSM_in_Entitlement_Louiza) == true && Count == 1){
                       NSMId = System.Label.TSM_in_Entitlement_Louiza;
                       Counter = 2;
                   } 
                   else if(usrMap.get(System.Label.TSM_in_Entitlement_Robert) == true && Count == 2){
                       NSMId = System.Label.TSM_in_Entitlement_Robert;
                       Counter = 3;
                   } 
                   else if(usrMap.get(System.Label.TSM_in_Entitlement_ReAnnita) == true && Count == 3){
                        NSMId = System.Label.TSM_in_Entitlement_ReAnnita;
                        Counter = 1;
                   } updateCustomSettings  = true;
                }
                                 
            }else if(SupportRegion=='EMEA'){
               if(usrMap.get(System.Label.TSM_For_EMEA) == true) NSMId = System.Label.TSM_For_EMEA;
               
            }else if(SupportRegion=='ANZ' || SupportRegion=='APAC') {
              if(usrMap.get(System.Label.TSM_For_APAC) == true) NSMId = System.Label.TSM_For_APAC;
            }
            else if(SupportRegion == 'Japan') {
              if(usrMap.get(System.Label.TSM_For_Japan) == true) NSMId = System.Label.TSM_For_Japan;
            }
            return this;
        }
    }
        public static Map<Id,Boolean> isUserActive(){
            Map<Id,Boolean> usrMap = new Map<Id,Boolean>();
            Set<Id> usrIds;
            usrIds = new Set<Id>{Label.TSM_in_Entitlement_Louiza,Label.TSM_in_Entitlement_Robert,Label.TSM_in_Entitlement_ReAnnita,Label.TSM_For_EMEA,Label.TSM_For_APAC,Label.TSM_For_Japan};
            for(User usr : [Select id,isactive from User where id IN: usrIds ]){
                usrMap.put(usr.id,usr.isactive);
            }
            return usrMap;
        }
    
    //Added sops-968
    public static void AssignNSMForBusinessEntitlements_OnInsert(List<Entitlement> TriggerNew) {
        //HANDLE BEFORE INSERT
        System.debug('AssignNSMForBusinessEntitlements_OnInsert==> ' +  TriggerNew);
        Set<Id> accountIds = new Set<Id>();
        Set<Id> validEntIds = new Set<Id>();
        Set<String> validRegions = new Set<String>{'NS','PE','QC','NB','FL','GA','SC','NC','VA' ,'KY','TN','WV','OH','IN','MI' ,'DC' ,'MD' ,'DE','NJ','PA','NY' ,'ME','VT','NH','MA','RI','CT'}; 
        Map<Id, Account> accounts = new Map<Id, Account>();
        Map<Id,Boolean> usrStatusMap = new Map<Id,Boolean>();
        usrStatusMap = isUserActive();
        RobinRoundNSM1__c CS = RobinRoundNSM1__c.getInstance('NSMcheckbox');         
        boolean updateCustomSettings = false;   
        for(Entitlement et: TriggerNew) {
            if(et.Status != 'Expired' && businessEnts.contains(et.type) && et.AssignedSupportPOC__c == Null) {
                validEntIds.add(et.Id);
                accountIds.add(et.AccountId);
            }   
        }
        if(accountIds.isEmpty() == FALSE) {
            accounts = new Map<Id, Account>([select id, name, billingState,Support_Point_Of_Contact__c from Account where id in :accountIds AND Account_Sub_Type__c!= 'Ex-Customer' AND Partner_Type__c!= 'Ex-Partner']);     
        }      
        for(Entitlement et: TriggerNew){
            if(!validEntIds.contains(et.Id)) continue;                      
            if(!accounts.containsKey(et.AccountId)) continue;                       
            Account acc = accounts.get(et.AccountId);   
            NSMIdNOperation nsmIDwithStatus = new NSMIdNOperation ();
            nsmIDwithStatus.GetNSM_IdAnd_UpdateOperation(et.Support_Region__c,CS.NSMrobin__c,Integer.valueOf(CS.Counter__c),usrStatusMap);
            et.AssignedSupportPOC__c = nsmIDwithStatus.NSMId;
            et.POC_Type__c = 'Named Support Manager';
            if(nsmIDwithStatus.updateCustomSettings){ 
                updateCustomSettings  = true;
                CS.NSMrobin__c = true; 
                CS.Counter__c = nsmIDwithStatus.Counter;
            }
            
        }
        if(updateCustomSettings) update CS;            
    }
    
    //Added sops-968
    public static void AssignNSMForBusinessEntitlements_OnUpdate(Map < ID, Entitlement > TriggerNewMap, Map < ID, Entitlement > TriggerOldMap) {
        //HANDLE BEFORE UPDATE        
        System.debug('AssignNSMForBusinessEntitlements_OnUpdate==> ' +  TriggerOldMap + ' ' +  TriggerNewMap);
        Set<Id> accountIds = new Set<Id>();
        Set<Id> validEntIds = new Set<Id>();
        Map<Id, Account> accounts = new Map<Id, Account>();
        Map<Id,Boolean> usrStatusMap = new Map<Id,Boolean>();
        usrStatusMap = isUserActive();
        RobinRoundNSM1__c CS = RobinRoundNSM1__c.getInstance('NSMcheckbox');
        boolean updateCustomSettings = false;
        for(Entitlement et: TriggerNewMap.Values()) {
            if(businessEnts.contains(et.type) && et.Status != 'Expired' && et.AssignedSupportPOC__c== NULL) {  
                validEntIds.add(et.Id);
                accountIds.add(et.AccountId);                                
            }
        }
        System.debug('AssignNSMForBusinessEntitlements_OnUpdate==> ' +  accountIds + ' ' + validEntIds);        
        if(accountIds.isEmpty() == FALSE) {
            accounts = new Map<Id, Account>([select id, name, billingState,Support_Point_Of_Contact__c from Account where id in :accountIds AND Account_Sub_Type__c!= 'Ex-Customer' AND Partner_Type__c!= 'Ex-Partner']);     
        }  
        system.debug('accounts ===> ' + accounts);
        for(Entitlement et: TriggerNewMap.Values()) {
            if(!validEntIds.contains(et.Id)) continue;                      
            if(!accounts.containsKey(et.AccountId)) continue;            
            Account acc = accounts.get(et.AccountId);        
            NSMIdNOperation nsmIDwithStatus = new NSMIdNOperation ();
            nsmIDwithStatus.GetNSM_IdAnd_UpdateOperation(et.Support_Region__c,CS.NSMrobin__c,Integer.ValueOf(CS.Counter__c),usrStatusMap);
            et.AssignedSupportPOC__c = nsmIDwithStatus.NSMId;
            et.POC_Type__c = 'Named Support Manager';
            if(nsmIDwithStatus.updateCustomSettings) { 
                updateCustomSettings  = true;
                CS.NSMrobin__c = true; 
                CS.Counter__c = nsmIDwithStatus.counter;
            }           
        }   
        if(updateCustomSettings) update CS;                       
    }
    
    //SOPS-1102 starts
    public static void SendEmailToNSEForPremiumEntitlements_OnInsert(List<Entitlement> TriggerNew){
        List<Case> CasesTobeInserted = new List<Case>();
        Map<Id,String> accMap= new Map<Id,String>();
        for(Entitlement ett: [Select id,Account.Name from Entitlement where id in : TriggerNew]){
            accMap.put(ett.Id,ett.Account.Name);
        }
        for(Entitlement ent: TriggerNew){           
        if(ent.type != null && (ent.type == 'Premier' || ent.type == 'Premier Plus') && ent.Status != 'Expired' && ent.AssignedSupportPOC__c!= null) {
            system.debug('%% entered in insert' +ent.AssignedSupportPOC__c);
            Case cse = new Case();
            cse.recordTypeId  = Label.ProActiveCaseRecTypeId;
            if(ent.accountId != null){
                cse.AccountId = ent.accountId;
            }
            if(ent.Support_Admin_Contact__c != null){
                cse.ContactId = ent.Support_Admin_Contact__c;
            }
            cse.Origin = 'Proactive';
            cse.Priority = 'P2';
            cse.Problem_Type__c = 'Support Review';
            cse.Category__c = 'Kick Off Call';
            if(ent.AssignedSupportPOC__c!= null){
                cse.OwnerId = ent.AssignedSupportPOC__c;
            }
            cse.Subject = 'You have been assigned as the NSE to ' +accMap.get(ent.Id);
            cse.Description =  'You have been assigned as the NSE for ' +accMap.get(ent.Id)+ ' If this is a new account then arrange a kickoff call with the customer. If this is an existing customer then arrange for an introduction call, including a hand-off with the previous owner, if possible.';
            CasesTobeInserted.add(cse);
            
        }
           if(CasesTobeInserted.IsEmpty() == false){insert CasesTobeInserted;}
        }
    }
    
    public static void SendEmailToNSEForPremiumEntitlements_OnUpdate(Map < ID, Entitlement > TriggerNewMap, Map < ID, Entitlement > TriggerOldMap){
         Map<Id,String> accMap= new Map<Id,String>();
        for(Entitlement ett: [Select id,Account.Name from Entitlement where id in : TriggerNewMap.keySet()]){
            accMap.put(ett.Id,ett.Account.Name);
        }
        //entList = [Select id,Account.Name from Entitlement where id IN : entId limit 1];
        List<Case> CasesTobeInserted = new List<Case>();
        for(Entitlement ent: TriggerNewMap.values()) {           
            if(ent.type != null && (ent.type == 'Premier' || ent.type == 'Premier Plus') && ent.AssignedSupportPOC__c!= null && ent.Status != 'Expired' && (TriggerOldMap.get(ent.Id).AssignedSupportPOC__c!= TriggerNewMap.get(ent.Id).AssignedSupportPOC__c) ) {
                Case cse = new Case();
                cse.recordTypeId  = Label.ProActiveCaseRecTypeId;
                if(ent.accountId != null){
                    cse.AccountId = ent.accountId;
                }
                if(ent.Support_Admin_Contact__c != null){
                    cse.ContactId = ent.Support_Admin_Contact__c;
                }
                cse.Origin = 'Proactive';
                cse.Priority = 'P2';
                cse.Problem_Type__c = 'Support Review';
                cse.Category__c = 'Kick Off Call';
                if(ent.AssignedSupportPOC__c!=null){
                    cse.OwnerId = ent.AssignedSupportPOC__c;
                }
                cse.Subject = 'You have been assigned as the NSE to ' +accMap.get(ent.Id);
                cse.Description =  'You have been assigned as the NSE for ' +accMap.get(ent.Id)+ ' If this is a new account then arrange a kickoff call with the customer. If this is an existing customer then arrange for an introduction call, including a hand-off with the previous owner, if possible.';
                CasesTobeInserted.add(cse);
            }
        }   
        if(CasesTobeInserted.IsEmpty() == false){insert CasesTobeInserted;}
    }
    
  //SOPS-1102 code ends  
    
    
    public static void ClearSubscriptionEndDate_OnUpdate(Map < ID, Entitlement > TriggerNewMap, Map < ID, Entitlement > TriggerOldMap) {
        //HANDLE SUBSCRIPTION DATE
        for(Entitlement entl_obj: TriggerNewMap.Values()) {
            if(entl_obj.Processed_For_grace__c == false) {
                entl_obj.Processed_For_grace__c = FALSE;
                entl_obj.Subscription_End_Date__c = entl_obj.EndDate;
            }
        }        
    }

    public static void AssignSubscriptionEndDate_OnInsert(List<Entitlement> TriggerNew) {
        for(Entitlement eid: TriggerNew){              
           eid.Subscription_End_Date__c = eid.enddate;
        }    
    }

   public static void updateEntitlementAccount(Map<Id, Entitlement> TriggerNewMap) {
       List<Id> acnt_ID = new List<Id>();
        List<Account> acnt_list_update = new List<Account>();  
        for(Entitlement ent: TriggerNewMap.Values()) {
            if(ent.AccountId != null)acnt_ID.Add(ent.AccountId);            
        }
        for (account acc: [SELECT Id,NAME, support_level1__c,Support_Point_Of_Contact__c, (SELECT Type,Name, Id, Status, Entitlement_Status__c, AssignedSupportPOC__c,Support_Region__c FROM Entitlements WHERE Entitlement_Status__c = 'Active' Order by type ASC,EndDate Desc Limit 1) FROM ACCOUNT WHERE ID IN: acnt_ID]) {
            if(acc.support_level1__c == null)acc.support_level1__c = '';
            if(acc.Entitlements.Size() > 0){
                for(Entitlement ent : acc.Entitlements){
                    if(ent.type == 'Premier' && ent.AssignedSupportPOC__c!= null) acc.Support_Point_Of_Contact__c = ent.AssignedSupportPOC__c;
                    else if(ent.type == 'Elite' && ent.AssignedSupportPOC__c!= null)  acc.Support_Point_Of_Contact__c = ent.AssignedSupportPOC__c;
                    else if(businessEnts.contains(ent.type) && ent.AssignedSupportPOC__c!= null) acc.Support_Point_Of_Contact__c = ent.AssignedSupportPOC__c;
                    if (ent.Type == NULL) ent.Type = '';             
                    if (!acc.support_level1__c.containsIgnoreCase(ent.type)) acc.support_level1__c = acc.support_level1__c + ';' + ent.type + ' ;';                                
                }
                 acnt_list_update.add(acc); 
            }          
        }
         if(!acnt_list_update.isEmpty())try{DatabaseOperation.updateAccount(acnt_list_update, true, true);} catch(Exception e){TriggerNewMap.values()[0].addError(e);} 
    }
    
    //Sops-968
    
    
    
    //Added by Abhijeet Baneka @ Jadeglobal on 11.11.2015 
    public static void clearInactiveUsersOnEntitlementUpdate(List<Entitlement> TriggerNew){
        set<id> userIdSet = new set<id>();
        set<id> inactiveUserIdsSet = new set<id>();
        for(Entitlement et : TriggerNew){
            if(et.AssignedSupportPOC__c!= null){
                 userIdSet.add(et.AssignedSupportPOC__c);
            }
        }
        
        if(!userIdSet.isEmpty()){
            for(User usr: [SELECT id,IsActive FROM User WHERE id IN: userIdSet AND IsActive = false]){
                inactiveUserIdsSet.add(usr.id);
            }
        }
        
        if(!inactiveUserIdsSet.isEmpty()){
            for(Entitlement et : TriggerNew){
                if(et.AssignedSupportPOC__c!= null){
                    if(inactiveUserIdsSet.contains(et.AssignedSupportPOC__c)){
                        et.AssignedSupportPOC__c = null;
                    }
                }
            }
      }  
    }
    
    public static void SendnotificationToBusinessAuthCon(list<id> EntLists) {
        List<Case> trackInitialMeetingCases = new List<Case>();         
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        Id OnbordingTemplate = Label.OnboardingNotificationToCustomer;        
        //SupportEmailSettings__c.getInstance('Onboarding Notification To Customer').RecordId__c; 
        
        
        for(Authorized_Contact__c temp : [select id, Entitlement__r.Support_Region__c, Entitlement__r.AssignedSupportPOC__c,Entitlement__r.AssignedSupportPOC__r.email, contact__c, contact__r.AccountId, contact__r.Account.CAM_Owner__c, contact__r.Account.CAM_Owner__r.email, contact__r.Account.New_Business_Account_Executive__r.email, Customer_Admin__c from Authorized_Contact__c where Customer_Admin__c =true and entitlement__c in : EntLists]) {     
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            if(temp.Entitlement__r.Support_Region__c == 'Japan'){ 
                OnbordingTemplate = Label.Japanese_Onboarding_Notification;   
                email.setTemplateId(OnbordingTemplate);
            }else{
                email.setTemplateId(OnbordingTemplate);
            }
            email.setTemplateId(OnbordingTemplate);
            email.setTargetObjectId(temp.Contact__c); //Set UserId
            email.setWhatId(temp.id);
            if(temp.Entitlement__r.AssignedSupportPOC__c != null) email.setBccAddresses(new List<String>{temp.Entitlement__r.AssignedSupportPOC__r.email});
            email.setSaveAsActivity(false);
            email.setOrgWideEmailAddressId('0D250000000Kz9OCAS');                                                        
            emails.add(email);                        
            if(Label.CreateOnBoardingCase == 'Yes' || Test.isRunningTest()) {               
                trackInitialMeetingCases.Add(CreateNewCase(temp));
            }
        }
        system.debug('emails===>'+emails);
        if(emails.isEmpty() == FALSE) { 
            Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(emails);                   
        } 
        
        if(trackInitialMeetingCases.isEmpty() == FALSE) insert trackInitialMeetingCases;                      
    }
    
    public static Case CreateNewCase(Authorized_Contact__c temp) {    
        string accountId= temp.Contact__r.AccountId;
        case c1 = new case(OwnerId = temp.Entitlement__r.AssignedSupportPOC__c );
        //new Case( recordTypeId='01250000000UJwxAAG',Origin='Phone',AccountId=temp.Contact__r.AccountId,ContactId=temp.Contact__c,
        //Priority='P2',Subject='Business Support Onboarding Followup Needed',Description=Label.OnBoardingNewCaseDescriptoin));
        Map<String, OnBoardingCase__c> allValues = OnBoardingCase__c.getAll();        
        for(OnBoardingCase__c tmp : allValues.values() ){
            if(tmp.Name =='Account') {
                c1.put(tmp.fieldName__c,accountId);
            } else if(tmp.Name =='Contact') {
                c1.put(tmp.fieldName__c,temp.get(tmp.fieldValue__c));            
            } else {
                c1.put(tmp.fieldName__c,tmp.fieldValue__c);
            }           
        }
        return c1;        
    }
    
    public static void BusinessEntCreationEmailtoCAM(list<id> EntLists) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(entitlement temp : [select id, name, AssignedSupportPOC__c, Account.name, AssignedSupportPOC__r.email,Account.CAM_Owner__c, Account.CAM_Owner__r.name from entitlement where id in : EntLists]){
            if(temp.Account.CAM_Owner__c !=null && temp.Account.CAM_Owner__c != Label.CustomerSupportUserId){
                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                if(Test.isRunningTest())
                    email.setTargetObjectId(userinfo.getUserId());                
                else
                    email.setTargetObjectId(temp.Account.CAM_Owner__c);
                if(temp.AssignedSupportPOC__c !=null) {                   
                    list<string> cc = new list<string>();                    
                    cc.add(temp.AssignedSupportPOC__r.email);
                     email.setCcAddresses(cc);
                }
                email.setSaveAsActivity(false);
                email.setOrgWideEmailAddressId('0D250000000Kz9OCAS'); 
                email.setSubject('New Business Entitlement Created');
                String body;
                if(temp.Account.CAM_Owner__r.name == null){
                    body = 'Dear, <br/><br/> New Entitlement {'+temp.name+'}  is created for account {'+temp.Account.name+'}. <br/><br/> Best Regards,<br/> Marketo Support';                           
                }else{
                    body = 'Dear '+temp.Account.CAM_Owner__r.name+', <br/><br/> New Entitlement {'+temp.name+'}  is created for account {'+temp.Account.name+'}. <br/><br/> Best Regards,<br/> Marketo Support';           
                }
                email.setHtmlBody(body);                                                       
                emails.add(email); 
            }
        }
        system.debug('emails===>'+emails);
        if(emails.isEmpty() == FALSE) { 
            Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(emails);                   
        }         
    }
    public static void NotifyNewPremierCustomer(List<Id> entIds){   
        List<Id> contactIds = new List<Id>();
        Map<Id,Boolean> caseMap = new Map<Id,Boolean>();
        List<Case> caseList = new List<case>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();

        list<Authorized_Contact__c> authList = new list<Authorized_Contact__c>([SELECT Id, Entitlement__c, Contact__c, Entitlement__r.AccountId, Entitlement__r.AssignedSupportPOC__r.Name, Entitlement__r.AssignedSupportPOC__c, Entitlement__r.AssignedSupportPOC__r.Email FROM Authorized_Contact__c WHERE Entitlement__c in : entIds]);
        if(!authList.isempty()){
            for(Authorized_Contact__c ac : authList){
                contactIds.add(ac.Contact__c);  
                caseMap.put(ac.Contact__c,false);
            }
            if(!contactIds.isempty()){
                for(Case cse : [SELECT Id, ContactId FROM Case WHERE Problem_Type__c = 'Account Notification' AND Category__c = 'Introduction Video' AND RecordTypeId =: Label.ProActiveCaseRecTypeId AND ContactId =: contactIds]){
                    caseMap.put(cse.ContactId,true);
                }
                if(!caseMap.isempty()){
                    for(Authorized_Contact__c auth : authList){
                        if((caseMap.ContainsKey(auth.Contact__c) && caseMap.get(auth.Contact__c) != true) || Test.isRunningTest()){
                            Case procase = new Case(OwnerId = Label.ProActiveUserId,status='Closed', RecordTypeId = Label.ProActiveCaseRecTypeId, Origin = 'Proactive', Priority = 'P3', AccountId = auth.Entitlement__r.AccountId, ContactId = auth.Contact__c, Problem_Type__c = 'Account Notification', Category__c = 'Introduction Video', Subject = 'Introduction Video Sent', Description = 'A welcome email and introduction video was sent to the authorized Admin.');
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
                if(!caseList.isempty())insert caseList;
                if(!emailList.isempty())Messaging.sendEmail(emailList, false);  
            }
        }
    }
    public static void createSMcaseforPremierEntitlements(Set<Id> entIds){    
        list<case> casesTobeInserted = new list<case>(); 
        for (Entitlement ent: [Select id,account.Name,status,account.Id,type,AssignedSupportPOC__c,Support_Region__c from Entitlement where id in:entIds and type In ('Premier','Premier Plus') and AssignedSupportPOC__c = null and Status != 'Expired'] ){               
            case cs = new case();
            cs.recordtypeId = Label.SitManSupportRecordTypeId;      
            cs.ownerId = Label.SupportEscalationsQueueId;
            cs.Situation_Account__c = ent.account.Id;
            cs.AccountId = ent.account.Id;
            cs.origin = 'Support';
            cs.EntitlementId = ent.id;
            cs.Problem_type__c = 'Support Review';
            cs.category__c = 'Kick Off';
            cs.subject = 'New Premier/Elite Account in'+' '+ ent.Support_Region__c +'-'+ ent.Account.Name; 
            cs.description = 'A new Premier/Elite account has been created in your region. Please assign an NSE to this account and work towards scheduling the welcome call.';   
            casesTobeInserted.add(cs);  
        }
        if(casesTobeInserted.IsEmpty() == false) insert casesTobeInserted;
    }
    /*******************************************************************************
         Below Method is written for Proactive Case Creation On Secured Domain Entitlements
        *********************************************************************************/
        
        public static void ProactiveCaseForSecuredDomains(Map<Id,Id> accountEntMap){  
            List<Case> caseListToInsert = new List<Case>(); 
            Map<Id,Boolean> accountMap = new Map<Id,Boolean>();
            Datetime dt = System.now().addDays(-14);
            for(Id accId : accountEntMap.keySet()){
                accountMap.put(accId,False);
            }
            for(Case cse :[Select id,accountId from case where category__c = 'SSL Certificate' and recordtypeId =: Label.ProActiveCaseRecTypeId and createddate >:dt and accountId IN: accountEntMap.keySet()]){
                accountMap.put(cse.accountId,True);
            }
            for(Entitlement ent : [Select id,accountId,opportunity__c ,opportunity__r.Primary_Marketo_User_Lookup__c from entitlement where ID IN : accountEntMap.Values() and Opportunity__r.type IN ('Upsell/Crossell','Renewal') and Opportunity__r.stagename = 'Closed Won']){
                 if(accountMap.ContainsKey(ent.accountId) && accountMap.get(ent.accountId) != True){
                     Case proCase = new Case();
                     procase.status = 'New';
                     procase.origin = 'Internal';
                     procase.priority = 'P3';
                     procase.Problem_Type__c  = 'Account Notification';
                     procase.Category__c  = 'SSL Certificate';
                     procase.AccountId = ent.AccountId;
                     if(ent.opportunity__c != null && ent.opportunity__r.Primary_Marketo_User_Lookup__c != null) procase.contactId = ent.opportunity__r.Primary_Marketo_User_Lookup__c;
                     proCase.recordtypeId = Label.ProActiveCaseRecTypeId;
                     procase.subject = 'Activating your SSL Secured Domains for Landing Pages and/or Tracking Links';
                     procase.description = 'Your Marketo subscription includes SSL Secured Domains for Landing Pages and/or Tracking Links. To activate, we need to confirm the Munchkin ID from the Admin section on the subscription you are securing. \n\nACTION ITEM: Please reply to this email with your Munchkin ID for the instance needing SSL to begin the activation process. A Marketo technical support engineer will then respond with any next steps.\n\nThank you,';
                     procase.category__c = 'SSL Certificate';
                     procase.ownerId = Label.VishalSharmaId;
                     procase.entitlementId = ent.Id;
                     caseListToInsert.add(procase);
                 }
            }
            if(caseListToInsert != null && !caseListToInsert.isEmpty()) Database.Insert(caseListToInsert,false);
      } 
}