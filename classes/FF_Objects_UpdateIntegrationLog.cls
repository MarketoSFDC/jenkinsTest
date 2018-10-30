/* *************************************************************************************************************************************
*Company Name  :Jade Global Inc.
*Created Date  :10th February 2018 
*Batch Apex Class: FF_Objects_UpdateIntegrationLog
---------------------------------------------------------------------------------------------------------------------------------------
* Purpose/Methods:
    If Exception thrown at salesforce side update Financial Force Object based on the Integration Event Log
---------------------------------------------------------------------------------------------------------------
Last ModifiedBy : Priyanka Shende, Jade Global Inc. on 12th July 2018
Purpose         : If Record is In progress then only retrigger the Update Record in Salesforce Action update the integration log with Integration Status = blank 
*********************************************************************************************************** */

public class FF_Objects_UpdateIntegrationLog{

  @InvocableMethod(label='Update Integration Log')
  public static void UpdateSobjetFromIntLog(List<Integration_Event_Log__c> PBInputs){
     Integration_Event_Log__c IntEventLogToBeUpdate = PBInputs[0];
     String Integration_Status = 'In-Progress';
     Id ObjId = IntEventLogToBeUpdate.Name;
     Schema.SObjectType sobjectType = ObjId.getSObjectType();
     String sobjectName = sobjectType.getDescribe().getName();
     SObject record = Database.query('Select Id, Name,Integration_Status__c,int_Intacct_Record_No__c From ' + sobjectName + ' Where Id = :ObjId');
     if(record.get('Integration_Status__c')==Integration_Status && (record.get('int_Intacct_Record_No__c')==null|| record.get('int_Intacct_Record_No__c')=='')){
         Integration_Event_Log__c IntEventLogList =[SELECT Name,Id,Debug__c,Payload__c,Payload_Format__c,sObjectType__c,Type__c,Action__c,Integration_Status__c FROM Integration_Event_Log__c WHERE Name=:PBInputs[0].Name AND Action__c like '%Update%' AND Action__c like '%Salesforce%' order by createdDate desc limit 1];
     
     //Invoke SF_Utility UpdateSobjectRecord() method 
     SF_Utility.UpdateSobjectRecord(IntEventLogList.Payload__c,IntEventLogList.sObjectType__c,IntEventLogList.Action__c,IntEventLogList.Type__c,IntEventLogToBeUpdate.id);
     system.debug('################## After Update SobjectRecord');
     }else{
         Integration_Event_Log__c IntLogToUpdate  = new Integration_Event_Log__c();
         IntLogToUpdate.id                        = PBInputs[0].id;
         IntLogToUpdate.Integration_Status__c     = null;
         Update IntLogToUpdate;
     }
      
  }//End of UpdateSobjetFromIntLog() Method
}