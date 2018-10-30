/*********************************************************************
* Created by         : Rajesh Wani
* Created Date       : 5th Jan 2015
* Last Modified By   : Rajesh Wani 5th Jan 2015
* Purpose            : This is used as
*                       1. Handler class for SBQQ__Quote__c object trigger.   
* 
* Last Modified By   : Jade Global Inc, on 6th June 2017
* Purpose            : 1.Populate Bill-To, Ship-To Contact and its address on Quote from Account 
*                      2.If Bill-To and Ship-To contact is blank then populate from its Primary Contact(Quote)
*                      3. Populate Bill to and ship to address from Bill-To and Ship-To contact
* Last Modified By   : Jade Global Inc, on 4th April 2018
* Purpose            :  APPS-19530:Bill to contact and ship to contact lookup filter error
*
* Last Modified by   : Grazitti 
* Modified Date      : 5-April-18
* Purpose            : Added a Function mothsbetweendates to calculate correct number of months between dates, one can track the changes by searching the ticket number in code.
* Refrence           : #APPS-19105# Subscription Term is wrong Months
                           
* Modified By        : Jade Global on 3rd May 2018
* Purpose            : Added Code to carry forward Order Type on New Quote from Prior Quote
                       Reference Ticket No :APPS-14831:Rubiks automated quotes: Order Type doesn't carry over
					   
					   
					   
Modified By : Tushar Misri, Grazitti Interactive
Modified date : 8/11/2018
Purpose : Commented the field that are used in field removal project 
refrence : APPS-20840 Field Cleanup Project - Phase One
log of fields commented : Opportunity: project_classification__c

* Modified By        : Jade Global Inc, on 8th September 2018
* Purpose            : To handle Phoenix Provisioning Scenarios
					   Added logic for Solution Quote should not Carry forward for phoenix(Group Line Items)
					   
* Modified By        : Jade Global Inc, on 13th September 2018
* Purpose            : To populate the Additional_UR_Products__c field on quote from QLI UR products
					  
*********************************************************************** */
public class SBQQQuoteTriggerHandler {
    static list<SBQQ__Quote__c> quoteWithCountryList = new list<SBQQ__Quote__c>();
    static set<id> updatedOppIds      = new set<id>();
    static set<string> countrySet                    = new set<string> ();
    static set<id> oppIds                            = new set<id>();
    static map<id,Opportunity> OpportunityUpdateMap  = new map<id,Opportunity>();
    static list<Opportunity> OpptyUpdateList         = new list<Opportunity>();
    public static Boolean IS_OPPTY_UPDATED           = false;
    public static Boolean IS_Intacct_Entity_Updated_On_Opportunity           = false;
    /**Added code for updating Account from Quote Shiping Address and Billling Address**/
    public static List<Account> acc2UpdWdQuoteBillShipAddrs = new List<Account>();
    public static Map<Id,SBQQ__Quote__c> quoteWithBillShipAddress = new Map<Id,SBQQ__Quote__c>();
    public static Set<Id> accIds = new Set<Id>();
    public static Boolean IS_ACCOUNT_UPDATED         = false;
    public static set<id> oppsToUpdateSet= new set<id>();
    public static Boolean IS_OPPTY_UPDATED_AfterInsert           = false;
    public static Boolean IS_OPPTY_UPDATED_Afterupdate           = false;
    public static set<ID> setPriorSubTermOnQuote=new set<ID>();
    public static set<ID> contractIdSet=new set<ID>();
    public static Map<id,Contract> contractMapForUC=new Map<id,Contract>();
    public static set<ID> QuoteIdSet=new set<ID>();
    public static set<ID> QuoteIdForPaymentFreq=new set<ID>();
    Public static String OPPTY_SIGNED_ORDER = Label.Opportunity_Stage_is_Signed_Order;
    public static string JPY_BILL_TO_CONTACT_NAME_SALUTATION =  Label.JPY_Order_Form_Salutation;
    //public static boolean AmendOpptyQuoteLinked = false;
    //public static id AmendUpsellOpptyQuoteid;
    
    //public static bool afterinsert = false;
    /**Ends**/
    
