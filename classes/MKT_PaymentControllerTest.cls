/****************************************************
Class Name: MKT_PaymentControllerTest
Author: Vrp
Created Date: 2/13/2013
Usage: Test class that includes unit tests for shopping cart and triggers

/*******************************************************************
    Modified By : Sumit Bhatt, Grazitti Interactive
    Modified Date: 7/27/2018
    Purpose : Commented the field that are used in field removal project 
    refrence : APPS-20840 Field Cleanup Project - Phase One
    log of fields commented : Opportunity: mkt_user__c
*******************************************************************

*****************************************************/
public class MKT_PaymentControllerTest {
    public static User createTestUser(String ProfId, String fName, String lName, String cfsId) {
        String orgId = UserInfo.getOrganizationId();
        String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
        Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
        String uniqueName = orgId + dateString + randomInt;
        User tuser = new User(firstname = fName,
                            lastName = lName,
                            email = uniqueName + '@test' + orgId + '.org',
                            Username = uniqueName + '@test' + orgId + '.org',
                            EmailEncodingKey = 'ISO-8859-1',
                            Alias = uniqueName.substring(18, 23),
                            TimeZoneSidKey = 'America/Los_Angeles',
                            LocaleSidKey = 'en_US',
                            LanguageLocaleKey = 'en_US',
                            ProfileId = profId,
                            lmscons__Cornerstone_ID__c = 'cfsId',
                            lmscons__CFS_Status__c = 'Active'
        );
        return tuser;
    }

   
    @isTest (seeAllData=true)
    private static void testMKT_PaymentControllerTestShoppingCartPayment() {
        delete [SELECT Id FROM MKT_AssignQueue__c WHERE MKT_Status__c = 'Pending'];
       /*List<kumocomm__GatewayConfig__c> ActiveGateways = [SELECT Id FROM kumocomm__GatewayConfig__c WHERE /*kumocomm__Active__c = true AND kumocomm__Use_Tokenization__c = true];
        if (!ActiveGateways.IsEmpty()) delete ActiveGateways;*/
        List<RecordType> RecordTypeList = [SELECT Id FROM RecordType WHERE DeveloperName = 'MeS' AND IsActive = true /*SObjectType = :kumocomm__GatewayConfig__c.SObjectType.getDescribe().getName() AND */];
        //kumocomm__GatewayConfig__c gconf = new  kumocomm__GatewayConfig__c(Name ='GatewayAuthorizeNet', kumocomm__Use_Tokenization__c = true /*kumocomm__TestMode__c = true,*//*kumocomm__MerchantSecurityKey__c = 'dsfdsfdsfsd',*/ /*kumocomm__MerchantSecurityCode__c = 'dsfdasfdsf',*/ /*kumocomm__MerchantReference__c = 'dsfdsfdsfdsf',*/ /*kumocomm__MerchantPassword__c = 'sdfdsfdasf', /*kumocomm__MerchantId__c = 'sdfdsfdsf',kumocomm__Debug__c = true,*/ /*kumocomm__Active__c = true ,*/ );
        if (RecordTypeList.size() > 0) {
        //gconf.RecordTypeId = String.valueOf(RecordTypeList[0].get('Id'));
        }
        //insert gconf;
        Product2 prodQuiz = new Product2(Name = 'prodQuiz', isActive  = true);
        insert new List<Product2>{prodQuiz};

        List<Pricebook2> Pricebook2Test = [SELECT Id FROM Pricebook2 WHERE isStandard=true AND IsActive = true AND IsDeleted = false];
        Pricebook2 Pricebook2Test2 = new Pricebook2(IsActive = true, Name = 'TestPriceBook');
        insert  Pricebook2Test2;

        MKT_Setting__c mkt_sett = MKT_Setting__c.getInstance();
        mkt_sett.PriceBookName__c = 'TestPriceBook';
        upsert mkt_sett;

        PricebookEntry PricebookEntryTest = new PricebookEntry(Pricebook2Id = Pricebook2Test[0].Id, CurrencyIsoCode = 'USD',  UnitPrice = 150.00, Product2Id = prodQuiz.id, IsActive = true);
        insert PricebookEntryTest;
        lmscons__LMS_Consumer_Settings__c LCS = new lmscons__LMS_Consumer_Settings__c(lmscons__Default_License_Period__c='Months', lmscons__Default_License_Term__c = 12, lmscons__Cornerstone_Callback_URL__c='dep', lmscons__CyberUSecretSignKey__c='dep');
        insert LCS;

        lmscons__Training_Content__c TC = new lmscons__Training_Content__c();
        insert new List<lmscons__Training_Content__c>{TC};

        Date d = Date.valueOf(system.now());
        lmscons__Training_Content_License__c tcl = new lmscons__Training_Content_License__c(lmscons__Training_Content__c=TC.Id, lmscons__Expiration_Date__c=d, lmscons__Seats__c = 100);
        insert tcl;

        lmscons__Quiz__c qP = new lmscons__Quiz__c(Product__c = prodQuiz.Id, lmscons__Description__c = 'Descr');
        insert new List<lmscons__Quiz__c>{qP};

        Account testAcc = new Account(Name = 'test');
        insert testAcc;
        Contact testContact = new Contact();
        testContact.AccountId = testAcc.Id;
        testContact.LastName = 'TestCont';
        testContact.Phone = '54589651485';
        testContact.OtherStreet = 'OtherStreet';
        testContact.Email = 'Email@Email.ru';
        testContact.MailingCountry = 'MailingCountry';
        testContact.MailingPostalCode = '224013';
        testContact.MailingState = 'AL';
        testContact.MailingCity = 'City';
        testContact.MailingStreet = 'MailingStreet';
        testContact.FirstName = 'FirstName';

        insert testContact;
       /*kumocomm__Transaction__c testTrans = new kumocomm__Transaction__c();
        insert testTrans;*/
        Profile profile;
        try {
        profile = [SELECT Id FROM profile WHERE name='System Administrator'];
        } catch (system.exception e) {
        profile = [SELECT Id FROM profile WHERE Id=:UserInfo.getProfileId()];
        }
        User u = createTestUser(profile.Id, 'firstTestName4', 'secondtestName4', 'af');
        insert u;

        /*kumocomm__Payment_Source__c PaymentSourceItem = new kumocomm__Payment_Source__c ();
        //PaymentSourceItem.kumocomm__Contact__c = testContact.Id;
        PaymentSourceItem.kumocomm__CreditCardExpirationMonth__c = '07';
        PaymentSourceItem.kumocomm__CreditCardExpirationYear__c = '2015';
        PaymentSourceItem.kumocomm__Last4CreditCardNumber__c = '4444';
        PaymentSourceItem.kumocomm__CreditCardSecurityCode__c = '678';
        PaymentSourceItem.kumocomm__CreditCardType__c = 'Visa';
        PaymentSourceItem.kumocomm__Gateway_Config__c = gconf.Id;
        PaymentSourceItem.kumocomm__Token__c = '12345612345628596';
        insert PaymentSourceItem;*/
        /*kumocomm__Address__c BillingAddressItem = new kumocomm__Address__c();
        //BillingAddressItem.kumocomm__Contact__c = testContact.Id;
        BillingAddressItem.kumocomm__Type__c = 'Billing Address';
        BillingAddressItem.kumocomm__City__c = 'City';
        BillingAddressItem.kumocomm__Country__c = 'Country';
        BillingAddressItem.kumocomm__PostalCode__c = 'Zip';
        BillingAddressItem.kumocomm__State__c = 'State';
        BillingAddressItem.kumocomm__Street__c = 'Address1';
        BillingAddressItem.MKT_FirstName__c = 'FirstName';
        BillingAddressItem.MKT_LastName__c = 'LastName';
        BillingAddressItem.MKT_Phone__c = 'Phone';
        BillingAddressItem.MKT_Address2__c = 'Address2';
        insert BillingAddressItem;*/

       /* kumocomm__Order__c NewOrder = new kumocomm__Order__c(/*kumocomm__Contact__c = testContact.Id, *//*kumocomm__Amount__c = 50,*/ /*kumocomm__BillingAddress__c = BillingAddressItem.ID, kumocomm__ShippingAddress__c = BillingAddressItem.ID, /*kumocomm__Status__c = 'Pending',kumocomm__PaymentSource__c = PaymentSourceItem.ID);
        insert NewOrder;*/
        /*kumocomm__OrderItem__c NewOrderItem = new kumocomm__OrderItem__c(/*kumocomm__Amount__c = 100, *//*kumocomm__Order__c = NewOrder.Id, kumocomm__Product__c = prodQuiz.Id, kumocomm__Quantity__c = 2);
        insert NewOrderItem;*/
        lmscons__Transcript__c tr = new lmscons__Transcript__c(lmscons__Trainee__c = u.Id);
        insert tr;
        System.runAs(u) {

        Test.startTest();
            ApexPages.currentPage().getParameters().put('ContactIdForTest', testContact.Id);
            //ApexPages.currentPage().getParameters().put('OrderId', NewOrder.Id);
            //HelperWithoutSharing.AddToCart(qP.Id,lmscons__Quiz__c.sObjectType.getDescribe().getLabel());
            MKT_ShoppingCart cartObj = new MKT_ShoppingCart();
            //ApexPages.Action InitShoppingCartAction = new ApexPages.Action('{!InitShoppingCart}');
            //InitShoppingCartAction.invoke();
            //cartObj.InitShoppingCart();
            //System.assertEquals(cartObj.CartCount, 1);
           //cartObj.OrderId = NewOrder.Id;
            cartObj.paymentObj = new MKT_ShoppingCart.PaymentInfo();
            cartObj.paymentObj.CardNumber = '4555555555554444';
            //cartObj.paymentObj.TestTransactionId = (String)testTrans.Id;
            cartObj.paymentObj.isAccept = true;

            cartObj.SubmitOrder();
        Test.stopTest();
        }
    }

    

