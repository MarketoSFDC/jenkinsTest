public class OpportunityConfigurator {

    public List<OpportunityLineItemWrapper> lineItemWrappers { get ; set ;}
    public String editedField {get; set;}
    private ApexPages.StandardController controller;
    private Opportunity Opportunity;
    
    public OpportunityConfigurator(ApexPages.StandardController controller) {
        this.controller = controller;
        
        Opportunity = getOpportunity(controller.getId());
            
        lineItemWrappers = createWrappers(Opportunity);
    }
    
    public OpportunityConfigurator () {
        // just for testing
    }
    
    public void copyItem(){
        try {
            Integer i = Integer.valueOf(Apexpages.currentPage().getParameters().get('index'));
            lineItemWrappers.add(i+1, lineItemWrappers[i].cloneNew());
        } catch(Exception e) {
        }
        // refresh the records to ensure rules are adhered to
        saveLineItemsTemp();
    }

    public static OpportunityLineItemWrapper[] createWrappers(Opportunity Opportunity){
        List<OpportunityLineItemWrapper> lineItemWrappers = new List<OpportunityLineItemWrapper>();
        
        if (Opportunity.Pricebook2Id == null)
            return lineItemWrappers;
        
        // add our existing selected products
        
        Set<Id> seenProducts = new Set<Id>();
        for (OpportunityLineItem oli : getOpportunityLineItems(Opportunity.Id)) {
            lineItemWrappers.add(new OpportunityLineItemWrapper(oli, oli.PricebookEntry));
            seenProducts.add(oli.PricebookEntry.Id);
        }
        
        // then add any products that are not already selected
        
        for (PriceBookEntry pbe : getPricebookEntries(Opportunity)) {
            if (!seenProducts.contains(pbe.Id)) {
                lineItemWrappers.add(new OpportunityLineItemWrapper(
                    new OpportunityLineItem(
                        OpportunityId=Opportunity.Id,
                        PriceBookEntryId=pbe.Id,
                        //Quantity = 0,
                        UnitPrice = pbe.UnitPrice,
                        PricebookEntry = pbe
                    ), 
                    pbe
                ));
            }
        }
        
        return lineItemWrappers;
    }
    
    public void saveLineItemsTemp(){
        Savepoint sp = Database.setSavePoint();
       
        // save the ids we truely have so we can remove the ones that were made inside the transaction
        Set<Id> originalIds = new Set<Id>();
        for (OpportunityLineItemWrapper oppLineItemWrap:lineItemWrappers)
            if (oppLineItemWrap.oppLineItem.Id != NULL)
                originalIds.add(oppLineItemWrap.oppLineItem.Id);

        PageReference pr = saveLineItems();

        Opportunity = getOpportunity(Opportunity.Id);
        if (pr != null)
            resetWrappersAfterSave(originalIds, Opportunity, lineItemWrappers);
        Database.rollback(sp);
    }
    
    @TestVisible
    private static void resetWrappersAfterSave(Set<Id> originalIds, Opportunity Opportunity, OpportunityLineItemWrapper[] wrappers) {
        Map<Id,OpportunityLineItem> OpportunityLineItemMap = new Map<Id,OpportunityLineItem>(getOpportunityLineItems(Opportunity.Id));
       for(OpportunityLineItemWrapper oppLineItemWrap:wrappers){
           if (oppLineItemWrap.oppLineItem.Id != null){
                if (originalIds.contains(oppLineItemWrap.oppLineItem.Id)) {
                    oppLineItemWrap.oppLineItem = OpportunityLineItemMap.get(oppLineItemWrap.oppLineItem.Id).clone(true, false, false, false);
                } else {
                    oppLineItemWrap.oppLineItem = OpportunityLineItemMap.get(oppLineItemWrap.oppLineItem.Id).clone(false, false, false, false);
                    oppLineItemWrap.oppLineItem.OpportunityId = Opportunity.Id;
                }
           }
       }
    }
    
    public Pagereference saveLineItems(){
        Pagereference pageRef;
        try{
            controller.save();
            delete toDelete(lineItemWrappers);
            upsert fixUnitPriceTotalPriceConflict(toUpsert(editedField, lineItemWrappers));
            pageRef = new Pagereference('/'+Opportunity.Id);
        }
        catch(Exception e){
            Apexpages.addMessages(e);
        }
        
        return pageRef;       
    }
    
    // the sobjects used in the visualforce page cause oracle errors on upsert
    // this method queries for fresh objects and just writes the values that we want to update on the object
    @TestVisible
    private static OpportunityLineItem[] fixUnitPriceTotalPriceConflict(OpportunityLineItem[] lineItems) {

        Map<Id, OpportunityLineItem> originalLineItems = new Map<Id, OpportunityLineItem>([select id, unitprice, quantity from OpportunityLineItem where Id in :lineItems]);

        // only required on opportunities because quotes have a totalprice that is a formula
        for (Integer i=0; i<lineItems.size(); i++) {
            if (lineItems[i].Id == null) {
                // onchange tempsave can populate totalprice, but we can't insert with it since we insert with sales price
                if (lineItems[i].TotalPrice != null)
                    lineItems[i].TotalPrice = null;
            } else {
                OpportunityLineItem oli = lineItems[i];
                lineItems[i] = originalLineItems.get(lineItems[i].Id);
                // FIXME: use the fieldset
                lineItems[i].Quantity = oli.Quantity;
                lineItems[i].UnitPrice = oli.UnitPrice;
                lineItems[i].Users__c = oli.Users__c;
                lineItems[i].Months__c = oli.Months__c;
                lineItems[i].Discount = oli.Discount;
            }
        }
        return lineItems;
    }

    @TestVisible
    private static PricebookEntry[] getPricebookEntriesOverride;
    
    @TestVisible
    private static PricebookEntry[] getPricebookEntries(Opportunity Opportunity) {
        if (getPricebookEntriesOverride != null)
            return getPricebookEntriesOverride;
        String pricebookId = Opportunity.Pricebook2Id;
        String currencyIsoCode;
        String query =
        'SELECT Id, Product2.Name, UnitPrice, Product2.Description '+
        'FROM PricebookEntry '+
        'WHERE Pricebook2Id = :pricebookId '+
        'and IsActive = true '+
        'and Product2.IsActive = true ';
        if (multiCurrencyEnabled()) {
            currencyIsoCode = (String)Opportunity.get('CurrencyIsoCode');
            query += 'and CurrencyIsoCode = :currencyIsoCode ';
        }
        query += 'ORDER BY Product2.Name '+
        'limit 1000 '; // max collection size, we give a warning to the user if they are at 1,000
        return Database.query(query);
    }
    
    @TestVisible
    public static List<OpportunityLineItem> getOpportunityLineItemsOverride;
    @TestVisible
    private static List<OpportunityLineItem> getOpportunityLineItems(String id){
        if (getOpportunityLineItemsOverride != null)
           return getOpportunityLineItemsOverride;
        String queryStr = FieldSetDescriber.generateQueryFromFieldSets(
            'OpportunityLineItem',
            new Set<String>{'Opportunity_Configurator'}, 
            new Set<String>{
                'Quantity', 'UnitPrice', 'TotalPrice', 'Discount', 'PricebookEntryId',
                'PricebookEntry.Id', 'PricebookEntry.Product2.Name', 'PricebookEntry.UnitPrice', 
                'PricebookEntry.Product2.Description'
            },
            'OpportunityId=:id'
        );
        return Database.query(queryStr);
    }
    
    @TestVisible
    private static Opportunity getOpportunity(String id){
        Set<String> additionalFields = new Set<String>{'Pricebook2Id'};
        if (multiCurrencyEnabled())
           additionalFields.add('CurrencyIsoCode');
        String queryStr = FieldSetDescriber.generateQueryFromFieldSets(
            'Opportunity',
            new Set<String>{'Opportunity_Configurator'}, 
            additionalFields,
            'Id=:id'
        );
        return Database.query(queryStr);
    }
    
    public class OpportunityLineItemWrapper{
        public OpportunityLineItem oppLineItem { get ; set ;}
        public String productName { get ;private set ;}
        public String prouctDescription{get; private set;}
        
        public OpportunityLineItemWrapper(OpportunityLineItem oppLineItem, PriceBookEntry pbe){
            this.oppLineItem=oppLineItem;
            this.productName=pbe.Product2.Name;
            this.prouctDescription = pbe.Product2.Description;
        }
        
        public OpportunityLineItemWrapper(){
        
        }
        
        public OpportunityLineItemWrapper cloneNew() {
            OpportunityLineItemWrapper newObj = new OpportunityLineItemWrapper();
            newObj.productName = productName;
            newObj.prouctDescription = prouctDescription;
            newObj.oppLineItem = oppLineItem.clone(false,false,false);
            newObj.oppLineItem.Id = null;
            return newObj;
        }
    }
    
    @TestVisible
    private static OpportunityLineItem[] toUpsert(String editedField, OpportunityLineItemWrapper[] lineItemWrappers) {
        OpportunityLineItem[] result = new OpportunityLineItem[]{};
        for(OpportunityLineItemWrapper oppLineItemWrap:lineItemWrappers){
            if(oppLineItemWrap.oppLineItem.Quantity != 0 && oppLineItemWrap.oppLineItem.Quantity != null){
                result.add(oppLineItemWrap.oppLineItem);
            }
        }
        return result;
    }
    
    @TestVisible
    private static OpportunityLineItem[] toDelete(OpportunityLineItemWrapper[] lineItemWrappers) {
        OpportunityLineItem[] result = new OpportunityLineItem[]{};
        for(OpportunityLineItemWrapper oppLineItemWrap:lineItemWrappers){
            if((oppLineItemWrap.oppLineItem.Quantity == 0 || oppLineItemWrap.oppLineItem.Quantity == null) && oppLineItemWrap.oppLineItem.Id != null){
                result.add(oppLineItemWrap.oppLineItem);
            }
        }
        return result;
    }
    
    @TestVisible
    private static Boolean multiCurrencyEnabled;
    @TestVisible
    private static Boolean multiCurrencyEnabled() {
        if (multiCurrencyEnabled != null)
           return multiCurrencyEnabled;
        
        try {
            (new Opportunity()).get('CurrencyIsoCode');
            multiCurrencyEnabled = true;
        } catch(Exception e) {
            multiCurrencyEnabled = false;
        }
        
        return multiCurrencyEnabled;
    }
}