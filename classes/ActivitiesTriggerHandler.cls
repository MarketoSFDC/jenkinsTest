/**
GOAL OF THIS CLASS IS USED TO HANDLE ALL EVENT OF TASK AND EVENT TRIGGER AND 
DELEGATE THE EXECUTION TO APPROPRIATE HANDLER.
DEVELOPED BY: GRAZITTI (MARKETO IT)
**/
public class ActivitiesTriggerHandler{
    public static Boolean FLAG = True;
    public static String TSK_TYPE = System.Label.Task_Type_Outbound_Sales_Email;
    public static String TSK_SUB1 = System.Label.Task_Subject_Created_From_Email;
    public static String TSK_SUB2 = System.Label.Task_Subject_Created_Internally;
    
    /*EVENT HANDLER METHODS--START-->*/
    public static void eventBeforeInsertHandler(List<Event> triggerNew) {
        Map<Id,Event> nullTaskMap = new Map<Id,Event>();
        eventLookupFieldsUpdate(triggerNew,nullTaskMap);
    }
    
    public static void eventBeforeUpdateHandler(List<Event> TriggerNew, Map<Id,Event> oldTriggerMap){
        eventLookupFieldsUpdate(TriggerNew, oldTriggerMap);
    }    
    
    public static void eventBeforeDeleteHandler(List<Event> TriggerOld){
        eventTriggerValid(TriggerOld);
    }
    
    public static void eventAfterInsertHandler(List<Event> newTrigger){
        updateScheduledMeetingInfoOnCampMembr(newTrigger, false);
        updateContactUpsellStatusFromEvent(newTrigger);
        createCaseIfCalendlyEvent(newTrigger);
    }
    
    public static void eventAfterUpdateHandler(List<Event> newTrigger){
        updateScheduledMeetingInfoOnCampMembr(newTrigger, false);
        updateContactUpsellStatusFromEvent(newTrigger);
    }
    
    public static void eventAfterDeleteHandler(List<Event> oldTrigger){
        updateScheduledMeetingInfoOnCampMembr(oldTrigger,true);
    }
    
    /*EVENT HANDLER METHODS--ENDS<--*/
    
    /*TASK HANDLER METHODS--STARTS-->*/
    public static void taskBeforeInsertHandler(List<Task> TriggerNew) {
    Map<Id,Task> nullTaskMap = new Map<Id,Task>();
        taskLookupFieldsUpdate(TriggerNew, nullTaskMap );
    }
    
    public static void taskBeforeUpdateHandler(List<Task> TriggerNew, Map<Id,Task> oldTriggerMap) {
        taskLookupFieldsUpdate(TriggerNew, oldTriggerMap);
    }
    
    public static void taskBeforeDeleteHandler(List<Task> TriggerOld) {
        taskTriggerValid(TriggerOld);
    }
    
    public static void TaskAfterInsertHandler(List<Task> TriggerNew) {
        updateCallResultOnContactAndLead(TriggerNew);
        updateContactUpsellStatusFromTask(TriggerNew);
    }
    
    public static void TaskAfterUpdateHandler(List<Task> TriggerNew) {
        updateCallResultOnContactAndLead(TriggerNew);
        updateContactUpsellStatusFromTask(TriggerNew);
    }    
    /*TASK HANDLER METHODS--ENDS<--*/
    
    /*HELPER METHOD STARTS-->*/
    public static void eventLookupFieldsUpdate(List<Event> TriggerNew, Map<Id,Event> oldTriggerMap) {
        for(Event ent: TriggerNew) {
        
            ent.Contact__c     = null;  
            ent.Lead__c        = null;  
            ent.Opportunity__c = null;
            Map <String,Activity_Teams__c> activityTeamsMap = Activity_Teams__c.getAll();
            
            if(ent.WhoId != Null && String.valueOf(ent.WhoId).startsWith('003')){
                ent.Contact__c = ent.WhoID;
            }          
            if(ent.WhoId != Null && String.ValueOf(ent.WhoId).startsWith('00Q')){
                ent.Lead__c = ent.WhoID;
            }              
            if(ent.WhatId != Null && String.valueOf(ent.WhatId).startsWith('006')){
                ent.Opportunity__c = ent.WhatId;
            }
            /*if((trigger.isInsert && ent.AE_Involved__c != null)||(trigger.isUpdate && ent.AE_Involved__c != oldTriggerMap.get(ent.Id).AE_Involved__c) )
            {
                //Activity Teams custom setting populating Teams in Task//
                if(!activityTeamsMap.isEmpty()){
                    if(activityTeamsMap.containsKey(ent.AE_Involved__c)){
                        ent.Teams__c = activityTeamsMap.get(ent.AE_Involved__c).Team__c;
                    }
                }
            }*/
        }
    }
    
