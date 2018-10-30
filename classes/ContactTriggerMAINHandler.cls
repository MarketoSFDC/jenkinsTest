/************************************************************************
Updated by: Jade Global Inc.
Updated On: 4th June 2017
Updated for: 
# Reference:Added Code for SDR Owner Functinality
# Jira Ticket: APPS-13173: Tasks in the Requirement document for Sprint 4

Last Modified By: Priyanka Shende on 4th July 2018
Purpose         : APPS-20985: Request to Update Apex Code on Account 
*************************************************************************/

//******   This is the Handler Class for the ContactTriggerMAIN Trigger *************//
public class ContactTriggerMAINHandler{    
    
    public static boolean isTriggerExecuted             = false;
    public static boolean isBeforeInsertHandlerExecuted = false;
    public static boolean isBeforeUpdateHandlerExecuted = false;
    public static boolean isAfterInsertHandlerExecuted  = false;
    public static boolean isAfterUpdateHandlerExecuted  = false;
    public static boolean isAfterDeleteHandlerExecuted  = false;
    
    public static Set<Id> accountIds;
    public static Set<Id> contactOwnerIds;
    public static Map<Id,Contact> accContactMap;
    public static Map<Id,Account> masterAccountMap;
    public static List<JBCXM__Milestone__c> MilestonesToInsert;
    public static set<id> SetAccIdsForSDROwnerLookup;
    
    public static void InitializeGlobalVariables(){
        accountIds          = new Set<Id>();
        contactOwnerIds     = new Set<Id>();
        accContactMap       = new Map<Id,Contact>();
        masterAccountMap    = new Map<Id,Account>();
        MilestonesToInsert  = new List<JBCXM__Milestone__c>();
        SetAccIdsForSDROwnerLookup = new set<id>();
    }    
    
    public static void beforeInsertHandler(List<Contact> triggerNew, Map<Id, Contact> triggerOldMap) {          
        if(!isBeforeInsertHandlerExecuted){
            isBeforeInsertHandlerExecuted = true;
            
            InitializeGlobalVariables();
            for(Contact con : triggerNew){       
                //1. FILTER CONTACT OWNER 
                contactOwnerIds.add(con.OwnerID);//SET OF CONTACT OWNER ID's
                //2. SDR OWNER UPDATE
                // checkSDROwnerCrietria(con,con);
            }            
            //INVOKE METHOD TO PERFORM BULK OPERATION ON FILTERED RECORDS 
            contactOwnerTerritoryPopulator(triggerNew,contactOwnerIds);
            updateSDROwnerCrietria(triggerNew);
            
            //Method Call Added by Jade Global Inc
            //Date: 10th May 2017
            //This method will run on Contact before insert to populate the SDR Owner fields on Contact
            populateSDROwnerFieldsOnContact(triggerNew,null);
        }               
    }
    
    public static void beforeUpdateHandler(List<Contact> triggerNew,Map<Id, Contact> newMap,List<Contact> oldList, Map<Id, Contact> triggerOldMap) {   
        if(!isBeforeUpdateHandlerExecuted){
            isBeforeUpdateHandlerExecuted = true;
            
            InitializeGlobalVariables();
            for(Contact con : triggerNew){            
                //1. FILTER CONTACT OWNER 
                contactOwnerIds.add(con.OwnerID);//SET OF CONTACT OWNER ID's
                accountIds.add(con.AccountID); 
                
                populateStageBeforeTouchOnContact(con, triggerOldMap);               
                //2. SDR OWNER UPDATE
                // checkSDROwnerCrietria(con,triggerOldMap.get(con.id));
            }            
            //INVOKE METHOD TO PERFORM BULK OPERATION ON FILTERED RECORDS 
            contactOwnerTerritoryPopulator(triggerNew,contactOwnerIds);
            GainsightContactTrigger(triggerNew, triggerOldMap);
            updateSDROwnerCrietria(triggerNew);
            
            //Method Call Added by Jade Global Inc
            //Date: 10th May 2017
            //This method will run on Contact before update to populate the SDR Owner fields on Contact
            populateSDROwnerFieldsOnContact(triggerNew,triggerOldMap);
        }
        
    }
    
