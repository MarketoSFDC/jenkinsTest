/****************************************************
Modified By :Jade Global 31th August 20
   Change      : Removed closedWonRecordTypeId of class Trigger_Opportunity_Helper  variable from class
 ******************************************************/
@isTest(SeeAllData=true)
public class TestClassesforMKTO_University {

    static testMethod void DeleteUserWhenEntitlementEndDateReached() {
        Test.startTest();
        Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
        Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
        Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
        Trigger_Opportunity_Helper.isAfterUpdateEvent = true;       
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA = true;
        Account ac = Utility.insertAccountInTestClasses();
        ac.BillingCity = 'Ichalkaranji';
        ac.BillingCountry = 'India';
        ac.BillingStreet = 'Test Street';
        ac.BillingState ='Test Billing State';
        ac.BillingPostalCode ='12345';
        ac.ShippingCity ='Pune';
        ac.ShippingCountry ='India';
        ac.ShippingPostalCode = '12345';
        ac.ShippingState = 'Maharashtra';
        ac.ShippingStreet = 'Test Shipping Street';
        ac.Name ='Test Account Marketo';
        ac.website= 'testtestgf@test.com';
        insert ac;
        Contact con = Utility.insertContactInTestClasses(ac.Id);
        con.firstname='tesing';
        insert con;
        User usr = Utility.insertCustomerPortalUser(con.Id);
        insert usr;
        Entitlement ent = Utility.insertEntitlementInTestClasses( LMS_Util.LMSEntRecordTypeId, 'Education', ac.Id, Date.TODAY().addDays(-7), Date.Today());
        ent.Catalog__c = System.Label.Premium_Education_Catalog_Id;
        ent.Quantity__c =5;
        insert ent;
        String jobId = System.schedule('DeleteUserWhenEntitlementEndDateReachedinTest'+DateTime.now(), '0 0 0 3 9 ? 2022', new DeleteUserWhenEntitlementEndDateReached());
        String jobIdtest = System.schedule('DeleteUserWhenEntitlementEndDateReachedTest'+DateTime.now(), '0 0 0 3 9 ? 2022', new DeleteUserWhenEntitlementEndDateReached(new set<string>{ent.Id}));
        ent.StartDate      = Date.TODAY().addDays(-7);
        ent.EndDate        = Date.Today().addDays(-3);
        update ent;
        Test.stopTest();
     }
    
    static testMethod void LMS_Util(){
        Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
        Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
        Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
        Trigger_Opportunity_Helper.isAfterUpdateEvent = true;       
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA = true;
        
        Account ac = Utility.insertAccountInTestClasses();
        ac.BillingCity = 'Ichalkaranji sahdgh';
        ac.BillingCountry = 'India';
        ac.BillingStreet = 'Test Street';
        ac.BillingState ='Test Billing State';
        ac.BillingPostalCode ='12345';
        ac.ShippingCity ='Pune';
        ac.ShippingCountry ='India';
        ac.ShippingPostalCode = '12345';
        ac.ShippingState = 'Maharashtra';
        ac.ShippingStreet = 'Test Shipping Street';
        ac.Name ='Test Account for Marketo sadgsahdghagsg';
        ac.website= 'testtestasdgadghsd@test.com';
        insert ac;
        
        Set<string> accid = new Set<string>();
        
        accid.add(ac.id);
        Contact con = Utility.insertContactInTestClasses(ac.Id);
        con.firstname = 'test details for university';
        con.lastName = 'Univercity Last Date';
        con.email = 'univercity_Marketo@gmail.com';
        insert con;
        
        User usr = Utility.insertCustomerPortalUser(con.Id);
        insert usr;
        Opportunity opp1 = Utility.insertOpportunityInTestClasses(ac.Id, con.Id, 'Closed Won', 'New Business', Date.today(),  Date.today(),  Date.today().addDays(365), Date.today());
        opp1.MainCompetitor__c ='ttt';
        Opportunity opp2 = Utility.insertOpportunityInTestClasses(ac.Id, con.Id, 'Closed Won', 'Renewal', Date.today().addDays(365),  Date.today().addDays(365),  Date.today().addYears(2), Date.today()); 
        opp2.Prior_Opportunity__c = opp1.Id;
        List<Opportunity> opplist = new List<Opportunity>{opp1,opp2};
        insert opplist ;
        Entitlement ent = Utility.insertEntitlementInTestClasses( LMS_Util.LMSEntRecordTypeId, 'Education', ac.Id, Date.TODAY().addDays(-7), Date.Today());
        ent.Catalog__c = System.Label.Premium_Education_Catalog_Id;
        ent.Quantity__c =5;
        ent.Opportunity__c = opp1.Id;
        insert ent;       
        //SMB_SheduledJobInfo__c  jobProj = new  SMB_SheduledJobInfo__c(
        //                                   ProjectId__c = opp1.Id
        //                                  );
        //insert jobProj ;
        LMS_Util.deleteSheduledOpp(new Set<string>{opp1.Id});
        Test.startTest();
        LMS_Util.AddAndDeleteUserFromGroup(new Set<String>{usr.Id},  new Set<String>{usr.Id});
        LMS_Util.addUserToPublicGroup(accid,'');
        Boolean b = LMS_Util.isPremiumProduct(Premium_Education_Catalog_Products__c.getAll().values()[0].Product_Name__c);
        LMS_Util.deleteUserFromGroup(new Set<string>{ent.Id});
        //LMS_Util.createUpdatePremiumEntitlement(new Map<string, List<OpportunityLineItem>>(), new Map<string, Opportunity>());
        LMS_Util.sendLearningPassCodesInMail(opp1.Id, ent.Id);
        Test.stopTest();
    }
     static testmethod void testShedulerOfFetchAttendanceFromGoToTraining(){
        Test.startTest();
        FetchAttendanceFromGoToTraining fetchScheduler = new FetchAttendanceFromGoToTraining();
        fetchScheduler.execute(null);
        Test.stopTest();
    }
    
