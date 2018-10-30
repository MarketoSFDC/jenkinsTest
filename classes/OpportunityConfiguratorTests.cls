@isTest
private class OpportunityConfiguratorTests {
    
    private static String lineItemId1 = '00kF000000NyjrN';
    private static String lineItemId2 = '00kF000000NyjrO';
    private static String lineItemId3 = '00kF000000NyjrP';
    
    @isTest static void toDeleteShouldNotFindNewRecords() {
        OpportunityConfigurator.OpportunityLineItemWrapper[] wrappers = new OpportunityConfigurator.OpportunityLineItemWrapper[]{
            new OpportunityConfigurator.OpportunityLineItemWrapper(new OpportunityLineItem(), new PricebookEntry())
        };
        System.assertEquals(0, OpportunityConfigurator.toDelete(wrappers).size());
    }
    
    @isTest static void toDeleteShouldFindDeleted() {
        OpportunityConfigurator.OpportunityLineItemWrapper[] wrappers = new OpportunityConfigurator.OpportunityLineItemWrapper[]{
            new OpportunityConfigurator.OpportunityLineItemWrapper(new OpportunityLineItem(Id=lineItemId1, Quantity=0), new PricebookEntry())
        };
        System.assertEquals(1, OpportunityConfigurator.toDelete(wrappers).size());
    }
    
    @isTest static void toUpsertShouldOnlyFindRecordsWithQuantity() {
        OpportunityConfigurator.OpportunityLineItemWrapper[] wrappers = new OpportunityConfigurator.OpportunityLineItemWrapper[]{
            new OpportunityConfigurator.OpportunityLineItemWrapper(new OpportunityLineItem(Id=lineItemId1, Quantity=0), new PricebookEntry()),
            new OpportunityConfigurator.OpportunityLineItemWrapper(new OpportunityLineItem(Id=lineItemId1, Quantity=1), new PricebookEntry())
        };
        System.assertEquals(1, OpportunityConfigurator.toUpsert('Quantity', wrappers).size());
    }
    
    @isTest static void getOpportunityShouldFailWithoutId() {
        try {
           OpportunityConfigurator.getOpportunity(null);
           System.assert(false, 'should have thrown exception');
        } catch (Exception e) {
        }
    }
    
    @isTest static void getOpportunityLineItemsShouldReturnNoRecordsWithoutId() {
        System.assertEquals(0, OpportunityConfigurator.getOpportunityLineItems(null).size());
    }
    
    @isTest static void generatedGettersShouldNotCountAgainstCoveragePercentage () {
        // just having used the constructor, the getters and setters don't count against your code coverage %
        OpportunityConfigurator controller = new OpportunityConfigurator();
    }
    
    @isTest static void getPricebookEntriesShouldSucceed() {
        OpportunityConfigurator.getPricebookEntries(new Opportunity(Pricebook2Id='01sF0000000UFsa'));
    }
    
    @isTest static void resetWrappersAfterSaveShouldReloadFromDatabase() {
        OpportunityConfigurator.getOpportunityLineItemsOverride = new List<OpportunityLineItem>{
           new OpportunityLineItem(Id=lineItemId1, Quantity=1),
           new OpportunityLineItem(Id=lineItemId2, Quantity=1)
        };
        OpportunityConfigurator.OpportunityLineItemWrapper[] wrappers = new OpportunityConfigurator.OpportunityLineItemWrapper[]{
            new OpportunityConfigurator.OpportunityLineItemWrapper(new OpportunityLineItem(Id=lineItemId1, Quantity=0), new PricebookEntry()),
            new OpportunityConfigurator.OpportunityLineItemWrapper(new OpportunityLineItem(Id=lineItemId2, Quantity=1), new PricebookEntry())
        };
        OpportunityConfigurator.resetWrappersAfterSave(new Set<Id>(), new Opportunity(), wrappers);
        System.assertEquals(1, wrappers[0].oppLineItem.Quantity);
        System.assertEquals(1, wrappers[1].oppLineItem.Quantity);
    }
    
    @isTest static void multiCurrencyEnabledShouldUseCachedValue() {
        OpportunityConfigurator.multiCurrencyEnabled();
        // reverse the cached value and try again to make sure the cache is used
        OpportunityConfigurator.multiCurrencyEnabled = OpportunityConfigurator.multiCurrencyEnabled != true;
        System.assertEquals(OpportunityConfigurator.multiCurrencyEnabled, OpportunityConfigurator.multiCurrencyEnabled());
    }
    
    @isTest static void OpportunityLineItemWrapperCloneShouldHaveNewLineItem() {
        OpportunityConfigurator.OpportunityLineItemWrapper w = new OpportunityConfigurator.OpportunityLineItemWrapper(new OpportunityLineItem(Id=lineItemId1, Quantity=0), new PricebookEntry());
        OpportunityConfigurator.OpportunityLineItemWrapper w2 = w.cloneNew();
        System.assertNotEquals(w.oppLineItem.Id, w2.oppLineItem.Id);
    }
    
