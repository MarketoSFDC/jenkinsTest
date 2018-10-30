@isTest(SeeAllData = true)
private class testJiraCaseController {

    static testMethod void Fetch_Issue()  {
        
        Case caseObj = new Case(Subject = 'Test Sub', Description = 'Test Description');//, Status = 'New');         
        insert caseObj;
        Test.setCurrentPage(Page.JIRAFetchIssues);
        ApexPages.currentPage().getParameters().put('id', caseObj.Id);
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(caseObj ); 
        JIRAFetchIssuesController testCntrl = new JIRAFetchIssuesController(stdcontroller);     
        testCntrl.getIssuesJson();
        testCntrl.getIssues();
                 

        Test.setCurrentPage(Page.JiraCaseDetailPage);
        ApexPages.currentPage().getParameters().put('id', caseObj.Id);
        ApexPages.StandardController stdcontroller2 = new ApexPages.StandardController(caseObj ); 
        JiraCaseDetailPage testCntrl2 = new JiraCaseDetailPage(stdcontroller2);
        testCntrl2.checkPwd();

    }
    

}