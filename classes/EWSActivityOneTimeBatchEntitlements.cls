/*********************************************************************
* Last Modified by   : Grazitti Support 
* Modified Date      : 28-April-18
* Purpose            : #01009688 Consolidate Support Engineer Fields on Entitlement
* Line numbers       : 11,24

**********************************************************************/
global class EWSActivityOneTimeBatchEntitlements{
    public EWSActivityOneTimeBatchEntitlements(){}
    /*  implements Database.Batchable<sObject> 
    global String Query = 'Select id, (select oldvalue,newvalue,createddate,field from histories where field IN (\'AssignedSupportPOC__c\',\'Support_Admin_Contact__c\')),Accountid,AssignedSupportPOC__c,AssignedSupportPOC__r.Name,Support_Admin_Contact__c,Support_Admin_Contact__r.Name from Entitlement where AccountId != null'+(Test.isRunningTest()?' LIMIT 200':'');
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
    global EWSActivityOneTimeBatchEntitlements (){}
    global EWSActivityOneTimeBatchEntitlements (String x){
        Query = x;
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<Id,List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>> accountIdsForEWSMap = new Map<Id,List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>>();
        List<Entitlement> authContacts = (List<Entitlement>)scope;
        for(Entitlement ent : authContacts){
            for(Entitlementhistory h : ent.histories){
                if(h.field == 'AssignedSupportPOC__c' && h.newvalue != null && !((''+h.newValue).startswith('005'))){ List<EWSActivityOneTimeBatchAccount.activityInfoWrapper> temp = new List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>();if(accountIdsForEWSMap.containsKey(ent.AccountId)) temp = accountIdsForEWSMap.get(ent.AccountId);EWSActivityOneTimeBatchAccount.activityInfoWrapper accWrap = new EWSActivityOneTimeBatchAccount.activityInfoWrapper(); accWrap.name = 'New NSE'; accWrap.subDriver = 'New NSE'; accWrap.description = h.newvalue + ' was reassigned as the new Named Support Engineer'; accWrap.historyDate = h.createddate; temp.add(accWrap); accountIdsForEWSMap.put(ent.AccountId,temp); }
                if(h.field == 'Support_Admin_Contact__c' && h.newvalue != null  && !((''+h.newValue).startswith('003'))){
                    List<EWSActivityOneTimeBatchAccount.activityInfoWrapper> temp = new List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>();
                        if(accountIdsForEWSMap.containsKey(ent.AccountId)) temp = accountIdsForEWSMap.get(ent.AccountId);
                        EWSActivityOneTimeBatchAccount.activityInfoWrapper accWrap = new EWSActivityOneTimeBatchAccount.activityInfoWrapper();
                        accWrap.name='New Admin';
                        accWrap.subDriver='New Admin';
                        String supportAdmin = '';
                        accWrap.historyDate = h.createddate;
                        accWrap.description = h.newvalue + ' became the new Authorized Support Admin';
                        temp.add(accWrap);
                        accountIdsForEWSMap.put(ent.AccountId,temp);
                }
            }
        }
        if(accountIdsForEWSMap.size()>0) EWSActivityOneTimeBatchAccount.createrEWSActivities(accountIdsForEWSMap);
        
    }
    global void finish(Database.BatchableContext BC){
      EWSActivityOneTimeBatchAccount.sendEmail('EWSActivityOneTimeBatchEntitlements');
    }
    */
}