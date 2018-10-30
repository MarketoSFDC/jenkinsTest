global Class SupportUtil{
    public static List<Messaging.SendEmailResult> mailResult = new List<Messaging.SendEmailResult>();
    
    global static void sendEmailNotificatioToManager(Id tseId,Id objId){
        List<User> usrList = new List<User>();
        usrList = [Select managerId from user where Id =: tseId];
        /*String ccAddress = label.Case_Quality_Review_CC_List;
        String[] ccAddresses = ccAddress.split(';'); */       
        List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();        
        for(User tmpKey : usrList){
            Messaging.SingleEmailMessage message  = new Messaging.SingleEmailMessage();
            message.setTargetObjectId(tmpKey.managerId);
            message.setOrgWideEmailAddressId('0D250000000Kz9O');
            //message.setCcAddresses(ccAddresses);
            message.setTemplateId(Label.OOOTemplateId);
            message.SetWhatId(objId);
            message.setSaveAsActivity(false);
            allmsg.add(message);            
        }        
        mailResult = Messaging.sendEmail(allmsg, false);
        List<Messaging.SendEmailError> isEmailFailed = new List<Messaging.SendEmailError>();
        for(Messaging.SendEmailResult singlemEmailResult : mailResult){
            isEmailFailed.addAll(singlemEmailResult.getErrors());
        }
    }
}