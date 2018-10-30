/************************************************************************
Updated by : Aman Gupta
Updated On : 17 Aug 2018
Updated For :
#APPS-20692  : Business Unit Migration to Code
#Created six methods handling the business unit

Updated by: Jade Global Inc.
Updated On: 4th June 2017
Updated for: 
# Reference: SDR Owner Functionality and RF field reference removal
# Jira Ticket: APPS-13173: Tasks in the Requirement document for Sprint 4
*************************************************************************/

/**
THIS CLASS IS NAVIGATOR- TAKES EACH EVENT FROM TRIGGER AND DELEGATES TO AN APPROPRIATE EXECUTOR.
DESIGNED BY: GRAZITTI

DEVELOPER INSTRUCTIONS:
1. TRY TO KEEP YOUR LOGIC IN MASTER LOOP. AVOID NEW LOOP ADDITION.
2. CREATE A HELPER METHOD TO HANDLE THE LOGICS
3. DO NOT ADD ANY NEW DML OPERATION- TRY TO ADD DATA TO BE MANIPULATE IN EXISTING DMLs.
4. DO NOT ADD ANY SOQL REDUNDANTLY 
**/

/**************************************************************
last modified by : Sumit Bhatt, Grazitti Interactive
last Modified Date : 13-April-2018
changes done: #APPS-10924# Remove functionality that is not needed for Account Score
Tracking : One can track the changes by searching the ticket number in the code 
**************************************************************/

public class Account_MAIN_TriggerHandler {  

