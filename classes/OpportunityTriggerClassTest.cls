@isTest
public class OpportunityTriggerClassTest {   
/*   
    public static testmethod void currrencyAmountTest(){
    lmscons__Disable_triggers__c ldt = new lmscons__Disable_triggers__c();
     ldt.Name = 'OpportunityTriggerManagement';
     ldt.lmscons__After_Delete__c = true;
     ldt.lmscons__After_Insert__c = true;
     ldt.lmscons__After_Update__c = true;
     ldt.lmscons__Before_Delete__c = true;
     ldt.lmscons__Before_Insert__c = true;
     ldt.lmscons__Before_Update__c = true;
     insert ldt;
     System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt);
     lmscons__Disable_triggers__c ldt2 = new lmscons__Disable_triggers__c();
     ldt2.Name = 'AccountTriggerManagement';
     ldt2.lmscons__After_Delete__c = true;
     ldt2.lmscons__After_Insert__c = true;
     ldt2.lmscons__After_Update__c = true;
     ldt2.lmscons__Before_Delete__c = true;
     ldt2.lmscons__Before_Insert__c = true;
     ldt2.lmscons__Before_Update__c = true;
     insert ldt2;
        
        Marketo_Trigger_Management__c MKTMgt=new Marketo_Trigger_Management__c(Activate_Legacy_Triggers__c=True);
        insert MKTMgt;
        
        Intacct_Entity__c entity=new Intacct_Entity__c(Name='marketo-rubiks');
        insert entity;
        
        Account acc = UtilityToCreateTestData.insertAccount();
        date toCloseDate = Date.newInstance(2014,12,30);
        list<Opportunity> insertOpptyList = new list<Opportunity>();
        list<Opportunity> updateOpptyList = new list<Opportunity>();
        acc.Intacct_Entity__c=entity.id;
        acc.IntacctID__c = 'TestIntacctID123456';
        update acc;
        for(integer i=0;i<10;i++){
            Opportunity opp = new Opportunity(
                            Name        = 'Test Opportunity', 
                            AccountId   = acc.id, 
                            StageName   = 'Closed Won', 
                            Type        = 'New Business',
                            CloseDate   = toCloseDate,
                            Amount      =  1000,
                            SBQQ__Contracted__c =true,
                            CurrencyIsoCode = 'USD'
                            
            );
            Opportunity euroopp = new Opportunity(
                                Name        = 'Test Opportunity Euro', 
                                AccountId   = acc.id, 
                                StageName   = 'Discovery', 
                                Type        = 'New Business',
                                CloseDate   = toCloseDate,
                                Amount      =  1000,
                                CurrencyIsoCode = 'EUR'
                );
           
            insertOpptyList.add(Opp);
            insertOpptyList.add(euroopp);
           // insertOpptyList.add(AUDopp);
        }
        
        insert insertOpptyList;
         Test.StartTest();
        list<opportunity> getOpptyInsertResult = [SELECT id,currencyISOcode,Est_USD_Amount__c FROM Opportunity WHERE id IN :insertOpptyList and currencyISOcode='USD' AND Est_USD_Amount__c!=null];
        //system.assertEquals(10, getOpptyInsertResult.size());
        for(Opportunity oppty :insertOpptyList){
            if(oppty.currencyISOcode !='USD'){
                oppty.Third_Party_Solutions__c='No';
                oppty.Intacct_Entity__c=entity.id;
                Oppty.StageName     = 'Closed Won';
                Oppty.SBQQ__Contracted__c =true;
                oppty.Amount        = 2000;
                updateOpptyList.add(oppty);
            }
        }
        update updateOpptyList;
         list<opportunity> getOpptyUpdateResult = [SELECT id,currencyISOcode,Est_USD_Amount__c FROM Opportunity WHERE id IN :updateOpptyList and currencyISOcode!='USD' AND Est_USD_Amount__c!=null];
       // system.assertEquals(10, getOpptyUpdateResult.size());
        Test.StopTest();
        
    }
    
        public static testmethod void deleteOppTest(){
        lmscons__Disable_triggers__c ldt = new lmscons__Disable_triggers__c();
     ldt.Name = 'OpportunityTriggerManagement';
     ldt.lmscons__After_Delete__c = true;
     ldt.lmscons__After_Insert__c = true;
     ldt.lmscons__After_Update__c = true;
     ldt.lmscons__Before_Delete__c = true;
     ldt.lmscons__Before_Insert__c = true;
     ldt.lmscons__Before_Update__c = true;
     insert ldt;
     System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt);
     lmscons__Disable_triggers__c ldt2 = new lmscons__Disable_triggers__c();
     ldt2.Name = 'AccountTriggerManagement';
     ldt2.lmscons__After_Delete__c = true;
     ldt2.lmscons__After_Insert__c = true;
     ldt2.lmscons__After_Update__c = true;
     ldt2.lmscons__Before_Delete__c = true;
     ldt2.lmscons__Before_Insert__c = true;
     ldt2.lmscons__Before_Update__c = true;
     insert ldt2;
        Marketo_Trigger_Management__c MKTMgt=new Marketo_Trigger_Management__c(Activate_Legacy_Triggers__c=True);
        insert MKTMgt;
        
        Intacct_Entity__c entity=new Intacct_Entity__c(Name='marketo-rubiks');
        insert entity;
        
        Account acc = UtilityToCreateTestData.insertAccount();
        date toCloseDate = Date.newInstance(2014,12,30);
        list<Opportunity> insertOpptyList = new list<Opportunity>();
        list<Opportunity> updateOpptyList = new list<Opportunity>();
        acc.Intacct_Entity__c=entity.id;
        acc.IntacctID__c = 'TestIntacctID123456';
        update acc;
        for(integer i=0;i<10;i++){
            Opportunity opp = new Opportunity(
                            Name        = 'Test Opportunity', 
                            AccountId   = acc.id, 
                            StageName   = 'Closed Won', 
                            Type        = 'New Business',
                            CloseDate   = toCloseDate,
                            Amount      =  1000,
                            SBQQ__Contracted__c =true,
                            CurrencyIsoCode = 'USD'
                            
            );
            Opportunity euroopp = new Opportunity(
                                Name        = 'Test Opportunity Euro', 
                                AccountId   = acc.id, 
                                StageName   = 'Discovery', 
                                Type        = 'New Business',
                                CloseDate   = toCloseDate,
                                Amount      =  1000,
                                CurrencyIsoCode = 'EUR'
                );
           
            insertOpptyList.add(Opp);
            insertOpptyList.add(euroopp);
           // insertOpptyList.add(AUDopp);
        }
        
        insert insertOpptyList;
         Test.StartTest();
        list<opportunity> getOpptyInsertResult = [SELECT id,currencyISOcode,Est_USD_Amount__c FROM Opportunity WHERE id IN :insertOpptyList and currencyISOcode='USD' AND Est_USD_Amount__c!=null];
        //system.assertEquals(10, getOpptyInsertResult.size());
        for(Opportunity oppty :insertOpptyList){
            if(oppty.currencyISOcode !='USD'){
                oppty.Third_Party_Solutions__c='No';
                oppty.Intacct_Entity__c=entity.id;
                Oppty.StageName     = 'Closed Won';
                Oppty.SBQQ__Contracted__c =true;
                oppty.Amount        = 2000;
                updateOpptyList.add(oppty);
            }
        }
        update updateOpptyList;
         list<opportunity> getOpptyUpdateResult = [SELECT id,currencyISOcode,Est_USD_Amount__c FROM Opportunity WHERE id IN :updateOpptyList and currencyISOcode!='USD' AND Est_USD_Amount__c!=null];
       // system.assertEquals(10, getOpptyUpdateResult.size());
       
       delete updateOpptyList;
       //undelete updateOpptyList;
       
        Test.StopTest();
        
    }
 */   
    public static testmethod void DTOTest(){
    
    lmscons__Disable_triggers__c ldt = new lmscons__Disable_triggers__c();
     ldt.Name = 'OpportunityTriggerManagement';
     ldt.lmscons__After_Delete__c = true;
     ldt.lmscons__After_Insert__c = true;
     ldt.lmscons__After_Update__c = true;
     ldt.lmscons__Before_Delete__c = true;
     ldt.lmscons__Before_Insert__c = true;
     ldt.lmscons__Before_Update__c = true;
     insert ldt;
     System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt);
     lmscons__Disable_triggers__c ldt2 = new lmscons__Disable_triggers__c();
     ldt2.Name = 'AccountTriggerManagement';
     ldt2.lmscons__After_Delete__c = true;
     ldt2.lmscons__After_Insert__c = true;
     ldt2.lmscons__After_Update__c = true;
     ldt2.lmscons__Before_Delete__c = true;
     ldt2.lmscons__Before_Insert__c = true;
     ldt2.lmscons__Before_Update__c = true;
     insert ldt2;
        List<Account> accntList = new List<Account>();
            accntList = TestCPQUtilityClass.createAccounts(1);
        
