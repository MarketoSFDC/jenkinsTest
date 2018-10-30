/**@@
    #ABOUT ME: I AM UTILITY CLASS THAT IS USED TO CREATE ASSET, ENTITLEMENT, AUTHORIZED CONTACT.
    #REFERENCED IN: APEX CLASS: "Trigger_Opportunity_Handler".
    #MANAGED BY: GRAZITTI  
@@**/      
public class NEWCreateAssetsAndEntitlements {
    
    /**GLOBAL DECLARATION OF COLLECTION USED**/
    private static List<Asset> listOfAssets;
    private static List<Entitlement> newEntitlementList; 
    private static List<Opportunity> oppAndAccount; 
    private static List<Asset> subscripAsset; 
    private static List<Entitlement> deafultEntitlementInfo = new List<Entitlement>();
    private static List<Opportunity> currentOpp = new List<Opportunity>();  
    private static List<Product2> sandboxProductId = new List<Product2>(); 
    private static List<Authorized_Contact__c> listOfAuthorizedContact; 
    private static List<Entitlement> premiumEntitlement; //New Code: Premium Catalog enablement in LMS
    private static Map<String, Asset> oppAssetsMap;  
    private static Map<String, id> eprocessMap;    
    private static Map<String, id> businessHoursMap;
    private static Map<Id, Entitlement> existingEntitlementsMap;
    private static Map<Id, Id> lineItemWithRelatedAssetMap;
    private static Map<Id, Asset> relatedAssetMap;
    private static Map<Id, Entitlement> entitlementWithRelatedAssetMap;
    private static Map<Id, Authorized_Contact__c> existingAuthContactMap;
       
    /**GLOBAL INITIALIZATION OF VARIABLES**/
    public static Boolean allowAssetAndEntitlementCreator = true;
	 public static Boolean allowAccountUpdateonAssetCreation = false;
    public static Boolean updateAssetAndEntitlementInfoOnAccount = false;//SET A FLAG IF WE NEED TO UPDATE ASSET AND ENETITLEMENT INFO ON ACCOUNT
    static Asset ass; 
    static Entitlement rawEntitlement;    
    static String  OpportunityID;  
    static Boolean hasREGULAR = false; 
    static Boolean hasSPARK = false; //If any product name contains spark then change the type of default entitlement from standard.
    static Boolean haveOppAddOnProdOnly = true;//true if Opportunty have only Add-On Product.
    static string  REPLACEMENTINSTANCE = 'Replacement Instance';//if deal type is Replacement Instance; no entitlement will be created.
            
    public static List<Product2> getsandboxProductId(){
        if(sandboxProductId != null && sandboxProductId.isEmpty()){
            sandboxProductId = [SELECT id, name FROM Product2 WHERE ProductCode = 'LM-SAND'];
        }
        return sandboxProductId;
    }
    
    public static Map <String, Id> geteprocessMap(){
        if(eprocessMap.isEmpty()){
            for (SlaProcess sla: [SELECT Id, Name FROM SlaProcess WHERE Name = 'Standard Support' OR Name = 'Partner Support' 
                            OR Name = 'Spark Support' OR Name = 'Premier Support' OR Name = 'Elite Support' OR Name = 'Business Support' LIMIT 10]){
                eprocessMap.put(sla.name, sla.id);
            }
        }
        return eprocessMap;
    }
    
    public static Map<String,Id> getbusinessHoursMap(){
        if(businessHoursMap.isEmpty()){
            for (BusinessHours bh: [SELECT id, Name FROM BusinessHours LIMIT 100]) {
                businessHoursMap.put(bh.name, bh.id);
            }
        }
        return businessHoursMap;
    }
    
