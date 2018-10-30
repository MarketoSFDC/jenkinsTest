public class AssignGroupstoLines {

      @InvocableMethod
     public static void createGroups(List<String> quoteLines){
     List<SBQQ__QuoteLine__c> theQuoteLines = [SELECT Id, SBQQ__Quote__c, SBQQ__Group__c, Group_Number__c FROM SBQQ__QuoteLine__c WHERE ID IN :quoteLines];    
     string theQuoteID = theQuoteLines[0].SBQQ__Quote__c;
     List<SBQQ__QuoteLine__c> linesToUpdate = new List<SBQQ__QuoteLine__c>();
     List<SBQQ__QuoteLineGroup__c> newQuoteLineGroups = [SELECT Id, Name, SBQQ__Number__c FROM SBQQ__QuoteLineGroup__c where SBQQ__Quote__c = :theQuoteID];
      Map<Decimal, Id> quoteLineGroupMap = new Map<Decimal, Id>();
        
        for (SBQQ__QuoteLineGroup__c nqlg : newQuoteLineGroups){
            quoteLineGroupMap.put(nqlg.SBQQ__Number__c, nqlg.Id);}
        for(SBQQ__QuoteLine__c ql : theQuoteLines){
            if(ql.Group_Number__c !=NULL){
            ql.SBQQ__Group__c = quoteLineGroupMap.get(ql.Group_Number__c);
            linesToUpdate.add(ql);
            }
        }
        update linesToUpdate;
        }  
}