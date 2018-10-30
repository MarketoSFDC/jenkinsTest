/* *******************************************************************************************************
 # Modified By grazitti interactive on 21/8/18
 # APPS-22357 - Update Account From customer to Ex-customer 
 # Date : (20-sep-2018)   
 # Trace the changes by seaching the ticket no 
**********************************************************************************************
Updated by       : Sumit Bhatt, Grazitti
Updated On       : 23 Nov 2017
Updated for      : Added code for Populating the TIER values for the new Product Content AI - OLI_TIER_7 REF:APPS-16624 
           Method Edited - updateOpptyLines
           lines modified [1012,1101,1105-1108]

Updated by       : Aman Gupta, Grazitti
Updated On       : 23 May 2018
Updated for      : Added code for truncatinate the size of Product_SVS as per the ticket APPS-20034
           
*********************************************************************************************************/

/* *******************************************************************************************************
Updated by       : Sumit Bhatt, Grazitti
Updated On       : 16 Nov 2017
Updated for      :# Reference: APPS-15482:Change to Renewal Owner Logic
                  # Changed the logic for renewal opportunity owner assignment

Updated by: Jade Global Inc.
Updated On: 4th June 2017
Updated for: 
# Reference: Added Code for SDR owner Functinality
# Jira Ticket: APPS-13173: Tasks in the Requirement document for Sprint 4

/*----------------------------------------------------------
       * Modified by Sumit Bhatt 19-March-18 
       * APPS-17919 - Decommission Cross object formula fields that are not used on Opp Merge three workflow
       * One can find the usage by searching the ticket number in code
---------------------------------------------------------------------------------------------------------*/


/***********************
Updated by: Rajesh Wani, Jade Global Inc.
Updated On: 2nd May 2017
Updated for: 
    # JIRA Ticket Reference: APPS-13409-quote end date is not reflecting correctly  
    # Modified the Line no 380 to populate the correct Master Sub End Date on Opportunity
Last modified by :Rajesh Wani,Jade global Inc
Updates : Popuating Account_String__c on Opportunity from method populateDateFieldOnOpprotunity
Line:365,435-446
Last Modified by : Priyanka Shende, Jade global Inc
Purpose : populating Account_String__c on Opportunity, Method - populateDateFieldOnOpprotunity
             1. On Renewal opportunity - populate Account_String__c from Primary asset prefix of renewal contract of its Opportunity.
             2. If Primary asset prefix(renewal) or Quote Quote Asset Name(Upsell) length> 255 truncate as the Account_String__c length is 255.
Line: 370, 445-452 & 454-458  
Last Modified: Priyanka Shende, Jade Global,12th June 2017 
Purpose      : Commented the Account String Population logic as populating from BOFU(Signed Order) Page.             

Last Modified By : Jade Global Inc, on 6th June 2017
Purpose          : Populate Bill-To and Ship-To Contact on Account while closure of the Opportunity
Line No          : 727 to 758
********************************************************************************************************** */

/************************************************************************
Updated by: Sumit Bhatt,Grazitti Interative
Updated On: 2-Nov-2017
Updated for: 
Updated for:      # Reference: APPS-15090
                  # Abbreviate long account names on renewal opportunities 
                    Line: 431
*************************************************************************/
/* ***********************************************************************
Updated by: Jade Global Inc
Updated On: 10th Feb 2018
Updated for: As Part of Financial force deployment- OpportunityCreateBOFU.opportunityTriggerHandler Method should not run for Automated Process user

Last Modified By: Jade Global Inc, on 19th April 2018. JIRA:  APPS-18492
Purpose         : Added OR Condition for populating Adjusted POR - as If OLI -> Quote -> MKTO Effective End Date != Opportunity -> Master Sub End Date then run logic for populating Adjusted POR of future Renewal
********************************************************************************************** */

/************************************************************************************************
Last Modified By: Jade Global Inc On 19th May 2018
Updated for: As part of Churn Winback Automation,added Churn Winback condition to avoid overriding of Adjusted POR for Churn Winback Opportunity.

LastModifiedBy: Jade Global Inc. On 23rd May 2018
Purpose       : Convert  Adjusted POR Currency into the changed opportunity currency
                REFERENCED JIRA: APPS-9339 and APPS-17240
************************************************************************************************
Modified by Sumit Bhatt 19-July-18
   * APPS-21703 AEs unable to Close Lost an Opportunity
   * One can track the changes by searching the ticket number in code. 
***********************************************************************/
/********************************************************
Modified By : Tushar Misri, Grazitti Interactive
Modified Date: 8/11/2018
Purpose : Commented the field that are used in field removal project 
refrence : APPS-20840 Field Cleanup Project - Phase One
log of fields commented : Opportunity: billed_services__c,csm_email__c,are_services_included__c,sent_to_clarizen__c,ease_of_renewal__c,perceived_customer_value__c,
                                       requestedkickoffdate__c,implementation__c,edition__c,split_opportunity_last_payment_date__c,channel__c,sales_outbound_notes__c,
                                       projecttype__c,assigned_consultant_email__c,opportunity_source__c,pod_territory__c,quote_expiration_date__c,average_monthly_email_volume__c,
                                       web_traffic__c,lead_promotion_date__c,assigned_cem__c,service_only__c,sfdc_user__c,project_stage__c,product_interest__c,sales_lead_type__c,
                                       project_classification__c,project_type__c,project_start_date__c,solutions_consultant_email__c,servicesnotes__c,cf_opp_id__c,needs_internal_kickoff_meeting__c,
                                       enablement_percent_completed__c,non_standard_payment_terms__c,office_hours_purchased__c,oa_partner_involved__c,employee_range_summary__c,enablement_close_notes__c,
                                       enablement_completion_date__c,manual_apor_adjustment__c,marketo_subscription_plan__c,pod__c,sc_enablement_notes__c,additional_enablement_partner__c,
                                       tracking_url__c,sfdc_users__c,project_temperature__c,marketo_login__c,marketo_password__c,demo_type__c,reason_lost_to_competitor__c,credit_comments__c,
                                       marketo_subscription_subplan__c,case_study_permission__c,sdr_upsell_owner__c,cssclass__c,days_since_lead_promotion__c,days_to_sales_lead__c,pay_referral__c,
                                       openair_percent_complete_del__c,oa_product_purchased_del__c,primary_marketo_user_phone__c,enablement_project_stage__c,services_required__c,original_lead_created_date__c,
                                       rep2__c,mp_sandbox__c,partner_involved_del__c,MKT_User__c,RT__c,solutions_consultant_lookup__c

* Last Modified By: Jade Global Inc, on 8th September 2018
* Purpose         : To handle Phoenix Provisioning Scenarios
                    - Added BOFU logic on Opportunity Signed order Stage.
                    1. Populate Data Center field - check the Primary Quote - Country and accordingly populate the Data Center field on signed order based on the Data Center custom setting values.
                    2. Populating the Provisioning_Type__c on Renewal opportunity based on current and previous quote.
                    3. Populating Account_String__c on Upsell opportunity from primary asset present on Master Contract        present on Quote
                    4. Populating Account_String__c on RenewalOpportunity opportunity from primary asset present on Master    Contract on Quote
************************************************************************************* */
public class Trigger_Opportunity_Helper {
    /**
        #-VARIABLES HUB -- STARTED
    **/
    //BELOW ARE THE MASTER/FINAL LISTS AND MAP TO BE USED FOR DML OPERATION
    public static Map<Id, Account> ACCOUNT_MASTER_LIST          = new Map<Id, Account>();
    public static Map<Id, Contact> CONTACTS_MASTER_LIST         = new Map<Id, Contact>(); 
    public static Map<Id, Asset> ASSETS_MASTER_LIST             = new Map<Id, Asset>();
    public static Map<Id, OpportunityLineItem> OLI_MASTER_LIST  = new Map<Id, OpportunityLineItem>();
    public static List<MKT_Payment__c> MKT_PAYMENT_MASTER_LIST  = new List<MKT_Payment__c>();
  Public static Map <id,opportunity> MapoppAfterUpdate=new Map <id,opportunity>();
    public static Map<Id, Opportunity> opptyMapforCLZ           = new Map<Id, Opportunity>();
  public static List<opportunity> oppToUpdate=new List<opportunity>();
    /**----------------------------------------------------------
    BELOW ARE THE STATIC VARIABLES TO HANDLES RECURSSION IN TRIGGER
    ------------------------------------------------------------**/
    public static boolean isBeforeInsertEvent     = false;
    public static boolean isBeforeUpdateEvent     = false;
    public static boolean isBeforeDeleteEvent     = false;
    public static boolean isAfterInsertEvent      = false;
    public static boolean isAfterUpdateEvent      = false;
    public static boolean isAfterDeleteEvent      = false;
    
    /**------------------------------------------------------------------------
    #BELOW ARE THE VARIABLE THAT ARE USED TO AVOID THE HARDCODED VALUES IN THE CODE 
    ------------------------------------------------------------------------**/
    public static String RENEWAL_OPPTY                              = Label.OPPORTUNITY_TYPE_RENEWAL;
    public static String UPSELL_CROSSELL_OPPTY                      = Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL;
    public static String CLOSED_WON_OPPTY                           = Label.OPPORTUNITY_STAGE_CLOSED_WON;
    public static String NEW_BUSS_OPPTY                             = Label.OPPORTUNITY_TYPE_NEW_BUSINESS;
    public static String CLOSE_LOST_OPPTY                           = Label.OPPORTUNITY_STAGE_CLOSED_LOST;
    public static String SIGNED_ORDER_OPPTY                         = Label.OPPORTUNITY_STAGE_SIGNED_ORDER;
    public static String SIGNED_ORDER_6_OPPTY                       = Label.OPPORTUNITY_STAGE_6_SIGNED_ORDER;
    public static String OPPTY_PRODUCT_TYPE_SERVICES                = Label.PRODUCT_TYPE_SERVICES;
    public static String OPPTY_DEAL_TYPE_REPLACEMENT_INSTANCE       = Label.OPPORTUNITY_DEAL_TYPE_REPLACEMENT_INSTANCE;
    public static String OPPTY_DEAL_TYPE_SANDBOX                    = Label.OPPORTUNITY_DEAL_TYPE_SANDBOX;
    public static String OPPTY_DEAL_TYPE_CREDIT                     = Label.OPPORTUNITY_DEAL_TYPE_CREDIT;
    public static String OPPTY_DEAL_TYPE_INSIGHTERA_HISTORICAL      = Label.OPPORTUNITY_DEAL_TYPE_INSIGHTERA_HISTORICAL;
    public static String OPPTY_DEAL_TYPE_DATARATI_CONVERSION        = Label.OPPORTUNITY_DEAL_TYPE_DATARATI_CONVERSION;
    public static String OPPTY_BOFU_SIGN_ORDER_VALIDATION_ERROR     = Label.OPPTY_BOFU_SIGN_ORDER_VALIDATION_ERROR;    
   
    /**---#TRIGGER PREREQUISTES, SETTING INITIALIZATION#---**/
    //GET THE STEELBRICK PRICEBOOK ID STORED IN THE CUSTOM SETTONG. VERY IMP** : PLEASE UPDATE PRODUCTION SB PRICEBOOK ID IN CUSTOM SETTINGS.  
    public static SteelBrickCPQPricebook__c SBPB = SteelBrickCPQPricebook__c.getOrgDefaults();
    //CHECKING THE BOFU WIZARD ENABLE FOR THE CURRENT LOGGED IN USER    
    public static Boolean bofuWizardEnabledForUser;// [SELECT BOFU_Wizard_Enabled__c FROM User WHERE Id = :UserInfo.getUserId()].BOFU_Wizard_Enabled__c;
    
    //This variable used in UpdatePrimaryProjectOnOpty method and its store the Financial Force Go Live Date
    public static Date FinancialForceGoLiveDate     = Date.newInstance(2018, 2, 10);
    /** #-VARIABLE HUB -- END **/     
    
  /*****************************************************
     * Modified By    :Jade Global(Rajesh Wani)
     * Modified Date  : 20th April 2016
     * Change         : Added new map PriorOppIdWithCloseDateMap to get CloseDate of Prior Oppty
    *****************************************************/
    public static Map<Id, date> PriorOppIdWithCloseDateMap  = new Map<Id, date>();
    static map<id,SBQQ__Quote__c> quoteMap= new map <id,SBQQ__Quote__c>();
  //Added by Jade on 29th March 2017
    static map<id,Quote> StandardQuoteMap = new map<id,Quote>();
    /**---------------------------------------------------
    #BELOW METHOD ADD THE PRICEBOOK ON THE OPPORTUNITY RECORD
    -----------------------------------------------------**/
    public static Opportunity opptyPriceBook(Opportunity opp){
        //if(opp.pricebook2id == null && opp.type != RENEWAL_OPPTY && opp.type != UPSELL_CROSSELL_OPPTY){
          //  opp.pricebook2id = SBPB.ID__c;
           // opp.SBQQ__QuotePricebookId__c = SBPB.ID__c;   
       // }//END OF IF CONDITION
        return opp;
    }//END OF OPPTYPRICEBOOK METHOD
    
    
    /**---------------------------------------------------
    #BELOW METHOD TO STORE THE IDs OF CLOSED WON OPPTY
    -----------------------------------------------------**/
    public static Set<Id> closeWonOpptyIds = new Set<Id>();
    
    public static Void isOpptywithCloseWonRecordType(Opportunity opp){
     /*****************************************
     Modified By :Jade Global 8th Sept 2018
           Change      : changed close won record type check to Iswon of Opportunity.
    
     */
        if(opp.iswon==true){
            closeWonOpptyIds.add(opp.id);
        }//END OF IF CONDITION
    }//END OF ISOPPTYWITHCLOSEWONRECORDTYPE METHOD
    
    /**-------------------------------------------------------------
    #BELOW METHOD HANDLES BOFU SIGNED ORDER VALIDATION ERROR MESSAGE
    -------------------------------------------------------------**/
    public static void BOFUSignOrderValidation(List<Opportunity> oldList, List<Opportunity> newList){
      string UserName =UserInfo.getName(); 
        if(Username!='Automated Process'){
            bofuWizardEnabledForUser = [SELECT BOFU_Wizard_Enabled__c FROM User WHERE Id = :UserInfo.getUserId()].BOFU_Wizard_Enabled__c;
          OpportunityCreateBOFU.opportunityTriggerHandler(oldlist, newlist, bofuWizardEnabledForUser);
          }
    }//END OF BOFUSIGNORDERVALIDATION METHOD
    
    
    /**---------------------------------------------------
    #BELOW METHOD POPULATE EXCHANGE RATE ON RENEWAL OPPTY- BEFORE INSERT
    -----------------------------------------------------**/
    public static Opportunity populateExchangeRateOnRenewalsOppty(Opportunity opp){
        if(opp.Type != null && opp.Type == RENEWAL_OPPTY && opp.Prior_Opportunity__c!=null && !PriorOppIdWithCloseDateMap.isEmpty() && PriorOppIdWithCloseDateMap.containsKey(opp.Prior_Opportunity__c)){
          // Get Clse Date of Prior Opportunity
            Date PriorOppCloseDate = PriorOppIdWithCloseDateMap.get(opp.Prior_Opportunity__c);
            opp = populateExchangeRate(opp, PriorOppCloseDate);
        }//END OF IF STATEMENT
        return opp;
    }//END OF POPULATEEXCHANGERATEONRENEWALSOPPTY METHOD
    
    public static Opportunity populateExchangeRate(Opportunity opp, Date ExchangeRateDate) {
        System.debug('ExchangeRateDate*********' + ExchangeRateDate);
        if(standardExchangeRatesMap.containsKey(opp.CurrencyIsoCode)){
            for(DatedConversionRate dateRate :standardExchangeRatesMap.get(opp.CurrencyIsoCode)) {
                System.debug('dateRate*********' + dateRate);
                if(dateRate.startdate  <= ExchangeRateDate && (daterate.NextStartDate==null || daterate.NextStartDate > ExchangeRateDate )) {
                    opp.Exchange_Rate_Plan_POR__c = dateRate.ConversionRate;
                    opp.Exchange_Rate_Plan_ARR__c = dateRate.ConversionRate;
                    System.debug('opp.Exchange_Rate_Plan_ARR__c*********' + opp.Exchange_Rate_Plan_ARR__c);
                    //break;
                }//END OF IF CONDITION
            }//END OF FOR LOOP DATEDCONVERSIONRATE
        }//END OF IF CONDITION
        return opp;
    }//END OF METHOD POPULATEEXCHANGERATE
    
    /**-----------------------------------------------------------------------------
    #METHOD TO CALCULATED ESTIMATED AMOUNT ON OPPORTUNITY BASED ON CURRENT EXCHANGE RATE
    -------------------------------------------------------------------------------**/
    public static opportunity opportunityCurrencyConversion(Opportunity opp){
        Map<String,List<DatedConversionRate>> CurrConvsMap  = getStandardExchangeRatesMap();
        if(opp.Amount!=null && opp.isclosed){
            opp.Est_USD_Amount__c = opp.Amount;
            if(CurrConvsMap.containsKey(opp.CurrencyIsoCode)){
                for(DatedConversionRate dateRate :CurrConvsMap.get(opp.CurrencyIsoCode)){
                    if(dateRate.startdate  <= opp.CloseDate && (daterate.NextStartDate == null || daterate.NextStartDate > opp.CloseDate)){
                        if(dateRate.ConversionRate != 0) opp.Est_USD_Amount__c = opp.Amount/ dateRate.ConversionRate;
                    }//END OF IF CONDITION
                }//End of FOR loop of DatedConversionRate
            }//End of ELSE loop
        }//END OF IF CONDITION
        return opp;
    }//END OF OPPORTUNITYCURRENCYCONVERSION METHOD  
    
    /**----------------------------------------
    #BELOW METHOD UPDATE CONTRACT ON OPPORTUNITY
    -----------------------------------------**/    
    public static List<Opportunity> closedOppList = new List<Opportunity>();
    public static List<Opportunity> RenwalOppList = new List<Opportunity>();
    public static Set<Id> contractIds             = new Set<Id>();   
    
    public static Opportunity updateOpportunityLists(Opportunity opp){
        if(opp.SBQQ__Contracted__c == true &&  !opp.iswon){
            opp.SBQQ__Contracted__c = false;
        }//END OF IF CONDITION
        if(opp.SBQQ__RenewedContract__c != null && opp.SBQQ__Renewal__c == true ){
            RenwalOppList.add(opp);
            contractIds.add(opp.SBQQ__RenewedContract__c);
        }//END OF IF CONDITION
        return opp;
    }//END OF UPDATEOPPORTUNITYLISTS METHOD
    
    /**-------------------------------------------------
    #BELOW METHOD POPULATES THE RENEWAL OPPORTUNITY FIELDS
    ---------------------------------------------------**/
    public static void populateRenwalOpptyFields(){
        if(!RenwalOppList.isEmpty() && !contractIds.isEmpty()){
            RenewalTriggerMappingController.populateRenwalOpportunityFields(RenwalOppList,contractIds);
        }//END OF IF CONDITION
    }//END OF POPULATERENWALOPPTYFIELDS METHOD
    
    /**------------------------------------------------------------
    #BELOW METHOD OWNER GEOGRAPHICAL INFORMATION BASED ON THEIR ROLE
    -----------------------------------------------------------**/   
    public static Map<string, Role_Geographical_Segmentation_Setting__c> roleGeoSegmentSetting = Role_Geographical_Segmentation_Setting__c.getAll();
    public static Opportunity updateOwnerRoleMapping (Opportunity opp, Map<Id,Opportunity> oldMap){
        //if( trigger.isUpdate && opp.IsClosed == True){// COMMENTING BECAUSE NOW THIS PROCESS WILL ALSO HANGLE THE FUNCTIONALITY OF quoteAftInsB4Upd TRIGGER  
            SalesTriggersUtility.isQuoteUpdatedFromOpportunityTrigger = true;
            opp.Owner_Role_Mapping__c = opp.OwnerId;
            opp.Owner_Manager__c      = opp.Owner_Manager_Id__c;
        //}//END OF IF CONDITION        
        if(opp.Owner_Role_Custom__c != null && roleGeoSegmentSetting.containsKey(opp.Owner_Role_Custom__c)){
            opp.ORC_Geo__c     = roleGeoSegmentSetting.get(opp.Owner_Role_Custom__c).Geo__c;
            opp.ORC_Group__c   = roleGeoSegmentSetting.get(opp.Owner_Role_Custom__c).Group__c;
            opp.ORC_Segment__c = roleGeoSegmentSetting.get(opp.Owner_Role_Custom__c).Segment__c;
            //opp.FP_A_Hierarchy_Child__c = roleGeoSegmentSetting.get(opp.Owner_Role_Custom__c).FP_A_Hierarchy_Child__c;
            //opp.FP_A_PS_Hierarchy_Parent__c = roleGeoSegmentSetting.get(opp.Owner_Role_Custom__c).FP_A_PS_Hierarchy_Parent__c;
           // opp.FP_A_Sales_Hierarchy_Parent__c = roleGeoSegmentSetting.get(opp.Owner_Role_Custom__c).FP_A_Sales_Hierarchy_Parent__c;
        }else if(opp.Owner_Role_Custom__c != null && !roleGeoSegmentSetting.containsKey(opp.Owner_Role_Custom__c)){
            opp.ORC_Geo__c     = '';
            opp.ORC_Group__c   = '';
            opp.ORC_Segment__c = '';
            //opp.FP_A_Hierarchy_Child__c = '';
            //opp.FP_A_PS_Hierarchy_Parent__c = '';  
           // opp.FP_A_Sales_Hierarchy_Parent__c = '';
        }//END OF ELSE IF CONDITION
        return opp;
    }//END OF UPDATEOWNERROLEMAPPING METHOD
    

    /**------------------------------------------------------------
    #BELOW METHOD TO POPULATE EXCHANGE RATE ON NB AND UPSELL/CROSELL
    -----------------------------------------------------------**/ 
    /*---------------------------------------------------------------
     *  Modified by  :  Jade 4th Feb 2015
     *  Modification : Changes the logic to populate the  Exchange_Rate_Plan_ARR__c
     *                Now using Opportunity CurrencyIsoCode to get Exchange rate from custom setting
     *                Previously we were using  Opportunity CurrencyIsoCode +  Opportunity Creattion Year to get Exchange rate from custom setting 
     * --------------------------------------------------------------*/
    public static Opportunity customExchangeRateImplementation(Opportunity opp,map<id,Opportunity> oldOppMap){
      if( trigger.isInsert || (trigger.isUpdate && oldOppMap.get(opp.id).isClosed==False && oldOppMap.get(opp.id).isClosed!=opp.isclosed)) {

        Map<string, MarketoCustomExchangeRates__c> customExchangeRates = getCustomExchangeRatesMap();
        if(opp.CurrencyIsoCode!=null && !customExchangeRates.isEmpty() && customExchangeRates.containsKey(opp.CurrencyIsoCode) && (opp.Type == NEW_BUSS_OPPTY || opp.Type == UPSELL_CROSSELL_OPPTY)) {
                opp.Exchange_Rate_Plan_ARR__c = customExchangeRates.get(opp.CurrencyIsoCode).Exchange_Rate__c;
              System.debug('opp.Exchange_Rate_Plan_ARR__c for NB and Upsell********' + opp.Exchange_Rate_Plan_ARR__c);
                opp.Exchange_Rate_Plan_POR__c = 1;
            }//END OF IF CONDITION
        }//END OF IF CONDITION  
        return opp; 
    }//END OF CUSTOMEXCHANGERATEIMPLEMENTATION METHOD
    
