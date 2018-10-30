global class EWSActivityOneTimeBatchAccount implements Database.Batchable<sObject>{
    global String Query = 'select Id,Description__c,Case_Number__c FROM Activities__c WHERE Case_Number__c = NULL';
    global EWSActivityOneTimeBatchAccount(String a){
        Query=a;
    }
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        list<Activities__c> AccounttoUpdate = new list<Activities__c>();
        List<Activities__c> Accounts = (List<Activities__c>)scope;
        Map<Id,String> IdsandNumbers = new Map<Id,String>();
        for(Activities__c ac : Accounts){
            String csNumber = '';
            if(String.isNotBlank(ac.Description__c)){
                String s1 = ac.Description__c;
                if(s1.contains(' filed a P1 Case - ')) IdsandNumbers.put(ac.Id,s1.substringBetween(' filed a P1 Case - ',' : '));
                
                else if(s1.contains(' was set as a P2')) IdsandNumbers.put(ac.Id,s1.substringBetween('Case - ',' was set as a P2'));
                
                else if(s1.contains('Was filed for Case - ')) IdsandNumbers.put(ac.Id,s1.substringAfter('Case - '));
                
                else if(s1.contains(' - was reopened ')) IdsandNumbers.put(ac.Id,s1.substringBetween('Case - ',' - was reopened '));
                
                else if(s1.contains(' - Escalated to Tier -3 , Jira Number - ')) IdsandNumbers.put(ac.Id,s1.substringBetween('Case - ',' - Escalated to Tier -3 , Jira Number - '));
                
                else if(s1.contains(' Filed Sitman - ')) IdsandNumbers.put(ac.Id,s1.substringBetween(' Filed Sitman - ',' : '));
                
                else if(s1.contains(' Was escalated to a Subject Matter')) IdsandNumbers.put(ac.Id,s1.substringBetween('Case - ',' Was escalated to a Subject Matter'));
                
                else if(s1.contains(' was identified as a product issue')) IdsandNumbers.put(ac.Id,s1.substringBetween('Case - ',' was identified as a product issue'));
                
                else if(s1.contains(' Delivered a mentor session')) IdsandNumbers.put(ac.Id,s1.substringAfter(';'+ ' Case - '));
                                
                else if(s1.contains(' was opened with a Category of ')) IdsandNumbers.put(ac.Id,s1.substringBetween('Case - ',' was opened with a Category of '));
                
                else if(s1.contains(' Delivered a half-yearly review')) IdsandNumbers.put(ac.Id,s1.substringAfter(';'+ ' Case - '));
            }
        }
        
        if(!IdsandNumbers.isEmpty()){
            Map<String,Id> caseNumbers = new Map<String,Id>();
            for(Case c : [SELECT Id, caseNumber FROM Case where caseNumber IN: IdsandNumbers.values()]){
                caseNumbers.put(c.CaseNumber,c.Id);
            }
            if(!caseNumbers.isEmpty()){
                for(Id i : IdsandNumbers.keySet()){
                    if(caseNumbers.containsKey(IdsandNumbers.get(i))){
                        AccounttoUpdate.add(new Activities__c(Id=i,Case_Number__c=caseNumbers.get(IdsandNumbers.get(i))));
                    }
                }
                
                if(!AccounttoUpdate.isEmpty()) database.update(AccounttoUpdate,false);
            }
        }
    }
    global void finish(Database.BatchableContext BC){}
    /*  implements Database.Batchable<sObject>
    global String Query = 'select Id,Temperature__c,Spam_Trap_Full_Detail__c,Temperature_History__c, (select oldvalue,newvalue,createddate from histories where field IN (\'CAM_Owner__c\')) from Account'+(Test.isRunningTest()?' LIMIT 200':'');
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    global EWSActivityOneTimeBatchAccount(){}
    global EWSActivityOneTimeBatchAccount(String x){
        Query = x;
    }
    
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<Id,List<activityInfoWrapper>> accountIdsForEWSMap = new Map<Id,List<activityInfoWrapper>>();
        List<Account> Accounts = (List<Account>)scope;
        for(Account ac : Accounts){
            for(Accounthistory h : ac.histories){
                if(h.newvalue != null && h.oldvalue != null){
                    List<activityInfoWrapper> temp = new List<activityInfoWrapper>();
                    if(accountIdsForEWSMap.containsKey(ac.Id)) temp = accountIdsForEWSMap.get(ac.Id);
                    activityInfoWrapper accWrap = new activityInfoWrapper();
                    accWrap.name = 'New CSM';
                    accWrap.subDriver = 'New CSM';
                    accWrap.historyDate = h.createddate;
                    
                    accWrap.description = h.newvalue +' - was reassigned as the new CSM.';
                    temp.add(accWrap);
                    accountIdsForEWSMap.put(ac.Id,temp);
                }
            }
           
        } 
        
        if(!accountIdsForEWSMap.isEmpty()) createrEWSActivities(accountIdsForEWSMap);                       // *****Added on - 01 - September, 2016 ******                    
    }
    
    global void finish(Database.BatchableContext BC){
        sendEmail('EWSActivityOneTimeBatchAccount');    
    }
    
    public static void sendEmail(String subject){}
    
    //******** All EWS Activities are created here *************
    public static void createrEWSActivities(Map<Id,List<activityInfoWrapper>> accountIdsForEWSMap) {
        List<Activities__c> activitiesListToInsert = new List<Activities__c>();
        List<Activities__c> activitiesListToUpsert = new List<Activities__c>();
        if(accountIdsForEWSMap != null && accountIdsForEWSMap.size() > 0){
            Set<String> pointsTableNameSet = new Set<String>();
            for(Id i : accountIdsForEWSMap.KeySet()){
                for(activityInfoWrapper s : accountIdsForEWSMap.get(i)){
                    pointsTableNameSet.add(s.name);
                }
            }
            List<EWS_Point_Table__c> pointsTableList = [select Id,Activate__c,Name,Points__c,Type__c,Driver__c,Sub_Driver__c from EWS_Point_Table__c where Name in : pointsTableNameSet];
            Map<String,EWS_Point_Table__c> pointsTableMap = New Map<String,EWS_Point_Table__c>();
            for(EWS_Point_Table__c p : pointsTableList){
                pointsTableMap.put(p.Name,p);
            }
            
            if(accountIdsForEWSMap.size()>0){
                for(Id i : accountIdsForEWSMap.keySet()){                       
                    for(activityInfoWrapper s : accountIdsForEWSMap.get(i)){
                        
                        if(pointsTableMap.containsKey(s.name) && pointsTableMap.get(s.name).Activate__c){
                            if(test.isRunningTest() || (String.isNotBlank(pointsTableMap.get(s.name).Type__c) && pointsTableMap.get(s.name).Type__c == 'Product')){
                                Activities__c ac = new Activities__c();
                                ac.Account__c = i;
                                ac.Name = s.name;
                                ac.EWS_Point__c = pointsTableMap.get(s.name).Id;
                                ac.Description__c = s.description;
                                ac.Type__c = pointsTableMap.get(s.name).Type__c;
                                ac.Driver__c = pointsTableMap.get(s.name).Driver__c;
                                ac.Sub_Driver__c = pointsTableMap.get(s.name).Sub_Driver__c;
                                if(s.historyDate != null) ac.HistoryDate__c = s.historyDate;
                                activitiesListToInsert.add(ac);
                            }
                            if(String.isNotBlank(pointsTableMap.get(s.name).Type__c) && pointsTableMap.get(s.name).Type__c == 'CSM'){
                                Activities__c ac = new Activities__c();
                                ac.Account__c = i;
                                ac.Name = s.name;
                                ac.Description__c = s.description;
                                ac.EWS_Point__c = pointsTableMap.get(s.name).Id;
                                ac.Type__c = pointsTableMap.get(s.name).Type__c;
                                ac.Driver__c = pointsTableMap.get(s.name).Driver__c;
                                ac.Sub_Driver__c = pointsTableMap.get(s.name).Sub_Driver__c;
                                if(s.historyDate != null) ac.HistoryDate__c = s.historyDate;
                                activitiesListToInsert.add(ac);
                            }
              
                            if(String.isNotBlank(pointsTableMap.get(s.name).Type__c) && pointsTableMap.get(s.name).Type__c == 'Support'){
                                if(s.Name != 'Half-Yearly Review' && s.Name != 'Mentor Session'){
                                    Activities__c ac = new Activities__c();
                                    ac.Account__c = i;
                                    ac.Name = s.name;
                                    ac.Description__c = s.description;
                                    ac.EWS_Point__c = pointsTableMap.get(s.name).Id;
                                    ac.Type__c = pointsTableMap.get(s.name).Type__c;
                                    ac.Driver__c = pointsTableMap.get(s.name).Driver__c;
                                    ac.Sub_Driver__c = pointsTableMap.get(s.name).Sub_Driver__c;
                                    if(s.historyDate != null) ac.HistoryDate__c = s.historyDate;
                                    activitiesListToInsert.add(ac);
                                }
                                if(test.isRunningTest() || (s.Name == 'Half-Yearly Review' || s.Name == 'Mentor Session')){
                                    Activities__c ac = new Activities__c();
                                    ac.Account__c = i;
                                    ac.Name = s.name;
                                    ac.Description__c = s.description;
                                    ac.EWS_Point__c = pointsTableMap.get(s.name).Id;
                                    ac.Type__c = pointsTableMap.get(s.name).Type__c;
                                    ac.Driver__c = pointsTableMap.get(s.name).Driver__c;
                                    ac.Sub_Driver__c = pointsTableMap.get(s.name).Sub_Driver__c;
                                    ac.Activity_Identifier__c = s.activityIdentifier + s.name;
                                    if(s.historyDate != null) ac.HistoryDate__c = s.historyDate;
                                    if(!test.isRunningTest()) activitiesListToUpsert.add(ac);    
                                }
                            }
                        }
                    }
                }
            }
     
            if(!activitiesListToInsert.isEmpty()) insert activitiesListToInsert;
            if(!activitiesListToUpsert.isEmpty()) upsert activitiesListToUpsert Activity_Identifier__c;
        }
    }
    
     // Wrapper class to insert EWS Activities with all the fields
     public class activityInfoWrapper {
         public String name = '';
         public String driver = '';
         public String subDriver = '';
         public String description = '';
         public Datetime historyDate;
         public String activityIdentifier = '';
     }
         
    */
}