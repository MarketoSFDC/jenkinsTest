@isTest(seeAllData=true)
public class ScheduleBatchUpdateContactOwnerTest{

    public static testMethod void Method1(){
    // Query SDR User
    List<Account> AccList=new List<Account>();
    List<Contact> ContList=new List<Contact>();
    List<User> SDRUserList=[SELECT Id,Name,IsActive,Profile.Name,UserRole.Name FROM User where Profile.Name='Sales Development' and IsActive=True limit 4];
    
    Account acc = new Account(Name = 'Test Account',Target_Account_1__c = 'Enterprise Target' ,SDR_Owner_Lookup__c=SDRUserList[0].Id,LS_Deal_Score__c=200,LS_Account_Score__c=300,Account_Category__c='2018 Named Account',SDR_Owner_Picklist__c=SDRUserList[0].Name ); 
    
    Account acc1= new Account(Name = 'Test Account1',Target_Account_1__c = 'Enterprise Target' ,SDR_Owner_Lookup__c=SDRUserList[1].Id,SDR_Owner_Picklist__c=SDRUserList[1].Name);
    
    Account acc3= new Account(Name = 'Test Account1',Target_Account_1__c = 'Enterprise Target' ,SDR_Owner_Lookup__c=SDRUserList[1].Id,SDR_Owner_Picklist__c=SDRUserList[1].Name,Account_Category__c='2018 Named Account');
    AccList.add(acc);
    AccList.add(acc1);
    AccList.add(acc3);
    
    if(!AccList.isEmpty()){
        insert AccList;
    }
        
        contact con1 = new Contact(FirstName = 'Test1231223', LastName ='Test1', email= 'tert@tets.com', accountId= AccList[0].Id);
        
        contact con2 = new Contact(FirstName = 'Test1231224', LastName ='Test2', email= 'tert@tets.com', accountId= AccList[1].Id,Contact_Status__c='Opportunity');
         
        contact con3 = new Contact(FirstName = 'Test12', LastName ='Test3', email= 'tert@tets.com', accountId= AccList[2].Id,Contact_Status__c='Lead');
        
        ContList.add(con1);
        ContList.add(con2);
        ContList.add(con3);
        
        if(!ContList.isEmpty()){
            insert ContList;
        }
        Test.startTest();
        if(!AccList.isEmpty()){
        AccList[0].OwnerId=SDRUserList[2].Id;
        AccList[1].Account_Category__c='';
        AccList[2].Account_Category__c='';
        Update AccList;
        }
        
        ScheduleBatchUpdateContactOwner sh1 = new ScheduleBatchUpdateContactOwner();
    ScheduleBatchUpdateContactOwner.accMap.put(acc.Id, acc);
        sh1.execute(Null);
        Test.stopTest();
    }
}