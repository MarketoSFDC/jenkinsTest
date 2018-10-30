@IsTest
public class Trigger_GoToTraining_RegistrantTest {
    public static testMethod void testTrigger_GoToTraining_Registrant(){
        
        // Insert Account
        List<Account> accountList = new List<Account>();
        accountList = TestCPQUtilityClass.createAccounts(1);  
        insert accountList;
        
        // Insert Contact
        List<Contact> conList = new List<Contact>();
        conList = TestCPQUtilityClass.createContacts(accountList, 1);
        insert conList;
        
        // Insert Custom Event
        lmsilt__Event__c event1 = new lmsilt__Event__c();
        event1.Name = 'test event';
        insert event1;        
        
        // Insert Class object
        lmsilt__Class__c classObj = new lmsilt__Class__c();
        classObj.Name = 'test name';
        classObj.lmsilt__Cancellation_Deadline__c = 2;
        classObj.lmsilt__Maximum_Capacity__c = 20;
        classObj.lmsilt__Minimum_Capacity__c = 1;
        classObj.lmsilt__Start_Date__c = System.today()+2;
        // insert event id
        classObj.lmsilt__Event__c = event1.Id;
        insert classObj;
        
        // Insert GTT_Registrant__c record
        GTT_Registrant__c gt = new GTT_Registrant__c();
        gt.Name = ' test training';
        gt.Student_Email__c = 'test@gmail.com';
        gt.Class__c = classObj.Id;
        gt.Registration_Date__c = System.today();
        gt.Student__c = conList[0].Id;
        insert gt;
        
        update gt;
    }
}