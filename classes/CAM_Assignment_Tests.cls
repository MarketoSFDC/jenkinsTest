@isTest(SeeAllData=false)
public class CAM_Assignment_Tests {
    
    @isTest
    static void shouldTriggerHandler(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'stand1', Email='stand1@testorg.com', 
                    EmailEncodingKey='UTF-8', LastName='stand1', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, 
                    TimeZoneSidKey='America/Los_Angeles', UserName='stand1@cam.com');
        insert u;
        Intacct_Entity__c entity=new Intacct_Entity__c(Name='marketo-rubiks');
        insert entity;
        System.assertNotEquals(u.id,null);
        Account parentAccount=new Account(Name='Test_Account');
        parentAccount.CAM_Owner__c =u.id;
        parentAccount.CAM_Group__c = 'AMER-MM/ENT+L60K';
        parentAccount.Intacct_Entity__c=entity.id;
        parentAccount.IntacctID__c = 'TestIntacctID12345';
        system.debug('Parent Account *******'+parentAccount);
        insert parentAccount;
        
        // Insert Child Account
        List<Account> childAccList=new List<Account>();
        Account childAccount=new Account(name='Child_Account', ParentId = parentAccount.id,CAM_Assign_Status__c='Pending CAM Group Assignment');       
        insert childAccount;  
        childAccList.add(childAccount);
        Account childAccount1=new Account(name='Child_Account1', ParentId = parentAccount.id,CAM_Assign_Status__c='Pending CAM Owner Assignment');       
        insert childAccount1;  
        childAccList.add(childAccount1);   
        CAM_Assignment.syncCAMwithParent(parentAccount); 
        CAM_Assignment.triggerHandler(childAccList);
        
    } 
    static testmethod void testOppTriggerHandler(){
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'stand2', Email='stand2@testorg.com', 
                    EmailEncodingKey='UTF-8', LastName='stand2', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, 
                    TimeZoneSidKey='America/Los_Angeles', UserName='stand2@cam.com');
        insert u;
        Account pacc = new Account(Name = 'Test Parent Account1', CAM_Owner__c = u.id,CAM_Group__c = 'AMER-MM/ENT+L60K');
        insert pacc;
        Account cacc = new Account(Name = 'Test Child Account1', ParentId = pacc.ID);
        insert cacc;
        Id otherUserId = [select Id from User where IsActive = true and Id != :UserInfo.getUserId() limit 1].Id;
        List<CAM_Rotator__c> rotators = new List<CAM_Rotator__c>{
            new CAM_Rotator__c(CAM_Owner__c = UserInfo.getUserId(),CAM_Group__c = 'ANZ SMB'),
            new CAM_Rotator__c(CAM_Owner__c = otherUserId, Last_Assigned__c = System.now(), CAM_Group__c = 'ANZ SMB')
        };
        Account cacc2 = new Account(Name = 'Test Child Account2');
        insert cacc2;
        Opportunity Opp = new Opportunity(Name='test opp',AccountId=cacc2.id,Type='New Business',CloseDate=Date.today(),stagename='Discovery',Deal_Type__c = 'Standard',NextStep='test',CRM_System__c = 'ACT!',LeadSource = 'Blog',Rep_Create_ARR__c = 10,Owner_Role_Custom_Text__c = 'ANZ SMB');
        insert Opp;
        opp.StageName = 'Closed Won';
        //update Opp;
        CAM_Assignment.triggerHandler(new Opportunity[]{Opp});  
    }
    
    @isTest
    static void shouldUpdateChildAccountsNew(){ 
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
        User u = new User(Alias = 'stand3', Email='stand3@testorg.com', 
                    EmailEncodingKey='UTF-8', LastName='stand3', LanguageLocaleKey='en_US', 
                    LocaleSidKey='en_US', ProfileId = p.Id, 
                    TimeZoneSidKey='America/Los_Angeles', UserName='stand3@cam.com');
        insert u;
        string ownerId=u.id;
        System.assertNotEquals(u.id,null);
        Account parentAccount=new Account(Name='Test_Account');
        parentAccount.CAM_Owner__c =u.id;
        parentAccount.CAM_Group__c = 'AMER-MM/ENT+L60K';
        insert parentAccount;
        
        // Insert Child Account
        Account childAccount=new Account(name='Child_Account', ParentId = parentAccount.id);       
        insert childAccount;        
        
        CAM_Assignment.childAccountQueryOverride = new Account[]{childAccount};
        CAM_Assignment.updateChildAccountsNew(new Account[]{parentAccount});
    }
}