    private static testmethod void testMKT_PaymentControllerTestProductCheckTrigger() {
        Product2 prodQuiz = new Product2(Name = 'prodQuiz', isActive  = true);
        Product2 prodEvent = new Product2(Name = 'prodEventP', isActive  = true);
        Product2 prodModule = new Product2(Name = 'prodModule', isActive  = true);
        Product2 prodCourse = new Product2(Name = 'prodCourse', isActive  = true);
        Product2 prodLP = new Product2(Name = 'prodLP', isActive  = true);
        Product2 prodCur = new Product2(Name = 'prodCur', isActive  = true);
        insert new List<Product2>{prodQuiz, prodEvent, prodModule, prodCourse, prodLP, prodCur};

        MKT_Setting__c mkt_sett = MKT_Setting__c.getInstance();
        mkt_sett.PriceBookName__c = 'TestPriceBook';
        upsert mkt_sett;

        lmscons__LMS_Consumer_Settings__c LCS = new lmscons__LMS_Consumer_Settings__c(lmscons__Default_License_Period__c='Months', lmscons__Default_License_Term__c = 12, lmscons__Cornerstone_Callback_URL__c='dep', lmscons__CyberUSecretSignKey__c='dep');
        insert LCS;

        lmscons__Training_Content__c TCP = new lmscons__Training_Content__c(Product__c = prodModule.Id);
        insert new List<lmscons__Training_Content__c>{TCP};

        Date d = Date.valueOf(system.now());
        lmscons__Training_Content_License__c tcl = new lmscons__Training_Content_License__c(lmscons__Training_Content__c=TCP.Id, lmscons__Expiration_Date__c=d, lmscons__Seats__c = 100);
        insert tcl;

        lmscons__Quiz__c qP = new lmscons__Quiz__c(Product__c = prodQuiz.Id);
        insert new List<lmscons__Quiz__c>{qP};

        lmsilt__Event__c eP = new lmsilt__Event__c(lmsilt__Languages__c = 'English', Name='Test Event', Product__c = prodEvent.Id);
        insert new List<lmsilt__Event__c>{eP};

        lmscons__Training_Content__c tc2 = new lmscons__Training_Content__c(lmsilt__Event__c=eP.Id,lmscons__Title__c = 'Training me', lmscons__Cornerstone_ID__c = 'af');
        insert tc2;

        lmscons__Training_Path__c tpP = new lmscons__Training_Path__c(Name = 'testPath', lmscons__Enforce_Curriculum_Sequence__c=true, Product__c = prodCourse.Id);
        insert new List<lmscons__Training_Path__c>{tpP};

        lmscons__Learning_Path__c lpP = new lmscons__Learning_Path__c(Name='TestLP 1', lmscons__Enforce_Sequence__c=true, Product__c = prodLP.Id, lmscons__Description__c = 'Description');
        insert new List<lmscons__Learning_Path__c>{lpP};

        lmscons__Curriculum__c curP = new lmscons__Curriculum__c(Name='Test Cur 1', lmscons__Enforce_Sequence__c = true, Product__c = prodCur.Id);
        insert new List<lmscons__Curriculum__c>{curP};

        Profile profile;
        try {
        profile = [SELECT Id FROM profile WHERE name='System Administrator'];
        } catch (system.exception e) {
        profile = [SELECT Id FROM profile WHERE Id=:UserInfo.getProfileId()];
        }
        User u = createTestUser(profile.Id, 'firstTestName12', 'secondtestName12', 'af');
        insert u;
       /* kumocomm__ShoppingCart__c sh = new kumocomm__ShoppingCart__c();
        insert sh;
        kumocomm__ShoppingCartItem__c shItem1 = new kumocomm__ShoppingCartItem__c(kumocomm__Product__c = prodEvent.Id, kumocomm__Status__c = 'In Cart', kumocomm__ShoppingCart__c = sh.Id);
        kumocomm__ShoppingCartItem__c shItem2 = new kumocomm__ShoppingCartItem__c(kumocomm__Product__c = prodQuiz.Id, kumocomm__Status__c = 'In Cart', kumocomm__ShoppingCart__c = sh.Id);
        kumocomm__ShoppingCartItem__c shItem3 = new kumocomm__ShoppingCartItem__c(kumocomm__Product__c = prodModule.Id, kumocomm__Status__c = 'In Cart', kumocomm__ShoppingCart__c = sh.Id);
        kumocomm__ShoppingCartItem__c shItem4 = new kumocomm__ShoppingCartItem__c(kumocomm__Product__c = prodCourse.Id, kumocomm__Status__c = 'In Cart', kumocomm__ShoppingCart__c = sh.Id);
        kumocomm__ShoppingCartItem__c shItem5 = new kumocomm__ShoppingCartItem__c(kumocomm__Product__c = prodLP.Id, kumocomm__Status__c = 'In Cart', kumocomm__ShoppingCart__c = sh.Id);
        kumocomm__ShoppingCartItem__c shItem6 = new kumocomm__ShoppingCartItem__c(kumocomm__Product__c = prodCur.Id, kumocomm__Status__c = 'In Cart', kumocomm__ShoppingCart__c = sh.Id);
        insert new List<kumocomm__ShoppingCartItem__c>{shItem1, shItem2,shItem3, shItem4,shItem5, shItem6};
        System.runAs(u) {
        lmscons__Transcript__c tr = new lmscons__Transcript__c(lmscons__Trainee__c = UserInfo.getUserId());
        insert tr;
        Test.startTest();
            try {
            qP.Product__c = prodEvent.Id;
            update qP;
            }
            catch (Exception e) {
            System.assert(e != NULL);
            }

            try {
            TCP.Product__c = prodEvent.Id;
            update TCP;
            }
            catch (Exception e) {
            System.assert(e != NULL);
            }

            try {
            eP.Product__c = prodQuiz.Id;
            update eP;
            }
            catch (Exception e) {
            System.assert(e != NULL);
            }

            try {
            tpP.Product__c = prodQuiz.Id;
            update tpP;
            }
            catch (Exception e) {
            System.assert(e != NULL);
            }

            try {
            lpP.Product__c = prodQuiz.Id;
            update lpP;
            }
            catch (Exception e) {
            System.assert(e != NULL);
            }

            try {
            curP.Product__c = prodQuiz.Id;
            update curP;
            }
            catch (Exception e) {
            System.assert(e != NULL);
            }

            //Shopping Cart Test
        Test.stopTest();

        }*/
    }

