/**************************************************************************************************************************************
* Apex Class: Trigger_Timecard_Handler
* Created by Jade Global
---------------------------------------------------------------------------------------------------------------------------------------
* Purpose/Methods:
* - Handler class for Trigger - "trigger_Timecard"
---------------------------------------------------------------------------------------------------------------------------------------
* DEVELOPER INSTRUCTIONS:
1. TRY TO KEEP YOUR LOGIC IN MASTER LOOP. AVOID NEW LOOP ADDITION.
2. CREATE A HELPER METHOD TO HANDLE THE LOGIC
3. DO NOT ADD ANY NEW DML OPERATION- TRY TO ADD DATA TO BE MANIPULATE IN EXISTING DMLs.
4. DO NOT ADD ANY SOQL REDUNDANTLY
---------------------------------------------------------------------------------------------------------------------------------------
* History:
* - VERSION     DEVELOPER NAME          DATE                        DETAIL FEATURES
    1.0         Jade Global             10th February 2018          INITIAL DEVELOPMENT
    1.1         Jade Global             23rd May 2018               JIRA APPS-20255 Milestone and Project Validation Error
   
**************************************************************************************************************************************/

public class Trigger_Timecard_Handler {
    
    /***----------------------------------------------------------------------------------------------------------------------------------
    BEFORE INSERT HANDLER----PLACE HERE YOUR CODE TO BE EXECUTE BEFORE INSERTING THE RECORDS
    -----------------------------------------------------------------------------------------------------------------------------------***/ 
    public static void beforeInsertHandler(List<pse__Timecard__c> newList, Map<Id,pse__Timecard__c> newMap){  

    }
    
    /***-----------------------------------------------------------------------------------------------------------
    BEFORE UPDATE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE BEFORE UPDATING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/ 
    public static void beforeUpdateHandler(List<pse__Timecard__c> newList, Map<Id,pse__Timecard__c> newMap, List<pse__Timecard__c> oldList, Map<Id,pse__Timecard__c> oldMap){
        Trigger_Timecard_Helper.populateFieldOnTimecard(newList,oldMap);
    }
    
    /***-----------------------------------------------------------------------------------------------------------
    BEFORE DELETE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE BEFORE DELETING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/   
   /*public static void beforeDeleteHandler(List<pse__Timecard__c > oldList, Map<Id,pse__Timecard__c > oldMap){
       
    }*/
    
    /***-----------------------------------------------------------------------------------------------------------
    AFTER INSERT HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER INSERTING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/   
    public static void afterInsertHandler(List<pse__Timecard__c> newList, Map<Id,pse__Timecard__c> newMap, List<pse__Timecard__c> oldList, Map<Id,pse__Timecard__c> oldMap){
        
        // Invoke handler method to Map projects field with Platform Event(Integration Event) and publish the event.
        Trigger_Timecard_Helper.MapFieldsAndPublishIntegrationPlatformEvent(newList,oldMap);
    }
      
      
    /***-----------------------------------------------------------------------------------------------------------
    AFTER UPDATE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER UPDATING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/   
    public static void afterUpdateHandler(List<pse__Timecard__c> newList, Map<Id,pse__Timecard__c> newMap, List<pse__Timecard__c> oldList, Map<Id,pse__Timecard__c> oldMap){
                Trigger_Timecard_Helper.MapFieldsAndPublishIntegrationPlatformEvent(newList,oldMap);

    }
    
    /***-----------------------------------------------------------------------------------------------------------
    AFTER DELETE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER DELETING THE RECORDS
    JIRA APPS-20255 Milestone and Project Validation Error
    ---------------------------------------------------------------------------------------------------------------***/       
    public static void afterDeleteHandler(List<pse__Timecard__c > newList, List<pse__Timecard__c > oldList, Map<Id,pse__Timecard__c > oldMap){
        Trigger_Timecard_Helper.MilestoneUpdateBasedOnTimecardDelete(oldList);
    }
    
    /***-----------------------------------------------------------------------------------------------------------
    AFTER UNDELETE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER DELETING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/   
   /* public static void afterUnDeleteHandler(List<pse__Timecard__c > newList, Map<Id,pse__Timecard__c> newMap){

    }*/
    
}