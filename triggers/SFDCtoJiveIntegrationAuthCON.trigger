trigger SFDCtoJiveIntegrationAuthCON on Authorized_Contact__c (after insert, after delete) {
    if( system.isFuture() || system.isBatch() ) return;
    if(system.label.JiveSyncEnable =='True' || test.isrunningtest() == True) {  
        if(SfdcJiveHelper.RunIntegrationTriggerOnceOnAuthCon ==true )return; 
        SfdcJiveHelper.RunIntegrationTriggerOnceOnAuthCon = true;    
        
        map<id, string> ConIdEmailMap  = new map<id, string>();
        map<id, string> ConIDStringMap = new map<id, string>();
            
        if(trigger.isdelete){
            for (Authorized_Contact__c  temp : trigger.old) {
                ConIdEmailMap.put(temp.Contact__c, temp.email__c);  
                ConIDStringMap.put(temp.Contact__c, 'No');     
            }
        }
        if(trigger.isinsert){
            for (Authorized_Contact__c  temp : trigger.new) {
                ConIdEmailMap.put(temp.Contact__c, temp.email__c);  
                ConIDStringMap.put(temp.Contact__c, 'Yes');     
            }
        }
        
        try {
        
        //Code EWS Starts Added on Sep 29, 2016 - Grazitti Interactive
        if((Test.isRunningTest() || Label.EWSActivator == 'YES') && trigger.isInsert){EWSUtility.createrEWSActivitiesForAuthorisedContacts();}
        }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
      //Code EWS Starts Added on Sep 29, 2016 - Grazitti Interactive
      
        system.debug('ConIdEmailMap------>'+ConIdEmailMap +'=============  ConIDStringMap------>'+ConIDStringMap);   
    
        if(ConIdEmailMap.isEmpty() == FALSE && ConIDStringMap.isEmpty() == FALSE) {    
            SfdcJiveHelper cqrb = new SfdcJiveHelper(ConIdEmailMap, ConIDStringMap);        
            //Execute the batch, 1 Contact at a time.
            database.executeBatch(cqrb,40);        
        } else {
            system.debug('<=== Nothing found:===> ');
        } 
    }
}