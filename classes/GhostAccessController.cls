public class GhostAccessController {

    public static id         caseId;
    public static string     caseStatus;
    public static string     email;
    public static string     isAdmin;
    public static boolean    thanks{get;set;}
    public static string     jap{get;set;}
    
    public GhostAccessController(){        
        thanks = true;
        caseId = null;
        caseStatus = '';
        email = '';
        if(ApexPages.currentPage().getParameters().get('id') != null && ApexPages.currentPage().getParameters().get('id') != '') 
            caseId = ApexPages.currentPage().getParameters().get('id'); 
        if(ApexPages.currentPage().getParameters().get('status') != null && ApexPages.currentPage().getParameters().get('status') != '') 
            caseStatus = ApexPages.currentPage().getParameters().get('status'); 
        if(ApexPages.currentPage().getParameters().get('email') != null && ApexPages.currentPage().getParameters().get('email') != '') 
            email = ApexPages.currentPage().getParameters().get('email');
        if(ApexPages.currentPage().getParameters().get('isAdmin') != null && ApexPages.currentPage().getParameters().get('isAdmin') != '') 
            isAdmin = ApexPages.currentPage().getParameters().get('isAdmin');
            
        
    }

    public pagereference UpdateCaseGhostAccess(){
        system.debug('caseStatus==>>>'+caseStatus);
        if(caseId != null && String.isNotBlank(caseStatus) && String.isNotBlank(email)){
            if(isAdmin == 'true') {
                List<Case> csList = new List<Case>();
                for(case cse: [select id,Case_Ghost_Access__c,Ghost_Access_Status__c, contact_Preferred_Language__c from case where id =:caseId]) {
                    jap = cse.contact_Preferred_Language__c ;
                    cse.Case_Ghost_Access__c = caseStatus;
                    cse.Ghost_Access_Status__c = caseStatus;
                    csList.add(cse);
                }
                system.debug('csList==>>>'+csList);
                if(csList.isEmpty() == False) {
                    try{
                        //Database.update(csList,false);
                        update csList;
                    } catch (Exception e) {
                        CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);
                    } 
                }                    
                
            }else{
                /********* send email to admin*****************/
                thanks = false;
                List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();          
                case cas =  [select contactid, contact.email, entitlementId from case where id = :caseId];
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                Id EmailtemplateId  = SupportEmailSettings__c.getInstance('GhostAccessRequestAdmin').RecordId__c; 
                for(Authorized_Contact__c acc : [select id,contact__c, contact__r.Preferred_Language__c from Authorized_Contact__c where Entitlement__c = :cas.entitlementId and Customer_Admin__c = true limit 1]){
                    jap = acc.contact__r.Preferred_Language__c;
                    if(cas.contactId != acc.Contact__c){                       
                        if(acc.contact__c != null && acc.contact__r.Preferred_Language__c =='Japanese') EmailtemplateId = SupportEmailSettings__c.getInstance('GhostAccessRequestAdminJP').RecordId__c;
                        mail.setTargetObjectId(acc.contact__c );
                        mail.saveAsActivity = false; 
                        mail.setTemplateId(EmailtemplateId);
                        mail.setOrgWideEmailAddressId('0D250000000Kz9O');
                        mail.SetWhatId(caseId);
                        emails.add(mail); 
                    }
                } 
                if(emails.IsEmpty() ==false) Messaging.sendEmail(emails, false);
            }
        }
        return null;        
    }
    
}