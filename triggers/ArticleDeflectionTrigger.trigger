trigger ArticleDeflectionTrigger on Article_Deflection__c (after insert, before insert) {
   
    if(Trigger.isAfter && Trigger.isInsert){
        if(system.isBatch() == false && system.Isfuture() == false){
            ArticleDeflectionTriggerClass.makeCallout(Trigger.newMap.keySet());
        } 
    }
    if(Trigger.isBefore && Trigger.isInsert){
        for(Article_Deflection__c ac : Trigger.New){
            String article = String.valueOf(ac.Article_ID__c);
            if(ac.Article_ID__c!= null && ac.Article_ID__c != ''){
               if(article .Contains('yes')){
                   ac.Article_ID__c = article.replaceAll('yes-','');
                   ac.isArticleHelpful__c = true;
               }
               if(article.Contains('no')){
                   ac.Article_ID__c = article.replaceAll('no-','');
                   ac.isArticleHelpful__c = false;
               }  
            }
            if(ac.Customer_Response_For_Yes__c != null && ac.Customer_Response_For_Yes__c != ''){
                ac.Custom_Response__c = ac.Customer_Response_For_Yes__c;
            }
            else if(ac.Customer_Response_For_No__c != null && ac.Customer_Response_For_No__c != ''){
                ac.Custom_Response__c = ac.Customer_Response_For_No__c;
            }
        }
    }
}