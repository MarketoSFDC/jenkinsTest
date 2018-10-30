/* ***********************************************************************************************
Company Name  :Jade Global Inc.
Created Date : 10th February 2018
Description : 1. Map Milestone field with Platform Event(Integration Event) and publish the event.

Last ModifiedBy : Priyanka Shende, Jade Global inc. On 31st Jan 2018
Purpose         : Purpose - On Project -> One milestone Queue_for_PopulateProjectFromTemplate__c = true all others are false
                  This is used in Batch class - BatchPopulateProjectFromTemplate
Method          : beforeInsertHelper

Last Modified By: Jade Global Inc. On 11th April 2018
Purpose         : Used to Check the Submitted And Unapproved Timecards. If Submitted And Unapproved Timecards is true on milestone then set true on the project. 
* *********************************************************************************************** */
public class TriggerInt_Milestone_Helper {
     public static String Event_Type                              = Label.Platform_Event_Type;
     public static String Payload_Format                          = Label.Platform_Event_Payload_Format;
     public static String Action                                  = Label.Platform_Event_Milestone_Action;                          
     public static String PSE_Milestone                           = 'pse__Milestone__c'; 
     public static String Update_Action                           = Label.Platform_Event_Milestone_Update_Action;
     public static String After_InsertEvent                       = 'After Insert';
     public static String After_UpdateEvent                       = 'After Update';
     public static IntacctAPIRequest__mdt milestoneMetadata = [SELECT Id, API_Request_Template__c FROM IntacctAPIRequest__mdt WHERE MasterLabel = 'Update Milestone in Intacct' LIMIT 1];  