    public static void createAssetWithEntitlement(Opportunity currentProcessedOpp){
    
        /**DECLARE VARIABLES**/       
        listOfAssets        = new List<Asset>();
        newEntitlementList  = new List<Entitlement>();
        oppAssetsMap        = new Map<String, Asset>();
        eprocessMap         = new Map<String, Id>();
        businessHoursMap    = new Map<String, Id>();
        existingEntitlementsMap = new Map <Id, Entitlement>();
        lineItemWithRelatedAssetMap = new Map <Id, Id>();
        relatedAssetMap  = new Map <Id, Asset>();
        entitlementWithRelatedAssetMap = new Map <Id, Entitlement> ();
        listOfAuthorizedContact = new list<Authorized_Contact__c> ();
        existingAuthContactMap          = new Map<Id, Authorized_Contact__c> ();
        OpportunityID    = currentProcessedOpp.Id;
        currentOpp.add(currentProcessedOpp);       
        
        premiumEntitlement = new List<Entitlement>([SELECT Id FROM Entitlement where Opportunity__c = : OpportunityID AND recordTypeId = : LMS_Util.LMSEntRecordTypeId LIMIT 1]); 
        sandboxProductId = getsandboxProductId();
        for (Asset ase: [SELECT id, name, Product2.id FROM Asset WHERE opportunity__c = : OpportunityId LIMIT 100]) {
            oppAssetsMap.put(ase.Product2.id, ase);
        } 
        eprocessMap = geteprocessMap();
        businessHoursMap = getbusinessHoursMap();
        oppAndAccount = new List<Opportunity>([SELECT Account.id,AccountId,Prior_Opportunity__c,Primary_Marketo_User_Lookup__c, Primary_Marketo_User_Lookup__r.Account.Id, 
                                                      Account.name, Account.business_unit__c, Account.Sales_Region__c, Sub_Start_Date__c, Sub_End_Date__c,
                                                      (SELECT pricebookentry.product2.ConvertTo__c,
                                                           pricebookentry.product2.ProductCode,
                                                           pricebookentry.product2.Name,
                                                           pricebookentry.product2.Family,
                                                           pricebookentry.product2.Record_Limitation__c,
                                                           pricebookentry.product2.id,
                                                           pricebookentry.product2.Subscription_Type__c,
                                                           pricebookentry.product2.Included_Marketing_Users__c,
                                                           opportunityId,
                                                           opportunity.account.id,
                                                           opportunity.name,
                                                           opportunity.type,
                                                           Opportunity.Deal_type__c,
                                                           opportunity.account.name,
                                                           opportunity.account.business_unit__c,
                                                           opportunity.account.type,
                                                           opportunity.account.Professional_Edition__c,
                                                           opportunity.account.Partner_Type__c,
                                                           opportunity.account.Sales_Region__c,
                                                           opportunity.CRM_System__c,
                                                           opportunity.Sub_Start_Date__c,
                                                           opportunity.Sub_End_Date__c,
                                                           opportunity.Primary_Marketo_User_Lookup__c,
														   opportunity.Rep_Create_ARR__c,
                                                           Related_asset__r.purpose__c, 
                                                           Related_asset__r.Installdate,
                                                           Related_asset__r.UsageEndDate,
                                                           Related_Asset__c, Quantity,Quantity_from_Quote_Line__c
                                                        FROM Opportunitylineitems LIMIT 100)
                                               FROM opportunity where id = : OpportunityID LIMIT 1 ]); 
    
        List<Opportunitylineitem> oppLineItemsList = new List<Opportunitylineitem>(oppAndAccount[0].Opportunitylineitems);
        if(!oppLineItemsList.isEmpty()) {
            for(opportunitylineitem ol: oppLineItemsList) {                         
                if (ol.Related_Asset__c != null) {
                    lineItemWithRelatedAssetMap.put(ol.Id, ol.Related_Asset__c);
                }
                if(ol.pricebookentry.product2.ConvertTo__c != 'Add On'){
                    haveOppAddOnProdOnly = false;
                }               
            }            
            if(lineItemWithRelatedAssetMap != null && lineItemWithRelatedAssetMap.size() > 0) {     
                List<Entitlement> relatedEntitlements = new List<Entitlement>();
                for (Asset a: [SELECT Id, Name, AccountId, InstallDate, UsageEndDate, Purpose__c, (SELECT id, AssetId, BusinessHoursId, EndDate, Name, SlaProcessId,
                               StartDate, Status, Type FROM Entitlements) FROM Asset WHERE Id IN : lineItemWithRelatedAssetMap.values() LIMIT 1000 ])
                {  
                   relatedAssetMap.put(a.Id, a);
                   relatedEntitlements.addAll(a.Entitlements);         
                }

                for(Entitlement e: relatedEntitlements) {
                    entitlementWithRelatedAssetMap.put(e.AssetId, e);
                }
            }          
            /**@@
            -1. INVOKE METHOD THAT CREATES SUBSCRIPTION ASSETS
            @@**/
            Utility.DO_NOT_UPDATE_ACCOUNT_FROM_OPPTY = true;
			allowAccountUpdateonAssetCreation = true;
            createSubscriptionAssets(oppLineItemsList);
            subscripAsset = [SELECT Id, Product2.ProductCode, (SELECT id, StartDate,
                            EndDate, BusinessHoursId, SlaProcessId, Product_ID__c, name, AccountId, AssetId, Type, Support_Region__c
                            from Entitlements) FROM Asset  WHERE Purpose__c = 'Production'
                            AND Asset_Type__c = 'Subscription' AND Opportunity__c = : OpportunityID ORDER BY CreatedDate LIMIT 10];            
            /**@@
            -2. INVOKE METHOD THAT CREATES ADDON ASSETS
            @@**/
            Utility.haveupdatedAssets = false;
            Utility.DO_NOT_UPDATE_ACCOUNT_FROM_OPPTY = true;    
			allowAccountUpdateonAssetCreation = true;			
            createAddOnAssets(oppLineItemsList);
            if(subscripAsset != null && subscripAsset.size() > 0) {
                for (Asset ast: subscripAsset) {                                    
                    for(Entitlement ent : ast.Entitlements){                        
                        if(ent.Product_ID__c != null && ent.AccountId == OppAndAccount[0].AccountId){
                            existingEntitlementsMap.put(ent.Product_ID__c, ent);
                        }else{
                            if(ent.Product_ID__c == null && ent.AccountId == OppAndAccount[0].AccountId){
                                deafultEntitlementInfo.add(ent);
                            }
                        }
                    }
                }                               
            }
            
            /**@@
            -3. INVOKE METHOD TO CREATE ENTITLEMENTS
            @@**/
            if(currentProcessedOpp.Deal_type__c != REPLACEMENTINSTANCE && !haveOppAddOnProdOnly){ 
                Utility.DO_NOT_UPDATE_ACCOUNT_FROM_OPPTY = TRUE; 
				allowAccountUpdateonAssetCreation = true;
                CreateEntiltements(oppLineItemsList);            
            }               
                           
            for(Authorized_Contact__c c: [SELECT id, Entitlement__c FROM Authorized_Contact__c
                                         WHERE Entitlement__c in :newEntitlementList AND Customer_Admin__c = true limit 200]){
              existingAuthContactMap.put(c.Entitlement__c,c);
            } 
             /**@@
            -4. INVOKE METHOD TO CREATE AUTORIZED CONTACT
            @@**/
            createAuthorizedContacts(); 
            
            /**@---POPULATE ASSET AND ENETITLEMENT INFO ON ACCOUNT---@**/
            if(updateAssetAndEntitlementInfoOnAccount){
                updateAssetAndSubscriptionAndEntitlementInfo(new Set<String>{oppAndAccount[0].AccountId});
            }           
        }
    }
    
    /*@@
        -THIS METHOD CREATE AUTHORIZED CONTACTS BASED ON ENTITLEMENTS
    @@*/
    private static void createAuthorizedContacts() {
        Authorized_Contact__c ac;
        if (newEntitlementList != null && newEntitlementList.size() > 0) {
            for (Entitlement ent: newEntitlementList) {
                if(ent.Type != System.Label.Entitlement_Type_Label){ //DO NOT CREATE AUTHORIZED CONTACT FOR LEARNING PASS ENTITLEMENTS
                    if (existingAuthContactMap.containsKey(ent.id)) {
                        ac = existingAuthContactMap.get(ent.id);
                    }else{
                        ac = new Authorized_Contact__c();
                        if (oppAndAccount!= null && oppAndAccount.size() > 0) {
                            ac.Contact__c = oppAndAccount[0].Primary_Marketo_User_Lookup__c;
                        }
                        ac.Entitlement__c    = ent.id;
                        ac.Customer_Admin__c = true;
                        if (ac.Contact__c != null && oppAndAccount[0].Primary_Marketo_User_Lookup__r.Account.Id == ent.AccountId) {
                            listOfAuthorizedContact.add(ac);
                        }
                    }                
                }
            }
        }
        if (listOfAuthorizedContact != null && listOfAuthorizedContact.size() > 0) {
            upsert listOfAuthorizedContact;
        }
    }
    
