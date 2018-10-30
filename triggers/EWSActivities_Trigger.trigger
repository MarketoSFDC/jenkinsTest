trigger EWSActivities_Trigger on Activities__c (after insert) {
    if(Label.EWSActivator == 'YES' || Test.isRunningTest()){
        try{
            Set<id> eWSAccountsIds = new Set<id>();
    
            for( Activities__c acc : trigger.new){
                eWSAccountsIds.add(acc.Account__c);
            }
    
            if(!eWSAccountsIds.isEmpty()) EWSUtility.handleEWSscenarios(eWSAccountsIds);                
        }catch(exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
    }
}