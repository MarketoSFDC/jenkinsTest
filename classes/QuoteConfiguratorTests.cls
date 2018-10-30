@isTest
private class QuoteConfiguratorTests {

    @isTest static void toDeleteShouldNotFindNewRecords() {
        QuoteConfigurator.QuoteLineItemWrapper[] wrappers = new QuoteConfigurator.QuoteLineItemWrapper[]{
            new QuoteConfigurator.QuoteLineItemWrapper(new QuoteLineItem(), new PricebookEntry())
        };
        System.assertEquals(0, QuoteConfigurator.toDelete(wrappers).size());
    }
    
    @isTest static void toDeleteShouldFindDeleted() {
        QuoteConfigurator.QuoteLineItemWrapper[] wrappers = new QuoteConfigurator.QuoteLineItemWrapper[]{
            new QuoteConfigurator.QuoteLineItemWrapper(new QuoteLineItem(Id='0QLF00000000000', Quantity=0), new PricebookEntry())
        };
        System.assertEquals(1, QuoteConfigurator.toDelete(wrappers).size());
    }
    
    @isTest static void toUpsertShouldOnlyFindRecordsWithQuantity() {
    	QuoteConfigurator.QuoteLineItemWrapper[] wrappers = new QuoteConfigurator.QuoteLineItemWrapper[]{
            new QuoteConfigurator.QuoteLineItemWrapper(new QuoteLineItem(Id='0QLF00000000000', Quantity=0), new PricebookEntry()),
            new QuoteConfigurator.QuoteLineItemWrapper(new QuoteLineItem(Id='0QLF00000000000', Quantity=1), new PricebookEntry())
        };
        System.assertEquals(1, QuoteConfigurator.toUpsert('Quantity', wrappers).size());
    }
    
    @isTest static void getQuoteShouldFailWithoutId() {
    	try {
    	   QuoteConfigurator.getQuote(null);
    	   System.assert(false, 'should have thrown exception');
    	} catch (Exception e) {
    	}
    }
    
    @isTest static void getQuoteLineItemsShouldReturnNoRecordsWithoutId() {
        System.assertEquals(0, QuoteConfigurator.getQuoteLineItems(null).size());
    }
	
	@isTest static void generatedGettersShouldNotCountAgainstCoveragePercentage () {
		// just having used the constructor, the getters and setters don't count against your code coverage %
		QuoteConfigurator controller = new QuoteConfigurator();
	}
	
    @isTest static void getPricebookEntriesShouldSucceed() {
        QuoteConfigurator.getPricebookEntries(new Quote(Pricebook2Id='01sF0000000UFsa'));
    }
    
    @isTest static void resetWrappersAfterSaveShouldReloadFromDatabase() {
    	QuoteConfigurator.getQuoteLineItemsOverride = new List<QuoteLineItem>{
    	   new QuoteLineItem(Id='0QLF00000000000', Quantity=1),
    	   new QuoteLineItem(Id='0QLF00000000001', Quantity=1)
    	};
    	QuoteConfigurator.QuoteLineItemWrapper[] wrappers = new QuoteConfigurator.QuoteLineItemWrapper[]{
            new QuoteConfigurator.QuoteLineItemWrapper(new QuoteLineItem(Id='0QLF00000000000', Quantity=0), new PricebookEntry()),
            new QuoteConfigurator.QuoteLineItemWrapper(new QuoteLineItem(Id='0QLF00000000001', Quantity=1), new PricebookEntry())
        };
        QuoteConfigurator.resetWrappersAfterSave(new Set<Id>(), new Quote(), wrappers);
        System.assertEquals(1, wrappers[0].oppLineItem.Quantity);
        System.assertEquals(1, wrappers[1].oppLineItem.Quantity);
    }
    
    @isTest static void multiCurrencyEnabledShouldUseCachedValue() {
    	QuoteConfigurator.multiCurrencyEnabled();
    	// reverse the cached value and try again to make sure the cache is used
    	QuoteConfigurator.multiCurrencyEnabled = QuoteConfigurator.multiCurrencyEnabled != true;
    	System.assertEquals(QuoteConfigurator.multiCurrencyEnabled, QuoteConfigurator.multiCurrencyEnabled());
    }
    
    @isTest static void QuoteLineItemWrapperCloneShouldHaveNewLineItem() {
    	QuoteConfigurator.QuoteLineItemWrapper w = new QuoteConfigurator.QuoteLineItemWrapper(new QuoteLineItem(Id='0QLF00000000001', Quantity=0), new PricebookEntry());
    	QuoteConfigurator.QuoteLineItemWrapper w2 = w.cloneNew();
    	System.assertNotEquals(w.oppLineItem.Id, w2.oppLineItem.Id);
    }
    
    @isTest static void createWrappersShouldWrap2ExistingProductOfSameKind() {
    	// TODO should refactor object generation into helpers
    	QuoteConfigurator.getQuoteLineItemsOverride = new List<QuoteLineItem>{
            new QuoteLineItem(
                Id='0QLF00000000000', 
                Quantity=1, 
                PricebookEntry = new PricebookEntry(
                    Product2 = new Product2(Name='test')
                ) 
            ),
            new QuoteLineItem(
                Id='0QLF00000000001', 
                Quantity=1, 
                PricebookEntry = new PricebookEntry(
                    Product2 = new Product2(Name='test')
                ) 
            )
        };
    	QuoteConfigurator.QuoteLineItemWrapper[] wrappers = QuoteConfigurator.createWrappers(new Quote(Pricebook2Id='01sF0000000UFsa'));
    	System.assertEquals(2, wrappers.size());
    }
    
    @isTest static void createWrappersShouldMakeNewRow() {
        QuoteConfigurator.getPricebookEntriesOverride = new PricebookEntry[]{
        	new PricebookEntry(
        	   Product2 = new Product2(
        	       Name = 'test'
        	   )
        	)
        };        
        QuoteConfigurator.QuoteLineItemWrapper[] wrappers = QuoteConfigurator.createWrappers(new Quote(Pricebook2Id='01sF0000000UFsa'));
        System.assertEquals(1, wrappers.size());
    }
    
    @isTest static void createWrappersShouldNotErrorOnNoPricebookSelected() {
        QuoteConfigurator.QuoteLineItemWrapper[] wrappers = QuoteConfigurator.createWrappers(new Quote());
        System.assertEquals(0, wrappers.size());
    }
    
    @isTest(seeAllData=true) static void initShouldNotFail() {
        // try to test with real quote if we can
        Quote quote;
        for (Quote q : [select Id from Quote where LineItemCount>0 limit 1])
            quote = q;
        if (quote == null)
            return;
        ApexPages.StandardController standardController = new ApexPages.StandardController(quote);
        QuoteConfigurator controller = new QuoteConfigurator(standardController);
    }
    
    @isTest(seeAllData=true) static void saveLineItemsTempShouldNotThrowException() {
    	Quote quote;
        for (Quote q : [select Id from Quote where LineItemCount>0 limit 1])
            quote = q;
        if (quote == null)
            return;
    	ApexPages.StandardController standardController = new ApexPages.StandardController(quote);
        QuoteConfigurator controller = new QuoteConfigurator(standardController);
        controller.saveLineItemsTemp();
    }
    
}