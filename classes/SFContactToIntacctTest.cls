@isTest
Public class SFContactToIntacctTest {
    @isTest static void SFContactToIntacct() {
    
     Test.setMock(HttpCalloutMock.class, new SFContactToIntacctMockTest());
         List<Account> accntList = new List<Account>();
         accntList = TestCPQUtilityClass.createAccounts(1);
         accntList[0].Name='Jade Test Account';
         if(!accntList.isEmpty()){
             insert accntList;
         }
         
         system.assertequals(accntList.size(),1);
         List<Contact> contactList = new List<Contact>();
         contactList = TestCPQUtilityClass.createContacts(accntList,1);
         contactList[0].FirstName='Snehal';
         contactList[0].LastName='Khot';
         contactList[0].MailingCity='Pune';
         contactList[0].MailingState='Maharashtra';
         contactList[0].MailingCountry='Canada';
         contactList[0].MailingPostalCode='411014';
         contactList[0].MailingStreet='Nagar Road';
         contactList[0].Phone='(999) 999-9999';
         contactList[0].Email='skhot@marketo.com';
        
         if(!contactList.isEmpty()){
            insert contactList;
         }
         
          //********* Products Insertion ************
        list<Product2> prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].ProductCode ='PARENT';// 'BNDL-ENT-MKTGAUTO';

        prodList[1].ProductCode = 'PROD-APPS-INST';
        prodList[2].ProductCode = 'PROD-PLAT-SANDBOX-INST';

        for(Product2 pd: prodList){
            pd.Product_Type__c         ='Subscription';
            pd.Family                  ='Services';
            pd.Product_SubFamily__c    = 'Launch Pack';
            pd.Product_SubFamily2__c   = 'Launch Pack Core';
        }//End of FOR

        if(!prodList.isEmpty()){
            prodList[0].Family ='Bundle';
            insert prodList;
        }//End of IF
        
        //*************** Inserting Pricebook ********************
        list<priceBook2> priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }//End of IF
        
       
        // Get Id of Standard Pricebook
        id stdPbId = Test.getStandardPricebookId();
         list<PriceBookEntry> pbEntryStdPbList = new list<PriceBookEntry>();
        //************** Insert Products into Standard Pricebook *******************
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }//End Of FOR
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }//End of IF
        
        //************ Insert Products into Custom Pricebooks ***************
        list<PriceBookEntry> pbEntryList = TestCPQUtilityClass.createPriceBookEntries(prodList, priceBookList);
        if(!pbEntryList.isEmpty()){
            insert pbEntryList;
        }//End of IF
        
        //Enter Data in custom setting
        SteelBrickCPQPricebook__c SBPriceBook= new SteelBrickCPQPricebook__c();
        SBPriceBook.Name = 'SteelBrick PB';
        SBPriceBook.Case_Safe_ID__c=priceBookList[0].id;
        SBPriceBook.ID__c=priceBookList[0].id;
        if(SBPriceBook!=null){
            insert SBPriceBook;
        }

        
        List<Id> OppId = new List<Id>();
        List<Opportunity> NewoppotyList    = TestCPQUtilityClass.createOpportunities(accntList, 1);
        NewoppotyList[0].PriceBook2Id         = SteelBrickCPQPricebook__c.getOrgDefaults().ID__c;
        NewoppotyList[0].Quarterly_Renewal__c = string.valueof(2);
        NewoppotyList[0].Sub_End_Date__c      = System.Today().addMonths(1);
        NewoppotyList[0].type                 = 'New Business';
        NewoppotyList[0].Deal_Type__c         = 'Standard';
        NewoppotyList[0].Rep_Create_ARR__c    =1;
        NewoppotyList[0].Needs_Pains__c       ='Test Pain';
        NewoppotyList[0].MainCompetitor__c='Act-On';
        NewoppotyList[0].Use_Case__c='B2B';
        NewoppotyList[0].Subscription_Language__c ='English';
        NewoppotyList[0].Subscription_Locale__c='English-United States';
        NewoppotyList[0].Subscription_Time_Zone__c='Pacific Time (America/Los_Angeles)';
        insert NewoppotyList;
        OppId.add(NewoppotyList[0].Id);
        
        List<OpportunityLineItem> oppotyLineItemList = new List<OpportunityLineItem>();
        oppotyLineItemList = TestCPQUtilityClass.createOppLineItems(NewoppotyList,pbEntryList);
     
        insert oppotyLineItemList;
        
        List<SBQQ__Quote__c> newquoteList = TestCPQUtilityClass.createQuotes(NewoppotyList,  1);
        for(SBQQ__Quote__c q: newquoteList){
            q.SBQQ__Primary__c=true;
            q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
            q.SBQQ__StartDate__c =system.today()+40;
            q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
            q.SBQQ__SubscriptionTerm__c=12;
            q.SBQQ__PrimaryContact__c=contactList[0].id;
            q.Bill_To_Contact__c=contactList[0].id;
            q.Ship_To_Contact__c=contactList[0].id;
            q.SBQQ__ShippingCountry__c='Canada';
            q.SBQQ__Opportunity2__c=NewoppotyList[0].Id;
            q.Acct_Prefix_Requested__c='Test';
        }
        insert newquoteList;
   
        
        NewoppotyList[0].StageName            = 'Signed Order';
        NewoppotyList[0].Stage_Signed_Order_Date__c = system.today();
        update NewoppotyList;  
        
     
        
         system.debug('Pricebookid*******'+SteelBrickCPQPricebook__c.getOrgDefaults().ID__c);
         NewoppotyList[0].StageName            = 'Closed Won';
         update NewoppotyList;
        system.debug('NewoppotyList[0].StageName  #########'+NewoppotyList[0].StageName);
        Test.StartTest();
       
        // Create a fake response
        HTTPResponse hTTPRes=new HTTPResponse ();
        SFContactToIntacct.sendContactDetailsToIntacct(OppId);
        SFContactToIntacct.UpdateContactToIntacct(contactList[0].id);
        
        //system.debug('res@@@'+res);
        
                
       Test.StopTest();    
        
     }
     
      @isTest static void SFContactToIntacctError() {
    
     Test.setMock(HttpCalloutMock.class, new SFContactToIntacctErrorMockTest());
         List<Account> accntList = new List<Account>();
         Set<Id> OppSet=new Set<Id>();
         accntList = TestCPQUtilityClass.createAccounts(1);
         accntList[0].Name='Jade Test Account';
         if(!accntList.isEmpty()){
             insert accntList;
         }
         
         system.assertequals(accntList.size(),1);
         List<Contact> contactList = new List<Contact>();
         contactList = TestCPQUtilityClass.createContacts(accntList,1);
         contactList[0].FirstName='Snehal';
         contactList[0].LastName='Khot';
         contactList[0].MailingCity='Pune';
         contactList[0].MailingState='Maharashtra';
         contactList[0].MailingCountry='Canada';
         contactList[0].MailingPostalCode='411014';
         contactList[0].MailingStreet='Nagar Road';
         contactList[0].Phone='(999) 999-9999';
         contactList[0].Email='skhot@marketo.com';
       //  contactList[0].Contact_Synced_to_Intacct__c = true;
         if(!contactList.isEmpty()){
            insert contactList;
         }
         
          //********* Products Insertion ************
        list<Product2> prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].ProductCode ='PARENT';// 'BNDL-ENT-MKTGAUTO';

        prodList[1].ProductCode = 'PROD-APPS-INST';
        prodList[2].ProductCode = 'PROD-PLAT-SANDBOX-INST';

        for(Product2 pd: prodList){
            pd.Product_Type__c         ='Subscription';
            pd.Family                  ='Services';
            pd.Product_SubFamily__c    = 'Launch Pack';
            pd.Product_SubFamily2__c   = 'Launch Pack Core';
        }//End of FOR

        if(!prodList.isEmpty()){
            prodList[0].Family ='Bundle';
            insert prodList;
        }//End of IF
        
        //*************** Inserting Pricebook ********************
        list<priceBook2> priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }//End of IF
        
       
        // Get Id of Standard Pricebook
        id stdPbId = Test.getStandardPricebookId();
         list<PriceBookEntry> pbEntryStdPbList = new list<PriceBookEntry>();
        //************** Insert Products into Standard Pricebook *******************
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }//End Of FOR
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }//End of IF
        
        //************ Insert Products into Custom Pricebooks ***************
        list<PriceBookEntry> pbEntryList = TestCPQUtilityClass.createPriceBookEntries(prodList, priceBookList);
        if(!pbEntryList.isEmpty()){
            insert pbEntryList;
        }//End of IF
        
        //Enter Data in custom setting
        SteelBrickCPQPricebook__c SBPriceBook= new SteelBrickCPQPricebook__c();
        SBPriceBook.Name = 'SteelBrick PB';
        SBPriceBook.Case_Safe_ID__c=priceBookList[0].id;
        SBPriceBook.ID__c=priceBookList[0].id;
        if(SBPriceBook!=null){
            insert SBPriceBook;
        }

        
        List<Id> OppId = new List<Id>();
        List<Opportunity> NewoppotyList    = TestCPQUtilityClass.createOpportunities(accntList, 1);
        NewoppotyList[0].PriceBook2Id         = SteelBrickCPQPricebook__c.getOrgDefaults().ID__c;
        NewoppotyList[0].Quarterly_Renewal__c = string.valueof(2);
        NewoppotyList[0].Sub_End_Date__c      = System.Today().addMonths(1);
        NewoppotyList[0].type                 = 'New Business';
        NewoppotyList[0].Deal_Type__c         = 'Standard';
        NewoppotyList[0].Rep_Create_ARR__c    =1;
        NewoppotyList[0].Needs_Pains__c       ='Test Pain';
        NewoppotyList[0].MainCompetitor__c='Act-On';
        NewoppotyList[0].Use_Case__c='B2B';
        NewoppotyList[0].Subscription_Language__c ='English';
        NewoppotyList[0].Subscription_Locale__c='English-United States';
        NewoppotyList[0].Subscription_Time_Zone__c='Pacific Time (America/Los_Angeles)';
        insert NewoppotyList;
        OppId.add(NewoppotyList[0].Id);
        OppSet.add(NewoppotyList[0].Id);
        
        List<OpportunityLineItem> oppotyLineItemList = new List<OpportunityLineItem>();
        oppotyLineItemList = TestCPQUtilityClass.createOppLineItems(NewoppotyList,pbEntryList);
     
        insert oppotyLineItemList;
        
        List<SBQQ__Quote__c> newquoteList = TestCPQUtilityClass.createQuotes(NewoppotyList,  1);
        for(SBQQ__Quote__c q: newquoteList){
            q.SBQQ__Primary__c=true;
            q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
            q.SBQQ__StartDate__c =system.today()+40;
            q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
            q.SBQQ__SubscriptionTerm__c=12;
            q.SBQQ__PrimaryContact__c=contactList[0].id;
            q.Bill_To_Contact__c=contactList[0].id;
            q.Ship_To_Contact__c=contactList[0].id;
            q.SBQQ__Opportunity2__c=NewoppotyList[0].Id;
            q.SBQQ__ShippingCountry__c='Canada';
			q.Acct_Prefix_Requested__c='Test';
        }
        insert newquoteList;

        NewoppotyList[0].StageName            = 'Signed Order';
        NewoppotyList[0].Stage_Signed_Order_Date__c = system.today();
        update NewoppotyList;  
        
     
        
         system.debug('Pricebookid*******'+SteelBrickCPQPricebook__c.getOrgDefaults().ID__c);
         NewoppotyList[0].StageName            = 'Closed Won';
         update NewoppotyList;
        system.debug('NewoppotyList[0].StageName  #########'+NewoppotyList[0].StageName);
        Test.StartTest();
       
        // Create a fake response
        HTTPResponse hTTPRes=new HTTPResponse ();
        SFContactToIntacct.sendContactDetailsToIntacct(OppId);
        SFContactToIntacct.UpdateContactToIntacct(contactList[0].id);
        SFContactToIntacct.UpdateOppWithErrorMsg(OppSet);
        
        //system.debug('res@@@'+res);
        system.debug('***************Accounttt******************');
        
       
               
       Test.StopTest();    
        
     } 
     
      @isTest static void SFContactToIntacct2() {
    
     Test.setMock(HttpCalloutMock.class, new SFContactToIntacctMockTest());
          
           Set<Id> OppSet=new Set<Id>();
         List<Account> accntList = new List<Account>();
         accntList = TestCPQUtilityClass.createAccounts(2);
         accntList[0].Name='Jade Test Account';
         accntList[1].Name='Jade Test Account2';
         if(!accntList.isEmpty()){
             insert accntList;
         }
         
        // system.assertequals(accntList.size(),1);
         List<Contact> contactList = new List<Contact>();
         contactList = TestCPQUtilityClass.createContacts(accntList,2);
         
         Integer j=1;
        for(Contact con: contactList){
            con.FirstName='Test'+j;
            con.AccountId = accntList[0].Id;
            con.LastName='Khot'+j;
            con.MailingCity='Pune';
            con.MailingState='Maharashtra';
            con.MailingCountry='Canada';
            con.MailingPostalCode='411014';
            con.MailingStreet='Nagar Road';
            con.Phone='(999) 999-9999';
            con.Email='h@marketo.com';
            con.pse__Salesforce_User__c =null;
            j++;
        }
        
        if(!contactList.isEmpty()){
                    insert contactList[0];
                   // contactList[1].pse__Salesforce_User__c =null;
                    insert contactList[1];
                 }
                 
          //********* Products Insertion ************
        list<Product2> prodList = TestCPQUtilityClass.createCustomProducts(5);
        prodList[0].ProductCode ='PARENT';// 'BNDL-ENT-MKTGAUTO';

        prodList[1].ProductCode = 'PROD-APPS-INST';
        prodList[2].ProductCode = 'PROD-PLAT-SANDBOX-INST';

        for(Product2 pd: prodList){
            pd.Product_Type__c         ='Subscription';
            pd.Family                  ='Services';
            pd.Product_SubFamily__c    = 'Launch Pack';
            pd.Product_SubFamily2__c   = 'Launch Pack Core';
        }//End of FOR

        if(!prodList.isEmpty()){
            prodList[0].Family ='Bundle';
            insert prodList;
        }//End of IF
        
        //*************** Inserting Pricebook ********************
        list<priceBook2> priceBookList = TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBookList.isEmpty()){
            insert priceBookList;
        }//End of IF
        
       
        // Get Id of Standard Pricebook
        id stdPbId = Test.getStandardPricebookId();
         list<PriceBookEntry> pbEntryStdPbList = new list<PriceBookEntry>();
        //************** Insert Products into Standard Pricebook *******************
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbe = new PricebookEntry(Pricebook2Id = stdPbId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbEntryStdPbList.add(pbe);
        }//End Of FOR
        if(!pbEntryStdPbList.isEmpty()){
            insert pbEntryStdPbList;
        }//End of IF
        
        //************ Insert Products into Custom Pricebooks ***************
        list<PriceBookEntry> pbEntryList = TestCPQUtilityClass.createPriceBookEntries(prodList, priceBookList);
        if(!pbEntryList.isEmpty()){
            insert pbEntryList;
        }//End of IF
        
        //Enter Data in custom setting
        SteelBrickCPQPricebook__c SBPriceBook= new SteelBrickCPQPricebook__c();
        SBPriceBook.Name = 'SteelBrick PB';
        SBPriceBook.Case_Safe_ID__c=priceBookList[0].id;
        SBPriceBook.ID__c=priceBookList[0].id;
        if(SBPriceBook!=null){
            insert SBPriceBook;
        }
        system.debug('*****************Check**************');
        
        List<Id> OppId = new List<Id>();
        List<Opportunity> NewoppotyList    = TestCPQUtilityClass.createOpportunities(accntList, 1);
        NewoppotyList[0].PriceBook2Id         = SteelBrickCPQPricebook__c.getOrgDefaults().ID__c;
        NewoppotyList[0].AccountId            = accntList[0].Id;
        NewoppotyList[0].Quarterly_Renewal__c = string.valueof(2);
        NewoppotyList[0].Sub_End_Date__c      = System.Today().addMonths(1);
        NewoppotyList[0].type                 = 'New Business';
        NewoppotyList[0].Deal_Type__c         = 'Standard';
        NewoppotyList[0].Rep_Create_ARR__c    =1;
        NewoppotyList[0].Needs_Pains__c       ='Test Pain';
        NewoppotyList[0].MainCompetitor__c='Act-On';
        NewoppotyList[0].Use_Case__c='B2B';
        NewoppotyList[0].Subscription_Language__c ='English';
        NewoppotyList[0].Subscription_Locale__c='English-United States';
        NewoppotyList[0].Subscription_Time_Zone__c='Pacific Time (America/Los_Angeles)';
        insert NewoppotyList[0];
        OppId.add(NewoppotyList[0].Id);
          OppSet.add(NewoppotyList[0].Id);
        
        List<Opportunity> NewOppList = [select Id,AccountId from Opportunity where Type='New Business'];
        system.assertEquals(1,NewOppList.size());

        
        List<OpportunityLineItem> oppotyLineItemList = new List<OpportunityLineItem>();
        oppotyLineItemList = TestCPQUtilityClass.createOppLineItems(NewOppList,pbEntryList);
     
        insert oppotyLineItemList;
        
                
        List<SBQQ__Quote__c> newquoteList = TestCPQUtilityClass.createQuotes(NewOppList ,  1);
        for(SBQQ__Quote__c q: newquoteList){
            q.SBQQ__Primary__c=true;
            q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
            q.SBQQ__StartDate__c =system.today()+40;
            q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
            q.SBQQ__SubscriptionTerm__c=12;
            q.SBQQ__PrimaryContact__c=contactList[0].id;
            q.Bill_To_Contact__c=contactList[0].id;
            q.Ship_To_Contact__c=contactList[1].id;
            q.SBQQ__ShippingCountry__c='Canada';
            q.SBQQ__Opportunity2__c=NewoppotyList[0].Id;
            q.Acct_Prefix_Requested__c='Test';
        }
        insert newquoteList;
        
       contactList[0].Contact_Synced_to_Intacct__c = True;
       update contactList[0];
       
        NewoppotyList[0].StageName            = 'Signed Order';
        NewoppotyList[0].Stage_Signed_Order_Date__c = system.today();
        update NewoppotyList[0];  
        
     
        
         system.debug('Pricebookid*******'+SteelBrickCPQPricebook__c.getOrgDefaults().ID__c);
         NewoppotyList[0].StageName            = 'Closed Won';
          
           
         update NewoppotyList[0];
         
       // system.assertEquals(contactList[0].id, NewoppotyList[0].Intacct_Bill_to_Contact__c);
        system.assertEquals('Closed Won', NewoppotyList[0].StageName);
        system.debug('NewoppotyList[0].StageName  #########'+NewoppotyList[0].StageName);
       
       Test.StartTest();
        // Create a fake response
    HTTPResponse hTTPRes=new HTTPResponse ();
       
        SFContactToIntacct.sendContactDetailsToIntacct(OppId);
        SFContactToIntacct.UpdateContactToIntacct(contactList[0].id);
      //  SFContactToIntacct.UpdateOppWithErrorMsg(OppSet); 
        //system.debug('res@@@'+res);
        
                
       Test.StopTest();    
      //  system.assertEquals(contactList[0].id, NewoppotyList[0].Intacct_Bill_to_Contact__c);
     }
               
}