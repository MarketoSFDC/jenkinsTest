/***************************************************************************
This Scheduler Class Runs On Every Five Minutes
*****************************************************************************/
global class EveryFiveMinuteScheduler implements Schedulable{    
    global void execute(SchedulableContext ctx){
       try{
            if(Label.P1EnhancementSwitch == 'Yes' || Test.isRunningTest()) P1EnhancementModule.p1MilestoneTracking();
            if(Support_Switches__c.getInstance('CsmNotificationModule') != null && Support_Switches__c.getInstance('CsmNotificationModule').isActive__c == 'Yes') CustomerSucessCommunication.getNotification();
             
             
             
            if((Support_Switches__c.getInstance('SendInitResponseNotification') != null && Support_Switches__c.getInstance('SendInitResponseNotification').isActive__c == 'Yes') || Test.isrunningTest())SendInitialResponseNotification.initResponseNotificationToManager();
            
       }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
    }
}