    /**-------------------------------------------------------------------
    #BELOW METHOD TO AUTO-PROVISION THE OPPORTUNITY WHEN IT IS CLOSED AS WON
    -------------------------------------------------------------------**/  
    public static List <Opportunity> opp_of_interest = new List <Opportunity>(); 
    public static Opportunity opptyAutoprovisingProcess(Opportunity Opp, Map<Id,Opportunity> oldMap){
        if (opp.Processed__c != true) {
         // Modified By :Jade Global 8th Sept 2018
         //  Change      : changed close won record type check to Iswon of Opportunity.

            if (opp.iswon== true && oldmap.get(opp.id).stagename!= opp.stagename){
                if(opp.stagename == CLOSED_WON_OPPTY && opp.Type == NEW_BUSS_OPPTY ){
                    opp_of_interest.add(opp);
                    opp.processed__c = true;
                }//END OF IF CONDITION
            }//END OF IF CONDITION
        }//END OF IF CONDITION
        return opp;
    }//END OF OPPTYAUTOPROVISINGPROCESS METHOD
    
    public static void processOpportunitiesProcess(){
        if(!opp_of_interest.isEmpty()){
            // HANDLES THE processOpportunities PROCESS
            OpportunityAutoProvisioning.processOpportunities(opp_of_interest);
        }//END OF IF CONDITION
    }//END OF PROCESSOPPORTUNITIESPROCESS METHOD
      
    /**------------------------------------------------------------------------------------
    #BELOW METHOD TO POPULATE SALES REGION FROM ACCOUNT BY USING FPRMULA FIELD INSTEAD OF QUERY
    ---------------------------------------------------------------------------------------**/   
    public static Opportunity updateSalesRegionFromAccinBeforeProcess(Opportunity Opp, Map<Id,Opportunity> oldMap){
        if(opp.StageName != oldMap.get(opp.Id).StageName && opp.StageName == CLOSED_WON_OPPTY){
            if(opp.Intacct_Sales_Region__c == null || opp.Intacct_Sales_Region__c == ''){
                opp.Intacct_Sales_Region__c = Opp.Account_Sales_Region__c;
            }//END OF IF CONDITION
        }//END OF IF CONDITION
        return opp;
    }//END OF UPDATESALESREGIONFROMACCINBEFOREPROCESS METHOD
    
    /**------------------------------------------------------------
    #BELOW METHOD TO MAKE THE CONTRACTED CHECKBOX TRUE.
    -----------------------------------------------------------**/ 
    public static opportunity updateSBQQ_Contracted(Opportunity opp, Map<Id,Opportunity> oldMap){
        if(opp.SBQQ__PrimaryQuote__c != null && opp.isclosed != oldmap.get(opp.id).isclosed && opp.iswon == true && opp.Split_Opportunity_Case_Safe_ID__c == null ){
            opp.SBQQ__Contracted__c = true;
        }//END OF IF CONDITION
        return opp;
    }//END OF UPDATESBQQ_CONTRACTED METHOD
    
    /**------------------------------------------------------------
    #BELOW METHOD TO CONVERT THE CURRENCY BASED ON CURRENT CONVERSION RATE.
    -----------------------------------------------------------**/ 
    public static opportunity opportunityCurrencyConversion(Opportunity opp, Map<Id,Opportunity> oldMap){
        map<string,list<DatedConversionRate>> CurrConvsMap  = getStandardExchangeRatesMap();
        if(opp.Amount!=null && opp.isclosed && oldmap.containsKey(opp.id) &&(opp.Amount!=oldmap.get(opp.id).amount ||  opp.isclosed != oldmap.get(opp.id).isclosed ||opp.closedate != oldmap.get(opp.id).closedate)){
            opp.Est_USD_Amount__c = opp.Amount;
            if(CurrConvsMap != null && CurrConvsMap.containsKey(opp.CurrencyIsoCode)){
                for(DatedConversionRate dateRate :CurrConvsMap.get(opp.CurrencyIsoCode)){
                    if(dateRate.startdate  <= opp.CloseDate && (daterate.NextStartDate==null || daterate.NextStartDate > opp.CloseDate)){
                        opp.Est_USD_Amount__c = opp.Amount/ dateRate.ConversionRate;
                    }
                }//End of FOR loop of DatedConversionRate
            }//End of ELSE loop
        }//END OF IF CONDITION
        return opp;
    }//END OF OPPORTUNITYCURRENCYCONVERSION METHOD

    
    /**------------------------------------------------------------------
    #BELOW METHOD TO POPULATE EXCHANGE RATE ON OPPPRTUNITY AFTER CLOSED WON
    -------------------------------------------------------------------**/ 
    public static Map<String,List<DatedConversionRate>> CurrDatedConRateMap  = new Map<String,List<DatedConversionRate>>();
    public static Map<String,List<DatedConversionRate>> CurrentDatedConRateMap(){
    
        if(CurrDatedConRateMap.isEmpty()){
            List<DatedConversionRate> dateConversionExchangeRate2 = retrieveExchangeRate();
            
            if(!dateConversionExchangeRate2.isEmpty()){
                for(DatedConversionRate dateCon : dateConversionExchangeRate2){
                    if(CurrDatedConRateMap.containsKey(dateCon.IsoCode)){
                         CurrDatedConRateMap.get(dateCon.IsoCode).add(datecon);
                    }else{
                        CurrDatedConRateMap.put(dateCon.IsoCode, new list<DatedConversionRate> {datecon});
                    }//END OF ELSE CONDITION
                }//END OF FOR LOOP OF DATEDCONVERSIONRATE
            }//END OF IF CONDITION
        }//END OF IF CONDITION
        return CurrDatedConRateMap;
    }//END OF CURRENTDATEDCONRATEMAP METHOD
    public static Opportunity updateOpptyExchangeRate(Opportunity opp){       
        Map<String,List<DatedConversionRate>> CurrDatedConRateMap2  = CurrentDatedConRateMap();   
        // Create map of currency and dated exchange rate 
        if(!CurrDatedConRateMap2.isEmpty()){
            // Put exchange rate on opportunity
            if((opp.stageName != '') && (opp.stageName == CLOSED_WON_OPPTY) && (opp.isWon == true)){
                if(CurrDatedConRateMap2.containsKey(opp.CurrencyIsoCode)){
                    for(DatedConversionRate dateRate :CurrDatedConRateMap2.get(opp.CurrencyIsoCode)){
                        if(dateRate.startdate  <= opp.closedate && (daterate.NextStartDate == null || daterate.NextStartDate > opp.closedate)){
                            opp.Exchange_Rate__c = dateRate.ConversionRate;
                        }//END OF IF CONDITION
                    }//END OF FOR LOOP OF DATEDCONVERSIONRATE
                }//END OF IF CONDITION
            }//END OF IF CONDITION       
        }//END OF IF CONDITION  
        return opp;      
    }//END OF METHOD UPDATEOPPTYEXCHANGERATE
    
    /**------------------------------------------------------------------
    #BELOW METHOD TO POPULATE RENEWAL OWNER ON ACCOUNT FROM OPPORTUNITY 
    -------------------------------------------------------------------**/
    public static Map<Id, Account> renewalTargetAccs = new Map<Id, Account>(); 
    public static void updateRenewalsOwnerOnAccountOnOpptyCreation(Opportunity opp){
        if(opp.AccountId != null && opp.Type == RENEWAL_OPPTY && (opp.OwnerId != opp.Renewals_Owner_Id__c)){
            Account targetAc = retrievePartiallyUpdatedAccount(opp.AccountId);
            targetAc.Renewals_Owner__c = opp.OwnerId;
            ACCOUNT_MASTER_LIST.put(targetAc.Id, targetAc);
        }//END OF IF CONDITION
        
               
        
    }//END OF UPDATERENEWALSOWNERONACCOUNTONOPPTYCREATION METHOD
    
    /**------------------------------------------------------------------
    # Modified By grazitti interactive on 21/8/18
    # APPS-22357 - Update Account From customer to Ex-customer 
    -------------------------------------------------------------------**/
    
    public static void updateSetAccounttypeInClosedLost(List<Opportunity> newTrigger,Map<Id,Opportunity> newmap,List<Opportunity> oldlist, Map<Id,Opportunity> oldMap){
        set<id> Accountsid = new set<id>(); 
        list<Account> updaacc = new list<Account>();
        if(trigger.isinsert){                           
            for(opportunity opp : newtrigger){
                if(opp.type == 'Renewal' && (opp.stageName!= 'Closed Won' || opp.stageName!= 'Closed Lost') && opp.CloseDate >= date.newInstance(2014,03,01)){
                    Accountsid.add(opp.AccountId);              
                }
            }       
        }
        if(trigger.isdelete){                           
            for(opportunity opp : oldlist){
                if(opp.type == 'Renewal' && (opp.stageName!= 'Closed Won' || opp.stageName!= 'Closed Lost') && opp.CloseDate >= date.newInstance(2014,03,01)){
                    Accountsid.add(opp.AccountId);              
                }
            }       
        }
        
        if(trigger.isupdate){
            for(opportunity opp : newtrigger){
                if(opp.type == 'Renewal' && (oldmap.get(opp.id).StageName != 'Closed Won' || oldmap.get(opp.id).stageName != 'Closed Lost') && opp.CloseDate >= date.newInstance(2014,03,01) && (opp.type != oldmap.get(opp.id).type || opp.stageName != oldmap.get(opp.id).stageName || opp.CloseDate != oldmap.get(opp.id).CloseDate)){
                    Accountsid.add(opp.AccountId);              
                }
            }       
        }
        for(Account aa : [select id,name,Number_of_Open_RenewalOpportunities_RUSF__c,(select id,name,stageName,CloseDate,type from opportunities where type = 'Renewal' and  stageName!= 'Closed Won' and stageName!= 'Closed Lost' and CloseDate >= 2014-03-01)from Account where id in : Accountsid]){
                aa.Number_of_Open_RenewalOpportunities_RUSF__c = aa.opportunities.size(); 
            updaacc.add(aa);
           }
            if(updaacc!= null){
                update updaacc;
            }         
    
        
    }
    /**------------------------------------------------------------------
    # End of - APPS-22357 - Update Account From customer to Ex-customer 
    -------------------------------------------------------------------**/
    
  /**------------------------------------------------------------
    * Modified by :Jade 13th May 2016
    * This is used to populate the Sub_Start_Date__c(Master Sub Start Date ) from Quote using the formula field Quote_Start_Date__c
    -----------------------------------------------------------**/ 
    public static void populateDateFieldOnOpprotunity(list<Opportunity> newopp,Map<id,Opportunity> oldMap){
      set<id> QuoteIds  =  new set<id>(); 
    //Added by Jade on 29th March 2017
     set<id> StandardQuoteIds  =  new set<id>(); 
     //map<id,SBQQ__Quote__c> quoteMap= new map <id,SBQQ__Quote__c>();
     for(opportunity opp :newopp){
         if(opp.SBQQ__PrimaryQuote__c!=null){
            QuoteIds.add(opp.SBQQ__PrimaryQuote__c);
         }
         //Added by Jade on 29th March 2017     
        if(opp.SyncedQuoteId != null){      
            StandardQuoteIds.add(opp.SyncedQuoteId);        
     }
     }

     if(quoteMap.isEmpty() && !QuoteIds.isEmpty()){
         quoteMap= new map<Id,SBQQ__Quote__c>([SELECT Id,SBQQ__SubscriptionTerm__c,MKTO_Effective_End_Date__c,Rubiks_Quote__c,SOW_Special_Terms__c,Promotional_End_Date__c,SBQQ__Primary__c,Payment_Frequency__c,Required_Max_Contact_Records__c,SBQQ__Type__c,SBQQ__StartDate__c,SBQQ__EndDate__c,SBQQ__Account__r.CAM_Owner__c,SBQQ__Account__r.CRT_Owner__c,SBQQ__PaymentTerms__c,New_Instance_or_Change_to_Existing__c,Opportunity_Type__c ,SBQQ__Account__r.Name,CreatedDate,SBQQ__Opportunity2__r.CreatedDate,Blended_Discount__c,Asset_Name__c ,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Primary_Asset__r.name,SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Primary_Asset__r.Acct_Prefix__c,SBQQ__MasterContract__r.Primary_Asset__r.Acct_Prefix__c,SBQQ__Opportunity2__c,SBQQ__Opportunity2__r.type,SBQQ__Opportunity2__r.Prior_Opportunity__c,MDQ_Quote__c,Instance_Rollup__c,SBQQ__Opportunity2__r.Account_String__c,SBQQ__MasterContract__r.SBQQ__Quote__r.Instance_Rollup__c,SBQQ__ShippingCountry__c,SBQQ__LineItemsGrouped__c,SBQQ__Opportunity2__r.Data_Center__c,SBQQ__Opportunity2__r.StageName,SBQQ__Account__r.CAM_Group__c,SBQQ__Account__r.New_Business_Account_Executive__c,(select id From SBQQ__LineItemGroups__r) FROM SBQQ__Quote__c WHERE id IN :QuoteIds]);    
      
      }
      
     if( !quoteMap.isEmpty()){
     for(opportunity opp :newopp){
         if(quoteMap.containsKey(opp.SBQQ__PrimaryQuote__c )){
            SBQQ__Quote__c qo =quoteMap.get(opp.SBQQ__PrimaryQuote__c);

            if(opp.Maximum_Database_Size__c!= qo.Required_Max_Contact_Records__c && qo.Required_Max_Contact_Records__c!=null && qo.Rubiks_Quote__c!=True){
                opp.Maximum_Database_Size__c  =  qo.Required_Max_Contact_Records__c;
            }
            if(opp.Sub_Start_Date__c!= qo.SBQQ__StartDate__c&& qo.SBQQ__StartDate__c!=null){
                    opp.Sub_Start_Date__c         =  qo.SBQQ__StartDate__c;
            }
           
            if(opp.Payment_Terms__c!= qo.SBQQ__PaymentTerms__c && qo.Promotional_End_Date__c!=null){
                opp.Payment_Terms__c          =  qo.SBQQ__PaymentTerms__c;
            }
            if(qo.SBQQ__SubscriptionTerm__c!=null && qo.SBQQ__Type__c!='Amendment' && qo.SBQQ__StartDate__c!=null && qo.New_Instance_or_Change_to_Existing__c!='Change to Existing Instance'){
                    opp.Sub_End_Date__c = qo.SBQQ__StartDate__c.addMonths(Integer.valueOf(qo.SBQQ__SubscriptionTerm__c)).adddays(-1);
            }
            
            if( qo.Opportunity_Type__c=='Upsell/Crossell' && qo.SBQQ__EndDate__c!=null && qo.New_Instance_or_Change_to_Existing__c=='Change to Existing Instance'&& qo.Rubiks_Quote__c==FALSE && qo.MKTO_Effective_End_Date__c!=null){
                    opp.Sub_End_Date__c = qo.MKTO_Effective_End_Date__c;
            }
             /*if(qo.SBQQ__Type__c!='Amendment' && qo.SBQQ__EndDate__c!=null){
                    opp.Sub_End_Date__c =qo.SBQQ__EndDate__c;
            }*/
           
            if(opp.Payment_Frequency__c!= qo.Payment_Frequency__c && qo.Payment_Frequency__c!=null ){
                opp.Payment_Frequency__c      =  qo.Payment_Frequency__c;
            }
           
            if(opp.Promotional_End_Date__c!= qo.Promotional_End_Date__c  && qo.Promotional_End_Date__c!=null){
                opp.Promotional_End_Date__c   =  qo.Promotional_End_Date__c;
            }
           
       //Added for Renewal opportunity name and owner only     
      datetime createdateTimeOpp =qo.SBQQ__Opportunity2__r.CreatedDate.addMinutes(2);
           

            if( qo.CreatedDate<=createdateTimeOpp && opp.createddate<qo.CreatedDate && opp.type==Label.OPPORTUNITY_TYPE_RENEWAL && opp.Migration__c==false){            
                Opp.Name=qo.SBQQ__Account__r.Name.abbreviate(95) +' - '+ Label.OPPORTUNITY_TYPE_RENEWAL +' - '+ string.valueof(Opp.CloseDate.year());
                String OWNER_ID;
                //Conditions for CRT Owner added by Cassandrea on 10.17.16 for APPS-15482
                if (qo.SBQQ__Account__r.CRT_Owner__c != null && OWNER_ID != qo.SBQQ__Account__r.CRT_Owner__c){
                    OWNER_ID = qo.SBQQ__Account__r.CRT_Owner__c;
                }else if (qo.SBQQ__Account__r.CRT_Owner__c == null && qo.SBQQ__Account__r.CAM_Owner__c != null){
                    OWNER_ID = qo.SBQQ__Account__r.CAM_Owner__c;
                }
                    if(OWNER_ID != null){
                    Opp.OwnerId=OWNER_ID;
                }
            
            } 
            //Commented as per APPS-20840
            // To populate the Project_Classification__c on Opportunity
            /*if(qo.SOW_Special_Terms__c!=null && opp.Project_Classification__c!='C'){
                     opp.Project_Classification__c  = 'C';      
             }*///End of if loop of update of Project_Classification__c on Opportunity
            
              //Added by Jade on 29th March 2017
           //This is to populate the Blended Discount on opportunity on closed won
           if(Opp.isWon == TRUE && oldMap.get(Opp.id).isWon == FALSE && qo.Blended_Discount__c != null){
               Opp.CPQ_Blended_Discount__c = qo.Blended_Discount__c;
           }//End of IF - Blended Discount Population
           
           /* **********************************************
              * Last Modified: Priyanka Shende, Jade Global,12th June 2017 
              * Commented the Account String Population logic as populating from BOFU(Signed Order) Page.
              * APPS-11883
              * Updates:1.Account_String__c on Renewal opportunity from Primary asset Acct_Prefix__c of renewal contract of Opportunity
              *         2.Account_String__c on Upsell  opportunity from  SBQQ__MasterContract Primary asset Acct_Prefix__c of Quote  
               
              if(opp.Account_String__c==NULL && Opp.Type== RENEWAL_OPPTY  && qo.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Primary_Asset__r.Acct_Prefix__c!=null  ){
                     opp.Account_String__c = qo.SBQQ__Opportunity2__r.SBQQ__RenewedContract__r.Primary_Asset__r.Acct_Prefix__c;
                     
              }
              if(opp.Type==UPSELL_CROSSELL_OPPTY && opp.Account_String__c==null &&  qo.SBQQ__MasterContract__r.Primary_Asset__r.Acct_Prefix__c!=null){
                   opp.Account_String__c = qo.SBQQ__MasterContract__r.Primary_Asset__r.Acct_Prefix__c;
                  
              }
             
             *********************************************** */
            }//END OF IF CONDITION
        }//End of FOR loop
      }//End of Quote IF Block 
      //This IF loop will populate the Blended Discount on Opportunity if the Primary quote is Legacy/Standard Quote
     if(StandardQuoteMap.isEmpty() && !StandardQuoteIds.isEmpty()){
        StandardQuoteMap = new map<Id,Quote>([SELECT Id,Blended_Discount__c FROM Quote WHERE id IN :StandardQuoteIds AND Blended_Discount__c != null]);  
    
       For(Opportunity Opp: newOpp){
         if(StandardQuoteMap.ContainsKey(Opp.SyncedQuoteId)){
           Quote qt = StandardQuoteMap.get(Opp.SyncedQuoteId);
           if(Opp.isWon == TRUE && oldMap.get(Opp.id).isWon == FALSE){
             Opp.CPQ_Blended_Discount__c = qt.Blended_Discount__c;
           }//End of IF
         }//End of IF
       }//End of FOR
     }//END of IF Loop
      OpportunityBOFUPagePopulation(newopp,quoteMap);
    }//END OF populateDateFieldOnOpprotunity METHOD
  
  /* ----------------------------------------------------------
       * Modified by Sumit Bhatt 19-March-18 
       * APPS-17919 - Decommission Cross object formula fields that are not used on Opp Merge three workflow
---------------------------------------------------------------------------------------------------------*/
    //#APPS-17919#-Start
    Public static void getOpportunityMapOnAfterUpdate(){
        Map<id,opportunity> mapnew=new Map<id,opportunity>([select id,name,/*Solutions_Consultant_Lookup__c,Solutions_Consultant_Lookup__r.email,Solutions_Consultant_Email__c,*/SBQQ__PrimaryQuote__c,SBQQ__PrimaryQuote__r.Enterprise_Roll_up_SKU__c,SBQQ__Contracted__c,SBQQ__Renewal__c,SBQQ__RenewedContract__c,SBQQ__RenewedContract__r.Enterprise_Roll_up_SKU__c,Accountid,Account.CAM_Owner__c,Account.CAM_Owner__r.email,CAM_Owner_Email__c,StageName from opportunity where id in :trigger.newmap.keyset()]);
        MapOppAfterUpdate=mapnew;
    }
    public static void workflowActions(opportunity oppnew, opportunity oppold,list<opportunity> newlist){
        if(trigger.isupdate && trigger.isafter && !MapOppAfterUpdate.isempty() && !isBeforeInsertEvent){
            opportunity opp=new opportunity(id=oppnew.id);
             //commented as per APPS-21703
            //code to populate Solution consulatant email on update
            /*if(oppnew.Solutions_Consultant_Lookup__c!=null && MapoppAfterUpdate.containskey(oppnew.id) && MapoppAfterUpdate.get(oppnew.id).Solutions_Consultant_Lookup__c!=null && MapoppAfterUpdate.get(oppnew.id).Solutions_Consultant_Lookup__r.email!=null && oppnew.name!=null){
                opp.Solutions_Consultant_Email__c=MapoppAfterUpdate.get(oppnew.id).Solutions_Consultant_Lookup__r.email;
            }
            else if(oppnew.Solutions_Consultant_Lookup__c==null){
                opp.Solutions_Consultant_Email__c=null;
            }*/
            
            //Code to populate Account Cam Owner
            /*if (oppnew.stagename=='Closed Won' && MapoppAfterUpdate.containskey(oppnew.id) && MapoppAfterUpdate.get(oppnew.id).accountid!=null && MapoppAfterUpdate.get(oppnew.id).account.CAM_Owner__c!=null && (oppnew.CAM_Owner_Email__c==null || oppnew.CAM_Owner_Email__c !=MapoppAfterUpdate.get(oppnew.id).account.CAM_Owner__r.email)){
                opp.CAM_Owner_Email__c=MapoppAfterUpdate.get(oppnew.id).account.CAM_Owner__r.email;
            }*/
            ////commented as per APPS-21703
            
            //Code to populate Enterprise Rollup Flag
            //Added a check to not update Enterprise_Roll_up_SKU__c when closed lost as per APPS-21703
            if(MapoppAfterUpdate.containskey(oppnew.id) && ((MapoppAfterUpdate.get(oppnew.id).SBQQ__PrimaryQuote__c!=null && MapoppAfterUpdate.get(oppnew.id).SBQQ__PrimaryQuote__r.Enterprise_Roll_up_SKU__c ==true && oppnew.SBQQ__Contracted__c ==true)||(oppnew.SBQQ__Renewal__c ==true && MapoppAfterUpdate.get(oppnew.id).SBQQ__RenewedContract__c!=null && MapoppAfterUpdate.get(oppnew.id).SBQQ__RenewedContract__r.Enterprise_Roll_up_SKU__c==true)) && MapoppAfterUpdate.get(oppnew.id).stagename!='Closed Lost'){
                opp.Enterprise_Roll_up_SKU__c=true;
                oppToUpdate.add(opp);
            }
            
        }
        //commented as per APPS-21703
        /*if(trigger.isinsert && trigger.isbefore && isBeforeInsertEvent){
            set<id> userids=new set<id>();
            for(opportunity opp:newlist){
                if(opp.Solutions_Consultant_Lookup__c!=null){
                    userids.add(opp.Solutions_Consultant_Lookup__c);
                }
            }
            if(!userids.isempty()){
                map<id,user> usermap=new map<id,user>([select id,email from user where id in :userids]);
                system.debug([select id,email from user where id in :userids]);
                for(opportunity opp:newlist){
                   if(opp.Solutions_Consultant_Lookup__c!=null && usermap.containskey(opp.Solutions_Consultant_Lookup__c)){
                        opp.Solutions_Consultant_Email__c=usermap.get(opp.Solutions_Consultant_Lookup__c).email;
                    } 
                }
            }
        }*/
        //commented as per APPS-21703
    }
    public static void workflowActionsUpdation(){
        if(!oppToUpdate.isempty() && trigger.isafter && trigger.isupdate && !isBeforeInsertEvent && !isAfterInsertEvent){
            Update oppToUpdate;
        }
    }
    //#APPS-17919#-END
  