    // Map projects field with Platform Event(Integration Event) and publish the event.
    public static void MapFieldsAndPublishIntegrationPlatformEvent(List<pse__Milestone__c> newList,map<id,pse__Milestone__c> oldMap,String TriggerEvent){
    
        List<Integration_Event__e> IntegrationEventList   = new List<Integration_Event__e>();   
        if(!newList.isEmpty()){
            //Iterate project List
            for(pse__Milestone__c PSEMile : newList){
                If(SF_Utility.isMilestoneCalloutExecuted == false && PSEMile.int_issyncing__c == True){
                    //created instance of platform event 
                    Integration_Event__e IntegrationEvent     = new Integration_Event__e();
                    IntegrationEvent.Type__c                  = Event_Type;
                    IntegrationEvent.Payload_Format__c        = Payload_Format; 
                     //system.debug('milstone========='+oldMap.get(PSEMile.Id).Integration_Status__c);
                     system.debug('milstone===Status====='+ PSEMile.Integration_Status__c);
                    
                    if(((PSEMile.int_issyncing__c == True && TriggerEvent == After_InsertEvent)  || (TriggerEvent == After_UpdateEvent && PSEMile.int_issyncing__c == True && PSEMile.int_issyncing__c != oldMap.get(PSEMile.Id).int_issyncing__c) || (PSEMile.int_Intacct_Record_No__c==null)) && ((PSEMile.Integration_Status__c=='In-Progress' && oldMap.get(PSEMile.Id).Integration_Status__c!='In-Progress' && PSEMile.int_Intacct_Record_No__c==null && PSEMile.int_IsSyncing__c==true) || (PSEMile.int_IsSyncing__c==true && PSEMile.Integration_Status__c==null && oldMap.get(PSEMile.Id).Integration_Status__c!=null && PSEMile.int_Intacct_Record_No__c==null))){                    
                        IntegrationEvent.Action__c            = Action;  
                    }else if((TriggerEvent == After_UpdateEvent && PSEMile.int_IsSyncing__c == True && PSEMile.int_IsSyncing__c == oldMap.get(PSEMile.Id).int_IsSyncing__c && PSEMile.int_Intacct_Record_No__c!=null &&  PSEMile.Integration_Status__c=='In-Progress' && oldMap.get(PSEMile.Id).Integration_Status__c!='In-Progress')||(PSEMile.int_IsSyncing__c==true && PSEMile.Integration_Status__c==null && oldMap.get(PSEMile.Id).Integration_Status__c!=null && PSEMile.int_Intacct_Record_No__c!=null)){
                            IntegrationEvent.Action__c        = Update_Action;
                    }
               
                IntegrationEvent.sObjectType__c           = PSE_Milestone; 
                IntegrationEvent.Payload__c               = JSON.serialize(PSEMile);
                
                //Add Platform Event record in List 
                IntegrationEventList.add(IntegrationEvent);     
             } 
            }//End of PSEMile for
         }//End of newList isEmpty If
          system.debug('IntegrationEventList========='+IntegrationEventList);
         if(!IntegrationEventList.isEmpty()){
              //To avoid multiple callout 
                SF_Utility.isMilestoneCalloutExecuted = true;
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
     
     public static void populateProjectFromTemplateonInsert(List<pse__Milestone__c> newList){
         for (pse__Milestone__c Milestone:newList){
              if (Milestone.Copy_from_Template__c == true)
                RS_Utilities.populateProjectFromTemplate(Milestone.Template_ID__c,Milestone.pse__Project__c,Milestone.Id,Milestone.CurrencyIsoCode);
            }  
     }//End of populateProjectFromTemplateonInsert method
     
     public static void populateProjectFromTemplateonUpdate(List<pse__Milestone__c> newList,list<pse__Milestone__c> MileStoneOld){
     
         Integer index = -1;
        Map<Integer, pse__Milestone__c> oldmap = new Map<Integer, pse__Milestone__c>();
        if (MileStoneOld.size() > 0)
        {
          for (pse__Milestone__c Milestone: MileStoneOld)
          {
            index++;
            oldmap.put(index,Milestone);
          }
        }
  
        index = -1; 
      
        for (pse__Milestone__c Milestone: newList)
        {
          index++;
          pse__Milestone__c oldMilestone = oldmap.get(index);
          if (Milestone.Copy_from_Template__c == true && oldMilestone.Copy_from_Template__c != true)
            RS_Utilities.populateProjectFromTemplate(Milestone.Template_ID__c,Milestone.pse__Project__c,Milestone.Id,Milestone.CurrencyIsoCode);
        }
     
     }//End of populateProjectFromTemplateonUpdate method.
     
      //Used to avoid multiple callout,Getting call on before upudate of Milstonetrigger 
     public static void populateFieldOnMilstone(List<pse__Milestone__c> newList,Map<Id,pse__Milestone__c> oldMap){
         
         for(pse__Milestone__c MilestoneObj : newList){
             system.debug('SF_Utility.isCalloutExecuted == ======'+SF_Utility.isCalloutExecuted);
             if(MilestoneObj.Integration_Status__c==null && MilestoneObj.int_Intacct_Record_No__c==null && MilestoneObj.int_IsSyncing__c==true ){
                 MilestoneObj.Integration_Status__c= 'In-Progress';
             }
             else if(SF_Utility.isMilestoneCalloutExecuted == false && MilestoneObj.Integration_Status__c!=null && MilestoneObj.int_Intacct_Record_No__c!=null && MilestoneObj.int_IsSyncing__c==true){
                   if(isSpecifiedFieldUpdated(MilestoneObj , oldMap, milestoneMetadata.API_Request_Template__c)){
                        MilestoneObj.Integration_Status__c= 'In-Progress';
                    }
             }
             
        }//End of FOR loop
     }//End of method populateFieldOnProject
     
     

     public static Boolean isSpecifiedFieldUpdated(pse__Milestone__c newRecord, Map<Id,pse__Milestone__c> oldMap, String XMLBody){
            Set<String> apiNameSet = new Set<String>();
        String[] XMLBodyWithoutTags = XMLBody.stripHTMLTags().split('\\[\\[');
        
        System.debug('XMLBodyWithoutTags >>>' + XMLBodyWithoutTags);
        
        for(String fieldName : XMLBodyWithoutTags){
            String fName = fieldName.substringBefore(']]');
            if(!fName.isWhitespace()){
                apiNameSet.add(fName);
                System.debug('Field Name ==  >>>' + fName);
            }
            
        }

        for(String fieldName : apiNameSet){
            System.debug('>>> Field Name = '+ fieldName);
            if(newRecord.get(fieldName) != oldMap.get(newRecord.Id).get(fieldName)){
                return true;
            }
        }

        return false;

     }//End of method isSpecifiedFieldUpdated
 
  //Used to Check the Submitted And Unapproved Timecards. If Submitted And Unapproved Timecards is true on milestone then set true on the project.
        public static void SubmittedAndUnapprovedTimecardsFieldUpdate(List<pse__Milestone__c> newList){
            set<Id> setofProjectID = new set<Id>();
            List<pse__Proj__c> projWithItsMilestone = new List<pse__Proj__c>();
            List<pse__Proj__c> UpdateProjList =  new list<pse__Proj__c>();
            
            for(pse__Milestone__c MileObj : newList){
                if(!newList.isEmpty()){
                    setofProjectID.add(MileObj.pse__Project__c);
                }
            }
            
            projWithItsMilestone = [SELECT id,Submitted_and_Unapproved_Timecards__c, (SELECT id,Submitted_and_Unapproved_Timecards__c ,pse__Project__c FROM pse__Milestones__r WHERE Submitted_and_Unapproved_Timecards__c = TRUE LIMIT 1) FROM pse__Proj__c WHERE id IN : setofProjectID];
                system.debug('Project with milestone>>>>>'+projWithItsMilestone);
                
                for(pse__Proj__c ProObj: projWithItsMilestone){
                    if(!projWithItsMilestone.isEmpty() && ProObj.Submitted_and_Unapproved_Timecards__c != TRUE ){
                        ProObj.Submitted_and_Unapproved_Timecards__c = TRUE  ;
                    }
                      
                    else if ( ProObj.pse__Milestones__r.isEmpty() && ProObj.Submitted_and_Unapproved_Timecards__c == TRUE ){
                        ProObj.Submitted_and_Unapproved_Timecards__c = FALSE ;
                         
                    }
                    system.debug('Project submitted and unapproved>>>>>'+ProObj.Submitted_and_Unapproved_Timecards__c);
                    UpdateProjList.add(ProObj);
                    
                }
            
            UPDATE UpdateProjList;
            
            

        }//end of SubmittedAndUnapprovedTimecardsFieldUpdate()
        
}