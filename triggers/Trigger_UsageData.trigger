trigger Trigger_UsageData on JBCXM__UsageData__c(before insert, before update, after insert, after update,after delete) {
     
    if(Trigger.isBefore){
        if(trigger.isInsert){
            //UsageDataTriggerHelper.handleBeforeInsert(trigger.new);
        }else
        if(Trigger.isUpdate){
           // UsageDataTriggerHelper.handleBeforeUpdate(trigger.new);
        }
    }else           
    if(trigger.isAfter){      
        if(trigger.isInsert){
            UsageDataTriggerHelper.handleAfterInsert(trigger.newMap);
        }else if(trigger.isUpdate){
            UsageDataTriggerHelper.handleAfterUpdate(trigger.new, trigger.newMap, trigger.oldMap);
        }
        else if(trigger.isDelete){
            UsageDataTriggerHelper.handleAfterdelete(trigger.oldMap);   
        }
    }   
  
}