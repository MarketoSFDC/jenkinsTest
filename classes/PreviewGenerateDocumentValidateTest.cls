@IsTest
class PreviewGenerateDocumentValidateTest{
    static testMethod void testValidateGenerateDocument(){
    	List<SBQQ__QuoteLine__c> quotelineList = new List<SBQQ__QuoteLine__c>();
        
        Account a = Utility.insertAccountInTestClasses();   
        a.BillingCountry = 'United States';
        a.BillingStreet = 'Test Street';
        a.BillingState ='Test Billing State';
        a.BillingPostalCode ='12345';
        a.ShippingCity ='Pune';
        a.ShippingCountry ='India';
        a.ShippingPostalCode = '12345';
        a.ShippingState = '';
        a.ShippingStreet = 'Test Shipping Street';     
        insert a;
        
        Contact c = Utility.insertContactInTestClasses(a.Id);
        insert c;
        
        Opportunity Opp = Utility.insertOpportunityInTestClasses(a.id, c.Id, 'Closed Won', 'Renewal',Date.Today(), system.today().addDays(1),system.today().addDays(7), null);        
        insert Opp;
        
        // insert records for custom setting Products_Operational_Services__c
        Products_Operational_Services__c osp1 = new Products_Operational_Services__c();
        osp1.Name = 'Account String Change';
        osp1.Product_Code__c ='SVC-TECH-STRING';
		insert osp1;
        
        Products_Operational_Services__c osp2 = new Products_Operational_Services__c();
        osp2.Name = 'Convert Production to Sandbox';
        osp2.Product_Code__c ='SVC-TECH-CONV-PROD-SNBX';
		insert osp2;
        
        // Insert Products
        List<Product2> ProList = new List<Product2>();  
        Product2 p =new Product2(Name='test pro',IsActive = true,ConvertTo__c = 'Subscription',family='Dedicated IP',ProductCode='SVC-TECH-CONV-PROD-SNBX');
        ProList.add(p);
        Product2 p2 =new Product2(Name='test pro2',IsActive = true,ConvertTo__c = 'Add On',family='Dedicated IP', ProductCode='SVC-TECH-STRING');
        ProList.add(p2);
        Product2 p3 =new Product2(Name='test pro3',IsActive = true,ConvertTo__c = 'Entitlement-Spark',family='Dedicated IP', ProductCode='abc');
        ProList.add(p3);
        Product2 p4 =new Product2(Name='test pro4',IsActive = true,ConvertTo__c = 'Entitlement-Spark',family='Dedicated IP', ProductCode='xyz');
        ProList.add(p4);
        insert ProList;
        
        // Create Quote
		List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        SBQQ__Quote__c testQuote = new SBQQ__Quote__c(SBQQ__Opportunity2__c = Opp.Id, SBQQ__StartDate__c = System.Today());
		testQuote.Acct_Prefix_Requested__c = 'Test 123';
		testQuote.SBQQ__BillingState__c = 'Maharashtra';
		testQuote.SBQQ__ShippingCountry__c = 'India';
		quoteList.add(testQuote);
        
        SBQQ__Quote__c testQuote2 = new SBQQ__Quote__c(SBQQ__Opportunity2__c = Opp.Id, SBQQ__StartDate__c = System.Today());
		quoteList.add(testQuote2);
		
		SBQQ__Quote__c testQuote3 = new SBQQ__Quote__c(SBQQ__Opportunity2__c = Opp.Id, SBQQ__StartDate__c = System.Today());
        quoteList.add(testQuote3);
		
		insert quoteList;
        
        // insert Quote Line
        SBQQ__QuoteLine__c qtLine1 = new SBQQ__QuoteLine__c();
        qtLine1.SBQQ__Quote__c = testQuote.Id;
        qtLine1.SBQQ__Product__c = p.Id;
        quotelineList.add(qtLine1);
        
        SBQQ__QuoteLine__c qtLine2 = new SBQQ__QuoteLine__c();
        qtLine2.SBQQ__Quote__c = testQuote.Id;
        qtLine2.SBQQ__Product__c = p.Id;
        quotelineList.add(qtLine2);
		
		SBQQ__QuoteLine__c qtLine3 = new SBQQ__QuoteLine__c();
        qtLine3.SBQQ__Quote__c = quoteList[2].Id;
        qtLine3.SBQQ__Product__c = p4.Id;
        quotelineList.add(qtLine3);
        
        insert quotelineList;
        
        // insert records for custom setting Quote_Document_Validation_Fields__c
        Quote_Document_Validation_Fields__c dvf1 = new Quote_Document_Validation_Fields__c();
        dvf1.Name = 'Acct Prefix Requested';
        dvf1.Field_API_Name__c  = 'Acct_Prefix_Requested__c';
        dvf1.Operational_Services_Field__c = true;
		insert dvf1;
        
        Quote_Document_Validation_Fields__c dvf2 = new Quote_Document_Validation_Fields__c();
        dvf2.Name = 'Bill To City';
        dvf2.Field_API_Name__c  = 'SBQQ__PrimaryContact__c';
        dvf2.Operational_Services_Field__c = false;
        insert dvf2;
              
        PreviewGenerateDocumentValidate.validateGenerateDocument(quoteList[0].Id);
		
		PreviewGenerateDocumentValidate.validateGenerateDocument(quoteList[1].Id);
		
		PreviewGenerateDocumentValidate.validateGenerateDocument(quoteList[2].Id);	
        
    }
}