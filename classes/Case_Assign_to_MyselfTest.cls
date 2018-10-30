/* Name: Case_Assign_to_MyselfTest
     Description : Controller for Case_Assign_to_Myself
     Author : LK
     History:
     VERSION     AUTHOR               DATE                            DETAIL                                    UserStory/Req#
     1.0 -             
       */
@isTest
public class Case_Assign_to_MyselfTest {
    static testMethod void testMethod1() {
    
        Case cse = new Case();
        cse.recordtypeId = Label.SupportCaseRecordTypeId;
        cse.Priority = 'High'; 
        cse.subject = 'test';
        cse.status = 'New';
        cse.Category__c = 'ToutApp';
        cse.Last_Public_Comment_Date_Time__c = System.Now();
        cse.status = 'Closed';
        insert cse;
        
        ApexPages.CurrentPage().getParameters().put('caseId', cse.Id);
    
        Case_Assign_to_Myself camObj = new Case_Assign_to_Myself();
        PageReference pageRef = camObj.assignCaseToRunningUser();
        
    }
}