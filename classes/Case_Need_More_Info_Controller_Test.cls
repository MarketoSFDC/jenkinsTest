@isTest
private class Case_Need_More_Info_Controller_Test {

	private static testMethod void test() {
	    
	   Case_Need_More_Info_Controller controller = new Case_Need_More_Info_Controller();
	   Account acc = new Account();
       acc.name = 'testAccount';
       insert acc;
       
       Contact con=new contact();
       con.accountid=acc.id;
       con.lastname='tester';
       insert con;
       
       Case cs=new Case();
       cs.accountid = acc.id;
       cs.contactid=con.id;
       cs.origin = 'Voicemail';
       insert cs;
       
       ApexPages.currentPage().getParameters().put('Id',cs.id);
       controller.updateCaseStatus();
       
       
       

	}

}