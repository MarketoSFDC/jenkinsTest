/******************************
** File:    GainsightInstanceDBSizeTrigger.trigger
** Desc:    Trigger to populate Database Size at the Instance level
** Auth:    Rob Begley
** Date:    1.30.14
**************************
** Change History
**************************
** PR   Date        Author      Description 
** --   --------    -------     ------------------------------------
*******************************/

trigger GainsightInstanceDBSizeTrigger on JBCXM__UsageData__c (before insert, before update) 
{
    try 
    {
        Set<String> MunchkinIdSet = new Set<String>();
        Map<String,Asset> AssetByMunchkinId = new Map<String,Asset>();
        
        //Populate set of needed Munchkin IDs
        for(JBCXM__UsageData__c UD : Trigger.New)
        {
            MunchkinIdSet.add(UD.JBCXM__InstanceId__c);
        }
        
        //UsageEndDate InstallDate Status
        //Query Assets by related Munchkin ID and store in Map
        for(Asset A : [SELECT Id, Maximum_Database_Size__c,Munchkin_ID__c FROM Asset WHERE Munchkin_ID__c IN :MunchkinIdSet])
        {
            AssetByMunchkinId.put(A.Munchkin_ID__c,A);
        }
        
        //Update Database Size before insert/update
        for(JBCXM__UsageData__c UD : Trigger.New)
        {
            if(UD.Name == 'INSTANCELEVEL' && UD.JBCXM__InstanceId__c != null)
            {
                if(AssetByMunchkinId != null && AssetByMunchkinId.containsKey(UD.JBCXM__InstanceId__c)){
                    Asset ast = AssetByMunchkinId.get(UD.JBCXM__InstanceId__c);
                    if(ast.Maximum_Database_Size__c != null){
                        UD.DatabaseSize__c = ast.Maximum_Database_Size__c;
                    }else{  UD.DatabaseSize__c = 0; }
                    UD.Related_Asset__c = ast.Id;// CREATED THIS FIELD TO MINIMIZE THE NO OF SQL 
                }
                /*
                UD.DatabaseSize__c = AssetByMunchkinId.containsKey(UD.JBCXM__InstanceId__c) ? AssetByMunchkinId.get(UD.JBCXM__InstanceId__c) : 0;
                */
            }
        }
    }
    catch (Exception e) {
        JBCXM__Log__c errorLog = New JBCXM__Log__c(JBCXM__ExceptionDescription__c   = 'Received a ' + e.getTypeName() + ' at line No. ' + e.getLineNumber() + ' while running the Trigger to populate Database Size at the INSTANCELEVEL.',JBCXM__LogDateTime__c= datetime.now(),JBCXM__SourceData__c= e.getMessage(),JBCXM__SourceObject__c= 'JBCXM__UsageData__c',JBCXM__Type__c= 'GainsightInstanceDBSizeTrigger');
        insert errorLog;
        system.Debug(errorLog.JBCXM__ExceptionDescription__c);
        system.Debug(errorLog.JBCXM__SourceData__c);
    }
}