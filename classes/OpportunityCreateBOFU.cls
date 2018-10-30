/****************************************************************
 * Last Modified By   : Aman Gupta, Grazitti Interactive
 * Last Modified Date : 5 June 2018
 * Changes            : 1 Add Delivery Source and Delivery Source Details fields on Bofu page As per the ticket APPS-20849
 * Line               : 455-462
 
 
 * Last Modified By   : Cassandrea Steiner, Marketo
 * Last Modified Date : 17 Nov 2017
 * Changes            : 1.Removed Use_Case__c from the fields that would be cleared on Signed Order
 * Line               : 362

 * Last Modified By   : Rajesh Wani,Jade Global
 * Last Modified Date : 1st June 2017
 * Changes            : 1.Updating the Provisioning_Type__c on Renewal opportunity
 *                      2.Populating Account_String__c on Upsell opportunity from primary asset present on Master Contract presnt on Quote
 *                      3.Populating Account_String__c on RenewalOpportunity opportunity from primary asset present on contract
 *                      4.Populating Sandbox_account_prefix__c on RenewalOpportunity opportunity from primary asset related Sandbox Asset
 * Line               : 99-136
 * 
 * Last Modified By   : Priyanka Shende, Jade Global Inc, On 13th June 2017
 * Purpose            : 1. For Upsell Account_String__c population Amendment and MDQ check not required
 *                      2. Populate Sandbox Account Prefix For Rubiks 
 *                      3. Populate Account prefix on feature and rubiks
 * Line No            : 112 , 121 to 123, 137
 * 
 * Last Modified By   : Priyanka Shende, Jade Global Inc, On 19th July 2017
 * Purpose            : 1. For Multi Instance populate the popup on Account_String__c  if any instance is rollout/Dropped
 *                      2. For Multi Instance Populate popup on Renewed sandbox prefix if any instance is rollout/Dropped
 
 * Last Modified By   : Tushar Misri, Grazitti Interactive, On 11th August 2018
 * Purpose            : Commented the field that are used in field removal project 
    refrence : APPS-20840 Field Cleanup Project - Phase One
    log of fields commented : Opportunity: sandbox_account_prefix__c
 
 * ***************************************************************/