    /**------------------------------------------------------------------
    #BELOW METHODS TO PREPARE THE VARIABLES AFTER CLOSED WON. WILL BE USED IN DIFFERENT 
    PROCESSES THAT TAKE PLACE AFTER CLOSING THE OPPTY AS WON
    -------------------------------------------------------------------**/
    public static Set<Id> OpptyIds                              = new Set<Id>();                                
    public static Set<Id> paidOpportunitySet                    = new Set<Id>();                      
    public static Set<Id> opp_Set                               = new Set<Id>();                               
    public static Set<Id> opp_SetR                              = new Set<Id>(); 
    public static Set<Id> opp_SetRNM                            = new Set<Id>();
    public static Set<Id> opp_SetNM                             = new Set<Id>();    
    public static Set<Id> acctIds                               = new Set<Id>();                                 
    public static List<Opportunity> oppSet                      = new List<Opportunity>();                         
    public static Map<Id,Opportunity> closedOpps                = new Map<Id,Opportunity>();            
    public static Map<Id,Opportunity> TriggerNewMap_NewBusiness = new Map<Id,Opportunity>(); 
    public static Map<Id,Opportunity> TriggerNewMap_Renewal     = new Map<Id,Opportunity>();    
    public static String dealtypes = Label.Deal_types;
    
    public static void closeWonOpportunityChecking(Opportunity opp, Map<Id,Opportunity> oldMap){
        if(opp.StageName == CLOSED_WON_OPPTY && oldMap.get(opp.Id).StageName != CLOSED_WON_OPPTY){
            OpptyIds.add(opp.ID);
            closedOpps.put(opp.ID, opp);
            acctIds.add(opp.AccountId); 
             // Modified By :Jade Global 31th August 2018
             // Change      : Removed close won record type check of Opportunity..
                if(opp.Amount >= 0){
                    paidOpportunitySet.add(opp.Id);
                }//END OF IF CONDITION
                if(opp.Assets_created_on_closed_Won__c != true && opp.Type != RENEWAL_OPPTY){
                    oppSet.add(opp);
                }//END OF IF CONDITION
            }//END OF IF CONDITION
            if (opp.deal_type__c != null && !dealtypes.containsIgnorecase(opp.deal_type__c)) {
            // Modified By :Jade Global 31th August 2018
            // Change      : changed close won record type check to Iswon of Opportunity.
            if(opp.type == NEW_BUSS_OPPTY && opp.iswon== true && opp.Pricebook2Id != SBPB.ID__c && SBPB.Phoenix_Price_Books__c!=null && opp.Pricebook2Id!=null && !SBPB.Phoenix_Price_Books__c.contains(opp.Pricebook2Id)){
                    TriggerNewMap_NewBusiness.put(opp.id, opp);
                    opp_Set.add(opp.id); 
                    if(!opp.Toutapp_migrated__c){
                    opp_SetNM.add(opp.id);} 
                }//END OF IF CONDITION
                if(opp.type == RENEWAL_OPPTY && opp.iswon== true && opp.Pricebook2Id != SBPB.ID__c && !SBPB.Phoenix_Price_Books__c.contains(opp.Pricebook2Id)){
                    TriggerNewMap_Renewal.put(opp.id, opp);
                    opp_SetR.add(opp.id);
                    if(!opp.Toutapp_migrated__c){
                    opp_SetRNM.add(opp.id);}
                }//END OF IF CONDITION
        }//END OF IF CONDITION           
    }//End of closeWonOpportunityChecking Method

    
    /**------------------------------------------------------------------
    #BELOW METHODS TO PREPARE THE VARIABLES AFTER LOOSING A OPPTY. 
    -------------------------------------------------------------------**/
    public static Map <Id, Opportunity> TriggerNewMap_ClosedLost = new Map <Id, Opportunity>(); 
    
    public static void closeLostOpportunityChecking(Opportunity opp, Map<Id,Opportunity> oldMap){       
        if (opp.stagename == CLOSE_LOST_OPPTY && oldmap.get(opp.id).Stagename != opp.stagename && opp.type == RENEWAL_OPPTY ) {
            TriggerNewMap_ClosedLost.put(opp.id, opp);    
        }//END OF IF CONDITION
    }//END OF CLOSELOSTOPPORTUNITYCHECKING METHOD

    
    /**------------------------------------------------------------------
    #BELOW METHOD allows us to create MKT payment on closed won of the opportunity based on the related opportunity line items.  
    #It checks for Launch packs products in MKT_TranslationTable__c and create payment for those.
    #Also create payment for normal OLI
    -------------------------------------------------------------------**/
    public static void mkt_AddPaymentTrigger() {
        if(!paidOpportunitySet.isEmpty()){
            Map<Id, OpportunityLineItem> launchPackIdOpportunityLPMap = new Map<Id, OpportunityLineItem>();
            Set<Id> ProcessOpportunityLineItemIds = new Set<Id>();
            List<OpportunityLineItem> finalOpptyLineItemlist = new List<OpportunityLineItem>();
            List<Opportunity> OpptyIdsList = new List<Opportunity>();
            OpptyIdsList = getAllOpportunityLists();
            for(Opportunity oppty : OpptyIdsList ){
                if(paidOpportunitySet.contains(oppty.Id)){
                    List<OpportunityLineItem> newOLIlist = new List<OpportunityLineItem>();
                    newOLIlist = oppty.OpportunityLineItems;
                    for(OpportunityLineItem oli : newOLIlist){
                        finalOpptyLineItemlist.add(oli);
                    }//END OF FOR LOOP OPPORTUNITYLINEITEM
                }//END OF IF CONDITION    
            }//END OF FOR LOOP OPPORTUNIT
            for (OpportunityLineItem opportunityLItem : finalOpptyLineItemlist) {
                launchPackIdOpportunityLPMap.put(opportunityLItem.PricebookEntry.Product2Id, opportunityLItem);
            }//END OF FOR LOOP OPPORTUNITYLINEITEM
            
            for (MKT_TranslationTable__c launchPackProductItem :[SELECT ChildProduct__c, ParentProduct__c, Total_Seats__c FROM MKT_TranslationTable__c WHERE ParentProduct__c IN :launchPackIdOpportunityLPMap.keySet()]) {
                OpportunityLineItem opportunityLPItem = (OpportunityLineItem)launchPackIdOpportunityLPMap.get(launchPackProductItem.ParentProduct__c);
                //if (opportunityLPItem.Opportunity.MKT_Transaction__c == NULL) {
                    MKT_Payment__c payment = new MKT_Payment__c();
                    payment.Product__c = launchPackProductItem.ChildProduct__c;
                   // payment.User__c = (opportunityLPItem.Opportunity.MKT_User__c == NULL) ? opportunityLPItem.Opportunity.CreatedById : opportunityLPItem.Opportunity.MKT_User__c;
                    payment.Account__c = opportunityLPItem.Opportunity.AccountId;
                    payment.Total_Seats__c = opportunityLPItem.Quantity * launchPackProductItem.Total_Seats__c;
                    payment.MKT_Opportunity__c = opportunityLPItem.OpportunityId;
                    MKT_PAYMENT_MASTER_LIST.add(payment);
                    ProcessOpportunityLineItemIds.Add(opportunityLPItem.Id);
                //}//END OF IF CONDITION                    
            }//END OF FOR LOOP OF MKT_TRANSLATIONTABLE__C
            
            for (OpportunityLineItem SingleProductOpportunityLineItem : launchPackIdOpportunityLPMap.values()) {
                if (!ProcessOpportunityLineItemIds.contains(SingleProductOpportunityLineItem.Id)) {
                    MKT_Payment__c payment = new MKT_Payment__c();
                    payment.Product__c = SingleProductOpportunityLineItem.PricebookEntry.Product2Id;
                    //payment.User__c = (SingleProductOpportunityLineItem.Opportunity.MKT_User__c == NULL) ? SingleProductOpportunityLineItem.Opportunity.CreatedById : SingleProductOpportunityLineItem.Opportunity.MKT_User__c;
                    payment.Account__c = SingleProductOpportunityLineItem.Opportunity.AccountId;
                    payment.Total_Seats__c = SingleProductOpportunityLineItem.Quantity;
                    payment.MKT_Opportunity__c = SingleProductOpportunityLineItem.OpportunityId;
                    MKT_PAYMENT_MASTER_LIST.add(payment);
                }//END OF IF CONDITION
            }//END OF FOR LOOP OF OPPORTUNITYLINEITEM 
        }//END OF IF CONDITION 
    }//END OF METHOD MKT_ADDPAYMENTTRIGGER   
    
    /**----------------------------------------------------------------------------------------------
    #BELOW METHODS TO CREATE NEW RENEWAL OPPTY IF CURRENT OPPORTUNITY IS NB/UPSELL-CROSELL & CLOSED WON. 
    ----------------------------------------------------------------------------------------------**/
    public static void cloneNewBusinessOpportunity(Map<Id,Opportunity> newMap){
        if (!TriggerNewMap_NewBusiness.isEmpty()) {        
            if (!NEWupdateOpportunityBasedOnCriteria.isFromTriggerCloneOppBasedonCriteria) {
                NEWupdateOpportunityBasedOnCriteria.isFromTriggerCloneOppBasedonCriteria = true;
                //HANDLE THE clone_OpportunityBasedOnCriteria FOR THE NEW BUSINESS OPPORTUNITIES
                //NEWupdateOpportunityBasedOnCriteria.processOpportunity_NewBusiness(opp_Set, newmap);  
                NEWupdateOpportunityBasedOnCriteria.processOpportunity_NewBusiness(opp_SetNM, newmap);  
            }//END OF IF CONDITION
        }//END OF IF CONDITION
    }//END OF METHOD CLONENEWBUSINESSOPPORTUNITY
    
    /**-----------------------------------------------------------------------------------
    #BELOW METHODS TO CREATE NEW RENEWAL OPPTY IF CURRENT OPPORTUNITY IS RENEWAL & CLOSED WON. 
    ------------------------------------------------------------------------------------**/
    public static void cloneRenewalOpportunity(Map<Id,Opportunity> newMap){
        /***WHEN TYPE- RENEWAL OPPORTUNITY UPDATED is closed won***/
        if (!TriggerNewMap_Renewal.isEmpty()) {
            if (!NEWupdateOpptyBasedOnCriteriaRenewal.isFromTriggerCloneOppBasedonCriteriaRenewal) {
                NEWupdateOpptyBasedOnCriteriaRenewal.isFromTriggerCloneOppBasedonCriteriaRenewal = true;
                //HANDLE THE clone_OpportunityBasedOnCriteria FOR THE RENEWAL OPPORTUNITIES
                NEWupdateOpptyBasedOnCriteriaRenewal.updateOpportunity_Renewal(opp_SetR, newmap);
            }//END OF IF CONDITION
        }//END OF IF CONDITION
    }//END OF METHOD CLONERENEWALOPPORTUNITY
    
    /**-----------------------------------------------------------
    #BELOW METHODS TO UPDATE ASSET AS EXPIRED IF OPPORTUNITY IS LOST. 
    ------------------------------------------------------------**/
    public static void cloneCloseLostOpportunity(){
        /***WHEN STAGE- CLOSED LOST OPPORTUNITY UPDATED***/
        if (!TriggerNewMap_ClosedLost.isEmpty()) {
            if (!NEWupdateOpptyBasedOnCriteriaRenewal.isFromTriggerCloneOppBasedonCriteriaRenewal) {
                NEWupdateOpptyBasedOnCriteriaRenewal.isFromTriggerCloneOppBasedonCriteriaRenewal = true;
                // HANDLE THE clone_OpportunityBasedOnCriteria FOR THE CLOSE LOST OPPORTUNITIES 
                ASSETS_MASTER_LIST.putAll(NEWupdateOpptyBasedOnCriteriaRenewal.UpdateAssets_ClosedLost(TriggerNewMap_ClosedLost));
            }//END OF IF CONDITION
        }//END OF IF CONDITION  
    }//END OF METHOD CLONECLOSELOSTOPPORTUNITY
    
    /**-----------------------------------------------------------
    #BELOW METHODS TO POPULATE ACCOUNT'S MULTIPLE FIELD FROM OPPTY. 
    ------------------------------------------------------------**/
    public static void mapAccountFieldsFromOpportunity(List<Opportunity> newlist) {
        
        String MARKT_PERMISSION_CPR    = 'Customer Permission Received';
        String MARKT_PERMISSION_NCP    = 'Need Customer Permission';
        String MARKT_PERMISSION_UCL    = 'Do Not Use Customer Logo';
        String LOGO_PERMISSION_AGR     = 'Agreed';
        String LOGO_PERMISSION_WRI_REQ = 'Written Required';
        String LOGO_PERMISSION_NO      = 'No';
       
       if(!OpptyIds.isEmpty()) {
           List<Opportunity> OpptyIdsList = new List<Opportunity>();
           OpptyIdsList = getAllOpportunityLists();
           for(Opportunity oppty : OpptyIdsList ){   
                Boolean newBusiness = false;
                String engagementManagerId = oppty.Engagement_Manager__c;
                if(oppty.Type == NEW_BUSS_OPPTY){
                    newBusiness = true;                    
                }//END OF IF CONDITION
                if(!oppty.SBQQ__Quotes2__r.isEmpty()) {
                    SBQQ__Quote__c sbq = oppty.SBQQ__Quotes2__r[0];
                    Account targetAc;
                    Boolean criteriaQualified = false;
                    targetAc = retrievePartiallyUpdatedAccount(sbq.SBQQ__Opportunity2__r.AccountID);                   
                    
                    //*************
                    //Code added by Jade for updating PO_Required__c value on Account from Oppty on closed Won event
                    //Reference JIRA Ticket : APPS-8166 - PO Number discussion
                    //Date : 20th July 2016
                    if(targetAc != null && oppty.stagename != null && oppty.stagename == 'Closed Won'){
                        targetAc.PO_Required__c = oppty.PO_Required__c;
                    }
                    //*************
                    
                    if(targetAc != null && newBusiness){
                        targetAc.Economic_Decision_Maker__c         = oppty.Economic_Decision_Maker__c;
                        targetAc.Economic_Decision_Maker_C__c    = oppty.Economic_Decision_Maker__r.FirstName;
                        targetAc.Economic_Decision_Maker_Email__c   = oppty.Economic_Decision_Maker__r.email;
                        targetAc.Primary_Marketo_User_C__c      = oppty.Primary_Marketo_User_Lookup__r.FirstName;
                        targetAc.Primary_Marketo_User_Lookup__c     = oppty.Primary_Marketo_User_Lookup__c;
                        targetAc.Primary_Marketo_User_Email__c      = oppty.Primary_Marketo_User_Email__c;
                        if(engagementManagerId != null) targetAc.Engagement_Mgr_Owner__c = engagementManagerId;
                        criteriaQualified = true;
                    }//END OF IF CONDITION
    
                    if(sbq.Marketing_Permission__c != null) {
                        if(sbq.Marketing_Permission__c == MARKT_PERMISSION_CPR) {
                            targetAc.Logo_Permission2__c = LOGO_PERMISSION_AGR;
                            criteriaQualified = true;
                        }else if(sbq.Marketing_Permission__c == MARKT_PERMISSION_NCP) {                   
                            targetAc.Logo_Permission2__c = LOGO_PERMISSION_WRI_REQ;
                            criteriaQualified = true;
                        }else if(sbq.Marketing_Permission__c == MARKT_PERMISSION_UCL) {
                            targetAc.Logo_Permission2__c = LOGO_PERMISSION_NO;
                            criteriaQualified = true;
                        }//END OF ELSE IF CONDITION   
                    }else{
                        targetAc.Logo_Permission2__c = '';
                        criteriaQualified = true;
                    }//END OF IF CONDITION
                    if(sbq.Case_Study_Permission__c != null) {
                        targetAc.Case_Study_Permission__c = true;
                        criteriaQualified = true;
                    }else{
                        targetAc.Case_Study_Permission__c = false;
                        criteriaQualified = true;                                               
                    }//END OF IF CONDITION
                    
                    if(criteriaQualified){  
                        ACCOUNT_MASTER_LIST.put(targetAc.id, targetAc);
                    }//END OF IF CONDITION
                }else{
                    if(newBusiness){
                        Account accNew                              = retrievePartiallyUpdatedAccount(oppty.AccountID);
                        accNew.Economic_Decision_Maker__c           = oppty.Economic_Decision_Maker__c;
                        accNew.Economic_Decision_Maker_C__c         = oppty.Economic_Decision_Maker__r.FirstName;
                        accNew.Economic_Decision_Maker_Email__c     = oppty.Economic_Decision_Maker__r.email;
                        accNew.Primary_Marketo_User_C__c            = oppty.Primary_Marketo_User_Lookup__r.FirstName;
                        accNew.Primary_Marketo_User_Lookup__c       = oppty.Primary_Marketo_User_Lookup__c;
                        accNew.Primary_Marketo_User_Email__c        = oppty.Primary_Marketo_User_Email__c;
                        //*************
                        //Code added by Jade for updating PO_Required__c value on Account from Oppty on closed Won event
                        //Reference JIRA Ticket : APPS-8166 - PO Number discussion
                        //Date : 20th July 2016
            if(accNew != null && oppty.stagename != null && oppty.stagename == 'Closed Won'){
              accNew.PO_Required__c = oppty.PO_Required__c;
            }
                        //*************
                        if(engagementManagerId != null) accNew.Engagement_Mgr_Owner__c = engagementManagerId;
                        ACCOUNT_MASTER_LIST.put(accNew.Id, accNew);
                    }//END OF IF CONDITION
                }//END OF ELSE CONDITION
            }//END OF FOR LOOP OF OPPORTUNITY
        }//END OF IF CONDITION   
    }//END OF METHOD UPDATERENEWALSOWNERF METHOD UPDATERENEWALSOWNERONACCOUNT 
    
    /* ***************************************************************************************************
     *  Modified By : Jade Global Inc, on 6th June 2017
     *  Purpose     : Populate Bill-To and Ship-To Contact on Account while closer of the Opportunity
     *  Line No     : 727 to 758
     *************************************************************************************************** */
    public static void PopulateBillToAndShipToContacts(List<Opportunity> newlist,Map<Id,Opportunity> oldMap){
      
        Set<Id> ClosedOppSet=new Set<Id>();
        List<opportunity> OpportunityList=new List<opportunity>();
        for(opportunity opp:newlist){
            if(opp.stageName==CLOSED_WON_OPPTY && opp.stageName!= oldMap.get(opp.id).stageName){
                ClosedOppSet.add(opp.id);
            }
        }
     
        if(!ClosedOppSet.isEmpty()){
            for(opportunity OppObj :[SELECT Id, IsDeleted, AccountId,Account.Bill_To_Contact__c,Account.Ship_To_Contact__c, StageName,(SELECT ID,SBQQ__Opportunity2__c,Bill_To_Contact__c,Ship_To_Contact__c, SBQQ__Opportunity2__r.AccountID FROM SBQQ__Quotes2__r WHERE SBQQ__Primary__c=TRUE LIMIT 1) FROM Opportunity WHERE ID IN: ClosedOppSet]){
                Account targetAcc=new Account();
                //targetAcc.id=OppObj.AccountID;
                if(!oppObj.SBQQ__Quotes2__r.isEmpty()){
                  
                    if(OppObj.Account.Bill_To_Contact__c==NULL){
                        targetAcc.Bill_To_Contact__c=OppObj.SBQQ__Quotes2__r[0].Bill_To_Contact__c; 
                        //ACCOUNT_MASTER_LIST.put(targetAcc.id,targetAcc);
                    }
                  
                    if(OppObj.Account.Ship_To_Contact__c==NULL){
                        targetAcc.Ship_To_Contact__c=OppObj.SBQQ__Quotes2__r[0].Ship_To_Contact__c; 
                        //ACCOUNT_MASTER_LIST.put(targetAcc.id,targetAcc);
                    }
                    if(targetAcc!=null){
                        targetAcc.id=OppObj.AccountID;
                        ACCOUNT_MASTER_LIST.put(targetAcc.id,targetAcc);
    
                    }
                }
            }

        }
    }
    
   /**-------------------------------------------------------------
    #BELOW METHODS TO POPULATE LOCATION & GEOGRAPHY ON OPPTYLINEITEMS . 
    #PREVIOUSLY IT WAS PART OF TRIGGER: UpdateSalesRegionFromAcc
    ------------------------------------------------------------**/
    public static Set<Id> oppIdSet = new Set<Id>();                         
    public static void updateGeoInfoOnOLIFromAccinAfterUpdateChecking(Opportunity opp, Map<Id,Opportunity> oldMap){
        if(opp.Intacct_Entity__c != oldMap.get(opp.Id).Intacct_Entity__c){
            oppIdSet.add(opp.Id);
        }//END OF IF CONDITION
    }//END OF METHOD UPDATEGEOINFOONOLIFROMACCINAFTERUPDATECHECKING
    
    
    public static void updateGeoInfoOnOLIFromAccinAfterUpdate(){
        if(!oppIdSet.isEmpty()){
            List<OpportunityLineItem> finalOpptyLineItemlist = new List<OpportunityLineItem>();
            List<Opportunity> oppIdSetList = new List<Opportunity>();
            
            String INTACCT_ENTITY_EMEA  = 'marketo-emea';
            String INTACCT_ENTITY_US    = 'marketo-us';
            String OLI_LOCATION_EMEA    = 'marketo-emea';
            String OLI_LOCATION_US      = 'marketo-us';
            String OLI_GEO_IRELAND      = 'Ireland';
            String OLI_GEO_US           = 'US';
            
            oppIdSetList = getAllOpportunityLists();
            for(Opportunity oppty : oppIdSetList ){
                if(oppIdSet.contains(oppty.Id)){
                    List<OpportunityLineItem> newOLIlist = new List<OpportunityLineItem>();
                    newOLIlist = oppty.OpportunityLineItems;
                    for(OpportunityLineItem oli : newOLIlist){
                        finalOpptyLineItemlist.add(oli);
                    }//END OF FOR LOOP OPPORTUNITYLINEITEM
                }//END OF IF CONDITION    
            }//END OF FOR LOOP OPPORTUNITY               
            for(OpportunityLineItem oppLineItem : finalOpptyLineItemlist){
                if(oppLineItem.Opportunity.Intacct_Entity__r.Name == INTACCT_ENTITY_EMEA){
                    oppLineItem.Location__c = OLI_LOCATION_EMEA;
                    //oppLineItem.Geography__c = OLI_GEO_IRELAND;
                    OLI_MASTER_LIST.put(oppLineItem.Id, oppLineItem);
                }//END OF IF CONDITION
                else if(oppLineItem.Opportunity.Intacct_Entity__r.Name == INTACCT_ENTITY_US){
                    oppLineItem.Location__c = OLI_LOCATION_US;
                    //oppLineItem.Geography__c = OLI_GEO_US;
                    OLI_MASTER_LIST.put(oppLineItem.Id, oppLineItem);
                }else{
                    oppLineItem.Location__c = oppLineItem.Opportunity.Intacct_Entity__r.Name;
                    OLI_MASTER_LIST.put(oppLineItem.Id, oppLineItem);
                }//END OF ELSE IF CONDITION
            }//ENF OF FOR LOOP OF OPPORTUNITYLINEITEM
        }//END OF IF CONDITION
    }//END OF METHOD UPDATESALESREGIONFROMACCINAFTERUPDATE
    
    
    /*--------------------------------------------------------------------
    #METHOD IS USED TO CREATE ASSETS, ENTITLEMENTS, AURORIZED CONTACT  
    AND LEARNING PASSPORT WHEN OPPORTUNITY IS CLOSED AS WON
    ---------------------------------------------------------------------**/
    public static void updateOpportunity(){
        if(!OppSet.isEmpty()){
            for(Opportunity opp : oppSet){
                if (NEWCreateAssetsAndEntitlements.allowAssetAndEntitlementCreator == true) {
                    NEWCreateAssetsAndEntitlements.allowAssetAndEntitlementCreator = false;
                    NEWCreateAssetsAndEntitlements.createAssetWithEntitlement(opp);
                }//END OF IF CONDITION
            }//END OF FOR LOOP OF OPPORTUNITY
        }//END OF IF CONDITION
    }//END OF METHOD UPDATEOPPORTUNITY
   
    
    
