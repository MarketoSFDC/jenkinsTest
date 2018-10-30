@isTest
public class ContractTriggerMainHandlerTest{
    public static testmethod void testData(){
    
        Account account =  new Account(Name='New Test Account');
        insert account;
    
        // Insert Product
        Product2 pr = new Product2();
        pr.Name='Moto - G1';
        pr.isActive=true;
        insert pr;
        
        // Insert Pricebook
        PriceBook2 customPriceBook = new PriceBook2();
        customPriceBook.Name='Custom Pricebook';
        customPriceBook.IsActive=true;
        insert customPriceBook;
        
        // Query Standard and Custom Price Books
        Pricebook2 customPriceBookRec=[select Id from Pricebook2 where id=:customPriceBook.Id];
        Id stdPriceBookRecId = Test.getStandardPricebookId();
        
        // Create Standard PriceBookEntry
        PriceBookEntry stdPriceBookEntry = new PriceBookEntry();
        stdPriceBookEntry.Product2Id=pr.Id;
        stdPriceBookEntry.Pricebook2Id=stdPriceBookRecId;
        stdPriceBookEntry.UnitPrice=2000;
        stdPriceBookEntry.IsActive=true;
        insert stdPriceBookEntry;
        // Create Custom PriceBookEntry
        PriceBookEntry customPriceBookEntry = new PriceBookEntry();
        customPriceBookEntry.Product2Id=pr.Id;
        customPriceBookEntry.Pricebook2Id=customPriceBookRec.Id;
        customPriceBookEntry.UnitPrice=5000;
        customPriceBookEntry.IsActive=true;
        insert customPriceBookEntry;
        

        Opportunity opportunity = new Opportunity(Account=account,Name='Oppor',Type = 'New Business',StageName='Prospecting',CloseDate= System.Today(),Subscription_Time_Zone__c='Pacific Time (America/Los_Angeles)',Primary_Enablement_Partner__c='Marketo Professional Services',Subscription_Locale__c='English-United States',Use_Case__c='B2B',Subscription_Language__c='English',Needs_Pains__c='Test Needs_Pains__c',Competitor_Swap__c='3rd Party ESP/Agency',Compelling_Event__c='here Test!',MainCompetitor__c='Act-On',Rep_Create_ARR__c = 1000,Deal_Type__c = 'Education');
        insert opportunity;
        
        // Add product and Pricebook to the particular opportunity using OpportunityLineItem 
        OpportunityLineItem oppLineItem = new OpportunityLineItem();
        oppLineItem.OpportunityId = opportunity.Id;
        oppLineItem.PricebookEntryId = customPriceBookEntry.Id;
        oppLineItem.UnitPrice = 7000;
        oppLineItem.Quantity = 5;
        insert oppLineItem;      
    
        test.startTest();    
        List<Contract> conttoinsert = new List<Contract>();
  
            // Create contract record only when the Stage is Updated to "Pending Win"
            if (opportunity.StageName == 'Pending win') {
                Contract con = new Contract();
                con.AccountId = account.Id;
                con.Total_Contact_Records__c = 10000;
                con.SBQQ__Opportunity__c   = opportunity.Id;
                con.Account     = account;
                con.CurrencyIsoCode       = opportunity.CurrencyIsoCode;
                conttoinsert.add(con); // For Bulk processing of the Records.
            } //end if
    
        // Inserting the New Contract Records if these records exist
        if ( !conttoinsert.isEmpty()) {
            insert conttoinsert;
        } 
        ContractTriggerMainHandler.isBeforeInsertHandler(conttoinsert,new Map<Id,Contract>());
        ContractTriggerMainHandler.isBeforeUpdateHandler(conttoinsert,new Map<Id,Contract>(),conttoinsert,new Map<Id,Contract>());
       ContractTriggerMainHandler.isBeforeDeleteHandler(conttoinsert,new Map<Id,Contract>());
       ContractTriggerMainHandler.isAfterInsertHandler(conttoinsert,new Map<Id,Contract>());
       
        update conttoinsert;
        delete conttoinsert;
        test.stopTest();
        
     }
}