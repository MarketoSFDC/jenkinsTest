@IsTest
public class newQuotePageExtenstionTest {
    
    public static testMethod void testNewActionRubiks(){
        // Insert Account
        List<Account> accntList = new List<Account>();
        accntList = TestCPQUtilityClass.createAccounts(5);
        insert accntList; 
        
        // Insert COntacts
        List<Contact> contactList = new List<Contact>();
        contactList = TestCPQUtilityClass.createContacts(accntList, 1);
        insert contactList[0];
                
        // Insert Opportunities
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities(accntList, 1);
        opptyList[0].StageName ='3 - Solution Definition';
        opptyList[0].Type = 'Upsell/Crossell';
        opptyList[1].Type = 'New Business';
        opptyList[2].Type = 'Renewal';
        opptyList[2].ORC_Segment__c = 'CH';          
        insert opptyList;
        
        // Create Quote
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        quoteList = TestCPQUtilityClass.createQuotes(opptyList, 1);
        quoteList[0].New_Instance_or_Change_to_Existing__c = 'Change to Existing Instance';
        quoteList[0].Rubiks_Quote__c=true;
        quoteList[1].New_Instance_or_Change_to_Existing__c = 'New Instance';
        quoteList[1].Target_Number_of_Contact_Records__c = null;
        quoteList[1].Target_Number_of_Unique_Visitors__c = null;
        
        insert quoteList;
        
        List<Contract> contractList = new List<Contract>();
        contractList = TestCPQUtilityClass.createContracts(accntList, 1);
        for(Integer i=0; i<contractList.size(); i++){
            contractList[i].SBQQ__Opportunity__c = opptyList[1].Id;
            contractList[i].SBQQ__Quote__c=quoteList.get(0).id;
            contractList[i].SBQQ__PreserveBundleStructureUponRenewals__c = true;
            contractList[i].SBQQ__DefaultRenewalContactRoles__c = true;
            contractList[i].SBQQ__DefaultRenewalPartners__c = true;
            contractList[i].By_Pass_Contract_Workflow__c= true;
            //contractList[i].Status='Activated';
            contractList[i].startDate =system.today().adddays(-1);
            
        }   
        insert contractList;

        //Define Page
        PageReference pg = Page.newQuotePage;
        Test.setCurrentPageReference(pg);
        //Test.setCurrentPage(pg);
        pg.getParameters().put('oppid', opptyList[0].Id);
        pg.getParameters().put('accid', opptyList[0].AccountId);
        pg.getParameters().put('quoteType', 'Feature');
        
        test.startTest();
        // Initialise standard controller for scenario1
        ApexPages.StandardController stdController = new ApexPages.standardController(quoteList[0]);

        // call constructor
        newQuotePageExtenstion extObj =new newQuotePageExtenstion(stdController);
        extObj.checkForContractedRubiks();
        extObj.proceed();
        
        Test.stopTest();
    }

