global class SelectbestanswerClass {//implements Database.Batchable<sObject>,Database.Stateful, Database.AllowsCallouts
   /* Global Set<Id> bestReplyIds ; 
 
     global SelectbestanswerClass(Set<Id> bestReplyIds){
        this.bestReplyIds = bestReplyIds.clone();
                // Batch Constructor
     }
     
     // Start Method
     global Database.QueryLocator start(Database.BatchableContext BC){
         String query = '';
         if(Test.isRunningTest()){
             query = 'SELECT id, CreatedDate, CreatedById From Reply where id in : bestReplyIds Limit 1';
         }else{
             query = 'SELECT id, CreatedDate, CreatedById From Reply where id in : bestReplyIds';
         }
         return Database.getQueryLocator(query);
     }
    
   // Execute Logic
    global void execute(Database.BatchableContext BC, List<Reply> scope){
        List<BadgevilleBehavior__c> badgeList = New List<BadgevilleBehavior__c>();
            for(Reply r : scope){
                BadgevilleBehavior__c badgebehv = New BadgevilleBehavior__c();
                badgebehv.Behaviours__c = 'Select best answer';
                badgebehv.CustomCreatedDate__c = r.CreatedDate;
                badgebehv.UserId__c = r.CreatedById;
                badgeList.add(badgebehv);
            }
            insert badgeList;
           // Logic to be Executed batch wise      
   
    }
   
    global void finish(Database.BatchableContext BC){
         // Logic to be Executed at finish
    }*/
 }