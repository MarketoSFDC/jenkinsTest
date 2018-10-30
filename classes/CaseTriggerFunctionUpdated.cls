/* This class is created to handle new updates in support Case trigger 6th July. By Grazitti Support Team*/
/*********************************************************************
* Last Modified by   : Grazitti Support 
* Modified Date      : 28-April-18
* Purpose            : #01009688 Consolidate Support Engineer Fields on Entitlement
* Line numbers       : 196-199,236,250

**********************************************************************/

public class CaseTriggerFunctionUpdated {  

    public static Id supCaseRecordTypeId  = '01250000000UJwxAAG';    
    public static boolean updateMilestoneForCustomerSucessCases = false;
    public static boolean updateMilestoneForFeedbackCases = false;
    public static boolean recursionSwtichForTier3 = false;
    public static list<Global_SLA__c> gSLAlist = [select id,Support_Level__c, Priority__c,Recordtype_Id__c,Resolution_Time__c,First_Response_Time__c,Case_Update_Milestone_Time__c from Global_SLA__c];
    public static Set<String> dedicatedSLARecType = new Set<String>(Label.CustomSupportPortalRecTypeId.split(';'));

    /*****************************************************************************************************
            Below method is written to populate attachments for support cases
     ******************************************************************************************/
    @future    
    public static void copyEmailAttachmentToCase(Id emailMessageId, id caseId){  

        List<Attachment> attachments = new List<Attachment>();
        attachments = [Select Id, Name, ParentId, Body, IsPrivate, OwnerId FROM Attachment WHERE ParentId = :emailMessageId];
        if(attachments.size() > 0){
            List<Attachment> newAttachments = new List<Attachment>();
            for(Attachment att : attachments){
                if(att.ParentId != null){
                    Attachment a = new Attachment();
                    a.ParentId = caseId;
                    a.body =att.body;
                    a.IsPrivate = false;
                    a.name=att.name;           
                    newAttachments.add(a);            
                }
            }
            insert newAttachments;
        }
    }
    /****************************************************************************************************
            Below method is written to populate case team for manually created support cases
     ******************************************************************************************/
    public static CaseTeamTemplateRecord insertCaseTeam(Case cas1){
        CaseTeamTemplateRecord ct = new CaseTeamTemplateRecord();        
        if((cas1.recordtypeId == supCaseRecordTypeId && cas1.createdbyId != Label.JiveSyncUserId && cas1.createdbyId != label.System_Admin_Id && (UserInfo.getUseremail().contains('@marketo.com') || UserInfo.getUseremail().contains('@grazitti.com') )) ){
            ct.parentId = cas1.ID;
            ct.TeamTemplateId= label.CaseTeamTemplateId; 
            return ct;
        }
        return null;    
    }
    /**********************************************************************************************
            Below method is written to populate CSM Account for CSM recordtype cases
     ***********************************************************************************/
    public static void populateCsmAccountName(Case cse){
        if(cse.AccountId != null && cse.RecordTypeId == label.CSM_RecordType_Id|| cse.RecordTypeId == label.CCareRecordTypeId18 )cse.CSM_Account_Name__c = cse.AccountId;
    }
    
