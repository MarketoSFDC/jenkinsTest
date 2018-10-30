/*******************************************************************
*Modified By: Sumit Bhatt, Grazitti Interactive
*Purpose: REF: #APPS-18580# Update Test Classes
*Tracking: One cn track the changes by searching ticket number in code
*******************************************************************/

public class AEEmailHandlerController
{
    public static List<Authorized_Contact__c> ListOfAuthorizedContact;
    public static Map<Id,Authorized_Contact__c> AuthMap;
    public static void createFromEmail(string OppID,string Munchkin , string PO,string ProductC,string InstanceNum,string Asse,string AccountPre)
    {

 String OpID = OppID; 
 String MunchkinID =Munchkin;
 String POD=PO;
 String ProductCode = ProductC;
 List<Id> AssetsIds = new List<Id>();
   ListOfAuthorizedContact = new list<Authorized_Contact__c>();
    AuthMap = new Map<Id,Authorized_Contact__c>();
 Decimal InstanceNumber;
 if(InstanceNum != '' && InstanceNum != null)
     InstanceNumber = Decimal.valueOf(InstanceNum);
 String Asset =  Asse;
 String AccountPrefix = AccountPre;
 
 list<asset> ListOfAssetss = new list<asset>();
 list<asset> AssetsToUpdate = new list<asset>();
 
 list<opportunitylineitem> OLI = [select pricebookentry.product2.ConvertTo__c ,
                                Opportunity.Primary_Marketo_User_Lookup__c,
                                Opportunity.Primary_Marketo_User_Lookup__r.Account.Id, 
                                pricebookentry.product2.ProductCode,
                                pricebookentry.product2.Family,
                                pricebookentry.product2.Record_Limitation__c,
                                pricebookentry.product2.id,
                                opportunity.account.id,
                                opportunity.account.name,
                                opportunity.account.type,
                                opportunity.account.Partner_Type__c,
                                opportunity.account.Sales_Region__c,
                                opportunity.CRM_System__c,
                                opportunity.Sub_Start_Date__c,
                                opportunity.Sub_End_Date__c,
                                Quantity,Instance_Number__c
                                from opportunitylineitem where OpportunityId =: OpID 
                                AND Instance_Number__c=:InstanceNumber 
                                AND 
                                pricebookentry.product2.ProductCode =:ProductCode limit 1
                                ];
 if(OLI.size()>0)
 {
 system.debug('yes found');
  ListOfAssetss = [select id,product2.id,Munchkin_ID__c,POD__c,Acct_Prefix__c from asset where opportunity__c =:OpID limit 100];
  if(ListOfAssetss.size()>0)
  {
      for(asset LOA : ListOfAssetss)
      {
          if(LOA.product2.id == OLI[0].pricebookentry.product2.id)
          {
                        system.debug('yeah matched');
                        LOA.Munchkin_ID__c = MunchkinID;
                        LOA.POD__c = POD;
                        LOA.Acct_Prefix__c = AccountPrefix;
                        LOA.Provision_Status__c = 'Completed';
                  
                                       
                        if(LOA.Provision_Status__c == 'Completed' && (LOA.Munchkin_ID__c!='' || LOA.Munchkin_ID__c!=null) && (LOA.POD__c!=null || LOA.POD__c!='') && (LOA.Acct_Prefix__c!=null || LOA.Acct_Prefix__c!='')){
                            LOA.Provisioning_Complete__c = System.today();
                            LOA.Status = 'Active';   
                        }
                        
                        if((LOA.Acct_Prefix__c!='' || LOA.Acct_Prefix__c!=null) && (LOA.Purpose__c!='' || LOA.Purpose__c!=null)){
                            LOA.Name = LOA.Acct_Prefix__c + ' '+ String.ValueOf(LOA.Purpose__c);
                        }
                        AssetsToUpdate.add(LOA);
                        AssetsIds.add(LOA.id);
          }
      }
 
  
  }
 }
               List<Entitlement> ExtEntList = [SELECT id,StartDate,EndDate,BusinessHoursId,
               SlaProcessId,Product_ID__c,name,AccountId,AssetId,Type,Support_Region__c from Entitlement where AssetId =: AssetsIds  limit 100];
             
               
              /* CurrentOpp = [select id,accountid,Primary_Marketo_User_Lookup__c,
                                Primary_Marketo_User_Lookup__r.Account.Id 
                               from opportunity where id =: OpID  limit 1];*/
                
               List<Authorized_Contact__c> ExistingAC = [SELECT id,
                                                                   Entitlement__c
                                                              FROM Authorized_Contact__c
                                                              WHERE Entitlement__c in :ExtEntList 
                                                              and Customer_Admin__c = true limit 200]; 
               
                  for(Authorized_Contact__c c: ExistingAC )
                  {
                      AuthMap.put(c.Entitlement__c,c);
                  } 
                 
                 // Calling this method for creating Authorized Contacts
                  CreateAuthorizedContact(ExtEntList,OLI);  
 if(AssetsToUpdate.size()>0)
 {
     update AssetsToUpdate;
 }
}

