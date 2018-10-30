@isTest
private class OpportunityRecordTypeSelection_Test {

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
	    
	    List<Contact>  lstContacts = new List<Contact>();
                Contact con = new Contact();
                    con.LastName = 'TestConOptimised1';
                    con.AccountId = acc.Id;
                    con.email ='Test@test.com';
                    //con.LS_Deal_Score__c = 55;
                    con.LS_Account_Score__c  = 66;
                lstContacts.add(con);
              insert lstContacts;
	    
	    OpportunityRecordTypeSelection.fetchRecordTypeValues();
	    OpportunityRecordTypeSelection.getRecTypeId('New Business');
	    OpportunityRecordTypeSelection.fetchCaseRecordDetail(lstContacts[0].Id);
	    OpportunityRecordTypeSelection.fetchUser();

	}

}