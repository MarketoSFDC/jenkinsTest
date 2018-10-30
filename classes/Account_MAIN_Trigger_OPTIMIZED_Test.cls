@isTest()
/**************************************************************
last modified by : Sumit Bhatt, Grazitti Interactive
last Modified Date : 13-April-2018
changes done: #APPS-10924# Remove functionality that is not needed for Account Score
Tracking : One can track the changes by searching the ticket number in the code 
**************************************************************/
public class Account_MAIN_Trigger_OPTIMIZED_Test{
    
       @testSetup static void InsertAccountMethod(){
       lmscons__Disable_triggers__c ldt = new lmscons__Disable_triggers__c();
       ldt.Name = 'OpportunityTriggerManagement';
       ldt.lmscons__After_Delete__c = true;
       ldt.lmscons__After_Insert__c = true;
       ldt.lmscons__After_Update__c = true;
       ldt.lmscons__Before_Delete__c = true;
       ldt.lmscons__Before_Insert__c = true;
       ldt.lmscons__Before_Update__c = true;
       insert ldt;
       System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt);
       lmscons__Disable_triggers__c ldt2 = new lmscons__Disable_triggers__c();
       ldt2.Name = 'AccountTriggerManagement';
       ldt2.lmscons__After_Delete__c = true;
       ldt2.lmscons__After_Insert__c = true;
       ldt2.lmscons__After_Update__c = true;
       ldt2.lmscons__Before_Delete__c = true;
       ldt2.lmscons__Before_Insert__c = true;
       ldt2.lmscons__Before_Update__c = true;
       insert ldt2;
       
       /*AccountScorerSettings__c accScoreer = new AccountScorerSettings__c();
             accScoreer.Name = 'executionsetting';
             accScoreer.exceutionMode__c = 'create';
             accScoreer.Disable_Account_Score_Trigger__c= true;
             accScoreer.settingsMode__c='off';
             accScoreer.triggerMode__c = 'on'; 
             insert accScoreer;*/
       
