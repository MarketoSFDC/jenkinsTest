public Class TSECaseEvaluationFormController{
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
    public Boolean showHeader{get;set;}
    public Case parentCase;
    public TSE_Score_Card__c scoreCard{get;set;} 
    public TSECaseEvaluationFormController(ApexPages.StandardController controller) {
        isDisplayButton = false;
        caseComm = new List<CaseComment>();
        this.parentCase = (Case)controller.getRecord();
        caseComm  = [select id,parentid,createddate,CreatedById,IsPublished,CommentBody from casecomment where parentid =:parentCase.id order by createddate desc];
        try {
            this.scoreCard = [Select Id,Case__c, Initial_Response__c, Understanding__c, Research__c, Updates__c, Phone_Usage__c, Communication__c, Escalation__c, Coding__c, Closing__c, Recommendation__c,TSE_ManagerDetail__r.TSE__c, TSE_ManagerDetail__r.Support_Manager__c, Evaluated_By__c, Status__c,Applicable_Record_Count__c,Applicable_Postiive_Score__c,Applicable_Negative_Score__c,Applicable_Score_Percent__c   from TSE_Score_Card__c where Case__c =: this.parentCase.Id Limit 1];
           if(ApexPages.currentPage().getParameters().get('userId') != null && ApexPages.currentPage().getParameters().get('userId') != ''){
                idOfSuppEng = ApexPages.currentPage().getParameters().get('userId');
            }
            if(ApexPages.currentPage().getParameters().get('activityLogId') != null && ApexPages.currentPage().getParameters().get('activityLogId') !=''){
               managerActivityLog = ApexPages.currentPage().getParameters().get('activityLogId');
            }    
        }
        catch(Exception Ex){
            if(ApexPages.currentPage().getParameters().get('userId') != null && ApexPages.currentPage().getParameters().get('userId') != ''){idOfSuppEng = ApexPages.currentPage().getParameters().get('userId');isDisplayButton = true;}
            if(ApexPages.currentPage().getParameters().get('activityLogId') != null && ApexPages.currentPage().getParameters().get('activityLogId') !=''){managerActivityLog = ApexPages.currentPage().getParameters().get('activityLogId');isDisplayButton = true;}      
            else{ApexPages.addmessage(new ApexPages.message(ApexPages.severity.FATAL,'Page URL is Incorrect')); isDisplayButton = false;}
        }     
    }
    
    public pageReference saveScoreCard() {      
        List<TSE_Score_Card__c> supScore= [Select Id from TSE_Score_Card__c where Case__c = :this.parentCase.Id];
        try {
            this.scoreCard.Status__c = 'Completed';
            this.scoreCard.Final_Case_Owner__c = parentCase.OwnerId;
            this.scoreCard.Evaluated_By__c = UserInfo.getUserId();
            update this.scoreCard; 
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.INFO,'Review form has been saved successfully. You can check the form detail<a href="'+system.URL.getSalesforceBaseUrl().toExternalForm()+ '/' +supScore[0].Id+'">here</a>'));
        } catch(Exception Ex) { this.scoreCard = null; ApexPages.addmessages(Ex); }
         
        return null;    
    }
    
    public pageReference startEvaluation() {               
        List<TSE_Score_Card__c> tmpSSC = [Select Id,Case__c, Initial_Response__c, Understanding__c, Research__c, Updates__c, Phone_Usage__c, Communication__c, Escalation__c, Coding__c, Closing__c, Recommendation__c,TSE_ManagerDetail__r.TSE__c, TSE_ManagerDetail__r.Support_Manager__c, Evaluated_By__c, Status__c,Applicable_Record_Count__c,Applicable_Postiive_Score__c,Applicable_Negative_Score__c,Applicable_Score_Percent__c   from TSE_Score_Card__c where Case__c =: this.parentCase.Id Limit 1]; 
        if(tmpSSC.size() == 0 || Test.isRunningTest()) {
            Id tmpId = this.parentCase.OwnerId;
            User tmpUser = [SELECT Id, ManagerId from User where id = :ApexPages.currentPage().getParameters().get('userId')];                
            TSE_ManagerDetail__c scoreCardT = new TSE_ManagerDetail__c();
            scoreCardT.Case__c = this.parentCase.Id;
            scoreCardT.Support_Manager__c = tmpUser.ManagerId;
            scoreCardT.TSE__c = idOfSuppEng ;
            insert scoreCardT;                       
            TSE_Score_Card__c scoreCardS = new TSE_Score_Card__c();
            scoreCardS.TSE_ManagerDetail__c = scoreCardT.id;
            scoreCardS.Case__c = this.parentCase.Id;
            scoreCardS.Status__c = 'In Progress';
            scoreCardS.Mentor_TSE_Table__c = managerActivityLog ;
            insert scoreCardS;                                         
        }
        tmpSSC = [Select Id,Case__c, Initial_Response__c, Understanding__c, Research__c, Updates__c, Phone_Usage__c, Communication__c, Escalation__c, Coding__c, Closing__c, Recommendation__c,TSE_ManagerDetail__r.TSE__c, TSE_ManagerDetail__r.Support_Manager__c, Evaluated_By__c, Status__c,Applicable_Record_Count__c,Applicable_Postiive_Score__c,Applicable_Negative_Score__c,Applicable_Score_Percent__c   from TSE_Score_Card__c where Case__c =: this.parentCase.Id Limit 1]; 
        if(tmpSSC.size() > 0) {
            this.scoreCard = tmpSSC[0];
        }                                       
        return null;    
    }
    /*
    public Class wrapperClass{
        public String CasePriority       {get;set;}
        public String CaseId             {get;set;}
        public String CaseNumber         {get;set;}
        public Decimal CaseAge           {get;set;}
        public String EvaluationStatus   {get;set;}
        public String SupportScoreCardId {get;set;}
        public String caseFromMonth      {get;set;}
        public wrapperClass(Store_Cases_By_Week__c tempObject){
           CasePriority       = tempObject.Case__r.Priority;
           CaseId             = tempObject.Case__c;
           CaseNumber         = tempObject.Case__r.CaseNumber;
           CaseAge            = tempObject.Case__r.AgeInDays__c;
           EvaluationStatus   = tempObject.Case__r.Evaluation_Status__c == Null? tempObject.Evaluation_Status__c: tempObject.Case__r.Evaluation_Status__c;
           SupportScoreCardId = tempObject.Id;
           caseFromMonth      = tempObject.Case_For_Month__c;
        }
    }    */
    
    
}