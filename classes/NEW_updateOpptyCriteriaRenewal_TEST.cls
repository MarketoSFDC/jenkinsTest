/*******************************************************
Modified By : Sumit Bhatt, Grazitti Interactive
Modified date : 7/27/2018
Purpose : Commented the field that are used in field removal project 
refrence : APPS-20840 Field Cleanup Project - Phase One
log of fields commented : Opportunity: third_party_solutions__c

 Modified By :Jade Global 31th August 2018
 Change      : Removed closedWonRecordTypeId   variable from class
*******************************************************/
@isTest
public class NEW_updateOpptyCriteriaRenewal_TEST {
    
    

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
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA = true;
        
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
        AssignNBAEPerRules.ANFirstPass = True;
        Utility.isUpdateContactOwnerAsAccountOwnerRunningOnceMore = true;
        SfdcJiveHelper.RunIntegrationTriggerOnceAcc=true;
        Trigger_Opportunity_Helper.bofuWizardEnabledForUser = false;
        List<Opportunity> oppLists = new List<Opportunity>();
        
        Intacct_Entity__c ie = new Intacct_Entity__c();
        ie.Name = 'marketo-emea';
        insert ie;
        Intacct_Entity__c ie2 = new Intacct_Entity__c();
        ie2.Name = 'marketo-us';
        insert ie2;
        
         Account acc = new Account();
                        acc.Name                 = 'GRAZITTI TEST ACCOUNT 1 test account duplicate';
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
                        con.FirstName = 'test';
                        con.LastName   = 'GRAZITTI TEST CONTACT 1';
                        con.email      = 'testsdgshgdhsgd@test.com';
                        con.LeadSource = 'Blog';
                        con.AccountId  = acc.Id;
        insert con;
        Contact con2 = new Contact();
                        con2.FirstName = 'testsdgfhgdfsh';
                        con2.LastName   = 'GRAZITTI TEST CONTACT 12';
                        con2.email      = 'testsdghfgsdg@test.com';
                        con2.LeadSource = 'Blog';
                        con2.AccountId  = acc.Id;
        insert con2;
        
        
        Role_Geographical_Segmentation_Setting__c rgs = new Role_Geographical_Segmentation_Setting__c();
        rgs.Name = 'ANZ PS';
        insert rgs; 
        
        Id stdPbId = Test.getStandardPricebookId();
        
        Opportunity opp = new Opportunity();
                            opp.Name      = 'GRAZITTI TEST OPPORTUNITY 1 shafheafgh';
                            opp.AccountId = acc.Id;
                            opp.Type      = 'Renewal';
                            opp.StageName = 'A - Qualify';
                            opp.Amount   = 10000;
                            opp.PriceBook2Id = stdPbId;
                            opp.Rep_Create_ARR__c = 10;
                            opp.MainCompetitor__c = 'Act-On';
                            opp.Primary_Marketo_User_Lookup__c = con.Id;
                            opp.Economic_Decision_Maker__c = con.Id;
                            opp.Engagement_Manager__c = UserInfo.getUserId();
                            opp.SBQQ__Contracted__c = true;
                            opp.Intacct_Sales_Region__c = '';
                            opp.Owner_Role_Custom_Text__c = 'ANZ PS';
                            opp.Intacct_Entity__c = ie.Id;
                            opp.Migration__c =true;
                            opp.CloseDate = System.Now().Date();
                            opp.Sub_End_Date__c = System.Now().Date().addDays(300);

