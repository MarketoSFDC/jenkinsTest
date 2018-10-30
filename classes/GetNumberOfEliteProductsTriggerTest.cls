@istest(SeeAllData=true)
public class GetNumberOfEliteProductsTriggerTest{
     static testmethod void mytest(){
         Account TestAcc1 = new Account(Name='Test Account');
         TestAcc1.BillingCity = 'NewYork';
         TestAcc1.BillingCountry = 'United States';
         TestAcc1.BillingStreet = 'Test Street';
         TestAcc1.BillingState ='Test Billing State';
         TestAcc1.BillingPostalCode ='12345';
         TestAcc1.ShippingCity ='Pune';
         TestAcc1.ShippingCountry ='India';
         TestAcc1.ShippingPostalCode = '12345';
         TestAcc1.ShippingState = '';
         TestAcc1.ShippingStreet = 'Test Shipping Street';
         insert TestAcc1;
         
         List_of_Elite_Products__c lep = new List_of_Elite_Products__c(Name = 'TESTPROD123321');
         insert lep;
         
         Product2 product = new Product2(Name = 'Test Product', ProductCode = 'TESTPROD123321', isActive=TRUE);
         insert product;
         
         Pricebook2 pb = [select id from Pricebook2 where isStandard = TRUE limit 1]; 
         
         PriceBookEntry pbe = new PriceBookEntry (Product2Id = product.id, PriceBook2Id = pb.id, UnitPrice = 10, isActive = TRUE);
         insert pbe;
               
         Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = TestAcc1.id, StageName = 'Discovery',Rep_Create_ARR__c = 10,MainCompetitor__c = 'Act-On',Number_of_Elite_Products__c = 0, CloseDate=System.Today());
         opp.Pricebook2Id = pb.id;
         insert opp;
         system.debug(opp.id);
        
         Opportunity opp2 = new Opportunity(Name = 'Test Opportunity', AccountId = TestAcc1.id, StageName = 'Discovery',Rep_Create_ARR__c = 10,MainCompetitor__c = 'Act-On', CloseDate=System.Today());
         opp.Pricebook2Id = pb.id;
         insert opp2;
         system.debug(opp2.id);
         
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
         
         //system.assert([select Number_of_Elite_Products__c from Opportunity where id = :opp.id].Number_of_Elite_Products__c == 2);
         //system.assert([select Number_of_Elite_Products__c from Opportunity where id = :opp2.id].Number_of_Elite_Products__c == 0);
     }
}