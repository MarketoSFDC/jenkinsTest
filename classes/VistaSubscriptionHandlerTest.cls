/**
 * Test class for VistaSubscriptionHandler.
 *
 * @author Advanced Technology Group (www.atginfo.com)
 * @see VistaSubscriptionHandler
 */
@isTest
private class VistaSubscriptionHandlerTest {

    /**
     * Holds an instance of VistaAssetHelperUtil class,
     * which provides helper methods such as insertion of test records.
     * @see VistaAssetHelperUtil
     */
    public static VistaAssetHelperUtil util = new VistaAssetHelperUtil();

    /**
     * Test case that proves SBQQ__Subscription__c insertion is working
     * with the VistaSubscriptionHandler being called in the after insert trigger.
     */ 
     @isTest static void subscriptionTriggerTest() {
        System.debug(LoggingLevel.INFO, 'VistaSubscriptionHandlerTest.subscriptionTriggerTest');

        // Create a product record
        List<Product2> productList = new List<Product2>();
        productList.addAll(util.initProductSet(1, 'Hardware', 'Fixed Price'));

        Test.startTest();

        // Create a subscription record
        SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
        sub.SBQQ__Product__c = productList[0].Id;
        sub.SBQQ__Quantity__c = 1;
        sub.SBQQ__NetPrice__c = 1.00;
        sub.Annual_Recurring_Revenue__c = 1.00;
        sub.SBQQ__SubscriptionStartDate__c = System.today();
        insert sub;

        System.assertEquals(1, sub.SBQQ__Quantity__c);

        Test.stopTest();
    }

    /**
     * Test case that proves Customer_Asset__c record are being inserted after
     * SBQQ__Subscription__c records are created.
     */ 
    @isTest static void createNewSubscriptionTest() {
        System.debug(LoggingLevel.INFO, 'VistaSubscriptionHandlerTest.createNewSubscriptionTest');

        // Create an account and a Master Subscription Agreement
        Account account = util.createAccount('ABC Test Account');
        Contract msa = util.createContract(null, account, 'Customer - MSA', Date.today());
        
        // Create products that generate subscriptions
        List<Product2> productList = new List<Product2>();
        productList.addAll(util.initProductSet(5, 'Hardware', 'Fixed Price'));

        // Generate pricebook entries for the products created above
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);

        // Create an opportunity
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');

