global class VoteOnIdeaBatchClass { //implements Database.Batchable<sObject>,Database.Stateful, Database.AllowsCallouts
   /*Global Set<Id> voteIds ; 
 
     global VoteOnIdeaBatchClass(Set<Id> voteIds){
        this.voteIds = voteIds.clone();
                // Batch Constructor
     }
     
     // Start Method
     global Database.QueryLocator start(Database.BatchableContext BC){
         String query = '';
         if(Test.isRunningTest()){
             query = 'SELECT id, CreatedDate,CreatedById from Vote where id in : voteIds Limit 1';     
         
         }else{
             query = 'SELECT id, CreatedDate,CreatedById from Vote where id in : voteIds';
         }
         return Database.getQueryLocator(query);
     }
    
   // Execute Logic
    global void execute(Database.BatchableContext BC, List<vote> scope){
        List<BadgevilleBehavior__c> badgeList = New List<BadgevilleBehavior__c>();
            for(vote v : scope){
                BadgevilleBehavior__c badgebehv = New BadgevilleBehavior__c();
                badgebehv.Behaviours__c = 'Vote on idea';
                badgebehv.CustomCreatedDate__c = v.CreatedDate;
                badgebehv.UserId__c = v.CreatedById;
                badgeList.add(badgebehv);
            }
            system.debug('badgeList-->'+badgeList.size());
            insert badgeList;
           // Logic to be Executed batch wise      
   
    }
   
    global void finish(Database.BatchableContext BC){
         // Logic to be Executed at finish
    }*/
 }