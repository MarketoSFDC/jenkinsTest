@isTest
public class CaseAutoProvisioning_Test {
    public static testMethod void testProcessCases(){
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA  = true;

        List<Account> accountsToInsertList = new List<Account>();
        map<id, id> AccToCont = new Map<id,id>();
        
        //Insert Accounts
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
            accnt.Acct_Prefix__c = 'testtest';
            //accnt.RecordTypeId = '01250000000ULb7AAG'; 
            accountsToInsertList.add(accnt);
        }
        insert accountsToInsertList;
        
        
        //Insert Contacts
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
        
        // Create custom pricebooks
        List<PriceBook2> pricebookList = new List<PriceBook2>();
        pricebookList =TestCPQUtilityClass.createCustomPriceBooks(5);
        insert pricebookList;
        
        // insert opportunities - for Closed Won Oppty - Contract will be created automatically
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities(accountsToInsertList,4);
        for(Opportunity opp : opptyList){
            opp.Rep_Create_ARR__c = 10000;
            opp.Amount = 2000;
            opp.Pricebook2Id = pricebookList[0].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.type ='Upsell/Crossell';
            opp.OwnerId=UserInfo.getUserId();
            if(AccToCont.containsKey(opp.AccountId)){
                opp.Primary_Marketo_User_Lookup__c = AccToCont.get(opp.AccountId) ;
                opp.Primary_Marketo_User_Email__c = 'test.abc@jade.com' ;
            }
        }
        
        opptyList[1].type = 'Renewal';
        opptyList[1].Prior_Opportunity__c = opptyList[0].id;
        //  opptyList[1].type = 'Upsell/Crossell';
        if(!opptyList.isEmpty()){
            insert opptyList;
        }
        system.debug('opptyList='+opptyList);
        System.debug('opptyList[0].Accountid...'+opptyList[0].Accountid);
        
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
        
        
        //Insert Assets
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
        //    as1.Contract__c = contractList[0].Id;
        as1.Munchkin_ID__c = '1234-asd-124';
        as1.Acct_Prefix__c = 'TestTest1';
        as1.POD__c = 'sjint';
        assetList.add(as1);

     //   List<AssetHistory> AssetList1=[SELECT AssetId,Field,Id,IsDeleted,NewValue,OldValue, Asset.Acct_Prefix__c, Asset.Munchkin_ID__c FROM AssetHistory];
     //   system.debug('AssetList='+AssetList1);
     //   system.assertEquals(1,AssetList1.size());
          Test.startTest();
          
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA  = true;

        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(2);
        as2.Opportunity__c = opptyList[0].Id;
        as2.Asset_Type__c='Instance';
        as2.purpose__c='Production';
        as2.Product2Id= productToInsertList[0].Id;
        as2.AccountId = accountsToInsertList[0].Id;
        as2.ContactId = ContactToInsert[0].id;
        as2.status = 'Active';
        as2.Munchkin_ID__c = '1234-asd-123';
        as2.Acct_Prefix__c = 'TestTest';
        as2.POD__c = 'sjint';
        assetList.add(as2);
        insert assetList;
        
