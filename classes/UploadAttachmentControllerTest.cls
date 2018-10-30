/**
* (c) 2018 Appirio, Inc
* 
* 
* Description : An apex test class for UploadAttachmentController.
* Created By : Sumit Dayama
* Created Date :March 27th 2018
* CHANGE LOG
 * DEVELOPER NAME             CHANGE DESCRIPTION                      MODIFY DATE
 * ------------------------------------------------------------------------------
 * Appirio               Created class                           2018/03/27
 * Appirio               Updated class                           2018/03/30
* --------------------------------------------------------------------------------------
**/
@isTest 
public class UploadAttachmentControllerTest {
    public static testMethod void uploadAttachmentTest() {
        lmsilt__Development_Plan_Task__c devPlan;
        Accreditation_Approval__c  accApp;
        User testUser = TestDataUtility.createUser(null, true);
        //Run with respect to test User
        System.runAs(testUser) {
            //Insert Dev Plan Task
            devPlan = TestDataUtility.createDevPlanTask(true);
            accApp = TestDataUtility.createAccApp(false);
            accApp.Development_Plan_Task__c = devPlan.Id;
            //Insert Accreditation Approval
            Insert accApp;
            PageReference pref = Page.Custom_Attachment;
            pref.getParameters().put('developmentTaskId', devPlan.id);
            Test.setCurrentPage(pref);
            ApexPages.StandardController stdCon = new ApexPages.StandardController(devPlan);
            UploadAttachmentController uac= New UploadAttachmentController(stdCon);
            uac.UploadAttachmentControllerAction();
            uac.getDevPlanTask(devPlan.id);
            uac.fileName='Unit Test Attachment'; 
            uac.fileBody=Blob.valueOf('Unit Test Attachment Body');
            uac.updateAcreObj();
        }
        
    }
    //Redirect to success page
     public static testMethod void uploadSuccesTest() {
         PageReference pref = Page.UploadSucces;
         UploadSuccesController usc = new UploadSuccesController();
         usc.redirectToPage(); 
     }
}