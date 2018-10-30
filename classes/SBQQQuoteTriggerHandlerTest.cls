@IsTest
public class SBQQQuoteTriggerHandlerTest {
    public static List<SBQQ__Quote__c> QuotesWithoutABN_NoList;
    public static Integer numOfQuotesPerOppty;
    public static List<Account>accountsWithSBN_NoList;
    public static List<Opportunity>opportunityForAccountWithoutSBN_NoList;
    public static List<Account> accountsWithRegistered_VAT_NoList;
    public static List<Opportunity> opptyForAcctsWithoutRegistered_VAT_NoList;
    public static List<SBQQ__Quote__c> QuotesWithoutRegistered_VAT_NoList;
    
    /*public static testMethod void testQuoteTriggerHandler(){
        // Insert Accounts
        List<Account> accountsToBeInsertedList = new List<Account>();
        accountsToBeInsertedList = TestCPQUtilityClass.createAccounts(2);
        for(Account accnt :accountsToBeInsertedList){
            accnt.name = 'Marketo Inc';
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
        }
        accountsToBeInsertedList[0].ABN_No__c=null;
        accountsToBeInsertedList[1].Registered_VAT_No__c='Test';
        insert accountsToBeInsertedList;
        
        // Insert Opportunities
        List<Opportunity> OpptyToBeInsertedList = new List<Opportunity>();
        OpptyToBeInsertedList = TestCPQUtilityClass.createOpportunities(accountsToBeInsertedList,2);
        OpptyToBeInsertedList[0].type='Upsell';
        OpptyToBeInsertedList[2].type='Renewal';
        insert OpptyToBeInsertedList;
        
        // Insert records for country__c
        List<Country__c> countryListToInsert = new List<Country__c>();
        for(Integer i=0; i<10; i++){
            Country__c con = new Country__c();
            con.Name ='Australia';
            con.Region__c ='Australia';
            con.Marketo_Entity__c='Marketo, KK';
            con.VAT_GST_Total__c = 80.50;
            countryListToInsert.add(con);
        }
        countryListToInsert[1].Region__c=null;
        countryListToInsert[2].Region__c='European Union';
        insert countryListToInsert;
        
        //insert contract
        List<Contract> contractsList = new List<Contract>();
        contractsList=TestCPQUtilityClass.createContracts(accountsToBeInsertedList,2);
        for(Contract con:contractsList){
            con.By_Pass_Contract_Workflow__c = true;
        }
        insert contractsList;
        
        // Insert Quotes
        List<SBQQ__Quote__c> quotesToBeInsertedList = new List<SBQQ__Quote__c>();
        quotesToBeInsertedList = TestCPQUtilityClass.createQuotes(OpptyToBeInsertedList,2);
        quotesToBeInsertedList[0].SBQQ__ShippingCountry__c=null;               
        quotesToBeInsertedList[0].Country__c=countryListToInsert[0].id;
        quotesToBeInsertedList[0].SBQQ__Opportunity2__c=OpptyToBeInsertedList[0].Id;
        quotesToBeInsertedList[1].Country__c=countryListToInsert[1].id;
        quotesToBeInsertedList[1].SBQQ__ShippingCountry__c='Australia';        
        quotesToBeInsertedList[1].SBQQ__Opportunity2__c=OpptyToBeInsertedList[0].Id;
        quotesToBeInsertedList[1].ABN_No__c=null;
        quotesToBeInsertedList[4].ABN_No__c=null;
        quotesToBeInsertedList[4].Registered_VAT_No__C=null;
        quotesToBeInsertedList[4].SBQQ__Opportunity2__c = OpptyToBeInsertedList[2].Id; 
        quotesToBeInsertedList[4].Country__c=countryListToInsert[2].id;
        quotesToBeInsertedList[1].SBQQ__ShippingCountry__c='India';
        insert quotesToBeInsertedList;       
        
        List<SBQQ__Quote__c> quotesWithMasterContractList = new List<SBQQ__Quote__c>();
        quotesWithMasterContractList=TestCPQUtilityClass.createQuotesWithMasterContracts(OpptyToBeInsertedList,1,contractsList[0]);
        //insert quotesWithMasterContractList;

        // Insert Quote Lines
        List<SBQQ__QuoteLine__c> quoteLinesToInsertList = new List<SBQQ__QuoteLine__c>();
        quoteLinesToInsertList = TestCPQUtilityClass.createQuoteLines(quotesToBeInsertedList,1);
        Test.startTest();
        insert quoteLinesToInsertList;
        
        //Update Quote
        List<SBQQ__Quote__c> quoteToBeUpdatedList = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote :quotesToBeInsertedList){
            quote.SBQQ__ShippingCountry__c='Spain';
            quoteToBeUpdatedList.add(quote);
        }
        update quoteToBeUpdatedList;
        
        // Update Quote Lines
        List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c quoteLine : quoteLinesToInsertList){
            quoteLine.SBQQ__Quantity__c = 100.00;
            quoteLine.SBQQ__Bundle__c =TRUE;
            quoteLine.SBQQ__OptionLevel__c =0;
            quoteLinesToUpdate.add(quoteLine);
        }
        update quoteLinesToUpdate;       
        
        // test when ABN_No__C on account != null and ABN_No__C on Quote == null
        // Quote.ABN_No__C = Account.ABN_No__C
        accountsWithSBN_NoList = new List<Account>();
        for(Integer i=0;i<10;i++) {
            Account a = new Account(Name='TestAccount' + i, ShippingCountry='Australia', Sales_Region__c='Australia',ABN_No__c=' Test 1234');           
            a.BillingCountry = 'United States';
            a.BillingStreet = 'Test Street';
            a.BillingState ='Test Billing State';
            a.BillingPostalCode ='12345';
            a.ShippingCity ='Pune';           
            a.ShippingPostalCode = '12345';
            a.ShippingState = '';
            a.ShippingStreet = 'Test Shipping Street';  
            a.Accounting_Email__c = 'test@gmail.com';
            a.Accounting_Contact_First_Name__c = 'FirstName';
            a.Accounting_Contact_Last_Name__c = 'LastName';
            a.Website = 'www.google.com';
            accountsWithSBN_NoList.add(a);
        }
        insert accountsWithSBN_NoList;        
        
        opportunityForAccountWithoutSBN_NoList = new List<Opportunity>();
        for (Integer j=0;j<accountsWithSBN_NoList.size();j++){         
            opportunityForAccountWithoutSBN_NoList.add(new Opportunity(Name=accountsWithSBN_NoList[j].Name + ' Opportunity ' + j,StageName='Prospecting',CloseDate=System.today().addMonths(1),AccountId=accountsWithSBN_NoList[j].Id));
        }               
        insert opportunityForAccountWithoutSBN_NoList;
        
        QuotesWithoutABN_NoList = new List<SBQQ__Quote__c>();
        numOfQuotesPerOppty =1;
        for(Integer i=0; i<opportunityForAccountWithoutSBN_NoList.size();i++){
            for(Integer j=0; j<numOfQuotesPerOppty; j++){
                //SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft', SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia',Region__c='Australia', SBQQ__Opportunity2__c=opportunityForAccountWithoutSBN_NoList[i].Id,SBQQ__Account__c= opportunityForAccountWithoutSBN_NoList[i].accountId);
                SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft', SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opportunityForAccountWithoutSBN_NoList[i].Id,SBQQ__Account__c= opportunityForAccountWithoutSBN_NoList[i].accountId, SBQQ__StartDate__c = System.Today());
                QuotesWithoutABN_NoList.add(quote);
            }
        }
        QuotesWithoutABN_NoList[0].SBQQ__ShippingCountry__c=null;
        insert QuotesWithoutABN_NoList; 
        
        // test when Registered_VAT_No__c on account != null and Registered_VAT_No__c on Quote == null
        // Quote.Registered_VAT_No__c = Account.Registered_VAT_No__c
        accountsWithRegistered_VAT_NoList = new List<Account>();
        for(Integer i=0;i<5;i++) {
            Account a = new Account(Name='TestAccount' + i, ShippingCountry='Australia', Sales_Region__c='Australia', Registered_VAT_No__c='Test 123');
            a.BillingCountry = 'United States';
            a.BillingStreet = 'Test Street';
            a.BillingState ='Test Billing State';
            a.BillingPostalCode ='12345';
            a.ShippingCity ='Pune';           
            a.ShippingPostalCode = '12345';
            a.ShippingState = '';
            a.ShippingStreet = 'Test Shipping Street';  
            a.Accounting_Email__c = 'test@gmail.com';
            a.Accounting_Contact_First_Name__c = 'FirstName';
            a.Accounting_Contact_Last_Name__c = 'LastName';
            a.Website = 'www.google.com';
            accountsWithRegistered_VAT_NoList.add(a);
        }
        insert accountsWithRegistered_VAT_NoList;
        Test.stopTest();
        
        opptyForAcctsWithoutRegistered_VAT_NoList = new List<Opportunity>();
        for (Integer j=0;j<accountsWithRegistered_VAT_NoList.size();j++){         
            opptyForAcctsWithoutRegistered_VAT_NoList.add(new Opportunity(Name=accountsWithRegistered_VAT_NoList[j].Name + ' Opportunity ' + j,StageName='Prospecting',CloseDate=System.today().addMonths(1),AccountId=accountsWithRegistered_VAT_NoList[j].Id));
        }               
        insert opptyForAcctsWithoutRegistered_VAT_NoList;
        
        QuotesWithoutRegistered_VAT_NoList = new List<SBQQ__Quote__c>();
        numOfQuotesPerOppty =1;
        for(Integer i=0; i<opptyForAcctsWithoutRegistered_VAT_NoList.size();i++){
            for(Integer j=0; j<numOfQuotesPerOppty; j++){
                //SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft', SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia',Region__c='Australia', SBQQ__Opportunity2__c=opportunityForAccountWithoutSBN_NoList[i].Id,SBQQ__Account__c= opportunityForAccountWithoutSBN_NoList[i].accountId);
                SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft', SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opportunityForAccountWithoutSBN_NoList[i].Id,SBQQ__Account__c= opportunityForAccountWithoutSBN_NoList[i].accountId, SBQQ__StartDate__c = System.Today());
                QuotesWithoutRegistered_VAT_NoList.add(quote);
            }
        }
        insert QuotesWithoutRegistered_VAT_NoList;         
    }*/
    
