@isTest(SeeAllData = true)
private class TestOpportunityClone{
     static testMethod void Renewal_Clone()  {
        //Test.StartTest();
        ID ClosedWonId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Closed Won').getRecordTypeId();
        
        Account a = Utility.insertAccountInTestClasses();
        a.BillingCountry = 'United States';
        a.BillingStreet = 'Test Street';
        a.BillingState ='Test Billing State';
        a.BillingPostalCode ='12345';
        a.ShippingCity ='Pune';
        a.ShippingCountry ='India';
        a.ShippingPostalCode = '12345';
        a.ShippingState = '';
        a.ShippingStreet = 'Test Shipping Street';  
        a.Accounting_Email__c = 'test@gmail.com';
        a.Accounting_Contact_First_Name__c = 'FirstName';
        a.Accounting_Contact_Last_Name__c = 'LastName';
        a.Website = 'www.google.com';
        insert a;
        Contact c = Utility.insertContactInTestClasses(a.Id);
        insert c;
        Opportunity Opp = Utility.insertOpportunityInTestClasses(a.id, c.Id, 'Closed Won', 'Renewal',Date.Today(), system.today().addDays(1),system.today().addDays(7), null);        
        insert Opp;

        List < Product2 > ProList = new List < Product2 > ();
        Product2 p = new Product2(Name = 'test pro', IsActive = true, ConvertTo__c = 'Subscription', ProductCode = 'abc');
        ProList.add(p);
        /*Product2 p2 = new Product2(Name = 'test pro2', IsActive = true, ConvertTo__c = 'Add On');
        ProList.add(p2);
        Product2 p3 = new Product2(Name = 'test pro3', IsActive = true, ConvertTo__c = 'Entitlement-Spark');
        ProList.add(p3);
        Product2 p4 = new Product2(Name = 'test pro4', IsActive = true, ConvertTo__c = 'Entitlement-Spark');
        ProList.add(p4);*/
        insert ProList;
        List < PriceBook2 > PriceB = [Select id from PriceBook2 where IsStandard = true limit 1];
        //Product2 prod = [SELECT p.Id FROM Product2 p WHERE p.Name = 'Lead Management - Professional 100K'];
        List < PriceBookEntry > PBEList = new List < PriceBookEntry > ();
        PriceBookEntry Pe = new PriceBookEntry(IsActive = true, PriceBook2Id = PriceB[0].id, Product2Id = p.id, UnitPrice = 200);
        PBEList.add(Pe);
        /*PriceBookEntry Pe2 = new PriceBookEntry(IsActive = true, PriceBook2Id = PriceB[0].id, Product2Id = p2.id, UnitPrice = 200);
        PBEList.add(Pe2);
        PriceBookEntry Pe3 = new PriceBookEntry(IsActive = true, PriceBook2Id = PriceB[0].id, Product2Id = p3.id, UnitPrice = 200);
        PBEList.add(Pe3);
        PriceBookEntry Pe4 = new PriceBookEntry(IsActive = true, PriceBook2Id = PriceB[0].id, Product2Id = p4.id, UnitPrice = 200);
        
        PBEList.add(Pe4);*/
        insert PBEList;
        /* List<PriceBookEntry> pbe_list = [Select p.Id, p.Name, p.Pricebook2Id, p.Product2Id , p.CreatedById , p.LastModifiedById From PricebookEntry p WHERE
                p.Pricebook2.Name = 'Standard Price Book' and p.IsActive = true];//and p.Name = 'Lead Management - Professional 100K' and p.IsActive = true];
            PricebookEntry pbe = pbe_list.get(0);*/
        List < OpportunityLineItem > OplList = new List < OpportunityLineItem > ();
        OpportunityLineItem oli = new OpportunityLineItem();
        //oli.Product_Family__c = 'test product family';
        oli.Users__c = 1;
        oli.MLM_Edition__c = 'test edition';
        oli.OpportunityId = Opp.Id;
        oli.PricebookEntryId = pe.Id;
        oli.Instance_Number__c = 123;
        oli.Quantity = 2;
        oli.UnitPrice = 200;
        //  oli.Quantity_1__c = 34;
        //  oli.Sales_Price_1__c = 500; 
        OplList.add(oli);
        /* OpportunityLineItem oli2 = new OpportunityLineItem();
        //oli.Product_Family__c = 'test product family';
        oli2.Users__c = 1;
        oli2.MLM_Edition__c = 'test edition';
        oli2.OpportunityId = Opp.Id;
        oli2.PricebookEntryId = pe2.Id;
        oli2.Quantity = 2;
        oli2.UnitPrice = 200;
        //   oli2.Quantity_1__c = 34;
        //   oli2.Sales_Price_1__c = 500; 
        OplList.add(oli2);
        OpportunityLineItem oli3 = new OpportunityLineItem();
        //oli.Product_Family__c = 'test product family';
        oli3.Users__c = 1;
        oli3.MLM_Edition__c = 'test edition';
        oli3.OpportunityId = Opp.Id;
        oli3.PricebookEntryId = pe3.Id;
        oli3.Quantity = 2;
        oli3.UnitPrice = 200;
        //  oli3.Quantity_1__c = 34;
        //  oli3.Sales_Price_1__c = 500; 
        OplList.add(oli3);
        OpportunityLineItem oli4 = new OpportunityLineItem();
        //oli.Product_Family__c = 'test product family';
        oli4.Users__c = 1;
        oli4.MLM_Edition__c = 'test edition';
        oli4.OpportunityId = Opp.Id;
        oli4.PricebookEntryId = pe4.Id;
        oli4.Quantity = 2;
        oli4.UnitPrice = 200;
        OplList.add(oli4);*/
        Test.StartTest();
        insert OplList;

        Opp.RecordTypeId = ClosedWonId;
        Opp.Stagename = 'Closed Won';
        update Opp;

        //createFromEmail(Opp.id ,'001','','abc','123','','aer');
        // createFromEmail(string OppID,string Munchkin , string PO,string ProductC,string InstanceNum,string Asse,string AccountPre)
        /* Account PartnerAccount = new Account(Name='Test Acc',Sales_Region__c = 'EMEA',Type='Partner');
        insert PartnerAccount ;
        Opp.AccountId = PartnerAccount.Id ; 
        update Opp;*/

        Test.stopTest();

    }
    
   }