    public static Boolean isAccountTriggerExecuted = False;
    //public static AccountScorerSettings__c setting =  AccountScorerSettings__c.getInstance('executionsetting'); APPS-10924
    /***----------------------------------------------------------------------------------------------------------------------------------
    BEFORE INSERT HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE BEFORE INSERTING THE RECORDS
    -----------------------------------------------------------------------------------------------------------------------------------***/      
    public static void beforeInsertHandlerInBulk(List<Account> newList, Map<Id, Account> newMap){
        try{
            /**RECURSION HANDLING**/
            if(Account_MainTriggerHelper.isBeforeInsertHandler) return;
            Account_MainTriggerHelper.isBeforeInsertHandler = True;                        
            Map<Id, String> AccountTerritoryMap =  Account_MainTriggerHelper.TerritoryName(newList);
            List<Id> accNBAEIds = new List<Id>();
            
            /**ACCOUNT SCORER TRIGGER PREREQUISITES**/            
           //Boolean invokeAccountScorerTrigger = false; APPS-10924
            
            
            /**MASTER LOOP - ON NEW VERSION OF RECORDS**/
            for(Account ac :  newList) {
				 // Code Added as per the Ticket Apps-20692
				  String parentAccCountry = ac.BillingCountry;
                if(parentAccCountry != NULL)
                {
                    System.debug('Inside before insert------'+ parentAccCountry);
                    Pattern pAMER = Pattern.compile(Label.ParentAccountAMER);
                    Matcher mAMER = pAMER .matcher(parentAccCountry);
                    Pattern pANZ =  Pattern.compile(Label.ParentAccountANZ);
                    Matcher mANZ =  pANZ.matcher(parentAccCountry);
                    Pattern pAPAC = Pattern.compile(Label.ParentAccountAPAC);
                    Matcher mAPAC = pAPAC.matcher(parentAccCountry);
                    Pattern pEMEA = Pattern.compile(Label.ParentAccountEMEA);
                    Matcher mEMEA = pEMEA.matcher(parentAccCountry);
                    Pattern pJPN  =  Pattern.compile(Label.ParentAccountJPN);
                    Matcher mJPN  =  pJPN.matcher(parentAccCountry);
                    Pattern pLATAM =  Pattern.compile(Label.ParentAccountLATAM);
                    Matcher mLATAM =  pLATAM.matcher(parentAccCountry);
                    if(mAMER.matches())
                    {
                        Account_MainTriggerHelper.updateBusinessUnitsAMER(ac);
                    }
                    else if(mANZ.matches())
                    {
                        Account_MainTriggerHelper.updateBusinessUnitsANZ(ac);
                    }
                    else if(mAPAC.matches())
                    {
                        Account_MainTriggerHelper.updateBusinessUnitsAPAC(ac);
                    }
                    else if(mEMEA.matches())
                    {
                        Account_MainTriggerHelper.updateBusinessUnitsEMEA(ac);
                    }
                    else if(mJPN.matches())
                    {
                        Account_MainTriggerHelper.updateBusinessUnitsJPN(ac);
                    }
                    else if(mLATAM.matches())
                    {
                        Account_MainTriggerHelper.updateBusinessUnitsLATAM(ac);
                    }
                } // End of Apps-20692
                
                /**--PROCESS 1: COPY TERRITORRY INFORMATION IN ACCOUNT CUSTOM FIELD. LEGACY TRIGGER: "accountB4InsertB4Update".--***/                              
                ac = Account_MainTriggerHelper.populateTerritoties(ac, AccountTerritoryMap); 
                              
                /**--PROCESS 2: UPDATE CUSTOMER LIFECYCLE STAGE FROM CLARIZEN PROJECTS. LEGACY FROM TRIGGER: "accountB4InsertB4Update".--- **/ 
                ac = Account_MainTriggerHelper.populateLifeCycleStage(ac);
                
                /**--PROCESS 3: AUTOPOPULATE INTACCT INFO IN ACCOUNT CUSTOM FIELDS. LEGACY FROM TRIGGER: "accountB4InsertB4Update".--**/
                ac = Account_MainTriggerHelper.populateIntacctFields(ac);
                
                /**--PROCESS 4: SET A SCORE TO ACCOUNT. LEGACY FROM TRIGGER: "accountScorerTrigger".--**/
                //invokeAccountScorerTrigger = Account_MainTriggerHelper.isAccountScorerIsQualified(ac, new Account(), true);  APPS-10924         
                                
                /**--PROCESS 5: POPULATE NEW BUSINESS ACCOUNT EXECUTIVE FIELD ON ACCOUNT. MOVED FROM TRIGGER: "accountB4InsertB4Update"--**/ 
                if(Account_MainTriggerHelper.nbae_assignment(ac, new Account(), false)){
                    accNBAEIds.add(ac.Id);
                }
                
                /**--PROCESS 6: POPULATE SDP FIELDS ON ACCOUNT AND CAM ASSIGNMENT HANDLING. MOVED FROM TRIGGER: "accountTrigger".--- **/ 
               // ac = Account_MainTriggerHelper.accountTrigger_updateSDPFields(ac);
                
                /**--PROCESS 7: ASSIGN CAM OWNER ON ACCOUNT DYNAMICALLY. MOVED FROM TRIGGER: "accountTrigger"--**/   
                Account_MainTriggerHelper.isCAM_AssignmentPasssed(ac);  

                /**--PROCESS 8: Assign Industry when Reach Force change the RF Industry on Account **/
               // ac = Account_MainTriggerHelper.populateRFIndustry(ac,ac);  
                
            } 
            
            /***---FINAL DESTINATION:- PERFORM ALL BULK OPERATIONS, - PERFORM DML OPERATION, ASYNCHRONOUS OPERATIONS (FUTURE, BATCHES & SCHEDULERS)---****/
            
            /**--PROCESS 5: POPULATE NEW BUSINESS ACCOUNT EXECUTIVE FIELD ON ACCOUNT. MOVED FROM TRIGGER: "accountB4InsertB4Update"--**/  
            Account_MainTriggerHelper.process_NBAE_assignment(newList, accNBAEIds);
            /* APPS-10924 if(setting!=null && setting.Disable_Account_Score_Trigger__c == false){
                if(invokeAccountScorerTrigger) Account_MainTriggerHelper.accountScorerTrigger(newList);
            } APPS-10924 */ 
             //Method call for SDR Owner population on Account insert
            //Added by Jade Global Inc
            //Date: 24th May 2017
             Account_MainTriggerHelper.accountTrigger_updateSDPFieldsNew1(trigger.new,null);
            
            /**--PROCESS 6: POPULATE SDP FIELDS ON ACCOUNT AND CAM ASSIGNMENT HANDLING. MOVED FROM TRIGGER: "accountTrigger".--- **/ 
            Account_MainTriggerHelper.updateSDP_Fields();
            
            /**--PROCESS 7: ASSIGN CAM OWNER ON ACCOUNT DYNAMICALLY. MOVED FROM TRIGGER: "accountTrigger"--**/               
            Account_MainTriggerHelper.processCAM_assignment(newList);
            
            /**FINALLY PEROFRM ALL DML OPERATIONS**/
            Account_MainTriggerHelper.FINALLY_DMLS();                       
            
        }catch(Exception ex){ newList[0].addError(ex.getMessage());}
    }
    
