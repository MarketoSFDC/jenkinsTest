/*Run this scheduler via Marketo Administrator
Latest Changes - 15 July 2017 By Grazitti.
Lines - 66,77 as per the requiremnt on SISR - #00820804
*/
global class CaseQualityReviewBatchApex implements Database.Batchable<User>{
    Date firstDayOfMonth;
    Date lastDayOfMonth;
    Integer numberOfDaysInMonth;
    List<User> completeTseList;
    List<User> completeManagerList;
    Map<Id,List<Case>> ownerIdToCaseList = new Map<Id,List<Case>>();
    Map<Id,Integer> ownerToNoOfReviewMap = new Map<Id,Integer>();// new map added by Rizvan
    Map<String,List<Case>> mapOfCaseBucketToCaseList;
    Map<String, List<Case>> finalCaseListMap;
    Map<Id,List<Store_Cases_For_Month__c>> manActIdToStoredCaseMap = new Map<Id,List<Store_Cases_For_Month__c>>();
    Map<Id,Case> mapCaseIdToCase{get;set;}
    List<Store_Cases_For_Month__c> finalCasesToBeAttached = new List<Store_Cases_For_Month__c>();
    Set<String> customerCareUsers = new set<String>(CaseRecordOrTypeIds__c.getInstance('Customer Care Users').ReferenceIds__c.split(';'));
    
    public CaseQualityReviewBatchApex(){
        if(system.label.ReviewForTesing == 'True'){        
          List<String> TestReviewCaseUserIds = system.Label.TestReviewCaseUserID.split(';');        
         completeTseList = [Select Id, Name, ManagerId, Case_Quality_Reviews_Count__c, Manager.FirstName from User Where ID IN :TestReviewCaseUserIds];   
       }else {
            completeTseList = [Select Id, Name, ManagerId, Case_Quality_Reviews_Count__c, Manager.FirstName  from User Where (((Profile.Id = '00e50000000zJpI') AND isActive = True AND (NOT UserRole.Name like '%lead%') AND (NOT UserRole.Name like '%manager%') AND (NOT UserRole.Name like '%tam%') and Case_Quality_Reviews_Count__c != '0') OR (id IN: customerCareUsers))]; 
        }
        if(Test.isRunningTest()){
            completeTseList = [Select Id, Name, ManagerId, Case_Quality_Reviews_Count__c, Manager.FirstName  from User Where ( Profile.Id = '00e50000000zJpI') AND isActive = True AND isActive = True AND (NOT UserRole.Name like '%lead%') AND (NOT UserRole.Name like '%manager%') AND (NOT UserRole.Name like '%tam%') limit 1];     
        }
    }    
   
    global Iterable<User> start (database.batchablecontext BC){
        return (completeTseList);    
    }        
 
    global void execute(Database.BatchableContext BC, List<user> scope){
        try{
            List<User> allTheTse = new List<User>();
            List<User> allcustomerCareTSE = new List<User>();
            for(User tempUser : scope){
                if(!customerCareUsers.Contains(tempUser.Id)) allTheTse.add(tempUser);
                else allcustomerCareTSE.add(tempUser);
            }
            Set<String> inValidCaseCloseReasons   = new Set<String>{'Spam','Duplicate','Invalid Case'};
            
            Boolean onDemandCaseQualityReview   = On_Demand_Case_Quality_Review__c.getInstance('On Demand Detail One').Enable_On_Demand_Cases__c;
            Datetime CurrentDateTime = System.now();
            If(onDemandCaseQualityReview || Test.isRunningTest()){
                Integer year = On_Demand_Case_Quality_Review__c.getInstance('On Demand Detail One').Year__c.intValue() ;
                Integer Month = On_Demand_Case_Quality_Review__c.getInstance('On Demand Detail One').Month_In_Number__c.intValue() ; 
                firstDayOfMonth          = Date.newInstance(year , Month, 1).toStartOfMonth();
                numberOfDaysInMonth      = Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month());
                lastDayOfMonth           = Date.newInstance(firstDayOfMonth.year(), firstDayOfMonth.month(), numberOfDaysInMonth);
            }else{
                firstDayOfMonth          = Date.newInstance(CurrentDateTime.year(), CurrentDateTime.month(), CurrentDateTime.day()).toStartOfMonth();
                numberOfDaysInMonth      = Date.daysInMonth(firstDayOfMonth.year(), firstDayOfMonth.month());
                lastDayOfMonth           = Date.newInstance(firstDayOfMonth.year(), firstDayOfMonth.month(), numberOfDaysInMonth);
            }
            
            
            //Used in Queries for fetching previous month cases
            Integer previousMonth             = firstDayOfMonth.addMonths(-1).month();
            Integer previousOrCurrentYear     = previousMonth == 12 ? firstDayOfMonth.year()-1:firstDayOfMonth.year();
            //Used in Queries for fetching previous month cases
            
            Set<String> recordTypeIdsForCaseQuality = new set<String>(CaseRecordOrTypeIds__c.getInstance('RecordType_For_Case_Quality').ReferenceIds__c.split(';'));
            Set<String> problemTypesToExclude = new set<String>(Case_Statuses__c.getInstance('Case_Problem _Types').Problem_Types__c.split(';'));
            List<Id> negativeCsatList = new List<Id>();
            List<CSatSurveyFeedback__c> tempCsatSurveyList = [Select Id, Case__c, Question_1__c from CSatSurveyFeedback__c Where (Question_1__c = '1' OR Question_1__c = '2') AND CALENDAR_MONTH(createdDate) =: previousMonth AND CALENDAR_YEAR(createdDate) =: previousOrCurrentYear];
            for(CSatSurveyFeedback__c tempCsat : tempCsatSurveyList){
                negativeCsatList.add(tempCsat.Case__c);
            }
            Set<Id> setOfAlreadyStoredCases = new Set<Id>();
            List<Store_Cases_For_Month__c> listOfAlreadyStoredCases = [Select Case__c from Store_Cases_For_Month__c where Createddate = LAST_N_MONTHS:6];
            for(Store_Cases_For_Month__c tempCase : listOfAlreadyStoredCases){
                setOfAlreadyStoredCases.add(tempCase.Case__c);
            }
            List<Case> rawCaseList = [Select CaseNumber,OwnerId,Id, Status, AgeInDays__c,ClosedDate,Evaluation_Status__c, Priority from Case where (isClosed = True AND CALENDAR_MONTH(ClosedDate) =: previousMonth AND CALENDAR_YEAR(ClosedDate) =: previousOrCurrentYear) AND Evaluation_Status__c = '' AND Close_Reason__c NOT IN : inValidCaseCloseReasons AND Id NOT IN : negativeCsatList AND Id NOT IN : setOfAlreadyStoredCases AND Problem_Type__c NOT IN :problemTypesToExclude AND ((OwnerId IN : allTheTse AND RecordTypeId IN :recordTypeIdsForCaseQuality) OR (OwnerId IN : allcustomerCareTSE AND RecordTypeId =:Label.CCareRecordTypeId18) )];
            system.debug('@@@@@@rawCaseList ' +rawCaseList.Size() );
            for(Case tempCase: rawCaseList){            
                If(!ownerIdToCaseList.ContainsKey(tempCase.OwnerId)){
                    ownerIdToCaseList.put(tempCase.OwnerId, new List<Case>{(tempCase)});
                }else{
                    ownerIdToCaseList.get(tempCase.OwnerId).add(tempCase);
                    ownerIdToCaseList.put(tempCase.OwnerId, new List<Case>(ownerIdToCaseList.get(tempCase.OwnerId)));
                }
            }
            
            List<Manger_Activity_Log__c> activityIdToManActDetail = [Select Id, SupportManager__c, TseName__c from Manger_Activity_Log__c Where ((TseName__c IN: allTheTse) OR (TseName__c IN: allcustomerCareTSE))];
            System.Debug('____activityIdToManActDetail_____'+activityIdToManActDetail);
            List<Store_Cases_For_Month__c> checkExistenceOfCaseIds = [Select Id,Manger_Activity_Log__c, Evaluation_Ended__c, Cases_From_Previous_Month__c, Case__r.Evaluation_Status__c, Case__r.AgeInDays__c, Case__r.Priority, Case__c, Case__r.CaseNumber, Filter_Criteria__c From Store_Cases_For_Month__c where Manger_Activity_Log__c IN: activityIdToManActDetail];
            //List<Store_Cases_For_Month__c> checkExistenceOfCaseIds = [Select Id,Manger_Activity_Log__c, Cases_From_Previous_Month__c, Case__r.Evaluation_Status__c, Case__r.AgeInDays__c, Case__r.Priority, Case__c, Case__r.CaseNumber, Filter_Criteria__c From Store_Cases_For_Month__c where Manger_Activity_Log__c IN: activityIdToManActDetail];
            Set<String> concatenatedManIdAndTseId = new Set<String>();
            Map<Id,Manger_Activity_Log__c> tseToManagerActLog = new Map<Id,Manger_Activity_Log__c>();
            Set<Id> allSupportEngineer = new Set<Id>(); 
            for(Manger_Activity_Log__c tempManActLog : activityIdToManActDetail){
                allSupportEngineer.add(tempManActLog.TseName__c);
                tseToManagerActLog.put(tempManActLog.TseName__c, tempManActLog);
                concatenatedManIdAndTseId.add(tempManActLog.SupportManager__c+''+tempManActLog.TseName__c);
            }        
            System.Debug('_____concatenatedManIdAndTseId_____'+concatenatedManIdAndTseId);
            List<Manger_Activity_Log__c> manActLogToBeInsertedOrUpdated = new List<Manger_Activity_Log__c>();
            List<User> insertManagerActivityLogList   = new List<User>();
            List<Manger_Activity_Log__c> updateManagerActivityLogList   = new List<Manger_Activity_Log__c>();
            
            System.Debug('___allTheTse_____'+allTheTse.Size());
            
            for(User tempTse : allTheTse){
                System.debug('____tempTse___'+tempTse);
                if(tempTse.Case_Quality_Reviews_Count__c != null){
                    ownerToNoOfReviewMap.put(tempTse.id, integer.valueof(tempTse.Case_Quality_Reviews_Count__c));
                }else{
                    ownerToNoOfReviewMap.put(tempTse.id,Integer.valueOf(Label.Default_Case_Quality_Review_Count));
                }
                If(!concatenatedManIdAndTseId.Contains(tempTse.ManagerId+''+tempTse.Id)){
                    insertManagerActivityLogList.add(tempTse);
                    allSupportEngineer.add(tempTse.Id);
                    System.debug('____insertManagerActivityLogList111___'+tempTse);
                }else{
                    System.debug('____updateManagerActivityLogList1111___'+tempTse);
                    updateManagerActivityLogList.add(tseToManagerActLog.get(tempTse.Id));
                }
            }
            for(User tempTse : allcustomerCareTSE){
                System.debug('____tempTse___'+tempTse);
                if(tempTse.Case_Quality_Reviews_Count__c != null){
                    ownerToNoOfReviewMap.put(tempTse.id, integer.valueof(tempTse.Case_Quality_Reviews_Count__c));
                }else{
                    ownerToNoOfReviewMap.put(tempTse.id,Integer.valueOf(Label.Default_Case_Quality_Review_Count));
                }
                If(!concatenatedManIdAndTseId.Contains(tempTse.ManagerId+''+tempTse.Id)){
                    insertManagerActivityLogList.add(tempTse);
                    allSupportEngineer.add(tempTse.Id);
                    System.debug('____insertManagerActivityLogList111___'+tempTse);
                }else{
                    System.debug('____updateManagerActivityLogList1111___'+tempTse);
                    updateManagerActivityLogList.add(tseToManagerActLog.get(tempTse.Id));
                }
            }  
                        
            for(Store_Cases_For_Month__c tempCase: checkExistenceOfCaseIds){
                If(!manActIdToStoredCaseMap.ContainsKey(tempCase.Manger_Activity_Log__c)){
                    manActIdToStoredCaseMap.put(tempCase.Manger_Activity_Log__c, new List<Store_Cases_For_Month__c>{(tempCase)});
                }else{
                    manActIdToStoredCaseMap.get(tempCase.Manger_Activity_Log__c).add(tempCase);
                    manActIdToStoredCaseMap.put(tempCase.Manger_Activity_Log__c, new List<Store_Cases_For_Month__c>(manActIdToStoredCaseMap.get(tempCase.Manger_Activity_Log__c)));
                }
            }
            
            List<Manger_Activity_Log__c> finalManagerActivityLogListToBeUpdated  = new List<Manger_Activity_Log__c>();
            List<Manger_Activity_Log__c> finalManagerActivityLogListToBeInserted = new List<Manger_Activity_Log__c>();
            List<Manger_Activity_Log__c> finalManagerActivityList                = new List<Manger_Activity_Log__c>();
            
            System.Debug('_____insertManagerActivityLogList______'+insertManagerActivityLogList.Size());
            System.Debug('_____updateManagerActivityLogList______'+updateManagerActivityLogList);

            
            if(!insertManagerActivityLogList.isEmpty()){
                finalManagerActivityLogListToBeInserted.addAll(insertManagerActivityLog(insertManagerActivityLogList));
                insert finalManagerActivityLogListToBeInserted;
                finalManagerActivityList.addAll(finalManagerActivityLogListToBeInserted);
            }
            
            if(!updateManagerActivityLogList.isEmpty()){
                finalManagerActivityLogListToBeUpdated.addAll(updateManagerActivityLog(updateManagerActivityLogList)); 
                update finalManagerActivityLogListToBeUpdated;
                finalManagerActivityList.addAll(finalManagerActivityLogListToBeUpdated);
            }
            
            if(!finalManagerActivityList.isEmpty()){   
                attachCaseListWithManActLog(finalManagerActivityList);
            }
        }
        Catch(Exception e){
            CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);
        }      
    }
    
    public List<Manger_Activity_Log__c> insertManagerActivityLog(List<User> createManActLog){
        System.Debug('________insertManagerActivityLog_________'+createManActLog);
        List<Manger_Activity_Log__c> finalManActLogList = new List<Manger_Activity_Log__c>(); 
        DateTime dT          = System.now();
        Date myDate          = date.newinstance(dT.year(), dT.month(), dT.day());
        Integer numberOfDays = Date.daysInMonth(myDate.year(), myDate.month());
        for(User tempUser : createManActLog){
            Manger_Activity_Log__c tempManagerActivity = new Manger_Activity_Log__c();
            tempManagerActivity.SupportManager__c      = tempUser.ManagerId;
            tempManagerActivity.TseName__c             = tempUser.Id;
            tempManagerActivity.Evaluation_Started__c  = firstDayOfMonth;
            tempManagerActivity.Evaluation_Ended__c    = lastDayOfMonth;         
            tempManagerActivity.Name                   = tempUser.Manager.FirstName+'-'+tempUser.Name;
            tempManagerActivity.Test_Var__c            = True;
            finalManActLogList.add(tempManagerActivity);
        }
        System.Debug('__finalManActLogListInserted____'+finalManActLogList.Size());
        return finalManActLogList;
    }
    
    public List<Manger_Activity_Log__c> updateManagerActivityLog(List<Manger_Activity_Log__c> updateManActLog){
        System.Debug('________updateManagerActivityLog_________'+updateManActLog);
        List<Manger_Activity_Log__c> finalManActLogList = new List<Manger_Activity_Log__c>(); 
        for(Manger_Activity_Log__c tempManagerActivity : updateManActLog){
            tempManagerActivity.Status__c             = 'Not Started';
            tempManagerActivity.Evaluation_Started__c  = firstDayOfMonth;
            tempManagerActivity.Evaluation_Ended__c    = lastDayOfMonth;
            tempManagerActivity.Test_Var_Update__c           = True;
            finalManActLogList.add(tempManagerActivity);
        }
        System.Debug('__finalManActLogListUpdated____'+finalManActLogList);
        return finalManActLogList;
    }
    
    public void attachCaseListWithManActLog(List<Manger_Activity_Log__c> manActLogList){
        /*CODE TO ATTACH CASE LIST WITH MANAGER ACTIVITY LOG*/
        
        List<Store_Cases_For_Month__c> previousMonCases = new List<Store_Cases_For_Month__c>();
        
        for(Manger_Activity_Log__c tempManActLogUser : manActLogList){
            Map<String,List<Case>> globalCaseBucketToCaseList = new Map<String,List<Case>>();
            //System.Debug('_____tempManActLogUser_____'+ownerIdToCaseList.get(tempManActLogUser.TseName__c));
            if(ownerIdToCaseList.get(tempManActLogUser.TseName__c) != NULL){
                globalCaseBucketToCaseList = CaseBucketToCaseListV1(ownerIdToCaseList.get(tempManActLogUser.TseName__c), ownerToNoOfReviewMap.get(tempManActLogUser.TseName__c ));
            }
            //System.Debug('___globalCaseBucketToCaseList___'+globalCaseBucketToCaseList);
            If(globalCaseBucketToCaseList != NULL){
                System.Debug('____globalCaseBucketToCaseList ___'+globalCaseBucketToCaseList );
                storeCasesAlongWithKeyMap(globalCaseBucketToCaseList, tempManActLogUser.Id);
            }
            If(manActIdToStoredCaseMap.get(tempManActLogUser.id) != Null)
                previousMonCases.addAll(manActIdToStoredCaseMap.get(tempManActLogUser.id));
            System.Debug('______ownerIdToCaseList.get(tempManActLogUser.TseName__c)_________'+ownerIdToCaseList.get(tempManActLogUser.TseName__c));
            System.Debug('______manActIdToStoredCaseMap.get(tempManActLogUser.id)_________'+manActIdToStoredCaseMap.get(tempManActLogUser.id));
        }
        If(previousMonCases != NULL){
            for(Store_Cases_For_Month__c tempCase : previousMonCases){
                System.Debug('__________Updating List Of Stored Cases___________'+tempCase);
                tempCase.Cases_From_Previous_Month__c = true;
                finalCasesToBeAttached.add(tempCase);
            }        
        }
        If(!finalCasesToBeAttached.isEmpty()){                      
            System.Debug('_____finalCasesToBeAttached_____'+finalCasesToBeAttached);
            upsert finalCasesToBeAttached;
        }
    }
    
    global void finish(Database.BatchableContext BC){
        EmailNotificationToManager.fetchFreshReviewsForManager();   
    }
   
   public void storeCasesAlongWithKeyMap(Map<String,List<Case>> finalCaseListMap, Id manActLogId){
        //delete listOfStoredCases;
        System.Debug('___finalCaseListMap___'+finalCaseListMap);
        System.Debug('___finalCaseListMap___'+finalCaseListMap.keySet());
        
        List<Store_Cases_For_Month__c> tempCaseIdsToBeSaved = new List<Store_Cases_For_Month__c>(); 
        
        If(!finalCaseListMap.isEmpty()){
            System.Debug('_____Case Are Inserted For First Time____');
            finalCasesToBeAttached.addAll(insertCasesForNextMonOrForFirstTime(finalCaseListMap, manActLogId)); 
        }
        //finalCasesToBeAttached.addAll(insertCasesForNextMonOrForFirstTime(finalCaseListMap, listOfStoredCases, manActLogId)); 
        System.Debug('_______finalCasesToBeAttached___________'+finalCasesToBeAttached);
   }
   
   public Map<String,List<Case>> CaseBucketToCaseListV1(List<Case> rawCaseList, Integer NoOfReview){
        System.Debug('_________mapOfCaseBucketToCaseList________'+mapOfCaseBucketToCaseList);
        //Map<Id,String> caseIdToStatusInEngineeringEscalated = caseIdToStatusInEngineerEscalMap(rawCaseList);
        mapOfCaseBucketToCaseList = new Map<String,List<Case>>();
        System.Debug('_____raw case list___'+rawCaseList.Size());
        for(Case tempCase : rawCaseList){
            /*If(caseIdToStatusInEngineeringEscalated.get(tempCase.Id) == 'Engineering Escalated'){
                biggerMapRoutine('Engineering Escalated', tempCase);                
            } else If(tempCase.Priority == 'P1' || tempCase.Priority == 'P2'){
                    biggerMapRoutine('Priority '+tempCase.Priority, tempCase);
            } else If(tempCase.AgeInDays__c > 10){
                    biggerMapRoutine('Aged', tempCase);
            } else {*/
            biggerMapRoutine('Closed', tempCase);
            //}
        }
        System.Debug('_________mapOfCaseBucketToCaseList________'+mapOfCaseBucketToCaseList.Size());
        return filterOutFiveValidCases(mapOfCaseBucketToCaseList, NoOfReview);
    }
    
    public Map<Id,String> caseIdToStatusInEngineerEscalMap(List<Case> rawCaseList){
        Map<Id,String> tempCaseIdToCaseStatusInEngEscal = new Map<Id,String>();
        for(Case SingleCase : rawCaseList){
            List<Casehistory> tempHist = SingleCase.Histories;
            If(!tempHist.isEmpty()){
                for(Casehistory tempHistory : tempHist){
                    If((tempHistory.oldValue == 'Engineering Escalated' || tempHistory.newValue == 'Engineering Escalated') || 
                        (tempHistory.oldValue == 'Routed To Tier 2' || tempHistory.newValue == 'Routed To Tier 2')
                        ){
                        tempCaseIdToCaseStatusInEngEscal.put(SingleCase.Id, 'Engineering Escalated');  
                        Break;  
                    }else{
                        tempCaseIdToCaseStatusInEngEscal.put(SingleCase.Id, 'Not Engineering Escalated');    
                    }
                }
            } else {
                tempCaseIdToCaseStatusInEngEscal.put(SingleCase.Id, 'Not Engineering Escalated');    
            }
        }
        return tempCaseIdToCaseStatusInEngEscal;
    }
    
    public Map<String,List<Case>> filterOutFiveValidCases(Map<String,List<Case>> mapOfCaseBucketToCaseLists, Integer NoOfReview){
        finalCaseListMap = new Map<String, List<Case>>();
        integer ReviewCasesNUmber = 0;
        
        /*If(mapOfCaseBucketToCaseLists.ContainsKey('Engineering Escalated') && !mapOfCaseBucketToCaseLists.get('Engineering Escalated').IsEmpty()){
            if(ReviewCasesNUmber < NoOfReview){                
                finalMapRoutine('Engineering Escalated', mapOfCaseBucketToCaseLists);
                ReviewCasesNUmber++;
            }
        }
        If(mapOfCaseBucketToCaseLists.ContainsKey('Aged') && !mapOfCaseBucketToCaseLists.get('Aged').IsEmpty()){
            if(ReviewCasesNUmber < NoOfReview){
                finalMapRoutine('Aged', mapOfCaseBucketToCaseLists);
                ReviewCasesNUmber++;
            }
        }
        If(mapOfCaseBucketToCaseLists.ContainsKey('Priority P1') && !mapOfCaseBucketToCaseLists.get('Priority P1').IsEmpty()){
           if(ReviewCasesNUmber < NoOfReview){
                finalMapRoutine('Priority P1', mapOfCaseBucketToCaseLists);
                ReviewCasesNUmber++;
            }             
        }
        If(mapOfCaseBucketToCaseLists.ContainsKey('Priority P2') && !mapOfCaseBucketToCaseLists.get('Priority P2').IsEmpty()){
            if(ReviewCasesNUmber < NoOfReview){
                finalMapRoutine('Priority P2', mapOfCaseBucketToCaseLists);
                ReviewCasesNUmber++;
            } 
        }*/
        System.Debug('____finalMapRoutine___'+finalCaseListMap);
        
        integer i;
        for(i= finalCaseListMap.size(); i < NoOfReview; i++){
            /*If(mapOfCaseBucketToCaseLists.ContainsKey('Aged') && !mapOfCaseBucketToCaseLists.get('Aged').IsEmpty()){
                remainingCaseList('Aged', mapOfCaseBucketToCaseLists);
            }else
            If(mapOfCaseBucketToCaseLists.ContainsKey('Engineering Escalated') && !mapOfCaseBucketToCaseLists.get('Engineering Escalated').IsEmpty()){
                remainingCaseList('Engineering Escalated', mapOfCaseBucketToCaseLists);
            }else
            If(mapOfCaseBucketToCaseLists.ContainsKey('Priority P1') && !mapOfCaseBucketToCaseLists.get('Priority P1').IsEmpty()){
                remainingCaseList('Priority P1', mapOfCaseBucketToCaseLists);
            }else
            If(mapOfCaseBucketToCaseLists.ContainsKey('Priority P2') && !mapOfCaseBucketToCaseLists.get('Priority P2').IsEmpty()){
                remainingCaseList('Priority P2', mapOfCaseBucketToCaseLists);
            }else  */
            If(mapOfCaseBucketToCaseLists.ContainsKey('Closed') && !mapOfCaseBucketToCaseLists.get('Closed').IsEmpty()){
               remainingCaseList('Closed', mapOfCaseBucketToCaseLists);
            }
        }
        
        System.Debug('_____mapOfCaseBucketToCaseLists SIZE after Remove_____'+finalCaseListMap);
        return finalCaseListMap;
    }  
      
    public void biggerMapRoutine(String mapKeyInRoutine, Case caseInRoutine){
        If(mapOfCaseBucketToCaseList.containsKey(mapKeyInRoutine)){
            List<Case> tempCaseList = mapOfCaseBucketToCaseList.get(mapKeyInRoutine);
            tempCaseList.add(caseInRoutine);
            mapOfCaseBucketToCaseList.put(mapKeyInRoutine,tempCaseList);
        } else{
            List<Case> tempCaseList = new List<Case>();
            tempCaseList.add(caseInRoutine);
            mapOfCaseBucketToCaseList.put(mapKeyInRoutine,tempCaseList); 
        }
    }
    
    public void finalMapRoutine(String mapKeyInRoutine, Map<String,List<Case>> localMapOfCaseBucketToCaseLists){
        List<Case> tempCase = new List<Case>();
        if(mapKeyInRoutine != null){
            Case c = localMapOfCaseBucketToCaseLists.get(mapKeyInRoutine)[0];
            tempCase.add(c);
        }
        finalCaseListMap.put(mapKeyInRoutine,tempCase);
        localMapOfCaseBucketToCaseLists.get(mapKeyInRoutine).Remove(0);
    }
    
    public void remainingCaseList(String mapKeyForRoutine, Map<String,List<Case>> localMapOfCaseBucketToCaseLists){
        System.Debug('_________Entry in map exists_________'+localMapOfCaseBucketToCaseLists.containsKey(mapKeyForRoutine));
        if(localMapOfCaseBucketToCaseLists.containsKey(mapKeyForRoutine)){
            If(finalCaseListMap.ContainsKey(mapKeyForRoutine)){
                finalCaseListMap.get(mapKeyForRoutine).add(localMapOfCaseBucketToCaseLists.get(mapKeyForRoutine)[0]);
            }else{
                Case tempCase = localMapOfCaseBucketToCaseLists.get(mapKeyForRoutine)[0];
                List<Case> tempCaseList = new List<Case>();tempCaseList.add(tempCase);
                finalCaseListMap.put(mapKeyForRoutine,tempCaseList);
            }
            localMapOfCaseBucketToCaseLists.get(mapKeyForRoutine).Remove(0);
            System.Debug('_____remainingCaseList_______'+finalCaseListMap);
        }   
    } 
         
    public List<Store_Cases_For_Month__c> insertCasesForNextMonOrForFirstTime(Map<String,List<Case>> finalCaseListMap, Id managerActivityLog){
        Set<String> finalMapKeySet = finalCaseListMap.keySet();
        List<Store_Cases_For_Month__c> finalCaseIdsToBeSaved = new List<Store_Cases_For_Month__c>();
        List<Case> updateCaseStatus = new List<Case>();
        Integer numberOfDays = Date.daysInMonth(System.now().year(), System.now().month());
        for(String tempKey : finalCaseListMap.keySet()){
            System.Debug('_______managerActivityLogId_____'+finalCaseListMap.get(tempKey));
            for(Case tempCase : finalCaseListMap.get(tempKey)){
                Store_Cases_For_Month__c tempCasesToBeStored = new Store_Cases_For_Month__c(); 
                tempCasesToBeStored.Filter_Criteria__c          = tempKey; 
                tempCasesToBeStored.Case__c                     = tempCase.Id;
                tempCasesToBeStored.Manger_Activity_Log__c      = managerActivityLog;
                tempCasesToBeStored.Evaluation_Ended__c         = lastDayOfMonth;
                tempCasesToBeStored.Evaluation_Status__c        = 'Evaluate';
                tempCasesToBeStored.Test_Var__c                 = true;
                finalCaseIdsToBeSaved.add(tempCasesToBeStored);
            }
        } 
        return finalCaseIdsToBeSaved;
    }
}