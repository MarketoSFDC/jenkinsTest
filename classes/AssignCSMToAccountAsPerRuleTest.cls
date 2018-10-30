@isTest
public class AssignCSMToAccountAsPerRuleTest{
    static testmethod void mytest(){
    
        List<Account> accList = new List<Account>();        
        // Add Parent Account
        Account parentAcc = new Account(Name = 'Test Account');
        parentAcc.Type = 'Customer';
        parentAcc.RecordTypeId = '01250000000ULb7';
        parentAcc.Marketo_Elite__c = TRUE;
        parentAcc.Marketo_Key__c = TRUE;
        parentAcc.Business_Unit__c = 'AMER - ENT';
        //parentAcc.Customer_Success_Manager__c = UserInfo.getUserId();
       
        accList.add(parentAcc);
        
        // Add Child Account
        Account childAcc = new Account(Name = 'Test Account');
        childAcc.Type = 'Customer';
        childAcc.Marketo_Elite__c = TRUE;
        childAcc.RecordTypeId = '01250000000ULb7';
        childAcc.Marketo_Key__c = TRUE;
        childAcc.Business_Unit__c = 'AMER - ENT';
        childAcc.ParentId = parentAcc.Id;
        accList.add(childAcc);  
        
        // Add Simple Account
         Account simpleAcc = new Account(Name = 'Test Account');      
        accList.add(simpleAcc); 
        
        insert accList; 
        
        Test.startTest();
        Map<id, id> csmMap = AssignCSMToAccountAsPerRule.getAccountCSM(accList);
        Map<id, id> csmMap2 = AssignCSMPerRules.getAccountCSM(accList);
        Test.stopTest();
    }
}