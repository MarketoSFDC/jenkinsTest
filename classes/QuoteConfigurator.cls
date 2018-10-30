public class QuoteConfigurator {

    public List<QuoteLineItemWrapper> lineItemWrappers { get ; set ;}
    public String editedField {get; set;}
    private ApexPages.StandardController controller;
    private Quote quote;
    
    public QuoteConfigurator(ApexPages.StandardController controller) {
        this.controller = controller;
        
        quote = getQuote(controller.getId());
            
        lineItemWrappers = createWrappers(quote);
    }
    
    public QuoteConfigurator () {
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

    public static QuoteLineItemWrapper[] createWrappers(Quote quote){
        List<QuoteLineItemWrapper> lineItemWrappers = new List<QuoteLineItemWrapper>();
        
        if (quote.Pricebook2Id == null)
            return lineItemWrappers;
        
        // add our existing selected products
        
        Set<Id> seenProducts = new Set<Id>();
        for (QuoteLineItem oli : getQuoteLineItems(quote.Id)) {
            lineItemWrappers.add(new QuoteLineItemWrapper(oli, oli.PricebookEntry));
            seenProducts.add(oli.PricebookEntry.Id);
        }
        
        // then add any products that are not already selected
        
        for (PriceBookEntry pbe : getPricebookEntries(quote)) {
            if (!seenProducts.contains(pbe.Id)) {
                lineItemWrappers.add(new QuoteLineItemWrapper(
                    new QuoteLineItem(
                        QuoteId=quote.Id,
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
        for (QuoteLineItemWrapper oppLineItemWrap:lineItemWrappers)
            if (oppLineItemWrap.oppLineItem.Id != NULL)
                originalIds.add(oppLineItemWrap.oppLineItem.Id);

        PageReference pr = saveLineItems();

        quote = getQuote(quote.Id);
        if (pr != null)
            resetWrappersAfterSave(originalIds, quote, lineItemWrappers);
        Database.rollback(sp);
    }
    
    @TestVisible
    private static void resetWrappersAfterSave(Set<Id> originalIds, Quote quote, QuoteLineItemWrapper[] wrappers) {
        Map<Id,QuoteLineItem> QuoteLineItemMap = new Map<Id,QuoteLineItem>(getQuoteLineItems(quote.Id));
       for(QuoteLineItemWrapper oppLineItemWrap:wrappers){
           if (oppLineItemWrap.oppLineItem.Id != null){
                if (originalIds.contains(oppLineItemWrap.oppLineItem.Id)) {
                    oppLineItemWrap.oppLineItem = QuoteLineItemMap.get(oppLineItemWrap.oppLineItem.Id).clone(true, false, false, false);
                } else {
                    oppLineItemWrap.oppLineItem = QuoteLineItemMap.get(oppLineItemWrap.oppLineItem.Id).clone(false, false, false, false);
                    oppLineItemWrap.oppLineItem.QuoteId = quote.Id;
                }
           }
       }
    }
    
    public Pagereference saveLineItems(){
        Pagereference pageRef;
        try{
            controller.save();
            
            List<QuoteLineItem> lstLineItems = toUpsert(editedField, lineItemWrappers);
            List<QuoteLineItem> lstLineItemsToDel = toDelete(lineItemWrappers);
    
            if(!lstLineItemsToDel.isEmpty()){
                DELETE lstLineItemsToDel;
            }
    
            if(!lstLineItems.isEmpty()){
                UPSERT lstLineItems;
            }
            pageRef = new Pagereference('/'+quote.Id);
        }
        catch(Exception e){
            Apexpages.addMessages(e);
        }
        
        return pageRef;       
    }

    public PageReference saveAndClone() {
        if (saveLineItems() != null) {
            return copy();
        }
        return null;
    }

    private PageReference copy() {
        PageReference pr;
        Savepoint sp = Database.setSavePoint();
        try {
            Quote newQuote = quote.clone(false, true);
            newQuote.Name += ' Clone';
            insert newQuote;
            QuoteLineItem[] newLineItems = new QuoteLineItem[]{};
            for (QuoteLineItem i : getQuoteLineItems(quote.Id)) {
                QuoteLineItem iClone = i.clone(false, true);
                iClone.QuoteId = newQuote.Id;
                newLineItems.add(iClone);
            }
            insert newLineItems;
            pr = Page.QuoteConfigurator;
            pr.getParameters().put('id', newQuote.Id);
            pr.setRedirect(true);
        } catch (Exception e) {
            ApexPages.addMessages(e);
            Database.rollback(sp);
        }
        return pr;
    }
    
    @TestVisible
    private static PricebookEntry[] getPricebookEntriesOverride;
    
    @TestVisible
    private static PricebookEntry[] getPricebookEntries(Quote quote) {
        if (getPricebookEntriesOverride != null)
            return getPricebookEntriesOverride;
        String pricebookId = quote.Pricebook2Id;
        String currencyIsoCode;
        String query =
        'SELECT Id, Product2.Name, UnitPrice, Product2.Description '+
        'FROM PricebookEntry '+
        'WHERE Pricebook2Id = :pricebookId '+
        'and IsActive = true '+
        'and Product2.IsActive = true ';
        if (multiCurrencyEnabled()) {
            currencyIsoCode = (String)quote.get('CurrencyIsoCode');
            query += 'and CurrencyIsoCode = :currencyIsoCode ';
        }
        query += 'ORDER BY Product2.Name '+
        'limit 1000 '; // max collection size, we give a warning to the user if they are at 1,000
        return Database.query(query);
    }
    
    @TestVisible
    public static List<QuoteLineItem> getQuoteLineItemsOverride;
    @TestVisible
    private static List<QuoteLineItem> getQuoteLineItems(String id){
        if (getQuoteLineItemsOverride != null)
           return getQuoteLineItemsOverride;
        String queryStr = FieldSetDescriber.generateQueryFromFieldSets(
            'QuoteLineItem',
            new Set<String>{'Quote_Configurator'}, 
            new Set<String>{
                'Quantity', 'UnitPrice', 'TotalPrice', 'Discount', 'PricebookEntryId',
                'PricebookEntry.Id', 'PricebookEntry.Product2.Name', 'PricebookEntry.UnitPrice', 
                'PricebookEntry.Product2.Description'
            },
            'QuoteId=:id'
        );
        return Database.query(queryStr);
    }
    
    @TestVisible
    private static Quote getQuote(String id){
        Set<String> additionalFields = new Set<String>{'Pricebook2Id'};
        if (multiCurrencyEnabled())
           additionalFields.add('CurrencyIsoCode');
        String queryStr = FieldSetDescriber.generateQueryFromFieldSets(
            'Quote',
            new Set<String>{'Quote_Configurator'}, 
            additionalFields,
            'Id=:id'
        );
        return Database.query(queryStr);
    }
    
    public class QuoteLineItemWrapper{
        public QuoteLineItem oppLineItem { get ; set ;}
        public String productName { get ;private set ;}
        public String prouctDescription{get; private set;}
        
        public QuoteLineItemWrapper(QuoteLineItem oppLineItem, PriceBookEntry pbe){
            this.oppLineItem=oppLineItem;
            this.productName=pbe.Product2.Name;
            this.prouctDescription = pbe.Product2.Description;
        }
        
        public QuoteLineItemWrapper(){
        
        }
        
        public QuoteLineItemWrapper cloneNew() {
            QuoteLineItemWrapper newObj = new QuoteLineItemWrapper();
            newObj.productName = productName;
            newObj.prouctDescription = prouctDescription;
            newObj.oppLineItem = oppLineItem.clone(false,false,false);
            newObj.oppLineItem.Id = null;
            return newObj;
        }
    }
    
    @TestVisible
    private static QuoteLineItem[] toUpsert(String editedField, QuoteLineItemWrapper[] lineItemWrappers) {
        QuoteLineItem[] result = new QuoteLineItem[]{};
        for(QuoteLineItemWrapper oppLineItemWrap:lineItemWrappers){
            if(oppLineItemWrap.oppLineItem.Quantity != 0 && oppLineItemWrap.oppLineItem.Quantity != null){
                result.add(oppLineItemWrap.oppLineItem);
            }
        }
        return result;
    }
    
    @TestVisible
    private static QuoteLineItem[] toDelete(QuoteLineItemWrapper[] lineItemWrappers) {
        QuoteLineItem[] result = new QuoteLineItem[]{};
        for(QuoteLineItemWrapper oppLineItemWrap:lineItemWrappers){
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
            (new Quote()).get('CurrencyIsoCode');
            multiCurrencyEnabled = true;
        } catch(Exception e) {
            multiCurrencyEnabled = false;
        }
        
        return multiCurrencyEnabled;
    }
}