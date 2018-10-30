@isTest
public class TestQueueOwnedCaseNCaseCommentTriggers {    
    @isTest(seeAllData=true)
    public static void testEmailToCase() {
        List<String> queueNames = new String[]{'Support Escalations Queue','MarketoCares Queue'};
        List<QueueSobject> myQueuelist =  new List<QueueSobject>();
        myQueuelist =  [Select Id, QueueId,q.Queue.Name from QueueSobject q where q.Queue.Name in:queueNames];

        Account acc = new Account(Name = 'Test Acc',Type = 'Customer',RecordTypeId = '01250000000ULb7');
        insert acc;        
        Contact con = new Contact(LastName = 'Test Con', Email = 'test@test.com',FirstName = 'test',AccountId = acc.Id);
        insert con;        
        Case caseObj = new Case(Status = 'New', Priority = 'P1', Subject = 'Test', SuppliedEmail = 'test@test.com',Description = 'Test Description', Origin = 'TBD',OwnerId=myQueuelist[0].QueueId);
        insert caseObj;        
        CaseComment com = new CaseComment();
        com.ParentId = caseObj.id;
        com.CommentBody= caseObj.Description;
        Insert com ;   
             
        CaseComment com2 = new CaseComment();
        com2.ParentId = caseObj.id;
        com2.CommentBody= caseObj.Description;
        com2.isPublished = true;
        Insert com2 ;        


        
    }
}