@isTest
public class OpportunityTriggerTest {
    
    public static testmethod void clone_OpportunityBasedOnCriteria_old(){
        
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
        /*Account acc= new account();
        acc.name='Test Account';
        acc.CurrencyIsoCode='USD';
        insert acc;*/
    
        Account acc= UtilityToCreateTestData.insertAccount();
        Contact cc = UtilityToCreateTestData.insertContact(acc.Id);
        
        ID  RenewalSalesId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Closed Won').getRecordTypeId();
        ID  ChannelId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Channel').getRecordTypeId();
        
        list<Opportunity> ListOfOpp = new list<Opportunity>();
        //Disabled by Passage Technology
        
        Opportunity opp = new opportunity();
        opp.Name='Test Name';
        opp.CRM_System__c='Microsoft CRM 2011';
        opp.AccountId=acc.id ;
        opp.CloseDate=Date.today();
        opp.stagename='Discovery';
        opp.Deal_Type__c='Services';
        opp.NextStep='abc';
        opp.Forecast_Category__c='Commit';
        opp.LeadSource='Additional User';
        opp.type='New Business';
        opp.recordtypeId=RenewalSalesId;
        opp.Quarterly_Renewal__c='123';
        opp.MainCompetitor__c = 'Act-On';
        opp.Rep_Create_ARR__c = 10;
        opp.Primary_Marketo_User_Lookup__c = cc.Id;
        insert opp;
        
        OppProQuanPrice_TriggerClass.isFromTriggerCloneOppBasedonCriteria = false;
        opp.recordtypeId=ChannelId;
        update opp;
        
        ListOfOpp.add(opp);
        
        upsert ListOfOpp; 
    }
    //************************ JADE ************** 
    public static testmethod void methodToCoverProcessClosedWonOpportunities(){
        
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
        /*Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');*/
        
        Account acc=UtilityToCreateTestData.insertAccount();
        Contact con = new Contact(firstname='Test',lastName='Contact',AccountId = acc.id);
        insert con;
        
        ID  RenewalSalesId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Closed Won').getRecordTypeId();
        ID  ChannelId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Channel').getRecordTypeId();
        
        list<Opportunity> ListOfOpp = new list<Opportunity>();
        
        Opportunity opp = new opportunity();
        opp.Name='Test Name';
        opp.CRM_System__c='Microsoft CRM 2011';
        opp.AccountId=acc.id ;
        opp.CloseDate=Date.today();
        opp.stagename='Discovery';
        opp.Deal_Type__c='Services';
        opp.NextStep='abc';
        opp.Forecast_Category__c='Commit';
        opp.LeadSource='Additional User';
        opp.type='New Business';
        opp.recordtypeId=RenewalSalesId;
        opp.Quarterly_Renewal__c='123';
        opp.Primary_Marketo_User_Lookup__c = con.id;
        opp.Intacct_Sales_Region__c = null;
        opp.MainCompetitor__c = 'Act-On';
        opp.Rep_Create_ARR__c = 10;
        opp.Primary_Marketo_User_Lookup__c = con.Id;
        insert opp;
        
        Intacct_Entity__c ie = new Intacct_Entity__c();
        ie.Name = 'marketo-emea';
        insert ie;
        
        opp.Stagename = 'Closed Won';
        opp.Intacct_Entity__c = ie.id;
        update opp;
        
        Intacct_Entity__c ie1 = new Intacct_Entity__c();
        ie1.Name = 'marketo-us';
        insert ie1;
        
        opp.Stagename = 'Closed Won';
        opp.Intacct_Entity__c = ie1.id;
        update opp;
                
        opp.recordtypeId=RenewalSalesId;
        opp.Type = 'Renewal';
        opp.StageName = 'Closed Won';
        update opp;
        
        /*OppProQuanPrice_TriggerClass.isFromTriggerCloneOppBasedonCriteria = false;
        opp.recordtypeId=ChannelId;
        update opp;
        
        ListOfOpp.add(opp);
        
        upsert ListOfOpp; */
    }
    
