public class UsageDataTriggerHelper{
    
    public static Boolean Execute_UsageData_Trigger_After_Insert  = true; 
    public static Boolean Execute_UsageData_Trigger_After_update  = true; 
    public static final string INSTANCELEVEL = 'INSTANCELEVEL';    
    
    public static void handleAfterInsert(Map<Id, JBCXM__UsageData__c> triggerNewMap){
        //HANDLE RECURSION
        if(!Execute_UsageData_Trigger_After_Insert) return; 
         
        //IMPLEMENT THE FUNCTIONALITIES. PLEASE PERFORM DML OPERTAION/FUTURE OPERATION IN THE LAST 
        updateGainsightEngagementOnAccount(triggerNewMap);
        
        //SET RECURSION FLAG TO DO NOT EXECUTE 
        Execute_UsageData_Trigger_After_Insert = false;
    }
    
    public static void handleAfterUpdate(List<JBCXM__UsageData__c> triggerNew, Map<Id, JBCXM__UsageData__c> triggerNewMap, Map<Id, JBCXM__UsageData__c> triggerOldMap){
        //HANDLE RECURSION
        if(!Execute_UsageData_Trigger_After_update) return;
        
        //IMPLEMENT THE FUNCTIONALITIES. PLEASE PERFORM DML OPERTAION/FUTURE OPERATION IN THE LAST 
        updateGainsightEngagementOnAccount(triggerNewMap);
        
        //SET RECURSION FLAG TO DO NOT EXECUTE 
        Execute_UsageData_Trigger_After_update = false;
    }
    public static void handleAfterdelete(Map<Id,JBCXM__UsageData__c> triggerNewMap){
        //HANDLE RECURSION    
        if(!Execute_UsageData_Trigger_After_Insert) return;
        
        //IMPLEMENT THE FUNCTIONALITIES. PLEASE PERFORM DML OPERTAION/FUTURE OPERATION IN THE LAST 
        updateGainsightEngagementOnAccount(triggerNewMap);
        //SET RECURSION FLAG TO DO NOT EXECUTE 
        Execute_UsageData_Trigger_After_Insert = false;
    }
    
