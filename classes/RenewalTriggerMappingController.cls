/**************************************************************
Updated By : Tushar Misri, Grazitti Interactive
Updated Date : 8th February,2018
Reason : APPS-13970: To Stop Primary_Enablement_Partner__c 
auto population from this trigger.
Code Updated : Line 65, Commented

Last Modified By: Jade Team on 19th April 2018, APPS-18492
Purpose         : Added OR Condition If Prior Opty->Master Sub End Date != Prior Opty->Primary Quote-> MKTO Effective End Date then
                  Opp Plan of Record Renewal Date = Prior Opty->Primary Quote-> MKTO Effective End Date else remaning logic as it is
                  Opp Plan of Record Renewal Date = Master Sub End Date
				  
Last Modified By: Jade Global Inc On 19th May 2018
Updated for: Added as part of Churn Winback Automation, added code to avoid overrinding of Renewal Opportunity field population for Churn winback Opportunity


* Last modified By : Tushar Misri, Grazitti Interactive, 10th Aug 2018
* Purpose          : APPS-20840, Field Cleanup Project - Phase One
                     Fields which are being commented out:
                     billed_services__c,parent_opportunity_quarterly_deals__c,mp_sandbox__c,ease_of_renewal__c,perceived_customer_value__c
                     requestedkickoffdate__c,channel__c,sales_outbound_notes__c,projecttype__c,opportunity_source__c,quote_expiration_date__c,
                     average_monthly_email_volume__c,web_traffic__c,lead_promotion_date__c,service_only__c,sfdc_user__c,project_stage__c
                     product_interest__c,sales_lead_type__c,project_classification__c,project_type__c,project_start_date__c,solutions_consultant_email__c
                     servicesnotes__c,cf_opp_id__c,needs_internal_kickoff_meeting__c,enablement_percent_completed__c,non_standard_payment_terms__c
                     oa_partner_involved__c,employee_range_summary__c,enablement_close_notes__c,enablement_completion_date__c,marketo_subscription_plan__c
                     pod__c,sc_enablement_notes__c,tracking_url__c,sfdc_users__c,project_temperature__c,marketo_login__c,marketo_password__c
                     demo_type__c,marketo_subscription_subplan__c,days_since_lead_promotion__c,days_to_sales_lead__c,pay_referral__c,openair_percent_complete_del__c
                     ,oa_product_purchased_del__c,primary_marketo_user_phone__c,partner_involved_del__c
                     enablement_project_stage__c,services_required__c,original_lead_created_date__c,solutions_consultant_lookup__c,rt__c

**************************************************************/
/* ********************************************************************************************************
* Last Modified By: Jade Global Inc, on 8th September 2018
* Purpose         : To handle Phoenix Provisioning Scenarios
				   - Added Record Type check previously Record Type Was 'Renewal sales' Added check 'Renewal'
********************************************************************************************************* */
public class RenewalTriggerMappingController
{    
	// Added Record Type check previously Record Type Was 'Renewal sales' Added check 'Renewal'
	static Id RenewalSalesId  = Opportunity.sObjectType.getDescribe().getRecordTypeInfosByName().get('Renewal').getRecordTypeId() ;