       System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt2);
              SalesTriggersUtility.Setvaluesfortest();
             //SalesTriggersUtility.marketoTriggerManager.Activate_Legacy_Triggers__c = False;
                List<Account> lstAccount = new List<Account>();
                List<Account> accdel     = new List<Account>();
                List<Account> updateAcc  = new List<Account>();

                User newUser =  Utility.createTestUser(Label.SystemAdmin_Profile_Id, 'testUser', 'Mkto', 'cfsId');
                insert newUSer;
                
                Account acct = new Account();
                    acct.Name = 'TestAccounterOptimised';
                    acct.Sales_Region__c      = 'North America';
                    acct.CAM_Owner__c = newUser.Id;
                    acct.CAM_Group__c = 'AMER-SB+L60K';
               //     acct.CAM_Assign_Status__c = 'Pending CAM Group Assignment';
                insert acct; 
                
                delete acct;
                
                Account acct1 = new Account();
                    acct1.Name = 'TestAccounterOptimised';
                    acct1.Sales_Region__c      = 'North America';
                    acct1.CAM_Owner__c = newUser.Id;
                    acct1.CAM_Group__c = 'AMER-SB+L60K';
                    acct1.CAM_Assign_Status__c = 'Pending CAM Owner Assignment';
                insert acct1; 
                
                updateAcc.add(acct1);
                accdel.add(acct1);
                
                Account acct2 = new Account();
                    acct2.parentid=acct1.id;
                    acct2.Name = 'TestAccounterOptimisedone';
                    acct2.Sales_Region__c      = 'North America';
                    acct2.CAM_Owner__c = newUser.Id;
                    acct2.CAM_Group__c = 'AMER-SB+L60K';
                    system.debug('@@@@@@ccccooouuunnnnt==='+ acct2.id);
                insert acct2;
                
                updateAcc.add(acct2);
                accdel.add(acct2);
                
                update updateAcc;
                delete accdel;
                
                Account accParent = new Account();
                    accParent.Name = 'TestAccountParentMainTriggerOptimisedtwo';
                    accParent.Sales_Region__c      = 'North America';
                    accParent.CAM_Owner__c = newUser.Id;
                    accParent.CAM_Group__c = 'AMER-SB+L60K';
                    accParent.Date_Became_a_Customer__c = System.Now().Date().addDays(-10);
                    accParent.CSM_Trigger__c = 'Standard';
                    
                lstAccount.add(accParent);
                
                Account accChild = new Account();
                    accChild.Name = 'TestAccountChildMainTriggerOptimised';
                    accChild.Sales_Region__c      = 'North America';
                    accChild.CAM_Owner__c = newUser.Id;
                    accChild.CAM_Group__c = 'AMER-SB+L60K';
                    accChild.ParentId = accParent.Id;
                    accChild.Date_Became_a_Customer__c = System.Now().Date().addDays(-10);
                    accChild.CSM_Trigger__c = 'Enterprise';
                    
                lstAccount.add(accChild);
                
                Account acc = new Account();
                    acc.Name = 'TestAccountMainTriggerOptimised';
                    acc.Sales_Region__c      = 'North America';
                    acc.Business_Unit__c     = 'AMER-SB';
                    acc.BillingCity          = 'NewYork';
                    acc.BillingCountry       = 'United States';
                    acc.BillingStreet        = 'Test Street';
                    acc.BillingState         = 'Test Billing State';
                    acc.BillingPostalCode    = '12345';
                    acc.ShippingCity         = 'Chandigarh';
                    acc.ShippingCountry      = 'India';
                    acc.ShippingPostalCode   = '12345';
                    acc.ShippingState        = '';
                    acc.ShippingStreet       = 'Test Shipping Street';
                    acc.type                 = 'Prospect';
                    //acc.CRM_System__c = 'Microsoft CRM 2011';
                    acc.Current_MRM_MA_Solution__c = 'Unica';
                    acc.Global_Number_of_Employees__c = 1500;
                    acc.Phone = '+1140899900';
                    acc.Current_ESP_Solution__c ='MailChimp';
                    acc.SicDesc ='Custom Computer Programming Services';
                    acc.Intacct_Account_Payable_Status__c = 'Test';
                    acc.Partner_Type__c = 'Agency'; 
                    acc.CSM_Trigger__c = 'Elite/Key';
                    acc.Date_Became_a_Customer__c = System.Now().Date().addDays(-10);
                   
                    
                lstAccount.add(acc);
                
                Account accounts = new Account();
                    accounts.Name = 'TestAccountMainTrigger2Optimised';
                    accounts.CSM_Trigger__c = 'Enterprise';
                    
                insert accounts;
                
                Account accounts2 = new Account();
                    accounts2.Name = 'TestAccountMainTrigger3Optimised';
                    accounts2.CSM_Trigger__c = 'Standard';
                    
                insert accounts2;
                
                insert lstAccount;
                //insert acc;
                
                List<Contact>  lstContacts = new List<Contact>();
                Contact con = new Contact();
                    con.LastName = 'TestConOptimised1';
                    con.AccountId = acc.Id;
                    con.email ='Test@test.com';
                    //con.LS_Deal_Score__c = 55;
                    con.LS_Account_Score__c  = 66;
                lstContacts.add(con);
                //insert con;
                
                Contact con2 = new Contact();
                    con2.LastName = 'TestCon2Optimised1';
                    con2.email ='Test2@test.com';
                    con2.AccountId = acc.Id;
                    //con2.LS_Deal_Score__c = 77;
                    con2.LS_Account_Score__c = 88;
                lstContacts.add(con2);
                //insert con2;
                insert lstContacts;
                
                Opportunity opp1 = new Opportunity();
                    opp1.Name = 'TestOpportunityOptimiesed';
                    opp1.AccountId = acc.Id;
                    opp1.Payment_Frequency__c = 'Annually';
                    opp1.StageName = 'Closed Won';
                    opp1.Owner_Role_Mapping__c = newUser.Id;
                    opp1.CloseDate = System.Now().Date().addDays(-10);
                    opp1.Deal_Type__c = 'Services';
                    opp1.Rep_Create_ARR__c = 1;
                insert opp1;
                
                
                /*
        for(Account acc23 : lstAccount){
                    Account_MainTriggerHelper.createTaslTrigger(acc23);
                }
        */
                Account_MainTriggerHelper.retrievePartiallyUpdatedAccount(accounts2);
                Account_MainTriggerHelper.ACCOUNT_MASTER_LIST.put(accounts2.Id, accounts2);
           }
           static testmethod void TestingAccountMethod(){
        lmscons__Disable_triggers__c ldt = new lmscons__Disable_triggers__c();
       ldt.Name = 'OpportunityTriggerManagement';
       ldt.lmscons__After_Delete__c = true;
       ldt.lmscons__After_Insert__c = true;
       ldt.lmscons__After_Update__c = true;
       ldt.lmscons__Before_Delete__c = true;
       ldt.lmscons__Before_Insert__c = true;
       ldt.lmscons__Before_Update__c = true;
       insert ldt;
       System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt);
       lmscons__Disable_triggers__c ldt2 = new lmscons__Disable_triggers__c();
       ldt2.Name = 'AccountTriggerManagement';
       ldt2.lmscons__After_Delete__c = true;
       ldt2.lmscons__After_Insert__c = true;
       ldt2.lmscons__After_Update__c = true;
       ldt2.lmscons__Before_Delete__c = true;
       ldt2.lmscons__Before_Insert__c = true;
       ldt2.lmscons__Before_Update__c = true;
       insert ldt2;
       
        /*AccountScorerSettings__c accScoreer = new AccountScorerSettings__c();
             accScoreer.Name = 'executionsetting';
             accScoreer.exceutionMode__c = 'create';
             accScoreer.Disable_Account_Score_Trigger__c= true;
             accScoreer.settingsMode__c='off';
             accScoreer.triggerMode__c = 'on'; 
             insert accScoreer;*/
       
       System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt2);
                SalesTriggersUtility.Setvaluesfortest();
                //SalesTriggersUtility.marketoTriggerManager.Activate_Legacy_Triggers__c = False;
                List<Account> accUpdate = new List<Account>();
                List<Account> accList = new List<Account>([SELECT Id, Name,Engagement_Mgr_Owner__c,SDR_Owner_Picklist__c,Partner_Type__c,CAM_Owner__c,LS_Deal_Score__c,LS_Account_Score__c,Datanyze_Website_History__c,MLM_Edition__c,type,Date_Became_a_Customer__c,Customer_Number__c,CSM_Trigger__c,/*Customer_Success_Manager__c,CRM_System__c,*/Current_MRM_MA_Solution__c,BillingCity,BillingCountry,BillingStreet,BillingState,BillingPostalCode,Global_Number_of_Employees__c,Phone, Current_ESP_Solution__c,SicDesc FROM Account WHERE Name like
                'TestAccountMainTriggerOptimised%']);
                
                List<Account> accNewList = new List<Account>([SELECT Id,Date_Became_a_Customer__c,CSM_Trigger__c/*,Customer_Success_Manager__c*/ FROM Account WHERE Name like 'TestAccountMainTrigger2Optimised%']);
                
                List<Account> accNewList2 = new List<Account>([SELECT Id,Date_Became_a_Customer__c,CSM_Trigger__c/*,Customer_Success_Manager__c*/ FROM Account WHERE Name like 'TestAccountMainTrigger3Optimised%']);
                
                //List<Account> nwUpdatList = new List<Account>();
                
                List<Opportunity> opp = new List<Opportunity>([SELECT id from Opportunity where Name Like 'TestOpportunityOptimiesed%']);
                List<Opportunity> ops = new List<Opportunity>();
                List<User> newUsers = new List<User>([SELECT Id FROM User WHERE Name='testUser' LIMIT 1]);
                User newUser;
                if(!newUsers.isEmpty()){ newUser = newUsers[0];}else{return;}
                for(Account acc : accList){
                    acc.SDR_Owner_Picklist__c = 'Aoife Hoare';
                    acc.CAM_Owner__c = newUser.Id;
                    acc.LS_Deal_Score__c = 33;
                    acc.LS_Account_Score__c = 44;
                    acc.Datanyze_Website_History__c = 'December 12, 2015';
                    acc.MLM_Edition__c = 'Enterprise';
                    acc.type = 'Customer';
                    acc.Date_Became_a_Customer__c = System.Now().Date().addDays(-10);
                    acc.Customer_Number__c = 5500;
                    acc.CSM_Trigger__c = 'Elite/Key';
                    //acc.Customer_Success_Manager__c = newUser.Id;
                    //acc.CRM_System__c = 'Salesforce';
                    acc.Current_MRM_MA_Solution__c = 'Eloqua';
                    acc.Global_Number_of_Employees__c = 0;
                    acc.Phone = '40899900';
                    acc.Current_ESP_Solution__c ='Lyris';
                    acc.SicDesc ='Custom Computer Programming Services';
                    acc.Partner_Type__c = 'Agency';
                    acc.Engagement_Mgr_Owner__c =newUser.Id;
                    acc.BillingCity          = 'NewYork';
                    acc.BillingCountry       = 'United States';
                    acc.BillingStreet        = 'Test Street';
                    acc.BillingState         = 'Test Billing State';
                    acc.BillingPostalCode    = '12345';
                    acc.ShippingCity         = 'Chandigarh';
                    acc.ShippingCountry      = 'India';
                    acc.ShippingPostalCode   = '12345';
                    acc.ShippingState        = '';
                    acc.ShippingStreet       = 'Test Shipping Street';
                    acc.Customer_Lifecycle_Stage__c = 'Lost';
                    
                    accUpdate.add(acc);
                }
                //update accUpdate;
                
                for(Account acc : accNewList){
                    acc.CSM_Trigger__c = 'Enterprise';
                    //acc.Customer_Success_Manager__c = newUser.Id;
                    acc.Date_Became_a_Customer__c = System.Now().Date().addDays(-10);
                    accUpdate.add(acc);
                }
                
                for(Account acc : accNewList2){
                    acc.CSM_Trigger__c = 'Standard';
                    //acc.Customer_Success_Manager__c = newUser.Id;
                    acc.Date_Became_a_Customer__c = System.Now().Date().addDays(-10);
                    accUpdate.add(acc);
                }
                
                update accUpdate;
                
                
                for(Opportunity o : opp){
                    User u = new User(Id =newUser.Id);
                    o.Owner = u;
                    ops.add(o);
                }
                update ops;
                
                
                
              
                Account acc23 = new Account();
                acc23.Type = 'Customer';
                acc23.MLM_edition__c = 'Professional';
                insert acc23;
                Set<Id> accIDs = new Set<ID>();
                accIDs.add(acc23.ID);

                Contact con = new Contact();
                        con.LastName   = 'GRAZITTI 2345';
                        con.email      = 'test@test.com';
                        con.LeadSource = 'Blog';
                        con.AccountId  = acc23.Id;
                insert con;
                
                User usr = Utility.insertCustomerPortalUser(con.Id);
                insert usr;
                //Account_MainTriggerHelper.updateUserEditionType(accIDs);
                Account_MainTriggerHelper.retrievePartiallyUpdatedAccount(acc23);
                update acc23;
                

           }
           
