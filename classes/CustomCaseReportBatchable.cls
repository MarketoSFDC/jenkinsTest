global class CustomCaseReportBatchable implements Database.Batchable<Account> {

    private static string SupportCases  = '01250000000UJwxAAG';  //Support case record type
    public list<account> accsToTarget;
    Date endDate;
    Date startDate;
    
    public CustomCaseReportBatchable(Set<Id> Accounts) {        
        accsToTarget = new List<account>();
        Map<Id, Account> tmpAccs = new Map<Id, Account>([SELECT ID from Account Where Id in :Accounts AND (NOT Type IN ('Ex-Customer','Ex-Partner')) Limit 10000]);        
        accsToTarget.AddAll(tmpAccs.values());
        Date currentDate = Date.today();
        Integer daysToAdd = Date.daysInMonth(currentDate.Year(),currentDate.month());
        endDate = currentDate.toStartOfMonth().addDays(daysToAdd);
        startDate = currentDate.addMonths(-2).toStartOfMonth();
        //System.debug('currentDate=>'+currentDate);System.debug('endDate=>'+endDate);System.debug('startDate=>'+startDate);
        //currentDate=>2014-10-18 00:00:00//endDate=>2014-11-01 00:00:00//startDate=>2014-08-01 00:00:00        
    }
    
    global Iterable<Account> start (database.batchablecontext BC){    
        return (accsToTarget);    
    }  
    
    global void finish(Database.BatchableContext BC){
    
    }
    
    global void execute(Database.BatchableContext BC, List<Account> scope) {        
        Set<Id> ValidAccIds = new Set<Id>();
        for(Account acc : scope) {
            ValidAccIds.add(acc.Id);
        }
        if(ValidAccIds.isEmpty() == FALSE) {
            system.debug('ValidAccIds==>' + ValidAccIds);    
            addCaseSummary(ValidAccIds);
        }
    }
    
    global void addCaseSummary(Set<Id> ValidAccIds) {            
        //DateTime startDate = DateTime.now().addMonths(-3); 
        //DateTime endDate = DateTime.now();
        
        System.Debug('startDate==>'+startDate + ' endDate==>'+endDate);
        integer currentMonth = Date.Today().month();
        integer lastMonth = Date.Today().addMonths(-1).month();
        integer prevToLastMonth = Date.Today().addMonths(-2).month();
        
        //Cases closed during that time interval with CSAT Records
        List<Case> closedSupportCases = [SELECT Id,Account.Id, ClosedDate,AgeInDays__c,Problem_Type__c, Category__c, Priority, Maximum_Priority__c, Status,Support_Level__c,  
        (SELECT Id,Overall_CSAT_Positive__c,Case__r.ClosedDate From Support_CSat_Survey_Feedbacks__r) 
        From Case Where 
        Account.Id in :ValidAccIds AND RecordTypeId =:SupportCases AND Status = 'Closed' AND ClosedDate < :EndDate AND ClosedDate >= : StartDate 
        AND (NOT Case.Close_Reason__c  in ('Spam','Duplicate','Invalid Case','Invalid Record','Partner Supported Referral','Unauthorized Contact Reroute')) Order By Account.Id]; //Order By ClosedDate
                
        //Cases opened during that time interval and Custom Milestone
        List<Case> openedSupportCases = [SELECT Id,Account.Id, CreatedDate,AgeInDays__c, Priority,Maximum_Priority__c, Status,Support_Level__c,
        (SELECT Id, Start_Date__c,Violation__c From Case_Milestones__r Where Violation__c = true AND  Milestone_Type__c = 'First Response')
        From Case Where 
        Account.Id in :ValidAccIds AND RecordTypeId =:SupportCases AND CreatedDate < :EndDate AND CreatedDate >= : StartDate 
        AND (NOT Case.Close_Reason__c  in ('Spam','Duplicate','Invalid Case','Invalid Record','Partner Supported Referral','Unauthorized Contact Reroute')) Order By Account.Id]; //Order By ClosedDate

        Set<Id> accToSet = new Set<Id>();                
        Map<Id,List<Case>> accToClCaseMap = new Map<Id,List<Case>>();                
        Map<Id,List<Case>> accToOpCaseMap = new Map<Id,List<Case>>();        
        Map<Id,List<Case_Update_Milestones__c>> caseToMilestoneMap = new Map<Id,List<Case_Update_Milestones__c>>();        
        Map<Id,List<CSatSurveyFeedback__c>> caseToCSATMap = new Map<Id,List<CSatSurveyFeedback__c>>();        
        
        for(Case cm :openedSupportCases) {
            Integer keyStr = cm.CreatedDate.month();
            system.debug('keyStr==>' + keyStr + ' OpenedCases');                        
            accToSet.Add(cm.Account.Id);
            if(!accToOpCaseMap.containskey(cm.Account.Id)) {
                accToOpCaseMap.put(cm.Account.Id, new List<Case>());
            }
            accToOpCaseMap.get(cm.Account.Id).add(cm);    
            caseToMilestoneMap.put(cm.Id,new List<Case_Update_Milestones__c>());
            if(cm.Case_Milestones__r.isEmpty() == FALSE) {
                caseToMilestoneMap.get(cm.Id).AddAll(cm.Case_Milestones__r);
            }       
        }
        
        for(Case cm :closedSupportCases) {
            Integer keyStr = cm.ClosedDate.month();
            system.debug('keyStr==>' + keyStr + ' ' + cm.Problem_Type__c);                        
            accToSet.Add(cm.Account.Id);
            if(!accToClCaseMap.containskey(cm.Account.Id)) {
                accToClCaseMap.put(cm.Account.Id, new List<Case>());
            }
            accToClCaseMap.get(cm.Account.Id).add(cm);                          
            caseToCSATMap.put(cm.Id,new List<CSatSurveyFeedback__c>());
            if(cm.Support_CSat_Survey_Feedbacks__r.isEmpty() == FALSE) {
                caseToCSATMap.get(cm.Id).AddAll(cm.Support_CSat_Survey_Feedbacks__r);
            }                        
        }
        
            
        List<CustomCaseReportSummary__c> MainUpsertList = new List<CustomCaseReportSummary__c>();
                 
        for(Id accId : ValidAccIds) {
        
            Map<Integer,Map<string,integer>> monthToCategMap = new Map<Integer,Map<string,integer>>();
            Map<Integer,Map<string,integer>> monthToPrblmMap = new Map<Integer,Map<string,integer>>();
            Map<Integer,StackedData> monthToAgeCountMap = new Map<Integer,StackedData>();    
            Map<Integer,Integer> monthToCSATCountMap = new Map<Integer, Integer>();
            Map<Integer,Integer> monthToCSATPositiveMap = new Map<Integer, Integer>();             
            Map<Integer,Integer> monthToCSATNegativeMap = new Map<Integer, Integer>();             
            Map<Integer,Integer> monthToMSCountMap = new Map<Integer, Integer>();
            Map<Integer,Integer> monthToMSViolatedMap = new Map<Integer, Integer>();             
            Map<Integer,Integer> monthToMSP1CountMap = new Map<Integer, Integer>();
            Map<Integer,Integer> monthToMSP1ViolatedMap = new Map<Integer, Integer>();             
            
            monthToCategMap.put(currentMonth, new Map<string,integer>()); 
            monthToCategMap.put(lastMonth, new Map<string,integer>()); 
            monthToCategMap.put(prevToLastMonth, new Map<string,integer>());    
            
            monthToPrblmMap.put(currentMonth, new Map<string,integer>()); 
            monthToPrblmMap.put(lastMonth, new Map<string,integer>()); 
            monthToPrblmMap.put(prevToLastMonth, new Map<string,integer>());    
            
            monthToCSATCountMap.put(currentMonth,0); 
            monthToCSATCountMap.put(lastMonth,0); 
            monthToCSATCountMap.put(prevToLastMonth,0); 
            
            monthToCSATNegativeMap.put(currentMonth,0); 
            monthToCSATNegativeMap.put(lastMonth,0); 
            monthToCSATNegativeMap.put(prevToLastMonth,0); 
            
            monthToCSATPositiveMap.put(currentMonth,0); 
            monthToCSATPositiveMap.put(lastMonth,0); 
            monthToCSATPositiveMap.put(prevToLastMonth,0); 
            
            monthToMSCountMap.put(currentMonth,0); 
            monthToMSCountMap.put(lastMonth,0); 
            monthToMSCountMap.put(prevToLastMonth,0); 
            
            monthToMSViolatedMap.put(currentMonth,0); 
            monthToMSViolatedMap.put(lastMonth,0); 
            monthToMSViolatedMap.put(prevToLastMonth,0); 
            
            monthToMSP1CountMap.put(currentMonth,0); 
            monthToMSP1CountMap.put(lastMonth,0); 
            monthToMSP1CountMap.put(prevToLastMonth,0);             
            
            monthToMSP1ViolatedMap.put(currentMonth,0); 
            monthToMSP1ViolatedMap.put(lastMonth,0); 
            monthToMSP1ViolatedMap.put(prevToLastMonth,0); 
            
            monthToAgeCountMap.put(currentMonth, new StackedData(currentMonth,0,0,0,0,0,0));            
            monthToAgeCountMap.put(lastMonth, new StackedData(lastMonth,0,0,0,0,0,0));
            monthToAgeCountMap.put(prevToLastMonth, new StackedData(prevToLastMonth,0,0,0,0,0,0));
            
            List<Case> closedSupCasesonAcc = new List<Case>();
            if(accToClCaseMap.containsKey(accId))
                closedSupCasesonAcc.AddAll(accToClCaseMap.get(accId));    
            
            List<Case> openedSupCasesonAcc = new List<Case>();
            if(accToOpCaseMap.containsKey(accId))
                openedSupCasesonAcc.AddAll(accToOpCaseMap.get(accId));                                 
            
            for(Case cm :openedSupCasesonAcc)  {
                Integer keyStr = cm.CreatedDate.month(); 
                if(caseToMilestoneMap.containsKey(cm.Id)) {                
                    if(!monthToMSCountMap.containskey(keyStr))          monthToMSCountMap.put(keyStr,0);                     
                    if(!monthToMSViolatedMap.containskey(keyStr))       monthToMSViolatedMap.put(keyStr,0);                     
                    if(!monthToMSP1CountMap.containskey(keyStr))        monthToMSP1CountMap.put(keyStr,0);                     
                    if(!monthToMSP1ViolatedMap.containskey(keyStr))     monthToMSP1ViolatedMap.put(keyStr,0);
                    
                    if(cm.Support_Level__c != NULL && cm.Support_Level__c != 'Cancelled' && cm.Support_Level__c != 'Internal') {                         
                        monthToMSCountMap.put(keyStr,monthToMSCountMap.get(keyStr)+1); 
                        if(cm.Case_Milestones__r.isEmpty() == FALSE && cm.Case_Milestones__r[0].Violation__c == true)  
                            monthToMSViolatedMap.put(keyStr,monthToMSViolatedMap.get(keyStr)+1);                        
                        if(cm.Maximum_Priority__c == 'P1') {                        
                            monthToMSP1CountMap.put(keyStr,monthToMSP1CountMap.get(keyStr)+1); 
                            if(cm.Case_Milestones__r.isEmpty() == FALSE && cm.Case_Milestones__r[0].Violation__c == true)  
                                monthToMSP1ViolatedMap.put(keyStr,monthToMSP1ViolatedMap.get(keyStr)+1);                                
                        }
                    }
                }
            }
            for(Case cm :closedSupCasesonAcc) {
                Integer keyStr = cm.ClosedDate.month();                                
                if(caseToCSATMap.containsKey(cm.Id) && caseToCSATMap.isEmpty() == FALSE) {       
                    system.debug('keyStr==>' + keyStr);                    
                    if(!monthToCSATCountMap.containskey(keyStr)) monthToCSATCountMap.put(keyStr,0);                               
                    if(!monthToCSATPositiveMap.containskey(keyStr)) monthToCSATPositiveMap.put(keyStr,0);                               
                    if(!monthToCSATNegativeMap.containskey(keyStr)) monthToCSATNegativeMap.put(keyStr,0);                                                   
                    //If csat data for that case exists                  
                    if(cm.Support_CSat_Survey_Feedbacks__r.isEmpty() == FALSE) {
                        monthToCSATCountMap.put(keyStr,monthToCSATCountMap.get(keyStr)+1);                     
                        if(cm.Support_CSat_Survey_Feedbacks__r[0].Overall_CSAT_Positive__c == TRUE) {                              
                            monthToCSATPositiveMap.put(keyStr,monthToCSATPositiveMap.get(keyStr)+1);    
                        } else {    
                            monthToCSATNegativeMap.put(keyStr,monthToCSATNegativeMap.get(keyStr)+1);    
                        }
                    }
                }
                                                
                if(!monthToCategMap.containskey(keyStr)) {
                    monthToCategMap.put(keyStr, new Map<String, Integer>());
                }                
                Map<String,Integer> categToCountMap = new Map<String, Integer>();           
                categToCountMap =  monthToCategMap.get(keyStr);                       
                if(cm.Category__c != NULL) {
                    if(categToCountMap.containsKey(cm.Category__c)) {
                        categToCountMap.put(cm.Category__c,categToCountMap.get(cm.Category__c)+1);
                    } else {
                        categToCountMap.put(cm.Category__c,1);
                    }                                                                                               
                } else {                        
                    if(categToCountMap.containsKey('NULL')) {
                        categToCountMap.put('NULL',categToCountMap.get('NULL')+1);
                    } else {
                        categToCountMap.put('NULL',1);
                    }                                                                                               
                }        
                monthToCategMap.put(keyStr,categToCountMap);
                
                if(!monthToPrblmMap.containskey(keyStr)) {
                    monthToPrblmMap.put(keyStr, new Map<String, Integer>());
                }            
                Map<String,Integer> prblmToCountMap = new Map<String, Integer>();                
                prblmToCountMap =  monthToPrblmMap.get(keyStr);            

                if(cm.Problem_Type__c != NULL) {
                    if(prblmToCountMap.containsKey(cm.Problem_Type__c)) {
                         prblmToCountMap.put(cm.Problem_Type__c,prblmToCountMap.get(cm.Problem_Type__c)+1);
                    } else {
                         prblmToCountMap.put(cm.Problem_Type__c,1);
                    }
                } else {
                    if(prblmToCountMap.containsKey('NULL')) {
                         prblmToCountMap.put('NULL',prblmToCountMap.get('NULL')+1);
                    } else {
                         prblmToCountMap.put('NULL',1);
                    }
                }                 
                monthToPrblmMap.put(keyStr,prblmToCountMap);
                
                System.debug('<=='+ monthToCategMap + ' <=> ' + monthToPrblmMap);
                
                if(!monthToAgeCountMap.containskey(keyStr)) monthToAgeCountMap.put(keyStr, new StackedData(keyStr,0,0,0,0,0,0)); 
                
                if(monthToAgeCountMap.containsKey(keyStr)) {
                    integer ageCnt = (Integer)cm.AgeInDays__c;                                    
                    if(ageCnt <=1)
                        monthToAgeCountMap.get(keyStr).data1++;            
                    else if(ageCnt <=5)
                        monthToAgeCountMap.get(keyStr).data5++;            
                    else if(ageCnt <=30)
                        monthToAgeCountMap.get(keyStr).data30++;            
                    else if(ageCnt <=60)
                        monthToAgeCountMap.get(keyStr).data60++;            
                    else if(ageCnt <=100)
                        monthToAgeCountMap.get(keyStr).data100++;            
                    else 
                        monthToAgeCountMap.get(keyStr).data100p++;
                }
            }                                    
            
            CustomCaseReportSummary__c CCRS = new CustomCaseReportSummary__c();
            CustomCaseReportSummary__c CCRSLastMonth = new CustomCaseReportSummary__c();
            CustomCaseReportSummary__c CCRSPrevToLastMonth = new CustomCaseReportSummary__c();

            CCRS.Account__c = accId;
            CCRS.Case_Age_D1__c =  monthToAgeCountMap.get(currentMonth).data1;
            CCRS.Case_Age_D5__c =  monthToAgeCountMap.get(currentMonth).data5;
            CCRS.Case_Age_D30__c =  monthToAgeCountMap.get(currentMonth).data30;
            CCRS.Case_Age_D60__c =  monthToAgeCountMap.get(currentMonth).data60;
            CCRS.Case_Age_D100__c =  monthToAgeCountMap.get(currentMonth).data100;
            CCRS.Case_Age_D100p__c =  monthToAgeCountMap.get(currentMonth).data100p;
            
            CCRS.InitialResponseSLA__c =  monthToMSCountMap.get(currentMonth);
            CCRS.InitialResponseVIO__c =  monthToMSViolatedMap.get(currentMonth);
            CCRS.InitialResponseSLAP1__c =  monthToMSP1CountMap.get(currentMonth);
            CCRS.InitialResponseVIOP1__c =  monthToMSP1ViolatedMap.get(currentMonth);
            
            CCRS.OverallCSatNegative__c =  monthToCSATNegativeMap.get(currentMonth);
            CCRS.OverallCSatPositive__c =  monthToCSATPositiveMap.get(currentMonth);
            CCRS.OverallCSatCount__c =  monthToCSATCountMap.get(currentMonth);
            
            date dtm = Date.Today();        
            CCRS.ReferenceDate__c = monthsMap.get(dtm.month()) +  ' ' + string.valueof(dtm.year());
            if(dtm.month() < 10)
                CCRS.ExternID__c = dtm.year()+ '_0' + dtm.month() + '_' + accID;
            else            
                CCRS.ExternID__c = dtm.year()+ '_' + dtm.month() + '_' + accID;
            System.debug('CCRS.ExternID__c==>'+CCRS.ExternID__c);
            
            String tmpPrblmType = '';String tmpCateg = '';
            if(monthToPrblmMap.get(currentMonth).isEmpty() == FALSE) {
                system.debug('monthToPrblmMap==>'  + currentMonth + ' ' + monthToPrblmMap.get(currentMonth));    
                for(String key : monthToPrblmMap.get(currentMonth).keySet()) {                                    
                    system.debug('key==>' + key + monthToPrblmMap.get(currentMonth).get(key));
                    tmpPrblmType += key+'=' + monthToPrblmMap.get(currentMonth).get(key)+'<==>';
                }   
            }
            if(monthToCategMap.get(currentMonth).isEmpty() == FALSE) {
                system.debug('monthToCategMap==>'  + currentMonth + ' ' + monthToCategMap.get(currentMonth));    
                for(String key : monthToCategMap.get(currentMonth).keySet()) {                                    
                    system.debug('key==>' + key + monthToCategMap.get(currentMonth).get(key));
                    tmpCateg += key+'='+monthToCategMap.get(currentMonth).get(key)+'<==>';
                }      
            }
            CCRS.ProblemType_Cases__c = tmpPrblmType;
            CCRS.Category_Cases__c = tmpCateg ;                        
            //upsert CCRS ExternID__c;

            CCRSLastMonth.Account__c = accId;                
            CCRSLastMonth.Case_Age_D1__c =  monthToAgeCountMap.get(lastMonth).data1;
            CCRSLastMonth.Case_Age_D5__c =  monthToAgeCountMap.get(lastMonth).data5;
            CCRSLastMonth.Case_Age_D30__c =  monthToAgeCountMap.get(lastMonth).data30;
            CCRSLastMonth.Case_Age_D60__c =  monthToAgeCountMap.get(lastMonth).data60;
            CCRSLastMonth.Case_Age_D100__c =  monthToAgeCountMap.get(lastMonth).data100;
            CCRSLastMonth.Case_Age_D100p__c =  monthToAgeCountMap.get(lastMonth).data100p;
           
            CCRSLastMonth.InitialResponseSLA__c =  monthToMSCountMap.get(lastMonth);
            CCRSLastMonth.InitialResponseVIO__c =  monthToMSViolatedMap.get(lastMonth);
            CCRSLastMonth.InitialResponseSLAP1__c =  monthToMSP1CountMap.get(lastMonth);
            CCRSLastMonth.InitialResponseVIOP1__c =  monthToMSP1ViolatedMap.get(lastMonth);
           
            CCRSLastMonth.OverallCSatNegative__c =  monthToCSATNegativeMap.get(lastMonth);
            CCRSLastMonth.OverallCSatPositive__c =  monthToCSATPositiveMap.get(lastMonth);
            CCRSLastMonth.OverallCSatCount__c =  monthToCSATCountMap.get(lastMonth);
           
            dateTime dtmLastMonth = DateTime.Now().addMonths(-1);
            CCRSLastMonth.ReferenceDate__c = monthsMap.get(dtmLastMonth.month()) +  ' ' + string.valueof(dtmLastMonth.year());
            if(dtmLastMonth.month() < 10)
                CCRSLastMonth.ExternID__c = dtmLastMonth.year() + '_0' +  dtmLastMonth.month() + '_'  + accID ;
            else
                CCRSLastMonth.ExternID__c = dtmLastMonth.year() + '_' +  dtmLastMonth.month() + '_'  + accID ;
            
            System.debug('CCRSLastMonth.ExternID__c==>'+CCRSLastMonth.ExternID__c);
            tmpPrblmType = '';tmpCateg = '';
            if(monthToPrblmMap.get(lastMonth).isEmpty() == FALSE) {
                system.debug('monthToPrblmMap==>'  + lastMonth + ' ' + monthToPrblmMap.get(lastMonth));    
                for(String key : monthToPrblmMap.get(lastMonth).keySet()) {                                    
                    system.debug('key==>' + key + monthToPrblmMap.get(lastMonth).get(key));
                    tmpPrblmType += key+'=' + monthToPrblmMap.get(lastMonth).get(key)+'<==>';
                }   
            }
            if(monthToCategMap.get(lastMonth).isEmpty() == FALSE) {
                system.debug('monthToCategMap==>'  + lastMonth + ' ' + monthToCategMap.get(lastMonth));    
                for(String key : monthToCategMap.get(lastMonth).keySet()) {                                    
                    system.debug('key==>' + key + monthToCategMap.get(lastMonth).get(key));
                    tmpCateg += key+'='+monthToCategMap.get(lastMonth).get(key)+'<==>';
                }      
            }
            CCRSLastMonth.ProblemType_Cases__c = tmpPrblmType;
            CCRSLastMonth.Category_Cases__c = tmpCateg ;                        
            //upsert CCRSLastMonth ExternID__c;
                        
            CCRSPrevToLastMonth.Account__c = accId;            
            dateTime dtmPrevLastMonth = DateTime.Now().addMonths(-2);
            CCRSPrevToLastMonth.ReferenceDate__c = monthsMap.get(dtmPrevLastMonth.month()) +  ' ' + string.valueof(dtmPrevLastMonth.year());
            
            if(dtmPrevLastMonth.month() < 10)
                CCRSPrevToLastMonth.ExternID__c = dtmPrevLastMonth.year() + '_0' + dtmPrevLastMonth.month() + '_' + accID;
            else
                CCRSPrevToLastMonth.ExternID__c = dtmPrevLastMonth.year() + '_' + dtmPrevLastMonth.month() + '_' + accID;
            
            
            System.debug('CCRSPrevToLastMonth.ExternID__c==>'+CCRSPrevToLastMonth.ExternID__c);
           
            CCRSPrevToLastMonth.Case_Age_D1__c =  monthToAgeCountMap.get(prevToLastMonth).data1;
            CCRSPrevToLastMonth.Case_Age_D5__c =  monthToAgeCountMap.get(prevToLastMonth).data5;
            CCRSPrevToLastMonth.Case_Age_D30__c =  monthToAgeCountMap.get(prevToLastMonth).data30;
            CCRSPrevToLastMonth.Case_Age_D60__c =  monthToAgeCountMap.get(prevToLastMonth).data60;
            CCRSPrevToLastMonth.Case_Age_D100__c =  monthToAgeCountMap.get(prevToLastMonth).data100;
            CCRSPrevToLastMonth.Case_Age_D100p__c =  monthToAgeCountMap.get(prevToLastMonth).data100p;
           
            CCRSPrevToLastMonth.InitialResponseSLA__c =  monthToMSCountMap.get(prevToLastMonth);
            CCRSPrevToLastMonth.InitialResponseVIO__c =  monthToMSViolatedMap.get(prevToLastMonth);
            CCRSPrevToLastMonth.InitialResponseSLAP1__c =  monthToMSP1CountMap.get(prevToLastMonth);
            CCRSPrevToLastMonth.InitialResponseVIOP1__c =  monthToMSP1ViolatedMap.get(prevToLastMonth);
           
            CCRSPrevToLastMonth.OverallCSatNegative__c =  monthToCSATNegativeMap.get(prevToLastMonth);
            CCRSPrevToLastMonth.OverallCSatPositive__c =  monthToCSATPositiveMap.get(prevToLastMonth);            
            CCRSPrevToLastMonth.OverallCSatCount__c =  monthToCSATCountMap.get(prevToLastMonth);

            tmpPrblmType = '';tmpCateg = '';
            if(monthToPrblmMap.get(prevToLastMonth).isEmpty() == FALSE) {
                system.debug('monthToPrblmMap==>'  + prevToLastMonth + ' ' + monthToPrblmMap.get(prevToLastMonth));    
                for(String key : monthToPrblmMap.get(prevToLastMonth).keySet()) {                                    
                    system.debug('key==>' + key + monthToPrblmMap.get(prevToLastMonth).get(key));
                    tmpPrblmType += key+'=' + monthToPrblmMap.get(prevToLastMonth).get(key)+'<==>';
                }   
            }
            if(monthToCategMap.get(prevToLastMonth).isEmpty() == FALSE) {
                system.debug('monthToCategMap==>'  + prevToLastMonth + ' ' + monthToCategMap.get(prevToLastMonth));    
                for(String key : monthToCategMap.get(prevToLastMonth).keySet()) {                                    
                    system.debug('key==>' + key + monthToCategMap.get(prevToLastMonth).get(key));
                    tmpCateg += key+'='+monthToCategMap.get(prevToLastMonth).get(key)+'<==>';
                }      
            }            
            CCRSPrevToLastMonth.ProblemType_Cases__c = tmpPrblmType;
            CCRSPrevToLastMonth.Category_Cases__c = tmpCateg ;                        
            //upsert CCRSPrevToLastMonth ExternID__c;
            
            List<CustomCaseReportSummary__c> tmpUpsertList = new List<CustomCaseReportSummary__c>{CCRSPrevToLastMonth,CCRSLastMonth,CCRS};
            MainUpsertList.addAll(tmpUpsertList); 
                                    
        }
        upsert MainUpsertList ExternID__c;

                
    }
    
    
    public class StackedData {
        public Integer name { get; set; }
        public Integer data1   { get; set; }
        public Integer data5  { get; set; }
        public Integer data30 { get; set; }
        public Integer data60 { get; set; }
        public Integer data100 { get; set; }
        public Integer data100p { get; set; }
        public StackedData(Integer name, Integer data1, Integer data5, Integer data30, Integer data60, Integer data100,Integer data100p) {
            this.name = name;
            this.data1 = data1;
            this.data5 = data5;
            this.data30 = data30;
            this.data60 = data60;
            this.data100 = data100;            
            this.data100p = data100p;
        }
    }
    
    private static Map<Integer,String> monthsMap = new Map<Integer,String> {
      1  => 'Jan',
      2  => 'Feb',
      3  => 'Mar',
      4  => 'Apr',
      5  => 'May',
      6  => 'Jun',
      7  => 'Jul',
      8  => 'Aug',
      9  => 'Sep',
      10 => 'Oct',
      11 => 'Nov',
      12 => 'Dec' 
    };
        
}