/* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
********************************************************************************************************************* */
@isTest (SeeAllData=true)
public class TestSMB_SendSurveyOnLP_Closed{

     /*****Code for unit testing ---started*****/
    public static testMethod void testTrigger() {
        Account ac = Utility.insertAccountInTestClasses(); 
        ac.BillingCountry = 'United States';
        ac.BillingStreet = 'Test Street';
        ac.BillingState ='Test Billing State';
        ac.BillingPostalCode ='12345';
        ac.ShippingCity ='Pune';
        ac.ShippingCountry ='India';
        ac.ShippingPostalCode = '12345';
        ac.ShippingState = 'Maharashtra';
        ac.ShippingStreet = 'Test Shipping Street';  
        ac.Accounting_Email__c = 'test@gmail.com';
        ac.Accounting_Contact_First_Name__c = 'FirstName';
        ac.Accounting_Contact_Last_Name__c = 'LastName';
        ac.Website = 'www.google.com';
        insert ac;
        ac.Business_Unit__c = 'AMER-SB';
        update ac;      
        Contact c = Utility.insertContactInTestClasses(ac.Id);
        insert c;  
        opportunity op = Utility.insertOpportunityInTestClasses(ac.id, c.Id, 'Discovery', 'New Business',Date.Today(), system.today().addDays(-111),system.today(), system.today().addDays(-3));        
        insert op;
        
		/* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
		
        clzV5__Clarizen_Resource__c cr = new clzV5__Clarizen_Resource__c(
                                              Name ='SMBResourceTestSMB-2',
                                              clzV5__CLZ_State__c = 'Active'
                                          );
        insert cr;
        clzV5__Clarizen_Project__c lpProj = new clzV5__Clarizen_Project__c(
                                                Name = 'SMBProjectTest-2',
                                                clzV5__CLZ_N_ProjectManager__c = cr.Id,
                                                clzV5__CLZ_State__c = 'Active',
                                                CLZ_C_BusinessUnit__c = 'AMER-SB',
                                                CLZ_C_ProjectFamily__c = 'MLMLP',
                                                clzV5__CLZ_Customer__c= ac.Id,
                                                clzV5__CLZ_ProjectType__c = 'BASELP',
                                                clzV5__Opportunity__c = op.Id
                                                
                                               );
        insert lpProj ;    
        system.debug(lpProj+'AFTERINSERT'); 
        SMB_Survey_Util.run = true;
        lpProj.clzV5__CLZ_State__c = 'Completed';
        update lpProj ;
        system.debug(lpProj+'AFTERTRIGGER');
		
		********************************************************************************************************************* */
		
      
    }
    
    
    public static testMethod void testschedule() {
        Test.StartTest();
       
        SMB_ScheduledSurveyMail sh1 = new SMB_ScheduledSurveyMail();
        DateTime timeToSendMail = system.now().addseconds(200);
        String sch = '' + timeToSendMail.second() + ' ' + timeToSendMail.minute() + ' ' + timeToSendMail.hour() + ' ' + timeToSendMail.day() + ' ' + timeToSendMail.month() + ' ? ' + timeToSendMail.year();
        String sId = system.schedule('Test'+system.now(), sch, sh1);
        
		/* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
		
		clzV5__Clarizen_Project__c lpProj = new clzV5__Clarizen_Project__c(
                                                clzV5__CLZ_State__c = 'Active',
                                                CLZ_C_BusinessUnit__c = 'AMER-MM',
                                                CLZ_C_ProjectFamily__c = 'MLMLP'
        
                                                );
        insert lpProj ;  
		********************************************************************************************************************* */
        /*SMB_SheduledJobInfo__c  jobProj = new  SMB_SheduledJobInfo__c(
                                           SheduledJobId__c = sId,
                                           ProjectId__c = lpProj.Id
                                          );
        insert jobProj ;*/
        Test.stopTest();
        
        }
}