    public static testMethod void testSaveQuote(){
        // Insert Account
        List<Account> accntList = new List<Account>();
        accntList = TestCPQUtilityClass.createAccounts(5);
        insert accntList; 
        
        // Insert COntacts
        List<Contact> contactList = new List<Contact>();
        contactList = TestCPQUtilityClass.createContacts(accntList, 1);
        insert contactList[0];
                
        // Insert Opportunities
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities(accntList, 1);
        opptyList[0].StageName ='3 - Solution Definition';
        opptyList[0].Type = 'Upsell/Crossell';
        opptyList[1].Type = 'New Business';
        opptyList[2].Type = 'Renewal';
        opptyList[2].ORC_Segment__c = 'CH';          
        insert opptyList;
        
        
        
        List<Contract> contractList = new List<Contract>();
        contractList = TestCPQUtilityClass.createContracts(accntList, 1);
        for(Integer i=0; i<contractList.size(); i++){
            contractList[i].SBQQ__Opportunity__c = opptyList[1].Id;
            contractList[i].SBQQ__PreserveBundleStructureUponRenewals__c = true;
            contractList[i].SBQQ__DefaultRenewalContactRoles__c = true;
            contractList[i].SBQQ__DefaultRenewalPartners__c = true;
            contractList[i].By_Pass_Contract_Workflow__c= true;
            
        }   
        insert contractList;
        
        
        // Create Quote
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        quoteList = TestCPQUtilityClass.createQuotes(opptyList, 1);
        quoteList[0].New_Instance_or_Change_to_Existing__c = 'Change to Existing Instance';
        quoteList[1].New_Instance_or_Change_to_Existing__c = 'New Instance';
        quoteList[1].Target_Number_of_Contact_Records__c = null;
        quoteList[1].Target_Number_of_Unique_Visitors__c = null;
        //insert quoteList;
        
        //Define Page
        PageReference pg = Page.newQuotePage;
        Test.setCurrentPageReference(pg);
        //Test.setCurrentPage(pg);
        pg.getParameters().put('oppid', opptyList[0].Id);
        pg.getParameters().put('accid', opptyList[0].AccountId);
        pg.getParameters().put('quoteType', 'Feature');
        
        test.startTest();
        // Initialise standard controller for scenario1
        ApexPages.StandardController stdController = new ApexPages.standardController(quoteList[0]);
        
        
        
        // call constructor
        newQuotePageExtenstion extObj =new newQuotePageExtenstion(stdController);
        
         PageReference pgRefChangeType = Page.newQuotePage;
         quoteList[0].Opportunity_Type__c = 'New Business';
         pgRefChangeType = extObj.saveQuote();
         
        PageReference pgRef = Page.newQuotePage;
        pgRef = extObj.saveQuote();
        
        // Initialise standard controller for scenario2
        ApexPages.StandardController stdController2 = new ApexPages.standardController(quoteList[1]);
        
        // call constructor
        newQuotePageExtenstion extObj2 =new newQuotePageExtenstion(stdController2);
        PageReference pgRef2 = Page.newQuotePage;
        pgRef2 = extObj2.saveQuote();
        Test.stopTest();
        
         pg.getParameters().put('oppid', opptyList[2].Id);
        pg.getParameters().put('accid', opptyList[2].AccountId);
        // Initialise standard controller for scenario3
        ApexPages.StandardController stdController3 = new ApexPages.standardController(quoteList[2]);
        
        // call constructor
        newQuotePageExtenstion extObj3 =new newQuotePageExtenstion(stdController3);
        quoteList[2].Order_Type__c ='Internal';
        PageReference pgRef3 = Page.newQuotePage;
        pgRef3 = extObj3.saveQuote();
        
        PageReference pgRefrenewal = Page.newQuotePage;
        pgRefrenewal = extObj3.saveQuote();
        
        
    }
    
