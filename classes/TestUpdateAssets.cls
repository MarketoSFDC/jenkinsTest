@isTest(SeeAllData = true)
private class TestUpdateAssets{
     static testMethod void testAsset(){
        //Test.StartTest();
        ID ClosedWonId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Closed Won').getRecordTypeId();
        
        Account b = Utility.insertAccountInTestClasses();
        b.BillingCity = 'Ichalkaranji';
        b.BillingCountry = 'India';
        b.BillingStreet = 'Test Street';
        b.BillingState ='Test Billing State';
        b.BillingPostalCode ='12345';
        b.ShippingCity ='Pune';
        b.ShippingCountry ='India';
        b.ShippingPostalCode = '12345';
        b.ShippingState = 'Maharashtra';
        b.ShippingStreet = 'Test Shipping Street';
         Utility.haveupdatedAccounts=false;
        insert b;    
         
        Contact c = Utility.insertContactInTestClasses(b.Id);
        insert c;  
        opportunity opp = Utility.insertOpportunityInTestClasses(b.id, c.Id, 'Discovery', 'New Business',Date.Today(), system.today().addDays(-7),system.today().addDays(7), null);        
        opp.rep_create_arr__c=1234;
        opp.Needs_Pains__c  = 'test';
        opp.MainCompetitor__c = 'Act-On';
        insert opp;
        Asset aset = new Asset(Name='Test Asset-subscription' ,accountid=b.id, Opportunity__c = opp.ID,Asset_type__c='Subscription', Acct_Prefix__c = 'testpre', usageEndDate = Date.today() );
        insert aset;
        Asset a= new Asset(Name='Test Asset', Parent_Instance__c = aset.Id, accountid=b.id,Opportunity__c= opp.ID,Asset_type__c='Subscription');
        insert a;
        a.subscription_type__c = 'SMB Spark';
        a.status='Active';          
        a.Add_on_Product__c='Test';
        Entitlement ent = new Entitlement(Name='Test Ent', accountid=b.id,Processed_For_grace__c =true,startdate=Date.Today(),enddate=Date.today(),Has_been_Replaced__c = false, AssetId= a.Id);
        insert ent;
        Utility.haveupdatedAccounts = false;
        update a;       

    }
    
     static testMethod void testEnttitlement()  {
        //Test.StartTest();
        ID ClosedWonId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Closed Won').getRecordTypeId();
        Account a = Utility.insertAccountInTestClasses();
        a.BillingCity = 'Ichalkaranji';
        a.BillingCountry = 'India';
        a.BillingStreet = 'Test Street';
        a.BillingState ='Test Billing State';
        a.BillingPostalCode ='12345';
        a.ShippingCity ='Pune';
        a.ShippingCountry ='India';
        a.ShippingPostalCode = '12345';
        a.ShippingState = 'Maharashtra';
        a.ShippingStreet = 'Test Shipping Street';
        insert a;    
        Entitlement b = new Entitlement(Name = 'Test Ent' ,accountid = a.id,Processed_For_grace__c =true,startdate=Date.Today(),enddate=Date.today());
        Test.starttest();
        insert b;        
        b.EndDate = Date.today().adddays(60);        
        update b;
        Test.stopTest();

    }
    