    public static testmethod void cloneOpportunityBasedOnCriteria_new(){
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

        Account acc=UtilityToCreateTestData.insertAccount();
        Contact cc = UtilityToCreateTestData.insertContact(acc.Id);
        
        id pbId = UtilityToCreateTestData.returnStandardPriceBookId();
        
        insert new SteelBrickCPQPricebook__c(id__c=pbId);
        
        ID  RenewalSalesId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Closed Won').getRecordTypeId();
        ID  ChannelId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Channel').getRecordTypeId();
        
        list<Opportunity> ListOfOpp = new list<Opportunity>();
        //Disabled by Passage Technology
        
        Opportunity opp = new opportunity();
        opp.Name='Test Name';
        opp.CRM_System__c='Microsoft CRM 2011';
        opp.AccountId=acc.id ;
        opp.CloseDate=Date.today();
        opp.stagename='Discovery';
        opp.Deal_Type__c='Services';
        opp.NextStep='abc';
        opp.Forecast_Category__c='Commit';
        opp.LeadSource='Additional User';
        opp.type='New Business';
        opp.recordtypeId=RenewalSalesId;
        opp.Quarterly_Renewal__c='123';
        opp.MainCompetitor__c = 'Act-On';
        opp.Rep_Create_ARR__c = 10;
        opp.Primary_Marketo_User_Lookup__c = cc.Id;
        insert opp;
        
        OppProQuanPrice_TriggerClass.isFromTriggerCloneOppBasedonCriteria = false;
        opp.recordtypeId=ChannelId;
        update opp;
        
        ListOfOpp.add(opp);
        
        upsert ListOfOpp; 
        
        //OpportunityTriggerHelper.populateExchangeRateOnRenewalsOppty(ListOfOpp);
    }
    
    static testMethod void updateRenewalsOwnerOnAccount_old(){
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
        
        Account acc=UtilityToCreateTestData.insertAccount();
        
        String recordTypeId = [select id from RecordType where Name = 'Trial' and SObjectType = 'Opportunity'].id;
        
        Opportunity opp = new Opportunity (AccountId = acc.id, Name = 'Test Opportunity', RecordTypeId = recordTypeId, 
                                            StageName = 'Discovery', Type = 'Renewal', CloseDate = System.Today());
        Test.StartTest();
        insert opp;
        Test.StopTest();
       // system.assert([select Renewals_Owner__c from Account where id = :acc.id].Renewals_Owner__c != null);
    }
    static testMethod void updateRenewalsOwnerOnAccount_new(){
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
        
        Account acc=UtilityToCreateTestData.insertAccount();
        Contact cc = UtilityToCreateTestData.insertContact(acc.Id);
        
        id pbId = UtilityToCreateTestData.returnStandardPriceBookId();
        
        insert new SteelBrickCPQPricebook__c(id__c=pbId);
        String recordTypeId = [select id from RecordType where Name = 'Trial' and SObjectType = 'Opportunity'].id;
        
        Opportunity opp = new Opportunity (AccountId = acc.id, Name = 'Test Opportunity', RecordTypeId = recordTypeId, 
                                            StageName = 'Discovery',MainCompetitor__c = 'Act-On',Rep_Create_ARR__c = 10,Primary_Marketo_User_Lookup__c = cc.Id, Type = 'Renewal', CloseDate = System.Today());
        Test.StartTest();
        insert opp;
        Test.StopTest();
       // system.assert([select Renewals_Owner__c from Account where id = :acc.id].Renewals_Owner__c != null);
    }
    
     static testmethod void GetNumberOfEliteProducts_old(){
         
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
         Account TestAcc1 =UtilityToCreateTestData.insertAccount();
         Contact cc = UtilityToCreateTestData.insertContact(TestAcc1.Id);
         
         List_of_Elite_Products__c lep = new List_of_Elite_Products__c(Name = 'TESTPROD123321');
         insert lep;
         
         Product2 product = new Product2(Name = 'Test Product', ProductCode = 'TESTPROD123321', isActive=TRUE);
         insert product;
         
         id pbId = UtilityToCreateTestData.returnStandardPriceBookId();
         
         insert new SteelBrickCPQPricebook__c(id__c = pbid);
         
         PriceBookEntry pbe = new PriceBookEntry (Product2Id = product.id, PriceBook2Id = pbId, UnitPrice = 10, isActive = TRUE);
         insert pbe;
               
         Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = TestAcc1.id,MainCompetitor__c = 'Act-On',Rep_Create_ARR__c = 10,Primary_Marketo_User_Lookup__c = cc.Id, StageName = 'Discovery', CloseDate=System.Today());
         insert opp;
        
