@IsTest

public class QuoteSegmentStartDateBatchTest{

public static testMethod void testQuoteSegmentStartDateBatch(){
 
    List<Account> accountsToBeInsertedList = new List<Account>();
    accountsToBeInsertedList = TestCPQUtilityClass.createAccounts(1);
    
    insert accountsToBeInsertedList;
    
    List<Product2> productToInsertList = new List<Product2>();
    productToInsertList = TestCPQUtilityClass.createCustomProducts(3);
    productToInsertList[0].ProductCode='PROD-APPS-AUTOWKFL';
    productToInsertList[1].ProductCode = 'PROD-PLAT-SANDBOX';
    productToInsertList[2].ProductCode = 'PROD-PLAT-SANDBOX-INST';
    
    if(!productToInsertList.isEmpty()){
    
        productToInsertList[0].Family ='Product';
        productToInsertList[1].Family ='Product';
        productToInsertList[2].Family ='Lead Management';
        productToInsertList[0].name='Automation and Workflow';
        productToInsertList[1].name='Sandbox';
        productToInsertList[2].name='Sandbox Instance';
        insert productToInsertList;
    } 
    
    
    // Create Custom Pricebooks
    List<PriceBook2> priceBookList = new List<PriceBook2>();
    priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
    if(!priceBookList.isEmpty()){
        insert priceBookList;
    }
    
    // Insert data for custom setting - SteelBrickCPQPricebook__c
    SteelBrickCPQPricebook__c obj = new SteelBrickCPQPricebook__c();
    obj.Name = 'SteelBrick PB';
    obj.ID__c = priceBookList[0].Id;
    //insert obj;
    
    // Get Id of Standard Pricebook
    Id stdPbId = Test.getStandardPricebookId();
    
    
    // Insert Products into Standard Pricebook
    List<PriceBookEntry> pbEntryStdPbList = new List<PriceBookEntry>();
    for(Integer i=0; i<productToInsertList.size(); i++){
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = productToInsertList[i].Id,UnitPrice = 10000, IsActive = true);
        system.debug('stdPbId Inside PBE'+stdPbId);
        pbEntryStdPbList.add(pbe);
    }
    if(!pbEntryStdPbList.isEmpty()){
        insert pbEntryStdPbList;
    }
    
    
    List<PriceBookEntry> pbEntryCustPbList = new List<PriceBookEntry>();
    for(Integer i=0; i<productToInsertList.size(); i++){
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = priceBookList[0].id, Product2Id = productToInsertList[i].Id,UnitPrice = 10000, IsActive = true);
        pbEntryCustPbList.add(pbe);
    }
    if(!pbEntryCustPbList.isEmpty()){
        insert pbEntryCustPbList;
    }
    
    list<User> u=[select id, email from User where id='00550000003PDSe'];
    
    List<Opportunity> OpptyToBeInsertedList = new List<Opportunity>();
    OpptyToBeInsertedList = TestCPQUtilityClass.createOpportunities(accountsToBeInsertedList,1);
    OpptyToBeInsertedList[0].StageName            = '3 - Solution Definition';
    OpptyToBeInsertedList[0].PriceBook2Id         = priceBookList[0].id;
    OpptyToBeInsertedList[0].Quarterly_Renewal__c = string.valueof(2);
    OpptyToBeInsertedList[0].type                 = 'New Business';
    OpptyToBeInsertedList[0].Deal_Type__c         = 'Standard';
    OpptyToBeInsertedList[0].CAM_Owner_Email__c ='rajesh.wani@jadeglobal.com';
    OpptyToBeInsertedList[0].Actual_Close_Date__c=system.today();
    OpptyToBeInsertedList[0].owner=u[0];
    //OpptyToBeInsertedList[0].Create_Provisioning_Case__c = true;
    
    insert OpptyToBeInsertedList ;
    system.debug('OpptyToBeInsertedList '+OpptyToBeInsertedList ); 
    
    
    
    
    
    List<SBQQ__Quote__c> quotesToBeInsertedList= new List<SBQQ__Quote__c>();
    quotesToBeInsertedList = TestCPQUtilityClass.createQuotes(OpptyToBeInsertedList,1);
    
    for(SBQQ__Quote__c quote : quotesToBeInsertedList){
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__SubscriptionTerm__c=12;
        quote.Rubiks_Quote__c=true;
        quote.SBQQ__Opportunity2__c=OpptyToBeInsertedList[0].id;
        quote.SBQQ__StartDate__c=system.today();
        quote.SBQQ__PriceBook__c=priceBookList[0].id;
        quote.MDQ_Quote__c=true;
    
    }
    insert quotesToBeInsertedList;
    system.debug('quotesToBeInsertedList'+quotesToBeInsertedList);
    
    List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
    
    SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6),SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=6,SBQQ__SegmentKey__c='1475100700835');
    
    
    SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c( SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6).addDays(1),SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__EndDate__c,SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=6,SBQQ__SegmentKey__c='1475100700836'); 
    
    SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6),SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=6,SBQQ__SegmentKey__c='1475100700837');
    
    SBQQ__QuoteLine__c quoteLine3 = new SBQQ__QuoteLine__c( SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6).addDays(1),SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__EndDate__c,SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=6,SBQQ__SegmentKey__c='1475100700838');
    
    SBQQ__QuoteLine__c quoteLine4 = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=true,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[0].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6),SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=6,SBQQ__SegmentKey__c='1475100700839');
    
    SBQQ__QuoteLine__c quoteLine5 = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=true,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[0].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6).addDays(1),SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=6,SBQQ__SegmentKey__c='1475100700830');
    
    
    quoteLinesToInsert.add(quoteLine);
    quoteLinesToInsert.add(quoteLine1);
    quoteLinesToInsert.add(quoteLine2);
    quoteLinesToInsert.add(quoteLine3);
    quoteLinesToInsert.add(quoteLine4);
    quoteLinesToInsert.add(quoteLine5);
    //  Test.StartTest();
    insert quoteLinesToInsert;
    //  Test.StopTest();
    
    system.debug('quoteLinesToInsert#######'+quoteLinesToInsert);
    
    
    List<OpportunityLineItem> OLIListToBeInserted=new List<OpportunityLineItem>();       
    
    
    OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[1].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[0].Id,Segment_Start_Date__c=quoteLinesToInsert[0].SBQQ__StartDate__c,Users__c=1,Create_Asset__c=true,ServiceDate=quoteLinesToInsert[0].SBQQ__StartDate__c);           
    
    OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[1].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[1].Id,Segment_Start_Date__c=quoteLinesToInsert[1].SBQQ__StartDate__c,Users__c=1,Create_Asset__c=true,ServiceDate=quoteLinesToInsert[1].SBQQ__StartDate__c);
    
    OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[2].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[2].Id,Segment_Start_Date__c=quoteLinesToInsert[2].SBQQ__StartDate__c,Users__c=1,Create_Asset__c=true,ServiceDate=quoteLinesToInsert[2].SBQQ__StartDate__c);
    
    OpportunityLineItem oli4 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[2].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[3].Id,Segment_Start_Date__c=quoteLinesToInsert[3].SBQQ__StartDate__c,Users__c=1,Create_Asset__c=true,ServiceDate=quoteLinesToInsert[3].SBQQ__StartDate__c);
    
    OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[0].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[4].Id,Segment_Start_Date__c=quoteLinesToInsert[4].SBQQ__StartDate__c,Users__c=1,ServiceDate=quoteLinesToInsert[4].SBQQ__StartDate__c);
    
    OpportunityLineItem oli5 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[0].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[5].Id,Segment_Start_Date__c=quoteLinesToInsert[5].SBQQ__StartDate__c,Users__c=1,ServiceDate=quoteLinesToInsert[5].SBQQ__StartDate__c);
    
    
    OLIListToBeInserted.add(oli1);
    OLIListToBeInserted.add(oli2);
    OLIListToBeInserted.add(oli3);
    OLIListToBeInserted.add(oli4);
    OLIListToBeInserted.add(oli);
    OLIListToBeInserted.add(oli5);
    if(!OLIListToBeInserted.isEmpty()){
    insert OLIListToBeInserted;
    }
    update OLIListToBeInserted;
    
	OpptyToBeInsertedList[0].Migration__c = true;
    OpptyToBeInsertedList[0].StageName            = 'Signed Order';
    OpptyToBeInsertedList[0].Subscription_Language__c = 'English';
    OpptyToBeInsertedList[0].Subscription_Locale__c = 'English-United States';
    OpptyToBeInsertedList[0].Subscription_Time_Zone__c = 'Afghanistan Time (Asia/Kabul)';
    OpptyToBeInsertedList[0].Use_Case__c = 'B2B';
    OpptyToBeInsertedList[0].Needs_Pains__c = 'test';
    OpptyToBeInsertedList[0].MainCompetitor__c = 'Act-On';
    update OpptyToBeInsertedList;    
    
	OpptyToBeInsertedList[0].Migration__c = false;
    OpptyToBeInsertedList[0].StageName            = 'Closed Won';
    OpptyToBeInsertedList[0].Stage_Signed_Order_Date__c=system.Today();
    //OpptyToBeInsertedList[0].SBQQ__Contracted__c=true;
    OpptyToBeInsertedList[0].SBQQ__PrimaryQuote__c=quotesToBeInsertedList[0].id;
    OpptyToBeInsertedList[0].Actual_Close_Date__c=system.today();
    
    update OpptyToBeInsertedList;
    set<Id>OpIdSet =new set<Id>();
    //  system.assertEquals(system.today(),OpptyToBeInsertedList[0].Actual_Close_Date__c);
    //system.assertEquals(True,OpptyToBeInsertedList[0].isWon);
    
    for(Opportunity op:OpptyToBeInsertedList){
        OpIdSet.add(op.Id);
    }
    
    
    list<Opportunity> OppList=[select id,isWon,Actual_Close_Date__c,CAM_Owner_Email__c from Opportunity where Id IN:OpIdSet];
    
    
    
    system.assertEquals(True,OppList[0].isWon);
    system.debug('OpptyToBeInsertedList Updated Opp'+OpptyToBeInsertedList);
    
    
    
    String query='SELECT id,iswon,stagename,Actual_Close_Date__c,SBQQ__PrimaryQuote__c,SBQQ__PrimaryQuote__r.MDQ_Quote__c FROM Opportunity WHERE iswon != null AND Actual_Close_Date__c=:system.today()';
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
    Test.startTest();
    QuoteSegmentStartDateBatch c = new QuoteSegmentStartDateBatch();
    
    Database.executeBatch(c);
    
    Test.stopTest();
    set<Id>OLId=new set<ID>();
    for(OpportunityLineItem o:OLIListToBeInserted){
        OLId.add(o.Id);
    }
    
    //system.assertEquals(OLId.size() ,2); 
    List<OpportunityLineItem> OLIListNew=[select Id,Segment_Start_Date__c,CAM_Owner_Email__c,Opportunity_OwnerEmail__c,Product_Start_Date__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__StartDate__c,SBQQ__QuoteLine__r.SBQQ__SegmentLabel__c from OpportunityLineItem where Opportunity_OwnerEmail__c!=null limit 1];
    //system.assertEquals(OLIListNew.size() ,1);   
    //system.debug('OLIListNew******'+OLIListNew);
    //system.assertEquals(OLIListNew[0].Segment_Start_Date__c,OLIListNew[0].Product_Start_Date__c);
    // system.assertEquals(OLIListNew[1].CAM_Owner_Email__c,OLIListNew[1].Product_Start_Date__c);
    
    //system.assertEquals(OLIListNew[0].Opportunity_OwnerEmail__c,OpptyToBeInsertedList[0].owner.email);

}//End of Test method testQuoteSegmentStartDateBatch

