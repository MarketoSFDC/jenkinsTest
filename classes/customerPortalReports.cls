public class customerPortalReports {

    public string accountId {get;set;}
    public string reportType {get;set;}
    public List<Entitlement> entitLst{get;set;}
    public boolean rendr {get;set;}
    public String intervalType{get;set;}
    public Date fromDate{get;set;}
    public Date toDate{get;set;}
    public DateTime refreshDate{get;set;}
    private static string SupportCases  = '01250000000UJwxAAG';
    private User u1;
    
    public Boolean isAuthorizedElite {get;set;}    
    
    //getter setter can be removed, for now these values are used in customerPortalReports vf page
    public List<CustomReportDataPercent> P1CustomerResponseSLA{get;set;}
    public List<CustomReportDataPercent> InitCustomerResponseSLA {get;set;}
    public List<CustomReportDataPercent> OverAllCSAT{get;set;}
    public List<CustomReportData> CasesByProblemType{get;set;}
    public List<CustomReportData> CasesByCategory{get;set;}
    public List<StackedData> CasesByAging{get;set;}
    
    //getter setter for json string                
    public String jsonP1CustomerResponseSLA{get;set;}
    public String jsonInitCustomerResponseSLA {get;set;}
    public String jsonOverAllCSAT{get;set;}
    public String jsonCasesByAging{get;set;}
    public String jsonCasesByProblemType{get;set;}
    public String jsonCasesByCategory{get;set;}
    

    public customerPortalReports() {        
        intervalType='thisQuarter'; //default value when page initailly loaded
        isAuthorizedElite  = false;
        u1 = [SELECT Id,Contact.Id,Munchkin_Id__c, Contact.Is_Authorized_Contact__c,Contact.Account.Id FROM User where id = :userinfo.getuserId() Limit 1];
        
        List<Authorized_Contact__c> authorizedContact = new List<Authorized_Contact__c>([Select Entitlement__c, Entitlement__r.Type,Entitlement__r.AssetId, Entitlement__r.Asset.Munchkin_Id__c From Authorized_Contact__c where Entitlement__r.AccountId = :u1.Contact.Account.Id AND Contact__c =: u1.ContactId AND Entitlement__r.Asset.Munchkin_Id__c =: u1.Munchkin_Id__c and Entitlement__r.Status = 'Active' AND Entitlement__r.Type in ('Elite','Premier','Premier Plus') Limit 1]);
        if(authorizedContact.size() > 0 || Test.isRunningTest()) {
            isAuthorizedElite = true;        
            initData(); 
        } else {
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.Error,'Reports are only visible to Elite/Premier/PremierPlus Users'));  
        }
    }
    
    public void initData() {
    
        system.debug('intervalType==>' + intervalType);
        
        //initialize all the variables           
        P1CustomerResponseSLA = new List<CustomReportDataPercent>();
        InitCustomerResponseSLA = new List<CustomReportDataPercent>();
        OverAllCSAT = new List<CustomReportDataPercent>();
        CasesByProblemType = new List<CustomReportData>();
        CasesByCategory = new List<CustomReportData>();
        CasesByAging = new List<StackedData>();
        jsonCasesByCategory = ''; jsonCasesByProblemType = '';
        List<String> externalIds = new List<String>();
        
        date dtm = Date.Today();    
        toDate = dtm ;    
        fromDate = dtm.addmonths(-2).toStartOfMonth();
        //u1 = [SELECT Id,Contact.Is_Authorized_Contact__c,  Contact.Account.Id FROM User where id = :userinfo.getuserId()];
        string accId = u1.Contact.Account.Id;        
        
        
        
        if(isAuthorizedElite == TRUE) {
            rendr = true;
            String CCRSExternID = '';
            if(dtm.month() < 10)
                CCRSExternID = dtm.year() + '_0' + dtm.month() + '_' + accID; //this month
            else
                CCRSExternID = dtm.year() + '_' + dtm.month() + '_' + accID; //this month
            
            String CCRSLMExternID = '';
            if(dtm.addmonths(-1).month() < 10)
                CCRSLMExternID = dtm.addmonths(-1).year() + '_0' + dtm.addmonths(-1).month() + '_' + accID; //last month
            else    
                CCRSLMExternID = dtm.addmonths(-1).year() + '_' + dtm.addmonths(-1).month() + '_' + accID; //last month
            
            String CCRSP2LMExternID = '';
            if(dtm.addmonths(-2).month() < 10)
                CCRSP2LMExternID = dtm.addmonths(-2).year() + '_0' + dtm.addmonths(-2).month() + '_' + accID;//prev to last month
            else
                CCRSP2LMExternID = dtm.addmonths(-2).year() + '_' + dtm.addmonths(-2).month() + '_' + accID;//prev to last month
            
            //Select which external ids to fetch for time interval selected
            if(intervalType == 'thisQuarter') {
                externalIds.addAll(new list<string>{CCRSExternID,CCRSLMExternID,CCRSP2LMExternID});                
                //fromDate = dtm.addmonths(-2).toStartOfMonth();
                //toDate = tmpRec.LastModifiedDate.Date();
            } else if(intervalType == 'prevMonth') {
                externalIds.addAll(new list<String>{CCRSLMExternID});      
                fromDate = dtm.addMonths(-1).toStartOfMonth();    
                toDate  =   fromDate.addDays(Date.daysInMonth(fromDate.year(), fromDate.month())-1);
            } else { //thisMonth
                externalIds.add(CCRSExternID);
                fromDate = dtm.toStartOfMonth();      
            }
            

            
            List<CustomCaseReportSummary__c> myReportLst = [SELECT ID, Case_Age_D1__c,Case_Age_D5__c, Case_Age_D30__c, Case_Age_D60__c, Case_Age_D100__c,
            Case_Age_D100p__c, InitialResponseSLA__c, InitialResponseVIO__c, InitialResponseSLAP1__c, InitialResponseVIOP1__c, OverallCSatNegative__c, 
            OverallCSatPositive__c, OverallCSatCount__c,ExternID__c,ReferenceDate__c , Category_Cases__c,ProblemType_Cases__c,LastmodifiedDate
            from CustomCaseReportSummary__c Where ExternID__c in :externalIds]; 
               
            //(SELECT Account__c, Type__c, SubType__c,Count__c,CustomCaseReportSummary__c from CustomeCaseReportChild__r)
                        
            Map<String,Integer> categToCountMap = new Map<String, Integer>();           
            Map<String,Integer> prblmToCountMap = new Map<String, Integer>();           
            for(CustomCaseReportSummary__c  tmpRec: myReportLst) {              
                refreshDate = tmpRec.LastModifiedDate;//getLocalDateTime(tmpRec.LastModifiedDate);
                //if(intervalType == 'thisQuarter') toDate = tmpRec.LastModifiedDate.Date(); 
                
                StackedData s1 = new StackedData(tmpRec.ReferenceDate__c,Integer.valueOf(tmpRec.Case_Age_D1__c),Integer.valueOf(tmpRec.Case_Age_D5__c),Integer.valueOf(tmpRec.Case_Age_D30__c),Integer.valueOf(tmpRec.Case_Age_D60__c),Integer.valueOf(tmpRec.Case_Age_D100__c),Integer.valueOf(tmpRec.Case_Age_D100p__c));
                CasesByAging.Add(s1);                
                Decimal  tmpData = 0;
                if(tmpRec.OverallCSatCount__c > 0) {//check for division by zero
                    tmpData = (tmpRec.OverallCSatPositive__c/tmpRec.OverallCSatCount__c)*100;                    
                }
                CustomReportDataPercent c1 = new CustomReportDataPercent(tmpRec.ReferenceDate__c,Integer.valueOf(tmpRec.OverallCSatCount__c),Integer.valueOf(tmpRec.OverallCSatNegative__c),Integer.valueOf(tmpRec.OverallCSatPositive__c),tmpData);
                OverAllCSAT.add(c1);

                tmpData = 0;
                if(tmpRec.InitialResponseSLA__c > 0) {
                    tmpData = ((tmpRec.InitialResponseSLA__c - tmpRec.InitialResponseVIO__c)/tmpRec.InitialResponseSLA__c)*100;
                }      
                c1 = new CustomReportDataPercent(tmpRec.ReferenceDate__c,Integer.valueOf(tmpRec.InitialResponseSLA__c),Integer.valueOf(tmpRec.InitialResponseVIO__c),Integer.valueOf(tmpRec.InitialResponseSLA__c - tmpRec.InitialResponseVIO__c),tmpData);                
                InitCustomerResponseSLA.ADD(c1);                
                tmpData = 0;
                if(tmpRec.InitialResponseSLAP1__c > 0) {
                    tmpData = ((tmpRec.InitialResponseSLAP1__c - tmpRec.InitialResponseVIOP1__c)/tmpRec.InitialResponseSLAP1__c)*100;
                }
                c1 = new CustomReportDataPercent(tmpRec.ReferenceDate__c,Integer.valueOf(tmpRec.InitialResponseSLAP1__c),Integer.valueOf(tmpRec.InitialResponseVIOP1__c),Integer.valueOf(tmpRec.InitialResponseSLAP1__c - tmpRec.InitialResponseVIOP1__c),tmpData);                
                P1CustomerResponseSLA.ADD(c1);
                /* else { 
                    CustomReportDataPercent  c1 = new CustomReportDataPercent(tmpRec.ReferenceDate__c,Integer.valueOf(tmpRec.InitialResponseSLAP1__c),Integer.valueOf(tmpRec.InitialResponseVIOP1__c),Integer.valueOf(tmpRec.InitialResponseSLAP1__c - tmpRec.InitialResponseVIOP1__c),tmpData);                
                    P1CustomerResponseSLA.ADD(c1);                
                }*/      
                
                          
                System.Debug('tmpRec.ProblemType_Cases__c==>'+ tmpRec.ProblemType_Cases__c);
                
                
                //ProblemType_Cases__c==>How-To=1<==>Other=1<==>
                //First split on <==> then on =
                if(tmpRec.ProblemType_Cases__c != NULL && tmpRec.ProblemType_Cases__c.trim() != '') {
                    if(tmpRec.ProblemType_Cases__c.contains('<==>')) {
                        List<String> prblmTypeMainStr = tmpRec.ProblemType_Cases__c.split('<==>');
                        if(prblmTypeMainStr.isEmpty() == FALSE) {
                            for(string tmpStr : prblmTypeMainStr) {
                                List<String> prblmTypeSubStr = tmpStr.split('=');
                                if(prblmTypeSubStr.size() == 2) {                                    
                                    if(prblmToCountMap.containsKey(prblmTypeSubStr[0])) {
                                        prblmToCountMap.put(prblmTypeSubStr[0],Integer.valueOf(prblmTypeSubStr[1]) + prblmToCountMap.get(prblmTypeSubStr[0]));
                                    } else {
                                        prblmToCountMap.put(prblmTypeSubStr[0],Integer.valueOf(prblmTypeSubStr[1]));                        
                                    }                                      
                                }                            
                            }
                        }                        
                    }                    
                }
                
                //System.Debug('tmpRec.Category_Cases__c==>'+ tmpRec.Category_Cases__c);                
                
                //Category_Cases__c==>Design Studio=9<==>Case Review=1<==>Other=1<==>NULL=1<==>                
                //First split on <==> then on =
                if(tmpRec.Category_Cases__c != NULL && tmpRec.Category_Cases__c.trim() != '') {
                    if(tmpRec.Category_Cases__c.contains('<==>')) {
                        List<String> catgTypeMainStr = tmpRec.Category_Cases__c.split('<==>');
                        if(catgTypeMainStr.isEmpty() == FALSE) {
                            for(string tmpStr : catgTypeMainStr) {
                                List<String> catgTypeSubStr = tmpStr.split('=');
                                if(catgTypeSubStr.size() == 2) {                                    
                                    if(categToCountMap.containsKey(catgTypeSubStr[0])) {
                                        categToCountMap.put(catgTypeSubStr[0],Integer.valueOf(catgTypeSubStr[1]) + categToCountMap.get(catgTypeSubStr[0]));
                                    } else {
                                        categToCountMap.put(catgTypeSubStr[0],Integer.valueOf(catgTypeSubStr[1]));                        
                                    }                                      
                                }                            
                            }
                        }                        
                    }                    
                }                
                                                                              
            }
                    
            for(string key : prblmToCountMap.keySet()) {
                CustomReportData c2 = new CustomReportData(key,prblmToCountMap.get(key));
                CasesByProblemType.Add(c2);                                         
            }
            for(string key : categToCountMap.keySet()) {
                CustomReportData c2 = new CustomReportData(key,categToCountMap.get(key));
                CasesByCategory.Add(c2);                                         
            }                     
                 
            //sort data month wise
            CasesByAging.Sort(); 
            P1CustomerResponseSLA.Sort();
            InitCustomerResponseSLA.Sort();
            OverAllCSAT.Sort();                
            
            //Serialize and make available to vf page variables.
            jsonCasesByProblemType =   JSON.serialize(CasesByProblemType);                                                
            jsonCasesByCategory =   JSON.serialize(CasesByCategory);    
            jsonCasesByAging = JSON.serialize(CasesByAging);                          
            jsonP1CustomerResponseSLA = JSON.serialize(P1CustomerResponseSLA);            
            jsonInitCustomerResponseSLA = JSON.serialize(InitCustomerResponseSLA);                                                
            jsonOverAllCSAT =   JSON.serialize(OverAllCSAT);            
        }            
    
    }
    
    
    /*
    
    public DateTime getLocalDateTime(DateTime modifiedDate){
        TimeZone tz =  UserInfo.getTimeZone();                
        return modifiedDate.AddSeconds(tz.getOffset(modifiedDate)/1000);
    } 
    
    // Return a list of data points for a chart    
    public List<CustomReportData> getP1CustomerResponseSLAPercent() {    
        DateTime startDate = DateTime.now().addMonths(-6); DateTime endDate = DateTime.now();              
        List<CustomReportData> Lst1 = new List<CustomReportData>();
        Map<Integer,Integer> monthToCountMap = new Map<Integer, Integer>();
        Map<Integer,Integer> monthToViolatedMap = new Map<Integer, Integer>();     
        Map<String,Integer> prblmToCountMap = new Map<String, Integer>();   
        List<Case> closedSupportCases = [SELECT Id, ClosedDate,Problem_Type__c, Status From Case Where 
        Account.Id = :u1.Contact.Account.Id 
        AND RecordTypeId =:SupportCases 
        AND Status = 'Closed'
        AND Priority = 'P1' 
        AND ClosedDate <= :EndDate AND ClosedDate >= : StartDate      
        AND (NOT Case.Close_Reason__c  in ('Spam','Duplicate','Invalid Case','Partner Supported Referral','Unauthorized Contact Reroute')) Order By ClosedDate]; 
        for(Case cm :closedSupportCases) {
            if(monthToCountMap.containsKey(cm.ClosedDate.Month())) {
                 monthToCountMap.put(cm.ClosedDate.Month(),monthToCountMap.get(cm.ClosedDate.Month())+1);
            } else {
                 monthToCountMap.put(cm.ClosedDate.Month(),1);
            }                                                 
        }                
        for(Integer key : monthToCountMap.keyset()) {        
            //Decimal  tmpData = ((monthToCountMap.get(key)- monthToViolatedMap.get(key)) < 1) ? 0 : ( (monthToCountMap.get(key)- monthToViolatedMap.get(key)) / monthToCountMap.get(key) );
            CustomReportData c1 = new CustomReportData(monthsMap.get(key),monthToCountMap.get(key));//tmpData);
            Lst1.add(c1);                    
        }
        System.debug(Lst1);
        return Lst1;               
    } 
                  
    public List<CustomReportDataPercent> getCustomerInitialResponseSLAPercent() {    
        DateTime startDate = DateTime.now().addMonths(-6); DateTime endDate = DateTime.now();              
        System.debug('startDate=> ' + startDate + ' endDate-> ' + endDate); 
        //IF(RowCount - IS_VIOLATED:SUM < 1, 0, (RowCount - IS_VIOLATED:SUM) / RowCount)
        List<CustomReportDataPercent> Lst1 = new List<CustomReportDataPercent>();
        Map<Integer,Integer> monthToCountMap = new Map<Integer, Integer>();
        Map<Integer,Integer> monthToViolatedMap = new Map<Integer, Integer>();     
        
        List<Case> closedSupportCases = [SELECT Id, CreatedDate, ClosedDate,Problem_Type__c, Status, 
        (SELECT Id, Start_Date__c,Violation__c From Case_Milestones__r Where Violation__c = true AND  Milestone_Type__c = 'First Response')         
        From Case Where 
        Account.Id = :u1.Contact.Account.Id 
        AND RecordTypeId =:SupportCases 
        //AND Status = 'Closed'
        AND CreatedDate <= :EndDate AND CreatedDate >= : StartDate      
        AND (NOT Case.Close_Reason__c  in ('Self-Service/No Agent','Spam','Duplicate','Invalid Case','Partner Supported Referral','Unauthorized Contact Reroute')) Order By CreatedDate]; 

        for(Case cm :closedSupportCases) {
            if(!monthToViolatedMap.containsKey(cm.CreatedDate.Month())) 
                monthToViolatedMap.put(cm.CreatedDate.Month(),0);                
            if(!monthToCountMap.containsKey(cm.CreatedDate.Month())) 
                 monthToCountMap.put(cm.CreatedDate.Month(),1);

            monthToCountMap.put(cm.CreatedDate.Month(),monthToCountMap.get(cm.CreatedDate.Month())+1); 
            if(cm.Case_Milestones__r.isEmpty() == FALSE && cm.Case_Milestones__r[0].Violation__c == true)  
                monthToViolatedMap.put(cm.CreatedDate.Month(),monthToViolatedMap.get(cm.CreatedDate.Month())+1);                                
        } 
        
        for(Integer key : monthToCountMap.keyset()) {        
            Decimal  tmpData = (((Decimal)monthToCountMap.get(key) - (Decimal)monthToViolatedMap.get(key))/(Decimal)monthToCountMap.get(key))*100;
            CustomReportDataPercent c1 = new CustomReportDataPercent(monthsMap.get(key),monthToCountMap.get(key),monthToViolatedMap.get(key),tmpData);
            Lst1.add(c1);                    
        }        
        System.debug(Lst1);
        return Lst1;               
    }        
    
    public List<CustomReportDataPercent>  getOverallCSATPercentage() {        
        DateTime startDate = DateTime.now().addMonths(-6); DateTime endDate = DateTime.now(); 
        List<CustomReportDataPercent> Lst1 = new List<CustomReportDataPercent>();
        Map<Integer,Integer> monthToCountMap = new Map<Integer, Integer>();
        Map<Integer,Integer> monthToViolatedMap = new Map<Integer, Integer>();               
        List<CSatSurveyFeedback__c> filledSupportCSats = [SELECT Id,Overall_CSAT_Positive__c,Case__r.ClosedDate From CSatSurveyFeedback__c Where  
        Case__r.Account.Id = :u1.Contact.Account.Id 
        AND Case__r.ClosedDate <= :EndDate AND Case__r.ClosedDate >= : StartDate 
        AND (NOT Case__r.Close_Reason__c  in ('Spam','Duplicate','Invalid Case','Partner Supported Referral','Unauthorized Contact Reroute')) Order By Case__r.ClosedDate];         
        for(CSatSurveyFeedback__c cm :filledSupportCSats) {
            if(!monthToViolatedMap.containsKey(cm.Case__r.ClosedDate.Month())) 
                monthToViolatedMap.put(cm.Case__r.ClosedDate.Month(),0);                
            if(!monthToCountMap.containsKey(cm.Case__r.ClosedDate.Month())) 
                monthToCountMap.put(cm.Case__r.ClosedDate.Month(),0);                            
            if(cm.Overall_CSAT_Positive__c == NULL || cm.Overall_CSAT_Positive__c == FALSE) {
                monthToViolatedMap.put(cm.Case__r.ClosedDate.Month(),monthToViolatedMap.get(cm.Case__r.ClosedDate.Month())+1);                    
            } else {                                      
                monthToCountMap.put(cm.Case__r.ClosedDate.Month(),monthToCountMap.get(cm.Case__r.ClosedDate.Month())+1);
            }
        }        
        for(Integer key :monthToCountMap.keyset()) {        
            Decimal  tmpData = ((Decimal)monthToCountMap.get(key)/(monthToViolatedMap.get(key)+monthToCountMap.get(key)))*100;
            CustomReportDataPercent c1 = new CustomReportDataPercent(monthsMap.get(key),monthToCountMap.get(key),monthToViolatedMap.get(key),tmpData);
            Lst1.add(c1);                    
        }
        System.debug(Lst1);                
        return Lst1;
    }
    
    public List<CustomReportData> getClosedCasesByProblemType() {    
        DateTime startDate = DateTime.now().addMonths(-6); DateTime endDate = DateTime.now(); 
        List<CustomReportData> Lst1 = new List<CustomReportData>();
        Map<String,Integer> prblmToCountMap = new Map<String, Integer>();   
        List<Case> closedSupportCases = [SELECT Id, ClosedDate,Problem_Type__c, Status From Case Where 
        Account.Id = :u1.Contact.Account.Id 
        AND RecordTypeId =:SupportCases 
        AND Status = 'Closed' 
        AND ClosedDate <= :EndDate AND ClosedDate >= : StartDate 
        AND (NOT Case.Close_Reason__c  in ('Spam','Duplicate','Invalid Case','Partner Supported Referral','Unauthorized Contact Reroute')) Order By ClosedDate]; 
        for(Case cm :closedSupportCases) {
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
        }
        for(String key : prblmToCountMap.keyset()) {        
            CustomReportData c1 = new CustomReportData(key,prblmToCountMap.get(key));
            Lst1.add(c1);                    
        }
        System.debug(Lst1);
        return Lst1;
    }

    public List<CustomReportData> getClosedCasesByCategory() {    
        DateTime startDate = DateTime.now().addMonths(-6); DateTime endDate = DateTime.now();  
        List<CustomReportData> Lst1 = new List<CustomReportData>();
        Map<String,Integer> categToCountMap = new Map<String, Integer>();   
        List<Case> closedSupportCases = [SELECT Id, ClosedDate,Category__c, Status From Case Where 
        Account.Id = :u1.Contact.Account.Id 
        AND RecordTypeId =:SupportCases 
        AND Status = 'Closed'
        AND ClosedDate <= :EndDate AND ClosedDate >= : StartDate      
        AND (NOT Case.Close_Reason__c  in ('Spam','Duplicate','Invalid Case','Partner Supported Referral','Unauthorized Contact Reroute')) Order By ClosedDate]; 
        for(Case cm :closedSupportCases) {            
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
        }    
               
        for(String key : categToCountMap.keyset()) {        
            CustomReportData c1 = new CustomReportData(key,categToCountMap.get(key));
            Lst1.add(c1);                    
        }                   
        System.debug(Lst1);
        return Lst1;               
    }        

    public List<StackedData> getClosedCasesAging() {    
        DateTime startDate = DateTime.now().addMonths(-6); DateTime endDate = DateTime.now();  
        List<StackedData> Lst2 = new List<StackedData>();
        Map<Integer,StackedData> monthToCountMap = new Map<Integer,StackedData>();
        List<Case> closedSupportCases = [SELECT Id, ClosedDate,Category__c, Status, AgeInDays__c From Case Where 
        Account.Id = :u1.Contact.Account.Id 
        AND RecordTypeId =:SupportCases 
        AND Status = 'Closed'
        AND ClosedDate != NULL           
        AND ClosedDate <= :EndDate AND ClosedDate >= : StartDate      
        AND (NOT Case.Close_Reason__c  in ('Spam','Duplicate','Invalid Case','Partner Supported Referral','Unauthorized Contact Reroute')) Order By ClosedDate]; 
        for(Case cm :closedSupportCases) { 
            System.debug('Closed Date==> ' + cm.ClosedDate);            
            if(!monthToCountMap.containsKey(cm.ClosedDate.Month())) {
                StackedData s1 = new StackedData(monthsMap.get(cm.ClosedDate.Month()),0,0,0,0,0,0);
                monthToCountMap.put(cm.ClosedDate.Month(), s1);
            }
            if(monthToCountMap.containsKey(cm.ClosedDate.Month())) {
                integer ageCnt = (Integer)cm.AgeInDays__c;                                    
                if(ageCnt <=1)
                    monthToCountMap.get(cm.ClosedDate.Month()).data1++;            
                else if(ageCnt <=5)
                    monthToCountMap.get(cm.ClosedDate.Month()).data5++;            
                else if(ageCnt <=30)
                    monthToCountMap.get(cm.ClosedDate.Month()).data30++;            
                else if(ageCnt <=60)
                    monthToCountMap.get(cm.ClosedDate.Month()).data60++;            
                else if(ageCnt <=100)
                    monthToCountMap.get(cm.ClosedDate.Month()).data100++;            
                else 
                    monthToCountMap.get(cm.ClosedDate.Month()).data100p++;
            }

        }                   
        for(Integer key : monthToCountMap.keyset()) {        
            StackedData  c1 = monthToCountMap.get(key);
            Lst2.add(c1);                    
        }
        System.debug(Lst2);
        return Lst2;               
    }     
    */
    
    // Wrapper class with comparable interface, other approach would be to fetch data in sorted order.
    public class CustomReportData implements Comparable{
        public String name { get; set; }
        public Integer data { get; set; }
        public CustomReportData (String name, Integer data) {
            this.name = name;
            this.data = data;
        }
        public Integer compareTo(Object compareTo){
            CustomReportData compareToCls = (CustomReportData)compareTo;
            List<String> tmpLst = compareToCls.name.split(' ');
            List<String> objLst = this.name.split(' ');
            Date objDate = date.valueOf(objLst[1]+'-'+monthsToStringMap.get(objLst[0])+'-1');
            Date tmpDate = date.valueOf(tmpLst[1]+'-'+monthsToStringMap.get(tmpLst[0])+'-1');            
            if (objDate == tmpDate) return 0;
            if (objDate >  tmpDate) return 1;
            return -1;
        }
    }               
    // Wrapper class          
    public class CustomReportDataPercent implements Comparable{
        public String name { get; set; }
        public Integer data { get; set; }
        public Integer nData { get; set; }
        public Integer pData { get; set; }
        public Decimal perCent { get; set; }
        public CustomReportDataPercent (String name, Integer data, Integer nData, Integer pData,Decimal perCent) {
            this.name = name;
            this.data = data;
            this.nData = nData;
            this.pData = pData;
            this.perCent = perCent;
        }
        public Integer compareTo(Object compareTo){
            CustomReportDataPercent compareToCls = (CustomReportDataPercent)compareTo;
            List<String> tmpLst = compareToCls.name.split(' ');
            List<String> objLst = this.name.split(' ');
            Date objDate = date.valueOf(objLst[1]+'-'+monthsToStringMap.get(objLst[0])+'-1');
            Date tmpDate = date.valueOf(tmpLst[1]+'-'+monthsToStringMap.get(tmpLst[0])+'-1');            
            if (objDate == tmpDate) return 0;
            if (objDate >  tmpDate) return 1;
            return -1;
        }
    }    

    // Wrapper class
    public class StackedData implements Comparable {
        public String name { get; set; }
        public Integer data1   { get; set; }
        public Integer data5  { get; set; }
        public Integer data30 { get; set; }
        public Integer data60 { get; set; }
        public Integer data100 { get; set; }
        public Integer data100p { get; set; }
        public StackedData(String name, Integer data1, Integer data5, Integer data30, Integer data60, Integer data100,Integer data100p) {
            this.name = name;
            this.data1 = data1;
            this.data5 = data5;
            this.data30 = data30;
            this.data60 = data60;
            this.data100 = data100;
            this.data100p = data100p;
        }
        public Integer compareTo(Object compareTo){
            StackedData compareToCls = (StackedData)compareTo;
            List<String> tmpLst = compareToCls.name.split(' ');
            List<String> objLst = this.name.split(' ');
            Date objDate = date.valueOf(objLst[1]+'-'+monthsToStringMap.get(objLst[0])+'-1');
            Date tmpDate = date.valueOf(tmpLst[1]+'-'+monthsToStringMap.get(tmpLst[0])+'-1');            
            if (objDate == tmpDate) return 0;
            if (objDate >  tmpDate) return 1;
            return -1;
        }
    }
         
    public static Map<Integer,String> monthsMap = new Map<Integer,String> {
      1  => 'January',
      2  => 'February',
      3  => 'March',
      4  => 'April',
      5  => 'May',
      6  => 'June' ,
      7  => 'July',
      8  => 'August' ,
      9  => 'September',
      10 => 'October' ,
      11 => 'November',
      12 => 'December' 
    };        
         
    public static Map<String,Integer> monthsToStringMap = new Map<String,Integer> {
      'Jan' => 1,
      'Feb' => 2,
      'Mar' => 3,
      'Apr' => 4,
      'May' => 5,
      'Jun' => 6,
      'Jul' => 7,
      'Aug' => 8,
      'Sep' => 9,
      'Oct' => 10,
      'Nov' => 11,
      'Dec' => 12 
    };    
    
    public static Map<Integer,List<Integer>> agingMap = new Map<Integer,List<Integer>> {
        1 =>  new List<Integer>{0,2},
        5 =>  new List<Integer>{2,5},
        15 => new List<Integer>{5,15},
        35 => new List<Integer>{15,30},
        60 => new List<Integer>{60,100},      
        100 => new List<Integer>{100,10000}      
    };
}