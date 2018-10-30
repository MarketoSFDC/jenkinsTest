/* Name: Case_Assign_to_Myself
     Description : Controller for Case_Assign_to_Myself
     Author : LK
     History:
     VERSION     AUTHOR               DATE                            DETAIL                                    UserStory/Req#
     1.0 -             
       */
public class Case_Assign_to_Myself {

 public Case_Assign_to_Myself()
 {
     
 }
 public PageReference assignCaseToRunningUser()
 {
     try{
     string caseId = apexpages.currentpage().getparameters().get('caseId');
     system.debug('====caseId==='+caseId);
     if(caseId != null){
         
         Case caseObj = new Case(Id = caseId, Status= 'New',OwnerId  = UserInfo.getUserId());
         update caseObj;
         //return new PageReference('/00b/e?Id='+caseId);ApexPages.currentPage().getHeaders().get('Host')
        
         return new PageReference('/'+caseId);
     
     }
     }
     Catch(Exception ex)
     {
         system.debug('=ex===');
     }
     
     return null;
     
 }
 
}