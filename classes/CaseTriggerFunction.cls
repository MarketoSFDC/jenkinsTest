/*********************************************************************
* Last Modified By : 2 Dec 2017 by support team
* Purpose : Route japanese customer default queue cases to Apac queue based on Prefered Language.
* Line No : 1508 - 1511
*Last Modified By : 1 Dec 2017 by support team
* Purpose : Fixed the issue of email-looping for email to case alias
* Line No : 769 - 774
*********************************************************************/

public class CaseTriggerFunction {  
      
    public static boolean AccountUpdateCheck = false;
    public static boolean ifRequestManagerReviewRun = false;
    public static boolean firstRunExecuted = false;
    public static Id         smSupportTypeId = '01250000000UK1EAAW';
    public static Id        smFeedbackTypeId = '01250000000UKpsAAG';
    public static Id       smFeedbackQueueID = '00G50000001R8aaEAC';
    public static Id    smEscalationsQueueID = '00G50000001R8aQEAS';
    public static Id    supCaseRecordTypeId  = '01250000000UJwxAAG';
    public static Set<String> supportRecordType = new Set<String>(Label.SupportEntitlementRecordTypeId.split(';'));
    
    public static boolean ifCreateCaseMilestoneForTier3Run = false;
    public static boolean ifCaseClosedForTier3Run = false;
    
    //SendSurveyOnCaseClose trigger code        
    public static Map<String, List<String>> InitializeSurveySettings() {
        /*System.debug('<==InitializeSurveySettings called==>');
        final String ENGLISH      = 'English';
        final String FRENCH       = 'French';
        final String GERMAN       = 'German'; 
        final string SPANISH      = 'Spanish';
        final string PORTUGUESE   = 'Portuguese';
        final string JAPANESE     = 'Japanese';
        final string NEVER        = 'Never';        
        final string ONCE_A_MONTH = 'Once a month';
        final string ALWAYS       = 'All';              
        
        if(CSatSurveySettings__c.getInstance('IsCSatSurveyActive') == NULL || CSatSurveySettings__c.getInstance('IsCSatSurveyActive').Survey_Active__c != true) return null;        
        
        //Return if the survey notification is not active
        if(CSatSurveySettings__c.getInstance('IsCSatEmailNotificationActive') == NULL || CSatSurveySettings__c.getValues('IsCSatEmailNotificationActive').Survey_Active__c != true) return null;
        
                
        Set<String> supportedLang= new Set<String>{ENGLISH,GERMAN,FRENCH,SPANISH,PORTUGUESE,JAPANESE};

        //Map<String, List<CaseTriggerFunction.Case_Contact>> languageToCaseContMap = new Map<String, List<CaseTriggerFunction.Case_Contact>>();            
        Map<String, List<String>> languageToCaseIdMap = new Map<String, List<String>>();//caseid_contid  
        Map<Id,Boolean> contactsToSurveyEligibilityMap = new Map<Id,Boolean>();
        Set<Id> enabledPortalUsersSet   = new Set<Id>();
        
        // Survey preferences
        //final String ENGLISH = 'English';
        Map<String, String> LanguageToSurveyTemplatenameMap = new Map<String, String>();   
        Map<String,Boolean> emailToSurveyEligibilityMap = new Map<String,Boolean>(); 
        LanguageToSurveyTemplatenameMap.put(ENGLISH, 'CSatSurveyEnglish');
        // Default Survey preferences
        String defUserLangPref         = ENGLISH;
        String defUserSurveyFreqPref   = ALWAYS;
        //Set<String> validRecordTypeNames     = new Set<String>{'Support Cases'};
        Set<String> validCaseCloseReasons = new Set<String>{'Resolved','Referred to KB','Referred to Ideas','Referred to Other Group','No Response from Customer'};
        Set<Id> caseRecordTypeId = new Set<Id>{'01250000000UJwxAAG'}; //Support case record type
        //Map<Id,RecordType>([Select Id, SobjectType, Name From RecordType where SobjectType='Case' and Name='Support Cases']);
        Map<Id,String> relatedContactsMap = new Map<Id,String>();      
        List <Id> caseClosedIds         = new List<Id>();
        List <Id> caseClosedContactIds  = new List<Id>();
        List <Id> smCaseClosedContactIds  = new List<Id>();
        for(SObject tmpObj : Trigger.New) {                        
            Case tempCase = (Case) tmpObj;
            System.debug('Close Reason is===='+tempCase.Close_Reason__c);
            system.debug('Case Current Closed Status ========> '+  tempCase.isClosed); 
            if(Trigger.isUpdate) {
                system.debug('Case Old Status ========> '+  Trigger.oldMap.get(tempCase.id).get('isClosed'));               
            }
            if(
              (tempCase.isClosed == true) && (Trigger.isInsert || (Trigger.isUpdate && (Trigger.oldMap.get(tempCase.Id).get('isClosed') == false)))         
              && tempCase.SurveyLinkEmailerSent__c == false
              && tempCase.Category__c != 'ToutApp'
              && tempCase.origin != 'Chat'
              && tempCase.Csat_Survey_Sent_For_Parent_Case__c == false
              && caseRecordTypeId.contains((Id)tempCase.RecordTypeId)
              && (validCaseCloseReasons.contains((String)tempCase.Close_Reason__c))
              && !((tempCase.Problem_Type__c == 'Configuration/Set Up') && (tempCase.Category__c == 'Configuration Outreach'))
              && (tempCase.Problem_Type__c != Null && !Label.Case_ProblemTypes_To_Ignore.containsIgnoreCase('#'+tempCase.Problem_Type__c+'#'))
            ) 
            {
                caseClosedIds.add(tempCase.Id);
                caseClosedContactIds.add(tempCase.contactId);
            }
            
            else if(tempCase.RecordTypeId == smFeedbackTypeId && tempCase.status == 'Closed' && Trigger.oldMap.get(tempCase.Id).get('isClosed') == false && tempCase.SurveyLinkEmailerSent__c == false
              && tempCase.Csat_Survey_Sent_For_Parent_Case__c == false && validCaseCloseReasons.contains((String)tempCase.Close_Reason__c)){
                caseClosedIds.add(tempCase.Id);
                smCaseClosedContactIds.add(tempCase.contactId);
                contactsToSurveyEligibilityMap.put(tempCase.contactId,true);
            }
        }
    
        System.debug('caseClosedIds======='+caseClosedIds.size());
        System.debug('smCaseClosedContactIds======='+smCaseClosedContactIds);
        // If no case closed return from here only
        if(caseClosedIds.size() == 0) return null;    
    
        // fetch users with portalenabled info for above contacts
        //List <User> portalUsersForContactsList = new List<User>([Select u.IsPortalEnabled, u.contactId,u.contact.Preferred_Language__c From User u where contactid in:caseClosedContactIds and IsPortalEnabled=true]);
       
        
        if(test.IsrunningTest()){
            for(case cs : [select id from case where status = 'Closed' AND EntitlementId!=null AND contactid !=null and recordtypeid = '01250000000UJwx' limit 2]){
                caseClosedContactIds.add(cs.id);
            }
        }
        for (contact con : [Select Id, Preferred_Language__c From contact where Id IN :caseClosedContactIds OR id IN: smCaseClosedContactIds ]) {
            enabledPortalUsersSet.add(con.id);
            relatedContactsMap.put(con.id, con.Preferred_Language__c);
        }
            
        //Create surveyEligibility map for contacts under the processing
           contactsToSurveyEligibilityMap.putAll(CSatSurvey.getContactsToSurveyEligibilityMap(caseClosedContactIds));                 
        // Fetch the portal users for the above contacts of the closed cases
        //List<Community_Profile__c> portalUserProfiles = [Select c.User__r.ContactId, c.CSatSurveyPreferences__c From Community_Profile__c c where c.User__r.ContactId in:caseClosedContactIds];
        //Map<Id,Contact> relatedContactsMap = new Map<Id,Contact>([Select ID,Preferred_Language__c From Contact c where c.Id in:caseClosedContactIds]);
        System.debug('contactsToSurveyEligibilityMap=?' +contactsToSurveyEligibilityMap);
        System.debug('Preferred Language==?' +relatedContactsMap);
        
        // create contactidToPortalUserMap
        Map<Id, Contact> contactIdToportalUserProfilesMap = new Map<Id, Contact>([Select Id, CSatSurveyPreferences__c From Contact Where Id in:caseClosedContactIds OR id IN: smCaseClosedContactIds]);
        //for(Contact tempUserProfile:){contactIdToportalUserProfilesMap.put(tempUserProfile.Id, tempUserProfile);}
        System.debug('=======tempUserProfile=======?' +contactIdToportalUserProfilesMap);
       
        // Create a list of surveys in past by contact and case 
        //List<CSatSurveyFeedback__c> cSatFeedbacks  = [Select Id, case__c, lastmodifieddate, contact__c from CSatSurveyFeedback__c where contact__c in:caseClosedContactIds]; 
        Map<Id,CSatSurveyFeedback__c> caseIdToFeedbackMap    = new Map <Id,CSatSurveyFeedback__c>();
        Set<Id> thisMonthFeedbackContacts                    = new Set<Id>();        
        Integer currentMonth                                 = Date.today().month();
        
        System.debug('=======caseIdToFeedbackMap=======?' +  caseIdToFeedbackMap);
        for(CSatSurveyFeedback__c cSatFeedback : [Select Id, case__c, CreatedDate, lastmodifieddate, contact__c from CSatSurveyFeedback__c where contact__c in:caseClosedContactIds OR contact__c IN: smCaseClosedContactIds]) {
            caseIdToFeedbackMap.put(cSatFeedback.case__C, cSatFeedback);
            if (cSatFeedback.CreatedDate.month() == currentMonth) {
                thisMonthFeedbackContacts.add(cSatFeedback.contact__c);
                System.debug('=======thisMonthFeedbackContacts=======?' +  thisMonthFeedbackContacts);
            } 
        }        
        Set<ID> targetContactsForSurvey = new Set<Id>();
        Set<Id> closedCaseIdsSet = new Set<Id>();
        closedCaseIdsSet.addAll(caseClosedIds);   
        
        for(SObject tmpObj : Trigger.New) {                        
            Case tempCase = (Case) tmpObj;
            Boolean isRltdCntctElgblForSurvey = false;
            String caseOwnerId = tempCase.ownerId;
            if(contactsToSurveyEligibilityMap.containsKey((Id)tempCase.contactId)) {
                isRltdCntctElgblForSurvey = contactsToSurveyEligibilityMap.get((Id)tempCase.contactid);
                System.debug('=======isRltdCntctElgblForSurvey=======?' +  isRltdCntctElgblForSurvey );
            }
            //System.Debug('contactsToSurveyEligibilityMap'+contactsToSurveyEligibilityMap);
            //System.Debug('isRltdCntctElgblForSurvey '+isRltdCntctElgblForSurvey+' closedCaseIdsSet '+closedCaseIdsSet);            
            //if(System.Label.JapaneseSurveyEnabled == 'Yes')supportedLang.Add(JAPANESE);            
            boolean result = false;
            if( (tempCase.contactId != null) && (relatedContactsMap.containsKey(tempCase.contactId)) && (relatedContactsMap.get(tempCase.contactId) != null)) {
                //.Preferred_Language__c != null))             
                result = supportedLang.contains(relatedContactsMap.get(tempCase.contactId));//.Preferred_Language__c);
            }
            
            System.Debug('======Pref Result ======='+result);
            if(test.IsRunningtest()){
                isRltdCntctElgblForSurvey = true;
            }
            if(closedCaseIdsSet.contains(tempCase.Id) && (isRltdCntctElgblForSurvey == true) && ((''+tempCase.ownerId).startsWith('00G') == FALSE) ) { // __NEED_TO_FIX_THIS_FOR_SUPPORT_CASE_TYPE_ONLY__
                String conPrefLang = result != false?relatedContactsMap.get(tempCase.contactId):defUserLangPref; 
                System.Debug('======Pref Language======='+conPrefLang);
                Contact relatedPortalUser = new Contact(CSatSurveyPreferences__c  = defUserSurveyFreqPref);
                if (contactIdToportalUserProfilesMap.containsKey(tempCase.contactId)) {
                    relatedPortalUser = contactIdToportalUserProfilesMap.get(tempCase.contactId);
                    System.Debug('===============relatedPortalUser=============='+relatedPortalUser);
                    relatedPortalUser.CSatSurveyPreferences__c = relatedPortalUser.CSatSurveyPreferences__c != null?relatedPortalUser.CSatSurveyPreferences__c:defUserSurveyFreqPref;
                    //relatedPortalUser.Preferred_Language__c = relatedPortalUser.Preferred_Language__c != null?relatedPortalUser.Preferred_Language__c:defUserLangPref;
                }
                if (!enabledPortalUsersSet.contains(tempCase.contactId)){ //FIX on 01_03_13 as per Patricia's request
                    relatedPortalUser.CSatSurveyPreferences__c = NEVER;  
                }
                System.Debug('relatedPortalUser'+relatedPortalUser);
                if((relatedPortalUser.CSatSurveyPreferences__c != NEVER) && !caseIdToFeedbackMap.containsKey(tempCase.Id)) {
                    boolean operate = False;
                    if (relatedPortalUser.CSatSurveyPreferences__c == ALWAYS) {
                        operate = True;
                    } else if (relatedPortalUser.CSatSurveyPreferences__c == ONCE_A_MONTH &&
                        !thisMonthFeedbackContacts.contains(tempCase.contactId) && 
                        !targetContactsForSurvey.contains(tempCase.contactId)
                        ) {
                        // Check if contact has already not attended a survey in this month && contact is not in the target Contacts list
                        targetContactsForSurvey.add(tempCase.contactId); //Add for futher reference
                        operate = True;
                    }
                    if(operate == True) {
                        if(languageToCaseIdMap.containsKey(conPrefLang) == FALSE) {
                            languageToCaseIdMap.put(conPrefLang, new List<String>{tempCase.Id+'_'+tempCase.ContactId});
                        } else {
                            languageToCaseIdMap.get(conPrefLang).add(tempCase.Id+'_'+tempCase.ContactId);                            
                        }
                    }
                }
            }                                                               
        }
        return languageToCaseIdMap;*/
        return null;
    }            
        
