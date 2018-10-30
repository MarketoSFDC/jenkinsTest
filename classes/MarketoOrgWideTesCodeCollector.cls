/**
   GOAL: THIS IS GENERAL TEST CODE COLLECTOR- CREATED IN CODE CEOVERAGE PROJECT
   BY: GRAZITTI
**/
@isTest
public class MarketoOrgWideTesCodeCollector {
/*    
    public static testmethod void MarketoUniversityCalendar(){
        MarketoUniversityCalendar controller = new MarketoUniversityCalendar();        
        controller.submit();
        Utility.isFutureUpdate = false; 
        Utility.haveRunAlertDatanyzeUpdate = true;  
        Utility.isUpdateContactOwnerAsAccountOwnerRunningOnceMore = true;
        Account ac = Utility.insertAccountInTestClasses();
        insert ac;
        controller.getUserCodeToMatch('10078', ac.Id);
    }
*/    
    static testMethod void BAUATMethod1(){
        test.startTest();
        Account acc = Utility.insertAccountInTestClasses();
        insert acc;
        Asset NewAs = new Asset(Name='Test',AccountId=acc.Id,Maximum_Database_Size__c=10000,Munchkin_ID__c='123-ABC');
        insert NewAs;
        
        BatchApexUpdateAssets ba = new BatchApexUpdateAssets();
        
        List<Asset> astList = new List<Asset>();
        astList.add(NewAs);
        ba.Asset_List = astList;
        ba.start(null);
        ba.execute(null,astList);
        ba.finish(null);

        test.stopTest();
    }
    
    static testMethod void BAUOMethod1(){
        test.startTest();
        Account acc = Utility.insertAccountInTestClasses();
        insert acc;
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = acc.id, StageName = 'Not Contacted', type = 'Renewal', CloseDate=System.Today());
        insert opp;
        Product2 prod = UtilityToCreateTestData.insertProduct();
        PriceBookEntry pbe2 = new PriceBookEntry (Product2Id =prod.Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 10, isActive = TRUE, CurrencyIsoCode = 'USD');
        insert pbe2;
        Asset NewAs = new Asset(Name='Test',AccountId=acc.Id,Maximum_Database_Size__c=10000,Munchkin_ID__c='123-ABC', Product2Id =prod.Id);
        insert NewAs;
        OpportunityLineItem oliTest = new OpportunityLineItem();
        oliTest.OpportunityId = opp.Id;
        oliTest.PricebookEntryId = pbe2.Id; 
        oliTest.UnitPrice = 1234.00; 
        oliTest.Quantity = 2;
        
        insert oliTest;
        List<OpportunityLineItem> oliList2 = new List<OpportunityLineItem>([SELECT ID, OpportunityID, Pricebookentry.Product2ID, Opportunity.AccountID, related_asset__c FROM OpportunityLineItem WHERE Opportunity.stageName = 'Not Contacted' and Opportunity.type = 'Renewal' and related_asset__c= null AND ID =: oliTest.Id LIMIT 1]);
        
        BatchApexUpdateoli ba = new BatchApexUpdateoli();
        
        List<OpportunityLineItem> oliList = new List<OpportunityLineItem>();
        LIST<ASSET> astList = new LIST<ASSET>();

       // MAP <ID,LIST<ASSET>> ACCNTASSMAP= NEW MAP<ID,LIST<ASSET>>();
        astList.add(NewAs);
        ba.AccountIDs.add(acc.ID);
        ba.Act_IDs.add(acc.ID);
        
        ba.newOli_List.add(oliTest);
        oliList.add(oliTest);
        ba.AST = astList;
        ba.ACCNTASSMAP.put(acc.Id, astList);
        ba.newOli_List = oliList;
        ba.start(null);
        
        ba.execute(null,oliList2);
        ba.finish(null);

        test.stopTest();
    }
}