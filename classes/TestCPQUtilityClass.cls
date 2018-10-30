@IsTest

public class TestCPQUtilityClass{

public static List<Account> accountList{get;set;}
public static List<Product2> productsToInsertList{get;set;}
public static List<Opportunity> opportunityList{get;set;}  
public static List<PriceBookEntry> priceBookEntryList{get;set;}
public static List<PriceBook2> priceBooksToBeInsertedList{get;set;}
public static List<OpportunityLineItem> opportunityLineItemsList{get;set;}  
public static List<Contact> contactsList{get;set;}
public static List<Contract> contractsList{get;set;}
public static List<SBQQ__Subscription__c> subscriptionsList{get;set;}
public static List<PricebookEntry> standardPricebookEntryList{get;set;}
public static List<SBQQ__Quote__c> quotesList{get;set;}
public static List<Entitlement> entitlementsList{get;set;}
public static List<SBQQ__QuoteLine__c> quoteLinesToInsert{get;set;}
public static List<SBQQ__Quote__c> quotesWithLookupContractList{get;set;}
public static List<SBQQ__QuoteLine__c> quoteLinesWithContractLookupList{get;set;}    
public static List<SBQQ__Quote__c> simpleQuotesList{get;set;}
public static List<Intacct_Entity__c> IntacctEntityList{get;set;}
public static List<Case> caseList{get;set;}

public static List<SBQQ__QuoteLineGroup__c> QuoteLineGroupList;
public static List<pse__Proj__c> InsertProjectList;
public static List<pse__Milestone__c> InsertMilestoneList;
public static List<pse__Assignment__c> InsertAssignmentList;
public static List<pse__Timecard_Header__c> InsertTimeCardHeaderList;
public static List<pse__Timecard__c> InsertTimecardSplitList;
public static List<Sales_Invoice__c> InsertSalesInvoiceList;
public static List<Integration_Event_Log__c>InsertIntegrationEventLogList;
public static List<pse__Schedule__c> InsertScheduleList;
public static List<pse__Region__c> InsertRegionList;
public static List<pse__Practice__c> InsertPracticeList;
public static List<pse__Grp__c> InsertGroupList;
public static List<pse__Expense__c> InsertExpenseList;
public static List<pse__Expense_Report__c > InsertExpenseReportList{get;set;}
public static List<pse__Budget__c> InsertBudgetList;
public static List<pse__Project_Task__c> ProjectTaskList;
public static list<pse__Project_Task_Dependency__c> InsertProjectDepTask ;
Public static list<pse__Resource_Request__c> resourceRequestList;
public static List<pse__Resource_Skill_Request__c> InsertProjectRequestSkillList;  
public static List<pse__Skill__c> InsertProjectSkillList;

public static List<Account> createAccounts(Integer numbOfAccounts){
    
    IntacctEntityList = new List<Intacct_Entity__c>();
    for(Integer j=0;j<numbOfAccounts;j++){
        Intacct_Entity__c entity=new Intacct_Entity__c(Name='marketo-rubiks');
        IntacctEntityList.add(entity);
    }
    insert IntacctEntityList;

    accountList = new List<Account>();
    for(Integer i=0;i<numbOfAccounts;i++) {
            Account a = new Account(Name='TestAccount' + i, ShippingCountry='Australia', Sales_Region__c='Australia',ABN_No__c=' Test 1234');
            a.BillingCountry = 'United States';
            a.BillingStreet = 'Test Street';
            a.BillingState ='Test Billing State';
            a.BillingPostalCode ='12345';
            a.ShippingCity ='Pune';
            a.ShippingCountry ='India';
            a.ShippingPostalCode = '12345';
            a.ShippingState = 'Maharashtra';
            a.ShippingStreet = 'Test Shipping Street';  
            a.Accounting_Email__c = 'test@gmail.com';
            a.Accounting_Contact_First_Name__c = 'FirstName';
            a.Accounting_Contact_Last_Name__c = 'LastName';
            a.Website = 'www.google.com';
            a.IntacctID__c = 'TestIntacctID123' +i;
            a.Intacct_Entity__c = IntacctEntityList[i].id;
            accountList.add(a);
        }
    return accountList;
}

public static List<Contact> createContacts(List<Account> accountsList, Integer numbOfContactsPerAccount){
    contactsList = new List<Contact>();
    for (Integer j=0;j<accountsList.size();j++) {
        for(Integer k=0; k<numbOfContactsPerAccount; k++){
            Contact c = new Contact(firstname='Test'+k, lastname='Test'+k, AccountId=accountsList[k].Id,MailingStreet='901 Mariners Island Blvd',MailingState='',MailingCity='San Mateo',MailingCountry='US',MailingPostalCode='94404',pse__Salesforce_User__c = UserInfo.getUserId());
            contactsList.add(c);
        }
    }
    return contactsList;
}
    
public static List<Opportunity> createOpportunities(List<Account> insertedAccountList, Integer numOfOppty){
    opportunityList = new List<Opportunity>();
    PriceBook2 pb = new PriceBook2(name='Test PriceBook', isActive=TRUE);
    insert pb;
    IntacctEntityList = new List<Intacct_Entity__c>();
    Intacct_Entity__c entity=new Intacct_Entity__c(Name='marketo-rubiks');
    IntacctEntityList.add(entity);
    insert IntacctEntityList;
    for (Integer j=0;j<insertedAccountList.size();j++)          
        for (Integer k=0;k<numOfOppty;k++) {
            opportunityList.add(new Opportunity(Name=insertedAccountList[j].Name + ' Opportunity ' + k,StageName='Prospecting',CloseDate=System.today().addMonths(1),AccountId=insertedAccountList[j].Id,Intacct_Entity__c = IntacctEntityList[0].id,Intacct_Sales_Region__c = 'APAC',Rep_Create_ARR__c=1,MainCompetitor__c='Act-On',Subscription_Language__c='English',Subscription_Locale__c='English-United States',Subscription_Time_Zone__c='Afghanistan Time (Asia/Kabul)',Pricebook2id=pb.id,Payment_Terms__c = 'Payment Due on Receipt of Invoice',Payment_Frequency__c = 'Annually'));
        }               
    return opportunityList;
}


public static List<Product2> createCustomProducts(Integer numOfProducts){
    productsToInsertList = new List<Product2>();
     for(Integer i=0; i<numOfProducts; i++){
        Product2 product = new Product2(Name = 'Test Product' + i, ProductCode = 'TESTPRODCODE' + i, isActive=TRUE);
        productsToInsertList.add(product);
     }
        return productsToInsertList;
}

public static List<PriceBook2> createCustomPriceBooks(Integer numOfPriceBooks){
    priceBooksToBeInsertedList = new List<PriceBook2>();
    for(Integer x=0; x<numOfPriceBooks; x++){
        PriceBook2 pb = new PriceBook2(name='Test PriceBook '+x, isActive=TRUE);
        priceBooksToBeInsertedList.add(pb);
    }
        return priceBooksToBeInsertedList;
}

public static List<SteelBrickCPQPricebook__c> createSteelBrickCPQPricebook(Integer numOfPriceBooks,List<PriceBook2> priceBookList){
    list<SteelBrickCPQPricebook__c> CPQPricebookList = new list<SteelBrickCPQPricebook__c>() ;
    for(integer p=0; p<numOfPriceBooks; p++){
        for(integer q=0; q<priceBookList.size();q++)
        {
            SteelBrickCPQPricebook__c CPQPrice = new SteelBrickCPQPricebook__c(Name = 'SteelBrick PB', ID__c = priceBookList[q].Id);
            CPQPricebookList.add(CPQPrice);
        }
    }
    return CPQPricebookList;
}

public static List<PriceBookEntry> createPriceBookEntries(List<Product2> insertedProductList, List<PriceBook2> priceBookList){
    priceBookEntryList = new List<PriceBookEntry>();
    for(integer p=0; p<insertedProductList.size();p++){
        for(integer q=0; q<priceBookList.size();q++)
        {
            PriceBookEntry pbe = new PriceBookEntry (Product2Id =insertedProductList[p].Id, PriceBook2Id = priceBookList[q].Id, UnitPrice = 10, isActive = TRUE);
            priceBookEntryList.add(pbe);
        }
    }
    return priceBookEntryList;
}

public static List<OpportunityLineItem> createOppLineItems(List<Opportunity> oppList, List<PricebookEntry> priceBookEntriesList){
    opportunityLineItemsList = new List<OpportunityLineItem>();
    for(Integer r=0;r<oppList.size();r++){
        for(Integer s=0; s<priceBookEntriesList.size(); s++){
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = oppList[r].Id, PricebookEntryId = priceBookEntriesList[s].Id, UnitPrice = 10, Quantity = 20);
            opportunityLineItemsList.add(oli);
        }
    }
    return opportunityLineItemsList;
}

