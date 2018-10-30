@isTest
private class Asset_Rubik_Test {
    
    

    static testMethod void testRubixAssetClass(){
        //Need Account
        //Need Contact
        //Need Opp
        //Need Products and Pricebooks
        //Need Quote
        //Need Quote Lines
        //Need Child Quote Lines
        //Need Contract and Subscriptions
        //Lastly Need Assets
         List<Account> accntList = new List<Account>();
        accntList = TestCPQUtilityClass.createAccounts(1);
        if(!accntList.isEmpty()){
            insert accntList;
        }
        
        List<Contact> contactList = new List<Contact>();
        contactList = TestCPQUtilityClass.createContacts(accntList,1);
        if(!contactList.isEmpty()){
            insert contactList;
        }
        
        // Create Products
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(3);
        prodList[0].ProductCode ='PARENT';// 'BNDL-ENT-MKTGAUTO';

        prodList[1].ProductCode = 'PROD-APPS-INST';
        prodList[2].ProductCode = 'PROD-PLAT-SANDBOX-INST';
        //prodList[0].ProductCode='INST';
        for(Product2 pd: prodList){
            pd.Product_Type__c         ='Services';
            pd.Family                  ='Services';
            pd.Product_SubFamily__c    = 'Launch Pack';
            pd.Product_SubFamily2__c   = 'Launch Pack Core';

        }

        prodList[0].Family ='Bundle';
        
        if(!prodList.isEmpty()){
            insert prodList;
        }
        
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
        oppotyList                         = TestCPQUtilityClass.createOpportunities(accntList, 1);
        oppotyList[0].StageName            = 'Prospecting';
        oppotyList[0].PriceBook2Id         = priceBookList[0].id;
        oppotyList[0].Quarterly_Renewal__c = string.valueof(2);
        oppotyList[0].Sub_End_Date__c      = System.Today().addMonths(1);
        oppotyList[0].type                 = 'New Business';
        oppotyList[0].Deal_Type__c         = 'Standard';
        oppotyList[0].Rep_Create_ARR__c    = 1;
        insert oppotyList;
       
         SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
         List<SBQQ__Quote__c> quotList = TestCPQUtilityClass.createQuotes(oppotyList,  1);
         List<SBQQ__Quote__c> InsertquotList = new List<SBQQ__Quote__c>();
          for(SBQQ__Quote__c quote : quotList){
              quote.SBQQ__Primary__c = true;
              InsertquotList.add(quote);
          }
          insert InsertquotList;

          //Create QuoteLine Parent
          List<Product2> prodListParent = new List<Product2>();
          prodListParent.add(prodList.get(0));

          system.debug(prodList.get(0));

          //List<SBQQ__QuoteLine__c> InsertquoteLineList= TestCPQUtilityClass.createQuoteLinesForQuote( InsertquotList[0],prodListParent );
          //insert InsertquoteLineList;
 
          List<SBQQ__QuoteLine__c> quoteLinesToInsertParent = new List<SBQQ__QuoteLine__c>();
          //SBQQ__RequiredBy__c=InsertquoteLineList.get(0).id,
          SBQQ__QuoteLine__c quoteLine3 = new SBQQ__QuoteLine__c( SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[0].id);
          quoteLinesToInsertParent.add(quoteLine3);
          insert quoteLinesToInsertParent;
 Test.StartTest();
          List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
          system.debug(quoteLine3.id);
          SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[1].id);
          SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[2].id);
          quoteLinesToInsert.add(quoteLine);
          quoteLinesToInsert.add(quoteLine2);
          insert quoteLinesToInsert;

          // Create Contract
        Contract contrct = new Contract(Name='Test Contract ', AccountId=oppotyList[0].AccountId, SBQQ__Opportunity__c =oppotyList[0].Id, ContractTerm = 12, SBQQ__RenewalForecast__c = true, SBQQ__PreserveBundleStructureUponRenewals__c = true, SBQQ__DefaultRenewalContactRoles__c = true, SBQQ__DefaultRenewalPartners__c = true, StartDate=System.today());
        insert contrct;   
          
         //Insert Subscriptions
         List<SBQQ__Subscription__c> subs=new List<SBQQ__Subscription__c>();
         subs.add(new SBQQ__Subscription__c(SBQQ__Quantity__c=1, SBQQ__Account__c=accntList.get(0).id, SBQQ__Contract__c=contrct.id, SBQQ__QuoteLine__c=quoteLinesToInsertParent.get(0).id, SBQQ__Product__c=Prodlist[0].id));
         subs.add(new SBQQ__Subscription__c(SBQQ__Quantity__c=7, SBQQ__Account__c=accntList.get(0).id, SBQQ__Contract__c=contrct.id, SBQQ__QuoteLine__c=quoteLinesToInsert.get(0).id, SBQQ__Product__c=Prodlist[1].id));
         subs.add(new SBQQ__Subscription__c(SBQQ__Quantity__c=7, SBQQ__Account__c=accntList.get(0).id, SBQQ__Contract__c=contrct.id, SBQQ__QuoteLine__c=quoteLinesToInsert.get(1).id, SBQQ__Product__c=Prodlist[2].id));
          //List<SBQQ__QuoteLine__c> quoteLinesToInsertParent = new List<SBQQ__QuoteLine__c>();
          insert subs;
          //insert quoteLinesToInsertParent;

          List<Asset> assList=new List<Asset>();
          assList.add(new Asset(AccountId=accntList.get(0).id, Product2Id=Prodlist[1].id,  Contract__c=contrct.id, SBQQ__QuoteLine__c=quoteLinesToInsert.get(0).id, SBQQ__LatestQuoteLine__c=quoteLinesToInsert.get(0).id, Asset_Type__c='Instance'));
          assList.add(new Asset(AccountId=accntList.get(0).id, Product2Id=Prodlist[2].id,  Contract__c=contrct.id, SBQQ__QuoteLine__c=quoteLinesToInsert.get(1).id, SBQQ__LatestQuoteLine__c=quoteLinesToInsert.get(1).id, Asset_Type__c='Instance'));

          insert assList;
        Test.StopTest();

          update assList;
 
    }
    
    @isTest static void test_method_two() {
        // Implement test code
    }
    
}