    /***-----------------------------------------------------------------------------------------------------------
    BEFORE UPDATE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE BEFORE UPDATING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/    
    public static void beforeUpdateHandlerInBulk(List<Account> newList, Map<Id, Account> newMap, List<Account> oldList, Map<Id, Account> oldMap){
        try{
            /**RECURSION HANDLING**/
            if(Account_MainTriggerHelper.isBeforeUpdateHandler) return;
            Account_MainTriggerHelper.isBeforeUpdateHandler = True;      
            
            Map<Id, String> AccountTerritoryMap =  Account_MainTriggerHelper.TerritoryName(newList);
            List<Id> accNBAEIds = new List<Id>();
            
            /**ACCOUNT SCORER TRIGGER PRERQUISITES**/            
            //Boolean invokeAccountScorerTrigger = false; APPS-10924
            
            /**MASTER LOOP - ON NEW VERSION OF RECORDS**/
            for(Account ac :  newList) {
            // Code Added as per the Ticket Apps-20692
			  Account oldAcc = oldMap.get(ac.Id);
                String parentAccCountry = ac.BillingCountry;
                if(parentAccCountry != NULL)
                {
                    System.debug(parentAccCountry);
                    System.debug('Old account ----' + oldAcc);
                    Boolean isChanged = false;
                    if(ac.BillingCountry != oldAcc.BillingCountry || ac.Type != oldAcc.Type || ac.Employees_Override__c!= oldAcc.Employees_Override__c || ac.Business_Unit__c != oldAcc.Business_Unit__c)
                        isChanged = true;
                    Pattern pAMER = Pattern.compile(Label.ParentAccountAMER);
                    Matcher mAMER = pAMER.matcher(parentAccCountry);
                    Pattern pANZ = Pattern.compile(Label.ParentAccountANZ);
                    Matcher mANZ = pANZ.matcher(parentAccCountry);
                    Pattern pAPAC = Pattern.compile(Label.ParentAccountAPAC);
                    Matcher mAPAC = pAPAC.matcher(parentAccCountry);
                    Pattern pEMEA = Pattern.compile(Label.ParentAccountEMEA);
                    Matcher mEMEA = pEMEA.matcher(parentAccCountry);
                    Pattern pJPN = Pattern.compile(Label.ParentAccountJPN);
                    Matcher mJPN = pJPN.matcher(parentAccCountry);
                    Pattern pLATAM =  Pattern.compile(Label.ParentAccountLATAM);
                    Matcher mLATAM =  pLATAM.matcher(parentAccCountry);
                    if(mAMER.matches() && isChanged)
                    {
                        Account_MainTriggerHelper.updateBusinessUnitsAMER(ac);
                    }
                    else if(mANZ.matches() && isChanged)
                    {
                        Account_MainTriggerHelper.updateBusinessUnitsANZ(ac);
                    }
                    else if(mAPAC.matches() && isChanged)
                    {
                        Account_MainTriggerHelper.updateBusinessUnitsAPAC(ac);
                    }
                    else if(mEMEA.matches() && isChanged)
                    {
                        Account_MainTriggerHelper.updateBusinessUnitsEMEA(ac);
                    }
                    else if(mJPN.matches() && isChanged)
                    {
                        Account_MainTriggerHelper.updateBusinessUnitsJPN(ac);
                    }
                    else if(mLATAM.matches() && isChanged)
                    {
                        Account_MainTriggerHelper.updateBusinessUnitsLATAM(ac);
                    }
                } // End of Apps -20692
                 /**PROCESS 1: COPY TERRITORRY INFORMATION IN ACCOUNT CUSTOM FIELD.
                    MOVED FROM TRIGGER: "accountB4InsertB4Update".
                ***/                                
                ac = Account_MainTriggerHelper.populateTerritoties(ac, AccountTerritoryMap); //populate territories in custom field
                              
                /**--PROCESS 2: UPDATE CUSTOMER LIFECYCLE STAGE FROM CLARIZEN PROJECTS. MOVED FROM TRIGGER: "accountB4InsertB4Update".--**/ 
                ac = Account_MainTriggerHelper.populateLifeCycleStage(ac);
                
                /**PROCESS 3: AUTOPOPULATE INTACCT INFO IN ACCOUNT CUSTOM FIELDS.
                   MOVED FROM TRIGGER: "accountB4InsertB4Update".
                **/
                ac = Account_MainTriggerHelper.populateIntacctFields(ac);
                
                /**PROCESS 4: SET A SCORE TO ACCOUNT.
                   MOVED FROM TRIGGER: "accountScorerTrigger".
                **/
                //invokeAccountScorerTrigger = Account_MainTriggerHelper.isAccountScorerIsQualified(ac, new Account(), true);   APPS-10924    
                
                /**PROCESS 5: POPULATE NEW BUSINESS ACCOUNT EXECUTIVE FIELD ON ACCOUNT
                   MOVED FROM TRIGGER: "accountB4InsertB4Update".
                **/ 
                if(Account_MainTriggerHelper.nbae_assignment(ac, oldMap.get(ac.Id), true)){
                    accNBAEIds.add(ac.Id);
                }
                
                /**PROCESS 6: POPULATE SDP FIELDS ON ACCOUNT
                   MOVED FROM TRIGGER: "accountTrigger".
                **/ 
              //  ac = Account_MainTriggerHelper.accountTrigger_updateSDPFields(ac);
                
                /**PROCESS 7: ASSIGN CAM OWNER ON ACCOUNT DYNAMICALLY
                   MOVED FROM TRIGGER: "accountTrigger".
                **/   
                Account_MainTriggerHelper.isCAM_AssignmentPasssed(ac);
                
                /**--PROCESS 8: Assign Industry when Reach Force change the RF Industry on Account **/
               // ac = Account_MainTriggerHelper.populateRFIndustry(ac,oldMap.get(ac.Id)); 
            
            } 
            
