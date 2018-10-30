@istest
public class test_SalesInvAndRelated
{
   static testmethod void mytest()
   {
      Account acc=new Account(Name='test Account1',ownerid=UserInfo.getUserId());
      acc.BillingCity = 'Ichalkaranji';
        acc.BillingCountry = 'India';
        acc.BillingStreet = 'Test Street';
        acc.BillingState ='Test Billing State';
        acc.BillingPostalCode ='12345';
        acc.ShippingCity ='Pune';
        acc.ShippingCountry ='India';
        acc.ShippingPostalCode = '12345';
        acc.ShippingState = 'Maharashtra';
        acc.ShippingStreet = 'Test Shipping Street';
      insert acc;
       
      Opportunity opp=new Opportunity(Name='test Opportunity1',AccountId=acc.id,StageName='Closed Won',CloseDate=Date.today(),ownerid=UserInfo.getUserId(),Rep_Create_ARR__c=2);
      insert opp;
      Sales_Invoice__c si=new Sales_Invoice__c(Account__c=acc.id,Opportunity__c=opp.id,name='INVTest-1',subtotal__c=1000);
      insert si;
      Sales_Invoice_Item__c sii1=new Sales_Invoice_Item__c(Opportunity__c=opp.id, Sales_Invoice__c=si.id,Extended_Price__c=0);
      insert sii1;
      Sales_Invoice_Item__c sii2=new Sales_Invoice_Item__c(Opportunity__c=opp.id, Sales_Invoice__c=si.id,Extended_Price__c=300);
      insert sii2;
      Sales_Invoice_Item__c sii3=new Sales_Invoice_Item__c(Opportunity__c=opp.id, Sales_Invoice__c=si.id,Extended_Price__c=700);
      insert sii3;
      Sales_Invoice_Payment__c sip=new Sales_Invoice_Payment__c( Sales_Invoice__c=si.id, Amount__c=100,CurrencyIsoCode='GBP',
           Payment_Type__c = 'Payment', Payment_Date__c = date.Today());
      insert sip;
      List <Sales_Invoice_Item_Payment_Detail__c> siipdList = [select Id,Payment_Applied__c,CurrencyIsoCode from Sales_Invoice_Item_Payment_Detail__c 
           where Sales_Invoice_Payment_Detail__c = :sip.id order by Payment_Applied__c asc];
      system.assertequals(3,siipdList.size());
      system.assertequals(0,siipdList[0].Payment_Applied__c);
      system.assertequals(30,siipdList[1].Payment_Applied__c);
      system.assertequals(70,siipdList[2].Payment_Applied__c);
      system.assertequals('GBP',siipdList[0].CurrencyIsoCode);
 //     system.assertequals(sip.Payment_Date__c,oppList[0].Latest_Payment_Date__c);
 //     system.assertequals(si.Opportunity__c,oppList[0].Opportunity_Invoices__c);
      CreateSalesInvItmInvPmt.SIIFirstPass = False;
      Sales_Invoice__c si1=new Sales_Invoice__c(Account__c=acc.id,Opportunity__c=opp.id,name='PROSVC',subtotal__c=1000);
      insert si1;
      Sales_Invoice_Item__c sii4=new Sales_Invoice_Item__c(Opportunity__c=opp.id, Sales_Invoice__c=si1.id,Extended_Price__c=0);
      insert sii4;
      Sales_Invoice_Item__c sii5=new Sales_Invoice_Item__c(Opportunity__c=opp.id, Sales_Invoice__c=si1.id,Extended_Price__c=0);
      insert sii5;
      Sales_Invoice_Payment__c sip1=new Sales_Invoice_Payment__c( Sales_Invoice__c=si1.id, Amount__c=100,CurrencyIsoCode='USD',Payment_Type__c = 'Payment');
      insert sip1;
      List <Sales_Invoice_Item_Payment_Detail__c> siipdList1 = [select Id,Payment_Applied__c,CurrencyIsoCode from Sales_Invoice_Item_Payment_Detail__c 
           where Sales_Invoice_Payment_Detail__c = :sip1.id order by Payment_Applied__c asc];
      system.assertequals(2,siipdList1.size());
      system.assertequals(0,siipdList1[0].Payment_Applied__c);
      system.assertequals(0,siipdList1[1].Payment_Applied__c);
      system.assertequals('USD',siipdList1[0].CurrencyIsoCode);
      system.assertequals(null,si.Opportunity_Invoices__c);
   }
}