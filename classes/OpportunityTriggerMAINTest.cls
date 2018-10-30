/*******************************************************
Modified By : Sumit Bhatt, Grazitti Interactive
Modified date : 7/27/2018
Purpose : Commented the field that are used in field removal project 
refrence : APPS-20840 Field Cleanup Project - Phase One
log of fields commented : Opportunity: implementation__c,mkt_user__c
*******************************************************/
@isTest
public class OpportunityTriggerMAINTest {

@testSetup static void Insertuser() {

Profile prof = [select id from profile where Id =: '00e50000000nA3H'];
        User user = new User();
        user.firstName = 'test1unique';
        user.lastName = 'test25555';
        user.profileId = prof.id;
        user.username = 'test@test.com555555';
        user.email = 'test@test.com5555555';
        user.Alias='alias55';
        user.TimeZoneSidKey= 'America/Los_Angeles';
        user.LocaleSidKey='en_US';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.UserRoleid    = '00E500000014lKn';
        insert user;
        
}
   
    public static testmethod void oldOpportunities(){
    lmscons__Disable_triggers__c ldt = new lmscons__Disable_triggers__c();
     ldt.Name = 'OpportunityTriggerManagement';
     ldt.lmscons__After_Delete__c = true;
     ldt.lmscons__After_Insert__c = true;
     ldt.lmscons__After_Update__c = true;
     ldt.lmscons__Before_Delete__c = true;
     ldt.lmscons__Before_Insert__c = true;
     ldt.lmscons__Before_Update__c = true;
     insert ldt;
     System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt);
     lmscons__Disable_triggers__c ldt2 = new lmscons__Disable_triggers__c();
     ldt2.Name = 'AccountTriggerManagement';
     ldt2.lmscons__After_Delete__c = true;
     ldt2.lmscons__After_Insert__c = true;
     ldt2.lmscons__After_Update__c = true;
     ldt2.lmscons__Before_Delete__c = true;
     ldt2.lmscons__Before_Insert__c = true;
     ldt2.lmscons__Before_Update__c = true;
     insert ldt2;
        //test.startTest();
       
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u1 = new User(Alias = 'opusr', Email='olduser1@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, isActive=true,
        TimeZoneSidKey='America/Los_Angeles', UserName='newuseroldOpportunities1@testorg.com');
        insert u1;
        
        User u2 = new User(Alias = 'nusr', Email='newuseroldOpportunitiesnewuser1233@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, isActive=true,
        TimeZoneSidKey='America/Los_Angeles', UserName='newuseroldOpportunities2@testorg.com');
        insert u2;
        
        // Insert Accounts
        List<Account> accountList = new List<Account>();
        accountList = TestCPQUtilityClass.createAccounts(5);   
        accountList[0].Renewals_Owner__c=u1.id;
        accountList[0].Sales_Region__c = 'Test Sales Region';
        accountList[2].Sales_Region__c = 'AMERICAS';
        accountList[3].Sales_Region__c = 'APAC';        
        if(!accountList.isEmpty()){
            insert accountList ;
        }       
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id oppRecordTypeId =OpportunityRecordTypeInfo.get('Closed Won').getRecordTypeId();
        
        ID  RenewalSalesId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Closed Won').getRecordTypeId();
        
        ID  ChannelId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Channel').getRecordTypeId();
        
        // Create Custom PB
        List<pricebook2> pbList = TestCPQUtilityClass.createCustomPriceBooks(2);
        insert pbList;
        
        // Add Custom Setting test data
        Role_Geographical_Segmentation_Setting__c rgss = new Role_Geographical_Segmentation_Setting__c();
        rgss.Name='Test';
        insert rgss;
        
        // Get ID of Standard PB
        Id stdPricebookId = Test.getStandardPricebookId();
        
        // Insert Products
        List<Product2> prodList = TestCPQUtilityClass.createCustomProducts(3);
        if(!prodList.isEmpty()){
            insert prodList;
        }
        
