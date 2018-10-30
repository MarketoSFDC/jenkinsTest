trigger Trigger_GoToTraining_Attendance on GoToTraining_Attendance__c(before insert, before update) {
    
    Set<string> studentsEmail  = new Set<string>();
    Map<string, Contact> usersMap = new Map<string, Contact>();
    
    for(GoToTraining_Attendance__c student :trigger.new){
        studentsEmail.add(student.Attendee_Email__c);
    }
    
    for(Contact u : [SELECT Email, Name FROM Contact WHERE Email IN : studentsEmail]){
        usersMap.put(u.Email, u);
    }
    
    for(GoToTraining_Attendance__c student :trigger.new){
        if(usersMap.containsKey(student.Attendee_Email__c)){
            student.Student_In_SFDC__c = usersMap.get(student.Attendee_Email__c).Id;
        }
    }

}