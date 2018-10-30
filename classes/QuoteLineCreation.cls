public class QuoteLineCreation {
    @InvocableMethod
    public static List<SBQQ__QuoteLine__c> createQuoteLine(List<String> theQuotes){
    
    List<SBQQ__Quote__c> quotes = [SELECT Id, SBQQ__Opportunity2__r.SBQQ__RenewedContract__c, SBQQ__MasterContract__r.SBQQ__Quote__c FROM SBQQ__Quote__c WHERE Id IN :theQuotes];
        Map<ID,Integer> groupContactDBsize = new Map<ID,Integer>();
        List<SBQQ__QuoteLineGroup__c> quoteLineGroups = new List<SBQQ__QuoteLineGroup__c> ();
        String masterContractQuote = '';
        List<SBQQ__Quote__c> cotermed = new List<SBQQ__Quote__c> ();

        quoteLineGroups = new List<SBQQ__QuoteLineGroup__c> ();
        for (SBQQ__Quote__c q : quotes){
            
            //Check to see if the opportunity is renewal related. Avoiding custom setting due to having to 
            //update to support Rubiks/Phoenix. 
            if(q.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c != NULL)
            {
            //If it is, find the contract related, pulling a relationship field wasn't working.
            	Contract theContract = [SELECT ID, SBQQ__Quote__c from Contract where id = :q.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c];
             //Add the original quote that created the opportunity 
                masterContractQuote = theContract.SBQQ__Quote__c; 
             //Check to see if the there are any admendments. 
                cotermed = [SELECT ID, SBQQ__Primary__c, 
                                                 SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.CloseDate from SBQQ__Quote__c
                                                 where SBQQ__MasterContract__c = :theContract.Id
                                                 and SBQQ__Opportunity2__r.StageName = 'Closed Won' 
                                                 and SBQQ__Primary__c = true
                                                 Order by SBQQ__Opportunity2__r.CloseDate Desc];  
            }
            //If it's not a renewal, then pull find amendments and set the masterContractQuote to the orginal quote
            else if (q.SBQQ__MasterContract__c !=NULL)
            {
                cotermed = [SELECT ID, SBQQ__Primary__c, 
                                                 SBQQ__Opportunity2__c, SBQQ__Opportunity2__r.CloseDate from SBQQ__Quote__c
                                                 where SBQQ__MasterContract__c = :q.SBQQ__MasterContract__c 
                                                 and SBQQ__Opportunity2__r.StageName = 'Closed Won' 
                                                 and SBQQ__Primary__c = true
                                                 Order by SBQQ__Opportunity2__r.CloseDate Desc];  
                masterContractQuote = q.SBQQ__MasterContract__r.SBQQ__Quote__c; 
            }
      
            //If there is an amendment, use the oldest and get the groups
            if(cotermed.size() > 0)
            {
            mastercontractQuote = cotermed[0].id;
            quoteLineGroups = [SELECT Id, Name, Contact_Database_size__c, SBQQ__Number__c FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c  = :mastercontractQuote];    
            }
            
            //If there isn't, use the original quote and get the groups.
            if(cotermed.size() < 1)
            {
            quoteLineGroups = [SELECT Id, Name, Contact_Database_size__c, SBQQ__Number__c FROM SBQQ__QuoteLineGroup__c WHERE SBQQ__Quote__c = :masterContractQuote];    
            }
         
        
         //For each of the groups, create a new group with the same contact database size.
        List<SBQQ__QuoteLineGroup__c> newQuoteLineGroups = new List<SBQQ__QuoteLineGroup__c>();
        for (SBQQ__QuoteLineGroup__c qlg : quoteLineGroups){
            SBQQ__QuoteLineGroup__c newQLG = new SBQQ__QuoteLineGroup__c(
                SBQQ__Number__c = qlg.SBQQ__Number__c,
                Name = qlg.Name,
                SBQQ__Quote__c = q.id,
                SBQQ__NetTotal__c = 0,
                SBQQ__ListTotal__c = 0,
                SBQQ__CustomerTotal__c = 0,
                Contact_Database_Size__c = qlg.Contact_Database_Size__c
                );
                newQuoteLineGroups.add(newQLG);
        }
        
        insert newQuoteLineGroups;
        Map<Decimal, Id> quoteLineGroupMap = new Map<Decimal, Id>();
            
        //Add to a map for easy assignments
        for (SBQQ__QuoteLineGroup__c nqlg : newQuoteLineGroups){
            quoteLineGroupMap.put(nqlg.SBQQ__Number__c, nqlg.Id);
        }
        
        List<SBQQ__QuoteLine__c> theQuoteLines = [SELECT Id, SBQQ__SegmentIndex__c, SBQQ__Product__r.ProductCode, SBQQ__Quote__c, SBQQ__Group__c, Group_Number__c, SBQQ__Quantity__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :q.id];
        
            //For each of the quote lines, assign the groups so they match the previous groupings.
        Map<Decimal, Decimal> groupQTY = new Map<Decimal, Decimal>();
        for(SBQQ__QuoteLine__c ql : theQuoteLines)
        {
            ql.SBQQ__Group__c = quoteLineGroupMap.get(ql.Group_Number__c);
    
        }
      update newQuoteLineGroups;
     
        }
       
        return null;
    }
}