     static testmethod void testButtonOfFetchAttendanceFromGoToTraining(){
         
        Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
        Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
        Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
        Trigger_Opportunity_Helper.isAfterUpdateEvent = true;       
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA = true;
        
        Test.startTest();
        lmsilt__Event__c event = new lmsilt__Event__c (Name = 'Basics 2: Foundation Live-Online');
        insert event;
        lmsilt__Class__c clas = new lmsilt__Class__c(
                                                    Name = 'LMS Build Workshop 6-10-13',lmsilt__Type__c ='Public',
                                                    lmsilt__Event__c = event.Id
                                                    );
        insert clas;
        lmsilt__vILT_Account__c vILTacc = new lmsilt__vILT_Account__c(
                                                                Name = 'Marketo vILT acct'
                                                             );
        insert vILTacc;
                                                             
        lmsilt__Session__c session = new lmsilt__Session__c(Name = '1: Leads Lists', 
                                                            lmsilt__Class__c           = clas.Id,
                                                            lmsilt__ILT_vILT__c        = 'vILT',
                                                            lmsilt__Meeting_Type__c    = 'GoToTraining',
                                                            lmsilt__Start_Date_Time__c = DateTime.Now().addDays(1),
                                                            lmsilt__End_Date_Time__c   = DateTime.Now().addDays(2),
                                                            lmsilt__vILT_Account__c    = vILTacc.Id
                                                           );
        insert session;
        GoTo_Training_Session__c gttSession = new GoTo_Training_Session__c(
                                                                            GoTo_Training_Training_Key__c = '6906628824343898624',
                                                                            SFDC_Session__c = session.Id,
                                                                            Class__c = clas.Id
                                                                           );
        insert gttSession ;
        
        GoToTrainingAuthenticatorWithUtils.refreshRegistrationInfosInSfdc(clas.Id);
        GoToTrainingAuthenticatorWithUtils.makeAPIRequest('test.test.com', 'POST');       
        
        ApexPages.StandardController sc = new ApexPages.StandardController(session);
        GoToTrainingSessionController con = new GoToTrainingSessionController(sc); 
        Test.setCurrentPage(Page.LMSRedirectPage);
        ApexPages.CurrentPage().getparameters().put('id', session.id);  
        con.getAttendanceDetail();                                                            
        FetchAttendanceFromGoToTraining fetchScheduler = new FetchAttendanceFromGoToTraining(session.Id);
        FetchRegistrationFromGoToTraining fetchRegistr1 = new FetchRegistrationFromGoToTraining();
        FetchRegistrationFromGoToTraining fetchRegistr = new FetchRegistrationFromGoToTraining(clas.Id);
        
        ApexPages.currentPage().getParameters().put('Id',session.Id);
        con.init();
        
        fetchRegistr1.execute(null);
        Test.stopTest();
    }
/*    
   public static testmethod void testRegister() {
        Test.StartTest();
        MarketoGTTRegistrationController regController = new MarketoGTTRegistrationController();
        Test.setCurrentPage(Page.MarketoGTTRegistration);
        ApexPages.currentPage().getParameters().put('tr_id', '123');
        regController.Register();
        Test.StopTest();
    }
*/    
    public static testmethod void Trigger_User() {
        Test.StartTest();
        Profile p = [select Id,name from Profile where UserType = 'Standard' limit 1];
        User newUser =  HelperWithoutSharing.createTestUser(p.Id, 'testUser', 'Mkto', 'cfsId') ;
        insert newUser;
        //UserTriggerHelper.Execute_User_Trigger = true;
        newUser.isActive = false;
        update newUser;
        Test.StopTest();
    }
    
