/**************************************************************
*Modified By: Sumit Bhatt, Grazitti Interactive
*Purpose: REF: #APPS-18580# Update Test Classes
*Tracking: One cn track the changes by searching ticket number in code

* Last modified By : Tushar Misri, Grazitti Interactive, 11th August 2018
* Purpose          : APPS-20840, Field Cleanup Project - Phase One
                     Fields which are being commented out:
                     requestedkickoffdate__c
**************************************************************/

public class Utility{
    public static Boolean isFutureUpdate = true;
    public static Boolean isAccountUpdatedFromTrigger = false;
    public static Boolean isAccountUpdatedFromAssetTrigger = false;
    public static Long updateCounter = 0;    
    public static Long updateMaxCounter = 0;
    public static Boolean isGetNumberOfEliteProductsGoingToRunOnceMore = false; 
    public static Boolean isAsset_BI_BU_AI_AUGoingToRunOnceMore = false;  
    public static Boolean isupdateUserBadgeTagGoingToRunOnceMore = false;
    public static Boolean isInsertUserInLMSGroupGoingToRunOnceMore = false;//trigger variable on user object
    public static Boolean isUpdateContactOwnerAsAccountOwnerRunningOnceMore = false;
    public static Boolean isUpdateCLSOnAccountFromClzProjectRunningOnceMore = false;
    /**USED IN ASSET TRIGGER***/
    public static Boolean DO_NOT_UPDATE_ACCOUNT_FROM_OPPTY = false;
    public static Boolean haveupdatedAccounts = false;//TO BE DELETED
    public static Boolean haveupdatedAssets   = false;
    public static Boolean isAssetTriggerExecutedFromOppty = false;
    /**USED IN ENTITLEMENT TRIGGER***/
    public static Boolean haveupdatedEntitlements = false;
    public static Boolean haveupdatedAccountsfromEntitlement = false;
    public static Boolean haveupdatedLMSEntitlement = false; 
    //USED IN OPPORTUNITYLINTEM TRIGGER
    public static Boolean isBeforeTriggerOnPLI_OnceMore = false;
    //APPS-685
    public static Boolean haveRunAlertDatanyzeUpdate = false;
    
