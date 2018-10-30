public with sharing class CFS_Class_Reminder_Controller {
    
    public string classId {get;set;}
    public List<lmsilt__Session__c> getClassSessions(){
        List<lmsilt__Session__c> SessionList = new List<lmsilt__Session__c>([
            SELECT Id,lmsilt__End_Date_Time__c,lmsilt__Start_Date_Time__c,lmsilt__Time_Zone__c,lmsilt__Session_Location__r.name,Name,lmsilt__Class__c FROM lmsilt__Session__c
            WHERE lmsilt__Class__c =: classId  
            ORDER BY lmsilt__Start_Date_Time__c ASC 
        ]);
        return SessionList;
    }
}