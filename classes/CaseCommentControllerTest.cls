@isTest
public class CaseCommentControllerTest{

    public static testMethod void testMyController() {
         
        Account acc = new Account(Name = 'TestAccount1', Type = 'Prospect', CurrencyIsoCode = 'USD', Sales_Region__c = 'North America', Account_Ghost_Access__c = 'Never');
        insert acc; 
        
        Contact con = new Contact(FirstName = 'TestContactF1', LastName = 'TestContactL1', LeadSource = 'Blog', Email = 'testcontactf1@gmail.com', AccountId = acc.Id);
        insert con;
        
        
        Case cs = new Case(ContactId = con.Id, AccountId = acc.Id, Status = 'New', Priority = 'P3', recordTypeId = Label.supportcaserecordtypeid);
        insert cs;
        
        CaseComment cc = new CaseComment(ParentId = cs.Id, isPublished = True, CommentBody = 'Test Comment is created');
        insert cc; 
        
        Test.startTest();
        CaseCommentController ccc = new CaseCommentController();
        ccc.caseId= cs.Id;
        ccc.getCaseComment();
        Test.stopTest();
    }
}