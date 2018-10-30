@IsTest
public class QuoteLinesVisibilityTrueControllerTest {
    public static List<SBQQ__QuoteLine__c> quoteLinesList;
    public static testMethod void testQuoteLines(){
        Account a = new Account();
        a.Name='TestAccount'; 
        a.ShippingCountry='Australia';
        a.Sales_Region__c='Australia';
        a.ABN_No__c=' Test 1234';
        a.BillingCountry = 'United States';
        a.BillingStreet = 'Test Street';
        a.BillingState ='Test Billing State';
        a.BillingPostalCode ='12345';
        a.ShippingCity ='Pune';
        a.ShippingCountry ='India';
        a.ShippingPostalCode = '12345';
        a.ShippingState = 'Maharashtra';
        a.ShippingStreet = 'Test Shipping Street';  
        a.Accounting_Email__c = 'test@gmail.com';
        a.Accounting_Contact_First_Name__c = 'FirstName';
        a.Accounting_Contact_Last_Name__c = 'LastName';
        a.Website = 'www.google.com';
        insert a;
        
        // Insert Product
        List<Product2> prodList = new List<Product2>();
        Product2 product = new Product2(Name = 'Test Product', ProductCode = 'TESTPRODCODE', isActive=TRUE);
        prodList.add(product);
        
        Product2 prod2 = new Product2(Name = 'Test Product 2', ProductCode = 'TESTCODEPRODCODE', isActive=TRUE);
        prodList.add(prod2);
        
        insert prodList;
        
        Id stdPBId = Test.getStandardPricebookId();
        
        // Insert products into Standard PB
        List<PriceBookEntry> stdPBEList = new List<PriceBookEntry>();
        PriceBookEntry stdPbe1 = new PriceBookEntry(Product2Id = prodList[0].Id, PriceBook2Id = stdPBId, UnitPrice = 10, isActive = TRUE);
        PriceBookEntry stdPbe2 = new PriceBookEntry(Product2Id = prodList[1].Id, PriceBook2Id = stdPBId, UnitPrice = 10, isActive = TRUE);       
        stdPBEList.add(stdPbe1);
        stdPBEList.add(stdPbe2);
        insert stdPBEList;
        
        // Insert MKTO Std PB.
        Pricebook2 mktoPB = new PriceBook2(name='MKTO STD PB', isActive=TRUE);
        insert mktoPB;
        
        List<PriceBookEntry> pbeList = new List<PriceBookEntry>();
        PriceBookEntry pbe = new PriceBookEntry (Product2Id = prodList[0].Id, PriceBook2Id = mktoPB.Id, UnitPrice = 10, isActive = TRUE, UseStandardPrice = false);
        PriceBookEntry pbe2 = new PriceBookEntry (Product2Id = prodList[1].Id, PriceBook2Id = mktoPB.Id, UnitPrice = 10, isActive = TRUE, UseStandardPrice = false);
        pbeList.add(pbe);
        pbeList.add(pbe2);
        insert pbeList;
        
        Opportunity oppty = new Opportunity(Name='Test Opportunity ', Pricebook2Id = mktoPB.Id, StageName='Prospecting',CloseDate=System.today().addMonths(1),AccountId=a.Id, type = 'Renewal');
        insert oppty;
             
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=oppty.Id,SBQQ__Account__c= oppty.accountId, SBQQ__StartDate__c = System.Today());        
        insert quote2;
        
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote2.Id, SBQQ__Product__c = prodList[0].Id, SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0);
        quoteLineList .add(quoteLine1);
        
        SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote2.Id, SBQQ__Product__c = prodList[1].Id, SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0);
        quoteLineList.add(quoteLine2);
        insert quoteLineList;       
        
        QuoteLinesVisibilityTrueController.quoteId = quote2.Id;        
        quoteLinesList = QuoteLinesVisibilityTrueController.getQuoteLinesList();
    }   
}