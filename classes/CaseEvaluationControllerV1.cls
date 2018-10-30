public Class CaseEvaluationControllerV1{
    public string onDemandCaseNumber  {get;set;}
    public String nameOfSuppEng{get;set;}
    public List<Case> onDemandCase {get;set;}
    public List<CaseComment> caseComm {get;set;}
    public Id idOfSuppEng{get;set;}    
    public Boolean isSearchCompleted {get;set;}
    public Boolean statusIsChanged {get;set;}
    public Boolean isDisplayButton {get;set;}
    public Boolean isDefault {get;set;}
    public Id managerActivityLog {get;set;}
    public Boolean casesExistForThisMonth {get;set;}
    public Boolean casesExistForPreviousMonth {get;set;}
    public Map<String, Map<String, List<wrapperClass>>> mapOfCasesForPreviousMonth {get;set;}
    public Map<String, Map<String, List<wrapperClass>>> mapOfCasesForCurrentMonth {get;set;}
    public Map<Integer,String> sortedDateMap {get;set;}
    public Map<Integer,String> sortedFilterMap {get;set;}
    public Map<String,String> sortedFilterMap1 {get;set;}
     
    public Map<String, List<wrapperClass>> mapOfCasesForCurrentMonthNew {get;set;}
    public Map<String, List<wrapperClass>> mapOfCasesForPreviousMonthNew {get;set;}
    
    public Boolean showHeader{get;set;}
    public Case parentCase;
    public Support_Score_Card__c scoreCard{get;set;} 
    public CaseEvaluationControllerV1(ApexPages.StandardController controller) {
        isDisplayButton = false;
        caseComm = new List<CaseComment>();
        this.parentCase = (Case)controller.getRecord();
        caseComm  = [select id,parentid,createddate,CreatedById,IsPublished,CommentBody from casecomment where parentid =:parentCase.id order by createddate desc];
        try {
            this.scoreCard = [Select Id,Case__c, Initial_Response__c, Understanding__c, Research__c, Updates__c, Phone_Usage__c, Communication__c, Escalation__c, Coding__c, Closing__c, Recommendation__c, Manger_Activity_Log__c,TSE_ManagerDetail__r.TSE__c, TSE_ManagerDetail__r.Support_Manager__c, Evaluated_By__c, Status__c,Applicable_Record_Count__c,Applicable_Postiive_Score__c,Applicable_Negative_Score__c,Applicable_Score_Percent__c   from Support_Score_Card__c where Case__c =: this.parentCase.Id Limit 1];
           if(ApexPages.currentPage().getParameters().get('userId') != null && ApexPages.currentPage().getParameters().get('userId') != ''){
                idOfSuppEng = ApexPages.currentPage().getParameters().get('userId');
            }
            if(ApexPages.currentPage().getParameters().get('activityLogId') != null && ApexPages.currentPage().getParameters().get('activityLogId') !=''){
               managerActivityLog = ApexPages.currentPage().getParameters().get('activityLogId');
            }    
        }
        catch(Exception Ex){
            if(ApexPages.currentPage().getParameters().get('userId') != null && ApexPages.currentPage().getParameters().get('userId') != ''){
                idOfSuppEng = ApexPages.currentPage().getParameters().get('userId');
                system.debug('@@@@userId ' +idOfSuppEng);
                isDisplayButton = true;
            }
            if(ApexPages.currentPage().getParameters().get('activityLogId') != null && ApexPages.currentPage().getParameters().get('activityLogId') !=''){
               managerActivityLog = ApexPages.currentPage().getParameters().get('activityLogId');
               system.debug('@@@@managerActivityLog ' +managerActivityLog);
               isDisplayButton = true;
            }      
            else{
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Page URL is Incorrect')); 
                 isDisplayButton = false;
            }
            /*if(!isDisplayButton){
                 ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Parent record not found.'));   
            }*/      
        }      
    }
    
    public pageReference saveScoreCard() {      
        List<Support_Score_Card__c> supScore= [Select Id from Support_Score_Card__c where Case__c = :this.parentCase.Id];
        try {
            this.scoreCard.Status__c = 'Completed';
            this.scoreCard.Final_Case_Owner__c = parentCase.OwnerId;
            this.scoreCard.Evaluated_By__c = UserInfo.getUserId();
            update this.scoreCard; 
            Store_Cases_For_Month__c scfm= [Select id, Evaluation_Status__c  from Store_Cases_For_Month__c where Case__c = :this.parentCase.Id] ;
            scfm.Evaluation_Status__c = 'Completed';
            update scfm;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Review form has been saved successfully. You can check the form detail<a href="'+system.URL.getSalesforceBaseUrl().toExternalForm()+ '/' +supScore[0].Id+'">here</a>'));
        } catch(Exception Ex) {
            this.scoreCard = null;
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.ERROR,'Operation Failed. Please try again.'));            
        }
        return null;    
    }
    
    public pageReference startEvaluation() {               
        List<Support_Score_Card__c> tmpSSC = [Select Id,Case__c, Initial_Response__c, Understanding__c, Research__c, Updates__c, Phone_Usage__c, Communication__c, Escalation__c, Coding__c, Closing__c, Recommendation__c, Manger_Activity_Log__c,TSE_ManagerDetail__r.TSE__c, TSE_ManagerDetail__r.Support_Manager__c, Evaluated_By__c, Status__c,Applicable_Record_Count__c,Applicable_Postiive_Score__c,Applicable_Negative_Score__c,Applicable_Score_Percent__c   from Support_Score_Card__c where Case__c =: this.parentCase.Id Limit 1]; 
        if(tmpSSC.size() == 0 || Test.isRunningTest()) {
            Id tmpId = this.parentCase.OwnerId;
            User tmpUser = [SELECT Id, ManagerId from User where id = :ApexPages.currentPage().getParameters().get('userId')];                
            TSE_ManagerDetail__c scoreCardT = new TSE_ManagerDetail__c();
            scoreCardT.Case__c = this.parentCase.Id;
            scoreCardT.Support_Manager__c = tmpUser.ManagerId;
            scoreCardT.TSE__c = idOfSuppEng ;
            insert scoreCardT;                       
            Support_Score_Card__c scoreCardS = new Support_Score_Card__c();
            scoreCardS.TSE_ManagerDetail__c = scoreCardT.id;
            scoreCardS.Case__c = this.parentCase.Id;
            scoreCardS.Status__c = 'In Progress';
            scoreCardS.Manger_Activity_Log__c = managerActivityLog ;
            insert scoreCardS;                                         
        }
        tmpSSC = [Select Id,Case__c, Initial_Response__c, Understanding__c, Research__c, Updates__c, Phone_Usage__c, Communication__c, Escalation__c, Coding__c, Closing__c, Recommendation__c, Manger_Activity_Log__c,TSE_ManagerDetail__r.TSE__c, TSE_ManagerDetail__r.Support_Manager__c, Evaluated_By__c, Status__c,Applicable_Record_Count__c,Applicable_Postiive_Score__c,Applicable_Negative_Score__c,Applicable_Score_Percent__c   from Support_Score_Card__c where Case__c =: this.parentCase.Id Limit 1]; 
        if(tmpSSC.size() > 0) {
            this.scoreCard = tmpSSC[0];
        }                                       
        return null;    
    }
    
    public CaseEvaluationControllerV1(){
        isSearchCompleted = false;
        statusIsChanged = false;
        isDefault = false;
        showHeader = ApexPages.currentPage().getParameters().get('showHeader')=='true'?True:false;   
        If(ApexPages.currentPage().getParameters().get('userName') != null){
            nameOfSuppEng = ApexPages.currentPage().getParameters().get('userName');
        }
        If(ApexPages.currentPage().getParameters().get('activityLogId') != null){
            managerActivityLog = ApexPages.currentPage().getParameters().get('activityLogId');
        }
        If(ApexPages.currentPage().getParameters().get('userId') != null){
            idOfSuppEng = ApexPages.currentPage().getParameters().get('userId');
        }
        getCaseListBasedOnFilterCriteria();
    }   
    
    public pageReference backToTSESelect(){
        String baseUrl = URL.getSalesforceBaseUrl().toExternalForm()+'/apex/GetUsersBasedOnRoleHeirarchy';        
        if(showHeader){ baseUrl += '?sfdc.tabName=01r50000000M1ou';}
        PageReference pageRef = new PageReference(baseUrl);    
        return pageRef; 
    }
    
    public string scoreCardId{get;set;}
    
    public void getCaseListBasedOnFilterCriteria(){
        mapOfCasesForPreviousMonth  = new Map<String, Map<String, List<wrapperClass>>>();
        mapOfCasesForCurrentMonth   = new Map<String, Map<String, List<wrapperClass>>>();
        mapOfCasesForPreviousMonthNew = new Map<String, List<wrapperClass>> ();
        mapOfCasesForCurrentMonthNew  = new Map<String, List<wrapperClass>> ();
        
        
        sortedDateMap = new Map<Integer,String>();
        Integer i = 1;
        
        Set<String> monthDateSet = new Set<String>();
        
        sortedFilterMap = new Map<Integer,String>();
        sortedFilterMap.put(1,'Engineering Escalated');
        sortedFilterMap.put(2,'Priority P1');
        sortedFilterMap.put(3,'Priority P2');
        sortedFilterMap.put(4,'Aged');
        sortedFilterMap.put(5,'Closed');
        sortedFilterMap.put(6,'On Demand');
        
        sortedFilterMap1 = new Map<String,String>();
        sortedFilterMap1.put('Engineering Escalated','1');
        sortedFilterMap1.put('Priority P1','2');
        sortedFilterMap1.put('Priority P2','3');
        sortedFilterMap1.put('Aged','4');
        sortedFilterMap1.put('Closed','5');
        sortedFilterMap1.put('On Demand','6');
       
        for(Store_Cases_For_Month__c tempObject : [Select Id, Evaluation_Ended__c,Evaluation_Status__c, Case_For_Month__c,case_from_previous_month__c, Cases_From_Previous_Month__c, Case__r.AgeInDays__c, Case__r.Priority, Case__c, Case__r.CaseNumber, Filter_Criteria__c, Case__r.Evaluation_Status__c From Store_Cases_For_Month__c where Manger_Activity_Log__c =: managerActivityLog ORDER BY Evaluation_Ended__c DESC]){
            If(tempObject.case_from_previous_month__c == True || Test.isRunningTest()){  
                If(tempObject.Evaluation_Status__c == 'Evaluate'){ 
                    if(mapOfCasesForPreviousMonth.containsKey(tempObject.Case_For_Month__c)) { // If Month exists in Master map
                       if (mapOfCasesForPreviousMonth.get(tempObject.Case_For_Month__c).containsKey(sortedFilterMap1.get(tempObject.Filter_Criteria__c))) { // If Filter criteria exists in this month Map
                           mapOfCasesForPreviousMonth.get(tempObject.Case_For_Month__c).get(sortedFilterMap1.get(tempObject.Filter_Criteria__c)).add(new wrapperClass(tempObject));
                       } else {
                           List<wrapperClass> tempList = new List<wrapperClass>();
                           tempList.add(new wrapperClass(tempObject));
                           mapOfCasesForPreviousMonth.get(tempObject.Case_For_Month__c).put(sortedFilterMap1.get(tempObject.Filter_Criteria__c), tempList);
                       }               
                    } else {
                       List<WrapperClass> caseObjectList = new List<WrapperClass>();
                       caseObjectList.add(new wrapperClass(tempObject));
                       Map<String, List<WrapperClass>> filterCriteriaToCaseListMap = new Map<String, List<WrapperClass>>();
                       filterCriteriaToCaseListMap.put(sortedFilterMap1.get(tempObject.Filter_Criteria__c), caseObjectList);
                       mapOfCasesForPreviousMonth.put(tempObject.Case_For_Month__c, filterCriteriaToCaseListMap);
                    }
                    If(!monthDateSet.Contains(tempObject.Case_For_Month__c)){
                        sortedDateMap.put(i, tempObject.Case_For_Month__c);
                        monthDateSet.add(tempObject.Case_For_Month__c);
                        i++;
                    }
                }
            }else{
                if(mapOfCasesForCurrentMonth.containsKey(tempObject.Case_For_Month__c)) { // If Month exists in Master map
                   if (mapOfCasesForCurrentMonth.get(tempObject.Case_For_Month__c).containsKey(sortedFilterMap1.get(tempObject.Filter_Criteria__c))) { // If Filter criteria exists in this month Map
                       mapOfCasesForCurrentMonth.get(tempObject.Case_For_Month__c).get(sortedFilterMap1.get(tempObject.Filter_Criteria__c)).add(new wrapperClass(tempObject));
                   } else {
                       List<wrapperClass> tempList = new List<wrapperClass>();
                       tempList.add(new wrapperClass(tempObject));
                       mapOfCasesForCurrentMonth.get(tempObject.Case_For_Month__c).put(sortedFilterMap1.get(tempObject.Filter_Criteria__c), tempList);
                   }               
                } else {
                   List<WrapperClass> caseObjectList = new List<WrapperClass>();
                   caseObjectList.add(new wrapperClass(tempObject));
                   Map<String, List<WrapperClass>> filterCriteriaToCaseListMap = new Map<String, List<WrapperClass>>();
                   filterCriteriaToCaseListMap.put(sortedFilterMap1.get(tempObject.Filter_Criteria__c), caseObjectList);
                   mapOfCasesForCurrentMonth.put(tempObject.Case_For_Month__c, filterCriteriaToCaseListMap);
                }
            }
        }
        casesExistForThisMonth     = mapOfCasesForCurrentMonth.Size()  > 0 ? True : False;
        casesExistForPreviousMonth = mapOfCasesForPreviousMonth.Size() > 0 ? True : False;
        
        
        //for(String keyStr :  mapOfCasesForPreviousMonth.keySet()) {
        for(Integer keyStr :  sortedDateMap.keySet()) {
            System.debug('keyStr ' + keyStr);
            System.debug(''+sortedDateMap.get(keyStr));            
            for(String keyStr1 : mapOfCasesForPreviousMonth.get(sortedDateMap.get(keyStr)).keySet()) {                
                if(mapOfCasesForPreviousMonth.get(sortedDateMap.get(keyStr)).get(KeyStr1) != Null) {
                    if(!mapOfCasesForPreviousMonthNew.containsKey(sortedDateMap.get(keyStr))) {
                        mapOfCasesForPreviousMonthNew.put(sortedDateMap.get(keyStr),new List<wrapperClass>());
                    }
                    //System.Debug(' <==> '+mapOfCasesForPreviousMonth.get(sortedDateMap.get(keyStr)));            
                    mapOfCasesForPreviousMonthNew.get(sortedDateMap.get(keyStr)).AddAll(mapOfCasesForPreviousMonth.get(sortedDateMap.get(keyStr)).get(KeyStr1));
                }
            }            
        }
        system.debug(mapOfCasesForCurrentMonth);               
        for(String keyStr : mapOfCasesForCurrentMonth.keySet()) {
            System.debug('keyStr ' + keyStr);
            if(!mapOfCasesForCurrentMonthNew.containsKey(keyStr)) {
                mapOfCasesForCurrentMonthNew.put(keyStr,new List<wrapperClass>());
            }
            for(String keyStr1 : mapOfCasesForCurrentMonth.get(keyStr).keySet()) {                
                System.debug('keyStr1 ' + keyStr1);
                if(mapOfCasesForCurrentMonth.get(keyStr).get(KeyStr1) != Null) {                
                    System.Debug(' <==> '+mapOfCasesForCurrentMonth.get(keyStr).get(KeyStr1));            
                    mapOfCasesForCurrentMonthNew.get(keyStr).AddAll(mapOfCasesForCurrentMonth.get(keyStr).get(KeyStr1));
                }
            } 
        }
        /*
        for(String keyStr : mapOfCasesForCurrentMonth.keySet()) {     
            System.debug('keyStr ' + keyStr);            
            if(mapOfCasesForCurrentMonth.get(keyStr) != Null) {
                if(!mapOfCasesForCurrentMonthNew.containsKey(keyStr)) {
                    mapOfCasesForCurrentMonthNew.put(keyStr,new List<wrapperClass>());
                }
                System.Debug(' <==> '+mapOfCasesForCurrentMonth.get(keyStr));            
                //mapOfCasesForCurrentMonthNew.get(keyStr).AddAll(mapOfCasesForCurrentMonth.get(keyStr));
            }
        }*/
        
        
        System.debug('' +mapOfCasesForCurrentMonthNew); 
        System.debug('' +mapOfCasesForPreviousMonthNew);
    }
    
    public Class wrapperClass{
        public String CasePriority       {get;set;}
        public String CaseId             {get;set;}
        public String CaseNumber         {get;set;}
        public Decimal CaseAge           {get;set;}
        public String EvaluationStatus   {get;set;}
        public String SupportScoreCardId {get;set;}
        public String caseFromMonth      {get;set;}
        public wrapperClass(Store_Cases_For_Month__c tempObject){
           CasePriority       = tempObject.Case__r.Priority;
           CaseId             = tempObject.Case__c;
           CaseNumber         = tempObject.Case__r.CaseNumber;
           CaseAge            = tempObject.Case__r.AgeInDays__c;
           EvaluationStatus   = tempObject.Case__r.Evaluation_Status__c == Null? tempObject.Evaluation_Status__c: tempObject.Case__r.Evaluation_Status__c;
           SupportScoreCardId = tempObject.Id;
           caseFromMonth      = tempObject.Case_For_Month__c;
        }
    }
    
    public void showOnDemandCase(){
        String caseIdOnDemand = ApexPages.currentPage().getParameters().get('caseIdOnDemand');
        if(caseIdOnDemand != ''){
            isSearchCompleted = true;
            onDemandCase = new List<Case>();
            onDemandCase =  [Select CaseNumber, Id, AgeInDays__c, Evaluation_Status__c ,ClosedDate, Priority from Case where Id=: caseIdOnDemand ] ;
        }
    }
}