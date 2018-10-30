/**
MARKETO UNIVERSITY--> LEARNING PASS ENABLEMENT
DESCRIPTION: THIS CLASS USED TO SEND LEARNING PASS CODE TO PRIMARY MARKETO USER EMAIL WHEN OPP IS CLOSED
DATE: JULY 24, 2014
**/
global class SendLearningPassCodeToPrimUserAfter24Hr implements Schedulable{
   public String EMAILTEMPLATE;  
   
   public SendLearningPassCodeToPrimUserAfter24Hr (String emailTemplateName){
       EMAILTEMPLATE = emailTemplateName;
   }
   
   public SendLearningPassCodeToPrimUserAfter24Hr (){
       EMAILTEMPLATE = System.Label.University_LearningPassCodes_EmailTemplate_For_NewBusiness; 
   }
   
   global void execute(SchedulableContext SC) {
        Set<String> entitlementsIds = new Set<String>();               
        String jobId = SC.getTriggerId();
        if(jobId.length()>15)
        jobId = jobId.subString(0,jobId.length()-3);
        /*List<SMB_SheduledJobInfo__c> sheduledEnts = new List<SMB_SheduledJobInfo__c>([SELECT ProjectId__c FROM SMB_SheduledJobInfo__c WHERE SheduledJobId__c =: jobId]);
        for(SMB_SheduledJobInfo__c jobOpp : sheduledEnts ){
           entitlementsIds.add(jobOpp.ProjectId__c) ;
        }*/ 
		
        List<Entitlement> universityEnts = sendLearningPassCodes(entitlementsIds);
		
        if(!universityEnts.isEmpty()){
            try{update universityEnts;}catch(Exception e){}
           /* if(!sheduledEnts.isEmpty()){
                try{delete sheduledEnts;}catch(Exception e){}
            }  */          
        }   
    }
    
    public List<Entitlement> sendLearningPassCodes(Set<string> entitlementsIds){
        List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        EmailTemplate mailTemplate  = [SELECT id,HtmlValue FROM EmailTemplate WHERE name =:System.Label.University_LearningPassCodes_EmailTemplate_For_NewBusiness];
		

		
        OrgWideEmailAddress owa     = [SELECT id, DisplayName , Address FROM OrgWideEmailAddress WHERE DisplayName =:'Marketo Education'];
        List<Entitlement> universityEnts   = new List<Entitlement>([SELECT Opportunity__c, Opportunity__r.Primary_Marketo_User_Lookup__c FROM Entitlement WHERE Id IN: entitlementsIds]);
        Map<String, Id> primContactWithOpp = new Map<String, Id>();
        for(Entitlement enty : universityEnts){
            primContactWithOpp.put(enty.Id, enty.Opportunity__r.Primary_Marketo_User_Lookup__c);
        }        
        for(Entitlement enty :universityEnts){
            if(primContactWithOpp.containsKey(enty.Id)){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(primContactWithOpp.get(enty.Id));
                mail.setOrgWideEmailAddressId(owa.id);
                mail.setCcAddresses(system.label.MKTO_UNIV_LEARNING_PASS_CODE_RECIPIENTS.split('#'));
                mail.setTemplateID(mailTemplate.Id); 
                mail.setWhatId(enty.Opportunity__c);
                mail.setSaveAsActivity(false);
                mailList.add(mail);
                enty.Is_University_Codes_Sent__c = true;
                system.debug('mail--->'+mail);
            }
        }        
        List<Messaging.SendEmailResult> mailResult = Messaging.sendEmail(mailList, false); 
        if (!mailResult.isEmpty() && mailResult.get(0).isSuccess()) {
            return universityEnts;
        }       
        return new List<Entitlement>();
     }
     
    /********Following code used in Component --> SendLearningPassCodeToPrimUser ********/
    
    public string oppId {get;set;}
	public String EntId {get;set;}
    
    public List<Learning_Passport__c> getLearningPassCodes(){
        return new List<Learning_Passport__c>([SELECT Code__c, Account__c, Opportunity__c, Contact__r.Name, Opportunity__r.Type, Passport_Serial_No__c FROM Learning_Passport__c WHERE Opportunity__c=: oppId AND IsArchived__c = false ORDER BY Passport_Serial_No__c ASC]);
    }
	
	 public List<Learning_Passport__c> getEntitlementLearningPassCodes(){  
     return new List<Learning_Passport__c>([SELECT Code__c, Account__c, Opportunity__c, Contact__r.Name, Opportunity__r.Type, Passport_Serial_No__c, Entitlement__r.StartDate, Entitlement__r.EndDate FROM Learning_Passport__c WHERE Entitlement__c=: EntId ORDER BY Passport_Serial_No__c ASC]);
    }
    
}