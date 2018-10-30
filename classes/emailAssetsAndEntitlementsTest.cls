@IsTest
public Class emailAssetsAndEntitlementsTest{
    public static testMethod void testEmailAssetsAndEntitlement(){      
        // Insert Oppty
        List<Account> accntList = new List<Account>();
        accntList = TestCPQUtilityClass.createAccounts(5);
        for(Account accnt :accntList){
            accnt.Acct_Prefix__c = 'Test Accnt Prefix';
            accnt.POD__c = 'Other123';
            accnt.Munchkin_ID__c = 'Test123';
        }   
        if(!accntList.isEmpty()){
            insert accntList;
        }
        
        List<Contact> contactList = new List<Contact>();
        contactList = TestCPQUtilityClass.createContacts(accntList, 1);
        contactlist[0].pse__Salesforce_User__c=null;
        if(!contactList.isEmpty()){
            insert contactList[0];
        }
        
        // Insert Product
        List<Product2> prodList = new List<Product2>();
        prodList = TestCPQUtilityClass.createCustomProducts(5);
        if(!prodList.isEmpty()){
            insert prodList;
        }
        
        // Add product into standard pricebook
        Id stdPricebookId = Test.getStandardPricebookId();
        
        List<PricebookEntry> stdPBEntryList = new List<PricebookEntry>();
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = stdPricebookId, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            stdPBEntryList.add(pbEntry);   
        }
        insert stdPBEntryList;
        
        // add products into custom pricebook
        PriceBook2 customPB = new PriceBook2(name='Test Custom PriceBook', isActive=TRUE);
        insert customPB;
        
        List<PricebookEntry> customPBEntryList = new List<PricebookEntry>();
        for(Integer i=0; i<prodList.size(); i++){
            PricebookEntry pbEntry = new PricebookEntry(Pricebook2Id = customPB.Id, Product2Id = prodList[i].Id,UnitPrice = 10000, IsActive = true);
            customPBEntryList.add(pbEntry);   
        }
        insert customPBEntryList;
        
        List<Opportunity> oppList = new List<Opportunity>();
        oppList = TestCPQUtilityClass.createOpportunities(accntList, 1);
        if(!oppList.isEmpty()){
            insert oppList;
        }
        
        // Insert Asset
        List<Asset> assetList = new List<Asset>();
        Asset as1 = new Asset();
        as1.Name = 'Test Asset 1';
        as1.installdate = System.today();
        as1.UsageEndDate = System.today().addMonths(2);
        as1.Opportunity__c = oppList[0].Id;
        as1.AccountId = accntList[0].Id;
        as1.ContactId = contactList[0].Id;
        
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 2';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Opportunity__c = oppList[0].Id;
        as2.AccountId = accntList[0].Id;
        as2.ContactId = contactList[0].Id;
        
        assetList.add(as1);
        assetList.add(as2);
        if(!assetList.isEmpty()){
            insert assetList;
        }
        
        Integer instanceNumber = 123;      
        
        // Create a new email, envelope object and Attachment
        Messaging.InboundEmail email = new Messaging.InboundEmail();
        Messaging.InboundEnvelope envelope = new Messaging.InboundEnvelope();       
        email.subject = 'Test Subject';
        email.fromName = 'test test';
        email.plainTextBody = 'Opportunity ID:' + oppList[0].Id + ' Product Code:' + prodList[0].ProductCode + ' Instance Number:' +  instanceNumber + ' Asset:' + assetList[0].Id + ' Munchkin ID:' + accntList[0].Munchkin_ID__c + ' Account Prefix:' + accntList[0].Acct_Prefix__c + 'TestAcc' + ' POD:' + accntList[0].POD__c;
        System.debug('body==========>' + email.plainTextBody);
        envelope.fromAddress = 'user@acme.com';
        
        // setup controller object
        emailAssetsAndEntitlements catcher = new emailAssetsAndEntitlements();
        Messaging.InboundEmailResult result = catcher.handleInboundEmail(email, envelope);
        System.assertEquals( result.success  ,true);    
    }
}