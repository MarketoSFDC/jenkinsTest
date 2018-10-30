@isTest
public class AssetAutoProvisioningTest {
    
    public static testMethod void insertCustSetRecords(){
        List<Product_SKU_Engineering_Code__c> custSetRecordsList = new List<Product_SKU_Engineering_Code__c>();
        
        // Create custSetRecords
        Product_SKU_Engineering_Code__c  custSetRec1 = new Product_SKU_Engineering_Code__c();
        custSetRec1.Name = 'custSetRec1';
        custSetRec1.Engineering_Code__c = 'accountBasedMarketing';
        custSetRec1.Product_Code__c = 'EDU-TRN-RTP-ADMIN';
        custSetRecordsList.add(custSetRec1);
        
        Product_SKU_Engineering_Code__c  custSetRec2 = new Product_SKU_Engineering_Code__c();
        custSetRec2.Name = 'custSetRec2';
        custSetRec2.Engineering_Code__c = 'emailPlugin';
        custSetRec2.Product_Code__c = 'PROD-APPS-EMAILPLUGIN';
        custSetRecordsList.add(custSetRec2);
        
        Product_SKU_Engineering_Code__c  custSetRec3 = new Product_SKU_Engineering_Code__c();
        custSetRec3.Name = 'custSetRec3';
        custSetRec3.Engineering_Code__c = 'advancedReportBuilder';
        custSetRec3.Product_Code__c = 'PROD-APPS-ADVREP';
        custSetRecordsList.add(custSetRec3);
        
        Product_SKU_Engineering_Code__c  custSetRec4 = new Product_SKU_Engineering_Code__c();
        custSetRec4.Name = 'custSetRec4';
        custSetRec4.Engineering_Code__c = 'websiteRetargeting';
        custSetRec4.Product_Code__c = 'LM-SAND';
        custSetRecordsList.add(custSetRec4);
        
         Product_SKU_Engineering_Code__c  custSetRec5 = new Product_SKU_Engineering_Code__c();
        custSetRec5.Name = 'custSetRec5';
        custSetRec5.Engineering_Code__c = 'websiteRetargeting';
        custSetRec5.Product_Code__c = 'Sales Insight';
        custSetRecordsList.add(custSetRec5);
        
         Product_SKU_Engineering_Code__c  custSetRec6 = new Product_SKU_Engineering_Code__c();
        custSetRec6.Name = 'custSetRec6';
        custSetRec6.Engineering_Code__c = 'websiteRetargeting';
        custSetRec6.Product_Code__c = 'Outlook plug-in';
        custSetRecordsList.add(custSetRec6);
        
        if(!custSetRecordsList.isEmpty()){
            insert custSetRecordsList;
        }   
    }
   
    public static testmethod void  AssetAutoProvisionSpaTest(){
        insertCustSetRecords();
        
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA  = true;
        
       List<Account> accntList = new List<Account>();
        accntList = TestCPQUtilityClass.createAccounts(1);
        if(!accntList.isEmpty()){
            accntList[0].Name='Jade Global Test Account on 15th June 2017-This Name is changed to satiesfy the condition of Name Lenght';
            insert accntList;
        }
        
        List<Contact> contactList = new List<Contact>();
        contactList = TestCPQUtilityClass.createContacts(accntList,1);
        contactList[0].email = 'SPAtestcontact@gmail.com';
        if(!contactList.isEmpty()){
            insert contactList;
        }
        
        // Create Products
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(7);
        prodList[0].ProductCode = 'PROD-PLAT-PARTINST-INST';
        prodList[1].ProductCode = 'LM-SAND';
        prodList[2].ProductCode = 'Sales Insight';
        prodList[3].ProductCode = 'Outlook plug-in';
        // Below product is used in Subscription
        prodList[4].ProductCode = 'PROD-APPS-ADVREP';
        prodList[5].ProductCode = 'PROD-APPS-EMAILPLUGIN';
        prodList[6].ProductCode ='EDU-TRN-RTP-ADMIN';
    
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
      insertAssetCustomsetting[3].ArgLevel__c='Rubiks Production';
     // insertAssetCustomsetting[3].ArgLevel__c='Rubiks Production';
      insert insertAssetCustomsetting;
    //  system.debug('insertAssetCustomsetting'+insertAssetCustomsetting);
      
        // Create Custom Pricebooks
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }
         system.debug('priceBookList'+priceBookList);
        
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
        
        // system.debug('pbEntryList'+pbEntryList);
          
        // Create Opportunities with stage Closed Won
        List<Opportunity> oppotyList = new List<Opportunity>();
        oppotyList = TestCPQUtilityClass.createOpportunities(accntList, 1);
        oppotyList[0].StageName = 'Prospecting';
        oppotyList[0].PriceBook2Id = priceBookList[0].id;
        oppotyList[0].Quarterly_Renewal__c = string.valueof(2);
        oppotyList[0].Sub_End_Date__c = System.Today().addMonths(1);
         oppotyList[0].Primary_Marketo_User_Lookup__c =contactList[0].id;
         oppotyList[0].Rep_Create_ARR__c = 10000;
         oppotyList[0].MainCompetitor__c='Act-On';
        insert oppotyList;
        // system.debug('oppotyList'+oppotyList);
        
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
       //system.debug('oppotyLineItemList'+oppotyLineItemList);
    // Create Quote and Quote Line - Put Quote Line on Asset
    List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
    quoteList = TestCPQUtilityClass.createSimpleQuote(oppotyList,1);
    quoteList[0].MDQ_Quote__c=false;
    //quoteList[0].SBQQ__Primary__c = true;
    insert quoteList;
    system.debug('quoteList'+quoteList);
     test.startTest();
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA  = true;
        
