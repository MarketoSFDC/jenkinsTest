@istest
public class test_AssignNBAEPerRules
{
   static testmethod void mytest()
   {
      set <id> accids = new set <id>();
      AssignNBAEPerRules.ANFirstPass = True;
      map <id, account> accmap = new map <id, account>();

      Account acc=new Account(Name='test Account1',ownerid=UserInfo.getUserId());
       acc.BillingCountry = 'United States';
       acc.BillingStreet = 'Test Street';
       acc.BillingState ='Test Billing State';
       acc.BillingPostalCode ='12345';
       acc.ShippingCity ='Pune';
       acc.ShippingCountry ='India';
       acc.ShippingPostalCode = '12345';
       acc.ShippingState = 'Maharashtra';
       acc.ShippingStreet = 'Test Shipping Street';  
       acc.Accounting_Email__c = 'test@gmail.com';
       acc.Accounting_Contact_First_Name__c = 'FirstName';
       acc.Accounting_Contact_Last_Name__c = 'LastName';
       acc.Website = 'www.google.com';
       acc.Type = 'Customer';
       acc.RecordTypeId = '01250000000ULb7';
       insert acc;
       
       contact cc = new contact();
       cc.FirstName = 'grazitti';
       cc.LastName = 'test grazitti';
       cc.AccountId = acc.Id;
       insert cc;
       
      accids.add(acc.id);
      Opportunity opp=new Opportunity(Name='test Opportunity1',
                                      AccountId=acc.id,type='New Business',
                                       CloseDate=date.today(),
                                       StageName='Closed Won',
                                       ownerid=UserInfo.getUserId(),
                                       Primary_Marketo_User_Lookup__c = cc.Id,
                                       Rep_Create_ARR__c = 10,
                                       MainCompetitor__c = 'Act-On'
                                      );
      insert opp;

      List <account> acclist1 = [select id,type from account where id in :accids];
      for (Account acc1 : accList1){
         acc1.type = 'Customer';
      }

      AssignNBAEPerRules.ANFirstPass = False;
      update accList1;

      List <account> acclist2 = [select New_Business_Account_Executive__c from account where id in :accids];
      for (Account acc2 : accList2){
         //system.assertequals(UserInfo.getUserId(),acc2.New_Business_Account_Executive__c);
      }
   }
}