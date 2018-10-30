/* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
********************************************************************************************************************* */
public Class UpdateCLSOnAccountFromClzProject {
    
    public static final String CANCELLED              = 'Cancelled';
	public static final String CANCELED               = 'Canceled';
    public static final String COMPLETED              = 'Completed';
    public static final String ACTIVE                 = 'Active';
    public static final String HOLD                   = 'On Hold';
    public static final String SUSPENDED              = 'Suspended';
    public static final String LOST                   = 'Lost';
    public static final String NEWVALUE               = 'New';
    public static final String ONBOARDINGINPRODUCTION = 'Onboarding- In Production';
    public static final String INPRODUCTION           = 'In Production';
    public static final String ONBOARDING             = 'Onboarding';    
    public static final String UNKNOWN                = 'Unknown'; 

	/* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
		
    public static void UpdateCLSOnAccountFromClzProjects(List<clzV5__Clarizen_Project__c> TriggerNew){

        Set<String> clarizenProjectTypes = new Set<String>();       
        Map<String, clzV5__Clarizen_Project__c> accountWithClarizenProject = new Map<String, clzV5__Clarizen_Project__c>();
        Set<String> accountIds           = new Set<String>();
        clarizenProjectTypes.addAll(System.Label.ClarizenProjectTypes_When_CLS_of_Account_Is_Updated.split(','));
        for(clzV5__Clarizen_Project__c clzProj : TriggerNew){
            system.debug(clarizenProjectTypes.contains(clzProj.clzV5__CLZ_ProjectType__c)+'==test'+clzProj.clzV5__CLZ_ProjectType__c);
            if(clzProj.clzV5__CLZ_Customer__c != null ){
                accountIds.add(clzProj.clzV5__CLZ_Customer__c);
            }
        }
        if(accountIds.isEmpty()) return;
        List<Account> accountsToBeUpdated = new List<Account>();
        Set<String> lostAndSuspendedCLStages = new Set<String>{LOST, SUSPENDED};  
        for(Account ac : [SELECT Customer_Lifecycle_Stage__c, Active_Projects__c, (select Id,clzV5__CLZ_State__c,clzV5__CLZ_ProjectType__c,clzV5__CLZ_Customer__r.Customer_Lifecycle_Stage__c from clzV5__Clarizen_Projects__r) FROM Account WHERE Id IN: accountIds ]){
            integer Count = 0;
            boolean isChanged = false;
            Map<String, Account> removeDuplicates = new Map<String, Account>();  
            String latestCustLifeCycleStageValue;          
            for(clzV5__Clarizen_Project__c clzProj : ac.clzV5__Clarizen_Projects__r ){
                if(!lostAndSuspendedCLStages.contains(clzProj.clzV5__CLZ_Customer__r.Customer_Lifecycle_Stage__c)){
                    if(clarizenProjectTypes.contains(clzProj.clzV5__CLZ_ProjectType__c)){
                        if(clzProj.clzV5__CLZ_State__c == ACTIVE){
                            if(clzProj.clzV5__CLZ_ProjectType__c != 'OPPTY'){
                                Count = Count +1;
                            }
                            if((ac.Customer_Lifecycle_Stage__c <> INPRODUCTION && ac.Customer_Lifecycle_Stage__c <> ONBOARDINGINPRODUCTION)){
                                ac.Customer_Lifecycle_Stage__c = ONBOARDING;
                                removeDuplicates.put(ac.Id, ac);                        
                            }else if(ac.Customer_Lifecycle_Stage__c == INPRODUCTION ){
                                ac.Customer_Lifecycle_Stage__c = ONBOARDINGINPRODUCTION;    
                                removeDuplicates.put(ac.Id, ac);                                            
                            }
                        }else if(clzProj.clzV5__CLZ_State__c == CANCELLED || clzProj.clzV5__CLZ_State__c == CANCELED || clzProj.clzV5__CLZ_State__c == COMPLETED){
                            if(ac.Customer_Lifecycle_Stage__c == ONBOARDING || ac.Customer_Lifecycle_Stage__c == NEWVALUE || ac.Customer_Lifecycle_Stage__c == UNKNOWN || ac.Customer_Lifecycle_Stage__c == ONBOARDINGINPRODUCTION){
                                ac.Customer_Lifecycle_Stage__c = INPRODUCTION;
                                removeDuplicates.put(ac.Id, ac);                        
                            } 
                        }else if(clzProj.clzV5__CLZ_State__c == HOLD){
                            if(clzProj.clzV5__CLZ_ProjectType__c != 'OPPTY'){
                                Count = Count +1;
                            }
                        }
                    }else if(clzProj.clzV5__CLZ_ProjectType__c != 'OPPTY'){
                        if(clzProj.clzV5__CLZ_State__c == ACTIVE || clzProj.clzV5__CLZ_State__c == HOLD){
                            Count = Count +1;
                        }
                    }
                }else{
                    if(clzProj.clzV5__CLZ_ProjectType__c != 'OPPTY'){
                        if(clzProj.clzV5__CLZ_State__c == ACTIVE || clzProj.clzV5__CLZ_State__c == HOLD){
                            Count = Count +1;
                        }
                    }
                }
            }
            if(Count != ac.Active_Projects__c){
                ac.Active_Projects__c = Count;
                isChanged = True;
            }
            if(!removeDuplicates.isEmpty()){
                if(removeDuplicates.containsKey(ac.Id)){
                    ac.Customer_Lifecycle_Stage__c = removeDuplicates.get(ac.Id).Customer_Lifecycle_Stage__c;
                    isChanged = True;
                }
            }  
            if(isChanged){
                accountsToBeUpdated.add(ac);
            }
        }
        if(!accountsToBeUpdated.isEmpty()){
            Utility.isAccountUpdatedFromTrigger = true;
            try{ update accountsToBeUpdated; } catch(Exception e){ TriggerNew[0].addError(e);}
        }
    }
	********************************************************************************************************************* */
    
    public static boolean ParentChildSync = False;
	
	/* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
		
    public static void SyncParentwithChild(List<clzV5__Clarizen_Project__c> newList, Map<Id,clzV5__Clarizen_Project__c> oldmap){
      
      Map<Id,clzV5__Clarizen_Project__c> clzSyncMap = new Map<Id,clzV5__Clarizen_Project__c>();
      Map<Id,Boolean> clzFieldsSyncMap = new Map<Id,Boolean>();
      String PROJECT_TYPE_NAME = System.Label.PROJECT_TYPE_NAME;
      String FIELD_NAMES = System.Label.CLZ_SYNC_FIELDS;
      List<String> FIELD_NAME_LIST = FIELD_NAMES.split(',');
      
      for(clzV5__Clarizen_Project__c cp : newList){
        if(cp.Project_Type_Name__c == PROJECT_TYPE_NAME){
          clzSyncMap.put(cp.Id, cp);
        }
      }
      
      if(!clzSyncMap.isEmpty()){
        String QUERYFIELDNAME = FIELD_NAMES ;
        Set<Id> parentIds = clzSyncMap.keySet();

        String Qry = 'SELECT ID, clzV5__CLZ_Parent__c, '+QUERYFIELDNAME+' FROM clzV5__Clarizen_Project__c WHERE clzV5__CLZ_Parent__c IN :parentIds';
        List<clzV5__Clarizen_Project__c> CLZtoBeUpdated = new List<clzV5__Clarizen_Project__c>();
        
        List<clzV5__Clarizen_Project__c> CLZtoBeProcessed =  (List<clzV5__Clarizen_Project__c>)DataBase.query(Qry);
        for(clzV5__Clarizen_Project__c ccp : CLZtoBeProcessed){
          
          boolean isUpdateNeeded = False;
          if(clzSyncMap.containsKey(ccp.clzV5__CLZ_Parent__c)){
            for(String str : FIELD_NAME_LIST){
              clzV5__Clarizen_Project__c targetProject = clzSyncMap.get(ccp.clzV5__CLZ_Parent__c);
              if(ccp.get(str) != targetProject.get(str)){
                ccp.put(str, targetProject.get(str));
                isUpdateNeeded = True;
              }
            }
            if(isUpdateNeeded){
              CLZtoBeUpdated.add(ccp);
            }
          }
        }
        if(!CLZtoBeUpdated.isEmpty()){
          ParentChildSync = true;
          update CLZtoBeUpdated;
        }
      }
    }
	********************************************************************************************************************* */
}