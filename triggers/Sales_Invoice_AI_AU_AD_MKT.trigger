trigger Sales_Invoice_AI_AU_AD_MKT on Sales_Invoice__c (before update,after delete, after insert, after update) {
   
   //Variable declaration
   Map<Id, List <Sales_Invoice__c>> InvMap = new Map<Id, List<Sales_Invoice__c>>();
   List <Sales_Invoice__c> Inv1 = new List<Sales_Invoice__c>();
   List <Id> OppIds = new List<Id>();
   set <Id> AccAll = new set<id>();
   set <Id> AccIdsPending = new set<Id>();
   set <Id> AccIdsPaid = new set<Id>();
   integer i = 0; 
   integer j = 0; 
   DateTime curTime = datetime.now();
   //Variable declaration
   Set<ID> AccntID = new Set<ID>();
   Set<ID> DelAccntID = new Set<ID>();
    
    Map<id,integer> accountWithSalesInvoicesCount        = new Map<id,integer>();
    Map<id,integer> accountWithDeletedSalesInvoicesCount = new Map<id,integer>();
    List<Account> accToBeUpdatedOnSI_insert_Update     = new List<Account>();
    List<Account> accToBeUpdatedOnSIDelete = new List<Account>();
    
    if(!(SalesTriggersUtility.marketoTriggerManager.Deactivate_Sales_Invoice_Triggers__c)){
     if(trigger.isAfter){
         if( Trigger.IsUpdate || Trigger.isInsert){  
            
            for (Sales_Invoice__c s : trigger.new) {
                
                if(s.Account__c !=null) AccntID.add(s.Account__c );//for outstanding invoices
                
                AccAll.add(s.Account__r.Id);//Existing code
                if (s.Payment_Status__c == 'Approved' || s.Payment_Status__c == 'Partially Paid') {
                    AccIdsPending.add(s.Account__r.Id);
                } else {
                    AccIdsPaid.add(s.Account__r.Id);
                }
                if (trigger.isUpdate){
                    if (s.Document_Type__c <> 'Revenue Recognition Activation' && s.Last_Payment_Date__c <> trigger.old[i].Last_Payment_Date__c) {
                       OppIds.add(s.Opportunity__c);
                    }
                } else
                if (trigger.isInsert){
                    if (s.Document_Type__c <> 'Revenue Recognition Activation') {
                       OppIds.add(s.Opportunity__c);
                    }
                }
                i++;
            }
            
            for(Id accid1 :AccAll){
                for (Sales_Invoice__c s1 : trigger.new){
                    if (accid1 == s1.Account__r.Id) {
                       Inv1.add(s1);
                    }
                }
                InvMap.put(accid1,Inv1);
                Inv1.clear();
            }        
            
            for(Account insrtAcct:[SELECT ID,count_SV__c,Name,SI_Payment_Past_Due__c,(SELECT Id,Count_Invoice_Present__c, Name, Reference_Number__c, Billing_Frequency__c, Opportunity__c, Opportunity__r.Name,
                Payment_Status__c, Date__c, Payment_Due_Date__c, Days_Past_Due__c, Terms__c, Amount_Due__c, Total__c 
                FROM R00N40000001jWp9EAE__r WHERE Count_Invoice_Present__c >0 and  Amount_Due__c >= 1000 AND Days_Past_Due__c > 30 AND 
                Document_Type__c NOT in ('Revenue Recognition Activation', 'Professional Services','Rev Rec Activation UDD') ORDER BY Days_Past_Due__c DESC) FROM ACCOUNT WHERE ID IN :AccntID])
            {
                insrtAcct.SI_Payment_Past_Due__c = null;
                if(insrtAcct.R00N40000001jWp9EAE__r.size() > 0){
                insrtAcct.SI_Payment_Past_Due__c = insrtAcct.R00N40000001jWp9EAE__r[0].Days_Past_Due__c;   
                }
                insrtAcct.count_SV__c = insrtAcct.R00N40000001jWp9EAE__r.size();
                accToBeUpdatedOnSI_insert_Update.add(insrtAcct);
                
            }        
            /**Update the account with the number of outstanding invoices meeting criteria--Ends**/
        }
         if( Trigger.IsDelete ){
         
            for(Sales_Invoice__c si: trigger.old){
                if(si.Account__c !=null) DelAccntID.add(si.Account__c );
            }
            for(Account delAcct:[SELECT ID,count_SV__c,NAme,SI_Payment_Past_Due__c,(SELECT Id,Count_Invoice_Present__c, Name, Reference_Number__c, 
                Billing_Frequency__c, Opportunity__c, Opportunity__r.Name,
                Payment_Status__c, Date__c, Payment_Due_Date__c, Days_Past_Due__c, Terms__c, Amount_Due__c, Total__c 
                FROM R00N40000001jWp9EAE__r WHERE Count_Invoice_Present__c >0 and  Amount_Due__c >= 1000 AND Days_Past_Due__c > 30 AND 
                Document_Type__c NOT in ('Revenue Recognition Activation', 'Professional Services','Rev Rec Activation UDD') ORDER BY Days_Past_Due__c DESC) FROM ACCOUNT WHERE ID IN :DelAccntID])
            {
                    delAcct.SI_Payment_Past_Due__c = null;
                    if(delAcct.R00N40000001jWp9EAE__r.size() > 0){
                        delAcct.SI_Payment_Past_Due__c = delAcct.R00N40000001jWp9EAE__r[0].Days_Past_Due__c;   
                    }
                    delAcct.count_SV__c = delAcct.R00N40000001jWp9EAE__r.size();
                    accToBeUpdatedOnSIDelete.add(delAcct);
            }        
            
            for (Sales_Invoice__c s : trigger.old){
                if (trigger.old[j].Document_Type__c <> 'Revenue Recognition Activation') {
                    OppIds.add(trigger.old[j].Opportunity__c);
                }
                j++;
            }    
        }     
        
        // Update Last Payment Date on Opportunity
        if (!UpdOppFromSalesInv.OSIFirstPass && !OppIds.isEmpty()){
            try{
                UpdOppFromSalesInv.updateLatestPaymentDate(OppIds);
                UpdOppFromSalesInv.OSIFirstPass = True;
            }catch(Exception e){
                Utility.sendEcxeptionMailToDeveloper(e, System.Label.Developer_Email, (string)OppIds[0]);
            }
            
        }
        
        //DML Operations 
        if(!accToBeUpdatedOnSIDelete.isEmpty()){
            try{
               // update accToBeUpdatedOnSIDelete;
                DatabaseOperation.updateAccount(accToBeUpdatedOnSIDelete, True, True);
            }Catch(Exception e){
                Utility.sendEcxeptionMailToDeveloper(e, System.Label.Developer_Email, (string)accToBeUpdatedOnSIDelete[0].Id);
            }
        }
        
        if(!accToBeUpdatedOnSI_insert_Update.isEmpty()){
            try{
                //update accToBeUpdatedOnSI_insert_Update;
                DatabaseOperation.updateAccount(accToBeUpdatedOnSI_insert_Update, True, True);
            }Catch(Exception e){
                Utility.sendEcxeptionMailToDeveloper(e, System.Label.Developer_Email, (string)accToBeUpdatedOnSI_insert_Update[0].Id);
            }
        }    
       
       }
        /**@@
        #HANDLER CLASS NAME    :    TriggerInt_Invoice_Handler
        #HELPER CLASS NAME     :    TriggerInt_Invoice_Helper
        #DESCRIPTION           :    This Trigger will handles all the trigger events and make call to the Handler class to handling the appropriate logic.
        #DESIGNED BY           :    Jade Global
        @@**/
        if(Trigger.isAfter &&  Trigger.isUpdate){
            system.debug('@@@Inside Trigger@@@');
             //TriggerInt_Invoice_Handler.MapFieldsAndPublishIntegrationPlatformEvent(trigger.new,trigger.oldmap);
             TriggerInt_Invoice_Handler.afterUpdateHandler(trigger.new, trigger.newMap, trigger.old, trigger.oldMap);
            //Finalcial Force Sales Invoice Logic comes here..AWAITING FOR A PROCESS.....
        }
        else if(Trigger.isbefore &&  Trigger.isUpdate){
           
            TriggerInt_Invoice_Handler.beforeUpdateHandler(trigger.new,trigger.newMap,trigger.old,trigger.oldmap);
             
        }
    }
}