static testmethod void TestingAccountMethod3() {
       lmscons__Disable_triggers__c ldt = new lmscons__Disable_triggers__c();
       ldt.Name = 'OpportunityTriggerManagement';
       ldt.lmscons__After_Delete__c = true;
       ldt.lmscons__After_Insert__c = true;
       ldt.lmscons__After_Update__c = true;
       ldt.lmscons__Before_Delete__c = true;
       ldt.lmscons__Before_Insert__c = true;
       ldt.lmscons__Before_Update__c = true;
       insert ldt;
       System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt);
       lmscons__Disable_triggers__c ldt2 = new lmscons__Disable_triggers__c();
       ldt2.Name = 'AccountTriggerManagement';
       ldt2.lmscons__After_Delete__c = true;
       ldt2.lmscons__After_Insert__c = true;
       ldt2.lmscons__After_Update__c = true;
       ldt2.lmscons__Before_Delete__c = true;
       ldt2.lmscons__Before_Insert__c = true;
       ldt2.lmscons__Before_Update__c = true;
       insert ldt2;
       
        /*AccountScorerSettings__c accScoreer = new AccountScorerSettings__c();
             accScoreer.Name = 'executionsetting';
             accScoreer.exceutionMode__c = 'create';
             accScoreer.Disable_Account_Score_Trigger__c= false;
             accScoreer.settingsMode__c='off';
             accScoreer.triggerMode__c = 'on'; 
             insert accScoreer;
             
        Account_Scoring_Rule_States__c asrs=new Account_Scoring_Rule_States__c ();
            asrs.state_name__c='Country not USA + Canada + Top 13 EMEA';
            asrs.Rule_Name__c='Country is not USA, Canada, or top 13 EMEA countries';
            asrs.Score__c=-40;
            asrs.Rule_Group__c='Rule Group 3';
            asrs.Name='Rule 13';
           // asrs.Rule_Data__c='United States,United States of America,US,USA,U.S.,U.S.A., Canada,CA,Israel,Netherlands, Sweden,Belgium,Finland,Spain, Switzerland,Ireland,Germany, France,United Kingdom,Norway, South Africa,IL,NL,SE,BE,FI,ES,CH, IE,DE,FR,DE,UK,NO,ZA';
            insert asrs;*/
       
       System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt2);
       account aacc=new account();
       aacc.name='account1';
       insert aacc;
               Account acc23 = new Account();
                //acc23.Type = 'Customer';
                acc23.Name= 'Test Account';
                acc23.MLM_edition__c = 'Professional';
                acc23.Current_ESP_Solution__c = 'AgilOne';
                acc23.datanyze_website_history__c='December 15, 2016';
                acc23.parentid=aacc.id;
                acc23.CAM_Assign_Status__c = 'Pending CAM Group Assignment';
                acc23.BillingCountry = 'India';
               insert acc23;                
    
                Set<Id> accIDs = new Set<ID>();
                accIDs.add(acc23.ID);

                Contact con = new Contact();
                        con.LastName   = 'GRAZITTI 2345';
                        con.email      = 'test@test.com';
                        con.LeadSource = 'Blog';
                        con.AccountId  = acc23.Id;
                insert con;
                
                //User usr = Utility.insertCustomerPortalUser(con.Id);
                //insert usr;
                //Account_MainTriggerHelper.updateUserEditionType(accIDs);
                Account_MainTriggerHelper.retrievePartiallyUpdatedAccount(acc23);
                acc23.CAM_Owner__c = UserInfo.getUserId();
                acc23.Current_ESP_Solution__c = 'Bronto';
                acc23.Current_MRM_MA_Solution__c= 'Bislr';
                //acc23.CRM_System__c = 'Microsoft CRM 2011';
                acc23.Current_MRM_MA_Solution__c ='Autopilot';
                acc23.Phone = '123456';
                //acc23.Competes_with_Current_Marketo_Customer__c ='Tst1';
                acc23.SicDesc = 'Sic 1';
                acc23.Datanyze_Website_History__c = 'October 5, 2017';
                    
                Account_MainTriggerHelper.alertDatanyzeUpdate(acc23);
                Account aac4 = acc23;
                aac4.Datanyze_Website_History__c = 'October 5, 2017';
                aac4.Current_ESP_Solution__c = 'Delivra';
                aac4.Current_MRM_MA_Solution__c= 'Genius';
                aac4.BillingCountry =   'USA';
                //acc23.CRM_System__c = 'Microsoft CRM 2011';
                acc23.Current_MRM_MA_Solution__c = 'Act-On';
                acc23.Phone = '1235';
                //acc23.Competes_with_Current_Marketo_Customer__c = 'testing 342';
                acc23.SicDesc = 'Sic 2';
                acc23.SDR_Owner_Picklist__c='   Anthony Lee Florez';
                acc23.BillingCountry = 'Australia';
    
                
                update aac4;
            

                //Account_MainTriggerHelper.processAlertDatanyzeUpdate(acc23,aac4);
                update acc23;
                Account_MainTriggerHelper.processAlertDatanyzeUpdate(acc23,aac4);
                Map<Id,Account> accMap = new Map<Id,Account>();
                accMap.put(acc23.Id, acc23);
                Account_MainTriggerHelper.commitAlerDatanyzeProcess(accMap);
                //Account_MainTriggerHelper.isAccountScorerIsQualified(acc23,aac4,False);
        Account_MainTriggerHelper.updateUserEditionType(accMap.keySet());
        Account_MainTriggerHelper.isUpdateUserBadgeTagQualified(acc23,aac4,False);
           }
           
    static testmethod void TestingAccountMethod4() {
           
       lmscons__Disable_triggers__c ldt = new lmscons__Disable_triggers__c();
       ldt.Name = 'OpportunityTriggerManagement';
       ldt.lmscons__After_Delete__c = true;
       ldt.lmscons__After_Insert__c = true;
       ldt.lmscons__After_Update__c = true;
       ldt.lmscons__Before_Delete__c = true;
       ldt.lmscons__Before_Insert__c = true;
       ldt.lmscons__Before_Update__c = true;
       insert ldt;
       System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt);
       lmscons__Disable_triggers__c ldt2 = new lmscons__Disable_triggers__c();
       ldt2.Name = 'AccountTriggerManagement';
       ldt2.lmscons__After_Delete__c = true;
       ldt2.lmscons__After_Insert__c = true;
       ldt2.lmscons__After_Update__c = true;
       ldt2.lmscons__Before_Delete__c = true;
       ldt2.lmscons__Before_Insert__c = true;
       ldt2.lmscons__Before_Update__c = true;
       insert ldt2;
       
       
             
       System.Debug('!!!!!!!!!!!!!!!!!!!!!!!!!!!'+ldt2);
       
       /*Account_Scoring_Rule_States__c asrs=new Account_Scoring_Rule_States__c ();
            asrs.state_name__c='salesforce';
            asrs.Rule_Name__c='CRM System is SFDC';
            asrs.Score__c=30;
            asrs.Rule_Group__c='Rule Group 2';
            asrs.Name='salesforce';
            asrs.Rule_Data__c='United States,United States of America,US,USA,U.S.,U.S.A., Canada,CA,Israel,Netherlands, Sweden,Belgium,Finland,Spain, Switzerland,Ireland,Germany, France,United Kingdom,Norway, South Africa,IL,NL,SE,BE,FI,ES,CH, IE,DE,FR,DE,UK,NO,ZA';
            insert asrs;*/
            
               Account acc23 = new Account();
                //acc23.Type = 'Customer';
                acc23.Name= 'Test Account';
                acc23.MLM_edition__c = 'Professional';
                insert acc23;
                
                
                /*AccountScorerSettings__c accScoreer = new AccountScorerSettings__c();
             accScoreer.Name = 'executionsetting';
             accScoreer.exceutionMode__c = 'create';
             accScoreer.Disable_Account_Score_Trigger__c= false;
             accScoreer.settingsMode__c='off';
             accScoreer.triggerMode__c = 'on'; 
            insert accScoreer;*/
                
                Set<Id> accIDs = new Set<ID>();
                accIDs.add(acc23.ID);

                Contact con = new Contact();
                        con.LastName   = 'GRAZITTI 2345';
                        con.email      = 'test@test.com';
                        con.LeadSource = 'Blog';
                        con.AccountId  = acc23.Id;
                insert con;
                
                //User usr = Utility.insertCustomerPortalUser(con.Id);
                //insert usr;
                //Account_MainTriggerHelper.updateUserEditionType(accIDs);
                
                Map<Id,Account> accMap = new Map<Id,Account>();
                accMap.put(acc23.Id, acc23);
                Account_MainTriggerHelper.commitAlerDatanyzeProcess(accMap);
                Account_MainTriggerHelper.updateContactOwnerAsAccountOwner(accMap.keyset(),accMap);
                
                List<Account> tobeUpdated = new List<Account>();
                List<Account> lstAccNew = [Select Id,Current_ESP_Solution__c,Current_MRM_MA_Solution__c,Datanyze_Website_History__c from Account where Name Like '%TestAccounterOptimised%'];
                
                for(Account acc: lstAccNew){
                    acc.Current_ESP_Solution__c = 'Lyris';
                    acc.Current_MRM_MA_Solution__c ='Drip';
                    acc.Datanyze_Website_History__c='December 15, 2016';
                    tobeUpdated.add(acc);
                }
                        update tobeUpdated;
                }
                
           static testmethod void TestingAccountMethod5(){
                list<account> accontdata = new list<account>();
                list<user> userlist = new list<user>();
                Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
                Id recordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();
                Id UserId1 = UserInfo.getUserId();
                Account ac = new Account();
                ac.name = 'test account 1';
                ac.type = 'Ex-Customer';
                ac.Customer_Lifecycle_Stage__c ='New';
                ac.RecordTypeId = recordTypeId;
                accontdata.add(ac);
                
                account ac2 = new account();
                ac2.name = 'Test account 2';
                ac2.type = 'Ex-Partner';
                ac2.Customer_Lifecycle_Stage__c ='New';
                ac2.RecordTypeId = recordTypeId;
                accontdata.add(ac2);
                
                account ac3 = new account();
                ac3.name = 'Test account 4';
                ac3.type = 'Customer';
                ac3.Customer_Lifecycle_Stage__c ='New';
                ac3.Intacct_Account_Payable_Status__c = 'ABC';
                ac3.RecordTypeId = recordTypeId;
                
               
                accontdata.add(ac3);
                
                list<opportunity> newoplist = new list<opportunity>();
                Opportunity op = new Opportunity();
                op.name = 'Test Opportunity 1';
                op.CloseDate=  Date.newInstance(2017,05,21);
                op.OwnerId = UserId1;
                op.type = 'New Business';
                op.StageName='Closed Won';
                op.Rep_Create_ARR__c = 1000;
                newoplist.add(op);
                insert newoplist;
                
                list<user>useridlist = [SELECT Id,Name,IsActive,Profile.Name,UserRole.Name FROM User where Profile.Name='Sales Development' and IsActive=True limit 4]; 
                account ac4 = new account();
                ac4.name = 'Test account 3';
                ac4.Customer_Lifecycle_Stage__c ='New';
                ac4.Intacct_Account_Payable_Status__c = 'ABC';
                ac4.RecordTypeId = recordTypeId1;
                ac4.SDR_Owner_Lookup__c = useridlist.get(0).id;
                ac4.type = 'Prospect';
                ac4.Partner_Type__c = 'Agency';
                ac4.CAM_Owner__c = useridlist .get(0).id;
                ac4.Engagement_Mgr_Owner__c = useridlist .get(0).id;
                ac4.BillingCountry = 'USA';
                
                accontdata.add(ac4);
                
                insert accontdata;
                
               
                
                list<user> useridlist2 = [SELECT Id,name from user where Profile.Name = 'Customer Support Administrator' and isActive = true limit 1]; 
               
                /*list<account> tobeupdatedlist = [select id,name,type,Partner_Type__c,CAM_Owner__c,Engagement_Mgr_Owner__c,BillingCountry from account where id=: accontdata[3].id ];
                list<account> updateList = new list<Account>();*/
                
                if(!accontdata.isempty()){
                
                
                    accontdata[3].OwnerId=useridlist[1].Id;
                    accontdata[3].SDR_Owner_Lookup__c=useridlist[1].Id;
                    
                    accontdata[1].Partner_Type__c= 'Referral';
                    accontdata[1].CAM_Owner__c = useridlist[1].id;
                    accontdata[1].Engagement_Mgr_Owner__c = useridlist[1].id;
                    accontdata[1].BillingCountry = 'India';
                    
                    }
                
                
                if(!accontdata.isEmpty())
                    update accontdata;
                
                
                accountshare acshare = new accountshare();
                acshare.accountid = accontdata[3].id;
                acshare.AccountAccessLevel = 'Edit';
                //acshare.CaseAccessLevel= 'None';
                acshare.OpportunityAccessLevel= 'Edit';
                //acshare.ContactAccessLevel= 'Edit';
                acshare.UserOrGroupId = useridlist2 [0].id;
                acshare.RowCause = 'Manual';
                insert acshare;
                
                               
                /*accountshare acshare2 = new accountshare();
                acshare2.accountid = accontdata[3].id;
                acshare2.AccountAccessLevel = 'Edit';
                //acshare.CaseAccessLevel= 'None';
                acshare2.OpportunityAccessLevel= 'Edit';
                //acshare.ContactAccessLevel= 'Edit';
                acshare2.UserOrGroupId = useridlist2[0].id;
                acshare2.RowCause = 'Territory';
                insert acshare2;*/
                
               
               //new version of account 
                /*account ac5 = new account();
                ac5.name= 'test account 5';
                ac5.ParentId= acc.id;
                ac5.type= 'Press';
                ac5.RecordTypeId = recordTypeId;
                insert ac5;*/
                //system.debug('**************the list of account inserted*****'+accontdata);
                //system.debug('*************the new instance of account inserted*********'+ac5);
                
                //system.assertEquals(ac5.ParentId,acc.id);
                
                 map<id,id> owneridmap = new map<id,id>();
                   owneridmap.put(ac4.id,op.OwnerId);
                if(owneridmap.get(ac4.id) <> null){
                ac4.New_Business_Account_Executive__c = owneridmap.get(ac4.id);
                }
                update accontdata;
                
                
                
        
        }
    
     static testmethod void TestingAccountMethod6() {
         Id recordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Customer').getRecordTypeId();
         Id recordTypeId1 = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Prospect').getRecordTypeId();

        account ac4 = new account();
         ac4.name = 'Test account 3';
         ac4.Customer_Lifecycle_Stage__c ='New';
         ac4.Intacct_Account_Payable_Status__c = 'ABC';
         ac4.RecordTypeId = recordTypeId1;
         ac4.type = 'Prospect';
         ac4.Partner_Type__c = 'Agency';
         ac4.BillingCountry = 'USA';
         Insert ac4;
     
         account ac5 = new account();
         ac5.name = 'Test account 3';
         ac5.Customer_Lifecycle_Stage__c ='New';
         ac5.Intacct_Account_Payable_Status__c = 'ABC';
         ac5.RecordTypeId = recordTypeId1;
         ac5.type = 'Customer & Partner';
         ac5.Partner_Type__c = 'Referral';
         ac5.BillingCountry = 'Australia';
         ac5.parentId   =   ac4.Id;
         Insert ac5;
         Account_MainTriggerHelper.checkJiveIntegrationCriteria(ac4,ac5);
         ac5.BillingCountry = 'US';
         ac4.BillingCountry = 'Australia';
         Account_MainTriggerHelper.checkJiveIntegrationCriteria(ac4,ac5);
         ac5.BillingCountry = 'US';
         ac4.BillingCountry = 'Bermuda';
         Account_MainTriggerHelper.checkJiveIntegrationCriteria(ac4,ac5);
        
         List<Account> accList  =   new List<Account>();
         List<Account> accList1 =   new List<Account>();
        
         ac4.CAM_Assign_Status__c = 'Pending CAM Group Assignment';
         
         accList.add(ac4);
         Account_MainTriggerHelper.processCAM_assignment(accList);
         ac5.CAM_Assign_Status__c = 'Pending CAM Owner Assignment';
                  
         accList1.add(ac5);
         Account_MainTriggerHelper.processCAM_assignment(accList1);
     }