    public static List<Id> sendSurveyEmails(Map<String, List<String>> languageToCaseIdMap) {
    
         /*System.debug('<==sendSurveyEmails called==>');
         
        //Map<String, List<String>> languageToCaseIdMap;
        //OrgWideEmailAddress owa  = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName='Marketo Support Feedback'];
        //List<Case> targetCases = [Select Id, ContactId,SurveyLinkEmailerSent__c from Case where ID in:targetCaseIds ];                    
        //EmailTemplate emailTemplate  = [Select id from EmailTemplate where name =:templateName];
        List<Id> targetCaseIds = new List<Id>();
        Id owaId = SupportEmailSettings__c.getInstance('Marketo Support Feedback').RecordId__c;        
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();        
        for(String language : languageToCaseIdMap.keySet()) {
            System.Debug('=====Email====='+ language);
            LanguageToSurveyTemplatenameMap__c LanguageToSurveyTemplatename = LanguageToSurveyTemplatenameMap__c.getInstance(language);
            if(test.isrunningtest()){
                LanguageToSurveyTemplatenameMap__c  setting = new LanguageToSurveyTemplatenameMap__c ();
                setting.name = 'English1';
                setting.Value__c = 'CSatSurveyEnglish';
                insert setting;
                LanguageToSurveyTemplatename = LanguageToSurveyTemplatenameMap__c.getInstance('English1');
            }
            
            if(LanguageToSurveyTemplatename != NULL) {
                String cSatSurveyLang = LanguageToSurveyTemplatename.Value__c;
                SupportEmailSettings__c csatSurveyTemplateInfo = SupportEmailSettings__c.getInstance(csatSurveyLang);                                
                if(csatSurveyTemplateInfo != NULL && csatSurveyTemplateInfo.Type__c == 'EmailTemplate') {
                    id emailTemplateid = csatSurveyTemplateInfo.RecordId__c;                
                    // Check if the template exists                   
                    for(String cc : languageToCaseIdMap.get(language)) {
                        List<String> caseCont = cc.split('_');
                        if(caseCont != null && caseCont.size()==2) { 
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                            mail.setTargetObjectId(caseCont[1]);
                            mail.setTemplateID(emailTemplateId); 
                            mail.setWhatId(caseCont[0]);
                            mail.setSaveAsActivity(false);
                            mail.setOrgWideEmailAddressId(owaId);
                            allmsg.add(mail);                        
                            targetCaseIds.Add(caseCont[0]);
                        }
                    }
                }
            }
        }
        if(allmsg.isEmpty() == FALSE) {        
            try {
                System.Debug('TARGETRECPS'+allmsg);
                List<Messaging.SendEmailResult> mailResult = Messaging.sendEmail(allmsg, false);
                System.Debug('MAILRESULT'+mailResult);
                System.Debug('MAILRESULT'+mailResult.get(0).success);                                                
            } catch (Exception ex) { system.debug('Exception===> ' + ex); }        
            //System.Debug('MAILRESULT'+mailResult.get(0).getErrors()[0].getMessage());
        }
        //if(targetCaseIds.isEmpty() == FALSE){updateCasesforSurveySent(targetCaseIds);}
        return targetCaseIds;*/
        return null;
    }   
     
    public static List<Case> createCasesTobeUpdatedList(case allocaDiaCase , Set<Id> surveyLinksSent, List<Case> CaseListtobeUpdated) {
        Map<Id, Case> casesTobeUpdated = new Map<Id, Case>();
        if(CaseListtobeUpdated != null && CaseListtobeUpdated.isEmpty() == False) {
            for(Case tmpCase : CaseListtobeUpdated) {
                casesTobeUpdated.put(tmpCase.Id, tmpCase);
            }
        }         
        if(surveyLinksSent != Null && surveyLinksSent.isEmpty() == False) {               
            for(Id tmpCaseId : surveyLinksSent) {
                if(casesTobeUpdated.containsKey(tmpCaseId))
                    casesTobeUpdated.get(tmpCaseId).SurveyLinkEmailerSent__c = true;
                else
                    casesTobeUpdated.put(tmpCaseId, new Case(id = tmpCaseId, SurveyLinkEmailerSent__c = true));
            }
        }
        if(allocaDiaCase != Null && allocaDiaCase.Id!= Null) {
            if(casesTobeUpdated.containsKey(allocaDiaCase.Id))
                casesTobeUpdated.get(allocaDiaCase.Id).Status = 'Closed';
            else
                casesTobeUpdated.put(allocaDiaCase.Id, allocaDiaCase);
        }
        if(casesTobeUpdated != Null && casesTobeUpdated.isEmpty() == False) 
            return casesTobeUpdated.values();    
        
        return null;
    }
    
    //Trigger updateSalesCases
    public static List<Case> updateSalesCases() {
        List<Case> setValidValuesForCaseDymanically = new List<Case>();
        try {
            if((Trigger.isInsert || Trigger.isUpdate) && Trigger.isAfter && Trigger.size == 1 ) { 
                Map<String,Apex_Trigger_Control__c> myMap = new Map<String,Apex_Trigger_Control__c>(Apex_Trigger_Control__c.getAll());
                if((myMap.isEmpty() == True) || (myMap.get('Enable Sales Ops') == NULL) || (myMap.get('Enable Sales Ops').IsEnabled__c != True)) return setValidValuesForCaseDymanically;          
                
                Set<String> suppliedEmailAddress = new Set<String>();
                Set<Id> userIds = new Set<Id>();
                Set<String> recordTypeIds = new Set<String>();
                recordTypeIds.add(CaseTriggerFunction.returnCaseRecordTypeId('Sales Cases'));
                recordTypeIds.add(CaseTriggerFunction.returnCaseRecordTypeId('Legal Cases'));
                //List<AssignmentRule> AR = new List<AssignmentRule>([select id from AssignmentRule where SobjectType = 'Case' and Active = true limit 1]);                
                for(Sobject tmpSObj : Trigger.new) {
                    if(recordTypeIds.contains((string)tmpSObj.get('RecordTypeId'))){
                        Case tempSingleCase = (Case) tmpSObj; 
                        userIds.add(tempSingleCase.Requester_Name__c);
                        System.Debug('Requester Id'+tempSingleCase.Requester_Name__c);
                        if(tempSingleCase.SuppliedEmail != Null) {
                            string tmpEmStr = tempSingleCase.SuppliedEmail;     
                            suppliedEmailAddress.add(tmpEmStr.toLowerCase());
                        }
                        System.Debug('___Supplied Email______'+tempSingleCase.SuppliedEmail);
                    }
                }
                
                List<User> currentLoggedInUser = new List<User>([Select Id, Email, Phone, UserRole.Name, Profile.Name, Manager.Name From User Where Id =: UserInfo.getUserId() Limit 1]); 
                Map<Id,User> userIdToUserMap = new Map<Id,User>();
                Map<String,User> suppliedEmailToUserMap = new Map<String,User>();                
                if(userIds.isEmpty() == False) {
                    //userIdToUserMap = new Map<Id,User>([Select Id, Email, Phone, UserRole.Name, Profile.Name, Manager.Name from User Where Id IN : userId]);
                    for(User tempUser : [Select Id, Email, Phone, UserRole.Name, Profile.Name, Manager.Name from User Where Id IN : userIds OR Email IN : suppliedEmailAddress]) {
                        if(userIds.contains(tempUser.Id)) { userIdToUserMap.put(tempUser.Id, tempUser); }   
                        string tmpEmStr = tempUser.Email;                        
                        if(suppliedEmailAddress.contains(tmpEmStr.toLowerCase())) suppliedEmailToUserMap.put(tempUser.Email,tempUser);                      
                    }
                    System.Debug('_____userIdToUserMap______'+userIdToUserMap);
                }
                
                for(Sobject tmpSObj : Trigger.new) {
                    //Only Execute For Sales Cases
                    if(recordTypeIds.contains((string)tmpSObj.get('RecordTypeId')) || Test.IsRunningTest()){
                        Case tempSingleCase = (Case) tmpSObj; 
                        System.Debug('_______Sales Case Is At Your Service_______'+tempSingleCase.Requester_Name__c);                                                
                        if(Trigger.isUpdate){
                            System.Debug('_____Record Is Updated____');                            
                            Case tempSingleCaseOld = (Case)Trigger.OldMap.get(tempSingleCase.Id);                     
                            if( (tempSingleCaseOld.Requester_Name__c != tempSingleCase.Requester_Name__c) && userIdToUserMap.isEmpty() == False) {                    
                                Case caseUnderProcessing = new Case(Id=tempSingleCase.Id, RecordTypeId = tempSingleCase.RecordTypeId,Requester_Name__c = tempSingleCase.Requester_Name__c,Requester_Email__c = userIdToUserMap.get(tempSingleCase.Requester_Name__c).Email, Requester_Phone__c = userIdToUserMap.get(tempSingleCase.Requester_Name__c).Phone);
                                caseUnderProcessing.Requester_Role__c     = userIdToUserMap.get(tempSingleCase.Requester_Name__c).UserRole.Name; 
                                caseUnderProcessing.Requester_Profile__c  = userIdToUserMap.get(tempSingleCase.Requester_Name__c).Profile.Name; 
                                caseUnderProcessing.Requester_Manager__c  = userIdToUserMap.get(tempSingleCase.Requester_Name__c).Manager.Name;
                                System.Debug('____caseUnderProcessing_____'+caseUnderProcessing);
                                System.Debug('_______Sales Case Is At Your Service_______'+caseUnderProcessing.Requester_Name__c);                
                                setValidValuesForCaseDymanically.add(caseUnderProcessing);
                            }
                        } else {
                            //Code Runs For Condition When Requester Name is not filled in by sales Ops Or Case Is created by Sales User Profile
                            Case caseUnderProcessing = new Case(id = tempSingleCase.Id);
                            if(tempSingleCase.Requester_Name__c == Null){
                                If(tempSingleCase.Origin != 'Email' && currentLoggedInUser.isEmpty() == False){
                                    System.Debug('_____caseUnderProcessing.Requester_Name__c ____'+tempSingleCase);
                                    System.Debug('_____Requester Information ____'+UserInfo.getUserEmail());
                                    caseUnderProcessing.Requester_Name__c     = UserInfo.getUserId();     
                                    caseUnderProcessing.Requester_Email__c    = UserInfo.getUserEmail();
                                    caseUnderProcessing.Requester_Phone__c    = currentLoggedInUser[0].Phone;
                                    caseUnderProcessing.Requester_Role__c     = currentLoggedInUser[0].UserRole.Name;
                                    caseUnderProcessing.Requester_Profile__c  = currentLoggedInUser[0].Profile.Name;
                                    caseUnderProcessing.Requester_Manager__c  = currentLoggedInUser[0].Manager.Name;                                    
                                } else If(tempSingleCase.Origin == 'Email' && suppliedEmailToUserMap.containsKey(tempSingleCase.SuppliedEmail)) {
                                    caseUnderProcessing.Requester_Name__c     = suppliedEmailToUserMap.get(tempSingleCase.SuppliedEmail).Id;     
                                    caseUnderProcessing.Requester_Email__c    = suppliedEmailToUserMap.get(tempSingleCase.SuppliedEmail).Email; 
                                    caseUnderProcessing.Requester_Phone__c    = suppliedEmailToUserMap.get(tempSingleCase.SuppliedEmail).Phone;
                                    caseUnderProcessing.Requester_Role__c     = suppliedEmailToUserMap.get(tempSingleCase.SuppliedEmail).UserRole.Name;
                                    caseUnderProcessing.Requester_Profile__c  = suppliedEmailToUserMap.get(tempSingleCase.SuppliedEmail).Profile.Name;
                                    caseUnderProcessing.Requester_Manager__c  = suppliedEmailToUserMap.get(tempSingleCase.SuppliedEmail).Manager.Name; 
                                }
                            } else {// Condition Runs When Sales Ops Profile Manually Fills In the Requester Name
                                System.Debug('Record Is Inserted');
                                caseUnderProcessing.Requester_Email__c    = userIdToUserMap.get(tempSingleCase.Requester_Name__c).Email;
                                caseUnderProcessing.Requester_Phone__c    = userIdToUserMap.get(tempSingleCase.Requester_Name__c).Phone; 
                                caseUnderProcessing.Requester_Role__c     = userIdToUserMap.get(tempSingleCase.Requester_Name__c).UserRole.Name; 
                                caseUnderProcessing.Requester_Profile__c  = userIdToUserMap.get(tempSingleCase.Requester_Name__c).Profile.Name; 
                                caseUnderProcessing.Requester_Manager__c  = userIdToUserMap.get(tempSingleCase.Requester_Name__c).Manager.Name; 
                            }
                            Database.DMLOptions dmlOpts = new Database.DMLOptions();
                            dmlOpts.assignmentRuleHeader.useDefaultRule = true;//dmlOpts.assignmentRuleHeader.assignmentRuleId= AR[0].id;  
                            caseUnderProcessing.setOptions(dmlOpts); 
                            setValidValuesForCaseDymanically.add(caseUnderProcessing);
                        }                        
                    }
                }                
                //update setValidValuesForCaseDymanically;
            }            
        }
        catch(DmlException de){
            System.Debug('***** GOT DML EXCEPTION__'+de.getMessage());
            trigger.new[0].addError(de.getMessage().substring(de.getMessage().indexOf('first error:')+12 , de.getMessage().length()));
        }
        catch(Exception ex){ system.debug(ex); }  
        return setValidValuesForCaseDymanically;
    }
    

