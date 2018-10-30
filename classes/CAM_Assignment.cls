public with sharing class CAM_Assignment {
    
    public static void triggerHandler(List<Account> triggerNew){
        Set<Id> parentIds = new Set<Id>();
        Map<Id,Account> accMap = new Map<Id,Account>();
        for(Account acc : triggerNew){
            if(acc.ParentId != NULL){
                parentIds.add(acc.ParentId);
            }
        }
        
/*      COMMENTED THE BELOW CODE BECAUSE IN BEFORE INSERT OPERATION WE CAN'T QUERY ON THE SAME RECORD 
        Map<Id,Account> parentAccMap = new Map<Id,Account>([
            SELECT Id,ParentId,Parent.CAM_Owner__c,Parent.CAM_Group__c 
            FROM Account 
            WHERE ParentId IN:parentIds
        ]);
*/
        // BELOW MAP RETURNS THE MAP OF PARENT ACCOUNT RECORD
        Map<Id,Account> parentAccMap = new Map<Id,Account>([
            SELECT Id,ParentId,Parent.CAM_Owner__c,Parent.CAM_Group__c, CAM_Owner__c,CAM_Group__c 
            FROM Account 
            WHERE Id IN:parentIds
        ]);
        for(Account acc : triggerNew){
            if(acc.ParentId != NULL){
                if(!parentAccMap.isEmpty() && parentAccMap.containsKey(acc.ParentId)){
                    acc.Parent = parentAccMap.get(acc.ParentId);
                }
                if(Trigger.isInsert == true){
                    syncCAMwithParent(acc);
                }
            }
            if(acc.CAM_Assign_Status__c == 'Pending CAM Group Assignment'){
                CAM_Assignment.setGroup(acc);
                if(Test.isRunningTest() || Trigger.isUpdate){
                    accMap.put(acc.Id,acc);
                }
            }
            if(acc.CAM_Assign_Status__c == 'Pending CAM Owner Assignment'){
                CAM_Assignment.setOwner(acc);
                if(Test.isRunningTest() || Trigger.isUpdate){
                    accMap.put(acc.Id,acc);
                }
            }
        }
        if(!accMap.isEmpty())
            updateChildAccounts(accMap.values());
    }

    public static void triggerHandler(List<Opportunity> triggerNew){
        if(OpportunityCreateBOFU.isBofuAdditionalFieldsEnabled()){
            Set<Id> accIds = new Set<Id>();
            for(Opportunity o : triggerNew){
                if(o.StageName == 'Closed Won')
                    accIds.add(o.AccountId);
            }
            if(!accIds.isEmpty()){
                List<Account> accounts = [
                    SELECT Id,
                        CAM_Group__c,
                        CAM_Owner__c,
                        Account.ParentId,
                        Account.Parent.CAM_Owner__c,
                        Account.Parent.CAM_Group__c,
                        CAM_Assign_Status__c 
                    FROM 
                        Account 
                    WHERE Id=:accIds AND (CAM_Group__c = Null OR CAM_Owner__c = Null)];
                for(Account a : accounts){
                    CAM_Assignment.setGroup(a);
                    CAM_Assignment.setOwner(a);
                }
                update accounts;
            }
        }
    }

    public static void setGroup(Account a) {
        if (a.CAM_Group__c == null) {
            setExistingGroupFromParent(a);
            setGroupFromRules(a);
        }
    }

    public static void setOwner(Account a) {
        if (a.CAM_Owner__c == null) {
            setExistingOwnerFromParent(a);
            setOwnerFromRotatorQueue(a);
        }
    }
    
    @TestVisible
    private static void setExistingGroupFromParent(Account a) {
        if (a.Parent != null && a.Parent.CAM_Group__c != null) {
            a.CAM_Group__c = a.Parent.CAM_Group__c;
        }
    }

    @TestVisible
    private static void setExistingOwnerFromParent(Account a) {
        if (a.Parent != null && a.Parent.CAM_Owner__c != null) {
            a.CAM_Owner__c = a.Parent.CAM_Owner__c;
        }
    }
    
    @TestVisible
    private static void setGroupFromRules(Account a) {
        if (a.CAM_Group__c == null) {
            // TODO move into rules table so they can update it
            Opportunity o = new Opportunity();
            if(Test.isRunningTest()){
                o = a.Opportunities.size() > 0 ? a.Opportunities[0] : new Opportunity();
            }
            else if(a.Id != NULL){
                //TODO bulkify code ?
                for(Opportunity opp : [
                        SELECT Opportunity_ARR__c,Owner_Role_Custom__c, BOFU_CAM_Group__c 
                        FROM Opportunity 
                        WHERE AccountId=:a.Id 
                        AND IsWon = true
                        ORDER BY CloseDate desc 
                        LIMIT 1]){
                    o = opp;
                }
            }

            a.CAM_Group__c = o.BOFU_CAM_Group__c;

            //Boolean bigDeal = o.Opportunity_ARR__c != null && o.Opportunity_ARR__c >= 60000; // FIXME: is this the right field?
            //String role = o.Owner_Role_Custom__c != null ? o.Owner_Role_Custom__c : '';
            //if (role == 'EMEA')
            //    a.CAM_Group__c = 'EMEA-SB';
            //else if (role == 'EMEA ENT AE')
            //    a.CAM_Group__c = 'EMEA-ENT';
            //else if (role.contains('ANZ ENT AE'))
            //    a.CAM_Group__c = 'ANZ-ENT';
            //else if (role == 'ANZ SMB AE')
            //    a.CAM_Group__c = 'ANZ-SB';
            //else if (role.contains('JPN'))
            //    a.CAM_Group__c = 'JPN';

            //else if (role.contains('BizDev'))
            //    a.CAM_Group__c = 'AMER-Channel';
            //else if (role.contains('VP BD'))
            //    a.CAM_Group__c = 'AMER-Channel';
            //else if (role.contains('LATAM BD'))
            //    a.CAM_Group__c = 'AMER-Channel';

            //else if (role.contains('Mid Market') && bigDeal)
            //    a.CAM_Group__c = 'AMER+G60K';
            //else if (role.contains('Enterprise') && bigDeal)
            //    a.CAM_Group__c = 'AMER+G60K';
            //else if (role.contains('Corporate') && bigDeal)
            //    a.CAM_Group__c = 'AMER+G60K';

            //else if (role.contains('Mid Market') && !bigDeal)
            //    a.CAM_Group__c = 'AMER-MM/ENT+L60K';
            //else if (role.contains('Enterprise') && !bigDeal)
            //    a.CAM_Group__c = 'AMER-MM/ENT+L60K';
            ///*
            //else if (role.contains('Corporate') && !bigDeal)
            //    a.CAM_Group__c = 'AMER-MM/ENT+L60K';
            //*/
            //else if (role.contains('Corporate') && !bigDeal)
            //    a.CAM_Group__c = 'AMER-SB+L60K';

            //else
            //    a.CAM_Group__c = 'Renewal Team';

            a.CAM_Assign_Status__c = 'Pending CAM Assignment';
            
        }
    }

    @TestVisible
    private static void setOwnerFromRotatorQueue(Account a) {
        if (a.CAM_Owner__c == null) {
            List<CAM_Rotator__c> rotators = [
                SELECT Id,CAM_Owner__c 
                FROM CAM_Rotator__c 
                WHERE CAM_Group__c =:a.CAM_Group__c 
                AND CAM_Owner__c != NULL 
                AND isActive__c = true  
                ORDER BY Last_Assigned__c ASC NULLS FIRST 
                LIMIT 1
            ];
            for(CAM_Rotator__c cr : rotators){
                a.CAM_Owner__c = cr.CAM_Owner__c;
                a.CAM_Assigned_Date__c = Date.today();
                a.CAM_Assign_Status__c = 'CAM Owner Assigned';
                cr.Last_Assigned__c = System.now();
            }
            if(!rotators.isEmpty()){
                update rotators;
            }
        }
    }

    @TestVisible static Account[] childAccountQueryOverride;
    private static void updateChildAccounts(Account[] accounts) {
        Map<Id, Account> accountMap = new Map<Id, Account>(accounts);
        Account[] childAccounts = childAccountQueryOverride != null ? childAccountQueryOverride : [
            select Id,
                CAM_Group__c,
                CAM_Owner__c,
                ParentId,
                Parent.ParentId,
                Parent.Parent.ParentId,
                Parent.Parent.Parent.ParentId,
                Parent.Parent.Parent.Parent.ParentId
            from Account
            // query 5 levels of accounts to limit recursion and query govorner limits
            where ParentId in :accounts
            or Parent.ParentId in :accounts
            or Parent.Parent.ParentId in :accounts
            or Parent.Parent.Parent.ParentId in :accounts
            or Parent.Parent.Parent.Parent.ParentId in :accounts
        ];
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        for (Account c : childAccounts) {
            Account parentAccount = parentAccount(c, accountMap);
            if(parentAccount != null){
                if (c.CAM_Group__c != parentAccount.CAM_Group__c) {
                    c.CAM_Group__c = parentAccount.CAM_Group__c;
                    accountsToUpdate.put(c.Id, c);
                }
                if (c.CAM_Owner__c != parentAccount.CAM_Owner__c) {
                    c.CAM_Owner__c = parentAccount.CAM_Owner__c;
                    accountsToUpdate.put(c.Id, c);
                }
            }
        }
        if (!accountsToUpdate.isEmpty() && !Test.isRunningTest()) {
            update accountsToUpdate.values();
        }
    }
  @TestVisible static Account[] childAccountQueryOverrideNew;
    public static Map<Id, Account> updateChildAccountsNew(Account[] accounts) {
        Map<Id, Account> accountMap = new Map<Id, Account>(accounts);
        Account[] childAccounts = childAccountQueryOverrideNew != null ? childAccountQueryOverrideNew : [
            select Id,
                CAM_Group__c,
                CAM_Owner__c,
                ParentId,
                Parent.ParentId,
                Parent.Parent.ParentId,
                Parent.Parent.Parent.ParentId,
                Parent.Parent.Parent.Parent.ParentId
            from Account
            // query 5 levels of accounts to limit recursion and query govorner limits
            where ParentId in :accounts
            or Parent.ParentId in :accounts
            or Parent.Parent.ParentId in :accounts
            or Parent.Parent.Parent.ParentId in :accounts
            or Parent.Parent.Parent.Parent.ParentId in :accounts
        ];
        Map<Id, Account> accountsToUpdate = new Map<Id, Account>();
        for(Account c : childAccounts) {
        
           // c = Account_MainTriggerHelper.retrievePartiallyUpdatedAccount(c); //added to make sure that functionality is not being overridden by another process.
            Account parentAccount = parentAccount(c, accountMap);
            if(parentAccount != null){
                if (c.CAM_Group__c != parentAccount.CAM_Group__c) {
                    c.CAM_Group__c = parentAccount.CAM_Group__c;
                    accountsToUpdate.put(c.Id, c);
                }
                if (c.CAM_Owner__c != parentAccount.CAM_Owner__c) {
                    c.CAM_Owner__c = parentAccount.CAM_Owner__c;
                    accountsToUpdate.put(c.Id, c);
                }
            }
        }        
        
        if (!accountsToUpdate.isEmpty() && !Test.isRunningTest()) {
            return accountsToUpdate;
        }
        return new Map<Id, Account>();
    }

    private static Account parentAccount(Account c, Map<Id, Account> accountMap) {
        // always use the top parent possible
        return 
            accountMap.containsKey(c.Parent.Parent.Parent.Parent.ParentId) ? accountMap.get(c.Parent.Parent.Parent.Parent.ParentId) : 
            accountMap.containsKey(c.Parent.Parent.Parent.ParentId) ? accountMap.get(c.Parent.Parent.Parent.ParentId) : 
            accountMap.containsKey(c.Parent.Parent.ParentId) ? accountMap.get(c.Parent.Parent.ParentId) : 
            accountMap.containsKey(c.Parent.ParentId) ? accountMap.get(c.Parent.ParentId) : 
            accountMap.containsKey(c.ParentId) ? accountMap.get(c.ParentId) : 
            null;
    }

    public static void syncCAMwithParent(Account a){
        setExistingGroupFromParent(a);
        setExistingOwnerFromParent(a);
    }
    
}