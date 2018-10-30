global class MKT_AssignQueueProcessingScheduled implements Schedulable {
    public Integer JobsSizeLimit = 4;
    global static String Schedule(Integer minute) {
            String seconds = '0';
            String minutes = String.valueOf(system.now().addMinutes(minute).minute()); //Execute at every Nth minute of hour
            String hours = '*'; // Execute Every Hour
            String dayOfMonth = '*'; // Execute Every Day of the Month
            String month = '*';
            String dayOfWeek = '?'; //Execute on all 7 days of the Week
            String year = '*'; //
            String CRON_EXP = seconds + ' ' + minutes + ' ' + hours + ' ' + dayOfMonth + ' ' + month + ' ' + dayOfWeek + ' ' + year;
            List<AsyncApexJob> StartedScheduledJobsList = [SELECT Status, MethodName, JobType, ApexClass.Name, ApexClassId FROM AsyncApexJob WHERE Jobtype = 'ScheduledApex' AND ( Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing') AND ApexClass.Name = 'MKT_AssignQueueProcessingScheduled'];
        return StartedScheduledJobsList.size() == 0 ? System.schedule('MKT_AssignQueueProcessingScheduled',CRON_EXP,new MKT_AssignQueueProcessingScheduled()) : NULL;
    }

    global void execute(SchedulableContext sc) {
        Integer JobsSize;
        List<AsyncApexJob> StartedJobsList = [SELECT TotalJobItems, Status, ParentJobId, JobType, Id, ApexClass.Name, ApexClassId FROM AsyncApexJob WHERE Jobtype = 'BatchApex' AND ( Status = 'Queued' OR Status = 'Processing')];
        JobsSize = StartedJobsList.Size();
        List<MKT_AssignQueue__c> PendingAssignList = new List<MKT_AssignQueue__c>();
        List<MKT_AssignQueue__c> PendingAssignListToProc = new List<MKT_AssignQueue__c>();
        Map<String, MKT_AssignQueue__c> ProccessingAssignMap = new Map<String, MKT_AssignQueue__c>();

        Set<String> ProccessingJobsSet = new Set<String>();

        Map<String, AsyncApexJob> ClassNameJobItemMap = new Map<String, AsyncApexJob>();
        for (AsyncApexJob StartedJob :StartedJobsList) {
            ClassNameJobItemMap.Put(StartedJob.ApexClass.Name, StartedJob);
        }
        Integer JobsSizeTemp = JobsSize;
        for (MKT_AssignQueue__c AssignQueueItem : [SELECT ID, MKT_AsyncApexJobId__c, MKT_Status__c, MKT_ApexClassName__c, MKT_SerializedData__c FROM MKT_AssignQueue__c WHERE MKT_Status__c = 'Pending' OR MKT_Status__c = 'Proccessing']) {
            //Find Pending Jobs
            if (AssignQueueItem.MKT_Status__c == 'Pending') {
                if (!ClassNameJobItemMap.containsKey(AssignQueueItem.MKT_ApexClassName__c) && JobsSizeTemp<= JobsSizeLimit) {
                    PendingAssignListToProc.Add(AssignQueueItem);
                    JobsSizeTemp ++;
                }
                else {
                    PendingAssignList.Add(AssignQueueItem);
                }
            }
            if (AssignQueueItem.MKT_Status__c == 'Proccessing' && AssignQueueItem.MKT_AsyncApexJobId__c != NULL) {
                ProccessingAssignMap.put(AssignQueueItem.MKT_AsyncApexJobId__c, AssignQueueItem);
            }
        }
        //Update Completed Jobs Statuses
        List<MKT_AssignQueue__c> CompletedAssignList = new List<MKT_AssignQueue__c>();
        if (ProccessingAssignMap.Size() > 0) {
            for (AsyncApexJob CompletedJob: [SELECT TotalJobItems, Status, ParentJobId, JobType, Id, ApexClass.Name, ApexClassId FROM AsyncApexJob WHERE Id IN :ProccessingAssignMap.keySet()]) {
                if (CompletedJob.Status == 'Aborted' || CompletedJob.Status == 'Completed' || CompletedJob.Status == 'Failed') {
                    MKT_AssignQueue__c MKT_AssignItem = ProccessingAssignMap.get(CompletedJob.Id);
                    MKT_AssignItem.MKT_Status__c = CompletedJob.Status;
                    CompletedAssignList.Add(MKT_AssignItem);
                }
            }
            if (CompletedAssignList.Size() > 0) update CompletedAssignList;
        }
        if (PendingAssignListToProc.Size() == 0 && PendingAssignList.Size() == 0 && ProccessingAssignMap.Size() == CompletedAssignList.Size()) {
            System.Debug('================abortJob=====================');
            System.abortJob(sc.getTriggerId());
            return;
        }
        //return if the limit is reached
        if (JobsSize >= JobsSizeLimit) {
            System.Debug('================JobsSize == JobsSizeLimit=====================');
            try {
                HelperWithoutSharing.RestartAssignJob(sc);
            }
            catch (Exception e) {}
        }

        //Start Jobs From Queue
        List<MKT_AssignQueue__c> AssignListForUpdate = new List<MKT_AssignQueue__c>();
        Set<String> ClassNameJobSet = new Set<String>();
        for (MKT_AssignQueue__c AssignQueueItem :PendingAssignListToProc) {
            System.Debug('================PendingAssignListToProc=====================');
            //if (JobsSize == JobsSizeLimit) break;
            if (AssignQueueItem.MKT_ApexClassName__c == 'MKT_BatchAssign') {
                if (AssignQueueItem.MKT_SerializedData__c != NULL && AssignQueueItem.MKT_SerializedData__c != '' && !ClassNameJobSet.contains(AssignQueueItem.MKT_ApexClassName__c)) {
                    Set<String> NewOrderItemsSet = (Set<String>)JSON.deserialize(AssignQueueItem.MKT_SerializedData__c, Set<String>.class );
                    System.debug('MKT_AssignQueueTrigger NewOrderItems ============='+NewOrderItemsSet);
                    /*List<kumocomm__OrderItem__c> NewOrderItems = [SELECT Id, /*MKT_Class__c, kumocomm__Amount__c, kumocomm__Order__c, kumocomm__Product__c, kumocomm__Quantity__c, /*kumocomm__Order__r.kumocomm__Contact__c FROM kumocomm__OrderItem__c WHERE Id IN  :NewOrderItemsSet];
                    MKT_BatchAssign b = new MKT_BatchAssign();
                    b.recs = NewOrderItems;
                    Set<String> ClassIdsB = new Set<String>();
                    for (kumocomm__OrderItem__c NewOrderItemB :NewOrderItems) {
                        //if (NewOrderItemB.MKT_Class__c != NULL) ClassIdsB.Add(NewOrderItemB.MKT_Class__c);
                    }
                    b.ClassIds = ClassIdsB;
                    Id batchprocessid = Database.executeBatch(b, 1);*/
                    AssignQueueItem.MKT_Status__c = 'Proccessing';
                    //AssignQueueItem.MKT_AsyncApexJobId__c = batchprocessid;
                    AssignListForUpdate.Add(AssignQueueItem);
                    ClassNameJobSet.Add(AssignQueueItem.MKT_ApexClassName__c);
                    System.debug('MKT_AssignQueueTrigger AssignListForUpdate ============='+AssignListForUpdate);
                }
            }
            if (AssignQueueItem.MKT_ApexClassName__c == 'BatchRegisterForTraining' && !ClassNameJobSet.contains(AssignQueueItem.MKT_ApexClassName__c)) {
                if (AssignQueueItem.MKT_SerializedData__c != NULL && AssignQueueItem.MKT_SerializedData__c != '' && !ClassNameJobSet.contains(AssignQueueItem.MKT_ApexClassName__c)) {
                    String Query = (String)JSON.deserialize(AssignQueueItem.MKT_SerializedData__c, String.class);
                    System.debug('BatchRegisterForTraining Query ============='+Query);
                    lmsilt.BatchRegisterForTraining b = new lmsilt.BatchRegisterForTraining();
                    b.Query = Query;
                    Id batchprocessid = Database.executeBatch(b, 1);
                    AssignQueueItem.MKT_Status__c = 'Proccessing';
                    AssignQueueItem.MKT_AsyncApexJobId__c = batchprocessid;
                    AssignListForUpdate.Add(AssignQueueItem);
                    ClassNameJobSet.Add(AssignQueueItem.MKT_ApexClassName__c);
                    System.debug('BatchRegisterForTraining AssignListForUpdate ============='+AssignListForUpdate);
                }
            }
            /*if (AssignQueueItem.MKT_ApexClassName__c == 'BatchUpdateWebEx' && !ClassNameJobSet.contains(AssignQueueItem.MKT_ApexClassName__c)) {
                if (AssignQueueItem.MKT_SerializedData__c != NULL && AssignQueueItem.MKT_SerializedData__c != '' && !ClassNameJobSet.contains(AssignQueueItem.MKT_ApexClassName__c)) {
                    String Query = (String)JSON.deserialize(AssignQueueItem.MKT_SerializedData__c, String.class);
                    System.debug('BatchUpdateWebEx Query ============='+Query);
                    lmsilt.BatchUpdateWebEx b = new lmsilt.BatchUpdateWebEx();
                    b.Query = Query;
                    Id batchprocessid = Database.executeBatch(b, 1);
                    AssignQueueItem.MKT_Status__c = 'Proccessing';
                    AssignQueueItem.MKT_AsyncApexJobId__c = batchprocessid;
                    AssignListForUpdate.Add(AssignQueueItem);
                    ClassNameJobSet.Add(AssignQueueItem.MKT_ApexClassName__c);
                    System.debug('BatchUpdateWebEx AssignListForUpdate ============='+AssignListForUpdate);
                }
            }*/
            if (AssignQueueItem.MKT_ApexClassName__c == 'BatchUnRegisterForTraining') {
                if (AssignQueueItem.MKT_SerializedData__c != NULL && AssignQueueItem.MKT_SerializedData__c != '' && !ClassNameJobSet.contains(AssignQueueItem.MKT_ApexClassName__c)) {
                    String Query = (String)JSON.deserialize(AssignQueueItem.MKT_SerializedData__c, String.class);
                    System.debug('BatchUnRegisterForTraining Query ============='+Query);
                    lmsilt.BatchUnRegisterForTraining b = new lmsilt.BatchUnRegisterForTraining();
                    b.Query = Query;
                    Id batchprocessid = Database.executeBatch(b, 1);
                    AssignQueueItem.MKT_Status__c = 'Proccessing';
                    AssignQueueItem.MKT_AsyncApexJobId__c = batchprocessid;
                    AssignListForUpdate.Add(AssignQueueItem);
                    ClassNameJobSet.Add(AssignQueueItem.MKT_ApexClassName__c);
                    System.debug('BatchUnRegisterForTraining AssignListForUpdate ============='+AssignListForUpdate);
                }
            }
        }
        //Update Statuses to Proccessing
        if (AssignListForUpdate.Size() > 0) update AssignListForUpdate;

        try {
            HelperWithoutSharing.RestartAssignJob(sc);
        }
        catch (Exception e) {}

    }


    //-----------------------------------------------------------------------
    //--                          TEST METHODS                            ---
    //-----------------------------------------------------------------------


    public static testMethod void TestAssignQueue(){
        Product2 prod1 = new Product2(Name = 'producTest1');
        Product2 prodQuiz = new Product2(Name = 'prodQuiz', isActive  = true);
        Product2 prodEvent = new Product2(Name = 'prodEventP', isActive  = true);
        Product2 prodModule = new Product2(Name = 'prodModule', isActive  = true);
        Product2 prodCourse = new Product2(Name = 'prodCourse', isActive  = true);
        Product2 prodLP = new Product2(Name = 'prodLP', isActive  = true);
        Product2 prodCur = new Product2(Name = 'prodCur', isActive  = true);
        insert new List<Product2>{prod1, prodQuiz, prodEvent, prodModule, prodCourse, prodLP, prodCur};
        lmscons__LMS_Consumer_Settings__c LCS = new lmscons__LMS_Consumer_Settings__c(lmscons__Default_License_Period__c='Months', lmscons__Default_License_Term__c = 12, lmscons__Cornerstone_Callback_URL__c='dep', lmscons__CyberUSecretSignKey__c='dep');
        insert LCS;



        lmscons__Training_Content__c TC = new lmscons__Training_Content__c();
        lmscons__Training_Content__c TCP = new lmscons__Training_Content__c(Product__c = prodModule.Id);
        insert new List<lmscons__Training_Content__c>{TC, TCP};

        Date d = Date.valueOf(system.now());
        lmscons__Training_Content_License__c tcl = new lmscons__Training_Content_License__c(lmscons__Training_Content__c=TC.Id, lmscons__Expiration_Date__c=d, lmscons__Seats__c = 100);
        insert tcl;

        lmscons__Quiz__c q= new lmscons__Quiz__c(Product__c = prod1.Id);
        lmscons__Quiz__c q2 = new lmscons__Quiz__c(Product__c = prod1.Id);
        lmscons__Quiz__c q3 = new lmscons__Quiz__c(Product__c = prod1.Id);
        lmscons__Quiz__c qP = new lmscons__Quiz__c(Product__c = prodQuiz.Id);
        insert new List<lmscons__Quiz__c>{q,q2,q3,qP};

        lmsilt__Event__c e2 = new lmsilt__Event__c(lmsilt__Languages__c = 'English', Name='Test Event');
        lmsilt__Event__c eP = new lmsilt__Event__c(lmsilt__Languages__c = 'English', Name='Test Event', Product__c = prodEvent.Id);
        insert new List<lmsilt__Event__c>{e2,eP};

        lmscons__Training_Content__c tc2 = new lmscons__Training_Content__c(lmsilt__Event__c=e2.Id,lmscons__Title__c = 'Training me', lmscons__Cornerstone_ID__c = 'af');
        insert tc2;

        lmsilt__Meeting__c m = new lmsilt__Meeting__c(lmsilt__Meetingkey__c='123');
        insert m;

        lmsilt__Class__c cls = new lmsilt__Class__c(lmsilt__Event__c = e2.Id);
        insert cls;
        lmsilt__Class__c clsP = new lmsilt__Class__c(lmsilt__Event__c = eP.Id);
        insert clsP;

        lmsilt__Material__c matir = new lmsilt__Material__c(lmsilt__Sequence__c = 'after', lmsilt__Class__c = cls.Id);
        lmsilt__Material__c matir2 = new lmsilt__Material__c(lmsilt__Sequence__c = 'before', lmsilt__Class__c = cls.Id);
        insert new List<lmsilt__Material__c>{matir,matir2};

        lmsilt__Session__c ss = new lmsilt__Session__c(lmsilt__ILT_vILT__c = 'ILT', lmsilt__Class__c = clsP.Id, lmsilt__Start_Date_Time__c = system.now().addDays(7), lmsilt__End_Date_Time__c=system.now().addDays(8));
        lmsilt__Session__c ss1 = new lmsilt__Session__c(lmsilt__ILT_vILT__c = 'ILT', lmsilt__Class__c = clsP.Id, lmsilt__Start_Date_Time__c = system.now().addDays(6), lmsilt__End_Date_Time__c=system.now().addDays(7));
        lmsilt__Session__c ss2 = new lmsilt__Session__c(lmsilt__ILT_vILT__c = 'ILT', lmsilt__Class__c = cls.Id, lmsilt__Start_Date_Time__c = system.now().addDays(6), lmsilt__End_Date_Time__c=system.now().addDays(7));
        insert new List<lmsilt__Session__c>{ss,ss1,ss2};

        lmscons__Training_Path__c tp = new lmscons__Training_Path__c(Name = 'testPath', lmscons__Enforce_Curriculum_Sequence__c=true);
        lmscons__Training_Path__c tpP = new lmscons__Training_Path__c(Name = 'testPath', lmscons__Enforce_Curriculum_Sequence__c=true, Product__c = prodCourse.Id);
        insert new List<lmscons__Training_Path__c>{tp,tpP};

        Id RCModule = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Training_Path_Item__c' AND DeveloperName='Module' limit 1].Id;
        Id RCEvent = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Training_Path_Item__c' AND DeveloperName='Event' limit 1].Id;

        List<lmscons__Training_Path_Item__c> ICIs = new List<lmscons__Training_Path_Item__c>();
        lmscons__Training_Path_Item__c ICI = new lmscons__Training_Path_Item__c(lmscons__Training_Path__c = tp.Id, lmscons__Training_Content__c=TC.Id, RecordTypeId=RCModule);
        ICIs.add(ICI);

        lmscons__Training_Path_Item__c ICI2 = new lmscons__Training_Path_Item__c(lmscons__Training_Path__c = tp.Id, lmscons__Training_Content__c = tc2.Id ,lmsilt__Event__c = e2.Id, RecordTypeId=RCEvent);
        ICIs.add(ICI2);
        insert ICIs;

        lmscons__Learning_Path__c lp = new lmscons__Learning_Path__c(Name='TestLP 1', lmscons__Enforce_Sequence__c=true);
        lmscons__Learning_Path__c lpP = new lmscons__Learning_Path__c(Name='TestLP 1', lmscons__Enforce_Sequence__c=true, Product__c = prodLP.Id, lmscons__Description__c = 'Description');
        insert new List<lmscons__Learning_Path__c>{lp,lpP};

        Id RCModule3 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Learning_Path_Item__c' AND DeveloperName='Module' limit 1].Id;
        Id RCEvent3 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Learning_Path_Item__c' AND DeveloperName='Event' limit 1].Id;
        Id RCCourse3 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Learning_Path_Item__c' AND DeveloperName='Course' limit 1].Id;

        List<lmscons__Learning_Path_Item__c> LPIs = new List<lmscons__Learning_Path_Item__c>();
        lmscons__Learning_Path_Item__c LPI3 = new lmscons__Learning_Path_Item__c(lmscons__Learning_Path__c = lp.Id, lmsilt__Event__c=e2.Id, RecordTypeId=RCEvent3);
        LPIs.add(LPI3);
        lmscons__Learning_Path_Item__c LPI4 = new lmscons__Learning_Path_Item__c(lmscons__Learning_Path__c = lp.Id, lmscons__Module__c=tc.Id, RecordTypeId=RCModule3);
        LPIs.add(LPI4);
        lmscons__Learning_Path_Item__c LPI5 = new lmscons__Learning_Path_Item__c(lmscons__Learning_Path__c = lp.Id, lmscons__Course__c=tp.Id, RecordTypeId=RCCourse3);
        LPIs.add(LPI5);
        insert LPIs;

        lmscons__Curriculum__c cur = new lmscons__Curriculum__c(Name='Test Cur 1', lmscons__Enforce_Sequence__c = true);
        lmscons__Curriculum__c curP = new lmscons__Curriculum__c(Name='Test Cur 1', lmscons__Enforce_Sequence__c = true, Product__c = prodCur.Id);
        insert new List<lmscons__Curriculum__c>{cur,curP};

        LIST<lmscons__Curriculum_Item__c> CIList = new LIST<lmscons__Curriculum_Item__c>();

        Id RCModule5 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Curriculum_Item__c' AND DeveloperName='Module' limit 1].Id;
        Id RCEvent5 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Curriculum_Item__c' AND DeveloperName='Event' limit 1].Id;
        Id RCLP5 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Curriculum_Item__c' AND DeveloperName='Learning_Path2' limit 1].Id;
        Id RCCourse5 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Curriculum_Item__c' AND DeveloperName='Course' limit 1].Id;


        List<lmscons__Curriculum_Item__c> CIs = new List<lmscons__Curriculum_Item__c>();
        lmscons__Curriculum_Item__c ci = new lmscons__Curriculum_Item__c(lmscons__Learning_Path__c = lp.Id, lmscons__Curriculum__c = cur.Id, RecordTypeId=RCLP5);
        CIs.add(ci);

        lmscons__Curriculum_Item__c ci2 = new lmscons__Curriculum_Item__c(lmscons__Course__c=tp.Id, lmscons__Curriculum__c = cur.Id, RecordTypeId=RCCourse5);
        CIs.add(ci2);

        lmscons__Curriculum_Item__c ci3 = new lmscons__Curriculum_Item__c(lmscons__Module__c=tc.Id, lmscons__Curriculum__c = cur.Id, RecordTypeId=RCModule5);
        CIs.add(ci3);

        lmscons__Curriculum_Item__c ci4 = new lmscons__Curriculum_Item__c(lmsilt__Event__c=e2.Id, lmscons__Curriculum__c = cur.Id, RecordTypeId=RCEvent5);
        CIs.add(ci4);
        insert CIs;

        Account testAcc = new Account(Name = 'test');
        insert testAcc;
        Contact testContact = new Contact();
        testContact.AccountId = testAcc.Id;
        testContact.LastName = 'TestCont';
        testContact.Phone = '54589651485';
        testContact.OtherStreet = 'OtherStreet';
        testContact.Email = 'Email@Email.ru';
        testContact.MailingCountry = 'MailingCountry';
        testContact.MailingPostalCode = '224013';
        testContact.MailingState = 'AL';
        testContact.MailingCity = 'City';
        testContact.MailingStreet = 'MailingStreet';
        testContact.FirstName = 'FirstName';

        insert testContact;

        /*kumocomm__Payment_Source__c PaymentSourceItem = new kumocomm__Payment_Source__c ();
           // PaymentSourceItem.kumocomm__Contact__c = testContact.Id;
            PaymentSourceItem.kumocomm__CreditCardExpirationMonth__c = '07';
            PaymentSourceItem.kumocomm__CreditCardExpirationYear__c = '2015';
            PaymentSourceItem.kumocomm__CreditCardNumber__c = '5555555555554444';
            PaymentSourceItem.kumocomm__CreditCardSecurityCode__c = '678';
            PaymentSourceItem.kumocomm__CreditCardType__c = 'Mastercard';
            insert PaymentSourceItem;*/
        /*kumocomm__Address__c BillingAddressItem = new kumocomm__Address__c();
            //BillingAddressItem.kumocomm__Contact__c = testContact.Id;
            BillingAddressItem.kumocomm__Type__c = 'Billing Address';
            BillingAddressItem.kumocomm__City__c = 'City';
            BillingAddressItem.kumocomm__Country__c = 'Country';
            BillingAddressItem.kumocomm__PostalCode__c = 'Zip';
            BillingAddressItem.kumocomm__State__c = 'State';
            BillingAddressItem.kumocomm__Street__c = 'Address1';
            BillingAddressItem.MKT_FirstName__c = 'FirstName';
            BillingAddressItem.MKT_LastName__c = 'LastName';
            BillingAddressItem.MKT_Phone__c = 'Phone';
            BillingAddressItem.MKT_Address2__c = 'Address2';

            insert BillingAddressItem;*/


        /*kumocomm__Order__c testOrder = new kumocomm__Order__c(CurrencyIsoCode = 'USD',/*kumocomm__PaymentSource__c = PaymentSourceItem.ID,kumocomm__BillingAddress__c = BillingAddressItem.Id /*,kumocomm__Status__c = 'Completed', kumocomm__Amount__c = 900);
        kumocomm__Order__c testOrder2 = new kumocomm__Order__c(CurrencyIsoCode = 'USD',/*kumocomm__PaymentSource__c = PaymentSourceItem.ID,kumocomm__BillingAddress__c = BillingAddressItem.Id /*,kumocomm__Status__c = 'Completed', kumocomm__Amount__c = 900);
        kumocomm__Order__c testOrder3 = new kumocomm__Order__c(CurrencyIsoCode = 'USD',/*kumocomm__PaymentSource__c = PaymentSourceItem.ID,kumocomm__BillingAddress__c = BillingAddressItem.Id /*,kumocomm__Status__c = 'Completed', kumocomm__Amount__c = 900);
        kumocomm__Order__c testOrder4 = new kumocomm__Order__c(CurrencyIsoCode = 'USD',/*kumocomm__PaymentSource__c = PaymentSourceItem.ID,kumocomm__BillingAddress__c = BillingAddressItem.Id /*,kumocomm__Status__c = 'Completed', kumocomm__Amount__c = 900);

        insert new List<kumocomm__Order__c>{testOrder, testOrder2, testOrder3, testOrder4};*/

        /*List<kumocomm__OrderItem__c> NewOrderItems = new List<kumocomm__OrderItem__c>();
            kumocomm__OrderItem__c NewOrderItem = new kumocomm__OrderItem__c(/*kumocomm__Amount__c = 100, kumocomm__Order__c = testOrder.Id, kumocomm__Product__c = prodModule.Id, kumocomm__Quantity__c = 2, MKT_Assignment_Status_c__c = 'Completed');
            kumocomm__OrderItem__c NewOrderItem2 = new kumocomm__OrderItem__c(/*kumocomm__Amount__c = 100, kumocomm__Order__c = testOrder2.Id, kumocomm__Product__c = prodQuiz.Id, kumocomm__Quantity__c = 2, MKT_Assignment_Status_c__c = 'Completed');
            kumocomm__OrderItem__c NewOrderItem3 = new kumocomm__OrderItem__c(/*kumocomm__Amount__c = 100, kumocomm__Order__c = testOrder3.Id, kumocomm__Product__c = prodEvent.Id, kumocomm__Quantity__c = 2, MKT_Assignment_Status_c__c = 'Completed'/*, MKT_Class__c = clsP.Id);
            kumocomm__OrderItem__c NewOrderItem4 = new kumocomm__OrderItem__c(/*kumocomm__Amount__c = 100, kumocomm__Order__c = testOrder4.Id, kumocomm__Product__c = prodCourse.Id, kumocomm__Quantity__c = 2, MKT_Assignment_Status_c__c = 'Completed');
            kumocomm__OrderItem__c NewOrderItem5 = new kumocomm__OrderItem__c(/*kumocomm__Amount__c = 100, kumocomm__Order__c = testOrder.Id, kumocomm__Product__c = prodLP.Id, kumocomm__Quantity__c = 2, MKT_Assignment_Status_c__c = 'Completed');
            kumocomm__OrderItem__c NewOrderItem6 = new kumocomm__OrderItem__c(/*kumocomm__Amount__c = 100, kumocomm__Order__c = testOrder2.Id, kumocomm__Product__c = prodCur.Id, kumocomm__Quantity__c = 2, MKT_Assignment_Status_c__c = 'Completed');*/

        Profile profile;
        try {
            profile = [SELECT Id FROM profile WHERE name='System Administrator'];
        } catch (system.exception e) {
            profile = [SELECT Id FROM profile WHERE Id=:UserInfo.getProfileId()];
        }
        /*User u = new User(alias = 'tes334t2', email='test23434456@test.com', emailencodingkey='UTF-8', lastname='2te43st444', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profile.Id, timezonesidkey='America/Los_Angeles', username='test@test343SF111112d.com' );
        insert u;*/
        User u = HelperWithoutSharing.createTestUser(profile.Id, 'firstTestName1', 'secondtestName1', 'aff');
        insert u;


        /*insert new List<kumocomm__OrderItem__c>{NewOrderItem,NewOrderItem2,NewOrderItem3,NewOrderItem4,NewOrderItem5,NewOrderItem6};*/
        String GTTUnQuery = 'select Class__r.Maximum_Capacity__c, registrantKey__c, confirmationUrl__c, User__c, Session__c, Session__r.Meeting__r.Meetingkey__c, Roster__r.Student__c, Roster__r.Student__r.Email, Roster__r.Student__r.LastName, Roster__r.Student__r.FirstName, Roster__c, JoinUrl__c, Event__c, Event__r.Name, Class__c, Name from GoToTraining_Session__c where Session__c = \''+ss.ID+'\' and User__c=\''+U.id+'\'';
        String GTTQuery = 'SELECT lmsilt__Session__r.lmsilt__Meeting_Type__c, lmsilt__Class__r.lmsilt__Maximum_Capacity__c, lmsilt__registrantKey__c, lmsilt__confirmationUrl__c, lmsilt__User__c, lmsilt__Session__c, lmsilt__Session__r.lmsilt__Meeting__r.lmsilt__Meetingkey__c, lmsilt__Roster__r.lmsilt__Student__c, lmsilt__Roster__r.lmsilt__Student__r.Email, lmsilt__Roster__r.lmsilt__Student__r.LastName, lmsilt__Roster__r.lmsilt__Student__r.FirstName, lmsilt__Roster__c, lmsilt__JoinUrl__c, lmsilt__Event__c, lmsilt__Event__r.Name, lmsilt__Class__c, Name FROM lmsilt__GoToTraining_Session__c WHERE lmsilt__Class__c = \''+clsP.ID+'\'   and lmsilt__Session__r.lmsilt__Meeting_Type__c=\'GoToTraining\' AND lmsilt__JoinUrl__c = NULL order by lmsilt__Roster__c';
        String WevExQuery = 'SELECT lmsilt__Session__r.lmsilt__Meeting_Type__c, lmsilt__Class__r.lmsilt__Maximum_Capacity__c, lmsilt__registrantKey__c, lmsilt__confirmationUrl__c, lmsilt__User__c, lmsilt__Session__c, lmsilt__Session__r.lmsilt__Meeting_Password__c, lmsilt__Session__r.lmsilt__Meeting__r.lmsilt__Meetingkey__c, lmsilt__Roster__r.lmsilt__Student__c, lmsilt__Roster__r.lmsilt__Student__r.Email, lmsilt__Roster__r.lmsilt__Student__r.LastName, lmsilt__Roster__r.lmsilt__Student__r.FirstName, lmsilt__Roster__c, lmsilt__JoinUrl__c, lmsilt__Event__c, lmsilt__Event__r.Name, lmsilt__Class__c, Name FROM lmsilt__GoToTraining_Session__c WHERE lmsilt__Class__c = \''+clsP.ID+'\'  and lmsilt__Session__r.lmsilt__Meeting_Type__c=\'WebEx\'';
        MKT_AssignQueue__c AssignQueueObj1 = new MKT_AssignQueue__c(MKT_ApexClassName__c = 'MKT_BatchAssign', MKT_Status__c = 'Proccessing', MKT_SerializedData__c = 'SerializeString');
        MKT_AssignQueue__c AssignQueueObj2 = new MKT_AssignQueue__c(MKT_ApexClassName__c = 'MKT_BatchAssign', MKT_Status__c = 'Proccessing', MKT_SerializedData__c = 'SerializeString');
        MKT_AssignQueue__c AssignQueueObj3 = new MKT_AssignQueue__c(MKT_ApexClassName__c = 'BatchUnRegisterForTraining', MKT_Status__c = 'Pending', MKT_SerializedData__c = JSON.serialize(GTTUnQuery));
        MKT_AssignQueue__c AssignQueueObj32 = new MKT_AssignQueue__c(MKT_ApexClassName__c = 'BatchUnRegisterForTraining', MKT_Status__c = 'Pending', MKT_SerializedData__c = JSON.serialize(GTTUnQuery));
        MKT_AssignQueue__c AssignQueueObj4 = new MKT_AssignQueue__c(MKT_ApexClassName__c = 'BatchRegisterForTraining', MKT_Status__c = 'Pending', MKT_SerializedData__c = JSON.serialize(GTTQuery));
        MKT_AssignQueue__c AssignQueueObj5 = new MKT_AssignQueue__c(MKT_ApexClassName__c = 'BatchRegisterForTraining', MKT_Status__c = 'Pending', MKT_SerializedData__c = JSON.serialize(WevExQuery));
        MKT_AssignQueue__c AssignQueueObj6 = new MKT_AssignQueue__c(MKT_ApexClassName__c = 'MKT_BatchAssign', MKT_Status__c = 'Pending');/*, MKT_SerializedData__c = JSON.serialize(new Set<String>{NewOrderItem.Id}));*/
        MKT_AssignQueue__c AssignQueueObj7 = new MKT_AssignQueue__c(MKT_ApexClassName__c = 'MKT_BatchAssign', MKT_Status__c = 'Pending');/*, MKT_SerializedData__c = JSON.serialize(new Set<String>{NewOrderItem2.Id}));*/
        MKT_AssignQueue__c AssignQueueObj8 = new MKT_AssignQueue__c(MKT_ApexClassName__c = 'MKT_BatchAssign', MKT_Status__c = 'Pending');/*, MKT_SerializedData__c = JSON.serialize(new Set<String>{NewOrderItem3.Id}));*/
        MKT_AssignQueue__c AssignQueueObj9 = new MKT_AssignQueue__c(MKT_ApexClassName__c = 'MKT_BatchAssign', MKT_Status__c = 'Pending');/*, MKT_SerializedData__c = JSON.serialize(new Set<String>{NewOrderItem4.Id}));*/


        System.runAs(u) {
            lmscons__Transcript__c tr = new lmscons__Transcript__c(lmscons__Trainee__c = UserInfo.getUserId());
            insert tr;
            Test.StartTest();
                insert new List<MKT_AssignQueue__c>{AssignQueueObj1,AssignQueueObj2,AssignQueueObj3,AssignQueueObj32,AssignQueueObj4,AssignQueueObj5,AssignQueueObj6,AssignQueueObj7,AssignQueueObj8,AssignQueueObj9};
            Test.StopTest();
            List<MKT_AssignQueue__c> testAssign = [SELECT ID, MKT_AsyncApexJobId__c, MKT_Status__c, MKT_ApexClassName__c, MKT_SerializedData__c FROM MKT_AssignQueue__c WHERE MKT_Status__c = 'Pending'];
            //System.assert(testAssign.size() == 0);
        }
    }
}