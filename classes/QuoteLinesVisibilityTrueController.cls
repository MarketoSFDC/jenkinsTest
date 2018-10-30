public class QuoteLinesVisibilityTrueController{
    public static Id quoteId{get;set;}
    public List<SBQQ__QuoteLine__c> quoteLinesList;
    
    public static List<SBQQ__QuoteLine__c>getQuoteLinesList(){
        List<SBQQ__QuoteLine__c> quoteLinesList = new List<SBQQ__QuoteLine__c>();
        String query = 'SELECT ';
        
        // Get Quote Field Set fields       
        List<Schema.FieldSetMember> fieldSetMembersList = new List<Schema.FieldSetMember>();    
        fieldSetMembersList = SObjectType.SBQQ__QuoteLine__c.FieldSets.ApprovalRequest.getFields();     
        for(Schema.FieldSetMember f : fieldSetMembersList) {
            query += f.getFieldPath() + ', ';            
        }
        String visible = 'Never';
        query += 'Id, Name, SBQQ__Quote__c, SBQQ__Quote__r.SBQQ__Opportunity2__r.CurrencyISOCode, SBQQ__ComponentVisibility__c,SBQQ__ProductFamily__c,Quote_Line_Sort_Order__c FROM SBQQ__QuoteLine__c where SBQQ__ComponentVisibility__c != \''+String.escapeSingleQuotes(visible)+'\' AND SBQQ__Quote__c =\'' + quoteId +'\' Order By LineSortField__c ASC,Quote_Line_Sort_Order__c ASC';
        //Added order by to sort the Quote Lines based on the Name (Multi-instance) and sort order, Bundle should always be the first line
        System.debug('Final Query=====>' + query);
        quoteLinesList = Database.query(query);
        
        //Setting Decimals to 0 for Quantity field for each quoteLine
        for(SBQQ__QuoteLine__c qtln : quoteLinesList){
            qtln.SBQQ__Quantity__c = qtln.SBQQ__Quantity__c.setScale(0);
        }
        System.debug('#@#@#@#@@#@#@#@#@ quoteLinesList : '+ quoteLinesList);    
        return quoteLinesList;    
    }
}