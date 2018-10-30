/* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
********************************************************************************************************************* */
@isTest(SeeAllData=true)
public class Test_SalesHandoffSurvey{
    
    static testMethod void testSaveSalesSurveyInClarizenProject() {
            Account acc = Utility.insertAccountInTestClasses();
        	acc.BillingCity = 'Ichalkaranji';
            acc.BillingCountry = 'India';
            acc.BillingStreet = 'Test Street';
            acc.BillingState ='Test Billing State';
            acc.BillingPostalCode ='12345';
            acc.ShippingCity ='Pune';
            acc.ShippingCountry ='India';
            acc.ShippingPostalCode = '12345';
            acc.ShippingState = 'Maharashtra';
            acc.ShippingStreet = 'Test Shipping Street';
            insert acc;
        
            Contact con = Utility.insertContactInTestClasses(acc.Id);
            con.firstname ='tesing';
			insert con;            
            Opportunity opp = Utility.insertOpportunityInTestClasses(acc.Id, con.Id, 'Discovery', 'New Business', Date.today(), Date.today(), Date.today().addDays(7), null);
            insert opp;
			
			/* ********************************************************************************************************************
				Last Modified By - Jade Global Inc, on 11th Feb 2018
				Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
		
            clzV5__Clarizen_Project__c proj = new clzV5__Clarizen_Project__c();
            proj.Sales_Survey_Status__c = 'Sent';
            proj.Name = 'test clarizen';
            proj.clzV5__Opportunity__c = opp.Id;
            proj.clzV5__CLZ_Customer__c = acc.Id;
            insert proj;
            
            PageReference pageRef = Page.SalesHandoffSurvey;
            pageRef.getParameters().put('id', String.valueOf(proj.Id));
            Test.setCurrentPage(pageRef);
            ApexPages.StandardController sc = new ApexPages.StandardController(proj);
            SaveSalesSurveyInClarizenProject survey = new SaveSalesSurveyInClarizenProject (sc);
            survey.save();
            Test.StartTest();
            SendReminderToOpportunityOwner reminder = new SendReminderToOpportunityOwner(String.valueOf(proj.Id));
            reminder.execute(null);
            Test.stopTest();
			********************************************************************************************************************* */
    }
    static testMethod void testSendReminderToOpportunityOwner() {
        Test.StartTest();
        SendReminderToOpportunityOwner reminder = new SendReminderToOpportunityOwner();
        reminder.execute(null);
        Test.stopTest();
    }
    
    static testMethod void testUpdateCLSOnAccountFromClzProject() {
        Account acc = Utility.insertAccountInTestClasses();
        acc.Type = 'Competitor';
        acc.BillingCity = 'Ichalkaranji';
        acc.BillingCountry = 'India';
        acc.BillingStreet = 'Test Street';
        acc.BillingState ='Test Billing State';
        acc.BillingPostalCode ='12345';
        acc.ShippingCity ='Pune';
        acc.ShippingCountry ='India';
        acc.ShippingPostalCode = '12345';
        acc.ShippingState = 'Maharashtra';
        acc.ShippingStreet = 'Test Shipping Street';
        insert acc;
        Contact con = Utility.insertContactInTestClasses(acc.Id);
        con.firstname ='tesing';
		insert con;            
        Opportunity opp = Utility.insertOpportunityInTestClasses(acc.Id, con.Id, 'Discovery', 'New Business', Date.today(), Date.today(), Date.today().addDays(7), null);
        insert opp;
        
		/* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
		
		clzV5__Clarizen_Project__c proj1 = new clzV5__Clarizen_Project__c();
        proj1.Sales_Survey_Status__c = 'Sent';
        proj1.Name = 'test clarizen';
        proj1.clzV5__CLZ_State__c = 'Active';
        proj1.clzV5__CLZ_ProjectType__c = 'STANLPPRO';
        proj1.clzV5__Opportunity__c = opp.Id;
        proj1.clzV5__CLZ_Customer__c = acc.Id;
        insert proj1;
        
        clzV5__Clarizen_Project__c proj2 = new clzV5__Clarizen_Project__c();
        proj2.Sales_Survey_Status__c = 'Sent';
        proj2.Name = 'test clarizen2';
        proj2.clzV5__CLZ_State__c = 'Active';
        proj2.clzV5__CLZ_ProjectType__c = 'STANLPPRO';
        proj2.clzV5__Opportunity__c = opp.Id;
        proj2.clzV5__CLZ_Customer__c = acc.Id;
        insert proj2;
        
        Utility.isUpdateCLSOnAccountFromClzProjectRunningOnceMore = false;
        proj2.clzV5__CLZ_State__c = 'Completed';
        update proj2;
		********************************************************************************************************************* */
    }
    
    
}