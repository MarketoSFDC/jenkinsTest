global class TSECasesFromPreviousWeekController {
    public list<Mentor_TSE_Table__c > mentorList{get;set;}     
    public static Map<Id,List<Store_Cases_By_Week__c>> tseCaseMap{get;set;}
    public String ManagerActivityLogId;
    public Id ActivityLogManagerNew {get;set;}
   
    public List<Mentor_TSE_Table__c> getWeekMap(){
        mentorList = new List<Mentor_TSE_Table__c>();
        mentorList = [Select id,Trainee_Name__r.name,(SELECT Mentor_TSE_Table__r.Trainee_Name__r.name,Mentor_TSE_Table__c ,Mentor_TSE_Table__r.Trainee_Name__c,case__r.Account.name,Case__r.Support_Level__c,Case__r.casenumber,Case__r.Subject,Case__r.Priority,Case__r.AgeInDays__c,Case__r.ClosedDate from Store_Cases_By_Weeks__r where createddate = today limit 5) from Mentor_TSE_Table__c where id =: ActivityLogManagerNew];
        return mentorList;
        
        
    }
}