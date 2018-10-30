@isTest
public class CaseRelatedArticleListTest {

    static testMethod void CaseRelatedArticleLists () {
        Account acc = new Account();
        acc.Name = 'test acc';
        insert acc;
        
        Contact c= new Contact();
        c.FirstName = 'test';
        c.LastName = 'test contact'; 
        c.Accountid = acc.id; 
        c.email = 'test@testing.com';
        c.Phone = '123456789';
        insert c; 
        Case cs = new Case(Accountid = acc.id,contactid = c.id);
        
        CaseRelatedArticleList obj = new CaseRelatedArticleList(new ApexPages.StandardController(cs));

    }
}