    /**********************************************************************************************
        Below method is written to manage case milestones for CSM and C-care cases.
    ************************************************************************************************/  
    public static List<Case_Update_Milestones__c> updateMilestoneForCustomerSucessCases(){
            Set<string> IgnoreStatuses = new set<string>(Case_Statuses__c.getInstance('Case Status').Ignore_Case_Status_Values__c.split(','));
            Set<string> NonIgnoreStatuses = new set<string>(Case_Statuses__c.getInstance('Case Status').Non_Ignore_Case_Status_Values__c.split(','));
            Map<Id,String> caseMap = new Map<Id,String>();
            Boolean isPriorityDowngrade = False;
            Global_SLA__c gSLA = new Global_SLA__c();
            list<Case_Update_Milestones__c> cmListToUpsert = new list<Case_Update_Milestones__c>();
            Set<String> testSet;
            for(sObject c : trigger.new){
            case cs = (case) c; 
            
            if(trigger.IsInsert && ((cs.recordtypeId == Label.CSM_RecordType_Id || cs.recordtypeId == Label.CCareRecordTypeId18 || cs.recordtypeId == Label.SupportFeedBackRecTypeId || cs.recordtypeId == Label.tier3FullRecordTypeId || cs.recordtypeId == Label.SitManSupportRecordTypeId) || (cs.recordtypeId == Label.SupportCaseRecordTypeId && cs.Category__c == 'ToutApp' && cs.EntitlementId == null))){
                gSLA = findGslaRecord(cs);
                if(gSLA.id != null){
                    if(cs.recordtypeId != null){
                         cmListToUpsert.add(createCustomMilestone(cs.businessHoursId,integer.valueof(gSLA.First_Response_Time__c),cs.id,'First Response',Label.System_Admin_Id,cs.recordtypeId ));
                    }
                    if(cs.recordtypeId == Label.SupportFeedBackRecTypeId || cs.recordtypeId == Label.tier3FullRecordTypeId || cs.recordtypeId == Label.SupportCaseRecordTypeId || cs.recordtypeId == Label.SitManSupportRecordTypeId){
                        cmListToUpsert.add(createCustomMilestone(cs.businessHoursId,integer.valueof(gSLA.Resolution_Time__c),cs.id,'Resolution Response',Label.System_Admin_Id,cs.recordtypeId));
                    }
                }
            }else if(trigger.IsUpdate && ((cs.recordtypeId == Label.CSM_RecordType_Id || cs.recordtypeId == Label.CCareRecordTypeId18 || cs.recordtypeId == Label.SupportFeedBackRecTypeId || cs.recordtypeId == Label.SitManSupportRecordTypeId || cs.recordtypeId == Label.tier3FullRecordTypeId) || (cs.recordtypeId == Label.SupportCaseRecordTypeId && cs.Category__c == 'ToutApp' && cs.EntitlementId == null)) ){
                gSLA = findGslaRecord(cs);
                case oldCase = (case) trigger.oldMap.get(cs.id);
                if(gSLA.id != null){
                    if((IgnoreStatuses.contains(cs.status) && NonIgnoreStatuses.contains(oldCase.status)) || (oldCase.status != 'Closed' && cs.status == 'Closed')){
                        caseMap.put(cs.Id,'Complete_Milestones');
                    }
                    else if(NonIgnoreStatuses.contains(cs.status) && IgnoreStatuses.contains(oldCase.status)){
                        cmListToUpsert.add(createCustomMilestone(cs.businessHoursId,integer.valueof(gSLA.Case_Update_Milestone_Time__c),cs.id,'Case Update',cs.ownerId,cs.recordtypeId));
                        //Need to reopen resolution milestone for support case
                    }
                    else if(cs.Last_Public_Comment_Date_Time__c != oldCase.Last_Public_Comment_Date_Time__c && (UserInfo.getUserEmail().Contains('marketo.com') || UserInfo.getUserEmail().Contains('grazitti.com')) && UserInfo.getUserId() != Label.JiveSyncSafeUserId && UserInfo.getUserId() != Label.System_Admin_Id && !IgnoreStatuses.Contains(cs.status)){
                         if((cs.recordtypeId != Label.tier3FullRecordTypeId) || (cs.recordtypeId == Label.tier3FullRecordTypeId && cs.OwnerId == cs.lastmodifiedbyId)){
                             caseMap.put(cs.Id,'Complete_Milestones');
                             cmListToUpsert.add(createCustomMilestone(cs.businessHoursId,integer.valueof(gSLA.Case_Update_Milestone_Time__c),cs.id,'Case Update',cs.ownerId,cs.recordtypeId));
                          }
                    }
                    else if(cs.OwnerId != oldCase.OwnerId){
                        caseMap.put(cs.Id,'Update_Milestones');
                    }
                    else if(cs.priority != oldCase.priority){
                         if(cs.RecordTypeId != Label.SupportCaseRecordTypeId){
                             caseMap.put(cs.Id,'Update_Milestones');
                         }
                         else if(cs.RecordTypeId == Label.SupportCaseRecordTypeId){
                                if(cs.Priority > oldCase.priority){
                                    caseMap.put(cs.Id,'Complete_Milestones');
                                    isPriorityDowngrade = true;
                                }
                                if(cs.Priority < oldCase.priority)caseMap.put(cs.Id,'Update_Milestones');
                         }
                    }
                }               
            }
         }
         if(!caseMap.IsEmpty()){
            for(Case_Update_Milestones__c cm : [SELECT Id,case__c, Start_Date__c, Case__r.RecordTypeId,case__r.businessHoursId,Duration__c ,ownerId,case__r.ownerId,case__r.status,Completion_Date__c, Milestone_Type__c,Violation__c, Completed__c, Target_Date__c from Case_Update_Milestones__c where Case__c IN: caseMap.keySet() AND Completion_Date__c = null]){
                if(caseMap.get(cm.case__c) == 'Complete_Milestones'){
                    if((cm.Milestone_Type__c == 'Resolution Response' &&  cm.case__r.status == 'Closed') || (cm.Milestone_Type__c != 'Resolution Response' && !isPriorityDowngrade)  || (isPriorityDowngrade && cm.Milestone_Type__c == 'Resolution Response')){
                        cm.Completion_Date__c = System.now();
                        cm.Completed__c = TRUE;
                        if(string.valueOf(cm.case__r.ownerId).startsWith('00G'))cm.ownerId =  Label.System_Admin_Id;
                        else cm.ownerId = cm.case__r.ownerId; 
                        cm.Violation__c = System.now() > cm.Target_Date__c ? TRUE:FALSE ;
                        cmListToUpsert.add(cm);
                    }
                }
                if(caseMap.get(cm.case__c) == 'Update_Milestones' || Test.isRunningTest()){
                     long slaTime = Integer.valueOf(gSLA.First_Response_Time__c);
                    if(cm.Milestone_Type__c == 'First Response'){
                        cm.Target_Date__c = BusinessHours.addGmt(cm.case__r.businessHoursId, cm.Start_Date__c, slaTime*60000);
                        cm.Duration__c = String.valueOf(gSLA.First_Response_Time__c);
                        if(string.valueOf(cm.case__r.ownerId).startsWith('00G'))cm.ownerId =  Label.System_Admin_Id;
                        else cm.ownerId = cm.case__r.ownerId; 
                    }
                    if(cm.Milestone_Type__c == 'Case Update'){
                        long slaTime2 = Integer.valueOf(gSLA.Case_Update_Milestone_Time__c);
                        cm.Target_Date__c = BusinessHours.addGmt(cm.case__r.businessHoursId, cm.Start_Date__c, slaTime2*60000);
                        cm.Duration__c = String.valueOf(gSLA.Case_Update_Milestone_Time__c);
                        if(string.valueOf(cm.case__r.ownerId).startsWith('00G')) cm.ownerId =  Label.System_Admin_Id;
                        else cm.ownerId = cm.case__r.ownerId;
                    }
                    if(cm.Milestone_Type__c == 'Resolution Response'){
                        long slaTime3 = Integer.valueOf(gSLA.Resolution_Time__c);
                        cm.Target_Date__c = BusinessHours.addGmt(cm.case__r.businessHoursId, cm.Start_Date__c, slaTime3*60000);
                        cm.Duration__c = String.valueOf(gSLA.Resolution_Time__c);
                        if(string.valueOf(cm.case__r.ownerId).startsWith('00G')) cm.ownerId =  Label.System_Admin_Id;
                        else cm.ownerId = cm.case__r.ownerId;
                    }
                    cmListToUpsert.add(cm);
                }
             }
         }
         return cmListToUpsert;
    }
    /**********************************************************************************************
        Below method is written to create case milestones.
    ***********************************************************************************************  */
    public static Case_Update_Milestones__c createCustomMilestone(Id businessHoursId,integer slaTime, id caseid, string type, string ownerId, Id recordTypeId){
        Case_Update_Milestones__c cm = new Case_Update_Milestones__c();
        cm.case__c = caseid;
        if(string.valueOf(OwnerId).startsWith('00G') || string.valueOf(OwnerId) == label.JiveSyncSafeUserId) cm.ownerId =  Label.System_Admin_Id;
        else cm.ownerId = ownerId;
        cm.Start_Date__c = system.now();
        cm.Duration__c = String.valueOf(slaTime);
        long slaMinutes = Integer.valueOf(slaTime);   
        cm.Target_Date__c = BusinessHours.addGmt(businessHoursId, system.now(), slaTime*60000);
        cm.Milestone_Type__c = type;
        return cm;
    }
    
