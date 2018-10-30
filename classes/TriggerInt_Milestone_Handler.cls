/* ***********************************************************************************************
Company Name  :Jade Global Inc.
Created Date : 10th February 2018
Description : Handle TriggerInt_Milestone events 

Last ModifiedBy : Priyanka Shende, Jade Global Inc. on 31st Jan 2018.
Purpose         : Handle TriggerInt_Milestone  Before Insert Event

Last Modified By : Jade Global Inc. On 11th April 2018
Purpose          : Handle AfterUpdate Event - Method: SubmittedAndUnapprovedTimecardsFieldUpdate
* *********************************************************************************************** */
public class TriggerInt_Milestone_Handler {



 public static void beforeUpdateHandler(List<pse__Milestone__c> newList, Map<Id,pse__Milestone__c> newMap, List<pse__Milestone__c> oldList, Map<Id,pse__Milestone__c> oldMap){
        TriggerInt_Milestone_Helper.populateFieldOnMilstone(newList,oldMap);
 }
 

 
 public static void beforeInsertHandler(List<pse__Milestone__c> newList, Map<Id,pse__Milestone__c> newMap){
        //TriggerInt_Milestone_Helper.beforeInsertHelper(newList,oldMap);
 }
/***-----------------------------------------------------------------------------------------------------------
          AFTER INSERT HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER INSERTING THE RECORDS
---------------------------------------------------------------------------------------------------------------***/   
    public static void afterInsertHandler(List<pse__Milestone__c > newList,List<pse__Milestone__c > oldlist,map<id,pse__Milestone__c> NewMileStoneMap,map<id,pse__Milestone__c> OldMap){
    
    
    //Moved this method to Scheduled Batch Apex - FFObjectUpdateIntegrationLogBatch
       //TriggerInt_Milestone_Helper.populateProjectFromTemplateonInsert(newList);
       
       // Invoke handler method to Map Milestone field with Platform Event(Integration Event) and publish the event.
       TriggerInt_Milestone_Helper.MapFieldsAndPublishIntegrationPlatformEvent(newList,OldMap,'After Insert');
       
    }//End of afterInsertHandler Method
    
      /***-----------------------------------------------------------------------------------------------------------
    AFTER UPDATE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER UPDATING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/
    public static void afteUpdateHandler(List<pse__Milestone__c > newList,List<pse__Milestone__c > oldlist,map<id,pse__Milestone__c> NewMileStoneMap,map<id,pse__Milestone__c> OldMileStoneMap){
       
       //TriggerInt_Milestone_Helper.populateProjectFromTemplateonUpdate(newList,oldlist);
       // Invoke handler method to Map Milestone field with Platform Event(Integration Event) and publish the event.
       TriggerInt_Milestone_Helper.MapFieldsAndPublishIntegrationPlatformEvent(newList,OldMileStoneMap,'After Update');
       TriggerInt_Milestone_Helper.SubmittedAndUnapprovedTimecardsFieldUpdate(newList);
    }//End of afterInsertHandler Method
}