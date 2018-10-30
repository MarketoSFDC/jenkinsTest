@IsTest
public class Known_Issue_Class_Test {
    
    @IsTest
    static void main(){
        
        KISettings__c customSetting = new KISettings__c();
        customSetting.Name = 'Default';
        customSetting.Visualforce_Domain__c = 'test';
        customSetting.Default_Notification__c = 'pgonzalez@marketo.com';
        insert customSetting;
        
        Known_Issue__c ki = new Known_Issue__c();
        insert ki;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
        User u1 = new User(Alias = 'standt1',Country='United Kingdom',Email='demo1@randomdemodomain.com',EmailEncodingKey='UTF-8', LastName='Testging', LanguageLocaleKey='en_US',LocaleSidKey='en_US',ProfileId = p.Id,TimeZoneSidKey='America/Los_Angeles', UserName='demo1@ffgfg.com');
        insert u1;
        
        KI_Notification__c kn = new KI_Notification__c();
        kn.Known_Issue__c = ki.Id;
        kn.Subscribed_User_Name__c = u1.Id;
        insert kn;
        
        Known_Issue_Class kiClass = new Known_Issue_Class();
        kiClass.executeAfterInsert(ki);
        
        /*Create known issue notification*/
        KI_Notification__c notification = new KI_Notification__c();
        notification.name = 'pgonzalez@marketo.com';
        notification.Known_Issue__c = ki.Id;
        insert notification;
        
        /*Create known issue update*/
        KI_Update__c kiUpdate = new KI_Update__c();
        kiUpdate.Known_Issue__c = ki.Id;
        insert kiUpdate;
    }

}