  private static void CreateAuthorizedContact(List<Entitlement> ListOfEntitlement,List<OpportunityLineItem> Opt)
    {
        Authorized_Contact__c ac ;
            if(ListOfEntitlement.size()>0)
            {
                for(Entitlement ent : ListOfEntitlement)
                {
                        if(AuthMap.keyset().contains(ent.id)){
                            ac = AuthMap.get(ent.id);
                        }
                        else{
                            ac = new Authorized_Contact__c();
                        
                           /* if(CurrentOpp.size()>0)
                            {
                                ac.Contact__c= CurrentOpp[0].Primary_Marketo_User_Lookup__c ;
                            }*/
                            if(Opt.size()>0 && Opt[0].Opportunity.Primary_Marketo_User_Lookup__c != null)
                            {
                                ac.Contact__c= Opt[0].Opportunity.Primary_Marketo_User_Lookup__c ;
                            }
                            ac.Entitlement__c= ent.id;
                            ac.Customer_Admin__c=true;  
                                
                          /*  if(ac.Contact__c !=null && CurrentOpp[0].Primary_Marketo_User_Lookup__r.Account.Id == ent.AccountId)
                            {
                                ListOfAuthorizedContact.add(ac);
                                system.debug('ooo2'); 
                                
                            }*/
                            if(ac.Contact__c !=null && Opt[0].Opportunity.Primary_Marketo_User_Lookup__r.Account.Id == ent.AccountId)
                            {
                                ListOfAuthorizedContact.add(ac);
                                system.debug('ooo2'); 
                                
                            }
                        }
                }
            }
             system.debug('This is size of ac '+ListOfAuthorizedContact.size());  
            if(ListOfAuthorizedContact.size()>0)
            {
                upsert ListOfAuthorizedContact ;
            }
    }
    @isTest(SeeAllData=false)
    private static void AEEmailController()
    {
         Intacct_Entity__c entity=new Intacct_Entity__c(Name='marketo-rubiks');
        insert entity;
    
        // Insert Account
        Account a = new Account(Name='Test Acc',Sales_Region__c = 'North America');
         a.BillingCity = 'NewYork';
         a.BillingCountry = 'United States';
         a.BillingStreet = 'Test Street';
         a.BillingState ='Test Billing State';
         a.BillingPostalCode ='12345';
         a.ShippingCity ='Pune';
         a.ShippingCountry ='India';
         a.ShippingPostalCode = '12345';
         a.ShippingState = '';
         a.ShippingStreet = 'Test Shipping Street';
         a.Intacct_Entity__c=entity.id;
         a.IntacctID__c = 'TestIntacctID123456';
         insert a;
        
    // Insert Contact
        Contact c = new Contact(firstName = 'test', LastName = 'test Con',LeadSource = 'Blog',accountId=a.id);
        insert c;
        
    // Insert Products
         List<Product2> ProList = new List<Product2>();  
         Product2 p =new Product2(Name='test pro',IsActive = true,ConvertTo__c = 'Subscription',family='Dedicated IP',ProductCode='abc');
         ProList.add(p);
         Product2 p2 =new Product2(Name='test pro2',IsActive = true,ConvertTo__c = 'Add On',family='Dedicated IP', ProductCode ='xyz');
         ProList.add(p2);
         Product2 p3 =new Product2(Name='test pro3',IsActive = true,ConvertTo__c = 'Entitlement-Spark',family='Dedicated IP', ProductCode ='pqr');
         ProList.add(p3);
         Product2 p4 =new Product2(Name='test pro4',IsActive = true,ConvertTo__c = 'Entitlement-Spark',family='Dedicated IP', ProductCode ='rst');
         ProList.add(p4);
         insert ProList;
     
     // Fetch Standard PB
         List<PriceBook2> PriceB = [Select id from PriceBook2 where IsStandard = true limit 1];
         Id stdPBId = Test.getStandardPricebookId();
     
     // Insert Products into Standard PB
         //Product2 prod = [SELECT p.Id FROM Product2 p WHERE p.Name = 'Lead Management - Professional 100K'];
         List<PriceBookEntry> PBEList = new List<PriceBookEntry>();
         PriceBookEntry Pe = new PriceBookEntry(IsActive=true,PriceBook2Id=stdPBId,Product2Id=p.id,UnitPrice=200);
         PBEList.add(Pe); 
         PriceBookEntry Pe2 = new PriceBookEntry(IsActive=true,PriceBook2Id=stdPBId,Product2Id=p2.id,UnitPrice=200);
         PBEList.add(Pe2);
         PriceBookEntry Pe3 = new PriceBookEntry(IsActive=true,PriceBook2Id=stdPBId,Product2Id=p3.id,UnitPrice=200);
         PBEList.add(Pe3);
          PriceBookEntry Pe4 = new PriceBookEntry(IsActive=true,PriceBook2Id=stdPBId,Product2Id=p4.id,UnitPrice=200);
         PBEList.add(Pe4);
         insert PBEList;
        
    // Insert Opp
        Opportunity Opp = new Opportunity(Name='test opp',AccountId=a.id,Type='New Business',CloseDate=Date.today(),stagename='Discovery',Deal_Type__c = 'Standard',NextStep='test',CRM_System__c = 'ACT!',LeadSource = 'Blog',Intacct_Entity__c=entity.id,Primary_Marketo_User_Lookup__c=c.id);         
        opp.Pricebook2Id = stdPBId; 
		//APPS-18580
        opp.Rep_Create_ARR__c = 1;
		opp.MainCompetitor__c = 'AppBoy';
		//APPS-18580
        insert Opp; 
            
            List<OpportunityLineItem> OplList = new List<OpportunityLineItem>();        
            OpportunityLineItem oli = new OpportunityLineItem();
            //oli.Product_Family__c = 'test product family';
            oli.Users__c = 1;
            oli.MLM_Edition__c = 'test edition';
            oli.OpportunityId = Opp.Id;
            oli.PricebookEntryId = pe.Id;
            oli.Instance_Number__c = 123;
            oli.Quantity = 2;
            oli.UnitPrice = 200;
           //  oli.Quantity_1__c = 34;
          //  oli.Sales_Price_1__c = 500; 
            OplList.add(oli);
      
             OpportunityLineItem oli2 = new OpportunityLineItem();
            //oli.Product_Family__c = 'test product family';
            oli2.Users__c = 1;
            oli2.MLM_Edition__c = 'test edition';
      oli2.Instance_Number__c = 456;
            oli2.OpportunityId = Opp.Id;
            oli2.PricebookEntryId = pe2.Id;
            oli2.Quantity = 2;
            oli2.UnitPrice = 200;
         //   oli2.Quantity_1__c = 34;
         //   oli2.Sales_Price_1__c = 500; 
             OplList.add(oli2);
       
               OpportunityLineItem oli3 = new OpportunityLineItem();
            //oli.Product_Family__c = 'test product family';
            oli3.Users__c = 1;
            oli3.MLM_Edition__c = 'test edition';
            oli3.OpportunityId = Opp.Id;
            oli3.PricebookEntryId = pe3.Id;
      oli3.Instance_Number__c = 678;
            oli3.Quantity = 2;
            oli3.UnitPrice = 200;
            oli3.Quantity_1__c = 34;
          //  oli3.Sales_Price_1__c = 500; 
         //  OplList.add(oli3);
     
                OpportunityLineItem oli4 = new OpportunityLineItem();
            //oli.Product_Family__c = 'test product family';
            oli4.Users__c = 1;
            oli4.MLM_Edition__c = 'test edition';
            oli4.OpportunityId = Opp.Id;
            oli4.PricebookEntryId = pe4.Id;
            oli4.Quantity = 2;
            oli4.UnitPrice = 200;
           // OplList.add(oli4);
           
            insert OplList;
      
      
            List<RecordType> Rc = [SELECT id from RecordType WHERE Name = 'Closed Won' limit 1];
            Opp.RecordTypeId = Rc[0].id;
            Opp.Stagename = 'Closed Won';            
            update Opp;
        list<Asset> newAssetInsetList = new list<Asset>();
            // Create Contract
           Contract contrct = new Contract(Name='Test Contract ', AccountId=Opp.AccountId, SBQQ__Opportunity__c =Opp.Id, ContractTerm = 12, SBQQ__RenewalForecast__c = true, SBQQ__PreserveBundleStructureUponRenewals__c = true, SBQQ__DefaultRenewalContactRoles__c = true, SBQQ__DefaultRenewalPartners__c = true, StartDate=System.today());
           insert contrct;
        
           Asset ass=new Asset(AccountId=a.id, Product2Id=p.id,Contract__c=contrct.id, Asset_Type__c='Instance',opportunity__c=Opp.Id,Add_On_Product__c = 'Additional Authorized Contacts',Purpose__c='Production');
          // insert ass;
           
           Asset ass2=new Asset(AccountId=a.id, Product2Id=p.id,Contract__c=contrct.id, Asset_Type__c='Add On'/*,opportunity__c=Opp.Id*/,Add_On_Product__c = 'Additional Authorized Contacts',Purpose__c='Production');
           //insert ass2;
         newAssetInsetList.add(ass);
         newAssetInsetList.add(ass2);
        insert newAssetInsetList;
           List<Asset> ListOfAssetss = [select id,product2.id,Munchkin_ID__c,POD__c,Acct_Prefix__c from asset where opportunity__c =:Opp.Id limit 100];
        
           Entitlement Ent=new Entitlement(name='Test_Entitlement', AssetId = ass.id, Opportunity__c=Opp.id, Authorized_Contact_AddOn_Asset__c=ass2.id,AccountId=ass.AccountId);
           insert Ent; 
       
           Entitlement Ent1=new Entitlement(name='Test_Entitlement2', AssetId = ass.id, Opportunity__c=Opp.id, Authorized_Contact_AddOn_Asset__c=ass2.id,AccountId=ass2.AccountId);
           //insert Ent1;             
       
           Test.StartTest();
           Authorized_Contact__c Acnt=new Authorized_Contact__c(Entitlement__c=Ent.id,Contact__c=c.id,Customer_Admin__c= true);
           insert Acnt;
           
           Authorized_Contact__c Acnt1=new Authorized_Contact__c(Entitlement__c=Ent.id,Contact__c=c.id,Customer_Admin__c= false);
          // insert Acnt1;
       
           Test.stopTest();
       
           List<Authorized_Contact__c> ExistingAC = [SELECT id,Entitlement__c
                                                              FROM Authorized_Contact__c
                                                              WHERE Entitlement__c=:Ent.id
                                                              and Customer_Admin__c = true]; 
         
           //List<Entitlement> EntList=new List<Entitlement>();
           //EntList.add(Ent);
        
           AEEmailHandlerController.createFromEmail(Opp.id ,'7689','', p.ProductCode,'123',ass.Id,'pqrxyz');
           //AEEmailHandlerController.createFromEmail(Opp.id ,'001','', p2.ProductCode,'456',ass.Id,'aer');
           //AEEmailHandlerController.createFromEmail(Opp.id ,'001','', p3.ProductCode,'123',ass.Id,'aer');
           //AEEmailHandlerController.createFromEmail(Opp.id ,'001','', p4.ProductCode,'123',ass.Id,'aer');
           
           // Commented while pushing to Staging
           //AEEmailHandlerController.CreateAuthorizedContact(EntList,OplList);
           
           
    }
    
}