    /**@@
    - CREATE ASSET WITH SUBSCRIPTION - START
    @@ **/    
    private static void createSubscriptionAssets(List<OpportunityLineitem> opplineitemList) {
        Set<Id> CheckDupSet = new Set<Id>();
        for (opportunitylineitem ol: opplineitemList){
            /**@@ New Code: Premium Catalog enablement in LMS.
            if products belong to Premium Catalog then no Asset would be created @@**/            
            if (LMS_Util.isPremiumProduct(ol.pricebookentry.product2.Id)){
                hasREGULAR = false;
                continue;
            }
            /**New Code: Premium Catalog enablement in LMS -Ended**/
           
            if (ol.pricebookentry.product2.Name.contains('Spark')){
                hasSPARK = true;
            }
            if (ol.pricebookentry.product2.ConvertTo__c == 'Subscription'){                
                if(oppAssetsMap.containsKey(ol.pricebookentry.product2.id)){
                    ass = oppAssetsMap.get(ol.pricebookentry.product2.id);                    
                }else if(lineItemWithRelatedAssetMap.containsKey(ol.id)){
                    Id assetId = lineItemWithRelatedAssetMap.get(ol.id);
                    if(relatedAssetMap.containsKey(assetId)) ass = relatedAssetMap.get(assetId);                                     
                } else {
                    if(!(ol.opportunity.name.containsIgnorecase('renewal') || ol.opportunity.name.containsIgnorecase('-01R') ||
                        ol.opportunity.name.containsIgnorecase('-02R') ||ol.opportunity.name.containsIgnorecase('-03R'))) {
                        
                        ass = new Asset();
                        ass.InstallDate  = ol.opportunity.Sub_Start_Date__c;
                        ass.UsageEndDate = ol.opportunity.Sub_End_Date__c;
                        if(!ol.pricebookentry.product2.Name.containsIgnorecase('Sandbox')) {
                            ass.Purpose__c = 'Production';
                            ass.Name = ol.opportunity.account.name+' '+ ass.Purpose__c;
                            hasREGULAR = true;
                        }
                        if(ol.pricebookentry.product2.Name.containsIgnorecase('Sandbox')) {
                            ass.Purpose__c = 'Sandbox';
                            ass.Name = ol.opportunity.account.name +' '+ ass.Purpose__c;
                        }
                        if(ol.opportunity.Account.Name.containsIgnorecase('Marketo') ||
                            ol.opportunity.Account.Name.containsIgnorecase('MKTO') ||
                            ol.Opportunity.Deal_type__c.containsIgnorecase('Internal Demo')) {
                            ass.Purpose__c = 'Internal';
                            ass.Name = ol.opportunity.account.name + ' ' + ass.Purpose__c;
                        }
                        if(ol.Opportunity.Deal_type__c.containsIgnorecase('Trial')) {
                            ass.Purpose__c = 'Trial';
                            ass.Name = ol.opportunity.account.name +' '+ ass.Purpose__c;
                        }                       
                    }else{
                        break; /**@@ GRAZITTI QUERY: we need to check why there is break. it was added by SHEKHARPALLI @@**/
                    }
                }
                                
                ass.AccountId     = ol.opportunity.account.id;                
                ass.Asset_Type__c = ol.pricebookentry.product2.ConvertTo__c;
                ass.Product2Id = ol.pricebookentry.product2.id;
                ass.Subscription_Type__c = ol.pricebookentry.product2.Subscription_Type__c;           
                ass.Opportunity__c = OpportunityId;
                ass.CRM_System__c = ol.opportunity.CRM_System__c;
                
                if(ol.pricebookentry.product2.ConvertTo__c != null && ol.pricebookentry.product2.ConvertTo__c == 'Add On') {
                    if(ol.pricebookentry.product2.Family != null) ass.Add_On_Product__c = ol.pricebookentry.product2.Family;
                }                
                if (ass.Parent_Instance__c != null && ass.Parent_Instance__r.Asset_Type__c == 'Subscription') {
                    ass.Quantity = ol.pricebookentry.product2.Record_Limitation__c;
                }
                if (ass.Purpose__c != null && ass.Purpose__c == 'Production') {
                    ass.Supported_Instance__c = true;
                    ass.Partner_Supported__c  = False;
                }
                if (ol.opportunity.account.type != null && ol.opportunity.account.type == 'Partner') {
                    ass.Partner_Supported__c = true;
                }
                if (ass.id != null && !CheckDupSet.contains(ass.id)) {
                    listOfAssets.add(ass);
                    CheckDupSet.add(ass.id);
                }else if(ass.id == null){
                    listOfAssets.add(ass);
                }
            }
            
        }        
        if (listOfAssets!= null && listOfAssets.size() > 0) {            
            try{
                upsert listOfAssets;   
                updateAssetAndEntitlementInfoOnAccount = true;            
            }catch(Exception e){
                currentOpp[0].addError(e.getMessage());
            }
            listOfAssets.clear();
        }
    }/**CREATE ASSET WITH SUBSCRIPTION - ENDS****/
    