     /**-----------------------------------------------------
     #THIS METHOD UPDATE PRIMARY MARKETO USER CHECKBOX ON CONTACT 
     ------------------------------------------------------**/
     public static void updatePrimaryMarketoUserOnContact() {
         if(!closedOpps.isEmpty()){
            List<Opportunity> closedWonOpps = closedOpps.Values();
            Map<String, String> newPrimaryMarketoUserMap = new Map<String, String>();
            
            //TO UPDATE PRIMARY MARKETO USER CHECKBOX ON CONTACT
            for(Opportunity oppBeingClosed : closedWonOpps) {
                if(oppBeingClosed.Type == NEW_BUSS_OPPTY && oppBeingClosed.Primary_Marketo_User_Lookup__c != null) {
                    newPrimaryMarketoUserMap.put(oppBeingClosed.AccountId, oppBeingClosed.Primary_Marketo_User_Lookup__c);
                }//END OF IF CONDITION   
            }//END OF FOR LOOP OF OPPORTUNITY 
            
            //PERFORM OPERATIONS--        
            if(!newPrimaryMarketoUserMap.isEmpty()) {
                Map<string, Contact> updateContactMap = new Map<string, Contact>();//MAP TO AVOID DUPLICATE RECORDS
                for(Account acc : [SELECT Id, (SELECT Id, CE_Primary_Marketo_User__c FROM Contacts Where CE_Primary_Marketo_User__c = True LIMIT 1) FROM ACCOUNT WHERE Id IN : newPrimaryMarketoUserMap.keySet()]){
                    List<Contact> Acc_ContactList = new List<Contact>();
                    Acc_ContactList = acc.Contacts;
                    if(!Acc_ContactList.isEmpty()) {
                        if(Acc_ContactList[0].Id != newPrimaryMarketoUserMap.get(acc.Id)) {
                            Acc_ContactList[0].CE_Primary_Marketo_User__c = false;
                            Contact contct = new Contact(Id = newPrimaryMarketoUserMap.get(acc.Id), CE_Primary_Marketo_User__c = true);
                            CONTACTS_MASTER_LIST.put(Acc_ContactList[0].Id, Acc_ContactList[0]);
                            CONTACTS_MASTER_LIST.put(contct.Id, contct);
                        }//END OF IF CONDITION                
                    }else {
                        Contact contct = new Contact(Id = newPrimaryMarketoUserMap.get(acc.Id), CE_Primary_Marketo_User__c = true);
                        CONTACTS_MASTER_LIST.put(contct.Id, contct);
                    }//END OF ELSE CONDITION                
                }//END OF FOR LOOP OF ACCOUNT            
            }//END OF IF CONDITION
        }//END OF IF CONDITION
    }//END OF METHOD PROCESSCLOSEDWONOPPORTUNITIES
    
    /**-------------------------------------------------------------
    #BELOW METHOD POPULATE THE CAM OWNER AND CAM GROUP ON ACCOUNT RECORD
    ------------------------------------------------------------------**/
    public static Map<String, CAM_Rotator__c> camOwnerMap_s = new Map<String,CAM_Rotator__c>(); 
    public static Map<String, CAM_Rotator__c> getcamOwnerMap(){
        if(camOwnerMap_s.isEmpty()){
            List<CAM_Rotator__c> rotators = [SELECT Id,CAM_Owner__c, CAM_Group__c FROM CAM_Rotator__c WHERE CAM_Group__c != NULL 
                                             AND CAM_Owner__c != NULL AND isActive__c = true ORDER BY Last_Assigned__c ASC 
                                             NULLS FIRST];
            for(CAM_Rotator__c cr : rotators){
                if(!camOwnerMap_s.containsKey(cr.CAM_Group__c)){
                    camOwnerMap_s.put(cr.CAM_Group__c, cr);
                }//END OF IF CONDITION
            }//END OF FOR LOOP CAM ROTATOR
        }//END OF IF CONDITION
        return camOwnerMap_s;
    }//END OF METHOD GETCAMOWNERMAP
    
    public static void populatecamOwnerandcamGroupOnAccount(List<Opportunity> newlist){
        
        String PENDING_CAM_ASSIGN_STATUS = 'Pending CAM Assignment';
        String ASSIGNED_CAM_ASSIGN_STATUS = 'CAM Owner Assigned';
        
        if(!acctIds.isEmpty()){
            List<Account> accountList = [SELECT Id, CAM_Group__c, CAM_Owner__c, Account.ParentId, Account.Parent.CAM_Owner__c, 
                                         Account.Parent.CAM_Group__c, CAM_Assign_Status__c,
                                         (
                                            SELECT Id, Opportunity_ARR__c,Owner_Role_Custom__c,  BOFU_CAM_Group__c FROM Opportunities 
                                            WHERE IsWon = True ORDER BY CloseDate DESC LIMIT 1
                                         ) 
                                         FROM Account WHERE Id IN : acctIds AND (CAM_Group__c = Null OR CAM_Owner__c = Null)];
            List<CAM_Rotator__c> updateCAMrotatorsList = new List<CAM_Rotator__c>();
            Map<String,CAM_Rotator__c> camOwnerMap;
            
            for(Account acc : accountList){
                Boolean isAccountChanged = False;
                Opportunity o = new Opportunity();
                if(!acc.Opportunities.isEmpty()){
                    o = acc.Opportunities[0];
                }//END OF IF CONDITION
                String Parent_CAM_OWNER = acc.Parent.CAM_Owner__c;
                String Parent_CAM_GROUP = acc.Parent.CAM_Group__c;
                
                if(!ACCOUNT_MASTER_LIST.isEmpty() && ACCOUNT_MASTER_LIST.containsKey(acc.Id)){
                    Account ac = ACCOUNT_MASTER_LIST.get(acc.Id);
                            ac.CAM_Group__c = acc.CAM_Group__c;
                            ac.CAM_Owner__c = acc.CAM_Owner__c;
                            ac.ParentId = acc.ParentId;
                            ac.CAM_Assign_Status__c = acc.CAM_Assign_Status__c;
                            acc = ac;
                }//END OF IF CONDITION
                
                if (acc.CAM_Group__c == null) {
                    if (acc.ParentId != null && Parent_CAM_GROUP != null) {
                        acc.CAM_Group__c = Parent_CAM_GROUP;
                        isAccountChanged = True;
                    }//END OF IF CONDITION
                    else {
                        acc.CAM_Group__c = o.BOFU_CAM_Group__c;
                        acc.CAM_Assign_Status__c = PENDING_CAM_ASSIGN_STATUS;
                        isAccountChanged = True;
                    }//END OF ELSE CONDITION
                }//END OF IF CONDITION
                if (acc.CAM_Owner__c == null) {
                    if (acc.ParentId != null && Parent_CAM_OWNER != null) {
                        acc.CAM_Owner__c = Parent_CAM_OWNER;
                        isAccountChanged = True;
                    }//END OF IF CONDITION
                    else {
                        camOwnerMap = new Map<String,CAM_Rotator__c>();
                        camOwnerMap = getcamOwnerMap();
                        if(!camOwnerMap.isEmpty() && camOwnerMap.containsKey(acc.CAM_Group__c)){
                            CAM_Rotator__c cr = camOwnerMap.get(acc.CAM_Group__c);
                            acc.CAM_Owner__c = cr.CAM_Owner__c;
                            acc.CAM_Assigned_Date__c = Date.today();
                            acc.CAM_Assign_Status__c = ASSIGNED_CAM_ASSIGN_STATUS;
                            cr.Last_Assigned__c = System.now();     
                            updateCAMrotatorsList.add(cr);
                            isAccountChanged = True;
                        }//END OF IF CONDITION
                        if(!updateCAMrotatorsList.isEmpty()){
                            update updateCAMrotatorsList;
                        }//END OF IF CONDITION
                    }//END OF ELSE CONDITION
                }//END OF IF CONDITION
                if(isAccountChanged){
                    ACCOUNT_MASTER_LIST.put(acc.Id, acc);
                }//END OF IF CONDITION
            }//END OF FOR LOOP OF ACCOUNT
        }//END OF IF CONDITION
    }//END OF METHOD POPULATECAMOWNERANDCAMGROUPONACCOUNT
     
    /**---------------------------------------------------------------------
    #METHOD TO UPDATE TIER ON OPPRTUNITYLINEITEM- AS PART OF CPQ, BY JADEGLOBAL
    ----------------------------------------------------------------------**/
    public static void updateOpptyLines(){         
        if(!closedOpps.isEmpty()){             
            Set<id> contractid             = new Set<id>();
            Map<id,opportunity> Oppmap     = new Map<id,opportunity>(); 
            List<Opportunity> OpptyIdsList = new List<Opportunity>();
            
            String OLI_TIER_1 = 'Tier 1';
            String OLI_TIER_2 = 'Tier 2';
            String OLI_TIER_3 = 'Tier 3';
            String OLI_TIER_4 = 'Tier 4';
            String OLI_TIER_5 = 'Tier 5';
            String OLI_TIER_6 = 'Tier 6';
            String OLI_TIER_7 = 'Tier 7';

            OpptyIdsList = getAllOpportunityLists();
            for(Opportunity oppty : OpptyIdsList ){
                if(closedOpps.containsKey(oppty.Id)){
                    Oppmap.put(oppty.Id, oppty);
                }//END OF IF CONDITION
            }//END OF FOR LOOP OPPORTUNITY        
        
            Map<Id,contract> contractmap  = new Map<Id,contract>();
            
            for(Opportunity Opp  :Oppmap.values()){
                if(opp.SBQQ__PrimaryQuote__c!=null){
                    if(opp.SBQQ__PrimaryQuote__r.SBQQ__MasterContract__c!=null){
                        contractid.add(opp.SBQQ__PrimaryQuote__r.SBQQ__MasterContract__c);
                    }//END OF IF CONDITION
                    else if(opp.SBQQ__PrimaryQuote__r.Contract_Lookup__c!=null){
                        contractid.add(opp.SBQQ__PrimaryQuote__r.Contract_Lookup__c);
                    }//END OF ELSE CONDITION
                }//END OF IF BLOCK
            }//END FOR LOOP OPPORTUNITY
        
            contractmap = new map<id,contract>([SELECT id,name ,(SELECT id,SBQQ__Quantity__c,Subscription_Product_Code__c   FROM SBQQ__Subscriptions__r WHERE SBQQ__Quantity__c!=null ) FROM Contract WHERE ID IN : contractid]);
             
            Map<string,ProductCodeVSOETier__c> ProductCodeVSOMap   = new Map<string,ProductCodeVSOETier__c>();
            List<OpportunityLineItem>          UpdateOLI           = new List<OpportunityLineItem>();
            
            for(ProductCodeVSOETier__c prd :ProductCodeVSOETier__c.getall().values()){
                ProductCodeVSOMap.put(prd.name,prd);
            }//END OF FOR LOOP PRODUCTCODEVSOETIER__C
            
            for(Opportunity opp :Oppmap.values()){
                if(!opp.OpportunityLineItems.isEmpty()){
                    for(OpportunityLineItem oli :opp.OpportunityLineItems){
                        Boolean isOpportunityLineItemUpdate = False;
                        String Oppty_Product_Code = oli.ProductCode;
                        Decimal Oppty_Contract_Quantity = oli.Contract_Quantity__c;
                        
                        if(OLI_MASTER_LIST != null && !OLI_MASTER_LIST.isEmpty() && OLI_MASTER_LIST.containsKey(oli.Id)){
                            OpportunityLineItem o = OLI_MASTER_LIST.get(oli.Id);
                            oli = o;
                        }//END OF IF CONDITION
                        
                        decimal quantity = Oppty_Contract_Quantity <> null? Oppty_Contract_Quantity:0;
                        if(Oppty_Product_Code!=null && ProductCodeVSOMap.containsKey(Oppty_Product_Code)){
                            //Get the product code related range for Tier
                            ProductCodeVSOETier__c ProdVSOE = ProductCodeVSOMap.get(Oppty_Product_Code);
                            if(opp.SBQQ__PrimaryQuote__r.SBQQ__MasterContract__c!=null && opp.Type == UPSELL_CROSSELL_OPPTY){ 
                                if(contractmap.containsKey(opp.SBQQ__PrimaryQuote__r.SBQQ__MasterContract__c)){
                                    Contract con = contractmap.get(opp.SBQQ__PrimaryQuote__r.SBQQ__MasterContract__c);
                                    for(SBQQ__Subscription__c  sub :con.SBQQ__Subscriptions__r){
                                        if(sub.Subscription_Product_Code__c  ==Oppty_Product_Code ){
                                          quantity = quantity + sub.SBQQ__Quantity__c;
                                        }//END OF IF CONDITION
                                    }//End of FOR loop of SBQQ__Subscription__c
                                }//END OF IF CONDITION
                           }//End of  IF block of contract check
                           else if(opp.SBQQ__PrimaryQuote__r.Contract_Lookup__c!=null && opp.Type == UPSELL_CROSSELL_OPPTY){
                                if(contractmap.containsKey(opp.SBQQ__PrimaryQuote__r.Contract_Lookup__c)){
                                    Contract con = contractmap.get(opp.SBQQ__PrimaryQuote__r.Contract_Lookup__c);
                                    for(SBQQ__Subscription__c  sub :con.SBQQ__Subscriptions__r){
                                        if(sub.Subscription_Product_Code__c  == Oppty_Product_Code ){
                                          quantity = quantity + sub.SBQQ__Quantity__c;
                                        }//END OF IF CONDITION
                                    }//End of FOR loop of SBQQ__Subscription__c
                                }//END OF IF CONDITION
                            }//End of ELSE IF block of contract check
                        
                            if(quantity!=null){ 
                                  if(ProdVSOE.Tier_1_Low__c <= quantity && ProdVSOE.Tier_1_High__c >= quantity){
                                      oli.Tier__c  = OLI_TIER_1;
                                      isOpportunityLineItemUpdate = True;
                                  }//END OF IF CONDITION                              
                                  else if(ProdVSOE.Tier_2_Low__c <= quantity && ProdVSOE.Tier_2_High__c>= quantity){
                                      oli.Tier__c  = OLI_TIER_2;
                                      isOpportunityLineItemUpdate = True;
                                  }//END OF ELSE IF CONDITION                                 
                                  else if(ProdVSOE.Tier_3_Low__c <= quantity && ProdVSOE.Tier_3_High__c>= quantity){
                                      oli.Tier__c  = OLI_TIER_3;
                                      isOpportunityLineItemUpdate = True;
                                  }//END OF ELSE IF CONDITION                                
                                  else if(ProdVSOE.Tier_4_Low__c <= quantity && ProdVSOE.Tier_4_High__c>= quantity){
                                      oli.Tier__c  = OLI_TIER_4;
                                      isOpportunityLineItemUpdate = True;
                                  }//END OF ELSE IF CONDITION                                
                                  else if(ProdVSOE.Tier_5_Low__c <= quantity && ProdVSOE.Tier_5_High__c>= quantity){
                                      oli.Tier__c  = OLI_TIER_5;
                                      isOpportunityLineItemUpdate = True;
                                  }//END OF ELSE IF CONDITION                                
                                  else if(ProdVSOE.Tier_6_Low__c <= quantity && ProdVSOE.Tier_6_High__c>= quantity ){
                                      oli.Tier__c  = OLI_TIER_6;
                                      isOpportunityLineItemUpdate = True;
                                  }//END OF ELSE IF CONDITION  
                                   else if(ProdVSOE.Tier_7_Low__c <= quantity && ProdVSOE.Tier_7_High__c>= quantity){
                                      oli.Tier__c  = OLI_TIER_7;
                                      isOpportunityLineItemUpdate = True;
                                  }//END OF ELSE IF CONDITION
                             }//END OF IF BLOCK OF QUANTITY!=NULL CHECK
                            if(isOpportunityLineItemUpdate){
                                OLI_MASTER_LIST.put(oli.Id, oli); 
                            }//END OF IF CONDITION 
                        }//END OF IF CONDITION
                    }//END OF FOR LOOP OF OPPORTUNITYLINEITEM
                }//END OF IF CONDITION
            }//END OF FOR LOOP OF OPPORTUNITY
        }//END OF IF CONDITION
    }//END OF METHOD UPDATEOPPTYLINES         
   
    /**--------------------------------------------------
    #AFTER EACH EVENT, ALL DML OPERATIONS ARE PERFORMED HERE
    ---------------------------------------------------**/
    public static void FINALLY_DMLS(){  
        //1. UPDATE ACCOUNT
        UPDATE_ACCOUNT_FINALLY();
        //2. UPDATE CONTACT
        UPDATE_CONTACT_FINALLY();
        //3. UPDATE OPPORTUNITY LINE ITEM
        UPDATE_OPPTYLINEITEM_FINALLY();
        //4. UPDATE ASSET
        UPDATE_ASSET_FINALLY();
        //5. UPDATE MKT_PAYMENT
        INSERT_MKT_PAYMENT_FINALLY();
        //5. UPDATE OTHER OBJECTS- OPPORTUNITY
    } 
    
    public static void UPDATE_ACCOUNT_FINALLY(){
        if(ACCOUNT_MASTER_LIST != null && !ACCOUNT_MASTER_LIST.isEmpty()){
            try{
                DatabaseOperation.updateAccount(ACCOUNT_MASTER_LIST.values(), SalesTriggersUtility.marketoTriggerManager.Deactivate_Account_trigger__c, true);
                ACCOUNT_MASTER_LIST.clear();
            }//END OF TRY BLOCK
            catch(Exception e){
                System.Debug('----- GOT AN EXCEPTION -----'+e.getMessage());
            }//END OF CATCH BLOCK
        }//END OF IF CONDITION
    }//END OF METHOD UPDATE_ACCOUNT_FINALLY
    
    public static void UPDATE_CONTACT_FINALLY(){
        if(CONTACTS_MASTER_LIST != null && !CONTACTS_MASTER_LIST.isEmpty()){
            try{
                DatabaseOperation.updateContact(CONTACTS_MASTER_LIST.values(), true, true);
                CONTACTS_MASTER_LIST.clear();
            }//END OF TRY BLOCK
            catch(Exception e){
                System.Debug('----- GOT AN EXCEPTION -----'+e.getMessage());
            }//END OF CATCH BLOCK
        }//END OF IF CONDITION
    }//END OF METHOD UPDATE_CONTACT_FINALLY
    
    public static void UPDATE_OPPTYLINEITEM_FINALLY(){
        if(OLI_MASTER_LIST != null && !OLI_MASTER_LIST.isEmpty()){
            try{
                DatabaseOperation.updateOpportunityLineItem(OLI_MASTER_LIST.values(), true, true);
                OLI_MASTER_LIST.clear();
            }//END OF TRY BLOCK
            catch(Exception e){
                System.Debug('----- GOT AN EXCEPTION -----'+e.getMessage());
            }//END OF CATCH BLOCK
        }//END OF IF CONDITION
    }//END OF METHOD UPDATE_OPPTYLINEITEM_FINALLY
    
    public static void UPDATE_ASSET_FINALLY(){
        if(ASSETS_MASTER_LIST != null && !ASSETS_MASTER_LIST.isEmpty()){
            try{
                DatabaseOperation.updateAsset(ASSETS_MASTER_LIST.values(), true, true);
                ASSETS_MASTER_LIST.clear();
            }//END OF TRY BLOCK
            catch(Exception e){
                System.Debug('----- GOT AN EXCEPTION -----'+e.getMessage());
            }//END OF CATCH BLOCK
        }//END OF IF CONDITION
    }//END OF METHOD UPDATE_ASSET_FINALLY
    
    public static void INSERT_MKT_PAYMENT_FINALLY(){
        if(MKT_PAYMENT_MASTER_LIST != null && !MKT_PAYMENT_MASTER_LIST.isEmpty()){
            try{
                insert MKT_PAYMENT_MASTER_LIST;
                MKT_PAYMENT_MASTER_LIST.clear();
            }//END OF TRY BLOCK
            catch(Exception e){
                System.Debug('----- GOT AN EXCEPTION -----'+e.getMessage());
            }//END OF CATCH BLOCK
        }//END OF IF CONDITION
    }//END OF METHOD INSERT_MKT_PAYMENT_FINALLY
    
    /**----------------------------------------------------------------------------------------------------------------------
    @DEVELOPER: UTIL, INDEPENDENT AND GENERIC METHOD STARTED. PLEASE USE THESE METHOD INSTEAD OF ADDING NEW ROUTINE FOR THE SAME
    -----------------------------------------------------------------------------------------------------------------------**/    
    private static List <DatedConversionRate> dateConversionExchangeRate = new List <DatedConversionRate>();
    
    private static List<DatedConversionRate> retrieveExchangeRate(){
        if(dateConversionExchangeRate.isEmpty()){
            dateConversionExchangeRate = [SELECT Id, IsoCode, StartDate, NextStartDate, ConversionRate FROM DatedConversionRate ORDER BY StartDate DESC];
        }//END OF IF CONDITION       
        return dateConversionExchangeRate;   
    }//END OF METHOD RETRIEVEEXCHANGERATE
    
    /**------------------------------------------------------------
    #METHOD RETURNS A GENERIC MAP OF CURRENCY CODE WITH EXCHNAGE RATE
    ------------------------------------------------------------**/
    public static Map<string,List<DatedConversionRate>> standardExchangeRatesMap = new Map<string,List<DatedConversionRate>>();
    
    public static Map<string,List<DatedConversionRate>> getStandardExchangeRatesMap() {
        if(standardExchangeRatesMap.isEmpty()){
            List<DatedConversionRate> dateConversionExchangeRate2 = retrieveExchangeRate();
            for(DatedConversionRate exchangeRate : dateConversionExchangeRate2){
                if(standardExchangeRatesMap.containsKey(exchangeRate.IsoCode)){
                    standardExchangeRatesMap.get(exchangeRate.IsoCode).add(exchangeRate);
                }else{
                    standardExchangeRatesMap.put(exchangeRate.IsoCode, new List<DatedConversionRate> {exchangeRate});
                }//END OF ELSE CONDITION
            }//END OF FOR LOOP DATEDCONVERSIONRATE  
        }//END OF IF CONDITION
        return standardExchangeRatesMap; 
    }//END OF METHOD GETSTANDARDEXCHANGERATESMAP
    
