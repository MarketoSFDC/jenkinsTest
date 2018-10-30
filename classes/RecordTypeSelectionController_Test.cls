@isTest
private class RecordTypeSelectionController_Test {

	private static testMethod void test() {
	    
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
       
	   RecordTypeSelectionController.fetchRecordTypeValues();
	   RecordTypeSelectionController.fetchCaseRecordDetail(cs.Id);
	   RecordTypeSelectionController.getRecTypeId('CS Ops Cases');
	}

}