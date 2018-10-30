/* ***********************************************************************************************
  Company Name :Jade Global Inc.
  Created Date :10th February 2018
   Description : This is used for
                 1.Updating Salesforce record dynamically from Intacct response.

Last Modified By: Priyanka Shende, On 26th Feb 2018
         Purpose: To handle duplicate fields issue 

Last Modified By: Priyanka Shende, Jade Global Inc on 19th May 2018.
Description     : Removed 3 Attempts logic as we have process builder to retrigger locked(Failed) records   

Last Modified By: Jade Global Inc On 19th May 2018
Updated for    : Added as part of Collection Lock Requirement, added code to handle scenarios related to  Asset and Account.
 
Last Modified By : Jade Global Inc, 22nd August 2018.
Purpose          : APPS-21688 : Account Unlock Process

* *********************************************************************************************** */
public class SF_Utility implements dynamicMethodHandlerInterface {
    public static boolean isCalloutExecuted = false;
    public static boolean isMilestoneCalloutExecuted = false;
    private static final String UNABLE_TO_LOCK_ROW = 'UNABLE_TO_LOCK_ROW';
    private static final String INVALID_CROSS_REFERENCE_KEY = 'INVALID_CROSS_REFERENCE_KEY';

   /***************************************************************
    * Method name   :dynamicMethodHandler
    * Return type   :void
    * Purpose       : Getting called from Integration event trigger(Platform Event).
    *                 This is used to call method parsePlatformEventRecord for Update
    *****************************************************************/
   
    Public static void dynamicMethodHandler(List < Integration_Event__e > newList) {
        System.debug('dynamicMethodHandler Method called');
        parsePlatformEventRecord(newList);
    }
    
    /***************************************************************
    * Method name   :parsePlatformEventRecord
    * Return type   :void
    * Purpose       : Updating salesforce record From Intacct success Response based on the SObject type
    *                 
    *****************************************************************/

    Public static void parsePlatformEventRecord(List < Integration_Event__e > IEObjList) {
               for(Integration_Event__e IE: IEObjList) {
                        UpdateSobjectRecord(IE.Payload__c,IE.sObjectType__c, IE.Action__c,IE.Type__c,null);
                }
    
    }//End of method parsePlatformEventRecord

    /***************************************************************
    * Method name   :UpdateRecordsFromIntacctResponse
    * Return type   :void
    * Purpose       : Updating salesforce record From Intacct Error Response based on the SObject type
    *                 
    *****************************************************************/
    Public static void UpdateRecordsFromIntacctResponse(string SFID, string sObjType, String status, string errorMsg) {
        Savepoint sp = Database.setSavepoint();
        try {
            
            String QUERY = 'SELECT Id,Integration_Status__c, Integration_Message__c';
            QUERY += ' FROM ' + sObjType + ' WHERE Id =: SFID LIMIT 1 FOR UPDATE';
            system.debug('QUERY================='+QUERY);
            List < sObject > recordToUpdate = Database.query(QUERY);
            
            if(!recordToUpdate.isEmpty())
            {
                recordToUpdate[0].put('Integration_Status__c', status);
                recordToUpdate[0].put('Integration_Message__c', errorMsg);
            }
            
            isCalloutExecuted = True;
            if (sObjType.equalsIgnoreCase('pse__Milestone__c'))
                isMilestoneCalloutExecuted = true;

           UPDATE recordToUpdate;
        } catch (Exception ex) {
            string ErrorMsgException = 'Cause : '+ ex.getCause() + 
                                                      '\nError Line Number : '+ ex.getLineNumber() + 
                                                      '\nMessage : '+ ex.getMessage() + 
                                                      '\nStackTrace : '+ ex.getStackTraceString() + 
                                                      '\nException Type : '+ ex.getTypeName();
            Database.rollback(sp);
          LogPlatformEvent.createErrorLog( ErrorMsgException , sObjType, 'Update Integration Status and Message', status + '\n' + errorMsg, 'SF Event', SFID,'In Progress');
        }
    }