    /**@@
       CREATE ASSET OF TYPE- ADDON - START
    @@**/
    private static void CreateAddOnAssets(List<OpportunityLineItem> OpplinelistAddOn) {
        
        Set<Id> CheckDupSet = new Set<Id> ();
        Map<String, Product_Family__c> productFamilies = Product_Family__c.getAll();
        for (opportunitylineitem opl: OpplinelistAddOn) {
            /**@@ New Code: Premium Catalog enablement in LMS.
            if products belong to Premium Catalog then no Asset would be created @@**/
            if (LMS_Util.isPremiumProduct(opl.pricebookentry.product2.Id)){
                hasREGULAR = false;
                continue;
            }
            /**New Code: Premium Catalog enablement in LMS -Ended**/
            if (!(opl.opportunity.name.containsIgnorecase('renewal') || opl.opportunity.name.containsIgnorecase('-01R') ||opl.opportunity.name.containsIgnorecase('-02R') || opl.opportunity.name.containsIgnorecase('-03R'))   
                 && opl.pricebookentry.product2.Name.containsIgnorecase('Enterprise')
                 && !opl.pricebookentry.product2.Name.containsIgnorecase('Sandbox') 
                 && (opl.pricebookentry.Product2.ConvertTo__c == 'Subscription')
             ){
                asset ass1 = new Asset();
                ass1.InstallDate = opl.opportunity.Sub_Start_Date__c;
                ass1.UsageEndDate = opl.opportunity.Sub_End_Date__c;
                ass1.Purpose__c = 'Sandbox';
                ass1.Asset_Type__c = 'Subscription';
                if(sandboxProductId != null && sandboxProductId.size()>0) ass1.Product2Id = sandboxProductId[0].ID;
                ass1.Subscription_Type__c = 'Enterprise';
                ass1.Name = opl.opportunity.account.name +' '+ ass1.Purpose__c;
                ass1.AccountId = opl.opportunity.account.id;
                ass1.CRM_System__c = opl.opportunity.CRM_System__c;
                ass1.Opportunity__c = OpportunityId;
                if(subscripAsset != null && subscripAsset.size()>0) ass1.Parent_Instance__c = subscripAsset[0].id;
                listOfAssets.add(ass1);
                asset ass2 = new Asset();
                ass2.InstallDate = opl.opportunity.Sub_Start_Date__c;
                ass2.UsageEndDate = opl.opportunity.Sub_End_Date__c;
                ass2.Purpose__c = '';
                ass2.Product2Id = opl.pricebookentry.product2.id;             
                ass2.AccountId = opl.opportunity.account.id;
                ass2.CRM_System__c = opl.opportunity.CRM_System__c;
                ass2.Opportunity__c = OpportunityId;
                ass2.Add_On_Product__c = 'Advanced Engagement';
                ass2.Asset_Type__c = 'Add On';
                ass2.Name = opl.opportunity.account.name +' '+ ass2.Add_On_Product__c;
                if(subscripAsset != null && subscripAsset.size()>0) ass2.Parent_Instance__c = subscripAsset[0].id;
                listOfAssets.add(ass2);
            }
            if (opl.pricebookentry.product2.ConvertTo__c == 'Add On'){
                ass = new Asset();
                if (oppAssetsMap.keyset().contains(opl.pricebookentry.product2.id)) {
                    ass = oppAssetsMap.get(opl.pricebookentry.product2.id);
                    if (ass != null) {                        
                        break;
                    }
                } else if (lineItemWithRelatedAssetMap.keyset().contains(opl.id)) {
                    Id AssetId = lineItemWithRelatedAssetMap.get(opl.id);
                    if(relatedAssetMap.containsKey(AssetId)) ass = relatedAssetMap.get(AssetId);
                    if (ass != null) {                        
                        break;
                    }
                } else {
                    if (!(opl.opportunity.name.containsIgnorecase('renewal') || opl.opportunity.name.containsIgnorecase('-01R')||opl.opportunity.name.containsIgnorecase('-02R') || opl.opportunity.name.containsIgnorecase('-03R'))){    
                        ass.InstallDate = opl.opportunity.Sub_Start_Date__c;
                        ass.UsageEndDate = opl.opportunity.Sub_End_Date__c;                        
                    } else {
                        break;
                    }
                }
                
                if (subscripAsset!= null && subscripAsset.size() > 0) ass.Parent_Instance__c = subscripAsset[0].id;
                ass.AccountId     = opl.opportunity.account.id;
                ass.Asset_Type__c = opl.pricebookentry.product2.ConvertTo__c;
                
                /***************Code for Add On products**************/
                //As per product names:-   
                if(productFamilies.containsKey(opl.pricebookentry.product2.ProductCode)){
                    ass.Add_on_Product__c = productFamilies.get(opl.pricebookentry.product2.ProductCode).Product_Family_Value__c;
                }else{          
                    if (opl.pricebookentry.product2.Name.containsIgnoreCase(productFamilies.get('Additional Authorized Contacts').Product_Family_key__c)) {
                        ass.Add_on_Product__c = productFamilies.get('Additional Authorized Contacts').Product_Family_Value__c;
                    }else                
                    if (opl.pricebookentry.product2.Name.containsIgnoreCase(productFamilies.get('DB Space').Product_Family_key__c)) {
                        ass.Add_on_Product__c = productFamilies.get('DB Space').Product_Family_Value__c;
                    }else                
                    if (opl.pricebookentry.product2.Name.containsIgnoreCase(productFamilies.get('eMail Relay').Product_Family_key__c)) {
                        ass.Add_on_Product__c = productFamilies.get('eMail Relay').Product_Family_Value__c;
                    }else                
                    if (opl.pricebookentry.product2.Name.containsIgnoreCase(productFamilies.get('Advanced Engagement').Product_Family_key__c)) {
                        ass.Add_on_Product__c = productFamilies.get('Advanced Engagement').Product_Family_Value__c;
                    }else
                    if (opl.pricebookentry.product2.Name.containsIgnoreCase(productFamilies.get('Secured Page Services').Product_Family_key__c)){
                        ass.Add_on_Product__c = productFamilies.get('Secured Page Services').Product_Family_Value__c;
                    }else                
                    if (opl.pricebookentry.product2.Name.containsIgnoreCase(productFamilies.get('Marketo Social Marketing').Product_Family_key__c)) {
                        ass.Add_on_Product__c = productFamilies.get('Marketo Social Marketing').Product_Family_Value__c;
                    }
                    //As per product Families:-   
                    if(opl.pricebookentry.product2.Family != null && productFamilies.containsKey(opl.pricebookentry.product2.Family)){
                         ass.Add_on_Product__c = productFamilies.get(opl.pricebookentry.product2.Family).Product_Family_Value__c;
                    }else{             
                        if (opl.pricebookentry.product2.Family != null &&  productFamilies.get('CRM Integration').Product_Family_key__c.containsIgnoreCase(opl.pricebookentry.product2.Family)) {
                            ass.Add_on_Product__c = productFamilies.get('CRM Integration').Product_Family_Value__c;
                        }else                
                        if (opl.pricebookentry.product2.Family != null && opl.pricebookentry.product2.Family != null && productFamilies.get('Deliverability Tool').Product_Family_key__c.containsIgnoreCase(opl.pricebookentry.product2.Family)) {
                            ass.Add_on_Product__c = productFamilies.get('Deliverability Tool').Product_Family_Value__c;
                        }else                
                        if (opl.pricebookentry.product2.Family != null && productFamilies.get('RCA').Product_Family_key__c.containsIgnoreCase(opl.pricebookentry.product2.Family)) {
                            ass.Add_on_Product__c = productFamilies.get('RCA').Product_Family_Value__c;
                        }else                
                        if (opl.pricebookentry.product2.Family != null && productFamilies.get('MSI').Product_Family_key__c.containsIgnoreCase(opl.pricebookentry.product2.Family)) {
                            ass.Add_on_Product__c = productFamilies.get('MSI').Product_Family_Value__c;
                        }else
                        if (opl.pricebookentry.product2.Family != null && productFamilies.get('Dedicated IP').Product_Family_key__c.containsIgnoreCase(opl.pricebookentry.product2.Family)) {
                            ass.Add_on_Product__c = productFamilies.get('Dedicated IP').Product_Family_Value__c;
                        }else
                        if (opl.pricebookentry.product2.Family != null &&  productFamilies.get('Marketo Financial Management').Product_Family_key__c.containsIgnoreCase(opl.pricebookentry.product2.Family)) {
                            ass.Add_on_Product__c = productFamilies.get('Marketo Financial Management').Product_Family_Value__c;
                        }else                
                        if (opl.pricebookentry.product2.Family != null && productFamilies.get('Social Campaigns').Product_Family_key__c.containsIgnoreCase(opl.pricebookentry.product2.Family)) {
                            ass.Add_on_Product__c = productFamilies.get('Social Campaigns').Product_Family_Value__c;
                        }else
                        if (opl.pricebookentry.product2.Family != null && ass.Add_on_Product__c == null){
                            ass.Add_On_Product__c = opl.pricebookentry.product2.Family;
                        }
                    }
                }
                
                /**@@
                - SET NAME OF ASSETS BASED ON ADDON PRODUCT AND NAME- STARTS 
                @@**/                 
                if (!opl.pricebookentry.product2.Name.containsIgnorecase('Sandbox')) {                            
                    ass.Name = opl.opportunity.account.name + ' '+ ass.Add_On_Product__c;
                    hasREGULAR = true;
                }else
                if (opl.pricebookentry.product2.Name.containsIgnorecase('Sandbox')) {
                    // ass.Purpose__c = 'Sandbox';
                    ass.Name = opl.opportunity.account.name +' '+ ass.Purpose__c;
                }                
                if (opl.Opportunity.Account.Name.containsIgnorecase('Marketo') ||
                    opl.Opportunity.Account.Name.containsIgnorecase('MKTO') ||
                    opl.Opportunity.Deal_type__c.containsIgnorecase('Internal Demo')) {
                    ass.Purpose__c = 'Internal';
                    ass.Name = opl.opportunity.account.name + ' ' + ass.Purpose__c;
                }
                if (opl.Opportunity.Deal_type__c.containsIgnorecase('Trial')) {
                    // ass.Purpose__c = 'Trial';
                    ass.Name = opl.opportunity.account.name + ' ' + ass.Purpose__c;
                }/****SET NAME OF ASSETS BASED ON ADDON PRODUCT AND NAME - END****/
                              
                if (opl.pricebookentry.product2.Family == 'Sales Insight') {
                    ass.MSI_Seats__c = opl.Quantity;
                }
                ass.CRM_System__c = opl.opportunity.CRM_System__c;                          
                ass.Partner_Supported__c = false;
                ass.Supported_Instance__c = false;
                if (ass.Parent_Instance__c != null && ass.Parent_Instance__r.Asset_Type__c == 'Subscription') {
                    ass.Quantity = opl.pricebookentry.product2.Record_Limitation__c;
                }
                ass.Product2Id = opl.pricebookentry.product2.id;
                //ass.Subscription_Type__c = opl.pricebookentry.product2.Subscription_Type__c;
                ass.Opportunity__c = OpportunityId;
                if (ass.id != null && !CheckDupSet.contains(ass.id)){
                    listOfAssets.add(ass);
                    CheckDupSet.add(ass.id);
                } else if (ass.id == null)
                    listOfAssets.add(ass);
            }
        }
        if (listOfAssets != null && listOfAssets.size() > 0) {
            try{
                upsert listOfAssets;
                updateAssetAndEntitlementInfoOnAccount = true;
            }catch(Exception e){ currentOpp[0].addError(e.getMessage());}
        }
    }/**CREATE ASSET OF TYPE- ADDON - ENDS****/
    