public static List<Contract> createContracts(List<Account> accList, Integer numOfContractsPerAcoount){
    contractsList = new List<Contract>();
    for (Integer j=0;j<accList.size();j++) {
        for(Integer k=0; k<numOfContractsPerAcoount; k++){
            Contract c = new Contract(Name='Test Contract '+k, AccountId=accList[j].Id,StartDate=System.today());
            contractsList.add(c);
        }
    }
    return contractsList;
}

public static List<SBQQ__Subscription__c> createSubscriptions(List<Contract> contractList, Integer numOfContractsPerSubscription){
    subscriptionsList = new List<SBQQ__Subscription__c>();
    for (Integer j=0;j<contractList.size();j++) {
        for(Integer k=0; k<numOfContractsPerSubscription; k++){
            SBQQ__Subscription__c c = new SBQQ__Subscription__c(SBQQ__Contract__c=contractList[j].Id,SBQQ__Account__c=contractList[0].AccountId,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4));
            subscriptionsList.add(c);
        }
    }
    return subscriptionsList;
}

// Method to insert every product in StandardPricebook
// First get standard pricebook Id
// Id stdPricebookId = Test.getStandardPricebookId();
public static void createStdPricebookEntries(List<Product2> prodctList, Id standardPricebookId){
    standardPricebookEntryList = new List<PricebookEntry>();
    for(Integer i=0; i<prodctList.size();i++){
        PricebookEntry standardPrice = new PricebookEntry(Pricebook2Id = standardPricebookId, Product2Id = prodctList[i].Id,UnitPrice = 10000, IsActive = true);
        standardPricebookEntryList.add(standardPrice);
    }
    insert standardPricebookEntryList;
}