            /*****FINAL DESTINATION:
            - PERFORM ALL BULK OPERATIONS
            - PERFORM DML OPERATION- 
            - ASYNCHRNOUS OPERATIONS (FUTURE, BATCHES & SCHEDULERS)
            - SEND EMAILS
            ****/
            
            /**PROCESS 5: POPULATE NEW BUSINESS ACCOUNT EXECUTIVE FIELD ON ACCOUNT
               MOVED FROM TRIGGER: "accountB4InsertB4Update".
            **/ 
            Account_MainTriggerHelper.process_NBAE_assignment(newList, accNBAEIds);
            
        /* APPS-10924 if(setting!=null && setting.Disable_Account_Score_Trigger__c == false){
            if(invokeAccountScorerTrigger)Account_MainTriggerHelper.accountScorerTrigger(newList);            
        } APPS-10924 */
        
            //Method call for SDR Owner population on Account insert
            //Added by Jade Global Inc
            //Date: 24th May 2017
            Account_MainTriggerHelper.accountTrigger_updateSDPFieldsNew1(newList,oldMap);
            
            /**PROCESS 6: POPULATE SDP FIELDS ON ACCOUNT
               MOVED FROM TRIGGER: "accountTrigger".
            **/ 
            Account_MainTriggerHelper.updateSDP_Fields();
            
            /**PROCESS 7: ASSIGN CAM OWNER ON ACCOUNT DYNAMOCALLY
               MOVED FROM TRIGGER: "accountTrigger".
            **/  
             Account_MainTriggerHelper.processCAM_assignment(newList);
           
