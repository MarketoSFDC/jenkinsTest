global class SandboxPostRefresh_AC implements SandboxPostCopy { 
    static List<MetadataService.Metadata> allMetadataList = new List<MetadataService.Metadata>();
    global void runApexClass(SandboxContext context) { 

        //System.debug(context.organizationId()); 

        //System.debug(context.sandboxId()); 

        //System.debug(context.sandboxName()); 
       String sandboxesName = '-Sandbox2';
        
        /**********Turning Off the triggers ***********************************/
        list<Marketo_Trigger_Management__c> mkttrigger = [select id from Marketo_Trigger_Management__c];
        if(mkttrigger!=null && !mkttrigger.isempty()){
            Marketo_Trigger_Management__c marketoTriggerManager=new Marketo_Trigger_Management__c (id=mkttrigger[0].id);
            marketoTriggerManager.Deactivate_Account_Triggers__c= true;
            marketoTriggerManager.Deactivate_Asset_Triggers__c= true;
            marketoTriggerManager.Deactivate_Contact_Triggers__c= true;
            marketoTriggerManager.Deactivate_Contract_Triggers__c= true;
            marketoTriggerManager.Deactivate_Entitlements_Triggers__c= true;
            marketoTriggerManager.Deactivate_Legacy_QLI_Triggers__c= true;
            marketoTriggerManager.Deactivate_Legacy_Quote_Triggers__c= true;
            marketoTriggerManager.Deactivate_OLI_Triggers__c= true;
            marketoTriggerManager.Deactivate_Opportunity_Triggers__c= true;
            marketoTriggerManager.Deactivate_Steelbrick_Quote_Triggers__c= true;
            marketoTriggerManager.Deactivate_Subscription_Triggers__c= true;
            marketoTriggerManager.Deactivate_User_Triggers__c= true;
            marketoTriggerManager.Deactivate_Project_Triggers__c = true;
            marketoTriggerManager.Deactivate_Timecard_Split_Triggers__c = true;
            marketoTriggerManager.Deactivate_Sales_Invoice_Triggers__c = true;
            marketoTriggerManager.Deactivate_Assignment_Triggers__c = true;
            marketoTriggerManager.Deactivate_Milestone_Triggers__c = true;
            update marketoTriggerManager;
        }
        /**********Turning Off the triggers ***********************************/
        
        /********* Remove Intacct credentials from User Record Starts *********/
       
        list<user> userlist=new list<user>();
        for(user u :[select id,Intacct_Company_ID__c  from user where Intacct_Company_ID__c != null]){
         u.Intacct_Company_ID__c =  u.Intacct_Company_ID__c+ 'UAT';
         userlist.add(u);
        }
        update userlist;
        
        /********* Remove Intacct credentials from User Record Ends *********/
        
        /********* Intacct Updation Starts *********/
        
      //  String sandboxesNames = context.sandboxName() == 'Fullcopy' ? 'marketo-sandbox2':'marketo-copy';
      String sandboxesNames = 'UAT';
        List<Intacct_Entity__c> lst  = new List<Intacct_Entity__c>();
        for(Intacct_Entity__c intc : [SELECT Id, Name, Parent_Entity__c FROM Intacct_Entity__c]){
            Intacct_Entity__c ic = new Intacct_Entity__c(id=intc.Id);
            if(intc.Name == 'marketo' && intc.Parent_Entity__c  == 'marketo' ){
                ic.name = sandboxesNames;
                ic.Parent_Entity__c = sandboxesNames;
            }else if(intc.Parent_Entity__c  == 'marketo'){
                ic.Parent_Entity__c = sandboxesNames;
            }
            lst.add(ic);
        }
        update lst;
        
        /********* Intacct Updation Ends *********/
        
       
        /*** Configure CFS Sandbox ***/ 
            list<lmscons__CFS_Config__c> updatecfs = new list<lmscons__CFS_Config__c>();
            for(lmscons__CFS_Config__c cc : [select id,lmscons__Disable_CFS_integration__c,lmscons__Enable_Button__c,lmscons__New_Header__c,lmscons__Secure_Launch_Link__c,lmscons__Service_URL__c,lmscons__Task_Notification__c,lmscons__Use_One_Url__c from lmscons__CFS_Config__c]){
                if(cc!= null){
                cc.lmscons__Enable_Button__c = 'Create Sandbox';
                cc.lmscons__New_Header__c = True;
                cc.lmscons__Service_URL__c = 'https://stg.cfs-api.com/v2/service.svc/';
                cc.lmscons__Use_One_Url__c = True;
                updatecfs.add(cc);
                }
                system.debug(cc);
            }
            if(updatecfs!= null){
            update updatecfs;
            }

        /*** End of Configure CFS Sandbox ***/ 
        
         /********Custom labels updation Starts********/
        //updatecustomlabels();
         /********Custom labels updation Ends********/
        
        /********Cron Jobs Removal Starts********/
        
        Set<id> ids= new Set<Id>();
        for(CronJobDetail cd :[SELECT Id from CronJobDetail where JobType='3' OR JobType='8']){
            ids.add(cd.Id);
        }
        system.debug(ids);
        for(CronTrigger ct: [Select id from cronTrigger where CronJobDetailId IN :ids  limit 100]){
            system.debug(ct);
            system.abortJob(ct.Id);
        }

        /********Cron Jobs Removal Ends********/
        
        
         
        
        /******* Emails Invalidation Starts *******/
        
        UpdateEmails bc1 = new UpdateEmails('select id,Email,SDR_Owner_Email__c,Referrer_Email_Number_Copy__c,Referrer_Email_Number__c from lead where isconverted=false and (((not Email like \'%fullcopy%\') and Email != null) or ((not SDR_Owner_Email__c like \'%fullcopy%\') and SDR_Owner_Email__c!= null) or ((not Referrer_Email_Number_Copy__c like \'%fullcopy%\') and Referrer_Email_Number_Copy__c!= null) or ((not Referrer_Email_Number__c like \'%fullcopy%\') and Referrer_Email_Number__c != null))','Email;SDR_Owner_Email__c;Referrer_Email_Number_Copy__c;Referrer_Email_Number__c');
        ID batchprocessid1 = Database.executeBatch(bc1,200);
       
        
        UpdateEmails bc2 = new UpdateEmails('select id,Email,SDR_Owner_Email__c,Referrer_Email_Number__c from contact where ((not Email like \'%fullcopy%\') and Email!= null) or ((not SDR_Owner_Email__c like \'%fullcopy%\') and SDR_Owner_Email__c!= null) or  ((not Referrer_Email_Number__c like \'%fullcopy%\') and Referrer_Email_Number__c != null)','Email;SDR_Owner_Email__c;Referrer_Email_Number__c');
         ID batchprocessid2 = Database.executeBatch(bc2,200);
        
          UpdateEmails bc3 = new UpdateEmails('select id,Accounting_Email__c,Economic_Decision_Maker_Email__c,Primary_Marketo_User_Email__c from account where ((not Accounting_Email__c like \'%fullcopy%\') and Accounting_Email__c!= null) or ((not Economic_Decision_Maker_Email__c like \'%fullcopy%\') and Economic_Decision_Maker_Email__c!= null) or  ((not Primary_Marketo_User_Email__c like \'%fullcopy%\') and Primary_Marketo_User_Email__c != null)','Accounting_Email__c;Economic_Decision_Maker_Email__c;Primary_Marketo_User_Email__c');
         ID batchprocessid3 = Database.executeBatch(bc3,200); 
        
        UpdateEmails bc4 = new UpdateEmails('select id,Primary_Marketo_User_Email__c,Accounting_Email__c,Referrer_Email_Number__c from opportunity where (((not Primary_Marketo_User_Email__c like \'%fullcopy%\') and Primary_Marketo_User_Email__c != null) or  ((not Accounting_Email__c like \'%fullcopy%\') and Accounting_Email__c!= null) or ((not Referrer_Email_Number__c like  \'%fullcopy%\') and Referrer_Email_Number__c != null))','Primary_Marketo_User_Email__c;Accounting_Email__c;Referrer_Email_Number__c');
         ID batchprocessid4 = Database.executeBatch(bc4,200);
        
         UpdateEmails bc5 = new UpdateEmails('select id,SuppliedEmail,ContactEmail,CC_Email_001a__c,CC_Email_002a__c,CC_Email_003a__c,CC_Email_004a__c,CC_Email_005a__c,CC_Email_006a__c,CC_Email_007a__c,CC_Email_008a__c,CC_Email_009a__c,CC_Email_010a__c,Case_Creator_ContactEmail__c,Requester_Email__c,SM_Contact_Email__c,Case_Owner_Manager_Email__c,Primary_Marketo_User_Email__c from case where ((not SuppliedEmail like \'%fullcopy%\') and SuppliedEmail != null) or ((not ContactEmail like \'%fullcopy%\') and ContactEmail != null) or ((not CC_Email_001a__c like \'%fullcopy%\') and CC_Email_001a__c != null) or ((not CC_Email_002a__c like \'%fullcopy%\') and CC_Email_002a__c != null) or ((not CC_Email_002a__c like \'%fullcopy%\') and CC_Email_002a__c != null) or ((not CC_Email_003a__c like \'%fullcopy%\') and CC_Email_003a__c != null) or ((not CC_Email_004a__c like \'%fullcopy%\') and CC_Email_004a__c != null) or ((not CC_Email_005a__c like \'%fullcopy%\') and CC_Email_005a__c != null) or ((not CC_Email_006a__c like \'%fullcopy%\') and CC_Email_006a__c != null) or ((not CC_Email_007a__c like \'%fullcopy%\') and CC_Email_007a__c != null) or ((not CC_Email_008a__c like \'%fullcopy%\') and CC_Email_008a__c != null) or ((not CC_Email_009a__c like \'%fullcopy%\') and CC_Email_009a__c != null) or ((not CC_Email_010a__c like \'%fullcopy%\') and CC_Email_010a__c != null) or ((not Case_Creator_ContactEmail__c like \'%fullcopy%\') and Case_Creator_ContactEmail__c != null) or ((not Requester_Email__c like \'%fullcopy%\') and Requester_Email__c != null) or ((not SM_Contact_Email__c like \'%fullcopy%\') and SM_Contact_Email__c != null) or ((not Case_Owner_Manager_Email__c like \'%fullcopy%\') and Case_Owner_Manager_Email__c != null) or ((not Primary_Marketo_User_Email__c like \'%fullcopy%\') and Primary_Marketo_User_Email__c != null)','SuppliedEmail;CC_Email_001a__c;CC_Email_002a__c;CC_Email_003a__c;CC_Email_004a__c;CC_Email_005a__c;CC_Email_006a__c;CC_Email_007a__c;CC_Email_008a__c;CC_Email_009a__c;CC_Email_010a__c;Case_Creator_ContactEmail__c;Requester_Email__c;SM_Contact_Email__c;Case_Owner_Manager_Email__c;Primary_Marketo_User_Email__c');
         ID batchprocessid5 = Database.executeBatch(bc5,200);
        
        UpdateEmails bc6 = new UpdateEmails('select id,Primary_Marketo_User_Email_Email_Alert__c from asset where Primary_Marketo_User_Email_Email_Alert__c!=null and (not Primary_Marketo_User_Email_Email_Alert__c like \'%fullcopy%\')','Primary_Marketo_User_Email_Email_Alert__c');
         ID batchprocessid6 = Database.executeBatch(bc6,200);
        
        UpdateEmails bc7 = new UpdateEmails('SELECT Id, Email,Opportunity_Owner_Manager_Email__c  from Quote  where ((not(Email like \'%fullcopy%\')) and Email!= null) or ((not(Opportunity_Owner_Manager_Email__c like \'%fullcopy%\')) and (not(Opportunity_Owner_Manager_Email__c like \'%fullcopy%\')) and Opportunity_Owner_Manager_Email__c!= null)','Email;Opportunity_Owner_Manager_Email__c');
         ID batchprocessid7 = Database.executeBatch(bc7,200);
        
        UpdateEmails bc8 = new UpdateEmails('SELECT id,Primary_Marketo_User_Email_Text__c,Primary_Marketo_User_Email_Hidden__c  from entitlement where ((not(Primary_Marketo_User_Email_Text__c like \'%fullcopy%\')) and Primary_Marketo_User_Email_Text__c!= null) or ((not(Primary_Marketo_User_Email_Hidden__c  like \'%fullcopy%\')) and Primary_Marketo_User_Email_Hidden__c!= null)','Primary_Marketo_User_Email_Text__c;Primary_Marketo_User_Email_Hidden__c');
         ID batchprocessid8 = Database.executeBatch(bc8,200);
        
       /*#APPS-22321 UpdateEmails bc9 = new UpdateEmails('SELECT Id, Netkitchen_Login__c,Marketo_Login__c from Onboarding__c where ((not(Netkitchen_Login__c like \'%fullcopy%\')) and Netkitchen_Login__c!= null) or ((not(Marketo_Login__c like \'%fullcopy%\')) and Marketo_Login__c != null)','Netkitchen_Login__c;Marketo_Login__c');
         ID batchprocessid9 = Database.executeBatch(bc9,500); */
        
        UpdateEmails bc10 = new UpdateEmails('SELECT Id, echosign_dev1__Email_Address__c from echosign_dev1__SIGN_Recipients__c where ((not(echosign_dev1__Email_Address__c like \'%fullcopy%\')) and echosign_dev1__Email_Address__c != null) ','echosign_dev1__Email_Address__c');
         ID batchprocessid10 = Database.executeBatch(bc10,50);
        
        UpdateEmails bc11 = new UpdateEmails('SELECT Id, Default_Notification__c from KISettings__c where ((not(Default_Notification__c like \'%fullcopy%\')) and Default_Notification__c!= null) ','Default_Notification__c');
         ID batchprocessid11 = Database.executeBatch(bc11,50);
        
        UpdateEmails bc12 = new UpdateEmails('SELECT Id, BEM_Email__c from Confirmit_Survey_Results__c where ((not(BEM_Email__c like \'%fullcopy%\')) and BEM_Email__c!= null) ','BEM_Email__c');
         ID batchprocessid12 = Database.executeBatch(bc12,50);
         
         UpdateEmails bc13 = new UpdateEmails('SELECT Id, TSE_Email__c from Customer_Communication_Action__c where ((not(TSE_Email__c like \'%fullcopy%\')) and TSE_Email__c!= null)','TSE_Email__c');
         ID batchprocessid13 = Database.executeBatch(bc13,50);
        
         UpdateEmails bc14 = new UpdateEmails('SELECT Id, Email__c from Customer_Portal_Login_Data__c where ((not(Email__c like \'%fullcopy%\')) and Email__c!= null) ','Email__c');
         ID batchprocessid14 = Database.executeBatch(bc14,50);
        
        UpdateEmails bc15 = new UpdateEmails('SELECT Id, From_Address__c from Customer_Communication__c where ((not(From_Address__c like \'%fullcopy%\')) and From_Address__c!= null)  ','From_Address__c');
         ID batchprocessid15 = Database.executeBatch(bc15,50);
        
        UpdateEmails bc16 = new UpdateEmails('SELECT Id, JBCXM__UserEmail__c from JBCXM__SurveyResponse__c where ((not(JBCXM__UserEmail__c like \'%fullcopy%\')) and JBCXM__UserEmail__c!= null)  ','JBCXM__UserEmail__c');
         ID batchprocessid16 = Database.executeBatch(bc16,50);
        
         UpdateEmails bc17 = new UpdateEmails('SELECT Id, InviteeEmail__c from CalendlyAction__c where ((not(InviteeEmail__c like \'%fullcopy%\')) and InviteeEmail__c!= null) ','InviteeEmail__c');
         ID batchprocessid17 = Database.executeBatch(bc17,50);
        
        UpdateEmails bc18 = new UpdateEmails('SELECT Id, JBCXM__SentEmail__c from JBCXM__SurveyParticipant__c where ((not(JBCXM__SentEmail__c like \'%fullcopy%\')) and JBCXM__SentEmail__c!= null)','JBCXM__SentEmail__c');
         ID batchprocessid18 = Database.executeBatch(bc18,50);
        
        UpdateEmails bc19 = new UpdateEmails('SELECT Id, Business_Email_Address__c,Personal_Email_Address__c  from Certification_History__c where ((not(Business_Email_Address__c like \'%fullcopy%\')) and Business_Email_Address__c!= null) or  ((not(Personal_Email_Address__c like \'%fullcopy%\')) and Personal_Email_Address__c!= null)','Business_Email_Address__c;Personal_Email_Address__c');
         ID batchprocessid19 = Database.executeBatch(bc19,50); 
        
        UpdateEmails bc20 = new UpdateEmails('SELECT Id, EmailOfProductManager__c  from ProductManagers__c  where ((not(EmailOfProductManager__c like \'%fullcopy%\')) and EmailOfProductManager__c!= null)  ','EmailOfProductManager__c');
         ID batchprocessid20 = Database.executeBatch(bc20,50);
        
        UpdateEmails bc21 = new UpdateEmails('SELECT Id, Manager_Email__c  from n2de__Out_of_office__c  where ((not(Manager_Email__c like \'%fullcopy%\')) and Manager_Email__c!= null)','Manager_Email__c');
         ID batchprocessid21 = Database.executeBatch(bc21,50);
        
        UpdateEmails bc22 = new UpdateEmails('select id,Contact_Email__c,CC_Email_001a__c,CC_Email_002a__c,CC_Email_003a__c,CC_Email_004a__c,CC_Email_005a__c,CC_Email_006a__c,CC_Email_007a__c,CC_Email_008a__c,CC_Email_009a__c,CC_Email_010a__c from Case_Related_Article_List__c where ((not CC_Email_001a__c like \'%fullcopy%\') and CC_Email_001a__c != null) or ((not CC_Email_002a__c like \'%fullcopy%\') and CC_Email_002a__c != null) or ((not CC_Email_002a__c like \'%fullcopy%\') and CC_Email_002a__c != null) or ((not CC_Email_003a__c like \'%fullcopy%\') and CC_Email_003a__c != null) or ((not CC_Email_004a__c like \'%fullcopy%\') and CC_Email_004a__c != null) or ((not CC_Email_005a__c like \'%fullcopy%\') and CC_Email_005a__c != null) or ((not CC_Email_006a__c like \'%fullcopy%\') and CC_Email_006a__c != null) or ((not CC_Email_007a__c like \'%fullcopy%\') and CC_Email_007a__c != null) or ((not CC_Email_008a__c like \'%fullcopy%\') and CC_Email_008a__c != null) or ((not CC_Email_009a__c like \'%fullcopy%\') and CC_Email_009a__c != null) or ((not CC_Email_010a__c like \'%fullcopy%\') and CC_Email_010a__c != null) or ((not Contact_Email__c like \'%fullcopy%\') and Contact_Email__c!= null)','Contact_Email__c;CC_Email_001a__c;CC_Email_002a__c;CC_Email_003a__c;CC_Email_004a__c;CC_Email_005a__c;CC_Email_006a__c;CC_Email_007a__c;CC_Email_008a__c;CC_Email_009a__c;CC_Email_010a__c');
         ID batchprocessid22 = Database.executeBatch(bc22,50);
        
        UpdateEmails bc23 = new UpdateEmails('SELECT Id, echosign_dev1__Email_Recipient__c  from echosign_dev1__Recipient_Template__c  where ((not(echosign_dev1__Email_Recipient__c like \'%fullcopy%\')) and echosign_dev1__Email_Recipient__c!= null)','echosign_dev1__Email_Recipient__c');
         ID batchprocessid23 = Database.executeBatch(bc23,500);
        
        UpdateEmails bc24 = new UpdateEmails('SELECT Id, Attendee_Email__c  from GoToTraining_Attendance__c  where ((not(Attendee_Email__c like \'%fullcopy%\')) and Attendee_Email__c!= null)','Attendee_Email__c');
         ID batchprocessid24 = Database.executeBatch(bc24,50);
        
        UpdateEmails bc25 = new UpdateEmails('SELECT Id, Bill_To_Contact_Email__c  from SBQQ__Quote__c  where ((not(Bill_To_Contact_Email__c like \'%fullcopy%\')) and Bill_To_Contact_Email__c!= null)','Bill_To_Contact_Email__c');
         ID batchprocessid25 = Database.executeBatch(bc25,50);
        
        UpdateEmails bc26 = new UpdateEmails('SELECT Id, Student_Email__c  from GTT_Registrant__c  where ((not(Student_Email__c like \'%fullcopy%\')) and Student_Email__c!= null)','Student_Email__c');
         ID batchprocessid26 = Database.executeBatch(bc26,50);
        
       UpdateEmails bc27 = new UpdateEmails('SELECT Id, Email__c  from QualtricsSurvey__c  where ((not(Email__c like \'%fullcopy%\')) and Email__c!= null)','Email__c');
         ID batchprocessid27 = Database.executeBatch(bc27,50); 
        
        
        UpdateEmails bc30 = new UpdateEmails('SELECT Id, Email__c  from SDR_Owner_Settings__c  where ((not(Email__c  like \'%fullcopy%\')) and Email__c!= null)','Email__c');
         ID batchprocessid30 = Database.executeBatch(bc30,50);
     
         UpdateEmails bc31 = new UpdateEmails('SELECT Id, Jive_Email__c  from Jive_User__c  where ((not(Jive_Email__c like \'%fullcopy%\')) and Jive_Email__c!= null)','Jive_Email__c');
         ID batchprocessid31 = Database.executeBatch(bc31,50);
         
         /******* Emails Invalidation Ends*******/
    } 
    /********Custom labels updation Utility Functions********/ 
    global static void createCustomLabelMeta(string csname,string value){

        MetadataService.CustomLabel csLabel = new MetadataService.CustomLabel();
        csLabel.fullName = csname;
        csLabel.value=value;
        csLabel.protected_x  = false;
        csLabel.language = 'en_US';
        csLabel.shortDescription  = csname;
        allMetadataList.add(csLabel);
        
    }
    
     global static boolean updateCustomLabel(){
        MetadataService.MetadataPort service = createService();
        if(!Test.isRunningTest())
        {
            List<MetadataService.SaveResult> results = service.updateMetadata(allMetadataList);
                for(MetadataService.SaveResult result: results){
                system.debug('update custom label results success='+result);
                }
            return results[0].success;
         }
         else
             return true;
    }
    
    static MetadataService.MetadataPort createService(){ 
        MetadataService.MetadataPort service = new MetadataService.MetadataPort();
        service.SessionHeader = new MetadataService.SessionHeader_element();
        service.SessionHeader.sessionId = UserInfo.getSessionId();
        return service;     
    }
    
    
    static void updatecustomlabels(){ 
       
        CreateCustomLabelmeta('DomainUrl',System.URL.getSalesforceBaseUrl().toexternalform());
        CreateCustomLabelmeta('PORTAL_ARTICLE_FEEDBACK_RECEPIENT',label.PORTAL_ARTICLE_FEEDBACK_RECEPIENT+'.'+'UAT');
        CreateCustomLabelmeta('PORTAL_RESOURCE_FEEDBACK_RECEPIENT',label.PORTAL_RESOURCE_FEEDBACK_RECEPIENT+'.'+'UAT');
        CreateCustomLabelmeta('INTERNAL_ARTICLE_FEEDBACK_RECEPIENT',label.INTERNAL_ARTICLE_FEEDBACK_RECEPIENT+'.'+'UAT');
        string MKTO_UNIV_LEARNING_PASS_CODE_RECIPIENTS='';
        for(string s :label.MKTO_UNIV_LEARNING_PASS_CODE_RECIPIENTS.split('#')){
            MKTO_UNIV_LEARNING_PASS_CODE_RECIPIENTS=MKTO_UNIV_LEARNING_PASS_CODE_RECIPIENTS+s+'.'+'UAT';
        }
        CreateCustomLabelmeta('MKTO_UNIV_LEARNING_PASS_CODE_RECIPIENTS',MKTO_UNIV_LEARNING_PASS_CODE_RECIPIENTS);
        CreateCustomLabelmeta('OAP_endpoint','https://spa-ext-stage.marketo.com/api/subpost');
        CreateCustomLabelmeta('jiveGetUserInfoUrl','https://marketo-ext.jiveon.com/api/core/v3/people/email/');
        CreateCustomLabelmeta('jiveSetUserInfoUrl','https://marketo-ext.jiveon.com/api/core/v3/people/');
        CreateCustomLabelmeta('JiveSupportHomeURl','https://marketo-ext.jiveon.com/apps/d9b4f216bee951f7b28f437fedacd55d');
        CreateCustomLabelmeta('iveSyncCaseDetailUrl','https://marketo-ext.jiveon.com/apps/d9b4f216bee951f7b28f437fedacd55d?page=detail&caseid=');
        CreateCustomLabelmeta('jiveGetUserInfoUrl','https://marketo-ext.jiveon.com/api/core/v3/people/email/');
        Boolean issuccess=updateCustomLabel();
        system.debug('All custom labels updated>>>>>>'+issuccess);
        
            
    }
    
    /********Custom labels updation utility functions********/
}