    /**@@
    - CREATE ENTITLEMENT BASED ON PRODUCTS- STARTS
    @@**/
    private static void CreateEntiltements(List<OpportunityLineItem> OpplineEnt) {
        string Partner_Type = '';
        boolean IsPartner = false;
        Map < String, Sales_region__c > mcs = Sales_region__c.getAll();
        string sr_key = '';
        Set <String> CheckDupSet = new Set<String> ();
        integer i = 0; /**New Code: Premium Catalog enablement in LMS**/
        List <OpportunityLineItem> universityProducts = new List<OpportunityLineItem> ();
        for (OpportunityLineItem ol: OpplineEnt){
            /**New Code: Premium Catalog enablement in LMS -Started**/          
            if (premiumEntitlement.isEmpty() && LMS_Util.isPremiumProduct(ol.pricebookentry.product2.Id)){
                universityProducts.add(ol);               
                continue;
            }            
            /**New Code: Premium Catalog enablement in LMS -Ended**/
            
            Partner_Type = '';    
            Set<String> converToValuesToCreateEntitlement = new Set<String>(System.Label.ProductConverToValuesToCreateEntitlement.split('#'));          
            if ((ol.pricebookentry.product2.ConvertTo__c != null && converToValuesToCreateEntitlement.contains(ol.pricebookentry.product2.ConvertTo__c)) && ol.pricebookentry.product2.ProductCode != 'LM-SAND') {
                Partner_Type = ol.opportunity.account.type != null ? ol.opportunity.account.type : '';
                if (IsPartner == true) Partner_Type = 'Partner';
                if ((Partner_Type == 'Partner') && ol.opportunity.account.Partner_Type__c != 'Referral') {
                    if (existingEntitlementsMap.keyset().contains(ol.pricebookentry.product2Id)) {
                        rawEntitlement = existingEntitlementsMap.get(ol.pricebookentry.product2Id);
                    } else if (ol.related_Asset__c != null && entitlementWithRelatedAssetMap.keyset().contains(ol.related_Asset__c)) {
                        rawEntitlement = entitlementWithRelatedAssetMap.get(ol.related_Asset__c);
                    } else {
                        //****updating default entitlement*****
                        if (deafultEntitlementInfo != null && deafultEntitlementInfo.size() > 0) {
                            rawEntitlement = deafultEntitlementInfo[0];                            
                        } else {
                            rawEntitlement = new Entitlement();
                            rawEntitlement.AccountId = ol.opportunity.account.id;
                            rawEntitlement = assignSupportRegion(rawEntitlement , oppAndAccount[0].Account.Business_Unit__c, mcs);
                        }
                    }
                    rawEntitlement.Product_ID__c = ol.pricebookentry.product2.id;
                    rawEntitlement.name = ol.opportunity.account.name;
                    if (subscripAsset != null && subscripAsset.size() > 0) {
                        rawEntitlement.AssetId = subscripAsset[0].id;
                    }
                    if (ol.opportunity.account.Partner_Type__c == 'Agency') {
                        rawEntitlement.Type = 'Partner';                        
                        if (eprocessMap.containskey('Standard Support')) {
                            rawEntitlement.SlaProcessId = eprocessMap.get('Standard Support');
                        }
                        if(oppAndAccount != null && oppAndAccount.size()> 0 ){
                            rawEntitlement = assignBusinessHours(rawEntitlement, oppAndAccount[0]);
                        }
                    }else
                    if (ol.opportunity.account.Partner_Type__c == 'Preferred Services') {
                        rawEntitlement.Type = 'Partner';
                        if (eprocessMap.containskey('Partner Support')) {
                            rawEntitlement.SlaProcessId = eprocessMap.get('Partner Support');
                        }
                        if (businessHoursMap.containskey('24x5')) {
                            rawEntitlement.BusinessHoursId = businessHoursMap.get('24x5');
                        }
                    }else
                    if (ol.opportunity.account.Partner_Type__c == 'Reseller') {
                        rawEntitlement.Type = 'Partner';
                        rawEntitlement = assignBusinessHours(rawEntitlement, oppAndAccount[0]); 
                    }else
                    if (ol.opportunity.account.Partner_Type__c == 'Customer & Partner') {
                        rawEntitlement.Type = '';
                    }
                    rawEntitlement.StartDate = ol.opportunity.Sub_Start_Date__c;
                    rawEntitlement.EndDate   = ol.opportunity.Sub_End_Date__c;

                } else if ((ol.opportunity.account.type != 'Partner') && ol.opportunity.account.Partner_Type__c != 'Referral') {
                    IsPartner = test.isrunningtest()? true : false;
                    if (existingEntitlementsMap.keyset().contains(ol.pricebookentry.product2Id)) {
                        rawEntitlement = existingEntitlementsMap.get(ol.pricebookentry.product2Id);                       
                    } else if (ol.related_Asset__c != null && entitlementWithRelatedAssetMap.keyset().contains(ol.related_Asset__c)) {
                        rawEntitlement = entitlementWithRelatedAssetMap.get(ol.related_Asset__c);
                    } else {
                        if (deafultEntitlementInfo != null && deafultEntitlementInfo.size() > 0) {
                            rawEntitlement = deafultEntitlementInfo[0];
                        } else {
                            rawEntitlement = new Entitlement();
                            rawEntitlement.AccountId = ol.opportunity.account.id;                            
                            rawEntitlement = assignSupportRegion(rawEntitlement, ol.opportunity.account.Business_Unit__c, mcs);
                        }
                    }
                    rawEntitlement.Product_ID__c = ol.pricebookentry.product2.id;
                    rawEntitlement.name = ol.opportunity.account.name;
                    if (!subscripAsset.isEmpty()) rawEntitlement.AssetId = subscripAsset[0].id;                     
                    
                    if (ol.pricebookentry.product2.ConvertTo__c == 'Entitlement-Spark') {
                        rawEntitlement.Type = 'Spark';                        
                        if (eprocessMap.containskey('Spark Support')) {
                            rawEntitlement.SlaProcessId = eprocessMap.get('Spark Support');
                        }
                        rawEntitlement = assignBusinessHours(rawEntitlement, oppAndAccount[0]);
                    }else
                    if (ol.pricebookentry.product2.ConvertTo__c == 'Entitlement-Premier') {
                        rawEntitlement.Type = 'Premier';                        
                        if (eprocessMap.containskey('Premier Support')) {
                            rawEntitlement.SlaProcessId = eprocessMap.get('Premier Support');
                        }
                        if(oppAndAccount[0].account.Sales_Region__c=='Japan'){
							rawEntitlement = assignBusinessHours(rawEntitlement, oppAndAccount[0]);
							system.debug('rawEntitlement'+rawEntitlement.id);   
                        }else if (businessHoursMap.containskey('24x5')) {
                            rawEntitlement.BusinessHoursId = businessHoursMap.get('24x5');
                        }
                    }else
                    if (ol.pricebookentry.product2.ConvertTo__c == 'Entitlement-Elite' ) {
                        rawEntitlement.Type = 'Elite';
                        if (eprocessMap.containskey('Elite Support')) {
                            rawEntitlement.SlaProcessId = eprocessMap.get('Elite Support');
                        }
						if(oppAndAccount[0].account.Sales_Region__c=='Japan'){
							rawEntitlement = assignBusinessHours(rawEntitlement, oppAndAccount[0]);
							system.debug('rawEntitlement'+rawEntitlement.id);   
                        }else if (businessHoursMap.containskey('24x5')) {
                            rawEntitlement.BusinessHoursId = businessHoursMap.get('24x5');
                        }
                    }else
                    if (ol.pricebookentry.product2.ConvertTo__c == 'Entitlement') {
                        rawEntitlement.Type = 'Standard';                        
                        if (eprocessMap.containskey('Standard Support')) {
                            rawEntitlement.SlaProcessId = eprocessMap.get('Standard Support');
                        }                      
                        rawEntitlement = assignBusinessHours(rawEntitlement, oppAndAccount[0]);
                    }else
                    if(ol.pricebookentry.product2.ConvertTo__c == 'Entitlement-Business'){
                        rawEntitlement.Type = 'Business';
                        if (eprocessMap.containskey('Standard Support')) {
                            rawEntitlement.SlaProcessId = eprocessMap.get('Standard Support');
                        }                        
                        rawEntitlement = assignBusinessHours(rawEntitlement, oppAndAccount[0]);
                    }            
                    rawEntitlement.StartDate = ol.opportunity.Sub_Start_Date__c;
                    rawEntitlement.EndDate = ol.opportunity.Sub_End_Date__c;                    
                }
                if (rawEntitlement.id != null && !CheckDupSet.contains(rawEntitlement.id)) {
                    newEntitlementList.add(rawEntitlement);
                    CheckDupSet.add(rawEntitlement.id);
                } else if (rawEntitlement.id == null) newEntitlementList.add(rawEntitlement);
            }
        }
        //UNIVERSITY SECTION
        List<Entitlement> tempLMSEntList = New List<Entitlement>();
        if(!universityProducts.isEmpty()){
            Entitlement univEnt;
            univEnt = LMS_Util.decorateUnivEntitlement(oppAndAccount[0], universityProducts, univEnt );
            tempLMSEntList.add(univEnt);
            newEntitlementList.add(univEnt);
        }
        
        if (newEntitlementList != null && newEntitlementList.size() > 0) {
            try{
                upsert newEntitlementList;
                updateAssetAndEntitlementInfoOnAccount = true;                  
                if(!tempLMSEntList.isEmpty()){
                    Boolean isLeaningPassCreated = LMS_Util.generateUniqueCode(tempLMSEntList);
                    //CODE IS COMMENTED AS LMS HAS BEEN MOVED TO MERIDIAN
                    //if(isLeaningPassCreated) LMS_Util.sendPassportCodeToPrimaryUserAfter24Hr(tempLMSEntList, System.Label.University_LearningPassCodes_EmailTemplate_For_NewBusiness);
                }                 
             }catch(Exception e){ currentOpp[0].addError(e.getMessage());}
        }else if(newEntitlementList.size() == 0 || test.IsRunningtest()) {
            createDefaultEntitlement();
        }
    }
    /**CREATE ENTITLEMENT BASED ON PRODUCTS- ENDS****/
   
