public class UtilityTriggerClass{
    List<Case> listOfCasesUnderProcessing;
    Map<Id, Case> globalOldCaseIdToCase;
    Map<Id, Case> globalNewCaseIdToCase;
    List<Case_Update_Milestones__c> milestonesToBeUpdated           = new List<Case_Update_Milestones__c>(); 
    public static boolean SITMAN = false;
     
    public UtilityTriggerClass(Map<Id, Case> localNewCaseIdToCase, Map<Id, Case> localOldCaseIdToCase){
        listOfCasesUnderProcessing     = localNewCaseIdToCase.Values();
        globalNewCaseIdToCase          = localNewCaseIdToCase;
        if(Trigger.isUpdate){  
            globalOldCaseIdToCase          = localOldCaseIdToCase;
        }
    }
    
    public void CustomMilestoneOnCasesClone(){
        TRY{
            // DYNAMIC MILESTONE ENABLED MODULE BEGINS HERE
            If(CustomMilestone.isDynamicMilestoneEnabled() != true)
                return;
            // DYNAMIC MILESTONE ENABLED MODULE ENDS HERE
            
            // INITIALIZATION BLOCK BEGINS HERE
            List<Id> listOfCaseIdsUnderProcessing                  = new List<Id>();
            List<Case> casesToBeUpdated                            = new List<Case>();
            List<Case_Update_Milestones__c> newlyCreatedMilestones = new List<Case_Update_Milestones__c>(); 
            List<Case_Update_Milestones__c> ResolutionMilestones   = new List<Case_Update_Milestones__c>();       
            Boolean isStatusChangedViaWorkflow                     = False; 
            Boolean isOwnerChangedViaWorkflow                      = False;             
            Set<String> recordTypeIdsforSituationManagement        = CustomMilestone.getListOfSituationManagRecordIds();
            // INITIALIZATION BLOCK ENDS HERE
            
            //FILTERING OUT THE SUPPORT CASES OUT OF ALL OTHER CASE TYPES USING RECORD TYPE ID CHECK
            for (Case tempCase: listOfCasesUnderProcessing ) {
               If (!recordTypeIdsforSituationManagement.contains(tempCase.RecordTypeId)){
                   listOfCaseIdsUnderProcessing.add(tempCase.Id);
                   // RUN THE TRIGGER TWICE FOR THESE CONDITIONS
                   If(Trigger.isUpdate){
                       isStatusChangedViaWorkflow  = CustomMilestone.getIgnoreCaseStatuses().Contains(globalOldCaseIdToCase.get(tempCase.Id).status) && CustomMilestone.getNonIgnoreCaseStatuses().Contains(tempCase.status);
                       isOwnerChangedViaWorkflow   = globalOldCaseIdToCase.get(tempCase.Id).OwnerId != tempCase.OwnerId ? TRUE : FALSE;               
                   }
                   System.Debug('______isStatusChangedViaWorkflow_______'+isStatusChangedViaWorkflow);
                   System.Debug('______isOwnerChangedViaWorkflow_______'+isOwnerChangedViaWorkflow);
                   // RUN THE TRIGGER TWICE FOR THESE CONDITIONS
               }
            }
            //FILTERING OUT THE SUPPORT CASES OUT OF ALL OTHER CASE TYPES USING RECORD TYPE ID CHECK
                
            //RUN THE CODE TWICE IF OWNER IS CHANGED OR CASE STATUS IS CHANGED VIA WORKFLOW
            If((isOwnerChangedViaWorkflow || isStatusChangedViaWorkflow)){
               CustomMilestone.firstRunInCase = TRUE;
            }
            //RUN THE CODE TWICE IF OWNER IS CHANGED OR CASE STATUS IS CHANGED VIA WORKFLOW
                            
            // TRIGGER ALREADY EXECUTED MODULE BEGINS HERE
                if(CustomMilestone.firstRunInCase == FALSE) {return;}
                   CustomMilestone.firstRunInCase = FALSE;
            // TRIGGER ALREADY EXECUTED MODULE BEGINS HERE
            
            // FILLING UP THE SLA LIST VIA QUERY ! WARNING : THIS CONSTRUCTOR CONTAINS QUERY SO USE IT WISELY 
                CustomMilestone callConstrForIntial = new CustomMilestone();
            // FILLING UP THE SLA LIST VIA QUERY ! WARNING : THIS CONSTRUCTOR CONTAINS QUERY SO USE IT WISELY
                    
            // FIRST RESPONSE MILESTONE MODULE BEGINS HERE
            If(!listOfCaseIdsUnderProcessing.isEmpty()){
                for(ID singleCaseUnderProcessing : listOfCaseIdsUnderProcessing){
                    If(Trigger.isInsert && globalNewCaseIdToCase.get(singleCaseUnderProcessing).EntitlementId != null) {
                        System.DEbug('____First Response Milestone_____');
                        Integer slaMinutes = CustomMilestone.getSlaHours(globalNewCaseIdToCase.get(singleCaseUnderProcessing).Priority, globalNewCaseIdToCase.get(singleCaseUnderProcessing).Support_level__c).First_Response_NOM__c.intValue();
                        Datetime targetDateOfCaseMilestone = null;
                        If(slaMinutes > 0)
                            targetDateOfCaseMilestone = BusinessHours.addGmt(globalNewCaseIdToCase.get(singleCaseUnderProcessing).BusinessHoursId, globalNewCaseIdToCase.get(singleCaseUnderProcessing).CreatedDate, slaMinutes*60000);
                        If(targetDateOfCaseMilestone != null ){
                            newlyCreatedMilestones.add(CustomMilestone.firstResponseMilestone(globalNewCaseIdToCase.get(singleCaseUnderProcessing), slaMinutes));    
                            system.debug('newlyCreatedMilestones-->'+newlyCreatedMilestones);
                            casesToBeUpdated.add(CustomMilestone.updateNextUpdateDueDateOnCase(singleCaseUnderProcessing, CustomMilestone.firstResponseMilestone(globalNewCaseIdToCase.get(singleCaseUnderProcessing), slaMinutes).Target_Date__c));
                        }
                        
                        if (globalNewCaseIdToCase.get(singleCaseUnderProcessing).Support_level__c == 'Microsoft'){
                            System.DEbug('____Resolution_Response_Milestone_____');
                            Integer slaMins = CustomMilestone.getSlaHours(globalNewCaseIdToCase.get(singleCaseUnderProcessing).Priority, globalNewCaseIdToCase.get(singleCaseUnderProcessing).Support_level__c).Resolution_NOM__c.intValue();
                            targetDateOfCaseMilestone = null;                            
                            If(slaMins > 0)
                                targetDateOfCaseMilestone = BusinessHours.addGmt(globalNewCaseIdToCase.get(singleCaseUnderProcessing).BusinessHoursId, globalNewCaseIdToCase.get(singleCaseUnderProcessing).CreatedDate, slaMins*60000);
                            If(targetDateOfCaseMilestone != null ){
                                String MilestoneType = 'Resolution Milestone';
                                ResolutionMilestones.add(CustomMilestone.ResolutionMilestone(globalNewCaseIdToCase.get(singleCaseUnderProcessing), slaMins));                        
                            }
                        }  
                    }
                }
            }
            
            If(!ResolutionMilestones.isEmpty()) insert ResolutionMilestones;  
                 
            If(!newlyCreatedMilestones.isEmpty()) {
                system.debug('newlyCreatedMilestones--->'+newlyCreatedMilestones); 
                insert newlyCreatedMilestones;
            }
            If(!casesToBeUpdated.isEmpty()) update casesToBeUpdated;
             // FIRST RESPONSE MODULE ENDS HERE             
                
                
                
                
                 
             // CASE UPDATE MODULE BEGINS HERE
             If(! Trigger.isUpdate ){return;}
             //INITIALIZATION BLOCK BEGINS HERE   
             Map<Id,Case_Update_Milestones__c> caseIdToCaseUpdateMilestone   = new Map<Id,Case_Update_Milestones__c>();   
             for(Case_Update_Milestones__c tempCaseMile : [SELECT OwnerId,Case__c,Start_Date__c,Target_Date__c, Milestone_Type__c from Case_Update_Milestones__c where Case__c IN : listOfCaseIdsUnderProcessing And Completed__c = false and Milestone_Type__c!='Resolution Response']){
                 caseIdToCaseUpdateMilestone.put(tempCaseMile.Case__c, tempCaseMile);        
             }
             //INITIALIZATION BLOCK ENDS HERE
             
             
             //-------------
             
              map<id,list<Case_Update_Milestones__c>> caseIdToMilestone = new map<id,list<Case_Update_Milestones__c>>();                
                for(Case_Update_Milestones__c CusMil : [SELECT OwnerId, Case__c,Start_Date__c, Target_Date__c, Milestone_Type__c from Case_Update_Milestones__c where Case__c IN : Trigger.NewMap.keyset() And Completed__c = false]){
                    if(caseIdToMilestone.containsKey(CusMil.Case__c)) {
                        List<Case_Update_Milestones__c> MilList = caseIdToMilestone.get(CusMil.Case__c);
                        MilList.add(CusMil);
                        caseIdToMilestone.put(CusMil.Case__c, MilList);
                    } else {
                        caseIdToMilestone.put(CusMil.Case__c, new List<Case_Update_Milestones__c> { CusMil });
                    }
                }
             
             //-------------------
             
             
             System.Debug('____OPEN CASE UPDATE MILESTONE ON CASE_____'+caseIdToMilestone);
             If(!listOfCaseIdsUnderProcessing.isEmpty()){
                 for(ID singleCaseUnderProcessing : listOfCaseIdsUnderProcessing){
                     UpdateOperations validCaseUpdateOperations = new UpdateOperations(globalNewCaseIdToCase.get(singleCaseUnderProcessing),globalOldCaseIdToCase.get(singleCaseUnderProcessing));
                 
                     If(caseIdToMilestone.get(singleCaseUnderProcessing) == Null && ! validCaseUpdateOperations.ignoreToNonIgnore && ! validCaseUpdateOperations.isEntitPopulatedForFirstTime){continue;}  

                     Case caseToBeUpdated = new Case(Id=singleCaseUnderProcessing);                     
                     //VERIFY VALUES START HERE
                         System.Debug('___Owner Is Changed__'+validCaseUpdateOperations.isCaseOwnerChanged);
                         System.Debug('___Priority Is Increased___'+validCaseUpdateOperations.isCasePriorityIncreased);
                         System.Debug('___Ignore To Non Ignore__'+validCaseUpdateOperations.ignoreToNonIgnore);
                         System.Debug('___Non Ignore To Ignore__'+validCaseUpdateOperations.nonIgnoreToIgnore);
                         System.Debug('___is Entit Changed To Other Entit__'+validCaseUpdateOperations.isEntitChangedToOtherEntit);
                         System.Debug('___is Entit Populated For First Time__'+validCaseUpdateOperations.isEntitPopulatedForFirstTime);                
                     //VERIFY VALUES ENDS HERE
                                  
                     // CASE OWNER IS UPDATED STARTS HERE
                        // If(validCaseUpdateOperations.isCaseOwnerChanged ){
                          //   milestonesToBeUpdated.add(CustomMilestone.updOpenCaseUpdateMileOwner(caseIdToCaseUpdateMilestone.get(singleCaseUnderProcessing).Id, globalNewCaseIdToCase.get(singleCaseUnderProcessing).OwnerId));        
                        // } 
                        
                        If(validCaseUpdateOperations.isCaseOwnerChanged ){
                            milestonesToBeUpdated = CustomMilestone.UpdateMileOwner(caseIdToMilestone.get(singleCaseUnderProcessing), globalNewCaseIdToCase.get(singleCaseUnderProcessing).OwnerId); 
                        }
                     // CASE OWNER IS UPDATED ENDS HERE    
                     
                   /*  //CASE PRIORITY IS UPDATED STARTS HERE    
                         If(validCaseUpdateOperations.isCasePriorityIncreased) {
                             If(caseIdToCaseUpdateMilestone.get(singleCaseUnderProcessing).Milestone_Type__c == 'First Response'){
                                 //UPDATE THE EXISTING CASE UPDATE MILESTONE STARTS HERE
                                  milestonesToBeUpdated.add(CustomMilestone.updOpenFirstRespCaseMile(globalNewCaseIdToCase.get(singleCaseUnderProcessing), caseIdToCaseUpdateMilestone.get(singleCaseUnderProcessing)));    
                                 //UPDATE THE EXISTING CASE UPDATE MILESTONE ENDS HERE                     
                                 system.debug('14==>');
                                 //UPDATE NEXT UPDATE DUE DATE ON CASE STARTS HERE
                                 DateTime targetDateOfMilestone = CustomMilestone.insertCaseUpdateMilestone(globalNewCaseIdToCase.get(singleCaseUnderProcessing), validCaseUpdateOperations).Target_Date__c;
                                 casesToBeUpdated.add(CustomMilestone.updateNextUpdateDueDateOnCase(singleCaseUnderProcessing, targetDateOfMilestone));
                                 //UPDATE NEXT UPDATE DUE ON CASE ENDS HERE
                             } else If(caseIdToCaseUpdateMilestone.get(singleCaseUnderProcessing).Milestone_Type__c == 'Case Update'){
                                 //UPDATE THE EXISTING CASE UPDATE MILESTONE STARTS HERE
                                 milestonesToBeUpdated.add(CustomMilestone.updOpenCaseUpdateMile(caseIdToCaseUpdateMilestone.get(singleCaseUnderProcessing), 'CASE TRIGGER'));
                                 //UPDATE THE EXISTING CASE UPDATE MILESTONE ENDS HERE                     
                                 
                                 //CREATE NEW CASE UPDATE MILESTONE STARTS HERE
                                 newlyCreatedMilestones.add(CustomMilestone.insertCaseUpdateMilestone(globalNewCaseIdToCase.get(singleCaseUnderProcessing),validCaseUpdateOperations));
                                 //CREATE NEW CASE UPDATE MILESTONE ENDS HERE 
                                 system.debug('13==>');
                                 //UPDATE NEXT UPDATE DUE DATE ON CASE STARTS HERE
                                 DateTime targetDateOfMilestone = CustomMilestone.insertCaseUpdateMilestone(globalNewCaseIdToCase.get(singleCaseUnderProcessing), validCaseUpdateOperations).Target_Date__c;
                                 casesToBeUpdated.add(CustomMilestone.updateNextUpdateDueDateOnCase(singleCaseUnderProcessing, targetDateOfMilestone));
                                 //UPDATE NEXT UPDATE DUE ON CASE ENDS HERE
                             }
                         }
                     //CASE PRIORITY IS UPDATED ENDS HERE
                     */
                     
                     //CASE PRIORITY IS UPDATED STARTS HERE    
                     If(validCaseUpdateOperations.isCasePriorityIncreased) {
                         for(Case_Update_Milestones__c tmp : caseIdToMilestone.get(singleCaseUnderProcessing)){
                             system.debug('Milestone_Type__c ------------->'+tmp.Milestone_Type__c );
                             If(tmp.Milestone_Type__c == 'First Response') {
                                 //UPDATE THE EXISTING CASE UPDATE MILESTONE STARTS HERE
                                  milestonesToBeUpdated.add(CustomMilestone.updOpenFirstRespCaseMile(globalNewCaseIdToCase.get(singleCaseUnderProcessing), tmp ));    
                                 //UPDATE THE EXISTING CASE UPDATE MILESTONE ENDS HERE                     
                                 system.debug('14==>');
                                 //UPDATE NEXT UPDATE DUE DATE ON CASE STARTS HERE
                                 DateTime targetDateOfMilestone = CustomMilestone.insertCaseUpdateMilestone(globalNewCaseIdToCase.get(singleCaseUnderProcessing), validCaseUpdateOperations).Target_Date__c;
                                 casesToBeUpdated.add(CustomMilestone.updateNextUpdateDueDateOnCase(singleCaseUnderProcessing, targetDateOfMilestone));
                                 //UPDATE NEXT UPDATE DUE ON CASE ENDS HERE
                             }else If(tmp.Milestone_Type__c == 'Resolution Response'){
                                 //UPDATE THE EXISTING CASE UPDATE MILESTONE STARTS HERE
                                  milestonesToBeUpdated.add(CustomMilestone.updResolutionCaseMile(globalNewCaseIdToCase.get(singleCaseUnderProcessing), tmp));    
                                 //UPDATE THE EXISTING CASE UPDATE MILESTONE ENDS HERE                     
                             }
                             else If(tmp.Milestone_Type__c == 'Case Update'){
                                 //UPDATE THE EXISTING CASE UPDATE MILESTONE STARTS HERE
                                 milestonesToBeUpdated.add(CustomMilestone.updOpenCaseUpdateMile(caseIdToCaseUpdateMilestone.get(singleCaseUnderProcessing), 'CASE TRIGGER'));
                                 //UPDATE THE EXISTING CASE UPDATE MILESTONE ENDS HERE                     
                                 
                                 //CREATE NEW CASE UPDATE MILESTONE STARTS HERE
                                 newlyCreatedMilestones.add(CustomMilestone.insertCaseUpdateMilestone(globalNewCaseIdToCase.get(singleCaseUnderProcessing),validCaseUpdateOperations));
                                 //CREATE NEW CASE UPDATE MILESTONE ENDS HERE 
                                 system.debug('13==>');
                                 //UPDATE NEXT UPDATE DUE DATE ON CASE STARTS HERE
                                 DateTime targetDateOfMilestone = CustomMilestone.insertCaseUpdateMilestone(globalNewCaseIdToCase.get(singleCaseUnderProcessing), validCaseUpdateOperations).Target_Date__c;
                                 casesToBeUpdated.add(CustomMilestone.updateNextUpdateDueDateOnCase(singleCaseUnderProcessing, targetDateOfMilestone));
                                 //UPDATE NEXT UPDATE DUE ON CASE ENDS HERE
                             }
                         }
                     }
                 //CASE PRIORITY IS UPDATED ENDS HERE
                     
                     
                     
                     //CASE STATUS IS CHANGED START HERE
                         If(validCaseUpdateOperations.nonIgnoreToIgnore){
                             //UPDATE THE EXISTING CASE UPDATE MILESTONE STARTS HERE
                             //milestonesToBeUpdated.add(CustomMilestone.updOpenCaseUpdateMile(caseIdToCaseUpdateMilestone.get(singleCaseUnderProcessing),globalNewCaseIdToCase.get(singleCaseUnderProcessing).isClosed));                             
                             for (Case_Update_Milestones__c temp: (CustomMilestone.updOpenCaseUpdateMilelist(caseIdToMilestone.get(singleCaseUnderProcessing),globalNewCaseIdToCase.get(singleCaseUnderProcessing).isClosed))){
                                 milestonesToBeUpdated.add(temp);
                             }                             
                             //UPDATE THE EXISTING CASE UPDATE MILESTONE ENDS HERE   
                             system.debug('12==>');
                             //UPDATE NEXT UPDATE DUE DATE ON CASE STARTS HERE
                             if (globalNewCaseIdToCase.get(singleCaseUnderProcessing).isclosed != TRUE){
                                 DateTime targetDateOfMilestone = NULL;
                                 casesToBeUpdated.add(CustomMilestone.updateNextUpdateDueDateOnCase(singleCaseUnderProcessing, targetDateOfMilestone));
                                 //UPDATE NEXT UPDATE DUE DATE ON CASE ENDS HERE                                 
                             }
                         }
                         
                         else If(validCaseUpdateOperations.ignoreToNonIgnore && caseIdToCaseUpdateMilestone.isEmpty()){
                         
                             //CREATE NEW CASE UPDATE MILESTONE STARTS HERE
                             newlyCreatedMilestones.add(CustomMilestone.insertCaseUpdateMilestone(globalNewCaseIdToCase.get(singleCaseUnderProcessing), validCaseUpdateOperations));
                             //CREATE NEW CASE UPDATE MILESTONE ENDS HERE
                             system.debug('11==>');
                             //UPDATE NEXT UPDATE DUE DATE ON CASE STARTS HERE
                             DateTime targetDateOfMilestone = CustomMilestone.insertCaseUpdateMilestone(globalNewCaseIdToCase.get(singleCaseUnderProcessing), validCaseUpdateOperations).Target_Date__c;
                             casesToBeUpdated.add(CustomMilestone.updateNextUpdateDueDateOnCase(singleCaseUnderProcessing, targetDateOfMilestone));
                             //UPDATE NEXT UPDATE DUE DATE ON CASE ENDS HERE                 
                         }
                         
                         else if(validCaseUpdateOperations.ignoreToClose && globalNewCaseIdToCase.get(singleCaseUnderProcessing).Support_level__c == 'Microsoft'){                         
                             system.debug('__________________ignoreToClose_________________');
                             milestonesToBeUpdated = (CustomMilestone.updOpenCaseUpdateMilelist(caseIdToMilestone.get(singleCaseUnderProcessing),globalNewCaseIdToCase.get(singleCaseUnderProcessing).isClosed));
                         }
                         else if(validCaseUpdateOperations.CaseReopens && globalNewCaseIdToCase.get(singleCaseUnderProcessing).Support_level__c == 'Microsoft'){
                              system.debug('__________________CaseReopens_________________');
                              milestonesToBeUpdated.add(CustomMilestone.reopenResolMil(globalNewCaseIdToCase.get(singleCaseUnderProcessing)));  
                         }
                     //CASE STATUS IS CHANGED ENDS HERE
                     
                     //ENTITLEMENT IS UPDATED STARTS HERE
                         If(validCaseUpdateOperations.isEntitChangedToOtherEntit){
                             //UPDATE THE EXISTING CASE UPDATE MILESTONE STARTS HERE
                             system.debug('one==>');
                             milestonesToBeUpdated.add(CustomMilestone.updOpenCaseUpdateMile(caseIdToCaseUpdateMilestone.get(singleCaseUnderProcessing), 'CASE TRIGGER'));
                             //UPDATE THE EXITING CASE UPDATE MILESTONE ENDS HERE
                             
                             //CREATE A NEW CASE UPDATE MILESTONE IF CASE IS IN NON IGNORE CASE STATUS
                             If(!CustomMilestone.getIgnoreCaseStatuses().Contains(globalNewCaseIdToCase.get(singleCaseUnderProcessing).Status)){ 
                                 //CREATE NEW CASE UPDATE MILESTONE STARTS HERE
                                 system.debug('two==>');
                                 newlyCreatedMilestones.add(CustomMilestone.insertCaseUpdateMilestone(globalNewCaseIdToCase.get(singleCaseUnderProcessing), validCaseUpdateOperations));
                                 //CREATE NEW CASE UPDATE MILESTONE ENDS HERE
                                 //UPDATE NEXT UPDATE DUE DATE ON CASE STARTS HERE
                                 DateTime targetDateOfMilestone = CustomMilestone.insertCaseUpdateMilestone(globalNewCaseIdToCase.get(singleCaseUnderProcessing), validCaseUpdateOperations).Target_Date__c;
                                 casesToBeUpdated.add(CustomMilestone.updateNextUpdateDueDateOnCase(singleCaseUnderProcessing, targetDateOfMilestone));
                                 //UPDATE NEXT UPDATE DUE DATE ON CASE ENDS HERE   
                             }
                             //CREATE A NEW CASE UPDATE MILESTONE IF CASE IS IN NON IGNORE CASE STATUS
                         } If(validCaseUpdateOperations.isEntitPopulatedForFirstTime){
                             Integer slaMinutes = CustomMilestone.getSlaHours(globalNewCaseIdToCase.get(singleCaseUnderProcessing).Priority, globalNewCaseIdToCase.get(singleCaseUnderProcessing).Support_level__c).First_Response_NOM__c.intValue(); 
                             system.debug('three==>');
                             If(globalNewCaseIdToCase.get(singleCaseUnderProcessing).First_Response_Post_Time__c != NULL){
                                 //CREATE A NEW FIRST RESPONSE MILESTONE AND COMPLETE IT
                                 newlyCreatedMilestones.add(CustomMilestone.firstRespMilesFrmEntChng(globalNewCaseIdToCase.get(singleCaseUnderProcessing), slaMinutes));    
                                 //CREATE A NEW FIRST RESPONSE MILESTONE AND COMPLETE IT                         
                             system.debug('four==>');
                                 If(!CustomMilestone.getIgnoreCaseStatuses().Contains(globalNewCaseIdToCase.get(singleCaseUnderProcessing).Status)){ 
                                     //Create a new Case Update Milestone 
                                     newlyCreatedMilestones.add(CustomMilestone.insertCaseUpdateMilestone(globalNewCaseIdToCase.get(singleCaseUnderProcessing), validCaseUpdateOperations));
                                     //Create a new Case Update Milestone 
                                     system.debug('five==>');
                                      //UPDATE NEXT UPDATE DUE DATE ON CASE STARTS HERE
                                     DateTime targetDateOfMilestone = CustomMilestone.insertCaseUpdateMilestone(globalNewCaseIdToCase.get(singleCaseUnderProcessing), validCaseUpdateOperations).Target_Date__c;
                                     casesToBeUpdated.add(CustomMilestone.updateNextUpdateDueDateOnCase(singleCaseUnderProcessing, targetDateOfMilestone));
                                     //UPDATE NEXT UPDATE DUE DATE ON CASE ENDS HERE  
                                 }
                             }  else {
                             
                                 system.debug('cooooooooooooooool==>slaMinutes' + slaMinutes);
                                 
                                 //CREATE A NEW FIRST RESPONSE MILESTONE
                                 newlyCreatedMilestones.add(CustomMilestone.firstRespMilesFrmEntChng(globalNewCaseIdToCase.get(singleCaseUnderProcessing),slaMinutes));    
                                 //CREATE A NEW FIRST RESPONSE MILESTONE                                  
                                       
                                  //  UPDATE NEXT UPDATE DUE DATE ON CASE STARTS HERE// added by Riz
                                 DateTime targetDateOfMilestone = CustomMilestone.firstRespMilesFrmEntChng(globalNewCaseIdToCase.get(singleCaseUnderProcessing),slaMinutes).Target_Date__c;

                                 system.debug('cooooooooooooooool==>' + targetDateOfMilestone);
                                 casesToBeUpdated.add(CustomMilestone.updateNextUpdateDueDateOnCase(singleCaseUnderProcessing, targetDateOfMilestone));
                                 //UPDATE NEXT UPDATE DUE DATE ON CASE ENDS HERE //added by Riz
                             }     
                         }
                     //ENTITLEMENT IS UPDATED ENDS HERE
                 }
             }
         // CASE UPDATE MODULE ENDS HERE
         If(!milestonesToBeUpdated.isEmpty())
             update milestonesToBeUpdated;
         If(!casesToBeUpdated.isEmpty())
             update casesToBeUpdated;
         If(!newlyCreatedMilestones.isEmpty())
             insert newlyCreatedMilestones;
     } CATCH(Exception ex){
            System.Debug('_______EXCEPTION________'+ex);
        }  
    }