        @future
        public static void UpdateSobjectRecord(string payload,string sobjType,string action,string type, string intEventLog) {
           
            Set<String> sObjectTypes = new Set<String>();
            Map<String, String> HashMap = new Map<String, String>();
            String objId = '';
            Savepoint sp = Database.setSavepoint();
            list < sobject > updateSobj = new list < sobject > ();
            list < Asset > AssList = new list < Asset > ();
            list < Account > AccountList = new list < Account > ();
            List < sObject > recordToUpdate=new List < sObject >();
            
            try {
                HashMap = Generate_XML.ReplaceMap(Payload);
                String QUERY='SELECT Integration_Status__c,Integration_Message__c,Intacct_Sync_Date__c ';                      
                //Added for Asset Object       
                if(sobjType=='Asset'){
                    QUERY = QUERY+',Munchkin_ID__c,AccountId,Id,Status ';
                }//End of If
                
                if(!HashMap.isEmpty()) {
                    for (String FiledName: HashMap.keySet()) {
                        //Added !QUERY.contains(FiledName) condition to avoid duplicate fields
                        if(FiledName.contains('__c') && !QUERY.contains(FiledName)){
                            QUERY += ' ,' + FiledName + ' ';
                        }//End of If
                    }//End of For

                    objId = HashMap.get('Id');
                    QUERY += 'FROM ' + sObjType + ' WHERE Id =: objId LIMIT 1 FOR UPDATE';
                    System.debug('ObjectId >>>' + objId);
                    System.debug('QUERY >>>' + QUERY);
                    
                    recordToUpdate = Database.query(QUERY);
                    //To handle Too many SOQL Exception
                    integer SOQLCount = Limits.getQueries();
                    
                    if(SOQLCount > 100){
                        LogPlatformEvent.createErrorLog('Too many SOQL 101', sobjType, action, payload, Type, objId,'In Progress');
                    }//End of If
                    
                    if(!recordToUpdate.isEmpty()){  
                        System.debug('recordToUpdate List >>>'+ recordToUpdate);
                        for (String FiledName: HashMap.keySet()) {
                            String FieldValue = HashMap.get(FiledName);
                            if (FieldValue != null && FieldValue != 'null') {
                                FieldValue = FieldValue.unescapeHtml4();
                                if(!FiledName.equalsIgnoreCase('Id'))
                                    recordToUpdate[0].put(FiledName.trim(), FieldValue.trim());
                            }//End of If
                        }//End of for
                                    
                        // UPDATE Sobject
                        recordToUpdate[0].put('Integration_Status__c', 'Success');
                        recordToUpdate[0].put('Integration_Message__c', 'Success');
                        recordToUpdate[0].put('Intacct_Sync_Date__c', System.now());
                        system.debug('sObj==' + recordToUpdate[0]);
                        isCalloutExecuted = True;
                        updateSobj.add(recordToUpdate[0]);
                    }//End of IF block of recordToUpdate list Empty check
                 }
                
                    if (!updateSobj.isEmpty()) {
    
                        if (sObjType.equalsIgnoreCase('pse__Milestone__c'))
                            isMilestoneCalloutExecuted = true;
    
                        UPDATE updateSobj;
                }//End of If
                    
                if(sobjType =='Asset'){
                    Asset convertedAsset = (Asset)recordToUpdate[0];
                   // System.assertequals(convertedAsset,updateSobj[0]);
                    
                    AccountList=[Select Id,Collection_Status__c,Asset_Status__c from Account where Id=:convertedAsset.AccountId];
                    
                    system.debug('AccountList==' + AccountList);
                    //Code to populate Asset Status,Collection Status on Account                  
                    if(HashMap.get('Status') =='Locked'){
                        system.debug('*********'+convertedAsset.Munchkin_ID__c+':Error In Lock');
                        
                        if(String.isBlank(AccountList[0].Asset_Status__c)){
                            AccountList[0].Asset_Status__c=convertedAsset.Munchkin_ID__c+':Locked Successfully';
                        }//End of If
                        else if(AccountList[0].Asset_Status__c.contains(convertedAsset.Munchkin_ID__c+':Error In Lock')){                        
                            AccountList[0].Asset_Status__c=AccountList[0].Asset_Status__c.replace(convertedAsset.Munchkin_ID__c+':Error In Lock', convertedAsset.Munchkin_ID__c+':Locked Successfully');
                        }
                        else if(!AccountList[0].Asset_Status__c.contains(convertedAsset.Munchkin_ID__c+':Locked Successfully'))
                            AccountList[0].Asset_Status__c=AccountList[0].Asset_Status__c +','+convertedAsset.Munchkin_ID__c+':Locked Successfully' ;
                        
                        //Populate Collection Status on Account based on Asset Status   
                        if(!AccountList[0].Asset_Status__c.contains('Error') && AccountList[0].Asset_Status__c.contains('Locked Successfully')&& !AccountList[0].Asset_Status__c.contains('Unlocked Successfully')){
                            AccountList[0].Collection_Status__c='Account Locked';
                         }//End of If
                    }        
                    else if(HashMap.get('Status') =='Active'){
                        if(AccountList[0].Collection_Status__c=='Account Locked'){
                            AccountList[0].Asset_Status__c='';
                        }//End of If
                                                
                        if(String.isBlank(AccountList[0].Asset_Status__c)){
                            AccountList[0].Asset_Status__c=convertedAsset.Munchkin_ID__c+':Unlocked Successfully';
                        }
                        else if(!String.isBlank(AccountList[0].Asset_Status__c) && AccountList[0].Asset_Status__c.contains( convertedAsset.Munchkin_ID__c+':Error In Unlock')){
                        
                            AccountList[0].Asset_Status__c=AccountList[0].Asset_Status__c.replace(convertedAsset.Munchkin_ID__c+':Error In Unlock',convertedAsset.Munchkin_ID__c+':Unlocked Successfully');
                        }
                        else 
                            AccountList[0].Asset_Status__c=AccountList[0].Asset_Status__c+','+convertedAsset.Munchkin_ID__c +':Unlocked Successfully';
                                
                            if(!AccountList[0].Asset_Status__c.contains('Error') && AccountList[0].Asset_Status__c.contains('Unlocked Successfully')&& !AccountList[0].Asset_Status__c.contains('Locked Successfully')){
                            
                                AccountList[0].Collection_Status__c='Account Unlocked';                               
                            
                            }//End of If                                
                        }else if(HashMap.get('Status') =='Expired'){
                            if(String.isBlank(AccountList[0].Asset_Status__c)){
                            AccountList[0].Asset_Status__c=convertedAsset.Munchkin_ID__c+':Expired Successfully,as instance is already cancelled in SPA';
                            }
                            else if(!String.isBlank(AccountList[0].Asset_Status__c) ){
                                AccountList[0].Asset_Status__c=!AccountList[0].Asset_Status__c.contains( convertedAsset.Munchkin_ID__c)? AccountList[0].Asset_Status__c+','+convertedAsset.Munchkin_ID__c+':Expired Successfully,as instance is already cancelled in SPA':AccountList[0].Asset_Status__c;   
                                
                                String AssetStatus='';
                                AssetStatus=AccountList[0].Asset_Status__c.contains(convertedAsset.Munchkin_ID__c+':Error In Unlock')?convertedAsset.Munchkin_ID__c+':Error In Unlock':AccountList[0].Asset_Status__c.contains(convertedAsset.Munchkin_ID__c+':Error In Lock')?convertedAsset.Munchkin_ID__c+':Error In Lock':AccountList[0].Asset_Status__c.contains(convertedAsset.Munchkin_ID__c+':Locked Successfully')?convertedAsset.Munchkin_ID__c+':Locked Successfully':AccountList[0].Asset_Status__c.contains(convertedAsset.Munchkin_ID__c+':Unlocked Successfully')?convertedAsset.Munchkin_ID__c+':Unlocked Successfully':AssetStatus;
                                
                                if(!String.isBlank(AssetStatus)){
                                    AccountList[0].Asset_Status__c=AccountList[0].Asset_Status__c.replace(AssetStatus,convertedAsset.Munchkin_ID__c+':Expired Successfully,as instance is already cancelled in SPA');
                                }
                            
                            //Populate Collection Status on Account based on Asset Status   
                            if(!AccountList[0].Asset_Status__c.contains('Error') && AccountList[0].Asset_Status__c.contains('Expired Successfully,as instance is already cancelled in SPA')){
                                AccountList[0].Collection_Status__c='Account Locked';
                             }//End of If
                            }
                        
                        //End of else
                     }  
                }//End of if
                
                system.debug('AccountList==' + AccountList);
                if(!AccountList.isEmpty()){
                    Update AccountList;
                }//End of if
                
                if(intEventLog!=null){
                    Integration_Event_Log__c IntEventLogToBeUpdate = new Integration_Event_Log__c();
                    IntEventLogToBeUpdate.id  = intEventLog;
                    IntEventLogToBeUpdate.Integration_Status__c    = null;
                    
                    update IntEventLogToBeUpdate;
                    system.debug('################## IntEventLogToBeUpdate'+IntEventLogToBeUpdate);
                 }//End of if
            } //End of TRY block

            catch (Exception Ex) {
                string ErrorMsgException = 'Cause : '+ ex.getCause() + 
                                                      '\nError Line Number : '+ ex.getLineNumber() + 
                                                      '\nMessage : '+ ex.getMessage() + 
                                                      '\nStackTrace : '+ ex.getStackTraceString() + 
                                                      '\nException Type : '+ ex.getTypeName();
                   Database.rollback(sp);
                   LogPlatformEvent.createErrorLog( ErrorMsgException , sobjType, action, payload, Type, objId,'In Progress');
                    
                    
                    System.debug('Outer Catch exception >>>>' + Ex);
                    system.debug('DML Exception====' +Ex.getMessage());
                } //ENd of catch block 
          //  } //End of while loop
    }//End of method :UpdateSobjectRecord

}//End of Class