@isTest
Public class ProactometerBatchTest{

    static testMethod void ProactometerBatchTestMethod() {
            Support_Switches__c csobj1 = new Support_Switches__c(name = 'ProactometerBatchSwitch',isActive__c = 'Yes');
            insert csobj1;
            
            Support_Switches__c csobj2 = new Support_Switches__c(name = 'ProactiveOpenCasesBatchSwitch',isActive__c = 'Yes');
            insert csobj2;
            
            Account account1 = new Account (name='test_Account1');
            Insert account1;
            
            Contact cont = new Contact(lastname = 'Aman',accountId = account1.Id);
            Insert cont;
            
            Entitlement ent4 = new Entitlement(AccountId = account1.id,Name = 'Test Entitlement54321',EndDate = System.Now().Date().addDays(90),StartDate = System.Now().Date().addDays(-90),Type = 'Elite');
            insert ent4;
            
            Authorized_Contact__c authCon = new Authorized_Contact__c(Customer_Admin__c = false, contact__c = cont.id, Entitlement__c = ent4.id,Email_read__c =false); 
            insert authCon;
         
            Case cse = new Case(EntitlementId = ent4.Id,accountId = account1.Id,contactId = cont.Id,category__c = 'Kick Off Call',recordtypeId = Label.SupportCaseRecordTypeId,status = 'New');
            Insert cse;
            Test.setCreatedDate(cse.Id, System.Now().addDays(-5));  
            
            Proactive_Data__c p = new Proactive_Data__c(contact__c = cont.Id,Entitlement__c =ent4.Id);
            insert p;

            Test.StartTest();
    
            ProactometerBatch newTopicsUpdate = new ProactometerBatch();
            Database.executeBatch(newTopicsUpdate);
            
            ProactiveOpenCasesScheduler ps = new ProactiveOpenCasesScheduler();
            ps.execute(null);
            
            ProactiveOpenCasesBatch pb= new ProactiveOpenCasesBatch();
            Database.executeBatch(pb);
            
            ProactometerScheduler pc = new ProactometerScheduler();
            pc.execute(null);
            
            Test.StopTest();   
        }

}