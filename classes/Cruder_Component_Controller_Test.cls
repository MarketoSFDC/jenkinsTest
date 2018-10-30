/*********************************
 * Class Name:Cruder_Component_Controller_Test
 * Description: Test class for Cruder_Component_Controller
 * 
 * *************************************/

@isTest
private class Cruder_Component_Controller_Test {

	private static testMethod void test() {
	    
	    Cruder_Component_Controller.retriveRecordDetail('Name','Account','Name =\'Test\'');
	    Cruder_Component_Controller.fetchRecordByQuery('Select Name From Account LIMIT 1');

	}

}