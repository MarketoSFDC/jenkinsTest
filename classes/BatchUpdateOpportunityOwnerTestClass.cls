@isTest
private class BatchUpdateOpportunityOwnerTestClass {

    static testmethod void test() {
        
        User newUser22 =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser2', 'Mkto', 'cfsId');
       insert newUser22 ;
       
       account[] aList = new List<account>(); 
           for (Integer i=0;i<10;i++) {
               account a = new account(
                   Name='TestAcc' + i,
                   CAM_Owner__c = newUser22.Id
                   );
               aList.add(a);
           }    
       insert aList;
       
       opportunity[] oList = new List<opportunity>();
       for (account a : aList){    
           for (Integer i=0;i<10;i++) {
               opportunity o = new opportunity(
                   Name='TestOpp' + i,
                   AccountId = a.Id,
                   Type = 'Renewal',
                   StageName = 'New Buisness',
                   CloseDate = date.today()
                   );
               oList.add(o);
           }
       }
       insert oList;
       
       set<id> accountIds = new set<Id>();
       Map<id, account> newMap = new Map<id, account>();
       for(account a:aList){
           accountIds.add(a.Id); 
           newMap.put(a.Id, a);
       }
       
       
       
       
       
       Test.startTest();
            Database.executeBatch(new BatchUpdateOpportunityOwner(accountIds,newMap),100);
       Test.stopTest();
    }
}