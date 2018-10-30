public class KI_Update_Class {
    
    public Known_Issue__c ki;
    
    public void executeAfterInsert(KI_Update__c kiUpdate){
        ki = [SELECT Id,Title__c,Description__c  FROM Known_Issue__c WHERE Id =: kiUpdate.Known_Issue__c];
        
        KI_Update__c kiUpdate2 = [SELECT Id, Description__c FROM KI_Update__c WHERE Id =: kiUpdate.id];
        
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();                                   
        for(KI_Notification__c st : [SELECT Subscribed_User_Name__r.Id FROM KI_Notification__c WHERE Known_Issue__r.id =: ki.Id AND Subscribed_User_Name__r.Id != null]){
             Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
             mail.setTargetObjectId(st.Subscribed_User_Name__r.Id); //Sending emails to subscribed users.
             mail.setReplyTo('cs-support-tier3@marketo.com');
             mail.setSubject('LATEST UPDATE: ' +ki.Title__c); //added title field for email notification subject - date [31 july 2017]
             mail.setHtmlBody('<p><b>LATEST UPDATE: </b> '+ kiUpdate2.Description__c+ '</p>'+
            '<p><b>Issue: </b> '+ ki.title__c+ '</p>'+
            '<p><b>Description:</b> '+ ki.Description__c+ '</p>'+
            '<p><b>Link to more details and attachments: </b> <a  href= "'+system.URL.getSalesforceBaseUrl().toExternalForm()+'/apex/mktoKIDetailPage?id='+ki.id+'"> Click Here </a></p>');
             mail.setSenderDisplayName('Critical Issue Notification');
             mail.saveAsActivity = false; 
             emails.add(mail);     
          }
         if(emails.isEmpty() == FALSE){
             Messaging.sendEmail(emails);
         }
 
    }
    
}