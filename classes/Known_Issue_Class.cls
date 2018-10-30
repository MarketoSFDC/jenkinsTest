/*This class is called from the KnownIssueAfterInsert apex trigger 
to send an email notification when a new known issue is created*/
public class Known_Issue_Class {
    
    
    
    public void executeAfterInsert(Known_Issue__c ki){
      
        
       String visualforceURL = '';
       String emailTo = '';
       Known_Issue__c ki2 = [SELECT Id,Title__c,Description__c 
                            FROM Known_Issue__c WHERE Id =: ki.Id];
        
        KISettings__c myCS2 = KISettings__c.getInstance('Default');
        if(myCS2 != null){
            visualforceURL = myCS2.Visualforce_Domain__c;
            emailTo = myCS2.Default_Notification__c;
        }

        
        List<String> emailList = new List<String>();
        
        
        emailList.add(emailTo);
        
        
        if(!emailList.isEmpty()){
            
            // Now create a new single email message object
            // that will send out a single email to the addresses in the To, CC & BCC list.
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            
            
            // Assign the addresses for the To and CC lists to the mail object.
            mail.setBccAddresses (emailList);
            
             //Specify the address used when the recipients reply to the email. 
             mail.setReplyTo('cs-support-tier3@marketo.com');
            
            //Specify the name used as the display name.
            mail.setSenderDisplayName('Known Issue Notification');
            
            /*OrgWideEmailAddress[] owea = [select Id from OrgWideEmailAddress where Address = 'pgonzalez@marketo.com'];  
            if ( owea.size() > 0 ) { 
            mail.setOrgWideEmailAddressId(owea.get(0).Id); 
            } */
            
            // Specify the subject line for your email address.
            mail.setSubject('New Known Issue: ' + ki2.Title__c);
            
            
            mail.setHtmlBody('<p>A new known issue has been created</p>'+
                             '<p><b>Issue: </b> '+ ki2.Title__c+ '</p>'+
                             '<p><b>Description: </b> '+ ki2.Description__c+ '</p>'+
                             '<p><b>Link to more details and attachments: </b> '+visualforceURL+'/apex/mktoKIDetailPage?id='+ki2.id+'</p>');
            
            
            
            
            // Send the email you have created.
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        }
        
        
        
    }
    
}