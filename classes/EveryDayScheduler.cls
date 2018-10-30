/***************************************************************************
This Scheduler Class Runs after Every One Hour
*****************************************************************************/
global class EveryDayScheduler implements Schedulable{   
    global void execute(SchedulableContext ctx){
        try{
            if((Support_Switches__c.getInstance('AppViewSwitch') != null && Support_Switches__c.getInstance('AppViewSwitch').isActive__c == 'Yes') || Test.isRunningTest()){
                Database.executeBatch(new AppviewBatchClass(),200);
            }
            
            if((Support_Switches__c.getInstance('BizibleSupportSwitch') != null && Support_Switches__c.getInstance('BizibleSupportSwitch').isActive__c == 'Yes') || Test.isRunningTest()){
                Database.executeBatch(new BizibleJiveContactSyncBatch(),60);
            }
       }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
    }     
}