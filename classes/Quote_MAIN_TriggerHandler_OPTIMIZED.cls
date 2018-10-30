/* *******************************************************************************************************
Last Modified By: Jade Global Inc, on 8th September 2018
Purpose         : To handle Phoenix Provisioning Scenarios
				  Removed closedWonRecordTypeId of class Trigger_Opportunity_Helper  variable from class
******************************************************************************************************** */
public class Quote_MAIN_TriggerHandler_OPTIMIZED{
    
    //RECURSIONHANDLER'S CREW
    public static Boolean isBeforeInsertCompleted = false;
    public static Boolean isBeforeUpdateCompleted = false;
    public static Boolean isAfterInsertCompleted  = False;
    public static Boolean isAfterUpdateCompleted  = False;
    public static Boolean isAfterDeleteCompleted  = False;
    
    static boolean isCaseStudyPermissionOnAccount_done = false;
    
    public static Id SMBRecTypeId = Schema.SObjectType.Quote.getRecordTypeInfosByName().get('SMB').getRecordTypeId();
    
    //************ BEFORE HANDLERS STARTS ******************//
    public static void isBeforeInsertHandler(List<Quote> newTrigger) {
        if(isBeforeInsertCompleted) return;
        isBeforeUpdateCompleted = true;
        
        for(Quote qote: newTrigger){
            qote = updateQuoteNotesForSMB(qote);
            qote = updateOpportunityOwnerManager(qote);
        }//END OF FOR LOOP QUOTE
        
    }//END OF METHOD ISBEFOREINSERTHANDLER
    
    public static void isBeforeUpdateHandler(List<Quote> newTrigger, Map<Id, Quote> newTriggerMap, Map<Id, Quote> oldTriggerMap) {
        if(isBeforeUpdateCompleted) return;
        isBeforeUpdateCompleted = true;
        
        for(Quote qote: newTrigger){
            qote = updateQuoteNotesForSMB(qote);
            qote = updateOpportunityOwnerManager(qote);
        }//END OF FOR LOOP QUOTE
        
    }//END OF METHOD isBeforeUpdateHandler
    
    //************ BEFORE HANDLERS ENDS *******************//
    
    //************ AFTER HANDLERS STARTS******************//
    public static void isAfterInsertHandler(List<Quote> newTrigger, Map<id,Quote> newTriggerMap) {
        if(isAfterInsertCompleted) return;
        isAfterInsertCompleted  = true;
        
        for(Quote qt : newTrigger){
            oppIDs.add(qt.OpportunityID);
            caseStudyPermissionOnAccount(qt);
        }//END OF FOR LOOP QUOTE      
        
        /**-- POPULATE CASE STUDY PERMISSION CHECKBOX ON ACCOUNT **/
        caseStudyPermissionOnAccount();
        
        /**-- TRIGGER: "QuoteAftInsB4Upd". DEACTIVATING THIS TRIGGER AS WE ARE DOING THE SAME OPERATION IN OPPRTUNITY TRIGGER --**/   
        quoteAftInsB4Upd_updateOppotunity(); 
        
    }//END OF METHOD ISAFTERINSERTHANDLER
    
    public static void isAfterUpdateHandler(List<Quote> newTrigger, List<Quote> oldTrigger, Map<id,Quote> newTriggerMap, Map<id,Quote> oldTriggerMap) {
        if(isAfterUpdateCompleted) return;
        isAfterUpdateCompleted = true;
        
        for(Quote qt: newTrigger){
            oppIDs.add(qt.OpportunityID);
            caseStudyPermissionOnAccount(qt);
        }//END OF FOR LOOP QUOTE    
        
        /**-- POPULATE CASE STUDY PERMISSION CHECKBOX ON ACCOUNT --**/
        caseStudyPermissionOnAccount();
        
        /**-- TRIGGER: SetApprovalRequestStatus --**/
       // SetApprovalRequestStatusController sa = new SetApprovalRequestStatusController();
        //sa.setApprovalRequestStatus(newTrigger, newTriggerMap, oldTriggerMap);
        
        /**-- TRIGGER: "QuoteAftInsB4Upd". DEACTIVATING THIS TRIGGER AS WE ARE DOING THE SAME OPERATION IN OPPRTUNITY TRIGGER --**/   
        quoteAftInsB4Upd_updateOppotunity(); 
        
    }//END OF METHOD ISAFTERUPDATEHANDLER
    
