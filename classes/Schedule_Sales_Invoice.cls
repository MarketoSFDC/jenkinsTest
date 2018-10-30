/**
THE SCHEDULER IS WRITTEN TO OVERCOME THE ISSUE: DAYS PAST DUE, A FORMULA FIELD, GETS A VALUE 
AUTOMATICALLY AND DOES NOT INVOKE TRIGGER TO UPDATE PAYMENT STATUS ON ACCOUNT EVEN IT MEETS THE CRITERIA THAT CUSTOMER HAS PAST DUE.
**/
/*-----------------------------------------------
* Last Modified By   : Sumit Bhatt, Grazitti
* Last Modified Date : 11th Jan 2018
* Changes            : Removed the check of Count_sv__c to zero from the query at [line- 43] such that all invoices that satisfy the criteria will come in query.
                     : Added the check for creating the list of account to be updated at [line- 58] such that only those accounts will get updated in which either count_sv__c is changed or account's field SI_Payment_Past_Due__c is not correct
                     
* Last Modified Date : 15th Feb 2018
* Changes: instead of usung list to assign a query we have directly used it in a loop to avoid query time out [line 44-50]                     
---------------------------------------------------------*/
global class Schedule_Sales_Invoice implements Schedulable,Database.Batchable<sObject>{
    public List<Account> accountsWithOutstandingInvoices ;
    public Set<Id> accIds ;                             
    public boolean isGlobal = false;
    set<string> avoidDuplicates;
    
    /*public Schedule_Sales_Invoice (boolean isGenericUpdate){
        accIds                          = new Set<Id>();    
        isGlobal = isGenericUpdate;
    }*/
    public Schedule_Sales_Invoice (){
        accountsWithOutstandingInvoices = new List<Account>();
        accIds                          = new Set<Id>();    
        isGlobal = false;
    }
    public Schedule_Sales_Invoice (set<id> acctstobeprocessed){
        accIds=acctstobeprocessed;
        accountsWithOutstandingInvoices = new List<Account>();
        avoidDuplicates     = new set<string>();
    }
    global Database.QueryLocator start(Database.BatchableContext BC)
    {
        String Query= 'SELECT ID, count_SV__c,SI_Payment_Past_Due__c, (SELECT Id, Count_Invoice_Present__c, Document_Type__c, Days_Past_Due__c, Amount_Due__c FROM R00N40000001jWp9EAE__r WHERE Count_Invoice_Present__c > 0 and  Amount_Due__c >= 1000 AND Days_Past_Due__c > 30 AND Document_Type__c NOT IN (\'Revenue Recognition Activation\', \'Professional Services\',\'Rev Rec Activation UDD\') ORDER BY Days_Past_Due__c DESC) FROM Account where ID IN : accIds';
        return Database.getQueryLocator(query);
        
    }
    global void execute(SchedulableContext SC) {
        
        accountsWithOutstandingInvoices = new List<Account>();
        accIds                          = new Set<Id>();        
        /*List<Sales_Invoice__c> salesInvoices = isGlobal? new List<Sales_Invoice__c>([SELECT Id, Account__c FROM Sales_Invoice__c WHERE Count_Invoice_Present__c > 0 AND  Amount_Due__c >= 1000 AND 
                         Days_Past_Due__c > 30 AND Document_Type__c NOT in ('Revenue Recognition Activation', 'Professional Services','Rev Rec Activation UDD') AND 
                         Account__c != Null /*AND(Account__r.Count_sv__c =0 OR Account__r.Count_sv__c= null)*//* ORDER BY Days_Past_Due__c DESC] ): new List<Sales_Invoice__c>([SELECT Id, Account__c FROM Sales_Invoice__c WHERE Count_Invoice_Present__c > 0 AND  Amount_Due__c >= 1000 AND 
                         Days_Past_Due__c > 30 AND Document_Type__c NOT in ('Revenue Recognition Activation', 'Professional Services','Rev Rec Activation UDD') AND 
                         Account__c != Null  AND Payment_Due_Date__c = YESTERDAY ORDER BY Days_Past_Due__c DESC] );*/
                                  
        for(Sales_Invoice__c sv: [SELECT Id, Account__c FROM Sales_Invoice__c WHERE Count_Invoice_Present__c > 0 AND  Amount_Due__c >= 1000 AND Days_Past_Due__c > 30 AND Document_Type__c NOT in ('Revenue Recognition Activation', 'Professional Services','Rev Rec Activation UDD') AND Account__c != Null ORDER BY Days_Past_Due__c DESC])
        {
            accIds.add(sv.Account__c);
        }
        Schedule_Sales_Invoice scheduleSI = new Schedule_Sales_Invoice (accIds);
        database.executebatch(scheduleSI,200);   
    }
    
    global void execute(Database.BatchableContext BC, List<account> scope){
        //OPTIMIZE THE NUMBER OF ACCOUNT TO BE UPDATED. UPDATE ONLY IF NEEDED, OTHERWISE EXLUDE. IF WE UPDATE ALL SALES INVOICE THEN ALL ACCOUNT WILL BE UPDATED.
        for(Account ac: scope){
            if(ac.count_SV__c != ac.R00N40000001jWp9EAE__r.size() || ac.SI_Payment_Past_Due__c!=ac.R00N40000001jWp9EAE__r[0].Days_Past_Due__c){ 
               if(!avoidDuplicates.contains(ac.Id)){
                   ac.count_SV__c = ac.R00N40000001jWp9EAE__r.size();
                   if(ac.R00N40000001jWp9EAE__r.size() > 0){
                       ac.SI_Payment_Past_Due__c = ac.R00N40000001jWp9EAE__r[0].Days_Past_Due__c;
                   }
                   accountsWithOutstandingInvoices.add(ac);
                   avoidDuplicates.add(ac.Id);
               }
            }
        }
        if(!accountsWithOutstandingInvoices.isEmpty()) {
            DatabaseOperation.updateAccount(accountsWithOutstandingInvoices, true, true);
                //Database.SaveResult[] updatedAccounts = Database.update(accountsWithOutstandingInvoices, false);
        }
    }
    global void finish(Database.BatchableContext BC){
    }
}