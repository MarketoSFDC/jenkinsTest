/*******************************************************************
*Modified By: Sumit Bhatt, Grazitti Interactive
*Purpose: REF: #APPS-18580# Update Test Classes
*Tracking: One cn track the changes by searching ticket number in code
*******************************************************************/

public class CSatSurvey{
    
    public Static Boolean executionFlag{get;set;}
    
    @future
    public static void sendSurveyEmails(String templateName, List<String>  targetCaseIds) {
        List<Case> targetCases = [Select Id, ContactId,SurveyLinkEmailerSent__c from Case where ID in:targetCaseIds ];
        System.Debug('CSatSurvey.templateName'+templateName);
        EmailTemplate emailTemplate  = [Select id from EmailTemplate where name =:templateName];
        OrgWideEmailAddress owa      = [select id, DisplayName, Address from OrgWideEmailAddress where DisplayName='Marketo Support Feedback'];
        
        // Check if the template exists
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        for (Case caseItr:targetCases) {
            Messaging.SingleEmailMessage mail     = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(caseItr.contactId);
            mail.setTemplateID(emailTemplate.Id); 
            mail.setWhatId(caseItr.Id);
            mail.setSaveAsActivity(false);
            mail.setOrgWideEmailAddressId(owa.id);
            allmsg.add(mail);
            caseItr.SurveyLinkEmailerSent__c = true;
        }
        System.Debug('TARGETRECPS'+allmsg);
        List<Messaging.SendEmailResult> mailResult = Messaging.sendEmail(allmsg, false);
        System.Debug('MAILRESULT'+mailResult);
        System.Debug('MAILRESULT'+mailResult.get(0).success);        
        //System.Debug('MAILRESULT'+mailResult.get(0).getErrors()[0].getMessage());
        update targetCases;
    }
    
    /*
    public static List<CSatSurveyFeedback__c> surveyFeedbackForCaseByContact(Id caseId, Id contactId) {
        List<CSatSurveyFeedback__c> cSatFeedback = [Select Id from CSatSurveyFeedback__c where Case__c=:caseId AND Contact__c=:contactId];
        return cSatFeedback;
    }
    */
    /*
    public static Integer countSurveyFeedbackByContactInCurrentMonth(Id contactId) {
        return Database.countQuery('Select COUNT() from CSatSurveyFeedback__c where Contact__c=\''+contactId+'\' and lastmodifieddate = THIS_MONTH');
    }
    */
    
    public static Integer countSurveyOnCaseByContact(Id caseId, Id contactId) {
        return Database.countQuery('Select COUNT() from CSatSurveyFeedback__c where Contact__c=\''+contactId+'\' and Case__c=\''+caseId+'\'');
    }
    
    public static List<CSatSurveyFeedback__c> getSurveyFeedbackByContact(Id contactId){
        return [Select Id, case__c, lastmodifieddate from CSatSurveyFeedback__c where Contact__c=:contactId];
    }
    
    public Static Map<Id, Boolean> getContactsToSurveyEligibilityMap(List<ID> contactIds) {
    
        
        // Does contact exist in Authorized_contact__c
        // Authorized_contact__c.entitlement.type != internal
        // Authorized_contact__c.assetid.type     = purpose 
    
        Map <Id, Boolean> contactIdsToSurveyEligibilityMap = new Map<Id, Boolean>();

        List<Authorized_Contact__c> authorizedContacts = [Select a.Id, a.Entitlement__r.AssetId, a.Entitlement__r.Type, a.Entitlement__c,a.contact__c From Authorized_Contact__c a where  a.Entitlement__r.Status = 'Active'  AND  contact__c in:contactIds];      
        List<id> relatedAssetIds                   = new List<Id>();
        Map<id, id> contactIdToAssetId             = new Map<Id,Id>();
        Map<id, String> contactIdToEntitlementType = new Map<Id, String>();
           
        for (Authorized_Contact__c authCon:authorizedContacts) {
            relatedAssetIds.add(authCon.Entitlement__r.AssetId);
            contactIdToAssetId.put(authCon.contact__c,authCon.Entitlement__r.AssetId);
            contactIdToEntitlementType.put(authCon.contact__c, authCon.Entitlement__r.Type); 
        }
        
        Map <Id,Asset> assets = new Map<Id,Asset>([Select a.Purpose__c, a.AccountId From Asset a where a.id in:relatedAssetIds]); 
        system.debug('****assets******' + assets );
        system.debug('****entitlementtype******' + contactIdToEntitlementType);
        for (Id contactId:contactIds) {
            if (
                (contactIdToAssetId.containsKey(contactId)) &&  
                (assets.containsKey(contactIdToAssetId.get(contactId))) &&
                (assets.get(contactIdToAssetId.get(contactId)).Purpose__c == 'Production' || assets.get(contactIdToAssetId.get(contactId)).Purpose__c == 'Rubiks Production') &&
                (contactIdToEntitlementType.containsKey(contactId)) &&
                (contactIdToEntitlementType.get(contactId) != 'internal')
            )   
            {            
                contactIdsToSurveyEligibilityMap.put(contactId, true);                                
            } else {      //Bikram added starts                     
                if((contactIdToEntitlementType.containsKey(contactId)) && (contactIdToEntitlementType.get(contactId) != null)  && (contactIdToEntitlementType.get(contactId) != 'internal') && contactIdToAssetId.containsKey(contactId) && contactIdToAssetId.get(contactId) == null) //Bikram added starts
                    contactIdsToSurveyEligibilityMap.put(contactId, null);
                else  //Bikram added ends
                    contactIdsToSurveyEligibilityMap.put(contactId, false); //original line               
            }
        }        
        return contactIdsToSurveyEligibilityMap;    
    }
    
