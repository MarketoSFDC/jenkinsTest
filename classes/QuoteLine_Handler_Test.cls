@IsTest

public class QuoteLine_Handler_Test{

	public static testMethod void Test_QuoteLine_Handler(){
 
      List<Account> accountsToBeInsertedList = new List<Account>();
      accountsToBeInsertedList = TestCPQUtilityClass.createAccounts(1);
      
      insert accountsToBeInsertedList;
      //Insert priceBook record
       list<priceBook2> priceBooksList =TestCPQUtilityClass.createCustomPriceBooks(1);
        if(!priceBooksList.isEmpty()){
            insert priceBooksList ;
        }
        
        //Insert opportunity record
       list<opportunity> opportunityList =TestCPQUtilityClass.createOpportunities(accountsToBeInsertedList ,1);
        for(integer i=0;i<opportunityList.size();i++){
            opportunityList[i].Pricebook2Id=priceBooksList[0].id;
        }
        if(!opportunityList.isEmpty()){
            insert opportunityList;    
        }
        
        
        //Insert products record
        list<product2> productsToInsertList =TestCPQUtilityClass.createCustomProducts(4);
        if(!productsToInsertList.isEmpty()){
            insert productsToInsertList;    
        }
        
        id pbId = Test.getStandardPricebookId();
        TestCPQUtilityClass.createStdPricebookEntries(productsToInsertList,pbid);
        
        //Insert priceBookEntry record
        list<priceBookEntry> priceBookEntryList =TestCPQUtilityClass.createPriceBookEntries(productsToInsertList ,priceBooksList );
        if(!priceBookEntryList.isEmpty()){
            insert priceBookEntryList ;
        }
             
             
        
        list<Contract> newContractList =TestCPQUtilityClass.createContracts(accountsToBeInsertedList,1);
        insert newContractList;
        
        list<SBQQ__Quote__c> newQuotList = TestCPQUtilityClass.createQuotesWithMasterContracts(opportunityList,1,newContractList[0]);
        insert newQuotList;
        
        test.startTest();
        list<SBQQ__Subscription__c> InsertsubList =    new list<SBQQ__Subscription__c>();
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c(SBQQ__Contract__c=newContractList[0].Id,SBQQ__Account__c=accountsToBeInsertedList[0].Id,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productsToInsertList[0].Id);
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c(SBQQ__Contract__c=newContractList[0].Id,SBQQ__Account__c=accountsToBeInsertedList[0].Id,SBQQ__Quantity__c=3, SBQQ__TerminatedDate__c=System.today().addMonths(4),SBQQ__ProrateMultiplier__c = 1.1234, SBQQ__Product__c =productsToInsertList[1].Id);
        InsertsubList.add(sub1);
        InsertsubList.add(sub2);
        insert InsertsubList;
       
        // Insert Quote Lines
       list<SBQQ__QuoteLine__c> quoteLines=TestCPQUtilityClass.createQuoteLines(newQuotList,1,productsToInsertList);
       insert quoteLines;
        
        list<SBQQ__QuoteLine__c> childquoteLines=TestCPQUtilityClass.createQuoteLines(newQuotList,1,productsToInsertList);
        childquoteLines[0].SBQQ__RequiredBy__c = quoteLines[0].id;
        
        insert childquoteLines;
        test.stopTest();
	}

}