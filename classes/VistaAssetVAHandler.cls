/* Change history
* 
* VistaSubAssetHandler
* Created - August 2016 - Jody Crutchfield (ATG)
* 
* Date - Who - What
* 3.28.17 - Barsotti - Refactor to reduce SOQLs / DML / etc
* 
*/
public without sharing class VistaAssetVAHandler {
    private static Map<Id, Asset>               assetMap                = new Map<Id, Asset>();
    private static Map<Id, Customer_Asset__c>   customerAssetMap = new Map<Id, Customer_Asset__c>();//map of IDs (subscriptions / assets / customer asset - returns customer asset)
    private static List<Asset>                  assetToTotal            = new List<Asset>();
    private static List<CustomerAssetWrapper> CustomerAssetWrapperList = new List<CustomerAssetWrapper>();

    public VistaAssetVAHandler(List<Asset> assetList) {
        initializeAssetWrapper(assetList);
        upsertAssets();
    }

    

    private static void upsertAssets() {
        Set<Customer_Asset__c> customerAssetSet = new Set<Customer_Asset__c>();
        for(CustomerAssetWrapper caw: CustomerAssetWrapperList) {
            customerAssetSet.add(caw.customerAsset);
        }
        upsert new List<Customer_Asset__c>(customerAssetSet);
    }
    public static void initializeAssetWrapper(List<Asset> assetList){
        populateStaticMaps(assetList);

        /* update below to resolve defect of multiple lines per transaction */
        Set<Id> currentAssetSet = new Set<Id>();

        for(Asset a : assetMap.values()) {
            if(currentAssetSet.contains(a.Id)) {continue;}
            currentAssetSet.add(a.Id);
            if(!a.Product2.Generate_Asset__c) {continue;} //only process where generate asset is set to true
            if(VistaAssetUtil.migrateBool && a.SBQQ__QuoteLine__c == null) { 
                CustomerAssetWrapperList.add(new CustomerAssetWrapper(a));
            } else if (a.SBQQ__QuoteLine__c != null && a != null) {
                CustomerAssetWrapperList.add(new CustomerAssetWrapper(a));
            }
        }
    }

    
    private static void populateStaticMaps(List<Asset> assetList) {
        

        //get Quote Line info for each asset
        assetMap = new Map<Id, Asset>((List<Asset>)Database.query(VistaAssetUtil.baseAssetQuery + ' WHERE Id IN :assetList '));

        //query values to later summarize all of the assets
        Set<Id> querySet = new Set<Id>();
        Set<Id> amendedSet = new Set<Id>();
        for(Asset a: assetMap.values()) {
            querySet.add(a.Id); //new
            querySet.add(a.SBQQ__RevisedAsset__c); //amended
            amendedSet.add(a.SBQQ__RevisedAsset__c); //amended
        }
        querySet.remove(null);
        amendedSet.remove(null);
        assetToTotal = Database.query(VistaAssetUtil.baseAssetQuery + ' WHERE Id IN :querySet OR SBQQ__RevisedAsset__c IN: amendedSet');

        //populate customer asset maps - only query where the subscription is null so that we don't pull back subscribed assets 
        for(Customer_Asset__c ca: Database.query(VistaAssetUtil.baseCustomerAssetQuery + '  WHERE (Steelbrick_Asset__c IN :querySet ' +
                                                    ' OR Steelbrick_Asset__r.SBQQ__RevisedAsset__c IN: querySet) ' +
                                                    ' AND Steelbrick_Subscription__c = null FOR UPDATE')) {
            customerAssetMap.put(ca.Id, ca);
            customerAssetMap.put(ca.Steelbrick_Asset__c, ca);
            customerAssetMap.put(ca.Steelbrick_Asset__r.SBQQ__RevisedAsset__c, ca);
        }
    }
    
    private class CustomerAssetWrapper {
        private CustomerAssetWrapper(Asset asset) {
            this.asset = asset; // must set asset first
            if(getIsAmendment()) {
                this.customerAsset = customerAssetMap.get(asset.SBQQ__RevisedAsset__c); //amendment
            } else {
                this.customerAsset = customerAssetMap.get(asset.Id); //new
            }
        }
        //method to determine if a asset is an amendment
        private boolean getIsAmendment() {
            if(asset != null && asset.SBQQ__RevisedAsset__c != null) {
                return true;
            }
            return false;
        }
        //method to determine if a asset is a renewal
        private boolean getIsRenewal() {
            if(quoteLine != null && quoteLine.SBQQ__RenewedSubscription__c != null) {
                return true;
            }
            return false;
        }
        //the associated quoteline
        private SBQQ__QuoteLine__c quoteLine {get {
            return asset.SBQQ__LatestQuoteLine__r;
        }}

        private SBQQ__Subscription__c subscription {get {
            return asset.SBQQ__CurrentSubscription__r;
        }}

        private Asset asset {get; set;}
        //sets the values of the customer asset
        private Customer_Asset__c customerAsset {get; 
            set {
                /* if the customer asset is null, then it is a net new asset */
                if(value == null) { //new customer asset
                    customerAsset = new Customer_Asset__c();
                    customerAsset.Name__c = asset.Product2.Name;
                    customerAsset.Account__c = asset.AccountId;
                    customerAsset.Product__c = asset.Product2Id;
                    customerAsset.Description__c = asset.Product2.Description;
                    customerAsset.Asset_Status__c = 'Active';
                    if (quoteLine == null) {
                        customerAsset.Quantity__c = asset.Quantity;
                    } else {
                        customerAsset.Quantity__c = quoteLine.SBQQ__Quantity__c;
                    }
                } else { //update to existing customer asset
                    customerAsset = value;
                }

                customerAsset.Steelbrick_Asset__c = asset.Id;
                customerAsset.Contract__c = asset.Contract__c;
                customerAsset.CurrencyIsoCode = asset.CurrencyIsoCode;
                //start and enddate logic
                if(!getIsRenewal() && !getIsAmendment()) {
                    customerAsset.Term_Start_Date__c = asset.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c;
                }
                customerAsset.Term_End_Date__c = asset.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveEndDate__c;

                /* decommision logic 
                * decom vista assets for existing quote lines with new quantity of 0
                */
                if(quoteLine != null && quoteLine.SBQQ__Quantity__c == 0) {
                    customerAsset.Decommission_Effective_Date__c = asset.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c;
                    if(asset.SBQQ__LatestQuoteLine__r.SBQQ__EffectiveStartDate__c == Date.today()) {
                        customerAsset.Asset_Status__c = 'Decommissioned';
                    }
                } else {
                    /* standard update */
                    if(quoteLine != null) {
                        if(customerAsset.Quantity__c < quoteLine.SBQQ__Quantity__c && customerAsset.Asset_Status__c == 'Fulfilled') {
                            customerAsset.Asset_Status__c = 'Partially Fulfilled';
                        }
                        customerAsset.Quantity__c = quoteLine.SBQQ__Quantity__c;
                    }
                    populateAggregateFields();
                }
            }
        }
        private void populateAggregateFields() {
            //initialize aggregation map
            Map<String, Double> aggregateMap = new Map<String, Double>();
            for(String s: VistaAssetUtil.customerAssetFieldToAssetField.keySet()) {
                aggregateMap.put(s, 0);
            }

            if(getIsAmendment()) { //aggregate all where they have the same upgraded asset + the upgraded asset
                for(Asset a: assetToTotal) {
                    Id upgradeId = asset.SBQQ__RevisedAsset__c;
                    if(a.Id == upgradeId //aggregate the quoteline that is the upgraded one
                        || a.SBQQ__RevisedAsset__c == upgradeId) { //aggregate all other assets that have also upgrade the same asset
                        for(String s: aggregateMap.keySet()) {
                            try {
                                //already summed value = aggregatedvalue
                                Double aggregatedValue = aggregateMap.get(s);
                                //value to add = the current assets values
                                String fieldToAdd = VistaAssetUtil.customerAssetFieldToAssetField.get(s);
                                aggregatedValue += VistaAssetUtil.getValueFromSObject(asset, fieldToAdd);
                                aggregateMap.put(s, aggregatedValue);
                            } catch (exception e) {
                                System.debug('failed to aggregate value ' + s + ' reason: ' + e.getMessage() + ' from asset '+ a);
                            }
                        }
                    }
                }
                for(String s: aggregateMap.keySet()) {
                    try {
                        //set the customer asset value aggregatedvalue
                        customerAsset.put(s, aggregateMap.get(s));
                    } catch (exception e) {
                        System.debug('failed to set value ' + s + ' reason: ' + e.getMessage());
                    }
                }

            } else { 
                //no need to aggregate for new / renewals
                for(String s: aggregateMap.keySet()) {
                    try {
                        //set the customer asset value to the asset value
                        String fieldToAdd = VistaAssetUtil.customerAssetFieldToAssetField.get(s);
                        customerAsset.put(s, VistaAssetUtil.getValueFromSObject(asset, fieldToAdd));
                    } catch (exception e) {
                        System.debug('failed to set value ' + s + ' reason: ' + e.getMessage());
                    }
                }
            }
        }
    }
}