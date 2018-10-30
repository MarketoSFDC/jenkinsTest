/* Written By Brian Cherry 4/2018. This class will be invoked by a process builder to send approval emails for SteelBrick CPQ*/ 

public class SBapprovalHandler {
    
    //This is the main invokable method. This queries all the approvals from the platform Event and loops
    //through it flow through the logic required. If delegated user is set, we use that field if the timeframe meets
    //critera using System.today(), then moves to determine if it's a user or if it's a group. If it's a group, we need to query 
    //all users tied to the group. This class will not handle groups nested into groups.
    
    @InvocableMethod(label='Send CPQ Approval Emails' description='Sends email to approvers listed in approval rule')
    public static void processApprovalEmails(List<ID> ids)
    {
        //Need to Query The Approvals
        List<sbaa__Approval__c> theApprovals = [SELECT sbaa__Approver__c,
                                                sbaa__Approver__r.sbaa__GroupId__c,
                                                sbaa__Approver__r.sbaa__User__c,
                                                sbaa__Approver__r.sbaa__User__r.Email,
                                                sbaa__Approver__r.sbaa__DelegatedApprover__c,
                                                sbaa__Approver__r.sbaa__DelegationStart__c, 
                                                sbaa__Approver__r.sbaa__DelegationEnd__c,
                                                sbaa__Approver__r.sbaa__DelegatedApprover__r.sbaa__User__c,
                                                sbaa__Approver__r.sbaa__DelegatedApprover__r.sbaa__User__r.Email,
                                                sbaa__Approver__r.sbaa__DelegatedApprover__r.sbaa__GroupId__c,
                                                sbaa__Rule__r.RequestTemplate__r.sbaa__TemplateId__c
                                                from sbaa__Approval__c where id in: ids];
        for(sbaa__Approval__c a : theApprovals)
        {
             Set<String> groupIds = new Set<String>();
             List<String> emails = new List<String>();
            //Check if delegated Approver is set
            if(a.sbaa__Approver__r.sbaa__DelegatedApprover__c != NULL && 
               a.sbaa__Approver__r.sbaa__DelegationEnd__c >= System.Today() 
               && a.sbaa__Approver__r.sbaa__DelegationStart__c <= System.Today())
            {
            	if(a.sbaa__Approver__r.sbaa__DelegatedApprover__r.sbaa__User__c != NULL)
            	{
                	emails.add(a.sbaa__Approver__r.sbaa__DelegatedApprover__r.sbaa__User__r.Email);
            	}
                	else if(a.sbaa__Approver__r.sbaa__DelegatedApprover__r.sbaa__GroupId__c != NULL)
                	{
                	groupIds.add(a.sbaa__Approver__r.sbaa__DelegatedApprover__r.sbaa__GroupId__c);   
                	}
            }  
            //If not delegated, then let's see if there is a user. If both user and group is set, we are going to use
            //the user
            else if(a.sbaa__Approver__r.sbaa__User__c != NULL)
            {
                emails.add(a.sbaa__Approver__r.sbaa__User__r.Email);
            }
            //If user is blank, let's look at the group. Now if both are empty, we are essentailly just going to break.
            else if(a.sbaa__Approver__r.sbaa__GroupId__c != NULL)
            {
                groupIds.add(a.sbaa__Approver__r.sbaa__GroupId__c);
           	}
            //If we found people to email, then let's do it!!!
            if((groupIds.size()>0 || emails.size()>0) && a.sbaa__Rule__r.RequestTemplate__r.sbaa__TemplateId__c != NULL) 
            {
                sendEmails(a.id,emails,groupIds,a.sbaa__Rule__r.RequestTemplate__r.sbaa__TemplateId__c);
            }
            
        }
    }
            
 
    public static void sendEmails(id approvalId, List<String> Emails, Set<String> groupIds, id templateId)
        { 
            if(Limits.getEmailInvocations() > 9)
            {
             SBapprovalHandler.sendEmailsFuture(approvalId,Emails,groupIds,templateId);   
            }
            else
            {
            if(groupIds.size() > 0)
            {
               emails.addAll(getEmailAddressesofGroups(groupIds));
            }
        	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
	    	email.setWhatId(approvalId);
			email.setTemplateId(templateId);
			email.setToAddresses(Emails);
            email.setInReplyTo('steelbrick_approval_service@j-1bxuumtonei53x4eb7y305w6uttthz55c98p8c8xp1ur1787gd.5-6shbeai.na3.apex.salesforce.com');
            email.setReplyTo('steelbrick_approval_service@j-1bxuumtonei53x4eb7y305w6uttthz55c98p8c8xp1ur1787gd.5-6shbeai.na3.apex.salesforce.com');
			email.settargetObjectId(UserInfo.getUserId()); 
			email.setsaveAsActivity(false);
        	email.setTreatTargetObjectAsRecipient(false); 
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] 
        		{ 
        			email 
        		}
        		);
        }
        }
	    
    public static List<String> getEmailAddressesOfGroups(Set<String> groupIDs) {
    	List<String> mailToAddresses = new List<String>();
    	List<User> users = [SELECT Email FROM User
                 			WHERE Id IN (
                          		SELECT UserOrGroupId
                          		FROM GroupMember
                          		WHERE Group.id in :groupIds
                        				)];
    	for(User u : users)
        {
        	mailToAddresses.add(u.email);
        }
    		return mailToAddresses;
}
    
 @future
        public static void sendEmailsFuture(id approvalId, List<String> Emails, Set<String> groupIds, id templateId)
        {
            //Let's check if we are passing a group.
            if(groupIds.size() > 0)
            {
               emails.addAll(getEmailAddressesofGroups(groupIds));
            }
        	Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
	    	email.setWhatId(approvalId);
			email.setTemplateId(templateId);
			email.setToAddresses(Emails);
            email.setInReplyTo('steelbrick_approval_service@j-1bxuumtonei53x4eb7y305w6uttthz55c98p8c8xp1ur1787gd.5-6shbeai.na3.apex.salesforce.com');
            email.setReplyTo('steelbrick_approval_service@j-1bxuumtonei53x4eb7y305w6uttthz55c98p8c8xp1ur1787gd.5-6shbeai.na3.apex.salesforce.com');
			email.settargetObjectId(UserInfo.getUserId()); 
			email.setsaveAsActivity(false);
        	email.setTreatTargetObjectAsRecipient(false); 
        	Messaging.sendEmail(new Messaging.SingleEmailMessage[] 
        		{ 
        			email 
        		}
        		);
        }

}