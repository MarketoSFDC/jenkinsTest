/***********************
Updated by : Aman Gupta
Updated On : 17 Aug 2018
Updated For :
#APPS-20692  : Business Unit Migration to Code
#Created six methods handling the business unit

Updated by: Sumit Bhatt, Grazitti
Updated On: 16 Nov 2017
Updated for: 
# APPS-15482:Change to Renewal Owner Logic
# Changed the logic for renewal opportunity owner assignment

Updated by: Snehal Khot, Jade Global Inc.
Updated On: 9th May 2017
Updated for: 
# Reference: APPS-12993:New Code for Contact Ownership
# Changed functionality for APPS-12993


#### last modified by : Sumit Bhatt, Grazitti Interactive
	 last Modified Date : 13-April-2018
	 changes done: #APPS-10924# Remove functionality that is not needed for Account Score
	 Tracking : One can track the changes by searching the ticket number in the code 


*****************/

public class Account_MainTriggerHelper{
 
    /**Boolean variables to handle recurssion**/
    public static boolean isBeforeInsertHandler = False;
    public static boolean isBeforeUpdateHandler = False;
    public static boolean isBeforeDeleteHandler = False;
    public static boolean isAfterInsertHandler  = False;
    public static boolean isAfterUpdateHandler  = False;
    public static boolean isAfterDeleteHandler  = False;    
    
    public static Map<Id, Account> ACCOUNT_MASTER_LIST = new Map<Id, Account>();
    
    static final string LOST              = UpdateCLSOnAccountFromClzProject.LOST;
    static final String SUSPENDED         = UpdateCLSOnAccountFromClzProject.SUSPENDED;
    static final string NEWVALUE          = UpdateCLSOnAccountFromClzProject.NEWVALUE;
    static Set<String> lostAndSuspendedCLStages  = new Set<String>{LOST, SUSPENDED};
    static Set<String> CLStages           = new Set<String>(System.Label.CLS_Shoud_Not_Be_As_Follows_When_CLS_Updated_To_New.split(','));
    static Set<String> accountTypes       = new Set<String>(System.Label.Account_Type_Shoud_Be_In_Follows_When_CLS_Updated_To_New.split(','));
    static Set<String> accountTypesWhenCLSisLost = new Set<String>(System.Label.Account_Type_When_CLS_Popolated_As_LOST.split(','));
    
    static Date DATEBECAMEMEMBER  = Date.today()-90;
    static Decimal CUSTOMERNUMBER = Decimal.valueof(System.Label.Sales_Bell_Account_Customer_Number.trim());
    
    static List<Task> tasklist        = new List<Task>();
    static Map<Id,Id> recurringTasks  = new Map<Id,Id>();
    static Map<Id,Id> recurringTasks2 = new Map<Id,Id>();
    static integer a = 0;
    static integer b = 0 ;
    
    /***ACCOUNT SCORER RESORT****/
	/*  ***** APPS-10924 *****
    private static AccountScorerSettings__c triggerSettings;
    private static List <Account_Scoring_Rule_States__c> scoringRules = new List <Account_Scoring_Rule_States__c>();
    public static Boolean ruleGroup1 = false;
    public static Boolean ruleGroup2 = false;
    public static Boolean ruleGroup3 = false;
    public static Boolean ruleGroup4 = false;
    public static Boolean ruleGroup5 = false;
    public static Boolean ruleGroup6 = false;
    public static Boolean ruleGroup7 = false;
    public static Boolean ruleGroup8 = false;    
    public static Boolean ruleGroup9 = false;
	***** APPS-10924 *****  */
    
    //static Set<String> validRuleGroups = new Set<String>();  ***** APPS-10924 *****
    static Map<Id, String> accWithChangedStringMap = new Map<Id, String>();    
    //ALERTDATANYZE TRIGGER
    static String prodOrgId = System.Label.ORGANIZATION_ID;
    static Set<String> usrIdSet = new Set<String>(Label.DataNyzeNotificationList.split(','));
    public static Set<String> UserName=new Set<String>();
    public static Set<Id> UserId=new Set<Id>();
    public static Map<String,Id> UserNameAndIdPicklistToLookup=new Map<String,Id>();
    public static Map<Id,String> UserIdAndNameLookupToPicklist=new Map<Id,String>();
    public static List<User> UserList=new List<User>();
    //ACCOUNTTRIGGER TRIGGER
    Static Map<String, List<Account>> mapNameAccount = new Map<String, List<Account>>();
    
    public static Account populateTerritoties(Account ac, Map<Id, String> accountTerritoryMap) {
        system.debug(accountTerritoryMap+'debug___mania__'+ac.Id);
        if(ac != null && ac.Id != null){
            if(accountTerritoryMap != null && accountTerritoryMap.containsKey(ac.Id)) {
                ac.Territories_C__c = accountTerritoryMap.get(ac.Id);
            }
        }         
        return ac;
    }
    
    public static Account populateLifeCycleStage(Account ac){
        if(!lostAndSuspendedCLStages.contains(ac.Customer_Lifecycle_Stage__c) && (accountTypesWhenCLSisLost.contains(ac.Type))){
            ac.Customer_Lifecycle_Stage__c = LOST;
        }else if(!lostAndSuspendedCLStages.contains(ac.Customer_Lifecycle_Stage__c) && accountTypes.contains( ac.Type) && !CLStages.contains(ac.Customer_Lifecycle_Stage__c)){
            ac.Customer_Lifecycle_Stage__c = NEWVALUE;                
        }   
        return ac;
    }
    
    public static Account populateIntacctFields(Account ac){
    
        if(ac.Intacct_Account_Payable_Status__c != null){
            ac.Account_Payment_Status__c = ac.Intacct_Account_Payable_Status__c;
        }
        if(ac.Intacct_Collection_Notes__c == null){
            ac.Intacct_Collection_Notes__c='No available notes';
        }
        
        return ac;
    
    }
    
    public static boolean nbae_assignment(Account newVersion, Account oldVersion, Boolean isUpdate) {
        Boolean hasQualified = false;
        if (newVersion.type == 'Customer' || newVersion.type == 'Customer of Reseller Partner' || newVersion.type == 'Customer & Partner'){
            if(isUpdate){
                 if (oldVersion != null && oldVersion.type <> 'Customer' && oldVersion.type <> 'Customer of Reseller Partner' && oldVersion.type <> 'Customer & Partner') {
                     hasQualified = true;
                 }
            }else{
                hasQualified = true;
            }
        }
        return hasQualified;
    }
    
    public static void process_NBAE_assignment(List<Account> triggerNew, List<Id> accNBAEIds) {
        if(!AssignNBAEPerRules.ANFirstPass && !accNBAEIds.isEmpty()) {        
            Map<Id,Id> acctNBAEMap = AssignNBAEPerRules.getAccountNBAE(accNBAEIds);
            AssignNBAEPerRules.ANFirstPass = True;
            for (Account ac : triggerNew){
                if (AcctNBAEMap.get(ac.Id) <> null){
                    ac.New_Business_Account_Executive__c = acctNBAEMap.get(ac.Id);
                }
            }
        }
    }
    
    public static boolean isCAMOwnerSyncNeeded(Account newVersion, Account oldVersion) {
        Boolean hasQualified = false;
          if(newVersion.CAM_Owner__c != oldVersion.CAM_Owner__c && newVersion.CAM_Owner__c != null ||
             //CRT_Owner condition added by Cassandrea Steiner on 10.17.17 for APPS-15482
             (newVersion.CRT_Owner__c != oldVersion.CRT_Owner__c && newVersion.CRT_Owner__c != null)){
            hasQualified = true;
        }
        return hasQualified;
    }
    