    private static void updateGainsightEngagementOnAccount(Map<Id, JBCXM__UsageData__c> newUsageDataInMap){
        String BETACUST = '';//System.Label.Gainsight_Instance_Suffix;
        Set<Id> accountIds = new Set<Id>();
        List<Account> accounts = new List<Account>();
        for(JBCXM__UsageData__c usageData : newUsageDataInMap.values()){
            accountIds.add(usageData.JBCXM__Account__c);
        }
                
        List<Account> accountsToBeRefreshed = new List<Account>([SELECT Gainsight_Total_Known_Lead_Count__c, Name, Gainsight_Database_Size__c, Gainsight_Usage__c, (SELECT totalknownleadcount__c, DatabaseSize__c, ComplianceFormula__c, JBCXM__InstanceName__c, JBCXM__InstanceId__c, JBCXM__Date__c,Is_Valid_Record__c FROM JBCXM__Usage_Data__r WHERE   Name =:'INSTANCELEVEL' AND totalknownleadcount__c !=Null AND JBCXM__InstanceName__c != null AND JBCXM__InstanceId__c != null ORDER BY JBCXM__Date__c Desc nulls Last, totalknownleadcount__c Desc LIMIT 100) FROM Account WHERE Id IN: accountIds ]);
        /*
        Map<Id, Set<String>> munchIDMap = new Map<Id, Set<String>>();
        For(Asset ast : [Select id,Name,Account.id,Munchkin_ID__c from Asset where Status =:'Expired' AND Account.id In: accountIds]){
            if(munchIDMap.containsKey(ast.Account.Id)){
                    munchIDMap.get(ast.Account.Id).add(ast.Munchkin_ID__c);
            }
            else{
                munchIDMap.put(ast.Account.Id, new Set<String>{ast.Munchkin_ID__c});
            }
        }
        */    
        for(Account ac : accountsToBeRefreshed) {
            boolean isUpdateable = false;
            for(JBCXM__UsageData__c usageData : ac.JBCXM__Usage_Data__r){
                
                if(usageData.JBCXM__InstanceName__c.LastIndexOF('B',usageData.JBCXM__InstanceName__c.Length()) >= 0) {
                    BETACUST = usageData.JBCXM__InstanceName__c.SubString(usageData.JBCXM__InstanceName__c.LastIndexOF('B',usageData.JBCXM__InstanceName__c.Length()),usageData.JBCXM__InstanceName__c.Length()).toLowerCase();
                }
                /*
                Set<String> munchkinIds = new Set<String>();
                if(munchIDMap.containsKey(ac.Id)){
                    munchkinIds = munchIDMap.get(ac.Id);
                }
                if(!munchkinIds.contains(usageData.JBCXM__InstanceId__c)){
                */  
                if(usageData.Is_Valid_Record__c){
            
                    if(!(ac.Name.containsIgnoreCase('Dev') || ac.Name.containsIgnoreCase('Sandbox'))){
                      
                        String sandboxSuffix = usageData.JBCXM__InstanceName__c.toLowerCase().substringBetween('sandbox',BETACUST);
                        if(sandboxSuffix!= null && sandboxSuffix !=''){usageData.JBCXM__InstanceName__c = usageData.JBCXM__InstanceName__c.toLowerCase().replace(sandboxSuffix,'');}
                        String devSuffix = usageData.JBCXM__InstanceName__c.toLowerCase().substringBetween('dev',BETACUST);
                        if(devSuffix!= null && devSuffix !=''){usageData.JBCXM__InstanceName__c = usageData.JBCXM__InstanceName__c.toLowerCase().replace(devSuffix,'');}
                        
                        if(!(usageData.JBCXM__InstanceName__c.toLowerCase().endsWith('dev'+BETACUST) || usageData.JBCXM__InstanceName__c.toLowerCase().endsWith('sandbox'+BETACUST))){
                            ac.Gainsight_Total_Known_Lead_Count__c = usageData.totalknownleadcount__c;
                            //ac.Gainsight_Database_Size__c = usageData.DatabaseSize__c;                            
                            accounts.add(ac);
                            isUpdateable = true;
                            break;
                        }
                    }
                    
                    else if(ac.Name.containsIgnoreCase('Dev')){
                        integer standardDevcount = ac.Name.toLowerCase().countMatches('dev');
                        integer devCount = 0;
                        devCount = usageData.JBCXM__InstanceName__c.toLowerCase().countMatches('dev');
                        if(usageData.JBCXM__InstanceName__c.containsIgnoreCase(ac.Name.deleteWhitespace()) && !usageData.JBCXM__InstanceName__c.containsIgnoreCase('sandbox') && devCount < (standardDevcount+1)){
                            ac.Gainsight_Total_Known_Lead_Count__c = usageData.totalknownleadcount__c;
                            //ac.Gainsight_Database_Size__c = usageData.DatabaseSize__c;
                            accounts.add(ac);
                            isUpdateable = true;
                            break;
                        }
                        
                        else if(devCount < (standardDevcount+1) && !usageData.JBCXM__InstanceName__c.containsIgnoreCase('sandbox') && !(usageData.JBCXM__InstanceName__c.toLowerCase().endsWith('dev'+BETACUST) || usageData.JBCXM__InstanceName__c.toLowerCase().endsWith('sandbox'+BETACUST)) &&!(usageData.JBCXM__InstanceName__c.containsIgnoreCase(ac.Name.deleteWhitespace()))){ 
                            ac.Gainsight_Total_Known_Lead_Count__c = usageData.totalknownleadcount__c;
                            //ac.Gainsight_Database_Size__c = usageData.DatabaseSize__c;
                            accounts.add(ac);
                            isUpdateable = true;
                            break;
                            
                        }
                    }
                    
                    else if(ac.Name.containsIgnoreCase('Sandbox')){
                        integer standardSandboxcount = ac.Name.toLowerCase().countMatches('sandbox');
                        integer sandboxCount = 0;
                        sandboxCount = usageData.JBCXM__InstanceName__c.toLowerCase().countMatches('sandbox');
                        if(usageData.JBCXM__InstanceName__c.containsIgnoreCase(ac.Name.deleteWhitespace()) && !usageData.JBCXM__InstanceName__c.containsIgnoreCase('Dev') && sandboxCount < (standardSandboxcount+1)){
                            ac.Gainsight_Total_Known_Lead_Count__c = usageData.totalknownleadcount__c;
                            //ac.Gainsight_Database_Size__c = usageData.DatabaseSize__c;
                            accounts.add(ac);
                            isUpdateable = true;
                            break;
                        }
                        else if(sandboxCount < (standardSandboxcount+1) && !usageData.JBCXM__InstanceName__c.containsIgnoreCase('Dev') && !(usageData.JBCXM__InstanceName__c.toLowerCase().endsWith('dev'+BETACUST) || usageData.JBCXM__InstanceName__c.toLowerCase().endsWith('sandbox'+BETACUST)) && !(usageData.JBCXM__InstanceName__c.containsIgnoreCase(ac.Name.deleteWhitespace()))){ 
                            ac.Gainsight_Total_Known_Lead_Count__c = usageData.totalknownleadcount__c;
                            //ac.Gainsight_Database_Size__c = usageData.DatabaseSize__c;
                            accounts.add(ac);
                            isUpdateable = true;
                            break;
                        }
                        
                    }
                }
                                  
            }
            
            system.debug('ACCOUNT_UPDATED'+ac);
            
            if(!isUpdateable){
                ac.Gainsight_Total_Known_Lead_Count__c = Null;
                //ac.Gainsight_Database_Size__c = Null;
                accounts.add(ac);    
            }
        }        
        
        try{
            DatabaseOperation.updateAccount(accounts, true, false);
            /*Database.SaveResult[] updatedAccounts = Database.update(accounts, false);
            string failedRecords ='Accounts: ';
            for (Database.SaveResult sr : updatedAccounts) {
                if (!sr.isSuccess()){
                    failedRecords +=sr.getId();
                }
            }*/
        }
        catch(Exception e){System.Debug('____FAILEDRECORDS___'+e);}
    }
}