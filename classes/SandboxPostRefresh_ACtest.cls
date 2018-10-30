@istest
public class SandboxPostRefresh_ACtest {
    
    public static testMethod void testcreatetestdata(){
    
        //Create Marketo Trigger Management Custom Setting
        Marketo_Trigger_Management__c marketoTriggerManager= new Marketo_Trigger_Management__c();
        marketoTriggerManager.Deactivate_Account_Triggers__c= False;
        marketoTriggerManager.Deactivate_Asset_Triggers__c= False;
        marketoTriggerManager.Deactivate_Contact_Triggers__c= False;
        marketoTriggerManager.Deactivate_Contract_Triggers__c= False;
        marketoTriggerManager.Deactivate_Entitlements_Triggers__c= False;
        marketoTriggerManager.Deactivate_Legacy_QLI_Triggers__c= False;
        marketoTriggerManager.Deactivate_Legacy_Quote_Triggers__c= False;
        marketoTriggerManager.Deactivate_OLI_Triggers__c= False;
        marketoTriggerManager.Deactivate_Opportunity_Triggers__c= False;
        marketoTriggerManager.Deactivate_Steelbrick_Quote_Triggers__c= False;
        marketoTriggerManager.Deactivate_Subscription_Triggers__c= False;
        marketoTriggerManager.Deactivate_User_Triggers__c= False;
        marketoTriggerManager.Deactivate_Project_Triggers__c = False;
        marketoTriggerManager.Deactivate_Timecard_Split_Triggers__c = False;
        marketoTriggerManager.Deactivate_Sales_Invoice_Triggers__c = False;
        marketoTriggerManager.Deactivate_Assignment_Triggers__c = False;
        marketoTriggerManager.Deactivate_Milestone_Triggers__c = False;
        insert marketoTriggerManager;
        
        //Creating intacct Entity
        Intacct_Entity__c entity1=new Intacct_Entity__c(Name='marketo',parent_entity__c='marketo');
        Intacct_Entity__c entity2=new Intacct_Entity__c(Name='JPN',parent_entity__c='marketo');
        insert entity1;
        insert entity2;
        
        //create LMSCONFIG
        
        lmscons__CFS_Config__c LMSCONFIG=new lmscons__CFS_Config__c(name='testlms');
        insert LMSCONFIG;
        
        // create lead 
        lead emailupdatelead = new lead ();
        emailupdatelead.Email ='test@test.com';
        emailupdatelead.LastName = 'test';
        emailupdatelead.Company = 'Grazitti';
        emailupdatelead.Status = 'Lead';
        emailupdatelead.SDR_Owner_Email__c = 'test@test.com';
        emailupdatelead.Referrer_Email_Number_Copy__c = 'test@test.com';
        emailupdatelead.Referrer_Email_Number__c = 'test@test.com';
        insert emailupdatelead;

        // *** create Account with thehelp of utility class ***
        account aa = Utility.insertAccountInTestClasses();
        aa.Accounting_Email__c = 'test@test.com';
        aa.Economic_Decision_Maker_Email__c = 'test@test.com';
        aa.Primary_Marketo_User_Email__c = 'test@test.com';
        insert aa;

        // *** create Account with thehelp of utility class ***
        contact con = utility.insertContactInTestClasses(aa.id);
        con.SDR_Owner_Email__c = 'test@test.com';
        con.Referrer_Email_Number__c  = 'test@test.com';
        insert con;

        // *** Create opportunity with the help of utility class ***
        opportunity opp = Utility.insertOpportunityInTestClasses(aa.id,con.id,'closed Won','New business',Date.Today(),Date.Today(),Date.today().addDays(365),Date.today().addDays(105));
        opp.Primary_Marketo_User_Email__c = 'test@test.com';
        opp.Accounting_Email__c           = 'test@test.com';
        opp.Referrer_Email_Number__c = 'test@test.com';

        insert opp;

        // *** create case ***
        case cc = new case();
        cc.Accountid = aa.id;
        cc.Origin = 'Phone';
        //cc.CSM_Request_Type__c = 'Other';
        cc.Status = 'Working';
        cc.Priority =  'High';
        cc.Contactid = con.id;
        cc.Subject = 'test';
        cc.Description = 'test';
        //cc.recordtype.id = '01238000000UWOR';
        cc.SuppliedEmail  = 'test@test.com';
        //cc.ContactEmail = 'test@test.com';
        cc.CC_Email_001a__c = 'test@test.com';
        cc.CC_Email_002a__c = 'test@test.com';
        cc.CC_Email_003a__c = 'test@test.com';
        cc.CC_Email_004a__c = 'test@test.com';
        cc.CC_Email_005a__c = 'test@test.com';
        cc.CC_Email_006a__c = 'test@test.com';
        cc.CC_Email_007a__c = 'test@test.com';
        cc.CC_Email_008a__c = 'test@test.com';
        cc.CC_Email_009a__c = 'test@test.com';
        cc.CC_Email_010a__c = 'test@test.com';
        cc.Case_Creator_ContactEmail__c = 'test@test.com';
        cc.Requester_Email__c = 'test@test.com';
        cc.SM_Contact_Email__c = 'test@test.com';
        cc.Case_Owner_Manager_Email__c = 'test@test.com'; 
        cc.Primary_Marketo_User_Email__c  = 'test@test.com';

        insert cc;

        // *** Create Asset ***
        Asset asse = new asset();
        asse.Name = 'Test Asset';
        asse.Accountid = aa.id;
        asse.Asset_Type__c = 'instance';
        asse.Primary_Marketo_User_Email_Email_Alert__c = 'Test@test.com';
        insert asse;

        // *** Create Entitlement ***
        Entitlement ee = new Entitlement();
        ee.name = 'test enttilement';
        ee.Accountid = aa.id;
        //ee.Recordtype.name = 'Education';
        ee.Primary_Marketo_User_Email_Hidden__c = 'test@test.com';
        ee.Primary_Marketo_User_Email_Text__c  = 'test@test.com';
        insert ee;

         // *** Create Recipient ***
        /*echosign_dev1__SIGN_Recipients__c Recipienttest = new echosign_dev1__SIGN_Recipients__c();
        Recipienttest.Name = 'test';
        Recipienttest.echosign_dev1__Agreement__c
        Recipienttest.CurrencyIsoCode = 'EUR';
        Recipienttest.echosign_dev1__Email_Address__c = 'test@test.com';
        insert Recipienttest;*/

        // *** Create CUSTOM SETTING Known Issues Settings  *** 
        KISettings__c kisetting = new KISettings__c();
        kisetting.Default_Notification__c = 'test@test.com';
        kisetting.Visualforce_Domain__c  = 'test';
        kisetting.name = 'ttest';
        insert kisetting;

        // *** create Confirmit_Survey_Results__c ***
        Confirmit_Survey_Results__c consurres = new Confirmit_Survey_Results__c();
        consurres.Name = 'test';
        consurres.CurrencyIsoCode = 'EUR';
        consurres.BEM_Email__c = 'test@test.com';
        insert consurres;

        // *** create Customer_Communication_Action__c ***

        Customer_Communication_Action__c cca = new Customer_Communication_Action__c();
        //cca.name = 1234;
        cca.TSE_Email__c = 'test@test.com';
        cca.CurrencyIsoCode  = 'EUR';
        insert  cca;

        // *** create Customer_Portal_Login_Data__c ***

        Customer_Portal_Login_Data__c cpld = new Customer_Portal_Login_Data__c();
        cpld.CurrencyIsoCode = 'EUR';
        cpld.Email__c = 'test@test.com';
        cpld.Name__c = 'test';
        insert  cpld; 

        // *** create Customer Communication ***
        Customer_Communication__c cuscom = new Customer_Communication__c();
        cuscom.Customers__c = 'All My Customers';
        cuscom.From_Address_Name__c = 'test';
        cuscom.From_Address__c = 'testt@test.com';
        cuscom.Subject__c  = 'test';
        cuscom.Send_Email__c = true;
        cuscom.Create_Cases__c = 'Support Case';
        cuscom.Description__c = 'test';
        //cuscom.Date_Time__c   = date.today();
        DateTime currentDate = DateTime.Now();
        cuscom.Date_Time__c   = currentDate.addMinutes(10);
        insert cuscom;

        // *** insert NPSSurvey Response ***     

        JBCXM__SurveyResponse__c jsr = new JBCXM__SurveyResponse__c();
        jsr.JBCXM__Account__c  = aa.id;
        jsr.JBCXM__NPSScore__c = 5;
        jsr.JBCXM__UserEmail__c = 'test@test.com';
        jsr.JBCXM__UserName__c = 'test';
        jsr.JBCXM__ResponseDate__c = Datetime.now();
        insert jsr;

        // *** Insert CalendlyAction ***

        CalendlyAction__c calac = new CalendlyAction__c();
        calac.Name = 'test';
        calac.EventCreatedAt__c  = Datetime.now();
        calac.EventEndTime__c  = Datetime.now();
        calac.EventStartTime__c  = Datetime.now();
        calac.EventSubject__c = 'test';
        calac.EventTypeDuration__c = 18;
        calac.EventTypeKind__c = 'test';
        calac.EventTypeName__c = 'test';
        calac.EventTypeSlug__c = 'test';
        calac.EventUuid__c = 'test';
        calac.InviteeCreatedAt__c = Datetime.now();
        calac.InviteeEmail__c  = 'test@test.com';
        calac.InviteeUuid__c = 'test';
        calac.EventPrimaryPublisherName__c = 'test';
        calac.EventPrimaryPublisherEmail__c = 'test';
        insert calac;

        // *** insert Survey Participant ***

        JBCXM__SurveyParticipant__c  jsp = new JBCXM__SurveyParticipant__c();
        jsp.JBCXM__SentEmail__c = 'test123@test.com';
        jsp.CurrencyIsoCode = 'EUR';
        insert jsp;

        // *** insert Certification History ***

        Certification_History__c ch = new Certification_History__c();
        //ch.Name = 1234;
        ch.Personal_Email_Address__c = 'test@test.com';
        ch.CurrencyIsoCode = 'EUR';
        ch.Business_Email_Address__c = 'test@test.com';
        insert ch;

        // *** insert Custom setting ProductManager ***

        ProductManagers__c  pm = new ProductManagers__c();
        pm.name = 'test';
        pm.EmailOfProductManager__c = 'test@test.com';
        pm.IdeaCategories__c  = 'test';
        insert pm;

        // *** insert Out of office ***

        n2de__Out_of_office__c ooff = new n2de__Out_of_office__c();
        ooff.Name = 'test';
        ooff.Manager_Email__c = 'test@test.com';
        insert ooff;

        // *** insert Case Related Article List ***

        Case_Related_Article_List__c cral = new Case_Related_Article_List__c ();
        cral.Name = 'test';
        cral.Contact_Email__c = 'test@test.com';
        cral.CC_Email_001a__c = 'test@test.com';
        cral.CC_Email_002a__c = 'test@test.com';
        cral.CC_Email_003a__c = 'test@test.com';
        cral.CC_Email_004a__c = 'test@test.com';
        cral.CC_Email_005a__c = 'test@test.com';
        cral.CC_Email_006a__c = 'test@test.com';
        cral.CC_Email_007a__c = 'test@test.com';
        cral.CC_Email_008a__c = 'test@test.com';
        cral.CC_Email_009a__c = 'test@test.com';
        cral.CC_Email_010a__c = 'test@test.com';
        cral.Case__c = cc.id;
        insert cral;

        // *** insert  Add Recipient ***
        /*echosign_dev1__Recipient_Template__c  esdrt = new echosign_dev1__Recipient_Template__c();
        esdrt.echosign_dev1__Email_Recipient__c =  'test@test.com';
        esdrt.echosign_dev1__Recipient_Type__c  = 'Email';
        esdrt.echosign_dev1__Recipient_Role__c = 'Signer';
        esdrt.echosign_dev1__Signer_Verification_Method__c = 'Email';
        insert esdrt;*/

        // *** insert GoToTraining Attendance ***

        /*GoToTraining_Attendance__c gta = new GoToTraining_Attendance__c();
        gta.Attendee_Email__c = 'test@test.com';
        gta.Name = 'test';
        gta.CurrencyIsoCode = 'EUR';
        insert gta;*/

        // *** insert GoToTraining Registrant ***

        /*GTT_Registrant__c gttr = new GTT_Registrant__c();
        gttr.Name = 'test';
        gttr.CurrencyIsoCode =  'EUR';
        gttr.Student_Email__c = 'test@test.com';
        insert gttr;*/

        // *** insert Qualtrics Survey ***

        QualtricsSurvey__c qs = new QualtricsSurvey__c();
        qs.Email__c = 'test@test.com';
        qs.Name = 'test';
        qs.CurrencyIsoCode = 'EUR';
        insert qs;

        // *** create custom setting SDR_Owner_Settings__c ***

        SDR_Owner_Settings__c sos = new SDR_Owner_Settings__c();
        sos.Email__c = 'test@test.com';
        sos.name = 'test';
        insert sos;

        // ***insert JiveUser ***

        Jive_User__c juser = new Jive_User__c();
        juser.Name = 'test';
        juser.CurrencyIsoCode = 'EUR';
        juser.jive_id__c = 12334;
        juser.Jive_Email__c = 'test@test.com';

        insert juser;
        SandboxPostRefresh_AC spra; 
        Test.testSandboxPostCopyScript(
            new SandboxPostRefresh_AC(), 
            UserInfo.getOrganizationId(),
            UserInfo.getOrganizationId(), 
            UserInfo.getOrganizationName()
        );

    }
   
      
       

}