            if(!accntList.isEmpty()){
            insert accntList;
            }
        
            List<Contact> contactList = new List<Contact>();
            contactList = TestCPQUtilityClass.createContacts(accntList,1);
            if(!contactList.isEmpty()){
                insert contactList;
            }
            System.debug('Contact List ========' + contactList);
        
            // Create Products
            List<Product2> prodList = new List<Product2>();
            List<Product2> prodListWithCode = new List<Product2>();
            List<ProductCodeVSOETier__c> ProductCodeVSOETierList = new List<ProductCodeVSOETier__c>();
            prodList = TestCPQUtilityClass.createCustomProducts(6);
        
            prodList[0].CurrencyIsoCode = 'EUR';
            integer j=0;
            for(Product2 prd: ProdList){
                 prd.CurrencyIsoCode = 'EUR';
                prd.PRODUCTCODE = 'PRODUCTCODE'+j;
                prodListWithCode.add(prd);
              
               
                j=j+1;
            }
                 ProductCodeVSOETier__c ProductCodeVSOETier1 =  new ProductCodeVSOETier__c(name=  prodListWithCode[0].PRODUCTCODE, Tier_1_Low__c=1,Tier_1_High__c=10);
                 ProductCodeVSOETierList.add(ProductCodeVSOETier1);
                 
