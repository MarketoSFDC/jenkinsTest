@isTest(seeAllData=true)
public class cont_SBApprovalEmail_Test {
     
     @isTest
     private static void getNonStandardTerms(){
     
        List<Account> accntList = new List<Account>();
        accntList = TestCPQUtilityClass.createAccounts(1);
        insert accntList;
        
        List<Contact> contactList = new List<Contact>();
        contactList = TestCPQUtilityClass.createContacts(accntList ,1);
        insert contactList;
         
        
        List<Opportunity> opportunityList = new List<Opportunity>();
        opportunityList = TestCPQUtilityClass.createOpportunities(accntList ,1);
        insert opportunityList;
        
        List<SBQQ__Quote__c> quoteList = new List<SBQQ__Quote__c>();
        quoteList= TestCPQUtilityClass.createQuotes(opportunityList ,1);
        insert quoteList;
        
        //SBQQ__Quote__c q=[select id from SBQQ__Quote__c limit 1];
        //SBQQ__Quote__c q=[select id from SBQQ__Quote__c limit 1];
        
        string qId=quoteList[0].id;
        
        StandardTerms__c stdTerm=new StandardTerms__c(Name='testname1234',APIName__c='testtermapiname',ApprovedTerms__c='testapprovalterm');
        insert stdTerm;
        
        //StandardTerms__c selectStdTerm=[select Name,ApprovedTerms__c from standardterms__c limit 1];
       // System.assertNotEquals(selectStdTerm,null);
       StandardTerms__c selectStdTerm=[select Name,ApprovedTerms__c from standardterms__c limit 1];
       //***Grzt System.assertEquals(selectStdTerm,Null);
        
         //getNonStandardTerms();
        // getNonStandardTerms();
       
        
     }

}