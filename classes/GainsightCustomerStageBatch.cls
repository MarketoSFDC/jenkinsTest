global class GainsightCustomerStageBatch implements Database.Batchable<sObject>, Database.Stateful
{
    global final String Query;

    //Constructor to populate features for one Account
    global GainsightCustomerStageBatch(string pAccountId)
    {
        Query = 'SELECT JBCXM__Account__c FROM JBCXM__CustomerInfo__c WHERE JBCXM__Account__c = \'' + pAccountId + '\'';
    }

    //Constructor to populate features for all Account
    global GainsightCustomerStageBatch()
    {
        Query = 'SELECT JBCXM__Account__c FROM JBCXM__CustomerInfo__c';
    }

    global void execute(SchedulableContext SC) 
    {
        database.executebatch(new GainsightCustomerStageBatch(),1);
    }
      
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<JBCXM__CustomerInfo__c> scope)
    {
        Set<Id> AccountIdSet = new Set<Id>();
        Map<String, JBCXM__CustomerInfo__c> CustomersToUpdate = new Map<String, JBCXM__CustomerInfo__c>();
        Map<String, String> MilestoneTypeMap = new Map<String, String>();
        Map<String, String> CustomerStageMap = new Map<String, String>();
        Set<String> NeededSystemNames = new Set<String>{'Proj Start','Proj Compl'};

        for(JBCXM__PickList__c PL : [SELECT Id,JBCXM__SystemName__c,JBCXM__Category__c FROM JBCXM__PickList__c WHERE JBCXM__Category__c = 'Customer Stage' OR (JBCXM__Category__c = 'Milestones' AND JBCXM__SystemName__c IN :NeededSystemNames )])
        {
        	if(PL.JBCXM__Category__c == 'Milestones')
        	{
        		MilestoneTypeMap.put(PL.JBCXM__SystemName__c,PL.Id);	
        	}
        	else if(PL.JBCXM__Category__c == 'Customer Stage')
        	{
        		CustomerStageMap.put(PL.JBCXM__SystemName__c,PL.Id);
        	}
        }

        //Get Account Ids and reset Stages to New Business
        for (JBCXM__CustomerInfo__c CI : scope)
        {
        	AccountIdSet.add(CI.JBCXM__Account__c);
        	CI.JBCXM__Stage__c = CustomerStageMap.get('stage1');
        	CustomersToUpdate.put(CI.JBCXM__Account__c,CI);
        }

        for(JBCXM__Milestone__c MS : [SELECT Id,JBCXM__Milestone__r.JBCXM__SystemName__c,JBCXM__Account__c FROM JBCXM__Milestone__c WHERE JBCXM__Account__c IN :AccountIdSet AND JBCXM__Milestone__r.JBCXM__SystemName__c IN :MilestoneTypeMap.keySet()])
        {
        	if(CustomersToUpdate.containsKey(MS.JBCXM__Account__c))
        	{
        		JBCXM__CustomerInfo__c CI = CustomersToUpdate.get(MS.JBCXM__Account__c);
        		
        		if(MS.JBCXM__Milestone__r.JBCXM__SystemName__c == 'Proj Start')
        		{
        			if(CI.JBCXM__Stage__c != CustomerStageMap.get('stage3'))
        			{
        				CI.JBCXM__Stage__c = CustomerStageMap.get('stage2');
        			}
        		}
        		else if(MS.JBCXM__Milestone__r.JBCXM__SystemName__c == 'Proj Compl')
        		{
        			CI.JBCXM__Stage__c = CustomerStageMap.get('stage3');	
        		}

        		CustomersToUpdate.put(MS.JBCXM__Account__c,CI);		
        	}
        }

        for(Opportunity Opp : [SELECT Id,AccountId FROM Opportunity WHERE StageName = 'Closed Won' AND Type = 'Renewal' AND AccountId IN :AccountIdSet])
        {
        	if(CustomersToUpdate.containsKey(Opp.AccountId))
        	{
        		JBCXM__CustomerInfo__c CI = CustomersToUpdate.get(Opp.AccountId);
        		
        		CI.JBCXM__Stage__c = CustomerStageMap.get('stage4');	
        		
        		CustomersToUpdate.put(CI.JBCXM__Account__c,CI);		
        	}	
        }

        if(CustomersToUpdate.values().size() > 0) update CustomersToUpdate.values();
    }

    global void finish(Database.BatchableContext BC)
    { 
        
    }                  
}