/* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
********************************************************************************************************************* */
@isTest(SeeAllData=True)
public class Marketo_CasetoAccountUpdate_Test{


     public static testmethod void testWelcome() {
      Contact c1 = new Contact(lastName ='Name');
      insert c1;
      
      //User u1 = new User(LastName='Usr1');
     // insert u1;
        List<Account> lstac = new List<Account>();
        Account a1 = new Account (Name = 'Acc123',Customer_Lifecycle_Stage__c='New');
        lstac.add(a1);
        
        Account a2 = new Account (Name = 'Acc123',Customer_Lifecycle_Stage__c='In Production');
        lstac.add(a2);
        
        Account a3 = new Account (Name = 'Acc123',Customer_Lifecycle_Stage__c='Onboarding');
        lstac.add(a3);
        
        insert lstac;
        Case tempCase = new case(Origin='Web',ContactId = c1.Id, AccountId = a1.Id, subject='Test Case',description='asd',Problem_Type__c='Community',Category__c='General Questions',Priority='P3',Status = 'Awaiting Customer Input');        
        System.Debug('Case at time of creation'+tempCase);
        insert tempCase;  
  
        Profile p = [select Id,name from Profile where UserType = 'Standard' limit 1];
        User u1 = createTestUser(p.Id, 'testUser', 'Mkto', 'cfsId') ;
        insert u1;
        
        /*User u2 = createTestUser(p.Id, 'testUse2r', 'Mk2to', 'cfsId') ;
        insert u2;*/
        
        
		/* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
		
        clzV5__Clarizen_Resource__c cr = new clzV5__Clarizen_Resource__c(clzV5__CLZ_Email__c= u1.email);
        insert cr;
        
        List<clzV5__Clarizen_Project__c> lstcp = new List<clzV5__Clarizen_Project__c>();
        clzV5__Clarizen_Project__c cp1 = new clzV5__Clarizen_Project__c (clzV5__CLZ_ProjectType__c ='ACC',CLZ_C_ProjectState__c='Active',clzV5__CLZ_Customer__c =a1.Id,clzV5__CLZ_State__c='Active');
        lstcp.add(cp1);
        clzV5__Clarizen_Project__c cp2 = new clzV5__Clarizen_Project__c (clzV5__CLZ_ProjectType__c ='ACC',CLZ_C_ProjectState__c='Expired',clzV5__CLZ_Customer__c =a1.Id,clzV5__CLZ_State__c='Active');
        lstcp.add(cp2);
        clzV5__Clarizen_Project__c cp3 = new clzV5__Clarizen_Project__c (clzV5__CLZ_ProjectType__c ='ACC',CLZ_C_ProjectState__c='Active',clzV5__CLZ_Customer__c =a2.Id,clzV5__CLZ_State__c='Active');
        lstcp.add(cp3);
        clzV5__Clarizen_Project__c cp4 = new clzV5__Clarizen_Project__c (clzV5__CLZ_ProjectType__c ='ACC',CLZ_C_ProjectState__c='Active',clzV5__CLZ_Customer__c =a3.Id,clzV5__CLZ_State__c='Active');
        lstcp.add(cp4);
        clzV5__Clarizen_Project__c cp5 = new clzV5__Clarizen_Project__c (clzV5__CLZ_ProjectType__c ='OPPTY',CLZ_C_ProjectState__c='Active',clzV5__CLZ_Customer__c =a3.Id,clzV5__CLZ_State__c='Active');
        lstcp.add(cp5);
        
        insert lstcp;
        
        clzV5__Clarizen_Project__c cp6 = new clzV5__Clarizen_Project__c (clzV5__CLZ_Parent__c= cp5.clzV5__Clarizen_ID__c);
        insert cp6;
        
        List<clzV5__Clarizen_Project__c> cpUp = [SELECT Id,CLZ_C_ProjectState__c,clzV5__CLZ_Customer__c,clzV5__Clarizen_ID__c,Fillout_Form_Count_Avg_Last_26_Weeks__c from clzV5__Clarizen_Project__c where Id=:cp2.Id or clzV5__Clarizen_ID__c=:cp5.clzV5__Clarizen_ID__c];
        
        List<clzV5__Clarizen_Project__c> update2clz = new List<clzV5__Clarizen_Project__c>();
        
        for(clzV5__Clarizen_Project__c cccpp : cpUp){
            cccpp.CLZ_C_ProjectState__c = 'Active';
            cccpp.clzV5__CLZ_State__c = 'Cancelled';
            cccpp.Fillout_Form_Count_Avg_Last_26_Weeks__c=123;
            update2clz.add(cccpp);
        }
        update update2clz;
        ********************************************************************************************************************* */
        /*Clz_Project_Manager_Team__c cmm = new Clz_Project_Manager_Team__c(Related_User__c = u2.id,Team_Member__c=cr.Id);
        insert cmm;*/
     }
     
     
     public static testmethod void testWelcome2() {
      Contact c1 = new Contact(lastName ='Name');
      insert c1;
      
      //User u1 = new User(LastName='Usr1');
     // insert u1;
        List<Account> lstac = new List<Account>();
        Account a1 = new Account (Name = 'Acc123',Customer_Lifecycle_Stage__c='New');
        lstac.add(a1);
        
        Account a2 = new Account (Name = 'Acc123',Customer_Lifecycle_Stage__c='In Production');
        lstac.add(a2);
        
        Account a3 = new Account (Name = 'Acc123',Customer_Lifecycle_Stage__c='Onboarding');
        lstac.add(a3);
        
        insert lstac;
        Case tempCase = new case(Origin='Web',ContactId = c1.Id, AccountId = a1.Id, subject='Test Case',description='asd',Problem_Type__c='Community',Category__c='General Questions',Priority='P3',Status = 'Awaiting Customer Input');        
        System.Debug('Case at time of creation'+tempCase);
        insert tempCase;  
  
        Profile p = [select Id,name from Profile where UserType = 'Standard' limit 1];
        User u1 = createTestUser(p.Id, 'testUser', 'Mkto', 'cfsId') ;
        insert u1;
        
        /*User u2 = createTestUser(p.Id, 'testUse2r', 'Mk2to', 'cfsId') ;
        insert u2;*/
        
		/* ********************************************************************************************************************
		Last Modified By - Jade Global Inc, on 11th Feb 2018
		Purpose          - As part of Clarizen Decomissioning we have commented clarizen fields and its reference
		
        
        clzV5__Clarizen_Resource__c cr = new clzV5__Clarizen_Resource__c(clzV5__CLZ_Email__c= u1.email);
        insert cr;
        
        List<clzV5__Clarizen_Project__c> lstcp = new List<clzV5__Clarizen_Project__c>();
        clzV5__Clarizen_Project__c cp1 = new clzV5__Clarizen_Project__c (clzV5__CLZ_ProjectType__c ='ACC',clzV5__CLZ_Customer__c =a1.Id,clzV5__CLZ_State__c='Draft');
        lstcp.add(cp1);
        clzV5__Clarizen_Project__c cp2 = new clzV5__Clarizen_Project__c (clzV5__CLZ_ProjectType__c ='ACC',clzV5__CLZ_Customer__c =a1.Id,clzV5__CLZ_State__c='Draft');
        lstcp.add(cp2);
        clzV5__Clarizen_Project__c cp3 = new clzV5__Clarizen_Project__c (clzV5__CLZ_ProjectType__c ='ACC',clzV5__CLZ_Customer__c =a2.Id,clzV5__CLZ_State__c='Draft');
        lstcp.add(cp3);
        clzV5__Clarizen_Project__c cp4 = new clzV5__Clarizen_Project__c (clzV5__CLZ_ProjectType__c ='ACC',clzV5__CLZ_Customer__c =a3.Id,clzV5__CLZ_State__c='Draft');
        lstcp.add(cp4);
        clzV5__Clarizen_Project__c cp5 = new clzV5__Clarizen_Project__c (clzV5__CLZ_ProjectType__c ='OPPTY',clzV5__CLZ_Customer__c =a3.Id,clzV5__CLZ_State__c='Draft');
        lstcp.add(cp5);
        
        insert lstcp;
        
        clzV5__Clarizen_Project__c cp6 = new clzV5__Clarizen_Project__c (clzV5__CLZ_Parent__c= cp5.clzV5__Clarizen_ID__c);
        insert cp6;
        
        List<clzV5__Clarizen_Project__c> cpUp = [SELECT Id,CLZ_C_ProjectState__c,clzV5__CLZ_Customer__c,clzV5__Clarizen_ID__c,Fillout_Form_Count_Avg_Last_26_Weeks__c from clzV5__Clarizen_Project__c where Id=:cp2.Id or clzV5__Clarizen_ID__c=:cp5.clzV5__Clarizen_ID__c];
        
        List<clzV5__Clarizen_Project__c> update2clz = new List<clzV5__Clarizen_Project__c>();
        
        for(clzV5__Clarizen_Project__c cccpp : cpUp){
            cccpp.CLZ_C_ProjectState__c = 'Active';
            cccpp.clzV5__CLZ_State__c = 'Completed';
            cccpp.Fillout_Form_Count_Avg_Last_26_Weeks__c=123;
            update2clz.add(cccpp);
        }
        update update2clz;
        
		********************************************************************************************************************* */
        /*Clz_Project_Manager_Team__c cmm = new Clz_Project_Manager_Team__c(Related_User__c = u2.id,Team_Member__c=cr.Id);
        insert cmm;*/
     }
     
      public static User createTestUser(String ProfId, string fName, String lName, String cfsId) {
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User tuser = new User(  firstname = fName,
                                    lastName = lName,
                                    email = uniqueName + '@test' + orgId + '.org',
                                    Username = uniqueName + '@test' + orgId + '.org',
                                    EmailEncodingKey = 'ISO-8859-1',
                                    Alias = uniqueName.substring(18, 23),
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    LocaleSidKey = 'en_US',
                                    LanguageLocaleKey = 'en_US',
                                    ProfileId = profId,
                                    lmscons__Cornerstone_ID__c = 'cfsId'
                                    );
            return tuser;
    } 
    
  /* public static void Clz_Project_Manager_Team() {
        Profile p = [select Id,name from Profile where UserType = 'Standard' limit 1];
        User u2 = createTestUser(p.Id, 'testUser', 'Mkto', 'cfsId') ;
        insert u2;
        clzV5__Clarizen_Resource__c cr = new clzV5__Clarizen_Resource__c(clzV5__CLZ_Email__c= u2.email);
        insert cr;
         
    }*/
    
        
}