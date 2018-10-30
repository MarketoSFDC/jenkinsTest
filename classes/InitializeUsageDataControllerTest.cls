@IsTest
public class InitializeUsageDataControllerTest {
    static testMethod void testInitializeUsageData(){
        // Insert Account
        List<Account> accList =  new List<Account>();
        accList = TestCPQUtilityClass.createAccounts(10);         
        if(!accList.isEmpty()){
            insert accList;
        }
        
        // Insert Contact
        List<Contact> contactList = new List<Contact>();
        contactList = TestCPQUtilityClass.createContacts(accList,1);
        if(!contactList.isEmpty()){
            insert contactList[0];
        }
        for(Contact con :contactList){
            con.User_Type_Sales_User__c=TRUE;
            con.Marketo_End_User__c = TRUE;
        }
        update contactList[0];
        
       // System.DEBUG('Contact======>' + [Select id, lastName, Marketo_End_User__c from Contact where Id IN : contactList];
        
        List<JBCXM__UsageData__c> usageDataList = new List<JBCXM__UsageData__c>();
        for(Integer i=0; i<accList.size(); i++){
            JBCXM__UsageData__c testUsageData = new JBCXM__UsageData__c();
            testUsageData.JBCXM__Account__c = accList[i].Id;
            testUsageData.Marketo_Users__c = 7.07;
            usageDataList.add(testUsageData);           
        }
        if(!accList.isEmpty()){
            insert usageDataList;
        } 
        
        InitializeUsageDataController usageObj = new InitializeUsageDataController();
        usageObj.InitializeUsageData(usageDataList);
    }
}