    public static testMethod void testSaveSolutionQuote(){
        // Insert Account
        List<Account> accntList = new List<Account>();
        accntList = TestCPQUtilityClass.createAccounts(5);
        insert accntList; 
        
        // Insert COntacts
        List<Contact> contactList = new List<Contact>();
        contactList = TestCPQUtilityClass.createContacts(accntList, 1);
        insert contactList[0];
                
        // Insert Opportunities
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities(accntList, 1);
        opptyList[0].StageName ='3 - Solution Definition';
        opptyList[0].Type = 'Upsell/Crossell';
        opptyList[1].Type = 'New Business';
        opptyList[2].Type = 'Renewal';
        opptyList[2].ORC_Segment__c = 'CH';          
        insert opptyList;
        
        
        
        List<Contract> contractList = new List<Contract>();
        contractList = TestCPQUtilityClass.createContracts(accntList, 1);
        for(Integer i=0; i<contractList.size(); i++){
            contractList[i].SBQQ__Opportunity__c = opptyList[1].Id;
            contractList[i].SBQQ__PreserveBundleStructureUponRenewals__c = true;
            contractList[i].SBQQ__DefaultRenewalContactRoles__c = true;
            contractList[i].SBQQ__DefaultRenewalPartners__c = true;
            contractList[i].By_Pass_Contract_Workflow__c= true;
            
        }   
        insert contractList;
        
        
        // Create Quote
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        quoteList = TestCPQUtilityClass.createQuotes(opptyList, 1);
        quoteList[0].New_Instance_or_Change_to_Existing__c = 'Change to Existing Instance';
        quoteList[1].New_Instance_or_Change_to_Existing__c = 'New Instance';
        quoteList[1].Target_Number_of_Contact_Records__c = null;
        quoteList[1].Target_Number_of_Unique_Visitors__c = null;
        //insert quoteList;
        
        //Define Page
        PageReference pg = Page.newQuotePage;
        Test.setCurrentPageReference(pg);
        //Test.setCurrentPage(pg);
        pg.getParameters().put('oppid', opptyList[0].Id);
        pg.getParameters().put('accid', opptyList[0].AccountId);
        pg.getParameters().put('quoteType', 'Solution');
        
        test.startTest();
        // Initialise standard controller for scenario1
        ApexPages.StandardController stdController = new ApexPages.standardController(quoteList[0]);
        
        
        
        // call constructor
        newQuotePageExtenstion extObj =new newQuotePageExtenstion(stdController);
        
         PageReference pgRefChangeType = Page.newQuotePage;
         quoteList[0].Opportunity_Type__c = 'New Business';
         pgRefChangeType = extObj.saveQuote();
         
        PageReference pgRef = Page.newQuotePage;
        pgRef = extObj.saveQuote();
        
        // Initialise standard controller for scenario2
        ApexPages.StandardController stdController2 = new ApexPages.standardController(quoteList[1]);
        
        // call constructor
        newQuotePageExtenstion extObj2 =new newQuotePageExtenstion(stdController2);
        PageReference pgRef2 = Page.newQuotePage;
        pgRef2 = extObj2.saveQuote();
        Test.stopTest();
        
         pg.getParameters().put('oppid', opptyList[2].Id);
        pg.getParameters().put('accid', opptyList[2].AccountId);
        // Initialise standard controller for scenario3
        ApexPages.StandardController stdController3 = new ApexPages.standardController(quoteList[2]);
        
        // call constructor
        newQuotePageExtenstion extObj3 =new newQuotePageExtenstion(stdController3);
        quoteList[2].Order_Type__c ='Internal';
        PageReference pgRef3 = Page.newQuotePage;
        pgRef3 = extObj3.saveQuote();
        
        PageReference pgRefrenewal = Page.newQuotePage;
        pgRefrenewal = extObj3.saveQuote();
        
        
    }
     public static testMethod void testUpsellOpptyQuote(){
        // Insert Account
        List<Account> accntList = new List<Account>();
        accntList = TestCPQUtilityClass.createAccounts(1);
        insert accntList; 
        
        // Insert COntacts
        List<Contact> contactList = new List<Contact>();
        contactList = TestCPQUtilityClass.createContacts(accntList, 1);
        insert contactList[0];
                
        // Insert Opportunities
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities(accntList, 1);
        opptyList[0].StageName ='3 - Solution Definition';
        opptyList[0].Type = 'Upsell/Crossell';
            
        insert opptyList;
  
        // Create Quote
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        quoteList = TestCPQUtilityClass.createQuotes(opptyList, 2);
        quoteList[0].New_Instance_or_Change_to_Existing__c = 'Change to Existing Instance';
       
        
        //Define Page
        PageReference pg = Page.newQuotePage;
        Test.setCurrentPageReference(pg);
        //Test.setCurrentPage(pg);
        pg.getParameters().put('oppid', opptyList[0].Id);
        pg.getParameters().put('accid', opptyList[0].AccountId);
        pg.getParameters().put('quoteType', 'Feature');
        
        test.startTest();
        // Initialise standard controller for scenario1
        ApexPages.StandardController stdController = new ApexPages.standardController(quoteList[0]);
        
        
        
        // call constructor
        newQuotePageExtenstion extObj =new newQuotePageExtenstion(stdController);
       
        PageReference pgRefNoContract = Page.newQuotePage;
        pgRefNoContract = extObj.saveQuote();
         List<Contract> contractList = new List<Contract>();
        contractList = TestCPQUtilityClass.createContracts(accntList, 1);
        for(Integer i=0; i<contractList.size(); i++){
            contractList[i].SBQQ__Opportunity__c = opptyList[0].Id;
            contractList[i].SBQQ__PreserveBundleStructureUponRenewals__c = true;
            contractList[i].SBQQ__DefaultRenewalContactRoles__c = true;
            contractList[i].SBQQ__DefaultRenewalPartners__c = true;
            contractList[i].By_Pass_Contract_Workflow__c= true;
            
        }   
        insert contractList;
        
        
        // Initialise standard controller for scenario2
        ApexPages.StandardController stdController2 = new ApexPages.standardController(quoteList[1]);
        newQuotePageExtenstion extContractObj =new newQuotePageExtenstion(stdController2);
        PageReference pgRefContract = Page.newQuotePage;
        pgRefContract = extObj.saveQuote();
     
    }
}