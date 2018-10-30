/*
 * Purpose : This Test class test the ResendApprovalEmailController class.
 * Author  : Prabhat Rai
 * Date    : 01/28/2015 
 */

@isTest(SeeAllData=true)
private class ResendApprovalEmailControllerTestClass{
    //Test for the Assigned type of User
    static testmethod void TestSendQueuedEmailsForUser() { 
ResendApprovalEmailController rs = new ResendApprovalEmailController();	
        //Query to extract User assign type of Approval
        /*List<Apttus_Approval__Approval_Request__c>  UserApprovalRequests=  [Select Apttus_Approval__Assigned_To_Type__c,Apttus_Approval__Assigned_To_Id__c from Apttus_Approval__Approval_Request__c  where Apttus_Approval__Assigned_To_Type__c='User'
                                                                            and (Apttus_Approval__Approval_Status__c = 'Assigned' or Apttus_Approval__Approval_Status__c = 'Reassigned') 
                                                                            Limit 1];
      
        ResendApprovalEmailController objResendApprovalEmailController = new ResendApprovalEmailController();
        PageReference pg = Page.ResendApprovalEmailPage;
        Test.setCurrentPage(pg);
        if(UserApprovalRequests != null && UserApprovalRequests.size() > 0)
        {
            pg.getParameters().put('id', UserApprovalRequests[0].Id);
            Test.startTest();
            objResendApprovalEmailController.SendQueuedEmails();
            Test.stopTest();
        }       
    }
    
    //Test for the Assigned type of Queue
    static testmethod void TestSendQueuedEmailsForQueue() {   
        //Query to extract Queue assign type of Approval
        List<Apttus_Approval__Approval_Request__c>  QueuedApprovalRequests=  [Select Apttus_Approval__Assigned_To_Type__c,Apttus_Approval__Assigned_To_Id__c from Apttus_Approval__Approval_Request__c  where Apttus_Approval__Assigned_To_Type__c='Queue'
                                                                              and (Apttus_Approval__Approval_Status__c = 'Assigned' or Apttus_Approval__Approval_Status__c = 'Reassigned')
                                                                              Limit 1];

        ResendApprovalEmailController objResendApprovalEmailController = new ResendApprovalEmailController();
        PageReference pg = Page.ResendApprovalEmailPage;
        Test.setCurrentPage(pg);
        

        if(QueuedApprovalRequests != null && QueuedApprovalRequests.size() > 0)
        {
            pg.getParameters().put('id', QueuedApprovalRequests[0].Id);
            
            Test.startTest();
            objResendApprovalEmailController.SendQueuedEmails();
            Test.stopTest();
        }     */ 
    }
}