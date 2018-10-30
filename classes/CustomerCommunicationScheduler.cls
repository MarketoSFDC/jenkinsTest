global class CustomerCommunicationScheduler implements Schedulable{

    global List<Customer_Communication_Action__c> ccaList;
    global Boolean isWorkflowNeeded;
    global CustomerCommunicationScheduler(List<Customer_Communication_Action__c> cList, Boolean isWorkflowReqd){      
        ccaList = cList;
        isWorkflowNeeded = isWorkflowReqd;
    }
    
   global void execute(SchedulableContext sc){
      try{
        
        Map<Id, Customer_Communication_Action__c> ccaMap = new Map<Id, Customer_Communication_Action__c>(ccaList);
        
        CustomerCommunicationBatch b = new CustomerCommunicationBatch(ccaMap.keySet(), isWorkflowNeeded); 
        database.executebatch(b);
      }
      catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}      
    }
}