    /**********************************************************************************************
        Below method is written to manage case milestones 
    ***********************************************************************************************   */
    public static Global_SLA__c findGslaRecord(case cs){
        for(Global_SLA__c gSLA : gSLAlist){
            if((gSLA.Priority__c == cs.priority && gSLA.Recordtype_Id__c == cs.RecordtypeId && (cs.RecordtypeId != Label.tier3FullRecordTypeId || (cs.RecordtypeId == Label.tier3FullRecordTypeId && cs.Support_Level__c == gSLA.Support_Level__c )))){
                return gSLA;
            }
            else if(gSLA.Priority__c == cs.priority && gSLA.Recordtype_Id__c == cs.RecordtypeId && cs.RecordtypeId == Label.tier3FullRecordTypeId && cs.EntitlementId == null){
                gSLA.Support_Level__c = 'premier';
                return gSLA;
            }
        }
        Global_SLA__c sla = new Global_SLA__c();
        return sla;
    }
    
    /**********************************************************************************************
      Below method is written to update Proactive case owner for new auth contact on Elite Entitlement
    ***********************************************************************************************   */
   public static list<Case> updateOwnerToTAMproactive(Set<Id> parentIds){
        List<Case> casesTobeUpdated = new List<Case>();  
        for(case cs : [Select id, ownerId, Last_Public_Comment_Date_Time__c, entitlement.AssignedSupportPOC__c,entitlement.AssignedSupportPOC__r.isactive from case where Last_Public_Comment_Date_Time__c = null AND id IN:parentIds and Entitlement.type='Elite' and recordtypeId =: Label.proactivecaseid]){
            if(cs.entitlement.AssignedSupportPOC__c != null && cs.entitlement.AssignedSupportPOC__r.isactive == true) casesTobeUpdated.add(new case(id = cs.Id, ownerid = cs.entitlement.AssignedSupportPOC__c));
            else if (cs.entitlement.AssignedSupportPOC__c == null || (cs.entitlement.AssignedSupportPOC__c != null && cs.entitlement.AssignedSupportPOC__r.isactive == false)) casesTobeUpdated.add(new case(id = cs.Id, ownerid = Label.Chandana_KothaID));
        }
         return casesTobeUpdated;   
      }
    
    /******************************************************************************************************
        Below method is written to create cases based on Splunk Reports
    ***********************************************************************************************   */
    @future
    public static void createProactiveCaseSplunk(Set<Id> caseIds){
    String sub = '';
    Boolean isCaseEligible = true;
    String commaSepEmails = '';
    Id adminContactId = null;
    Set<Id> cseIds = new Set<Id>();
    list<string> ccList = new list<string>();
    Map<String,case> accCaseMap = new Map<String,case>(); 
        for (Case cs : [Select id,subject from case where Id IN:caseIds]){
            if(cs.subject != null && cs.subject.contains('Splunk Alert:')){
                sub = cs.subject.substring(14,cs.subject.length());
                sub = sub.replace(' ','+');
                sub = sub.substring(0,sub.indexOf('+'));
                system.debug(sub);
                accCaseMap.put(sub,cs);
                cseIds.add(cs.Id);
            }
        }
        system.debug('#####accCaseMap' +accCaseMap);
        if(!accCaseMap.isEmpty()){
            Database.DMLOptions dmo = new Database.DMLOptions();
            List<Case>  caseList = new List<Case>();
            datetime dt = System.Now().addhours(-24);
            for(case c : [Select id,subject from case where createddate >:dt and Asset.Acct_Prefix__c IN : accCaseMap.keySet() and recordtypeId =: Label.ProActiveCaseRecTypeId and Id Not IN:cseIds and subject LIKE 'Splunk Alert:%' Limit 1]){
                if(c.Id != null) isCaseEligible = false;
            }
            system.debug('#####isCaseEligible ' +isCaseEligible );
            Set<String> entTypes = new Set<String>(Label.EliteTypeCustomers.Split(';'));    
            for(Entitlement entObj : [Select id,status,AssignedSupportPOC__c , type,Asset.Acct_Prefix__c, asset.Purpose__c, AccountId, Account.name, (select id,contact__r.id, Email__c, Customer_Admin__c from Authorized_Contacts__r) from Entitlement where type IN:entTypes and (Asset.Purpose__c = 'Production' OR Asset.Purpose__c='Rubiks Production') and status = 'Active' and Asset.Acct_Prefix__c  in:accCaseMap.keySet() Limit 1]){
                    for(Authorized_Contact__c ac : entObj.Authorized_Contacts__r){
                        if(ac.Email__c != null){
                            ccList.add(ac.Email__c);
                            commaSepEmails = String.join(ccList , '; ');
                        }
                        if(ac.Customer_Admin__c) adminContactId = ac.contact__r.id;
                    }
                    if(accCaseMap.values() != null){
                        for(Case cseObj : accCaseMap.values()){
                            if(entObj.AccountId != null) cseObj.accountId = entObj.AccountId;                        
                            if(entObj.id != null) cseObj.entitlementId = entObj.id;
                            if(entObj.AssetId != null) cseObj.AssetId = entObj.AssetId;
                            if(adminContactId != null && String.IsNotBlank(adminContactId)) cseObj.contactId = adminContactId ;
                            if(entObj.AssignedSupportPOC__c  != null) cseObj.ownerId = entObj.AssignedSupportPOC__c ;
                            else cseObj.ownerId = Label.Chandana_KothaID;
                            cseObj.problem_type__c = 'Elite Services';
                            cseObj.category__c = 'Splunk Alert';
                            cseObj.OnPortalAvailable__c = true;
                            cseObj.email_list__c = commaSepEmails;
                            if(!isCaseEligible){
                                cseObj.status = 'Closed';
                                cseObj.OnPortalAvailable__c = false;
                                cseObj.close_reason__c = 'Invalid Case';
                            }
                            dmo.assignmentRuleHeader.useDefaultRule = false;
                            cseObj.setOptions(dmo);
                            caseList.add(cseObj); 
                            system.debug('####caseList ' +caseList);
                        }
                    }                                    
                }
                if(caseList != null && caseList.isEmpty() == false) Database.update(caseList, dmo);
              }  
          }
          