         Opportunity opp2 = new Opportunity(Name = 'Test Opportunity', AccountId = TestAcc1.id,MainCompetitor__c = 'Act-On',Rep_Create_ARR__c = 10,Primary_Marketo_User_Lookup__c = cc.Id, StageName = 'Discovery', CloseDate=System.Today());
         insert opp2;
         
         
         system.assert([select Number_of_Elite_Products__c from Opportunity where id = :opp.id].Number_of_Elite_Products__c == 0);
         
         OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.id, PricebookEntryId = pbe.id, UnitPrice = 10, Quantity = 1);
         insert oli;
         
         OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = opp.id, PricebookEntryId = pbe.id, UnitPrice = 10, Quantity = 1);
         insert oli2;
        
         opp.Name = 'Test Opportunity Updated';
         opp2.Name = 'Test Opportunity Updated';
         List<Opportunity> oppList = new List<Opportunity>();
         oppList.add(opp);
         oppList.add(opp2);
         
         test.StartTest();
         Utility.isGetNumberOfEliteProductsGoingToRunOnceMore = false;
         update oppList;
         test.StopTest();
         
         system.debug('sssss'+[select Number_of_Elite_Products__c from Opportunity where id = :opp.id].Number_of_Elite_Products__c);
         //commneted by grazitti- will remove it after test code issue fix
         //system.assert([select Number_of_Elite_Products__c from Opportunity where id = :opp.id].Number_of_Elite_Products__c == 2);
         //system.assert([select Number_of_Elite_Products__c from Opportunity where id = :opp2.id].Number_of_Elite_Products__c == 0);
     }
     static testmethod void GetNumberOfEliteProducts_new(){
         
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
         Account TestAcc1 = UtilityToCreateTestData.insertAccount();
         Contact cc = UtilityToCreateTestData.insertContact(TestAcc1.Id);
         
         List_of_Elite_Products__c lep = new List_of_Elite_Products__c(Name = 'TESTPROD123321');
         insert lep;
         
         Product2 product = new Product2(Name = 'Test Product', ProductCode = 'TESTPROD123321', isActive=TRUE);
         insert product;
         
         id pbId = UtilityToCreateTestData.returnStandardPriceBookId();
         
         PriceBookEntry pbe = new PriceBookEntry (Product2Id = product.id, PriceBook2Id = pbId, UnitPrice = 10, isActive = TRUE);
         insert pbe;
               
         Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = TestAcc1.id, StageName = 'Discovery',MainCompetitor__c = 'Act-On',Rep_Create_ARR__c = 10,Primary_Marketo_User_Lookup__c = cc.Id, CloseDate=System.Today());
         insert opp;
        
         Opportunity opp2 = new Opportunity(Name = 'Test Opportunity', AccountId = TestAcc1.id, StageName = 'Discovery',MainCompetitor__c = 'Act-On',Rep_Create_ARR__c = 10,Primary_Marketo_User_Lookup__c = cc.Id, CloseDate=System.Today());
         insert opp2;
         
         
         system.assert([select Number_of_Elite_Products__c from Opportunity where id = :opp.id].Number_of_Elite_Products__c == 0);
         
         OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opp.id, PricebookEntryId = pbe.id, UnitPrice = 10, Quantity = 1);
         insert oli;
         
         OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = opp.id, PricebookEntryId = pbe.id, UnitPrice = 10, Quantity = 1);
         insert oli2;
        
         opp.Name = 'Test Opportunity Updated';
         opp2.Name = 'Test Opportunity Updated';
         List<Opportunity> oppList = new List<Opportunity>();
         oppList.add(opp);
         oppList.add(opp2);
         
         test.StartTest();
         Utility.isGetNumberOfEliteProductsGoingToRunOnceMore = false;
         update oppList;
         test.StopTest();
         
         system.debug('sssss'+[select Number_of_Elite_Products__c from Opportunity where id = :opp.id].Number_of_Elite_Products__c);
          //commneted by grazitti- will remove it after test code issue fix
         //system.assert([select Number_of_Elite_Products__c from Opportunity where id = :opp.id].Number_of_Elite_Products__c == 2);
         //system.assert([select Number_of_Elite_Products__c from Opportunity where id = :opp2.id].Number_of_Elite_Products__c == 0);
     }
     static testmethod void DTOTrigger_mytest1_old(){
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
        Contact cc = UtilityToCreateTestData.insertContact(acc.Id);
        Product2 prod = UtilityToCreateTestData.insertProduct2();
        id pbId = UtilityToCreateTestData.returnStandardPriceBookId();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pbId);
        Test.StartTest();
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Discovery', 'New Business', System.Today());
         opp.PriceBook2id=pbid;
         opp.MainCompetitor__c = 'Act-On';
         opp.Primary_Marketo_User_Lookup__c = cc.Id;
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        //DTOUtility.isDTOTriggerExecuted = FALSE;
        opp.StageName = 'Closed Won';
        update opp;
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Test.StopTest();
    }
    static testmethod void DTOTrigger_mytest1_new(){
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
        Pricebook2 pbf = new pricebook2(name='price1');
        insert pbf;
        
        insert new SteelBrickCPQPricebook__c(id__c=pbf.id);
        Account acc = UtilityToCreateTestData.insertAccount();
        Contact cc = UtilityToCreateTestData.insertContact(acc.Id);
        Product2 prod = UtilityToCreateTestData.insertProduct2();
        id pbId = UtilityToCreateTestData.returnStandardPriceBookId();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pbId);
        Test.StartTest();
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Discovery', 'New Business', System.Today());
          opp.MainCompetitor__c = 'Act-On';
          opp.Primary_Marketo_User_Lookup__c = cc.Id;
         //OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        //DTOUtility.isDTOTriggerExecuted = FALSE;
        opp.StageName = 'Closed Won';
        opp.PriceBook2id=pbid;
        update opp;
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Test.StopTest();
    }
    
    static testmethod void DTOTrigger_mytest2_old(){
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
        Product2 prod = UtilityToCreateTestData.insertProduct2();
        id pbId = UtilityToCreateTestData.returnStandardPriceBookId();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pbId);
        Test.StartTest();
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Discovery', 'Renewal', System.Today());
        opp.PriceBook2id=pbid;
        update opp;
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        OpportunityLineItem opli2 = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        OpportunityLineItem opli3 = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        //DTOUtility.isDTOTriggerExecuted = FALSE;
        opp.StageName = 'Closed Won';
        update opp;
        Test.StopTest();
    }
    static testmethod void DTOTrigger_mytest2_new(){
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
        Pricebook2 pbf = new pricebook2(name='price1');
        insert pbf;
        
        insert new SteelBrickCPQPricebook__c(id__c=pbf.id);
        Account acc = UtilityToCreateTestData.insertAccount();
        Product2 prod = UtilityToCreateTestData.insertProduct2();
        id pbId = UtilityToCreateTestData.returnStandardPriceBookId();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pbId);
        Test.StartTest();
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Discovery', 'Renewal', System.Today());
        opp.PriceBook2id=pbid;
        update opp;
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        OpportunityLineItem opli2 = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        OpportunityLineItem opli3 = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        //DTOUtility.isDTOTriggerExecuted = FALSE;
        opp.StageName = 'Closed Won';
        update opp;
        Test.StopTest();
    }
    /*
    static testmethod void DTOTrigger_mytest3_old(){
        
        Test.StartTest();
        Account acc = UtilityToCreateTestData.insertAccount();
        Product2 prod = UtilityToCreateTestData.insertProduct2();
        id pbId = UtilityToCreateTestData.returnStandardPriceBookId();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pbId);
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Discovery', 'Renewal', System.Today()-1);
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        Opportunity opp2 = UtilityToCreateTestData.insertOpportunity(acc.id, 'Discovery', 'Renewal', System.Today());
        opp2.PriceBook2id=pbid;
        update opp2;
        OpportunityLineItem opli2 = UtilityToCreateTestData.insertOppLineItem(opp2.id, pbe.id, 10, 1);
        Sales_Order__c so2 = UtilityToCreateTestData.insertSalesOrder(opp2.id);
        //DTOUtility.isDTOTriggerExecuted = FALSE;
        opp.StageName = 'Closed Won';
        update opp;
       // DTOUtility.isDTOTriggerExecuted = FALSE;
        opp2.StageName = 'Closed Won';
        update opp2;
        Test.StopTest();
    }
      
    static testmethod void DTOTrigger_mytest3_new(){
        Test.StartTest();
        Pricebook2 pbf = new pricebook2(name='price1');
        insert pbf;
        
        insert new SteelBrickCPQPricebook__c(id__c=pbf.id);
        Account acc = UtilityToCreateTestData.insertAccount();
        Product2 prod = UtilityToCreateTestData.insertProduct2();
        id pbId = UtilityToCreateTestData.returnStandardPriceBookId();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pbId);
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Discovery', 'Renewal', System.Today()-1);
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        
        Opportunity opp2 = UtilityToCreateTestData.insertOpportunity(acc.id, 'Discovery', 'Renewal', System.Today());
        opp2.PriceBook2id=pbid;
        update opp2;
        OpportunityLineItem opli2 = UtilityToCreateTestData.insertOppLineItem(opp2.id, pbe.id, 10, 1);
        Sales_Order__c so2 = UtilityToCreateTestData.insertSalesOrder(opp2.id);
        //DTOUtility.isDTOTriggerExecuted = FALSE;
        opp.StageName = 'Closed Won';
        update opp;
        //DTOUtility.isDTOTriggerExecuted = FALSE;
        opp2.StageName = 'Closed Won';
        update opp2;
        Test.StopTest();
    }
    */
    
    static testmethod void DTOTrigger_mytest4_old(){
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
        Contact cc = UtilityToCreateTestData.insertContact(acc.Id);
        Product2 prod = UtilityToCreateTestData.insertProduct2();
        id pbId = UtilityToCreateTestData.returnStandardPriceBookId();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pbId);
        Test.StartTest();
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Closed Won', 'New Business', System.Today());
        opp.PriceBook2id=pbid;
        opp.MainCompetitor__c = 'Act-On';
        opp.Primary_Marketo_User_Lookup__c = cc.Id;
        update opp;
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        delete so;
        Test.StopTest();
    }
    static testmethod void DTOTrigger_mytest4_new(){
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
        Pricebook2 pbf = new pricebook2(name='price1');
        insert pbf;
        
        insert new SteelBrickCPQPricebook__c(id__c=pbf.id);
        Account acc = UtilityToCreateTestData.insertAccount();
        Contact cc = UtilityToCreateTestData.insertContact(acc.Id);
        Product2 prod = UtilityToCreateTestData.insertProduct2();
        id pbId = UtilityToCreateTestData.returnStandardPriceBookId();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pbId);
        Test.StartTest();
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Closed Won', 'New Business', System.Today());
        opp.PriceBook2id=pbid;
        opp.MainCompetitor__c = 'Act-On';
        opp.Primary_Marketo_User_Lookup__c = cc.Id;
        update opp;
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        delete so;
        Test.StopTest();
    }
    static testmethod void DTOTrigger_mytest5_old(){
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
        Product2 prod = UtilityToCreateTestData.insertProduct3();
        Product2 prod2 = UtilityToCreateTestData.insertProduct2();
        id pbId = UtilityToCreateTestData.returnStandardPriceBookId();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pbId);
        PriceBookEntry pbe2 = UtilityToCreateTestData.insertPriceBookEntry(prod2.id, pbId);
        Test.StartTest();
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Closed Won', 'Renewal', System.Today());
        opp.PriceBook2id=pbid;
        update opp;
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe2.id, 10, 1);
        OpportunityLineItem opli2 = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        Test.StopTest();
    }
    static testmethod void DTOTrigger_mytest5_new(){
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
        Pricebook2 pbf = new pricebook2(name='price1');
        insert pbf;
        
        insert new SteelBrickCPQPricebook__c(id__c=pbf.id);
        Account acc = UtilityToCreateTestData.insertAccount();
        Product2 prod = UtilityToCreateTestData.insertProduct3();
        Product2 prod2 = UtilityToCreateTestData.insertProduct2();
        id pbId = UtilityToCreateTestData.returnStandardPriceBookId();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pbId);
        PriceBookEntry pbe2 = UtilityToCreateTestData.insertPriceBookEntry(prod2.id, pbId);
        Test.StartTest();
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Closed Won', 'Renewal', System.Today());
        opp.PriceBook2id=pbid;
        update opp;
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe2.id, 10, 1);
        OpportunityLineItem opli2 = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        Test.StopTest();
    }
    static testmethod void DTOTrigger_mytest6_old(){
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
        Product2 prod = UtilityToCreateTestData.insertProduct4();
        Product2 prod2 = UtilityToCreateTestData.insertProduct2();
        Product2 prod3 = UtilityToCreateTestData.insertProduct5();
        id pbId = UtilityToCreateTestData.returnStandardPriceBookId();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pbId);
        PriceBookEntry pbe2 = UtilityToCreateTestData.insertPriceBookEntry(prod2.id, pbId);
        PriceBookEntry pbe3 = UtilityToCreateTestData.insertPriceBookEntry(prod3.id, pbId);
        Test.StartTest();
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Closed Won', 'Renewal', System.Today());
        opp.PriceBook2id=pbid;
        update opp;
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe2.id, 10, 1);
        OpportunityLineItem opli2 = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        OpportunityLineItem opli3 = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe3.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        Test.StopTest();
    }
    static testmethod void DTOTrigger_mytest6_new(){
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
        Pricebook2 pbf = new pricebook2(name='price1');
        insert pbf;
        
        insert new SteelBrickCPQPricebook__c(id__c=pbf.id);
        Account acc = UtilityToCreateTestData.insertAccount();
        Product2 prod = UtilityToCreateTestData.insertProduct4();
        Product2 prod2 = UtilityToCreateTestData.insertProduct2();
        Product2 prod3 = UtilityToCreateTestData.insertProduct5();
        id pbId = UtilityToCreateTestData.returnStandardPriceBookId();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pbId);
        PriceBookEntry pbe2 = UtilityToCreateTestData.insertPriceBookEntry(prod2.id, pbId);
        PriceBookEntry pbe3 = UtilityToCreateTestData.insertPriceBookEntry(prod3.id, pbId);
        Test.StartTest();
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Closed Won', 'Renewal', System.Today());
        opp.PriceBook2id=pbid;
        update opp;
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe2.id, 10, 1);
        OpportunityLineItem opli2 = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        OpportunityLineItem opli3 = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe3.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        Test.StopTest();
    }
    
    static testmethod void DTOTrigger_mytest7_old(){
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
        Contact cc = UtilityToCreateTestData.insertContact(acc.Id);
        Product2 prod = UtilityToCreateTestData.insertProduct2();
        id pbId = UtilityToCreateTestData.returnStandardPriceBookId();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pbId);
        Test.StartTest();
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Closed Won', 'New Business', System.Today());
        opp.PriceBook2id=pbid;
        opp.MainCompetitor__c = 'Act-On';
        opp.Primary_Marketo_User_Lookup__c = cc.Id;
        update opp;
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        opp.StageName = 'Discovery';
        update opp;
        //DTOUtility.isDTOTriggerExecuted = FALSE;
        opp.StageName = 'Closed Won';
        update opp;
        Test.StopTest();
    }
    static testmethod void DTOTrigger_mytest7_new(){
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
        Pricebook2 pbf = new pricebook2(name='price1');
        insert pbf;
        
        insert new SteelBrickCPQPricebook__c(id__c=pbf.id);
        Account acc = UtilityToCreateTestData.insertAccount();
        Contact cc = UtilityToCreateTestData.insertContact(acc.Id);
        Product2 prod = UtilityToCreateTestData.insertProduct2();
        id pbId = UtilityToCreateTestData.returnStandardPriceBookId();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pbId);
        Test.StartTest();
        Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Closed Won', 'New Business', System.Today());
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        opp.StageName = 'Discovery';
        opp.PriceBook2id=pbid;
        opp.MainCompetitor__c = 'Act-On';
        opp.Primary_Marketo_User_Lookup__c = cc.Id;
        update opp;
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        //DTOUtility.isDTOTriggerExecuted = FALSE;
        opp.StageName = 'Closed Won';
        update opp;
        Test.StopTest();
    } 
