@isTest(seeAllData = true)
public class TestMarketoController {
/*
    public static testmethod void testCaseController() {
        Test.StartTest();
        
        User u2  = new User();
        try {
            u2  = [SELECT ID from User where (NOT Email Like '%@marketo.com') and isPortalEnabled = true and isActive = true and ProfileId = :[select Id from Profile where Name = 'Session Marketo Community'].Id limit 1];
        } catch (Exception ex) {
            System.debug('Exception==>'+ ex);
        }            
        if(u2 != null){        
            System.runAs(u2) {                
        
                Case caseObj = new Case(
                    Subject = 'Test',
                    Description = 'Description Test',
                    Status = 'New'
                );
                insert caseObj;
                Test.setCurrentPage(Page.Case_Detail_Page);
                ApexPages.currentPage().getParameters().put('page', 'detail');
                ApexPages.StandardController controller = new ApexPages.StandardController(caseObj ); 
                CaseController caseCtrl = new CaseController(controller);          
                caseCtrl.caseRecord = caseObj; 
                caseCtrl.filterBy = 'My Closed Cases';
                caseCtrl.search(); 
                caseCtrl.filterBy = 'All Company Open Cases';
                caseCtrl.search(); 
                caseCtrl.filterBy = 'All Company Closed Cases';
                caseCtrl.search(); 
            }
        }
        Test.StopTest();
    }
/*    
    public static testmethod void testCaseController2() {
        Test.StartTest();
        
        User u2  = new User();
        try {
            u2  = [SELECT ID from User where (NOT Email Like '%@marketo.com') and isPortalEnabled = true and isActive = true and ProfileId = :[select Id from Profile where Name = 'Session Marketo Community'].Id  limit 1];
        } catch (Exception ex) {
            System.debug('Exception==>'+ ex);
        }            
        if(u2 != null){        
            System.runAs(u2) {                  
                Case caseObj = new Case(
                    Subject = 'Test2',
                    Description = 'Description Test2',
                    Status = 'New'
                );
                insert caseObj;
                Test.setCurrentPage(Page.Case_Detail_Page);
                ApexPages.currentPage().getParameters().put('page', 'detail');
                ApexPages.StandardController controller = new ApexPages.StandardController(caseObj ); 
                CaseController caseCtrl = new CaseController(controller);          
                caseCtrl.caseRecord = caseObj;
                
                caseCtrl.getAlphaRecords();
                caseCtrl.charLink = 'Other';
                caseCtrl.getAlphaRecords();
                caseCtrl.charLink = 'All';
                caseCtrl.getAlphaRecords();
                caseCtrl.viewData();
                caseCtrl.doSave();
                caseCtrl.viewData();
                caseCtrl.viewCaseDetail();
                caseCtrl.createCase();
                caseCtrl.doCancel();
                caseCtrl.editRedirect();
                caseCtrl.caseEdit();
                
                /*
                caseCtrl.acceptSuggestion();
                caseCtrl.rejectSuggestion();
                caseCtrl.getSortDirection();
                caseCtrl.redirectToCaseDetail();
                caseCtrl.goToAttach();
                caseCtrl.goToComment();
                caseCtrl.attachmentObj.Body = Blob.valueOf('Test');
                caseCtrl.attachmentObj.Name = 'Test';
                caseCtrl.attachFile();
                caseCtrl.caseComment = 'Test';
                caseCtrl.addComment();
                caseCtrl.first();
                caseCtrl.last();
                caseCtrl.next();
                caseCtrl.previous();
                CaseController ctrl = new CaseController();
                ctrl.doRedirectUser();
                ctrl.doSaveEmail();
                ctrl.doCancelEmail();
                caseCtrl.checkSaveFirst();
                caseCtrl.doSaveP2();
                *//*
            }
        }
        Test.StopTest();        
    }    
/*    
    public static testmethod void testCaseController3() {
        Test.StartTest();
        
        User u2  = new User();
        try {
            u2  = [SELECT ID from User where (NOT Email Like '%@marketo.com') and isPortalEnabled = true and isActive = true and ProfileId = :[select Id from Profile where Name = 'Session Marketo Community'].Id limit 1];
        } catch (Exception ex) {
            System.debug('Exception==>'+ ex);
        }            
        if(u2 != null){        
            System.runAs(u2) {                  
                Case caseObj = new Case(
                    Subject = 'Test3',
                    Description = 'Description Test3',
                    Status = 'New'
                );
                insert caseObj;
                Test.setCurrentPage(Page.Case_Detail_Page);
                ApexPages.currentPage().getParameters().put('page', 'detail');
                ApexPages.StandardController controller = new ApexPages.StandardController(caseObj ); 
                CaseController caseCtrl = new CaseController(controller);      
                //caseCtrl.acceptSuggestion();
                //caseCtrl.rejectSuggestion();
                caseCtrl.getSortDirection();
                caseCtrl.redirectToCaseDetail();
                caseCtrl.goToAttach();
                caseCtrl.goToComment();
                /*    
                CaseController ctrl = new CaseController();
                ctrl.doRedirectUser();
                ctrl.doCancelEmail();
                ctrl.doSaveEmail();
                caseCtrl.checkSaveFirst();
                caseCtrl.doSaveP2();*//*
            }
        }
        Test.StopTest();        
    }    
    
  */  
 /*   
    public static testmethod void testCaseController3_1() {
        Test.StartTest();        
        User u2  = new User();
        try {
            u2  = [SELECT ID from User where (NOT Email Like '%@marketo.com') and isPortalEnabled = true and isActive = true and ProfileId = :[select Id from Profile where Name = 'Session Marketo Community'].Id limit 1];
        } catch (Exception ex) {
            System.debug('Exception==>'+ ex);
        }            
        if(u2 != null){        
            System.runAs(u2) {                  
                Case caseObj = new Case(
                    Subject = 'Test3',
                    Description = 'Description Test3',
                    Status = 'New'
                );
                insert caseObj;
                
               pageReference pg = Page.Case_Detail_Page;
                ApexPages.StandardController tempVar = new ApexPages.StandardController(caseObj);
                ApexPages.currentPage().getParameters().put('id', caseObj.Id);
                //ApexPages.currentPage().getParameters().put('searchText', tempCase.Subject);
                Test.setCurrentPage(pg);
                CaseController testArticleSearchController = new CaseController(tempVar);
                
                CaseController ctrl = new CaseController();
                ctrl.doRedirectUser();
                ctrl.doCancelEmail();
                ctrl.doSaveEmail();
                Ctrl.checkSaveFirst();
                Ctrl.caseonBehalf = 'Customer';
                
                Ctrl.doSaveP2();
            }
        }
        Test.StopTest();        
    }    
 */   
 /*   
    public static testmethod void testCaseController4() {
        Test.StartTest();
        
        User u2  = new User();
        try {
            u2  = [SELECT ID from User where (NOT Email Like '%@marketo.com') and isPortalEnabled = true and isActive = true and ProfileId = :[select Id from Profile where Name = 'Session Marketo Community'].Id limit 1];
        } catch (Exception ex) {
            System.debug('Exception==>'+ ex);
        }            
        if(u2 != null){        
            System.runAs(u2) {                  
                Case caseObj = new Case(
                    Subject = 'Test4',
                    Description = 'Description Test4',
                    Status = 'New'
                );
                insert caseObj;
                Test.setCurrentPage(Page.Case_Detail_Page);
                ApexPages.currentPage().getParameters().put('page', 'detail');
                ApexPages.StandardController controller = new ApexPages.StandardController(caseObj ); 
                CaseController caseCtrl = new CaseController(controller);      
               
                caseCtrl.caseRecord = caseObj;                               
                caseCtrl.attachmentObj.Body = Blob.valueOf('Test');
                caseCtrl.attachmentObj.Name = 'Test';
                caseCtrl.attachFile();
                caseCtrl.caseComment = 'Test';
                caseCtrl.addComment();
                caseCtrl.first();
                caseCtrl.last();
                caseCtrl.next();
                caseCtrl.previous();
                
            }
        }
        Test.StopTest();        
    }    
  */  
    public static testmethod void testCaseController5() {
        Test.StartTest();
        
        Account acc = new Account(Name = 'Test', Type='Customer',RecordTypeId = '01250000000ULb7');
        insert acc;
        
        Contact con = new Contact(LastName = 'Test', AccountId = acc.id, Email = 'test@test.com', Customer_Portal_User__c = true);
        insert con;
        
        Case caseObj = new Case(
                    Subject = 'Test3',
                    Description = 'Description Test3',
                    Status = 'New'
                );
        
        ApexPages.StandardController testObject = new ApexPages.StandardController(caseObj);
        CustomAccLookupPopupController CustomAccLookupPopupControllerObj = new CustomAccLookupPopupController(testObject);
        CustomAccLookupPopupControllerObj.selAccount = acc;
        CustomAccLookupPopupControllerObj.query = 'test';
        CustomAccLookupPopupControllerObj.runQuery();
        CustomAccLookupPopupControllerObj.Beginning();
        CustomAccLookupPopupControllerObj.Previous();
        CustomAccLookupPopupControllerObj.Next();
        CustomAccLookupPopupControllerObj.End() ;
        CustomAccLookupPopupControllerObj.getDisablePrevious();
        CustomAccLookupPopupControllerObj.getDisableNext();
        CustomAccLookupPopupControllerObj.getTotal_size();
        CustomAccLookupPopupControllerObj.getPageNumber();
        CustomAccLookupPopupControllerObj.getTotalPages();

        Test.StopTest();       
    } 
    
