/**************************************************************************************************************************************
* Apex Class: TriggerInt_Invoice_Helper
* Created by Jade Global
---------------------------------------------------------------------------------------------------------------------------------------
* Purpose/Methods:
* - Helper class for Trigger - "Sales_Invoice_AI_AU_AD_MKT" & Apex Class - TriggerInt_Invoice_Handler
---------------------------------------------------------------------------------------------------------------------------------------
* History:
* - VERSION     DEVELOPER NAME          DATE                         DETAIL FEATURES
    1.0         Jade Global             10th February 2018           INITIAL DEVELOPMENT
**************************************************************************************************************************************/

public class TriggerInt_Invoice_Helper{

    /* ----------------------------------------------------------------------------------------------
    #BELOW ARE THE VARIABLE THAT ARE USED TO AVOID THE HARDCODED VALUES IN THE CODE 
    ----------------------------------------------------------------------------------------------- */
    
    public static String Event_Type                              = Label.Platform_Event_Type;
    public static String Payload_Format                          = Label.Platform_Event_Payload_Format;
    public static String Action                                  = Label.Platform_Event_Update_Invoice_Action;                          
    public static String SalesInvoice                            = 'Sales_Invoice__c';
    public static IntacctAPIRequest__mdt invoiceMetadata = [SELECT Id, API_Request_Template__c FROM IntacctAPIRequest__mdt WHERE MasterLabel = 'Update Invoice in Intacct' LIMIT 1];

    // Map timecard field with Platform Event(Integration Event) and publish the event.
    public static void MapFieldsAndPublishIntegrationPlatformEvent(List<Sales_Invoice__c> newList,Map<Id,Sales_Invoice__c> oldMap){
        
        List<Integration_Event__e> IntegrationEventList   = new List<Integration_Event__e>();

        if(!newList.isEmpty() && Userinfo.getname()!='Intacct Marketo'){
            //Iterate Sales Invoice List
            for(Sales_Invoice__c SInvoice : newList){
            system.debug('==========INT OLD'+oldMap.get(SInvoice.Id).Integration_Status__c);
            system.debug('==========INT NEW'+SInvoice.Integration_Status__c);
                If(SF_Utility.isCalloutExecuted == false && SInvoice.int_issyncing__c == True && (SInvoice.Integration_Status__c=='In-Progress' && oldMap.get(SInvoice.Id).Integration_Status__c!=SInvoice.Integration_Status__c && SInvoice.int_Intacct_Transaction_ID__c!=null && SInvoice.int_IsSyncing__c==true)){
                //created instance of platform event 
                Integration_Event__e IntegrationEvent     = new Integration_Event__e();
                IntegrationEvent.Type__c                  = Event_Type;
                IntegrationEvent.Payload_Format__c        = Payload_Format; 
                IntegrationEvent.Action__c                = Action;  
                IntegrationEvent.sObjectType__c           = SalesInvoice;
                IntegrationEvent.Payload__c               = JSON.serialize(SInvoice);
                
                //Add Platform Event record in List 
                IntegrationEventList.add(IntegrationEvent);    
              }  
            }//End of PSEProj for
        }//End of newList isEmpty If
        
        if(!IntegrationEventList.isEmpty()){
            //To avoid multiple callout 
            SF_Utility.isCalloutExecuted = true;
             system.debug('########INVOICE###### IntegrationEventList'+ IntegrationEventList);
            // Call method to publish events.
            List<Database.SaveResult> resultsOfIntegrationEvent = EventBus.publish(IntegrationEventList);
            system.debug('############## resultsOfIntegrationEvent '+ resultsOfIntegrationEvent );
            
            if(!resultsOfIntegrationEvent .isEmpty()){
                // Inspect publishing result for each event
                for(Database.SaveResult sr : resultsOfIntegrationEvent){
                    if (sr.isSuccess()) {
                        System.debug('Successfully published Sales Invoice event.');
                        LogPlatformEvent.createIntegrationEventLog(IntegrationEventList);
                    }//End of If 
                    else {
                        for(Database.Error err : sr.getErrors()) {
                            System.debug('Error returned for Sales Invoice: ' +err.getStatusCode() +' - ' +err.getMessage());
                        }//End of For
                    }//End of else
                }
            }//End of resultsOfIntegrationEvent isEmpty() If
        }//End of IntegrationEventList isEmpty() If
    }// End of MapFieldsAndPublishIntegrationPlatformEvent Method
    
/* ***********************************************************************************************
Created By  : Jade Global Inc.
Created On  : 12th December 2017
Description : Populate Intacct Project ID And Milestone on Sales Invoice Item based on Sales Invoice Intacct Project ID. 

* *********************************************************************************************** */

