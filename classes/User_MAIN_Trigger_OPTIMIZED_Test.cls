/**-----
- TEST CODE WRITTEN BY GRAZITTI
- GOAL: TO COVER THE NEW OPTIMIZED TRIGGER ON USER.
----**/
@isTest(SeeAllData=true)
public class User_MAIN_Trigger_OPTIMIZED_Test{
   static testMethod void InsertUser123(){ 
        List<User> userList = New List<User>([SELECT Id,Contactid,TimeZoneSidKey FROM User WHERE isPortalEnabled = true and ManagerId != NULL and Contactid!=null  LIMIT 1]); 
        if(!userList.isEmpty()){
           userList[0].Munchkin_ID__c = 'abdc_123';
           userList[0].TimeZoneSidKey =  userList[0].TimeZoneSidKey !='Europe/Brussels'?'Europe/Brussels':'Europe/Paris';           
           userList[0].ManagerId = UserInfo.getUserId();
           update userList[0];
        }
        
   }
   
   static testMethod void InsertUser124(){ 
        //List<contact> conList = [select id from contact where Customer_Portal_User__c = true  and Is_Authorized_Contact__c = 'Yes' and Account.Type != 'Ex-Customer' limit 1];
        Profile p = [select Id,name from Profile where UserType = 'Standard' limit 1];
        User newUser2 =  Utility.createTestUser(p.id, 'Test12', 'User12', 'cfs2Id');
        insert newUser2; 
         
       //newUser2.ManagerId = UserInfo.getUserId();
        newUser2.ManagerId = userinfo.getuserid();
        update newUser2;
        //system.debug('>>>>>>>>>>>>>>>>>Manger_Activity_Log__c'+[select id,TseName__c from Manger_Activity_Log__c where TseName__c =:newUser2.id ]+'newUser3 '+newUser3.id);
        //newUser2.ManagerId= newUser3.id;
        //update newUser2;
   
   }
    static testMethod void testManger_Activity_Log(){ 
        Profile p = [select Id,name from Profile where UserType = 'Standard' limit 1];
        User newUser1 =  Utility.createTestUser(p.id, 'Test12', 'User12', 'cfs2Id');
        insert newUser1; 
        User newUser2 = new User(  firstname = 'testfName',
                                    lastName = 'testlName',
                                    email = 'uniqueName' + '@test' + UserInfo.getOrganizationId()+'.org',
                                    Username = 'uniqueName' + '@test' + UserInfo.getOrganizationId()+ '.org',
                                    EmailEncodingKey = 'ISO-8859-1',
                                    Alias = 'unique',
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    LocaleSidKey = 'en_US',
                                    LanguageLocaleKey = 'en_US',
                                    ProfileId = p.id,
                                    managerid=userinfo.getuserid()
                                    );
        insert newUser2;
        
        Manger_Activity_Log__c tempManObj = new Manger_Activity_Log__c();
        tempManObj.SupportManager__c = userinfo.getuserid();
        tempManObj.TseName__c = newUser2.Id;
        tempManObj.Evaluation_Started__c = date.newinstance(System.now().year(), System.now().month(), System.now().day());
        tempManObj.Evaluation_Ended__c = tempManObj.Evaluation_Started__c.addDays(30);
        tempManObj.Status__c = 'Completed';
        tempManObj.Status_Changed_For_Manager_Activity_Log__c = true;
        insert tempManObj;
        
        newUser2.managerid=newUser1.id;
        update newUser2;
    
    }
    static testMethod void InsertUser(){ 
    

        
        User usr1 = new User(Id= UserInfo.getUserId());
        usr1.TimeZoneSidKey =  usr1.TimeZoneSidKey !='Europe/Brussels'?'Europe/Brussels':'Europe/Paris'; 
        update usr1;

        //WILL REMOVE FUTHER
        User_Trigger_MAIN_Helper.usersIdsToAddToCyberU.add(usr1.Id);
        User_Trigger_MAIN_Helper.supportEngineerWithManager.put(usr1.Id, usr1);
        User_Trigger_MAIN_Helper.UpdateManagerOfSupportEngineer();
        
        try{
            User newUser_new =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser', 'Mkto', 'cfsId');
            insert newUser_new;
            
            User newUser2 =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'Test12', 'User12', 'cfs2Id');
            newUser2.ManagerId = newUser_new.Id;
            insert newUSer2;
            newUSer2.ManagerId = userInfo.getUserId();
            update newUSer2;      
        }catch(Exception e){
        
        }
        
    }
static testMethod void InsertUser2(){ 
List<User> newUserList = new List<User>([Select Id From USER Where UserRole.Name = 'CEO']);
if(!newUserList.isEmpty()){
update newUserList;
}
}



}