public class AssignCSMToAccountAsPerRule{
    public static boolean ARFirstPass = False;
    
    public static Map<id, id> getAccountCSM(List<Account> accounts){
		
		Map<Id,Id> emptyMap = new Map<Id,Id>();
		// **************** COMMENTING THE BELOW CODE AS Customer_Success_Manager__c IS DELETED ************//
		/*
        Set<String> CSMKeySet = new Set<String>();
        for(Account a :accounts){
            system.debug('cccccccc'+a.CSM_Assignment_Rule_Key__c);
            CSMKeySet.add(a.CSM_Assignment_Rule_Key__c);
        }
        system.debug('kkkk'+CSMKeySet);
        Map<String, id> csmKeyUserMap = new Map<String, id>();
        for(Assignment_Rule__c assignmentRule :[select id, User__c, Assignment_Rule_Key__c from Assignment_Rule__c where Assignment_Rule_Key__c in :CSMKeySet and Rule_Name__c = 'Account CSM Assignment Rev']){
            csmKeyUserMap.put(assignmentRule.Assignment_Rule_Key__c, assignmentRule.User__c);
        }
        system.debug('mmmmm'+csmKeyUserMap);
        //Default Assignment Rule
        List <Assignment_Rule__c> DefaultAssignmentRule = [select User__c from Assignment_Rule__c where 
        business_Unit__c = 'n/a' and Country__c = 'n/a' and State__c = 'n/a' and Zip5__c = 'n/a' limit 1];
        String defaultCSM;
        if (DefaultAssignmentRule.size() > 0){
            defaultCSM = DefaultAssignmentRule[0].User__c;
        }
        
        //Parent CSM
        List <Account> ParentCSMList = [select Id, parent.Customer_Success_Manager__c from Account where id in :accounts];
        Map<Id, Id> ParentCSMMap = new Map<id,Id>();
        for (Account ac : ParentCSMList){
            ParentCSMMap.put(ac.Id, ac.parent.Customer_Success_Manager__c);
        }
        
        Map<id, id> CSMMapToBeReturned = new Map<id, id>();
        
        id Parent_CSM;
        id currentCSM;
        for(Account acc :accounts){
            if(ParentCSMMap.get(acc.Id) <> null)
                Parent_CSM = ParentCSMMap.get(acc.Id);
            system.debug('pppp'+Parent_CSM);
            if (acc.ParentId <> null && Parent_CSM <> null) {
                currentCSM = Parent_CSM;
            }else
            
            if(csmKeyUserMap.get(acc.CSM_Assignment_Rule_Key__c) <> null){
                currentCSM = csmKeyUserMap.get(acc.CSM_Assignment_Rule_Key__c);
                system.debug('aaa'+acc.CSM_Assignment_Rule_Key__c+'--'+currentCSM);
            }else
            
            if (defaultCSM <> null) {
                currentCSM = defaultCSM;
            }
            
            CSMMapToBeReturned.put(acc.id, currentCSM);
            currentCSM = null;
            Parent_CSM = null;
        }
        return CSMMapToBeReturned;
		*/
		return emptyMap;
    }
    
}