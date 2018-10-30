/**Apex Scheduler that deletes users from public group when entitlement End Date reached**/
global class DeleteUserWhenEntitlementEndDateReached implements Schedulable{
    List<Entitlement> expiredEntitlement;
    public DeleteUserWhenEntitlementEndDateReached (set<String> expiredEnts){
        expiredEntitlement = new List<Entitlement>([SELECT AccountId FROM Entitlement WHERE Id IN : expiredEnts]);
    }
    public DeleteUserWhenEntitlementEndDateReached (){
        String LMSEntRecordTypeId = LMS_Util.LMSEntRecordTypeId;
        expiredEntitlement  = new List<Entitlement>([SELECT AccountId FROM Entitlement WHERE EndDate =: Date.TODAY() and recordTypeId =: LMSEntRecordTypeId]);
    }
    global void execute(SchedulableContext SC) {    
        Set<String> accountIds = new Set<String>();
        Set<String> userIds = new Set<String>();
        for(Entitlement ent : expiredEntitlement){
         system.debug(ent.AccountId+'accountids---'); 
         accountIds.add(ent.AccountId);
        }
        
        List<Learning_Passport__c> passportsToBeArchived = new List<Learning_Passport__c>([SELECT Id, IsArchived__c FROM Learning_Passport__c WHERE Entitlement__c IN: expiredEntitlement]);
        for(Learning_Passport__c learningPassport : passportsToBeArchived){         
         learningPassport.IsArchived__c = true;
        }
            
        system.debug(accountIds+'===acc');
        for(User usr : [SELECT Id FROM User WHERE AccountId IN : accountIds AND isActive = : True ]){
         userIds.add(usr.id);
        }
        system.debug(userIds+'===user');
        List<GroupMember> groupMemebrlist = new List<GroupMember>();     
        String GROUPID = LMS_Util.returnPremiumCatalogGroupId();
        groupMemebrlist = [SELECT Id from GroupMember WHERE GroupId =:GROUPID AND UserOrGroupId IN : userIds];
        if(!groupMemebrlist.isEmpty()) {
            System.debug('Group Member List is ' + groupMemebrlist);
            try{
                delete groupMemebrlist;
                if(!passportsToBeArchived.isEmpty()) {
                    update passportsToBeArchived;
                }
            }catch(Exception e){sendExceptionMail(e);}
        }
     
        //CODE TO POPULATE THE SUPPORT ADMIN CONTACT FIELD ON ENTITLEMENT  
        /* CODE HAS BEEN MOVED TO CLASS- SupportAdminOnActiveEntitlementPopulater*/  
   
   }
   public void sendExceptionMail(Exception e){
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {'ayub.a@grazitti.com'};
       mail.setToAddresses(toAddresses);
       mail.setSubject('MARKETO LMS EXCEPTION:: ' +e);
       mail.setPlainTextBody('MARKETO LMS EXCEPTION in the class DeleteUserWhenEntitlementEndDateReached'+e);
       try{Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });}catch(exception ex){}
     }
   
   
}