    /* public static testMethod void testQuoteTriggerHandler2(){
       
        List<Account> accountsToInsertList = new List<Account>();
        accountsToInsertList = TestCPQUtilityClass.createAccounts(2);
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
            accnt.Accounting_Email__c = 'testduplicatesahdhdnggg@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'dfdfdsdfg FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'fsdfdfbbg LastName';
            accnt.Website = 'www.googledfdfgfdgtyp@google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            accnt.Name ='Support duplicate Name avoid';
            accountsToInsertList.add(accnt);
        }
        insert accountsToInsertList;
        
        list<Contact> conList = TestCPQUtilityClass.createContacts(accountsToInsertList,2);
        List<Contact> ContactList = new List<Contact>();
        
        Contact Con = new Contact();
        Con.FirstName = 'Test Name 12345 2nd';
        Con.LastName = '12Test1Contact 1896wer 2nd';
        Con.email = 'testhghhjgh@testgoogle.com';
        Con.LeadSource = 'Blog';
        //Con.SDR_Owner__c = 'Aara Zakariaei';
        Con.AccountId = accountsToInsertList[0].Id;
        Con.MailingCountry = 'India';   
        insert con;
        ContactList.add(con);
        insert ContactList;
        
        accountsToInsertList[0].Bill_To_Contact__c=ContactList[0].Id;
        accountsToInsertList[0].Ship_To_Contact__c=ContactList[0].Id;
        Update accountsToInsertList;
        
        // Insert Opportunities
        List<Opportunity> OpptyToBeInsertedList = new List<Opportunity>();
        OpptyToBeInsertedList = TestCPQUtilityClass.createOpportunities(accountsToInsertList,2);
        OpptyToBeInsertedList[0].type='Upsell';
        OpptyToBeInsertedList[2].type='Renewal';
        insert OpptyToBeInsertedList;
        
        // Insert records for country__c
        List<Country__c> countryListToInsert = new List<Country__c>();
        for(Integer i=0; i<10; i++){
            Country__c con1 = new Country__c();
            con1.Name ='Australia';
            con1.Region__c ='Australia';
            con1.Marketo_Entity__c='Marketo, KK';
            con1.VAT_GST_Total__c = 80.50;
            con1.Country_Registered_Office_Address__c = 'Australia,Marketo EMEA, Limited';
            countryListToInsert.add(con1);
        }
        Country__c conSpain = new Country__c();
            conSpain.Name ='Spain ';
            conSpain.Region__c ='European Union';
            conSpain.Marketo_Entity__c='Marketo EMEA, Limited';
            conSpain.Current_EUSA__c='https://www.marketo.com/eusa-emea-20160115';
            conSpain.Country_Registered_Office_Address__c = 'Spain,European Union,Marketo EMEA, Limited';
            countryListToInsert.add(conSpain);
            
        countryListToInsert[1].Region__c=null;
        countryListToInsert[2].Region__c='European Union';
         conSpain.Country_Registered_Office_Address__c = 'Spain,European Union,Marketo EMEA, Limited';
        insert countryListToInsert;
        
         // add products with product code
        List<Product2> productToInsertList = new List<Product2>();
        productToInsertList =TestCPQUtilityClass.createCustomProducts(5);
        productToInsertList[0].MA_or_RTP__c = 'MA';   
        productToInsertList[0].Visible_To_Customer__c = true;
        productToInsertList[0].Family='Support';
        productToInsertList[1].Visible_To_Customer__c = true;
        productToInsertList[1].MA_or_RTP__c ='RTP';
        productToInsertList[1].Family= 'SERVICES ';
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        insert productToInsertList;
        system.debug('---productToInsertList[0]---'+productToInsertList[0]);
        // insert products into standard pricebook
        Id stdPricebookId = Test.getStandardPricebookId();
        TestCPQUtilityClass.createStdPricebookEntries(productToInsertList,stdPricebookId);
        
        //insert contract
        List<Contract> contractsList = new List<Contract>();
        contractsList=TestCPQUtilityClass.createContracts(accountsToInsertList,2);
        for(Contract con2:contractsList){
            con2.By_Pass_Contract_Workflow__c = true;
        }
        insert contractsList;
         Test.startTest();
        // Insert Quotes
        List<SBQQ__Quote__c> quotesToBeInsertedList = new List<SBQQ__Quote__c>();
        quotesToBeInsertedList = TestCPQUtilityClass.createQuotes(OpptyToBeInsertedList,2);
        quotesToBeInsertedList[0].SBQQ__ShippingCountry__c=null;               
        quotesToBeInsertedList[0].Country__c=countryListToInsert[0].id;
        quotesToBeInsertedList[0].SBQQ__Opportunity2__c=OpptyToBeInsertedList[0].Id;
        quotesToBeInsertedList[1].Country__c=countryListToInsert[1].id;
        quotesToBeInsertedList[1].SBQQ__ShippingCountry__c='Australia';        
        quotesToBeInsertedList[1].SBQQ__Opportunity2__c=OpptyToBeInsertedList[0].Id;
        quotesToBeInsertedList[1].ABN_No__c=null;
        quotesToBeInsertedList[4].ABN_No__c=null;
        quotesToBeInsertedList[4].Registered_VAT_No__C=null;
        quotesToBeInsertedList[4].SBQQ__Opportunity2__c = OpptyToBeInsertedList[2].Id; 
        quotesToBeInsertedList[4].Country__c=countryListToInsert[2].id;
        quotesToBeInsertedList[1].SBQQ__ShippingCountry__c='India';
        quotesToBeInsertedList[1].Opportunity_Type__c = OpptyToBeInsertedList[2].Type ;
        quotesToBeInsertedList[1].Payment_Frequency__c  = OpptyToBeInsertedList[2].SBQQ__RenewedContract__r.SBQQ__Quote__r.Payment_Frequency__c ; 
        insert quotesToBeInsertedList;      
        quotesToBeInsertedList[0].Bill_To_Contact__c=null;
        quotesToBeInsertedList[0].Ship_To_Contact__c=null;
        quotesToBeInsertedList[0].SBQQ__PrimaryContact__c=null;
        quotesToBeInsertedList[0].SBQQ__ShippingCountry__c='India';
        update quotesToBeInsertedList;
        quotesToBeInsertedList[0].SBQQ__PrimaryContact__c=ContactList[0].Id;
        update quotesToBeInsertedList;    
        //  quotesToBeInsertedList[0].SBQQ__PrimaryContact__c=
        List<SBQQ__Quote__c> quotesWithMasterContractList = new List<SBQQ__Quote__c>();
        quotesWithMasterContractList=TestCPQUtilityClass.createQuotesWithMasterContracts(OpptyToBeInsertedList,1,contractsList[0]);
        //insert quotesWithMasterContractList;

        // Insert Quote Lines
        List<SBQQ__QuoteLine__c> quoteLinesToInsertList = new List<SBQQ__QuoteLine__c>();
        quoteLinesToInsertList = TestCPQUtilityClass.createQuoteLinesForQuote(quotesToBeInsertedList[0],productToInsertList);
        insert quoteLinesToInsertList;
        
        //Update Quote
        List<SBQQ__Quote__c> quoteToBeUpdatedList = new List<SBQQ__Quote__c>();
        for(SBQQ__Quote__c quote :quotesToBeInsertedList){
            quote.SBQQ__ShippingCountry__c = countryListToInsert[0].name;
            quote.SBQQ__BillingCountry__c  = countryListToInsert[0].name;
            quote.SBQQ__Opportunity2__c = OpptyToBeInsertedList[2].id;
            quote.Opportunity_Type__c = quote.SBQQ__Opportunity2__r.Type ;
            quoteToBeUpdatedList.add(quote);
        }
        Test.stopTest();
        update quoteToBeUpdatedList;
        
        //Update Opportunity
        //List<Opportunity> OpptyToBeUpdatedList = new List<Opportunity>();
        
        // Update Quote Lines
        List<SBQQ__QuoteLine__c> quoteLinesToUpdate = new List<SBQQ__QuoteLine__c>();
        for(SBQQ__QuoteLine__c quoteLine : quoteLinesToInsertList){
            quoteLine.SBQQ__Quantity__c = 100.00;
            quoteLine.SBQQ__Bundle__c =TRUE;
            quoteLine.SBQQ__OptionLevel__c =0;
            quoteLinesToUpdate.add(quoteLine);
        }
        update quoteLinesToUpdate;       
        /*
        // test when ABN_No__C on account != null and ABN_No__C on Quote == null
        // Quote.ABN_No__C = Account.ABN_No__C
        accountsWithSBN_NoList = new List<Account>();
        for(Integer i=0;i<10;i++) {
            Account a = new Account(Name='TestAccount' + i, ShippingCountry='Australia', Sales_Region__c='Australia',ABN_No__c=' Test 1234');           
            a.BillingCountry = 'United States';
            a.BillingStreet = 'Test Street';
            a.BillingState ='Test Billing State';
            a.BillingPostalCode ='12345';
            a.ShippingCity ='Pune';           
            a.ShippingPostalCode = '12345';
            a.ShippingState = '';
            a.ShippingStreet = 'Test Shipping Street';  
            a.Accounting_Email__c = 'test@gmail.com';
            a.Accounting_Contact_First_Name__c = 'FirstName';
            a.Accounting_Contact_Last_Name__c = 'LastName';
            a.Website = 'www.google.com';
            accountsWithSBN_NoList.add(a);
        }
        insert accountsWithSBN_NoList;        
         Test.stopTest();
        opportunityForAccountWithoutSBN_NoList = new List<Opportunity>();
        for (Integer j=0;j<accountsWithSBN_NoList.size();j++){         
            opportunityForAccountWithoutSBN_NoList.add(new Opportunity(Name=accountsWithSBN_NoList[j].Name + ' Opportunity ' + j,StageName='Prospecting',CloseDate=System.today().addMonths(1),AccountId=accountsWithSBN_NoList[j].Id));
        }               
        insert opportunityForAccountWithoutSBN_NoList;
        
        QuotesWithoutABN_NoList = new List<SBQQ__Quote__c>();
        numOfQuotesPerOppty =1;
        for(Integer i=0; i<opportunityForAccountWithoutSBN_NoList.size();i++){
            for(Integer j=0; j<numOfQuotesPerOppty; j++){
                //SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft', SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia',Region__c='Australia', SBQQ__Opportunity2__c=opportunityForAccountWithoutSBN_NoList[i].Id,SBQQ__Account__c= opportunityForAccountWithoutSBN_NoList[i].accountId);
                SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft', SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opportunityForAccountWithoutSBN_NoList[i].Id,SBQQ__Account__c= opportunityForAccountWithoutSBN_NoList[i].accountId, SBQQ__StartDate__c = System.Today());
                QuotesWithoutABN_NoList.add(quote);
            }
        }
        QuotesWithoutABN_NoList[0].SBQQ__ShippingCountry__c=null;
        insert QuotesWithoutABN_NoList; 
        
        // test when Registered_VAT_No__c on account != null and Registered_VAT_No__c on Quote == null
        // Quote.Registered_VAT_No__c = Account.Registered_VAT_No__c
        accountsWithRegistered_VAT_NoList = new List<Account>();
        for(Integer i=0;i<5;i++) {
            Account a = new Account(Name='TestAccount' + i, ShippingCountry='Australia', Sales_Region__c='Australia', Registered_VAT_No__c='Test 123');
            a.BillingCountry = 'United States';
            a.BillingStreet = 'Test Street';
            a.BillingState ='Test Billing State';
            a.BillingPostalCode ='12345';
            a.ShippingCity ='Pune';           
            a.ShippingPostalCode = '12345';
            a.ShippingState = '';
            a.ShippingStreet = 'Test Shipping Street';  
            a.Accounting_Email__c = 'test@gmail.com';
            a.Accounting_Contact_First_Name__c = 'FirstName';
            a.Accounting_Contact_Last_Name__c = 'LastName';
            a.Website = 'www.google.com';
            accountsWithRegistered_VAT_NoList.add(a);
        }
        insert accountsWithRegistered_VAT_NoList;
       
        
        opptyForAcctsWithoutRegistered_VAT_NoList = new List<Opportunity>();
        for (Integer j=0;j<accountsWithRegistered_VAT_NoList.size();j++){         
            opptyForAcctsWithoutRegistered_VAT_NoList.add(new Opportunity(Name=accountsWithRegistered_VAT_NoList[j].Name + ' Opportunity ' + j,StageName='Prospecting',CloseDate=System.today().addMonths(1),AccountId=accountsWithRegistered_VAT_NoList[j].Id));
        }               
        insert opptyForAcctsWithoutRegistered_VAT_NoList;
        
        QuotesWithoutRegistered_VAT_NoList = new List<SBQQ__Quote__c>();
        numOfQuotesPerOppty =1;
        for(Integer i=0; i<opptyForAcctsWithoutRegistered_VAT_NoList.size();i++){
            for(Integer j=0; j<numOfQuotesPerOppty; j++){
                //SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft', SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia',Region__c='Australia', SBQQ__Opportunity2__c=opportunityForAccountWithoutSBN_NoList[i].Id,SBQQ__Account__c= opportunityForAccountWithoutSBN_NoList[i].accountId);
                SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft', SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opportunityForAccountWithoutSBN_NoList[i].Id,SBQQ__Account__c= opportunityForAccountWithoutSBN_NoList[i].accountId, SBQQ__StartDate__c = System.Today());
                QuotesWithoutRegistered_VAT_NoList.add(quote);
            }
        }
        insert QuotesWithoutRegistered_VAT_NoList;   
            
    } */
    
