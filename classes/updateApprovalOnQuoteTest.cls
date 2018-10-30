@isTest(SeeAllData=true)
private class updateApprovalOnQuoteTest
{
    static testmethod void DoTriggertest()
    {
         Account a = new Account(Name='Test Acc',Sales_Region__c = 'North America');
         a.BillingCity = 'NewYork';
         a.BillingCountry = 'United States';
         a.BillingStreet = 'Test Street';
         a.BillingState ='Test Billing State';
         a.BillingPostalCode ='12345';
         a.ShippingCity ='Pune';
         a.ShippingCountry ='India';
         a.ShippingPostalCode = '12345';
         a.ShippingState = '';
         a.ShippingStreet = 'Test Shipping Street';
         insert a;
        
         Contact c = new Contact(FirstName = 'test Con',LastName = 'test Con',LeadSource = 'Blog',AccountId = a.id);
         insert c;  
   
         List<Product2> productList = new List<Product2>();   
         Product2 p =new Product2(Name='test pro',ProductCode='INT-CUST',IsActive = true,Edition__c = 'Enterprise',ConvertTo__c = 'Subscription');
         productList.add(p);
         Product2 p2 =new Product2(Name='test pro2',IsActive = true,ConvertTo__c = 'Add On');
         productList.add(p2);
         Product2 p3 =new Product2(Name='test pro3',IsActive = true,ConvertTo__c = 'Entitlement-Spark');
         productList.add(p3);
         Product2 p4 =new Product2(Name='test pro4',IsActive = true,ConvertTo__c = 'Entitlement-Spark');
         productList.add(p4);
         insert productList;
         List<PriceBook2> PriceB = [Select id from PriceBook2 where IsStandard = true limit 1];
         //Product2 prod = [SELECT p.Id FROM Product2 p WHERE p.Name = 'Lead Management - Professional 100K'];
         
         List<PriceBookEntry> peList = new List<PriceBookEntry>();
         PriceBookEntry Pe = new PriceBookEntry(IsActive=true,PriceBook2Id=PriceB[0].id,Product2Id=p.id,UnitPrice=200);
         peList.add(Pe);
         PriceBookEntry Pe2 = new PriceBookEntry(IsActive=true,PriceBook2Id=PriceB[0].id,Product2Id=p2.id,UnitPrice=200);
         peList.add(Pe2);
         PriceBookEntry Pe3 = new PriceBookEntry(IsActive=true,PriceBook2Id=PriceB[0].id,Product2Id=p3.id,UnitPrice=200);
         peList.add(Pe3);
         PriceBookEntry Pe4 = new PriceBookEntry(IsActive=true,PriceBook2Id=PriceB[0].id,Product2Id=p4.id,UnitPrice=200);
         peList.add(Pe4);
         insert peList;
         
         Opportunity Opp = new Opportunity(Name='test opp',AccountId=a.id,Type='New Business',CloseDate=Date.today(),stagename='Discovery',Deal_Type__c = 'Standard',NextStep='test',CRM_System__c = 'ACT!',LeadSource = 'Blog',Primary_Marketo_User_Lookup__c = c.id);
         Opp.Pricebook2Id = PriceB[0].id;
         Opp.Rep_Create_ARR__c = 10;
         Opp.MainCompetitor__c = 'Act-On';
         insert Opp;
        
        /* List<PriceBookEntry> pbe_list = [Select p.Id, p.Name, p.Pricebook2Id, p.Product2Id , p.CreatedById , p.LastModifiedById From PricebookEntry p WHERE
                p.Pricebook2.Name = 'Standard Price Book' and p.IsActive = true];//and p.Name = 'Lead Management - Professional 100K' and p.IsActive = true];
            PricebookEntry pbe = pbe_list.get(0);*/
            
            Test.StartTest();
                    
            List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();        
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
            oliList.add(oli);
              
             OpportunityLineItem oli2 = new OpportunityLineItem();
            //oli.Product_Family__c = 'test product family';
            oli2.Users__c = 1;
            oli2.MLM_Edition__c = 'test edition';
            oli2.OpportunityId = Opp.Id;
            oli2.PricebookEntryId = pe2.Id;
            oli2.Quantity = 2;
            oli2.UnitPrice = 200;
         //   oli2.Quantity_1__c = 34;
         //   oli2.Sales_Price_1__c = 500; 
            oliList.add(oli2);
            
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
            oliList.add(oli3);
                
            OpportunityLineItem oli4 = new OpportunityLineItem();
            //oli.Product_Family__c = 'test product family';
            oli4.Users__c = 1;
            oli4.MLM_Edition__c = 'test edition';
            oli4.OpportunityId = Opp.Id;
            oli4.PricebookEntryId = pe4.Id;
              oli4.Quantity = 2;
                 oli4.UnitPrice = 200;
            oliList.add(oli4);  
            
            insert oliList;
            
            Quote q = new Quote();
            q.Maximum_Database_Size__c = 1000;           
            q.Name = 'test Quote'; 
            q.OpportunityId = Opp.Id;
            q.Pricebook2Id = PriceB[0].id;
            insert q;
            
         List<Quotelineitem> newQli = new List<Quotelineitem>(); 
           
            Quotelineitem qli = new Quotelineitem();
            qli.QuoteId = q.id;
            qli.PricebookEntryId = pe.Id;
            qli.Quantity = 2;
            qli.Discount = 50;
            qli.UnitPrice = 200;
            newQli.add(qli);
            //insert qli;
            
            Quotelineitem qli2 = new Quotelineitem();
            qli2.QuoteId = q.id;
            qli2.PricebookEntryId = Pe2.Id;
            qli2.Quantity = 2;
            qli2.UnitPrice = 100;
             newQli.add(qli2);
             
             insert newQli;
             
             system.assertEquals(2,newQli.size());
             delete qli;
            //insert qli;
            
            Test.StopTest();
    }

    
}