    /**@@
    - CREATE DEFAULT ENTITLEMENT FOR ACCOUNT- STARTS**
    @@**/
    public static void createDefaultEntitlement(){
        Map <String, Sales_region__c> mcs = Sales_region__c.getAll();
        string sr_key = '';
        if (hasREGULAR) {
            entitlement defaultEntitlement = new entitlement();             
            if(!oppAndAccount.isEmpty()){
                defaultEntitlement.name      = oppAndAccount[0].Account.Name;
                defaultEntitlement.StartDate = oppAndAccount[0].Sub_Start_Date__c;
                defaultEntitlement.EndDate   = oppAndAccount[0].Sub_End_Date__c;
            }
            if (hasSPARK) {
                defaultEntitlement.Type = 'Spark';
                if (eprocessMap.containskey('Spark Support'))
                    defaultEntitlement.SlaProcessId = eprocessMap.get('Spark Support');
            } else {
                defaultEntitlement.Type = 'Standard';
                if (eprocessMap.containskey('Standard Support'))
                    defaultEntitlement.SlaProcessId = eprocessMap.get('Standard Support');
            }
            if(!oppAndAccount.isEmpty()){
                defaultEntitlement = assignBusinessHours(defaultEntitlement, oppAndAccount[0]);                
                defaultEntitlement.accountid = oppAndAccount[0].account.id;  
                if(oppAndAccount[0].account.Business_Unit__c != null){                   
                     defaultEntitlement = assignSupportRegion(defaultEntitlement, oppAndAccount[0].account.Business_Unit__c, mcs);
                }
            }
            if (subscripAsset != null && subscripAsset.size() > 0) {                
                for (Asset a: subscripAsset) {                    
                    if (a.product2.ProductCode != 'LM-SAND') {
                        defaultEntitlement.AssetId = a.id;                        
                    }
                }               
            }            
            newEntitlementList.add(defaultEntitlement);
            if (!newEntitlementList.isEmpty()){
                try { 
                    upsert newEntitlementList;
                    updateAssetAndEntitlementInfoOnAccount = true;                
                }catch(Exception e){ currentOpp[0].addError(e.getMessage());}
            }
        }
    }/**CREATE DEFAULT ENTITLEMENT FOR ACCOUNT- END**/
    