    public static Account retrievePartiallyUpdatedAccount(Id accountId){    
        if(ACCOUNT_MASTER_LIST != null && !ACCOUNT_MASTER_LIST.isEmpty() && ACCOUNT_MASTER_LIST.containsKey(accountId)){
            return ACCOUNT_MASTER_LIST.get(accountId);
        }else{
            return new Account(Id = accountId);
        }//END OF IF CONDITION
    }//END OF METHOD RETRIEVEPARTIALLYUPDATEDACCOUNT
    
    public static OpportunityLineItem retrievePartiallyUpdatedOLI(Id OLIid){    
        if(OLI_MASTER_LIST != null && !OLI_MASTER_LIST.isEmpty() && OLI_MASTER_LIST.containsKey(OLIid)){
            return OLI_MASTER_LIST.get(OLIid);
        }else{
            return new OpportunityLineItem(Id = OLIid);
        }//END OF IF CONDITION
    }//END OF METHOD RETRIEVEPARTIALLYUPDATEDOLI
    
    private static Map<string, MarketoCustomExchangeRates__c> customExchangeRates2 = new Map<string, MarketoCustomExchangeRates__c>();
    // BELOW METHOD GET CUSTOM EXCHANGE RATE
    /*---------------------------------------------------------------
     *  Modified by  :  Jade 4th Feb 2015
     *  Modification : Changes the logic to populate the  Exchange_Rate_Plan_ARR__c
     *                Now using Opportunity CurrencyIsoCode to get Exchange rate from custom setting
     *                Previously we were using  Opportunity CurrencyIsoCode +  Opportunity Creattion Year to get Exchange rate from custom setting 
     * --------------------------------------------------------------*/
    private static Map<string, MarketoCustomExchangeRates__c> getCustomExchangeRatesMap() {
        if(customExchangeRates2.isEmpty()){
            for(MarketoCustomExchangeRates__c exchngRate : MarketoCustomExchangeRates__c.getall().values()){
                //integer year = (Integer)exchngRate.Exchange_Rate_Plan_Year__c;
               // customExchangeRates2.put(exchngRate.Currency_Code__c+'-'+year, exchngRate);
                customExchangeRates2.put(exchngRate.Currency_Code__c, exchngRate);

            }//END OF FOR LOOP OF MARKETOCUSTOMEXCHANGERATES__C
        }//END OF IF CONDITION
        return customExchangeRates2;
    }//END OF METHOD GETCUSTOMEXCHANGERATESMAP
    
    public static List<Opportunity> final_Opportunity_List = new List<Opportunity>();
        public static List<Opportunity> getAllOpportunityLists(){
        if(final_Opportunity_List.isEmpty()){
            return final_Opportunity_List = 
            [SELECT Id,Is_Winback_Created__c, IsDeleted, AccountId,Account.Bill_To_Contact__c,Account.Ship_To_Contact__c,RecordTypeId, Account.Name, IsPrivate, Name, Description, StageName, Amount, Probability, ExpectedRevenue,
                TotalOpportunityQuantity, CloseDate, Type, NextStep, LeadSource, IsClosed, IsWon, ForecastCategory, ForecastCategoryName, CurrencyIsoCode, CampaignId, HasOpportunityLineItem, Pricebook2Id, OwnerId, CreatedDate, CreatedById, FiscalQuarter, FiscalYear, Fiscal, ConnectionReceivedId, ConnectionSentId, SyncedQuoteId,
                MainCompetitor__c, Lead_Source_Comments__c, Lead_Notes__c, DealLostReason__c, CRM_System__c, Search_String__c, Current_Unofficial_ARR__c,
                 Days_Since_Lead_Created__c,  Sales_Lead_Date__c,  Est_Zero_Stage_Opp_credit__c,
                Est_Stage_One_Opp_Credit__c, SDR_Owner__c,  Deal_Won_By__c, Quote_Number__c, Sales_Probability__c, Deal_Type__c, Parent_Lead_Source__c,   ExistingLandingPage__c,
                Actual_Close_Date__c, /*RequestedKickoffDate__c,Lead_Promotion_Date__c,Days_to_Sales_Lead__c,Demo_Type__c,Project_Type__c, Days_Since_Lead_Promotion__c,Marketo_Subscription_Subplan__c,Marketo_Subscription_Plan__c, ServicesNotes__c,Enablement_Completion_Date__c,*/Referral_Partner__c, Contact_Database_Size__c, /*ProjectType__c,Web_Traffic__c,SFDC_User__c,Project_Start_Date__c,Enablement_Percent_Completed__c,POD__c,Tracking_URL__c,SFDC_Users__c,Project_Temperature__c,Marketo_Login__c,Marketo_Password__c,OpenAir_Percent_Complete_del__c,Partner_Involved_del__c,OA_Product_Purchased_del__c,Primary_Marketo_User_Phone__c,*/ SFDC_Edition__c, 
                    Munchkin_ID__c, Account_String__c,
                Discount_Type__c, Sub_Start_Date__c, Commission_Paid__c, Maximum_Database_Size__c,  /*Channel__c,Product_Interest__c,OA_Partner_Involved__c,*/ Primary_Marketo_User_Email__c,   Additional_Requests__c,  Primary_Marketo_User_Lookup__c,Economic_Decision_Maker__c,Economic_Decision_Maker__r.FirstName, Economic_Decision_Maker__r.email,Primary_Marketo_User_Lookup__r.FirstName,
                 Primary_Enablement_Partner__c, Sub_End_Date__c, Payment_Terms__c, Registered_VAT_No__c, Forecast_Category__c, 
                /*mkto_si__MarketoAnalyzer__c,*/ Estimated_Opp_Value__c, Business_Unit__c,   /*RT__c,*/ Discount_RUSF__c, Spark_Opp__c, 
                Split_Opportunities__c, Total_Discount__c, Payment_Frequency__c, /*Ease_of_Renewal__c,Opportunity_Source__c,Average_Monthly_Email_Volume__c,Sales_Lead_Type__c,Pay_Referral__c,MP_Sandbox__c,Enablement_Project_Stage__c,Services_Required__c,*/  Primary_Marketo_User_OpenAir__c,
                /*Perceived_Customer_Value__c,Quote_Expiration_Date__c,Project_Stage__c,CF_Opp_Id__c,Non_standard_Payment_Terms__c, Enablement_Close_Notes__c,SC_Enablement_Notes__c,*/ Previous_Year_ACV__c, Promotional_End_Date__c,   Competitor_Swap__c, Renewal_Lift__c,
                SFDC_Oppty_Recordtype__c,   Week_Number2__c, Forecast_Category_Probability__c, Accounting_Contact__c,
                Accounting_Email__c, Accounting_Phone__c,  Forecast_Revenue__c, Project_Ref_No__c, Lead_Category__c, Lead_Buying_Behavior__c,
                Closed_2_Target_Active_Development__c, Opportunity_ARR__c, MSI_involved__c, RCA_Involved__c, LID__LinkedIn_Company_Id__c, 
                 Start_Date_Delay__c, MP_Purpose__c, Services_Total__c, Total_Price_Services__c, Subscription__c,  Total_List_Price__c,
                Plan_of_Record_Renewal_Date__c, SwapFormula__c, Compelling_Event__c, Needs_Pains__c, Opportunity_Count__c,  MP_Reseller_Partner__c, 
                Sandbox_Involved__c, Opportunity_Number__c, PO_Number__c,PO_Required__c, Provisioning_Email_Sent__c, Contract_Sign_Date__c,  Term__c, 
                /*Billed_Services__c, Service_Only__c,*/Qualified_Meeting__c, Lead_Source_Summary__c, /*Sales_Outbound_Notes__c,POD_Territory__c,Solutions_Consultant_Email__c,Needs_Internal_Kickoff_Meeting__c,Employee_Range_Summary__c,Reason_Lost_to_Competitor__c,Original_Lead_Created_Date__c,  Solutions_Consultant_Lookup__c,*/ POC_Prov_Email_Sent__c, Corp_Currency_Amount__c, Intacct_Entity__c,Intacct_Entity__r.name,
                Intacct_Custom_Text__c, Actual_Create_Date__c, Opportunity_ARR2012__c,  Opportunity_Reference__c,
                Loss_Description__c, Commission_Payment_Date__c,  Intacct_Sales_Region__c, Prior_Opportunity__c, Quarterly_Renewal__c, 
                Subscription_Language__c, Subscription_Locale__c, Subscription_Time_Zone__c,  Referring_Partner__c, /*,
                 MKT_Transaction__c,SDR_Upsell_Owner__c,MKT_User__c, */ Referral_Partner_Type__c, /*CSM_Email__c, Edition__c,Office_Hours_Purchased__c,*/ Case_Safe_Id__c, Use_Case__c, /*Customer_Support_Manager__c,*/ 
                CSM_Credit__c, Latest_Payment_Date__c, Owner_Role_Mapping__c, /*Apttus_Approval__Approval_Status__c,Rep2__c,Project_Classification__c,  CRM_System_RUSF__c,*/ Sales_Team_Ownership__c/*, MKT_Order__cAdditional_Enablement_Partner__c,*/,
                Renewals_Owner_Id__c,  Created_Day_of_the_Month__c, Number_of_Elite_Products__c, Created_Month_of_the_Year__c,
                /*Split_Opportunity_Last_Payment_Date__c,Credit_Comments__c,CSSClass__c,*/ Split_Opportunity_Case_Safe_ID__c, Blended_Discount__c, Subscription_Discount_Total__c, Subscription_Total__c, Processed__c,
                Owner_Role_Custom__c, Subscription_Days__c, GainsightBlendedDiscount__c,/* APPS-20034 Product_SVS_trunc__c, */Use_Case_RUSF__c, /*Are_Services_Included__c,*/  Dnbi_Status__c,
                 frm_payment__c, Owner_Role_Custom_Text__c, n2de__Is_distributed__c, n2de__Is_reassigned__c, n2de__Last_distributed__c,
                n2de__Last_reassigned__c, Gainsight_Booking_Date__c, Competitive_MA__c, Competitive_ESP__c, Competitors_MA__c, Competitors_ESP__c, /*Implementation__c,*/
                Lost_Reason_Sub__c, Assets_created_on_closed_Won__c,Exchange_Rate_Plan_POR__c, Exchange_Rate_Plan_ARR__c, Prior_Opportunity_ExchangeRate_Date__c,
                Assignment_Email_Project_Type__c,Product_SVS__c,Product_Info__c,Assignment_Email_Sent__c,/*Sent_to_Clarizen__c,Assigned_Consultant_Email__c,Assigned_CEM__c,*/
                Engagement_Manager__c, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.Custom_Text__c,SBQQ__PrimaryQuote__r.SBQQ__MasterContract__c,SBQQ__PrimaryQuote__r.Contract_Lookup__c ,Account.CAM_Owner__c,Account.CRT_Owner__c,Account.CAM_Group__c, SBQQ__PrimaryQuote__r.Country__r.Intacct_Entity__c,SBQQ__PrimaryQuote__r.MKTO_Effective_End_Date__c
                ,
                (
                    SELECT ID, Case_Study_Permission__c, Marketing_Permission__c,SBQQ__Opportunity2__c,Bill_To_Contact__c,Ship_To_Contact__c, SBQQ__Opportunity2__r.AccountID FROM SBQQ__Quotes2__r ORDER BY LastModifiedDate Desc LIMIT 1
                )
                ,
                (
                    SELECT id, OpportunityId, IsPrimary, contactId FROM OpportunityContactRoles
                ),
                (
                    SELECT id, OpportunityId,PriceBookEntryId,Total_ARR_for_RUSF__c, Quantity, Subtotal, UnitPrice, ListPrice, Description, Discount, ServiceDate, ARR__c, Months__c,
                    ARR_Credit_over_12__c, ARR_Credit_under_12__c, ARR_NB_partial_year__c, ARR_Renewal__c, ARR_Spark__c, ARR_Spark_SI__c, ARR_Upsell__c, Calculated_Term__c,
                    DiscountAmount__c, Line_Item_Price__c, Express_Product_Family__c, Product_Type__c, Full_Price__c,/* Geography__c,*/ Instance_Number__c, Line_Item_Note__c,
                    Location__c, MLM_Edition__c, Monthly_Price__c,MRR__c,OpportunityLineItem.pricebookentry.product2.Subscription_Type__c,OpportunityLineItem.pricebookentry.product2.ConvertTo__c, ServiceEndDate__c,OpportunityLineItem.opportunity.account.Id,OpportunityLineItem.opportunity.account.name, 
                    pricebookentry.product2.Included_Marketing_Users__c,related_Asset__c, OpportunityLineItem.Opportunity.Quarterly_Renewal__c, 
                    OpportunityLineItem.Opportunity.Sub_Start_Date__c, OpportunityLineItem.Opportunity.Sub_ENd_date__c, OpportunityLineItem.Opportunity.Name, 
                    pricebookentry.product2.Record_Limitation__c, OpportunityLineItem.Pricebookentry.Product2.Name, OpportunityLineItem.Pricebookentry.Product2.ProductCode, ProductCode,
                    Contract_Quantity__c,/* Opportunity.MKT_User__c,*/Opportunity.AccountId,/*Opportunity.MKT_Transaction__c,*/ Opportunity.CreatedById, PricebookEntry.ProductCode,
                    PricebookEntry.Name, PricebookEntry.Product2Id,  Opportunity.Intacct_Entity__r.Name FROM OpportunityLineItems
                )
            FROM Opportunity WHERE ID IN: opp_Set OR Id IN: OpptyIds OR Id IN: closedOpps.keyset() OR Id IN: paidOpportunitySet OR Id IN: oppIdSet OR Id IN: opp_SetR];/*MKT_Order__c,Opportunity.MKT_Transaction__c,  */
        }//END OF IF CONDITION
        return Final_Opportunity_List;
    }//END OF METHOD GETALLOPPORTUNITYLISTS

    public static void opportunityAdallomTrigger (List<Opportunity> newTrigger, Map<Id, Opportunity> newTriggerMap, List<Opportunity> oldTrigger, Map<Id, Opportunity> oldTriggerMap) { 
        try{
            AdallomAudit__c audit = new AdallomAudit__c();
            audit.UserId__c = UserInfo.getUserId();
            audit.Timestamp__c = System.now(); 
            audit.ObjectName__c = 'Opportunity';
            if (Trigger.isDelete) {
                if (oldTrigger.size() == 1) {
                    String serializedValue = System.JSON.serialize(oldTrigger[0]); 
                    if (serializedValue.length() <= 32768) { 
                       audit.OldObjectJSON__c = serializedValue; 
                    }//END OF IF CONDITION
                    audit.ActionType__c = 'DELETE';
                    audit.ObjectId__c = oldTrigger[0].Id;
                    audit.ObjectTitle__c = oldTrigger[0].Name;
                } else {
                   audit.ActionType__c = 'MASS_DELETE';
                   audit.ObjectIds__c = System.JSON.serialize(oldTriggerMap.keySet());
                }//END OF IF CONDITION
            } else {
                if (Trigger.isInsert) {
                    if (newTrigger.size() == 1) {
                        String serializedValue = System.JSON.serialize(newTrigger[0]); 
                        if (serializedValue.length() <= 32768) { 
                            audit.NewObjectJSON__c = serializedValue; 
                        }//END OF IF CONDITION
                        audit.ActionType__c = 'INSERT';
                        audit.ObjectId__c = newTrigger[0].Id;
                        audit.ObjectTitle__c = newTrigger[0].Name;
                    } else {
                        audit.ActionType__c = 'MASS_INSERT';
                        audit.ObjectIds__c = System.JSON.serialize(newTriggerMap.keySet());
                    }//END OF IF CONDITION
                } else {
                    if (newTrigger.size() == 1) {
                        String serializedValue = System.JSON.serialize(oldTrigger[0]); 
                        if (serializedValue.length() <= 32768) { 
                           audit.OldObjectJSON__c = serializedValue; 
                        }//END OF IF CONDITION
                        serializedValue = System.JSON.serialize(newTrigger[0]); 
                        if (serializedValue.length() <= 32768) { 
                            audit.NewObjectJSON__c = serializedValue; 
                        }//END OF IF CONDITION
                        audit.ActionType__c = 'UPDATE';
                        audit.ObjectId__c = newTrigger[0].Id;
                        audit.ObjectTitle__c = newTrigger[0].Name;
                    } else {
                        audit.ActionType__c = 'MASS_UPDATE';
                        audit.ObjectIds__c = System.JSON.serialize(newTriggerMap.keySet());
                    }//END OF IF CONDITION 
                }//END OF ELSE CONDITION 
            }//END OF ELSE CONDITION  
            insert audit; 
        } catch (Exception e) {System.Debug('___GOT AN EXCEPTION____');} 
    }//END OF METHOD OPPORTUNITYADALLOMTRIGGER
   
    public static Map<Id,List<Opportunity>> accIdOppsMap = new Map<Id,List<Opportunity>>();
    public static Opportunity populateOpptyFieldsChecking(Opportunity opp){
        if((opp.Type == UPSELL_CROSSELL_OPPTY && opp.AccountId != null) || opp.Type == RENEWAL_OPPTY){
            if(accIdOppsMap != null && accIdOppsMap.containsKey(opp.AccountId)){
                accIdOppsMap.get(opp.AccountId).add(opp);
            }else{
                accIdOppsMap.put(opp.AccountId, new List<Opportunity>{opp});
            }//END OF IF CONDITION
        }//END OF IF CONDITION
        return opp;    
    }//END OF METHOD POPULATEOPPTYFIELDSCHECKING
  
    public static Map<Id,Account> accountBeforeInsertMap = new Map<Id,Account>();
    public static Map<Id,Account> getAccountMapinBeforeInsert(Set<Id> accId){
        if(accountBeforeInsertMap.isEmpty()){
            for(Account acc :[Select Id,Engagement_Mgr_Owner__c,(Select Id, Name, StageName, CloseDate, Type,CRM_Data_Source__c,CRM_System__c from Opportunities where StageName = 'Closed Won' and Type != 'Upsell/Crossell' order by CloseDate desc) from Account where Id in:accId]){
                accountBeforeInsertMap.put(acc.Id,acc);
            }//END OF FOR LOOP ACCOUNT
        }//END OF IF CONDITION
        return accountBeforeInsertMap;
    }//END OF METHOD GETACCOUNTMAPINBEFOREINSERT
    
    
    /*--------------------------------------------------------------------
    #METHOD IS USED TO POPULATE THE RENEWAL OPPORTUNITY FIELD AT THE TIME OF
    RENEWAL OPPORTUNITY CREATION FROM THE PRIOR OPPORTUNITY PRIMARY QUOTE
    ---------------------------------------------------------------------**/
    
    // Populate Renewal Opportunity Fields from Prior Opportunity's Primary Quote - Jira - APPS-2259
    public static Set<Id> priorOppIdSBSet = new Set<Id>();
    public static Set<Id> priorOppIdLegacySet = new Set<Id>();

    public static Opportunity populateRenOppFieldsChecking(Opportunity opp){
        if(opp.Prior_Opportunity__c != null && opp.Type == RENEWAL_OPPTY && opp.Pricebook2Id == SBPB.ID__c){
            priorOppIdSBSet.add(opp.Prior_Opportunity__c);
        }else if(opp.Prior_Opportunity__c != null && opp.Type == RENEWAL_OPPTY){
            priorOppIdLegacySet.add(opp.Prior_Opportunity__c);
        }//END OF IF CONDITION
        return opp;
    }//END OF METHOD POPULATERENOPPFIELDSCHECKING

