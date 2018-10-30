/*********************************************************************
* Created by         : Rajesh Wani
* Created Date       : 2nd February 2015
* Purpose            : This class covers method of AssetTriggerHandler class
************************************************************************/
@isTest 
public class AssetTriggerTest{
    /*
    static testMethod void testData(){
        
        test.starttest();
        
        List<Account> accntList = new List<Account>();
        accntList = TestCPQUtilityClass.createAccounts(10);
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
        prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].ProductCode = 'INST';
        if(!prodList.isEmpty()){
            insert prodList;
        }
        
        // Create Custom Pricebooks
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(2);
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
        oppotyList[0].PriceBook2Id = stdPbId;
        oppotyList[0].Quarterly_Renewal__c = string.valueof(2);
        oppotyList[0].Sub_End_Date__c = System.Today().addMonths(1);
        insert oppotyList;
        
        // Create Quote and Quote Line - Put Quote Line on Asset
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        quoteList = TestCPQUtilityClass.createSimpleQuote(oppotyList,1);
        //quoteList[0].SBQQ__Primary__c = true;
        insert quoteList;
        
        List<SBQQ__QuoteLine__c> quoteLineList = new List<SBQQ__QuoteLine__c>();
        quoteLineList = TestCPQUtilityClass.createQuoteLines(quoteList,2,prodList);
        if(!quoteLineList.isEmpty()){
            insert quoteLineList;
        }
        
        
        // Create Oppty with stage other than Closed Won
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test Oppty 1';
        opp1.StageName='Prospecting';
        opp1.CloseDate=System.today().addMonths(1);
        opp1.AccountId = accntList[0].Id;
        opp1.PriceBook2Id = stdPbId;
        insert opp1;
        
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = opp1.Id;
        oli1.PricebookEntryId = pbEntryStdPbList[0].Id;
        oli1.UnitPrice = 10;
        oli1.Quantity = 20;
        insert oli1;
        
        oppotyList[0].StageName = 'Closed Won';
        update oppotyList;
             
        // Create Contract
        Contract contrct = new Contract(Name='Test Contract ', AccountId=oppotyList[0].AccountId, SBQQ__Opportunity__c =oppotyList[0].Id, ContractTerm = 12, SBQQ__RenewalForecast__c = true, SBQQ__PreserveBundleStructureUponRenewals__c = true, SBQQ__DefaultRenewalContactRoles__c = true, SBQQ__DefaultRenewalPartners__c = true, StartDate=System.today());
        //insert contrct;      
        
        // Create Assets
        List<Asset> assetList = new List<Asset>();
        Asset as1 = new Asset();
        as1.Name = 'Test Asset 1';
        as1.installdate = System.today();
        as1.UsageEndDate = System.today().addMonths(2);
        as1.Opportunity__c = oppotyList[0].Id;
        //as1.Asset_Type__c='Instance';
        as1.purpose__c='Production';
        as1.Product2Id=prodList[0].id;
        as1.AccountId = accntList[0].Id;
        as1.ContactId = contactList[0].Id;
        as1.SBQQ__QuoteLine__c = quoteLineList[0].Id;
        
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = oppotyList[0].Id;
        as2.AccountId = accntList[0].Id;
        as2.ContactId = contactList[0].Id;
        
        Asset as3 = new Asset();
        as3.Name = 'Test Asset 1';
        as3.installdate = System.today();
        as3.UsageEndDate = System.today().addMonths(2);
        as3.Opportunity__c = oppotyList[0].Id;
        as3.Asset_Type__c='Instance';
        as3.purpose__c='Production';
        as3.Product2Id=prodList[0].id;
        as3.AccountId = accntList[0].Id;
        as3.ContactId = contactList[0].Id;
        as3.SBQQ__QuoteLine__c = quoteLineList[0].Id;
        
        //**************************
        Asset as4 = new Asset();
        as4.Name = 'Test Asset with Acct Prefix';
        as4.installdate = System.today();
        as4.UsageEndDate = System.today().addMonths(2);
        as4.Opportunity__c = oppotyList[0].Id;
        as4.Asset_Type__c='Instance';
        as4.purpose__c='Production';
        as4.Product2Id=prodList[0].id;
        as4.AccountId = accntList[0].Id;
        as4.ContactId = contactList[0].Id;
        as4.SBQQ__QuoteLine__c = quoteLineList[0].Id;
        as4.Acct_Prefix__c = 'TestAcctPrefix';
        //**************************
        
        assetList.add(as1);
        assetList.add(as2);
        assetList.add(as3);
        assetList.add(as4);
        
        if(!assetList.isEmpty()){
            insert assetList;
        } 
        
        // Update Asset
        if(!assetList.isEmpty()){
            update assetList;
        }        
        
        // Delete Asset
        if(!assetList.isEmpty()){
            delete assetList[1];
        }                      
        
        
        //List<Asset> undeleteAsset = new List<Asset>();
        //undeleteAsset =[select id from Asset where name=:'Test Asset' All Rows];
        //if(!undeleteAsset.isEmpty()){
         //   undelete undeleteAsset;
        //} 
       
        test.stoptest();
    }//End of test method testData
    
    */
      static testMethod void AssettriggerHelperTest(){
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA  = true;

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
        prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].ProductCode = 'INST';
        for(Product2 pd: prodList){
            pd.Product_Type__c         ='Services';
            pd.Family                  ='Services';
            pd.Product_SubFamily__c    = 'Launch Pack';
            pd.Product_SubFamily2__c   = 'Launch Pack Core';
            pd.ProductCode             = 'PROD-APPS-INST';

        }
         prodList[1].ProductCode ='PROD-PLAT-SANDBOX-INST';
        prodList[1].Family  = 'Support';
        prodList[1].Product_SubFamily2__c = 'Sandbox';
        prodList[2].Family = 'Education';
        
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
        oppotyList[0].Rep_Create_ARR__c = 10000;
        oppotyList[0].Data_Center__c='US';
        
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        
        insert oppotyList;
        
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        
         List<SBQQ__Quote__c> quotList = TestCPQUtilityClass.createQuotes(oppotyList,  1);
         List<SBQQ__Quote__c> InsertquotList = new List<SBQQ__Quote__c>();
          for(SBQQ__Quote__c quote : quotList){
              quote.SBQQ__Primary__c = true;
               quote.Rubiks_Quote__c = true;        
               quote.SBQQ__LineItemsGrouped__c = false;
              InsertquotList.add(quote);
          }
         
