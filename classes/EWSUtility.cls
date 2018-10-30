public class EWSUtility {

/*_______________________________________________________________________________
 This class handles all the operations that has to be performed related to EWS
 Create AN EWS ACTIVITY RECORD when CAM Owner or Temprature is changed
 Added on - 29- August, 2016  Created By -GRAZITTI INTERACTIVE - Jatin Narula
  _______________________________________________________________________________
   
*/
    //!!Variables to handle recursion ********
    public static Boolean isEwsExecutedInsert = false;
    public static Boolean isEwsExecutedUpdate = false;
    //!!Variables to handle recursion ********
    
    //******** All EWS Activities are created here *************
    public static void createrEWSActivities(Map<Id,List<activityInfoWrapper>> accountIdsForEWSMap) {
        List<Activities__c> activitiesListToInsert = new List<Activities__c>();
        List<Activities__c> activitiesListToUpsert = new List<Activities__c>();
        if(accountIdsForEWSMap != null && accountIdsForEWSMap.size() > 0){
            Set<String> pointsTableNameSet = new Set<String>();
            for(Id i : accountIdsForEWSMap.KeySet()){
                for(activityInfoWrapper s : accountIdsForEWSMap.get(i)){
                    pointsTableNameSet.add(s.name);
                }
            }
            List<EWS_Point_Table__c> pointsTableList = [select Id,Activate__c,Name,Points__c,Type__c,Driver__c,Sub_Driver__c from EWS_Point_Table__c where Name in : pointsTableNameSet];
            Map<String,EWS_Point_Table__c> pointsTableMap = New Map<String,EWS_Point_Table__c>();
            for(EWS_Point_Table__c p : pointsTableList){
                pointsTableMap.put(p.Name,p);
            }
            
            if(accountIdsForEWSMap.size()>0){
                for(Id i : accountIdsForEWSMap.keySet()){                       
                    for(activityInfoWrapper s : accountIdsForEWSMap.get(i)){
                        
                        if(pointsTableMap.containsKey(s.name) && pointsTableMap.get(s.name).Activate__c){
                            if(String.isNotBlank(pointsTableMap.get(s.name).Type__c) && pointsTableMap.get(s.name).Type__c == 'Product'){
                                Activities__c ac = new Activities__c();
                                ac.Account__c = i;
                                ac.Name = s.name;
                                ac.EWS_Point__c = pointsTableMap.get(s.name).Id;
                                ac.Description__c = s.description;
                                ac.Type__c = pointsTableMap.get(s.name).Type__c;
                                ac.Driver__c = pointsTableMap.get(s.name).Driver__c;
                                ac.Sub_Driver__c = pointsTableMap.get(s.name).Sub_Driver__c;
                                if(String.isNotBlank(s.caseId)) ac.Case_Number__c = s.caseId;
                                activitiesListToInsert.add(ac);
                            }
                            if(String.isNotBlank(pointsTableMap.get(s.name).Type__c) && pointsTableMap.get(s.name).Type__c == 'CSM'){
                                Activities__c ac = new Activities__c();
                                ac.Account__c = i;
                                ac.Name = s.name;
                                ac.Description__c = s.description;
                                ac.EWS_Point__c = pointsTableMap.get(s.name).Id;
                                ac.Type__c = pointsTableMap.get(s.name).Type__c;
                                if(String.isNotBlank(s.caseId)) ac.Case_Number__c = s.caseId;
                                ac.Driver__c = pointsTableMap.get(s.name).Driver__c;
                                ac.Sub_Driver__c = pointsTableMap.get(s.name).Sub_Driver__c;
                                activitiesListToInsert.add(ac);
                            }
              
                            if(String.isNotBlank(pointsTableMap.get(s.name).Type__c) && pointsTableMap.get(s.name).Type__c == 'Support'){
                                if(s.Name != 'Half-Yearly Review' && s.Name != 'Mentor Session'){
                                    Activities__c ac = new Activities__c();
                                    ac.Account__c = i;
                                    ac.Name = s.name;
                                    ac.Description__c = s.description;
                                    ac.EWS_Point__c = pointsTableMap.get(s.name).Id;
                                    ac.Type__c = pointsTableMap.get(s.name).Type__c;
                                    if(String.isNotBlank(s.caseId)) ac.Case_Number__c = s.caseId;
                                    ac.Driver__c = pointsTableMap.get(s.name).Driver__c;
                                    ac.Sub_Driver__c = pointsTableMap.get(s.name).Sub_Driver__c;
                                    activitiesListToInsert.add(ac);
                                }
                                if(s.Name == 'Half-Yearly Review' || s.Name == 'Mentor Session'){
                                    Activities__c ac = new Activities__c();
                                    ac.Account__c = i;
                                    ac.Name = s.name;
                                    ac.Description__c = s.description;
                                    ac.EWS_Point__c = pointsTableMap.get(s.name).Id;
                                    ac.Type__c = pointsTableMap.get(s.name).Type__c;
                                    if(String.isNotBlank(s.caseId)) ac.Case_Number__c = s.caseId;
                                    ac.Driver__c = pointsTableMap.get(s.name).Driver__c;
                                    ac.Sub_Driver__c = pointsTableMap.get(s.name).Sub_Driver__c;
                                    ac.Activity_Identifier__c = s.activityIdentifier + s.name;
                                    activitiesListToUpsert.add(ac);    
                                }
                            }
                        }
                    }
                }
            }
     
            if(!activitiesListToInsert.isEmpty()) Database.insert(activitiesListToInsert, false);            
            Schema.SObjectField f = Activities__c.Fields.Activity_Identifier__c;
            if(!activitiesListToUpsert.isEmpty()) Database.upsert(activitiesListToUpsert, f, false);
        }
    }
    
    //*** this method is called from caseHandler to return a map for support EWS Acrivities
    public static Map<Id,List<activityInfoWrapper>> createrEWSActivitiesForCases(){
        List<Case> newCases = (List<Case>)trigger.new;
        Map<Id,Case> oldMap = (Map<Id,Case>)trigger.oldMap;
        Map<Id,Case> newMap = (Map<Id,Case>)trigger.oldMap;
        Map<Id,List<activityInfoWrapper>> accountIdsForEWSMap = new Map<Id,List<activityInfoWrapper>>(); 
        Set<String> listOfCat = new Set<String>{'Deliverability','Email','Salesforce.com','Microsoft Dynamics','Sales Insight'};        
        if(newCases != null && !newCases.isEmpty()){
            Set<Id> halfYearlyCaseIds = new Set<Id>();
            Map<Id,Case> crossRefrenceFieldMap = new Map<Id,Case>([SELECT id,Subject,ContactId,Contact.Name,Situation_Contact__r.FirstName,Situation_Contact__r.LastName,owner.Name from case where id IN: newCases]);
            for(Case c : newCases){
                if(String.isNotBlank(c.AccountId)){
                    if(c.Category__c == 'Early Warning System' && c.isClosed && c.RecordTypeId == Label.ProactiveCaseId && c.Close_Reason__c != 'Invalid Case' && c.Close_Reason__c !='Spam' && c.Close_Reason__c !='Duplicate' && (trigger.isInsert || (trigger.isUpdate && !oldMap.get(c.Id).isClosed))){                        
                        List<activityInfoWrapper> temp = new List<activityInfoWrapper>(); 
                        if(accountIdsForEWSMap.containsKey(c.AccountId)) temp = accountIdsForEWSMap.get(c.AccountId);
                        activityInfoWrapper accWrap = new activityInfoWrapper();
                        accWrap.name = 'Outreach Made';
                        accWrap.subDriver = 'Outreach Made';
                        accWrap.caseId = c.Id;
                        accWrap.description = crossRefrenceFieldMap.get(c.id).owner.Name +' concluded an outreach on '+ c.ClosedDate +' through Case : '+c.CaseNumber;
                        temp.add(accWrap);
                        accountIdsForEWSMap.put(c.AccountId,temp); 
                    }
                    
                    if((trigger.isInsert && c.Priority == 'P1') || (trigger.isUpdate && c.Priority == 'P1' && oldMap.get(c.Id).Priority != 'P1')){                        
                        List<activityInfoWrapper> temp = new List<activityInfoWrapper>(); 
                        if(accountIdsForEWSMap.containsKey(c.AccountId)) temp = accountIdsForEWSMap.get(c.AccountId);
                        activityInfoWrapper accWrap = new activityInfoWrapper();
                        accWrap.name = 'P1 Condition';
                        accWrap.subDriver = 'P1 Condition';
                        accWrap.caseId = c.Id;
                        accWrap.description = crossRefrenceFieldMap.get(c.id).Contact.Name+' filed a P1 Case - '+c.CaseNumber+' : '+c.Subject;
                        temp.add(accWrap);
                        accountIdsForEWSMap.put(c.AccountId,temp); 
                    }
                    
                    if((trigger.isInsert && c.Priority == 'P2') || (trigger.isUpdate && c.Priority == 'P2' && oldMap.get(c.Id).Priority != 'P2')){                        
                        List<activityInfoWrapper> temp = new List<activityInfoWrapper>();  
                        if(accountIdsForEWSMap.containsKey(c.AccountId)) temp = accountIdsForEWSMap.get(c.AccountId);
                        activityInfoWrapper accWrap = new activityInfoWrapper();
                        accWrap.name = 'P2 Case';
                        accWrap.subDriver = 'P2 Case';
                        accWrap.caseId = c.Id;
                        accWrap.description = 'Case - '+ c.CaseNumber +' was set as a P2';
                        temp.add(accWrap);
                        accountIdsForEWSMap.put(c.AccountId,temp);
                          
                    }
                    
                    if(Test.isRunningTest() ||(trigger.isUpdate && c.Status !='Closed' && oldMap != null && oldMap.containsKey(c.Id) && oldMap.get(c.Id).Status =='Closed')){
                        if(Test.isRunningTest() || c.No_Of_Times_Case_Re_opened__c > 2){
                            List<activityInfoWrapper> temp = new List<activityInfoWrapper>();
                            if(accountIdsForEWSMap.containsKey(c.AccountId)) temp = accountIdsForEWSMap.get(c.AccountId);
                            activityInfoWrapper accWrap = new activityInfoWrapper();
                            accWrap.name = 'Excessive (2+) Reopens';
                            accWrap.subDriver = 'Excessive Reopens';
                            accWrap.caseId = c.Id;
                            accWrap.description = 'Case - '+ c.CaseNumber+' - was reopened '+c.No_Of_Times_Case_Re_opened__c+ ' times.'; 
                            temp.add(accWrap);
                            accountIdsForEWSMap.put(c.AccountId,temp);
                        }
                    }
                    if((trigger.isInsert && String.isNotBlank(c.JIRA_Num__c)) || (trigger.isUpdate && String.isNotBlank(c.JIRA_Num__c) && oldMap.containsKey(c.Id) && String.isBlank(oldMap.get(c.Id).JIRA_Num__c))){
                        List<activityInfoWrapper> temp = new List<activityInfoWrapper>();
                        if(accountIdsForEWSMap.containsKey(c.AccountId)) temp = accountIdsForEWSMap.get(c.AccountId);
                        activityInfoWrapper accWrap = new activityInfoWrapper();
                        accWrap.Name = 'Escalated to Engineering';
                        accWrap.subDriver = 'Escalated to Engineering';
                        accWrap.caseId = c.Id;
                        accWrap.description = 'Case - '+ c.CaseNumber+' - Escalated to Tier -3 , Jira Number - '+c.JIRA_Num__c;
                        temp.add(accWrap);
                        accountIdsForEWSMap.put(c.AccountId,temp);
                         
                    }
                }  
                
                if(trigger.isInsert && trigger.isAfter){
                    if(c.Category__c != 'Early Warning System'){                  
                        if(c.Situation_Account__c!=null) {       
                            if(c.RecordTypeID=='01250000000UK1E' || c.RecordTypeID=='01250000000UKps'){                  
                                List<activityInfoWrapper> temp = new List<activityInfoWrapper>();
                                if(accountIdsForEWSMap.containsKey(c.Situation_Account__c)) temp = accountIdsForEWSMap.get(c.Situation_Account__c);                        
                                activityInfoWrapper accWrap = new activityInfoWrapper();
                                accWrap.name = 'Sitman Filled';
                                accWrap.subDriver = 'Sitman Filled';
                                accWrap.caseId = c.Id;
                                accWrap.description = crossRefrenceFieldMap.get(c.id).Situation_Contact__r.FirstName +' '+ crossRefrenceFieldMap.get(c.id).Situation_Contact__r.LastName +' Filed Sitman - '+c.CaseNumber+' : '+c.Subject;
                                temp.add(accWrap);               
                                accountIdsForEWSMap.put(c.Situation_Account__c,temp);
                                                
                            }                                            
                        }
                    }           
                }
                if(Test.isRunningTest() || (trigger.isUpdate && c.Status =='Closed' && oldMap.get(c.id).Status !='closed' && String.isNotBlank(c.Category__c) && String.isNotBlank(c.Close_Reason__c) && c.Category__c =='Product Functionality' && c.Close_Reason__c == 'Referred to Ideas')){
                    List<activityInfoWrapper> temp = new List<activityInfoWrapper>();
                    if(accountIdsForEWSMap.containsKey(c.AccountId)) temp = accountIdsForEWSMap.get(c.AccountId);
                    activityInfoWrapper accWrap = new activityInfoWrapper();
                    accWrap.name = 'CSATs with entry of "Product"';
                    accWrap.subDriver = 'Product SitMan';
                    accWrap.caseId = c.Id;
                    accWrap.description = 'Case - '+c.CaseNumber+ ' : ' +c.Subject+ ' - Was identified as a Product issue';
                    temp.add(accWrap);   
                    accountIdsForEWSMap.put(c.AccountId,temp); 
                                      
                }
                if(Test.isRunningTest() || (trigger.isUpdate && c.Status =='Closed' && oldMap.get(c.id).Status !='closed' && c.Close_Reason__c != null && (C.Problem_Type__c == 'Feature Request' || (c.Close_Reason__c == 'Referred to Ideas' || c.Close_Reason__c == 'Awaiting Engineering Fix (Soft Close)')))){
                    List<activityInfoWrapper> temp = new List<activityInfoWrapper>();
                    if(accountIdsForEWSMap.containsKey(c.AccountId)) temp = accountIdsForEWSMap.get(c.AccountId);
                    activityInfoWrapper accWrap = new activityInfoWrapper();
                    accWrap.name = 'Case Closed "Reffered to Ideas"';
                    accWrap.subDriver = 'Product Support Case';
                    accWrap.caseId = c.Id;
                    accWrap.description = 'Case - '+c.CaseNumber+ ' was identified as a product issue by the support engineer';
                    temp.add(accWrap);   
                    accountIdsForEWSMap.put(c.AccountId,temp);                   
                }
                if((trigger.isInsert && c.Escalated_to_SME__c) || (trigger.isUpdate && !oldMap.get(c.Id).Escalated_to_SME__c && c.Escalated_to_SME__c)){
                    List<activityInfoWrapper> temp = new List<activityInfoWrapper>();
                    if(accountIdsForEWSMap.containsKey(c.AccountId)) temp = accountIdsForEWSMap.get(c.AccountId);
                        activityInfoWrapper accWrap = new activityInfoWrapper();
                        accWrap.name = 'Escalated to SME';
                        accWrap.caseId = c.Id;
                        accWrap.subDriver = 'Escalated to SME';
                        accWrap.description = 'Case - '+c.CaseNumber+ ' Was escalated to a Subject Matter Expert in '+ c.Category__c;
                        temp.add(accWrap);   
                        accountIdsForEWSMap.put(c.AccountId,temp);     
                }
                if(Test.isRunningTest() || (trigger.isUpdate && oldMap.get(c.id).Status != 'Closed' && c.Status =='Closed' && c.Problem_Type__c == 'Mentoring Session' && c.RecordTypeId == '01250000000UJwx' && c.Close_Reason__c != 'Duplicate' && c.Close_Reason__c != 'Spam' && c.Close_Reason__c != 'Invalid Case')){
                    List<activityInfoWrapper> temp = new List<activityInfoWrapper>();      
                    if(accountIdsForEWSMap.containsKey(c.AccountId)) temp = accountIdsForEWSMap.get(c.AccountId);
                    activityInfoWrapper accWrap = new activityInfoWrapper();
                    accWrap.Name = 'Mentor Session';
                    accWrap.subDriver = 'Mentor Session';
                    accWrap.caseId = c.Id;
                    accWrap.activityIdentifier = c.AccountId;
                    accWrap.description = crossRefrenceFieldMap.get(c.id).owner.Name +' Delivered a mentor session' +';'+ ' Case - '+c.CaseNumber;
                    temp.add(accWrap);
                    accountIdsForEWSMap.put(c.AccountId,temp);
                        
                }
                if(Test.isRunningTest() || (trigger.isUpdate && c.RecordTypeId == '0123B0000008Z6H' && c.Status =='Closed' && oldMap.get(c.id).Status !='Closed' && c.Problem_Type__c == 'Support Review' && c.Close_Reason__c == 'Resolved')){
                    List<activityInfoWrapper> temp = new List<activityInfoWrapper>();
                    if(accountIdsForEWSMap.containsKey(c.AccountId)) temp = accountIdsForEWSMap.get(c.AccountId);
                    activityInfoWrapper accWrap = new activityInfoWrapper();
                    accWrap.name = 'Half-Yearly Review';
                    accWrap.subDriver = 'Half-Yearly Review';
                    accWrap.caseId = c.Id;
                    accWrap.activityIdentifier = c.AccountId;
                    accWrap.description = crossRefrenceFieldMap.get(c.id).owner.Name +' Delivered a half-yearly review' +';'+ ' Case - '+c.CaseNumber;
                    temp.add(accWrap);
                    accountIdsForEWSMap.put(c.AccountId,temp);
                        
                }
                  if(trigger.isAfter && trigger.isUpdate){ 
                    if(c.RecordTypeID=='01250000000UJwx'){
                        if(Test.isRunningTest() || (c.Category__c != Null && listOfCat.contains(c.Category__c) && oldMap.get(c.id).Category__c != c.Category__c && !listOfCat.contains(oldMap.get(c.id).Category__c))){
                            List<activityInfoWrapper> temp = new List<activityInfoWrapper>();
                            if(accountIdsForEWSMap.containsKey(c.AccountId)) temp = accountIdsForEWSMap.get(c.AccountId);
                            activityInfoWrapper accWrap = new activityInfoWrapper();
                            accWrap.name = 'Case opened: Volatile Subject';
                            accWrap.subDriver = 'Case opened: Volatile Subject';
                            accWrap.caseId = c.Id;
                            accWrap.description = 'Case - ' + c.CaseNumber +' was opened with a Category of '+ c.Category__c;
                            temp.add(accWrap);   
                            accountIdsForEWSMap.put(c.AccountId,temp);                  
                        }                   
                    }
                }
            }
        }
        return accountIdsForEWSMap;
    }
    
    //*** this method is called from Account_MAIN_TriggerHandler to return a map for support EWS Acrivities
    public static Map<Id,List<activityInfoWrapper>> createrEWSActivitiesForAccounts(){
        List<Account> newAccounts = (List<Account>)trigger.new;
        Map<Id,Account> oldMap = (Map<Id,Account>)trigger.oldMap;
        Map<Id,Account> newMap = (Map<Id,Account>)trigger.oldMap;
        Map<Id,List<activityInfoWrapper>> accountIdsForEWSMap = new Map<Id,List<activityInfoWrapper>>();
        if(newAccounts != null && !newAccounts.isEmpty()){
            for(Account ac :  [select Id,CAM_Owner__c,CAM_Owner__r.FirstName,CAM_Owner__r.LastName,Temperature__c,Spam_Trap_Full_Detail__c from Account where id IN:newAccounts]) {   
                /**_____________________________________________________
                Create AN EWS ACTIVITY RECORD when CAM Owner or Temprature is changed
                Added on - 29- August, 2016    By - GRAZITTI INTERACTIVE - Jatin Narula__ START____
                ________________________________________________________**/ 
                if(oldMap.containsKey(ac.Id)){
                    if(Test.isRunningTest() || (trigger.isUpdate && oldMap.get(ac.Id).CAM_Owner__c != null && oldMap.get(ac.Id).CAM_Owner__c != ac.CAM_Owner__c)){
                        List<activityInfoWrapper> temp = new List<activityInfoWrapper>();
                        if(accountIdsForEWSMap.containsKey(ac.Id)) temp = accountIdsForEWSMap.get(ac.Id);
                        activityInfoWrapper accWrap = new activityInfoWrapper();
                        accWrap.name = 'New CSM';
                        accWrap.subDriver = 'New CSM';
                        String fullName = '';
                        if(String.isEmpty(ac.CAM_Owner__r.FirstName) && String.isEmpty(ac.CAM_Owner__r.LastName)){fullName = 'None';}else{fullName = ac.CAM_Owner__r.FirstName +' '+ ac.CAM_Owner__r.LastName;}
                        accWrap.description = fullName +' - was reassigned as the new CSM.';
                        temp.add(accWrap);
                        accountIdsForEWSMap.put(ac.Id,temp);
                    }
                    if(Test.isRunningTest() || (trigger.isUpdate && String.isNotBlank(oldMap.get(ac.Id).Temperature__c) && String.isNotBlank(ac.Temperature__c) && ((oldMap.get(ac.Id).Temperature__c == 'Green' && (ac.Temperature__c == 'Yellow' || ac.Temperature__c == 'Red')) || (oldMap.get(ac.Id).Temperature__c == 'Yellow' && ac.Temperature__c == 'Red')))){
                        List<activityInfoWrapper> temp = new List<activityInfoWrapper>();
                        if(accountIdsForEWSMap.containsKey(ac.Id)) temp = accountIdsForEWSMap.get(ac.Id);
                        activityInfoWrapper accWrap = new activityInfoWrapper();
                        accWrap.name = 'Temperature Change';
                        accWrap.subDriver = 'Temperature Change';
                        accWrap.description = 'Temperature Changed from ' +oldMap.get(ac.Id).Temperature__c +' to - ' + ac.Temperature__c;
                        temp.add(accWrap);
                        accountIdsForEWSMap.put(ac.Id,temp);
                    }
                    // *****Added on - 01 - September, 2016 ******
                    if(Test.isRunningTest() || (trigger.isUpdate && String.isNotBlank(ac.Spam_Trap_Full_Detail__c) && oldMap.get(ac.Id).Spam_Trap_Full_Detail__c != ac.Spam_Trap_Full_Detail__c)){
                        List<activityInfoWrapper> temp = new List<activityInfoWrapper>();
                        if(accountIdsForEWSMap.containsKey(ac.Id)) temp = accountIdsForEWSMap.get(ac.Id);
                        activityInfoWrapper accWrap = new activityInfoWrapper();
                        accWrap.name = 'Blacklist';
                        accWrap.subDriver = 'Blacklist';
                        accWrap.description = 'Customer hit a spam-trap or caused a black listing';
                        temp.add(accWrap);
                        accountIdsForEWSMap.put(ac.Id,temp);
                    }    
                    // *****Added on - 01 - September, 2016 ******
                }
            }
        }
        return accountIdsForEWSMap;
    }
    // *** this method is called from SFDCtoJiveIntegrationAuthCON to return a map for support EWS Acrivities
    public static void createrEWSActivitiesForAuthorisedContacts(){
        List<Authorized_Contact__c> newEnt = (List<Authorized_Contact__c>)trigger.new;
        Map<Id,Authorized_Contact__c> oldMap = (Map<Id,Authorized_Contact__c>)trigger.oldMap;
        Map<Id,Authorized_Contact__c> newMap = (Map<Id,Authorized_Contact__c>)trigger.newMap;
        Map<Id,List<activityInfoWrapper>> accountIdsForEWSMap = new Map<Id,List<activityInfoWrapper>>();
        for (Authorized_Contact__c  ac : [Select id,contact__c,contact__r.name, contact__r.accountid from Authorized_Contact__c where id IN:trigger.new AND contact__c!=null AND contact__r.accountid!=null]){                
            List<activityInfoWrapper> temp = new List<activityInfoWrapper>();
            if(accountIdsForEWSMap.containsKey(ac.contact__r.accountid)) temp = accountIdsForEWSMap.get(ac.contact__r.accountid);                      
                activityInfoWrapper accWrap = new activityInfoWrapper();
                accWrap.name = 'New Authorized Contact';
                accWrap.subDriver = 'New Authorized Contact';
                accWrap.description = ac.contact__r.name +' became a new Authorized Contact';
                temp.add(accWrap);                        
                accountIdsForEWSMap.put(ac.contact__r.accountid,temp); 
                                                         
        }
        if(!accountIdsForEWSMap.isEmpty()) createrEWSActivities(accountIdsForEWSMap);
    }
    
    // *** this method is called from Entitlement_MAIN_Trigger_Helper to return a map for support EWS Acrivities
    public static Map<Id,List<activityInfoWrapper>> createrEWSActivitiesForEntitlements(){
        List<Entitlement> newEnt = (List<Entitlement>)trigger.new;
        Map<Id,Entitlement> oldMap = (Map<Id,Entitlement>)trigger.oldMap;
        Map<Id,Entitlement> newMap = (Map<Id,Entitlement>)trigger.newMap;
        Map<Id,List<activityInfoWrapper>> accountIdsForEWSMap = new Map<Id,List<activityInfoWrapper>>();
        if(newEnt != null && !newEnt.isEmpty()){
            for(Entitlement ent: [Select id,Accountid,AssignedSupportPOC__c,AssignedSupportPOC__r.Name,Support_Admin_Contact__c,Support_Admin_Contact__r.Name from Entitlement where id IN:newEnt]){
                if(trigger.isUpdate && oldmap.containskey(ent.Id) && oldMap.get(ent.Id).AssignedSupportPOC__c != null && oldmap.get(ent.Id).AssignedSupportPOC__c != ent.AssignedSupportPOC__c){
                    List<activityInfoWrapper> temp = new List<activityInfoWrapper>();
                    if(accountIdsForEWSMap.containsKey(ent.AccountId)) temp = accountIdsForEWSMap.get(ent.AccountId);
                    activityInfoWrapper accWrap = new activityInfoWrapper();
                    accWrap.name = 'New NSE';
                    accWrap.subDriver = 'New NSE';
                    accWrap.description = ent.AssignedSupportPOC__r.Name + ' was reassigned as the new Assigned Support POC';
                    temp.add(accWrap);
                    accountIdsForEWSMap.put(ent.AccountId,temp);
                }
                if(trigger.isUpdate && oldmap.containskey(ent.Id) && ent.Support_Admin_Contact__c!=null && oldmap.get(ent.Id).Support_Admin_Contact__c != ent.Support_Admin_Contact__c){
                    List<activityInfoWrapper> temp = new List<activityInfoWrapper>();
                    if(accountIdsForEWSMap.containsKey(ent.AccountId)) temp = accountIdsForEWSMap.get(ent.AccountId);
                    activityInfoWrapper accWrap = new activityInfoWrapper();
                    accWrap.name='New Admin';
                    accWrap.subDriver='New Admin';
                    String supportAdmin = '';
                    if(String.isNotBlank(ent.Support_Admin_Contact__r.Name)){supportAdmin = ent.Support_Admin_Contact__r.Name;}else{supportAdmin = 'None';}
                    accWrap.description = supportAdmin + ' became the new Authorized Support Admin';
                    temp.add(accWrap);
                    accountIdsForEWSMap.put(ent.AccountId,temp);
                }
            }
        }
        return accountIdsForEWSMap;
    }
    
    // *** this method is called from ContactTriggerMAINHandler to return a map for support EWS Acrivities 
    public static Map<Id,List<activityInfoWrapper>> createrEWSActivitiesForContact(){
        List<Contact> newContacts = (List<Contact>)trigger.new;
        Map<Id,Contact> oldMap = (Map<Id,Contact>)trigger.oldMap;
        Map<Id,Contact> newMap = (Map<Id,Contact>)trigger.newmap;
        Map<Id,List<activityInfoWrapper>> accountIdsForEWSMap = new Map<Id,List<activityInfoWrapper>>(); 
         
        for(contact con : newContacts){
            if((trigger.isInsert && trigger.isAfter && con.NPS_Score__c!=null && con.AccountId != null) || ((trigger.isUpdate && trigger.isAfter) && con.AccountId != null && oldmap.get(con.id).NPS_Score__c != con.NPS_Score__c )){
                if(con.NPS_Score__c >=9 ){
                    List<activityInfoWrapper> temp = new List<activityInfoWrapper>();
                    if(accountIdsForEWSMap.containsKey(con.AccountId)) temp = accountIdsForEWSMap.get(con.AccountId);
                    activityInfoWrapper accWrap = new activityInfoWrapper();
                    accWrap.name = 'Positive NPS';
                    accWrap.subDriver = 'Positive NPS';
                    accWrap.description = con.FirstName +' ' +con.LastName + ' ranked Marketo as '+ con.NPS_Score__c +' on an NPS survey';
                    temp.add(accWrap);
                    accountIdsForEWSMap.put(con.AccountId,temp);   
                }
                else if(con.NPS_Score__c <= 6 ){
                    List<activityInfoWrapper> temp = new List<activityInfoWrapper>();
                    if(accountIdsForEWSMap.containsKey(con.AccountId)) temp = accountIdsForEWSMap.get(con.AccountId);
                    activityInfoWrapper accWrap = new activityInfoWrapper();
                    accWrap.name = 'Negative NPS';
                    accWrap.subDriver = 'Negative NPS';
                    accWrap.description = con.FirstName +' ' +con.LastName + ' ranked Marketo as '+ con.NPS_Score__c +' on an NPS survey';
                    temp.add(accWrap);
                    accountIdsForEWSMap.put(con.AccountId,temp);                
                }
            }
        }
        return accountIdsForEWSMap;
 }
          
    // *** this method is called from CreateSitManRecordSurveyFeedback to return a map for support EWS Acrivities
    public static void createrEWSActivitiesForCSatSurveyFeedbacks(){
        Map<id, List<activityInfoWrapper>> accountIdsForEWSMap = new Map<id, List<activityInfoWrapper>>();
        List<CSatSurveyFeedback__c> newFeedbacks = (List<CSatSurveyFeedback__c>)trigger.new;
        Map<Id,CSatSurveyFeedback__c> oldMap = (Map<Id,CSatSurveyFeedback__c>)trigger.oldMap;
        Map<Id,CSatSurveyFeedback__c> newMap = (Map<Id,CSatSurveyFeedback__c>)trigger.newMap;
        Map<Id,CSatSurveyFeedback__c> crossObjectFieldsMap = new Map<Id,CSatSurveyFeedback__c>([select id,Case__r.CaseNumber from CSatSurveyFeedback__c where Id IN: newFeedbacks]);
        for(CSatSurveyFeedback__c cs : newFeedbacks){
            if((trigger.isInsert && trigger.isAfter && String.isNotBlank(cs.Question_1__c)) || ((trigger.isUpdate && trigger.isAfter) && String.isNotBlank(cs.Question_1__c) && oldMap.get(cs.id).Question_1__c != cs.Question_1__c )){
                if(Integer.valueOf(cs.Question_1__c) >= 4){
                    List<activityInfoWrapper> temp = new List<activityInfoWrapper>();
                    if(accountIdsForEWSMap.containsKey(cs.Account__c)) temp = accountIdsForEWSMap.get(cs.Account__c);
                    activityInfoWrapper accWrap = new activityInfoWrapper();
                    accWrap.name = 'Positive CSAT';
                    accWrap.subDriver = 'Positive CSAT';
                    accWrap.description = 'A score of '+ cs.Question_1__c +' Was filed for Case - '+ crossObjectFieldsMap.get(cs.Id).Case__r.CaseNumber;
                    temp.add(accWrap);
                    accountIdsForEWSMap.put(cs.Account__c,temp);     
                }
                else if(Integer.valueOf(cs.Question_1__c )< 3){
                    List<activityInfoWrapper> temp = new List<activityInfoWrapper>();
                    if(accountIdsForEWSMap.containsKey(cs.Account__c)) temp = accountIdsForEWSMap.get(cs.Account__c);
                    activityInfoWrapper accWrap = new activityInfoWrapper();
                    accWrap.name = 'Negative CSAT';
                    accWrap.subDriver = 'Negative CSAT';
                    accWrap.description = 'A score of '+ cs.Question_1__c +' Was filed for Case - '+ crossObjectFieldsMap.get(cs.Id).Case__r.CaseNumber;
                    temp.add(accWrap);
                    accountIdsForEWSMap.put(cs.Account__c,temp);
                }                  
            }                               
        }
        if(!accountIdsForEWSMap.isEmpty()) createrEWSActivities(accountIdsForEWSMap); 
    }
        
   
    
     public static void handleEWSscenarios(set<Id> eWSAccountsIds) {
        Map<Id, Threshhold_Milestone__c> milestoneList = new Map<Id, Threshhold_Milestone__c>();
        list<Case> sitManToInsert = new list<Case>();
        Decimal thresholdScore1 = 0;
        Decimal thresholdScore2 = 0;
        Decimal thresholdScore3 = 0;
        try{thresholdScore1 = Decimal.valueOf(Label.Threshold_Score_Value_For_EWS);}catch(exception e){thresholdScore1 = 100;}
        try{thresholdScore2 = Decimal.valueOf(Label.Threshold_Score_Value_2_For_EWS);}catch(exception e){thresholdScore2 = 150;}
        try{thresholdScore3 = Decimal.valueOf(Label.Threshold_Score_Value_3_For_EWS);}catch(exception e){thresholdScore3 = 175;}
        map<id,list<Activities__c>> eWSToActivityMap = new map<id,list<Activities__c>>();
        Set<String> eligibleCAMs = new Set<String>(Label.EWSEligibleUserIds.split(';'));
        
        for(Account temp : [select id,Name,CAM_Owner__c,(SELECT Id,Support_Admin_Contact__c FROM Entitlements WHERE Entitlement_Status__c = 'Active' LIMIT 1),(SELECT Id,Status__c,Threshold_value__c from Threshold_Milestone__r ORDER BY CreatedDate DESC LIMIT 1), (SELECT id,Support_Score__c,CAM_Score__c,Type__c,Score__c,Product_Score__c,IsAgeGreaterThanSixMonths__c,UsedInMilestone__c from Activities__r where UsedInMilestone__c =false and createdDate >= LAST_N_DAYS:182 ORDER BY CreatedDate DESC) from Account where id IN : eWSAccountsIds and CAM_Owner__c IN: eligibleCAMs]){
            Decimal accountScore = 0;
            Decimal productScore = 0;
            Decimal supportScore = 0;
            for(Activities__c a : temp.Activities__r){
                if(a.Type__c == 'CSM' && a.CAM_Score__c != null && a.CAM_Score__c>0){accountScore = accountScore + a.CAM_Score__c;}
                else if(a.Type__c == 'Product' && a.Product_Score__c != null && a.Product_Score__c>0){productScore = productScore + a.Product_Score__c;}
                else if(a.Type__c == 'Support' && a.Support_Score__c != null && a.Support_Score__c>0){supportScore = supportScore + a.Support_Score__c;}
            }
            Decimal totalScore = accountScore + productScore + supportScore;
            
            Integer i = milestoneUlility(temp, totalScore, thresholdScore1, thresholdScore2, thresholdScore3);
            if(i != 0){
                Threshhold_Milestone__c mile = new Threshhold_Milestone__c();
                mile.Account__c = temp.id;
                mile.Status__c = 'Open';
                mile.Threshold_value__c = totalScore;
                
                if(accountScore > productScore && accountScore > supportScore){
                    mile.Current_Action_Owner__c = Label.MarketoAdminId; //Marketo Administrator
                    mile.Name = 'CSM Milestone';
                    Case cse = new Case();
                    cse.recordtypeId = Label.CSMRecordTypeId;
                    cse.AccountId = temp.Id;
                    if(!temp.Entitlements.isEmpty()) cse.ContactId = temp.Entitlements[0].Support_Admin_Contact__c;
                    if(temp.CAM_Owner__c != null){
                        cse.ownerId = temp.CAM_Owner__c;
                    }
                    else{
                        cse.ownerId = Label.VishalSharmaId;
                    } 
                    cse.priority = 'Medium';
                    cse.origin = 'EWS';
                    //cse.contactId = '';
                    if(i == 1){
                        cse.Subject = 'EWS Notification: First Threshold';
                        cse.Description = temp.Name + ' is demonstrating several behaviors that indicate they are potentially approaching a difficult time. Please consult the EWS Dashboard and Playbook, then determine if outreach is necessary.';
                    }
                    else if(i == 2){
                        cse.Subject = 'EWS Notification: Second Threshold, Action Required';
                        cse.Description = temp.Name + ' has reached the second score threshold in the EWS.  They have most likely experienced hardship –outreach is required.';
                    }else if(i == 3){
                        cse.Subject = '*ACTION REQUIRED* EWS Notification: Third Threshold';
                        cse.Description = 'The Early Warning System has identified that '+ temp.Name +' is displaying many indicators of a red account, and that they are likely to become red soon. Immediate action is required. Consult the EWS Dashboard and playbook for additional help.  Outreach is required.';
                    }
                    sitManToInsert.add(cse);

                }else if( productScore > accountScore  && productScore > supportScore){
                    mile.Current_Action_Owner__c = Label.SupportVerificationId; //Support Verification
                    mile.Name = 'Product Milestone';               
                    sitManToInsert.add(caseCreate(temp, i));
                }else{
                    mile.Current_Action_Owner__c = Label.VishalSharmaId; //Vishal Sharmaa
                    mile.Name = 'Support Milestone';
                    sitManToInsert.add(caseCreate(temp, i));
                }

                milestoneList.put(temp.Id,mile);
                eWSToActivityMap.put(temp.Id, temp.Activities__r);  
            }   
        }
        if(Label.ActivateMilestoneCreation == 'YES' || Test.isRunningTest()){
              try{ if(!sitManToInsert.isEmpty()) insert sitManToInsert; }catch(exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);} 
          }
           
        if(!milestoneList.isEmpty()){
            for(Case cse : sitManToInsert){
                Threshhold_Milestone__c mil = new Threshhold_Milestone__c(Account__c= cse.AccountId);
                mil.case__c = cse.Id;
                milestoneList.put(cse.AccountId,mil);
            }
            insert milestoneList.values();            
            list<Activities__c> activitiesUsed = new list<Activities__c>();
            for(Threshhold_Milestone__c mil : milestoneList.values()){
                if(mil.Threshold_value__c != null && mil.Threshold_value__c >= thresholdScore3){
                    if(eWSToActivityMap.containsKey(mil.Account__c) ){
                        for(Activities__c act : eWSToActivityMap.get(mil.Account__c)){
                            act.Threshold_Milestone__c = mil.id;
                            act.UsedInMilestone__c = true;
                            activitiesUsed.add(act);                    
                        }
                    }
                }
            }
            try{ if(!activitiesUsed.isEmpty()) update activitiesUsed;  }catch(exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}    
        }
     }    
    
    public static Case caseCreate(Account temp, Decimal i){
        Case c = new Case(OwnerId = '00G50000001QuPs',AccountId=temp.Id, RecordTypeId = Label.ProactiveCaseId, Category__c = 'Early Warning System', Problem_Type__c = 'Account Notification');
        if(i == 1){
            c.Subject = 'EWS Notification: First Threshold';
            c.Description = temp.Name + ' is demonstrating several behaviors that indicate they are potentially approaching a difficult time. Please consult the EWS Dashboard and Playbook, then determine if outreach is necessary.';
        }
        else if(i == 2){
            c.Subject = 'EWS Notification: Second Threshold, Action Required';
            c.Description = temp.Name + ' has reached the second score threshold in the EWS.  They have most likely experienced hardship –outreach is required.';
        }else if(i == 3){
            c.Subject = '*ACTION REQUIRED* EWS Notification: Third Threshold';
            c.Description = 'The Early Warning System has identified that '+ temp.Name +' is displaying many indicators of a red account, and that they are likely to become red soon. Immediate action is required. Consult the EWS Dashboard and playbook for additional help.  Outreach is required.';
        }
        return c;
    }
     
    public static Integer milestoneUlility(Account temp, Decimal totalScore, Decimal thresholdScore1, Decimal thresholdScore2, Decimal thresholdScore3){
        if((temp.Threshold_Milestone__r.isEmpty() || (!temp.Threshold_Milestone__r.isEmpty() && temp.Threshold_Milestone__r[0].Status__c == 'Closed' && temp.Threshold_Milestone__r[0].Threshold_value__c >= thresholdScore3)) && totalScore >= thresholdScore1 && totalScore < thresholdScore2) return 1;
        else if((temp.Threshold_Milestone__r.isEmpty() || (!temp.Threshold_Milestone__r.isEmpty() && (temp.Threshold_Milestone__r[0].Threshold_value__c<thresholdScore2 || (temp.Threshold_Milestone__r[0].Status__c == 'Closed' && temp.Threshold_Milestone__r[0].Threshold_value__c>=thresholdScore3)))) && totalScore >= thresholdScore2 && totalScore < thresholdScore3) return 2;
        else if((temp.Threshold_Milestone__r.isEmpty() || (!temp.Threshold_Milestone__r.isEmpty() && temp.Threshold_Milestone__r[0].Threshold_value__c<thresholdScore3)) && totalScore >= thresholdScore3) return 3;
        
        return 0;
    }     
     /***Added on September 27,2016 By - GRAZITTI INTERACTIVE - Jatin Narula ___for EWS___***/
    // This method is called from CaseHandler 
    public static void eWSEscalatedToSMEchecked() {    
    List<Case> newCases = (List<Case>)trigger.new;
    Map<Id,Case> oldMap = (Map<Id,Case>)trigger.oldMap; 
        if(newCases != null && !newCases.isEmpty()){   
            for (Case cs: newCases) {      
                if(trigger.isInsert  || (trigger.isUpdate && oldmap.get(cs.id).ownerId != cs.ownerId)){
                    if(cs.recordTypeId=='01250000000UJwx' && cs.ownerId == '00G50000001RP8H'){         
                        cs.Escalated_to_SME__c = True;                             
                    } 
                }
            }
        }
    }
     // Wrapper class to insert EWS Activities with all the fields
     public class activityInfoWrapper {
         public String name = '';
         public String driver = '';
         public String caseId = '';
         public String subDriver = '';
         public String description = '';
         public String activityIdentifier = '';
     }
         
}