    public static void taskLookupFieldsUpdate(List<Task> TriggerNew, Map<Id,Task> oldTriggerMap) {
        for(Task tsk: TriggerNew) { 
           
            tsk.Contact__c     = null;  
            tsk.Lead__c        = null;  
            tsk.Opportunity__c = null;
            
            Map <String,Activity_Teams__c> activityTeamsMap = Activity_Teams__c.getAll();
            
            if(tsk.WhoId != Null && String.valueOf(tsk.WhoId).startsWith('003')){
                tsk.Contact__c = tsk.WhoID;
            }          
            if(tsk.WhoId != Null && String.ValueOf(tsk.WhoId).startsWith('00Q')){
                tsk.Lead__c = tsk.WhoID;
            }              
            if(tsk.WhatId != Null && String.valueOf(tsk.WhatId).startsWith('006')){
                tsk.Opportunity__c = tsk.WhatId;
            }
            if(tsk.Subject != Null && (tsk.Subject.containsIgnoreCase(TSK_SUB1) || tsk.Subject.containsIgnoreCase(TSK_SUB2))){
                tsk.Type = TSK_TYPE;
            }
            /*if((trigger.isInsert && tsk.AE_Involved__c != null)||(trigger.isUpdate && tsk.AE_Involved__c != oldTriggerMap.get(tsk.Id).AE_Involved__c) )
            {
                //Activity Teams custom setting populating Teams in Task//
                if(!activityTeamsMap.isEmpty()){
                    if(activityTeamsMap.containsKey(tsk.AE_Involved__c)){
                        tsk.Teams__c = activityTeamsMap.get(tsk.AE_Involved__c).Team__c;
                    }
                }
            }*/
        }
    }
    
    public static void updateCallResultOnContactAndLead(List<Task> TriggerNew){
        Set<Id> contactIds              = new Set<ID>();
        Set<Id> leadIds                 = new Set<ID>();
        Map<Id,String> closedTaskMap    = new Map<Id,String>();
        Map<Id,String> openTaskMap      = new Map<Id,String>();
        List<Contact> updateContactList = new List<Contact>();
        List<Lead> updateLeadList = new List<Lead>();
    
        for(Task tsk: TriggerNew) {                
            if(tsk.WhoId != Null && (String.valueOf(tsk.WhoId).startsWith('003') || String.valueOf(tsk.WhoId).startsWith('00Q'))){
                if(tsk.Call_Disposition__c != null && tsk.Call_Disposition__c != ''){
                    if(tsk.isClosed){
                        closedTaskMap.put(tsk.WhoID, tsk.Call_Disposition__c);
                    }else{
                        openTaskMap.put(tsk.WhoID, tsk.Call_Disposition__c);
                    }
                }
                if(String.valueOf(tsk.WhoId).startsWith('003')){
                    contactIds.add(tsk.WhoID);
                }
                if(String.valueOf(tsk.WhoId).startsWith('00Q')){
                    leadIds.add(tsk.WhoID);
                }
            }
        }
        
        /*if(!contactIds.isEmpty()) {
            for(ID contactId: contactIds) {
                Contact con = new Contact(Id = contactId);
                if(!openTaskMap.isEmpty()){
                    if(openTaskMap.containsKey(con.Id)){
                        con.CAS_Call_Result__c = openTaskMap.get(con.ID);
                    }
                }else if(!closedTaskMap.isEmpty()){
                    if(closedTaskMap.containsKey(con.Id)){
                        con.CAS_Call_Result__c = closedTaskMap.get(con.ID);
                    }
                }else{
                    con.CAS_Call_Result__c = '';
                }
                updateContactList.add(con);
            }
        }*/
        
        /*if(!leadIds.isEmpty()) {
            for(ID leadId: leadIds) {
                Lead led = new Lead(Id = leadId);
                if(!openTaskMap.isEmpty()){
                    if(openTaskMap.containsKey(led.Id)){
                        led.CAS_Call_Result__c = openTaskMap.get(led.ID);
                    }
                }else if(!closedTaskMap.isEmpty()){
                    if(closedTaskMap.containsKey(led.Id)){
                        led.CAS_Call_Result__c = closedTaskMap.get(led.ID);
                    }
                }else{
                    led.CAS_Call_Result__c = '';
                }
                updateLeadList.add(led);
            }
        }*/
        
        if(FLAG == True){
            FLAG = False;
            try{
                if(!updateContactList.isEmpty()){
                    update updateContactList;
                }
                if(!updateLeadList.isEmpty()){
                    update updateLeadList;
                }
            }
            Catch(Exception e){
                System.Debug('*******'+e.getMessage());
            }
        }   
    }
   
