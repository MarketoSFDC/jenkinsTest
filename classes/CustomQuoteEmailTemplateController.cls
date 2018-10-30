public class CustomQuoteEmailTemplateController{
    /*public Quote quote{get;set;}
    public string approvalRequestId{get;set;}
    public CustomQuoteEmailTemplateController(){
        
    }
    
    public List<QuoteLineItem> getQuoteLineItems(){             
         return [select id, Term_Months__c, Product_Name_Copied__c, Discount, 
                Subscription_Start_Date__c, Users__c, Sales_Price_1__c, 
                Total_Line_after_Discount__c, VATline__c, Grand_Total__c,
                Is_Finance_Approval_Required__c, Is_Launch_Pack_Included__c, Is_Support_Approval_Required__c, 
                Is_ENT_Product_Included__c, Is_SMB_Product_Included__c, Is_Quote_using_GBP_currency__c, Is_Operations_Approval_Required__c, 
                ListPrice, Quantity, UnitPrice, CurrencyIsoCode, TotalPrice from QuoteLineItem where QuoteId = :quote.id];
    }
    
    public Apttus_Approval__Approval_Request__c getApprovalRequest(){
        Apttus_Approval__Approval_Request__c approvalRequest = new Apttus_Approval__Approval_Request__c();
        if(approvalRequestId != null && String.isNotBlank(approvalRequestId)){
            approvalRequest = [select id, Apttus_Approval__Approval_Status__c, Apttus_Approval__Date__c, 
                       Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__Request_Comments__c, 
                       Apttus_Approval__Approver_Comments__c, Apttus_Approval__ProcessInstanceId__c from 
                       Apttus_Approval__Approval_Request__c where id = :approvalRequestId];
         }
         return approvalRequest;
    }
    
    public List<Apttus_Approval__Approval_Request__c> getApprovalDetails(){
        List<Apttus_Approval__Approval_Request__c> requestList = new List<Apttus_Approval__Approval_Request__c>();
        if(approvalRequestId != null && String.isNotBlank(approvalRequestId)){
            string processInstanceId = [select id, Apttus_Approval__ProcessInstanceId__c from Apttus_Approval__Approval_Request__c
                   where id = :approvalRequestId].Apttus_Approval__ProcessInstanceId__c;
            requestList = [select Apttus_Approval__Step_Name__c, Apttus_Approval__Approval_Status__c, Apttus_Approval__Date__c,
                   Apttus_Approval__Assigned_To_Name__c, Apttus_Approval__Actual_Approver__c, Apttus_Approval__Approver_Comments__c 
                   from Apttus_Approval__Approval_Request__c where Apttus_Approval__ProcessInstanceId__c = :processInstanceId];
        }  
        return requestList;          
    }
	*/
}