        /******************************************************************************************************
        Below method is written to Run the Assignment Rule For SA and SC Record type cases.
        ***********************************************************************************************   */
        public static void assignmentRuleForScAndSaRecordType(list<case> ScAndSacases){
        list<case> updatecaseforAssignmentRule = new list<case>();
            for(case cc: ScAndSacases){
                 case c=new case(id=cc.id);
                 Database.DMLOptions dmo = new Database.DMLOptions();
                 dmo.assignmentRuleHeader.useDefaultRule = true;
                 c.setOptions(dmo); 
                 updatecaseforAssignmentRule.add(c);
                
            }
             if(!updatecaseforAssignmentRule.isempty()){
                 Database.update(updatecaseforAssignmentRule);
            }
        }
        /******************************************************************************************************
        Below method is written to update tier3 Case when parent case is closed 
        ***********************************************************************************************   */
        public static List<Case> updateTier3ForClosedParent(){
        List<Case> caseList = new List<Case>();
        List<CaseComment> cmntList = new List<CaseComment>();
        for(Case cse : [Select id,status,Close_Reason__c ,(select recordtypeId,status from cases where recordtypeId =: Label.tier3RecordTypeId) from case where id In: Trigger.New]){
            Case CaseOld = (Case)Trigger.OldMap.get(cse.Id); 
            for(Case cc : cse.cases){
                if(cse.status == 'Closed' && CaseOld.status != 'Closed' && cc.status != 'Closed'){
                    cc.status = 'Needs Reply';
                    CaseComment com = new CaseComment(IsPublished = false,ParentId = cc.Id,CommentBody = 'Parent case has been closed');
                    cmntList.add(com);
                    caseList.add(cc);  
                }
                if(cc.status == 'Closed' && cse.status == 'Closed' && CaseOld.status != 'Closed'){
                    CaseComment com1 = new CaseComment(IsPublished =false,ParentId = cc.Id,CommentBody = 'Parent case has been closed');
                    cmntList.add(com1);
                }
            }
        }
        if(cmntList != null && cmntList.Size() > 0)insert cmntList;
        return caseList;
        }
        
        /***********************************************************************************************************************************************************************
        Method is called by process builder (Tier 3- Status Change to Soft closed v6).... add a new comment and close case if tier 3 case stays in awaiting input for 10 days...
        ************************************************************************************************************************************************************************/
        @InvocableMethod(label='create Case Comment' description='Returns the list of Brass Cases corresponding to the specified Brass Cases IDs.')
        public static void createCaseComment( List<Case> caseIds){
            List<CaseComment> listToInsert = new List<CaseComment>();
            for(Case cas1:caseIds){                           
                CaseComment com = new CaseComment(IsPublished = false,ParentId = cas1.parentId,CommentBody = 'The tier 3 case has not had a response in 10 days. The case has been soft -closed, if customer is still experiencing an issues, please reopen up this case.');
                listToInsert.add(com);               
            }if(!listToInsert.isEmpty() && listToInsert.Size() > 0) Database.insert(listToInsert,false);
        }       
        
        /******************************************************************************************************
        Below method is written to populated Temporary Milestone for those entitlements where dedicated TAM is assigned 
        ***********************************************************************************************   */
           public static List<Case_Update_Milestones__c> UpdateMSFTMilestone(){
            List<Case_Update_Milestones__c> milestonesToUpsert = new List<Case_Update_Milestones__c>();
            List<Case> caseListToUpsert = new List<Case>();
            Set<Id> parentIds = new Set<Id>();
            Map<Id,String> caseMap = new Map<Id,String>();
            Set<Id> cseIds = new Set<Id>(); 
            Map<String,Integer> slaMap = new Map<String,Integer>();
            Boolean isFirstResponseUpdate = false;
            for (object cseObj : trigger.new){
                case cs = (case) cseObj;
                if(dedicatedSLARecType.contains(cs.recordTypeId) && cs.Dedicated_TAM__c){
                    cseIds.add(cs.Id);
                }
            }
            for(Global_SLA__c sla : [SELECT id,Priority__c,Temporary_Resolution__c from Global_SLA__c WHERE Dedicated_TAM__c = true]){
                slaMap.put(sla.Priority__c,Integer.valueOf(sla.Temporary_Resolution__c));
            }
            for(Case cs : [SELECT Id,ownerId,businessHoursId,recordtypeId,status,P0Priority__c,priority,entitlement.Dedicated_TAM__c from case where id IN : cseIds and Dedicated_TAM__c = true]){
                if(Trigger.isInsert){
                    if(cs.status != 'Closed' && !cs.P0Priority__c) milestonesToUpsert.add(createCustomMilestone(cs.businessHoursId,slaMap.get(cs.priority),cs.id,'Temporary Resolution',cs.ownerId,cs.recordtypeId));
                    else if(cs.status != 'Closed' && cs.P0Priority__c) milestonesToUpsert.add(createCustomMilestone(cs.businessHoursId,15,cs.id,'Temporary Resolution',cs.ownerId,cs.recordtypeId));

                }
                if(Trigger.isUpdate){
                    Case CaseOld = (Case)Trigger.OldMap.get(cs.Id);
                    if(cs.status != 'Closed' && ((CaseOld.priority != cs.priority) || (CaseOld.ownerId != cs.OwnerId) || (CaseOld.P0Priority__c == false && cs.P0Priority__c == true))){
                        if(CaseOld.P0Priority__c == false && cs.P0Priority__c == true){
                            caseMap.put(cs.Id,'Update');
                            isFirstResponseUpdate = true;
                        }else {
                            caseMap.put(cs.Id,'Update');
                            
                        }
                    }                
                    else if((cs.status == 'Temporary solution provided' && CaseOld.status != 'Temporary solution provided') || (cs.status == 'Closed' && CaseOld.status != 'Closed')) caseMap.put(cs.Id,'Complete');
                }
            }
            if(!caseMap.isEmpty()){
                for(Case_Update_Milestones__c cm : [SELECT Id,case__c,case__r.P0Priority__c,case__r.priority,Case__r.RecordTypeId,case__r.businessHoursId,Duration__c ,ownerId,case__r.ownerId,case__r.status,Completion_Date__c,Start_Date__c, Milestone_Type__c,Violation__c, Completed__c, Target_Date__c from Case_Update_Milestones__c where Case__c IN: caseMap.keySet() AND Completion_Date__c = null AND Milestone_Type__c IN ('Temporary Resolution','First Response')]){
                    if(caseMap.get(cm.case__c) == 'Complete' && cm.Milestone_Type__c == 'Temporary Resolution'){
                        system.debug('##### Level 1');
                        cm.Completion_Date__c = System.now();
                        cm.Completed__c = TRUE;
                        if(cm.case__r.status == 'Closed') cm.AutoComplete__c = true;
                        if(string.valueOf(cm.case__r.ownerId).startsWith('00G') || string.valueOf(cm.case__r.ownerId) == label.JiveSyncSafeUserId) cm.ownerId =  Label.System_Admin_Id;
                        else cm.ownerId = cm.case__r.ownerId;
                        cm.Violation__c = System.now() > cm.Target_Date__c ? TRUE:FALSE ;
                        cm.Actual_Diffrence__c = CustomMilestoneFunction.calculateBusinessHourDiff(cm.case__r.businessHoursId,cm.Completion_Date__c,cm.Target_Date__c);
                        milestonesToUpsert.add(cm);
                        
                    }else if(caseMap.get(cm.case__c) == 'Update' && cm.Milestone_Type__c == 'Temporary Resolution'){
                        system.debug('##### Level 2');
                        long slaTime = 0;
                        if(!cm.case__r.P0Priority__c)  slaTime = Integer.valueOf(slaMap.get(cm.case__r.priority));
                        else if(cm.case__r.P0Priority__c)slaTime = Integer.valueOf(slaMap.get('P1'));
                        cm.Target_Date__c = BusinessHours.addGmt(cm.case__r.businessHoursId, cm.Start_Date__c, slaTime*60000);
                        cm.Duration__c = String.valueOf(slaTime);
                        if(string.valueOf(cm.case__r.ownerId).startsWith('00G'))cm.ownerId =  Label.System_Admin_Id;
                        else cm.ownerId = cm.case__r.ownerId;
                        cm.Violation__c = System.now() > cm.Target_Date__c ? TRUE:FALSE ;
                        milestonesToUpsert.add(cm);
                    }
                    else if(isFirstResponseUpdate && cm.Milestone_Type__c == 'First Response' && cm.Completed__c == False){
                        system.debug('##### Level 3');
                        long slaTime = 0;
                        if(!cm.case__r.P0Priority__c)slaTime = Integer.valueOf(slaMap.get(cm.case__r.priority));
                        else if(cm.case__r.P0Priority__c)slaTime = Integer.valueOf(15);
                        cm.Target_Date__c = BusinessHours.addGmt(cm.case__r.businessHoursId, cm.Start_Date__c, slaTime*60000);
                        cm.Duration__c = String.valueOf(slaTime);
                        if(string.valueOf(cm.case__r.ownerId).startsWith('00G'))cm.ownerId =  Label.System_Admin_Id;
                        else cm.ownerId = cm.case__r.ownerId;
                        cm.Violation__c = System.now() > cm.Target_Date__c ? TRUE:FALSE ;
                        milestonesToUpsert.add(cm);
                    }
                }
            }
            system.debug('#####milestonesToUpsert ' +milestonesToUpsert);
            return milestonesToUpsert;
        }  

