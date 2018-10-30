/**************************************************************
last modified by : Sumit Bhatt, Grazitti Interactive
last Modified Date : 13-April-2018
changes done: #APPS-10924# Remove functionality that is not needed for Account Score
Tracking : One can track the changes by searching the ticket number in the code 
**************************************************************/
@isTest(seeAlldata=false)
private class BillingSchedule_Test {
    
        public static Id stdPbId;
        public static List<Account> accntList = new List<Account>();
        public static List<Product2> prodList = new List<Product2>();
        public static List<PriceBook2> priceBookList = new List<PriceBook2>();
        public static List<PriceBookEntry> pbEntryStdPbList = new List<PriceBookEntry>();
        public static List<PriceBookEntry> pbEntryList = new List<PriceBookEntry>();
        
    
    @isTest static void BillingSchedule_NewBusinessTestMethod() {
 
       //Insert data in payment frequency custom setting 
       List<QuotePaymentFrequency__c> payFreq=new List<QuotePaymentFrequency__c>();
       QuotePaymentFrequency__c payfre1= new QuotePaymentFrequency__c(Name='Annually',paymentFrequencyTerm__c=12);
       QuotePaymentFrequency__c payfre2= new QuotePaymentFrequency__c(Name='Monthly',paymentFrequencyTerm__c=1);
       QuotePaymentFrequency__c payfre3= new QuotePaymentFrequency__c(Name='Quarterly',paymentFrequencyTerm__c=3);
       QuotePaymentFrequency__c payfre4= new QuotePaymentFrequency__c(Name='Semi-Annually',paymentFrequencyTerm__c=6);
       payFreq.add(payfre1);
       payFreq.add(payfre2);
       payFreq.add(payfre3);
       payFreq.add(payfre4);
       insert payFreq;  
       system.debug('################### payFreq'+payFreq);
           
        //Insert data in Marketo Entity On Quote custom setting 
        List<MarketoEntityOnQuote__c> MKTOEntity = new List<MarketoEntityOnQuote__c>();
        MarketoEntityOnQuote__c MKTOEntity1=new MarketoEntityOnQuote__c(Name='Marketo EMEA, Limited',Date_Format__c='{0,date,dd/MM/yyyy}');
        MarketoEntityOnQuote__c MKTOEntity2=new MarketoEntityOnQuote__c(Name='Marketo, Inc.',Date_Format__c='{0,date,dd/MM/yyyy}');
        MarketoEntityOnQuote__c MKTOEntity3=new MarketoEntityOnQuote__c(Name='Marketo, KK',Date_Format__c='{0,date,dd/MM/yyyy}');
        MKTOEntity.add(MKTOEntity1) ;
        MKTOEntity.add(MKTOEntity2) ;
        MKTOEntity.add(MKTOEntity3) ;
        insert MKTOEntity; 
        system.debug('################### MKTOEntity'+MKTOEntity);
        
        //Insert data in billing schedule number Format custom setting
        List<numberFormat__c> noFormat=new list<numberFormat__c>(); 
        numberFormat__c noFormat1=new numberFormat__c(Name='AUD',numberFormat__c='{0, number, #,###.00}');
        numberFormat__c noFormat2=new numberFormat__c(Name='EUR',numberFormat__c='{0, number, #,###.00}');
        numberFormat__c noFormat3=new numberFormat__c(Name='GBP',numberFormat__c='{0, number, #,###.00}');
        numberFormat__c noFormat4=new numberFormat__c(Name='JPY',numberFormat__c='{0, number,}');
        numberFormat__c noFormat5=new numberFormat__c(Name='USD',numberFormat__c='{0, number, #,###.00}');
        noFormat.add(noFormat1);
        noFormat.add(noFormat2);
        noFormat.add(noFormat3);
        noFormat.add(noFormat4);
        noFormat.add(noFormat5);
        insert noFormat;
        system.debug('################### noFormat'+noFormat);
        
        
        //Add Data in custom setting 
        /*AccountScorerSettings__c accSetting=new AccountScorerSettings__c(Name='executionsetting',Disable_Account_Score_Trigger__c=true,exceutionMode__c='create',settingsMode__c='off',triggerMode__c='on');
        
        insert accSetting;*/

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
        List<Opportunity> oppotyList       = TestCPQUtilityClass.createOpportunities(accntList, 2);
        oppotyList[0].StageName            = '3 - Solution Definition';
        oppotyList[0].PriceBook2Id         = priceBookList[0].id;
        oppotyList[0].Quarterly_Renewal__c = string.valueof(2);
        oppotyList[0].Sub_End_Date__c      = System.Today().addMonths(1);
        oppotyList[0].type                 = 'New Business';
        oppotyList[0].Deal_Type__c         = 'Standard';
        insert oppotyList;
        
        //*********** Create County Record for displaying Marketo Entity on quote
        Country__c country=new Country__c();
        country.Country_Registered_Office_Address__c='Marketo, Inc., 901 Mariners Island Blvd Suite 200, San Mateo, CA, 94404, United States';
        insert country;
        system.assertNotEquals(null,country);
        //*********** Create Quote ***********
        List<SBQQ__Quote__c> quotList = TestCPQUtilityClass.createQuotes(oppotyList, 1);
        system.debug('##########quotList'+quotList);
        //System.assertEquals(1,quotList.size());
        List<SBQQ__Quote__c> InsertquotList = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote : quotList){
            quote.SBQQ__Primary__c = true;
            //quote.SBQQ__Status__c='Draft';
            //quote.SBQQ__Opportunity2__c=oppotyList[0].id;
            quote.SBQQ__StartDate__c = System.Today();
            quote.Rubiks_Quote__c=true;
            quote.MDQ_Quote__c=true;
            quote.Payment_Frequency__c='Quarterly';
            quote.Include_Billing_Schedule__c=true;
            quote.SBQQ__SubscriptionTerm__c=17; 
            //quote.Country__c=country.id;
            quote.SBQQ__ShippingCountry__c='USA';
            quote.CurrencyIsoCode='USD';
            InsertquotList.add(quote);
        }
        insert InsertquotList;
        system.debug('############### InsertquotList'+InsertquotList);
        //system.assertEquals(1, InsertquotList.size());
        List<Product2> prodListParent = new List<Product2>();
        prodListParent.add(prodList.get(0));
        
