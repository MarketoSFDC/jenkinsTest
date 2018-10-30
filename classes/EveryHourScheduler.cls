/***************************************************************************
This Scheduler Class Runs after Every One Hour
*****************************************************************************/
global class EveryHourScheduler implements Schedulable{   
    global void execute(SchedulableContext ctx){
        try{
            if( (Support_Switches__c.getInstance('SMNotificationModule') != null && Support_Switches__c.getInstance('SMNotificationModule').isActive__c == 'Yes') || Test.isRunningTest()){
                CaseTriggerFunctionUpdated.escalatedCase();
            }
       }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
    }     
}