    public static Opportunity MapFields(Opportunity o)
    {
        Opportunity newOpp = new Opportunity();
        newOpp.AccountId = o.AccountId;   	                 
        newOpp.Description = o.Description;
        newOpp.LeadSource = o.LeadSource;
        newOpp.NextStep = o.NextStep;
        newOpp.CurrencyIsoCode = o.CurrencyIsoCode;
        newOpp.CampaignId = o.CampaignId;
        newOpp.IsPrivate = o.IsPrivate;
        newOpp.Promotional_End_Date__c = o.Promotional_End_Date__c;
        newOpp.Accounting_Contact__c = o.Accounting_Contact__c;
        newOpp.Accounting_Email__c = o.Accounting_Email__c;
        newOpp.Accounting_Phone__c = o.Accounting_Phone__c;
        newOpp.Account_String__c = o.Account_String__c;
        newOpp.Actual_Close_Date__c = o.Actual_Close_Date__c;
        newOpp.Actual_Create_Date__c = o.Actual_Create_Date__c;
        newOpp.Additional_Requests__c = o.Additional_Requests__c;                        
        //newOpp.Average_Monthly_Email_Volume__c = o.Average_Monthly_Email_Volume__c;
        //newOpp.Billed_Services__c = o.Billed_Services__c;
        newOpp.Payment_Frequency__c = o.Payment_Frequency__c;
        //newOpp.CF_Opp_Id__c = o.CF_Opp_Id__c;
       // newOpp.Channel__c = o.Channel__c;
        newOpp.Compelling_Event__c = o.Compelling_Event__c;
        newopp.MainCompetitor__c = o.MainCompetitor__c;
        newOpp.Competitor_Swap__c = o.Competitor_Swap__c;
        newOpp.Contract_Sign_Date__c = o.Contract_Sign_Date__c;
        newOpp.Corp_Currency_Amount__c = o.Corp_Currency_Amount__c;
        newOpp.CRM_System__c = o.CRM_System__c;
        newopp.Contact_Database_Size__c = o.Contact_Database_Size__c;
        newOpp.Days_Since_Lead_Created__c = o.Days_Since_Lead_Created__c;
       // newopp.Days_Since_Lead_Promotion__c = o.Days_Since_Lead_Promotion__c;
        //newOpp.Days_to_Sales_Lead__c = o.Days_to_Sales_Lead__c;
        newOpp.DealLostReason__c = o.DealLostReason__c;
        newOpp.Deal_Type__c = o.Deal_Type__c;
        newOpp.Deal_Won_By__c = o.Deal_Won_By__c;
        //newOpp.Demo_Type__c = o.Demo_Type__c;
        newOpp.Discount_Type__c = o.Discount_Type__c;
       // newOpp.Ease_of_Renewal__c = o.Ease_of_Renewal__c;
       // newOpp.Employee_Range_Summary__c = o.Employee_Range_Summary__c;
        //newOpp.Enablement_Close_Notes__c = o.Enablement_Close_Notes__c;
        //newOpp.Enablement_Project_Stage__c = o.Enablement_Project_Stage__c;
        newOpp.ExistingLandingPage__c = o.ExistingLandingPage__c;
        newopp.Forecast_Category__c = o.Forecast_Category__c;
        newOpp.Forecast_Category_Probability__c = o.Forecast_Category_Probability__c;
        //newopp.Service_Only__c = o.Service_Only__c;
        newOpp.Intacct_Entity__c = o.Intacct_Entity__c;
        newopp.Intacct_Sales_Region__c = o.Intacct_Sales_Region__c;
        newOpp.Lead_Buying_Behavior__c = o.Lead_Buying_Behavior__c;
        newopp.Lead_Category__c = o.Lead_Category__c;
        //newOpp.Lead_Promotion_Date__c = o.Lead_Promotion_Date__c;
        newOpp.Lead_Source_Comments__c = o.Lead_Source_Comments__c;
        newOpp.Lead_Source_Summary__c = o.Lead_Source_Summary__c;
        newOpp.Loss_Description__c = o.Loss_Description__c;
        // newOpp.Primary_Enablement_Partner__c = o.Primary_Enablement_Partner__c;
       // newOpp.Marketo_Login__c = o.Marketo_Login__c;
       // newOpp.Marketo_Password__c = o.Marketo_Password__c;
        //newOpp.Marketo_Subscription_Plan__c = o.Marketo_Subscription_Plan__c;
        //newOpp.Marketo_Subscription_Subplan__c = o.Marketo_Subscription_Subplan__c;
        newOpp.Maximum_Database_Size__c = o.Maximum_Database_Size__c;
        newOpp.MP_Purpose__c = o.MP_Purpose__c;
        newopp.MP_Reseller_Partner__c = o.MP_Reseller_Partner__c;
        //newOpp.MP_Sandbox__c = o.MP_Sandbox__c;
        newOpp.Munchkin_ID__c = o.Munchkin_ID__c;
        newOpp.Needs_Pains__c = o.Needs_Pains__c;
        //newOpp.Needs_Internal_Kickoff_Meeting__c = o.Needs_Internal_Kickoff_Meeting__c;
        //newOpp.Non_standard_Payment_Terms__c = o.Non_standard_Payment_Terms__c;
        newopp.Lead_Notes__c = o.Lead_Notes__c;
        //newOpp.Partner_Involved_del__c = o.Partner_Involved_del__c;
        //newOpp.OA_Product_Purchased_del__c = o.OA_Product_Purchased_del__c;
       // newopp.OpenAir_Percent_Complete_del__c = o.OpenAir_Percent_Complete_del__c;
        newopp.Opportunity_ARR__c = o.Opportunity_ARR__c;
        newOpp.Opportunity_Count__c = o.Opportunity_Count__c;
        //newOpp.Opportunity_Source__c = o.Opportunity_Source__c;
        //newOpp.Original_Lead_Created_Date__c     = o.Original_Lead_Created_Date__c  ;
        //newopp.OA_Partner_Involved__c = o.OA_Partner_Involved__c;
        newOpp.Payment_Terms__c = o.Payment_Terms__c;
        //newOpp.Pay_Referral__c = o.Pay_Referral__c;
       // newOpp.Perceived_Customer_Value__c = o.Perceived_Customer_Value__c;
        newOpp.POC_Prov_Email_Sent__c = o.POC_Prov_Email_Sent__c;
       // newOpp.POD__c = o.POD__c;
        newOpp.PO_Number__c = o.PO_Number__c;
        newOpp.Primary_Marketo_User_Email__c = o.Primary_Marketo_User_Email__c ;
        newOpp.Primary_Marketo_User_Lookup__c = o.Primary_Marketo_User_Lookup__c ;
        //newOpp.Primary_Marketo_User_Phone__c  = o.Primary_Marketo_User_Phone__c  ;                    
       // newOpp.Product_Interest__c = o.Product_Interest__c;
        //newOpp.Project_Classification__c = o.Project_Classification__c  ;
       // newOpp.Enablement_Completion_Date__c = o.Enablement_Completion_Date__c;
        //newOpp.ServicesNotes__c = o.ServicesNotes__c;
        //newopp.Enablement_Percent_Completed__c = o.Enablement_Percent_Completed__c;
        //newOpp.Project_Stage__c = o.Project_Stage__c;
        //newOpp.Project_Start_Date__c = o.Project_Start_Date__c;
        //newOpp.Project_Temperature__c = o.Project_Temperature__c;
        //newOpp.ProjectType__c = o.ProjectType__c;
        //newopp.Project_Type__c = o.Project_Type__c;                   
        newOpp.Qualified_Meeting__c = o.Qualified_Meeting__c;
        newOpp.Quarterly_Renewal__c = o.Quarterly_Renewal__c;
        //newOpp.Quote_Expiration_Date__c = o.Quote_Expiration_Date__c;
        newOpp.Referral_Partner__c = o.Referral_Partner__c;
        //newopp.RequestedKickoffDate__c = o.RequestedKickoffDate__c;
        //newOpp.RT__c = o.RT__c;
        newOpp.Sales_Lead_Date__c = o.Sales_Lead_Date__c;
        //newOpp.Sales_Lead_Type__c = o.Sales_Lead_Type__c;
       // newOpp.Sales_Outbound_Notes__c = o.Sales_Outbound_Notes__c;
        newOpp.Sales_Probability__c = o.Sales_Probability__c;
        //newOpp.SC_Enablement_Notes__c = o.SC_Enablement_Notes__c;
        newOpp.SDR_Owner__c = o.SDR_Owner__c;                   
        newOpp.Search_String__c = o.Search_String__c;                    
        //newopp.Services_Required__c = o.Services_Required__c;
        newOpp.SFDC_Edition__c = o.SFDC_Edition__c;
        //newOpp.SFDC_User__c =o.SFDC_User__c;
        //newOpp.SFDC_Users__c = o.SFDC_Users__c;
        //newOpp.Solutions_Consultant_Email__c = o.Solutions_Consultant_Email__c;
       // newOpp.Solutions_Consultant_Lookup__c = o.Solutions_Consultant_Lookup__c;
        newOpp.Split_Opportunities__c = o.Split_Opportunities__c;
        //newOpp.Tracking_URL__c = o.Tracking_URL__c;
        //newOpp.Web_Traffic__c = o.Web_Traffic__c;
        newOpp.Assignment_Email_Sent__c = null;
        /**newOpp.Assignment_Email_Project_Type__c = o.Assignment_Email_Project_Type__c;
        newOpp.Product_SVS__c   = o.Product_SVS__c   ;
        newOpp.Product_Info__c = o.Product_Info__c;
        newOpp.Assignment_Email_Sent__c = o.Assignment_Email_Sent__c;
        newOpp.Assigned_Consultant_Email__c =o.Assigned_Consultant_Email__c;
        newOpp.Sent_to_Clarizen__c = o.Sent_to_Clarizen__c;                    
        newOpp.Assigned_CEM__c = o.Assigned_CEM__c;               
        **/                    
        // newOpp.Provisioning_Email_Sent__c = o.Provisioning_Email_Sent__c;
        //newOpp.SDR_Owner_Look_Up__c = o.SDR_Owner_Look_Up__c;
        //newOpp.Amount = o.Amount;
        //newOpp.Discount_RUSF__c = o.Discount_RUSF__c;
        //newOpp.ExpectedRevenue = o.ExpectedRevenue;

       return newOpp;
    }
    