        // Add Products into Standard PB
        List<pricebookentry> pbeList = new List<pricebookentry>();
        for(Integer i=0; i< prodList.size(); i++){
            pricebookentry pbe = new pricebookentry(Pricebook2Id = stdPricebookId,Product2Id=prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbeList.add(pbe);
        }
        if(!pbeList.isEmpty()){
            insert pbeList;
        }
        
        // Add Products into Custom PB
        List<pricebookentry> pbeCustomList = new List<pricebookentry>();
        for(Integer i=0; i< prodList.size(); i++){
            pricebookentry pbe = new pricebookentry(Pricebook2Id = pbList[1].Id,Product2Id=prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbeCustomList.add(pbe);
        }
        if(!pbeCustomList.isEmpty()){
            insert pbeCustomList;
        }
        
        Intacct_Entity__c IntactEntity = new Intacct_Entity__c();
        IntactEntity.name='marketo-emea';
        insert IntactEntity;
        
        Intacct_Entity__c IntactEntity1 = new Intacct_Entity__c();
        IntactEntity1.name='marketo-us';
        insert IntactEntity1;
        
        List<MKT_TranslationTable__c> MKTList = new List<MKT_TranslationTable__c>();
        for(integer i=0;i<2;i++){
            MKT_TranslationTable__c MKT =new MKT_TranslationTable__c(ParentProduct__c=prodList[0].id);
            MKTList.add(MKT);
        }       
        insert MKTList;
       /* 
        kumocomm__Transaction__c TransactionRec = new kumocomm__Transaction__c(kumocomm__Amount__c=20);
        insert TransactionRec;  */            
        
        // Insert Opportunities with StageName = Prospecting
        List<Opportunity> opportunityList = new List<Opportunity>(); 
        opportunityList = TestCPQUtilityClass.createOpportunities(accountList,3);
        for(Opportunity opp : opportunityList){
            opp.Amount = 2000;
            opp.Pricebook2Id = pbList[1].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.OwnerId=u2.id;
        }
        
        // Insert Opportunities for Old Process
        opportunityList[0].Intacct_Entity__c = IntactEntity.Id;     // marketo - emea
        opportunityList[0].Deal_Type__c='Services';
        opportunityList[0].type='New Business'; 
        //opportunityList[0].MKT_User__c  = u2.id;
        opportunityList[0].Intacct_Sales_Region__c = 'AMERICAS';        

        // Insert Closed Own Opprtunity
        opportunityList[1].Intacct_Entity__c = IntactEntity.Id;     // marketo - emea
        opportunityList[1].Deal_Type__c='Services';
        opportunityList[1].type='New Business';
        opportunityList[1].stageName ='Closed Won';         
        opportunityList[1].recordTypeId = oppRecordTypeId;
        //opportunityList[1].MKT_User__c  = u2.id;
        opportunityList[1].Intacct_Sales_Region__c = 'APAC';
        opportunityList[1].Probability = 1;
        opportunityList[1].Split_Opportunities__c = null;
        opportunityList[1].Ghost__c = False ;
        opportunityList[1].pse__Primary_Project__c = null; 
        
        
        // Insert Oppty  with no Pricebook - New process
        opportunityList[5].Pricebook2Id = null;  //No Pricebook on Oppty - Takes SBPB       
        opportunityList[5].type='New Business';
        //opportunityList[1].MKT_User__c  = u2.id;
         test.startTest();
        if(!opportunityList.isEmpty()){
       /* Profile prof = [select id from profile where Id =: '00e50000000nA3H'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test25555';
        user.profileId = prof.id;
        user.username = 'test@test.com555555';
        user.email = 'test@test.com5555555';
        user.Alias='alias55';
        user.TimeZoneSidKey= 'America/Los_Angeles';
        user.LocaleSidKey='en_US';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.UserRoleid    = '00E500000014lKn';
        insert user;*/ 
      user uu = [select id,firstname from user where firstName = 'test1unique'];  
        system.runAs(uu){
            insert opportunityList;
        }
        }
        
        // Insert Opportunity Line Items
        List<OpportunityLineItem> OpportunityLineItemList = new List<OpportunityLineItem>();
        for(integer i=0;i<2;i++){       
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opportunityList[0].Id, PricebookEntryId = pbeCustomList[0].Id, UnitPrice = 10, Quantity = 20);
            oli.Product_Type__c = 'Services';   
            OpportunityLineItemList.add(oli);                  
        }
        
        for(integer i=0;i<opportunityList.size();i++){      
            OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opportunityList[i].Id, PricebookEntryId = pbeCustomList[0].Id, UnitPrice = 10, Quantity = 20);
            oli.Product_Type__c = 'Services';   
            OpportunityLineItemList.add(oli);                  
        }
        insert OpportunityLineItemList; 
        
        // Insert MKT_Payment__c
        List<MKT_Payment__c> MKTPaymentList = new List<MKT_Payment__c>();
        
        MKT_Payment__c payment = new MKT_Payment__c();
        payment.Product__c = OpportunityLineItemList[0].PricebookEntry.Product2Id;
        //payment.User__c = (OpportunityLineItemList[0].Opportunity.MKT_User__c == NULL) ? OpportunityLineItemList[0].Opportunity.CreatedById : OpportunityLineItemList[0].Opportunity.MKT_User__c;
        payment.Account__c = opportunityList[0].AccountId;
        payment.Total_Seats__c = OpportunityLineItemList[0].Quantity;
        payment.MKT_Opportunity__c = OpportunityLineItemList[0].OpportunityId;
        MKTPaymentList.add(payment);
        
        insert MKTPaymentList;      
        
        delete opportunityList;
        //undelete opportunityList;
        
        test.stopTest();
    }
    