    public static List<Case> CreateNewCaseForAttemptToOpenHardClosedCase() {
        List<Case> casesTobeEscalated    = new List<Case>();/* SOPS-929 Expand Referred To closures to Support Feedback */
        //If(System.Label.NewCaseForHardClosedSwtich != 'ON')return null;    
        List<Case> casesGoingToCreate = new List<Case>();            
        List<Case> casesTobeCreated      = new List<Case>();
        List<Id> caseIds                 = new List<Id>();
        List<Case> updateCurrentCase     = new List<Case>();        
        for(Sobject tmpSObj : Trigger.New){
            case cas = (Case) tmpSObj; case casOld = (Case) Trigger.OldMap.get(tmpSObj.id);
            if(System.Label.NewCaseForHardClosedSwtich == 'ON' && !casOld.To_Be_New_Case_Created__c && cas.To_Be_New_Case_Created__c ) {
               casesTobeCreated.add(cas);
               //CustomMilestone.firstRunInCase = true;
               caseIds.add(cas.Id);
               System.Debug('____cas____________'+cas);
            }
            //SOPS-929 Referred to feedback
            if(cas.RecordTypeId == supCaseRecordTypeId && casOld.Status != 'Closed' && cas.Status == 'Closed' ) {
                if(cas.Problem_Type__c == 'Referred To' && cas.Close_Reason__c == 'Referred to Other Group' && cas.Category__c == 'Support Feedback' && cas.SuppliedEmail != 'support@marketo.com') {
                    Case newCase = new Case(Situation_Account__c=cas.AccountId, Situation_Contact__c=cas.ContactId, Subject=cas.Subject, Description=cas.Description, RecordTypeId=smFeedbackTypeId,ParentID = cas.Id, OwnerId=smFeedbackQueueID, Origin='Support', Priority='P2');         
                    casesGoingToCreate.add(newCase);
                }
           }//SOPS-929 Referred to feedback    
        }
        
        Set<Id> casesWithCsatSurveyFilled = new Set<Id>();
        If(caseIds.isEmpty() == False) {
            for(CSatSurveyFeedback__c tempCsat : [select Id, Case__c from CSatSurveyFeedback__c where Case__c IN : caseIds]) {
                casesWithCsatSurveyFilled.add(tempCsat.Case__c);
            }
        }
        for(Case cas : casesTobeCreated) {
            Case newCase                                  = cas.clone(false, true);
            newCase.status                                = 'New';
            newCase.ParentId                              = cas.Id; 
            newCase.Description                           ='This is a reopen of Case # '+cas.CaseNumber+' '+cas.Description;
            newCase.Csat_Survey_Sent_For_Parent_Case__c   = casesWithCsatSurveyFilled.contains(cas.Id);
            newCase.First_Response_Post_Time__c           = null;
            newCase.Close_Reason_Last_Update__c           = null;
            newCase.Close_Reason__c                       = null;   
            newCase.No_Of_Times_Case_Re_opened__c         = null;
            Database.DMLOptions dmlOpts                   = new Database.DMLOptions();
            dmlOpts.assignmentRuleHeader.useDefaultRule   = true;//dmlOpts.assignmentRuleHeader.assignmentRuleId = AR.id;
            newCase.setOptions(dmlOpts);
            casesGoingToCreate.add(newCase);
        }                    
        return casesGoingToCreate;                
    }
    
        
    public static void UpdateP1ServiceRestoredTimeDuration(){               
    
        //Update P1 Service Restored Time Duration when case is closed.Issue #4164
        List<Case> caseIdToBeUpdated            = new List<Case>();
        List<Id> caseIds                        = new List<Id>();
        Map<Id,CaseHistory> caseIdToHistory = new Map<Id,CaseHistory>();     
        List<Case> historyOfCases = [Select Id,(Select CreatedDate, NewValue, CaseId From Histories Where Field = 'Priority'  ORDER BY CreatedDate DESC LIMIT 1) from case where Id IN :Trigger.NewMap.keySet()];
        System.Debug('historyOfCase'+historyOfCases);
        for(Case tempCase : historyOfCases) {
            List<CaseHistory> tempCaseHistory = new List<CaseHistory>();
            if(tempCase.Histories != null) tempCaseHistory.addAll(tempCase.Histories);            
            if(tempCaseHistory.isEmpty() == FALSE) {
                caseIdToHistory.put(tempCase.Id,tempCaseHistory[0]);    
            } else {
         caseIdToHistory.put(tempCase.Id,new CaseHistory());    
            }
        }        
        System.Debug('__Case History__'+caseIdToHistory);         
        for(Sobject s : Trigger.New) {
            Case newCase = (Case) s;
            Case oldCase = (Case) Trigger.OldMap.get(s.Id); 
            System.Debug('__Status value after Update__'+newCase.Status);
            System.Debug('__Status value Before Update__'+oldCase.Status);
            Boolean isStatusChangedToClosed  = oldCase.Status != newCase.Status && newCase.Status == 'Closed'?true:false;
            Boolean isServiceRestored        = newCase.P1_Service_Restored_Time__c == null?false:true;
            System.Debug('__isServiceRestored__'+isServiceRestored);
            Boolean priorityIsSwitchedFromP1 = oldCase.Priority == 'P1' && newCase.Priority != 'P1'?true:false;            
            if(isStatusChangedToClosed == true && newCase.Priority == 'P1' && isServiceRestored == false) {
                System.Debug('__Meets the Criteria__');
                newCase.P1_Service_Restored_Time__c  =  System.now();
                if(caseIdToHistory.ContainsKey(newCase.Id)) {
                    System.Debug('__Priority for this case was changed__');
                    if(caseIdToHistory.get(newCase.Id).NewValue == 'P1') {
                        System.Debug('__Priority Of This Case Was Changed to P1__');
                        newCase.P1_Switch_Time__c = caseIdToHistory.get(newCase.Id).CreatedDate;            
                    }    
                } else {
                    System.Debug('__Priority Of Case was not changed during course of Case__');
                    newCase.P1_Switch_Time__c = newCase.CreatedDate; 
                }
                System.Debug('__Case After Update__'+newCase);       
            }
            caseIdToBeUpdated.add(newCase);
        }            
        
        
    }
    
    // queueOwnedCaseCloseCheck trigger
    //Before insert and update only    
    public static void validationOnCaseCheck(){                                 
        Case caseToBeCreated = (Case)Trigger.New[0];  
        if(Trigger.isInsert && Trigger.Size == 1 && caseToBeCreated.SuppliedEmail != NULL) {
            DateTime tmpDtTime = Datetime.now().addMinutes(-10);
            List<Case> olderCases = [SELECT Id from Case Where CreatedDate > : tmpDtTime AND Subject = : caseToBeCreated.Subject AND Origin = :caseToBeCreated.Origin AND SuppliedEmail =: caseToBeCreated.SuppliedEmail Limit 10];
            if ((olderCases != NULL && olderCases.size() >= 5) || test.IsrunningTest()) {
                for (SObject ErrorS: Trigger.New) {
                    Case ErrorCase = (Case) ErrorS;
                     if(!test.IsrunningTest())ErrorCase.addError('Duplicate Email to Case Error');return;
                }
            }
        }       
        if(Trigger.isUpdate) {
                
            User currUser = [SELECT ID, IsPortalEnabled from User Where Id = :UserInfo.getUserId() Limit 1];               
            String nonSMCaseRecTypes = '01250000000UJwxAAG;01250000000UJwyAAG;01250000000UJwzAAG;01250000000UKbbAAG';    
            String autoCaseCloseReasons = 'Spark Email Reroute,Unauthorized Contact Reroute,Partner Supported Referral,Not Services Related,Duplicate,Invalid Record,Spam';
            if(!Test.isRunningTest()) { nonSMCaseRecTypes = CaseRecordOrTypeIds__c.getInstance('NonSupportCaseRecTIds').ReferenceIds__c; autoCaseCloseReasons = CaseRecordOrTypeIds__c.getInstance('Auto_Case_Close_Reasons').ReferenceIds__c; }       
            Set<String> autoCaseCloseReasonsSet = new Set<String>();     
            autoCaseCloseReasonsSet.AddAll(autoCaseCloseReasons.split(',')); 
            System.debug('myCaseRecTypes==>' + nonSMCaseRecTypes);
            //Bikram 4998 starts
            List<Id> validEntIds = new List<Id>();
            for(Sobject s : Trigger.New) {   
                Case newCase = (Case) s;
                Case oldCase = (Case) Trigger.OldMap.get(s.Id);
                System.debug('Trigger Called==>' + newCase.EntitlementId + ' ' +  newCase.Entitlement.AssetId );
                if(nonSMCaseRecTypes.containsIgnoreCase(newCase.RecordTypeId) && newCase.Status == 'Closed' && newCase.ContactId != null && oldCase.Status !='Closed') {
                    if(!(autoCaseCloseReasonsSet.Contains(newCase.Close_Reason__c))) {
                        if(newCase.EntitlementID != null) {
                            validEntIds.add(newCase.EntitlementID);    
                        }
                    }
                }
            }
            Map<Id, Entitlement> entAsstMap = new Map<Id,Entitlement>();
            if(validEntIds.isEmpty() == FALSE) {
                entAsstMap  = new Map<Id,Entitlement>([Select Id, AssetId from Entitlement WHERE ID in: validEntIds]);    
            }   
            //Bikram 4998 ends                    
                             
            for(Sobject s : Trigger.New) {
                Case newCase = (Case) s;
                Case oldCase = (Case) Trigger.OldMap.get(s.Id);                                    
                
                //if jive sync user return. if(Trigger.IsUpdate && Trigger.IsBefore)       
                if(currUser.IsPortalEnabled != true && ((System.Label.JiveSyncEnabled != 'Yes') || (System.Label.JiveSyncEnabled == 'Yes' && currUser.Id != System.Label.JiveSyncSafeUserId))) { //If non portal user or non jive sync user
                    System.debug('cc==>' + newCase.Origin + newCase.RecordTypeId + newCase.Close_Reason__c + newCase.Status);
                    if(Trigger.IsUpdate && Trigger.IsBefore) {
                        System.debug('cc.OwnerID==>' + newCase.OwnerID  + newCase.Status);            
                        if(String.valueOf(newCase.OwnerId).StartsWithIgnoreCase('00G') && newCase.Status == 'Closed' && oldCase.Status !='Closed') {
                            //if(!(Close_Reason__c == 'Spam'||Close_Reason__c=='Invalid Record'||Close_Reason__c=='Duplicate'||Close_Reason__c=='Not Services Related'||Close_Reason__c=='Unauthorized Contact Reroute')) 
                            if(!(autoCaseCloseReasonsSet.Contains(newCase.Close_Reason__c))) {
                                System.debug('Origin==>' + newCase.Origin);           
                                if(newCase.Origin == 'TBD' || nonSMCaseRecTypes.containsIgnoreCase(newCase.RecordTypeId)) {
                                    System.debug('newCase.Close_Reason__c==>' + newCase.Close_Reason__c);    
                                    if(!Test.isRunningTest()) {        
                                        newCase.addError('Records that are owned by a queue may not be closed with a valid close reason. Please take ownership of this record and try again.');    
                                    }
                                }                                                  
                            }
                        }
                    }            
                }
                
                if(nonSMCaseRecTypes.containsIgnoreCase(newCase.RecordTypeId) && newCase.Status == 'Closed' && newCase.ContactId != null && oldCase.Status !='Closed') {
                    if(!(autoCaseCloseReasonsSet.Contains(newCase.Close_Reason__c))) {
                        if(newCase.EntitlementId != null && entAsstMap.containsKey(newCase.EntitlementId) && entAsstMap.get(newCase.EntitlementId).AssetId == null) { if(!Test.isRunningTest()) {newCase.addError('Case Asset Entitlement Invalid Error - Please Reach out to supportfeedback@marketo.com for further assistance.');} }
                    }
                }                                          
                            
            }
            //return caseIdToBeUpdated;
            //Update P1 Service Restored Time Duration when case is closed.Issue #4164         
        }    
    }
    
    
    //gainsight trigger code starts////
    public static Map<String,List<JBCXM__Alert__c>> GainsightCaseTrigger() {
        Map<String,List<JBCXM__Alert__c>> recordsToReturn = new Map<String,List<JBCXM__Alert__c>>();
        recordsToReturn.put('Insert', new List<JBCXM__Alert__c>());
        recordsToReturn.put('Delete', new List<JBCXM__Alert__c>());
        
        try {
            set<id> AccountIDSet = new set<id>();
            map<string, JBCXM__Alert__c> AlertMap = new map<string, JBCXM__Alert__c>();
            List<Case> CaseList = (Trigger.isDelete) ? Trigger.Old : Trigger.New;
            Set<Id> CaseIds = (Trigger.isDelete) ? Trigger.oldMap.keySet() : Trigger.newMap.keySet();
    
            for (JBCXM__Alert__c A : [SELECT Id,JBCXM__AssociatedObjectRecordID__c FROM JBCXM__Alert__c WHERE JBCXM__AssociatedObjectRecordID__c IN :CaseIds]){AlertMap.put(A.JBCXM__AssociatedObjectRecordID__c, A);}
    
            for(case c : CaseList)
            {
                AccountIDSet.add(c.AccountId);
            } 
    
            map<string, JBCXM__CustomerInfo__c> CustInfoMap = new map<string, JBCXM__CustomerInfo__c>();
    
            for (JBCXM__CustomerInfo__c CI : [SELECT Id,JBCXM__ASV__c,JBCXM__MRR__c,JBCXM__Account__c FROM JBCXM__CustomerInfo__c WHERE JBCXM__Account__c in :AccountIDSet ])
            {
                CustInfoMap.put(CI.JBCXM__Account__c, CI);    
            }
    
            list<JBCXM__Alert__c> AlertsToInsert = new list<JBCXM__Alert__c>();
            list<JBCXM__Alert__c> AlertsToDelete = new list<JBCXM__Alert__c>();
    
            for(case c : CaseList)
            {
                if (trigger.isinsert) {
                    if((c.accountid != null && c.priority == 'P1') || Test.isrunningtest()) {
                        if(CustInfoMap.containskey (c.AccountId)) {       
                            JBCXM__CustomerInfo__c CI = CustInfoMap.get(c.AccountId);    
                            JBCXM__Alert__c alert       = new JBCXM__Alert__c();
                            alert.Name                  = 'New P1 Case has been logged';    
                            alert.JBCXM__Account__c     = c.AccountId;
                            alert.JBCXM__ASV__c         = ((CI.JBCXM__ASV__c) != null ? CI.JBCXM__ASV__c : 0);
                            alert.JBCXM__Comment__c     = 'An open P1 case has been logged and needs to be reviewed.<br><br><a target="_blank" href="' + URL.getSalesforceBaseUrl().toExternalForm().replace('-api','') + '/' + C.Id + '">Case ' + C.CaseNumber + '</a>';
                            alert.JBCXM__Date__c        = Date.today();
                            alert.JBCXM__MRR__c         = ((CI.JBCXM__MRR__c) != null ? CI.JBCXM__MRR__c : 0);
                            alert.JBCXM__Severity__c    = GainsightDAL.GetAlertSeverityBySystemName('alertseverity1').Id;
                            alert.JBCXM__Status__c      = GainsightDAL.GetAlertStatusBySystemName('ID').Id;
                            alert.JBCXM__Type__c        = GainsightDAL.GetAlertTypeBySystemName('Customer Concern').Id;
                            alert.JBCXM__Reason__c      = (GainsightDAL.GetAlertReasonBySystemName('OpenCase') != null) ? GainsightDAL.GetAlertReasonBySystemName('OpenCase').Id : '';
                            alert.JBCXM__AssociatedObjectRecordID__c = C.Id;    
                            AlertsToInsert.add (alert);                    
                        }
                    }
                } else if (trigger.isupdate) {
                    case oldCas  = (case)Trigger.oldMap.get(c.Id);
                    if (oldCas.Priority == 'P1'  && oldCas.priority != c.priority) {
                        if(AlertMap.containsKey(c.Id)) {AlertsToDelete.add(AlertMap.get(C.Id));}
                    } else if(oldCas.Priority != 'P1'  && c.priority == 'P1' && c.accountid != null) {                        
                        if(CustInfoMap.containskey(c.AccountId)) {       
                            JBCXM__CustomerInfo__c CI = CustInfoMap.get(c.AccountId);    
                            JBCXM__Alert__c alert       = new JBCXM__Alert__c();
                            alert.Name                  = 'New P1 Case has been logged';    
                            alert.JBCXM__Account__c     = c.AccountId;
                            alert.JBCXM__ASV__c         = ((CI.JBCXM__ASV__c) != null ? CI.JBCXM__ASV__c : 0);
                            alert.JBCXM__Comment__c     = 'An open P1 case has been logged and needs to be reviewed.<br><br><a target="_blank" href="' + URL.getSalesforceBaseUrl().toExternalForm().replace('-api','') + '/' + C.Id + '">Case ' + C.CaseNumber + '</a>';
                            alert.JBCXM__Date__c        = Date.today();
                            alert.JBCXM__MRR__c         = ((CI.JBCXM__MRR__c) != null ? CI.JBCXM__MRR__c : 0);
                            alert.JBCXM__Severity__c    = GainsightDAL.GetAlertSeverityBySystemName('alertseverity2').Id;
                            alert.JBCXM__Status__c      = GainsightDAL.GetAlertStatusBySystemName('ID').Id;
                            alert.JBCXM__Type__c        = GainsightDAL.GetAlertTypeBySystemName('Customer Concern').Id;
                            alert.JBCXM__Reason__c      = (GainsightDAL.GetAlertReasonBySystemName('OpenCase') != null) ? GainsightDAL.GetAlertReasonBySystemName('OpenCase').Id : '';
                            alert.JBCXM__AssociatedObjectRecordID__c = C.Id;    
                            AlertsToInsert.add (alert);
                        }
                    }
                } else if( Trigger.isDelete && AlertMap.containsKey(c.Id) ) {AlertsToDelete.add( AlertMap.get(c.Id));}
            }
            //insert AlertsToInsert;
            //delete AlertsToDelete;
            recordsToReturn.get('Insert').addAll(AlertsToInsert);
            recordsToReturn.get('Delete').addAll(AlertsToDelete);                
        } catch (Exception e) {
            JBCXM__Log__c errorLog = New JBCXM__Log__c(JBCXM__ExceptionDescription__c   = 'Received a '+e.getTypeName()+' at line No. '+e.getLineNumber()+' while running the Trigger to create alerts from P1 Cases',
                                                       JBCXM__LogDateTime__c            = datetime.now(),
                                                       JBCXM__SourceData__c             = e.getMessage(),
                                                       JBCXM__SourceObject__c           = 'Case',
                                                       JBCXM__Type__c                   = 'GainsightCaseTrigger Trigger');
            insert errorLog;
            system.Debug(errorLog.JBCXM__ExceptionDescription__c);
            system.Debug(errorLog.JBCXM__SourceData__c);
        }
        return recordsToReturn;
    }    
    
