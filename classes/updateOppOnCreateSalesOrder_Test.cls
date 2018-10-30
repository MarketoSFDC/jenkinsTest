@isTest
private class updateOppOnCreateSalesOrder_Test {

	private static testMethod void test() {
	    
	      Account acc = new Account();
                    acc.Name = 'TestAccountMainTriggerOptimised';
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
                    acc.type                 = 'Prospect';
                    //acc.CRM_System__c = 'Microsoft CRM 2011';
                    acc.Current_MRM_MA_Solution__c = 'Unica';
                    acc.Global_Number_of_Employees__c = 1500;
                    acc.Phone = '+1140899900';
                    acc.Current_ESP_Solution__c ='MailChimp';
                    acc.SicDesc ='Custom Computer Programming Services';
                    acc.Intacct_Account_Payable_Status__c = 'Test';
                    acc.Partner_Type__c = 'Agency'; 
                    acc.CSM_Trigger__c = 'Elite/Key';
                    acc.Date_Became_a_Customer__c = System.Now().Date().addDays(-10);
                   
                    
               
                insert acc;
	    
	    
	     Opportunity opp1 = new Opportunity();
                    opp1.Name = 'TestOpportunityOptimiesed';
                    opp1.AccountId = acc.Id;
                    opp1.Payment_Frequency__c = 'Annually';
                    opp1.StageName = 'Closed Won';
                    opp1.CloseDate = System.Now().Date().addDays(-10);
                    opp1.Deal_Type__c = 'Services';
                    opp1.Rep_Create_ARR__c = 1;
                   insert opp1;
                 
        updateOppOnCreateSalesOrderController controller = new updateOppOnCreateSalesOrderController();        
        ApexPages.currentPage().getParameters().put('id',opp1.Id);
        ApexPages.currentPage().getParameters().put('intactUrl','Test');
        controller.redirectToIntacct();

	}

}