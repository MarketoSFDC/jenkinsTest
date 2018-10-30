public class OpportunityLineItemController {
  public id oppid{get;set;}
  public id proId {get;set;}
  
  List<OpportunityLineItem> oli = new List<OpportunityLineItem>();
  
  public string getProductQuantity(){
  
      oli = [Select id, Name,Quantity from OpportunityLineitem where OpportunityID=:oppid and Product2Id=:proId LIMIT 1];
      if(!oli.isEmpty()){
          return oli[0].Quantity.toPlainString();
      }else{
          return '';
      }
      
  }
  
}