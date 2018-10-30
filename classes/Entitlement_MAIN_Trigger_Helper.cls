/*********************************************************************
* Last Modified by   : Grazitti Support 
* Modified Date      : 28-April-18
* Purpose            : #01009688 Consolidate Support Engineer Fields on Entitlement
* Line numbers       : 51,94,98,102,105,152,153

**********************************************************************/
public class Entitlement_MAIN_Trigger_Helper{
    
    private static boolean isBeforeInsertHandlerInBulk_done = false;
    private static boolean isBeforeUpdateHandlerInBulk_done = false;
    private static boolean isAfterInsertHandlerInBulk_done  = false;   
    private static boolean isAfterUpdateHandlerInBulk_done  = false;  
    
    public static boolean isEntitlement_MAIN_TriggerExecuted = false;
    public static boolean onbaordngEmailSentToAdmin = false;
    public static Set<String> businessEnts = new Set<String>(Label.Business_Entitlement_Types.split(','));
    public static Marketo_Trigger_Management__c EntitlementTriggerSetting = Marketo_Trigger_Management__c.getInstance();  
    
    /***----------------------------------------------------------------------------------------------------------------------------------
    BEFORE INSERT HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE BEFORE INSERTING THE RECORDS
    -----------------------------------------------------------------------------------------------------------------------------------***/  
    public static void beforeInsertHandlerInBulk(List<Entitlement> newList){
        if(isBeforeInsertHandlerInBulk_done) return; isBeforeInsertHandlerInBulk_done = true;
        UpdateEntitlements_Trigger.AssignSubscriptionEndDate_OnInsert(newList);
        try{UpdateEntitlements_Trigger.AssignNSMForBusinessEntitlements_OnInsert(newList);}
        catch(Exception e) {system.debug('Exception =======>'+e);CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}                
    }
    