                 ProductCodeVSOETier__c ProductCodeVSOETier2 =  new ProductCodeVSOETier__c(name=  prodListWithCode[1].PRODUCTCODE, Tier_1_Low__c=1,Tier_1_High__c=10,Tier_2_Low__c=11,Tier_2_High__c=100);
                 ProductCodeVSOETierList.add(ProductCodeVSOETier2);
        
                 ProductCodeVSOETier__c ProductCodeVSOETier3 =  new ProductCodeVSOETier__c(name=  prodListWithCode[2].PRODUCTCODE, Tier_1_Low__c=1,Tier_1_High__c=10,Tier_2_Low__c=11,Tier_2_High__c=100,Tier_3_Low__c=101,Tier_3_High__c=200);
                 ProductCodeVSOETierList.add(ProductCodeVSOETier3);
                 
                 ProductCodeVSOETier__c ProductCodeVSOETier4 =  new ProductCodeVSOETier__c(name=  prodListWithCode[3].PRODUCTCODE, Tier_1_Low__c=1,Tier_1_High__c=10,Tier_2_Low__c=11,Tier_2_High__c=100,Tier_3_Low__c=101,Tier_3_High__c=200,Tier_4_Low__c=201,Tier_4_High__c=300);
                 ProductCodeVSOETierList.add(ProductCodeVSOETier4);
        
                ProductCodeVSOETier__c ProductCodeVSOETier5 =  new ProductCodeVSOETier__c(name=  prodListWithCode[4].PRODUCTCODE, Tier_1_Low__c=1,Tier_1_High__c=10,Tier_2_Low__c=11,Tier_2_High__c=100,Tier_3_Low__c=101,Tier_3_High__c=200,Tier_4_Low__c=201,Tier_4_High__c=300,Tier_5_Low__c=301,Tier_5_High__c=400);
                ProductCodeVSOETierList.add(ProductCodeVSOETier5);
        
