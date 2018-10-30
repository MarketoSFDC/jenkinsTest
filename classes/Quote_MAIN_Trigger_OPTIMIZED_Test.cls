@isTest
public class Quote_MAIN_Trigger_OPTIMIZED_Test{

    static testMethod void InsertQuoteTest(){
       //SalesTriggersUtility.marketoTriggerManager.Activate_Legacy_Triggers__c = False;
			 SalesTriggersUtility.Setvaluesfortest(); 
	   Account acc = new Account();
                acc.Name = 'Test Quote Account1';
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
        insert acc;
        
        Opportunity opp = new Opportunity();
                            opp.Name      = 'GRAZITTI TEST OPPORTUNITY 1';
                            opp.AccountId = acc.Id;
                            opp.Type      = 'New Business';
                            opp.StageName = 'Closed Won';
                            opp.Amount   = 10000;
                            opp.OwnerId = UserInfo.getUserId();
                            opp.CloseDate = System.Now().Date();
                            opp.MainCompetitor__c    =  'Act-On';
                            opp.Rep_Create_ARR__c    = 10;
        insert opp;
        
        Quote qut = new Quote();
              qut.Name = 'Test Quote 1';
              qut.Maximum_Database_Size__c = 100000;
              qut.OpportunityId = opp.id;
              qut.Case_Study_Permission__c = 'Customer agrees to a joint press release with Marketo outlining their reasons for choosing the Marketo Solution. Customer also agrees to participate in the Marketo reference and case study programs.';
              qut.RecordTypeId = Quote_MAIN_TriggerHandler_OPTIMIZED.SMBRecTypeId;
              qut.Competition__c = 'Woobox';
              qut.Competitive_Reason_1__c = 'Rip & Replace, lack of scalability and growth.';
              qut.Competitive_Reason_2__c = 'Rip & Replace, lack of scalability and growth.';
              qut.Why_Marketo_Reason_1__c = 'VC backed.';
              qut.Why_Marketo_Reason_2__c = 'VC backed.';
              qut.Terms__c = 'Premier Support.';
              qut.When__c = 'Deal today, please approve.';
          insert qut;
          update qut;
          
          Quote qut2 = new Quote();
              qut2.Name = 'Test Quote 1';
              qut2.Maximum_Database_Size__c = 100000;
              qut2.OpportunityId = opp.id;
              qut2.Case_Study_Permission__c = 'Customer agrees to a joint press release with Marketo outlining their reasons for choosing the Marketo Solution. Customer also agrees to participate in the Marketo reference and case study programs.';
              qut2.RecordTypeId = Quote_MAIN_TriggerHandler_OPTIMIZED.SMBRecTypeId;
              qut2.Competition__c = 'Woobox';
              qut2.Competitive_Reason_1__c = 'Rip & Replace, lack of scalability and growth.';
              qut2.Competitive_Reason_2__c = 'Rip & Replace, lack of scalability and growth.';
              qut2.Why_Marketo_Reason_1__c = 'VC backed.';
              qut2.Why_Marketo_Reason_2__c = 'VC backed.';
              qut2.Terms__c = 'Premier Support.';
              qut2.When__c = 'Deal today, please approve.';
          insert qut2;
          update qut2;
          delete qut2;

    }
}