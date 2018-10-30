/*********************************************************************
* Last Modified by   : Grazitti 
* Modified Date      : 28-April-18
* Purpose            : #01009688 Consolidate Support Engineer Fields on Entitlement
* Line numbers       : 145,151,152

**********************************************************************/

trigger SendInitialResponseNotificationtoTSE on Case_Update_Milestones__c (after insert,before Update, after update) {
    system.debug('case1======>'+label.updateCaseP1Flag); 
    system.debug('case2======>'+UserInfo.getUserId());
    if(label.updateCaseP1Flag == 'Yes' && UserInfo.getUserId() == Label.Disable_Trigger_WF_UserId) return;
   try{
        if(label.EnableResolutionMile == 'Yes' && trigger.isAfter && trigger.IsUpdate && trigger.new.size() <= 2){
            for(Case_Update_Milestones__c  temp : trigger.new) {
                if(temp.Case__c != null && temp.Milestone_Type__c == 'Resolution Response' && temp.Completed__c){
                    case cs = new case (id = temp.Case__c, R_M_C_Date__c = system.now());
                    update cs;
                }
                if(temp.Case__c != null && temp.Milestone_Type__c == 'Resolution Response' && temp.Completed__c == false ){
                    case cs = new case (id = temp.Case__c, R_M_C_Date__c = null);
                    update cs;
                }
            }    
        }
    }catch (Exception e) {
        CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);
    }
    
    if(trigger.isAfter && trigger.isUpdate && (Test.isRunningTest() || Label.Tier3MilestoneSwitch == 'Yes')){
        Set<Id> caseId = new Set<Id>();
        for(Case_Update_Milestones__c cm: trigger.new){
            if(CM.Completed__c){
                caseId.add(cm.case__c);
            }
        }
        if(caseId.IsEmpty()==false){
            List<Case> caseList = new List<Case>();
            for(case cs : [select id, NextUpdateDueFrmCUM__c from case where Id IN :caseId and RecordtypeId =: System.Label.tier3RecordTypeId]){
                cs.NextUpdateDueFrmCUM__c = null;
                caseList.add(cs);  
            }
            try{
                if(caseList.IsEmpty()==false){
                    update caseList;
                }
            }
            catch(exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        }
    }
    Map<Id,Id> milestoneParentMap = new Map<Id,Id>();
    try{
        if(Trigger.isbefore){
            for(Case_Update_Milestones__c cm : Trigger.New){
                if(Trigger.isupdate){
                    if(cm.case__c!= null && (cm.Milestone_Type__c == 'Temporary Resolution' || cm.Milestone_Type__c == 'Resolution Response') && (Trigger.oldMap.get(cm.Id).Actual_Completion_Date__c != cm.Actual_Completion_Date__c)) milestoneParentMap.put(cm.case__c,cm.Id);
                }
            }
            if(milestoneParentMap != null && milestoneParentMap.isEmpty() == False) CustomMilestoneFunction.getBusinessHoursDiff(milestoneParentMap,trigger.New, Trigger.oldMap);
        }
    }catch(Exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}

    if(trigger.isAfter && trigger.isInsert){
        if (!CaseHandler.firstRunSendInitialResponseNotificationtoTSE) return;
        CaseHandler.firstRunSendInitialResponseNotificationtoTSE = False;
        List<Case_Update_Milestones__c > MilestoneList = new List<Case_Update_Milestones__c>();
        Set<Id> caseIDs = new Set<Id>();
        Map<Id, Case> Cases = new Map<Id, Case>();
        Map<Id, Case> CasesToUpdate = new Map<Id, Case>();// to add next update date on case
        for(Case_Update_Milestones__c  cs : trigger.new) {
            caseIDs.add(cs.case__c);             
        }   
        if(caseIDs.isEmpty() == FALSE) {
            Cases = new Map<Id, case>([select id, RecordTypeId, NextUpdateDueFrmCUM__c, priority, ownerId, BusinessHoursId from case where id in :caseIDs]);     
        } 
       
        for(Case_Update_Milestones__c  temp : trigger.new) {
            if(Cases.containsKey(temp.case__c)) {   
                Case ca = Cases.get(temp.case__c);  
                String s1 = ca.OwnerId;
                
                if(!temp.Completed__c && temp.Milestone_Type__c == 'Case Update' && (ca.RecordTypeId == Label.tier3RecordTypeId || ca.RecordTypeId == Label.SupportFeedBackRecTypeId || ca.RecordtypeId == Label.SitManSupportRecordTypeId)  && ca.NextUpdateDueFrmCUM__c != temp.Target_Date__c){
                    ca.NextUpdateDueFrmCUM__c = temp.Target_Date__c;
                    CasesToUpdate.put(temp.case__c, ca);
                }
                if(!temp.Completed__c && temp.Milestone_Type__c == 'First Response' && (ca.RecordTypeId == Label.tier3RecordTypeId || ca.RecordtypeId == Label.SitManSupportRecordTypeId || ca.RecordTypeId == Label.SupportFeedBackRecTypeId)){
                     ca.NextUpdateDueFrmCUM__c = temp.Target_Date__c;
                        CasesToUpdate.put(temp.case__c, ca);
                }
                if(ca.priority == 'P1'){
                    if(temp.Milestone_Type__c == 'First Response' && temp.Support_Level__c == 'Microsoft' && temp.Duration__c!=null && Cases.get(temp.case__c)!=null) {
                        system.debug('duration------>'+temp.Duration__c.trim());
                        integer MinforFirstReminder = Integer.valueof(temp.Duration__c.trim());
                        // Build a CRON Expression corresponding to 1 second from now 
                        Datetime dt50 = BusinessHours.addGmt(Cases.get(temp.case__c).BusinessHoursId, System.now(), MinforFirstReminder*30000);
                        Datetime dt75 = BusinessHours.addGmt(Cases.get(temp.case__c).BusinessHoursId, System.now(), MinforFirstReminder*45000);
                        String cronExpression50 = ('' + dt50.second() + ' ' + dt50.minute() + ' ' + dt50.hour() + ' ' + dt50.day() + ' ' + dt50.month() + ' ? ' + dt50.year());
                        String cronExpression75 = ('' + dt75.second() + ' ' + dt75.minute() + ' ' + dt75.hour() + ' ' + dt75.day() + ' ' + dt75.month() + ' ? ' + dt75.year());                    
                        
                        // Instantiate a new Scheduled Apex class
                        notifyTSEaboutSLASchdlr scheduledJob50 = new notifyTSEaboutSLASchdlr(temp, '50%');
                        notifyTSEaboutSLASchdlr scheduledJob75 = new notifyTSEaboutSLASchdlr(temp, '25%'); 
                        // Schedule our class to run at our given execute time, 
                        // naming executeTime so that the the Schedule name will be Unique  
                        try {
                            system.debug('dt50.getTime()===>'+dt50.getTime());
                            System.schedule('ScheduledJob50 ' + temp.id,cronExpression50,scheduledJob50);
                            System.schedule('ScheduledJob75 ' + temp.id,cronExpression75,scheduledJob75);
                        }catch(Exception e){
                            CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);
                        }
                    } 
                    
                    if(temp.Milestone_Type__c == 'First Response' && temp.Completed__c == False ){ 
                        try {
                            String str15 = temp.Target_Date__c.addMinutes(-15).format('ss mm HH dd MM ? yyyy');
                            system.debug('str15Else===>'+str15);
                            notifyTSEaboutSLASchdlr scheduledJob15 = new notifyTSEaboutSLASchdlr(temp, '15');                                  
                            System.schedule('scheduledJob15_' +temp.id, str15, scheduledJob15);
                        }catch(Exception e){
                            CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);
                        }                       
                    }
                }
            }
            
        } 
        
        if(!CasesToUpdate.isEmpty()){ 
            Database.update(CasesToUpdate.values(), false);                   
        }  
    }
    //belowcode is written for Case Notification: P1 Missed SLA
     if(trigger.isAfter && trigger.isUpdate){
       if(label.Enable_5_Proactive_Cases == 'Yes'){
       Set<Id> caseIDs = new Set<Id>();
        try{
            for(Case_Update_Milestones__c CUM : trigger.new){
                if(CUM.Violation__c == True && Trigger.OldMap.get(CUM.Id).Violation__c==false){
                    caseIDs.add(CUM.case__c);
                }           
            }   
            if(caseIDs!=null && caseIDs.IsEmpty() == false ){
                list<case> proactiveCases = new list<case>();
                for(case cas : [Select id, status,CaseNumber,category__c, AccountId, contactId, parentid, Ownerid, Entitlement.AssignedSupportPOC__c from case where Id IN: caseIDs AND recordtypeId = '01250000000UJwx' AND status!='Closed' AND EntitlementId!=null AND Entitlement.type in ('Premier', 'Premier Plus', 'Elite') and isNSECaseOwner__c=false and  Priority = 'P1'  AND Entitlement.AssignedSupportPOC__c != null]){
                        case proCase = new case();
                        proCase.AccountId = cas.AccountId;
                        proCase.contactId = cas.contactId;  
                        proCase.parentid = cas.Id;
                        proCase.recordtypeId = '01238000000E8aV';
                        if(cas.Entitlement.AssignedSupportPOC__c!=null){
                            proCase.Ownerid = cas.Entitlement.AssignedSupportPOC__c;
                        }
                        proCase.Problem_Type__c = 'Case Notification';
                        proCase.Category__c = 'P1 Missed SLA';
                        proCase.Subject = 'Missed SLA on P1 Case#'+cas.CaseNumber;
                        proCase.Description = 'Case #'+cas.CaseNumber+ ' is a P1 case that has missed its most recent SLA. Please Review and take ownership or provide an update as necessary'; 
                        proactiveCases.add(proCase);
                    }
                if(proactiveCases!=null && proactiveCases.IsEmpty()==false){
                    insert proactiveCases;
                }
            }       
        }catch(exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
       }
    }
    
    if(trigger.isBefore && trigger.isUpdate){
        TRY{
        List<Id> parentCaseIds                             = new List<Id>();
        List<Id> parentIds                                  = new List<Id>();
        List<Case_Update_Milestones__c> milestonesUpdated  = new List<Case_Update_Milestones__c>();
        Map<Id,Case> caseIdToCase                          = new Map<Id,Case>();
        List<Case_Update_Milestones__c> newMilestones      = new List<Case_Update_Milestones__c>();
        
        // DYNAMIC MILESTONE ENABLED MODULE BEGINS HERE
        If(CustomMilestone.isDynamicMilestoneEnabled() != true)
            return;
        // DYNAMIC MILESTONE ENABLED MODULE ENDS HERE
        
        // TRIGGER ALREADY EXECUTED MODULE BEGINS HERE
            if(CustomMilestone.firstRunInCaseMilestone == false ) {return;}
               CustomMilestone.firstRunInCaseMilestone = false;
        // TRIGGER ALREADY EXECUTED MODULE BEGINS HERE
       
        for(Case_Update_Milestones__c currentCaseUpdateMile : Trigger.New){
            parentCaseIds.add(CurrentCaseUpdateMile.Case__c);
            milestonesUpdated.add(currentCaseUpdateMile);
            if(trigger.OldMap.get(currentCaseUpdateMile.id).completed__c == false && trigger.NewMap.get(currentCaseUpdateMile.id).completed__c == true && currentCaseUpdateMile.Milestone_Type__c == 'First Response') parentIds.add(currentCaseUpdateMile.case__c);
        }
    
        caseIdToCase                               = CustomMilestone.getMapOfCaseIdToCase(parentCaseIds);
        Map<Id,Case> caseMapToMilestone                    = new Map<Id,Case>([Select id,ownerId,recordtypeid from case where id IN:parentIds]);
        CustomMilestone callConstrForIntialization = new CustomMilestone();
        for(Case_Update_Milestones__c mil : Trigger.new){
            if(caseMapToMilestone != null && Label.milestoneFix == 'Yes'){
                if(caseMapToMilestone.containsKey(mil.case__c) && mil.OwnerId != caseMapToMilestone.get(mil.case__c).ownerId && string.valueOf(caseMapToMilestone.get(mil.case__c).ownerId).startsWith('00G') == false && (caseMapToMilestone.get(mil.case__c).RecordtypeId == Label.supportcaseRecordtypeId || caseMapToMilestone.get(mil.case__c).RecordtypeId == Label.tier3RecordTypeId) ){
                     mil.OwnerId = caseMapToMilestone.get(mil.case__c).ownerId;
                }
            }
        }
        
        for(Case_Update_Milestones__c milestoneUnderProcessing : milestonesUpdated){
            If(milestoneUnderProcessing.Completed__c == true
                && milestoneUnderProcessing.AutoComplete__c == true 
                    && milestoneUnderProcessing.update__c == false
                        && milestoneUnderProcessing.Milestone_Type__c != 'First Response'
                            && caseIdToCase.get(milestoneUnderProcessing.Case__c).IsClosed == false){ // added by Riz
                    newMilestones.add(CustomMilestone.insertCaseUpdateMilestone(caseIdToCase.get(milestoneUnderProcessing.Case__c)));
            }        
        }
        If(!newMilestones.isEmpty())
            insert newMilestones;
        }CATCH(Exception ex){
            CaseTriggerFunction.sendEcxeptionMailToDeveloper(ex);
        }
       
    }
    
      if((trigger.isAfter && trigger.isUpdate && Label.P1EnhancementSwitch == 'Yes') || Test.isRunningTest()){
        Set<Id> caseIDs = new Set<Id>();
        List<Case> casesTobeUpdated    = new List<Case>();
        Map<Id, Id> caseToCurrentOwner = new Map<Id, Id>();
        Map<Id, Id> caseToCurrentTSE = new Map<Id, Id>();
        for(Case_Update_Milestones__c  temp : trigger.new) {
            if(temp.Case__c != null && temp.Completed__c == false && temp.Current_User_Owner__c !=null && trigger.oldmap.get(temp.id).Current_User_Owner__c != temp.Current_User_Owner__c){
                caseIDs.add(temp.case__c);
                caseToCurrentOwner.put(temp.case__c,temp.Current_User_Owner__c);                                
            }   
            if(temp.Case__c != null && temp.Completed__c && trigger.oldmap.get(temp.id).Completed__c == false && temp.Case_TSE__c !=null )  {
                caseIDs.add(temp.case__c);
                caseToCurrentTSE.put(temp.case__c,temp.Case_TSE__c);
            }          
        }
         if(caseIDs!=null && caseIDs.IsEmpty() == false ){
            for(case cas : [Select id, ownerId,recordtypeId from case where Id IN: caseIDs AND recordtypeId = '01250000000UJwx' AND status!='Closed' AND Priority = 'P1'] ){            
                if(caseToCurrentOwner.get(cas.id)!=null && cas.OwnerId != caseToCurrentOwner.get(cas.id)){
                    cas.OwnerId = caseToCurrentOwner.get(cas.id);
                }
                if(caseToCurrentTSE.get(cas.id)!=null && cas.OwnerId != caseToCurrentTSE.get(cas.id)){
                    cas.OwnerId =    caseToCurrentTSE.get(cas.id);
                }
                
                casesTobeUpdated.add(cas);      
            }                     
                          
            if(casesTobeUpdated!=null && casesTobeUpdated.IsEmpty()==false){ 
                update casesTobeUpdated ; 
            }   
         }
    }
}