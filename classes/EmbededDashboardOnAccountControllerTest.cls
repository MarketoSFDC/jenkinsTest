@isTest(SeeAllData = true)
public class EmbededDashboardOnAccountControllerTest{
    
    static testMethod void TestEmbededDashboardOnAccountController() {
        Account ac = Utility.insertAccountInTestClasses();
        insert ac;
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ac);
        EmbededDashboardOnAccountController testAccPlan = new EmbededDashboardOnAccountController(sc);
        
        PageReference pageRef = Page.EmbedDashboardOnAccount;
        pageRef.getParameters().put('id', String.valueOf(ac.Id));
        Test.setCurrentPage(pageRef);
        
        List<SelectOption> selList = testAccPlan.getDateFilters();
    }
    
    static testMethod void TestEmbededDashboardOnAccountController2() {
        Account ac = Utility.insertAccountInTestClasses();
        insert ac;
        ApexPages.CurrentPage().getParameters().put('renderAsPdf', 'true');
        ApexPages.CurrentPage().getParameters().put('summarizeAs', 'Prev Month');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ac);
        EmbededDashboardOnAccountController testAccPlan = new EmbededDashboardOnAccountController(sc);
        
        PageReference pageRef = Page.EmbedDashboardOnAccount;
        pageRef.getParameters().put('id', String.valueOf(ac.Id));
        Test.setCurrentPage(pageRef);
        testAccPlan.renderAsPDF();
        testAccPlan.changeFilterCriteria();
    } 

    static testMethod void TestEmbededDashboardOnAccountController3() {
        Account ac = Utility.insertAccountInTestClasses();
        insert ac;
        ApexPages.CurrentPage().getParameters().put('renderAsPdf', 'true');
        ApexPages.CurrentPage().getParameters().put('summarizeAs', 'Prev Quarter');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ac);
        EmbededDashboardOnAccountController testAccPlan = new EmbededDashboardOnAccountController(sc);
        
        PageReference pageRef = Page.EmbedDashboardOnAccount;
        pageRef.getParameters().put('id', String.valueOf(ac.Id));
        Test.setCurrentPage(pageRef);
        testAccPlan.renderAsPDF();
        testAccPlan.changeFilterCriteria();
    }     
    
    static testMethod void TestEmbededDashboardOnAccountController4() {
        Account ac = Utility.insertAccountInTestClasses();
        insert ac;
        ApexPages.CurrentPage().getParameters().put('renderAsPdf', 'true');
        ApexPages.CurrentPage().getParameters().put('summarizeAs', 'Prev Year');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ac);
        EmbededDashboardOnAccountController testAccPlan = new EmbededDashboardOnAccountController(sc);
        
        PageReference pageRef = Page.EmbedDashboardOnAccount;
        pageRef.getParameters().put('id', String.valueOf(ac.Id));
        Test.setCurrentPage(pageRef);
        testAccPlan.renderAsPDF();
        testAccPlan.changeFilterCriteria();
    }     
    
    static testMethod void TestEmbededDashboardOnAccountController5() {
        Account ac = Utility.insertAccountInTestClasses();
        insert ac;
        ApexPages.CurrentPage().getParameters().put('renderAsPdf', 'true');
        ApexPages.CurrentPage().getParameters().put('summarizeAs', 'Prev Bi-Annual');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ac);
        EmbededDashboardOnAccountController testAccPlan = new EmbededDashboardOnAccountController(sc);
        
        PageReference pageRef = Page.EmbedDashboardOnAccount;
        pageRef.getParameters().put('id', String.valueOf(ac.Id));
        Test.setCurrentPage(pageRef);
    }  
    
    static testMethod void TestEmbededDashboardOnAccountController10() {
        Account ac = Utility.insertAccountInTestClasses();
        insert ac;
        ApexPages.CurrentPage().getParameters().put('renderAsPdf', 'true');
        ApexPages.CurrentPage().getParameters().put('summarizeAs', 'Curr Month');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ac);
        EmbededDashboardOnAccountController testAccPlan = new EmbededDashboardOnAccountController(sc);
        
        PageReference pageRef = Page.EmbedDashboardOnAccount;
        pageRef.getParameters().put('id', String.valueOf(ac.Id));
        Test.setCurrentPage(pageRef);
    }
    
    static testMethod void TestEmbededDashboardOnAccountController6() {
        Account ac = Utility.insertAccountInTestClasses();
        insert ac;
        ApexPages.CurrentPage().getParameters().put('renderAsPdf', 'true');
        ApexPages.CurrentPage().getParameters().put('summarizeAs', 'Curr Quarter');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ac);
        EmbededDashboardOnAccountController testAccPlan = new EmbededDashboardOnAccountController(sc);
        
        PageReference pageRef = Page.EmbedDashboardOnAccount;
        pageRef.getParameters().put('id', String.valueOf(ac.Id));
        Test.setCurrentPage(pageRef);
    }  
    
    static testMethod void TestEmbededDashboardOnAccountController7() {
        Account ac = Utility.insertAccountInTestClasses();
        insert ac;
        ApexPages.CurrentPage().getParameters().put('renderAsPdf', 'true');
        ApexPages.CurrentPage().getParameters().put('summarizeAs', 'Curr Year');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ac);
        EmbededDashboardOnAccountController testAccPlan = new EmbededDashboardOnAccountController(sc);
        
        PageReference pageRef = Page.EmbedDashboardOnAccount;
        pageRef.getParameters().put('id', String.valueOf(ac.Id));
        Test.setCurrentPage(pageRef);
    }  
    static testMethod void TestEmbededDashboardOnAccountController8() {
        Account ac = Utility.insertAccountInTestClasses();
        insert ac;
        ApexPages.CurrentPage().getParameters().put('renderAsPdf', 'true');
        ApexPages.CurrentPage().getParameters().put('summarizeAs', 'Curr Bi-Annual');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ac);
        EmbededDashboardOnAccountController testAccPlan = new EmbededDashboardOnAccountController(sc);
        
        PageReference pageRef = Page.EmbedDashboardOnAccount;
        pageRef.getParameters().put('id', String.valueOf(ac.Id));
        Test.setCurrentPage(pageRef);
    }       
    static testMethod void TestEmbededDashboardOnAccountController9() {
        Account ac = Utility.insertAccountInTestClasses();
        insert ac;
        ApexPages.CurrentPage().getParameters().put('renderAsPdf', 'true');
        ApexPages.CurrentPage().getParameters().put('summarizeAs', 'Monthly');
        
        ApexPages.StandardController sc = new ApexPages.StandardController(ac);
        EmbededDashboardOnAccountController testAccPlan = new EmbededDashboardOnAccountController(sc);
        
        PageReference pageRef = Page.EmbedDashboardOnAccount;
        pageRef.getParameters().put('id', String.valueOf(ac.Id));
        Test.setCurrentPage(pageRef);
    }           
                                      
}