    /*public static void populateOpportunityFields(List<Opportunity> newlist, Map<Id,Opportunity> newMap){
    }*/
    public static void populateOpportunityFields(List<Opportunity> newlist, Map<Id,Opportunity> newMap, Map<Id,Opportunity> oldMap){
    
        Map<Id,list<String>> LineDetail     = new Map<Id,list<string>>();
        Map<Id,list<String>> ServiceDetail  = new Map<Id,list<string>>();
        String Ldetail = '';
        String SDetail = '';
        List<OpportunityLineItem> OliList = new List<OpportunityLineItem>();
        Map<Id, List<OpportunityLineItem>> lineItemMap = new Map<Id, List<OpportunityLineItem>>();
        Map<String, List_of_Elite_Products__c> EliteProductsMap = List_of_Elite_Products__c.getAll();
        Map<Id,Set<String>> existProdCode = new Map<Id,Set<String>>();
        Map<String,String> prdcodeCountneeded = new Map<String,String>();
        Map<String,Integer> prdcodeMap = new Map<String,Integer>();
        
        List<string> VALID_ProductCode = System.label.University_Launchpacks.split(',');
        Set<string> set_productcodes = new Set<String>();
        set_productcodes.addall(VALID_ProductCode);
        Map<Id, Boolean> LaunchOpptyMap = new Map<Id,Boolean>();
        
        for(OpportunityLineitem op : [SELECT MKTO_Net_Unit_Price__c, PricebookEntry.Product2.PS_Hours_per_Qty_T_M_only__c,PricebookEntry.Product2.Intacct_T_M_RR__c, PricebookEntry.ProductCode,Product_Type__c,PricebookEntry.Product2.Family,PricebookEntry.Name,id,UnitPrice,Quantity,OpportunityId,Discount,TotalPrice,/*Geography__c,*/Rev_Rec_Template__c,MLM_Edition__c FROM OpportunityLineitem WHERE Opportunityid IN : newlist ORDER BY CreatedDate]){
    
            Integer i =  1;
            /**-- THE BELOW METHOD POPULATE THE NUMBEROFELITEPRODUCTS ON OPPORTUNITY--STARTS---**/  
            if(lineItemMap.get(op.OpportunityId) != null){
                lineItemMap.get(op.OpportunityId).add(op);
            }//END OF IF CONDITION
            else{
                List<OpportunityLineItem> oppLineItemList = new List<OpportunityLineItem>();
                oppLineItemList.add(op);
                lineItemMap.put(op.OpportunityId, oppLineItemList);
            }//END OF ELSE CONDITION
            
            if(!closeWonOpptyIds.isEmpty()){
                if(closeWonOpptyIds.contains(op.OpportunityId)){
                    if(op.Product_Type__c == OPPTY_PRODUCT_TYPE_SERVICES) {
                        SDetail = op.PricebookEntry.ProductCode;
                        if(op.PricebookEntry.Product2.Intacct_T_M_RR__c){
                            if(existProdCode != null && !existProdCode.isEmpty() && existProdCode.containsKey(op.OpportunityId)){
                                Set<String> mapprdcode = new Set<String>();
                                mapprdcode = existProdCode.get(op.OpportunityId);
                                if(mapprdcode != null && !mapprdcode.isEmpty() && mapprdcode.contains(op.PricebookEntry.ProductCode)){
                                    if(prdcodeMap != null && !prdcodeMap.isEmpty() && prdcodeMap.containskey(op.PricebookEntry.ProductCode)){
                                        Integer j = prdcodeMap.get(op.PricebookEntry.ProductCode);
                                        j = j +1;
                                        i = j;
                                        prdcodeMap.put(op.PricebookEntry.ProductCode,j);
                                    }else{
                                        i = 2;
                                        prdcodeMap.put(op.PricebookEntry.ProductCode,2);
                                    }
                                }else{
                                    mapprdcode.add(op.PricebookEntry.ProductCode);
                                    existProdCode.put(op.OpportunityId,mapprdcode);
                                }
                            }else{
                                Set<String> prdcode = new Set<String>();
                                prdcode.add(op.PricebookEntry.ProductCode);
                                existProdCode.put(op.OpportunityId,prdcode);
                            }
                              Decimal MKTO_NET = op.MKTO_Net_Unit_Price__c;
                            if(op.PricebookEntry.Product2.PS_Hours_per_Qty_T_M_only__c != null && op.PricebookEntry.Product2.PS_Hours_per_Qty_T_M_only__c != 0){
                                if(MKTO_NET != null && MKTO_NET != 0){
                                    MKTO_NET = MKTO_NET/op.PricebookEntry.Product2.PS_Hours_per_Qty_T_M_only__c;
                                }
                            }
                            SDetail = op.PricebookEntry.ProductCode+'|' + MKTO_NET+'|'+i;
                            //SDetail = op.PricebookEntry.ProductCode+'|' + op.MKTO_Net_Unit_Price__c+'|'+i;
                        }   
                        if(!ServiceDetail.keyset().contains(op.OpportunityId)) {
                            ServiceDetail.put(op.OpportunityId,new List<string>{SDetail});
                            prdcodeCountneeded.put(SDetail,op.PricebookEntry.ProductCode);
                        }else {
                            ServiceDetail.get(op.OpportunityId).add('|'+SDetail);
                            prdcodeCountneeded.put('|'+SDetail,op.PricebookEntry.ProductCode);
                        }//END OF ELSE CONDITION
                    }//END OF IF CONDITION
                    Ldetail=' | ' + op.PricebookEntry.Name+' | '+op.Product_Type__c+ ' | ';
                    if(!LineDetail.keyset().contains(op.OpportunityId)) {
                        LineDetail.put(op.OpportunityId,new List<string>{Ldetail});
                    }else {
                        LineDetail.get(op.OpportunityId).add('\n'+Ldetail);
                    }//END OF ELSE CONDITION
                }//END OF IF CONDITION
            }//END OF IF CONDITION
            if(!LaunchOpptyMap.containsKey(op.OpportunityId)){
                if(set_productcodes != null && !set_productcodes.isEmpty() && set_productcodes.contains(op.PricebookEntry.ProductCode)){
                    LaunchOpptyMap.put(op.OpportunityId,True);
                }
            }
        }//END OF FOR LOOP OPPORTUNITYLINEITEM

        /** ---BELOW ACCOUNT MAP IS USED FOR POPULATING ENGAGEMENT MANAGER AND PRIOR OPPORTUNITY FIELD----ENDS---**/
        Map<Id,Account> Acc_OppMap = getAccountMapinBeforeInsert(accIdOppsMap.keySet());
        Map<Id,SBQQ__Quote__c> priorOppIdQuoteMap = new Map<Id,SBQQ__Quote__c>();
        Map<Id,Quote> priorOppIdStdQuoteMap = new Map<Id,Quote>();
        
        if(trigger.isInsert){
            /**---------BELOW STEPS POPULATE RENEWAL OPPORTUNITY FIELD FROM PRIOR OPPORTUNITY PRIMARY QUOTE --STARTS----------**/
            
            if(!priorOppIdSBSet.isEmpty()){
                for(SBQQ__Quote__c quot :[Select Id, SBQQ__Opportunity2__c, Payment_Frequency__c, SBQQ__Opportunity2__r.Account.PO_Required__c,  SBQQ__Opportunity2__r.Account.ABN_No__c, SBQQ__Opportunity2__r.Account.Registered_VAT_No__c, SBQQ__Primary__c, Marketing_Permission__c, Case_Study_Permission__c, Custom_Agreement_Name_and_Date__c, SBQQ__PaymentTerms__c, Hide_Discount__c, Enterprise_Roll_up_SKU__c, Renewal_Uplift_pct__c, Renewal_Uplift_Text__c From SBQQ__Quote__c where SBQQ__Opportunity2__c IN :priorOppIdSBSet and SBQQ__Primary__c = true]){
                    priorOppIdQuoteMap.put(quot.SBQQ__Opportunity2__c, quot);
                }//END OF FOR LOOP SBQQ__QUOTE__C
            }else{
                for(Quote thisQuote :[Select Id, Opportunity.Account.PO_Required__c, Opportunity.Account.ABN_No__c, Opportunity.Renewal_Uplift_Text__c, Opportunity.Enterprise_Roll_up_SKU__c, Opportunity.Hide_Discount__c, PO__c, Increase_Language__c, IsSyncing, Opportunity.Custom_Agreement_Name_and_Date__c, OpportunityId, Payment_Frequency__c, Customer_gives_Marketing_Permission__c, Case_Study_Permission__c, Payment_Terms__c from Quote where OpportunityId IN :priorOppIdLegacySet and IsSyncing = true]){
                    priorOppIdStdQuoteMap.put(thisQuote.OpportunityId, thisQuote);
                }//END OF FOR LOOP QUOTE
            }//END OF ELSE CONDITION
        }//END OF IF CONDITION
        
        for(Opportunity o : newlist) {
            String line     ='';
            String Sline    ='|'; 
            if(LineDetail.keyset().contains(o.id)) {
                for(string s:LineDetail.get(o.id)) {
                    line+=s;
                }//END OF FOR LOOP OF STRING
                o.Product_Info__c=line;
            }else {
                o.Product_Info__c = '';
            }//END OF ELSE CONDITION
            if(ServiceDetail.keyset().contains(o.id)) {
                for(string s:ServiceDetail.get(o.id)) {
                    if(prdcodeCountneeded != null && !prdcodeCountneeded.isEmpty() && prdcodeCountneeded.containsKey(s)){
                        if(prdcodeMap != null && !prdcodeMap.isEmpty() && !prdcodeMap.containsKey(prdcodeCountneeded.get(s))){
                            if(s.endsWithIgnoreCase('|1')){
                                Integer removestr = s.lastIndexOf('|1');
                                s = s.substring(0,removestr );
                            }
                        }
                    }
                    Sline+=s;
                }//END OF FOR LOOP OF STRING
         /* code added by grazitti to truncatinate the size of Product_SVS as per the ticket APPS-20034 */
        Sline += '|';
        if(o.Product_SVS__c==null && o.stagename=='Closed Won'){
          if(Sline.length()>255){
          o.Product_SVS__c = Sline.abbreviate(255);
          }
          else{
            o.Product_SVS__c = Sline;
          }
        }
      //********* End of APPS-20034 ************
            }else{
                o.Product_SVS__c = '';
            }//END OF ELSE CONDITION

            if(trigger.isInsert){
            
                /** -----PROCESS 2 ---------------POPULATE OPPORTUNITY FIELDS-------------**/
                if(Acc_OppMap != null && Acc_OppMap.containsKey(o.AccountId)){
                    if(o.Type == UPSELL_CROSSELL_OPPTY){
                        if(!Acc_OppMap.get(o.AccountId).Opportunities.isEmpty()){
                            o.Prior_Opportunity__c = Acc_OppMap.get(o.AccountId).Opportunities[0].Id;
              
                          //Code added by Jade Global Inc
                          //Date: 15th March 2017
                          //JIRA Reference --> APPS-11876:Carry forward of the CRM system from New Business or Recent Renewal
                          o.CRM_System__c=Acc_OppMap.get(o.AccountId).Opportunities[0].CRM_System__c!=null ? Acc_OppMap.get(o.AccountId).Opportunities[0].CRM_System__c:null;
                            o.CRM_Data_Source__c=Acc_OppMap.get(o.AccountId).Opportunities[0].CRM_Data_Source__c!=null ? Acc_OppMap.get(o.AccountId).Opportunities[0].CRM_Data_Source__c : null;
              
                        }//END OF IF CONDITION
                        if(Acc_OppMap != null && Acc_OppMap.containsKey(o.AccountId)){
                            o.Engagement_Manager__c = Acc_OppMap.get(o.AccountId).Engagement_Mgr_Owner__c;
                        }//END OF IF CONDITION
                    }else if(o.Type == RENEWAL_OPPTY){
                        if(Acc_OppMap != null && Acc_OppMap.containsKey(o.AccountId)){
                            o.Engagement_Manager__c = Acc_OppMap.get(o.AccountId).Engagement_Mgr_Owner__c;
                        }//END OF IF CONDITION
                    }//END OF ELSE CONDITION
                }//END OF IF CONDITION              
                /** -PROCESS 3 -----------POPULATE RENEWAL OPPORTUNITY FIELD FROM PRIOR OPPORTUNITY PRIMARY QUOTE----*/
                if(o.Type == RENEWAL_OPPTY && o.Prior_Opportunity__c != null){
                    if(o.Pricebook2Id == SBPB.ID__c && priorOppIdQuoteMap.containsKey(o.Prior_Opportunity__c)){
                        // If SteelBrick Opportunity - Quote Fields
                        SBQQ__Quote__c thisOppQuote = priorOppIdQuoteMap.get(o.Prior_Opportunity__c);
                        o.Pricebook2Id = SBPB.ID__c;
                        o.Marketing_Permission__c = thisOppQuote.Marketing_Permission__c != null? thisOppQuote.Marketing_Permission__c : null;
                        //Commented as per APPS-20840
                        //o.Case_Study_Permission__c = thisOppQuote.Case_Study_Permission__c != null ? thisOppQuote.Case_Study_Permission__c : null;
                        o.Custom_Agreement_Name_and_Date__c = thisOppQuote.Custom_Agreement_Name_and_Date__c != null ? thisOppQuote.Custom_Agreement_Name_and_Date__c : null;
                        o.Payment_Terms__c = thisOppQuote.SBQQ__PaymentTerms__c != null ? thisOppQuote.SBQQ__PaymentTerms__c : null;
                        o.Payment_Frequency__c = thisOppQuote.Payment_Frequency__c != null ? thisOppQuote.Payment_Frequency__c : null;
                        o.Hide_Discount__c = thisOppQuote.Hide_Discount__c != null ? thisOppQuote.Hide_Discount__c : null;
                        o.Enterprise_Roll_up_SKU__c = thisOppQuote.Enterprise_Roll_up_SKU__c != null ? thisOppQuote.Enterprise_Roll_up_SKU__c : null;
                        o.Renewal_Uplift_pct__c = thisOppQuote.Renewal_Uplift_pct__c != null ? thisOppQuote.Renewal_Uplift_pct__c : null;
                        o.Renewal_Uplift_Text__c = thisOppQuote.Renewal_Uplift_Text__c != null ? thisOppQuote.Renewal_Uplift_Text__c : null;
                        // Fields coming from Account
                        o.PO_Required__c = thisOppQuote.SBQQ__Opportunity2__r.Account.PO_Required__c != null ? thisOppQuote.SBQQ__Opportunity2__r.Account.PO_Required__c : null;
                        o.ABN_No__c = thisOppQuote.SBQQ__Opportunity2__r.Account.ABN_No__c != null ? thisOppQuote.SBQQ__Opportunity2__r.Account.ABN_No__c : null;
                            
                    }else if(o.Type == RENEWAL_OPPTY && o.Prior_Opportunity__c != null){
                        // Legacy Opportunity
                        if(!priorOppIdStdQuoteMap.isEmpty() && priorOppIdStdQuoteMap.containsKey(o.Prior_Opportunity__c)){
                            Quote thisOppQuote = priorOppIdStdQuoteMap.get(o.Prior_Opportunity__c);
                            o.Marketing_Permission__c = thisOppQuote.Customer_gives_Marketing_Permission__c != null? thisOppQuote.Customer_gives_Marketing_Permission__c : null;
                            //Commented as per APPS-20840
                            //o.Case_Study_Permission__c = thisOppQuote.Case_Study_Permission__c != null ? thisOppQuote.Case_Study_Permission__c : null;
                            o.Custom_Agreement_Name_and_Date__c = thisOppQuote.Opportunity.Custom_Agreement_Name_and_Date__c != null ? thisOppQuote.Opportunity.Custom_Agreement_Name_and_Date__c : null;
                            o.Payment_Terms__c = thisOppQuote.Payment_Terms__c != null ? thisOppQuote.Payment_Terms__c : null;
                            o.Payment_Frequency__c = thisOppQuote.Payment_Frequency__c != null ? thisOppQuote.Payment_Frequency__c : null;
                            o.Hide_Discount__c = thisOppQuote.Opportunity.Hide_Discount__c != null ? thisOppQuote.Opportunity.Hide_Discount__c : null;
                            o.Enterprise_Roll_up_SKU__c = thisOppQuote.Opportunity.Enterprise_Roll_up_SKU__c != null ? thisOppQuote.Opportunity.Enterprise_Roll_up_SKU__c : null;
                            if(thisOppQuote.Increase_Language__c != null){
                                String s1 = thisOppQuote.Increase_Language__c;
                                Integer perInte = Integer.valueOf(s1.substring(Integer.valueOf(s1.indexOf('%')) - 1,Integer.valueOf(s1.indexOf('%'))));
                                o.Renewal_Uplift_pct__c = String.valueOf(perInte);
                            }else{
                                o.Renewal_Uplift_pct__c = null;
                            }//END OF ELSE CONDITION              
                            o.Renewal_Uplift_Text__c = thisOppQuote.Opportunity.Renewal_Uplift_Text__c != null ? thisOppQuote.Opportunity.Renewal_Uplift_Text__c : null;                            
                            
                            //  Fields coming from Account
                            o.PO_Required__c = thisOppQuote.Opportunity.Account.PO_Required__c != null ? thisOppQuote.Opportunity.Account.PO_Required__c : null;
                            o.ABN_No__c = thisOppQuote.Opportunity.Account.ABN_No__c != null ? thisOppQuote.Opportunity.Account.ABN_No__c : null;
                        }//END OF IF CONDITION
                    }//END OF ELSE IF CONDITION
                }//END OF IF CONDITION
            }//END OF IF CONDITION
            else if(trigger.isUpdate){
                Integer numberOfEliteProds = 0;
                if(lineItemMap.get(o.Id) != null){
                    for(OpportunityLineItem oppLineItem :lineItemMap.get(o.Id)){
                        if(EliteProductsMap.get(oppLineItem.PriceBookEntry.ProductCode) != null){
                            numberOfEliteProds = numberOfEliteProds + 1;
                        }//END OF IF CONDITION
                    }//END OF FOR LOOP OF OPPORTUNITYLINEITEM
                }//END OF IF CONDITION    
                o.Number_of_Elite_Products__c = numberOfEliteProds;
                if(o.stagename != null && o.StageName == 'Closed Won' && oldMap.get(o.Id).StageName != null && oldMap.get(o.Id).StageName != o.StageName){
                    if(LaunchOpptyMap != null && o.Launch_Pack_Check__c ==false && LaunchOpptyMap.containsKey(o.Id)){
                        o.Launch_Pack_Check__c = true;
                    }
                }
            }//END OF IF CONDITION
        }//END OF FOR LOOP OF OPPORTUNITY
    }//END OF METHOD POPULATEOPPORTUNITYFIELDS
    
    /**----------------------------------------------
    BELOW QUERY IS USED FOR BEFORE OPERATIONS, IF NECESSARY RETRIVE OTHER LEVEL FIELDS IN THIS QUERY 
    -------------------------------------------------**/
    public static Map<Id,Opportunity> getOpptyBeforeUpdateMap = new Map<Id,Opportunity>();
    public static Map<Id,Opportunity> getIntacctOpportunityMap(Set<Id> oppIds){
        if(getOpptyBeforeUpdateMap.isEmpty()){
      Map<Id,Opportunity> OppRecordMap = new Map<Id,Opportunity>([SELECT Id, Name ,Intacct_Entity__r.name, Intacct_Custom_Text__c , SyncedQuoteId, SyncedQuote.Additional_Terms_Finance__c, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.Custom_Text__c, SBQQ__PrimaryQuote__r.Country__r.Intacct_Entity__c FROM Opportunity WHERE ID IN: oppIds]);
            getOpptyBeforeUpdateMap = OppRecordMap ;
        }//END OF IF CONDITION
        return getOpptyBeforeUpdateMap;
    }//END OF METHOD GETINTACCTOPPORTUNITYMAP
    
    /**------------------------------------------------------------------------------------------------------
    BELOW METHOD POPULATE INTACCT CUSTOM TEXT FIELD ON OPPORTUNITY FROM RELATED SBQQ QUOTE AND STANDRAD QUOTE
    -------------------------------------------------------------------------------------------------------**/
    public static void populateOpportunityIntacctCustomTextField (List<Opportunity> newList, Map<Id,Opportunity> newMap){
        Map<Id,Opportunity> OpptyWithIntacctInfoMap = getIntacctOpportunityMap(newMap.keySet());
        if(OpptyWithIntacctInfoMap != null || !OpptyWithIntacctInfoMap.isEmpty()){
            for(Opportunity opp : newList){
                if(OpptyWithIntacctInfoMap.containsKey(opp.Id)){
                    Opportunity op = OpptyWithIntacctInfoMap.get(opp.Id);
                    if(op.SyncedQuote.Additional_Terms_Finance__c != null || op.SBQQ__PrimaryQuote__r.Custom_Text__c != null){
                        if(op.SyncedQuote.Additional_Terms_Finance__c != null){
                            opp.Intacct_Custom_Text__c = op.SyncedQuote.Additional_Terms_Finance__c;
                        }else if(op.SBQQ__PrimaryQuote__r.Custom_Text__c != null){
                            opp.Intacct_Custom_Text__c = op.SBQQ__PrimaryQuote__r.Custom_Text__c;
                        }//END OF ELSE IF CONDITION
                        if(opp.Intacct_Custom_Text__c!= null){
                            opp.Intacct_Custom_Text__c = opp.Intacct_Custom_Text__c.stripHtmlTags();
                        }
                    }//END OF IF CONDITION
                }//END OF IF CONDITION
            }//END OF FOR LOOP OPPORTUNITY
        }//END OF IF CONDITION
    }//END OF METHOD POPULATEOPPORTUNITYINTACCTCUSTOMTEXTFIELD
    
     /**------------------------------------------------------------------------------------------------------
         BELOW METHOD CHECK FOR THE INTACCT RELATED FIELDS IF POPULATED ON OPPORTUNITY
    -------------------------------------------------------------------------------------------------------**/
/*
public static Opportunity updateCLZProductDataChecking(Opportunity opp){
 if(opp.StageName != CLOSED_WON_OPPTY && (opp.Intacct_Entity__c != null || opp.Intacct_Sales_Region__c != null || opp.Intacct_Customer_ID__c != null)){
  opptyMapforCLZ.put(opp.Id, opp);
 }
 return opp;
}   
 public static void updateCLZProductData(){
     if(opptyMapforCLZ != null && !opptyMapforCLZ.isEmpty()){
      Map<id,opportunity> oppMap = opptyMapforCLZ;
      List<clzV5__Clarizen_Project__c> lstClzProjtoUpdate = new List<clzV5__Clarizen_Project__c>();
      
      for(clzV5__Clarizen_Project__c clz : [SELECT ID,clzV5__Opportunity__r.Id,CLZ_C_IntacctCustomerIDProj__c,CLZ_C_IntacctEntity__c,CLZ_C_IntacctProjectLocation__c from clzV5__Clarizen_Project__c where clzV5__Opportunity__r.Id in : oppMap.keyset()]){
       Boolean isUpdated = False;
       if(oppMap.containsKey(clz.clzV5__Opportunity__r.Id)){
            if(clz.CLZ_C_IntacctCustomerIDProj__c != oppMap.get(clz.clzV5__Opportunity__r.Id).Intacct_Customer_ID__c && oppMap.get(clz.clzV5__Opportunity__r.Id).Intacct_Customer_ID__c != null){
             isUpdated = True;
             clz.CLZ_C_IntacctCustomerIDProj__c = oppMap.get(clz.clzV5__Opportunity__r.Id).Intacct_Customer_ID__c;
            }
            if(clz.CLZ_C_IntacctEntity__c != oppMap.get(clz.clzV5__Opportunity__r.Id).Intacct_Entity_Name__c && oppMap.get(clz.clzV5__Opportunity__r.Id).Intacct_Entity_Name__c != null){
             isUpdated = True;
             clz.CLZ_C_IntacctEntity__c = oppMap.get(clz.clzV5__Opportunity__r.Id).Intacct_Entity_Name__c;
            }
            
            if(clz.CLZ_C_IntacctProjectLocation__c != oppMap.get(clz.clzV5__Opportunity__r.Id).Intacct_Sales_Region__c && oppMap.get(clz.clzV5__Opportunity__r.Id).Intacct_Sales_Region__c != null){
             isUpdated = True;
             clz.CLZ_C_IntacctProjectLocation__c = oppMap.get(clz.clzV5__Opportunity__r.Id).Intacct_Sales_Region__c;
            }
       }
       if(isUpdated){
        lstClzProjtoUpdate.add(clz);
       }
      }
      if(!lstClzProjtoUpdate.isEmpty()){
       update lstClzProjtoUpdate;
      }
     }
    }//END OF METHOD
*/ 

  /************ BELOW METHOD IS USED TO PREVENT USER FROM CHANGING THE INTACCT ENTITY ON OPPORTUNITY */
    public static void validIntacctEntity(List<Opportunity> newList, Map<Id,Opportunity> oldMap){
        
        List<Opportunity> GetCurrentOpptyList  = getAllOpportunityLists();
        //Fetching the SteelBrick pricebook ID stored in the custom setting.
        SteelBrickCPQPricebook__c SBPBRecord = SteelBrickCPQPricebook__c.getOrgDefaults();
        Map<Id,Opportunity> OpptyIntacctInfoMap = new Map<Id,Opportunity>();
        for(Opportunity opp : GetCurrentOpptyList){
            OpptyIntacctInfoMap.put(opp.Id, opp);
        }
        for(Opportunity opp : newList){
        /****************************************************************************
        * Modified By  : JadeGlobal on 24th May 2016
        * Modification  : Bypassing the below code for Non-Steelbrick Opportunity.
        *                 Validation should not fire for Non-Steelbrick Opportunity.
        *                 Added IF block to check Non-SB pricebook of Opportunity.
        *                 Now Validation will fire only for SB Opportunity
        *******************************************************************************/
         /******************************************************************************
     Modified By  : JadeGlobal on 8th June 2016
     Modification   : Added the condition to bypass the split opportunities from 
              this validation in below IF Loop
    **********************************************************************************/
     if (opp.pricebook2id != null && (opp.pricebook2id == SBPBRecord.ID__c || opp.pricebook2id == SBPBRecord.Case_Safe_ID__c) && (opp.Split_Opportunities__c==null || opp.Type!='Upsell/Crossell') && opp.SBQQ__PrimaryQuote__c!=null){
            if(!OpptyIntacctInfoMap.isEmpty() && OpptyIntacctInfoMap.containsKey(opp.Id)){
                Opportunity currtOppty = OpptyIntacctInfoMap.get(opp.Id);
                if(opp.Intacct_Entity__c != null && opp.Intacct_Entity__c != oldMap.get(opp.Id).Intacct_Entity__c){
                    if(currtOppty.Intacct_Entity__r.name != currtOppty.SBQQ__PrimaryQuote__r.Country__r.Intacct_Entity__c && !test.isrunningtest()){
                        opp.addError(System.Label.Opportunity_Intacct_Entity_Validation);
                    }
                }else if(opp.Intacct_Entity__c ==  null && oldMap.get(opp.Id).Intacct_Entity__c != null && currtOppty.SBQQ__PrimaryQuote__r.Country__r.Intacct_Entity__c != null && !test.isrunningtest()){
                    opp.addError(System.Label.Opportunity_Intacct_Entity_Validation);
                }
            }//End of IF Block for keyset check 
          }//End of IF block of Pricebook
        }//End of Opportunity FOR loop
    }//End of Method 
    
