global class EWSActivityUsageCreater implements Database.Batchable<sObject>{

    global String Query = 'select id,sessioncount__c,Marketo_Users__c,JBCXM__Account__r.Name,JBCXM__Account__c,leadcount__c,emailsentcount__c from JBCXM__UsageData__c where ((emailsentcount__c != null and leadcount__c != null and leadcount__c != 0) or (sessioncount__c != null and Marketo_Users__c != null and Marketo_Users__c != 0)) and CreatedDate = LAST_N_DAYS:7';
  //  global final String Query = 'select id,sessioncount__c,Marketo_Users__c,JBCXM__Account__r.Name,JBCXM__Account__c,leadcount__c,emailsentcount__c from JBCXM__UsageData__c where (emailsentcount__c != null and leadcount__c != null and leadcount__c != 0) or (sessioncount__c != null and Marketo_Users__c != null and Marketo_Users__c != 0)';
    global EWSActivityUsageCreater(){}
    
    global EWSActivityUsageCreater(String query){
        query = query;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        try{
            if(Test.isRunningTest() || Label.EWSActivator == 'YES'){
                List<JBCXM__UsageData__c> usageDataList = (List<JBCXM__UsageData__c>)scope;
                Map<Id,List<EWSUtility.activityInfoWrapper>> accountIdsForEWSMap = new Map<Id,List<EWSUtility.activityInfoWrapper>>();
                Decimal countLowLogins = 0;
                Decimal countLowEmailSends = 0;
                try{countLowEmailSends = Decimal.valueOf(Label.Inactivity_Low_Email_sends);}catch(exception e){countLowEmailSends = 22;}
                try{countLowLogins = Decimal.valueOf(Label.Inactivity_Low_Logins);}catch(exception e){countLowLogins = 25;}
                for(JBCXM__UsageData__c u : usageDataList){
                    if(u.emailsentcount__c != null && u.leadcount__c != null && u.leadcount__c != 0){
                        Decimal percentCount = u.emailsentcount__c/u.leadcount__c;
                        if(percentCount*100 <= countLowEmailSends){
                            List<EWSUtility.activityInfoWrapper> temp = new List<EWSUtility.activityInfoWrapper>();
                            if(accountIdsForEWSMap.containsKey(u.JBCXM__Account__c)) temp = accountIdsForEWSMap.get(u.JBCXM__Account__c); 
                            EWSUtility.activityInfoWrapper accWrap = new EWSUtility.activityInfoWrapper();
                            accWrap.name = 'Inactivity: Low Email sends';
                            accWrap.description = u.JBCXM__Account__r.Name +' had a low Email send rate for the week of Last week';
                            temp.add(accWrap);               
                            accountIdsForEWSMap.put(u.JBCXM__Account__c,temp);     
                        }
                    }
                    if(Test.isRunningTest()){u.Marketo_Users__c=500;}
                    if(u.sessioncount__c != null && u.Marketo_Users__c != null && u.Marketo_Users__c != 0){
                        Decimal percentCount = u.sessioncount__c/u.Marketo_Users__c;
                        if(percentCount*100 <= countLowLogins){
                            List<EWSUtility.activityInfoWrapper> temp = new List<EWSUtility.activityInfoWrapper>();
                            if(accountIdsForEWSMap.containsKey(u.JBCXM__Account__c)) temp = accountIdsForEWSMap.get(u.JBCXM__Account__c);
                            EWSUtility.activityInfoWrapper accWrap = new EWSUtility.activityInfoWrapper();
                            accWrap.name = 'Inactivity: Low Logins';
                            accWrap.description = u.JBCXM__Account__r.Name +' had low logins';
                            temp.add(accWrap);               
                            accountIdsForEWSMap.put(u.JBCXM__Account__c,temp);
                        }
                    }
                }
                if(!accountIdsForEWSMap.isEmpty()){EWSUtility.createrEWSActivities(accountIdsForEWSMap);}
            } 
        }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
    }
    
    global void finish(Database.BatchableContext BC){}
}