trigger SalesInvItmB4InsB4Upd on Sales_Invoice_Item__c (before insert, before update) {

   List <Id> oliIds = new List <Id>();
   for (Sales_Invoice_Item__c sii : trigger.new){
      oliIds.add(sii.Opp_Product_Id__c);
   }
   map <Id, OpportunityLineItem> olimap = new map <Id, OpportunityLineItem> ([select id, Total_Price_Services__c, Total_ARR_for_RUSF__c from OpportunityLineItem
        where id in :oliIds]);

   for (Sales_Invoice_Item__c sii2 : trigger.new){
     if(olimap.get(sii2.Opp_Product_Id__c) <> null){
        if (olimap.get(sii2.Opp_Product_Id__c).Total_ARR_for_RUSF__c <> null & olimap.get(sii2.Opp_Product_Id__c).Total_ARR_for_RUSF__c <> 0) {
           sii2.Opp_Line_Total__c = olimap.get(sii2.Opp_Product_Id__c).Total_ARR_for_RUSF__c;
        } else
        if (olimap.get(sii2.Opp_Product_Id__c).Total_Price_Services__c <> null) {
           sii2.Opp_Line_Total__c = olimap.get(sii2.Opp_Product_Id__c).Total_Price_Services__c;
        } else
        if (olimap.get(sii2.Opp_Product_Id__c).Total_Price_Services__c == null & 
            olimap.get(sii2.Opp_Product_Id__c).Total_ARR_for_RUSF__c == null) {
           sii2.Opp_Line_Total__c = 0;
        }
     }
   }
}