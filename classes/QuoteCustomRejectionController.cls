public class QuoteCustomRejectionController{
    public String quoteId = ApexPages.CurrentPage().getParameters().get('quoteId');
    public Quote quote{get;set;}
    public QuoteCustomRejectionController(){
          quote = getQuoteDetails();
          quote.Comments_by_Sales_Ops__c = '';
    }
    
    public Quote getQuoteDetails(){
        return [select id, Name, Approval_Status_Sales_Operations__c, Comments_by_Sales_Ops__c from Quote where id = :quoteId];        
    }
    
    public PageReference rejectRequest(){
        quote.Approval_Status_Sales_Operations__c = 'Declined';
        update quote;
        PageReference pf = new PageReference('/'+quote.id);
        return pf;
    }
}