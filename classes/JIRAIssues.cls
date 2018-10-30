public class JIRAIssues{

    public Boolean showJiraSection{get;set;}
    
    public JIRAIssues(ApexPages.StandardController stdController) {
            showJiraSection = False;
    }
    
    public JIRAIssues() {
        showJiraSection = False;
    }
    
    public void showHideJiraSection() {
        showJiraSection = !showJiraSection;
    }
    
    @isTest
    public static void testMethod1()
    {
        JIRAIssues testCntrl1 = new JIRAIssues(); 
        Case caseObj = new Case(Subject = 'Article', Description = 'Test Article Description');//, Status = 'New');         
        insert caseObj;
        Test.setCurrentPage(Page.JIRAIssues);
        ApexPages.currentPage().getParameters().put('id', caseObj.Id);
        ApexPages.StandardController stdcontroller = new ApexPages.StandardController(caseObj ); 
        JIRAIssues testCntrl = new JIRAIssues(stdcontroller);     
        testCntrl.showHideJiraSection();
    }
 
 
}