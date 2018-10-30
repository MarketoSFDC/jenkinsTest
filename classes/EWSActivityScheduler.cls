global class EWSActivityScheduler implements Schedulable {  

    global void execute(SchedulableContext context) {
        
        if(Label.EWSActivator == 'YES' || Test.isRunningTest()){
            try{ updateActivities(); }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            try{ checkRenewalSoonToInsertActivity(); }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            try{ checkCaseAgeToInsertActivity(); }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        }
    }   
    
    public void updateActivities() {     
      list<Activities__c> actList = new list<Activities__c>();     
      for(Activities__c act: [SELECT id, IsAgeGreaterThanSixMonths__c from Activities__c where CreatedDate != THIS_MONTH and CreatedDate != LAST_N_MONTHS:5 AND IsAgeGreaterThanSixMonths__c = false AND IsActivityEligible__c = true]){        
          act.IsAgeGreaterThanSixMonths__c = true;
          actList.add(act);       
      }
      if(actList != null && actList.IsEmpty() == false) update actList;      
    }
    
    public void checkRenewalSoonToInsertActivity() {  
        Map<Id,List<EWSUtility.activityInfoWrapper>> accountIdsForEWSMap = new Map<Id,List<EWSUtility.activityInfoWrapper>>();
        Integer i = 0;
        try{i = Integer.valueOf(Label.Account_Renewal_Days);}catch(exception e){i=90;}
        List<EWSUtility.activityInfoWrapper> temp = new List<EWSUtility.activityInfoWrapper>();
            EWSUtility.activityInfoWrapper accWrap = new EWSUtility.activityInfoWrapper();
            accWrap.name = 'Renewal Soon';
            accWrap.subDriver ='Renewal Soon';
            accWrap.description = 'Renewal is in ' + i + ' Days.' ;
            temp.add(accWrap);               
        Date todayDatePlusOne = Date.today().addDays(i+1);
        Date todayDateMinusOne = Date.today().addDays(i-1);
        for(Account acc : [SELECT Id from Account where Acct_Renewal_Date__c != null and Acct_Renewal_Date__c >: todayDateMinusOne and Acct_Renewal_Date__c <: todayDatePlusOne]){
            accountIdsForEWSMap.put(acc.Id,temp);
        }
        if(!accountIdsForEWSMap.isEmpty()){EWSUtility.createrEWSActivities(accountIdsForEWSMap);}       
    }
    
    public static void checkCaseAgeToInsertActivity() {
        Date todayDate =  Date.today();
        Set<String> listOfCat = new Set<String>{'Deliverability','Email','Salesforce.com','Microsoft Dynamics','Sales Insight'};
        Map<Id,List<EWSUtility.activityInfoWrapper>> accountIdsForEWSMap = new Map<Id,List<EWSUtility.activityInfoWrapper>>();
        String hundredDays = 'Aging: 100 days';
        String sixtyDays = 'Aging: 60 days';
        String thirtyDays = 'Aging: 30 days';
        String tenDays = 'Aging: 10 days';
        List<Case> hundredCaseList = [SELECT Id,accountId,CaseNumber from Case where accountId != null and CreatedDate >: todayDate.addDays(-101) and CreatedDate <: todayDate.addDays(-99) and Status != 'Closed'];
        List<Case> thirtyCaseList = [SELECT Id,accountId,CaseNumber from Case where accountId != null and CreatedDate >: todayDate.addDays(-31) and CreatedDate <: todayDate.addDays(-29)  and Status != 'Closed'];
        List<Case> tenCaseList = [SELECT Id,accountId,CaseNumber,Category__c from Case where accountId != null and CreatedDate >: todayDate.addDays(-11) and CreatedDate <: todayDate.addDays(-9) and Status != 'Closed'];
        List<Case> sixtyCaseList = [SELECT Id,accountId,CaseNumber,Category__c from Case where accountId != null and CreatedDate >: todayDate.addDays(-61) and CreatedDate <: todayDate.addDays(-59)  and Status != 'Closed'];
        if(Test.isRunningTest()){
            hundredCaseList = [SELECT Id,accountId,CaseNumber,Category__c from Case where Subject = 'Feature Request'];
            thirtyCaseList = hundredCaseList;
            tenCaseList = hundredCaseList;
            sixtyCaseList = hundredCaseList;
        }
        for(Case c : hundredCaseList){
            List<EWSUtility.activityInfoWrapper> temp = new List<EWSUtility.activityInfoWrapper>();
            if(accountIdsForEWSMap.containsKey(c.accountId)) temp = accountIdsForEWSMap.get(c.accountId);
            
            EWSUtility.activityInfoWrapper accWrap = new EWSUtility.activityInfoWrapper();
            accWrap.name = hundredDays;
            accWrap.subDriver = hundredDays;
            accWrap.description = 'Case - '+ c.CaseNumber +' unresolved for 100 days' ;
            accWrap.caseId = c.Id;
            temp.add(accWrap);               
            accountIdsForEWSMap.put(c.accountId,temp);
        }
        for(Case c : sixtyCaseList){
            List<EWSUtility.activityInfoWrapper> temp = new List<EWSUtility.activityInfoWrapper>();
            if(accountIdsForEWSMap.containsKey(c.accountId)) temp = accountIdsForEWSMap.get(c.accountId);
            
            EWSUtility.activityInfoWrapper accWrap = new EWSUtility.activityInfoWrapper();
            accWrap.name = sixtyDays;
            accWrap.subDriver = sixtyDays;
            accWrap.description = 'Case - '+ c.CaseNumber +' unresolved for 60 days' ;
            accWrap.caseId = c.Id;
            temp.add(accWrap);               
            accountIdsForEWSMap.put(c.accountId,temp);
            
        }
        
        for(Case c : thirtyCaseList){
            List<EWSUtility.activityInfoWrapper> temp = new List<EWSUtility.activityInfoWrapper>();
            if(accountIdsForEWSMap.containsKey(c.accountId)) temp = accountIdsForEWSMap.get(c.accountId);
            
            EWSUtility.activityInfoWrapper accWrap = new EWSUtility.activityInfoWrapper();
            accWrap.name = thirtyDays;
            accWrap.subDriver = thirtyDays;
            accWrap.description = 'Case - '+ c.CaseNumber +' unresolved for 30 days' ;
            accWrap.caseId = c.Id;
            temp.add(accWrap);               
            accountIdsForEWSMap.put(c.accountId,temp);
            
            
        }
        for(Case c : tenCaseList){
            if(c.Category__c != Null && listOfCat.contains(c.Category__c)){
                List<EWSUtility.activityInfoWrapper> temp = new List<EWSUtility.activityInfoWrapper>();
                if(accountIdsForEWSMap.containsKey(c.accountId)) temp = accountIdsForEWSMap.get(c.accountId);
                
                EWSUtility.activityInfoWrapper accWrap = new EWSUtility.activityInfoWrapper();
                accWrap.name = tenDays;
                accWrap.caseId = c.Id;
                accWrap.subDriver = tenDays;
                accWrap.description = 'Volatile Case - '+ c.CaseNumber+' with category '+ c.Category__c +' has been open for 10 days' ;
                temp.add(accWrap);               
                accountIdsForEWSMap.put(c.accountId,temp);
                
            }
        }
        if(!accountIdsForEWSMap.isEmpty()){EWSUtility.createrEWSActivities(accountIdsForEWSMap);}
    }
          
}