    public static testMethod void coverPopulateNewQuoteFieldsFromPrevQuoteMtd(){
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
 
        // A. SteelBrick Process
        Test.startTest();
        List<Account> accountsToBeInsertedList = new List<Account>();
        accountsToBeInsertedList = TestCPQUtilityClass.createAccounts(1);
        for(Account accnt :accountsToBeInsertedList){
            accnt.name = 'Marketo Inc Test Acc Details';
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test1@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName453';
            accnt.Accounting_Contact_Last_Name__c = 'LastName789';
            accnt.Website = 'www.googletext12.com';
            accnt.PO_Required__c = true;
            accnt.ABN_No__c = '12345';
            accnt.Registered_VAT_No__c = '456789';
        }
        if(!accountsToBeInsertedList.isEmpty()){
            insert accountsToBeInsertedList;
        }       
        
        // Add products
        List<Product2> productToInsertList = new List<Product2>();
        productToInsertList =TestCPQUtilityClass.createCustomProducts(2);
        if(!productToInsertList.isEmpty()){
            insert productToInsertList;
        }
        
        // Insert MKTO Std PB.
        Pricebook2 mktoPB = new PriceBook2(name='MKTO STD PB', isActive=TRUE);
        insert mktoPB;
        
        // Insert custom setting data - SteelBrickCPQPricebook__c
        SteelBrickCPQPricebook__c mktoPBCustSet = new SteelBrickCPQPricebook__c(Case_Safe_ID__c = 'MKTO Case Safe Id', ID__c = mktoPB.Id);
        insert mktoPBCustSet;
        
                SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
 
        // Insert New Business Opportunities - Set Steelbrick PB
        List<Opportunity> OpptyToBeInsertedList = new List<Opportunity>();
        OpptyToBeInsertedList = TestCPQUtilityClass.createOpportunities(accountsToBeInsertedList,2);
        OpptyToBeInsertedList[0].type='New Business';
        OpptyToBeInsertedList[1].type='New Business';
        OpptyToBeInsertedList[0].Pricebook2Id = mktoPB.Id;
        OpptyToBeInsertedList[1].Pricebook2Id = mktoPB.Id;
        if(!OpptyToBeInsertedList.isEmpty()){
            insert OpptyToBeInsertedList;
        }

        
        // Insert SB Quotes
        List<SBQQ__Quote__c> quotesToBeInsertedList = new List<SBQQ__Quote__c>();
        quotesToBeInsertedList = TestCPQUtilityClass.createQuotes(OpptyToBeInsertedList,1);
        quotesToBeInsertedList[0].Marketing_Permission__c = 'Marketing_Permission__c';
        quotesToBeInsertedList[0].Case_Study_Permission__c = 'Case_Study_Permission__c';
        quotesToBeInsertedList[0].Custom_Agreement_Name_and_Date__c = 'Custom_Agreement_Name_and_Date__c';
        quotesToBeInsertedList[0].SBQQ__PaymentTerms__c = 'SBQQ__PaymentTerms__c';
        quotesToBeInsertedList[0].Payment_Frequency__c = 'Payment_Frequency__c';
        quotesToBeInsertedList[0].Hide_Discount__c = true;
        quotesToBeInsertedList[0].Enterprise_Roll_up_SKU__c = true;
        quotesToBeInsertedList[0].Renewal_Uplift_pct__c = '7%';
        quotesToBeInsertedList[0].Renewal_Uplift_Text__c = 'Renewal_Uplift_Text__c';
        quotesToBeInsertedList[0].PO_Number__c = '12345';
        quotesToBeInsertedList[0].PO_Required__c = true;
        quotesToBeInsertedList[0].SBQQ__Primary__c = true;
        //Secod Quote
        quotesToBeInsertedList[1].Marketing_Permission__c = 'Marketing_Permission__c';
        quotesToBeInsertedList[1].Case_Study_Permission__c = 'Case_Study_Permission__c';
        quotesToBeInsertedList[1].Custom_Agreement_Name_and_Date__c = 'Custom_Agreement_Name_and_Date__c';
        quotesToBeInsertedList[1].SBQQ__PaymentTerms__c = 'SBQQ__PaymentTerms__c';
        quotesToBeInsertedList[1].Payment_Frequency__c = 'Payment_Frequency__c';
        quotesToBeInsertedList[1].Hide_Discount__c = true;
        quotesToBeInsertedList[1].Enterprise_Roll_up_SKU__c = true;
        quotesToBeInsertedList[1].Renewal_Uplift_pct__c = '7%';
        quotesToBeInsertedList[1].Renewal_Uplift_Text__c = 'Renewal_Uplift_Text__c';
        quotesToBeInsertedList[1].PO_Number__c = '12345';
        quotesToBeInsertedList[1].PO_Required__c = true;
        quotesToBeInsertedList[1].SBQQ__Primary__c = true;
        if(!quotesToBeInsertedList.isEmpty()){
            insert quotesToBeInsertedList;
        }
   
        //OpptyToBeInsertedList[0].StageName = 'Signed Order';
        OpptyToBeInsertedList[0].Needs_Pains__c='Test';
        OpptyToBeInsertedList[0].Stage_Signed_Order_Date__c = system.today();
         
        // OpptyToBeInsertedList[1].StageName = 'Signed Order';
        OpptyToBeInsertedList[1].Needs_Pains__c='Test';
        OpptyToBeInsertedList[1].Stage_Signed_Order_Date__c = system.today();
        
        update OpptyToBeInsertedList;
         
        // Update Opportunity as Closed Won  - Fetch Opp Record Type
        Schema.DescribeSObjectResult descOppSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> oppRecordTypeInfo = descOppSchema.getRecordTypeInfosByName(); 
        Id closedWonRecTypeId = oppRecordTypeInfo.get('Closed Won').getRecordTypeId();
        
        OpptyToBeInsertedList[0].RecordTypeId = closedWonRecTypeId;
        OpptyToBeInsertedList[1].RecordTypeId = closedWonRecTypeId;
        
        OpptyToBeInsertedList[0].StageName = 'Closed Won';
        OpptyToBeInsertedList[1].StageName = 'Closed Won';
        
        update OpptyToBeInsertedList;
        
        // Insert Renewal Opportunity
        List<Opportunity> renOppList = new List<Opportunity>();
        renOppList = TestCPQUtilityClass.createOpportunities(accountsToBeInsertedList,1);
        renOppList[0].type='Renewal';
        renOppList[0].Pricebook2Id = mktoPB.Id;
        renOppList[0].Prior_Opportunity__c = OpptyToBeInsertedList[0].Id;
        if(!renOppList.isEmpty()){
            insert renOppList;
        }
                SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
 
        // Insert Quote on Renewal Opp
        List<SBQQ__Quote__c> renOppQuoteList = new List<SBQQ__Quote__c>();
        renOppQuoteList = TestCPQUtilityClass.createQuotes(renOppList,1);
        insert renOppQuoteList;
        Test.stopTest();
    } // End of test method coverPopulateNewQuoteFieldsFromPrevQuoteMtd
    
