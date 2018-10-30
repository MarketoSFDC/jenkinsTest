global class SfdcJiveSyncingStatusNotification implements Schedulable {
   global void execute(SchedulableContext SC) {
      list<Jive_User__c> recordList=[Select id from Jive_User__c where LastModifiedDate=YESTERDAY];
        Messaging.SingleEmailMessage emailMsg = new Messaging.SingleEmailMessage(); 
        emailMsg.setTargetObjectId('00550000001m8mNAAQ');  
        emailMSg.saveAsActivity = false;
        emailMsg.setSenderDisplayName('sender name');
        if(recordList.size()==0){ 
            emailMsg.setSubject('Please check webhook functionality'); 
            emailmsg.setPlainTextBody('The webhook has not updated any record yesterday. Please check manually if webhook is working or not.'); 
        }else{
            emailMsg.setSubject('Webhook functionality worked succesfully');  
            emailmsg.setPlainTextBody('Congrats!!!Your webhook has updated '+recordList.size()+' records successfully');
        }
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] { emailMsg });
    }
}