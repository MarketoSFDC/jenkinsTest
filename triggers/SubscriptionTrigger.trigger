trigger SubscriptionTrigger on SBQQ__Subscription__c (after insert) {
    VistaSubscriptionHandler handler = new VistaSubscriptionHandler(trigger.new);
}