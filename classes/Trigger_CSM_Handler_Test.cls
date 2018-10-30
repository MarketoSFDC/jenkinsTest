@isTest

public class Trigger_CSM_Handler_Test {

    public static testmethod void testTicketInsert()
    {
	Account acct = new Account(Name = 'Test');
    insert acct;
    CSM_Ticket__c ticket = new CSM_Ticket__c(Name='Test', Bizible_Account_Id__c = acct.id);
    insert ticket;    
    }
}