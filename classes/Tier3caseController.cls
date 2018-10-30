public class Tier3caseController{
    public Case c { get; set; }        
    public String selectedPriority { get; set; }
    public String t3Subject{ get; set; }
    public String t3BusImpact{ get; set; }
    public String t3Description{ get; set; }
    public String t3Steps{ get; set; }
    public String ownerName{ get; set; }
    public String t3Analysis{ get; set; }          
    public Case ca {get;set;}
    public string callfunc {get;set;}
    public Attachment attachment1 {
    get {
        if (attachment1 == null)
            attachment1 = new Attachment();
            return attachment1;
        }
    set;
    }
    public Attachment attachment2 {
    get {
        if (attachment2 == null)
            attachment2 = new Attachment();
            return attachment2;
        }
    set;
    }
    public Attachment attachment3 {
    get {
        if (attachment3 == null)
            attachment3 = new Attachment();
            return attachment3;
        }
    set;
    }       
    public Tier3caseController(ApexPages.StandardController controller) {
                     
        //this.ca = (Case)controller.getRecord(); 
        Id caseId= ApexPages.currentPage().getParameters().get('id');
        this.ca = [select ownerId,Problem_Type__c,JIRA_Num__c,Category__c,Sub_Category__c,Case_Issue__c,Case_Sub_Issue__c,Contact.Id,Parentid,Account.id,Account.Name,Contact.Name,origin,EntitlementId,AssetId,BusinessHoursId,Priority,Business_Impact__c,Description,Steps_to_Reproduce__c,Analysis_completed_so_far__c,(Select id,parentid from attachments) from case where id =: caseId];                      
        contactOnBehalf = this.ca.Contact.name;
        accOnBehalf = this.ca.account.name;
        targetIdAccount = this.ca.accountID;
        targetIdContact = this.ca.Contact.Id;
        selectedPriority = this.ca.priority;
        ownerName=this.ca.ownerId;
        EmailList = UserInfo.getUserEmail();       
    }  
    public String targetIdAccount{get;set;}
    public String targetIdContact{get;set;}            
    public boolean showCaseDetail{get;set;}
    public Case csDetail{get;set;}       
    public Case tier3Case{get;set;}
    public string contactOnBehalf{get;set;}
    public string accOnBehalf{get;set;}
    public string EmailList{get;set;}
    
    public PageReference populateTier3Section(){
        system.debug('populateTier3Section=======>>>>>');
        Case childCase = new Case();
        childCase.RecordtypeId = System.Label.tier3RecordTypeId;
        childCase.origin = 'Internal';
        childCase.Priority = selectedPriority;
        childCase.Business_Impact__c = t3BusImpact;
        childCase.Subject = t3Subject;
        childCase.Description = t3Description;
        childCase.Steps_to_Reproduce__c = t3Steps;
        childCase.Analysis_completed_so_far__c = t3Analysis;
        childCase.ParentId = ca.Id;
        childCase.EntitlementId= ca.EntitlementId;
        childCase.AssetId = ca.AssetID;
        childCase.BusinessHoursId = ca.BusinessHoursId;
        childCase.status = 'New';
        childCase.accountid = ca.Accountid;
        childCase.contactid = ca.contactid;
        childCase.Requester_Name__c = UserInfo.getUserId();
        childCase.Problem_Type__c = ca.Problem_Type__c;
        childCase.Category__c = ca.Category__c;
        childCase.Sub_Category__c = ca.Sub_Category__c;
        childCase.Case_Issue__c = ca.Case_Issue__c;
        childCase.Case_Sub_Issue__c = ca.Case_Sub_Issue__c;
        childCase.JIRA_Num__c= ca.JIRA_Num__c;
        User user = [select id, name, email from user where id =:ca.ownerId];
        childCase.Email_List__c = user.email;
        
        // Specify DML options to ensure the assignment rules are executed
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.assignmentRuleHeader.useDefaultRule = true;
        childCase.setOptions(dmlOpts);
        insert childCase;
        ca.Status='Tier 3 Investigating';
        update ca;
        //Attchments
        List<Attachment> achment = new List<Attachment>();
        list<Attachment> att = [select Id,parentId,body,name from attachment where parentid = :childcase.parentid];
        for(Attachment a : att){
            attachment ab= new attachment();
            ab.ParentId = childCase.Id; 
            ab.body =a.body;
            ab.IsPrivate = false;
            ab.name=a.name; 
            achment.add(ab);   
        }         
        if(attachment1.body != null ){        
            attachment1.ParentId = childCase.Id; 
            attachment1.IsPrivate = false; 
            achment.add(attachment1);            
        }  
        if(attachment2.body != null ){        
            attachment2.ParentId = childCase.Id; 
            attachment2.IsPrivate = false;   
            achment.add(attachment2);            
        } 
        if(attachment3.body != null ){        
            attachment3.ParentId = childCase.Id; 
            attachment3.IsPrivate = false; 
            achment.add(attachment3);
        } 
        try{
            if(achment.IsEmpty() == false) insert achment;
        }catch(Exception e){
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Error uploading file'));
        }finally{
            attachment1.body = null; // clears the viewstate
            attachment1= new attachment();
            attachment2.body = null; // clears the viewstate
            attachment2= new attachment();
            attachment3.body = null; // clears the viewstate
            attachment3= new attachment();
        }               
    
        callfunc='<script> CloseAndReWfresh(); </script>';                                   
        return null;                         
    }
}