    public static void afterInsertHandler(List<Contact> triggerNew, Map<Id,Contact> newMap) {
        if(!isAfterInsertHandlerExecuted){
            isAfterInsertHandlerExecuted = true;
            /***Added on September 30,2016 By - GRAZITTI INTERACTIVE  ___for EWS___***/
            Map<Id,List<EWSUtility.activityInfoWrapper>> accountIdsForEWSMap = new Map<Id,List<EWSUtility.activityInfoWrapper>>();
            try{
                if(Test.isRunningTest() || Label.EWSActivator == 'YES') accountIdsForEWSMap = EWSUtility.createrEWSActivitiesForContact();
            }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            
            InitializeGlobalVariables();
            for(Contact con : triggerNew){        
                //1. FILTER ACCOUNTS WHERE CUSTOMER ROLE WILL BE POPULATED
                con = updatedAccountInfoChecking(con);
                accountIds.add(con.AccountId);          
                //2. DO OTHER OPERATION
                
            }  
            try{      
                if((Test.isRunningTest() || Label.EWSActivator == 'YES') && !accountIdsForEWSMap.Isempty()){EWSutility.createrEWSActivities(accountIdsForEWSMap);}
            }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}      
            //UPDATE ACCOUNT- 1.ROLL UP CUSTOMER ROLE, 2. UPDATE SPAM TRAP ACTION COMPLETED DATE
            updatedAccountInfo();
            ContactAdallomTrigger(triggerNew, newMap, null, null);
            //APPS-20374 - Update Primary Contact on Project
            updatePrimaryUserOnProjects(triggerNew);
        }
    }
    
    public static void afterUpdateHandler(List<Contact> triggerNew, Map<Id, Contact> newMap,List<Contact> oldList, Map<Id, Contact> triggerOldMap) {
        if(!isAfterUpdateHandlerExecuted){
            isAfterUpdateHandlerExecuted = true;
            /***Added on September 30,2016 By - GRAZITTI INTERACTIVE  ___for EWS___***/
            Map<Id,List<EWSUtility.activityInfoWrapper>> accountIdsForEWSMap = new Map<Id,List<EWSUtility.activityInfoWrapper>>();
            try{
                if(Test.isRunningTest() || Label.EWSActivator == 'YES') accountIdsForEWSMap = EWSUtility.createrEWSActivitiesForContact();
            }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
            
            InitializeGlobalVariables();
            for(Contact con : triggerNew) {            
                //1. FILTER ACCOUNTS WHERE CUSTOMER ROLE WILL BE POPULATED
                con = updatedAccountInfoChecking(con, triggerOldMap);
                
                //2. JIVE PROFILE INTEGRATION
                checkJiveCriteria(con, triggerOldMap.get(con.id));
            } 
            
            try{      
                if((Test.isRunningTest() || Label.EWSActivator == 'YES') && !accountIdsForEWSMap.Isempty()) EWSutility.createrEWSActivities(accountIdsForEWSMap);
            }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}            
            
            //UPDATE ACCOUNT- 1.ROLL UP CUSTOMER ROLE, 2. UPDATE SPAM TRAP ACTION COMPLETED DATE
            updatedAccountInfo();
            ContactAdallomTrigger(triggerNew, newMap, oldList, triggerOldMap);
            updateJiveProfileFromSFDC();
            //APPS-20374 - Update Primary Contact on Project
            updatePrimaryUserOnProjects(triggerNew);
        }
        
    }
    
    public static void afterDeleteHandler(List<Contact> triggerOld,Map<Id,Contact> oldMap) {
        if(!isAfterDeleteHandlerExecuted){
            isAfterDeleteHandlerExecuted = true;
            
            InitializeGlobalVariables();
            for(Contact con : triggerOld) {        
                //1. FILTER ACCOUNTS WHERE CUSTOMER ROLE WILL BE POPULATED
                con = updatedAccountInfoChecking(con);
                //2. DO OTHER OPERATION
            }  
            
            //UPDATE ACCOUNT- 1.ROLL UP CUSTOMER ROLE, 2. UPDATE SPAM TRAP ACTION COMPLETED DATE
            updatedAccountInfo();
            ContactAdallomTrigger(null, null, triggerOld, oldMap);
        }
    }      
    
    /*
@@##------------------------------------------------------------------------------------##@@
HELPER METHODS STARTS HERE
@@##------------------------------------------------------------------------------------##@@
*/
    public static void contactOwnerTerritoryPopulator(List<Contact> contactList, set<ID> contactOwnerID){
        
        Map<ID,ID> territoryUserMap     = new Map<ID,ID>();
        Map<ID,String> territoryNameMap = new Map<ID,String>();
        String T_NAME;
        
        for(UserTerritory ut : [SELECT Id, isActive, UserId, TerritoryId FROM UserTerritory WHERE isActive =: True AND UserID IN : contactOwnerID]){
            territoryUserMap.put(ut.TerritoryId, ut.UserId);
        }
        if(territoryUserMap.isEmpty()) return;
        
        for(Territory t: [SELECT Id, Name FROM Territory WHERE ID IN : territoryUserMap.KeySet()]){
            if(territoryUserMap.containsKey(t.ID)){
                if(!territoryNameMap.containsKey(territoryUserMap.get(t.ID))){
                    territoryNameMap.put(territoryUserMap.get(t.ID), t.Name);
                }else{
                    T_NAME = territoryNameMap.get(territoryUserMap.get(t.ID))+' , '+t.Name; 
                    territoryNameMap.put(territoryUserMap.get(t.ID), T_NAME);
                }
            }            
        }    
        
        /*for(Contact con : contactList){
con.Contact_Owner_Territory__c = territoryNameMap.get(Con.OwnerID);
}*/
    }
    
    public static contact updatedAccountInfoChecking(Contact con){
        if(con.Customer_Role__c != null || (con.Spam_Trap_Action_Completed__c && con.Spam_Trap_Action_Completed_Date__c != Null)) {
            accountIds.add(con.AccountId);           
        }
        if(trigger.isInsert){
            if(con.LS_Account_Score__c != null /*|| con.LS_Deal_Score__c != null*/) {
                accContactMap.put(con.AccountId,con);
            }
            
            //**************
            //Added by Jade Global Inc
            //Date: 10th May 2017
            SetAccIdsForSDROwnerLookup.add(con.AccountId);
        }
        
        return con;
    }
    public static contact updatedAccountInfoChecking(Contact con, Map<Id,Contact> oldMap){
        if((con.Customer_Role__c != null || (con.Customer_Role__c == null && oldMap.get(con.Id).Customer_Role__c != null)) || 
           (con.Spam_Trap_Action_Completed__c && con.Spam_Trap_Action_Completed_Date__c != Null)) {
               accountIds.add(con.AccountId);           
           }
        return con;
    }
    public static void updatedAccountInfo() {
        
        String CUSTOMER_ROLE_DECISIONMAKER      = 'Decision Maker';
        // Last Modified By: Priyanka Shende on 4th July 2018
        // Purpose         : APPS-20985: Request to Update Apex Code on Account 
        String CUSTOMER_ROLE_ENDUSER            = 'Renewal Owner';
        String CUSTOMER_ROLE_EXECUTIVESPONSER   = 'Executive Sponsor';
        String CUSTOMER_ROLE_INFLUENCER         = 'Influencer';
        String CUSTOMER_ROLE_POWERUSER          = 'Power User';
        
        if((accountIds != null && !accountIds.isEmpty()) || !SetAccIdsForSDROwnerLookup.isEmpty()){
            for(Account acc : [SELECT Id, LS_Deal_Score__c, LS_Account_Score__c, Sum_of_Decision_Maker__c, Type, Sum_of_End_User__c,
                               Sum_of_Executive_Sponsor__c, Sum_of_Influencer__c, Sum_of_Power_User__c, Spam_Trap_Action_Completed__c, 
                               Spam_Trap_Action_Completed_Date__c, (SELECT Id, Customer_Role__c, Spam_Trap_Action_Completed__c, 
                                                                    Spam_Trap_Action_Completed_Date__c FROM Contacts WHERE (Customer_Role__c != Null) 
                                                                    OR (Spam_Trap_Action_Completed__c =: TRUE AND Spam_Trap_Action_Completed_Date__c != Null) 
                                                                    ORDER BY Spam_Trap_Action_Completed__c DESC) FROM Account WHERE ID IN: accountIds]){
                                                                        
                                                                        Integer DECISIONMAKER        = 0;
                                                                        Integer ENDUSER              = 0;
                                                                        Integer EXECUTIVESPONSER     = 0;
                                                                        Integer INFLUENCER           = 0;
                                                                        Integer POWERUSER            = 0; 
                                                                        
                                                                        List<Contact> accContactList =  acc.Contacts;
                                                                        /*SPAM TRAP ACTION COMPLETED TASK --STARTS*/
                                                                        Contact spamTrapActionContact;
                                                                        for(contact con : accContactList){
                                                                            if(con.Spam_Trap_Action_Completed_Date__c != null && con.Spam_Trap_Action_Completed__c){
                                                                                spamTrapActionContact= con;
                                                                                break;
                                                                            }
                                                                        }
                                                                        if(spamTrapActionContact != null) {
                                                                            if(acc.Spam_Trap_Action_Completed_Date__c != acc.contacts[0].Spam_Trap_Action_Completed_Date__c){
                                                                                acc.Spam_Trap_Action_Completed__c = True;
                                                                                acc.Spam_Trap_Action_Completed_Date__c = acc.contacts[0].Spam_Trap_Action_Completed_Date__c;
                                                                            }       
                                                                        }else {
                                                                            acc.Spam_Trap_Action_Completed__c      = False;
                                                                            acc.Spam_Trap_Action_Completed_Date__c = Null;
                                                                        }
                                                                        /*SPAM TRAP ACTION COMPLETED TASK --ENDS*/
                                                                        /*ROLL UP CUSTOMER ROLE ON ACCOUNT--STARTS*/
                                                                        for(Contact con : acc.Contacts) {
                                                                            if(con.Customer_Role__c != null) {
                                                                                if(con.Customer_Role__c.Contains(CUSTOMER_ROLE_DECISIONMAKER)) {
                                                                                    DECISIONMAKER = DECISIONMAKER + 1;
                                                                                }
                                                                                if(con.Customer_Role__c.Contains(CUSTOMER_ROLE_ENDUSER)){
                                                                                    ENDUSER = ENDUSER + 1;
                                                                                }
                                                                                if(con.Customer_Role__c.Contains(CUSTOMER_ROLE_EXECUTIVESPONSER)) {
                                                                                    EXECUTIVESPONSER = EXECUTIVESPONSER + 1;
                                                                                }
                                                                                if(con.Customer_Role__c.Contains(CUSTOMER_ROLE_INFLUENCER)) {
                                                                                    INFLUENCER = INFLUENCER + 1;
                                                                                }
                                                                                if(con.Customer_Role__c.Contains(CUSTOMER_ROLE_POWERUSER)) {
                                                                                    POWERUSER = POWERUSER + 1;
                                                                                } 
                                                                            }
                                                                        }
                                                                        
                                                                        acc.Sum_of_Decision_Maker__c    =     DECISIONMAKER ;
                                                                        acc.Sum_of_End_User__c          =     ENDUSER ;
                                                                        acc.Sum_of_Executive_Sponsor__c =     EXECUTIVESPONSER ;
                                                                        acc.Sum_of_Influencer__c        =     INFLUENCER ;
                                                                        acc.Sum_of_Power_User__c        =     POWERUSER ;
                                                                        masterAccountMap.put(acc.Id, acc); 
                                                                        
                                                                        /*ROLL UP CUSTOMER ROLE ON ACCOUNT-ENDS*/  
                                                                        
                                                                        // Added for when contact is convert from lead//
                                                                        if(trigger.isInsert){
                                                                            if(accContactMap != null && accContactMap.containskey(acc.Id)){
                                                                                //acc.LS_Deal_Score__c     = accContactMap.get(acc.Id).LS_Deal_Score__c;
                                                                                acc.LS_Account_Score__c  = accContactMap.get(acc.Id).LS_Account_Score__c;
                                                                                accContactMap.remove(acc.Id);
                                                                            }
                                                                        }
                                                                    }
            if(accContactMap != null && !accContactMap.isEmpty()){
                for(ID idd : accContactMap.keySet()){
                    Account accNew;
                    if(masterAccountMap != null && masterAccountMap.containsKey(idd)){
                        accNew = masterAccountMap.get(idd);
                    }else{
                        accNew = new Account(ID = idd);
                    }
                    //accNew.LS_Deal_Score__c        = accContactMap.get(idd).LS_Deal_Score__c;
                    accNew.LS_Account_Score__c  = accContactMap.get(idd).LS_Account_Score__c;
                    masterAccountMap.put(accNew.Id, accNew);
                }
            }
            //************************************************************************************************
            //Date: 10th May 2017
            //Added by Jade Global Inc
            //This piece of code populates the SDR Owner fields on Account
            if(!SetAccIdsForSDROwnerLookup.isEmpty()){
                
                list<Account> listAccount = [SELECT id,SDR_Owner_Picklist__c,SDR_Owner_Lookup__c,SDR_Owner_Email_Address__c,SDR_Owner_First_Name__c,SDR_Owner_Last_Name__c,SDR_Owner_Phone_Number__c,SDR_Owner_Title__c FROM Account WHERE ID IN: SetAccIdsForSDROwnerLookup AND SDR_Owner_Picklist__c != null];
                
                set<String> SetSDROwnerNames = new set<String>();
                if(!listAccount.IsEmpty()){
                    for(Account ac: listAccount){
                        SetSDROwnerNames.add(ac.SDR_Owner_Picklist__c);
                    }//End of FOR
                }
                
                if(!SetSDROwnerNames.isEmpty()){
                    List<User> ListUsers = [SELECT Name,Id, Email, FirstName, LastName, Phone, Title FROM USER WHERE Name IN: SetSDROwnerNames];
                    
                    map<String,User> MapIdsWithUser = new map<String,User>();
                    
                    if(!ListUsers.isEmpty()){
                        for(User u: ListUsers){
                            if(!MapIdsWithUser.containsKey(u.Name)){
                                MapIdsWithUser.put(u.Name,u);
                            }//End of IF
                        }//End of FOR
                    }//End of IF
                    
                    for(Account acc: listAccount){
                        if((acc.SDR_Owner_Lookup__c == null ) && !MapIdsWithUser.isEmpty() && MapIdsWithUser.containsKey(acc.SDR_Owner_Picklist__c)){
                            acc.SDR_Owner_Lookup__c = truncateField(Account.SDR_Owner_Lookup__c,MapIdsWithUser.get(acc.SDR_Owner_Picklist__c).Id);
                            
                            acc.SDR_Owner_Email_Address__c = truncateField(Account.SDR_Owner_Email_Address__c,MapIdsWithUser.get(acc.SDR_Owner_Picklist__c).Email);
                            
                            acc.SDR_Owner_First_Name__c = truncateField(Account.SDR_Owner_First_Name__c,MapIdsWithUser.get(acc.SDR_Owner_Picklist__c).FirstName);
                            
                            acc.SDR_Owner_Last_Name__c = truncateField(Account.SDR_Owner_Last_Name__c,MapIdsWithUser.get(acc.SDR_Owner_Picklist__c).LastName);
                            
                            acc.SDR_Owner_Phone_Number__c = truncateField(Account.SDR_Owner_Phone_Number__c,MapIdsWithUser.get(acc.SDR_Owner_Picklist__c).Phone);
                            
                            acc.SDR_Owner_Title__c = truncateField(Account.SDR_Owner_Title__c,MapIdsWithUser.get(acc.SDR_Owner_Picklist__c).Title);
                            
                            if(!masterAccountMap.containsKey(acc.id)){
                                masterAccountMap.put(acc.id,acc);
                            }//End of IF
                            else{
                                Account act = masterAccountMap.get(acc.id);
                                
                                act.SDR_Owner_Lookup__c = acc.SDR_Owner_Lookup__c;
                                act.SDR_Owner_Email_Address__c = acc.SDR_Owner_Email_Address__c;
                                act.SDR_Owner_First_Name__c = acc.SDR_Owner_First_Name__c;
                                act.SDR_Owner_Last_Name__c = acc.SDR_Owner_Last_Name__c;
                                act.SDR_Owner_Phone_Number__c = acc.SDR_Owner_Phone_Number__c;
                                act.SDR_Owner_Title__c = acc.SDR_Owner_Title__c;
                                
                                //Removing the old entry
                                masterAccountMap.remove(act.id);
                                //Adding updated acc record
                                masterAccountMap.put(act.id,act);
                            }//End of ELSE
                        }//End of IF
                    }//End of FOR
                    
                }//End of IF
                
            }//End of IF
            //***************************************************************************
            if(masterAccountMap != null && !masterAccountMap.isEmpty()){
                DatabaseOperation.updateAccount(masterAccountMap.values(), true, false);
            }
        }       
    }
    //***************************************************************************
    //Added by Jade Global Inc
    //Date: 10th May 2017
    public static String truncateField(Schema.SObjectField sobjField,String value){
        Integer fieldLength = sobjField.getDescribe().getLength();
        return String.isBlank(value) || value.length() <= fieldLength ? value : value.substring(0,fieldLength - 1);
    }
    //***************************************************************************
    
    public static void GainsightContactTrigger(List<Contact> newList, Map<Id,Contact> oldMap){
        try{   
            if(accountIds != null && !accountIds.isEmpty()){
                Map<Id,Account> AccountMap = new Map<Id,Account>([SELECT Id,JBCXM__CustomerInfo__c,JBCXM__CustomerInfo__r.JBCXM__ASV__c,JBCXM__CustomerInfo__r.JBCXM__MRR__c FROM Account WHERE Id IN : accountIds]);
                Map<String,JBCXM__PickList__c> MilestoneMap = getMilestonePicklistMap();                
                for(Contact C: newList){
                    //Check if Contact has an Account and is still with the company
                    if(C.AccountId != null && C.No_Longer_with_Company__c == FALSE){
                        //Make sure the Contact has an Account and associated Customer Info record
                        if(AccountMap.get(C.AccountId).JBCXM__CustomerInfo__c != null){
                            //Check if Foundation Classroom was attended
                            if(oldMap.get(C.ID).EDU_Foundation_Classroom_Attended__c != C.EDU_Foundation_Classroom_Attended__c 
                               && C.EDU_Foundation_Classroom_Attended__c != null){
                                   //If results found, make Milestone
                                   if(MilestonePicklistMap.containsKey('Foundation Classroom')){
                                       JBCXM__Milestone__c Milestone = new JBCXM__Milestone__c(JBCXM__Account__c=C.AccountId,
                                                                                               JBCXM__Milestone__c=MilestonePicklistMap.get('Foundation Classroom').Id,
                                                                                               JBCXM__Date__c=DateTime.newInstance(C.EDU_Foundation_Classroom_Attended__c.Year(), C.EDU_Foundation_Classroom_Attended__c.Month(), C.EDU_Foundation_Classroom_Attended__c.Day()),
                                                                                               JBCXM__Comment__c=C.FirstName + ' ' + C.LastName + ' attended the Foundation Training.');
                                       
                                       MilestonesToInsert.add(Milestone);
                                   }               
                               }                         
                            
                            //Check if Foundation Virtual was attended
                            if(oldMap.get(C.ID).EDU_Foundation_Virtual_Attended__c != C.EDU_Foundation_Virtual_Attended__c && C.EDU_Foundation_Virtual_Attended__c != null){
                                //If results found, make Milestone
                                if(MilestonePicklistMap.containsKey('Foundation Virtual')){
                                    JBCXM__Milestone__c Milestone = new JBCXM__Milestone__c(JBCXM__Account__c=C.AccountId,
                                                                                            JBCXM__Milestone__c=MilestonePicklistMap.get('Foundation Virtual').Id,
                                                                                            JBCXM__Date__c=DateTime.newInstance(C.EDU_Foundation_Virtual_Attended__c.Year(), C.EDU_Foundation_Virtual_Attended__c.Month(), C.EDU_Foundation_Virtual_Attended__c.Day()),
                                                                                            JBCXM__Comment__c=C.FirstName + ' ' + C.LastName + ' attended the Foundation Training.');
                                    
                                    MilestonesToInsert.add(Milestone);
                                }               
                            }  
                        }
                    }
                }
                
                if(MilestonesToInsert != null && !MilestonesToInsert.isEmpty()){
                    insert MilestonesToInsert;
                }
            }
        }catch(Exception e){
            JBCXM__Log__c errorLog = New JBCXM__Log__c(JBCXM__ExceptionDescription__c   = 'Received a '+e.getTypeName()+' at line No. '
                                                       +e.getLineNumber()+' while running the Trigger to create Milestones from Contacts',
                                                       JBCXM__LogDateTime__c            = datetime.now(),
                                                       JBCXM__SourceData__c             = e.getMessage(),
                                                       JBCXM__SourceObject__c           = 'Contact',
                                                       JBCXM__Type__c                   = 'GainsightContactTrigger Trigger');
            insert errorLog;
        }   
    }
    
    public static Map<String,JBCXM__PickList__c> MilestonePicklistMap = new Map<String,JBCXM__PickList__c>();
    public static Map<String,JBCXM__PickList__c> getMilestonePicklistMap(){
        if(MilestonePicklistMap == null || MilestonePicklistMap.isEmpty()){
            for(JBCXM__PickList__c PL : [SELECT Id,JBCXM__SystemName__c FROM JBCXM__PickList__c WHERE JBCXM__Category__c = 'Milestones' AND JBCXM__Active__c = true]) {
                MilestonePicklistMap.put(PL.JBCXM__SystemName__c,PL);  
            }
        }
        return MilestonePicklistMap;
    }
    
    public static void ContactAdallomTrigger(List<Contact> newList, Map<Id,Contact> newMap, List<Contact> oldList, Map<Id,Contact> oldMap) { 
        try{
            AdallomAudit__c audit = new AdallomAudit__c();
            audit.UserId__c = UserInfo.getUserId();
            audit.Timestamp__c = System.now(); 
            audit.ObjectName__c = 'Contact';
            if (Trigger.isDelete) {
                if (oldList.size() == 1) {
                    String serializedValue = System.JSON.serialize(oldList[0]); 
                    if (serializedValue.length() <= 32768) { 
                        audit.OldObjectJSON__c = serializedValue; 
                    }
                    audit.ActionType__c = 'DELETE';
                    audit.ObjectId__c = oldList[0].Id;
                    audit.ObjectTitle__c = (oldList[0].FirstName + ' ' + oldList[0].LastName);
                } else {
                    audit.ActionType__c = 'MASS_DELETE';
                    audit.ObjectIds__c = System.JSON.serialize(oldMap.keySet());
                }
            } else {
                if (Trigger.isInsert) {
                    if (newList.size() == 1) {
                        String serializedValue = System.JSON.serialize(newList[0]); 
                        if (serializedValue.length() <= 32768) { 
                            audit.NewObjectJSON__c = serializedValue; 
                        }
                        audit.ActionType__c = 'INSERT';
                        audit.ObjectId__c = newList[0].Id;
                        audit.ObjectTitle__c = (newList[0].FirstName + ' ' + newList[0].LastName);
                    } else {
                        audit.ActionType__c = 'MASS_INSERT';
                        audit.ObjectIds__c = System.JSON.serialize(newMap.keySet());
                    }
                } else {
                    if (newList.size() == 1) {
                        String serializedValue = System.JSON.serialize(oldList[0]); 
                        if (serializedValue.length() <= 32768) { 
                            audit.OldObjectJSON__c = serializedValue; 
                        }
                        serializedValue = System.JSON.serialize(newList[0]); 
                        if (serializedValue.length() <= 32768) { 
                            audit.NewObjectJSON__c = serializedValue; 
                        }
                        audit.ActionType__c = 'UPDATE';
                        audit.ObjectId__c = newList[0].Id;
                        audit.ObjectTitle__c = (newList[0].FirstName + ' ' + newList[0].LastName);
                    } else {
                        audit.ActionType__c = 'MASS_UPDATE';
                        audit.ObjectIds__c = System.JSON.serialize(newMap.keySet());
                    } 
                } 
            } 
            insert audit; 
        } catch (Exception e) {} 
    }
    
    
    public static Contact populateStageBeforeTouchOnContact(Contact con, Map<Id,Contact> oldMap){
        String TOUCH_STAGE_UNTOUCHED = 'Untouched';
        String s_ACT_NOW             = 'Act Now';
        String s_CALL_NOW            = 'Call Now';
        String s_MQL                 = 'MQLA';
        String s_FRESH_LEAD          = 'Fresh Lead';
        String s_EVERYTHING_ELSE     = 'Everything Else';
        String s_CONTACT_STATUS      = 'Recycled';
        String TO_POPULATE;
        Date TODAY_DATE = Date.today();
        
        if(oldMap.get(con.Id).Touch_Stage__c != con.Touch_Stage__c && oldMap.get(con.Id).Touch_Stage__c == TOUCH_STAGE_UNTOUCHED){
            if(con.Act_Now__c || con.Call_Now__c || con.NMQLA__c || con.Fresh_Lead__c){
                
                boolean ACT_NOW         = con.Act_Now__c;
                boolean CALL_NOW        = con.Call_Now__c;
                boolean MQL             = con.NMQLA__c;
                boolean FRESH_LEAD      = con.Fresh_Lead__c;
                Date ACT_NOW_DATE       = con.Last_Act_Now_Date__c;
                Date CALL_NOW_DATE      = con.Last_Call_Now_Date__c;
                Date MQL_DATE           = con.Last_NMQLA_Created_Date__c;
                Date FRESH_LEAD_DATE    = con.Fresh_Lead_Date__c;
                Date TO_COMPARE;
                
                
                if(ACT_NOW){
                    if(ACT_NOW_DATE != null){TO_COMPARE = ACT_NOW_DATE;}else{TO_COMPARE = TODAY_DATE.addYears(999);}
                    TO_POPULATE = s_ACT_NOW;
                    
                    if(CALL_NOW){
                        if(TO_COMPARE > CALL_NOW_DATE && CALL_NOW_DATE != null){
                            TO_COMPARE = CALL_NOW_DATE;
                            TO_POPULATE = s_CALL_NOW;
                        }
                    }
                    if(MQL){
                        if(TO_COMPARE > MQL_DATE && MQL_DATE != null){
                            TO_COMPARE = MQL_DATE;
                            TO_POPULATE = s_MQL;
                        }
                    }
                    if(FRESH_LEAD){
                        if(TO_COMPARE > FRESH_LEAD_DATE && FRESH_LEAD_DATE != null){
                            TO_COMPARE = FRESH_LEAD_DATE;
                            TO_POPULATE = s_FRESH_LEAD;
                        }
                    }
                }else if(CALL_NOW){
                    if(CALL_NOW_DATE != null){TO_COMPARE = CALL_NOW_DATE;}else{TO_COMPARE = TODAY_DATE.addYears(999);}
                    TO_POPULATE = s_CALL_NOW;
                    
                    if(MQL){
                        if(TO_COMPARE > MQL_DATE && MQL_DATE != null){
                            TO_COMPARE = MQL_DATE;
                            TO_POPULATE = s_MQL;
                        }
                    }
                    if(FRESH_LEAD){
                        if(TO_COMPARE > FRESH_LEAD_DATE && FRESH_LEAD_DATE != null){
                            TO_COMPARE = FRESH_LEAD_DATE;
                            TO_POPULATE = s_FRESH_LEAD;
                        }
                    }
                }else if(MQL){
                    if(MQL_DATE != null){TO_COMPARE = MQL_DATE;}else{TO_COMPARE = TODAY_DATE.addYears(999);}
                    TO_POPULATE = s_MQL;
                    
                    if(FRESH_LEAD){
                        if(TO_COMPARE > FRESH_LEAD_DATE && FRESH_LEAD_DATE != null){
                            TO_COMPARE = FRESH_LEAD_DATE;
                            TO_POPULATE = s_FRESH_LEAD;
                        }
                    }
                }else if(FRESH_LEAD){
                    TO_POPULATE = s_FRESH_LEAD;
                }
            }
            else{
                TO_POPULATE = s_EVERYTHING_ELSE;
            }
            con.Status_Before_Touch__c = TO_POPULATE;
        }
        if(con.Contact_Status__c == s_CONTACT_STATUS && oldMap.get(con.Id).Contact_Status__c != con.Contact_Status__c){
            con.Status_Before_Touch__c = '';
        }
        return con;
    }
    
    Static Map<Id, String> ConIdEmailMap  = new Map<Id, String>();
    Static Map<Id, String> ConIDStringMap = new Map<Id, String>(); 
    public static void checkJiveCriteria(contact newVersion, Contact oldVersion){    
        String ConString = '';
        boolean GoAhead = false;
        ConString += '#Email#' +oldVersion.Email+ '#Email1#';
        if(newVersion.Email!= oldVersion.Email){
            ConString += '#NewEmail#' +newVersion.Email+ '#NewEmail1#'; 
            GoAhead = true;
        }
        if(newVersion.FirstName != oldVersion.FirstName){
            ConString += '#FirstName#' +newVersion.FirstName+ '#FirstName1#';
            GoAhead = true;
        }
        if(newVersion.lastName != oldVersion.lastName){
            ConString += '#lastName#' +newVersion.lastName+ '#lastName1#';
            GoAhead = true;
        }
        if(newVersion.title != oldVersion.title){
            ConString += '#title#' +newVersion.title+ '#title1#';
            GoAhead = true;
        }
        if(newVersion.Phone != oldVersion.Phone){
            ConString += '#Phone#' +newVersion.Phone+ '#Phone1#';
            GoAhead = true;
        }
        if(newVersion.MobilePhone != oldVersion.MobilePhone){
            ConString += '#MobilePhone#' +newVersion.MobilePhone+ '#MobilePhone1#';
            GoAhead = true;
        }
        /*if(newVersion.sf4twitter__Twitter_Username__c != oldVersion.sf4twitter__Twitter_Username__c){
ConString += '#TwitterName#' +newVersion.sf4twitter__Twitter_Username__c + '#TwitterName1#';
GoAhead = true;
}*/
        if(newVersion.Munchkin_ID__c != oldVersion.Munchkin_ID__c){
            ConString += '#MunchkinID#' +newVersion.Munchkin_ID__c + '#MunchkinID1#';
            GoAhead = true;
        }
        if(newVersion.Marketo_POD__c != oldVersion.Marketo_POD__c){
            ConString += '#POD#' +newVersion.Marketo_POD__c + '#POD1#';
            GoAhead = true;
        }
        if(GoAhead){
            ConIdEmailMap.put(newVersion.id, newVersion.email);  
            ConIDStringMap.put(newVersion.id, ConString); 
        }     
    }
    
    public static void updateJiveProfileFromSFDC(){
        
        if(System.isBatch() || System.isFuture() || Label.JiveSyncEnable !='True' ||  UserInfo.getUserId() == Label.JiveGuestUserId) return;
        
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
    public Static Map<Id, String> contactSDROwner  = new Map<Id, String>();
    /*public static void checkSDROwnerCrietria(contact newVersion, Contact oldVersion){
if(trigger.isInsert){
if(newVersion.SDR_Owner__c != null){
contactSDROwner.put(newVersion.Id,newVersion.SDR_Owner__c);
}
}else if(trigger.isUpdate){
if(newVersion.SDR_Owner__c != oldVersion.SDR_Owner__c){
contactSDROwner.put(newVersion.Id,newVersion.SDR_Owner__c);
}
}


}*/
    
    //******************************************************************************************
    //Added by Jade Global Inc
    //Date: 10th May 2017
    //This method will be called on Before Insert and Before Update of Contact
    
    public static void populateSDROwnerFieldsOnContact(List<Contact> listContact, Map<id,Contact> oldMap){
        if(Trigger.isInsert){
            set<id> setAccountIds = new set<id>();
            
            for(Contact ct : listContact){
                if(ct.AccountId != null){
                    setAccountIds.add(ct.AccountId);
                }//End of IF
            }//End of FOR
            
            
            if(!setAccountIds.isEmpty()){
                Map<id,Account> MapAccIdsWithAccounts = new Map<id,Account>([SELECT id,SDR_Owner_Lookup__c,SDR_Owner_Picklist__c,SDR_Owner_Email_Address__c FROM Account WHERE ID IN: setAccountIds AND SDR_Owner_Lookup__c != null]);
                
                if(!MapAccIdsWithAccounts.isEmpty()){
                    for(Contact ct: listContact){
                        //system.assertEquals(null,MapAccIdsWithAccounts.get(ct.AccountId).SDR_Owner_Lookup__c);
                        if(/*ct.SDR_Owner__c == null &&*/ MapAccIdsWithAccounts.containsKey(ct.AccountId)){
                            ct.SDR_Owner__c = MapAccIdsWithAccounts.get(ct.AccountId).SDR_Owner_Picklist__c;
                            ct.SDR_Owner_Email__c = MapAccIdsWithAccounts.get(ct.AccountId).SDR_Owner_Email_Address__c;
                            ct.SDR_Owner_Look_Up__c=MapAccIdsWithAccounts.get(ct.AccountId).SDR_Owner_Lookup__c;
                        }//End of IF
                    }//End of FOR
                }//End of IF
                
            }//End of IF
        }//End of isInsert
        
        if(Trigger.isUpdate){
            set<id> SDRUsersIds = new set<id>();
            
            for(Contact ct : listContact){
                if(ct.SDR_Owner_Look_Up__c != null && ct.SDR_Owner_Look_Up__c != oldMap.get(ct.Id).SDR_Owner_Look_Up__c){
                    SDRUsersIds.add(ct.SDR_Owner_Look_Up__c);
                }//End of IF
            }//End of FOR
            
            if(!SDRUsersIds.isEmpty()){
                map<id,User> MapIdsWithUsers = new map<id,User>([SELECT id,Name,Email FROM USER WHERE ID IN: SDRUsersIds]);
                
                for(Contact c: listContact){
                    if(c.SDR_Owner_Look_Up__c != null && MapIdsWithUsers.ContainsKey(c.SDR_Owner_Look_Up__c)){
                        c.SDR_Owner__c = MapIdsWithUsers.get(c.SDR_Owner_Look_Up__c).Name;
                        c.SDR_Owner_Email__c = MapIdsWithUsers.get(c.SDR_Owner_Look_Up__c).Email;
                        
                    }//End of IF
                }//End of FOR
                
            }//End of IF
        }//End of isUpdate
        
    }//End of populateSDROwnerFieldsOnContact()
    
    //******************************************************************************************
    
    public static void updateSDROwnerCrietria( List<Contact> lstContact){
        if(!contactSDROwner.isEmpty()){
            Map<String,String> name2Email = new Map<String,String>();
            for(User usr : [Select id,Name,email from User where Name IN : contactSDROwner.values() and usertype = 'Standard']){
                name2Email.put(usr.Name,usr.Email);
            }
            System.Debug('!!!!!!!!===>'+name2Email);
            for(Contact cont :lstContact){
                if(!contactSDROwner.isEmpty() && contactSDROwner.containsKey(cont.Id)){
                    String SDROwner = contactSDROwner.get(cont.id);
                    if(!name2Email.isEmpty() && SDROwner!= null &&name2Email.containsKey(SDROwner)){
                        cont.SDR_Owner_Email__c = name2Email.get(SDROwner);
                    }else{
                        cont.SDR_Owner_Email__c = '';
                    }
                }
            }
        }
    }
    
    
    //******************************************************************************************
    //Added for APPS-20374 by Cassandrea 7/17/18
    public static void updatePrimaryUserOnProjects(List<Contact> contactList){
        //If the Contact(s) from the trigger is marked as the Primary Marketo User,
        //then this will find all the active Projects on the Account and update the Project's Primary Contact field to that Contact
        
        Map<id,id> accountAndContactMap = new Map<id,id>();
        List<pse__Proj__c> projectsToUpdate = new List<pse__Proj__c>();
        
        for(Contact c : contactList){
            if(c.AccountId != null && c.CE_Primary_Marketo_User__c){
                accountAndContactMap.put(c.AccountId,c.id);
            }//End of IF
        }//End of FOR
        
        if(!accountAndContactMap.isEmpty()){
            for(pse__Proj__c p: [SELECT id, Primary_Contact__c,pse__Account__r.ID FROM pse__Proj__c WHERE pse__Account__r.ID IN: accountAndContactMap.keyset() AND pse__Is_Active__c = true]){
                p.Primary_Contact__c = accountAndContactMap.get(p.pse__Account__r.id);
                projectsToUpdate.add(p);
            }//End of FOR
        }//End of IF
        
        if(!projectsToUpdate.isEmpty()){
            update projectsToUpdate;
        }
    }    
}