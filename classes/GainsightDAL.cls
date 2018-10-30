/*
This class contains methods to populate Static Variables that will be hold 
Alert Attributes/Picklist values, Account Map, Gainsight Customer Map and few other objects
that will be referenced while creating automated alerts in Gainsight
*/

public class GainsightDAL {

    //Static Variables to Store Alert Attributes and the checked to see if the attributes are cached
    private static Map<String, JBCXM__PickList__c> alertReasons     = new Map<String, JBCXM__PickList__c>();
    private static Map<String, JBCXM__PickList__c> alertSeverity    = new Map<String, JBCXM__PickList__c>();
    private static Map<String, JBCXM__PickList__c> alertStatus      = new Map<String, JBCXM__PickList__c>();
    private static Map<String, JBCXM__PickList__c> alertType        = new Map<String, JBCXM__PickList__c>();
    private static Boolean alertAttributesCached                    = false;

    //Static Variables to Store Adoption Attributes and the checked to see if the attributes are cached
    private static Map<String, JBCXM__PickList__c> adoptionMeasures = new Map<String, JBCXM__PickList__c>();
    private static Map<id, JBCXM__PickList__c> adoptionMeasuresById = new Map<id, JBCXM__PickList__c>();
    private static Boolean adoptionAttributesCached                 = false;

    //Static Variables to Store Milestone Attributes and the checked to see if the attributes are cached
    private static Map<String, JBCXM__PickList__c> milestoneTypes = new Map<String, JBCXM__PickList__c>();
    private static Map<id, JBCXM__PickList__c> milestoneTypesById = new Map<id, JBCXM__PickList__c>();
    private static Boolean milestoneAttributesCached              = false;
    
    //Static variables to Store Accounts and CustomerInfo - If we need to read data from Account and or Customer 
    private static Map<id, Account> accounts                    = new Map<id, Account>();
    private static List<id> accountIDs                          = new List<id>();
    private static Map<id, JBCXM__CustomerInfo__c> customers    = new Map<id, JBCXM__CustomerInfo__c>();
    private static Boolean accountsCached                       = false;
    private static Boolean customersCached                      = false;
    
    //Static variables to store Milestione Attribues a boolean to see if the data is cached
    private static Map<id, JBCXM__PickList__c> mileStones   = new Map<id, JBCXM__PickList__c>();
    private static Boolean mileStonesCached                 = false;
    
    //Test Gainsight DAL
    static testMethod void TestGainsightDAL() 
    {
    	GainsightDAL.RecacheAlertAtrributes();
    	GainsightDAL.RecacheAccounts();
    	GainsightDAL.GetCustomers(new List<JBCXM__CustomerInfo__c>(), 'JBara', new List<String>());
    	GainsightDAL.GetAccounts(new List<Account>(), 'JBara', new List<String>());
    	GainsightDAL.GetMilestoneAttributeBySystemName('000000000000000000');
    	GainsightDAL.GetMilestoneAttributeById('000000000000000000');
    	GainsightDAL.GetAlertStatusBySystemName('000000000000000000');
    	GainsightDAL.GetAlertTypeBySystemName('000000000000000000');
    	GainsightDAL.GetAlertSeverityBySystemName('000000000000000000');
    	GainsightDAL.GetAlertReasonBySystemName('000000000000000000');
    	GainsightDAL.GetAdoptionAttributeBySystemName('000000000000000000');
    	GainsightDAL.GetAdoptionAttributeById('000000000000000000');
    }

    //Methods to get Different Alert attributes by their SystemName
    public static JBCXM__PickList__c GetAlertStatusBySystemName(String systemName) {
        if(!alertAttributesCached) CacheAlertAtrributes();
        return alertStatus.get(systemName);
    }
    public static JBCXM__PickList__c GetAlertTypeBySystemName(String systemName) {
        if(!alertAttributesCached) CacheAlertAtrributes();
        return alertType.get(systemName);
    }
    public static JBCXM__PickList__c GetAlertSeverityBySystemName(String systemName) {
        if(!alertAttributesCached) CacheAlertAtrributes();
        return alertSeverity.get(systemName);
    }
    public static JBCXM__PickList__c GetAlertReasonBySystemName(String systemName) {
        if(!alertAttributesCached) CacheAlertAtrributes();
        return alertReasons.get(systemName);
    }
    
    public static JBCXM__PickList__c GetAdoptionAttributeBySystemName(String systemName) {
        if(!adoptionAttributesCached) CacheAdoptionAtrributes();
        return adoptionMeasures.get(systemName);
    }
    
    public static JBCXM__PickList__c GetAdoptionAttributeById(Id systemName) {
        if(!adoptionAttributesCached) CacheAdoptionAtrributes();
        return adoptionMeasuresById.get(systemName);
    }

    public static JBCXM__PickList__c GetMilestoneAttributeBySystemName(String systemName) {
        if(!milestoneAttributesCached) CacheMilestoneAtrributes();
        return milestoneTypes.get(systemName);
    }
    
    public static JBCXM__PickList__c GetMilestoneAttributeById(Id systemName) {
        if(!milestoneAttributesCached) CacheMilestoneAtrributes();
        return milestoneTypesById.get(systemName);
    }