public static testmethod void updateOppties(){
lmscons__Disable_triggers__c ldt = new lmscons__Disable_triggers__c();
     ldt.Name = 'OpportunityTriggerManagement';
     ldt.lmscons__After_Delete__c = true;
     ldt.lmscons__After_Insert__c = true;
     ldt.lmscons__After_Update__c = true;
     ldt.lmscons__Before_Delete__c = true;
     ldt.lmscons__Before_Insert__c = true;
     ldt.lmscons__Before_Update__c = true;
     insert ldt;
     System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt);
     lmscons__Disable_triggers__c ldt2 = new lmscons__Disable_triggers__c();
     ldt2.Name = 'AccountTriggerManagement';
     ldt2.lmscons__After_Delete__c = true;
     ldt2.lmscons__After_Insert__c = true;
     ldt2.lmscons__After_Update__c = true;
     ldt2.lmscons__Before_Delete__c = true;
     ldt2.lmscons__Before_Insert__c = true;
     ldt2.lmscons__Before_Update__c = true;
     insert ldt2;
        
        List<Account> accountList = new List<Account>();
        accountList = TestCPQUtilityClass.createAccounts(1);
    accountList[0].type='Customer';
        accountList[0].recordtypeid='01250000000ULb7'; 
        if(!accountList.isEmpty()){
            insert accountList ;
        }
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        user u1 =  [select id,firstname from user where firstname = 'test1unique'];
        /*
        User u1 = new User(Alias = 'opusr', Email='olduser1@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, isActive=true,userroleid = '00E500000014lKn',
        TimeZoneSidKey='America/Los_Angeles', UserName='newuseroldOpportunities1@testorg.com');
        insert u1;*/
        
        User u2 = new User(Alias = 'nusr', Email='newuseroldOpportunitiesnewuser1233@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, isActive=true,
        TimeZoneSidKey='America/Los_Angeles', UserName='newuseroldOpportunities2@testorg.com');
        insert u2;
        
        // Record Types
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id oppRecordTypeId =OpportunityRecordTypeInfo.get('Closed Won').getRecordTypeId();
        ID  RenewalSalesId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Closed Won').getRecordTypeId();
        
        // Create Custom PB
        List<pricebook2> pbList = TestCPQUtilityClass.createCustomPriceBooks(2);
        insert pbList;
        
        test.startTest();
        // Custom Setting
        Intacct_Entity__c IntactEntity = new Intacct_Entity__c();
        IntactEntity.name='marketo-emea';
        insert IntactEntity;
        
        Intacct_Entity__c IntactEntity1 = new Intacct_Entity__c();
        IntactEntity1.name='marketo-us';
        insert IntactEntity1;
        
        List<Opportunity> opportunityList = new List<Opportunity>(); 
        opportunityList = TestCPQUtilityClass.createOpportunities(accountList,4);
        if(!opportunityList.isEmpty()){
            insert opportunityList ;
        }
        
        // UPDATE OPPORTUNITIES
        System.debug('opportunityList**********************' + opportunityList.size());
        
        // Scene-1 == After Update, StageName = Closed Won  & type = 'New Business'
        opportunityList[0].type = 'New Business';
        opportunityList[0].StageName = 'Closed Won';
        opportunityList[0].Deal_Type__c = 'Services';
        opportunityList[0].Assets_created_on_closed_Won__c = true;
        opportunityList[0].Pricebook2Id = pbList[1].Id; 
        opportunityList[0].Intacct_Entity__c = IntactEntity.Id;  
        opportunityList[0].recordTypeId = oppRecordTypeId;
        //opportunityList[0].MKT_User__c  = u2.id;
        opportunityList[0].Intacct_Sales_Region__c = 'AMERICAS';
        
        // Scene-2 == stagename = 'Closed Won' type = 'Renewal' & Assets_created_on_closed_Won__c = true
        opportunityList[1].StageName = 'Closed Won';
        opportunityList[1].type = 'Renewal';
        opportunityList[1].Assets_created_on_closed_Won__c = true;
        opportunityList[1].Pricebook2Id = pbList[1].Id;
        opportunityList[1].RecordtypeID = RenewalSalesId;
        opportunityList[1].Intacct_Entity__c = IntactEntity1.Id; 
        opportunityList[1].recordTypeId = oppRecordTypeId;
        //opportunityList[1].MKT_User__c  = u2.id;
        opportunityList[1].Intacct_Sales_Region__c = 'AMERICAS';
        
        // Scene-3 == Lost Oppty, stagename = 'Closed Won' type = 'Renewal' & Assets_created_on_closed_Won__c = true
        opportunityList[2].type = 'Renewal';
        opportunityList[2].StageName = 'Closed Lost';
        opportunityList[2].Pricebook2Id = pbList[1].Id;
        //opportunityList[2].MKT_User__c  = u2.id;
        opportunityList[2].Competitive_MA__c='Yes';
        opportunityList[2].Competitive_MA__c = 'Yes';
        opportunityList[2].Competitive_ESP__c ='Yes';
        //opportunityList[2].Implementation__c  ='Yes';
        opportunityList[2].Lost_Reason_Sub__c ='Non MKTO - migration forced';
        opportunityList[2].Competitors_ESP__c ='Constant Contact';
        opportunityList[2].DealLostReason__c  ='Competitor - Agency';
        opportunityList[2].Loss_Description__c ='LossDescription test';
        opportunityList[2].Primary_Competitor__c = 'Adobe/Neolane'; 
        opportunityList[2].Deal_Won_By__c  = 'Act!On';     
         
         // Insert Oppty  with no Pricebook - New process
        opportunityList[3].Pricebook2Id = null;  //No Pricebook on Oppty - Takes SBPB       
        opportunityList[3].type='New Business';
        opportunityList[3].Intacct_Entity__c = IntactEntity1.Id;   // marketo - us
        //opportunityList[3].MKT_User__c  = u2.id;
       /* Profile prof = [select id from profile where Id =: '00e50000000nA3H'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test277777777';
        user.profileId = prof.id;
        user.username = 'test@test.com7777777777';
        user.email = 'test@test.com777777777777';
        user.Alias='alias77';
        user.TimeZoneSidKey= 'America/Los_Angeles';
        user.LocaleSidKey='en_US';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.UserRole.Name   = 'System_Admins';
        insert user;*/
      user uu = [select id,firstname from user where firstName = 'test1unique'];  
        system.runAs(uu){
        update opportunityList;
        }
    }
    public static testmethod void newOpportunities(){
    lmscons__Disable_triggers__c ldt = new lmscons__Disable_triggers__c();
     ldt.Name = 'OpportunityTriggerManagement';
     ldt.lmscons__After_Delete__c = true;
     ldt.lmscons__After_Insert__c = true;
     ldt.lmscons__After_Update__c = true;
     ldt.lmscons__Before_Delete__c = true;
     ldt.lmscons__Before_Insert__c = true;
     ldt.lmscons__Before_Update__c = true;
     insert ldt;
     System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt);
     lmscons__Disable_triggers__c ldt2 = new lmscons__Disable_triggers__c();
     ldt2.Name = 'AccountTriggerManagement';
     ldt2.lmscons__After_Delete__c = true;
     ldt2.lmscons__After_Insert__c = true;
     ldt2.lmscons__After_Update__c = true;
     ldt2.lmscons__Before_Delete__c = true;
     ldt2.lmscons__Before_Insert__c = true;
     ldt2.lmscons__Before_Update__c = true;
     insert ldt2;
        
        // Insert User record
       /* Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u1 = new User(Alias = 'conus', Email='newOpportunitiesnewuser12@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing1', LanguageLocaleKey='en_US',
        LocaleSidKey='en_US', ProfileId = p.Id,userroleId = '00E500000014lKn',
        TimeZoneSidKey='America/Los_Angeles', UserName='newuser1newOpportunitiestest@testorg.com');
        insert u1;*/
        user u1 = [select id,firstname from user where firstname = 'test1unique'];
        profile p = [select id from profile where Id =: '00e50000000nA3H'];
        User u2 = new User(Alias = 'accus', Email='newOpportunitiesnewuser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='Testing2', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id, 
        TimeZoneSidKey='America/Los_Angeles', UserName='newOpportunitiesnewuser2@testorg.com');
        insert u2;
        
        // Insert Accounts
        List<Account> accountList = new List<Account>();
        accountList = TestCPQUtilityClass.createAccounts(5);   
        accountList[0].Renewals_Owner__c=u1.id;
        accountList[0].Sales_Region__c = 'Test Sales Region';
        accountList[2].Sales_Region__c = 'AMERICAS';
        accountList[3].Sales_Region__c = 'APAC';    
        if(!accountList.isEmpty()){
            insert accountList ;
        }
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Opportunity; 
        Map<String,Schema.RecordTypeInfo> OpportunityRecordTypeInfo = cfrSchema.getRecordTypeInfosByName();
        Id oppRecordTypeId =OpportunityRecordTypeInfo.get('Closed Won').getRecordTypeId();
        
        ID  RenewalSalesId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Closed Won').getRecordTypeId();
        
        ID  ChannelId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Channel').getRecordTypeId();
        
        // Create Custom PB
        List<pricebook2> pbList = TestCPQUtilityClass.createCustomPriceBooks(2);
        insert pbList;
        
        // Add record for SteelBric PB Id
        SteelBrickCPQPricebook__c SBPB = new SteelBrickCPQPricebook__c();
        SBPB.id__c = pbList[0].Id;
        insert SBPB;
        
        // Add Custom Setting test data
        Role_Geographical_Segmentation_Setting__c rgss = new Role_Geographical_Segmentation_Setting__c();
        rgss.Name='Test';
        insert rgss;
        
        // Get ID of Standard PB
        Id stdPricebookId = Test.getStandardPricebookId();
        
        // Insert Products
        List<Product2> prodList = TestCPQUtilityClass.createCustomProducts(3);
        if(!prodList.isEmpty()){
            insert prodList;
        }
        
        // Add Products into Standard PB
        List<pricebookentry> pbeList = new List<pricebookentry>();
        for(Integer i=0; i< prodList.size(); i++){
            pricebookentry pbe = new pricebookentry(Pricebook2Id = stdPricebookId,Product2Id=prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbeList.add(pbe);
        }
        if(!pbeList.isEmpty()){
            insert pbeList;
        }
        
        // Add Products into Custom PB
        List<pricebookentry> pbeCustomList = new List<pricebookentry>();
        for(Integer i=0; i< prodList.size(); i++){
            pricebookentry pbe = new pricebookentry(Pricebook2Id = pbList[0].Id,Product2Id=prodList[i].Id,UnitPrice = 10000, IsActive = true);
            pbeCustomList.add(pbe);
        }
        if(!pbeCustomList.isEmpty()){
            insert pbeCustomList;
        }
        
        Intacct_Entity__c IntactEntity = new Intacct_Entity__c();
        IntactEntity.name='marketo-emea';
        insert IntactEntity;
        
        Intacct_Entity__c IntactEntity1 = new Intacct_Entity__c();
        IntactEntity1.name='marketo-us';
        insert IntactEntity1;
        
        List<MKT_TranslationTable__c> MKTList = new List<MKT_TranslationTable__c>();
        for(integer i=0;i<2;i++){
            MKT_TranslationTable__c MKT =new MKT_TranslationTable__c(ParentProduct__c=prodList[0].id);
            MKTList.add(MKT);
        }       
        insert MKTList;
        /*
        kumocomm__Transaction__c TransactionRec = new kumocomm__Transaction__c(kumocomm__Amount__c=20);
        insert TransactionRec;      */
        
        List<Opportunity> opportunityListV2 = new  List<Opportunity>();       
        
        // Insert Opportunities with StageName = Prospecting
        opportunityListV2 = TestCPQUtilityClass.createOpportunities(accountList,3);
        for(Opportunity opp : opportunityListV2){
            opp.Amount = 2000;
            opp.Pricebook2Id = pbList[0].Id;
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.OwnerId=u2.id;
        }
        
        // Insert Closed Own Opprtunity
        opportunityListV2[1].Intacct_Entity__c = IntactEntity.Id;     // marketo - emea
        opportunityListV2[1].Deal_Type__c='Services';
        opportunityListV2[1].type='New Business';
        opportunityListV2[1].type='Renewal';
        opportunityListV2[1].stageName ='Closed Won';         
        opportunityListV2[1].recordTypeId = oppRecordTypeId;
        //opportunityListV2[1].MKT_User__c  = u2.id;
        opportunityListV2[1].Intacct_Sales_Region__c = 'AMERICAS';
        opportunityListV2[1].Probability = 1;
        opportunityListV2[1].Split_Opportunities__c = null;
        opportunityListV2[1].Ghost__c = False ;
        opportunityListV2[1].pse__Primary_Project__c = null; 
        
        // Insert Opportunities for New Process
        opportunityListV2[0].Intacct_Entity__c = IntactEntity.Id;     // marketo - emea
        opportunityListV2[0].Deal_Type__c = 'Services';
        opportunityListV2[0].type = 'New Business';
        //opportunityListV2[0].MKT_User__c  = u2.id;    
        opportunityListV2[0].Intacct_Sales_Region__c = 'APAC';        
        
        // Insert Oppty  with no Pricebook - New process
        opportunityListV2[5].Pricebook2Id = null;  //No Pricebook on Oppty - Takes SBPB       
        opportunityListV2[5].type='New Business';
        opportunityListV2[5].Intacct_Entity__c = IntactEntity1.Id;   // marketo - us
        //opportunityListV2[5].MKT_User__c  = u2.id;
        
        test.startTest();
        system.debug('+++++++++++++++++++++size of the opportunity '+ opportunityListV2.size());
        if(!opportunityListV2.isEmpty()){
        /*Profile prof = [select id from profile where Id =: '00e50000000nA3H'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test24444';
        user.profileId = prof.id;
        user.username = 'test@test.com44444444';
        user.email = 'test@test.com4444444444';
        user.Alias='alias44';
        user.TimeZoneSidKey= 'America/Los_Angeles';
        user.LocaleSidKey='en_US';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.UserRole.Name   = 'System_Admins';
        insert user;*/ 
        user uu = [select id,firstname from user where firstName = 'test1unique'];
        system.runAs(uu){
            insert opportunityListV2;
        }
        }
        
        // Insert Opportunity Line Items
        List<OpportunityLineItem> OpportunityLineItemList = new List<OpportunityLineItem>();
        for(integer i=0;i<opportunityListV2.size();i++){
            for(integer j=0; j<2;j++){
                OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = opportunityListV2[i].Id, PricebookEntryId = pbeCustomList[0].Id, UnitPrice = 10, Quantity = 20);
                oli.Product_Type__c = 'Services';
                OpportunityLineItemList.add(oli);
            }         
        }

        insert OpportunityLineItemList;
        
        // Insert MKT_Payment__c
        List<MKT_Payment__c> MKTPaymentList = new List<MKT_Payment__c>();
        
        MKT_Payment__c payment = new MKT_Payment__c();
        payment.Product__c = OpportunityLineItemList[0].PricebookEntry.Product2Id;
        //payment.User__c = (OpportunityLineItemList[0].Opportunity.MKT_User__c == NULL) ? OpportunityLineItemList[0].Opportunity.CreatedById : OpportunityLineItemList[0].Opportunity.MKT_User__c;
        payment.Account__c = opportunityListV2[0].AccountId;
        payment.Total_Seats__c = OpportunityLineItemList[0].Quantity;
        payment.MKT_Opportunity__c = OpportunityLineItemList[0].OpportunityId;
        MKTPaymentList.add(payment);
        
        insert MKTPaymentList;
        
        opportunityListV2[2].StageName = 'Signed Order';
        opportunityListV2[2].MainCompetitor__c = 'Act-On';
        opportunityListV2[2].Needs_Pains__c = 'test';
        opportunityListV2[2].Use_Case__c = 'B2B';
        update opportunityListV2[2];
        
        // UPDATE OPPORTUNITIES
        
        // Scene-1 == After Update, StageName = Closed Won  & type = 'New Business'
        opportunityListV2[2].type = 'New Business';
        opportunityListV2[2].StageName = 'Closed Won';
        opportunityListV2[2].Deal_Type__c = 'Services';
        //opportunityListV2[2].Assets_created_on_closed_Won__c = true;        
        opportunityListV2[2].Intacct_Sales_Region__c = null;      
        opportunityListV2[2].Intacct_Entity__c = IntactEntity.Id;    // marketo - emea
        opportunityListV2[2].recordTypeId = oppRecordTypeId;
        //opportunityListV2[2].MKT_User__c  = u2.id;
        opportunityListV2[2].Intacct_Sales_Region__c = 'APAC';
        opportunityListV2[2].Probability = 1;
        opportunityListV2[2].Split_Opportunities__c = null;
        opportunityListV2[2].Ghost__c = False ;
        opportunityListV2[2].pse__Primary_Project__c = null;
        
        /*
        // Scene-2 == stagename = 'Closed Won' type = 'Renewal' & Assets_created_on_closed_Won__c = true
        opportunityListV2[4].StageName = 'Closed Won';
        opportunityListV2[4].type = 'Renewal';
        //opportunityListV2[4].Assets_created_on_closed_Won__c = true;        
        opportunityListV2[4].RecordtypeID = RenewalSalesId;
        opportunityListV2[4].Intacct_Entity__c = IntactEntity1.Id;    // marketo - us
        opportunityListV2[4].recordTypeId = oppRecordTypeId;
        opportunityListV2[4].MKT_User__c  = u2.id;
        opportunityListV2[4].Intacct_Sales_Region__c = 'AMERICAS';
        
        // Oppty type = New Business, Stage = Closed Won    
        opportunityListV2[0].stageName='Closed Won';  
        opportunityListV2[0].recordTypeId = oppRecordTypeId;
        opportunityListV2[0].MKT_User__c  = u2.id;
        opportunityListV2[0].Intacct_Entity__c = IntactEntity1.Id;   // marketo - us
        
        // Scene-3 == Lost Oppty, stagename = 'Closed Won' type = 'Renewal' & Assets_created_on_closed_Won__c = true
        opportunityListV2[1].type = 'Renewal';
        opportunityListV2[1].StageName = 'Closed Lost';
        opportunityListV2[1].MKT_User__c  = u2.id;
        opportunityListV2[1].Intacct_Entity__c = IntactEntity1.Id;   // marketo - us
        
        //TO REMOVE SCHEDULED EMAIL
        opportunityListV2[5].type = 'New Business';
        opportunityListV2[5].stageName = 'Closed Won';
        opportunityListV2[5].Intacct_Entity__c = IntactEntity1.Id;
        opportunityListV2[5].recordTypeId = oppRecordTypeId;
        opportunityListV2[5].MKT_User__c  = u2.id;
        opportunityListV2[1].Intacct_Entity__c = IntactEntity1.Id;   // marketo - us
        */

        update opportunityListV2[2];
        
        Opportunity opp = [Select id, stageName,Intacct_Sales_Region__c, type, Deal_Type__c from Opportunity where id =: opportunityListV2[2].Id limit 1];
        
        //System.assertEquals(opp.Intacct_Sales_Region__c, 'Test');
        
        System.debug('Testing Opportunity ====>' + [Select id, stageName, Intacct_Sales_Region__c, type, Deal_Type__c from Opportunity where id =: opportunityListV2[2].Id]);
        
        delete opportunityListV2;
        
        //undelete opportunityListV2;
        
        test.stopTest();
    }   
    
    //Code added by Jade on 16th Feb, 2016
    //Below testmethod will cover the OpportunityAPORRecursion class
    public static testmethod void CoverOpportunityAPORRecursion(){
    lmscons__Disable_triggers__c ldt = new lmscons__Disable_triggers__c();
     ldt.Name = 'OpportunityTriggerManagement';
     ldt.lmscons__After_Delete__c = true;
     ldt.lmscons__After_Insert__c = true;
     ldt.lmscons__After_Update__c = true;
     ldt.lmscons__Before_Delete__c = true;
     ldt.lmscons__Before_Insert__c = true;
     ldt.lmscons__Before_Update__c = true;
     insert ldt;
     System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt);
     lmscons__Disable_triggers__c ldt2 = new lmscons__Disable_triggers__c();
     ldt2.Name = 'AccountTriggerManagement';
     ldt2.lmscons__After_Delete__c = true;
     ldt2.lmscons__After_Insert__c = true;
     ldt2.lmscons__After_Update__c = true;
     ldt2.lmscons__Before_Delete__c = true;
     ldt2.lmscons__Before_Insert__c = true;
     ldt2.lmscons__Before_Update__c = true;
     insert ldt2;
        
        Test.StartTest();
        //  ********* Insert product ********************** *
        list<product2> prod = TestCPQUtilityClass.createCustomProducts(1);
        insert prod[0];
        
        //  ********** Insert Pricebook *****************************
        
        list<pricebook2> pribook = TestCPQUtilityClass.createCustomPriceBooks(1);
        insert pribook[0];
        
        //  ********** Insert Pricebook Entry ****************
        TestCPQUtilityClass.createStdPricebookEntries(prod,Test.getstandardpricebookid());
        list<PriceBookEntry> pricebookenty = TestCPQUtilityClass.createPriceBookEntries(prod,pribook);
        pricebookenty[0].UseStandardPrice = False;
        insert pricebookenty[0];
        
        OpportunityAPORRecursion apor = new OpportunityAPORRecursion();
        
        //Insert an Account
        list<Account> accList = TestCPQUtilityClass.createAccounts(1);
        insert accList;
        
        // insert contract
         list<Contract> contra = TestCPQUtilityClass.createContracts(accList,1);      
         insert contra;
        
        //Insert New Business Oppty
        List<string> quotidlist = new list<string>();
        list<Opportunity> NBOppList = TestCPQUtilityClass.createOpportunities(accList,1);
        for(Opportunity o : NBOppList){
            o.Type = 'New Business';
            o.Pricebook2Id = pribook[0].id;
        }
        insert NBOppList;
        
        //Insert SBQQ__Quote__c to New Business Oppty
        List<SBQQ__Quote__c> QuoteList = TestCPQUtilityClass.createQuotes(NBOppList,1);
        for(SBQQ__Quote__c q : QuoteList){
            q.SBQQ__Primary__c = TRUE;
            q.SBQQ__MasterContract__c = contra[0].id;
            
        }
        Insert QuoteList;
        quotidlist.add(QuoteList[0].id);
        QuoteLineCreation.createQuoteLine(quotidlist);
        
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = NBOppList[0].Id, PricebookEntryId = pricebookenty[0].Id, UnitPrice = 10, Quantity = 20);
        oli2.Product_Type__c = 'Services';   
        insert oli2;
        
        //opportunity will go through sign order before closed won 
        
        for(Opportunity o : NBOppList){
            o.RecordTypeId = Trigger_Opportunity_Helper.closedWonRecordTypeId;
            o.StageName = 'Signed Order';
      o.Migration__c = true;
            o.MainCompetitor__c = 'Act-On';
            o.Needs_Pains__c = 'test';
            o.Use_Case__c = 'B2B';
        }
        Update NBOppList;

        //Close won sign order Oppty
        for(Opportunity o : NBOppList){
            o.RecordTypeId = Trigger_Opportunity_Helper.closedWonRecordTypeId;
            o.StageName = 'Closed Won';
      o.Migration__c = false;
            o.Probability = 1;
            o.Split_Opportunities__c = null;
            o.Ghost__c = False ;
            o.pse__Primary_Project__c = null; 
            
        }
        /*Profile prof = [select id from profile where Id =: '00e50000000nA3H'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test222';
        user.profileId = prof.id;
        user.username = 'test@test.com2222';
        user.email = 'test@test.com222';
        user.Alias='alias222';
        user.TimeZoneSidKey= 'America/Los_Angeles';
        user.LocaleSidKey='en_US';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.userroleid  = '00E500000014lKn';
        insert user;*/ 
        user uu = [select id,firstname from user where firstName = 'test1unique'];
        system.runAs(uu){
          
        Update NBOppList;
       }
        //Insert Upsell/Crossell Oppty on Same Account
        list<Opportunity> UpsellOppList = TestCPQUtilityClass.createOpportunities(accList,1);
        for(Opportunity o : UpsellOppList){
            o.Type = 'Upsell/Crossell';
            o.Pricebook2Id = pribook[0].id;
        }
        insert UpsellOppList;
        
        //Insert SBQQ__Quote__c to Upsell/Crossell Oppty
        List<SBQQ__Quote__c> QuoteListforUpsell = TestCPQUtilityClass.createQuotes(UpsellOppList,1);
        for(SBQQ__Quote__c q : QuoteListforUpsell){
            q.SBQQ__Primary__c = TRUE;
        }
        Insert QuoteListforUpsell;
        
        OpportunityLineItem oli3 = new OpportunityLineItem(OpportunityId = UpsellOppList[0].Id, PricebookEntryId = pricebookenty[0].Id, UnitPrice = 10, Quantity = 20);
        oli3.Product_Type__c = 'Services';   
        insert oli3;
        
        //Signed order  Upsell/Crossell Oppty
        for(Opportunity o : UpsellOppList){
            o.RecordTypeId = Trigger_Opportunity_Helper.closedWonRecordTypeId;
            o.StageName = 'Signed Order';
        }
        Update UpsellOppList;
        
        //Closed Won Upsell/Crossell Oppty
        for(Opportunity o : UpsellOppList){
            o.RecordTypeId = Trigger_Opportunity_Helper.closedWonRecordTypeId;
            o.Probability = 1;
            o.Split_Opportunities__c = null;
            o.Ghost__c = False ;
            o.pse__Primary_Project__c = null;
            o.StageName = 'Closed Won';
        }
        Update UpsellOppList;
    
        //list<Opportunity> opptyList = [SELECT id,StageName,Type FROM Opportunity WHERE id IN : UpsellOppList AND isWon = TRUE AND Type = 'Upsell/Crossell'];
      
        //system.assertEquals(opptyList.size(),UpsellOppList.size());
       
        
        Test.StopTest();
    }
    
    public static testmethod void CoverPopulateExchangeRateOnRenewalsOppty(){
    lmscons__Disable_triggers__c ldt = new lmscons__Disable_triggers__c();
     ldt.Name = 'OpportunityTriggerManagement';
     ldt.lmscons__After_Delete__c = true;
     ldt.lmscons__After_Insert__c = true;
     ldt.lmscons__After_Update__c = true;
     ldt.lmscons__Before_Delete__c = true;
     ldt.lmscons__Before_Insert__c = true;
     ldt.lmscons__Before_Update__c = true;
     insert ldt;
     System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt);
     lmscons__Disable_triggers__c ldt2 = new lmscons__Disable_triggers__c();
     ldt2.Name = 'AccountTriggerManagement';
     ldt2.lmscons__After_Delete__c = true;
     ldt2.lmscons__After_Insert__c = true;
     ldt2.lmscons__After_Update__c = true;
     ldt2.lmscons__Before_Delete__c = true;
     ldt2.lmscons__Before_Insert__c = true;
     ldt2.lmscons__Before_Update__c = true;
     insert ldt2;
        //Insert an Account
        list<Account> accList = TestCPQUtilityClass.createAccounts(1);
        insert accList;
        
          // *****Insert Contract**************/
        
         list<Contract> contra = TestCPQUtilityClass.createContracts(accList,1);
      
         insert contra;
        
   //  ********* Insert product **********************
   
        list<product2> prod1 = TestCPQUtilityClass.createCustomProducts(1);
        insert prod1[0];
        
  //  ********** Insert Pricebook *****************************
      
        list<pricebook2> pribook1 = TestCPQUtilityClass.createCustomPriceBooks(1);
        insert pribook1[0];
  
  //  ********** Insert Pricebook Entry ****************
       TestCPQUtilityClass.createStdPricebookEntries(prod1,Test.getstandardpricebookid());
       list<PriceBookEntry> pricebookenty1 = TestCPQUtilityClass.createPriceBookEntries(prod1,pribook1);
       pricebookenty1[0].UseStandardPrice = False;
       insert pricebookenty1[0];
        
        //Insert New Business Oppty
        list<Opportunity> NBOppList = TestCPQUtilityClass.createOpportunities(accList,1);
        for(Opportunity o : NBOppList){
            o.Type = 'New Business';
            o.CloseDate = System.Today() + 365;
            o.Pricebook2id = pribook1[0].Id;
        }
        insert NBOppList;
                       
        //Insert SBQQ__Quote__c to New Business Oppty
        List<SBQQ__Quote__c> QuoteList = TestCPQUtilityClass.createQuotes(NBOppList,1);
        for(SBQQ__Quote__c q : QuoteList){
            q.SBQQ__Primary__c = TRUE;
        }
        Insert QuoteList;
         
         
        list<product2> prod = TestCPQUtilityClass.createCustomProducts(1);
        insert prod[0];
        
        
        OpportunityLineItem oli = new OpportunityLineItem(OpportunityId = NBOppList[0].Id, PricebookEntryId = pricebookenty1[0].Id, UnitPrice = 10, Quantity = 20);
        oli.Product_Type__c = 'Services';   
        insert oli;
        
        //opportunity will go through sign order before closed won 
        for(Opportunity o : NBOppList){
            o.RecordTypeId = Trigger_Opportunity_Helper.closedWonRecordTypeId;
            o.StageName = 'Signed Order';
      o.Migration__c = true;
            o.MainCompetitor__c = 'Act-On';
            o.Needs_Pains__c = 'test';
            o.Use_Case__c = 'B2B';
        }
        Update NBOppList;
        
        //Close won sign order oppty
        for(Opportunity o : NBOppList){
            o.RecordTypeId = Trigger_Opportunity_Helper.closedWonRecordTypeId;
            o.StageName = 'Closed Won';
      o.Migration__c = false;
            o.Probability = 1;
            o.Split_Opportunities__c = null;
            o.Ghost__c = False ;
            o.pse__Primary_Project__c = null;  
            o.SBQQ__RenewedContract__c = contra[0].id;
        }
       /* Profile prof = [select id from profile where Id =: '00e50000000nA3H'];
        User user = new User();
        user.firstName = 'test1';
        user.lastName = 'test2333333';
        user.profileId = prof.id;
        user.username = 'test@test.com333333';
        user.email = 'test@test.com33333333';
        user.Alias='alias333';
        user.TimeZoneSidKey= 'America/Los_Angeles';
        user.LocaleSidKey='en_US';
        user.EmailEncodingKey='UTF-8';
        user.LanguageLocaleKey='en_US';
        user.userroleid = '00E500000014lKn';
        insert user;*/
        user uu = [select id,firstname from user where Firstname = 'test1unique'];
        system.runAs(uu){
        Update NBOppList;
        }
        
        //Insert Renewal Oppty
        list<Opportunity> RNWLOppList = TestCPQUtilityClass.createOpportunities(accList,1);
        for(Opportunity o : RNWLOppList ){
            o.Type = 'Renewal';
            o.Prior_Opportunity__c = NBOppList[0].id;
            o.CloseDate = System.Today() + 365;
            o.Pricebook2id = pribook1[0].Id;
            //o.RecordTypeId='01250000000UBOS';
           
        }
        insert RNWLOppList;
         list<string> Quoteidlst = new list<string>();
        list<product2> prod2 = TestCPQUtilityClass.createCustomProducts(1);
        insert prod2[0];
        
        OpportunityLineItem oli2 = new OpportunityLineItem(OpportunityId = RNWLOppList[0].Id, PricebookEntryId = pricebookenty1[0].Id, UnitPrice = 10, Quantity = 20);
        oli2.Product_Type__c = 'Services';   
        insert oli2;
        
        //Insert SBQQ__Quote__c to RNWL Oppty
        List<SBQQ__Quote__c> RNWLQuoteList = TestCPQUtilityClass.createQuotes(RNWLOppList,1);
        for(SBQQ__Quote__c q : RNWLQuoteList){
            q.SBQQ__Primary__c = TRUE;
            q.SBQQ__MasterContract__c = contra[0].id;
        }
        Test.startTest();
        Insert RNWLQuoteList;
        Quoteidlst.add(RNWLQuoteList[0].id);
         QuoteLineCreation.createQuoteLine(Quoteidlst);
        
        //Close won RNWL Oppty
        for(Opportunity o : RNWLOppList){
            o.RecordTypeId = Trigger_Opportunity_Helper.closedWonRecordTypeId;
            o.MainCompetitor__c = 'Act-On';
            o.Needs_Pains__c = 'test';
            o.Use_Case__c = 'B2B';
            o.StageName = 'Signed Order';
            
        }
        
            Update RNWLOppList;
        
               
        for(Opportunity o : RNWLOppList){
            o.RecordTypeId = Trigger_Opportunity_Helper.closedWonRecordTypeId;
            o.Probability = 1;
            o.Split_Opportunities__c = null;
            o.Ghost__c = False ;
            o.pse__Primary_Project__c = null;
            o.StageName = 'Closed Won';
            o.SBQQ__RenewedContract__c  = contra[0].id;
            
        }
      
        system.runAs(uu){
            Update RNWLOppList;
        }
         QuoteLineCreation.createQuoteLine(Quoteidlst);    
          Test.stopTest();
    }
   
}