    /****************************************************************************************************
     SISR - #00915069  Below method is written to run the assignment rules for users except Support and customer advocacy
    ***************************************************************************************************/
    @future   
    public static void runCaseOwnerAssignmentRule(Map<Id,Id> ownerCaseMap){
        Map<Id,Boolean> usrMap = new Map<Id,Boolean>();
        for(User usr : [select id,UserRole.Name from user where id IN : ownerCaseMap.keySet()]){
            if(usr.UserRole != null && !String.valueOf(usr.UserRole.name).startsWith('SUP-') && !String.valueOf(usr.UserRole.name).startsWith('ADV-')) usrMap.put(usr.Id,true);
        }
        if(usrMap.isEmpty() == False){
            Database.DMLOptions dmo = new Database.DMLOptions();
            List<Case>  caseList = new List<Case>();
            for(Case cs :[Select id,recordtypeId,ownerId from case where Id IN :ownerCaseMap.values()]){
            if(usrMap.containsKey(cs.ownerId) && usrMap.get(cs.ownerId) == true  && cs.recordtypeId == Label.SupportCaseRecordTypeId){
                dmo.assignmentRuleHeader.useDefaultRule = true;
                cs.setOptions(dmo);
                caseList.add(cs); 
            }  
        }
        if(caseList != null && caseList.isEmpty() == false) Database.update(caseList, dmo);
        }
    } 
    
    /**********************************************************************************************
        00727265# After Hours Support checkbox in case
        DESC: This helps TSE to route there cases to Premier+ Queue when they are not available 
        and customer responded back on the case.
    ************************************************************************************************/
    Public static void AfterHoursRedistribution() {
        for(object tem : trigger.new){
            case temp = (case) tem;
            Case CaseOld = (Case)Trigger.OldMap.get(temp.Id);
             if(temp.RecordtypeId == label.supportcaserecordtypeid && temp.After_Hours__c==true && label.LevelToSupportAfterHourDestribution.contains(temp.Support_Level__c) && CaseOld.status!='Needs Reply' && temp.status=='Needs Reply'){          
                string OwID = temp.ownerId;
                if(OwID.startsWith('005')){                
                    set<id> idsSet = new set<id>();
                    Map<Id,Map<Id,Boolean>> teamMap = n2de.DistributionEngineGlobal.getUserAvailabilityAllTeams();
                    list <id> tl=new list<id>();
                    tl = (list <id>)label.TeamIds.split(',');
                    Set<Id> teamIds = new Set<Id>();
                    teamIds.addAll(tl);
                    for(Id t : teamIds){
                        Map<Id,Boolean> test = teamMap.get(t);
                        if(test.containskey(temp.Ownerid) && test.get(temp.Ownerid) == True){
                        }else{
                             temp.ownerId =label.premierPlusQueueId;
                             temp.After_Hours__c=false;
                        }
                    }
                }
            }
        }
    }
    