    /**@@
    - UTILITY METHODS STARTS
    @@**/
    private static Entitlement assignSupportRegion(Entitlement entToBeReturned, String accountBusinessUnit, Map <String, Sales_region__c> salesRegions){
        if(accountBusinessUnit != null && accountBusinessUnit != ''){                                
            if (salesRegions.get('AMER').Support_region_key__c.containsIgnoreCase(accountBusinessUnit)) {
                entToBeReturned.Support_Region__c = salesRegions.get('AMER').support_region_value__c;
            }else
            if(salesRegions.get('LATAM').Support_region_key__c.containsIgnoreCase(accountBusinessUnit)) {
                entToBeReturned.Support_Region__c = salesRegions.get('LATAM').support_region_value__c;
            }else
            if (salesRegions.get('EMEA').Support_region_key__c.containsIgnoreCase(accountBusinessUnit)) {
                entToBeReturned.Support_Region__c = salesRegions.get('EMEA').support_region_value__c;
            }else
            if (salesRegions.get('ANZ').Support_region_key__c.containsIgnoreCase(accountBusinessUnit)) {
                entToBeReturned.Support_Region__c = salesRegions.get('ANZ').support_region_value__c;
            }else                                
            if (salesRegions.get('Non-EMEA Spark').Support_region_key__c.containsIgnoreCase(accountBusinessUnit)) {
                entToBeReturned.Support_Region__c = salesRegions.get('Non-EMEA Spark').support_region_value__c;
            }else                                
            if (salesRegions.get('JPN').Support_region_key__c.containsIgnoreCase(accountBusinessUnit)) {
                entToBeReturned.Support_Region__c = salesRegions.get('JPN').support_region_value__c;
            }
        }   
        return entToBeReturned;
    }

