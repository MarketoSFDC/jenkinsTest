@isTest()
public class Populate_SupportAdmin_Name_Test {

    static testmethod void authrosiedTest(){
       SupportEmailSettings__c ss = new SupportEmailSettings__c();
       ss.name = 'Onboarding Reminder Notification';
       ss.RecordId__c = '00X38000001AhvK';
       insert ss;
       
       User newUser =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser', 'Mkto', 'cfsId');
            insert newUSer;
        Account acc = new Account();
                    acc.Name = 'Test Account For Entitlement2';
                    acc.CAM_Owner__c  = userInfo.getuserId();
            insert acc;
            
            Contact con = new Contact(
                    FirstName = 'Tes1t',
                    LAstName = 'Test',
                    Email = 'test@test.com',
                    Accountid =  acc.id   
                );
            insert con;
           
            Entitlement ent4 = new Entitlement();
                        ent4.AccountId = acc.id;
                        //ent4.Asset = as2;
                        ent4.Name = 'Test Entitlement54321';
                        ent4.EndDate = System.Now().Date().addDays(90);
                        ent4.StartDate = System.Now().Date().addDays(-90);
                        ent4.AccountId = acc.Id;
                        ent4.Type = 'Business';
                        ent4.AssignedSupportPOC__c = newUSer.id;
                        insert ent4;
                        
                       
                        
                        Authorized_Contact__c authCon = new Authorized_Contact__c(
                            /*Customer_Admin__c = true,*/ contact__c = con.id, Entitlement__c = ent4.id,Email_read__c =false
                        ); 
                        insert authCon;
                        authCon.Email_read__c = true;
                        update authCon;
                        system.debug('ppp'+authCon.Entitlement__c +'ppp'+authCon.Entitlement__r.AssignedSupportPOC__c);
                        authCon.Video_Seen__c = true;
                        update authCon;
                        authCon.First_Reminder_Req__c =true;
                        authCon.Customer_Admin__c =false;
                        update authcon;
                        authCon.Second_Reminder_Req__c = true;
                        authCon.Customer_Admin__c =true;
                        update authCon;
          
   }

}