    public static void sendEcxeptionMailToDeveloper(Exception e, String developerMail, String exceptionMessage){
       List<User> developer = new List<User>([select Id, email from user where username = 'vishals@marketo.com.fullcopy']);
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {developerMail};
       mail.setToAddresses(toAddresses);// for testing
       //if(!developer.isEmpty())
       //mail.setTargetObjectId(developer[0].Id);
       //mail.setSaveAsActivity(false);
       mail.setSubject('Please forward to ayub.a@grazitti.com::-->'+e);
       mail.setPlainTextBody(exceptionMessage+'::-->'+e);
       try{Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });}catch(exception ex){}
    
    }
    public static Account insertAccountInTestClasses(){
        Account acc = new Account(
            Name = 'Test Acc', Sales_Region__c = 'North America', Business_Unit__c = 'AMER-SB',
            BillingCity = 'NewYork',
            BillingCountry = 'United States',
            BillingStreet = 'Test Street',
            BillingState ='Test Billing State',
            BillingPostalCode ='12345',
            ShippingCity ='Chandigarh',
            ShippingCountry ='India',
            ShippingPostalCode = '12345',
            ShippingState = '',
            ShippingStreet = 'Test Shipping Street'
        );
        return acc;
    }
    public static Contact insertContactInTestClasses(Id accountId){
        Contact con = new Contact(FirstName = 'test Con', LastName = 'test Con', email='test@test.com', LeadSource = 'Blog', AccountId = accountId);
        return con ;
    }  
   
    public static Opportunity insertOpportunityInTestClasses(Id accountId, Id contactId, String stageName, string type, Date closeDate, Date masterStartDate, Date masterEndDate, Date RequestedKickoffDate){
                
        Opportunity Opp = new Opportunity(
            Name = 'test opp', 
            AccountId = accountId, 
            Type = type, 
            CloseDate = closeDate, 
            Stagename = stageName, 
            Deal_Type__c = 'Standard', 
            NextStep = 'test', CRM_System__c = 'NetSuite', 
            LeadSource = 'Blog', 
            Payment_Frequency__c ='',Payment_Terms__c='',
            Primary_Marketo_User_Lookup__c = contactId,
            Sub_Start_Date__c = masterStartDate,
            SFDC_Edition__c = 'Enterprise',
            Sub_End_Date__c = masterEndDate,
			//APPS-18580
            Rep_Create_ARR__c = 1,
			MainCompetitor__c = 'AppBoy'
			//APPS-18580		
        );
        //if(RequestedKickoffDate != null) opp.RequestedKickoffDate__c = RequestedKickoffDate;
        return opp;
    }
    
    public static Entitlement insertEntitlementInTestClasses(Id recordtype, string Type, Id accountId, Date startDate, Date enddate){
        Entitlement ent = new Entitlement();
        ent.AccountId = accountId;
        if(recordtype != null) ent.recordTypeId   = recordtype;
        ent.name           = 'Test Code Entitlement';
        ent.StartDate      = startDate;
        ent.EndDate        = endDate;
        ent.Type           = Type;
        return ent;
    }
    
    public static User insertCustomerPortalUser(Id contactId){
        Profile p = [select Id,name from Profile where UserType = 'PowerCustomerSuccess' limit 1];
        User newUser =  createTestUser(p.Id, 'testUser', 'Mkto', 'cfsId') ;
        newUser.contactId = contactId;
        return newUser;
    }         

    public static boolean checkForDatanyzeChange(string currEspSoln , string oldEspSoln, List<String> Current_Solution, List<String> Current_ExpSolution) {
        if(currEspSoln == NULL || currEspSoln.trim() == '') {
            if(oldEspSoln == NULL || oldEspSoln.trim() == '') {
                return false;
            } else {                                     
                //Set<String> oldEspValsSet1 = new Set<String>(); 
                //oldEspValsSet1.addAll(oldEspSoln.toLowerCase().split(';'));
                Set<String> oldEspValsSet = new Set<String>(); //Old not null, new null.                     
                for(string tmpstr : oldEspSoln.toLowerCase().split(';')) 
                    oldEspValsSet.Add(tmpStr.trim());                                                                
                //If old set contained the listed exp item return true else false
                if(oldEspValsSet.removeAll(Current_ExpSolution) == TRUE) return true;
            }                
        } else {
            if(oldEspSoln == NULL || oldEspSoln.trim() == '') {  //All added values are new
                Set<String> newEspValsSet = new Set<String>();                     
                for(string tmpstr : currEspSoln.toLowerCase().split(';')) 
                    newEspValsSet.Add(tmpStr.trim());                                    
                
                //If added value is in notification list
                if(newEspValsSet.removeAll(Current_Solution) == TRUE) return true;                                                                            
            } else {  //Mix of old and new values
                Set<String> newEspValsSet = new Set<String>(); 
                Set<String> oldEspValsSet = new Set<String>();
                Set<String> removedEspValsSet = new Set<String>(); 
                Set<String> addedEspValsSet = new Set<String>();
                for(string tmpstr : currEspSoln.toLowerCase().split(';')) {
                    newEspValsSet.Add(tmpStr.trim());                                    
                    addedEspValsSet.Add(tmpStr.trim());
                }               
                for(string tmpstr : oldEspSoln.toLowerCase().split(';')) {
                    oldEspValsSet.Add(tmpStr.trim());
                    removedEspValsSet.Add(tmpStr.trim());
                }
                //If nothing was added or removed
                if(newEspValsSet.equals(oldEspValsSet)) return false;               
                
                //Get list of all newly added and removed values
                addedEspValsSet.removeAll(oldEspValsSet); //remove old values from new
                removedEspValsSet.removeAll(newEspValsSet);//removed new value from old
                
                //If value exists in removed list
                if(removedEspValsSet.removeAll(Current_ExpSolution) == TRUE) return true;
                
                //If value exists in added list
                if(addedEspValsSet.removeAll(Current_Solution) == TRUE) return true;
            }
        }
        return false;
    } 
    
    public static User createTestUser(String ProfId, string fName, String lName, String cfsId) {
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User tuser = new User(  firstname = fName,
                                    lastName = lName,
                                    email = uniqueName + '@test' + orgId + '.org',
                                    Username = uniqueName + '@test' + orgId + '.org',
                                    EmailEncodingKey = 'ISO-8859-1',
                                    Alias = uniqueName.substring(18, 23),
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    LocaleSidKey = 'en_US',
                                    LanguageLocaleKey = 'en_US',
                                    ProfileId = profId,
                                    lmscons__Cornerstone_ID__c = 'cfsId'
                                    );
            return tuser;
    }       
    
    public static void sendDatanyzeNotification(Map<Id,Account> changedAccounts, Id templateId, Id FROM_EMAIL_ID) {
        try { 
            system.debug('SendDatanyzeNotify');
            List<string> receiverIds = System.Label.DataNyzeNotificationList.split(',');
            List<User> notificationReceivers = [SELECT Id, Email from User where Id in : receiverIds];  
            system.debug('SendDatanyzeNotifyEmailRecivers' + notificationReceivers );                                                  
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();            
            for(Id whatId : changedAccounts.keyset()) {
                if(System.Label.DataNyzeNotificationEnabled == 'Yes') {   
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    email.setTemplateId(templateId);
                    email.setTargetObjectId(changedAccounts.get(whatId).cam_owner__c);                    
                    email.setWhatId(whatId);
                    email.setSaveAsActivity(false);
                    email.setOrgWideEmailAddressId(FROM_EMAIL_ID);                                            
                    emails.add(email);                                                
                } else {                
                    for(User u : notificationReceivers) { 
                     system.debug('SendDatanyzeNotifyEmailReciverselses' + u );                                
                        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                        email.setTemplateId(templateId);
                        email.setTargetObjectId(u.Id);
                        email.setWhatId(whatId);
                        email.setSaveAsActivity(false);
                        email.setOrgWideEmailAddressId(FROM_EMAIL_ID);                                            
                        emails.add(email);               
                    }                
                }                
            }                                                 
            Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(emails);   
            system.debug('SendDatanyzeNot'+resultMail );       
            LIST<Messaging.SendEmailError> emailErrors ;//
            if(resultMail != null && resultMail.size() > 0){
                emailErrors = resultMail[0].getErrors();
                System.debug('Checking for Emails Error ==>'+emailErrors);
            }
            String response;
            if(resultMail != null && resultMail.size() > 0 && resultMail[0].isSuccess()) {
                response = 'Ok!! Emails Sent!';
                System.debug('Emails Sent ==>');
            }
            else {
                System.debug('Checking Emails Sent Error ==>');
                if(resultMail != null && resultMail.size() > 0)
                    response = resultMail[0].getErrors().get(0).getMessage();
            }                        
        } 
        catch(System.EmailException ex) {
            System.debug('Exception==>' + ex);
        }
    }    

}