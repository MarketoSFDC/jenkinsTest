@isTest
public class CasesFromPreviousMonthControllerTest{
       static testmethod void testMethod1(){
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            User u = new User(Alias = 'Testu', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, 
            TimeZoneSidKey='America/Los_Angeles', UserName='testuseringss44@testorg.com'); 
            insert u;
            
            Account acc=new Account();
            acc.name = 'Test account';
            insert acc;
            
            Contact con = new Contact();
            con.lastname='xyz';
            con.accountid = acc.id;
            insert con;
            
            Case cs=new Case();
            cs.AccountID = acc.id;
            cs.Priority = 'P1';
            cs.contactid = con.id;
            cs.description='test';
           	
            insert cs;

            Manger_Activity_Log__c mal = new Manger_Activity_Log__c();
            mal.SupportManager__c = u.id;
            mal.TseName__c = u.id;
            mal.Evaluation_Started__c = date.newinstance(System.now().year(), System.now().month(), System.now().day());
            mal.Evaluation_Ended__c = mal.Evaluation_Started__c.addDays(30);
            mal.Status__c = 'Completed';
            mal.Status_Changed_For_Manager_Activity_Log__c = true;
            insert mal;

           Store_Cases_For_Month__c sc = new Store_Cases_For_Month__c();
           sc.Evaluation_Status__c = 'Evaluate';
           sc.Case__c = cs.id;
           sc.Manger_Activity_Log__c = mal.id; 
           insert sc;
           
            CasesFromPreviousMonthController cpfr =new CasesFromPreviousMonthController();
            cpfr.setManagerId (u.id);
            cpfr.ManagerActivityLogId = u.id;
            cpfr.getManagerId();
            cpfr.getActivityLogFromCurrentMonth();
            cpfr.getActivityLogFromPreviousMonth();
            cpfr.previousMonStoredCases = new List<Store_Cases_For_Month__c>(); 
            cpfr.listOfPreviousCasesToBeDisplayed = new List<Store_Cases_For_Month__c>(); 
            
               
        }
}