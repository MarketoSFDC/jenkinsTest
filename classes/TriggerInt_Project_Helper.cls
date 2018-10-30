/* ***********************************************************************************************
Company Name  :Jade Global Inc.
Created Date  :10th February 2018
Description : 1. Map projects field with Platform Event(Integration Event) and publish the event.

Last Modified by : Priyanka Shende. Jade Global Inc.
Modified Date    : on 12th Feb 2018
Purpose          : Not able to replicate timecards approved exception 
                  - Commented opportunity updation logic populatePSAFieldsOnOppty()
                  
Last Modified By : Jade Global Inc. On 12th April 2018
Purpose          : Populate Project_End_Date__c on Opportunity 
* *********************************************************************************************** */

public class TriggerInt_Project_Helper{
    
    /* ----------------------------------------------------------------------------------------------
#BELOW ARE THE VARIABLE THAT ARE USED TO AVOID THE HARDCODED VALUES IN THE CODE 
----------------------------------------------------------------------------------------------- */
    public static boolean isProjectOpptyfieldsUpdated = false;
    public static String Event_Type                              = Label.Platform_Event_Type;
    public static String Payload_Format                          = Label.Platform_Event_Payload_Format;
    public static String Action                                  = Label.Platform_Event_Action;                          
    public static String PSE_Project                             = 'pse__Proj__c'; 
    public static String Update_Action                           = Label.Platform_Event_Update_Action;
    public static String After_InsertEvent                       = 'After Insert';
    public static String After_UpdateEvent                       = 'After Update';
    public static Map<Id,pse__Proj__c> oldProjectMap             = new Map<Id,pse__Proj__c>();
    public static Map<Id,Set<Id>> ShareIdsMap                    = new Map<Id,Set<Id>>();
    public static Map<Id,Set<Id>> DeleteIdsMap                   = new Map<Id,Set<Id>>();
    public   static  IntacctAPIRequest__mdt projectMetadata = [SELECT Id, API_Request_Template__c FROM IntacctAPIRequest__mdt WHERE MasterLabel = 'Update Project in Intacct' LIMIT 1];

