@isTest
private class test_QCP {
  
  @isTest static void test_non_rubiks() {
    Account acct = new Account(Name='Test');
        acct.BillingCountry = 'United States';
        acct.BillingStreet = 'Test Street';
        acct.BillingState ='Test Billing State';
        acct.BillingPostalCode ='12345';
        acct.ShippingCity ='Pune';
        acct.ShippingCountry ='India';
        acct.ShippingPostalCode = '12345';
        acct.ShippingState = 'Maharashtra';
        acct.ShippingStreet = 'Test Shipping Street';  
        acct.Accounting_Email__c = 'test@gmail.com';
        acct.Accounting_Contact_First_Name__c = 'FirstName';
        acct.Accounting_Contact_Last_Name__c = 'LastName';
        acct.Website = 'www.google.com';
        insert acct;
        
        contact cc = new contact();
        cc.FirstName = 'Grazitti';
        cc.LastName  = 'testcontact';
        cc.AccountId = acct.id;
		cc.firstnamelocal='test';
		cc.lastnamelocal='test';
        insert cc;
       
        Opportunity opp1 = new Opportunity(Name='Test', AccountId=acct.Id, StageName='B - Discover', CloseDate=System.today());
        opp1.Type = 'New Business';
        opp1.CRM_System__c = 'Other';
        opp1.Use_Case__c = 'B2B';
        opp1.NextStep = 'test';
        opp1.Deal_Type__c = 'Standard';
        opp1.LeadSource = 'Website';
        opp1.Rep_Create_ARR__c=1;
        opp1.MainCompetitor__c = 'Act-on';
        opp1.Primary_Marketo_User_Lookup__c = cc.id;
        insert opp1;
        
        Product2[] products = new Product2[0];
        Product2 p1 = new Product2(Name='MA Select Edition',ProductCode='BNDL-SVC-ADV',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p2 = new Product2(Name='MA Base Contacts',ProductCode='PROD-MA-SEL-USE',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p3 = new Product2(Name='Support',ProductCode='SUP-BASE-BUS',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p4 = new Product2(Name='Support2',ProductCode='SUP-BASE-STD-SMB',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p5 = new Product2(Name='Sub',ProductCode='PROD-ANA-RCA',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p6 = new Product2(Name='Sub',ProductCode='PROD-SOC-CAMP',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p7 = new Product2(Name='Sub',ProductCode='PROD-MA-WRKSP',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p8 = new Product2(Name='Sub',ProductCode='PROD-MA-DIA-INT',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');


        products.add(p1);
        products.add(p2);
        products.add(p3);
        products.add(p4);
        products.add(p5);
        products.add(p6);
        products.add(p7);
        products.add(p8);
        insert products;
        
        p2.SBQQ__IncludeInMaintenance__c = true;
        update products;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(Additional_UR_Products__c='prod1,prod2', SBQQ__Opportunity2__c=opp1.Id, SBQQ__StartDate__c = System.Today());
        quote1.Payment_Frequency__c = 'Quarterly';
        quote1.Order_Type__c = 'Standard (includes Promos)';
        quote1.SBQQ__StartDate__c = System.today();
        insert quote1;
        
        SBQQ__QuoteLine__c[] lines1 = new SBQQ__QuoteLine__c[0];
        SBQQ__QuoteLine__c line1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p1.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 0, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p2.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 100, SBQQ__Quantity__c=10,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p3.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 0, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line4 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p4.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 10, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line5 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p5.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 10, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line6 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p6.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 10, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line7 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p7.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 10, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line8 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p8.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 10, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        lines1.add(line1);
        lines1.add(line2);
        lines1.add(line3);
        lines1.add(line4);
        lines1.add(line5);
        lines1.add(line6);
        lines1.add(line7);
        lines1.add(line8);
        insert lines1;
        


     //Contract
        Contract contr=new Contract();
        contr.Accountid=acct.id;
        contr.Status='Draft';
        contr.StartDate=system.today().adddays(-1);
        contr.ContractTerm=12;
        insert contr;

        //Subscription
        SBQQ__Subscription__c subscrip=new SBQQ__Subscription__c();
        subscrip.SBQQ__Account__c=acct.id;
        subscrip.SBQQ__Contract__c=contr.id;

        subscrip.SBQQ__QuoteLine__c=lines1.get(0).id;
        subscrip.SBQQ__Product__c=p1.id;
        subscrip.SBQQ__Quantity__c=1;
        insert subscrip;


        lines1[0].SBQQ__Incomplete__c = false;
        lines1[0].SBQQ__RenewedSubscription__c=subscrip.id;
        lines1[0].SBQQ__Discount__c=.01;
        lines1[0].Database_Size_Label__c='sizelabel';
        lines1[0].Bundle_Name__c='bundlename';
        lines1[1].SBQQ__Incomplete__c = false;
        lines1[2].SBQQ__Incomplete__c = false;
        lines1[3].SBQQ__Incomplete__c = false;
        lines1[1].SBQQ__OptionLevel__c = 1;
        lines1[2].SBQQ__OptionLevel__c = 1;
        lines1[3].SBQQ__OptionLevel__c = 1;
        lines1[1].SBQQ__ProrateMultiplier__c = 1;
        lines1[2].SBQQ__ProrateMultiplier__c = 1;
        lines1[3].SBQQ__ProrateMultiplier__c = 1;
        lines1[1].SBQQ__DiscountScheduleType__c = 'Slab';
        lines1[1].SBQQ__SubscriptionPricing__c = 'Fixed Price';
        lines1[1].SBQQ__DefaultSubscriptionTerm__c = 12;
        lines1[1].SBQQ__RenewedSubscription__c=subscrip.id;
        lines1[1].Include_in_Bundle_Price__c=true;
       
        //Setting line 0 as the Bundle Parent
        lines1[1].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[2].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[3].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[4].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[5].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[6].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[7].SBQQ__RequiredBy__c = lines1[0].id;
        update lines1;
        
        
        
        lines1 = [SELECT SBQQ__Quote__c, SBQQ__RequiredBy__r.Renewal_Blended_Discount__c,SBQQ__RequiredBy__r.Email_Volume__c,Email_Volume__c, UR_Product__c, MKTO_Product_Name__c, Renewal_Blended_Discount__c, Renewal_Uplifted_Price__c,Renewal_Component_Total__c,SBQQ__RenewedSubscription__c,SBQQ__Product__c, SBQQ__BundledQuantity__c,Product_Multiple__c,  SBQQ__RequiredBy__r.SBQQ__ProductName__c, SBQQ__RequiredBy__r.Bundle_Name__c,  SBQQ__RequiredBy__r.Renewal_Component_Total__c, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__Discount__c, SBQQ__RequiredBy__r.Previous_Additional_Discount__c, SBQQ__RequiredBy__r.SBQQ__Product__c, SBQQ__RequiredBy__r.id, SBQQ__RequiredBy__r.SBQQ__ProductCode__c, SBQQ__ProductCode__c, SBQQ__Quantity__c, SBQQ__ListPrice__c, SBQQ__ProratedListPrice__c, SBQQ__RegularPrice__c, SBQQ__NetPrice__c, MSRP_Price__c, SBQQ__ListTotal__c, SBQQ__RegularTotal__c, SBQQ__CustomerTotal__c, SBQQ__NetTotal__c, ARR_for_Bundles__c, Bundle_Name__c, Database_Size__c, Database_Size_Label__c, SBQQ__ProductName__c, Bundle_Component_List_Total__c, Bundle_Component_Regular_Total__c, Bundle_Component_Customer_Total__c, Bundle_Component_Net_Total__c, Bundle_Component_ARR_for_Bundles__c, Include_in_Bundle_Price__c, SBQQ__EffectiveStartDate__c, SBQQ__EffectiveEndDate__c, SBQQ__SubscriptionTerm__c, SBQQ__DefaultSubscriptionTerm__c, MKTO_Effective_Term__c, MKTO_Effective_End_Date__c, SBQQ__SubscriptionPricing__c, SBQQ__ProrateMultiplier__c, SBQQ__Renewal__c, SBQQ__Bundled__c, SBQQ__Existing__c, SBQQ__PricingMethod__c, SBQQ__DiscountScheduleType__c, Quoted_Base_ACV_for_Support__c, Support_ACV_Amount__c, Include_in_Maintenance__c, SBQQ__OptionLevel__c, SBQQ__DistributorDiscount__c, SBQQ__PartnerDiscount__c, Delta_Usage_Formatted__c, Parent_Product_Code__c, DebugMessage__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quote1.Id ORDER BY SBQQ__Number__c];
        

       

        MarketoQuoteCalculator target1 = new MarketoQuoteCalculator();
        target1.onInit(lines1);
        target1.onBeforeCalculate(quote1, lines1);
        target1.onBeforePriceRules(quote1, lines1);
        target1.onAfterPriceRules(quote1, lines1);
        target1.onAfterCalculate(quote1, lines1);
  }
 
  @isTest static void test_rubiks_1() {
    Account acct = new Account(Name='Test');
        acct.BillingCountry = 'United States';
        acct.BillingStreet = 'Test Street';
        acct.BillingState ='Test Billing State';
        acct.BillingPostalCode ='12345';
        acct.ShippingCity ='Pune';
        acct.ShippingCountry ='India';
        acct.ShippingPostalCode = '12345';
        acct.ShippingState = 'Maharashtra';
        acct.ShippingStreet = 'Test Shipping Street';  
        acct.Accounting_Email__c = 'test@gmail.com';
        acct.Accounting_Contact_First_Name__c = 'FirstName';
        acct.Accounting_Contact_Last_Name__c = 'LastName';
        acct.Website = 'www.google.com';
        insert acct;
        
        contact cc = new contact();
        cc.FirstName = 'Grazitti';
        cc.LastName  = 'testcontact';
        cc.AccountId = acct.id;
		cc.firstnamelocal='test';
		cc.lastnamelocal='test';
        insert cc;
       
        
        Opportunity opp1 = new Opportunity(Name='Test', AccountId=acct.Id, StageName='B - Discover', CloseDate=System.today());
        opp1.Type = 'New Business';
        opp1.CRM_System__c = 'Other';
        opp1.Use_Case__c = 'B2B';
        opp1.NextStep = 'test';
        opp1.Deal_Type__c = 'Standard';
        opp1.LeadSource = 'Website';
        opp1.Rep_Create_ARR__c=1;
        opp1.MainCompetitor__c = 'Act-on';
        opp1.Primary_Marketo_User_Lookup__c = cc.id;
        insert opp1;
        
        Product2[] products = new Product2[0];
        Product2 p1 = new Product2(Name='RubikBundle',ProductCode='BNDL-SMB-MKTGAUTO',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p2 = new Product2(Name='MA Base Contacts',ProductCode='PROD-APPS-AUTOWKFL',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p3 = new Product2(Name='Support',ProductCode='SUP-BASE-BUS',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p4 = new Product2(Name='Support2',ProductCode='PROD-PLAT-SANDBOX',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p5 = new Product2(Name='Sub',ProductCode='PROD-APPS-ADVREP',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p6 = new Product2(Name='Sub',ProductCode='PROD-APPS-LCM',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p7 = new Product2(Name='Sub',ProductCode='PROD-PLAT-WORKPAR',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p8 = new Product2(Name='Sub',ProductCode='PROD-MA-DIA-INT',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');


        products.add(p1);
        products.add(p2);
        products.add(p3);
        products.add(p4);
        products.add(p5);
        products.add(p6);
        products.add(p7);
        products.add(p8);
        insert products;
        
        p2.SBQQ__IncludeInMaintenance__c = true;
        update products;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(SBQQ__Opportunity2__c=opp1.Id, SBQQ__StartDate__c = System.Today());
        quote1.Payment_Frequency__c = 'Quarterly';
        quote1.Order_Type__c = 'Standard (includes Promos)';
        quote1.SBQQ__StartDate__c = System.today();
        insert quote1;
        
        SBQQ__QuoteLine__c[] lines1 = new SBQQ__QuoteLine__c[0];
        SBQQ__QuoteLine__c line1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p1.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 0, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p2.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 100, SBQQ__Quantity__c=10,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p3.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 0, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line4 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p4.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 10, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line5 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p5.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 10, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line6 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p6.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 10, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line7 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p7.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 10, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line8 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p8.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 10, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        lines1.add(line1);
        lines1.add(line2);
        lines1.add(line3);
        lines1.add(line4);
        lines1.add(line5);
        lines1.add(line6);
        lines1.add(line7);
        lines1.add(line8);
        insert lines1;
        


     //Contract
        Contract contr=new Contract();
        contr.Accountid=acct.id;
        contr.Status='Draft';
        contr.StartDate=system.today().adddays(-1);
        contr.ContractTerm=12;
        insert contr;

        //Subscription
        SBQQ__Subscription__c subscrip=new SBQQ__Subscription__c();
        subscrip.SBQQ__Account__c=acct.id;
        subscrip.SBQQ__Contract__c=contr.id;

        subscrip.SBQQ__QuoteLine__c=lines1.get(0).id;
        subscrip.SBQQ__Product__c=p1.id;
        subscrip.SBQQ__Quantity__c=1;
        insert subscrip;


        lines1[0].SBQQ__Incomplete__c = false;
        lines1[0].SBQQ__RenewedSubscription__c=subscrip.id;
        lines1[0].SBQQ__Discount__c=.01;
        lines1[0].Database_Size_Label__c='sizelabel';
        lines1[0].Bundle_Name__c='bundlename';
        lines1[1].SBQQ__Incomplete__c = false;
        lines1[2].SBQQ__Incomplete__c = false;
        lines1[3].SBQQ__Incomplete__c = false;
        lines1[1].SBQQ__OptionLevel__c = 1;
        lines1[2].SBQQ__OptionLevel__c = 1;
        lines1[3].SBQQ__OptionLevel__c = 1;
        lines1[1].SBQQ__ProrateMultiplier__c = 1;
        lines1[2].SBQQ__ProrateMultiplier__c = 1;
        lines1[3].SBQQ__ProrateMultiplier__c = 1;
        lines1[1].SBQQ__DiscountScheduleType__c = 'Slab';
        lines1[1].SBQQ__SubscriptionPricing__c = 'Fixed Price';
        lines1[1].SBQQ__DefaultSubscriptionTerm__c = 12;
        lines1[1].SBQQ__RenewedSubscription__c=subscrip.id;
        lines1[1].Include_in_Bundle_Price__c=true;
         lines1[0].UR_Product__c=false;
        lines1[1].UR_Product__c=false;
        lines1[2].UR_Product__c=true;
        lines1[3].UR_Product__c=false;
        lines1[4].UR_Product__c=false;
        lines1[5].UR_Product__c=false;
        lines1[6].UR_Product__c=false;
        lines1[7].UR_Product__c=false;

        lines1[2].Manual_Rollup__c=true;
        lines1[2].Product_Multiple__c=2;
        //Setting line 0 as the Bundle Parent
        lines1[1].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[2].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[3].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[4].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[5].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[6].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[7].SBQQ__RequiredBy__c = lines1[0].id;
        update lines1;
        
        
        
        lines1 = [SELECT SBQQ__Quote__c, SBQQ__RequiredBy__r.Renewal_Blended_Discount__c,SBQQ__RequiredBy__r.Email_Volume__c,Email_Volume__c,Manual_Rollup__c, Renewal_Blended_Discount__c, SBQQ__RequiredBy__r.Subscription_ACV__c,Subscription_ACV__c,Renewal_Uplifted_Price__c,Renewal_Component_Total__c,SBQQ__RenewedSubscription__c,SBQQ__Product__c, SBQQ__BundledQuantity__c,Product_Multiple__c,  SBQQ__RequiredBy__r.SBQQ__ProductName__c, SBQQ__RequiredBy__r.Bundle_Name__c,  SBQQ__Discount__c, Previous_Rubiks_Support_ACV__c, SBQQ__SegmentIndex__c, SBQQ__RequiredBy__r.Renewal_Component_Total__c, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__Discount__c, SBQQ__RequiredBy__r.Previous_Additional_Discount__c, SBQQ__RequiredBy__r.SBQQ__Product__c, SBQQ__RequiredBy__r.id, SBQQ__RequiredBy__r.SBQQ__ProductCode__c, SBQQ__ProductCode__c, SBQQ__Quantity__c, SBQQ__ListPrice__c, SBQQ__ProratedListPrice__c, SBQQ__RegularPrice__c, SBQQ__NetPrice__c, MSRP_Price__c, SBQQ__ListTotal__c, SBQQ__RegularTotal__c, SBQQ__CustomerTotal__c, SBQQ__NetTotal__c, ARR_for_Bundles__c, Bundle_Name__c, Database_Size__c, Database_Size_Label__c, SBQQ__ProductName__c, Bundle_Component_List_Total__c, Bundle_Component_Regular_Total__c, Bundle_Component_Customer_Total__c, Bundle_Component_Net_Total__c, Bundle_Component_ARR_for_Bundles__c, Include_in_Bundle_Price__c, SBQQ__EffectiveStartDate__c, SBQQ__EffectiveEndDate__c, SBQQ__SubscriptionTerm__c, SBQQ__DefaultSubscriptionTerm__c, MKTO_Effective_Term__c, MKTO_Effective_End_Date__c, SBQQ__SubscriptionPricing__c, SBQQ__ProrateMultiplier__c, SBQQ__Renewal__c, SBQQ__Bundled__c, SBQQ__Existing__c, SBQQ__PricingMethod__c, SBQQ__DiscountScheduleType__c, Quoted_Base_ACV_for_Support__c, Support_ACV_Amount__c, Include_in_Maintenance__c, SBQQ__OptionLevel__c, SBQQ__DistributorDiscount__c, SBQQ__PartnerDiscount__c, Delta_Usage_Formatted__c, Parent_Product_Code__c, DebugMessage__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quote1.Id ORDER BY SBQQ__Number__c];
        

       

        MarketoQuoteCalculator target1 = new MarketoQuoteCalculator();
        target1.onInit(lines1);
        target1.onBeforeCalculate(quote1, lines1);
        target1.onBeforePriceRules(quote1, lines1);
        target1.onAfterPriceRules(quote1, lines1);
        target1.onAfterCalculate(quote1, lines1);
  } 
 
  @isTest static void test_block_pricing_uplift() {
    Account acct = new Account(Name='Test');
        acct.BillingCountry = 'United States';
        acct.BillingStreet = 'Test Street';
        acct.BillingState ='Test Billing State';
        acct.BillingPostalCode ='12345';
        acct.ShippingCity ='Pune';
        acct.ShippingCountry ='India';
        acct.ShippingPostalCode = '12345';
        acct.ShippingState = 'Maharashtra';
        acct.ShippingStreet = 'Test Shipping Street';  
        acct.Accounting_Email__c = 'test@gmail.com';
        acct.Accounting_Contact_First_Name__c = 'FirstName';
        acct.Accounting_Contact_Last_Name__c = 'LastName';
        acct.Website = 'www.google.com';
        insert acct;
        
        contact cc = new contact();
        cc.FirstName = 'Grazitti';
        cc.LastName  = 'testcontact';
        cc.AccountId = acct.id;
		cc.firstnamelocal='test';
		cc.lastnamelocal='test';
        insert cc;
        
        
        Opportunity opp1 = new Opportunity(Name='Test', AccountId=acct.Id, StageName='B - Discover', CloseDate=System.today());
        opp1.Type = 'New Business';
        opp1.CRM_System__c = 'Other';
        opp1.Use_Case__c = 'B2B';
        opp1.NextStep = 'test';
        opp1.Deal_Type__c = 'Standard';
        opp1.LeadSource = 'Website';
        opp1.Rep_Create_ARR__c=1;
        opp1.MainCompetitor__c = 'Act-on';
        opp1.Primary_Marketo_User_Lookup__c = cc.id;
        insert opp1;
        
        Product2[] products = new Product2[0];
        Product2 p1 = new Product2(Name='MA Select Edition',ProductCode='BNDL-SVC-ADV',SBQQ__PricingMethod__c='Block',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p2 = new Product2(Name='MA Base Contacts',ProductCode='PROD-MA-SEL-USE',SBQQ__PricingMethod__c='Block',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p3 = new Product2(Name='Support',ProductCode='SUP-BASE-BUS',SBQQ__PricingMethod__c='Block',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p4 = new Product2(Name='Support2',ProductCode='SUP-BASE-STD-SMB',SBQQ__PricingMethod__c='Block',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p5 = new Product2(Name='Sub',ProductCode='PROD-ANA-RCA',SBQQ__PricingMethod__c='Block',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p6 = new Product2(Name='Sub',ProductCode='PROD-SOC-CAMP',SBQQ__PricingMethod__c='Block',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p7 = new Product2(Name='Sub',ProductCode='PROD-MA-WRKSP',SBQQ__PricingMethod__c='Block',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p8 = new Product2(Name='Sub',ProductCode='PROD-MA-DIA-INT',SBQQ__PricingMethod__c='Block',SBQQ__SubscriptionPricing__c='Fixed Price');


        products.add(p1);
        products.add(p2);
        products.add(p3);
        products.add(p4);
        products.add(p5);
        products.add(p6);
        products.add(p7);
        products.add(p8);
        insert products;
        
        List<SBQQ__BlockPrice__c> blockPricing=new List<SBQQ__BlockPrice__c>();
        blockPricing.add(new SBQQ__BlockPrice__c(CurrencyIsoCode='USD', SBQQ__LowerBound__c=0, SBQQ__UpperBound__c=500,SBQQ__Price__c=100, SBQQ__Product__c=p1.id));
        blockPricing.add(new SBQQ__BlockPrice__c(CurrencyIsoCode='USD', SBQQ__LowerBound__c=0, SBQQ__UpperBound__c=500,SBQQ__Price__c=100, SBQQ__Product__c=p2.id));
        blockPricing.add(new SBQQ__BlockPrice__c(CurrencyIsoCode='USD', SBQQ__LowerBound__c=0, SBQQ__UpperBound__c=500,SBQQ__Price__c=100, SBQQ__Product__c=p3.id));
        blockPricing.add(new SBQQ__BlockPrice__c(CurrencyIsoCode='USD', SBQQ__LowerBound__c=0, SBQQ__UpperBound__c=500,SBQQ__Price__c=100, SBQQ__Product__c=p4.id));
        blockPricing.add(new SBQQ__BlockPrice__c(CurrencyIsoCode='USD', SBQQ__LowerBound__c=0, SBQQ__UpperBound__c=500,SBQQ__Price__c=100, SBQQ__Product__c=p5.id));
        blockPricing.add(new SBQQ__BlockPrice__c(CurrencyIsoCode='USD', SBQQ__LowerBound__c=0, SBQQ__UpperBound__c=500,SBQQ__Price__c=100, SBQQ__Product__c=p6.id));
        blockPricing.add(new SBQQ__BlockPrice__c(CurrencyIsoCode='USD', SBQQ__LowerBound__c=0, SBQQ__UpperBound__c=500,SBQQ__Price__c=100, SBQQ__Product__c=p7.id));
        blockPricing.add(new SBQQ__BlockPrice__c(CurrencyIsoCode='USD', SBQQ__LowerBound__c=0, SBQQ__UpperBound__c=500,SBQQ__Price__c=100, SBQQ__Product__c=p8.id));
        insert blockPricing;

        p2.SBQQ__IncludeInMaintenance__c = true;
        update products;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(Additional_UR_Products__c='prod1,prod2', SBQQ__Opportunity2__c=opp1.Id, SBQQ__StartDate__c = System.Today());
        quote1.Payment_Frequency__c = 'Annually';
        quote1.Order_Type__c = 'Standard (includes Promos)';
        quote1.SBQQ__StartDate__c = System.today();
        insert quote1;
        
        SBQQ__QuoteLine__c[] lines1 = new SBQQ__QuoteLine__c[0];
        SBQQ__QuoteLine__c line1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p1.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 0, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p2.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 100, SBQQ__Quantity__c=10,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p3.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 0, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line4 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p4.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 10, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line5 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p5.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 10, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line6 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p6.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 10, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line7 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p7.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 10, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line8 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p8.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 10, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        lines1.add(line1);
        lines1.add(line2);
        lines1.add(line3);
        lines1.add(line4);
        lines1.add(line5);
        lines1.add(line6);
        lines1.add(line7);
        lines1.add(line8);
        insert lines1;
        


     //Contract
        Contract contr=new Contract();
        contr.Accountid=acct.id;
        contr.Status='Draft';
        contr.StartDate=system.today().adddays(-1);
        contr.ContractTerm=12;
        insert contr;

        //Subscription
        SBQQ__Subscription__c subscrip=new SBQQ__Subscription__c();
        subscrip.SBQQ__Account__c=acct.id;
        subscrip.SBQQ__Contract__c=contr.id;

        subscrip.SBQQ__QuoteLine__c=lines1.get(0).id;
        subscrip.SBQQ__Product__c=p1.id;
        subscrip.SBQQ__Quantity__c=1;
        insert subscrip;


        lines1[0].SBQQ__Incomplete__c = false;
        lines1[0].SBQQ__RenewedSubscription__c=subscrip.id;
        lines1[0].SBQQ__Discount__c=.01;
        lines1[0].Database_Size_Label__c='sizelabel';
        lines1[0].Bundle_Name__c='bundlename';
        lines1[1].SBQQ__Incomplete__c = false;
        lines1[2].SBQQ__Incomplete__c = false;
        lines1[3].SBQQ__Incomplete__c = false;
        lines1[1].SBQQ__OptionLevel__c = 1;
        lines1[2].SBQQ__OptionLevel__c = 1;
        lines1[3].SBQQ__OptionLevel__c = 1;
        lines1[1].SBQQ__ProrateMultiplier__c = 1;
        lines1[2].SBQQ__ProrateMultiplier__c = 1;
        lines1[3].SBQQ__ProrateMultiplier__c = 1;
        lines1[1].SBQQ__DiscountScheduleType__c = 'Slab';
        lines1[1].SBQQ__SubscriptionPricing__c = 'Fixed Price';
        lines1[1].SBQQ__DefaultSubscriptionTerm__c = 12;
        lines1[1].SBQQ__RenewedSubscription__c=subscrip.id;
        lines1[1].Include_in_Bundle_Price__c=true;

        
        lines1[0].SBQQ__PricingMethod__c='Block';
        lines1[1].SBQQ__PricingMethod__c='Block';
        lines1[2].SBQQ__PricingMethod__c='Block';
        lines1[3].SBQQ__PricingMethod__c='Block';
        lines1[4].SBQQ__PricingMethod__c='Block';
        lines1[5].SBQQ__PricingMethod__c='Block';
        lines1[6].SBQQ__PricingMethod__c='Block';
        lines1[7].SBQQ__PricingMethod__c='Block';
    
       
        //Setting line 0 as the Bundle Parent
        lines1[1].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[2].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[3].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[4].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[5].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[6].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[7].SBQQ__RequiredBy__c = lines1[0].id;
        update lines1;
        
        //SBQQ__RequiredBy__r.Renewal_Blended_Discount__c

        lines1 = [SELECT SBQQ__RequiredBy__r.Renewal_Blended_Discount__c, SBQQ__Quote__c, Email_Volume__c, Payment_Freq__c, UR_Product__c, MKTO_Product_Name__c, Renewal_Blended_Discount__c, Renewal_Uplifted_Price__c,Renewal_Component_Total__c,SBQQ__RenewedSubscription__c,SBQQ__Product__c, SBQQ__BundledQuantity__c,Product_Multiple__c,  SBQQ__RequiredBy__r.SBQQ__ProductName__c, SBQQ__RequiredBy__r.Bundle_Name__c,  SBQQ__RequiredBy__r.Renewal_Component_Total__c, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__Discount__c, SBQQ__RequiredBy__r.Previous_Additional_Discount__c, SBQQ__RequiredBy__r.SBQQ__Product__c, SBQQ__RequiredBy__r.id, SBQQ__RequiredBy__r.SBQQ__ProductCode__c, SBQQ__ProductCode__c, SBQQ__Quantity__c, SBQQ__ListPrice__c, SBQQ__ProratedListPrice__c, SBQQ__RegularPrice__c, SBQQ__NetPrice__c, MSRP_Price__c, SBQQ__ListTotal__c, SBQQ__RegularTotal__c, SBQQ__CustomerTotal__c, SBQQ__NetTotal__c, ARR_for_Bundles__c, Bundle_Name__c, Database_Size__c, Database_Size_Label__c, SBQQ__ProductName__c, Bundle_Component_List_Total__c, Bundle_Component_Regular_Total__c, Bundle_Component_Customer_Total__c, Bundle_Component_Net_Total__c, Bundle_Component_ARR_for_Bundles__c, Include_in_Bundle_Price__c, SBQQ__EffectiveStartDate__c, SBQQ__EffectiveEndDate__c, SBQQ__SubscriptionTerm__c, SBQQ__DefaultSubscriptionTerm__c, MKTO_Effective_Term__c, MKTO_Effective_End_Date__c, SBQQ__SubscriptionPricing__c, SBQQ__ProrateMultiplier__c, SBQQ__Renewal__c, SBQQ__Bundled__c, SBQQ__Existing__c, SBQQ__PricingMethod__c, SBQQ__DiscountScheduleType__c, Quoted_Base_ACV_for_Support__c, Support_ACV_Amount__c, Include_in_Maintenance__c, SBQQ__OptionLevel__c, SBQQ__DistributorDiscount__c, SBQQ__PartnerDiscount__c, Delta_Usage_Formatted__c, Parent_Product_Code__c, DebugMessage__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quote1.Id ORDER BY SBQQ__Number__c];
        

       

        MarketoQuoteCalculator target1 = new MarketoQuoteCalculator();
        target1.onInit(lines1);
        target1.onBeforeCalculate(quote1, lines1);
        target1.onBeforePriceRules(quote1, lines1);
        target1.onAfterPriceRules(quote1, lines1);
        target1.onAfterCalculate(quote1, lines1);
  }
  
  @isTest static void test_page_security_plugin() {
    Account acct = new Account(Name='Test');
        acct.BillingCountry = 'United States';
        acct.BillingStreet = 'Test Street';
        acct.BillingState ='Test Billing State';
        acct.BillingPostalCode ='12345';
        acct.ShippingCity ='Pune';
        acct.ShippingCountry ='India';
        acct.ShippingPostalCode = '12345';
        acct.ShippingState = 'Maharashtra';
        acct.ShippingStreet = 'Test Shipping Street';  
        acct.Accounting_Email__c = 'test@gmail.com';
        acct.Accounting_Contact_First_Name__c = 'FirstName';
        acct.Accounting_Contact_Last_Name__c = 'LastName';
        acct.Website = 'www.google.com';
        insert acct;
        
         contact cc = new contact();
        cc.FirstName = 'Grazitti';
        cc.LastName  = 'testcontact';
        cc.AccountId = acct.id;
		cc.firstnamelocal='test';
		cc.lastnamelocal='test';
        insert cc;
                
        Opportunity opp1 = new Opportunity(Name='Test', AccountId=acct.Id, StageName='B - Discover', CloseDate=System.today());
        opp1.Type = 'New Business';
        opp1.CRM_System__c = 'Other';
        opp1.Use_Case__c = 'B2B';
        opp1.NextStep = 'test';
        opp1.Deal_Type__c = 'Standard';
        opp1.LeadSource = 'Website';
        opp1.Rep_Create_ARR__c=1;
        opp1.MainCompetitor__c = 'Act-on';
        opp1.Primary_Marketo_User_Lookup__c = cc.id;
        insert opp1;
        
        Product2[] products = new Product2[0];
        Product2 p1 = new Product2(Family='Other', Name='MA Select Edition',ProductCode='BNDL-SVC-ADV',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p2 = new Product2(Family='Other', Name='MA Base Contacts',ProductCode='PROD-MA-SEL-USE',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p3 = new Product2(Family='Other', Name='Support',ProductCode='SUP-BASE-BUS',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p4 = new Product2(Family='Other', Name='Support2',ProductCode='SUP-BASE-STD-SMB',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p5 = new Product2(Family='Other', Name='Sub',ProductCode='PROD-ANA-RCA',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p6 = new Product2(Family='Other', Name='Sub',ProductCode='PROD-SOC-CAMP',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p7 = new Product2(Family='Other', Name='Sub',ProductCode='PROD-MA-WRKSP',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');
        Product2 p8 = new Product2(Family='Other', Name='Sub',ProductCode='PROD-MA-DIA-INT',SBQQ__PricingMethod__c='List',SBQQ__SubscriptionPricing__c='Fixed Price');


        products.add(p1);
        products.add(p2);
        products.add(p3);
        products.add(p4);
        products.add(p5);
        products.add(p6);
        products.add(p7);
        products.add(p8);
        insert products;
        

        p2.SBQQ__IncludeInMaintenance__c = true;
        update products;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
        SBQQ__Quote__c quote1 = new SBQQ__Quote__c(Rubiks_Quote__c=false,Additional_UR_Products__c='prod1,prod2', SBQQ__Opportunity2__c=opp1.Id, SBQQ__StartDate__c = System.Today());
        quote1.Payment_Frequency__c = 'Annually';
        quote1.Order_Type__c = 'Standard (includes Promos)';
        quote1.SBQQ__StartDate__c = System.today();
        insert quote1;
        
        SBQQ__QuoteLine__c[] lines1 = new SBQQ__QuoteLine__c[0];
        SBQQ__QuoteLine__c line1 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p1.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 0, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line2 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p2.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 100, SBQQ__Quantity__c=10,Renewal_Uplifted_Price__c=100.00,Renewal_Discount__c=12.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line3 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p3.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 0, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line4 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p4.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 10, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line5 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p5.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 10, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line6 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p6.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 10, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line7 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p7.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 10, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        SBQQ__QuoteLine__c line8 = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote1.Id, SBQQ__Product__c=p8.Id ,SBQQ__Incomplete__c=true, SBQQ__ListPrice__c = 10, SBQQ__Quantity__c=1,Renewal_Uplifted_Price__c=100.00,Renewal_Component_Total__c=0.00,Renewal_Blended_Discount__c=0.00);
        lines1.add(line1);
        lines1.add(line2);
        lines1.add(line3);
        lines1.add(line4);
        lines1.add(line5);
        lines1.add(line6);
        lines1.add(line7);
        lines1.add(line8);
        insert lines1;
        


     //Contract
        Contract contr=new Contract();
        contr.Accountid=acct.id;
        contr.Status='Draft';
        contr.StartDate=system.today().adddays(-1);
        contr.ContractTerm=12;
        insert contr;

        //Subscription
        SBQQ__Subscription__c subscrip=new SBQQ__Subscription__c();
        subscrip.SBQQ__Account__c=acct.id;
        subscrip.SBQQ__Contract__c=contr.id;

        subscrip.SBQQ__QuoteLine__c=lines1.get(0).id;
        subscrip.SBQQ__Product__c=p1.id;
        subscrip.SBQQ__Quantity__c=1;
        insert subscrip;


        lines1[0].SBQQ__Incomplete__c = false;
        lines1[0].SBQQ__RenewedSubscription__c=subscrip.id;
        lines1[0].SBQQ__Discount__c=.01;
        lines1[0].Database_Size_Label__c='sizelabel';
        lines1[0].Bundle_Name__c='bundlename';
        lines1[1].SBQQ__Incomplete__c = false;
        lines1[2].SBQQ__Incomplete__c = false;
        lines1[3].SBQQ__Incomplete__c = false;
        lines1[1].SBQQ__OptionLevel__c = 1;
        lines1[2].SBQQ__OptionLevel__c = 1;
        lines1[3].SBQQ__OptionLevel__c = 1;
        lines1[1].SBQQ__ProrateMultiplier__c = 1;
        lines1[2].SBQQ__ProrateMultiplier__c = 1;
        lines1[3].SBQQ__ProrateMultiplier__c = 1;
        lines1[1].SBQQ__DiscountScheduleType__c = 'Slab';
        lines1[1].SBQQ__SubscriptionPricing__c = 'Fixed Price';
        lines1[1].SBQQ__DefaultSubscriptionTerm__c = 12;
        lines1[1].SBQQ__RenewedSubscription__c=subscrip.id;
        lines1[1].Include_in_Bundle_Price__c=true;

        
        lines1[0].SBQQ__PricingMethod__c='List';
        lines1[1].SBQQ__PricingMethod__c='List';
        lines1[2].SBQQ__PricingMethod__c='List';
        lines1[3].SBQQ__PricingMethod__c='List';
        lines1[4].SBQQ__PricingMethod__c='List';
        lines1[5].SBQQ__PricingMethod__c='List';
        lines1[6].SBQQ__PricingMethod__c='List';
        lines1[7].SBQQ__PricingMethod__c='List';
    
       
        //Setting line 0 as the Bundle Parent
        lines1[1].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[2].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[3].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[4].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[5].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[6].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[7].SBQQ__RequiredBy__c = lines1[0].id;
        lines1[0].Manual_Rollup__c =true;
        
        update lines1;
        
        
        
        lines1 = [SELECT Rubiks_Quote__c,Quote_Type__c,SBQQ__RequiredBy__r.Renewal_Blended_Discount__c,Email_Volume__c,SBQQ__Quote__c, SBQQ__ProductFamily__c,Payment_Freq__c, UR_Product__c, MKTO_Product_Name__c, Renewal_Blended_Discount__c, Renewal_Uplifted_Price__c,Renewal_Component_Total__c,SBQQ__RenewedSubscription__c,SBQQ__Product__c, SBQQ__BundledQuantity__c,Product_Multiple__c,  SBQQ__RequiredBy__r.SBQQ__ProductName__c, SBQQ__RequiredBy__r.Bundle_Name__c,  SBQQ__RequiredBy__r.Renewal_Component_Total__c, SBQQ__RequiredBy__c, SBQQ__RequiredBy__r.SBQQ__Discount__c, SBQQ__RequiredBy__r.Previous_Additional_Discount__c, SBQQ__RequiredBy__r.SBQQ__Product__c, SBQQ__RequiredBy__r.id, SBQQ__RequiredBy__r.SBQQ__ProductCode__c, SBQQ__ProductCode__c, SBQQ__Quantity__c, SBQQ__ListPrice__c, SBQQ__ProratedListPrice__c, SBQQ__RegularPrice__c, SBQQ__NetPrice__c, MSRP_Price__c, SBQQ__ListTotal__c, SBQQ__RegularTotal__c, SBQQ__CustomerTotal__c, SBQQ__NetTotal__c, ARR_for_Bundles__c, Bundle_Name__c, Database_Size__c, Database_Size_Label__c, SBQQ__ProductName__c, Bundle_Component_List_Total__c, Bundle_Component_Regular_Total__c, Bundle_Component_Customer_Total__c, Bundle_Component_Net_Total__c, Bundle_Component_ARR_for_Bundles__c, Include_in_Bundle_Price__c, SBQQ__EffectiveStartDate__c, SBQQ__EffectiveEndDate__c, SBQQ__SubscriptionTerm__c, SBQQ__DefaultSubscriptionTerm__c, MKTO_Effective_Term__c, MKTO_Effective_End_Date__c, SBQQ__SubscriptionPricing__c, SBQQ__ProrateMultiplier__c, SBQQ__Renewal__c, SBQQ__Bundled__c, SBQQ__Existing__c, SBQQ__PricingMethod__c, SBQQ__DiscountScheduleType__c, Quoted_Base_ACV_for_Support__c, Support_ACV_Amount__c, Include_in_Maintenance__c, SBQQ__OptionLevel__c, SBQQ__DistributorDiscount__c, SBQQ__PartnerDiscount__c, Delta_Usage_Formatted__c, Parent_Product_Code__c, DebugMessage__c FROM SBQQ__QuoteLine__c WHERE SBQQ__Quote__c = :quote1.Id ORDER BY SBQQ__Number__c];
        

       Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
       Schema.SObjectType qlSchema = schemaMap.get('SBQQ__QuoteLine__c');
       Map<String, Schema.SObjectField> fieldMap = qlSchema.getDescribe().fields.getMap();

       MarketoPageSecurityPlugin psp=new MarketoPageSecurityPlugin();
       for(String s:fieldMap.keyset()){
           Schema.SObjectField myfld=fieldMap.get(s);
           psp.isFieldEditable('EditLines',myfld,lines1.get(0));
           psp.isFieldVisible('EditLines',myfld,lines1.get(0));
           psp.isFieldEditable('EditLines',myfld);
           psp.isFieldVisible('EditLines',myfld);

       }
       
       
  }
 
}