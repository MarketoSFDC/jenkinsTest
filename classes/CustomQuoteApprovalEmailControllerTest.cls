@isTest
private class CustomQuoteApprovalEmailControllerTest {
                              
    /**
     * Class Constructor
     */
    private CustomQuoteApprovalEmailControllerTest() {
    }
    
    /**
     * Tests the controller
     */
    static testmethod void test1() {
        
        CustomQuoteApprovalEmailControllerTest testController = new CustomQuoteApprovalEmailControllerTest();
        
        // test the approval email 
        testController.testApprovalEmail1();
        
    }
    
    /**
     * Test the approval email 
     */
    private void testApprovalEmail1() {
        
      Account acc=new Account(Name='test Account1',ownerid=UserInfo.getUserId());
      acc.BillingCountry = 'United States';
        acc.BillingStreet = 'Test Street';
        acc.BillingState ='Test Billing State';
        acc.BillingPostalCode ='12345';
        acc.ShippingCity ='Pune';
        acc.ShippingCountry ='India';
        acc.ShippingPostalCode = '12345';
        acc.ShippingState = 'Maharashtra';
        acc.ShippingStreet = 'Test Shipping Street';  
        acc.Accounting_Email__c = 'test@gmail.com';
        acc.Accounting_Contact_First_Name__c = 'FirstName';
        acc.Accounting_Contact_Last_Name__c = 'LastName';
        acc.Website = 'www.google.com';
      insert acc;
      Opportunity opp=new Opportunity(Name='test Opportunity1',AccountId=acc.id,type='New Business',
           CloseDate=date.today(),Rep_Create_ARR__c = 10,MainCompetitor__c = 'Act-On',StageName='Negotiation',ownerid=UserInfo.getUserId());
      insert opp;
        
        // STEP I - Create a new Quote
        Quote QuoteSO = new Quote(Name = 'Test Quote', 
                               Maximum_Database_Size__c = 100000,
                               OpportunityId = opp.id);
        
        insert QuoteSO;
 Test.startTest();
        CustomQuoteApprovalEmailController cs = new CustomQuoteApprovalEmailController();
        // STEP II - Create a new process
        /*Apttus_Approval__Approval_Process__c processSO = Apttus_Approval.TestSupport.createApprovalProcess('TEST-' + Datetime.now().format(), 
                                                                                                           1,
                                                                                                           'Quote',
                                                                                                           null,
                                                                                                           null,
                                                                                                           null,
                                                                                                           null, 
                                                                                                           null, 
                                                                                                           true);
                                                              
        // STEP III - Create approval users
        User userSO = null;
        User userSO2 = null;
        
        System.runAs(new User(Id = System.UserInfo.getUserId())) {
            userSO = Apttus_Approval.TestSupport.createUser('assignee1@approvals.xyz.com', 
                                                            'ast1', 
                                                            'assignee1',
                                                            'tester',
                                                            'assignee1@approvals.xyz.com',
                                                            ID.valueOf(UserInfo.getProfileId()));
                                         
            // fetch the assignee 
            userSO = Apttus_Approval.TestSupport.getUserSO(userSO.Id);
            
            userSO2 = Apttus_Approval.TestSupport.createUser('assignee2@approvals.xyz.com', 
                                                             'ast2', 
                                                             'assignee2',
                                                             'tester',
                                                             'assignee2@approvals.xyz.com',
                                                             ID.valueOf(UserInfo.getProfileId()));
                                                                                                              
            // fetch the assignee 
            userSO2 = Apttus_Approval.TestSupport.getUserSO(userSO2.Id);
        
        }
                                                                                                                                                                                                                                               
        // STEP IV - Create a new approval request
        Apttus_Approval__Approval_Request__c requestSO = Apttus_Approval.TestSupport.createAssignmentRequest(userSO, 
                                                                                                             processSO.Id, 
                                                                                                             QuoteSO.Id, 
                                                                                                             'Quote-3456');
        
        Apttus_Approval__Approval_Request__c requestSO2 = Apttus_Approval.TestSupport.createAssignmentRequest(userSO2, 
                                                                                                              processSO.Id, 
                                                                                                              QuoteSO.Id, 
                                                                                                              'Quote-3457');
        
        // STEP V - Create the controller
        // Create the email component controller
        CustomQuoteApprovalEmailController controller = new CustomQuoteApprovalEmailController();
        
        // STEP VI - Test methods
        
        // start the test
        Test.startTest();
        
        // get the context
        Apttus_Approval.ContextApprovalEmailController context = controller.getContext();
        
        context.setRequestSO(requestSO);
        context.setRecipientSO(userSO);
        
        // request and recipient paraneters
        System.assertNotEquals(context.getRequestSO(), null);
        System.assertNotEquals(context.getRecipientSO(), null);
        
        // status
        System.assert(context.getAreActionsSupported());
        System.assert(!context.getIsStatusCancelled());
        
        // Quote sobject
        System.assertNotEquals(controller.getQuoteSO(), null);
        
        // email response
        System.debug('EmailApprovalResponseEnabled=' + context.getIsEmailApprovalResponseEnabled());
        
        // email links
        System.debug('ReassignPageUrl=' + context.getReassignPageUrl());
        System.debug('ApproveRejectPageUrl=' + context.getApproveRejectPageUrl());
        System.debug('AddCommentPageUrl=' + context.getAddCommentPageUrl());
        System.debug('ContextPageUrl=' + context.getContextPageUrl());
        System.debug('ContextLinkInstruction=' + context.getContextLinkInstruction());
        
        // approval history
        System.assert(!context.getApprovalHistory().isEmpty());
        
        // end the test */
        Test.stopTest();
        
    }
    
    
}