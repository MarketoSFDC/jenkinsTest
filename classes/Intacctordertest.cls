/****************************************************
 Modified By :Jade Global 31th August 2018
 Change      : Removed closedWonRecordTypeId   variable from class
 *******************************************************/
@istest
private class Intacctordertest {
    public static testmethod void  Intacctordertestmethod(){
        IntacctOrderController p=new IntacctOrderController();
        Product2 pr = new Product2();
        pr.Name='Moto - G1';
        pr.isActive=true;
        pr.ProductCode = 'LM-SAND';
        insert pr;
        NEWCreateAssetsAndEntitlements.getsandboxProductId();
        SalesTriggersUtility.dlrs_AccountTrigger = true;
         Account acc = new Account();
                        acc.Name                 = 'GRAZITTI TEST ACCOUNT 1';
                        acc.Sales_Region__c      = 'North America';
                        acc.Business_Unit__c     = 'AMER-SB';
                        acc.BillingCity          = 'NewYork';
                        acc.BillingCountry       = 'United States';
                        acc.BillingStreet        = 'Test Street';
                        acc.BillingState         = 'Test Billing State';
                        acc.BillingPostalCode    = '12345';
                        acc.ShippingCity         = 'Chandigarh';
                        acc.ShippingCountry      = 'India';
                        acc.ShippingPostalCode   = '12345';
                        acc.ShippingState        = '';
                        acc.ShippingStreet       = 'Test Shipping Street';
                        acc.Partner_Type__c      = 'Agency';
        insert acc;
        
        Contact con = new Contact();
                        con.FirstName = 'GRAZITTI';
                        con.LastName   = 'GRAZITTI TEST CONTACT 1';
                        con.email      = 'test@test.com';
                        con.LeadSource = 'Blog';
                        con.AccountId  = acc.Id;
        insert con;
        
        Intacct_Entity__c ie = new Intacct_Entity__c();
        ie.Name = 'marketo-emea';
        insert ie;
        Intacct_Entity__c ie2 = new Intacct_Entity__c();
        ie2.Name = 'marketo-us';
        insert ie2;
        
        
        Id stdPbId = Test.getStandardPricebookId();
        
        Opportunity opp = new Opportunity();
                            opp.Name      = 'GRAZITTI TEST OPPORTUNITY 1';
                            opp.AccountId = acc.Id;
                            opp.Type      = 'New Business';
                            opp.StageName = 'A - Qualify';
                            opp.Amount   = 10000;
                            opp.PriceBook2Id = stdPbId;
                            opp.Primary_Marketo_User_Lookup__c = con.Id;
                            opp.Economic_Decision_Maker__c = con.Id;
                            opp.Engagement_Manager__c = UserInfo.getUserId();
                            opp.SBQQ__Contracted__c = true;
                            opp.Intacct_Sales_Region__c = '';
                            opp.Owner_Role_Custom_Text__c = 'ANZ PS';
                            opp.Intacct_Entity__c = ie.Id;
                            opp.Rep_Create_ARR__c = 10;
                            opp.MainCompetitor__c = 'Act-On';
                          
                            opp.CloseDate = System.Now().Date();

        insert opp;
        p.oppid=opp.id;
        p.getdocumentno();
    }
     public static testmethod void  OpportunityLineItemControllertestmethod(){
         Product2 pr = new Product2();
        pr.Name='Moto - G1';
        pr.isActive=true;
        pr.ProductCode = 'LM-SAND';
        insert pr;
        NEWCreateAssetsAndEntitlements.getsandboxProductId();
        SalesTriggersUtility.dlrs_AccountTrigger = true;
         Account acc = new Account();
                        acc.Name                 = 'GRAZITTI TEST ACCOUNT 1';
                        acc.Sales_Region__c      = 'North America';
                        acc.Business_Unit__c     = 'AMER-SB';
                        acc.BillingCity          = 'NewYork';
                        acc.BillingCountry       = 'United States';
                        acc.BillingStreet        = 'Test Street';
                        acc.BillingState         = 'Test Billing State';
                        acc.BillingPostalCode    = '12345';
                        acc.ShippingCity         = 'Chandigarh';
                        acc.ShippingCountry      = 'India';
                        acc.ShippingPostalCode   = '12345';
                        acc.ShippingState        = '';
                        acc.ShippingStreet       = 'Test Shipping Street';
                        acc.Partner_Type__c      = 'Agency';
        insert acc;
        
        Contact con = new Contact();
                         con.FirstName = 'GRAZITTI';
                        con.LastName   = 'GRAZITTI TEST CONTACT 1';
                        con.email      = 'test@test.com';
                        con.LeadSource = 'Blog';
                        con.AccountId  = acc.Id;
        insert con;
        
        Intacct_Entity__c ie = new Intacct_Entity__c();
        ie.Name = 'marketo-emea';
        insert ie;
        Intacct_Entity__c ie2 = new Intacct_Entity__c();
        ie2.Name = 'marketo-us';
        insert ie2;
        
        
        Id stdPbId = Test.getStandardPricebookId();
        
        Opportunity opp = new Opportunity();
                            opp.Name      = 'GRAZITTI TEST OPPORTUNITY 1';
                            opp.AccountId = acc.Id;
                            opp.Type      = 'New Business';
                            opp.StageName = 'A - Qualify';
                            opp.Amount   = 10000;
                            opp.PriceBook2Id = stdPbId;
                            opp.Primary_Marketo_User_Lookup__c = con.Id;
                            opp.Economic_Decision_Maker__c = con.Id;
                            opp.Engagement_Manager__c = UserInfo.getUserId();
                            opp.SBQQ__Contracted__c = true;
                            opp.Intacct_Sales_Region__c = '';
                            opp.Owner_Role_Custom_Text__c = 'ANZ PS';
                            opp.Intacct_Entity__c = ie.Id;
                            opp.Rep_Create_ARR__c = 10;
                            opp.MainCompetitor__c = 'Act-On';
                            
                            opp.CloseDate = System.Now().Date();

        insert opp;
         OpportunityLineItemController olic=new OpportunityLineItemController();
         olic.oppid=opp.id;
         olic.proId=pr.id;
         olic.getProductQuantity();
     }
}