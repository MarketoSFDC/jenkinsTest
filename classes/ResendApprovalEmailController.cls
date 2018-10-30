/*
 * Purpose : This controller sends the Approval Request Reminder email to single user or Queued user.
 * Author  : Prabhat Rai
 * Date    : 01/27/2015 
 *
 * Modified By: Sumit Bhatt, Grazitti Interactive
 * Purpose: REF: #APPS-18580# Update Test Classes
 * Tracking: One cn track the changes by searching ticket number in code
 */
 
 
public class ResendApprovalEmailController {
    //This variable stores the Id of ReminderEmailTemplate.
    /*private string approvalRequestReminderEmailTemplateId = '';
    private Map<string,string> userNameEmailMap = new Map<string,string>();
    public string apprvalRequestId {get;set;}
    public ResendApprovalEmailController(){        
    }
    
    //This method invokes from the apex page action.    
    public PageReference SendQueuedEmails()
    {
        try
        {            
            apprvalRequestId = ApexPages.CurrentPage().getParameters().get('id');
            if(apprvalRequestId != null)
            {
                List<Apttus_Approval__Approval_Request__c>  approvalRequests=  [Select Apttus_Approval__Assigned_To_Type__c,Apttus_Approval__Assigned_To_Id__c from Apttus_Approval__Approval_Request__c where Id=: apprvalRequestId];
                if(approvalRequests.size() > 0)
                {
                    //One time set the reminder email template id.
                    SetRequestReminderEmailTemplate();                
                    if(approvalRequests[0].Apttus_Approval__Assigned_To_Type__c == 'User'){
                        SendEmailtoUser(approvalRequests[0].Apttus_Approval__Assigned_To_Id__c,apprvalRequestId);
                    }
                    else if(approvalRequests[0].Apttus_Approval__Assigned_To_Type__c == 'Queue'){
                        SendEmailToQueue(approvalRequests[0].Apttus_Approval__Assigned_To_Id__c,apprvalRequestId);
                    }            
                }
            }
            return null;
            //return new PageReference('/' + apprvalRequestId)
        }
        catch(Exception ex)
        {
            system.debug('**SendQueuedEmails Method Exception**' + ex.getMessage());
            return null;
        }
    }
    
    //Set the id of ApprovalRequestReminderEmailTemplate.
    private void SetRequestReminderEmailTemplate()
    {
        List<EmailTemplate> tmplts= [select Id from  EmailTemplate where DeveloperName='Apttus_Approval_Request_Reminder'];
        if(tmplts != null && tmplts.size() >0){            
            approvalRequestReminderEmailTemplateId = tmplts[0].Id;
        }
    }
    
    //Send email to individual user
    private void SendEmailtoUser(string userId,string approvalRequestId){
        try
        {
            if(userId != '' && approvalRequestId != ''){
                String emailAddress =userNameEmailMap.get(userId);
                if(emailAddress == null || emailAddress == '')
                {
                    List<User> user = [SELECT email FROM User where id =: userId];                
                    if(user != null && user.size() > 0) {
                        emailAddress = user[0].email;
                        userNameEmailMap.put(userId, user[0].email);                   
                    }
                }
                Messaging.SingleEmailMessage EMail = new Messaging.SingleEmailmessage();
                EMail.setToAddresses(new String[]{emailAddress});
                EMail.setTargetObjectId(userId);
                if(approvalRequestReminderEmailTemplateId != null){            
                    EMail.setTemplateId(approvalRequestReminderEmailTemplateId);
                }
                EMail.saveAsActivity = false;        
               
                EMail.whatid = approvalRequestId;
               
                //Send email
				//APPS-18580
				if(Limits.getEmailInvocations() < 10)
				//APPS-18580
                Messaging.sendEmail(new Messaging.Singleemailmessage[]{ EMail });    
            }
        }
        catch(Exception ex)
        {
            system.debug('**SendEmailtoUser Method Exception**' + ex.getMessage());
        }
    }    
   
    //Send email to queued users.
    private void SendEmailToQueue(string queueId,string approvalRequestId){
        try
        {
            if(queueId != '' && approvalRequestId != ''){
                List<GroupMember> members = [Select Id,UserOrGroupId from GroupMember where GroupId=:queueId];
                if(members!= null && members.size() >0){
                    for(GroupMember member:members){
                        SendEmailtoUser(member.UserOrGroupId,approvalRequestId);
                    }
                }
            }
        }
        catch(Exception ex)
        {
            system.debug('**SendEmailToQueue Method Exception**' + ex.getMessage());
        }
    }*/
}