    private static testmethod void testMKT_PaymentControllerFreeRegisterTP() {
         /*kumocomm__GatewayConfig__c gconf = new  kumocomm__GatewayConfig__c(Name ='GatewayAuthorizeNet' /*kumocomm__TestMode__c = true*/ /*,kumocomm__MerchantSecurityKey__c = 'dsfdsfdsfsd',*/ /*kumocomm__MerchantSecurityCode__c = 'dsfdasfdsf',*/ /*kumocomm__MerchantReference__c = 'dsfdsfdsfdsf',*/ /*kumocomm__MerchantPassword__c = 'sdfdsfdasf', /*kumocomm__MerchantId__c = 'sdfdsfdsf', kumocomm__Debug__c = true, *//*kumocomm__Active__c = true);
        
        insert gconf;*/
        MKT_Setting__c mkt_sett = MKT_Setting__c.getInstance();
        mkt_sett.PriceBookName__c = 'TestPriceBook';
        upsert mkt_sett;
        lmscons__LMS_Consumer_Settings__c LCS = new lmscons__LMS_Consumer_Settings__c(lmscons__Default_License_Period__c='Months', lmscons__Default_License_Term__c = 12, lmscons__Cornerstone_Callback_URL__c='dep', lmscons__CyberUSecretSignKey__c='dep');
        insert LCS;
        lmscons__Training_Content__c TC = new lmscons__Training_Content__c();
        Date d = Date.valueOf(system.now());
        insert TC;

        lmsilt__Event__c e2 = new lmsilt__Event__c(lmsilt__Languages__c = 'English', Name='Test Event');
        insert e2;
        lmscons__Training_Content__c tc2 = new lmscons__Training_Content__c(lmsilt__Event__c=e2.Id,lmscons__Title__c = 'Training me', lmscons__Cornerstone_ID__c = 'af');
        insert tc2;
        lmsilt__Meeting__c m = new lmsilt__Meeting__c(lmsilt__Meetingkey__c='123');
        insert m;
        lmsilt__Class__c cls = new lmsilt__Class__c(lmsilt__Event__c = e2.Id);
        insert cls;

        lmsilt__Material__c matir = new lmsilt__Material__c(lmsilt__Sequence__c = 'after', lmsilt__Class__c = cls.Id);
        lmsilt__Material__c matir2 = new lmsilt__Material__c(lmsilt__Sequence__c = 'before', lmsilt__Class__c = cls.Id);
        insert new List<lmsilt__Material__c>{matir,matir2};

        lmsilt__Session__c ss2 = new lmsilt__Session__c(lmsilt__ILT_vILT__c = 'ILT', lmsilt__Class__c = cls.Id, lmsilt__Start_Date_Time__c = system.now().addDays(6), lmsilt__End_Date_Time__c=system.now().addDays(7));
        insert ss2;

        lmscons__Training_Path__c tp = new lmscons__Training_Path__c(Name = 'testPath', lmscons__Enforce_Curriculum_Sequence__c=true);
        insert tp;

        Id RCModule = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Training_Path_Item__c' AND DeveloperName='Module' limit 1].Id;
        Id RCEvent = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Training_Path_Item__c' AND DeveloperName='Event' limit 1].Id;

        List<lmscons__Training_Path_Item__c> ICIs = new List<lmscons__Training_Path_Item__c>();
        lmscons__Training_Path_Item__c ICI = new lmscons__Training_Path_Item__c(lmscons__Training_Path__c = tp.Id, lmscons__Training_Content__c=TC.Id, RecordTypeId=RCModule);
        ICIs.add(ICI);

        lmscons__Training_Path_Item__c ICI2 = new lmscons__Training_Path_Item__c(lmscons__Training_Path__c = tp.Id, lmscons__Training_Content__c = tc2.Id ,lmsilt__Event__c = e2.Id, RecordTypeId=RCEvent);
        ICIs.add(ICI2);
        insert ICIs;

        Profile profile;
        try {
        profile = [SELECT Id FROM profile WHERE name='System Administrator'];
        } catch (system.exception e) {
        profile = [SELECT Id FROM profile WHERE Id=:UserInfo.getProfileId()];
        }
        User u = createTestUser(profile.Id, 'firstTestName5', 'secondtestName5', 'af');
        insert u;
        System.runAs(u) {
        lmscons__Transcript__c tr = new lmscons__Transcript__c(lmscons__Trainee__c = UserInfo.getUserId());
        insert tr;
        Test.startTest();
            ApexPages.currentPage().getParameters().put('ObjId', tp.Id);
            ApexPages.currentPage().getParameters().put('Action', 'freeRegister');
            ApexPages.currentPage().getParameters().put('TypeObj', lmscons__Training_Path__c.sObjectType.getDescribe().getLabel());
            MKT_PaymentController contr = new MKT_PaymentController();
            contr.InitPaymentObjects();
            System.assertEquals(contr.PaymentComplete, true);
        Test.stopTest();
        }
    }

    private static testmethod void testMKT_PaymentControllerFreeRegisterLP() {
       /*kumocomm__GatewayConfig__c gconf = new  kumocomm__GatewayConfig__c(Name ='GatewayAuthorizeNet'/*kumocomm__TestMode__c = true*/ /*,kumocomm__MerchantSecurityKey__c = 'dsfdsfdsfsd',*/ /*kumocomm__MerchantSecurityCode__c = 'dsfdasfdsf',*/ /*kumocomm__MerchantReference__c = 'dsfdsfdsfdsf',*/ /*kumocomm__MerchantPassword__c = 'sdfdsfdasf', /*kumocomm__MerchantId__c = 'sdfdsfdsf', kumocomm__Debug__c = true, *//*kumocomm__Active__c = true);
        insert gconf;*/
        MKT_Setting__c mkt_sett = MKT_Setting__c.getInstance();
        mkt_sett.PriceBookName__c = 'TestPriceBook';
        upsert mkt_sett;
        lmscons__LMS_Consumer_Settings__c LCS = new lmscons__LMS_Consumer_Settings__c(lmscons__Default_License_Period__c='Months', lmscons__Default_License_Term__c = 12, lmscons__Cornerstone_Callback_URL__c='dep', lmscons__CyberUSecretSignKey__c='dep');
        insert LCS;

        lmscons__Training_Content__c TC = new lmscons__Training_Content__c();
        Date d = Date.valueOf(system.now());
        insert TC;
        lmscons__Training_Content_License__c tcl = new lmscons__Training_Content_License__c(lmscons__Training_Content__c=TC.Id, lmscons__Expiration_Date__c=d, lmscons__Seats__c = 100);
        insert tcl;
        lmscons__Quiz__c q = new lmscons__Quiz__c();
        insert q;
        lmsilt__Event__c e2 = new lmsilt__Event__c(lmsilt__Languages__c = 'English', Name='Test Event');
        lmsilt__Event__c eP = new lmsilt__Event__c(lmsilt__Languages__c = 'English', Name='Test Event');
        insert new List<lmsilt__Event__c>{e2,eP};
        lmscons__Training_Content__c tc2 = new lmscons__Training_Content__c(lmsilt__Event__c=e2.Id,lmscons__Title__c = 'Training me', lmscons__Cornerstone_ID__c = 'af');
        insert tc2;
        lmsilt__Meeting__c m = new lmsilt__Meeting__c(lmsilt__Meetingkey__c='123');
        insert m;
        lmsilt__Class__c cls = new lmsilt__Class__c(lmsilt__Event__c = e2.Id);
        insert cls;
        lmsilt__Class__c clsP = new lmsilt__Class__c(lmsilt__Event__c = eP.Id);
        insert clsP;
        lmsilt__Material__c matir = new lmsilt__Material__c(lmsilt__Sequence__c = 'after', lmsilt__Class__c = cls.Id);
        lmsilt__Material__c matir2 = new lmsilt__Material__c(lmsilt__Sequence__c = 'before', lmsilt__Class__c = cls.Id);
        insert new List<lmsilt__Material__c>{matir,matir2};
        lmsilt__Session__c ss = new lmsilt__Session__c(lmsilt__ILT_vILT__c = 'ILT', lmsilt__Class__c = clsP.Id, lmsilt__Start_Date_Time__c = system.now().addDays(7), lmsilt__End_Date_Time__c=system.now().addDays(8));
        lmsilt__Session__c ss1 = new lmsilt__Session__c(lmsilt__ILT_vILT__c = 'ILT', lmsilt__Class__c = clsP.Id, lmsilt__Start_Date_Time__c = system.now().addDays(6), lmsilt__End_Date_Time__c=system.now().addDays(7));
        lmsilt__Session__c ss2 = new lmsilt__Session__c(lmsilt__ILT_vILT__c = 'ILT', lmsilt__Class__c = cls.Id, lmsilt__Start_Date_Time__c = system.now().addDays(6), lmsilt__End_Date_Time__c=system.now().addDays(7));
        insert new List<lmsilt__Session__c>{ss,ss1,ss2};
        lmscons__Training_Path__c tp = new lmscons__Training_Path__c(Name = 'testPath', lmscons__Enforce_Curriculum_Sequence__c=true);
        insert new List<lmscons__Training_Path__c>{tp};
        Id RCModule = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Training_Path_Item__c' AND DeveloperName='Module' limit 1].Id;
        Id RCEvent = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Training_Path_Item__c' AND DeveloperName='Event' limit 1].Id;
        List<lmscons__Training_Path_Item__c> ICIs = new List<lmscons__Training_Path_Item__c>();
        lmscons__Training_Path_Item__c ICI = new lmscons__Training_Path_Item__c(lmscons__Training_Path__c = tp.Id, lmscons__Training_Content__c=TC.Id, RecordTypeId=RCModule);
        ICIs.add(ICI);

        lmscons__Training_Path_Item__c ICI2 = new lmscons__Training_Path_Item__c(lmscons__Training_Path__c = tp.Id, lmscons__Training_Content__c = tc2.Id ,lmsilt__Event__c = e2.Id, RecordTypeId=RCEvent);
        ICIs.add(ICI2);
        insert ICIs;

        lmscons__Learning_Path__c lp = new lmscons__Learning_Path__c(Name='TestLP 1', lmscons__Enforce_Sequence__c=true);
        insert lp;

        Id RCModule3 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Learning_Path_Item__c' AND DeveloperName='Module' limit 1].Id;
        Id RCEvent3 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Learning_Path_Item__c' AND DeveloperName='Event' limit 1].Id;
        Id RCCourse3 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Learning_Path_Item__c' AND DeveloperName='Course' limit 1].Id;

        List<lmscons__Learning_Path_Item__c> LPIs = new List<lmscons__Learning_Path_Item__c>();
        lmscons__Learning_Path_Item__c LPI3 = new lmscons__Learning_Path_Item__c(lmscons__Learning_Path__c = lp.Id, lmsilt__Event__c=e2.Id, RecordTypeId=RCEvent3);
        LPIs.add(LPI3);
        lmscons__Learning_Path_Item__c LPI4 = new lmscons__Learning_Path_Item__c(lmscons__Learning_Path__c = lp.Id, lmscons__Module__c=tc.Id, RecordTypeId=RCModule3);
        LPIs.add(LPI4);
        lmscons__Learning_Path_Item__c LPI5 = new lmscons__Learning_Path_Item__c(lmscons__Learning_Path__c = lp.Id, lmscons__Course__c=tp.Id, RecordTypeId=RCCourse3);
        LPIs.add(LPI5);
        insert LPIs;

        Profile profile;
        try {
        profile = [SELECT Id FROM profile WHERE name='System Administrator'];
        } catch (system.exception e) {
        profile = [SELECT Id FROM profile WHERE Id=:UserInfo.getProfileId()];
        }
        User u = createTestUser(profile.Id, 'firstTestName13', 'secondtestName13', 'af');
        insert u;
        System.runAs(u) {
        lmscons__Transcript__c tr = new lmscons__Transcript__c(lmscons__Trainee__c = UserInfo.getUserId());
        insert tr;
        Test.startTest();
            ApexPages.currentPage().getParameters().put('ObjId', lp.Id);
            ApexPages.currentPage().getParameters().put('Action', 'freeRegister');
            ApexPages.currentPage().getParameters().put('TypeObj', lmscons__Learning_Path__c.sObjectType.getDescribe().getLabel());
            MKT_PaymentController contr = new MKT_PaymentController();
            contr.InitPaymentObjects();
            System.assertEquals(contr.PaymentComplete, true);
        Test.stopTest();
        }
    }