    public static testmethod void Dotest()
    {
        Opportunity  o = new Opportunity();
        RenewalTriggerMappingController.Mapfields(o);
        
    }
    public static void populateRenwalOpportunityFields(list<Opportunity> newRenwalOpportunityList,set<id> contractIds){
        
       map<id,id> contractWithOppids    = new map<id,id>();
       map<id,id> contractWithRenewalOppids=new map<id,id>();
       map<id,Opportunity> parentOppMap = new map<id,Opportunity>();
       set<id> oppIds                   = new set<id>();     
       set<string> fieldName            = new set<string>();     
       for(Contract  cont: [SELECT id , SBQQ__Opportunity__c,SBQQ__RenewalOpportunity__c FROM Contract  WHERE ID IN :contractIds AND SBQQ__Opportunity__c!=null]){
       
           contractWithOppids.put(cont.id,cont.SBQQ__Opportunity__c);
           if(cont.SBQQ__RenewalOpportunity__c!=null)
           //Added Map For setting Prior Opp on Churn Winback opp As Contract.Renewal Opp
           contractWithRenewalOppids.put(cont.id,cont.SBQQ__RenewalOpportunity__c);
           
       }//End of FOR loop
        if(!contractWithOppids.isEmpty()){  
            oppIds.addAll(contractWithOppids.values());
            if(!contractWithRenewalOppids.isEmpty())
            oppIds.addAll(contractWithRenewalOppids.values());
            string soqlStr ='SELECT ' ;
            for(Renewal_Opportunity_Fields__c renField :Renewal_Opportunity_Fields__c.getAll().values()){
                soqlStr = soqlStr +renField.Field_API_Name__c + ', ';
                fieldName.add(renField.Field_API_Name__c);
            }//End of FOR loop
            if(!fieldName.isEmpty()){
                //Query all current opp and renewal opp of Contract
                soqlStr = soqlStr +' id ,Name,closedate,Sub_End_Date__c,Type, Account.CAM_Owner__c, Account.CAM_Group__c, Plan_of_Record_Renewal_Date__c,Sub_Start_Date__c ,Opportunity_ARR2012__c,OwnerId,owner.isActive,Is_Winback_Created__c,SBQQ__PrimaryQuote__c,SBQQ__PrimaryQuote__r.MKTO_Effective_End_Date__c FROM Opportunity WHERE Id IN :oppIds';
                System.debug('soqlStr==============='+soqlStr);
               for(Opportunity opp:Database.query(soqlStr)){
                    parentOppMap.put(opp.id,opp);
                    Trigger_Opportunity_Helper.PriorOppIdWithCloseDateMap.put(opp.id,opp.closedate);
                }//End of FOR loop
                
                for(Opportunity Opp : newRenwalOpportunityList){
                          
                    
                    if(contractWithOppids.containsKey(opp.SBQQ__RenewedContract__c) && parentOppMap.containsKey(contractWithOppids.get(opp.SBQQ__RenewedContract__c)))
                    {
                        opportunity ParentOpp =  parentOppMap.get(contractWithOppids.get(opp.SBQQ__RenewedContract__c));
                        
                        //For Churn Winback Opp Consider Contract.Renewal Opp as Prior Opp
                        if(opp.Renewal_Type__c=='Churn Win-Back' && contractWithRenewalOppids.containsKey(opp.SBQQ__RenewedContract__c) && parentOppMap.containsKey(contractWithRenewalOppids.get(opp.SBQQ__RenewedContract__c)))
                           ParentOpp =  parentOppMap.get(contractWithRenewalOppids.get(opp.SBQQ__RenewedContract__c));
                        for(string s :fieldName){
                            Opp.put(s,ParentOpp.get(s));
                        }//End of FOR loop  
                         opp.closeDate = ParentOpp.closedate.addYears(1);
                         
                         Opp.StageName= System.Label.Renewal_Opportunity_Stage_Name;
                        
                        /* *********************************************************************************
                            Last Modified By: Jade Team on 19th April 2018, APPS-18492
                            Purpose         : Added OR Condition If Prior Opty->Master Sub End Date != Prior Opty->Primary Quote-> MKTO Effective End Date then opp Plan of Record Renewal Date = Prior Opty->Primary Quote-> MKTO Effective End Date else remaning logic as it is Opp Plan of Record Renewal Date = Master Sub End Date
                        *********************************************************************************** */  

                        
                        if (ParentOpp.SBQQ__PrimaryQuote__c != null && (ParentOpp.SBQQ__PrimaryQuote__r.MKTO_Effective_End_Date__c != ParentOpp.Sub_End_Date__c ) && opp.Renewal_Type__c!='Churn Win-Back'){
                            Opp.Plan_of_Record_Renewal_Date__c = ParentOpp.SBQQ__PrimaryQuote__r.MKTO_Effective_End_Date__c;
                        }
                        else if (ParentOpp.Sub_End_Date__c != null && opp.Renewal_Type__c!='Churn Win-Back'){
                              Opp.Plan_of_Record_Renewal_Date__c =  ParentOpp.Sub_End_Date__c ;
                        }
                        
                        if (ParentOpp.Sub_End_Date__c != null) {
                            Opp.CloseDate = ParentOpp.Sub_End_Date__c;//.addDays(1);                                 
                            if(Opp.Plan_of_Record_Renewal_Date__c != null)
                                Opp.Sub_Start_Date__c = Opp.Plan_of_Record_Renewal_Date__c.addDays(1);
                            if(Opp.Sub_Start_Date__c != null)
                                Opp.Sub_End_Date__c = Opp.Sub_Start_Date__c.addYears(1).addDays(-1);               
                        }//End of IF
                        else{
                            if(ParentOpp.closedate != null && opp.Renewal_Type__c!='Churn Win-Back'){ Opp.CloseDate = ParentOpp.CloseDate.addYears(1);}else if(ParentOpp.Sub_Start_Date__c != null){Opp.CloseDate = ParentOpp.Sub_Start_Date__c.addYears(1);}
                            if(ParentOpp.Sub_Start_Date__c != null) Opp.Sub_Start_Date__c = ParentOpp.Sub_Start_Date__c.addYears(1);
                        }//End of ELSE
                       
                        Opp.Prior_Opportunity__c = ParentOpp.id;
                        //Opp.Parent_Opportunity_Quarterly_Deals__c =ParentOpp.id;
                        Opp.RecordtypeId = RenewalSalesId;
                        opp.type         = Label.OPPORTUNITY_TYPE_RENEWAL;
                        List<Opportunity> CurrentOpptyList = new List<Opportunity>();
                        CurrentOpptyList.add(ParentOpp);
                        
                        if(opp.Renewal_Type__c!='Churn Win-Back'){
                        
                        String OWNER_ID = NEWupdateOpportunityBasedOnCriteria.getRenewalOpptyDefaultOwner(CurrentOpptyList);
                        system.debug('###############OWNER_ID '+OWNER_ID );
                        Opp.OwnerId = OWNER_ID;//System.Label.Renewal_Opportunity_Owner_Value;
                        }
                        if (ParentOpp.Opportunity_ARR2012__c != null && opp.Renewal_Type__c!='Churn Win-Back') {                    
                            Opp.Previous_Year_ACV__c = ParentOpp.Opportunity_ARR2012__c;
                            //Opp.Adjusted_POR__c = ParentOpp.Opportunity_ARR2012__c;
                        }                                              
                    }//End of IF
                }//End of FOR loop
            }//End of IF
        }//End of IF                                                                                                             
    }//End of method populateRenwalOpportunityFields 
}