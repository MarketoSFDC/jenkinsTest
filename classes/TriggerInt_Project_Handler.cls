/* ***********************************************************************************************
Company Name  :Jade Global Inc.
Created Date  :10th February 2018
Description : Handle TriggerInt_Project events 

* *********************************************************************************************** */

public class TriggerInt_Project_Handler{
    
      /***----------------------------------------------------------------------------------------------------------------------------------
    BEFORE INSERT HANDLER----PLACE HERE YOUR CODE TO BE EXECUTE BEFORE INSERTING THE RECORDS
    -----------------------------------------------------------------------------------------------------------------------------------***/ 
    public static void beforeInsertHandler(List<pse__Proj__c> newList, Map<Id,pse__Proj__c> newMap){  
        TriggerInt_Project_Helper.populateOpptyFieldOnProject(newList);
    }
    
    /***-----------------------------------------------------------------------------------------------------------
    BEFORE UPDATE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE BEFORE UPDATING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/ 
    public static void beforeUpdateHandler(List<pse__Proj__c> newList, Map<Id,pse__Proj__c> newMap, List<pse__Proj__c> oldList, Map<Id,pse__Proj__c> oldMap){
        TriggerInt_Project_Helper.populateFieldOnProject(newList,oldMap);
    }
    
     /***-----------------------------------------------------------------------------------------------------------
                AFTER INSERT HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER INSERTING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/   
    public static void afterInsertHandler(List<pse__Proj__c > newList, Map<Id,pse__Proj__c> newMap,Map<Id,pse__Proj__c> oldMap,List<pse__Proj__c > oldList){
       
       TriggerInt_Project_Helper.afterInsertHelper(newList);
       
       TriggerInt_Project_Helper.SharingSettings(newList);
       
       // Invoke handler method to Map projects field with Platform Event(Integration Event) and publish the event.
       TriggerInt_Project_Helper.MapFieldsAndPublishIntegrationPlatformEvent(newList,oldMap,'After Insert');
       
    }//End of afterInsertHandler Method
    
      /***-----------------------------------------------------------------------------------------------------------
    AFTER UPDATE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER UPDATING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/   
    public static void afterUpdateHandler(List<pse__Proj__c> newList,Map<Id,pse__Proj__c> newMap,List<pse__Proj__c> oldList,Map<Id,pse__Proj__c> oldMap){
        
       TriggerInt_Project_Helper.afterUpdateHelper(newList,oldList);
       
       TriggerInt_Project_Helper.SharingSettings(newList);
       
       // Invoke handler method to Map projects field with Platform Event(Integration Event) and publish the event.
       TriggerInt_Project_Helper.MapFieldsAndPublishIntegrationPlatformEvent(newList,oldMap,'After Update');
        
    }//End of afterUpdateHandler Method
}