    public static void QuoteTriggerHandler(list<SBQQ__Quote__c> newQuote, map<id,SBQQ__Quote__c> oldQuoteMap){
        SteelBrickCPQPricebook__c SBPB = SteelBrickCPQPricebook__c.getOrgDefaults();
        if(Trigger.isBefore) {   
            if(Trigger.isInsert){  

               set<id> quotesIds                            = new set<id>();
               list<SBQQ__Quote__c> RenewalQuotelist = new list<SBQQ__Quote__c>();
               /**NEW CODE ADDED BY GRAZIIT_ ADDRESS COPY ON ACCOUNT __**/
               Map<Id,SBQQ__Quote__c> nullQuoteMap = new Map<Id,SBQQ__Quote__c>();
               
               OpptyMap = new Map<Id,Opportunity>();
               /**NEW CODE ADDED BY GRAZIIT_ ADDRESS COPY ON ACCOUNT __END**/
               for(SBQQ__Quote__c quote: newQuote){
                       
                       quoteWithCountryList.add(quote);
                       if(quote.SBQQ__ShippingCountry__c!=null){
                           countrySet.add(quote.SBQQ__ShippingCountry__c);
                       }//End of IF loop
                       if(quote.SBQQ__Opportunity2__c!= null){
                           oppIds.add(quote.SBQQ__Opportunity2__c);  
                       }  
                   
                  
                }//End of FOR loop
                                
                if(!quoteWithCountryList.isEmpty()){
                    populateCountryFields(quoteWithCountryList,countrySet,oppIds, nullQuoteMap );
                }
                
                //Optimized by Jade to Fix CPU Time Limit Exception while Solution Amend 
                // Modified by Jade Global Inc, On 6th June 2017
                map<id,Opportunity> OpportunityMapNBandRen = new map<id,Opportunity>([SELECT id, Sub_Start_Date__c, Sub_End_Date__c,Payment_Frequency__c, Maximum_Database_Size__c,Payment_Terms__c,SBQQ__AmendedContract__r.ContractTerm, Prior_Opportunity__c, Pricebook2Id, Prior_Opportunity__r.Pricebook2Id, SBQQ__RenewedContract__r.SBQQ__Quote__r.Rubiks_Quote__c,SBQQ__AmendedContract__r.SBQQ__Quote__r.Rubiks_Quote__c,SBQQ__RenewedContract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c,SBQQ__AmendedContract__r.SBQQ__Quote__r.SBQQ__LineItemsGrouped__c,Account.ABN_No__c,Account.Registered_VAT_No__c,SBQQ__RenewedContract__c,SBQQ__RenewedContract__r.SBQQ__Quote__r.Payment_Frequency__c,SBQQ__AmendedContract__r.SBQQ__Quote__r.Payment_Frequency__c,SBQQ__RenewedContract__r.Total_Contact_Records__c,SBQQ__RenewedContract__r.SBQQ__RenewalTerm__c,SBQQ__RenewedContract__r.Total_Unique_Visitors__c,type,Prior_Opportunity__r.SBQQ__PrimaryQuote__r.Hide_Discount__c,SBQQ__AmendedContract__c,SBQQ__RenewedContract__r.Renewal_Uplift_pct__c,SBQQ__PrimaryQuote__r.Blended_Discount__c,SBQQ__AmendedContract__r.Payment_Frequency__c,Account.Auto_Acct_Prefix__c,Account.Bill_To_Contact__c,Account.Bill_To_Contact__r.name,Account.Ship_To_Contact__c,Account.Ship_To_Contact__r.name,Primary_Marketo_User_Lookup__c,Primary_Marketo_User_Lookup__r.name,Account.Bill_To_Contact__r.MailingStreet,Account.Bill_To_Contact__r.MailingCity,Account.Bill_To_Contact__r.MailingState,Account.Bill_To_Contact__r.MailingPostalCode,Account.Bill_To_Contact__r.MailingCountry,Account.Ship_To_Contact__r.MailingStreet,Account.Ship_To_Contact__r.MailingCity,Account.Ship_To_Contact__r.MailingState,Account.Ship_To_Contact__r.MailingPostalCode,Account.Ship_To_Contact__r.MailingCountry,Account.Bill_To_Contact__r.Email,Account.Bill_To_Contact__r.FirstName,Account.Bill_To_Contact__r.LastName,Account.Bill_To_Contact__r.LastNameLocal,Account.Bill_To_Contact__r.FirstNameLocal,Account.Ship_To_Contact__r.FirstNameLocal,Account.Ship_To_Contact__r.LastNameLocal,Account.Ship_To_Contact__r.FirstName,Account.Ship_To_Contact__r.LastName,SBQQ__RenewedContract__r.SBQQ__Quote__r.Order_Type__c,CreatedDate FROM Opportunity WHERE  Id IN :oppIds]);
                
                /* *******************************************************************************           
                Last Modified By : Jade Global Inc, on 6th June 2017
                Purpose          : Populate Bill-To, Ship-To Contact and its address on Quote from Account 
                ********************************************************************************* */                               
                for(SBQQ__Quote__c quote: newQuote){
                
                    /* *******************************************************************************           
                    Last Modified By : Jade Global Inc, on 4th July 2018
                    Purpose          :  APPS-19530:Bill to contact and ship to contact lookup filter error
          Line No       : 89 to 96
          ********************************************************************************* */
          datetime createdateTimeOpp,CurrentDateTime;
                    
                    if(OpportunityMapNBandRen.containsKey(quote.SBQQ__Opportunity2__c)){
            createdateTimeOpp =OpportunityMapNBandRen.get(quote.SBQQ__Opportunity2__c).CreatedDate.addMinutes(2);
                    
            CurrentDateTime=system.now();
                    
                    }
                    
                    if(quote.SBQQ__Opportunity2__c!=null && OpportunityMapNBandRen.containsKey(quote.SBQQ__Opportunity2__c) && !(CurrentDateTime<=createdateTimeOpp)){
                         Opportunity Opp = OpportunityMapNBandRen.get(quote.SBQQ__Opportunity2__c);
                        if(Opp.Account.Bill_To_Contact__c!=Null){
                                    quote.Bill_To_Contact__c            =   Opp.Account.Bill_To_Contact__c;  
                                    quote.SBQQ__BillingName__c          =   Opp.Account.Bill_To_Contact__r.name;
                                    quote.SBQQ__BillingStreet__c        =   Opp.Account.Bill_To_Contact__r.MailingStreet;
                                    quote.SBQQ__BillingCity__c          =   Opp.Account.Bill_To_Contact__r.MailingCity;
                                    quote.SBQQ__BillingState__c         =   Opp.Account.Bill_To_Contact__r.MailingState;
                                    quote.SBQQ__BillingPostalCode__c    =   Opp.Account.Bill_To_Contact__r.MailingPostalCode;
                                    quote.SBQQ__BillingCountry__c       =   Opp.Account.Bill_To_Contact__r.MailingCountry;
                                    quote.Bill_To_Contact_Email__c      =   Opp.Account.Bill_To_Contact__r.Email;
                  if(quote.Japan_Checkbox__c){
                                        quote.Bill_to_Contact_Name_for_JPN_Order_Form__c=Opp.Account.Bill_To_Contact__r.LastNameLocal+' ' +Opp.Account.Bill_To_Contact__r.FirstNameLocal+' '+JPY_BILL_TO_CONTACT_NAME_SALUTATION;
                                    }
                            }
                            if(Opp.Account.Ship_To_Contact__c!=Null){
                                    quote.Ship_To_Contact__c            =   Opp.Account.Ship_To_Contact__c;
                                    quote.SBQQ__ShippingName__c         =   Opp.Account.Ship_To_Contact__r.name;
                                    quote.SBQQ__ShippingStreet__c       =   Opp.Account.Ship_To_Contact__r.MailingStreet;
                                    quote.SBQQ__ShippingCity__c         =   Opp.Account.Ship_To_Contact__r.MailingCity;
                                    quote.SBQQ__ShippingState__c        =   Opp.Account.Ship_To_Contact__r.MailingState;
                                    quote.SBQQ__ShippingPostalCode__c   =   Opp.Account.Ship_To_Contact__r.MailingPostalCode;
                                    quote.SBQQ__ShippingCountry__c      =   Opp.Account.Ship_To_Contact__r.MailingCountry;
                                      
                                    if(Opp.Account.Ship_To_Contact__r.FirstNameLocal != null &&  Opp.Account.Ship_To_Contact__r.LastNameLocal != null){
                                       quote.Contact_Name_Toggle_Text__c    =    Opp.Account.Ship_To_Contact__r.LastNameLocal+ ' ' + Opp.Account.Ship_To_Contact__r.FirstNameLocal + ' ' +JPY_BILL_TO_CONTACT_NAME_SALUTATION;
                                     }else{
                                       quote.Contact_Name_Toggle_Text__c    =    Opp.Account.Ship_To_Contact__r.LastName   +' ' + Opp.Account.Ship_To_Contact__r.FirstName+ ' ' +JPY_BILL_TO_CONTACT_NAME_SALUTATION;
                                     }

                            }
                        
                        // Populate following fields on Quote from Opportunity - Required_Max_Contact_Records__c, SBQQ__StartDate__c, SBQQ__EndDate__c, Payment_Frequency__c, SBQQ__PaymentTerms__c.
                        // Code Added by Jade - APPS-5673
                        /*if(quote.Rubiks_Quote__c == FALSE){
                            // Populate Required Contacts on Quote if it is not Solution Quote. For Solution quote, we have different logic.
                            quote.Target_Number_of_Contact_Records__c = Opp.Maximum_Database_Size__c != null ? Opp.Maximum_Database_Size__c : quote.Target_Number_of_Contact_Records__c;
                        }*/
                       /* Comment added by jade  for APPS-8298*/
                      //  quote.SBQQ__StartDate__c = Opp.Sub_Start_Date__c != null ? Opp.Sub_Start_Date__c : quote.SBQQ__StartDate__c;
                        //If Loop added by Jade to fix the Start date/end date issue for APPS-8341 on 27th May 16
                        //This End date should work for Upsells only
                        if(opp.type == 'Upsell/Crossell'){
                            quote.SBQQ__EndDate__c = Opp.Sub_End_Date__c != null? Opp.Sub_End_Date__c : quote.SBQQ__EndDate__c ;  
                           system.debug('quote.SBQQ__EndDate__c###########'+quote.SBQQ__EndDate__c);
                            system.debug('Opp.Sub_End_Date__c###########'+Opp.Sub_End_Date__c);
                        }
                        //quote.Payment_Frequency__c = Opp.Payment_Frequency__c != null ? Opp.Payment_Frequency__c :
                        //Added if loop by jade to handle two validation rules on SB Quote
                        //Date : 29th April 2016
                        // Commented by Jade on 31st Aug 2016 for ticket APPS-9447
                       /* if(quote.Opportunity_Type__c != 'Upsell/Crossell' && (quote.Order_Type__c != 'Services Only' || quote.Order_Type__c != 'Custom SOW')){
                            quote.Payment_Frequency__c = Opp.Payment_Frequency__c != null ? Opp.Payment_Frequency__c : quote.Payment_Frequency__c;
                        }*/
                        
                        //quote.SBQQ__PaymentTerms__c = Opp.Payment_Terms__c != null ? Opp.Payment_Terms__c : quote.SBQQ__PaymentTerms__c; 
                        /************************************************************************
                         * Modified by   : Jade Global (Rajesh Wani)
                         * Modified date : 20th April 2016
                         * Changes       : Updating the Quote Type as Renewal if Opportunity type is Renewal
                                           Updating the Quote Opportunity_Type__c same as  Opportunity type 
                                           Hide discount logic
                                           Above 3 logic was removed from IF loop at line 108 where we are poulating the values from SBQQ__RenewedContract__c
                        ************************************************************************/
                        quote.Opportunity_Type__c                   =  Opp.type;
                        if(Opp.type=='Renewal'){
                            quote.SBQQ__Type__c                         = 'Renewal';
                        }
                         if(Opp.Prior_Opportunity__r.SBQQ__PrimaryQuote__r.Hide_Discount__c ==true){
                                quote.Hide_Discount__c = true;
                        }
                        //quote.Payment_Frequency__c                  = opp.SBQQ__RenewedContract__r.SBQQ__Quote__r.Payment_Frequency__c;
                        if(Opp.type=='Renewal' && opp.SBQQ__RenewedContract__c!=null){
                            //quote.Opportunity_Type__c                   =  Opp.type;
                            //Setting Quote Type = Renewal if Opportunity Type = Renewal
                            //Added by Jade on 12th Feb, 2016 for APPS - 6809
                            //quote.SBQQ__Type__c                         = 'Renewal';
                            quote.Payment_Frequency__c                  = opp.SBQQ__RenewedContract__r.SBQQ__Quote__r.Payment_Frequency__c;
                            /* ************************************************************************************
                            Modified By         : Jade Global on 3rd May 2018
                            Purpose             : Added Code to carry forward Order Type on New Quote from Prior Quote
                                                  Reference Ticket No :APPS-14831:Rubiks automated quotes: Order Type doesn't carry over
                            ************************************************************************************* */
                            if(opp.SBQQ__RenewedContract__r.SBQQ__Quote__c!= null){
                                quote.Order_Type__c = Opp.SBQQ__RenewedContract__r.SBQQ__Quote__r.Order_Type__c;
                            }
                            
                            //quote.Contract_Lookup__c                    = opp.SBQQ__RenewedContract__c;
                            //Added for Rubik Quote ,Not carry forwarding the Contacts from Last Contract 
                            //Modified By :Jade Global 10th June 2016
                            system.debug('Entered in Renewals loop****************');
                            //added check for change early renewal term
                            
                            quote.SBQQ__SubscriptionTerm__c = opp.SBQQ__RenewedContract__r.SBQQ__RenewalTerm__c;
                             system.debug(' opp.SBQQ__RenewedContract__r.SBQQ__RenewalTerm__c#######'+ opp.SBQQ__RenewedContract__r.SBQQ__RenewalTerm__c);
                             system.debug(' quote.SBQQ__SubscriptionTerm__c#######'+ quote.SBQQ__SubscriptionTerm__c);
                            //We have added check as part of the phoneix, as phoneix is not Rubiks Quote
                            if(quote.Rubiks_Quote__c==FALSE && opp.SBQQ__RenewedContract__r.SBQQ__Quote__r.Rubiks_Quote__c==TRUE && !(SBPB.Phoenix_Price_Books__c.contains(opp.Pricebook2Id))){
                                quote.Rubiks_Quote__c                       = opp.SBQQ__RenewedContract__r.SBQQ__Quote__r.Rubiks_Quote__c;
                            }
                            if(quote.Rubiks_Quote__c==FALSE){
                                quote.Target_Number_of_Unique_Visitors__c   = opp.SBQQ__RenewedContract__r.Total_Unique_Visitors__c;
                                quote.Target_Number_of_Contact_Records__c   = opp.SBQQ__RenewedContract__r.Total_Contact_Records__c;
                            }
                            //quote.Current_Uplift_pct__c = String.valueOf(opp.SBQQ__RenewedCo  ntract__r.Renewal_Uplift_pct__c);
                            /*if(Opp.Prior_Opportunity__r.SBQQ__PrimaryQuote__r.Hide_Discount__c ==true){
                                quote.Hide_Discount__c = true;
                            }
                            */
                        }else if(quote.SBQQ__Type__c=='Amendment'){
                            quote.Opportunity_Type__c                   =  'Upsell/Crossell';
                            //quote.Payment_Frequency__c                  = opp.SBQQ__AmendedContract__r.SBQQ__Quote__r.Payment_Frequency__c;
                            
                            //########## Added By Jade For Amends Decommissioning #############
                            if(!QuoteIdForPaymentFreq.isEmpty()&& !QuoteIdForPaymentFreq.contains(quote.Id)){
                                quote.Payment_Frequency__c= opp.SBQQ__AmendedContract__r.Payment_Frequency__c;
                                QuoteIdForPaymentFreq.add(quote.Id);
                            }
                            else{
                                quote.Payment_Frequency__c= opp.SBQQ__AmendedContract__r.Payment_Frequency__c;
                                QuoteIdForPaymentFreq.add(quote.Id);
                            }
                            //########## Added By Jade For Amends Decommissioning #############
                            //We have added check as part of the phoneix, as phoneix is not Rubiks Quote
                            if(!(SBPB.Phoenix_Price_Books__c.contains(opp.Pricebook2Id))){
                                quote.Rubiks_Quote__c                       = opp.SBQQ__AmendedContract__r.SBQQ__Quote__r.Rubiks_Quote__c;
                            }
                            // Populating Subscription Term from Amended Contract's Contract Term - Jade
                            //quote.SBQQ__SubscriptionTerm__c = opp.SBQQ__AmendedContract__r.ContractTerm;
                            if(quote.MKTO_Effective_End_Date__c != null && quote.SBQQ__StartDate__c != null){
                //APPS-19105
                                //quote.SBQQ__SubscriptionTerm__c = (quote.SBQQ__StartDate__c.monthsBetween(quote.MKTO_Effective_End_Date__c.addDays(1)));
                quote.SBQQ__SubscriptionTerm__c = monthsbetweendates(quote.SBQQ__StartDate__c,quote.MKTO_Effective_End_Date__c.addDays(1));
                //APPS-19105
                
                            }
                            else{
                                quote.SBQQ__SubscriptionTerm__c = opp.SBQQ__AmendedContract__r.ContractTerm;
                            }
                            
                             //############Commented by JADE for Amends Decomissioning##############
                            //quote.AmendNewBusinessOpportunityId__c  = quote.SBQQ__Opportunity2__c;
                            
                             //quote.SBQQ__Primary__c = FALSE;
              
                              //*******************************
                              //Added by Jade Global
                              //29th Sep 2016
                               //############Commented by JADE for Amends Decomissioning##############
                              /*
                              Opportunity myOpp;

                              if(quote.AmendNewBusinessOpportunityId__c != null ){

                                List<Opportunity> oppList=new List<Opportunity>([Select id,SBQQ__PrimaryQuote__c, Name, SBQQ__AmendedContract__r.SBQQ__Quote__r.Payment_Frequency__c,SBQQ__AmendedContract__r.SBQQ__Quote__r.Rubiks_Quote__c, Prior_Opportunity__r.SBQQ__PrimaryQuote__r.Hide_Discount__c  from Opportunity where id!=:quote.AmendNewBusinessOpportunityId__c and SBQQ__AmendedContract__c!=NULL and SBQQ__AmendedContract__c=:quote.SBQQ__MasterContract__c and id!=:quote.SBQQ__Opportunity2__c AND isWon = FALSE  AND isClosed = FALSE Order by LastModifiedDate DESC LIMIT 1]);
                                
                                //String oldOpp=quote.SBQQ__Opportunity2__c;
                                Boolean isAmendment=false;

                                if(!oppList.isEmpty()){
                                  myOpp=oppList.get(0);

                                  
                                  system.debug('Amended Upsell Id*********** : '+myOpp);
                                  //System.AssertEquals(string.valueof(myOpp.id),oldOpp);

                                  for(SBQQ__Quote__c q:newQuote){
                                    q.SBQQ__Opportunity2__c=oppList.get(0).id; 
                                    AmendOpptyQuoteLinked = true;
                                    AmendUpsellOpptyQuoteid = oppList.get(0).id;
                                    //System.assertEquals(String.valueof(oppList.get(0).id),'Test');
                                    q.Quote_Name__c=myOpp.Name + ' ' + q.Name;
                                    q.Amendment_Override__c=true;
                                    if(q.SBQQ__Type__c=='Amendment'){
                                      isAmendment=true;
                                      q.Opportunity_Type__c                   =  'Upsell/Crossell';
                                      //q.Payment_Frequency__c                  = myOpp.SBQQ__AmendedContract__r.SBQQ__Quote__r.Payment_Frequency__c;
                                      q.Rubiks_Quote__c                       = myOpp.SBQQ__AmendedContract__r.SBQQ__Quote__r.Rubiks_Quote__c;
                                      if(q.MKTO_Effective_End_Date__c != null && q.SBQQ__StartDate__c != null){
                                        q.SBQQ__SubscriptionTerm__c = (q.SBQQ__StartDate__c.monthsBetween(q.MKTO_Effective_End_Date__c.addDays(1)));
                                      }
                                      else{
                                        q.SBQQ__SubscriptionTerm__c = q.SBQQ__Opportunity2__r.SBQQ__AmendedContract__r.ContractTerm;
                                      }

                                    }  
                                  }

                                }
                              }
                              */
                              //********************************
                             //############Commented by JADE for Amends Decomissioning##############
                         }
                         quote.Acct_Prefix_Requested__c  = Opp.Account.Auto_Acct_Prefix__c != null? Opp.Account.Auto_Acct_Prefix__c : quote.Acct_Prefix_Requested__c  ;  
             system.debug('######### Opp.Account.Auto_Acct_Prefix__c'+Opp.Account.Auto_Acct_Prefix__c ); 
                   }
                   
                   //Added by Abhijeet Baneka @ Jadeglobal on 11.11.2015 for Jira ticket number : APPS-2259
                   // Start of APPS-2259
                   if(quote.SBQQ__Opportunity2__c!=null && !OpportunityMapNBandRen.isEmpty() ){
                        if(OpportunityMapNBandRen.containskey(quote.SBQQ__Opportunity2__c) && OpportunityMapNBandRen.get(quote.SBQQ__Opportunity2__c).Account!= null && (quote.ABN_No__c == NULL || quote.ABN_No__c == '' )){
                           if(OpportunityMapNBandRen.get(quote.SBQQ__Opportunity2__c).type == 'Renewal' && OpportunityMapNBandRen.get(quote.SBQQ__Opportunity2__c).Account.ABN_No__c != null && OpportunityMapNBandRen.get(quote.SBQQ__Opportunity2__c).Account.ABN_No__c != ''){
                                quote.ABN_No__c = OpportunityMapNBandRen.get(quote.SBQQ__Opportunity2__c).Account.ABN_No__c;
                           }
                       }
                       if(OpportunityMapNBandRen.containskey(quote.SBQQ__Opportunity2__c) && OpportunityMapNBandRen.get(quote.SBQQ__Opportunity2__c).Account!= null && (quote.Registered_VAT_No__c== NULL || quote.Registered_VAT_No__c== '' )){
                           if(OpportunityMapNBandRen.get(quote.SBQQ__Opportunity2__c).type == 'Renewal' && OpportunityMapNBandRen.get(quote.SBQQ__Opportunity2__c).Account.Registered_VAT_No__c!= null && OpportunityMapNBandRen.get(quote.SBQQ__Opportunity2__c).Account.Registered_VAT_No__c!= ''){
                                quote.Registered_VAT_No__c = OpportunityMapNBandRen.get(quote.SBQQ__Opportunity2__c).Account.Registered_VAT_No__c;
                           }
                       }
                        
                   }
                   // END of APPS-2259
                   
                }//End of FOR loop */
                //System.assertEquals(1,2);
                
                
                // Method to populate current quote fields from previous quote 
                //Optimized by Jade to Fix CPU Time Limit Exception while Solution Amend 
                populateNewQuoteFieldsFromPrevQuote(newQuote,OpportunityMapNBandRen);             
                //System.assertEquals(1, 2);
                
                //******************** Blended Discount Logic *****************
                //Call to method to populate Prior Blended Discount on creation of Renewal Quote
                //Added by Jade on 22nd July 2016 for APPS-7462 : Create "Previous YTD Blended Discount"
                /*list<SBQQ__Quote__c> listRenewalQuotes = new list<SBQQ__Quote__c>();
                For(SBQQ__Quote__c quote : newQuote){
                    //Checking if Quote is of type 'Renewal'
                    if(quote.Opportunity_Type__c == 'Renewal'){
                        listRenewalQuotes.add(quote);
                    }
                }
                if(!listRenewalQuotes.isEmpty()){
                    //This Method will only be called for Renewal Quotes being inserted
                   YTDBlendedDiscountCalculator.populatePriorBlendedDiscoutFieldOnRNWLQuote(listRenewalQuotes); 
                }*/
                
                YTDBlendedDiscountCalculator.populatePriorBlendedDiscoutFieldOnRenewalAndUpsellQuote(newQuote);
                
                //******************** Blended Discount Logic Ends ***************** 
                
            }//End of Before Insert trigger
            
            if(Trigger.isUpdate){
              
              if(Trigger.size==1){
                //Find Opportunity that contains Quote's Contract ID, Exclude the Existing Opportunity from the Search
                //If found, grab Opp Id and update on Quote
                //This is used to store the NB Opportunity id  created by Steelbrick for Amend 
                id AmendDeleteOpptyId;
                SBQQ__Quote__c myQuote;
                Opportunity myOpp;
                
                for(SBQQ__Quote__c q:newQuote){
                    myQuote=q;
                    if(oldQuoteMap.get(q.Id).SBQQ__SubscriptionTerm__c!=null && !setPriorSubTermOnQuote.contains(q.Id)){
                        q.Prior_Subscription_Term__c=oldQuoteMap.get(q.Id).SBQQ__SubscriptionTerm__c;
                        setPriorSubTermOnQuote.add(q.Id);
                    }
                    //myQuote.SBQQ__Primary__c=true;
                    
                    if(q.SBQQ__Type__c=='Amendment'){
                        if(q.MKTO_Effective_End_Date__c != null && q.SBQQ__StartDate__c != null){
              //APPS-19105
                            //q.SBQQ__SubscriptionTerm__c = (q.SBQQ__StartDate__c.monthsBetween(q.MKTO_Effective_End_Date__c.addDays(1)));
              q.SBQQ__SubscriptionTerm__c = monthsbetweendates(q.SBQQ__StartDate__c,q.MKTO_Effective_End_Date__c.addDays(1));
              //APPS-19105
                        }
                        
                        AmendDeleteOpptyId                      = q.AmendNewBusinessOpportunityId__c;
                    }//End of IF loop
                    
                    if( q.Opportunity_Type__c=='Upsell/Crossell' && q.Rubiks_Quote__c==FALSE && q.New_Instance_or_Change_to_Existing__c=='Change to Existing Instance' && q.SBQQ__MasterContract__c!=null && q.SBQQ__MasterContract__c!= oldQuoteMap.get(q.id).SBQQ__MasterContract__c){
                        contractIdSet.add(q.SBQQ__MasterContract__c);
                        
                    }
                    
                    //########### Commented by Jade For Amends Decommissioning ############
                    /*if(q.SBQQ__Opportunity2__c!=AmendUpsellOpptyQuoteid && AmendUpsellOpptyQuoteid!=null){
                        q.SBQQ__Opportunity2__c = AmendUpsellOpptyQuoteid;
                    }*/
                   
                }  
                if(!contractMapForUC.keySet().containsAll(contractIdSet) && !contractIdSet.IsEmpty()){
                 contractMapForUC = new map<id,Contract>([select id,Payment_Frequency__c,ContractTerm,StartDate,EndDate from Contract where id IN:contractIdSet]);
                
                
                }
                          
                //Commented by Jade Global
                //29th Sep 2016
                /*if(AmendDeleteOpptyId!=null ){
                   
                     List<Opportunity> oppList=new List<Opportunity>([Select id,SBQQ__PrimaryQuote__c, Name, SBQQ__AmendedContract__r.SBQQ__Quote__r.Payment_Frequency__c,SBQQ__AmendedContract__r.SBQQ__Quote__r.Rubiks_Quote__c, Prior_Opportunity__r.SBQQ__PrimaryQuote__r.Hide_Discount__c  from Opportunity where id!=:AmendDeleteOpptyId and SBQQ__AmendedContract__c!=NULL and SBQQ__AmendedContract__c=:myQuote.SBQQ__MasterContract__c and id!=:myQuote.SBQQ__Opportunity2__c and SBQQ__AmendedContract__c=:myQuote.SBQQ__MasterContract__c  Order by LastModifiedDate DESC LIMIT 1]);

                    String oldOpp=myQuote.SBQQ__Opportunity2__c;
                    Boolean isAmendment=false;
                    if(!oppList.isEmpty()){
                        myOpp=oppList.get(0);
              
                        System.debug('Amended Upsell Id*********** : '+myOpp);
                        //System.AssertEquals(string.valueof(myOpp.id),oldOpp);

                        for(SBQQ__Quote__c q:newQuote){
                                q.SBQQ__Opportunity2__c=myOpp.id; 
                                q.Quote_Name__c=myOpp.Name + ' ' + q.Name;
                                q.Amendment_Override__c=true;
                                if(q.SBQQ__Type__c=='Amendment'){
                                  isAmendment=true;
                                  q.Opportunity_Type__c                   =  'Upsell/Crossell';
                                  //q.Payment_Frequency__c                  = myOpp.SBQQ__AmendedContract__r.SBQQ__Quote__r.Payment_Frequency__c;
                                  q.Rubiks_Quote__c                       = myOpp.SBQQ__AmendedContract__r.SBQQ__Quote__r.Rubiks_Quote__c;
                                  if(q.MKTO_Effective_End_Date__c != null && q.SBQQ__StartDate__c != null){
                                    q.SBQQ__SubscriptionTerm__c = (q.SBQQ__StartDate__c.monthsBetween(q.MKTO_Effective_End_Date__c.addDays(1)));
                                  }
                                  else{
                                    q.SBQQ__SubscriptionTerm__c = q.SBQQ__Opportunity2__r.SBQQ__AmendedContract__r.ContractTerm;
                                  }
                                 
                                }  
                        }

                    }
                }*/
                }

                
               list<SBQQ__Quote__c> quotelist                       = new list<SBQQ__Quote__c>();
               list<SBQQ__Quote__c> quotePaymentFrequencylist       = new list<SBQQ__Quote__c>();
               /**NEW CODE FOR SHIIPING/BIILING ADDRESS__START***/
              
               List<SBQQ__Quote__c> allquoteslist                   = new List<SBQQ__Quote__c>();
               OpptyMap = new Map<Id,Opportunity>();
               /**NEW CODE FOR SHIIPING/BIILING ADDRESS__START***/
                // Quote Payment Frequency Changes      
                Set<Id> oppIdSet = new Set<Id>();
                Map<Id,Opportunity> oppIdOpptyMap = new Map<Id,Opportunity>();
                
                if(!newQuote.isEmpty()){
                    for(SBQQ__Quote__c quote: newQuote){
                        oppIdSet.add(quote.SBQQ__Opportunity2__c);
                    }//End of FOR loop
                }
                
                if(!oppIdSet.isEmpty()){
                    for(Opportunity opp :[Select Id, Type, SBQQ__RenewedContract__r.SBQQ__Quote__r.Payment_Frequency__c, SBQQ__AmendedContract__r.SBQQ__Quote__r.Payment_Frequency__c,SBQQ__RenewedContract__r.EndDate,SBQQ__RenewedContract__r.SBQQ__Quote__r.Rubiks_Quote__c,SBQQ__AmendedContract__c,SBQQ__AmendedContract__r.SBQQ__Quote__r.Rubiks_Quote__c,StageName,CreatedDate,Pricebook2Id From Opportunity where Id IN:oppIdSet]){
                        oppIdOpptyMap.put(opp.Id,opp);
                    }
                }
                
                // Quote Payment frequency code ends here
               Set<Id> ContactIdSet=new Set<Id>();
               for(SBQQ__Quote__c quote: newQuote){
                /* *******************************************************************************           
                    Last Modified By : Jade Global Inc, on 6th June 2017
                    Purpose          : 1. If Bill-To and Ship-To contact is blank then populate from its Primary Contact(Quote)
                                       2. Populate Bill to and ship to address from Bill-To and Ship-To contact
                ********************************************************************************* */
                    
          /* *******************************************************************************           
                    Last Modified By : Jade Global Inc, on 4th July 2018
                    Purpose          :  APPS-19530:Bill to contact and ship to contact lookup filter error
          Line No       : 445 to 452
          ********************************************************************************* */
          datetime createdateTimeOpp,CurrentDateTime;
                    
                    if(oppIdOpptyMap.containsKey(quote.SBQQ__Opportunity2__c)){
            createdateTimeOpp =oppIdOpptyMap.get(quote.SBQQ__Opportunity2__c).CreatedDate.addMinutes(2);
                    
            CurrentDateTime=system.now();
                    
                    }
                    if(quote.Bill_To_Contact__c==NULL && quote.Ship_To_Contact__c==NULL && quote.SBQQ__PrimaryContact__c!=NULL &&  !(CurrentDateTime<=createdateTimeOpp)){
                        ContactIdSet.add(quote.SBQQ__PrimaryContact__c);
                        quote.Bill_To_Contact__c        =   quote.SBQQ__PrimaryContact__c;
                        quote.Ship_To_Contact__c        =   quote.SBQQ__PrimaryContact__c;   
                    }else if(quote.Bill_To_Contact__c!=NULL && quote.Is_Open_Opportunity__c == TRUE && oppIdOpptyMap.ContainsKey(quote.SBQQ__Opportunity2__c) && oppIdOpptyMap.get(quote.SBQQ__Opportunity2__c).StageName != OPPTY_SIGNED_ORDER && quote.ApprovalStatus__c != 'Approved' && (oldQuoteMap.get(quote.Id).Bill_To_Contact__c != quote.Bill_To_Contact__c || oldQuoteMap.get(quote.Id).SBQQ__BillingStreet__c != quote.SBQQ__BillingStreet__c || oldQuoteMap.get(quote.Id).SBQQ__BillingCity__c != quote.SBQQ__BillingCity__c || oldQuoteMap.get(quote.Id).SBQQ__BillingState__c != quote.SBQQ__BillingState__c || oldQuoteMap.get(quote.Id).SBQQ__BillingPostalCode__c != quote.SBQQ__BillingPostalCode__c || oldQuoteMap.get(quote.Id).SBQQ__BillingCountry__c != quote.SBQQ__BillingCountry__c)){
                        ContactIdSet.add(quote.Bill_To_Contact__c);
                    }
                    if(quote.Ship_To_Contact__c!=NULL && quote.Is_Open_Opportunity__c == TRUE && oppIdOpptyMap.ContainsKey(quote.SBQQ__Opportunity2__c) && oppIdOpptyMap.get(quote.SBQQ__Opportunity2__c).StageName != OPPTY_SIGNED_ORDER && quote.ApprovalStatus__c != 'Approved' && (oldQuoteMap.get(quote.Id).Ship_To_Contact__c != quote.Ship_To_Contact__c || oldQuoteMap.get(quote.Id).SBQQ__ShippingStreet__c != quote.SBQQ__ShippingStreet__c || oldQuoteMap.get(quote.Id).SBQQ__ShippingCity__c != quote.SBQQ__ShippingCity__c || oldQuoteMap.get(quote.Id).SBQQ__ShippingState__c != quote.SBQQ__ShippingState__c || oldQuoteMap.get(quote.Id).SBQQ__ShippingPostalCode__c != quote.SBQQ__ShippingPostalCode__c || oldQuoteMap.get(quote.Id).SBQQ__ShippingCountry__c != quote.SBQQ__ShippingCountry__c)){
                        ContactIdSet.add(quote.Ship_To_Contact__c);
                    }  
                    if(quote.Ship_To_Contact__c == null && quote.Ship_To_Contact__c != oldQuoteMap.get(quote.Id).Ship_To_Contact__c ){
                        quote.Contact_Name_Toggle_Text__c    = null;
                   }

                   opportunity opp;
                    //Early Renewal -subscription Term
                   
                    if(oppIdOpptyMap.containsKey(quote.SBQQ__Opportunity2__c)){
                        opp= oppIdOpptyMap.get(quote.SBQQ__Opportunity2__c);
                    }
                    system.debug('#############quote.Early_Renewal__c '+quote.Early_Renewal__c);
                    if(opp.type=='Renewal' && opp.SBQQ__RenewedContract__c!=null){
                        if(quote.Early_Renewal__c==TRUE && quote.SBQQ__StartDate__c!=NULL && quote.MKTO_Effective_End_Date__c!=NULL){
              //APPS-19105
                            //quote.SBQQ__SubscriptionTerm__c = quote.SBQQ__StartDate__c.monthsBetween(quote.MKTO_Effective_End_Date__c);
              quote.SBQQ__SubscriptionTerm__c = monthsbetweendates(quote.SBQQ__StartDate__c,quote.MKTO_Effective_End_Date__c);
                            system.debug('quote term ##########'+quote.SBQQ__SubscriptionTerm__c);
              //APPS-19105
                        }
                    }
                    //This is for the only Upsell/Crossell Opportunity Quote
                   if(quote.Previous_Payment_Frequency__c!=null && quote.SBQQ__MasterContract__c!= oldQuoteMap.get(quote.id).SBQQ__MasterContract__c && quote.SBQQ__MasterContract__c !=null){
                      // quote.Payment_Frequency__c = quote.Previous_Payment_Frequency__c;                   
                   }                   
                       /*-------- Code added by Jade from line no 261-270 for ticket APPS-8298-------- */
                       
                   if( quote.Opportunity_Type__c=='Upsell/Crossell' && quote.Rubiks_Quote__c==FALSE && quote.New_Instance_or_Change_to_Existing__c=='Change to Existing Instance' && quote.SBQQ__MasterContract__c!=null && !contractMapForUC.IsEmpty() && contractMapForUC.containsKey(quote.SBQQ__MasterContract__c) && quote.SBQQ__MasterContract__c!= oldQuoteMap.get(quote.id).SBQQ__MasterContract__c ){
                    
                    Contract con=contractMapForUC.get(quote.SBQQ__MasterContract__c);
                                       
                    quote.Payment_Frequency__c=con.Payment_Frequency__c != null ? con.Payment_Frequency__c : quote.Payment_Frequency__c;
                    quote.SBQQ__EndDate__c=con.EndDate;
                                                      
                   }
                   if(quote.SBQQ__StartDate__c != Null && quote.MKTO_Effective_End_Date__c != Null && quote.Opportunity_Type__c=='Upsell/Crossell' && quote.Rubiks_Quote__c==FALSE && quote.New_Instance_or_Change_to_Existing__c=='Change to Existing Instance'){
             //APPS-19105
                        //quote.SBQQ__SubscriptionTerm__c=(quote.SBQQ__StartDate__c.monthsBetween(quote.MKTO_Effective_End_Date__c.addDays(1)));
            quote.SBQQ__SubscriptionTerm__c=monthsbetweendates(quote.SBQQ__StartDate__c,quote.MKTO_Effective_End_Date__c.addDays(1));
            //APPS-19105
                   }
                   /* if(oppIdOpptyMap.containsKey(quote.SBQQ__Opportunity2__c)){
                         opportunity opp = oppIdOpptyMap.get(quote.SBQQ__Opportunity2__c);*/
                         /*if(quote.SBQQ__Type__c == 'Amendment'){
                            quote.Payment_Frequency__c                  = opp.SBQQ__AmendedContract__r.SBQQ__Quote__r.Payment_Frequency__c;
                         }*/
                        if(quote.Payment_Frequency__c != opp.SBQQ__RenewedContract__r.SBQQ__Quote__r.Payment_Frequency__c && opp.Type == 'Renewal' && oldQuoteMap.get(quote.id).Payment_Frequency__c == opp.SBQQ__RenewedContract__r.SBQQ__Quote__r.Payment_Frequency__c){                       
                            //quote.Payment_Frequency__c = opp.SBQQ__RenewedContract__r.SBQQ__Quote__r.Payment_Frequency__c;
                        }
                        //Added by Jade to populate the End dates on New business as well as Renewal Quotes on 9th June 2016
                       /* if( (opp.Type == 'Renewal' || opp.Type == 'New Business') && quote.SBQQ__SubscriptionTerm__c != null && quote.SBQQ__StartDate__c != null) {
                            quote.SBQQ__EndDate__c = quote.SBQQ__StartDate__c.addMonths(Integer.valueOf(quote.SBQQ__SubscriptionTerm__c)).adddays(-1);
                        }*/
                        
                         // Code added by Jade from line no 326-335 on 17th Aug 2016 for ticket CPQ-120
                       /* if( (oldQuoteMap.get(quote.id).Early_Renewal__c != quote.Early_Renewal__c||oldQuoteMap.get(quote.id).SBQQ__Type__c != quote.SBQQ__Type__c ||(oldQuoteMap.get(quote.id).MDQ_Quote__c != quote.MDQ_Quote__c && quote.MDQ_Quote__c == TRUE)  || oldQuoteMap.get(quote.id).SBQQ__StartDate__c!= quote.SBQQ__StartDate__c)){
                                                
                        if((quote.Early_Renewal__c==FALSE && quote.MDQ_Quote__c==True &&  quote.SBQQ__Type__c =='Renewal'&& quote.SBQQ__Opportunity2__r.SBQQ__RenewedContract__c!=''&& opp.SBQQ__RenewedContract__r.EndDate !=null && quote.SBQQ__StartDate__c !=null && opp.SBQQ__RenewedContract__r.EndDate > quote.SBQQ__StartDate__c)){
                                          
                              quote.Early_Renewal__c=TRUE;  
                              QuoteIdSet.add(quote.ID);                       
                        }
                        
                        else if(!QuoteIdSet.contains(quote.id)){ 
                               quote.Early_Renewal__c=false;           
                          }                  
                        }*/
                    //Added SBQQ__LineItemsGrouped__c check as part of phoneix
                    if(quote.Rubiks_Quote__c==FALSE && (opp.SBQQ__RenewedContract__r.SBQQ__Quote__r.Rubiks_Quote__c==TRUE || (opp.SBQQ__AmendedContract__c !=null && opp.SBQQ__AmendedContract__r.SBQQ__Quote__r.Rubiks_Quote__c==true)) && !(SBPB.Phoenix_Price_Books__c.contains(opp.Pricebook2Id))){
                        quote.Rubiks_Quote__c                       = TRUE;
                        
                    }
                    //} 
                   

                    if(quote.SBQQ__Opportunity2__c!= null){
                        oppIds.add(quote.SBQQ__Opportunity2__c);
                    }
                    
                   quotelist.add(quote);
                   if( quote.Payment_Frequency__c!=null && (quote.Payment_Frequency__c!=oldQuoteMap.get(quote.id).Payment_Frequency__c )){ 
                      quotePaymentFrequencylist.add(quote);
                   }
                }//End of FOR loop
                /* *******************************************************************************           
                    Last Modified By : Jade Global Inc, on 6th June 2017
                    Purpose          : 1. If Bill-To and Ship-To contact is blank then populate from its Primary Contact(Quote)
                                       2. Populate Bill to and ship to address from Bill-To and Ship-To contact
                ********************************************************************************* */  
                if(!ContactIdSet.isEmpty()){
                    Map<id,Contact> IdToContactMap=new Map<Id,Contact>([select Id,name,FirstName,LastName,MailingStreet,MailingCity,MailingState, MailingPostalCode,MailingCountry,Email,LastNameLocal,FirstNameLocal FROM contact where Id IN:ContactIdSet]);
                    if(!newQuote.isEmpty()){
                        for(SBQQ__Quote__c quoteObj:newQuote){
                            if(IdToContactMap.containsKey(quoteObj.Bill_To_Contact__c)){
                                Contact ConObj=IdToContactMap.get(quoteObj.Bill_To_Contact__c);
                                system.debug('inside if stmt2='+ConObj.MailingStreet);                   
                                quoteObj.SBQQ__BillingName__c       =   ConObj.name;
                                quoteObj.SBQQ__BillingStreet__c     =   ConObj.MailingStreet;
                                quoteObj.SBQQ__BillingCity__c       =   ConObj.MailingCity;
                                quoteObj.SBQQ__BillingState__c      =   ConObj.MailingState;
                                quoteObj.SBQQ__BillingPostalCode__c =   ConObj.MailingPostalCode;
                                quoteObj.SBQQ__BillingCountry__c    =   ConObj.MailingCountry;
                                quoteObj.Bill_To_Contact_Email__c   =   ConObj.Email;
                                if(quoteObj.Japan_Checkbox__c){
                                    quoteObj.Bill_to_Contact_Name_for_JPN_Order_Form__c=ConObj.LastNameLocal+' ' +ConObj.FirstNameLocal+' '+JPY_BILL_TO_CONTACT_NAME_SALUTATION;
                                }
                            }//End If
                            if(IdToContactMap.containsKey(quoteObj.Ship_To_Contact__c)){
                                Contact ConObj=IdToContactMap.get(quoteObj.Ship_To_Contact__c);
                                quoteObj.SBQQ__ShippingName__c          =   ConObj.name;
                                quoteObj.SBQQ__ShippingStreet__c        =   ConObj.MailingStreet;
                                quoteObj.SBQQ__ShippingCity__c          =   ConObj.MailingCity;
                                quoteObj.SBQQ__ShippingState__c         =   ConObj.MailingState;
                                quoteObj.SBQQ__ShippingPostalCode__c    =   ConObj.MailingPostalCode;
                                quoteObj.SBQQ__ShippingCountry__c       =   ConObj.MailingCountry;
                                
                                 if(ConObj.FirstNameLocal != null &&  ConObj.LastNameLocal != null){
                                       quoteObj.Contact_Name_Toggle_Text__c    =    ConObj.LastNameLocal+ ' ' + ConObj.FirstNameLocal + ' ' +JPY_BILL_TO_CONTACT_NAME_SALUTATION;
                                 }else{
                                       quoteObj.Contact_Name_Toggle_Text__c    =    ConObj.LastName   +' ' + ConObj.FirstName+ ' ' +JPY_BILL_TO_CONTACT_NAME_SALUTATION;
                                 }
                             }//End If
                              if( quoteObj.SBQQ__ShippingCountry__c!=null && (quoteObj.SBQQ__ShippingCountry__c!=oldQuoteMap.get(quoteObj.id).SBQQ__ShippingCountry__c || quoteObj.Country__c == null) ){                      
                                    quoteWithCountryList.add(quoteObj);
                                    system.debug('Inside If statement='+quoteWithCountryList);
                                    countrySet.add(quoteObj.SBQQ__ShippingCountry__c);
                       
                                }//End of IF loop
                                else {
                                    allquoteslist.add(quoteObj);
                                }
                             //*********
                          }//End of For
                    }//End of Is Empty
                  }//End of ContactIdSet
                //************************************************************
       
                if(!quoteWithCountryList.isEmpty()){
                    populateCountryFields(quoteWithCountryList,countrySet,oppIds,oldQuoteMap);
                }
          
                //***************************************
                //Added by Jade Global Inc.
                //Date : 17th Aug 2016
                //Logic to populate the bundle names on Quote in comma seperated fashion for Non MDQ Quotes ONLY
                //JIRA ticket Reference: CPQ-121 : Multi Instance fields for Intacct and SalesOps
                
                //set to get all solution quotes from Trigger.new
                set<id> SolutionQuoteIdsSet = new set<id>();
                
                //map of quote id and it's quote
                map<id,SBQQ__Quote__c> QuoteIdAndQuoteMap = new map<id,SBQQ__Quote__c>();
                
                //Populating the set of all Solution Quotes
                for(SBQQ__Quote__c qt : newQuote){
                    if( qt.Rubiks_Quote__c == TRUE){
                        SolutionQuoteIdsSet.add(qt.id);
                    }//End of IF
                }//End of FOR
    
                if(!SolutionQuoteIdsSet.isEmpty()){
                    //Fetching all Solution quotes along with all Bundle QLIs
                    list<SBQQ__Quote__c> ListOfQuotes = [SELECT id,MDQ_Quote__c,Parent_Bundle_Name__c,Instance_Rollup__c,(SELECT id, SBQQ__RequiredBy__c,Product_Name_Output_Calc__c,SBQQ__Quote__c,Rubiks_Package__c,SBQQ__Bundle__c ,MKTO_Product_Name__c,UR_Product__c FROM SBQQ__LineItems__r WHERE (SBQQ__RequiredBy__c = NULL AND SBQQ__Bundle__c = TRUE AND SBQQ__ProductCode__c LIKE '%BNDL%') OR UR_Product__c=true)  FROM SBQQ__Quote__c WHERE id IN : SolutionQuoteIdsSet];
                    
                    if(!ListOfQuotes.isEmpty()){
                        //Populating the map of Quote id and Quote record
                        for(SBQQ__Quote__c quote : ListOfQuotes){
                            
                            if(!quote.SBQQ__LineItems__r.isEmpty()){
                             quote.Additional_UR_Products__c='';
                                for(SBQQ__QuoteLine__c QLI :quote.SBQQ__LineItems__r){
                                   
                                     if(QLI.UR_Product__c==true){
                                      
                                         quote.Additional_UR_Products__c=quote.Additional_UR_Products__c==''?QLI.MKTO_Product_Name__c:quote.Additional_UR_Products__c+','+QLI.MKTO_Product_Name__c;
                                     }
                                }//End Of FOR
                                if(!QuoteIdAndQuoteMap.containsKey(quote.id)){
                                    QuoteIdAndQuoteMap.put(quote.id,quote);
                                }//End of IF
                            }
                        }//End of FOR
                        
                        for(SBQQ__Quote__c q : ListOfQuotes){
                            //Set to get all unique bundle names present on the QLIs
                            list<String> listBundleNames = new list<String>();
                            //String variable to concatenate all the bundlenames to be populated on Multi-Instance Quote
                            String AllBundlesOnQuote = '';
                            
                            if(!q.SBQQ__LineItems__r.isEmpty()){
                                //Getting all QLIs of the quote in a list
                                list<SBQQ__QuoteLine__c> listRelatedQuoteLines = q.SBQQ__LineItems__r;
                                
                                //Populating set of string with all the unique bundle names from QLI using Rubiks_Package__c field
                                for(SBQQ__QuoteLine__c qtln : listRelatedQuoteLines){
                                    if(qtln.Rubiks_Package__c != NULL  && qtln.SBQQ__Bundle__c == TRUE){
                                        listBundleNames.add(qtln.Rubiks_Package__c);
                                    }//End of IF
                                }//End of FOR
                            }//End of IF
                            //Below IF loop will be executed ONLY IF the quote is Multi-Instance
                            if(q.Instance_Rollup__c > 1){
                                //Formation of comma seperated string
                                if(!listBundleNames.isEmpty()){
                                    for(String s : listBundleNames){
                                        AllBundlesOnQuote += s+',';
                                    }//End of FOR
                                    AllBundlesOnQuote = AllBundlesOnQuote.removeEnd(',');
                                }//End of IF
        
                                //Assigning final concatenated string to Parent_Bundle_Name__c on Quote
                                if(AllBundlesOnQuote != Null){
                                    q.Parent_Bundle_Name__c = AllBundlesOnQuote;
                                }//End of IF
                            }//End Of IF
                            //Else loop will be executed if the quote is not Multi-Instance
                            else{
                                if(!listBundleNames.isEmpty()){
                                    for(string st : listBundleNames){
                                        q.Parent_Bundle_Name__c = st;
                                        break;
                                    }//End of FOR
                                }//End Of IF
                            }//End of ELSE
                        }//End of FOR
                    }//End of IF
                }//End of IF
                
                //Assigning final updated Parent Bundle name on Trigger.new
                for(SBQQ__Quote__c quoteToBeUpdated : newQuote){
                    if(QuoteIdAndQuoteMap.containsKey(quoteToBeUpdated.id)){
                        quoteToBeUpdated.Parent_Bundle_Name__c = QuoteIdAndQuoteMap.get(quoteToBeUpdated.id).Parent_Bundle_Name__c;
                        quoteToBeUpdated.Additional_UR_Products__c =QuoteIdAndQuoteMap.get(quoteToBeUpdated.id).Additional_UR_Products__c ;
                    }//End of IF 
                    
                    System.debug('%%%%%%%%% quoteToBeUpdated.Parent_Bundle_Name__c %%%%%%%%%: '+quoteToBeUpdated.Parent_Bundle_Name__c);
                    
                }//End of FOR

                //****************************************
               
            }//End of Before Update Trigger
            
        }//End of Before trigger
        /***CODE ADDED BY GRAZITTI TO POPULATE INTACCT ENTITY ON OPPORTUNITY:
        - WE MOVED THE METHOD updateOpportunity(), LINE NO. 40, 75,  FROM BEFORE TRIGGER TO AFTER TRIGGER BECAUSE WE ARE UPDATING ANOTHER OBJECT INSTEAD OF OBJECT ON WHICH TRIGGER IS EXECUTING.
        - WE NEED TO POPULATE INTACT ENTITY ALSO ON OPPORTUNITY WHEN QUOTE IS MADE PRIMARY 
        **/
        else{
            if(trigger.isInsert) {
                Map<Id,Opportunity> targetOpportunitiesMap = new Map<Id,Opportunity>();
                List<SBQQ__Quote__c> renewalQuotelist = new List<SBQQ__Quote__c>();
                Set<Id> opptyIds = new Set<Id>();
                List<SBQQ__Quote__c> quotesWithIntacctInfo = new List<SBQQ__Quote__c>();
                
                for(SBQQ__Quote__c quote: newQuote) {
                    if(quote.SBQQ__Opportunity2__c!= null) {
                        oppIds.add(quote.SBQQ__Opportunity2__c);
                    }
                    if(quote.Opportunity_Type__c=='Renewal') {
                          RenewalQuotelist.add(quote);
                    }
                    if(quote.SBQQ__Primary__c == True && quote.SBQQ__ShippingCountry__c != null){
                        IS_Intacct_Entity_Updated_On_Opportunity = true;
                        quotesWithIntacctInfo.add(quote);
                    }
                }
                if(!targetOpportunitiesMap.isEmpty()){
                    targetOpportunitiesMap.putAll(updateOpportunityFieldUpdate(targetOpportunitiesMap,newQuote,null));
                }
                else if(!newQuote.isEmpty()){
                   
                    for(SBQQ__Quote__c quote: newQuote){
                        if(quote.SBQQ__Opportunity2__c!=null){
                            OpportunityUpdateMap.put(quote.SBQQ__Opportunity2__c,new Opportunity(id=quote.SBQQ__Opportunity2__c));
                        }
                    }
                    targetOpportunitiesMap.putAll(updateOpportunityFieldUpdate(OpportunityUpdateMap,newQuote,null));
                }
                
                if(!quotesWithIntacctInfo.isEmpty()){
                    targetOpportunitiesMap.putAll(SBQQ_OpportunityFieldsUpdate(quotesWithIntacctInfo,targetOpportunitiesMap));
                }

                if(!targetOpportunitiesMap.isEmpty()){
                    if(!IS_OPPTY_UPDATED_AfterInsert){
                        IS_OPPTY_UPDATED_AfterInsert = true;
                        update targetOpportunitiesMap.values();
                    }
                }  
            }else if(trigger.isUpdate) {                   
                Map<Id,Opportunity> targetOpportunitiesMap = new Map<Id,Opportunity>();
                List<SBQQ__Quote__c> quotePaymentFrequencylist = new List<SBQQ__Quote__c>();
                Set<Id> opptyIds = new Set<Id>();
                List<SBQQ__Quote__c> quotesWithIntacctInfo = new List<SBQQ__Quote__c>();
                //This is used to store the NB Opportunity id  created by Steelbrick for Amend 
                id AmendDeleteMeOpptyId = null;
                for(SBQQ__Quote__c quote: newQuote) {
                    if( quote.Payment_Frequency__c!=null && (quote.Payment_Frequency__c!=oldQuoteMap.get(quote.id).Payment_Frequency__c )){ 
                         quotePaymentFrequencylist.add(quote);
                    }
                    if(quote.SBQQ__Opportunity2__c!= null){
                        opptyIds.add(quote.SBQQ__Opportunity2__c);
                    }
                    
                    if(quote.SBQQ__Primary__c &&(!(oldQuoteMap.get(quote.Id).SBQQ__Primary__c) || (quote.SBQQ__ShippingCountry__c != null && quote.SBQQ__ShippingCountry__c != oldQuoteMap.get(quote.Id).SBQQ__ShippingCountry__c) || (quote.SBQQ__Opportunity2__c != null && quote.SBQQ__Opportunity2__c != oldQuoteMap.get(quote.Id).SBQQ__Opportunity2__c) || (quote.Country__c != null && quote.Country__c != oldQuoteMap.get(quote.Id).Country__c))){
                        IS_Intacct_Entity_Updated_On_Opportunity = true;
                        IS_OPPTY_UPDATED_Afterupdate = false;
                        quotesWithIntacctInfo.add(quote);
                    }
                    if(quote.AmendNewBusinessOpportunityId__c!=null){
                        AmendDeleteMeOpptyId = quote.AmendNewBusinessOpportunityId__c;
                    }
                }
                
                if(!quotePaymentFrequencylist.isEmpty()) {
                   // targetOpportunitiesMap.putAll(updateOpportunity(quotePaymentFrequencylist,opptyIds,targetOpportunitiesMap));
                }  
                if(!targetOpportunitiesMap.isEmpty()){
                    targetOpportunitiesMap.putAll(updateOpportunityFieldUpdate(targetOpportunitiesMap,newQuote,oldQuoteMap));
                }
                else{
                    for(SBQQ__Quote__c quote: newQuote){
                        if(quote.SBQQ__Opportunity2__c!=null){
                        OpportunityUpdateMap.put(quote.SBQQ__Opportunity2__c,new Opportunity(id=quote.SBQQ__Opportunity2__c));
                        }
                    }
                    targetOpportunitiesMap.putAll(updateOpportunityFieldUpdate(OpportunityUpdateMap,newQuote,oldQuoteMap));
                }
                
                if(!quotesWithIntacctInfo.isEmpty()) {
                    targetOpportunitiesMap.putAll(SBQQ_OpportunityFieldsUpdate(quotesWithIntacctInfo,targetOpportunitiesMap));
                }
                if(!targetOpportunitiesMap.isEmpty()){
                    if(!IS_OPPTY_UPDATED_Afterupdate){
                        IS_OPPTY_UPDATED_Afterupdate = true;
                        if(AmendDeleteMeOpptyId!=null &&targetOpportunitiesMap.containsKey(AmendDeleteMeOpptyId)){
                            targetOpportunitiesMap.remove(AmendDeleteMeOpptyId);
                        }
                       update targetOpportunitiesMap.values();
                    }
                } 
                
             }
             
             else if(trigger.isDelete){
         
                    set<id> Oppidset = new set<id>();
                    for(SBQQ__Quote__c quote: oldQuoteMap.values()){
                         if(quote.SBQQ__Opportunity2__c!= null){
                              Oppidset.add(quote.SBQQ__Opportunity2__c);  
                          }//End of IF  
                    }//End of FOR
                    if(!Oppidset.isEmpty()){
                        list<OpportunityLineItem> OLIList = [SELECT id FROM  OpportunityLineItem WHERE Opportunityid IN :Oppidset AND Opportunity.Type =: Label.OPPORTUNITY_TYPE_RENEWAL];
                        
                        if(!OLIList.isEmpty()){                        
                            update OLIList;
                        }//End of IF
                    }//End of IF
            }//End of DELETE trigger
                     
        }

    }//End of Method QuoteTriggerHandler
    
