@isTest
public class Button_AssetAutoProvisioning_Test{
    public static testMethod void button_AssetAutoProvision(){
        List<Account> accntList = new List<Account>();
        accntList = TestCPQUtilityClass.createAccounts(1);
        if(!accntList.isEmpty()){
            insert accntList;
        }
        
        List<Contract> contractList= new List<Contract>();
        contractList=TestCPQUtilityClass.createContracts(accntList,1);
        if(!contractList.isEmpty()){
            insert contractList;
        }
        
        List<Contact> contactList = new List<Contact>();
        contactList = TestCPQUtilityClass.createContacts(accntList,1);
        if(!contactList.isEmpty()){
            insert contactList;
        }
        
        // Create Products
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].ProductCode = 'INST';
        prodList[1].ProductCode = 'LM-SAND';
        prodList[2].ProductCode = 'Sales Insight';
        prodList[3].ProductCode = 'Outlook plug-in';
        
        // Below product is used in Subscription
        prodList[4].ProductCode = 'PROD-APPS-ADVREP';
        //prodList[5].ProductCode = 'Outlook plug-in';
    
        if(!prodList.isEmpty()){
            insert prodList;
        }
        
       list<AssetProductFamilyAutoProvisioning__c> insertAssetCustomsetting = new list<AssetProductFamilyAutoProvisioning__c>();
       set<string> uniqCode = new set<string>();
        for(Product2 prod :prodList){   
            if(!uniqCode.contains(prod.ProductCode)){ 
                AssetProductFamilyAutoProvisioning__c  AssetproductSales   = new AssetProductFamilyAutoProvisioning__c(name= prod.ProductCode,Product_Code__c=prod.ProductCode);
                insertAssetCustomsetting.add(AssetproductSales);
                uniqCode.add(prod.ProductCode);
            }
        }
     
      insert insertAssetCustomsetting;
      
        // Create Custom Pricebooks
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }
        
        // Insert data for custom setting - SteelBrickCPQPricebook__c
        SteelBrickCPQPricebook__c obj = new SteelBrickCPQPricebook__c();
        obj.Name = 'SteelBrick PB';
        obj.ID__c = priceBookList[0].Id;
        insert obj;
        
        // Get Id of Standard Pricebook
        Id stdPbId = Test.getStandardPricebookId();
        
        // Insert Products into Standard Pricebook
        List<PriceBookEntry> pbEntryStdPbList = new List<PriceBookEntry>();
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }
        
        // Insert Products into Custom Pricebooks
        List<PriceBookEntry> pbEntryList = new List<PriceBookEntry>();
        pbEntryList = TestCPQUtilityClass.createPriceBookEntries(prodList, priceBookList);
        if(!pbEntryList.isEmpty()){
            insert pbEntryList;
        }
          
        // Create Opportunities with stage Closed Won
        List<Opportunity> oppotyList = new List<Opportunity>();
        oppotyList = TestCPQUtilityClass.createOpportunities(accntList, 1);
        oppotyList[0].StageName = 'Prospecting';
        oppotyList[0].PriceBook2Id = priceBookList[0].id;
        oppotyList[0].Quarterly_Renewal__c = string.valueof(2);
        oppotyList[0].Sub_End_Date__c = System.Today().addMonths(1);
        oppotyList[0].Rep_Create_ARR__c = 1;
        insert oppotyList;
        
        List<OpportunityLineItem> oppotyLineItemList = new List<OpportunityLineItem>();
        List<OpportunityLineItem> newoppotyLineItemList = new List<OpportunityLineItem>();
        oppotyLineItemList = TestCPQUtilityClass.createOppLineItems(oppotyList,pbEntryList);
       integer quantity= 1;
       for(OpportunityLineItem oli:oppotyLineItemList){
           oli.Users__c = 2;
           
           oli.quantity  = quantity;
           newoppotyLineItemList.add(oli);
           quantity++;
       }
     
       insert oppotyLineItemList;
       
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        // Create Quote and Quote Line - Put Quote Line on Asset
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        quoteList = TestCPQUtilityClass.createSimpleQuote(oppotyList,1);
        //quoteList[0].SBQQ__Primary__c = true;
        insert quoteList;
        Test.startTest();
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        quoteLineList = TestCPQUtilityClass.createQuoteLines(quoteList,5,prodList);
        integer countQLI=0;
        for(SBQQ__QuoteLine__c qli : quoteLineList){
           qli.SBQQ__Product__c = prodList[countQLI].id;
           countQLI++;
        }
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        if(!quoteLineList.isEmpty()){
            insert quoteLineList;
        }
    
        integer countAsset=0;
        list<Asset> assetList = new list<Asset>();    
        for(Product2  ProdId  : prodList){
                Asset as1 = new Asset();
                as1.Name = 'Test Asset '+countAsset;
                as1.installdate = System.today();
                as1.UsageEndDate = System.today().addMonths(2);
                as1.Opportunity__c = oppotyList[0].Id;
                as1.Asset_Type__c='Instance';
                as1.purpose__c='Production';
                as1.Product2Id=ProdId.id;
                as1.AccountId = accntList[0].Id;
                as1.ContactId = contactList[0].Id;
                as1.Provision_Status__c = 'New';
                as1.SBQQ__QuoteLine__c = quoteLineList[0].Id;
                as1.Purpose__c = 'Rubiks Production';
                as1.Contract__c=contractList[0].Id;
            countAsset++;
            assetList.add(as1);
        }
        
        assetList[1].Purpose__c = 'Sandbox';
    
        if(!assetList.isEmpty()){
            insert assetList;     
        }
        
        List<Case> caseList = TestCPQUtilityClass.createCases(oppotyList,1);
        system.assertEquals(caseList.size(), 1);
        if(!caseList.isempty()){
          insert caseList;  
        }
        system.assertEquals(caseList.size(), 1);
        Test.stopTest();
        Button_AssetAutoProvisioning.callAssetAutoProvisioning(assetList[0].id);
        Button_AssetAutoProvisioning.callCaseAutoProvisioning(caseList[0].id);
    }//End of test Method
}