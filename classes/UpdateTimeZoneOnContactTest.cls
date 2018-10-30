public Class UpdateTimeZoneOnContactTest{
    @isTest(SeeAllData = True)
    public static void unitTest(){
        List<User> authorizedUsers = [Select Id, ContactId, TimeZoneSidKey From User where 
                                                            Contact.Customer_Portal_User__c = true and
                                                            Contact.Is_Authorized_Contact__c = 'Yes' and 
                                                            Contact.Account.Type != 'Ex-Customer' Limit 1];
        If(authorizedUsers.size()>0){                                               
            List<User> userTimeZone          = [Select TimeZoneSidkey From User where TimeZoneSidkey !=: authorizedUsers[0].TimeZoneSidkey Limit 1];
            User testUserForUpdate           = new User(id=authorizedUsers[0].Id);
            testUserForUpdate.TimeZoneSidkey = userTimeZone[0].TimeZoneSidKey;
            update testUserForUpdate;
        }   
    }
    @isTest(SeeAllData = True)
    public static void unitTestClassContactTimeZone(){
        List<User> authorizedUsers = [Select Id, ContactId, TimeZoneSidKey,Contact.Munchkin_ID__c From User where 
                                                            Contact.Customer_Portal_User__c = true and
                                                            Contact.Is_Authorized_Contact__c = 'Yes' and 
                                                            Contact.Account.Type != 'Ex-Customer' Limit 10];
        List<Id> tempContactIds = new List<Id>();
        Map<Id,String> ContactIdToTimeZone = new Map<Id,String>();
        Map<String,String> ContactIdToMunchkinId = new Map<String,String>();
        for(User tempVar : authorizedUsers ){
            tempContactIds.add(tempVar.ContactId);
            ContactIdToTimeZone.put(tempVar.ContactId,tempVar.TimeZoneSidKey);
            ContactIdToMunchkinId.put(tempVar.ContactId,tempVar.Contact.Munchkin_ID__c);
        } 
        ContactTimeZone.UpdateTimeZone(tempContactIds,ContactIdToTimeZone); 
        ContactTimeZone.updateContacts(ContactIdToMunchkinId);
    }  
}