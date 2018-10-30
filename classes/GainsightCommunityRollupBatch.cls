global class GainsightCommunityRollupBatch implements Database.Batchable<sObject>
{
    static testMethod void GainsightCommunityRollupBatchTest() 
    {
        Account A = new Account(Name='Test');
        insert A;

        JBCXM__PickList__c PL = new JBCXM__PickList__c(JBCXM__Active__c=true,JBCXM__Category__c='Customer Status',JBCXM__SystemName__c='ActiveCustomer',Name='Active');
        insert PL;

        JBCXM__CustomerInfo__c CI = new JBCXM__CustomerInfo__c(JBCXM__Account__c=A.Id,JBCXM__ASV__c=0,JBCXM__MRR__c=0,JBCXM__Status__c=PL.Id);
        insert CI; 

        Test.startTest();
        database.executebatch(new GainsightCommunityRollupBatch(Date.Today(),A.Id),1);
        Test.stopTest();

        database.executebatch(new GainsightCommunityRollupBatch(Date.Today()),1);
        database.executebatch(new GainsightCommunityRollupBatch(),1);
    }

    //Date D = date.parse('12/30/2012');
    //database.executebatch(new GainsightCommunityRollupBatch(D,'0015000000aWhIBAA0'),1);

    global final DateTime StartOfWeek;
    global final DateTime EndOfWeek;
    global final String Query;

    //Constructor to run one Account for one week
    global GainsightCommunityRollupBatch(Date pStartOfWeek, String pAccountId)
    {
        StartOfWeek = datetime.newInstance(pStartOfWeek.year(), pStartOfWeek.month(), pStartOfWeek.day(), 0, 0, 0);
        EndOfWeek = datetime.newInstance(pStartOfWeek.addDays(6).year(), pStartOfWeek.addDays(6).month(), pStartOfWeek.addDays(6).day(), 23, 59, 59);
        Query = 'SELECT JBCXM__Account__c FROM JBCXM__CustomerInfo__c WHERE JBCXM__Account__c=\'' + pAccountId + '\'';
    }

    //Constructor to run all Accounts for one week
    global GainsightCommunityRollupBatch(Date pStartOfWeek)
    {
        StartOfWeek = datetime.newInstance(pStartOfWeek.year(), pStartOfWeek.month(), pStartOfWeek.day(), 0, 0, 0);
        EndOfWeek = datetime.newInstance(pStartOfWeek.addDays(6).year(), pStartOfWeek.addDays(6).month(), pStartOfWeek.addDays(6).day(), 23, 59, 59);
        Query = 'SELECT JBCXM__Account__c FROM JBCXM__CustomerInfo__c';
    }

    //Constructor to run all Accounts for the current week
    global GainsightCommunityRollupBatch()
    {
        StartOfWeek = datetime.newInstance(Date.Today().addDays(-7).year(), Date.Today().addDays(-7).month(), Date.Today().addDays(-7).day(), 0, 0, 0);
        EndOfWeek = datetime.newInstance(Date.Today().addDays(6).year(), Date.Today().addDays(6).month(), Date.Today().addDays(6).day(), 23, 59, 59);
        Query = 'SELECT JBCXM__Account__c FROM JBCXM__CustomerInfo__c';
    }

    global void execute(SchedulableContext SC) 
    {
        database.executebatch(new GainsightCommunityRollupBatch(),1);
    }
      
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<JBCXM__CustomerInfo__c> scope)
    {
        for(JBCXM__CustomerInfo__c CI : scope)
        {
            //Initialize Community rollups
            Integer IdeaCommentCount = 0;
            Integer IdeaCount = 0;
            Integer QuestionCommentCount = 0;
            Integer QuestionCount = 0;
            Integer LoginCount = 0;
            Integer UniqueLoginCount = 0;
            Integer TotalUsers = 0;
            Integer TrueLoginPercent = 0;

            //Get Community Activities by a single account for the week
           /* for(Community_Activity__c CA : [SELECT Type__c FROM Community_Activity__c WHERE Contact__r.AccountId=:CI.JBCXM__Account__c AND Posted_Date__c>=:StartOfWeek AND Posted_Date__c<=:EndOfWeek])
            {
                if(CA.Type__c == 'QuestionComment')
                {
                    QuestionCommentCount++;
                }
                else if(CA.Type__c == 'Question')
                {
                    QuestionCount++;
                }
                else if(CA.Type__c == 'Idea')
                {
                    IdeaCount++;
                }
                else if(CA.Type__c == 'IdeaComment')
                {
                    IdeaCommentCount++;
                }
            }
			*/

            //Get Total User count by querying related Contacts that are flagged as a Portal User
            Set<Id> PortalUsers = new Set<Id>();

            for(User U : [SELECT Id FROM User WHERE Contact.AccountId=:CI.JBCXM__Account__c AND Contact.Customer_Portal_User__c = true])
            {
                PortalUsers.add(U.Id);  
            }

            //TotalUsers = PortalUsers.size();
            
            Set<Id> LoggedInPortalUsers = new Set<Id>();

            //Query LoginHistory to get count of Users who logged in during the week
            for(LoginHistory LH : [SELECT UserId,Status FROM LoginHistory WHERE UserId IN :PortalUsers AND LoginTime>=:StartOfWeek AND LoginTime<=:EndOfWeek])
            {
                if(LH.Status == 'Success')
                {
                    LoginCount++;
                    LoggedInPortalUsers.add(LH.UserId);
                } 
            }

            UniqueLoginCount = LoggedInPortalUsers.size();
            
            //Calculate True Login Percentage
            //TrueLoginPercent = (LoginCount / TotalUsers) * 100;         

            /*
            String[] ToAddress = new String[]{'rbegley@gainsight.com'};
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setSubject('GainsightCommunityRollupBatch');
            mail.setToAddresses(ToAddress);
            mail.setHtmlBody('Rollups from ' + StartOfWeek.format() + ' to ' + EndOfWeek.format() + '<br><br>' +
                                  'Query: ' + Query + '<br>' +
                                  'IdeaCommentCount: ' + IdeaCommentCount + '<br>' +
                                  'IdeaCount: ' + IdeaCount + '<br>' +
                                  'QuestionCommentCount: ' + QuestionCommentCount + '<br>' +
                                  'QuestionCount: ' + QuestionCount + '<br>' +
                                  'LoginCount: ' + LoginCount + '<br>' +
                                  'TotalUsers: ' + TotalUsers + '<br>' +
                                  'TrueLoginPercent: ' + TrueLoginPercent + '<br>');
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
            */
            
            JBCXM__UsageData__c UD = new JBCXM__UsageData__c(JBCXM__Account__c = CI.JBCXM__Account__c,
                                                             Name = 'ACCOUNTLEVEL',
                                                             JBCXM__Date__c = StartOfWeek.date(),
                                                             CommunityIdea__c = IdeaCount,
                                                             CommunityIdeaComment__c = IdeaCommentCount,
                                                             CommunityQuestion__c = QuestionCount,
                                                             CommunityQuestionComment__c = QuestionCommentCount,
                                                             CommunityLogins__c = LoginCount);

            insert UD;
        }  
    }

    global void finish(Database.BatchableContext BC)
    { 
        
    }                  
}