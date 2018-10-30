/*******************************************************
Modified By : Sumit Bhatt, Grazitti Interactive
Modified date : 7/27/2018
Purpose : Commented the field that are used in field removal project 
refrence : APPS-20840 Field Cleanup Project - Phase One
log of fields commented : Opportunity: Third_Party_Solutions__c,solutions_consultant_lookup__c


Modified By :Jade Global 31th August 20
   Change      : Removed closedWonRecordTypeId of class Trigger_Opportunity_Helper  variable from class
          
*******************************************************/
@isTest
public class Opportunity_MAIN_Trigger_OPTIMIZED_TEST {

     @testSetup static void InsertOpportunityTestForLegacy(){
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
     System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt2);
     
   
         //SalesTriggersUtility.marketoTriggerManager.Activate_Legacy_Triggers__c = False;
         //SalesTriggersUtility.Setvaluesfortest();
        
        Account_MainTriggerHelper.isBeforeInsertHandler = True;
        Account_MainTriggerHelper.isBeforeUpdateHandler = True;      
        Account_MainTriggerHelper.isBeforeDeleteHandler = True;
        Account_MainTriggerHelper.isAfterInsertHandler = True;
        Account_MainTriggerHelper.isAfterUpdateHandler = True;
        Account_MainTriggerHelper.isAfterDeleteHandler = True;
        Account_MAIN_TriggerHandler.isAccountTriggerExecuted = True;
        
        ContactTriggerMAINHandler.isTriggerExecuted = True;
        Utility.haveRunAlertDatanyzeUpdate = true;
        Utility.isFutureUpdate = false; 
        RecurssionOnOppandAccount.isFromupdateUserBadgeTag= false;
        //GenericTriggerAccountB4InsertB4Update.isTerritoryNameRunningOnceMore = True;
        AssignNBAEPerRules.ANFirstPass = True;
        Utility.isUpdateContactOwnerAsAccountOwnerRunningOnceMore = true;
        SfdcJiveHelper.RunIntegrationTriggerOnceAcc=true;
        Trigger_Opportunity_Helper.bofuWizardEnabledForUser = true;
        List<Opportunity> oppLists = new List<Opportunity>();
        
        Intacct_Entity__c ie = new Intacct_Entity__c();
        ie.Name = 'marketo-emea';
        insert ie;
        Intacct_Entity__c ie2 = new Intacct_Entity__c();
        ie2.Name = 'marketo-us';
        insert ie2;
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
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
                        acc.Intacct_Entity__c    = ie.id;
                        acc.IntacctID__c         = 'TestID123';
        insert acc;
        
        Contact con = new Contact();
                        con.LastName   = 'GRAZITTI TEST CONTACT 1';
                        con.FirstName  = 'Test';
                        con.email      = 'test@test.com';
                        con.LeadSource = 'Blog';
                        con.AccountId  = acc.Id;
        insert con;
        
        
        Role_Geographical_Segmentation_Setting__c rgs = new Role_Geographical_Segmentation_Setting__c();
        rgs.Name = 'ANZ PS';
        insert rgs;
        
        Id stdPbId = Test.getStandardPricebookId();
        
