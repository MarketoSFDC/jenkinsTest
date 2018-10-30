global class EWSActivityOneTimeBatchCase{
    public EWSActivityOneTimeBatchCase(){}
    /*  implements Database.Batchable<sObject> 
    global final String Query = 'SELECT createddate, (select oldvalue,newvalue,field,createddate from histories where field IN (\'Priority\',\'JIRA_Num__c\',\'Status\',\'Category__c\') order by createddate asc), Status,id,Escalated_to_SME__c,RecordTypeID,Problem_Type__c,Close_Reason__c,Category__c,Situation_Account__c,JIRA_Num__c,CaseNumber,AccountId,No_Of_Times_Case_Re_opened__c,Priority,Subject,ContactId,Contact.Name,Situation_Contact__r.FirstName,Situation_Contact__r.LastName,owner.Name from case where AccountId != null and CREATEDDATE = LAST_N_DAYS:180'+(Test.isRunningTest()?' LIMIT 200':'');
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<Id,List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>> accountIdsForEWSMap = new Map<Id,List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>>();
        Set<String> listOfCat = new Set<String>{'Deliverability','Email','Salesforce.com','Microsoft Dynamics','Sales Insight'};
        List<Case> cases = (List<Case>)scope;
        for(Case c : cases){
            if(String.isNotBlank(c.AccountId)){
            if(test.isRunningTest() || (c.RecordTypeID=='01250000000UK1E' || c.RecordTypeID=='01250000000UKps')){    
                List<EWSActivityOneTimeBatchAccount.activityInfoWrapper> temp = new List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>(); 
                if(accountIdsForEWSMap.containsKey(c.AccountId)) temp = accountIdsForEWSMap.get(c.AccountId);
                EWSActivityOneTimeBatchAccount.activityInfoWrapper accWrap = new EWSActivityOneTimeBatchAccount.activityInfoWrapper();
                accWrap.name = 'Sitman Filled';
                accWrap.subDriver = 'Sitman Filled';
                accWrap.historyDate = c.createddate;
                accWrap.description = c.Situation_Contact__r.FirstName +' '+ c.Situation_Contact__r.LastName +' Filed Sitman - '+c.CaseNumber+' : '+c.Subject;
                temp.add(accWrap);
                accountIdsForEWSMap.put(c.AccountId,temp);    
            
            }
            Integer reopencount = 0;
        for(CaseHistory h : c.histories){
            
                
                    if(h.field == 'Priority'){
                    if(h.newvalue == 'P1'){
                         List<EWSActivityOneTimeBatchAccount.activityInfoWrapper> temp = new List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>(); 
                            if(accountIdsForEWSMap.containsKey(c.AccountId)) temp = accountIdsForEWSMap.get(c.AccountId);
                            EWSActivityOneTimeBatchAccount.activityInfoWrapper accWrap = new EWSActivityOneTimeBatchAccount.activityInfoWrapper();
                            accWrap.name = 'P1 Condition';
                            accWrap.subDriver = 'P1 Condition';
                            accWrap.historyDate = h.createddate;
                            accWrap.description = c.Contact.Name+' filed a P1 Case - '+c.CaseNumber+' : '+c.Subject;
                            temp.add(accWrap);
                            accountIdsForEWSMap.put(c.AccountId,temp);     
                    }
                    
                    if(h.newvalue == 'P2'){
                        List<EWSActivityOneTimeBatchAccount.activityInfoWrapper> temp = new List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>();  
                            if(accountIdsForEWSMap.containsKey(c.AccountId)) temp = accountIdsForEWSMap.get(c.AccountId);
                            EWSActivityOneTimeBatchAccount.activityInfoWrapper accWrap = new EWSActivityOneTimeBatchAccount.activityInfoWrapper();
                            accWrap.name = 'P2 Case';
                            accWrap.subDriver = 'P2 Case';
                            accWrap.historyDate = h.createddate;
                            accWrap.description = 'Case - '+ c.CaseNumber +' was set as a P2';
                            temp.add(accWrap);
                            accountIdsForEWSMap.put(c.AccountId,temp);  
                    }
                    }
                    
                    if(h.field == 'Status' && h.newvalue !='Closed' && h.oldvalue =='Closed'){
                       
                        if(test.isRunningTest() || (reopencount > 2)){    
                            List<EWSActivityOneTimeBatchAccount.activityInfoWrapper> temp = new List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>();
                            if(accountIdsForEWSMap.containsKey(c.AccountId)) temp = accountIdsForEWSMap.get(c.AccountId);
                            EWSActivityOneTimeBatchAccount.activityInfoWrapper accWrap = new EWSActivityOneTimeBatchAccount.activityInfoWrapper();
                            accWrap.name = 'Excessive (2+) Reopens';
                            accWrap.subDriver = 'Excessive Reopens';
                            accWrap.historyDate = h.createddate;
                            accWrap.description = 'Case - '+ c.CaseNumber+' - was reopened '+ reopencount + ' times.'; 
                            temp.add(accWrap);
                            accountIdsForEWSMap.put(c.AccountId,temp);
                        }
                        reopencount++;
                    }
                    if(h.field == 'JIRA_Num__c' && h.newvalue != null && h.newvalue != ''){
                        List<EWSActivityOneTimeBatchAccount.activityInfoWrapper> temp = new List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>();
                            if(accountIdsForEWSMap.containsKey(c.AccountId)) temp = accountIdsForEWSMap.get(c.AccountId);
                            EWSActivityOneTimeBatchAccount.activityInfoWrapper accWrap = new EWSActivityOneTimeBatchAccount.activityInfoWrapper();
                            accWrap.Name = 'Escalated to Engineering';
                            accWrap.subDriver = 'Escalated to Engineering';
                            accWrap.historyDate = h.createddate;
                            accWrap.description = 'Case - '+ c.CaseNumber+' - Escalated to Tier -3 , Jira Number - '+h.newvalue;
                            temp.add(accWrap);
                            accountIdsForEWSMap.put(c.AccountId,temp);  
                    }
                
              
            
             if(h.field == 'Category__c' && h.newvalue != null && listOfCat.contains((string)h.newvalue) && c.RecordTypeID=='01250000000UJwx'){
               
                    
                         List<EWSActivityOneTimeBatchAccount.activityInfoWrapper> temp = new List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>();
                            if(accountIdsForEWSMap.containsKey(c.AccountId)) temp = accountIdsForEWSMap.get(c.AccountId);
                            EWSActivityOneTimeBatchAccount.activityInfoWrapper accWrap = new EWSActivityOneTimeBatchAccount.activityInfoWrapper();
                            accWrap.name = 'Case opened: Volatile Subject';
                            accWrap.historyDate = h.createddate;
                            accWrap.subDriver = 'Case opened: Volatile Subject';
                            accWrap.description = 'Case - ' + c.CaseNumber +' was opened with a Category of '+ h.newvalue;
                            temp.add(accWrap);   
                            accountIdsForEWSMap.put(c.AccountId,temp);        
                
                }
                
                }
                }
            
        }
        if(!accountIdsForEWSMap.isEmpty()) EWSActivityOneTimeBatchAccount.createrEWSActivities(accountIdsForEWSMap);
      }  
    
    global void finish(Database.BatchableContext BC){
      EWSActivityOneTimeBatchAccount.sendEmail('EWSActivityOneTimeBatchCase');
    }
    */
}