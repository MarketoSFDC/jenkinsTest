/* ***********************************************************************************************
Company Name  :Jade Global Inc.
Created Date  :10th February 2018
Description   : Call the LogPlatformEvent class to log Platform Event record into Integration Log Event Object 
* *********************************************************************************************** */
public class Trigger_PlatformEvent_Helper {

    public static void MatchDispatcherRecord(List<Integration_Event__e> newList){
        String MatchClass;
        Set<String> Actions = new Set<String>();
        Set<String> Types   = new Set<String>();
        Map<String,Dispatcher__mdt> MapofActionMatchtoDisp      = new  Map<String,Dispatcher__mdt>();
        Map<String,String> IntegrationEventIdtoMatchClass       = new Map<String,String>();
        
        for(Integration_Event__e IntegrationObj : newList){
            if(IntegrationObj.Action__c != null){
               Actions.add(IntegrationObj.Action__c);
            }
            if(IntegrationObj.Type__c != null){
               Types.add(IntegrationObj.Type__c);
            }
        }
        system.debug('Actions=='+Actions);
        system.debug('Types==='+Types);
        List<Dispatcher__mdt> DispatcherList = [Select id,Action__c,Type_Match__c,Dispatch_to_Class__c FROM Dispatcher__mdt WHERE Action__c IN :Actions AND Type_Match__c IN :Types];
        System.debug('DispatcherList==='+DispatcherList);
        For(Dispatcher__mdt Disp :DispatcherList){
               System.debug('Inside For loop');
             // Dynamically call Apex class specified in "Dispatch_to_Class" field
                 Type t;
                 t = Type.forName(Disp.Dispatch_to_Class__c);
                 dynamicMethodHandlerInterface Handler = (dynamicMethodHandlerInterface)t.newInstance();     
                 Handler.dynamicMethodHandler(newList);
        }
       
        //Call the LogPlatformEvent class 
        System.debug('Calling LogPlatformEvent class');
       
    }
}