    public static testmethod void testCaseController6() {
        Test.StartTest();
        
        Account acc = new Account(Name = 'Test', Type='Customer',RecordTypeId = '01250000000ULb7');
        insert acc;
        
        Contact con = new Contact(LastName = 'Test', AccountId = acc.id, Email = 'test@test.com', Customer_Portal_User__c = true);
        insert con;
        
        Case caseObj = new Case(
                    Subject = 'Test3',
                    Description = 'Description Test3',
                    Status = 'New'
                );
        
        ApexPages.StandardController testObject = new ApexPages.StandardController(caseObj);
        CustomContactLookupPopupController CustomContactLookupPopupControllerObj = new CustomContactLookupPopupController(testObject);
        CustomContactLookupPopupControllerObj.selAccount = acc;
        CustomContactLookupPopupControllerObj.selAccount = acc;
        
        CustomContactLookupPopupControllerObj.query = 'test';
        CustomContactLookupPopupControllerObj.runQuery();
        CustomContactLookupPopupControllerObj.Beginning();
        CustomContactLookupPopupControllerObj.Previous();
        CustomContactLookupPopupControllerObj.Next();
        CustomContactLookupPopupControllerObj.End() ;
        CustomContactLookupPopupControllerObj.getDisablePrevious();
        CustomContactLookupPopupControllerObj.getDisableNext();
        CustomContactLookupPopupControllerObj.getTotal_size();
        CustomContactLookupPopupControllerObj.getPageNumber();
        CustomContactLookupPopupControllerObj.getTotalPages();

        Test.StopTest();       
    }     
    
    
    
    
    