    public static void isAfterDeleteHandler(List<Quote> oldTrigger, Map<Id,Quote> oldTriggerMap) {
        if(isAfterDeleteCompleted) return;    
        isAfterDeleteCompleted = true;
        
        for(Quote qt: oldTrigger){
            caseStudyPermissionOnAccount(qt);
        }//END OF FOR LOOP QUOTE  
        
        caseStudyPermissionOnAccount();   
        
    }//END OF METHOD ISAFTERDELETEHANDLER
    
    //************ AFTER HANDLERS ENDS******************//  
    
    
    /**------------------------------------------------------------
    - HELPER METHODS START
    --------------------------------------------------------------**/
    public static Quote updateQuoteNotesForSMB(Quote qt){
         if(qt.RecordTypeId == SMBRecTypeId){
            qt.Quote_Notes__c = '';
            if(qt.Discount_Deal_Size__c != null)
                qt.Quote_Notes__c = qt.Quote_Notes__c + qt.Discount_Deal_Size__c + '<br/>';
            if(qt.Competition__c != null)
                qt.Quote_Notes__c = qt.Quote_Notes__c + qt.Competition__c + '<br/>';
            if(qt.Competitive_Reason_1__c != null)
                qt.Quote_Notes__c = qt.Quote_Notes__c + qt.Competitive_Reason_1__c + '<br/>';
            if(qt.Competitive_Reason_2__c != null)
                qt.Quote_Notes__c = qt.Quote_Notes__c + qt.Competitive_Reason_2__c + '<br/>';
            if(qt.Why_Marketo_Reason_1__c != null)
                qt.Quote_Notes__c = qt.Quote_Notes__c + qt.Why_Marketo_Reason_1__c + '<br/>';
            if(qt.Why_Marketo_Reason_2__c != null)
                qt.Quote_Notes__c = qt.Quote_Notes__c + qt.Why_Marketo_Reason_2__c + '<br/>';
            if(qt.Terms__c != null)
                qt.Quote_Notes__c = qt.Quote_Notes__c + qt.Terms__c + '<br/>';
            if(qt.When__c != null)
                qt.Quote_Notes__c = qt.Quote_Notes__c + qt.When__c;
         }//END OF IF CONDITION
         return qt;    
    }//END OF METHOD UPDATEQUOTENOTESFORSMB    
    
    public static Quote updateOpportunityOwnerManager(Quote newVersion) {
        newVersion.Opportunity_Owner_Manager__c = newVersion.Opportunity_Owner_Manager_Id__c;
        newVersion.Opportunity_Owner_AVP__c     = newVersion.Opportunity_Owner_AVP_ID__c;
        newVersion.Opportunity_Owner_SVP__c = newVersion.Opportunity_Owner_SVP_ID__c;
        newVersion.Opportunity_Owner_Sales_VP__c = newVersion.Opportunity_Owner_Sales_VP_ID__c;
        return newVersion;
    }//END OF METHOD UPDATEOPPORTUNITYOWNERMANAGER
    
