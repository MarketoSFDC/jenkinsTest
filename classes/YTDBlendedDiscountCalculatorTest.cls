/*
 * Author: Jade Global, Inc.
 * Date: 27th Oct 2016 
 * Purpose: Test class for YTDBlendedDiscountCalculator
 * */

@isTest
public class YTDBlendedDiscountCalculatorTest {

    public static Id stdPbId;
    public static List<Account> accntList = new List<Account>();
    public static List<Product2> prodList = new List<Product2>();
    public static List<PriceBook2> priceBookList = new List<PriceBook2>();
    public static List<PriceBookEntry> pbEntryStdPbList = new List<PriceBookEntry>();
    public static List<PriceBookEntry> pbEntryList = new List<PriceBookEntry>();
    
    @isTest static void test_YTDBlendedDisc1(){
       
        //********* Account Insertion ************
        accntList = TestCPQUtilityClass.createAccounts(1);
        System.debug('########## accntList: '+accntList);
        if(!accntList.isEmpty()){
            insert accntList;
        }//End of IF
        contact con=new contact(accountid=accntList[0].id,firstname='test',lastname='Contact', email='test@test.com',leadsource='Blog',mailingcountry='Australia');
		insert con;
		
        //********* Products Insertion ************
        prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].ProductCode ='PARENT';// 'BNDL-ENT-MKTGAUTO';

        prodList[1].ProductCode = 'PROD-APPS-INST';
        prodList[2].ProductCode = 'PROD-PLAT-SANDBOX-INST';

        for(Product2 pd: prodList){
            pd.Product_Type__c         ='Subscription ';
            pd.Family                  ='Subscription ';
            pd.Product_SubFamily__c    = 'Launch Pack';
            pd.Product_SubFamily2__c   = 'Launch Pack Core';
        }//End of FOR

        if(!prodList.isEmpty()){
            prodList[0].Family ='Bundle';
            insert prodList;
        }//End of IF
        