    public static List<Case> updateTier3CaseNumber(Map<id,case> caseIdMap){     
        list<case> CasesToUpdate = new list<case>();            
        for(case cs : [Select Id, Tier3CaseNumber__c, (Select id, ParentId, recordtypeid, Tier3CaseNumber__c from cases WHERE Id NOT IN: trigger.new) from case where id in : caseIdMap.keyset() ]){ 
            for(Case cas : cs.cases){
                if(caseIdMap.containsKey(cas.ParentId) && caseIdMap.get(cas.ParentId)!= null){
                    if(cas.Tier3CaseNumber__c != caseIdMap.get(cas.ParentId).CAseNUmber){
                        cas.Tier3CaseNumber__c = caseIdMap.get(cas.ParentId).CaseNumber;
                        cas.Tier3Case__C =   '<a href="/'+caseIdMap.get(cas.ParentId).Id+'"> ' +caseIdMap.get(cas.ParentId).CaseNumber+'</a>';
                        CasesToUpdate.add(cas);
                    }
                }
            } 
            if(caseIdMap.containsKey(cs.id)){
                if(cs.Tier3CaseNumber__c != caseIdMap.get(cs.id).CaseNumber && caseIdMap.get(cs.id)!=null){
                    cs.Tier3CaseNumber__c = caseIdMap.get(cs.id).CaseNUmber;
                    cs.Tier3Case__C =   '<a href="/'+caseIdMap.get(cs.id).id+'"> ' +caseIdMap.get(cs.id).CaseNumber+'</a>';
                    CasesToUpdate.add(cs);
                }
            }
                  
        }            
        return CasesToUpdate;        
    }
    
    /******************************************************************************************************
        Below method is written to update Case Ghost Access for support cases 
    ***********************************************************************************************   */
    
    public static void updateCaseGhostAccess(Set<Id> contactIds){
        Map<Id,String> conMap = new Map<Id,String>();
        for(Contact con: [Select id,accountid,account.Account_Ghost_Access__c from Contact where id IN: contactIds]){
            if(con.account.Account_Ghost_Access__c!= null){
                conMap.put(con.id,con.account.Account_Ghost_Access__c);
            }else{
                conMap.put(con.id,'All Cases');
            }
        }
        system.debug('conMap===>>>>'+conMap);
        for(sObject c : trigger.new){
            case cse = (case) c; 
            //system.debug('conMap===>>>>'+conMap.get(cse.ContactId));
            if((cse.recordtypeId == Id.valueOf(Label.SupportCaseRecordTypeId) || cse.recordtypeId == '01250000000UJwzAAG' || cse.recordtypeId =='01250000000UJwyAAG' || cse.recordtypeId =='01250000000UJwzAAG' || cse.recordtypeId =='01250000000UKbbAAG') && conMap != null){
                if(conMap.ContainsKey(cse.ContactId) && conMap.get(cse.ContactId) == 'Never') cse.Case_Ghost_Access__c = 'Denied';
                if(conMap.ContainsKey(cse.ContactId) && conMap.get(cse.ContactId) == 'Approval Needed') cse.Case_Ghost_Access__c = 'Denied';
                if(conMap.ContainsKey(cse.ContactId) && conMap.get(cse.ContactId) == 'All Cases') cse.Case_Ghost_Access__c = 'Allowed';
                if(conMap.ContainsKey(cse.ContactId) && String.isBlank(conMap.get(cse.ContactId))) cse.Case_Ghost_Access__c = 'Allowed';

            }
        }
    }
    
    /************************************************************************************************************
        Below method is written to check if there is any update on SM Case assigned to different manager
        Call by Scheduler(EveryHourScheduler)
    **********************************************************************************************************/
    /************Kamal code starts here**************/
    public static void escalatedCase(){
        Map<Id,List<Case>> caseMap = new Map<Id,List<Case>>();
        List<Messaging.SingleEmailMessage> emailList = new List<Messaging.SingleEmailMessage>();
        Map<Id,Map<Id,Boolean>> teamMap = n2de.DistributionEngineGlobal.getUserAvailabilityAllTeams();
        
        for(Case cse : [SELECT Id, OwnerId, ParentId,CaseNumber,priority,Owner.Name, LastModifiedById, LastModifiedDate, Parent.OwnerId, CreatedDate FROM Case WHERE recordTypeId =: Label.SituationManagementSupportRecTypeId and createdById ='00550000004KAuFAAW' and Status != 'Closed' and ParentId != NULL]){
            string owID = cse.OwnerId;
            if(owID.startsWith('005')){
                if(caseMap.containskey(cse.Parent.Ownerid)){
                   caseMap.get(cse.Parent.OwnerId).add(cse);
                }
                else{
                    caseMap.put(cse.Parent.OwnerId,new list<case>{cse});
                }
            }
        }                     
        List<string> emailCcList = new List<string>();
        for(User usr : [Select id, ManagerId, Manager.Email from user where Id IN:caseMap.keySet()]){
            for(case cse : caseMap.get(usr.id)){
                DateTime current = System.now();
                DateTime crtdDate = cse.CreatedDate;
                decimal totalTime = decimal.valueof((current.getTime() - crtdDate.getTime())/(60*60));
                decimal timeInHours = (totalTime/1000000).setScale(0);
        
                if(cse.OwnerId != usr.ManagerId){
                    if((cse.LastModifiedDate == cse.CreatedDate && (timeInHours == 5 || timeInHours == 10 || timeInHours == 15 || timeInHours == 20)) || Test.isRunningTest()){
                        id t = label.escalCaseFromPOrtalTeam;
                        Map<Id,Boolean> test = teamMap.get(t);
                        if(test.containskey(usr.ManagerId) && test.get(usr.ManagerId) == True){
                            cse.OwnerId = usr.ManagerId;
                        }else{
                            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage(); 
                            emailCcList.add(usr.Manager.Email);
                            emailCcList.add('amanb@grazitti.com');
                            mail.setTargetObjectId(cse.OwnerId);
                            mail.setCcAddresses(emailCcList);
                            mail.setWhatId(cse.id);
                            mail.setOrgWideEmailAddressId('0D238000000TQIa');
                            mail.setSubject('Need Response On SM Case - '+cse.CaseNumber);
                            String body = 'Hi ' + cse.Owner.Name + ', <br/>';
                            body += '<p>The response has not been provided from last 5 hours. Please check the case and provide response.</p>';
                            body +='<p>Case Details -:';
                            body +='<br/>Case Number: '+cse.CaseNumber;
                            body +='<br/>Case Priority: '+cse.Priority;
                            body += '<br/>Case Link: '+ system.URL.getSalesforceBaseUrl().toExternalForm()+'/'+cse.Id;
                            body +='<p>Regards,';
                            body +='<br/>Marketo Support';
                            mail.setHtmlBody(body);
                            mail.setUseSignature(false); 
                            mail.setBccSender(false); 
                            mail.setSaveAsActivity(false);  
                            emailList.add(mail);
                        }
                    }
                }
            }
        }
        Messaging.sendEmail(emailList); 
    }
    /*******************Kamal code ends here*******************/
    
