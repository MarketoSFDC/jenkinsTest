trigger Trigger_GoToTraining_Registrant on GTT_Registrant__c (before insert, before update) {
    
    Set<string> studentsEmail  = new Set<string>();
    Map<string, Contact> usersMap = new Map<string, Contact>();
    
    for(GTT_Registrant__c student :trigger.new){
        studentsEmail.add(student.Student_Email__c);
    }
    
    for(Contact u : [SELECT Email, Name FROM Contact WHERE Email IN : studentsEmail]){
        usersMap.put(u.Email, u);
    }
    
    for(GTT_Registrant__c student :trigger.new){
        if(usersMap.containsKey(student.Student_Email__c)){
            student.Student__c = usersMap.get(student.Student_Email__c).Id;
        }
    }

}