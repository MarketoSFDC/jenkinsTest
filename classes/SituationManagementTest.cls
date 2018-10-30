@isTest(seeallData=true)
public class SituationManagementTest {
    
    public static testmethod void testHistoryComponent() {
        Account acc = new Account(Name = 'Default Partner');
        insert acc;
        Case caseObj = new Case(Status = 'New', Priority = 'P1', Subject = 'Test', Description = 'Test Description');
        insert caseObj;        
        List<CaseHistory> historyList = new List<CaseHistory>();
        CaseHistory caseHistory1 = new CaseHistory(Field = 'Status', CaseId = caseObj.id);
        historyList.add(caseHistory1);
        CaseHistory caseHistory2 = new CaseHistory(Field = 'Created', CaseId = caseObj.id);
        historyList.add(caseHistory2);
        insert historyList;        
        GenericHistoryComponentController history = new GenericHistoryComponentController();
        history.myObject = caseObj;
        history.getObjectHistory();
    }
    
    public static testmethod void testSMControl2()
    {
        

        List<Case> myCases = [SELECT Id, Status,Priority, Subject, Description, Situation_Contact__c, Situation_Account__c, Email_List__c  from Case where Situation_Account__c != Null and Situation_Contact__c != Null limit 10];
        Case caseObj =  myCases[0]; 
        caseObj.Email_List__c = 'test@mail.com';
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(caseObj);   
        ApexPages.currentPage().getParameters().put('id', caseObj.Id);     
        ApexPages.currentPage().getParameters().put('type', 'supp'); 
        ApexPages.currentPage().getParameters().put('type', 'feed');
        ApexPages.currentPage().getParameters().put('type', 'EscMan');
        
        SituationMgmtController situationCtrl = new SituationMgmtController(ctrl);        

        ApexPages.currentPage().getParameters().put('page', 'new_account');              
        situationCtrl = new SituationMgmtController(ctrl);        
        ApexPages.currentPage().getParameters().put('page', 'new_account');              
        situationCtrl = new SituationMgmtController(ctrl);   
        ApexPages.currentPage().getParameters().put('page', 'new_contact');              
        situationCtrl = new SituationMgmtController(ctrl);   
        ApexPages.currentPage().getParameters().put('page', 'edit');              
        situationCtrl = new SituationMgmtController(ctrl);   
        ApexPages.currentPage().getParameters().put('page', 'close');              
        situationCtrl = new SituationMgmtController(ctrl);   
        ApexPages.currentPage().getParameters().put('page', 'clone');              
        situationCtrl = new SituationMgmtController(ctrl);

    
    }
    