// create test data for custom Quote
public static List<SBQQ__Quote__c> createQuotes(List<Opportunity> opptiesList, Integer numOfQuotesPerOppty){
    quotesList = new List<SBQQ__Quote__c>();
    for(Integer i=0; i<opptiesList.size();i++){
        for(Integer j=0; j<numOfQuotesPerOppty; j++){
            //SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia',Region__c='Australia', SBQQ__Opportunity2__c=opptiesList[i].Id,SBQQ__Account__c= opptiesList[i].accountId);
            SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opptiesList[i].Id,SBQQ__Account__c= opptiesList[i].accountId, SBQQ__StartDate__c = System.Today());
            quotesList.add(quote);
        }
    }
    return quotesList;
}

public static List<SBQQ__QuoteLineGroup__c> createQuoteLineGroup(List<SBQQ__Quote__c> QuoteList,Integer numOfGroupsPerQuote ){
    QuoteLineGroupList = new List<SBQQ__QuoteLineGroup__c>();
    for(Integer i=0;i<QuoteList.size();i++){
        for(Integer j=0; j<numOfGroupsPerQuote; j++){
            SBQQ__QuoteLineGroup__c QuoteLineGrp = new SBQQ__QuoteLineGroup__c(SBQQ__Quote__c=QuoteList[i].Id,Contact_Database_Size__c=1234);
            QuoteLineGroupList.add(QuoteLineGrp);
        }
    }
    return QuoteLineGroupList;
}


