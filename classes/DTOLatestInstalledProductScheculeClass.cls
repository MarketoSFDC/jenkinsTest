/***************************************************************
* Created by         : Rajesh Wani
* Created Date       : 26th September  2014
* Last Modified By   : Rajesh Wani 26th September  2014
* Purpose            : This is used to
                       1.Schedule batch class DTOLatestInstalledBatchclass which is used to uncheck Latest_Installed_Product__c flag on DTO                   
******************************************************/

global class DTOLatestInstalledProductScheculeClass implements Schedulable {

   global void execute(SchedulableContext sc) {
   /*
      DTOLatestInstalledBatchclass DTOInstalltedBatch = new DTOLatestInstalledBatchclass(); 
      database.executebatch(DTOInstalltedBatch);
	  */
   }//End of execute method
   
   
    static testmethod void DTOLatestInstalledProductScheculeClassTest(){
	test.startTest();
		DTOLatestInstalledProductScheculeClass dtc = new DTOLatestInstalledProductScheculeClass();
		dtc.execute(Null);
	test.stopTest();
	}

}