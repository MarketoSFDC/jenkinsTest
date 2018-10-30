/**
 * This class contains helper methods that are utilized across 
 * all the test classes related to Customer Assets.
 *
 * @author Advanced Technology Group (www.atginfo.com)
 */
@isTest
public class VistaAssetHelperUtil {

    /**
     * Default constructor for the class.
     */
    public VistaAssetHelperUtil() {
    }

    /**
     * Holds the Id of the Standard pricebook.
     */
    public Id pricebookId = Test.getStandardPricebookId();

    /**
     * Creates an Account record.
     * @param acctName Account name.
     * @return The Account record that was created.
     * @see Account
     */
    public Account createAccount(String acctName) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createAccount');
        Account account = new Account();
        account.Name = acctName;
        account.BillingCountry = 'USA';
        insert account;
        return account;
    }

    /**
     * Creates a 'Draft' Contract record for 12 months from the start date.
     * @param opportunity The Oportunity record related to the contract.
     * @param account The Account record related to the contract.
     * @param contractType The contract type.
     * @param startdate The contract start date.
     * @return The Contract record that was created.
     * @see Contract
     */
    public Contract createContract(Opportunity opportunity, Account account, String contractType, Date startdate) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createContract');
        Contract contract = new Contract();
        contract.AccountId = account.Id;
        contract.Status = 'Draft';
        contract.StartDate = startdate;
        contract.ContractTerm = 12;

        // Assign the opportunity to the contract only if it isn't a Master Agreement.
        if (contractType != 'Master Agreement' && opportunity != null) {
            contract.SBQQ__Opportunity__c = opportunity.Id;
        }

        insert contract;
        return contract;
    }

    /**
     * Creates a specific number of Product records, all of them with the same group and pricing type. 
     * @param numProducts Defines how many products to create.
     * @param productGroup It is only used in the name of the product, the description and the family.
     * @param subPricingType Defines the pricing and the subscription type.
     * @return List of products that were created.
     * @see Product2
     */
    public List<Product2> initProductSet(Integer numProducts, String productGroup, String subPricingType) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.initProductSet');
        // subPricingType = 'Fixed Price' or 'Percent Of Total'
        List<Product2> productList = new List<Product2>();

        for (Integer p = 0; p < numProducts; p++) {
            Product2 product = new Product2();
            product.ProductCode = 'product-' + p;
            product.Name = productGroup + ' Product ' + p;
            product.Description = productGroup + ' Product ' + p + ' Description';
            product.Family = productGroup + 'Family';
            product.Generate_Asset__c = true;
            product.IsActive = true;
            if (subPricingType != null) { // Generates Subscriptions
                if (subPricingType == 'Percent Of Total') { 
                    product.SBQQ__SubscriptionPricing__c = 'Percent Of Total';
                    product.SBQQ__SubscriptionPercent__c = 10;
                    product.SBQQ__SubscriptionBase__c = 'List';
                } else if (subPricingType == 'One Time') {
                    product.SBQQ__SubscriptionPricing__c = 'Fixed Price';
                    product.SBQQ__SubscriptionType__c = 'One-time';
                    product.SBQQ__SubscriptionTerm__c = 12;
                } else { // Generates Subscriptions
                    product.SBQQ__SubscriptionPricing__c = subPricingType;
                    product.SBQQ__SubscriptionType__c = 'Renewable';
                    product.SBQQ__SubscriptionTerm__c = 12;
                }
            } else { // Not subscriptions
                product.SBQQ__SubscriptionPricing__c = null;
                product.SBQQ__SubscriptionType__c = null;
            }

            product.SBQQ__QuantityEditable__c = true;
            product.SBQQ__IncludeInMaintenance__c = true;

            productList.add(product);
        }

        insert productList;
        return productList;
    }

    /**
     * Creates the Pricebook entries for the products included in the list passed as a parameter.
     * It uses the Standard pricebook. 
     * @param productList Products for which entries will be created.
     * @return Map with the ProductId as the key and the PricebookEntry as the value.
     */
    public Map<Id, PricebookEntry> initPricebook(List<Product2> productList) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.initPricebook');
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        List<PricebookEntry> pbInsertList = new List<PricebookEntry>();
        Integer pb = 0;
        while (pb < productList.size()) {
            PricebookEntry pbEntry = new PricebookEntry();
            pbEntry.Pricebook2Id = pricebookId;
            pbEntry.Product2Id = productList[pb].Id;
            pbEntry.UnitPrice = 500 * pb + 1;
            pbEntry.IsActive = true;
            pbInsertList.add(pbEntry);
            pricebookEntries.put(pbEntry.Product2Id, pbEntry);
            pb = pb + 1;
        }
        insert pbInsertList;
        return pricebookEntries;
    }

    /**
     * Creates an Opportunity record.
     * @param opportunityName Name of the opportunity.
     * @param account The account record related to the opportunity.
     * @param recordType Record type (not being used).
     * @param orderType Order type (not being used).
     * @return The opportunity record that was created.
     */
    public Opportunity createNewOpportunity(String opportunityName, Account account, String recordType, String orderType) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createNewOpportunity');
        Opportunity opportunity = new Opportunity();
        opportunity.Name = opportunityName;
        opportunity.StageName = '1 - Plan';
        opportunity.CloseDate = System.today();
        opportunity.AccountId = account.Id;
        opportunity.LeadSource = 'SEO';
        opportunity.Description = 'Opp Desc';
        insert opportunity;
        return opportunity;
    }

    /**
     * Creates a Quote record.
     * @param opportunity The opportunity record related to the Quote.
     * @param account The account record related to the opportunity.
     * @param startDate Start date of the quote.
     * @return The Quote record that was created.
     */
    public SBQQ__Quote__c createSBQuote(Opportunity opportunity, Account account, Date startDate) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createSBQuote');
        SBQQ__Quote__c quote = new SBQQ__Quote__c();
        quote.SBQQ__Account__c = account.Id;
        quote.SBQQ__Opportunity2__c = opportunity.Id;
        quote.SBQQ__Primary__c = false; 
        quote.SBQQ__StartDate__c = startDate;
        quote.SBQQ__SubscriptionTerm__c = 12;
        quote.SBQQ__Status__c = 'Approved';
        insert quote;

        /* Quote is turned to primary during the insertion, so since for testing purposes
         * we don't want to sync with the opportunity, we set it back as no-primary. */
        quote.SBQQ__Primary__c = false;
        update quote;

        return quote;
    }

    /**
     * Creates quote lines for a specific Quote record.
     * Create as many lines items as entries in the pricebookEntries map passed as parameter.
     * @param sbQuote The Quote record related to the line items.
     * @param pricebookEntries The pricebook entries. 
     * @param existing Indicates if quote lines are marked as existing.
     * @param quantityMultiplier Multiplier for quantity. Quantity = mutiplier * index.
     * @return List of inserted Quote lines.
     */
    public List<SBQQ__QuoteLine__c> createSBQuoteLines(SBQQ__Quote__c sbQuote
            , Map<Id, PricebookEntry> pricebookEntries
            , boolean existing
            , Integer quantityMultiplier) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createSBQuoteLines');
        List<SBQQ__QuoteLine__c> sbQuoteLines = new List<SBQQ__QuoteLine__c>();
        Integer q = 1;

        for (PricebookEntry pbEntry : pricebookEntries.values()) {
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c();
            quoteLine.SBQQ__Quote__c = sbQuote.Id;
            quoteLine.SBQQ__Product__c = pbEntry.Product2Id;
            quoteLine.SBQQ__Quantity__c = q * quantityMultiplier;
            quoteLine.SBQQ__Existing__c = existing;
            quoteLine.SBQQ__NetPrice__c = pbEntry.UnitPrice;
            quoteline.SBQQ__RenewedAsset__c = null;
            sbQuoteLines.add(quoteLine);
            q = q + 1;
        }
        insert sbQuoteLines;
        sbQuoteLines = [
                SELECT Id, SBQQ__Quote__c, SBQQ__Product__c, SBQQ__Quantity__c, SBQQ__Existing__c, SBQQ__NetPrice__c
                        , SBQQ__Product__r.SBQQ__SubscriptionPricing__c, SBQQ__Product__r.SBQQ__SubscriptionType__c
                        , SBQQ__RenewedAsset__c
                        , Annual_Recurring_Revenue__c, SBQQ__StartDate__c
                FROM SBQQ__QuoteLine__c
                WHERE Id in :sbQuoteLines
        ];
        return sbQuoteLines;
    }

    /**
     * Creates opportunity lines starting from quote lines list passed as parameter.
     * @param opportunity The opportunity record related to the lines that will be created.
     * @param quoteLines Quote lines to be 'copied'. 
     * @param pbEntries Pricebook entries related to the products in quote lines passed as parameters.
     * @return List of inserted Opportunity lines.
     */
    public List<OpportunityLineItem> createOppLineItems(Opportunity opportunity
            , List<SBQQ__Quoteline__c> quoteLines
            , Map<Id, PricebookEntry> pbEntries) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createOppLineItems');
        
        List<OpportunityLineItem> opportunityLineItems = new List<OpportunityLineItem>();
        
        for (SBQQ__Quoteline__c quoteLine : quoteLines) {
            OpportunityLineItem oli = new OpportunityLineItem();
            oli.SBQQ__QuoteLine__c = quoteLine.Id;
            oli.OpportunityId = opportunity.Id;
            
            if (quoteLine.SBQQ__Quantity__c == 0) {
                oli.Quantity = 1;
            } else {
                oli.Quantity = quoteLine.SBQQ__Quantity__c;
            }
            
            oli.TotalPrice = quoteLine.SBQQ__NetPrice__c;
            PricebookEntry pbe = pbEntries.get(quoteLine.SBQQ__Product__c);
            oli.PricebookEntryId = pbe.Id;
            opportunityLineItems.add(oli);
        }
        
        insert opportunityLineItems;
        opportunityLineItems = [
                SELECT Id, OpportunityId, ProductCode, SBQQ__QuoteLine__c, PricebookEntryId
                        , SBQQ__QuoteLine__r.SBQQ__Group__c
                        , SBQQ__QuoteLine__r.SBQQ__Group__r.SBQQ__Number__c, TotalPrice, Quantity
                        , SBQQ__QuoteLine__r.SBQQ__Group__r.Id, UnitPrice, ListPrice
                        , SBQQ__QuoteLine__r.SBQQ__Product__r.SBQQ__SubscriptionPricing__c
                        , SBQQ__QuoteLine__r.SBQQ__Product__r.SBQQ__SubscriptionType__c
                FROM OpportunityLineItem
                WHERE Id in :opportunityLineItems
        ];
        return opportunityLineItems;
    }

    /**
     * Sets the opportunity state to 'Close Won' and marks it as Contrated.
     * @param opportunity The opportunity record to be modified.
     * @return The opportunity record modified.
     */
    public Opportunity closeWonOpportunity(Opportunity opportunity) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.closeWonOpportunity');
        opportunity.StageName = 'Closed Won';
        opportunity.SBQQ__Contracted__c = true;
        update opportunity;
        return opportunity;
    }

    /**
     * Creates one Subscription for each quote line passed as parameter.
     * @param quoteLines Quote lines for subscriptions to be created.
     * @param contract Contract record related to the subscriptions. 
     * @param account Account record related to the subscriptions.
     * @param revisedSubId Id of the revised Subscription.
     * @return List of inserted Subscriptions.
     * @see SBQQ__Subscription__c
     */
    public List<SBQQ__Subscription__c> createSubscriptions(List<SBQQ__Quoteline__c> quoteLines
            , Contract contract
            , Account account
            , Id revisedSubId) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createSubscriptions');
        List<SBQQ__Subscription__c> subscriptionList = new List<SBQQ__Subscription__c>();
        
        for (SBQQ__Quoteline__c quoteLine : quoteLines) {
            System.debug(LoggingLevel.WARN, 'ql inside create subscr: ' + quoteLine.SBQQ__Product__r.SBQQ__SubscriptionPricing__c);
            
            if (quoteLine.SBQQ__Product__r.SBQQ__SubscriptionPricing__c != null) {
                
                SBQQ__Subscription__c sub = new SBQQ__Subscription__c();
                sub.SBQQ__Product__c = quoteLine.SBQQ__Product__c;
                
                if (quoteLine.SBQQ__Quantity__c == 0) {
                    sub.SBQQ__Quantity__c = 1;
                } else {
                    sub.SBQQ__Quantity__c = quoteLine.SBQQ__Quantity__c;
                }

                if (revisedSubId != null) {
                    sub.SBQQ__RevisedSubscription__c = revisedSubId;
                }

                sub.SBQQ__NetPrice__c = quoteLine.SBQQ__NetPrice__c;
                sub.Annual_Recurring_Revenue__c = quoteLine.Annual_Recurring_Revenue__c;
                sub.SBQQ__SubscriptionStartDate__c = quoteLine.SBQQ__StartDate__c;
                sub.SBQQ__Contract__c = contract.Id;
                sub.SBQQ__Contract__r = contract;
                sub.SBQQ__Account__c = account.Id;
                sub.SBQQ__QuoteLine__c = quoteLine.Id;
                subscriptionList.add(sub);
            }
        }

        insert subscriptionList;
        subscriptionList = [
                SELECT Id, SBQQ__Product__c, SBQQ__ProductName__c, SBQQ__Account__c
                        , SBQQ__Contract__c, SBQQ__Contract__r.EndDate, SBQQ__StartDate__c
                        , SBQQ__EndDate__c, SBQQ__Quantity__c, SBQQ__QuoteLine__c
                        , Subscribed_Asset_Count__c
                        , SBQQ__Product__r.Name, SBQQ__Product__r.Description
                        , SBQQ__NetPrice__c, Annual_Recurring_Revenue__c
                        , SBQQ__RevisedSubscription__c
                        , SBQQ__QuoteLine__r.Id, SBQQ__QuoteLine__r.SBQQ__Existing__c
                        , SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c, SBQQ__QuoteLine__r.SBQQ__Quantity__c
                FROM SBQQ__Subscription__c
                WHERE Id IN :subscriptionList
        ];
        System.debug(LoggingLevel.WARN, 'subscriptionList1: ' + subscriptionList);
        return subscriptionList;
    }

    /**
     * Creates an Salesforce Asset starting from a Quote line.
     * @param quoteLine Quote line related to the asset.
     * @param account Account record related to the asset. 
     * @return The Asset record that was created.
     * @see Asset
     */
    public Asset createSFDCAsset(SBQQ__Quoteline__c quoteLine, Account account) {
        return createSFDCAsset(quoteLine, account, null);
    }

    /**
     * Creates an Salesforce Asset starting from a Quote line.
     * @param quoteLine Quote line related to the asset.
     * @param account Account record related to the asset.
     * @param revisedId Id of revised Asset.
     * @return The Asset record that was created.
     * @see Asset
     */
  public Asset createSFDCAsset(SBQQ__Quoteline__c quoteLine, Account account, Id revisedId) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createSFDCAsset');
        Product2 product = [SELECT Id, Name, Description FROM Product2 WHERE Id = :quoteLine.SBQQ__Product__c];
        Asset newAsset = new Asset();
        newAsset.SBQQ__RevisedAsset__c = revisedId;
        newAsset.AccountId = account.Id;
        newAsset.Name = product.Name;
        newAsset.Product2Id = quoteLine.SBQQ__Product__c;
        newAsset.Price = quoteLine.SBQQ__NetPrice__c;
        newAsset.Quantity = quoteLine.SBQQ__Quantity__c;
        newAsset.SBQQ__QuoteLine__c = quoteLine.Id;
        newAsset.SBQQ__LatestQuoteLine__c = quoteLine.Id;

        insert newAsset;

        newAsset = [
                SELECT Id, AccountId, Name, Product2Id, Price, Quantity, CurrencyIsoCode
                        , Product2.Name, Product2.Description, Contract__c 
                        , SBQQ__QuoteLine__c, SBQQ__QuoteLine__r.SBQQ__Quantity__c
                        , SBQQ__LatestQuoteLine__r.SBQQ__RenewedAsset__c
                FROM Asset
                WHERE Id = :newAsset.Id
        ];

        return newAsset;
    }

    /**
     * Creates a CPQ Subscribed Asset record.
     * @param active Indicates whether the record is active or not.
     * @param sfdcAsset Related Asset records.
     * @param subscription Related subscription Record.
     * @return The Subscribed Asset that was created.
     * @see SBQQ__SubscribedAsset__c
     */
    public SBQQ__SubscribedAsset__c createSubscribedAsset(Boolean active, Asset sfdcAsset, SBQQ__Subscription__c subscription) {
        System.debug(LoggingLevel.WARN, 'VistaAssetHelperUtil.createSubscribedAsset');
        SBQQ__SubscribedAsset__c sbSubAsset = new SBQQ__SubscribedAsset__c();
        sbSubAsset.SBQQ__Active__c = active;
        sbSubAsset.SBQQ__Asset__c = sfdcAsset.Id;
        sbSubAsset.SBQQ__Subscription__c = subscription.Id;
        insert sbSubAsset;
        sbSubAsset = [
                SELECT Id
                        , SBQQ__Active__c, SBQQ__Asset__c, SBQQ__ContractId__c, SBQQ__Subscription__c
                        , SBQQ__Asset__r.AccountId, SBQQ__Asset__r.Contract__c
                        , SBQQ__Asset__r.SBQQ__RevisedAsset__c
                        , SBQQ__Asset__r.Price, SBQQ__Asset__r.Annual_Recurring_Revenue__c
                        , SBQQ__Asset__r.Product2Id, SBQQ__Asset__r.Product2.Name
                        , SBQQ__Asset__r.Product2.Description, SBQQ__Asset__r.Product2.Generate_Asset__c
                        , SBQQ__Subscription__r.SBQQ__RevisedSubscription__c, SBQQ__Subscription__r.CurrencyIsoCode
                        , SBQQ__Subscription__r.Subscribed_Asset_Count__c
                        , SBQQ__Subscription__r.SBQQ__NetPrice__c
                        , SBQQ__Subscription__r.SBQQ__StartDate__c, SBQQ__Subscription__r.SBQQ__EndDate__c
                        , SBQQ__Asset__r.SBQQ__QuoteLine__c
                        , SBQQ__Asset__r.SBQQ__QuoteLine__r.Id, SBQQ__Asset__r.SBQQ__QuoteLine__r.SBQQ__Existing__c
                        , SBQQ__Asset__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c, SBQQ__Asset__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c
                        , SBQQ__Asset__r.Contract__r.StartDate, SBQQ__Asset__r.Contract__r.EndDate
                FROM SBQQ__SubscribedAsset__c
                WHERE Id = :sbSubAsset.Id
        ];
        return sbSubAsset;
    }

}