    public static testMethod void coverPopulateNewQuoteFieldsFromPrevQuoteMtdV2(){
        // B. Standard Process
                SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        List<Account> accountsToBeInsertedList = new List<Account>();
        accountsToBeInsertedList = TestCPQUtilityClass.createAccounts(1);
        for(Account accnt :accountsToBeInsertedList){
            accnt.name = 'Marketo Inc test @quote123';
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'testjhhg@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName1234';
            accnt.Accounting_Contact_Last_Name__c = 'LastName981';
            accnt.Website = 'www.googlehghgh.com';
            accnt.PO_Required__c = true;
            accnt.ABN_No__c = '12345';
            accnt.Registered_VAT_No__c = '456789';
        }
        if(!accountsToBeInsertedList.isEmpty()){
            insert accountsToBeInsertedList;
        }
        Test.startTest();        
                SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        // Get Standard PB Id
        Id stdPricebookId = Test.getStandardPricebookId();      
        
        // Insert New Business Opportunities - Set Steelbrick PB
        List<Opportunity> OpptyToBeInsertedList = new List<Opportunity>();
        OpptyToBeInsertedList = TestCPQUtilityClass.createOpportunities(accountsToBeInsertedList,2);
        OpptyToBeInsertedList[0].type='New Business';
        OpptyToBeInsertedList[1].type='New Business';
        OpptyToBeInsertedList[0].Pricebook2Id = stdPricebookId;
        OpptyToBeInsertedList[1].Pricebook2Id = stdPricebookId;
        if(!OpptyToBeInsertedList.isEmpty()){
            insert OpptyToBeInsertedList;
        }
        
        // Insert Standard Quote
        List<Quote> stdQuoteList = new List<Quote>();
        Quote stdQuote = new Quote(OpportunityId = OpptyToBeInsertedList[0].Id);
        stdQuote.Name = 'Quote 1';
        stdQuote.Customer_gives_Marketing_Permission__c = 'Customer_gives_Marketing_Permission__c';
        stdQuote.Case_Study_Permission__c = 'Case_Study_Permission__c';
        stdQuote.Payment_Terms__c = 'Payment_Terms__c';
        stdQuote.Payment_Frequency__c = 'Payment_Frequency__c';
        stdQuote.PO__c = '123';
        stdQuote.Increase_Language__c = 'Subscription fees will automatically increase by 5% per year.';
        stdQuoteList.add(stdQuote);
        Quote stdQuote2 = new Quote(OpportunityId = OpptyToBeInsertedList[1].Id);
        stdQuote2.Name = 'Quote 2';
        stdQuote2.Customer_gives_Marketing_Permission__c = 'Customer_gives_Marketing_Permission__c';
        stdQuote2.Case_Study_Permission__c = 'Case_Study_Permission__c';
        stdQuote2.Payment_Terms__c = 'Payment_Terms__c';
        stdQuote2.Payment_Frequency__c = 'Payment_Frequency__c';
        stdQuote2.PO__c = '123';
        stdQuote2.Increase_Language__c = null;
        stdQuoteList.add(stdQuote2);
        if(!stdQuoteList.isEmpty()){
            insert stdQuoteList;
        }
        Test.stopTest();
        
       //OpptyToBeInsertedList[0].StageName = 'Signed Order';
        OpptyToBeInsertedList[0].Needs_Pains__c='Test';
        OpptyToBeInsertedList[0].Stage_Signed_Order_Date__c = system.today();
         
        // OpptyToBeInsertedList[1].StageName = 'Signed Order';
        OpptyToBeInsertedList[1].Needs_Pains__c='Test';
        OpptyToBeInsertedList[1].Stage_Signed_Order_Date__c = system.today();
        
        update OpptyToBeInsertedList;
        
        // Update Opportunity as Closed Won  - Fetch Opp Record Type
        Schema.DescribeSObjectResult descOppSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> oppRecordTypeInfo = descOppSchema.getRecordTypeInfosByName(); 
        Id closedWonRecTypeId = oppRecordTypeInfo.get('Closed Won').getRecordTypeId();
        
        OpptyToBeInsertedList[0].RecordTypeId = closedWonRecTypeId;
        OpptyToBeInsertedList[1].RecordTypeId = closedWonRecTypeId;
        
        OpptyToBeInsertedList[0].StageName = 'Closed Won';
        OpptyToBeInsertedList[1].StageName = 'Closed Won';
        
        OpptyToBeInsertedList[0].SyncedQuoteId = stdQuoteList[0].Id;
        OpptyToBeInsertedList[1].SyncedQuoteId = stdQuoteList[1].Id;
        
        SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=OpptyToBeInsertedList[0].id,SBQQ__Account__c=accountsToBeInsertedList[0].id, SBQQ__StartDate__c = System.Today(),Order_Type__c ='123');
        insert quote ;
        