// Code Written to cover the Line as per the ticket no APPS-20692
public static list<Account> createAccount(String type,string IntacctAccountPayableStatus,string PartnerType, integer noofAcc,string isocode){
     List<Account> listofacc = new List<Account>();
        for(integer i =1;i<= noofAcc;i++){
        Account aa = new Account();
        aa.name = 'TestAccount' + i;        
        aa.Type = type;
        aa.Intacct_Account_Payable_Status__c =  IntacctAccountPayableStatus;
        aa.Partner_Type__c  = PartnerType;
        aa.CurrencyIsoCode = isocode;
        listofacc.add(aa);
        }
        return listofacc;
        
    }
     static testmethod void TestingAccountMethod8() {
     List<account> insertAccount = new list<Account>();
    List<account> acc = createAccount('Partner','Test','Agency',50,'AUD');
    //01250000000ULbM id for Account partner record Type 
    acc[0].RecordTypeid = '01250000000ULbM';
    acc[0].BillingCountry = 'Australia';
    acc[0].NumberOfEmployees = 2000;
    insertAccount.add(acc[0]);
    
    acc[1].RecordTypeid = '01250000000ULbM';
    acc[1].BillingCountry = 'USA';
    acc[1].NumberOfEmployees = 2000;
    insertAccount.add(acc[1]);
    
    acc[2].RecordTypeid = '01250000000ULbM';
    acc[2].BillingCountry = 'BD';
    acc[2].NumberOfEmployees = 2000;
    insertAccount.add(acc[2]);
    
    acc[3].RecordTypeid = '01250000000ULbM';
    acc[3].BillingCountry = 'Japan';
    acc[3].NumberOfEmployees = 2000;
    insertAccount.add(acc[3]);
    
    acc[10].RecordTypeid = '01250000000ULbM';
    acc[10].BillingCountry = 'AI';
    acc[10].NumberOfEmployees = 2000;
    insertAccount.add(acc[10]);
    
    acc[11].RecordTypeid = '01250000000ULbM';
    acc[11].BillingCountry = 'NC';
    acc[11].NumberOfEmployees = 2000;
    insertAccount.add(acc[11]);
    
    acc[12].RecordTypeid = '01250000000ULbM';
    acc[12].BillingCountry = 'USA';
    acc[12].NumberOfEmployees = 50;
    insertAccount.add(acc[12]);
    
    acc[13].RecordTypeid = '01250000000ULbM';
    acc[13].BillingCountry = 'BD';
    acc[13].NumberOfEmployees = 50;
    insertAccount.add(acc[13]);
    
    acc[14].RecordTypeid = '01250000000ULbM';
    acc[14].BillingCountry = 'Japan';
    acc[14].NumberOfEmployees = 50;
    insertAccount.add(acc[14]);
    
    acc[15].RecordTypeid = '01250000000ULbM';
    acc[15].BillingCountry = 'Anguilla';
    acc[15].NumberOfEmployees = 50;
    insertAccount.add(acc[15]);
    
    acc[16].RecordTypeid = '01250000000ULbM';
    acc[16].BillingCountry = 'Germany';
    acc[16].NumberOfEmployees = 50;
    insertAccount.add(acc[16]);
    
    // 01250000000ULb7 for Account customer record type
    acc[4].RecordTypeid = '01250000000ULb7';
    acc[4].BillingCountry = 'Australia';
    acc[4].NumberOfEmployees = 502;
    acc[4].Type = 'Customer';
    insertAccount.add(acc[4]);
    
    acc[23].RecordTypeid = '01250000000ULb7';
    acc[23].BillingCountry = 'Australia';
    acc[23].NumberOfEmployees = 1005;
    acc[23].Type = 'Customer';
    insertAccount.add(acc[23]);
    
   
    
    acc[5].RecordTypeid = '01250000000ULb7';
    acc[5].BillingCountry = 'Japan';
    acc[5].NumberOfEmployees = 500;
    acc[5].Type = 'Customer';
    insertAccount.add(acc[5]);
    
    acc[6].RecordTypeid = '01250000000ULb7';
    acc[6].BillingCountry = 'Bangladesh';
    acc[6].NumberOfEmployees = 500;
    acc[6].Type = 'Customer';
    insertAccount.add(acc[6]);
    
    acc[24].RecordTypeid = '01250000000ULb7';
    acc[24].BillingCountry = 'BD';
    acc[24].NumberOfEmployees = 50;
    acc[24].Type = 'Customer';
    insertAccount.add(acc[24]);
    
    acc[25].RecordTypeid = '01250000000ULb7';
    acc[25].BillingCountry = 'BD';
    acc[25].NumberOfEmployees = 0;
    acc[25].Type = 'Customer';
    insertAccount.add(acc[25]);
    
    acc[7].RecordTypeid = '01250000000ULb7';
    acc[7].BillingCountry = 'USA';
    acc[7].NumberOfEmployees = 502;
    acc[7].Type = 'Customer';
    insertAccount.add(acc[7]);
    
    
    
    acc[8].RecordTypeid = '01250000000ULb7';
    acc[8].BillingCountry = 'AI';
    acc[8].NumberOfEmployees = 500;
    acc[8].Type = 'Customer';
    insertAccount.add(acc[8]);
    
    acc[9].RecordTypeid = '01250000000ULb7';
    acc[9].BillingCountry = 'Germany';
    acc[9].NumberOfEmployees = 2000;
    acc[9].Type = 'Customer';
    insertAccount.add(acc[9]);  
    
    acc[17].RecordTypeid = '01250000000ULb7';
    acc[17].BillingCountry = 'AI';
    acc[17].NumberOfEmployees = 2000;
    acc[17].Type = 'Customer';
    insertAccount.add(acc[17]);
    
    acc[18].RecordTypeid = '01250000000ULb7';
    acc[18].BillingCountry = 'BD';
    acc[18].NumberOfEmployees = 2000;
    acc[18].Type = 'Customer';
    insertAccount.add(acc[18]);
    
    acc[19].RecordTypeid = '01250000000ULb7';
    acc[19].BillingCountry = 'Germany';
    acc[19].NumberOfEmployees = 2000;
    acc[19].Type = 'Customer';
    insertAccount.add(acc[19]);
    
    acc[20].RecordTypeid = '01250000000ULb7';
    acc[20].BillingCountry = 'USA';
    acc[20].NumberOfEmployees = 2000;
    acc[20].Type = 'Customer';
    insertAccount.add(acc[20]);
    
    acc[21].RecordTypeid = '01250000000ULb7';
    acc[21].BillingCountry = 'USA';
    acc[21].NumberOfEmployees = 15;
    acc[21].Type = 'Customer';
    insertAccount.add(acc[21]);
    
    acc[22].RecordTypeid = '01250000000ULb7';
    acc[22].BillingCountry = 'USA';
    acc[22].NumberOfEmployees = 400;
    acc[22].Type = 'Customer';
    insertAccount.add(acc[22]);
    
    acc[26].RecordTypeid = '01250000000ULb7';
    acc[26].BillingCountry = 'Germany';
    acc[26].NumberOfEmployees = 200;
    acc[26].Type = 'Customer';
    insertAccount.add(acc[26]);
    
     acc[27].RecordTypeid = '01250000000ULb7';
    acc[27].BillingCountry = 'Germany';
    acc[27].NumberOfEmployees = 0;
    acc[27].Type = 'Customer';
    insertAccount.add(acc[27]);
    
    acc[28].RecordTypeid = '01250000000ULb7';
    acc[28].BillingCountry = 'Australia';
    acc[28].NumberOfEmployees = 10;
    acc[28].Type = 'Customer';
    insertAccount.add(acc[28]);
    
    acc[29].RecordTypeid = '01250000000ULb7';
    acc[29].BillingCountry = 'Australia';
    acc[29].NumberOfEmployees = 10;
    acc[29].Type = 'Customer';
    insertAccount.add(acc[29]);
    
    acc[30].RecordTypeid = '01250000000ULb7';
    acc[30].BillingCountry = 'Japan';
    acc[30].NumberOfEmployees = 300;
    acc[30].Type = 'Customer';
    insertAccount.add(acc[30]);
    
    acc[31].RecordTypeid = '01250000000ULb7';
    acc[31].BillingCountry = 'Japan';
    acc[31].NumberOfEmployees = 300;
    acc[31].Type = 'Customer';
    insertAccount.add(acc[31]);
    
    acc[32].RecordTypeid = '01250000000ULb7';
    acc[32].BillingCountry = 'AI';
    acc[32].NumberOfEmployees = 560;
    acc[32].Type = 'Customer';
    insertAccount.add(acc[32]);
    
    acc[33].RecordTypeid = '01250000000ULb7';
    acc[33].BillingCountry = 'AI';
    acc[33].NumberOfEmployees = 0;
    acc[33].Type = 'Customer';
    insertAccount.add(acc[33]);
    
    if(insertAccount != null){
     insert insertAccount;
    }
    
    
    }
}