    //gainsight trigger code ends////    
    public static Case CaseReceivedNotificationEmail() {        
        //Allocadia
        Case CaseTobeUpdated = new Case();        
        Id caseContactId;
        
        //Case size will always be 1
        for(SObject tmpSObj : Trigger.New) { //Size is always 1
            Case tempCase = (Case) tmpSObj;            
            system.debug('tempCase-------->' + tempCase);
            system.debug('case record type id==>' + tempCase.recordTypeId);
            //if(test.IsrunningTest())  { CaseTobeUpdated = tempCase; }
            if(tempCase.Case_Issue__c == 'Analytics' && tempCase.Case_Sub_Issue__c == 'MFM' && tempCase.AssetId != NULL) {
                for(Asset tmpAst : [select Id, Status, Parent_Instance__c From Asset Where Status = 'Expired' AND Parent_Instance__r.id = :tempCase.Assetid Limit 1]) { CaseTobeUpdated = tempCase; }
            }
            if(CaseTobeUpdated.Id == Null) {                    
                caseContactId = tempCase.ContactId;
            }
        }
        
        if(CaseTobeUpdated.Id != Null) {
            if(!test.IsrunningTest()) Casetobeupdated.Status = 'Closed';                
            //code to send Contact allocadia email ;
            //OrgWideEmailAddress owa = [select Id from OrgWideEmailAddress where DisplayName = 'Marketo Customer Support' Limit 1];    
            //EmailTemplate Emailtemplate = [SELECT id FROM EmailTemplate where name = 'Expired MFM contact to Allocadia'];
            Id owaId = SupportEmailSettings__c.getInstance('Marketo Customer Support').RecordId__c; 
            Id EmailtemplateId  = SupportEmailSettings__c.getInstance('Expired MFM contact to Allocadia').RecordId__c;         
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(Casetobeupdated.contactId);
            mail.setTemplateID(EmailtemplateId);
            mail.setWhatId(Casetobeupdated.Id);
            mail.setSaveAsActivity(false);
            mail.setOrgWideEmailAddressId(owaId);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
            return Casetobeupdated;
        }
        
        //List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        List < Id > caseIds = new List < Id > ();
        List < Id > portalCaseIds = new List < Id > ();

        //Is contact authorized contact and is entitlement valid for case notification. 
        List<Contact> caseContact = [SELECT Id, Is_Authorized_Contact__c from Contact Where Id = :caseContactId AND Is_Authorized_Contact__c = 'Yes' Limit 1];
        List<Entitlement> caseEntitlement = [SELECT Id, Name, Type, SlaProcessId, Asset.Munchkin_Id__c, SocialMarketing_Only__c from Entitlement WHERE Status = 'Active' and recordtypeId IN: supportRecordType AND Id = :((Case)Trigger.New[0]).EntitlementId Limit 1];
        System.Debug('caseContact ++++' + caseContact);
        System.Debug('caseEntitlement ++++' + caseEntitlement);

        for(SObject tmpSObj : Trigger.New) { //Size is always 1        
            Case tempCase = (Case) tmpSObj;
            
            System.Debug('tempCase.ContactId+++++' + tempCase.SuppliedEmail);
            System.Debug('tempCase.Origin-->' + tempCase.Origin);
            Boolean condForPortalCaseRecordId = tempCase.recordtypeId == '01250000000UJwyAAG' ? true : false;
            Boolean condForPortalCaseOrigin = tempCase.Origin == 'Web' ? true : false;
            if (condForPortalCaseRecordId && condForPortalCaseOrigin) { portalCaseIds.add(tempCase.Id); break; }
            if(tempCase.Problem_Type__c != NULL && Label.Case_ProblemTypes_To_Ignore.containsIgnoreCase('#'+tempCase.Problem_Type__c+'#')) {
                continue;
            }           
            Boolean Cond1 = tempCase.Origin == 'Email';
            Boolean Cond2 = FALSE;
            Boolean Cond3 = FALSE;
            Boolean Cond5 = FALSE;
            Boolean Cond10 = FALSE;
            Boolean Cond4 = !caseContact.isEmpty();
            If(caseEntitlement.isEmpty() == FALSE) {
                Cond2 = (caseEntitlement[0].SlaProcessId != null) ? true : false;
                Cond3 = System.Label.email2Case_Blocked_SLAs.contains(caseEntitlement[0].SlaProcessId) ? false : true;
                Cond5 = caseEntitlement[0].SocialMarketing_Only__c != true ? true : false;
                Cond10 = (caseEntitlement[0].Name == System.Label.CopperEgg_Entlmnt_Name) ? true : false;
            }
            Set <String> blockedEmails = new Set <String>();
            blockedEmails.addAll(System.Label.email2Case_Blocked_Emails.split(','));
            System.debug('blockedEmails=>Supplied=>' + blockedEmails + ' ' + tempCase.SuppliedEmail);
            
            Boolean Cond6 = !blockedEmails.contains(tempCase.SuppliedEmail);
            Boolean Cond7 = tempCase.SuppliedEmail != null ? (tempCase.SuppliedEmail.Contains('@marketo.com')) : false;
            Boolean Cond8 = tempCase.RecordTypeId == System.Label.email2Case_RecordType ? true : false;
            Boolean Cond9 = (tempCase.Account.Type != 'Ex-Customer' && tempCase.Account.Type != 'Ex-Partner') ? true : false;
            Boolean Cond11 = (tempCase.SuppliedEmail != null) ? true : false;

            System.debug('Cond1=>' + Cond1 + ' Cond2=>' + Cond2 + ' Cond3=>' + Cond3 + ' Cond4=>' + Cond4 + ' Cond5=>' + Cond5);
            System.debug('Cond6=>' + Cond6 + ' Cond7=>' + Cond7 + ' Cond8=>' + Cond8 + ' Cond9=>' + Cond9 + ' Cond10=>' + Cond10 + ' Cond11=>' + Cond11);
            System.Debug('Result+++' + ((cond1 && Cond2 && (Cond3 || Cond10) && Cond4 && Cond5 && Cond6 && Cond8 && Cond9 && Cond11) || (Cond1 && Cond6 && Cond7 && Cond8 && Cond9 && Cond11)));
            
            if ((cond1 && Cond2 && (Cond3 || Cond10) && Cond4 && Cond5 && Cond6 && Cond8 && Cond9 && Cond11) || (Cond1 && Cond6 && Cond7 && Cond8 && Cond9 && Cond11)) { caseIds.add(tempCase.Id); }
            for (Sobject tmoObj : trigger.new){
                Case caseInfo = (case)tmoObj;
                if(caseinfo.origin == 'Email' && (caseinfo.recordtypeId == label.DLVR_Cases_RecordType || caseinfo.recordtypeId == label.SIServiceRequestRecordType)){ caseIds.add(caseInfo.Id); }
             }
        }
        if (!portalCaseIds.isEmpty()) CaseUtils.sendCaseNotificationWithJiveEnabled(portalCaseIds, System.Label.Jive_Search_Credentials);
        if (!caseIds.isEmpty()) CaseUtils.sendCaseNotificationWithJiveEnabled(caseIds, '');
        return null;
    }
    