    List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
    quoteLineList = TestCPQUtilityClass.createQuoteLines(quoteList,7,prodList);
   
    integer countQLI=0;
    for(SBQQ__QuoteLine__c qli : quoteLineList){
            
           qli.SBQQ__Product__c = prodList[countQLI].id;
           countQLI++;
    }
        if(!quoteLineList.isEmpty()){
            insert quoteLineList;
        }
        
        
        
         if(!quoteLineList.isEmpty()){
                
            quoteLineList[1].SBQQ__RequiredBy__c=quoteLineList[0].Id;
            quoteLineList[2].SBQQ__RequiredBy__c=quoteLineList[0].Id;
            quoteLineList[3].SBQQ__RequiredBy__c=quoteLineList[0].Id;
            quoteLineList[4].SBQQ__RequiredBy__c=quoteLineList[0].Id;
            quoteLineList[5].SBQQ__RequiredBy__c=quoteLineList[0].Id;
            quoteLineList[6].SBQQ__RequiredBy__c=quoteLineList[0].Id;
            
            update quoteLineList;
            
        }
        
    List<Contract>  insertCotractList = TestCPQUtilityClass.createContracts(accntList,1);
        insert insertCotractList;
      integer countAsset=0;
      list<Asset> assetList = new list<Asset>();    
        for(Product2  ProdId  : prodList){
                Asset as1 = new Asset();
                as1.Name = 'Test Asset '+countAsset;
                as1.installdate = System.today();
                as1.UsageEndDate = System.today().addMonths(2);
                as1.Opportunity__c = oppotyList[0].Id;
                as1.Asset_Type__c='Instance';
               // as1.purpose__c='Production';
                as1.Product2Id=ProdId.id;
                as1.Contract__c =insertCotractList[0].id;
                as1.AccountId = accntList[0].Id;
                as1.ContactId = contactList[0].Id;
                as1.Provision_Status__c = 'New';
                as1.SBQQ__QuoteLine__c = quoteLineList[0].Id;
                as1.Purpose__c = 'Rubiks Production';
            countAsset++;
            assetList.add(as1);
            system.debug('assetList'+assetList);
            
        }
        
        assetList[1].Purpose__c = 'Sandbox';
        assetList[2].Opportunity__c=null;
        assetList[3].ContactId=null;
         
    
        if(!assetList.isEmpty()){
            insert assetList;           
        }
         system.debug('assetList'+assetList);
        //list<asset> assetlist2 = new list<asset>();
        
        assetList[1].Production_Asset__c=assetList[0].Id;
        if(!assetList.isEmpty()){
            update assetList;
        }
         system.debug('assetList'+assetList);
         //test.stopTest();
        // Insert Subscriptions
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c();        
        sub1.SBQQ__Product__c = prodList[4].Id;
        sub1.Production_Asset__c = assetList[0].Id;
        sub1.SBQQ__Account__c = assetList[0].AccountId;
        sub1.SBQQ__QuoteLine__c = assetList[0].SBQQ__QuoteLine__c;
        sub1.SBQQ__Quantity__c = 1.0;
        sub1.SBQQ__Contract__c=insertCotractList[0].id;
        subList.add(sub1);
        
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c();        
        sub2.SBQQ__Product__c = assetList[1].Product2Id;
        sub2.Production_Asset__c = assetList[0].Id;
        sub2.SBQQ__Account__c = assetList[1].AccountId;
        sub2.SBQQ__QuoteLine__c = assetList[1].SBQQ__QuoteLine__c;
        sub2.SBQQ__Quantity__c = 2.0;
        sub2.SBQQ__Contract__c=insertCotractList[0].id;
        subList.add(sub2);    
        
         SBQQ__Subscription__c sub4 = new SBQQ__Subscription__c();        
        sub4.SBQQ__Product__c = assetList[2].Product2Id;
        sub4.Production_Asset__c = assetList[2].Id;
        sub4.SBQQ__Account__c = assetList[2].AccountId;
        sub4.SBQQ__QuoteLine__c = assetList[2].SBQQ__QuoteLine__c;
        sub4.SBQQ__Quantity__c = 2.0;
        sub4.SBQQ__Contract__c=insertCotractList[0].id;
         subList.add(sub4);
        
         SBQQ__Subscription__c sub5 = new SBQQ__Subscription__c();        
        sub5.SBQQ__Product__c = assetList[3].Product2Id;
        sub5.Production_Asset__c = assetList[3].Id;
        sub5.SBQQ__Account__c = assetList[3].AccountId;
        sub5.SBQQ__QuoteLine__c = assetList[3].SBQQ__QuoteLine__c;
        sub5.SBQQ__Quantity__c = 2.0;
        sub5.SBQQ__Contract__c=insertCotractList[0].id;
         subList.add(sub5);
         
          system.debug('subList'+subList);
        
        
        if(!subList.isEmpty()){
            insert subList;
        }
        
