trigger trigger_Expense on pse__Expense__c (after insert)  { 
    
      // Handle pse__Expense__c object After insert event
      
      if(trigger.isInsert){
               
               /*-----------------------------------------------------------------------------------------------------------
                  AFTER INSERT Event ---- PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER INSERTING THE RECORDS
               --------------------------------------------------------------------------------------------------------------- */
               Trigger_Expense_Handler.afterInsertHandler(Trigger.new);
               
       }
           
          
 }