    private static testmethod void testMKT_PaymentControllerFreeRegisterCurr() {
        /*kumocomm__GatewayConfig__c gconf = new  kumocomm__GatewayConfig__c(Name ='GatewayAuthorizeNet', kumocomm__TestMode__c = true, kumocomm__MerchantSecurityKey__c = 'dsfdsfdsfsd', kumocomm__MerchantSecurityCode__c = 'dsfdasfdsf', kumocomm__MerchantReference__c = 'dsfdsfdsfdsf', kumocomm__MerchantPassword__c = 'sdfdsfdasf', kumocomm__MerchantId__c = 'sdfdsfdsf', kumocomm__Debug__c = true, kumocomm__Active__c = true);
        insert gconf;*/
        MKT_Setting__c mkt_sett = MKT_Setting__c.getInstance();
        mkt_sett.PriceBookName__c = 'TestPriceBook';
        upsert mkt_sett;
        lmscons__LMS_Consumer_Settings__c LCS = new lmscons__LMS_Consumer_Settings__c(lmscons__Default_License_Period__c='Months', lmscons__Default_License_Term__c = 12, lmscons__Cornerstone_Callback_URL__c='dep', lmscons__CyberUSecretSignKey__c='dep');
        insert LCS;
        lmscons__Training_Content__c TC = new lmscons__Training_Content__c();
        Date d = Date.valueOf(system.now());
        insert TC;
        lmscons__Training_Content_License__c tcl = new lmscons__Training_Content_License__c(lmscons__Training_Content__c=TC.Id, lmscons__Expiration_Date__c=d, lmscons__Seats__c = 100);
        insert tcl;
        lmscons__Quiz__c q = new lmscons__Quiz__c();
        insert q;
        lmsilt__Event__c e2 = new lmsilt__Event__c(lmsilt__Languages__c = 'English', Name='Test Event');
        lmsilt__Event__c eP = new lmsilt__Event__c(lmsilt__Languages__c = 'English', Name='Test Event');
        insert new List<lmsilt__Event__c>{e2,eP};
        lmscons__Training_Content__c tc2 = new lmscons__Training_Content__c(lmsilt__Event__c=e2.Id,lmscons__Title__c = 'Training me', lmscons__Cornerstone_ID__c = 'af');
        insert tc2;
        lmsilt__Meeting__c m = new lmsilt__Meeting__c(lmsilt__Meetingkey__c='123');
        insert m;
        lmsilt__Class__c cls = new lmsilt__Class__c(lmsilt__Event__c = e2.Id);
        insert cls;
        lmsilt__Class__c clsP = new lmsilt__Class__c(lmsilt__Event__c = eP.Id);
        insert clsP;
        lmsilt__Material__c matir = new lmsilt__Material__c(lmsilt__Sequence__c = 'after', lmsilt__Class__c = cls.Id);
        lmsilt__Material__c matir2 = new lmsilt__Material__c(lmsilt__Sequence__c = 'before', lmsilt__Class__c = cls.Id);
        insert new List<lmsilt__Material__c>{matir,matir2};
        lmsilt__Session__c ss = new lmsilt__Session__c(lmsilt__ILT_vILT__c = 'ILT', lmsilt__Class__c = clsP.Id, lmsilt__Start_Date_Time__c = system.now().addDays(7), lmsilt__End_Date_Time__c=system.now().addDays(8));
        lmsilt__Session__c ss1 = new lmsilt__Session__c(lmsilt__ILT_vILT__c = 'ILT', lmsilt__Class__c = clsP.Id, lmsilt__Start_Date_Time__c = system.now().addDays(6), lmsilt__End_Date_Time__c=system.now().addDays(7));
        lmsilt__Session__c ss2 = new lmsilt__Session__c(lmsilt__ILT_vILT__c = 'ILT', lmsilt__Class__c = cls.Id, lmsilt__Start_Date_Time__c = system.now().addDays(6), lmsilt__End_Date_Time__c=system.now().addDays(7));
        insert new List<lmsilt__Session__c>{ss,ss1,ss2};
        lmscons__Training_Path__c tp = new lmscons__Training_Path__c(Name = 'testPath', lmscons__Enforce_Curriculum_Sequence__c=true);
        lmscons__Training_Path__c tpP = new lmscons__Training_Path__c(Name = 'testPath', lmscons__Enforce_Curriculum_Sequence__c=true);
        insert new List<lmscons__Training_Path__c>{tp,tpP};
        Id RCModule = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Training_Path_Item__c' AND DeveloperName='Module' limit 1].Id;
        Id RCEvent = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Training_Path_Item__c' AND DeveloperName='Event' limit 1].Id;
        List<lmscons__Training_Path_Item__c> ICIs = new List<lmscons__Training_Path_Item__c>();
        lmscons__Training_Path_Item__c ICI = new lmscons__Training_Path_Item__c(lmscons__Training_Path__c = tp.Id, lmscons__Training_Content__c=TC.Id, RecordTypeId=RCModule);
        ICIs.add(ICI);
        lmscons__Training_Path_Item__c ICI2 = new lmscons__Training_Path_Item__c(lmscons__Training_Path__c = tp.Id, lmscons__Training_Content__c = tc2.Id ,lmsilt__Event__c = e2.Id, RecordTypeId=RCEvent);
        ICIs.add(ICI2);
        insert ICIs;
        lmscons__Learning_Path__c lp = new lmscons__Learning_Path__c(Name='TestLP 1', lmscons__Enforce_Sequence__c=true);
        lmscons__Learning_Path__c lpP = new lmscons__Learning_Path__c(Name='TestLP 1', lmscons__Enforce_Sequence__c=true);
        insert new List<lmscons__Learning_Path__c>{lp,lpP};

        Id RCModule3 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Learning_Path_Item__c' AND DeveloperName='Module' limit 1].Id;
        Id RCEvent3 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Learning_Path_Item__c' AND DeveloperName='Event' limit 1].Id;
        Id RCCourse3 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Learning_Path_Item__c' AND DeveloperName='Course' limit 1].Id;
        List<lmscons__Learning_Path_Item__c> LPIs = new List<lmscons__Learning_Path_Item__c>();
        lmscons__Learning_Path_Item__c LPI3 = new lmscons__Learning_Path_Item__c(lmscons__Learning_Path__c = lp.Id, lmsilt__Event__c=e2.Id, RecordTypeId=RCEvent3);
        LPIs.add(LPI3);
        lmscons__Learning_Path_Item__c LPI4 = new lmscons__Learning_Path_Item__c(lmscons__Learning_Path__c = lp.Id, lmscons__Module__c=tc.Id, RecordTypeId=RCModule3);
        LPIs.add(LPI4);
        lmscons__Learning_Path_Item__c LPI5 = new lmscons__Learning_Path_Item__c(lmscons__Learning_Path__c = lp.Id, lmscons__Course__c=tp.Id, RecordTypeId=RCCourse3);
        LPIs.add(LPI5);
        insert LPIs;

        lmscons__Curriculum__c cur = new lmscons__Curriculum__c(Name='Test Cur 1', lmscons__Enforce_Sequence__c = true);
        lmscons__Curriculum__c curP = new lmscons__Curriculum__c(Name='Test Cur 1', lmscons__Enforce_Sequence__c = true);
        insert new List<lmscons__Curriculum__c>{cur,curP};

        LIST<lmscons__Curriculum_Item__c> CIList = new LIST<lmscons__Curriculum_Item__c>();

        Id RCModule5 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Curriculum_Item__c' AND DeveloperName='Module' limit 1].Id;
        Id RCEvent5 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Curriculum_Item__c' AND DeveloperName='Event' limit 1].Id;
        Id RCLP5 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Curriculum_Item__c' AND DeveloperName='Learning_Path2' limit 1].Id;
        Id RCCourse5 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Curriculum_Item__c' AND DeveloperName='Course' limit 1].Id;


        List<lmscons__Curriculum_Item__c> CIs = new List<lmscons__Curriculum_Item__c>();
        lmscons__Curriculum_Item__c ci = new lmscons__Curriculum_Item__c(lmscons__Learning_Path__c = lp.Id, lmscons__Curriculum__c = cur.Id, RecordTypeId=RCLP5);
        CIs.add(ci);

        lmscons__Curriculum_Item__c ci2 = new lmscons__Curriculum_Item__c(lmscons__Course__c=tp.Id, lmscons__Curriculum__c = cur.Id, RecordTypeId=RCCourse5);
        CIs.add(ci2);

        lmscons__Curriculum_Item__c ci3 = new lmscons__Curriculum_Item__c(lmscons__Module__c=tc.Id, lmscons__Curriculum__c = cur.Id, RecordTypeId=RCModule5);
        CIs.add(ci3);

        lmscons__Curriculum_Item__c ci4 = new lmscons__Curriculum_Item__c(lmsilt__Event__c=e2.Id, lmscons__Curriculum__c = cur.Id, RecordTypeId=RCEvent5);
        CIs.add(ci4);
        insert CIs;

        Profile profile;
        try {
        profile = [SELECT Id FROM profile WHERE name='System Administrator'];
        } catch (system.exception e) {
        profile = [SELECT Id FROM profile WHERE Id=:UserInfo.getProfileId()];
        }

        User u = createTestUser(profile.Id, 'firstTestName14', 'secondtestName14', 'af');
        insert u;
        System.runAs(u) {
        lmscons__Transcript__c tr = new lmscons__Transcript__c(lmscons__Trainee__c = UserInfo.getUserId());
        insert tr;
        Test.startTest();
            ApexPages.currentPage().getParameters().put('ObjId', cur.Id);
            ApexPages.currentPage().getParameters().put('Action', 'freeRegister');
            ApexPages.currentPage().getParameters().put('TypeObj', lmscons__Curriculum__c.sObjectType.getDescribe().getLabel());
            MKT_PaymentController contr3 = new MKT_PaymentController();
            contr3.InitPaymentObjects();
            System.assertEquals(contr3.PaymentComplete, true);

        Test.stopTest();
        }
    }

