/***
Description: This test class will Cover OpportunityLineItemTrigger 
created date : 3/4/2015
***/

@isTest
public class OpportunityLineItemTriggerTest{
    
    public static testmethod void testData(){
        List<Account> accountList = new List<Account>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        List<OpportunityLineItem> opportunityLineItemsList = new List<OpportunityLineItem>();
        List<Product2> productsToInsertList = new List<Product2>();
        List<PriceBook2> priceBooksList = new List<PriceBook2>();    
        List<PriceBookEntry>  priceBookEntryList = new List<PriceBookEntry>();
        
        //Insert Account record
        accountList = TestCPQUtilityClass.createAccounts(1);
        if(!accountList.isEmpty()){
            insert accountList ;
        }
        
        //Insert priceBook record
        priceBooksList =TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBooksList.isEmpty()){
            insert priceBooksList ;
        }
        
        //Insert opportunity record
        opportunityList =TestCPQUtilityClass.createOpportunities(accountList ,2);
        for(integer i=0;i<opportunityList.size();i++){
            opportunityList[i].Pricebook2Id=priceBooksList[0].id;
        }
        if(!opportunityList.isEmpty()){
            insert opportunityList;    
        }
        
        
        //Insert products record
        productsToInsertList =TestCPQUtilityClass.createCustomProducts(1);
        if(!productsToInsertList.isEmpty()){
            insert productsToInsertList;    
        }
        
        id pbId = Test.getStandardPricebookId();
        TestCPQUtilityClass.createStdPricebookEntries(productsToInsertList,pbid);
        
        //Insert priceBookEntry record
        priceBookEntryList =TestCPQUtilityClass.createPriceBookEntries(productsToInsertList ,priceBooksList );
        if(!priceBookEntryList.isEmpty()){
            insert priceBookEntryList ;
        }
        
        //Insert OpptyProduct_ARR_Calculation_Setting__c record
        OpptyProduct_ARR_Calculation_Setting__c opcs = new OpptyProduct_ARR_Calculation_Setting__c();
        opcs.Name='Test OpptyProduct';
        opcs.Opportunity_Id__c=opportunityList[1].Id;
        opcs.Opportunity_Name__c=opportunityList[0].name;
        insert opcs;
        