        insert opp;
        OpportunityContactRole oc  = new OpportunityContactRole();
        oc.ContactId = con.Id;
        oc.OpportunityId = opp.Id;
        oc.IsPrimary = true;
        insert oc;
        OpportunityContactRole oc2  = new OpportunityContactRole();
        oc2.ContactId = con2.Id;
        oc2.OpportunityId = opp.Id;
        insert oc2;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opp.Id,SBQQ__Account__c= acc.Id, SBQQ__StartDate__c = System.Today());
        insert quote;
        
        // Create Products
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].ProductCode = 'INST';
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
        
        ProductCodeVSOETier__c myTestRec = new ProductCodeVSOETier__c(name = 'INST',Tier_1_High__c=2, Tier_1_Low__c=1,Tier_2_High__c=2, Tier_2_Low__c=1,Tier_3_High__c=2, Tier_3_Low__c=1,Tier_4_High__c=2, Tier_4_Low__c=1,Tier_5_High__c=2, Tier_5_Low__c=1,Tier_6_High__c=2, Tier_6_Low__c=1);
        insert myTestRec;        
        ///
        MKT_TranslationTable__c launchPackProductItem =  new MKT_TranslationTable__c(ChildProduct__c = prodList[0].Id, ParentProduct__c=null, Total_Seats__c=10);
        insert launchPackProductItem;
        
        
        OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = opp.Id;
        oli1.PricebookEntryId = pbEntryStdPbList[0].Id;
        oli1.UnitPrice = 10;
        oli1.ServiceEndDate__c = System.Now().Date().addDays(300);
        oli1.Quantity = 20;
        insert oli1;
        
        Asset aset = new Asset(Name='Test Asset-subscription' ,accountid=acc.id, Opportunity__c = opp.ID,Asset_type__c='Subscription', latest_opportunity__c = opp.Id );
        insert aset;
        
        Entitlement ent2 = new Entitlement();
        ent2.Name = 'Test Entitlement54321';
        ent2.EndDate = System.Now().Date().addDays(-89);
        ent2.StartDate = System.Now().Date().addDays(-90);
        ent2.AccountId = acc.Id;
        ent2.AssetId = aset.Id;
        insert ent2;
        Entitlement ent = new Entitlement();
        ent.Name = 'Test Entitlement5432123';
        ent.EndDate = System.Now().Date().addDays(100);
        ent.StartDate = System.Now().Date().addDays(-90);
        ent.AccountId = acc.Id;
        ent.AssetId = aset.Id;
        insert ent;
        
        
         }
    
    static testmethod void UpdateOpportunityTestForOptimized_NB_Xsell(){

    
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
     
     SalesTriggersUtility.dlrs_ContractTrigger=true;
     SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
     SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
     SalesTriggersUtility.dlrs_AccountTrigger = true;
     SalesTriggersUtility.AssetTriggerVA = true;
     System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt2);
        Trigger_Opportunity_Helper.bofuWizardEnabledForUser = false;
        Set<Id> closeOpptyIds = new Set<Id>();
        Map<Id,Opportunity> updateOpptyList2 = new Map<Id,Opportunity>();
        
        Id stdPbId = Test.getStandardPricebookId();
        
     //   List<Opportunity> oppList = new List<Opportunity>([SELECT Id, Name,AccountId,StageName FROM Opportunity WHERE Name like 'GRAZITTI TEST OPPORTUNITY %']);
         list<Account> accntList = TestCPQUtilityClass.createAccounts(1);
         insert accntList;
         
        List<Opportunity> oppList = TestCPQUtilityClass.createOpportunities(accntList, 1);
        
        insert oppList;
        
        List<SBQQ__Quote__c> quoteList = TestCPQUtilityClass.createQuotes(oppList,  1);
       // List<SBQQ__Quote__c> InsertUpsellquotList = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote : quoteList){
            quote.SBQQ__Primary__c = true;
            quote.Rubiks_Quote__c=false;
            quote.Show_All_Bundles__c = false;
          //  InsertUpsellquotList.add(quote);
        }
        
        // Create Products
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].ProductCode = 'INST';
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
        
        oppList[0].PriceBook2Id = stdPbId;
        update oppList;
        
         OpportunityLineItem oli1 = new OpportunityLineItem();
        oli1.OpportunityId = oppList[0].Id;
        oli1.PricebookEntryId = pbEntryStdPbList[0].Id;
        oli1.UnitPrice = 10;
        oli1.Quantity = 20;
        insert oli1;
        
        System.Debug('oppList =='+oppList);
        Intacct_Entity__c ie = new Intacct_Entity__c();
        ie.Name = 'marketo-emea';
        insert ie;
        Intacct_Entity__c ie2 = new Intacct_Entity__c();
        ie2.Name = 'marketo-us';
        insert ie2;
        
        Test.startTest();
        for(Opportunity op : oppList){
            if(op.StageName != 'Signed Order'){
                op.Intacct_Entity__c = ie2.Id;
                op.Intacct_Sales_Region__c = '';
                //op.Third_Party_Solutions__c = 'No';
                op.amount=10000;
                op.Type = 'New Business';
                op.StageName = 'Closed Won';
                op.Migration__c=true;
            }
            updateOpptyList2.put(op.Id, op); 
            closeOpptyIds.add(op.Id);
        }
        update oppList;
        system.assertEquals(1,updateOpptyList2.values().size());
        if(updateOpptyList2.values()!=null){
       // update updateOpptyList2.values();
        
        NEWupdateOpptyBasedOnCriteriaRenewal.UpdateAssets_ClosedLost(updateOpptyList2);
        }
        Test.stopTest();
    }

}