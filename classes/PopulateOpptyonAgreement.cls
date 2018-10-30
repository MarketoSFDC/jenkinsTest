global class PopulateOpptyonAgreement{
    webservice static String processOpptyID(String oppId, String accId, String OppName){
        echosign_dev1__SIGN_Agreement__c echoAgr = new echosign_dev1__SIGN_Agreement__c(
        echosign_dev1__More_Recipients__c = System.Label.EchoSignEmailRecipients,
        Name = oppName,
        echosign_dev1__Opportunity__c = oppId,
        echosign_dev1__Account__c = accId
        );
        List<echosign_dev1__Agreement_Template__c> agrTemp = new List<echosign_dev1__Agreement_Template__c>([SELECT Id, echosign_dev1__Email_Copy_To__c, Name FROM echosign_dev1__Agreement_Template__c LIMIT 1]);
        if(!agrTemp.isEmpty()){
            if(agrTemp[0].echosign_dev1__Email_Copy_To__c != null){
                echoAgr.echosign_dev1__Cc__c = agrTemp[0].echosign_dev1__Email_Copy_To__c;
            }
        }
        insert echoAgr;
    return echoAgr.Id;
    }
    
    public static testMethod void POAgreementTestMethod1(){
        test.startTest();
        Account acc = Utility.insertAccountInTestClasses();
        insert acc;
        Opportunity opp = new Opportunity(Name = 'Test Opportunity', AccountId = acc.id, StageName = 'Not Contacted', type = 'Renewal', CloseDate=System.Today());
        insert opp;
        Product2 prod = UtilityToCreateTestData.insertProduct();
        PriceBookEntry pbe2 = new PriceBookEntry (Product2Id =prod.Id, PriceBook2Id = Test.getStandardPricebookId(), UnitPrice = 10, isActive = TRUE, CurrencyIsoCode = 'USD');
        insert pbe2;
        Asset NewAs = new Asset(Name='Test',AccountId=acc.Id,Maximum_Database_Size__c=10000,Munchkin_ID__c='123-ABC', Product2Id =prod.Id);
        insert NewAs;
        OpportunityLineItem oliTest = new OpportunityLineItem();
        oliTest.OpportunityId = opp.Id;
        oliTest.PricebookEntryId = pbe2.Id; 
        oliTest.UnitPrice = 1234.00; 
        oliTest.Quantity = 2;
        insert oliTest;
        PopulateOpptyonAgreement.processOpptyID(opp.Id, acc.Id, Opp.Name);
        test.stopTest();
    }
}