    public static casecomment ghostRequestAccess(){
        casecomment com = new casecomment();
        system.debug('ghostRequestAccess Called===============>');         
        
        case triggerNew = (case) trigger.new[0];
        case triggerOld = (Case) trigger.OldMap.get(triggerNew.Id);
        if(triggerNew.RecordtypeId == Label.SupportCaseRecordTypeId && triggerNew.Ghost_Access_Status__c != triggerOld.Ghost_Access_Status__c && (triggerNew.Ghost_Access_Status__c == 'Allowed' || triggerNew.Ghost_Access_Status__c == 'Denied' || triggerNew.Account_Ghost_Access__c == 'Never' || triggerNew.Case_Ghost_Access__c == 'Denied') ){
            com.IsPublished = true;
            com.ParentId= triggerNew.Id; 
            if(triggerNew.Contact_Preferred_Language__c != 'Japanese') {
                if(triggerNew.Ghost_Access_Status__c == 'Allowed' ) {
                    com.CommentBody = 'Access has been ALLOWED by the Authorized Contact on this case.';
                } else if(triggerNew.Ghost_Access_Status__c == 'Denied') {
                    com.CommentBody = 'Access has been DENIED by the Authorized Contact on this case. If you need access to the Marketo instance related to this Case, please click the "Request Ghost Access" Button and the Support Administrator will receive an access request notification.';
                } else if(triggerNew.Ghost_Access_Status__c =='Admin Requested' || triggerNew.Ghost_Access_Status__c =='Admin Requested Again') {
                    com.CommentBody = 'An access request notification has been sent to the Support Administrator requesting that they allow us Ghost Access Permission for this Case.';
                } else if(triggerNew.Ghost_Access_Status__c =='Contact Requested' || triggerNew.Ghost_Access_Status__c =='Contact Requested Again') {
                    com.CommentBody = 'An access request notification has been sent to the Authorized Contact on this Case requesting that they allow us Ghost Access Permission for this Case.';
                }
            } else {
                if(triggerNew.Ghost_Access_Status__c == 'Allowed' ) {
                    com.CommentBody = '本サポートケースのオーソライズドコンタクトの方によって、インスタンスへのアクセスが許可されました';
                } else if(triggerNew.Ghost_Access_Status__c == 'Denied') {
                    com.CommentBody = '本サポートケースのオーソライズドコンタクトの方によって、インスタンスへのアクセスが拒否されました。もし、本ケースの調査に際し、お客様のインスタンスへのアクセスが必要な場合は、「Ghost アクセスをリクエスト」ボタンをクリックしてください。お客様のサポートアドミンの方がアクセスリクエストの通知を受け取ります。';
                } else if(triggerNew.Ghost_Access_Status__c =='Admin Requested' || triggerNew.Ghost_Access_Status__c =='Admin Requested Again') {
                    com.CommentBody = '本ケースでのGhostアクセスの承認リクエストの通知が、お客様インスタンスのサポートアドミンの方に送信されました';
                } else if(triggerNew.Ghost_Access_Status__c =='Contact Requested' || triggerNew.Ghost_Access_Status__c =='Contact Requested Again') {
                    com.CommentBody = '本ケースへのGhostアクセスを許可してもらうための承認リクエストの通知がオーソライズドコンタクトの方に送信されました。';
                }
            }
            
        }
        return com;
    }  
    
