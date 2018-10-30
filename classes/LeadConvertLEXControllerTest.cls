@IsTest
public class LeadConvertLEXControllerTest {
  @IsTest
    public static void testQuickActionMethods() {
        Account accountObj = new Account();
        accountObj.Name = 'TEST99999';
        insert accountObj;
    
        Lead leadObj = new Lead();
        leadObj.FirstName = 'XXXJoe23523523'; 
        leadObj.LastName = 'XXXXSmith5253253';
        leadObj.LeadSource = ' Customer';
        leadObj.Email = 'test@testXXtestst.com';
        leadObj.Account__c = accountObj.Id;
        leadObj.City = 'LALALA';
        leadObj.Country = 'USA';
        leadObj.PostalCode = '75022';
        leadObj.State = 'TX';
        leadObj.Street = '123 Test';
        leadObj.Company = 'TEST COMPANY';
        //leadObj.mkto_si__Last_Interesting_Moment_Date__c;
        leadObj.Phone = '(224)242-2424';
        leadObj.Lead_Source_Comments__c = 'TEST';
        insert leadObj; 
        
        Test.startTest();
        LeadConvertLEXController.validProfileForConversion();
        LeadConvertLEXController.validLeadStatus(leadObj.Id);
        LeadConvertLEXController.convertLead(leadObj.Id);
        Test.stopTest();


    }
  @IsTest
    public static void testDuplicateMethods() {
        Account accountObj = new Account();
        accountObj.Name = 'TEST99999';
        insert accountObj;
    	Contact testContact = new Contact(
        	FirstName = 'XXXJoe23523523',
        	LastName = 'XXXXSmith5253253',
            Email = 'test@testXXtestst.com',
            AccountId = accountObj.Id
        );
        insert testContact;
        Lead leadObj = new Lead();
        leadObj.FirstName = 'XXXJoe23523523'; 
        leadObj.LastName = 'XXXXSmith5253253';
        leadObj.LeadSource = ' Customer';
        leadObj.Email = 'test@testXXtestst.com';
        leadObj.Account__c = accountObj.Id;
        leadObj.City = 'LALALA';
        leadObj.Country = 'USA';
        leadObj.PostalCode = '75022';
        leadObj.State = 'TX';
        leadObj.Street = '123 Test';
        leadObj.Company = 'TEST COMPANY';
        //leadObj.mkto_si__Last_Interesting_Moment_Date__c;
        leadObj.Phone = '(224)242-2424';
        leadObj.Lead_Source_Comments__c = 'TEST';
        insert leadObj; 
        
        Test.startTest();
        LeadConvertLEXController.validProfileForConversion();
        LeadConvertLEXController.validLeadStatus(leadObj.Id);
        LeadConvertLEXController.convertLead(leadObj.Id);
        LeadConvertLEXController.updateLeadAndUpsertContact(leadObj.Id, testContact.Id, testContact); 
        Test.stopTest();


    }

}