    public static testmethod void testAcceptRejectCtrl() {
        Case caseObj = new Case(
            Subject = 'Test',
            Description = 'Description Test',
            Status = 'New'
        );
        insert caseObj;
        
        ApexPages.StandardController controller = new ApexPages.StandardController(caseObj ); 
        AcceptRejectSuggestionCtrl caseCtrl = new AcceptRejectSuggestionCtrl(controller); 
        ApexPages.currentPage().getParameters().put('suggestion', 'accept');         
        caseCtrl.updateCaseStatus(); 
        ApexPages.currentPage().getParameters().put('suggestion', 'reject');         
        caseCtrl.updateCaseStatus(); 
        ApexPages.currentPage().getParameters().put('suggestion', 'sendemail');         
        caseCtrl.updateCaseStatus(); 
    }
    
    public static testmethod void testCaseCloseCtrl() {
        Case caseObj = new Case(
            Subject = 'Test',
            Description = 'Description Test',
            Status = 'New'
        );
        insert caseObj;
        
        List<Case> caseList = new List<Case>();
        caseList.add(caseObj);
        
        ApexPages.StandardSetController controller = new ApexPages.StandardSetController(caseList); 
        CaseCloseController caseCtrl = new CaseCloseController(controller); 
                
        caseCtrl.closeCase(); 
        caseCtrl.doCancel(); 
    }
    
/*
    public static testmethod void testWelcomeCtrl() {
        WelcomeController caseCtrl = new WelcomeController(); 
                
        //caseCtrl.getLanguageMap(); 
        caseCtrl.manageAuthorizedContacts(); 
    }
*/    
    public static testmethod void testAutoCloseMilestone() {
        Account acc = new Account(Name = 'Test');
        insert acc;
        
        Contact con = new Contact(LastName = 'Test', AccountId = acc.id, Email = 'test@test.com', Customer_Portal_User__c = true);
        insert con;
            
        Profile p = [SELECT Id FROM Profile WHERE Name Like '%Portal%' limit 1]; 
        /*
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', ContactId = con.id,
                                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
                                LocaleSidKey='en_US', ProfileId = p.Id, Munchkin_ID__c = '1010101',
                                TimeZoneSidKey='America/Los_Angeles', UserName='testuser@testorg.com');
        
       */
       // System.runAs(u) {
            
            
            Asset ast = new Asset(Name = 'Test', AccountId = acc.id, Munchkin_ID__c = '1010101',Pod__c ='POD');
            insert ast;
            /* // Commented as this class is throwing exception when deploying
            Entitlement entl = new Entitlement(Name = 'Test', AssetId = ast.id, AccountId = acc.id);
            insert entl;
            
            Authorized_Contact__c ac = new Authorized_Contact__c(Contact__c = con.id, Entitlement__c = entl.id);
            insert ac;
            */
            Case caseObj = new Case(
                Subject = 'Test',
                Description = 'Description Test',
                Status = 'New',
                SuppliedEmail = 'test@test.com'
            );
            insert caseObj;
            
            caseObj.Status = 'Closed';
            update caseObj;
        //}        
    }
    
}