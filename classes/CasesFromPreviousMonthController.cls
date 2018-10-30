global class CasesFromPreviousMonthController {
    public String ManagerActivityLogId;
    public List<Store_Cases_For_Month__c> previousMonStoredCases {get;set;}
    public list<Store_Cases_For_Month__c> listOfPreviousCasesToBeDisplayed {get;set;}
    public list<Manger_Activity_Log__c> lstActivityLogManagers{get;set;}     
    public String ActivityLogManager{get;set{ActivityLogManager = value;getActivityLogFromPreviousMonth();}}

    public String ActivityLogManagerNew{get;set{ActivityLogManagerNew = value;getActivityLogFromCurrentMonth();}}
       
    public void setManagerId (Id tempId) {
        ManagerActivityLogId = tempId;
        //getCasesFromPreviousMonth();        
    }    
    public Id getManagerId() {
        return ManagerActivityLogId;
    }
    
    public void getActivityLogFromPreviousMonth() {

        Integer daysBefore = 7;        
        try {
            daysBefore = Integer.valueof(System.Label.CaseQualityReviewReminderDays);
        } catch (Exception ex) {
            system.debug('Exception==>' + ex);
        }                
        //Set current month last date.
        Date lastDtofMnth = Date.today().toStartOfMonth().addMonths(1).addDays(-1);                
        Date plusAddedDays = Date.Today().addDays(daysBefore);//Added 7 days pending check.    
        if(!Test.isRunningTest()){if(plusAddedDays != lastDtofMnth) return;}      
        //Date plusSevenDays = Date.Today().addDays(7);//Added 7 days pending check.     
        
        lstActivityLogManagers = new List<Manger_Activity_Log__c>();
        Map<Id,Manger_Activity_Log__c> ActivityLogManagers = new Map<Id,Manger_Activity_Log__c>([SELECT ID, TseName__r.Name, (SELECT Case__r.CaseNumber, Case__c, Case__r.Account.Name, Case__r.Subject, Case__r.Support_Level__c, Case__r.Priority, Case__r.ClosedDate, Case__r.AgeInDays__c, Manager_Reminded__c, Manger_Activity_Log__r.TseName__r.Name FROM Store_Cases_For_Month__r where Evaluation_Status__c = 'Evaluate' AND Evaluation_Ended__c <=: plusAddedDays) FROM Manger_Activity_Log__c Where SupportManager__c =: ActivityLogManager AND TseName__r.isActive = True]);                     
        for(Id tmp : ActivityLogManagers.keySet()) {
            previousMonStoredCases = new List<Store_Cases_For_Month__c>(); previousMonStoredCases.addAll(ActivityLogManagers.get(tmp).Store_Cases_For_Month__r);             if(ActivityLogManagers.get(tmp).Store_Cases_For_Month__r.isEmpty() == FALSE) {              lstActivityLogManagers.add(ActivityLogManagers.get(tmp));}
        }
    }
    
    public void getActivityLogFromCurrentMonth() {        
        lstActivityLogManagers = new List<Manger_Activity_Log__c>();
        Map<Id,Manger_Activity_Log__c> ActivityLogManagers = new Map<Id,Manger_Activity_Log__c>([SELECT ID, TseName__r.Name, (SELECT Case__r.CaseNumber, Case__c, Case__r.Account.Name, Case__r.Subject, Case__r.Support_Level__c, Case__r.Priority, Case__r.ClosedDate, Case__r.AgeInDays__c, Manager_Reminded__c, Manger_Activity_Log__r.TseName__r.Name FROM Store_Cases_For_Month__r where Evaluation_Status__c = 'Evaluate' AND CreatedDate = Today) FROM Manger_Activity_Log__c Where SupportManager__c =: ActivityLogManagerNew AND TseName__r.isActive = True]);
        System.Debug('________ActivityLogManagers_______'+ActivityLogManagers);        
        for(Id tmp : ActivityLogManagers.keySet()) {
            previousMonStoredCases = new List<Store_Cases_For_Month__c>(); previousMonStoredCases.addAll(ActivityLogManagers.get(tmp).Store_Cases_For_Month__r); if(ActivityLogManagers.get(tmp).Store_Cases_For_Month__r.isEmpty() == FALSE) { lstActivityLogManagers.add(ActivityLogManagers.get(tmp));}
        }
    }
    
    
    //not used.  
    /*
    public void getCasesFromPreviousMonth() {
        listOfPreviousCasesToBeDisplayed  = new List<Store_Cases_For_Month__c>();
        //previousMonStoredCases = [Select Case__r.CaseNumber, Case__c, Manager_Reminded__c, Manger_Activity_Log__r.TseName__r.Name from Store_Cases_For_Month__c where Manger_Activity_Log__c =: ManagerActivityLogId AND Evaluation_Ended__c <=: date.newinstance(System.now().year(), System.now().month(), System.now().day()) AND (Evaluation_Status__c = 'In Progress' OR Evaluation_Status__c = '')];
        previousMonStoredCases = [Select Case__r.CaseNumber, Case__c, Manager_Reminded__c, Manger_Activity_Log__r.TseName__r.Name from Store_Cases_For_Month__c where Manger_Activity_Log__c =: ManagerActivityLogId AND Evaluation_Status__c = 'Evaluate' AND Evaluation_Ended__c <=: date.newinstance(System.now().year(), System.now().month(), System.now().day()) ];
        //previousMonStoredCases = [Select Manger_Activity_Log__c, Case__r.CaseNumber, Case__c,Manger_Activity_Log__r.TseName__c, Manager_Reminded__c, Manger_Activity_Log__r.TseName__r.Name from Store_Cases_For_Month__c where Manger_Activity_Log__c =: ManagerActivityLogId ];
        System.Debug('________previousMonStoredCases_______'+previousMonStoredCases);
        for(Store_Cases_For_Month__c tempStoredCases : previousMonStoredCases){
            if(tempStoredCases.Manager_Reminded__c == null){
                tempStoredCases.Manager_Reminded__c = System.now();
                listOfPreviousCasesToBeDisplayed.add(tempStoredCases);
            } else if(Calculate_Duration_In_Hours.duration_between_two_date_times(tempStoredCases.Manager_Reminded__c, System.now()) > 1){
                tempStoredCases.Manager_Reminded__c = System.now();
                listOfPreviousCasesToBeDisplayed.add(tempStoredCases);
            }
        }
    }*/
}