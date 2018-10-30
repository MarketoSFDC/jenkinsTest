public class InitializeUsageDataController{
    public InitializeUsageDataController(){}
    
    public void InitializeUsageData(List<JBCXM__UsageData__c> usageDataList){
        Set<Id> AccountIdSet = new Set<Id>();
        for(JBCXM__UsageData__c usageData :usageDataList){
            AccountIdSet.add(usageData.JBCXM__Account__c);
        }
        
        //Get all related Contact Details
        Map<Id, List<Contact>> contactMap = new Map<Id, List<Contact>>();
        for(Contact con :[SELECT Id, Name, Marketo_End_User__c, CreatedDate, AccountId FROM Contact 
        WHERE AccountId in :accountIdSet AND Marketo_End_User__c = TRUE]){           
            if(contactMap.get(con.AccountId) != null){
                contactMap.get(con.AccountId).add(con);
            }
            else{
                List<Contact> conList =new List<Contact>();
                conList.add(con);
                contactMap.put(con.AccountId, conList);
            }
        }
       
        for(JBCXM__UsageData__c usageData :usageDataList){
            usageData.Marketo_Users__c = 0;
            if(contactMap.get(usageData.JBCXM__Account__c) != null){
                usageData.Marketo_Users__c = contactMap.get(usageData.JBCXM__Account__c).size();
            }
        }
    }
}