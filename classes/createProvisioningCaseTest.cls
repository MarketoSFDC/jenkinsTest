@istest
public class createProvisioningCaseTest{
 
     static testmethod void testin(){
       
     MapOpportunityFieldsToProvisioningCase__c custmset=new MapOpportunityFieldsToProvisioningCase__c();
     custmset.name='AccountId';
     custmset.OpportunityFieldName__c='AccountId';
     custmset.isfield__c=true;
     
     MapOpportunityFieldsToProvisioningCase__c custmset1=new MapOpportunityFieldsToProvisioningCase__c();
     custmset1.name='BusinessHoursId';
     custmset1.OpportunityFieldName__c='01m500000004FoA';
     custmset1.isfield__c=false;

     MapOpportunityFieldsToProvisioningCase__c custmset2=new MapOpportunityFieldsToProvisioningCase__c();
     custmset2.name='RecordTypeId';
     custmset2.OpportunityFieldName__c='0126C000000GtdU';
     custmset2.isfield__c=false;
     
     MapOpportunityFieldsToProvisioningCase__c custmset3=new MapOpportunityFieldsToProvisioningCase__c();
     custmset3.name='Opportunity_Type__c';
     custmset3.OpportunityFieldName__c='Type';
     custmset3.isfield__c=true;
     
     MapOpportunityFieldsToProvisioningCase__c custmset4=new MapOpportunityFieldsToProvisioningCase__c();
     custmset4.name='Asset_Name__c';
     custmset4.OpportunityFieldName__c='SBQQ__PrimaryQuote__r.Asset_Name__c';
     custmset4.isfield__c=true;
     
     list<MapOpportunityFieldsToProvisioningCase__c> listmap=new list<MapOpportunityFieldsToProvisioningCase__c>{custmset,custmset1,custmset2,custmset3,custmset4};
     insert listmap;
     SalesTriggersUtility.dlrs_ContractTrigger=true;
     SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
     SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
     SalesTriggersUtility.dlrs_AccountTrigger = true;
     SalesTriggersUtility.AssetTriggerVA  = true;
     account acc=new account(name='testacc',BillingCountry = 'United States',BillingStreet = 'Test Street',BillingState ='Test Billing State',BillingPostalCode ='12345',ShippingCity ='Pune',ShippingCountry ='India',ShippingPostalCode = '12345',ShippingState = '',ShippingStreet = 'Test Shipping Street',Accounting_Email__c = 'test@gmail.com',Accounting_Contact_First_Name__c = 'FirstName',Accounting_Contact_Last_Name__c = 'LastName',Website = 'www.google.com',MA_Edition__c ='Edition',RTP_Suite__c = 'Suite',Add_On_Subscriptions__c ='Subscription',Services__c = 'Sevices',Support__c ='Support');
     insert acc;
        // Create Custom Pricebooks
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }
      SteelBrickCPQPricebook__c obj = new SteelBrickCPQPricebook__c();
        obj.Name = 'SteelBrick PB';
        obj.ID__c = priceBookList[0].Id;
        insert obj;
     Test.startTest();
     SalesTriggersUtility.dlrs_ContractTrigger=true;
     SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
     SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
     SalesTriggersUtility.dlrs_AccountTrigger = true;
     SalesTriggersUtility.AssetTriggerVA  = true;
     Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
     Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
     Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
    Trigger_Opportunity_Helper.isAfterUpdateEvent = true;
     opportunity opp=new opportunity(Name='Opportunity',type='New Business',StageName='Prospecting',Rep_Create_ARR__c=1234,CloseDate=System.today().addMonths(1),AccountId=acc.Id,Pricebook2Id=priceBookList[0].Id,MainCompetitor__c='Act-On');
     opp.Deal_Type__c='University';
     opp.Name = 'University Test Class Validation'; 
     insert opp;
     
    
     Product2 product = new Product2(Name = 'Test Product', ProductCode = 'TESTPRODCODE', isActive=TRUE,Family='Support',MA_or_RTP__c ='RTP',Visible_To_Customer__c = true,Product_Type__c='Subscription');
     Product2 product1 = new Product2(Name = 'Test Product', ProductCode = 'TESTPRODCODE', isActive=TRUE,Family='Support',MA_or_RTP__c ='RTP',Visible_To_Customer__c = true,Product_Type__c='Services');
     Product2 product2 = new Product2(Name = 'Test Product', ProductCode = 'TESTPRODCODE', isActive=TRUE,Family='Support',MA_or_RTP__c ='RTP',Visible_To_Customer__c = true,Product_Type__c='Services');
     Product2 product3 = new Product2(Name = 'Test Product', ProductCode = 'TESTPRODCODE', isActive=TRUE,Family='Support',MA_or_RTP__c ='RTP',Visible_To_Customer__c = true,Product_Type__c='Services');
     list<Product2> prodlist=new list<Product2>{product,product1,product2,product3};
     insert prodlist;
     
     id standardpricebookid=Test.getstandardpricebookid();
     
     PriceBookEntry pbe = new PriceBookEntry (Product2Id = product.id, PriceBook2Id = standardpricebookid, UnitPrice = 10, isActive = TRUE);
     PriceBookEntry pbe2 = new PriceBookEntry (Product2Id = product1.id, PriceBook2Id = standardpricebookid, UnitPrice = 10, isActive = TRUE);
     PriceBookEntry pbe3 = new PriceBookEntry (Product2Id = product2.id, PriceBook2Id = standardpricebookid ,UnitPrice = 10, isActive = TRUE);
     PriceBookEntry pbe4 = new PriceBookEntry (Product2Id = product3.id, PriceBook2Id =  standardpricebookid, UnitPrice = 10, isActive = TRUE);
     list<PriceBookEntry> pbelist1=new list<PriceBookEntry>{pbe,pbe2,pbe3,pbe4};
     insert pbelist1;
     
      PriceBookEntry pbe5 = new PriceBookEntry (Product2Id = product.id, PriceBook2Id = priceBookList[0].Id, UnitPrice = 10, isActive = TRUE);
     PriceBookEntry pbe6 = new PriceBookEntry (Product2Id = product1.id, PriceBook2Id = priceBookList[0].Id, UnitPrice = 10, isActive = TRUE);
     PriceBookEntry pbe7 = new PriceBookEntry (Product2Id = product2.id, PriceBook2Id = priceBookList[0].Id ,UnitPrice = 10, isActive = TRUE);
     PriceBookEntry pbe8 = new PriceBookEntry (Product2Id = product3.id, PriceBook2Id =  priceBookList[0].Id, UnitPrice = 10, isActive = TRUE);
     list<PriceBookEntry> pbelist=new list<PriceBookEntry>{pbe5,pbe6,pbe7,pbe8};
     insert pbelist;
     
     OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe5.Id, UnitPrice = 10, Quantity = 20);
     OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = opp.Id, PricebookEntryId = pbe6.Id, UnitPrice = 10, Quantity = 20);
     list<OpportunityLineItem> olilist=new list<OpportunityLineItem>{oli,oli2};
     insert olilist;
     
     SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opp.id,SBQQ__Account__c=acc.id, SBQQ__StartDate__c = System.Today(),Order_Type__c ='123',Rubiks_Quote__c=True);
     insert quote ;
     
     if(!olilist.IsEmpty()){
     olilist[0].servicedate=quote.SBQQ__StartDate__c;
     olilist[1].servicedate=quote.SBQQ__StartDate__c;
     olilist[0].Product_Type__c='Subscription';
     olilist[1].Product_Type__c='Subscription';
     
     update olilist;
     }
     Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
  Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
  Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
  Trigger_Opportunity_Helper.isAfterUpdateEvent = true;
     opp.Stage_Signed_Order_Date__c=system.Today();
     opp.SBQQ__PrimaryQuote__c  = quote.id;
     opp.Probability = 1;
     opp.Split_Opportunities__c = null;
     opp.Ghost__c = False ;
     opp.pse__Primary_Project__c = null;
     opp.Total_Assigned_Hours__c = 100;
     opp.Deal_Type__c='University';
     opp.Intacct_Sales_Region__c = 'AMERICAS';
     opp.Name = 'University Test Class Validation';
     opp.stagename='Closed Won';
     update opp;
     
     //// Creating MDQ Opportunity
     
     
     list<opportunity> listopp=new list<opportunity>{opp};
     createProvisioningCaseFromOpportunity.createProvisioningCase(listopp);
     Test.stopTest();
    }
    
    static testmethod void testin3(){
      
     MapOpportunityFieldsToProvisioningCase__c custmset=new MapOpportunityFieldsToProvisioningCase__c();
     custmset.name='AccountId';
     custmset.OpportunityFieldName__c='AccountId';
     custmset.isfield__c=true;
     
     MapOpportunityFieldsToProvisioningCase__c custmset1=new MapOpportunityFieldsToProvisioningCase__c();
     custmset1.name='BusinessHoursId';
     custmset1.OpportunityFieldName__c='01m500000004FoA';
     custmset1.isfield__c=false;

     MapOpportunityFieldsToProvisioningCase__c custmset2=new MapOpportunityFieldsToProvisioningCase__c();
     custmset2.name='RecordTypeId';
     custmset2.OpportunityFieldName__c='0126C000000GtdU';
     custmset2.isfield__c=false;
     
     MapOpportunityFieldsToProvisioningCase__c custmset3=new MapOpportunityFieldsToProvisioningCase__c();
     custmset3.name='Opportunity_Type__c';
     custmset3.OpportunityFieldName__c='Type';
     custmset3.isfield__c=true;
     
     MapOpportunityFieldsToProvisioningCase__c custmset4=new MapOpportunityFieldsToProvisioningCase__c();
     custmset4.name='Asset_Name__c';
     custmset4.OpportunityFieldName__c='SBQQ__PrimaryQuote__r.Asset_Name__c';
     custmset4.isfield__c=true;
     
     list<MapOpportunityFieldsToProvisioningCase__c> listmap=new list<MapOpportunityFieldsToProvisioningCase__c>{custmset,custmset1,custmset2,custmset3,custmset4};
     insert listmap;
     SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
     account acc=new account(name='testacc',BillingCountry = 'United States',BillingStreet = 'Test Street',BillingState ='Test Billing State',BillingPostalCode ='12345',ShippingCity ='Pune',ShippingCountry ='India',ShippingPostalCode = '12345',ShippingState = '',ShippingStreet = 'Test Shipping Street',Accounting_Email__c = 'test@gmail.com',Accounting_Contact_First_Name__c = 'FirstName',Accounting_Contact_Last_Name__c = 'LastName',Website = 'www.google.com',MA_Edition__c ='Edition',RTP_Suite__c = 'Suite',Add_On_Subscriptions__c ='Subscription',Services__c = 'Sevices',Support__c ='Support');
     insert acc;

     Product2 product = new Product2(Name = 'Test Product', ProductCode = 'TESTPRODCODE', isActive=TRUE,Family='Support',MA_or_RTP__c ='RTP',Visible_To_Customer__c = true,Product_Type__c='Subscription');
     Product2 product1 = new Product2(Name = 'Test Product', ProductCode = 'TESTPRODCODE', isActive=TRUE,Family='Support',MA_or_RTP__c ='RTP',Visible_To_Customer__c = true,Product_Type__c='Subscription');
     Product2 product2 = new Product2(Name = 'Test Product', ProductCode = 'TESTPRODCODE', isActive=TRUE,Family='Support',MA_or_RTP__c ='RTP',Visible_To_Customer__c = true,Product_Type__c='Services');
     Product2 product3 = new Product2(Name = 'Test Product', ProductCode = 'TESTPRODCODE', isActive=TRUE,Family='Support',MA_or_RTP__c ='RTP',Visible_To_Customer__c = true,Product_Type__c='Services');
     list<Product2> prodlist=new list<Product2>{product,product1,product2,product3};
     insert prodlist;
     
     id standardpricebookid=Test.getstandardpricebookid();
     
     PriceBookEntry pbe = new PriceBookEntry (Product2Id = product.id, PriceBook2Id = standardpricebookid, UnitPrice = 10, isActive = TRUE);
     PriceBookEntry pbe2 = new PriceBookEntry (Product2Id = product1.id, PriceBook2Id = standardpricebookid, UnitPrice = 10, isActive = TRUE);
     PriceBookEntry pbe3 = new PriceBookEntry (Product2Id = product2.id, PriceBook2Id = standardpricebookid, UnitPrice = 10, isActive = TRUE);
     PriceBookEntry pbe4 = new PriceBookEntry (Product2Id = product3.id, PriceBook2Id = standardpricebookid, UnitPrice = 10, isActive = TRUE);
     list<PriceBookEntry> pbelist=new list<PriceBookEntry>{pbe,pbe2,pbe3,pbe4};
     insert pbelist;
     
      //Insert data in SBPB custom setting 
     SteelBrickCPQPricebook__c SBPB=new SteelBrickCPQPricebook__c(Case_Safe_ID__c='01s50000000OEDvAAO',ID__c=standardpricebookid);
     insert SBPB;  
     system.debug('################### SBPB'+SBPB.ID__c);
     Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
  Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
  Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
  Trigger_Opportunity_Helper.isAfterUpdateEvent = true;
     //// Creating MDQ Opportunity
     opportunity opp2=new opportunity(Name='Opportunity',type='New Business',StageName='Prospecting',Rep_Create_ARR__c=1234,CloseDate=System.today().addMonths(1),AccountId=acc.Id,PriceBook2Id=standardpricebookid,MainCompetitor__c='Act-On');
     opp2.Deal_Type__c='University';
     opp2.Name = 'University Test Class Validation';
     insert opp2;
     
     SBQQ__Quote__c quote2 = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opp2.id,SBQQ__Account__c=acc.id, SBQQ__StartDate__c = System.Today(),Order_Type__c ='123',Mdq_quote__c = true);
     insert quote2 ;
     
     
      
      //********* Inserting Bundle Line ***********
        List<SBQQ__QuoteLine__c> quoteLinesToInsertParent = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLineParent = new SBQQ__QuoteLine__c( SBQQ__Quote__c=quote2.Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[0].id);
        quoteLinesToInsertParent.add(quoteLineParent);
        insert quoteLinesToInsertParent;
        system.debug('############### quoteLinesToInsertParent'+quoteLinesToInsertParent);
        Test.StartTest();
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        //******** Inserting Quote Lines under the Bundle *********
        
        List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=quote2.Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=System.Today(),SBQQ__EndDate__c=quote2.SBQQ__StartDate__c.addMonths(3),SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=10,SBQQ__NetPrice__c=50000,MKTO_Effective_End_Date__c=system.today().addMonths(10),Product_Type__c='Subscription');
        
        SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=quote2.Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__EndDate__c=System.Today().addMonths(3),SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=10,SBQQ__NetPrice__c=40000,MKTO_Effective_End_Date__c=system.today().addMonths(10),Product_Type__c='Subscription');
        
        SBQQ__QuoteLine__c quoteLine3 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=quote2.Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=System.Today(),SBQQ__EndDate__c=System.Today().addMonths(3),SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=7,SBQQ__NetPrice__c=60000,MKTO_Effective_End_Date__c=system.today().addMonths(7),Product_Type__c='Subscription');
       
        SBQQ__QuoteLine__c quoteLine4 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=quote2.Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[2].id,SBQQ__RegularPrice__c = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=System.Today(),SBQQ__EndDate__c=System.Today().addMonths(3),SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=7,SBQQ__NetPrice__c=80000,MKTO_Effective_End_Date__c=system.today().addMonths(7),Product_Type__c='Subscription');
       
        SBQQ__QuoteLine__c quoteLine5 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote2.Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=System.Today(),SBQQ__EndDate__c=System.Today().addMonths(3),SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=7,SBQQ__NetPrice__c=60000,MKTO_Effective_End_Date__c=system.today().addMonths(7),Product_Type__c='Subscription');
       
        SBQQ__QuoteLine__c quoteLine6 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote2.Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[2].id,SBQQ__RegularPrice__c = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=System.Today(),SBQQ__EndDate__c=System.Today().addMonths(3),SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=7,SBQQ__NetPrice__c=80000,MKTO_Effective_End_Date__c=system.today().addMonths(7),Product_Type__c='Subscription');
       
        quoteLinesToInsert.add(quoteLine1);
        quoteLinesToInsert.add(quoteLine2);
        quoteLinesToInsert.add(quoteLine3);
        quoteLinesToInsert.add(quoteLine4);
        quoteLinesToInsert.add(quoteLine5);
        quoteLinesToInsert.add(quoteLine6);
        insert quoteLinesToInsert;
        
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = opp2.Id, PricebookEntryId = pbe3.id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLine1.id,servicedate=system.today());
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = opp2.Id, PricebookEntryId = pbe4.id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLine2.id,servicedate=system.today());
        OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId = opp2.Id, PricebookEntryId = pbe3.id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLine2.id,servicedate=system.today());
        OpportunityLineItem oli4 = new OpportunityLineItem(OpportunityId = opp2.Id, PricebookEntryId = pbe4.id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLine4.id,servicedate=system.today());
        OpportunityLineItem oli5 = new OpportunityLineItem(OpportunityId = opp2.Id, PricebookEntryId = pbe3.id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLine5.id,servicedate=system.today());
        OpportunityLineItem oli6 = new OpportunityLineItem(OpportunityId = opp2.Id, PricebookEntryId = pbe4.id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLine6.id,servicedate=system.today());
        list<OpportunityLineItem> olilist2=new list<OpportunityLineItem>{oli1,oli2,oli3,oli4,oli5};
        insert olilist2;
     
     Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
  Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
  Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
  Trigger_Opportunity_Helper.isAfterUpdateEvent = true;
        opp2.SBQQ__PrimaryQuote__c  = quote2.id;
        update opp2;
     
       
        list<opportunity> listopp=new list<opportunity>{opp2};
        createProvisioningCaseFromOpportunity.createProvisioningCase(listopp);
        Test.stopTest();
		QuoteLine_Handler.setQLI();
            
    }
    static testmethod void testMethod3(){

        MapOpportunityFieldsToProvisioningCase__c custmset=new MapOpportunityFieldsToProvisioningCase__c();
        custmset.name='AccountId';
        custmset.OpportunityFieldName__c='AccountId';
        custmset.isfield__c=true;

        MapOpportunityFieldsToProvisioningCase__c custmset1=new MapOpportunityFieldsToProvisioningCase__c();
        custmset1.name='BusinessHoursId';
        custmset1.OpportunityFieldName__c='01m500000004FoA';
        custmset1.isfield__c=false;

        MapOpportunityFieldsToProvisioningCase__c custmset2=new MapOpportunityFieldsToProvisioningCase__c();
        custmset2.name='RecordTypeId';
        custmset2.OpportunityFieldName__c='0126C000000GtdU';
        custmset2.isfield__c=false;

        MapOpportunityFieldsToProvisioningCase__c custmset3=new MapOpportunityFieldsToProvisioningCase__c();
        custmset3.name='Opportunity_Type__c';
        custmset3.OpportunityFieldName__c='Type';
        custmset3.isfield__c=true;

        MapOpportunityFieldsToProvisioningCase__c custmset4=new MapOpportunityFieldsToProvisioningCase__c();
        custmset4.name='Asset_Name__c';
        custmset4.OpportunityFieldName__c='SBQQ__PrimaryQuote__r.Asset_Name__c';
        custmset4.isfield__c=true;

        list<MapOpportunityFieldsToProvisioningCase__c> listmap=new list<MapOpportunityFieldsToProvisioningCase__c>{custmset,custmset1,custmset2,custmset3,custmset4};
        insert listmap;

        //Insert Account
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        List<Account> accountsToBeInsertedList = new List<Account>();
        accountsToBeInsertedList = TestCPQUtilityClass.createAccounts(1);
        for(Account accnt :accountsToBeInsertedList){
            accnt.name = 'Marketo Inc';
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.PO_Required__c = true;
            accnt.ABN_No__c = '12345';
            accnt.Registered_VAT_No__c = '456789';
        }
        if(!accountsToBeInsertedList.isEmpty()){
            insert accountsToBeInsertedList;
        }       

        // Add products
        List<Product2> productToInsertList = new List<Product2>();
        productToInsertList =TestCPQUtilityClass.createCustomProducts(5);
        if(!productToInsertList.isEmpty()){
            insert productToInsertList;
        }

        // Insert MKTO Std PB.
        Pricebook2 mktoPB = new PriceBook2(name='MKTO STD PB', isActive=TRUE);
        insert mktoPB;
        
        list<Pricebook2> listPB = new list<Pricebook2>();
        listPB.add(mktoPB);
        
        //Inserting PricebookEntries for Standard PB
        id StdPBId = Test.getStandardPricebookId();
       TestCPQUtilityClass.createStdPricebookEntries(productToInsertList,StdPBId);
        
        //Inserting PricebookEntries for Custom PB
        List<PriceBookEntry> listPBE = new List<PriceBookEntry>();
        listPBE = TestCPQUtilityClass.createPriceBookEntries(productToInsertList,listPB);
        for(PriceBookEntry pbe: listPBE){
            pbe.UnitPrice = 10;
        }
        insert listPBE;

        // Insert custom setting data - SteelBrickCPQPricebook__c
        SteelBrickCPQPricebook__c mktoPBCustSet = new SteelBrickCPQPricebook__c(Case_Safe_ID__c = 'MKTO Case Safe Id', ID__c = mktoPB.Id);
        insert mktoPBCustSet;

        // Insert New Business Opportunities - Set Steelbrick PB
        Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
  Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
  Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
  Trigger_Opportunity_Helper.isAfterUpdateEvent = true;
        List<Opportunity> OpptyToBeInsertedList = new List<Opportunity>();
        OpptyToBeInsertedList = TestCPQUtilityClass.createOpportunities(accountsToBeInsertedList,1);
        OpptyToBeInsertedList[0].type='New Business';
        OpptyToBeInsertedList[0].Pricebook2Id = mktoPB.Id;
        OpptyToBeInsertedList[0].MainCompetitor__c  = 'Act-On';
        insert OpptyToBeInsertedList;

        // Insert SB Quotes
        List<SBQQ__Quote__c> quotesToBeInsertedList = new List<SBQQ__Quote__c>();
        quotesToBeInsertedList = TestCPQUtilityClass.createQuotes(OpptyToBeInsertedList,1);
        quotesToBeInsertedList[0].Marketing_Permission__c = 'Marketing_Permission__c';
        quotesToBeInsertedList[0].Case_Study_Permission__c = 'Case_Study_Permission__c';
        quotesToBeInsertedList[0].Custom_Agreement_Name_and_Date__c = 'Custom_Agreement_Name_and_Date__c';
        quotesToBeInsertedList[0].SBQQ__PaymentTerms__c = 'SBQQ__PaymentTerms__c';
        quotesToBeInsertedList[0].Payment_Frequency__c = 'Payment_Frequency__c';
        quotesToBeInsertedList[0].Hide_Discount__c = true;
        quotesToBeInsertedList[0].Enterprise_Roll_up_SKU__c = true;
        quotesToBeInsertedList[0].Renewal_Uplift_pct__c = '7%';
        quotesToBeInsertedList[0].Renewal_Uplift_Text__c = 'Renewal_Uplift_Text__c';
        quotesToBeInsertedList[0].PO_Number__c = '12345';
        quotesToBeInsertedList[0].PO_Required__c = true;
        quotesToBeInsertedList[0].SBQQ__Primary__c = true;
        insert quotesToBeInsertedList;

        Test.StartTest();
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        //Insert Quote Lines
        List<SBQQ__QuoteLine__c> listQuoteLinesToBeInserted = new List<SBQQ__QuoteLine__c>();
        listQuoteLinesToBeInserted = TestCPQUtilityClass.createQuoteLines(quotesToBeInsertedList,5,productToInsertList);
        listQuoteLinesToBeInserted[0].SBQQ__RequiredBy__c = null;
        /*for(SBQQ__QuoteLine__c qli: listQuoteLinesToBeInserted){
            qli.SBQQ__ProductOption__r.SBQQ__QuoteLineVisibility__c = 'Document Only';
        }*/
     /*  Today */ insert listQuoteLinesToBeInserted;
        
     /*   listQuoteLinesToBeInserted[1].SBQQ__RequiredBy__c = listQuoteLinesToBeInserted[0].id;
        listQuoteLinesToBeInserted[2].SBQQ__RequiredBy__c = listQuoteLinesToBeInserted[0].id;
        listQuoteLinesToBeInserted[3].SBQQ__RequiredBy__c = listQuoteLinesToBeInserted[0].id;
        listQuoteLinesToBeInserted[4].SBQQ__RequiredBy__c = listQuoteLinesToBeInserted[0].id;
        update listQuoteLinesToBeInserted; */

        //Inserting OpportunityLines
   /* Today  */  List<OpportunityLineItem> listOLIs = new  List<OpportunityLineItem>();
        listOLIs = TestCPQUtilityClass.createOppLineItems(OpptyToBeInsertedList,listPBE);
        For(integer i=0; i < listOLIs.size(); i++){
            listOLIs[i].SBQQ__QuoteLine__c = listQuoteLinesToBeInserted[i].id;
            listOLIs[i].Product_Type__c = 'Subscription';
        }
        listOLIs[3].Product_Type__c = 'Sevices';
        insert listOLIs;
        
        // Update Opportunity as Closed Won  - Fetch Opp Record Type
        Schema.DescribeSObjectResult descOppSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> oppRecordTypeInfo = descOppSchema.getRecordTypeInfosByName(); 
        Id closedWonRecTypeId = oppRecordTypeInfo.get('Closed Won').getRecordTypeId();
        Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
  Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
  Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
  Trigger_Opportunity_Helper.isAfterUpdateEvent = true;
        OpptyToBeInsertedList[0].Stage_Signed_Order_Date__c=system.Today();
        OpptyToBeInsertedList[0].RecordTypeId = closedWonRecTypeId;
        OpptyToBeInsertedList[0].Total_Assigned_Hours__c = 100;
        OpptyToBeInsertedList[0].StageName = 'Closed Won';

        update OpptyToBeInsertedList;
        Test.StopTest();
    }//End of testMethod3() 
    
    static testmethod void testAddingDropping3(){

        MapOpportunityFieldsToProvisioningCase__c custmset=new MapOpportunityFieldsToProvisioningCase__c();
        custmset.name='AccountId';
        custmset.OpportunityFieldName__c='AccountId';
        custmset.isfield__c=true;

        MapOpportunityFieldsToProvisioningCase__c custmset1=new MapOpportunityFieldsToProvisioningCase__c();
        custmset1.name='BusinessHoursId';
        custmset1.OpportunityFieldName__c='01m500000004FoA';
        custmset1.isfield__c=false;

        MapOpportunityFieldsToProvisioningCase__c custmset2=new MapOpportunityFieldsToProvisioningCase__c();
        custmset2.name='RecordTypeId';
        custmset2.OpportunityFieldName__c='0126C000000GtdU';
        custmset2.isfield__c=false;

        MapOpportunityFieldsToProvisioningCase__c custmset3=new MapOpportunityFieldsToProvisioningCase__c();
        custmset3.name='Opportunity_Type__c';
        custmset3.OpportunityFieldName__c='Type';
        custmset3.isfield__c=true;

        MapOpportunityFieldsToProvisioningCase__c custmset4=new MapOpportunityFieldsToProvisioningCase__c();
        custmset4.name='Asset_Name__c';
        custmset4.OpportunityFieldName__c='SBQQ__PrimaryQuote__r.Asset_Name__c';
        custmset4.isfield__c=true;

        list<MapOpportunityFieldsToProvisioningCase__c> listmap=new list<MapOpportunityFieldsToProvisioningCase__c>{custmset,custmset1,custmset2,custmset3,custmset4};
        insert listmap;

        //Insert Account
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        List<Account> accountsToBeInsertedList = new List<Account>();
        accountsToBeInsertedList = TestCPQUtilityClass.createAccounts(1);
        for(Account accnt :accountsToBeInsertedList){
            accnt.name = 'Marketo Inc';
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.PO_Required__c = true;
            accnt.ABN_No__c = '12345';
            accnt.Registered_VAT_No__c = '456789';
        }
        if(!accountsToBeInsertedList.isEmpty()){
            insert accountsToBeInsertedList;
        }       

        // Add products
        List<Product2> productToInsertList = new List<Product2>();
        productToInsertList =TestCPQUtilityClass.createCustomProducts(5);
        for(Product2 prdtObj :productToInsertList){
            prdtObj.Family = 'Bundle';
            prdtObj.Product_Type__c = 'Subscription';
        }
        if(!productToInsertList.isEmpty()){
            insert productToInsertList;
        }

        // Insert MKTO Std PB.
        Pricebook2 mktoPB = new PriceBook2(name='MKTO STD PB', isActive=TRUE);
        insert mktoPB;
        
        list<Pricebook2> listPB = new list<Pricebook2>();
        listPB.add(mktoPB);
        system.assertEquals(1,listPB.size());
        system.assertEquals(mktoPB,listPB[0]);
        //Inserting PricebookEntries for Standard PB
        id StdPBId = Test.getStandardPricebookId();
        TestCPQUtilityClass.createStdPricebookEntries(productToInsertList,StdPBId);
        
        //Inserting PricebookEntries for Custom PB
        List<PriceBookEntry> listPBE = new List<PriceBookEntry>();
        listPBE = TestCPQUtilityClass.createPriceBookEntries(productToInsertList,listPB);
        for(PriceBookEntry pbe: listPBE){
            pbe.UnitPrice = 10;
            pbe.PriceBook2Id  =mktoPB.Id;
        }
        insert listPBE;

        // Insert custom setting data - SteelBrickCPQPricebook__c
        SteelBrickCPQPricebook__c mktoPBCustSet = new SteelBrickCPQPricebook__c(Case_Safe_ID__c = mktoPB.Id, ID__c = mktoPB.Id);
        insert mktoPBCustSet;

        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        // Insert New Business Opportunities - Set Steelbrick PB
        Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
  Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
  Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
  Trigger_Opportunity_Helper.isAfterUpdateEvent = true;
        List<Opportunity> OpptyToBeInsertedList = new List<Opportunity>();
        OpptyToBeInsertedList = TestCPQUtilityClass.createOpportunities(accountsToBeInsertedList,2);
        OpptyToBeInsertedList[0].type='Renewal';
        OpptyToBeInsertedList[0].Pricebook2Id = mktoPB.Id;
        OpptyToBeInsertedList[1].Pricebook2Id = mktoPB.Id;
        OpptyToBeInsertedList[0].MainCompetitor__c  = 'Act-On';
        OpptyToBeInsertedList[1].type='Renewal';
        OpptyToBeInsertedList[0].Deal_Type__c='University';
        OpptyToBeInsertedList[0].Name = 'University Test Class Validation';
        OpptyToBeInsertedList[1].Deal_Type__c='University';
        OpptyToBeInsertedList[1].Name = 'University Test Class Validation';
        insert OpptyToBeInsertedList;

        // Insert SB Quotes
        List<SBQQ__Quote__c> quotesToBeInsertedList = new List<SBQQ__Quote__c>();
        quotesToBeInsertedList = TestCPQUtilityClass.createQuotes(OpptyToBeInsertedList,1);
        quotesToBeInsertedList[0].Marketing_Permission__c = 'Marketing_Permission__c';
        quotesToBeInsertedList[0].Case_Study_Permission__c = 'Case_Study_Permission__c';
        quotesToBeInsertedList[0].Custom_Agreement_Name_and_Date__c = 'Custom_Agreement_Name_and_Date__c';
        quotesToBeInsertedList[0].SBQQ__PaymentTerms__c = 'SBQQ__PaymentTerms__c';
        quotesToBeInsertedList[0].Payment_Frequency__c = 'Payment_Frequency__c';
        quotesToBeInsertedList[0].Hide_Discount__c = true;
        quotesToBeInsertedList[0].Enterprise_Roll_up_SKU__c = true;
        quotesToBeInsertedList[0].Renewal_Uplift_pct__c = '7%';
        quotesToBeInsertedList[0].Renewal_Uplift_Text__c = 'Renewal_Uplift_Text__c';
        quotesToBeInsertedList[0].PO_Number__c = '12345';
        quotesToBeInsertedList[0].PO_Required__c = true;
        quotesToBeInsertedList[0].SBQQ__Primary__c = true;
        quotesToBeInsertedList[0].SBQQ__PriceBook__c = mktoPB.Id;
        insert quotesToBeInsertedList;

        system.assertEquals(2,quotesToBeInsertedList.size());       
        
        Test.StartTest();
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        //Insert Quote Lines
        List<SBQQ__QuoteLine__c> listQuoteLinesToBeInserted = new List<SBQQ__QuoteLine__c>();
        listQuoteLinesToBeInserted = TestCPQUtilityClass.createQuoteLines(quotesToBeInsertedList,5,productToInsertList);
        listQuoteLinesToBeInserted[0].SBQQ__RequiredBy__c = null;
        listQuoteLinesToBeInserted[0].Product_Family__c = 'Bundle';
        listQuoteLinesToBeInserted[1].Product_Family__c = 'Bundle';
        listQuoteLinesToBeInserted[0].Product_Type__c ='Subscription';
        listQuoteLinesToBeInserted[1].Product_Type__c ='Subscription';
        listQuoteLinesToBeInserted[0].SBQQ__Bundled__c = true;
        listQuoteLinesToBeInserted[1].SBQQ__Bundled__c = true;
        
        /*for(SBQQ__QuoteLine__c qli: listQuoteLinesToBeInserted){
            qli.SBQQ__ProductOption__r.SBQQ__QuoteLineVisibility__c = 'Document Only';
        }*/
  /* Today */ insert listQuoteLinesToBeInserted;
    
        listQuoteLinesToBeInserted[1].SBQQ__RequiredBy__c = listQuoteLinesToBeInserted[0].id;
        listQuoteLinesToBeInserted[2].SBQQ__RequiredBy__c = listQuoteLinesToBeInserted[0].id;
        listQuoteLinesToBeInserted[3].SBQQ__RequiredBy__c = listQuoteLinesToBeInserted[0].id;
        listQuoteLinesToBeInserted[4].SBQQ__RequiredBy__c = listQuoteLinesToBeInserted[0].id; 
        //update listQuoteLinesToBeInserted;
        
        Test.StopTest();

        //Inserting OpportunityLines
        List<OpportunityLineItem> listOLIs = new  List<OpportunityLineItem>();
        listOLIs = TestCPQUtilityClass.createOppLineItems(OpptyToBeInsertedList,listPBE);
        system.assertEquals(OpptyToBeInsertedList[0].Pricebook2Id,OpptyToBeInsertedList[1].Pricebook2Id);
        For(integer i=0; i < listOLIs.size(); i++){
            listOLIs[i].SBQQ__QuoteLine__c = listQuoteLinesToBeInserted[i].id;
            listOLIs[i].Product_Type__c = 'Subscription';
        
        } 
        listOLIs[3].Product_Type__c = 'Services';
        insert listOLIs;
        List<OpportunityLineItem> listOLIs1=[select id,SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__c from OpportunityLineItem where Id IN :listOLIs];
        // system.assertEquals(listQuoteLinesToBeInserted[1].id, listOLIs1[0].SBQQ__QuoteLine__r.SBQQ__RequiredBy__c);
        //   system.debug('listOLIs1==='+listOLIs1);
        // Update Opportunity as Closed Won  - Fetch Opp Record Type
        Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
        Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
        Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
        Trigger_Opportunity_Helper.isAfterUpdateEvent = true;
        Schema.DescribeSObjectResult descOppSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> oppRecordTypeInfo = descOppSchema.getRecordTypeInfosByName(); 
        Id closedWonRecTypeId = oppRecordTypeInfo.get('Closed Won').getRecordTypeId();
        OpptyToBeInsertedList[0].Stage_Signed_Order_Date__c=system.Today();
        OpptyToBeInsertedList[0].RecordTypeId = closedWonRecTypeId;
        OpptyToBeInsertedList[0].Probability = 1;
        OpptyToBeInsertedList[0].Split_Opportunities__c = null;
        OpptyToBeInsertedList[0].Ghost__c = False ;
        OpptyToBeInsertedList[0].pse__Primary_Project__c = null;
        OpptyToBeInsertedList[0].Total_Assigned_Hours__c = 100;
        OpptyToBeInsertedList[0].StageName = 'Closed Won';
        OpptyToBeInsertedList[1].RecordTypeId = closedWonRecTypeId;
        OpptyToBeInsertedList[1].Probability = 1;
        OpptyToBeInsertedList[1].Split_Opportunities__c = null;
        OpptyToBeInsertedList[1].Ghost__c = False ;
        OpptyToBeInsertedList[1].pse__Primary_Project__c = null;
        OpptyToBeInsertedList[1].Prior_Opportunity__c =OpptyToBeInsertedList[0].id;
        OpptyToBeInsertedList[0].SBQQ__PrimaryQuote__c=quotesToBeInsertedList[0].id;
        OpptyToBeInsertedList[1].Total_Assigned_Hours__c = 100;
        OpptyToBeInsertedList[1].StageName = 'Closed Won'; 
        update OpptyToBeInsertedList;
  
    }//End of testMethod3()
    
      static testmethod void testMDQCase(){

        MapOpportunityFieldsToProvisioningCase__c custmset=new MapOpportunityFieldsToProvisioningCase__c();
        custmset.name='AccountId';
        custmset.OpportunityFieldName__c='AccountId';
        custmset.isfield__c=true;

        MapOpportunityFieldsToProvisioningCase__c custmset1=new MapOpportunityFieldsToProvisioningCase__c();
        custmset1.name='BusinessHoursId';
        custmset1.OpportunityFieldName__c='01m500000004FoA';
        custmset1.isfield__c=false;

        MapOpportunityFieldsToProvisioningCase__c custmset2=new MapOpportunityFieldsToProvisioningCase__c();
        custmset2.name='RecordTypeId';
        custmset2.OpportunityFieldName__c='0126C000000GtdU';
        custmset2.isfield__c=false;

        MapOpportunityFieldsToProvisioningCase__c custmset3=new MapOpportunityFieldsToProvisioningCase__c();
        custmset3.name='Opportunity_Type__c';
        custmset3.OpportunityFieldName__c='Type';
        custmset3.isfield__c=true;

        MapOpportunityFieldsToProvisioningCase__c custmset4=new MapOpportunityFieldsToProvisioningCase__c();
        custmset4.name='Asset_Name__c';
        custmset4.OpportunityFieldName__c='SBQQ__PrimaryQuote__r.Asset_Name__c';
        custmset4.isfield__c=true;

        list<MapOpportunityFieldsToProvisioningCase__c> listmap=new list<MapOpportunityFieldsToProvisioningCase__c>{custmset,custmset1,custmset2,custmset3,custmset4};
        insert listmap;
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA  = true;
        //Insert Account
        List<Account> accountsToBeInsertedList = new List<Account>();
        accountsToBeInsertedList = TestCPQUtilityClass.createAccounts(1);
        for(Account accnt :accountsToBeInsertedList){
            accnt.name = 'Marketo Inc';
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.PO_Required__c = true;
           accnt.ABN_No__c = '12345';
            accnt.Registered_VAT_No__c = '456789';
        }
        if(!accountsToBeInsertedList.isEmpty()){
           insert accountsToBeInsertedList;
        }       

        // Add products
        List<Product2> productToInsertList = new List<Product2>();
        productToInsertList =TestCPQUtilityClass.createCustomProducts(5);
        for(Product2 prdtObj :productToInsertList){
            prdtObj.Family = 'Bundle';
            prdtObj.Product_Type__c = 'Subscription';
        }
        if(!productToInsertList.isEmpty()){
            insert productToInsertList;
        }

        // Insert MKTO Std PB.
        Pricebook2 mktoPB = new PriceBook2(name='MKTO STD PB', isActive=TRUE);
        insert mktoPB;
         
        
        list<Pricebook2> listPB = new list<Pricebook2>();
        listPB.add(mktoPB);
        
        //Inserting PricebookEntries for Standard PB
        id StdPBId = Test.getStandardPricebookId();
        TestCPQUtilityClass.createStdPricebookEntries(productToInsertList,StdPBId);
        
        //Inserting PricebookEntries for Custom PB
        List<PriceBookEntry> listPBE = new List<PriceBookEntry>();
        listPBE = TestCPQUtilityClass.createPriceBookEntries(productToInsertList,listPB);
        for(PriceBookEntry pbe: listPBE){
            pbe.UnitPrice = 10;
        }
        insert listPBE;

        // Insert custom setting data - SteelBrickCPQPricebook__c
        SteelBrickCPQPricebook__c mktoPBCustSet = new SteelBrickCPQPricebook__c(Case_Safe_ID__c = 'MKTO Case Safe Id', ID__c = mktoPB.Id);
        insert mktoPBCustSet;
    
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
        Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
        Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
        Trigger_Opportunity_Helper.isAfterUpdateEvent = true;
        // Insert New Business Opportunities - Set Steelbrick PB
        
        List<Opportunity> OpptyToBeInsertedList = new List<Opportunity>();
        OpptyToBeInsertedList = TestCPQUtilityClass.createOpportunities(accountsToBeInsertedList,2);
        OpptyToBeInsertedList[0].type='Renewal';
        OpptyToBeInsertedList[0].Pricebook2Id = mktoPB.Id;
        OpptyToBeInsertedList[1].Pricebook2Id = mktoPB.Id;
        OpptyToBeInsertedList[0].MainCompetitor__c  = 'Act-On';
        OpptyToBeInsertedList[1].type='Renewal';
        insert OpptyToBeInsertedList;
        
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        
        // Insert SB Quotes
        List<SBQQ__Quote__c> quotesToBeInsertedList = new List<SBQQ__Quote__c>();
        quotesToBeInsertedList = TestCPQUtilityClass.createQuotes(OpptyToBeInsertedList,1);
        quotesToBeInsertedList[0].Marketing_Permission__c = 'Marketing_Permission__c';
        quotesToBeInsertedList[0].Case_Study_Permission__c = 'Case_Study_Permission__c';
        quotesToBeInsertedList[0].Custom_Agreement_Name_and_Date__c = 'Custom_Agreement_Name_and_Date__c';
        quotesToBeInsertedList[0].SBQQ__PaymentTerms__c = 'SBQQ__PaymentTerms__c';
        quotesToBeInsertedList[0].Payment_Frequency__c = 'Payment_Frequency__c';
        quotesToBeInsertedList[0].Hide_Discount__c = true;
        quotesToBeInsertedList[0].Enterprise_Roll_up_SKU__c = true;
        quotesToBeInsertedList[0].Renewal_Uplift_pct__c = '7%';
        quotesToBeInsertedList[0].Renewal_Uplift_Text__c = 'Renewal_Uplift_Text__c';
        quotesToBeInsertedList[0].PO_Number__c = '12345';
        quotesToBeInsertedList[0].PO_Required__c = true;
        quotesToBeInsertedList[0].SBQQ__Primary__c = true;
        quotesToBeInsertedList[1].SBQQ__Primary__c = true;
        quotesToBeInsertedList[0].Mdq_quote__c = true;
        quotesToBeInsertedList[1].Mdq_quote__c = true;
        quotesToBeInsertedList[1].Rubiks_Quote__c = true;
        quotesToBeInsertedList[0].Rubiks_Quote__c = true;
        insert quotesToBeInsertedList;

        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;       
       
        //Insert Quote Lines
        List<SBQQ__QuoteLine__c> listQuoteLinesToBeInserted = new List<SBQQ__QuoteLine__c>();
        listQuoteLinesToBeInserted = TestCPQUtilityClass.createQuoteLines(quotesToBeInsertedList,5,productToInsertList);
        listQuoteLinesToBeInserted[0].SBQQ__RequiredBy__c = null;
        listQuoteLinesToBeInserted[0].Product_Family__c = 'Bundle';
        listQuoteLinesToBeInserted[1].Product_Family__c = 'Bundle';
        listQuoteLinesToBeInserted[0].Product_Type__c ='Subscription';
        listQuoteLinesToBeInserted[1].Product_Type__c ='Subscription';
        listQuoteLinesToBeInserted[0].SBQQ__Bundled__c = true;
        listQuoteLinesToBeInserted[1].SBQQ__Bundled__c = true;
          id MDQQuoteId;
          for(SBQQ__QuoteLine__c QLI: listQuoteLinesToBeInserted){
              if(quotesToBeInsertedList[1].id==QLI.SBQQ__Quote__c){
                listQuoteLinesToBeInserted[0].SBQQ__SegmentLabel__c ='1';
                listQuoteLinesToBeInserted[1].SBQQ__SegmentLabel__c ='1';
                listQuoteLinesToBeInserted[2].SBQQ__SegmentLabel__c ='2';
                listQuoteLinesToBeInserted[3].SBQQ__SegmentLabel__c ='2';
                  MDQQuoteId=QLI.SBQQ__Quote__c;
              }
          }
        test.startTest(); 
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA  = true;
        insert listQuoteLinesToBeInserted;  
        Test.StopTest();
        id reqbyId;
        List<SBQQ__QuoteLine__c> UpdateQuoteLines = new List<SBQQ__QuoteLine__c>();
        integer setReqId=0;
          for(SBQQ__QuoteLine__c QLI:[SELECT id ,SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c=:MDQQuoteId]){
              if(setReqId==0){
                  reqbyId = QLI.id;
              }
            
              if(setReqId!=0){
                   QLI.SBQQ__RequiredBy__c=reqbyId;
                   UpdateQuoteLines.add(QLI);
              }
               setReqId= setReqId+1;
          }  
        
        update UpdateQuoteLines;
        
        //Inserting OpportunityLines
        List<OpportunityLineItem> listOLIs = new  List<OpportunityLineItem>();
        listOLIs = TestCPQUtilityClass.createOppLineItems(OpptyToBeInsertedList,listPBE);
        For(integer i=0; i < listOLIs.size(); i++){
            listOLIs[i].SBQQ__QuoteLine__c = listQuoteLinesToBeInserted[i].id;
            listOLIs[i].Product_Type__c = 'Subscription';
        }
        listOLIs[3].Product_Type__c = 'Sevices';
        insert listOLIs;
        
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
  Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
  Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
  Trigger_Opportunity_Helper.isAfterUpdateEvent = true;
        // Update Opportunity as Closed Won  - Fetch Opp Record Type
        Schema.DescribeSObjectResult descOppSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> oppRecordTypeInfo = descOppSchema.getRecordTypeInfosByName(); 
        Id closedWonRecTypeId = oppRecordTypeInfo.get('Closed Won').getRecordTypeId();
        OpptyToBeInsertedList[0].Stage_Signed_Order_Date__c=system.Today();
        OpptyToBeInsertedList[0].RecordTypeId = closedWonRecTypeId;
        OpptyToBeInsertedList[0].Total_Assigned_Hours__c = 100;
        OpptyToBeInsertedList[0].StageName = 'Closed Won';
        OpptyToBeInsertedList[1].Stage_Signed_Order_Date__c=system.Today();
        OpptyToBeInsertedList[1].RecordTypeId = closedWonRecTypeId;
        OpptyToBeInsertedList[1].Total_Assigned_Hours__c = 100;
        OpptyToBeInsertedList[1].StageName = 'Closed Won'; 
      
        OpptyToBeInsertedList[1].Prior_Opportunity__c =OpptyToBeInsertedList[0].id;
        OpptyToBeInsertedList[0].SBQQ__PrimaryQuote__c=quotesToBeInsertedList[0].id;
        //Test.StartTest();
        update OpptyToBeInsertedList;
       
  
    }//End of testMDQCase()

     public static testmethod void Test2ndSegmentAddingDropping(){
        
         
     MapOpportunityFieldsToProvisioningCase__c custmset=new MapOpportunityFieldsToProvisioningCase__c();
     custmset.name='AccountId';
     custmset.OpportunityFieldName__c='AccountId';
     custmset.isfield__c=true;
     
     MapOpportunityFieldsToProvisioningCase__c custmset1=new MapOpportunityFieldsToProvisioningCase__c();
     custmset1.name='BusinessHoursId';
     custmset1.OpportunityFieldName__c='01m500000004FoA';
     custmset1.isfield__c=false;

     MapOpportunityFieldsToProvisioningCase__c custmset2=new MapOpportunityFieldsToProvisioningCase__c();
     custmset2.name='RecordTypeId';
     custmset2.OpportunityFieldName__c='0126C000000GtdU';
     custmset2.isfield__c=false;
     
     MapOpportunityFieldsToProvisioningCase__c custmset3=new MapOpportunityFieldsToProvisioningCase__c();
     custmset3.name='Opportunity_Type__c';
     custmset3.OpportunityFieldName__c='Type';
     custmset3.isfield__c=true;
     
     MapOpportunityFieldsToProvisioningCase__c custmset4=new MapOpportunityFieldsToProvisioningCase__c();
     custmset4.name='Asset_Name__c';
     custmset4.OpportunityFieldName__c='SBQQ__PrimaryQuote__r.Asset_Name__c';
     custmset4.isfield__c=true;
     
     list<MapOpportunityFieldsToProvisioningCase__c> listmap=new list<MapOpportunityFieldsToProvisioningCase__c>{custmset,custmset1,custmset2,custmset3,custmset4};
     insert listmap;
         
         // Create accounts to insert
        Set<Id> accountsToInsertSet = new Set<Id>();
        map<id, id> AccToCont = new Map<id,id>();
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA  = true;
        List<Account> accountsToInsertList = new List<Account>();

        for(Account accnt: TestCPQUtilityClass.createAccounts(1)){
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            //accnt.RecordTypeId = '01250000000ULb7AAG';
            accountsToInsertList.add(accnt);
        }
            insert accountsToInsertList;
            for(Account acc : accountsToInsertList){
                accountsToInsertSet.add(acc.Id);
            }
           
        list<Contact> ContactToInsert = new list<Contact>();
        ContactToInsert = TestCPQUtilityClass.createContacts(accountsToInsertList,1);
        //Contact con = new Contact(firstname='First Name', lastname='Last Name', AccountId=accountsToInsertList[0].id);
        insert ContactToInsert;
        for(Contact c: ContactToInsert)
        {
            if(c.id != Null && c.AccountId !=Null){
                AccToCont.put(c.AccountId , c.id);
            }
        }
        
        //Primary_Marketo_User_Lookup__c
        // add products with product code
        List<Product2> productToInsertList = new List<Product2>();
        productToInsertList =TestCPQUtilityClass.createCustomProducts(5);
        productToInsertList[0].MA_or_RTP__c = 'MA';   
        productToInsertList[0].Visible_To_Customer__c = true;
        productToInsertList[0].Family='Support';
        productToInsertList[1].Visible_To_Customer__c = true;
        productToInsertList[1].MA_or_RTP__c ='RTP';
        productToInsertList[1].ProductCode = 'SANDBOX_PRODUCT_CODE' ;
        productToInsertList[1].Family= 'Bundle ';
        productToInsertList[0].Family= 'Bundle ';
        productToInsertList[0].Product_Type__c= 'Subscription ';
        productToInsertList[1].Product_Type__c = 'Subscription';
        productToInsertList[2].Product_Type__c = 'Subscription';
        productToInsertList[3].Product_Type__c = 'Subscription';
        productToInsertList[4].Product_Type__c = System.Label.PRODUCT_TYPE_SERVICES;
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        productToInsertList[3].ProductCode ='SUPTPCBNDL';
        productToInsertList[4].ProductCode ='SUPTPC41BNDL'; 
        productToInsertList[2].Asset_Type__c = 'Support Product';
        insert productToInsertList;
        system.debug('---productToInsertList[0]---'+productToInsertList[0]);

        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        priceBookList[0].Name = 'Enterprise Price Book v2018';
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }
         system.debug('priceBookList'+priceBookList);
        
        // Insert data for custom setting - SteelBrickCPQPricebook__c
        SteelBrickCPQPricebook__c obj = new SteelBrickCPQPricebook__c();
        obj.Name = 'SteelBrick PB';
        obj.ID__c = priceBookList[0].Id;
       // obj.Phoenix_Price_Books__c = priceBookList[0].Id;
        insert obj;
        
        // Get Id of Standard Pricebook
        Id stdPbId = Test.getStandardPricebookId();
        
        // Insert Products into Standard Pricebook
        List<PriceBookEntry> pbEntryStdPbList = new List<PriceBookEntry>();
        for(Integer i=0; i<productToInsertList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = productToInsertList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }
        
        // Insert Products into Custom Pricebooks
        List<PriceBookEntry> pbEntryList = new List<PriceBookEntry>();
        pbEntryList = TestCPQUtilityClass.createPriceBookEntries(productToInsertList, priceBookList);
        if(!pbEntryList.isEmpty()){
            insert pbEntryList;
        }
        
         list<RubiksSandboxCodes__c> RbkSandList = new list<RubiksSandboxCodes__c>();
         
        RubiksSandboxCodes__c RSandProduct = new RubiksSandboxCodes__c(name='test RUBSand',Product_Code__c='test RUBSand');
        RubiksSandboxCodes__c RSandProduct1 = new RubiksSandboxCodes__c(name='test RUBSand1',Product_Code__c='test RUBSand1');
        RbkSandList.add(RSandProduct);
        RbkSandList.add(RSandProduct1);
         
        insert  RbkSandList;
         
         list<RubiksProdCode__c> RbkProList = new list<RubiksProdCode__c>();
         
        RubiksProdCode__c RbkProduct = new RubiksProdCode__c(name='test RUB P',Product_Code__c='test RUB P');
        RubiksProdCode__c RbkProduct1 = new RubiksProdCode__c(name='test RUB P1',Product_Code__c='test RUB P1');
        RbkProList.add(RbkProduct);
        RbkProList.add(RbkProduct1);
         
        insert  RbkProList;
         
         List<Product_SKU_Engineering_Code__c> custSetRecordsList = new List<Product_SKU_Engineering_Code__c>();
        
        // Create custSetRecords
        Product_SKU_Engineering_Code__c  custSetRec1 = new Product_SKU_Engineering_Code__c();
        custSetRec1.Name = 'custSetRec1';
        custSetRec1.Engineering_Code__c = 'accountBasedMarketing';
        custSetRec1.Product_Code__c = productToInsertList[0].ProductCode ;
        custSetRec1.Quantity_Multiple__c =1;
        custSetRecordsList.add(custSetRec1);
        
        Product_SKU_Engineering_Code__c  custSetRec2 = new Product_SKU_Engineering_Code__c();
        custSetRec2.Name = 'custSetRec2';
        custSetRec2.Engineering_Code__c = 'emailPlugin';
        custSetRec2.Product_Code__c = productToInsertList[1].ProductCode ;
         custSetRec2.Quantity_Multiple__c =2;
        custSetRecordsList.add(custSetRec2);
        
        // Create custSetRecords
        Product_SKU_Engineering_Code__c  custSetRec3 = new Product_SKU_Engineering_Code__c();
        custSetRec3.Name = 'custSetRec3';
        custSetRec3.Engineering_Code__c = 'testaccountBasedMarketing';
        custSetRec3 .Product_Code__c = productToInsertList[2].ProductCode ;
        custSetRec3.Quantity_Multiple__c =3;
        custSetRecordsList.add(custSetRec3);
        
        Product_SKU_Engineering_Code__c  custSetRec4 = new Product_SKU_Engineering_Code__c();
        custSetRec4.Name = 'custSetRec4';
        custSetRec4.Engineering_Code__c = 'testemailPlugin';
        custSetRec4.Product_Code__c = productToInsertList[3].ProductCode ;
        custSetRec4.Quantity_Multiple__c =4;
        custSetRecordsList.add(custSetRec4);
        
         Product_SKU_Engineering_Code__c  custSetRec5 = new Product_SKU_Engineering_Code__c();
        custSetRec5.Name = 'custSetRec5';
        custSetRec5.Engineering_Code__c = 'test2emailPlugin';
        custSetRec5.Product_Code__c = productToInsertList[4].ProductCode ;
        custSetRec5.Quantity_Multiple__c =5;
        custSetRecordsList.add(custSetRec5);
     
        
        insert custSetRecordsList ;
        
        set<string> engCode = new set<string>();
        
        engcode.add(custSetRec1.Product_Code__c);
        engcode.add(custSetRec2.Product_Code__c);
        engcode.add(custSetRec3.Product_Code__c);
        engcode.add(custSetRec4.Product_Code__c);
        engcode.add(custSetRec5.Product_Code__c);           
        // Create custom pricebooks
     /*   List<PriceBook2> pricebookList = new List<PriceBook2>();
        pricebookList =TestCPQUtilityClass.createCustomPriceBooks(1);
        insert pricebookList;
        
        // insert products into custom pricebooks
        List<PriceBookEntry> priceBookEntriesList = new List<PriceBookEntry>();
        priceBookEntriesList =TestCPQUtilityClass.createPriceBookEntries(productToInsertList,pricebookList);
        insert priceBookEntriesList;*/
        
        // Insert data for custom setting - Contract_Roll_Up_With_Product_Code__c       
        List<Contract_Roll_Up_With_Product_Code__c> productCodeList = new List<Contract_Roll_Up_With_Product_Code__c>();
        Contract_Roll_Up_With_Product_Code__c crp1 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test Product 1 ', FieldName__c='Contract_Base_ACV_for_Support__c',   Multiplier__c=3, Need_To_Check_Criteria__c = true, Product_Code__c = 'TESTPRODCODE0', Subscription_Field__c = 'Total_Support_Contacts__c', User_Code__c= 'SUP-BASE-BUS, SUP-BASE-ELT, SUP-BASE-STD-ENT, SUP-BASE-PRM, SUP-BASE-STD-SMB, SUP-BASE-SPK',Include_in_Maintenance__c = true);           
        Contract_Roll_Up_With_Product_Code__c crp2 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test', FieldName__c='Contract_Base_ACV_for_Support__c',  Multiplier__c=3, Need_To_Check_Criteria__c = true, Product_Code__c = 'TESTPRODCODE2,TESTPRODCODE3', Subscription_Field__c = 'Subscription_ACV__c', User_Code__c = null, Include_in_Maintenance__c = true,SUP_Product_code__c = 'tes');          
        Contract_Roll_Up_With_Product_Code__c crp3 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test 2', FieldName__c='Contract_Base_ACV_for_Support__c',    Multiplier__c=3, Need_To_Check_Criteria__c = false, Product_Code__c = 'TPC4', Subscription_Field__c = 'Subscription_ACV__c');           
        Contract_Roll_Up_With_Product_Code__c crp4 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test 3', FieldName__c='Total_Support_Contacts__c',    Multiplier__c=3, Need_To_Check_Criteria__c = true, Product_Code__c = 'SUPTPC', Subscription_Field__c ='Subscription_MCV__c',SUP_Product_code__c='SU'   ,User_Code__c=null,Include_in_Maintenance__c=False);            
        Contract_Roll_Up_With_Product_Code__c crp5 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test 4', FieldName__c='Total_Support_Contacts__c',    Multiplier__c=3, Need_To_Check_Criteria__c = false, Product_Code__c = 'SUPTPC41', Subscription_Field__c ='Subscription_MCV__c',SUP_Product_code__c='SU'    ,User_Code__c=null,Include_in_Maintenance__c=False);            
        Contract_Roll_Up_With_Product_Code__c crp6 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test 6', FieldName__c='Total_Support_Contacts__c',    Multiplier__c=3, Need_To_Check_Criteria__c = false, Product_Code__c =  productToInsertList[2].ProductCode, Subscription_Field__c ='Subscription_MCV__c',SUP_Product_code__c='SU'   ,User_Code__c=null,Include_in_Maintenance__c=False);   
        Contract_Roll_Up_With_Product_Code__c crp7 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test 7', FieldName__c='Total_Support_Contacts__c',    Multiplier__c=3, Need_To_Check_Criteria__c = false, Product_Code__c =  productToInsertList[3].ProductCode, Subscription_Field__c ='Subscription_MCV__c',SUP_Product_code__c='SU'   ,User_Code__c=null,Include_in_Maintenance__c=False);   

        productCodeList.add(crp1);
        productCodeList.add(crp2);
        productCodeList.add(crp3);
        productCodeList.add(crp4);
        productCodeList.add(crp5);
        productCodeList.add(crp6);
        productCodeList.add(crp7);
     
        insert productCodeList;        
        
        // Insert data for custom setting - Entitlement_Product_Code_Criteria__c
        List<Entitlement_Product_Code_Criteria__c> entProdCodeList = new List<Entitlement_Product_Code_Criteria__c>();
        Entitlement_Product_Code_Criteria__c entProdCode = new Entitlement_Product_Code_Criteria__c(Name ='Test Name',Product_Code__c = 'TESTPROD2', Type__c = 'Test');
        entProdCodeList.add(entProdCode);
        insert entProdCodeList;
        
        Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
  Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
  Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
  Trigger_Opportunity_Helper.isAfterUpdateEvent = true;
        // insert opportunities - for Closed Won Oppty - Contract will be created automatically
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities(accountsToInsertList,1);
        for(Opportunity opp : opptyList){
            opp.Rep_Create_ARR__c = 10000;
            opp.Amount = 2000;
            opp.Pricebook2Id = pricebookList[0].Id;
            opp.Deal_Type__c='University';
            opp.Name = 'University Test Class Validation';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.OwnerId=UserInfo.getUserId();
            if(AccToCont.containsKey(opp.AccountId)){
                opp.Primary_Marketo_User_Lookup__c = AccToCont.get(opp.AccountId) ;
                opp.Primary_Marketo_User_Email__c = 'test.abc@jade.com' ;
            }
        }
        
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        
        opptyList[0].Probability = 1;
        opptyList[0].Split_Opportunities__c = null;
        opptyList[0].Ghost__c = False ;
        opptyList[0].pse__Primary_Project__c = null;
        opptyList[0].stagename =Label.OPPORTUNITY_STAGE_CLOSED_WON; 
        //Test.startTest(); 
        if(!opptyList.isEmpty()){
            insert opptyList;
        }
        
        
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        System.debug('opptyList[0].Accountid...'+opptyList[0].Accountid);
        List<SBQQ__Quote__c> newquotList=  TestCPQUtilityClass.createSimpleQuote(opptyList,1);
        for(SBQQ__Quote__c SBQuote :newquotList){
            SBQuote.Rubiks_Quote__c = true;
             SBQuote.SBQQ__Primary__c = true;
            SBQuote.Mdq_quote__c =true;
        }
       system.debug('newquotList================='+newquotList);
       SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        insert newquotList;
        Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
  Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
  Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
  Trigger_Opportunity_Helper.isAfterUpdateEvent = true;
        opptyList[0].SBQQ__PrimaryQuote__c= newquotList[0].id;
        update opptyList;
     
         List<SBQQ__QuoteLine__c>  quoteLineList = TestCPQUtilityClass.createQuoteLines(newquotList,5,productToInsertList);
         
         for(  SBQQ__QuoteLine__c QLI:quoteLineList){
             
             QLI.Product_Type__c ='Subscription';
             QLI.SBQQ__StartDate__c=System.Today().addDays(120);
             QLI.SBQQ__EndDate__c=System.Today().addDays(360);
             QLI.SBQQ__SegmentIndex__c=2;
         }
          quoteLineList[0].SBQQ__StartDate__c=System.Today();
         quoteLineList[3].Product_Type__c=System.Label.PRODUCT_TYPE_SERVICES;
           quoteLineList[1].SBQQ__StartDate__c=System.Today().addDays(120);
          quoteLineList[1].SBQQ__SegmentIndex__c=1;
         insert quoteLineList;
          
          Marketo_Trigger_Management__c MKTOTriggerManagement = new Marketo_Trigger_Management__c();
          MKTOTriggerManagement.Deactivate_Contract_Triggers__c = true;
          insert MKTOTriggerManagement;

         // create contracts 
         List<Contract> contractList = new List<Contract>();
         Contract contract1 = new Contract(Name='Test Contract ', AccountId=opptyList[0].AccountId,SBQQ__Opportunity__c = opptyList[0].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true, SBQQ__Quote__c = newquotList[0].Id,ContractTerm = 12);         
         contractList.add(contract1);
         SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
         insert contractList;
        
        
         
        list<SBQQ__QuoteLine__c> QLIList =    [SELECT id,SBQQ__Product__c,SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c];
        integer oliFlag=0;
          Test.startTest(); 
          SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
         for(SBQQ__QuoteLine__c QLI:QLIList){
             if(oliFlag!=0){
                QLI.SBQQ__RequiredBy__c=QLIList[0].id;
                  QLI.SBQQ__Quantity__c=2;
             }
             oliFlag = oliFlag+1;
         }
          update QLIList;
           List<OpportunityLineItem> listOLIs = new  List<OpportunityLineItem>();
        listOLIs = TestCPQUtilityClass.createOppLineItems(opptyList,pbEntryList);
       // system.assertEquals(OpptyToBeInsertedList[0].Pricebook2Id,OpptyToBeInsertedList[1].Pricebook2Id);
        For(integer i=0; i < listOLIs.size(); i++){
            listOLIs[i].SBQQ__QuoteLine__c = QLIList[i].id;
            listOLIs[i].Product_Type__c = 'Subscription';
        
        } 
        listOLIs[3].Product_Type__c = 'Services';
        insert listOLIs;
         
         SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        
         Utility.isAssetTriggerExecutedFromOppty  = true;
         
        List<Asset> assetList = new List<Asset>();
        Asset as1 = new Asset();
        as1.Name = 'Test Asset 1';
        as1.installdate = System.today();
        as1.UsageEndDate = System.today().addMonths(2);
        as1.Opportunity__c = opptyList[0].Id;
        //as1.Asset_Type__c='Instance';
        as1.purpose__c='Production';
        as1.Product2Id= productToInsertList[0].Id;
        as1.AccountId = accountsToInsertList[0].Id;
        as1.ContactId = ContactToInsert[0].id;
        as1.status = 'Active';
        as1.Acct_Prefix__c = QLIList[1].id;
        as1.Munchkin_ID__c= QLIList[1].id;
        as1.SBQQ__QuoteLine__c =QLIList[1].id;

       
        
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = opptyList[0].Id;
        as1.Product2Id = productToInsertList[2].Id;
        as2.AccountId = accountsToInsertList[0].Id;
        //as2.ContactId = ContactToInsert[0].id;
        as2.status = 'Active';
        as2.SBQQ__QuoteLine__c =QLIList[0].id;
        as2.Acct_Prefix__c = QLIList[0].id;
        as2.Munchkin_ID__c= QLIList[0].id;
        as2.Contract__c = contractList[0].Id;
        assetList.add(as1);
        assetList.add(as2);
       
        if(!assetList.isEmpty()){
            //insert assetList;
        } 
      
    // Test.startTest(); 
         
        
     
        
        // create subscriptions
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sub1   = new SBQQ__Subscription__c(SBQQ__Account__c=accountsToInsertList[0].Id,SBQQ__Quantity__c=3,SBQQ__SegmentStartDate__c=system.today(),SBQQ__SegmentQuantity__c=1,SBQQ__SegmentIndex__c=1, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[0].Id,SBQQ__QuoteLine__c=quoteLineList[0].id);
        SBQQ__Subscription__c subSeg2 = new SBQQ__Subscription__c(SBQQ__Account__c=accountsToInsertList[0].Id,SBQQ__Quantity__c=3,SBQQ__SegmentStartDate__c=system.today().addDays(120),SBQQ__SegmentQuantity__c=3,SBQQ__SegmentIndex__c=2, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[0].Id,SBQQ__QuoteLine__c=quoteLineList[0].id);

        SBQQ__Subscription__c subDrop = new SBQQ__Subscription__c(SBQQ__Account__c=accountsToInsertList[0].Id,SBQQ__Quantity__c=3,SBQQ__SegmentStartDate__c=system.today(),SBQQ__SegmentQuantity__c=1,SBQQ__SegmentIndex__c=1, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[1].Id,SBQQ__QuoteLine__c=quoteLineList[1].id);

        SBQQ__Subscription__c sub11 = new SBQQ__Subscription__c(SBQQ__Account__c=accountsToInsertList[0].Id,SBQQ__Quantity__c=4 ,SBQQ__SegmentStartDate__c=system.today().addDays(120),SBQQ__SegmentQuantity__c=3,SBQQ__SegmentIndex__c=2,SBQQ__TerminatedDate__c=System.today().addMonths(7),SBQQ__ProrateMultiplier__c = 1, SBQQ__Product__c =productToInsertList[3].Id);

        SBQQ__Subscription__c sub6 = new SBQQ__Subscription__c(SBQQ__Account__c=accountsToInsertList[0].Id,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =QLIList[0].SBQQ__Product__c,SBQQ__QuoteLine__c=QLIList[0].id);
        SBQQ__Subscription__c sub7 = new SBQQ__Subscription__c(SBQQ__Account__c=accountsToInsertList[0].Id,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =QLIList[1].SBQQ__Product__c,SBQQ__QuoteLine__c=QLIList[1].id);
        subList.add(sub1);
        subList.add(subSeg2);
        subList.add(subDrop);
        
        
         subList.add(sub6);
         subList.add(sub7); 
         subList.add(sub11);
       
       insert subList;
       date segDate =system.today().addDays(120);
       Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
  Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
  Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
  Trigger_Opportunity_Helper.isAfterUpdateEvent = true;
      list<Opportunity> oppAddDrop=[SELEct id,SBQQ__PrimaryQuote__r.Mdq_quote__c,(SELECT Id,Product_Type__c,Product2.Name,SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c,SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.Production_Asset__c,Opportunity.Sub_End_Date__c, Opportunity.Sub_Start_Date__c, Name, ProductCode, Quantity, OpportunityId, Opportunity.Maximum_Database_Size__c,Product_Name__c,SBQQ__QuoteLine__r.SBQQ__Quantity__c,opportunity.Pricebook2Id,PricebookEntry.Product2.Name,QuoteLine_Quantity__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.id,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__ProductCode__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.Name,SBQQ__QuoteLine__r.Bundle_Package__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.MKTO_Product_Name__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.SBQQ__StartDate__c,SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c,SBQQ__QuoteLine__r.SBQQ__EndDate__c FROM OpportunityLineItems WHERE SBQQ__QuoteLine__c!=null AND SBQQ__QuoteLine__r.SBQQ__Quantity__c!=null AND SBQQ__QuoteLine__r.SBQQ__StartDate__c=:segDate) FROM Opportunity where Id=: opptyList[0].id AND StageName =:Label.OPPORTUNITY_STAGE_CLOSED_WON AND AccountId!=null  AND SBQQ__PrimaryQuote__c!=null AND SBQQ__PrimaryQuote__r.Rubiks_Quote__c=TRUE];
      list<OpportunityLineItem> UpdateOLIs = new list<OpportunityLineItem>();
         for(OpportunityLineItem oli:oppAddDrop[0].OpportunityLineItems){
             OLI.Product_Type__c = System.Label.PRODUCT_TYPE_SUBSCRIPTIONS;
             UpdateOLIs.add(OLI);
         }
         UpdateOLIs[1].Product_Type__c=System.Label.PRODUCT_TYPE_SERVICES;
         update UpdateOLIs;
         list<Opportunity> oppAddDrop1=[SELEct id,AccountId,Account.Name,type,SBQQ__PrimaryQuote__r.Mdq_quote__c,SBQQ__PrimaryQuote__r.Instance_Rollup__c,SBQQ__PrimaryQuote__r.Asset_Name__c,(SELECT Id,MKTO_Product_Name__c,Product2.Name,Product_Type__c,SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__c,SBQQ__QuoteLine__r.SBQQ__RenewedSubscription__r.Production_Asset__c,Opportunity.Sub_End_Date__c, Opportunity.Sub_Start_Date__c, Name, ProductCode, Quantity, OpportunityId, Opportunity.Maximum_Database_Size__c,Product_Name__c,SBQQ__QuoteLine__r.SBQQ__Quantity__c,opportunity.Pricebook2Id,PricebookEntry.Product2.Name,QuoteLine_Quantity__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.id,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__ProductCode__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__Product__r.Name,SBQQ__QuoteLine__r.Bundle_Package__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.MKTO_Product_Name__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Instance_Rollup__c,SBQQ__QuoteLine__r.SBQQ__RequiredBy__r.SBQQ__RenewedSubscription__r.SBQQ__QuoteLine__c,SBQQ__QuoteLine__r.SBQQ__StartDate__c,SBQQ__QuoteLine__r.SBQQ__SegmentIndex__c,SBQQ__QuoteLine__r.SBQQ__EndDate__c FROM OpportunityLineItems WHERE SBQQ__QuoteLine__c!=null AND SBQQ__QuoteLine__r.SBQQ__Quantity__c!=null AND SBQQ__QuoteLine__r.SBQQ__StartDate__c=:segDate ORDER BY SBQQ__QuoteLine__r.SBQQ__RequiredBy__c  DESC NULLS LAST) FROM Opportunity where Id=: opptyList[0].id AND StageName =:Label.OPPORTUNITY_STAGE_CLOSED_WON AND AccountId!=null  AND SBQQ__PrimaryQuote__c!=null AND SBQQ__PrimaryQuote__r.Rubiks_Quote__c=TRUE];
          AddingDroppingProdController.AddedProducts.add('ENG:'+2); 
          AddingDroppingProdController.AddedProducts.add('ENG1:'+3);
          AddingDroppingProdController.DroppedProducts.add('ENG12:'+4);
          AddingDroppingProdController.DroppedProducts.add('ENG122:'+6);
          AddingDroppingProdController.QuantityChangedProducts.add('ENG11:'+4);
          AddingDroppingProdController.DroppedProducts.add('ENG33:'+6);
         //  system.assertEquals(4, oppAddDrop[0].Opportunit)
         createProvisioningCaseFromOpportunity.create2ndSegmentProvisioningCase(oppAddDrop1[0]);  
        Test.stopTest();
		createProvisioningCaseFromOpportunity.testAddingDroppingProducts();
        
    }//End of Test Method Test2ndSegment 
    //***********/
    public  Map<string,list<string>> ReturnProductMap(){
        Map<string,list<string>> AddedDroppedMap = new Map<string,list<string>>();
        AddedDroppedMap.put('Added Products',new list<string>{'Product1=10','product2=12'});
        AddedDroppedMap.put('Dropped Products',new list<string>{'Product1=10','product2=12'});
        AddedDroppedMap.put('QuantityChangedProduct',new list<string>{'Product1=10','product2=12'});
        AddedDroppedMap.put('AddedDroppedQtyChange',new list<string>{'Product1=10','product2=12'});
        return AddedDroppedMap;
    }
    
   
    
     
        
}