    //Commented as per APPS-20840
    //Method Added by Jade on 21st July 2016
    //This method will run on every Renewal Update [And not on Closed won of Renewal]
    //This Method will calculate the APOR on every Renewal update by considering the manually adjusted APOR factor
    /*public static void OpportunityAPORCalcOnRNWLUpdate(List<Opportunity> newList, Map<Id,Opportunity> oldMap){

        if(!newList.isEmpty()){
            for(Opportunity oppty : newList){
                if(oppty.Ghost__c == FALSE && oppty.Type == RENEWAL_OPPTY && oppty.isWon == FALSE && oppty.Manual_APOR_Adjustment__c != OldMap.get(oppty.id).Manual_APOR_Adjustment__c && oppty.Manual_APOR_Adjustment__c != null && oppty.Manual_APOR_Adjustment__c != 0){
                    oppty.Adjusted_POR__c += oppty.Manual_APOR_Adjustment__c;
                }//End of IF
            }//End of FOR
        }//End of IF
    }*///End of Method OpportunityAPORCalcOnRNWLUpdate();
    
    
    /*
    Method Name: OpportunityAPORCalcRevisited()
    Author: JadeGlobal Inc.
    Date: 29th August 2016
    This method will be called on AFTER UPDATE event on Opportunity [Closed Won of Upsell/Crossell].
    This is a newly designed method for APOR calculation on Renewal Opportunity at the time of MDQ.
    */
    
    public static list<Opportunity> OpportunityAPORCalcRevisited(list<Opportunity> newOppList,map<id,Opportunity> OldMap,String triggerEvent){
    
        //Set of AccountIds to fetch all the related opptys
        Set<id> PriorOpptyIds = new set<id>();
        Set<id> CurrentOpptyId = new set<id>();
    
        //List of relevant renewal oppty
        List<Opportunity> listRelevantOpptys = new List<Opportunity>();
        
        //map of prior Oppty and it's Renewal
        Map<id,Opportunity> MapOpptyAndRenewalOppty = new Map<id,Opportunity>();
        
        //List of OLIs from current Opptys
        map<id,list<OpportunityLineItem>> MapOpptyAndOpptyLines = new map<id,list<OpportunityLineItem>>();
        
        //Map of prior oppty and contract
        Map<id,Contract> mapPriorOpptyAndContract = new Map<id,Contract>();
        
        //List of Renewal Opptys to be updated with new APOR
        list<Opportunity> ListOfRenewalsTobeUpdated = new list<Opportunity>();
        
        //map of Opportunity Id and Opprtunities
        map<id,Date> MapOpptyIdAndOpportunity = new map<id,Date>();
        
        //List of Renewal Opptys Being inserted
        set<id> setNewRenewalsBeingInserted = new set<id>();
        set<id> setPriorOpptysOfRenewals = new set<id>();
        Map<String,List<DatedConversionRate>> CurrConvsMap  = getStandardExchangeRatesMap();
             
        if(!newOppList.isEmpty()){
            
            for(Opportunity oppty: newOppList){
                if(Trigger.isUpdate){
                    if(oldMap.ContainsKey(oppty.id)){
                    Opportunity OldOppty = oldMap.get(oppty.id);
                        if(oppty.Type == UPSELL_CROSSELL_OPPTY && (oppty.SBQQ__PrimaryQuote__c != null || oppty.Pricebook2Id != SBPB.ID__c) && oppty.isWon == TRUE && oppty.isWon != OldOppty.isWon && oppty.Opportunity_ARR2012__c != 0 && oppty.Prior_Opportunity__c != null){
                            //Populating CurrentOpportunityId in CurrentOpptyId set
                            CurrentOpptyId.add(oppty.id);
                            //Populating PriorOpportunityId in PriorOpptyIds set
                            PriorOpptyIds.add(oppty.Prior_Opportunity__c);
                        }//End of If
                    }//End of If
                }//If isUpdate
                
                //This will be executed at the Renewal Oppty insertion
                if(Trigger.isInsert){
                    if(oppty.Type == RENEWAL_OPPTY && Oppty.isWon == FALSE && oppty.Prior_Opportunity__c != null && Oppty.GHOST__c == FALSE){
                        //Populating set of Prior Opporutnity Ids of Renewal Opportunities bing inserted
                        setPriorOpptysOfRenewals.add(oppty.Prior_Opportunity__c);
                    }//End of IF
                }//If isInsert
                
            }//End of FOR
            
            System.debug('@@@@@@@@@ CurrentOpptyId: '+CurrentOpptyId);
            System.debug('######### PriorOpptyIds: '+PriorOpptyIds);
            
            //This IF loop will be executed when the upsell gets closed won
            if(triggerEvent != null && triggerEvent == 'AFTER UPDATE'){
      
            /**********************************************************************************************
      Last Modified By: Jade Global Inc On 19th May 2018
      Updated for: As part of Churn Winback Automation,added Churn Winback condition to avoid overriding of Adjusted POR for Churn Winback Opportunity.Modified SOQL - Renewal_Type__c!='Churn Win-Back'
      **********************************************************************************************/
                if(!PriorOpptyIds.isEmpty() && !CurrentOpptyId.isEmpty()){
                    listRelevantOpptys = [SELECT id, AccountId,Sub_End_Date__c, Prior_Opportunity__r.Sub_End_Date__c, SBQQ__PrimaryQuote__c, SBQQ__PrimaryQuote__r.MDQ_Quote__c, StageName, isWon, Type, Opportunity_ARR2012__c,Prior_Opportunity__c,Adjusted_POR__c,SBQQ__PrimaryQuote__r.SBQQ__EndDate__c,Prior_Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__EndDate__c,Prior_Opportunity__r.SBQQ__PrimaryQuote__r.MKTO_Effective_End_Date__c,CurrencyIsoCode,CloseDate,(SELECT id,Quote_Line_End_Date__c,MKTO_Net_Total__c,Total_ARR__c,Total_ARR_for_RUSF__c,OpportunityId,SBQQ__QuoteLine__r.MKTO_Net_Total__c,SBQQ__QuoteLine__r.MKTO_Effective_Term__c,SBQQ__QuoteLine__r.SBQQ__Bundle__c,Quantity_from_Quote_Line__c FROM OpportunityLineItems WHERE PricebookEntry.Product2.Product_Type__c='Subscription') FROM Opportunity WHERE ((ID IN: CurrentOpptyId OR (Prior_Opportunity__c IN: PriorOpptyIds AND ((Type =: RENEWAL_OPPTY AND Renewal_Type__c!='Churn Win-Back' AND (IsWon = TRUE OR IsClosed = FALSE)) OR (Type =: NEW_BUSS_OPPTY AND isWon = TRUE)))) OR ID IN: setPriorOpptysOfRenewals) AND Ghost__c = FALSE];
                    
                    if(!listRelevantOpptys.isEmpty()){
                        for(Opportunity Opptys : listRelevantOpptys){
                            
                            //To populate the map of Opportunities with their respective OLIs
                            if(Opptys.OpportunityLineItems != null && Opptys.isWon == TRUE){
                                list<OpportunityLineItem> lstOpptyLines = Opptys.OpportunityLineItems;
                                if(!lstOpptyLines.isEmpty()){
                                    for(OpportunityLineItem oli: lstOpptyLines){
                                        if(!MapOpptyAndOpptyLines.ContainsKey(oli.OpportunityId)){
                                            MapOpptyAndOpptyLines.put(oli.OpportunityId,new list<OpportunityLineItem>{oli});
                                        }//End of IF
                                        else{
                                            MapOpptyAndOpptyLines.get(oli.OpportunityId).add(oli);
                                        }//End of ELSE
                                    }//End of FOR
                                }//End of IF
                            }//End of IF
                            
                            //Populating map of Prior Oppty Id and Renewal Oppty
                            if(Opptys.OpportunityLineItems != null && Opptys.Type == RENEWAL_OPPTY && Opptys.Prior_Opportunity__c != null){
                                if(!MapOpptyAndRenewalOppty.containsKey(Opptys.id)){
                                    MapOpptyAndRenewalOppty.put(Opptys.Prior_Opportunity__c,Opptys);
                                }//End of IF
                            }//End of IF
                            
                            //Populating map of PriorOpportunityid with its Primary Quote End date
                            
              //********Changed by Jade on 9th Feb 2017
                            //********This is to fix the APOR --> if the Primary Quote Lookup is Blank on prior Opportunity, still this logic should work.
                            
                            /*if(Opptys.Prior_Opportunity__r.SBQQ__PrimaryQuote__c != null && Opptys.Prior_Opportunity__r.SBQQ__PrimaryQuote__r.MKTO_Effective_End_Date__c != null)*/
                            
              If(Opptys.Prior_Opportunity__r.Sub_End_Date__c != null){
                                //MapOpptyIdAndOpportunity.put(Opptys.Prior_Opportunity__c,Opptys.Prior_Opportunity__r.SBQQ__PrimaryQuote__r.MKTO_Effective_End_Date__c);
                MapOpptyIdAndOpportunity.put(Opptys.Prior_Opportunity__c,Opptys.Prior_Opportunity__r.Sub_End_Date__c);
                            }//End of IF
                            
                        }//End of FOR
                        
                        System.debug('^^^^^^^^^^ MapOpptyAndOpptyLines ^^^^^^^^^^ : '+MapOpptyAndOpptyLines);
                        System.debug('%%%%%%%%%% MapOpptyAndRenewalOppty %%%%%%%%%% : '+MapOpptyAndRenewalOppty);
                        System.debug('@@@@@@@@@@ MapOpptyIdAndOpportunity @@@@@@@@@ : '+MapOpptyIdAndOpportunity);
                        
                    }//End of IF
                }//End of IF
                
                if(!MapOpptyAndOpptyLines.isEmpty() && !MapOpptyAndRenewalOppty.isEmpty() && !MapOpptyIdAndOpportunity.isEmpty()){
                    System.debug('!@@!@!@!@!@!@ Inside IF !@!@!@@@!!!!@!@');
                    for(Opportunity o : newOppList){
                        
                        Opportunity RelatedRNWLOppty = MapOpptyAndRenewalOppty.get(o.Prior_Opportunity__c);
                        if(o.Type == UPSELL_CROSSELL_OPPTY && MapOpptyAndOpptyLines.ContainsKey(o.id) && MapOpptyAndRenewalOppty.ContainsKey(o.Prior_Opportunity__c) && MapOpptyIdAndOpportunity.ContainsKey(o.Prior_Opportunity__c) && o.CurrencyIsoCode!=RelatedRNWLOppty.CurrencyIsoCode){
                            list<OpportunityLineItem> RelatedOLIs = MapOpptyAndOpptyLines.get(o.id);
                            Date RelatedEndDate = MapOpptyIdAndOpportunity.get(o.Prior_Opportunity__c);
                           // Opportunity RelatedRNWLOppty = MapOpptyAndRenewalOppty.get(o.Prior_Opportunity__c);
              
                            if(RelatedRNWLOppty.Adjusted_POR__c == null){
                                RelatedRNWLOppty.Adjusted_POR__c = 0;
                            }
                            
                            System.Debug('@#@#@#@ RelatedOLIs: '+RelatedOLIs);
                            System.Debug('*&*&*&*& RelatedEndDate: '+RelatedEndDate);
                            System.Debug('!@!@!@!@!@! RelatedRNWLOppty: '+RelatedRNWLOppty);
                            
                            
                            if(!RelatedOLIs.isEmpty() && RelatedEndDate != null && RelatedRNWLOppty != null){
                                for(OpportunityLineItem oli : RelatedOLIs ){
                                  Double APORValue = oli.Total_ARR_for_RUSF__c;
                                  Double APORConvertedIntoRenewalOpp = oli.Total_ARR_for_RUSF__c;
                                     if(CurrConvsMap.containsKey(o.CurrencyIsoCode)){
                                        for(DatedConversionRate dateRate :CurrConvsMap.get(o.CurrencyIsoCode)){
                                            if(dateRate.startdate  <= o.CloseDate && (daterate.NextStartDate == null || daterate.NextStartDate > o.CloseDate)){
                                                if(dateRate.ConversionRate != 0) {
                                                    APORValue = oli.Total_ARR_for_RUSF__c/dateRate.ConversionRate;
                                                    system.debug('*****APORValue****'+APORValue);
                                                }   
                                            }//END OF IF CONDITION
                                        }//End of FOR loop of DatedConversionRate
                                    }//End of IF loop
                                    
                                     if(CurrConvsMap.containsKey(RelatedRNWLOppty.CurrencyIsoCode)){
                                        for(DatedConversionRate dateRate :CurrConvsMap.get(RelatedRNWLOppty.CurrencyIsoCode)){
                                            if(dateRate.startdate  <= RelatedRNWLOppty.CloseDate && (daterate.NextStartDate == null || daterate.NextStartDate >RelatedRNWLOppty.CloseDate)){
                                                if(dateRate.ConversionRate != 0) {
                                                    APORConvertedIntoRenewalOpp = APORValue * dateRate.ConversionRate;
                                                    system.debug('*****APORConvertedIntoRenewalOpp****'+APORConvertedIntoRenewalOpp);
                                                }   
                                            }//END OF IF CONDITION
                                        }//End of FOR loop of DatedConversionRate
                                    }//End of IF loop
                                    
                                    //if(oli.Quote_Line_End_Date__c == RelatedEndDate){
                                       // RelatedRNWLOppty.Adjusted_POR__c = RelatedRNWLOppty.Adjusted_POR__c + oli.Total_ARR_for_RUSF__c; 
                                        RelatedRNWLOppty.Adjusted_POR__c = RelatedRNWLOppty.Adjusted_POR__c + APORConvertedIntoRenewalOpp; 
                                         system.debug('*****RelatedRNWLOppty.Adjusted_POR__c ****'+RelatedRNWLOppty.Adjusted_POR__c );
                                    //}//End Of IF
                                }//End of FOR
                                ListOfRenewalsTobeUpdated.add(RelatedRNWLOppty);
                            }//End of IF
                        }//End of IF
                    }//End of FOR
                }//End of IF    
            }//End of AFTER UPDATE loop
            
            //This IF loop will be executed on Renewal Opportunity creation
            if(triggerEvent != null && triggerEvent == 'BEFORE INSERT'){
                if(!setPriorOpptysOfRenewals.isEmpty()){
        
        /*****************************************************************************************
        Last Modified By: Jade Global Inc On 19th May 2018
        Updated for: As part of Churn Winback Automation,added Churn Winback condition to avoid overriding of Adjusted POR for Churn Winback Opportunity.Modified SOQL - Renewal_Type__c!='Churn Win-Back'
        ******************************************************************************************/
                
        listRelevantOpptys = [SELECT id,CurrencyIsoCode,AccountId,Account.CurrencyIsoCode,Sub_End_Date__c, Prior_Opportunity__r.Sub_End_Date__c, SBQQ__PrimaryQuote__c,Exchange_Rate__c, SBQQ__PrimaryQuote__r.MDQ_Quote__c, StageName, isWon, Type, convertCurrency(Opportunity_ARR2012__c),Prior_Opportunity__c,Prior_Opportunity__r.CurrencyIsoCode,Prior_Opportunity__r.Account.CurrencyIsoCode,Adjusted_POR__c,SBQQ__PrimaryQuote__r.SBQQ__EndDate__c,Prior_Opportunity__r.SBQQ__PrimaryQuote__r.SBQQ__EndDate__c,Prior_Opportunity__r.SBQQ__PrimaryQuote__r.MKTO_Effective_End_Date__c,Prior_Opportunity__r.Exchange_Rate__c,Renewal_Type__c,(SELECT id,Quote_Line_End_Date__c,MKTO_Net_Total__c,Total_ARR__c,Total_ARR_for_RUSF__c,OpportunityId,SBQQ__QuoteLine__r.MKTO_Net_Total__c,SBQQ__QuoteLine__r.MKTO_Effective_Term__c,SBQQ__QuoteLine__r.SBQQ__Bundle__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Rubiks_Quote__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.MKTO_Effective_End_Date__c FROM OpportunityLineItems WHERE PricebookEntry.Product2.Product_Type__c='Subscription') FROM Opportunity WHERE ((ID IN: CurrentOpptyId OR (Prior_Opportunity__c IN: PriorOpptyIds AND ((Type =: RENEWAL_OPPTY AND Renewal_Type__c!='Churn Win-Back')  OR Type =: NEW_BUSS_OPPTY))) OR ID IN: setPriorOpptysOfRenewals) AND isWon = TRUE AND Ghost__c = FALSE];

                    
                    map<id,Opportunity> mapPriorOpptyIdANDOppty = new Map<id,Opportunity>();
                    
                    if(!listRelevantOpptys.isEmpty()){
                        for(Opportunity opppp : listRelevantOpptys){
                            if(!mapPriorOpptyIdANDOppty.ContainsKey(opppp.id)){
                                mapPriorOpptyIdANDOppty.put(opppp.id,opppp);
                            }//End of IF
                        }//End of FOR   
                    }//End of IF
                    
                    if(!mapPriorOpptyIdANDOppty.isEmpty()){
                        for(Opportunity opty : newOppList){
                            
                            if(opty.Adjusted_POR__c == null){
                                opty.Adjusted_POR__c = 0;
                            }
                        
                            if(mapPriorOpptyIdANDOppty.containsKey(opty.Prior_Opportunity__c)){
                                Opportunity RelatedPriorOppty = mapPriorOpptyIdANDOppty.get(opty.Prior_Opportunity__c);
                                
                                Date RelatedEndDate;                                 
                                if(RelatedPriorOppty != null){
                                    RelatedEndDate = RelatedPriorOppty.Sub_End_Date__c;
                                    list<OpportunityLineItem> lstPriorOLIs = RelatedPriorOppty.OpportunityLineItems;
                                    if(!lstPriorOLIs.isEmpty()){
                                        for(OpportunityLineItem oli : lstPriorOLIs){
                      
                      //Modified by Jade Global on 15th March 2017
                      //Added below IF and ELSE loop to check if the OLIs Quote is Feature or Rubiks
                      //Modified for APPS-12023
                      if(oli.SBQQ__QuoteLine__r.SBQQ__Quote__r.Rubiks_Quote__c){
                        /* **********************************************************************************************************
                            Last Modified By: Jade Global Inc, on 19th April 2018. JIRA: APPS-18492
                            Purpose         : Added OR Condition for populating Adjusted POR - as If OLI-> Quote -> MKTO Effective End Date != opportunity -> Master Sub End Date then run logic for populating Adjusted POR of future Renewal
                        ************************************************************************************************************ */
                        if((oli.Quote_Line_End_Date__c == RelatedEndDate || oli.SBQQ__QuoteLine__r.SBQQ__Quote__r.MKTO_Effective_End_Date__c != RelatedEndDate) && oli.SBQQ__QuoteLine__r.MKTO_Net_Total__c != null && oli.SBQQ__QuoteLine__r.MKTO_Effective_Term__c!= 0 && oli.SBQQ__QuoteLine__r.MKTO_Effective_Term__c!= null && !oli.SBQQ__QuoteLine__r.SBQQ__Bundle__c){
                          opty.Adjusted_POR__c = opty.Adjusted_POR__c + ((
                          oli.SBQQ__QuoteLine__r.MKTO_Net_Total__c/ oli.SBQQ__QuoteLine__r.MKTO_Effective_Term__c)*12);
                        }//end of if  
                      }//End of IF --> For Solution Quote
                      else{
                        if(oli.Total_ARR_For_RUSF__c != null && oli.Total_ARR_For_RUSF__c != 0){
                          opty.Adjusted_POR__c = opty.Adjusted_POR__c + oli.Total_ARR_For_RUSF__c;
                        }//End of IF
                      }//End of ELSE --> For Feature Quote
                      
                                        }//End of FOR
                                    }//End of IF
                                }//End of IF
                            }//End of IF
                        }//End of FOR
                    }//End of IF
                    
                }//End of IF
            }//End of BEFORE INSERT event
    
        }//End of IF

        System.debug('*&*&*&*&*^%^%^ ListOfRenewalsTobeUpdated: '+ListOfRenewalsTobeUpdated);
        //Returning the Renewal Opportunity list with the Calculated APOR values
        return ListOfRenewalsTobeUpdated;
    }//End of Method OpportunityAPORCalcRevisited()
  