public static testMethod void testQuote2SegmentStartDateBatch(){
 
    List<Account> accountsToBeInsertedList = new List<Account>();
    accountsToBeInsertedList = TestCPQUtilityClass.createAccounts(1);
    
    insert accountsToBeInsertedList;
    
    List<Product2> productToInsertList = new List<Product2>();
    productToInsertList = TestCPQUtilityClass.createCustomProducts(3);
    productToInsertList[0].ProductCode='PROD-APPS-AUTOWKFL';
    productToInsertList[1].ProductCode = 'PROD-PLAT-SANDBOX';
    productToInsertList[2].ProductCode = 'PROD-PLAT-SANDBOX-INST';
    
    if(!productToInsertList.isEmpty()){
    
        productToInsertList[0].Family ='Product';
        productToInsertList[1].Family ='Product';
        productToInsertList[2].Family ='Lead Management';
        productToInsertList[0].name='Automation and Workflow';
        productToInsertList[1].name='Sandbox';
        productToInsertList[2].name='Sandbox Instance';
        insert productToInsertList;
    } 
    
    
    // Create Custom Pricebooks
    List<PriceBook2> priceBookList = new List<PriceBook2>();
    priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
    if(!priceBookList.isEmpty()){
        insert priceBookList;
    }
    
    // Insert data for custom setting - SteelBrickCPQPricebook__c
    SteelBrickCPQPricebook__c obj = new SteelBrickCPQPricebook__c();
    obj.Name = 'SteelBrick PB';
    obj.ID__c = priceBookList[0].Id;
    //insert obj;
    
    // Get Id of Standard Pricebook
    Id stdPbId = Test.getStandardPricebookId();
    
    
    // Insert Products into Standard Pricebook
    List<PriceBookEntry> pbEntryStdPbList = new List<PriceBookEntry>();
    for(Integer i=0; i<productToInsertList.size(); i++){
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = productToInsertList[i].Id,UnitPrice = 10000, IsActive = true);
        system.debug('stdPbId Inside PBE'+stdPbId);
        pbEntryStdPbList.add(pbe);
    }
    if(!pbEntryStdPbList.isEmpty()){
    insert pbEntryStdPbList;
    
    }
    
    
    List<PriceBookEntry> pbEntryCustPbList = new List<PriceBookEntry>();
    for(Integer i=0; i<productToInsertList.size(); i++){
        PricebookEntry pbe = new PricebookEntry(Pricebook2Id = priceBookList[0].id, Product2Id = productToInsertList[i].Id,UnitPrice = 10000, IsActive = true);
        pbEntryCustPbList.add(pbe);
    }
    
    if(!pbEntryCustPbList.isEmpty()){
        insert pbEntryCustPbList;
    }
    
    
    
    List<Opportunity> OpptyToBeInsertedList = new List<Opportunity>();
    OpptyToBeInsertedList = TestCPQUtilityClass.createOpportunities(accountsToBeInsertedList,1);
    OpptyToBeInsertedList[0].StageName            = '3 - Solution Definition';
    OpptyToBeInsertedList[0].PriceBook2Id         = priceBookList[0].id;
    OpptyToBeInsertedList[0].Quarterly_Renewal__c = string.valueof(2);
    OpptyToBeInsertedList[0].type                 = 'New Business';
    OpptyToBeInsertedList[0].Deal_Type__c         = 'Standard';
    OpptyToBeInsertedList[0].CAM_Owner_Email__c ='rajesh.wani@jadeglobal.com';
    OpptyToBeInsertedList[0].Actual_Close_Date__c=system.today();
    
    
    insert OpptyToBeInsertedList ;
    system.debug('OpptyToBeInsertedList '+OpptyToBeInsertedList ); 
    
    List<SBQQ__Quote__c> quotesToBeInsertedList= new List<SBQQ__Quote__c>();
    quotesToBeInsertedList = TestCPQUtilityClass.createQuotes(OpptyToBeInsertedList,1);
    
    for(SBQQ__Quote__c quote : quotesToBeInsertedList){
        quote.SBQQ__Primary__c = true;
        quote.SBQQ__SubscriptionTerm__c=12;
        quote.Rubiks_Quote__c=true;
        quote.SBQQ__Opportunity2__c=OpptyToBeInsertedList[0].id;
        quote.SBQQ__StartDate__c=system.today();
        quote.SBQQ__PriceBook__c=priceBookList[0].id;
        quote.MDQ_Quote__c=true;
    }
    insert quotesToBeInsertedList;
    system.debug('quotesToBeInsertedList'+quotesToBeInsertedList);
    
    List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
    
    SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=System.Today().addDays(7),SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6),SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=6,SBQQ__SegmentKey__c='1475100700835',SBQQ__SegmentIndex__c = 2);
    
    
    SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c( SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=System.Today().addDays(7),SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__EndDate__c,SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=6,SBQQ__SegmentKey__c='1475100700836',SBQQ__SegmentIndex__c = 1); 
    
    SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6),SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=6,SBQQ__SegmentKey__c='1475100700837',SBQQ__SegmentIndex__c = 3);
    
    SBQQ__QuoteLine__c quoteLine3 = new SBQQ__QuoteLine__c( SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6).addDays(1),SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__EndDate__c,SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=6,SBQQ__SegmentKey__c='1475100700838',SBQQ__SegmentIndex__c = 4);
    
    SBQQ__QuoteLine__c quoteLine4 = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=true,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[0].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6),SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=6,SBQQ__SegmentKey__c='1475100700839',SBQQ__SegmentIndex__c = 5);
    
    SBQQ__QuoteLine__c quoteLine5 = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=true,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[0].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6).addDays(1),SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=6,SBQQ__SegmentKey__c='1475100700830',SBQQ__SegmentIndex__c = 6);
    
    
    quoteLinesToInsert.add(quoteLine);
    quoteLinesToInsert.add(quoteLine1);
    quoteLinesToInsert.add(quoteLine2);
    quoteLinesToInsert.add(quoteLine3);
    quoteLinesToInsert.add(quoteLine4);
    quoteLinesToInsert.add(quoteLine5);
    //  Test.StartTest();
    insert quoteLinesToInsert;
    //  Test.StopTest();
    
    system.debug('quoteLinesToInsert#######'+quoteLinesToInsert);
    
    
    List<OpportunityLineItem> OLIListToBeInserted=new List<OpportunityLineItem>();       
    
    
    OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[1].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[0].Id,Segment_Start_Date__c=quoteLinesToInsert[0].SBQQ__StartDate__c,Users__c=1,Create_Asset__c=true,ServiceDate=quoteLinesToInsert[0].SBQQ__StartDate__c);           
    
    OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[1].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[1].Id,Segment_Start_Date__c=quoteLinesToInsert[1].SBQQ__StartDate__c,Users__c=1,Create_Asset__c=true,ServiceDate=quoteLinesToInsert[1].SBQQ__StartDate__c);
    
    OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[2].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[2].Id,Segment_Start_Date__c=quoteLinesToInsert[2].SBQQ__StartDate__c,Users__c=1,Create_Asset__c=true,ServiceDate=quoteLinesToInsert[2].SBQQ__StartDate__c);
    
    OpportunityLineItem oli4 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[2].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[3].Id,Segment_Start_Date__c=quoteLinesToInsert[3].SBQQ__StartDate__c,Users__c=1,Create_Asset__c=true,ServiceDate=quoteLinesToInsert[3].SBQQ__StartDate__c);
    
    OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[0].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[4].Id,Segment_Start_Date__c=quoteLinesToInsert[4].SBQQ__StartDate__c,Users__c=1,ServiceDate=quoteLinesToInsert[4].SBQQ__StartDate__c);
    
    OpportunityLineItem oli5 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[0].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[5].Id,Segment_Start_Date__c=quoteLinesToInsert[5].SBQQ__StartDate__c,Users__c=1,ServiceDate=quoteLinesToInsert[5].SBQQ__StartDate__c);
    
    
    OLIListToBeInserted.add(oli1);
    OLIListToBeInserted.add(oli2);
    OLIListToBeInserted.add(oli3);
    OLIListToBeInserted.add(oli4);
    OLIListToBeInserted.add(oli);
    OLIListToBeInserted.add(oli5);
    if(!OLIListToBeInserted.isEmpty()){
        insert OLIListToBeInserted;
    }
    update OLIListToBeInserted;
    
	OpptyToBeInsertedList[0].Migration__c = true;
    OpptyToBeInsertedList[0].StageName            = 'Signed Order';
    OpptyToBeInsertedList[0].Subscription_Language__c = 'English';
    OpptyToBeInsertedList[0].Subscription_Locale__c = 'English-United States';
    OpptyToBeInsertedList[0].Subscription_Time_Zone__c = 'Afghanistan Time (Asia/Kabul)';
    OpptyToBeInsertedList[0].Use_Case__c = 'B2B';
    OpptyToBeInsertedList[0].Needs_Pains__c = 'test';
    OpptyToBeInsertedList[0].MainCompetitor__c = 'Act-On';
    update OpptyToBeInsertedList;
    
	OpptyToBeInsertedList[0].Migration__c = false;
    OpptyToBeInsertedList[0].StageName            = 'Closed Won';
    OpptyToBeInsertedList[0].Stage_Signed_Order_Date__c=system.Today();
    //OpptyToBeInsertedList[0].SBQQ__Contracted__c=true;
    OpptyToBeInsertedList[0].SBQQ__PrimaryQuote__c=quotesToBeInsertedList[0].id;
    OpptyToBeInsertedList[0].Actual_Close_Date__c=system.today();
    
    update OpptyToBeInsertedList;
    set<Id>OpIdSet =new set<Id>();
    //  system.assertEquals(system.today(),OpptyToBeInsertedList[0].Actual_Close_Date__c);
    //system.assertEquals(True,OpptyToBeInsertedList[0].isWon);
    
    for(Opportunity op:OpptyToBeInsertedList){
        OpIdSet.add(op.Id);
    }
    
    
    list<Opportunity> OppList=[select id,isWon,Actual_Close_Date__c,CAM_Owner_Email__c from Opportunity where Id IN:OpIdSet];
    
    
    
    system.assertEquals(True,OppList[0].isWon);
    system.debug('OpptyToBeInsertedList Updated Opp'+OpptyToBeInsertedList);
    
    
    
    String query='SELECT id,iswon,stagename,Actual_Close_Date__c,SBQQ__PrimaryQuote__c,SBQQ__PrimaryQuote__r.MDQ_Quote__c FROM Opportunity WHERE iswon != null AND Actual_Close_Date__c=:system.today()';
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
    
    Test.startTest();
    QuoteSegmentStartDateBatch c = new QuoteSegmentStartDateBatch();
    
    Database.executeBatch(c);
    list<case> ProvisiCaseList=[SELECT id FROM CASE];
    // system.assertEquals(1, ProvisiCaseList.size());
    Test.stopTest();
    
    }//End of Test method testQuoteSegmentStartDateBatch
}