    @isTest (seeAllData=true)
    private static void testMKT_PaymentController2() {
       /* kumocomm__GatewayConfig__c gconf = new  kumocomm__GatewayConfig__c(Name ='GatewayAuthorizeNet', kumocomm__TestMode__c = true, kumocomm__MerchantSecurityKey__c = 'dsfdsfdsfsd', kumocomm__MerchantSecurityCode__c = 'dsfdasfdsf', kumocomm__MerchantReference__c = 'dsfdsfdsfdsf', kumocomm__MerchantPassword__c = 'sdfdsfdasf', kumocomm__MerchantId__c = 'sdfdsfdsf', kumocomm__Debug__c = true, kumocomm__Active__c = true);
        insert gconf;*/
        Product2 prod1 = new Product2(Name = 'producTest1');
        Product2 prodQuiz = new Product2(Name = 'prodQuiz', isActive  = true);
        insert new List<Product2>{prod1, prodQuiz};

        List<Pricebook2> Pricebook2Test = [SELECT Id FROM Pricebook2 WHERE isStandard=true AND IsActive = true AND IsDeleted = false];
        Pricebook2 Pricebook2Test2 = new Pricebook2(IsActive = true, Name = 'TestPriceBook');
        insert  Pricebook2Test2;

        MKT_Setting__c mkt_sett = MKT_Setting__c.getInstance();
        mkt_sett.PriceBookName__c = 'TestPriceBook';
        upsert mkt_sett;

        PricebookEntry PricebookEntryTest = new PricebookEntry(Pricebook2Id = Pricebook2Test[0].Id, CurrencyIsoCode = 'USD',  UnitPrice = 150.00, Product2Id = prod1.id, IsActive = true);
        PricebookEntry PricebookEntryTest2 = new PricebookEntry(Pricebook2Id = Pricebook2Test[0].Id, CurrencyIsoCode = 'USD',  UnitPrice = 150.00, Product2Id = prodQuiz.id, IsActive = true);

        insert new List<PricebookEntry> {PricebookEntryTest,PricebookEntryTest2};
        //insert PricebookEntryTest2;

        lmscons__LMS_Consumer_Settings__c LCS = new lmscons__LMS_Consumer_Settings__c(lmscons__Default_License_Period__c='Months', lmscons__Default_License_Term__c = 12, lmscons__Cornerstone_Callback_URL__c='dep', lmscons__CyberUSecretSignKey__c='dep');
        insert LCS;

        lmscons__Training_Content__c TC = new lmscons__Training_Content__c();
        insert new List<lmscons__Training_Content__c>{TC};

        Date d = Date.valueOf(system.now());
        lmscons__Training_Content_License__c tcl = new lmscons__Training_Content_License__c(lmscons__Training_Content__c=TC.Id, lmscons__Expiration_Date__c=d, lmscons__Seats__c = 100);
        insert tcl;

        lmscons__Quiz__c q= new lmscons__Quiz__c(Product__c = prod1.Id);
        lmscons__Quiz__c q2 = new lmscons__Quiz__c(Product__c = prod1.Id);
        lmscons__Quiz__c q3 = new lmscons__Quiz__c(Product__c = prod1.Id);
        lmscons__Quiz__c qP = new lmscons__Quiz__c(Product__c = prodQuiz.Id);
        insert new List<lmscons__Quiz__c>{q,q2,q3,qP};

        Account testAcc = new Account(Name = 'test');
        insert testAcc;

        Profile profile;
        try {
        profile = [SELECT Id FROM profile WHERE name='System Administrator'];
        } catch (system.exception e) {
        profile = [SELECT Id FROM profile WHERE Id=:UserInfo.getProfileId()];
        }

        User u = createTestUser(profile.Id, 'firstTestName6', 'secondtestName6', 'af');
        insert u;
        System.runAs(u) {
        lmscons__Transcript__c tr = new lmscons__Transcript__c(lmscons__Trainee__c = UserInfo.getUserId());
        insert tr;
        Test.startTest();

            MKT_PaymentController contr4 = new MKT_PaymentController();
            contr4.QuizDetails = [SELECT Id, Name, Product__c, lmscons__Description__c FROM lmscons__Quiz__c WHERE Id = :q.Id];
            contr4.paymentObj.ProductId = String.ValueOf(contr4.QuizDetails.Product__c);
            contr4.paymentObj.Title = contr4.QuizDetails.Name;
            contr4.paymentObj.Description = contr4.QuizDetails.lmscons__Description__c;
            contr4.AccountId = testAcc.Id;
            contr4.TypeObj = lmscons__Quiz__c.sObjectType.getDescribe().getLabel();
            contr4.PaymentComplete = false;
            contr4.ObjId = q.Id;
            contr4.paymentObj.curUser = [SELECT Id, UserType, AccountId, Name, Phone, Email FROM User WHERE Id =: UserInfo.GetUserId() LIMIT 1];
            contr4.UserList = new List<User>();
            contr4.UserList.Add(contr4.paymentObj.curUser);
            contr4.GetInfoObjectPayment();
            System.assertEquals(contr4.PaymentComplete, false);
        Test.stopTest();
        }
    }
    @isTest (seeAllData=true)
    private static void testMKT_PaymentController3() {
      
       /* kumocomm__GatewayConfig__c gconf = new  kumocomm__GatewayConfig__c(Name ='GatewayAuthorizeNet', kumocomm__TestMode__c = true, kumocomm__MerchantSecurityKey__c = 'dsfdsfdsfsd', kumocomm__MerchantSecurityCode__c = 'dsfdasfdsf', kumocomm__MerchantReference__c = 'dsfdsfdsfdsf', kumocomm__MerchantPassword__c = 'sdfdsfdasf', kumocomm__MerchantId__c = 'sdfdsfdsf', kumocomm__Debug__c = true, kumocomm__Active__c = true);
        insert gconf;*/
        Product2 prod1 = new Product2(Name = 'producTest1');
        Product2 prodQuiz = new Product2(Name = 'prodQuiz', isActive  = true);
        insert new List<Product2>{prod1, prodQuiz};

        List<Pricebook2> Pricebook2Test = [SELECT Id FROM Pricebook2 WHERE isStandard=true AND IsActive = true AND IsDeleted = false];
        Pricebook2 Pricebook2Test2 = new Pricebook2(IsActive = true, Name = 'TestPriceBook');
        insert  Pricebook2Test2;

        MKT_Setting__c mkt_sett = MKT_Setting__c.getInstance();
        mkt_sett.PriceBookName__c = 'TestPriceBook';
        upsert mkt_sett;

        PricebookEntry PricebookEntryTest = new PricebookEntry(Pricebook2Id = Pricebook2Test[0].Id, CurrencyIsoCode = 'USD',  UnitPrice = 150.00, Product2Id = prod1.id, IsActive = true);
        PricebookEntry PricebookEntryTest2 = new PricebookEntry(Pricebook2Id = Pricebook2Test[0].Id, CurrencyIsoCode = 'USD',  UnitPrice = 150.00, Product2Id = prodQuiz.id, IsActive = true);

        insert new List<PricebookEntry> {PricebookEntryTest,PricebookEntryTest2};
        //insert PricebookEntryTest2;

        lmscons__LMS_Consumer_Settings__c LCS = new lmscons__LMS_Consumer_Settings__c(lmscons__Default_License_Period__c='Months', lmscons__Default_License_Term__c = 12, lmscons__Cornerstone_Callback_URL__c='dep', lmscons__CyberUSecretSignKey__c='dep');
        insert LCS;

        lmscons__Training_Content__c TC = new lmscons__Training_Content__c();
        insert new List<lmscons__Training_Content__c>{TC};

        Date d = Date.valueOf(system.now());
        lmscons__Training_Content_License__c tcl = new lmscons__Training_Content_License__c(lmscons__Training_Content__c = TC.Id, lmscons__Expiration_Date__c=d, lmscons__Seats__c = 100);
        insert tcl;

        lmscons__Quiz__c q = new lmscons__Quiz__c(Product__c = prod1.Id);
        lmscons__Quiz__c q2 = new lmscons__Quiz__c(Product__c = prod1.Id);
        lmscons__Quiz__c q3 = new lmscons__Quiz__c(Product__c = prod1.Id);
        lmscons__Quiz__c qP = new lmscons__Quiz__c(Product__c = prodQuiz.Id);
        insert new List<lmscons__Quiz__c>{q,q2,q3,qP};
        lmsilt__Event__c e2 = new lmsilt__Event__c(lmsilt__Languages__c = 'English', Name='Test Event');
        insert new List<lmsilt__Event__c>{e2};
        lmscons__Training_Content__c tc2 = new lmscons__Training_Content__c(lmsilt__Event__c = e2.Id,lmscons__Title__c = 'Training me', lmscons__Cornerstone_ID__c = 'af');
        insert tc2;
        Account testAcc = new Account(Name = 'test');
        insert testAcc;
        MKT_Payment__c paymentObjTest = new MKT_Payment__c(Product__c = prodQuiz.Id, Account__c = testAcc.Id, Total_Seats__c = 5);
        insert paymentObjTest;
        Profile profile;
        try {
        profile = [SELECT Id FROM profile WHERE name='System Administrator'];
        } catch (system.exception e) {
        profile = [SELECT Id FROM profile WHERE Id=:UserInfo.getProfileId()];
        }

        User u = createTestUser(profile.Id, 'firstTestName7', 'secondtestName7', 'af');
        insert u;
        System.runAs(u) {
        lmscons__Transcript__c tr = new lmscons__Transcript__c(lmscons__Trainee__c = UserInfo.getUserId());
        insert tr;
            Test.startTest();
                ApexPages.currentPage().getParameters().put('ObjId', q2.Id);
                ApexPages.currentPage().getParameters().put('Action', 'freeRegister');
                ApexPages.currentPage().getParameters().put('TypeObj', lmscons__Quiz__c.sObjectType.getDescribe().getLabel());
                MKT_PaymentController contr5 = new MKT_PaymentController();
                contr5.InitPaymentObjects();
                System.assertEquals(contr5.PaymentComplete, true);

                contr5.QuizDetails = [SELECT Id, Name, Product__c, lmscons__Description__c FROM lmscons__Quiz__c WHERE Id = :q3.Id];
                contr5.paymentObj.ProductId = String.ValueOf(contr5.QuizDetails.Product__c);
                contr5.paymentObj.Title = contr5.QuizDetails.Name;
                contr5.paymentObj.Description = contr5.QuizDetails.lmscons__Description__c;
                contr5.AccountId = testAcc.Id;
                contr5.TypeObj = lmscons__Quiz__c.sObjectType.getDescribe().getLabel();
                contr5.GetInfoObjectPayment();
                //System.assertEquals(contr5.PaymentComplete, true);

                ApexPages.currentPage().getParameters().put('ObjId', tc2.Id);
                ApexPages.currentPage().getParameters().put('TypeObj', lmscons__Training_Content__c.sObjectType.getDescribe().getLabel());
                MKT_PaymentController contr6 = new MKT_PaymentController();
                contr6.InitPaymentObjects();


                ApexPages.currentPage().getParameters().put('ObjId', qP.Id);
                ApexPages.currentPage().getParameters().put('Action', 'freeRegister');
                ApexPages.currentPage().getParameters().put('TypeObj', lmscons__Quiz__c.sObjectType.getDescribe().getLabel());
                MKT_PaymentController contr7 = new MKT_PaymentController();
                contr7.InitPaymentObjects();
                contr7.AccountId = testAcc.Id;
                contr7.GetInfoObjectPayment();
                System.assertEquals(contr7.PaymentComplete, true);

            Test.stopTest();
        }
    }