         //********* Inserting Bundle Line ***********
        List<SBQQ__QuoteLine__c> quoteLinesToInsertParent = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLineParent = new SBQQ__QuoteLine__c( SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[0].id);
        quoteLinesToInsertParent.add(quoteLineParent);
        insert quoteLinesToInsertParent;
        system.debug('############### quoteLinesToInsertParent'+quoteLinesToInsertParent);
        Test.StartTest();
        //******** Inserting Quote Lines under the Bundle *********
        List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
        Date secoundSegmentStartdate=InsertquotList.get(0).SBQQ__StartDate__c.addMonths(3);
        
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=InsertquotList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=InsertquotList.get(0).SBQQ__StartDate__c.addMonths(3),SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=10,SBQQ__NetPrice__c=50000,MKTO_Effective_End_Date__c=system.today().addMonths(10),Product_Type__c='Subscription');
        
        SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__EndDate__c=InsertquotList.get(0).SBQQ__StartDate__c.addMonths(3),SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=10,SBQQ__NetPrice__c=40000,MKTO_Effective_End_Date__c=system.today().addMonths(10),Product_Type__c='Subscription');
        
        SBQQ__QuoteLine__c quoteLine3 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=secoundSegmentStartdate.adddays(1),SBQQ__EndDate__c=InsertquotList.get(0).Calc_End_Date__c,SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=7,SBQQ__NetPrice__c=60000,MKTO_Effective_End_Date__c=system.today().addMonths(7),Product_Type__c='Subscription');
       
        SBQQ__QuoteLine__c quoteLine4 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[2].id,SBQQ__RegularPrice__c = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=secoundSegmentStartdate.adddays(1),SBQQ__EndDate__c=InsertquotList.get(0).Calc_End_Date__c,SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=7,SBQQ__NetPrice__c=80000,MKTO_Effective_End_Date__c=system.today().addMonths(7),Product_Type__c='Subscription');
       
        quoteLinesToInsert.add(quoteLine);
        quoteLinesToInsert.add(quoteLine2);
        quoteLinesToInsert.add(quoteLine3);
        quoteLinesToInsert.add(quoteLine4);
        insert quoteLinesToInsert;
       system.debug('############### quoteLinesToInsert'+quoteLinesToInsert);
       system.assertequals(4,quoteLinesToInsert.size());

        //Id idVariable=InsertquotList[0].id;
        SBQQ__Quote__c quoteDetails=[SELECT id,Name from SBQQ__Quote__c where id=:InsertquotList[0].id];
        
    
        //system.debug('idVariable ##############'+idVariable);
        //system.assertEquals('aAp3B0000004HcB',quoteDetails.id);
        PageReference p=Page.SBQQ__PreviewDocument;
        Test.setCurrentPageReference(p); 
        System.currentPageReference().getParameters().put('qid', quoteDetails.id);
        
        billingScheduleVFComponentController controller = new billingScheduleVFComponentController() ;
        
        Test.stopTest();
        
        
    }
    
    //Renewal 
     
     @isTest static void BillingSchedule_RenewalTestMethod() {
 
       //Insert data in payment frequency custom setting 
       List<QuotePaymentFrequency__c> payFreq=new List<QuotePaymentFrequency__c>();
       QuotePaymentFrequency__c payfre1= new QuotePaymentFrequency__c(Name='Annually',paymentFrequencyTerm__c=12);
       QuotePaymentFrequency__c payfre2= new QuotePaymentFrequency__c(Name='Monthly',paymentFrequencyTerm__c=1);
       QuotePaymentFrequency__c payfre3= new QuotePaymentFrequency__c(Name='Quarterly',paymentFrequencyTerm__c=3);
       QuotePaymentFrequency__c payfre4= new QuotePaymentFrequency__c(Name='Semi-Annually',paymentFrequencyTerm__c=6);
       payFreq.add(payfre1);
       payFreq.add(payfre2);
       payFreq.add(payfre3);
       payFreq.add(payfre4);
       insert payFreq;  
       system.debug('################### payFreq'+payFreq);
           
        //Insert data in Marketo Entity On Quote custom setting 
        List<MarketoEntityOnQuote__c> MKTOEntity = new List<MarketoEntityOnQuote__c>();
        MarketoEntityOnQuote__c MKTOEntity1=new MarketoEntityOnQuote__c(Name='Marketo EMEA, Limited',Date_Format__c='{0,date,dd/MM/yyyy}');
        MarketoEntityOnQuote__c MKTOEntity2=new MarketoEntityOnQuote__c(Name='Marketo, Inc.',Date_Format__c='{0,date,dd/MM/yyyy}');
        MarketoEntityOnQuote__c MKTOEntity3=new MarketoEntityOnQuote__c(Name='Marketo, KK',Date_Format__c='{0,date,dd/MM/yyyy}');
        MKTOEntity.add(MKTOEntity1) ;
        MKTOEntity.add(MKTOEntity2) ;
        MKTOEntity.add(MKTOEntity3) ;
        insert MKTOEntity; 
        system.debug('################### MKTOEntity'+MKTOEntity);
        
        //Insert data in billing schedule number Format custom setting
        List<numberFormat__c> noFormat=new list<numberFormat__c>(); 
        numberFormat__c noFormat1=new numberFormat__c(Name='AUD',numberFormat__c='{0, number, #,###.00}');
        numberFormat__c noFormat2=new numberFormat__c(Name='EUR',numberFormat__c='{0, number, #,###.00}');
        numberFormat__c noFormat3=new numberFormat__c(Name='GBP',numberFormat__c='{0, number, #,###.00}');
        numberFormat__c noFormat4=new numberFormat__c(Name='JPY',numberFormat__c='{0, number,}');
        numberFormat__c noFormat5=new numberFormat__c(Name='USD',numberFormat__c='{0, number, #,###.00}');
        noFormat.add(noFormat1);
        noFormat.add(noFormat2);
        noFormat.add(noFormat3);
        noFormat.add(noFormat4);
        noFormat.add(noFormat5);
        insert noFormat;
        system.debug('################### noFormat'+noFormat);
        
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
            pd.Product_Type__c         ='Product_Type__c';
            pd.Family                  ='Product_Type__c';
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
        oppotyList[0].StageName            = 'Not Contacted';
        oppotyList[0].PriceBook2Id         = priceBookList[0].id;
        oppotyList[0].Quarterly_Renewal__c = string.valueof(2);
        oppotyList[0].Sub_End_Date__c      = System.Today().addMonths(1);
        oppotyList[0].type                 = 'Renewal';
        oppotyList[0].Deal_Type__c         = 'Standard';
        insert oppotyList;
        system.debug('############### oppotyList'+oppotyList);
        
        //*********** Create County Record for displaying Marketo Entity on quote
        Country__c country=new Country__c();
        country.Country_Registered_Office_Address__c='Marketo, Inc., 901 Mariners Island Blvd Suite 200, San Mateo, CA, 94404, United States';
        insert country;
        system.assertNotEquals(null,country);
        //*********** Create Quote ***********
        List<SBQQ__Quote__c> quotList = TestCPQUtilityClass.createQuotes(oppotyList, 1);
        system.debug('##########quotList'+quotList);
        //System.assertEquals(1,quotList.size());
        List<SBQQ__Quote__c> InsertquotList = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote : quotList){
            quote.SBQQ__Primary__c = true;
            quote.SBQQ__Status__c='Draft';
            quote.SBQQ__Opportunity2__c=oppotyList[0].id;
            quote.SBQQ__StartDate__c = System.Today();
            quote.Rubiks_Quote__c=true;
            quote.MDQ_Quote__c=true;
            quote.Payment_Frequency__c='Quarterly';
            quote.Include_Billing_Schedule__c=true;
            quote.SBQQ__SubscriptionTerm__c=14; 
            quote.Country__c=country.id;
            quote.SBQQ__ShippingCountry__c='USA';
            quote.CurrencyIsoCode='USD';
            InsertquotList.add(quote);
        }
        insert InsertquotList;
        system.debug('############### InsertquotList'+InsertquotList);
        system.assertEquals(1, InsertquotList.size());
        List<Product2> prodListParent = new List<Product2>();
        prodListParent.add(prodList.get(0));
        
         //********* Inserting Bundle Line ***********
        List<SBQQ__QuoteLine__c> quoteLinesToInsertParent = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLineParent = new SBQQ__QuoteLine__c( SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[0].id);
        quoteLinesToInsertParent.add(quoteLineParent);
        insert quoteLinesToInsertParent;
        system.debug('############### quoteLinesToInsertParent'+quoteLinesToInsertParent);
        Test.StartTest();
        //******** Inserting Quote Lines under the Bundle *********
        List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
        Date secoundSegmentStartdate=InsertquotList.get(0).SBQQ__StartDate__c.addMonths(3);
        
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=InsertquotList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=InsertquotList.get(0).SBQQ__StartDate__c.addMonths(3),SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=7,SBQQ__NetPrice__c=40000,MKTO_Effective_End_Date__c=system.today().addMonths(7),Product_Type__c='Subscription');
        
        SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__EndDate__c=InsertquotList.get(0).SBQQ__StartDate__c.addMonths(3),SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=7,SBQQ__NetPrice__c=50000,MKTO_Effective_End_Date__c=system.today().addMonths(7),Product_Type__c='Subscription');
        
        SBQQ__QuoteLine__c quoteLine3 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=secoundSegmentStartdate.adddays(1),SBQQ__EndDate__c=InsertquotList.get(0).Calc_End_Date__c,SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=7,SBQQ__NetPrice__c=60000,MKTO_Effective_End_Date__c=system.today().addMonths(7),Product_Type__c='Subscription');
       
        SBQQ__QuoteLine__c quoteLine4 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[2].id,SBQQ__RegularPrice__c = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=secoundSegmentStartdate.adddays(1),SBQQ__EndDate__c=InsertquotList.get(0).Calc_End_Date__c,SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=7,SBQQ__NetPrice__c=70000,MKTO_Effective_End_Date__c=system.today().addMonths(7),Product_Type__c='Subscription');
       
        quoteLinesToInsert.add(quoteLine);
        quoteLinesToInsert.add(quoteLine2);
        quoteLinesToInsert.add(quoteLine3);
        quoteLinesToInsert.add(quoteLine4);
        insert quoteLinesToInsert;
       system.debug('############### quoteLinesToInsert'+quoteLinesToInsert);
       system.assertequals(4,quoteLinesToInsert.size());
     
        
        //Id idVariable=InsertquotList[0].id;
        SBQQ__Quote__c quoteDetails=[SELECT id,Name,Calc_End_Date__c from SBQQ__Quote__c where id=:InsertquotList[0].id];
        //system.assertEquals(null,quoteDetails.Calc_End_Date__c);
        //system.debug('idVariable ##############'+idVariable);
        //system.assertEquals('aAp3B0000004HcB',quoteDetails.id);
        PageReference p=Page.SBQQ__PreviewDocument;
        Test.setCurrentPageReference(p); 
        System.currentPageReference().getParameters().put('qid', quoteDetails.id);
        
        list<SBQQ__QuoteLine__c> quoteLineItems=[SELECT id,SBQQ__ProductCode__c,MKTO_Net_Total__c,SBQQ__NetTotal__c,SBQQ__EffectiveStartDate__c,MKTO_Effective_End_Date__c,SBQQ__SegmentIndex__c,MKTO_Net_Unit_Price__c,SBQQ__SegmentLabel__c,MKTO_Product_Name__c,SBQQ__Quote__r.SBQQ__SubscriptionTerm__c,SBQQ__Quote__r.SBQQ__StartDate__c,SBQQ__Quote__r.MKTO_Effective_End_Date__c,SBQQ__Quote__r.Payment_Frequency__c,CurrencyIsoCode,Product_Type__c,SBQQ__StartDate__c,MKTO_Effective_Term__c,Effective_Subscription_Term__c FROM SBQQ__QuoteLine__c where SBQQ__Quote__r.Id=:quoteDetails.id AND SBQQ__Quote__r.Payment_Frequency__c!='Non-Standard' AND SBQQ__Quote__r.Payment_Frequency__c!='One-Time' AND SBQQ__Quote__r.MKTO_Effective_End_Date__c!=null AND SBQQ__NetTotal__c!=0  order by SBQQ__EffectiveStartDate__c ASC];

        system.assertequals(5,quoteLineItems.size());
        billingScheduleVFComponentController controller = new billingScheduleVFComponentController() ;
        
        Test.stopTest();
        
        
    }
    
        @isTest static void BillingSchedule_NewBusinessShortTestMethod() {
 
       //Insert data in payment frequency custom setting 
       List<QuotePaymentFrequency__c> payFreq=new List<QuotePaymentFrequency__c>();
       QuotePaymentFrequency__c payfre1= new QuotePaymentFrequency__c(Name='Annually',paymentFrequencyTerm__c=12);
       QuotePaymentFrequency__c payfre2= new QuotePaymentFrequency__c(Name='Monthly',paymentFrequencyTerm__c=1);
       QuotePaymentFrequency__c payfre3= new QuotePaymentFrequency__c(Name='Quarterly',paymentFrequencyTerm__c=3);
       QuotePaymentFrequency__c payfre4= new QuotePaymentFrequency__c(Name='Semi-Annually',paymentFrequencyTerm__c=6);
       payFreq.add(payfre1);
       payFreq.add(payfre2);
       payFreq.add(payfre3);
       payFreq.add(payfre4);
       insert payFreq;  
       system.debug('################### payFreq'+payFreq);
           
        //Insert data in Marketo Entity On Quote custom setting 
        List<MarketoEntityOnQuote__c> MKTOEntity = new List<MarketoEntityOnQuote__c>();
        MarketoEntityOnQuote__c MKTOEntity1=new MarketoEntityOnQuote__c(Name='Marketo EMEA, Limited',Date_Format__c='{0,date,dd/MM/yyyy}');
        MarketoEntityOnQuote__c MKTOEntity2=new MarketoEntityOnQuote__c(Name='Marketo, Inc.',Date_Format__c='{0,date,dd/MM/yyyy}');
        MarketoEntityOnQuote__c MKTOEntity3=new MarketoEntityOnQuote__c(Name='Marketo, KK',Date_Format__c='{0,date,dd/MM/yyyy}');
        MKTOEntity.add(MKTOEntity1) ;
        MKTOEntity.add(MKTOEntity2) ;
        MKTOEntity.add(MKTOEntity3) ;
        insert MKTOEntity; 
        system.debug('################### MKTOEntity'+MKTOEntity);
        
        //Insert data in billing schedule number Format custom setting
        List<numberFormat__c> noFormat=new list<numberFormat__c>(); 
        numberFormat__c noFormat1=new numberFormat__c(Name='AUD',numberFormat__c='{0, number, #,###.00}');
        numberFormat__c noFormat2=new numberFormat__c(Name='EUR',numberFormat__c='{0, number, #,###.00}');
        numberFormat__c noFormat3=new numberFormat__c(Name='GBP',numberFormat__c='{0, number, #,###.00}');
        numberFormat__c noFormat4=new numberFormat__c(Name='JPY',numberFormat__c='{0, number,}');
        numberFormat__c noFormat5=new numberFormat__c(Name='USD',numberFormat__c='{0, number, #,###.00}');
        noFormat.add(noFormat1);
        noFormat.add(noFormat2);
        noFormat.add(noFormat3);
        noFormat.add(noFormat4);
        noFormat.add(noFormat5);
        insert noFormat;
        system.debug('################### noFormat'+noFormat);
        
        
        //Add Data in custom setting 
        /*AccountScorerSettings__c accSetting=new AccountScorerSettings__c(Name='executionsetting',Disable_Account_Score_Trigger__c=true,exceutionMode__c='create',settingsMode__c='off',triggerMode__c='on');
        
        insert accSetting;*/

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
        List<Opportunity> oppotyList       = TestCPQUtilityClass.createOpportunities(accntList, 2);
        oppotyList[0].StageName            = '3 - Solution Definition';
        oppotyList[0].PriceBook2Id         = priceBookList[0].id;
        oppotyList[0].Quarterly_Renewal__c = string.valueof(2);
        oppotyList[0].Sub_End_Date__c      = System.Today().addMonths(1)-3;
        oppotyList[0].type                 = 'New Business';
        oppotyList[0].Deal_Type__c         = 'Standard';
        insert oppotyList;
        
        //*********** Create County Record for displaying Marketo Entity on quote
        Country__c country=new Country__c();
        country.Country_Registered_Office_Address__c='Marketo, Inc., 901 Mariners Island Blvd Suite 200, San Mateo, CA, 94404, United States';
        insert country;
        system.assertNotEquals(null,country);
        //*********** Create Quote ***********
        List<SBQQ__Quote__c> quotList = TestCPQUtilityClass.createQuotes(oppotyList, 1);
        system.debug('##########quotList'+quotList);
        //System.assertEquals(1,quotList.size());
        List<SBQQ__Quote__c> InsertquotList = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote : quotList){
            quote.SBQQ__Primary__c = true;
            //quote.SBQQ__Status__c='Draft';
            //quote.SBQQ__Opportunity2__c=oppotyList[0].id;
            quote.SBQQ__StartDate__c = System.Today();
            quote.Rubiks_Quote__c=true;
            quote.MDQ_Quote__c=true;
            quote.Payment_Frequency__c='Quarterly';
            quote.Include_Billing_Schedule__c=true;
            quote.SBQQ__SubscriptionTerm__c=2; 
            //quote.Country__c=country.id;
            quote.SBQQ__ShippingCountry__c='USA';
            quote.CurrencyIsoCode='USD';
            InsertquotList.add(quote);
        }
        insert InsertquotList;
        system.debug('############### InsertquotList'+InsertquotList);
        //system.assertEquals(1, InsertquotList.size());
        List<Product2> prodListParent = new List<Product2>();
        prodListParent.add(prodList.get(0));
        
         //********* Inserting Bundle Line ***********
        List<SBQQ__QuoteLine__c> quoteLinesToInsertParent = new List<SBQQ__QuoteLine__c>();
        SBQQ__QuoteLine__c quoteLineParent = new SBQQ__QuoteLine__c( SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[0].id);
        quoteLinesToInsertParent.add(quoteLineParent);
        insert quoteLinesToInsertParent;
        system.debug('############### quoteLinesToInsertParent'+quoteLinesToInsertParent);
        Test.StartTest();
        //******** Inserting Quote Lines under the Bundle *********
        List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
        Date secoundSegmentStartdate=InsertquotList.get(0).SBQQ__StartDate__c.addMonths(3);
        
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=InsertquotList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=InsertquotList.get(0).SBQQ__StartDate__c.addMonths(3),SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=10,SBQQ__NetPrice__c=50000,MKTO_Effective_End_Date__c=system.today().addMonths(10),Product_Type__c='Subscription');
        
        SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__EndDate__c=InsertquotList.get(0).SBQQ__StartDate__c.addMonths(3),SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=10,SBQQ__NetPrice__c=40000,MKTO_Effective_End_Date__c=system.today().addMonths(10),Product_Type__c='Subscription');
        
        SBQQ__QuoteLine__c quoteLine3 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=secoundSegmentStartdate.adddays(1),SBQQ__EndDate__c=InsertquotList.get(0).Calc_End_Date__c,SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=7,SBQQ__NetPrice__c=60000,MKTO_Effective_End_Date__c=system.today().addMonths(7),Product_Type__c='Subscription');
       
        SBQQ__QuoteLine__c quoteLine4 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[2].id,SBQQ__RegularPrice__c = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=secoundSegmentStartdate.adddays(1),SBQQ__EndDate__c=InsertquotList.get(0).Calc_End_Date__c,SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=7,SBQQ__NetPrice__c=80000,MKTO_Effective_End_Date__c=system.today().addMonths(7),Product_Type__c='Subscription');
       
        quoteLinesToInsert.add(quoteLine);
        quoteLinesToInsert.add(quoteLine2);
        quoteLinesToInsert.add(quoteLine3);
        quoteLinesToInsert.add(quoteLine4);
        insert quoteLinesToInsert;
       system.debug('############### quoteLinesToInsert'+quoteLinesToInsert);
       system.assertequals(4,quoteLinesToInsert.size());

        //Id idVariable=InsertquotList[0].id;
        SBQQ__Quote__c quoteDetails=[SELECT id,Name from SBQQ__Quote__c where id=:InsertquotList[0].id];
        
    
        //system.debug('idVariable ##############'+idVariable);
        //system.assertEquals('aAp3B0000004HcB',quoteDetails.id);
        PageReference p=Page.SBQQ__PreviewDocument;
        Test.setCurrentPageReference(p); 
        System.currentPageReference().getParameters().put('qid', quoteDetails.id);
        
        billingScheduleVFComponentController controller = new billingScheduleVFComponentController() ;
        
        Test.stopTest();
        
        
    }

      
}