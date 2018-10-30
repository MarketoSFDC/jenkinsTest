// test class form EWS module
@isTest(seeAlldata=true)
private class OneTimeBatchTestClass{
   
   
    static testMethod void eWSUtility(){
     
        List<Account> accounts = new List<Account>();
        accounts.add(new Account(Name = 'Unit Test Corp'));
        accounts.add(new Account(Name = 'Unit Test LLC'));
        accounts.add(new Account(Name = 'Parent Company Inc'));
        insert accounts;
        
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(AccountId = accounts[0].Id, FirstName = 'Tess', LastName = 'Dachshund'));
        contacts.add(new Contact(AccountId = accounts[0].Id, FirstName = 'Grachus', LastName = 'Dachshund'));
        contacts.add(new Contact(AccountId = accounts[1].Id, FirstName = 'Pete', LastName = 'Dachshund'));
        contacts.add(new Contact(AccountId = accounts[1].Id, FirstName = 'Alphonse', LastName = 'Dachshund'));
        contacts.add(new Contact(AccountId = accounts[1].Id, FirstName = 'Alphonse', LastName = 'Dachshund',NPS_Score__c=6));
        contacts.add(new Contact(AccountId = accounts[1].Id, FirstName = 'Alphonse', LastName = 'Dachshund',NPS_Score__c=9));
        insert contacts;
        
        List<EWS_Point_Table__c> ewsPointsList = new List<EWS_Point_Table__c>();
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'P2 Case',Type__c= 'Support',Driver__c='Relationship',Sub_Driver__c= 'P2 Case'));       
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'P1 Condition',Type__c= 'Support',Driver__c='Product Experience',Sub_Driver__c= 'P1 Condition'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Positive NPS',Type__c= 'CSM',Driver__c='Direct Communication',Sub_Driver__c= 'Positive NPS'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Half-Yearly Review',Type__c= 'Product',Driver__c='Product Experience',Sub_Driver__c= 'Product SitMan'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'New CSM',Type__c= 'CSM',Driver__c='Relationship',Sub_Driver__c= 'New CSM'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Temperature Change',Type__c= 'CSM',Driver__c='Relationship',Sub_Driver__c= 'Temperature Change'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Renewal Soon',Type__c= 'CSM',Driver__c='Relationship',Sub_Driver__c= 'Renewal Soon'));   
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'New NSE',Type__c= 'Support',Driver__c='Relationship',Sub_Driver__c= 'New NSE')); 
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'New Admin',Type__c= 'CSM',Driver__c='Relationship',Sub_Driver__c= 'New Admin'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'New Authorized Contact',Type__c= 'CSM',Driver__c='Relationship',Sub_Driver__c= 'New Authorized Contact'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Blacklist',Type__c= 'Support',Driver__c='Product Experience',Sub_Driver__c= 'Blacklist'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'CSATs with entry of "Product"',Type__c= 'Product',Driver__c='Product Experience',Sub_Driver__c= 'Product SitMan'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Sitman with Entry "Product"',Type__c= 'Product',Driver__c='Product Experience',Sub_Driver__c= 'Product SitMan'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Case Closed "Reffered to Ideas"',Type__c= 'Product',Driver__c='Product Experience',Sub_Driver__c= 'Product Support Case'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Sitman Filled',Type__c= 'Support',Driver__c='Direct Communication',Sub_Driver__c= 'Sitman Filled'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Positive CSAT',Type__c= 'Support',Driver__c='Direct Communication',Sub_Driver__c= 'Positive CSAT'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Negative CSAT',Type__c= 'Support',Driver__c='Direct Communication',Sub_Driver__c= 'Negative CSAT'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Negative NPS',Type__c= 'CSM',Driver__c='Direct Communication',Sub_Driver__c= 'Negative NPS'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Escalated to SME',Type__c= 'Support',Driver__c='Case Handling',Sub_Driver__c= 'Escalated to SME'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Escalated to Engineering',Type__c= 'Support',Driver__c='Case Handling',Sub_Driver__c= 'Escalated to Engineering'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Excessive (2+) Reopens',Type__c= 'Support',Driver__c='Case Handling',Sub_Driver__c= 'Excessive Reopens'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Aging: 10 days',Type__c= 'Support',Driver__c='Time to Resolution',Sub_Driver__c= 'Aging: 10 days'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Aging: 30 days',Type__c= 'Support',Driver__c='Time to Resolution',Sub_Driver__c= 'Aging: 30 days'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Aging: 60 days',Type__c= 'Support',Driver__c='Time to Resolution',Sub_Driver__c= 'Aging: 60 days'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Aging: 100 days',Type__c= 'Support',Driver__c='Time to Resolution',Sub_Driver__c= 'Aging: 100 days'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Inactivity: Low Logins',Type__c= 'CSM',Driver__c='Usage',Sub_Driver__c= 'Inactivity: Logins'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Inactivity: Low Email sends',Type__c= 'CSM',Driver__c='Usage',Sub_Driver__c= 'Low Email Sends'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Case Opened: Volatile Subject',Type__c= 'CSM',Driver__c='Usage',Sub_Driver__c= 'Case Opened: Volatile Subject'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Mentor Session',Type__c= 'Support',Driver__c='Service Consumed',Sub_Driver__c= 'Mentor Session'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Half-Yearly Review',Type__c= 'Support',Driver__c='Service Consumed',Sub_Driver__c= 'Half-Yearly Review'));
        ewsPointsList.add(new EWS_Point_Table__c(Activate__c= True,Points__c = 123,Name = 'Renewed',Type__c= 'CSM',Driver__c='Service Consumed',Sub_Driver__c= 'Renewed'));
        insert ewsPointsList;
        
        insert new Activities__c(EWS_Point__c=ewsPointsList[0].Id,Account__c='0015000000fD2sO',Description__c='A score of 5 Was filed for Case - 00741863');
        new EWSActivityOneTimeBatchContact();
        new EWSActivityOneTimeBatchCase();
        new EWSActivityOneTimeBatchAuthContacts();
        new EWSActivityOneTimeBatchEntitlements();
        Database.QueryLocator QL;
        Database.BatchableContext BC;
        List<Activities__c> AcctList = new List<Activities__c>();
        EWSActivityOneTimeBatchAccount AU = new EWSActivityOneTimeBatchAccount('select Id,Description__c,Case_Number__c FROM Activities__c WHERE Case_Number__c = NULL limit 200');
        QL = AU.start(bc);
        
        Database.QueryLocatorIterator QIT =  QL.iterator();
        while (QIT.hasNext())
        {
            Activities__c Acc = (Activities__c)QIT.next();            
            System.debug(Acc);
            AcctList.add(Acc);
        }        
        
        AU.execute(BC, AcctList);
        AU.finish(BC); 
      //  database.executeBatch(new EWSActivityOneTimeBatchAccount());
        new EWSActivityOneTimeBatchCSatSurvey();
        
          
    }  
}