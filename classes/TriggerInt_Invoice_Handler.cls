/**************************************************************************************************************************************
* Apex Class: TriggerInt_Invoice_Handler
* Created by Jade Global
---------------------------------------------------------------------------------------------------------------------------------------
* Purpose/Methods:
* - Handler class for Trigger - "Sales_Invoice_AI_AU_AD_MKT"
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
**************************************************************************************************************************************/

public class TriggerInt_Invoice_Handler {
    
    /***----------------------------------------------------------------------------------------------------------------------------------
    BEFORE INSERT HANDLER----PLACE HERE YOUR CODE TO BE EXECUTE BEFORE INSERTING THE RECORDS
    -----------------------------------------------------------------------------------------------------------------------------------***/ 
/*    public static void beforeInsertHandler(List<Sales_Invoice__c> newList, Map<Id,Sales_Invoice__c> newMap){  

    }*/
    
    /***-----------------------------------------------------------------------------------------------------------
    BEFORE UPDATE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE BEFORE UPDATING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/ 
    public static void beforeUpdateHandler(List<Sales_Invoice__c> newList, Map<Id,Sales_Invoice__c> newMap, List<Sales_Invoice__c> oldList, Map<Id,Sales_Invoice__c> oldMap){
       TriggerInt_Invoice_Helper.populateFieldOnInvoice(newList,oldmap);
    }
    
    /***-----------------------------------------------------------------------------------------------------------
    BEFORE DELETE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE BEFORE DELETING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/   
   /* public static void beforeDeleteHandler(List<Sales_Invoice__c > oldList, Map<Id,Sales_Invoice__c > oldMap){
       
    }*/
    
    /***-----------------------------------------------------------------------------------------------------------
    AFTER INSERT HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER INSERTING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/   
   /* public static void afterInsertHandler(List<Sales_Invoice__c> newList, Map<Id,Sales_Invoice__c> newMap, List<Sales_Invoice__c> oldList, Map<Id,Sales_Invoice__c> oldMap){
        
    }*/
    
    /***-----------------------------------------------------------------------------------------------------------
    AFTER UPDATE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER UPDATING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/   
    public static void afterUpdateHandler(List<Sales_Invoice__c> newList, Map<Id,Sales_Invoice__c> newMap, List<Sales_Invoice__c> oldList, Map<Id,Sales_Invoice__c> oldMap){
        TriggerInt_Invoice_Helper.populateIntacctProjectIDWithMilestone(newList,oldMap);
        TriggerInt_Invoice_Helper.MapFieldsAndPublishIntegrationPlatformEvent(newList,oldMap);
    }
    
    /***-----------------------------------------------------------------------------------------------------------
    AFTER DELETE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER DELETING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/   
    /*public static void afterDeleteHandler(List<Sales_Invoice__c > newList, List<Sales_Invoice__c > oldList, Map<Id,Sales_Invoice__c > oldMap){
        
    }*/
    
    /***-----------------------------------------------------------------------------------------------------------
    AFTER UNDELETE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER DELETING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/   
   /* public static void afterUnDeleteHandler(List<Sales_Invoice__c > newList, Map<Id,Sales_Invoice__c > newMap){

    }*/
    
}