            /**FINALLY PEROFRM ALL DML OPERATIONS**/
            Account_MainTriggerHelper.FINALLY_DMLS();            
            
        }catch(Exception ex){ newList[0].addError(ex.getMessage());}
    }
    
    /***-----------------------------------------------------------------------------------------------------------
    BEFORE DELETE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE BEFORE DELETING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/   
    public static void beforeDeleteHandlerInBulk(List<Account> newList, Map<Id, Account> newMap){
        if(Account_MainTriggerHelper.isBeforeDeleteHandler) return;           
        Account_MainTriggerHelper.isBeforeDeleteHandler = True;
            
        //PLACE HERE YOUR CODE!!!
    }
    
    /***-----------------------------------------------------------------------------------------------------------
    AFTER INSERT HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER INSERTING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/   
    public static void afterInsertHandlerInBulk(List<Account> newList, Map<Id, Account> newMap){
        try{
        
            if(Account_MainTriggerHelper.isAfterInsertHandler) return;
            Account_MainTriggerHelper.isAfterInsertHandler = True;
            
            List<Account> accounts  = new List<Account>();
            List<Id> userids        = new List<Id>();
            Set<Id> accountIds      = new Set<Id>();
            
            for(Account ac : newList) {
            
                /**TRIGGER: UpdateUserBadge
                UPDATE USER BADGE TAG FUNCTIONALITY WHEN AN ACCOUNT BECOMES CUSTOMER***/
                accountIds.add(ac.Id);
            /*  
                if(Account_MainTriggerHelper.isUpdateUserBadgeTagQualified(ac, new Account(), false)) {
                    accounts.add(ac);
                    userids.add(ac.ownerid);
                } 
            */    
                /**** CREATETASL TRIGGER- FUNCTIONALITY ***/
                // ***************** COMMENTING AS BELOW FUNCTIONALITY NO LONGER REQUIRED ***********************//
                /*
                if(Account_MainTriggerHelper.createTaskTriggerQualified(ac, new Account(), false)){
                   Account_MainTriggerHelper.createTaslTrigger(ac);
                }
                */
                         
            }
            
            /*****FINAL DESTINATION- PERFORM DML OPERATION- FUTURE- BATCHES****/
        //    Account_MainTriggerHelper.updateUserBadgeTag(accountIds, accounts, userids, false);
            
            //****** BELOW MENTIONED FUNCTIONALITY NO LONGER REQUIRED**********//
            //Account_MainTriggerHelper.commitCreateTaslTrigger();
            
            //**@@-- BELOW METHODS HANDLES THE AccountAdallomTrigger TRIGGER PROCESS
            Account_MainTriggerHelper.AccountAdallomTrigger(newList, newMap, null, null);
            
            /*** CAM ASSIGNMENT EMAIL FUNCTIONALITY***/
            //CAM_Assignment_Email.triggerHandler(Trigger.old, Trigger.new);     
                  
            
        }catch(Exception ex){ newList[0].addError(ex.getMessage());}
    }
    
    /***-----------------------------------------------------------------------------------------------------------
    AFTER UPDATE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER UPDATING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/   
    public static void afterUpdateHandlerInBulk(List<Account> newList, Map<Id, Account> newMap, List<Account> oldList, Map<Id, Account> oldMap){
        try{
            if(Account_MainTriggerHelper.isAfterUpdateHandler) return;
            Account_MainTriggerHelper.isAfterUpdateHandler = True;
        
            // NEW CODE ADDED TO HANDLE CPU LIMIT EXCEEDED EXCEPTION
            Set<Id> qualfieldAccIds = new Set<Id>();
            Set<Id> qualfieldCAMAccIds = new Set<Id>();
            List<Id> userids        = new List<Id>();
            Set<Id> accountIds      = new Set<Id>();
            List<Account> accounts  = new List<Account>();
            // Call this Method to insert an EWS activity Added on September 29, 2016 - Grazitti Interactive - Jatin Narula
            Map<Id,List<EWSUtility.activityInfoWrapper>> accountIdsForEWSMap = new Map<Id,List<EWSUtility.activityInfoWrapper>>();
            try{
                if(Test.isRunningTest() || Label.EWSActivator == 'YES'){accountIdsForEWSMap = EWSUtility.createrEWSActivitiesForAccounts();}
            }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            
            /**MASTER LOOP - ON NEW VERSION OF RECORDS**/
            for(Account ac :  newList) {
                
                /**SYNC OWNER/SDR OWNER***/      
                if(Account_MainTriggerHelper.isOwnerSyncNeeded(ac, oldMap.get(ac.Id))) {
                    qualfieldAccIds.add(ac.id);
                }
                  /**SYNC CAM OWNER**/
                if(Account_MainTriggerHelper.isCAMOwnerSyncNeeded(ac, oldMap.get(ac.Id))) {
                    qualfieldCAMAccIds.add(ac.id);
                }
                /**TRIGGER: UpdateUserBadge
                UPDATE USER BADGE TAG FUNCTIONALITY WHEN AN ACCOUNT BECOMES CUSTOMER***/
                accountIds.add(ac.Id);                
        /*        if(Account_MainTriggerHelper.isUpdateUserBadgeTagQualified(ac, oldMap.get(ac.id), true)) {
                    accounts.add(ac);
                    userids.add(ac.ownerid);
                } 
        */        
                /**** CREATETASL TRIGGER- FUNCTIONALITY ***/
                // ***************** COMMENTING AS BELOW FUNCTIONALITY NO LONGER REQUIRED ***********************//
                /*
                if(Account_MainTriggerHelper.createTaskTriggerQualified(ac, new Account(), false)){
                   Account_MainTriggerHelper.createTaslTrigger(ac);
                }
                */
                /***** Datanyze Trigger Qualtifying Criteria *****/
                if(Account_MainTriggerHelper.alertDatanyzeUpdate(ac)){
                    Account_MainTriggerHelper.processAlertDatanyzeUpdate(ac, oldMap.get(ac.id));
                }  
                
                /**----Jive profile integration----**/
                Account_MainTriggerHelper.checkJiveIntegrationCriteria(ac, oldMap.get(ac.id));          
            }
            
            /*****FINAL DESTINATION- PERFORM DML OPERATION- FUTURE- BATCHES****/
            /***Added on August 31,2016 By - GRAZITTI INTERACTIVE__for EWS___*****/
            try{
                if((Test.isRunningTest() || Label.EWSActivator == 'YES') && accountIdsForEWSMap != null && !accountIdsForEWSMap.isEmpty()){EWSUtility.createrEWSActivities(accountIdsForEWSMap);}    
            }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            
            /***Added on August 31,2016 By - GRAZITTI INTERACTIVE__for EWS___***/
        //    Account_MainTriggerHelper.updateUserBadgeTag(accountIds, accounts, userids, true);
            Account_MainTriggerHelper.updateContactOwnerAsAccountOwner(qualfieldAccIds,newMap); 
            
            //****** BELOW MENTIONED FUNCTIONALITY NO LONGER REQUIRED**********//
            //Account_MainTriggerHelper.commitCreateTaslTrigger();
            
            //**@@-- BELOW METHODS HANDLES THE AccountAdallomTrigger TRIGGER PROCESS
            Account_MainTriggerHelper.AccountAdallomTrigger(newList, newMap, oldList, oldMap);
            
            /**** AlertDatanyze Email notifications ****/
            Account_MainTriggerHelper.commitAlerDatanyzeProcess(newMap);
            
            /**----Jive profile integration----**/
            Account_MainTriggerHelper.updateJiveProfileFromSFDC();       

            /**--Used for populating CAM Owner as Opportunity Renewal Owner--**/
            Account_MainTriggerHelper.updateCAMOwnerAsOpportunityOwner(qualfieldCAMAccIds,newMap); 
      
            
        }catch(Exception ex){ newList[0].addError(ex.getMessage());}
    }
    
    
    /***-----------------------------------------------------------------------------------------------------------
    AFTER DELETE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER DELETING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/   
    public static void afterDeleteHandlerInBulk(List<Account> oldList, Map<Id, Account> oldMap){
        if(!Account_MainTriggerHelper.isAfterDeleteHandler){
            Account_MainTriggerHelper.isAfterDeleteHandler = true; 
            
            //**@@-- BELOW METHODS HANDLES THE AccountAdallomTrigger TRIGGER PROCESS
            Account_MainTriggerHelper.AccountAdallomTrigger(null, null, oldList, oldMap);
        }
    }
}