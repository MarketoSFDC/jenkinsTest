/* Name: Case_Need_More_Info_Controller
     Description : Controller for Case_Need_More_Info
     Author : LK
     History:
     VERSION     AUTHOR               DATE                            DETAIL                                    UserStory/Req#
     1.0 -             
       */
public class Case_Need_More_Info_Controller {
    
    public Case_Need_More_Info_Controller()
    {
       
    }
    
    public PageReference updateCaseStatus()
    {
        String  caseId =System.currentPageReference().getParameters().get('Id');
        system.debug('=caseId==='+caseId);
        if(caseId != null)
        {
            Case caseObj = new Case(Status = 'Awaiting Customer Input',Id = caseId);
            update caseObj;
            return new PageReference('/'+caseId);
            //return new PageReference('/00a/e?parent_id='+caseId+'&retURL='+caseId);
        }
        else
        {
            return null;
        }
    }

}