          insert InsertquotList;
         // Test.StartTest();
          List<SBQQ__QuoteLine__c> InsertquoteLineList= TestCPQUtilityClass.createQuoteLinesForQuote( InsertquotList[0],prodList );
           InsertquoteLineList[0].SBQQ__Bundled__c   = False;       
           InsertquoteLineList[1].SBQQ__Bundled__c   = False;
          
          insert InsertquoteLineList;
           
          list<OpportunityLineItem> OLIList = [SELECT id ,Opportunityid From OpportunityLineItem where opportunityid= :oppotyList[0].id];
          system.assertEquals(prodList.size(),OLIList.size());
          
           opportunity opptclose = oppotyList[0];
           opptclose.Stage_Signed_Order_Date__c=system.today(); 
           opptclose.Probability = 1;
           opptclose.Split_Opportunities__c = null;
           opptclose.Ghost__c = False ;
           opptclose.pse__Primary_Project__c = null;  
           opptclose.stagename ='Closed Won';
           opptclose.SBQQ__Contracted__c = true;
          update opptclose;
          
       
          list<contract> contractList = [SELECT id FROM contract WHERE accountid= :opptclose.accountid];
          // system.assertEquals(contractList.size(),1);
           
          list<Asset> assetList = [SELECT id FROM Asset WHERE accountid= :opptclose.accountid];
          
          //system.assertEquals(assetList.size(),3);
            test.startTest();
          List<Contract> insertContractlist   =  TestCPQUtilityClass.createContracts(accntList, 1);
          for(Contract cont : insertContractlist   ){
             // cont.SBQQ__Opportunity__c = opptclose.id;
              cont.ContractTerm         = 4;
              cont.StartDate            = system.today() + 20;
              cont.SBQQ__Quote__c = InsertquotList[0].Id;
          }
        insert insertContractlist   ;
         
