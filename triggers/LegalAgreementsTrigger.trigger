trigger LegalAgreementsTrigger on Legal_Agreements__c (after insert, after update,after delete, after undelete,before delete){
     /******* Functionality for After ***************/
 if(!(SalesTriggersUtility.marketoTriggerManager.Deactivate_Legal_Agreement_Triggers__c)){
    if(trigger.isafter){
        if(trigger.isinsert || trigger.isupdate){
            LegalAgreements.onTrigger(Trigger.newMap, Trigger.oldMap);
            APXT_Redlining.PlatformDataService.sendData(Trigger.old, Trigger.new);
        }
        if(trigger.isDelete){
            APXT_Redlining.PlatformDataService.sendData(Trigger.old, Trigger.new);
        }
        if(trigger.isundelete){
            APXT_Redlining.PlatformDataService.sendData(Trigger.old, Trigger.new);
        }

    }
    /******* Functionality for Before ***************/
    
    if(trigger.isbefore){
        if(trigger.isdelete){
            LegalAgreements.onTrigger(Trigger.newMap, Trigger.oldMap);
        }
    
    }
}
}