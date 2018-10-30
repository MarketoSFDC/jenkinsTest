@isTest
public class CaseMassActionControllerTest
{
    public static testmethod void testCaseController()
    {
        case cs = new case();
        cs.Priority = 'p1';
        cs.Status = 'New';
        cs.Sales_Ops_Category__c = 'Report';
        insert cs;
        
        ApexPages.StandardController con = new ApexPages.StandardController(cs); 
        string value = cs.Id+','+cs.Id;       
        PageReference pageRef = Page.CaseMassActions;
        pageRef.getParameters().put('CaseMassTask','CASE_CHANGE_SALES_CATEGORY');
        pageRef.getParameters().put('key', value);
        pageRef.getParameters().put('retUrl',String.valueOf(cs.Id));
        Test.setCurrentPage(pageRef);
        CaseMassActionController cse = new CaseMassActionController(con);
       
        cse.getsalesCategoryOptions();
        cse.getPriorityOptions();
        cse.getStatusOptions();
        cse.save();
        cse.cancel();

  }
}