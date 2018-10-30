public class ContactTimeZone{
    public Static Boolean oneTimeUpdate = true; 
    public static boolean runOnce = true;
    @Future
    public Static void UpdateTimeZone(List<Id> contactsToBeUpdated, Map<Id,String> contIdToTimeZone){
        System.debug('Static method is run'+contactsToBeUpdated);
        List<Contact> finalUpdateListOfContact = new List<Contact>();
        List<Contact> cont = [Select id,Time_Zone__c from contact where Customer_Portal_User__c = True and Is_Authorized_Contact__c = 'Yes' AND Id IN : contactsToBeUpdated];
        system.debug('Contacts In Future methods'+cont);
        for(Contact tempContact : cont){
            System.debug('contIdToTimeZone'+contIdToTimeZone.get(tempContact.Id));
            tempContact.Time_Zone__c = contIdToTimeZone.get(tempContact.Id);
            finalUpdateListOfContact.add(tempContact); 
        }
        System.Debug('finalUpdateListOfContact++++'+finalUpdateListOfContact);
        update finalUpdateListOfContact;
    }
    @Future
    public static void updateContacts(Map<String,String> cntMnkMap) {
        System.Debug('ContactTimeZone.oneTimeUpdateInFutureMethod++++'+ContactTimeZone.oneTimeUpdate);
        set<string> cntIds = cntMnkMap.keyset();
        List<Contact> cLst = [select Id,Munchkin_ID__c from Contact where Id in: cntIds];
        List<Contact> cntUpdLst = new List<Contact>();
        for(Contact c :cLst)               
        {
            if(c.Munchkin_ID__c != cntMnkMap.get(c.Id))
            {   
                c.Munchkin_ID__c = cntMnkMap.get(c.Id);
                cntUpdLst.add(c);
            }
        }
        if(!cntUpdLst.isEmpty()){
            SfdcJiveHelper.RunIntegrationTriggerOnce = true; 
            update cntUpdLst;
        }
    }/*
    @Future
    public static void updateUsers(Map<Id,String> usrIdToTimeZone){
        Set<Id> userIds = usrIdToTimeZone.keySet();
        List<User> usersToBeUpdated = new List<User>();
        for(Id tempId : userIds){
            User tempUser = new User(Id=tempId);
            tempUser.TimeZOneSidKey = usrIdToTimeZone.get(tempId);
            usersToBeUpdated.add(tempUser);
        }
        update usersToBeUpdated;     
    }*/
}