        SBQQ__Quote__c quote2 = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=OpptyToBeInsertedList[1].id,SBQQ__Account__c=accountsToBeInsertedList[0].id, SBQQ__StartDate__c = System.Today(),Order_Type__c ='123');
        insert quote2 ;
        
        OpptyToBeInsertedList[0].SBQQ__PrimaryQuote__c  = quote.id;
        OpptyToBeInsertedList[1].SBQQ__PrimaryQuote__c  = quote2.id;

        update OpptyToBeInsertedList;
        
        // Insert SB Renewal Opportunity - Insert MKTO Std PB.
        Pricebook2 mktoPB = new PriceBook2(name='MKTO STD PB', isActive=TRUE);
        insert mktoPB;
        
        // Insert custom setting data - SteelBrickCPQPricebook__c
        SteelBrickCPQPricebook__c mktoPBCustSet = new SteelBrickCPQPricebook__c(Case_Safe_ID__c = 'MKTO Case Safe Id', ID__c = mktoPB.Id);
        insert mktoPBCustSet;
        
        List<Opportunity> renOppList = new List<Opportunity>();
        renOppList = TestCPQUtilityClass.createOpportunities(accountsToBeInsertedList,1);
        renOppList[0].type='Renewal';
        renOppList[0].Pricebook2Id = mktoPB.Id;
        renOppList[0].Prior_Opportunity__c = OpptyToBeInsertedList[0].Id;
        if(!renOppList.isEmpty()){
            insert renOppList;
        }
        
        // Insert Quote on Renewal Opp
        List<SBQQ__Quote__c> renOppQuoteList = new List<SBQQ__Quote__c>();
        renOppQuoteList = TestCPQUtilityClass.createQuotes(renOppList,1);
        insert renOppQuoteList;
    } // End of test method coverPopulateNewQuoteFieldsFromPrevQuoteMtdV2
    
     static testmethod  void AccountUpdateCheckFromQuote(){
                SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        // test when ABN_No__C on account != null and ABN_No__C on Quote == null
        // Quote.ABN_No__C = Account.ABN_No__C
        accountsWithSBN_NoList = new List<Account>();
        for(Integer i=0;i<10;i++) {
            Account a = new Account(Name='TestAccount tyrtyryr' + i, ShippingCountry='Australia', Sales_Region__c='Australia',ABN_No__c=' Test 1234');           
            a.BillingCountry = 'United States';
            a.BillingStreet = 'Test Street';
            a.BillingState ='Test Billing State';
            a.BillingPostalCode ='12345';
            a.ShippingCity ='Pune';           
            a.ShippingPostalCode = '12345';
            a.ShippingState = '';
            a.ShippingStreet = 'Test Shipping Street';  
            a.Accounting_Email__c = 'test@gmail.com';
            a.Accounting_Contact_First_Name__c = 'FirstName';
            a.Accounting_Contact_Last_Name__c = 'LastName';
            a.Website = 'www.google.com';
            accountsWithSBN_NoList.add(a);
        }
        insert accountsWithSBN_NoList;        
        
        opportunityForAccountWithoutSBN_NoList = new List<Opportunity>();
        for (Integer j=0;j<accountsWithSBN_NoList.size();j++){         
            opportunityForAccountWithoutSBN_NoList.add(new Opportunity(Name=accountsWithSBN_NoList[j].Name + ' Opportunity ' + j,StageName='Prospecting',CloseDate=System.today().addMonths(1),AccountId=accountsWithSBN_NoList[j].Id,Rep_Create_ARR__c=1,MainCompetitor__c='Eloqua'));
        }               
        insert opportunityForAccountWithoutSBN_NoList;
        test.startTest();
                SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        QuotesWithoutABN_NoList = new List<SBQQ__Quote__c>();
        numOfQuotesPerOppty =1;
        for(Integer i=0; i<opportunityForAccountWithoutSBN_NoList.size();i++){
            for(Integer j=0; j<numOfQuotesPerOppty; j++){
                //SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft', SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia',Region__c='Australia', SBQQ__Opportunity2__c=opportunityForAccountWithoutSBN_NoList[i].Id,SBQQ__Account__c= opportunityForAccountWithoutSBN_NoList[i].accountId);
                SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft', SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opportunityForAccountWithoutSBN_NoList[i].Id,SBQQ__Account__c= opportunityForAccountWithoutSBN_NoList[i].accountId, SBQQ__StartDate__c = System.Today());
                QuotesWithoutABN_NoList.add(quote);
            }
        }
        QuotesWithoutABN_NoList[0].SBQQ__ShippingCountry__c=null;
        insert QuotesWithoutABN_NoList; 
        
        // test when Registered_VAT_No__c on account != null and Registered_VAT_No__c on Quote == null
        // Quote.Registered_VAT_No__c = Account.Registered_VAT_No__c
        accountsWithRegistered_VAT_NoList = new List<Account>();
        for(Integer i=0;i<5;i++) {
            Account a = new Account(Name='TestAccount VAT No fhfhfhf' + i, ShippingCountry='Australia', Sales_Region__c='Australia', Registered_VAT_No__c='Test 123');
            a.BillingCountry = 'United States asgdg';
            a.BillingStreet = 'Test Street sads';
            a.BillingState ='Test Billing State aas';
            a.BillingPostalCode ='12345';
            a.ShippingCity ='Pune';           
            a.ShippingPostalCode = '12345';
            a.ShippingState = '';
            a.ShippingStreet = 'Test Shipping Street';  
            a.Accounting_Email__c = 'testvxcvxcv@gmail.com';
            a.Accounting_Contact_First_Name__c = 'accounting email FirstName';
            a.Accounting_Contact_Last_Name__c = 'accounting email LastName';
            a.Website = 'www.googlehghghhhgg.com';
            accountsWithRegistered_VAT_NoList.add(a);
        }
        insert accountsWithRegistered_VAT_NoList;
       
        
        opptyForAcctsWithoutRegistered_VAT_NoList = new List<Opportunity>();
        for (Integer j=0;j<accountsWithRegistered_VAT_NoList.size();j++){         
            opptyForAcctsWithoutRegistered_VAT_NoList.add(new Opportunity(Name=accountsWithRegistered_VAT_NoList[j].Name + ' Opportunity ' + j,StageName='Prospecting',CloseDate=System.today().addMonths(1),AccountId=accountsWithRegistered_VAT_NoList[j].Id,Rep_Create_ARR__c=1,MainCompetitor__c='Eloqua'));
        }               
        insert opptyForAcctsWithoutRegistered_VAT_NoList;
        Test.stopTest();
        QuotesWithoutRegistered_VAT_NoList = new List<SBQQ__Quote__c>();
        numOfQuotesPerOppty =1;
        for(Integer i=0; i<opptyForAcctsWithoutRegistered_VAT_NoList.size();i++){
            for(Integer j=0; j<numOfQuotesPerOppty; j++){
                //SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft', SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia',Region__c='Australia', SBQQ__Opportunity2__c=opportunityForAccountWithoutSBN_NoList[i].Id,SBQQ__Account__c= opportunityForAccountWithoutSBN_NoList[i].accountId);
                SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft', SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opportunityForAccountWithoutSBN_NoList[i].Id,SBQQ__Account__c= opportunityForAccountWithoutSBN_NoList[i].accountId, SBQQ__StartDate__c = System.Today());
                QuotesWithoutRegistered_VAT_NoList.add(quote);
            }
        }
        insert QuotesWithoutRegistered_VAT_NoList; 
    
    }//End of Testmethod 
    
  public static testmethod void AmendQuoteTest(){
            SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
 
  List<Account> accountsToInsertList = new List<Account>();
   map<id,Opportunity> UpsellOpptyMap = new map<id,Opportunity>();
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
            accnt.Accounting_Contact_First_Name__c = 'dfdfdsdfg FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'fsdfdfbbg LastName';
            accnt.Website = 'www.googledfdfgfdg.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            accountsToInsertList.add(accnt);
        }
        insert accountsToInsertList;
        
        list<Contact> conList = TestCPQUtilityClass.createContacts(accountsToInsertList,2);
        List<Contact> ContactLists = new List<Contact>();
        
        Contact Con = new Contact();
        Con.FirstName = 'Test Name 12345';
        Con.LastName = '12Test1Contact 1896wer';
        Con.email = 'testhghhjgh@test.com';
        Con.LeadSource = 'Blog';
        //Con.SDR_Owner__c = 'Aara Zakariaei';
        Con.AccountId = accountsToInsertList[0].Id;
        Con.MailingCountry = 'India';   
        insert con;
        
        accountsToInsertList[0].Bill_To_Contact__c = con.id;
        accountsToInsertList[0].Ship_To_Contact__c = con.id;
        accountsToInsertList[1].Bill_To_Contact__c = con.id;
        accountsToInsertList[1].Ship_To_Contact__c = con.id;
        update accountsToInsertList;
            SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
 
        List<Contract> insertContractList= TestCPQUtilityClass.createContracts(accountsToInsertList,1);
        //Insert contract
        insert insertContractList;
        
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
       //  Test.startTest();
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
        opptyList[0].type = 'Renewal';
        opptyList[0].SBQQ__RenewedContract__c = insertContractList[0].id;
        opptyList[1].name = 'DeleteMe';
        opptyList[1].type = 'Upsell/Crossell';
        
        if(!opptyList.isEmpty()){
            insert opptyList;
            Test.setCreatedDate(opptyList[0].Id, DateTime.newInstance(2018,04,04,00,00,00));
        }
        
         for(Opportunity opp:opptyList){
             
             if(opp.type== 'Upsell/Crossell'){
                 UpsellOpptyMap.put(opp.id,opp);
             }
         }
        List<SBQQ__Quote__c> InsertQuote = TestCPQUtilityClass.createQuotes(opptyList,1);
         for(SBQQ__Quote__c SBQuote:InsertQuote){
             
             if(SBQuote.SBQQ__Opportunity2__c!=null && UpsellOpptyMap.containskey(SBQuote.SBQQ__Opportunity2__c)){
                 SBQuote.SBQQ__Type__c='Amendment';
             }
         }
                SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        insert InsertQuote;
        Test.setCreatedDate(InsertQuote[0].Id, DateTime.newInstance(2018,04,04,00,02,00));
        
         Test.startTest();
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        System.assert([SELECT COUNT() FROM SBQQ__Quote__c] > 0);

        Test.stopTest();
        
       // test.stoptest();
    }
    
    public static testmethod void AmendQuoteTest1(){
                SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
 
    List<Account> accountsToInsertList = new List<Account>();
    map<id,Opportunity> UpsellOpptyMap = new map<id,Opportunity>();
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
            accnt.Accounting_Contact_First_Name__c = 'FirstNamesdffd';
            accnt.Accounting_Contact_Last_Name__c = 'LastNamedff';
            accnt.Website = 'www.googlesfdsdf.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            accountsToInsertList.add(accnt);
        }
        insert accountsToInsertList;
        
        list<Contact> conList = TestCPQUtilityClass.createContacts(accountsToInsertList,2);
        List<Contact> ContactLists = new List<Contact>();
        
        Contact Con = new Contact();
        Con.FirstName = 'Test Name sdff';
        Con.LastName = '12Test1Contact 1 sdfsdf';
        Con.email = 'test@teshghgt.com';
        Con.LeadSource = 'Blog';
        Con.SDR_Owner__c = 'Aara Zakariaei';
        Con.AccountId = accountsToInsertList[0].Id;
        Con.MailingCity  = 'Mumbai';    
        Con.MailingCountry = 'India';   
        insert con;
            SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
           List<Contract> insertContractList= TestCPQUtilityClass.createContracts(accountsToInsertList,1);
           //Insert contract
           insert insertContractList;
        
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
       //  Test.startTest();
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
        opptyList[0].type = 'Renewal';
        opptyList[0].SBQQ__RenewedContract__c = insertContractList[0].id;
        opptyList[1].name = 'DeleteMe';
        opptyList[1].type = 'Upsell/Crossell';
        
        if(!opptyList.isEmpty()){
            insert opptyList;
            Test.setCreatedDate(opptyList[0].Id, DateTime.newInstance(2018,04,04,00,00,00));
        }
        
         for(Opportunity opp:opptyList){
             
             if(opp.type== 'Upsell/Crossell'){
                 UpsellOpptyMap.put(opp.id,opp);
             }
         }
        List<SBQQ__Quote__c> InsertQuote = TestCPQUtilityClass.createQuotes(opptyList,1);
         for(SBQQ__Quote__c SBQuote:InsertQuote){
             if(SBQuote.SBQQ__Opportunity2__c!=null && UpsellOpptyMap.containskey(SBQuote.SBQQ__Opportunity2__c)){
                 SBQuote.SBQQ__Type__c='Amendment';
             }
         }
        InsertQuote[0].SBQQ__PrimaryContact__c = Con.id;
        insert InsertQuote;
        Test.setCreatedDate(InsertQuote[0].Id, DateTime.newInstance(2018,04,04,00,04,00));

        
        Con.MailingCity  = 'Pune';  
        Update con;
        Test.startTest();
        SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        System.assert([SELECT COUNT() FROM SBQQ__Quote__c] > 0);

        Test.stopTest();
        
       // test.stoptest();
    }
        
     public static testmethod void multiInstanceTest(){
     SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
          List<Account> accountsToInsertList = new List<Account>();
           map<id,Opportunity> UpsellOpptyMap = new map<id,Opportunity>();
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
        
           List<Contract> insertContractList= TestCPQUtilityClass.createContracts(accountsToInsertList,1);
           //Insert contract
           insert insertContractList;
        
        List<Product2> productToInsertList = new List<Product2>();
        productToInsertList =TestCPQUtilityClass.createCustomProducts(5);
        productToInsertList[0].MA_or_RTP__c = 'MA';   
        productToInsertList[0].Visible_To_Customer__c = true;
        productToInsertList[0].Family  = 'Bundle';
        productToInsertList[0].Product_Type__c='Subscription';
        
        productToInsertList[1].Visible_To_Customer__c = true;
        productToInsertList[1].Family  = 'Bundle';
        productToInsertList[1].MA_or_RTP__c ='RTP';
        productToInsertList[1].ProductCode = 'TESTClassPRODCODE' ;
        productToInsertList[1].Product_Type__c='Subscription';
        
        productToInsertList[2].Visible_To_Customer__c = true;
        productToInsertList[2].MA_or_RTP__c ='RTP'; 
        productToInsertList[2].Family= 'Product';
        
        productToInsertList[3].Visible_To_Customer__c = true;
        productToInsertList[3].MA_or_RTP__c ='RTP'; 
        productToInsertList[3].Family= 'Product';

        
        insert productToInsertList;
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
        opptyList = TestCPQUtilityClass.createOpportunities( accountsToInsertList,1);
        for(Opportunity opp : opptyList){
            opp.Amount = 2000;
            opp.Pricebook2Id = pricebookList[0].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.OwnerId=UserInfo.getUserId();
        }
        opptyList[0].name = 'New Business';
            SalesTriggersUtility.dlrs_ContractTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_SubscriptionTrigger=true;
SalesTriggersUtility.dlrs_SBQQ_QuoteLineTrigger=true;
 SalesTriggersUtility.dlrs_AccountTrigger = true;
 SalesTriggersUtility.AssetTriggerVA  = true;
        if(!opptyList.isEmpty()){
            insert opptyList;
        }
           // Insert records for country__c
        List<Country__c> countryListToInsert = new List<Country__c>();
        for(Integer i=0; i<1; i++){
            Country__c con = new Country__c();
            con.Name ='Australia';
            con.Region__c ='Australia';
            con.Marketo_Entity__c='Marketo, KK';
            con.VAT_GST_Total__c = 80.50;
            con.Country_Registered_Office_Address__c='Marketo EMEA Limited, Red Oak North';
            countryListToInsert.add(con);
        }
        
       
        
        insert countryListToInsert;
        
         
        List<SBQQ__Quote__c> InsertQuote = TestCPQUtilityClass.createQuotes(opptyList,1);
              InsertQuote[0].Rubiks_Quote__c =true;
              InsertQuote[0].SBQQ__Type__c='Amendment';
              InsertQuote[0].SBQQ__ShippingCountry__c=countryListToInsert[0].name;
               InsertQuote[0].Country__c=countryListToInsert[0].id;
              InsertQuote[0].ABN_No__c='332';
              InsertQuote[0].Registered_VAT_No__C='text 12';
        insert InsertQuote;
         
        list<SBQQ__QuoteLine__c> newQLIList  = TestCPQUtilityClass.createQuoteLines(InsertQuote,4,productToInsertList);
        newQLIList[0].UR_Product__c =true;
        insert newQLIList;
       integer diffInDay= SBQQQuoteTriggerHandler.monthsbetweendates(system.today() ,system.today()+20);
        integer diffInDay1= SBQQQuoteTriggerHandler.monthsbetweendates(system.today() ,system.today()+40);
        SalesTriggersUtility.Setvaluesfortest();
        
        SalesTriggersUtility.Settruevaluesfortest();
        test.stoptest();
    }//End of testmethod multiInstanceTest
}