    public static void populateIntacctProjectIDWithMilestone(List<Sales_Invoice__c> newList,Map<Id,Sales_Invoice__c> oldMap){
        
        set<String> setofIntacctId = new set<String>();
        Map<id,String> SalesInvoiceIdwithIntacctId = new Map<id,String>();
        Map<String,Id> MapOfSalesInvoiceItemsIntacctId = new Map<String,Id>();
        Map<id,Sales_Invoice_Item__c> MapofSalesInvoiceItmIDWithRec = new Map<id,Sales_Invoice_Item__c>();
        Map<String,Id> MapofIntactProjIdWithSalesInvoiceID = new Map<String,Id>();
        list<Sales_Invoice_Item__c> listOfUpdateSalesInvoiceItem = new list<Sales_Invoice_Item__c>(); 
        
            for(Sales_Invoice__c SalesInvoiceObj :newList){
                if(!newList.isEmpty() && SalesInvoiceObj.int_Intacct_Project_ID__c != oldMap.get(SalesInvoiceObj.id).int_Intacct_Project_ID__c)
                    SalesInvoiceIdwithIntacctId.put(SalesInvoiceObj.Id,SalesInvoiceObj.int_Intacct_Project_ID__c);
            }//end of for
            
             for(pse__Milestone__c MileStoneObj : [SELECT id ,int_Intacct_Project_ID_2__c FROM pse__Milestone__c WHERE int_Intacct_Project_ID_2__c IN: SalesInvoiceIdwithIntacctId.values()]){
                 MapofIntactProjIdWithSalesInvoiceID.put(MileStoneObj.int_Intacct_Project_ID_2__c,MileStoneObj.id);
             }
            
            
            if(!MapofIntactProjIdWithSalesInvoiceID.isEmpty()){
                for(Sales_Invoice_Item__c SalesInItemObj: [SELECT id, Sales_Invoice__c,Sales_Invoice__r.int_Intacct_Project_ID__c,int_Intacct_Project_ID__c,int_Milestone_Intacct_Project__c from Sales_Invoice_Item__c WHERE Sales_Invoice__c IN: SalesInvoiceIdwithIntacctId.KeySet() AND int_Milestone_Intacct_Project__c = null]){
                    
                       if(MapofIntactProjIdWithSalesInvoiceID.ContainsKey(SalesInItemObj.Sales_Invoice__r.int_Intacct_Project_ID__c)){
                        SalesInItemObj.int_Milestone_Intacct_Project__c = MapofIntactProjIdWithSalesInvoiceID.get(SalesInItemObj.Sales_Invoice__r.int_Intacct_Project_ID__c);
                        SalesInItemObj.int_Intacct_Project_ID__c = SalesInItemObj.Sales_Invoice__r.int_Intacct_Project_ID__c;
                        listOfUpdateSalesInvoiceItem.add(SalesInItemObj);
                        }//end of if
                   
                }//end of for
            }//end of if
            try{
                update listOfUpdateSalesInvoiceItem;
            }catch(DMLException ex){
                system.debug('###Exception Occured### ' +ex);
            }//end of try catch block

        
        
    }
    
     //Used to avoid multiple callout,Getting call on before upudate of Invoice trigger 
     public static void populateFieldOnInvoice(List<Sales_Invoice__c> newList,Map<Id,Sales_Invoice__c> oldMap){
       if( Userinfo.getname()!='Intacct Marketo'){
         for(Sales_Invoice__c invoiceObj : newList){
             system.debug('SF_Utility.isCalloutExecuted == ======'+SF_Utility.isCalloutExecuted);
             system.debug('========'+invoiceObj.Integration_Status__c);
             if(invoiceObj.Integration_Status__c==null && invoiceObj.int_Intacct_Transaction_ID__c!=null && invoiceObj.int_IsSyncing__c==true){
                invoiceObj.Integration_Status__c= 'In-Progress';
                 system.debug('SF_Utility.isCalloutExecuted == ======'+SF_Utility.isCalloutExecuted);
                 system.debug('==IF======'+invoiceObj.Integration_Status__c);
             }
             else if(SF_Utility.isCalloutExecuted == false && invoiceObj.Integration_Status__c!=null && invoiceObj.int_Intacct_Transaction_ID__c!=null && invoiceObj.int_IsSyncing__c==true){
                 if(isSpecifiedFieldUpdated(invoiceObj, oldMap, invoiceMetadata.API_Request_Template__c)){
                     invoiceObj.Integration_Status__c= 'In-Progress';
                 }
                  system.debug('==ELSE ======'+invoiceObj.Integration_Status__c);
             }
        }//End of FOR loop
       }
     }//End of method populateFieldOnInvoice
     
    public static Boolean isSpecifiedFieldUpdated(Sales_Invoice__c newRecord, Map<Id,Sales_Invoice__c > oldMap, String XMLBody){

        Set<String> apiNameSet = new Set<String>();
        String[] XMLBodyWithoutTags = XMLBody.stripHTMLTags().split('\\[\\[');
        
        
        
        for(String fieldName : XMLBodyWithoutTags){
            
            
                if(fieldName.contains(']]')){
                    for(string s1:fieldName.stripHTMLTags().split('\\[\\[')){   
                    system.debug('FEILD API============='+s1.substring(0,s1.indexof(']]')));
                       apiNameSet.add(s1.substring(0,s1.indexof(']]')));
                    }
                }
               
            
            
        }//End of FOR

        for(String fieldName : apiNameSet){
            System.debug('>>> Field Name = '+ fieldName);
            if(newRecord.get(fieldName) != oldMap.get(newRecord.Id).get(fieldName)){
                return true;
            }
        }

        return false;
     }//End of mehtod isSpecifiedFieldUpdated
}//end of class trigger_TimecardHeader_Helper