global class ProactiveCasesSchedulerClass implements Schedulable {
   global void execute(SchedulableContext sc) {
      ProactiveCaseBatchClass b = new ProactiveCaseBatchClass(); 
      database.executebatch(b);
   }
}