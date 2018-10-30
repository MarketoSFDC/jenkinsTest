@isTest
public class CFS_Class_Reminder_Controller_Test {

    @isTest
    static void test() {
        lmsilt__Event__c e = new lmsilt__Event__c(name='eventTest');
        insert e;
        lmsilt__Class__c c = new lmsilt__Class__c (name='classTest', lmsilt__Event__c=e.id);
        insert c;
        CFS_Class_Reminder_Controller contr = new CFS_Class_Reminder_Controller();
        contr.classId = c.id;
        contr.getClassSessions();
    }
}