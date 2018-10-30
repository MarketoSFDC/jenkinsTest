public with sharing class MKT_PaymentController {

    public Boolean PaymentComplete { get; set; }
    public Boolean PaymentCompleteCost { get; set; }
    public Boolean EnrollPaymentError { get; set; }
    public String ObjId { get; set; }
    public Boolean isEnroll { get; set; }
    public String TypeObj { get; set; }
    public String ClassId { get; set; }
    public String AccountId { get; set; }
    public String AssignId { get; set; }
    public String Action { get; set; }
    public String RedirectLink { get; set; }
    public PaymentInfo paymentObj { get; set; }
    public Account acc{ get; set; }
    public List<User> UserList { get; set; }
    public lmsilt__Event__c EventDetails { get; set; }
    public lmscons__Quiz__c QuizDetails { get; set; }
    public lmscons__Training_Content__c ModuleDetails { get; set; }
    public lmscons__Learning_Path__c LPDetails { get; set; }
    public lmscons__Curriculum__c CurriculumDetails { get; set; }
    public lmscons__Training_Path__c CourseDetails { get; set; }

    private static final Integer MAXAGE = 60*60*24*365;
    private static final Long AGE = 60*60*24*7;

    //------------- CONSTRUCTOR ---------------------------
    public MKT_PaymentController () {
        EnrollPaymentError = false;
        PaymentComplete = false;
        PaymentCompleteCost = false;
        paymentObj = new PaymentInfo();
        ObjId = ApexPages.currentPage().getParameters().get('ObjId');
        ClassId = ApexPages.currentPage().getParameters().get('ClassId');
        TypeObj = ApexPages.currentPage().getParameters().get('TypeObj');
        AssignId = ApexPages.currentPage().getParameters().get('assign');
        Action = ApexPages.currentPage().getParameters().get('Action');
    }

    public pageReference InitPaymentObjects() {
        if (!HelperWithoutSharing.isAccessUser()) {
            EnrollPaymentError = true;
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, Label.MKT_AccessDeniedError));
            return NULL;
        }

        paymentObj.curUser = [SELECT Id, UserType, AccountId, ContactId, Contact.Account.Name, CompanyName, Contact.Account.Intacct_Entity__c, Contact.Account.IntacctID__c, Name, Phone, Email FROM User WHERE Id =: UserInfo.GetUserId() LIMIT 1];
        UserList = new List<User>();
        UserList.Add(paymentObj.curUser);
        if (paymentObj.curUser.UserType.equalsIgnoreCase('CSPLitePortal') || paymentObj.curUser.UserType.equalsIgnoreCase('CustomerSuccess') || paymentObj.curUser.UserType.equalsIgnoreCase('PowerCustomerSuccess')) {
            AccountId = paymentObj.curUser.AccountId;
        }
        else {
            //AccountId = [SELECT Id FROM Account WHERE Name = 'TestUserAccount' LIMIT 1].Id;
            AccountId = NULL;
        }
        if (TypeObj == lmscons__Quiz__c.sObjectType.getDescribe().getLabel()) {
            QuizDetails = [SELECT Id, Name, Product__c, lmscons__Description__c FROM lmscons__Quiz__c WHERE Id = :ObjId];
            paymentObj.ProductId = String.ValueOf(QuizDetails.Product__c);
            paymentObj.Title = QuizDetails.Name;
            paymentObj.Description = QuizDetails.lmscons__Description__c;
        }
        else if (TypeObj == lmsilt__Event__c.sObjectType.getDescribe().getLabel()) {
            EventDetails = [SELECT Id, Name, Product__c, lmsilt__Description__c FROM lmsilt__Event__c WHERE Id = :ObjId];
            paymentObj.ClassesObj = (ClassId == '' || ClassId == NULL) ? NULL : [SELECT Id, Name, lmsilt__Start_Date__c, lmsilt__End_Date__c, lmsilt__Maximum_Capacity__c, lmsilt__Waitlist_Enabled__c, lmsilt__Cancellation_Policy_lookup__c, lmsilt__Cancellation_Policy_lookup__r.lmsilt__Description__c, lmsilt__Cancellation_Policy_lookup__r.Name, (SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, lmsilt__ILT_vILT__c, lmsilt__Session_Location__c, lmsilt__Session_Location__r.Name, lmsilt__Class__c, lmsilt__Event__c, lmsilt__Start_Date_Time__c, lmsilt__End_Date_Time__c FROM lmsilt__Sessions__r ORDER BY lmsilt__Start_Date_Time__c) FROM lmsilt__Class__c WHERE Id = :ClassId];
            paymentObj.Title = EventDetails.Name;
            paymentObj.Description = EventDetails.lmsilt__Description__c;
            paymentObj.ProductId = String.ValueOf(EventDetails.Product__c);
        }
        else if (TypeObj == lmscons__Training_Content__c.sObjectType.getDescribe().getLabel()) {
            ModuleDetails = [SELECT Id, Name, Product__c, lmscons__Description__c FROM lmscons__Training_Content__c WHERE Id = :ObjId];
            paymentObj.Title = ModuleDetails.Name;
            paymentObj.Description = ModuleDetails.lmscons__Description__c;
            paymentObj.ProductId = String.ValueOf(ModuleDetails.Product__c);
        }
        else if (TypeObj == lmscons__Training_Path__c.sObjectType.getDescribe().getLabel()) {
            CourseDetails =  [SELECT Id, Name, Product__c, lmscons__Description__c FROM lmscons__Training_Path__c WHERE Id = :ObjId];
            paymentObj.Title = CourseDetails.Name;
            paymentObj.Description = CourseDetails.lmscons__Description__c;
            paymentObj.ProductId = String.ValueOf(CourseDetails.Product__c);
        }
        else if (TypeObj == lmscons__Learning_Path__c.sObjectType.getDescribe().getLabel()) {
            LPDetails = [SELECT Id, Name, Product__c, lmscons__Description__c FROM lmscons__Learning_Path__c WHERE Id = :ObjId];
            paymentObj.Title = LPDetails.Name;
            paymentObj.Description = LPDetails.lmscons__Description__c;
            paymentObj.ProductId = String.ValueOf(LPDetails.Product__c);
        }
        else if (TypeObj == lmscons__Curriculum__c.sObjectType.getDescribe().getLabel()) {
            CurriculumDetails = [SELECT Id, Name, Product__c, lmscons__Description__c FROM lmscons__Curriculum__c WHERE Id = :ObjId];
            paymentObj.Title = CurriculumDetails.Name;
            paymentObj.Description = CurriculumDetails.lmscons__Description__c;
            paymentObj.ProductId = String.ValueOf(CurriculumDetails.Product__c);
        }

        if (Action == 'unEnrollUser') {
            unEnrollUser();
        }
        else if (Action == 'addToCart') {
            AddToCart();
        }
        if (Action == 'freeRegister') {
            System.Debug('freeRegister============================');
            if (AssignId != NULL && AssignId != '' && TypeObj == lmsilt__Event__c.sObjectType.getDescribe().getLabel() && (CheckAssignEvent() || AccountId == NULL)) {
                EnrollEventClass();
                if (CheckEnroll()) {
                    PaymentComplete = true;
                }
                else {
                    EnrollPaymentError = true;
                }
            }
            else if (AccountId == NULL) {
                System.Debug('AccountId == NULL============================');
                EnrollObjects();
                if (CheckEnroll()) {
                    PaymentComplete = true;
                }
                else {
                    EnrollPaymentError = true;
                }
                return NULL;
            }
            else {
                System.Debug('AccountId ==============================' + AccountId);
                GetInfoObjectPayment();
            }
        }
        return NULL;
    }
    public Boolean AddToCart() {
        //kumocomm__ShoppingCart__c ShCart;
        if (paymentObj.curUser.contactId != NULL) {
            //List<kumocomm__ShoppingCart__c> ShCartList = [SELECT Id FROM kumocomm__ShoppingCart__c WHERE kumocomm__Contact__c = :paymentObj.curUser.contactId AND kumocomm__Status__c = 'Active' LIMIT 1];
            //if (ShCartList.size() > 0) {
               // ShCart = ShCartList[0];
           // }
            //else {
               // ShCart = new kumocomm__ShoppingCart__c();
               // ShCart.kumocomm__Contact__c = paymentObj.curUser.contactId;
                //ShCart.kumocomm__Status__c = 'Active';
                //insert ShCart;
            //}
        }
        else {
            String SessionID = HelperWithoutSharing.getCurrentSessionId();
            if (SessionID != null) {
                //List<kumocomm__ShoppingCart__c> ShCartList = [SELECT Id FROM kumocomm__ShoppingCart__c WHERE kumocomm__SessionKey__c = :SessionID AND kumocomm__Status__c = 'Active' LIMIT 1];
                //if (ShCartList.size() > 0) {
                   // ShCart = ShCartList[0];
               // }
            }
            //if (ShCart == NULL) {
               // SessionID = setCookie();
               // ShCart = new kumocomm__ShoppingCart__c();
                //ShCart.kumocomm__Status__c = 'Active';
                //ShCart.kumocomm__SessionKey__c = SessionID;
                //insert ShCart;
            //}

        }
        //kumocomm__ShoppingCartItem__c ShCartItem;
       // List<kumocomm__ShoppingCartItem__c> ShCartItemList = [SELECT Id, /*MKT_Class__c, */kumocomm__Quantity__c, kumocomm__Product__c, kumocomm__Status__c FROM kumocomm__ShoppingCartItem__c WHERE kumocomm__ShoppingCart__c = :ShCart.Id AND kumocomm__Product__c = :paymentObj.ProductId AND kumocomm__Status__c = 'In Cart' LIMIT 1];
        //if (ShCartItemList.size() == 0) ShCartItemList = [SELECT Id, /*MKT_Class__c,*/ kumocomm__Quantity__c, kumocomm__Product__c, kumocomm__Status__c FROM kumocomm__ShoppingCartItem__c WHERE kumocomm__ShoppingCart__c = :ShCart.Id AND kumocomm__Product__c = :paymentObj.ProductId AND kumocomm__Status__c = 'Removed' LIMIT 1];
        //if (ShCartItemList.size() > 0) {
        //    ShCartItem = ShCartItemList[0];
        //}
       // else {
           // ShCartItem = new kumocomm__ShoppingCartItem__c();
        //}
       // ShCartItem.kumocomm__Product__c = paymentObj.ProductId;
       // ShCartItem.kumocomm__Quantity__c = 1;
        //ShCartItem.kumocomm__Status__c = 'In Cart';
       // if (paymentObj.ClassesObj != NULL) {}//ShCartItem.MKT_Class__c = paymentObj.ClassesObj.Id;
        //ShCartItem.kumocomm__ShoppingCart__c = ShCart.Id;
        //upsert ShCartItem;
        return true;
    }
    private String getGeneratedId() {
        Blob blobKey = crypto.generateAesKey(128);
        String key = EncodingUtil.convertToHex(blobKey);
        return String.valueOf(system.currentTimeMillis()) + '%' + key.substring(0,25);
    }

    public String setCookie() {
        String SessionID = getGeneratedId();
        Cookie ShoppingCart = new Cookie(HelperWithoutSharing.CURRENT_COOKIE_NAME, SessionID, null, MAXAGE, false);
        ApexPages.currentPage().setCookies(new Cookie[]{ShoppingCart});
        return SessionID;
    }

    public void GetInfoObjectPayment() {
        Savepoint sp = Database.setSavepoint();
        isEnroll = false;
        try {
            PricebookEntry PricebookEntryItem = HelperWithoutSharing.getPricebookEntryByProductId(paymentObj.ProductId);
            if (PricebookEntryItem != NULL && PricebookEntryItem.UnitPrice != 0) {
                paymentObj.Cost = PricebookEntryItem.UnitPrice;
                paymentObj.PricebookEntryItem = PricebookEntryItem;
                List<MKT_PaymentLicense__c> paymentLicenseList = [SELECT Id, User__c, MKT_Payment__c FROM MKT_PaymentLicense__c WHERE IsDeleted = false AND Canceled__c = false AND User__c = :UserInfo.getUserId() AND MKT_Payment__r.Product__c = :paymentObj.ProductId AND MKT_Payment__r.Account__c = :AccountId];
                if (paymentLicenseList.size() > 0) {
                    isEnroll = true;
                }
                else {
                    List<MKT_Payment__c> paymentList = [SELECT Id, Remaining_Seats__c FROM MKT_Payment__c WHERE Product__c =: PricebookEntryItem.Product2Id AND Remaining_Seats__c > 0 AND Account__c =: AccountId LIMIT 1];
                    if (paymentList.Size() > 0) {
                        MKT_PaymentLicense__c paymentLicense = new MKT_PaymentLicense__c(User__c = paymentObj.curUser.Id, MKT_Payment__c = paymentList[0].Id);
                        insert paymentLicense;
                        isEnroll = true;
                    }
                }
            }
            else {
                isEnroll = true;
            }

            if (isEnroll) {
                EnrollObjects();
                if (CheckEnroll()) {
                    PaymentComplete = true;
                }
                else {
                    EnrollPaymentError = true;
                }
            }
        }
        catch (Exception e) {
            EnrollPaymentError = true;
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.GetMessage()));
        }
    }
    public void EnrollObjects() {
        Savepoint sp = Database.setSavepoint();
        try {
            if (TypeObj == lmscons__Quiz__c.sObjectType.getDescribe().getLabel()) {
                lmscons.LMSUtil.assignQuiz(UserList, QuizDetails);
            }
            else if (TypeObj == lmsilt__Event__c.sObjectType.getDescribe().getLabel()) {
                lmsilt.ILTUtil.assignEvent(UserList, EventDetails);
                EnrollEventClass();
            }
            else if (TypeObj == lmscons__Training_Content__c.sObjectType.getDescribe().getLabel()) {
                lmscons.LMSUtil.assignModule(UserList, ModuleDetails);
            }
            else if (TypeObj == lmscons__Training_Path__c.sObjectType.getDescribe().getLabel()) {
                lmsilt.ILTUtil.assignCourse(UserList, CourseDetails);
            }
            else if (TypeObj == lmscons__Learning_Path__c.sObjectType.getDescribe().getLabel()) {
                lmsilt.ILTUtil.assignLearningPath(UserList, LPDetails);
            }
            else if (TypeObj == lmscons__Curriculum__c.sObjectType.getDescribe().getLabel()) {
                lmsilt.ILTUtil.assignCurriculum(UserList, CurriculumDetails);
            }
        }
        catch (Exception e) {
            EnrollPaymentError = true;
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO, e.GetMessage()));
        }
    }

    public Boolean CheckAssignEvent() {
        List<lmscons__Transcript_Line__c> AssignedTL = [SELECT Id From lmscons__Transcript_Line__c  WHERE lmscons__Training_User_License__r.lmscons__User__c =: paymentObj.curUser.Id AND Id =: AssignId AND lmscons__Curriculum_Item__c = NULL AND lmscons__Learning_Path_Item__c = NULL AND lmscons__Training_Path_Item__c = NULL AND lmsilt__Event__c =: ObjId];
        return (AssignedTL.size() == 0);
    }
    public Boolean CheckEnroll () {
        Set<Id> AssignedContent = new Set<Id>();
        for (lmscons__Transcript_Line__c tl : [SELECT lmsilt__Event__c, lmscons__Quiz__c, lmscons__Training_Content__c, lmscons__Status__c, lmscons__Training_Path_Item__r.lmscons__Training_Path__c, lmscons__Training_Path_Item__c, t.lmscons__Learning_Path_Item__c, t.lmscons__Learning_Path_Item__r.lmscons__Learning_Path__c, t.lmscons__Curriculum_Item__r.lmscons__Curriculum__c, t.lmscons__Curriculum_Item__c FROM lmscons__Transcript_Line__c t WHERE lmscons__Training_User_License__r.lmscons__User__c =: paymentObj.curUser.Id]){
            if (tl.lmscons__Curriculum_Item__c == NULL && tl.lmscons__Learning_Path_Item__c == NULL && tl.lmscons__Training_Path_Item__c == NULL && tl.lmsilt__Event__c == ObjId && tl.lmscons__Status__c == 'Enrolled') {
                AssignedContent.add(tl.lmsilt__Event__c);
            }
            if (tl.lmscons__Curriculum_Item__c == NULL && tl.lmscons__Learning_Path_Item__c == NULL && tl.lmscons__Training_Path_Item__c == NULL && tl.lmscons__Quiz__c == ObjId) {
                AssignedContent.add(tl.lmscons__Quiz__c);
            }
            if (tl.lmscons__Curriculum_Item__c == NULL && tl.lmscons__Learning_Path_Item__c == NULL && tl.lmscons__Training_Path_Item__c == NULL && tl.lmscons__Training_Content__c == ObjId) {
                AssignedContent.add(tl.lmscons__Training_Content__c);
            }
            if (tl.lmscons__Curriculum_Item__c == NULL && tl.lmscons__Learning_Path_Item__c == NULL && tl.lmscons__Training_Path_Item__c == NULL && tl.lmscons__Training_Content__c == ObjId) {
                AssignedContent.add(tl.lmscons__Training_Content__c);
            }
            if (tl.lmscons__Curriculum_Item__c == NULL && tl.lmscons__Learning_Path_Item__c == NULL && tl.lmscons__Training_Path_Item__c != NULL) {
                AssignedContent.add(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c);
            }
            if (tl.lmscons__Curriculum_Item__c == NULL && tl.lmscons__Learning_Path_Item__c != NULL) {
                AssignedContent.add(tl.lmscons__Learning_Path_Item__r.lmscons__Learning_Path__c);
            }
            if (tl.lmscons__Curriculum_Item__c != NULL) {
                AssignedContent.add(tl.lmscons__Curriculum_Item__r.lmscons__Curriculum__c);
            }
        }
        return (AssignedContent.size() > 0);
    }

    public void EnrollEventClass () {
        Savepoint sp = Database.setSavepoint();
        try {
            List<lmsilt__Session__c> ss = [SELECT Id FROM lmsilt__Session__c WHERE lmsilt__Class__c = :ClassId AND lmsilt__Meeting_Type__c != null];

            List<lmscons__Transcript_Line__c> TLList = [SELECT Id, lmsilt__Class__c, lmsilt__Roster__c FROM lmscons__Transcript_Line__c WHERE lmsilt__Event__c = :ObjId AND lmscons__Transcript__r.lmscons__Trainee__c =: userinfo.getUserId()];

            lmsilt__Class__c cls = [SELECT id, lmsilt__Start_Date__c, lmsilt__End_Date__c, lmsilt__Total_hours__c, lmsilt__Event__c, lmsilt__Maximum_Capacity__c, lmsilt__Cancellation_Policy_lookup__c FROM lmsilt__Class__c WHERE id=:ClassId];

            Integer StudentsEnroledInRoster = [SELECT COUNT() FROM lmsilt__Roster__c WHERE lmsilt__Class__c=:ClassId AND lmsilt__Status__c = 'Enrolled'];

            String Status = Label.lmsilt.Enrolled;
            Integer StudentsWaitlistedInRoster = null;

            if (StudentsEnroledInRoster >= cls.lmsilt__Maximum_Capacity__c) {
                Status = Label.lmsilt.Waitlist;
                list<AggregateResult> c = [SELECT MAX(lmsilt__Waitlist_Priority__c) from lmsilt__Roster__c where lmsilt__Class__c=:ClassId and lmsilt__Status__c = 'Waitlisted'];

                StudentsWaitlistedInRoster = (c[0].get('expr0') != null) ? Integer.valueOf(c[0].get('expr0')) : NULL;
                if (StudentsWaitlistedInRoster != null) {
                    StudentsWaitlistedInRoster = StudentsWaitlistedInRoster+1;
                }
                else {
                    StudentsWaitlistedInRoster = 1;
                }
            }

            lmsilt__Roster__c rNew = new lmsilt__Roster__c(
                lmsilt__Class__c = ClassId,
                lmsilt__Status__c = Status,
                lmsilt__Student__c = userinfo.getUserId(),
                lmsilt__Waitlist_Priority__c = StudentsWaitlistedInRoster
            );

            List<lmsilt__Roster__c> rstList = new List<lmsilt__Roster__c>();
            rstList.add(rNew);

            upsert rstList;

            for (lmscons__Transcript_Line__c tl : TLList) {
                tl.lmsilt__Class__c = ClassId;
                tl.lmsilt__Roster__c = rNew.Id;
                tl.lmscons__Status__c = Status;
            }

            update TLList;

            HelperWithoutSharing.RegisterforTrainingClass(new Set<String> {ClassId});
        }
        catch(Exception e) {
            EnrollPaymentError = true;
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, e.GetMessage()));
        }
    }

    public void unEnrollUser() {
        Savepoint sp = Database.setSavepoint();
        try {
            Id ClsId = null;
            Integer aJobs = [SELECT COUNT() FROM AsyncApexJob WHERE Jobtype = 'BatchApex' AND ( Status = 'Queued' OR Status = 'Processing')];
                if (aJobs == 5) {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, Label.lmsilt.BatchNotAllowed));
                    return;
                }
            List<lmscons__Transcript_Line__c> TLList = [SELECT Id, lmsilt__Class__c, lmsilt__Roster__c FROM lmscons__Transcript_Line__c WHERE lmsilt__Event__c = :ObjId AND lmscons__Transcript__r.lmscons__Trainee__c =: paymentObj.curUser.Id];
            System.Debug('TLList========='+TLList);
            if (TLList.size() > 0) {
                Set<Id> tstIds = new Set<Id>();
                for (lmscons__Transcript_Line__c tl : TLList) {
                    if (tl.lmsilt__Roster__c != null) {
                        tstIds.add(tl.lmsilt__Roster__c);
                    }
                    ClsId = tl.lmsilt__Class__c;

                    tl.lmsilt__Roster__c = null;
                    tl.lmsilt__Class__c = null;
                    tl.lmscons__Status__c = 'Cancelled';
                }

                HelperWithoutSharing.updateILTAssignment(TLList);
                HelperWithoutSharing.unRegisterforTraining(ClsId, userinfo.getUserId());
                System.Debug('tstIds========='+tstIds);
                if (tstIds.size() > 0) {
                    List<lmsilt__Roster__c> r = [SELECT Id FROM lmsilt__Roster__c WHERE lmsilt__Student__c = :userinfo.getUserId() AND Id IN:tstIds];
                    System.Debug('r========='+r);
                    HelperWithoutSharing.DeleteSessionsRoster(r);
                    System.Debug('r2========='+r);
                    HelperWithoutSharing.DeleteRoster(r);
                    System.Debug('r3========='+r);
                }
            }
            else {
                ClsId = ClassId;
            }
            lmsilt__Class__c cls = HelperWithoutSharing.getClassByClassId(ClsId);

            Integer StudentsEnroledInRoster = HelperWithoutSharing.getCountStudentEnroled(ClsId);
            Integer StudentsWaitlistedInRoster = HelperWithoutSharing.getCountStudentWaitlisted(ClsId);
            if (StudentsEnroledInRoster >= cls.lmsilt__Maximum_Capacity__c) {
                return;
            }

            if (StudentsWaitlistedInRoster > 0) {
                Map<Id, List<lmsilt__Roster__c>> cls_listRoster = new Map<Id, List<lmsilt__Roster__c>>();
                cls_listRoster = HelperWithoutSharing.getWaitlistMapRostersByClassIds(clsId);
                List<lmsilt__Roster__c> listRoster = new List<lmsilt__Roster__c>();
                if (cls_listRoster != null && cls_listRoster.size() > 0) {
                    if (cls_listRoster.get(clsId).size()>0) {
                        Integer i=1;
                        Integer diffC = Integer.valueOf(cls.lmsilt__Maximum_Capacity__c - StudentsEnroledInRoster);
                        if (diffC > 0) {
                            for (lmsilt__Roster__c r : cls_listRoster.get(clsId)) {
                                listRoster.add(r);
                                i++;
                                if (diffC < i) {
                                    break;
                                }
                            }
                        }
                    }
                }
                if (listRoster.size() > 0) {
                    for (lmsilt__Roster__c r : listRoster) {
                        r.lmsilt__Status__c = 'Enrolled';
                    }
                    HelperWithoutSharing.updateRoster(listRoster);
                }
            }
            //delete temp objects for Workflow;
            List<MKT_Email_Workflow_in_CyberU__c> emailWorkflows = [SELECT ID, Class__c, User__c FROM MKT_Email_Workflow_in_CyberU__c WHERE Class__c = : ClsId AND User__c = :paymentObj.curUser.Id];
            if (emailWorkflows.Size() > 0) {
                HelperWithoutSharing.DeleteEmailWorkflows(emailWorkflows);
            }
            //for not nested courses the license returns
            if (!CheckAssignEvent()) {
                if (paymentObj.ProductId != NULL && paymentObj.ProductId != '') {
                    List<MKT_PaymentLicense__c> paymentLicenseList = [SELECT Id, MKT_Payment__c FROM MKT_PaymentLicense__c WHERE MKT_Payment__r.Product__c =: paymentObj.ProductId AND User__c =: paymentObj.curUser.Id AND Canceled__c = false LIMIT 1];
                    if (paymentLicenseList.Size() > 0) {
                        List<MKT_Payment__c> paymentList = [SELECT Id, Remaining_Seats__c FROM MKT_Payment__c WHERE Id =: paymentLicenseList[0].MKT_Payment__c AND Account__c =: AccountId LIMIT 1];
                        if (paymentList.Size() > 0 && paymentObj.ClassesObj.lmsilt__Start_Date__c > datetime.now()) {
                            Action = 'CloseWin';
                            paymentLicenseList[0].Canceled__c = true;
                            update paymentLicenseList[0];
                        }
                    }
                }
                List<lmscons__Transcript_Line__c> assignments_for_delete = [SELECT Id FROM lmscons__Transcript_Line__c WHERE Id = : AssignId];
                if (assignments_for_delete.size() > 0) {
                    delete assignments_for_delete;
                }
            }
            Action = 'CloseWin';
        }
        catch(Exception e) {
            EnrollPaymentError = true;
            Database.rollback(sp);
            ApexPages.addMessage(new ApexPages.Message(ApexPages.SEVERITY.ERROR, e.GetMessage()));
        }
    }

    public class PaymentInfo {
        public String paymentStatus { get; set; }
        public String Title { get; set; }
        public Boolean isAccept { get; set; }
        public PricebookEntry PricebookEntryItem { get; set; }
        //public kumocomm.KumoCollectionClasses.AddressInfo customerAddress{ get; set; }
        public lmsilt__Class__c ClassesObj { get; set; }
        public User curUser { get; set; }
        public Decimal Cost { get; set; }
        public String ProductId { get; set; }
        public String Description { get; set; }
        public String CardEnding { get; set; }
        public String FirstName { get; set; }
        public String LastName { get; set; }
        public String Quantity { get; set; }
        public String CardType { get; set; }
        public String CardNumber { get; set; }
        public String ExpirationMonth { get; set; }
        public String ExpirationYear { get; set; }
        public String Code { get; set; }

        public PaymentInfo() {
            String curHost = ApexPages.currentPage().getHeaders().get('Host');
            //customerAddress = new kumocomm.KumoCollectionClasses.AddressInfo();
            paymentStatus = NULL;
            if (curHost != '' && curHost != NULL && !curHost.contains('marketo--cyberu0925') && !curHost.contains('marketo--fullcopy')) {
                Quantity = '1';
                isAccept = false;
            }
            else {
                Quantity = '1';
                CardNumber = '5555555555554444';
                cardType = 'MasterCard';
                ExpirationMonth = '07';
                ExpirationYear = '2015';
                Code = '678';
                //customerAddress.Address1 = 'Suite 300';
                //customerAddress.Country = 'US';
                //customerAddress.State = 'CA';
                //customerAddress.Zip = '2240000';
                //customerAddress.City = 'NY';
                FirstName = 'Piter';
                LastName = 'James';
                isAccept = true;
            }

        }
    }


    //-----------------------------------------------------------------------
    //--                          TEST METHODS                            ---
    //-----------------------------------------------------------------------
    //MKT_PaymentControllerTest.cls
}