    public static void populateCountryFields(list<SBQQ__Quote__c> quoteCountryList,set<string> countryNameSet,set<id> oppIdSet , Map<Id,SBQQ__Quote__c> oldMap){
       map<string ,Country__c> CountryMap = new map<string,Country__c>();
       
       map<id,opportunity> oppMap         = getOpportunityMap(oppIdSet);
       /*map<id,opportunity> oppMap         = new map<id,opportunity>([SELECT id,name,Accountid,Account.Type,Account.ABN_No__c,Account.Registered_VAT_No__c,Account.ShippingCountry FROM Opportunity WHERE id IN : oppIdSet ]);
       */
      // map<id,Account> AccountMap         = new map<id,Account>([SELECT id,ABN_No__c,Registered_VAT_No__c,ShippingCountry FROM Account WHERE id IN : AccIdSet /*AND (ABN_No__c=null OR Registered_VAT_No__c=null)*/]);
       list<Account> updateAccount        = new list<account>();
       set<id> updatedAccIds              = new set<id>();
       //This is used to update the Quote and Account fields(ABN_No__c,Registered_VAT_No__c) only region which are present in set. 
       set<string> regionSet              = new set<string>{'Australia','European Union'};
       
       if(IS_ACCOUNT_UPDATED ==false){    
           for(Country__c Country  :[SELECT  id,
                                             name,
                                             Marketo_Entity__c,
                                             Region__c,
                                             Signature__c,
                                             VAT_GST_Total__c
                                     FROM Country__c 
                                     /*WHERE name IN :countryNameSet*/]){
               CountryMap.put( Country.name.toLowerCase(),Country);
           }//End of FOR loop
        
        }
        for(SBQQ__Quote__c quote :quoteCountryList){
            string country = quote.SBQQ__ShippingCountry__c;
            
            
         
           
            if(country !=null && CountryMap.containsKey(country.toLowerCase())){
                Country__c con                            = CountryMap.get(country.toLowerCase());
                quote.Country__c                          = con.id;
                quote.Signature__c                        = con.Signature__c;
                opportunity  opp;
               
                if(quote.SBQQ__Opportunity2__c!= null  && oppMap.containsKey(quote.SBQQ__Opportunity2__c)){
                     opp = oppMap.get(quote.SBQQ__Opportunity2__c);
                  
                    if( regionSet.contains( quote.Region__c ) && opp.accountid!=null && oppMap.containsKey(opp.id) && !updatedAccIds.contains(opp.accountid)){
                        Account acc;
                        
              
                            acc = new account(id = opp.accountid);
                     
                        
                        boolean accUpdateFlag = false;
                        if(opp.account.ABN_No__c== null &&  quote.ABN_No__c!=Null){
                            acc.ABN_No__c = quote.ABN_No__c;
                            accUpdateFlag = true;
                        }//End of IF 
                        else if(opp.account.ABN_No__c!= null    &&  quote.ABN_No__c==Null){
                            quote.ABN_No__c = opp.account.ABN_No__c;
                        }//End of ELSE IF
                        if(opp.account.Registered_VAT_No__c== null  && quote.Registered_VAT_No__C!=null ){
                            opp.account.Registered_VAT_No__c = quote.Registered_VAT_No__c;
                            accUpdateFlag                    = true;
                        }//End of IF 
                        else if(opp.account.Registered_VAT_No__c!= null && quote.Registered_VAT_No__C==null ){
                            quote.Registered_VAT_No__c =  opp.account.Registered_VAT_No__c;
                        }//End of ELSE IF 
                        if(accUpdateFlag == True){
                            updatedAccIds.add(opp.accountid);
                            updateAccount.add(acc);
                        }//End of IF 
                }//End of IF Region  
                }
                
            }//End of IF loop
                   
        }//End of FOR loop

        if(!updateAccount.isEmpty()){
            IS_ACCOUNT_UPDATED = true;
            update updateAccount;
        }//End of IF loop
        
    }//End of Mehtod populateCountryFields
     
    


