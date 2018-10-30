/**
- GENERIC CLASS THAT RECIEVE CALLS FROM CONTRACT, SUBSCRIPTION, OPPRTUNITY, ASSET AND ENTITLEMENT
- PERFORM OPERATION BASED ON CALLED PARENT ROUTINE
- DEVELOPED BY: GRAZITTI
**/
public class SBQQContractAndSubscriptionTriggerHelper {
    
    public static String P_MA         = 'MA';
    public static String P_RTP        = 'RTP';
    public static String PF_PRODUCT   = 'Product';
    public static String PF_SERVICES  = 'Services';
    public static String PF_EDUCATION = 'Education';
    public static String PF_SUPPORT   = 'Support';    
        
    public static void updateProductInfoOnAccountORDatabaseSize(Set<Id> accIdsForProductInfo, Map<Id, Decimal> accIdsForGiansightDBSizeMap){
         Map<Id, Account> updateAccountMap = new  Map<Id,Account>();
         accIdsForProductInfo.addAll(accIdsForGiansightDBSizeMap.keySet());//CONSOLIDATE THE ACCOUNT IDS
         if(!accIdsForProductInfo.isEmpty()){
             updateAccountMap = updateAccountRecMap(accIdsForProductInfo, accIdsForGiansightDBSizeMap);
         }
       
         if(!updateAccountMap.isEmpty()){    
            try{ DatabaseOperation.updateAccount(UpdateAccountMap.Values(), true, true); }catch(Exception e){}
         }
    }
    
    public static Map<Id,Account> populateGainsightDatabaseSize(Map<Id, Decimal> accIdsForGiansightDBSizeMap, Map<Id, Account> updateAccountMap){
        Map<Id, Decimal> assetWithGainsightDatabaseSize = new Map<Id, Decimal>();
        for(Asset ast: [SELECT Id, Maximum_Database_Size__c, AccountId FROM Asset WHERE AccountId IN: accIdsForGiansightDBSizeMap.keySet() AND Maximum_Database_Size__c!= null ORDER BY CreatedDate ASC]){
            assetWithGainsightDatabaseSize.put(ast.AccountId, ast.Maximum_Database_Size__c);
        }
        
        for(Id currentAccId : accIdsForGiansightDBSizeMap.keySet()){
            Account ac = updateAccountMap.containsKey(currentAccId)?updateAccountMap.get(currentAccId):new Account(Id = currentAccId);
            ac.Gainsight_Database_Size__c = assetWithGainsightDatabaseSize.containsKey(currentAccId)?assetWithGainsightDatabaseSize.get(currentAccId):accIdsForGiansightDBSizeMap.get(currentAccId);
            updateAccountMap.put(ac.Id, ac);
        }
        return updateAccountMap;
    }
    
    /**UPDATE ACCOUNT BASED ON SUBSCRIPTION AND ASSET--CALLED FROM SUBSCRIPTION TRIGGER**/
    public static void updateAccountRec(Set<ID> AccIds, List<SBQQ__Subscription__c> newSubcription){
         Map<Id,Account> UpdateAccountMap = new  Map<Id,Account>();
         UpdateAccountMap = updateAccountRecMap(AccIds, new Map<Id, Decimal>());
        
        if(UpdateAccountMap!=null && !updateAccountMap.isEmpty()){    
            try{
                DatabaseOperation.updateAccount(UpdateAccountMap.Values(), true, true);
            }
            catch(Exception e){
                for(SBQQ__Subscription__c sa : newSubcription){
                    System.Debug('******EXCEPTION*********'+e.getMessage());
                    sa.addError('Got an Exception');
                }                
            }
        }        
    }
    
