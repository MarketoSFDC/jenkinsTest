public class EmailNotificationToTSE{
    public static List<Case> listOfCasesInP1SinceCreation = new List<Case>();
    public static List<Case> listOfCasesInP1AfterCreation = new List<Case>();
    
    //Remove the Owner ID Check Prior to Deployment
    //add the code for cases in queue
    public static void fetchValidCasedForNotification(){
        try{
            List<Case> rawCaseList            = [Select id, P1_Service_Notification_Sent_Initiated__c, CreatedDate, OwnerId, CaseNumber, (Select Id, CaseId, CreatedDate, Field, OldValue, NewValue From Histories Where Field = 'Priority' ORDER BY CreatedDate DESC LIMIT 1) from Case where isClosed = false and Priority = 'P1' AND P1_Service_Restored_Time_Visible__c = Null];
            System.Debug('___rawCaseList___'+rawCaseList);
            If(!rawCaseList.IsEmpty()){
                splitEditedAndNotEditedCases(rawCaseList);
            }
        }catch(Exception ex){
            System.Debug('Exception Caught::'+ex);
        }
    }
    //Remove the Owner ID Check Prior to Deployment
    
    public static void splitEditedAndNotEditedCases(List<Case> rawCaseList){
        for(Case tempCase : rawCaseList){
            //Case Priority Is Not Changed Till Now So This Case Was Logged Under P1 Priority
            if(tempCase.P1_Service_Notification_Sent_Initiated__c == null){
                if(tempCase.Histories.size() == 0 ){
                    System.Debug('______Duration After Creating P1_______'+Calculate_Duration_In_Hours.duration_between_two_date_times(tempCase.CreatedDate, System.now()));
                    if(Calculate_Duration_In_Hours.duration_between_two_date_times(tempCase.CreatedDate, System.now()) >= 24){
                        listOfCasesInP1SinceCreation.add(tempCase);
                    }//Case Priority Is Changed From Something Else To P1
                } else {
                    System.Debug('______Duration After Updating P1_______'+Calculate_Duration_In_Hours.duration_between_two_date_times(tempCase.CreatedDate, System.now()));
                    if(Calculate_Duration_In_Hours.duration_between_two_date_times(tempCase.Histories[0].CreatedDate, System.now()) >= 24){
                        listOfCasesInP1AfterCreation.add(tempCase);
                    }
                } 
            }else if(tempCase.P1_Service_Notification_Sent_Initiated__c  != null){
                if(tempCase.Histories.size() == 0 ){
                    System.Debug('______Duration After Creating P1_______'+Calculate_Duration_In_Hours.duration_between_two_date_times(tempCase.P1_Service_Notification_Sent_Initiated__c  , System.now()));
                    if(Calculate_Duration_In_Hours.duration_between_two_date_times(tempCase.P1_Service_Notification_Sent_Initiated__c, System.now()) >= 24){
                        listOfCasesInP1SinceCreation.add(tempCase);
                    }//Case Priority Is Changed From Something Else To P1
                } else {
                    System.Debug('______Duration After Updating P1_______'+Calculate_Duration_In_Hours.duration_between_two_date_times(tempCase.P1_Service_Notification_Sent_Initiated__c  , System.now()));
                    if(Calculate_Duration_In_Hours.duration_between_two_date_times(tempCase.P1_Service_Notification_Sent_Initiated__c, System.now()) >= 24){
                        listOfCasesInP1AfterCreation.add(tempCase);
                    }
                }      
            }
        }

        System.Debug('____listOfCasesInP1SinceCreation____'+listOfCasesInP1SinceCreation);
        System.Debug('____listOfCasesInP1AfterCreation____'+listOfCasesInP1AfterCreation);
        System.Debug('____listOfCasesInP1SinceCreation Size____'+listOfCasesInP1SinceCreation.size());
        System.Debug('____listOfCasesInP1AfterCreation Size____'+listOfCasesInP1AfterCreation.size());

        List<Case> casesForWhichMailIsToBeSent = new List<Case>();
        casesForWhichMailIsToBeSent.addAll(listOfCasesInP1SinceCreation);
        casesForWhichMailIsToBeSent.addAll(listOfCasesInP1AfterCreation);
        If(!casesForWhichMailIsToBeSent.IsEmpty() && SYSTEM.LABEL.Is_P1_Service_Mailer_Enabled == 'Yes'){
            sendP1ServiceBreachedEmail(casesForWhichMailIsToBeSent);
        }
    }

    public static void sendP1ServiceBreachedEmail(List<Case>  targetCases) {
        System.Debug('I AM IN MAILER CODE');
        EmailTemplate emailTemplate  = [Select id from EmailTemplate where name = 'P1ServiceRestoredTemplate'];
        OrgWideEmailAddress owa = [Select id, displayname from OrgWideEmailAddress where displayname='Marketo Customer Support'];
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();
        List<Case> casesToBeUpdated = new List<Case>();
        for (Case caseItr : targetCases) {
            Messaging.SingleEmailMessage message  = new Messaging.SingleEmailMessage();
            Id tempId = caseItr.OwnerId;
            System.Debug('___Temp USer ID__'+tempId);
            message.setTargetObjectId(tempId);
            message.setOrgWideEmailAddressId(owa.id);
            message.setTemplateId(emailTemplate.Id);
            message.setCcAddresses(new String[]{System.Label.CC_Email_Addresses_For_P1_Service_Not_Restored});
            message.setWhatId(caseItr.Id);
            message.setSaveAsActivity(false);
            allmsg.add(message);
            caseItr.P1_Service_Notification_Sent_Initiated__c = System.now();
            casesToBeUpdated.add(caseItr);
        }
        update casesToBeUpdated;
        List<Messaging.SendEmailResult> mailResult = Messaging.sendEmail(allmsg, false);
        System.Debug('mailResult'+mailResult);

    }  
}