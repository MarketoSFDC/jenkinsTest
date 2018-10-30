public class NewsAlertTemplatecontroller {
    Public String type{get;set;}
    public NewsAlertTemplatecontroller () {
        Set<Id> NewsandALerts = EmailNewsAndAlerts.newsset;
        List<Marketo_News__c> News = [select Id,Description__c,Type__c,Publish_Date__c,Name from Marketo_News__c 
                      where Id IN: NewsandALerts AND active__c = true AND (Type__c = 'News' OR Type__c ='Alert')]; 
        for(Marketo_News__c newsalert :News){
            type = newsalert.type__c;    
        }       
    }
    
    @isTest
    public static void testMethod1()
    {
        NewsAlertTemplatecontroller  testCntl = new NewsAlertTemplatecontroller ();
    
    }
   

    
}