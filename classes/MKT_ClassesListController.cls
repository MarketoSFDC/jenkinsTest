public with sharing class  MKT_ClassesListController {

    public List<ObjectWrapper> cwList { get; set; }
    public Boolean exRecords { get; set; }
    public String EventId { get; set; }
    public Integer ClassSize { get; set; }
    public String ClassId { get; set; }
    public String SessionId { get; set; }
    public String NewClassId { get; set; }
    public String AssignId { get; set; }
    public lmsilt__Event__c EventDetails { get; set; }
    public List<lmsilt__Session__c> SessionsList { get; set; }
    public lmsilt__Session__c LocationFromSessionObj { get; set; }
    public Map<String, lmsilt__Session__c> SessionIdObjMap { get; set; }
    public List<lmsilt__Material__c> MaterialsList { get; set; }
    public lmsilt__Roster__c Roster { get; set; }
    public lmsilt__Development_Plan_Task__c SelectedTask { get; set; }
    public lmscons__Transcript_Line__c SelectedTranscriptLine { get; set; }
    public lmsilt__Class__c ClassCancellationPolicy { get; set; }
    public String EventPrice { get; set; }
    public String Action { get; set; }
    public Boolean ShowAddToCart { get; set; }
    public Boolean IsInCart { get; set; }
    public String TaskId { get; set; }
    public String TrLineId { get; set; }
    //------------- CONSTRUCTOR ---------------------------
    public MKT_ClassesListController() {
        try {
            exRecords = false;
            cwList = new List<ObjectWrapper>();
            EventId = ApexPages.currentPage().getParameters().get('EventId');
            SessionId = ApexPages.currentPage().getParameters().get('SessionId');
            ClassId = ApexPages.currentPage().getParameters().get('ClassId');
            NewClassId = ApexPages.currentPage().getParameters().get('NewClassId');
            AssignId = ApexPages.currentPage().getParameters().get('assign');
            Action = ApexPages.currentPage().getParameters().get('Action');
            TaskId = ApexPages.currentPage().getParameters().get('task');
            TrLineId = ApexPages.currentPage().getParameters().get('itemid');
            SessionIdObjMap = new Map<String, lmsilt__Session__c>();
            IsInCart = false;
            if (Action == 'geteventdetails') {
                GetEventDetails();
            }
            else if (Action == 'showtaskdetails') {
                ShowTaskDetails();
            }
            else if (Action == 'showLocation') {
                ShowSessionLocation();
            }
            else if (EventId != NULL && EventId != '') {
                GetClasses();
            }
        }
        catch (Exception e) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.MKT_Records_not_found));
        }
    }

    public class ObjectWrapper {
        public Boolean isFree { get; set; }
        public Boolean isRegister { get; set; }
        public Boolean showRegister { get; set; }
        public Boolean showAddToCart { get; set; }
        public lmsilt__Class__c ClassObj { get; set; }
        public String Status { get; set; }
        public ObjectWrapper (lmsilt__Class__c s) {
            ClassObj = s;
            isFree = true;
            isRegister = false;
            showRegister = false;
            showAddToCart = false;
        }
    }
    public void ShowSessionLocation () {
        LocationFromSessionObj = new lmsilt__Session__c();
        if (SessionsList == NULL && SessionId != NULL && SessionId != '') {
            SessionsList = [SELECT Id, lmsilt__Start_Date_Time__c, lmsilt__End_Date_Time__c, lmsilt__Session_Location__c,
                            lmsilt__ILT_vILT__c,  lmsilt__Session_Location__r.Name, lmsilt__Session_Location__r.lmsilt__ZIP__c, lmsilt__Session_Location__r.lmsilt__Type__c,
                            lmsilt__Session_Location__r.lmsilt__Street_Address__c, lmsilt__Session_Location__r.lmsilt__State__c, lmsilt__Session_Location__r.lmsilt__Room__c,
                            lmsilt__Session_Location__r.lmsilt__Region__c, lmsilt__Session_Location__r.lmsilt__Postal_code__c, lmsilt__Session_Location__r.lmsilt__Country__c,
                            lmsilt__Session_Location__r.lmsilt__Contact_Phone__c, lmsilt__Session_Location__r.lmsilt__City__c, lmsilt__Session_Location__r.ArrivalText__c,
                            lmsilt__Session_Location__r.Accommodations__c
                            FROM lmsilt__Session__c WHERE Id = :SessionId ORDER BY lmsilt__Start_Date_Time__c];
            for (lmsilt__Session__c SessionItem :SessionsList) {
                SessionIdObjMap.put(SessionItem.ID, SessionItem);
            }
        }
        if (SessionId != NULL && SessionId != '' && SessionIdObjMap.containskey(SessionId)) {
            LocationFromSessionObj = SessionIdObjMap.get(SessionId);
        }
    }
    public PageReference ShowTaskDetails() {

        SelectedTask = [SELECT l.lmsilt__User__c, l.lmsilt__Task_Manager__c, l.lmsilt__Description__c, l.lmsilt__URL__c, l.Name, l.Id FROM lmsilt__Development_Plan_Task__c l WHERE l.Id =: TaskId];
        SelectedTranscriptLine = [SELECT lmscons__Status__c, lmscons__Score__c, Id From lmscons__Transcript_Line__c WHERE Id =: TrLineId];

        return null;
    }

    public List<Attach> getTaskAttachments () {
        List<Attach> atcl = new List<Attach>();
        for (Attachment a : [SELECT ParentId, Name, BodyLength, Id FROM Attachment WHERE ParentId =: TaskId]) {
            Attach atc = new Attach();
            atc.Id = a.Id;
            if (a.Name != NULL) {
                atc.Name = a.Name;
            }
            else {
                atc.Name = '';
            }
            if (a.BodyLength > 1024) {
                atc.BodyLength = String.valueOf(Decimal.valueOf(Decimal.valueOf(a.BodyLength/1024).intValue()))+' Kb';
            }
            else {
                atc.BodyLength = String.valueOf(a.BodyLength)+' B';
            }
            atcl.add(atc);
        }
        return atcl;
    }

    public PageReference MarkComplete() {
        SelectedTranscriptLine.lmscons__Percent_Complete__c = 100;
        SelectedTranscriptLine.lmscons__Status__c = 'Completed';

        List<lmscons__Transcript_Line__c> AssignmentList = new List<lmscons__Transcript_Line__c>();
        AssignmentList.add(SelectedTranscriptLine);
        HelperWithoutSharing.updateILTAssignment(AssignmentList);

        return null;
    }

    public class Attach {
        public String Id { get; set; }
        public String ParentId { get; set; }
        public String Name { get; set; }
        public String BodyLength { get; set; }
    }
    public void AddToCart() {
        if (EventDetails != NULL) {
            if (NewClassId == NULL) HelperWithoutSharing.AddToCart(EventDetails.Id, lmsilt__Event__c.sObjectType.getDescribe().getLabel());
            else HelperWithoutSharing.AddClassToCart(EventDetails.Id, NewClassId);
        }
    }
    public void GetClasses() {
        Boolean isFreeEvent = true;
        Boolean showRegisterEvent = false;
        PricebookEntry PricebookEntryEvent = new PricebookEntry();
        try {
            EventDetails = [SELECT Id, Name, Product__c, lmsilt__Description__c FROM lmsilt__Event__c WHERE Id = :EventId];
            if (EventDetails.Product__c != NULL) {
                PricebookEntryEvent = HelperWithoutSharing.getPricebookEntryByProductId(EventDetails.Product__c);
                Set<Id> CartItemsProductsSet = HelperWithoutSharing.getCurrentCartItemsProductsSet();
                IsInCart = CartItemsProductsSet.Contains(EventDetails.Product__c);
                System.Debug('=======IsInCart===='+IsInCart);
                Set<Id> PaidItemsProductsSet = HelperWithoutSharing.getPaidProductsSet(new Set<Id> {EventDetails.Product__c});
                if (PricebookEntryEvent.UnitPrice > 0 && AssignId == NULL && (PaidItemsProductsSet.Size() == 0)) isFreeEvent = false;
                EventPrice = 'free';
                if (PricebookEntryEvent.UnitPrice > 0) {
                    Decimal EventPriceDec = PricebookEntryEvent.UnitPrice;
                    EventPrice = HelperWithoutSharing.currencySymbol(PricebookEntryEvent.CurrencyIsoCode) + String.ValueOf(EventPriceDec.setScale(0).format());
                }
            }

        }
        catch (system.exception e) { }
        System.Debug('EventDetails============'+EventDetails);
        Set<Id> ClassIds = new Set<Id>();
        List<lmsilt__Class__c> ClassesList = new List<lmsilt__Class__c>();
        try {
            ClassesList = [SELECT Id, Name, lmsilt__Start_Date__c, lmsilt__End_Date__c, lmsilt__Maximum_Capacity__c, lmsilt__Waitlist_Enabled__c, lmsilt__Cancellation_Policy_lookup__c, (SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, lmsilt__ILT_vILT__c, lmsilt__Session_Location__c, lmsilt__Session_Location__r.Name, lmsilt__Class__c, lmsilt__Event__c, lmsilt__Start_Date_Time__c, lmsilt__End_Date_Time__c FROM lmsilt__Sessions__r ORDER BY lmsilt__Start_Date_Time__c) FROM lmsilt__Class__c WHERE lmsilt__Event__c = :EventId ORDER BY lmsilt__Start_Date__c ];
            for (lmsilt__Class__c cls : ClassesList) {
                ClassIds.add(cls.Id);
            }
            map<String, Integer> cls_CountRoster = HelperWithoutSharing.getCountRosterByClassAndStatus(ClassIds, Label.lmsilt.Enrolled);

            if (cls_CountRoster != NULL){
                if (cls_CountRoster.size() > 0) {
                    for (lmsilt__Class__c cls : ClassesList) {
                        System.Debug('cls============'+cls);
                        ObjectWrapper cw = new ObjectWrapper(cls);
                        cw.showRegister = (cls.lmsilt__Start_Date__c > datetime.now()) ? true : false;
                        cw.showAddToCart = (NewClassID == NULL) ? !IsInCart : cls.Id != NewClassID;
                        System.Debug('=======cw.showAddToCart===='+cw.showAddToCart);
                        if (cls.lmsilt__End_Date__c > datetime.now()) {
                            showRegisterEvent = (showRegisterEvent) ? true : (cls.lmsilt__Start_Date__c > datetime.now());

                            System.Debug('showRegisterEvent============'+showRegisterEvent);
                            if (cls_CountRoster.containsKey(cls.Id)) {
                                if (cls.lmsilt__Waitlist_Enabled__c == true) {
                                    cw.Status = Label.lmsilt.Active;
                                    if (cls.lmsilt__Maximum_Capacity__c <= cls_CountRoster.get(cls.Id)) {
                                        cw.Status = Label.lmsilt.Waitlist;
                                    }
                                    else {
                                        cw.Status = Label.lmsilt.Active;
                                    }
                                }
                                else {
                                    if (cls.lmsilt__Maximum_Capacity__c <= cls_CountRoster.get(cls.Id)) {
                                        cw.Status = Label.lmsilt.Full;
                                    }
                                    else {
                                        cw.Status = Label.lmsilt.Active;
                                    }
                                }
                            }
                            else {
                                cw.Status = Label.lmsilt.Active;
                            }
                            cwList.add(cw);
                        }
                    }
                }
            }
            else {
                for (lmsilt__Class__c cls : ClassesList) {
                    System.Debug('cls============'+cls);
                    ObjectWrapper cw = new ObjectWrapper(cls);
                    cw.Status = Label.lmsilt.Active;
                    cw.showRegister = (cls.lmsilt__Start_Date__c > datetime.now()) ? true : false;

                    if (cls.lmsilt__End_Date__c > datetime.now()) {
                        showRegisterEvent = (showRegisterEvent) ? true : (cls.lmsilt__Start_Date__c > datetime.now());
                        System.Debug('showRegisterEvent============'+showRegisterEvent);
                        cw.showAddToCart = (NewClassID == NULL) ? !IsInCart : cls.Id != NewClassID;
                        cwList.add(cw);
                    }
                }
            }
        }
        catch(system.exception e) { }

        if (ClassesList.size() == 0) {
            ClassSize = 0;
            exRecords = false;
        }
        else {
            ClassSize = 1;
            exRecords = true;
        }
        if (!isFreeEvent) ShowAddToCart = true;
    }


    public pageReference GetEventDetails() {

        try {
            EventDetails = [SELECT Id, Name, lmsilt__Description__c FROM lmsilt__Event__c WHERE Id = :EventId];
        }
        catch (system.exception e) { }

        List <lmsilt__Class__c> clsListcp = [SELECT Id, lmsilt__Cancellation_Policy_lookup__c, lmsilt__Cancellation_Policy_lookup__r.lmsilt__Description__c, lmsilt__Cancellation_Policy_lookup__r.Name FROM lmsilt__Class__c WHERE Id = :ClassId];
        ClassCancellationPolicy = (clsListcp.size() > 0) ? clsListcp[0] : NULL;

        try {
            SessionsList = [SELECT Id, lmsilt__Start_Date_Time__c, lmsilt__End_Date_Time__c, lmsilt__Session_Location__c,
                            lmsilt__ILT_vILT__c,  lmsilt__Session_Location__r.Name, lmsilt__Session_Location__r.lmsilt__ZIP__c, lmsilt__Session_Location__r.lmsilt__Type__c,
                            lmsilt__Session_Location__r.lmsilt__Street_Address__c, lmsilt__Session_Location__r.lmsilt__State__c, lmsilt__Session_Location__r.lmsilt__Room__c,
                            lmsilt__Session_Location__r.lmsilt__Region__c, lmsilt__Session_Location__r.lmsilt__Postal_code__c, lmsilt__Session_Location__r.lmsilt__Country__c,
                            lmsilt__Session_Location__r.lmsilt__Contact_Phone__c, lmsilt__Session_Location__r.lmsilt__City__c, lmsilt__Session_Location__r.ArrivalText__c,
                            lmsilt__Session_Location__r.Accommodations__c
                            FROM lmsilt__Session__c WHERE lmsilt__Class__c = :ClassId ORDER BY lmsilt__Start_Date_Time__c];
            for (lmsilt__Session__c SessionItem :SessionsList) {
                SessionIdObjMap.put(SessionItem.ID, SessionItem);
            }
        }
        catch (system.exception e) { }

        try {
            MaterialsList = [SELECT Id, lmsilt__Description__c, lmsilt__Instructions__c, Name, (Select Id, Name From Attachments) FROM lmsilt__Material__c WHERE lmsilt__Class__c = :ClassId OR lmsilt__Event__c =: EventId];
        }
        catch (system.exception e) { }

        try {
            Roster = [SELECT lmsilt__Status__c, lmsilt__Attended__c, Id FROM lmsilt__Roster__c WHERE lmsilt__Student__c = :UserInfo.getUserId() AND lmsilt__Class__c = :ClassId];
        }
        catch (system.exception e) { }
        ClassSize = 0;
        return null;
    }

    //-----------------------------------------------------------------------
    //--                          TEST METHODS                            ---
    //-----------------------------------------------------------------------


    public static testMethod void testMKT_ClassesListController(){
        Profile profile;
        try {
            profile = [SELECT Id FROM profile WHERE name='System Administrator'];
        } catch (system.exception e) {
            profile = [SELECT Id FROM profile WHERE Id=:UserInfo.getProfileId()];
        }
        /*User u = new User(alias = 'tes334t2', email='test23434@test.com', emailencodingkey='UTF-8', lastname='2te43st', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profile.Id, timezonesidkey='America/Los_Angeles', username='test@test343SF111112d.com');
        insert u;*/
        User u = HelperWithoutSharing.createTestUser(profile.Id, 'firstTestName2', 'secondtestName2','');
        insert u;
        
        lmscons__LMS_Consumer_Settings__c LCS = new lmscons__LMS_Consumer_Settings__c(lmscons__Default_License_Period__c='Months', lmscons__Default_License_Term__c = 12, lmscons__Cornerstone_Callback_URL__c='dep', lmscons__CyberUSecretSignKey__c='dep');
            insert LCS;

            lmscons__Transcript__c tr = new lmscons__Transcript__c(lmscons__Trainee__c = UserInfo.getUserId());
            insert tr;
            lmscons__Training_Content__c TC = new lmscons__Training_Content__c();
            insert TC;

            Date d = Date.valueOf(system.now());
            lmscons__Training_Content_License__c tcl = new lmscons__Training_Content_License__c(lmscons__Training_Content__c=TC.Id, lmscons__Expiration_Date__c=d, lmscons__Seats__c = 100);
            insert tcl;

            lmsilt__Event__c e2 = new lmsilt__Event__c(lmsilt__Languages__c = 'English', Name='Test Event');
            insert e2;

            lmscons__Training_Content__c tc2 = new lmscons__Training_Content__c(lmsilt__Event__c=e2.Id,lmscons__Title__c = 'Training me', lmscons__Cornerstone_ID__c = 'af');
            insert tc2;

            lmsilt__Meeting__c m = new lmsilt__Meeting__c(lmsilt__Meetingkey__c='123');
            insert m;

            lmsilt__Class__c cls = new lmsilt__Class__c(lmsilt__Event__c = e2.Id, lmsilt__Waitlist_Enabled__c = true, lmsilt__Maximum_Capacity__c = 1);
            insert cls;

            lmsilt__Material__c matir = new lmsilt__Material__c(lmsilt__Sequence__c = 'after', lmsilt__Class__c = cls.Id);
            insert matir;

            lmsilt__Material__c matir2 = new lmsilt__Material__c(lmsilt__Sequence__c = 'before', lmsilt__Class__c = cls.Id);
            insert matir2;

            //lmsilt__Session__c ss = new lmsilt__Session__c(lmsilt__Meeting__c = m.Id, lmsilt__ILT_vILT__c = 'vILT', lmsilt__Meeting_Type__c='GoToTraining', lmsilt__Class__c = cls.Id, lmsilt__Start_Date_Time__c = system.now().addDays(2), lmsilt__End_Date_Time__c=system.now().addDays(3));
            //insert ss;
            lmsilt__Session_Location__c sessLOc = new lmsilt__Session_Location__c(Name = 'testloc', lmsilt__Country__c = 'USA', lmsilt__Street_Address__c = 'testaddr');
            insert sessLOc;
            lmsilt__Session__c ss2 = new lmsilt__Session__c(lmsilt__Session_Location__c =sessLOc.Id, lmsilt__ILT_vILT__c = 'ILT', lmsilt__Class__c = cls.Id, lmsilt__Start_Date_Time__c = system.now().addDays(4), lmsilt__End_Date_Time__c=system.now().addDays(5));
            insert ss2;

            lmsilt__Development_Plan_Task__c taskTest = new lmsilt__Development_Plan_Task__c(lmsilt__User__c = UserInfo.getUserId(), lmsilt__Task_Manager__c = UserInfo.getUserId(), lmsilt__Description__c = 'testts', lmsilt__URL__c = 'https://docs.google.com');
            insert taskTest;

            lmscons__Training_User_License__c tul = new lmscons__Training_User_License__c( lmscons__Content_License__c = tcl.Id, lmscons__User__c = UserInfo.getUserId(), lmscons__Cornerstone_ID__c = 'af' );
            insert tul;
            lmscons__Transcript_Line__c tLineTask = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Cornerstone_ID__c = 'af',lmscons__Status__c = 'nCompleted', lmscons__Score__c = '0');
            insert tLineTask;
            Attachment attTest = new Attachment(Name = 'text.pdf', Body = Blob.valueof('sdfdsfdsfdsafdsfdsfdsfdsfs'), ParentId = taskTest.Id);
            insert attTest;
            lmsilt__Roster__c rNew = new lmsilt__Roster__c(
                lmsilt__Class__c = cls.Id,
                lmsilt__Status__c = 'Enrolled',
                lmsilt__Student__c = userinfo.getUserId(),
                lmsilt__Waitlist_Priority__c = 1
            );
            lmsilt__Roster__c rNew2 = new lmsilt__Roster__c(
                lmsilt__Class__c = cls.Id,
                lmsilt__Status__c = 'Enrolled',
                lmsilt__Student__c = u.Id,
                lmsilt__Waitlist_Priority__c = 2
            );

            Test.startTest();
                ApexPages.currentPage().getParameters().put('action', 'showLocation');
                ApexPages.currentPage().getParameters().put('SessionId', ss2.ID);
                MKT_ClassesListController contrSess = new MKT_ClassesListController();
                contrSess.ShowSessionLocation();
                ApexPages.currentPage().getParameters().put('action', '');
                ApexPages.currentPage().getParameters().put('EventId', e2.Id);
                ApexPages.currentPage().getParameters().put('ClassId', cls.Id);
                ApexPages.currentPage().getParameters().put('task', taskTest.Id);
                ApexPages.currentPage().getParameters().put('itemid', tLineTask.Id);
                MKT_ClassesListController contr = new MKT_ClassesListController();
                User curUser = [SELECT Id, UserType, AccountId, Name, Phone, Email FROM User WHERE Id =: UserInfo.GetUserId() LIMIT 1];
                List<User> UserList = new List<User>();
                UserList.Add(curUser);

                contr.GetClasses();
                System.assertEquals(contr.exRecords , true);
                insert rNew;
                insert rNew2;
                contr.GetClasses();
                System.assertEquals(contr.exRecords , true);

                lmsilt.ILTUtil.assignEvent(UserList, contr.EventDetails);
                contr.GetEventDetails();
                System.assertEquals(contr.EventDetails.Id, e2.Id);

                contr.EventId = cls.Id;
                contr.ClassId = e2.Id;
                contr.GetEventDetails();


                contr.ShowTaskDetails();
                System.assertEquals(contr.SelectedTask.Id, taskTest.Id);
                contr.MarkComplete();
                contr.getTaskAttachments();
                System.assertEquals(contr.SelectedTranscriptLine.lmscons__Percent_Complete__c, 100);

            Test.stopTest();

    }
}