/*********************************************************************
* Created by         : Priyanka Shende
* Created Date       : 21st March 2017
* Purpose            : For below validations
                       1.  If exodus opportunity assets not provisioned then while closure of the exodus future renewal opportunity then display validation message
                       2.  If on exodus opportunity migration flag is not checked then displaying validation.
                       3. If contract is not created for Exodus Opportunity then displaying validation
**********************************************************************/
public class closeWonOpportunity_Validation {
    
     public static String CLOSED_WON_OPPTY            = Label.OPPORTUNITY_STAGE_CLOSED_WON;
     public static String OPPTY_TYPE_RENEWAL          = Label.OPPORTUNITY_TYPE_RENEWAL;
     public static String OPPTY_TYPE_UPSELL_CROSSELL  = Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL;
     public static string OPPTY_TYPE_NEW_BUSINESS     = Label.OPPORTUNITY_TYPE_NEW_BUSINESS;
     public static string EXODUS_PROVI_VALIDATION     = Label.EXODUS_PROVISIONING_VALIDATION_ON_RENEWAL_CLOSE_WON;
     public static string EXODUS_OPPTY_CLOSE_WON_VAL  = Label.EXODUS_OPPTY_CLOSE_WON_VALIDATION;
     public static string OPP_TYPE_EXODUS             = Label.OPPORTUNITY_TYPE_EXODUS;
     // Exodus Close Won Opty Validation
     public static void closeWonOppProvisioningValidation(List<Opportunity> newList, Map<Id,Opportunity> oldMap){
         Set<Id> astId              = new Set<Id>();
         Set<Id> accId              = new Set <Id>();
         Set<Id> migrationAccId     = new Set<Id>();  
         set<Id> oppExoIds          = new Set <Id>();
         set<Id> ContractoppIds     = new Set <Id>();
                  
        Map<String,Exodus_Sales_Users__c> exodusSalesUsersMap = new Map<string,Exodus_Sales_Users__c>();
        
        for(Exodus_Sales_Users__c users :Exodus_Sales_Users__c.getAll().values()){
            exodusSalesUsersMap.put(users.UserId__c, users);
        }
         
         if(!newList.isEmpty()){
             for(Opportunity opp : newList){
                 if(opp.StageName == CLOSED_WON_OPPTY && oldMap.get(opp.Id).StageName != CLOSED_WON_OPPTY && opp.AccountId!=null && (opp.type==OPPTY_TYPE_UPSELL_CROSSELL || opp.type==OPPTY_TYPE_RENEWAL)) {
              accId.add(opp.AccountId);  
                 }
             }   
         }
         
         if(!accId.isEmpty()){
            // for(Asset asst : [SELECT id,Asset_Type__c,Opportunity__c,Contract__c,Contract__r.Status,Provision_Status__c,Provisioning_Type__c,AccountId FROM Asset WHERE AccountId IN : accId AND Provisioning_Type__c='Migration' AND Provision_Status__c!='Completed' AND Asset_Type__c='Instance']){
             for(Account acc:[ SELECT id,(SELECT id ,Asset_Type__c,Provisioning_Type__c FROM Assets WHERE Provisioning_Type__c='Migration' AND Provision_Status__c!='Completed' AND Asset_Type__c='Instance'),
                              (SELECT id,Migration__c FROM Opportunities WHERE Migration__c=TRUE AND Iswon=TRUE),
                              (SELECT SBQQ__Opportunity__c,id FROM Contracts WHERE Status='Activated') 
                               FROM  Account WHERE id IN :accId]){
                   if(!Acc.Assets.IsEmpty()){
                        migrationAccId.add(acc.id);
                    }//End of IF Asset block 
                    if(!acc.Opportunities.isEmpty()){
                        for(Opportunity exoOpp :acc.Opportunities){
                            oppExoIds.add(exoOpp.id);
                         }
                    }//End of IF Exodus Opportunity block   
                    if(!acc.Contracts.isEmpty()){
                        for(Contract Cont :acc.Contracts){
                            ContractoppIds.add(Cont.SBQQ__Opportunity__c);
                        }
                    }//End of IF Contract  block 
             }//End of FOR loop of Account  
         }
         if(!newList.isEmpty()){
           for(Opportunity opp : newList){
               
               if(opp.StageName == CLOSED_WON_OPPTY && oldMap.get(opp.Id).StageName != CLOSED_WON_OPPTY && ((opp.type==OPPTY_TYPE_UPSELL_CROSSELL || opp.type==OPPTY_TYPE_RENEWAL)) && opp.Prior_Opportunity__c!=null && oppExoIds.contains(opp.Prior_Opportunity__c) && !ContractoppIds.contains(opp.Prior_Opportunity__c) ) {
                   system.debug('This is in exodus opty closed won validation');
                     opp.AddError(Label.EXODUS_Prior_OPPTY_CLOSE_WON_VAL);
               }
               if(opp.StageName == CLOSED_WON_OPPTY && oldMap.get(opp.Id).StageName != CLOSED_WON_OPPTY && opp.type==OPPTY_TYPE_RENEWAL && exodusSalesUsersMap.containsKey(opp.CreatedById) && opp.Migration__c==False && (opp.Name.toUpperCase()).contains(OPP_TYPE_EXODUS)) {
                   system.debug('This is in exodus opty closed won validation');
                     opp.AddError(EXODUS_OPPTY_CLOSE_WON_VAL);
                 }
                if(opp.StageName == CLOSED_WON_OPPTY && oldMap.get(opp.Id).StageName != CLOSED_WON_OPPTY && opp.AccountId!=null && ((opp.type==OPPTY_TYPE_UPSELL_CROSSELL || opp.type==OPPTY_TYPE_RENEWAL))) {
                    
                    if(migrationAccId.contains(opp.AccountId)){
                       system.debug('This is in exodus provisioning opty closed won validation');
                        opp.AddError(EXODUS_PROVI_VALIDATION);
                    }
             }
             }//End of newList Opty For
         }//End Of newList empty If
    }
    
    
   
}