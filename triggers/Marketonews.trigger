trigger Marketonews on Marketo_News__c (after insert,after update) {
    if(Trigger.Isinsert || Trigger.Isupdate) {
        Set<Id> ids = new Set<Id>();
        Set<Id> idsForPod = new Set<Id>();
        for (Marketo_News__c  news: Trigger.new) {
            if(news.Active__c == true) {
                if(news.Pod__c != null) {
                    idsForPod.add(news.Id);
                } else {
                    ids.add(news.Id);
                }
            }
        }        
        if(!ids.isEmpty()) {       
            EmailNewsAndAlerts.sendReplyNotifications(ids);            
        }
        if(!idsForPod.isEmpty()) {
            EmailNewsAndAlerts myPodAlerts = new EmailNewsAndAlerts();       
            myPodAlerts.sendPodAlertNotifications(idsForPod);            
        }        
    }
}