// Create quotes with master contract
public static List<SBQQ__Quote__c> createQuotesWithMasterContracts(List<Opportunity> opptiesList, Integer numOfQuotesPerOppty, Contract masterContract){
    quotesList = new List<SBQQ__Quote__c>();
    for(Integer i=0; i<opptiesList.size();i++){
        for(Integer j=0; j<numOfQuotesPerOppty; j++){
            //SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',SBQQ__MasterContract__c=masterContract.Id, ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia',Region__c='Australia', SBQQ__Opportunity2__c=opptiesList[i].Id,SBQQ__Account__c= opptiesList[i].accountId);
            SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',SBQQ__MasterContract__c=masterContract.Id, ABN_No__c ='12345',Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia', SBQQ__Opportunity2__c=opptiesList[i].Id,SBQQ__Account__c= opptiesList[i].accountId, SBQQ__StartDate__c = System.Today());
            quotesList.add(quote);
        }
    }
    return quotesList;
}


// Create quotes with Contracts Lookup
public static List<SBQQ__Quote__c> createQuotesWithContractsLookup(List<Opportunity> oppties2List, Integer numOfQuotesPerOppty2, Contract contrct2){
    quotesWithLookupContractList = new List<SBQQ__Quote__c>();
    for(Integer i=0; i<oppties2List.size();i++){
        for(Integer j=0; j<numOfQuotesPerOppty2; j++){
            //SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Contract_Lookup__c=contrct2.Id,Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia',Region__c='Australia', SBQQ__Opportunity2__c=oppties2List[i].Id,SBQQ__Account__c= oppties2List[i].accountId);
            SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Status__c='Draft',ABN_No__c ='12345',Contract_Lookup__c=contrct2.Id,Registered_VAT_No__C='12345',SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c='Australia',SBQQ__Opportunity2__c=oppties2List[i].Id,SBQQ__Account__c= oppties2List[i].accountId, SBQQ__StartDate__c = System.Today());
            quotesWithLookupContractList.add(quote);
        }
    }
    return quotesWithLookupContractList;
}

// Create simple quote
public static List<SBQQ__Quote__c> createSimpleQuote(List<Opportunity> oppotiesList, Integer numQuotes){
    simpleQuotesList = new List<SBQQ__Quote__c>();
    for(Integer i=0; i<oppotiesList.size();i++){
        for(Integer j=0; j<numQuotes; j++){
            //SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c=oppotiesList[i].account.ShippingCountry, Region__c=oppotiesList[i].account.Sales_Region__c, SBQQ__Opportunity2__c=oppotiesList[i].Id,SBQQ__Account__c= oppotiesList[i].accountId);
            SBQQ__Quote__c quote = new SBQQ__Quote__c(SBQQ__Type__c='Quote',SBQQ__ShippingCountry__c=oppotiesList[i].account.ShippingCountry,SBQQ__Opportunity2__c=oppotiesList[i].Id,SBQQ__Account__c= oppotiesList[i].accountId, SBQQ__StartDate__c = System.Today());
            simpleQuotesList.add(quote);
        }
    }
    return simpleQuotesList;
}

