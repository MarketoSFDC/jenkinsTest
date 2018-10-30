global class SMB_ScheduledSurveyMail implements Schedulable{
   Set<String> lpIds = new Set<String>();
   //List<SMB_SheduledJobInfo__c> sheduleProjects = new List<SMB_SheduledJobInfo__c>();
   private static final String EMAILTEMPLATE = 'SMBLaunchPackSurveyTemplate'; 
   
  
   global void execute(SchedulableContext SC) {
       /*
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        List<Contact> ContactList = new List<Contact>();
        Map<String,Contact> projectContactMap = new Map<String,Contact>();
        OrgWideEmailAddress owa = [select id, DisplayName , Address from OrgWideEmailAddress where DisplayName =:'Rod Cherkas'];
        EmailTemplate mailTemplate  = [Select id,HtmlValue from EmailTemplate where name =:EMAILTEMPLATE];
        string jobId = SC.getTriggerId();
        if(jobId.length()>15)
        jobId = jobId.subString(0,jobId.length()-3);
        //sheduleProjects = [select ProjectId__c from SMB_SheduledJobInfo__c where SheduledJobId__c =: jobId];
        
        for(SMB_SheduledJobInfo__c jobProj : sheduleProjects ){
           lpIds.add(jobProj.ProjectId__c) ;
        }
        Set<String> mails = new set<string>();
        Set<String> userNames = new Set<String>();
        List<clzV5__Clarizen_Project__c> LP_ProjectsList = [Select name,clzV5__CLZ_Customer__c, CLZ_C_PrimaryCustomerContactEmail__c,CLZ_C_PrimaryCustomerContact__c  from clzV5__Clarizen_Project__c where Id in:lpIds ];
        for(clzV5__Clarizen_Project__c c : LP_ProjectsList){
            mails.add(c.CLZ_C_PrimaryCustomerContactEmail__c);
            userNames .add(c.CLZ_C_PrimaryCustomerContact__c);
        }
        List<Contact> con = [select Name,email,HasOptedOutOfEmail from Contact where email in : mails];
        Map<String,Contact> Contactm = new Map<String,Contact>();
        for(Contact c : con){
           if(c.Name != null && userNames.contains(c.Name)&& !c.HasOptedOutOfEmail){
                Contactm.put(c.email, c);
            }
        }
        for(clzV5__Clarizen_Project__c lp :LP_ProjectsList){
           if(Contactm.containsKey(lp.CLZ_C_PrimaryCustomerContactEmail__c)){
                projectContactMap.put(lp.Id,Contactm.get(lp.CLZ_C_PrimaryCustomerContactEmail__c));
            }else{
                Contact tempContact;
                string firstName1='';
                String customerContact=lp.CLZ_C_PrimaryCustomerContact__c;
                if(customerContact != null){
                    List<String> parts = customerContact.split(' ');
                    if(parts.size()>0){
                       firstName1=parts[0];
                    }     
                }
                //tempContact = new Contact(email = 'ayub.a@grazitti.com',firstName= firstName1,lastName = 'to be deleted');
                tempContact = new Contact(email = lp.CLZ_C_PrimaryCustomerContactEmail__c , firstName = firstName1, lastName = 'to be deleted');
                projectContactMap.put(lp.Id,tempContact);
                ContactList.add(tempContact);
           } 
        }
        if(!ContactList.isEmpty()){
            try{insert ContactList;}catch(Exception e){}
        }
        for(clzV5__Clarizen_Project__c lp :LP_ProjectsList){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            if(projectContactMap.containsKey(lp.Id)){
               mail.setTargetObjectId(projectContactMap.get(lp.Id).Id);
            }
            mail.setOrgWideEmailAddressId(owa.id);
            mail.setTemplateID(mailTemplate.Id); 
            mail.setWhatId(lp.Id);
            mail.setSaveAsActivity(false);
            mailList.add(mail);
            lp.IsSurveyEmailSent__c = true;
         }
        List<Messaging.SendEmailResult> mailResult = Messaging.sendEmail(mailList, false);
        if(!sheduleProjects.isEmpty() ){
            try{delete sheduleProjects;}catch(Exception e){}
        }
        if(!ContactList.isEmpty()){
            try{delete ContactList;}catch(Exception e){}
        }
        try{update LP_ProjectsList;}catch(Exception e){}
            */
    }
    
    
}