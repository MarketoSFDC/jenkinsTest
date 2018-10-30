@isTest
private class CreateNewOpportunityRedirectTests {

    public static testMethod void createOpportunity(){
        Account a = Utility.insertAccountInTestClasses();
        insert a;
        Contact con = new Contact();
        con.LastName = '12Test1Contact 4';
        con.email = 'test@test.com';
        con.AccountId = a.Id;
        insert con;
        
        PageReference pageRef = Page.NewOpportunityRedirect;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',con.Id);
        CreateNewOpportunityRedirect  cor = new CreateNewOpportunityRedirect(new ApexPages.StandardController(con));
        cor.onLoad();
    }
}