        List<SBQQ__Subscription__c> insertSubscriptions = TestCPQUtilityClass.createSubscriptions(insertContractlist,4);
        insertSubscriptions[0].SBQQ__Product__c = prodList[0].Id;
        insertSubscriptions[1].SBQQ__Product__c = prodList[1].Id;
        insertSubscriptions[2].SBQQ__Product__c = prodList[0].Id;
        insertSubscriptions[3].SBQQ__Product__c = prodList[2].Id;
        
        insert insertSubscriptions;
     
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA  = true;
        
        // Create Assets
        List<Asset> insertAssetList = new List<Asset>();
        Asset as1 = new Asset();
        as1.Name = 'Test Asset 1';
        as1.installdate = System.today();
        as1.UsageEndDate = System.today().addMonths(2);
        as1.Opportunity__c = opptclose.Id;
       as1.Asset_Type__c='Education Product';
        //as1.purpose__c='Production';
        as1.Product2Id= prodList[0].id;
        as1.AccountId = opptclose.accountId;
        as1.ContactId = contactList[0].Id;  
        as1.SBQQ__CurrentSubscription__c = insertSubscriptions[0].id;
        as1.SBQQ__LatestQuoteLine__c = InsertquoteLineList[0].id;
        as1.Contract__c=insertContractlist[0].Id;
            
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = opptclose.Id;
        as2.AccountId = opptclose.accountId;
        as2.Product2Id=prodList[1].id;
        as2.ContactId = contactList[0].Id;
        as2.Munchkin_ID__c = 'Test';
        as2.SBQQ__CurrentSubscription__c = insertSubscriptions[1].id;    
        as2.SBQQ__LatestQuoteLine__c = InsertquoteLineList[0].id;
        as2.Asset_Type__c='Service Product';        
        
        Asset as3 = new Asset();
        as3.Name = 'Test Asset 3';
        as3.installdate = System.today();
        as3.UsageEndDate = System.today().addMonths(1);
        as3.Opportunity__c = opptclose.Id;
        as3.AccountId = opptclose.accountId;
        as3.Product2Id=prodList[2].id;
        as3.ContactId = contactList[0].Id; 
        as3.Asset_Type__c='Subscription';
        as3.SBQQ__LatestQuoteLine__c = InsertquoteLineList[0].id;
        //as3.SBQQ__CurrentSubscription__c = insertSubscriptions[2].id; 
        
        //**************************
        Asset as4 = new Asset();
        as4.Name = 'Test Asset with Acct Prefix';
        as4.installdate = System.today();
        as4.UsageEndDate = System.today().addMonths(2);
        as4.Opportunity__c = oppotyList[0].Id;
        as4.Asset_Type__c='Instance';
        as4.purpose__c='Production';
        as4.Product2Id=prodList[0].id;
        as4.AccountId = accntList[0].Id;
        as4.ContactId = contactList[0].Id;
        as4.SBQQ__QuoteLine__c = InsertquoteLineList[0].Id;
        as4.Acct_Prefix__c = 'TestAcctPrefix';
        as4.SBQQ__CurrentSubscription__c = insertSubscriptions[3].id;
        as4.SBQQ__LatestQuoteLine__c = InsertquoteLineList[0].id;
        //**************************
        
        insertAssetList .add(as1);
        insertAssetList .add(as2);
        insertAssetList .add(as3);
        insertAssetList .add(as4);
        
        RubiksProdCode__c rubiksProdCode = new RubiksProdCode__c();
        rubiksProdCode.Name = 'Production Instance';
        rubiksProdCode.Product_Code__c = 'PROD-APPS-INST';
        insert rubiksProdCode;
        
        RubiksSandboxCodes__c rubiksSandboxCode = new RubiksSandboxCodes__c();
        rubiksSandboxCode.Name = 'Sandbox Instance';
        rubiksSandboxCode.Product_Code__c = 'PROD-PLAT-SANDBOX-INST';
        insert rubiksSandboxCode;
        
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        
        
        if(!insertAssetList .isEmpty()){
            insert insertAssetList ;
        } 
        
        if(!insertAssetList.IsEmpty()){
            update insertAssetList;
        }
         AssetTriggerHelper.UpdateUsageDataDataBaseSize(insertAssetList);
        Test.StopTest();
          
    }//End of test method AssettriggerHelperTest
}