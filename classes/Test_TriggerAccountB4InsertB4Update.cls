@istest(SeeAllData=False)
public class Test_TriggerAccountB4InsertB4Update{

    static testmethod void UpdateContactOwnerAsAccountOwnerTest(){
        Account acc = new Account(Name='test Account for trigger',ownerid = UserInfo.getUserId(),Target_Account_1__c = 'Enterprise Target');
        acc.SDR_Owner_Picklist__c = 'Vishal Sharma';
        insert acc;        
        User u = HelperWithoutSharing.createTestUser(UserInfo.getProfileId(), 'firstNameTest', 'secondNameTest','');
        insert u;
        Contact c = new Contact(LastName = 'test Con', LeadSource = 'Blog', AccountId = acc.id, ownerid = u.Id, SDR_Owner__c = 'Kevin Horkan'  );
        insert c;
        Utility.isUpdateContactOwnerAsAccountOwnerRunningOnceMore = false;
        acc.SDR_Owner_Picklist__c = 'Ayub Ansari';
        update acc;        
        system.debug(acc.Id+'===ids'+c.AccountId +'###'+acc.OwnerId+'ownerI>>>'+c.OwnerId);        
    }
    static testmethod void UpdateContactOwnerAsAccountOwnerTest2(){
        Account acc = new Account(Name='test Account for trigger',ownerid = UserInfo.getUserId());
        acc.SDR_Owner_Picklist__c = 'Vishal Sharma';
        insert acc;        
        User u = HelperWithoutSharing.createTestUser(UserInfo.getProfileId(), 'firstNameTest', 'secondNameTest','');
        insert u;
        Contact c = new Contact(LastName = 'test Con', LeadSource = 'Blog', AccountId = acc.id, ownerid = u.Id, SDR_Owner__c = 'Kevin Horkan'  );
        insert c;
        Utility.isUpdateContactOwnerAsAccountOwnerRunningOnceMore = false;
        acc.SDR_Owner_Picklist__c = 'Ayub Ansari';
        update acc;        
        system.debug(acc.Id+'===ids'+c.AccountId +'###'+acc.OwnerId+'ownerI>>>'+c.OwnerId);        
    }
        
    static testmethod void DeactivatedUserReferencesControllerTest(){    
        DeactivatedUserReferencesController deactivatedUser = new DeactivatedUserReferencesController();
        User u = HelperWithoutSharing.createTestUser(UserInfo.getProfileId(), 'firstNameTest', 'secondNameTest','');      
        system.runAs(u){
            String jobId = System.schedule('testBasicScheduledApex', '0 0 0 3 9 ? 2022', new Schedule_Sales_Invoice ());
        }
        deactivatedUser.userId = u.Id;
        deactivatedUser.getJobDetails();
    }
}