        assetList[0].Munchkin_ID__c = null;
        assetList[0].Acct_Prefix__c = null;
        assetList[0].POD__c = null;
        assetList[0].status = 'Expired';
        update assetList[0];
        
      
        // Create Quote     
        List<SBQQ__Quote__c> newQuotList  = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opptyList[0].Id,SBQQ__Account__c= opptyList[0].accountId, SBQQ__StartDate__c = System.Today());
        newQuotList.add(quote);
        insert newQuotList;
        
        // Insert Quote Lines
       list<SBQQ__QuoteLine__c> quoteLines=TestCPQUtilityClass.createQuoteLines(newQuotList,1,productToInsertList);
  
        insert quoteLines;    
        
        // create contracts 
        List<Contract> contractList = new List<Contract>();
        Contract contract1 = new Contract(Name='Test Contract ', AccountId=opptyList[0].AccountId,SBQQ__Opportunity__c = opptyList[0].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true, SBQQ__Quote__c = quote.Id,ContractTerm = 2);         
        Contract contract2 = new Contract(Name='Test Contract ', AccountId=opptyList[0].AccountId,SBQQ__Opportunity__c = opptyList[1].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true,ContractTerm = 2);
        contractList.add(contract1);
        contractList.add(contract2);
        insert contractList;
        
        // create subscriptions
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234,SBQQ__Product__c =productToInsertList[0].Id);       
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[1].Id);
        subList.add(sub1);
        subList.add(sub2);
   
        insert subList;
         test.stopTest();
        //Insert Asset History
        //AssetHistory ah=new AssetHistory(AssetId=as1.Id);
        //insert ah;
        
        //Insert Case
        List<Case> CaseList = new List<Case>();
        CaseList = TestCPQUtilityClass.createCases(opptyList,1);
        for(Case c :CaseList){
            c.Added_Products__c= 'test';
            c.Quantity_Change_on_Existing_Products__c = 'test';
            c.Asset_Name__c='TestRubiks ProductionTest';
            c.Account_String__c = 'TestTest,test2test2,Test3Test3';
        }
        CaseList[1].Account_String__c = 'Test';
         if(!CaseList.isEmpty()){       
            insert CaseList;        
        }       
       // insert CaseList;
        system.debug('CaseList='+CaseList);  
        //Call processCases
        CaseAutoProvisioning.processCases();
       
    } 
    
    //*************************************************
     public static testMethod void testProcessCasesMultiInstace(){
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA  = true;
        
        List<Account> accountsToInsertList = new List<Account>();
        map<id, id> AccToCont = new Map<id,id>();
        
        //Insert Accounts
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
            accnt.Acct_Prefix__c = 'testtest';
            //accnt.RecordTypeId = '01250000000ULb7AAG'; 
            accountsToInsertList.add(accnt);
        }

        insert accountsToInsertList;
      
        
        //Insert Contacts
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
        
        // Create custom pricebooks
        List<PriceBook2> pricebookList = new List<PriceBook2>();
        pricebookList =TestCPQUtilityClass.createCustomPriceBooks(5);
        insert pricebookList;
        
        // insert opportunities - for Closed Won Oppty - Contract will be created automatically
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities(accountsToInsertList,4);
        for(Opportunity opp : opptyList){
            opp.Rep_Create_ARR__c = 10000;
            opp.Amount = 2000;
            opp.Pricebook2Id = pricebookList[0].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.type ='Upsell/Crossell';
            opp.OwnerId=UserInfo.getUserId();
            if(AccToCont.containsKey(opp.AccountId)){
                opp.Primary_Marketo_User_Lookup__c = AccToCont.get(opp.AccountId) ;
                opp.Primary_Marketo_User_Email__c = 'test.abc@jade.com' ;
            }
        }
        opptyList[0].type = 'New Business';
        opptyList[1].type = 'Renewal';
        
        //  opptyList[1].type = 'Upsell/Crossell';
        if(!opptyList.isEmpty()){
            insert opptyList;
        }
         
        Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
        Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
        Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
        Trigger_Opportunity_Helper.isAfterUpdateEvent = true;
        
        opptyList[1].Prior_Opportunity__c = opptyList[0].id;
        opptyList[2].Prior_Opportunity__c = opptyList[0].id;
        update opptyList;
         
         set<id> OppRenId = new set<id>();
         for(Opportunity opp:opptyList){
             if(opp.type=='Renewal'){
                 OppRenId.add(opp.id);
             }
         }

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

        productToInsertList[0].Product_Type__c = 'Subscription';
        insert productToInsertList;
        system.debug('---productToInsertList[0]---'+productToInsertList[0]);
        
        List<Product_SKU_Engineering_Code__c> custSetRecordsList = new List<Product_SKU_Engineering_Code__c>();
        
        // Create custSetRecords
        Product_SKU_Engineering_Code__c  custSetRec1 = new Product_SKU_Engineering_Code__c();
        custSetRec1.Name = 'custSetRec1';
        custSetRec1.Engineering_Code__c = 'accountBasedMarketing';
        custSetRec1 .Product_Code__c = productToInsertList[0].ProductCode ;
        custSetRecordsList.add(custSetRec1);
        
        Product_SKU_Engineering_Code__c  custSetRec2 = new Product_SKU_Engineering_Code__c();
        custSetRec2.Name = 'custSetRec2';
        custSetRec2.Engineering_Code__c = 'emailPlugin';
        custSetRec2.Product_Code__c = productToInsertList[1].ProductCode ;
        custSetRecordsList.add(custSetRec2);
        
        insert custSetRecordsList ;
        
        
        
        Utility.isAssetTriggerExecutedFromOppty  = true;
        //Insert Assets
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
        //    as1.Contract__c = contractList[0].Id;
        as1.Munchkin_ID__c = '1234-asd-124';
        as1.Acct_Prefix__c = 'TestTest1';
        as1.POD__c = 'sjint';
        assetList.add(as1);
        
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(2);
        as2.Opportunity__c = opptyList[0].Id;
        as2.Asset_Type__c='Instance';
        as2.purpose__c='Production';
        as2.Product2Id= productToInsertList[0].Id;
        as2.AccountId = accountsToInsertList[0].Id;
        as2.ContactId = ContactToInsert[0].id;
        as2.status = 'Active';
        as2.Munchkin_ID__c = '1234-asd-123';
        as2.Acct_Prefix__c = 'TestTest';
        as2.POD__c = 'sjint';
        assetList.add(as2);
        insert assetList;
        
        assetList[0].Munchkin_ID__c = null;
        assetList[0].Acct_Prefix__c = null;
        assetList[0].POD__c = null;
        assetList[0].status = 'Expired';
        update assetList[0];
  
        test.startTest();
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA  = true;
        
        // Create Quote     
        List<SBQQ__Quote__c> newQuotList=TestCPQUtilityClass.createQuotes(opptyList,1);
        insert newQuotList;
        
         // Insert Quote Lines
         list<SBQQ__QuoteLine__c> quoteLines=TestCPQUtilityClass.createQuoteLines(newQuotList,5,productToInsertList);
        
         
         for(SBQQ__QuoteLine__c QL :quoteLines){
             QL.Product_Family__c       = 'Bundle';
             QL.Product_Type__c         = 'Subscription';
             QL.Bundle_Name__c          = 'Consumer Marketing';
             
         }
         quoteLines[0].Bundle_Name__c = 'Email Marketing';
         insert quoteLines; 
       
        
        // create contracts 
        List<Contract> contractList = new List<Contract>();
         
         contractList=TestCPQUtilityClass.createContracts(accountsToInsertList, 2);
       
             for(Contract contr:contractList){
                
                   contr.SBQQ__Opportunity__c =newQuotList[0].SBQQ__Opportunity2__c;
                   contr.SBQQ__Quote__c =newQuotList[0].id;
               }
               
               contractList[1].SBQQ__Opportunity__c =newQuotList[1].SBQQ__Opportunity2__c;
              contractList[1].SBQQ__Quote__c =newQuotList[1].id;

        insert contractList;
         
        // create subscriptions
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234,SBQQ__Product__c =productToInsertList[0].Id);       
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[1].Id);
        subList.add(sub1);
        subList.add(sub2);
    
        insert subList;
        test.stopTest();
        List<Case> CaseList = new List<Case>();
        CaseList = TestCPQUtilityClass.createCases(opptyList,1);
        Map<String,Map<String,String>> adddropMap = new Map<String,Map<String,String>>();
        
        adddropMap.put('123',new map<string,string>{'a'=>'1','b'=>'3'});
        adddropMap.put('111',new map<string,string>{'c'=>'2','d'=>'3'});
        for(Case c :CaseList){
            c.Added_Products__c= 'accountBasedMarketing:10000.000,mobileEngagement:10000.000';
            c.Quantity_Change_on_Existing_Products__c = 'prod-base-dbsize:70000.000,workspacesAndPartitions:70000.000';
            c.Asset_Name__c='TestRubiks ProductionTest';
            c.Added_Dropped_QtyChange__c =JSON.serialize(adddropMap);
            c.Account_String__c = 'TestTest,TestTest1';
        }
        insert CaseList;
        
        list<id> provCaseId = new list<id>();
        
        for(case cs:CaseList){
           
               if(OppRenId.contains(cs.Opportunity__c)){
                   provCaseId.add(cs.id);
               }
            
        }
        system.debug('provCase========'+provCaseId);  
       system.assertEquals(provCaseId.size(),1);
        //Call processCases
        if(!provCaseId.isEmpty()){
            CaseAutoProvisioning.processCaseAutoProvisioningBatch(provCaseId);
        }
        
        
    }//End of test method testProcessCasesMultiInstace  
    
    //*************************************************
     public static testMethod void caseStatusTest(){
         
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA  = true;
        
        List<Account> accountsToInsertList = new List<Account>();
        map<id, id> AccToCont = new Map<id,id>();
        
        //Insert Accounts
        for(Account accnt: TestCPQUtilityClass.createAccounts(1)){
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = 'India';
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
            accnt.Acct_Prefix__c = 'testtest';
            //accnt.RecordTypeId = '01250000000ULb7AAG'; 
            accountsToInsertList.add(accnt);
        }
        //Marketo_Trigger_Management__c mktTrigger= new Marketo_Trigger_Management__c(Activate_Legacy_Triggers__c=true); 
        //insert mktTrigger;
        //SalesTriggersUtility.Settruevaluesfortest();
    
        insert accountsToInsertList;
      
        
        //Insert Contacts
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
        
        // Create custom pricebooks
        List<PriceBook2> pricebookList = new List<PriceBook2>();
        pricebookList =TestCPQUtilityClass.createCustomPriceBooks(5);
        insert pricebookList;
        
        // insert opportunities - for Closed Won Oppty - Contract will be created automatically
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities(accountsToInsertList,4);
        for(Opportunity opp : opptyList){
            opp.Rep_Create_ARR__c = 10000;
            opp.Amount = 2000;
            opp.Pricebook2Id = pricebookList[0].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.type ='Upsell/Crossell';
            opp.OwnerId=UserInfo.getUserId();
            if(AccToCont.containsKey(opp.AccountId)){
                opp.Primary_Marketo_User_Lookup__c = AccToCont.get(opp.AccountId) ;
                opp.Primary_Marketo_User_Email__c = 'test.abc@jade.com' ;
            }
        }
        
        test.startTest();
        
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA  = true;
        
        List<Case> CaseList = new List<Case>();
        CaseList = TestCPQUtilityClass.createCases(opptyList,1);
        Map<String,Map<String,String>> adddropMap = new Map<String,Map<String,String>>();
        
        adddropMap.put('123',new map<string,string>{'a'=>'1','b'=>'3'});
        adddropMap.put('111',new map<string,string>{'c'=>'2','d'=>'3'});
        for(Case c :CaseList){
            c.Added_Products__c= 'accountBasedMarketing:10000.000,mobileEngagement:10000.000';
            c.Quantity_Change_on_Existing_Products__c = 'prod-base-dbsize:70000.000,workspacesAndPartitions:70000.000';
            c.Asset_Name__c='TestRubiks ProductionTest';
            c.Added_Dropped_QtyChange__c =JSON.serialize(adddropMap);
            c.Account_String__c = 'TestTest,TestTest1';
        }
        insert CaseList;
        
        list<id> provCaseId = new list<id>();
        
        CaseAutoProvisioning.updateCase(new case(id=CaseList[0].id,Provision_Status__c=''),'Success');
        CaseAutoProvisioning.updateCase(new case(id=CaseList[1].id,Provision_Status__c=''),'Error');
        CaseAutoProvisioning.updateCase(new case(id=CaseList[2].id,Provision_Status__c=''),'SF Error');
        
        CaseAutoProvisioning.CaseIdWithProvisionStatus.put(CaseList[0].id,'Success');
        
        CaseAutoProvisioning.CaseIdWithProvisionStatus.put(CaseList[1].id,Label.Provisioning_Exception_Status);
         CaseAutoProvisioning.CaseIdWithProvisionStatus.put(CaseList[2].id,'SF Error');
        
        CaseAutoProvisioning.caseIdWithSPAParameters.put(CaseList[0].id,'Success');
         CaseAutoProvisioning.caseIdWithSPAParameters.put(CaseList[1].id,'Error');
         CaseAutoProvisioning.caseIdWithSPAParameters.put(CaseList[2].id,'SF Error');
        
        CaseAutoProvisioning.casemap.put(CaseList[0].id,new case(id=CaseList[0].id,SPA_Parameters__c='1 '));
        CaseAutoProvisioning.casemap.put(CaseList[1].id,new case(id=CaseList[1].id,SPA_Parameters__c='2 '));
       // CaseAutoProvisioning.casemap.put(CaseList[2].id,new case(id=CaseList[2].id,SPA_Parameters__c=null));
        CaseAutoProvisioning.updateCasesProvisioningStatus();
        test.stopTest();
        
    }//End of test method caseStatusTest
    
    
    public static testMethod void testProcessCasesMDQ(){
        
    SalesTriggersUtility.dlrs_ContractTrigger=true;
    SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
    SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
    SalesTriggersUtility.dlrs_AccountTrigger = true;
    SalesTriggersUtility.AssetTriggerVA  = true;
        
   List<Account> accountsToBeInsertedList = new List<Account>();
  accountsToBeInsertedList = TestCPQUtilityClass.createAccounts(1);
  
  insert accountsToBeInsertedList;
  
  
    
  List<Product2> productToInsertList = new List<Product2>();
  productToInsertList = TestCPQUtilityClass.createCustomProducts(3);
        productToInsertList[0].ProductCode ='PARENT';
        productToInsertList[1].ProductCode ='PROD-PLAT-SANDBOX';
        productToInsertList[2].ProductCode ='PROD-PLAT-SANDBOX-INST';
      
        if(!productToInsertList.isEmpty()){
            productToInsertList[0].Family ='Bundle';
            productToInsertList[1].name='Sandbox';
            productToInsertList[2].name='Sandbox Instance';
            insert productToInsertList;
        } 
        
          List<Product_SKU_Engineering_Code__c> custSetRecordsList = new List<Product_SKU_Engineering_Code__c>();
        
        // Create custSetRecords
        Product_SKU_Engineering_Code__c  custSetRec1 = new Product_SKU_Engineering_Code__c();
        custSetRec1.Name = 'custSetRec1';
        custSetRec1.Engineering_Code__c = 'accountBasedMarketing';
        custSetRec1 .Product_Code__c = 'PROD-PLAT-SANDBOX' ;
        custSetRec1.Quantity_Multiple__c=2;
        custSetRecordsList.add(custSetRec1);
        
        Product_SKU_Engineering_Code__c  custSetRec2 = new Product_SKU_Engineering_Code__c();
        custSetRec2.Name = 'custSetRec2';
        custSetRec2.Engineering_Code__c ='emailPlugin';
        custSetRec2.Product_Code__c = 'PROD-PLAT-SANDBOX-INST';
        custSetRec2.Quantity_Multiple__c=2;
        custSetRecordsList.add(custSetRec2);
        
         Product_SKU_Engineering_Code__c  custSetRec3 = new Product_SKU_Engineering_Code__c();
         
        custSetRec3.Name = 'custSetRec3';
        custSetRec3.Engineering_Code__c ='emailPlugin';
        custSetRec3.Product_Code__c = 'PARENT';
        custSetRec3.Quantity_Multiple__c=1;
        custSetRecordsList.add(custSetRec3);
        
        insert custSetRecordsList ;
 
  
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
        OpptyToBeInsertedList[0].Rep_Create_ARR__c         = 1;
  
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
  
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
              quote.Ship_To_Contact__c = null;
               quote.MDQ_Quote__c = true;
              
          }
          SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
          
  insert quotesToBeInsertedList;
   system.debug('quotesToBeInsertedList'+quotesToBeInsertedList);
       
        List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
     
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6),SBQQ__SegmentLabel__c='Seg1');
        
        
         SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c( SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6).addDays(1),SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__EndDate__c,SBQQ__SegmentLabel__c='Seg2'); 
         
         SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6),SBQQ__SegmentLabel__c='Seg1');
         
         SBQQ__QuoteLine__c quoteLine3 = new SBQQ__QuoteLine__c( SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6).addDays(1),SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__EndDate__c,SBQQ__SegmentLabel__c='Seg2');
         
         SBQQ__QuoteLine__c quoteLine4 = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=true,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[0].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6),SBQQ__SegmentLabel__c='Seg1');
          
       
        quoteLinesToInsert.add(quoteLine);
        quoteLinesToInsert.add(quoteLine1);
        quoteLinesToInsert.add(quoteLine2);
        quoteLinesToInsert.add(quoteLine3);
        quoteLinesToInsert.add(quoteLine4);
        
          
         SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
          
         insert quoteLinesToInsert;
         
         SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
         
        Test.StartTest();
        
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA  = true;
         
         system.debug('quoteLinesToInsert#######'+quoteLinesToInsert);
         List<ProductDetails__c> ProdDetailsList=new List<ProductDetails__c>();
         
          ProductDetails__c obj1 = new ProductDetails__c(Name='Sandbox',ID__c = productToInsertList[1].Id,Product_Code__c ='PROD-PLAT-SANDBOX');
            
            ProductDetails__c obj2 = new ProductDetails__c(Name='Sandbox Instance',ID__c = productToInsertList[2].Id,Product_Code__c = 'PROD-PLAT-SANDBOX-INST');
            
            ProdDetailsList.add(obj1);
             ProdDetailsList.add(obj2);
             insert ProdDetailsList;
                   
           List<OpportunityLineItem> OLIListToBeInserted=new List<OpportunityLineItem>();       
       
          
           OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[1].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[0].Id,Create_Asset__c=false,Segment_Start_Date__c=quoteLinesToInsert[0].SBQQ__StartDate__c);           
               
            OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[1].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[1].Id,Create_Asset__c=false,Segment_Start_Date__c=quoteLinesToInsert[1].SBQQ__StartDate__c.addMonths(6).addDays(1));
            
             OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[2].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[2].Id,Create_Asset__c=false,Segment_Start_Date__c=quoteLinesToInsert[2].SBQQ__StartDate__c);
             
             OpportunityLineItem oli4 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[2].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[3].Id,Create_Asset__c=false,Segment_Start_Date__c=quoteLinesToInsert[3].SBQQ__StartDate__c.addMonths(6).addDays(1));
              
             OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[0].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[4].Id,Create_Asset__c=false);
            
         
            OLIListToBeInserted.add(oli1);
            OLIListToBeInserted.add(oli2);
            OLIListToBeInserted.add(oli3);
            OLIListToBeInserted.add(oli4);
            OLIListToBeInserted.add(oli);
            
            SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
            
            if(!OLIListToBeInserted.isEmpty()){
            insert OLIListToBeInserted;
            }
            
            SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;   
        
            Map<Id,OpportunityLineItem> OLIMap=new Map<Id,OpportunityLineItem>();
            set<Id> OLIId=new set<Id>();
             if(!OLIListToBeInserted.isEmpty()){
            for(OpportunityLineItem o:OLIListToBeInserted){
                OLIId.add(o.id);
            }
            }   
            for(OpportunityLineItem O:OLIListToBeInserted){
                    OLIMap.put(O.Id,O);
             }      
            
           List<OpportunityLineItem> OL=[select id,SBQQ__QuoteLine__c,OpportunityId,unitprice,Create_Asset__c,Segment_Start_Date__c from OpportunityLineItem where ID IN :OLIId ];            
          
          for(OpportunityLineItem o:OL){
                o.Create_Asset__c=true;
            }
            
            if(!OL.isEmpty()){
                             
                update OL;
                
            }  
          
         // OpptyToBeInsertedList[0].StageName            = 'Closed Won';
          OpptyToBeInsertedList[0].SBQQ__Contracted__c=true;
          OpptyToBeInsertedList[0].SBQQ__PrimaryQuote__c=quotesToBeInsertedList[0].id;
          update OpptyToBeInsertedList;
          system.debug('OpptyToBeInsertedList Updated Opp'+OpptyToBeInsertedList);
      
          
        // Create Contract
        Contract contrct = new Contract(Name='Test Contract ',SBQQ__Quote__c=quotesToBeInsertedList[0].id, AccountId=accountsToBeInsertedList[0].Id, SBQQ__Opportunity__c =OpptyToBeInsertedList[0].Id, ContractTerm = 12, SBQQ__RenewalForecast__c = true, SBQQ__PreserveBundleStructureUponRenewals__c = true, SBQQ__DefaultRenewalContactRoles__c = true, SBQQ__DefaultRenewalPartners__c = true, StartDate=quotesToBeInsertedList.get(0).SBQQ__StartDate__c);
        insert contrct; 
        contrct.Status='Activated';
        update contrct;
        
       
        
        Utility.isAssetTriggerExecutedFromOppty  = true;
        //Insert Assets
        List<Asset> assetList = new List<Asset>();
        Asset as1 = new Asset();
        as1.Name = 'Test Asset 1';
        as1.installdate = System.today();
        as1.UsageEndDate = System.today().addMonths(2);
        as1.Opportunity__c = OpptyToBeInsertedList[0].Id;
        as1.Asset_Type__c='Instance';
        as1.purpose__c='Production';
        as1.Product2Id= productToInsertList[0].Id;
        as1.AccountId = accountsToBeInsertedList[0].Id;
        
        as1.status = 'Active';
        //    as1.Contract__c = contractList[0].Id;
        as1.Munchkin_ID__c = '1234-asd-124';
        as1.Acct_Prefix__c = 'TestTest1';
        as1.POD__c = 'sjint';
        assetList.add(as1);

     //   List<AssetHistory> AssetList1=[SELECT AssetId,Field,Id,IsDeleted,NewValue,OldValue, Asset.Acct_Prefix__c, Asset.Munchkin_ID__c FROM AssetHistory];
     //   system.debug('AssetList='+AssetList1);
     //   system.assertEquals(1,AssetList1.size());
        
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(2);
        as2.Opportunity__c = OpptyToBeInsertedList[0].Id;
        as2.Asset_Type__c='Instance';
        as2.purpose__c='Production';
        as2.Product2Id= productToInsertList[0].Id;
        as2.AccountId = accountsToBeInsertedList[0].Id;
        as2.status = 'Active';
        as2.Munchkin_ID__c = '1234-asd-123';
        as2.Acct_Prefix__c = 'TestTest';
        as2.POD__c = 'sjint';
        assetList.add(as2);
        insert assetList;
        
        assetList[0].Munchkin_ID__c = null;
        assetList[0].Acct_Prefix__c = null;
        assetList[0].POD__c = null;
        assetList[0].status = 'Expired';
        
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        
        update assetList[0];
  
           
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
    
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c();        
        sub1.SBQQ__Product__c = productToInsertList[1].Id;
        sub1.SBQQ__Account__c = accountsToBeInsertedList[0].Id;
        sub1.SBQQ__Quantity__c = 4.0;
        sub1.SBQQ__Contract__c=contrct.id;
        subList.add(sub1);
        
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c();        
        sub2.SBQQ__Product__c = productToInsertList[2].Id;
        sub2.SBQQ__Account__c = accountsToBeInsertedList[0].Id;
        sub2.SBQQ__Quantity__c = 4.0;
        sub2.SBQQ__Contract__c=contrct.id;
        subList.add(sub2);
        
        
        insert subList;
        
        List<Case> CaseList = new List<Case>();
        CaseList = TestCPQUtilityClass.createCases(OpptyToBeInsertedList,1);
        Map<String,Map<String,String>> adddropMap = new Map<String,Map<String,String>>();
        
        adddropMap.put('123',new map<string,string>{'a'=>'1','b'=>'3'});
        adddropMap.put('111',new map<string,string>{'c'=>'2','d'=>'3'});
        for(Case c :CaseList){
            c.Added_Products__c= 'accountBasedMarketing:10000.000,mobileEngagement:10000.000';
            c.Quantity_Change_on_Existing_Products__c = 'prod-base-dbsize:70000.000,workspacesAndPartitions:70000.000';
            c.Asset_Name__c='TestRubiks ProductionTest';
            c.Added_Dropped_QtyChange__c =JSON.serialize(adddropMap);
            c.Account_String__c = 'TestTest,TestTest1';
        }

        insert CaseList;
        
        
         list<id> provCaseId = new list<id>();
        set<id> OppRenId = new set<id>();
        
        for(Case c :CaseList){
            OppRenId.add(c.Opportunity__c);
        }
        for(case cs:CaseList){
           
               if(OppRenId.contains(cs.Opportunity__c)){
                   provCaseId.add(cs.id);
               }
            
        }
        system.debug('provCase========'+provCaseId);  
       system.assertEquals(provCaseId.size(),1);
        //Call processCases
          
        if(!provCaseId.isEmpty()){
            CaseAutoProvisioning.processCaseAutoProvisioningBatch(provCaseId);
        }
        test.stopTest();
    
    }
    
     public static testMethod void testProcessCasesBatch(){
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA  = true;
        
        List<Account> accountsToBeInsertedList = new List<Account>();
  accountsToBeInsertedList = TestCPQUtilityClass.createAccounts(1);
  
  insert accountsToBeInsertedList;
  
  
    
  List<Product2> productToInsertList = new List<Product2>();
  productToInsertList = TestCPQUtilityClass.createCustomProducts(3);
        productToInsertList[0].ProductCode ='PARENT';
        productToInsertList[1].ProductCode ='PROD-PLAT-SANDBOX';
        productToInsertList[2].ProductCode ='PROD-PLAT-SANDBOX-INST';
      
        if(!productToInsertList.isEmpty()){
            productToInsertList[0].Family ='Bundle';
            productToInsertList[1].name='Sandbox';
            productToInsertList[2].name='Sandbox Instance';
            insert productToInsertList;
        } 
        
          List<Product_SKU_Engineering_Code__c> custSetRecordsList = new List<Product_SKU_Engineering_Code__c>();
        
        // Create custSetRecords
        Product_SKU_Engineering_Code__c  custSetRec1 = new Product_SKU_Engineering_Code__c();
        custSetRec1.Name = 'custSetRec1';
        custSetRec1.Engineering_Code__c = 'accountBasedMarketing';
        custSetRec1 .Product_Code__c = 'PROD-PLAT-SANDBOX' ;
        custSetRec1.Quantity_Multiple__c=2;
        custSetRecordsList.add(custSetRec1);
        
        Product_SKU_Engineering_Code__c  custSetRec2 = new Product_SKU_Engineering_Code__c();
        custSetRec2.Name = 'custSetRec2';
        custSetRec2.Engineering_Code__c ='emailPlugin';
        custSetRec2.Product_Code__c = 'PROD-PLAT-SANDBOX-INST';
        custSetRec2.Quantity_Multiple__c=2;
        custSetRecordsList.add(custSetRec2);
        
         Product_SKU_Engineering_Code__c  custSetRec3 = new Product_SKU_Engineering_Code__c();
         
        custSetRec3.Name = 'custSetRec3';
        custSetRec3.Engineering_Code__c ='emailPlugin';
        custSetRec3.Product_Code__c = 'PARENT';
        custSetRec3.Quantity_Multiple__c=1;
        custSetRecordsList.add(custSetRec3);
        
        insert custSetRecordsList ;
 
  
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
        OpptyToBeInsertedList = TestCPQUtilityClass.createOpportunities(accountsToBeInsertedList,2);
        OpptyToBeInsertedList[0].StageName            = '3 - Solution Definition';
        OpptyToBeInsertedList[0].PriceBook2Id         = priceBookList[0].id;
        OpptyToBeInsertedList[0].Quarterly_Renewal__c = string.valueof(2);
        OpptyToBeInsertedList[0].type                 = 'New Business';
        OpptyToBeInsertedList[0].Deal_Type__c         = 'Standard';
        OpptyToBeInsertedList[0].Rep_Create_ARR__c         = 1;
  
          insert OpptyToBeInsertedList ;
          system.debug('OpptyToBeInsertedList '+OpptyToBeInsertedList );   
   
  

  List<SBQQ__Quote__c> quotesToBeInsertedList= new List<SBQQ__Quote__c>();
  quotesToBeInsertedList = TestCPQUtilityClass.createQuotes(OpptyToBeInsertedList,1);
  integer quoteflag=0;
   for(SBQQ__Quote__c quote : quotesToBeInsertedList){
              quote.SBQQ__Primary__c = true;
              quote.SBQQ__SubscriptionTerm__c=12;
              quote.Rubiks_Quote__c=true;
              quote.SBQQ__Opportunity2__c=OpptyToBeInsertedList[quoteflag].id;
              quote.SBQQ__StartDate__c=system.today();
              quote.SBQQ__PriceBook__c=priceBookList[0].id;
               quote.MDQ_Quote__c = true;
              quoteflag=1;
          }
  insert quotesToBeInsertedList;
   system.debug('quotesToBeInsertedList'+quotesToBeInsertedList);
       
        List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
     
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6),SBQQ__SegmentLabel__c='Seg1',Product_Family__c='Bundle',Product_Type__c='Subscription');
        
        
         SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c( SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6).addDays(1),SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__EndDate__c,SBQQ__SegmentLabel__c='Seg2',Product_Family__c='Bundle',Product_Type__c='Subscription'); 
         
         SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6),SBQQ__SegmentLabel__c='Seg1',Product_Family__c='Bundle',Product_Type__c='Subscription');
         
         SBQQ__QuoteLine__c quoteLine3 = new SBQQ__QuoteLine__c( SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6).addDays(1),SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__EndDate__c,SBQQ__SegmentLabel__c='Seg2');
         
         SBQQ__QuoteLine__c quoteLine4 = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=true,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[0].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6),SBQQ__SegmentLabel__c='Seg1');
          
       
        quoteLinesToInsert.add(quoteLine);
        quoteLinesToInsert.add(quoteLine1);
        quoteLinesToInsert.add(quoteLine2);
        quoteLinesToInsert.add(quoteLine3);
        quoteLinesToInsert.add(quoteLine4);
          Test.StartTest();
        // insert quoteLinesToInsert;
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA  = true;
         
         system.debug('quoteLinesToInsert#######'+quoteLinesToInsert);
         List<ProductDetails__c> ProdDetailsList=new List<ProductDetails__c>();
         
          ProductDetails__c obj1 = new ProductDetails__c(Name='Sandbox',ID__c = productToInsertList[1].Id,Product_Code__c ='PROD-PLAT-SANDBOX');
            
            ProductDetails__c obj2 = new ProductDetails__c(Name='Sandbox Instance',ID__c = productToInsertList[2].Id,Product_Code__c = 'PROD-PLAT-SANDBOX-INST');
            
            ProdDetailsList.add(obj1);
             ProdDetailsList.add(obj2);
             insert ProdDetailsList;
                   
           List<OpportunityLineItem> OLIListToBeInserted=new List<OpportunityLineItem>();       
       
          
           OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[1].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[0].Id,Create_Asset__c=false,Segment_Start_Date__c=quoteLinesToInsert[0].SBQQ__StartDate__c);           
               
            OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[1].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[1].Id,Create_Asset__c=false,Segment_Start_Date__c=quoteLinesToInsert[1].SBQQ__StartDate__c.addMonths(6).addDays(1));
            
             OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[2].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[2].Id,Create_Asset__c=false,Segment_Start_Date__c=quoteLinesToInsert[2].SBQQ__StartDate__c);
             
             OpportunityLineItem oli4 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[2].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[3].Id,Create_Asset__c=false,Segment_Start_Date__c=quoteLinesToInsert[3].SBQQ__StartDate__c.addMonths(6).addDays(1));
              
             OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[0].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[4].Id,Create_Asset__c=false);
            
         
            OLIListToBeInserted.add(oli1);
            OLIListToBeInserted.add(oli2);
            OLIListToBeInserted.add(oli3);
            OLIListToBeInserted.add(oli4);
            OLIListToBeInserted.add(oli);
            if(!OLIListToBeInserted.isEmpty()){
            insert OLIListToBeInserted;
            }
            
               
        
            Map<Id,OpportunityLineItem> OLIMap=new Map<Id,OpportunityLineItem>();
            set<Id> OLIId=new set<Id>();
             if(!OLIListToBeInserted.isEmpty()){
            for(OpportunityLineItem o:OLIListToBeInserted){
                OLIId.add(o.id);
            }
            }   
            for(OpportunityLineItem O:OLIListToBeInserted){
                    OLIMap.put(O.Id,O);
             }      
            
           List<OpportunityLineItem> OL=[select id,SBQQ__QuoteLine__c,OpportunityId,unitprice,Create_Asset__c,Segment_Start_Date__c from OpportunityLineItem where ID IN :OLIId ];            
          
          for(OpportunityLineItem o:OL){
                o.Create_Asset__c=true;
            }
            
            if(!OL.isEmpty()){
                             
                update OL;
                
            }  
          
         // OpptyToBeInsertedList[0].StageName            = 'Closed Won';
          OpptyToBeInsertedList[0].SBQQ__Contracted__c=true;
          OpptyToBeInsertedList[0].SBQQ__PrimaryQuote__c=quotesToBeInsertedList[0].id;
          OpptyToBeInsertedList[0].Prior_Opportunity__c = OpptyToBeInsertedList[1].id;
          OpptyToBeInsertedList[1].Ghost__c=True;
          update OpptyToBeInsertedList;
          system.debug('OpptyToBeInsertedList Updated Opp'+OpptyToBeInsertedList);
      
          
        // Create Contract
        Contract contrct = new Contract(Name='Test Contract ',SBQQ__Quote__c=quotesToBeInsertedList[0].id, AccountId=accountsToBeInsertedList[0].Id, SBQQ__Opportunity__c =OpptyToBeInsertedList[0].Id, ContractTerm = 12, SBQQ__RenewalForecast__c = true, SBQQ__PreserveBundleStructureUponRenewals__c = true, SBQQ__DefaultRenewalContactRoles__c = true, SBQQ__DefaultRenewalPartners__c = true, StartDate=quotesToBeInsertedList.get(0).SBQQ__StartDate__c);
        insert contrct; 
        contrct.Status='Activated';
        update contrct;
        
       
        
        Utility.isAssetTriggerExecutedFromOppty  = true;
        //Insert Assets
        List<Asset> assetList = new List<Asset>();
        Asset as1 = new Asset();
        as1.Name = 'Test Asset 1';
        as1.installdate = System.today();
        as1.UsageEndDate = System.today().addMonths(2);
        as1.Opportunity__c = OpptyToBeInsertedList[0].Id;
        as1.Asset_Type__c='Instance';
        as1.purpose__c='Production';
        as1.Product2Id= productToInsertList[0].Id;
        as1.AccountId = accountsToBeInsertedList[0].Id;
        
        as1.status = 'Active';
        //    as1.Contract__c = contractList[0].Id;
        as1.Munchkin_ID__c = '1234-asd-124';
        as1.Acct_Prefix__c = 'TestTest1';
        as1.POD__c = 'sjint';
        assetList.add(as1);

     //   List<AssetHistory> AssetList1=[SELECT AssetId,Field,Id,IsDeleted,NewValue,OldValue, Asset.Acct_Prefix__c, Asset.Munchkin_ID__c FROM AssetHistory];
     //   system.debug('AssetList='+AssetList1);
     //   system.assertEquals(1,AssetList1.size());
        
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(2);
        as2.Opportunity__c = OpptyToBeInsertedList[0].Id;
        as2.Asset_Type__c='Instance';
        as2.purpose__c='Production';
        as2.Product2Id= productToInsertList[0].Id;
        as2.AccountId = accountsToBeInsertedList[0].Id;
        as2.status = 'Active';
        as2.Munchkin_ID__c = '1234-asd-123';
        as2.Acct_Prefix__c = 'TestTest';
        as2.POD__c = 'sjint';
        assetList.add(as2);
        insert assetList;
        
        assetList[0].Munchkin_ID__c = null;
        assetList[0].Acct_Prefix__c = null;
        assetList[0].POD__c = null;
        assetList[0].status = 'Expired';
        update assetList[0];
  
           
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
    
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c();        
        sub1.SBQQ__Product__c = productToInsertList[1].Id;
        sub1.SBQQ__Account__c = accountsToBeInsertedList[0].Id;
        sub1.SBQQ__Quantity__c = 4.0;
        sub1.SBQQ__Contract__c=contrct.id;
        sub1.SBQQ__QuoteLine__c= quoteLine.id;
        subList.add(sub1);
        
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c();        
        sub2.SBQQ__Product__c = productToInsertList[2].Id;
        sub2.SBQQ__Account__c = accountsToBeInsertedList[0].Id;
        sub2.SBQQ__Quantity__c = 4.0;
        sub2.SBQQ__Contract__c=contrct.id;
        sub1.SBQQ__QuoteLine__c= quoteLine1.id;
        subList.add(sub2);
        
        
        insert subList;
        
        List<Case> CaseList = new List<Case>();
        CaseList = TestCPQUtilityClass.createCases(OpptyToBeInsertedList,1);
        Map<String,Map<String,String>> adddropMap = new Map<String,Map<String,String>>();
        
        adddropMap.put('123',new map<string,string>{'a'=>'1','b'=>'3'});
        adddropMap.put('111',new map<string,string>{'c'=>'2','d'=>'3'});
        for(Case c :CaseList){
            c.Added_Products__c= 'accountBasedMarketing:10000.000,mobileEngagement:10000.000';
            c.Quantity_Change_on_Existing_Products__c = 'prod-base-dbsize:70000.000,workspacesAndPartitions:70000.000';
            c.Asset_Name__c='TestRubiks ProductionTest';
            c.Added_Dropped_QtyChange__c =JSON.serialize(adddropMap);
            c.Account_String__c = 'TestTest';
            c.Send_Case_to_SPA__c = true;
            c.Segment_Index__c     =2;
        }
        //case newCase = CaseList[0].clone(false,true,false,false);
         //newCase.Account_String__c = 'TestTest,TestTest1,TestTest12';
         //CaseList.add(newCase);
        insert CaseList;
        
        
         list<id> provCaseId = new list<id>();
        set<id> OppRenId = new set<id>();
        
        for(Case c :CaseList){
            OppRenId.add(c.Opportunity__c);
        }
        for(case cs:CaseList){
           
               if(OppRenId.contains(cs.Opportunity__c)){
                   provCaseId.add(cs.id);
               }
            
        }
        system.debug('provCase========'+provCaseId);  
   //    system.assertEquals(provCaseId.size(),1);
        //Call processCases
        if(!provCaseId.isEmpty()){
            CaseAutoProvisioning.processCases();
        }
        test.stopTest();
    
    }//End of testProcessCasesBatch
    public static testMethod void testProcessCasesPhoneixGroup(){
        
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA = true;
        
        List<Account> accountsToInsertList = new List<Account>();
        map<id, id> AccToCont = new Map<id,id>();
        
        //Insert Accounts
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
            accnt.Acct_Prefix__c = 'testtest';
            //accnt.RecordTypeId = '01250000000ULb7AAG'; 
            accountsToInsertList.add(accnt);
        }

        insert accountsToInsertList;
      
        
        //Insert Contacts
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
        
        // Create custom pricebooks
        List<PriceBook2> pricebookList = new List<PriceBook2>();
        pricebookList =TestCPQUtilityClass.createCustomPriceBooks(5);
        insert pricebookList;
        
        Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
        Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
        Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
        Trigger_Opportunity_Helper.isAfterUpdateEvent = true;
        
        // insert opportunities - for Closed Won Oppty - Contract will be created automatically
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities(accountsToInsertList,4);
        for(Opportunity opp : opptyList){
            opp.Rep_Create_ARR__c = 10000;
            opp.Amount = 2000;
            opp.Pricebook2Id = pricebookList[0].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.type ='Upsell/Crossell';
            
            opp.OwnerId=UserInfo.getUserId();
            if(AccToCont.containsKey(opp.AccountId)){
                opp.Primary_Marketo_User_Lookup__c = AccToCont.get(opp.AccountId) ;
                opp.Primary_Marketo_User_Email__c = 'test.abc@jade.com' ;
            }
        }
        opptyList[0].Ghost__c=true;
        opptyList[0].type = 'New Business';
        opptyList[1].type = 'Renewal';
        
        //  opptyList[1].type = 'Upsell/Crossell';
        if(!opptyList.isEmpty()){
            insert opptyList;
        }
         
         set<id> OppRenId = new set<id>();
         for(Opportunity opp:opptyList){
             if(opp.type=='Renewal'){
                 OppRenId.add(opp.id);
             }
         }
        system.debug('opptyList='+opptyList);
        System.debug('opptyList[0].Accountid...'+opptyList[0].Accountid);
        
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
        productToInsertList[0].Product_Type__c = 'Subscription';
        insert productToInsertList;
        system.debug('---productToInsertList[0]---'+productToInsertList[0]);
        
        List<Product_SKU_Engineering_Code__c> custSetRecordsList = new List<Product_SKU_Engineering_Code__c>();
        
        Product_SKU_Engineering_Code__c  custSetRec1 = new Product_SKU_Engineering_Code__c();
        custSetRec1.Name = 'custSetRec1';
        custSetRec1.Engineering_Code__c = 'accountBasedMarketing';
        custSetRec1 .Product_Code__c = productToInsertList[0].ProductCode ;
        custSetRecordsList.add(custSetRec1);
        
        Product_SKU_Engineering_Code__c  custSetRec2 = new Product_SKU_Engineering_Code__c();
        custSetRec2.Name = 'custSetRec2';
        custSetRec2.Engineering_Code__c = 'emailPlugin';
        custSetRec2.Product_Code__c = productToInsertList[1].ProductCode ;
        custSetRecordsList.add(custSetRec2);
        
        insert custSetRecordsList ;
        
        Utility.isAssetTriggerExecutedFromOppty  = true;
        //Insert Assets
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
        //    as1.Contract__c = contractList[0].Id;
        as1.Munchkin_ID__c = '1234-asd-124';
        as1.Acct_Prefix__c = 'TestTest1';
        as1.POD__c = 'sjint';
        assetList.add(as1);

        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(2);
        as2.Opportunity__c = opptyList[0].Id;
        as2.Asset_Type__c='Instance';
        as2.purpose__c='Production';
        as2.Product2Id= productToInsertList[0].Id;
        as2.AccountId = accountsToInsertList[0].Id;
        as2.ContactId = ContactToInsert[0].id;
        as2.status = 'Active';
        as2.Munchkin_ID__c = '1234-asd-123';
        as2.Acct_Prefix__c = 'TestTest';
        as2.POD__c = 'sjint';
        assetList.add(as2);
        insert assetList;
        
        assetList[0].Munchkin_ID__c = null;
        assetList[0].Acct_Prefix__c = null;
        assetList[0].POD__c = null;
        assetList[0].status = 'Expired';
        update assetList[0];
  
        // Create Quote     
        List<SBQQ__Quote__c> newQuotList=TestCPQUtilityClass.createQuotes(opptyList,1);

        newQuotList[0].MDQ_Quote__c=true;
        newQuotList[0].Show_All_Bundles__c = True;
        newQuotList[1].MDQ_Quote__c=true;
        newQuotList[0].SBQQ__LineItemsGrouped__c = True;
        newQuotList[1].SBQQ__LineItemsGrouped__c = True;
        insert newQuotList;
        test.startTest();
        List<SBQQ__QuoteLineGroup__c> QuoteLineGrpList = new List<SBQQ__QuoteLineGroup__c>();
        QuoteLineGrpList = TestCPQUtilityClass.createQuoteLineGroup(newQuotList, 2);
        
        // create contracts 
        List<Contract> contractList = new List<Contract>();
         
         contractList=TestCPQUtilityClass.createContracts(accountsToInsertList, 2);
       
             for(Contract contr:contractList){
                
                   contr.SBQQ__Opportunity__c =newQuotList[0].SBQQ__Opportunity2__c;
                   contr.SBQQ__Quote__c =newQuotList[0].id;
               }
               
               contractList[1].SBQQ__Opportunity__c =newQuotList[1].SBQQ__Opportunity2__c;
              contractList[1].SBQQ__Quote__c =newQuotList[1].id;

        insert contractList;
         
        // create subscriptions
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234,SBQQ__Product__c =productToInsertList[0].Id);       
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[0].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productToInsertList[1].Id);
        subList.add(sub1);
        subList.add(sub2);
    
        insert subList;
        test.stopTest();
        
        Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
        Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
        Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
        Trigger_Opportunity_Helper.isAfterUpdateEvent = true;
        
         opptyList[0].Ghost__c=false;
         opptyList[0].Migration__c=false;
         opptyList[0].stagename='Closed Won';
         opptyList[1].Prior_Opportunity__c = opptyList[0].id;
         opptyList[2].Prior_Opportunity__c = opptyList[0].id;
         update opptyList;
       
         List<opportunity> OppList=[select id, name,isWon from opportunity where type = 'New Business'];

        List<Case> CaseList = new List<Case>();
        CaseList = TestCPQUtilityClass.createCases(opptyList,1);
        Map<String,Map<String,String>> adddropMap = new Map<String,Map<String,String>>();
        
        adddropMap.put('123',new map<string,string>{'a'=>'1','b'=>'3'});
        adddropMap.put('111',new map<string,string>{'c'=>'2','d'=>'3'});
        Id CaseRecordTypeid = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Provisioning Cases Record Type').getRecordTypeId();
        for(Case c :CaseList){
            c.Added_Products__c= 'accountBasedMarketing:10000.000,mobileEngagement:10000.000';
            c.Quantity_Change_on_Existing_Products__c = 'prod-base-dbsize:70000.000,workspacesAndPartitions:70000.000';
            c.Asset_Name__c='TestRubiks ProductionTest';
            c.Added_Dropped_QtyChange__c =JSON.serialize(adddropMap);
           // c.Account_String__c = 'TestTest,TestTest1';
            c.RecordTypeId=CaseRecordTypeid;
        }
        insert CaseList;
        
        list<id> provCaseId = new list<id>();
        
        for(case cs:CaseList){
           
               if(OppRenId.contains(cs.Opportunity__c)){
                   provCaseId.add(cs.id);
               }
            
        }
        system.debug('provCase========'+provCaseId);  
       system.assertEquals(provCaseId.size(),1);
        //Call processCases
        if(!provCaseId.isEmpty()){
            CaseAutoProvisioning.processCaseAutoProvisioningBatch(provCaseId);
        }
       
        
    }
}