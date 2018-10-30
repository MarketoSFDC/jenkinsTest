trigger SalesInvB4InsB4Upd on Sales_Invoice__c (before insert, before update) {
   Map<String, Excluded_Sales_Invoice_Document_Type__c> excludedDocumentTypesMap = new Map<String, Excluded_Sales_Invoice_Document_Type__c>();
   excludedDocumentTypesMap = Excluded_Sales_Invoice_Document_Type__c.getAll();
   
   for (Sales_Invoice__c s : trigger.new){
      if (excludedDocumentTypesMap.get(s.Document_Type__c) == null) {
         string id1 = s.Opportunity__c;
         s.Opportunity_Invoices__c = id1;
      } else
      {
         s.Opportunity_Invoices__c = null;
      }
   } 
}