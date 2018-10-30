global class SchedulerForUniqueUserReport implements Schedulable{
    
    public static String sched = system.label.ScheduleUniqueUserReport; //LAST DAY OF EVERY MONTH AT 23:59:59

    global static String scheduleMe() {
        SchedulerForUniqueUserReport  SC = new SchedulerForUniqueUserReport (); 
        return System.schedule('My batch Job'+system.now(), sched, SC);
    }

    global void execute(SchedulableContext sc) {

        UniqueUserBatchClass  b1 = new UniqueUserBatchClass();
        ID batchprocessid = Database.executeBatch(b1,200);           
    }
}