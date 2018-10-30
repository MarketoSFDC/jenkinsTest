/**************************************************************

 Modified By :Jade Global 31th August 2018
 Change      : Removed closedWonRecordTypeId   variable from class
 ****************************************************************/
@IsTest(seeallData=True)
public class NEWCreateAssetsAndEntitlements_Test{


    public static testMethod void testCreateAE(){
        
        Product2 pr = new Product2();
        pr.Name='Moto - G1';
        pr.isActive=true;
        pr.ProductCode = 'LM-SAND';
        insert pr;
        NEWCreateAssetsAndEntitlements.getsandboxProductId();
          SalesTriggersUtility.dlrs_AccountTrigger = true;
         Account acc = new Account();
                        acc.Name                 = 'GRAZITTI TEST ACCOUNT 1';
                        acc.Sales_Region__c      = 'North America';
                        acc.Business_Unit__c     = 'AMER-SB';
                        acc.BillingCity          = 'NewYork';
                        acc.BillingCountry       = 'United States';
                        acc.BillingStreet        = 'Test Street';
                        acc.BillingState         = 'Test Billing State';
                        acc.BillingPostalCode    = '12345';
                        acc.ShippingCity         = 'Chandigarh';
                        acc.ShippingCountry      = 'India';
                        acc.ShippingPostalCode   = '12345';
                        acc.ShippingState        = '';
                        acc.ShippingStreet       = 'Test Shipping Street';
                        acc.Partner_Type__c      = 'Agency';
        insert acc;
        
        Contact con = new Contact();
                        con.FirstName = 'test';
                        con.LastName   = 'GRAZITTI TEST CONTACT 1';
                        con.email      = 'test@test.com';
                        con.LeadSource = 'Blog';
                        con.AccountId  = acc.Id;
        insert con;
        
        Intacct_Entity__c ie = new Intacct_Entity__c();
        ie.Name = 'marketo-emea';
        insert ie;
        Intacct_Entity__c ie2 = new Intacct_Entity__c();
        ie2.Name = 'marketo-us';
        insert ie2;
        
        
        Id stdPbId = Test.getStandardPricebookId();
        
        Opportunity opp = new Opportunity();
                            opp.Name      = 'GRAZITTI TEST OPPORTUNITY 1';
                            opp.AccountId = acc.Id;
                            opp.Type      = 'New Business';
                            opp.StageName = 'A - Qualify';
                            opp.Amount   = 10000;
                            opp.PriceBook2Id = stdPbId;
                            opp.Primary_Marketo_User_Lookup__c = con.Id;
                            opp.Economic_Decision_Maker__c = con.Id;
                            opp.Engagement_Manager__c = UserInfo.getUserId();
                            opp.SBQQ__Contracted__c = true;
                            opp.Intacct_Sales_Region__c = '';
                            opp.Owner_Role_Custom_Text__c = 'ANZ PS';
                            opp.Intacct_Entity__c = ie.Id;
                            opp.Rep_Create_ARR__c=1;
                            opp.MainCompetitor__c ='Act-On';
                            
                            opp.CloseDate = System.Now().Date();

        insert opp;
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opp.Id,SBQQ__Account__c= acc.Id, SBQQ__StartDate__c = System.Today());
        insert quote;
        
