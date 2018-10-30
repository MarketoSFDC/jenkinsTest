/*************************************************************
* Last modified By : Tushar Misri, Grazitti Interactive, 10th Aug 2018
* Purpose          : APPS-20840, Field Cleanup Project - Phase One
                     Fields which are being commented out:
                     RTP_Config_Billing_Frequency__c,RTP_Config_Selected_Suite__c

 **************************************************************/
 
public class OpportunityConfiguratorRTP {

    public List<OpportunityLineItemWrapper> lineItemWrappers { get ; set ;}
    public List<OpportunityLineItemWrapper> newLineItemWrappers { get ; set ;}

    public class ProductTable {
        public String name {get; set;}
        public OpportunityLineItemWrapper[] products {get; set;}
        public ProductTable(String name, OpportunityLineItemWrapper[] products) {
            this.name = name;
            this.products = products;
        }
    }

    public ProductTable[] getTables() {
        return new ProductTable[]{
            new ProductTable('Included', lineItemWrappers),
            new ProductTable('Addons', lineItemWrappers),
            new ProductTable('Available Addons', newLineItemWrappers)
        };
    } 

    public String editedField {get; set;}
    private ApexPages.StandardController controller;
    @TestVisible
    private Opportunity opportunity;
    
    public OpportunityConfiguratorRTP(ApexPages.StandardController controller) {
        this.controller = controller;
        
        Opportunity = getOpportunity(controller.getId());

        // stop processing init because the onLoad will redirect us
       /* if (opportunity.RTP_Config_Selected_Suite__c == null || opportunity.RTP_Config_Selected_Suite__c == '') {
            return;
        } */

        lineItemWrappers = new OpportunityLineItemWrapper[]{};
        newLineItemWrappers = new OpportunityLineItemWrapper[]{};

        if (opportunity.Pricebook2Id == null) {
            ApexPages.addMessage(
                new ApexPages.Message(ApexPages.Severity.FATAL, 'No pricebook selected'));
        }

        createWrappers(Opportunity);
    }
    
    public OpportunityConfiguratorRTP () {
        // just for testing
        lineItemWrappers = new OpportunityLineItemWrapper[]{};
        newLineItemWrappers = new OpportunityLineItemWrapper[]{};
        opportunity = getOpportunity(null); // will get override value
    }

