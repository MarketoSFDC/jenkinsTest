@IsTest
public class AddingDroppingProdControllerTest{
    
    public static testMethod void insertCustSetRecords(){
        List<Product_SKU_Engineering_Code__c> custSetRecordsList = new List<Product_SKU_Engineering_Code__c>();
        
        // Create custSetRecords
        Product_SKU_Engineering_Code__c  custSetRec1 = new Product_SKU_Engineering_Code__c();
        custSetRec1.Name = 'account Based Marketing';
        custSetRec1.Engineering_Code__c = 'accountBasedMarketing';
        custSetRec1.Product_Code__c = 'EDU-TRN-RTP-ADMIN';
        custSetRec1.Quantity_Multiple__c =1;
        custSetRecordsList.add(custSetRec1);
        
        Product_SKU_Engineering_Code__c  custSetRec2 = new Product_SKU_Engineering_Code__c();
        custSetRec2.Name = 'email Plugin';
        custSetRec2.Engineering_Code__c = 'emailPlugin';
        custSetRec2.Product_Code__c = 'PROD-APPS-EMAILPLUGIN';
        custSetRec2.Quantity_Multiple__c =1;
        custSetRecordsList.add(custSetRec2);

        Product_SKU_Engineering_Code__c  custSetRec3 = new Product_SKU_Engineering_Code__c();
        custSetRec3.Name = 'advanced Report Builder';
        custSetRec3.Engineering_Code__c = 'advancedReportBuilder';
        custSetRec3.Product_Code__c = 'PROD-APPS-ADVREP';
        custSetRec3.Quantity_Multiple__c =1;
        custSetRecordsList.add(custSetRec3);

        Product_SKU_Engineering_Code__c  custSetRec4 = new Product_SKU_Engineering_Code__c();
        custSetRec4.Name = 'custSetRec4';
        custSetRec4.Engineering_Code__c = 'websiteRetargeting';
        custSetRec4.Product_Code__c = 'LM-SAND';
        custSetRec4.Quantity_Multiple__c =1;
        custSetRecordsList.add(custSetRec4);

        Product_SKU_Engineering_Code__c  custSetRec5 = new Product_SKU_Engineering_Code__c();
        custSetRec5.Name = 'website Retargeting';
        custSetRec5.Engineering_Code__c = 'websiteRetargeting';
        custSetRec5.Product_Code__c = 'Sales Insight';
        custSetRec5.Quantity_Multiple__c =1;
        custSetRecordsList.add(custSetRec5);

        Product_SKU_Engineering_Code__c  custSetRec6 = new Product_SKU_Engineering_Code__c();
        custSetRec6.Name = 'custSetRec6';
        custSetRec6.Engineering_Code__c = 'testprodcode';
        custSetRec6.Product_Code__c = 'Outlook plug-in'; 
        custSetRec6.Quantity_Multiple__c =1;
        custSetRecordsList.add(custSetRec6); 
        if(!custSetRecordsList.isEmpty()){
            insert custSetRecordsList;
        }   
    }
    
