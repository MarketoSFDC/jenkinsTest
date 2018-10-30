////////******** P1 Tracking ********////////////////SOPS-1135

global class batchcaseP1Update implements Database.Batchable<sObject> {
    global Database.QueryLocator start(Database.BatchableContext BC) {
        string usrId = '\'01250000000UJwx\'';
        String query = 'select id, Maximum_Priority__c, Initial_Priority__c, Priority, P1_Priority_Flag__c from case where createddate = this_year and recordtypeid = ' +usrId+' and Initial_Priority__c = null and Maximum_Priority__c = null';
        if(test.isrunningtest()){
            string p1 = 'P1';
            query = 'SELECT Id, Priority, P1_Priority_Flag__c from case where recordtypeid =' +usrId+' and P1_Priority_Flag__c!=true and Priority = :p1 LIMIT 1';
        }
        system.debug('query==>'+query);
        return Database.getQueryLocator(query);
    }
   
    global void execute(Database.BatchableContext BC, List<Case> scope) {
        list<case> year2016Cases = new list<case>();
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule= false;
        for(case cs : scope){
            cs.setOptions(dmo);
            if (cs.P1_Priority_Flag__c){
                year2016Cases.add(new case(id=cs.id, Initial_Priority__c = cs.Priority, Maximum_Priority__c = 'P1'));
            }else{
                year2016Cases.add(new case(id=cs.id, Initial_Priority__c = cs.Priority, Maximum_Priority__c = cs.Priority ));
            }
            
        }
        update year2016Cases;
    }   
    
    global void finish(Database.BatchableContext BC) {
        system.debug('<<<=====I am in finish=====>>>>>>'+BC);
    }
}