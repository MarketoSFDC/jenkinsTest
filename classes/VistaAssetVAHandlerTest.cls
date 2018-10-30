/**
 * Test class for VistaAssetVAHandler.
 *
 * @author Advanced Technology Group (www.atginfo.com)
 * @see VistaAssetVAHandler
 */
@isTest
public class VistaAssetVAHandlerTest {

    /**
     * Holds an instance of VistaAssetHelperUtil class,
     * which provides helper methods such as insertion of test records.
     * @see VistaAssetHelperUtil
     */
    private static VistaAssetHelperUtil util = new VistaAssetHelperUtil();

    /**
     * Covers the creation of new Customer Assert scenario.
     * This test case covers the whole class functionality, since all class
     * code manages the Customer Asset creation after Salesforce Assets are created.
     */
    @isTest
    static void createNewAssetTest() {
        System.debug('VistaAssetVAHandlerTest.createNewAssetTest');
        
        // Insert a test account record
        Account account = util.createAccount('ABC Test Account');

        // Create a contact using the test account
        Contract msa = util.createContract(null, account, 'Customer - MSA', Date.today());

        // Create products and their correspondent pricebook entries
        List<Product2> productList = new List<Product2>();
        productList.addAll(util.initProductSet(2, 'Hardware', null));
        Map<Id, PricebookEntry> pricebookEntries = new Map<Id, PricebookEntry>();
        pricebookEntries = util.initPricebook(productList);

        // Create an opportunity
        Opportunity opportunity = util.createNewOpportunity('Test Opportunity 1', account, 'Products, Services and Maintenance', 'New');
        Test.startTest();

        // Create a Quote associated with the opportunity. Create quotes lines with the producs created before.
        SBQQ__Quote__c sbQuote = util.createSBQuote(opportunity, account, Date.today());
        List<SBQQ__Quoteline__c> sbQuoteLines = util.createSBQuoteLines(sbQuote, pricebookEntries, false, 2);

        // Create opportunity line items based on quote lines.
        List<OpportunityLineItem> opportunityLineItems = util.createOppLineItems(opportunity, sbQuoteLines, pricebookEntries);
        //opportunity = util.closeWonOpportunity(opportunity);

        // Create a contract related to the opportunity
        Contract contract = util.createContract(opportunity, account, 'SteelBrick CPQ Contract', Date.today());

        // Create Salesforce Assets starting from Quote Lines.
        List<Asset> assetList = new List<Asset>();
        for (SBQQ__QuoteLine__c ql : sbQuoteLines){
            Asset sfdcAsset = util.createSFDCAsset(ql, account);
            assetList.add(sfdcAsset);
        }

        // Retrieve all Customer Assets
        List<Customer_Asset__c> vistaVAAssets = [SELECT
                Id, Name, Name__c, Account__c, Product__c, Description__c, Contract__c
                , Term_Start_Date__c, Term_End_Date__c, Asset_Status__c, Quantity__c
                , Annual_Recurring_Revenue__c, Steelbrick_Subscription__c, Steelbrick_Asset__c
                , Total_One_Time_Fee_s__c, CurrencyIsoCode
                // subscribed asset fields
                , Steelbrick_Asset__r.SBQQ__CurrentSubscription__c, Steelbrick_Asset__r.Price
                // subscribed asset subscription fields
                , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.SBQQ__Quantity__c
                , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.SBQQ__NetPrice__c
                , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.CurrencyIsoCode
                , Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.Annual_Recurring_Revenue__c
                , Steelbrick_Asset__r.Quantity, Steelbrick_Asset__r.Annual_Recurring_Revenue__c
                , Steelbrick_Asset__r.CurrencyIsoCode
                , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c
                , Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveEndDate__c
                                                  FROM Customer_Asset__c WHERE Steelbrick_Asset__r.Id IN :assetList];

        // Check the amount of Customer Assets created.
        System.assertEquals(2, vistaVAAssets.size());
        System.debug('asset to update: ' + vistaVAAssets.get(0));

        // Check most relevant fields on Custom Asset
        for (Integer i = 0; i < vistaVAAssets.size(); i++) {
            Customer_Asset__c ca = vistaVAAssets[i];

            // Check associated account
            System.assertEquals(account.Id, ca.Account__c, 'Account Id is wrong on Customer Asset #' + i);

            // Find the SF asset related to the Custom Asset
            Asset asset;
            for(Asset a : assetList) {
                if (a.Id == ca.Steelbrick_Asset__c) {
                    asset = a;
                    break;
                }
            }
            System.assert(asset != null, 'No SF Asset has been found for Customer Asset #' + i);

            // Check most relevant Customer Asset fields
            System.assertEquals(asset.Product2.Name, ca.Name__c, 'Name is wrong on Customer Asset #' + i);
            System.assertEquals(asset.Product2.Description, ca.Description__c, 'Description is wrong on Customer Asset #' + i);
            System.assertEquals(asset.Contract__c, ca.Contract__c, 'Contract is wrong on Customer Asset #' + i);
            System.assertEquals(asset.CurrencyIsoCode, ca.CurrencyIsoCode, 'CurrencyIsoCode is wrong on Customer Asset #' + i);
            System.assertEquals('Active', ca.Asset_Status__c, 'Status is wrong on Customer Asset #' + i);
        }
        
        /* Process amendment */
Test.stopTest();
        // Create addon opportunity and quote records, for the same account using the same products and pricebook entries
     List<Product2> productListAddon = new List<Product2>(productList);
        Map<Id, PricebookEntry> pricebookEntriesAddon = new Map<Id, PricebookEntry>(pricebookEntries);
        Opportunity opportunityAddon = util.createNewOpportunity('Test Opportunity 1 Addon', account, 'Products, Services and Maintenance', 'New');
        SBQQ__Quote__c sbQuoteAddon = util.createSBQuote(opportunityAddon, account, Date.today());
        List<SBQQ__Quoteline__c> sbQuoteLinesAddon = util.createSBQuoteLines(sbQuoteAddon, pricebookEntriesAddon, true, 1);
        for(integer i = 0; i < sbQuoteLinesAddon.size(); i++) {
            sbQuoteLinesAddon[i].SBQQ__UpgradedAsset__c = assetList[i].Id;
        }
        update sbQuoteLinesAddon;
        
        List<OpportunityLineItem> opportunityLineItemsAddon = util.createOppLineItems(opportunityAddon, sbQuoteLinesAddon, pricebookEntriesAddon);
        //opportunityAddon = util.closeWonOpportunity(opportunityAddon);
        Contract contractAddon = util.createContract(opportunityAddon, account, 'SteelBrick CPQ Contract', Date.today());
        try {
            for (Integer i = 0; i < 1; i++) {
                Asset sfdcAsset = util.createSFDCAsset(sbQuoteLinesAddon[i], account, assetList[i].Id);
                break;
            }    
        } catch (exception e) {
            
        }

        
    }
}