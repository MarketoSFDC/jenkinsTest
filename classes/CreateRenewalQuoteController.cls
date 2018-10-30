public class CreateRenewalQuoteController{

    public CreateRenewalQuoteController(ApexPages.StandardSetController controller){
    
    }
    
    public PageReference init(){
        List<Opportunity> opp = new List<Opportunity>([select id, AccountId, StageName, Name,Payment_Frequency__c,Payment_Terms__c, 
                          Prior_Opportunity__c, Prior_Opportunity__r.Payment_Frequency__c,
                          Prior_Opportunity__r.Payment_Terms__c, Sub_Start_Date__c, maximum_database_size__c,Sub_End_Date__c,
                          (SELECT PricebookEntry.Product2.Record_Limitation__c from OpportunityLineItems where PricebookEntry.Product2.Product_Type__c = 'Subscription')
                          from Opportunity where Id=: ApexPages.currentPage().getParameters().get('Id')]);
                          
        if(!opp.isEmpty()){
           String renewalRecordTypeId = Quote.sObjectType.getDescribe().getRecordTypeInfosByName().get('Renewal').getRecordTypeId();
           Opportunity currentOpp = opp[0];
           String paymentFrequency ='';
           String paymentTerms = '';
           String expiryDate ='';
           String oldQuoteOpportunityId = '';
           String MarketingPermission = 'None';
           List<Opportunity> priorOpp = new List<Opportunity>();
           
           if(currentOpp.Prior_Opportunity__c == null && currentOpp.Sub_Start_Date__c != null){
              priorOpp = new List<Opportunity>([select Id, Payment_Frequency__c, Payment_Terms__c, (select Customer_gives_Marketing_Permission__c from Quotes where IsSyncing =: true AND Customer_gives_Marketing_Permission__c != null limit 1) 
                                                from Opportunity where AccountId =: currentOpp.AccountId and (Sub_End_Date__c=: currentOpp.Sub_Start_Date__c.addDays(-1) OR Sub_End_Date__c=: currentOpp.Sub_Start_Date__c ) limit 1]);
           }
           
           //DEFINE OLD QUOTE'S OPPTY          
           if(currentOpp.StageName == 'Closed Won'){
               oldQuoteOpportunityId = currentOpp.Id;
           }else if(currentOpp.Prior_Opportunity__c != null){
               oldQuoteOpportunityId = currentOpp.Prior_Opportunity__c;
           }else{
               system.debug('priorOpp ===='+currentOpp.AccountId+'=='+currentOpp.Sub_End_Date__c);               
               system.debug(priorOpp+'priorOpp ====');
               if(!priorOpp.isEmpty() && !priorOpp[0].Quotes.isEmpty() && priorOpp[0].Quotes[0].Customer_gives_Marketing_Permission__c != null) {
                   MarketingPermission  = EncodingUtil.urlEncode(priorOpp[0].Quotes[0].Customer_gives_Marketing_Permission__c, 'UTF-8');
               }
           }
           system.debug(MarketingPermission +'MarketingPermission  ====');           
           if(oldQuoteOpportunityId != ''){
               List<Quote> oldQuote = new List<Quote>([select Customer_gives_Marketing_Permission__c from Quote where OpportunityId = : oldQuoteOpportunityId and IsSyncing =: true and Customer_gives_Marketing_Permission__c != NULL limit 1]);
               if(!oldQuote.isEmpty() && oldQuote[0].Customer_gives_Marketing_Permission__c != null)
               MarketingPermission  = EncodingUtil.urlEncode(oldQuote[0].Customer_gives_Marketing_Permission__c, 'UTF-8');
           }
           
           //payment frequency
           if(currentOpp.StageName=='Closed Won'){
               if(currentOpp.Payment_Frequency__c!= null)
                   paymentFrequency = currentOpp.Payment_Frequency__c; 
           }else if(currentOpp.Prior_Opportunity__c != null){
               if(currentOpp.Prior_Opportunity__r.Payment_Frequency__c != null)
                   paymentFrequency = currentOpp.Prior_Opportunity__r.Payment_Frequency__c;
           }else if(!priorOpp.isEmpty()){ 
               if(priorOpp[0].Payment_Frequency__c!= null)
                   paymentFrequency = priorOpp[0].Payment_Frequency__c;
           }else{
               if(currentOpp.Payment_Frequency__c!= null)
                   paymentFrequency =currentOpp.Payment_Frequency__c;
           }
           //payment terms
           if(currentOpp.StageName=='Closed Won'){
               if(currentOpp.Payment_Terms__c!= null)
                   paymentTerms =currentOpp.Payment_Terms__c; 
           }else if(currentOpp.Prior_Opportunity__c != null){
               if(currentOpp.Prior_Opportunity__r.Payment_Terms__c!= null)
                   paymentTerms = currentOpp.Prior_Opportunity__r.Payment_Terms__c;
           }else if(!priorOpp.isEmpty()){ 
               if(priorOpp[0].Payment_Terms__c!= null)
                   paymentTerms = priorOpp[0].Payment_Terms__c;    
           }else{
               if(currentOpp.Payment_Terms__c!= null)
                   paymentTerms =currentOpp.Payment_Terms__c;
           }
           paymentTerms = EncodingUtil.urlEncode(paymentTerms, 'UTF-8');
           paymentFrequency = EncodingUtil.urlEncode(paymentFrequency, 'UTF-8');
           
           //MAXIMUM DATABASE SIZE
           Decimal maxDBSize=0;
           for(OpportunityLineItem oli : currentOpp.OpportunityLineItems){
               if(maxDBSize < oli.PricebookEntry.Product2.Record_Limitation__c){
                   maxDBSize = oli.PricebookEntry.Product2.Record_Limitation__c;
               }
           }
           String encodedName = EncodingUtil.urlEncode(currentOpp.Name, 'UTF-8');
           if(currentOpp.Sub_Start_Date__c != null){
               expiryDate = currentOpp.Sub_Start_Date__c.addDays(-7).month()+'/'+currentOpp.Sub_Start_Date__c.addDays(-7).day()+'/'+currentOpp.Sub_Start_Date__c.addDays(-7).year();
           }
           String url = '/0Q0/e?retURL='+currentOpp.Id+'&oppid='+currentOpp.Id+'&RecordType='+renewalRecordTypeId+'&ent=Quote&Name='+encodedName+'&00N50000002OVnp='+maxDBSize;
           if(currentOpp.Sub_Start_Date__c!= null){
               url += '&00N50000002OVnf='+currentOpp.Sub_Start_Date__c.month()+'/'+currentOpp.Sub_Start_Date__c.day()+'/'+currentOpp.Sub_Start_Date__c.year();
           }else{url += '&00N50000002OVnf=';}
           
           if(currentOpp.Sub_End_Date__c!= null){
               url +='&00N50000002OVnk='+currentOpp.Sub_End_Date__c.month()+'/'+currentOpp.Sub_End_Date__c.day()+'/'+currentOpp.Sub_End_Date__c.year();
           }else{url +='&00N50000002OVnk=';}
           
           url +='&ExpirationDate='+expiryDate+'&00N50000002OHZY=Incentive&00N50000002Ni1z='+paymentTerms+'&00N50000002Ni1u='+paymentFrequency+'&00N50000002Njv0='+MarketingPermission;
           
           system.debug('=='+url);
           
           Pagereference newpage = new PageReference(url);
           return newpage;
        }

        return null;
    }
    /****test codes****/
    @isTest(SeeAllData=true)
    static void testCreateRenewalQuoteController(){
        test.startTest();        
        Account a = Utility.insertAccountInTestClasses();  
        a.BillingCity = 'Ichalkaranji';
        a.BillingCountry = 'India';
        a.BillingStreet = 'Test Street';
        a.BillingState ='Test Billing State';
        a.BillingPostalCode ='12345';
        a.ShippingCity ='Pune';
        a.ShippingCountry ='India';
        a.ShippingPostalCode = '12345';
        a.ShippingState = 'Maharashtra';
        a.ShippingStreet = 'Test Shipping Street';
        insert a;
        
        Contact c = Utility.insertContactInTestClasses(a.Id);
        insert c;
        Opportunity Opp = Utility.insertOpportunityInTestClasses(a.id, c.Id, 'Closed Won', 'Renewal',Date.Today(), system.today().addDays(1),system.today().addDays(7), null);        
        insert Opp;
        
        Product2 p = new Product2(Name = 'test pro',Product_Type__c = 'Subscription', Record_Limitation__c =3000, IsActive = true, ConvertTo__c = 'Subscription', ProductCode = 'abc');
        insert p;
        List < PriceBook2 > PriceB = [Select id from PriceBook2 where IsStandard = true limit 1];
        PriceBookEntry Pe = new PriceBookEntry(IsActive = true, PriceBook2Id = PriceB[0].id, Product2Id = p.id, UnitPrice = 200);
        insert pe;
       
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Users__c = 1;
        oli.MLM_Edition__c = 'test edition';
        oli.OpportunityId = Opp.Id;
        oli.PricebookEntryId = pe.Id;
        oli.Instance_Number__c = 123;
        oli.Quantity = 2;
        oli.UnitPrice = 200;
        insert oli;
        
        PageReference pageRef = Page.CreateRenewalQuote;
        pageRef.getParameters().put('Id',opp.Id);
        Test.setCurrentPageReference(pageRef);
        List<Quote> quotes = new List<Quote>();
        // load the extension
        CreateRenewalQuoteController controller = new CreateRenewalQuoteController(new ApexPages.StandardSetController(quotes));
        controller.init();
        test.stopTest();
    }
}