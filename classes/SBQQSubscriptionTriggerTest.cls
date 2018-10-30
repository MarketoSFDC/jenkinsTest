/**************************************************************************************************************************************
Company Name  :Jade Global Inc.
Created Date  :10th February 2018
Apex Class    :SBQQSubscriptionTriggerTest
**************************************************************************************************************************************/

@IsTest
public class SBQQSubscriptionTriggerTest {

    public static testMethod void testSubscriptions(){      
    
    SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        // Create accounts to insert
        Set<Id> accountsToInsertSet = new Set<Id>();
        map<id, id> AccToCont = new Map<id,id>();
        List<Account> accountsToInsertList = new List<Account>();
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        for(Account accnt: TestCPQUtilityClass.createAccounts(2)){
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
        ContactToInsert = TestCPQUtilityClass.createContacts(accountsToInsertList,2);
       for(Contact con:ContactToInsert ){
                con.pse__Salesforce_User__c  =null;
         }
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
        productToInsertList[1].ProductCode = 'TESTClassPRODCODE' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        insert productToInsertList;
        system.debug('---productToInsertList[0]---'+productToInsertList[0]);
        // insert products into standard pricebook
        Id stdPricebookId = Test.getStandardPricebookId();
        TestCPQUtilityClass.createStdPricebookEntries(productToInsertList,stdPricebookId);
        
        // Create custom pricebooks
        List<PriceBook2> pricebookList = new List<PriceBook2>();
        pricebookList =TestCPQUtilityClass.createCustomPriceBooks(5);
        insert pricebookList;
        
        // insert products into custom pricebooks
        List<PriceBookEntry> priceBookEntriesList = new List<PriceBookEntry>();
        priceBookEntriesList =TestCPQUtilityClass.createPriceBookEntries(productToInsertList,pricebookList);
        insert priceBookEntriesList;
        
        // Insert data for custom setting - Contract_Roll_Up_With_Product_Code__c       
        List<Contract_Roll_Up_With_Product_Code__c> productCodeList = new List<Contract_Roll_Up_With_Product_Code__c>();
        Contract_Roll_Up_With_Product_Code__c crp1 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test Product 1 ', FieldName__c='Contract_Base_ACV_for_Support__c',   Multiplier__c=3, Need_To_Check_Criteria__c = true, Product_Code__c = 'TESTPRODCODE0, TESTPRODCODE1', Subscription_Field__c = 'Subscription_ACV__c', User_Code__c= 'SUP-BASE-BUS, SUP-BASE-ELT, SUP-BASE-STD-ENT, SUP-BASE-PRM, SUP-BASE-STD-SMB, SUP-BASE-SPK',Include_in_Maintenance__c = true);           
        Contract_Roll_Up_With_Product_Code__c crp2 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test', FieldName__c='Contract_Base_ACV_for_Support__c',  Multiplier__c=3, Need_To_Check_Criteria__c = true, Product_Code__c = 'TESTPRODCODE2,TESTPRODCODE3', Subscription_Field__c = 'Subscription_ACV__c', User_Code__c = null, Include_in_Maintenance__c = true,SUP_Product_code__c = 'tes');          
        Contract_Roll_Up_With_Product_Code__c crp3 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test 2', FieldName__c='Contract_Base_ACV_for_Support__c',    Multiplier__c=3, Need_To_Check_Criteria__c = false, Product_Code__c = 'TPC4', Subscription_Field__c = 'Subscription_ACV__c');           
        Contract_Roll_Up_With_Product_Code__c crp4 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test 3', FieldName__c='Contract_Base_ACV_for_Support__c',    Multiplier__c=3, Need_To_Check_Criteria__c = false, Product_Code__c = 'TPC4', Subscription_Field__c ='Subscription_MCV__c');            
        productCodeList.add(crp1);
        productCodeList.add(crp2);
        productCodeList.add(crp3);
        productCodeList.add(crp4);
        insert productCodeList;        
        
        // Insert data for custom setting - Entitlement_Product_Code_Criteria__c
        List<Entitlement_Product_Code_Criteria__c> entProdCodeList = new List<Entitlement_Product_Code_Criteria__c>();
        Entitlement_Product_Code_Criteria__c entProdCode = new Entitlement_Product_Code_Criteria__c(Name ='Test Name',Product_Code__c = 'TESTPROD2', Type__c = 'Test');
        entProdCodeList.add(entProdCode);
        insert entProdCodeList;
        
        // insert opportunities - for Closed Won Oppty - Contract will be created automatically
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities(accountsToInsertList,2);
        for(Opportunity opp : opptyList){
            opp.Rep_Create_ARR__c = 10000;
            opp.Amount = 2000;
            opp.Pricebook2Id = pricebookList[0].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.OwnerId=UserInfo.getUserId();
            if(AccToCont.containsKey(opp.AccountId)){
                opp.Primary_Marketo_User_Lookup__c = AccToCont.get(opp.AccountId) ;
                opp.Primary_Marketo_User_Email__c = 'test.abc@jade.com' ;
            }
        }
        
        opptyList[2].type = 'Renewal';
        opptyList[3].type = 'Upsell';
        Test.startTest();
SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;       
        if(!opptyList.isEmpty()){
            insert opptyList;
        }
        System.debug('opptyList[0].Accountid...'+opptyList[0].Accountid);
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        // Create Quote     
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opptyList[0].Id,SBQQ__Account__c= opptyList[0].accountId, SBQQ__StartDate__c = System.Today());
        insert quote;
        
       SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
       
        
         // create contracts 
         List<Contract> contractList = new List<Contract>();
         Contract contract1 = new Contract(Name='Test Contract ', AccountId=opptyList[0].AccountId,SBQQ__Opportunity__c = opptyList[0].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true, SBQQ__Quote__c = quote.Id,ContractTerm = 2);         
         Contract contract2 = new Contract(Name='Test Contract ', AccountId=opptyList[0].AccountId,SBQQ__Opportunity__c = opptyList[0].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 2);
         Contract contract3 = new Contract(Name='Test Contract ', AccountId=opptyList[2].AccountId,SBQQ__Opportunity__c = opptyList[2].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 3);
         Contract contract4 = new Contract(Name='Test Contract ', AccountId=opptyList[2].AccountId,SBQQ__Opportunity__c = opptyList[3].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm =4 );
         contractList.add(contract1);
         contractList.add(contract2);
         contractList.add(contract3);
         contractList.add(contract4);
         insert contractList;
        
        opptyList[2].SBQQ__RenewedContract__c = contractList[0].Id;
        update opptyList;
        
        List<Asset> assetList = new List<Asset>();
        Asset as1 = new Asset();
        as1.Name = 'Test Asset 1';
        as1.installdate = System.today();
        as1.UsageEndDate = System.today().addMonths(2);
        as1.Opportunity__c = opptyList[0].Id;
        as1.Asset_Type__c='Instance';
        as1.purpose__c='Production';
        as1.Product2Id= productToInsertList[0].Id;
        as1.AccountId = accountsToInsertList[0].Id;
        as1.ContactId = ContactToInsert[0].id;
        as1.status = 'Active';
        as1.Contract__c = contractList[0].Id;
        
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = opptyList[0].Id;
        as1.Product2Id = productToInsertList[2].Id;
        as2.AccountId = accountsToInsertList[0].Id;
        as2.ContactId = ContactToInsert[0].id;
        as2.status = 'Active';
        as2.Contract__c = contractList[0].Id;
        assetList.add(as1);
        assetList.add(as2);
        list<Product2> Product2List = [SELECT id,name,ProductCode FROM  Product2 WHERE Id IN :productToInsertList]; 
         system.debug('Product2List======='+Product2List);
        if(!assetList.isEmpty()){
            insert assetList;
        } 
       list<asset> assBunAssetList = [SELECT id,Product2id,name,Product_Code__c,Associated_Bundle__c FROM  Asset WHERE Id IN :assetList];  
       system.debug('assBunAssetList======='+assBunAssetList);
          
         
        
        contractList[0].Primary_Asset__c = assetList[0].Id;
        contractList[1].Primary_Asset__c = assetList[1].Id;
        update contractList;
        
        System.debug('Contracts on Asset ===> ' + [Select id, Primary_Asset__c from Contract where id =: contractList[0].Id]);     
        
        // create subscriptions
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234,SBQQ__Product__c =productToInsertList[0].Id);       
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[1].Id);
        SBQQ__Subscription__c sub3 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[1].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[2].Id);
        SBQQ__Subscription__c sub4 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[1].Id,SBQQ__Account__c=contractList[1].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[3].Id);
        SBQQ__Subscription__c sub5 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[3].Id,SBQQ__Account__c=contractList[3].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[4].Id);
        
        subList.add(sub1);
        subList.add(sub2);
        subList.add(sub3);
        subList.add(sub4);
        subList.add(sub5);
        insert subList;
        
        // UPDATE SUBSCRIPTIONS 
        subList[0].SBQQ__Contract__c = contractList[1].Id;
        subList[0].SBQQ__Quantity__c = 4;
        
        // remove contract from subscriptoin, Change terminated date
        subList[1].SBQQ__Contract__c = null;
        subList[1].SBQQ__TerminatedDate__c=System.today().addMonths(5);
        update subList;   
        
        //***********************************
        UpdateAssets.updateAccount(assetList);
        
        Map<id,Asset> MapAstIdAndAsset = new Map<id,Asset>();
        
        List<Entitlement> lstEnt = TestCPQUtilityClass.createEntitlements(subList,2);
        for(Entitlement ent: lstEnt){
            ent.AccountId = accountsToInsertList[0].Id;
        }
        Insert lstEnt;
        
        assetList[0].AccountId = accountsToInsertList[0].Id;
        update assetList;
        
        for(Entitlement entl : lstEnt){
            entl.AssetId = assetList[0].id;
        }
        update lstEnt;
        
        for(Asset ast: assetList){
            MapAstIdAndAsset.put(ast.Id,ast);           
        }
        UpdateAssets.updateEntitlementStartdate(MapAstIdAndAsset);
        
        
      //  SBQQContractAndSubscriptionTriggerHelper.updateAccountRec(accountsToInsertSet,subList);  
        //SBQQContractAndSubscriptionTriggerHelper.updateAccountRecMap(accountsToInsertSet);  
        Test.stopTest();
        // Delete Subscription
        delete subList;   
    }
    
    public static testMethod void testEntitlementSubscriptions(){    

SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;   
        // Create accounts to insert
        Set<Id> accountsToInsertSet = new Set<Id>();
        List<Account> accountsToInsertList = new List<Account>();
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        for(Account accnt: TestCPQUtilityClass.createAccounts(1)){
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.Partner_Type__c ='Agency';
            accnt.Type            = 'Partner';
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
           
        
        Contact con = new Contact(firstname='First Name', lastname='Last Name', AccountId=accountsToInsertList[0].id);
        insert con;
        
        //Primary_Marketo_User_Lookup__c
        // add products with product code
        List<Product2> productToInsertList = new List<Product2>();
        productToInsertList =TestCPQUtilityClass.createCustomProducts(5);
        productToInsertList[0].MA_or_RTP__c = 'MA';   
        productToInsertList[0].Visible_To_Customer__c = true;
        productToInsertList[0].Family='Support';
        productToInsertList[1].Visible_To_Customer__c = true;
        productToInsertList[1].MA_or_RTP__c ='RTP';
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        productToInsertList[2].SBQQ__IncludeInMaintenance__c =true;
        insert productToInsertList;
        
        
        Id stdPricebookId = Test.getStandardPricebookId();
        TestCPQUtilityClass.createStdPricebookEntries(productToInsertList,stdPricebookId);
        
        // Create custom pricebooks
        List<PriceBook2> pricebookList = new List<PriceBook2>();
        pricebookList =TestCPQUtilityClass.createCustomPriceBooks(1);
        insert pricebookList;
        
        // insert products into custom pricebooks
        List<PriceBookEntry> priceBookEntriesList = new List<PriceBookEntry>();
        priceBookEntriesList =TestCPQUtilityClass.createPriceBookEntries(productToInsertList,pricebookList);
        insert priceBookEntriesList;
        
        // Insert data for custom setting - Contract_Roll_Up_With_Product_Code__c       
        List<Contract_Roll_Up_With_Product_Code__c> productCodeList = new List<Contract_Roll_Up_With_Product_Code__c>();
        Contract_Roll_Up_With_Product_Code__c crp1 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test Product 1 ', FieldName__c='Contract_Base_ACV_for_Support__c',   Multiplier__c=3, Need_To_Check_Criteria__c = true, Product_Code__c = 'TESTPRODCODE0, TESTPRODCODE1', Subscription_Field__c = 'Subscription_ACV__c', User_Code__c= 'SUP-BASE-BUS, SUP-BASE-ELT, SUP-BASE-STD-ENT, SUP-BASE-PRM, SUP-BASE-STD-SMB, SUP-BASE-SPK',Include_in_Maintenance__c = true);           
        Contract_Roll_Up_With_Product_Code__c crp2 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test', FieldName__c='Contract_Base_ACV_for_Support__c',  Multiplier__c=3, Need_To_Check_Criteria__c = true, Product_Code__c = 'TESTPRODCODE2,TESTPRODCODE3', Subscription_Field__c = 'Subscription_ACV__c', User_Code__c = null, Include_in_Maintenance__c = true,SUP_Product_code__c = 'tes');          
        Contract_Roll_Up_With_Product_Code__c crp21 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test12', FieldName__c='Contract_Base_ACV_for_Support__c',  Multiplier__c=3, Need_To_Check_Criteria__c = false, Product_Code__c = 'TESTPROD2112', Subscription_Field__c = 'Subscription_ACV__c', User_Code__c = null, Include_in_Maintenance__c = true,SUP_Product_code__c = null);          
        Contract_Roll_Up_With_Product_Code__c crp3 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test 2', FieldName__c='Contract_Base_ACV_for_Support__c',    Multiplier__c=3, Need_To_Check_Criteria__c = false, Product_Code__c = 'TPC4', Subscription_Field__c = 'Subscription_ACV__c');           
        Contract_Roll_Up_With_Product_Code__c crp4 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test 3', FieldName__c='Contract_Base_ACV_for_Support__c',    Multiplier__c=3, Need_To_Check_Criteria__c = false, Product_Code__c = 'TPC4', Subscription_Field__c ='Subscription_MCV__c');            
        Contract_Roll_Up_With_Product_Code__c crp5 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test 5', FieldName__c='Contract_Base_ACV_for_Support__c',    Multiplier__c=3, Need_To_Check_Criteria__c = false, Product_Code__c = 'TPC4', Subscription_Field__c ='Subscription_MCV__c');            
        
        productCodeList.add(crp1);
        productCodeList.add(crp2);
        productCodeList.add(crp3);
        productCodeList.add(crp4);
        productCodeList.add(crp21);
        insert productCodeList;        
        
        // Insert data for custom setting - Entitlement_Product_Code_Criteria__c
        List<Entitlement_Product_Code_Criteria__c> entProdCodeList = new List<Entitlement_Product_Code_Criteria__c>();
        Entitlement_Product_Code_Criteria__c entProdCode = new Entitlement_Product_Code_Criteria__c(Name ='Test Name',Product_Code__c = productToInsertList[0].productcode, Type__c = 'Test',Account_Partner_Type__c='Agency',Order_Type__c='Agency',Record_Type__c = 'Education');
        
        Entitlement_Product_Code_Criteria__c entProdCode1 = new Entitlement_Product_Code_Criteria__c(Name ='Test Name1',Product_Code__c = productToInsertList[1].productcode, Type__c = 'Test',Account_Partner_Type__c=null,Order_Type__c='Agency');
        Entitlement_Product_Code_Criteria__c entProdCode2 = new Entitlement_Product_Code_Criteria__c(Name ='Test Name2',Product_Code__c = productToInsertList[1].productcode, Type__c = 'Test',Account_Partner_Type__c=null,Order_Type__c='Agency',Record_Type__c = 'Education');
        Entitlement_Product_Code_Criteria__c entProdCode3 = new Entitlement_Product_Code_Criteria__c(Name ='Test Name3',Product_Code__c = productToInsertList[1].productcode, Type__c = 'Test',Account_Partner_Type__c=null);

        entProdCodeList.add(entProdCode);
        entProdCodeList.add(entProdCode1);
        entProdCodeList.add(entProdCode2);
        entProdCodeList.add(entProdCode3);
        insert entProdCodeList;
        
        // insert opportunities - for Closed Won Oppty - Contract will be created automatically
       List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities(accountsToInsertList,2);
        for(Opportunity opp : opptyList){
            opp.Rep_Create_ARR__c = 10000;
            opp.Amount = 2000;
            opp.Pricebook2Id = pricebookList[0].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.OwnerId=UserInfo.getUserId();
            opp.Primary_Marketo_User_Lookup__c = con.Id;
       }
        opptyList[1].type ='Renewal';
       opptyList[0].type ='Renewal';
       
        Test.startTest();
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        insert opptyList;
        System.debug('opptyList[0].Accountid...'+opptyList[0].Accountid);
        
        // Create Quote     
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opptyList[0].Id,SBQQ__Account__c= opptyList[0].accountId, SBQQ__StartDate__c = System.Today(),Order_Type__c='Agency');
        insert quote;
        List<OpportunityLineItem> OLIList = TestCPQUtilityClass.createOppLineItems(opptyList,priceBookEntriesList);
        insert OLIList;
        
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        
         // create contracts 
         List<Contract> contractList = new List<Contract>();
         Contract contract1 = new Contract(Name='Test Contract ', AccountId=opptyList[0].AccountId,SBQQ__Opportunity__c = opptyList[0].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true, SBQQ__Quote__c = quote.Id,ContractTerm = 2);         
        
         contractList.add(contract1);
         insert contractList;
        
        opptyList[1].SBQQ__RenewedContract__c = contractList[0].Id;
        update opptyList;
       
        // create subscriptions
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today()-12,SBQQ__ProrateMultiplier__c = 1.1234,SBQQ__Product__c =productToInsertList[0].Id);       
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today()-12,SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[1].Id);
        SBQQ__Subscription__c sub3 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[2].Id);
        SBQQ__Subscription__c sub4 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[3].Id);
        SBQQ__Subscription__c sub5 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[4].Id);
        
        subList.add(sub1);
        subList.add(sub2);
        subList.add(sub3);
        subList.add(sub4);
        subList.add(sub5);
        insert subList;
        
        Test.stopTest();
    }
   
    
    public static testMethod void checkPrevEntTestMtd(){
        
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        // Accounts
        Account accnt = new Account();
        accnt.Name = 'Test Account';
        accnt.BillingCountry = 'United States';
        accnt.BillingStreet = 'Test Street';
        accnt.BillingState ='Test Billing State';
        accnt.BillingPostalCode ='12345';
        accnt.Partner_Type__c ='Agency';
        accnt.Type            = 'Partner';
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
        insert accnt;
        
        // Contact
        Contact con = new Contact(firstname='First Name', lastname='Last Name', AccountId=accnt.id);
        insert con;
        
        // Opportunity
        date toCloseDate = Date.newInstance(2015,12,30);
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(accnt.id, 'Closed Won', 'New Business', toCloseDate);
        
        // Asset
        List<Asset> assetList = new List<Asset>();
        Asset asst = new Asset();
        asst.Name = 'TestAsset';
        asst.Asset_Type__c='Instance';
        asst.installdate = System.today();
        asst.UsageEndDate = System.today().addMonths(1);
        asst.Opportunity__c = opp.id;
        asst.AccountId = accnt.Id;
        asst.status = 'Active';
        asst.ContactId = con.Id;
        assetList.add(asst);
        
        Asset asst2 = new Asset();
        asst2.Name = 'TestAsset1';
        asst2.Asset_Type__c='Subscription';
        asst2.installdate = System.today();
        asst2.UsageEndDate = System.today().addMonths(1);
        asst2.Opportunity__c = opp.id;
        asst2.AccountId = accnt.Id;
        asst2.ContactId = con.Id;
        asst2.status = 'Active';
        assetList.add(asst2);
        
        insert assetList;
        
        // Entitlement
        List<Entitlement> entList = new List<Entitlement>();
        Entitlement prevEnt = new Entitlement();
        prevEnt.Name = 'Previous Ent';
        prevEnt.AccountId = accnt.Id;
        prevEnt.AssetId = asst.Id;
        insert prevEnt;
        //entList.add(prevEnt);
        
        Entitlement currEnt = new Entitlement();
        currEnt.Name = 'Current Ent';
        currEnt.AccountId = accnt.Id;
        currEnt.AssetId = asst2.Id;
        currEnt.Previous_Entitlement__c = prevEnt.Id;
        entList.add(currEnt);
        
        insert entList;
    }
   
  
    
    public static testMethod void testOldAssetOnRenewal(){   
    
SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
 
        // Create accounts to insert
        Set<Id> accountsToInsertSet = new Set<Id>();
        map<id, id> AccToCont = new Map<id,id>();
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
        productToInsertList =TestCPQUtilityClass.createCustomProducts(6);
        productToInsertList[0].MA_or_RTP__c = 'MA';   
        productToInsertList[0].Visible_To_Customer__c = true;
        productToInsertList[0].Family='Support';
        productToInsertList[0].ProductCode= productToInsertList[0].ProductCode;// +'INST';
        productToInsertList[1].Visible_To_Customer__c = true;
        productToInsertList[1].MA_or_RTP__c ='RTP';
        productToInsertList[1].ProductCode = 'RTP Code test' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].ProductCode= 'PROD test ';
        productToInsertList[3].ProductCode= 'RTP test ';
        
        productToInsertList[5].ProductCode= 'SAND test ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        insert productToInsertList;
        system.debug('---productToInsertList[0]---'+productToInsertList[0]);
        // insert products into standard pricebook
        Id stdPricebookId = Test.getStandardPricebookId();
        TestCPQUtilityClass.createStdPricebookEntries(productToInsertList,stdPricebookId);
        
        // Create custom pricebooks
        List<PriceBook2> pricebookList = new List<PriceBook2>();
        pricebookList =TestCPQUtilityClass.createCustomPriceBooks(5);
        insert pricebookList;
        
        // insert products into custom pricebooks
        List<PriceBookEntry> priceBookEntriesList = new List<PriceBookEntry>();
        priceBookEntriesList =TestCPQUtilityClass.createPriceBookEntries(productToInsertList,pricebookList);
        insert priceBookEntriesList;
        
        // Insert data for custom setting - Contract_Roll_Up_With_Product_Code__c       
        List<Contract_Roll_Up_With_Product_Code__c> productCodeList = new List<Contract_Roll_Up_With_Product_Code__c>();
        Contract_Roll_Up_With_Product_Code__c crp1 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test Product 1 ', FieldName__c='Contract_Base_ACV_for_Support__c',   Multiplier__c=3, Need_To_Check_Criteria__c = true, Product_Code__c = 'TESTPRODCODE0, TESTPRODCODE1', Subscription_Field__c = 'Subscription_ACV__c', User_Code__c= 'SUP-BASE-BUS, SUP-BASE-ELT, SUP-BASE-STD-ENT, SUP-BASE-PRM, SUP-BASE-STD-SMB, SUP-BASE-SPK',Include_in_Maintenance__c = true);           
        Contract_Roll_Up_With_Product_Code__c crp2 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test', FieldName__c='Contract_Base_ACV_for_Support__c',  Multiplier__c=3, Need_To_Check_Criteria__c = true, Product_Code__c = 'TESTPRODCODE2,TESTPRODCODE3', Subscription_Field__c = 'Subscription_ACV__c', User_Code__c = null, Include_in_Maintenance__c = true,SUP_Product_code__c = 'tes');          
        Contract_Roll_Up_With_Product_Code__c crp3 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test 2', FieldName__c='Contract_Base_ACV_for_Support__c',    Multiplier__c=3, Need_To_Check_Criteria__c = false, Product_Code__c = 'TPC4', Subscription_Field__c = 'Subscription_ACV__c');           
        Contract_Roll_Up_With_Product_Code__c crp4 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test 3', FieldName__c='Contract_Base_ACV_for_Support__c',    Multiplier__c=3, Need_To_Check_Criteria__c = false, Product_Code__c = 'TPC4', Subscription_Field__c ='Subscription_MCV__c');            
        productCodeList.add(crp1);
        productCodeList.add(crp2);
        productCodeList.add(crp3);
        productCodeList.add(crp4);
        insert productCodeList;        
        
        // Insert data for custom setting - Entitlement_Product_Code_Criteria__c
        List<Entitlement_Product_Code_Criteria__c> entProdCodeList = new List<Entitlement_Product_Code_Criteria__c>();
        Entitlement_Product_Code_Criteria__c entProdCode = new Entitlement_Product_Code_Criteria__c(Name ='Test Name',Product_Code__c = 'TESTPROD2', Type__c = 'Test');
        entProdCodeList.add(entProdCode);
        insert entProdCodeList;
        
        // insert opportunities - for Closed Won Oppty - Contract will be created automatically
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities(accountsToInsertList,2);
        for(Opportunity opp : opptyList){
            opp.Rep_Create_ARR__c = 10000;
            opp.Amount = 2000;
            opp.Pricebook2Id = pricebookList[0].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.OwnerId=UserInfo.getUserId();
            if(AccToCont.containsKey(opp.AccountId)){
                opp.Primary_Marketo_User_Lookup__c = AccToCont.get(opp.AccountId) ;
                opp.Primary_Marketo_User_Email__c = 'test.abc@jade.com' ;
            }
        }
        
      
        if(!opptyList.isEmpty()){
            insert opptyList;
        }
        System.debug('opptyList[0].Accountid...'+opptyList[0].Accountid);
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
 
        // Create Quote     
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opptyList[0].Id,SBQQ__Account__c= opptyList[0].accountId, SBQQ__StartDate__c = System.Today());
        insert quote;
        List<Opportunity> opptyUpdateList = new List<Opportunity>();
       //   opptyList[0].Prior_Opportunity__c     = opptyList[3].id;
        opptyList[1].Prior_Opportunity__c     = opptyList[0].id;
       // opptyList[2].Prior_Opportunity__c     = opptyList[1].id;
        
       
        opptyList[0].type='Renewal';
        opptyList[1].type='Renewal';
         Test.startTest(); 
         SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        opptyUpdateList.add(opptyList[0]);
        opptyUpdateList.add(opptyList[1]);
       // opptyUpdateList.add(opptyList[1]);
       // opptyUpdateList.add(opptyList[2]);
        //opptyUpdateList.add(opptyList[3]);
        update opptyUpdateList;
        
        
        
         // create contracts 
         List<Contract> contractList = new List<Contract>();
         Contract contract1 = new Contract(Name='Test Contract ', AccountId=opptyList[1].AccountId,SBQQ__Opportunity__c = opptyList[1].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true, SBQQ__Quote__c = quote.Id,ContractTerm = 2);         
         Contract contract2 = new Contract(Name='Test Contract ', AccountId=opptyList[1].AccountId,SBQQ__Opportunity__c = opptyList[1].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 2);
         Contract contract3 = new Contract(Name='Test Contract ', AccountId=opptyList[1].AccountId,SBQQ__Opportunity__c = opptyList[1].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 3);
         Contract contract4 = new Contract(Name='Test Contract ', AccountId=opptyList[1].AccountId,SBQQ__Opportunity__c = opptyList[1].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm =4 );
         contractList.add(contract1);
        // contractList.add(contract2);
         //contractList.add(contract3);
         //contractList.add(contract4);
         insert contractList;
        
        List<Asset> assetList = new List<Asset>();
        Asset as1 = new Asset();
        as1.Name = 'Test Asset 1';
        as1.installdate = System.today();
        as1.UsageEndDate = System.today().addMonths(2);
        as1.Opportunity__c = opptyList[0].Id;
        as1.latest_Opportunity__c = opptyList[1].id;
        as1.purpose__c='Production';
        as1.Acct_Prefix__c = 'testAct';
        as1.Munchkin_ID__c ='munkintest';
        as1.POD__c ='testPOD';
        as1.Product2Id= productToInsertList[0].Id;
        as1.AccountId = opptyList[0].AccountId;
        as1.ContactId = ContactToInsert[0].id;
        as1.status = 'Active';
        
        Asset as11 = new Asset();
        as11.Name = 'Test Asset 1';
        as11.installdate = System.today();
        as11.UsageEndDate = System.today().addMonths(4);
        as11.Opportunity__c = opptyList[0].Id;
        as11.latest_Opportunity__c = opptyList[1].id;
        as11.purpose__c='Production';
        as11.Acct_Prefix__c = 'tesa';
        as11.Munchkin_ID__c ='munkin1';
        as11.POD__c ='testPOD';
        as11.Product2Id= productToInsertList[0].Id;
        as11.AccountId = opptyList[0].AccountId;
        as11.ContactId = ContactToInsert[0].id;
        as11.status = 'Active';
        
         Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = opptyList[1].Id;
        as2.Product2Id = productToInsertList[2].Id;
        as2.purpose__c='Production';
        as2.AccountId = opptyList[1].accountId;
        as2.ContactId = ContactToInsert[0].id;
        as2.status = 'Active';
        as2.Contract__c = contractList[0].Id;
        
        //To test RTP to RTP scenario for asset
        Asset astRTP = new Asset();
        astRTP.Name = 'Test Asset 1';
        astRTP.installdate = System.today();
        astRTP.UsageEndDate = System.today().addMonths(2);
        astRTP.Opportunity__c = opptyList[0].Id;
        astRTP.latest_Opportunity__c = opptyList[1].id;
        astRTP.purpose__c='Production';
        astRTP.Acct_Prefix__c = 'testRTP';
        astRTP.Product2Id= productToInsertList[0].Id;
        astRTP.AccountId = accountsToInsertList[0].Id;
        astRTP.ContactId = ContactToInsert[0].id;
        astRTP.status = 'Active';
        astRTP.Contract__c = contractList[0].Id;
        astRTP.Subscription_Type__c='Real Time Personalization';
        
        Asset astRTP11 = new Asset();
        astRTP11.Name = 'Test Asset 1';
        astRTP11.installdate = System.today();
        astRTP11.UsageEndDate = System.today().addMonths(4);
        astRTP11.Opportunity__c = opptyList[0].Id;
        astRTP11.latest_Opportunity__c = opptyList[1].id;
        astRTP11.purpose__c='Production';
        astRTP11.Acct_Prefix__c = 'testRTP11';
        astRTP11.Product2Id= productToInsertList[0].Id;
        astRTP11.AccountId = accountsToInsertList[0].Id;
        astRTP11.ContactId = ContactToInsert[0].id;
        astRTP11.status = 'Active';
        astRTP11.Contract__c = contractList[0].Id;
        astRTP11.Subscription_Type__c='Real Time Personalization';
        
        Asset astRTP1 = new Asset();
        astRTP1.Name = 'Test Asset 1';
        astRTP1.installdate = System.today();
        astRTP1.UsageEndDate = System.today().addMonths(2);
        astRTP1.Opportunity__c = opptyList[1].Id;
        astRTP1.purpose__c='Production';
        astRTP1.Product2Id= productToInsertList[3].Id;
        astRTP1.AccountId = accountsToInsertList[0].Id;
        astRTP1.ContactId = ContactToInsert[0].id;
        astRTP1.status = 'Active';
     
        Asset astSand = new Asset();
        astSand.Name = 'Test Asset 1';
        astSand.installdate = System.today();
        astSand.UsageEndDate = System.today().addMonths(2);
        astSand.Opportunity__c = opptyList[0].Id;
        astSand.latest_Opportunity__c = opptyList[1].id;
        astSand.Acct_Prefix__c = 'testSB1';
        astSand.Munchkin_ID__c ='munkinSB1';
        astSand.POD__c ='testPOD';
        astSand.Product2Id= productToInsertList[4].Id;
        astSand.AccountId = accountsToInsertList[0].Id;
        astSand.ContactId = ContactToInsert[0].id;
        astSand.status = 'Active';
        astSand.Contract__c = contractList[0].Id;
        astSand.Purpose__c ='Sandbox';
        
        Asset astSand11 = new Asset();
        astSand11.Name = 'Test Asset 1';
        astSand11.installdate = System.today();
        astSand11.UsageEndDate = System.today().addMonths(4);
        astSand11.Opportunity__c = opptyList[0].Id;
        astSand11.latest_Opportunity__c = opptyList[1].id;
        astSand11.Acct_Prefix__c = 'testSB11';
        astSand11.Munchkin_ID__c ='munkinSB11';
        astSand11.POD__c ='testPOD';
        astSand11.Product2Id= productToInsertList[4].Id;
        astSand11.AccountId = accountsToInsertList[0].Id;
        astSand11.ContactId = ContactToInsert[0].id;
        astSand11.status = 'Active';
        astSand11.Contract__c = contractList[0].Id;
        astSand11.Purpose__c ='Sandbox';
        
        Asset astSand1 = new Asset();
        astSand1.Name = 'Test Asset 1';
        astSand1.installdate = System.today();
        astSand1.UsageEndDate = System.today().addMonths(2);
        astSand1.Opportunity__c = opptyList[1].Id;
        astSand1.Product2Id= productToInsertList[5].Id;
        astSand1.AccountId = accountsToInsertList[0].Id;
        astSand1.ContactId = ContactToInsert[0].id;
        astSand1.status = 'Active';
        astSand1.Contract__c = contractList[0].Id;
        astSand1.Purpose__c ='Sandbox';
        
        assetList.add(as1);
        assetList.add(as11);
        assetList.add(as2);
        assetList.add(astRTP);
        assetList.add(astRTP11);
        assetList.add(astRTP1);
        assetList.add(astSand);
       // assetList.add(astSand11);
        assetList.add(astSand1);
        
        list<Product2> Product2List = [SELECT id,name,ProductCode FROM  Product2 WHERE Id IN :productToInsertList]; 
         system.debug('Product2List======='+Product2List);
        if(!assetList.isEmpty()){
            insert assetList;
        } 
         list<asset> assUpdateAssetList  = new  list<asset> ();
        assetList[0].Contract__c = null;
        assetList[1].Contract__c = null;
        assetList[3].Contract__c = null;
        assetList[4].Contract__c = null;
        assetList[6].Contract__c = null;
       // assetList[7].Contract__c = null;
        
        assUpdateAssetList.add( assetList[0]);
        assUpdateAssetList.add( assetList[1]);
        assUpdateAssetList.add( assetList[3]);
        assUpdateAssetList.add( assetList[4]);
        assUpdateAssetList.add( assetList[6]);
       // assUpdateAssetList.add( assetList[7]);
       
        update  assUpdateAssetList;
       list<asset> assBunAssetList = [SELECT id,Product2id,name,Product_Code__c,Associated_Bundle__c FROM  Asset WHERE Id IN :assetList and Acct_Prefix__c!=null AND Purpose__c='Production'];  
       system.debug('assBunAssetList======='+assBunAssetList);
       // system.assertEquals(assBunAssetList.size(),2);
         
        
        contractList[0].Primary_Asset__c = assetList[0].Id;
       // contractList[1].Primary_Asset__c = assetList[1].Id;
        update contractList;
        
        System.debug('Contracts on Asset ===> ' + [Select id, Primary_Asset__c from Contract where id =: contractList[0].Id]);     
        
        // create subscriptions
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234,SBQQ__Product__c =productToInsertList[0].Id);       
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[1].Id);
        SBQQ__Subscription__c sub3 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[2].Id);
        SBQQ__Subscription__c sub4 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[3].Id);
        SBQQ__Subscription__c sub5 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[4].Id);
        SBQQ__Subscription__c sub6 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[3].Id);

        subList.add(sub1);
        subList.add(sub2);
        subList.add(sub3);
        subList.add(sub4);
        subList.add(sub5);
        subList.add(sub6);
        insert subList;
        
        
        Test.stopTest();
        
    
    }//End of Testmethod
    
      public static testMethod void testSubscriptionEntCreation(){
SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;         
        // Create accounts to insert
        Set<Id> accountsToInsertSet = new Set<Id>();
        map<id, id> AccToCont = new Map<id,id>();
        List<Account> accountsToInsertList = new List<Account>();
          integer accNumber= 0;
        for(Account accnt: TestCPQUtilityClass.createAccounts(2)){
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='1234'+accNumber;
            accnt.name = accnt.name+''+accNumber;
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
            accnt.IntacctID__c = null;
            //accnt.RecordTypeId = '01250000000ULb7AAG';
            accountsToInsertList.add(accnt);
            
            accNumber = accNumber+2;
        }
            insert accountsToInsertList;
            for(Account acc : accountsToInsertList){
                accountsToInsertSet.add(acc.Id);
            }
           
        list<Contact> ContactToInsert = new list<Contact>();
        ContactToInsert = TestCPQUtilityClass.createContacts(accountsToInsertList,2);
        for(Contact con:ContactToInsert ){
                con.pse__Salesforce_User__c  =null;
         }
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
        productToInsertList[1].ProductCode = 'TESTClassPRODCODE' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        productToInsertList[3].ProductCode ='SUPTPC';
        productToInsertList[4].ProductCode ='SUPTPC41'; 
        productToInsertList[2].Asset_Type__c = 'Support Product';
        insert productToInsertList;
        system.debug('---productToInsertList[0]---'+productToInsertList[0]);
        // insert products into standard pricebook
        Id stdPricebookId = Test.getStandardPricebookId();
        TestCPQUtilityClass.createStdPricebookEntries(productToInsertList,stdPricebookId);
        
        // Create custom pricebooks
        List<PriceBook2> pricebookList = new List<PriceBook2>();
        pricebookList =TestCPQUtilityClass.createCustomPriceBooks(5);
        insert pricebookList;
        
        // insert products into custom pricebooks
        List<PriceBookEntry> priceBookEntriesList = new List<PriceBookEntry>();
        priceBookEntriesList =TestCPQUtilityClass.createPriceBookEntries(productToInsertList,pricebookList);
        insert priceBookEntriesList;
        
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
        
        // insert opportunities - for Closed Won Oppty - Contract will be created automatically
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities(accountsToInsertList,2);
        for(Opportunity opp : opptyList){
            opp.Rep_Create_ARR__c = 10000;
            opp.Amount = 2000;
            opp.Pricebook2Id = pricebookList[0].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.OwnerId=UserInfo.getUserId();
            if(AccToCont.containsKey(opp.AccountId)){
                opp.Primary_Marketo_User_Lookup__c = AccToCont.get(opp.AccountId) ;
                opp.Primary_Marketo_User_Email__c = 'test.abc@jade.com' ;
            }
        }
        
        opptyList[2].type = 'Renewal';
        opptyList[3].type = 'Upsell';
        opptyList[0].type = 'Upsell';
        opptyList[0].stagename = 'Closed Won';
        //Test.startTest(); 
         Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
    Trigger_Opportunity_Helper.isBeforeUpdateEvent = True;
        if(!opptyList.isEmpty()){
            insert opptyList;
        }
        System.debug('opptyList[0].Accountid...'+opptyList[0].Accountid);
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        // Create Quote     
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opptyList[0].Id,SBQQ__Account__c= opptyList[0].accountId, SBQQ__StartDate__c = System.Today());
        insert quote;
        
         List<SBQQ__QuoteLine__c>  quoteLineList = TestCPQUtilityClass.createQuoteLines(new list<SBQQ__Quote__c>{quote},1,productToInsertList);
         insert quoteLineList;
       
        
         // create contracts 
         List<Contract> contractList = new List<Contract>();
         Contract contract1 = new Contract(Name='Test Contract ', AccountId=opptyList[0].AccountId,SBQQ__Opportunity__c = opptyList[0].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true, SBQQ__Quote__c = quote.Id,ContractTerm = 2);         
         Contract contract2 = new Contract(Name='Test Contract ', AccountId=opptyList[0].AccountId,SBQQ__Opportunity__c = opptyList[1].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 2);
         Contract contract3 = new Contract(Name='Test Contract ', AccountId=opptyList[2].AccountId,SBQQ__Opportunity__c = opptyList[2].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 3);
         Contract contract4 = new Contract(Name='Test Contract ', AccountId=opptyList[2].AccountId,SBQQ__Opportunity__c = opptyList[3].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm =4 );
         contractList.add(contract1);
         contractList.add(contract2);
         contractList.add(contract3);
         contractList.add(contract4);
         insert contractList;
        
        opptyList[2].SBQQ__RenewedContract__c = contractList[0].Id;
        update opptyList;
        Test.startTest(); 
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
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
        as1.Contract__c = contractList[0].Id;
       
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = opptyList[0].Id;
        as1.Product2Id = productToInsertList[2].Id;
        as2.AccountId = accountsToInsertList[0].Id;
        as2.ContactId = ContactToInsert[0].id;
        as2.status = 'Active';
        as2.Contract__c = contractList[0].Id;
        assetList.add(as1);
        assetList.add(as2);
        list<Product2> Product2List = [SELECT id,name,ProductCode FROM  Product2 WHERE Id IN :productToInsertList]; 
         system.debug('Product2List======='+Product2List);
        if(!assetList.isEmpty()){
            insert assetList;
        } 
       list<asset> assBunAssetList = [SELECT id,Product2id,name,Product_Code__c,Associated_Bundle__c FROM  Asset WHERE Id IN :assetList];  
       system.debug('assBunAssetList======='+assBunAssetList);
          
         
        
        contractList[0].Primary_Asset__c = assetList[0].Id;
        contractList[1].Primary_Asset__c = assetList[1].Id;
        update contractList;
        
        System.debug('Contracts on Asset ===> ' + [Select id, Primary_Asset__c from Contract where id =: contractList[0].Id]);     
        
        // create subscriptions
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        ////SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234,SBQQ__Product__c =productToInsertList[0].Id);       
       // SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[1].Id);
        //SBQQ__Subscription__c sub3 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[1].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[2].Id);
        SBQQ__Subscription__c sub4 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[1].Id,SBQQ__Account__c=contractList[1].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[3].Id);
        SBQQ__Subscription__c sub5 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[4].Id,SBQQ__QuoteLine__c=quoteLineList[0].id);
        
        //subList.add(sub1);
        //subList.add(sub2);
        //subList.add(sub3);
        subList.add(sub4);
        subList.add(sub5);
        insert subList;
        List<Entitlement> newEntList= TestCPQUtilityClass.createEntitlements(subList,1);
         for(Entitlement newEnt : newEntList){
             newEnt.Contract__c = contractList[0].Id;
         }
         // newEntList[1].Contract__c = contractList[1].Id;
         insert newEntList;
         list<SBQQ__Subscription__c> InsertsubList =    new list<SBQQ__Subscription__c>();
       SBQQ__Subscription__c sub6 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[1].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[2].Id);
       SBQQ__Subscription__c sub7 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[1].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[3].Id);
       InsertsubList.add(sub6);
       InsertsubList.add(sub7);
       insert InsertsubList;
        // UPDATE SUBSCRIPTIONS 
        subList[0].SBQQ__Contract__c = contractList[1].Id;
        subList[0].SBQQ__Quantity__c = 4;
        
        // remove contract from subscriptoin, Change terminated date
     //   subList[1].SBQQ__Contract__c = null;
      //  subList[1].SBQQ__TerminatedDate__c=System.today().addMonths(5);
        update subList;   
        
      //  SBQQContractAndSubscriptionTriggerHelper.updateAccountRec(accountsToInsertSet,subList);  
        //SBQQContractAndSubscriptionTriggerHelper.updateAccountRecMap(accountsToInsertSet);  
        Test.stopTest();
        // Delete Subscription
        delete subList;   
    }//End of method testSubscriptionEntCreation
    
    public static testMethod void testSubscriptionRollUp(){    

SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
 
        // Create accounts to insert
        Set<Id> accountsToInsertSet = new Set<Id>();
        map<id, id> AccToCont = new Map<id,id>();
        List<Account> accountsToInsertList = new List<Account>();

        for(Account accnt: TestCPQUtilityClass.createAccounts(2)){
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
        ContactToInsert = TestCPQUtilityClass.createContacts(accountsToInsertList,2);
         for(Contact con:ContactToInsert ){
                con.pse__Salesforce_User__c  =null;
         }
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
        productToInsertList[1].ProductCode = 'TESTClassPRODCODE' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        productToInsertList[3].ProductCode ='SUPTPC';
        productToInsertList[4].ProductCode ='SUPTPC41'; 
        productToInsertList[2].Asset_Type__c = 'Support Product';
        insert productToInsertList;
        system.debug('---productToInsertList[0]---'+productToInsertList[0]);
        // insert products into standard pricebook
        Id stdPricebookId = Test.getStandardPricebookId();
        TestCPQUtilityClass.createStdPricebookEntries(productToInsertList,stdPricebookId);
        
        // Create custom pricebooks
        List<PriceBook2> pricebookList = new List<PriceBook2>();
        pricebookList =TestCPQUtilityClass.createCustomPriceBooks(5);
        insert pricebookList;
        
        // insert products into custom pricebooks
        List<PriceBookEntry> priceBookEntriesList = new List<PriceBookEntry>();
        priceBookEntriesList =TestCPQUtilityClass.createPriceBookEntries(productToInsertList,pricebookList);
        insert priceBookEntriesList;
        
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
        
        // insert opportunities - for Closed Won Oppty - Contract will be created automatically
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities(accountsToInsertList,2);
        for(Opportunity opp : opptyList){
            opp.Rep_Create_ARR__c = 10000;
            opp.Amount = 2000;
            opp.Pricebook2Id = pricebookList[0].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.OwnerId=UserInfo.getUserId();
            if(AccToCont.containsKey(opp.AccountId)){
                opp.Primary_Marketo_User_Lookup__c = AccToCont.get(opp.AccountId) ;
                opp.Primary_Marketo_User_Email__c = 'test.abc@jade.com' ;
            }
        }
        
        opptyList[2].type = 'Renewal';
        opptyList[3].type = 'Upsell';
        opptyList[0].type = 'Upsell';
        opptyList[0].stagename = 'Closed Won';
       // Test.startTest(); 
        Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
    Trigger_Opportunity_Helper.isBeforeUpdateEvent = True;
        if(!opptyList.isEmpty()){
            insert opptyList;
        }
        System.debug('opptyList[0].Accountid...'+opptyList[0].Accountid);
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        // Create Quote     
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opptyList[0].Id,SBQQ__Account__c= opptyList[0].accountId, SBQQ__StartDate__c = System.Today());
        insert quote;
        
         List<SBQQ__QuoteLine__c>  quoteLineList = TestCPQUtilityClass.createQuoteLines(new list<SBQQ__Quote__c>{quote},1,productToInsertList);
         insert quoteLineList;
         
         
         // create contracts 
         List<Contract> contractList = new List<Contract>();
         Contract contract1 = new Contract(Name='Test Contract ', AccountId=opptyList[0].AccountId,SBQQ__Opportunity__c = opptyList[0].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true, SBQQ__Quote__c = quote.Id,ContractTerm = 2);         
         Contract contract2 = new Contract(Name='Test Contract ', AccountId=opptyList[0].AccountId,SBQQ__Opportunity__c = opptyList[1].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 2);
         Contract contract3 = new Contract(Name='Test Contract ', AccountId=opptyList[2].AccountId,SBQQ__Opportunity__c = opptyList[2].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 3);
         Contract contract4 = new Contract(Name='Test Contract ', AccountId=opptyList[2].AccountId,SBQQ__Opportunity__c = opptyList[3].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm =4 );
         contractList.add(contract1);
         contractList.add(contract2);
         contractList.add(contract3);
         contractList.add(contract4);
         insert contractList;
        
        opptyList[2].SBQQ__RenewedContract__c = contractList[0].Id;
        update opptyList;
        Test.startTest(); 
            SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
     SalesTriggersUtility.AssetTriggerVA  = true;
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
        as1.Contract__c = contractList[0].Id;
        
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = opptyList[0].Id;
        as1.Product2Id = productToInsertList[2].Id;
        as2.AccountId = accountsToInsertList[0].Id;
        as2.ContactId = ContactToInsert[0].id;
        as2.status = 'Active';
        as2.Contract__c = contractList[0].Id;
        assetList.add(as1);
        assetList.add(as2);
        list<Product2> Product2List = [SELECT id,name,ProductCode FROM  Product2 WHERE Id IN :productToInsertList]; 
         system.debug('Product2List======='+Product2List);
        if(!assetList.isEmpty()){
            insert assetList;
        } 
       list<asset> assBunAssetList = [SELECT id,Product2id,name,Product_Code__c,Associated_Bundle__c FROM  Asset WHERE Id IN :assetList];  
       system.debug('assBunAssetList======='+assBunAssetList);
          
         
        
        contractList[0].Primary_Asset__c = assetList[0].Id;
        contractList[1].Primary_Asset__c = assetList[1].Id;
        update contractList;
        
        System.debug('Contracts on Asset ===> ' + [Select id, Primary_Asset__c from Contract where id =: contractList[0].Id]);     
        
        // create subscriptions
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        ////SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234,SBQQ__Product__c =productToInsertList[0].Id);       
       // SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[1].Id);
        //SBQQ__Subscription__c sub3 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[1].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[2].Id);
        SBQQ__Subscription__c sub4 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[1].Id,SBQQ__Account__c=contractList[1].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[3].Id);
        SBQQ__Subscription__c sub5 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[4].Id,SBQQ__QuoteLine__c=quoteLineList[0].id);
        
        //subList.add(sub1);
        //subList.add(sub2);
        //subList.add(sub3);
        subList.add(sub4);
        subList.add(sub5);
        insert subList;
        //Test.stopTest();
        List<Entitlement> newEntList= TestCPQUtilityClass.createEntitlements(subList,1);
         for(Entitlement newEnt : newEntList){
             newEnt.Contract__c = contractList[0].Id;
         }
          newEntList[1].Contract__c = contractList[1].Id;
         insert newEntList;
         list<SBQQ__Subscription__c> InsertsubList =    new list<SBQQ__Subscription__c>();
       SBQQ__Subscription__c sub6 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[1].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[2].Id);
       SBQQ__Subscription__c sub7 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[1].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[3].Id);
       InsertsubList.add(sub6);
       InsertsubList.add(sub7);
       insert InsertsubList;
       
         Test.stopTest();
       
    }//End of method testSubscriptionEntCreation
    
    public static testMethod void testRubikQuoteContract(){    
SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
 
        // Create accounts to insert
        Set<Id> accountsToInsertSet = new Set<Id>();
        map<id, id> AccToCont = new Map<id,id>();
        List<Account> accountsToInsertList = new List<Account>();

        for(Account accnt: TestCPQUtilityClass.createAccounts(2)){
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
        ContactToInsert = TestCPQUtilityClass.createContacts(accountsToInsertList,2);
        for(Contact con:ContactToInsert ){
        
            con.pse__Salesforce_User__c  =null;
        }
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
        productToInsertList[1].ProductCode = 'TESTClassPRODCODE' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        productToInsertList[3].ProductCode ='SUPTPC';
        productToInsertList[4].ProductCode ='SUPTPC41'; 
        productToInsertList[2].Asset_Type__c = 'Support Product';
        insert productToInsertList;
        system.debug('---productToInsertList[0]---'+productToInsertList[0]);
        // insert products into standard pricebook
        Id stdPricebookId = Test.getStandardPricebookId();
        TestCPQUtilityClass.createStdPricebookEntries(productToInsertList,stdPricebookId);
        
        // Create custom pricebooks
        List<PriceBook2> pricebookList = new List<PriceBook2>();
        pricebookList =TestCPQUtilityClass.createCustomPriceBooks(5);
        insert pricebookList;
        
        // insert products into custom pricebooks
        List<PriceBookEntry> priceBookEntriesList = new List<PriceBookEntry>();
        priceBookEntriesList =TestCPQUtilityClass.createPriceBookEntries(productToInsertList,pricebookList);
        insert priceBookEntriesList;
        
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
        
        // insert opportunities - for Closed Won Oppty - Contract will be created automatically
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities(accountsToInsertList,2);
        for(Opportunity opp : opptyList){
            opp.Rep_Create_ARR__c = 10000;
            opp.Amount = 2000;
            opp.Pricebook2Id = pricebookList[0].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.OwnerId=UserInfo.getUserId();
            if(AccToCont.containsKey(opp.AccountId)){
                opp.Primary_Marketo_User_Lookup__c = AccToCont.get(opp.AccountId) ;
                opp.Primary_Marketo_User_Email__c = 'test.abc@jade.com' ;
            }
        }
        
        opptyList[2].type = 'Renewal';
        opptyList[3].type = 'Upsell';
        opptyList[0].type = 'Upsell';
        opptyList[0].stagename = 'Closed Won';
        //Test.startTest(); 
        Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
    Trigger_Opportunity_Helper.isBeforeUpdateEvent = True;
        if(!opptyList.isEmpty()){
            insert opptyList;
        }
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        System.debug('opptyList[0].Accountid...'+opptyList[0].Accountid);
        List<SBQQ__Quote__c> newquotList=  TestCPQUtilityClass.createSimpleQuote(opptyList,1);
        for(SBQQ__Quote__c SBQuote :newquotList){
            SBQuote.Rubiks_Quote__c = true;
        }
        insert newquotList;
        Test.startTest(); 
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
         List<SBQQ__QuoteLine__c>  quoteLineList = TestCPQUtilityClass.createQuoteLines(newquotList,1,productToInsertList);
         insert quoteLineList;
         
        
        
         // create contracts 
         List<Contract> contractList = new List<Contract>();
         Contract contract1 = new Contract(Name='Test Contract ', AccountId=opptyList[0].AccountId,SBQQ__Opportunity__c = opptyList[0].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true, SBQQ__Quote__c = newquotList[0].Id,ContractTerm = 2);         
         Contract contract2 = new Contract(Name='Test Contract ', AccountId=opptyList[0].AccountId,SBQQ__Opportunity__c = opptyList[0].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 2);
         Contract contract3 = new Contract(Name='Test Contract ', AccountId=opptyList[2].AccountId,SBQQ__Opportunity__c = opptyList[2].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 3);
         Contract contract4 = new Contract(Name='Test Contract ', AccountId=opptyList[2].AccountId,SBQQ__Opportunity__c = opptyList[3].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm =4 );
         contractList.add(contract1);
          contractList.add(contract3);
        // contractList.add(contract4);
         insert contractList;
        
        opptyList[2].SBQQ__RenewedContract__c = contractList[0].Id;
        update opptyList;
      
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
        as1.Contract__c = contractList[0].Id;
        
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = opptyList[0].Id;
        as1.Product2Id = productToInsertList[2].Id;
        as2.AccountId = accountsToInsertList[0].Id;
        as2.ContactId = ContactToInsert[0].id;
        as2.status = 'Active';
        as2.Contract__c = contractList[0].Id;
        assetList.add(as1);
        assetList.add(as2);
        //18 Nov Test.startTest(); 
        list<Product2> Product2List = [SELECT id,name,ProductCode FROM  Product2 WHERE Id IN :productToInsertList]; 
         system.debug('Product2List======='+Product2List);
        if(!assetList.isEmpty()){
            insert assetList;
        } 
       list<asset> assBunAssetList = [SELECT id,Product2id,name,Product_Code__c,Associated_Bundle__c FROM  Asset WHERE Id IN :assetList];  
       system.debug('assBunAssetList======='+assBunAssetList);
          
         
        
        contractList[0].Primary_Asset__c = assetList[0].Id;
        contractList[1].Primary_Asset__c = assetList[1].Id;
        update contractList;
         
        System.debug('Contracts on Asset ===> ' + [Select id, Primary_Asset__c from Contract where id =: contractList[0].Id]);     
        
        // create subscriptions
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        ////SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234,SBQQ__Product__c =productToInsertList[0].Id);       
       // SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[1].Id);
        //SBQQ__Subscription__c sub3 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[1].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[2].Id);
        SBQQ__Subscription__c sub4 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[1].Id,SBQQ__Account__c=contractList[1].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[3].Id);
        SBQQ__Subscription__c sub5 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[4].Id,SBQQ__QuoteLine__c=quoteLineList[0].id);
        
        //subList.add(sub1);
        //subList.add(sub2);
        //subList.add(sub3);
        subList.add(sub4);
        subList.add(sub5);
        insert subList;
        //Test.stopTest();
        List<Entitlement> newEntList= TestCPQUtilityClass.createEntitlements(subList,1);
         for(Entitlement newEnt : newEntList){
             newEnt.Contract__c = contractList[0].Id;
         }
          newEntList[1].Contract__c = contractList[1].Id;
         insert newEntList;
         list<SBQQ__Subscription__c> InsertsubList =    new list<SBQQ__Subscription__c>();
       SBQQ__Subscription__c sub6 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[1].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[2].Id);
       SBQQ__Subscription__c sub7 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[1].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[3].Id);
       InsertsubList.add(sub6);
       InsertsubList.add(sub7);
         Test.stopTest();
       insert InsertsubList;
      
        
       
    }//End of method testRubikQuoteContract
    
    
       public static testMethod void testUpsellEnt(){    
SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;      
        // Create accounts to insert
        Set<Id> accountsToInsertSet = new Set<Id>();
        map<id, id> AccToCont = new Map<id,id>();
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
        productToInsertList[1].ProductCode = 'TESTClassPRODCODEBNDL' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        productToInsertList[3].ProductCode ='SUPTPCBNDL';
        productToInsertList[4].ProductCode ='SUPTPC41BNDL'; 
        productToInsertList[2].Asset_Type__c = 'Support Product';
        insert productToInsertList;
        system.debug('---productToInsertList[0]---'+productToInsertList[0]);
        // insert products into standard pricebook
        Id stdPricebookId = Test.getStandardPricebookId();
        TestCPQUtilityClass.createStdPricebookEntries(productToInsertList,stdPricebookId);
        
        // Create custom pricebooks
        List<PriceBook2> pricebookList = new List<PriceBook2>();
        pricebookList =TestCPQUtilityClass.createCustomPriceBooks(5);
        insert pricebookList;
        
        // insert products into custom pricebooks
        List<PriceBookEntry> priceBookEntriesList = new List<PriceBookEntry>();
        priceBookEntriesList =TestCPQUtilityClass.createPriceBookEntries(productToInsertList,pricebookList);
        insert priceBookEntriesList;
        
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
        
        // insert opportunities - for Closed Won Oppty - Contract will be created automatically
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities(accountsToInsertList,2);
        for(Opportunity opp : opptyList){
            opp.Rep_Create_ARR__c = 10000;
            opp.Amount = 2000;
            opp.Pricebook2Id = pricebookList[0].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.OwnerId=UserInfo.getUserId();
            if(AccToCont.containsKey(opp.AccountId)){
                opp.Primary_Marketo_User_Lookup__c = AccToCont.get(opp.AccountId) ;
                opp.Primary_Marketo_User_Email__c = 'test.abc@jade.com' ;
            }
        }
        
        
        opptyList[1].type = Label.OPPORTUNITY_TYPE_UPSELL;
        opptyList[0].stagename = 'Closed Won';
        //Test.startTest(); 
        if(!opptyList.isEmpty()){
            insert opptyList;
        }
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        System.debug('opptyList[0].Accountid...'+opptyList[0].Accountid);
        List<SBQQ__Quote__c> newquotList=  TestCPQUtilityClass.createSimpleQuote(opptyList,1);
        for(SBQQ__Quote__c SBQuote :newquotList){
            SBQuote.Rubiks_Quote__c = true;
        }
        newquotList[1].SBQQ__Type__c = 'Amendment';
        insert newquotList;
        Test.startTest(); 
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
         List<SBQQ__QuoteLine__c>  quoteLineList = TestCPQUtilityClass.createQuoteLines(newquotList,2,productToInsertList);
         insert quoteLineList;
         
         
                
         // create contracts 
         List<Contract> contractList = new List<Contract>();
         Contract contract1 = new Contract(Name='Test Contract ', AccountId=opptyList[0].AccountId,SBQQ__Opportunity__c = opptyList[0].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true, SBQQ__Quote__c = newquotList[0].Id,ContractTerm = 12);         
         contractList.add(contract1);
         insert contractList;
        
    list<SBQQ__QuoteLine__c> QLIList =    [SELECT id,SBQQ__Product__c FROM SBQQ__QuoteLine__c   WHERE SBQQ__Quote__r.SBQQ__Opportunity2__r.type =:Label.OPPORTUNITY_TYPE_UPSELL AND SBQQ__Product__c!=null];

      
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
        as1.SBQQ__QuoteLine__c =QLIList[1].id;

        as1.Contract__c = contractList[0].Id;
        
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = opptyList[0].Id;
        as1.Product2Id = productToInsertList[2].Id;
        as2.AccountId = accountsToInsertList[0].Id;
        as2.ContactId = ContactToInsert[0].id;
        as2.status = 'Active';
        as2.SBQQ__QuoteLine__c =QLIList[0].id;
        as2.Acct_Prefix__c = QLIList[0].id;
        as2.Contract__c = contractList[0].Id;
        assetList.add(as1);
        assetList.add(as2);
        //18 Nov Test.startTest(); 
        list<Product2> Product2List = [SELECT id,name,ProductCode FROM  Product2 WHERE Id IN :productToInsertList]; 
         system.debug('Product2List======='+Product2List);
        if(!assetList.isEmpty()){
            insert assetList;
        } 
       list<asset> assBunAssetList = [SELECT id,Product2id,name,Product_Code__c,Associated_Bundle__c FROM  Asset WHERE Id IN :assetList];  
       system.debug('assBunAssetList======='+assBunAssetList);
          
         
        
        contractList[0].Primary_Asset__c = assetList[0].Id;
        update contractList;
        
        // create subscriptions
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[3].Id,SBQQ__QuoteLine__c=quoteLineList[0].id);
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[4].Id,SBQQ__QuoteLine__c=quoteLineList[1].id);
        
        
        subList.add(sub1);
        subList.add(sub2);
       insert subList;
       
         List<Entitlement> newEntList= TestCPQUtilityClass.createEntitlements(subList,1);
         for(Entitlement newEnt : newEntList){
             newEnt.Contract__c = contractList[0].Id;
         }
          newEntList[0].Contract__c = contractList[0].Id;
         insert newEntList;
         
          list<SBQQ__Subscription__c> InsertsubList =    new list<SBQQ__Subscription__c>();
           SBQQ__Subscription__c sub6 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =QLIList[0].SBQQ__Product__c,SBQQ__QuoteLine__c=QLIList[0].id);
           SBQQ__Subscription__c sub7 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =QLIList[1].SBQQ__Product__c,SBQQ__QuoteLine__c=QLIList[1].id);
           InsertsubList.add(sub6);
          InsertsubList.add(sub7);
         Test.stopTest();
       insert InsertsubList;
       
    /* list <SBQQ__Subscription__c> SubAfterDMLList=[SELECT id,SBQQ__StartDate__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Rubiks_Quote__c,SBQQ__Product__r.productcode,SBQQ__Contract__c,SBQQ__Contract__r.SBQQ__Opportunity__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Opportunity_Type__c from SBQQ__Subscription__c WHERE id IN :InsertsubList AND SBQQ__QuoteLine__r.SBQQ__Quote__r.Opportunity_Type__c=:Label.OPPORTUNITY_TYPE_UPSELL];
     
     System.assertEquals(1, SubAfterDMLList.size());*/

        
       
    }//End of method testRubikQuoteContract
    
    
    public static  testMethod  void AssetConversiontest(){
    SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        // Create accounts to insert
        Set<Id> accountsToInsertSet = new Set<Id>();
        map<id, id> AccToCont = new Map<id,id>();
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
        productToInsertList[0].ProductCode ='PROD-APPS-INST RTP'; 

        productToInsertList[1].Visible_To_Customer__c = true;
        productToInsertList[1].MA_or_RTP__c ='RTP';
        productToInsertList[1].ProductCode = 'PROD-APPS-INST' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        productToInsertList[3].ProductCode ='SUPTPCBNDL';
        productToInsertList[2].ProductCode ='PROD-APPS-INST1'; 
        productToInsertList[2].Asset_Type__c = 'Support Product';
        insert productToInsertList;
        system.debug('---productToInsertList[0]---'+productToInsertList[0]);
        // insert products into standard pricebook
        Id stdPricebookId = Test.getStandardPricebookId();
        TestCPQUtilityClass.createStdPricebookEntries(productToInsertList,stdPricebookId);
        
        // Create custom pricebooks
        List<PriceBook2> pricebookList = new List<PriceBook2>();
        pricebookList =TestCPQUtilityClass.createCustomPriceBooks(5);
        insert pricebookList;
        
        // insert products into custom pricebooks
        List<PriceBookEntry> priceBookEntriesList = new List<PriceBookEntry>();
        priceBookEntriesList =TestCPQUtilityClass.createPriceBookEntries(productToInsertList,pricebookList);
        insert priceBookEntriesList;
        
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
        
        // insert opportunities - for Closed Won Oppty - Contract will be created automatically
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities(accountsToInsertList,2);
        for(Opportunity opp : opptyList){
            opp.Rep_Create_ARR__c = 10000;
            opp.Amount = 2000;
            opp.Pricebook2Id = pricebookList[0].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.OwnerId=UserInfo.getUserId();
            if(AccToCont.containsKey(opp.AccountId)){
                opp.Primary_Marketo_User_Lookup__c = AccToCont.get(opp.AccountId) ;
                opp.Primary_Marketo_User_Email__c = 'test.abc@jade.com' ;
            }
        }
        
        
        opptyList[1].type = Label.OPPORTUNITY_TYPE_UPSELL;
        opptyList[0].stagename = 'Closed Won';
        //Test.startTest(); 
        if(!opptyList.isEmpty()){
            insert opptyList;
        }
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        System.debug('opptyList[0].Accountid...'+opptyList[0].Accountid);
        List<SBQQ__Quote__c> newquotList=  TestCPQUtilityClass.createSimpleQuote(opptyList,1);
        for(SBQQ__Quote__c SBQuote :newquotList){
            SBQuote.Rubiks_Quote__c = true;
             SBQuote.Order_Type__c ='Edition Change';   
        }
        newquotList[1].SBQQ__Type__c = 'Amendment';
        insert newquotList;
        Test.startTest(); 
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
         List<SBQQ__QuoteLine__c>  quoteLineList = TestCPQUtilityClass.createQuoteLines(newquotList,2,productToInsertList);
         insert quoteLineList;
       
        
         // create contracts 
         List<Contract> contractList = new List<Contract>();
         Contract contract1 = new Contract(Name='Test Contract ', AccountId=opptyList[0].AccountId,SBQQ__Opportunity__c = opptyList[0].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true, SBQQ__Quote__c = newquotList[0].Id,ContractTerm = 12);         
         contractList.add(contract1);
         insert contractList;
        
    list<SBQQ__QuoteLine__c> QLIList =    [SELECT id,SBQQ__Product__c FROM SBQQ__QuoteLine__c   WHERE SBQQ__Quote__r.SBQQ__Opportunity2__r.type =:Label.OPPORTUNITY_TYPE_UPSELL AND SBQQ__Product__c!=null];
     RubiksProdCode__c rubCodes = new RubiksProdCode__c(name=productToInsertList[0].name,Product_Code__c=productToInsertList[0].ProductCode);
     insert rubCodes;
     
      
        List<Asset> assetList = new List<Asset>();
        Asset as1 = new Asset();
        as1.Name = 'Test Asset 1';
        as1.installdate = System.today();
        as1.UsageEndDate = System.today().addMonths(2);
        as1.Opportunity__c = opptyList[0].Id;
        //as1.Asset_Type__c='Instance';
        as1.purpose__c='Rubiks Production';
        as1.Product2Id= productToInsertList[0].Id;
        as1.AccountId = accountsToInsertList[0].Id;
        as1.ContactId = ContactToInsert[0].id;
        as1.status = 'Active';
        as1.Acct_Prefix__c = QLIList[1].id;
        as1.SBQQ__QuoteLine__c =QLIList[1].id;

        as1.Contract__c = contractList[0].Id;
        
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = opptyList[0].Id;
        as1.Product2Id = productToInsertList[2].Id;
        as2.AccountId = accountsToInsertList[0].Id;
        as2.ContactId = ContactToInsert[0].id;
        as2.status = 'Active';
        as2.SBQQ__QuoteLine__c =QLIList[0].id;
        as2.Acct_Prefix__c = QLIList[0].id;
        //as2.Contract__c = contractList[0].Id;
        as2.purpose__c='Production';
       // as2.Asset_Type__c ='Instance';
        assetList.add(as1);
        assetList.add(as2);
        //18 Nov Test.startTest(); 
        list<Product2> Product2List = [SELECT id,name,ProductCode FROM  Product2 WHERE Id IN :productToInsertList]; 
         system.debug('Product2List======='+Product2List);
        if(!assetList.isEmpty()){
            insert assetList;
        } 
        SBQQSubscriptionTriggerHandler sbqqSubObj = new SBQQSubscriptionTriggerHandler();
      list<Asset> UpdatedAsset=  sbqqSubObj.populateOldAssetData(assetList);
      test.stopTest();
    }//End of method AssetConversiontest
    
         public static testMethod void testUpsellEnt1(){   

SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
 
        // Create accounts to insert
        Set<Id> accountsToInsertSet = new Set<Id>();
        map<id, id> AccToCont = new Map<id,id>();
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
        productToInsertList[1].ProductCode = label.Additional_Support_Product_Code_Of_subscription ;
        productToInsertList[1].Family= 'Support';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        productToInsertList[3].ProductCode ='SUPTPCBNDL';
        productToInsertList[4].ProductCode ='SUPTPC41BNDL'; 
        productToInsertList[2].Asset_Type__c = 'Support Product';
        insert productToInsertList;
        system.debug('---productToInsertList[0]---'+productToInsertList[0]);
        // insert products into standard pricebook
        Id stdPricebookId = Test.getStandardPricebookId();
        TestCPQUtilityClass.createStdPricebookEntries(productToInsertList,stdPricebookId);
        
        // Create custom pricebooks
        List<PriceBook2> pricebookList = new List<PriceBook2>();
        pricebookList =TestCPQUtilityClass.createCustomPriceBooks(5);
        insert pricebookList;
        
        // insert products into custom pricebooks
        List<PriceBookEntry> priceBookEntriesList = new List<PriceBookEntry>();
        priceBookEntriesList =TestCPQUtilityClass.createPriceBookEntries(productToInsertList,pricebookList);
        insert priceBookEntriesList;
        
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
        
        // insert opportunities - for Closed Won Oppty - Contract will be created automatically
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities(accountsToInsertList,2);
        for(Opportunity opp : opptyList){
            opp.Rep_Create_ARR__c = 10000;
            opp.Amount = 2000;
            opp.Pricebook2Id = pricebookList[0].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.OwnerId=UserInfo.getUserId();
            if(AccToCont.containsKey(opp.AccountId)){
                opp.Primary_Marketo_User_Lookup__c = AccToCont.get(opp.AccountId) ;
                opp.Primary_Marketo_User_Email__c = 'test.abc@jade.com' ;
            }
        }
        
        
        opptyList[1].type = Label.OPPORTUNITY_TYPE_UPSELL;
        opptyList[0].stagename = 'Closed Won';
        //Test.startTest(); 
        if(!opptyList.isEmpty()){
            insert opptyList;
        }
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        System.debug('opptyList[0].Accountid...'+opptyList[0].Accountid);
        List<SBQQ__Quote__c> newquotList=  TestCPQUtilityClass.createSimpleQuote(opptyList,1);
        for(SBQQ__Quote__c SBQuote :newquotList){
            SBQuote.Rubiks_Quote__c = true;
        }
        newquotList[1].SBQQ__Type__c = 'Amendment';
        insert newquotList;
        Test.startTest(); 
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
         List<SBQQ__QuoteLine__c>  quoteLineList = TestCPQUtilityClass.createQuoteLines(newquotList,2,productToInsertList);
         insert quoteLineList;
         
         
         // create contracts 
         List<Contract> contractList = new List<Contract>();
         Contract contract1 = new Contract(Name='Test Contract ', AccountId=opptyList[0].AccountId,SBQQ__Opportunity__c = opptyList[0].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true, SBQQ__Quote__c = newquotList[0].Id,ContractTerm = 12);         
         contractList.add(contract1);
         insert contractList;
        
    list<SBQQ__QuoteLine__c> QLIList =    [SELECT id,SBQQ__Product__c FROM SBQQ__QuoteLine__c   WHERE SBQQ__Quote__r.SBQQ__Opportunity2__r.type =:Label.OPPORTUNITY_TYPE_UPSELL AND SBQQ__Product__c!=null];

      
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
        as1.SBQQ__QuoteLine__c =QLIList[1].id;

        as1.Contract__c = contractList[0].Id;
        
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = opptyList[0].Id;
        as1.Product2Id = productToInsertList[2].Id;
        as2.AccountId = accountsToInsertList[0].Id;
        as2.ContactId = ContactToInsert[0].id;
        as2.status = 'Active';
        as2.SBQQ__QuoteLine__c =QLIList[0].id;
        as2.Acct_Prefix__c = QLIList[0].id;
        as2.Contract__c = contractList[0].Id;
        assetList.add(as1);
        assetList.add(as2);
        //18 Nov Test.startTest(); 
        list<Product2> Product2List = [SELECT id,name,ProductCode FROM  Product2 WHERE Id IN :productToInsertList]; 
         system.debug('Product2List======='+Product2List);
        if(!assetList.isEmpty()){
            insert assetList;
        } 
       list<asset> assBunAssetList = [SELECT id,Product2id,name,Product_Code__c,Associated_Bundle__c FROM  Asset WHERE Id IN :assetList];  
       system.debug('assBunAssetList======='+assBunAssetList);
          
         
        
        contractList[0].Primary_Asset__c = assetList[0].Id;
        update contractList;
        
        // create subscriptions
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[1].Id,SBQQ__QuoteLine__c=quoteLineList[1].id);
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[1].Id,SBQQ__QuoteLine__c=quoteLineList[1].id);
        
        
        subList.add(sub1);
        subList.add(sub2);
       insert subList;
       
         List<Entitlement> newEntList= TestCPQUtilityClass.createEntitlements(subList,2);
          Id SupportRecordTypeId = Schema.SObjectType.Entitlement.getRecordTypeInfosByName().get('Support').getRecordTypeId();
         for(Entitlement newEnt : newEntList){
             newEnt.Contract__c = contractList[0].Id;
             newEnt.Type = 'Business' ;
             newEnt.StartDate =  system.today() -50;
             newEnt.EndDate =  system.today() +10;
             newEnt.recordTypeID = SupportRecordTypeId;
             
         }
          newEntList[0].Contract__c = contractList[0].Id;
         insert newEntList;
         
          list<SBQQ__Subscription__c> InsertsubList =    new list<SBQQ__Subscription__c>();
           SBQQ__Subscription__c sub6 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =QLIList[0].SBQQ__Product__c,SBQQ__QuoteLine__c=QLIList[0].id);
           SBQQ__Subscription__c sub7 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =QLIList[1].SBQQ__Product__c,SBQQ__QuoteLine__c=QLIList[1].id);
           InsertsubList.add(sub6);
          InsertsubList.add(sub7);
         Test.stopTest();
       insert InsertsubList;
       
    /* list <SBQQ__Subscription__c> SubAfterDMLList=[SELECT id,SBQQ__StartDate__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Rubiks_Quote__c,SBQQ__Product__r.productcode,SBQQ__Contract__c,SBQQ__Contract__r.SBQQ__Opportunity__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Opportunity_Type__c from SBQQ__Subscription__c WHERE id IN :InsertsubList AND SBQQ__QuoteLine__r.SBQQ__Quote__r.Opportunity_Type__c=:Label.OPPORTUNITY_TYPE_UPSELL];
     
     System.assertEquals(1, SubAfterDMLList.size());*/

       
    }//End of method testRubikQuoteContract
    
     
    public static testMethod void testMoveAuthorizedContactAndCases(){
        
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
 
        map<id, id> AccToCont = new Map<id,id>();
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
        
        list<Contact> ContactToInsert = new list<Contact>();
        ContactToInsert = TestCPQUtilityClass.createContacts(accountsToInsertList,1);
        for(Contact con:ContactToInsert ){
            con.pse__Salesforce_User__c  =null;
        }
        insert ContactToInsert;
        
        List<Product2> productToInsertList = new List<Product2>();
        productToInsertList =TestCPQUtilityClass.createCustomProducts(5);
        productToInsertList[0].MA_or_RTP__c = 'MA';   
        productToInsertList[0].Visible_To_Customer__c = true;
        productToInsertList[0].Family='Support';
        productToInsertList[0].ProductCode= productToInsertList[0].ProductCode;// +'INST';
        productToInsertList[1].Visible_To_Customer__c = true;
        productToInsertList[1].MA_or_RTP__c ='RTP';
        productToInsertList[1].ProductCode = 'RTP Code testINST' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].ProductCode= 'PROD testINST1 ';
        productToInsertList[3].ProductCode= 'RTP testINST 12';
        
        //productToInsertList[].ProductCode= 'SAND test ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        insert productToInsertList;
        system.debug('---productToInsertList[0]---'+productToInsertList[0]);
        // insert products into standard pricebook
        Id stdPricebookId = Test.getStandardPricebookId();
        //TestCPQUtilityClass.createStdPricebookEntries(productToInsertList,stdPricebookId);
        
        //insert product in std pricebook entry
        List<PricebookEntry> standardPricebookEntryList = new List<PricebookEntry>();
        for(Integer i=0; i<productToInsertList.size();i++){
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = stdPricebookId, Product2Id = productToInsertList[i].Id,UnitPrice = 10000, IsActive = true);
        standardPricebookEntryList.add(standardPrice);
        }
        insert standardPricebookEntryList;
     
        // Create custom pricebooks
        List<PriceBook2> pricebookList = new List<PriceBook2>();
        pricebookList =TestCPQUtilityClass.createCustomPriceBooks(5);
        insert pricebookList;
        
        // insert products into custom pricebooks
        List<PriceBookEntry> priceBookEntriesList = new List<PriceBookEntry>();
        priceBookEntriesList =TestCPQUtilityClass.createPriceBookEntries(productToInsertList,pricebookList);
        insert priceBookEntriesList;
        
        // Insert data for custom setting - Contract_Roll_Up_With_Product_Code__c       
        List<Contract_Roll_Up_With_Product_Code__c> productCodeList = new List<Contract_Roll_Up_With_Product_Code__c>();
        Contract_Roll_Up_With_Product_Code__c crp1 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test Product 1 ', FieldName__c='Contract_Base_ACV_for_Support__c',   Multiplier__c=3, Need_To_Check_Criteria__c = true, Product_Code__c = 'TESTPRODCODE0, TESTPRODCODE1', Subscription_Field__c = 'Subscription_ACV__c', User_Code__c= 'SUP-BASE-BUS, SUP-BASE-ELT, SUP-BASE-STD-ENT, SUP-BASE-PRM, SUP-BASE-STD-SMB, SUP-BASE-SPK',Include_in_Maintenance__c = true);           
        Contract_Roll_Up_With_Product_Code__c crp2 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test', FieldName__c='Contract_Base_ACV_for_Support__c',  Multiplier__c=3, Need_To_Check_Criteria__c = true, Product_Code__c = 'TESTPRODCODE2,TESTPRODCODE3', Subscription_Field__c = 'Subscription_ACV__c', User_Code__c = null, Include_in_Maintenance__c = true,SUP_Product_code__c = 'tes');          
        Contract_Roll_Up_With_Product_Code__c crp3 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test 2', FieldName__c='Contract_Base_ACV_for_Support__c',    Multiplier__c=3, Need_To_Check_Criteria__c = false, Product_Code__c = 'TPC4', Subscription_Field__c = 'Subscription_ACV__c');           
        Contract_Roll_Up_With_Product_Code__c crp4 = new Contract_Roll_Up_With_Product_Code__c(Name = 'Test 3', FieldName__c='Contract_Base_ACV_for_Support__c',    Multiplier__c=3, Need_To_Check_Criteria__c = false, Product_Code__c = 'TPC4', Subscription_Field__c ='Subscription_MCV__c');            
        productCodeList.add(crp1);
        productCodeList.add(crp2);
        productCodeList.add(crp3);
        productCodeList.add(crp4);
        insert productCodeList;     
        
        // Insert data for custom setting - Entitlement_Product_Code_Criteria__c
        List<Entitlement_Product_Code_Criteria__c> entProdCodeList = new List<Entitlement_Product_Code_Criteria__c>();
        Entitlement_Product_Code_Criteria__c entProdCode = new Entitlement_Product_Code_Criteria__c(Name ='Test Name',Product_Code__c = productToInsertList[0].productcode, Type__c = 'Test');
        entProdCodeList.add(entProdCode);
        insert entProdCodeList;

        // insert opportunities - for Closed Won Oppty - Contract will be created automatically
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities(accountsToInsertList,2);
        for(Opportunity opp : opptyList){
            opp.Rep_Create_ARR__c = 10000;
            opp.Amount = 2000;
            opp.Pricebook2Id =stdPricebookId;
            //opp.Pricebook2Id = pricebookList[0].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.Sub_End_Date__c =System.today().addMonths(10);
            opp.Sub_Start_Date__c=System.today();
            opp.OwnerId=UserInfo.getUserId();
            opp.Competitor_Swap__c='Act-On';
            if(AccToCont.containsKey(opp.AccountId)){
                opp.Primary_Marketo_User_Lookup__c = AccToCont.get(opp.AccountId) ;
                opp.Primary_Marketo_User_Email__c = 'test.abc@jade.com' ;
            }
        }
        
        //opptyList[2].type = 'Renewal';
        //opptyList[3].type = 'Upsell/Crossell';
        opptyList[0].type = 'New Business';
        opptyList[0].stagename = 'Closed Won';
        opptyList[0].Ghost__c=true;
        opptyList[1].Ghost__c=true;
        opptyList[1].Migration__c=true;
        opptyList[1].Pricebook2Id = pricebookList[0].Id;
        opptyList[1].type = 'Renewal';
        opptyList[0].Primary_Marketo_User_Lookup__c=ContactToInsert[0].id;
        opptyList[1].Primary_Marketo_User_Lookup__c=ContactToInsert[0].id;
        opptyList[1].Deal_Type__c='Education';
        opptyList[0].Deal_Type__c='Education';
        if(!opptyList.isEmpty()){
            insert opptyList;
        }
        
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
 
        // Create Quote 
        Quote quote = new Quote(Name='Test Quote',Maximum_Database_Size__c=10000,Pricebook2Id=stdPricebookId,OpportunityId=opptyList[0].Id, Master_Sub_Start_Date__c = System.Today(),Master_Sub_end_Date__c = System.Today().addMonths(12));
        insert quote;
        //List<OpportunityLineItem> OLIList = TestCPQUtilityClass.createOppLineItems(opptyList,standardPricebookEntryList);
        //insert OLIList;
        List<QuoteLineItem> quoteLinesToInsert = new List<QuoteLineItem>(); 
        for(Integer j=0; j<2; j++){
        QuoteLineItem quoteLine = new QuoteLineItem(QuoteId=quote.Id,Quantity=7,Product2Id=productToInsertList[j].id,PricebookEntryId=standardPricebookEntryList[0].id, UnitPrice=12);
        quoteLinesToInsert.add(quoteLine);
        }
       // Test.startTest(); 
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
         SalesTriggersUtility.dlrs_AccountTrigger = true;
         SalesTriggersUtility.AssetTriggerVA  = true;
 
        insert quoteLinesToInsert;
        List<SBQQ__Quote__c> newquotList=  TestCPQUtilityClass.createSimpleQuote(opptyList,1);
        for(SBQQ__Quote__c SBQuote :newquotList){
            SBQuote.Rubiks_Quote__c = true;
        }
        insert newquotList;
         List<SBQQ__QuoteLine__c>  quoteLineList = TestCPQUtilityClass.createQuoteLines(newquotList,2,productToInsertList);
              quoteLineList[0].Product_Family__c='Bundle';

         insert quoteLineList;
          
        opptyList[1].Prior_Opportunity__c=opptyList[0].id;
        opptyList[1].stagename = 'Closed Won';
        update opptyList;
        
            // create contracts 
         /*List<Contract> contractList = new List<Contract>();
         Contract contract1 = new Contract(Name='Test Contract ', AccountId=opptyList[0].AccountId,SBQQ__Opportunity__c = opptyList[0].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true, ContractTerm = 2);         
         Contract contract2 = new Contract(Name='Test Contract ', AccountId=opptyList[1].AccountId,SBQQ__Opportunity__c = opptyList[1].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true,SBQQ__Quote__c = newquotList[0].Id,ContractTerm =4 );
         contractList.add(contract1);
         contractList.add(contract2);*/
         Test.startTest();
       SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        
         List<Contract> contractList = new List<Contract>();
         Contract contract1 = new Contract(Name='Test Contract ', AccountId=opptyList[1].AccountId,SBQQ__Opportunity__c = opptyList[0].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true, SBQQ__Quote__c = newquotList[0].Id,ContractTerm = 12);         
         Contract contract2 = new Contract(Name='Test Contract ', AccountId=opptyList[1].AccountId,SBQQ__Opportunity__c = opptyList[1].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 10,SBQQ__Quote__c = newquotList[1].Id);
         contractList.add(contract1);
         contractList.add(contract2);
         insert contractList;
         
         
        
        List<Asset> assetList = new List<Asset>();
        Utility.DO_NOT_UPDATE_ACCOUNT_FROM_OPPTY=true;
         Utility.haveupdatedAssets=true;
        Asset as1 = new Asset();
        as1.Name = 'Test Asset 1';
        as1.installdate = System.today();
        as1.UsageEndDate = System.today().addMonths(-12);
        as1.Opportunity__c = opptyList[0].Id;
        as1.latest_Opportunity__c = opptyList[1].id;
        as1.purpose__c='Production';
        as1.Acct_Prefix__c = 'testAct';
        as1.Munchkin_ID__c ='munkintest';
        as1.POD__c ='testPOD';
        as1.Product2Id= productToInsertList[0].Id;
        as1.AccountId = opptyList[0].AccountId;
        as1.ContactId = ContactToInsert[0].id;
        as1.status = 'Active';
        as1.Asset_Type__c = 'Instance';
        
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().adddays(1);
        as2.Opportunity__c = opptyList[1].Id;
        as2.Product2Id = productToInsertList[2].Id;
        as2.purpose__c='Production';
        as2.AccountId = opptyList[1].accountId;
        as2.ContactId = ContactToInsert[0].id;
        as2.status = 'Active';
        as2.Contract__c = contractList[0].Id;
        as1.Asset_Type__c = 'Instance';
        
      
        
        assetList.add(as1);
        assetList.add(as2);
        insert assetList;
       
       
        contractList[0].Primary_Asset__c = assetList[0].Id;
        contractList[1].Primary_Asset__c = assetList[1].Id;
        //update contractList;
        
        // create subscriptions
       // create subscriptions
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234,SBQQ__Product__c =productToInsertList[0].Id,SBQQ__QuoteLine__c=quoteLineList[0].id);       
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[1].Id,SBQQ__Account__c=contractList[1].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[0].Id,SBQQ__QuoteLine__c=quoteLineList[0].id); 
       
        subList.add(sub1);
        subList.add(sub2);
        insert subList;
            
         /*assetList[0].Munchkin_ID__c='testMunchkin1';
         assetList[0].POD__c='ab18';
         assetList[0].Acct_Prefix__c='TestAsset';
         update assetList;*/
        List<Entitlement> lstEnt = TestCPQUtilityClass.createEntitlements(subList,2);
        for(Entitlement ent: lstEnt){
            ent.AccountId = opptyList[0].AccountId;
            ent.StartDate = System.Today();
            ent.EndDate = System.Today().addMonths(12);  
            ent.type='Online';       
        }
        lstEnt[0].AssetId = assetList[0].id;
       // lstEnt[1].AssetId = assetList[1].id;
      //  Insert lstEnt;
       
       set<Id> assetIDSet = new set<Id>();
       for(asset ass : assetList){
           assetIDSet.add(ass.id);
       }
       list<Entitlement> listEnt = [SELECT id,type, AssetId From Entitlement WHERE AssetId IN : assetIDSet order by Enddate ];
       system.debug('listEnt############ '+listEnt);
       map<id,id> EntMap = new map<id,id>();
       
        listEnt[0].startdate=system.today()-10;
       listEnt[0].enddate=system.today()-1;
       listEnt[1].type='Online'; 
       listEnt[0].type='Online';   
       update listEnt;
       
       entitlement entNewB=[SELECT id,type FROM Entitlement WHERE id=:listEnt[1].id and type!=: system.label.Entitlement_Type_Label];
       EntMap.put(listEnt[0].id, listEnt[1].id);
      // system.assertEquals(listEnt[1].AssetId,assetList[1].id);
     //  system.assertEquals(!listEnt.isEmpty(),false);
       
       
        test.stopTest();
       
       
        //RecordType rt = [select Id from RecordType where Name = 'Proactive Cases' and SobjectType = 'Case' limit 1];
        Id RecordTypeIdCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Proactive Cases').getRecordTypeId();
        //System.AssertEquals(rt.name,
        Case cs=new Case();
        cs.accountid = accountsToInsertList[0].id;
        cs.contactid=ContactToInsert[0].id;
        cs.origin = 'Voicemail';
        cs.Entitlementid=listEnt[0].id;
        cs.RecordTypeId = RecordTypeIdCase;
        cs.Subject = 'test Subject';
        cs.Problem_Type__c='Bug';
        cs.Description='test Desc';
       cs.status='New';
        insert cs;
        SBQQSubscriptionTriggerHandler.MoveAuthorizedContactAndCases(EntMap);
         
        
    }  
    public static testMethod void testMethodForENT(){ 

SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;   
        // Create accounts to insert
        Set<Id> accountsToInsertSet = new Set<Id>();
        map<id, id> AccToCont = new Map<id,id>();
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
           
            accountsToInsertList.add(accnt);
        }
            insert accountsToInsertList;
            for(Account acc : accountsToInsertList){
                accountsToInsertSet.add(acc.Id);
            }
           
        list<Contact> ContactToInsert = new list<Contact>();
        ContactToInsert = TestCPQUtilityClass.createContacts(accountsToInsertList,1);
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
        productToInsertList[0].ProductCode ='INST Prod Asset';
        productToInsertList[0].MA_or_RTP__c = 'MA';   
        productToInsertList[0].Visible_To_Customer__c = true;
        productToInsertList[0].Family='Support';
        productToInsertList[1].Visible_To_Customer__c = true;
        productToInsertList[1].MA_or_RTP__c ='RTP';
        productToInsertList[1].ProductCode = 'TESTClassPRODCODEBNDL' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        productToInsertList[3].ProductCode ='SUP-BASE SUPTPCBNDL';
        productToInsertList[4].ProductCode ='SUP-BASE SUPTPC41BNDL'; 
        productToInsertList[2].Asset_Type__c = 'Support Product';
       // productToInsertList[2].Product_Family__c='Bundle';
                productToInsertList[3].Asset_Type__c = 'Support Product';

        productToInsertList[4].Asset_Type__c = 'Support Product';
 productToInsertList[2].ProductCode ='PROD-APPS-INST';
        insert productToInsertList;
        system.debug('---productToInsertList[0]---'+productToInsertList[0]);
        // insert products into standard pricebook
        Id stdPricebookId = Test.getStandardPricebookId();
        TestCPQUtilityClass.createStdPricebookEntries(productToInsertList,stdPricebookId);
        
        // Create custom pricebooks
        List<PriceBook2> pricebookList = new List<PriceBook2>();
        pricebookList =TestCPQUtilityClass.createCustomPriceBooks(5);
        insert pricebookList;
        
        // insert products into custom pricebooks
        List<PriceBookEntry> priceBookEntriesList = new List<PriceBookEntry>();
        priceBookEntriesList =TestCPQUtilityClass.createPriceBookEntries(productToInsertList,pricebookList);
        insert priceBookEntriesList;
        
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
        
        // insert opportunities - for Closed Won Oppty - Contract will be created automatically
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities(accountsToInsertList,2);
        for(Opportunity opp : opptyList){
            opp.Rep_Create_ARR__c = 10000;
            opp.Amount = 2000;
            opp.Pricebook2Id = pricebookList[0].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.OwnerId=UserInfo.getUserId();
            if(AccToCont.containsKey(opp.AccountId)){
                opp.Primary_Marketo_User_Lookup__c = AccToCont.get(opp.AccountId) ;
                opp.Primary_Marketo_User_Email__c = 'test.abc@jade.com' ;
            }
        }
        
        opptyList[0].type = Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL;
        opptyList[1].type = Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL;
        opptyList[0].stagename = 'Closed Won';
        Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
      Trigger_Opportunity_Helper.isBeforeUpdateEvent = True;
        if(!opptyList.isEmpty()){
            insert opptyList;
        }
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        System.debug('opptyList[0].Accountid...'+opptyList[0].Accountid);
        List<SBQQ__Quote__c> newquotList=  TestCPQUtilityClass.createSimpleQuote(opptyList,1);
        for(SBQQ__Quote__c SBQuote :newquotList){
            SBQuote.Rubiks_Quote__c = true;
            SBQuote.Opportunity_Type__c=Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL;
        }
        newquotList[1].SBQQ__Type__c = 'Amendment';
        insert newquotList;
        Test.startTest(); 
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
         List<SBQQ__QuoteLine__c>  quoteLineList = TestCPQUtilityClass.createQuoteLines(newquotList,3,productToInsertList);
         quoteLineList[0].Product_Family__c='Bundle';
         quoteLineList[1].Product_Family__c='Bundle';
         insert quoteLineList;
         
         
       
        
         // create contracts 
         List<Contract> contractList = new List<Contract>();
         Contract contract1 = new Contract(Name='Test Contract ', AccountId=opptyList[0].AccountId,SBQQ__Opportunity__c = opptyList[0].Id, StartDate=System.today()-2, By_Pass_Contract_Workflow__c =true, SBQQ__Quote__c = newquotList[0].Id,ContractTerm = 12);         
         contractList.add(contract1);
         insert contractList;
        
    list<SBQQ__QuoteLine__c> QLIList =    [SELECT id,SBQQ__Product__c,SBQQ__RequiredBy__c FROM SBQQ__QuoteLine__c   WHERE SBQQ__Quote__r.SBQQ__Opportunity2__r.type =:Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL AND SBQQ__Product__c!=null AND SBQQ__ProductCode__c='PROD-APPS-INST'];
