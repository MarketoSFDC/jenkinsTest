@isTest
public class AssetDeprovisioningProcesses_test {
    
    @isTest static void testWebservice(){
        List<Account> acc_list = TestCPQUtilityClass.createAccounts(1);
        insert acc_list; 
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        if(RecordTypeIdAccount!=null){
            acc_list[0].recordtypeid=RecordTypeIdAccount;            
            acc_list[0].Type='Customer';
           
        }
      
        AssetDeprovisioningProcesses.submitRecordForSuspensionApproval(acc_list[0].Id);
    }
    
    @isTest static void NotifyAboutAccountLocked(){
        List<Account> acc_list = TestCPQUtilityClass.createAccounts(3);
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        if(RecordTypeIdAccount!=null){
            acc_list[0].recordtypeid=RecordTypeIdAccount;
            acc_list[1].recordtypeid=RecordTypeIdAccount;
            acc_list[2].recordtypeid=RecordTypeIdAccount;
            acc_list[0].Type='Customer';
            acc_list[1].Type='Customer';
            acc_list[2].Type='Customer';
        }
        insert acc_list;
        
        User newUsercon =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser1', 'Mkto1', 'cfsId');
        newUsercon.EmployeeNumber='13456';
        newUsercon.lmscons__Cornerstone_ID__c = 'cfsdd1';
        Insert newUsercon;
        User newUser =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser', 'Mkto', 'cfsId');
        newUser.EmployeeNumber='1345';
        Insert newUSer;
        List<Contact> con_List = TestCPQUtilityClass.createContacts(acc_list,1);
        con_List[0].CE_Primary_Marketo_User__c = TRUE;
        con_List[0].Email = 'test@contact.com';
        con_List[0].pse__Salesforce_User__c = newUsercon.Id;
        con_List[1].CE_Primary_Marketo_User__c = TRUE;
        con_List[1].Email = 'test@contact12.com';
        con_List[1].pse__Salesforce_User__c = newUSer.Id;
        con_List[2].CE_Primary_Marketo_User__c = TRUE;
        con_List[2].Email = 'test@contact12345.com';
        insert con_List;
    
        test.startTest();   
        acc_list[0].Collection_Status__c = 'Account Locked';
        acc_list[0].Credit_Collections_Analyst__c = UserInfo.getUserId();
        acc_list[0].Secondary_E_mail__c  = 'test@t.com,test123@t.com';
        acc_list[1].Collection_Status__c = 'Send 10 days notice';
        acc_list[1].Credit_Collections_Analyst__c = newUser.id;
        acc_list[1].Secondary_E_mail__c  = 'test@t.com,test123@t.com';
        acc_list[2].Collection_Status__c = 'Account Unlocked';
        acc_list[2].Credit_Collections_Analyst__c = newUser.id;
        acc_list[2].Secondary_E_mail__c  = 'test@t.com,test123@t.com';
        update acc_list;
        
        List<Id> accIdLockList = new List<Id>();
        List<Id> accIdSend10daysList = new List<Id>();
        List<Id> accIdUnLockList = new List<Id>();
        accIdLockList.add(acc_list[0].Id);
        accIdLockList.add(acc_list[1].Id);
        accIdSend10daysList.add(acc_list[1].Id);
        accIdUnLockList.add(acc_list[2].Id);
        
        Credit_Collections_Analyst__c cnew = new Credit_Collections_Analyst__c(SetupOwnerId=acc_list[0].Credit_Collections_Analyst__c,Email_ID__c = '');
        Credit_Collections_Analyst__c cnew1 = new Credit_Collections_Analyst__c(SetupOwnerId=acc_list[1].Credit_Collections_Analyst__c,Email_ID__c = 'test@t.com');
        //Credit_Collections_Analyst__c cnew2 = new Credit_Collections_Analyst__c(SetupOwnerId=acc_list[2].Credit_Collections_Analyst__c,Email_ID__c = 'test123@t.com');
        List<Credit_Collections_Analyst__c> cnewList= new List<Credit_Collections_Analyst__c>();
        cnewList.add(cnew);
        cnewList.add(cnew1);
        //cnewList.add(cnew2);
        insert cnewList;
        
        List<EmailTemplate> AccLockedEmailTemp=new List<EmailTemplate>();
        AccLockedEmailTemp=[SELECT Body,HtmlValue,Id,IsActive,Name,Subject,DeveloperName FROM EmailTemplate where (DeveloperName='Provisioning_Notification_ForLock' OR DeveloperName = 'Provisioning_Cust_Notify_forlock_notice') AND IsActive=True];
        
        Credit_Collections_Analyst__c creditCollectionAnalystList = Credit_Collections_Analyst__c.getValues(acc_list[0].Credit_Collections_Analyst__c);
        Credit_Collections_Analyst__c creditCollectionAnalystList1 = Credit_Collections_Analyst__c.getValues(acc_list[1].Credit_Collections_Analyst__c);       
        Credit_Collections_Analyst__c creditCollectionAnalystList2 = Credit_Collections_Analyst__c.getValues(acc_list[2].Credit_Collections_Analyst__c);   
        
        AssetDeprovisioningProcesses.NotifyAboutAccountLocked(accIdLockList);
        AssetDeprovisioningProcesses.NotifyAboutAccountLocked(accIdSend10daysList);
        AssetDeprovisioningProcesses.NotifyAboutAccountLocked(accIdUnLockList);
        
        String EmailBody=AssetDeprovisioningProcesses.getEmailBodyAccLocked();
        EmailBody=AssetDeprovisioningProcesses.getEmailBodySend10DaysNotice();
        AssetDeprovisioningProcesses.validateIntLogForAccountLockAlert(accIdLockList);
        test.stopTest();
    } 