     static testMethod void testOpp()  {
     list<opportunity> updateoppty = new list<opportunity>();
        //Test.StartTest();
        
        List <Product2> ProList = new List <Product2> ();
        Product2 p = new Product2(Name = 'test pro', IsActive = true, ConvertTo__c = 'Subscription', ProductCode = 'abc');
        ProList.add(p);        
        insert ProList;
        List <PriceBook2> PriceB = [Select id from PriceBook2 where IsStandard = true limit 1];        
        List < PriceBookEntry > PBEList = new List < PriceBookEntry > ();
        PriceBookEntry Pe = new PriceBookEntry(IsActive = true, 
        PriceBook2Id = PriceB[0].id, Product2Id = p.id, UnitPrice = 200);
        PBEList.add(Pe);        
        insert PBEList;
        
        ID ClosedWonId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Closed Won').getRecordTypeId();
        Account b = Utility.insertAccountInTestClasses();
         b.BillingCity = 'Ichalkaranji';
        b.BillingCountry = 'India';
        b.BillingStreet = 'Test Street';
        b.BillingState ='Test Billing State';
        b.BillingPostalCode ='12345';
        b.ShippingCity ='Pune';
        b.ShippingCountry ='India';
        b.ShippingPostalCode = '12345';
        b.ShippingState = 'Maharashtra';
        b.ShippingStreet = 'Test Shipping Street';
        insert b;      
        Contact c = Utility.insertContactInTestClasses(b.Id);
        insert c;       
        opportunity opp = Utility.insertOpportunityInTestClasses(b.id, c.Id, 'Discovery', 'New Business',Date.Today(), system.today().addDays(-7),system.today().addDays(7), null);        
        opp.rep_create_arr__c=123;
        updateoppty.add(opp);
        opp.stagename='Discovery';
        opp.Needs_Pains__c = 'test';
        Opp.RecordtypeID=ClosedWonId ;
        opp.Assets_created_on_closed_won__c=true;
        opp.MainCompetitor__c = 'Act-On';
        opp.Pricebook2id =PriceB[0].id; 
        insert opp;
        
        
      //  *****insert quote through utility class***************
        List<SBQQ__Quote__c> quotesToBeInsertedList = new List<SBQQ__Quote__c>();
        quotesToBeInsertedList = TestCPQUtilityClass.createQuotes(updateoppty,1);
         system.debug('%%%%%%%%%%%%%%%%%%%---size of list'+ quotesToBeInsertedList.size());
            if(quotesToBeInsertedList!= null){
                quotesToBeInsertedList[0].sbqq__opportunity2__c=opp.id;
               insert quotesToBeInsertedList[0];
            }
            else{
            system.debug('%%%%%%%%%%%%%%%%%%%---size of list'+ quotesToBeInsertedList.size());
            } 
        
     
        opp.SBQQ__PrimaryQuote__c  = quotesToBeInsertedList[0].id;
        
        List < OpportunityLineItem > OplList = new List < OpportunityLineItem > ();
        OpportunityLineItem oli = new OpportunityLineItem();        
        oli.Users__c = 1;
        oli.MLM_Edition__c = 'test edition';
        oli.OpportunityId = Opp.Id;
        oli.PricebookEntryId = pe.Id;
        oli.Instance_Number__c = 123;
        oli.Quantity = 2;
        oli.UnitPrice = 200;        
        OplList.add(oli);
        insert OplList;
        
		opp.Migration__c = true;
        opp.stagename='Signed Order';
        opp.Subscription_Language__c = 'English';
        opp.Subscription_Locale__c = 'English-United States';
        opp.Subscription_Time_Zone__c = 'Afghanistan Time (Asia/Kabul)';
        opp.Use_Case__c = 'B2B';
        update opp;
		
		opp.Migration__c = false;
        opp.stagename='Closed Won';
        update opp;     
       
    }
    static testMethod void testOLI()  {
        //Test.StartTest();
        ID ClosedWonId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Closed Won').getRecordTypeId();
        Account b = Utility.insertAccountInTestClasses();
        b.BillingCity = 'Ichalkaranji';
        b.BillingCountry = 'India';
        b.BillingStreet = 'Test Street';
        b.BillingState ='Test Billing State';
        b.BillingPostalCode ='12345';
        b.ShippingCity ='Pune';
        b.ShippingCountry ='India';
        b.ShippingPostalCode = '12345';
        b.ShippingState = 'Maharashtra';
        b.ShippingStreet = 'Test Shipping Street';
        insert b;      
        Contact c = Utility.insertContactInTestClasses(b.Id);
        insert c;       
        opportunity opp = Utility.insertOpportunityInTestClasses(b.id, c.Id, 'Discovery', 'New Business',Date.Today(), system.today().addDays(-7),system.today().addDays(7), null);        
       
       
        List <Product2> ProList = new List <Product2> ();
        Product2 p = new Product2(Name = 'test pro', IsActive = true, ConvertTo__c = 'Subscription', ProductCode = 'abc');
        ProList.add(p);        
        insert ProList;
        List <PriceBook2> PriceB = [Select id from PriceBook2 where IsStandard = true limit 1];        
        List < PriceBookEntry > PBEList = new List < PriceBookEntry > ();
        PriceBookEntry Pe = new PriceBookEntry(IsActive = true, 
        PriceBook2Id = PriceB[0].id, Product2Id = p.id, UnitPrice = 200);
        PBEList.add(Pe);        
        insert PBEList;
        opp.rep_create_arr__c=123;
        opp.Needs_Pains__c = 'test';
        opp.MainCompetitor__c = 'Act-On';
        opp.pricebook2Id = PriceB[0].id;
        insert opp; 
        
        List < OpportunityLineItem > OplList = new List < OpportunityLineItem > ();
        OpportunityLineItem oli = new OpportunityLineItem();        
        oli.Users__c = 1;
        oli.MLM_Edition__c = 'test edition';
        oli.OpportunityId = Opp.Id;
        oli.PricebookEntryId = pe.Id;
        oli.Instance_Number__c = 123;
        oli.Quantity = 2;
        oli.UnitPrice = 200;        
        OplList.add(oli);
        
       Test.starttest();
       insert OplList ;
       update OplList ;
        
       Test.stopTest();

    }
    
    
   }