    /**----
    - OLD TRIGGER: QuoteAftInsB4Upd
    - JOB:  UPDATE OPPORTUNITY Owner_Role_Mapping__c FROM OpportunityOwner
    --**/
    static set <ID> oppIDs = new set<Id>();
    public static void quoteAftInsB4Upd_updateOppotunity(){
    
        if(SalesTriggersUtility.isQuoteUpdatedFromOpportunityTrigger) return;//IF RECORD HAS ALREADY BEEN UPDATED
        
        if(!oppIDs.isEmpty()){
            Set<Id> tempIds = new Set<Id>(oppIDs);
            List<Opportunity> oppList = [select Owner_Role_Mapping__c, OwnerID from Opportunity where ID IN: oppIDs and iswon=false and StageName <> 'Closed Lost'];
            List<Opportunity> oppListToUpd = new List <Opportunity>();
            for (Opportunity op1 : oppList){
                if (op1.Owner_Role_Mapping__c <> op1.OwnerID){
                    op1.Owner_Role_Mapping__c = op1.OwnerID;
                    oppListToUpd.add(op1);
                }//END OF IF CONDITION
            }//END OF FOR LOOP OPPORTUNITY    
            
            if(!oppListToUpd.isEmpty()){
                DatabaseOperation.updateOpportunity(oppListToUpd, true, false);
            }//END OF IF CONDITION
        }//END OF IF CONDITION
    }//END OF METHOD QUOTEAFTINSB4UPD_UPDATEOPPOTUNITY
    
    static Set<ID> accIds = new Set<ID>();
    public static void caseStudyPermissionOnAccount(Quote qt){
        if(qt.AccountId != null){
            accIds.add(qt.AccountId);
        }else if(qt.Opportunity_Account_Id__c != null){
            accIds.add(qt.Opportunity_Account_Id__c);
        }//END OF ELSE IF CONDITION        
    }//END OF METHOD CASESTUDYPERMISSIONONACCOUNT
    
    public static void caseStudyPermissionOnAccount() {
    
        if(isCaseStudyPermissionOnAccount_done) return;
        isCaseStudyPermissionOnAccount_done = true;
        
        List<Account> updateAccount   = new List<Account>();
        Map<ID,Account> newAccountMap = new Map<ID,Account>();        
        Set<ID> cachedAccIdsWithFalse = new Set<ID>();
        
        try{ 
            if(accIds.isEmpty()) return;
            
            for(Opportunity opp : [Select ID,(SELECT ID FROM Quotes WHERE Case_Study_Permission__c != null Limit 1), AccountID From Opportunity Where StageName = 'Closed Won' AND AccountID IN: accIds]){
                If(!newAccountMap.ContainsKey(opp.AccountID)){
                    if(!opp.Quotes.isEmpty()){
                        Account acc = new Account(ID = opp.AccountID);
                        acc.Case_Study_Permission__c = True;    
                        newAccountMap.put(opp.AccountID,acc);
                    }else if(!newAccountMap.ContainsKey(opp.AccountID)){                        
                        Account acc = new Account(ID = opp.AccountID);
                        acc.Case_Study_Permission__c = False;
                        newAccountMap.put(opp.AccountID,acc);
                        cachedAccIdsWithFalse.add(opp.AccountID);
                    }//END OF ELSE IF CONDITION  
                }else{
                    if(!opp.Quotes.isEmpty() && cachedAccIdsWithFalse.contains(opp.AccountID)){
                        Account acc = new Account(ID = opp.AccountID);
                        acc.Case_Study_Permission__c = True;
                        newAccountMap.remove(opp.AccountID);
                        newAccountMap.put(opp.AccountID,acc);
                    }//END OF IF CONDITION  
                }//END OF ELSE CONDITION     
            }//END OF FOR LOOP OPPORTUNITY
            if(!newAccountMap.isEmpty()){
                updateAccount = newAccountMap.Values();
                DatabaseOperation.updateAccount(updateAccount, true, false);
            }//END OF IF CONDITION
        }//END OF TRY BLOCK
        Catch(Exception e){
            System.Debug('QUOTE__MAIN__TRIGGER__EXCEPTION___'+e.getMessage());
        }//END OF CATCH BLOCK    
    }//END OF METHOD CASESTUDYPERMISSIONONACCOUNT
}//END OF CLASS