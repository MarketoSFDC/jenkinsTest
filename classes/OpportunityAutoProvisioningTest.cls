/*******************************************************
Modified By : Sumit Bhatt, Grazitti Interactive
Modified date : 7/27/2018
Purpose : Commented the field that are used in field removal project 
refrence : APPS-20840 Field Cleanup Project - Phase One
log of fields commented : Opportunity: third_party_solutions__c

Modified By :Jade Global 31th August 20
   Change      : Removed closedWonRecordTypeId of class Trigger_Opportunity_Helper  variable from class
*******************************************************/
@isTest

private class OpportunityAutoProvisioningTest 
{
    static testMethod void testMethods1() 
    {
        OpportunityAutoProvisioning.processOpportunities([SELECT Id FROM Opportunity WHERE (Type = 'New Business' OR Type = 'Upsell/Crossell') LIMIT 100]);
    }
  
    static testMethod void testTrigger1()
    {    
        // run this as sales ops
        List<User> users = [select u.Name,IsActive from User u where u.UserRole.Name = 'System Admins' AND IsActive = True];
        User salesOpsUser = users.get(0);
    
        Intacct_Entity__c entity=new Intacct_Entity__c(Name='marketo-rubiks');
        insert entity;
    
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA = true;
        
        Account a = Utility.insertAccountInTestClasses();
        a.BillingCity = 'NewYork';
        a.BillingCountry = 'United States';
        a.BillingStreet = 'Test Street';
        a.BillingState ='Test Billing State';
        a.BillingPostalCode ='12345';
        a.ShippingCity ='Pune';
        a.ShippingCountry ='India';
        a.ShippingPostalCode = '12345';
        a.ShippingState = '';
        a.ShippingStreet = 'Test Shipping Street';  
        a.Intacct_Entity__c=entity.id;
        a.IntacctID__c = 'TestIntacctID123'; 
        a.Name = 'Test Account Name change to make duplicate rule fail';
        a.Website = 'testghj@test.com';
        insert a;
    
        Contact c = Utility.insertContactInTestClasses(a.Id);
        c.firstname ='testingss';
        insert c;
        
        // Create Products
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].Family = 'Lead Management';
        prodList[1].Family = 'Spark Edition';
        prodList[2].Family = 'Select Edition';
        prodList[3].Family = 'Standard Edition';
        prodList[4].Family = 'Real Time Personalization';
        if(!prodList.isEmpty()){
            insert prodList;
        }
        
