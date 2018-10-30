@isTest
private class Amendment_Override_Test {
    
    @isTest static void test_method_one() {
        // Implement test code
        //Need Account
        //Oppportunity
        //Contract(s)

          List<Account> accntList = new List<Account>();
        accntList = TestCPQUtilityClass.createAccounts(2);
        if(!accntList.isEmpty()){
            insert accntList;
        }
        
        List<Contact> contactList = new List<Contact>();
        contactList = TestCPQUtilityClass.createContacts(accntList,1);
        if(!contactList.isEmpty()){
            insert contactList[0];
        }
        
        contact cc = new contact();
        cc.FirstName = 'grazitti';
        cc.LastName  = 'test';
        cc.AccountId = accntList[0].Id;
        cc.FirstNameLocal = 'TTTR';
        cc.LastNameLocal = 'DDDDAQ';
        cc.MailingStreet='901 Blvd';
        cc.MailingState='vvv';
        cc.MailingCity='Sano';
        cc.MailingCountry='AUS';
        cc.MailingPostalCode='9784404';
        insert cc;
        //MailingStreet='901 Mariners Island Blvd',MailingState='',MailingCity='San Mateo',MailingCountry='US',MailingPostalCode='94404'

         // Create Products
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(3);
        prodList[0].ProductCode ='PARENT';// 'BNDL-ENT-MKTGAUTO';

        prodList[1].ProductCode = 'PROD-APPS-INST';
        prodList[2].ProductCode = 'PROD-PLAT-SANDBOX-INST';
        //prodList[0].ProductCode='INST';
        for(Product2 pd: prodList){
            pd.Product_Type__c         ='Services';
            pd.Family                  ='Services';
            pd.Product_SubFamily__c    = 'Launch Pack';
            pd.Product_SubFamily2__c   = 'Launch Pack Core';

        }

        prodList[0].Family ='Bundle';
        
        if(!prodList.isEmpty()){
            insert prodList;
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
        insert obj;
        
        // Get Id of Standard Pricebook
        Id stdPbId = Test.getStandardPricebookId();
        
        // Insert Products into Standard Pricebook
        List<PriceBookEntry> pbEntryStdPbList = new List<PriceBookEntry>();
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }
        
        // Insert Products into Custom Pricebooks
        List<PriceBookEntry> pbEntryList = new List<PriceBookEntry>();
        pbEntryList = TestCPQUtilityClass.createPriceBookEntries(prodList, priceBookList);
        if(!pbEntryList.isEmpty()){
            insert pbEntryList;
        }
         
        // Create Opportunities with stage Closed Won
        List<Opportunity> oppotyList = new List<Opportunity>();
        oppotyList                         = TestCPQUtilityClass.createOpportunities(accntList, 2);
        oppotyList[0].StageName            = 'Prospecting';
        oppotyList[0].PriceBook2Id         = priceBookList[0].id;
        oppotyList[0].Quarterly_Renewal__c = string.valueof(2);
        oppotyList[0].Sub_End_Date__c      = System.Today().addMonths(1);
        oppotyList[0].type                 = 'New Business';
        oppotyList[0].Deal_Type__c         = 'Standard';
        oppotyList[0].AccountId             =accntList[0].id;
        
        
        oppotyList[1].StageName            = 'Prospecting';
        oppotyList[1].PriceBook2Id         = priceBookList[0].id;
        oppotyList[1].Quarterly_Renewal__c = string.valueof(2);
        oppotyList[1].Sub_End_Date__c      = System.Today().addMonths(1);
        oppotyList[1].type                 = 'Renewal';
        oppotyList[1].Deal_Type__c         = 'Standard';
        oppotyList[1].AccountId             =accntList[1].id;
        
        
        insert oppotyList;
        
         List<SBQQ__Quote__c> quotList = TestCPQUtilityClass.createQuotes(oppotyList,  1);
         List<SBQQ__Quote__c> InsertquotList = new List<SBQQ__Quote__c>();
          for(SBQQ__Quote__c quote : quotList){
              quote.SBQQ__Primary__c = true;
              quote.Ship_To_Contact__c = cc.Id;
              InsertquotList.add(quote);
          }
          InsertquotList[0].Rubiks_Quote__c = TRUE;
        
         // InsertquotList[1].Rubiks_Quote__c = TRUE;
         
          insert InsertquotList;

          //Create QuoteLine Parent
          List<Product2> prodListParent = new List<Product2>();
          prodListParent.add(prodList.get(0));

          system.debug(prodList.get(0));

          //List<SBQQ__QuoteLine__c> InsertquoteLineList= TestCPQUtilityClass.createQuoteLinesForQuote( InsertquotList[0],prodListParent );
          //insert InsertquoteLineList;
         
          List<SBQQ__QuoteLine__c> quoteLinesToInsertParent = new List<SBQQ__QuoteLine__c>();
          //SBQQ__RequiredBy__c=InsertquoteLineList.get(0).id,
          SBQQ__QuoteLine__c quoteLine3 = new SBQQ__QuoteLine__c( SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[0].id);
          quoteLinesToInsertParent.add(quoteLine3);
          insert quoteLinesToInsertParent;
          Test.StartTest();
          List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
          system.debug(quoteLine3.id);
          SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[1].id);
          SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[2].id);
          quoteLinesToInsert.add(quoteLine);
          quoteLinesToInsert.add(quoteLine2);
          
           List<SBQQ__QuoteLine__c> quoteLinesToInsertParent1 = new List<SBQQ__QuoteLine__c>();
          SBQQ__QuoteLine__c quoteLine4 = new SBQQ__QuoteLine__c( SBQQ__Quote__c=InsertquotList.get(1).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[0].id);
          quoteLinesToInsertParent1.add(quoteLine4);
          insert quoteLinesToInsertParent1;
          
         // List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
          system.debug(quoteLine4.id);
          SBQQ__QuoteLine__c quoteLine5 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent1.get(0).id, SBQQ__Quote__c=InsertquotList.get(1).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[1].id);
          SBQQ__QuoteLine__c quoteLine6 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent1.get(0).id, SBQQ__Quote__c=InsertquotList.get(1).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[2].id);
          
          quoteLinesToInsert.add(quoteLine5);
          quoteLinesToInsert.add(quoteLine6);
          
          insert quoteLinesToInsert;
            Test.stopTest();
          

         // Create Opportunities with stage Closed Won
        List<Opportunity> oppotyList2 = new List<Opportunity>();
        oppotyList2                         = TestCPQUtilityClass.createOpportunities(accntList, 1);
        oppotyList2[0].StageName            = 'Prospecting';
        oppotyList2[0].PriceBook2Id         = priceBookList[0].id;
        oppotyList2[0].Quarterly_Renewal__c = string.valueof(2);
        oppotyList2[0].Sub_End_Date__c      = System.Today().addMonths(1);
        oppotyList2[0].type                 = 'New Business';
        oppotyList2[0].Deal_Type__c         = 'Standard';
        insert oppotyList2;

        
        // Create Contract
        Contract contrct = new Contract(SBQQ__Quote__c=InsertquotList.get(0).id, Status='Draft',  Name='Test Contract ', AccountId=oppotyList[0].AccountId, SBQQ__Opportunity__c =oppotyList[0].Id, ContractTerm = 12, SBQQ__RenewalForecast__c = true, SBQQ__PreserveBundleStructureUponRenewals__c = true, SBQQ__DefaultRenewalContactRoles__c = true, SBQQ__DefaultRenewalPartners__c = true, StartDate=System.today());
        insert contrct;  
        contrct.Status='Activated';
        update contrct;
        
        Contract contrct1 = new Contract(SBQQ__Quote__c=InsertquotList.get(1).id, Status='Draft',  Name='Test Contract ', AccountId=oppotyList[1].AccountId, SBQQ__Opportunity__c =oppotyList[1].Id, ContractTerm = 12, SBQQ__RenewalForecast__c = true, SBQQ__PreserveBundleStructureUponRenewals__c = true, SBQQ__DefaultRenewalContactRoles__c = true, SBQQ__DefaultRenewalPartners__c = true, StartDate=System.today());
        insert contrct1;  
        contrct1.Status='Activated';
        update contrct1;
        
        oppotyList[1].SBQQ__RenewedContract__c=contrct.id;
        update oppotyList;

        
        //No Active Contracts
        PageReference p=Page.amendmentoverride;
        Test.setCurrentPage(p);
        
        PageReference p1=Page.amendmentoverride;
        Test.setCurrentPage(p1);
        
        ApexPages.StandardController sc=new ApexPages.StandardController(oppotyList2.get(0));
        cont_ext_opportunity_override over=new cont_ext_opportunity_override(sc);
        over.selectedContract=contrct.id;
        over.amendQuote();
        over.returnToOpp();
        
         ApexPages.StandardController sc1=new ApexPages.StandardController(oppotyList2.get(0));
        cont_ext_opportunity_override over1=new cont_ext_opportunity_override(sc1);
        over1.selectedContract=null;
        over1.amendQuote();
        over1.returnToOpp();


     

        //Pass Active Contract
        sc=new ApexPages.StandardController(oppotyList2.get(0));
        over=new cont_ext_opportunity_override(sc);
        over.selectedContract=contrct.id;
        //over.checkContracts();
        over.returnToOpp();


        Opportunity o=[Select SBQQ__RenewedContract__c from Opportunity where id=:oppotyList2.get(0).id];
        o.SBQQ__RenewedContract__c=contrct.id;
        update o;

        //Fail Renewed Opp
        sc=new ApexPages.StandardController(o);
        over=new cont_ext_opportunity_override(sc);
        over.selectedContract=contrct.id;
        //over.checkContracts();
        over.returnToOpp();
        
    }
    
    //public static String CRON_EXP = '0 0 0 15 3 ? 2022';

    @isTest static void test_method_two() {
          List<Account> accntList = new List<Account>();
        accntList = TestCPQUtilityClass.createAccounts(1);
        if(!accntList.isEmpty()){
            insert accntList;
        }
        
        // Create Opportunities with stage Closed Won
        List<Opportunity> oppotyList = new List<Opportunity>();
        oppotyList                         = TestCPQUtilityClass.createOpportunities(accntList, 1);
        oppotyList[0].StageName            = 'Prospecting';
        oppotyList[0].type                 = 'New Business';
        oppotyList[0].Deal_Type__c         = 'Standard';
        oppotyList[0].Name='DeleteMe'; 
        insert oppotyList;

        /*
        String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP, 
                        new schedule_Opportunity_Cleanup());
         
      // Get the information from the CronTrigger API object 
    
      CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, 
         NextFireTime
         FROM CronTrigger WHERE id = :jobId];

      // Verify the expressions are the same 
    
      System.assertEquals(CRON_EXP, 
         ct.CronExpression);

      // Verify the job has not run 
    
      System.assertEquals(0, ct.TimesTriggered);

      // Verify the next time the job will run 
    
      System.assertEquals('2022-03-15 00:00:00', 
         String.valueOf(ct.NextFireTime));
      // Verify the scheduled job hasn't run yet. 
    
*/


        
    }
    /***************************************************************
     * Testmethod: polulateOpptyFieldsFromQuoteTest
     * Added by  : Jade Global(20th May 2016)
     * Purpose   : To add code coverage Class batch_Opportunity_Cleanup 
     **************************************************************/
    public static testmethod void polulateOpptyFieldsFromQuoteTest(){
        List<Account> accountsToInsertList = new List<Account>();
        
        for(Account accnt: TestCPQUtilityClass.createAccounts(2)){
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            accountsToInsertList.add(accnt);
        }
        insert accountsToInsertList;
           
        
        //Primary_Marketo_User_Lookup__c
        // add products with product code
        List<Product2> productToInsertList = new List<Product2>();
        productToInsertList =TestCPQUtilityClass.createCustomProducts(5);
        productToInsertList[0].MA_or_RTP__c = 'MA';   
        productToInsertList[0].Visible_To_Customer__c = true;
        productToInsertList[0].Family='Support';
        productToInsertList[1].Visible_To_Customer__c = true;
        productToInsertList[1].MA_or_RTP__c ='RTP';
        productToInsertList[1].ProductCode = 'TESTClassPRODCODE' ;
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        insert productToInsertList;
        system.debug('---productToInsertList[0]---'+productToInsertList[0]);
        // insert products into standard pricebook
        Id stdPricebookId = Test.getStandardPricebookId();
        TestCPQUtilityClass.createStdPricebookEntries(productToInsertList,stdPricebookId);
        
        // Create custom pricebooks
        List<PriceBook2> pricebookList = new List<PriceBook2>();
        pricebookList =TestCPQUtilityClass.createCustomPriceBooks(5);
        insert pricebookList;
        
        // insert products into custom pricebooks
        List<PriceBookEntry> priceBookEntriesList = new List<PriceBookEntry>();
        priceBookEntriesList =TestCPQUtilityClass.createPriceBookEntries(productToInsertList,pricebookList);
        insert priceBookEntriesList;
        
        Test.startTest();
        // insert opportunities - for Closed Won Oppty - Contract will be created automatically
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities( accountsToInsertList,2);
        for(Opportunity opp : opptyList){
            opp.Amount = 2000;
            opp.Pricebook2Id = pricebookList[0].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.OwnerId=UserInfo.getUserId();
        }
        opptyList[0].name = 'DeleteMe';
        opptyList[0].type = 'New Business';
        opptyList[1].type = 'Upsell/Crossell';
        
        if(!opptyList.isEmpty()){
            insert opptyList;
        }
        
         
         // Create Primary Quote     
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opptyList[0].Id,SBQQ__Account__c= opptyList[0].accountId, SBQQ__StartDate__c = System.Today(),SBQQ__Primary__c=True);
        insert quote;

        //############ Commented for Amends Decommissioning #############
        
        //database.executeBatch(new batch_Opportunity_Cleanup());

        Test.stopTest();
        
        
    }//End of testmethod polulateOpptyFieldsFromQuoteTest()
    
        @isTest static void test_method_four() {
        
        List<Account> accntList = new List<Account>();
        accntList = TestCPQUtilityClass.createAccounts(1);
        if(!accntList.isEmpty()){
            insert accntList;
        }
        
        List<Contact> contactList = new List<Contact>();
        contactList = TestCPQUtilityClass.createContacts(accntList,1);
        if(!contactList.isEmpty()){
            insert contactList;
        }
        
         // Create Products
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(3);
        prodList[0].ProductCode ='PARENT';// 'BNDL-ENT-MKTGAUTO';

        prodList[1].ProductCode = 'PROD-APPS-INST';
        prodList[2].ProductCode = 'PROD-PLAT-SANDBOX-INST';
        //prodList[0].ProductCode='INST';
        for(Product2 pd: prodList){
            pd.Product_Type__c         ='Services';
            pd.Family                  ='Services';
            pd.Product_SubFamily__c    = 'Launch Pack';
            pd.Product_SubFamily2__c   = 'Launch Pack Core';

        }

        prodList[0].Family ='Bundle';
        
        if(!prodList.isEmpty()){
            insert prodList;
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
        insert obj;
        
        // Get Id of Standard Pricebook
        Id stdPbId = Test.getStandardPricebookId();
        
        // Insert Products into Standard Pricebook
        List<PriceBookEntry> pbEntryStdPbList = new List<PriceBookEntry>();
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }
        
        // Insert Products into Custom Pricebooks
        List<PriceBookEntry> pbEntryList = new List<PriceBookEntry>();
        pbEntryList = TestCPQUtilityClass.createPriceBookEntries(prodList, priceBookList);
        if(!pbEntryList.isEmpty()){
            insert pbEntryList;
        }
        
        List<Opportunity> oppotyList = new List<Opportunity>();
        //####### New Business ######
        oppotyList                         = TestCPQUtilityClass.createOpportunities(accntList, 1);
        oppotyList[0].StageName            = 'Prospecting';
        oppotyList[0].PriceBook2Id         = priceBookList[0].id;
        oppotyList[0].Quarterly_Renewal__c = string.valueof(2);
        oppotyList[0].Sub_End_Date__c      = System.Today().addMonths(1);
        oppotyList[0].type                 = 'New Business';
        oppotyList[0].Deal_Type__c         = 'Standard';
        
        Insert oppotyList;
        
        List<SBQQ__Quote__c> quotList = TestCPQUtilityClass.createQuotes(oppotyList,  1);
         List<SBQQ__Quote__c> InsertquotList = new List<SBQQ__Quote__c>();
          for(SBQQ__Quote__c quote : quotList){
              quote.SBQQ__Primary__c = true;
              quote.Rubiks_Quote__c = true;
              InsertquotList.add(quote);
          }
          insert InsertquotList;

        //Create QuoteLine Parent
          List<Product2> prodListParent = new List<Product2>();
          prodListParent.add(prodList.get(0));
          
         Test.startTest();
         
         List<SBQQ__QuoteLine__c> quoteLinesToInsertParent = new List<SBQQ__QuoteLine__c>();
          //SBQQ__RequiredBy__c=InsertquoteLineList.get(0).id,
          SBQQ__QuoteLine__c quoteLine3 = new SBQQ__QuoteLine__c( SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[0].id);
          quoteLinesToInsertParent.add(quoteLine3);
          insert quoteLinesToInsertParent;
          
          List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
          system.debug(quoteLine3.id);
          SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[1].id);
          SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(SBQQ__RequiredBy__c=quoteLinesToInsertParent.get(0).id, SBQQ__Quote__c=InsertquotList.get(0).Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[2].id);
          quoteLinesToInsert.add(quoteLine);
          quoteLinesToInsert.add(quoteLine2);
         
         
         insert quoteLinesToInsert;
         
         Test.StopTest();
         
         oppotyList[0].stageName = 'Signed Order';
         oppotyList[0].Use_Case__c = 'B2B';
         oppotyList[0].Needs_Pains__c = 'oppty';
         oppotyList[0].MainCompetitor__c = 'Act-On';
         oppotyList[0].Migration__c = true;
     
         update oppotyList[0];
         
         oppotyList[0].Migration__c = false;
         oppotyList[0].Probability = 1;
         oppotyList[0].Split_Opportunities__c = null;
         oppotyList[0].Ghost__c=False;
         oppotyList[0].stageName = 'Closed Won';
         oppotyList[0].pse__Primary_Project__c = null;
         update oppotyList[0];
         
         // Create Contract
        Contract contrct = new Contract(SBQQ__Quote__c=InsertquotList.get(0).id, Status='Draft',  Name='Test Contract ', AccountId=oppotyList[0].AccountId, SBQQ__Opportunity__c =oppotyList[0].Id, ContractTerm = 12, SBQQ__RenewalForecast__c = true, SBQQ__PreserveBundleStructureUponRenewals__c = true, SBQQ__DefaultRenewalContactRoles__c = true, SBQQ__DefaultRenewalPartners__c = true, StartDate=System.today());
        insert contrct;  
        contrct.Status='Activated';
        update contrct;
         
        List<Opportunity> oppotyList1 = new List<Opportunity>();
        //####### New Business ######
        oppotyList1                         = TestCPQUtilityClass.createOpportunities(accntList, 1);
        oppotyList1[0].StageName            = 'Prospecting';
        oppotyList1[0].PriceBook2Id         = priceBookList[0].id;
        oppotyList1[0].Quarterly_Renewal__c = string.valueof(2);
        oppotyList1[0].Sub_End_Date__c      = System.Today().addMonths(1);
        oppotyList1[0].type                 = 'Renewal';
        oppotyList1[0].Deal_Type__c         = 'Standard';
        oppotyList1[0].SBQQ__RenewedContract__c = contrct.id;
        
        Insert oppotyList1;
         
        PageReference p1=Page.amendmentoverride;
        Test.setCurrentPage(p1);
        
        ApexPages.StandardController sc=new ApexPages.StandardController(oppotyList1.get(0));
        cont_ext_opportunity_override over=new cont_ext_opportunity_override(sc);
        over.selectedContract=contrct.id;
        over.amendQuote();
        over.returnToOpp();
    }
    
}