    public static testMethod void GTTCancelRegistrationController(){
        GTTCancelRegistrationController control = new GTTCancelRegistrationController();
        PageReference pageRef = Page.GTTCancelRegistration;
        Test.setCurrentPage(pageRef);
        lmsilt__Event__c event = new lmsilt__Event__c (Name = 'Basics 2: Foundation Live-Online');
        insert event;
        lmsilt__Class__c clas = new lmsilt__Class__c(
                                                    Name = 'LMS Build Workshop 6-10-13',lmsilt__Type__c ='Public',
                                                    lmsilt__Event__c = event.Id
                                                    );
        insert clas;
        GTT_Registrant__c reg = new GTT_Registrant__c();
        reg.name = 'test_registrant';
        reg.Student_Email__c = 'a@a.com';
        reg.Class__c = clas.Id;
        insert reg;
        ApexPages.currentPage().getParameters().put('registrantId', reg.Id);
        ApexPages.currentPage().getParameters().put('trainingKey', '12345');
        ApexPages.currentPage().getParameters().put('registrantKey', '12345');
        control.init();
        
    }
    static testMethod void LMS_UTilsTests(){
        
        Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
        Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
        Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
        Trigger_Opportunity_Helper.isAfterUpdateEvent = true;       
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA = true;
        
        Map<string,List<OpportunityLineItem>> mpoopLine = new Map<string,List<OpportunityLineItem>>();
        Map<string, Opportunity> overallOppMap = new Map<string, Opportunity> ();
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
                            acc.IntacctID__c         = 'TestID123';
            insert acc;
            
            Contact con = new Contact();
            con.firstname = 'test';
                            con.LastName   = 'GRAZITTI TEST CONTACT 1';
                            con.email      = 'test@test.com';
                            con.LeadSource = 'Blog';
                            con.AccountId  = acc.Id;
            insert con;
            
            
            Role_Geographical_Segmentation_Setting__c rgs = new Role_Geographical_Segmentation_Setting__c();
            rgs.Name = 'ANZ PS';
            insert rgs; 
            
            Id stdPbId = Test.getStandardPricebookId();
          
            Opportunity opp = new Opportunity();
                                opp.Name      = 'GRAZITTI TEST OPPORTUNITY 1';
                                opp.AccountId = acc.Id;
                                opp.Type      = 'Renewal';
                                opp.StageName = 'A - Qualify';
                                opp.Amount   = 10000;
                                opp.PriceBook2Id = stdPbId;
                                opp.Primary_Marketo_User_Lookup__c = con.Id;
                                opp.Economic_Decision_Maker__c = con.Id;
                                opp.Engagement_Manager__c = UserInfo.getUserId();
                                opp.SBQQ__Contracted__c = true;
                                opp.Intacct_Sales_Region__c = '';
                                opp.Owner_Role_Custom_Text__c = 'ANZ PS';
                                opp.Sub_Start_Date__c = Date.Today();
                                opp.Sub_End_Date__c   = Date.Today()+40;
                               
                                opp.CloseDate = System.Now().Date();

            insert opp;
               // Create Products
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].Name = 'Marketo University: Single Learning Passport';
        prodList[1].Name = 'Marketo University: 5-Pack Learning Passport';
        prodList[2].Name = 'Marketo University: 3-Pack Learning Passport';
        prodList[3].Name = 'Marketo University: 10-Pack Learning Passport';
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
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = opp.Id;
        as2.Purpose__c = 'Production';
        as2.Asset_Type__c = 'Subscription';
        as2.AccountId = acc.Id;
        insert as2;
        Entitlement ent = insertEntitlementInTestClasses(Entitlement.sObjectType.getDescribe().getRecordTypeInfosByName().get(System.Label.EntitlementType).getRecordTypeId(), 'Premium Education Catalog', acc.Id, Date.TODAY().addDays(-7), Date.Today());
        ent.Catalog__c = System.Label.Premium_Education_Catalog_Id;
        ent.Quantity__c = 3;
        insert ent;
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
        List<OpportunityLineItem> lstoli= new List<OpportunityLineItem>();
        lstoli.add(oli1);
        lstoli.add(oli2);
            mpoopLine.put(opp.id,lstoli);
            overallOppMap.put(opp.id,opp);
            