    public static boolean isOwnerSyncNeeded(Account newVersion, Account oldVersion) {
        Boolean hasQualified = false;
          // If condition is changed by Jade on 24 th May 2017 for APPS-12993
      if(((
          (newVersion.OwnerId != oldVersion.OwnerId)||
          (newVersion.SDR_Owner_Lookup__c!=oldVersion.SDR_Owner_Lookup__c && newVersion.SDR_Owner_Lookup__c!=null) ||
          (newVersion.Account_Category__c   !=oldVersion.Account_Category__c )) && (newVersion.Type!=null && newVersion.Type=='Prospect')
		//next line added 8.23.17 by Cassandrea for APPS-15106, this is using the Custom Setting 'Exclude Business Units'
          && (!Exclude_Business_Units__c.getAll().containsKey(newVersion.Business_Unit__c))
         )/*  ||(newVersion.LS_Account_Score__c != oldVersion.LS_Account_Score__c && newVersion.LS_Account_Score__c != null)*/){
            hasQualified = true;
        }
        return hasQualified;
    }
    
    public static void updateContactOwnerAsAccountOwner(Set<Id> acountIds,Map<Id, Account> newMap){
    
        if(!acountIds.isEmpty()) {
            if(!System.IsBatch()){
                if([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5){ 
                    Database.executeBatch(new BatchUpdateContactOwner(acountIds,newMap),100);
                }else { 
                    System.ScheduleBatch(new BatchUpdateContactOwner(acountIds,newMap) , 'Batch to update contact-After limit exceeded'+Datetime.now() , 30);                     
                }
            }else{            
                System.ScheduleBatch(new BatchUpdateContactOwner(acountIds,newMap) , 'Batch to update contact-called from a batch job itself'+Datetime.now() , 30);                    
            }
        }
    }
    
    public static void updateCAMOwnerAsOpportunityOwner(Set<Id> accountIds, Map<Id,Account> newMap){
    
        system.debug('updateCAMOwnerAsOpportunityOwner');
        if(!accountIds.isEmpty()) {
            if(!System.IsBatch()){
                system.debug('updateCAMOwnerAsOpportunityOwner IsBatch');
                if([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5){ 
                                    system.debug('updateCAMOwnerAsOpportunityOwner IsBatch 1');
                    Database.executeBatch(new BatchUpdateOpportunityOwner(accountIds,newMap),100);
                }else { 
                                system.debug('updateCAMOwnerAsOpportunityOwner IsBatch2');
                    System.ScheduleBatch(new BatchUpdateOpportunityOwner(accountIds,newMap) , 'Batch to update contact-After limit exceeded'+Datetime.now() , 30);                     
                }
            }else{  
                            system.debug('updateCAMOwnerAsOpportunityOwner IsBatch3');          
                System.ScheduleBatch(new BatchUpdateOpportunityOwner(accountIds,newMap) , 'Batch to update contact-called from a batch job itself'+Datetime.now() , 30); 
            }
        }
    }
    
    public static boolean isUpdateUserBadgeTagQualified(Account newVersion, Account oldVersion, Boolean isUpdate) {
    /*
        Boolean hasQualified = false;
        if (trigger.isupdate){
        
            if ((oldVersion.type <> 'Customer' && oldVersion.type <> 'Partner' && oldVersion.type <> 'Customer of Reseller Partner' && oldVersion.type <> 'Customer & Partner') ||
                  oldVersion.customer_number__c == null || oldVersion.Date_Became_a_Customer__c == null)
            {
                if (newVersion.type == 'Customer' || newVersion.type == 'Partner' || newVersion.type == 'Customer of Reseller Partner' || newVersion.type == 'Customer & Partner') {
                    if (newVersion.customer_number__c > CUSTOMERNUMBER && newVersion.Date_Became_a_Customer__c > DATEBECAMEMEMBER) {
                        hasQualified = true;
                    }
                }
    
            }
        }else{
            if (newVersion.type == 'Customer' || newVersion.type == 'Partner' || newVersion.type == 'Customer of Reseller Partner' || newVersion.type == 'Customer & Partner') {
                if (newVersion.customer_number__c > CUSTOMERNUMBER && newVersion.Date_Became_a_Customer__c > DATEBECAMEMEMBER) {
                    hasQualified = true;
                 }
            }      
        }        
        return hasQualified;
    */
        return False;
    }
    
    
    public static void updateUserBadgeTag(Set<Id> accids, List<Account> accounts, List<Id> userIds, boolean isUpdate) {
    /*   
        if(isUpdate){
            updateUserEditionType(accids);
        }
        
        if (!PostToChatter.FirstPass){
            if(accounts != null && accounts.size() > 0) {
              PostToChatter.PostSalesBellToChatter(accounts, userIds);
              PostToChatter.FirstPass = True;
            }
        }
    */      
    }
    
    
   public static void updateUserEditionType(Set<Id> accids) {
    /*   
        List<User> userList = new List<User>();
        for(User us: [SELECT id, name, Is_Partner__c, Professional__c, AccountId, Contact.Account.MLM_Edition__c, Contact.Account.Type FROM User WHERE AccountId IN: accids]){
            us.Is_Partner__c   = false;
            us.Professional__c = false;
            us.Enterprise__c   = false;
            us.Spark__c        = false;  
            
            string MLM_edition = us.Contact.Account.MLM_Edition__c; // = us.Account.MLM_Edition__c;Account.MLM_Edition__c, Account.Type,
            string badge_type  = us.Contact.Account.Type;           //  = us.Account.Type; 
            
            if (badge_type == 'Partner') {
               us.Is_Partner__c = true;
            } 
            
            if(MLM_edition== 'Professional' || MLM_edition == 'SMB') {
               us.Professional__c = true;
              
            }
            
            if(MLM_edition== 'Enterprise') {
               us.Enterprise__c = true;
            }
            
            if(MLM_edition== 'Spark') {
               us.Spark__c = true;
            }  
            userList.add(us);      
        }        
        update userList;  
    */                  
    }
      /* APPS-10924
    public static AccountScorerSettings__c accountScorerSetting (){
    
        if(triggerSettings == null){
            AccountScorerSettings__c setting =  AccountScorerSettings__c.getInstance('executionsetting');
            if(setting == null){
                setting = new AccountScorerSettings__c();
            }
            setting.exceutionMode__c = Trigger.isInsert?'create':'update';  
            triggerSettings = setting;            
        }       
        
        return triggerSettings;    
    } APPS-10924 */
    
         /* APPS-10924
		private static List<Account_Scoring_Rule_States__c> retrieveScoringRules(){
        if(scoringRules.isEmpty()){
            scoringRules = [SELECT Rule_Group__c,Rule_Name__c, State_name__c, Score__c FROM Account_Scoring_Rule_States__c LIMIT 1000];//INCREASE LIMIT IN FUTURE IF NEEDED, CURRENTLY THERE ARE ONLY 29 RECS
        }        
        return scoringRules;   
    }  APPS-10924 */
    
    /* APPS-10924
		public static Boolean isAccountScorerIsQualified(Account newVersion, Account oldVersion, Boolean isInsert){
        if(isInsert){
            ruleGroup1 =  true; ruleGroup2 = true; ruleGroup3 = true; ruleGroup4 = true; ruleGroup5 = true; ruleGroup6 = true; ruleGroup7 = true; ruleGroup8 = true; ruleGroup9 = true;
         }else{
           // if(newVersion.CRM_System__c != oldVersion.CRM_System__c){ ruleGroup1 = true;}else{ validRuleGroups.add('Rule Group 1');}
            if(newVersion.Current_MRM_MA_Solution__c != oldVersion.Current_MRM_MA_Solution__c || (newVersion.Type != oldVersion.Type && newVersion.Type == 'Customer' || newVersion.Type == 'Customer & Partner')) {ruleGroup2 = true;}else{ validRuleGroups.add('Rule Group 2');}
            if(newVersion.BillingCountry != oldVersion.BillingCountry) { ruleGroup3 = true; validRuleGroups.add('Rule Group 3');}
            if(newVersion.Phone != oldVersion.Phone) {ruleGroup4 = true;}else{ validRuleGroups.add('Rule Group 4');}
            if(newVersion.Competes_with_Current_Marketo_Customer__c != oldVersion.Competes_with_Current_Marketo_Customer__c) {ruleGroup5 = true; }else{ validRuleGroups.add('Rule Group 5');}
            if(newVersion.Current_ESP_Solution__c != oldVersion.Current_ESP_Solution__c) { ruleGroup6 = true; validRuleGroups.add('Rule Group 6');}
            if(newVersion.SicDesc != oldVersion.SicDesc || newVersion.NAICS_Name__c != oldVersion.NAICS_Name__c ){ ruleGroup7 = true; ruleGroup8 = true;}else{ validRuleGroups.add('Rule Group 7'); validRuleGroups.add('Rule Group 8'); }
        }        
        return (ruleGroup1||ruleGroup2||ruleGroup3||ruleGroup4||ruleGroup5||ruleGroup6||ruleGroup7||ruleGroup8);//DO NOT ADD GROUP 9 BECAUSE IT IS NOT DEPENDENT ON ANY ACCOUNT FIELD    
    } APPS-10924 */
    
    /* APPS-10924
	public static void accountScorerTrigger(List<Account> newVersionAccounts) {
        
        AccountScorerSettings__c accountScorerSetting     = accountScorerSetting();
        List<Account_Scoring_Rule_States__c> scorngRules  = retrieveScoringRules();
        Map<String,Map<String, Decimal>> ruleGroups       = new Map<String, Map<String, Decimal>>();
        Map<String, String> rulenames                     = new Map<String, String>();    
        AccountScorerBatch__c accBatch                    = new AccountScorerBatch__c();
           
        for(Account_Scoring_Rule_States__c scoringRule: scorngRules) {
            if(!validRuleGroups.contains(scoringRule.Rule_Group__c)){          
                if(ruleGroups.containsKey(scoringRule.Rule_Group__c)) {
                    Map<String, Decimal> states = ruleGroups.get(scoringRule.Rule_Group__c);
                    states.put(scoringRule.State_name__c, scoringRule.Score__c);
                    rulenames.put(scoringRule.State_name__c, scoringRule.Rule_Name__c);
                    ruleGroups.put(scoringRule.Rule_Group__c, states);  
                } else {
                    Map<String, Decimal> states = new Map<String, Decimal>();
                    states.put(scoringRule.State_name__c, scoringRule.Score__c);
                    rulenames.put(scoringRule.State_name__c, scoringRule.Rule_Name__c);
                    ruleGroups.put(scoringRule.Rule_Group__c, states);  
                }  
            }             
        }                 
        
        AccountScorer accScorer = new AccountScorer();      
        Map<ID,Decimal> manualIncDecScoreMap = new Map<ID,Decimal>();
        /*List<Manual_Increment_Decrement__c> manualIncDecScoreList = new List<Manual_Increment_Decrement__c>([Select Account_ID__r.Id, Score_Update__c From Manual_Increment_Decrement__c  Where Account_ID__c IN : newVersionAccounts]);
        for(Manual_Increment_Decrement__c  IncDec: manualIncDecScoreList ){
            manualIncDecScoreMap.put(IncDec.Account_ID__r.Id,IncDec.Score_Update__c );
        }
        try{//TOO HANDLE TOO AMNY CPU TIME
            for(Account newAccount : newVersionAccounts) {
                accBatch.Accountids__c += (String)newAccount.Id+',';
                Double accScore = 0;
                newAccount.Account_Score_History__c = '';
                String accScoreHistory = '';
                if(manualIncDecScoreMap != null && !manualIncDecScoreMap.isEmpty() && manualIncDecScoreMap.containsKey(newAccount.Id)) {
                    accScore = manualIncDecScoreMap.get(newAccount.Id);
                }else{
                    accScore = 0;
                }
                accScoreHistory = 'Manual Increase/Decrease:  ' + accScore + '<br/>' ;
                //Evaluate all rule groups                               
                for (String ruleGroup : ruleGroups.keySet()){                         
                    accScorer.evaluateRule(ruleGroup, ruleGroups.get(ruleGroup),rulenames, newAccount, accountScorerSetting.exceutionMode__c);
                    accScore += accScorer.accScore;
                    accScoreHistory += accScorer.accHistory;                        
                }           
                newAccount.Account_Score__c         = accScore;
                newAccount.Account_Score_History__c = accScoreHistory;    
            }
        }catch(Exception e){newVersionAccounts[0].addError(e.getMessage());}
        
        if(accountScorerSetting.settingsMode__c == 'on') { //recalculation batch mode
            try{insert accBatch;}catch (Exception ex){trigger.new[0].addError(ex.getMessage());} 
        }
    
    } APPS-10924 */
    // ***************** COMMENTING AS BELOW FUNCTIONALITY NO LONGER REQUIRED, AS Customer_Success_Manager__c FIELD IS DELETED ***********************//
    /*
    public static Boolean createTaskTriggerQualified(Account newVersion, Account oldVersion, Boolean isUpdate){
        if(isUpdate){
            if(oldVersion.CSM_Trigger__c != newVersion.CSM_Trigger__c){
                if(newVersion.Customer_Success_Manager__c != null && newVersion.CSM_Trigger__c != null){  
                    return true;
                }
            }
        }else{
            if(newVersion.Customer_Success_Manager__c != null && newVersion.CSM_Trigger__c != null){
                return true;   
            }
        }
        return false;        
    }
    */
    /*
    public static void createTaslTrigger(Account newVersion) {
        system.debug(newVersion.CSM_Trigger__c + 'New Bersionsss!!!');
        if(newVersion.CSM_Trigger__c == 'Elite/Key'){
            a++;            
            if(a==1){
                Task obj1 = new Task();
                obj1.Ownerid=newVersion.Customer_Success_Manager__c;
                obj1.whatid=newVersion.id;
                obj1.Subject = 'Weekly Meeting Setup Needed';
                obj1.Description='Please schedule a weekly meeting with our new Elite/Key Customer!';                   
                obj1.Isrecurrence = true;
                obj1.recurrenceStartDateOnly = newVersion.Date_Became_a_Customer__c;
                //obj1.recurrenceStartDateOnly = newVersion.Date_Became_a_Customer__c;
                //obj1.ActivityDate=newVersion.Date_Became_a_Customer__c+7; 
                obj1.recurrenceEndDateOnly = newVersion.Date_Became_a_Customer__c+364; 
                obj1.recurrencetype = 'RecursWeekly';
                obj1.RecurrenceDayOfWeekMask = 1;
                obj1.RecurrenceInterval= 1;
                tasklist.add(obj1); 
            } 
            Task obj3 = new Task();
            obj3.whatid=newVersion.id;
            obj3.Ownerid=newVersion.Customer_Success_Manager__c;
            obj3.Subject = 'Quarterly Business Review Prep';
            obj3.Description='Prepare for your Quarterly Review with the Customer';
            obj3.ActivityDate=newVersion.Date_Became_a_Customer__c+76;
            tasklist.add(obj3);
                
            Task obj4 = new Task();
            obj4.whatid=newVersion.id;
            obj4.Ownerid=newVersion.Customer_Success_Manager__c;
            obj4.Subject = 'Quarterly Business Review';
            obj4.Description='Schedule a Business Review with the customer';
            obj4.ActivityDate=newVersion.Date_Became_a_Customer__c+90;
            tasklist.add(obj4);
                
            Task obj5 = new Task();
            obj5.whatid=newVersion.id;
            obj5.Ownerid=newVersion.Customer_Success_Manager__c;
            obj5.Subject = 'Quarterly Business Review Prep';
            obj5.Description='Prepare for your Quarterly Review with the Customer';
            obj5.ActivityDate=newVersion.Date_Became_a_Customer__c+166;
            tasklist.add(obj5);
                
            Task obj6 = new Task();
            obj6.whatid=newVersion.id;
            obj6.Ownerid=newVersion.Customer_Success_Manager__c;
            obj6.Subject = 'Quarterly Business Review';
            obj6.Description='Schedule a Business Review with the customer';
            obj6.ActivityDate=newVersion.Date_Became_a_Customer__c+180;
            tasklist.add(obj6);
                
            Task obj7 = new Task();
            obj7.whatid=newVersion.id;
            obj7.Ownerid=newVersion.Customer_Success_Manager__c;
            obj7.Subject = 'Quarterly Business Review Prep';
            obj7.Description='Prepare for your Quarterly Review with the Customer';
            obj7.ActivityDate=newVersion.Date_Became_a_Customer__c+256;
            tasklist.add(obj7);
                
            Task obj8 = new Task();
            obj8.whatid=newVersion.id;
            obj8.Ownerid=newVersion.Customer_Success_Manager__c;
            obj8.Subject = 'Quarterly Business Review';
            obj8.Description='Schedule a Business Review with the customer';
            obj8.ActivityDate=newVersion.Date_Became_a_Customer__c+270;
            tasklist.add(obj8);
               
            Task obj9 = new Task();
            obj9.whatid=newVersion.id;
            obj9.Ownerid=newVersion.Customer_Success_Manager__c;
            obj9.Subject = 'Quarterly Business Review Prep';
            obj9.Description='Prepare for your Quarterly Review with the Customer';
            obj9.ActivityDate=newVersion.Date_Became_a_Customer__c+346;
            tasklist.add(obj9);
                
            Task obj10 = new Task();
            obj10.whatid=newVersion.id;
            obj10.Ownerid=newVersion.Customer_Success_Manager__c;
            obj10.Subject = 'Quarterly Business Review';
            obj10.Description='Schedule a Business Review with the customer';
            obj10.ActivityDate=newVersion.Date_Became_a_Customer__c+360;
            tasklist.add(obj10);
                
            Task obj11 = new Task();
            obj11.Ownerid=newVersion.Customer_Success_Manager__c;
            obj11.whatid=newVersion.id;
            obj11.Subject = 'Renewal Discussions';
            obj11.Description='Start Renewal Discussions with the customer';
            if(newVersion.Acct_Renewal_Date__c !=null)
                //  obj11.ActivityDate=newVersion.Acct_Renewal_Date__c ;
                obj11.ActivityDate=newVersion.Acct_Renewal_Date__c-120 ;
            else
                obj11.ActivityDate=newVersion.Date_Became_a_Customer__c+240;
             
            tasklist.add(obj11);
                
            Task obj12 = new Task();
            obj12.whatid=newVersion.id;
            obj12.Ownerid=newVersion.Customer_Success_Manager__c;
            obj12.Subject = 'Usage Review and Offers';
            obj12.Description='Discuss Usage and any additional product offers';
            obj12.ActivityDate=newVersion.Date_Became_a_Customer__c+180;
            tasklist.add(obj12);
            
            Task obj13 = new Task();
            obj13.whatid=newVersion.id;
            obj13.Ownerid=newVersion.Customer_Success_Manager__c;
            obj13.Subject = 'Usage Review and Offers';
            obj13.Description='Discuss Usage and any additional product offers';
            obj13.ActivityDate=newVersion.Date_Became_a_Customer__c+360;
            tasklist.add(obj13); 
        }else
        if(newVersion.CSM_Trigger__c == 'Enterprise'){
            b++;          
            if(b==1)                 {
                recurringTasks2.put(newVersion.id,newVersion.Customer_Success_Manager__c); 
            }
            Task obj3 = new Task();
            obj3.whatid=newVersion.id;
            obj3.Ownerid=newVersion.Customer_Success_Manager__c;
            obj3.Subject = 'Quarterly Business Review Prep';
            obj3.Description='Prepare for your Quarterly Review with the Customer';
            obj3.ActivityDate=newVersion.Date_Became_a_Customer__c+76;
            tasklist.add(obj3);
            
            Task obj4 = new Task();
            obj4.whatid=newVersion.id;
            obj4.Ownerid=newVersion.Customer_Success_Manager__c;
            obj4.Subject = 'Quarterly Business Review';
            obj4.Description='Schedule a Business Review with the customer';
            obj4.ActivityDate=newVersion.Date_Became_a_Customer__c+90;
            tasklist.add(obj4);
            
            Task obj5 = new Task();
            obj5.whatid=newVersion.id;
            obj5.Ownerid=newVersion.Customer_Success_Manager__c;
            obj5.Subject = 'Quarterly Business Review Prep';
            obj5.Description='Prepare for your Quarterly Review with the Customer';
            obj5.ActivityDate=newVersion.Date_Became_a_Customer__c+166;
            tasklist.add(obj5);
            
            Task obj6 = new Task();
            obj6.whatid=newVersion.id;
            obj6.Ownerid=newVersion.Customer_Success_Manager__c;
            obj6.Subject = 'Quarterly Business Review';
            obj6.Description='Schedule a Business Review with the customer';
            obj6.ActivityDate=newVersion.Date_Became_a_Customer__c+180;
            tasklist.add(obj6);
            
            Task obj7 = new Task();
            obj7.whatid=newVersion.id;
            obj7.Ownerid=newVersion.Customer_Success_Manager__c;
            obj7.Subject = 'Quarterly Business Review Prep';
            obj7.Description='Prepare for your Quarterly Review with the Customer';
            obj7.ActivityDate=newVersion.Date_Became_a_Customer__c+256;
            tasklist.add(obj7);
            
            Task obj8 = new Task();
            obj8.whatid=newVersion.id;
            obj8.Ownerid=newVersion.Customer_Success_Manager__c;
            obj8.Subject = 'Quarterly Business Review';
            obj8.Description='Schedule a Business Review with the customer';
            obj8.ActivityDate=newVersion.Date_Became_a_Customer__c+270;
            tasklist.add(obj8);
           
            Task obj9 = new Task();
            obj9.whatid=newVersion.id;
            obj9.Ownerid=newVersion.Customer_Success_Manager__c;
            obj9.Subject = 'Quarterly Business Review Prep';
            obj9.Description='Prepare for your Quarterly Review with the Customer';
            obj9.ActivityDate=newVersion.Date_Became_a_Customer__c+346;
            tasklist.add(obj9);
            
            Task obj10 = new Task();
            obj10.whatid=newVersion.id;
            obj10.Ownerid=newVersion.Customer_Success_Manager__c;
            obj10.Subject = 'Quarterly Business Review';
            obj10.Description='Schedule a Business Review with the customer';
            obj10.ActivityDate=newVersion.Date_Became_a_Customer__c+360;
            tasklist.add(obj10);
            
            Task obj11 = new Task();
            obj11.whatid=newVersion.id;
            obj11.Ownerid=newVersion.Customer_Success_Manager__c;
            obj11.Subject = 'Renewal Discussions';
            obj11.Description='Start Renewal Discussions with the customer';
            if(newVersion.Acct_Renewal_Date__c !=null){            
                obj11.ActivityDate=newVersion.Acct_Renewal_Date__c-120 ;
            }else{
                obj11.ActivityDate=newVersion.Date_Became_a_Customer__c+240;
            }
            tasklist.add(obj11);
            
            Task obj12 = new Task();
            obj12.whatid=newVersion.id;
            obj12.Ownerid=newVersion.Customer_Success_Manager__c;
            obj12.Subject = 'Usage Review and Offers';
            obj12.Description='Discuss Usage and any additional product offers';
            obj12.ActivityDate=newVersion.Date_Became_a_Customer__c+180;
            tasklist.add(obj12);
            
            Task obj13 = new Task();
            obj13.whatid=newVersion.id;
            obj13.Ownerid=newVersion.Customer_Success_Manager__c;
            obj13.Subject = 'Usage Review and Offers';
            obj13.Description='Discuss Usage and any additional product offers';
            obj13.ActivityDate=newVersion.Date_Became_a_Customer__c+360;
            tasklist.add(obj13);                 
        }else 
        if(newVersion.CSM_Trigger__c == 'Standard'){
                
            Task obj1 = new Task();
            obj1.whatid=newVersion.id;
            obj1.Ownerid=newVersion.Customer_Success_Manager__c;
            obj1.Subject = 'Quarterly Meeting';
            obj1.Description='Schedule a Quarterly Meeting with the customer';
            obj1.ActivityDate=newVersion.Date_Became_a_Customer__c+90;
            tasklist.add(obj1);
            
            Task obj2 = new Task();
            obj2.whatid=newVersion.id;
            obj2.Ownerid=newVersion.Customer_Success_Manager__c;
            obj2.Subject = 'Quarterly Meeting';
            obj2.Description='Schedule a Quarterly Meeting with the customer';
            obj2.ActivityDate=newVersion.Date_Became_a_Customer__c+180;
            tasklist.add(obj2);
            
            Task obj3 = new Task();
            obj3.whatid=newVersion.id;
            obj3.Ownerid=newVersion.Customer_Success_Manager__c;
            obj3.Subject = 'Quarterly Meeting';
            obj3.Description='Schedule a Quarterly Meeting with the customer';
            obj3.ActivityDate=newVersion.Date_Became_a_Customer__c+270;
            tasklist.add(obj3);
            
            Task obj4 = new Task();
            obj4.whatid=newVersion.id;
            obj4.Ownerid=newVersion.Customer_Success_Manager__c;
            obj4.Subject = 'Quarterly Meeting';
            obj4.Description='Schedule a Quarterly Meeting with the customer';
            obj4.ActivityDate=newVersion.Date_Became_a_Customer__c+360;
            tasklist.add(obj4);
            
            Task obj5 = new Task();
            obj5.whatid=newVersion.id;
            obj5.Ownerid=newVersion.Customer_Success_Manager__c;
            obj5.Subject = 'Renewal Discussions';
            obj5.Description='Start Renewal Discussions with the customer';
            if(newVersion.Acct_Renewal_Date__c !=null){
                obj5.ActivityDate=newVersion.Acct_Renewal_Date__c-120;           
            }else{
                obj5.ActivityDate=newVersion.Date_Became_a_Customer__c+240;
            }
            tasklist.add(obj5);
            
            Task obj6 = new Task();
            obj6.whatid=newVersion.id;
            obj6.Ownerid=newVersion.Customer_Success_Manager__c;
            obj6.Subject = 'Usage Review and Offers';
            obj6.Description='Discuss Usage and any additional product offers';
            obj6.ActivityDate=newVersion.Date_Became_a_Customer__c+180;
            tasklist.add(obj6);
            
            Task obj7 = new Task();
            obj7.whatid=newVersion.id;
            obj7.Ownerid=newVersion.Customer_Success_Manager__c;
            obj7.Subject = 'Usage Review and Offers';
            obj7.Description='Discuss Usage and any additional product offers';
            obj7.ActivityDate=newVersion.Date_Became_a_Customer__c+360;
            tasklist.add(obj7);
            
            
            Task obj8 = new Task();
            obj8.whatid=newVersion.id;
            obj8.Ownerid=newVersion.Customer_Success_Manager__c;
            obj8.Subject = 'Semi Annual Instance Review';
            obj8.Description='Schedule an instance review with the customer';
            obj8.ActivityDate=newVersion.Date_Became_a_Customer__c+120;
            tasklist.add(obj8);
            
            
            Task obj9 = new Task();
            obj9.whatid=newVersion.id;
            obj9.Ownerid=newVersion.Customer_Success_Manager__c;
            obj9.Subject = 'Semi Annual Instance Review';
            obj9.Description='Schedule an instance review with the customer';
            obj9.ActivityDate=newVersion.Date_Became_a_Customer__c+300;
            tasklist.add(obj9);
        }        
    }
    */
    /*
    public static void commitCreateTaslTrigger(){
        if(!tasklist.isEmpty()){
            insert Tasklist;
        }  
        if(!recurringTasks.isEmpty() && !System.isFuture() && !System.isBatch()){
            CreateTaskTriggerController.CreateRecurringTasks(recurringTasks,'Elite/Key');
        }
        if(!recurringTasks2.isEmpty() && !System.isFuture() && !System.isBatch()){
            CreateTaskTriggerController.CreateRecurringTasks(recurringTasks2,'Enterprise');   
        }   
    }
    */
    /*** TRIGGER: AlertDatanyzeUpdate STARTS***/
    public static Boolean alertDatanyzeUpdate(Account newVersion) {       
        if((newVersion.Type != 'Customer') && (newVersion.Type != 'Customer & Partner')) return false;                                    
        if(newVersion.Name.containsIgnoreCase('Marketo')) return false;   
        if(newVersion.CAM_Owner__c  == NULL) return false;               
        //If org is sandbox and not in allowed testers list
        if(prodOrgId != Userinfo.getOrganizationId() && (!usrIdSet.contains(newVersion.CAM_Owner__c))) return false;  
      
        return true;     
    }
    
    static Set<Id> changedEspAccounts = new Set<Id>();
    static Set<Id> changedMrmAccounts = new Set<Id>();  
    static List<String> Current_ESP_Solution       = System.Label.Current_ESP_Solution.toLowerCase().split(';');
    static List<String> Current_MRM_MA_Solution    = System.Label.Current_MRM_MA_Solution.toLowerCase().split(';');              
    static List<String> Current_ESP_ExpSolution    = System.Label.Current_ESP_ExpSolution.toLowerCase().split(';');      
    static List<String> Current_MRM_MA_ExpSolution = System.Label.Current_MRM_MA_ExpSolution.toLowerCase().split(';');
    static Date TodayDate                          = Date.Today();
    static Map<Integer,String> monthsMap = new Map<Integer,String> {
              1  => 'January',
              2  => 'February',
              3  => 'March',
              4  => 'April',
              5  => 'May',
              6  => 'June' ,
              7  => 'July',
              8  => 'August' ,
              9  => 'September',
              10 => 'October' ,
              11 => 'November',
              12 => 'December' 
            };
    static Integer month         = TodayDate.month();
    static string formattedMonth = monthsMap.Get(month);
    static Integer day           = TodayDate.day();
    static Integer Year          = TodayDate.year();
    static string formattedDate  = formattedMonth + ' ' +day + ', '+Year;
              
    public static void processAlertDatanyzeUpdate(Account newVersion, Account oldVersion) {
        Boolean IsMatched = false;
        if(newVersion.Datanyze_Website_History__c != null ){
            string DatanyzeWebsiteHistory = newVersion.Datanyze_Website_History__c;                
            //set<string> testSplitStr = new set<string>();   
            List<String> testsplit = DatanyzeWebsiteHistory.split('[\n\r]');            
            if(testsplit != null && testsplit.size() > 0){
                IsMatched= formattedDate.trim().equals(testsplit[0].trim());//check datanyze date is same to the current date.
            }
        }
        //check if date matches and value of Current_ESP_Solution__c is changing
        if(IsMatched && (newVersion.Current_ESP_Solution__c != oldVersion.Current_ESP_Solution__c)) {    
            string currEspSoln = newVersion.Current_ESP_Solution__c; //current values stored here 
            string oldEspSoln  = oldVersion.Current_ESP_Solution__c; //old values stored here                           
            
            if(Utility.checkForDatanyzeChange(currEspSoln , oldEspSoln  , Current_ESP_Solution, Current_ESP_ExpSolution) == TRUE) {                                               
                changedEspAccounts.Add(newVersion.Id);  
            }  
        }     
        
        //date match with present and Current_MRM_MA_Solution__c values changes.
        if(IsMatched && (newVersion.Current_MRM_MA_Solution__c != oldVersion.Current_MRM_MA_Solution__c)) {
            string currMrmSoln = newVersion.Current_MRM_MA_Solution__c; //current values stored here 
            string oldMrmSoln = oldVersion.Current_MRM_MA_Solution__c; //old values stored here
            
            //Main fucntion called                  
            if(Utility.checkForDatanyzeChange(currMrmSoln , oldMrmSoln , Current_MRM_MA_Solution, Current_MRM_MA_ExpSolution) == TRUE ) {                                               
                changedMrmAccounts.Add(newVersion.Id);  
            }
        }                     
    }
    
    public static void commitAlerDatanyzeProcess(Map<Id, Account> newVersionMap){
    
        if(changedEspAccounts.isEmpty() == FALSE || changedMrmAccounts.isEmpty() == FALSE) {    
                    
            Id FROM_EMAIL_ID = System.Label.Frank_OrgWideEmailAddrressId; //[select Id from OrgWideEmailAddress where DisplayName = 'Frank Passantino'].Id;              
            Map<String, Id> emailTempltToNameMap = new Map<String,Id>();   
            for(EmailTemplate tmp : [select Id, DeveloperName from EmailTemplate where DeveloperName in ('Alert_Current_ESP_Solutions','Alert_Current_MRMMA_Solution')]) {
                emailTempltToNameMap.put(tmp.DeveloperName,tmp.Id);                     
            }
                          
            if(changedEspAccounts.isEmpty() == FALSE) {  
                Map<Id,Account> toBeMailedAccounts = new  Map<Id,Account>();
                for(Id whatId : changedEspAccounts) {
                    if(newVersionMap.get(whatId).CAM_Owner__c != NULL) {  
                        toBeMailedAccounts.put(whatId,newVersionMap.get(whatId));
                    }  
                }                 
                //Main fucntion called use to send email                              
                Utility.sendDatanyzeNotification(toBeMailedAccounts, emailTempltToNameMap.get('Alert_Current_ESP_Solutions'), FROM_EMAIL_ID);                                                                           
            }    
            
            if(changedMrmAccounts.isEmpty() == FALSE) {     
                //prepare mailing account
                Map<Id,Account> toBeMailedAccounts = new  Map<Id,Account>();
                for(Id whatId : changedMrmAccounts) {
                    if(newVersionMap.get(whatId).CAM_Owner__c != NULL) {  
                        toBeMailedAccounts.put(whatId,newVersionMap.get(whatId));
                    }
                }
                //Main fucntion called use to send email
                Utility.sendDatanyzeNotification(toBeMailedAccounts, emailTempltToNameMap.get('Alert_Current_MRMMA_Solution'), FROM_EMAIL_ID);                                                           
            }                 
        } 
    }
    
    /*** TRIGGER: AlertDatanyzeUpdate STARTS***/
    
    /*** TRIGGER: "accountTrigger" - STARTED ****/
    /*public static Account accountTrigger_updateSDPFields(Account newVersion){
        if(String.isNotBlank(newVersion.SDR_Owner_Picklist__c)){
            if(!mapNameAccount.containsKey(newVersion.SDR_Owner_Picklist__c)){
                mapNameAccount.put(newVersion.SDR_Owner_Picklist__c, new List<Account>());
            }
            mapNameAccount.get(newVersion.SDR_Owner_Picklist__c).add(newVersion);   
        }
        else{
            //Assign fields null value
            newVersion = AccountTriggerHandler.copyUserValues(new User(),newVersion);
        }
        return newVersion;    
    }  */ 
    
    
    //****************************************************************************************************
    // Added by Jade Global Inc
    //Date: 24th May 2017
    // Following method is written to populate SDR Owner as SDR owner lookup when SDR owner lookup get changed in Before Update of Account 
    public static void accountTrigger_updateSDPFieldsNew1(List<Account> newList, Map<Id, Account> oldMap){
        for(Account at:newList){
        
            if(Trigger.isInsert){
                if(at.SDR_Owner_Lookup__c!=null){
                    
                 UserId.add(at.SDR_Owner_Lookup__c);
                 system.debug('UserId@@@@@@@'+UserId);
                }
            }//End of IF
            
            if(Trigger.isUpdate){
                if( at.SDR_Owner_Lookup__c != oldMap.get(at.Id).SDR_Owner_Lookup__c && at.SDR_Owner_Lookup__c!=null){
                    
                UserId.add(at.SDR_Owner_Lookup__c);    
                system.debug('UserId#####'+UserId);
                }//end of if loop  
            }//End of IF
            
        }//end of for loop 
        
        if(!UserId.IsEmpty()){    
            UserList=[select Id,Name from User where Id IN :UserId ];   
            system.debug('UserList#####'+UserList);
        }//end of if loop 
        if(!UserList.IsEmpty()){
            for(User u:UserList){
                if(!UserIdAndNameLookupToPicklist.containsKey(u.Id)){
                       UserIdAndNameLookupToPicklist.put(u.Id,u.Name);
                       system.debug('UserIdAndNameLookupToPicklist#####'+UserIdAndNameLookupToPicklist);
                }//end of if loop                  
            }//end of for loop 
        }//end of if loop 
        
        for(Account act:newList){
            if(((trigger.isInsert &&  act.SDR_Owner_Lookup__c !=null) || (( trigger.isUpdate && act.SDR_Owner_Lookup__c != oldMap.get(act.Id).SDR_Owner_Lookup__c )&& act.SDR_Owner_Lookup__c!=null )) && 
            !UserIdAndNameLookupToPicklist.isEmpty()  && UserIdAndNameLookupToPicklist.containsKey(act.SDR_Owner_Lookup__c) ){
                
                system.debug(' act.SDR_Owner_Picklist__c#####'+act.SDR_Owner_Picklist__c);
                act.SDR_Owner_Picklist__c=UserIdAndNameLookupToPicklist.get(act.SDR_Owner_Lookup__c);
                if(!mapNameAccount.containsKey(act.SDR_Owner_Picklist__c) ){
                    mapNameAccount.put(act.SDR_Owner_Picklist__c, new List<Account>{act});
                    system.debug('mapNameAccount#####'+mapNameAccount);
                   
                }//end of if loop
                else
                    mapNameAccount.get(act.SDR_Owner_Picklist__c).add(act);   
                    system.debug('mapNameAccount#####'+mapNameAccount);
            }//end of if loop  
           
        }//end of for loop   
        
        }//End of accountTrigger_updateSDPFieldsNew1()
    public static void updateSDP_Fields(){
        //Query User Object
        if(!mapNameAccount.isEmpty()){
            Set<String> setSDPNames = mapNameAccount.keySet();
            //Update fields for Account
            for(User objUser : [SELECT Id, Email, Name, FirstName, LastName, Phone, Title FROM User WHERE Name IN : setSDPNames AND IsActive = true AND IsPortalEnabled = false]){
                //Get List of Accounts based on Name
                List<Account> tempAccount = mapNameAccount.get(objUser.Name);
                for(Account objTempAcc : mapNameAccount.get(objUser.Name)){
                    objTempAcc = AccountTriggerHandler.copyUserValues(objUser,objTempAcc);
                }
            }
        }    
    }
    
    Static Set<Id> parentIds = new Set<Id>();
    public static void isCAM_AssignmentPasssed(Account newVersion){
        if(newVersion.ParentId != NULL){
            parentIds.add(newVersion.ParentId);
        }    
    }
    
    public static void processCAM_assignment(List<Account> triggerNew) {
        CAM_Assignment camObject     = new CAM_Assignment();
        Map<Id,Account> parentAccMap = new Map<Id,Account>();
        Map<Id,Account> accMap       = new Map<Id,Account>();
        if(!parentIds.isEmpty()) {
           parentAccMap = new Map<Id,Account>([SELECT Id,ParentId,Parent.CAM_Owner__c,Parent.CAM_Group__c,CAM_Owner__c,CAM_Group__c
                                               FROM Account WHERE Id IN:parentIds]);
        }
        for(Account acc : triggerNew) {
            if(acc.ParentId != NULL){
                if(!parentAccMap.isEmpty() && parentAccMap.containsKey(acc.ParentId)){
                    acc.Parent = parentAccMap.get(acc.ParentId);
                }
                if(Trigger.isInsert == true){
                    CAM_Assignment.syncCAMwithParent(acc);
                }
            }
            if(acc.CAM_Assign_Status__c == 'Pending CAM Group Assignment'){
                CAM_Assignment.setGroup(acc);
                if(Test.isRunningTest() || Trigger.isUpdate){
                    accMap.put(acc.Id,acc);
                }
            }
            if(acc.CAM_Assign_Status__c == 'Pending CAM Owner Assignment'){
                CAM_Assignment.setOwner(acc);
                if(Test.isRunningTest() || Trigger.isUpdate){
                    accMap.put(acc.Id,acc);
                }
            }
        }
        
        if(!accMap.isEmpty()) {
            Map<Id, account> accs = CAM_Assignment.updateChildAccountsNew(accMap.values());
            ACCOUNT_MASTER_LIST.putAll(accs);
        }
    }
  
    /***TOOLS & UTILITY- STARTS**/
    public static void FINALLY_DMLS(){  
        //1. UPDATE ACCOUNT
        UPDATE_ACCOUNT_FINALLY();        
        //2. UPDATE OTHER OBJECTS- OPPORTUNITY
    }
    
    public static void UPDATE_ACCOUNT_FINALLY(){
        if(!ACCOUNT_MASTER_LIST.isEmpty()){
            try{
                DatabaseOperation.updateAccount(ACCOUNT_MASTER_LIST.values(), true, true);
                ACCOUNT_MASTER_LIST.clear();
            }catch(Exception e){
                system.debug('EXCEPTION__UPDATE_ACCOUNT____'+e);
            }
        }
    } 
    
    public static Account retrievePartiallyUpdatedAccount(Account acc){ 
        if(acc.Id != null) {   
            if(ACCOUNT_MASTER_LIST.containsKey(acc.Id)){
                return ACCOUNT_MASTER_LIST.get(acc.Id);
            }else{
                return acc;
            }
        }else{
            return acc;        
        }
    }
    
    public static void AccountAdallomTrigger(List<Account> newTrigger, Map<Id, Account> newTriggerMap, List<Account> oldTrigger, Map<Id, Account> oldTriggerMap) { 
        try{
            AdallomAudit__c audit = new AdallomAudit__c();
            audit.UserId__c = UserInfo.getUserId();
            audit.Timestamp__c = System.now(); 
            audit.ObjectName__c = 'Account';
            if (Trigger.isDelete) {
                if (oldTrigger.size() == 1) {
                    String serializedValue = System.JSON.serialize(oldTrigger[0]); 
                    if (serializedValue.length() <= 32768) { 
                       audit.OldObjectJSON__c = serializedValue; 
                    }
                    audit.ActionType__c = 'DELETE';
                    audit.ObjectId__c = oldTrigger[0].Id;
                    audit.ObjectTitle__c = oldTrigger[0].Name;
                } else {
                   audit.ActionType__c = 'MASS_DELETE';
                   audit.ObjectIds__c = System.JSON.serialize(oldTriggerMap.keySet());
                }
            } else {
                if (Trigger.isInsert) {
                    if (newTrigger.size() == 1) {
                        String serializedValue = System.JSON.serialize(newTrigger[0]); 
                        if (serializedValue.length() <= 32768) { 
                            audit.NewObjectJSON__c = serializedValue; 
                        }
                        audit.ActionType__c = 'INSERT';
                        audit.ObjectId__c = newTrigger[0].Id;
                        audit.ObjectTitle__c = newTrigger[0].Name;
                    } else {
                        audit.ActionType__c = 'MASS_INSERT';
                        audit.ObjectIds__c = System.JSON.serialize(newTriggerMap.keySet());
                    }
                } else {
                    if (newTrigger.size() == 1) {
                        String serializedValue = System.JSON.serialize(oldTrigger[0]); 
                        if (serializedValue.length() <= 32768) { 
                           audit.OldObjectJSON__c = serializedValue; 
                        }
                        serializedValue = System.JSON.serialize(newTrigger[0]); 
                        if (serializedValue.length() <= 32768) { 
                            audit.NewObjectJSON__c = serializedValue; 
                        }
                        audit.ActionType__c = 'UPDATE';
                        audit.ObjectId__c = newTrigger[0].Id;
                        audit.ObjectTitle__c = newTrigger[0].Name;
                    } else {
                        audit.ActionType__c = 'MASS_UPDATE';
                        audit.ObjectIds__c = System.JSON.serialize(newTriggerMap.keySet());
                    } 
                } 
            } 
            insert audit; 
        } catch (Exception e) {System.Debug('___GOT AN EXCEPTION____');} 
    }
    
    
    public static void checkJiveIntegrationCriteria(Account newVersion, Account oldVersion){
        Boolean goAhead = false;
        String conString = '';
        if(newVersion.Type != oldVersion.Type){
            conString = '#Type#' +newVersion.Type+ '#Type1#'; 
            goAhead = true;
        }
        if(newVersion.Partner_Type__c!= oldVersion.Partner_Type__c){
            conString += '#PartnerType#' +newVersion.Partner_Type__c+ '#PartnerType1#';           
            goAhead = true;
        }
        if(newVersion.CAM_Owner__c!= oldVersion.CAM_Owner__c){
            conString += '#CAMowner#' +newVersion.CAM_Owner__c+ '#CAMowner1#';
            goAhead = true;
        }
        if(newVersion.Engagement_Mgr_Owner__c!= oldVersion.Engagement_Mgr_Owner__c){
            conString += '#EngagementMgrOwner#' +newVersion.Engagement_Mgr_Owner__c+ '#EngagementMgrOwner1#';
            goAhead = true;
        } 
        if(newVersion.BillingCountry!= oldVersion.BillingCountry) {
            if(newVersion.BillingCountry == 'Australia' || newVersion.BillingCountry =='New Zealand'){            
                conString += '#SalesRegion#APAC#SalesRegion1#';
            }else if(newVersion.BillingCountry =='United States' || newVersion.BillingCountry =='Canada' || newVersion.BillingCountry =='US' || newVersion.BillingCountry =='USA'){            
                conString += '#SalesRegion#North America#SalesRegion1#';
            }else if(newVersion.BillingCountry == 'Bermuda' || newVersion.BillingCountry =='Uruguay' || newVersion.BillingCountry =='Colombia'){            
                conString += '#SalesRegion#Other#SalesRegion1#';
            }else{            
                conString += '#SalesRegion#EMEA#SalesRegion1#';
            }
            goAhead = true;
        } 
        if(goAhead) accWithChangedStringMap.put(newVersion.Id, conString); 
    }
    
    public static void updateJiveProfileFromSFDC(){
        if(System.isBatch() || System.isFuture() || Label.JiveSyncEnable !='True') return;
        
        Map<id, string> ConIdEmailMap  = new Map<id, string>();
        Map<id, string> ConIDStringMap = new Map<id, string>();
        for(contact temp : [SELECT Id, Email, Accountid FROM Contact WHERE Accountid IN: accWithChangedStringMap.keyset()]) {
            ConIDStringMap.put(temp.id, accWithChangedStringMap.get(temp.accountid));
            ConIdEmailMap.put(temp.id, temp.email);
        }
        
        if(ConIdEmailMap.isEmpty() == FALSE && ConIDStringMap.isEmpty() == FALSE) { 
                if(!System.IsBatch()){
                    if([SELECT count() FROM AsyncApexJob WHERE JobType='BatchApex' AND (Status = 'Processing' OR Status = 'Preparing')] < 5){ 
                        SfdcJiveHelper cqrb = new SfdcJiveHelper(ConIdEmailMap, ConIDStringMap);            
                        //Execute the batch, 40 Contact at a time.
                        database.executeBatch(cqrb,40);
                    }else { 
                        System.ScheduleBatch(new SfdcJiveHelper(ConIdEmailMap, ConIDStringMap) , 'Batch jiveSFDCUpdate to update contact-After limit exceeded'+Datetime.now() , 30);                                            
                    }
                }else{            
                    System.ScheduleBatch(new SfdcJiveHelper(ConIdEmailMap, ConIDStringMap) , 'Batch jiveSFDCUpdate to update contact-After limit exceeded'+Datetime.now() , 30);                    
                }
            } else {
            system.debug('<=== Nothing found:===> ');
        } 
    }
    
    
      public static Map<ID,String> TerritoryName(List<Account> accIds){
        Map<ID,String> accountAndTerritoryMap = new Map<ID,String>();
        Map<ID,Set<ID>> territoryIdAndAccountIdMap = new Map<ID,Set<ID>>();
        Map<ID,Set<ID>> groupIdAndAccountIdMap = new Map<ID,Set<ID>>();
         
        
        for(AccountShare accshare : [SELECT Id, ACCOUNTID, UserOrGroupId, RowCause FROM AccountShare WHERE AccountID IN: accIds AND RowCause IN ('Territory', 'TerritoryManual')]){
             Set<ID> newaccIDs = new Set<ID>();
            if(!groupIdAndAccountIdMap.containsKey(accshare.UserOrGroupId)){
                
                newaccIDs.add(accshare.ACCOUNTID);
                groupIdAndAccountIdMap.put(accshare.UserOrGroupId, newaccIDs); 
            }else{
                //newaccIDs = new Set<ID>();
                newaccIDs = groupIdAndAccountIdMap.get(accshare.UserOrGroupId);
                newaccIDs.add(accshare.ACCOUNTID);
                groupIdAndAccountIdMap.put(accshare.UserOrGroupId, newaccIDs); 
            }
        }
        
    
        for(Group grp : [SELECT Id, RelatedID, Type FROM Group WHERE Type = 'Territory' AND Id IN : groupIdAndAccountIdMap.keySet()]){
            if(groupIdAndAccountIdMap.containsKey(grp.Id)){
                territoryIdAndAccountIdMap.put(grp.RelatedID, groupIdAndAccountIdMap.get(grp.Id));
            }
        }
    
        for(Territory ter : [SELECT Id, Name FROM Territory WHERE Id IN: territoryIdAndAccountIdMap.keySet() ]){
            if(territoryIdAndAccountIdMap.containsKey(ter.Id)){
                for(ID setid : territoryIdAndAccountIdMap.get(ter.Id)){
                    if(!accountAndTerritoryMap.containsKey(setid)){
                        accountAndTerritoryMap.put(setid, ter.Name);
                    }
                    else{
                        String TRNAME = accountAndTerritoryMap.get(setid)+', '+ter.Name;
                        accountAndTerritoryMap.put(setid, TRNAME);
                    }
                }
            }
        }
        if(!accountAndTerritoryMap.isEmpty()){
            return accountAndTerritoryMap;
        }else{
            return null;
        }
      
    }
	
     /*************** beforeInsertHandlerInBulk  # APPS-20692 *****************/
     
     public static void updateBusinessUnitsAMER(Account ac)
     {
         if(ac.type=='Partner')
             ac.Business_Unit__c ='AMER - Channel';
         else if(ac.Employees_Override__c > 1500 && ac.type!='Partner' && ac.Business_Unit__c!='AMER - ENT')
             ac.Business_Unit__c ='AMER - ENT';
         else if(ac.Employees_Override__c > 25 && ac.Employees_Override__c <= 500 && ac.type!='Partner' && ac.Business_Unit__c!='AMER - MM')
             ac.Business_Unit__c ='AMER - Growth';
         else if(ac.Employees_Override__c > 500 && ac.Employees_Override__c <= 1500 && ac.type!='Partner' && ac.Business_Unit__c!='AMER - MM')
             ac.Business_Unit__c ='AMER - MM';
         else if(ac.Employees_Override__c <= 25 && ac.type!='Partner' && ac.Business_Unit__c!='AMER - SB'&& ac.Employees_Override__c > 0)
             ac.Business_Unit__c = 'AMER - SB';
         else if((ac.Employees_Override__c == 0 || ac.Employees_Override__c == NULL) &&  ac.type!='Partner') 
             ac.Business_Unit__c = 'AMER - Unknown';
             
     }
     
     public static void updateBusinessUnitsANZ(Account ac)
     {
         if(ac.type=='Partner')
             ac.Business_Unit__c ='ANZ - Channel';
         else if(ac.Employees_Override__c > 1000 && ac.type!='Partner')
             ac.Business_Unit__c ='ANZ - ENT';
         else if(ac.Employees_Override__c > 100 && ac.Employees_Override__c <= 1000 && ac.type!='Partner')
             ac.Business_Unit__c = 'ANZ - MM';
         else if(ac.Employees_Override__c <= 100 && ac.type!='Partner')
             ac.Business_Unit__c = 'ANZ - SB';
         else if((ac.Employees_Override__c == 0 || ac.Employees_Override__c == NULL) && ac.type!='Partner')
             ac.Business_Unit__c = 'ANZ - Unknown';
     }
     public static void updateBusinessUnitsAPAC(Account ac)
     {
        if(ac.type=='Partner')
             ac.Business_Unit__c = 'APAC - Channel';
        else if(ac.Employees_Override__c > 1000 && ac.type!='Partner')
             ac.Business_Unit__c ='APAC - ENT'; 
        else if(ac.Employees_Override__c > 100 && ac.Employees_Override__c <= 1000 && ac.type!='Partner')
             ac.Business_Unit__c = 'APAC - MM'; 
        else if(ac.Employees_Override__c <= 100 && ac.type!='Partner')
             ac.Business_Unit__c = 'APAC - SB';
        else if((ac.Employees_Override__c == 0 || ac.Employees_Override__c == NULL) && ac.type!='Partner')
             ac.Business_Unit__c = 'APAC - Unknown'; 
     }
     public static void updateBusinessUnitsEMEA(Account ac)
     {
        if(ac.type=='Partner')
             ac.Business_Unit__c = 'EMEA - Channel';
        else if(ac.Employees_Override__c > 1000 && ac.type!='Partner')
             ac.Business_Unit__c ='EMEA - ENT'; 
         
        else if(ac.Employees_Override__c <= 1000 && ac.type!='Partner')
             ac.Business_Unit__c = 'EMEA - SB';
        else if((ac.Employees_Override__c == 0 || ac.Employees_Override__c ==NULL) && ac.type!='Partner')
             ac.Business_Unit__c = 'EMEA - Unknown'; 
     }
     public static void updateBusinessUnitsJPN(Account ac)
     {
        if(ac.type=='Partner')
             ac.Business_Unit__c = 'JPN - Channel'; 
         else if(ac.Employees_Override__c > 400 && ac.type!='Partner')
             ac.Business_Unit__c ='JPN - ENT';
         else if(ac.Employees_Override__c <= 400 && ac.type!='Partner')
             ac.Business_Unit__c ='JPN - SB';
         else if((ac.Employees_Override__c == 0 || ac.Employees_Override__c == NULL) && ac.type!='Partner')
             ac.Business_Unit__c = 'JPN - Unknown'; 
         
     }
     public static void updateBusinessUnitsLATAM(Account ac)
     {
        if(ac.type=='Partner')
             ac.Business_Unit__c = 'LATAM - Channel';
        else if(ac.Employees_Override__c > 1500 && ac.type!='Partner')
             ac.Business_Unit__c ='LATAM - ENT'; 
        else if(ac.Employees_Override__c > 500 && ac.Employees_Override__c <= 1500 && ac.type!='Partner')
             ac.Business_Unit__c = 'LATAM - MM'; 
        else if(ac.Employees_Override__c <= 500 && ac.type!='Partner')
             ac.Business_Unit__c = 'LATAM - SB';
        else if((ac.Employees_Override__c == 0 || ac.Employees_Override__c == NULL) && ac.type!='Partner')
             ac.Business_Unit__c = 'LATAM - Unknown'; 
     }
     /*******************   beforeInsertHandlerInBulk -ends #APPS-20692 *******************************/   
        
    /***TOOLS & UTILITY- ENDS**/
}