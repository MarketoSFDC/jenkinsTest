/**************************************************************************************************************************************
* Apex Class: TriggerInt_Assignement_Helper
* Created by Jade Global
---------------------------------------------------------------------------------------------------------------------------------------
* Purpose/Methods:
* - Helper class for Trigger - "triggerInt_Assignment" & Apex Class - Assignment_Trigger_Handler
---------------------------------------------------------------------------------------------------------------------------------------
* History:
* - VERSION     DEVELOPER NAME          DATE                        DETAIL FEATURES
    1.0         Jade Global             10th February 2018          INITIAL DEVELOPMENT
**************************************************************************************************************************************/

public class TriggerInt_Assignement_Helper {
 public static String Event_Type                                  = Label.Platform_Event_Type;
     public static String Payload_Format                          = Label.Platform_Event_Payload_Format;
     public static String Action                                  = Label.Platform_Event_Assignment_Action;                          
     public static String PSE_Assignement                         = 'pse__Assignment__c'; 
     public static String After_InsertEvent                       = 'After Insert';
     public static String After_UpdateEvent                       = 'After Update';
     
     /* ***********************************************************************************************
        Created By  : Suraj Makandar, Jade Global Inc.
        Created On  : 6th November 2017
        Description : 1. Map Assignement field with Platform Event(Integration Event) and publish the event.
    
    * *********************************************************************************************** */
     
    // Map projects field with Platform Event(Integration Event) and publish the event.
    public static void MapFieldsAndPublishIntegrationPlatformEvent(List<pse__Assignment__c> newList,Map<Id,pse__Assignment__c > oldMap){
        system.debug('MapFieldsAndPublishIntegrationPlatformEvent Called');
        List<Integration_Event__e> IntegrationEventList   = new List<Integration_Event__e>();     
        if(!newList.isEmpty()){
            //Iterate project List
            for(pse__Assignment__c PSEAssign : newList){
              If(SF_Utility.isCalloutExecuted == false && PSEAssign.int_issyncing__c == True && (PSEAssign.Integration_Status__c=='In-Progress' &&  oldMap.get(PSEAssign.Id).Integration_Status__c!='In-Progress' &&  PSEAssign.int_Intacct_Record_No__c==null && PSEAssign.int_IsSyncing__c==true)){
                //created instance of platform event 
                Integration_Event__e IntegrationEvent     = new Integration_Event__e();
                IntegrationEvent.Type__c                  = Event_Type;
                IntegrationEvent.Payload_Format__c        = Payload_Format; 
              //  if(PSEAssign.int_IsSyncing__c == True && PSEAssign.int_IsSyncing__c != oldMap.get(PSEAssign.Id).int_IsSyncing__c){
                    IntegrationEvent.Action__c            = Action;  
              //  }
                IntegrationEvent.sObjectType__c           = PSE_Assignement; 
                IntegrationEvent.Payload__c               = JSON.serialize(PSEAssign);
                
                //Add Platform Event record in List 
                IntegrationEventList.add(IntegrationEvent);      
              }
            }//End of PSEAssign for
         }//End of newList isEmpty If
         system.debug('IntegrationEventList=='+IntegrationEventList);
         if(!IntegrationEventList.isEmpty()){
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
     
     public static void sendProjectIDToSharingSetting( List<pse__Assignment__c> listNewAssignment){ 
  
        Set<Id> ProjectIds = new Set<Id>();
        for (pse__Assignment__c TC: listNewAssignment)
        {
            ProjectIds.add(TC.pse__Project__c);
        }//end of the for

        Map<Id,pse__Proj__c> projects = new Map<Id,pse__Proj__c>([Select Id,pse__Project_Manager__r.pse__Salesforce_User__c, Delegated_Project_Manager__r.pse__Salesforce_User__c from pse__Proj__c where ID IN: ProjectIds]);
        Set<Id> Ids = new Set<Id>();
        Set<Id> LIds = new Set<Id>();

        for (pse__Proj__c project: projects.values())
        {
            if (project.pse__Project_Manager__r.pse__Salesforce_User__c != null){
                Ids.add(project.pse__Project_Manager__r.pse__Salesforce_User__c);
            }//end of the if
            if (project.Delegated_Project_Manager__r.pse__Salesforce_User__c != null){
                 Ids.add(project.Delegated_Project_Manager__r.pse__Salesforce_User__c);
            }//end of the if
            
            for (pse__Assignment__c assignment: listNewAssignment)
            {
                System.debug('Adding ID ' + assignment.ResourceSalesforceID__c);
                if (assignment.ResourceSalesforceID__c != null && assignment.pse__Project__c == project.Id) LIds.add(assignment.ResourceSalesforceID__c);
            }
            ShareUtilities.SetAllSharingSettingsForProject(project.Id,Ids);
            System.Debug('Ids : ' + LIds);
            ShareUtilities.AddLimitedSharingSettingsforResource(project.Id,LIds);
            
        }//end of the for 
        
    }//end of the method sendProjectIDToSharingSetting()
    
    //Used to avoid multiple callout,Getting call on before upudate of Assignment  trigger 
     public static void populateFieldOnAssignment(List<pse__Assignment__c > newList,Map<Id,pse__Assignment__c > oldMap){
         
         for(pse__Assignment__c AssObj : newList){
             system.debug('SF_Utility.isCalloutExecuted == ======'+SF_Utility.isCalloutExecuted);
             if(AssObj.Integration_Status__c==null && AssObj.int_Intacct_Record_No__c==null && AssObj.int_IsSyncing__c==true){
                 AssObj.Integration_Status__c= 'In-Progress';
             }
             
        }//End of FOR loop
     }//End of method populateFieldOnAssignment
    
}