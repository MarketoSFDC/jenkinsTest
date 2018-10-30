public class AddSupportAssistController {
    public list<skill__c> SkillList{get;set;}
    public case OLdCase;
    public case UpdatedCase;
    public AddSupportAssistController(ApexPages.StandardController controller) {
        UpdatedCase = (case) controller.getRecord(); 
        OLdCase = [select id, status, Support_Assist__c, Support_Assist_Due_date_time__c,Problem_type__c, category__c, sub_category__c  from case where id =: ApexPages.currentPage().getParameters().get('id')];
        SkillList = [select id, SME__c, Category__c, User_Skill_Level__c, User__r.name, user__r.Division, user__r.Country, user__r.City from skill__c where Category__c =: OLdCase.Category__c and User_Skill_Level__c !='null' and User_Skill_Level__c !='Unskilled' and Approval_status__c = 'Approved' ORDER BY User_Skill_Level__c DESC limit 50];  
        system.debug('conttructor called===>'+OLdCase); 
        system.debug('conttructor called===>'+UpdatedCase);
    }
    
    public PageReference SupportAssistOperation() {
        system.debug('conttructor called===>'+UpdatedCase);
        system.debug(  UpdatedCase.Support_Assist__c + ' ' + UpdatedCase.Support_Assist_Due_date_time__c);
        if(OLdCase.Problem_type__c == null || OLdCase.category__c == null || OLdCase.sub_category__c == null ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Required Fields Missing: Please go back and fill Problem type, Category and Sub-Category'));            
            return null;
        } 
        if(UpdatedCase.Support_Assist__c == null ){
            ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,'Please enter Support Assist User'));            
            return null;
        }                
        if(OldCase.Support_Assist__c != UpdatedCase.Support_Assist__c || OLdCase.Support_Assist_Due_date_time__c != UpdatedCase.Support_Assist_Due_date_time__c) {          
            UpdatedCase.status = 'Pending Support Assist';
            UpdatedCase.Support_Assist__c = UpdatedCase.Support_Assist__c;
            UpdatedCase.Support_Assist_Due_date_time__c = UpdatedCase.Support_Assist_Due_date_time__c;            
            update UpdatedCase;             
            //Add support assist record in case related list.            
            Support_Assist__c SuppAssist = new Support_Assist__c();                
            SuppAssist.Case__c = UpdatedCase.id;                 
            SuppAssist.Start_Date__c = system.now();                 
            if(UpdatedCase.Support_Assist_Due_date_time__c!=null)SuppAssist.Target_Due_Date__c = UpdatedCase.Support_Assist_Due_date_time__c;
            SuppAssist.Support_Assist_Owner__c = UpdatedCase.Support_Assist__c;          
            insert SuppAssist;            
        } 
        PageReference pref = new ApexPages.StandardController(UpdatedCase).view();
        return pref;
    }
     
}