    //Method to get Cached Accounts and Customers Info
    public static Map<id, Account> GetAccounts (List<Sobject> newList, String sObjectType, List<String> accountFields) {
        if(!accountsCached) CacheAccounts(newList, sObjectType, accountFields);
        return accounts;
    }
    public static Map<id, JBCXM__CustomerInfo__c> GetCustomers (List<Sobject> newList, String sObjectType, List<String> accountFields) {
        if(!customersCached) CacheCustomers(newList, sObjectType, accountFields);
        return customers;
    }


    //Methods to Cache Static Data Across Execution Context
    public static void RecacheAlertAtrributes () {
        alertReasons            = new Map<String, JBCXM__PickList__c>();
        alertSeverity           = new Map<String, JBCXM__PickList__c>();
        alertStatus             = new Map<String, JBCXM__PickList__c>();
        alertType               = new Map<String, JBCXM__PickList__c>();
        alertAttributesCached   = false;
    }

    //Methods to Cache Static Data Across Execution Context
    public static void RecacheAccounts () {
        accountsCached   = false;
        customersCached  = false;
        accountIds.clear();
    }
    
    //cache all the AlertAtrributes
    private static void CacheAlertAtrributes () {

        if(alertAttributesCached) return;

        for(JBCXM__PickList__c alertConfig : [SELECT Id, JBCXM__SystemName__c,JBCXM__Category__c, Name FROM JBCXM__PickList__c WHERE JBCXM__Category__c like 'Alert %']) {
            if(alertConfig.JBCXM__Category__c == 'Alert Reason') {
                alertReasons.put(alertConfig.JBCXM__SystemName__c,alertConfig);
            }
            if(alertConfig.JBCXM__Category__c == 'Alert Severity') {
                alertSeverity.put(alertConfig.JBCXM__SystemName__c, alertConfig);
            }
            if(alertConfig.JBCXM__Category__c == 'Alert Status') {
                alertStatus.put(alertConfig.JBCXM__SystemName__c, alertConfig);
            }
            if(alertConfig.JBCXM__Category__c == 'Alert Type') {
                alertType.put(alertConfig.JBCXM__SystemName__c, alertConfig);
            }
        }

        alertAttributesCached = true;
    }

    //Cache Adoption Attributes
    private static void CacheAdoptionAtrributes () {
        if(adoptionAttributesCached) return;
        for(JBCXM__PickList__c adoptionMeasure : [SELECT Id, JBCXM__SystemName__c,JBCXM__Category__c, Name FROM JBCXM__PickList__c WHERE JBCXM__Category__c like 'Adoption Measure%']) {
          adoptionMeasures.put(adoptionMeasure.JBCXM__SystemName__c, adoptionMeasure);
          adoptionMeasuresById.put(adoptionMeasure.id, adoptionMeasure);
        }
        alertAttributesCached = true;
    }

    //Cache Milestone Attributes
    private static void CacheMilestoneAtrributes () {
        if(milestoneAttributesCached) return;
        for(JBCXM__PickList__c milestoneType : [SELECT Id, JBCXM__SystemName__c,JBCXM__Category__c, Name FROM JBCXM__PickList__c WHERE JBCXM__Category__c like 'Milestone%']) {
          milestoneTypes.put(milestoneType.JBCXM__SystemName__c, milestoneType);
          milestoneTypesById.put(milestoneType.Id, milestoneType);
        }
        milestoneAttributesCached = true;
    }
  
    //Cache Accounts and Account IDs
    private static void CacheAccounts (List<Sobject> newList, String sObjectType, List<String> accountFields) {
        if(accountsCached) return;
    
    //For all standard salesforce object except account we will read accountId field
    //For all Gainsight object we will read JBCXM__Account__c field to get account id        
        for(Sobject obj : newList) {
            accountIDs.add((id)obj.get((sObjectType == 'JBara') ? 'JBCXM__Account__c' : 'accountid'));
        }
    
    //Build the Dynamic query to included all the additional field that should be queried on the account object
        String dynamicAccountsQuery = 'Select id ';
        for(String accountField : accountFields) {
            dynamicAccountsQuery += ', '+accountField+' ';
        }

        dynamicAccountsQuery += 'from Account where id in : accountIDs';

    //Execute the query and populate the Map
    List<Account> accountsList = database.query(dynamicAccountsQuery);
        for(Account acc : accountsList){
            accounts.put(acc.id, acc);
        }

        accountsCached = true;
    }

    //Cache CustomerInfo records
    private static void CacheCustomers (List<Sobject> newList, String sObjectType, List<String> accountFields) {
        if(customersCached) return;
        if(!accountsCached) CacheAccounts(newList, sObjectType, accountFields);
        for(JBCXM__CustomerInfo__c customer : [Select Id, JBCXM__ASV__c, JBCXM__MRR__c, JBCXM__Users__c, JBCXM__Account__c from JBCXM__CUstomerInfo__c 
                                                where JBCXM__Account__c in : accountIDs]) {
            customers.put(customer.JBCXM__Account__c, customer);
        }
        customersCached = true;

    }

}