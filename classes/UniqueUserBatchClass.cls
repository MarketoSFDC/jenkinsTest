global class UniqueUserBatchClass  implements Database.Batchable<sObject>,Database.Stateful, Database.AllowsCallouts{
     Global Datetime startDate;
     Global Datetime endDate;
     Global Boolean checkThisMonth;
     
     
     global UniqueUserBatchClass (){
        UniqueUserSetting__c currUniqueUserSetting  =  UniqueUserSetting__c.getInstance('UniqueUser');
        startDate = datetime.valueOf(currUniqueUserSetting.StartDateTimeForUniqueUser__c);
        endDate = datetime.valueOf(currUniqueUserSetting.EndDateTimeForUniqueUser__c);
        checkThisMonth = currUniqueUserSetting.IsThisMonth__c;
        
                // Batch Constructor
     }
     
     // Start Method
     global Database.QueryLocator start(Database.BatchableContext BC){
        String query='';
        if(test.isrunningtest()){
             query = 'Select id From User where IsPortalEnabled = true and IsActive = true and Profile.Name in (\'Session Marketo Community\',\'Named Marketo Community Portal\')  LIMIT 1';    
        }else{
         query = 'Select id From User where IsPortalEnabled = true and IsActive = true and Profile.Name in (\'Session Marketo Community\',\'Named Marketo Community Portal\')';
        }   
      return Database.getQueryLocator(query);
     }
    
   // Execute Logic
    global void execute(Database.BatchableContext BC, List<User> scope){
        Map<Id,User> userIdToUserMap = New Map<Id,User>();
        List<LoginHistory> loginhistoryList = new List<LoginHistory>();
        for(User u : scope){
            userIdToUserMap.put(u.id,u);
        }
        if(!checkThisMonth){
            loginhistoryList =[Select id,UserId, LoginTime From LoginHistory  where UserId in:userIdToUserMap.keyset() and LoginTime > =: startDate  and LoginTime <=: endDate order by LoginTime asc];
        }else{
            loginhistoryList =[Select id,UserId, LoginTime From LoginHistory  where UserId in:userIdToUserMap.keyset() and LoginTime =LAST_MONTH order by LoginTime asc];
        }

        system.debug('loginhistoryList-->'+loginhistoryList);
        Map<Id,LoginHistory> useridToLoginhistoryMap = New Map<Id,LoginHistory>();
        for(LoginHistory l:loginhistoryList){
            useridToLoginhistoryMap.put(l.UserId,l);
        }
        List<Logged_users__c> loggedUserList = new List<Logged_users__c>();
        
        //AggregateResult[] groupedResults = [SELECT count(LoginTime),UserId from LoginHistory where UserId in:useridToLoginhistoryMap.keyset() and LoginTime >=: startDate  and LoginTime <=: endDate GROUP BY UserId];

        for (LoginHistory temp : useridToLoginhistoryMap.values())  {
            Logged_users__c logged= new Logged_users__c();
            logged.LastLoginDateTime__c = temp.LoginTime;
            logged.User__c = temp.UserId;
            logged.IsCommunityUniqueUserReport__c = true;
            loggedUserList.add(logged);
    
        }
        insert loggedUserList;
        // Logic to be Executed batch wise      
   
    }
   
    global void finish(Database.BatchableContext BC){
         // Logic to be Executed at finish
    }
 }