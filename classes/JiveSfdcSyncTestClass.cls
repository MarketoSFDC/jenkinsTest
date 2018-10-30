/*********************************************************************
* Last Modified by   : Grazitti 
* Modified Date      : 28-April-18
* Purpose            : #01009688 Consolidate Support Engineer Fields on Entitlement
* Line numbers       : 35,37

**********************************************************************/

@isTest(SeeAllData=True)
public class JiveSfdcSyncTestClass{

    public static testMethod void JiveSfdcSync() {
    
        Contact Cont = [select id, accountId, Email, FirstName, lastName, title, Phone, MobilePhone, Munchkin_ID__c, Marketo_POD__c  from contact where Is_Authorized_Contact__c ='Yes' limit 1]; //sf4twitter__Twitter_Username__c, 
        Cont.Email = 'test@test.com';
        Cont.FirstName = 'test';
        Cont.lastName = 'test';
        Cont.title = 'test';
        Cont.Phone = '123456789';
        Cont.MobilePhone = '1234567890';
        //Cont.sf4twitter__Twitter_Username__c = 'test';
        Cont.Munchkin_ID__c = 'test123';
        Cont.Marketo_POD__c = 'test';
        update Cont;     
                  
        account acc = [select id, Type, Partner_Type__c, CAM_Owner__c, Engagement_Mgr_Owner__c, BillingCountry  from account where id = :Cont.accountId limit 1];
        User usr = [select id from user where Isactive = true and IsPortalEnabled =false and UserType ='Standard' limit 1];
        //acc.Type = 'testAcc';
        acc.Partner_Type__c = 'testAcc';
        acc.CAM_Owner__c = usr.id;
        acc.Engagement_Mgr_Owner__c =  usr.id;
        acc.BillingCountry  = 'testAcc';
        update acc;
        
        entitlement ent = [select id, Support_Region__c, AssignedSupportPOC__c, type from entitlement where accountid =:Cont.accountId limit 1];         
        ent.Support_Region__c = 'testEnt';
        ent.AssignedSupportPOC__c= usr.id;
        ent.type = 'Premier Plus';
        update ent;
        
        authorized_contact__c authCon = [select id from authorized_contact__c where contact__r.id = :Cont.id limit 1];
        authCon.Customer_Admin__c = false;
        update authCon;
        delete authCon;
    } 
       
    static testmethod void testMemberRestsvc(){
            
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse(); 
        req.requestURI = '<a target="_blank" href="{system.label.JIveServiceClassSiteUrl};" rel="nofollow">system.label.JIveServiceClassSiteUrl;</a>';
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        String results = JIveSFDCServiceClass.parseWebhhokData();   
        
    }
    
    public static testMethod void testscheduleSfdcJiveSyncingStatusNotification() {
        Test.StartTest();
            SfdcJiveSyncingStatusNotification testsche = new SfdcJiveSyncingStatusNotification();
            testsche.execute(null);
        Test.stopTest();
    }

}