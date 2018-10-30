public with sharing class MKT_PrintOrder {
    /*public String OrderId { get; set; }
    public String OrderNumber { get; set; }
    public String PaymentDate { get; set; }
    public List<OrderItemWrapper> OrderItems { get; set; }
    public String CurrencyIsoCode { get; set; }
    public String GatewayTransactionId { get; set; }

    public kumocomm__Payment_Source__c PaymentSource { get; set; }
    public kumocomm__Address__c BillingAddress { get; set; }
    public Map<Id, List<lmsilt__Class__c>> CLSMap ;
    public String TotalAmount { get; set; }
    public MKT_PrintOrder () {
        OrderId = ApexPages.currentPage().getParameters().get('OrderId');
        CLSMap = new Map<Id, List<lmsilt__Class__c>>();
        PaymentSource = new kumocomm__Payment_Source__c();
        BillingAddress = new kumocomm__Address__c();
        FillOrderTable();
    }
    public void FillOrderTable() {
        List<kumocomm__Order__c> OrderList = [SELECT Id, CurrencyIsoCode, kumocomm__Amount__c, kumocomm__PaymentSource__c, kumocomm__BillingAddress__c, kumocomm__Status__c, Name FROM kumocomm__Order__c WHERE Id = :OrderId];

        if (OrderList.size() == 0) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.MKT_OrderID_Record_Not_Found)); return;}
        else if (OrderList[0].kumocomm__Status__c != 'Completed') {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.MKT_Order_has_not_been_paid));return;}
        CurrencyIsoCode = OrderList[0].CurrencyIsoCode;
        TotalAmount = HelperWithoutSharing.currencySymbol(CurrencyIsoCode) + String.ValueOf(OrderList[0].kumocomm__Amount__c.setScale(0).format());
        OrderNumber = OrderList[0].Name;
        List<kumocomm__Transaction__c> TransactionList = [SELECT kumocomm__GatewayTransactionId__c, Name, LastModifiedDate, Id FROM kumocomm__Transaction__c WHERE kumocomm__Order__c = :OrderId ORDER BY LastModifiedDate DESC LIMIT 1];
        if (TransactionList.size() == 0) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.MKT_Transaction_Record_Not_Found)); return;}
        PaymentDate = TransactionList[0].LastModifiedDate.format('MM/dd/yyyy');
        GatewayTransactionId = TransactionList[0].kumocomm__GatewayTransactionId__c;
        List<kumocomm__OrderItem__c> OrderItemList = [SELECT kumocomm__Order__c, MKT_Class__c, kumocomm__Product__c, kumocomm__Amount__c, Name, MKT_Assignment_Status_c__c, Id, kumocomm__Quantity__c  FROM kumocomm__OrderItem__c WHERE kumocomm__Order__c = :OrderId /*AND MKT_Assignment_Status_c__c = 'Completed'*//* AND kumocomm__Product__c != NULL];
        if (OrderItemList.size() == 0) {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.MKT_Completed_Order_Items_Are_Not_Found)); return;}

        OrderItems = new List<OrderItemWrapper>();
        Map<Id, kumocomm__OrderItem__c> OrderItemsProductsMap = new Map<Id, kumocomm__OrderItem__c>();
        for (kumocomm__OrderItem__c OrderItem : OrderItemList) {
            OrderItemsProductsMap.put(OrderItem.kumocomm__Product__c, OrderItem);
        }
        List<kumocomm__Payment_Source__c> PaymentSourceList = [SELECT ID, kumocomm__CreditCardExpirationMonth__c,kumocomm__CreditCardExpirationYear__c, kumocomm__Last4CreditCardNumber__c, kumocomm__CreditCardSecurityCode__c, kumocomm__CreditCardType__c FROM kumocomm__Payment_Source__c WHERE ID = : OrderList[0].kumocomm__PaymentSource__c LIMIT 1];
        if (PaymentSourceList.size() > 0) PaymentSource = PaymentSourceList[0];
        else {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.MKT_Payment_Source_Record_Not_Found)); return;}

        List<kumocomm__Address__c> BillingAddressList = [SELECT Id, MKT_Address2__c, MKT_FirstName__c, MKT_LastName__c, MKT_Phone__c, kumocomm__Contact__c, kumocomm__City__c, kumocomm__Country__c, kumocomm__PostalCode__c, kumocomm__State__c, kumocomm__Street__c, kumocomm__Type__c, kumocomm__Contact__r.Email FROM kumocomm__Address__c WHERE Id = :OrderList[0].kumocomm__BillingAddress__c AND kumocomm__Type__c = 'Billing Address' LIMIT 1];
        if (BillingAddressList.size() > 0) BillingAddress = BillingAddressList[0];
        else {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, Label.MKT_Billing_Address_Record_Not_Found)); return;}

        /*List<kumocomm__Address__c> BillingAddressList = [SELECT Id, MKT_Address2__c, MKT_FirstName__c, MKT_LastName__c, MKT_Phone__c, kumocomm__Contact__c, kumocomm__City__c, kumocomm__Country__c, kumocomm__PostalCode__c, kumocomm__State__c, kumocomm__Street__c, kumocomm__Type__c, kumocomm__Contact__r.Email FROM kumocomm__Address__c WHERE Id = :OrderList[0].kumocomm__BillingAddress__c AND kumocomm__Type__c = 'Billing Address' LIMIT 1];
        if (BillingAddressList.size() > 0) BillingAddress = BillingAddressList[0];
        else {ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Billing Address Record Not Found')); return;}*/

        /*Set<Id> OrderItemsProductsSet = OrderItemsProductsMap.keySet();
        String Name_Event = lmsilt__Event__c.sObjectType.getDescribe().getLabel();
        String Name_Module = 'On-Demand';
        String Name_Course = lmscons__Training_Path__c.sObjectType.getDescribe().getLabel();
        String Name_LP = lmscons__Learning_Path__c.sObjectType.getDescribe().getLabel();
        String Name_Curriculum = lmscons__Curriculum__c.sObjectType.getDescribe().getLabel();
        List<lmscons__Training_Content__c> ListModules = [SELECT Id, lmscons__Title__c, Product__c, lmscons__Description__c,Product__r.isActive FROM lmscons__Training_Content__c WHERE Product__c IN :OrderItemsProductsSet];
        List<lmscons__Quiz__c> ListQuizes = [SELECT Id, Name, Product__c, lmscons__Description__c,Product__r.isActive FROM lmscons__Quiz__c WHERE Product__c IN :OrderItemsProductsSet];
        List<lmsilt__Event__c> ListEvents = [SELECT lmsilt__Description__c, Name, Id, Product__c,Product__r.isActive FROM lmsilt__Event__c WHERE Product__c IN :OrderItemsProductsSet];
        List<lmscons__Training_Path__c> ListCourses = [SELECT id, Name, lmscons__Description__c, lmscons__Total_Items__c, Product__c,Product__r.isActive FROM lmscons__Training_Path__c WHERE  Product__c IN :OrderItemsProductsSet];
        List<lmscons__Learning_Path__c> ListLP = [SELECT id, Name, lmscons__Description__c, lmscons__Total_Items__c, Product__c,Product__r.isActive FROM lmscons__Learning_Path__c WHERE  Product__c IN :OrderItemsProductsSet];
        List<lmscons__Curriculum__c> ListCurr = [SELECT id, Name, lmscons__Description__c, lmscons__Total_Items__c, Product__c, Product__r.isActive FROM lmscons__Curriculum__c WHERE  Product__c IN :OrderItemsProductsSet];


        if (ListEvents.size() > 0) {
            Set<Id> EventIds = new Set<Id>();
            for (lmsilt__Event__c e : ListEvents) {
                EventIds.add(e.Id);
            }
            for (lmsilt__Class__c cl : [SELECT Id, Name, lmsilt__Event__c, lmsilt__Start_Date__c, lmsilt__End_Date__c, lmsilt__Maximum_Capacity__c, lmsilt__Waitlist_Enabled__c, lmsilt__Cancellation_Policy_lookup__c, (SELECT Id, Name, lmsilt__ILT_vILT__c, lmsilt__Session_Location__c, lmsilt__Session_Location__r.Name, lmsilt__Start_Date_Time__c, lmsilt__End_Date_Time__c FROM lmsilt__Sessions__r) FROM lmsilt__Class__c WHERE lmsilt__Event__c IN : EventIds]) {

                List<lmsilt__Class__c> classes_list = new List<lmsilt__Class__c>();
                if (CLSMap.containskey(cl.lmsilt__Event__c)) {
                    classes_list = CLSMap.get(cl.lmsilt__Event__c);
                }
                classes_list.add(cl);
                CLSMap.put(cl.lmsilt__Event__c, classes_list);
            }
        }
        for (lmscons__Training_Content__c moduleItem : ListModules) {
            OrderItemWrapper OrderItemObj = new OrderItemWrapper();
            OrderItemObj.CourseName = moduleItem.lmscons__Title__c;
            OrderItemObj.Type = Name_Module;
            OrderItemObj.Description = moduleItem.lmscons__Description__c;
            kumocomm__OrderItem__c orderItem = (kumocomm__OrderItem__c)OrderItemsProductsMap.get(moduleItem.Product__c);
            OrderItemObj.OrderItemId = orderItem.Id;
            OrderItemObj.ProductId = moduleItem.Product__c;
            OrderItemObj.Quantity = (Integer)orderItem.kumocomm__Quantity__c;
            OrderItemObj.Amount = orderItem.kumocomm__Amount__c;
            OrderItemObj.CurrencyIsoCode = CurrencyIsoCode;
            orderItems.Add(OrderItemObj);
        }
        for (lmscons__Quiz__c quizItem : ListQuizes) {
            OrderItemWrapper OrderItemObj = new OrderItemWrapper();
            OrderItemObj.CourseName = quizItem.Name;
            OrderItemObj.Type = Name_Module;
            OrderItemObj.Description = quizItem.lmscons__Description__c;
            kumocomm__OrderItem__c orderItem = (kumocomm__OrderItem__c)OrderItemsProductsMap.get(quizItem.Product__c);
            OrderItemObj.orderItemId = orderItem.Id;
            OrderItemObj.ProductId = quizItem.Product__c;
            OrderItemObj.Quantity = (Integer)orderItem.kumocomm__Quantity__c;
            OrderItemObj.Amount = orderItem.kumocomm__Amount__c;
            OrderItemObj.CurrencyIsoCode = CurrencyIsoCode;
            orderItems.Add(OrderItemObj);
        }
        for (lmsilt__Event__c eventItem : ListEvents) {
            kumocomm__OrderItem__c orderItem = (kumocomm__OrderItem__c)OrderItemsProductsMap.get(eventItem.Product__c);
            Map<String,String> infoEvent = getEventInfo(eventItem.Id, '');//orderItem.MKT_Class__c);

            OrderItemWrapper OrderItemObj = new OrderItemWrapper();
            OrderItemObj.CourseName = eventItem.Name;
            OrderItemObj.Description = eventItem.lmsilt__Description__c;
            OrderItemObj.Location = (infoEvent.containsKey('location')) ? infoEvent.Get('location') : '';
            OrderItemObj.StartSess = (infoEvent.containsKey('start')) ? infoEvent.Get('start') : '';
            OrderItemObj.EndSess = (infoEvent.containsKey('end')) ? infoEvent.Get('end') : '';
            OrderItemObj.ClassId = '';//orderItem.MKT_Class__c;
            OrderItemObj.Type = (infoEvent.containsKey('type')) ? infoEvent.Get('type') : '';
            OrderItemObj.orderItemId = orderItem.Id;
            OrderItemObj.ProductId = eventItem.Product__c;
            OrderItemObj.Quantity = (Integer)orderItem.kumocomm__Quantity__c;
            OrderItemObj.Amount = orderItem.kumocomm__Amount__c;
            OrderItemObj.CurrencyIsoCode = CurrencyIsoCode;
            orderItems.Add(OrderItemObj);
        }
        for (lmscons__Training_Path__c courseItem : ListCourses) {
            OrderItemWrapper OrderItemObj = new OrderItemWrapper();
            OrderItemObj.CourseName = courseItem.Name;
            OrderItemObj.Type = Name_Course;
            OrderItemObj.Description = courseItem.lmscons__Description__c;
            kumocomm__OrderItem__c orderItem = (kumocomm__OrderItem__c)OrderItemsProductsMap.get(courseItem.Product__c);
            OrderItemObj.orderItemId = orderItem.Id;
            OrderItemObj.ProductId = courseItem.Product__c;
            OrderItemObj.Quantity = (Integer)orderItem.kumocomm__Quantity__c;
            OrderItemObj.Amount = orderItem.kumocomm__Amount__c;
            OrderItemObj.CurrencyIsoCode = CurrencyIsoCode;
            orderItems.Add(OrderItemObj);
        }
        for (lmscons__Learning_Path__c lpItem : ListLP) {
            OrderItemWrapper OrderItemObj = new OrderItemWrapper();
            OrderItemObj.CourseName = lpItem.Name;
            OrderItemObj.Type = Name_LP;
            OrderItemObj.Description = lpItem.lmscons__Description__c;
            kumocomm__OrderItem__c orderItem = (kumocomm__OrderItem__c)OrderItemsProductsMap.get(lpItem.Product__c);
            OrderItemObj.orderItemId = orderItem.Id;
            OrderItemObj.ProductId = lpItem.Product__c;
            OrderItemObj.Quantity = (Integer)orderItem.kumocomm__Quantity__c;
            OrderItemObj.Amount = orderItem.kumocomm__Amount__c;
            OrderItemObj.CurrencyIsoCode = CurrencyIsoCode;
            orderItems.Add(OrderItemObj);
        }
        for (lmscons__Curriculum__c currItem : ListCurr) {
            OrderItemWrapper OrderItemObj = new OrderItemWrapper();
            OrderItemObj.CourseName = currItem.Name;
            OrderItemObj.Type = Name_Curriculum;
            OrderItemObj.Description = currItem.lmscons__Description__c;
            kumocomm__OrderItem__c orderItem = (kumocomm__OrderItem__c)OrderItemsProductsMap.get(currItem.Product__c);
            OrderItemObj.orderItemId = orderItem.Id;
            OrderItemObj.ProductId = currItem.Product__c;
            OrderItemObj.Quantity = (Integer)orderItem.kumocomm__Quantity__c;
            OrderItemObj.Amount = orderItem.kumocomm__Amount__c;
            OrderItemObj.CurrencyIsoCode = CurrencyIsoCode;
            orderItems.Add(OrderItemObj);
        }

    }
    public Map<String,String> getEventInfo(Id EvtId, Id ClassID) {
        Map<String,String> EvtInfo = new Map<String,String>();
        String expired = 'true';
        if (CLSMap.containskey(EvtId)) {
            Set<String> location = new Set<String>();
            Set<String> typeEvnt = new Set<String>();
            for (lmsilt__Class__c cl : CLSMap.get(EvtId)) {
                if (cl.lmsilt__Sessions__r != NULL && cl.ID == ClassID) {
                    for (lmsilt__Session__c sess : cl.lmsilt__Sessions__r) {
                        String SessType = (sess.lmsilt__ILT_vILT__c == 'ILT') ? Label.MKT_Classroom : Label.MKT_Virtual;
                        if (SessType == 'Virtual') {
                            if (!location.contains(SessType) ) {
                                location.Add(SessType);
                            }
                        }
                        if (!typeEvnt.contains(SessType) ) {
                            typeEvnt.Add(SessType);
                        }
                        if (sess.lmsilt__Session_Location__r != NULL) {
                            if (!location.contains(sess.lmsilt__Session_Location__r.Name) ) {
                                location.Add(sess.lmsilt__Session_Location__r.Name);
                            }
                        }
                        EvtInfo.put('start', sess.lmsilt__Start_Date_Time__c.format('MM/dd/yyyy h:mm a'));
                        EvtInfo.put('end', sess.lmsilt__End_Date_Time__c.format('MM/dd/yyyy h:mm a'));
                    }
                }
                if (cl.lmsilt__Start_Date__c > datetime.now()) expired = 'false';
            }
            if (location.size() > 1) {
                EvtInfo.put('location', 'choose');
            }
            else if (location.size() == 1) {
                List<String> resultList = new List<String>();
                resultList.addAll(location);
                EvtInfo.put('location', resultList[0]);
            }
            else {
                EvtInfo.put('location', '');
            }

            String typeEvntTmp = '';
            for (String tmp : typeEvnt) {
                typeEvntTmp += tmp + '/';
            }
            EvtInfo.put('type',typeEvntTmp.substring(0,typeEvntTmp.length()-1));
            EvtInfo.put('isExpired', expired);
        }
        return EvtInfo;
    }
    // Inner Classes//
    public class OrderItemWrapper {
        public String CourseName { get; set; }
        public String Type { get; set; }
        public String Location { get; set; }
        public String StartSess { get; set; }
        public String EndSess { get; set; }
        public String EventId { get; set; }
        public String ClassId { get; set; }
        public Integer Quantity { get; set; }
        public String ProductId { get; set; }
        public String CurrencyIsoCode { get; set; }
        public Decimal Amount { get; set; }
        public String Description { get; set; }
        public String OrderItemId { get; set; }
        public String getCost() {
            String CostString = '0';
            if (Amount != NULL) {
                CostString = HelperWithoutSharing.currencySymbol(CurrencyIsoCode) + String.ValueOf(Amount.setScale(0).format());
            }
            return CostString;
        }
        public String getSubtotal() {
            Decimal SubtotalDec = 0;
            String SubtotalString = '0';
            if (Amount != NULL && Quantity != NULL) {
                SubtotalDec = Amount * Quantity;
                SubtotalString = HelperWithoutSharing.currencySymbol(CurrencyIsoCode) + String.ValueOf(SubtotalDec.setScale(0).format());
            }
            return SubtotalString;
        }
    }

    //-----------------------------------------------------------------------
    //--                          TEST METHODS                            ---
    //-----------------------------------------------------------------------
    static testMethod void TestPrintOrder(){
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

        lmscons__Transcript__c tr = new lmscons__Transcript__c(lmscons__Trainee__c = UserInfo.getUserId());
        insert tr;

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

        kumocomm__Payment_Source__c PaymentSourceItem = new kumocomm__Payment_Source__c ();
            PaymentSourceItem.kumocomm__Contact__c = testContact.Id;
            PaymentSourceItem.kumocomm__CreditCardExpirationMonth__c = '07';
            PaymentSourceItem.kumocomm__CreditCardExpirationYear__c = '2015';
            PaymentSourceItem.kumocomm__Last4CreditCardNumber__c = '4444';
            PaymentSourceItem.kumocomm__CreditCardSecurityCode__c = '678';
            PaymentSourceItem.kumocomm__CreditCardType__c = 'Mastercard';
            insert PaymentSourceItem;
        kumocomm__Address__c BillingAddressItem = new kumocomm__Address__c();
            BillingAddressItem.kumocomm__Contact__c = testContact.Id;
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

            insert BillingAddressItem;


        kumocomm__Order__c testOrder = new kumocomm__Order__c();
        testOrder.CurrencyIsoCode = 'USD';
        testOrder.kumocomm__PaymentSource__c = PaymentSourceItem.ID;
        testOrder.kumocomm__BillingAddress__c = BillingAddressItem.Id;
        testOrder.kumocomm__Status__c = 'Completed';
        testOrder.kumocomm__Amount__c = 900;

        insert testOrder;

        List<kumocomm__OrderItem__c> NewOrderItems = new List<kumocomm__OrderItem__c>();
            kumocomm__OrderItem__c NewOrderItem = new kumocomm__OrderItem__c(kumocomm__Amount__c = 100, kumocomm__Order__c = testOrder.Id, kumocomm__Product__c = prodModule.Id, kumocomm__Quantity__c = 2, MKT_Assignment_Status_c__c = 'Completed');
            kumocomm__OrderItem__c NewOrderItem2 = new kumocomm__OrderItem__c(kumocomm__Amount__c = 100, kumocomm__Order__c = testOrder.Id, kumocomm__Product__c = prodQuiz.Id, kumocomm__Quantity__c = 2, MKT_Assignment_Status_c__c = 'Completed');
            kumocomm__OrderItem__c NewOrderItem3 = new kumocomm__OrderItem__c(kumocomm__Amount__c = 100, kumocomm__Order__c = testOrder.Id, kumocomm__Product__c = prodEvent.Id, kumocomm__Quantity__c = 2, MKT_Assignment_Status_c__c = 'Completed');//, MKT_Class__c = clsP.Id);
            kumocomm__OrderItem__c NewOrderItem4 = new kumocomm__OrderItem__c(kumocomm__Amount__c = 100, kumocomm__Order__c = testOrder.Id, kumocomm__Product__c = prodCourse.Id, kumocomm__Quantity__c = 2, MKT_Assignment_Status_c__c = 'Completed');
            kumocomm__OrderItem__c NewOrderItem5 = new kumocomm__OrderItem__c(kumocomm__Amount__c = 100, kumocomm__Order__c = testOrder.Id, kumocomm__Product__c = prodLP.Id, kumocomm__Quantity__c = 2, MKT_Assignment_Status_c__c = 'Completed');
            kumocomm__OrderItem__c NewOrderItem6 = new kumocomm__OrderItem__c(kumocomm__Amount__c = 100, kumocomm__Order__c = testOrder.Id, kumocomm__Product__c = prodCur.Id, kumocomm__Quantity__c = 2, MKT_Assignment_Status_c__c = 'Completed');

            insert new List<kumocomm__OrderItem__c>{NewOrderItem,NewOrderItem2,NewOrderItem3,NewOrderItem4,NewOrderItem5,NewOrderItem6};


        kumocomm__Transaction__c testTrans = new kumocomm__Transaction__c();
        testTrans.kumocomm__GatewayTransactionId__c = '1234567989';
        testTrans.kumocomm__Order__c = testOrder.ID;
        insert testTrans;
        Test.StartTest();
            ApexPages.currentPage().getParameters().put('OrderId', testOrder.Id);
            MKT_PrintOrder printObj = new MKT_PrintOrder();
            System.AssertEquals(printObj.GatewayTransactionId, testTrans.kumocomm__GatewayTransactionId__c);
        Test.StopTest();
    }*/
}