@isTest

public class showMDQClosedWonOpptyProdContTest {
       public static Id stdPbId;
        public static List<Account> accntList = new List<Account>();
        public static List<Product2> prodList = new List<Product2>();
        public static List<PriceBook2> priceBookList = new List<PriceBook2>();
        public static List<PriceBookEntry> pbEntryStdPbList = new List<PriceBookEntry>();
        public static List<PriceBookEntry> pbEntryList = new List<PriceBookEntry>();
        
    /*
    public static testMethod void testshowMDQClosedWonOpptyProdCont(){
        List<Account> accountsToBeInsertedList = new List<Account>();
        accountsToBeInsertedList = TestCPQUtilityClass.createAccounts(1);
  
        insert accountsToBeInsertedList;
    
        List<Product2> productToInsertList = new List<Product2>();
        productToInsertList = TestCPQUtilityClass.createCustomProducts(3);
        productToInsertList[0].ProductCode='PROD-APPS-AUTOWKFL';
        productToInsertList[1].ProductCode = 'PROD-PLAT-SANDBOX';
        productToInsertList[2].ProductCode = 'PROD-PLAT-SANDBOX-INST';
      
        if(!productToInsertList.isEmpty()){
            
             productToInsertList[0].Family ='Product';
            productToInsertList[1].Family ='Product';
            productToInsertList[2].Family ='Lead Management';
             productToInsertList[0].name='Automation and Workflow';
            productToInsertList[1].name='Sandbox';
            productToInsertList[2].name='Sandbox Instance';
            insert productToInsertList;
        } 
 
  
    // Create Custom Pricebooks
        List<PriceBook2> priceBookList = new List<PriceBook2>();
        priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }
        
        // Insert data for custom setting - SteelBrickCPQPricebook__c
        SteelBrickCPQPricebook__c obj = new SteelBrickCPQPricebook__c();
        obj.Name = 'SteelBrick PB';
        obj.ID__c = priceBookList[0].Id;
        //insert obj;
   
     // Get Id of Standard Pricebook
        Id stdPbId = Test.getStandardPricebookId();
     
        
     // Insert Products into Standard Pricebook
        List<PriceBookEntry> pbEntryStdPbList = new List<PriceBookEntry>();
        for(Integer i=0; i<productToInsertList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = productToInsertList[i].Id,UnitPrice = 10000, IsActive = true);
            system.debug('stdPbId Inside PBE'+stdPbId);
            pbEntryStdPbList.add(pbe);
        }
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        
        }
      
   
     List<PriceBookEntry> pbEntryCustPbList = new List<PriceBookEntry>();
        for(Integer i=0; i<productToInsertList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = priceBookList[0].id, Product2Id = productToInsertList[i].Id,UnitPrice = 10000, IsActive = true);
      
            pbEntryCustPbList.add(pbe);
        }
        if(!pbEntryCustPbList.isEmpty()){
            insert pbEntryCustPbList;
        }
        
       list<User> u=[select id, email from User where id='00550000003PDSe'];
   
       List<Opportunity> OpptyToBeInsertedList = new List<Opportunity>();
        OpptyToBeInsertedList = TestCPQUtilityClass.createOpportunities(accountsToBeInsertedList,1);
        OpptyToBeInsertedList[0].StageName            = '3 - Solution Definition';
        OpptyToBeInsertedList[0].PriceBook2Id         = priceBookList[0].id;
        OpptyToBeInsertedList[0].Quarterly_Renewal__c = string.valueof(2);
        OpptyToBeInsertedList[0].type                 = 'New Business';
        OpptyToBeInsertedList[0].Deal_Type__c         = 'Standard';
        OpptyToBeInsertedList[0].CAM_Owner_Email__c ='rajesh.wani@jadeglobal.com';
        OpptyToBeInsertedList[0].Actual_Close_Date__c=system.today();
        OpptyToBeInsertedList[0].owner=u[0];
  
          insert OpptyToBeInsertedList ;
          system.debug('OpptyToBeInsertedList '+OpptyToBeInsertedList ); 

      
   
  
 
        List<SBQQ__Quote__c> quotesToBeInsertedList= new List<SBQQ__Quote__c>();
        quotesToBeInsertedList = TestCPQUtilityClass.createQuotes(OpptyToBeInsertedList,1);
  
        for(SBQQ__Quote__c quote : quotesToBeInsertedList){
              quote.SBQQ__Primary__c = true;
              quote.SBQQ__SubscriptionTerm__c=12;
              quote.Rubiks_Quote__c=true;
              quote.SBQQ__Opportunity2__c=OpptyToBeInsertedList[0].id;
              quote.SBQQ__StartDate__c=system.today();
              quote.SBQQ__PriceBook__c=priceBookList[0].id;
              quote.MDQ_Quote__c=true;
              
          }
        insert quotesToBeInsertedList;
        system.debug('quotesToBeInsertedList'+quotesToBeInsertedList);
       
        List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
     
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6),SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=6,SBQQ__SegmentKey__c='1475100700835');
        
        
         SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c( SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6).addDays(1),SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__EndDate__c,SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=6,SBQQ__SegmentKey__c='1475100700836'); 
         
         SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6),SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=6,SBQQ__SegmentKey__c='1475100700837');
         
         SBQQ__QuoteLine__c quoteLine3 = new SBQQ__QuoteLine__c( SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6).addDays(1),SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__EndDate__c,SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=6,SBQQ__SegmentKey__c='1475100700838');
         
         SBQQ__QuoteLine__c quoteLine4 = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[0].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6),SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=6,SBQQ__SegmentKey__c='1475100700839');
         
          SBQQ__QuoteLine__c quoteLine5 = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[0].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6).addDays(1),SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__EndDate__c,SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=6,SBQQ__SegmentKey__c='1475100700830');
          
       
        quoteLinesToInsert.add(quoteLine);
        quoteLinesToInsert.add(quoteLine1);
        quoteLinesToInsert.add(quoteLine2);
        quoteLinesToInsert.add(quoteLine3);
        quoteLinesToInsert.add(quoteLine4);
         quoteLinesToInsert.add(quoteLine5);
          Test.StartTest();
         insert quoteLinesToInsert;
        Test.StopTest();
         
         system.debug('quoteLinesToInsert#######'+quoteLinesToInsert);

                   
           List<OpportunityLineItem> OLIListToBeInserted=new List<OpportunityLineItem>();       
       
          
           OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[1].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[0].Id,Segment_Start_Date__c=quoteLinesToInsert[0].SBQQ__StartDate__c,Users__c=1,ServiceDate=quoteLinesToInsert[0].SBQQ__StartDate__c);           
               
            OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[1].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[1].Id,Segment_Start_Date__c=quoteLinesToInsert[1].SBQQ__StartDate__c,Users__c=1,ServiceDate=quoteLinesToInsert[1].SBQQ__StartDate__c);
            
             OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[2].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[2].Id,Segment_Start_Date__c=quoteLinesToInsert[2].SBQQ__StartDate__c,Users__c=1,ServiceDate=quoteLinesToInsert[2].SBQQ__StartDate__c);
             
             OpportunityLineItem oli4 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[2].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[3].Id,Segment_Start_Date__c=quoteLinesToInsert[3].SBQQ__StartDate__c,Users__c=1,ServiceDate=quoteLinesToInsert[3].SBQQ__StartDate__c);
              
             OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[0].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[4].Id,Segment_Start_Date__c=quoteLinesToInsert[4].SBQQ__StartDate__c,Users__c=1,ServiceDate=quoteLinesToInsert[4].SBQQ__StartDate__c);
             
              OpportunityLineItem oli5 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[0].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[5].Id,Segment_Start_Date__c=quoteLinesToInsert[5].SBQQ__StartDate__c,Users__c=1,ServiceDate=quoteLinesToInsert[5].SBQQ__StartDate__c);
            
         
            OLIListToBeInserted.add(oli1);
            OLIListToBeInserted.add(oli2);
            OLIListToBeInserted.add(oli3);
            OLIListToBeInserted.add(oli4);
            OLIListToBeInserted.add(oli);
            OLIListToBeInserted.add(oli5);
            if(!OLIListToBeInserted.isEmpty()){
            insert OLIListToBeInserted;
            }
            update OLIListToBeInserted;
               
        
          
          OpptyToBeInsertedList[0].StageName            = 'Closed Won';
          OpptyToBeInsertedList[0].SBQQ__Contracted__c=true;
          OpptyToBeInsertedList[0].SBQQ__PrimaryQuote__c=quotesToBeInsertedList[0].id;
          OpptyToBeInsertedList[0].Actual_Close_Date__c=system.today();
          
          update OpptyToBeInsertedList;
          
          
         showMDQClosedWonOpptyProductsController sc=new showMDQClosedWonOpptyProductsController();
         sc.opportunityId=OpptyToBeInsertedList[0].Id;

    }
    */
    public static testMethod void testshowMDQClosedWonOpprtunity(){
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
        
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=InsertquotList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=InsertquotList.get(0).SBQQ__StartDate__c.addMonths(3),SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=10,SBQQ__NetPrice__c=50000,MKTO_Effective_End_Date__c=system.today().addMonths(10),Product_Type__c='Subscription',SBQQ__SegmentKey__c='12345678');
        
        SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__EndDate__c=InsertquotList.get(0).SBQQ__StartDate__c.addMonths(3),SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=10,SBQQ__NetPrice__c=40000,MKTO_Effective_End_Date__c=system.today().addMonths(10),Product_Type__c='Subscription',SBQQ__SegmentKey__c='123456789');
        
        SBQQ__QuoteLine__c quoteLine3 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=secoundSegmentStartdate.adddays(1),SBQQ__EndDate__c=InsertquotList.get(0).Calc_End_Date__c,SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=7,SBQQ__NetPrice__c=60000,MKTO_Effective_End_Date__c=system.today().addMonths(7),Product_Type__c='Subscription',SBQQ__SegmentKey__c='123456745');
       
        SBQQ__QuoteLine__c quoteLine4 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[2].id,SBQQ__RegularPrice__c = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=secoundSegmentStartdate.adddays(1),SBQQ__EndDate__c=InsertquotList.get(0).Calc_End_Date__c,SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=7,SBQQ__NetPrice__c=80000,MKTO_Effective_End_Date__c=system.today().addMonths(7),Product_Type__c='Subscription',SBQQ__SegmentKey__c='123456699');
       
        quoteLinesToInsert.add(quoteLine);
        quoteLinesToInsert.add(quoteLine2);
        quoteLinesToInsert.add(quoteLine3);
        quoteLinesToInsert.add(quoteLine4);
        insert quoteLinesToInsert;
      
        List<OpportunityLineItem> OLIListToBeInserted=new List<OpportunityLineItem>();   
        
        OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = oppotyList[0].Id, PricebookEntryId = pbEntryList [1].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[0].Id,Segment_Start_Date__c=quoteLinesToInsert[0].SBQQ__StartDate__c,Users__c=1,ServiceDate=quoteLinesToInsert[0].SBQQ__StartDate__c);           
                   
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = oppotyList[0].Id, PricebookEntryId = pbEntryList [1].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[1].Id,Segment_Start_Date__c=quoteLinesToInsert[1].SBQQ__StartDate__c,Users__c=1,ServiceDate=quoteLinesToInsert[1].SBQQ__StartDate__c);
                
        OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId = oppotyList[0].Id, PricebookEntryId = pbEntryList [2].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[2].Id,Segment_Start_Date__c=quoteLinesToInsert[2].SBQQ__StartDate__c,Users__c=1,ServiceDate=quoteLinesToInsert[2].SBQQ__StartDate__c);
                 
        OpportunityLineItem oli4 = new OpportunityLineItem(OpportunityId = oppotyList[0].Id, PricebookEntryId = pbEntryList [2].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[3].Id,Segment_Start_Date__c=quoteLinesToInsert[3].SBQQ__StartDate__c,Users__c=1,ServiceDate=quoteLinesToInsert[3].SBQQ__StartDate__c);
                    
        OLIListToBeInserted.add(oli1);
        OLIListToBeInserted.add(oli2);
        OLIListToBeInserted.add(oli3);
        OLIListToBeInserted.add(oli4);
        
        insert OLIListToBeInserted;
        
        showMDQClosedWonOpptyProductsController sc=new showMDQClosedWonOpptyProductsController();
        sc.setopportunityId(oppotyList[0].Id);
        sc.opportunityId=oppotyList[0].Id;
        id oppid = sc.getopportunityId();
        
    }
   

}