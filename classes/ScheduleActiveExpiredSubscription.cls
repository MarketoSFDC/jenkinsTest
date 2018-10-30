global class ScheduleActiveExpiredSubscription implements Schedulable {
 
   global void execute(SchedulableContext SC) {
       
      List<SBQQ__Subscription__c> targetSubscription = new List<SBQQ__Subscription__c>();
      for(SBQQ__Subscription__c sbq : [Select ID, SBQQ__Contract__c, SBQQ__EndDate__c, SBQQ__StartDate__c, SBQQ__Account__r.ID, SBQQ__Product__c, SBQQ__Product__r.Name, SBQQ__Product__r.MA_or_RTP__c, SBQQ__Product__r.Family, SBQQ__Product__r.Visible_To_Customer__c FROM SBQQ__Subscription__c WHERE SBQQ__Product__r.Visible_To_Customer__c = True AND (SBQQ__EndDate__c = Yesterday OR SBQQ__StartDate__c = Today) AND LastModifiedDate != Today  Limit 25000]) {
          targetSubscription.add(sbq);
      }
      if(!targetSubscription.isEmpty()){
          update targetSubscription;
      }
   }
}