global class GainsightUserGroupBatch implements Database.Batchable<sObject>, Database.Stateful
{
    global final String Query;

    //Constructor to populate features for one Account
    global GainsightUserGroupBatch(string pAccountId)
    {
        Query = 'SELECT JBCXM__Account__c FROM JBCXM__CustomerInfo__c WHERE JBCXM__Account__c = \'' + pAccountId + '\'';
    }

    //Constructor to populate features for all Account
    global GainsightUserGroupBatch()
    {
        Query = 'SELECT JBCXM__Account__c FROM JBCXM__CustomerInfo__c';
    }

    global void execute(SchedulableContext SC) 
    {
        database.executebatch(new GainsightUserGroupBatch(),1);
    }
      
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<JBCXM__CustomerInfo__c> scope) 
    {
        
        Set<Id> AccountIdSet = new Set<Id>();
        Map<String,JBCXM__CustomerInfo__c> CustomersToUpdate = new Map<String,JBCXM__CustomerInfo__c>();
        Map<String,String> MilestoneTypeMap = new Map<String,String>();
        Map<String,CampaignMember> CampaignMemberMap = new Map<String,CampaignMember>();
        List<JBCXM__Milestone__c> MilestonesToInsert = new List<JBCXM__Milestone__c>();

        Map<String,List<Contact>> AccountContactMap = new Map<String,List<Contact>>();
        Map<String,Map<String,JBCXM__Milestone__c>> CurrentMilestonesMap = new Map<String,Map<String,JBCXM__Milestone__c>>();

        // Populate Milestone Type Map
        for (JBCXM__PickList__c PL : [SELECT Id,JBCXM__SystemName__c,JBCXM__Category__c FROM JBCXM__PickList__c WHERE JBCXM__Category__c = 'Milestones' AND JBCXM__SystemName__c = 'User Group'])
        {
            MilestoneTypeMap.put(PL.JBCXM__SystemName__c,PL.Id);    
        }

        // Populate Account ID Set
        for (JBCXM__CustomerInfo__c CI : scope) 
        {
            AccountIdSet.add(CI.JBCXM__Account__c);
        }

        // Query all Contacts under previous Accounts
        for (Contact C : [SELECT Id, AccountId, Name FROM Contact WHERE AccountId IN :AccountIdSet])
        {
            List<Contact> TempList = new List<Contact>();

            if (AccountContactMap.containsKey(C.AccountId)) TempList = AccountContactMap.get(C.AccountId);
            TempList.add(C);
            AccountContactMap.put(C.AccountId,TempList);
        }

        // Query current Milestones and add them to the Current Milestones map
        for (JBCXM__Milestone__c MS : [SELECT Id,JBCXM__Account__c,JBCXM__Comment__c,JBCXM__Date__c FROM JBCXM__Milestone__c WHERE JBCXM__Account__c IN :AccountIdSet])
        {
            Map<String,JBCXM__Milestone__c> TempMap = new Map<String,JBCXM__Milestone__c>();
            
            if (CurrentMilestonesMap.containsKey(MS.JBCXM__Account__c)) TempMap = CurrentMilestonesMap.get(MS.JBCXM__Account__c);
            System.Debug('Key 1 : ' + MS.JBCXM__Comment__c + '~' + MS.JBCXM__Date__c.format('M/d/yyyy'));
            
            TempMap.put(MS.JBCXM__Comment__c + '~' + MS.JBCXM__Date__c.format('M/d/yyyy'),MS);
            CurrentMilestonesMap.put(MS.JBCXM__Account__c,TempMap);
        }

        // Query all Campaign Members
        for (CampaignMember CM : [SELECT Id, ContactId, Contact.Name, Contact.AccountId, Campaign.StartDate FROM CampaignMember WHERE Contact.AccountId IN :AccountIdSet AND ContactId != null AND Campaign.Name LIKE '%User Group Attendees%' AND Status = 'Attended' AND Campaign.StartDate != null])
        {
            CampaignMemberMap.put(CM.Contact.Name + '~' + CM.Contact.AccountId,CM);
        }

        // Create new Milestones
        for (JBCXM__CustomerInfo__c CI : scope)
        {
            if (AccountContactMap.containsKey(CI.JBCXM__Account__c))
            {
                List<Contact> ContactList = AccountContactMap.get(CI.JBCXM__Account__c);
                Map<String,JBCXM__Milestone__c> MilestoneMap = CurrentMilestonesMap.get(CI.JBCXM__Account__c);

                for (Contact C : ContactList)
                {
                    if (CampaignMemberMap.containsKey(C.Name + '~' + C.AccountId))
                    {
                        CampaignMember TempCM = CampaignMemberMap.get(C.Name + '~' + C.AccountId);
                        String Comment = C.Name + ' - Attended User Group';

                        if (TempCM.Campaign.StartDate != null && !MilestoneMap.containsKey(Comment + '~' + String.valueOf(TempCM.Campaign.StartDate.format())))
                        {
                            JBCXM__Milestone__c NewMS = new JBCXM__Milestone__c(
                                JBCXM__Comment__c   = Comment,
                                JBCXM__Milestone__c = MilestoneTypeMap.get('User Group'),
                                JBCXM__Date__c      = DateTime.newInstance(TempCM.Campaign.StartDate.Year(), TempCM.Campaign.StartDate.Month(), TempCM.Campaign.StartDate.Day()),
                                JBCXM__Account__c   = CI.JBCXM__Account__c
                                );

                            MilestonesToInsert.add(NewMS);
                        }
                    }
                }
            }
        }

        // Insert Milestones
        if (!MilestonesToInsert.isEmpty()) insert MilestonesToInsert;
    }

    global void finish(Database.BatchableContext BC)
    { 
        
    } 
}