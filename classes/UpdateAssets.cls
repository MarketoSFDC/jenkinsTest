public class UpdateAssets {

    public static Boolean haveupdatedAccounts = false;
    public static Boolean haveupdatedAssets   = false;

    public static void updateAddOnAssetsNameAndStatus(List <Asset> triggerNew){

        List <Asset> ast_list = new List <Asset>();
        for (Asset ast: [SELECT Id, Add_On_Product__c, Parent_instance__r.Acct_Prefix__c, Status, Name,
            Asset.Product2.name, Asset_type__c, Parent_Instance__c, Parent_Instance__r.Status FROM Asset WHERE
            Parent_Instance__c IN: triggerNew AND 
            (Parent_Instance__r.Status = 'Active' OR Parent_instance__r.Acct_Prefix__c != null) AND (InstallDate >=TODAY AND UsageEndDate <= TODAY )])
        {  
            if (ast.Parent_instance__r.Acct_Prefix__c != null) ast.name = ast.Parent_instance__r.Acct_Prefix__c + ' ' + ast.Add_On_Product__c;
            if(ast.Parent_Instance__r.Status == 'Active') ast.Status = 'Active';
                 
            ast_list.add(ast);          
        }
        system.debug('ast_list====================='+ast_list );
        if (!ast_list.isEmpty()) {
            try{ update ast_list;}catch(Exception e){ triggerNew[0].addError(e.getMessage());}
        }
    }
       
    public static void updateRelatedAsset_On_OLI(List <Asset> triggerNew) {
        List<Id> newOpIds = new List <Id>();
        List<Id> opIds    = new List <Id>();
        Map<String, Id> assetWithProductInfo = new Map <String, Id>();        
        List<OpportunityLineItem> newLineItemList = new List <OpportunityLineItem>();

        for (asset a: triggerNew) {
            if(a.purpose__c!='Sandbox' && a.Add_on_product__c!='Advanced Engagement') assetWithProductInfo.put(a.Product2ID+'-'+a.Opportunity__c, a.ID);
            if(a.Opportunity__c!=null) opIds.add(a.Opportunity__c);
            if(a.Latest_Opportunity__c!=null) newOpIds.add(a.Latest_Opportunity__c);
        }
        
        /** --**/
        newOpIds.addAll(opIds);        
        if(newOpIds.isEmpty()) return;        
        
        for(OpportunityLineItem newoli: [SELECT ID, OpportunityId, Pricebookentry.Product2ID,
                                         Related_asset__c FROM OpportunityLineItem WHERE OpportunityID In: newOpIds AND Related_asset__c=null])
        {
            if(assetWithProductInfo.containsKey(newoli.Pricebookentry.Product2ID+'-'+newoli.OpportunityId)){
                newoli.related_asset__c = assetWithProductInfo.get(newoli.Pricebookentry.Product2ID+'-'+newoli.OpportunityId);
                newLineItemList.add(newoli);
            }
        }
        
        if (!newLineItemList.isEmpty()) {
           try{ update newLineItemList;}catch(Exception e){ triggerNew[0].addError(e.getMessage());}
        }        
    }

    public static List<String> getPicklistValues(String ObjectApi_name, String Field_name) {
        List <String> lstPickvals = new List <String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(ObjectApi_name); //From the Object Api name retrieving the SObject
        Sobject Object_name = targetType.newSObject();
        Schema.sObjectType sobject_type = Object_name.getSObjectType(); //grab the sobject that was passed
        Schema.DescribeSObjectResult sobject_describe = sobject_type.getDescribe(); //describe the sobject
        Map <String, Schema.SObjectField > field_map = sobject_describe.fields.getMap(); //get a map of fields for the passed sobject
        List <Schema.PicklistEntry > pick_list_values = field_map.get(Field_name).getDescribe().getPickListValues(); //grab the list of picklist values for the passed field on the sobject
        for (Schema.PicklistEntry a: pick_list_values) { //for all values in the picklist list
            lstPickvals.add(a.getValue()); //add the value  to our final list
        }
        return lstPickvals;
    }
    
    /**CODE MODIFIED BY GRAZITTI TO AOUTPOPULATE PRODUCTS INFO ON ACCOUNT**/
    public static void updateAccount(List<Asset> triggerNew) {
    
        List <Account> accountsTobeUpdated = new List <Account>();
        Set<Id> accountIds  = new Set<Id>();        
        String PF_SERVICES  = SBQQContractAndSubscriptionTriggerHelper.PF_SERVICES;
        String PF_EDUCATION = SBQQContractAndSubscriptionTriggerHelper.PF_EDUCATION;
        String PF_SUPPORT   = SBQQContractAndSubscriptionTriggerHelper.PF_SUPPORT;
        String P_MA         = SBQQContractAndSubscriptionTriggerHelper.P_MA;
        String P_RTP        = SBQQContractAndSubscriptionTriggerHelper.P_RTP;
        String PF_PRODUCT   = SBQQContractAndSubscriptionTriggerHelper.PF_PRODUCT;
         
        String objectAPIName = 'Account';
        String fieldAPIname  = 'Product_Editions__c';  
        List <String> accountProdEditions = getPicklistValues(objectAPIName, fieldAPIname);     
        
        Map<Id,Account> AcctAssetDBSize = new Map<Id, Account>();
        for (asset a: triggerNew){
            accountIds.add(a.AccountId);                      
        }        

         for(Account acc : [SELECT Id,  Add_On_Products__c, Support_level1__c, PRODUCT_EDITIONS__c, MA_Edition__c, RTP_Suite__c, Add_On_Subscriptions__c, Services__c, Support__c ,
                          (SELECT ID, SBQQ__Contract__c, SBQQ__Account__r.ID, SBQQ__Product__c, SBQQ__Product__r.Name, SBQQ__Product__r.MA_or_RTP__c, SBQQ__Product__r.Family, SBQQ__Product__r.Visible_To_Customer__c FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__r.Visible_To_Customer__c = True AND SBQQ__EndDate__c >= TODAY Limit 100),
                          (SELECT ID,Asset_type__c,Purpose__c, Add_On_Product__c, NAME, STATUS, Subscription_type__c,   Product2.Family, Product2.Name, Product2.Visible_To_Customer__c, Maximum_Database_Size__c FROM ASSETS where status != 'Expired' AND Purpose__c like '%Production%' AND Asset_Type__c!= 'Add On' ORDER by Maximum_Database_Size__c DESC NULLS LAST Limit 1000),
                          (SELECT Name, ID, Status, Entitlement_Status__c, Type FROM Entitlements WHERE Entitlement_Status__c != 'Expired' LIMIT 100),
            (SELECT Id, CreatedDate, Total_Contact_Records__c FROM Contracts WHERE SBQQ__ActiveContract__c = 1ORDER BY Createddate DESC , Total_Contact_Records__c DESC NULLS LAST LIMIT 1),Name 
                          FROM Account WHERE ID IN: accountIds]) 
        {
            List<Contract> ContrList = new List<Contract>();
            Decimal ContractDBSize = 0;
            if(acc.Contracts != null ){
                ContrList = acc.Contracts;
                for(Contract ct : acc.Contracts){
                    ContractDBSize = (ct.Total_Contact_Records__c != null && ct.Total_Contact_Records__c != 0)?ct.Total_Contact_Records__c:0;
                }
            }
      
      
            String edition = '';
            String add_On = '';
            acc.Product_Editions__c = '';
            acc.Add_on_products__c = '';
            acc.support_level1__c = '';
            
            acc.MA_Edition__c           = '';
            acc.RTP_Suite__c            = '';
            acc.Add_On_Subscriptions__c = '';
            acc.Services__c             = '';
            acc.Support__c              = '';
            
            //PROCESS SUBSCRIPTION TO POPULATE SERVICES/EDUCATION PRODUCT ON ACCOUNT
            for(SBQQ__Subscription__c subscription : acc.SBQQ__Subscriptions__r) {
                //BASED ON PRODUCT IS MA OR RTP
                if(subscription.SBQQ__Product__r.MA_or_RTP__c == P_MA) {
                    if(acc.MA_Edition__c != '') {
                        acc.MA_Edition__c = acc.MA_Edition__c+';\n'+subscription.SBQQ__Product__r.Name;
                    }else{
                        acc.MA_Edition__c = subscription.SBQQ__Product__r.Name;
                    }
                
                }else if(subscription.SBQQ__Product__r.MA_or_RTP__c == P_RTP) {
                    if(acc.RTP_Suite__c != '') {
                        acc.RTP_Suite__c = acc.RTP_Suite__c+';\n'+subscription.SBQQ__Product__r.Name;
                    }else{
                        acc.RTP_Suite__c = subscription.SBQQ__Product__r.Name;
                    }
                }
                //BASED ON PRODUCT FAMILY
                if(subscription.SBQQ__Product__r.Family == PF_PRODUCT){
                    if(acc.Add_On_Subscriptions__c != ''){
                        acc.Add_On_Subscriptions__c = acc.Add_On_Subscriptions__c+';\n'+subscription.SBQQ__Product__r.Name;
                    }else{
                        acc.Add_On_Subscriptions__c = subscription.SBQQ__Product__r.Name;
                    } 
                }else if(subscription.SBQQ__Product__r.Family == PF_SERVICES || subscription.SBQQ__Product__r.Family == PF_EDUCATION ) {
                    if(acc.Services__c != ''){
                        acc.Services__c = acc.Services__c+';\n'+subscription.SBQQ__Product__r.Name;
                    }else{
                        acc.Services__c = subscription.SBQQ__Product__r.Name;
                    }  
                }else if(subscription.SBQQ__Product__r.Family == PF_SUPPORT) {
                    if(acc.Support__c != ''){
                        acc.Support__c = acc.Support__c+';\n'+subscription.SBQQ__Product__r.Name;
                    }else{
                        acc.Support__c = subscription.SBQQ__Product__r.Name;
                    }
                }
            }
            
            //PROCESS ASSETS TO POPULATE PRODUCT INFORMATION ON ACCOUNT
            for(asset a: acc.Assets) {                        
                if(a.Product2.Visible_To_Customer__c == True) {
                    if(a.Product2.Family == PF_SERVICES || a.Product2.Family == PF_EDUCATION ) {
                        if(acc.Services__c != ''){
                            acc.Services__c = acc.Services__c+';\n'+a.Product2.Name;
                        }else{
                            acc.Services__c = a.Product2.Name;
                        }                        
                    }
                    else if(a.Product2.Family == PF_SUPPORT){
                        if(acc.Support__c != ''){
                            acc.Support__c = acc.Support__c+';\n'+a.Product2.Name;
                        }else{
                            acc.Support__c = a.Product2.Name;
                        }
                    }                
                }       
                
                if(a.Purpose__c != 'Sandbox') {                
                    if (a.subscription_type__c != null) {
                        if (a.subscription_type__c == 'SMB Spark' ||
                            a.subscription_type__c == 'SMB Select' ||
                            a.subscription_type__c == 'SMB Standard') {
                            a.subscription_type__c = a.subscription_type__c.substring(4);
                        }
                        for (string s: accountProdEditions) {
                            if (s.containsignorecase(a.subscription_type__c)){
                                if(!edition.containsIgnoreCase(s)) edition = edition + ';' + s;
                            }
                        }
                    }
                    system.debug('edition' + edition+'=='+a.subscription_type__c+'---'+a.Id);
                    if (a.Asset_type__c == 'Add On') {
                        if (a.Add_on_Product__c != null){
                            if (!add_On.containsignorecase(a.Add_on_Product__c)) {
                                add_On = add_On + ';' + a.Add_on_Product__c;
                            }
                        }
                    }
                }
            }
            
             
            if (edition != null) acc.Product_editions__c = edition;
            if (add_On != null)  acc.Add_on_Products__c  = add_On;

            for (Entitlement e: acc.Entitlements) {                
                if (e.Type == null) {
                    e.Type = '';
                }
                if (acc.support_level1__c == null || acc.support_level1__c == '') {
                    acc.support_level1__c = '';
                }
                if (!acc.support_level1__c.containsignorecase(e.type)) {
                    acc.support_level1__c = acc.support_level1__c + ';' + e.type + ' ;';                   
                }
            }            
            system.debug(edition+'<==edition::Add_On ===>'+Add_On+'acc.support_level1__c==>'+acc.support_level1__c);
            
            Decimal DB_Size = 0;
            if(acc.Assets != null && !acc.Assets.isEmpty()){
                DB_Size = acc.Assets[0].Maximum_Database_Size__c;
            }
            if(DB_Size != null && DB_Size != 0){
                acc.Gainsight_Database_Size__c = DB_Size;
            }else{
                acc.Gainsight_Database_Size__c = ContractDBSize;
            }
            accountsTobeUpdated.add(acc);           
        }
        
        if(!AcctAssetDBSize.isEmpty()){
            accountsTobeUpdated.addAll(AcctAssetDBSize.values());
        }
        
        if (!accountsTobeUpdated.isEmpty()) { 
            try{ DatabaseOperation.updateAccount(accountsTobeUpdated, true, true);} catch(Exception e){ triggerNew[0].addError(e);} 
        }
    }
    
    public static void updateEntitlementStartdate(Map < ID, Asset > triggerNewmap) {
        Map <Asset, List <Entitlement>> Asset_entitlement_map = new map <Asset, List <Entitlement>>();
        List <Entitlement> ent_list = new List <Entitlement > ();

        for(entitlement e: [SELECT Name, StartDate, Processed_for_grace__c, Status, Has_been_Replaced__c, AssetID, EndDATE FROM Entitlement
            WHERE AssetID IN: triggerNewmap.Keyset()]) 
        {             
            if(e.Status =='Expired'){
                 if(e.Has_been_Replaced__c){
                     //nothing...
                }else{
                   e.EndDate = triggerNewmap.get(e.AssetId).UsageEnddate;  
                   e.Processed_For_grace__c = FALSE;
                   e.Subscription_End_Date__c = e.EndDate;
                }           
            }else{
                system.debug(triggerNewmap.get(e.AssetId).UsageEnddate+'status-->');
                if(triggerNewmap.get(e.AssetId).UsageEnddate >= Date.Today()){                
                    e.EndDate = triggerNewmap.get(e.AssetId).UsageEnddate;  
                    e.Processed_For_grace__c = FALSE;
                    e.Subscription_End_Date__c = e.EndDate;        
                }else if(!e.Processed_For_grace__c){
                    e.EndDate = triggerNewmap.get(e.AssetId).UsageEnddate;  
                    e.Processed_For_grace__c = FALSE;
                    e.Subscription_End_Date__c = e.EndDate;
                }
            }
            ent_list.add(e);
        }
        
        if (!ent_list.isempty()) {
            try{ update ent_list;}catch(Exception e){
                if(e.getMessage().contains('FIELD_INTEGRITY_EXCEPTION')){
                    triggerNewmap.values()[0].addError(': The End Date of Asset must be greater than Start Date of related Entitlements');
                }else{
                    triggerNewmap.values()[0].addError(e.getMessage());   
                }            
            }            
        }
    }
  
}