    /***-----------------------------------------------------------------------------------------------------------
    BEFORE UPDATE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE BEFORE UPDATING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/        
    public static void beforeUpdateHandlerInBulk(List<Entitlement> newList, Map<Id, Entitlement> newMap, Map<Id, Entitlement> oldMap){
        if(isBeforeUpdateHandlerInBulk_done ) return; isBeforeUpdateHandlerInBulk_done = true;
        UpdateEntitlements_Trigger.ClearSubscriptionEndDate_OnUpdate(newMap, oldMap);
        UpdateEntitlements_Trigger.clearInactiveUsersOnEntitlementUpdate(Trigger.new);          
        try{UpdateEntitlements_Trigger.AssignNSMForBusinessEntitlements_OnUpdate(newMap, oldMap);}
        catch(Exception e) {system.debug('Exception =======>'+e);CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}                
    }
    
    /***-----------------------------------------------------------------------------------------------------------
    BEFORE DELETE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE BEFORE DELETING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/   
    public static void afterInsertHandlerInBulk(List<Entitlement> newList, Map<Id, Entitlement> newMap){
        if(isAfterInsertHandlerInBulk_done ) return; isAfterInsertHandlerInBulk_done = true;
        if(!Utility.DO_NOT_UPDATE_ACCOUNT_FROM_OPPTY) UpdateEntitlements_Trigger.updateEntitlementAccount(newMap);
        
        try{
            Set<Id> entIds= new Set<Id>();
            Map<Id,Id> acctMap = new Map<Id,Id>();
            //MASTER LOOP. KEEP EVERY BASE LOGIC/FILTER HERE
            for(Entitlement ent: newList){
                if((ent.type == 'Premier' || ent.type == 'Premier Plus') && ent.AssignedSupportPOC__c == Null){
                    entIds.add(ent.Id);
                }
                if(ent.Opportunity__c != null && (ent.type =='Secured Landing Pages' || ent.type =='Secured Tracking Links') && Support_Switches__c.getInstance('SecuredDomainSSL') != null && Support_Switches__c.getInstance('SecuredDomainSSL').isActive__c == 'Yes'){
                    acctMap.put(ent.accountId,ent.Id);
                } 
            }
            if(acctMap != null && acctMap.isEmpty() == False){
                UpdateEntitlements_Trigger.ProactiveCaseForSecuredDomains(acctMap);
            }
            if(!entIds.isEmpty() && Label.Premier_SM_Creation == 'Yes'){
                UpdateEntitlements_Trigger.createSMcaseforPremierEntitlements(entIds);      
            }
            if(label.enableKickoffcase=='Yes'){
                UpdateEntitlements_Trigger.SendEmailToNSEForPremiumEntitlements_OnInsert(newList);
            }
                
        }catch(Exception e) {system.debug('Exception =======>'+e);CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);} 
    }
    
    
    /***-----------------------------------------------------------------------------------------------------------
    AFTER INSERT HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER INSERTING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/   
    public static void afterUpdateHandlerInBulk(List<Entitlement> newList, Map<Id, Entitlement> newMap, Map<Id, Entitlement> oldMap){
        if(isAfterUpdateHandlerInBulk_done ) return; isAfterUpdateHandlerInBulk_done = true;
 
        try{
            if(label.enableKickoffcase=='Yes'){
                UpdateEntitlements_Trigger.SendEmailToNSEForPremiumEntitlements_OnUpdate(newMap,oldMap);
            }
        }catch(Exception e) {system.debug('Exception =======>'+e);CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);} 
        
        //MASTER LOOP. KEEP EVERY BASE LOGIC/FILTER HERE
        list<id> BusinessEnt = new list<id>();
        list<id> BusinessEnttoNotify = new list<id>();
        List<Id> entIds = new List<Id>();
        Set<Id> enIds= new Set<Id>();
        // Call this Method to insert an EWS activity Added on September 29, 2016 - Grazitti Interactive - Jatin Narula
       
        Map<Id,List<EWSUtility.activityInfoWrapper>> accountIdsForEWSMap = new Map<Id,List<EWSUtility.activityInfoWrapper>>();
        try {
            if(Test.isRunningTest() || Label.EWSActivator == 'YES') accountIdsForEWSMap = EWSUtility.createrEWSActivitiesForEntitlements(); 
            // Call this Method to insert an EWS activity Added on September 29, 2016 - Grazitti Interactive - Jatin Narula
        }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        
        for(Entitlement ent: newList){
            checkJiveIntegrationCriteria(ent, oldMap.get(ent.Id));
            system.debug('ent====>>>>>'+ent);
            system.debug('ent OLD====>>>>>'+oldmap.get(ent.id));
            if(businessEnts.Contains(ent.type) && ent.AssignedSupportPOC__c !=null && ent.Support_Admin_Contact__c != null && oldmap.get(ent.id).Support_Admin_Contact__c == null){
                BusinessEnt.add(ent.id);
                BusinessEnttoNotify.add(ent.id);                              
            }
            if(businessEnts.Contains(ent.type) && ent.AssignedSupportPOC__c != null && oldmap.get(ent.id).AssignedSupportPOC__c == null){
                BusinessEnt.add(ent.id); 
                BusinessEnttoNotify.add(ent.id);                             
            } 
            if(((oldMap.get(ent.Id) != null && oldMap.get(ent.Id).AssignedSupportPOC__c == Null && ent.AssignedSupportPOC__c!= Null) ||  (oldMap.get(ent.id) != null && oldMap.get(ent.id).type != ent.type)) && (ent.type == 'Premier' || ent.type == 'Premier Plus')){
                entIds.add(ent.Id);
            }  
            if(((oldMap.get(ent.Id).type != ent.type) || (oldMap.get(ent.Id).AssignedSupportPOC__c != ent.AssignedSupportPOC__c))  && ent.AssignedSupportPOC__c == Null && (ent.type == 'Premier' || ent.type == 'Premier Plus')){  
               enIds.add(ent.Id);
            }        
        }
        try{
            if(!enIds.isEmpty() && Label.Premier_SM_Creation == 'Yes'){
                UpdateEntitlements_Trigger.createSMcaseforPremierEntitlements(enIds);
                    
            }
            if(!BusinessEnt.Isempty()) {
                onbaordngEmailSentToAdmin=true;
                UpdateEntitlements_Trigger.SendnotificationToBusinessAuthCon(BusinessEnt);
            } 
            if(BusinessEnttoNotify.IsEmpty() == FALSE) {
                UpdateEntitlements_Trigger.BusinessEntCreationEmailtoCAM(BusinessEnttoNotify);
            }
            if(!entIds.isempty()){
                UpdateEntitlements_Trigger.NotifyNewPremierCustomer(entIds);
            }
            // Call this Method to insert an EWS activity Added on September 29, 2016 - Grazitti Interactive - Jatin Narula
            if((Test.isRunningTest() || Label.EWSActivator == 'YES') && !accountIdsForEWSMap.isEmpty()) EWSutility.createrEWSActivities(accountIdsForEWSMap); 
            // Call this Method to insert an EWS activity Added on September 29, 2016 - Grazitti Interactive - Jatin Narula
            
        }catch (Exception e) {
            system.debug('Exception =======>'+e);
            CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);
        }        
        if(!Utility.DO_NOT_UPDATE_ACCOUNT_FROM_OPPTY) UpdateEntitlements_Trigger.updateEntitlementAccount(newMap); 
        if (!Utility.haveupdatedLMSEntitlement){
            Utility.haveupdatedLMSEntitlement = true; 
            LMS_Util.updateUniqueCode(newMap, true);
        }
        
        updateJiveProfileFromSFDC();
                
    }  
    
    
    /*****-------------------HELPER METHODS --STARTED ---------------**/
    static Map<Id, String> entStringMap = new Map<Id, String>();
    public static void checkJiveIntegrationCriteria(Entitlement newVersion, Entitlement oldVersion){
        boolean GoAhead = false;
        String EntString = '';
        if(newVersion.Support_Region__c != oldVersion.Support_Region__c){
            EntString = '#SupportRegion#' +newVersion.Support_Region__c+ '#SupportRegion1#'; 
            GoAhead = true;
        }
        if(newVersion.AssignedSupportPOC__c != oldVersion.AssignedSupportPOC__c){
            EntString += '#NSE#' +newVersion.AssignedSupportPOC__c+ '#NSE1#';           
            GoAhead = true;
        }
        /*if(newVersion.Named_Support_Manager__c!= oldVersion.Named_Support_Manager__c){
            EntString += '#NSM#' +newVersion.Named_Support_Manager__c+ '#NSM1#';
            GoAhead = true;
        }
        if(newVersion.Technical_Account_Manager__c != oldVersion.Technical_Account_Manager__c){
            EntString += '#TAM#' +newVersion.Technical_Account_Manager__c+ '#TAM1#';
            GoAhead = true;
        } */
        if(newVersion.type!= oldVersion.type){
            EntString += '#type#' +newVersion.type+ '#type1#';
            GoAhead = true;
        } 
        if(GoAhead) entStringMap.put(newVersion.id, EntString);   
    }
    
