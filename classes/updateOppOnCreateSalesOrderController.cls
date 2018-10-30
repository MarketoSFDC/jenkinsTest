/*****************************************************
 * Class name : updateOppOnCreateSalesOrderController
 * Description :Controller for the page updateOppOnCreateSalesOrder_LEX
 * 
 * *****************************************************/

public class updateOppOnCreateSalesOrderController{
    
    public updateOppOnCreateSalesOrderController()
    {
        
    }
    
  
    public Pagereference redirectToIntacct()
    {
        String oppId = ApexPages.currentPage().getParameters().get('id') ;
        Opportunity oppRecord = new Opportunity();
        oppRecord = [Select Id,IsSalesOrderCreated__c,Intacct_Customer_ID__c From Opportunity Where Id =:oppId];
        oppRecord.IsSalesOrderCreated__c = true;
        
        update oppRecord;
       
        String intacct_URL = ApexPages.currentPage().getParameters().get('intactUrl');
        PageReference pageRef = new PageReference(EncodingUtil.urlDecode(intacct_URL,'UTF-8'));
        
        return pageRef;
    }

}