/* Change history
* 
* VistaSubscriptionHandler
* Created - August 2016 - Jody Crutchfield (ATG)
*
* Date - Who - What
* 3.28.17 - Barsotti - Refactor
* 
*/ 
public without sharing class VistaSubscriptionHandler {
    private static List<CustomerAssetWrapper> CustomerAssetWrapperList = new List<CustomerAssetWrapper>();
    private static Map<Id, SBQQ__Subscription__c>   subscriptionMap         = new Map<Id, SBQQ__Subscription__c>();
    private static Map<Id, Customer_Asset__c>       customerAssetMap        = new Map<Id, Customer_Asset__c>(); //map of IDs (subscriptions / assets / customer asset - returns customer asset)
    private static List<SBQQ__Subscription__c>      subscriptionToTotal     = new List<SBQQ__Subscription__c>();
    
    public VistaSubscriptionHandler(List<SBQQ__Subscription__c> subscriptionList) {
        initializeAssetWrapper(subscriptionList);
        upsertAssets();
    }

    private static void upsertAssets() {
        Set<Customer_Asset__c> customerAssetSet = new Set<Customer_Asset__c>();
        for(CustomerAssetWrapper caw: CustomerAssetWrapperList) {
            customerAssetSet.add(caw.customerAsset);
        }
        upsert new List<Customer_Asset__c>(customerAssetSet);
    }
    private static void initializeAssetWrapper(List<SBQQ__Subscription__c> subscriptionList){
        populateStaticMaps(subscriptionList);
        /* update below to resolve defect of multiple lines per transaction */
        Set<Id> currentSubscriptionIdSet = new Set<Id>();
        for (SBQQ__Subscription__c sub : subscriptionMap.values()) {
            if(currentSubscriptionIdSet.contains(sub.Id)) {continue;}
            currentSubscriptionIdSet.add(sub.Id);

            if(!sub.SBQQ__Product__r.Generate_Asset__c) {continue;} //only process where generate asset is set to true
            if(VistaAssetUtil.migrateBool && sub.SBQQ__QuoteLine__c == null) { 
                CustomerAssetWrapperList.add(new CustomerAssetWrapper(sub));
            } else if (sub.SBQQ__QuoteLine__c != null && sub != null) {
                CustomerAssetWrapperList.add(new CustomerAssetWrapper(sub));
            }
        }
    }

    private static void populateStaticMaps(List<SBQQ__Subscription__c> subscriptionList) {
        //get Quote Line info for each subscription
        subscriptionMap = new Map<Id, SBQQ__Subscription__c>((List<SBQQ__Subscription__c>)Database.query(VistaAssetUtil.baseSubscriptionQuery + ' WHERE Id IN :subscriptionList '));

        //query values to later summarize all of the subscriptions
        Set<Id> querySet = new Set<Id>();
        Set<Id> amendedSet = new Set<Id>();
        for(SBQQ__Subscription__c sub: subscriptionMap.values()) {
            querySet.add(sub.SBQQ__RevisedSubscription__c); //amendments
            amendedSet.add(sub.SBQQ__RevisedSubscription__c); //amendments
            querySet.add(sub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c); //renewals
            querySet.add(sub.Id); //new suscriptions
        }
        querySet.remove(null);
        amendedSet.remove(null);
        subscriptionToTotal = Database.query(VistaAssetUtil.baseSubscriptionQuery + ' WHERE Id IN :querySet OR SBQQ__RevisedSubscription__c IN: AmendedSet ');
        
        //query existing customer assets - only pull back where asset is null so we do not get subscribed assets' customer asset
        for(Customer_Asset__c ca: Database.query(VistaAssetUtil.baseCustomerAssetQuery + ' WHERE (Steelbrick_Subscription__c IN :querySet OR ' +
                                                                        ' Steelbrick_Subscription__r.SBQQ__RevisedSubscription__c IN: querySet) FOR UPDATE')) {
            customerAssetMap.put(ca.Id, ca);
            customerAssetMap.put(ca.Steelbrick_Subscription__c, ca);
            customerAssetMap.put(ca.Steelbrick_Subscription__r.SBQQ__RevisedSubscription__c, ca);
            customerAssetMap.put(ca.Steelbrick_Subscription__r.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c, ca);
        }

    }
    
    private class CustomerAssetWrapper {
        private CustomerAssetWrapper(SBQQ__Subscription__c sub) {
            this.subscription = sub; // must set subscription first
            if(getIsAmendment()) {
                this.customerAsset = customerAssetMap.get(sub.SBQQ__RevisedSubscription__c); //amendment
            } else if (getIsRenewal()) {
                this.customerAsset = customerAssetMap.get(sub.SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c); //renewal
            } else {
                this.customerAsset = customerAssetMap.get(sub.Id); //new
            }
        }
        //method to determine if a subscription is an amendment
        private boolean getIsAmendment() {
            if(quoteLine != null && quoteLine.SBQQ__UpgradedSubscription__c != null) {
                return true;
            }
            return false;
        }
        //method to determine if a subscription is a renewal
        private boolean getIsRenewal() {
            if(quoteLine != null && quoteLine.SBQQ__RenewedSubscription__c != null) {
                return true;
            } 
            return false;
        }
        //the associated quoteline
        private SBQQ__QuoteLine__c quoteLine {get {
            return subscription.SBQQ__QuoteLine__r;
        }}

        private SBQQ__Subscription__c subscription {get {
            return subscription;
        } set;}

        //sets the values of the customer asset
        private Customer_Asset__c customerAsset {get; 
            set {
                /* if the customer asset is null, then it is a net new asset */
                if(value == null) { //new customer asset
                    customerAsset = new Customer_Asset__c();
                    customerAsset.Name__c = subscription.SBQQ__Product__r.Name;
                    customerAsset.Account__c = subscription.SBQQ__Account__c;
                    customerAsset.Product__c = subscription.SBQQ__Product__c;
                    customerAsset.Product_Family__c = subscription.SBQQ__Product__r.Family;
                    customerAsset.Description__c = subscription.SBQQ__Product__r.Description;
                    customerAsset.Asset_Status__c = 'Active';
                    if (quoteLine == null) {
                        customerAsset.Quantity__c = subscription.SBQQ__Quantity__c;
                    } else {
                        customerAsset.Quantity__c = quoteLine.SBQQ__Quantity__c;
                    }
                } else { //update to existing customer asset
                    customerAsset = value;
                }
                customerAsset.Steelbrick_Subscription__c = subscription.Id;
                //update values
                customerAsset.Contract__c = subscription.SBQQ__Contract__c;
                customerAsset.CurrencyIsoCode = subscription.CurrencyIsoCode;
                //start and enddate logic
                if(!getIsRenewal() && !getIsAmendment()) {
                    customerAsset.Term_Start_Date__c = subscription.SBQQ__StartDate__c;
                }
                customerAsset.Term_End_Date__c = subscription.SBQQ__EndDate__c;

                /* decommision logic 
                * decom vista assets for existing quote lines with new quantity of 0
                */
                if(quoteLine != null && quoteLine.SBQQ__Quantity__c == 0) {
                    customerAsset.Decommission_Effective_Date__c = subscription.SBQQ__StartDate__c;
                    if(subscription.SBQQ__StartDate__c == Date.today()) {
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
            for(String s: VistaAssetUtil.customerAssetFieldToSubscriptionField.keySet()) {
                aggregateMap.put(s, 0);
            }

            if(getIsAmendment()) { //aggregate all where they have the same upgraded subscription + the upgraded subscription
                for(SBQQ__Subscription__c sub: subscriptionToTotal) {
                    Id upgradeId = quoteLine.SBQQ__UpgradedSubscription__c;
                    if(sub.Id == upgradeId //aggregate the quoteline that is the upgraded one
                        || sub.SBQQ__QuoteLine__r.SBQQ__UpgradedSubscription__c == upgradeId) { //aggregate all other subscriptions that have also upgrade the same subscription
                        for(String s: aggregateMap.keySet()) {
                            try {
                                //already summed value = aggregatedvalue
                                Double aggregatedValue = aggregateMap.get(s);
                                String fieldToAdd = VistaAssetUtil.customerAssetFieldToSubscriptionField.get(s);
                                aggregatedValue += VistaAssetUtil.getValueFromSObject(sub, fieldToAdd);
                                aggregateMap.put(s, aggregatedValue);
                            } catch (exception e) {
                                System.debug('failed to aggregate value ' + s + ' reason: ' + e.getMessage() + ' from subscription '+ sub);
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
                        //set the customer asset value to the subscription value
                        String fieldToAdd = VistaAssetUtil.customerAssetFieldToSubscriptionField.get(s);
                        customerAsset.put(s, VistaAssetUtil.getValueFromSObject(subscription, fieldToAdd));
                    } catch (exception e) {
                        System.debug('failed to set value ' + s + ' reason: ' + e.getMessage());
                    }
                }
            }
        }
    }
}