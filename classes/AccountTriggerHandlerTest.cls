// This Clas acts as Test clas for 'AccountTriggerHandler'
@isTest
public class AccountTriggerHandlerTest{

    static  testMethod void testSdrFieldsonAccount(){
        //Create two Different User
        //Fetch the Profile
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        List<User> lstUser = new List<User>();
        lstUser.add(new User(Alias = 'acc1', Email='acc1@test1.com', EmailEncodingKey='UTF-8', FirstName = 'acc',
                            LastName='test', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='acc@test1.com'));
        lstUser.add(new User(Alias = 'acc2', Email='acc2@test2.com', EmailEncodingKey='UTF-8', FirstName = 'acc2',
                            LastName='test2', LanguageLocaleKey='en_US', LocaleSidKey='en_US', ProfileId = p.Id, 
                            TimeZoneSidKey='America/Los_Angeles', UserName='acc2@test2.com'));

        insert lstUser;

        //Create Accounts
        List<Account> lstAccounts = new List<Account>();
        for(Integer i=0; i<10; i++){
            if(i<5){
                    lstAccounts.add(new Account(Name = 'Test Account'+i, SDR_Owner_Picklist__c = 'Aaron Stein',LS_Deal_Score__c=200,LS_Account_Score__c=300 ));
                }else{
                    lstAccounts.add(new Account(Name = 'Test Account'+i, SDR_Owner_Picklist__c = 'Alan Shortt',LS_Deal_Score__c=200,LS_Account_Score__c=300));
                }

        }
        

        Test.startTest();

            //Insert Account
            insert lstAccounts;
            
            //Update Accounts
            List<Account> lstUpdatedAccount = new List<Account>();
            for(Integer i=0; i<10; i++){
                Account objAcc = lstAccounts[i];
                if(i < 5){
                    Contact c1= new Contact(AccountId = objAcc.Id);
                    Contact c2= new Contact(AccountId = objAcc.Id);
                    objAcc.SDR_Owner_Picklist__c = 'Alan Shortt';
                    objAcc.LS_Deal_Score__c=200;
                    objAcc.LS_Account_Score__c=300;
                }else{
                    Contact c1= new Contact(AccountId = objAcc.Id);
                    Contact c2= new Contact(AccountId = objAcc.Id);
                    objAcc.SDR_Owner_Picklist__c = '';
                    objAcc.LS_Deal_Score__c=200;
                    objAcc.LS_Account_Score__c=300;
                }
                lstUpdatedAccount.add(objAcc);
            }

            update lstUpdatedAccount;
            AccountTriggerHandler.updateSDPFields(lstUpdatedAccount);

        Test.stopTest();
    }
    
}