        // Create a quote related with the opportinity and quote lines using the products
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today());
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, false, 2);

        // Update the opportunity items based on quote lines
        List<OpportunityLineItem> opportunityLineItems = util.createOppLineItems(opportunity, sbQuoteLines, pricebookEntries);
        
        // Create a contract and the subscriptions for that contact
        Contract contract = util.createContract(opportunity, account, 'SteelBrick CPQ Contract', Date.today());
        List<SBQQ__Subscription__c> subscriptionList = util.createSubscriptions(sbQuoteLines, contract, account, null);
        
        subscriptionList = [SELECT Id, SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__Account__c
                            , SBQQ__Contract__c, SBQQ__Contract__r.EndDate, SBQQ__StartDate__c
                            , SBQQ__EndDate__c, SBQQ__Quantity__c
                            , Subscribed_Asset_Count__c
                            , SBQQ__Product__r.Name, SBQQ__Product__r.Description
                            , SBQQ__NetPrice__c, Annual_Recurring_Revenue__c
                            , SBQQ__RevisedSubscription__c
                            FROM SBQQ__Subscription__c WHERE Id in :subscriptionList];

        Test.startTest();

        List<Customer_Asset__c> vistaAssets = [SELECT Id, Name, Account__c, Product__c, Description__c, Contract__c
                                               , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                                               , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c
                                               FROM Customer_Asset__c WHERE Steelbrick_Subscription__c IN :subscriptionList];

        // Validate one Customer Asset per Subscription was created
        System.assertEquals(5, vistaAssets.size());
        Test.stopTest();
    }

    /**
     * Test case that proves Customer_Asset__c record are being updated after
     * SBQQ__Subscription__c records are created as amendments.
     */ 
    @isTest static void updateExistingSubscriptionTest() {
        System.debug(LoggingLevel.INFO, 'VistaSubscriptionHandlerTest.updateExistingSubscriptionTest');

        // Create an account and a Master Subscription Agreement
        Account account = util.createAccount('ABC Test Account');
        Contract msa = util.createContract(null, account, 'Customer - MSA', Date.today());
        
        // Create products that generate subscriptions
        List<Product2> productList = new List<Product2>();
        productList.addAll(util.initProductSet(1, 'Hardware', 'Fixed Price'));

        // Generate pricebook entries for the products created above
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);

        // Create an opportunity
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');

        // Create a quote related with the opportinity and quote lines using the products
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today());
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, false, 2);

        // Update the opportunity items based on quote lines
        List<OpportunityLineItem> opportunityLineItems = util.createOppLineItems(opportunity, sbQuoteLines, pricebookEntries);
        
        // Create a contract and the subscriptions for that contact
        Contract contract = util.createContract(opportunity, account, 'SteelBrick CPQ Contract', Date.today());
        List<SBQQ__Subscription__c> subscriptionList = util.createSubscriptions(sbQuoteLines, contract, account, null);
        
        subscriptionList = [SELECT Id, SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__Account__c
                            , SBQQ__Contract__c, SBQQ__Contract__r.EndDate, SBQQ__StartDate__c
                            , SBQQ__EndDate__c, SBQQ__Quantity__c
                            , Subscribed_Asset_Count__c
                            , SBQQ__Product__r.Name, SBQQ__Product__r.Description
                            , SBQQ__NetPrice__c, Annual_Recurring_Revenue__c
                            , SBQQ__RevisedSubscription__c
                            FROM SBQQ__Subscription__c WHERE Id in :subscriptionList];


        Test.startTest();

        List<Customer_Asset__c> vistaAssets = [SELECT Id, Name, Account__c, Product__c, Description__c, Contract__c
                                                    , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                                                    , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c
                                                    FROM Customer_Asset__c WHERE Steelbrick_Subscription__c IN :subscriptionList];

        /* --- Step 2: Create addon subscription --- */

        // Create a new product
        List<Product2> productListAddon = new List<Product2>();
        productListAddon.addAll(util.initProductSet(1, 'Hardware', 'Fixed Price'));

        // ..and pricebook entries for the new product
        Map<Id, PricebookEntry> pricebookEntriesAddon = new Map<Id, PricebookEntry>();
        pricebookEntriesAddon = util.initPricebook(productListAddon);

        // Create opportunity, quote and quote lines
        Opportunity opportunityAddon = util.createNewOpportunity('Test Opportunity 1 Addon', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuoteAddon = util.createSBQuote(opportunityAddon, account, Date.today());
        List<SBQQ__Quoteline__c> sbQuoteLinesAddon = util.createSBQuoteLines(sbQuoteAddon, pricebookEntriesAddon, true, 2);

        // Update the quote lines setting the previous subscription
        for(integer i = 0; i < sbQuoteLinesAddon.size(); i++) {
            sbQuoteLinesAddon[i].SBQQ__UpgradedSubscription__c = subscriptionList[0].Id;
        }
        update sbQuoteLinesAddon;

        // Create opportunity line items using updated quotes
        List<OpportunityLineItem> opportunityLineItemsAddon = util.createOppLineItems(opportunityAddon, sbQuoteLinesAddon, pricebookEntriesAddon);
        
        // Create a contract and the subscriptions for that contact
        Contract contractAddon = util.createContract(opportunityAddon, account, 'SteelBrick CPQ Contract', Date.today());
        List<SBQQ__Subscription__c> subscriptionListAddon = util.createSubscriptions(sbQuoteLinesAddon, contractAddon, account, null);

        subscriptionListAddon = [SELECT Id, SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__Account__c
                            , SBQQ__Contract__c, SBQQ__Contract__r.EndDate, SBQQ__StartDate__c
                            , SBQQ__EndDate__c, SBQQ__Quantity__c
                            , Subscribed_Asset_Count__c
                            , SBQQ__Product__r.Name, SBQQ__Product__r.Description
                            , SBQQ__NetPrice__c, Annual_Recurring_Revenue__c
                            , SBQQ__RevisedSubscription__c
                            FROM SBQQ__Subscription__c WHERE Id in :subscriptionListAddon];


        List<Customer_Asset__c> vistaAssetsAddon = [SELECT Id, Name, Account__c, Product__c, Description__c, Contract__c
                                                    , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                                                    , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c
                                                    FROM Customer_Asset__c WHERE Steelbrick_Subscription__c IN :subscriptionListAddon];

        // Check first record
        System.assertEquals(1, vistaAssets.size());

        Customer_Asset__c vaUpdate = vistaAssets[0];
        vaUpdate.Steelbrick_Subscription__c = subscriptionList[0].Id;
        vaUpdate.Decommission_Effective_Date__c = System.today();
        update vaUpdate;

        vaUpdate = [SELECT Id, Name, Account__c, Product__c, Description__c, Contract__c
                   , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                   , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c
                   , Steelbrick_Subscription__r.SBQQ__Contract__c, Steelbrick_Subscription__r.SBQQ__StartDate__c
                   , Steelbrick_Subscription__r.SBQQ__EndDate__c, Steelbrick_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c
                   , Steelbrick_Subscription__r.SBQQ__NetPrice__c, Steelbrick_Subscription__r.Annual_Recurring_Revenue__c
                   , Steelbrick_Subscription__r.CurrencyIsoCode
                   FROM Customer_Asset__c WHERE Id = :vaUpdate.Id];

        Test.stopTest();
    }

    /**
     * Test case that proves Customer_Asset__c record are being decommissed after
     * SBQQ__Subscription__c records asociated with them are decomissed too.
     */ 
    @isTest static void decomExistingSubscriptionTest() {
        System.debug(LoggingLevel.INFO, 'VistaSubscriptionHandlerTest.updateExistingSubscriptionTest');

        // Create an account and a Master Subscription Agreement
        Account account = util.createAccount('ABC Test Account');
        Contract msa = util.createContract(null, account, 'Customer - MSA', Date.today());
        
        // Create products that generate subscriptions
        List<Product2> productList = new List<Product2>();
        productList.addAll(util.initProductSet(1, 'Hardware', 'Fixed Price'));

        // Generate pricebook entries for the products created above
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);

        // Create an opportunity
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');

        // Create a quote related with the opportinity and quote lines using the products
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today());
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, false, 2);

        // Update the opportunity items based on quote lines
        List<OpportunityLineItem> opportunityLineItems = util.createOppLineItems(opportunity, sbQuoteLines, pricebookEntries);
        
        // Create a contract and the subscriptions for that contact
        Contract contract = util.createContract(opportunity, account, 'SteelBrick CPQ Contract', Date.today());
        List<SBQQ__Subscription__c> subscriptionList = util.createSubscriptions(sbQuoteLines, contract, account, null);
        
        subscriptionList = [SELECT Id, SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__Account__c
                            , SBQQ__Contract__c, SBQQ__Contract__r.EndDate, SBQQ__StartDate__c
                            , SBQQ__EndDate__c, SBQQ__Quantity__c
                            , Subscribed_Asset_Count__c
                            , SBQQ__Product__r.Name, SBQQ__Product__r.Description
                            , SBQQ__NetPrice__c, Annual_Recurring_Revenue__c
                            , SBQQ__RevisedSubscription__c
                            FROM SBQQ__Subscription__c WHERE Id in :subscriptionList];


        Test.startTest();

        List<Customer_Asset__c> vistaAssets = [SELECT Id, Name, Account__c, Product__c, Description__c, Contract__c
                                                    , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                                                    , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c
                                                    FROM Customer_Asset__c WHERE Steelbrick_Subscription__c IN :subscriptionList];
        
        /* --- Step 2: Create decom subscription --- */

        // Create an opportunity and a quote for decommission
        Opportunity opportunityDecom = util.createNewOpportunity('Test Opportunity 1 Decom', account, 'Products, Services and Maintenance', 'New'); 
        SBQQ__Quote__c sbQuoteDecom = util.createSBQuote(opportunityDecom, account, Date.today());

        // Create a quote line item with the same product but with quantity = 0
        List<SBQQ__Quoteline__c> sbQuoteLinesDecom = util.createSBQuoteLines(sbQuoteDecom, pricebookEntries, true, 0);

        // Update opportunity line items
        List<OpportunityLineItem> opportunityLineItemsDecom = util.createOppLineItems(opportunityDecom, sbQuoteLinesDecom, pricebookEntries);

        // Create new subscription for the same contract
        List<SBQQ__Subscription__c> subscriptionListDecom = util.createSubscriptions(sbQuoteLinesDecom, contract, account, null);
        
        subscriptionListDecom = [SELECT Id, SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__Account__c
                            , SBQQ__Contract__c, SBQQ__Contract__r.EndDate, SBQQ__StartDate__c
                            , SBQQ__EndDate__c, SBQQ__Quantity__c
                            , Subscribed_Asset_Count__c
                            , SBQQ__Product__r.Name, SBQQ__Product__r.Description
                            , SBQQ__NetPrice__c, Annual_Recurring_Revenue__c
                            , SBQQ__RevisedSubscription__c
                            FROM SBQQ__Subscription__c WHERE Id in :subscriptionListDecom];


        List<Customer_Asset__c> vistaAssetsDecom = [SELECT Id, Name, Account__c, Product__c, Description__c, Contract__c
                                                    , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                                                    , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c
                                                    FROM Customer_Asset__c WHERE Steelbrick_Subscription__c IN :subscriptionListDecom];



        // Check first record
        System.assertEquals(1, vistaAssets.size());

        Customer_Asset__c vaDecom = vistaAssets[0];
        vaDecom.Steelbrick_Subscription__c = subscriptionList[0].Id;
        vaDecom.Decommission_Effective_Date__c = System.today();
        update vaDecom;

        vaDecom = [SELECT Id, Name, Account__c, Product__c, Description__c, Contract__c
                   , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                   , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c
                   , Steelbrick_Subscription__r.SBQQ__Contract__c, Steelbrick_Subscription__r.SBQQ__StartDate__c
                   , Steelbrick_Subscription__r.SBQQ__EndDate__c, Steelbrick_Subscription__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c
                   , Steelbrick_Subscription__r.SBQQ__NetPrice__c, Steelbrick_Subscription__r.Annual_Recurring_Revenue__c
                   , Steelbrick_Subscription__r.CurrencyIsoCode
                   FROM Customer_Asset__c WHERE Id = :vaDecom.Id];

        Test.stopTest();
    }
}