/*
 * This class needs to be scheduled in order for it to run.
 *
 * The following code can be executed anonymously via the
 * System Log to schedule this class to run:
 *
 * // Run Monday - Friday at 6AM.
 * System.Schedule('Case Aged Emailer',  '0 0 6 ? * MON-FRI', new CaseAgedNotifyEmailScheduler());
 *
 * // Run on demand.
  CaseAgedNotifyEmailScheduler schedulable = new CaseAgedNotifyEmailScheduler();
  schedulable.execute(null);
 */
global class CaseAgedNotifyEmailScheduler implements Schedulable {
    
    global void execute(SchedulableContext context) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        String typeCaseRecord = '01250000000UJwx';
        List<Case> agedCases = [SELECT Id,CaseNumber,OwnerID,AgeinDays__c FROM CASE WHERE AgeInDays__c in (30) AND OwnerId != NULL AND isClosed = false AND recordType.Id = :typeCaseRecord  ORDER BY AgeInDays__c DESC Limit 10000];
		
		
        //1List<Case> agedCases = [SELECT Id,CaseNumber,OwnerId,AgeinDays__c FROM CASE WHERE OwnerId = '00550000001m8mNAAQ' AND Account.Id = '0015000000fD2sO' AND isClosed = false AND recordType.Id = '01250000000UJwx' ORDER BY AgeInDays__c DESC Limit 50000];                
        /*
		Map<Id,User> caseOwnerToManagerMap = new Map<Id,User>();        
		for(Case ageCase : agedCases) {
            if(ageCase.OwnerId != NULL && !String.valueof(ageCase.OwnerID).startsWith('00G') && ageCase.AgeinDays__c == 45) {            
                caseOwnerToManagerMap.put(ageCase.ownerId,NULL);
            }
        } 		
        caseOwnerToManagerMap  = new Map<Id,User>([SELECT Id, ManagerId from User WHERE Id in : caseOwnerToManagerMap.keySet()]);
        */
        if(Test.isRunningTest()){
			agedCases = [SELECT Id,CaseNumber,OwnerID,AgeinDays__c FROM CASE WHERE OwnerId != NULL AND isClosed = false AND recordType.Id = :typeCaseRecord  ORDER BY AgeInDays__c Limit 10000];		
		}
		
		
		Id EmailTemplateId = [select Id from EmailTemplate where DeveloperName = 'Case_Aging_Notification'].Id;
        Map<Id,User> notifyLst = new Map<Id,User>([SELECT Id, Email from User where isactive = true and Id in :System.Label.Backlog_Alert_Receiver_List.split(',')]);
        for (Case ageCase : agedCases) {
            if (ageCase.OwnerId != NULL && !String.valueof(ageCase.OwnerID).startsWith('00G') && ageCase.AgeinDays__c == 30) {            
                emails.add(createEmail(EmailTemplateId, ageCase.Id, ageCase.OwnerId));
            } else if(ageCase.OwnerId == NULL || String.valueof(ageCase.OwnerID).startsWith('00G')) {
                emails.addAll(createEmail(EmailTemplateId, ageCase.Id, notifyLst.keySet()));            
            }
        }
        if(emails.isEmpty() == FALSE) {
            sendCaseAgeNotificationEmail(emails);
        }
        
    }    
    
    public static List<Messaging.SingleEmailMessage> createEmail(Id templateId, Id whatId, Set<Id> targetIds) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for(Id targetId : targetIds)    
        {
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            email.setTemplateId(templateId);        
            email.setTargetObjectId(targetId);
            email.setWhatId(whatId);
            email.setSaveAsActivity(false);
            //email.setOrgWideEmailAddressId(FROM_EMAIL_ID);
            emails.add(email);
        }        
        return emails;
    }
    
    public static Messaging.SingleEmailMessage createEmail(Id templateId, Id whatId, Id targetId) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(templateId);        
        email.setTargetObjectId(targetId);
        email.setWhatId(whatId);
        email.setSaveAsActivity(false);
        //email.setOrgWideEmailAddressId(FROM_EMAIL_ID);
        return email;
    }
    
    public static void sendCaseAgeNotificationEmail(List<Messaging.SingleEmailMessage> emails) {        
        //Id FROM_EMAIL_ID = '';        
        try {
            Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(emails);          
            LIST<Messaging.SendEmailError> emailErrors ;
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