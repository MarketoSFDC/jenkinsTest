public without sharing class VistaAssetUtil {
    private static final String SELECTSTR = 'SELECT ';
    //single place to define all subscriptions being queried
    private static Set<String> subscriptionFieldsToQuery = new Set<String>{
                        'Id', 'SBQQ__Product__c','SBQQ__Account__c','SBQQ__Contract__c','SBQQ__StartDate__c','SBQQ__EndDate__c',
                        'SBQQ__NetPrice__c', 'Annual_Recurring_Revenue__c','SBQQ__Quantity__c','CurrencyIsoCode','SBQQ__RevisedSubscription__c', 
                        'Subscribed_Asset_Count__c', 'One_Time_Fees__c',

                        'SBQQ__Product__r.Name', 'SBQQ__Product__r.Description', 'SBQQ__Product__r.Generate_Asset__c', 'SBQQ__Product__r.Family'
    };

    //single place to define all quote lines fields to be queried
    private static Set<String> quoteLineFieldsToQuery = new Set<String>{
                        'Id', 'SBQQ__UpgradedSubscription__c', 'SBQQ__Existing__c', 'SBQQ__RenewedSubscription__c', 'SBQQ__Quantity__c', 
                        'SBQQ__RenewedAsset__c', 'SBQQ__EffectiveStartDate__c', 'SBQQ__EffectiveEndDate__c', 'SBQQ__UpgradedAsset__c', 'SBQQ__SubscriptionPercent__c'
    };
    //single place to define all customer assets fields to be queried
    private static Set<String> customerAssetFieldsToQuery = new Set<String> {
                        'Id', 'Name', 'Account__c', 'Product__c', 'Description__c', 'Contract__c', 'Term_Start_Date__c', 'Term_End_Date__c',
                        'Asset_Status__c', 'Quantity__c', 'Annual_Recurring_Revenue__c', 'Name__c', 'Steelbrick_Subscription__c', 'Steelbrick_Asset__c',
                        'Total_One_Time_Fee_s__c'
    };
    //single place to define all contract query fields
    private static Set<String> contractFieldsToQuery = new Set<String> {
                        'Id', 'StartDate', 'EndDate'
    };
    //single place to define all standard asset fields to query 
    private static Set<String> assetFieldsToQuery = new Set<String> {
                        'Id', 'AccountId', 'Name', 'Description', 'CurrencyIsoCode', 'SBQQ__RevisedAsset__c',
                        'InstallDate', 'Price', 'Product2Id', 'SBQQ__QuoteLine__c', 
                        'Quantity', 'Status', 'UsageEndDate', 'Annual_Recurring_Revenue__c', 
                        'SBQQ__LatestQuoteLine__c', 'Contract__c', 'SBQQ__CurrentSubscription__c', 'Net_Price__c',

                        'Product2.Description', 'Product2.Generate_Asset__c', 'Product2.Name'
                         
    };
    private static Set<String> subscribedAssetFieldsToQuery = new Set<String> {
                        'Id', 'SBQQ__Active__c', 'SBQQ__Asset__c', 'SBQQ__ContractId__c', 'SBQQ__Subscription__c'
    };

    
    /*Used to aggregate fields from the subscription to the customer asset
      key = customer asset field - value = subscription field to set from */
    public static Map<String, String> customerAssetFieldToSubscriptionField {get {
        if(customerAssetFieldToSubscriptionField == null) {
            customerAssetFieldToSubscriptionField = new Map<String, String>(); 
            //customer asset field Total_One_Time_Fee_s__c is set to summarize the subscriptions One_Time_Fees__c
            customerAssetFieldToSubscriptionField.put('Total_One_Time_Fee_s__c', 'One_Time_Fees__c');
            //customer asset field Annual_Recurring_Revenue__c is set to summarize the subscriptions Annual_Recurring_Revenue__c
            customerAssetFieldToSubscriptionField.put('Annual_Recurring_Revenue__c', 'Annual_Recurring_Revenue__c');
        }
        return customerAssetFieldToSubscriptionField;
    } set;}
    
    public static Map<String, String> customerAssetFieldToSubAssetField {get {
        if(customerAssetFieldToSubAssetField == null) {
            customerAssetFieldToSubAssetField = new Map<String, String>(); 
            //customer asset field Total_One_Time_Fee_s__c is set to summarize the subscriptions One_Time_Fees__c
            customerAssetFieldToSubAssetField.put('Total_One_Time_Fee_s__c', 'SBQQ__Subscription__r.One_Time_Fees__c');
            //customer asset field Annual_Recurring_Revenue__c is set to summarize the subscriptions Annual_Recurring_Revenue__c
            customerAssetFieldToSubAssetField.put('Annual_Recurring_Revenue__c', 'SBQQ__Subscription__r.Annual_Recurring_Revenue__c');
        }
        return customerAssetFieldToSubAssetField;
    } set;}
        /*Used to aggregate fields from the subscription to the customer asset
      key = customer asset field - value = subscription field to set from */
    public static Map<String, String> customerAssetFieldToAssetField {get {
        if(customerAssetFieldToAssetField == null) {
            customerAssetFieldToAssetField = new Map<String, String>(); 
            //customer asset field Total_One_Time_Fee_s__c is set to summarize the Asset's One_Time_Fees__c
            customerAssetFieldToAssetField.put('Total_One_Time_Fee_s__c', 'Net_Price__c');  
        }
        return customerAssetFieldToAssetField;
    } set;}
        
   /* public static String baseSubscribedAssetQuery {get {
        String baseSubscribedAssetQuery = SELECTSTR;
        for(String s: subscribedAssetFieldsToQuery) {
            baseSubscribedAssetQuery = baseSubscribedAssetQuery != SELECTSTR ? baseSubscribedAssetQuery += ', ' : baseSubscribedAssetQuery;
            baseSubscribedAssetQuery += ' ' + s.trim() + ' ';
        }
        for(String s: assetFieldsToQuery) {
            baseSubscribedAssetQuery = baseSubscribedAssetQuery != SELECTSTR ? baseSubscribedAssetQuery += ', ' : baseSubscribedAssetQuery;
            baseSubscribedAssetQuery += ' SBQQ__Asset__r.' + s.trim() + ' ';
        }
        for(String s: subscriptionFieldsToQuery) {
            baseSubscribedAssetQuery = baseSubscribedAssetQuery != SELECTSTR ? baseSubscribedAssetQuery += ', ' : baseSubscribedAssetQuery;
            baseSubscribedAssetQuery += ' SBQQ__Subscription__r.' + s.trim() + ' ';
        }
        for(String s: contractFieldsToQuery) {
            baseSubscribedAssetQuery = baseSubscribedAssetQuery != SELECTSTR ? baseSubscribedAssetQuery += ', ' : baseSubscribedAssetQuery;
            baseSubscribedAssetQuery += ' SBQQ__Asset__r.Contract__r.' + s.trim() + ' ';
        }
        for(String s: quoteLineFieldsToQuery) {
            baseSubscribedAssetQuery = baseSubscribedAssetQuery != SELECTSTR ? baseSubscribedAssetQuery += ', ' : baseSubscribedAssetQuery;
            baseSubscribedAssetQuery += ' SBQQ__Asset__r.SBQQ__QuoteLine__r.' + s.trim() + ' ';
            baseSubscribedAssetQuery += ', SBQQ__Subscription__r.SBQQ__QuoteLine__r.' + s.trim() + ' ';

        }
        baseSubscribedAssetQuery += ' FROM SBQQ__SubscribedAsset__c ';
        return baseSubscribedAssetQuery;
    } set;}*/


    //SOQL query for the standard asset object and related objects
    public static String baseAssetQuery {get {
        String baseAssetQuery = SELECTSTR;
        for(String s: assetFieldsToQuery) {
            baseAssetQuery = baseAssetQuery != SELECTSTR ? baseAssetQuery += ', ' : baseAssetQuery;
            baseAssetQuery += ' ' + s.trim() + ' ';
        }
        for(String s: contractFieldsToQuery) {
            baseAssetQuery = baseAssetQuery != SELECTSTR ? baseAssetQuery += ', ' : baseAssetQuery;
            baseAssetQuery += ' Contract__r.' + s.trim() + ' ';
        }
        for(String s: quoteLineFieldsToQuery) {
            baseAssetQuery = baseAssetQuery != SELECTSTR ? baseAssetQuery += ', ' : baseAssetQuery;
            baseAssetQuery += ' SBQQ__LatestQuoteLine__r.' + s.trim() + ' ';
            baseAssetQuery += ', SBQQ__QuoteLine__r.' + s.trim() + ' ';
            baseAssetQuery += ', SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.' + s.trim() + ' ';
        }
        for(String s: subscriptionFieldsToQuery) {
            baseAssetQuery = baseAssetQuery != SELECTSTR ? baseAssetQuery += ', ' : baseAssetQuery;
            baseAssetQuery += ' SBQQ__CurrentSubscription__r.' + s.trim() + ' ';
            
        }
        baseAssetQuery += ' FROM Asset ';
        return baseAssetQuery;
    } set;}
    public static String baseSubscriptionQuery {get {
        baseSubscriptionQuery = SELECTSTR;
        for(String s: subscriptionFieldsToQuery) {
            baseSubscriptionQuery = baseSubscriptionQuery != SELECTSTR ? baseSubscriptionQuery += ', ' : baseSubscriptionQuery;
            baseSubscriptionQuery += ' ' + s.trim() + ' ';
        }
        for(string s: quoteLineFieldsToQuery) {
            baseSubscriptionQuery = baseSubscriptionQuery != SELECTSTR ? baseSubscriptionQuery += ', ' : baseSubscriptionQuery;
            baseSubscriptionQuery += ' SBQQ__QuoteLine__r.' + s.trim() + ' ';
        }
        baseSubscriptionQuery += ' FROM SBQQ__Subscription__c ';
        return baseSubscriptionQuery;
    } set;}

    public static String baseCustomerAssetQuery {get{
        baseCustomerAssetQuery = SELECTSTR;
        for(String s: subscriptionFieldsToQuery) {
            baseCustomerAssetQuery = baseCustomerAssetQuery != SELECTSTR ? baseCustomerAssetQuery += ', ': baseCustomerAssetQuery;
            baseCustomerAssetQuery += ' Steelbrick_Subscription__r.' + s.trim() + ' ';                       //subscription fields
            baseCustomerAssetQuery += ', Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.' + s.trim() + ' '; //subscribed asset fields
        }
        for(String s: quoteLineFieldsToQuery) {
            baseCustomerAssetQuery = baseCustomerAssetQuery != SELECTSTR ? baseCustomerAssetQuery += ', ': baseCustomerAssetQuery;
            baseCustomerAssetQuery += ' Steelbrick_Subscription__r.SBQQ__QuoteLine__r.' + s.trim() + ' ';
            baseCustomerAssetQuery += ', Steelbrick_Asset__r.SBQQ__LatestQuoteLine__r.' + s.trim() + ' '; 
            baseCustomerAssetQuery += ', Steelbrick_Asset__r.SBQQ__CurrentSubscription__r.SBQQ__QuoteLine__r.' + s.trim() + ' '; //subscribed asset's subscription quote line
        }
        for(String s: assetFieldsToQuery) {
            baseCustomerAssetQuery = baseCustomerAssetQuery != SELECTSTR ? baseCustomerAssetQuery += ', ': baseCustomerAssetQuery;
            baseCustomerAssetQuery += ' Steelbrick_Asset__r.' + s.trim() + ' ';

        }
        baseCustomerAssetQuery += ' FROM Customer_Asset__c ';
        return baseCustomerAssetQuery;
    } set;} 

    public static Boolean migrateBool = Subscription_Migration_TF__c.getInstance(UserInfo.getUserId()).Migration_Allowed__c;

    //this is used to pull back double values from an sObject or a related sObject 
    public static Double getValueFromSObject(sObject sObj, String fieldToAdd)  {
        sObject tempSobj = sObj;
        system.debug(sObj);
        system.debug(fieldToAdd);
        if(fieldToAdd.contains('.')) {
            for(String tmp: fieldToAdd.split('\\.')) {
                system.debug(tmp);
                system.debug(tempSobj);
                if(tmp.contains('__c')) {
                    return (Double)tempSobj.get(tmp);
                } else {    
                    tempSobj = (Sobject)tempSobj.getsObject(tmp);   
                }
            }
        } else {
            return (Double)tempSobj.get(fieldToAdd);
        }
        return null;
    }
}