    public static void updateJiveProfileFromSFDC(){
        if(System.isBatch() || System.isFuture() || Label.JiveSyncEnable !='True') return;
        
        Map<string, string> munchkinIdMap = new Map<string, string>();
        Map<string, string> ConEmailStringMap = new Map<string, string>();
        Map<id, string> ConIdEmailMap  = new Map<id, string>();
        Map<id, string> ConIDStringMap = new Map<id, string>();
        
        List<id> accList = new List<id>();
        if(!entStringMap.isempty()) {
            for (entitlement temp : [select id, asset.Munchkin_ID__c,AccountId from entitlement where id in :EntStringMap.keyset()]) {
                munchkinIdMap.put(temp.asset.Munchkin_ID__c, EntStringMap.get(temp.id));
                accList.add(temp.accountid);
            }
            if(!munchkinIdMap.isempty() && !accList.isempty()) {
                for(contact temp : [select id, email, Munchkin_ID__c from contact where accountid in: accList and Munchkin_ID__c !=null And Munchkin_ID__c !='' And Munchkin_ID__c In :munchkinIdMap.keyset()]) {
                    ConIDStringMap.put(temp.id, munchkinIdMap.get(temp.Munchkin_ID__c));
                    ConIdEmailMap.put(temp.id, temp.email);
                }
            }
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
   
}