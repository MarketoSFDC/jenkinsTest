@isTest
private class Update_Contact_To_Intacct_Test {

	private static testMethod void test() {
	      List<Account> accntList = new List<Account>();
         Set<Id> OppSet=new Set<Id>();
         accntList = TestCPQUtilityClass.createAccounts(1);
         accntList[0].Name='Jade Test Account';
         if(!accntList.isEmpty()){
             insert accntList;
         }
         
	     List<Contact> contactList = new List<Contact>();
         contactList = TestCPQUtilityClass.createContacts(accntList,1);
         contactList[0].FirstName='Snehal';
         contactList[0].LastName='Khot';
         contactList[0].MailingCity='Pune';
         contactList[0].MailingState='Maharashtra';
         contactList[0].MailingCountry='Canada';
         contactList[0].MailingPostalCode='411014';
         contactList[0].MailingStreet='Nagar Road';
         contactList[0].Phone='(999) 999-9999';
         contactList[0].Email='skhot@marketo.com';
       //  contactList[0].Contact_Synced_to_Intacct__c = true;
         if(!contactList.isEmpty()){
            insert contactList;
         }
         
         Update_Contact_To_Intacct_Controller cotroller= new Update_Contact_To_Intacct_Controller();
         
         List<Opportunity> NewoppotyList    = TestCPQUtilityClass.createOpportunities(accntList, 1);
         
          Update_Contact_To_Intacct_Controller.UpdateContactToIntacct(contactList[0].id);
          Update_Contact_To_Intacct_Controller.sendContactDetailsToIntacct(NewoppotyList[0].Id);
          Update_Contact_To_Intacct_Controller.retriveCurrentUserProfileName();

	}

}