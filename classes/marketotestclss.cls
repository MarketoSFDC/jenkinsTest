/* ********************************************************************************************************************
        Last Modified By - Jade Global Inc, on 11th Feb 2018
        Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
        
        
        last modified by : Sumit Bhatt, Grazitti Interactive
        last Modified Date : 13-April-2018
        changes done: #APPS-10924# Remove functionality that is not needed for Account Score
        
        
 Modified By :Jade Global 31th August 2018
 Change      : Removed closedWonRecordTypeId   variable from class
********************************************************************************************************************* */
@istest
public class marketotestclss {
    
   /* public static testmethod void NewsControllerTest()
    {
        newsController nwsc=new newsController();
        nwsc.myStatusSet='';
        Map<String,String> ppp=new Map<String,String>();
        ppp.put('','');
        ppp.put('New', 'New case that has not been assigned to a Support Engineer.');
        ppp.put('Working' ,'Assigned to Support Engineer and work is in progress.');
        nwsc.statuses=ppp;
        nwsc.newsLimit=3;
        nwsc.initiativeLimit=3;
        nwsc.selectedCategory='';
        nwsc.typeOfMember='';
        nwsc.currentPage='';
        nwsc.CSatMonth='';
        nwsc.CSatPercentage='';
        nwsc.myPodName='gh';
        Map<String,String> px=nwsc.statuses;
        string px1=nwsc.myStatusSet;
        nwsc.getNewsList();
        nwsc.queryNewsRecords();
        nwsc.getAlertList();
        nwsc.toggleSubscription();
        nwsc.toggleSubscriptionLink();
        nwsc.getAlertExist();
        nwsc.getCustomersList();
        nwsc.getCustomersRecordsList();
        try{nwsc.getTeamTypeToObjectmap();}catch(exception e){}
        nwsc.getCSatSurveyMonth();
        nwsc.getCSatSurveyPercentage();
        nwsc.getMyCasesList();
        nwsc.getSubscribedToCurrentCategory();
        String urlForImage='';String memberName='';String memberDesc='';Integer position=3; String Id=''; String type='';
        newsController.SupportTeam st= new newsController.SupportTeam(urlForImage,memberName,memberDesc,position,Id,type);
    }*/
    /*public static testmethod void InvokeUpdateTriggerBatch()
    {
        test.startTest();
        account acc=new account(name='testac1');
        insert acc;
        AccountScorerBatch__c asb1=new AccountScorerBatch__c();
        asb1.Accountids__c=acc.id;
        insert asb1;
        account acc2=new account(name='testac2');
        insert acc2;
        AccountScorerBatch__c asb2=new AccountScorerBatch__c();
        asb2.Accountids__c=acc2.id;
        insert asb2;
        Map<ID,sObject> accIds = new Map<ID,sObject>([SELECT ID FROM Account LIMIT 150]);
        Map<ID,sObject> accIds2 = new Map<ID,sObject>();
        system.debug('ooooooooooooooooo'+accIds);
        database.executebatch(new InvokeUpdateTriggerBatch('Account', accIds.keyset(), 200));
        database.executebatch(new InvokeUpdateTriggerBatch('Account', accIds2.keyset(), 200));
        test.stopTest();
    } */
      public static testMethod void TestSMB_ScheduledSurveyMail() {
        Test.StartTest();
       
        SMB_ScheduledSurveyMail sh1 = new SMB_ScheduledSurveyMail();
        DateTime timeToSendMail = system.now().addseconds(200);
        String sch = '' + timeToSendMail.second() + ' ' + timeToSendMail.minute() + ' ' + timeToSendMail.hour() + ' ' + timeToSendMail.day() + ' ' + timeToSendMail.month() + ' ? ' + timeToSendMail.year();
        String sId = system.schedule('Test'+system.now(), sch, sh1);
        
        /* ********************************************************************************************************************
        Last Modified By - Jade Global Inc, on 11th Feb 2018
        Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
        clzV5__Clarizen_Project__c lpProj = new clzV5__Clarizen_Project__c(
                                                clzV5__CLZ_State__c = 'Active',
                                                CLZ_C_BusinessUnit__c = 'AMER-MM',
                                                CLZ_C_ProjectFamily__c = 'MLMLP'
        
                                                );
        insert lpProj ;  
        ********************************************************************************************************************* */
        /*SMB_SheduledJobInfo__c  jobProj = new  SMB_SheduledJobInfo__c(
                                           SheduledJobId__c = sId,
                                           ProjectId__c = lpProj.Id
                                          );
        insert jobProj ;*/
        AccountScorer aa = new AccountScorer();
        Test.stopTest();
        
        }
    public static testMethod void TestSendLearningPassCodeToPrimUserAfter24Hr() 
    { 
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
                        con.LastName   = 'GRAZITTI TEST CONTACT 1';
                        con.FirstName  = 'GRAZITTI TEST';
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
                            
                            opp.MainCompetitor__c = 'Act-On';
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
        
       SendLearningPassCodeToPrimUserAfter24Hr slp=new SendLearningPassCodeToPrimUserAfter24Hr();
       String sch = '0 0 11   ?';  
       slp.getLearningPassCodes();
       slp.getEntitlementLearningPassCodes();
       set<string> entitlementsids= new set<string>();
       entitlementsids.add(e2.id);
       slp.sendLearningPassCodes(entitlementsIds);
       SendLearningPassCodeToPrimUserAfter24Hr slp1 =new SendLearningPassCodeToPrimUserAfter24Hr('ppp');
        
        PageReference pageRef = Page.Opportunity_ViewOverridePage;
        Test.setCurrentPage(pageRef);

        ApexPages.StandardController sc = new ApexPages.StandardController(opp);
        Opportunity_ViewOverridePage_Ctrl opppage =new Opportunity_ViewOverridePage_Ctrl(sc);
        opppage.redirectOpp();
      
       
    }
}