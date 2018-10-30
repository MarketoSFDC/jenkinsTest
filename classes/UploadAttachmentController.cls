/**
* (c) 2018 Appirio, Inc
* 
* Description : An Apex Controller class for Custom Attachment Page.
* Purpose : The Page will create ac record of Accreditation Approval record and File will be stored in Standard Attachment reocrd.
* Created By : Sumit Dayama
* Created Date : Mar 7th 2018
* CHANGE LOG
 * DEVELOPER NAME             CHANGE DESCRIPTION                      MODIFY DATE
 * ------------------------------------------------------------------------------
 * Appirio               Created class                           2018/03/07
 * Appirio               Updated class                           2018/03/30
 * Cassandrea Steiner	 Added "acreObj.Status__c = 'Awaiting Approval';" to updateAcreObj method. Also 
 * updated "acreObj.Approver__c =usr.Id;" from the Owner of the devplantask to the current user.
 * Also added logic to populate the name of the Accreditation object. 2018/04/19             
* --------------------------------------------------------------------------------------
**/

public class UploadAttachmentController {
    
    public String devPlanTaskId {get;set;}
    private lmsilt__Development_Plan_Task__c DPT{get;set;} 
    public String fileName {get;set;}
    public String fileTitle {get;set;}
    public Transient Blob fileBody {get;set;}
    public lmsilt__Development_Plan_Task__c devPlanList {get;set;}
    Public User usr;
    public Accreditation_Approval__c  acreObj{get;set;}
    // creates a new Accreditation_Approval__c record
    public void UploadAttachmentControllerAction(){
        if (!String.IsBlank(ApexPages.currentPage().getParameters().get('developmentTaskId'))) {
            devPlanTaskId = ApexPages.currentPage().getParameters().get('developmentTaskId');  
            getDevPlanTask(devPlanTaskId);
            acreObj= new Accreditation_Approval__c(); 
            acreObj.Development_Plan_Task__c = devPlanTaskId;
            //Updates the name of the object with the Dev Plan Task Name + User's Name
            String devPlanTaskName = devPlanList.Name;
        	String usrName = usr.Name;
        	acreObj.Name = devPlanTaskName.abbreviate(40) + ' - ' + usrName.abbreviate(30); 
            //Updates the approver field with the Task Manager on the Dev Plan Task
            If(devPlanList.lmsilt__Task_Manager__c != null) {
                If(devPlanList.lmsilt__Task_Manager__c == 'Manager'){
                    acreObj.Approver__c = usr.ManagerId;
                }
                else if(devPlanList.lmsilt__Task_Manager__c== 'USER'){
                    acreObj.Approver__c =devPlanList.lmsilt__User__c;
                }
                else{
                    acreObj.Approver__c =usr.Id;
                }
            }
            else {
                acreObj.Approver__c = null;
            }
            // fill out cust obj fields
             Database.insert(acreObj);
        } else {
            ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Error: Missing Development Plan Task Id'));
        }
    }
    public UploadAttachmentController(ApexPages.StandardController controller) { 
    }   
    // Getting Task Manager
    public void getDevPlanTask(String DevID) {
        devPlanList = [SELECT Id, Name, ownerID, lmsilt__User__c, lmsilt__Task_Manager__c, lmsilt__Description__c FROM lmsilt__Development_Plan_Task__c WHERE Id =: DevID];
        usr = [SELECT Name, ManagerId FROM User where ID =: UserInfo.getUserId()];
    }
    // Redirecting User to Success Page
    public PageReference updateAcreObj(){
        acreObj.File_Title__c = fileTitle;
        acreObj.Status__c = 'Awaiting Approval';
        update acreObj;
        PageReference p = Page.UploadSucces;
        p.setRedirect(true);
        return p;
    }
}