@IsTest
public class ApprovalsRenderingComponentConTest {

 public static testMethod void TestApprovalsRenderingComponentController(){      
        // Create accounts to insert
        Set<Id> accountsToInsertSet = new Set<Id>();
        map<id, id> AccToCont = new Map<id,id>();
        List<Account> accountsToInsertList = new List<Account>();

        for(Account accnt: TestCPQUtilityClass.createAccounts(1)){
            accnt.BillingCountry = 'United States';
            accnt.BillingStreet = 'Test Street';
            accnt.BillingState ='Test Billing State';
            accnt.BillingPostalCode ='12345';
            accnt.ShippingCity ='Pune';
            accnt.ShippingCountry ='India';
            accnt.ShippingPostalCode = '12345';
            accnt.ShippingState = '';
            accnt.ShippingStreet = 'Test Shipping Street';  
            accnt.Accounting_Email__c = 'test@gmail.com';
            accnt.Accounting_Contact_First_Name__c = 'FirstName';
            accnt.Accounting_Contact_Last_Name__c = 'LastName';
            accnt.Website = 'www.google.com';
            accnt.MA_Edition__c ='Edition';
            accnt.RTP_Suite__c = 'Suite';
            accnt.Add_On_Subscriptions__c ='Subscription';
            accnt.Services__c = 'Sevices';
            accnt.Support__c ='Support';
            accountsToInsertList.add(accnt);
        }
            insert accountsToInsertList;
            for(Account acc : accountsToInsertList){
                accountsToInsertSet.add(acc.Id);
            }
           
      
        
       
      
        
        // insert opportunities - for Closed Won Oppty - Contract will be created automatically
        List<Opportunity> opptyList = new List<Opportunity>();
        opptyList = TestCPQUtilityClass.createOpportunities(accountsToInsertList,1);
        for(Opportunity opp : opptyList){
            opp.Amount = 2000;
           
            opp.Deal_Type__c='Services';
            opp.Owner_Role_Custom_Text__c = 'Test';
            opp.OwnerId=UserInfo.getUserId();
           
        }
        
        Test.startTest();
       // Test.startTest(); 
        if(!opptyList.isEmpty()){
            insert opptyList;
        }
       List<SBQQ__Quote__c> quotList = TestCPQUtilityClass.createQuotes(opptyList,  1);
         List<SBQQ__Quote__c> InsertquotList = new List<SBQQ__Quote__c>();
          for(SBQQ__Quote__c quote : quotList){
              quote.SBQQ__Primary__c = true;
              InsertquotList.add(quote);
          }
          insert InsertquotList;
          ApprovalsRenderingComponentController approvalRenderConObj = new ApprovalsRenderingComponentController();
          List<sbaa__Approval__c> approvalList=ApprovalsRenderingComponentController.getApprovalLinesList();
        
        Test.Stoptest();
       }
   }