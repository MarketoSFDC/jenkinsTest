trigger trigger_Expense_Report on pse__Expense_Report__c (after insert)  { 

     // Handle pse__Expense_Report__c object After insert event
      
      if(trigger.isInsert){
               
               /*-----------------------------------------------------------------------------------------------------------
                  AFTER INSERT Event ---- PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER INSERTING THE RECORDS
               --------------------------------------------------------------------------------------------------------------- */
               Trigger_Expense_Report_Handler.afterInsertHandler(Trigger.new);
               
       }
    

}