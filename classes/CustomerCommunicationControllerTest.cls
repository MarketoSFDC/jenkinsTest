@isTest(SeeAllData = false)
public class CustomerCommunicationControllerTest{

    static String str = 'Account Prefix,munchkin Id \n s016,AB-12345\n,ab01,Test-12356'; 
    static String str3 = 'munchkin Id,Account Prefix \n AB-12345,s016,\n Test-123,ab01'; 
    static String str2 = 'Munchkin Id \n AB-12345'; 
    public static String[] csvFileLines;
    public static Blob csvFileBody;
    
    @testSetup static void getUserDataafterInser(){
        List<Account> accsToInsert = new List<Account>();
        Account acc = new Account();
                acc.Name = 'Test Account For Entitlement';
        accsToInsert.add(acc);
        
        Account acc2 = new Account();
                acc2.Name = 'Test Account For Entitlement2';
        accsToInsert.add(acc2);
        
        insert accsToInsert;
        Contact con = new Contact(
                FirstName = 'Tes1t',
                LAstName = 'Test',
                Email = 'test@test.com',
                Accountid =  accsToInsert[0].id   
            );
        insert con;
        
        Asset as2 = new Asset();
        as2.Name = 'Test Asset 5';
        as2.installdate = System.today();
        as2.UsageEndDate = System.today().addMonths(1);
        as2.Purpose__c = 'Production';
        as2.Asset_Type__c = 'Subscription';
        as2.AccountID = acc.ID;
        as2.POD__c = 'ab01;s016';
        insert as2;
        
        List<Entitlement> entsToInsert = new List<Entitlement>();
        Entitlement ent2 = new Entitlement();
                    ent2.AccountId = accsToInsert[0].id;
                    ent2.Asset = as2;
                    ent2.Name = 'Test Entitlement543232145';
                    ent2.EndDate = System.Now().Date().addDays(90);
                    ent2.StartDate = System.Now().Date().addDays(-90);
                    ent2.AccountId = acc.Id;
                    ent2.Type = 'Elite';
                    ent2.AssignedSupportPOC__c = userInfo.getuserId();
                    //ent2.status='Active';
                    entsToInsert.add(ent2);
                    
      Entitlement ent3 = new Entitlement();
                    ent3.AccountId = accsToInsert[0].id;
                    ent3.Asset = as2;
                    ent3.Name = 'Test Entitlement54321';
                    ent3.EndDate = System.Now().Date().addDays(90);
                    ent3.StartDate = System.Now().Date().addDays(-90);
                    ent3.AccountId = acc.Id;
                    ent3.Type = 'Business';
                    ent3.AssignedSupportPOC__c = userInfo.getuserId();
                    entsToInsert.add(ent3);
               //     insert ent3;
                    
       Entitlement ent4 = new Entitlement();
                    ent4.AccountId = accsToInsert[0].id;
                    ent4.Asset = as2;
                    ent4.Name = 'Test Entitlement0000000';
                    ent4.EndDate = System.Now().Date().addDays(90);
                    ent4.StartDate = System.Now().Date().addDays(-90);
                    ent4.AccountId = acc.Id;
                    ent4.Type = 'Premier';
                    ent4.AssignedSupportPOC__c = userInfo.getuserId();
                    entsToInsert.add(ent4);
                    insert entsToInsert;
                    
                    List<Authorized_Contact__c> authConToInsert = new List<Authorized_Contact__c>();
                    Authorized_Contact__c authCon = new Authorized_Contact__c(
                        Customer_Admin__c = false, contact__c = con.id, Entitlement__c = ent2.id
                    ); 
                    authConToInsert.add(authCon);
                    
                    Authorized_Contact__c authCon2 = new Authorized_Contact__c(
                        Customer_Admin__c = true, contact__c = con.id, Entitlement__c = ent2.id
                    ); 
                    authConToInsert.add(authCon2);
                    insert authConToInsert;                    
    }
    static testmethod void CustomerCommunicationCntrlerTest(){
                  
        Test.startTest(); 
        getUserDataafterInser();      
        List<entitlement> ent = [Select id from entitlement where name='Test Entitlement0000000' limit 1];
        Customer_Communication__c cc = new Customer_Communication__c();
        cc.Level_Clone__c = 'Premier';
        cc.Subject__c = 'Test';
        cc.To_Address__c = 'amanb@grazitti.com';
        cc.Send_Email__c = true;
        cc.Customers__c = 'All My Customers';
        cc.Pod__c = 'ab01';
        cc.Date_Time__c = System.now().addminutes(10);
        cc.Email_Behalf_Of_Tse__c = true;
        insert cc;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(cc);
        CustomerCommunicationController ccc = new CustomerCommunicationController(sc);
        ccc.blockSize = 1;
        ccc.fetchEntitlementData();
        
        ccc.fetchEntitlementData();
        
        ccc.insertRecords();
        //ccc.getAllEntSelectedData();
        ccc.NextPage();
        //
        ccc.backPage();
        ccc.backToSecond();
        ccc.optionPicker();
        ccc.beginning();
        ccc.next();
        ccc.uncheckedIds.add(ent[0].id);
        ccc.previous();
        ccc.next();
        ccc.end();
        ccc.getprev();
        ccc.getnxt();
        //CustomerCommunicationController.IncCodeCoverage();
        ccc.finalRecordSize = 2001;
        ccc.createFinalListOfEntitlements();
        
        cc.Customers__c = 'All My Customers';
        cc.Level_Clone__c = 'Elite';
        cc.POD__c = null;
        cc.Send_Email__c = true;
        update cc;
        
        ApexPages.StandardController scck = new ApexPages.StandardController(cc);
        CustomerCommunicationController cc1k = new CustomerCommunicationController(scck);
        cc1k.fetchEntitlementData();
        
        cc.Customers__c = 'All My Customers';
        cc.Level_Clone__c = null;
        cc.POD__c = 'ab01;sj04';
        cc.Send_Email__c = true;
        update cc;
        
        ApexPages.StandardController scc = new ApexPages.StandardController(cc);
        CustomerCommunicationController cc1 = new CustomerCommunicationController(scc);
        cc1.fetchEntitlementData();
        
        
        
        
        cc.Customers__c = 'All My Customers';
        cc.Level_Clone__c = null;
        cc.POD__c = null;
        cc.Send_Email__c = true;
        update cc;
        
        ApexPages.StandardController scc1 = new ApexPages.StandardController(cc);
        CustomerCommunicationController cc2 = new CustomerCommunicationController(scc1);
        cc2.fetchEntitlementData();
        
        cc.Customers__c = 'All customers';
        cc.Level_Clone__c = 'Elite;Business;premier';
        cc.POD__c= 'ab01;sj04';
        cc.Send_Email__c = true;
        update cc;
        
        ApexPages.StandardController sc1 = new ApexPages.StandardController(cc);
        CustomerCommunicationController ccc1 = new CustomerCommunicationController(sc1);
        ccc1.fetchEntitlementData();
        
        cc.Customers__c = 'All customers';
        cc.Level_Clone__c = null;
        cc.POD__c= 'ab01;sj04';
        cc.Send_Email__c = true;
        update cc;
        
        ApexPages.StandardController sc3 = new ApexPages.StandardController(cc);
        CustomerCommunicationController ccc3 = new CustomerCommunicationController(sc3);
        ccc3.fetchEntitlementData();
        
        cc.Customers__c = 'All customers';
        cc.Level_Clone__c = 'Elite;Business;premier';
        cc.POD__c= null;
        cc.Send_Email__c = true;
        update cc;
        
        ApexPages.StandardController sc5 = new ApexPages.StandardController(cc);
        CustomerCommunicationController ccc5 = new CustomerCommunicationController(sc5);
        ccc5.fetchEntitlementData();
        
        cc.Customers__c = 'All customers';
        cc.Level_Clone__c = null;
        cc.POD__c= null;
        cc.Send_Email__c = true;
        update cc;
        
        ApexPages.StandardController sc6 = new ApexPages.StandardController(cc);
        CustomerCommunicationController ccc6 = new CustomerCommunicationController(sc6);
        ccc6.fetchEntitlementData();
        
        cc.Customers__c = 'All customers';
        cc.Level_Clone__c = 'Elite;Business;premier';
        cc.POD__c= 'ab01;sj04';
        cc.Send_Email__c = true;
        update cc;
        
        
        ApexPages.StandardController sc2 = new ApexPages.StandardController(cc);
        CustomerCommunicationController ccc2 = new CustomerCommunicationController(sc2);
        
        csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 
        ccc2.nameFile = 'test.csv';
        ccc2.contentFile = csvFileBody;
        ccc2.fetchCsvData();
        
        cc.Customers__c = 'Csv Option';
        cc.Level_Clone__c = 'Elite;Business;premier';
        cc.POD__c= null;
        cc.Send_Email__c = true;
        update cc;
        
        ApexPages.StandardController sc4 = new ApexPages.StandardController(cc);
        CustomerCommunicationController ccc4 = new CustomerCommunicationController(sc4);
        csvFileBody = Blob.valueOf(str);
        String csvAsString1 = csvFileBody.toString();
        csvFileLines = csvAsString1.split('\n'); 
        ccc4.nameFile = 'test1.csv';
        ccc4.contentFile = csvFileBody;
        ccc4.fetchCsvData();
       // ccc4.fetchEntitlementData();
        ccc4.next();
       // ccc4.previous();
        
        ApexPages.StandardController sc8 = new ApexPages.StandardController(cc);
        CustomerCommunicationController ccc8 = new CustomerCommunicationController(sc8);
        cc.Customers__c = 'Csv option';
        csvFileBody = Blob.valueOf(str);
        String csvAsString11 = csvFileBody.toString();
        csvFileLines = csvAsString11.split('\n'); 
        ccc4.nameFile = 'test1.csvv';
        ccc4.contentFile = csvFileBody;
        ccc4.fetchCsvData();
        ccc4.fetchEntitlementData();        
        Test.stopTest();
    }
    