        AssetAutoProvisioning.processAssets();
        test.stopTest();
    }
   /* 
    public static testmethod void  AssetAutoProvisionSpaWithMendatoryFieldTest(){
        insertCustSetRecords();
       List<Account> accntList = new List<Account>();
        accntList = TestCPQUtilityClass.createAccounts(1);
        if(!accntList.isEmpty()){
            accntList[0].Name='Jade Global Test Account on 15th June 2017-This Name is changed to satiesfy the condition of Name Lenght';
            insert accntList;
        }
        
        List<Contact> contactList = new List<Contact>();
        contactList = TestCPQUtilityClass.createContacts(accntList,1);
        contactList[0].email = 'SPAtestcontact@gmail.com';
        
        if(!contactList.isEmpty()){
            insert contactList;
        }
        
        // Create Products
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(7);
        prodList[0].ProductCode = 'PROD-PLAT-PARTINST-INST';
        prodList[1].ProductCode = 'LM-SAND';
        prodList[2].ProductCode = 'Sales Insight';
        prodList[3].ProductCode = 'Outlook plug-in';
        // Below product is used in Subscription
        prodList[4].ProductCode = 'PROD-APPS-ADVREP';
        prodList[5].ProductCode = 'PROD-APPS-EMAILPLUGIN';
        prodList[6].ProductCode ='EDU-TRN-RTP-ADMIN';
    
        if(!prodList.isEmpty()){
            insert prodList;
        }
        
       list<AssetProductFamilyAutoProvisioning__c> insertAssetCustomsetting = new list<AssetProductFamilyAutoProvisioning__c>();
       set<string> uniqCode = new set<string>();
      for(Product2 prod :prodList){   
        if(!uniqCode.contains(prod.ProductCode)){ 
             AssetProductFamilyAutoProvisioning__c  AssetproductSales   = new AssetProductFamilyAutoProvisioning__c(name= prod.ProductCode,Product_Code__c=prod.ProductCode,ArgLevel__c=prod.ProductCode);
             insertAssetCustomsetting.add(AssetproductSales);
             uniqCode.add(prod.ProductCode);
        }
      }
     
      insert insertAssetCustomsetting;
    //  system.debug('insertAssetCustomsetting'+insertAssetCustomsetting);
      
        // Create Custom Pricebooks
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }
         system.debug('priceBookList'+priceBookList);
        
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
        
        // system.debug('pbEntryList'+pbEntryList);
          
        // Create Opportunities with stage Closed Won
        List<Opportunity> oppotyList = new List<Opportunity>();
        oppotyList = TestCPQUtilityClass.createOpportunities(accntList, 1);
        oppotyList[0].StageName = 'Prospecting';
        oppotyList[0].PriceBook2Id = priceBookList[0].id;
        oppotyList[0].Quarterly_Renewal__c = string.valueof(2);
        oppotyList[0].Sub_End_Date__c = System.Today().addMonths(1);
         oppotyList[0].Primary_Marketo_User_Lookup__c =contactList[0].id;
         oppotyList[0].Rep_Create_ARR__c = 10000;
         oppotyList[0].MainCompetitor__c='Act-On';
        insert oppotyList;
        // system.debug('oppotyList'+oppotyList);
        
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
       //system.debug('oppotyLineItemList'+oppotyLineItemList);
    // Create Quote and Quote Line - Put Quote Line on Asset
    List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
    quoteList = TestCPQUtilityClass.createSimpleQuote(oppotyList,1);
    quoteList[0].MDQ_Quote__c=false;
    //quoteList[0].SBQQ__Primary__c = true;
    insert quoteList;
    system.debug('quoteList'+quoteList);
     test.startTest();
    List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
    quoteLineList = TestCPQUtilityClass.createQuoteLines(quoteList,7,prodList);
   
    integer countQLI=0;
    for(SBQQ__QuoteLine__c qli : quoteLineList){
            
           qli.SBQQ__Product__c = prodList[countQLI].id;
           countQLI++;
    }
        if(!quoteLineList.isEmpty()){
            insert quoteLineList;
        }
        
        
        
         if(!quoteLineList.isEmpty()){
                
            quoteLineList[1].SBQQ__RequiredBy__c=quoteLineList[0].Id;
            quoteLineList[2].SBQQ__RequiredBy__c=quoteLineList[0].Id;
            quoteLineList[3].SBQQ__RequiredBy__c=quoteLineList[0].Id;
            quoteLineList[4].SBQQ__RequiredBy__c=quoteLineList[0].Id;
            quoteLineList[5].SBQQ__RequiredBy__c=quoteLineList[0].Id;
            quoteLineList[6].SBQQ__RequiredBy__c=quoteLineList[0].Id;
            
            update quoteLineList;
            
        }
        
    List<Contract>  insertCotractList = TestCPQUtilityClass.createContracts(accntList,1);
        insert insertCotractList;
      integer countAsset=0;
      list<Asset> assetList = new list<Asset>();    
        for(Product2  ProdId  : prodList){
                Asset as1 = new Asset();
                as1.Name = 'Test Asset '+countAsset;
                as1.installdate = System.today();
                as1.UsageEndDate = System.today().addMonths(2);
                as1.Opportunity__c = oppotyList[0].Id;
                as1.Asset_Type__c='Instance';
               // as1.purpose__c='Production';
                as1.Product2Id=ProdId.id;
                as1.Contract__c =insertCotractList[0].id;
                as1.AccountId = accntList[0].Id;
                as1.ContactId = contactList[0].Id;
                as1.Provision_Status__c = 'New';
                as1.SBQQ__QuoteLine__c = quoteLineList[0].Id;
                as1.Purpose__c = 'Rubiks Production';
            countAsset++;
            assetList.add(as1);
            system.debug('assetList'+assetList);
            
        }
        
        assetList[1].Purpose__c = 'Sandbox';
        assetList[2].Opportunity__c=null;
        assetList[3].ContactId=null;
         
    
        if(!assetList.isEmpty()){
            insert assetList;           
        }
         system.debug('assetList'+assetList);
        //list<asset> assetlist2 = new list<asset>();
        
        assetList[1].Production_Asset__c=assetList[0].Id;
        if(!assetList.isEmpty()){
            update assetList;
        }
         system.debug('assetList'+assetList);
         test.stopTest();
        // Insert Subscriptions
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c();        
        sub1.SBQQ__Product__c = prodList[4].Id;
        sub1.Production_Asset__c = assetList[0].Id;
        sub1.SBQQ__Account__c = assetList[0].AccountId;
        sub1.SBQQ__QuoteLine__c = assetList[0].SBQQ__QuoteLine__c;
        sub1.SBQQ__Quantity__c = 1.0;
        sub1.SBQQ__Contract__c=insertCotractList[0].id;
        subList.add(sub1);
        
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c();        
        sub2.SBQQ__Product__c = assetList[1].Product2Id;
        sub2.Production_Asset__c = assetList[0].Id;
        sub2.SBQQ__Account__c = assetList[1].AccountId;
        sub2.SBQQ__QuoteLine__c = assetList[1].SBQQ__QuoteLine__c;
        sub2.SBQQ__Quantity__c = 2.0;
        sub2.SBQQ__Contract__c=insertCotractList[0].id;
        subList.add(sub2);    
        
         SBQQ__Subscription__c sub4 = new SBQQ__Subscription__c();        
        sub4.SBQQ__Product__c = assetList[2].Product2Id;
        sub4.Production_Asset__c = assetList[2].Id;
        sub4.SBQQ__Account__c = assetList[2].AccountId;
        sub4.SBQQ__QuoteLine__c = assetList[2].SBQQ__QuoteLine__c;
        sub4.SBQQ__Quantity__c = 2.0;
        sub4.SBQQ__Contract__c=insertCotractList[0].id;
         subList.add(sub4);
        
         SBQQ__Subscription__c sub5 = new SBQQ__Subscription__c();        
        sub5.SBQQ__Product__c = assetList[3].Product2Id;
        sub5.Production_Asset__c = assetList[3].Id;
        sub5.SBQQ__Account__c = assetList[3].AccountId;
        sub5.SBQQ__QuoteLine__c = assetList[3].SBQQ__QuoteLine__c;
        sub5.SBQQ__Quantity__c = 2.0;
        sub5.SBQQ__Contract__c=insertCotractList[0].id;
         subList.add(sub5);
         
          system.debug('subList'+subList);
        
            
        
        if(!subList.isEmpty()){
            insert subList;
        }
        
        AssetAutoProvisioning.processAssets();
        //test.stopTest();
    }//End of method AssetAutoProvisionSpaWithMendatoryFieldTest
    */
    
     public static testmethod void AssetAutoProvisionTestforPhoenix2(){
        insertCustSetRecords();
        
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA  = true;
        
        Marketo_Trigger_Management__c MKTOTrigger = Marketo_Trigger_Management__c.getOrgDefaults();
        MKTOTrigger.Deactivate_Subscription_Triggers__c = true;
        upsert MKTOTrigger;// Marketo_Trigger_Management__c.Id;
        system.assertEquals(True,MKTOTrigger.Deactivate_Subscription_Triggers__c);
         List<Account> accntList = new List<Account>();
        accntList = TestCPQUtilityClass.createAccounts(1);
        if(!accntList.isEmpty()){
            accntList[0].Name='Jade Global Test Account on 15th June 2017-This Name is changed to satiesfy the condition of Name Lenght';
            insert accntList;
        }
        
        List<Account> acc = new List<Account>();
        acc = [select Id from Account];
        
        Id accId = acc[0].Id;
        
        List<Contact> contactList = new List<Contact>();
        contactList = TestCPQUtilityClass.createContacts(accntList,1);
        contactList[0].email = 'SPAtestcontact@gmail.com';
        if(!contactList.isEmpty()){
            insert contactList;
        }
        
        // Create Products
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(5);
    
        prodList[0].ProductCode = 'Outlook plug-in';    
        prodList[1].ProductCode = 'SUP-BASE-PREM';
        prodList[2].ProductCode = 'PROD-APPS-INST';
        prodList[3].ProductCode = 'PROD-PLAT-SANDBOX-INST';
        prodList[4].ProductCode = 'Sales Insight'; 
      
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
     insertAssetCustomsetting[0].ArgLevel__c='Marketo - Lite';
     insertAssetCustomsetting[1].ArgLevel__c='Marketo - Lite';
     insertAssetCustomsetting[2].ArgLevel__c='Rubiks Production';
     insertAssetCustomsetting[3].ArgLevel__c='Rubiks Sandbox';
     insertAssetCustomsetting[4].ArgLevel__c='Marketo - Lite';
      insert insertAssetCustomsetting;
      
      system.assertEquals('Rubiks Production',AssetProductFamilyAutoProvisioning__c.getInstance('PROD-APPS-INST').ArgLevel__c);
      
      system.assertEquals('Outlook plug-in',AssetProductFamilyAutoProvisioning__c.getInstance('Outlook plug-in').Product_Code__c);
      
    //  system.debug('insertAssetCustomsetting'+insertAssetCustomsetting);
        // Create Custom Pricebooks
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        priceBookList[0].Name = 'Enterprise Price Book v2018';
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }
         system.debug('priceBookList'+priceBookList);
        
        // Insert data for custom setting - SteelBrickCPQPricebook__c
        SteelBrickCPQPricebook__c obj = new SteelBrickCPQPricebook__c();
        obj.Name = 'SteelBrick PB';
        obj.ID__c = priceBookList[0].Id;
        obj.Phoenix_Price_Books__c = priceBookList[0].Id;
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
        
        // system.debug('pbEntryList'+pbEntryList);
                
        // Create Opportunities with stage Closed Won
        List<Opportunity> oppotyList = new List<Opportunity>();
        oppotyList = TestCPQUtilityClass.createOpportunities(accntList, 1);
        oppotyList[0].StageName = 'Prospecting';
        oppotyList[0].PriceBook2Id = priceBookList[0].id;
        oppotyList[0].Quarterly_Renewal__c = string.valueof(2);
        oppotyList[0].Sub_End_Date__c = System.Today().addMonths(1);
        oppotyList[0].Primary_Marketo_User_Lookup__c =contactList[0].id;
        oppotyList[0].Rep_Create_ARR__c = 10000;
        oppotyList[0].MainCompetitor__c='Act-On';
        oppotyList[0].Type = 'New Business';
        
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        
        insert oppotyList;
        // system.debug('oppotyList'+oppotyList);
        
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
    
        List<Opportunity> oppList =  new List<Opportunity>();
        oppList = [select Id , SBQQ__Contracted__c from Opportunity where AccountId =: accntList[0].Id];
        //system.assertEquals(oppList.size(),1);
    
         // Create Quote and Quote Line - Put Quote Line on Asset
    List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
    quoteList = TestCPQUtilityClass.createSimpleQuote(oppotyList,1);
    quoteList[0].MDQ_Quote__c=false;
    quoteList[0].Show_All_Bundles__c = True;
    quoteList[0].SBQQ__Account__c = accntList[0].Id;
    quoteList[0].SBQQ__Opportunity2__c = oppList[0].Id;
    quoteList[0].SBQQ__Primary__c = true;
    quoteList[0].Acct_Prefix_Requested__c = 'TestAcctPrefixhjkl';
    insert quoteList;
            
  //  system.debug('quoteList'+quoteList);
        
         List<OpportunityLineItem> oppotyLineItemList = new List<OpportunityLineItem>();
      //   List<OpportunityLineItem> newoppotyLineItemList = new List<OpportunityLineItem>();
       oppotyLineItemList = TestCPQUtilityClass.createOppLineItems(oppotyList,pbEntryList);
       integer quantity= 1;
       for(OpportunityLineItem oli:oppotyLineItemList){
           oli.Users__c = 2;
           
           oli.quantity  = quantity;
         //  newoppotyLineItemList.add(oli);
           quantity++;
       }
     
       insert oppotyLineItemList;
    
    List<SBQQ__Quote__c> retrieveQuoteList = new List<SBQQ__Quote__c>();
    retrieveQuoteList = [select Id, SBQQ__Opportunity2__c from SBQQ__Quote__c where SBQQ__Opportunity2__c =: oppList[0].Id ];
     
    List<SBQQ__QuoteLineGroup__c> QuoteLineGrpList = new List<SBQQ__QuoteLineGroup__c>();
    QuoteLineGrpList = TestCPQUtilityClass.createQuoteLineGroup(quoteList, 2);
    QuoteLineGrpList[0].Contact_Database_Size__c = 1234;
    QuoteLineGrpList[0].Contact_Database_Size__c = 10234;
     
        insert QuoteLineGrpList;
    
    List<SBQQ__QuoteLineGroup__c> retrieveQuoteLineGrp = [select Id ,Name, SBQQ__Quote__c from SBQQ__QuoteLineGroup__c where SBQQ__Quote__c=:retrieveQuoteList[0].Id];
    
        for(SBQQ__Quote__c quote :retrieveQuoteList){
            quote.SBQQ__LineItemsGrouped__c = True;
            quote.Ship_To_Contact__c  =null;
        }
       update retrieveQuoteList;
       
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
    quoteLineList = TestCPQUtilityClass.createQuoteLines(retrieveQuoteList,5,prodList);
     
    integer countQLI=0;
    for(SBQQ__QuoteLine__c qli : quoteLineList){
           qli.SBQQ__Product__c = prodList[countQLI].id;
           qli.SBQQ__Quote__c = retrieveQuoteList[0].Id;
           countQLI++;
    }
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
      
        test.startTest();
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA  = true;
        
        if(!quoteLineList.isEmpty()){
            quoteLineList[0].SBQQ__Group__c = retrieveQuoteLineGrp[0].Id;
            quoteLineList[1].SBQQ__Group__c = retrieveQuoteLineGrp[0].Id;
            quoteLineList[2].SBQQ__Group__c = retrieveQuoteLineGrp[1].Id;
            quoteLineList[3].SBQQ__Group__c = retrieveQuoteLineGrp[1].Id;
            quoteLineList[4].SBQQ__Group__c = retrieveQuoteLineGrp[1].Id;
            insert quoteLineList;
        }
        
        for(Opportunity opp :oppotyList){
                opp.Needs_Pains__c = 'Test Pain';
                opp.Subscription_Language__c = 'English';
                opp.Subscription_Locale__c = 'English-United States';
                opp.Subscription_Time_Zone__c = 'Afghanistan Time (Asia/Kabul)';
                opp.Use_Case__c = 'B2B';
                opp.StageName = 'Signed Order';
                opp.Compelling_Event__c = 'Test Compelling_Event__c';
        }
        update oppotyList;
        for(Opportunity opp :oppotyList){
                opp.Data_Center__c = 'US';
                opp.StageName = 'Closed Won';
                
        }
        oppotyList[0].SBQQ__Contracted__c = True;
        
        update oppotyList;
   
        List<Contract>  insertCotractList = TestCPQUtilityClass.createContracts(accntList,1);
        insertCotractList[0].SBQQ__Quote__c = retrieveQuoteList[0].Id;
        insertCotractList[0].SBQQ__Opportunity__c = oppotyList[0].Id;
        //insertCotractList[0].
        insert insertCotractList;
      
      Utility.isAssetTriggerExecutedFromOppty  = true;
      integer countAsset=0;
      
      RecordType rt = [SELECT Id,Name FROM RecordType WHERE SobjectType='Asset' and Name like '%CPQ Instance Asset%' LIMIT 1];
      
      List<SBQQ__QuoteLine__c> quoteLineListRetrieved = new List<SBQQ__QuoteLine__c>();
      quoteLineListRetrieved = [select Id , SBQQ__Quote__c from SBQQ__QuoteLine__c where SBQQ__Quote__c =:retrieveQuoteList[0].Id ];
      
      system.assertEquals(5,quoteLineListRetrieved.size());
      
      List<Contract> retrieveContract = [select Id,SBQQ__Quote__c from Contract where SBQQ__Quote__c =:retrieveQuoteList[0].Id ];
      system.assertEquals(retrieveContract.size(),1);
      
      list<Asset> assetList = new list<Asset>();    
        for(Product2  ProdId  : prodList){
                Asset as1 = new Asset();
                as1.Name = 'Test Asset '+countAsset;
                as1.installdate = System.today();
                as1.UsageEndDate = System.today().addMonths(2);
                as1.Opportunity__c = oppotyList[0].Id;
                as1.Asset_Type__c='Instance';
                as1.Product2Id=ProdId.id;
                as1.Contract__c =retrieveContract[0].id;
                as1.AccountId = accntList[0].Id;
                as1.ContactId = contactList[0].Id;
                as1.Provision_Status__c = 'New';
                as1.Purpose__c = 'Internal';
                as1.RecordTypeId = rt.Id;
            //  as1.SBQQ__QuoteLine__c = quoteLineListRetrieved[countAsset].Id;
            countAsset++;
            assetList.add(as1);
            system.debug('assetList'+assetList);
            
        }
        
        assetList[0].SBQQ__QuoteLine__c = quoteLineListRetrieved[0].Id;
        assetList[1].SBQQ__QuoteLine__c = quoteLineListRetrieved[1].Id;
        assetList[2].SBQQ__QuoteLine__c = quoteLineListRetrieved[2].Id;
        assetList[3].SBQQ__QuoteLine__c = quoteLineListRetrieved[3].Id;
        assetList[4].SBQQ__QuoteLine__c = quoteLineListRetrieved[4].Id;
        assetList[0].Group_Name__c = retrieveQuoteLineGrp[0].Name;
        assetList[1].Group_Name__c = retrieveQuoteLineGrp[0].Name;
        assetList[2].Purpose__c = 'Rubiks Production';
        assetList[2].Group_Name__c = retrieveQuoteLineGrp[1].Name;
        assetList[3].Group_Name__c = retrieveQuoteLineGrp[1].Name;
        assetList[4].Group_Name__c = retrieveQuoteLineGrp[1].Name;
        assetList[3].Purpose__c='Sandbox';
        assetList[3].Production_Asset__c = assetList[2].Id; 
        assetList[4].Production_Asset__c = assetList[2].Id;
        if(!assetList.isEmpty()){
        
            insert assetList;           
        }
         system.debug('assetList'+assetList);
      /*  
        assetList[1].Production_Asset__c=assetList[0].Id;
        // test.startTest(); 
        if(!assetList.isEmpty()){
            update assetList;
        }
         system.debug('assetList'+assetList);
      */   
         List<Asset> assetRetrieve = [select Id,Name ,Account.Website,AccountId,Account.Name,SBQQ__QuoteLine__c,Product2Id,Product2.ProductCode,Contract__c , Contract__r.SBQQ__Quote__c , Contract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c, SBQQ__QuoteLine__r.SBQQ__Group__c,Opportunity__r.Primary_Marketo_User_Email__c,Opportunity__r.Primary_Marketo_User_Lookup__r.FirstName,Opportunity__r.Primary_Marketo_User_Lookup__r.LastName,Munchkin_ID__c,Purpose__c from Asset where Contract__c=:retrieveContract[0].id];
        Id prodAssetId;
        List<Id> assetIds = new List<Id>();
        for(Asset ast : assetRetrieve){
            assetIds.add(ast.Id);
            if(ast.Purpose__c =='Rubiks Production'){
                prodAssetId = ast.Id;
            }
        }
    
          // Insert Subscriptions
     
        retrieveContract[0].Primary_Asset__c = prodAssetId ;
        update retrieveContract;
        
        //AssetAutoProvisioning.processAssets();
        
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c();        
        sub1.SBQQ__Product__c = assetRetrieve[0].Product2Id;
        sub1.Production_Asset__c = prodAssetId;
        sub1.SBQQ__Account__c = assetRetrieve[0].AccountId;
        sub1.SBQQ__QuoteLine__c = assetRetrieve[0].SBQQ__QuoteLine__c;
        sub1.SBQQ__Quantity__c = 1.0;
        sub1.SBQQ__Contract__c=retrieveContract[0].id;
        //sub1.Subscription_Product_Code__c = ;
    
        subList.add(sub1);
        
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c();        
        sub2.SBQQ__Product__c = assetRetrieve[1].Product2Id;
        sub2.Production_Asset__c = prodAssetId;
        sub2.SBQQ__Account__c = assetRetrieve[0].AccountId;
        sub2.SBQQ__QuoteLine__c = assetRetrieve[0].SBQQ__QuoteLine__c;
        sub2.SBQQ__Quantity__c = 2.0;
        sub2.SBQQ__Contract__c=retrieveContract[0].id;
        
    
        subList.add(sub2);    
        
         SBQQ__Subscription__c sub3 = new SBQQ__Subscription__c();        
        sub3.SBQQ__Product__c = assetRetrieve[2].Product2Id;
        sub3.Production_Asset__c = prodAssetId;
        sub3.SBQQ__Account__c = assetRetrieve[0].AccountId;
        sub3.SBQQ__QuoteLine__c = assetRetrieve[0].SBQQ__QuoteLine__c;
        sub3.SBQQ__Quantity__c = 2.0;
        sub3.SBQQ__Contract__c=retrieveContract[0].id;
    
         subList.add(sub3);
        
         SBQQ__Subscription__c sub4 = new SBQQ__Subscription__c();        
        sub4.SBQQ__Product__c = assetRetrieve[3].Product2Id;
        sub4.Production_Asset__c = prodAssetId;
        sub4.SBQQ__Account__c = assetRetrieve[1].AccountId;
        sub4.SBQQ__QuoteLine__c = assetRetrieve[1].SBQQ__QuoteLine__c;
        sub4.SBQQ__Quantity__c = 2.0;
        sub4.SBQQ__Contract__c=retrieveContract[0].id;
    
         subList.add(sub4);
        
        SBQQ__Subscription__c sub5 = new SBQQ__Subscription__c();        
        sub5.SBQQ__Product__c = assetRetrieve[4].Product2Id;
        sub5.Production_Asset__c = prodAssetId;
        sub5.SBQQ__Account__c = assetRetrieve[1].AccountId;
        sub5.SBQQ__QuoteLine__c = assetRetrieve[1].SBQQ__QuoteLine__c;
        sub5.SBQQ__Quantity__c = 2.0;
        sub5.SBQQ__Contract__c=retrieveContract[0].id;
    
         subList.add(sub5);
        
          system.debug('subList'+subList); 
    
        if(!subList.isEmpty()){
            insert subList;
        }
         AssetAutoProvisioning.processAssets();
         test.stopTest();
    }
    
    
    /*
    
     public static testmethod void  OpptyAccountPrefixFieldTest(){
      
       List<Account> accntList = new List<Account>();
        accntList = TestCPQUtilityClass.createAccounts(1);
        if(!accntList.isEmpty()){
           
            insert accntList;
        }
        
        List<Contact> contactList = new List<Contact>();
        contactList = TestCPQUtilityClass.createContacts(accntList,1);
        contactList[0].email = 'SPAtestcontact@gmail.com';
        
        if(!contactList.isEmpty()){
            insert contactList;
        }
        
        // Create Products 
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(7);
        prodList[0].ProductCode = 'PROD-PLAT-PARTINST-INST';
        prodList[1].ProductCode = 'LM-SAND';
        prodList[2].ProductCode = 'Sales Insight';
        prodList[3].ProductCode = 'Outlook plug-in';
        // Below product is used in Subscription
        prodList[4].ProductCode = 'PROD-APPS-ADVREP';
        prodList[5].ProductCode = 'PROD-APPS-EMAILPLUGIN';
        prodList[6].ProductCode ='EDU-TRN-RTP-ADMIN';
    
        if(!prodList.isEmpty()){
            insert prodList;
        }
        
       list<AssetProductFamilyAutoProvisioning__c> insertAssetCustomsetting = new list<AssetProductFamilyAutoProvisioning__c>();
       set<string> uniqCode = new set<string>();
      for(Product2 prod :prodList){   
        if(!uniqCode.contains(prod.ProductCode)){ 
             AssetProductFamilyAutoProvisioning__c  AssetproductSales   = new AssetProductFamilyAutoProvisioning__c(name= prod.ProductCode,Product_Code__c=prod.ProductCode,ArgLevel__c=prod.ProductCode);
             insertAssetCustomsetting.add(AssetproductSales);
             uniqCode.add(prod.ProductCode);
        }
      }
     
      insert insertAssetCustomsetting;
    //  system.debug('insertAssetCustomsetting'+insertAssetCustomsetting);
      
        // Create Custom Pricebooks
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }
         system.debug('priceBookList'+priceBookList);
        
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
        
        // system.debug('pbEntryList'+pbEntryList);
          
        // Create Opportunities with stage Closed Won
        List<Opportunity> oppotyList = new List<Opportunity>();
        oppotyList = TestCPQUtilityClass.createOpportunities(accntList, 3);
        oppotyList[0].StageName = 'Prospecting';
        oppotyList[0].PriceBook2Id = priceBookList[0].id;
        oppotyList[0].Quarterly_Renewal__c = string.valueof(2);
        oppotyList[0].Sub_End_Date__c = System.Today().addMonths(1);
        oppotyList[0].Primary_Marketo_User_Lookup__c =contactList[0].id;
        oppotyList[0].Rep_Create_ARR__c = 10000;
        oppotyList[0].MainCompetitor__c='Act-On';
        
        
        oppotyList[1].type = Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL;
        oppotyList[1].PriceBook2Id = priceBookList[0].id;
        oppotyList[1].Primary_Marketo_User_Lookup__c =contactList[0].id;
        
        oppotyList[2].type =  Label.OPPORTUNITY_TYPE_RENEWAL;
        oppotyList[2].PriceBook2Id = priceBookList[0].id;
        oppotyList[2].Primary_Marketo_User_Lookup__c =contactList[0].id;
        
        insert oppotyList;
         oppotyList[1].Prior_Opportunity__c = oppotyList[0].id;
         oppotyList[2].Prior_Opportunity__c = oppotyList[0].id;
         
         update oppotyList;
        // system.debug('oppotyList'+oppotyList);
          test.startTest();
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
       //system.debug('oppotyLineItemList'+oppotyLineItemList);
        // Create Quote and Quote Line - Put Quote Line on Asset
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        quoteList = TestCPQUtilityClass.createSimpleQuote(oppotyList,1);
        quoteList[0].MDQ_Quote__c=false;
        quoteList[0].SBQQ__Primary__c = true;
        quoteList[1].SBQQ__Primary__c = true;
        quoteList[1].SBQQ__Type__c = 'Amendment';
        quoteList[2].SBQQ__Primary__c = true;
        insert quoteList;
        system.debug('quoteList'+quoteList);
        
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        quoteLineList = TestCPQUtilityClass.createQuoteLines(quoteList,7,prodList);
       
        integer countQLI=0;
        for(SBQQ__QuoteLine__c qli : quoteLineList){
                
              // qli.SBQQ__Product__c = prodList[countQLI].id;
               //countQLI++;
        }
        if(!quoteLineList.isEmpty()){
            insert quoteLineList;
        }
        
       
        
        
        
    List<Contract>  insertCotractList = TestCPQUtilityClass.createContracts(accntList,1);
        insert insertCotractList;
      integer countAsset=0;
      list<Asset> assetList = new list<Asset>();    
        for(Product2  ProdId  : prodList){
                Asset as1 = new Asset();
                as1.Name = 'Test Asset '+countAsset;
                as1.installdate = System.today();
                as1.UsageEndDate = System.today().addMonths(2);
                as1.Opportunity__c = oppotyList[0].Id;
                as1.Asset_Type__c='Instance';
               // as1.purpose__c='Production';
                as1.Product2Id=ProdId.id;
                as1.Contract__c =insertCotractList[0].id;
                as1.AccountId = accntList[0].Id;
                as1.ContactId = contactList[0].Id;
                as1.Provision_Status__c = 'New';
                as1.SBQQ__QuoteLine__c = quoteLineList[0].Id;
                as1.Purpose__c = 'Rubiks Production';
                as1.Acct_Prefix__c ='test'+ProdId.id;
                as1.SBQQ__QuoteLine__c = quoteLineList[countAsset].id;
            countAsset++;
            assetList.add(as1);
            system.debug('assetList'+assetList);
            
        }
        
        assetList[1].Purpose__c = 'Sandbox';
        assetList[2].Opportunity__c=null;
        assetList[3].ContactId=null;
         
    
        if(!assetList.isEmpty()){
            insert assetList;           
        }
         system.debug('assetList'+assetList);
        //list<asset> assetlist2 = new list<asset>();
        
        assetList[1].Production_Asset__c=assetList[0].Id;
        if(!assetList.isEmpty()){
            update assetList;
        } 
         system.debug('assetList'+assetList);
         
         OpportunityCreateBOFU  controller = new OpportunityCreateBOFU(new ApexPages.StandardController(oppotyList[1]));
         controller.onLoad();
         test.stopTest();
       
        
        
        //test.stopTest();
    }//End of method AssetAutoProvisionSpaWithMendatoryFieldTest*/
}