                ProductCodeVSOETier__c ProductCodeVSOETier6 =  new ProductCodeVSOETier__c(name=  prodListWithCode[5].PRODUCTCODE, Tier_1_Low__c=1,Tier_1_High__c=10,Tier_2_Low__c=11,Tier_2_High__c=100,Tier_3_Low__c=101,Tier_3_High__c=200,Tier_4_Low__c=201,Tier_4_High__c=300,Tier_5_Low__c=301,Tier_5_High__c=400,Tier_6_Low__c=401,Tier_6_High__c=500);
                ProductCodeVSOETierList.add(ProductCodeVSOETier6);
            if(!prodList.isEmpty()){
                insert prodListWithCode;
            }
            if(!ProductCodeVSOETierList.isEmpty()){
                insert ProductCodeVSOETierList;
            }
        // Create Custom Pricebooks
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }
        
        System.debug('Pricebooks List ========' + priceBookList);

        // Get Id of Standard Pricebook
        Id stdPbId = Test.getStandardPricebookId();
        
        // Insert Products into Standard Pricebook
        List<PriceBookEntry> pbEntryStdPbList = new List<PriceBookEntry>();
        for(Integer i=0; i<prodListWithCode.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodListWithCode[i].Id,UnitPrice = 1000, IsActive = true, CurrencyIsoCode = 'EUR');
            pbEntryStdPbList.add(pbe);
        }
        
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }
       
        date toCloseDate = Date.newInstance(2013,12,30);
        // Create Opportunities with stage Closed Won
        
        List<Opportunity> oppotyList = new List<Opportunity>();
        oppotyList = TestCPQUtilityClass.createOpportunities(accntList,1);
        
        oppotyList[0].StageName = 'Closed Won';
        oppotyList[0].PriceBook2Id = stdPbId;
        oppotyList[0].AccountId = accntList[0].Id;
        oppotyList[0].type     = 'Renewal';
        oppotyList[0].CloseDate = System.Today().addYears(1);
        oppotyList[0].CurrencyIsoCode = 'EUR';
        
         insert oppotyList;
        // Insert OLIs
    List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
    
    OpportunityLineItem oliTest = new OpportunityLineItem();
    oliTest.OpportunityId = oppotyList[0].Id;
    oliTest.PricebookEntryId = pbEntryStdPbList[0].Id; 
    oliTest.UnitPrice = 1234.00; 
    oliTest.Quantity = 2;

    OpportunityLineItem opli = new OpportunityLineItem();
    opli.OpportunityId = oppotyList[0].Id;
    opli.PricebookEntryId = pbEntryStdPbList[1].Id;
    opli.UnitPrice = 10; 
    opli.Quantity = 11;
    
    OpportunityLineItem opli2 = new OpportunityLineItem();
    opli2.OpportunityId = oppotyList[0].Id;
    opli2.PricebookEntryId = pbEntryStdPbList[2].Id;
    opli2.UnitPrice = 10; 
    opli2.Quantity = 111;
     
    OpportunityLineItem opli3 = new OpportunityLineItem();
    opli3.OpportunityId = oppotyList[0].Id;
    opli3.PricebookEntryId = pbEntryStdPbList[3].Id;
    opli3.UnitPrice = 10; 
    opli3.Quantity = 222;
  
    OpportunityLineItem opli4 = new OpportunityLineItem();
    opli4.OpportunityId = oppotyList[0].Id;
    opli4.PricebookEntryId = pbEntryStdPbList[4].Id;
    opli4.UnitPrice = 10; 
    opli4.Quantity = 333;
    
    OpportunityLineItem opli5 = new OpportunityLineItem();
    opli5.OpportunityId = oppotyList[0].Id;
    opli5.PricebookEntryId = pbEntryStdPbList[5].Id;
    opli5.UnitPrice = 10; 
    opli5.Quantity = 444;
  
                
    oliList.add(oliTest);
    oliList.add(opli);
    oliList.add(opli2);
    oliList.add(opli3);
    oliList.add(opli4);
    oliList.add(opli5);
  
    insert oliList;
        
        // create sales order
    Sales_Order__c so = new Sales_Order__c();
    so.Opportunity__c = oppotyList[0].Id;
    insert so;
        
    Test.startTest();
    oppotyList[0].stagename ='A - Qualify';
    update oppotyList;
    oppotyList[0].StageName = 'Closed Won';
    oppotyList[0].closedate = system.today()+100;
    oppotyList[0].Plan_of_Record_Renewal_Date__c = system.today()+100;
    update oppotyList;
         
        Test.stopTest();
        
    }//End of Test Method DTOTest
  
  public static testMethod void coverUpdateDTOsTest(){
  lmscons__Disable_triggers__c ldt = new lmscons__Disable_triggers__c();
     ldt.Name = 'OpportunityTriggerManagement';
     ldt.lmscons__After_Delete__c = true;
     ldt.lmscons__After_Insert__c = true;
     ldt.lmscons__After_Update__c = true;
     ldt.lmscons__Before_Delete__c = true;
     ldt.lmscons__Before_Insert__c = true;
     ldt.lmscons__Before_Update__c = true;
     insert ldt;
     System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt);
     lmscons__Disable_triggers__c ldt2 = new lmscons__Disable_triggers__c();
     ldt2.Name = 'AccountTriggerManagement';
     ldt2.lmscons__After_Delete__c = true;
     ldt2.lmscons__After_Insert__c = true;
     ldt2.lmscons__After_Update__c = true;
     ldt2.lmscons__Before_Delete__c = true;
     ldt2.lmscons__Before_Insert__c = true;
     ldt2.lmscons__Before_Update__c = true;
     insert ldt2;
    
    Account acc = UtilityToCreateTestData.insertAccount();
    
    // prodcut list
    List<Product2> prodList = new List<Product2>();
    // Product 1 MA, B2B
    Product2 prod1 = new Product2(Name = 'Test Product', ProductCode = 'TESTPROD123321', isActive=TRUE, Product_Type__c = 'Subscription');
    
    // Product 2 - Analytics,RCA
    Product2 prod2 = new Product2(Name = 'Test Product', ProductCode = 'TESTPROD123321', isActive=TRUE,Product_Type__c = 'Subscription');
    
    Product2 prod3 = new Product2(Name = 'Test Product', ProductCode = 'TESTPROD123321', isActive=TRUE,Product_Type__c = 'Subscription');
    
    prodList.add(prod1);
    prodList.add(prod2);
    prodList.add(prod3);  
    insert prodList;
    
    // Get Standard Pricebook Id
    Id stdPbId = Test.getStandardPricebookId();
        
        // Insert Products in SteelBrick Pricebook
    PriceBookEntry pbEntry1 = UtilityToCreateTestData.insertPriceBookEntry(prodList[0].id, stdPbId);
    PriceBookEntry pbEntry2 = UtilityToCreateTestData.insertPriceBookEntry(prodList[1].id, stdPbId);
    PriceBookEntry pbEntry3 = UtilityToCreateTestData.insertPriceBookEntry(prodList[2].id, stdPbId);
        
        // Get SteelBick PB
        Id SB_PB_Id = '01s50000000OEDvAAO'; // MKTO PB Id
        
        // Insert Products in SteelBrick Pricebook
    PriceBookEntry pbEntry11 = UtilityToCreateTestData.insertPriceBookEntry(prodList[0].id, SB_PB_Id);
    PriceBookEntry pbEntry22 = UtilityToCreateTestData.insertPriceBookEntry(prodList[1].id, SB_PB_Id);
    PriceBookEntry pbEntry33 = UtilityToCreateTestData.insertPriceBookEntry(prodList[2].id, SB_PB_Id);
    
    // Insert New Business Opportunity
    date toCloseDate = Date.newInstance(2012,12,30);
    Opportunity oppWith3Products = UtilityToCreateTestData.insertOpportunity(acc.id, 'A - Not Contacted', 'Renewal', toCloseDate);  
    
    // Insert OpportunityLineItem
    OpportunityLineItem opli1 = UtilityToCreateTestData.insertOppLineItem(oppWith3Products.id, pbEntry11.id, 10, 1);    
    OpportunityLineItem opli2 = UtilityToCreateTestData.insertOppLineItem(oppWith3Products.id, pbEntry22.id, 10, 1);    
    OpportunityLineItem opli3 = UtilityToCreateTestData.insertOppLineItem(oppWith3Products.id, pbEntry33.id, 10, 1);
    
    // Insert Sales Order - DTOs will be created after that.
    Sales_Order__c so1 = new Sales_Order__c(Opportunity__c = oppWith3Products.id);
    insert so1;  
    /*
        list<Deal_transaction__c > DtoList = [SELECT id,Opportunity__r.CloseDate, Opportunity__r.Sub_End_Date__c, Opportunity__r.Sub_Start_Date__c, Purchased_Start_Date__c, Purchased_End_Date__c, Munchkin_Id__c, Opportunity_Type__c, Account__c, Opportunity__c, Aisle_Bin_Combination__c, name, Account__r.name, Purchased_Product__c,Opportunity_Id__c ,Purchased_Close_Date__c, Error_Code__c FROM Deal_transaction__c WHERE Opportunity__c =:oppWith3Products.id];
    System.debug('DtoList from test************' + DtoList);
    */    
        // Insert Renewal Opportunity
    Opportunity oppWith1Products = UtilityToCreateTestData.insertOpportunity(acc.id, 'Closed Won', 'Renewal', Date.newInstance(2013,12,30));    
    oppWith1Products.Adjusted_POR__c = 500;    
    oppWith1Products.Sub_Start_Date__c = Date.newInstance(2012,12,30);
    oppWith1Products.Sub_End_Date__c = Date.newInstance(2013,12,30);
    update oppWith1Products;
    
    // Insert Products for Renewal Opportunity
    OpportunityLineItem opli4 = UtilityToCreateTestData.insertOppLineItem(oppWith1Products.id, pbEntry1.id, 10, 1);
    OpportunityLineItem opli5 = UtilityToCreateTestData.insertOppLineItem(oppWith1Products.id, pbEntry2.id, 10, 1);
        OpportunityLineItem opli6 = UtilityToCreateTestData.insertOppLineItem(oppWith1Products.id, pbEntry3.id, 10, 1);
    
    // Insert Sales Order - DTOs will be created after that.
    Sales_Order__c so2 = new Sales_Order__c(Opportunity__c = oppWith1Products.id);
    insert so2;
      /*  
     list<Deal_transaction__c > renOppDtoList = [SELECT id,Opportunity__r.CloseDate, Opportunity__r.Sub_End_Date__c, Opportunity__r.Sub_Start_Date__c, Purchased_Start_Date__c, Purchased_End_Date__c, Munchkin_Id__c, Opportunity_Type__c, Account__c, Opportunity__c, Aisle_Bin_Combination__c, name, Account__r.name, Purchased_Product__c,Opportunity_Id__c ,Purchased_Close_Date__c, Error_Code__c  FROM Deal_transaction__c WHERE Opportunity__c =:oppWith3Products.id];
    System.debug('renOppDtoList from test************' + renOppDtoList);
       */ 
        date newCloseDate = Date.newInstance(2013,01,01);
    oppWith3Products.CloseDate = newCloseDate;
    oppWith3Products.StageName = 'Closed Won';
    update oppWith3Products;
        
        Set<Id> oppIdSet = new Set<Id>();
        oppIdSet.add(oppWith3Products.Id);
        oppIdSet.add(oppWith1Products.Id);
       list<OpportunityLineItem> oliConfigList = new  list<OpportunityLineItem>();
      oliConfigList.add(opli4);
      list<OpportunityLineItem> OppProdList= OpportunityConfigurator.fixUnitPriceTotalPriceConflict(oliConfigList);
       list<OpportunityLineItem> oliConfigList1 =new  list<OpportunityLineItem>();
      oliConfigList1.add(new OpportunityLineItem(opportunityid=oppWith3Products.id));
     list<OpportunityLineItem> OppProdList2= OpportunityConfigurator.fixUnitPriceTotalPriceConflict(oliConfigList1);
       OpportunityConfigurator oppconfig = new OpportunityConfigurator(new ApexPages.StandardController(oppWith3Products));
      oppconfig.lineItemWrappers = null;
      oppconfig.editedField      = null;
      //OpportunityTriggerclass.UpdateDTOs(oppIdSet);
  }
}