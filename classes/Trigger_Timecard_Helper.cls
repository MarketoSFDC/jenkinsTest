/**************************************************************************************************************************************
* Apex Class: Trigger_Timecard_Helper
* Created by Jade Global
---------------------------------------------------------------------------------------------------------------------------------------
* Purpose/Methods:
* - Helper class for Trigger - "trigger_Timecard" & Apex Class - Trigger_Timecard_Handler
---------------------------------------------------------------------------------------------------------------------------------------
* History:
* - VERSION     DEVELOPER NAME          DATE                        DETAIL FEATURES
    1.0         Jade Global             10th February 2018          INITIAL DEVELOPMENT
    
* Last Modified By: Priyanka Shende, Jade Global INC. on 3rd May 2018
* Purpose         : Handled Below Scenario: APPS-19036
		    Timecard splits getting created twice and giving 2 responses for one request
			
* Last Modified By: Jade Team on 23rd May 2018, APPS-20255
* Purpose         : JIRA APPS-20255 Milestone and Project Validation Error
                    To Check the Timecard is Present on Milestone or not.
**************************************************************************************************************************************/

public class Trigger_Timecard_Helper{

    /* ----------------------------------------------------------------------------------------------
    #BELOW ARE THE VARIABLE THAT ARE USED TO AVOID THE HARDCODED VALUES IN THE CODE 
    ----------------------------------------------------------------------------------------------- */
    
    public static String Event_Type                              = Label.Platform_Event_Type;
    public static String Payload_Format                          = Label.Platform_Event_Payload_Format;
    public static String Action                                  = Label.Platform_Event_Timecard_Action;                          
    public static String PSE_Timecard                            = 'pse__Timecard__c';
    
    // Map timecard field with Platform Event(Integration Event) and publish the event.
    public static void MapFieldsAndPublishIntegrationPlatformEvent(List<pse__Timecard__c> newList,Map<Id,pse__Timecard__c> oldMap){
        
        List<Integration_Event__e> IntegrationEventList   = new List<Integration_Event__e>();
        
        if(!newList.isEmpty()){
            //Iterate Timecard List
            for(pse__Timecard__c PSETimecard : newList){
                If(SF_Utility.isCalloutExecuted == false && PSETimecard.int_issyncing__c == True && PSETimecard.int_Intacct_Record_No__c==null && (PSETimecard.Integration_Status__c=='In-Progress' && oldMap.get(PSETimecard.Id).Integration_Status__c!='In-Progress' && PSETimecard.int_Intacct_Record_No__c==null && PSETimecard.int_IsSyncing__c==true)){
                    //created instance of platform event 
                    Integration_Event__e IntegrationEvent     = new Integration_Event__e();
                    IntegrationEvent.Type__c                  = Event_Type;
                    IntegrationEvent.Payload_Format__c        = Payload_Format; 
                    IntegrationEvent.Action__c                = Action;  
                    IntegrationEvent.sObjectType__c           = PSE_Timecard;
                    IntegrationEvent.Payload__c               = JSON.serialize(PSETimecard);
                    
                    //Add Platform Event record in List 
                    IntegrationEventList.add(IntegrationEvent);     
                }
            }//End of PSEProj for
        }//End of newList isEmpty If
        
        if(!IntegrationEventList.isEmpty()){
           /* **************************************************************************************************************************
            * Last Modified By: Priyanka Shende, Jade Global INC. on 20th April 2018
            * Purpose         : Handled Below Scenario: APPS-19036
	    Timecard splits getting created twice and giving 2 responses for one request
            **************************************************************************************************************************** */
            SF_Utility.isCalloutExecuted = true;
            //Call method to publish events
            List<Database.SaveResult> resultsOfIntegrationEvent = EventBus.publish(IntegrationEventList);
            system.debug('############## resultsOfIntegrationEvent '+ resultsOfIntegrationEvent );
            
            if(!resultsOfIntegrationEvent .isEmpty()){
                // Inspect publishing result for each event
                for(Database.SaveResult sr : resultsOfIntegrationEvent){
                    if (sr.isSuccess()) {
                        System.debug('Successfully published Timecard event.');
                        LogPlatformEvent.createIntegrationEventLog(IntegrationEventList);
                    }//End of If 
                    else {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('Error returned for Timecard: ' +err.getStatusCode() +' - ' +err.getMessage());
                        }//End of For
                    }//End of else
                }
            }//End of resultsOfIntegrationEvent isEmpty() If
        }//End of IntegrationEventList isEmpty() If
    }// End of MapFieldsAndPublishIntegrationPlatformEvent Method


    //Used to avoid multiple callout,Getting call on before upudate of pse__Timecard__c trigger 
     public static void populateFieldOnTimecard(List<pse__Timecard__c > newList,Map<Id,pse__Timecard__c> oldMap){
         
         for(pse__Timecard__c TimecardObj : newList){
             system.debug('SF_Utility.isCalloutExecuted == ======'+SF_Utility.isCalloutExecuted);
             if(TimecardObj.Integration_Status__c==null && TimecardObj.int_Intacct_Record_No__c==null && TimecardObj.int_IsSyncing__c==true){
                 TimecardObj.Integration_Status__c= 'In-Progress';
             }
             
        }//End of FOR loop
     }//End of method populateFieldOnTimecard
     
    /* *********************************************************************************
        Last Modified By: Jade Team on 23rd May 2018, APPS-20255
        Purpose         : Used to Check the Timecard Present? on Milestone. If Timecards is present related to the milestone then set true Timecard Not Present? field on milestone.
     *********************************************************************************** */  

    public static void MilestoneUpdateBasedOnTimecardDelete(List<pse__Timecard__c > oldList){
        set<Id> setofMilestoneID = new set<Id>();
        List<pse__Milestone__c> MilestoneWithItsTimecards = new List<pse__Milestone__c>();
        List<pse__Milestone__c> UpdateMilestoneList =  new list<pse__Milestone__c>();
        try{
            
            for(pse__Timecard__c  timecardObj : oldList){
                if(!oldList.isEmpty()){
                    setofMilestoneID.add(timecardObj.pse__Milestone__c);
                }//end of If
            }//end of For
            
            MilestoneWithItsTimecards = [SELECT id,pse__Project__c ,Timecard_Not_Present__c,(SELECT id,pse__Project__c FROM pse__TimecardSplits__r) FROM pse__Milestone__c WHERE id IN : setofMilestoneID];

             for(pse__Milestone__c milestoneObj: MilestoneWithItsTimecards){
                if(!milestoneObj.pse__TimecardSplits__r.isEmpty()){
                    milestoneObj.Timecard_Not_Present__c = FALSE  ;
                }//End of if
                else if (milestoneObj.pse__TimecardSplits__r.isEmpty()){
                    milestoneObj.Timecard_Not_Present__c = TRUE ;
                     
                }//End of else if
                UpdateMilestoneList.add(milestoneObj);
            }//End of For
               UPDATE UpdateMilestoneList;
        }//End of Try Block
        catch(Exception Ex){
            System.debug('Exception Found ==================' +Ex.getMessage());
            System.debug('Exception Found ==================' +Ex.getLineNumber());
            System.debug('Exception Found ==================' +Ex.getcause());
        }//End of catch Block
    }//End of method MilestoneUpdateBasedOnTimecardDelete
    
}//end of class trigger_TimecardHeader_Helper