    @isTest static void CollectionStatus10DaysNotice(){
        List<Account> acc_list = TestCPQUtilityClass.createAccounts(2);
        
        Id RecordTypeIdAccount = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
        if(RecordTypeIdAccount!=null){
            acc_list[0].recordtypeid=RecordTypeIdAccount;
            acc_list[1].recordtypeid=RecordTypeIdAccount;
            acc_list[0].Type='Customer';
            acc_list[1].Type='Customer';
        }
        insert acc_list;
        
        User newUsercon =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser1', 'Mkto1', 'cfsId');
        newUsercon.EmployeeNumber='13456';
        newUsercon.lmscons__Cornerstone_ID__c = 'cfsdd1';
        Insert newUsercon;
        
        User newUsercon2 =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser2', 'Mkto2', 'cfsId');
        newUsercon2.EmployeeNumber='134567';
        newUsercon2.lmscons__Cornerstone_ID__c = 'cfsdd12';
        Insert newUsercon2;
        
        List<Contact> con_List = TestCPQUtilityClass.createContacts(acc_list,1);
        con_List[0].CE_Primary_Marketo_User__c = FALSE;       
        con_List[0].Email = 'test@contact.com';
        con_List[0].pse__Salesforce_User__c = newUsercon.Id;     
        insert con_List[0];
  
    
        test.startTest();   
        User newUser =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser', 'Mkto', 'cfsId');
        newUser.EmployeeNumber='1345';
        Insert newUSer;
        acc_list[0].Collection_Status__c = 'Account Locked';
        acc_list[0].Credit_Collections_Analyst__c = UserInfo.getUserId();
        acc_list[0].Secondary_E_mail__c  = 'test@t.com,test123@t.com';
        acc_list[0].CAM_Owner__c = newUser.id;
        acc_list[1].Collection_Status__c = 'Send 10 days notice';
        acc_list[1].Credit_Collections_Analyst__c = newUser.id;
        acc_list[1].Secondary_E_mail__c  = 'test@t.com,test123@t.com';
        update acc_list;
        
        List<Id> accIdList = new List<Id>();
        
        accIdList.add(acc_list[0].Id);
        accIdList.add(acc_list[1].Id);
        
        Credit_Collections_Analyst__c cnew = new Credit_Collections_Analyst__c(SetupOwnerId=acc_list[0].Credit_Collections_Analyst__c,Email_ID__c = '');
        
        insert cnew;
        
        List<EmailTemplate> AccLockedEmailTemp=new List<EmailTemplate>();
        AccLockedEmailTemp=[SELECT Body,HtmlValue,Id,IsActive,Name,Subject,DeveloperName FROM EmailTemplate where (DeveloperName='Provisioning_Notification_ForLock' OR DeveloperName = 'Provisioning_Cust_Notify_forlock_notice') AND IsActive=True];
        
        Credit_Collections_Analyst__c creditCollectionAnalystList = Credit_Collections_Analyst__c.getValues(acc_list[0].Credit_Collections_Analyst__c);
               
        
        AssetDeprovisioningProcesses.NotifyAboutAccountLocked(accIdList);
        
        String EmailBody=AssetDeprovisioningProcesses.getEmailBodyAccLocked();
        EmailBody=AssetDeprovisioningProcesses.getEmailBodySend10DaysNotice();
        AssetDeprovisioningProcesses.validateIntLogForAccountLockAlert(accIdList);
        AssetDeprovisioningProcesses.sendEmailOnError();
        test.stopTest();
    }
    
}