        // Insert Opportunity Products
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opportunityList[0].Id, PricebookEntryId = priceBookEntryList [0].Id, UnitPrice = 10, Quantity = 20);
        opportunityLineItemsList.add(oli);
        
        //Insert OpportunityLineItem record 
        if(!opportunityLineItemsList.isEmpty()){
            insert opportunityLineItemsList;
        }
        system.debug('opportunityLineItemsList============='+opportunityLineItemsList);
        
        
        /*opportunityLineItemsList=TestCPQUtilityClass.createOppLineItems(opportunityList ,priceBookEntryList );
        system.debug(opportunityLineItemsList);
        insert opportunityLineItemsList;*/
        test.startTest();
        //Insert rubic quote
         SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__Primary__c=True,
                                                   SBQQ__ShippingCountry__c='Australia',Rubiks_Quote__c=true, SBQQ__Opportunity2__c=opportunityList[0].Id,SBQQ__Account__c= opportunityList[0].accountId,SBQQ__StartDate__c=date.today());   
        insert quote;
       
        // Insert Quote Lines
        List<SBQQ__Quote__c> quotesToPassList=new List<SBQQ__Quote__c>();
        quotesToPassList.add(quote);
        List<SBQQ__QuoteLine__c> quoteLines=TestCPQUtilityClass.createQuoteLines(quotesToPassList,1,productsToInsertList);
        
        //insert quoteLines;
        
        //update quoteLines;
         
        test.stopTest();
        
    }//End of testmethod 
  
     public static testmethod void testMaxDbSizeForSolutionOppty(){
        List<Account> accountList = new List<Account>();
        List<Opportunity> opportunityList = new List<Opportunity>();
        List<OpportunityLineItem> opportunityLineItemsList = new List<OpportunityLineItem>();
        List<Product2> productsToInsertList = new List<Product2>();
        List<PriceBook2> priceBooksList = new List<PriceBook2>();    
        List<PriceBookEntry>  priceBookEntryList = new List<PriceBookEntry>();
        
        //Insert Account record
        accountList = TestCPQUtilityClass.createAccounts(1);
        if(!accountList.isEmpty()){
            insert accountList ;
        }
        
        //Insert priceBook record
        priceBooksList =TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBooksList.isEmpty()){
            insert priceBooksList ;
        }
        
        //Insert opportunity record
        opportunityList =TestCPQUtilityClass.createOpportunities(accountList ,2);
        for(integer i=0;i<opportunityList.size();i++){
            opportunityList[i].Pricebook2Id=priceBooksList[0].id;
        }
        if(!opportunityList.isEmpty()){
            insert opportunityList;    
        }
         Rubik_Product_Code_Quote_Contacts__c rebukProdCode = new Rubik_Product_Code_Quote_Contacts__c(Name='Automation and Workflow',Product_Code__c='PROD-APPS-AUTOWKFL');
        insert rebukProdCode ;
        
        //Insert products record
        productsToInsertList =TestCPQUtilityClass.createCustomProducts(1);
        
        for(Product2 pd :productsToInsertList){
           // pd.productcode=rebukProdCode.Product_Code__c;
        }
        productsToInsertList[0].productcode=rebukProdCode.Product_Code__c;
        if(!productsToInsertList.isEmpty()){
            insert productsToInsertList;    
        }
        
        id pbId = Test.getStandardPricebookId();
        TestCPQUtilityClass.createStdPricebookEntries(productsToInsertList,pbid);
        
        //Insert priceBookEntry record
        priceBookEntryList =TestCPQUtilityClass.createPriceBookEntries(productsToInsertList ,priceBooksList );
        if(!priceBookEntryList.isEmpty()){
            insert priceBookEntryList ;
        }
        
        //Insert OpptyProduct_ARR_Calculation_Setting__c record
        OpptyProduct_ARR_Calculation_Setting__c opcs = new OpptyProduct_ARR_Calculation_Setting__c();
        opcs.Name='Test OpptyProduct';
        opcs.Opportunity_Id__c=opportunityList[1].Id;
        opcs.Opportunity_Name__c=opportunityList[0].name;
        insert opcs;
       
        // Insert Opportunity Products
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opportunityList[0].Id, PricebookEntryId = priceBookEntryList [0].Id, UnitPrice = 10, Quantity = 20);
        opportunityLineItemsList.add(oli);
        
        //Insert OpportunityLineItem record 
        if(!opportunityLineItemsList.isEmpty()){
            insert opportunityLineItemsList;
        }
        system.debug('opportunityLineItemsList============='+opportunityLineItemsList);
        
        
        /*opportunityLineItemsList=TestCPQUtilityClass.createOppLineItems(opportunityList ,priceBookEntryList );
        system.debug(opportunityLineItemsList);
        insert opportunityLineItemsList;*/
        //test.startTest();
        //Insert rubic quote
         SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__Primary__c=True,
                                                   SBQQ__ShippingCountry__c='Australia',Rubiks_Quote__c=true, SBQQ__Opportunity2__c=opportunityList[0].Id,SBQQ__Account__c= opportunityList[0].accountId,SBQQ__StartDate__c=date.today());   
        insert quote;
        test.startTest();
        // Insert Quote Lines
        List<SBQQ__Quote__c> quotesToPassList=new List<SBQQ__Quote__c>();
        quotesToPassList.add(quote);
        List<SBQQ__QuoteLine__c> quoteLines=TestCPQUtilityClass.createQuoteLines(quotesToPassList,1,productsToInsertList);
        
        insert quoteLines;
        
        update quoteLines;
         
        test.stopTest();
        
    }//End of testmethod testMaxDbSizeForSolutionOppty
}