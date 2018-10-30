trigger KnownIssueUpdateAfterInsert on KI_Update__c (after insert) {
    
    Map<Id,KI_Update__c> myMap = Trigger.newMap; 
    system.debug(myMap);
    KI_Update__c kiu ;
    
    for(KI_Update__c kiupdate : myMap.values()){
        kiu = kiupdate;
        break;
    }
    try{
        KI_Update_Class triggerClass = new KI_Update_Class();
        triggerClass.executeAfterInsert(kiu);
    }
    catch(Exception ex){
        CaseTriggerFunction.sendEcxeptionMailToDeveloper(ex);
    }
    
}