public class KnownIssueExt {
    
    
    public String removedEmail {get; set;}
    public String addedEmail {get; set;}
    public List<Attachment> attachments {get; set;}
    public List<KI_Update__c> kiuList {get; set;}
    public Affected_Customer__c singleCustomer {get; set;}
    public List<Affected_Customer__c > customerList {get; set;}
    public Known_Issue__c ki {get; set;}
    
    public KnownIssueExt(ApexPages.StandardController sc){
        
        ki = [SELECT Id FROM Known_Issue__c WHERE Id = : sc.getId()];
        
        kiuList = [SELECT Id, Description__c , CreatedDate, CreatedBy.FirstName, CreatedBy.LastName FROM KI_Update__c 
                   WHERE Known_Issue__r.id =: ki.id 
                   ORDER BY CreatedDate Desc];
        
        customerList = [SELECT Id, Name,Case_Number__c 
                        FROM Affected_Customer__c WHERE Known_Issue__r.id =: ki.id];
        
        
        singleCustomer = new Affected_Customer__c();
        
        getAttachments();
    }
    
    public void addCustomer(){
        singleCustomer.Known_Issue__c = ki.Id;
        insert singleCustomer;
        customerList.add(singleCustomer);        
        singleCustomer = new Affected_Customer__c();
    }
    
    public void addNotification(){
        List<User> usrList = new List<User>();
        KI_Notification__c notification = new KI_Notification__c();
        usrList = [SELECT Id,name,email FROM User where email =: addedEmail];
        if(usrList != null && usrList.Size() > 0){
            notification.Known_Issue__c = ki.id;
            notification.Name = usrList[0].email;
            notification.Subscribed_User_Name__c = usrList[0].Id;
            insert notification;
        }
  
    }
    
    public void removeNotification(){
        List<KI_Notification__c> notifications = [SELECT Id, Name FROM KI_Notification__c 
             WHERE name =: removedEmail];
        
        if(!notifications.isEmpty()){
            delete notifications;
        }    
    }
    
    public void getAttachments(){
        attachments = [SELECT Id, Name, Description, CreatedDate
                    FROM Attachment
                    WHERE ParentId = :ki.id
                    ORDER by CreatedDate];
    }
}