        // Create Products
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].Name = 'Enterprise Test2';
        prodList[1].Name = 'Enterprise Test3';
        prodList[2].Name = 'Enterprise Test4';
        prodList[3].Name = 'Enterprise Tes5';
        prodList[4].Name = 'Enterprise Test5';
        prodList[0].ConvertTo__c = 'Subscription';
        prodList[1].ConvertTo__c = 'Add On';
        prodList[2].ConvertTo__c = 'Entitlement-Premier';
        prodList[3].ConvertTo__c = 'Entitlement-Elite';
        prodList[4].ConvertTo__c = 'Entitlement';
        if(!prodList.isEmpty()){
            insert prodList;
        }
        
        // Create Custom Pricebooks
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(2);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }
        
        // Insert Products into Standard Pricebook
        List<PriceBookEntry> pbEntryStdPbList = new List<PriceBookEntry>();
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }
        SalesTriggersUtility.AssetTriggerVA  = true;
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = opp.Id;
        as2.Purpose__c = 'Production';
        as2.Asset_Type__c = 'Subscription';
        as2.AccountId = acc.Id;
        insert as2;
        Entitlement e2 = new Entitlement(Name = 'Test2',AssetId = as2.Id,AccountID = acc.ID,  StartDate =Date.TODAY(),Type ='Premium Education Catalog',Opportunity__c = opp.ID );
        insert e2;
        
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = opp.Id;
        oli1.PricebookEntryId = pbEntryStdPbList[0].Id;
        oli1.UnitPrice = 10;
        oli1.Related_Asset__c = as2.Id;
        oli1.Quantity = 20;
        
        insert oli1;
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = opp.Id;
        oli2.PricebookEntryId = pbEntryStdPbList[1].Id;
        oli2.UnitPrice = 10;
        oli2.Related_Asset__c = as2.Id;
        oli2.Quantity = 20;
      
        insert oli2;
        OpportunityLineItem oli3 = new OpportunityLineItem();
        oli3.OpportunityId = opp.Id;
        oli3.PricebookEntryId = pbEntryStdPbList[2].Id;
        oli3.UnitPrice = 10;
        oli3.Related_Asset__c = as2.Id;
        oli3.Quantity = 20;
       
        insert oli3;
        OpportunityLineItem oli4 = new OpportunityLineItem();
        oli4.OpportunityId = opp.Id;
        oli4.PricebookEntryId = pbEntryStdPbList[3].Id;
        oli4.UnitPrice = 10;
        oli4.Related_Asset__c = as2.Id;
        oli4.Quantity = 20;
       
        insert oli4;
        OpportunityLineItem oli5 = new OpportunityLineItem();
        oli5.OpportunityId = opp.Id;
        oli5.PricebookEntryId = pbEntryStdPbList[4].Id;
        oli5.UnitPrice = 10;
        oli5.Related_Asset__c = as2.Id;
        oli5.Quantity = 20;
       
        insert oli5;
        
        
        List<OpportunityLineItem> oliLists = new List<OpportunityLineItem>();
        oliLists.add(oli1);
        oliLists.add(oli2);
        oliLists.add(oli3);
        oliLists.add(oli4);
        oliLists.add(oli5);
        test.startTest();
        NEWCreateAssetsAndEntitlements.createAssetWithEntitlement(opp);
        NEWCreateAssetsAndEntitlements.createDefaultEntitlement();
        test.stopTest();
         
        
    }
    public static testMethod void testCreateAE2(){
        
        Product2 pr = new Product2();
        pr.Name='Moto - G1';
        pr.isActive=true;
        pr.ProductCode = 'LM-SAND';
        insert pr;
        NEWCreateAssetsAndEntitlements.getsandboxProductId();
          SalesTriggersUtility.dlrs_AccountTrigger = true;
          SalesTriggersUtility.AssetTriggerVA  = true;
         Account acc = new Account();
                        acc.Name                 = 'GRAZITTI TEST ACCOUNT 1';
                        acc.Sales_Region__c      = 'EMEA';
                        acc.Business_Unit__c     = 'AMER-SB';
                        acc.BillingCity          = 'NewYork';
                        acc.BillingCountry       = 'United States';
                        acc.BillingStreet        = 'Test Street';
                        acc.BillingState         = 'Test Billing State';
                        acc.BillingPostalCode    = '12345';
                        acc.ShippingCity         = 'Chandigarh';
                        acc.ShippingCountry      = 'India';
                        acc.ShippingPostalCode   = '12345';
                        acc.ShippingState        = '';
                        acc.ShippingStreet       = 'Test Shipping Street';
                        acc.Partner_Type__c      = 'Preferred Services';
        insert acc;
        
        Contact con = new Contact();
                        con.FirstName = 'test';
                        con.LastName   = 'GRAZITTI TEST CONTACT 1';
                        con.email      = 'test@test.com';
                        con.LeadSource = 'Blog';
                        con.AccountId  = acc.Id;
        insert con;
        
        Intacct_Entity__c ie = new Intacct_Entity__c();
        ie.Name = 'marketo-emea';
        insert ie;
        Intacct_Entity__c ie2 = new Intacct_Entity__c();
        ie2.Name = 'marketo-us';
        insert ie2;
        
        
        Id stdPbId = Test.getStandardPricebookId();
        
        Opportunity opp = new Opportunity();
                            opp.Name      = 'GRAZITTI TEST OPPORTUNITY 1';
                            opp.AccountId = acc.Id;
                            opp.Type      = 'New Business';
                            opp.StageName = 'A - Qualify';
                            opp.MainCompetitor__c ='Act-On';  
                            opp.Amount   = 10000;
                            opp.PriceBook2Id = stdPbId;
                            opp.Primary_Marketo_User_Lookup__c = con.Id;
                            opp.Economic_Decision_Maker__c = con.Id;
                            opp.Engagement_Manager__c = UserInfo.getUserId();
                            opp.SBQQ__Contracted__c = true;
                            opp.Intacct_Sales_Region__c = '';
                            opp.Owner_Role_Custom_Text__c = 'ANZ PS';
                            opp.Intacct_Entity__c = ie.Id;
                            opp.Rep_Create_ARR__c= 1;
                            
                            opp.CloseDate = System.Now().Date();

        insert opp;
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opp.Id,SBQQ__Account__c= acc.Id, SBQQ__StartDate__c = System.Today());
        insert quote;
        
        // Create Products
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].ProductCode = 'Add On';
        prodList[1].ConvertTo__c = 'Add On';
        prodList[2].ConvertTo__c = 'Add On';
        prodList[3].ConvertTo__c = 'Add On';
        prodList[4].ConvertTo__c = 'Add On';
        if(!prodList.isEmpty()){
            insert prodList;
        }
        
        // Create Custom Pricebooks
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(2);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }
        
        // Insert Products into Standard Pricebook
        List<PriceBookEntry> pbEntryStdPbList = new List<PriceBookEntry>();
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }
        SalesTriggersUtility.AssetTriggerVA  = true;
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = opp.Id;
        as2.Purpose__c = 'Production';
        as2.Asset_Type__c = 'Subscription';
        as2.AccountId = acc.Id;
        insert as2;
        Entitlement e2 = new Entitlement(Name = 'Test2',AssetId = as2.Id,AccountID = acc.ID,  StartDate =Date.TODAY(),Type ='Premium Education Catalog',Opportunity__c = opp.ID );
        insert e2;
        
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = opp.Id;
        oli1.PricebookEntryId = pbEntryStdPbList[0].Id;
        oli1.UnitPrice = 10;
        oli1.Quantity = 20;
     
        insert oli1;
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = opp.Id;
        oli2.PricebookEntryId = pbEntryStdPbList[1].Id;
        oli2.UnitPrice = 10;
        oli2.Quantity = 20;
        
        insert oli2;
        OpportunityLineItem oli3 = new OpportunityLineItem();
        oli3.OpportunityId = opp.Id;
        oli3.PricebookEntryId = pbEntryStdPbList[2].Id;
        oli3.UnitPrice = 10;
        oli3.Quantity = 20;
        
        insert oli3;
        OpportunityLineItem oli4 = new OpportunityLineItem();
        oli4.OpportunityId = opp.Id;
        oli4.PricebookEntryId = pbEntryStdPbList[3].Id;
        oli4.UnitPrice = 10;
        oli4.Quantity = 20;
      
        insert oli4;
        OpportunityLineItem oli5 = new OpportunityLineItem();
        oli5.OpportunityId = opp.Id;
        oli5.PricebookEntryId = pbEntryStdPbList[4].Id;
        oli5.UnitPrice = 10;
        oli5.Quantity = 20;
      
        insert oli5;
        
        
        List<OpportunityLineItem> oliLists = new List<OpportunityLineItem>();
        oliLists.add(oli1);
        oliLists.add(oli2);
        oliLists.add(oli3);
        oliLists.add(oli4);
        oliLists.add(oli5);
        test.startTest();
        NEWCreateAssetsAndEntitlements.createAssetWithEntitlement(opp);   
        NEWCreateAssetsAndEntitlements.createDefaultEntitlement();
        test.stopTest();
    }
    public static testMethod void testCreateAE3(){
        
        Product2 pr = new Product2();
        pr.Name='Moto - G1';
        pr.isActive=true;
        pr.ProductCode = 'LM-SAND';
        insert pr;
        NEWCreateAssetsAndEntitlements.getsandboxProductId();
          SalesTriggersUtility.dlrs_AccountTrigger = true;
         Account acc = new Account();
                        acc.Name                 = 'GRAZITTI TEST ACCOUNT 1';
                        acc.Sales_Region__c      = 'Other';
                        acc.Business_Unit__c     = 'AMER-SB';
                        acc.BillingCity          = 'NewYork';
                        acc.BillingCountry       = 'United States';
                        acc.BillingStreet        = 'Test Street';
                        acc.BillingState         = 'Test Billing State';
                        acc.BillingPostalCode    = '12345';
                        acc.ShippingCity         = 'Chandigarh';
                        acc.ShippingCountry      = 'India';
                        acc.ShippingPostalCode   = '12345';
                        acc.ShippingState        = '';
                        acc.ShippingStreet       = 'Test Shipping Street';
        insert acc;
        
        Contact con = new Contact();
                        con.FirstName  = 'Test';
                        con.LastName   = 'GRAZITTI TEST CONTACT 1';
                        con.email      = 'test@test.com';
                        con.LeadSource = 'Blog';
                        con.AccountId  = acc.Id;
        insert con;
        
        Intacct_Entity__c ie = new Intacct_Entity__c();
        ie.Name = 'marketo-emea';
        insert ie;
        Intacct_Entity__c ie2 = new Intacct_Entity__c();
        ie2.Name = 'marketo-us';
        insert ie2;
        
        
        Id stdPbId = Test.getStandardPricebookId();
        
        Opportunity opp = new Opportunity();
                            opp.Name      = 'GRAZITTI TEST OPPORTUNITY 1';
                            opp.AccountId = acc.Id;
                            opp.Type      = 'New Business';
                            opp.StageName = 'A - Qualify';
                            opp.Amount   = 10000;
                            opp.PriceBook2Id = stdPbId;
                            opp.Primary_Marketo_User_Lookup__c = con.Id;
                            opp.MainCompetitor__c = 'Act-On';  
                            opp.Economic_Decision_Maker__c = con.Id;
                            opp.Engagement_Manager__c = UserInfo.getUserId();
                            opp.SBQQ__Contracted__c = true;
                            opp.Intacct_Sales_Region__c = '';
                            opp.Owner_Role_Custom_Text__c = 'ANZ PS';
                            opp.Intacct_Entity__c = ie.Id;
                            opp.Rep_Create_ARR__c=1;
                            
                            opp.CloseDate = System.Now().Date();

        insert opp;
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opp.Id,SBQQ__Account__c= acc.Id, SBQQ__StartDate__c = System.Today());
        insert quote;
        
        // Create Products
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].Name = 'Enterprise Test2';
        prodList[1].Name = 'Enterprise Test3';
        prodList[2].Name = 'Enterprise Test4';
        prodList[3].Name = 'Enterprise Tes5';
        prodList[4].Name = 'Enterprise Test5';
        prodList[0].ProductCode = 'TEst Code';
        prodList[1].ConvertTo__c = 'Entitlement-Business';
        prodList[2].ConvertTo__c = 'Entitlement-Premier';
        prodList[3].ConvertTo__c = 'Entitlement-Elite';
        prodList[4].ConvertTo__c = 'Entitlement';
        if(!prodList.isEmpty()){
            insert prodList;
        }
        
        // Create Custom Pricebooks
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(2);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }
        
        // Insert Products into Standard Pricebook
        List<PriceBookEntry> pbEntryStdPbList = new List<PriceBookEntry>();
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }
        SalesTriggersUtility.AssetTriggerVA  = true;
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = opp.Id;
        as2.Purpose__c = 'Production';
        as2.Asset_Type__c = 'Subscription';
        as2.AccountId = acc.Id;
        insert as2;
        Entitlement e2 = new Entitlement(Name = 'Test2',AssetId = as2.Id ,AccountID = acc.ID,Product_ID__c = prodList[1].Id ,  StartDate =Date.TODAY(),Type ='Premium Education Catalog',Opportunity__c = opp.ID );
        insert e2;
        
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = opp.Id;
        oli1.PricebookEntryId = pbEntryStdPbList[0].Id;
        oli1.UnitPrice = 10;
        oli1.Quantity = 20;
        
        insert oli1;
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = opp.Id;
        oli2.PricebookEntryId = pbEntryStdPbList[1].Id;
        oli2.UnitPrice = 10;
        oli2.Quantity = 20;
       
        insert oli2;
        OpportunityLineItem oli3 = new OpportunityLineItem();
        oli3.OpportunityId = opp.Id;
        oli3.PricebookEntryId = pbEntryStdPbList[2].Id;
        oli3.UnitPrice = 10;
        oli3.Quantity = 20;
   
        insert oli3;
        OpportunityLineItem oli4 = new OpportunityLineItem();
        oli4.OpportunityId = opp.Id;
        oli4.PricebookEntryId = pbEntryStdPbList[3].Id;
        oli4.UnitPrice = 10;
        oli4.Quantity = 20;
  
        insert oli4;
        OpportunityLineItem oli5 = new OpportunityLineItem();
        oli5.OpportunityId = opp.Id;
        oli5.PricebookEntryId = pbEntryStdPbList[4].Id;
        oli5.UnitPrice = 10;
        oli5.Quantity = 20;
        
        insert oli5;
        
        
        List<OpportunityLineItem> oliLists = new List<OpportunityLineItem>();
        oliLists.add(oli1);
        oliLists.add(oli2);
        oliLists.add(oli3);
        oliLists.add(oli4);
        oliLists.add(oli5);
        test.startTest();
        NEWCreateAssetsAndEntitlements.createAssetWithEntitlement(opp);
        NEWCreateAssetsAndEntitlements.createDefaultEntitlement();
        test.stopTest();
         
        
    }
        public static testMethod void testCreateAE4(){
        
        Product2 pr = new Product2();
        pr.Name='Moto - G1';
        pr.isActive=true;
        pr.ProductCode = 'LM-SAND';
        insert pr;
        NEWCreateAssetsAndEntitlements.getsandboxProductId();
          SalesTriggersUtility.dlrs_AccountTrigger = true;
         Account acc = new Account();
                        acc.Name                 = 'GRAZITTI TEST ACCOUNT 1';
                        //acc.Sales_Region__c      = 'North America';
                        acc.Business_Unit__c     = 'AMER-SB';
                        acc.BillingCity          = 'NewYork';
                        acc.BillingCountry       = 'United States';
                        acc.BillingStreet        = 'Test Street';
                        acc.BillingState         = 'Test Billing State';
                        acc.BillingPostalCode    = '12345';
                        acc.ShippingCity         = 'Chandigarh';
                        acc.ShippingCountry      = 'India';
                        acc.ShippingPostalCode   = '12345';
                        acc.ShippingState        = '';
                        acc.ShippingStreet       = 'Test Shipping Street';
                        acc.Partner_Type__c      = 'Agency';
        insert acc;
        
        Contact con = new Contact();
                        con.FirstName  = 'test';
                        con.LastName   = 'GRAZITTI TEST CONTACT 1';
                        con.email      = 'test@test.com';
                        con.LeadSource = 'Blog';
                        con.AccountId  = acc.Id;
        insert con;
        
        Intacct_Entity__c ie = new Intacct_Entity__c();
        ie.Name = 'marketo-emea';
        insert ie;
        Intacct_Entity__c ie2 = new Intacct_Entity__c();
        ie2.Name = 'marketo-us';
        insert ie2;
        
        
        Id stdPbId = Test.getStandardPricebookId();
        
        Opportunity opp = new Opportunity();
                            opp.Name      = 'GRAZITTI TEST OPPORTUNITY 1';
                            opp.AccountId = acc.Id;
                            opp.Type      = 'New Business';
                            opp.StageName = 'A - Qualify';
                            opp.Amount   = 10000;
                            opp.PriceBook2Id = stdPbId;
                            opp.MainCompetitor__c = 'Act-On';
                            opp.Primary_Marketo_User_Lookup__c = con.Id;
                            opp.Economic_Decision_Maker__c = con.Id;
                            opp.Engagement_Manager__c = UserInfo.getUserId();
                            opp.SBQQ__Contracted__c = true;
                            opp.Intacct_Sales_Region__c = '';
                            opp.Owner_Role_Custom_Text__c = 'ANZ PS';
                            opp.Intacct_Entity__c = ie.Id;
                            opp.Rep_Create_ARR__c=1;
                            
                            opp.CloseDate = System.Now().Date();

        insert opp;
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opp.Id,SBQQ__Account__c= acc.Id, SBQQ__StartDate__c = System.Today());
        insert quote;
        
        // Create Products
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].Name = 'Enterprise Test2';
        prodList[1].Name = 'Enterprise Test3';
        prodList[2].Name = 'Enterprise Test4';
        prodList[3].Name = 'Enterprise Tes5';
        prodList[4].Name = 'Enterprise Test5';
        prodList[0].ConvertTo__c = 'Subscription';
        prodList[1].ConvertTo__c = 'Add On';
        prodList[2].ConvertTo__c = 'Entitlement-Premier';
        prodList[3].ConvertTo__c = 'Entitlement-Elite';
        prodList[4].ConvertTo__c = 'Entitlement';
        if(!prodList.isEmpty()){
            insert prodList;
        }
        
        // Create Custom Pricebooks
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(2);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }
        
        // Insert Products into Standard Pricebook
        List<PriceBookEntry> pbEntryStdPbList = new List<PriceBookEntry>();
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }
        SalesTriggersUtility.AssetTriggerVA  = true;
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = opp.Id;
        as2.Purpose__c = 'Production';
        as2.Asset_Type__c = 'Subscription';
        as2.AccountId = acc.Id;
        insert as2;
        Entitlement e2 = new Entitlement(Name = 'Test2',AssetId = as2.Id,AccountID = acc.ID,  StartDate =Date.TODAY(),Type ='Premium Education Catalog',Opportunity__c = opp.ID );
        insert e2;
        
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = opp.Id;
        oli1.PricebookEntryId = pbEntryStdPbList[0].Id;
        oli1.UnitPrice = 10;
        oli1.Quantity = 20;
        
        insert oli1;
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = opp.Id;
        oli2.PricebookEntryId = pbEntryStdPbList[1].Id;
        oli2.UnitPrice = 10;
        oli2.Quantity = 20;
       
        insert oli2;
        OpportunityLineItem oli3 = new OpportunityLineItem();
        oli3.OpportunityId = opp.Id;
        oli3.PricebookEntryId = pbEntryStdPbList[2].Id;
        oli3.UnitPrice = 10;
        oli3.Quantity = 20;
        
        insert oli3;
        OpportunityLineItem oli4 = new OpportunityLineItem();
        oli4.OpportunityId = opp.Id;
        oli4.PricebookEntryId = pbEntryStdPbList[3].Id;
        oli4.UnitPrice = 10;
        oli4.Quantity = 20;
        
        insert oli4;
        OpportunityLineItem oli5 = new OpportunityLineItem();
        oli5.OpportunityId = opp.Id;
        oli5.PricebookEntryId = pbEntryStdPbList[4].Id;
        oli5.UnitPrice = 10;
        oli5.Quantity = 20;
        
        insert oli5;
        
        
        List<OpportunityLineItem> oliLists = new List<OpportunityLineItem>();
        oliLists.add(oli1);
        oliLists.add(oli2);
        oliLists.add(oli3);
        oliLists.add(oli4);
        oliLists.add(oli5);
        test.startTest();
        NEWCreateAssetsAndEntitlements.createAssetWithEntitlement(opp);
        NEWCreateAssetsAndEntitlements.createDefaultEntitlement();
        test.stopTest();
    }
            public static testMethod void testCreateAE5(){
        
        Product2 pr = new Product2();
        pr.Name='Moto - G1';
        pr.isActive=true;
        pr.ProductCode = 'LM-SAND';
        insert pr;
        NEWCreateAssetsAndEntitlements.getsandboxProductId();
          SalesTriggersUtility.dlrs_AccountTrigger = true;
         Account acc = new Account();
                        acc.Name                 = 'GRAZITTI TEST ACCOUNT 1';
                        acc.Sales_Region__c      = 'North America';
                        acc.Business_Unit__c     = 'AMER-SB';
                        acc.BillingCity          = 'NewYork';
                        acc.BillingCountry       = 'United States';
                        acc.BillingStreet        = 'Test Street';
                        acc.BillingState         = 'Test Billing State';
                        acc.BillingPostalCode    = '12345';
                        acc.ShippingCity         = 'Chandigarh';
                        acc.ShippingCountry      = 'India';
                        acc.ShippingPostalCode   = '12345';
                        acc.ShippingState        = '';
                        acc.ShippingStreet       = 'Test Shipping Street';
                        acc.Partner_Type__c      = 'Preferred Services';
        insert acc;
        
        Contact con = new Contact();
                        con.FirstName  = 'test';
                        con.LastName   = 'GRAZITTI TEST CONTACT 1';
                        con.email      = 'test@test.com';
                        con.LeadSource = 'Blog';
                        con.AccountId  = acc.Id;
        insert con;
        
        Intacct_Entity__c ie = new Intacct_Entity__c();
        ie.Name = 'marketo-emea';
        insert ie;
        Intacct_Entity__c ie2 = new Intacct_Entity__c();
        ie2.Name = 'marketo-us';
        insert ie2;
        
        
        Id stdPbId = Test.getStandardPricebookId();
        
        Opportunity opp = new Opportunity();
                            opp.Name      = 'GRAZITTI TEST OPPORTUNITY 1';
                            opp.AccountId = acc.Id;
                            opp.Type      = 'New Business';
                            opp.StageName = 'A - Qualify';
                            opp.Amount   = 10000;
                            opp.PriceBook2Id = stdPbId;
                            opp.MainCompetitor__c = 'Act-On';
                            opp.Primary_Marketo_User_Lookup__c = con.Id;
                            opp.Economic_Decision_Maker__c = con.Id;
                            opp.Engagement_Manager__c = UserInfo.getUserId();
                            opp.SBQQ__Contracted__c = true;
                            opp.Intacct_Sales_Region__c = '';
                            opp.Owner_Role_Custom_Text__c = 'ANZ PS';
                            opp.Intacct_Entity__c = ie.Id;
                            opp.Rep_Create_ARR__c=1;
                            
                            opp.CloseDate = System.Now().Date();

        insert opp;
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opp.Id,SBQQ__Account__c= acc.Id, SBQQ__StartDate__c = System.Today());
        insert quote;
        
        // Create Products
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].Name = 'Enterprise Test2';
        prodList[1].Name = 'Enterprise Test3';
        prodList[2].Name = 'Enterprise Test4';
        prodList[3].Name = 'Enterprise Tes5';
        prodList[4].Name = 'Enterprise Test5';
        prodList[0].ConvertTo__c = 'Subscription';
        prodList[1].ConvertTo__c = 'Add On';
        prodList[2].ConvertTo__c = 'Entitlement-Premier';
        prodList[3].ConvertTo__c = 'Entitlement-Elite';
        prodList[4].ConvertTo__c = 'Entitlement';
        if(!prodList.isEmpty()){
            insert prodList;
        }
        
        // Create Custom Pricebooks
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(2);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }
        
        // Insert Products into Standard Pricebook
        List<PriceBookEntry> pbEntryStdPbList = new List<PriceBookEntry>();
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }
        SalesTriggersUtility.AssetTriggerVA  = true;
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = opp.Id;
        as2.Purpose__c = 'Production';
        as2.Asset_Type__c = 'Subscription';
        as2.AccountId = acc.Id;
        insert as2;
        Entitlement e2 = new Entitlement(Name = 'Test2',AssetId = as2.Id,AccountID = acc.ID,  StartDate =Date.TODAY(),Type ='Premium Education Catalog',Opportunity__c = opp.ID );
        insert e2;
        
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = opp.Id;
        oli1.PricebookEntryId = pbEntryStdPbList[0].Id;
        oli1.UnitPrice = 10;
        oli1.Quantity = 20;
       
        insert oli1;
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = opp.Id;
        oli2.PricebookEntryId = pbEntryStdPbList[1].Id;
        oli2.UnitPrice = 10;
        oli2.Quantity = 20;
        
        insert oli2;
        OpportunityLineItem oli3 = new OpportunityLineItem();
        oli3.OpportunityId = opp.Id;
        oli3.PricebookEntryId = pbEntryStdPbList[2].Id;
        oli3.UnitPrice = 10;
        oli3.Quantity = 20;
      
        insert oli3;
        OpportunityLineItem oli4 = new OpportunityLineItem();
        oli4.OpportunityId = opp.Id;
        oli4.PricebookEntryId = pbEntryStdPbList[3].Id;
        oli4.UnitPrice = 10;
        oli4.Quantity = 20;
       
        insert oli4;
        OpportunityLineItem oli5 = new OpportunityLineItem();
        oli5.OpportunityId = opp.Id;
        oli5.PricebookEntryId = pbEntryStdPbList[4].Id;
        oli5.UnitPrice = 10;
        oli5.Quantity = 20;
      
        insert oli5;
        
        
        List<OpportunityLineItem> oliLists = new List<OpportunityLineItem>();
        oliLists.add(oli1);
        oliLists.add(oli2);
        oliLists.add(oli3);
        oliLists.add(oli4);
        oliLists.add(oli5);
        test.startTest();
        NEWCreateAssetsAndEntitlements.createAssetWithEntitlement(opp);
        NEWCreateAssetsAndEntitlements.createDefaultEntitlement();
        test.stopTest();
    }
     public static testMethod void testCreateAE6(){
        
        Product2 pr = new Product2();
        pr.Name='Moto - G1';
        pr.isActive=true;
        pr.ProductCode = 'LM-SAND';
        insert pr;
        NEWCreateAssetsAndEntitlements.getsandboxProductId();
          SalesTriggersUtility.dlrs_AccountTrigger = true;
         Account acc = new Account();
                        acc.Name                 = 'GRAZITTI TEST ACCOUNT 1';
                        acc.Sales_Region__c      = 'North America';
                        acc.Business_Unit__c     = 'AMER-SB';
                        acc.BillingCity          = 'NewYork';
                        acc.BillingCountry       = 'United States';
                        acc.BillingStreet        = 'Test Street';
                        acc.BillingState         = 'Test Billing State';
                        acc.BillingPostalCode    = '12345';
                        acc.ShippingCity         = 'Chandigarh';
                        acc.ShippingCountry      = 'India';
                        acc.ShippingPostalCode   = '12345';
                        acc.ShippingState        = '';
                        acc.ShippingStreet       = 'Test Shipping Street';
                        acc.Partner_Type__c      = 'Reseller';
        insert acc;
        
        Contact con = new Contact();
                        con.FirstName = 'test';
                        con.LastName   = 'GRAZITTI TEST CONTACT 1';
                        con.email      = 'test@test.com';
                        con.LeadSource = 'Blog';
                        con.AccountId  = acc.Id;
        insert con;
        
        Intacct_Entity__c ie = new Intacct_Entity__c();
        ie.Name = 'marketo-emea';
        insert ie;
        Intacct_Entity__c ie2 = new Intacct_Entity__c();
        ie2.Name = 'marketo-us';
        insert ie2;
        
        
        Id stdPbId = Test.getStandardPricebookId();
        
        Opportunity opp = new Opportunity();
                            opp.Name      = 'GRAZITTI TEST OPPORTUNITY 1';
                            opp.AccountId = acc.Id;
                            opp.Type      = 'New Business';
                            opp.StageName = 'A - Qualify';
                            opp.Amount   = 10000;
                            opp.MainCompetitor__c = 'Act-On';
                            opp.PriceBook2Id = stdPbId;
                            opp.Primary_Marketo_User_Lookup__c = con.Id;
                            opp.Economic_Decision_Maker__c = con.Id;
                            opp.Engagement_Manager__c = UserInfo.getUserId();
                            opp.SBQQ__Contracted__c = true;
                            opp.Intacct_Sales_Region__c = '';
                            opp.Owner_Role_Custom_Text__c = 'ANZ PS';
                            opp.Intacct_Entity__c = ie.Id;
                            opp.Rep_Create_ARR__c=1;
                           
                            opp.CloseDate = System.Now().Date();

        insert opp;
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opp.Id,SBQQ__Account__c= acc.Id, SBQQ__StartDate__c = System.Today());
        insert quote;
        
        // Create Products
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].Name = 'Enterprise Test2';
        prodList[1].Name = 'Enterprise Test3';
        prodList[2].Name = 'Enterprise Test4';
        prodList[3].Name = 'Enterprise Tes5';
        prodList[4].Name = 'Enterprise Test5';
        prodList[0].ConvertTo__c = 'Subscription';
        prodList[1].ConvertTo__c = 'Add On';
        prodList[2].ConvertTo__c = 'Entitlement-Premier';
        prodList[3].ConvertTo__c = 'Entitlement-Elite';
        prodList[4].ConvertTo__c = 'Entitlement';
        if(!prodList.isEmpty()){
            insert prodList;
        }
        
        // Create Custom Pricebooks
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(2);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }
        
        // Insert Products into Standard Pricebook
        List<PriceBookEntry> pbEntryStdPbList = new List<PriceBookEntry>();
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }
        SalesTriggersUtility.AssetTriggerVA  = true;
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = opp.Id;
        as2.Purpose__c = 'Production';
        as2.Asset_Type__c = 'Subscription';
        as2.AccountId = acc.Id;
        insert as2;
        Entitlement e2 = new Entitlement(Name = 'Test2',AssetId = as2.Id,AccountID = acc.ID,  StartDate =Date.TODAY(),Type ='Premium Education Catalog',Opportunity__c = opp.ID );
        insert e2;
        
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = opp.Id;
        oli1.PricebookEntryId = pbEntryStdPbList[0].Id;
        oli1.UnitPrice = 10;
        oli1.Quantity = 20;
       
        insert oli1;
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = opp.Id;
        oli2.PricebookEntryId = pbEntryStdPbList[1].Id;
        oli2.UnitPrice = 10;
        oli2.Quantity = 20;
    
        insert oli2;
        OpportunityLineItem oli3 = new OpportunityLineItem();
        oli3.OpportunityId = opp.Id;
        oli3.PricebookEntryId = pbEntryStdPbList[2].Id;
        oli3.UnitPrice = 10;
        oli3.Quantity = 20;
    
        insert oli3;
        OpportunityLineItem oli4 = new OpportunityLineItem();
        oli4.OpportunityId = opp.Id;
        oli4.PricebookEntryId = pbEntryStdPbList[3].Id;
        oli4.UnitPrice = 10;
        oli4.Quantity = 20;
       
        insert oli4;
        OpportunityLineItem oli5 = new OpportunityLineItem();
        oli5.OpportunityId = opp.Id;
        oli5.PricebookEntryId = pbEntryStdPbList[4].Id;
        oli5.UnitPrice = 10;
        oli5.Quantity = 20;
       
        insert oli5;
        
        
        List<OpportunityLineItem> oliLists = new List<OpportunityLineItem>();
        oliLists.add(oli1);
        oliLists.add(oli2);
        oliLists.add(oli3);
        oliLists.add(oli4);
        oliLists.add(oli5);
        test.startTest();
        NEWCreateAssetsAndEntitlements.createAssetWithEntitlement(opp);
        NEWCreateAssetsAndEntitlements.createDefaultEntitlement();
        test.stopTest();
    }
    public static testMethod void testCreateAE7(){
        
        Product2 pr = new Product2();
        pr.Name='Moto - G1';
        pr.isActive=true;
        pr.ProductCode = 'LM-SAND';
        insert pr;
        NEWCreateAssetsAndEntitlements.getsandboxProductId();
          SalesTriggersUtility.dlrs_AccountTrigger = true;
         Account acc = new Account();
                        acc.Name                 = 'GRAZITTI TEST ACCOUNT 1';
                        acc.Sales_Region__c      = 'ANZ';
                        acc.BillingCity          = 'Sydney';
                        acc.BillingCountry       = 'Australia';
                        acc.BillingStreet        = 'Test Street';
                        acc.BillingState         = 'Test Billing State';
                        acc.BillingPostalCode    = '12345';
                        acc.ShippingCity         = 'Chandigarh';
                        acc.ShippingCountry      = 'India';
                        acc.ShippingPostalCode   = '12345';
                        acc.ShippingState        = '';
                        acc.ShippingStreet       = 'Test Shipping Street';
                        acc.Partner_Type__c      = 'Reseller';
        insert acc;
        
        Contact con = new Contact();
                        con.FirstName = 'test';
                        con.LastName   = 'GRAZITTI TEST CONTACT 1';
                        con.email      = 'test@test.com';
                        con.LeadSource = 'Blog';
                        con.AccountId  = acc.Id;
        insert con;
        
        Intacct_Entity__c ie = new Intacct_Entity__c();
        ie.Name = 'marketo-emea';
        insert ie;
        Intacct_Entity__c ie2 = new Intacct_Entity__c();
        ie2.Name = 'marketo-us';
        insert ie2;
        
        
        Id stdPbId = Test.getStandardPricebookId();
        
        Opportunity opp = new Opportunity();
                            opp.Name      = 'GRAZITTI TEST OPPORTUNITY 1';
                            opp.AccountId = acc.Id;
                            opp.Type      = 'New Business';
                            opp.StageName = 'A - Qualify';
                            opp.Amount   = 10000;
                            opp.MainCompetitor__c = 'Act-On';
                            opp.PriceBook2Id = stdPbId;
                            opp.Primary_Marketo_User_Lookup__c = con.Id;
                            opp.Economic_Decision_Maker__c = con.Id;
                            opp.Engagement_Manager__c = UserInfo.getUserId();
                            opp.SBQQ__Contracted__c = true;
                            opp.Intacct_Sales_Region__c = '';
                            opp.Owner_Role_Custom_Text__c = 'ANZ PS';
                            opp.Intacct_Entity__c = ie.Id;
                            opp.Rep_Create_ARR__c=1;
                            
                            opp.CloseDate = System.Now().Date();

        insert opp;
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opp.Id,SBQQ__Account__c= acc.Id, SBQQ__StartDate__c = System.Today());
        insert quote;
        
        // Create Products
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].Name = 'Enterprise Test2';
        prodList[1].Name = 'Enterprise Test3';
        prodList[2].Name = 'Enterprise Test4';
        prodList[3].Name = 'Enterprise Tes5';
        prodList[4].Name = 'Enterprise Test5';
        prodList[0].ConvertTo__c = 'Subscription';
        prodList[1].ConvertTo__c = 'Add On';
        prodList[2].ConvertTo__c = 'Entitlement-Premier';
        prodList[3].ConvertTo__c = 'Entitlement-Elite';
        prodList[4].ConvertTo__c = 'Entitlement';
        if(!prodList.isEmpty()){
            insert prodList;
        }
        
        // Create Custom Pricebooks
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(2);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }
        
        // Insert Products into Standard Pricebook
        List<PriceBookEntry> pbEntryStdPbList = new List<PriceBookEntry>();
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }
        SalesTriggersUtility.AssetTriggerVA  = true;
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = opp.Id;
        as2.Purpose__c = 'Production';
        as2.Asset_Type__c = 'Subscription';
        as2.AccountId = acc.Id;
        insert as2;
        Entitlement e2 = new Entitlement(Name = 'Test2',AssetId = as2.Id,AccountID = acc.ID,  StartDate =Date.TODAY(),Type ='Premium Education Catalog',Opportunity__c = opp.ID );
        insert e2;
        
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = opp.Id;
        oli1.PricebookEntryId = pbEntryStdPbList[0].Id;
        oli1.UnitPrice = 10;
        oli1.Quantity = 20;
       
        insert oli1;
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = opp.Id;
        oli2.PricebookEntryId = pbEntryStdPbList[1].Id;
        oli2.UnitPrice = 10;
        oli2.Quantity = 20;
    
        insert oli2;
        OpportunityLineItem oli3 = new OpportunityLineItem();
        oli3.OpportunityId = opp.Id;
        oli3.PricebookEntryId = pbEntryStdPbList[2].Id;
        oli3.UnitPrice = 10;
        oli3.Quantity = 20;
    
        insert oli3;
        OpportunityLineItem oli4 = new OpportunityLineItem();
        oli4.OpportunityId = opp.Id;
        oli4.PricebookEntryId = pbEntryStdPbList[3].Id;
        oli4.UnitPrice = 10;
        oli4.Quantity = 20;
     
        insert oli4;
        OpportunityLineItem oli5 = new OpportunityLineItem();
        oli5.OpportunityId = opp.Id;
        oli5.PricebookEntryId = pbEntryStdPbList[4].Id;
        oli5.UnitPrice = 10;
        oli5.Quantity = 20;
  
        insert oli5;
        
        
        List<OpportunityLineItem> oliLists = new List<OpportunityLineItem>();
        oliLists.add(oli1);
        oliLists.add(oli2);
        oliLists.add(oli3);
        oliLists.add(oli4);
        oliLists.add(oli5);
        test.startTest();
        NEWCreateAssetsAndEntitlements.createAssetWithEntitlement(opp);
        NEWCreateAssetsAndEntitlements.createDefaultEntitlement();
        test.stopTest();
    }
    public static testMethod void testCreateAE8(){
        
        Product2 pr = new Product2();
        pr.Name='Moto - G1';
        pr.isActive=true;
        pr.ProductCode = 'LM-SAND';
        insert pr;
        NEWCreateAssetsAndEntitlements.getsandboxProductId();
        SalesTriggersUtility.AssetTriggerVA  = true;
          SalesTriggersUtility.dlrs_AccountTrigger = true;
         Account acc = new Account();
                        acc.Name                 = 'GRAZITTI TEST ACCOUNT 1';
                        acc.Sales_Region__c      = 'ANZ';
                        acc.BillingCity          = 'Tokyo';
                        acc.BillingCountry       = 'Japan';
                        acc.BillingStreet        = 'Test Street';
                        acc.BillingState         = 'Test Billing State';
                        acc.BillingPostalCode    = '12345';
                        acc.ShippingCity         = 'Chandigarh';
                        acc.ShippingCountry      = 'India';
                        acc.ShippingPostalCode   = '12345';
                        acc.ShippingState        = '';
                        acc.ShippingStreet       = 'Test Shipping Street';
                        acc.Partner_Type__c      = 'Reseller';
        insert acc;
        
        Contact con = new Contact();
                        con.FirstName  ='test';
                        con.LastName   = 'GRAZITTI TEST CONTACT 1';
                        con.email      = 'test@test.com';
                        con.LeadSource = 'Blog';
                        con.AccountId  = acc.Id;
        insert con;
        
        Intacct_Entity__c ie = new Intacct_Entity__c();
        ie.Name = 'marketo-emea';
        insert ie;
        Intacct_Entity__c ie2 = new Intacct_Entity__c();
        ie2.Name = 'marketo-us';
        insert ie2;
        
        
        Id stdPbId = Test.getStandardPricebookId();
        
        Opportunity opp = new Opportunity();
                            opp.Name      = 'GRAZITTI TEST OPPORTUNITY 1';
                            opp.AccountId = acc.Id;
                            opp.Type      = 'New Business';
                            opp.StageName = 'A - Qualify';
                            opp.Amount   = 10000;
                            opp.MainCompetitor__c = 'Act-On';
                            opp.PriceBook2Id = stdPbId;
                            opp.Primary_Marketo_User_Lookup__c = con.Id;
                            opp.Economic_Decision_Maker__c = con.Id;
                            opp.Engagement_Manager__c = UserInfo.getUserId();
                            opp.SBQQ__Contracted__c = true;
                            opp.Intacct_Sales_Region__c = '';
                            opp.Owner_Role_Custom_Text__c = 'ANZ PS';
                            opp.Intacct_Entity__c = ie.Id;
                            opp.Rep_Create_ARR__c=1;
                           
                            opp.CloseDate = System.Now().Date();

        insert opp;
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opp.Id,SBQQ__Account__c= acc.Id, SBQQ__StartDate__c = System.Today());
        insert quote;
        
        // Create Products
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].Name = 'Enterprise Test2';
        prodList[1].Name = 'Enterprise Test3';
        prodList[2].Name = 'Enterprise Test4';
        prodList[3].Name = 'Enterprise Tes5';
        prodList[4].Name = 'Enterprise Test5';
        prodList[0].ConvertTo__c = 'Subscription';
        prodList[1].ConvertTo__c = 'Add On';
        prodList[2].ConvertTo__c = 'Entitlement-Premier';
        prodList[3].ConvertTo__c = 'Entitlement-Elite';
        prodList[4].ConvertTo__c = 'Entitlement';
        if(!prodList.isEmpty()){
            insert prodList;
        }
        
        // Create Custom Pricebooks
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(2);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }
        
        // Insert Products into Standard Pricebook
        List<PriceBookEntry> pbEntryStdPbList = new List<PriceBookEntry>();
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }
        SalesTriggersUtility.AssetTriggerVA  = true;
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = opp.Id;
        as2.Purpose__c = 'Production';
        as2.Asset_Type__c = 'Subscription';
        as2.AccountId = acc.Id;
        insert as2;
        Entitlement e2 = new Entitlement(Name = 'Test2',AssetId = as2.Id,AccountID = acc.ID,  StartDate =Date.TODAY(),Type ='Premium Education Catalog',Opportunity__c = opp.ID );
        insert e2;
        
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = opp.Id;
        oli1.PricebookEntryId = pbEntryStdPbList[0].Id;
        oli1.UnitPrice = 10;
        oli1.Quantity = 20;
       
        insert oli1;
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = opp.Id;
        oli2.PricebookEntryId = pbEntryStdPbList[1].Id;
        oli2.UnitPrice = 10;
        oli2.Quantity = 20;
       
        insert oli2;
        OpportunityLineItem oli3 = new OpportunityLineItem();
        oli3.OpportunityId = opp.Id;
        oli3.PricebookEntryId = pbEntryStdPbList[2].Id;
        oli3.UnitPrice = 10;
        oli3.Quantity = 20;
      
        insert oli3;
        OpportunityLineItem oli4 = new OpportunityLineItem();
        oli4.OpportunityId = opp.Id;
        oli4.PricebookEntryId = pbEntryStdPbList[3].Id;
        oli4.UnitPrice = 10;
        oli4.Quantity = 20;
      
        insert oli4;
        OpportunityLineItem oli5 = new OpportunityLineItem();
        oli5.OpportunityId = opp.Id;
        oli5.PricebookEntryId = pbEntryStdPbList[4].Id;
        oli5.UnitPrice = 10;
        oli5.Quantity = 20;
     
        insert oli5;
        
        
        List<OpportunityLineItem> oliLists = new List<OpportunityLineItem>();
        oliLists.add(oli1);
        oliLists.add(oli2);
        oliLists.add(oli3);
        oliLists.add(oli4);
        oliLists.add(oli5);
        test.startTest();
        NEWCreateAssetsAndEntitlements.createAssetWithEntitlement(opp);
        NEWCreateAssetsAndEntitlements.createDefaultEntitlement();
        test.stopTest();
    }
}