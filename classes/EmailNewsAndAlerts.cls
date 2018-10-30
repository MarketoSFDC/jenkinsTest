public with sharing Class EmailNewsAndAlerts {   
    
    //private static Id FROM_EMAIL_ID = [select Id from OrgWideEmailAddress where DisplayName = 'Marketo Community'].Id;
    private static Id FROM_EMAIL_ID {
        get {
            if(FROM_EMAIL_ID == null ){
                Id tmpID =  [select Id from OrgWideEmailAddress where DisplayName = 'Marketo Community'].Id;
                FROM_EMAIL_ID = tmpID ;
            }
            return FROM_EMAIL_ID;
        }
    }     
    public Static set<Id> newsset = new Set<id>();
      
    //new functionality, set pod list for each support alert id.
    public static List<Marketo_News__c> Marketo_News = new List<Marketo_News__c>();
    
    public static void sendEmailDebug(List<Messaging.SingleEmailMessage> emails) {    
        //System.debug('Testing Emails==>'+emails);        
        try
        {                      
            Messaging.SendEmailResult[] resultMail = Messaging.sendEmail(emails);          
            LIST<Messaging.SendEmailError> emailErrors ;//
            if(resultMail != null && resultMail.size() > 0){
                emailErrors = resultMail[0].getErrors();
                System.debug('Testing Emails1==>'+emailErrors);
            }
            String response;
            if(resultMail != null && resultMail.size() > 0 && resultMail[0].isSuccess()) {
                response = 'ok sent!';
                System.debug('Testing Emails2==>');
            }
            else {
                System.debug('Testing Emails3==>');
                if(resultMail != null && resultMail.size() > 0)
                    response = resultMail[0].getErrors().get(0).getMessage();
            }                        
        } 
        catch(System.EmailException ex) {
            System.debug('Exception==>' + ex);
        } 
    }
     
    public static void sendReplyNotifications(Set<Id> NewsIds) {    

        Id templateId = [select Id from EmailTemplate where DeveloperName = 'Marketo_Community_All_News'].Id;
        Id templateIdAlert = [select Id from EmailTemplate where DeveloperName = 'Marketo_Community_All_Alerts'].Id;    

        List<Marketo_News__c> News = [select Id,Description__c,Name,POD__c,Type__c  from Marketo_News__c where Id in :NewsIds AND active__c = true and (Type__c = 'News' OR Type__c ='Alert')];               
        for(Marketo_News__c mktNews : News) {
            newsset.add(mktNews.Id);               
        }        
                
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        //List<Community_Subscription__c> subscriptions = [select Id,User__c,Type__c,User__r.IsActive from Community_Subscription__c where (NOT User__r.Email like '%.staging') and Type__c ='News and Alerts' and User__r.IsActive = true];             
        List<Community_Subscription__c> subscriptions = [select Id,User__c,Type__c,User__r.IsActive from Community_Subscription__c where Type__c ='News and Alerts' and User__r.IsActive = true];             
        
        //Added By bikram for partners and internal marketo users. Do not directly mail to contacts, use contact's user ids to mail
        //List<Contact> partnerContacts = [select Id,Email , Account.Id From Contact where (Not Email like '%.fullcopy') AND Email != NULL AND ((Account.ID in ('0015000000Xu1KcAAJ','0015000000Xu5OnAAJ')) OR (Account.Type = 'partner' and Account.Partner_Type__c = 'Preferred Services')) ];
        //emails.addAll(createEmails(templateIdAlert, MarketoNews.Id,partnerContacts));
        //Ends                                 

        for( Marketo_News__c MarketoNews: News ) {
            if(MarketoNews.Type__c == 'Alert') {
                emails.addAll(createEmails(templateIdAlert, MarketoNews.Id,subscriptions));
            } else {
                emails.addAll(createEmails(templateId, MarketoNews.Id,subscriptions));
            }
        }
        sendEmailDebug(emails);        
    }
     
    public static List<Messaging.SingleEmailMessage> createEmails(Id templateId, Id whatId, List<Community_Subscription__c> subscriptions) {
        List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        for (Community_Subscription__c subscription : subscriptions) {            
            emails.add(createEmail(templateId, whatId, subscription));            
        }      
        return emails;
    }
    public static Messaging.SingleEmailMessage createEmail(Id templateId, Id whatId, Community_Subscription__c subscription) {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        email.setTemplateId(templateId);
        email.setTargetObjectId(subscription.User__c);
        email.setWhatId(whatId);
        email.setSaveAsActivity(false);
        email.setOrgWideEmailAddressId(FROM_EMAIL_ID);        
        return email;
    }
    
    //New function to send only POD users the Alerts eventum issue no 3620 
    //Feb 27 2013
    public void sendPodAlertNotifications(Set<Id> AlertIds) {    
    
        System.Debug('AlertIds=>' + AlertIds);
        List<Marketo_News__c> News = [select Id,Description__c,Name,Type__c,POD__c from Marketo_News__c where Id in :AlertIds AND Active__c = true and (Type__c = 'News' OR Type__c ='Alert')];               
        
        Id templateId = [select Id from EmailTemplate where DeveloperName = 'Marketo_Community_All_News'].Id;
        Id templateIdAlert = [select Id from EmailTemplate where DeveloperName = 'Marketo_Community_All_Alerts'].Id;    

        map<id,set<string>> alertsId_PodMap = new map <id,set<string>>();       
        //27 Feb, POD field added in query        
        //Name=Test POD Alerts, POD__c=POD-A;POD-B;POD-CS, CurrencyIsoCode=USD, Id=a5PW00000004CNjMAM        
        //List<Contact> partnerContacts = [select Id,Email , Account.Id From Contact where (Not Email like '%.fullcopy') AND Email != NULL AND ((Account.ID in ('0015000000Xu1KcAAJ','0015000000Xu5OnAAJ')) OR (Account.Type = 'partner' and Account.Partner_Type__c = 'Preferred Services')) ];
        //System.debug('partnerContacts==> ' + partnerContacts );
            
        Set<String> validPods = new Set<String>();

        for(Marketo_News__c mktNews : News) {            
            Marketo_News.add(mktNews);
            if(mktNews.Type__c == 'Alert') {
                if(mktNews.POD__c != null && mktNews.POD__c != '') {                
                    alertsId_PodMap.put(mktNews.Id, new set<string>(mktNews.POD__c.split(';')));  
                    validPods.addAll(mktNews.POD__c.split(';'));                                  
                }                         
            }            
        }
        System.Debug('alertsId_PodMap=>' + alertsId_PodMap);        

        //Get list of all subscribed users  for news and alerts
        //List<Community_Subscription__c> subscriptions = [select Id,User__c,Type__c,User__r.IsActive, User__r.Munchkin_Id__c from Community_Subscription__c where Type__c ='News and Alerts' and User__r.IsActive = true AND (Not( User__r.Email like '%.staging' ))  ];
        List<Community_Subscription__c> subscriptions = [select Id,User__c,Type__c,User__r.IsActive, User__r.Munchkin_Id__c from Community_Subscription__c where Type__c ='News and Alerts' and User__r.IsActive = true ];

        System.Debug('subscriptions=>' + subscriptions );

        //5735 Get list of all pods and assets for the alert to grab munchkinid
        //List<Asset> podAssetLstTmp = new List<Asset>([SELECT ID, Pod__c, Munchkin_ID__c from Asset Where Pod__c in : validPods and Status = 'Active' and Munchkin_ID__c != null and Asset_Type__c = 'Subscription']);
        Map<String,Set<String>> podToAssetMnckinId = new Map<String,Set<String>>();
        Map<String,String> mnckinIdToPod = new Map<String,String>();
        
        for (Asset ast: [SELECT ID, Pod__c, Munchkin_ID__c from Asset Where Pod__c in : validPods and Status = 'Active' and Munchkin_ID__c != null and Asset_Type__c = 'Subscription']) {
            mnckinIdToPod.put(ast.Munchkin_ID__c, ast.Pod__c);
            if(podToAssetMnckinId.containsKey(ast.Pod__c)) {
                podToAssetMnckinId.get(ast.Pod__c).add(ast.Munchkin_ID__c); 
            } else {
                podToAssetMnckinId.put(ast.POD__c,new set<String>{ast.Munchkin_ID__c});             
            }                   
        }                
        
        //Save Podname => Subscription Map
        Map<String,Set<Community_Subscription__c>> podToSubscriptionMap = new Map<String,Set<Community_Subscription__c>>();        
                
        if(subscriptions.isEmpty() == false)
        {
            List<Messaging.SingleEmailMessage> emails = new List<Messaging.SingleEmailMessage>();
        
            for (Community_Subscription__c subscription:subscriptions) {
                // If subscription.User__r.Munchkin_Id__c   
                if(mnckinIdToPod.containsKey(subscription.User__r.Munchkin_Id__c)) {                
                    if(podToSubscriptionMap.containsKey(mnckinIdToPod.get(subscription.User__r.Munchkin_Id__c)))
                        podToSubscriptionMap.get(mnckinIdToPod.get(subscription.User__r.Munchkin_Id__c)).add(subscription);                                        
                    else
                        podToSubscriptionMap.put(mnckinIdToPod.get(subscription.User__r.Munchkin_Id__c),new set<Community_Subscription__c>{subscription});            
                }
            }                        
            System.Debug('podToSubscriptionMap=>' + podToSubscriptionMap);

            for(Marketo_News__c MarketoNews: News) {
                newsset.add(MarketoNews.Id); 
                if(MarketoNews.Type__c != 'Alert') { //If Not an Alert no pod specific item applicable
                    emails.addAll(createEmails(templateId, MarketoNews.Id,subscriptions));                 
                } else { //If Alert 
                    if(alertsId_PodMap.containsKey(MarketoNews.Id)) {//If POD selected                     
                        List<Community_Subscription__c> mySubList = new List<Community_Subscription__c>();
                        for(string tmpPodname : alertsId_PodMap.get(MarketoNews.Id)) {
                            //If pod named map exists for subscriptionsMap
                            if(podToSubscriptionMap.containsKey(tmpPodname)){                                
                                mySubList.addAll(podToSubscriptionMap.get(tmpPodname));    
                            }
                        }
                        if(mySubList.isEmpty() == false) {                                                                  
                            emails.addAll(createEmails(templateIdAlert, MarketoNews.Id,mySubList));
                            //emails.addAll(createEmails(templateIdAlert, MarketoNews.Id,partnerContacts));                                                        
                            System.Debug('mySubList=>' + mySubList);
                        } else {
                            System.Debug('Empty mySubList=>' + mySubList);                        
                        }
                    } else { //If No POD selected
                        emails.addAll(createEmails(templateIdAlert, MarketoNews.Id,subscriptions));                        
                    } 
                } 
            }           
            System.debug('Testing Emails Size==>'+emails.size());                    
            sendEmailDebug(emails);                                                
        }
    }

    public Static testmethod void testNewsalertsCtrl(){       
        EmailNewsAndAlerts NewsAlerts = new EmailNewsAndAlerts();
        List<EmailTemplate> listEmTemplates = [select Id from EmailTemplate limit 1];
        List<Community_Subscription__c> subscriptions = new List<Community_Subscription__c>();
        Community_Subscription__c commSub = new Community_Subscription__c();      
        commSub.user__c = UserInfo.getUserId();
        commSub.type__c = 'News and Alerts';
        subscriptions.add(commSub);
        Community_Subscription__c commSub1 = new Community_Subscription__c();
        commSub1.user__c = UserInfo.getUserId();
        commSub1.type__c = 'News and Alerts';
        subscriptions.add(commSub1);
        insert subscriptions;       
        Marketo_News__c NewsAlertsinsert = new Marketo_News__c(Name ='Testing',Type__c = 'News',active__c = true);
        insert NewsAlertsinsert ;       

        /*Marketo_News__c NewsAlertsinsert1 = new Marketo_News__c(Name ='Testing1',Type__c = 'Alert',active__c = true);
        insert NewsAlertsinsert1 ;       
        Marketo_News__c NewsAlertsinsert2 = new Marketo_News__c(Name ='Testing1',Type__c = 'Alert',POD__c = 'POD-A',active__c = true);
        insert NewsAlertsinsert2;       
        */

        List<Marketo_News__c> News = [select Id,Description__c,Name from Marketo_News__c where active__c = true And (Type__c = 'News' OR Type__c ='Alert')];       
        ID NewsID;
        for(Marketo_News__c MarketoNews: News) {  
            NewsID = MarketoNews.Id;
        }           
        if(listEmTemplates.size() > 0){
            EmailNewsAndAlerts.createEmails(listEmTemplates.get(0).Id,NewsAlertsinsert.ID, subscriptions);
            EmailNewsAndAlerts.createEmail(listEmTemplates.get(0).Id,commSub.Id,commSub);
        }
        NewsAlertsinsert.Type__c ='Alert';
        update NewsAlertsinsert;        

        NewsAlertsinsert.POD__c ='POD-A';
        update NewsAlertsinsert;        
        
    }  
}