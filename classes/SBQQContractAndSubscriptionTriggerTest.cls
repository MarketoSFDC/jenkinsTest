@isTest
public class SBQQContractAndSubscriptionTriggerTest {
    
    public static testMethod void testPopulatePrimaryAssetOnContract(){
        
        List<Account> accList = new List<Account>();
        accList = TestCPQUtilityClass.createAccounts(1);
        if(!accList.isEmpty()){
            insert accList;
        }
        Map<Id, Decimal> accIdsForGiansightDBSizeMap = new Map<Id, Decimal>();
        Map<Id, Account> updateAccountMap = new Map<Id, Account>();
        for(Account acc :accList){
                accIdsForGiansightDBSizeMap.put(acc.id, 20000.00);
                updateAccountMap.put(acc.id,acc);
        }
        
        updateAccountMap =SBQQContractAndSubscriptionTriggerHelper.populateGainsightDatabaseSize(accIdsForGiansightDBSizeMap,updateAccountMap);
        
        
        Asset a = new Asset();
        a.name = 'Test Asset';
        a.AccountId = accList[0].id;
        Insert a;
        
        List<Opportunity> oppList = new List<Opportunity>(); 
        oppList = TestCPQUtilityClass.createOpportunities(accList, 2);
        oppList[0].type = 'New Buisness';
        oppList[1].type = 'Renewal';
        
        if(!oppList.isEmpty()){
            insert oppList;
        }
        
        List<Contract> contractList = new List<Contract>();
        contractList = TestCPQUtilityClass.createContracts(accList,2);
        contractList[0].SBQQ__Opportunity__c = oppList[0].id;
        contractList[0].SBQQ__RenewalOpportunity__c = oppList[1].id;
        contractList[1].SBQQ__Opportunity__c = oppList[1].id;
        contractList[0].Primary_Asset__c = a.Id;
        contractList[0].Total_Contact_Records__c =100;
        contractList[1].Total_Contact_Records__c =200;
        system.debug('contractList: '+contractList);
        Test.startTest();
        if(!contractList.isEmpty()){
            insert contractList[0];
            insert contractList[1];
        }
        contractList[0].Total_Contact_Records__c =400;
        contractList[1].Total_Contact_Records__c =300;
        update contractList;
        Test.stopTest();
    }
    
    public static testMethod void SBQQContractAndSubscriptionTriggerTestMethod(){
        
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
        
      }
}