public with sharing class OpportunityCreateBOFU {

    private ApexPages.StandardController sc;
    private Opportunity o;
    private Opportunity opportunity;
    public Account account {get; set;}
    //public BOFU_Snapshot__c snapshot {get; set;}
    public Boolean bofuAdditionalFieldsEnabled {get; set;}
    public static Boolean inBofuScreen = false;
    public String conDate {get;set;}
    public string dataCenter{get;set;}
    public static Double instanceRollup{get;set;}
    public static integer accountPrefixCount{get;set;}
    public static integer sandboxAccountPrefixCount{get;set;}
    public static string accountid{get;set;}
    public static string opportunityId{get;set;}
    public static Boolean MissingPrefix{get;set;}
    public static Boolean showDeliverySource{get;set;}
    // should only be used in before insert, before update
    public static void opportunityTriggerHandler(Opportunity[] oldOpportunities, Opportunity[] newOpportunities, Boolean bofuWizardEnabledForUser) {

        if (inBofuScreen == true) return;
        if (bofuWizardEnabledForUser != true) return;

        Set<Id> idsToCheckForBofu = new Set<Id>();

        // ensure the bofu users go through the bofu screen for signed order
        for (Integer i=0; i<newOpportunities.size(); i++) {
            Boolean wasSignedOrder = oldOpportunities != null && oldOpportunities.get(i).StageName == 'Signed Order';
            Boolean nowSignedOrder = newOpportunities.get(i).StageName == 'Signed Order';
            if (nowSignedOrder && !wasSignedOrder) {
                newOpportunities.get(i).StageName.addError('Must use Signed Order button to change stage to Signed Order');
            }
        }
    }

    public OpportunityCreateBOFU(ApexPages.StandardController sc) {
        this.sc = sc;
        //this.snapshot = new BOFU_Snapshot__c();
        this.o = (Opportunity)sc.getSubject();
        this.opportunity = this.o;
        opportunityId=this.opportunity.id;
        loadAccount(this.opportunity);
        applyParameterValues(o);
        accountid= this.opportunity.AccountId; 
        stageChange();
        bofuAdditionalFieldsEnabled = isBofuAdditionalFieldsEnabled();
        /*if (o.Id == null) {
            updateAspOptions();
        }*/
        conDate = ApexPages.currentPage().getParameters().get('Date_Referral_Submitted__c');
        
        List<Asset> AssetList=[SELECT id,Status,Purpose__c FROM Asset WHERE Status='Active' AND AccountId=:accountid];
        sandboxAccountPrefixCount=0;
        accountPrefixCount=0;
        if(!AssetList.isEmpty()){
           for(Asset ast:AssetList){ 
                if(ast.Purpose__c=='Rubiks Production' || ast.Purpose__c=='Production'){
                   accountPrefixCount= accountPrefixCount+1;
                }else if(ast.Purpose__c=='Sandbox'){
                   sandboxAccountPrefixCount=sandboxAccountPrefixCount+1;
                }
            }//End of For
        }//End of If
        
          /****************************************************************
             * Last Modified By   : Priyanka Shende,Jade Global
             * Last Modified Date : 2nd June 2017
             * Changes            : 1. Populate Data Center field - check the Primary Quote - Country and       accordingly populate the Data Center field on signed order based on the Data Center custom setting values.
             * 
             * ***************************************************************/
            //country and its datacenter map  from custom setting  
            Map<String,string> dataCenterMap =   new Map<String,string>();
            for(Country__c Country :[SELECT Data_Center__c,Id,Name FROM Country__c]){
                dataCenterMap.put(Country.Name, Country.Data_Center__c);
            }
            
            list<SBQQ__Quote__c> SBQuotelist= new list<SBQQ__Quote__c>();
            
            if(sc.getId()!=null){ 
                SBQuotelist        =  [SELECT id,SBQQ__Opportunity2__c,Rubiks_Quote__c,SBQQ__Opportunity2__r.type,SBQQ__Opportunity2__r.Prior_Opportunity__c,MDQ_Quote__c,Instance_Rollup__c,SBQQ__Opportunity2__r.Account_String__c,SBQQ__MasterContract__r.Primary_Asset__r.Acct_Prefix__c,SBQQ__MasterContract__r.SBQQ__Quote__r.Instance_Rollup__c,SBQQ__Type__c,SBQQ__ShippingCountry__c  FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c=:sc.getId() AND Rubiks_Quote__c= true AND SBQQ__Primary__c=true];
            }
            system.debug('########### SBQuotelist'+SBQuotelist);
            
            if(!SBQuotelist.isEmpty()){
                    SBQQ__Quote__c primaryQuote= SBQuotelist[0];
                    instanceRollup=primaryQuote.Instance_Rollup__c;
                    
                    if(primaryQuote.SBQQ__ShippingCountry__c!=null && dataCenterMap.containsKey(primaryQuote.SBQQ__ShippingCountry__c) && primaryQuote.SBQQ__Opportunity2__r.type ==Label.OPPORTUNITY_TYPE_NEW_BUSINESS && primaryQuote.Instance_Rollup__c<=1){
                        this.opportunity.Data_Center__c=dataCenterMap.get(primaryQuote.SBQQ__ShippingCountry__c);
                        dataCenter=dataCenterMap.get(primaryQuote.SBQQ__ShippingCountry__c);
                    }
            }
            system.debug('############# this.Data_Center__c'+this.opportunity.Data_Center__c);
            
             /****************************************************************
             * Last Modified By   : Rajesh Wani,Jade Global
             * Last Modified Date : 1st June 2017
             * Changes            : 1.Populating the Provisioning_Type__c on Renewal opportunity based on current and previous quote(Legacy to Rubiks/Rubiks to Rubiks)
             *                      2.Populating Account_String__c on Upsell opportunity from primary asset present on Master Contract presnt on Quote
             *                      3.Populating Account_String__c on RenewalOpportunity opportunity from primary asset present on Master Contract pres
             * 
             * 
             * 
             * ***************************************************************/
             
            if(sc.getId()!=null &&  (this.opportunity.type == Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL || this.opportunity.type == Label.OPPORTUNITY_TYPE_RENEWAL)){
                
                if(!SBQuotelist.isEmpty()){
                    SBQQ__Quote__c primaryQuote         = SBQuotelist[0];
                    
                    if(primaryQuote.SBQQ__Opportunity2__r.Prior_Opportunity__c!=null && (primaryQuote.SBQQ__Type__c == 'Amendment' || primaryQuote.SBQQ__Opportunity2__r.type == Label.OPPORTUNITY_TYPE_RENEWAL)){
                        
                          id PriorOpptyId = primaryQuote.SBQQ__Opportunity2__r.Prior_Opportunity__c;
                           
                          /* ********************************************************************************
                             Modified By:  Priyanka Shende,Jade Global Inc, on 13th June 2017
                             Purpose    : 1. For Upsell Account_String__c population Amendment and MDQ check not required
                                          2. Populate Sandbox Account Prefix For Rubiks 
                                          3. Populate Account prefix on feature and rubiks
                           **********************************************************************************/
                          list<Contract> Contractlist   =  [SELECT id,SBQQ__Opportunity__c,SBQQ__Opportunity__r.type,SBQQ__Quote__c,SBQQ__Quote__r.Rubiks_Quote__c,SBQQ__Quote__r.MDQ_Quote__c,Primary_Asset__r.Acct_Prefix__c,SBQQ__Quote__r.Instance_Rollup__c ,Primary_Asset__c,(SELECT id,Production_Asset__c,Acct_Prefix__c FROM Assets__r WHERE Purpose__c='Sandbox' and Acct_Prefix__c!=null limit 1) FROM Contract WHERE SBQQ__Opportunity__c=:PriorOpptyId];
                         
                          if(primaryQuote.SBQQ__Opportunity2__r.type == Label.OPPORTUNITY_TYPE_RENEWAL && primaryQuote.Rubiks_Quote__c == TRUE ){
                              
                              this.opportunity.Provisioning_Type__c = 'Legacy to Rubiks';
                              if(!Contractlist.isEmpty() ){
                                  Contract  cont = Contractlist[0];
                                  
                                  this.opportunity.Provisioning_Type__c = (cont.SBQQ__Quote__r.Rubiks_Quote__c == TRUE && primaryQuote.Rubiks_Quote__c == TRUE)?'Rubiks to Rubiks':'Legacy to Rubiks';
                                   if( this.opportunity.Account_String__c == null){
                                        this.opportunity.Account_String__c = cont.Primary_Asset__r.Acct_Prefix__c!=NULL ? cont.Primary_Asset__r.Acct_Prefix__c:primaryQuote.SBQQ__Opportunity2__r.Account_String__c;
                                   }//End of If
                                   id primaryAsetId      = cont.Primary_Asset__c;
                                  
								  //Commented as per APPS-20840
                                   /*if(primaryAsetId!=null){
                                    list<Asset> SandboxAsset = [SELECT id,Production_Asset__c,Acct_Prefix__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Rubiks_Quote__c FROM Asset WHERE Production_Asset__c=:primaryAsetId AND purpose__c='Sandbox' AND Acct_Prefix__c!=null AND SBQQ__QuoteLine__r.SBQQ__Quote__r.Rubiks_Quote__c=TRUE limit 1];
                                        if(!SandboxAsset.isEmpty()){
                                            //this.opportunity.Sandbox_account_prefix__c =  SandboxAsset[0].Acct_Prefix__c;
                                        }
                                   }*///End of IF block
                                  
                              }//End of IF of Contractlist Enpty check
                          }//End of OPPORTUNITY_TYPE_RENEWAL check
                         
                    }
                    if(primaryQuote.SBQQ__Opportunity2__r.type == Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL && this.opportunity.Account_String__c==null && primaryQuote.SBQQ__MasterContract__r.Primary_Asset__r.Acct_Prefix__c!=null){
                          this.opportunity.Account_String__c =  primaryQuote.SBQQ__MasterContract__r.Primary_Asset__r.Acct_Prefix__c;
                    }
                }//End of IF of Quote list empty check
                
            }//End of IF block of Opportunity with Signed Order
    }
    public PageReference onLoad() {
        for (User u : [select Id, BOFU_Wizard_Enabled__c from User where Id = :UserInfo.getUserId()]) {
            if (u.BOFU_Wizard_Enabled__c) {
                return null;
            }
        }
        // next line would be logical but we get a java error from it:
        // PageReference pr = (new ApexPages.StandardController(this.o)).edit();
        
        PageReference newPr = new PageReference('/006/e');
        PageReference oldPr = System.currentPageReference();
        // copy querystring params to the new url for things like recordtype
        for (String k : oldPr.getParameters().keySet()) {
            newPr.getParameters().put(k, oldPr.getParameters().get(k));
        }
        
        // ensures that we're not redirected back to this override page
        newPr.getParameters().put('nooverride', '1');
        
        // make sure that we're not passing the save param
        newPr.getParameters().put('save_new', null);
        
        return newPr;
    }
    public PageReference save() {
        try{
            boolean isNewOpportunity = false;
            if (this.opportunity.Id == null) {
                isNewOpportunity = true;
            }
            OpportunityCreateBOFU.inBofuScreen = true;
            //setSnapshotType(this.opportunity, this.snapshot);
            updateAccount(this.account);
            string contIds = ApexPages.currentPage().getParameters().get('conid');
            if (this.opportunity.StageName == 'Signed Order') {
                            
            /****************************************************************
             * Last Modified By   : Rajesh Wani,Jade Global
             * Last Modified Date : 1st June 2017
             * Changes            : 1.Populating the Provisioning_Type__c on Renewal opportunity based on current and previous quote(Legacy to Rubiks/Rubiks to Rubiks)
             *                      2.Populating Account_String__c on Upsell opportunity from primary asset present on Master Contract presnt on Quote
             *                      3.Populating Account_String__c on RenewalOpportunity opportunity from primary asset present on Master Contract pres
             * 
             * 
             * 
             * ***************************************************************/
             
            if(sc.getId()!=null &&  (this.opportunity.type == Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL || this.opportunity.type == Label.OPPORTUNITY_TYPE_RENEWAL)){
                list<SBQQ__Quote__c> SBQuotelist= new list<SBQQ__Quote__c>();
                
                SBQuotelist        =  [SELECT id,SBQQ__Opportunity2__c,Rubiks_Quote__c,SBQQ__Opportunity2__r.type,SBQQ__Opportunity2__r.Prior_Opportunity__c,MDQ_Quote__c,Instance_Rollup__c,SBQQ__Opportunity2__r.Account_String__c,SBQQ__MasterContract__r.Primary_Asset__r.Acct_Prefix__c,SBQQ__MasterContract__r.SBQQ__Quote__r.Instance_Rollup__c,SBQQ__Type__c,SBQQ__ShippingCountry__c  FROM SBQQ__Quote__c WHERE SBQQ__Opportunity2__c=:sc.getId() AND Rubiks_Quote__c= true AND SBQQ__Primary__c=true];
                
                if(!SBQuotelist.isEmpty()){
                    SBQQ__Quote__c primaryQuote         = SBQuotelist[0];
                    instanceRollup=primaryQuote.Instance_Rollup__c;
                    if(instanceRollup >1.0){
                        this.opportunity.Missing_Prefixes__c=MissingPrefix;
                     }
                    if(primaryQuote.SBQQ__Opportunity2__r.Prior_Opportunity__c!=null && (primaryQuote.SBQQ__Type__c == 'Amendment' || primaryQuote.SBQQ__Opportunity2__r.type == Label.OPPORTUNITY_TYPE_RENEWAL)){
                        
                          id PriorOpptyId = primaryQuote.SBQQ__Opportunity2__r.Prior_Opportunity__c;
                          System.debug('PriorOpptyId=============='+PriorOpptyId);
                          /* ********************************************************************************
                             Modified By:  Priyanka Shende,Jade Global Inc, on 13th June 2017
                             Purpose    : 1. For Upsell Account_String__c population Amendment and MDQ check not required
                                          2. Populate Sandbox Account Prefix For Rubiks 
                                          3. Populate Account prefix on feature and rubiks
                           **********************************************************************************/
                          list<Contract> Contractlist   =  [SELECT id,SBQQ__Opportunity__c,SBQQ__Opportunity__r.type,SBQQ__Quote__c,SBQQ__Quote__r.Rubiks_Quote__c,SBQQ__Quote__r.MDQ_Quote__c,Primary_Asset__r.Acct_Prefix__c,SBQQ__Quote__r.Instance_Rollup__c ,Primary_Asset__c,(SELECT id,Production_Asset__c,Acct_Prefix__c FROM Assets__r WHERE Purpose__c='Sandbox' and Acct_Prefix__c!=null limit 1) FROM Contract WHERE SBQQ__Opportunity__c=:PriorOpptyId];
                            //System.debug('Contractlist=============='+Contractlist[0].id);
                          if(primaryQuote.SBQQ__Opportunity2__r.type == Label.OPPORTUNITY_TYPE_RENEWAL && primaryQuote.Rubiks_Quote__c == TRUE ){

                              if(!Contractlist.isEmpty() ){
                                  Contract  cont = Contractlist[0];
                                   if(this.opportunity.Account_String__c == null){
                                        this.opportunity.Account_String__c = cont.Primary_Asset__r.Acct_Prefix__c!=NULL ? cont.Primary_Asset__r.Acct_Prefix__c:primaryQuote.SBQQ__Opportunity2__r.Account_String__c;
                                   }//End of If
                                   id primaryAsetId      = cont.Primary_Asset__c;
                                  
                                   if(primaryAsetId!=null){
                                    list<Asset> SandboxAsset = [SELECT id,Production_Asset__c,Acct_Prefix__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Rubiks_Quote__c FROM Asset WHERE Production_Asset__c=:primaryAsetId AND purpose__c='Sandbox' AND Acct_Prefix__c!=null AND SBQQ__QuoteLine__r.SBQQ__Quote__r.Rubiks_Quote__c=TRUE limit 1];
                                        if(!SandboxAsset.isEmpty()){
                                            //this.opportunity.Sandbox_account_prefix__c =  SandboxAsset[0].Acct_Prefix__c;
                                        }
                                   }//End of IF block
                                  
                              }//End of IF of Contractlist Enpty check
                          }//End of OPPORTUNITY_TYPE_RENEWAL check
                         
                    }
                    if(primaryQuote.SBQQ__Opportunity2__r.type == Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL && this.opportunity.Account_String__c==null && primaryQuote.SBQQ__MasterContract__r.Primary_Asset__r.Acct_Prefix__c!=null){
                          this.opportunity.Account_String__c =  primaryQuote.SBQQ__MasterContract__r.Primary_Asset__r.Acct_Prefix__c;
                    }
                }//End of IF of Quote list empty check
            }//End of Upsell and Renewal Opty
            }
           
            PageReference pr = sc.save();
            // return user to page to see errors immediately if problem saving
            if (this.sc.getRecord().Id == null || pr == null) {
                return null;
            }
            //snapshot.Opportunity__c = sc.getId();
            //upsert snapshot;
            /*Grazitti - Used to add the contact role for a particular opportunity - Starts here - Switched Off as Part of APPS-11656*/
            if(contIds != null && isNewOpportunity){
                OpportunityContactRole oc  = new OpportunityContactRole();
                oc.ContactId = contIds;
                oc.OpportunityId = sc.getId();
                oc.IsPrimary = true;
                
                insert oc;
            }
            /*Grazitti - Used to add the contact role for a particular opportunity - Ends here*/ 
            OpportunityCreateBOFU.inBofuScreen = false;
            if (this.opportunity.StageName == 'Signed Order') {

                /***CODE EDITED BY GRAZITTI TO IMPLEMENT SALES OPS FUNCTIONALITY-STARTED*/      
                String caseRecordTypeforSales = Case.sObjectType.getDescribe().getRecordTypeInfosByName().get(System.Label.CASE_RECORD_TYPE_SalesCases).getRecordTypeId();    
                List<String> fieldsIds = new List<String>(System.Label.SalesOps_CaseFieldsToBeAutoPopulated.split('#'));
                 
                String redirectUrl = '/500/e?ent=Case&nooverride=1';  
                if(!fieldsIds.isEmpty() && fieldsIds.size()==3){
                    redirectUrl += '&'+fieldsIds[0]+'=0&RecordType='+caseRecordTypeforSales+'&'+fieldsIds[1]+'='+o.Name;
                    List<Account> acc = new List<Account>([SELECT Name From Account WHERE Id=: o.AccountId]);
                    if(!acc.isEmpty()){
                        redirectUrl += '&'+fieldsIds[2]+'='+acc[0].Name;
                    }                
                }   
                
                PageReference SalesCaseCreatePage = new PageReference(redirectUrl);
                return SalesCaseCreatePage;
                /***CODE EDITED BY GRAZITTI TO IMPLEMENT SALES OPS FUNCTIONALITY ---ENDED*/
                
                
            } else {
                return pr;
            }
            
        } catch (Exception e) {
            ApexPages.addMessages(e);
        }
        return null;
    }
    public void stageChange() {
        if (o.StageName == 'Signed Order') {
            clearFieldsForSignedOrder(o);
        }
    }
    
    @TestVisible
    private static void applyParameterValues(Opportunity o) {
        // standard record type selector does not have "Id" at the end of param name
        String recordTypeId = System.currentPageReference().getParameters().get('RecordType');
        if (recordTypeId != null) {
            o.put('RecordTypeId', recordTypeId);
        }

        Set<String> blacklistedFields = new Set<String>{'id'};
        for (String k : System.currentPageReference().getParameters().keySet()) {
            if (blacklistedFields.contains(k.toLowerCase())) continue;
            try {
                /*Code Added By Grazitti for checking if Date parameter is Empty or not - Starts*/
                if(k != 'Date_Referral_Submitted__c'){
                    if(System.currentPageReference().getParameters().get(k) != null && !String.isEmpty(System.currentPageReference().getParameters().get(k)) && System.currentPageReference().getParameters().get(k) != 'null'){
                        o.put(k, System.currentPageReference().getParameters().get(k));
                    }
                }
                
                if(k == 'Date_Referral_Submitted__c'){
                    if(!String.isEmpty(System.currentPageReference().getParameters().get(k))){
                        o.put(k, Date.parse(System.currentPageReference().getParameters().get(k)));
                    }
                }
                 /*Code Added By Grazitti for checking if Date parameter is Empty or not - Ends*/
            } catch (System.SObjectException e) {
                // ignore
            }
        }
    }
    @TestVisible
    private static void clearFieldsForSignedOrder(Opportunity o) {
        // clear fields to ensure that the values are correct
        Set<String> fieldsToClear = new Set<String>{
            'CRM_System__c'
        };
        for (String s : fieldsToClear) {
            o.put(s, null);
        }
    }
    
    @TestVisible
    private static Account loadAccountOverride;

    @TestVisible
    private void loadAccount(Opportunity o) {
        if (o.Id != null) {
            this.account = loadAccountOverride != null ? loadAccountOverride : [
                select Account.Id, 
                Account.Accounting_Contact_First_Name__c, 
                Account.Accounting_Contact_Last_Name__c, 
                Account.Accounting_Email__c,
                Account.CAM_Assign_Status__c,
                Account.ParentId,
                Account.Parent.CAM_Owner__c,
                Account.Parent.CAM_Group__c,
                Account.CAM_Group__c,
                Account.CAM_Owner__c
                from Opportunity 
                where Id = :o.Id
            ].Account;
        } else {
            this.account = new Account();
        }
    }

    @TestVisible
    private void updateAccount(Account account) {
        if (account != null && account.Id != null) {
            update account;
        }
    }
    public static Boolean isBofuAdditionalFieldsEnabled(){
        for (User u : [select Id, BOFU_CAM_Fields_During_Signed_Order__c from User where Id = :UserInfo.getUserId()]) {
            return u.BOFU_CAM_Fields_During_Signed_Order__c == true;
        }
        return false;
    }
    
    public Opportunity getO(){
        return this.o;
    }
    
    public void setO(Opportunity o){
        this.o = o;
    }
    
    public Opportunity getOpportunity(){
        return this.opportunity;
    }
    
    public void setOpportunity(Opportunity opportunity){
        this.opportunity = opportunity;
    }
    /****************************************************************
    * Last Modified By   : Sumit Bhatt, Grazitti
    * Last Modified Date : 18th October 2017
    * Changes            : Created two new functions for the Main Integration Partner and Main Implementation Partner, 
    so as to dynamically update the values of the Dropdown fields based on the prior value of selection. 
    **********************************************************************/
    
    public void set_mainintegrationpartner(){
        if(o.Who_Will_Integrate_Customer__c == 'Marketo Professional Services'){
            o.Main_Integration_Partner__c = Label.MainIntegrationPartner; 
        }else if(o.Who_Will_Integrate_Customer__c == 'Self'){
            o.Main_Integration_Partner__c = o.AccountId; 
        }else{
            o.Main_Integration_Partner__c =null;
        }
    }
    public void set_mainimplementationpartner(){
        if(o.Who_Will_Implement_Customer__c == 'Marketo Professional Services'){
            o.Main_Implementation_Partner__c = Label.MainImplementationPartner; 
        }else if(o.Who_Will_Implement_Customer__c == 'Self'){
            o.Main_Implementation_Partner__c = o.AccountId; 
        }else{
            o.Main_Implementation_Partner__c =null;
        }
    
    }
    // ********* APPS-20849 Delivery Source Fields on Opportunity and BOFU Page ***********
    public void actionDeliverySource(){
     if(o.Delivery_Source__c == 'Must be Staffed Internally'){
         showDeliverySource = true;
     }else{
         showDeliverySource = false;
     }
    
    }
}