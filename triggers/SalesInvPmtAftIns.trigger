trigger SalesInvPmtAftIns on Sales_Invoice_Payment__c (after insert) {

   //********************************************** Insert SalesInvItmInvPmt BEGIN **********************************************//
   // Pass list of all Sales Invoice Payment records to the class
   // Check to ensure the Apex call is performed once per trigger execution
   if (! CreateSalesInvItmInvPmt.SIIFirstPass){
      CreateSalesInvItmInvPmt.InsertSIIPD(trigger.new);
      CreateSalesInvItmInvPmt.SIIFirstPass = True;
   }
   //********************************************** Insert SalesInvItmInvPmt END **********************************************//
}