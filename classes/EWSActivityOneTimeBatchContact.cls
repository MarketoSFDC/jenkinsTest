global class EWSActivityOneTimeBatchContact{
    public EWSActivityOneTimeBatchContact(){}
    /*  implements Database.Batchable<sObject> 
    global String Query = 'Select id,createddate,Contact.FirstName,Contact.LastName,Accountid,NPS_Score__c from Contact where AccountId != null and NPS_Score__c !=null'+(Test.isRunningTest()?' LIMIT 200':'');
    global Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator(query);
    }
public EWSActivityOneTimeBatchContact(){}
    public EWSActivityOneTimeBatchContact(String x){Query = x;}
    global void execute(Database.BatchableContext BC, List<sObject> scope){
        Map<Id,List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>> accountIdsForEWSMap = new Map<Id,List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>>();
        List<Contact> authContacts = (List<Contact>)scope;
        for(Contact con : authContacts){
            if(con.NPS_Score__c!=null && con.AccountId != null){
                 if(con.NPS_Score__c >=9 ){
                    List<EWSActivityOneTimeBatchAccount.activityInfoWrapper> temp = new List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>();
                    if(accountIdsForEWSMap.containsKey(con.AccountId)) temp = accountIdsForEWSMap.get(con.AccountId);
                    EWSActivityOneTimeBatchAccount.activityInfoWrapper accWrap = new EWSActivityOneTimeBatchAccount.activityInfoWrapper();
                    accWrap.name = 'Positive NPS';
                    accWrap.historyDate = con.createddate;
                    accWrap.subDriver = 'Positive NPS';
                    accWrap.description = con.FirstName +' ' +con.LastName + ' ranked Marketo as '+ con.NPS_Score__c +' on an NPS survey';
                    temp.add(accWrap);
                    accountIdsForEWSMap.put(con.AccountId,temp);   
                }
                else if(con.NPS_Score__c <= 6 ){
                    List<EWSActivityOneTimeBatchAccount.activityInfoWrapper> temp = new List<EWSActivityOneTimeBatchAccount.activityInfoWrapper>();
                    if(accountIdsForEWSMap.containsKey(con.AccountId)) temp = accountIdsForEWSMap.get(con.AccountId);
                    EWSActivityOneTimeBatchAccount.activityInfoWrapper accWrap = new EWSActivityOneTimeBatchAccount.activityInfoWrapper();
                    accWrap.name = 'Negative NPS';
                    accWrap.historyDate = con.createddate;
                    accWrap.subDriver = 'Negative NPS';
                    accWrap.description = con.FirstName +' ' +con.LastName + ' ranked Marketo as '+ con.NPS_Score__c +' on an NPS survey';
                    temp.add(accWrap);
                    accountIdsForEWSMap.put(con.AccountId,temp);                
                }
            }    
        }
        if(accountIdsForEWSMap.size()>0){
            EWSActivityOneTimeBatchAccount.createrEWSActivities(accountIdsForEWSMap);
        }
    }
    global void finish(Database.BatchableContext BC){
        EWSActivityOneTimeBatchAccount.sendEmail('EWSActivityOneTimeBatchContact');
    }
    */
}