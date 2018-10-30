/**
 *  Apttus Approvals Management
 *  CustomQuoteApprovalSummaryController
 *   
 *  @2012-2013 Apttus Inc. 
 */
public with sharing class CustomQuoteApprovalSummaryController {
    /*
    // field names
    private static final String FIELD_NAME_ID = 'Id';
    
    // state
    
    // Quote object
    private Quote QuoteSO = null;
    
    /**
     * Class Constructor specifying initial values
     * @param stdController the standard controller
     */
   /* public CustomQuoteApprovalSummaryController(ApexPages.StandardController stdController) {
        
        // get the approval rule sobject
        Apttus_Approval__Approval_Request__c requestSO = (Apttus_Approval__Approval_Request__c) stdController.getRecord();
        
        // get the Quote sobject
        this.QuoteSO = getQuoteSO(requestSO.Apttus_Approval__Object_Id__c);
        
    }
    
    /**
     * Gets the Quote sobject
     * @return the Quote sobject
     */
   /* public Quote getQuoteSO() {
        return QuoteSO;
        
    }
    
    /**
     * Gets the Quote sobject for the given Quote id
     * @param QuoteId the Quote id
     * @return the Quote sobject
     */
    /*private static Quote getQuoteSO(ID QuoteId) {
        
        // build the opportunity query
        String qryStr = 'SELECT ';
        
        // get field names from the object 
        List<String> fieldNames = new List<String>();
        
        Integer numFields = 0;
        // add object fields
        Schema.DescribesObjectResult metadata = Quote.getSobjectType().getDescribe();
        for (Schema.SObjectField field : metadata.fields.getMap().values()) {
            Schema.DescribeFieldResult fldMetadata = field.getDescribe();
            if (numFields > 0) {
                qryStr += ',';
                
            }
            
            // add the field
            qryStr += fldMetadata.getName();
            
            numFields++;
        
        }
        
        qryStr += ' FROM ' + Quote.getSObjectType();
        qryStr += ' WHERE ';
        qryStr += FIELD_NAME_ID + ' = :QuoteId';
        
        qryStr += ' LIMIT 1';
    
        // get the Quote sobjects
        List<Quote> Quotes = Database.query(qryStr);
        
        return (!Quotes.isEmpty() ? Quotes[0] : null);
        
    }*/
    
}