// Create Entitlements
public static List<Entitlement> createEntitlements(List<SBQQ__Subscription__c> subscriptionsToInsertList, Integer numOfEntitlementsPerSubscription){
    entitlementsList = new List<Entitlement>();
    for(Integer k=0; k<subscriptionsToInsertList.size(); k++){
        for(Integer l=0; l<numOfEntitlementsPerSubscription; l++){
            Entitlement ent = new Entitlement(name='Test Entitlement '+ l,AccountId=subscriptionsToInsertList[0].SBQQ__Account__c);
            entitlementsList.add(ent);
        }
    }
    return entitlementsList;
}
// create Quote Line Items
public static List<SBQQ__QuoteLine__c> createQuoteLines(List<SBQQ__Quote__c> quotesToPassList, Integer numOfQuotesLinesPerQuote,list<Product2> ProductList){
    quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
    for(Integer i=0; i<quotesToPassList.size();i++){
        for(Integer j=0; j<numOfQuotesLinesPerQuote; j++){
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quotesToPassList[i].Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=ProductList[j].id);
            quoteLinesToInsert.add(quoteLine);
        }
    }
    return quoteLinesToInsert;
}
    /*
// create Quote Line Items
public static List<SBQQ__QuoteLine__c> createQuoteLines(List<SBQQ__Quote__c> quotesToPassList, Integer numOfQuotesLinesPerQuote){
    quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
    for(Integer i=0; i<quotesToPassList.size();i++){
        for(Integer j=0; j<numOfQuotesLinesPerQuote; j++){
            SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quotesToPassList[i].Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0);
            quoteLinesToInsert.add(quoteLine);
        }
    }
    return quoteLinesToInsert;
}
*/
    // create quote lines for quotes with contract lookup  
    public static List<SBQQ__QuoteLine__c> createQuoteLinesWithContractLookup(List<SBQQ__Quote__c> quotesPassedList, Integer quotesLinesPerQuote){
        quoteLinesWithContractLookupList = new List<SBQQ__QuoteLine__c>();
        for(Integer i=0; i<quotesPassedList.size();i++){
            for(Integer j=0; j<quotesLinesPerQuote; j++){
                SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quotesPassedList[i].Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0);
                quoteLinesWithContractLookupList.add(quoteLine);
            }
        }
        return quoteLinesWithContractLookupList;
    } 
    
     // create Quote Line Items for single quote
    public static List<SBQQ__QuoteLine__c> createQuoteLinesForQuote(SBQQ__Quote__c quote, list<product2> Prodlist){
        quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
        for(Integer i=0; i<Prodlist.size();i++){
            
                SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(SBQQ__Quote__c=quote.Id,SBQQ__Quantity__c=7,SBQQ__Bundle__c=TRUE,SBQQ__OptionLevel__c=0,SBQQ__Product__c=Prodlist[i].id);
                quoteLinesToInsert.add(quoteLine);
            
        }
        return quoteLinesToInsert;
    }
    //Create Cases
    public static List<Case> createCases(List<Opportunity> OppList, Integer numbOfCases){
        
        Schema.DescribeSObjectResult descOppSchema = Schema.SObjectType.Case; 
        Map<String,Schema.RecordTypeInfo> oppRecordTypeInfo = descOppSchema.getRecordTypeInfosByName(); 
        Id ProvisioningRecTypeId = oppRecordTypeInfo.get('Provisioning Cases Record Type').getRecordTypeId();
        caseList = new List<Case>();
        for (Integer j=0;j<OppList.size();j++) {
            for(Integer k=0; k<numbOfCases; k++){
                Case c = new Case(Subject='Test'+k, AccountId=OppList[j].AccountId,Opportunity__c=OppList[j].Id, Status ='New',Sales_Ops_Category__c='License',Recordtypeid=ProvisioningRecTypeId);
                caseList.add(c);
            }
        }
        return caseList;
    } 
    //create Region 
    public static List<pse__Region__c> createRegion(Integer numOfRegion){
        InsertRegionList= new list<pse__Region__c>();
        for(integer i=0; i <numOfRegion; i++){
            pse__Region__c regionObj = new pse__Region__c(Name = 'TestName');
            InsertRegionList.add(regionObj);
        }
        return InsertRegionList;
    }
    //create Practice
    public static List<pse__Practice__c> CreatePractice(Integer numofPractice){
    InsertPracticeList = new list<pse__Practice__c>();
        for(integer i=0; i <numofPractice; i++){
        pse__Practice__c PracObj = new pse__Practice__c(Name = 'Test');
        InsertPracticeList.add(PracObj);
        }
        return InsertPracticeList;
    }
    
  //Create Project
    public static List<pse__Proj__c> createProject(list<Opportunity> oppList, Integer numbOfProject){
    InsertProjectList = new list<pse__Proj__c>();
        for(Opportunity oppObj : oppList){
            for(Integer i=0; i<numbOfProject; i++){
                pse__Proj__c projObj = new pse__Proj__c(Name = 'Test Project' + i,pse__Project_Type__c = 'Customer Project',pse__Stage__c = 'Planned',pse__Start_Date__c = System.today(),pse__End_Date__c = System.today()+15,pse__Opportunity__c = oppObj.id,pse__Account__c = oppObj.AccountId);
                InsertProjectList.add(projObj);
            }
        }
        return InsertProjectList;
    }
    //Create Milestone
    public static List<pse__Milestone__c> createMilestone(List<pse__Proj__c> ProjList, Integer numbOfMilestone){
        InsertMilestoneList = new list<pse__Milestone__c>();
        for(pse__Proj__c ProjObj : ProjList){
            for(Integer i=0; i<numbOfMilestone; i++){
                pse__Milestone__c milestoneObj = new pse__Milestone__c( Name = 'Test Milestone' + i, pse__Target_Date__c = System.today()+5,pse__Milestone_Amount__c = 2000,pse__Project__c = ProjObj.id);
                InsertMilestoneList.add(milestoneObj);
            }
        }
        return InsertMilestoneList;
    }
    
    // create Schedule 
    public static list<pse__Schedule__c> createSchedule(Integer numbOfSchedule){
    InsertScheduleList = new list<pse__Schedule__c>();
        for(integer i = 0; i<numbOfSchedule; i++){
            pse__Schedule__c scheduleObj = new pse__Schedule__c(pse__Start_Date__c = system.today(),pse__End_Date__c = system.today()+5,pse__Monday_Hours__c = 8,pse__Tuesday_Hours__c = 8,pse__Wednesday_Hours__c = 8,pse__Thursday_Hours__c = 8 ,pse__Friday_Hours__c = 8,pse__Saturday_Hours__c = 8,pse__Sunday_Hours__c = 8);
            InsertScheduleList.add(scheduleObj);
        }
        return InsertScheduleList;
    }
    
    //create Assignment
    public static List<pse__Assignment__c> createAssignment(List<pse__Proj__c> ProjList,List<Contact> ConList , String ResourceRequestId, Integer numbOfAssignement){
        InsertAssignmentList = new list<pse__Assignment__c>();
        for(pse__Proj__c proObj : ProjList){
            for(Contact conObj : ConList){
                for(Integer i=0; i<numbOfAssignement; i++){
                    pse__Assignment__c assignementObj = new pse__Assignment__c( Name = 'Test Assignement' + i, pse__Role__c = 'Project Manager',pse__Bill_Rate__c = 0, pse__Is_Billable__c = true, pse__Cost_Rate_Amount__c = 100,pse__Project__c = proObj.id, pse__Resource__c = conObj.id, pse__Status__c = 'Tentative', pse__Resource_Request__c = ResourceRequestId, pse__Closed_for_Time_Entry__c = FALSE );
                    InsertAssignmentList.add(assignementObj);
                }
                
            }
        }
        return InsertAssignmentList;
    }
    
    
    
    //Create Timecard Header
    public static List<pse__Timecard_Header__c> createTimecardHeader(list<Contact> conList,Integer numbOfTimecardSplit){
        InsertTimeCardHeaderList = new list<pse__Timecard_Header__c>();
        for(Contact ConObj : conList){
            for(Integer i=0; i<numbOfTimecardSplit; i++){
                pse__Timecard_Header__c timecardHeaderObj = new pse__Timecard_Header__c(pse__Start_Date__c = System.today(),pse__End_Date__c = System.today()+6,pse__Resource__c = ConObj.id);
                InsertTimeCardHeaderList.add(timecardHeaderObj);
            }
        }
        return InsertTimeCardHeaderList;
    }
          
    
    //Create Timecard Split
    public static List<pse__Timecard__c> createTimecardSplit(list<pse__Timecard_Header__c> TimecardHeaderList,Integer numbOfTimecardSplit){
        InsertTimecardSplitList = new list<pse__Timecard__c>();
        for(pse__Timecard_Header__c timeHeadObj : TimecardHeaderList){
            for(Integer i=0; i<numbOfTimecardSplit; i++){
                pse__Timecard__c timecardSplitObj = new pse__Timecard__c(pse__Timecard_Header__c = timeHeadObj.id);
                InsertTimecardSplitList.add(timecardSplitObj);
            }
        }
        return InsertTimecardSplitList;
    }
    
    //Create Sales Invoice
    public static List<Sales_Invoice__c> createSalesInvoice(list<Opportunity> OppList , Integer numbOfSalesInvoice){
        InsertSalesInvoiceList = new list<Sales_Invoice__c>();
        for(Opportunity oppObj : OppList){
            for(Integer i=0; i<numbOfSalesInvoice; i++){
                Sales_Invoice__c SalesInvoiceObj = new Sales_Invoice__c(Name = 'Test Sales Invoice',Opportunity__c = oppObj.id);
                InsertSalesInvoiceList.add(SalesInvoiceObj);
            }
        }
        return InsertSalesInvoiceList;
    }
        
        //create Integration Event Log
    public static List<Integration_Event_Log__c> createIntegrationEventLog(Integer numofIntegrationEvent){
        InsertIntegrationEventLogList = new list<Integration_Event_Log__c>();
        for(Integer i=0; i<numofIntegrationEvent; i++){
            Integration_Event_Log__c IntEventLogObj = new Integration_Event_Log__c(Action__c = 'Create Milestone in Intacct' ,
            Debug__c = 'Test',
            Payload__c = 'Test Payload',
            Payload_Format__c = 'XML',
            sObjectType__c = 'pse__Milestone__c',
            Type__c = 'Intacct XML Raw Data Request');
            InsertIntegrationEventLogList.add(IntEventLogObj);
        }
        return InsertIntegrationEventLogList;
    }
    
    //create GroupList
     public static List<pse__Grp__c> createGroupList(List<Contact> contactsList,Integer numbOfGroups)
    {
        User newUser =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser', 'Mkto', 'cfsId');
        InsertGroupList = new List<pse__Grp__c>();
        for(Contact con : contactsList)
        {
           for(Integer i=0 ; i< numbOfGroups ;i++)
            {
            pse__Grp__c newGrp = new pse__Grp__c(Name='Test Group'+i, pse__Group_Head__c = con.id , pse__Actuals_Last_Updated_By__c = newUser.id, pse__Backlog_Last_Updated_By__c = newUser.Id , pse__Plan_Last_Updated_By__c = newUser.Id ,pse__Utilization_Last_Updated_By__c = newUser.Id );
            InsertGroupList.add(newGrp);
         } 
        }
        return InsertGroupList;
    }
    
    //create ExpenseList
    public static List<pse__Expense__c> createExpenseList(List<pse__Proj__c> ProjList,List<Contact> contactsList,Integer numbOfExpense){
        List<Contact> conList = new List<Contact>();
        for(Contact con: contactsList){
            con.pse__Salesforce_User__c = UserInfo.getUserId();
            conList.add(con);
        }
        InsertExpenseList = new List<pse__Expense__c>();
        for(pse__Proj__c Proj : ProjList){
            Proj.pse__Is_Active__c = true; 
            for(Integer i=0 ; i< numbOfExpense;i++){
                pse__Expense__c newExpense = new pse__Expense__c(pse__Project__c = Proj.id,pse__Resource__c = conList[0].id,pse__Amount__c = 1200 , pse__Type__c = 'Airfare',pse__Admin_Global_Edit__c = true,pse__Audit_Notes__c = 'test test test test');
                InsertExpenseList.add(newExpense );
            }
        }
        return InsertExpenseList;
    }
    //Create ExpenseReportList
    public static List<pse__Expense_Report__c> createExpenseReport(List<pse__Proj__c> ProjList,List<Contact> contact_list, Integer numOfExpenseReport)
    {
        list<Contact> ConList = new list<Contact>();
        for(Contact con: contact_list){
            con.pse__Salesforce_User__c = UserInfo.getUserId();
            ConList.add(con);
        }
        InsertExpenseReportList=new list<pse__Expense_Report__c>();
        for(pse__Proj__c ProjObj :  ProjList){
            for(Integer i=0 ; i<numOfExpenseReport; i++){
                pse__Expense_Report__c newExpenseReport = new pse__Expense_Report__c(Name='Test Expense report', pse__Project__c = ProjObj.id, pse__Resource__c=ConList[0].id,pse__Admin_Global_Edit__c= true,pse__Audit_Notes__c = 'test Expense Report');
                InsertExpenseReportList.add(newExpenseReport);
            }
        }
        return InsertExpenseReportList;
    }
    
    //Create BudgetList
    public static List<pse__Budget__c> createBudgetList(List<pse__Proj__c> ProjList , Integer numOfBudget ){
    InsertBudgetList = new List<pse__Budget__c>();
    for(pse__Proj__c proj : ProjList){
        for(Integer i=0 ; i<numOfBudget; i++){
            pse__Budget__c newBudget = new pse__Budget__c(Name = 'Test Budget'+i ,pse__Project__c = proj.Id);
            InsertBudgetList.add(newBudget);
        }
    }
    return InsertBudgetList;
    } 
    
   public static List<pse__Project_Task__c> createProjectTask(list<pse__Milestone__c> milestoneList,integer noOfProjectTask){
        ProjectTaskList = new list<pse__Project_Task__c>();
        for(pse__Milestone__c milstone : milestoneList){
           for (Integer j=0;j<noOfProjectTask;j++) {
                pse__Project_Task__c projectTask = new pse__Project_Task__c( Name = 'Test projectTask'+j, pse__Milestone__c=milstone.id,pse__Project__c = milstone.pse__Project__c,pse__Start_Date_Time__c=System.today()+(j+5),pse__End_Date_Time__c=System.today()+(j+20));
                ProjectTaskList.add(projectTask);
            }
        }
        return ProjectTaskList;
    }//End of method createProjectTask
    
    //Create Project Task Dependency
    
     public static List<pse__Project_Task_Dependency__c> createProjTaskDependency(list<pse__Project_Task__c> ProjTaskList, Integer numbOfDepTask){
        InsertProjectDepTask  = new list<pse__Project_Task_Dependency__c>();
            for(pse__Project_Task__c projTaskObj : ProjTaskList){
                for(Integer i=0; i<numbOfDepTask; i++){
                    pse__Project_Task_Dependency__c ProjTskDep = new pse__Project_Task_Dependency__c(pse__Type__c = 'Finish to Start (FS)',pse__Dependent_Task__c = projTaskObj.Id);
                    InsertProjectDepTask.add(ProjTskDep);
                }
            }
            return InsertProjectDepTask ;
        }
        
        //Create createResourceRequestList
        public static List<pse__Resource_Request__c> createResourceRequestList(list<pse__Milestone__c> milestoneList, Integer numOfResourceRequest){
              resourceRequestList = new list<pse__Resource_Request__c>();
              for(pse__Milestone__c milestone :  milestoneList){
               for(Integer i=0 ; i<numOfResourceRequest; i++){
                    pse__Resource_Request__c newResourceRequest = new pse__Resource_Request__c(pse__Milestone__c=milestone.id, pse__Project__c = milestone.pse__Project__c ,pse__Resource_Role__c='Business Consultant',pse__SOW_Hours__c=12,pse__Start_Date__c=system.Today(),pse__End_Date__c=system.Today().addMonths(6));
                     resourceRequestList.add(newResourceRequest);
               }
              }
        return resourceRequestList;
      }
     public static List<pse__Skill__c> createProjSkill(Integer numbOfSkill){
        InsertProjectSkillList = new list<pse__Skill__c>();
            for(Integer i=0; i<numbOfSkill; i++){
          pse__Skill__c projSkillObj = new pse__Skill__c(Name= 'Test',pse__Certification_Source__c='Salesforce.com',pse__Description__c='Test');
          InsertProjectSkillList.add(projSkillObj);
         }
      return InsertProjectSkillList;
    }
   
      public static List<pse__Resource_Skill_Request__c> createProjReqSkill(List<pse__Skill__c> ProjSkillList , Integer numbOfResSkillReq){
            InsertProjectRequestSkillList= new List<pse__Resource_Skill_Request__c>();
             for(pse__Skill__c skillObj : ProjSkillList){
              for(Integer i=0; i<numbOfResSkillReq; i++){
                   pse__Resource_Skill_Request__c reqSkillReqObj = new pse__Resource_Skill_Request__c(pse__Skill_Certification__c = skillObj.id , pse__Is_Primary__c = true);
                   InsertProjectRequestSkillList.add(reqSkillReqObj);
              }
             }
         return InsertProjectRequestSkillList;
        }
}