    public static testmethod void testSMController() {                
              
        
        //Contact testcontact = [Select Id, accountid from contact LIMIT 1];
        
        //Case caseObj = new Case(Status = 'New', Priority = 'P1', Subject = 'Test', Description = 'Test Description');
        //insert caseObj;          
        
        List<Case> myCases = [SELECT Id, Status,Priority, Subject, Description, Situation_Contact__c, Situation_Account__c, Email_List__c  from Case where Situation_Account__c != Null and Situation_Contact__c != Null limit 10];
        Case caseObj =  myCases[0]; 
        caseObj.Email_List__c = 'test@mail.com';
        
        ApexPages.StandardController ctrl = new ApexPages.StandardController(caseObj);   
        ApexPages.currentPage().getParameters().put('id', caseObj.Id);     
        ApexPages.currentPage().getParameters().put('type', 'supp');      
        
        SituationMgmtController situationCtrl = new SituationMgmtController(ctrl);        

        situationCtrl.caseRecord = caseObj;
        // situationCtrl.caseRecord.Situation_Contact__c = '0035000000tSg19';
        //situationCtrl.ContactProperty();       
        situationCtrl.getAlphaRecords();
        situationCtrl.charLink = 'Other';
        situationCtrl.getAlphaRecords();
        situationCtrl.charLink = 'All';
        situationCtrl.getAlphaRecords();
        situationCtrl.viewData();
        situationCtrl.doSave();
        situationCtrl.viewData();
        situationCtrl.viewCaseDetail();
        situationCtrl.createCase();
        situationCtrl.doCancel();
        situationCtrl.caseEdit();
        situationCtrl.getIsValidProfileCRUD();
        
        situationCtrl.getSortDirection();
        situationCtrl.redirectToCaseDetail();
        situationCtrl.goToComment();
        situationCtrl.caseComment = 'Test';
        situationCtrl.addComment();
        situationCtrl.first();
        situationCtrl.last();
        situationCtrl.next();
        situationCtrl.previous();
        situationCtrl.doClone();
        situationCtrl.doDelete();
        situationCtrl.redirectToCaseClone();
        situationCtrl.redirectToCaseEdit();
        situationCtrl.redirectToCaseClose();
        situationCtrl.getOptions();
        
        situationCtrl.filterBy = 'All Open Support';
        situationCtrl.filterQuery(); 
        situationCtrl.filterBy = 'All Open Services';
        situationCtrl.filterQuery(); 
        
        situationCtrl.filterBy = 'My Open Issues';
        situationCtrl.getProblemTypeVisibility(); 
        situationCtrl.filterQuery(); 
        
        
        
        
        ApexPages.currentPage().getParameters().put('type', 'serv');
        
        SituationMgmtController situationCtrl1 = new SituationMgmtController();
        situationCtrl1.caseRecord = caseObj; 
        situationCtrl1.caseEdit();
          
        
        
        ApexPages.currentPage().getParameters().put('chosenEntry',situationCtrl1.caseRecord.Id);
        situationCtrl1.filterBy = 'All Open Support';
        situationCtrl1.DeleteSelected();             
        
        situationCtrl1.accID = caseObj.Situation_Account__c;
        situationCtrl1.strField = 'test';
        situationCtrl1.fileName ='test';
        situationCtrl1.selectedStatus = 'New';
        situationCtrl1.fileSize  = 0;
        
        situationCtrl1.isEdit = true;
        situationCtrl1.myCloseCases = '';
        situationCtrl1.isOwnerQueue =true;
        situationCtrl1.isOriginTbd = true;
        
        situationCtrl1.filterby = 'All Open Feedback';
        situationCtrl1.filterQuery();
        //situationCtrl1.filterby = 'All Open Escalate Manager';
        //situationCtrl1.filterQuery();
        situationCtrl1.filterby = 'Queue (Support)';
        situationCtrl1.filterQuery();
        situationCtrl1.filterby = 'Queue (Services)';
        situationCtrl1.filterQuery();
        situationCtrl1.filterby = 'Queue (Feedback)';
        situationCtrl1.filterQuery();
        situationCtrl1.filterby = 'Queue (Escalate Manager)';
        situationCtrl1.filterQuery();
        
        situationCtrl1.hasNext = false;
        boolean tmp = situationCtrl1.hasNext;
        situationCtrl1.hasPrevious = false;
        tmp = situationCtrl1.hasPrevious;
        
        situationCtrl1.recordTo = 1;
        situationCtrl1.recordFrom = 1;
        integer abc = situationCtrl1.recordFrom;
        abc = situationCtrl1.recordTo;
        situationCtrl1.pageNumber = 1;
        abc = situationCtrl1.pageNumber;
        situationCtrl1.pageNumberTotal = 0;
        abc = situationCtrl1.pageNumberTotal ;
        situationCtrl1.getaccounts();
        situationCtrl1.getEmailToContactMap();
        situationCtrl1.getEmailToContactsMap();
        situationCtrl1.getEMsgToAddressMap();
        
        situationCtrl.sortExpression = '';
               
        
        SituationMgmtController situationCtrl2 = new SituationMgmtController();
        situationCtrl2.caseRecord = caseObj; 
        situationCtrl2.caseEdit();
        situationCtrl2.filterBy = 'All Open Support';
        
        situationCtrl2.fillRecordTypetoQueueMap();
        situationCtrl2.getProblemTypeVisibility();
        situationCtrl2.changeFlag();
        situationCtrl2.checkValidation();
        situationCtrl2.setSortDirection('ASC');
        situationCtrl2.ContactProperty();
        situationCtrl2.getEmailList();
        situationCtrl2.getReplyAllListings();
        situationCtrl2.gotoListSearch();
        situationCtrl2.getEmailAddressList('test@mail.com');
        
        situationCtrl2.chosenEntry= situationCtrl1.caseRecord.Id;
        situationCtrl2.DeleteSingleSelected();
        
        //List<User> selUser = [SELECT Id from User where  ]        
        situationCtrl2.getIsValidProfile();
        //situationCtrl2.getIsValidProfileCRUD();


        
        
        
    }
    
