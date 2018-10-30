/*********************************************************************
* Last Modified by   : Grazitti 
* Modified Date      : 28-April-18
* Purpose            : #01009688 Consolidate Support Engineer Fields on Entitlement
* Line numbers       : 16

**********************************************************************/

global class updateActivePrdctsAndSpprtFieldOnAccount implements Schedulable {   
  
    global void execute(SchedulableContext ctx) {        
        List<Asset> assetList = new List<Asset>([ SELECT Asset_type__c,Add_On_Product__c, NAME, ID, STATUS, Subscription_type__c, AccountId FROM Asset WHERE UsageEndDate = YESTERDAY and status ='Expire']);
        if(!assetList.isEmpty()) { 
            updateAssets.updateAccount(assetList);
        }
        List<Entitlement> entList= new List<Entitlement>([SELECT Type,Name,Id, Status, Entitlement_Status__c, AccountId,AssignedSupportPOC__c, Account.BillingState, Support_Region__c FROM Entitlement WHERE Entitlement_Status__c = 'Expired' AND EndDate = YESTERDAY]);
        if(entList.size() == 0) return;         
        Map<Id, Entitlement> TriggerNewMap = new Map<Id, Entitlement>();  
        Utility.isUpdateContactOwnerAsAccountOwnerRunningOnceMore = true;
        Utility.isFutureUpdate = false;           
        for(Entitlement entit : entList) {
            TriggerNewMap.put(entit.Id, entit);
        }
        if(!TriggerNewMap.isempty()) { 
            UpdateEntitlements_Trigger.updateEntitlementAccount(TriggerNewMap);
        }
    }    
    @isTest (seeAllData=true)
    public static void testAccountBatch2Scheduler () {                               
        updateActivePrdctsAndSpprtFieldOnAccount schd = new updateActivePrdctsAndSpprtFieldOnAccount();
        Datetime sysTime = System.now();
        sysTime = sysTime.addSeconds(10);
        String chron_exp = '' + sysTime.second() + ' ' + sysTime.minute() + ' ' + sysTime.hour() + ' ' + sysTime.day() + ' ' + sysTime.month() + ' ? ' + sysTime.year();      
        System.schedule('Test Fallback Batch'+sysTime.getTime(),chron_exp,schd );
    }
    
}