         // Create Custom Pricebooks
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(2);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }
        
         // Insert data for custom setting - SteelBrickCPQPricebook__c
        SteelBrickCPQPricebook__c obj = new SteelBrickCPQPricebook__c();
        obj.Name = 'SteelBrick PB';
        obj.ID__c = priceBookList[0].Id;
        insert obj;
        
        Opportunity opp = new Opportunity();
                            opp.Name      = 'GRAZITTI TEST OPPORTUNITY 1';
                            opp.AccountId = acc.Id;
                            opp.Type      = 'New Business';
                            opp.StageName = 'A - Qualify';
                            opp.Sub_End_Date__c      = System.Today().addMonths(1);
                            opp.Amount   = 10000;
                            opp.PriceBook2Id = stdPbId;
                            //opp.PriceBook2Id = priceBookList[0].id;
                            opp.Primary_Marketo_User_Lookup__c = con.Id;
                            opp.Economic_Decision_Maker__c = con.Id;
                            opp.Engagement_Manager__c = UserInfo.getUserId();
                            opp.SBQQ__Contracted__c = true;
                            opp.Intacct_Sales_Region__c = '';
                            opp.Owner_Role_Custom_Text__c = 'ANZ PS';
                            opp.Intacct_Entity__c = ie.Id;
                            opp.Rep_Create_ARR__c=1;
                            opp.MainCompetitor__c='Act-On';
                            
                            opp.CloseDate = System.Now().Date();
                            opp.Use_Case__c          ='B2B';
                            //opp.Solutions_Consultant_Lookup__c=UserInfo.getUserId();

        insert opp;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opp.Id,SBQQ__Account__c= acc.Id, SBQQ__StartDate__c = System.Today());
        insert quote;
        
        // Create Products
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].ProductCode = 'INST';
        if(!prodList.isEmpty()){
            insert prodList;
        }
        
       
        
        // Insert Products into Standard Pricebook
        List<PriceBookEntry> pbEntryStdPbList = new List<PriceBookEntry>();
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            //PricebookEntry pbe = new PricebookEntry(Pricebook2Id = priceBookList[0].id, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }
        
        ProductCodeVSOETier__c myTestRec = new ProductCodeVSOETier__c(name = 'INST',Tier_1_High__c=2, Tier_1_Low__c=1,Tier_2_High__c=2, Tier_2_Low__c=1,Tier_3_High__c=2, Tier_3_Low__c=1,Tier_4_High__c=2, Tier_4_Low__c=1,Tier_5_High__c=2, Tier_5_Low__c=1,Tier_6_High__c=2, Tier_6_Low__c=1);
        insert myTestRec;        
        ///
        MKT_TranslationTable__c launchPackProductItem =  new MKT_TranslationTable__c(ChildProduct__c = prodList[0].Id, ParentProduct__c=null, Total_Seats__c=10);
        insert launchPackProductItem;
        
        
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = opp.Id;
        oli1.PricebookEntryId = pbEntryStdPbList[0].Id;
        //oli1.PricebookEntryId = pbEntryStdPbList[0].Id;
        oli1.UnitPrice = 10;
        oli1.Quantity = 20;
        insert oli1;
        
        /*kumocomm__Transaction__c trans = new kumocomm__Transaction__c();
        trans.kumocomm__Amount__c = 56;
        insert trans; */
        Opportunity opp2 = new Opportunity();
                            opp2.Name      = 'GRAZITTI TEST OPPORTUNITY 2';
                            opp2.Type      = Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL;
                            opp2.Owner_Role_Custom_Text__c = 'ANZ PS';
                            opp2.AccountId = acc.Id;
                            opp2.PriceBook2Id = stdPbId;
                            opp2.Primary_Marketo_User_Lookup__c = con.Id;
                            opp2.Economic_Decision_Maker__c = con.Id;
                            opp2.Engagement_Manager__c = UserInfo.getUserId();
                            opp2.StageName = 'Discovery';
                            opp2.Amount   = 10000;
                            opp2.CloseDate = System.Now().Date();
                            //opp2.MKT_Transaction__c = trans.Id;
                            opp2.Intacct_Entity__c = ie2.Id;
                            opp2.Rep_Create_ARR__c=1;
                            opp2.MainCompetitor__c='Act-On';
                            opp2.Needs_Pains__c       ='Test Pain';
                            opp2.Use_Case__c          ='B2B';
        insert opp2;
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opp2.Id,SBQQ__Account__c= acc.Id, SBQQ__StartDate__c = System.Today());
        insert quote2;
        OpportunityLineItem oli2 = new OpportunityLineItem();
        oli2.OpportunityId = opp2.Id;
        oli2.PricebookEntryId = pbEntryStdPbList[0].Id;
        oli2.UnitPrice = 10;
        oli2.Quantity = 20;
        insert oli2;
        
        Opportunity opp3 = new Opportunity();
                            opp3.Name      = 'GRAZITTI TEST OPPORTUNITY 3';
                            opp3.Type      = 'Renewal';
                            opp3.Owner_Role_Custom_Text__c = 'ANZ PS';
                            opp3.AccountId = acc.Id;
                            opp3.Amount   = 10000;
                            opp3.PriceBook2Id = stdPbId;
                            opp3.StageName = 'A - Qualify';
                            opp3.Primary_Marketo_User_Lookup__c = con.Id;
                            opp3.Assets_created_on_closed_Won__c = true;
                            opp3.Economic_Decision_Maker__c = con.Id;
                            opp3.Engagement_Manager__c = UserInfo.getUserId();
                            opp3.Prior_Opportunity__c = opp.Id;
                            opp3.Intacct_Entity__c = ie.Id;
                            opp3.CloseDate = System.Now().Date();
                            opp3.Rep_Create_ARR__c=1;
                            opp3.MainCompetitor__c='Act-On';
                            opp3.Use_Case__c          ='B2B';
        insert opp3; 
        SBQQ__Quote__c quote3 = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opp3.Id,SBQQ__Account__c= acc.Id, SBQQ__StartDate__c = System.Today());
        insert quote3;
        OpportunityLineItem oli3 = new OpportunityLineItem();
        oli3.OpportunityId = opp3.Id;
        oli3.PricebookEntryId = pbEntryStdPbList[0].Id;
        oli3.UnitPrice = 10;
        oli3.Quantity = 20;
        
        insert oli3;        
        MKT_TranslationTable__c mkto = new MKT_TranslationTable__c ();
        mkto.ParentProduct__c = oli2.Product2Id;
        insert mkto;
        /*
        Deal_transaction__c D1 = new Deal_transaction__c(CurrencyIsoCode = 'USD', 
        Exchange_Rate_Of_Previous_Opportunity__c =1, 
        Account__c = opp2.AccountId,Opportunity__c= opp2.Id,
        Purchased_Close_Date__c = Date.Today(),Previous_Close_Date__c = Date.Today(),Purchased_Plan_of_Renewal_Date__c = Date.Today(),
        Previous_Plan_of_Renewal_Date__c = Date.Today(),Previous_Opportunity__c = opp.Id);
        Deal_transaction__c D2 = new Deal_transaction__c(CurrencyIsoCode = 'USD', 
        Exchange_Rate_Of_Previous_Opportunity__c =1, 
        Account__c = opp.AccountId,Opportunity__c= opp.Id,
        Purchased_Close_Date__c = Date.Today(),Previous_Close_Date__c = Date.Today(),Purchased_Plan_of_Renewal_Date__c = Date.Today(),
        Previous_Plan_of_Renewal_Date__c = Date.Today(),Previous_Opportunity__c = opp3.Id);

        insert new List<Deal_transaction__c>{D1,D2};
        */
        
        Set<Id> setOpIds = new Set<Id>();setOpIds.add(opp.Id);setOpIds.add(opp2.Id);setOpIds.add(opp3.Id);
        Trigger_Opportunity_Helper.retrievePartiallyUpdatedOLI(oli2.Id);
        
        
       //MKT_TranslationTable__c launchPackProductItem1=[SELECT ChildProduct__c, ParentProduct__c, Total_Seats__c FROM MKT_TranslationTable__c WHERE ParentProduct__c =:oli3.Product2Id];
    }
     static testmethod void TestTrigger_Opportunity_helper(){
        Opportunity oppRecord =[SELECT Id, Name,AccountId,StageName,Is_Winback_Created__c,SBQQ__PrimaryQuote__r.Country__c,SBQQ__PrimaryQuote__r.Country__r.Intacct_Entity__c,type,Prior_Opportunity__c FROM Opportunity WHERE Name = 'GRAZITTI TEST OPPORTUNITY 3' limit 1];
        Opportunity opp = Trigger_Opportunity_Helper.populateExchangeRateOnRenewalsOppty(oppRecord);   
    }
    /*static testmethod void UpdateOpportunityTestForOptimized_NB_Xsell(){
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
       Test.startTest();
       
     System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt2);
      //SalesTriggersUtility.marketoTriggerManager.Activate_Legacy_Triggers__c = False;
      
      // Create Custom Pricebooks
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(2);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }
        
        
        // Insert data for custom setting - SteelBrickCPQPricebook__c
        SteelBrickCPQPricebook__c obj = new SteelBrickCPQPricebook__c();
        obj.Name = 'SteelBrick PB';
        obj.ID__c = priceBookList[0].Id;
        insert obj;
        
        
        SalesTriggersUtility.Setvaluesfortest();
        Trigger_Opportunity_Helper.bofuWizardEnabledForUser = true;
        Map<Id,Opportunity> updateOpptyList2 = new Map<Id,Opportunity>();
        List<Opportunity> oppList = new List<Opportunity>([SELECT Id, Name,AccountId,StageName,Is_Winback_Created__c,SBQQ__PrimaryQuote__r.Country__c,SBQQ__PrimaryQuote__r.Country__r.Intacct_Entity__c FROM Opportunity WHERE Name like 'GRAZITTI TEST OPPORTUNITY %']);  
        
        System.Debug('oppList =='+oppList);
        Intacct_Entity__c ie = new Intacct_Entity__c();
        ie.Name = 'marketo-emea';
        insert ie;
        Intacct_Entity__c ie2 = new Intacct_Entity__c();
        ie2.Name = 'marketo-us';
        insert ie2;
      
        Map<Id,Country__c> contryList = new Map<Id,Country__c>();
        for(Opportunity op : oppList){
            if(op.StageName != 'Signed Order'){
                if(op.SBQQ__PrimaryQuote__r.Country__c != null){
                    Country__c cty = new Country__c(Id = op.SBQQ__PrimaryQuote__r.Country__c);
                    cty.Intacct_Entity__c = 'marketo-us';
                    contryList.put(op.SBQQ__PrimaryQuote__r.Country__c, cty);
                }
                op.Intacct_Entity__c = ie2.Id;
                op.Intacct_Sales_Region__c = 'APAC';
                //op.Third_Party_Solutions__c = 'No';
                op.Payment_Frequency__c = 'Annually';
                op.amount=10000;
                op.MainCompetitor__c='Act-On';
                
                op.StageName = 'Closed Won';
                op.MainCompetitor__c='Act-On';
            }
            
            updateOpptyList2.put(op.Id, op); 
        }
        if(!contryList.isEmpty()){
                update contryList.values();
            }
        update updateOpptyList2.values();
       
        Test.stopTest();
    }*/


    static testmethod void UpdateOpportunityTestForOptimized(){
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
     System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt2);
        
      //SalesTriggersUtility.marketoTriggerManager.Activate_Legacy_Triggers__c = False;
        SalesTriggersUtility.Setvaluesfortest();
        //System.Debug('##########AFTER UPDATE 2METHOD#######'+SalesTriggersUtility.marketoTriggerManager.Activate_Legacy_Triggers__c);
        Id stdPbId = Test.getStandardPricebookId();
        Intacct_Entity__c ie = new Intacct_Entity__c();
        ie.Name = 'marketo-emea';
        insert ie;
        Intacct_Entity__c ie2 = new Intacct_Entity__c();
        ie2.Name = 'marketo-us';
        insert ie2;    
        List<Opportunity> oppList = new List<Opportunity>([SELECT Id, Name,AccountId,StageName FROM Opportunity WHERE Name like 'GRAZITTI TEST OPPORTUNITY %']);
        List<Contact> conList = new List<Contact>([SELECT Id, AccountId, Email FROM Contact WHERE LastName = 'GRAZITTI TEST CONTACT 1']);
        
        //********* Products Insertion ************
        list<Product2> prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].ProductCode ='PARENT';// 'BNDL-ENT-MKTGAUTO';

        prodList[1].ProductCode = 'PROD-APPS-INST';
        prodList[2].ProductCode = 'PROD-PLAT-SANDBOX-INST';

        for(Product2 pd: prodList){
            pd.Product_Type__c         ='Subscription';
            pd.Family                  ='Services';
            pd.Product_SubFamily__c    = 'Launch Pack';
            pd.Product_SubFamily2__c   = 'Launch Pack Core';
        }//End of FOR

        if(!prodList.isEmpty()){
            prodList[0].Family ='Bundle';
            insert prodList;
        }//End of IF
        
        //*************** Inserting Pricebook ********************
        list<priceBook2> priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }//End of IF
        
        // Get Id of Standard Pricebook
         list<PriceBookEntry> pbEntryStdPbList = new list<PriceBookEntry>();
        //************** Insert Products into Standard Pricebook *******************
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }//End Of FOR
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }//End of IF
        
        //************ Insert Products into Custom Pricebooks ***************
        list<PriceBookEntry> pbEntryList = TestCPQUtilityClass.createPriceBookEntries(prodList, priceBookList);
        if(!pbEntryList.isEmpty()){
            insert pbEntryList;
        }//End of IF
        Test.startTest();
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        Opportunity opp4 = new Opportunity();
                            opp4.Name      = 'GRAZITTI TEST OPPORTUNITY 4';
                            opp4.Type      = 'Renewal';
                            opp4.Amount   = 10000;
                            opp4.Owner_Role_Custom_Text__c = 'ANZ PS';
                            opp4.AccountId = conList[0].AccountId;
                            opp4.StageName = 'A - Not Contacted';
                            if(!conList.isEmpty()){
                                opp4.Primary_Marketo_User_Lookup__c = conList[0].Id;
                                opp4.Economic_Decision_Maker__c = conList[0].Id;
                            }
                            opp4.Engagement_Manager__c = UserInfo.getUserId();
                            opp4.Assets_created_on_closed_Won__c = true;
                            opp4.PriceBook2Id = priceBookList[0].id;
                            opp4.Prior_Opportunity__c = oppList[0].Id;
                            opp4.CloseDate = System.Now().Date();
                            opp4.Intacct_Entity__c = ie.Id;
                            opp4.Rep_Create_ARR__c=1;
                            opp4.MainCompetitor__c='Act-On';
                            opp4.Needs_Pains__c       ='Test Pain';
                            opp4.Use_Case__c          ='B2B';
                            
                            
        insert opp4;
        
        
        List<Opportunity> oppListForOLI = new List<Opportunity>();
        oppListForOLI.add(opp4);
        
        List<OpportunityLineItem> oppotyLineItemList = new List<OpportunityLineItem>();
        oppotyLineItemList = TestCPQUtilityClass.createOppLineItems(oppListForOLI,pbEntryList);
        integer quantity= 1;
        for(OpportunityLineItem oli:oppotyLineItemList){
           oli.Users__c = 2;
           
           oli.quantity  = quantity;
           quantity++;
        }
     
        insert oppotyLineItemList;
       
        opp4.StageName = 'Signed Order';
        opp4.Stage_Signed_Order_Date__c = system.today();
        update opp4;
        
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opp4.Id,SBQQ__Account__c= oppList[0].AccountId, SBQQ__StartDate__c = System.Today(),Marketing_Permission__c = 'Need Customer Permission',SBQQ__Primary__c = true);
        insert quote2;
        
        opp4.StageName = 'Closed Won';
        opp4.Product_SVS__c = 'testtestetsetestesttestetstetstestetstestestetestestees';
        
        opp4.CloseDate = System.Now().Date().addDays(4);
        opp4.Intacct_Entity__c = ie2.Id;
        opp4.Intacct_Sales_Region__c = 'APAC';
        //opp4.Third_Party_Solutions__c = 'No';
        opp4.SBQQ__Renewal__c = true;
        
        Update opp4;
        
        delete opp4;
        
        opportunity opp5 = new Opportunity();
        opp5.Type= 'New Business';
        Trigger_Opportunity_Helper.opptyPriceBook(opp5);
        test.stopTest();
      
    }

    static testmethod void TestQuoteToAllEvent(){
    set<id> contracid = new set<id>();
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
     System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt2);
      //SalesTriggersUtility.marketoTriggerManager.Activate_Legacy_Triggers__c = False;
        SalesTriggersUtility.Setvaluesfortest();
        //System.Debug('##########AFTER UPDATE 2METHOD#######'+SalesTriggersUtility.marketoTriggerManager.Activate_Legacy_Triggers__c);
        Id stdPbId = Test.getStandardPricebookId();
        Intacct_Entity__c ie = new Intacct_Entity__c();
        ie.Name = 'marketo-emea';
        insert ie;
        Intacct_Entity__c ie2 = new Intacct_Entity__c();
        ie2.Name = 'marketo-us';
        insert ie2;    
        List<Opportunity> oppList = new List<Opportunity>([SELECT Id, Name,AccountId,StageName FROM Opportunity WHERE Name like 'GRAZITTI TEST OPPORTUNITY %']);
        List<Contact> conList = new List<Contact>([SELECT Id, AccountId, Email FROM Contact WHERE LastName = 'GRAZITTI TEST CONTACT 1']);
        
SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        
        
        Contract cont=new Contract();
        cont.Name='contact test Name';
        cont.AccountId=conList[0].AccountId;
        
        insert cont;
       contracid.add(cont.id);
         
        //********* Products Insertion ************
        list<Product2> prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].ProductCode ='PARENT';// 'BNDL-ENT-MKTGAUTO';

        prodList[1].ProductCode = 'PROD-APPS-INST';
        prodList[2].ProductCode = 'PROD-PLAT-SANDBOX-INST';

        for(Product2 pd: prodList){
            pd.Product_Type__c         ='Subscription';
            pd.Family                  ='Services';
            pd.Product_SubFamily__c    = 'Launch Pack';
            pd.Product_SubFamily2__c   = 'Launch Pack Core';
        }//End of FOR

        if(!prodList.isEmpty()){
            prodList[0].Family ='Bundle';
            insert prodList;
        }//End of IF
        
        //*************** Inserting Pricebook ********************
        list<priceBook2> priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }//End of IF
        
        // Get Id of Standard Pricebook
         list<PriceBookEntry> pbEntryStdPbList = new list<PriceBookEntry>();
        //************** Insert Products into Standard Pricebook *******************
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }//End Of FOR
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }//End of IF
        
        //************ Insert Products into Custom Pricebooks ***************
        list<PriceBookEntry> pbEntryList = TestCPQUtilityClass.createPriceBookEntries(prodList, priceBookList);
        if(!pbEntryList.isEmpty()){
            insert pbEntryList;
        }//End of IF
        
        Test.startTest();
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        Opportunity opp4 = new Opportunity();
                            opp4.Name      = 'DeleteMe';
                            opp4.Type      = 'Renewal';
                            opp4.Amount   = 10000;
                            opp4.Owner_Role_Custom_Text__c = 'ANZ PS';
                            opp4.AccountId = conList[0].AccountId;
                            opp4.StageName = 'A - Not Contacted';
                           
                            opp4.PriceBook2Id         = priceBookList[0].id;
                            if(!conList.isEmpty()){
                                opp4.Primary_Marketo_User_Lookup__c = conList[0].Id;
                                opp4.Economic_Decision_Maker__c = conList[0].Id;
                            }
                            opp4.Engagement_Manager__c = UserInfo.getUserId();
                            opp4.Assets_created_on_closed_Won__c = true;
                            opp4.Prior_Opportunity__c = oppList[0].Id;
                            opp4.CloseDate = System.Now().Date();
                            opp4.Intacct_Entity__c = ie.Id;
                            opp4.SBQQ__AmendedContract__c=cont.id;
                            opp4.Rep_Create_ARR__c=1;
                            opp4.MainCompetitor__c='Act-On';
                            opp4.Needs_Pains__c       ='Test Pain';
                            opp4.Use_Case__c='B2B';
                            opp4.Subscription_Language__c='English';
                            
        insert opp4;
        
        List<Opportunity> oppListForOLI = new List<Opportunity>();
        oppListForOLI.add(opp4);
        
        List<OpportunityLineItem> oppotyLineItemList = new List<OpportunityLineItem>();
        oppotyLineItemList = TestCPQUtilityClass.createOppLineItems(oppListForOLI,pbEntryList);
        integer quantity= 1;
        for(OpportunityLineItem oli:oppotyLineItemList){
           oli.Users__c = 2;
           
           oli.quantity  = quantity;
           quantity++;
        }
     
        insert oppotyLineItemList;
       
        opp4.Stage_Signed_Order_Date__c = system.today();
        opp4.StageName = 'Signed Order';
        update opp4;
        
        
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Honduras', SBQQ__Opportunity2__c=opp4.Id,SBQQ__Account__c= opp4.AccountId, SBQQ__StartDate__c = System.Today(),Marketing_Permission__c = 'Need Customer Permission',SBQQ__Primary__c = true,SBQQ__MasterContract__c=cont.id,SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice',SBQQ__SubscriptionTerm__c=12);
        insert quote2;
        
        opp4.StageName = 'Closed Won';
       
        opp4.CloseDate = System.Now().Date().addDays(4);
        opp4.Intacct_Entity__c = ie2.Id;
        opp4.Intacct_Sales_Region__c = 'APAC';
        //opp4.Third_Party_Solutions__c = 'No';
        opp4.SBQQ__Renewal__c = true;
        
        Update opp4;
        
        delete opp4;
        
        opportunity opp5 = new Opportunity();
        opp5.Type= 'New Business';
        Trigger_Opportunity_Helper.opptyPriceBook(opp5);
        RenewalTriggerMappingController.populateRenwalOpportunityFields(opplist,contracid);
        Test.stopTest();
    
    } 
    
    @isTest static void testOpportuityAPOR(){

        //********* Account Insertion ************
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        list<Account> accntList = TestCPQUtilityClass.createAccounts(1);
        System.debug('########## accntList: '+accntList);
        if(!accntList.isEmpty()){
            insert accntList;
        }//End of IF
         Test.StartTest();
         SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        //********* Products Insertion ************
        list<Product2> prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].ProductCode ='PARENT';// 'BNDL-ENT-MKTGAUTO';

        prodList[1].ProductCode = 'PROD-APPS-INST';
        prodList[2].ProductCode = 'PROD-PLAT-SANDBOX-INST';

        for(Product2 pd: prodList){
            pd.Product_Type__c         ='Subscription';
            pd.Family                  ='Services';
            pd.Product_SubFamily__c    = 'Launch Pack';
            pd.Product_SubFamily2__c   = 'Launch Pack Core';
        }//End of FOR

        if(!prodList.isEmpty()){
            prodList[0].Family ='Bundle';
            insert prodList;
        }//End of IF
        
        //*************** Inserting Pricebook ********************
        list<priceBook2> priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }//End of IF
        
        // Insert data for custom setting - SteelBrickCPQPricebook__c
        SteelBrickCPQPricebook__c obj = new SteelBrickCPQPricebook__c();
        obj.Name = 'SteelBrick PB';
        obj.ID__c = priceBookList[0].Id;
        insert obj;
        
        // Get Id of Standard Pricebook
        id stdPbId = Test.getStandardPricebookId();
         list<PriceBookEntry> pbEntryStdPbList = new list<PriceBookEntry>();
        //************** Insert Products into Standard Pricebook *******************
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }//End Of FOR
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }//End of IF
        
        //************ Insert Products into Custom Pricebooks ***************
        list<PriceBookEntry> pbEntryList = TestCPQUtilityClass.createPriceBookEntries(prodList, priceBookList);
        if(!pbEntryList.isEmpty()){
            insert pbEntryList;
        }//End of IF
        
        //********** Create New Business Opportunity **********
        List<Opportunity> oppotyList       = TestCPQUtilityClass.createOpportunities(accntList, 1);
        oppotyList[0].StageName            = 'A - Not Contacted';
        oppotyList[0].PriceBook2Id         = priceBookList[0].id;
        oppotyList[0].Quarterly_Renewal__c = string.valueof(2);
        oppotyList[0].Sub_End_Date__c      = System.Today().addMonths(1);
        oppotyList[0].type                 = 'New Business';
        oppotyList[0].Deal_Type__c         = 'Standard';
        oppotylist[0].Rep_Create_ARR__c    =1;
        oppotylist[0].Needs_Pains__c       ='Test Pain';
        oppotylist[0].MainCompetitor__c='Act-On';
        oppotylist[0].Use_Case__c='B2B';
        oppotylist[0].Subscription_Language__c ='English';
        oppotylist[0].Subscription_Locale__c='English-United States';
        oppotylist[0].Subscription_Time_Zone__c='Pacific Time (America/Los_Angeles)';
        
        insert oppotyList;
        
        
        List<OpportunityLineItem> oppotyLineItemList = new List<OpportunityLineItem>();
        oppotyLineItemList = TestCPQUtilityClass.createOppLineItems(oppotyList,pbEntryList);
     
        insert oppotyLineItemList;
        
        oppotyList[0].Stage_Signed_Order_Date__c = system.today();
        oppotyList[0].StageName            = 'Signed Order';
        oppotyList[0].Payment_Terms__c     = 'Payment_Terms__c';
        oppotyList[0].Compelling_Event__c  = 'Test Compelling_Event__c';
        update oppotyList; 
        
        oppotyList[0].StageName            = 'Closed Won';
        update oppotyList;
         
        
        //********** Create Upsell Opportunity **********
        List<Opportunity> UpsellOpptyList       = TestCPQUtilityClass.createOpportunities(accntList, 1);
        UpsellOpptyList[0].StageName            = 'A - Not Contacted';
        UpsellOpptyList[0].PriceBook2Id         = priceBookList[0].id;
        UpsellOpptyList[0].Quarterly_Renewal__c = string.valueof(2);
        UpsellOpptyList[0].Sub_End_Date__c      = System.Today().addMonths(1);
        UpsellOpptyList[0].type                 = 'Upsell/Crossell';
        UpsellOpptyList[0].Deal_Type__c         = 'Standard';
        UpsellOpptyList[0].Rep_Create_ARR__c    = 1;
        UpsellOpptyList[0].Payment_Terms__c     = 'Payment_Terms__c';
        
        insert UpsellOpptyList;
        
        List<OpportunityLineItem> upsellOLI = new List<OpportunityLineItem>();
        upsellOLI = TestCPQUtilityClass.createOppLineItems(UpsellOpptyList,pbEntryList);
     
        insert upsellOLI;
        

        
        UpsellOpptyList[0].Stage_Signed_Order_Date__c = system.today();
        UpsellOpptyList[0].StageName='Signed Order';
        
        update UpsellOpptyList;
        
        list<Opportunity> allOppList = new list<Opportunity>();
        allOppList.addAll(UpsellOpptyList);
        allOppList.addAll(oppotyList);
           
        list<OpportunityLineItem>  newOLIList = TestCPQUtilityClass.createOppLineItems(allOppList,pbEntryList);
        insert newOLIList;
        //*********** Create Quote on upsell ***********
        List<SBQQ__Quote__c> UpsellquoteList = TestCPQUtilityClass.createQuotes(UpsellOpptyList,  1);
        List<SBQQ__Quote__c> InsertUpsellquotList = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote : UpsellquoteList){
            quote.SBQQ__Primary__c = true;
            quote.Rubiks_Quote__c=false;
            InsertUpsellquotList.add(quote);
        }
       
        insert InsertUpsellquotList;
        
        
        
        //********** Closing the Upsell Opportunity ***********
        UpsellOpptyList[0].Prior_Opportunity__c = oppotyList[0].id;
        UpsellOpptyList[0].StageName = 'Closed Won';
        Update UpsellOpptyList;
        
        
        Test.StopTest();
    }//End of method test_YTDBlendedDisc3()

    @isTest static void testExchangeRate(){
        //********* Account Insertion ************
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        list<Account> accntList = TestCPQUtilityClass.createAccounts(1);
        System.debug('########## accntList: '+accntList);
        accntList[0].CAM_Owner__c = userinfo.getuserid();
        if(!accntList.isEmpty()){
            insert accntList;
        }//End of IF
        test.startTest();
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        //********* Products Insertion ************
        list<Product2> prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].ProductCode ='PARENT';// 'BNDL-ENT-MKTGAUTO';

        prodList[1].ProductCode = 'PROD-APPS-INST';
        prodList[2].ProductCode = 'PROD-PLAT-SANDBOX-INST';

        for(Product2 pd: prodList){
            pd.Product_Type__c         ='Subscription';
            pd.Family                  ='Services';
            pd.Product_SubFamily__c    = 'Launch Pack';
            pd.Product_SubFamily2__c   = 'Launch Pack Core';
        }//End of FOR

        if(!prodList.isEmpty()){
            prodList[0].Family ='Bundle';
            insert prodList;
        }//End of IF
        
        //*************** Inserting Pricebook ********************
        list<priceBook2> priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }//End of IF
        
        // Get Id of Standard Pricebook
        id stdPbId = Test.getStandardPricebookId();
         list<PriceBookEntry> pbEntryStdPbList = new list<PriceBookEntry>();
        //************** Insert Products into Standard Pricebook *******************
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }//End Of FOR
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }//End of IF
        
        //************ Insert Products into Custom Pricebooks ***************
        list<PriceBookEntry> pbEntryList = TestCPQUtilityClass.createPriceBookEntries(prodList, priceBookList);
        if(!pbEntryList.isEmpty()){
            insert pbEntryList;
        }//End of IF
         List<Opportunity> NewoppotyList       = TestCPQUtilityClass.createOpportunities(accntList, 1);
         NewoppotyList[0].Use_Case__c='B2B';
         insert NewoppotyList;
        
        
           
        //********** Create New Business Opportunity **********
        List<Opportunity> oppotyList       = TestCPQUtilityClass.createOpportunities(accntList, 3);
        oppotyList[0].StageName            = 'Not Contacted';
        oppotyList[0].PriceBook2Id         = priceBookList[0].id;
        oppotyList[0].Quarterly_Renewal__c = string.valueof(2);
        oppotyList[0].Sub_End_Date__c      = System.Today().addMonths(1);
        oppotyList[0].type                 = 'Renewal';
        oppotyList[0].Use_Case__c          ='B2B';
        oppotyList[0].Needs_Pains__c       ='Test Pain';
        oppotyList[0].Prior_Opportunity__c = NewoppotyList[0].id;
        oppotyList[0].Deal_Type__c         = 'Standard';
        oppotyList[0].Payment_Terms__c     = 'Payment Due on Receipt of Invoice';
        oppotyList[0].CurrencyIsoCode      = 'EUR';
        oppotyList[1].StageName            = '3 - Solution DefinitionUndo';
        oppotyList[1].PriceBook2Id         = priceBookList[0].id;
        oppotyList[1].Quarterly_Renewal__c = string.valueof(2);
        oppotyList[1].Sub_End_Date__c      = System.Today().addMonths(1);
        oppotyList[1].Needs_Pains__c       ='Test Pain';
        oppotyList[1].Use_Case__c          ='B2B';
        oppotyList[1].type                 = 'New Business';
        oppotyList[1].Deal_Type__c         = 'Standard';
        oppotyList[1].Payment_Terms__c     = 'Payment Due on Receipt of Invoice';
        oppotyList[1].CurrencyIsoCode      = 'EUR';
        oppotyList[2].CurrencyIsoCode      = 'EUR';
        oppotyList[2].amount               = 233;
        oppotyList[2]. Rep_Create_ARR__c   =1;
        oppotyList[2].Needs_Pains__c       ='Test Pain';
        oppotyList[2].Use_Case__c          ='B2B';
        oppotyList[2].Payment_Terms__c     = 'Payment Due on Receipt of Invoice';
        //RenewalTriggerMappingController.RenewalOppOwnerFlage=true;
        insert oppotyList;
       
         List<Opportunity> QuoteoppotyList       = new list <Opportunity>();
         QuoteoppotyList.addAll(oppotyList);
         QuoteoppotyList.remove(1);
        List<SBQQ__Quote__c> newquoteList = TestCPQUtilityClass.createQuotes(QuoteoppotyList,  1);
        for(SBQQ__Quote__c q: newquoteList){
            q.SBQQ__Primary__c=true;
            q.New_Logo_Term_Promotions__c = '3+9: 90-day early termination';
            q.SBQQ__StartDate__c = system.today()+40;
            q.SBQQ__PaymentTerms__c = 'Payment Due on Receipt of Invoice';
            q.SBQQ__SubscriptionTerm__c=12;
        }
        insert newquoteList;
        oppotyList[1].stageName='Closed Won';
        oppotyList[0].SBQQ__PrimaryQuote__c = newquoteList[0].id;
        update oppotyList;
      
            Trigger_Opportunity_Helper.TestOppty();
        test.stopTest();
    } 
     public static testMethod void testBilltoShipToUpdate(){      
        // Create accounts to insert
        Set<Id> accountsToInsertSet = new Set<Id>();
        map<id, id> AccToCont = new Map<id,id>();
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
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
        
         Test.startTest();
         SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
    for(Account acc : accountsToInsertList){
      accountsToInsertSet.add(acc.Id);
    }
             
        list<Contact> ContactToInsert = new list<Contact>();
        ContactToInsert = TestCPQUtilityClass.createContacts(accountsToInsertList,2);
        //Contact con = new Contact(firstname='First Name', lastname='Last Name', AccountId=accountsToInsertList[0].id);
        User newUser =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser', 'Mkto', 'cfsId');
        newUser.EmployeeNumber='1345';
        Insert newUSer;
        
        ContactToInsert[0].pse__Salesforce_User__c = UserInfo.getUserId();
        ContactToInsert[0].pse__Is_Resource__c = True;
        ContactToInsert[0].pse__Is_Resource_Active__c = True;
        ContactToInsert[1].pse__Salesforce_User__c = newUSer.id;
        ContactToInsert[1].pse__Is_Resource__c = True;
        ContactToInsert[1].pse__Is_Resource_Active__c = True;
        insert ContactToInsert[0];
        //insert ContactToInsert[1];
        
        for(Contact c: ContactToInsert){
            if(c.id != Null && c.AccountId !=Null){
                AccToCont.put(c.AccountId , c.id);
            }
        }
        // insert products into standard pricebook
        Id stdPricebookId = Test.getStandardPricebookId();
        
        // Create custom pricebooks
        List<PriceBook2> pricebookList = new List<PriceBook2>();
        pricebookList =TestCPQUtilityClass.createCustomPriceBooks(5);
        insert pricebookList;
       
        // Insert data for custom setting - SteelBrickCPQPricebook__c
        SteelBrickCPQPricebook__c obj = new SteelBrickCPQPricebook__c();
        obj.Name = 'SteelBrick PB';
        obj.ID__c = priceBookList[0].Id;
        insert obj;
        
        
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
            opp.StageName='Prospecting';
            opp.Payment_Terms__c       = 'Payment_Terms__c';
            if(AccToCont.containsKey(opp.AccountId)){
                opp.Primary_Marketo_User_Lookup__c = AccToCont.get(opp.AccountId) ;
                opp.Primary_Marketo_User_Email__c = 'test.abc@jade.com' ;
            }
        }
       
       
      Trigger_Opportunity_Helper.isAfterUpdateEvent = true;
        if(!opptyList.isEmpty()){
            insert opptyList;
        }
       
        System.debug('opptyList[0].Accountid...'+opptyList[0].Accountid);
        List<SBQQ__Quote__c> newquotList=  TestCPQUtilityClass.createSimpleQuote(opptyList,1);
        for(SBQQ__Quote__c SBQuote :newquotList){ 
            SBQuote.Rubiks_Quote__c = true;
            SBQuote.Bill_To_Contact__c = ContactToInsert[0].id;
             SBQuote.Ship_To_Contact__c= ContactToInsert[0].id;
             SBQuote.SBQQ__Primary__c =true;
        }
        insert newquotList;
         
         List<Opportunity> opptyUpdateList = new List<Opportunity>();
          for(Opportunity opp : opptyList){
              
           opp.stageName= Label.OPPORTUNITY_STAGE_CLOSED_WON;
           opptyUpdateList.add(opp);
          }
      
       Trigger_Opportunity_Helper.isAfterUpdateEvent = false;
    
        update opptyUpdateList;
       
        Test.stopTest();
       }//testBilltoShipToUpdate
   
    public static testMethod void populateRenewalOppFields(){
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        List<Account> accList = TestCPQUtilityClass.createAccounts(1);
        List<Contact> contactList = TestCPQUtilityClass.createContacts(accList, 1);
        List<Opportunity> oppList = TestCPQUtilityClass.createOpportunities(accList, 1);
        
        insert accList;
        insert contactList;
        
           //********* Products Insertion ************
        list<Product2> prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].ProductCode ='PARENT';// 'BNDL-ENT-MKTGAUTO';

        prodList[1].ProductCode = 'PROD-APPS-INST';
        prodList[2].ProductCode = 'PROD-PLAT-SANDBOX-INST';

        for(Product2 pd: prodList){
            pd.Product_Type__c         ='Subscription';
            pd.Family                  ='Services';
            pd.Product_SubFamily__c    = 'Launch Pack';
            pd.Product_SubFamily2__c   = 'Launch Pack Core';
        }//End of FOR

        if(!prodList.isEmpty()){
            prodList[0].Family ='Bundle';
            insert prodList;
        }//End of IF
        
        //*************** Inserting Pricebook ********************
        list<priceBook2> priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }//End of IF
        
        // Get Id of Standard Pricebook
         list<PriceBookEntry> pbEntryStdPbList = new list<PriceBookEntry>();
        //************** Insert Products into Standard Pricebook *******************
        
        Id stdPbId = Test.getStandardPricebookId();
        
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }//End Of FOR
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }//End of IF
        
        //************ Insert Products into Custom Pricebooks ***************
        list<PriceBookEntry> pbEntryList = TestCPQUtilityClass.createPriceBookEntries(prodList, priceBookList);
        if(!pbEntryList.isEmpty()){
            insert pbEntryList;
        }//End of IF
          Marketo_Trigger_Management__c MKTOTriggerManagement = new Marketo_Trigger_Management__c();
        MKTOTriggerManagement.Deactivate_Contract_Triggers__c = true;
        insert MKTOTriggerManagement;
        
        
        Contract cont=new Contract();
         cont.AccountId = accList[0].Id;
         cont.Name = 'test';
         
         insert cont;
          Test.startTest();
          SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
         cont.SBQQ__RenewalQuoted__c = true;
         cont.SBQQ__Opportunity__c = oppList[0].Id;
         update cont;
        
        Intacct_Entity__c ie = new Intacct_Entity__c();
        ie.Name = 'marketo-emea';
        insert ie;
        
        Intacct_Entity__c ie1 = new Intacct_Entity__c();
        ie1.Name = 'marketo-us';
        insert ie1;
        
        oppList[0].AccountId = accList[0].Id;
        oppList[0].Needs_Pains__c       ='Test Pain';
        oppList[0].Use_Case__c          ='B2B';
        oppList[0].StageName            = 'Not Contacted';
        oppList[0].PriceBook2Id         = priceBookList[0].id;
        oppList[0].Quarterly_Renewal__c = string.valueof(2);
        oppList[0].Sub_End_Date__c      = System.Today().addMonths(1);
        oppList[0].type                 = 'Renewal';
        oppList[0].Intacct_Entity__c    = ie.id;
       // oppList[0].Prior_Opportunity__c = oppList[0].id;
        oppList[0].Deal_Type__c         = 'Standard';
        oppList[0].CurrencyIsoCode      = 'USD';
        
        Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
        Trigger_Opportunity_Helper.isBeforeInsertEvent = true;
        if(!oppList.isEmpty()){
            insert oppList;
        }
         
        List<Opportunity> oppListForOLI = new List<Opportunity>();
        oppListForOLI.add(oppList[0]);
        
        List<OpportunityLineItem> oppotyLineItemList = new List<OpportunityLineItem>();
        oppotyLineItemList = TestCPQUtilityClass.createOppLineItems(oppListForOLI,pbEntryList);
        integer quantity= 1;
        for(OpportunityLineItem oli:oppotyLineItemList){
           oli.Users__c = 2;
           oli.quantity  = quantity;
           quantity++;
        }
     
        insert oppotyLineItemList;
       
        oppList[0].StageName = 'Signed Order';
        oppList[0].Stage_Signed_Order_Date__c = system.today();
        oppList[0].Payment_Terms__c    = 'Payment_Terms__c';
        oppList[0].Intacct_Entity__c    = ie1.id;
        update oppList[0];
        
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=oppList[0].Id,SBQQ__Account__c= oppList[0].AccountId, SBQQ__StartDate__c = System.Today(),Marketing_Permission__c = 'Need Customer Permission',SBQQ__Primary__c = true,SBQQ__MasterContract__c=cont.id,SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice',SBQQ__SubscriptionTerm__c=12);
        insert quote2;
       
        Intacct_Entity__c ie2 = new Intacct_Entity__c();
        ie2.Name = 'marketo-us';
        insert ie2;
        
        oppList[0].StageName = 'Closed Won';
        
        oppList[0].CloseDate = System.Now().Date().addDays(4);
        oppList[0].Intacct_Entity__c = ie2.Id;
        oppList[0].Intacct_Sales_Region__c = 'APAC';
        //oppList[0].Third_Party_Solutions__c = 'No';
        oppList[0].SBQQ__Renewal__c = true;
        
        oppList[0].SBQQ__RenewedContract__c = cont.Id;
        Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
        Trigger_Opportunity_Helper.isBeforeInsertEvent = true;
        Update oppList[0];
        
        cont.SBQQ__Opportunity__c = oppList[0].Id;
        update cont;
        
        List<Opportunity> oppListcheck = [Select Id from Opportunity where SBQQ__RenewedContract__c != null ];
        
        system.assertEquals(1,oppListcheck.size());    
       
        List<Opportunity> oppList_new = TestCPQUtilityClass.createOpportunities(accList, 1);
        
        oppList_new[0].Needs_Pains__c       ='Test Pain';
        oppList_new[0].Use_Case__c          ='B2B';
        oppList_new[0].StageName            = 'Not Contacted';
        oppList_new[0].Payment_Terms__c    = 'Payment_Terms__c';
        oppList_new[0].PriceBook2Id         = priceBookList[0].id;
        oppList_new[0].Quarterly_Renewal__c = string.valueof(2);
        oppList_new[0].Sub_End_Date__c      = System.Today().addMonths(1);
        oppList_new[0].type                 = 'Renewal';
        oppList_new[0].Prior_Opportunity__c = oppList[0].id;
        oppList_new[0].Deal_Type__c         = 'Standard';
        oppList_new[0].CurrencyIsoCode      = 'USD';
        oppList_new[0].SBQQ__Renewal__c = true;
        insert oppList_new;
        
        //oppList_new[0].SBQQ__RenewedContract__c = cont.Id;
        
        Renewal_Opportunity_Fields__c testRecord = new Renewal_Opportunity_Fields__c(Name= 'Account', Field_API_Name__c='AccountId');
        
        insert testRecord;
        
        cont.SBQQ__RenewalOpportunity__c = oppList_new[0].Id;
        update cont;
        
        Opportunity op = Trigger_Opportunity_Helper.updateOpportunityLists(oppList[0]);
        Trigger_Opportunity_Helper.populateRenwalOpptyFields();
        
        List<Renewal_Opportunity_Fields__c> RenewalOppField = new List<Renewal_Opportunity_Fields__c>();
        
        //insert RenewalOppField;
        
        List<Renewal_Opportunity_Fields__c> RenewalOppFieldTest = Renewal_Opportunity_Fields__c.getAll().values();
        
        // method called to cover OpportunityCreateBOFU 
        PageReference testPage = new pagereference('/apex/OpportunityCreateBOFU');
        Test.setCurrentPage(testPage); 
        //PageReference.getParameters().put('id', myID);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(oppList[0]); 
        OpportunityCreateBOFU dutchCont = new OpportunityCreateBOFU(sc);
        dutchCont.save();
        // end of method
        
        Test.stopTest();
    }
    
    
    public static testMethod void TestOpportunityBOFOPagePopulation(){
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        List<Account> accList = TestCPQUtilityClass.createAccounts(1);
        accList[0].BillingStreet    = '1';
        accList[0].BillingCity      = 'Farmington';
        accList[0].BillingState     = 'Honduras';
        accList[0].BillingPostalCode = '06032';
        accList[0].BillingCountry   = 'Honduras';
        List<Contact> contactList = TestCPQUtilityClass.createContacts(accList, 1);
        List<Opportunity> oppList = TestCPQUtilityClass.createOpportunities(accList, 1);
        
        insert accList;
        insert contactList;
        
           //********* Products Insertion ************
        list<Product2> prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].ProductCode ='PARENT';// 'BNDL-ENT-MKTGAUTO';

        prodList[1].ProductCode = 'PROD-APPS-INST';
        prodList[2].ProductCode = 'PROD-PLAT-SANDBOX-INST';

        for(Product2 pd: prodList){
            pd.Product_Type__c         ='Subscription';
            pd.Family                  ='Services';
            pd.Product_SubFamily__c    = 'Launch Pack';
            pd.Product_SubFamily2__c   = 'Launch Pack Core';
        }//End of FOR

        if(!prodList.isEmpty()){
            prodList[0].Family ='Bundle';
            insert prodList;
        }//End of IF
        
        //*************** Inserting Pricebook ********************
        list<priceBook2> priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }//End of IF
        
        // Get Id of Standard Pricebook
         list<PriceBookEntry> pbEntryStdPbList = new list<PriceBookEntry>();
        //************** Insert Products into Standard Pricebook *******************
        
        Id stdPbId = Test.getStandardPricebookId();
        
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }//End Of FOR
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }//End of IF
        
        //************ Insert Products into Custom Pricebooks ***************
        list<PriceBookEntry> pbEntryList = TestCPQUtilityClass.createPriceBookEntries(prodList, priceBookList);
        if(!pbEntryList.isEmpty()){
            insert pbEntryList;
        }//End of IF
        
          Marketo_Trigger_Management__c MKTOTriggerManagement = new Marketo_Trigger_Management__c();
        MKTOTriggerManagement.Deactivate_Contract_Triggers__c = true;
        insert MKTOTriggerManagement;
        
        Contract cont=new Contract();
         cont.AccountId = accList[0].Id;
         cont.Name = 'test';
         
         insert cont;
          Test.startTest();
          SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
         cont.SBQQ__RenewalQuoted__c = true;
         cont.SBQQ__Opportunity__c = oppList[0].Id;
         update cont;
        
        Intacct_Entity__c ie = new Intacct_Entity__c();
        ie.Name = 'marketo-emea';
        insert ie;
        
        Intacct_Entity__c ie1 = new Intacct_Entity__c();
        ie1.Name = 'marketo-us';
        insert ie1;
        
        oppList[0].AccountId = accList[0].Id;
        oppList[0].Needs_Pains__c       ='Test Pain';
        oppList[0].Use_Case__c          ='B2B';
        oppList[0].StageName            = 'Not Contacted';
        oppList[0].PriceBook2Id         = priceBookList[0].id;
        oppList[0].Quarterly_Renewal__c = string.valueof(2);
        oppList[0].Sub_End_Date__c      = System.Today().addMonths(1);
        oppList[0].type                 = 'New Business';
        oppList[0].Intacct_Entity__c    = ie.id;
        oppList[0].Deal_Type__c         = 'Standard';
        oppList[0].CurrencyIsoCode      = 'USD';
        
        if(!oppList.isEmpty()){
            insert oppList;
        }
        
        List<Opportunity> oppListForOLI = new List<Opportunity>();
        oppListForOLI.add(oppList[0]);
        
        List<OpportunityLineItem> oppotyLineItemList = new List<OpportunityLineItem>();
        oppotyLineItemList = TestCPQUtilityClass.createOppLineItems(oppListForOLI,pbEntryList);
        integer quantity= 1;
        for(OpportunityLineItem oli:oppotyLineItemList){
           oli.Users__c = 2;
           oli.quantity  = quantity;
           quantity++;
        }
     
        insert oppotyLineItemList;
       
        oppList[0].StageName = 'Signed Order';
        oppList[0].Stage_Signed_Order_Date__c = system.today();
        oppList[0].Payment_Terms__c    = 'Payment_Terms__c';
        oppList[0].Intacct_Entity__c    = ie1.id;       
        oppList[0].Compelling_Event__c  = 'Test Compelling_Event__c';
        update oppList[0];
        
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c = oppList[0].Id,SBQQ__Account__c= oppList[0].AccountId, SBQQ__StartDate__c = System.Today(),Marketing_Permission__c = 'Need Customer Permission',SBQQ__Primary__c = true,SBQQ__MasterContract__c=cont.id,SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice',SBQQ__SubscriptionTerm__c=12);
        insert quote2;
    }
    
    static testMethod void testOpportunityForPhoenix(){
        Intacct_Entity__c ie = new Intacct_Entity__c();
        ie.Name = 'marketo-emea';
        insert ie;
        
   
        Country__c  con = new Country__c (name='Canada',Country_Registered_Office_Address__c='San Mateo, CA, 94404',Region__c='North America',Marketo_Entity__c='Marketo, Inc.',Intacct_Entity__c='marketo-us',Data_Center__c='US');
        insert con;
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        List<Account> accList = TestCPQUtilityClass.createAccounts(1);
       insert accList;
        
          List<Contact> contactList = TestCPQUtilityClass.createContacts(accList, 1);
        insert contactList;
        List<Opportunity> oppList = TestCPQUtilityClass.createOpportunities(accList, 2);
        
           //********* Products Insertion ************
        list<Product2> prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].ProductCode ='PARENT';// 'BNDL-ENT-MKTGAUTO';

        prodList[1].ProductCode = 'PROD-APPS-INST';
        prodList[2].ProductCode = 'PROD-PLAT-SANDBOX-INST';

        for(Product2 pd: prodList){
            pd.Product_Type__c         ='Subscription';
            pd.Family                  ='Services';
            pd.Product_SubFamily__c    = 'Launch Pack';
            pd.Product_SubFamily2__c   = 'Launch Pack Core';
        }//End of FOR

        if(!prodList.isEmpty()){
            prodList[0].Family ='Bundle';
            insert prodList;
        }//End of IF
        
        //*************** Inserting Pricebook ********************
        list<priceBook2> priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }//End of IF
        
        // Get Id of Standard Pricebook
         list<PriceBookEntry> pbEntryStdPbList = new list<PriceBookEntry>();
        //************** Insert Products into Standard Pricebook *******************
        
        Id stdPbId = Test.getStandardPricebookId();
        
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }//End Of FOR
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }//End of IF
        
        //************ Insert Products into Custom Pricebooks ***************
        list<PriceBookEntry> pbEntryList = TestCPQUtilityClass.createPriceBookEntries(prodList, priceBookList);
        if(!pbEntryList.isEmpty()){
            insert pbEntryList;
        }//End of IF
        
       
        
        oppList[0].AccountId = accList[0].Id;
        oppList[0].Needs_Pains__c       ='Test Pain';
        oppList[0].Use_Case__c          ='B2B';
        oppList[0].StageName            = 'Not Contacted';
        oppList[0].PriceBook2Id         = priceBookList[0].id;
        oppList[0].Quarterly_Renewal__c = string.valueof(2);
        oppList[0].Sub_End_Date__c      = System.Today().addMonths(1);
        oppList[1].type                 = Label.OPPORTUNITY_TYPE_RENEWAL;
        oppList[0].Intacct_Entity__c    = ie.id;
        oppList[0].Use_Case__c='B2B';
        oppList[1].Use_Case__c='B2B';
         oppList[0].ToutApp_Migrated__c=true;
          oppList[1].ToutApp_Migrated__c=true;
       // oppList[0].Prior_Opportunity__c = oppList[0].id;
        oppList[0].Deal_Type__c         = 'Standard';
        oppList[0].CurrencyIsoCode      = 'USD';
        test.startTest();
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
        Trigger_Opportunity_Helper.isBeforeInsertEvent = true;
        if(!oppList.isEmpty()){
            insert oppList;
        }
         
       SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED  = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_AfterInsert = true;
        SBQQQuoteTriggerHandler.IS_OPPTY_UPDATED_Afterupdate = true;
        SBQQQuoteTriggerHandler.IS_ACCOUNT_UPDATED = true;
      
      
     List<SBQQ__Quote__c> newquotList=  TestCPQUtilityClass.createSimpleQuote(oppList,1);
        for(SBQQ__Quote__c SBQuote :newquotList){
            SBQuote.Rubiks_Quote__c = true;
            SBQuote.SBQQ__Primary__c= true;
            SBQuote.SBQQ__ShippingCountry__c=con.name;
        }
        insert newquotList;
        
        SBQQ__Quote__c QuoteforOppty =[SELECT id FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c=:oppList[0].id];
        SBQQ__Quote__c QuoteforOppty1 =[SELECT id FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c=:oppList[1].id];
           Marketo_Trigger_Management__c MKTOTriggerManagement = new Marketo_Trigger_Management__c();
        MKTOTriggerManagement.Deactivate_Contract_Triggers__c = true;
        insert MKTOTriggerManagement;
        
         
        Contract contract1 = new Contract(Name='Test Contract ', AccountId=oppList[1].AccountId,SBQQ__Opportunity__c = oppList[0].Id, StartDate=System.today(), By_Pass_Contract_Workflow__c =true, SBQQ__Quote__c = QuoteforOppty.Id,ContractTerm = 12);         
        
        insert contract1 ;
        
        oppList[0].StageName = 'Signed Order';
        oppList[0].Stage_Signed_Order_Date__c = system.today();
        oppList[0].Payment_Terms__c    = 'Payment_Terms__c';
       
        oppList[0].Intacct_Entity__c    = ie.id;
         oppList[0].SBQQ__PrimaryQuote__c=QuoteforOppty.id;
         oppList[1].SBQQ__PrimaryQuote__c=QuoteforOppty1.id ;
        oppList[1].Prior_Opportunity__c= oppList[0].id;
        oppList[0].Deal_Type__c='University';
         oppList[0].Name = 'University Test Class Validation'; 
         oppList[1].Deal_Type__c='University';
         oppList[1].Name = 'University Test Class Validation'; 
        update oppList;
        OpportunityCreateBOFU.inBofuScreen=true;
         oppList[1].Stage_Signed_Order_Date__c = system.today();

        oppList[1].StageName = 'Signed Order';
        
         Trigger_Opportunity_Helper.isBeforeUpdateEvent = false; 
         update oppList;
        
        opportunity oppQuote= [SELECT id FROM Opportunity WHERE id=:oppList[0].id and SBQQ__PrimaryQuote__c!=null];
        SBQQ__Quote__c QuoteforOppty11 =[SELECT id,Rubiks_Quote__c FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__r.Prior_Opportunity__c!=null AND SBQQ__Opportunity2__c=:oppList[1].id AND  SBQQ__Opportunity2__r.type=:Label.OPPORTUNITY_TYPE_RENEWAL];
      Test.stoptest();
        
    
    }//End of method testOpportunityForPhoenix
}