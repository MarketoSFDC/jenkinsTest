public class EWSDashboardController{

    public String selectedPoint {get;set;}
    public Activities__c activityToCreate {get;set;}
    public Account acc {get;set;}
    public String theWeek {get;set;}
    public String theWeekRange {get;set;}
    public String theType {get;set;}
    public Decimal theTypeScore {get;set;}
    public String customerSince {get;set;}
    public Id redCapId{get;set;}
    
    public String outReachValue {get;set;}
    public String actItem {get;set;}
    
    public String breakDownKey {get;set;}
    public List<EWSDashboardController> breakDownValues {get;set;}
    public String breakDownInnerKey {get;set;}
    public Decimal theScore {get;set;}
    
    Decimal th1 {get;set;}
    Decimal th2 {get;set;}
    Decimal th3 {get;set;}
    
    public string week3StartFilter {get;set;}
    public string Week3EndFilter {get;set;}
    
    public string month6StartFilter {get;set;}
    public string month6EndFilter {get;set;}
    
    public String report1 {get;set;}
    public String report2 {get;set;}
    public String report3 {get;set;}
    public String report4 {get;set;}
    public String report5 {get;set;}
    
    public Static Decimal theTotalScore {get;set;}
    public Integer totalCases {get;set;}
    public Decimal arrAcc {get;set;}
    public String entLevel {get;set;}
    public String renewalDate {get;set;}
    public String temperature {get;set;}
    public String cam {get;set;}
    public String nse {get;set;}
    public String nseIden {get;set;}
    Map<Id,EWS_Point_Table__c> activitiesMap {get;set;}
    public Decimal knownLeadCount {get;set;}
    public Decimal emailsentcount {get;set;}
    public Decimal sessioncount {get;set;}
    public Decimal changedatavaluecount {get;set;}
    
    public EWSDashboardController(){        
        breakDownValues = new List<EWSDashboardController>();
        activityToCreate = new Activities__c(Account__c=Apexpages.currentPage().getParameters().get('Paramtervalue'));                 
    }
    public String theMsg {get; set;}
    public boolean displayPopup {get; set;}     
    public boolean displayPopupEmail {get; set;}
    public String subjectEmail {get; set;}
    public String bodyEmail {get; set;}     
    public Decimal scoreValue {get; set;} 
      
    public void closePopup(){        
        displayPopup = false; 
        theMsg = '';   
    }     
    public void showPopup() {        
        displayPopup = true; 
    }
    
    public void closePopupEmail(){        
        displayPopupEmail = false;
        theMsg = '';      
    }     
    public void showPopupEmail() {        
        displayPopupEmail = true;    
    }
    
    public List<SelectOption> getActivePoints(){
        List<SelectOption> userList = new List<SelectOption>();
        userList.add(new SelectOption('None','--None--'));
        for(EWS_Point_Table__c a : activitiesMap.values()){
            userList.add(new SelectOption(a.id,a.Name));
        }
        return userList;
    }
    public void pointSelected(){
        if(selectedPoint != 'None' && activitiesMap.containsKey(selectedPoint)){
            EWS_Point_Table__c e = activitiesMap.get(selectedPoint);
            activityToCreate.Type__c = e.Type__c;
            activityToCreate.Name = e.Sub_Driver__c;
            activityToCreate.Driver__c = e.Driver__c;
            activityToCreate.Account__c=Apexpages.currentPage().getParameters().get('Paramtervalue');  
            activityToCreate.Sub_Driver__c = e.Sub_Driver__c;
            activityToCreate.EWS_Point__c = selectedPoint;
            scoreValue = e.Points__c;
        }else if(selectedPoint == 'None'){
            scoreValue = null;
            activityToCreate=new Activities__c();    
            
        }
    }
    public void insertActivity(){
        if(selectedPoint == 'None'){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please Select the Driver first.'));
        }else{
        
            insert activityToCreate;
            theMsg = 'Activity Created Successfully.'; 
            displayPopup = false;
            selectedPoint='None';
            activityToCreate=new Activities__c();
            scoreValue = null;  
        }
    }
    public void sendFeedBack(){
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setTargetObjectId(Label.JarniganId);
        mail.setSubject(subjectEmail);
        mail.saveAsActivity = false;
        mail.setHtmlBody(bodyEmail);               
        if(!Test.isRunningTest()) Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 
        theMsg = 'Email Sent Successfully.'; 
        displayPopupEmail = false;
        subjectEmail='';
        bodyEmail='';
        
    }
    
    public void accAction(){
        String accId = Apexpages.currentPage().getParameters().get('Paramtervalue');
        AggregateResult a = [SELECT COUNT(Id) countExp FROM Case WHERE AccountId =: accId AND Category__c != null AND RecordTypeId = '01250000000UJwx'  AND (CreatedDate = LAST_N_DAYS:91 OR CreatedDate = TODAY )];
        totalCases = (Integer)a.get('countExp');
        activitiesMap = new Map<Id,EWS_Point_Table__c>([SELECT Id,Name,Driver__c,Sub_Driver__c,Type__c,Points__c FROM EWS_Point_Table__c WHERE Activate__c = TRUE ORDER BY CreatedDate DESC]);
        acc = [SELECT Id,Name,Gainsight_Total_Known_Lead_Count__c,Acct_Renewal_Date__c,CAM_Owner__r.Name, ARR_from_Gainsight__c, Temperature__c, (SELECT Id,Type,AssignedSupportPOC__r.Name,Poc_Type__c FROM Entitlements  WHERE Type != null OR AssignedSupportPOC__c != null  ORDER BY CreatedDate DESC),(SELECT createddate,newvalue from Histories where field = 'Type' ORDER BY CreatedDate DESC LIMIT 1),(SELECT id from Critical_Account_Status__r where status__c = 'Open' limit 1),(SELECT Id,Accounting_Renewal_Date__c FROM Assets WHERE Accounting_Renewal_Date__c  != null ORDER BY Accounting_Renewal_Date__c DESC LIMIT 1) Name FROM Account WHERE Id =: accId];
        for(RedCAP__c red :acc.Critical_Account_Status__r){
            if(red.Id != null) redCapId = red.Id;            
        }
        for(AccountHistory his : acc.Histories){
            if(his.newvalue == 'Customer'){
                datetime dt = his.createddate;
                customerSince = dt.format('dd/MM/yyyy');
            }
        }
        arrAcc = acc.ARR_from_Gainsight__c;
        temperature = acc.Temperature__c;
        cam = acc.CAM_Owner__r.Name;
        knownLeadCount = acc.Gainsight_Total_Known_Lead_Count__c;
        Map<String,Integer> entLevelMap = new Map<String,Integer>();
        Integer level = 1;
        for (Schema.PicklistEntry f : Entitlement.Type.getDescribe().getPicklistValues()){
            entLevelMap.put(f.getValue(),level);
            level++;
        }
        Integer highLevel = 0;
        for(Entitlement e : acc.Entitlements){
            if(entLevelMap.get(e.Type) > highLevel){
                highLevel = entLevelMap.get(e.Type);
                entLevel = e.Type;
            }
            if(highLevel == entLevelMap.size()) break;
        }
        
        for(Entitlement e : acc.Entitlements){
            if(String.isNotBlank(e.AssignedSupportPOC__r.Name)){
                nse = e.AssignedSupportPOC__r.Name;
                nseIden = e.Poc_Type__c;
            }
            if(String.isnotBlank(nse)) break;
        }
        if(highLevel == 0) entLevel = 'None';
        renewalDate = String.valueOf(acc.Acct_Renewal_Date__c);
        
        for(Report r : [SELECT Id, DeveloperName, Name FROM Report WHERE DeveloperName IN ('X1_Summarized_by_Team_EWS','X2_Summarized_by_Team_EWS','X3_Summarized_by_Driver_EWS','X4_Last_3_Week_Cases_EWS','X5_All_Activities_EWS') ORDER BY Name ASC]){
            if(r.DeveloperName == 'X2_Summarized_by_Team_EWS') report2 = r.Id;
            else if(r.DeveloperName == 'X1_Summarized_by_Team_EWS') report1 = r.Id;
            else if(r.DeveloperName == 'X3_Summarized_by_Driver_EWS') report3 = r.Id;
            else if(r.DeveloperName == 'X4_Last_3_Week_Cases_EWS') report4 = r.Id;
            else if(r.DeveloperName == 'X5_All_Activities_EWS') report5 = r.Id;
        } 
       
        Date todayDate = Date.today();
        Date week3PastDate = Date.today().addDays(-21);
        Date month6PastDate = Date.today().addMonths(-6);        
        
        Week3EndFilter = week3PastDate.month()+'/'+week3PastDate.day()+'/'+week3PastDate.year();
        week3StartFilter = todayDate.month()+'/'+todayDate.day()+'/'+todayDate.year();
        
        month6StartFilter = week3StartFilter;
        month6EndFilter = month6PastDate.month()+'/'+month6PastDate.day()+'/'+month6PastDate.year();
        
        for(AggregateResult r : [SELECT SUM(sessioncount__c) sessioncount,SUM(emailsentcount__c) emailsentcount,SUM(changedatavaluecount__c) changedatavaluecount, JBCXM__Account__c accIds FROM JBCXM__UsageData__c WHERE JBCXM__Account__c =: accId AND CreatedDate = LAST_N_DAYS:7 GROUP BY JBCXM__Account__c]){
            sessioncount = (Decimal)r.get('sessioncount');
            emailsentcount = (Decimal)r.get('emailsentcount');
            changedatavaluecount = (Decimal)r.get('changedatavaluecount');
        }
    }
    
    public static List<EWSDashboardController> getScoreTypeData(){
        theTotalScore = 0;
        Map<String,EWSDashboardController> data = new Map<String,EWSDashboardController>();
        List<EWSDashboardController> finalData = new List<EWSDashboardController>();
        for(AggregateResult a : [SELECT SUM(Score__c) theSum, Type__c theType FROM Activities__c WHERE Account__c =: Apexpages.currentPage().getParameters().get('Paramtervalue') AND (CreatedDate = LAST_N_DAYS:91 OR CreatedDate = TODAY ) GROUP BY Type__c ORDER BY SUM(Score__c) DESC]){
            Decimal sum = (Decimal)a.get('theSum');
            String type = (String)a.get('theType');
            EWSDashboardController temp = new EWSDashboardController();
            
            temp.theType = type;
            temp.theTypeScore = sum;
            theTotalScore += temp.theTypeScore;
            data.put(temp.theType,temp);
        }
        EWSDashboardController ProductScore = new EWSDashboardController();
        for (Schema.PicklistEntry f : Activities__c.Type__c.getDescribe().getPicklistValues()){
            EWSDashboardController temp = new EWSDashboardController();
            if(!data.containsKey(f.getValue())){
                temp.theType = f.getValue();
                temp.theTypeScore = 0;                
            }else{
                temp = data.get(f.getValue());
            }
            if(temp.theType != 'Product') finalData.add(temp);
            else if(temp.theType == 'Product') ProductScore = temp;
            
        }
        finalData.add(ProductScore);
        return finalData;
    }
    
    public static List<EWSDashboardController> getRecentThreshold(){
        List<EWSDashboardController> data = new List<EWSDashboardController>();
        EWSDashboardController temp = new EWSDashboardController();
        temp.actItem = 'No Action Item';
        temp.outReachValue = '';
        for(Threshhold_Milestone__c t : [SELECT Id,Action_Item__c,Current_Action_Owner__c,Status__c,Threshold_value__c,LastModifiedDate FROM Threshhold_Milestone__c WHERE Account__c =:Apexpages.currentPage().getParameters().get('Paramtervalue') AND Status__c != 'Closed' ORDER BY CreatedDate DESC LIMIT 1]){
            temp.actItem = t.Action_Item__c;
            temp.outReachValue = t.LastModifiedDate.month()+'/'+t.LastModifiedDate.day()+'/'+t.LastModifiedDate.year();
        }
        data.add(temp);
        return data;
    }
    
    public static List<EWSDashboardController> getSplitTeamData(){
        List<EWSDashboardController> data = new List<EWSDashboardController>();
        Map<String,Map<String,Decimal>> splitData = new Map<String,Map<String,Decimal>>();
        for(AggregateResult a : [SELECT SUM(Score__c) theSum, Type__c theType, Sub_Driver__c subDriver FROM Activities__c WHERE Account__c =: Apexpages.currentPage().getParameters().get('Paramtervalue') AND (CreatedDate = LAST_N_DAYS:91 OR CreatedDate = TODAY) GROUP BY Type__c,Sub_Driver__c ORDER BY SUM(Score__c) DESC]){          
            String type = (String)a.get('theType');
            Decimal sum = (Decimal)a.get('theSum');
            String subDriver = (String)a.get('subDriver');
            Map<String,Decimal> temp = new Map<String,Decimal>();
            if(splitData.containsKey(type)) temp = splitData.get(type);
            if(!temp.isEmpty() && temp.containsKey(subDriver)) sum += temp.get(subDriver);
            temp.put(subDriver,sum);
            splitData.put(type,temp);       
        }
        
        if(!splitData.isEmpty()){
            for(String s : splitData.keySet()){
                EWSDashboardController temp = new EWSDashboardController();
                temp.theType = s;
                List<EWSDashboardController> valuesList = new List<EWSDashboardController>();
                Map<String,Decimal> tempSet = splitData.get(s);
                for(String d : tempSet.keySet()){
                    EWSDashboardController tempDriver = new EWSDashboardController();
                    tempDriver.breakDownInnerKey = d;
                    tempDriver.theScore = tempSet.get(d);
                    valuesList.add(tempDriver);
                }
                temp.breakDownValues = valuesList; 
                data.add(temp);
            }
        }
        return data;
    }
    
    public static List<EWSDashboardController> getSplitDriverData(){
        List<EWSDashboardController> data = new List<EWSDashboardController>();
        String accId = Apexpages.currentPage().getParameters().get('Paramtervalue');
        Map<String,Map<String,Decimal>> splitData = new Map<String,Map<String,Decimal>>();
        Map<String,Decimal> driverData = new Map<String,Decimal>();
        for(AggregateResult a : [SELECT SUM(Score__c) theSum, Driver__c driver FROM Activities__c WHERE Account__c =: accId AND (CreatedDate = LAST_N_DAYS:91 OR CreatedDate = TODAY ) GROUP BY Driver__c ORDER BY SUM(Score__c) DESC]){
            String type = (String)a.get('driver');
            Decimal sum = (Decimal)a.get('theSum');
            driverData.put(type,sum);
        }
        for(AggregateResult a : [SELECT SUM(Score__c) theSum, Driver__c driver, Sub_Driver__c subDriver FROM Activities__c WHERE Account__c =: accId AND (CreatedDate = LAST_N_DAYS:91 OR CreatedDate = TODAY ) GROUP BY Driver__c,Sub_Driver__c ORDER BY SUM(Score__c) DESC]){          
            String type = (String)a.get('driver');
            Decimal sum = (Decimal)a.get('theSum');
            String subDriver = (String)a.get('subDriver');
            Map<String,Decimal> temp = new Map<String,Decimal>();
            if(splitData.containsKey(type)) temp = splitData.get(type);
            if(!temp.isEmpty() && temp.containsKey(subDriver)) sum += temp.get(subDriver);
            temp.put(subDriver,sum);
            splitData.put(type,temp);       
        }
        
        if(!driverData.isEmpty() && !splitData.isEmpty()){
            for(String s : driverData.keySet()){
                EWSDashboardController temp = new EWSDashboardController();
                temp.theType = s;
                List<EWSDashboardController> valuesList = new List<EWSDashboardController>();
                Map<String, Decimal> tempSet = splitData.get(s);
                for(String d : tempSet.keySet()){
                    EWSDashboardController tempDriver = new EWSDashboardController();
                    tempDriver.breakDownInnerKey = d;
                    tempDriver.theScore = tempSet.get(d);
                    valuesList.add(tempDriver);
                }
                temp.breakDownValues = valuesList; 
                data.add(temp);
            }
        }
        return data;
    }
    
    public static List<EWSDashboardController> getScoreTrentsData(){
        List<EWSDashboardController> data = new List<EWSDashboardController>();
        Map<Integer,Decimal> temp = new Map<Integer,Decimal>();
        
        Decimal thresholdScore1 = 0;
        Decimal thresholdScore2 = 0;
        Decimal thresholdScore3 = 0;
        try{thresholdScore1 = Decimal.valueOf(Label.Threshold_Score_Value_For_EWS);}catch(exception e){thresholdScore1 = 100;}
        try{thresholdScore2 = Decimal.valueOf(Label.Threshold_Score_Value_2_For_EWS);}catch(exception e){thresholdScore2 = 150;}
        try{thresholdScore3 = Decimal.valueOf(Label.Threshold_Score_Value_3_For_EWS);}catch(exception e){thresholdScore3 = 175;}
        
        long totalWeeks = 26;
        long dt2Long = DateTime.now().getTime();
        
        for(Activities__c a : [SELECT Name,Score__c,CreatedDate,Type__c FROM Activities__c WHERE Account__c =: Apexpages.currentPage().getParameters().get('Paramtervalue') AND (CreatedDate = LAST_N_DAYS:273 OR CreatedDate = TODAY ) ORDER BY CreatedDate ASC, Score__c asc]){
            Integer weekNo = (Integer)(totalWeeks - (dt2Long - a.CreatedDate.getTime())/(1000*60*60*24*7));
            Decimal score = a.Score__c;
            if(temp.containsKey(weekNo)) score += temp.get(weekNo);
            temp.put(weekNo,score);  
        }
        DateTime initialDate = Date.today().addDays(-273);
        for(Integer i=1; i <= totalWeeks; i++){
            EWSDashboardController tempData = new EWSDashboardController();
            tempData.th1 = thresholdScore1;
            tempData.th2 = thresholdScore2;
            tempData.th3 = thresholdScore3;
            tempData.theWeek = i+' week';            
            tempData.theWeekRange = initialDate.format('dd/MM');
            initialDate = initialDate.addDays(7);
            tempData.theWeekRange += '-'+initialDate.format('dd/MM');
            tempData.theScore = 0;
            for(Integer j=i-13;j<i;j++){
                if(temp.containskey(j)) tempData.theScore += temp.get(j);
            } 
            data.add(tempData);  
        }
        system.debug('#####data '+data);
        return data;
    }
    
    public static List<EWSDashboardController> getWeek26CategoryCases(){
        List<EWSDashboardController> data = new List<EWSDashboardController>();
        for(AggregateResult a : [SELECT COUNT(Id) theSum, Problem_Type__c category FROM Case WHERE AccountId =: Apexpages.currentPage().getParameters().get('Paramtervalue') AND Problem_Type__c != null AND RecordTypeId = '01250000000UJwx'  AND (CreatedDate = LAST_N_DAYS:91 OR CreatedDate = TODAY ) GROUP BY Problem_Type__c]){
            EWSDashboardController temp = new EWSDashboardController();
            temp.theType = (String)a.get('category');
            temp.theTypeScore = (Decimal)a.get('theSum');
            data.add(temp);
        }
        return data;
    }    
    
    public static List<Case> getJiraCases(){
        return [SELECT Id,CaseNumber, JIRA_Num__c,subject, Description FROM Case WHERE AccountId =: Apexpages.currentPage().getParameters().get('Paramtervalue') AND RecordTypeId = '01250000000UJwx' AND JIRA_Num__c != NULL ORDER BY CreatedDate DESC LIMIT 2];        
    }
    
    public static List<Case> getWeekthreeCases(){
        return [SELECT Id,Status,CaseNumber, JIRA_Num__c,subject, Description FROM Case WHERE AccountId =: Apexpages.currentPage().getParameters().get('Paramtervalue') AND CreatedDate = LAST_N_DAYS:21  AND RecordTypeId = '01250000000UJwx' ORDER BY CreatedDate DESC LIMIT 4];        
    }  
    
}