    private static testMethod void testEnrollAndUnEnrollEvent() {
        Profile profile;
        try {
        profile = [SELECT Id FROM profile WHERE name='System Administrator'];
        } catch (system.exception e) {
        profile = [SELECT Id FROM profile WHERE Id=:UserInfo.getProfileId()];
        }

        User u = createTestUser(profile.Id, 'firstTestName8', 'secondtestName8', 'af');
        insert u;
        Product2 prod1 = new Product2(Name = 'producTest1');
        insert prod1;
        MKT_Setting__c mkt_sett = MKT_Setting__c.getInstance();
        mkt_sett.PriceBookName__c = 'TestPriceBook';
        upsert mkt_sett;

        lmscons__LMS_Consumer_Settings__c LCS = new lmscons__LMS_Consumer_Settings__c(lmscons__Default_License_Period__c='Months', lmscons__Default_License_Term__c = 12, lmscons__Cornerstone_Callback_URL__c='dep', lmscons__CyberUSecretSignKey__c='dep');
        insert LCS;

        lmscons__Training_Content__c TC = new lmscons__Training_Content__c();
        insert TC;

        Date d = Date.valueOf(system.now());
        lmscons__Training_Content_License__c tcl = new lmscons__Training_Content_License__c(lmscons__Training_Content__c=TC.Id, lmscons__Expiration_Date__c=d, lmscons__Seats__c = 100);
        insert tcl;

        lmsilt__Event__c e2 = new lmsilt__Event__c(lmsilt__Languages__c = 'English', Name='Test Event');
        insert e2;

        lmscons__Training_Content__c tc2 = new lmscons__Training_Content__c(lmsilt__Event__c=e2.Id,lmscons__Title__c = 'Training me', lmscons__Cornerstone_ID__c = 'af');
        insert tc2;

        lmsilt__Meeting__c m = new lmsilt__Meeting__c(lmsilt__Meetingkey__c='123');
        insert m;
        lmsilt__Class__c cls = new lmsilt__Class__c(lmsilt__Event__c = e2.Id, lmsilt__Maximum_Capacity__c = 600, lmsilt__Waitlist_Enabled__c = true, lmsilt__Start_Date__c = system.now().addDays(2), lmsilt__End_Date__c = system.now().addDays(3));
        insert cls;

        lmsilt__Material__c matir = new lmsilt__Material__c(lmsilt__Sequence__c = 'after', lmsilt__Class__c = cls.Id);
        insert matir;

        lmsilt__Material__c matir2 = new lmsilt__Material__c(lmsilt__Sequence__c = 'before', lmsilt__Class__c = cls.Id);
        insert matir2;


        //lmsilt__Session__c ss = new lmsilt__Session__c(lmsilt__Meeting__c = m.Id, lmsilt__ILT_vILT__c = 'vILT', lmsilt__Meeting_Type__c='GoToTraining', lmsilt__Class__c = cls.Id, lmsilt__Start_Date_Time__c = system.now().addDays(2), lmsilt__End_Date_Time__c=system.now().addDays(3));
        lmsilt__Session__c ss2 = new lmsilt__Session__c(lmsilt__ILT_vILT__c = 'ILT', lmsilt__Class__c = cls.Id, lmsilt__Start_Date_Time__c = system.now().addDays(4), lmsilt__End_Date_Time__c=system.now().addDays(5));
        lmsilt__Session__c ss3 = new lmsilt__Session__c(lmsilt__ILT_vILT__c = 'ILT', lmsilt__Class__c = cls.Id, lmsilt__Start_Date_Time__c = system.now().addDays(6), lmsilt__End_Date_Time__c=system.now().addDays(7));
        lmsilt__Session__c ss4 = new lmsilt__Session__c(lmsilt__ILT_vILT__c = 'ILT', lmsilt__Class__c = cls.Id, lmsilt__Start_Date_Time__c = system.now().addDays(8), lmsilt__End_Date_Time__c=system.now().addDays(9));
        insert new List<lmsilt__Session__c>{ss2,ss3,ss4};

        lmsilt__Roster__c rNew = new lmsilt__Roster__c(
        lmsilt__Class__c = cls.Id,
        lmsilt__Status__c = 'Enrolled',
        lmsilt__Student__c = u.ID,
        lmsilt__Waitlist_Priority__c = 1
        );
        insert rNew;

        Account testAcc = new Account(Name = 'test');
        insert testAcc;
        System.runAs(u) {
        lmscons__Transcript__c tr = new lmscons__Transcript__c(lmscons__Trainee__c = UserInfo.getUserId());
        insert tr;
            Test.startTest();
                ApexPages.currentPage().getParameters().put('ObjId', e2.Id);
                ApexPages.currentPage().getParameters().put('Action', 'freeRegister');
                ApexPages.currentPage().getParameters().put('TypeObj', lmsilt__Event__c.sObjectType.getDescribe().getLabel());
                ApexPages.currentPage().getParameters().put('ClassId', cls.Id);
                MKT_PaymentController contr = new MKT_PaymentController();
                contr.InitPaymentObjects();
                List<lmscons__Transcript_Line__c> AssignedTL = [SELECT Id From lmscons__Transcript_Line__c  WHERE lmscons__Training_User_License__r.lmscons__User__c =: contr.paymentObj.curUser.Id AND lmscons__Curriculum_Item__c = NULL AND lmscons__Learning_Path_Item__c = NULL AND lmscons__Training_Path_Item__c = NULL AND lmsilt__Event__c =: e2.Id];
                System.assert(AssignedTL.size() > 0);
                MKT_Payment__c MKT_Payment = new MKT_Payment__c(Product__c = prod1.Id, Total_Seats__c = 3, Account__c = testAcc.Id);
                insert MKT_Payment;
                MKT_PaymentLicense__c MKT_PaymentLicense = new MKT_PaymentLicense__c(User__c = contr.paymentObj.curUser.Id, Canceled__c = false, MKT_Payment__c = MKT_Payment.Id);
                insert MKT_PaymentLicense;
                contr.paymentObj.ProductId = String.ValueOf(prod1.Id);
                contr.AccountId = testAcc.Id;
                contr.AssignId = AssignedTL[0].Id;

                //System.assertEquals(contr.PaymentComplete, true);

                list<lmsilt__Roster__c> roster = [SELECT Id, lmsilt__Class__c, lmsilt__Attended__c FROM lmsilt__Roster__c WHERE lmsilt__Class__c = :cls.Id AND lmsilt__Attended__c = false  LIMIT 1];
                if (roster.size() > 0) {
                roster[0].lmsilt__Attended__c = true;
                }
                update roster;
                contr.unEnrollUser();

            Test.stopTest();
        }
    }

