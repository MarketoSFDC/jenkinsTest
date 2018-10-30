global class GainsightFeaturesBatch implements Database.Batchable<sObject>, Database.Stateful
{
    global final String Query;

    //Constructor to populate features for one Account
    global GainsightFeaturesBatch(string pAccountId)
    {
        Query = 'SELECT JBCXM__Account__c FROM JBCXM__CustomerInfo__c WHERE JBCXM__Account__c = \'' + pAccountId + '\'';
    }

    //Constructor to populate features for all Account
    global GainsightFeaturesBatch()
    {
        Query = 'SELECT JBCXM__Account__c FROM JBCXM__CustomerInfo__c';
    }

    global void execute(SchedulableContext SC) 
    {
        database.executebatch(new GainsightFeaturesBatch(),1);
    }
      
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        return Database.getQueryLocator(Query);
    }
    
    global void execute(Database.BatchableContext BC, List<JBCXM__CustomerInfo__c> scope)
    {
        Set<Id> AccountIdSet = new Set<Id>();

        //Get Account Ids
        for (JBCXM__CustomerInfo__c CI : scope)
        {
            AccountIdSet.add(CI.JBCXM__Account__c); 
        } 

        Map<String,String> ProductNameMap = new Map<String,String>();
        Map<String,String> FeatureNameMap = new Map<String,String>();
        Map<String,Map<String,OpportunityLineItem>> OppLinesByAccountMap = new Map<String,Map<String,OpportunityLineItem>>();
        Map<String,Set<String>> NeededFeaturesByAccount = new Map<String,Set<String>>();

        //Get Opp Products related to this Account
        for(OpportunityLineItem OPLI : [SELECT PricebookEntry.Product2Id,PricebookEntry.Product2.Product_Type__c,PricebookEntry.Product2.Family,PricebookEntry.Product2.Name,PricebookEntry.Product2.ProductCode,ServiceDate,ServiceEndDate__c,OpportunityId,Opportunity.Name,Opportunity.AccountId,Opportunity.Type,Opportunity.Sub_Start_Date__c,Opportunity.Sub_End_Date__c FROM OpportunityLineItem WHERE Opportunity.AccountId IN :AccountIdSet AND Opportunity.StageName = 'Closed Won' AND PricebookEntry.Product2.ProductCode != null AND PricebookEntry.Product2.Family != 'Services'])
        {
            Map<String,OpportunityLineItem> TempMap = new Map<String,OpportunityLineItem>();

            //Check if Map contains Opp Item Map for this Account
            if(OppLinesByAccountMap.containsKey(String.ValueOf(OPLI.Opportunity.AccountId))) TempMap = OppLinesByAccountMap.get(String.ValueOf(OPLI.Opportunity.AccountId));
            TempMap.put(String.ValueOf(OPLI.PricebookEntry.Product2.ProductCode),OPLI);
            OppLinesByAccountMap.put(String.ValueOf(OPLI.Opportunity.AccountId),TempMap);

            String TempProductName = (String.ValueOf(OPLI.PricebookEntry.Product2.Name).length() > 120) ? String.ValueOf(OPLI.PricebookEntry.Product2.Name).substring(0,120) : String.ValueOf(OPLI.PricebookEntry.Product2.Name);
            String TempSystemName = (String.ValueOf(OPLI.PricebookEntry.Product2.ProductCode).length() > 80) ? String.ValueOf(OPLI.PricebookEntry.Product2.ProductCode).substring(0,80) : String.ValueOf(OPLI.PricebookEntry.Product2.ProductCode);
            String TempFeatureName = OPLI.PricebookEntry.Product2.Family + ((OPLI.PricebookEntry.Product2.Product_Type__c != null) ? (' - ' + OPLI.PricebookEntry.Product2.Product_Type__c) : '');
            TempFeatureName = ((TempFeatureName.length() > 120) ? TempFeatureName.substring(0,120) : TempFeatureName);
            ProductNameMap.put(TempSystemName,TempProductName);
            FeatureNameMap.put(TempSystemName,TempFeatureName);

            Set<String> TempSet = new Set<String>();

            //Check if Map contains Feature Set for this Account
            if(NeededFeaturesByAccount.containsKey(String.ValueOf(OPLI.Opportunity.AccountId))) TempSet = NeededFeaturesByAccount.get(String.ValueOf(OPLI.Opportunity.AccountId));
            TempSet.add(TempSystemName);
            NeededFeaturesByAccount.put(String.ValueOf(OPLI.Opportunity.AccountId),TempSet);
        } 

        Map<String,JBCXM__Features__c> FeatureMap = new Map<String,JBCXM__Features__c>();

        //Check Features table for Opp Products
        for(JBCXM__Features__c FT : [SELECT Id,JBCXM__Feature__c,JBCXM__Product__c,JBCXM__SystemName__c FROM JBCXM__Features__c WHERE JBCXM__SystemName__c IN :ProductNameMap.keySet()])
        {
            FeatureMap.put(FT.JBCXM__SystemName__c,FT);
        }

        List<JBCXM__Features__c> FeaturesToUpsert = new List<JBCXM__Features__c>();

        //Update and Insert Features
        for(String SysName : ProductNameMap.keySet())
        {
            JBCXM__Features__c F = new JBCXM__Features__c();

            if(FeatureMap.containsKey(SysName)) F = FeatureMap.get(SysName);

            F.JBCXM__Feature__c = FeatureNameMap.containsKey(SysName) ? FeatureNameMap.get(SysName) : SysName;
            F.JBCXM__Product__c = ProductNameMap.containsKey(SysName) ? ProductNameMap.get(SysName) : SysName;
            F.JBCXM__SystemName__c = SysName;
            FeaturesToUpsert.add(F);
        }

        upsert FeaturesToUpsert;

        //Reinitialize FeatureMap
        FeatureMap = new Map<String,JBCXM__Features__c>();

        //Add all updated Features to Map
        for(JBCXM__Features__c FT : FeaturesToUpsert)
        {
            FeatureMap.put(FT.JBCXM__SystemName__c,FT);
        }
        
        List<JBCXM__CustomerFeatures__c> CustomerFeaturesToUpsert = new List<JBCXM__CustomerFeatures__c>();
        Map<String,Map<String,JBCXM__CustomerFeatures__c>> CurrentCustomerFeatureMap = new Map<String,Map<String,JBCXM__CustomerFeatures__c>>();

        //Query current Customer Features and add them to the Current Customer Features map
        for(JBCXM__CustomerFeatures__c CF : [SELECT Id,JBCXM__Account__c,JBCXM__Features__r.JBCXM__SystemName__c,JBCXM__Enabled__c,JBCXM__Licensed__c,JBCXM__Comment__c FROM JBCXM__CustomerFeatures__c WHERE JBCXM__Account__c IN :AccountIdSet])
        {
            Map<String,JBCXM__CustomerFeatures__c> TempMap = new Map<String,JBCXM__CustomerFeatures__c>();
            
            if(CurrentCustomerFeatureMap.containsKey(CF.JBCXM__Account__c)) TempMap = CurrentCustomerFeatureMap.get(CF.JBCXM__Account__c);
            TempMap.put(CF.JBCXM__Features__r.JBCXM__SystemName__c,CF);
            CurrentCustomerFeatureMap.put(CF.JBCXM__Account__c,TempMap);    
        }

        //Create new Customer Feature records that dont exist already
        for (JBCXM__CustomerInfo__c CI : scope)
        {
            //See if Account has features that need to be added
            if(NeededFeaturesByAccount.containsKey(CI.JBCXM__Account__c) && OppLinesByAccountMap.containsKey(CI.JBCXM__Account__c))
            {
                Set<String> TempSet = NeededFeaturesByAccount.get(CI.JBCXM__Account__c);
                Map<String,OpportunityLineItem> OppLinesBySystemName = OppLinesByAccountMap.get(CI.JBCXM__Account__c);

                for(String SystemName : TempSet)
                {
                    JBCXM__CustomerFeatures__c CF = new JBCXM__CustomerFeatures__c();

                    //Check to see if Customer Feature already exists in DB
                    if(CurrentCustomerFeatureMap.containsKey(CI.JBCXM__Account__c))
                    {
                        Map<String,JBCXM__CustomerFeatures__c> TempMap = CurrentCustomerFeatureMap.get(CI.JBCXM__Account__c);
                        
                        if(TempMap.containsKey(SystemName)) CF = TempMap.get(SystemName);
                    }
                    //If not -- set Account lookup
                    else
                    {
                        CF.JBCXM__Account__c=CI.JBCXM__Account__c;  
                    }
                    
                    //(Re)populate the rest of the Customer Feature fields
                    CF.JBCXM__Features__c = (FeatureMap.containsKey(SystemName) ? FeatureMap.get(SystemName).Id : '');

                    if(OppLinesBySystemName.containsKey(SystemName))
                    {
                        OpportunityLineItem OPLI = OppLinesBySystemName.get(SystemName);
                        
                        if(OPLI.OpportunityId != null)
                        {
                            //CF.JBCXM__Comment__c = '<a target="_blank" href="' + URL.getSalesforceBaseUrl().toExternalForm().replace('-api','') + '/' + OPLI.OpportunityId + '">' + OPLI.Opportunity.Name + '</a>';
                            CF.JBCXM__Comment__c = OPLI.Opportunity.Name;

                            //If Opportunity is currently active then mark the Customer Features as Licensed Enabled
                            if(OPLI.Opportunity.Sub_Start_Date__c <= Date.Today() && OPLI.Opportunity.Sub_End_Date__c >= Date.Today())
                            {
                                CF.JBCXM__Licensed__c = true;
                                CF.JBCXM__Enabled__c = true;
                            }
                            //If they are no longer using this product from before -- disable it (if you unlicense it it will no longer show up in the Features section on C360)
                            else
                            {
                                CF.JBCXM__Licensed__c = false;
                                CF.JBCXM__Enabled__c = false;   
                            }
                        }
                        else
                        {
                            CF.JBCXM__Comment__c = '';  
                        }
                    }
                    
                    CustomerFeaturesToUpsert.add(CF);
                }
            }
        }   

        upsert CustomerFeaturesToUpsert;
    }

    global void finish(Database.BatchableContext BC)
    { 
        
    }                  
}