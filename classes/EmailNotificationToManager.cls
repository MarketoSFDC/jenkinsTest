public class EmailNotificationToManager {

    public static List<Messaging.SendEmailResult> mailResult{get;set;}
    public static List<Store_Cases_For_Month__c> listOfStoredCasesToBeUpdated = new List<Store_Cases_For_Month__c>();
    public Static Set<Id> setOfManagersWithActivityLog;
 
    

    public static void sendEmailReminder(Set<Id> targetActivLogManager){
        System.Debug('I AM IN MAILER CODE');
        EmailTemplate emailTemplate  = [Select id from EmailTemplate where name = 'Case Quality InComplete Notification'];
        OrgWideEmailAddress owa = [Select id, displayname from OrgWideEmailAddress where displayname='Marketo Customer Support'];
        Map<Id,User> mapOfUserToManager = new Map<Id,User>([SELECT Id, ManagerId, Manager.Email from User where ID in: targetActivLogManager]);        
        String ccAddress = label.Case_Quality_Review_CC_List;
        String[] ccAddresses = ccAddress.split(';');        
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();        
        for(Id tmpKey : mapOfUserToManager.keySet()) {
            User manItr = mapOfUserToManager.get(tmpKey);
            Messaging.SingleEmailMessage message  = new Messaging.SingleEmailMessage();
            //ccAddresses.add(mapOfUserToManager.get(manItr.ID).Manager.Email);
            Id tempId = manItr.Id;
            System.Debug('___Temp User ID__'+tempId);
            message.setTargetObjectId(tempId);
            message.setOrgWideEmailAddressId(owa.id);
            message.setCcAddresses(ccAddresses);
            message.setTemplateId(emailTemplate.Id);
            message.setWhatId(manItr.Id);
            message.setSaveAsActivity(false);
            allmsg.add(message);            
        }        
        mailResult = Messaging.sendEmail(allmsg, false);
        System.Debug('I AM IN MAILER CODE'+mailResult);
        List<Messaging.SendEmailError> isEmailFailed = new List<Messaging.SendEmailError>();
        for(Messaging.SendEmailResult singlemEmailResult : mailResult){
            isEmailFailed.addAll(singlemEmailResult.getErrors());
        }
    }
    
    public static void sendEmailFirstReminder(Set<Id> targetActivLogManager){
        System.Debug('I AM IN MAILER CODE');
        EmailTemplate emailTemplate  = [Select id from EmailTemplate where name = 'Case Quality Created Notification'];
        OrgWideEmailAddress owa = [Select id, displayname from OrgWideEmailAddress where displayname='Marketo Customer Support'];
        Map<Id,User> mapOfUserToManager = new Map<Id,User>([SELECT Id, ManagerId, Manager.Email from User where ID in: targetActivLogManager]);        
        String ccAddress = label.Case_Quality_Review_CC_List;
        String[] ccAddresses = ccAddress.split(';');        
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();        
        for(Id tmpKey : mapOfUserToManager.keySet()) {
            User manItr = mapOfUserToManager.get(tmpKey);
            Messaging.SingleEmailMessage message  = new Messaging.SingleEmailMessage();
            Id tempId = manItr.Id;
            System.Debug('___Temp User ID__'+tempId);
            message.setTargetObjectId(tempId);
            message.setOrgWideEmailAddressId(owa.id);
            message.setCcAddresses(ccAddresses);
            message.setTemplateId(emailTemplate.Id);
            message.setWhatId(manItr.Id);
            message.setSaveAsActivity(false);
            allmsg.add(message);            
        }        
        mailResult = Messaging.sendEmail(allmsg, false);
        System.Debug('I AM IN MAILER CODE'+mailResult);
        List<Messaging.SendEmailError> isEmailFailed = new List<Messaging.SendEmailError>();
        for(Messaging.SendEmailResult singlemEmailResult : mailResult){
            isEmailFailed.addAll(singlemEmailResult.getErrors());
        }
    }
    
    
    
    

    public static void fetchDefaulterManager() {
        setOfManagersWithActivityLog = new Set<Id>();
        //Variable Initialization
        List<Store_Cases_For_Month__c> sendNotificationForFirstTime     = new List<Store_Cases_For_Month__c>();
        List<Store_Cases_For_Month__c> sendFollowUpNotifications        = new List<Store_Cases_For_Month__c>();
        List<Manger_Activity_Log__c> finalManagerListToBeMailed         = new List<Manger_Activity_Log__c>();
        Set<Id> sendNotificationForFirstTimeManagerIds                  = new Set<Id>();
        //Set<Id> sendFollowUpNotificationsManagerIds                     = new Set<Id>();
        List<Store_Cases_For_Month__c> finalCasesListFromLastMonth      = new List<Store_Cases_For_Month__c>();
        Set<Id> finalManagerActivityLogIds                              = new Set<Id>();

        Integer daysBefore = 7;        
        try {
            daysBefore = Integer.valueof(System.Label.CaseQualityReviewReminderDays);
        } catch (Exception ex) {
            system.debug('Exception==>' + ex);
        }                
        //Set current month last date.
        Date lastDtofMnth = Date.today().toStartOfMonth().addMonths(1).addDays(-1);                
        Date plusAddedDays = Date.Today().addDays(daysBefore);//Added 7 days pending check.
        
        
        if(plusAddedDays != lastDtofMnth && !test.isRunningTest()) return;
        
        
        //Fetching Raw Data For Processing
        //List<Store_Cases_For_Month__c> rawCasesInProgressFromLastMonth  = [Select Manager_Reminded__c, Manger_Activity_Log__c from Store_Cases_For_Month__c where Evaluation_Status__c = 'Evaluate' AND Manger_Activity_Log__r.Id ='aAh500000004CK6'];
        //List<Store_Cases_For_Month__c> rawCasesInProgressFromLastMonth  = [Select Manager_Reminded__c, Manger_Activity_Log__c from Store_Cases_For_Month__c where Evaluation_Status__c = 'Evaluate' AND Evaluation_Ended__c <: dt];   //=: date.newinstance(System.now().year(), System.now().month(), System.now().day())];
        List<Store_Cases_For_Month__c> rawCasesInProgressFromLastMonth  = [Select Manager_Reminded__c, Manger_Activity_Log__c from Store_Cases_For_Month__c where Evaluation_Status__c = 'Evaluate' AND Evaluation_Ended__c <=: plusAddedDays];   //=: date.newinstance(System.now().year(), System.now().month(), System.now().day())];

        System.Debug('_____rawCasesInProgressFromLastMonth______'+rawCasesInProgressFromLastMonth);
        //Fetching Raw Data For Processing
        //Populating two separate list's for first time notification and repetitive notification        
        for(Store_Cases_For_Month__c caseUnderProcessing : rawCasesInProgressFromLastMonth){
            if(true){
                sendNotificationForFirstTime.add(caseUnderProcessing);
                caseUnderProcessing.Manager_Reminded__c = System.now();
                listOfStoredCasesToBeUpdated.add(caseUnderProcessing);
            }
            /*else {
                sendFollowUpNotifications.add(caseUnderProcessing);
            }*/
        }
        //Populating two separate list's for first time notification and repetitive notification
        
        //Remove Cases for which notification has been sent within 3 days
        //List<Store_Cases_For_Month__c> threeDaysPassedSinceFollowUp = isValidForResending(sendFollowUpNotifications);
        //Remove Cases for which notification has been sent within 3 days
        
        //Master List For Valid Stored Cases For Last Month Demanding Notification(EITHER FIRST TIME OR REPETETIVE)
        finalCasesListFromLastMonth.addAll(sendNotificationForFirstTime);
        //finalCasesListFromLastMonth.addAll(threeDaysPassedSinceFollowUp);          
        //Master List For Valid Stored Cases For Last Month Demanding Notification(EITHER FIRST TIME OR REPETETIVE)
        
        //Populate Set Of Manager Activity Ids In Set
        for(Store_Cases_For_Month__c caseUnderProcessing : finalCasesListFromLastMonth){
            finalManagerActivityLogIds.add(caseUnderProcessing.Manger_Activity_Log__c);
        }
        //Populate Set Of Manager Activity Ids IN Set        
        
        finalManagerListToBeMailed = [Select Id, OwnerId, SupportManager__c,SupportManager__r.Manager.email from Manger_Activity_Log__c Where Id IN : finalManagerActivityLogIds];
        //finalManagerListToBeMailed = [Select Id, OwnerId, SupportManager__c from Manger_Activity_Log__c Where Id = 'aAiW000000001HiKAI'];
        
        for(Manger_Activity_Log__c  tmp: finalManagerListToBeMailed) {
            setOfManagersWithActivityLog.add(tmp.SupportManager__c);
        }
        
        System.Debug('______sendNotificationForFirstTime_______'+sendNotificationForFirstTime);
        //System.Debug('______sendFollowUpNotifications__________'+sendFollowUpNotifications);    
        System.Debug('______finalManagerActivityLogIds_________'+finalManagerActivityLogIds);    
        System.Debug('______finalManagerListToBeMailed_________'+finalManagerListToBeMailed);    
        
        //Send Email Method
        //If(!finalManagerListToBeMailed.isEmpty())
        If(!setOfManagersWithActivityLog.isEmpty()){
            sendEmailReminder(setOfManagersWithActivityLog);
            System.Debug('_____setOfManagersWithActivityLog_____'+setOfManagersWithActivityLog);
        } 
        //Send Email Method                
    } 
    
    public static void fetchFreshReviewsForManager() {
        setOfManagersWithActivityLog = new Set<Id>();
        //Variable Initialization
        List<Store_Cases_For_Month__c> sendNotificationForFirstTime     = new List<Store_Cases_For_Month__c>();
        List<Store_Cases_For_Month__c> sendFollowUpNotifications        = new List<Store_Cases_For_Month__c>();
        List<Manger_Activity_Log__c> finalManagerListToBeMailed         = new List<Manger_Activity_Log__c>();
        Set<Id> sendNotificationForFirstTimeManagerIds                  = new Set<Id>();
        List<Store_Cases_For_Month__c> finalCasesListFromLastMonth      = new List<Store_Cases_For_Month__c>();
        Set<Id> finalManagerActivityLogIds                              = new Set<Id>();

        //Fetching Raw Data For Processing
        List<Store_Cases_For_Month__c> rawCasesInProgressFromLastMonth  = [Select Manager_Reminded__c, Manger_Activity_Log__c from Store_Cases_For_Month__c where Evaluation_Status__c = 'Evaluate' AND CreatedDate = Today];
        System.Debug('_____rawCasesInProgressFromLastMonth______'+rawCasesInProgressFromLastMonth);
        //Fetching Raw Data For Processing
        //Populating two separate list's for first time notification and repetitive notification        
        for(Store_Cases_For_Month__c caseUnderProcessing : rawCasesInProgressFromLastMonth){
            sendNotificationForFirstTime.add(caseUnderProcessing);
        }        
        finalCasesListFromLastMonth.addAll(sendNotificationForFirstTime);
        //Populate Set Of Manager Activity Ids In Set
        for(Store_Cases_For_Month__c caseUnderProcessing : finalCasesListFromLastMonth){
            finalManagerActivityLogIds.add(caseUnderProcessing.Manger_Activity_Log__c);
        }
        //Populate Set Of Manager Activity Ids IN Set        
        
        finalManagerListToBeMailed = [Select Id, OwnerId, SupportManager__c,SupportManager__r.Manager.email from Manger_Activity_Log__c Where Id IN : finalManagerActivityLogIds];
        //finalManagerListToBeMailed = [Select Id, OwnerId, SupportManager__c from Manger_Activity_Log__c Where Id = 'aAiW000000001HiKAI'];
        
        for(Manger_Activity_Log__c  tmp: finalManagerListToBeMailed) {
            //if(tmp.SupportManager__c == '00538000004bIFs')    
            setOfManagersWithActivityLog.add(tmp.SupportManager__c);
        }
        
        System.Debug('______sendNotificationForFirstTime_______'+sendNotificationForFirstTime);
        System.Debug('______finalManagerActivityLogIds_________'+finalManagerActivityLogIds);    
        System.Debug('______finalManagerListToBeMailed_________'+finalManagerListToBeMailed);    
        
        //Send Email Method
        //If(!finalManagerListToBeMailed.isEmpty())
        If(!setOfManagersWithActivityLog.isEmpty()){
            sendEmailFirstReminder(setOfManagersWithActivityLog);
            System.Debug('_____sendEmailFirstReminder__setOfManagersWithActivityLog___'+setOfManagersWithActivityLog);
        } 
        //Send Email Method                
    } 
 
 
    
    
    /*
    public static void fetchDefaultedManagerLogActivities(){
    
        //Variable Initialization
        List<Store_Cases_For_Month__c> sendNotificationForFirstTime     = new List<Store_Cases_For_Month__c>();
        List<Store_Cases_For_Month__c> sendFollowUpNotifications        = new List<Store_Cases_For_Month__c>();
        List<Manger_Activity_Log__c> finalManagerListToBeMailed         = new List<Manger_Activity_Log__c>();
        Set<Id> sendNotificationForFirstTimeManagerIds                  = new Set<Id>();
        Set<Id> sendFollowUpNotificationsManagerIds                     = new Set<Id>();
        List<Store_Cases_For_Month__c> finalCasesListFromLastMonth      = new List<Store_Cases_For_Month__c>();
        Set<Id> finalManagerActivityLogIds                              = new Set<Id>();
        //Variable Initialization
            
        //Fetching Raw Data For Processing
        //List<Store_Cases_For_Month__c> rawCasesInProgressFromLastMonth  = [Select Manager_Reminded__c, Manger_Activity_Log__c from Store_Cases_For_Month__c where Evaluation_Status__c = 'Evaluate' AND Manger_Activity_Log__r.Id ='aAh500000004CK6'];
        List<Store_Cases_For_Month__c> rawCasesInProgressFromLastMonth  = [Select Manager_Reminded__c, Manger_Activity_Log__c from Store_Cases_For_Month__c where Evaluation_Status__c = 'Evaluate' AND Evaluation_Ended__c <=: date.newinstance(System.now().year(), System.now().month(), System.now().day())];
        System.Debug('_____rawCasesInProgressFromLastMonth______'+rawCasesInProgressFromLastMonth);
        //Fetching Raw Data For Processing
        
        //Populating two separate list's for first time notification and repetitive notification
        for(Store_Cases_For_Month__c caseUnderProcessing : rawCasesInProgressFromLastMonth){
            if(true){
                sendNotificationForFirstTime.add(caseUnderProcessing);
                caseUnderProcessing.Manager_Reminded__c = System.now();
                listOfStoredCasesToBeUpdated.add(caseUnderProcessing);
            } else {
                sendFollowUpNotifications.add(caseUnderProcessing);
            }
        }
        //Populating two separate list's for first time notification and repetitive notification
        
        //Remove Cases for which notification has been sent within 3 days
        List<Store_Cases_For_Month__c> threeDaysPassedSinceFollowUp = isValidForResending(sendFollowUpNotifications);
        //Remove Cases for which notification has been sent within 3 days
        
        //Master List For Valid Stored Cases For Last Month Demanding Notification(EITHER FIRST TIME OR REPETETIVE)
        finalCasesListFromLastMonth.addAll(sendNotificationForFirstTime);
        finalCasesListFromLastMonth.addAll(threeDaysPassedSinceFollowUp);          
        //Master List For Valid Stored Cases For Last Month Demanding Notification(EITHER FIRST TIME OR REPETETIVE)
        
        //Populate Set Of Manager Activity Ids In Set
        for(Store_Cases_For_Month__c caseUnderProcessing : finalCasesListFromLastMonth){
            finalManagerActivityLogIds.add(caseUnderProcessing.Manger_Activity_Log__c);
        }
        //Populate Set Of Manager Activity Ids IN Set        
        
        finalManagerListToBeMailed = [Select Id, OwnerId, SupportManager__c,SupportManager__r.Manager.email from Manger_Activity_Log__c Where Id IN : finalManagerActivityLogIds];
        //finalManagerListToBeMailed = [Select Id, OwnerId, SupportManager__c from Manger_Activity_Log__c Where Id = 'aAiW000000001HiKAI'];
        
        
        System.Debug('______sendNotificationForFirstTime_______'+sendNotificationForFirstTime);
        System.Debug('______sendFollowUpNotifications__________'+sendFollowUpNotifications);    
        System.Debug('______finalManagerActivityLogIds_________'+finalManagerActivityLogIds);    
        System.Debug('______finalManagerListToBeMailed_________'+finalManagerListToBeMailed);    
        

        //Send Email Method
        If(!finalManagerListToBeMailed.isEmpty()){
            sendEmailReminder(finalManagerListToBeMailed);
            System.Debug('_____finalManagerListToBeMailed_____'+finalManagerListToBeMailed);
        } 
        //Send Email Method        
    }
    
    public static List<Store_Cases_For_Month__c> isValidForResending(List<Store_Cases_For_Month__c> tempList){
        List<Store_Cases_For_Month__c> repeteReminder = new List<Store_Cases_For_Month__c>();
        for(Store_Cases_For_Month__c caseUnderProcessing : tempList){
            if(Calculate_Duration_In_Hours.duration_between_two_date_times(caseUnderProcessing.Manager_Reminded__c, System.now()) > 1){
                repeteReminder.add(caseUnderProcessing);
                caseUnderProcessing.Manager_Reminded__c = System.now();
                listOfStoredCasesToBeUpdated.add(caseUnderProcessing);
            }
        }
        return repeteReminder;
    }
    
    public static void sendEmailReminder(List<Manger_Activity_Log__c> targetManActivLog){
        System.Debug('I AM IN MAILER CODE');
        EmailTemplate emailTemplate  = [Select id from EmailTemplate where name = 'InComplete'];
        OrgWideEmailAddress owa = [Select id, displayname from OrgWideEmailAddress where displayname='Marketo Customer Support'];
        
        String ccAddress     = label.Case_Quality_Review_CC_List;
       
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        for (Manger_Activity_Log__c manItr : targetManActivLog) {
            String[] ccAddresses = ccAddress.split(';');        
            Messaging.SingleEmailMessage message  = new Messaging.SingleEmailMessage();
            ccAddresses.add(manItr.SupportManager__r.Manager.email);
            Id tempId = manItr.SupportManager__c;
            System.Debug('___Temp USer ID__'+tempId);
            message.setTargetObjectId(tempId);
            message.setOrgWideEmailAddressId(owa.id);
            message.setCcAddresses(ccAddresses);
            message.setTemplateId(emailTemplate.Id);
            message.setWhatId(manItr.Id);
            message.setSaveAsActivity(false);
            allmsg.add(message);
        }
        mailResult = Messaging.sendEmail(allmsg, false);
        System.Debug('I AM IN MAILER CODE'+mailResult);
        List<Messaging.SendEmailError> isEmailFailed = new List<Messaging.SendEmailError>();
        for(Messaging.SendEmailResult singlemEmailResult : mailResult){
            isEmailFailed.addAll(singlemEmailResult.getErrors());
        }
        //If(isEmailFailed.size() == 0 || isEmailFailed == Null)
            //update listOfStoredCasesToBeUpdated;
    }
    */
}