    public static void eventTriggerValid(List<Event> TriggerOld){
        String SDTEAM = System.Label.SFDC_Event_Ownership;
        for(Event ev: TriggerOld){
            if(SDTEAM.contains(UserInfo.getUserRoleId())){
                if(UserInfo.getUserId() != ev.OwnerID){
                    ev.addError(System.Label.SFDC_Event_Ownership_Error_Message);    
                }
            }
        }
    }  
      
    public static void taskTriggerValid(List<Task> TriggerOld){
        String SDTEAM = System.Label.SFDC_Event_Ownership;
        for(Task ev: TriggerOld){
            if(SDTEAM.contains(UserInfo.getUserRoleId())){
                if(UserInfo.getUserId() != ev.OwnerID){
                    ev.addError(System.Label.SFDC_Event_Ownership_Error_Message);    
                }            
            }        
        }
    }
    
    public static void updateScheduledMeetingInfoOnCampMembr(List<Event> newTrigger, Boolean flagDeleted) {
        
        Set<Id> contactIds      = new Set<Id>();
        Set<Id> allwhoIds = new Set<Id>();
        Set<Id> leadsIds        = new Set<Id>();  
        Set<Id> allcontactIds      = new Set<Id>();
        Set<Id> allleadsIds        = new Set<Id>();       
        List<CampaignMember> updateCampMembrsList = new List<CampaignMember>(); 
        Map<String, Boolean> lead_contactIdsWithScheduledInfo = new Map<String, Boolean>();
        Map<Id, DateTime> lead_contact_CampaignMemberInfo = new Map<Id, DateTime>();
    
        ///*** All the contacts and Leads who have events and the event have subject as 'Meeting'***///
        for(Event ev : newTrigger) {
            if(ev.Subject!=  null && ev.Subject.ContainsIgnoreCase('Meeting')) {
                if(ev.WhoId != null && String.valueOf(ev.WhoId).startsWith('003')) {
                    if(ev.EndDateTime < System.now() || flagDeleted) {
                        contactIds.Add(ev.WhoId);
                    }else{
                        lead_contact_CampaignMemberInfo.put(ev.whoId, ev.StartDateTime);
                        lead_contactIdsWithScheduledInfo.put(ev.WhoId, true);
                        allcontactIds.Add(ev.WhoId);
                    }                   
                }
                if(ev.WhoId != null && String.valueOf(ev.WhoId).startsWith('00Q')) {
                    if(ev.EndDateTime < System.now() || flagDeleted) {
                        leadsIds.Add(ev.WhoId);
                    }else {
                        lead_contact_CampaignMemberInfo.put(ev.whoId, ev.StartDateTime);
                        lead_contactIdsWithScheduledInfo.put(ev.WhoId, true);
                        allleadsIds.Add(ev.WhoId);
                    }                   
                }
            }else {
                if(ev.WhoId != null && String.valueOf(ev.WhoId).startsWith('003')) contactIds.Add(ev.WhoId); 
                if(ev.WhoId != null && String.valueOf(ev.WhoId).startsWith('00Q')) leadsIds.Add(ev.WhoId);
            }
        }///Close of for Loop
    
        allleadsIds.addAll(leadsIds);
        allcontactIds.addAll(contactIds);
        allwhoIds.addAll(allleadsIds);
        allwhoIds.addAll(allcontactIds);
    
        
        if(!contactIds.isEmpty() || !leadsIds.isEmpty()) {
            for(Event opEvent: [SELECT Id, WhoId, StartDateTime FROM Event WHERE WhoId IN: allwhoIds AND Subject like '%Meeting%' LIMIT 10000 ]) {
                
                lead_contactIdsWithScheduledInfo.put(opEvent.WhoId, true);
                lead_contact_CampaignMemberInfo.put(opEvent.whoId,opEvent.StartDateTime);
            }
        }
        for(CampaignMember cm: [SELECT Sales_Meeting_Scheduled_Date__c,Sales_Meeting_Scheduled__c, LeadId, ContactId FROM CampaignMember WHERE LeadId IN: allleadsIds OR ContactId IN: allcontactIds]) {
             if(lead_contactIdsWithScheduledInfo.isEmpty() || !(lead_contactIdsWithScheduledInfo.containsKey(cm.LeadId)) || !(lead_contactIdsWithScheduledInfo.containsKey(cm.ContactId))){
               cm.Sales_Meeting_Scheduled__c = False;  
               cm.Sales_Meeting_Scheduled_Date__c =null;            
            }
            if(lead_contactIdsWithScheduledInfo.containsKey(cm.LeadId) ||lead_contactIdsWithScheduledInfo.containsKey(cm.ContactId)) {
                if(cm.Sales_Meeting_Scheduled__c != True) {
                    cm.Sales_Meeting_Scheduled__c = TRUE;
                    if(lead_contact_CampaignMemberInfo.containsKey(cm.LeadId)){
                    cm.Sales_Meeting_Scheduled_Date__c = lead_contact_CampaignMemberInfo.get(cm.LeadId);
                    }
                    else if(lead_contact_CampaignMemberInfo.containsKey(cm.ContactId)){
                    cm.Sales_Meeting_Scheduled_Date__c = lead_contact_CampaignMemberInfo.get(cm.ContactId);
                    }
                }  
            }
            updateCampMembrsList.add(cm);
        }
        if(!updateCampMembrsList.isEmpty()) {
            update updateCampMembrsList;           
        } 
    } ///Close of function
    
    
    