//QLIList[1].SBQQ__RequiredBy__c=quoteLineList[3].id;
   //   update QLIList;
        List<Asset> assetList = new List<Asset>();
        Asset as1 = new Asset();
        as1.Name = 'Test Asset 1';
        as1.installdate = System.today();
        as1.UsageEndDate = System.today().addMonths(2);
        as1.Opportunity__c = opptyList[0].Id;
        //as1.Asset_Type__c='Instance';
        
        as1.Product2Id= productToInsertList[0].Id;
        as1.AccountId = accountsToInsertList[0].Id;
        as1.ContactId = ContactToInsert[0].id;
        as1.status = 'Active';
        as1.Acct_Prefix__c = QLIList[1].id;
        as1.SBQQ__QuoteLine__c =QLIList[1].id;
        as1.Asset_Type__c ='Instance';
        as1.Purpose__c = 'Rubiks Production';
        as1.Contract__c = contractList[0].Id;
        /*
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = opptyList[0].Id;
        as1.Product2Id = productToInsertList[2].Id;
        as2.AccountId = accountsToInsertList[0].Id;
        as2.ContactId = ContactToInsert[0].id;
        as2.status = 'Active';
        as2.SBQQ__QuoteLine__c =QLIList[0].id;
        as2.Acct_Prefix__c = QLIList[0].id;
        as2.Contract__c = contractList[0].Id;
        as2.Asset_Type__c ='Instance';
        as2.Purpose__c='Production';
        */
        assetList.add(as1);
        
        
        //18 Nov Test.startTest(); 
        list<Product2> Product2List = [SELECT id,name,ProductCode FROM  Product2 WHERE Id IN :productToInsertList]; 
         system.debug('Product2List======='+Product2List);
        if(!assetList.isEmpty()){
            insert assetList;
        } 
       list<asset> assBunAssetList = [SELECT id,Product2id,name,Product_Code__c,Associated_Bundle__c FROM  Asset WHERE Id IN :assetList];  
       system.debug('assBunAssetList======='+assBunAssetList);
          
         
        
        contractList[0].Primary_Asset__c = assetList[0].Id;
        update contractList;
        
        // create subscriptions
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[3].Id,SBQQ__QuoteLine__c=quoteLineList[0].id);
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[4].Id,SBQQ__QuoteLine__c=quoteLineList[1].id);
        
        
        subList.add(sub1);
        subList.add(sub2);
       insert subList;
       
       update subList;
       
         List<Entitlement> newEntList= TestCPQUtilityClass.createEntitlements(subList,1);
         for(Entitlement newEnt : newEntList){
             newEnt.Contract__c = contractList[0].Id;
         }
          newEntList[0].Contract__c = contractList[0].Id;
         insert newEntList;
         
          list<SBQQ__Subscription__c> InsertsubList =    new list<SBQQ__Subscription__c>();
           SBQQ__Subscription__c sub6 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =QLIList[0].SBQQ__Product__c,SBQQ__QuoteLine__c=QLIList[0].id);
           SBQQ__Subscription__c sub7 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =QLIList[1].SBQQ__Product__c,SBQQ__QuoteLine__c=QLIList[1].id);
           InsertsubList.add(sub6);
          InsertsubList.add(sub7);
         Test.stopTest();
       //insert InsertsubList;
       


        
       
    }//End of method testMethodForENT
}