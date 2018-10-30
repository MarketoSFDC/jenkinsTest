@IsTest

public class createSandboxAssetForMDQTest{

public static testMethod void testcreateSandboxAssetForMDQ(){
 
  List<Account> accountsToBeInsertedList = new List<Account>();
  accountsToBeInsertedList = TestCPQUtilityClass.createAccounts(1);
  
  insert accountsToBeInsertedList;
    
  List<Product2> productToInsertList = new List<Product2>();
  productToInsertList = TestCPQUtilityClass.createCustomProducts(3);
        productToInsertList[0].ProductCode ='PARENT';
        productToInsertList[1].ProductCode = 'PROD-PLAT-SANDBOX';
        productToInsertList[2].ProductCode = 'PROD-PLAT-SANDBOX-INST';
      
        if(!productToInsertList.isEmpty()){
            productToInsertList[0].Family ='Bundle';
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
        OpptyToBeInsertedList[0].Rep_Create_ARR__c         = 1;
  
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
     
        SBQQ__QuoteLine__c quoteLine = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6),SBQQ__SegmentLabel__c='Seg1');
        
        
         SBQQ__QuoteLine__c quoteLine1 = new SBQQ__QuoteLine__c( SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[1].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6).addDays(1),SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__EndDate__c,SBQQ__SegmentLabel__c='Seg2'); 
         
         SBQQ__QuoteLine__c quoteLine2 = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6),SBQQ__SegmentLabel__c='Seg1');
         
         SBQQ__QuoteLine__c quoteLine3 = new SBQQ__QuoteLine__c( SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=false,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[2].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6).addDays(1),SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__EndDate__c,SBQQ__SegmentLabel__c='Seg2');
         
         SBQQ__QuoteLine__c quoteLine4 = new SBQQ__QuoteLine__c(  SBQQ__Quote__c=quotesToBeInsertedList.get(0).Id,SBQQ__Quantity__c=1,SBQQ__Bundle__c=true,SBQQ__OptionLevel__c=0,SBQQ__Product__c=productToInsertList[0].id,SBQQ__RegularPrice__c  = 1000,SBQQ__CustomerPrice__c  = 500,SBQQ__StartDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c,SBQQ__EndDate__c=quotesToBeInsertedList.get(0).SBQQ__StartDate__c.addMonths(6),SBQQ__SegmentLabel__c='Seg1');
          
       
        quoteLinesToInsert.add(quoteLine);
        quoteLinesToInsert.add(quoteLine1);
        quoteLinesToInsert.add(quoteLine2);
        quoteLinesToInsert.add(quoteLine3);
        quoteLinesToInsert.add(quoteLine4);
          Test.StartTest();
         insert quoteLinesToInsert;
         Test.StopTest();
         
         system.debug('quoteLinesToInsert#######'+quoteLinesToInsert);
         List<ProductDetails__c> ProdDetailsList=new List<ProductDetails__c>();
         
          ProductDetails__c obj1 = new ProductDetails__c(Name='Sandbox',ID__c = productToInsertList[1].Id,Product_Code__c ='PROD-PLAT-SANDBOX');
            
            ProductDetails__c obj2 = new ProductDetails__c(Name='Sandbox Instance',ID__c = productToInsertList[2].Id,Product_Code__c = 'PROD-PLAT-SANDBOX-INST');
            
            ProdDetailsList.add(obj1);
             ProdDetailsList.add(obj2);
             insert ProdDetailsList;
                   
           List<OpportunityLineItem> OLIListToBeInserted=new List<OpportunityLineItem>();       
       
          
           OpportunityLineItem oli1 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[1].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[0].Id,Create_Asset__c=false,Segment_Start_Date__c=quoteLinesToInsert[0].SBQQ__StartDate__c);           
               
            OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[1].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[1].Id,Create_Asset__c=false,Segment_Start_Date__c=quoteLinesToInsert[1].SBQQ__StartDate__c.addMonths(6).addDays(1));
            
             OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[2].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[2].Id,Create_Asset__c=false,Segment_Start_Date__c=quoteLinesToInsert[2].SBQQ__StartDate__c);
             
             OpportunityLineItem oli4 = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[2].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[3].Id,Create_Asset__c=false,Segment_Start_Date__c=quoteLinesToInsert[3].SBQQ__StartDate__c.addMonths(6).addDays(1));
              
             OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = OpptyToBeInsertedList[0].Id, PricebookEntryId = pbEntryCustPbList[0].Id, UnitPrice = 10, Quantity = 20,SBQQ__QuoteLine__c=quoteLinesToInsert[4].Id,Create_Asset__c=false);
            
         
            OLIListToBeInserted.add(oli1);
            OLIListToBeInserted.add(oli2);
            OLIListToBeInserted.add(oli3);
            OLIListToBeInserted.add(oli4);
            OLIListToBeInserted.add(oli);
            if(!OLIListToBeInserted.isEmpty()){
            insert OLIListToBeInserted;
            }
            
               
        
            Map<Id,OpportunityLineItem> OLIMap=new Map<Id,OpportunityLineItem>();
            set<Id> OLIId=new set<Id>();
             if(!OLIListToBeInserted.isEmpty()){
            for(OpportunityLineItem o:OLIListToBeInserted){
                OLIId.add(o.id);
            }
            }   
            for(OpportunityLineItem O:OLIListToBeInserted){
                    OLIMap.put(O.Id,O);
             }      
            
           List<OpportunityLineItem> OL=[select id,SBQQ__QuoteLine__c,OpportunityId,unitprice,Create_Asset__c,Segment_Start_Date__c from OpportunityLineItem where ID IN :OLIId ];            
          
          for(OpportunityLineItem o:OL){
                o.Create_Asset__c=true;
            }
            
            if(!OL.isEmpty()){
                             
                update OL;
                
            }  
            OpptyToBeInsertedList[0].StageName  = 'Signed Order';
           OpptyToBeInsertedList[0].Use_Case__c =  'B2B';
           OpptyToBeInsertedList[0].Needs_Pains__c ='OPPTY';
		   OpptyToBeInsertedList[0].Migration__c = true;
           update OpptyToBeInsertedList;
          
          OpptyToBeInsertedList[0].StageName = 'Closed Won';
		  OpptyToBeInsertedList[0].Migration__c = false;
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
    
        SBQQ__Subscription__c sub1 = new SBQQ__Subscription__c();        
        sub1.SBQQ__Product__c = productToInsertList[1].Id;
        sub1.SBQQ__Account__c = accountsToBeInsertedList[0].Id;
        sub1.SBQQ__Quantity__c = 4.0;
        sub1.SBQQ__Contract__c=contrct.id;
        subList.add(sub1);
        
        SBQQ__Subscription__c sub2 = new SBQQ__Subscription__c();        
        sub2.SBQQ__Product__c = productToInsertList[2].Id;
        sub2.SBQQ__Account__c = accountsToBeInsertedList[0].Id;
        sub2.SBQQ__Quantity__c = 4.0;
        sub2.SBQQ__Contract__c=contrct.id;
        subList.add(sub2);
        
        
        insert subList;
         set<Id> SubId=new set<Id>();
        for(SBQQ__Subscription__c s:subList){
        SubId.add(s.Id);
    
        }
        Set<Date> segmentStartdate = new Set<Date>();
        set<String> ProdCod=new set<string>();
        for(ProductDetails__c p:ProdDetailsList){
        ProdCod.add(p.Product_Code__c);
        }
        for(OpportunityLineItem o:OL){
        segmentStartdate.add(o.Segment_Start_Date__c);
        }
      createSandboxAssetForMDQ.createAsset(OL,OLIMap);
}

}