    @testSetup static void setup(){
        insertCustSetRecords();

        // Create accounts to insert
        Set<Id> accountsToInsertSet = new Set<Id>();
        map<id, id> AccToCont = new Map<id,id>();
        List<Account> accountsToInsertList = new List<Account>();
        integer counter = 1;
        for(Account accnt: TestCPQUtilityClass.createAccounts(1)){
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            accnt.Name = 'AddingDroppingTestAcct'+counter;
            counter++;
            //accnt.RecordTypeId = '01250000000ULb7AAG';
            accountsToInsertList.add(accnt);
        }
        insert accountsToInsertList;
        
        list<Contact> ContactToInsert = new list<Contact>();
        ContactToInsert = TestCPQUtilityClass.createContacts(accountsToInsertList,1);
        //Contact con = new Contact(firstname='First Name', lastname='Last Name', AccountId=accountsToInsertList[0].id);
        insert ContactToInsert;
        
        //Primary_Marketo_User_Lookup__c
        // add products with product code
        List<Product2> productToInsertList = new List<Product2>();
        productToInsertList =TestCPQUtilityClass.createCustomProducts(2);
        productToInsertList[0].MA_or_RTP__c = 'MA';   
        productToInsertList[0].Visible_To_Customer__c = true;
        productToInsertList[0].Family='Support';
        productToInsertList[0].ProductCode = 'EDU-TRN-RTP-ADMIN' ;
        productToInsertList[0].Name = 'account Based Marketing';
        productToInsertList[0].Product_Type__c = 'Subscription';

        productToInsertList[1].Visible_To_Customer__c = true;
        productToInsertList[1].MA_or_RTP__c ='RTP';
        productToInsertList[1].ProductCode = 'PROD-APPS-EMAILPLUGIN' ;
        productToInsertList[1].Family= 'Support ';
        productToInsertList[1].Product_Type__c = 'Subscription';
        productToInsertList[1].Name = 'email Plugin';
        /*
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        productToInsertList[2].Asset_Type__c = 'Support Product';
        productToInsertList[2].ProductCode = 'PROD-APPS-ADVREP';
        productToInsertList[2].Name = 'advanced Report Builder';

        productToInsertList[3].ProductCode ='Sales Insight';
        productToInsertList[3].Name ='website Retargeting';

        productToInsertList[4].ProductCode ='Outlook plug-in'; 
        productToInsertList[4].Name ='custSetRec6'; */
        
        insert productToInsertList;

        // insert products into standard pricebook
        Id stdPricebookId = Test.getStandardPricebookId();
        TestCPQUtilityClass.createStdPricebookEntries(productToInsertList,stdPricebookId);
        
        // Create custom pricebooks
        List<PriceBook2> pricebookList = new List<PriceBook2>();
        pricebookList =TestCPQUtilityClass.createCustomPriceBooks(5);
        insert pricebookList;
        
        // insert products into custom pricebooks
        List<PriceBookEntry> priceBookEntriesList = new List<PriceBookEntry>();
        priceBookEntriesList =TestCPQUtilityClass.createPriceBookEntries(productToInsertList,pricebookList);
        insert priceBookEntriesList;  

        // Insert data for custom setting - SteelBrickCPQPricebook__c
        SteelBrickCPQPricebook__c obj = new SteelBrickCPQPricebook__c();
        obj.Name = 'SteelBrick PB';
        obj.ID__c = priceBookList[0].Id;
        obj.Phoenix_Price_Books__c = priceBookList[0].Id;
        insert obj;
        
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA = true;
    }
    
