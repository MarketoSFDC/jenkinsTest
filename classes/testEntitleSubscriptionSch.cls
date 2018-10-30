@istest
class testEntitleSubscriptionSch {  

   static testmethod void test() {
   
      Account testAcc = new Account();
      testAcc.Name = 'test';
      insert testAcc;
       
      Entitlement testEntitle = new Entitlement();
      testEntitle.AccountId = testAcc.Id;
      testEntitle.Name = 'test';
      testEntitle.StartDate = System.Today();
      testEntitle.EndDate = System.Today().addDays(1);
      testEntitle.Processed_for_grace__c = FALSE;
      insert testEntitle;
      
      // Insert Renewal Entitlement
      Entitlement renEnt = new Entitlement();
      renEnt.AccountId = testAcc.Id;
      renEnt.Name = 'test';
      renEnt.Previous_Entitlement__c = testEntitle.Id;
      renEnt.StartDate = System.Today().addDays(2);
      renEnt.EndDate = System.Today().addDays(60);
      insert renEnt;
      
      Test.startTest();      
      entitlementSubscriptionGrace obj_entitleGrace = new entitlementSubscriptionGrace();
      obj_entitleGrace.execute(null);
      Test.stopTest();      

   }
    
    public static testMethod void renEntNotCreated(){
        Account testAcc = new Account();
        testAcc.Name = 'test';
        insert testAcc;
        
        Entitlement testEntitle = new Entitlement();
        testEntitle.AccountId = testAcc.Id;
        testEntitle.Name = 'test';
        testEntitle.StartDate = System.Today();
        testEntitle.EndDate = System.Today().addDays(1);
        testEntitle.Processed_for_grace__c = FALSE;
        insert testEntitle;
        
        entitlementSubscriptionGrace obj_entitleGrace = new entitlementSubscriptionGrace();
        obj_entitleGrace.execute(null);
    }
}