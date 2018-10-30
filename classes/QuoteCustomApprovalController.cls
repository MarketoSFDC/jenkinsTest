public class QuoteCustomApprovalController{
    /*public String quoteId = ApexPages.CurrentPage().getParameters().get('id');
    public list<Apttus_Approval__Approval_Request__c> approvalRequestList{get;set;}
    public Quote quote{get;set;}
    public QuoteCustomApprovalController(ApexPages.StandardController con){
        approvalRequestList = new list<Apttus_Approval__Approval_Request__c>();
        approvalRequestList = getApprovalRequest();
        quote = getQuoteDetails();
    }
    
    public list<Apttus_Approval__Approval_Request__c> getApprovalRequest(){
        return [select id, Name, Apttus_Approval__Step_Name__c, Apttus_Approval__StepSequence__c, Apttus_Approval__Approval_Status__c, 
        Apttus_Approval__Date__c, Apttus_Approval__Assigned_To_Link__c, Apttus_Approval__DependsOn__c, Apttus_Approval__Approver_Comments__c,  
        Apttus_Approval__Action__c, Apttus_Approval__Actual_Approver__c from Apttus_Approval__Approval_Request__c where Related_Quote__c = :quoteId];
    }
    
    public Quote getQuoteDetails(){
        return [select id, Name, Approval_Status_Sales_Operations__c from Quote where id = :quoteId];        
    }
    
    public void updateApprovalStatus(){
         system.debug('method is called');
        quote.Approval_Status_Sales_Operations__c = 'Approval Pending';
        update quote;
    }
	*/
    
}