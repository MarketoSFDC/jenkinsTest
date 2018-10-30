trigger SalesInvAftTrig on Sales_Invoice__c (after insert, after update, after delete) {
   Map<Id, List <Sales_Invoice__c>> InvMap = new Map<Id, List<Sales_Invoice__c>>();
   List <Sales_Invoice__c> Inv1 = new List<Sales_Invoice__c>();
   List <Id> OppIds = new List<Id>();
   set <Id> AccAll = new set<id>();
   set <Id> AccIdsPending = new set<Id>();
   set <Id> AccIdsPaid = new set<Id>();
   integer i = 0; 
   integer j = 0; 

    if (trigger.isdelete){
      for (Sales_Invoice__c s : trigger.old){
         if (trigger.old[j].Document_Type__c <> 'Revenue Recognition Activation') {
            OppIds.add(trigger.old[j].Opportunity__c);
         }
         j++;
      }
    } else {
      for (Sales_Invoice__c s : trigger.new){
         AccAll.add(s.Account__r.Id);
         if (s.Payment_Status__c == 'Approved' || s.Payment_Status__c == 'Partially Paid') {
            AccIdsPending.add(s.Account__r.Id);
         } else {
            AccIdsPaid.add(s.Account__r.Id);
         }
         if (trigger.isupdate){
            if (s.Document_Type__c <> 'Revenue Recognition Activation' && s.Last_Payment_Date__c <> trigger.old[i].Last_Payment_Date__c) {
               OppIds.add(s.Opportunity__c);
            }
         } else
         if (trigger.isinsert){
            if (s.Document_Type__c <> 'Revenue Recognition Activation') {
               OppIds.add(s.Opportunity__c);
            }
         }
         i++;
      }
      for (Id accid1 :AccAll){
         for (Sales_Invoice__c s1 : trigger.new){
            if (accid1 == s1.Account__r.Id) {
               Inv1.add(s1);
            }
         }
         InvMap.put(accid1,Inv1);
         Inv1.clear();
      }
    }

   // Update Last Payment Date on Opportunity
   if (!UpdOppFromSalesInv.OSIFirstPass){
      UpdOppFromSalesInv.updateLatestPaymentDate(OppIds);
      UpdOppFromSalesInv.OSIFirstPass = True;
   }
}