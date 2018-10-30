@isTest
public class CAMHistoryUpdate_Test{

     static testmethod void TestingCAMHistoryUpdateMethod(){
     
         Account a = new Account();
         a.Name = 'CamAccount';
          
         insert a;
         
         Contact cc = new Contact(LastName='abc');
         
         insert cc;
         
         Customer_Account_Management_History__c c = new Customer_Account_Management_History__c ();
         c.RecordTypeId = Schema.SObjectType.Customer_Account_Management_History__c.getRecordTypeInfosByName().get('Marketo').getRecordTypeId();
         c.Contact__c = cc.Id;
         c.Notes_Next_Steps__c ='asdasdasdasdasdasddddsds';
         c.Summary__c= 'aasdasdasdasdasdasdasdasdasdasd';
         c.Temperature__c ='Red';
         c.Temperature_Reason__c ='ROI';
         c.Temperature_Sub_Reason__c ='No ROI with Reporting';
		 c.Purpose__c ='Marketing Maturity Curve Assessment';
		 c.Marketing_Maturity_Primary_Focus__c = 'Advanced Nurturing';
		 c.Marketing_Maturity_Secondary_Focus__c = 'Advanced Nurturing';
         c.Account__c = a.Id;
         
         insert c;
         
         
     
     }
}