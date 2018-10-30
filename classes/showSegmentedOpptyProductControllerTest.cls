@IsTest

public class showSegmentedOpptyProductControllerTest{

public static testMethod void testshowSegmentedOpptyProduc(){
 
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
        
     
   
       List<Opportunity> OpptyToBeInsertedList = new List<Opportunity>();
        OpptyToBeInsertedList = TestCPQUtilityClass.createOpportunities(accountsToBeInsertedList,1);
        OpptyToBeInsertedList[0].StageName            = '3 - Solution Definition';
        OpptyToBeInsertedList[0].PriceBook2Id         = priceBookList[0].id;
        OpptyToBeInsertedList[0].Quarterly_Renewal__c = string.valueof(2);
        OpptyToBeInsertedList[0].type                 = 'New Business';
        OpptyToBeInsertedList[0].Deal_Type__c         = 'Standard';
  
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
              
          }
  insert quotesToBeInsertedList;
   system.debug('quotesToBeInsertedList'+quotesToBeInsertedList);
       
        List<SBQQ__QuoteLine__c> quoteLinesToInsert = new List<SBQQ__QuoteLine__c>();
     
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6),SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=6);
        
        
         SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c( SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6).addDays(1),SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__EndDate__c,SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=6); 
         
         SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6),SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=6);
         
         SBQQ__QuoteLine__c quoteLine3 = new SBQQ__QuoteLine__c( SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6).addDays(1),SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__EndDate__c,SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=6);
         
         SBQQ__QuoteLine__c quoteLine4 = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=true,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[0].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6),SBQQ__SegmentLabel__c='Seg1',MKTO_Effective_Term__c=6);
         
          SBQQ__QuoteLine__c quoteLine5 = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=true,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[0].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6).addDays(1),SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__SegmentLabel__c='Seg2',MKTO_Effective_Term__c=6);
          
       
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
       
          
           OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[1].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[0].Id,Segment_Start_Date__c=quoteLinesToInsert[0].SBQQ__StartDate__c,Users__c=1,Create_Asset__c=true);           
               
            OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[1].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[1].Id,Segment_Start_Date__c=quoteLinesToInsert[1].SBQQ__StartDate__c,Users__c=1,Create_Asset__c=true);
            
             OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[2].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[2].Id,Segment_Start_Date__c=quoteLinesToInsert[2].SBQQ__StartDate__c,Users__c=1,Create_Asset__c=true);
             
             OpportunityLineItem oli4 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[2].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[3].Id,Segment_Start_Date__c=quoteLinesToInsert[3].SBQQ__StartDate__c,Users__c=1,Create_Asset__c=true);
              
             OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[0].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[4].Id,Segment_Start_Date__c=quoteLinesToInsert[4].SBQQ__StartDate__c,Users__c=1);
             
              OpportunityLineItem oli5 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[0].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[4].Id,Segment_Start_Date__c=quoteLinesToInsert[5].SBQQ__StartDate__c,Users__c=1);
            
         
            OLIListToBeInserted.add(oli1);
            OLIListToBeInserted.add(oli2);
            OLIListToBeInserted.add(oli3);
            OLIListToBeInserted.add(oli4);
            OLIListToBeInserted.add(oli);
            OLIListToBeInserted.add(oli5);
            if(!OLIListToBeInserted.isEmpty()){
            insert OLIListToBeInserted;
            }
            
          OpptyToBeInsertedList[0].Migration__c = true; 
          OpptyToBeInsertedList[0].StageName = 'Signed Order';
          OpptyToBeInsertedList[0].Needs_Pains__c = 'oppty';
          OpptyToBeInsertedList[0].Use_Case__c = 'B2B';
          update OpptyToBeInsertedList;
         
        
          OpptyToBeInsertedList[0].Migration__c = false;
          OpptyToBeInsertedList[0].StageName            = 'Closed Won';
          OpptyToBeInsertedList[0].SBQQ__Contracted__c=true;
          OpptyToBeInsertedList[0].SBQQ__PrimaryQuote__c=quotesToBeInsertedList[0].id;
          update OpptyToBeInsertedList;
          system.debug('OpptyToBeInsertedList Updated Opp'+OpptyToBeInsertedList);
      
          
        // Create Contract
        Contract contrct = new Contract(Name='Test Contract ',SBQQ__Quote__c=quotesToBeInsertedList[0].id, AccountId=accountsToBeInsertedList[0].Id, SBQQ__Opportunity__c =OpptyToBeInsertedList[0].Id, ContractTerm = 12, SBQQ__RenewalForecast__c = true, SBQQ__PreserveBundleStructureUponRenewals__c = true, SBQQ__DefaultRenewalContactRoles__c = true, SBQQ__DefaultRenewalPartners__c = true, StartDate=quotesToBeInsertedList.get(0).SBQQ__StartDate__c);
        insert contrct; 
        contrct.Status='Activated';
        update contrct;
           
        List<SBQQ__Subscription__c> subList = new List<SBQQ__Subscription__c>();
        
         SBQQ__Subscription__c sub = new SBQQ__Subscription__c();        
        sub.SBQQ__Product__c = productToInsertList[0].Id;
        sub.SBQQ__Account__c = accountsToBeInsertedList[0].Id;
        sub.SBQQ__Quantity__c = 4.0;
        sub.SBQQ__Contract__c=contrct.id;
        sub.SBQQ__QuoteLine__c=quoteLinesToInsert[5].id;
        subList.add(sub);
    
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c();        
        sub1.SBQQ__Product__c = productToInsertList[1].Id;
        sub1.SBQQ__Account__c = accountsToBeInsertedList[0].Id;
        sub1.SBQQ__Quantity__c = 4.0;
        sub1.SBQQ__Contract__c=contrct.id;
        sub1.SBQQ__QuoteLine__c=quoteLinesToInsert[0].id;
        subList.add(sub1);
        
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c();        
        sub2.SBQQ__Product__c = productToInsertList[2].Id;
        sub2.SBQQ__Account__c = accountsToBeInsertedList[0].Id;
        sub2.SBQQ__Quantity__c = 4.0;
        sub2.SBQQ__Contract__c=contrct.id;
        sub1.SBQQ__QuoteLine__c=quoteLinesToInsert[2].id;
        subList.add(sub2);
        
        
        insert subList;
        
        
        
        showSegmentedOpptyProductController s=new showSegmentedOpptyProductController();
        Id OLIID=OLIListToBeInserted[2].id;
        system.assertEquals(OLIID,OLIListToBeInserted[2].id);
        s.setopportunityLineId(OLIID);
        s.opportunityLineId =OLIListToBeInserted[2].id;
        
      
}

}