        //*************** Inserting Pricebook ********************
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }//End of IF
        
        // Get Id of Standard Pricebook
        stdPbId = Test.getStandardPricebookId();
        
        //************** Insert Products into Standard Pricebook *******************
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }//End Of FOR
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }//End of IF
        
        //************ Insert Products into Custom Pricebooks ***************
        pbEntryList = TestCPQUtilityClass.createPriceBookEntries(prodList, priceBookList);
        if(!pbEntryList.isEmpty()){
            insert pbEntryList;
        }//End of IF

       // insert opportunities - for Closed Won Oppty - Contract will be created automatically
        List<Opportunity> NBopptyList = new List<Opportunity>();
        NBopptyList = TestCPQUtilityClass.createOpportunities(accntList,1);
        for(Opportunity opp : NBopptyList){
            opp.Amount             = 2000;
            opp.Pricebook2Id         =  pricebookList[0].Id;
            opp.Deal_Type__c        ='Services';
            opp.Owner_Role_Custom_Text__c   = 'Test';
            opp.type             = 'New Business';
            opp.CloseDate                   = opp.CloseDate.addmonths(-3);  
        }
        Insert NBopptyList;
        
        list<Opportunity> newUpRNList = TestCPQUtilityClass.createOpportunities(accntList,2);
        
        newUpRNList[0].type = 'Upsell/Crossell';
        newUpRNList[0].Prior_Opportunity__c = NBopptyList[0].id;
        newUpRNList[1].Prior_Opportunity__c = NBopptyList[0].id;
        newUpRNList[1].type = 'Renewal';
        
        insert newUpRNList;
        
        newUpRNList.addAll(NBopptyList);
        Test.StartTest();
        List<SBQQ__Quote__c>  newQuoteList = TestCPQUtilityClass.createSimpleQuote(newUpRNList,1);
        for(SBQQ__Quote__c quote:  newQuoteList){
            quote.SBQQ__Primary__c =true;
			quote.ship_to_contact__c=con.id;
        }
        insert newQuoteList ;
         List<SBQQ__QuoteLine__c>  quoteLineList = TestCPQUtilityClass.createQuoteLines(newQuoteList,1,prodList);
         insert quoteLineList;
        list<opportunity> UpdateOpptyList = new list<Opportunity>();
        newUpRNList[0].Prior_Opportunity__c = NBopptyList[0].id;
        newUpRNList[1].Prior_Opportunity__c = NBopptyList[0].id;
        
        list<opportunitylineitem> oli=TestCPQUtilityClass.createOppLineItems(newUpRNList,pbEntryList);
        for(opportunitylineitem ol : oli){
            ol.users__c=10;
        }
        insert oli;
        
        newUpRNList[0].StageName = 'Signed Order';
        update newUpRNList[0];
        
        newUpRNList[0].StageName = 'Closed Won';
        
        UpdateOpptyList.add(newUpRNList[0]);
        UpdateOpptyList.add(newUpRNList[1]);
        Trigger_Opportunity_Helper.isAfterUpdateEvent = false;
        update newUpRNList;
 Test.StopTest();        
    }//End of method test_YTDBlendedDisc1()

    
    /*@isTest static void test_YTDBlendedDisc2(){
        //Test.StartTest();
       
        //********* Account Insertion ************
        accntList = TestCPQUtilityClass.createAccounts(1);
        System.debug('########## accntList: '+accntList);
        if(!accntList.isEmpty()){
            insert accntList;
        }//End of IF
        
        //********* Products Insertion ************
        prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].ProductCode ='PARENT';// 'BNDL-ENT-MKTGAUTO';

        prodList[1].ProductCode = 'PROD-APPS-INST';
        prodList[2].ProductCode = 'PROD-PLAT-SANDBOX-INST';

        for(Product2 pd: prodList){
            pd.Product_Type__c         ='Services';
            pd.Family                  ='Services';
            pd.Product_SubFamily__c    = 'Launch Pack';
            pd.Product_SubFamily2__c   = 'Launch Pack Core';
        }//End of FOR

        if(!prodList.isEmpty()){
            prodList[0].Family ='Bundle';
            insert prodList;
        }//End of IF
        
        //*************** Inserting Pricebook ********************
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }//End of IF
        
        // Get Id of Standard Pricebook
        stdPbId = Test.getStandardPricebookId();
        
        //************** Insert Products into Standard Pricebook *******************
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }//End Of FOR
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }//End of IF
        
        //************ Insert Products into Custom Pricebooks ***************
        pbEntryList = TestCPQUtilityClass.createPriceBookEntries(prodList, priceBookList);
        if(!pbEntryList.isEmpty()){
            insert pbEntryList;
        }//End of IF
        
        //********** Create New Business Opportunity **********
        List<Opportunity> oppotyList       = TestCPQUtilityClass.createOpportunities(accntList, 1);
        oppotyList[0].StageName            = 'Prospecting';
        oppotyList[0].PriceBook2Id         = priceBookList[0].id;
        oppotyList[0].Quarterly_Renewal__c = string.valueof(2);
        oppotyList[0].Sub_End_Date__c      = System.Today().addMonths(1);
        oppotyList[0].type                 = 'New Business';
        oppotyList[0].Deal_Type__c         = 'Standard';
        insert oppotyList;
        
        //*********** Create Quote ***********
        List<SBQQ__Quote__c> quotList = TestCPQUtilityClass.createQuotes(oppotyList,  1);
        List<SBQQ__Quote__c> InsertquotList = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote : quotList){
            quote.SBQQ__Primary__c = true;
            quote.Rubiks_Quote__c=false;
            InsertquotList.add(quote);
        }
        insert InsertquotList;
        
        Test.StartTest();
        //******* Create QuoteLine Parent ********
        List<Product2> prodListParent = new List<Product2>();
        prodListParent.add(prodList.get(0));
        
        //********* Inserting Bundle Line ***********
        List<SBQQ__QuoteLine__c> quoteLinesToInsertParent = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLineParent = new SBQQ__QuoteLine__c( SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[0].id);
        quoteLinesToInsertParent.add(quoteLineParent);
        insert quoteLinesToInsertParent;
        
        //******** Inserting Quote Lines under the Bundle *********
        List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500);
        SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500);
        SBQQ__QuoteLine__c quoteLine3 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[3].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500);
        SBQQ__QuoteLine__c quoteLine4 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[4].id,SBQQ__RegularPrice__c = 1000,SBQQ__CustomerPrice__c  = 500);
        quoteLinesToInsert.add(quoteLine);
        quoteLinesToInsert.add(quoteLine2);
        quoteLinesToInsert.add(quoteLine3);
        quoteLinesToInsert.add(quoteLine4);
        insert quoteLinesToInsert;
        
        //Test.StopTest();
        //Test.StartTest();
        
        //********** Closing the New Business Opportunity ***********
        oppotyList[0].StageName            = 'Closed Won';
        Update oppotyList;
        
        //******* Create Contract ********
        Contract contrct = new Contract(SBQQ__Quote__c=InsertquotList.get(0).id, Status='Draft',  Name='Test Contract ', AccountId=oppotyList[0].AccountId, SBQQ__Opportunity__c =oppotyList[0].Id, ContractTerm = 12, SBQQ__RenewalForecast__c = true, SBQQ__PreserveBundleStructureUponRenewals__c = true, SBQQ__DefaultRenewalContactRoles__c = true, SBQQ__DefaultRenewalPartners__c = true, StartDate=System.today());
        insert contrct;  
        contrct.Status='Activated';
        update contrct;
        
        //********* Creating Renewal Quote *********
        contrct.SBQQ__RenewalQuoted__c = TRUE;
        update contrct;
        
        Test.StopTest();
    }//End of method test_YTDBlendedDisc2()*/
    
    @isTest static void test_YTDBlendedDisc3(){

        //********* Account Insertion ************
        accntList = TestCPQUtilityClass.createAccounts(1);
        System.debug('########## accntList: '+accntList);
        if(!accntList.isEmpty()){
            insert accntList;
        }//End of IF
        
        //********* Products Insertion ************
        prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].ProductCode ='PARENT';// 'BNDL-ENT-MKTGAUTO';

        prodList[1].ProductCode = 'PROD-APPS-INST';
        prodList[2].ProductCode = 'PROD-PLAT-SANDBOX-INST';

        for(Product2 pd: prodList){
            pd.Product_Type__c         ='Services';
            pd.Family                  ='Services';
            pd.Product_SubFamily__c    = 'Launch Pack';
            pd.Product_SubFamily2__c   = 'Launch Pack Core';
        }//End of FOR

        if(!prodList.isEmpty()){
            prodList[0].Family ='Bundle';
            insert prodList;
        }//End of IF
        
        //*************** Inserting Pricebook ********************
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }//End of IF
        
        // Get Id of Standard Pricebook
        stdPbId = Test.getStandardPricebookId();
        
        //************** Insert Products into Standard Pricebook *******************
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }//End Of FOR
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }//End of IF
        
        //************ Insert Products into Custom Pricebooks ***************
        pbEntryList = TestCPQUtilityClass.createPriceBookEntries(prodList, priceBookList);
        if(!pbEntryList.isEmpty()){
            insert pbEntryList;
        }//End of IF
        
        //********** Create New Business Opportunity **********
        List<Opportunity> oppotyList       = TestCPQUtilityClass.createOpportunities(accntList, 1);
        oppotyList[0].StageName            = 'Prospecting';
        oppotyList[0].PriceBook2Id         = priceBookList[0].id;
        oppotyList[0].Quarterly_Renewal__c = string.valueof(2);
        oppotyList[0].Sub_End_Date__c      = System.Today().addMonths(1);
        oppotyList[0].type                 = 'New Business';
        oppotyList[0].Deal_Type__c         = 'Standard';
        insert oppotyList;
        
        oppotyList[0].StageName            = 'Closed Won';
        update oppotyList;
        
        //********** Create Upsell Opportunity **********
        List<Opportunity> UpsellOpptyList       = TestCPQUtilityClass.createOpportunities(accntList, 1);
        UpsellOpptyList[0].StageName            = 'Prospecting';
        UpsellOpptyList[0].PriceBook2Id         = priceBookList[0].id;
        UpsellOpptyList[0].Quarterly_Renewal__c = string.valueof(2);
        UpsellOpptyList[0].Sub_End_Date__c      = System.Today().addMonths(1);
        UpsellOpptyList[0].type                 = 'Upsell/Crossell';
        UpsellOpptyList[0].Deal_Type__c         = 'Standard';
        
        insert UpsellOpptyList;
        
        //*********** Create Quote on upsell ***********
        List<SBQQ__Quote__c> UpsellquoteList = TestCPQUtilityClass.createQuotes(UpsellOpptyList,  1);
        List<SBQQ__Quote__c> InsertUpsellquotList = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote : UpsellquoteList){
            quote.SBQQ__Primary__c = true;
            quote.Rubiks_Quote__c=false;
            InsertUpsellquotList.add(quote);
        }
        insert InsertUpsellquotList;
        
        Test.StartTest();
        //********* Inserting Bundle Line on Upsell ***********
        List<SBQQ__QuoteLine__c> UpsellquoteLinesToInsertParent = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c UpsellquoteLineParent = new SBQQ__QuoteLine__c( SBQQ__Quote__c=InsertUpsellquotList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[0].id);
        UpsellquoteLinesToInsertParent.add(UpsellquoteLineParent);
        insert UpsellquoteLinesToInsertParent;
        
        //******** Inserting Quote Lines under the Bundle *********
        List<SBQQ__QuoteLine__c> UpsellquoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c UpsellquoteLine = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=UpsellquoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertUpsellquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 700);
        SBQQ__QuoteLine__c UpsellquoteLine2 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=UpsellquoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertUpsellquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 700);
        SBQQ__QuoteLine__c UpsellquoteLine3 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=UpsellquoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertUpsellquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[3].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 700);
        SBQQ__QuoteLine__c UpsellquoteLine4 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=UpsellquoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertUpsellquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[4].id,SBQQ__RegularPrice__c = 1000,SBQQ__CustomerPrice__c  = 700);
        UpsellquoteLinesToInsert.add(UpsellquoteLine);
        UpsellquoteLinesToInsert.add(UpsellquoteLine2);
        UpsellquoteLinesToInsert.add(UpsellquoteLine3);
        UpsellquoteLinesToInsert.add(UpsellquoteLine4);
        insert UpsellquoteLinesToInsert;
        
        //Opportunity UpsellOppty = [SELECT id,Actual_Opportunity_ARR__c,Amount FROM Opportunity WHERE id = UpsellOpptyList[0].id];
        
        //System.debug('@@@@@@@@@ UpsellOppty: '+UpsellOppty);
        //System.assertEquals('1234567889',string.valueOf(UpsellOppty));
        
        list<opportunitylineitem> oli=TestCPQUtilityClass.createOppLineItems(UpsellOpptyList,pbEntryList);
        insert oli;
        
        //********** Closing the Upsell Opportunity ***********
        UpsellOpptyList[0].Prior_Opportunity__c = oppotyList[0].id;
        UpsellOpptyList[0].pse__Primary_Project__c=null;
        UpsellOpptyList[0].StageName = 'Signed Order';
        UpsellOpptyList[0].probability= 1;  
        UpsellOpptyList[0].Split_Opportunities__c= null; 
        UpsellOpptyList[0].ghost__c= false;    
        Update UpsellOpptyList;
        UpsellOpptyList[0].StageName = 'Closed Won';
        Update UpsellOpptyList;
        
        //System.assertEquals(UpsellOpptyList[0].Prior_Opportunity__c,UpsellOpptyList[0].id);
        
        //System.debug('@!@!@!@!@!@!@ UpsellOpptyList[0].type: '+UpsellOpptyList[0].type);
        //System.debug('@!@!@!@!@!@!@ UpsellOpptyList[0].StageName: '+UpsellOpptyList[0].StageName);
        //System.debug('@!@!@!@!@!@!@ UpsellOpptyList[0].Prior_Opportunity__c: '+UpsellOpptyList[0].Prior_Opportunity__c);
        //System.debug('@!@!@!@!@!@!@ UpsellOpptyList[0].isWon: '+UpsellOpptyList[0].IsWon);
        
        Test.StopTest();
    }//End of method test_YTDBlendedDisc3()
    
}