    static testmethod void CustomerCommunicationCntrlerTest2(){
        Test.startTest(); 
        Customer_Communication__c cc = new Customer_Communication__c();
        cc.Customers__c = 'Csv Option';
        cc.Level_Clone__c = 'Elite;Business;premier';
        cc.POD__c= null;
        cc.Send_Email__c = true;
        insert cc;
        
        
        ApexPages.StandardController sc2 = new ApexPages.StandardController(cc);
        CustomerCommunicationController ccc2 = new CustomerCommunicationController(sc2);
        
        csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 
        ccc2.nameFile = 'test2.csv';
        ccc2.contentFile = csvFileBody;
        ccc2.fetchCsvData();
        
        
        
        Test.stopTest(); 
    
    }
    static testmethod void CustomerCommunicationCntrlerTest3(){
        Test.startTest(); 
        Customer_Communication__c cc = new Customer_Communication__c();
        cc.Customers__c = 'All My Customers';
        cc.Level_Clone__c = null;
        cc.POD__c= null;
        cc.Send_Email__c = true;
        insert cc;
        
        
        ApexPages.StandardController sc2 = new ApexPages.StandardController(cc);
        CustomerCommunicationController ccc2 = new CustomerCommunicationController(sc2);
        
        csvFileBody = Blob.valueOf(str);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 
        ccc2.nameFile = 'test3.csv';
        ccc2.contentFile = csvFileBody;
        ccc2.fetchCsvData();
        
        
        
        Test.stopTest(); 
    
    }
    static testmethod void CustomerCommunicationCntrlerTest4(){
        Test.startTest(); 
        Customer_Communication__c cc = new Customer_Communication__c();
        cc.Customers__c = 'All My Customers';
        cc.Level_Clone__c = 'Elite;Business;premier';
        cc.POD__c= 'ab01';
        cc.Send_Email__c = true;
        insert cc;
        
        
        ApexPages.StandardController sc2 = new ApexPages.StandardController(cc);
        CustomerCommunicationController ccc2 = new CustomerCommunicationController(sc2);
        
        csvFileBody = Blob.valueOf(str3);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 
        ccc2.nameFile = 'testing.csv';
        ccc2.contentFile = csvFileBody;
        ccc2.fetchCsvData();
        //ccc2.getCSVRecords();
        
        
        
        Test.stopTest(); 
    
    }
    
    
    
    
    
    
     static testmethod void CustomerCommunicationSchedulerTest(){
        Test.startTest();
        
        Customer_Communication__c cc = new Customer_Communication__c();
        cc.Customers__c = 'Csv Option';
        cc.Level_Clone__c = 'Elite;Business;premier';
        cc.POD__c = 'ab01;sj04';
        cc.Send_Email__c = true;
        cc.Description__c = 'Testing Elite';
        cc.Create_Cases__c ='Proactive Case';
        cc.Subject__c = 'Test Subject';
        insert cc;
        
        ApexPages.StandardController sc2 = new ApexPages.StandardController(cc);
        CustomerCommunicationController ccc2 = new CustomerCommunicationController(sc2);
        
        csvFileBody = Blob.valueOf(str3);
        String csvAsString = csvFileBody.toString();
        csvFileLines = csvAsString.split('\n'); 
        ccc2.nameFile = 'testindg.csv';
        ccc2.contentFile = csvFileBody;
        ccc2.fetchCsvData();
        //ccc2.getCSVRecords();
        
        contact c = new contact(lastname = 'test',email='amanb@grazitti.com');
        insert c;
        
        contact c2 = new contact(lastname = 'test2',email ='amanb@grazitti.com');
        insert c2;
        
        
         List<Customer_Communication_Action__c> ccaList = new List<Customer_Communication_Action__c>();
         Set<Id> ccaIds = new Set<Id>();
         for(integer i=0; i<10; i++){
            ccaList.add(new Customer_Communication_Action__c(Case_Creation__c = true,Email_Sent__c = true ,Customer_Communication__c = cc.Id ,Contact__c = c.Id,Contact_1__c = c2.Id));
         }
         insert ccaList;
         for(Customer_Communication_Action__c cId : ccaList){
             ccaIds.add(cId.Id);
         }

         CustomerCommunicationScheduler ccs = new CustomerCommunicationScheduler(ccaList,false);
         ccs.execute(null);
         CustomerCommunicationBatch b = new CustomerCommunicationBatch(ccaIds,false);
         ID batchprocessid = Database.executeBatch(b);
         Test.stopTest();

     }    
}