    public static void updateContactUpsellStatusFromEvent(List<Event> newList){
        List<Contact> contactListToBeUpdated = new List<Contact>();
        Set<Id> conIds = new Set<Id>();
        for(Event evt : newList){
            if(evt.Contact__c != null){
                if(evt.Subject != null){
                    if(evt.Subject != null && evt.Subject.containsIgnoreCase('Vorsight') && !evt.Subject.containsIgnoreCase('follow') && evt.Meeting_Status__c == 'Completed'){
                        conIds.add(evt.Contact__c);
                    }
                }
            }
        }
        if(conIds != null && !conIds.IsEmpty()){
            for(Contact con : [ SELECT Id, Upsell_Status__c FROM Contact WHERE Id IN: conIds ]){
                con.Upsell_Status__c = 'Completed';
                contactListToBeUpdated.add(con);
            }
            if(!contactListToBeUpdated.isEmpty()){
                update contactListToBeUpdated;
            }
        }
    }
    
    public static void updateContactUpsellStatusFromTask(List<Task> newList){
        List<Contact> contactListToBeUpdated = new List<Contact>();
        Set<Id> conIds = new Set<Id>();
        for(Task evt : newList){
            if(evt.Contact__c != null){
                if(evt.Subject != null){
                    if(evt.Subject != null && evt.Subject.containsIgnoreCase('Vorsight') && !evt.Subject.containsIgnoreCase('follow') && evt.Meeting_Status__c == 'Completed'){
                        conIds.add(evt.Contact__c);
                    }
                }
            }
        }
        if(conIds != null && !conIds.IsEmpty()){
            for(Contact con : [ SELECT Id, Upsell_Status__c FROM Contact WHERE Id IN: conIds ]){
                con.Upsell_Status__c = 'Completed';
                contactListToBeUpdated.add(con);
            }
            if(!contactListToBeUpdated.isEmpty()){
                update contactListToBeUpdated;
            }
        }
    }
    