    public static Map<Id,Account> updateAccountRecMap(Set<ID> AccIds, Map<Id, Decimal> accIdsForGiansightDBSizeMap){
                
        Map<ID,Account> accountMap = new Map<ID,Account>();
       
        for(Account ac : [Select Id, Name, MA_Edition__c, RTP_Suite__c, Add_On_Subscriptions__c, Services__c, Support__c ,
                         (Select ID, SBQQ__Contract__c, SBQQ__Account__r.ID, SBQQ__Product__c, SBQQ__Product__r.Name, SBQQ__Product__r.MA_or_RTP__c, SBQQ__Product__r.Family, SBQQ__Product__r.Visible_To_Customer__c
                         FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__r.Visible_To_Customer__c = True AND SBQQ__EndDate__c >= TODAY Limit 1000),
                         (Select Id, Maximum_Database_Size__c, Product2.Family, Product2.Name, Product2.Visible_To_Customer__c FROM Assets WHERE Status != 'Expired' Limit 100), 
                         (SELECT Id, Total_Contact_Records__c FROM Contracts WHERE Total_Contact_Records__c != null AND SBQQ__ActiveContract__c = 1 ORDER BY Total_Contact_Records__c DESC LIMIT 1)
                         FROM Account WHERE Id IN: AccIds])
        {
        
            ac.MA_Edition__c           = '';
            ac.RTP_Suite__c            = '';
            ac.Add_On_Subscriptions__c = '';
            ac.Services__c             = '';
            ac.Support__c              = '';
            Boolean updateAccount = false;
            
            for(SBQQ__Subscription__c subscription : ac.SBQQ__Subscriptions__r) {
            
                if(subscription.SBQQ__Product__r.MA_or_RTP__c == P_MA) {
                    if(ac.MA_Edition__c != '') {
                        ac.MA_Edition__c = ac.MA_Edition__c+';\n'+subscription.SBQQ__Product__r.Name;
                    }else{
                        ac.MA_Edition__c = subscription.SBQQ__Product__r.Name;
                    } 
                    updateAccount = true;               
                }else if(subscription.SBQQ__Product__r.MA_or_RTP__c == P_RTP) {
                    if(ac.RTP_Suite__c != '') {
                        ac.RTP_Suite__c = ac.RTP_Suite__c+';\n'+subscription.SBQQ__Product__r.Name;
                    }else{
                        ac.RTP_Suite__c = subscription.SBQQ__Product__r.Name;
                    }
                    updateAccount = true;
                }
                
                if(subscription.SBQQ__Product__r.Family == PF_PRODUCT){
                    if(ac.Add_On_Subscriptions__c != ''){
                        ac.Add_On_Subscriptions__c = ac.Add_On_Subscriptions__c+';\n'+subscription.SBQQ__Product__r.Name;
                    }else{
                        ac.Add_On_Subscriptions__c = subscription.SBQQ__Product__r.Name;
                    } 
                    updateAccount = true;
                }else if(subscription.SBQQ__Product__r.Family == PF_SERVICES || subscription.SBQQ__Product__r.Family == PF_EDUCATION) {
                    if(ac.Services__c != ''){
                        ac.Services__c = ac.Services__c+';\n'+subscription.SBQQ__Product__r.Name;
                    }else{
                        ac.Services__c = subscription.SBQQ__Product__r.Name;
                    } 
                    updateAccount = true; 
                }else if(subscription.SBQQ__Product__r.Family == PF_SUPPORT) {
                    if(ac.Support__c != ''){
                        ac.Support__c = ac.Support__c+';\n'+subscription.SBQQ__Product__r.Name;
                    }else{
                        ac.Support__c = subscription.SBQQ__Product__r.Name;
                    }
                    updateAccount = true;
                }                
            }
            
            //PROCESS ASSETS
            Decimal maxDbSize = 0;
            for(Asset asst : ac.Assets) {
                if(asst.Product2.Visible_To_Customer__c == True){
                    if(asst.Product2.Family == PF_SERVICES || asst.Product2.Family == PF_EDUCATION) {
                        if(ac.Services__c != ''){
                            ac.Services__c = ac.Services__c+';\n'+asst.Product2.Name;
                        }else{
                            ac.Services__c = asst.Product2.Name;
                        }  
                        updateAccount = true;
                    }else if(asst.Product2.Family == PF_SUPPORT) {
                        if(ac.Support__c != ''){
                            ac.Support__c = ac.Support__c+';\n'+asst.Product2.Name;
                        }else{
                            ac.Support__c = asst.Product2.Name;
                        }
                        updateAccount = true;
                    }
                }  
                if(accIdsForGiansightDBSizeMap.containsKey(ac.Id) && asst.Maximum_Database_Size__c!= null){
                    maxDbSize = asst.Maximum_Database_Size__c>maxDbSize?asst.Maximum_Database_Size__c:maxDbSize;
                }                              
            } 
            if(maxDbSize == 0 && ac.Contracts != null && ac.Contracts .size()>0){
                maxDbSize = ac.Contracts[0].Total_Contact_Records__c;
            } 
            
            if(maxDbSize != 0 && ac.Gainsight_Database_Size__c != maxDbSize){
                ac.Gainsight_Database_Size__c = maxDbSize;
                updateAccount = true;
            }                                 
            
            if(updateAccount){
                accountMap.put(ac.Id, ac);
            } 
        }
        
        if(!accountMap.isEmpty()){
            return accountMap;
        }else{
            return accountMap;
        }
        
    }
   
       
}