@isTest(SeeAllData=true)
public class DTOTriggerTest{
    
    static testmethod void mytest1(){
        Account acc = UtilityToCreateTestData.insertAccount();
        Product2 prod = UtilityToCreateTestData.insertProduct2();
        PriceBook2 pb = UtilityToCreateTestData.getStandardPriceBook();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pb.id);
        Test.StartTest();
        // new Oppty
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = acc.Id, StageName = 'Test Stage',Rep_Create_ARR__c = 10,MainCompetitor__c = 'Act-On',CloseDate=System.today().addMonths(3));
        opp.Pricebook2Id = pb.id;
        insert opp;
        //Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Discovery', 'New Business', System.Today());
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        //DTOUtility.isDTOTriggerExecuted = FALSE;
        opp.StageName = 'Closed Won';
        update opp;
        Test.StopTest();
    }
    
    static testmethod void mytest2(){
        Account acc = UtilityToCreateTestData.insertAccount();
        Product2 prod = UtilityToCreateTestData.insertProduct2();
        PriceBook2 pb = UtilityToCreateTestData.getStandardPriceBook();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pb.id);
        Test.StartTest();
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = acc.Id, StageName = 'Test Stage',Rep_Create_ARR__c = 10,MainCompetitor__c = 'Act-On',CloseDate=System.today().addMonths(3));
        opp.Pricebook2Id = pb.id;
        insert opp;
        //Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Discovery', 'Renewal', System.Today());
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
    static testmethod void mytest3(){
        Account acc = UtilityToCreateTestData.insertAccount();
        Product2 prod = UtilityToCreateTestData.insertProduct2();
        PriceBook2 pb = UtilityToCreateTestData.getStandardPriceBook();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pb.id);
        // new Oppty
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = acc.Id, StageName = 'Test Stage',CloseDate=System.today().addMonths(3));
        opp.Pricebook2Id = pb.id;
        insert opp;
        //Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Discovery', 'Renewal', System.Today()-1);
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        Test.StartTest();
        
        // new Oppty
        Opportunity opp2 = new Opportunity(Name = 'Test Opportunity', AccountId = acc.Id, StageName = 'Test Stage',CloseDate=System.today().addMonths(3));
        opp2.Pricebook2Id = pb.id;
        insert opp2;
        //Opportunity opp2 = UtilityToCreateTestData.insertOpportunity(acc.id, 'Discovery', 'Renewal', System.Today());
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
    static testmethod void mytest4(){
        Account acc = UtilityToCreateTestData.insertAccount();
        Product2 prod = UtilityToCreateTestData.insertProduct2();
        PriceBook2 pb = UtilityToCreateTestData.getStandardPriceBook();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pb.id);
        Test.StartTest();
        // new Oppty
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = acc.Id, StageName = 'Test Stage',Rep_Create_ARR__c = 10,MainCompetitor__c = 'Act-On',CloseDate=System.today().addMonths(3));
        opp.Pricebook2Id = pb.id;
        insert opp;
        //Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Closed Won', 'New Business', System.Today());
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        delete so;
        Test.StopTest();
    }
    
    static testmethod void mytest5(){
        Account acc = UtilityToCreateTestData.insertAccount();
        Product2 prod = UtilityToCreateTestData.insertProduct3();
        Product2 prod2 = UtilityToCreateTestData.insertProduct2();
        PriceBook2 pb = UtilityToCreateTestData.getStandardPriceBook();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pb.id);
        PriceBookEntry pbe2 = UtilityToCreateTestData.insertPriceBookEntry(prod2.id, pb.id);
        Test.StartTest();
        // new Oppty
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = acc.Id, StageName = 'Test Stage',Rep_Create_ARR__c = 10,MainCompetitor__c = 'Act-On',CloseDate=System.today().addMonths(3));
        opp.Pricebook2Id = pb.id;
        insert opp;
        //Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Closed Won', 'Renewal', System.Today());
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe2.id, 10, 1);
        OpportunityLineItem opli2 = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        Test.StopTest();
    }
    
    static testmethod void mytest6(){
        Account acc = UtilityToCreateTestData.insertAccount();
        Product2 prod = UtilityToCreateTestData.insertProduct4();
        Product2 prod2 = UtilityToCreateTestData.insertProduct2();
        Product2 prod3 = UtilityToCreateTestData.insertProduct5();
        PriceBook2 pb = UtilityToCreateTestData.getStandardPriceBook();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pb.id);
        PriceBookEntry pbe2 = UtilityToCreateTestData.insertPriceBookEntry(prod2.id, pb.id);
        PriceBookEntry pbe3 = UtilityToCreateTestData.insertPriceBookEntry(prod3.id, pb.id);
        Test.StartTest();
        // new Oppty
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = acc.Id, StageName = 'Test Stage',Rep_Create_ARR__c = 10,MainCompetitor__c = 'Act-On',CloseDate=System.today().addMonths(3));
        opp.Pricebook2Id = pb.id;
        insert opp;
        //Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Closed Won', 'Renewal', System.Today());
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe2.id, 10, 1);
        OpportunityLineItem opli2 = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        OpportunityLineItem opli3 = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe3.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        Test.StopTest();
    }
    
    static testmethod void mytest7(){
        Account acc = UtilityToCreateTestData.insertAccount();
        Product2 prod = UtilityToCreateTestData.insertProduct2();
        PriceBook2 pb = UtilityToCreateTestData.getStandardPriceBook();
        PriceBookEntry pbe = UtilityToCreateTestData.insertPriceBookEntry(prod.id, pb.id);
        Test.StartTest();
        // new Oppty
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = acc.Id, StageName = 'Test Stage',Rep_Create_ARR__c = 10,MainCompetitor__c = 'Act-On',CloseDate=System.today().addMonths(3));
        opp.Pricebook2Id = pb.id;
        insert opp;
        
        //Opportunity opp = UtilityToCreateTestData.insertOpportunity(acc.id, 'Closed Won', 'New Business', System.Today());
        OpportunityLineItem opli = UtilityToCreateTestData.insertOppLineItem(opp.id, pbe.id, 10, 1);
        Sales_Order__c so = UtilityToCreateTestData.insertSalesOrder(opp.id);
        opp.StageName = 'Discovery';
        update opp;
        //DTOUtility.isDTOTriggerExecuted = FALSE;
        opp.StageName = 'Closed Won';
        update opp;
        Test.StopTest();
    }
}