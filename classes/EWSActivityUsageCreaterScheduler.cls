global class EWSActivityUsageCreaterScheduler implements Schedulable {  

    global void execute(SchedulableContext context){
    try{ Database.executeBatch(new EWSActivityUsageCreater()); }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
    }
}