    //test for HelperWithoutSharing
    @isTest (seeAllData=true)
    private static void testgetPricebookEntry() {
        Product2 prod1 = new Product2(Name = 'producTest1', IsActive = true);
        Product2 prod2 = new Product2(Name = 'producTest2', IsActive = true);
        Product2 prod3 = new Product2(Name = 'producTest3', IsActive = true);
        Product2 prod4 = new Product2(Name = 'producTest4', IsActive = true);
        Product2 prod5 = new Product2(Name = 'producTest5', IsActive = true);
        Product2 prod6 = new Product2(Name = 'producTest6', IsActive = true);
        insert new List<Product2> {prod1,prod2,prod3,prod4,prod5,prod6};
        List<Pricebook2> Pricebook2Test = [SELECT Id FROM Pricebook2 WHERE isStandard=true AND IsActive = true AND IsDeleted = false];
        Pricebook2 Pricebook2Test2 = new Pricebook2(IsActive = true, Name = 'TestPriceBook');
        insert  Pricebook2Test2;
        MKT_Setting__c mkt_sett = MKT_Setting__c.getInstance();
        mkt_sett.PriceBookName__c = 'TestPriceBook';
        upsert mkt_sett;
        PricebookEntry PricebookEntryTest = new PricebookEntry(Pricebook2Id = Pricebook2Test[0].Id, CurrencyIsoCode = 'USD',  Product2Id = prod1.id, UnitPrice = 150.00, IsActive = true);
        PricebookEntry PricebookEntryTest2 = new PricebookEntry(Pricebook2Id = Pricebook2Test[0].Id, CurrencyIsoCode = 'USD',  Product2Id = prod2.id, UnitPrice = 150.00, IsActive = true);
        PricebookEntry PricebookEntryTest3 = new PricebookEntry(Pricebook2Id = Pricebook2Test[0].Id, CurrencyIsoCode = 'USD',  Product2Id = prod3.id, UnitPrice = 150.00, IsActive = true);
        PricebookEntry PricebookEntryTest4 = new PricebookEntry(Pricebook2Id = Pricebook2Test[0].Id, CurrencyIsoCode = 'USD',  Product2Id = prod4.id, UnitPrice = 150.00, IsActive = true);
        PricebookEntry PricebookEntryTest5 = new PricebookEntry(Pricebook2Id = Pricebook2Test[0].Id, CurrencyIsoCode = 'USD',  Product2Id = prod5.id, UnitPrice = 150.00, IsActive = true);
        PricebookEntry PricebookEntryTest6 = new PricebookEntry(Pricebook2Id = Pricebook2Test[0].Id, CurrencyIsoCode = 'USD',  Product2Id = prod6.id, UnitPrice = 150.00, IsActive = true);
        insert new List<PricebookEntry> {PricebookEntryTest, PricebookEntryTest2,PricebookEntryTest3,PricebookEntryTest4,PricebookEntryTest5,PricebookEntryTest6};
        Profile profile;
        try {
        profile = [SELECT Id FROM profile WHERE name='System Administrator'];
        } catch (system.exception e) {
        profile = [SELECT Id FROM profile WHERE Id=:UserInfo.getProfileId()];
        }

        User u = createTestUser(profile.Id, 'firstTestName9', 'secondtestName9', 'af');
        insert u;
        System.runAs(u) {
        lmscons__Transcript__c tr = new lmscons__Transcript__c(lmscons__Trainee__c = UserInfo.getUserId());
        insert tr;
            Test.startTest();
                PricebookEntry testPrice = HelperWithoutSharing.getPricebookEntryByProductId(prod1.Id);
                System.assert(testPrice != NULL);
                lmscons__Training_Path__c tpP = new lmscons__Training_Path__c(Product__c = prod1.Id);
                insert tpP;
                lmscons__Learning_Path__c lpP = new lmscons__Learning_Path__c(Product__c = prod2.Id);
                insert lpP;
                lmscons__Curriculum__c curP = new lmscons__Curriculum__c(Product__c = prod3.Id);
                insert curP;
                lmsilt__Event__c eP = new lmsilt__Event__c(Product__c = prod4.Id);
                insert eP;
                lmscons__Quiz__c qP = new lmscons__Quiz__c(Product__c = prod5.Id);
                insert qP;
                lmscons__Training_Content__c tcP = new lmscons__Training_Content__c(Product__c = prod6.Id);
                insert tcP;
                tpP = [SELECT ID, Product__c, Product__r.isActive FROM lmscons__Training_Path__c WHERE Id = :tpP.ID LIMIT 1];
                lpP = [SELECT ID, Product__c, Product__r.isActive FROM lmscons__Learning_Path__c WHERE Id = :lpP.ID LIMIT 1];
                curP = [SELECT ID, Product__c, Product__r.isActive FROM lmscons__Curriculum__c WHERE Id = :curP.ID LIMIT 1];
                eP = [SELECT ID, Product__c, Product__r.isActive FROM lmsilt__Event__c WHERE Id = :eP.ID LIMIT 1];
                qP = [SELECT ID, Product__c, Product__r.isActive FROM lmscons__Quiz__c WHERE Id = :qP.ID LIMIT 1];
                tcP = [SELECT ID, Product__c, Product__r.isActive FROM lmscons__Training_Content__c WHERE Id = :tcP.ID LIMIT 1];
                Map<Id, PricebookEntry> ProductsMap = HelperWithoutSharing.getProductsPrice(new List<lmscons__Training_Path__c>{tpP}, new  List<lmscons__Learning_Path__c>{lpP}, new List<lmscons__Curriculum__c> {curP}, new List<lmsilt__Event__c> {eP}, new List<lmscons__Quiz__c> {qP}, new List<lmscons__Training_Content__c> {tcP});
                System.assert(ProductsMap.size() > 0);
            Test.stopTest();
        }
    }
   /* @isTest (seeAllData=true)
    private static void testOpportunity(){
        Account acc = new Account(Name = 'test');
        insert acc;
        Product2 prod1 = new Product2(Name = 'producTest1', isActive  = true, ProductCode = 'CVT');
        Product2 prod2 = new Product2(Name = 'prodQuiz', isActive  = true, ProductCode = 'CVT');
        Product2 prod3 = new Product2(Name = 'prodEvent', isActive  = true, ProductCode = 'CVT');
        insert new List<Product2>{prod1,prod2,prod3};
        List<Pricebook2> Pricebook2Test = [SELECT Id FROM Pricebook2 WHERE isStandard=true AND IsActive = true AND IsDeleted = false];
        PricebookEntry PricebookEntryTest = new PricebookEntry(Pricebook2Id = Pricebook2Test[0].Id, CurrencyIsoCode = 'USD',  UnitPrice = 150.00, Product2Id = prod1.id, IsActive = true);
        PricebookEntry PricebookEntryTest2 = new PricebookEntry(Pricebook2Id = Pricebook2Test[0].Id, CurrencyIsoCode = 'USD',  UnitPrice = 150.00, Product2Id = prod2.id, IsActive = true);
        PricebookEntry PricebookEntryTest3 = new PricebookEntry(Pricebook2Id = Pricebook2Test[0].Id, CurrencyIsoCode = 'USD',  UnitPrice = 150.00, Product2Id = prod3.id, IsActive = true);
        insert new List<PricebookEntry>{PricebookEntryTest,PricebookEntryTest2,PricebookEntryTest3};
        RecordType recT = [SELECT Id FROM RecordType WHERE SobjectType =: Opportunity.sObjectType.getDescribe().getName() AND DeveloperName = 'Closed_Won' LIMIT 1];
        MKT_TranslationTable__c tb1= new MKT_TranslationTable__c(Total_Seats__c = 2, ParentProduct__c = prod1.ID, ChildProduct__c = prod2.ID);
        insert tb1;
        MKT_TranslationTable__c tb2= new MKT_TranslationTable__c(Total_Seats__c = 1, ParentProduct__c = prod1.ID, ChildProduct__c = prod3.ID);
        insert tb2;
        Profile profile;
        try {
        profile = [SELECT Id FROM profile WHERE name='System Administrator'];
        } catch (system.exception e) {
        profile = [SELECT Id FROM profile WHERE Id=:UserInfo.getProfileId()];
        }

        User u = createTestUser(profile.Id, 'firstTestName11', 'secondtestName11', 'af');
        insert u;
        System.runAs(u) {
            lmscons__Transcript__c tr = new lmscons__Transcript__c(lmscons__Trainee__c = UserInfo.getUserId());
            insert tr;

            Opportunity newOpp = new Opportunity(AccountId = acc.Id, //MKT_User__c = UserInfo.GetUserId(), Name = 'University-Opportunity'+ datetime.now(), RecordTypeId = recT.Id, Deal_Type__c = 'University', StageName = 'Discovery', CloseDate = date.today(), Pricebook2Id = Pricebook2Test[0].Id);
            insert newOpp;
            OpportunityLineItem opportunityLItem = new OpportunityLineItem(OpportunityId = newOpp.Id, Quantity = 1, PricebookEntryId = PricebookEntryTest.Id, UnitPrice = 150);
            insert opportunityLItem;
            test.startTest();
                newOpp.StageName = 'Closed Won';
                update newOpp;
                List<MKT_Payment__c> paymentList = [SELECT Id, Remaining_Seats__c FROM MKT_Payment__c WHERE Product__c =: prod2.Id AND Remaining_Seats__c > 0 AND Account__c =: acc.Id LIMIT 1];
                HelperWithoutSharing.createSOTransaction(String.ValueOf(newOpp.Id), 'C-002771');
            test.stopTest();
        }
    }*/
    