     //BELOW METHOD POPULATE THE INTACCT SALES REGION AND INTACCT ENTITY ON OPPORTUNITY RECORD --BY GRAZITTI
    public static Map<Id,Opportunity> SBQQ_OpportunityFieldsUpdate(list<SBQQ__Quote__c> SBQQ_QuoteList, Map<Id,Opportunity> cacheOpptyMap){
    
        Set<Id> countryIds                             = new Set<Id>();
        Set<string> countryName                             = new Set<string>();
        Set<string> intactEntity                            = new Set<string>();
        List<Opportunity> updateOpptyList                   = new List<Opportunity>();
        Map<String,String> countryIntacctSalesRegionMap     = new Map<String,String>();
        Map<Id,String> countryIdsIntacctEntityMap          = new Map<Id,String>();
        Map<String,String> countryIntacctEntityMap          = new Map<String,String>();
        Map<String,ID> InctId                               = new Map<String,ID>();    
        
        for(SBQQ__Quote__c sbq : SBQQ_QuoteList){
            
            if(sbq.Country__c != null){
                countryIds.add(sbq.Country__c);
            }else if(sbq.SBQQ__ShippingCountry__c != null){
                countryName.add(sbq.SBQQ__ShippingCountry__c.toLowerCase());
            }
        }
        if(!countryName.isEmpty() || !countryIds.isEmpty()){        
            for(Country__c cntry : [Select Id, Name, Intacct_Entity__c , Intacct_Sales_Region__c from Country__c where ID IN:countryIds OR Name IN : countryName]){
                    countryIntacctSalesRegionMap.put(cntry.Name.toLowerCase() , cntry.Intacct_Sales_Region__c);
                    countryIdsIntacctEntityMap.put(cntry.Id,cntry.Intacct_Entity__c );
                    countryIntacctEntityMap.put(cntry.Name.toLowerCase(),cntry.Intacct_Entity__c);
                    intactEntity.add(cntry.Intacct_Entity__c);
                
            }
            if(!intactEntity.isEmpty()){
                for(Intacct_Entity__c intacten : [SELECT Id, Name from Intacct_Entity__c where Name IN : intactEntity]){
                    InctId.put(intacten.Name.toLowerCase() ,intacten.Id);    
                }
            }
        }
        for(SBQQ__Quote__c qoo: SBQQ_QuoteList){
            if(qoo.SBQQ__Opportunity2__c != null){
                Opportunity op;
                if(!cacheOpptyMap.isEmpty() && cacheOpptyMap.containsKey(qoo.SBQQ__Opportunity2__c)){
                    op = cacheOpptyMap.get(qoo.SBQQ__Opportunity2__c);
                }else{
                    op = new Opportunity(Id = qoo.SBQQ__Opportunity2__c);
                }
                op.Payment_Frequency__c = qoo.Payment_Frequency__c;
                op.Payment_Terms__c = qoo.SBQQ__PaymentTerms__c;
                if(countryIdsIntacctEntityMap.containsKey(qoo.Country__c)){
                    if(InctId.containsKey(countryIdsIntacctEntityMap.get(qoo.Country__c))){
                        op.Intacct_Entity__c = InctId.get(countryIdsIntacctEntityMap.get(qoo.Country__c));
                    }
                }
                else if(qoo.SBQQ__ShippingCountry__c !=null && countryIntacctEntityMap.containsKey(qoo.SBQQ__ShippingCountry__c.toLowerCase())){
                    if(InctId.containsKey(countryIntacctEntityMap.get(qoo.SBQQ__ShippingCountry__c.toLowerCase()))){
                        op.Intacct_Entity__c = InctId.get(countryIntacctEntityMap.get(qoo.SBQQ__ShippingCountry__c.toLowerCase()));
                    } 
                }
                if(qoo.SBQQ__ShippingCountry__c != null && countryIntacctSalesRegionMap.containsKey(qoo.SBQQ__ShippingCountry__c.toLowerCase())){
                    op.Intacct_Sales_Region__c = countryIntacctSalesRegionMap.get(qoo.SBQQ__ShippingCountry__c.toLowerCase());
                }
                cacheOpptyMap.put(op.Id,op);
            }
        }        
        return cacheOpptyMap;
    }//END OF METHOD
    

    
        /******************************************************
    * This is used to Update the opportunity fields.
    * 1.Promotional_End_Date__c
    * 2.Sub_Start_Date__c
    * 3.Sub_End_Date__c
    * 4.Maximum_Database_Size__c
    * 5.Project_Classification__c
    * 6.Payment_Frequency__c
    * 7.Payment_Terms__c
    *******************************************************/
    public static Map<Id,Opportunity> updateOpportunityFieldUpdate(map<id,Opportunity> OpptyMap,list<SBQQ__Quote__c> newquotes,map<id,SBQQ__Quote__c> OldQuoteMap){
         boolean UpdateFlag = false;
         List<Opportunity> oppsList = new List<Opportunity>();
        /*---------------------------------------------------------
         * Modified by : Jade on Jan 16th 2016
         * Updated code to avoid duplicate Opportunity record in list
         * Added new set of Opportunity id
         * --------------------------------------------------------*/   

         for(SBQQ__Quote__c SBQuote: newquotes){
              if(SBQuote.SBQQ__Opportunity2__c != null){
                Opportunity opp = OpptyMap.get(SBQuote.SBQQ__Opportunity2__c);  
                
                  // To populate the Promotional_End_Date__c on Opportunity
                 if(SBQuote.Promotional_End_Date__c!=null && SBQuote.SBQQ__Primary__c==True &&( (Trigger.isInsert ||(Trigger.isUpdate &&( OldQuoteMap.get(SBQuote.id).New_Logo_Term_Promotions__c!=SBQuote.New_Logo_Term_Promotions__c || OldQuoteMap.get(SBQuote.id).SBQQ__StartDate__c!=SBQuote.SBQQ__StartDate__c )|| (SBQuote.SBQQ__Primary__c!=OldQuoteMap.get(SBQuote.id).SBQQ__Primary__c))))){
                     opp.Promotional_End_Date__c = SBQuote.Promotional_End_Date__c;
                 }//End of if loop of update of Promotional_End_Date__c
                 
                 // To populate the Sub_End_Date__c on Opportunity
                  if(SBQuote.SBQQ__StartDate__c!=null && SBQuote.SBQQ__Primary__c==True &&( (Trigger.isInsert ||(Trigger.isUpdate && ((OldQuoteMap.get(SBQuote.id).SBQQ__StartDate__c!=SBQuote.SBQQ__StartDate__c) || (opp.Sub_End_Date__c == null)/*|| (SBQuote.SBQQ__Primary__c!=OldQuoteMap.get(SBQuote.id).SBQQ__Primary__c)*/))))){
                     opp.Sub_Start_Date__c = SBQuote.SBQQ__StartDate__c;
                     if(SBQuote.SBQQ__SubscriptionTerm__c!=null && SBQuote.SBQQ__Type__c!='Amendment'){
                        opp.Sub_End_Date__c = SBQuote.SBQQ__StartDate__c.addMonths(Integer.valueOf(SBQuote.SBQQ__SubscriptionTerm__c)).adddays(-1);
                     }
                 }//End of if loop of update of Sub_End_Date__c
                  // To populate the Maximum_Database_Size__c on Opportunity - This should work for Feature Quote only
                 if(SBQuote.Rubiks_Quote__c == False && SBQuote.Required_Max_Contact_Records__c!=null && SBQuote.SBQQ__Primary__c==True && ((Trigger.isInsert ||(Trigger.isUpdate && OldQuoteMap.get(SBQuote.id).Required_Max_Contact_Records__c!=SBQuote.Required_Max_Contact_Records__c)/*|| ((SBQuote.SBQQ__Primary__c!=OldQuoteMap.get(SBQuote.id).SBQQ__Primary__c))*/))){
                     opp.Maximum_Database_Size__c  = SBQuote.Required_Max_Contact_Records__c; 
                 }//End of if loop of update of Maximum_Database_Size__c on Opportunity
                 
				 //Commented as per APPS-20840
                 // To populate the Project_Classification__c on Opportunity
                 /*if(SBQuote.SOW_Special_Terms__c!=null && SBQuote.SBQQ__Primary__c==True &&( (Trigger.isInsert ||(Trigger.isUpdate && OldQuoteMap.get(SBQuote.id).SOW_Special_Terms__c!=SBQuote.SOW_Special_Terms__c  ) ))){
                     opp.Project_Classification__c  = 'C';      
                 }*///End of if loop of update of Project_Classification__c on Opportunity
                 
                 // Check Billing Frequency on Opp, get it from SB Quote
                 if(SBQuote.Payment_Frequency__c != null){
                    opp.Payment_Frequency__c = SBQuote.Payment_Frequency__c;
                 }
                 
                 // Check SBQQ__PaymentTerms__c on opp, get it from quote.
                 if(SBQuote.SBQQ__PaymentTerms__c != null){
                    opp.Payment_Terms__c = SBQuote.SBQQ__PaymentTerms__c;
                 }
                 
                 //Added By Jade For Amends Decomissioning
                 //Date: 20th Oct 2016
                 if(SBQuote.SBQQ__Type__c == 'Amendment'){
                    opp.Sub_End_Date__c = SBQuote.MKTO_Effective_End_Date__c != null ? SBQuote.MKTO_Effective_End_Date__c : opp.Sub_End_Date__c;
                    
                    opp.Promotional_End_Date__c = SBQuote.Promotional_End_Date__c != null ? SBQuote.Promotional_End_Date__c : opp.Promotional_End_Date__c;
                    
                 }
                 
                 OpptyMap.put(opp.Id, opp);

             }//End of Opportunity IF Block                 
         }//End of FOR loop 
         return OpptyMap;
    }//End of method updateOpportunityFieldUpdate

       
   

   
    public static Map<Id,Opportunity> OpptyMap;
    public static Map<Id,Opportunity> getOpportunityMap(Set<Id> oppIdSet){
        if(OpptyMap == null || OpptyMap.isEmpty()){
            return  OpptyMap = new map<id,opportunity>([SELECT id,name,Accountid,Account.Type,Account.ABN_No__c,Account.Registered_VAT_No__c,Account.ShippingCountry FROM Opportunity WHERE id IN : oppIdSet ]);
        }
        return OpptyMap;
    }


    
    // Method to populate current quote fields from previous quote - Logic is added for Renewal and Upsell/Crossell Opportunities
    public static void populateNewQuoteFieldsFromPrevQuote(List<SBQQ__Quote__c> newQuotesList, Map<Id,Opportunity> opportunityMap){
        // SteelBrick PB Id
        SteelBrickCPQPricebook__c SBPB = SteelBrickCPQPricebook__c.getOrgDefaults();
        Set<Id> priorOppIdSBSet = new Set<Id>();
        Set<Id> priorOppIdLegacySet = new Set<Id>();
        
        for(Opportunity opp: opportunityMap.values()){     
            if(opp.Prior_Opportunity__c != null && (opp.Type == 'Renewal' || opp.Type == 'Upsell/Crossell') && opp.Prior_Opportunity__r.Pricebook2Id == SBPB.ID__c){
                priorOppIdSBSet.add(opp.Prior_Opportunity__c);
            }
            else if(opp.Prior_Opportunity__c != null && (opp.Type == 'Renewal' || opp.Type == 'Upsell/Crossell')){
                priorOppIdLegacySet.add(opp.Prior_Opportunity__c);
            }
        }//End of FOR loop
        
        // Get previous quote
        Map<Id,SBQQ__Quote__c> priorOppIdQuoteMap = new Map<Id,SBQQ__Quote__c>();
        Map<Id,Quote> priorOppIdStdQuoteMap = new Map<Id,Quote>();
        if(!priorOppIdSBSet.isEmpty()){
            for(SBQQ__Quote__c quot :[Select Id, SBQQ__Opportunity2__r.Account.Custom_EUSA__c, SBQQ__Opportunity2__r.Maximum_Database_Size__c, Press_Release_Permission__c, PO_Number__c, SBQQ__Opportunity2__r.Type, SBQQ__Opportunity2__r.Prior_Opportunity__c, SBQQ__Opportunity2__r.Pricebook2Id, SBQQ__Opportunity2__c, Payment_Frequency__c, SBQQ__Opportunity2__r.Account.PO_Required__c,  SBQQ__Opportunity2__r.Account.ABN_No__c, SBQQ__Opportunity2__r.Account.Registered_VAT_No__c, SBQQ__Primary__c, Marketing_Permission__c, Case_Study_Permission__c, Custom_Agreement_Name_and_Date__c, SBQQ__PaymentTerms__c, Hide_Discount__c, Enterprise_Roll_up_SKU__c, Renewal_Uplift_pct__c, Renewal_Uplift_Text__c,Blended_Discount__c From SBQQ__Quote__c where SBQQ__Opportunity2__c IN :priorOppIdSBSet and SBQQ__Primary__c = true]){
                priorOppIdQuoteMap.put(quot.SBQQ__Opportunity2__c, quot);
            }
        }else{
            for(Quote thisQuote :[Select Id, Opportunity.Account.Custom_EUSA__c, Opportunity.Maximum_Database_Size__c, Opportunity.Account.Registered_VAT_No__c, Opportunity.Type, Opportunity.Prior_Opportunity__c, Opportunity.Pricebook2Id, Opportunity.Account.PO_Required__c, Opportunity.Account.ABN_No__c, Opportunity.Renewal_Uplift_Text__c, Opportunity.Enterprise_Roll_up_SKU__c, Opportunity.Hide_Discount__c, PO__c, Increase_Language__c, IsSyncing, Opportunity.Custom_Agreement_Name_and_Date__c, OpportunityId, Payment_Frequency__c, Customer_gives_Marketing_Permission__c, Case_Study_Permission__c, Payment_Terms__c,Blended_Discount__c from Quote where OpportunityId IN :priorOppIdLegacySet and IsSyncing = true]){
                priorOppIdStdQuoteMap.put(thisQuote.OpportunityId, thisQuote);
            }
        }
        
        // Map new quote fields with prev quote fields.
        for(SBQQ__Quote__c newquote: newQuotesList){
            if(opportunityMap.containsKey(newquote.SBQQ__Opportunity2__c) && (opportunityMap.get(newquote.SBQQ__Opportunity2__c).Type == 'Renewal' || opportunityMap.get(newquote.SBQQ__Opportunity2__c).Type == 'Upsell/Crossell') && opportunityMap.get(newquote.SBQQ__Opportunity2__c).Prior_Opportunity__c != null){
                if(opportunityMap.get(newquote.SBQQ__Opportunity2__c).Pricebook2Id == SBPB.ID__c && priorOppIdQuoteMap.containsKey(opportunityMap.get(newquote.SBQQ__Opportunity2__c).Prior_Opportunity__c)){
                    // If SteelBrick Opportunity - Quote Fields
                    SBQQ__Quote__c priorQuote = priorOppIdQuoteMap.get(opportunityMap.get(newquote.SBQQ__Opportunity2__c).Prior_Opportunity__c);
                    //newquote.SBQQ__Opportunity2__r.Pricebook2Id = SBPB.ID__c;
                    newquote.Marketing_Permission__c = priorQuote.Marketing_Permission__c != null? priorQuote.Marketing_Permission__c : null;
                    newquote.Case_Study_Permission__c = priorQuote.Case_Study_Permission__c != null ? priorQuote.Case_Study_Permission__c : null;
                    newquote.Custom_Agreement_Name_and_Date__c = priorQuote.Custom_Agreement_Name_and_Date__c != null ? priorQuote.Custom_Agreement_Name_and_Date__c : null;
                    newquote.SBQQ__PaymentTerms__c = priorQuote.SBQQ__PaymentTerms__c != null ? priorQuote.SBQQ__PaymentTerms__c : null;
                    
                    //To make sure system validation rules are addressed for Services Only and Custom SOW Quotes - APPS - 5651
                    if(newquote.SBQQ__Opportunity2__r.Type == 'Upsell/Crossell' && newquote.Order_Type__c != 'Services Only' && newquote.Order_Type__c != 'Custom SOW')
                    {
                        newquote.Payment_Frequency__c = priorQuote.Payment_Frequency__c != null ? priorQuote.Payment_Frequency__c : null;
                    }
                    newquote.Hide_Discount__c = priorQuote.Hide_Discount__c != null ? priorQuote.Hide_Discount__c : null;
                   /* newquote.Enterprise_Roll_up_SKU__c = priorQuote.Enterprise_Roll_up_SKU__c != null ? priorQuote.Enterprise_Roll_up_SKU__c : null;*/
                   
                   // Code added by Jade
                   
                   if(!(newquote.SBQQ__Opportunity2__r.Prior_Opportunity__r.SBQQ__PrimaryQuote__r.Rubiks_Quote__c==false && newquote.Rubiks_Quote__c==true)){
                        newquote.Enterprise_Roll_up_SKU__c = priorQuote.Enterprise_Roll_up_SKU__c != null ? priorQuote.Enterprise_Roll_up_SKU__c : null;
                    }
                    
                    // Carry Previous_Renewal_Uplift__c from Renewal_Uplift_pct__c as well
                    newquote.Renewal_Uplift_pct__c = priorQuote.Renewal_Uplift_pct__c != null ? priorQuote.Renewal_Uplift_pct__c : null;
                    if((opportunityMap.get(newquote.SBQQ__Opportunity2__c).Type == 'Renewal')){
                        newquote.Previous_Renewal_Uplift__c = priorQuote.Renewal_Uplift_pct__c != null ? priorQuote.Renewal_Uplift_pct__c : null;
                    }                   
                    
                    newquote.Renewal_Uplift_Text__c = priorQuote.Renewal_Uplift_Text__c != null ? priorQuote.Renewal_Uplift_Text__c : null;
                    newquote.PO_Number__c = priorQuote.PO_Number__c != null ? priorQuote.PO_Number__c : null;
                    newquote.Press_Release_Permission__c = priorQuote.Press_Release_Permission__c;
                    
                    if(newquote.SBQQ__Opportunity2__r.Type == 'Upsell/Crossell' && newquote.Rubiks_Quote__c == FALSE ){
                        newquote.Target_Number_of_Contact_Records__c = priorQuote.SBQQ__Opportunity2__r.Maximum_Database_Size__c;
                    }
                        
                    // Fields coming from Account
                    newquote.New_Custom_EUSA_Attached__c = priorQuote.SBQQ__Opportunity2__r.Account.Custom_EUSA__c;
                    newquote.PO_Required__c = priorQuote.SBQQ__Opportunity2__r.Account.PO_Required__c == true ? true : false;
                    newquote.ABN_No__c = priorQuote.SBQQ__Opportunity2__r.Account.ABN_No__c != null ? priorQuote.SBQQ__Opportunity2__r.Account.ABN_No__c : null;
                    newquote.Registered_VAT_No__c = priorQuote.SBQQ__Opportunity2__r.Account.Registered_VAT_No__c != null ? priorQuote.SBQQ__Opportunity2__r.Account.Registered_VAT_No__c : null;

                                             
                }else if(opportunityMap.containsKey(newquote.SBQQ__Opportunity2__c) && (opportunityMap.get(newquote.SBQQ__Opportunity2__c).Type == 'Renewal' || opportunityMap.get(newquote.SBQQ__Opportunity2__c).Type == 'Upsell/Crossell') && opportunityMap.get(newquote.SBQQ__Opportunity2__c).Prior_Opportunity__c != null){
                    // Legacy Opportunity
                    if(!priorOppIdStdQuoteMap.isEmpty() && priorOppIdStdQuoteMap.containsKey(opportunityMap.get(newquote.SBQQ__Opportunity2__c).Prior_Opportunity__c)){
                        Quote priorQuote = priorOppIdStdQuoteMap.get(opportunityMap.get(newquote.SBQQ__Opportunity2__c).Prior_Opportunity__c);
                        newquote.Marketing_Permission__c = priorQuote.Customer_gives_Marketing_Permission__c != null? priorQuote.Customer_gives_Marketing_Permission__c : null;
                        newquote.Case_Study_Permission__c = priorQuote.Case_Study_Permission__c != null ? priorQuote.Case_Study_Permission__c : null;
                        newquote.Custom_Agreement_Name_and_Date__c = priorQuote.Opportunity.Custom_Agreement_Name_and_Date__c != null ? priorQuote.Opportunity.Custom_Agreement_Name_and_Date__c : null;
                        newquote.SBQQ__PaymentTerms__c = priorQuote.Payment_Terms__c != null ? priorQuote.Payment_Terms__c : null;
                        //To make sure system validation rules are addressed for Services Only and Custom SOW Quotes - APPS - 5651
                        if(newquote.SBQQ__Opportunity2__r.Type == 'Upsell/Crossell' && newquote.Order_Type__c != 'Services Only' && newquote.Order_Type__c != 'Custom SOW')
                        {
                            newquote.Payment_Frequency__c = priorQuote.Payment_Frequency__c != null ? priorQuote.Payment_Frequency__c : null;
                        }
                        newquote.Hide_Discount__c = priorQuote.Opportunity.Hide_Discount__c != null ? priorQuote.Opportunity.Hide_Discount__c : null;
                       /* newquote.Enterprise_Roll_up_SKU__c = priorQuote.Opportunity.Enterprise_Roll_up_SKU__c != null ? priorQuote.Opportunity.Enterprise_Roll_up_SKU__c : null;*/
                       
                        if( newquote.Rubiks_Quote__c==false){
                                                            newquote.Enterprise_Roll_up_SKU__c = priorQuote.Opportunity.Enterprise_Roll_up_SKU__c != null ? priorQuote.Opportunity.Enterprise_Roll_up_SKU__c : null;
                        }
                        
                        // APPS-6165
                        // Carry Previous_Renewal_Uplift__c from Increase_Language__c as well
                        Integer perInte = 0;
                        if(priorQuote.Increase_Language__c != null){
                            String s1 = priorQuote.Increase_Language__c;
                            perInte = Integer.valueOf(s1.substring(Integer.valueOf(s1.indexOf('%')) - 1,Integer.valueOf(s1.indexOf('%'))));
                            newquote.Renewal_Uplift_pct__c = String.valueOf(perInte);
                            newquote.Previous_Renewal_Uplift__c = priorQuote.Increase_Language__c;
                        }else if((opportunityMap.get(newquote.SBQQ__Opportunity2__c).Type == 'Renewal')){
                            newquote.Renewal_Uplift_pct__c = '8';
                        }else{
                            newquote.Renewal_Uplift_pct__c = null;
                        }
                        
                        newquote.PO_Number__c = priorQuote.PO__c != null ? priorQuote.PO__c : null;
                        if(opportunityMap.get(newquote.SBQQ__Opportunity2__c).Type == 'Upsell/Crossell' && newquote.Rubiks_Quote__c == FALSE ){
                           newquote.Target_Number_of_Contact_Records__c = priorQuote.Opportunity.Maximum_Database_Size__c;
                        }           
                        newQuote.Press_Release_Permission__c = priorQuote.Customer_gives_Marketing_Permission__c;
                        
                        // Fields coming from Account
                        newquote.New_Custom_EUSA_Attached__c = priorQuote.Opportunity.Account.Custom_EUSA__c;
                        newquote.PO_Required__c = priorQuote.Opportunity.Account.PO_Required__c == true ? true : false;
                        newquote.ABN_No__c = priorQuote.Opportunity.Account.ABN_No__c != null ? priorQuote.Opportunity.Account.ABN_No__c : null;
                        newquote.Registered_VAT_No__c = priorQuote.Opportunity.Account.Registered_VAT_No__c != null ? priorQuote.Opportunity.Account.Registered_VAT_No__c : null;
                    }
                }
            }
        }
    } // End of mtd populateNewQuoteFieldsFromPrevQuote
     //APPS-19105
    Public static integer monthsbetweendates(date startdate, date enddate){ 
        Decimal MonthsSideways=((decimal)(date.daysInMonth(startdate.year(), startdate.month())-startdate.day())/date.daysInMonth(startdate.year(),startdate.month()))+((decimal)(enddate.day()-1)/date.daysInMonth(enddate.year(),enddate.month()));
        decimal monthbetw=date.newinstance(startdate.year(),startdate.month()+1,1).monthsbetween(date.newinstance(enddate.year(),enddate.month(),1));
        decimal monthsexact = MonthsSideways+monthbetw;
        if((monthsexact-Math.floor(monthsexact)) > 0 && (monthsexact-Math.floor(monthsexact))>0.5){
            return ((integer)Math.ceil(monthsexact));
        }
        else if((monthsexact-Math.floor(monthsexact)) > 0 && (monthsexact-Math.floor(monthsexact))<=0.5){
            return ((integer)Math.floor(monthsexact));
        }
        else{
            return (integer)monthsexact;
        }
    }
    //APPS-19105
}//End of Class