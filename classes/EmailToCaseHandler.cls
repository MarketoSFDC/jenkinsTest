/**
GOAL: EMAIL SERVICE HANDLER THAT CREATE CASE FROM EMAIL.
DESIGNED BY: GRAZITTI
**/
Global class EmailToCaseHandler implements Messaging.inboundEmailHandler {
   
    Global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope env) {
        
        System.debug(email);
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        createCase(email, env.fromAddress);
        return result;
    }
    
    public static Case[] createCase(Messaging.InboundEmail email, String fromEmail) {
        try {
            id usrId;
            try {
                usrId = [select id, name, email from user where email=:fromEmail and (email like '%@grazitti.com' OR email like '%@marketo.com')  limit 1].id;
                system.debug('sender id--------->'+usrId);               
            } catch (exception ex) {
                sendEmailExp(fromEmail, 'User Missing error: You are not authorized to create the case');
                return null;
            }

            // Validate Tags failed
            String caseSubject = email.subject;
            String TextBody = email.plainTextBody.trim();
            String ContactEmailAddress;
            String Description;
            try {
            //Parse content
                ContactEmailAddress = TextBody.substring(0, TextBody.indexOf('#'));
                Description = TextBody.substring(TextBody.indexOf('#'));
            } catch (exception ex) {
                sendEmailExp(fromEmail, 'Syntax Error: PLease check the email syntax and try again.');
                return null;
            }
            contact Conid;
            try {
               Conid = [select id,name,accountId from contact where email = :ContactEmailAddress limit 1];  
               system.debug('customer id--------->'+Conid);        
            } catch (exception ex) {
                sendEmailExp(fromEmail, 'Contact Not Found: There is no contact matching "' +ContactEmailAddress+ '" email address. Please check the email Adress and try again');
                return null;
            }            
            case emailCase = new case(contactid=Conid.id, accountid = Conid.accountId, RecordTypeid =label.supportcaserecordtypeid, status ='New', subject=caseSubject , Description=Description, ownerid=usrId, origin='Outlook', Problem_type__c='Outlook',priority='P3'); 
            try {
                insert emailCase;
            } catch (Exception ex) {
                sendEmailExp(fromEmail, ex.getMessage());                
            }
            
            sendEmail(fromEmail, Conid.name, new List<case>{emailCase});
            return null;

        } catch (Exception e) {
            system.debug(e.getCause()+'=='+e.getTypeName()+'==>'+e.getCause());
            if(e.getTypeName() != 'System.EmailException') {
                sendEmailExp(fromEmail, e.getMessage());
            }
            return null;
        }
    }

    public static void sendEmail(String s, string ContName, List < Case > CasetoInsert) {
        // Send an email back to the from email address of who created the case
        String[] toAddresses = new String[] {s};

        // new instance of a single email message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Marketo Support');
        mail.setSubject('New Case created - ' + CasetoInsert[0].Subject);
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody('Your case: "' + CasetoInsert[0].subject + '" has been created for Contact "'+ContName +'" \n. \n\n To watch the case in salesforce.com click on this link \n'+System.Label.DomainUrl+'/' + CasetoInsert[0].Id);
        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }

    public static void sendEmailExp(String s, String Exp) {
    
        // Send an email back to the from email address of who created the Case
        String[] toAddresses = new String[] {s};
        // new instance of a single email message
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(toAddresses);
        mail.setSenderDisplayName('Marketo Support');
        mail.setSubject('Exception - Cant create Case');
        mail.setBccSender(false);
        mail.setUseSignature(false);
        mail.setPlainTextBody('Following exception occured while system try to create your Case. PLease check.\n \n' + exp);
        System.Debug('ERROR_MESSAGE_' + Exp);
        // Send the email

        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
    }
    
}