    public static testMethod void AddingDroppingMethodUpsellUseCase(){
        
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA = true;
        
        List<Account> accountsToInsertList = [select id,Name from Account limit 1];
        system.assertequals(1,accountsToInsertList.size());
        Contact cont = [select id,firstName,LastName from contact limit 1];
        List<PriceBook2> pricebookList = [select id from PriceBook2 limit 1];
        List<Product2> productToInsertList = [select id,ProductCode,Name from Product2 where ProductCode!=null];
        
        // insert opportunities - for Closed Won Oppty - Contract will be created automatically
        List<Opportunity> opptyList = TestCPQUtilityClass.createOpportunities(accountsToInsertList,2);
        for(Opportunity opp : opptyList){
            opp.Rep_Create_ARR__c = 10000;
            opp.Amount = 2000;
            opp.Pricebook2Id = pricebookList[0].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.OwnerId=UserInfo.getUserId();
            opp.Competitor_Swap__c ='Aprimo';
            opp.Primary_Marketo_User_Lookup__c = cont.id ;
            opp.Primary_Marketo_User_Email__c = 'test.abc@jade.com' ;
        }
        
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        
        opptyList[1].type = Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL;
        opptyList[0].stagename = 'Closed Won';
        opptyList[1].stagename =Label.OPPORTUNITY_STAGE_CLOSED_WON; 
        //Test.startTest(); 
        
        Trigger_Opportunity_Helper.isBeforeUpdateEvent = True;
        Trigger_Opportunity_Helper.isBeforeInsertEvent = True;
        if(!opptyList.isEmpty()){
            insert opptyList;
        }
        
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        SalesTriggersUtility.marketoTriggerManager.Deactivate_Asset_Triggers__c = true;
        SalesTriggersUtility.marketoTriggerManager.Deactivate_AssetTriggerVA__c = true;
        
        System.debug('opptyList[0].Accountid...'+opptyList[0].Accountid);
        List<SBQQ__Quote__c> newquotList=  TestCPQUtilityClass.createSimpleQuote(opptyList,1);
        for(SBQQ__Quote__c SBQuote :newquotList){
            SBQuote.Rubiks_Quote__c = true;
            SBQuote.SBQQ__Primary__c = true;
        }
        system.debug('newquotList================='+newquotList);
        SalesTriggersUtility.marketoTriggerManager.Deactivate_Steelbrick_Quote_Triggers__c = true;
        insert newquotList;
        
        Test.startTest(); 
        
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA = true;
        
        List<SBQQ__QuoteLine__c>  quoteLineList = TestCPQUtilityClass.createQuoteLines(newquotList,2,productToInsertList);
        for(SBQQ__QuoteLine__c QLI:quoteLineList){
            QLI.Product_Type__c ='Subscription';
        }
        insert quoteLineList;

        // create contracts 
        List<Contract> contractList = new List<Contract>();
        Contract contract1 = new Contract(Name='Test Contract ', AccountId=opptyList[0].AccountId,SBQQ__Opportunity__c = opptyList[0].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true, SBQQ__Quote__c = newquotList[0].Id,ContractTerm = 12);         
        contractList.add(contract1);
        insert contractList;
        Test.stopTest();
        SalesTriggersUtility.marketoTriggerManager.Deactivate_Opportunity_Triggers__c = true; 
        
        list<SBQQ__QuoteLine__c> QLIList =    [SELECT id,SBQQ__Product__c FROM SBQQ__QuoteLine__c   WHERE SBQQ__Quote__r.SBQQ__Opportunity2__r.type !=:Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL AND SBQQ__Product__c!=null];
        opptyList[1].Prior_Opportunity__c = opptyList[0].id;
        opptyList[1].SBQQ__AmendedContract__c = contractList[0].id;
        opptyList[1].SBQQ__PrimaryQuote__c    = newquotList[1].id;
        opptyList[1].Account_String__c        = 'TestAccountPrefix';
        update opptyList;
        
        List<Asset> assetList = new List<Asset>();
        Asset as1 = new Asset();
        as1.Name = 'Test Asset 1';
        as1.installdate = System.today();
        as1.UsageEndDate = System.today().addMonths(2);
        as1.Opportunity__c = opptyList[0].Id;
        as1.Asset_Type__c='Instance';
        as1.purpose__c='Production';
        as1.Product2Id= productToInsertList[0].Id;
        as1.AccountId = accountsToInsertList[0].Id;
        as1.ContactId = cont.id;
        as1.status = 'Active';
        as1.Acct_Prefix__c = 'TestAccountPrefix';
        as1.Munchkin_ID__c = 'TestMunchkinId';
        as1.SBQQ__QuoteLine__c =QLIList[0].id;
        
        as1.Contract__c = contractList[0].Id;
        assetList.add(as1);
        
        
        if(!assetList.isEmpty()){
            insert assetList;
        } 
        list<asset> assBunAssetList = [SELECT id,Product2id,name,Product_Code__c,Associated_Bundle__c FROM  Asset WHERE Id IN :assetList];  
        system.debug('assBunAssetList======='+assBunAssetList);
        
        contractList[0].Primary_Asset__c = assetList[0].Id;
        update contractList;
        
        
        SalesTriggersUtility.marketoTriggerManager.Deactivate_Subscription_Triggers__c =true;
        // create subscriptions
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[0].Id,SBQQ__QuoteLine__c=quoteLineList[0].id,Production_Asset__c=assetList[0].Id);
        
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[1].Id,SBQQ__QuoteLine__c=quoteLineList[1].id,Production_Asset__c=assetList[0].Id);
        
        subList.add(sub1);
        //subList.add(sub2);
        insert subList;
        
        List<SBQQ__Subscription__c> subscriptionList = [SELECT Id,SBQQ__Account__c,SBQQ__Contract__c,SBQQ__Quantity__c,SBQQ__TerminatedDate__c,SBQQ__ProrateMultiplier__c,SBQQ__Product__c,SBQQ__QuoteLine__c,Production_Asset__c,Subscription_Product_Code__c FROM SBQQ__Subscription__c WHERE id=:subList[0].id];
        
        //system.assertEquals('01t0v00000257ki',subscriptionList[0].Subscription_Product_Code__c);
        
        SalesTriggersUtility.marketoTriggerManager.Deactivate_OLI_Triggers__c = true;
        list<OpportunityLineItem> insertOLIUP =new list<OpportunityLineItem>();
        
        OpportunityLineItem oliUp1 = new OpportunityLineItem(OpportunityId = opptyList[1].id, PricebookEntryId = pricebookList[0].Id , UnitPrice = 20, Quantity =30,SBQQ__QuoteLine__c=quoteLineList[1].id,Product2Id=productToInsertList[0].id);
        insertOLIUP.add(oliUp1);
        
        map<string,list<string> > AddedDroppedQtyChangeProduct= AddingDroppingProdController.populateAddedDroppedProductsOnCase(opptyList[1]);
        
        createProvisioningCaseFromOpportunity.createProvisioningCase(opptyList);
    }//End of method AddingDroppingMethodUseCase1 
    
    public static testMethod void AddingDroppingMethodRenewalUseCase(){

        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA = true;
        
        List<Account> accountsToInsertList = [select id,Name from Account limit 1];
        system.assertequals(1,accountsToInsertList.size());
        Contact cont = [select id,firstName,LastName from contact limit 1];
        List<PriceBook2> pricebookList = [select id from PriceBook2];
        // insert opportunities - for Closed Won Oppty - Contract will be created automatically
        List<Opportunity> opptyList = TestCPQUtilityClass.createOpportunities(accountsToInsertList,2);
        for(Opportunity opp : opptyList){
            opp.Rep_Create_ARR__c = 10000;
            opp.Amount = 2000;
            opp.Pricebook2Id = pricebookList[0].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.OwnerId=UserInfo.getUserId();
            opp.Competitor_Swap__c ='Aprimo';
            opp.Primary_Marketo_User_Lookup__c = cont.id ;
            opp.Primary_Marketo_User_Email__c = 'test.abc@jade.com' ;
        }
        
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        
        opptyList[1].type = 'Renewal';
        opptyList[0].stagename = 'Closed Won';
        opptyList[1].stagename =Label.OPPORTUNITY_STAGE_CLOSED_WON; 
        //Test.startTest(); 
        
        Trigger_Opportunity_Helper.isBeforeUpdateEvent = True;
        Trigger_Opportunity_Helper.isBeforeInsertEvent = True;
        if(!opptyList.isEmpty()){
            insert opptyList;
        }
        
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        SalesTriggersUtility.marketoTriggerManager.Deactivate_Asset_Triggers__c = true;
        SalesTriggersUtility.marketoTriggerManager.Deactivate_AssetTriggerVA__c = true;
     
        List<SBQQ__Quote__c> newquotList=  TestCPQUtilityClass.createSimpleQuote(opptyList,1);

        SalesTriggersUtility.marketoTriggerManager.Deactivate_Steelbrick_Quote_Triggers__c = true;
        for(SBQQ__Quote__c SBQuote :newquotList){
            SBQuote.SBQQ__Primary__c  = true;
            SBQuote.SBQQ__LineItemsGrouped__c = true;
            SBQuote.Mdq_quote__c = true; 
            SBQuote.Rubiks_Quote__c = false;    
        }
        insert newquotList;

        List<SBQQ__QuoteLineGroup__c> QuoteLineGrpList = new List<SBQQ__QuoteLineGroup__c>();
        QuoteLineGrpList = TestCPQUtilityClass.createQuoteLineGroup(newquotList, 2);
        for(SBQQ__Quote__c SBQuote :newquotList){
            QuoteLineGrpList[0].Contact_Database_Size__c = 10234;
            QuoteLineGrpList[0].SBQQ__Quote__c = SBQuote.Id;
            QuoteLineGrpList[0].Name = 'US';
            QuoteLineGrpList[1].Contact_Database_Size__c = 10000;
            QuoteLineGrpList[1].SBQQ__Quote__c = SBQuote.Id;
            QuoteLineGrpList[1].Name= 'UK';
        }
        insert QuoteLineGrpList;

        List<Product2> productToInsertList = [select id,ProductCode,Name from Product2 where ProductCode!=null];
        system.assertequals(2,productToInsertList.size());
        
        Test.startTest(); 
        
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA = true;
        
        List<SBQQ__QuoteLine__c>  quoteLineList = TestCPQUtilityClass.createQuoteLines(newquotList,2,productToInsertList);
        for(SBQQ__QuoteLine__c QLI:quoteLineList){
            QLI.Product_Type__c ='Subscription';
            QLI.SBQQ__Quantity__c = 3.0;
        }
        insert quoteLineList;
        
        // create contracts 
        List<Contract> contractList = new List<Contract>();
        Contract contract1 = new Contract(Name='Test Contract ', AccountId=opptyList[0].AccountId,SBQQ__Opportunity__c = opptyList[0].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true, SBQQ__Quote__c = newquotList[0].Id,ContractTerm = 12);         
        contractList.add(contract1);
        
        insert contractList;
        
        SalesTriggersUtility.marketoTriggerManager.Deactivate_Opportunity_Triggers__c = true; 
        
        list<SBQQ__QuoteLine__c> QLIList = [SELECT id,SBQQ__Product__c,SBQQ__Quantity__c,Product_Family__c FROM SBQQ__QuoteLine__c  WHERE SBQQ__Quote__r.SBQQ__Opportunity2__r.type !=:Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL AND SBQQ__Product__c!=null AND SBQQ__Quote__r.SBQQ__Opportunity2__c=:opptyList[1].id];

        opptyList[1].Prior_Opportunity__c     = opptyList[0].id;
        opptyList[1].SBQQ__RenewedContract__c = contractList[0].id;
        opptyList[1].SBQQ__PrimaryQuote__c    = newquotList[1].id;
        opptyList[0].SBQQ__PrimaryQuote__c    = newquotList[0].id;
        opptyList[1].Account_String__c        = 'TestAccountPrefix';
        update opptyList;

        SalesTriggersUtility.marketoTriggerManager.Deactivate_OLI_Triggers__c = true;
        list<OpportunityLineItem> insertOLIUP =new list<OpportunityLineItem>();
        
        List<Asset> assetList = new List<Asset>();
        Asset as1 = new Asset();
        as1.Name = 'Test Asset 1';
        as1.installdate = System.today();
        as1.UsageEndDate = System.today().addMonths(2);
        as1.Opportunity__c = opptyList[0].Id;
        as1.Asset_Type__c='Instance';
        as1.purpose__c='Production';
        as1.Product2Id= productToInsertList[0].Id;
        as1.AccountId = accountsToInsertList[0].Id;
        as1.ContactId = cont.id;
        as1.status = 'Active';
        as1.Acct_Prefix__c = 'TestAccountPrefix';
        as1.Munchkin_ID__c = 'TestMunchkinId';
        as1.SBQQ__QuoteLine__c =QLIList[1].id;
        
        as1.Contract__c = contractList[0].Id;
        assetList.add(as1);
        
        if(!assetList.isEmpty()){
            insert assetList;
        } 
        list<asset> assBunAssetList = [SELECT id,Product2id,name,Product_Code__c,Associated_Bundle__c FROM  Asset WHERE Id IN :assetList];  
        
        contractList[0].Primary_Asset__c = assetList[0].Id;
        update contractList;
        
        SalesTriggersUtility.marketoTriggerManager.Deactivate_Subscription_Triggers__c =true;
        // create subscriptions
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[0].Id,SBQQ__QuoteLine__c=quoteLineList[0].id,Production_Asset__c=assetList[0].Id);
        
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[1].Id,SBQQ__QuoteLine__c=quoteLineList[1].id,Production_Asset__c=assetList[0].Id);
       
        subList.add(sub1);
        subList.add(sub2);
        insert subList;
        
        QLIList[1].SBQQ__RenewedSubscription__c = subList[0].id;
        QLIList[1].Product_Family__c = null;
        QLIList[0].Product_Family__c = null;
        update QLIList;

        Test.stopTest();

        OpportunityLineItem oliUp1 = new OpportunityLineItem(OpportunityId = opptyList[1].id, UnitPrice = 20, Quantity =30,SBQQ__QuoteLine__c=QLIList[0].id,Product2Id=productToInsertList[0].id);
        insertOLIUP.add(oliUp1);

        SalesTriggersUtility.marketoTriggerManager.Deactivate_OLI_Triggers__c = true;
        OpportunityLineItem oliUp = new OpportunityLineItem(OpportunityId = opptyList[1].id, UnitPrice = 20, Quantity =30,SBQQ__QuoteLine__c=QLIList[1].id,Product2Id=productToInsertList[1].id);
        insertOLIUP.add(oliUp);
        
        insert insertOLIUP;

        list<Opportunity> oppAddDrop=[SELEct id,SBQQ__PrimaryQuote__r.Instance_Rollup__c,SBQQ__PrimaryQuote__c,SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c,(SELECT Id,SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c,SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.Production_Asset__c,Opportunity.Sub_End_Date__c, Opportunity.Sub_Start_Date__c, Name, ProductCode,Quantity,OpportunityId, Opportunity.Maximum_Database_Size__c,Product_Name__c,SBQQ__QuoteLine__r.SBQQ__Quantity__c,opportunity.Pricebook2Id,PricebookEntry.Product2.Name,QuoteLine_Quantity__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.id,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__ProductCode__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.Name,SBQQ__QuoteLine__r.Bundle_Package__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.MKTO_Product_Name__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.SBQQ__StartDate__c,SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c FROM OpportunityLineItems) FROM Opportunity where Id=: opptyList[1].id];

        //system.assertEquals(false,oppAddDrop[0].SBQQ__PrimaryQuote__r.SBQQ__LineItemsGrouped__c);
        map<string,list<string> > AddedDroppedQtyChangeProduct= AddingDroppingProdController.populateAddedDroppedProductsOnCase(oppAddDrop[0]);
        
        AddingDroppingProdController.AddedProducts.add('lifeCycleModeler:'+2); 
        AddingDroppingProdController.AddedProducts.add('lifeCycleModeler_AdditionalModels:'+3);
        AddingDroppingProdController.MultiInstAddedProducts.put(QLIList[0].id,new list<string>{'lifeCycleModeler:'+2,'lifeCycleModeler_AdditionalModels:'+3});
        
        AddingDroppingProdController.DroppedProducts.add('lifeCycleModeler:'+4);
        AddingDroppingProdController.DroppedProducts.add('lifeCycleModeler_AdditionalModels:'+6);
        AddingDroppingProdController.MultiInstDroppedProducts.put(QLIList[0].id,new list<string>{'lifeCycleModeler:'+4,'lifeCycleModeler_AdditionalModels:'+6});
        
        AddingDroppingProdController.QuantityChangedProducts.add('lifeCycleModeler:'+4);
        AddingDroppingProdController.DroppedProducts.add('lifeCycleModeler_AdditionalModels:'+6);
        AddingDroppingProdController.MultiInstQuantityChangedProducts.put(QLIList[0].id,new list<string>{'lifeCycleModeler_AdditionalModels:'+4,'lifeCycleModeler:'+6});
        map<string,list<string> > AddedDroppedQtyChangeProduct1= AddingDroppingProdController.populateAddedDroppedProductsOnCase(oppAddDrop[0]); 
        
        createProvisioningCaseFromOpportunity.createProvisioningCase(opptyList);
        
    }//End of method AddingDroppingMethodRenewalUseCase 
    
    
    public static testmethod void Test2ndSegmentAddingDropping(){
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA = true;
        
        List<Account> accountsToInsertList = [select id,Name from Account limit 1];
        system.assertequals(1,accountsToInsertList.size());
        Contact cont = [select id,firstName,LastName from contact limit 1];
        List<PriceBook2> pricebookList = [select id from PriceBook2];
        List<Product2> productToInsertList = [select id from Product2 limit 2];
        // insert opportunities - for Closed Won Oppty - Contract will be created automatically
        List<Opportunity> opptyList = TestCPQUtilityClass.createOpportunities(accountsToInsertList,2);
        for(Opportunity opp : opptyList){
            opp.Rep_Create_ARR__c = 10000;
            opp.Amount = 2000;
            opp.Pricebook2Id = pricebookList[0].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.OwnerId=UserInfo.getUserId();
            opp.Competitor_Swap__c ='Aprimo';
            opp.Primary_Marketo_User_Lookup__c = cont.id ;
            opp.Primary_Marketo_User_Email__c = 'test.abc@jade.com' ;
        }
        
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        
        opptyList[1].type = 'Renewal';
        opptyList[0].stagename = 'Closed Won';
        opptyList[1].stagename =Label.OPPORTUNITY_STAGE_CLOSED_WON; 
        //Test.startTest(); 
        
        Trigger_Opportunity_Helper.isBeforeUpdateEvent = True;
        Trigger_Opportunity_Helper.isBeforeInsertEvent = True;
        if(!opptyList.isEmpty()){
            insert opptyList;
        }
        
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        SalesTriggersUtility.marketoTriggerManager.Deactivate_Asset_Triggers__c = true;
        SalesTriggersUtility.marketoTriggerManager.Deactivate_AssetTriggerVA__c = true;

        List<SBQQ__Quote__c> newquotList=  TestCPQUtilityClass.createSimpleQuote(opptyList,1);
        for(SBQQ__Quote__c SBQuote :newquotList){
            SBQuote.Rubiks_Quote__c = true;
            SBQuote.SBQQ__Primary__c = true;
        }
        insert newquotList;
        List<SBQQ__QuoteLine__c>  quoteLineList = TestCPQUtilityClass.createQuoteLines(newquotList,2,productToInsertList);
        
        for(SBQQ__QuoteLine__c QLI:quoteLineList){  
            QLI.Product_Type__c ='Subscription';
            QLI.SBQQ__StartDate__c=System.Today().addDays(120);
        }
        quoteLineList[0].SBQQ__StartDate__c=System.Today();
        quoteLineList[1].SBQQ__StartDate__c=System.Today();
        insert quoteLineList;
        
        // create contracts 
        List<Contract> contractList = new List<Contract>();
        Contract contract1 = new Contract(Name='Test Contract ', AccountId=opptyList[0].AccountId,SBQQ__Opportunity__c = opptyList[0].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true, SBQQ__Quote__c = newquotList[1].Id,ContractTerm = 12);         
        contractList.add(contract1);
        insert contractList;

        List<SBQQ__QuoteLine__c> QLIList = [SELECT id,SBQQ__Product__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__r.SBQQ__Opportunity2__r.type !=:Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL AND SBQQ__Product__c!=null];
        opptyList[1].Prior_Opportunity__c     = opptyList[0].id;
        opptyList[1].SBQQ__RenewedContract__c = contractList[0].id;
        opptyList[1].SBQQ__PrimaryQuote__c    = newquotList[1].id;
        opptyList[1].Account_String__c        = 'TestAccountPrefix';
        update opptyList;
 
        Utility.isAssetTriggerExecutedFromOppty  = true;
        
        List<Asset> assetList = new List<Asset>();
        Asset as1 = new Asset();
        as1.Name = 'Test Asset 1';
        as1.installdate = System.today();
        as1.UsageEndDate = System.today().addMonths(2);
        as1.Opportunity__c = opptyList[0].Id;
        //as1.Asset_Type__c='Instance';
        as1.purpose__c='Production';
        as1.Product2Id= productToInsertList[0].Id;
        as1.AccountId = accountsToInsertList[0].Id;
        as1.ContactId = cont.id ;
        as1.status = 'Active';
        as1.Acct_Prefix__c = '';
        as1.Munchkin_ID__c= 'TestMunchkinId';
        as1.SBQQ__QuoteLine__c =QLIList[0].id;
        as1.Contract__c = contractList[0].Id;

        assetList.add(as1);

        insert assetList;

        Test.startTest(); 

        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA = true;
        
        // create subscriptions
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();

        SBQQ__Subscription__c sub1   = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3,SBQQ__SegmentStartDate__c=system.today(),SBQQ__SegmentQuantity__c=1,SBQQ__SegmentIndex__c=1,Production_Asset__c=assetList[0].id, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[0].Id,SBQQ__QuoteLine__c=quoteLineList[0].id);
        SBQQ__Subscription__c subSeg2 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3,SBQQ__SegmentStartDate__c=system.today().addDays(120),SBQQ__SegmentQuantity__c=3,SBQQ__SegmentIndex__c=2,Production_Asset__c=assetList[0].id, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[0].Id,SBQQ__QuoteLine__c=quoteLineList[0].id);
        
        SBQQ__Subscription__c subDrop = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3,SBQQ__SegmentStartDate__c=system.today(),SBQQ__SegmentQuantity__c=1,SBQQ__SegmentIndex__c=1, Production_Asset__c=assetList[0].id,SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[1].Id,SBQQ__QuoteLine__c=quoteLineList[1].id);
        
        SBQQ__Subscription__c sub11 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=4,Production_Asset__c=assetList[0].id, SBQQ__SegmentStartDate__c=system.today().addDays(120),SBQQ__SegmentQuantity__c=3,SBQQ__SegmentIndex__c=2,SBQQ__TerminatedDate__c=System.today().addMonths(7),SBQQ__ProrateMultiplier__c = 1, SBQQ__Product__c =productToInsertList[1].Id);
        
        SBQQ__Subscription__c sub6 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =QLIList[0].SBQQ__Product__c,SBQQ__QuoteLine__c=QLIList[0].id);

        SBQQ__Subscription__c sub7 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c  =QLIList[1].SBQQ__Product__c,SBQQ__QuoteLine__c=QLIList[1].id); 
        subList.add(sub1);
        subList.add(subSeg2);
        subList.add(subDrop);
        subList.add(sub6);
        subList.add(sub7); 
        subList.add(sub11);
        
        insert subList;
        date segDate =system.today().addDays(120);

        list<Opportunity> oppAddDrop=[SELEct id,(SELECT Id,SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c,SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.Production_Asset__c,Opportunity.Sub_End_Date__c, Opportunity.Sub_Start_Date__c, Name, ProductCode, Quantity, OpportunityId, Opportunity.Maximum_Database_Size__c,Product_Name__c,SBQQ__QuoteLine__r.SBQQ__Quantity__c,opportunity.Pricebook2Id,PricebookEntry.Product2.Name,QuoteLine_Quantity__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.id,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__ProductCode__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.Name,SBQQ__QuoteLine__r.Bundle_Package__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.MKTO_Product_Name__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.SBQQ__StartDate__c,SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c FROM OpportunityLineItems) FROM Opportunity where Id=: opptyList[0].id AND StageName =:Label.OPPORTUNITY_STAGE_CLOSED_WON AND AccountId!=null  AND SBQQ__PrimaryQuote__c!=null AND SBQQ__PrimaryQuote__r.Rubiks_Quote__c=TRUE];
        
        
        AddingDroppingProdController.AddedProducts.add('ENG:'+2); 
        AddingDroppingProdController.AddedProducts.add('ENG1:'+3);
        AddingDroppingProdController.MultiInstAddedProducts.put(QLIList[0].id,new list<string>{'ENG:'+2,'ENG1:'+3});
        
        AddingDroppingProdController.DroppedProducts.add('ENG12:'+4);
        AddingDroppingProdController.DroppedProducts.add('ENG122:'+6);
        AddingDroppingProdController.MultiInstDroppedProducts.put(QLIList[0].id,new list<string>{'ENG12:'+4,'ENG122:'+6});
        
        AddingDroppingProdController.QuantityChangedProducts.add('ENG11:'+4);
        AddingDroppingProdController.DroppedProducts.add('ENG33:'+6);
        AddingDroppingProdController.MultiInstQuantityChangedProducts.put(QLIList[0].id,new list<string>{'ENG11:'+4,'ENG33:'+6});
        map<string,list<string> > AddedDroppedQtyChangeProduct= AddingDroppingProdController.populateAddedDroppedProductsOnMDQ2ndSegmentCase(oppAddDrop[0]);
        
        Test.stopTest();
        createProvisioningCaseFromOpportunity.create2ndSegmentProvisioningCase(oppAddDrop[0]);
        
    }//End of Test Method Test2ndSegmentAddingDropping   
}