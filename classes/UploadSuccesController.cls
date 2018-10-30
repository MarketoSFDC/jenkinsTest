/**
* (c) 2018 Appirio, Inc
* 
* 
* Description : An apex class used as Contoller class for Updateuccess Page.
* Purpose : The class will check will redirect User to Success Page after file upload.
* Created By : Sumit Dayama
* Created Date : April 10th 2018
* CHANGE LOG
 * DEVELOPER NAME             CHANGE DESCRIPTION                      MODIFY DATE
 * ------------------------------------------------------------------------------
 * Appirio               Created class                           2018/02/21
 * Appirio               Updated class                           2018/03/30
* --------------------------------------------------------------------------------------
**/
public with sharing class UploadSuccesController{

    public String redirectToPage { get; set; }
    //redirect User to My Training Page
    public PageReference redirectToPage(){
        PageReference page;
        page = new PageReference('/apex/lmsilt__EUI_LearningLanding');
        page.setRedirect(true);
        return page;
    }
}