    public static testmethod void testSMAccountCtrl() {
        Account acc = new Account(Name = 'Test Account');
        insert acc;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(acc); 
        SituationAccountCtrl ctrl = new SituationAccountCtrl(sc);
        ctrl.getURL();
        ctrl.goToURL();
    }
    
    public static testmethod void testSMContactCtrl() {
       Account acc = new Account(Name = 'Test Acc',Type = 'Customer',RecordTypeId = '01250000000ULb7');
        insert acc;
        
        Contact con = new Contact(FirstName = 'test',LastName = 'Test Con', Email = 'test@test.com',AccountId = acc.Id);
        insert con;
        
        
        
        ApexPages.StandardController sc = new ApexPages.StandardController(con); 
        SituationContactCtrl ctrl = new SituationContactCtrl(sc);
        ctrl.getURL();
        ctrl.goToURL();
    }
    
    public static testmethod void testSMNewRedirectCtrl() {
        Case caseObj = new Case(Status = 'New', Priority = 'P1', Subject = 'Test', Description = 'Test Description');
        insert caseObj;
        
        ApexPages.currentPage().getParameters().put('id', caseObj.Id);
        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj); 
        SituationNewRedirectCtrl ctrl = new SituationNewRedirectCtrl(sc);
        ctrl.redirect();
    }
    
    public static testmethod void testSMRecordTypeSelectCtrl() {
        SituationRecordTypeSelectCtrl ctrl = new SituationRecordTypeSelectCtrl();
        ctrl.doCancel();
        ctrl.getOptions();
        ctrl.selectedRecType = 'Services';
        ctrl.doContinue();
        ctrl.selectedRecType = 'Support';
        ctrl.doContinue();
        ctrl.doCancel();
        
        ctrl.selectedRecType = 'Feedback';
        ctrl.doContinue();
        ctrl.doCancel();
        
        
        Case caseObj = new Case(Status = 'New', Priority = 'P1', Subject = 'Test', Description = 'Test Description');
        insert caseObj;        
        ApexPages.currentPage().getParameters().put('id', caseObj.Id);        
        ApexPages.StandardController sc = new ApexPages.StandardController(caseObj); 
        SituationRecordTypeSelectCtrl  ctrl1 = new SituationRecordTypeSelectCtrl();
        ctrl1.doCancel();
            
    }
    
    public static testmethod void testEmailToCase() {
        Account acc = new Account(Name = 'Test Acc',Type = 'Customer',RecordTypeId = '01250000000ULb7');
        insert acc;
        
        Contact con = new Contact(FirstName = 'test',LastName = 'Test Con', Email = 'test@test.com',AccountId = acc.Id);
        insert con;
        
        Case caseObj = new Case(Status = 'New', Priority = 'P1', Subject = 'Test', SuppliedEmail = 'test@test.com',
                                    Description = 'Test Description', Origin = 'TBD');
        insert caseObj;
    }

    
    public static testMethod void testJiveKCS() {        
        PageReference pageRef = Page.JiveKCS;
        Test.setCurrentPage(pageRef);                
        JiveKCScontroller controller = new JiveKCScontroller();
        controller.publishArticleInJive();
    }
    
    public static testMethod void CustomerCalledTest() {  
        case cse = [select id,contact.name from case where recordtype.name = 'support cases' limit 1];        
        ApexPages.StandardController sc = new ApexPages.StandardController(cse);
        PageReference pageRef = Page.CustomerCalled; 
        pageRef.getParameters().put('id',cse.Id);
        Test.setCurrentPage(pageRef);
        CustomerCalledClass cc = new CustomerCalledClass(sc);

        cc.saveComment();
    }
}