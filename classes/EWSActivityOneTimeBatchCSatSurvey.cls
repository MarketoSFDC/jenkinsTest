global class EWSActivityOneTimeBatchCSatSurvey{
    public EWSActivityOneTimeBatchCSatSurvey(){}
    /*  implements Database.Batchable<sObject> 
    global String Query = 'select id,createddate,Case__r.CaseNumber,Question_1__c,Account__c from CSatSurveyFeedback__c where Account__c != null and Question_1__c != null'+(Test.isRunningTest()?' LIMIT 200':'');
    global EWSActivityOneTimeBatchCSatSurvey(){}
    global EWSActivityOneTimeBatchCSatSurvey(String x){
        Query = x;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<Id,List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>> accountIdsForEWSMap = new Map<Id,List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>>();
        List<CSatSurveyFeedback__c> authContacts = (List<CSatSurveyFeedback__c>)scope;
        for(CSatSurveyFeedback__c cs : authContacts){
            if(String.isNotEmpty(cs.Question_1__c)){
                if(Integer.valueOf(cs.Question_1__c) >= 4){
                    List<EWSActivityOneTimeBatchAccount.activityInfoWrapper> temp = new List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>();
                    if(accountIdsForEWSMap.containsKey(cs.Account__c)) temp = accountIdsForEWSMap.get(cs.Account__c);
                    EWSActivityOneTimeBatchAccount.activityInfoWrapper accWrap = new EWSActivityOneTimeBatchAccount.activityInfoWrapper();
                    accWrap.name = 'Positive CSAT';
                    accWrap.subDriver = 'Positive CSAT';
                    accWrap.description = 'A score of '+ cs.Question_1__c +' Was filed for Case - '+ cs.Case__r.CaseNumber;
                    accWrap.historyDate = cs.createddate;
                    temp.add(accWrap);
                    accountIdsForEWSMap.put(cs.Account__c,temp);     
                }
                else if(Integer.valueOf(cs.Question_1__c )< 3){
                    List<EWSActivityOneTimeBatchAccount.activityInfoWrapper> temp = new List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>();
                    if(accountIdsForEWSMap.containsKey(cs.Account__c)) temp = accountIdsForEWSMap.get(cs.Account__c);
                    EWSActivityOneTimeBatchAccount.activityInfoWrapper accWrap = new EWSActivityOneTimeBatchAccount.activityInfoWrapper();
                    accWrap.name = 'Negative CSAT';
                    accWrap.subDriver = 'Negative CSAT';
                    accWrap.description = 'A score of '+ cs.Question_1__c +' Was filed for Case - '+ cs.Case__r.CaseNumber;
                    accWrap.historyDate = cs.createddate;
                    temp.add(accWrap);
                    accountIdsForEWSMap.put(cs.Account__c,temp);
                }                                 
            }   
        }
        if(accountIdsForEWSMap.size()>0) EWSActivityOneTimeBatchAccount.createrEWSActivities(accountIdsForEWSMap);
        
    }
    global void finish(Database.BatchableContext BC){
        EWSActivityOneTimeBatchAccount.sendEmail('EWSActivityOneTimeBatchCSatSurvey');
    }
    */
}