      public static void TestOppty(){
    
         list<Account> accntList = TestCPQUtilityClass.createAccounts(1);
      Opportunity testOpptyNew = new  Opportunity();
      Opportunity testOpptyNew1 = new  Opportunity();
            System.debug('########## accntList: '+accntList);
            accntList[0].name = 'test acc';
            if(!accntList.isEmpty()){
                accntList[0].name = 'test acc1';
            }//End of IF
         List<Opportunity> oppotyList       = TestCPQUtilityClass.createOpportunities(accntList, 3);
            oppotyList[0].StageName            = 'Not Contacted';
           
            oppotyList[0].Quarterly_Renewal__c = string.valueof(2);
            oppotyList[0].Sub_End_Date__c      = System.Today().addMonths(1);
            oppotyList[0].type                 = 'Renewal';
            oppotyList[0].Prior_Opportunity__c = null;
            oppotyList[0].Deal_Type__c         = 'Standard';
            oppotyList[0].CurrencyIsoCode      = 'EUR';
         
      
      
            
      
            List<Opportunity> RNoppotyList   =  new list<Opportunity>();
        List<Opportunity> RNoppotyList1   =  new list<Opportunity>();
        List<Opportunity> RNoppotyList2   =  new list<Opportunity>();  
        List<Opportunity> RNoppotyList3   =  new list<Opportunity>();
            List<SBQQ__Quote__c> newquoteList = TestCPQUtilityClass.createQuotes(oppotyList,  1);
            for(SBQQ__Quote__c q: newquoteList){
                q.SBQQ__Primary__c=true;
                q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
                q.SBQQ__StartDate__c =system.today()+40;
                q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
                q.SBQQ__SubscriptionTerm__c=12;
            }
          
             List<Opportunity> RNoppotyList5   =  new list<Opportunity>();
        List<Opportunity> RNoppotyList11   =  new list<Opportunity>();
        List<Opportunity> RNoppotyList22   =  new list<Opportunity>();  
        List<Opportunity> RNoppotyList33   =  new list<Opportunity>();
      
      List<OpportunityLineItem> RNoppotyOLIList2   =  new list<OpportunityLineItem>();  
        List<OpportunityLineItem> RNoppotyOLIList4   =  new list<OpportunityLineItem>();
       List<OpportunityLineItem> RNoppotyOLIList5   =  new list<OpportunityLineItem>();  
        List<OpportunityLineItem> RNoppotyOLIList6  =  new list<OpportunityLineItem>();
        List<SBQQ__Quote__c> newquoteRNList = TestCPQUtilityClass.createQuotes(oppotyList,  1);
            for(SBQQ__Quote__c q: newquoteRNList){
                q.SBQQ__Primary__c=true;
                q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
                q.SBQQ__StartDate__c =system.today()+40;
                q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
                q.SBQQ__SubscriptionTerm__c=12;
            }
      
        List<SBQQ__Quote__c> newquoteRNUpsellList = TestCPQUtilityClass.createQuotes(oppotyList,  1);
            for(SBQQ__Quote__c q: newquoteRNUpsellList){
                q.SBQQ__Primary__c=true;
                q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
                q.SBQQ__StartDate__c =system.today()+40;
                q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
                q.SBQQ__SubscriptionTerm__c=12;
        break;
            }
      
       List<SBQQ__Quote__c> newquoteRNUpsellRNList = TestCPQUtilityClass.createQuotes(oppotyList,  1);
            for(SBQQ__Quote__c q: newquoteRNUpsellRNList){
                q.SBQQ__Primary__c=true;
                q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
                q.SBQQ__StartDate__c =system.today()+40;
                q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
                q.SBQQ__SubscriptionTerm__c=12;
        break;
            }
       List<SBQQ__Quote__c> newquoteRNUpsellRNLNBist = TestCPQUtilityClass.createQuotes(oppotyList,  1);
            for(SBQQ__Quote__c q: newquoteRNUpsellRNLNBist){
                q.SBQQ__Primary__c=true;
                q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
                q.SBQQ__StartDate__c =system.today()+40;
                q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
                q.SBQQ__SubscriptionTerm__c=12;
        break;
            }
       List<SBQQ__Quote__c> newquoteAmendList = TestCPQUtilityClass.createQuotes(oppotyList,  1);
            for(SBQQ__Quote__c q: newquoteAmendList){
                q.SBQQ__Primary__c=true;
                q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
                q.SBQQ__StartDate__c =system.today()+40;
                q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
                q.SBQQ__SubscriptionTerm__c=12;
        break;
            }
       List<SBQQ__Quote__c> newquoteAmendUPList = TestCPQUtilityClass.createQuotes(oppotyList,  1);
            for(SBQQ__Quote__c q: newquoteAmendUPList){
                q.SBQQ__Primary__c=true;
                q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
                q.SBQQ__StartDate__c =system.today()+40;
                q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
                q.SBQQ__SubscriptionTerm__c=12;
        break;
            }
       List<SBQQ__Quote__c> newquoteAmendUPList2 = TestCPQUtilityClass.createQuotes(oppotyList,  1);
            for(SBQQ__Quote__c q: newquoteAmendUPList2){
                q.SBQQ__Primary__c=true;
                q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
                q.SBQQ__StartDate__c =system.today()+40;
                q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
                q.SBQQ__SubscriptionTerm__c=12;
        break;
            }
       List<SBQQ__Quote__c> newquoteAmendUPList3 = TestCPQUtilityClass.createQuotes(oppotyList,  1);
            for(SBQQ__Quote__c q: newquoteAmendUPList3){
                q.SBQQ__Primary__c=true;
                q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
                q.SBQQ__StartDate__c =system.today()+40;
                q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
                q.SBQQ__SubscriptionTerm__c=12;
        break;
            }
       List<SBQQ__Quote__c> newquoteAmendUPList4 = TestCPQUtilityClass.createQuotes(oppotyList,  1);
            for(SBQQ__Quote__c q: newquoteAmendUPList4){
                q.SBQQ__Primary__c=true;
                q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
                q.SBQQ__StartDate__c =system.today()+40;
                q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
                q.SBQQ__SubscriptionTerm__c=12;
        break;
            }
      for(SBQQ__Quote__c q: newquoteAmendUPList4){
                q.SBQQ__Primary__c=true;
                q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
                q.SBQQ__StartDate__c =system.today()+40;
                q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
                q.SBQQ__SubscriptionTerm__c=12;
        break;
            }
      for(SBQQ__Quote__c q: newquoteAmendUPList4){
                q.SBQQ__Primary__c=true;
                q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
                q.SBQQ__StartDate__c =system.today()+40;
                q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
                q.SBQQ__SubscriptionTerm__c=12;
        break;
            }
      for(SBQQ__Quote__c q: newquoteAmendUPList4){
                q.SBQQ__Primary__c=true;
                q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
                q.SBQQ__StartDate__c =system.today()+40;
                q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
                q.SBQQ__SubscriptionTerm__c=12;
        break;
            }
      for(SBQQ__Quote__c q: newquoteAmendUPList4){
                q.SBQQ__Primary__c=true;
                q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
                q.SBQQ__StartDate__c =system.today()+40;
                q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
                q.SBQQ__SubscriptionTerm__c=12;
        break;
            }
      for(SBQQ__Quote__c q: newquoteAmendUPList4){
                q.SBQQ__Primary__c=true;
                q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
                q.SBQQ__StartDate__c =system.today()+40;
                q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
                q.SBQQ__SubscriptionTerm__c=12;
        break;
            }
      for(SBQQ__Quote__c q: newquoteAmendUPList4){
                q.SBQQ__Primary__c=true;
                q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
                q.SBQQ__StartDate__c =system.today()+40;
                q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
                q.SBQQ__SubscriptionTerm__c=12;
        break;
            }for(SBQQ__Quote__c q: newquoteAmendUPList4){
                q.SBQQ__Primary__c=true;
                q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
                q.SBQQ__StartDate__c =system.today()+40;
                q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
                q.SBQQ__SubscriptionTerm__c=12;
        break;
            }for(SBQQ__Quote__c q: newquoteAmendUPList4){
                q.SBQQ__Primary__c=true;
                q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
                q.SBQQ__StartDate__c =system.today()+40;
                q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
                q.SBQQ__SubscriptionTerm__c=12;
        break;
            }
      for(SBQQ__Quote__c q: newquoteAmendUPList4){
                q.SBQQ__Primary__c=true;
                q.New_Logo_Term_Promotions__c='3+9: 90-day early termination';
                q.SBQQ__StartDate__c =system.today()+40;
                q.SBQQ__PaymentTerms__c='Payment Due on Receipt of Invoice';
                q.SBQQ__SubscriptionTerm__c=12;
        break;
            }
    }//End of methodTestOppty
    
    /****************************************************************
    Method: updateSDRPicklistOnOpportunity()
    Added by: Jade Global Inc.
    Date: 25th May 2017
    
    Events: BEFORE INSERT , BEFORE UPDATE
        
        This method will update the SDR_Owner__c field from SDR_Owner_Lookup__c on Opportunity on BEFORE INSERT and BEFORE UPDATE event(iff the SDR_Owner_Lookup__c value is changed).
    ****************************************************************/
    
    public static void updateSDRPicklistOnOpportunity(list<Opportunity> newOppList, Map<id,Opportunity> OldMap){
        set<id> SDROwnerIds = new set<id>();
        
        if(!newOppList.isEmpty()){
            for(Opportunity op : newOppList){
                if(Trigger.isInsert){
                    if(op.SDR_Owner_Lookup__c != null){
                        SDROwnerIds.add(op.SDR_Owner_Lookup__c);
                    }//End of IF
                }//End of isInsert
                
                if(Trigger.isUpdate){
                    if(op.SDR_Owner_Lookup__c != null && op.SDR_Owner_Lookup__c != OldMap.get(op.id).SDR_Owner_Lookup__c){
                        SDROwnerIds.add(op.SDR_Owner_Lookup__c);
                    }
                }//End of isUpdate
            }//End of FOR
            
            if(!SDROwnerIds.isEmpty()){
                map<id,User> MapSDROwnerIdAndName = new map<id,User>([SELECT id,Name FROM USER WHERE ID IN:SDROwnerIds]);
            
                if(!MapSDROwnerIdAndName.isEmpty()){
                    for(Opportunity opp: newOppList){
                        if(opp.SDR_Owner_Lookup__c != null && MapSDROwnerIdAndName.containsKey(opp.SDR_Owner_Lookup__c)){
                            opp.SDR_Owner__c = MapSDROwnerIdAndName.get(opp.SDR_Owner_Lookup__c).Name;
                        }//End of IF
                    }//End of FOR
                }//End of IF
            }//End of IF
        }//End of IF
    }//End of Method updateSDRPicklistOnOpportunity()
    
    
   /****************************************************************
    Method: convertAPOROntoChangedCurrency()
    Added by: Jade Global Inc.
    Date:  23rd May 2018
    Events:  BEFORE UPDATE
    Ticket No. :  APPS-9339 and APPS-17240 
    This method will be called on BEFORE UPDATE event on Opportunity.
    This is a newly designed method for APOR calculation on Opportunity when opportunity currency is changed.
    ****************************************************************/    
   public static void convertAPOROntoChangedCurrency(list<Opportunity> newOppList,map<id,Opportunity> OldMap,String triggerEvent){
    Map<String,List<DatedConversionRate>> CurrConvsMap  = getStandardExchangeRatesMap();
    for(Opportunity opp : newOppList){
            if(Trigger.isUpdate){
                String OldOppty = oldMap.get(opp.Id).CurrencyIsoCode;
                if(opp.CurrencyIsoCode != OldOppty && opp.Adjusted_POR__c!= null){
                    if(CurrConvsMap.containsKey(OldOppty)){
                        decimal APORValueInUSD = opp.Adjusted_POR__c;
                        decimal APORValueInCurrentCurrency = opp.Adjusted_POR__c;
                        for(DatedConversionRate dateRate :CurrConvsMap.get(OldOppty)){
                            if(dateRate.startdate  <= opp.CloseDate && (daterate.NextStartDate == null || daterate.NextStartDate > opp.CloseDate)){
                                if(dateRate.ConversionRate != 0) {
                                    APORValueInUSD = opp.Adjusted_POR__c/dateRate.ConversionRate;
                                    system.debug('*****APORValueInUSD****'+APORValueInUSD);
                                }//end of if
                            }//end of if
                        }//end of for
                        for(DatedConversionRate dateRate :CurrConvsMap.get(opp.CurrencyIsoCode)){
                            if(dateRate.startdate  <= opp.CloseDate && (daterate.NextStartDate == null || daterate.NextStartDate > opp.CloseDate)){
                                if(dateRate.ConversionRate != 0) {
                                    APORValueInCurrentCurrency = APORValueInUSD * dateRate.ConversionRate;
                                    opp.Adjusted_POR__c = APORValueInCurrentCurrency;
                                    system.debug('*****APORValueInCurrentCurrency****'+APORValueInCurrentCurrency);
                                    system.debug('*****Adjusted_POR__c****'+opp.Adjusted_POR__c );
                                }//end of if
                            }//end of if
                        }//end of for
                    }//end of if
                }//end of if
            }//end of update if
        }//end of for
    }//end of method convertAPOROntoChangedCurrency() 
    /****************************************************************
    Method: sendSurveyInviteForRenewal()
    Added by: Grazitti Support Team
    Date:  12th June 2018
    Events:  After Update
    Ticket No. : SISR-01006108
    Description : Below method sends Qualtrics survey invites when the Renewal opportunity get closed won and the account CSM group value is between Segment 2 or Segment 3.
                  There are two recipents which are going to recieve these survey emails. Primary contact present on primary quote and Contact present on CSM history object under the same account.
    ****************************************************************/    
    public static void sendSurveyInviteForRenewal(list<Opportunity> newOppList,map<id,Opportunity> OldMap){
        try{
            Map<Id,Id> oppAccMap = new Map<Id,Id>();
            Map<Id,String> contMap= new Map<Id,String>();
            for(Opportunity opp : newOppList){
                if(opp.AccountId != null && opp.type == 'Renewal' && opp.Ghost__c == False && OldMap.get(opp.Id).stagename != CLOSED_WON_OPPTY && opp.stagename == CLOSED_WON_OPPTY) oppAccMap.put(opp.AccountId,opp.Id);
            }//end of for
            if(oppAccMap.isEmpty() == False){
                Set<String> camGroups = new Set<String>(Label.CAM_Group.split(';'));
                for(Account acc : [Select id,CAM_Group__c ,(Select id,Contact__c,Contact__r.Preferred_Language__c,Contact__r.email from Customer_Account_Management_Histories__r order by createddate desc limit 1),(Select id,Primary_Marketo_User_Lookup__c,Primary_Marketo_User_Lookup__r.email,Primary_Marketo_User_Lookup__r.Preferred_Language__c from Opportunities where Id In:oppAccMap.Values()) from Account where id in:oppAccMap.keySet() and CAM_Group__c IN:camGroups]){
                    for(Customer_Account_Management_History__c cam: acc.Customer_Account_Management_Histories__r){
                        if(cam.Contact__c != null && cam.Contact__r.Preferred_Language__c == 'English' && !cam.Contact__r.email.Contains('@marketo.com')) contMap.put(cam.Contact__c,acc.CAM_Group__c);
                    }//end of for
                    for(Opportunity opp: acc.Opportunities){
                        if(opp.Primary_Marketo_User_Lookup__c != null && opp.Primary_Marketo_User_Lookup__r.Preferred_Language__c == 'English' && !opp.Primary_Marketo_User_Lookup__r.email.Contains('@marketo.com')) contMap.put(opp.Primary_Marketo_User_Lookup__c,acc.CAM_Group__c);
                    }//end of for
                }//end of for
            }//end of if
            if(!contMap.isEmpty()){
                List<Messaging.SingleEmailMessage> allmsg = new List<Messaging.SingleEmailMessage>();  
                for(Id contId : contMap.keySet()){
                    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                    mail.setTargetObjectId(contId); 
                    if(contMap.get(contId) == 'Segment 1') mail.setTemplateID(Label.RenewalCoordinatorSurveyTemplate); 
                    if(contMap.get(contId) == 'Segment 2' || contMap.get(contId) == 'Segment 3') mail.setTemplateID(Label.CSMRenawalSurveyTemplate); 
                    if(contMap.get(contId) == 'Segment 4' || contMap.get(contId) == 'Segment 5') mail.setTemplateID(Label.SalesRenewalSurveyTemplate); 
                    mail.setSaveAsActivity(false);
                    mail.setOrgWideEmailAddressId(Label.Customer_Success_Manager_Orgwide_Id);
                    mail.setWhatId(contId);
                    allmsg.add(mail);   
                }//end of for
                if(!allmsg.isEmpty()) Messaging.sendEmail(allmsg,false);//sending email
            }//end of if
        }//END OF TRY BLOCK
        catch(Exception e){
            System.Debug('----- GOT AN EXCEPTION -----'+e.getMessage());
        }//END OF CATCH BLOCK
    }
     
     /****************************************************************
    * Last Modified By   : Jade Global Inc.
    * Last Modified Date : 8th September 2018
    * Reason             : Moved code from BOFU Page
    * Changes            : 1. Populate Data Center field - check the Primary Quote - Country and accordingly populate the Data *                         Center field on signed order based on the Data Center custom setting values.
    *                      2. Populating the Provisioning_Type__c on Renewal opportunity based on current and previous quote.
    *                      3. Populating Account_String__c on Upsell opportunity from primary asset present on Master Contract *                         present on Quote
    *                      4. Populating Account_String__c on RenewalOpportunity opportunity from primary asset present on Master  *                         Contract on Quote
    ****************************************************************/
    public static void OpportunityBOFUPagePopulation(list<Opportunity> newOppList,map<Id,SBQQ__Quote__c> SBQuoteMap){
    
        set<Id> OppIDSet = new set<Id>();
        Set<Id> PriorOpptyId = new Set<Id>();
        set<String> QuoteShippingCountrySet = new Set<String>();
        Map<Id,SBQQ__Quote__c> MapofOpptyWithQuote = new Map<Id,SBQQ__Quote__c>();
        Map<String,string> dataCenterMap =   new Map<String,string>();
        Map<Id,Contract> PriorOptyWithContract = new Map<Id,Contract>();
        Map<Id,Asset> PriorOptyWithAsset =  new Map<Id,Asset>();
        integer GroupLineItems;

        if(!newOppList.isEmpty()){ 
            for(Opportunity opp: newOppList){
                OppIDSet.add(opp.Id);
                if(opp.Prior_Opportunity__c !=null ){
                PriorOpptyId.add(opp.Prior_Opportunity__c);
                }
            }//end of For
        }//End of If
        if(!SBQuoteMap.isEmpty()){
            for(Id QuoteObj : SBQuoteMap.keySet()){
                QuoteShippingCountrySet.add(SBQuoteMap.get(QuoteObj).SBQQ__ShippingCountry__c);
            }
            system.debug('QuoteShippingCountrySet'+QuoteShippingCountrySet);
        }

        /****************************************************************
        * Last Modified By   :  Ashwini Desai, Jade Global
        * Last Modified Date : 25th July 2018
        * Reason             : Moved code from BOFU Page
        * Changes            : 1. Populate Data Center field - check the Primary Quote - Country and accordingly populate the Data Center field on signed order based on the Data Center custom setting values.
        * 
        * ***************************************************************/
        //country and its datacenter map  from custom setting  
        //list<Country__c> CountryList = [SELECT Data_Center__c,Id,Name FROM Country__c Where Name In: QuoteShippingCountrySet];
        for(Country__c Country : [SELECT Data_Center__c,Id,Name FROM Country__c Where Name In: QuoteShippingCountrySet]){
            dataCenterMap.put(Country.Name, Country.Data_Center__c);
        }
        system.debug('dataCenterMap'+dataCenterMap);
        if(!newOppList.isEmpty()){
            for(Opportunity opp: newOppList){
                if(SBQuoteMap.containsKey(opp.SBQQ__PrimaryQuote__c)){
                    SBQQ__Quote__c PrimaryQuote = SBQuoteMap.get(opp.SBQQ__PrimaryQuote__c);
                     GroupLineItems = PrimaryQuote.SBQQ__LineItemGroups__r.size();
                    if(PrimaryQuote.SBQQ__Opportunity2__c == opp.Id && (PrimaryQuote.Rubiks_Quote__c == true || PrimaryQuote.SBQQ__LineItemsGrouped__c == true) && PrimaryQuote.SBQQ__Primary__c == true && PrimaryQuote.SBQQ__ShippingCountry__c != null && dataCenterMap.containsKey(primaryQuote.SBQQ__ShippingCountry__c) && (opp.StageName == SIGNED_ORDER_OPPTY || opp.StageName == SIGNED_ORDER_6_OPPTY)&& (PrimaryQuote.Instance_Rollup__c <= 1 || GroupLineItems == 1)){
                        if( opp.type == Label.OPPORTUNITY_TYPE_NEW_BUSINESS){
                            opp.Data_Center__c = dataCenterMap.get(primaryQuote.SBQQ__ShippingCountry__c);
                        }
                        MapofOpptyWithQuote.put(primaryQuote.SBQQ__Opportunity2__c,primaryQuote);
                        system.debug('*****MapofOpptyWithQuote ****'+MapofOpptyWithQuote);
                    }
                }//End of the IF
            }//End of the For
        }//End of the IF

        /****************************************************************
        * Last Modified By   :  Ashwini Desai, Jade Global.
        * Last Modified Date : 25th July 2018
        * Changes            : 1.Populating the Provisioning_Type__c on Renewal opportunity based on current and previous quote.
        *                      2.Populating Account_String__c on Upsell opportunity from primary asset present on Master Contract presnt *                        on Quote
        *                      3.Populating Account_String__c on RenewalOpportunity opportunity from primary asset present on Master *                        Contract on Quote
        * 
        * 
        * 
        * ***************************************************************/

        for(Contract  cont: [SELECT id,SBQQ__Opportunity__c,SBQQ__Opportunity__r.type,SBQQ__Quote__c,SBQQ__Quote__r.Rubiks_Quote__c,SBQQ__Quote__r.MDQ_Quote__c,Primary_Asset__r.Acct_Prefix__c,SBQQ__Quote__r.Instance_Rollup__c ,Primary_Asset__c,SBQQ__Quote__r.SBQQ__LineItemsGrouped__c/*,// Commented as per the ticket  APPS-20840 (SELECT id,Production_Asset__c,Acct_Prefix__c,SBQQ__QuoteLine__r.SBQQ__Quote__r.Rubiks_Quote__c , SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c FROM Assets__r WHERE Acct_Prefix__c!=null AND (SBQQ__QuoteLine__r.SBQQ__Quote__r.Rubiks_Quote__c = TRUE OR SBQQ__QuoteLine__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c = TRUE) AND Purpose__c = 'Sandbox')*/ FROM Contract WHERE SBQQ__Opportunity__c=:PriorOpptyId ]){
            IF(cont.SBQQ__Opportunity__c != null){
                PriorOptyWithContract.put(cont.SBQQ__Opportunity__c,cont);
                // Commented as per the ticket  APPS-20840 
                /*IF(!cont.Assets__r.isEmpty()){
                    PriorOptyWithAsset.put(cont.SBQQ__Opportunity__c,cont.Assets__r);
                }*/
            }
        }//End of For

        for(Opportunity opp: newOppList){

            if((opp.type == Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL || opp.type == Label.OPPORTUNITY_TYPE_RENEWAL) &&  (opp.StageName == SIGNED_ORDER_OPPTY || opp.StageName == SIGNED_ORDER_6_OPPTY)){
                if(MapofOpptyWithQuote.ContainsKey(opp.id)){
                SBQQ__Quote__c primaryQuote = MapofOpptyWithQuote.get(opp.id);
                if(primaryQuote.SBQQ__Opportunity2__r.Prior_Opportunity__c!=null && (primaryQuote.SBQQ__Type__c == 'Amendment' || opp.type == Label.OPPORTUNITY_TYPE_RENEWAL)){                  
                        /* ********************************************************************************
                         Modified By:  Jade Global Inc, on 25th July 2018
                         Purpose    : 1. For Upsell Account_String__c population Amendment and MDQ check not required
                                      2. Populate Sandbox Account Prefix For Rubiks 
                                      3. Populate Account prefix on feature and rubiks
                        **********************************************************************************/
                        if(opp.type == Label.OPPORTUNITY_TYPE_RENEWAL && (primaryQuote.Rubiks_Quote__c == TRUE || primaryQuote.SBQQ__LineItemsGrouped__c == TRUE)){
                            if(PriorOptyWithContract.ContainsKey(opp.Prior_Opportunity__c)){
                                Contract  cont = PriorOptyWithContract.get(opp.Prior_Opportunity__c);
                                if(cont.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c == TRUE && primaryQuote.SBQQ__LineItemsGrouped__c == TRUE){
                                    opp.Provisioning_Type__c = 'Phoenix to Phoenix';
                                }else if(cont.SBQQ__Quote__r.Rubiks_Quote__c == TRUE && primaryQuote.SBQQ__LineItemsGrouped__c == TRUE){
                                    opp.Provisioning_Type__c = 'Rubiks to Phoenix';
                                }
                                else if(cont.SBQQ__Quote__r.Rubiks_Quote__c == False && primaryQuote.SBQQ__LineItemsGrouped__c == TRUE){
                                    opp.Provisioning_Type__c = 'Legacy to Phoenix';
                                 }
                                else if(cont.SBQQ__Quote__r.Rubiks_Quote__c == TRUE && primaryQuote.Rubiks_Quote__c == TRUE){
                                    opp.Provisioning_Type__c = 'Rubiks to Rubiks';
                                 }
                                else if(cont.SBQQ__Quote__r.Rubiks_Quote__c == False && primaryQuote.Rubiks_Quote__c == TRUE){
                                    opp.Provisioning_Type__c = 'Legacy to Rubiks';
                                }
                                 
                                if( opp.Account_String__c == null){
                                    opp.Account_String__c = cont.Primary_Asset__r.Acct_Prefix__c!=NULL ? cont.Primary_Asset__r.Acct_Prefix__c:primaryQuote.SBQQ__Opportunity2__r.Account_String__c;
                                }//End of If
                                // Commented as per the ticket  APPS-20840 
                                /*if(PriorOptyWithAsset.ContainsKey(opp.Prior_Opportunity__c)){
                                
                                    //opp.Sandbox_account_prefix__c =  PriorOptyWithAsset.get(opp.Prior_Opportunity__c).Acct_Prefix__c;
                                }//End of IF block*/
                            }//End of IF PriorOptyWithContract
                        }//End of OPPORTUNITY_TYPE_RENEWAL check
                    }//End of If
                    if(opp.type == Label.OPPORTUNITY_TYPE_UPSELL_CROSSELL && opp.Account_String__c ==null && primaryQuote.SBQQ__MasterContract__r.Primary_Asset__r.Acct_Prefix__c != null){
                        opp.Account_String__c =  primaryQuote.SBQQ__MasterContract__r.Primary_Asset__r.Acct_Prefix__c;
                    }//End of If
                }//End of IF block
            }//End of IF block
        }//End of newOppList For
    }//End of Method OpportunityBOFUPagePopulation     
}//END OF CLASS