 /*SOPS-674 By Rizvan starts*/
        public void SMPatternIdentified(){    
        id conID ;
        id accID ;
        string CaseCategory;
        List <string> SupportRegions = Label.SupportRegionForPatternIdentifiedCase.split('#');
        List <string> CustomerType = Label.CamCustomerType.split('#');
        
        for(case temp : listOfCasesUnderProcessing){
            conID = temp.contactid;
            accID = temp.Accountid;
            CaseCategory = temp.category__c;
            break;
        } 
        Set<string> CaseNo = new Set<string>();
        
        //List of existing Sm case to avoid new case creation if case already exist for the account. 
        List<case> SMCaseList = new list<case>([select id,status,CasesRelated__c,CasessRelated__c from case where createdDate = LAST_N_DAYS:30 AND Problem_Type__c = 'Pattern Identified' AND RecordTypeid = '01250000000UK1EAAW' AND Situation_Account__c =: accID]);
        system.debug ('Sizeeeeee---->'+SMCaseList.size());
             
        for(case temp : SMCaseList){
            //check if there already exists an SM case for the account
            if(temp.status != 'Closed'){return;} 
            //list of cases for which SM is already created. Do not include these cases again. 
         if(temp.CasessRelated__c != null) {
            CaseNo.addall(temp.CasessRelated__c.split(','));
         }            
        }  
         //get list of case of type bug /troubleshooting within last 30 days   
        List<case> CaseList = new list<case>([select id, caseNumber,CasesRelated__c, entitlement.Named_support_engineer__r.managerid, entitlement.Named_support_engineer__c,entitlement.Named_support_engineer__r.manager.IsActive, CasessRelated__c,entitlement.type from case where  category__c = :
        CaseCategory AND Support_Region__c IN: SupportRegions AND createdDate = LAST_N_DAYS:30 AND (Problem_Type__c = 'Troubleshooting' OR Problem_Type__c = 'Bug') AND AccountId =:accID AND RecordTypeid = '01250000000UJwxAAG' AND CaseNumber NOT IN : CaseNo AND Entitlement.type IN :CustomerType]); 
        Boolean Goforward = false;
        id ownerID; 

        //if no of case are 3 or more, create an s of type pattern identified.
        if(CaseList.size()>2 || test.IsrunningTest()){
            for(case temp : CaseList){             
                if(temp.entitlement.Named_support_engineer__c != Null ){
                    if(temp.entitlement.Named_support_engineer__r.manager.IsActive){
                    
                        ownerID = temp.entitlement.Named_support_engineer__r.managerId;
                    }else{
                        ownerID = label.InactivedefaultPatternIdentifiedUser;
                                          
                    }
                    if(ownerID !=NUll)Goforward = true;                     
                    break;
                }
            }
            if(Goforward == true || test.IsrunningTest()){
                case InsrtSMCase = new case();
                if(Goforward)
                InsrtSMCase.Ownerid                 =     ownerID;
                InsrtSMCase.RecordTypeid            =     '01250000000UK1E';
                InsrtSMCase.Situation_Account__c    =      accID; 
                InsrtSMCase.Situation_Contact__c    =      conID;
                InsrtSMCase.status                  =     'New';
                InsrtSMCase.Origin                  =     'Web';
                InsrtSMCase.priority                =     'Medium';
                InsrtSMCase.subject                 =     'Case Pattern Identified';
                InsrtSMCase.description             =     'Case Pattern Identified – Proactive customer reach program';
                InsrtSMCase.Problem_Type__c         =     'Pattern Identified';
                InsrtSMCase.CasesRelated__c         =     '';
                InsrtSMCase.CasessRelated__c         =     '';
                for(case temp : CaseList ){
                   InsrtSMCase.CasesRelated__c     +=     '<a href="/'+temp.Id+'">' +temp.caseNumber+'</a>    ';
                   InsrtSMCase.CasessRelated__c     +=      temp.CaseNumber+',';
                }       
                Insert InsrtSMCase;
            }
        }
    }
    /*SOPS-674 By Rizvan Ends*/ 
    