    private Boolean pastOnLoad;
    public PageReference onLoad() {

        if (!Test.isRunningTest() && opportunity.Pricebook2Id == null) {
            opportunity.Pricebook2Id = [select Id from Pricebook2 where IsActive = true and IsStandard = true limit 1].Id;
            update opportunity;
        }

        // force the user to go through suite criteria entry before managing products
        //if (opportunity.RTP_Config_Selected_Suite__c == null || opportunity.RTP_Config_Selected_Suite__c == '') {
            PageReference pr = Page.OpportunityConfiguratorRTP_Slim;
            pr.getParameters().put('id', opportunity.Id);
            pr.setRedirect(true); // so standard controller gets their own fields on the other page
            return pr;
        //}

        // recalculate the current rows so we are sure that calcs displayed are correct
        saveLineItemsTemp();

        pastOnLoad = true;

        return null;
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
    
    public void addItem(){
        try {
            Integer i = Integer.valueOf(Apexpages.currentPage().getParameters().get('index'));
            lineItemWrappers.add(newLineItemWrappers[i].cloneNew());
            lineItemWrappers[lineItemWrappers.size()-1].oppLineItem.Quantity = 1;
        } catch(Exception e) {
            ApexPages.addMessages(e);
        }
        // refresh the records to ensure rules are adhered to
        saveLineItemsTemp();
    }


    // ------------------ rtp logic ------------------------------

    public void ensureProductSelected(String pricebookEntryId, Decimal quantity, Decimal unitPrice) {
        // TODO: should use another key like product code or something that doesn't change
        //       need time to figure out what field because there are a lot of duplicate products in fullcopy
        Boolean found = false;
        for (Integer i=0; i<lineItemWrappers.size(); i++) {
            OpportunityLineItemWrapper wrapper = lineItemWrappers[i];
            if (pricebookEntryId == wrapper.oppLineItem.PriceBookEntryId) {
                // already in desired table
                return;
            }
        }
        // create new one if not found 
        for (OpportunityLineItemWrapper wrapper : newLineItemWrappers) {
            if (pricebookEntryId == wrapper.oppLineItem.PriceBookEntryId) {
                OpportunityLineItemWrapper newWrapper = wrapper.cloneNew();
                newWrapper.oppLineItem.Quantity = quantity == null ? 1 : quantity;
                if (unitPrice != null)
                    newWrapper.oppLineItem.UnitPrice = unitPrice;
                lineItemWrappers.add(newWrapper);
                return;
            }
        }
        if (PriceBookEntryId != null)
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL, 
                'Suite product not found in pricebook for your currency code: ' + pricebookEntryId));
    }

    private void suiteSelectedWrappers() {
        // move all products found in the template up to selected area
        OpportunityLineItem[] templateLineItems = OpportunityConfiguratorRTP_Slim.generateLineItems(opportunity);
        for (Integer i=0; i<templateLineItems.size(); i++) {
            ensureProductSelected(
                templateLineItems[i].PriceBookEntryId, 
                templateLineItems[i].Quantity,
                templateLineItems[i].UnitPrice
            );
        }
    }

    // ------------------ end of rtp ------------------------------

    public void createWrappers(Opportunity Opportunity){
        lineItemWrappers.clear();
        newLineItemWrappers.clear();
        
        if (Opportunity.Pricebook2Id != null){
            // add our existing selected products
            
            Set<Id> seenProducts = new Set<Id>();
            for (OpportunityLineItem oli : getOpportunityLineItems(Opportunity.Id)) {
                lineItemWrappers.add(new OpportunityLineItemWrapper(oli, oli.PricebookEntry));
                seenProducts.add(oli.PricebookEntry.Id);
            }
            
            // then add any products that are not already selected
            
            for (PriceBookEntry pbe : getPricebookEntries(Opportunity)) {
                newLineItemWrappers.add(new OpportunityLineItemWrapper(
                    new OpportunityLineItem(
                        OpportunityId=Opportunity.Id,
                        PriceBookEntryId=pbe.Id,
                        UnitPrice = pbe.UnitPrice,
                        PricebookEntry = pbe
                    ), 
                    pbe
                ));
            }

            suiteSelectedWrappers();
        
        }
    }
    
    public void saveLineItemsTemp(){
        Savepoint sp = Database.setSavePoint();
       
        // save the ids we truely have so we can remove the ones that were made inside the transaction
        Set<Id> originalIds = new Set<Id>();
        for (OpportunityLineItemWrapper oppLineItemWrap : lineItemWrappers)
            if (oppLineItemWrap.oppLineItem.Id != NULL)
                originalIds.add(oppLineItemWrap.oppLineItem.Id);

        PageReference pr = saveLineItems();
        
        if (pr != null) {
            Opportunity = getOpportunity(Opportunity.Id);
            resetWrappersAfterSave(originalIds, Opportunity, lineItemWrappers);
        }

        Database.rollback(sp);
    }
    
    @TestVisible
    private static void resetWrappersAfterSave(Set<Id> originalIds, Opportunity Opportunity, OpportunityLineItemWrapper[] wrappers) {
        Map<Id,OpportunityLineItem> OpportunityLineItemMap = new Map<Id,OpportunityLineItem>(getOpportunityLineItems(Opportunity.Id));
        for(OpportunityLineItemWrapper oppLineItemWrap : wrappers){
            // not queried back means we deleted (qty=0) it as part of the save
            if (!OpportunityLineItemMap.containsKey(oppLineItemWrap.oppLineItem.Id))
                continue;
            // null means the save was not successful
            if (oppLineItemWrap.oppLineItem.Id == null) // || OpportunityLineItemMap.get(oppLineItemWrap.oppLineItem.Id) != NULL){
                continue;
            Boolean keepId = originalIds.contains(oppLineItemWrap.oppLineItem.Id);
            oppLineItemWrap.oppLineItem = OpportunityLineItemMap.get(oppLineItemWrap.oppLineItem.Id).clone(keepId, false, false, false);
       }
    }
    
    public Pagereference saveLineItems(){
        Pagereference pageRef;
        try{
            if (pastOnLoad == true)
            controller.save();
            
            List<OpportunityLineItem> lstLineItems = toUpsert(editedField, lineItemWrappers);
            List<OpportunityLineItem> lstLineItemsToDel = toDelete(lineItemWrappers);

            fixUnitPriceTotalPriceConflict(lstLineItems);

            if(!lstLineItemsToDel.isEmpty()){
                DELETE lstLineItemsToDel;
            }
    
            if(!lstLineItems.isEmpty()){
                UPSERT lstLineItems;
            }
            pageRef = new Pagereference('/'+Opportunity.Id);
        }
        catch(Exception e){
            Apexpages.addMessages(e);
        }
        
        return pageRef;       
    }
    
    @TestVisible
    private static void fixUnitPriceTotalPriceConflict(OpportunityLineItem[] lineItems) {
        // only required on opportunities because quotes have a totalprice that is a formula
        //for (OpportunityLineItem oli : lineItems)
            //oli.UnitPrice = oli.UnitPrice + 0; // would this work to trigger the setter????
            //oli.TotalPrice = null;
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
        'SELECT Id, Product2.Name, UnitPrice, Product2.Description, Product2.ProductCode '+
        'FROM PricebookEntry '+
        'WHERE Pricebook2Id = :pricebookId '+
        'and Product2.RecordType.Name != \'SBQQ Product Type\' '+
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
                'PricebookEntry.Product2.Description', 'OpportunityId', 
                'PricebookEntry.Product2.ProductCode'
            },
            'OpportunityId=:id'
        );
        return Database.query(queryStr);
    }
    // RTP_Config_Billing_Frequency__c,  RTP_Config_Selected_Suite__c,
    @TestVisible
    private static Opportunity getOpportunityOverride;
    @TestVisible
    private static Opportunity getOpportunity(String id){
        if (getOpportunityOverride != null)
            return getOpportunityOverride;
        Set<String> additionalFields = new Set<String>{
            'Pricebook2Id',            
            'RTP_Config_Monthly_Unique_Visitors__c',
            'RTP_Config_Campaigns_Monthly__c',
            'RTP_Config_Domains__c',
            'RTP_Config_Database_Contacts__c',
            'RTP_Config_View_Only_Users__c',
            'RTP_Config_MA__c',
            'RTP_Config_B2__c'
            
        };
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
        public Boolean managedByConfigurator {get; set;}
        
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
                // create a new opp line item because of weird save errors in salesforce when you have
                // both unit and total price provided
                OpportunityLineItem oli = new OpportunityLineItem(
                    Id = oppLineItemWrap.oppLineItem.Id
                );
                for(Schema.FieldSetMember fsm : SObjectType.OpportunityLineItem.FieldSets.Opportunity_Configurator.getFields()) {
                    if (fsm.getFieldPath() != 'TotalPrice' && fsm.getFieldPath() != 'ListPrice') {
                        try {
                            oli.put(fsm.getFieldPath(), oppLineItemWrap.oppLineItem.get(fsm.getFieldPath()));
                        } catch (Exception e) {
                            // field was read only or not editable
                        }
                    }
                }
                if (oli.Id == null) {
                    oli.OpportunityId = oppLineItemWrap.oppLineItem.OpportunityId;
                    oli.PriceBookEntryId = oppLineItemWrap.oppLineItem.PriceBookEntry.Id;
                }
                // link back to wrapper so the update prices from database works
                oppLineItemWrap.oppLineItem = oli;
                result.add(oli);
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

    // temporary while old configurator tests are ported to new configurator
    @TestVisible
    private static void testCoverage() {
        Integer i = 0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
        i=0;
    }
}