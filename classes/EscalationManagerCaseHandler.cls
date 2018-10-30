/**
GOAL: EMAIL SERVICE HANDLER THAT CREATE CASE FROM EMAIL.
DESIGNED BY: GRAZITTI(RIZVAN)
**/
Global class EscalationManagerCaseHandler implements Messaging.inboundEmailHandler {
   
    Global Messaging.InboundEmailResult handleInboundEmail(Messaging.InboundEmail email, Messaging.InboundEnvelope env) {
        
        System.debug(email);
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
        
        createCase(email, env.fromAddress);
        return result;
    }
    
    public static Case[] createCase(Messaging.InboundEmail email, String fromEmail) {
        try {
            id usrId;
            string TSE;
            try {
                user usrInfo = [select id, name, email from user where email = :fromEmail and (email like '%@grazitti.com' OR email like '%@marketo.com')  limit 1];
                usrId = usrInfo.id;
                TSE = usrInfo.name;
                system.debug('sender ID--------->usrId'+usrId);               
            } catch (exception ex) {
                sendEmailExp(fromEmail, 'User Missing error: You are not authorized to create the case');
                return null;
            }
            
            //Check if contact exists with matching email address. 
            contact Conid;
            try {
               Conid = [select id, name, accountId from contact where email =:fromEmail limit 1];  
               system.debug('customer id--------->'+Conid);        
            } catch (exception ex) {
                sendEmailExp(fromEmail,'Contact Not Found: There is no contact matching your email address.');
                return null;
            }

            // Email Tags
            String caseSubject = email.subject;
            String description = email.plainTextBody;
            string decri = system.label.caseDescriptionField;
            string Subj = system.label.caseSubjectField;
            //Create case if user and contact available
            case emailCase = new case();
            emailCase.Origin='Email';
            emailCase.Situation_Contact__c = Conid.id;
            emailCase.Situation_Account__c = Conid.accountId;
            emailCase.recordTypeid ='01250000000UK1E';
            emailCase.status ='New';
            emailCase.subject = caseSubject;
            emailCase.put(Subj, caseSubject);
            emailCase.Description = Description;
            emailCase.ownerid = '00G50000001R8aQ';
            emailCase.put(decri, Description);
            emailCase.problem_type__c = 'Escalated Account - Support';
             
            try {
                insert emailCase;
            } catch (Exception ex) {
                sendEmailExp(fromEmail, ex.getMessage());                
            }            
            sendEmail(fromEmail, TSE,  new List<case>{emailCase});
            return null;
        }catch (Exception e) {
            system.debug(e.getCause()+'=='+e.getTypeName()+'==>'+e.getCause());
            if(e.getTypeName() != 'System.EmailException') {
                sendEmailExp(fromEmail, e.getMessage());
            }
            return null;
        } 
    }

    public static void sendEmail(String s, string sender, List < Case > CasetoInsert) {        
        // Send an email back to the from email address of who created the case
        OrgWideEmailAddress owa = [select Id from OrgWideEmailAddress where Address = 'supportescalations@marketo.com' limit 1];
        EmailTemplate Emailtemplate = [SELECT id FROM EmailTemplate where id = '00X50000001UDzj'];
        String[] NotifyEmail = system.label.Escalation_Manager_email.split(',');
        system.debug('NotifyEmail---->'+NotifyEmail);
        list<string> toAddresses = new list<string>();
        for(user temp : [select id,email from user where email in : NotifyEmail]){
            system.debug('toAddresses--->'+temp.email);
            toAddresses.add(temp.email);    
        }
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(CasetoInsert[0].Situation_Contact__c);
        mail.setTemplateID(Emailtemplate.Id);
        mail.setCCAddresses(toAddresses);
        mail.setWhatId(CasetoInsert[0].Id);
        mail.setSaveAsActivity(false);
        mail.setOrgWideEmailAddressId(owa.id);
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
        mail.setPlainTextBody('Following exception occured while system try to create your case. PLease check.\n \n' + exp);
        System.Debug('ERROR_MESSAGE_' + Exp);
        // Send the email
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});        
    }
    
}