    @isTest (seeAllData=true)
    private static void testMKT_IntacctTest() {
        MKT_BatchAssign mkkk = new MKT_BatchAssign();
        Account acc = new Account(Name = 'test'); 
        insert acc;
         contact cc = new contact();
        cc.FirstName = 'test';
        cc.LastName = 'grazitti';
        cc.AccountId = acc.Id;
        cc.Email    = 'samantha.mills@sogefree.com';
        insert cc;
        Product2 prod1 = new Product2(Name = 'producTest1', isActive  = true, ProductCode = 'CVT');
        Product2 prod2 = new Product2(Name = 'prodQuiz', isActive  = true, ProductCode = 'CVT');
        Product2 prod3 = new Product2(Name = 'prodEvent', isActive  = true, ProductCode = 'CVT');
        insert new List<Product2>{prod1,prod2,prod3};
        List<Pricebook2> Pricebook2Test = [SELECT Id FROM Pricebook2 WHERE isStandard=true AND IsActive = true AND IsDeleted = false];
        PricebookEntry PricebookEntryTest = new PricebookEntry(Pricebook2Id = Pricebook2Test[0].Id, CurrencyIsoCode = 'USD',  UnitPrice = 150.00, Product2Id = prod1.id, IsActive = true);
        PricebookEntry PricebookEntryTest2 = new PricebookEntry(Pricebook2Id = Pricebook2Test[0].Id, CurrencyIsoCode = 'USD',  UnitPrice = 150.00, Product2Id = prod2.id, IsActive = true);
        PricebookEntry PricebookEntryTest3 = new PricebookEntry(Pricebook2Id = Pricebook2Test[0].Id, CurrencyIsoCode = 'USD',  UnitPrice = 150.00, Product2Id = prod3.id, IsActive = true);
        insert new List<PricebookEntry>{PricebookEntryTest,PricebookEntryTest2,PricebookEntryTest3};
        RecordType recT = [SELECT Id FROM RecordType WHERE SobjectType =: Opportunity.sObjectType.getDescribe().getName() AND DeveloperName = 'Closed_Won' LIMIT 1];
        MKT_TranslationTable__c tb1= new MKT_TranslationTable__c(Total_Seats__c = 2, ParentProduct__c = prod1.ID, ChildProduct__c = prod2.ID);
        insert tb1;
        MKT_TranslationTable__c tb2= new MKT_TranslationTable__c(Total_Seats__c = 1, ParentProduct__c = prod1.ID, ChildProduct__c = prod3.ID);
        insert tb2;
        Profile profile;
        try {
        profile = [SELECT Id FROM profile WHERE name='System Administrator'];
        } catch (system.exception e) {
        profile = [SELECT Id FROM profile WHERE Id=:UserInfo.getProfileId()];
        }

        User u = createTestUser(profile.Id, 'firstTestName12', 'secondtestName12', 'af');
        insert u;
        System.runAs(u) {
        lmscons__Transcript__c tr = new lmscons__Transcript__c(lmscons__Trainee__c = UserInfo.getUserId());
        insert tr;
        test.startTest();
            Opportunity newOpp = new Opportunity(AccountId = acc.Id,/* MKT_User__c = UserInfo.GetUserId(),*/ Name = 'University-Opportunity'+ datetime.now(), RecordTypeId = recT.Id, Deal_Type__c = 'University', StageName = 'Discovery', CloseDate = date.today(),MainCompetitor__c = 'Act-On',Rep_Create_ARR__c = 10,Pricebook2Id = Pricebook2Test[0].Id);
            insert newOpp;
            OpportunityLineItem opportunityLItem = new OpportunityLineItem(OpportunityId = newOpp.Id, Quantity = 1, PricebookEntryId = PricebookEntryTest.Id, UnitPrice = 150);
            insert opportunityLItem;
            HelperWithoutSharing.processIntacctTransaction(String.ValueOf(newOpp.Id), 'C-002771');
            List<OpportunityLineItem> OpportunityLItems = [SELECT Id, CurrencyIsoCode, Full_Price__c, Line_Item_Price__c, UnitPrice, Quantity,
                        PricebookEntry.ProductCode, PricebookEntry.Pricebook2Id, PricebookEntry.Name, PricebookEntry.Pricebook2.Name,
                        Opportunity.Name, Opportunity.Opportunity_Number__c, Opportunity.Account.Name,
                        Opportunity.Account.CurrencyIsoCode, Opportunity.Account.ShippingCountry, Opportunity.Account.ShippingPostalCode,
                        Opportunity.Account.ShippingState, Opportunity.Account.ShippingCity, Opportunity.Account.ShippingStreet, Opportunity.Account.BillingCountry,
                        Opportunity.Account.BillingPostalCode, Opportunity.Account.BillingState, Opportunity.Account.BillingCity, Opportunity.Account.BillingStreet,
                        Opportunity.AccountId, Opportunity.Account.ParentId, Opportunity.Account.Parent.Name, Opportunity.Account.OwnerId, Opportunity.Account.Parent.IntacctID__c, Opportunity.Account.Website,
                        Opportunity.Account.Accounting_Email__c,Opportunity.Account.Phone,
                        Opportunity.Account.Accounting_Contact_First_Name__c, Opportunity.Account.Accounting_Contact_Last_Name__c,
                        Opportunity.Account.IntacctID__c
                        FROM OpportunityLineItem WHERE OpportunityId = :newOpp.ID];
            System.assert(HelperWithoutSharing.PrepareIntacctXmlDoc(OpportunityLItems, 'C-002771', 'UpdateCustomer')!= NULL);
            System.assert(HelperWithoutSharing.PrepareIntacctXmlDoc(OpportunityLItems, 'C-002771', 'ReadCustomer')!= NULL);
            System.assert(HelperWithoutSharing.PrepareIntacctXmlDoc(OpportunityLItems, 'C-002771', 'ReadMoreCustomer')!= NULL);
            System.assert(HelperWithoutSharing.PrepareIntacctXmlDoc(OpportunityLItems, 'C-002771', 'CreateSOTransaction')!= NULL);
            System.assert(HelperWithoutSharing.PrepareIntacctXmlDoc(OpportunityLItems, 'C-002771', 'CreateBContact')!= NULL);
            System.assert(HelperWithoutSharing.PrepareIntacctXmlDoc(OpportunityLItems, 'C-002771', 'CreateSContact')!= NULL);
            HelperWithoutSharing.createSOTransaction(newOpp.Id,'C-002771');

        test.stopTest();
        }
    }
}