    @future
    public static void updateCSatOwners(Map<Id,Id> csatToCaseIdMap) {        
        Map<Id,CSatSurveyFeedback__c> csatMap = new Map<Id,CSatSurveyFeedback__c>([select Id,OwnerId,Case__c from CSatSurveyFeedback__c where Id in: csatToCaseIdMap.keyset()]);
        Map<Id,Case> caseMap = new Map<Id,Case>([select Id,OwnerId from Case WHERE Id in: csatToCaseIdMap.values()]);
        
        List<CSatSurveyFeedback__c> csatUpdLst = new List<CSatSurveyFeedback__c>();
        for(Id csatID :csatMap.keySet())               
        {
            CSatSurveyFeedback__c cs = csatMap.get(csatID);
            if(caseMap.containsKey(cs.Case__c)  && csatToCaseIdMap.containsKey(cs.Id))
            {   
                cs.OwnerId = caseMap.get(csatToCaseIdMap.get(cs.Id)).OwnerId;
                csatUpdLst.add(cs);
            }
        }
        if(!csatUpdLst.isEmpty()){ 
            if(!test.isRunningTest())
                update csatUpdLst;            
        }
    }      
    
    @isTest(SeeAllData=true)
    public static void testMails() { 
        
        List<Case> tempCaseList = [Select Id, ContactId, AccountId from Case where ContactId != null AND AccountId != null and Problem_Type__c = 'Other' limit 1];
         
        CSatSurvey csSurveyController = new CSatSurvey();
		//APPS-18580
        //CSatSurvey.sendSurveyEmails('CSatSurveyEnglish', new List<Id>{tempCaseList.get(0).Id});
		CSatSurvey.sendSurveyEmails('CSatSurvey Email Template', new List<Id>{tempCaseList.get(0).Id});
		//APPS-18580
        CSatSurvey.countSurveyOnCaseByContact(tempCaseList.get(0).Id, tempCaseList.get(0).ContactId);
        CSatSurvey.getSurveyFeedbackByContact(tempCaseList.get(0).ContactId);
        CSatSurvey.getContactsToSurveyEligibilityMap(new List<Id>{tempCaseList.get(0).ContactId});
    }
    
    @isTest(SeeAllData=true)
    public static void testTriggerOne() { 
        
        List<Case> tempCaseList = [Select Id, ContactId, AccountId from Case where ContactId != null AND AccountId != null limit 1];
        Case tempCase = new case(ContactId = tempCaseList.get(0).contactId, AccountId = tempCaseList.get(0).accountId, status='new', subject='Test Case', problem_type__c = 'Other');
        insert tempcase;
        System.debug('CASE STATUS'+tempcase.status);        
        tempcase.status = 'closed';
        update tempcase; 
    }
    
    @isTest(SeeAllData=true)
    public static void testTriggerTwo(){
        List<Case> tempCaseList2 = [Select Id, ContactId, AccountId from Case where ContactId != null AND AccountId != null and status != 'closed'  limit 1];
        if (tempCaseList2.size() > 0) {
            tempCaseList2.get(0).Problem_Type__c = 'Other';
            tempCaseList2.get(0).status = 'closed';
            update tempCaseList2; 
            Case tempcase1 = tempCaseList2.get(0);
            CSatSurveyFeedback__c cf = new CSatSurveyFeedback__c(case__c=tempcase1.id, contact__c=tempcase1.contactid, account__c=tempcase1.accountid, question_1__c='2', question_7__c='test', uniqueid__c=''+System.now(), contact_support_manager__c = 'Yes');
            insert cf;
        }        
        
        //CSatSurvey csSurveyController = new CSatSurvey();
        //CSatSurvey.sendSurveyEmails('CSatSurveyEnglish', new List<Id>{tempCaseList.get(0).Id});
        //CSatSurvey.countSurveyOnCaseByContact(tempCaseList.get(0).Id, tempCaseList.get(0).ContactId);
        //CSatSurvey.getSurveyFeedbackByContact(tempCaseList.get(0).ContactId);
        //CSatSurvey.getContactsToSurveyEligibilityMap(new List<Id>{tempCaseList.get(0).ContactId});
    }    
}