    public static void ghostRequestAccessNotifications(){                
        case triggerNew = (case) trigger.new[0];
        case triggerOld = (Case) trigger.OldMap.get(triggerNew .Id);
        if(triggerNew.RecordtypeId == Label.SupportCaseRecordTypeId && triggerNew.Ghost_Access_Status__c != triggerOld.Ghost_Access_Status__c && (triggerNew.Ghost_Access_Status__c == 'Contact Requested' || triggerNew.Ghost_Access_Status__c == 'Admin Requested' || triggerNew.Ghost_Access_Status__c == 'Contact Requested Again' || triggerNew.Ghost_Access_Status__c == 'Admin Requested Again')){ 
            id taregtId;                       
            if(triggerNew.Account_Ghost_Access__c == 'Never' && triggerNew.Case_Ghost_Access__c == 'Denied' && (triggerNew.Ghost_Access_Status__c =='Admin Requested' || triggerNew.Ghost_Access_Status__c =='Admin Requested Again')){             
                if(triggerNew.Support_Admin_Email__c != null){                  
                    List<Case> csList = new List<Case>();
                    csList = [SELECT id, entitlement.Support_Admin_Contact__c FROM case where id =: triggerNew.id]; 
                    if(!csList.IsEmpty()) taregtId = csList[0].entitlement.Support_Admin_Contact__c;
                }
            }else if(triggerNew.ContactId != null){
                taregtId = triggerNew.ContactId;
            }
            Id owaId = SupportEmailSettings__c.getInstance('Marketo Customer Support').RecordId__c; 
            Id EmailtemplateId;
            if(triggerNew.Contact_Preferred_Language__c != 'Japanese')
                EmailtemplateId = SupportEmailSettings__c.getInstance('GhostAccessRequest').RecordId__c;
            else 
                EmailtemplateId = SupportEmailSettings__c.getInstance('GhostAccessRequestJP').RecordId__c;         
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(taregtId);
            mail.setTemplateID(EmailtemplateId);
            mail.setWhatId(triggerNew.Id);
            mail.setSaveAsActivity(false);
            mail.setOrgWideEmailAddressId(owaId);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[]{mail});
        }
    }
    /*********************************************************************************************
       Below method is written to populate Entitlement on SM-Feedback Cases
    ************************************************************************************************/
    public static void populateEntitlementForSM(Set<Id> contactIds){
        Map<Id,Id> contactEntMap = new Map<Id,Id>();
        for(Authorized_Contact__c ac: [Select id,Entitlement__c,Contact__c,Entitlement__r.Status  From Authorized_Contact__c where Contact__c In: contactIds ORDER BY Entitlement__r.Status Limit 1]){
                contactEntMap.put(ac.Contact__c,ac.Entitlement__c);
        }
        if(!contactEntMap.isEmpty()){
            for(object tem : trigger.new){
                case cse = (case) tem;
                if(contactEntMap.ContainsKey(cse.Situation_Contact__c)) cse.entitlementId = contactEntMap.get(cse.Situation_Contact__c);
            }
        }
    }
    
    /***********************************************************************************************************
       Below method is written to populate Escalation Owner of SM-Support Cases i.e parent support case owner
    ************************************************************************************************************/
    public static void updateEscalationOwner(set<Id> escalateCaseIds){
        Map<Id,Id> parentcaseOwnerMap = new Map<Id,Id>();
        for(Case cse: [SELECT Id, OwnerId FROM Case WHERE Id IN: escalateCaseIds]){
            if(string.valueOf(cse.OwnerId).startsWith('005')) parentcaseOwnerMap.put(cse.Id, cse.OwnerId);
        }
        for(Sobject tmoObj : trigger.new){
            Case cse = (case)tmoObj;
            if(cse.ParentId != Null && cse.RecordTypeId == Label.SitManSupportRecordTypeId){
                if(Trigger.isInsert && parentcaseOwnerMap.containskey(cse.ParentId)){
                    cse.EscalationOwner__c = parentcaseOwnerMap.get(cse.ParentId);
                }else if(Trigger.isUpdate){
                    Case cseold = (case) Trigger.OldMap.get(cse.Id);
                    if(parentcaseOwnerMap.containskey(cse.ParentId)) cse.EscalationOwner__c = parentcaseOwnerMap.get(cse.ParentId);
                }
            }
        }
    }
    /***********************************************************************************************************
       Below method is written to populate CSM owner field on CER cases from parent Account.
    ************************************************************************************************************/
    public static void updateCSMOwnerForCERCases(set<Id> accIds){
        Map<Id,Id> caseAccMap = new Map<Id,Id>();
        for(Account acc: [Select id,CAM_Owner__c from Account where id IN:accIds]){
            if(acc.CAM_Owner__c != null)caseAccMap.put(acc.id,acc.CAM_Owner__c);
        }
        if(!caseAccMap.isEmpty()){
            for(Sobject tmoObj : trigger.new){
                Case cse = (case)tmoObj;
                if(caseAccMap.containsKey(cse.accountid)) cse.CSM_Owner__c = caseAccMap.get(cse.accountid);
            }
        }
    }
    /***********************************************************************************************************
       Below method is written to create CSM case for SSL Domain Delivery 
    ************************************************************************************************************/
    public static List<Case> createCSMCaseForSSLDomain(Set<Id> caseIds){
        List<Case> listToInsert = new List<Case>();
        for(Case cse : [Select id,accountId,account.name,contactId,contact.name,account.CAM_Owner__c,account.CAM_Owner__r.name from Case where Id IN: caseIds]){
            Case cs = new Case(contactId = cse.contactId,accountId = cse.accountId,parentId = cse.Id,status = 'New',priority = 'Low',subject='SSL Secured Domains Product Delivery',CSM_Request_Type__c = 'SSL Certificate Expiration',recordtypeId = Label.CSM_RecordType_Id);
            if(cs.contact.PreferredBusinessHours__c != 'Japanese')cs.description = 'Hello '+cse.account.CAM_Owner__r.name+',\n\n'+cse.account.name+'recently purchased either Secured Domains for Landing Pages and/or Secured Domains for Tracking Links. We have tried to contact '+cse.contact.name+' at '+cse.Account.name+' and have not received a reply\n\n IMMEDIATE ACTION REQUIRED:\n Please contact the appropriate person at '+cse.Account.name+' to verify the Munchkin ID for the Secured Domains product.  Then, click here: '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+cse.Id+' to add the Munchkin ID and contact information of a person we can work with to deliver the Secured Domains product as a comment on the case.\n\n Thank you,';
            else cs.description = cse.account.CAM_Owner__r.name+'さん,\n\n'+cse.account.name+'様が最近SSL Secured Domains for Landing Pages、SSL Secured Domains for Tracking Linksのどちらか、もしくは両方を購入されています。'+cse.account.name+'の'+cse.contact.name+'様にSSLの有効化についてご案内を差し上げましたが、返信がありません\n\n今すぐやっていただきたいこと: \n\n'+cse.Account.Name+'様の担当責任者の方にご連絡いただき、Munchkin IDの確認をお願いします。Munchkin IDはインスタンスにログイン後、管理セクション > 統合 > Munchkinにてご確認いただけます。確認できましたら、こちら: '+URL.getSalesforceBaseUrl().toExternalForm()+'/'+cse.Id+'をクリックして、Munchkin IDとお客様の担当責任者の連絡先をケースコメントとして追加してください。サポート担当者よりその方に連絡し、SSL有効化の手続きを進めます。\n\n どうぞよろしくお願いいたします。';
            listToInsert.add(cs);
        }
        return listToInsert;
    }
    /***********************************************************************************************************
       Below method is created to Populate Account' support Level for CER Case.
    ************************************************************************************************************/
    public static void UpdateCERAccountSupportLevel(Set<Id> AccountIds){
        Map<Id,String> caseAccountMap = new Map<Id,String>();
        Map<Id,String> caseUserMap = new Map<Id,String>();
        for(Case cse : [Select id,AccountId,Account.Support_Level1__c,Account.Support_Point_Of_Contact__r.firstname,Account.Support_Point_Of_Contact__r.lastname from Case where AccountID IN:AccountIds]){
            String username = '' +cse.Account.Support_Point_Of_Contact__r.firstname +' '+cse.Account.Support_Point_Of_Contact__r.lastname;
            if(cse.Account.Support_Level1__c != null && cse.Account.Support_Level1__c != '') caseAccountMap.put(cse.AccountId,String.ValueOf(cse.Account.Support_Level1__c));
            caseUserMap.put(cse.AccountId,username);
        }
        if(!caseAccountMap.isEmpty()){
            for(Sobject tmoObj : trigger.new){
                Case cse = (case)tmoObj;
                if(caseAccountMap.containsKey(cse.AccountId)) cse.Account_Support_Level__c = caseAccountMap.get(cse.AccountId);
                if(caseUserMap.containsKey(cse.AccountId)) cse.Support_Point_Of_Contact__c= caseUserMap.get(cse.AccountId);
            }
        }
    }   
}