            LMS_Util.decorateUnivEntitlement(opp,lstoli,new Entitlement());
            LMS_Util.createUpdatePremiumEntitlement(mpoopLine,overallOppMap);
            
    }
    public static Entitlement insertEntitlementInTestClasses(Id recordtype, string Type, Id accountId, Date startDate, Date enddate){
        Entitlement ent = new Entitlement();
        ent.AccountId = accountId;
        if(recordtype != null) ent.recordTypeId   = recordtype;
        ent.name           = 'Test Code Entitlement';
        ent.StartDate      = startDate;
        ent.EndDate        = endDate;
        ent.Type           = Type;
        if(recordtype =='01250000000UOqwAAG'){
        ent.Product_ID__c = '01t50000002fcp3AAA';
        ent.Products__c = 'Marketo University: Single Learning Passport';
        }
        return ent;
    }
    
    static testMethod void LMS_UTilsTests2(){
         
        Trigger_Opportunity_Helper.isBeforeInsertEvent     =true;
        Trigger_Opportunity_Helper.isBeforeUpdateEvent = true;
        Trigger_Opportunity_Helper.isAfterInsertEvent     =true;
        Trigger_Opportunity_Helper.isAfterUpdateEvent = true;       
        SalesTriggersUtility.dlrs_ContractTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
        SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
        SalesTriggersUtility.dlrs_AccountTrigger = true;
        SalesTriggersUtility.AssetTriggerVA = true;
        
        Map<string,List<OpportunityLineItem>> mpoopLine = new Map<string,List<OpportunityLineItem>>();
        Map<string, Opportunity> overallOppMap = new Map<string, Opportunity> ();
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
                            acc.IntacctID__c         = 'TestID123';
            insert acc;
            
            Contact con = new Contact();
                            con.firstname = 'test';
                            con.LastName   = 'GRAZITTI TEST CONTACT 1';
                            con.email      = 'test@test.com';
                            con.LeadSource = 'Blog';
                            con.AccountId  = acc.Id;
            insert con;
            
            
            Role_Geographical_Segmentation_Setting__c rgs = new Role_Geographical_Segmentation_Setting__c();
            rgs.Name = 'ANZ PS';
            insert rgs; 
            
            Id stdPbId = Test.getStandardPricebookId();
            Opportunity opp = new Opportunity();
                                opp.Name      = 'GRAZITTI TEST OPPORTUNITY 1';
                                opp.AccountId = acc.Id;
                                opp.Type      = 'Renewal';
                                opp.StageName = 'Closed Won';
                                opp.Amount   = 10000;
                                opp.PriceBook2Id = stdPbId;
                                opp.Primary_Marketo_User_Lookup__c = con.Id;
                                opp.Economic_Decision_Maker__c = con.Id;
                                opp.Engagement_Manager__c = UserInfo.getUserId();
                                opp.SBQQ__Contracted__c = true;
                                opp.Intacct_Sales_Region__c = '';
                                opp.Owner_Role_Custom_Text__c = 'ANZ PS';
                                opp.Sub_Start_Date__c = Date.Today();
                                opp.Sub_End_Date__c   = Date.Today()+40;
                                
                                opp.CloseDate = System.Now().Date();

            insert opp;
           
               // Create Products
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].Name = 'Marketo University: Single Learning Passport';
        prodList[1].Name = 'Marketo University: 5-Pack Learning Passport';
        prodList[2].Name = 'Marketo University: 3-Pack Learning Passport';
        prodList[3].Name = 'Marketo University: 10-Pack Learning Passport';
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
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = opp.Id;
        as2.Purpose__c = 'Production';
        as2.Asset_Type__c = 'Subscription';
        as2.AccountId = acc.Id;
        insert as2;
        Entitlement ent = insertEntitlementInTestClasses(Entitlement.sObjectType.getDescribe().getRecordTypeInfosByName().get(System.Label.EntitlementType).getRecordTypeId(), 'Premium Education Catalog', acc.Id, Date.TODAY().addDays(-7), Date.Today().addDays(-2));
        ent.Catalog__c = System.Label.Premium_Education_Catalog_Id;
        ent.Opportunity__c = opp.id;
        ent.Quantity__c =5;
        insert ent;
        Entitlement e2 = new Entitlement(Name = 'Test2',AssetId = as2.Id,AccountID = acc.ID,  StartDate =Date.TODAY(),Type ='Premium Education Catalog',Opportunity__c = opp.ID );
        insert e2;
        
        List<Entitlement> lstenttt = new List<Entitlement>();
        lstenttt.add(ent);
        lstenttt.add(e2);
                Set<id> entid = new Set<id>();
        entid.add(ent.id);
        entid.add(e2.id);        
        LMS_Util.updatePrimaryMarketoHiddenEmail(entid);
        LMS_Util.sendPassportCodeToPrimaryUserAfter24Hr(lstenttt,'');
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
        List<OpportunityLineItem> lstoli= new List<OpportunityLineItem>();
        lstoli.add(oli1);
        lstoli.add(oli2);
           
         Opportunity oppp = new Opportunity();
                                oppp.Name      = 'GRAZITTI TEST OPPORTUNITY 1';
                                oppp.AccountId = acc.Id;
                                oppp.Type      = 'Renewal';
                                oppp.StageName = 'A - Qualify';
                                oppp.Amount   = 10000;
                                oppp.PriceBook2Id = stdPbId;
                                oppp.Prior_Opportunity__c = opp.id;
                                oppp.Primary_Marketo_User_Lookup__c = con.Id;
                                oppp.Economic_Decision_Maker__c = con.Id;
                                oppp.Engagement_Manager__c = UserInfo.getUserId();
                                oppp.SBQQ__Contracted__c = true;
                                oppp.Intacct_Sales_Region__c = '';
                                oppp.Owner_Role_Custom_Text__c = 'ANZ PS';
                                //oppp.Sub_Start_Date__c = Date.Today();
                                //oppp.Sub_End_Date__c   = Date.Today()+40;
                               
                                oppp.CloseDate = System.Now().Date();

         insert oppp;
         Entitlement ent333 = insertEntitlementInTestClasses(Entitlement.sObjectType.getDescribe().getRecordTypeInfosByName().get(System.Label.EntitlementType).getRecordTypeId(), 'Premium Education Catalog', acc.Id, Date.TODAY().addDays(-7), Date.Today().addDays(-2));
        ent333.Catalog__c = System.Label.Premium_Education_Catalog_Id;
        ent333.Opportunity__c = oppp.id;
        
        insert ent333;
        Entitlement e233 = new Entitlement(Name = 'Test2',AssetId = as2.Id,AccountID = acc.ID,  StartDate =Date.TODAY(),Type ='Premium Education Catalog',Opportunity__c = opp.ID );
        insert e233;
         
            mpoopLine.put(oppp.id,lstoli);
            overallOppMap.put(oppp.id,oppp);
            
            //LMS_Util.decorateUnivEntitlement(oppp,lstoli,new Entitlement());
            //LMS_Util.createUpdatePremiumEntitlement(mpoopLine,overallOppMap);
            
            List<Entitlement> lstent = new List<Entitlement>();
            Entitlement ent2 = Utility.insertEntitlementInTestClasses( LMS_Util.LMSEntRecordTypeId, 'Education', acc.Id, Date.TODAY().addDays(-7), Date.Today());
            ent2.Catalog__c = System.Label.Premium_Education_Catalog_Id;
            ent2.Opportunity__c = opp.Id;
            ent2.Quantity__c =5;
            lstent.add(ent2); 
            insert lstent;   
           // LMS_Util.generateUniqueCode(lstent);
            
    }
}