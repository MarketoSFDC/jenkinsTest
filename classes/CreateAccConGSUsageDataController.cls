public class CreateAccConGSUsageDataController{
    public CreateAccConGSUsageDataController(){}
    
    public void CreateAccContactGSUsageData(Set<String> usageDataKeySet, Set<ID> accountIdSet, Set<String> instanceIdSet, Set<integer> yearSet){
        
        // *** Get all Related Contact Ids, Contact Ids are Used at multiple locations ***
        Set<Id> contactIdSet = new Set<Id>();
        contactIdSet = getContactIdSet(accountIdSet);
        
        // *** Get Related Asset Details ***
        Set<Id> assetIdSet = new Set<Id>();
        Map<String, Asset> assetMap = new Map<String, Asset>();
        for(Asset ast :getAllRelatedAssets(accountIdSet, instanceIdSet)){
            assetIdSet.add(ast.Id);
            assetMap.put(ast.AccountId+ast.Munchkin_ID__c, ast);
        }
        
        // *** Get Related Active Entitlement Details ***
        Map<Id, Entitlement> entitlementMap = new Map<Id, Entitlement>();
        entitlementMap = getActiveEntilementMap(assetIdSet);
        assetIdSet.clear();
        
        // *** Get Related Customer Info Details ***
        Map<Id, JBCXM__CustomerInfo__c> customerInfoMap = new Map<Id, JBCXM__CustomerInfo__c>();
        customerInfoMap = getCustomerInfo(accountIdSet);
        
        // *** Get Usage Data Grouped by Week Group 4 Number ***
        Map<String, List<JBCXM__UsageData__c>> usageDataGroupFourMap = new Map<String, List<JBCXM__UsageData__c>>();
        usageDataGroupFourMap = getUsageDataWeekGroupFourMap(usageDataKeySet, assetMap);
        
        // *** Get Related Existing GS Account Usage Data Details ***
        Map<String, GS_4Weekly_Usage_Data__c> GS4WeeklyUsageDataMap = new Map<String, GS_4Weekly_Usage_Data__c>();
        GS4WeeklyUsageDataMap = getGS4WeeklyUsagaDataMap(usageDataKeySet);
        
        // *** Get Related Certification History Details ***
        Map<Id,List<Certification_History__c>> certificationMap = new Map<Id,List<Certification_History__c>>();
        certificationMap = getCertificationHistoryMap(accountIdSet);
        
        // *** Get Historical Usage Data to Calculate Previous Averages ***
        Map<String, List<JBCXM__UsageData__c>> histroicalUsageDataMap = new Map<String, List<JBCXM__UsageData__c>>();
        histroicalUsageDataMap = getHistoricalUsageDataMap(accountIdSet, instanceIdSet, yearSet);
        
        // *** Get Case Related Details ***
        Map<Id,List<Case>> caseMap = new Map<Id,List<Case>>();
        caseMap = getCaseMap(accountIdSet);
        
        // *** Get Login History Details ***
        Map<Id, List<LoginHistory>> accLoginHistoryMap = new Map<Id,List<LoginHistory>>();
        accLoginHistoryMap = getAccLoginHistoryMap(accountIdSet, contactIdSet);
        
        // *** Get Course Related Details From Campaign ***
        Map<Id,List<CampaignMember>> campaignMemberMap = new Map<Id,List<CampaignMember>>();
        campaignMemberMap = getCampaignMemberMap(contactIdSet);
        
        // *** Get all related Contact GS Usage Data Map ***
        Map<Id,List<GS_4Weekly_Usage_Data_Contact__c>> existingContactUsageDataMap = new Map<Id,List<GS_4Weekly_Usage_Data_Contact__c>>();
        existingContactUsageDataMap = getExistingContactUsageDataMap(contactIdSet, usageDataKeySet);
        
        // *** Get all Contacts related to Accounts ***
        Map<Id,List<Contact>> contactMap = new Map<Id,List<Contact>>();
        contactMap = getContactMap(accountIdSet);
        
        List<GS_4Weekly_Usage_Data__c> accountGSUsageDataToUpsert = new List<GS_4Weekly_Usage_Data__c>();
        
        List<GS_4Weekly_Usage_Data_Contact__c> contactGSUsageDataToUpsert = new List<GS_4Weekly_Usage_Data_Contact__c>();
        
        // *** This loop Creates or Updates the account and contact usage data records ***
        for(String usageDataKey :usageDataKeySet){
            if(usageDataGroupFourMap.get(usageDataKey) != null && usageDataGroupFourMap.get(usageDataKey).size() >= 4){
                decimal highestWeekNumber = 0;
                integer highestWeekNumberIndex = 0;
                decimal lowestWeekNumber = 0;
                Date latestDate;
                Date previousDate;
                
                integer weekIndex = 0;
                
                // *** Get Highest Week Number, Week Index and Latest Date ***
                for(JBCXM__UsageData__c usageDataGroupFour :usageDataGroupFourMap.get(usageDataKey)){
                    if(usageDataGroupFour.Week_Number__c > highestWeekNumber){
                        highestWeekNumber = usageDataGroupFour.Week_Number__c;
                        highestWeekNumberIndex = weekIndex;
                        latestDate = usageDataGroupFour.JBCXM__Date__c;
                    }
                    weekIndex = weekIndex + 1;
                }
                
                // *** Get Lowest Week Number and Previous Date ***
                lowestWeekNumber = highestWeekNumber;
                for(JBCXM__UsageData__c usageDataGroupFour :usageDataGroupFourMap.get(usageDataKey)){
                    if(usageDataGroupFour.Week_Number__c < lowestWeekNumber){
                        lowestWeekNumber = usageDataGroupFour.Week_Number__c;
                        previousDate = usageDataGroupFour.JBCXM__Date__c;
                    }
                }
                
                // *** Account Usage Data New or Existing
                GS_4Weekly_Usage_Data__c accountGSUsageData;
                if(GS4WeeklyUsageDataMap.get(usageDataKey) != null){
                    accountGSUsageData = GS4WeeklyUsageDataMap.get(usageDataKey);
                }
                else{
                    accountGSUsageData = new GS_4Weekly_Usage_Data__c();
                }
                
                // *** Get Latest Usage Data record from the Group Four ***
                JBCXM__UsageData__c latestUsageData = new JBCXM__UsageData__c();
                latestUsageData = usageDataGroupFourMap.get(usageDataKey)[highestWeekNumberIndex];
                
                // *** Assign Dates and Week Number
                accountGSUsageData.Start_Week__c = lowestWeekNumber;
                accountGSUsageData.End_Week__c = highestWeekNumber;
                accountGSUsageData.Start_Date__c = previousDate;
                
                assignLatestUsageDataValues(accountGSUsageData, latestUsageData);
                assignValuesFromAssetsAndEntitlements(accountGSUsageData, latestUsageData, assetMap, entitlementMap);
                
                // *** Assign Customer Info Values ***
                if(customerInfoMap.get(latestUsageData.JBCXM__Account__c) != null){
                    accountGSUsageData.Database_Size__c = customerInfoMap.get(latestUsageData.JBCXM__Account__c).JBCXM__Users__c;
                }
                
                // *** Assign Certification History Values ***
                accountGSUsageData.Total_Certifications__c = 0;
                if(certificationMap.get(latestUsageData.JBCXM__Account__c) != null){
                    accountGSUsageData.Total_Certifications__c = certificationMap.get(latestUsageData.JBCXM__Account__c).size();    
                }
                
                initializeAccountGSUsageDataFieldsZero(accountGSUsageData);
                assignGroupFourTotalsToAccountGSUsageData(accountGSUsageData, usageDataGroupFourMap.get(usageDataKey));
                initializePrevAverageValuesFieldsZero(accountGSUsageData);
                
                // *** Calculating Previous Average ***
                string tempKeyForPrevAvg = '';
                tempKeyForPrevAvg = accountGSUsageData.Account__c + accountGSUsageData.InstanceId__c;
                
                if(histroicalUsageDataMap.get(tempKeyForPrevAvg) != null){
                    assignPrevAvgStartDateEndDate(accountGSUsageData, histroicalUsageDataMap.get(tempKeyForPrevAvg));
                    assignPrevAvgForAllOtherFields(accountGSUsageData, histroicalUsageDataMap.get(tempKeyForPrevAvg));
                }
                
                // *** Assign Case Related Details ***
                accountGSUsageData.PrevAvg_Tickets_Created__c = 0;
                accountGSUsageData.Tickets_Created__c = 0;
                accountGSUsageData.Tickets_Currently_Open__c = 0;
                if(caseMap.get(accountGSUsageData.Account__c) != null){
                    assignCaseRelatedDetails(accountGSUsageData, caseMap.get(accountGSUsageData.Account__c));
                }
                
                // *** Assign Login History Details ***
                accountGSUsageData.PrevAvg_SFDC_Logins__c = 0;
                accountGSUsageData.SFDC_Logins__c = 0;
                if(accLoginHistoryMap.get(accountGSUsageData.Account__c) != null){
                    assignLoginHistoryDetails(accountGSUsageData, accLoginHistoryMap.get(accountGSUsageData.Account__c));
                }
                
                // *** Assign Course Details ***
                accountGSUsageData.Total_Courses__c = 0;
                if(campaignMemberMap.get(accountGSUsageData.Account__c) != null){
                    accountGSUsageData.Total_Courses__c = campaignMemberMap.get(accountGSUsageData.Account__c).size();
                }
                
                // *** Create a Temporary Contact GS Usage Data ***
                GS_4Weekly_Usage_Data_Contact__c tempContactUsageData = new GS_4Weekly_Usage_Data_Contact__c();
                tempContactUsageData = getTempContactUsageData(accountGSUsageData);
                
                if(contactMap.get(accountGSUsageData.Account__c) != null){
                    for(Contact con :contactMap.get(accountGSUsageData.Account__c)){
                        // *** Check if Contact GS Usage Data Already Exists ***
                        String tempConGSUsageDataId = null;
                        if(existingContactUsageDataMap.get(con.Id) != null){
                            for(GS_4Weekly_Usage_Data_Contact__c existingContactGSUsageData :existingContactUsageDataMap.get(con.Id)){
                                if(existingContactGSUsageData.Usage_Data_Key__c == accountGSUsageData.Usage_Data_Key__c){
                                    tempConGSUsageDataId = existingContactGSUsageData.Id;
                                    break;
                                }
                            }
                        }
                        GS_4Weekly_Usage_Data_Contact__c conGSUsageDataNew = new GS_4Weekly_Usage_Data_Contact__c();
                        conGSUsageDataNew = tempContactUsageData.Clone(false,true);
                        conGSUsageDataNew.Id = tempConGSUsageDataId;
                        conGSUsageDataNew.Contact__c = con.Id;
                        conGSUsageDataNew.Account__c = accountGSUsageData.Account__c;
                        contactGSUsageDataToUpsert.add(conGSUsageDataNew);
                    }
                }
                
                // *** Add GS Usage Data To List ***
                accountGSUsageDataToUpsert.add(accountGSUsageData);
                
            }
        }
        
        if(accountGSUsageDataToUpsert.size()>0){
            upsert accountGSUsageDataToUpsert;
        }
        
        if(contactGSUsageDataToUpsert.size()>0){
            upsert contactGSUsageDataToUpsert;
        }
    }
    
    
    private List<Asset> getAllRelatedAssets(Set<Id> accountIdSet, Set<String> instanceIdSet){
        return [SELECT Id, Name, AccountId, Munchkin_ID__c, Asset_Type__c, Subscription_Type__c, Purpose__c,  
        DKIM__c, Branded_Link__c, Acct_Prefix__c 
        FROM Asset 
        WHERE AccountId in :accountIdSet 
        AND Munchkin_ID__c in :instanceIdSet];
    }
    
    
    private Map<Id, Entitlement> getActiveEntilementMap(Set<Id> assetIdSet){
        Map<Id, Entitlement> entitlementMap = new Map<Id, Entitlement>();
        for(Entitlement entl :[SELECT Id, Name, AssetId, AccountId, Type, Named_Support_Engineer__r.FirstName, 
        Named_Support_Engineer__r.LastName FROM Entitlement WHERE AssetId in :assetIdSet and Status = 'Active']){
            entitlementMap.put(entl.AssetId, entl);
        }
        return entitlementMap;
    }
    
    
    private Map<Id, JBCXM__CustomerInfo__c> getCustomerInfo(Set<ID> accountIdSet){
        Map<Id, JBCXM__CustomerInfo__c> customerInfoMap = new Map<Id, JBCXM__CustomerInfo__c>();
        for(JBCXM__CustomerInfo__c customerInfo :[SELECT Id, Name, JBCXM__Users__c, JBCXM__Account__c  
        FROM JBCXM__CustomerInfo__c WHERE JBCXM__Account__c in :accountIdSet]){
            customerInfoMap.put(customerInfo.JBCXM__Account__c, customerInfo);
        }
        return customerInfoMap;
    }
    
    
    private Map<String, List<JBCXM__UsageData__c>> getUsageDataWeekGroupFourMap(Set<String> usageDataKeySet, Map<String, Asset> assetMap){
        Map<String, List<JBCXM__UsageData__c>> usageDataGroupFourMap = new Map<String, List<JBCXM__UsageData__c>>();
        
        for(JBCXM__UsageData__c usageData :getUsageDataList(usageDataKeySet)){
            if(assetMap.get(usageData.JBCXM__Account__c+usageData.JBCXM__InstanceId__c) != null){
                if(usageDataGroupFourMap.get(usageData.Usage_Data_Key_Indexed__c) != null){
                    usageDataGroupFourMap.get(usageData.Usage_Data_Key_Indexed__c).add(usageData);
                }
                else{
                    List<JBCXM__UsageData__c> usageDataList = new List<JBCXM__UsageData__c>();
                    usageDataList.add(usageData);
                    usageDataGroupFourMap.put(usageData.Usage_Data_Key_Indexed__c ,usageDataList);
                }
            }
        }
        
        return usageDataGroupFourMap;
    }
    
    
    public List<JBCXM__UsageData__c> getUsageDataList(Set<String> usageDataKeySet){
        return [SELECT Id, Name, JBCXM__Account__c, Active_Engagement_Count__c, anonleadnetcount__c, anonwebvisitcount__c, 
                Balance_Black_Listed_Leads__c, Balance_Bounced_Leads__c, Balance_Possible_Duplicates__c, 
                Balance_Unsubscribed_Leads__c, batch_camp_count__c, batch_camp_execution_average__c, batch_camp_execution_deviation__c, 
                batch_camp_max_lead_count__c, batch_camp_max_seconds__c, batch_camp_total_lead_count__c, batch_camp_total_seconds__c, 
                batchcampcount__c, BatchCampZero__c, Campaign_Analysis_Count__c, changedatavaluecount__c, changescorecount__c, 
                clicklinkcount__c, CommunityIdea__c, CommunityIdeaComment__c, CommunityLogins__c, CommunityQuestion__c, 
                CommunityQuestionComment__c, Contact__c, createtaskcount__c, DataLoadId__c, JBCXM__Date__c, Email_Analysis_Count__c, 
                emailbounced__c, emailclicked__c, emaildelivered__c, emailopened__c, emailsentcount__c, emailsoftbounced__c, 
                emailunsubscribed__c, filloutformcount__c, Inactive_Engagement_Count__c, JBCXM__InstanceId__c, 
                JBCXM__InstanceName__c, known_lead_net_count__c, knownleadnetcount__c, Lead_Analysis_Count__c, leadcount__c, 
                Model_Performance_Company_Analysis_Count__c, Model_Performance_Leads_Analysis_Count__c, New_Form_Net_Count__c, 
                newleadcount__c, Opportunity_Analysis_Count__c, Opportunity_Influence_Analyzer_Count__c, JBCXM__Processed__c, 
                Program_Analyzer_Count__c, Program_Cost_Analysis_Count__c, programcount__c, Program_Membership_Analysis_Count__c, 
                Program_Opportunity_Analysis_Count__c, Program_Revenue_Stage_Analysis_Count__c, programsynccount__c, sessioncount__c, 
                Success_Path_Analyzer_Count__c, syncleadtosfdccount__c, total_session_time__c, total_soft_deleted_lead__c, 
                total_soft_deleted_pending_lead__c, totalanonleadcount__c, Total_Engagement_Count__c, totalknownleadcount__c, 
                Usage_Data_Key__c, JBCXM__User__c, usingcostperiodcount__c, usingtagsexcludetagcount__c, visitwebpagecount__c, 
                Week_Group4_Number__c, JBCXM__WeekLabel__c, Week_Number__c, workspacecount__c, Usage_Data_Key_Indexed__c, 
                Marketo_Users__c 
                FROM JBCXM__UsageData__c 
                WHERE Usage_Data_Key_Indexed__c in :usageDataKeySet];
    }
    
    
    private Map<String, GS_4Weekly_Usage_Data__c> getGS4WeeklyUsagaDataMap(Set<String> usageDataKeySet){
         Map<String, GS_4Weekly_Usage_Data__c> GS4WeeklyUsageDataMap = new Map<String, GS_4Weekly_Usage_Data__c>();
         for(GS_4Weekly_Usage_Data__c GS4WeeklyUsageData :getGS4WeeklyUsageDataList(usageDataKeySet)){
             GS4WeeklyUsageDataMap.put(GS4WeeklyUsageData.Usage_Data_Key__c, GS4WeeklyUsageData);
         }
         return GS4WeeklyUsageDataMap;
    }
    
    
    private List<GS_4Weekly_Usage_Data__c> getGS4WeeklyUsageDataList(Set<String> usageDataKeySet){
        return [SELECT Id, Name, Account__c, Active_Engagement_Count__c, anonleadnetcount__c, anonwebvisitcount__c, 
                Balance_Black_Listed_Leads__c, Balance_Bounced_Leads__c, Balance_Possible_Duplicates__c, 
                Balance_Unsubscribed_Leads__c, batch_camp_count__c, batch_camp_execution_average__c, batch_camp_execution_deviation__c, 
                batch_camp_max_lead_count__c, batch_camp_max_seconds__c, batch_camp_total_lead_count__c, batch_camp_total_seconds__c, 
                batchcampcount__c, BatchCampZero__c, Campaign_Analysis_Count__c, changedatavaluecount__c, changescorecount__c, 
                clicklinkcount__c, CommunityIdea__c, CommunityIdeaComment__c, CommunityLogins__c, 
                CommunityQuestion__c, CommunityQuestionComment__c, Contact__c, createtaskcount__c, DataLoadId__c, Date__c, 
                Email_Analysis_Count__c, emailbounced__c, emailclicked__c, emaildelivered__c, emailopened__c, emailsentcount__c, 
                emailsoftbounced__c, emailunsubscribed__c, filloutformcount__c, Inactive_Engagement_Count__c, InstanceId__c, 
                InstanceName__c, known_lead_net_count__c, knownleadnetcount__c, Lead_Analysis_Count__c, leadcount__c, 
                Model_Performance_Company_Analysis_Count__c, Model_Performance_Leads_Analysis_Count__c, New_Form_Net_Count__c, 
                newleadcount__c, Opportunity_Analysis_Count__c, Opportunity_Influence_Analyzer_Count__c, Processed__c, 
                Program_Analyzer_Count__c, Program_Cost_Analysis_Count__c, programcount__c, Program_Membership_Analysis_Count__c, 
                Program_Opportunity_Analysis_Count__c, Program_Revenue_Stage_Analysis_Count__c, programsynccount__c, 
                sessioncount__c, Success_Path_Analyzer_Count__c, syncleadtosfdccount__c, total_session_time__c, 
                total_soft_deleted_lead__c, total_soft_deleted_pending_lead__c, totalanonleadcount__c, Total_Engagement_Count__c, 
                totalknownleadcount__c, Usage_Data_Key__c, User__c, usingcostperiodcount__c, usingtagsexcludetagcount__c, 
                visitwebpagecount__c, Week_Group4_Number__c, workspacecount__c, Edition__c, Database_Size__c, Support_Level__c,     
                Support_Engineer__c, Account_Executive__c, Purpose__c, Marketo_Users__c, Marketo_Logins__c, Tickets_Created__c, 
                Tickets_Currently_Open__c, Total_Certifications__c, Total_Courses__c 
                FROM GS_4Weekly_Usage_Data__c 
                WHERE Usage_Data_Key__c in :usageDataKeySet];
    }
    
    
    private Map<Id,List<Certification_History__c>> getCertificationHistoryMap(Set<ID> accountIdSet){
        Map<Id,List<Certification_History__c>> certificationMap = new Map<Id,List<Certification_History__c>>();
        for(Certification_History__c cert :getCertificationHistoryList(accountIdSet)){
            if(certificationMap.get(cert.Account__c) != null){
                certificationMap.get(cert.Account__c).add(cert);
            }
            else{
                List<Certification_History__c> certificationList = new List<Certification_History__c>();
                certificationList.add(cert);
                certificationMap.put(cert.Account__c, certificationList);
            }
        }
        return certificationMap;
    }
    
    
    private List<Certification_History__c> getCertificationHistoryList(Set<ID> accountIdSet){
        return [SELECT Id, Account__c, Date_Passed_Exam__c, Exam_Result__c 
                FROM Certification_History__c 
                WHERE Account__c in :accountIdSet 
                AND Exam_Result__c = 'Pass'];
    }
    
    
    private Map<String, List<JBCXM__UsageData__c>> getHistoricalUsageDataMap(Set<Id> accountIdSet, Set<String> instanceIdSet, Set<integer> yearSet){
        Map<String, List<JBCXM__UsageData__c>> histroicalUsageDataMap = new Map<String, List<JBCXM__UsageData__c>>();
        for(JBCXM__UsageData__c usageDdata :getHistoricalusageDataList(accountIdSet, instanceIdSet, yearSet)){
            string tempKey = '';
            tempKey = usageDdata.JBCXM__Account__c + usageDdata.JBCXM__InstanceId__c;
            if(histroicalUsageDataMap.get(tempKey) != null){
                histroicalUsageDataMap.get(tempKey).add(usageDdata);
            }
            else{
                List<JBCXM__UsageData__c> tempList = new List<JBCXM__UsageData__c>();
                tempList.add(usageDdata);
                histroicalUsageDataMap.put(tempKey, tempList);
            }
        }
        return histroicalUsageDataMap;
    }  
    
    
    private List<JBCXM__UsageData__c> getHistoricalusageDataList(Set<Id> accountIdSet, Set<String> instanceIdSet, Set<integer> yearSet){
        return [SELECT Id, Name, JBCXM__Account__c, Active_Engagement_Count__c, anonleadnetcount__c, anonwebvisitcount__c, Balance_Black_Listed_Leads__c, 
                Balance_Bounced_Leads__c, Balance_Possible_Duplicates__c, Balance_Unsubscribed_Leads__c, batch_camp_count__c, 
                batch_camp_execution_average__c, batch_camp_execution_deviation__c, batch_camp_max_lead_count__c, batch_camp_max_seconds__c, 
                batch_camp_total_lead_count__c, batch_camp_total_seconds__c, batchcampcount__c, BatchCampZero__c, Campaign_Analysis_Count__c, 
                changedatavaluecount__c, changescorecount__c, clicklinkcount__c, CommunityIdea__c, CommunityIdeaComment__c, CommunityLogins__c, 
                CommunityQuestion__c, CommunityQuestionComment__c, Contact__c, createtaskcount__c, DataLoadId__c, JBCXM__Date__c, 
                Email_Analysis_Count__c, emailbounced__c, emailclicked__c, emaildelivered__c, emailopened__c, emailsentcount__c, 
                emailsoftbounced__c, emailunsubscribed__c, filloutformcount__c, Inactive_Engagement_Count__c, JBCXM__InstanceId__c, 
                JBCXM__InstanceName__c, known_lead_net_count__c, knownleadnetcount__c, Lead_Analysis_Count__c, leadcount__c, 
                Model_Performance_Company_Analysis_Count__c, Model_Performance_Leads_Analysis_Count__c, New_Form_Net_Count__c, newleadcount__c, 
                Opportunity_Analysis_Count__c, Opportunity_Influence_Analyzer_Count__c, JBCXM__Processed__c, Program_Analyzer_Count__c, 
                Program_Cost_Analysis_Count__c, programcount__c, Program_Membership_Analysis_Count__c, Program_Opportunity_Analysis_Count__c, 
                Program_Revenue_Stage_Analysis_Count__c, programsynccount__c, sessioncount__c, Success_Path_Analyzer_Count__c, 
                syncleadtosfdccount__c, total_session_time__c, total_soft_deleted_lead__c, total_soft_deleted_pending_lead__c, totalanonleadcount__c, 
                Total_Engagement_Count__c, totalknownleadcount__c, Usage_Data_Key__c, JBCXM__User__c, usingcostperiodcount__c, usingtagsexcludetagcount__c, 
                visitwebpagecount__c, Week_Group4_Number__c, JBCXM__WeekLabel__c, Week_Number__c, workspacecount__c, Usage_Data_Key_Indexed__c, 
                Marketo_Users__c
                FROM JBCXM__UsageData__c 
                WHERE JBCXM__Account__c in :accountIdSet 
                AND JBCXM__InstanceId__c in :instanceIdSet
                AND Year__c in :yearSet];
    }  
    
    
    private Map<Id,List<Case>> getCaseMap(Set<Id> accountIdSet){
        Map<Id,List<Case>> caseMap = new Map<Id,List<Case>>();
        for(Case cs :[SELECT id, AccountId, ClosedDate, CreatedDate, isClosed from Case WHERE AccountId in :accountIdSet]){
            if(caseMap.get(cs.AccountId) != null){
                caseMap.get(cs.AccountId).add(cs);
            }
            else{
                List<Case> caseList = new List<Case>();
                caseList.add(cs);
                caseMap.put(cs.AccountId, caseList);
            }
        }
        return caseMap;
    }
    
    
    private Map<Id, List<LoginHistory>> getAccLoginHistoryMap(Set<Id> accountIdSet, Set<Id> contactIdSet){
        Map<Id, List<LoginHistory>> accLoginHistoryMap = new Map<Id,List<LoginHistory>>();
        
        // *** Create an Account User Map ***
        Map<Id,Id> userAccountMap = new Map<Id,Id>();
        Set<Id> userIdSet = new Set<Id>();
        for(User u :[SELECT Id, ContactId, Contact.AccountId from User WHERE ContactId in :contactIdSet]){
            userIdSet.add(u.Id);
            userAccountMap.put(u.Id, u.Contact.AccountId);
        }
        
        // *** Get Login History For Users ***
        Map<Id, List<LoginHistory>> loginHistroyMap = new Map<Id, List<LoginHistory>>();
        loginHistroyMap = getLoginHistoryMap(userIdSet);
        
        // *** Create Account Login History Map ***
        for(Id userId :userAccountMap.keySet()){
            if(loginHistroyMap.get(userId) != null){
                if(accLoginHistoryMap.get(userAccountMap.get(userId))!= null){
                    accLoginHistoryMap.get(userAccountMap.get(userId)).addAll(loginHistroyMap.get(userId));
                }
                else{
                    
                    List<LoginHistory> LHistList = new List<LoginHistory>();
                    LHistList.addAll(loginHistroyMap.get(userId));
                    accLoginHistoryMap.put(userAccountMap.get(userId), LHistList);
    
                }
            }
        }    
        
        return accLoginHistoryMap;
    }
    
    
    private Set<Id> getContactIdSet(Set<Id> accountIdSet){
        Set<Id> contactIdSet = new Set<Id>();
        for(Contact con :[SELECT Id, Name, Marketo_End_User__c, CreatedDate FROM Contact 
        WHERE AccountId in :accountIdSet]){
            contactIdSet.add(con.Id);
        }
        return contactIdSet;
    }
    
    
    private Map<Id, List<LoginHistory>> getLoginHistoryMap(Set<Id> userIdSet){
        Map<Id, List<LoginHistory>> loginHistroyMap = new Map<Id, List<LoginHistory>>();
        for(LoginHistory loginHist :[SELECT id, UserId, Application, LoginTime, Status 
        FROM LoginHistory WHERE userId in :userIdSet]){
            If(loginHistroyMap.get(loginHist.UserId) != null){
                loginHistroyMap.get(loginHist.UserId).add(loginHist);
            }
            else{
                List<LoginHistory> LHistoryList = new List<LoginHistory>();
                LHistoryList.add(loginHist);
                loginHistroyMap.put(loginHist.UserId, LHistoryList);
            }
        }
        return loginHistroyMap;
    }
    
    
    private Map<Id,List<CampaignMember>> getCampaignMemberMap(Set<Id> contactIdSet){
        Map<Id,List<CampaignMember>> campaignMemberMap = new Map<Id,List<CampaignMember>>();
        
        for(CampaignMember campMemb :[SELECT Id, Contact.Account.Id from CampaignMember WHERE ContactId in :contactIdSet AND Campaign.Name Like '%Foundation%']){
            if(campaignMemberMap.get(campMemb.Contact.Account.Id) != null){
                campaignMemberMap.get(campMemb.Contact.Account.Id).add(campMemb);
            }
            else{
                List<CampaignMember> campaignMemberList = new List<CampaignMember>();
                campaignMemberList.add(campMemb);
                campaignMemberMap.put(campMemb.Contact.Account.Id, campaignMemberList);
            }
        }
        
        return campaignMemberMap;
    }
    
    
     private Map<Id,List<GS_4Weekly_Usage_Data_Contact__c>> getExistingContactUsageDataMap(Set<Id> contactIdSet, Set<String> usageDataKeySet){
         Map<Id,List<GS_4Weekly_Usage_Data_Contact__c>> existingcontactUsageDataMap = new Map<Id,List<GS_4Weekly_Usage_Data_Contact__c>>();
         for(GS_4Weekly_Usage_Data_Contact__c contactGSUsageData :getContactUsageDataList(contactIdSet, usageDataKeySet)){
             if(existingcontactUsageDataMap.get(contactGSUsageData.Contact__c) != null){
                 existingcontactUsageDataMap.get(contactGSUsageData.Contact__c).add(contactGSUsageData);
             }
             else{
                 List<GS_4Weekly_Usage_Data_Contact__c> tempConUsageDataList = new List<GS_4Weekly_Usage_Data_Contact__c>();
                 tempConUsageDataList.add(contactGSUsageData);
                 existingcontactUsageDataMap.put(contactGSUsageData.Contact__c, tempConUsageDataList);
             }  
         }
         return existingcontactUsageDataMap;
     }
     
     
     private List<GS_4Weekly_Usage_Data_Contact__c> getContactUsageDataList(Set<Id> contactIdSet, Set<String> usageDataKeySet){
         return [SELECT Id, Usage_Data_Key__c, Contact__c 
                FROM GS_4Weekly_Usage_Data_Contact__c 
                WHERE Contact__c in :contactIdSet
                AND Usage_Data_Key__c in :usageDataKeySet];
     }
     
     
     private Map<Id,List<Contact>> getContactMap(Set<Id> accountIdSet){
         Map<Id,List<Contact>> contactMap = new Map<Id,List<Contact>>();
         for(Contact con :[select Id, AccountId from Contact where AccountId in :accountIdSet AND 
         (Is_Authorized_Contact__c = 'Yes' OR 
         User_Type_Admin__c = TRUE OR 
         User_Type_System_Admin__c = TRUE/* OR 
         Marketo_Usage_Report_Opt_In__c = TRUE*/)]){
            if(contactMap.get(con.AccountId) != null){
                contactMap.get(con.AccountId).add(con);
            }
            else{
                List<Contact> conList = new List<Contact>();
                conList.add(con);
                contactMap.put(con.AccountId, conList);
            }
         }   
         return contactMap;
     }
     
     
     private void assignLatestUsageDataValues(GS_4Weekly_Usage_Data__c accountGSUsageData, JBCXM__UsageData__c latestUsageData){
        accountGSUsageData.Name = latestUsageData.Name;
        accountGSUsageData.Date__c = latestUsageData.JBCXM__Date__c;
        accountGSUsageData.Balance_Black_Listed_Leads__c = latestUsageData.Balance_Black_Listed_Leads__c;
        accountGSUsageData.Balance_Bounced_Leads__c = latestUsageData.Balance_Bounced_Leads__c;
        accountGSUsageData.Balance_Possible_Duplicates__c = latestUsageData.Balance_Possible_Duplicates__c;
        accountGSUsageData.Balance_Unsubscribed_Leads__c = latestUsageData.Balance_Unsubscribed_Leads__c;
        accountGSUsageData.Marketo_Users__c = latestUsageData.Marketo_Users__c;
        accountGSUsageData.Account__c = latestUsageData.JBCXM__Account__c;
        accountGSUsageData.DataLoadId__c = latestUsageData.DataLoadId__c;
        accountGSUsageData.Contact__c = latestUsageData.Contact__c;
        accountGSUsageData.InstanceId__c = latestUsageData.JBCXM__InstanceId__c;
        accountGSUsageData.InstanceName__c = latestUsageData.JBCXM__InstanceName__c;
        accountGSUsageData.Processed__c = latestUsageData.JBCXM__Processed__c;
        accountGSUsageData.User__c = latestUsageData.JBCXM__User__c;
        accountGSUsageData.Usage_Data_Key__c = latestUsageData.Usage_Data_Key_Indexed__c;
        accountGSUsageData.Week_Group4_Number__c = string.valueOf(integer.valueOf(latestUsageData.Week_Group4_Number__c));
     }
     
     
     private void assignValuesFromAssetsAndEntitlements(GS_4Weekly_Usage_Data__c accountGSUsageData, JBCXM__UsageData__c latestUsageData, Map<String, Asset> assetMap, Map<Id, Entitlement> entitlementMap){
         string tempKey = latestUsageData.JBCXM__Account__c+latestUsageData.JBCXM__InstanceId__c;
         if(assetMap.get(tempKey) != null){
                accountGSUsageData.Edition__c = assetMap.get(tempKey).Subscription_Type__c;
                accountGSUsageData.Purpose__c = assetMap.get(tempKey).Purpose__c;
                accountGSUsageData.DKIM__c = assetMap.get(tempKey).DKIM__c;
                accountGSUsageData.Branded_Tracking_Links__c = assetMap.get(tempKey).Branded_Link__c;
                accountGSUsageData.Acct_Prefix__c = assetMap.get(tempKey).Acct_Prefix__c;
                
                Id tempAssetId = assetMap.get(tempKey).Id;
                
                if(entitlementMap.get(tempAssetId) != null){
                    accountGSUsageData.Support_Level__c = entitlementMap.get(tempAssetId).Type;
                    accountGSUsageData.Support_Engineer__c = entitlementMap.get(tempAssetId).Named_Support_Engineer__r.FirstName +' ' +entitlementMap.get(tempAssetId).Named_Support_Engineer__r.LastName;
                }
          }    
     }
     
     
     private void initializeAccountGSUsageDataFieldsZero(GS_4Weekly_Usage_Data__c accountGSUsageData){
        accountGSUsageData.Active_Engagement_Count__c = 0;
        accountGSUsageData.anonleadnetcount__c = 0;
        accountGSUsageData.anonwebvisitcount__c = 0;
        accountGSUsageData.batch_camp_count__c = 0;
        accountGSUsageData.batch_camp_execution_average__c = 0;
        accountGSUsageData.batch_camp_execution_deviation__c = 0;
        accountGSUsageData.batch_camp_max_lead_count__c = 0;
        accountGSUsageData.batch_camp_max_seconds__c = 0;
        accountGSUsageData.batch_camp_total_lead_count__c = 0;
        accountGSUsageData.batch_camp_total_seconds__c = 0;
        accountGSUsageData.batchcampcount__c = 0;
        accountGSUsageData.Campaign_Analysis_Count__c = 0;
        accountGSUsageData.changedatavaluecount__c = 0;
        accountGSUsageData.changescorecount__c = 0;
        accountGSUsageData.clicklinkcount__c = 0;
        accountGSUsageData.CommunityIdea__c = 0;
        accountGSUsageData.CommunityIdeaComment__c = 0;
        accountGSUsageData.CommunityLogins__c = 0;
        accountGSUsageData.CommunityQuestion__c = 0;
        accountGSUsageData.CommunityQuestionComment__c = 0;
        accountGSUsageData.createtaskcount__c = 0;
        accountGSUsageData.Email_Analysis_Count__c = 0;
        accountGSUsageData.emailbounced__c = 0;
        accountGSUsageData.emailclicked__c = 0;
        accountGSUsageData.emaildelivered__c = 0;
        accountGSUsageData.emailopened__c = 0;
        accountGSUsageData.emailsentcount__c = 0;
        accountGSUsageData.emailsoftbounced__c = 0;
        accountGSUsageData.emailunsubscribed__c = 0;
        accountGSUsageData.filloutformcount__c = 0;
        accountGSUsageData.Inactive_Engagement_Count__c = 0;
        accountGSUsageData.known_lead_net_count__c = 0;
        accountGSUsageData.knownleadnetcount__c = 0;
        accountGSUsageData.Lead_Analysis_Count__c = 0;
        accountGSUsageData.leadcount__c = 0;
        accountGSUsageData.Model_Performance_Company_Analysis_Count__c = 0;
        accountGSUsageData.Model_Performance_Leads_Analysis_Count__c = 0;
        accountGSUsageData.New_Form_Net_Count__c = 0;
        accountGSUsageData.newleadcount__c = 0;
        accountGSUsageData.Opportunity_Analysis_Count__c = 0;
        accountGSUsageData.Opportunity_Influence_Analyzer_Count__c = 0;
        accountGSUsageData.Program_Analyzer_Count__c = 0;
        accountGSUsageData.Program_Cost_Analysis_Count__c = 0;
        accountGSUsageData.programcount__c = 0;
        accountGSUsageData.Program_Membership_Analysis_Count__c = 0;
        accountGSUsageData.Program_Opportunity_Analysis_Count__c = 0;
        accountGSUsageData.Program_Revenue_Stage_Analysis_Count__c = 0;
        accountGSUsageData.programsynccount__c = 0;
        accountGSUsageData.sessioncount__c = 0;
        accountGSUsageData.Success_Path_Analyzer_Count__c = 0;
        accountGSUsageData.syncleadtosfdccount__c = 0;
        accountGSUsageData.total_session_time__c = 0;
        accountGSUsageData.total_soft_deleted_lead__c = 0;
        accountGSUsageData.total_soft_deleted_pending_lead__c = 0;
        accountGSUsageData.totalanonleadcount__c = 0;
        accountGSUsageData.Total_Engagement_Count__c = 0;
        accountGSUsageData.totalknownleadcount__c = 0;
        accountGSUsageData.usingcostperiodcount__c = 0;
        accountGSUsageData.usingtagsexcludetagcount__c = 0;
        accountGSUsageData.visitwebpagecount__c = 0;
        accountGSUsageData.workspacecount__c = 0;
     }
     
     
     private void assignGroupFourTotalsToAccountGSUsageData(GS_4Weekly_Usage_Data__c accountGSUsageData, List<JBCXM__UsageData__c> usageDataGroupFourList){
         for(JBCXM__UsageData__c usageDataGroupFour :usageDataGroupFourList){
            if(usageDataGroupFour.Active_Engagement_Count__c != NULL) accountGSUsageData.Active_Engagement_Count__c = accountGSUsageData.Active_Engagement_Count__c + usageDataGroupFour.Active_Engagement_Count__c;
            if(usageDataGroupFour.anonleadnetcount__c != NULL) accountGSUsageData.anonleadnetcount__c = accountGSUsageData.anonleadnetcount__c + usageDataGroupFour.anonleadnetcount__c;
            if(usageDataGroupFour.anonwebvisitcount__c != NULL) accountGSUsageData.anonwebvisitcount__c = accountGSUsageData.anonwebvisitcount__c + usageDataGroupFour.anonwebvisitcount__c;
            if(usageDataGroupFour.batch_camp_count__c != NULL) accountGSUsageData.batch_camp_count__c = accountGSUsageData.batch_camp_count__c + usageDataGroupFour.batch_camp_count__c;
            if(usageDataGroupFour.batch_camp_execution_average__c != NULL) accountGSUsageData.batch_camp_execution_average__c = accountGSUsageData.batch_camp_execution_average__c + usageDataGroupFour.batch_camp_execution_average__c;
            if(usageDataGroupFour.batch_camp_execution_deviation__c != NULL) accountGSUsageData.batch_camp_execution_deviation__c = accountGSUsageData.batch_camp_execution_deviation__c + usageDataGroupFour.batch_camp_execution_deviation__c;
            if(usageDataGroupFour.batch_camp_max_lead_count__c != NULL) accountGSUsageData.batch_camp_max_lead_count__c = accountGSUsageData.batch_camp_max_lead_count__c + usageDataGroupFour.batch_camp_max_lead_count__c;
            if(usageDataGroupFour.batch_camp_max_seconds__c != NULL) accountGSUsageData.batch_camp_max_seconds__c = accountGSUsageData.batch_camp_max_seconds__c + usageDataGroupFour.batch_camp_max_seconds__c;
            if(usageDataGroupFour.batch_camp_total_lead_count__c != NULL) accountGSUsageData.batch_camp_total_lead_count__c = accountGSUsageData.batch_camp_total_lead_count__c + usageDataGroupFour.batch_camp_total_lead_count__c;
            if(usageDataGroupFour.batch_camp_total_seconds__c != NULL) accountGSUsageData.batch_camp_total_seconds__c = accountGSUsageData.batch_camp_total_seconds__c + usageDataGroupFour.batch_camp_total_seconds__c;
            if(usageDataGroupFour.batchcampcount__c != NULL) accountGSUsageData.batchcampcount__c = accountGSUsageData.batchcampcount__c + usageDataGroupFour.batchcampcount__c;
            if(usageDataGroupFour.Campaign_Analysis_Count__c != NULL) accountGSUsageData.Campaign_Analysis_Count__c = accountGSUsageData.Campaign_Analysis_Count__c + usageDataGroupFour.Campaign_Analysis_Count__c;
            if(usageDataGroupFour.changedatavaluecount__c != NULL) accountGSUsageData.changedatavaluecount__c = accountGSUsageData.changedatavaluecount__c + usageDataGroupFour.changedatavaluecount__c;
            if(usageDataGroupFour.changescorecount__c != NULL) accountGSUsageData.changescorecount__c = accountGSUsageData.changescorecount__c + usageDataGroupFour.changescorecount__c;
            if(usageDataGroupFour.clicklinkcount__c != NULL) accountGSUsageData.clicklinkcount__c = accountGSUsageData.clicklinkcount__c + usageDataGroupFour.clicklinkcount__c;
            if(usageDataGroupFour.CommunityIdea__c != NULL) accountGSUsageData.CommunityIdea__c = accountGSUsageData.CommunityIdea__c + usageDataGroupFour.CommunityIdea__c;
            if(usageDataGroupFour.CommunityIdeaComment__c != NULL) accountGSUsageData.CommunityIdeaComment__c = accountGSUsageData.CommunityIdeaComment__c + usageDataGroupFour.CommunityIdeaComment__c;
            if(usageDataGroupFour.CommunityLogins__c != NULL) accountGSUsageData.CommunityLogins__c = accountGSUsageData.CommunityLogins__c + usageDataGroupFour.CommunityLogins__c;
            if(usageDataGroupFour.CommunityQuestion__c != NULL) accountGSUsageData.CommunityQuestion__c = accountGSUsageData.CommunityQuestion__c + usageDataGroupFour.CommunityQuestion__c;
            if(usageDataGroupFour.CommunityQuestionComment__c != NULL) accountGSUsageData.CommunityQuestionComment__c = accountGSUsageData.CommunityQuestionComment__c + usageDataGroupFour.CommunityQuestionComment__c;
            if(usageDataGroupFour.createtaskcount__c != NULL) accountGSUsageData.createtaskcount__c = accountGSUsageData.createtaskcount__c + usageDataGroupFour.createtaskcount__c;
            if(usageDataGroupFour.Email_Analysis_Count__c != NULL) accountGSUsageData.Email_Analysis_Count__c = accountGSUsageData.Email_Analysis_Count__c + usageDataGroupFour.Email_Analysis_Count__c;
            if(usageDataGroupFour.emailbounced__c != NULL) accountGSUsageData.emailbounced__c = accountGSUsageData.emailbounced__c + usageDataGroupFour.emailbounced__c;
            if(usageDataGroupFour.emailclicked__c != NULL) accountGSUsageData.emailclicked__c = accountGSUsageData.emailclicked__c + usageDataGroupFour.emailclicked__c;
            if(usageDataGroupFour.emaildelivered__c != NULL) accountGSUsageData.emaildelivered__c = accountGSUsageData.emaildelivered__c + usageDataGroupFour.emaildelivered__c;
            if(usageDataGroupFour.emailopened__c != NULL) accountGSUsageData.emailopened__c = accountGSUsageData.emailopened__c + usageDataGroupFour.emailopened__c;
            if(usageDataGroupFour.emailsentcount__c != NULL) accountGSUsageData.emailsentcount__c = accountGSUsageData.emailsentcount__c + usageDataGroupFour.emailsentcount__c;
            if(usageDataGroupFour.emailsoftbounced__c != NULL) accountGSUsageData.emailsoftbounced__c = accountGSUsageData.emailsoftbounced__c + usageDataGroupFour.emailsoftbounced__c;
            if(usageDataGroupFour.emailunsubscribed__c != NULL) accountGSUsageData.emailunsubscribed__c = accountGSUsageData.emailunsubscribed__c + usageDataGroupFour.emailunsubscribed__c;
            if(usageDataGroupFour.filloutformcount__c != NULL) accountGSUsageData.filloutformcount__c = accountGSUsageData.filloutformcount__c + usageDataGroupFour.filloutformcount__c;
            if(usageDataGroupFour.Inactive_Engagement_Count__c != NULL) accountGSUsageData.Inactive_Engagement_Count__c = accountGSUsageData.Inactive_Engagement_Count__c + usageDataGroupFour.Inactive_Engagement_Count__c;
            if(usageDataGroupFour.known_lead_net_count__c != NULL) accountGSUsageData.known_lead_net_count__c = accountGSUsageData.known_lead_net_count__c + usageDataGroupFour.known_lead_net_count__c;
            if(usageDataGroupFour.knownleadnetcount__c != NULL) accountGSUsageData.knownleadnetcount__c = accountGSUsageData.knownleadnetcount__c + usageDataGroupFour.knownleadnetcount__c;
            if(usageDataGroupFour.Lead_Analysis_Count__c != NULL) accountGSUsageData.Lead_Analysis_Count__c = accountGSUsageData.Lead_Analysis_Count__c + usageDataGroupFour.Lead_Analysis_Count__c;
            if(usageDataGroupFour.leadcount__c != NULL) accountGSUsageData.leadcount__c = accountGSUsageData.leadcount__c + usageDataGroupFour.leadcount__c;
            if(usageDataGroupFour.Model_Performance_Company_Analysis_Count__c != NULL) accountGSUsageData.Model_Performance_Company_Analysis_Count__c = accountGSUsageData.Model_Performance_Company_Analysis_Count__c + usageDataGroupFour.Model_Performance_Company_Analysis_Count__c;
            if(usageDataGroupFour.Model_Performance_Leads_Analysis_Count__c != NULL) accountGSUsageData.Model_Performance_Leads_Analysis_Count__c = accountGSUsageData.Model_Performance_Leads_Analysis_Count__c + usageDataGroupFour.Model_Performance_Leads_Analysis_Count__c;
            if(usageDataGroupFour.New_Form_Net_Count__c != NULL) accountGSUsageData.New_Form_Net_Count__c = accountGSUsageData.New_Form_Net_Count__c + usageDataGroupFour.New_Form_Net_Count__c;
            if(usageDataGroupFour.newleadcount__c != NULL) accountGSUsageData.newleadcount__c = accountGSUsageData.newleadcount__c + usageDataGroupFour.newleadcount__c;
            if(usageDataGroupFour.Opportunity_Analysis_Count__c != NULL) accountGSUsageData.Opportunity_Analysis_Count__c = accountGSUsageData.Opportunity_Analysis_Count__c + usageDataGroupFour.Opportunity_Analysis_Count__c;
            if(usageDataGroupFour.Opportunity_Influence_Analyzer_Count__c != NULL) accountGSUsageData.Opportunity_Influence_Analyzer_Count__c = accountGSUsageData.Opportunity_Influence_Analyzer_Count__c + usageDataGroupFour.Opportunity_Influence_Analyzer_Count__c;
            if(usageDataGroupFour.Program_Analyzer_Count__c != NULL) accountGSUsageData.Program_Analyzer_Count__c = accountGSUsageData.Program_Analyzer_Count__c + usageDataGroupFour.Program_Analyzer_Count__c;
            if(usageDataGroupFour.Program_Cost_Analysis_Count__c != NULL) accountGSUsageData.Program_Cost_Analysis_Count__c = accountGSUsageData.Program_Cost_Analysis_Count__c + usageDataGroupFour.Program_Cost_Analysis_Count__c;
            if(usageDataGroupFour.programcount__c != NULL) accountGSUsageData.programcount__c = accountGSUsageData.programcount__c + usageDataGroupFour.programcount__c;
            if(usageDataGroupFour.Program_Membership_Analysis_Count__c != NULL) accountGSUsageData.Program_Membership_Analysis_Count__c = accountGSUsageData.Program_Membership_Analysis_Count__c + usageDataGroupFour.Program_Membership_Analysis_Count__c;
            if(usageDataGroupFour.Program_Opportunity_Analysis_Count__c != NULL) accountGSUsageData.Program_Opportunity_Analysis_Count__c = accountGSUsageData.Program_Opportunity_Analysis_Count__c + usageDataGroupFour.Program_Opportunity_Analysis_Count__c;
            if(usageDataGroupFour.Program_Revenue_Stage_Analysis_Count__c != NULL) accountGSUsageData.Program_Revenue_Stage_Analysis_Count__c = accountGSUsageData.Program_Revenue_Stage_Analysis_Count__c + usageDataGroupFour.Program_Revenue_Stage_Analysis_Count__c;
            if(usageDataGroupFour.programsynccount__c != NULL) accountGSUsageData.programsynccount__c = accountGSUsageData.programsynccount__c + usageDataGroupFour.programsynccount__c;
            if(usageDataGroupFour.sessioncount__c != NULL) accountGSUsageData.sessioncount__c = accountGSUsageData.sessioncount__c + usageDataGroupFour.sessioncount__c;
            if(usageDataGroupFour.Success_Path_Analyzer_Count__c != NULL) accountGSUsageData.Success_Path_Analyzer_Count__c = accountGSUsageData.Success_Path_Analyzer_Count__c + usageDataGroupFour.Success_Path_Analyzer_Count__c;
            if(usageDataGroupFour.syncleadtosfdccount__c != NULL) accountGSUsageData.syncleadtosfdccount__c = accountGSUsageData.syncleadtosfdccount__c + usageDataGroupFour.syncleadtosfdccount__c;
            if(usageDataGroupFour.total_session_time__c != NULL) accountGSUsageData.total_session_time__c = accountGSUsageData.total_session_time__c + usageDataGroupFour.total_session_time__c;
            if(usageDataGroupFour.total_soft_deleted_lead__c != NULL) accountGSUsageData.total_soft_deleted_lead__c = accountGSUsageData.total_soft_deleted_lead__c + usageDataGroupFour.total_soft_deleted_lead__c;
            if(usageDataGroupFour.total_soft_deleted_pending_lead__c != NULL) accountGSUsageData.total_soft_deleted_pending_lead__c = accountGSUsageData.total_soft_deleted_pending_lead__c + usageDataGroupFour.total_soft_deleted_pending_lead__c;
            if(usageDataGroupFour.totalanonleadcount__c != NULL) accountGSUsageData.totalanonleadcount__c = accountGSUsageData.totalanonleadcount__c + usageDataGroupFour.totalanonleadcount__c;
            if(usageDataGroupFour.Total_Engagement_Count__c != NULL) accountGSUsageData.Total_Engagement_Count__c = accountGSUsageData.Total_Engagement_Count__c + usageDataGroupFour.Total_Engagement_Count__c;
            if(usageDataGroupFour.totalknownleadcount__c != NULL) accountGSUsageData.totalknownleadcount__c = accountGSUsageData.totalknownleadcount__c + usageDataGroupFour.totalknownleadcount__c;
            if(usageDataGroupFour.usingcostperiodcount__c != NULL) accountGSUsageData.usingcostperiodcount__c = accountGSUsageData.usingcostperiodcount__c + usageDataGroupFour.usingcostperiodcount__c;
            if(usageDataGroupFour.usingtagsexcludetagcount__c != NULL) accountGSUsageData.usingtagsexcludetagcount__c = accountGSUsageData.usingtagsexcludetagcount__c + usageDataGroupFour.usingtagsexcludetagcount__c;
            if(usageDataGroupFour.visitwebpagecount__c != NULL) accountGSUsageData.visitwebpagecount__c = accountGSUsageData.visitwebpagecount__c + usageDataGroupFour.visitwebpagecount__c;
            if(usageDataGroupFour.workspacecount__c != NULL) accountGSUsageData.workspacecount__c = accountGSUsageData.workspacecount__c + usageDataGroupFour.workspacecount__c;
        }
     }
     
     
     private void initializePrevAverageValuesFieldsZero(GS_4Weekly_Usage_Data__c accountGSUsageData){
        accountGSUsageData.PrevAvg_Active_Engagement_Count__c = 0;
        accountGSUsageData.PrevAvg_anonleadnetcount__c = 0;
        accountGSUsageData.PrevAvg_anonwebvisitcount__c = 0;
        accountGSUsageData.PrevAvg_Balance_Black_Listed_Leads__c = 0;
        accountGSUsageData.PrevAvg_Balance_Bounced_Leads__c = 0;
        accountGSUsageData.PrevAvg_Balance_Possible_Duplicates__c = 0;
        accountGSUsageData.PrevAvg_Balance_Unsubscribed_Leads__c = 0;
        accountGSUsageData.PrevAvg_batch_camp_count__c = 0;
        accountGSUsageData.PrevAvg_batch_camp_execution_average__c = 0;
        accountGSUsageData.PrevAvg_batch_camp_execution_deviation__c = 0;
        accountGSUsageData.PrevAvg_batch_camp_max_lead_count__c = 0;
        accountGSUsageData.PrevAvg_batch_camp_max_seconds__c = 0;
        accountGSUsageData.PrevAvg_batch_camp_total_lead_count__c = 0;
        accountGSUsageData.PrevAvg_batch_camp_total_seconds__c = 0;
        accountGSUsageData.PrevAvg_batchcampcount__c = 0;
        accountGSUsageData.PrevAvg_Campaign_Analysis_Count__c = 0;
        accountGSUsageData.PrevAvg_changedatavaluecount__c = 0;
        accountGSUsageData.PrevAvg_changescorecount__c = 0;
        accountGSUsageData.PrevAvg_clicklinkcount__c = 0;
        accountGSUsageData.PrevAvg_CommunityIdea__c = 0;
        accountGSUsageData.PrevAvg_CommunityIdeaComment__c = 0;
        accountGSUsageData.PrevAvg_CommunityLogins__c = 0;
        accountGSUsageData.PrevAvg_CommunityQuestion__c = 0;
        accountGSUsageData.PrevAvg_CommunityQuestionComment__c = 0;
        accountGSUsageData.PrevAvg_createtaskcount__c = 0;
        accountGSUsageData.PrevAvg_Email_Analysis_Count__c = 0;
        accountGSUsageData.PrevAvg_emailbounced__c = 0;
        accountGSUsageData.PrevAvg_emailclicked__c = 0;
        accountGSUsageData.PrevAvg_emaildelivered__c = 0;
        accountGSUsageData.PrevAvg_emailopened__c = 0;
        accountGSUsageData.PrevAvg_emailsentcount__c = 0;
        accountGSUsageData.PrevAvg_emailsoftbounced__c = 0;
        accountGSUsageData.PrevAvg_emailunsubscribed__c = 0;
        accountGSUsageData.PrevAvg_filloutformcount__c = 0;
        accountGSUsageData.PrevAvg_Inactive_Engagement_Count__c = 0;
        accountGSUsageData.PrevAvg_known_lead_net_count__c = 0;
        accountGSUsageData.PrevAvg_knownleadnetcount__c = 0;
        accountGSUsageData.PrevAvg_Lead_Analysis_Count__c = 0;
        accountGSUsageData.PrevAvg_leadcount__c = 0;
        accountGSUsageData.PrevAvg_Marketo_Logins__c = 0;
        accountGSUsageData.PrevAvg_Model_Performance_Comp_Analysis__c = 0;
        accountGSUsageData.PrevAvg_Model_Performance_Leads_Analysis__c = 0;
        accountGSUsageData.PrevAvg_New_Form_Net_Count__c = 0;
        accountGSUsageData.PrevAvg_newleadcount__c = 0;
        accountGSUsageData.PrevAvg_Opportunity_Analysis_Count__c = 0;
        accountGSUsageData.PrevAvg_Opportunity_Influence_Analyzer__c = 0;
        accountGSUsageData.PrevAvg_Program_Analyzer_Count__c = 0;
        accountGSUsageData.PrevAvg_Program_Cost_Analysis_Count__c = 0;
        accountGSUsageData.PrevAvg_programcount__c = 0;
        accountGSUsageData.PrevAvg_Program_Membership_Analysis__c = 0;
        accountGSUsageData.PrevAvg_Program_Opportunity_Analysis__c = 0;
        accountGSUsageData.PrevAvg_Program_Revenue_Stage_Analysis__c = 0;
        accountGSUsageData.PrevAvg_programsynccount__c = 0;
        accountGSUsageData.PrevAvg_sessioncount__c = 0;
        accountGSUsageData.PrevAvg_Success_Path_Analyzer_Count__c = 0;
        accountGSUsageData.PrevAvg_syncleadtosfdccount__c = 0;
        accountGSUsageData.PrevAvg_total_session_time__c = 0;
        accountGSUsageData.PrevAvg_total_soft_deleted_lead__c = 0;
        accountGSUsageData.PrevAvg_total_soft_deleted_pending_lead__c = 0;
        accountGSUsageData.PrevAvg_totalanonleadcount__c = 0;
        accountGSUsageData.PrevAvg_Total_Engagement_Count__c = 0;
        accountGSUsageData.PrevAvg_totalknownleadcount__c = 0;
        accountGSUsageData.PrevAvg_usingcostperiodcount__c = 0;
        accountGSUsageData.PrevAvg_usingtagsexcludetagcount__c = 0;
        accountGSUsageData.PrevAvg_visitwebpagecount__c = 0;
        accountGSUsageData.PrevAvg_workspacecount__c = 0;
        accountGSUsageData.PrevAvg_Marketo_Users__c = 0;
     }
     
     
     private void assignPrevAvgStartDateEndDate(GS_4Weekly_Usage_Data__c accountGSUsageData, List<JBCXM__UsageData__c> usageDataGroupFourList){
        integer tempMinWeekNumber = integer.ValueOf(accountGSUsageData.Week_Group4_Number__c) * 4 - 16;
        integer minYear = accountGSUsageData.Date__c.Year();
        
        if(tempMinWeekNumber <= 0){
            minYear = minYear - 1;
            tempMinWeekNumber = 52 + tempMinWeekNumber;
        }
        
        integer tempMaxWeekNumber = integer.ValueOf(accountGSUsageData.Week_Group4_Number__c) * 4 - 4;
        integer maxYear = accountGSUsageData.Date__c.Year();
        
        if(tempMaxWeekNumber <= 0){
            maxYear = maxYear - 1;
            tempMaxWeekNumber = 52 + tempMaxWeekNumber;
        }
        
        Date minDate;
        Date maxDate;
        
        for(JBCXM__UsageData__c usageData :usageDataGroupFourList){
            if(usageData.JBCXM__Date__c.Year() == minYear && usageData.Week_Number__c == tempMinWeekNumber){
                minDate = usageData.JBCXM__Date__c;
            }
            
            if(usageData.JBCXM__Date__c.Year() == maxYear && usageData.Week_Number__c == tempMaxWeekNumber){
                maxDate = usageData.JBCXM__Date__c;
            }
        }
        
        if(tempMinWeekNumber == 52)
            accountGSUsageData.PrevAvg_Start_Week__c = 1;
        else    
            accountGSUsageData.PrevAvg_Start_Week__c = tempMinWeekNumber + 1;
        accountGSUsageData.PrevAvg_End_Week__c = tempMaxWeekNumber;
        accountGSUsageData.PrevAvg_Start_Date__c = minDate;
        accountGSUsageData.PrevAvg_End_Date__c = maxDate;
     }
     
     
     private void assignPrevAvgForAllOtherFields(GS_4Weekly_Usage_Data__c accountGSUsageData, List<JBCXM__UsageData__c> usageDataGroupFourList){
         for(JBCXM__UsageData__c usageData :usageDataGroupFourList){
             if(usageData.JBCXM__Date__c > accountGSUsageData.PrevAvg_Start_Date__c && usageData.JBCXM__Date__c <= accountGSUsageData.PrevAvg_End_Date__c){ 
                IF(usageData.anonleadnetcount__c!=NULL) accountGSUsageData.PrevAvg_anonleadnetcount__c = accountGSUsageData.PrevAvg_anonleadnetcount__c + usageData.anonleadnetcount__c;
                IF(usageData.anonwebvisitcount__c!=NULL) accountGSUsageData.PrevAvg_anonwebvisitcount__c = accountGSUsageData.PrevAvg_anonwebvisitcount__c + usageData.anonwebvisitcount__c;
                IF(usageData.Active_Engagement_Count__c!=NULL) accountGSUsageData.PrevAvg_Active_Engagement_Count__c = accountGSUsageData.PrevAvg_Active_Engagement_Count__c + usageData.Active_Engagement_Count__c;
                IF(usageData.Balance_Black_Listed_Leads__c!=NULL) accountGSUsageData.PrevAvg_Balance_Black_Listed_Leads__c = accountGSUsageData.PrevAvg_Balance_Black_Listed_Leads__c + usageData.Balance_Black_Listed_Leads__c;
                IF(usageData.Balance_Bounced_Leads__c!=NULL) accountGSUsageData.PrevAvg_Balance_Bounced_Leads__c = accountGSUsageData.PrevAvg_Balance_Bounced_Leads__c + usageData.Balance_Bounced_Leads__c;
                IF(usageData.Balance_Possible_Duplicates__c!=NULL) accountGSUsageData.PrevAvg_Balance_Possible_Duplicates__c = accountGSUsageData.PrevAvg_Balance_Possible_Duplicates__c + usageData.Balance_Possible_Duplicates__c;
                IF(usageData.Balance_Unsubscribed_Leads__c!=NULL) accountGSUsageData.PrevAvg_Balance_Unsubscribed_Leads__c = accountGSUsageData.PrevAvg_Balance_Unsubscribed_Leads__c + usageData.Balance_Unsubscribed_Leads__c;
                IF(usageData.batch_camp_count__c!=NULL) accountGSUsageData.PrevAvg_batch_camp_count__c = accountGSUsageData.PrevAvg_batch_camp_count__c + usageData.batch_camp_count__c;
                IF(usageData.batch_camp_execution_average__c!=NULL) accountGSUsageData.PrevAvg_batch_camp_execution_average__c = accountGSUsageData.PrevAvg_batch_camp_execution_average__c    + usageData.batch_camp_execution_average__c;
                IF(usageData.batch_camp_execution_deviation__c!=NULL) accountGSUsageData.PrevAvg_batch_camp_execution_deviation__c = accountGSUsageData.PrevAvg_batch_camp_execution_deviation__c + usageData.batch_camp_execution_deviation__c;
                IF(usageData.batch_camp_max_lead_count__c!=NULL) accountGSUsageData.PrevAvg_batch_camp_max_lead_count__c = accountGSUsageData.PrevAvg_batch_camp_max_lead_count__c + usageData.batch_camp_max_lead_count__c;
                IF(usageData.batch_camp_max_seconds__c!=NULL) accountGSUsageData.PrevAvg_batch_camp_max_seconds__c = accountGSUsageData.PrevAvg_batch_camp_max_seconds__c + usageData.batch_camp_max_seconds__c;
                IF(usageData.batch_camp_total_lead_count__c!=NULL) accountGSUsageData.PrevAvg_batch_camp_total_lead_count__c = accountGSUsageData.PrevAvg_batch_camp_total_lead_count__c + usageData.batch_camp_total_lead_count__c;
                IF(usageData.batch_camp_total_seconds__c!=NULL) accountGSUsageData.PrevAvg_batch_camp_total_seconds__c = accountGSUsageData.PrevAvg_batch_camp_total_seconds__c + usageData.batch_camp_total_seconds__c;
                IF(usageData.batchcampcount__c!=NULL) accountGSUsageData.PrevAvg_batchcampcount__c = accountGSUsageData.PrevAvg_batchcampcount__c + usageData.batchcampcount__c;
                IF(usageData.Campaign_Analysis_Count__c!=NULL) accountGSUsageData.PrevAvg_Campaign_Analysis_Count__c = accountGSUsageData.PrevAvg_Campaign_Analysis_Count__c + usageData.Campaign_Analysis_Count__c;
                IF(usageData.changedatavaluecount__c!=NULL) accountGSUsageData.PrevAvg_changedatavaluecount__c = accountGSUsageData.PrevAvg_changedatavaluecount__c + usageData.changedatavaluecount__c;
                IF(usageData.changescorecount__c!=NULL) accountGSUsageData.PrevAvg_changescorecount__c = accountGSUsageData.PrevAvg_changescorecount__c + usageData.changescorecount__c;
                IF(usageData.clicklinkcount__c!=NULL) accountGSUsageData.PrevAvg_clicklinkcount__c = accountGSUsageData.PrevAvg_clicklinkcount__c + usageData.clicklinkcount__c;
                IF(usageData.CommunityIdea__c!=NULL) accountGSUsageData.PrevAvg_CommunityIdea__c = accountGSUsageData.PrevAvg_CommunityIdea__c + usageData.CommunityIdea__c;
                IF(usageData.CommunityIdeaComment__c!=NULL) accountGSUsageData.PrevAvg_CommunityIdeaComment__c = accountGSUsageData.PrevAvg_CommunityIdeaComment__c + usageData.CommunityIdeaComment__c;
                IF(usageData.CommunityLogins__c!=NULL) accountGSUsageData.PrevAvg_CommunityLogins__c = accountGSUsageData.PrevAvg_CommunityLogins__c + usageData.CommunityLogins__c;
                IF(usageData.CommunityQuestion__c!=NULL) accountGSUsageData.PrevAvg_CommunityQuestion__c = accountGSUsageData.PrevAvg_CommunityQuestion__c + usageData.CommunityQuestion__c;
                IF(usageData.CommunityQuestionComment__c!=NULL) accountGSUsageData.PrevAvg_CommunityQuestionComment__c = accountGSUsageData.PrevAvg_CommunityQuestionComment__c + usageData.CommunityQuestionComment__c;
                IF(usageData.createtaskcount__c!=NULL) accountGSUsageData.PrevAvg_createtaskcount__c = accountGSUsageData.PrevAvg_createtaskcount__c + usageData.createtaskcount__c;
                IF(usageData.Email_Analysis_Count__c!=NULL) accountGSUsageData.PrevAvg_Email_Analysis_Count__c = accountGSUsageData.PrevAvg_Email_Analysis_Count__c + usageData.Email_Analysis_Count__c;
                IF(usageData.emailbounced__c!=NULL) accountGSUsageData.PrevAvg_emailbounced__c = accountGSUsageData.PrevAvg_emailbounced__c + usageData.emailbounced__c;
                IF(usageData.emailclicked__c!=NULL) accountGSUsageData.PrevAvg_emailclicked__c = accountGSUsageData.PrevAvg_emailclicked__c + usageData.emailclicked__c;
                IF(usageData.emaildelivered__c!=NULL) accountGSUsageData.PrevAvg_emaildelivered__c = accountGSUsageData.PrevAvg_emaildelivered__c + usageData.emaildelivered__c;
                IF(usageData.emailopened__c!=NULL) accountGSUsageData.PrevAvg_emailopened__c = accountGSUsageData.PrevAvg_emailopened__c + usageData.emailopened__c;
                IF(usageData.emailsentcount__c!=NULL) accountGSUsageData.PrevAvg_emailsentcount__c = accountGSUsageData.PrevAvg_emailsentcount__c + usageData.emailsentcount__c;
                IF(usageData.emailsoftbounced__c!=NULL) accountGSUsageData.PrevAvg_emailsoftbounced__c = accountGSUsageData.PrevAvg_emailsoftbounced__c + usageData.emailsoftbounced__c;
                IF(usageData.emailunsubscribed__c!=NULL) accountGSUsageData.PrevAvg_emailunsubscribed__c = accountGSUsageData.PrevAvg_emailunsubscribed__c + usageData.emailunsubscribed__c;
                IF(usageData.filloutformcount__c!=NULL) accountGSUsageData.PrevAvg_filloutformcount__c = accountGSUsageData.PrevAvg_filloutformcount__c + usageData.filloutformcount__c;
                IF(usageData.Inactive_Engagement_Count__c!=NULL) accountGSUsageData.PrevAvg_Inactive_Engagement_Count__c = accountGSUsageData.PrevAvg_Inactive_Engagement_Count__c + usageData.Inactive_Engagement_Count__c;
                IF(usageData.known_lead_net_count__c!=NULL) accountGSUsageData.PrevAvg_known_lead_net_count__c = accountGSUsageData.PrevAvg_known_lead_net_count__c + usageData.known_lead_net_count__c;
                IF(usageData.knownleadnetcount__c!=NULL) accountGSUsageData.PrevAvg_knownleadnetcount__c = accountGSUsageData.PrevAvg_knownleadnetcount__c + usageData.knownleadnetcount__c;
                IF(usageData.Lead_Analysis_Count__c!=NULL) accountGSUsageData.PrevAvg_Lead_Analysis_Count__c = accountGSUsageData.PrevAvg_Lead_Analysis_Count__c + usageData.Lead_Analysis_Count__c;
                IF(usageData.leadcount__c!=NULL) accountGSUsageData.PrevAvg_leadcount__c = accountGSUsageData.PrevAvg_leadcount__c + usageData.leadcount__c;
                IF(usageData.Model_Performance_Company_Analysis_Count__c!=NULL) accountGSUsageData.PrevAvg_Model_Performance_Comp_Analysis__c = accountGSUsageData.PrevAvg_Model_Performance_Comp_Analysis__c + usageData.Model_Performance_Company_Analysis_Count__c;
                IF(usageData.Model_Performance_Leads_Analysis_Count__c!=NULL) accountGSUsageData.PrevAvg_Model_Performance_Leads_Analysis__c = accountGSUsageData.PrevAvg_Model_Performance_Leads_Analysis__c + usageData.Model_Performance_Leads_Analysis_Count__c;
                IF(usageData.New_Form_Net_Count__c!=NULL) accountGSUsageData.PrevAvg_New_Form_Net_Count__c = accountGSUsageData.PrevAvg_New_Form_Net_Count__c + usageData.New_Form_Net_Count__c;
                IF(usageData.newleadcount__c!=NULL) accountGSUsageData.PrevAvg_newleadcount__c = accountGSUsageData.PrevAvg_newleadcount__c + usageData.newleadcount__c;
                IF(usageData.Opportunity_Analysis_Count__c!=NULL) accountGSUsageData.PrevAvg_Opportunity_Analysis_Count__c = accountGSUsageData.PrevAvg_Opportunity_Analysis_Count__c + usageData.Opportunity_Analysis_Count__c;
                IF(usageData.Opportunity_Influence_Analyzer_Count__c!=NULL) accountGSUsageData.PrevAvg_Opportunity_Influence_Analyzer__c = accountGSUsageData.PrevAvg_Opportunity_Influence_Analyzer__c + usageData.Opportunity_Influence_Analyzer_Count__c;
                IF(usageData.Program_Analyzer_Count__c!=NULL) accountGSUsageData.PrevAvg_Program_Analyzer_Count__c = accountGSUsageData.PrevAvg_Program_Analyzer_Count__c + usageData.Program_Analyzer_Count__c;
                IF(usageData.Program_Cost_Analysis_Count__c!=NULL) accountGSUsageData.PrevAvg_Program_Cost_Analysis_Count__c = accountGSUsageData.PrevAvg_Program_Cost_Analysis_Count__c + usageData.Program_Cost_Analysis_Count__c;
                IF(usageData.programcount__c!=NULL) accountGSUsageData.PrevAvg_programcount__c = accountGSUsageData.PrevAvg_programcount__c + usageData.programcount__c;
                IF(usageData.Program_Membership_Analysis_Count__c!=NULL) accountGSUsageData.PrevAvg_Program_Membership_Analysis__c = accountGSUsageData.PrevAvg_Program_Membership_Analysis__c + usageData.Program_Membership_Analysis_Count__c;
                IF(usageData.Program_Opportunity_Analysis_Count__c!=NULL) accountGSUsageData.PrevAvg_Program_Opportunity_Analysis__c = accountGSUsageData.PrevAvg_Program_Opportunity_Analysis__c + usageData.Program_Opportunity_Analysis_Count__c;
                IF(usageData.Program_Revenue_Stage_Analysis_Count__c!=NULL) accountGSUsageData.PrevAvg_Program_Revenue_Stage_Analysis__c = accountGSUsageData.PrevAvg_Program_Revenue_Stage_Analysis__c + usageData.Program_Revenue_Stage_Analysis_Count__c;
                IF(usageData.programsynccount__c!=NULL) accountGSUsageData.PrevAvg_programsynccount__c = accountGSUsageData.PrevAvg_programsynccount__c + usageData.programsynccount__c;
                IF(usageData.sessioncount__c!=NULL) accountGSUsageData.PrevAvg_sessioncount__c = accountGSUsageData.PrevAvg_sessioncount__c + usageData.sessioncount__c;
                IF(usageData.Success_Path_Analyzer_Count__c!=NULL) accountGSUsageData.PrevAvg_Success_Path_Analyzer_Count__c = accountGSUsageData.PrevAvg_Success_Path_Analyzer_Count__c + usageData.Success_Path_Analyzer_Count__c;
                IF(usageData.syncleadtosfdccount__c!=NULL) accountGSUsageData.PrevAvg_syncleadtosfdccount__c = accountGSUsageData.PrevAvg_syncleadtosfdccount__c + usageData.syncleadtosfdccount__c;
                IF(usageData.total_session_time__c!=NULL) accountGSUsageData.PrevAvg_total_session_time__c = accountGSUsageData.PrevAvg_total_session_time__c + usageData.total_session_time__c;
                IF(usageData.total_soft_deleted_lead__c!=NULL) accountGSUsageData.PrevAvg_total_soft_deleted_lead__c = accountGSUsageData.PrevAvg_total_soft_deleted_lead__c + usageData.total_soft_deleted_lead__c;
                IF(usageData.total_soft_deleted_pending_lead__c!=NULL) accountGSUsageData.PrevAvg_total_soft_deleted_pending_lead__c = accountGSUsageData.PrevAvg_total_soft_deleted_pending_lead__c + usageData.total_soft_deleted_pending_lead__c;
                IF(usageData.totalanonleadcount__c!=NULL) accountGSUsageData.PrevAvg_totalanonleadcount__c = accountGSUsageData.PrevAvg_totalanonleadcount__c + usageData.totalanonleadcount__c;
                IF(usageData.Total_Engagement_Count__c!=NULL) accountGSUsageData.PrevAvg_Total_Engagement_Count__c = accountGSUsageData.PrevAvg_Total_Engagement_Count__c + usageData.Total_Engagement_Count__c;
                IF(usageData.totalknownleadcount__c!=NULL) accountGSUsageData.PrevAvg_totalknownleadcount__c = accountGSUsageData.PrevAvg_totalknownleadcount__c + usageData.totalknownleadcount__c;
                IF(usageData.usingcostperiodcount__c!=NULL) accountGSUsageData.PrevAvg_usingcostperiodcount__c = accountGSUsageData.PrevAvg_usingcostperiodcount__c + usageData.usingcostperiodcount__c;
                IF(usageData.visitwebpagecount__c!=NULL) accountGSUsageData.PrevAvg_usingtagsexcludetagcount__c = accountGSUsageData.PrevAvg_usingtagsexcludetagcount__c + usageData.visitwebpagecount__c;
                IF(usageData.visitwebpagecount__c!=NULL) accountGSUsageData.PrevAvg_visitwebpagecount__c = accountGSUsageData.PrevAvg_visitwebpagecount__c + usageData.visitwebpagecount__c;
                IF(usageData.workspacecount__c!=NULL) accountGSUsageData.PrevAvg_workspacecount__c = accountGSUsageData.PrevAvg_workspacecount__c + usageData.workspacecount__c;
                IF(usageData.Marketo_Users__c!=NULL) accountGSUsageData.PrevAvg_Marketo_Users__c = accountGSUsageData.PrevAvg_Marketo_Users__c + usageData.Marketo_Users__c;
             }
         }
         getPrevAvgInternal(accountGSUsageData);
     }
     
     
     private void getPrevAvgInternal(GS_4Weekly_Usage_Data__c accountGSUsageData){
        integer tempDivisor = 3;
        accountGSUsageData.PrevAvg_Active_Engagement_Count__c = Math.round(accountGSUsageData.PrevAvg_Active_Engagement_Count__c / tempDivisor);
        accountGSUsageData.PrevAvg_anonleadnetcount__c = Math.round(accountGSUsageData.PrevAvg_anonleadnetcount__c / tempDivisor);
        accountGSUsageData.PrevAvg_anonwebvisitcount__c = Math.round(accountGSUsageData.PrevAvg_anonwebvisitcount__c / tempDivisor);
        accountGSUsageData.PrevAvg_Balance_Black_Listed_Leads__c = Math.round(accountGSUsageData.PrevAvg_Balance_Black_Listed_Leads__c / 12);
        accountGSUsageData.PrevAvg_Balance_Bounced_Leads__c = Math.round(accountGSUsageData.PrevAvg_Balance_Bounced_Leads__c / 12);
        accountGSUsageData.PrevAvg_Balance_Possible_Duplicates__c = Math.round(accountGSUsageData.PrevAvg_Balance_Possible_Duplicates__c / 12);
        accountGSUsageData.PrevAvg_Balance_Unsubscribed_Leads__c = Math.round(accountGSUsageData.PrevAvg_Balance_Unsubscribed_Leads__c / 12);
        accountGSUsageData.PrevAvg_Marketo_Users__c = Math.round(accountGSUsageData.PrevAvg_Marketo_Users__c / 12);
        accountGSUsageData.PrevAvg_batch_camp_count__c = Math.round(accountGSUsageData.PrevAvg_batch_camp_count__c / tempDivisor);
        accountGSUsageData.PrevAvg_batch_camp_execution_average__c = Math.round(accountGSUsageData.PrevAvg_batch_camp_execution_average__c / tempDivisor);
        accountGSUsageData.PrevAvg_batch_camp_execution_deviation__c = Math.round(accountGSUsageData.PrevAvg_batch_camp_execution_deviation__c / tempDivisor);
        accountGSUsageData.PrevAvg_batch_camp_max_lead_count__c = Math.round(accountGSUsageData.PrevAvg_batch_camp_max_lead_count__c / tempDivisor);
        accountGSUsageData.PrevAvg_batch_camp_max_seconds__c = Math.round(accountGSUsageData.PrevAvg_batch_camp_max_seconds__c / tempDivisor);
        accountGSUsageData.PrevAvg_batch_camp_total_lead_count__c = Math.round(accountGSUsageData.PrevAvg_batch_camp_total_lead_count__c / tempDivisor);
        accountGSUsageData.PrevAvg_batch_camp_total_seconds__c = Math.round(accountGSUsageData.PrevAvg_batch_camp_total_seconds__c / tempDivisor);
        accountGSUsageData.PrevAvg_batchcampcount__c = Math.round(accountGSUsageData.PrevAvg_batchcampcount__c / tempDivisor);
        accountGSUsageData.PrevAvg_Campaign_Analysis_Count__c = Math.round(accountGSUsageData.PrevAvg_Campaign_Analysis_Count__c / tempDivisor);
        accountGSUsageData.PrevAvg_changedatavaluecount__c = Math.round(accountGSUsageData.PrevAvg_changedatavaluecount__c / tempDivisor);
        accountGSUsageData.PrevAvg_changescorecount__c = Math.round(accountGSUsageData.PrevAvg_changescorecount__c / tempDivisor);
        accountGSUsageData.PrevAvg_clicklinkcount__c = Math.round(accountGSUsageData.PrevAvg_clicklinkcount__c / tempDivisor);
        accountGSUsageData.PrevAvg_CommunityIdea__c = Math.round(accountGSUsageData.PrevAvg_CommunityIdea__c / tempDivisor);
        accountGSUsageData.PrevAvg_CommunityIdeaComment__c = Math.round(accountGSUsageData.PrevAvg_CommunityIdeaComment__c / tempDivisor);
        accountGSUsageData.PrevAvg_CommunityLogins__c = Math.round(accountGSUsageData.PrevAvg_CommunityLogins__c / tempDivisor);
        accountGSUsageData.PrevAvg_CommunityQuestion__c = Math.round(accountGSUsageData.PrevAvg_CommunityQuestion__c / tempDivisor);
        accountGSUsageData.PrevAvg_CommunityQuestionComment__c = Math.round(accountGSUsageData.PrevAvg_CommunityQuestionComment__c / tempDivisor);
        accountGSUsageData.PrevAvg_createtaskcount__c = Math.round(accountGSUsageData.PrevAvg_createtaskcount__c / tempDivisor);
        accountGSUsageData.PrevAvg_Email_Analysis_Count__c = Math.round(accountGSUsageData.PrevAvg_Email_Analysis_Count__c / tempDivisor);
        accountGSUsageData.PrevAvg_emailbounced__c = Math.round(accountGSUsageData.PrevAvg_emailbounced__c / tempDivisor);
        accountGSUsageData.PrevAvg_emailclicked__c = Math.round(accountGSUsageData.PrevAvg_emailclicked__c / tempDivisor);
        accountGSUsageData.PrevAvg_emaildelivered__c = Math.round(accountGSUsageData.PrevAvg_emaildelivered__c / tempDivisor);
        accountGSUsageData.PrevAvg_emailopened__c = Math.round(accountGSUsageData.PrevAvg_emailopened__c / tempDivisor);
        accountGSUsageData.PrevAvg_emailsentcount__c = Math.round(accountGSUsageData.PrevAvg_emailsentcount__c / tempDivisor);
        accountGSUsageData.PrevAvg_emailsoftbounced__c = Math.round(accountGSUsageData.PrevAvg_emailsoftbounced__c / tempDivisor);
        accountGSUsageData.PrevAvg_emailunsubscribed__c = Math.round(accountGSUsageData.PrevAvg_emailunsubscribed__c / tempDivisor);
        accountGSUsageData.PrevAvg_filloutformcount__c = Math.round(accountGSUsageData.PrevAvg_filloutformcount__c / tempDivisor);
        accountGSUsageData.PrevAvg_Inactive_Engagement_Count__c = Math.round(accountGSUsageData.PrevAvg_Inactive_Engagement_Count__c / tempDivisor);
        accountGSUsageData.PrevAvg_known_lead_net_count__c = Math.round(accountGSUsageData.PrevAvg_known_lead_net_count__c / tempDivisor);
        accountGSUsageData.PrevAvg_knownleadnetcount__c = Math.round(accountGSUsageData.PrevAvg_knownleadnetcount__c / tempDivisor);
        accountGSUsageData.PrevAvg_Lead_Analysis_Count__c = Math.round(accountGSUsageData.PrevAvg_Lead_Analysis_Count__c / tempDivisor);
        accountGSUsageData.PrevAvg_leadcount__c = Math.round(accountGSUsageData.PrevAvg_leadcount__c / tempDivisor);
        accountGSUsageData.PrevAvg_Model_Performance_Comp_Analysis__c = Math.round(accountGSUsageData.PrevAvg_Model_Performance_Comp_Analysis__c / tempDivisor);
        accountGSUsageData.PrevAvg_Model_Performance_Leads_Analysis__c = Math.round(accountGSUsageData.PrevAvg_Model_Performance_Leads_Analysis__c / tempDivisor);
        accountGSUsageData.PrevAvg_New_Form_Net_Count__c = Math.round(accountGSUsageData.PrevAvg_New_Form_Net_Count__c / tempDivisor);
        accountGSUsageData.PrevAvg_newleadcount__c = Math.round(accountGSUsageData.PrevAvg_newleadcount__c / tempDivisor);
        accountGSUsageData.PrevAvg_Opportunity_Analysis_Count__c = Math.round(accountGSUsageData.PrevAvg_Opportunity_Analysis_Count__c / tempDivisor);
        accountGSUsageData.PrevAvg_Opportunity_Influence_Analyzer__c = Math.round(accountGSUsageData.PrevAvg_Opportunity_Influence_Analyzer__c / tempDivisor);
        accountGSUsageData.PrevAvg_Program_Analyzer_Count__c = Math.round(accountGSUsageData.PrevAvg_Program_Analyzer_Count__c / tempDivisor);
        accountGSUsageData.PrevAvg_Program_Cost_Analysis_Count__c = Math.round(accountGSUsageData.PrevAvg_Program_Cost_Analysis_Count__c / tempDivisor);
        accountGSUsageData.PrevAvg_programcount__c = Math.round(accountGSUsageData.PrevAvg_programcount__c / tempDivisor);
        accountGSUsageData.PrevAvg_Program_Membership_Analysis__c = Math.round(accountGSUsageData.PrevAvg_Program_Membership_Analysis__c / tempDivisor);
        accountGSUsageData.PrevAvg_Program_Opportunity_Analysis__c = Math.round(accountGSUsageData.PrevAvg_Program_Opportunity_Analysis__c / tempDivisor);
        accountGSUsageData.PrevAvg_Program_Revenue_Stage_Analysis__c = Math.round(accountGSUsageData.PrevAvg_Program_Revenue_Stage_Analysis__c / tempDivisor);
        accountGSUsageData.PrevAvg_programsynccount__c = Math.round(accountGSUsageData.PrevAvg_programsynccount__c / tempDivisor);
        accountGSUsageData.PrevAvg_sessioncount__c = Math.round(accountGSUsageData.PrevAvg_sessioncount__c / tempDivisor);
        accountGSUsageData.PrevAvg_Success_Path_Analyzer_Count__c = Math.round(accountGSUsageData.PrevAvg_Success_Path_Analyzer_Count__c / tempDivisor);
        accountGSUsageData.PrevAvg_syncleadtosfdccount__c = Math.round(accountGSUsageData.PrevAvg_syncleadtosfdccount__c / tempDivisor);
        accountGSUsageData.PrevAvg_total_session_time__c = Math.round(accountGSUsageData.PrevAvg_total_session_time__c / tempDivisor);
        accountGSUsageData.PrevAvg_total_soft_deleted_lead__c = Math.round(accountGSUsageData.PrevAvg_total_soft_deleted_lead__c / tempDivisor);
        accountGSUsageData.PrevAvg_total_soft_deleted_pending_lead__c = Math.round(accountGSUsageData.PrevAvg_total_soft_deleted_pending_lead__c / tempDivisor);
        accountGSUsageData.PrevAvg_totalanonleadcount__c = Math.round(accountGSUsageData.PrevAvg_totalanonleadcount__c / tempDivisor);
        accountGSUsageData.PrevAvg_Total_Engagement_Count__c = Math.round(accountGSUsageData.PrevAvg_Total_Engagement_Count__c / tempDivisor);
        accountGSUsageData.PrevAvg_totalknownleadcount__c = Math.round(accountGSUsageData.PrevAvg_totalknownleadcount__c / tempDivisor);
        accountGSUsageData.PrevAvg_usingcostperiodcount__c = Math.round(accountGSUsageData.PrevAvg_usingcostperiodcount__c / tempDivisor);
        accountGSUsageData.PrevAvg_usingtagsexcludetagcount__c = Math.round(accountGSUsageData.PrevAvg_usingtagsexcludetagcount__c / tempDivisor);
        accountGSUsageData.PrevAvg_visitwebpagecount__c = Math.round(accountGSUsageData.PrevAvg_visitwebpagecount__c / tempDivisor);
        accountGSUsageData.PrevAvg_workspacecount__c = Math.round(accountGSUsageData.PrevAvg_workspacecount__c / tempDivisor);
     }
     
     
     private void assignCaseRelatedDetails(GS_4Weekly_Usage_Data__c accountGSUsageData, List<Case> caseList){
         for(Case cs :caseList){
            if(Date.ValueOf(cs.CreatedDate) >= accountGSUsageData.PrevAvg_Start_Date__c && Date.ValueOf(cs.CreatedDate) <= accountGSUsageData.PrevAvg_End_Date__c){
                accountGSUsageData.PrevAvg_Tickets_Created__c = accountGSUsageData.PrevAvg_Tickets_Created__c + 1;
            }
            
            if(Date.ValueOf(cs.CreatedDate) >= accountGSUsageData.Start_Date__c && Date.ValueOf(cs.CreatedDate) <= accountGSUsageData.Date__c){
                accountGSUsageData.Tickets_Created__c = accountGSUsageData.Tickets_Created__c + 1;
            }
            
             if(cs.isClosed == FALSE){
                 accountGSUsageData.Tickets_Currently_Open__c = accountGSUsageData.Tickets_Currently_Open__c + 1;
             }
        }
        accountGSUsageData.PrevAvg_Tickets_Created__c = Math.round(accountGSUsageData.PrevAvg_Tickets_Created__c / 3);
     }
     
     
     private void assignLoginHistoryDetails(GS_4Weekly_Usage_Data__c accountGSUsageData, List<LoginHistory> loginHistoryList){
         for(LoginHistory lHistory :loginHistoryList){
            if(lHistory.Status == 'Success' && lHistory.LoginTime >= accountGSUsageData.PrevAvg_Start_Date__c && lHistory.LoginTime <= accountGSUsageData.PrevAvg_End_Date__c){
                accountGSUsageData.PrevAvg_SFDC_Logins__c = accountGSUsageData.PrevAvg_SFDC_Logins__c + 1;
            }
            
            if(lHistory.Status == 'Success' && lHistory.LoginTime >= accountGSUsageData.Start_Date__c && lHistory.LoginTime <= accountGSUsageData.Date__c){
                accountGSUsageData.SFDC_Logins__c = accountGSUsageData.SFDC_Logins__c + 1;
            }
         }
         accountGSUsageData.PrevAvg_SFDC_Logins__c = Math.round(accountGSUsageData.PrevAvg_SFDC_Logins__c / 3);
     }
     
     
     private GS_4Weekly_Usage_Data_Contact__c getTempContactUsageData(GS_4Weekly_Usage_Data__c accountGSUsageData){
         GS_4Weekly_Usage_Data_Contact__c tempContactUsageData = new GS_4Weekly_Usage_Data_Contact__c(
            Name = accountGSUsageData.Name,
            Acct_Prefix__c = accountGSUsageData.Acct_Prefix__c,
            Active_Engagement_Count__c = accountGSUsageData.Active_Engagement_Count__c,
            anonleadnetcount__c = accountGSUsageData.anonleadnetcount__c,
            anonwebvisitcount__c = accountGSUsageData.anonwebvisitcount__c,
            Balance_Black_Listed_Leads__c = accountGSUsageData.Balance_Black_Listed_Leads__c,
            Balance_Bounced_Leads__c = accountGSUsageData.Balance_Bounced_Leads__c,
            Balance_Possible_Duplicates__c = accountGSUsageData.Balance_Possible_Duplicates__c,
            Balance_Unsubscribed_Leads__c = accountGSUsageData.Balance_Unsubscribed_Leads__c,
            batch_camp_count__c = accountGSUsageData.batch_camp_count__c,
            batch_camp_execution_average__c = accountGSUsageData.batch_camp_execution_average__c,
            batch_camp_execution_deviation__c = accountGSUsageData.batch_camp_execution_deviation__c,
            batch_camp_max_lead_count__c = accountGSUsageData.batch_camp_max_lead_count__c,
            batch_camp_max_seconds__c = accountGSUsageData.batch_camp_max_seconds__c,
            batch_camp_total_lead_count__c = accountGSUsageData.batch_camp_total_lead_count__c,
            batch_camp_total_seconds__c = accountGSUsageData.batch_camp_total_seconds__c,
            batchcampcount__c = accountGSUsageData.batchcampcount__c,
            Branded_Tracking_Links__c = accountGSUsageData.Branded_Tracking_Links__c,
            Campaign_Analysis_Count__c = accountGSUsageData.Campaign_Analysis_Count__c,
            changedatavaluecount__c = accountGSUsageData.changedatavaluecount__c,
            changescorecount__c = accountGSUsageData.changescorecount__c,
            clicklinkcount__c = accountGSUsageData.clicklinkcount__c,
            CommunityIdea__c = accountGSUsageData.CommunityIdea__c,
            CommunityIdeaComment__c = accountGSUsageData.CommunityIdeaComment__c,
            CommunityLogins__c = accountGSUsageData.CommunityLogins__c,
            CommunityQuestion__c = accountGSUsageData.CommunityQuestion__c,
            CommunityQuestionComment__c = accountGSUsageData.CommunityQuestionComment__c,
            createtaskcount__c = accountGSUsageData.createtaskcount__c,
            Database_Size__c = accountGSUsageData.Database_Size__c,
            DataLoadId__c = accountGSUsageData.DataLoadId__c,
            Date__c = accountGSUsageData.Date__c,
            DKIM__c = accountGSUsageData.DKIM__c,
            Edition__c = accountGSUsageData.Edition__c,
            Email_Analysis_Count__c = accountGSUsageData.Email_Analysis_Count__c,
            emailbounced__c = accountGSUsageData.emailbounced__c,
            emailclicked__c = accountGSUsageData.emailclicked__c,
            emaildelivered__c = accountGSUsageData.emaildelivered__c,
            emailopened__c = accountGSUsageData.emailopened__c,
            emailsentcount__c = accountGSUsageData.emailsentcount__c,
            emailsoftbounced__c = accountGSUsageData.emailsoftbounced__c,
            emailunsubscribed__c = accountGSUsageData.emailunsubscribed__c,
            End_Week__c = accountGSUsageData.End_Week__c,
            filloutformcount__c = accountGSUsageData.filloutformcount__c,
            Inactive_Engagement_Count__c = accountGSUsageData.Inactive_Engagement_Count__c,
            InstanceId__c = accountGSUsageData.InstanceId__c,
            InstanceName__c = accountGSUsageData.InstanceName__c,
            known_lead_net_count__c = accountGSUsageData.known_lead_net_count__c,
            knownleadnetcount__c = accountGSUsageData.knownleadnetcount__c,
            Lead_Analysis_Count__c = accountGSUsageData.Lead_Analysis_Count__c,
            leadcount__c = accountGSUsageData.leadcount__c,
            Marketo_Logins__c = accountGSUsageData.Marketo_Logins__c,
            Marketo_Users__c = accountGSUsageData.Marketo_Users__c,
            Model_Performance_Company_Analysis_Count__c = accountGSUsageData.Model_Performance_Company_Analysis_Count__c,
            Model_Performance_Leads_Analysis_Count__c = accountGSUsageData.Model_Performance_Leads_Analysis_Count__c,
            New_Form_Net_Count__c = accountGSUsageData.New_Form_Net_Count__c,
            newleadcount__c = accountGSUsageData.newleadcount__c,
            Opportunity_Analysis_Count__c = accountGSUsageData.Opportunity_Analysis_Count__c,
            Opportunity_Influence_Analyzer_Count__c = accountGSUsageData.Opportunity_Influence_Analyzer_Count__c,
            Percent_Change__c = accountGSUsageData.Percent_Change__c,
            PrevAvg_Active_Engagement_Count__c = accountGSUsageData.PrevAvg_Active_Engagement_Count__c,
            PrevAvg_anonleadnetcount__c = accountGSUsageData.PrevAvg_anonleadnetcount__c,
            PrevAvg_anonwebvisitcount__c = accountGSUsageData.PrevAvg_anonwebvisitcount__c,
            PrevAvg_Balance_Black_Listed_Leads__c = accountGSUsageData.PrevAvg_Balance_Black_Listed_Leads__c,
            PrevAvg_Balance_Bounced_Leads__c = accountGSUsageData.PrevAvg_Balance_Bounced_Leads__c,
            PrevAvg_Balance_Possible_Duplicates__c = accountGSUsageData.PrevAvg_Balance_Possible_Duplicates__c,
            PrevAvg_Balance_Unsubscribed_Leads__c = accountGSUsageData.PrevAvg_Balance_Unsubscribed_Leads__c,
            PrevAvg_batch_camp_count__c = accountGSUsageData.PrevAvg_batch_camp_count__c,
            PrevAvg_batch_camp_execution_average__c = accountGSUsageData.PrevAvg_batch_camp_execution_average__c,
            PrevAvg_batch_camp_execution_deviation__c = accountGSUsageData.PrevAvg_batch_camp_execution_deviation__c,
            PrevAvg_batch_camp_max_lead_count__c = accountGSUsageData.PrevAvg_batch_camp_max_lead_count__c,
            PrevAvg_batch_camp_max_seconds__c = accountGSUsageData.PrevAvg_batch_camp_max_seconds__c,
            PrevAvg_batch_camp_total_lead_count__c = accountGSUsageData.PrevAvg_batch_camp_total_lead_count__c,
            PrevAvg_batch_camp_total_seconds__c = accountGSUsageData.PrevAvg_batch_camp_total_seconds__c,
            PrevAvg_batchcampcount__c = accountGSUsageData.PrevAvg_batchcampcount__c,
            PrevAvg_Campaign_Analysis_Count__c = accountGSUsageData.PrevAvg_Campaign_Analysis_Count__c,
            PrevAvg_changedatavaluecount__c = accountGSUsageData.PrevAvg_changedatavaluecount__c,
            PrevAvg_changescorecount__c = accountGSUsageData.PrevAvg_changescorecount__c,
            PrevAvg_clicklinkcount__c = accountGSUsageData.PrevAvg_clicklinkcount__c,
            PrevAvg_CommunityIdea__c = accountGSUsageData.PrevAvg_CommunityIdea__c,
            PrevAvg_CommunityIdeaComment__c = accountGSUsageData.PrevAvg_CommunityIdeaComment__c,
            PrevAvg_CommunityLogins__c = accountGSUsageData.PrevAvg_CommunityLogins__c,
            PrevAvg_CommunityQuestion__c = accountGSUsageData.PrevAvg_CommunityQuestion__c,
            PrevAvg_CommunityQuestionComment__c = accountGSUsageData.PrevAvg_CommunityQuestionComment__c,
            PrevAvg_createtaskcount__c = accountGSUsageData.PrevAvg_createtaskcount__c,
            PrevAvg_Email_Analysis_Count__c = accountGSUsageData.PrevAvg_Email_Analysis_Count__c,
            PrevAvg_emailbounced__c = accountGSUsageData.PrevAvg_emailbounced__c,
            PrevAvg_emailclicked__c = accountGSUsageData.PrevAvg_emailclicked__c,
            PrevAvg_emaildelivered__c = accountGSUsageData.PrevAvg_emaildelivered__c,
            PrevAvg_emailopened__c = accountGSUsageData.PrevAvg_emailopened__c,
            PrevAvg_emailsentcount__c = accountGSUsageData.PrevAvg_emailsentcount__c,
            PrevAvg_emailsoftbounced__c = accountGSUsageData.PrevAvg_emailsoftbounced__c,
            PrevAvg_emailunsubscribed__c = accountGSUsageData.PrevAvg_emailunsubscribed__c,
            PrevAvg_End_Date__c = accountGSUsageData.PrevAvg_End_Date__c,
            PrevAvg_End_Week__c = accountGSUsageData.PrevAvg_End_Week__c,
            PrevAvg_filloutformcount__c = accountGSUsageData.PrevAvg_filloutformcount__c,
            PrevAvg_Inactive_Engagement_Count__c = accountGSUsageData.PrevAvg_Inactive_Engagement_Count__c,
            PrevAvg_known_lead_net_count__c = accountGSUsageData.PrevAvg_known_lead_net_count__c,
            PrevAvg_knownleadnetcount__c = accountGSUsageData.PrevAvg_knownleadnetcount__c,
            PrevAvg_Lead_Analysis_Count__c = accountGSUsageData.PrevAvg_Lead_Analysis_Count__c,
            PrevAvg_leadcount__c = accountGSUsageData.PrevAvg_leadcount__c,
            PrevAvg_Marketo_Logins__c = accountGSUsageData.PrevAvg_Marketo_Logins__c,
            PrevAvg_Marketo_Users__c = accountGSUsageData.PrevAvg_Marketo_Users__c,
            PrevAvg_Model_Performance_Comp_Analysis__c = accountGSUsageData.PrevAvg_Model_Performance_Comp_Analysis__c,
            PrevAvg_Model_Performance_Leads_Analysis__c = accountGSUsageData.PrevAvg_Model_Performance_Leads_Analysis__c,
            PrevAvg_New_Form_Net_Count__c = accountGSUsageData.PrevAvg_New_Form_Net_Count__c,
            PrevAvg_newleadcount__c = accountGSUsageData.PrevAvg_newleadcount__c,
            PrevAvg_Opportunity_Analysis_Count__c = accountGSUsageData.PrevAvg_Opportunity_Analysis_Count__c,
            PrevAvg_Opportunity_Influence_Analyzer__c = accountGSUsageData.PrevAvg_Opportunity_Influence_Analyzer__c,
            PrevAvg_Program_Analyzer_Count__c = accountGSUsageData.PrevAvg_Program_Analyzer_Count__c,
            PrevAvg_Program_Cost_Analysis_Count__c = accountGSUsageData.PrevAvg_Program_Cost_Analysis_Count__c,
            PrevAvg_programcount__c = accountGSUsageData.PrevAvg_programcount__c,
            PrevAvg_Program_Membership_Analysis__c = accountGSUsageData.PrevAvg_Program_Membership_Analysis__c,
            PrevAvg_Program_Opportunity_Analysis__c = accountGSUsageData.PrevAvg_Program_Opportunity_Analysis__c,
            PrevAvg_Program_Revenue_Stage_Analysis__c = accountGSUsageData.PrevAvg_Program_Revenue_Stage_Analysis__c,
            PrevAvg_programsynccount__c = accountGSUsageData.PrevAvg_programsynccount__c,
            PrevAvg_sessioncount__c = accountGSUsageData.PrevAvg_sessioncount__c,
            PrevAvg_SFDC_Logins__c = accountGSUsageData.PrevAvg_SFDC_Logins__c,
            PrevAvg_Start_Date__c = accountGSUsageData.PrevAvg_Start_Date__c,
            PrevAvg_Start_Week__c = accountGSUsageData.PrevAvg_Start_Week__c,
            PrevAvg_Success_Path_Analyzer_Count__c = accountGSUsageData.PrevAvg_Success_Path_Analyzer_Count__c,
            PrevAvg_syncleadtosfdccount__c = accountGSUsageData.PrevAvg_syncleadtosfdccount__c,
            PrevAvg_Tickets_Created__c = accountGSUsageData.PrevAvg_Tickets_Created__c,
            PrevAvg_total_session_time__c = accountGSUsageData.PrevAvg_total_session_time__c,
            PrevAvg_total_soft_deleted_lead__c = accountGSUsageData.PrevAvg_total_soft_deleted_lead__c,
            PrevAvg_total_soft_deleted_pending_lead__c = accountGSUsageData.PrevAvg_total_soft_deleted_pending_lead__c,
            PrevAvg_totalanonleadcount__c = accountGSUsageData.PrevAvg_totalanonleadcount__c,
            PrevAvg_Total_Engagement_Count__c = accountGSUsageData.PrevAvg_Total_Engagement_Count__c,
            PrevAvg_totalknownleadcount__c = accountGSUsageData.PrevAvg_totalknownleadcount__c,
            PrevAvg_usingcostperiodcount__c = accountGSUsageData.PrevAvg_usingcostperiodcount__c,
            PrevAvg_usingtagsexcludetagcount__c = accountGSUsageData.PrevAvg_usingtagsexcludetagcount__c,
            PrevAvg_visitwebpagecount__c = accountGSUsageData.PrevAvg_visitwebpagecount__c,
            PrevAvg_workspacecount__c = accountGSUsageData.PrevAvg_workspacecount__c,
            Processed__c = accountGSUsageData.Processed__c,
            Program_Analyzer_Count__c = accountGSUsageData.Program_Analyzer_Count__c,
            Program_Cost_Analysis_Count__c = accountGSUsageData.Program_Cost_Analysis_Count__c,
            programcount__c = accountGSUsageData.programcount__c,
            Program_Membership_Analysis_Count__c = accountGSUsageData.Program_Membership_Analysis_Count__c,
            Program_Opportunity_Analysis_Count__c = accountGSUsageData.Program_Opportunity_Analysis_Count__c,
            Program_Revenue_Stage_Analysis_Count__c = accountGSUsageData.Program_Revenue_Stage_Analysis_Count__c,
            programsynccount__c = accountGSUsageData.programsynccount__c,
            Purpose__c = accountGSUsageData.Purpose__c,
            sessioncount__c = accountGSUsageData.sessioncount__c,
            SFDC_Logins__c = accountGSUsageData.SFDC_Logins__c,
            Start_Date__c = accountGSUsageData.Start_Date__c,
            Start_Week__c = accountGSUsageData.Start_Week__c,
            Success_Path_Analyzer_Count__c = accountGSUsageData.Success_Path_Analyzer_Count__c,
            Support_Engineer__c = accountGSUsageData.Support_Engineer__c,
            Support_Level__c = accountGSUsageData.Support_Level__c,
            syncleadtosfdccount__c = accountGSUsageData.syncleadtosfdccount__c,
            Tickets_Created__c = accountGSUsageData.Tickets_Created__c,
            Tickets_Currently_Open__c = accountGSUsageData.Tickets_Currently_Open__c,
            total_session_time__c = accountGSUsageData.total_session_time__c,
            total_soft_deleted_lead__c = accountGSUsageData.total_soft_deleted_lead__c,
            total_soft_deleted_pending_lead__c = accountGSUsageData.total_soft_deleted_pending_lead__c,
            totalanonleadcount__c = accountGSUsageData.totalanonleadcount__c,
            Total_Certifications__c = accountGSUsageData.Total_Certifications__c,
            Total_Courses__c = accountGSUsageData.Total_Courses__c,
            Total_Engagement_Count__c = accountGSUsageData.Total_Engagement_Count__c,
            totalknownleadcount__c = accountGSUsageData.totalknownleadcount__c,
            Usage_Data_Key__c = accountGSUsageData.Usage_Data_Key__c,
            User__c = accountGSUsageData.User__c,
            usingcostperiodcount__c = accountGSUsageData.usingcostperiodcount__c,
            usingtagsexcludetagcount__c = accountGSUsageData.usingtagsexcludetagcount__c,
            visitwebpagecount__c = accountGSUsageData.visitwebpagecount__c,
            Week_Group4_Number__c = accountGSUsageData.Week_Group4_Number__c,
            Week_Start_Year__c = accountGSUsageData.Week_Start_Year__c,
            workspacecount__c = accountGSUsageData.workspacecount__c
         );
         return tempContactUsageData;
     } 
}