    public static void createCaseIfCalendlyEvent(List<Event> newList){
        try{
            Map<Id, Case> eventCaseMap = new Map<Id, Case>();
            List<CaseComment> caseCommentList = new List<CaseComment>();
            Map<Id,Case> caseMapToUpdate = new Map<Id,Case>();
            Set<String> prefixToCheck = new Set<String>(Label.CalendlyPrefixes.split(','));
            for(Event e : newList){
            
                if(String.isNotBlank(e.Subject) && e.Subject.contains('- Calendly - ')){
                    if(e.WhatId == null && e.whoId != null && (''+e.whoId).startsWith('003')){//,OwnerId = ownerIdForCase
                        String actualCategory = e.Subject.substringBetween(': ',' - Calendly').trim();
                        String thePrefix = actualCategory.subString(0, 3); 
                        if(prefixToCheck.contains(thePrefix)){                            
                            String category = actualCategory.substringAfter(thePrefix).trim();
                            String body = (e.Description.replace('Event Details:', e.EventDetails__c)).replaceAll('_BR_ENCODED_', '\n');
                            eventCaseMap.put(e.Id,new Case(Meeting_Date__c = e.StartDateTime,OwnerId = e.OwnerId,Category__c=category,RecordTypeId=Label.RecordTypeIdForCalendlyCase,Problem_Type__c=Label.ProblemTypeForCalendlyCase,Subject = e.Subject,ContactId = e.whoId,description = body,origin='Calendly',priority='P4'));
                        }
                    }else if(e.WhatId != null && (''+e.WhatId).startsWith('500')){
                        String body = (e.Description.replace('Event Details:', e.EventDetails__c)).replaceAll('_BR_ENCODED_', '\n');
                        caseCommentList.add(new CaseComment(CommentBody = '\n'+ body, ParentId = e.WhatId,IsPublished = true));
                        caseMapToUpdate.put(e.WhatId,new Case(id = e.WhatId,status = 'Needs Reply'));
                    }
                }
            }
            if(!CaseCommentList.isEmpty()) Database.insert(CaseCommentList,false);
            if(!caseMapToUpdate.isEmpty()) Database.update(caseMapToUpdate.values(),false);
            if(!eventCaseMap.isEmpty()){
                Database.insert(eventCaseMap.values(),false);
                List<Event> eventsToUpdate = new List<Event>();
                for(Id i : eventCaseMap.keySet()){
                    eventsToUpdate.add(new Event(Id=i, WhatId = eventCaseMap.get(i).Id));
                }
                if(!eventsToUpdate.isEmpty()) Database.update(eventsToUpdate, false);
            }
        }catch(exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
    }
    
      /*********************************************************************************************************
     The below method is written to add an internal case comment when an automated email is sent by system.
     
    ***********************************************************************************************************/
    public static void addInternalCommentForTask(List<Task> taskList){
    try{
        List<CaseComment> ccListToInsert = new List<CaseComment>();
        for(Task t : taskList){
            if(t.whatid != null && String.isNotBlank(t.subject) && String.valueOf(t.whatid).startsWith('500') && t.subject.contains('1st Awaiting Customer Input')){
                ccListToInsert.add(new CaseComment(parentId = t.whatId,CommentBody = '1st Awaiting Customer Input Customer Reminder Sent'));
            }
            else if(t.whatid != null && String.isNotBlank(t.subject) && String.valueOf(t.whatid).startsWith('500') && t.subject.contains('2nd Awaiting Customer Input')){
                ccListToInsert.add(new CaseComment(parentId = t.whatId,CommentBody = '2nd Awaiting Customer Input Customer Reminder Sent'));
            }
            else if(t.whatid != null && String.isNotBlank(t.subject) && String.valueOf(t.whatid).startsWith('500') && t.subject.contains('1st Suggestion Provided')){
                ccListToInsert.add(new CaseComment(parentId = t.whatId,CommentBody = '1st Suggestion Provided Customer Reminder Sent'));
            }
            else if(t.whatid != null && String.isNotBlank(t.subject) && String.valueOf(t.whatid).startsWith('500') && t.subject.contains('2nd Suggestion Provided')){
                ccListToInsert.add(new CaseComment(parentId = t.whatId,CommentBody = '2nd Suggestion Provided Customer Reminder Sent'));
            }
          }
            if(ccListToInsert.isEmpty() == False) Database.Insert(ccListToInsert,false);
        }
        catch(exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
    }
    
}