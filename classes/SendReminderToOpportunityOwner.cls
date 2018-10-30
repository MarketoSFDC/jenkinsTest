/* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
********************************************************************************************************************* */
public class SendReminderToOpportunityOwner implements Schedulable{
    Static final String ENT = '%ENT%';
    Static final String JPN = '%JPN%';    
    Static final String STATUSSENT = Label.SalesSurveySentStatus;
    Static final String STATUSSENTANDNOTCOMPLETED = Label.SalesSurveyNotCompletedStatus; 
    
    //List<clzV5__Clarizen_Project__c> targetedProjects ;
    static final String EMAILTEMPLATE = 'Send_Reminder_Mail_to_OppOwner_Template'; 
    OrgWideEmailAddress owa = [select id, DisplayName , Address from OrgWideEmailAddress where DisplayName =:'Success Team'];
    EmailTemplate mailTemplate  = [Select id, DeveloperName from EmailTemplate where DeveloperName =:EMAILTEMPLATE];
    
    public SendReminderToOpportunityOwner (String projId){
		/* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
		
         targetedProjects = new List<clzV5__Clarizen_Project__c>();
         clzV5__Clarizen_Project__c proj = [SELECT Name, clzV5__Opportunity__r.OwnerId, clzV5__Opportunity__r.closeDate, clzV5__Opportunity__r.Owner.firstName, Sales_Survey_Status__c, clzV5__CLZ_Customer__r.Name, clzV5__Opportunity__r.Owner.Email FROM clzV5__Clarizen_Project__c WHERE id =: projId];
         if(proj.Id != null){
             targetedProjects.add(proj);
         }
		********************************************************************************************************************* */
    }
    
    public SendReminderToOpportunityOwner(){
		/* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
		
         targetedProjects = new List<clzV5__Clarizen_Project__c>();
         for(clzV5__Clarizen_Project__c proj : returnProjects()){
             if(proj.clzV5__Opportunity__r != null && proj.clzV5__Opportunity__r.closeDate != null){
                 if(proj.clzV5__Opportunity__r.closeDate.daysBetween(Date.Today()) == 3){
                     if(proj.clzV5__CLZ_ProjectType__c=='SPRNT'){
                         if(proj.Name.containsIgnoreCase('master')) targetedProjects.add(proj);
                     }else{ targetedProjects.add(proj); }
                 }
             }              
         }
		********************************************************************************************************************* */
          
    }
    
    public SendReminderToOpportunityOwner(Boolean isWeekly){
        /* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
		
		if(isWeekly){
            targetedProjects = new List<clzV5__Clarizen_Project__c>();
            for(clzV5__Clarizen_Project__c proj : returnProjects()){
                 if(proj.clzV5__Opportunity__r != null && proj.clzV5__Opportunity__r.closeDate != null){
                     if( proj.clzV5__Opportunity__r.closeDate.daysBetween(Date.Today()) > 3 &&  proj.clzV5__Opportunity__r.closeDate.daysBetween(Date.Today()) < 15){
                         if(proj.clzV5__CLZ_ProjectType__c=='SPRNT'){
                             if(proj.Name.containsIgnoreCase('master')) targetedProjects.add(proj);
                         }else{ targetedProjects.add(proj); }
                     }
                 }              
             }
         }
		********************************************************************************************************************* */
    }
    
	/* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose 
		
   private List<clzV5__Clarizen_Project__c> returnProjects(){
	         - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
		
        return new List<clzV5__Clarizen_Project__c>(
                                                  [
                                                      SELECT Name, clzV5__Opportunity__r.closeDate, clzV5__Opportunity__r.Owner.firstName,clzV5__Opportunity__r.Owner.Email,clzV5__CLZ_Customer__r.Name,Sales_Survey_Status__c, CLZ_C_BusinessUnit__c,CLZ_C_ProjectFamily__c,clzV5__CLZ_ProjectType__c, CreatedDate FROM clzV5__Clarizen_Project__c 
                                                      WHERE (CLZ_C_ProjectFamily__c IN : ProjectFamilyForSalesSurvey__c.getall().keySet() 
                                                      OR clzV5__CLZ_ProjectType__c IN : ProjectTypeForSalesSurvey__c.getall().keySet() OR clzV5__CLZ_ProjectType__c=:'SPRNT') AND (NOT CLZ_C_BusinessUnit__c LIKE : ENT) AND (NOT CLZ_C_BusinessUnit__c LIKE : JPN)
                                                      AND (Sales_Survey_Status__c = : STATUSSENT OR Sales_Survey_Status__c =:STATUSSENTANDNOTCOMPLETED) 
                                                  ]
                                      );
		
    }
	
    ********************************************************************************************************************* */
    
    /**system.schedule('SendReminderToOpportunityOwner'+Date.Today(), '0 0 5 * * ?', new SendReminderToOpportunityOwner());
       system.schedule('SendReminderToOpportunityOwner'+Date.Today(), '0 0 5 ? * MON', new SendReminderToOpportunityOwner(true));
    **/
    public void execute(SchedulableContext sc) {
        /* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
		
		List<Messaging.SingleEmailMessage> mailList = new List<Messaging.SingleEmailMessage>();
        for(clzV5__Clarizen_Project__c proj : targetedProjects){
            if(proj.clzV5__Opportunity__c != null){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setTargetObjectId(proj.clzV5__Opportunity__r.OwnerId);
                mail.setOrgWideEmailAddressId(owa.id);
                mail.setTemplateID(mailTemplate.Id); 
                mail.setWhatId(Proj.Id);
                mail.setSaveAsActivity(false);
                mailList.add(mail);
                if(proj.Sales_Survey_Status__c == null)
                proj.Sales_Survey_Status__c = STATUSSENT;
                else proj.Sales_Survey_Status__c = STATUSSENTANDNOTCOMPLETED;
                proj.Sales_Opportunity_Owner_Email__c = proj.clzV5__Opportunity__r.Owner.Email;
                proj.Sales_Survey_Sent_Date__c = System.Now();
            }
        }   
        
        try{
            List<Messaging.SendEmailResult> mailResult = Messaging.sendEmail(mailList, false);    
                if (!mailResult.isEmpty() && mailResult.get(0).isSuccess()) 
                    update targetedProjects;
        }catch(exception e){} 
		********************************************************************************************************************* */
    }

}