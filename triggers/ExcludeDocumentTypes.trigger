trigger ExcludeDocumentTypes on Sales_Order__c (before insert, before update) {
   Map<String, Excluded_Sales_Order_Document_Type__c> excludedDocumentTypesMap = new Map<String, Excluded_Sales_Order_Document_Type__c>();
   excludedDocumentTypesMap = Excluded_Sales_Order_Document_Type__c.getAll();
   
   for (Sales_Order__c s : trigger.new){
      if (excludedDocumentTypesMap.get(s.Document_Type__c) == null) {
         string id1 = s.Opportunity__c;
         s.Opportunity_Orders__c = id1;
      } else
      {
         s.Opportunity_Orders__c = null;
      }
   } 
}