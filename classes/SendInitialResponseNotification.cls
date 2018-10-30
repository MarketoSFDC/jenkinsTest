public class SendInitialResponseNotification{

    public static void initResponseNotificationToManager(){
         List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        
        for(Case_Update_Milestones__c cm : [SELECT Id,case__c, Start_Date__c, case__r.BusinessHoursId, case__r.Priority, case__r.No_of_CaseComments__c, case__r.OwnerId, case__r.Owner.Name, case__r.CaseNumber FROM Case_Update_Milestones__c WHERE Milestone_Type__c = 'First Response' AND Completed__c = false AND  case__r.recordTypeId = '01250000000UK1E']){
            DateTime current = System.now();
            DateTime strtDate = cm.Start_Date__c;
            System.debug('current@@' + current);
            System.debug('strtDate@@' + strtDate);
            Long businessMillis = BusinessHours.diff(cm.case__r.BusinessHoursId, strtDate, current);
            System.debug('businessMillis@@' + businessMillis);
            
            Integer bMins = (Integer)((businessMillis/1000)/60);
            System.debug('bMins@@' + bMins);
            System.debug('Priority@@' + cm.case__r.Priority);
            System.debug('Comment@@' + cm.case__r.No_of_CaseComments__c);
            System.debug('Owner@@' + cm.case__r.OwnerId);
            
            if(((cm.case__r.Priority  == 'P1' && cm.case__r.No_of_CaseComments__c == Null && bMins > 240 && bMins < 245) || (cm.case__r.Priority  == 'P2' && cm.case__r.No_of_CaseComments__c == Null && bMins > 720 && bMins < 725) || (cm.case__r.Priority  == 'P3' && cm.case__r.No_of_CaseComments__c == Null && bMins > 1440 && bMins < 1445))|| Test.isrunningTest()){
                System.debug('Priority@@@' + cm.case__r.Priority);
                System.debug('Comment@@@' + cm.case__r.No_of_CaseComments__c);
                System.debug('Owner@@@' + cm.case__r.OwnerId);
                
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                mail.setTargetObjectId(cm.case__r.OwnerId);
                mail.setWhatId(cm.id);
                mail.setOrgWideEmailAddressId('0D238000000TQIa');
                mail.setSubject('Need Response On Case - '+cm.case__r.CaseNumber);
                String body = 'Hi ' + cm.case__r.Owner.Name + ', <br/>';
                body += '<p>The response has not been provided. Please check the case and provide response.</p>';
                body +='<p><b>Case Details : </b><br/>';
                body +='<br/><b>Case Number: </b>'+cm.case__r.CaseNumber;
                body +='<br/><b>Case Priority: </b>'+cm.case__r.Priority;
                body += '<br/><b>Case Link: </b>'+ system.URL.getSalesforceBaseUrl().toExternalForm()+'/'+cm.case__c;
                body +='<p>Regards,';
                body +='<br/>Marketo Support';
                mail.setHtmlBody(body);
                mail.setUseSignature(false); 
                mail.setBccSender(false); 
                mail.setSaveAsActivity(false);  
                emailList.add(mail); 
            }
        }
        Messaging.sendEmail(emailList); 
    }
}