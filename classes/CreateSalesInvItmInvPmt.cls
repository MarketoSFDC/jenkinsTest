/*
   Created Date: 4/12/2013
   Purpose: Accept a list of Sales Invoice Payments and insert records into Sales Invoice Item Invoice Payment object
*/
public class CreateSalesInvItmInvPmt {
   public static boolean SIIFirstPass = False;
   public static void InsertSIIPD(List<Sales_Invoice_Payment__c> InvPmts)
   {
      Set <Id> InvIds = new Set<Id>();
      Boolean result;
      Map <Id, decimal> pmtinvitmpriceMap = new map <Id, decimal>();
      Decimal p=0;
      for (Sales_Invoice_Payment__c sip1 : InvPmts){
         result = InvIds.add(sip1.Sales_Invoice__c);
      }

      List < Sales_Invoice_Item_Payment_Detail__c > siipdList = new List < Sales_Invoice_Item_Payment_Detail__c >();
      List <Sales_Invoice_Item__c> siiList = [select Id,Sales_Invoice__c,sales_invoice__r.subtotal__c, Extended_Price__c
           from Sales_Invoice_Item__c where Sales_Invoice__c in :InvIds];
      system.debug('####siiListsize '+siiList.size());
      for (Sales_Invoice_Payment__c sip2 : InvPmts){
         for (Sales_Invoice_Item__c sii1 : siiList){
            if (sip2.Sales_Invoice__c == sii1.Sales_Invoice__c)
            {
            p = sii1.sales_invoice__r.Subtotal__c; 
            }
         }
         pmtinvitmpriceMap.put(sip2.id,p);
         system.debug('####pmtinvitmpriceMap '+pmtinvitmpriceMap);
         p=0;
      }

      for (Sales_Invoice_Payment__c sip3 : InvPmts){
         for (Sales_Invoice_Item__c sii2 : siiList){
            Sales_Invoice_Item_Payment_Detail__c siipd = new Sales_Invoice_Item_Payment_Detail__c();
            if (sip3.Sales_Invoice__c == sii2.Sales_Invoice__c)
            {
               siipd.Sales_Invoice_Item__c = sii2.Id;
               siipd.Sales_Invoice_Payment_Detail__c = sip3.Id;
               if (pmtinvitmpriceMap.get(sip3.id) <> null && pmtinvitmpriceMap.get(sip3.id) <> 0){
                  siipd.Payment_Applied__c = sip3.Payment_Total__c*sii2.Extended_Price__c/pmtinvitmpriceMap.get(sip3.id);
                  siipd.CurrencyIsoCode = sip3.CurrencyIsoCode;
         system.debug('####Payment_Applied__c '+siipd.Payment_Applied__c );
         system.debug('####Sales_Invoice_Payment_Detail__c '+siipd.Sales_Invoice_Payment_Detail__c );
         system.debug('####Sales_Invoice_Item__c '+siipd.Sales_Invoice_Item__c );
               } else
               {
                  siipd.Payment_Applied__c = 0;
                  siipd.CurrencyIsoCode = sip3.CurrencyIsoCode;
               }
               if (siipd.Sales_Invoice_Item__c <> null && siipd.Sales_Invoice_Payment_Detail__c <> null){
                  siipdList.add(siipd);
               }
            }
         }
      }
      if (siipdList.size()>0){
         insert siipdList;
      }
   }
}