trigger CSM_Ticket_Trigger_Main on CSM_Ticket__c (before insert, before update, before delete, after insert, after update, after delete, after undelete) {
  if(trigger.isBefore){
            if(trigger.isInsert || trigger.isUpdate){
               for(CSM_Ticket__C ticket :Trigger.new)
                {
                if(ticket.Bizible_Account_Id__c != NULL)
                {
                ticket.Account__c = ticket.Bizible_Account_Id__c;
                }
                }
    }
    }
    }