/* *****************************************************************************************
Last Modified By: Jade Global Inc, On 9th May 2018
Purpose         : Move Authorized Contact and Cases from Expired Entitlement to Active Entitlement 
***************************************************************************************** */

global class entitlementSubscriptionGrace implements Schedulable{
   global void execute(SchedulableContext SC) {    
     List<Entitlement> entitle = [SELECT Id,Processed_for_grace__c, Previous_Entitlement__c, Subscription_End_Date__c, EndDate,Subscription__r.SBQQ__Contract__r.SBQQ__Quote__r.Rubiks_Quote__c FROM Entitlement WHERE (EndDate = TOMORROW OR EndDate = YESTERDAY)];
   
   // Process entitle list for grace period
   Set<Id> currentEntIdSet = new Set<Id>();  
   Map<Id,Id> OldEntIdWithNewEntId = new Map<Id,Id>();
   Date TOMORROW=system.Today()+1;
   Date YESTERDAY=system.Today()-1;
   for(Entitlement thisEnt :entitle){   
        
        currentEntIdSet.add(thisEnt.Id);
   }
   System.debug('currentEntIdSet***********' + currentEntIdSet);
   
   // Collect renewal entitlements into set futureEntIdSet
     Set<Id> futureEntIdSet = new Set<Id>();
   if(!currentEntIdSet.isEmpty()){
     for(Entitlement thisEnt :[SELECT Id,Processed_for_grace__c, Previous_Entitlement__c, Subscription_End_Date__c, EndDate,Subscription__r.SBQQ__Contract__r.SBQQ__Quote__r.Rubiks_Quote__c,Previous_Entitlement__r.EndDate FROM Entitlement where Previous_Entitlement__c IN :currentEntIdSet]){ 
            if( thisEnt.Previous_Entitlement__c!=null && thisEnt.Previous_Entitlement__r.EndDate==TOMORROW){    
             futureEntIdSet.add(thisEnt.Previous_Entitlement__c);
             }
             
             // prepared OldEntIdWithNewEntId map(Previous Entitlement, Current Entitlement)
             if(thisEnt.Previous_Entitlement__c!=null && thisEnt.Subscription__r!=null && thisEnt.Subscription__r.SBQQ__Contract__c!=null && thisEnt.Subscription__r.SBQQ__Contract__r.SBQQ__Quote__c!=null && thisEnt.Subscription__r.SBQQ__Contract__r.SBQQ__Quote__r.Rubiks_Quote__c==true && thisEnt.Previous_Entitlement__r.EndDate==YESTERDAY ){
                OldEntIdWithNewEntId.put(thisEnt.Previous_Entitlement__c,thisEnt.Id);
             }
     }
   }      
   System.debug('futureEntIdSet***********' + futureEntIdSet);
   
    if(entitle.size() == 0) return;
   List<Entitlement> updateEntList = new List<Entitlement>();
     for (Entitlement entitleGrace : entitle){
    // If renewal entitlement is created, don't process current entitlement for Grace Period, otherwise process for grace period.
     if(entitleGrace.Processed_for_grace__c==false && (!futureEntIdSet.isEmpty()) && !(futureEntIdSet.contains(entitleGrace.Id)) && entitleGrace.EndDate!=null && entitleGrace.EndDate == TOMORROW){  
       entitleGrace.Subscription_End_Date__c = entitleGrace.EndDate;
       entitleGrace.EndDate                  = entitleGrace.EndDate.addDays(60);
       entitleGrace.Processed_for_grace__c=true;
       updateEntList.add(entitleGrace);
    }else if(!futureEntIdSet.isEmpty() && futureEntIdSet.contains(entitleGrace.Id) && entitleGrace.EndDate!=null && entitleGrace.EndDate == TOMORROW){
      entitleGrace.Subscription_End_Date__c = entitleGrace.EndDate;
      entitleGrace.Processed_for_grace__c=false;
      updateEntList.add(entitleGrace);
    }
     }
   
   if(!updateEntList.isEmpty()){
     update updateEntList;
     System.debug('updated list updateEntList***********' + updateEntList);
   } 
   
   /* *****************************************************************************************
      Last Modified By: Jade Global Inc, On 9th May 2018
      Purpose         : Move Authorized Contact and Cases from Expired Entitlement to Active Entitlement 
    ***************************************************************************************** */

   if(!OldEntIdWithNewEntId.isEmpty()){
        SBQQSubscriptionTriggerHandler.MoveAuthorizedContactAndCases(OldEntIdWithNewEntId);
   }
  }
}


/*global class entitlementSubscriptionGrace implements Schedulable{
   global void execute(SchedulableContext SC) {    
     List<Entitlement> entitle = [SELECT Id, EndDate FROM Entitlement WHERE EndDate = TOMORROW AND Subscription_End_Date__c = NULL];
     if(entitle.size() == 0) return;
     for (Entitlement entitleGrace : entitle ){         
         entitleGrace.Subscription_End_Date__c = entitleGrace.EndDate;
         entitleGrace.EndDate                  = entitleGrace.EndDate.addDays(60);
     }
     update entitle;
  }
}*/