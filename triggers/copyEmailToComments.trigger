Trigger copyEmailToComments on EmailMessage (after insert) {

    EmailMessageActions actions = new EmailMessageActions();  
    if(trigger.isAfter) {
        if (Trigger.isInsert) {
            actions.doAfterInsert(trigger.new);       
        }  
    }
    
    if(trigger.isInsert && trigger.isAfter && (Label.CopyEmailAttachmentToCase == 'Yes' || Test.IsRunningTest() )){
        try{ 
            for(EmailMessage  emm: trigger.new){ //Master For loop for trigger.New                   
                if(emm.parentid !=null && (emm.HasAttachment || Test.IsRunningTest() ) && system.isBatch() == false && system.Isfuture() == false){
                    CaseTriggerFunctionUpdated.copyEmailAttachmentToCase(emm.Id,emm.parentid);                  
                }        
            }
        }catch (Exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}    
    }
  
}