public class IntacctOrderController {
  public id  oppid{get;set;}
  List<Sales_Order__c> lstSO = new List<Sales_Order__c> ();
     public IntacctOrderController ()
     {
     }
     public string getdocumentno()
     {
          lstSO = [select opportunity__c,Document_Number__c from sales_order__c where opportunity__c=:oppid limit 1];
          if(!lstSO.isEmpty()){
              return lstSO[0].Document_Number__c; 
          }else{
              return '';
          }
     }
}