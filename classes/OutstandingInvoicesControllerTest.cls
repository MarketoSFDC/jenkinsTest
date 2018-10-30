@istest
public class OutstandingInvoicesControllerTest{
    static testmethod void mytest(){
         Account TestAcc1 = new Account(Name='Test Account');
         TestAcc1.BillingCity = 'NewYork';
         TestAcc1.BillingCountry = 'United States';
         TestAcc1.BillingStreet = 'Test Street';
         TestAcc1.BillingState ='Test Billing State';
         TestAcc1.BillingPostalCode ='12345';
         TestAcc1.ShippingCity ='Pune';
         TestAcc1.ShippingCountry ='India';
         TestAcc1.ShippingPostalCode = '12345';
         TestAcc1.ShippingState = '';
         TestAcc1.ShippingStreet = 'Test Shipping Street';
         insert TestAcc1;
               
         Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = TestAcc1.id, StageName = 'Discovery', MainCompetitor__c ='Act-On',Rep_Create_ARR__c = 10,CloseDate=System.Today());
         insert opp;
         
         Date yestDay = System.Today() - 1;
         
         
         Sales_Invoice__c salesInvoice = new Sales_Invoice__c(Account__c = TestAcc1.Id, Payment_Due_Date__c = yestDay, Amount_Due__c = 100);
         insert salesInvoice;
         
         Sales_Invoice_Item__c salesInvoiceItem = new Sales_Invoice_Item__c(Name = 'Test Item', Sales_Invoice__c = salesInvoice.Id);
         insert salesInvoiceItem;
         
         Test.StartTest();
         ApexPages.StandardController con = new ApexPages.StandardController(TestAcc1);
         ApexPages.CurrentPage().getParameters().put('id',TestAcc1.id);
         OutstandingInvoicesController oic = new OutstandingInvoicesController(con);
         Test.StopTest();
    }    
    
    //Added By JadeGlobal on 24th Feb 2016 to cover SalesInvItmB4InsB4Upd Trigger
    static testmethod void coverSalesInvItmB4InsB4Upd() {
        list<Account> lstAcc = TestCPQUtilityClass.createAccounts(1);
        insert lstAcc;
        
        list<Opportunity> lstOpptys = TestCPQUtilityClass.createOpportunities(lstAcc,1);
        insert lstOpptys;
        
        list<Product2> lstProd = TestCPQUtilityClass.createCustomProducts(3);
        insert lstProd;
       
        Id stdPricebookId = Test.getStandardPricebookId();
        
        TestCPQUtilityClass.createStdPricebookEntries(lstProd,stdPricebookId);
        
        list<PriceBook2> lstPriceBook = TestCPQUtilityClass.createCustomPriceBooks(1);
        insert lstPriceBook;
        
        list<PriceBookEntry> lstPBEntry = TestCPQUtilityClass.createPriceBookEntries(lstProd,lstPriceBook);
        insert lstPBEntry;

        Date yestDay = System.Today() - 1;
        
        
        list<OpportunityLineItem> lstOpptyLines = TestCPQUtilityClass.createOppLineItems(lstOpptys,lstPBEntry);
        for(OpportunityLineItem oli :lstOpptyLines){
            oli.Product_Type__c = 'Services';
            //oli.TotalPrice = 2500;
            oli.Is_Advantage_Bundle__c = TRUE;
            oli.Total_ARR_for_RUSF__c = 1000;
        }
        insert lstOpptyLines;

        Sales_Invoice__c salesInvoice = new Sales_Invoice__c(Account__c = lstAcc[0].Id, Payment_Due_Date__c = yestDay, Amount_Due__c = 100);
        insert salesInvoice;
        
        Sales_Invoice_Item__c salesInvoiceItem = new Sales_Invoice_Item__c(Sales_Invoice__c = salesInvoice.id,Opp_Product_Id__c = lstOpptyLines[0].id);
        insert salesInvoiceItem;
        
        list<OpportunityLineItem> lstOpptyLines1 = TestCPQUtilityClass.createOppLineItems(lstOpptys,lstPBEntry);
        for(OpportunityLineItem oli :lstOpptyLines1){
            oli.Product_Type__c = 'Services';
            //oli.TotalPrice = 2500;
            oli.Is_Advantage_Bundle__c = TRUE;
        }
        insert lstOpptyLines1;
        
        Sales_Invoice__c salesInvoice1 = new Sales_Invoice__c(Account__c = lstAcc[0].Id, Payment_Due_Date__c = yestDay, Amount_Due__c = 100);
        insert salesInvoice1;
        
        Sales_Invoice_Item__c salesInvoiceItem1 = new Sales_Invoice_Item__c(Sales_Invoice__c = salesInvoice1.id,Opp_Product_Id__c = lstOpptyLines1[0].id);
        insert salesInvoiceItem1;
        
        
        list<OpportunityLineItem> lstOpptyLines2 = TestCPQUtilityClass.createOppLineItems(lstOpptys,lstPBEntry);
        for(OpportunityLineItem oli :lstOpptyLines2){
            oli.Product_Type__c = 'test';
            oli.Is_Advantage_Bundle__c = FALSE;
            oli.Total_ARR_for_RUSF__c = null;
        }
        insert lstOpptyLines2;
        
        Sales_Invoice__c salesInvoice2 = new Sales_Invoice__c(Account__c = lstAcc[0].Id, Payment_Due_Date__c = yestDay, Amount_Due__c = 100);
        insert salesInvoice2;
        
        Sales_Invoice_Item__c salesInvoiceItem2 = new Sales_Invoice_Item__c(Sales_Invoice__c = salesInvoice2.id,Opp_Product_Id__c = lstOpptyLines2[0].id);
        insert salesInvoiceItem2;
    }  
    
}