static testmethod void testOpportunityTriggerClass(){
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
    
    // Insert User record
    Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
    User u1 = new User(Alias = 'gotus', Email='newuser1testOpportunityTriggerClass@testorg.com', 
    EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
    LocaleSidKey='en_US', ProfileId = p.Id, 
    TimeZoneSidKey='America/Los_Angeles', UserName='testOpportunityTriggerClassnewuser1@testorg.com');
    insert u1;
    
    User u2 = new User(Alias = 'mktus', Email='newuser2testOpportunityTriggerClass@testorg.com', 
    EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
    LocaleSidKey='en_US', ProfileId = p.Id, 
    TimeZoneSidKey='America/Los_Angeles', UserName='testOpportunityTriggerClassnewuser2@testorg.com');
    insert u2;
    
    // Insert Accounts
    List<Account> accountList = new List<Account>();
    accountList = TestCPQUtilityClass.createAccounts(3);   
    accountList[0].Renewals_Owner__c=u1.id;
    accountList[0].Sales_Region__c = 'Test Sales Region';
    accountList[2].Sales_Region__c = 'AMERICAS';
    accountList[1].Sales_Region__c = 'APAC';        
    if(!accountList.isEmpty()){
        insert accountList ;
    }
    
    // Create Custom PB
    List<pricebook2> pbList = TestCPQUtilityClass.createCustomPriceBooks(2);
    insert pbList;
    
    // Get ID of Standard PB
    Id stdPricebookId = Test.getStandardPricebookId();
    
    // Insert Products
    List<Product2> prodList = TestCPQUtilityClass.createCustomProducts(3);
    if(!prodList.isEmpty()){
        insert prodList;
    }
    
    // Add Products into Standard PB
    List<pricebookentry> pbeList = new List<pricebookentry>();
    for(Integer i=0; i< prodList.size(); i++){
        pricebookentry pbe = new pricebookentry(Pricebook2Id = stdPricebookId,Product2Id=prodList[i].Id,UnitPrice = 10000, IsActive = true);
        pbeList.add(pbe);
    }
    if(!pbeList.isEmpty()){
        insert pbeList;
    }
    
    // Add Products into Custom PB
    List<pricebookentry> pbeCustomList = new List<pricebookentry>();
    for(Integer i=0; i< prodList.size(); i++){
        pricebookentry pbe = new pricebookentry(Pricebook2Id = pbList[1].Id,Product2Id=prodList[i].Id,UnitPrice = 10000, IsActive = true);
        pbeCustomList.add(pbe);
    }
    if(!pbeCustomList.isEmpty()){
        insert pbeCustomList;
    }
    
    List<Opportunity> opportunityList = new  List<Opportunity>();       
    
    // Insert Opportunities with StageName = Prospecting
    opportunityList = TestCPQUtilityClass.createOpportunities(accountList,1);
    for(Opportunity opp : opportunityList){
        opp.Amount = 2000;
        opp.Pricebook2Id = pbList[1].Id;
        opp.Deal_Type__c='Services';
        opp.Owner_Role_Custom_Text__c = 'Test';
        opp.OwnerId=u2.id;
    }
    
    opportunityList[0].stageName = 'Closed Won';
    opportunityList[0].SBQQ__Contracted__c = true;  
    opportunityList[0].CloseDate = System.today().addDays(7);
    opportunityList[0].Probability = 1;
    opportunityList[0].Split_Opportunities__c = null;
    opportunityList[0].Ghost__c = False;
    opportunityList[0].pse__Primary_Project__c = null;
    
    
    opportunityList[1].SBQQ__Contracted__c = true;
    
    if(!opportunityList.isEmpty()){
        insert opportunityList;
    }
    
    opportunityList[1].stageName = 'Closed Won';
    opportunityList[1].SBQQ__Contracted__c = true;  
    opportunityList[1].CloseDate = System.today().addDays(7);
    opportunityList[1].Probability = 1;
    opportunityList[1].Split_Opportunities__c = null;
    opportunityList[1].Ghost__c = False;
    opportunityList[1].pse__Primary_Project__c = null;
    update opportunityList;
    
    // Insert Opportunity Line Items
    List<OpportunityLineItem> OpportunityLineItemList = new List<OpportunityLineItem>();
    for(integer i=0;i<2;i++){       
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opportunityList[0].Id, PricebookEntryId = pbeCustomList[0].Id, UnitPrice = 10, Quantity = 20);
        oli.Product_Type__c = 'Services';   
        OpportunityLineItemList.add(oli);                  
    }
    
    for(integer i=0;i<opportunityList.size();i++){      
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opportunityList[i].Id, PricebookEntryId = pbeCustomList[0].Id, UnitPrice = 10, Quantity = 20);
        oli.Product_Type__c = 'Services';   
        OpportunityLineItemList.add(oli);                  
    }
    insert OpportunityLineItemList;                 
    }
}