    @isTest static void createWrappersShouldWrap2ExistingProductOfSameKind() {
        // TODO should refactor object generation into helpers
        OpportunityConfigurator.getOpportunityLineItemsOverride = new List<OpportunityLineItem>{
            new OpportunityLineItem(
                Id=lineItemId1, 
                Quantity=1, 
                PricebookEntry = new PricebookEntry(
                    Product2 = new Product2(Name='test')
                ) 
            ),
            new OpportunityLineItem(
                Id=lineItemId2, 
                Quantity=1, 
                PricebookEntry = new PricebookEntry(
                    Product2 = new Product2(Name='test')
                ) 
            )
        };
        OpportunityConfigurator.OpportunityLineItemWrapper[] wrappers = OpportunityConfigurator.createWrappers(new Opportunity(Pricebook2Id='01sF0000000UFsa'));
        System.assertEquals(2, wrappers.size());
    }
    
    @isTest static void createWrappersShouldMakeNewRow() {
        OpportunityConfigurator.getPricebookEntriesOverride = new PricebookEntry[]{
            new PricebookEntry(
               Product2 = new Product2(
                   Name = 'test'
               )
            )
        };        
        OpportunityConfigurator.OpportunityLineItemWrapper[] wrappers = OpportunityConfigurator.createWrappers(new Opportunity(Pricebook2Id='01sF0000000UFsa'));
        System.assertEquals(1, wrappers.size());
    }
    
    @isTest static void createWrappersShouldNotErrorOnNoPricebookSelected() {
        OpportunityConfigurator.OpportunityLineItemWrapper[] wrappers = OpportunityConfigurator.createWrappers(new Opportunity());
        System.assertEquals(0, wrappers.size());
    }
    
    /*
    @isTest(seeAllData=true) static void initShouldNotFail() {
        // try to test with real opportunity if we can
        Opportunity opportunity;
        for (Opportunity q : [select Id from Opportunity where HasOpportunityLineItem=true limit 1])
            opportunity = q;
        if (opportunity == null)
            return;
        ApexPages.StandardController standardController = new ApexPages.StandardController(opportunity);
        OpportunityConfigurator controller = new OpportunityConfigurator(standardController);
    }
    
    
    @isTest(seeAllData=true) static void saveLineItemsTempShouldNotThrowException() {
        Opportunity opportunity;
        for (Opportunity q : [select Id from Opportunity where HasOpportunityLineItem=true limit 1])
            opportunity = q;
        if (opportunity == null)
            return;
        ApexPages.StandardController standardController = new ApexPages.StandardController(opportunity);
        OpportunityConfigurator controller = new OpportunityConfigurator(standardController);
        controller.saveLineItemsTemp();
    }
    */
    
     static void doubleSaveShouldNotError() {
       /* Opportunity testOpportunity = [
            select Id 
            from Opportunity 
            where HasOpportunityLineItem=true 
            and Pricebook2Id ='01s50000000MW4MAAW'
            and Pricebook2.IsActive = true
            limit 1
        ];
        */
        //updateOpportunityBasedOnCriteria.isFromTriggerCloneOppBasedonCriteria = true;
        Account a = Utility.insertAccountInTestClasses();
        insert a;
        Opportunity testOpportunity = Utility.insertOpportunityInTestClasses(a.id, null, 'Discovery', 'New Business',Date.Today(), system.today().addDays(1),system.today().addDays(7), null);   
        testOpportunity.Pricebook2Id = '01s50000000MW4MAAW';
        testOpportunity.Assets_created_on_closed_Won__c=true;
        insert testOpportunity ;
        Product2 p = new Product2(Name = 'test pro', IsActive = true, ConvertTo__c = 'Subscription', ProductCode = 'abc');
        insert p;
        PriceBookEntry Pe = new PriceBookEntry(IsActive = true, PriceBook2Id = '01s50000000MW4MAAW', Product2Id = p.id, UnitPrice = 200);
        insert pe;
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Users__c = 1;
        oli.MLM_Edition__c = 'test edition';
        oli.OpportunityId = testOpportunity.Id;
        oli.PricebookEntryId = pe.Id;
        oli.Instance_Number__c = 123;
        oli.Quantity = 5;
        oli.UnitPrice = 200;
        insert oli;
        
        OpportunityConfigurator controller = new OpportunityConfigurator(new ApexPages.StandardController(testOpportunity));
        
        controller.lineItemWrappers[0].oppLineItem.Quantity = controller.lineItemWrappers[0].oppLineItem.Quantity + 1;
        controller.editedField = 'Quantity';
        controller.saveLineItemsTemp();
        
        controller.lineItemWrappers[0].oppLineItem.UnitPrice = controller.lineItemWrappers[0].oppLineItem.UnitPrice + 1;
        controller.editedField = 'UnitPrice';
        controller.saveLineItemsTemp();
        
        controller.saveLineItems();
        /*
        controller.lineItemWrappers[0].oppLineItem.Quantity = controller.lineItemWrappers[0].oppLineItem.Quantity + 1;
        controller.editedField = 'Quantity';
        controller.saveLineItemsTemp();
        
        
        controller.lineItemWrappers[0].oppLineItem.UnitPrice = controller.lineItemWrappers[0].oppLineItem.UnitPrice + 1;
        controller.editedField = 'UnitPrice';
        controller.saveLineItemsTemp();

        controller.lineItemWrappers[0].oppLineItem.Quantity = controller.lineItemWrappers[0].oppLineItem.Quantity + 1;
        controller.editedField = 'Quantity';
        controller.saveLineItemsTemp();

        controller.lineItemWrappers[0].oppLineItem.UnitPrice = controller.lineItemWrappers[0].oppLineItem.UnitPrice + 1;
        controller.editedField = 'UnitPrice';
        controller.saveLineItemsTemp();
        */        
    }
    
}