        // Create Custom Pricebooks
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }
        
        // Get Id of Standard Pricebook
        Id stdPbId = Test.getStandardPricebookId();
        
        // Insert Products into Standard Pricebook
        List<PriceBookEntry> pbEntryStdPbList = new List<PriceBookEntry>();
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }
        
        // Insert Products into Custom Pricebooks
        List<PriceBookEntry> pbEntryList = new List<PriceBookEntry>();
        pbEntryList = TestCPQUtilityClass.createPriceBookEntries(prodList, priceBookList);
        if(!pbEntryList.isEmpty()){
            insert pbEntryList;
        }
        
    
        
        List<Opportunity> oppList = new List<Opportunity>(); 
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id oppClosedwonRecordTypeId =OpportunityRecordTypeInfo.get('Closed Won').getRecordTypeId();
       // Id oppEntSalesRecordTypeId =OpportunityRecordTypeInfo.get('Enterprise Sales').getRecordTypeId();//Enterprise Sales Record type is inactive : Commented by Jade
        Id oppNBRecordTypeId =OpportunityRecordTypeInfo.get('New Business').getRecordTypeId(); 
        
        // Create Opportunity
        Opportunity opp1 = new Opportunity();
        opp1.Name = 'Test Oppty 1';
        opp1.StageName='Prospecting';
        opp1.CloseDate=System.today().addMonths(1);
        opp1.AccountId = a.Id;
        opp1.PriceBook2Id = stdPbId;
        opp1.Intacct_Entity__c = entity.id;
        opp1.Intacct_Sales_Region__c = 'APAC';
        opp1.Rep_Create_ARR__c = 10;
        opp1.MainCompetitor__c = 'Act-On';
        oppList.add(opp1);
    
        Opportunity o = Utility.insertOpportunityInTestClasses(a.id, c.Id, 'Closed Won', 'Renewal',Date.Today(), system.today().addDays(1),system.today().addDays(7), null);        
        
        
        
        // Create opportunity product (line item) list
        /*List<OpportunityLineItem> oppProds = [SELECT Id, Product_Family__c, Users__c, MLM_Edition__c, OpportunityId, 
            PricebookEntry.Product2.Name, PricebookEntry.Product2.Family 
            FROM OpportunityLineItem 
            WHERE OpportunityId IN :oppIds 
            AND (PricebookEntry.Product2.Family = 'Lead Management' OR PricebookEntry.Product2.Family = 'Sales Insight')];
        */
        
        
       /* Product2 prod = [SELECT p.Id FROM Product2 p WHERE p.Name = 'Lead Management - Professional 100K'];
        List<PriceBookEntry> pbe_list = [Select p.Id, p.Name, p.Pricebook2Id, p.Product2Id , p.CreatedById , p.LastModifiedById From PricebookEntry p WHERE
            p.Pricebook2.Name = 'Standard Price Book' and p.Name = 'Lead Management - Professional 100K' and p.IsActive = true];
        PricebookEntry pbe = pbe_list.get(0);
                
        OpportunityLineItem oli = new OpportunityLineItem();
        //oli.Product_Family__c = 'test product family';
        oli.Users__c = 1;
        oli.MLM_Edition__c = 'test edition';
        oli.Opportunity = o;
        oli.PricebookEntry = pbe; */
               
     //   o.RecordTypeid = oppEntSalesRecordTypeId;
        o.RecordTypeid = oppNBRecordTypeId;
        o.Name = 'test2';
        o.Deal_Type__c = 'deal1';
        o.Pricebook2Id = stdPbId; 
        o.Intacct_Entity__c = entity.id;
        o.Intacct_Sales_Region__c = 'APAC';
        
        System.runAs(salesOpsUser){
              
      oppList.add(o);
      test.startTest();
      
            Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
            Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
            Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
            Trigger_Opportunity_Helper.isAfterUpdateEvent = true;
            
          for(Opportunity opp : oppList){
              opp.Payment_Frequency__c = 'Monthly';
          }
            insert oppList;
            //o.RecordType.Name = OpportunityAutoProvisioning.prerequisite_record_type_value;
            
            //Opportunity newOp = [SELECT o.Id, o.RecordType.Name FROM Opportunity o WHERE o.Id = :o.Id];
            
            oppList[1].StageName = OpportunityAutoProvisioning.changed_state_value;
            //oppList[1].RecordType.Name = 'Closed Won';//OpportunityAutoProvisioning.prerequisite_record_type_value;
            oppList[1].RecordTypeid = oppClosedwonRecordTypeId;  
            update oppList;
        }
        /*
        // Insert Oppty Line Items
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = oppList[1].Id;
        oli1.PricebookEntryId = pbEntryStdPbList[0].Id;
        oli1.UnitPrice = 10;
        oli1.Quantity = 20;
        
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = oppList[1].Id;
        oli2.PricebookEntryId = pbEntryStdPbList[1].Id;
        oli2.UnitPrice = 10;
        oli2.Quantity = 20;
        
        OpportunityLineItem oli3 = new OpportunityLineItem();
        oli3.OpportunityId = oppList[1].Id;
        oli3.PricebookEntryId = pbEntryStdPbList[2].Id;
        oli3.UnitPrice = 10;
        oli3.Quantity = 20;
        
        OpportunityLineItem oli4 = new OpportunityLineItem();
        oli4.OpportunityId = oppList[0].Id;
        oli4.PricebookEntryId = pbEntryStdPbList[3].Id;
        oli4.UnitPrice = 10;
        oli4.Quantity = 20;
        
        OpportunityLineItem oli5 = new OpportunityLineItem();
        oli5.OpportunityId = oppList[0].Id;
        oli5.PricebookEntryId = pbEntryStdPbList[4].Id;
        oli5.UnitPrice = 10;
        oli5.Quantity = 20;
        
        oliList.add(oli1);
        oliList.add(oli2);
        oliList.add(oli3);
        oliList.add(oli4);
        oliList.add(oli5);
        insert oliList;*/
    List<OpportunityLineItem> oppotyLineItemList = new List<OpportunityLineItem>();
        oppotyLineItemList = TestCPQUtilityClass.createOppLineItems(oppList,pbEntryStdPbList);
       insert oppotyLineItemList;
    // update oppty
    oppList[0].StageName = 'Closed Won';
        oppList[0].RecordTypeid = oppClosedwonRecordTypeId;  
        oppList[0].Intacct_Entity__c = entity.id;
        oppList[0].Intacct_Sales_Region__c = 'APAC';
        //oppList[0].Third_Party_Solutions__c = 'No';
        test.stoptest();
        Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
        Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
        Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
        Trigger_Opportunity_Helper.isAfterUpdateEvent = true;
        update oppList; 
        
        OpportunityAutoProvisioning.processOpportunities([SELECT Id FROM Opportunity WHERE id IN :oppList]);

    }
}