/**
    APPS-1861#Every Day - If a CAM does not update the Temperature Executive Summary or has not updated the Temperature fields 
    in 90 days, the temperature should be update to "Unknown". 
    No update should happen if the temperature is Red or Yellow. 
**/
global class AccountTemperatureToUnknownScheduler implements Schedulable {

   static final string RED     = 'Red';
   static final string YELLOW  = 'Yellow';
   static final string UNKNOWN = 'Unknown';
   
   global void execute(SchedulableContext SC) {
      Utility.isUpdateContactOwnerAsAccountOwnerRunningOnceMore = true;
      List<Account> targetAccounts = new List<Account>();
      for(Account ac : [SELECT Temperature__c, Temperature_Update_Date_Gradient__c FROM Account WHERE Temperature_Update_Date_Gradient__c >= 90 AND Temperature__c !=: RED AND Temperature__c !=: YELLOW AND Temperature__c !=: UNKNOWN LIMIT 2000]){
          ac.Temperature__c = UNKNOWN;
          targetAccounts.add(ac);
      }
      if(!targetAccounts.isEmpty()){
          Database.update(targetAccounts, false);
      }
   }
   
    static testMethod void testAccountTemperature(){ 
        Account a  = Utility.insertAccountInTestClasses();
        a.Temperature__c = 'Green';
        a.Success_Score_Updated__c = Date.Today().addDays(-100);
        a.Temp_Executive_Summary_Last_Update__c = Date.Today().addDays(-100);
        insert a;
        Test.StartTest();
        AccountTemperatureToUnknownScheduler sh1 = new AccountTemperatureToUnknownScheduler ();    
        sh1.execute(Null);
        Test.stopTest();    
    }
  
}