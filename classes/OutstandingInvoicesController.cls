public class OutstandingInvoicesController{
    public Id accountId = ApexPages.CurrentPage().getParameters().get('Id');
    
    public List<Sales_Invoice__c> subscriptionInvoiceList {get;set;}
    public List<Sales_Invoice__c> servicesInvoiceList {get;set;}
    public List<Sales_Invoice__c> unknownInvoiceList {get;set;}
    
    public OutstandingInvoicesController(ApexPages.StandardController con){
        subscriptionInvoiceList =  new List<Sales_Invoice__c>();
        servicesInvoiceList =  new List<Sales_Invoice__c>();
        unknownInvoiceList =  new List<Sales_Invoice__c>();
        
        //***Get all Sales Invoices related to the account***
        List<Sales_Invoice__c> allRelatedSalesIncoviceList = new List<Sales_Invoice__c>();
        allRelatedSalesIncoviceList = [SELECT Id, Name, Reference_Number__c, Billing_Frequency__c, Opportunity__c, Opportunity__r.Name,
            Payment_Status__c, Date__c, Payment_Due_Date__c, Days_Past_Due__c, Terms__c, Amount_Due__c, Total__c 
            FROM Sales_Invoice__c WHERE Account__c = :accountId AND Amount_Due__c > 0 AND Days_Past_Due__c > 0 AND 
            Document_Type__c NOT in ('Revenue Recognition Activation', 'Professional Services')];
        
        Set<Id> salesInvoiceIdSet = new Set<Id>();
        Map<Id, Sales_Invoice__c> salesInvoiceMap = new Map<Id, Sales_Invoice__c>();
        
        for(Sales_Invoice__c salesInvoice :allRelatedSalesIncoviceList){
            salesInvoiceIdSet.add(salesInvoice.Id);
            salesInvoiceMap.put(salesInvoice.Id, salesInvoice);
        }
        
        
        //***Get all related Sales Invoice Items, and get all related Opp Product Ids***
        Set<Id> productIdSet = new Set<Id>();
        List<Sales_Invoice_Item__c> allSalesInvoiceItemList = new List<Sales_Invoice_Item__c>();
        allSalesInvoiceItemList = [SELECT Id, Sales_Invoice__c, Opp_Product_Id__c FROM Sales_Invoice_Item__c 
            WHERE Sales_Invoice__c in :salesInvoiceIdSet];
        
        for(Sales_Invoice_Item__c salesInvoiceItem :allSalesInvoiceItemList){
            if(salesInvoiceItem.Opp_Product_Id__c != null){
                productIdSet.add(salesInvoiceItem.Opp_Product_Id__c);
            }
        }
        
        
        //***Get Product Type for all Invoice Items***
        Map<Id, String> productTypeMap = new Map<Id, String>();
        for(OpportunityLineItem oli :[SELECT Id, PriceBookEntry.Product2.Product_Type__c 
        FROM OpportunityLineItem WHERE id in :productIdSet]){
            productTypeMap.put(oli.Id, oli.PriceBookEntry.Product2.Product_Type__c);
        }
        
        
        //***Separated out Sales Invoices depending on conditions***
        Map<Id,Sales_Invoice__c> subscriptionSalesInvoiceMap = new Map<Id,Sales_Invoice__c>();
        Map<Id,Sales_Invoice__c> servicesSalesInvoiceMap = new Map<Id,Sales_Invoice__c>();
        Map<Id,Sales_Invoice__c> unknownSalesInvoiceMap = new Map<Id,Sales_Invoice__c>();
        
        for(Sales_Invoice_Item__c salesInvoiceItem :allSalesInvoiceItemList){
            if(salesInvoiceItem.Opp_Product_Id__c == null){
                unknownSalesInvoiceMap.put(salesInvoiceMap.get(salesInvoiceItem.Sales_Invoice__c).Id, salesInvoiceMap.get(salesInvoiceItem.Sales_Invoice__c));
            }
            else if(productTypeMap.get(salesInvoiceItem.Opp_Product_Id__c) == 'Services'){
                servicesSalesInvoiceMap.put(salesInvoiceMap.get(salesInvoiceItem.Sales_Invoice__c).Id, salesInvoiceMap.get(salesInvoiceItem.Sales_Invoice__c));
            }
            else if(productTypeMap.get(salesInvoiceItem.Opp_Product_Id__c) == 'Subscription'){
                subscriptionSalesInvoiceMap.put(salesInvoiceMap.get(salesInvoiceItem.Sales_Invoice__c).Id, salesInvoiceMap.get(salesInvoiceItem.Sales_Invoice__c));
            }
            else{
                unknownSalesInvoiceMap.put(salesInvoiceMap.get(salesInvoiceItem.Sales_Invoice__c).Id, salesInvoiceMap.get(salesInvoiceItem.Sales_Invoice__c));
            }
        }
        
        subscriptionInvoiceList =  subscriptionSalesInvoiceMap.values();
        servicesInvoiceList =  servicesSalesInvoiceMap.values();
        unknownInvoiceList =  unknownSalesInvoiceMap.values();
    }
}