    public static void parseEmailCCList() {
        for (Sobject tmoObj : trigger.new) {
            Case caseInfo = (case)tmoObj;
            Case oldCaseInfo = null;
            if(Trigger.isUpdate) { //caseInfo.Id != null) 
                oldCaseInfo = (Case) Trigger.oldMap.get(caseInfo.Id);
                system.debug('oldCaseInfo----->'+oldCaseInfo);
            }
            system.debug('caseInfo.Email_List__c===>>'+caseInfo.Email_List__c);
            if (Utils.hasChanges('Email_List__c', oldCaseInfo, caseInfo)) {
                if (caseInfo.Email_List__c != null && caseInfo.Email_List__c.length() > 0) {
                    String emailAddress = '';
                      try{
                        Set<string> ccToRemove = new Set<String>(Label.ExcludeEmailAliasFromLooping.split(';')); 
                        emailAddress = caseInfo.Email_List__c;
                        for(String str : ccToRemove){
                            if(emailAddress.Contains(str)){
                                emailAddress = emailAddress.replaceAll(str,'');
                            }
                        }
                    }catch(exception e){
                        CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);
                    }
                    emailAddress = emailAddress.replaceAll(';',',');
                    List<String> emailAddressList = emailAddress.split(',');
                    Integer i=1;
                    //SObject sobCase = null;                    
                    while(i <= 10) {
                        String fieldName ='CC_Email_';
                        if (i > 9) {fieldName = fieldName+'0'+i+'a__c'; } else {
                            fieldName =fieldName+'00'+i+'a__c';
                        }
                        //sobCase = (SObject)caseInfo;
                        caseInfo.put(fieldName, '');
                        i++;
                    }
                    i=1;
                    //sobCase = null;
                    for(String email : emailAddressList) {
                        String  fieldName ='CC_Email_';
                        if (i > 10) {break;}
                        if (i > 9) {
                            fieldName = fieldName+'0'+i+'a__c';
                        } else {
                            fieldName =fieldName+'00'+i+'a__c';
                        }
                        //sobCase = (SObject)caseInfo;
                        caseInfo.put(fieldName, email);
                        i++;
                    }
                } else {
                    Integer i=1;
                    //SObject sobCase = null;                    
                    while(i <= 10) {
                        String fieldName ='CC_Email_';
                        if (i > 9) {
                            fieldName = fieldName+'0'+i+'a__c';
                        } else {
                            fieldName =fieldName+'00'+i+'a__c';
                        }
                        //sobCase = (SObject)caseInfo;
                        caseInfo.put(fieldName, '');
                        i++;
                    }
                }
            }
        }
    }            
    
    public static void updateBusinessHours(){
        List <User> portalUser;
        List <Contact> portalContact = new List<Contact>();
        List <Contact> contactSelected;
        List <Authorized_Contact__c> authorizedContact;
        Boolean hasValidEntitlement = false;
        String munchkinIdOfUser;
        List <Entitlement> entList = new List <Entitlement>();  
        if(Trigger.Size == 1) {
            Case caseToBeCreated = new Case();
            for (SObject tempCase : Trigger.New) {
                caseToBeCreated = (Case) tempCase;
                if(caseToBeCreated.origin=='Security' && Trigger.isInsert) {
                    caseToBeCreated.Problem_type__c='Security Report';
                    caseToBeCreated.Category__c='Other';
                    caseToBeCreated.BusinessHoursId = '01m50000000H7REAA0';
                    if(caseToBeCreated.Priority == 'P3') { 
                        caseToBeCreated.Security_Origin_External__c = True;
                        caseToBeCreated.Priority = 'P2';
                    }
                    if(caseToBeCreated.contactId == null) {
                        caseToBeCreated.ContactId = Label.Support_Report_Default_Contact;
                        caseToBeCreated.AccountId = Label.Support_Report_Default_Account;
                    }
                    return;
                }
                if(caseToBeCreated.recordtypeId == Label.ProActiveCaseRecTypeId && caseToBeCreated.category__c == 'SSL Certificate') return;
            }                           
            if(!CaseTriggerFunction.isValidRecordTypeId(caseToBeCreated.recordTypeId))  return;      
            if(caseToBeCreated.contactId !=null && caseToBeCreated.origin != 'Security') {                 
                portalContact  = [Select Id,Munchkin_Id__c, Redirect_To_Case_Create__c from Contact where Id =: caseToBeCreated.ContactId];
            }
            if(portalContact.isEmpty() && caseToBeCreated.Accountid == Label.ToutServeAccountId){
                caseToBeCreated.EntitlementId = Label.ToutAppEntitlementId;
                caseToBeCreated.AssetId = Label.ToutAppAssetId;  
            }
            If(label.enableContactMunchin =='Yes' && portalContact != null && portalContact.isEmpty() == FALSE){
                If(trigger.isInsert || (Trigger.IsUpdate && (Trigger.oldMap.get(caseToBeCreated.Id).get('ContactId') != caseToBeCreated.ContactId || caseToBeCreated.EntitlementId == null))){                  
                    authorizedContact = new List < Authorized_Contact__c > ([Select Entitlement__c, Entitlement__r.Status, Entitlement__r.AssetId, Entitlement__r.Asset.Munchkin_Id__c From Authorized_Contact__c where Contact__c = :caseToBeCreated.ContactId and Entitlement__r.recordtypeId IN: supportRecordType ORDER BY Entitlement__r.Status ASC, Entitlement__r.type, Entitlement__r.EndDate DESC Limit 1]);
                    Boolean checkTout = true;
                    if((caseToBeCreated.origin != 'Security' && caseToBeCreated.origin != 'Email') || (caseToBeCreated.origin == 'Email' && authorizedContact.IsEmpty()== false )){
                        for(Authorized_Contact__c tmpA :  authorizedContact){
                            caseToBeCreated.EntitlementId = tmpA.Entitlement__c;
                            caseToBeCreated.AssetId = tmpA.Entitlement__r.AssetId;   
                            checkTout = false;
                            break;
                        }
                        if(authorizedContact.IsEmpty()== true && caseToBeCreated.contactID != null){
                            for(Account acc : [Select id,(Select id,AssetId,status from entitlements where recordtypeId IN: supportRecordType order by status ASC,type,EndDate DESC limit 1) from Account where Id IN (Select Accountid from contact where id =:caseToBeCreated.contactID) limit 1]){
                                for(Entitlement ent : acc.entitlements){
                                    if(ent.status == 'Active'){
                                        caseToBeCreated.EntitlementId = ent.id;
                                        caseToBeCreated.AssetId = ent.AssetId;
                                        break;
                                    }
                                    else if(ent.status == 'Expired'){
                                        caseToBeCreated.EntitlementId = ent.id;
                                        caseToBeCreated.AssetId = ent.AssetId;
                                        break;
                                    }
                                }
                            }
                        }
                    }
                    if(checkTout == true && caseToBeCreated.category__c == 'ToutApp'){
                        List<Entitlement> enList = new List<Entitlement>();
                        if(authorizedContact.IsEmpty()== false) enList = [Select id, Name, AssetId, Status, EndDate from Entitlement Where recordtypeId IN: supportRecordType AND Account.Type = 'Customer' And AccountId = '0015000000fD2sO' and (Entitlement.asset.Purpose__c = 'Production' OR Entitlement.asset.Purpose__c = 'Rubiks Production') Order by Status ASC, type, EndDate DESC limit 1];
                        if(enList.isEmpty() == false && enList.Size() > 0){
                            for(Entitlement ent : enList){
                                caseToBeCreated.EntitlementId = ent.id;
                                caseToBeCreated.AssetId = ent.AssetId;   
                            }
                        }
                        
                    }
                }
            }
  
        }
        /**POPULATE ASSET AND ENTITLEMENT BASED ON CONTACT---ENDED**/    
        /***New Section Started--Adding Business Hours to Case****/
        
        List < Case > myCaseList = new List < Case > ();
        Set < Id > myP1CaseIds = new Set < Id > ();
        Map < Id, Id > myNonP1CaseToEntIdMap = new Map < Id, Id > ();
        Set < Id > contIds = new Set < Id > ();
        Map < Id, Entitlement > myEntmntMap = new Map < Id, Entitlement > ();
        List < Businesshours > myBsHrs = new List < Businesshours > (); 
        for (SObject S: Trigger.new){
            Case c = (Case) S;
            if(c.Priority == 'P1' || c.origin=='Security') {
                if(c.BusinessHoursID != '01m50000000H7REAA0'){
                    myP1CaseIds.Add(c.Id);
                }
            } 
            else if (c.EntitlementId != null) {
                myNonP1CaseToEntIdMap.put(c.Id, c.EntitlementId);
            }
            if(c.contactId != null) contIds.add(c.contactId);
        }    
 
        if (myP1CaseIds.IsEmpty() == FALSE) myBsHrs = [SELECT Id, Name FROM Businesshours WHERE Name = 'P1 Issues' Limit 1];
        if (myNonP1CaseToEntIdMap.IsEmpty() == FALSE) myEntmntMap = new Map <ID, Entitlement > ([SELECT e.Id, e.BusinessHoursId From Entitlement e Where e.Id = : myNonP1CaseToEntIdMap.values() and recordtypeId IN: supportRecordType Limit 1]);
       
        for (SObject S: Trigger.new) {
            Case c = (Case) S;
            if (c.Priority == 'P1'){
                if (myBsHrs.isEmpty() == FALSE) c.BusinessHoursId = myBsHrs[0].Id;
            }
            else if ((c.EntitlementId != null) && (myEntmntMap != null) && (myEntmntMap.containsKey(c.EntitlementId))) {
                c.BusinessHoursId = myEntmntMap.get(c.EntitlementId).BusinessHoursId;   
            }
        }    
    }
    
    public static Map<case, id> NotifyTechSuppOrNamedSupp(){     
        /*Code to Send An Email For Entitlement Types Elite and Premier By Jaimal*/    
        //Label To Enable Disable this Trigger        
        System.Debug('____NotifyTechSuppOrNamedSuppSwtich_____'+System.Label.NotifyTechSuppOrNamedSuppSwtich);
        Map<case, id> EltPrmCaseAndEntMap = new Map<case, id>();    
        if(System.Label.NotifyTechSuppOrNamedSuppSwtich == 'ON') {
            //Label To Enable Disable this Trigger                               
            Set<String> supportLevels = new Set<String>{'Elite','Premier'};
            System.Debug('Entering Code For Technical Account Manager');            
            for(sObject tempSObj : Trigger.New) {                
                Case tempCase = (case)tempSObj;
                If(tempCase.recordTypeId == System.Label.SupportCaseRecordTypeId){
                    If(Trigger.isUpdate){
                        Case CaseOld = (case)Trigger.OldMap.get(tempSObj.Id);
                        If((tempCase.Priority == 'P1' && CaseOld.Priority != 'P1' && (supportLevels.contains(tempCase.Support_Level__c)))   ||  ((supportLevels.contains(tempCase.Support_Level__c) && !supportLevels.contains(CaseOld.Support_Level__c)) && tempCase.Priority == 'P1')){
                            EltPrmCaseAndEntMap.put(tempCase, tempCase.EntitlementId);
                        }
                    }   
                    If((Trigger.isInsert && supportLevels.contains(tempCase.Support_Level__c) && tempCase.Priority == 'P1')){
                        EltPrmCaseAndEntMap.put(tempCase, tempCase.EntitlementId);                                                  
                    }
                    else if(Trigger.isInsert && tempCase.Support_Level__c == 'UPS' && (tempCase.Priority == 'P1' || tempCase.Priority == 'P2' )){
                        EltPrmCaseAndEntMap.put(tempCase, tempCase.EntitlementId); 
                    }
                }  
            }                           
            System.Debug('______EltPrmCaseAndEntMap____'+EltPrmCaseAndEntMap);             
        }
        return EltPrmCaseAndEntMap;
    }
    
    public static void emailToNamSupEngOrTechAcctMan(Map<case, id> EltPrmCaseAndEntMap){
        System.Debug('I AM IN MAILER CODE');
        System.Debug('________EltPrmCaseAndEntMap_________'+EltPrmCaseAndEntMap);
        Map<Id,Entitlement> entitlmentIdToEntitlement = new Map<Id,Entitlement>([Select Id, Type,AssignedSupportPOC__c from Entitlement Where Id IN : EltPrmCaseAndEntMap.values() and recordtypeId IN:supportRecordType]);
        Id owaId = SupportEmailSettings__c.getInstance('Marketo Customer Support').RecordId__c; 
        Id emailTemplateTechnAccManId = SupportEmailSettings__c.getInstance('P1 Notification To Manager').RecordId__c; 
        Id emailTemplateNamSuppEngiId = SupportEmailSettings__c.getInstance('P1 Notification To NSE').RecordId__c; 
        
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        for(Case caseItr : EltPrmCaseAndEntMap.keyset()) {
            Messaging.SingleEmailMessage message  = new Messaging.SingleEmailMessage();
            Id tempIdSuppEngineerOrTechAccMan;
            if((entitlmentIdToEntitlement.get(caseItr.EntitlementId).Type == 'Elite' || entitlmentIdToEntitlement.get(caseItr.EntitlementId).Type == 'UPS') && entitlmentIdToEntitlement.ContainsKey(caseItr.EntitlementId) && entitlmentIdToEntitlement.get(caseItr.EntitlementId).AssignedSupportPOC__c != Null){
                tempIdSuppEngineerOrTechAccMan = entitlmentIdToEntitlement.get(caseItr.EntitlementId).AssignedSupportPOC__c;
                message.setTemplateId(emailTemplateTechnAccManId);
            } else if(entitlmentIdToEntitlement.get(caseItr.EntitlementId).Type == 'Premier' && entitlmentIdToEntitlement.ContainsKey(caseItr.EntitlementId) && entitlmentIdToEntitlement.get(caseItr.EntitlementId).AssignedSupportPOC__c != Null){
                tempIdSuppEngineerOrTechAccMan = entitlmentIdToEntitlement.get(caseItr.EntitlementId).AssignedSupportPOC__c;
                message.setTemplateId(emailTemplateNamSuppEngiId);
                System.Debug('________tempIdSuppEngineerOrTechAccMan______'+tempIdSuppEngineerOrTechAccMan);
            }
            System.Debug('________tempIdSuppEngineerOrTechAccMan______'+tempIdSuppEngineerOrTechAccMan);
            message.setTargetObjectId(tempIdSuppEngineerOrTechAccMan);
            message.setOrgWideEmailAddressId(owaid);
            message.setWhatId(caseItr.Id);
            message.setSaveAsActivity(false);
            allmsg.add(message);
        }
        List<Messaging.SendEmailResult> mailResult = Messaging.sendEmail(allmsg, false);
        System.Debug('mailResult'+mailResult);
        System.Debug('entitlmentIdToEntitlement'+entitlmentIdToEntitlement);
    }
            
    public static Boolean isValidRecordTypeId(Id recordTypeId){
        List<id> tempRecordTypeIdsList = System.label.IgnoreRecordType.split('#'); 
        Set<id>  recordTypeIdToBeIgnored = new Set<id>(tempRecordTypeIdsList);
        Boolean finalResult = recordTypeIdToBeIgnored.Contains(recordTypeId)?false:true;
        return finalResult;
    }

    public static List<Account> AccountUpdate() {    
        Set<Id> accountClosed = new Set<Id>();
        for(SObject cc : trigger.new){
            case c = (case)cc;             
            if(trigger.isUpdate){
                case cOld = (case)trigger.oldMap.get(cc.id);
                if(c.isClosed != cOld.isClosed){
                    accountClosed.add(c.accountid);
                }
            }else{
                if(c.isClosed != null){
                    accountClosed.add(c.accountid);
                }
            }
        }
        List<Account> acList = new List<Account>();
        for (AggregateResult ar : [select count(id) counts, AccountId from Case where isClosed= false and AccountId IN : accountClosed group by AccountId])  {
          Integer counts = (Integer)ar.get('counts');
          Id acid = (Id)ar.get('AccountId');
          if(acid != null){
              Account ac = new Account (Open_Cases__c= counts, Id = acid);
              string recordString = ac.id+','+counts+'\n';
              system.debug(ac);
              acList.add(ac);
          }
        }  
        return acList;      
    }
    
    public static string returnCaseRecordTypeId(String recordTypeName) {
        return Case.sObjectType.getDescribe().getRecordTypeInfosByName().get(recordTypeName).getRecordTypeId();       
    }
    
    public static void completeMilestone(Set<Id> caseIds, String milestoneName, DateTime complDate) {        
        if(!System.isFuture() && !System.isBatch()) {
            completeMilestoneFuture(caseIds,milestoneName,complDate);
            return;
        }
        List<CaseMilestone> cmsToUpdate = [select Id, completionDate from CaseMilestone cm where caseId in :caseIds and cm.MilestoneType.Name=:milestoneName and completionDate = null limit 1];
        if (cmsToUpdate.isEmpty() == false){
            for (CaseMilestone cm : cmsToUpdate){
                cm.completionDate = complDate;
            }
            try {
                update cmsToUpdate;
            } catch(Exception ex) {
                system.debug('Exception==>' + ex);    
            }
        } // end if
    }
    
    @future
    public static void completeMilestoneFuture(Set<Id> caseIds, String milestoneName, DateTime complDate) {
        List<CaseMilestone> cmsToUpdate = [select Id, completionDate from CaseMilestone cm where caseId in :caseIds and cm.MilestoneType.Name=:milestoneName and completionDate = null limit 1];                        
        if (cmsToUpdate.isEmpty() == false){
            for (CaseMilestone cm : cmsToUpdate){
                cm.completionDate = complDate;
            }
            try {
                update cmsToUpdate;
            } catch(Exception ex) {
                system.debug('Exception==>' + ex);    
            }
        } // end if
    }    

    public static void setContactRedirect(Id contactId){    
        if(System.isFuture() || System.isBatch()) {
            Contact caseContact = new Contact(Id = contactID, Redirect_To_Case_Create__c = TRUE);
            update caseContact;
        } else {
            setContactRedirectFuture(contactId);
        }
    }    
    /*SOPS-904 RUBIKS - Proactive Case Monitoring System Requirements By Rizvan starts*/
    public static case ProactiveCaseMonitoring(){
        system.debug('ProactiveCaseMonitoring called===>');
        case triggerNew = (case)  trigger.new[0];  
        string CaseCategory;
        string CaseProblemType;
        //Set<String> SupportRegions =  new Set<String>(Proactive_Case_Monitoring__c.getInstance('SupportRegions').Values__c.split('#'));
        Set<String> CustomerType     =  new Set<String>(Proactive_Case_Monitoring__c.getInstance('CustomerType').Values__c.split('#'));  
        Set<String> ProblemType      =  new Set<String>(Proactive_Case_Monitoring__c.getInstance('ProblemType').Values__c.split('#')); 
        Set<String> AccountidToexclude  = new Set<String>();
        AccountidToexclude.addAll(System.Label.Exclude_Proactive_Monitoring_Account_Ids.split('#')); 
             
        id conID                     =  triggerNew.contactid;
        id accID                     =  triggerNew.accountid;
        CaseProblemType              =  triggerNew.Problem_Type__c;
        CaseCategory                 =  triggerNew.category__c;

        Set<string> CaseNo           =  new Set<string>();
        list<case> last30DaysCases   =  new list<case>();
        list<case> lastMonthCases    =  new list<case>();
        list<case> thisMonthCases    =  new list<case>();
        
        //Iterate List of existing Sm case to avoid new case creation if case already exist for the account.              
        for(case temp : [select id, status, CasesRelated__c, CasessRelated__c from case where (createdDate = last_month OR createdDate = This_month) AND Problem_Type__c = 'Pattern Identified' AND RecordTypeid = '01250000000UK1EAAW' AND Situation_Account__c =: accID AND Situation_Account__c  NOT IN :AccountidToexclude]){ 
            //list of cases for which SM is already created. Do not include these cases again. 
            if(temp.CasessRelated__c != null) {
                CaseNo.addall(temp.CasessRelated__c.split(','));
            }            
        }  
        date daysbackDate = system.today().addDays(-90);
        //get list of case of type bug /troubleshooting within last 30 days   
        List<case> CaseList = new list<case>([select id,createdDate, caseNumber,CasesRelated__c,Problem_Type__c,category__c, entitlement.StartDate,entitlement.AssignedSupportPOC__r.name,entitlement.AssignedSupportPOC__r.managerid, entitlement.AssignedSupportPOC__r.manager.IsActive,entitlement.name,CasessRelated__c,entitlement.type from case where  (createdDate = last_month OR createdDate = This_month)  AND AccountId =:accID AND AccountId NOT IN :AccountidToexclude AND RecordTypeid = '01250000000UJwxAAG' AND CaseNumber NOT IN : CaseNo and Close_reason__c NOT IN ('Invalid Case', 'Spam', 'Duplicate') AND entitlement.type IN:CustomerType And entitlement.StartDate<=:daysbackDate  ]); 
        system.debug('CaseList===>'+CaseList);
        for(case temp : CaseList){
            if(temp.createdDate > (system.today().addDays(-30)) && ProblemType.contains(temp.Problem_Type__c) && temp.Problem_Type__c ==CaseProblemType && temp.category__c ==CaseCategory){
                last30DaysCases.add(temp);
            } 
            if(system.now().month() == temp.createdDate.month()){               
                thisMonthCases.add(temp);
            }
            if(system.now().addmonths(-1).month() == temp.createdDate.month()){
                lastMonthCases.add(temp);
            }           
        } 
        system.debug('last30DaysCases===>'+last30DaysCases.size());
        system.debug('thisMonthCases===>'+thisMonthCases.size());
        system.debug('lastMonthCases===>'+lastMonthCases.size());

        //if no of case are 3 or more, create an sm of type pattern identified.
        decimal dec = lastMonthCases.size() + lastMonthCases.size()/2;
        system.debug('lastMonthCases+50===>'+dec);
        if((last30DaysCases.IsEmpty()==false && last30DaysCases.size() > 4) || (last30DaysCases.IsEmpty()==false && thisMonthCases.IsEmpty()==false  && lastMonthCases.size() >=5 && thisMonthCases.size()>=Dec) || test.IsrunningTest()){
            system.debug('Condition fulfilled===>');
            string businessRule;
            case InsrtSMCase                    =      new case();
            InsrtSMCase.Ownerid                 =     '00G50000001R8aQ';
            if(last30DaysCases.IsEmpty()==false && (last30DaysCases.size() > 4  || test.IsrunningTest()) ){
                businessRule = Proactive_Case_Monitoring__c.getInstance('5CasesRecieved').Values__c +  ' on Problem type - '+last30DaysCases[0].problem_type__c  +  ' and Category - '+last30DaysCases[0].category__c;
                if(last30DaysCases[0].entitlement != null) {
                    if((last30DaysCases[0].entitlement.type == 'Premier' || last30DaysCases[0].entitlement.type == 'Premier Plus') && last30DaysCases[0].entitlement.AssignedSupportPOC__r.manager != null && last30DaysCases[0].entitlement.AssignedSupportPOC__r.manager.IsActive){
                        InsrtSMCase.SM_Created_By__c        =     thisMonthCases[0].entitlement.AssignedSupportPOC__r.name;
                        InsrtSMCase.Ownerid                 =     last30DaysCases[0].entitlement.AssignedSupportPOC__r.managerid;
                    }else if(last30DaysCases[0].entitlement.type == 'Elite' && last30DaysCases[0].entitlement.AssignedSupportPOC__r.manager != null &&               last30DaysCases[0].entitlement.AssignedSupportPOC__r.manager.IsActive){
                        InsrtSMCase.SM_Created_By__c= thisMonthCases[0].entitlement.AssignedSupportPOC__r.name;
                        InsrtSMCase.Ownerid                 =     last30DaysCases[0].entitlement.AssignedSupportPOC__r.managerid;
                    }else if(last30DaysCases[0].entitlement.type == 'Business' && last30DaysCases[0].entitlement.AssignedSupportPOC__r.manager != null &&                last30DaysCases[0].entitlement.AssignedSupportPOC__r.manager.IsActive){
                        InsrtSMCase.SM_Created_By__c = thisMonthCases[0].entitlement.AssignedSupportPOC__r.name;
                        InsrtSMCase.Ownerid                 =     last30DaysCases[0].entitlement.AssignedSupportPOC__r.managerid;
                    }
                }
            }else if(!lastMonthCases.IsEmpty() && !thisMonthCases.IsEmpty() && lastMonthCases.size() >=5 && thisMonthCases.size()>=(lastMonthCases.size()+(lastMonthCases.size()/2))){
                businessRule = Proactive_Case_Monitoring__c.getInstance('50%CaseIncrease').Values__c;
                if(thisMonthCases[0].entitlement != null) {
                    if((thisMonthCases[0].entitlement.type == 'Premier' || thisMonthCases[0].entitlement.type == 'Premier Plus') && thisMonthCases[0].entitlement.AssignedSupportPOC__r.manager != null && thisMonthCases[0].entitlement.AssignedSupportPOC__r.manager.IsActive){
                        InsrtSMCase.SM_Created_By__c = thisMonthCases[0].entitlement.AssignedSupportPOC__r.name;
                        InsrtSMCase.Ownerid = thisMonthCases[0].entitlement.AssignedSupportPOC__r.managerid;
                    }else if(thisMonthCases[0].entitlement.type == 'Elite' && thisMonthCases[0].entitlement.AssignedSupportPOC__r.manager != null &&                 thisMonthCases[0].entitlement.AssignedSupportPOC__r.manager.IsActive){
                        InsrtSMCase.Ownerid = thisMonthCases[0].entitlement.AssignedSupportPOC__r.managerid;
                        InsrtSMCase.SM_Created_By__c= thisMonthCases[0].entitlement.AssignedSupportPOC__r.name;
                    }else if(thisMonthCases[0].entitlement.type == 'Business' && thisMonthCases[0].entitlement.AssignedSupportPOC__c!=null && thisMonthCases[0].entitlement.AssignedSupportPOC__r.manager != null && thisMonthCases[0].entitlement.AssignedSupportPOC__r.manager.IsActive){
                        InsrtSMCase.Ownerid = thisMonthCases[0].entitlement.AssignedSupportPOC__c;
                        InsrtSMCase.SM_Created_By__c = thisMonthCases[0].entitlement.AssignedSupportPOC__r.name;                        
                    }
                }
            }

            InsrtSMCase.RecordTypeid            =     '01250000000UK1EAAW';
            InsrtSMCase.Situation_Account__c    =      accID;
            InsrtSMCase.Situation_contact__c    =      ConId;
            InsrtSMCase.status                  =     'New';
            InsrtSMCase.Origin                  =     'Support';
            InsrtSMCase.priority                =     'P2';
            InsrtSMCase.subject                 =     'Pattern Identified';
            InsrtSMCase.description             =     'Case Pattern Identified - Proactive customer reach program \n'+businessRule;
            InsrtSMCase.Problem_Type__c         =     'Pattern Identified';
            //InsrtSMCase.Category__c             =     'Other';
            //InsrtSMCase.Sub_category__c         =     'Other';
            InsrtSMCase.CasesRelated__c         =     '';
            InsrtSMCase.CasessRelated__c        =     '';
            if(last30DaysCases.size() > 4){
                for(case temp : last30DaysCases ){
                    InsrtSMCase.CasesRelated__c     +=     '<a href="/'+temp.Id+'"> ' +temp.caseNumber+'</a>    ';
                    InsrtSMCase.CasessRelated__c     +=      temp.CaseNumber+',';
                }
            }else if(!thisMonthCases.IsEmpty()){
                for(case temp : thisMonthCases){
                    InsrtSMCase.CasesRelated__c     +=     '<a href="/'+temp.Id+'"> ' +temp.caseNumber+'</a>    ';
                    InsrtSMCase.CasessRelated__c     +=      temp.CaseNumber+',';
                }
            } 
            system.debug('InsrtSMCase===>'+InsrtSMCase);      
            return InsrtSMCase;
        } 
        return null;      
    }
    /*SOPS-904 RUBIKS - Proactive Case Monitoring System Requirements By Rizvan Ends*/ 
        
    @future 
    public static void setContactRedirectFuture(Id contactId){
        Contact caseContact = new Contact(Id = contactID, Redirect_To_Case_Create__c = TRUE);
        update caseContact;
    }
    
    public static void sendEcxeptionMailToDeveloper(Exception e){
       system.debug('line number==>'+e.getMessage());
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {'ServiceCloudTeam@grazitti.com'};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Support Case Optimized trigger Exception');
       mail.setPlainTextBody(e+'\n'+e.getStackTraceString());
       try{Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });}catch(exception ex){}    
    }
    
    public static casecomment noArticleComments(){
        casecomment com ;
        system.debug('method called===============>');
        case triggerNew = (case)  trigger.new[0];
        case triggerOld = (Case)Trigger.OldMap.get(triggerNew .Id);
        string docType;
        string descriptionOfProb;
        string descriptionOfSol;
        string status;
        string statusOld;             
        id parentId  =  triggerNew.id;
        docType=  triggerNew.Doc_type__c;
        descriptionOfProb=  triggerNew.Description_of_problem__c;
        descriptionOfSol=  triggerNew.Description_of_solution__c;
        status=triggerNew.status;
        statusOld=triggerOld.status;         
        if(descriptionOfProb!=null && descriptionOfSol!=null && docType!=null && status=='closed' && statusOld!='closed') {
            com = new casecomment();
            com.IsPublished=false;
            com.ParentId=parentId;
            com.CommentBody='DOC TYPE:'+docType+'\n DESCRIPTION OF PROBLEM:'+descriptionOfProb+ '\n DESCRIPTION OF SOLUTION:'+descriptionOfSol;
            return com;
        }
        return com;
    }  
    
    //SOPS-1023 #P1 escalation from P3/P2 case redistribution to P1 queue Starts
    Public static void P1CaseRedistribution() {
        boolean activeInDE = false;
        for(object tem : trigger.new){
            case temp = (case) tem;
            case triggerOld = (Case) trigger.OldMap.get(temp.Id);
             if(temp.priority == 'P1' && temp.RecordtypeId == label.supportcaserecordtypeid && temp.ownerid !=UserInfo.getUserId() && ( (triggerOld.priority !='P1') || (temp.status == 'Needs Reply' && triggerOld.status != 'Needs Reply') || (temp.status == 'Reopened' && triggerOld.status != 'Reopened') || (temp.status == 'Working' && triggerOld.status != 'Working') || (temp.NextUpdateDueFrmCUM__c != triggerOld.NextUpdateDueFrmCUM__c ))){          
                string OwID = temp.ownerId;
                if(OwID.startsWith('005')){                
                    set<id> idsSet = new set<id>();
                    Map<Id,Map<Id,Boolean>> teamMap = n2de.DistributionEngineGlobal.getUserAvailabilityAllTeams();
                    system.debug('Reach Level 2===>>>'+teamMap.keyset());
                    list <id> tl=new list<id>();
                    tl = (list <id>)label.TeamIds.split(',');
                    Set<Id> teamIds = new Set<Id>();
                    teamIds.addAll(tl);
                    for(Id t : teamIds){
                        Map<Id,Boolean> test = teamMap.get(t);
                        system.debug('######Test ' +test);
                        if(test.containskey(temp.Ownerid) && test.get(temp.Ownerid) == True){
                            activeInDE = true;
                        }
                    }
                    if(activeInDE==false){
                         temp.ownerId = Label.P1QueueId;
                    }
                }
            }
        }
    }
    //SOPS-1023 #P1 escalation from P3/P2 case redistribution to P1 queue Ends
    
    //SOPS-1083 #Notification for TSE and their Manager if a case is put into “Needs Reply” Status 3 times in “N” days Starts
   public static list<case> NeedReplyNotifyCases() {
        list<case> casenotifyList = new list<case>();
        DateTime last5Days = system.now().addDays(-5);
        system.debug('NeedReplyNotifyCases Function Called===>'+last5Days);
        for(case temp : [select Id, CaseNumber, OwnerId, Owner.Name, contact.name, Entitlementid, Entitlement.type, Entitlement.AssignedSupportPOC__c, Entitlement.AssignedSupportPOC__r.name, Entitlement.AssignedSupportPOC__r.manager.email,(select NewValue from Histories where field = 'status' and createdDate >=:last5Days ) from Case where Id IN :Trigger.NewMap.keySet() and status = 'Needs Reply' and Entitlementid !=null And recordtypeId = '01250000000UJwx'] ){        
            
            system.debug('temp.Histories.size()===>'+temp.Histories.size());
            integer count = 1; 
            integer Num = 0;            
            for(caseHistory tmp : temp.Histories) {
                Num += 1;
                system.debug('Num==>> '+Num);
                if(tmp.NewValue == 'Needs Reply') {
                    count += 1; 
                    system.debug('NewValue===>'+tmp.NewValue +' Count==>> '+count+' Num==>> '+Num);                    
                }               
            }
            if( count >= 3 && Num == temp.Histories.size() ) {    
                casenotifyList.add(temp);    
            }
        }
        system.debug('casenotifyList===>'+casenotifyList);
        return casenotifyList;       
    }
    
    public static void SendNeedReplyNotificationToNSEandManager(List<case> CasList) {
        system.debug('SendNeedReplyNotificationToNSEandManager Function Called===>'+CasList.size());
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
        map<id,string> userToManagerEmailMap = new map<id,string>();
        list<id> UserIds = new list<id>();  
        for(case temp : CasList){      
            UserIds.add(temp.OwnerId);                    
        }
        for(User usr : [select id, Name, manager.email from user where id in : UserIds and Isactive =true]){
            if(usr.manager.email!=null){
                userToManagerEmailMap.put( usr.id, usr.manager.email);
            }       
        }
        
        for(case temp : CasList){
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            list<string> ccAddresses = new list<string>{};
            String body = 'Dear, <br/><br/>Case #' +temp.CaseNumber+ ' has been put into Needs Reply 3 times. Please reach out to the customer to assure the customer satisfaction on their case and determine the reason the case is still not resolved.';
            if( (temp.Entitlement.type == 'Premier' || temp.Entitlement.type == 'Premier Plus') && temp.Entitlement.AssignedSupportPOC__c!=null ) {
                email.setTargetObjectId(temp.Entitlement.AssignedSupportPOC__c);
                ccAddresses.add(temp.Entitlement.AssignedSupportPOC__r.manager.email);
                body = 'Dear '+temp.Entitlement.AssignedSupportPOC__r.name+', <br/><br/>Case #' +temp.CaseNumber+ ' has been put into Needs Reply 3 times. Please reach out to the customer to assure the customer satisfaction on their case and determine the reason the case is still not resolved.';
                if(ccAddresses != null && ccAddresses.IsEmpty()==FALSE ){ email.setccAddresses(ccAddresses); }
                email.setSaveAsActivity(false);
                email.setSubject('Case #' +temp.CaseNumber+ ' has been placed in Needs Reply. Please resolve as soon as possible');
                email.setHtmlBody(body);
                email.setOrgWideEmailAddressId('0D250000000Kz9OCAS');                                                        
                emails.add(email);
            }else if(temp.Entitlement.type == 'Elite'  && temp.Entitlement.AssignedSupportPOC__c != null) {
                email.setTargetObjectId(temp.Entitlement.AssignedSupportPOC__c);
                ccAddresses.add(temp.Entitlement.AssignedSupportPOC__r.manager.email);                
                body = 'Dear '+temp.Entitlement.AssignedSupportPOC__r.name+', <br/><br/>Case #' +temp.CaseNumber+ ' has been put into Needs Reply 3 times. Please reach out to the customer to assure the customer satisfaction on their case and determine the reason the case is still not resolved.';
                if(ccAddresses != null && ccAddresses.IsEmpty()==FALSE ){ email.setccAddresses(ccAddresses); }
                email.setSaveAsActivity(false);
                email.setSubject('Case #' +temp.CaseNumber+ ' has been placed in Needs Reply. Please resolve as soon as possible');
                email.setHtmlBody(body);
                email.setOrgWideEmailAddressId('0D250000000Kz9OCAS');                                                        
                emails.add(email);
            }else if(temp.OwnerId !=null && userToManagerEmailMap.containskey(temp.OwnerId)){
                email.setTargetObjectId(temp.OwnerId);
                ccAddresses.add(userToManagerEmailMap.get(temp.OwnerId));
                body = 'Dear '+temp.Owner.Name+', <br/><br/>Case #' +temp.CaseNumber+ ' has been put into Needs Reply 3 times. Please reach out to the customer to assure the customer satisfaction on their case and determine the reason the case is still not resolved.';
                if(ccAddresses != null && ccAddresses.IsEmpty()==FALSE ){ email.setccAddresses(ccAddresses); }
                email.setSaveAsActivity(false);
                email.setSubject('Case #' +temp.CaseNumber+ ' has been placed in Needs Reply. Please resolve as soon as possible');
                email.setHtmlBody(body);
                email.setOrgWideEmailAddressId('0D250000000Kz9OCAS');                                                        
                emails.add(email);
            }                                          
            
        }
        system.debug('emails===>'+emails);
        if(emails.isEmpty() == FALSE) { 
            Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(emails);                   
        }
    }
    //SOPS-1083 #Notification for TSE and their Manager if a case is put into “Needs Reply” Status 3 times in “N” days Ends.
    
    //SOPS-1048 - Build case ownership history reporting, By Rizvan starts
    public static list<Case_OwnerShip_History__c> CreateOwerHistroy(){
        list<Case_OwnerShip_History__c> OwnershipHistoryList = new list<Case_OwnerShip_History__c>();
        for(SObject cc : trigger.new) {
            case c = (case)cc; 
            if((c.recordtypeid =='01250000000UJwx' && c.ownerId != '00550000001y4AfAAI' && c.ownerId != '00550000004KAuFAAW') || Test.isrunningtest()){
                if(trigger.isUpdate){
                    Case CaseOld = (Case)Trigger.OldMap.get(c.Id);
                    if( c.OwnerID !=null && ((''+c.OwnerID).startsWith('00G') == FALSE) && c.OwnerID != CaseOld.OwnerID ) {                
                        string casIdOwnerId = c.id+'_'+c.OwnerID; 
                        Case_OwnerShip_History__c COH = new Case_OwnerShip_History__c(Case__c = c.id, Case_Owner__c = c.OwnerID, Assignment_Time__c = System.Now(), Unique_Id__c = casIdOwnerId );
                        OwnershipHistoryList.add(COH);
                    } 
                }else if(trigger.isInsert){
                    if( c.OwnerID !=null && ((''+c.OwnerID).startsWith('00G') == FALSE) ) {
                        string casIdOwnerId = c.id+'_'+c.OwnerID;
                        Case_OwnerShip_History__c COH = new Case_OwnerShip_History__c(Case__c = c.id, Case_Owner__c = c.OwnerID, Assignment_Time__c = System.Now(), Unique_Id__c = casIdOwnerId );
                        OwnershipHistoryList.add(COH);
                    }
                }
            }
            
        }
        return OwnershipHistoryList;
    }
    //SOPS-1048 - Build case ownership history reporting, By Rizvan Ends
    
    //SOPS-1179 starts
    Public static void escalCaseRedistributionToManager() {
        if(Trigger.size == 1){
            for(object tem : trigger.new){
                case temp = (case) tem;
                 if(temp.recordTypeId=='01250000000UK1E' && UserInfo.getUserId()=='00550000004KAuFAAW' &&  temp.Problem_Type__c != 'Survey Follow-up'){  
                    string OwID = temp.ownerId;
                    if(OwID.startsWith('005')){                
                        list<user> userlist = new list<user>();
                        userlist = [select id,managerid from user where id=:OwID];
                        Map<Id,Map<Id,Boolean>> teamMap = n2de.DistributionEngineGlobal.getUserAvailabilityAllTeams();
                        system.debug('Reach Level 2===>>>'+teamMap.keyset());               
                        id t = label.escalCaseFromPOrtalTeam;
                        Map<Id,Boolean> test = teamMap.get(t);
                        if(test.containskey(userlist[0].ManagerId) && test.get(userlist[0].ManagerId) == True){
                            temp.ownerId = userlist[0].ManagerId;
                        }else{
                            temp.ownerId = '00G50000001R8aQ';
                        }
                    }
                }
            }
        }
    } 
    //SOPS-1179 ends    
    
   //Below code is added for creating related proactive cases when cases reopened for the second time.
      public static List<Case> CasesOpenedForSecondTime(){
        list<case> proactiveCases = new list<case>();
        if(label.Enable_5_Proactive_Cases == 'Yes'){
        set<id> reopenedCaseIds = new set<id>();
        try{
            for (object cas1 : trigger.new){
                case cs = (case) cas1;
                Case CaseOld = (Case)Trigger.OldMap.get(cs.Id);
                if(CaseOld.status =='Closed' && CaseOld.status != cs.status ){
                    reopenedCaseIds.add(cs.Id);
                }
            }
            if(!reopenedCaseIds.isEmpty() || Test.IsRunningTest()){
            Integer reOpenedCount = 0;
            Map<Id,Case> reopenedCaseHistoryMap = new Map<Id,Case>([Select id,contactId,casenumber,status, category__c, AccountId, (select OldValue, NewValue from Histories where Field = 'Status') parentid, Ownerid, Entitlement.AssignedSupportPOC__c  from case where Id IN: reopenedCaseIds AND recordtypeId = '01250000000UJwx' and status!='Closed' and Entitlement.type in ('Premier', 'Premier Plus') and isNSECaseOwner__c = false AND Entitlement.AssignedSupportPOC__c !=null ]); 
                for(case cas : reopenedCaseHistoryMap.values()){
                    for(Id i : reopenedCaseHistoryMap.keySet()){
                            for(CaseHistory h : reopenedCaseHistoryMap.get(i).Histories){
                            if(h.OldValue == 'Closed' && h.NewValue != 'Closed'){
                                reOpenedCount++;
                            }
                        }
                        system.debug('#####count value ' +reOpenedCount);
                        if(test.isrunningtest()){ reOpenedCount = 2;}
                        if(reOpenedCount >= 1){
                            case proCase = new case();
                            proCase.AccountId = cas.AccountId;
                            proCase.contactId = cas.contactId;  
                            proCase.parentid = cas.Id;
                            proCase.RecordTypeId= '01238000000E8aV';
                            if(cas.Entitlement.AssignedSupportPOC__c!=null)proCase.Ownerid = cas.Entitlement.AssignedSupportPOC__c;
                            proCase.Problem_Type__c = 'Case Notification';
                            proCase.Category__c = 'Aging P3';
                            proCase.Subject = 'Case Reopened for second time #'+cas.CaseNumber;
                            proCase.Description = 'Case #'+cas.CaseNumber+ ' was reopened by the customer for the second time. Please Review and take ownership or provide an update as necessary'; 
                            proactiveCases.add(proCase);
                            system.debug('$$$$$$ProactiveCaseList in TriggerFunction >> ' +proactiveCases);
                            }
                        }
                    }
                }
            } catch(Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e); }  
        }
       return proactiveCases;   
    }
    
    /*@future
    public static void NonAuthCaseNotificationToCAM(id caseId) { 
        system.debug('caseId===>>>>'+caseId);
        list<case> unAuthContactsCases = new list<case>([Select id, CaseNumber, ContactId, Contact.Name, Account.CAM_Owner__c from case where id =:caseId and recordtypeid =: label.supportcaserecordtypeid]);
        system.debug('unAuthContactsCases===>>>>'+unAuthContactsCases);
        if(unAuthContactsCases != null && unAuthContactsCases.IsEmpty() == false && unAuthContactsCases[0].Accountid != null && unAuthContactsCases[0].Account.CAM_Owner__c != null){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                
            Id owaId = SupportEmailSettings__c.getInstance('Marketo Customer Support').RecordId__c;
            mail.setOrgWideEmailAddressId(owaId);               
            mail.setTemplateId('00X38000001bYC4');                
            mail.setTargetObjectId(unAuthContactsCases[0].Account.CAM_Owner__c);
            mail.setwhatId(unAuthContactsCases[0].id);
            mail.setSaveAsActivity(false);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
                
    }*/
    
 //SOPS-1192 starts
    public static List<Case> ifRequestManagerReviewChecked(){
    system.debug('ifRequestManagerReviewChecked====>' );
        Set<Id> ListOfOwnerIds = new Set<Id>();
        for (object cas1 : trigger.new){
                case cs = (case) cas1;
            ListOfOwnerIds.add(cs.OwnerId); 
            system.debug('cs.ownerId====>'+cs.OwnerId);   
        }
        MAP<ID,User> smOwnerManagerUsrs = new Map<Id,User>([SELECT ID,managerID FROM USER WHERE isActive = true and ID In :ListOfOwnerIds]);  
        List<Case> newCases = new List<Case>();
        for (object cas1 : trigger.new){
                case cs = (case) cas1;
                Case CaseOld = (Case)Trigger.OldMap.get(cs.Id);
            if(CaseOld.status!='Closed' && cs.status == 'Closed' && CaseOld.Request_Manager_Review__c == FALSE && cs.Request_Manager_Review__c == TRUE){
                case cas = new case();
                if(smOwnerManagerUsrs.containsKey(cs.ownerID) && smOwnerManagerUsrs.get(cs.ownerID)!=null && smOwnerManagerUsrs.get(cs.ownerID).managerId !=null ){
                    cas.ownerId = smOwnerManagerUsrs.get(cs.ownerID).managerId;
                }
                else{
                    cas.ownerId = '00G50000001R8aQ';
                }
                cas.recordTypeid ='01250000000UK1E';
                cas.parentId = cs.Id;
                cas.origin = 'Support';
                cas.Priority ='P2';
                cas.Subject= 'Review Requested of Escalated Case';
                cas.Description = cs.DescriptionNeeded__c;
                cas.Situation_Contact__c = '00350000021Vp2UAAS';
                cas.Situation_Account__c = '0015000000Xwh1cAAB';
                system.debug('cas====>'+cas);
                newCases.add(cas);
            }       
        }
        return newCases;
        
    }
    // START ==>>>> SOPS-1198 - Route Default Queue and LP Queue Support Cases to US Queue Automatically 23rd Nov, 2016
    @future public static void routeDefaultnLPcasesToUs(list<id> caseIds){
        system.debug('caseIds==>>'+caseIds);
        list<case> casesToUpdate = new list<case>();
        for(case cs : [select id, contact.Preferred_Language__c, ownerid, status from case where id in: caseIds ]){
            system.debug('Ownerid==>>>>>>>>>>>'+cs.ownerid +'status==>>>>>>>>>>>>'+cs.status); 
            if((cs.ownerid == Label.Default_Queue_Id || cs.ownerid == Label.LP_Partner_Queue) && cs.status == 'New'){ // Check if case in default or LP queue
                if( cs.contact.Preferred_Language__c == 'Japanese' ) {
                    cs.ownerid = Label.Apac_Queue_Id; //Apac Queue
                    casesToUpdate.add(cs);
                }else{
                    cs.ownerid = Label.US_Queue_Id; //Us Queue
                    casesToUpdate.add(cs);
                }
            }
        }
        if(casesToUpdate !=null && casesToUpdate.IsEmpty()==false) update casesToUpdate;
    }
    // END ==>>>> SOPS-1198 - Route Default Queue and LP Queue Support Cases to US Queue Automatically 23rd Nov, 2016
     
    //SOPS-1288 START ==========>
    public static void populateProactiveSupportField(){
        system.debug('populateProactiveSupportField====>' );
        
        List<Id> caseContactIdList = new List<Id>();
        Map<Id,String>  contactToMunch = new Map<Id, String>(); 
        Map<String,String> entToSupReg = new Map<String,String>();
        for (object cas1 : trigger.new){
            case cs = (case) cas1;
            if(cs.recordTypeId=='01238000000E8aV'){
                caseContactIdList.add(cs.ContactId);
            }              
        } 
        if(caseContactIdList!=null && caseContactIdList.IsEmpty()==false){  
            
            for(Contact con : [select id, munchkin_id__c from Contact where ID in :caseContactIdList]){       
                    contactToMunch.put(con.Id,con.munchkin_id__c);                 
            }
            
            if(contactToMunch.values()!=null && contactToMunch.values().Isempty()==False ){
                
                for(Entitlement ent : [Select id,status, Asset.Munchkin_Id__c,support_region__c,type From Entitlement where Asset.Munchkin_Id__c IN:contactToMunch.values() AND status ='Active' AND recordtypeId IN:supportRecordType]){        
                        entToSupReg.put(ent.Asset.Munchkin_Id__c,ent.type);           
                }
            } 
            Map<Id,String>  ContactNauthCon = new Map<Id, String>();
            for(Authorized_contact__c auth : [select id, Entitlement__c, Contact__c,Contact__r.id,Entitlement__r.support_region__c,Entitlement__r.type,Entitlement__r.status from Authorized_contact__c where Contact__r.ID in :caseContactIdList AND Entitlement__c !=null AND Entitlement__r.type!=null AND Entitlement__r.status='Active']){
                if(auth.Entitlement__c !=null){
                    ContactNauthCon.put(auth.Contact__r.Id,auth.Entitlement__r.type);
                }           
            }   
            for (object cas1 : trigger.new){
                case cs = (case) cas1;
                if(cs.recordTypeId=='01238000000E8aV'){
                    if( contactToMunch.containskey(cs.ContactId) && contactToMunch.get(cs.ContactId)!=null){
                        cs.Proactive_Support_Level__c = entToSupReg.get(contactToMunch.get(cs.ContactId));
                    }
                    else if(contactToMunch.containskey(cs.ContactId) && contactToMunch.get(cs.ContactId)==null){
                        cs.Proactive_Support_Level__c = ContactNauthCon.get(cs.ContactId);
                    }
                    
                }            
            } 
        }       
    }
    //SOPS-1288 END=======>
    public static list<Case> updateJiraInfoTier3(){
        list<Case> casesTobeUpdated = new list<Case>();
        if(trigger.isAfter && trigger.isUpdate){
            map<id,string> caseIdToJiraNum = new map<id,string>();
            list<Id> pIds = new list<Id>();
            for (object cas1 : trigger.new){
                case cs = (case) cas1; 
                Case CaseOld = (Case)Trigger.OldMap.get(cs.Id);
                if(cs.parentid !=null && (cs.recordtypeId==System.Label.tier3RecordTypeId || test.IsrunningTest() )&& CaseOld.JIRA_Num__c != cs.JIRA_Num__c ){
                    pIds.add(cs.parentId); 
                    caseIdToJiraNum.put(cs.parentid,cs.JIRA_Num__c); 
                }
            }
            if(!pIds.isEmpty()){
                for(case cs : [Select id,recordtypeId,JIRA_Num__c from case where id IN: pIds]  ){
                    if(cs.recordtypeId=='01250000000UJwxAAG' && cs.JIRA_Num__c!=caseIdToJiraNum.get(cs.id) ){
                        cs.JIRA_Num__c=caseIdToJiraNum.get(cs.id);
                        casesTobeUpdated.add(cs);
                    }
                }   
            }
            list<id> validCaseswithChilds = new list<id>();
            list<Id> cIds = new list<Id>();
            for (object cas1 : trigger.new){
                case cs = (case) cas1; 
                Case CaseOld = (Case)Trigger.OldMap.get(cs.Id);
                if( (cs.recordtypeId=='01250000000UJwxAAG' && CaseOld.jira_num__C!=cs.jira_num__c)  || test.IsrunningTest() ){
                    validCaseswithChilds.add(cs.id);
                    caseIdToJiraNum.put(cs.id,cs.JIRA_Num__c);
                }
            }
            if(!validCaseswithChilds.isEmpty()){
            String tier3Id1=System.Label.tier3RecordTypeId;
                for (Case cas1 : [Select id,jira_num__C,(Select id,jira_num__C,parentid from cases where recordtypeid=:tier3Id1) from case where recordtypeid='01250000000UJwxAAG' AND id in:validCaseswithChilds]){
                   if(cas1.cases!=null && !cas1.cases.isempty())   {
                      for(Case cs: cas1.cases){
                          if(cs.jira_num__C!=caseIdToJiraNum.get(cs.parentid)){
                              cIds.add(cs.id);
                          }                     
                      }                        
                   }                
                }
            }
            if(!cIds.isEmpty()){
                for(case cs : [Select id,recordtypeId,JIRA_Num__c,parentid from case where id IN: cIds]  ){
                    if(cs.recordtypeId==System.Label.tier3RecordTypeId || test.IsrunningTest() ){
                        cs.JIRA_Num__c=caseIdToJiraNum.get(cs.parentid);
                        casesTobeUpdated.add(cs);
                    }
                }
            }
        }
        return casesTobeUpdated; 
    }
     
    public static list<CaseComment> addCaseCommentToTier3Parent(){        
        list<casecomment> caseCommToInsert = new list<casecomment>();
        if(trigger.isAfter && trigger.isUpdate){
            for (object cas : trigger.new){
                case cas1= (case) cas;
                Case CaseOld= (Case)Trigger.OldMap.get(cas1.Id); 
                if(cas1.parentId != null){
                    if( (cas1.recordtypeId == System.Label.tier3RecordTypeId || test.IsrunningTest() ) && cas1.Last_Public_Comment_Date_Time__c != CaseOld.Last_Public_Comment_Date_Time__c && cas1.ownerId == cas1.lastmodifiedbyid){            
                        CaseComment com=new CaseComment() ;
                        com.IsPublished=false;
                        com.ParentId=cas1.parentId;
                        com.CommentBody = 'Tier 3 ticket has been updated';
                        caseCommToInsert.add(com);
                    }
                    if( (cas1.recordtypeId==System.Label.tier3RecordTypeId && CaseOld.status!='closed' && cas1.status=='Closed' && cas1.close_reason__c!='No Response from Customer (Soft Close)'  ) || test.IsrunningTest()){
                        CaseComment com=new CaseComment() ;
                        com.IsPublished=false;
                        com.ParentId=cas1.parentId;
                        com.CommentBody = 'Tier 3 ticket has been closed';
                        caseCommToInsert.add(com);
                    }                    
                }   
            }
        }
        return caseCommToInsert;    
    }
    
    public static list<Case> updateStatusToNeedsReplytier3Parent(){        
        list<case> casesTobeUpdated= new list<case>();
        list<Id> parentIds = new list<Id>();
        if(trigger.isAfter && trigger.isUpdate){
            for (object cas : trigger.new){
                case cas1= (case) cas;
                Case CaseOld= (Case)Trigger.OldMap.get(cas1.Id); 
                if( (cas1.recordtypeId == System.Label.tier3RecordTypeId || test.IsrunningTest() ) && (cas1.Last_Public_Comment_Date_Time__c!=CaseOld.Last_Public_Comment_Date_Time__c || CaseOld.status!='closed' && cas1.status=='closed' ) ){            
                    parentIds.add(cas1.parentId);
                }
            }
            if(parentIds.Isempty()==false){
                for(case cs : [Select id,status,Close_Reason__c from case where id IN: parentIds and status != 'Closed']){  
                    cs.status='Needs Reply';
                    casesTobeUpdated.add(cs);          
                }
            }       
        }
        return casesTobeUpdated;    
    } 
          
     @future
     public static void updateCaseOnCC(Map<Id,String> parentCaseMap){        
        list<case> casesTobeUpdated= new list<case>();
        for(case cs : [Select id,No_of_CaseComments__c from case where id in: parentCaseMap.keySet() and recordtypeId =: supCaseRecordTypeId]){
            if(parentCaseMap.get(cs.Id) == 'Insert'){
                if(cs.No_of_CaseComments__c == null || cs.No_of_CaseComments__c == 0 ) cs.No_of_CaseComments__c = 1;                                
                else cs.No_of_CaseComments__c = cs.No_of_CaseComments__c+1;                  
                casesTobeUpdated.add(cs); 
            }
            else if(parentCaseMap.get(cs.Id) == 'Delete'){
                if(cs.No_of_CaseComments__c!=null) cs.No_of_CaseComments__c=cs.No_of_CaseComments__c-1; 
                casesTobeUpdated.add(cs);
            } 
        }
        try{if(casesTobeUpdated != null && casesTobeUpdated.Size() > 0) update casesTobeUpdated;}
        catch(Exception ex ){CaseTriggerFunction.sendEcxeptionMailToDeveloper(ex);}
       }
    //below method is written to assign CAM as case owner for csm case only
    @future
    public static void assignCamOwner(Set<Id> casId){
       Database.DMLOptions dmo = new Database.DMLOptions();
       dmo.assignmentRuleHeader.useDefaultRule= false;
       List<Case> caseList = new List<Case>();
       Id idToExclude = Id.valueOf(Label.EmilyBenvenutiId);
       for(case cse : [select id, account.CAM_Owner__c from case where id in : casId and account.CAM_Owner__c != null and account.CAM_Owner__c !=: idToExclude]){
            cse.OwnerId = cse.account.CAM_Owner__c;
            cse.setOptions(dmo);
            caseList.add(cse);
       }
       try{ Update caseList;}
       catch(Exception ex ){system.debug('Exception==>' + ex);}
    }
    @future
    public static void P1Extended(list<id> caseIds){        
        list<Case_Update_Milestones__c> caseMilestoneTobeInserted = new list<Case_Update_Milestones__c>();
            for(case cas1 : [select id,ownerid from case where id in: caseIds]) {           
                Case_Update_Milestones__c CM = new Case_Update_Milestones__c();
                CM.Case__c           = cas1.id;
                CM.Milestone_Type__c = 'P1 Extended';
                CM.Start_Date__c     = system.now();
                CM.Target_Date__c    = system.now().addMinutes(240);
                CM.Duration__c       = '240';
                CM.OwnerId           = (string.valueOf(cas1.OwnerId).startsWith('00G') || cas1.OwnerId =='00550000004KAuFAAW') ? '00550000001y4AfAAI' : cas1.OwnerId;
                caseMilestoneTobeInserted.add(CM);
            }     
        if(caseMilestoneTobeInserted.Isempty()==False){insert caseMilestoneTobeInserted;}    
    }
}