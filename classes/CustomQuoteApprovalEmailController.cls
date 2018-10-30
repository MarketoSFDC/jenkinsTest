/**
 *  Apttus Approvals Management
 *  CustomQuoteApprovalEmailController
 *   
 *  @2012-2013 Apttus Inc. 
 */
public with sharing class CustomQuoteApprovalEmailController {
    /*public String relatedQuoteId {get;set;}
    
    // field names
    private static final String FIELD_NAME_ID = 'Id';
    
    // state
    
    // context controller
    private Apttus_Approval.ContextApprovalEmailController context = null;
    // Quote sobject
    private Quote QuoteSO = null;
    
    private List<QuoteLineItem> quoteLineItems = null;
    
    /**
     * Class Constructor
     */
    /*public CustomQuoteApprovalEmailController() {
        // create the context
        this.context = new Apttus_Approval.ContextApprovalEmailController();
        
        
    }
    
    /**
     * Gets the context controller
     * @return the context controller
     */
    /*public Apttus_Approval.ContextApprovalEmailController getContext() {
        return context;
        
    }
    
    /**
     * Gets the Quote sobject
     * @return the Quote sobject
     */
    /*public Quote getQuoteSO() {
        
        if (QuoteSO == null) {
            Apttus_Approval__Approval_Request__c requestSO = Context.getRequestSO();
            // make sure the object id is available. Email Template preview will not have it populated,
            // in which case we create an empty Quote object
            QuoteSO = (requestSO.Apttus_Approval__Object_Id__c != null 
                      ? getQuoteSO(requestSO.Apttus_Approval__Object_Id__c) 
                      : new Quote());
            
        }
        return QuoteSO;
    }
    
    /**
     * Gets the Quote sobject for the given Quote id
     * @param QuoteId the Quote id
     * @return the Quote sobject
     */
    /*private static Quote getQuoteSO(ID QuoteId) {
        
        // build the Quote query
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
        
    }
    
    public List<QuoteLineItem> getQuoteLineItems(){
         Apttus_Approval__Approval_Request__c requestSO = Context.getRequestSO();
        return [select id, Term_Months__c, Product_Name_Copied__c, Discount, 
                Subscription_Start_Date__c,Subscription_End_Date__c, Users__c, Sales_Price_1__c, 
                Total_Line_after_Discount__c, VATline__c, Grand_Total__c,
                Is_Finance_Approval_Required__c, Is_Launch_Pack_Included__c, Is_Support_Approval_Required__c, 
                Is_ENT_Product_Included__c, Is_SMB_Product_Included__c, Is_Quote_using_GBP_currency__c, Is_Operations_Approval_Required__c, 
                ListPrice, Quantity, UnitPrice, CurrencyIsoCode, TotalPrice from QuoteLineItem where QuoteId = :requestSO.Apttus_Approval__Object_Id__c];
    }*/
    
}