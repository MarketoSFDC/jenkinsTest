global class notifyTSEaboutSLASchdlr implements Schedulable {

    global Case_Update_Milestones__c Mil;
    global string noticeTime;
    global notifyTSEaboutSLASchdlr(Case_Update_Milestones__c Milstone, string noticetype) {      
        Mil = Milstone; 
        noticeTime = noticetype;   
    }
    
    global void execute(SchedulableContext SC) {
        try {
            list<Case_Update_Milestones__c> Milstone = [select id, Completed__c,OwnerId, Owner.email, Owner.Name, Duration__c, case__c, case__r.casenumber, case__r.OwnerId, case__r.Owner.Name, case__r.contact.name, case__r.Support_Level__c, case__r.Account.Name, case__r.Description from Case_Update_Milestones__c where id =: Mil.id ];
            if(Milstone != NULL && Milstone.isEmpty() == False && Milstone[0].Completed__c == False && Milstone[0].case__c!=null) {
                system.debug('milestone case number --->'+Milstone[0].case__r.casenumber); 
                Id orgWId = SupportEmailSettings__c.getInstance('Marketo Customer Support').RecordId__c;                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();                
                mail.setOrgWideEmailAddressId(orgWId);                
                if(noticeTime == '50%') {mail.setTemplateId(SupportEmailSettings__c.getInstance('Case Milestone 50% SLA Remaining').RecordId__c); mail.setTargetObjectId(Milstone[0].OwnerId);
                } else if(noticeTime == '25%'){mail.setTemplateId(SupportEmailSettings__c.getInstance('Case Milestone 25% SLA Remaining').RecordId__c); mail.setTargetObjectId(Milstone[0].OwnerId);
                }  else if(noticeTime == '15'){                    
                    if((''+Milstone[0].case__r.OwnerId).startsWith('00G') == FALSE){
                        mail.setTargetObjectId(Milstone[0].case__r.OwnerId); // This line is added to set the owner of the parent case of milestone to recieve email notication.
                        mail.setTemplateId(SupportEmailSettings__c.getInstance('Case Milestone 15 min Remaining').RecordId__c);
                        list<string> p1Alerts = new list<string>();
                        p1Alerts.addAll(label.p1AlertAlias.split('#'));
                        mail.setccAddresses(p1Alerts);                       
                    }else{
                        list<string> p1Alerts = new list<string>();
                        p1Alerts.addAll(label.p1AlertAlias.split('#'));
                        mail.setToAddresses(p1Alerts);
                        id templateid = SupportEmailSettings__c.getInstance('Case Milestone 15 min Remaining').RecordId__c;
                        list<EmailTemplate> EmailTemplateList = [SELECT Subject, Body, HtmlValue, Markup, TemplateType FROM EmailTemplate where id =:templateid  limit 1];
                        string pageAsString = String.valueOf(EmailTemplateList[0].Markup);
                        pageAsString = pageAsString.replace('{!relatedTo.Owner.Name}', Milstone[0].Owner.Name);
                        pageAsString = pageAsString.replace('{!relatedTo.Case__r.CaseNumber}', Milstone[0].case__r.CaseNumber);
                        pageAsString = pageAsString.replace('{!relatedTo.Case__r.Support_Level__c}', Milstone[0].case__r.Support_Level__c);
                        pageAsString = pageAsString.replace('{!relatedTo.Case__r.Owner.Name}', Milstone[0].case__r.Owner.Name);
                        pageAsString = pageAsString.replace('{!relatedTo.Case__r.Account.Name}', Milstone[0].case__r.Account.Name);
                        pageAsString = pageAsString.replace('{!relatedTo.Case__r.Description}', Milstone[0].case__r.Description);
                        pageAsString = pageAsString.replace('{!relatedTo.case__r.ID}', Milstone[0].case__c);

                        mail.setHtmlBody(pageAsString);
                        mail.setsubject(EmailTemplateList[0].Subject);
                    }
                }               
                mail.setwhatId(Milstone[0].Id);
                mail.setSaveAsActivity(false);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });             
                if(label.P1Abort =='Yes' || test.IsrunningTest() ){
                    list<CronTrigger> job = [SELECT TimesTriggered, NextFireTime FROM CronTrigger WHERE Id = :sc.getTriggerId() ];
                    if(!job.isEmpty()) { System.abortJob(job[0].id); }
                }      
            }
        } catch(Exception e) {
            CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);
        }        
    }
    
    @isTest(seealldata= true)
    public static Void TestScheduleActiveExpiredSubscription(){       
        List<Case_Update_Milestones__c> Milstone = [select id, Completed__c,OwnerId, Owner.email, Owner.Name, Duration__c, case__r.casenumber, case__r.contact.name from Case_Update_Milestones__c where Owner.email != null and case__r.casenumber != null and Completed__c = False and case__r.Owner.Name like '%Queue%' LIMIT 1 ];
        
        Test.StartTest();
        notifyTSEaboutSLASchdlr sh1 = new notifyTSEaboutSLASchdlr(Milstone[0],'15');   
        sh1.execute(Null);
        Test.stopTest();    
   }
}