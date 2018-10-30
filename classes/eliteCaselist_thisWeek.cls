global class eliteCaselist_thisWeek {
    global string accId {get;set;}
    global eliteCaselist_thisWeek(){} 
    global list<case> caseList;  
    
    global list<case> geteliteOpenCaselist(){        
        caseList = new list<case>();
        caseList = [select id,caseNumber,status,priority,createddate,Time_to_Resolution__c from case where accountid =:accId and createddate = LAST_Week and recordtype.Name ='Support Cases' and status!='Closed' order by Priority asc];
        return caseList;
    } 
    global list<case> geteliteClosedCaselist(){
        caseList = new list<case>();
        caseList = [select id,caseNumber,status,priority,ClosedDate,Time_to_Resolution__c from case where accountid =:accId and createddate = LAST_Week and recordtype.Name ='Support Cases' and status ='Closed' order by Priority asc];
        return caseList;
    }

}