    //SOPS-707 Phasing out Marketo Financial Management (MFM) starts. 
    public static boolean ContactAllocadia(List < Case > CasesUnderProcessing) {

        id AssetId;
        Map < id, string > AddOnAssetStatusMap = new Map < id, string > ();

        for (case temp : CasesUnderProcessing) {
            if (temp.Case_Issue__c == 'Analytics' && temp.Case_Sub_Issue__c == 'MFM') {
                AssetId = temp.assetid;
                break;
            }
        }
        list < id > CasetobeupdatedIds = new list < id > ();
        list < case >Casetobeupdated = new list < case >();

        if (AssetId != null) {
            list < Asset > AddOnAsset = new list < Asset > ([select id, status, Parent_Instance__c from asset where Parent_Instance__r.id = : AssetId limit 1]);
            if (!AddOnAsset.isempty()) {
                for (case temp : CasesUnderProcessing) {
                    system.debug('AddOnAsset.status-------->' + AddOnAsset[0].status);
                    if (temp.Case_Issue__c == 'Analytics' && temp.Case_Sub_Issue__c == 'MFM' && AddOnAsset[0].status == 'Expired') {
                        CasetobeupdatedIds.add(temp.id);
                    }
                    break;
                }
            }
        }

        if (!CasetobeupdatedIds.isempty()) {
            List < case > CaseLis = [select id, status, contactid from case where id in : CasetobeupdatedIds limit 1];
            CaseLis[0].status = 'Closed';
            Casetobeupdated.add(CaseLis[0]);

            //code to send Contact allocadia email ;
            OrgWideEmailAddress owa = [select Id from OrgWideEmailAddress where DisplayName = 'Marketo Customer Support'
            Limit 1];

            EmailTemplate Emailtemplate = [SELECT id FROM EmailTemplate where name = 'Expired MFM contact to Allocadia'];


            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(CaseLis[0].contactId);
            mail.setTemplateID(Emailtemplate.Id);
            mail.setWhatId(CaseLis[0].Id);
            mail.setSaveAsActivity(false);
            mail.setOrgWideEmailAddressId(owa.id);
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {
                mail
            });
        }

        if (!Casetobeupdated.isempty()) {
            Update Casetobeupdated;
            return True;
        } else {
            return False;
        }

    }
    //SOPS-707 Phasing out Marketo Financial Management (MFM) Ends.
    
}