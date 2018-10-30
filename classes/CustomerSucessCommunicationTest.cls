@isTest 
public class CustomerSucessCommunicationTest{

    @isTest static void CommunicationTesMethod(){
        Case cse = new Case();
        cse.recordtypeId = Label.CSMRecordTypeId;
        cse.Category__c = 'ToutApp';
        cse.Problem_Type__c = 'How-to';
        cse.Sub_Category__c = 'Munchkin';
        cse.Last_Public_Comment_Date_Time__c = null;
        cse.Last_Comment_Date_Time__c = null;
        cse.ownerId = UserInfo.getUserId();
        cse.priority= 'High';
        cse.status = 'New';
        insert cse;
        Datetime oldDate = Datetime.now().addDays(-14);
        Test.setCreatedDate(cse.Id, oldDate); 
        system.debug('#####' +cse.createddate);
        CustomerSucessCommunication.getNotification();
    }
    @isTest static void CommunicationTesMethod2(){
        Case cse = new Case();
        cse.recordtypeId = Label.CSMRecordTypeId;
        cse.Category__c = 'ToutApp';
        cse.Problem_Type__c = 'How-to';
        cse.Sub_Category__c = 'Munchkin';
        cse.Last_Public_Comment_Date_Time__c = null;
        cse.Last_Comment_Date_Time__c = null;
        cse.ownerId = UserInfo.getUserId();
        cse.priority= 'Medium';
        cse.status = 'New';
        insert cse;
        Datetime oldDate = Datetime.now().addDays(-14);
        Test.setCreatedDate(cse.Id, oldDate); 
        system.debug('#####' +cse.createddate);
        CustomerSucessCommunication.getNotification();
    }
    @isTest static void CommunicationTesMethod3(){
        Case cse = new Case();
        cse.recordtypeId = Label.CSMRecordTypeId;
        cse.Category__c = 'ToutApp';
        cse.Problem_Type__c = 'How-to';
        cse.Sub_Category__c = 'Munchkin';
        cse.Last_Public_Comment_Date_Time__c = null;
        cse.Last_Comment_Date_Time__c = null;
        cse.ownerId = UserInfo.getUserId();
        cse.priority= 'Low';
        cse.status = 'New';
        insert cse;
        Datetime oldDate = Datetime.now().addDays(-7);
        Test.setCreatedDate(cse.Id, oldDate); 
        system.debug('#####' +cse.createddate);
        CustomerSucessCommunication.getNotification();
    }
     @isTest static void CommunicationTesMethod4(){
        Case cse = new Case();
        cse.recordtypeId = Label.CSMRecordTypeId;
        cse.Category__c = 'ToutApp';
        cse.Problem_Type__c = 'How-to';
        cse.Sub_Category__c = 'Munchkin';
        cse.Last_Public_Comment_Date_Time__c = null;
        cse.Last_Comment_Date_Time__c = null;
        cse.ownerId = UserInfo.getUserId();
        cse.priority= 'Medium';
        cse.status = 'New';
        insert cse;
        Datetime oldDate = Datetime.now().addDays(-5);
        Test.setCreatedDate(cse.Id, oldDate); 
        system.debug('#####' +cse.createddate);
        CustomerSucessCommunication.getNotification();
    }

}