    private static Entitlement assignBusinessHours(Entitlement entitlementToBeReturned, Opportunity opp){
        if(oppAndAccount[0].Account.Sales_Region__c != null){
            if (opp.Account.Sales_Region__c == 'North America') {
                if (businessHoursMap.keyset().contains('Local Hours (North America)'))
                    entitlementToBeReturned.BusinessHoursId = businessHoursMap.get('Local Hours (North America)');
            }else									
			if (opp.Account.Sales_Region__c == 'APAC' || opp.Account.Sales_Region__c == 'ANZ') { /*Changes related to SOPS-1087*/           
                if(entitlementToBeReturned.type == 'Business' && businessHoursMap.keyset().contains('Local Hours (ANZ) -3')){
                    entitlementToBeReturned.BusinessHoursId = businessHoursMap.get('Local Hours (ANZ) -3');
                }else if (businessHoursMap.keyset().contains('Local Hours (APAC)') || businessHoursMap.keyset().contains('Local Hours (ANZ)')) //entitlementToBeReturned.BusinessHoursId = businessHoursMap.get('Local Hours (APAC)');
                    entitlementToBeReturned.BusinessHoursId = businessHoursMap.get('Local Hours (ANZ)');
            }else
            if (opp.Account.Sales_Region__c == 'EMEA') {
                if(entitlementToBeReturned.type == 'Business' && businessHoursMap.keyset().contains('Local Hours (EMEA) +3')){
                    entitlementToBeReturned.BusinessHoursId = businessHoursMap.get('Local Hours (EMEA) +3');
                }else if (businessHoursMap.keyset().contains('Local Hours (EMEA)'))
                    entitlementToBeReturned.BusinessHoursId = businessHoursMap.get('Local Hours (EMEA)');
            }else
            if(opp.Account.Sales_Region__c == 'Other'){
                entitlementToBeReturned.BusinessHoursId = businessHoursMap.get('Local Hours (North America)');
            }else
            if(opp.Account.Sales_Region__c == 'Japan'){
                entitlementToBeReturned.BusinessHoursId = businessHoursMap.get('Local Hours (Japan)');
            }
        }else{
            entitlementToBeReturned.BusinessHoursId = businessHoursMap.get('Local Hours (North America)');        
        }
        return entitlementToBeReturned;
    }
    /***/
    
    
    public static void updateAssetAndSubscriptionAndEntitlementInfo(Set<String> accountIds){
        String PF_SERVICES  = SBQQContractAndSubscriptionTriggerHelper.PF_SERVICES;
        String PF_EDUCATION = SBQQContractAndSubscriptionTriggerHelper.PF_EDUCATION;
        String PF_SUPPORT   = SBQQContractAndSubscriptionTriggerHelper.PF_SUPPORT;
        String P_MA         = SBQQContractAndSubscriptionTriggerHelper.P_MA;
        String P_RTP        = SBQQContractAndSubscriptionTriggerHelper.P_RTP;
        String PF_PRODUCT   = SBQQContractAndSubscriptionTriggerHelper.PF_PRODUCT;
        List<String> accountProdEditions = UpdateAssets.getPicklistValues('Account', 'Product_Editions__c');     
        for(Account acc : [SELECT Id,  Add_On_Products__c, Support_level1__c, PRODUCT_EDITIONS__c, MA_Edition__c, RTP_Suite__c, Add_On_Subscriptions__c, Services__c, Support__c ,
                          (SELECT ID, SBQQ__Contract__c, SBQQ__Account__r.ID, SBQQ__Product__c, SBQQ__Product__r.Name, SBQQ__Product__r.MA_or_RTP__c, SBQQ__Product__r.Family, SBQQ__Product__r.Visible_To_Customer__c FROM SBQQ__Subscriptions__r WHERE SBQQ__Product__r.Visible_To_Customer__c = True AND SBQQ__EndDate__c >= TODAY Limit 100),
                          (SELECT ID,Asset_type__c,Purpose__c, Add_On_Product__c, NAME, STATUS, Subscription_type__c,   Product2.Family, Product2.Name, Product2.Visible_To_Customer__c FROM ASSETS where status != 'Expired'  Limit 1000),
                          (SELECT Name, ID, Status, Entitlement_Status__c, Type FROM Entitlements WHERE Entitlement_Status__c != 'Expired' LIMIT 100), Name 
                          FROM Account WHERE ID IN: accountIds]) 
        {
            
            
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
            
            Account accInCache = Trigger_Opportunity_Helper.retrievePartiallyUpdatedAccount(acc.id);
            accInCache.support_level1__c   = acc.support_level1__c;
            accInCache.Product_editions__c = acc.Product_editions__c;
            accInCache.Add_on_Products__c  = acc.Add_on_Products__c  ;
            
            accInCache.Support__c= acc.Support__c;
            accInCache.Services__c = acc.Services__c;
            accInCache.Add_On_Subscriptions__c = acc.Add_On_Subscriptions__c;
            accInCache.RTP_Suite__c = acc.RTP_Suite__c;
            accInCache.MA_Edition__c = acc.MA_Edition__c ;
            
            Trigger_Opportunity_Helper.ACCOUNT_MASTER_LIST.put(accInCache.Id, accInCache );           
        }    
    }
    
   /****TEST CODE STARTED*****/
    @isTest(SeeAllData = true)
    public static void doTest(){
        
        ID ClosedWonId = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Closed Won').getRecordTypeId();
        Account a = Utility.insertAccountInTestClasses();
        a.BillingCity = 'NewYork';
        a.BillingCountry = 'United States';
        a.BillingStreet = 'Test Street';
        a.BillingState ='Test Billing State';
        a.BillingPostalCode ='12345';
        a.ShippingCity ='Pune';
        a.ShippingCountry ='India';
        a.ShippingPostalCode = '12345';
        a.ShippingState = '';
        a.ShippingStreet = 'Test Shipping Street';            
        insert a;
        
        Contact c = Utility.insertContactInTestClasses(a.Id);
        insert c;
        
        List <Product2> ProList = new List <Product2> ();
        Product2 p = new Product2(Name = 'test pro', IsActive = true, ConvertTo__c = 'Subscription', ProductCode = 'abc');
        Product2 lmsp = new Product2(Name = 'Premium Education Subscription- SMB', IsActive = true, ProductCode = 'lms', Record_Limitation__c = 5);
        ProList.add(p);
        ProList.add(lmsp);
        insert ProList;
        
        List <PriceBook2> PriceB = [Select id from PriceBook2 where IsStandard = true limit 1];

        List<PriceBookEntry> PBEList = new List < PriceBookEntry > ();
        PriceBookEntry Pe = new PriceBookEntry(IsActive = true, PriceBook2Id = PriceB[0].id, Product2Id = p.id, UnitPrice = 200);
        PriceBookEntry lmsPe = new PriceBookEntry(IsActive = true, PriceBook2Id = PriceB[0].id, Product2Id = lmsp.Id, UnitPrice = 200);
        PBEList.add(Pe);
        PBEList.add(lmspe);
        insert PBEList;
        
        Opportunity Opp = Utility.insertOpportunityInTestClasses(a.id, c.Id, 'Discovery', 'New Business',Date.Today(), system.today().addDays(1),system.today().addDays(7), null);        
        Opp.Pricebook2Id = PriceB[0].id;
		insert Opp;
        
        List <OpportunityLineItem> OplList = new List <OpportunityLineItem> ();
        OpportunityLineItem oli = new OpportunityLineItem();
        oli.Users__c = 1;
        oli.MLM_Edition__c = 'test edition';
        oli.OpportunityId = Opp.Id;
        oli.PricebookEntryId = pe.Id;
        oli.Instance_Number__c = 123;
        oli.Quantity = 5;
        oli.UnitPrice = 200;        
        OplList.add(oli);  
        Premium_Education_Catalog_Products__c lmsCustomSetting = new Premium_Education_Catalog_Products__c(
                Name = 'Premium Education', Product_Name__c = 'Premium Education Subscription- SMB',
                ProductId__c = lmsp.Id);
        insert lmsCustomSetting;
        OpportunityLineItem lmsoli = new OpportunityLineItem();
        lmsoli.Users__c = 1;
        lmsoli.MLM_Edition__c = 'test edition';
        lmsoli.OpportunityId = Opp.Id;
        lmsoli.PricebookEntryId = lmspe.Id;
        lmsoli.Instance_Number__c = 123;
        lmsoli.Quantity = 2;
        lmsoli.UnitPrice = 200;
        OplList.add(lmsoli);
        insert OplList;
        Test.StartTest();
        Opp.RecordTypeId = ClosedWonId;
        Opp.Stagename = 'Closed Won';
        update Opp; 
		
        NEWCreateAssetsAndEntitlements.createAssetWithEntitlement(opp);    
        NEWCreateAssetsAndEntitlements.createDefaultEntitlement();
        Test.stopTest();
    }

}