    // Map projects field with Platform Event(Integration Event) and publish the event.
    public static void MapFieldsAndPublishIntegrationPlatformEvent(List<pse__Proj__c> newList,Map<Id,pse__Proj__c> oldMap,String TriggerEvent){
        
        
        List<Integration_Event__e> IntegrationEventList   = new List<Integration_Event__e>();
        if(!newList.isEmpty()){
            //Iterate project List
            for(pse__Proj__c PSEProj : newList){
                system.debug('################## PSEProj.Product_SVS_trunc__c'+PSEProj.Product_SVS_trunc__c + '####### INTEGRATION STATUS #####'+ PSEProj.Integration_Status__c);
                
                If(SF_Utility.isCalloutExecuted == false && PSEProj.int_issyncing__c == True){
                    //created instance of platform event 
                    Integration_Event__e IntegrationEvent     = new Integration_Event__e();
                    IntegrationEvent.Type__c                  = Event_Type;
                    IntegrationEvent.Payload_Format__c        = Payload_Format; 
                    if(((PSEProj.int_issyncing__c == True && TriggerEvent == After_InsertEvent)  || (TriggerEvent == After_UpdateEvent && PSEProj.int_issyncing__c == True && PSEProj.int_issyncing__c != oldMap.get(PSEProj.Id).int_issyncing__c && oldMap.get(PSEProj.Id).int_issyncing__c == false)|| (PSEProj.int_Intacct_Record_No__c==null)) && ((PSEProj.Integration_Status__c=='In-Progress' && oldMap.get(PSEProj.Id).Integration_Status__c!='In-Progress' && PSEProj.int_Intacct_Record_No__c==null && PSEProj.int_IsSyncing__c==true) || (PSEProj.int_IsSyncing__c==true && PSEProj.Integration_Status__c==null && oldMap.get(PSEProj.Id).Integration_Status__c!=null && PSEProj.int_Intacct_Record_No__c==null))){
                        IntegrationEvent.Action__c            = Action; 
                    }else if((TriggerEvent == After_UpdateEvent && PSEProj.int_issyncing__c == True && PSEProj.int_issyncing__c == oldMap.get(PSEProj.Id).int_issyncing__c && PSEProj.int_Intacct_Record_No__c!=null &&  PSEProj.Integration_Status__c=='In-Progress' && oldMap.get(PSEProj.Id).Integration_Status__c!='In-Progress' )||(PSEProj.int_IsSyncing__c==true && PSEProj.Integration_Status__c==null && oldMap.get(PSEProj.Id).Integration_Status__c!=null && PSEProj.int_Intacct_Record_No__c!=null)){
                        IntegrationEvent.Action__c            = Update_Action;
                    }
                    IntegrationEvent.sObjectType__c           = PSE_Project; 
                    IntegrationEvent.Payload__c               = JSON.serialize(PSEProj);
                    If(IntegrationEvent.Action__c != null){
                        //Add Platform Event record in List 
                        IntegrationEventList.add(IntegrationEvent); 
                    } 
                }//End of IF block of Call out already executed
            }//End of PSEProj for
        }//End of newList isEmpty If
         system.debug('IntegrationEventList=========='+IntegrationEventList);
        if(!IntegrationEventList.isEmpty()){
            
            system.debug('IntegrationEventList=========='+IntegrationEventList);
            //To avoid multiple callout 
            SF_Utility.isCalloutExecuted = true;
            // Call method to publish events.
            List<Database.SaveResult> resultsOfIntegrationEvent = EventBus.publish(IntegrationEventList);
            system.debug('############## resultsOfIntegrationEvent '+ resultsOfIntegrationEvent );
            
            if(!resultsOfIntegrationEvent .isEmpty()){
                // Inspect publishing result for each event
                for(Database.SaveResult sr : resultsOfIntegrationEvent){
                    if (sr.isSuccess()) {
                        System.debug('Successfully published event.');
                        LogPlatformEvent.createIntegrationEventLog(IntegrationEventList);
                    }//End of If 
                    else {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('Error returned: ' +err.getStatusCode() +' - ' +err.getMessage());
                        }//End of For
                    }//End of else
                }
            }//End of resultsOfIntegrationEvent isEmpty() If
        }//End of IntegrationEventList isEmpty() If
        
    }// End of MapFieldsAndPublishIntegrationPlatformEvent Method
    
    //Merged code from trigger_Project created by Joseph 
    public static void afterUpdateHelper(List<pse__Proj__c> newList, List<pse__Proj__c> oldList){
        if(SF_Utility.isCalloutExecuted == false){
            for (pse__Proj__c Proj: oldList) {
                oldProjectMap.put(Proj.id,Proj);
            }
            
            for (pse__Proj__c Proj: newList)
            {
                Set<Id> tempShareIds = new Set<Id>();
                Set<Id> tempDeleteShareIds = new Set<Id>();
                
                Id Project_Manager_IDw = Proj.Project_Manager_ID__c;
                Id Delegated_Project_Manager_IDw = Proj.Delegated_Project_Manager_ID__c;
                
                pse__Proj__c oldProj = oldProjectMap.get(Proj.Id);
                
                System.debug('### Proj.pse__Project_Manager__c ' + Proj.pse__Project_Manager__c);
                System.debug('### oldProj.pse__Project_Manager__c ' + oldProj.pse__Project_Manager__c);
                System.debug('### oldProj.Project_Manager_IDw__c ' +  oldProj.Project_Manager_IDw__c);
                System.debug('### Project_Manager_IDw ' + Project_Manager_IDw);
                System.debug('### Delegated_Project_Manager_IDw '+ Delegated_Project_Manager_IDw);
                System.debug('### Proj.Project_Manager_ID__c ' + Proj.Project_Manager_ID__c);
                System.debug('### Proj.Delegated_Project_Manager_ID__c ' + Proj.Delegated_Project_Manager_ID__c);
                
                System.Debug('CP1 ');
                System.debug(Proj.pse__Project_Manager__c != oldProj.pse__Project_Manager__c);
                if (Proj.pse__Project_Manager__c != oldProj.pse__Project_Manager__c)
                {
                    System.Debug('CP2 ');
                    System.debug(Proj.pse__Project_Manager__c != null && Project_Manager_IDw != null);
                    if (Proj.pse__Project_Manager__c != null && Project_Manager_IDw != null)
                        tempShareIds.add(Project_Manager_IDw);
                    
                    System.Debug('CP3 ');
                    System.debug(oldProj.Project_Manager_IDw__c != null && Proj.pse__Project_Manager__c == null || oldProj.Project_Manager_IDw__c != Project_Manager_IDw);
                    if (oldProj.Project_Manager_IDw__c != null && Proj.pse__Project_Manager__c == null || oldProj.Project_Manager_IDw__c != Project_Manager_IDw)
                        tempDeleteShareIds.add(oldProj.Project_Manager_IDw__c);
                }
                
                if (Proj.Delegated_Project_Manager__c !=oldProj.Delegated_Project_Manager__c)
                {
                    if (Proj.Delegated_Project_Manager__c != null && Delegated_Project_Manager_IDw != null)
                        tempShareIds.add(Delegated_Project_Manager_IDw);
                    
                    if (oldProj.Delegated_Project_Manager_IDw__c != null && Proj.Delegated_Project_Manager__c == null || oldProj.Delegated_Project_Manager_IDw__c != Delegated_Project_Manager_IDw)
                        tempDeleteShareIds.add(oldProj.Delegated_Project_Manager_IDw__c);
                }
                
                if (tempShareIds.size()>0)
                {
                    for (Id tempShareId:tempShareIds)
                    {
                        ShareIdsMap.put(Proj.Id,tempShareIds);
                    }
                }
                
                System.Debug('TDS # ' + tempDeleteShareIds.size());
                
                if (tempDeleteShareIds.size()>0)
                {
                    for (Id tempDeleteShareId:tempDeleteShareIds)
                    {
                        DeleteIdsMap.put(Proj.Id,tempDeleteShareIds);
                    }
                }
            }
            
            //Method to update the Opportunity with Project fields...
            populatePSAFieldsOnOppty(newList, oldProjectMap);
        }//end of if
        
    }//End afterUpdateHelper() Method 
    
    public static void afterInsertHelper(List<pse__Proj__c> newList){
        
        for (pse__Proj__c Proj: newList)
        {
            Set<Id> tempShareIds = new Set<Id>();
            
            if (Proj.Project_Manager_ID__c != null)
                tempShareIds.add(Proj.Project_Manager_ID__c);
            
            if (Proj.Delegated_Project_Manager__c != null)
                tempShareIds.add(Proj.Delegated_Project_Manager__c);
            
            if (tempShareIds.size()>0)
            {
                for (Id tempShareId:tempShareIds)
                {
                    ShareIdsMap.put(Proj.Id,tempShareIds);
                }
            }
        }
        
        //Method to update the Opportunity with Project fields...
        populatePSAFieldsOnOppty(newList, null);
        
    }//End of afterInsertHelper() method
    
    public static void SharingSettings(List<pse__Proj__c> newList){
        for (pse__Proj__c Proj: newList)
        {
            if (ShareIdsMap.keySet().contains(Proj.Id))
            {
                Set<Id> Ids = ShareIdsMap.get(Proj.Id);
                System.debug('Run ShareUtilities : ' + Proj.Id + ' ** ' + Ids);
                // This may need to be refactored
                if (!Test.isRunningTest()) ShareUtilities.SetAllSharingSettingsForProject(Proj.Id,Ids);
            }
            if (DeleteIdsMap.keySet().contains(Proj.Id))
            {
                Set<Id> Ids = DeleteIdsMap.get(Proj.Id);
                System.debug('Run ShareUtilities : ' + Proj.Id + ' ** ' + Ids);
                // This may need to be refactored
                if (!Test.isRunningTest()) ShareUtilities.RemoveAllSharingSettingsForProjectUser(Proj.Id,Ids);
            }
        }
    }//End of SharingSettings() Method
    
    //Method to update the Opportunity with Project fields...
    public static void populatePSAFieldsOnOppty(List<pse__Proj__c> newList, Map<Id,pse__Proj__c> oldMap){
        
         map<id,Opportunity> opptiesToUpdatemap = new map<id,Opportunity>();
         Map<id,Opportunity> MapofOpptyWithOpptyRec = new Map<id,Opportunity>();
         set<id> oppids= new set<id>();
         map<string,string> ProjToOppMapField = new map<string,string>();
          List<MapOpportunityFieldsToIntProject__mdt> MapOpportunityFieldsToIntProjectList = [SELECT MasterLabel, OpportunityFieldName__c FROM MapOpportunityFieldsToIntProject__mdt];
          
            
        try{
            for(pse__Proj__c project : newList){
                 for(MapOpportunityFieldsToIntProject__mdt projectOppFieldMap : MapOpportunityFieldsToIntProjectList){
                      if(project.pse__Opportunity__c!=null && oldMap.get(project.Id).get(projectOppFieldMap.MasterLabel) != project.get(projectOppFieldMap.MasterLabel)){
                          oppids.add(project.pse__Opportunity__c);
                      }
                  }
            }
            
            if(!oppids.isEmpty()){
				// Added field in SOQL to Populate Project_End_Date__c on Opportunity 
                MapofOpptyWithOpptyRec = new Map<id,Opportunity>([SELECT id,Backlog_Health__c,Backlog_Health_Notes_Comments__c,pse__Primary_Project__c,Non_Allocated_Hours__c,Planned_Hours__c,Project_Manager__c,Project_Health__c,Project_Health_Notes__c,Total_Assigned_Hours__c,Remaining_Hours__c,Project_End_Date__c FROM Opportunity WHERE ID IN :oppids]);
                
                for(pse__Proj__c project : newList){
                    if(project.pse__Opportunity__c != null && String.isNotBlank(project.pse__Opportunity__c) && MapofOpptyWithOpptyRec.containskey(project.pse__Opportunity__c)){
                        Opportunity opp = MapofOpptyWithOpptyRec.get(project.pse__Opportunity__c);
                       
                        for(MapOpportunityFieldsToIntProject__mdt projectOppFieldMap : MapOpportunityFieldsToIntProjectList){
                             System.debug('field==========='+projectOppFieldMap.MasterLabel);
                             System.debug('old value======='+oldMap.get(project.Id).get(projectOppFieldMap.MasterLabel));
                             System.debug('New  value ====='+project.get(projectOppFieldMap.MasterLabel));

                            if(projectOppFieldMap.MasterLabel != null && project.get(projectOppFieldMap.MasterLabel) != null){
                                if(oldMap != null && opp.get(projectOppFieldMap.OpportunityFieldName__c)!= project.get(projectOppFieldMap.MasterLabel) )
                                    opp.put(projectOppFieldMap.OpportunityFieldName__c, project.get(projectOppFieldMap.MasterLabel));
                                
                                
                            }
                        }
                        opptiesToUpdatemap.put(opp.id,opp);
                    }
                }

                if(!opptiesToUpdatemap.isEmpty()){
                   
                  
                  update opptiesToUpdatemap.values();
                }
            }//end of IF 
        }catch(Exception e){
            System.debug('Exception in Opportunity Update at Line'+ e.getLineNumber() + ' And Error Message :'+ e.getMessage());
        }
    }//End of populatePSAFieldsOnOppty() Method
    
    //Method to update the Project with Opportunity fields...
     public static void populateOpptyFieldOnProject(List<pse__Proj__c> newList){
         Set<ID> SetOfOpportunityId = new Set<ID>();
         Map<id,Opportunity> MapofOpptyWithOpptyRec = new Map<id,Opportunity>();
         list<Opportunity> listOfOppty = new list<Opportunity>();
         for(pse__Proj__c projectObj : newList){
              if(projectObj.pse__Opportunity__c != null){
                  SetOfOpportunityId.add(projectObj.pse__Opportunity__c);
              }//END OF IF
             
         }//END OF FOR
         if(!SetOfOpportunityId.isEmpty()){
         MapofOpptyWithOpptyRec = new Map<id,Opportunity>([SELECT id,Engagement_Manager__r.Name,Primary_Marketo_User_Lookup__r.Name,Engagement_Manager__r.Email FROM Opportunity WHERE ID IN :SetOfOpportunityId]);
         }
        for(Opportunity OppObj : listOfOppty){
            MapofOpptyWithOpptyRec.put(OppObj.Id,OppObj);
        }
        
        for(pse__Proj__c PObj : newList){
            if(MapofOpptyWithOpptyRec.containskey(PObj.pse__Opportunity__c)){
                Opportunity oppObj = new Opportunity();
                oppObj = MapofOpptyWithOpptyRec.get(PObj.pse__Opportunity__c);
                PObj.Opportunity_Primary_Marketo_User_Lookup__c = oppObj.Primary_Marketo_User_Lookup__r.Name;
                PObj.Opportunity_Engagement_Manager_Email__c = oppObj.Engagement_Manager__r.Email;
                PObj.Opportunity_Engagement_Manager__c = oppObj.Engagement_Manager__r.Name;
            }
        }//END OF FOR
         
         
     }//END OF populateOpptyFieldOnProject
     
      //Used to avoid multiple callout,Getting call on before upudate of project trigger 
     public static void populateFieldOnProject(List<pse__Proj__c> newList,Map<Id,pse__Proj__c> oldMap){
         
         for(pse__Proj__c projectObj : newList){
             system.debug('SF_Utility.isCalloutExecuted == ======'+SF_Utility.isCalloutExecuted);
             if(projectObj.Integration_Status__c == null && projectObj.int_Intacct_Record_No__c==null && projectObj.int_IsSyncing__c==true){
                 projectObj.Integration_Status__c= 'In-Progress';
             }
             else if(SF_Utility.isCalloutExecuted == false && projectObj.Integration_Status__c!=null && projectObj.int_Intacct_Record_No__c!=null && projectObj.int_IsSyncing__c==true){
                 if(isSpecifiedFieldUpdated(projectObj , oldMap, projectMetadata.API_Request_Template__c)){
                     projectObj.Integration_Status__c= 'In-Progress';
                 }
                 
             }
             
        }//End of FOR loop
     }//End of method populateFieldOnProject

     public static Boolean isSpecifiedFieldUpdated(pse__Proj__c newRecord, Map<Id,pse__Proj__c> oldMap, String XMLBody){

        Set<String> apiNameSet = new Set<String>();
        String[] XMLBodyWithoutTags = XMLBody.stripHTMLTags().split('\\[\\[');
        
        for(String fieldName : XMLBodyWithoutTags){
            String fName = fieldName.substringBefore(']]');
            if(!fName.isWhitespace()){
                apiNameSet.add(fName);
            }
            
        }
        System.debug('API Set >>>'+ apiNameSet);

        for(String fieldName : apiNameSet){
            if(newRecord.get(fieldName) != oldMap.get(newRecord.Id).get(fieldName)){
                return true;
            }
        }

        return false;
     }//End of Method isSpecifiedFieldUpdated
}