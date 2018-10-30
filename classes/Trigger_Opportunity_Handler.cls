/************************************************************************
 # Modified By grazitti interactive on 21/8/18
 # APPS-22357 - Update Account From customer to Ex-customer 
 # Date : (20-sep-2018)   
 # Trace the changes by seaching the ticket no 
********************************************************
By :- Aman gupta 11-8-18
 Commented OpportunityAPORCalcOnRNWLUpdate as per the ticket # Apps 20840
***************************************************************************

Updated by: Jade Global Inc.
Updated On: 4th June 2017
Updated for: 
# Reference: Added Code for SDR owner Functinality
# Jira Ticket: APPS-13173: Tasks in the Requirement document for Sprint 4

 * Last Modified By   : Tushar Misri,Grazitti 
  * Last Modified Date : 16th March, 2018
  * Purpose            : APPS-17919, removing the cross object formula's 
  
   Modified by Sumit Bhatt 19-March-18 
       * APPS-17919 - Decommission Cross object formula fields that are not used on Opp Merge three workflow
       * One can find the usage by searching the ticket number in code
*************************************************************************/

/**
ABOUT ME: THIS CLASS IS NAVIGATOR- TAKES EACH EVENT FROM TRIGGER AND DELEGATES TO AN APPROPRIATE EXECUTOR.
REFERENCED IN: TRIGGER- "Opportunity_MAIN_Trigger_OPTIMIZED".
DESIGNED BY: GRAZITTI

DEVELOPER INSTRUCTIONS:
1. TRY TO KEEP YOUR LOGIC IN MASTER LOOP. AVOID NEW LOOP ADDITION.
2. CREATE A HELPER METHOD TO HANDLE THE LOGIC
3. DO NOT ADD ANY NEW DML OPERATION- TRY TO ADD DATA TO BE MANIPULATE IN EXISTING DMLs.
4. DO NOT ADD ANY SOQL REDUNDANTLY

Modified By : Jade Global Inc, on 6th June 2017
Purpose     : Invoked - PopulateBillToAndShipToContacts method(This method populate Bill-To and Ship-To Contact on Account while closer of the Opportunity)


LastModifiedBy: Jade Global Inc. On 23rd May 2018
Purpose       : Convert  Adjusted POR Currency into the changed opportunity currency
                REFERENCED JIRA: APPS-9339 and APPS-17240

******************************************************************************************************* 
Modified by Sumit Bhatt 19-July-18
   * APPS-21703 AEs unable to Close Lost an Opportunity
   * One can track the changes by searching the ticket number in code. 
***********************************************************************/
public class Trigger_Opportunity_Handler{

    public static Boolean isOpportunityTriggerExecuted = False;
    
    /***----------------------------------------------------------------------------------------------------------------------------------
    BEFORE INSERT HANDLER----PLACE HERE YOUR CODE TO BE EXECUTE BEFORE INSERTING THE RECORDS
    -----------------------------------------------------------------------------------------------------------------------------------***/ 
    public static void beforeInsertHandler(List<Opportunity> newList, Map<Id,Opportunity> newMap){

        if(Trigger_Opportunity_Helper.isBeforeInsertEvent) return;
        Trigger_Opportunity_Helper.isBeforeInsertEvent = True;       

        /** -- MASTER FOR LOOP -- **/
        for(Opportunity opp : newList){

            /**---PROCESS 1: SET THE STEEL BRICK PRICEBOOK TO NEW BUSINESS OPPORTUNITY BY DEFAULT FROM CUSTOM SETTING---**/
            opp = Trigger_Opportunity_Helper.opptyPriceBook(opp);

            /**--- PROCESS 3: BELOW METHOD UPDATE THE OWNER ROLE MAPPING ON THE OPPORTUNITY RECORD ---**/
            opp = Trigger_Opportunity_Helper.updateOwnerRoleMapping (opp, null);
           
            /**--- PROCESS 5: CHECKING IS OPPORTUNITY WITH RECORDTYPE CLOSED WON IS CREATED---**/
            Trigger_Opportunity_Helper.isOpptywithCloseWonRecordType(opp);
            
            /**--(PREVIOUSLY, PROCESS 6 AND 7 WERE PART OF TRIGGER: "OpportunityTrigger")--**/
            /**--- PROCESS 6: THIS IS USED TO UPDATE USD EQUIVALENT OF AMOUNT FIELD IN  EST_USD_AMOUNT__C OPPORTUNITY BASED ON CLOSED  DATE FROM DATECONVERSION---**/
            opp = Trigger_Opportunity_Helper.opportunityCurrencyConversion(opp);
            /**--- PROCESS 7: BELOW METHOD POPULATES THE RENEWAL OPPORTUNITY FIELDS---**/
            opp = Trigger_Opportunity_Helper.updateOpportunityLists(opp);
            
            /**--- PROCESS 8: BELOW METHOD POPULATED THE EXCHANGE RATE ON RENEWAL OPPORTUNITY AT THE TIME OF CREATION.---**/
             // Commented - Exchange Rate Plan POR issue - Called after populating Prior Opp on Renewal Opp
            //opp = Trigger_Opportunity_Helper.populateExchangeRateOnRenewalsOppty(opp);    
            
            /**--- PROCESS 9: BELOW METHOD POPULATES THE ENGAGEMENT MANAGER ON UPSELL/CROSSELL AND RENEWAL OPPORTUNITY AND PRIOR OPPORTUNITY ON UPSELL/CROSSELL OPPORTUNITY---**/
            opp = Trigger_Opportunity_Helper.populateOpptyFieldsChecking(opp);
            
            /**--- PROCESS 9: BELOW METHOD POPULATES THE RENEWAL OPPORTUNITY FROM PRIOR OPPORTUNITY PRIMARY QUOTE ---**/
            opp = Trigger_Opportunity_Helper.populateRenOppFieldsChecking(opp);

        }//END OF MASTER FOR LOOP OF OPPORTUNITY

        /** -- BELOW METHOD POPULATES THE RENEWAL OPPORTUNITY FIELDS (PREVIOUSLY IT WAS PART OF TRIGGER: "OpportunityTrigger") -- **/
        Trigger_Opportunity_Helper.populateRenwalOpptyFields();
        
        /**--- PROCESS 8: BELOW METHOD POPULATED THE EXCHANGE RATE ON RENEWAL OPPORTUNITY AT THE TIME OF CREATION.---**/
        for(Opportunity opp : newList){                                   
            if(opp.CurrencyIsoCode!='USD'){            
                opp = Trigger_Opportunity_Helper.populateExchangeRateOnRenewalsOppty(opp);   
            }
        }
        
            /**--- BELOW METHOD ADD VALIDATION TO SET STAGENAME OF OPPORTUNITY TO 'SIGNED ORDER' POSSIBLE ONLY THROUGH SIGNED ORDER BUTTON NOT FROM LAYOUT ---**/
        Trigger_Opportunity_Helper.BOFUSignOrderValidation(newList, newList);

        /** -- BELOW METHOD PERFORM:
                1. POPULATES PRODUCT_INFO__C FROM ALL LINE ITEMS WHERE PRODUCT_TYPE__C = "SERVICES" (PREVIOUSLY: Trigger_Opportunity_Helper.PopulateSalesancPro(newList))
                2. POPULATES ENGAGEMENT MANAGER AND PRIOR OPPORTUNITY ON OPPORTUNITY (PREVIOUSLY: Trigger_Opportunity_Helper.populateOpptyFields(newList))
                3. POPULATES RENEWAL OPPORTUNITY FIELD FORM THE PRIOR OPPORTUNITY PRIMARY QUOTE (PREVIOUSLY: Trigger_Opportunity_Helper.populateRenOppFields(newList))
         --**/        
        Trigger_Opportunity_Helper.populateOpportunityFields(newList, newMap, newMap);
        
        //**************** Code added by Jade - 30th Aug 2016 ****************
        //Call to OpportunityAPORCalcRevisited() method for MDQ
        System.debug('%$%$%$%$%$%$%$ Calling OpportunityAPORCalcRevisited() Method %$%$%$%$%$%$%$');
        List<Opportunity> lstRNWLOpptys = new List<Opportunity>();
        for(Opportunity op: newlist){
            if(op.isWon == FALSE && op.Type == 'Renewal'){
                lstRNWLOpptys.add(op);
            }
        }
        if(!lstRNWLOpptys.isEmpty()){
            lstRNWLOpptys = Trigger_Opportunity_Helper.OpportunityAPORCalcRevisited(lstRNWLOpptys,null,'BEFORE INSERT');
            //System.assertEquals(1,2);
        }
        
        /****************************************************************
        Added by: Jade Global Inc.
        Date: 25th May 2017
          Call to updateSDRPicklistOnOpportunity() method
          This method will update the SDR_Owner__c field from SDR_Owner_Lookup__c on Opportunity on BEFORE INSERT event.
        ****************************************************************/
        Trigger_Opportunity_Helper.updateSDRPicklistOnOpportunity(newlist,null);
        //commented as per APPS-21703
        //#APPS-17919#-Start
        //Trigger_Opportunity_Helper.workflowActions(null,null,newlist);
        //#APPS-17919#-End
        //commented as per APPS-21703
    }// END OF BEFORE INSERT HANDLER
    
    /***-----------------------------------------------------------------------------------------------------------
    BEFORE UPDATE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE BEFORE UPDATING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/ 
    public static void beforeUpdateHandler(List<Opportunity> newList, Map<Id,Opportunity> newMap, List<Opportunity> oldList, Map<Id,Opportunity> oldMap){
    
        /* 
          Due to setting isBeforeUpdateEvent variable to true , All method in before trigger is not getting executed in 2nd iteration .
           Added below method during Amend and will work for all Opportunity.
           Last modified date : 13th May 2016
        */
        /**--- PROCESS 11: TO POPULATE THE DATE FIELD VLAUE ON OPPORTUNITY--**/
    
    /** Exodus validation on close Won opty**/
        closeWonOpportunity_Validation.closeWonOppProvisioningValidation(newList,oldMap);
        //
        Trigger_Opportunity_Helper.populateDateFieldOnOpprotunity(newList,oldMap);

        if(Trigger_Opportunity_Helper.isBeforeUpdateEvent) return;
        Trigger_Opportunity_Helper.isBeforeUpdateEvent = True;       

        /** -- MASTER FOR LOOP -- **/
        for(Opportunity Opp : newList){

            /**---- PROCESS 1: VALIDATION TO SET STAGENAME OF OPPORTUNITY TO 'SIGNED ORDER' POSSIBLE ONLY THROUGH SIGNED ORDER BUTTON NOT FROM LAYOUT ---**/
            //opp = Trigger_Opportunity_Helper.BOFUSignOrderValidation(opp, oldMap);

            /**--- PROCESS 2: BELOW METHOD POPULATES THE CUSTOM EXCHANGE RATE ON NEW BUSINESS AND UPSELL/CROSELL OPPORTUNITY---**/
            opp = Trigger_Opportunity_Helper.customExchangeRateImplementation(opp,oldMap);
            
            /**--- PROCESS 3: WHEN CLOSED OPPORTUNITY RECORD TYPE IS CHANGED TO "CLOSED WON" THIS TRIGGER WILL DO SPA CALLOUT WITH THE INFORMATION (LANGUAGE, LOCALE AND TIMEZONE) OF OPPORTUNITYLINEITEM  WITH RESPECT TO PRODUCT FAMILY.---**/
            if(!opp.toutapp_migrated__c){
        opp = Trigger_Opportunity_Helper.opptyAutoprovisingProcess(opp, oldMap);
      }
            /**--- PROCESS 4:WHEN OPPORTUNITY TYPE IS SET TO "RENEWAL" AND OPPORTUNITY OWNERID IS NOT SAME AS RENEWALS_OWNER_ID__C THIS METHOD WILL UPDATE RENEWALS_OWNER__C FIELD OF ACCOUNT---**/
            opp = Trigger_Opportunity_Helper.updateOwnerRoleMapping(opp, oldMap);

            /**--- PROCESS 5:BELOW METHOD POPULATES EXCHANGE RATE ON CLOSED WON OPPORTUNITY---**/
            opp = Trigger_Opportunity_Helper.updateOpptyExchangeRate(opp);

            /**--- PROCESS 6: BELOW METHOD UPDATE THE SBQQ__CONTRACTED__C ON OPPORTUNITY WHEN OPPORTUNITY GET CLOSED AND THERE IS A PRIMARY QUOTE ON OPPORTUNITY---**/
            opp = Trigger_Opportunity_Helper.updateSBQQ_Contracted(opp, oldMap);

            /**--- PROCESS 7: THIS IS USED TO  UPDATE USD EQUIVALENT OF AMOUNT FIELD IN  EST_USD_AMOUNT__C OPPORTUNITY BASED ON CLOSED  DATE FROM DATECONVERSION---**/
            opp = Trigger_Opportunity_Helper.opportunityCurrencyConversion(opp, oldMap);

            /**--- PROCESS 8: CHECKING IS OPPORTUNITY WITH RECORDTYPE CLOSED WON IS CREATED ---**/
            Trigger_Opportunity_Helper.isOpptywithCloseWonRecordType(opp);

            /**--- PROCESS 9: BELOW METHOD POPULATE THE OPPORTUNITY'S SALES REGION FROM PARENT ACCOUNTS SALES REGION ON CLOSED WON.---**/
            Trigger_Opportunity_Helper.updateSalesRegionFromAccinBeforeProcess(opp,oldMap); 

        }//END OF FOR LOOP OF OPPORTUNITY
        
          /******Convert  Adjusted POR Currency into the changed opportunity currency ****/
            Trigger_Opportunity_Helper.convertAPOROntoChangedCurrency(newList,oldMap,'BEFORE UPDATE');
            
        
        /**--- BELOW METHOD ADD VALIDATION TO SET STAGENAME OF OPPORTUNITY TO 'SIGNED ORDER' POSSIBLE ONLY THROUGH SIGNED ORDER BUTTON NOT FROM LAYOUT ---**/
        Trigger_Opportunity_Helper.BOFUSignOrderValidation(oldList, newList);
        
        /**--- WHEN CLOSED OPPORTUNITY RECORD TYPE IS CHANGED TO "CLOSED WON" THIS TRIGGER WILL DO SPA CALLOUT WITH THE INFORMATION (LANGUAGE, LOCALE AND TIMEZONE) 
               OF OPPORTUNITYLINEITEM  WITH RESPECT TO PRODUCT FAMILY ---**/
        Trigger_Opportunity_Helper.processOpportunitiesProcess();
        
        /**--- BELOW METHOD POPULATES PRODUCT_INFO__C  ON OPPORTUNITY WHICH IS CONCATINATION OF ALL THE OPPORTUNITY LINE ITEM PRODUCT WHERE PRODUCT_TYPE__C = "SERVICES" --**/
        Trigger_Opportunity_Helper.populateOpportunityFields(newList, newMap, oldMap);
        
        /**--- BELOW METHODS POPULATES THE INTACCT-CUSTOM TEXT FIELD ON OPPORTUNITY FROM RELATED SBQQ AND STANDARD QUOTE. --**/
        Trigger_Opportunity_Helper.populateOpportunityIntacctCustomTextField(newList, newMap);    

        /**--- BELOW METHOD USED TO PREVENT USER TO CHANGE THE INTACCT ENTITY ON OPPORTUNITY --**/
        //Trigger_Opportunity_Helper.validIntacctEntity(newList, newMap, oldMap);    

        //Call to APORCalculationOnRNWLUpdate()
        //This method will be called on BEFORE UPDATE of every Renewal Opportunity
        //This will execute if and only if the Manual_APOR_Adjustment__c value is changed       
        list<Opportunity> lstRenewalOppty = new list<Opportunity>();
        For(Opportunity opty : newlist){
            if(opty.Type == 'Renewal'){
                lstRenewalOppty.add(opty);
            }//End of IF
        }//End of FOR
        if(!lstRenewalOppty.isEmpty()){
            // Commented as per the ticket #Apps - 20840
            //Trigger_Opportunity_Helper.OpportunityAPORCalcOnRNWLUpdate(lstRenewalOppty,oldMap);    
        }//End of IF
        
        /****************************************************************
        Added by: Jade Global Inc.
        Date: 25th May 2017
          Call to updateSDRPicklistOnOpportunity() method
          This method will update the SDR_Owner__c field from SDR_Owner_Lookup__c on Opportunity on BEFORE UPDATE event iff the SDR_Owner_Lookup__c value is changed.
        ****************************************************************/
        Trigger_Opportunity_Helper.updateSDRPicklistOnOpportunity(newlist,oldMap);
        
    }//END OF BEFORE UPDATE HANDLER
    
    
    /***-----------------------------------------------------------------------------------------------------------
    BEFORE DELETE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE BEFORE DELETING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/   
    public static void beforeDeleteHandler(List<Opportunity> oldList, Map<Id,Opportunity> oldMap){
        //AWAITING FOR YOU...
    }//END OF BEFORE DELETE HANDLER
    
    /***-----------------------------------------------------------------------------------------------------------
    AFTER INSERT HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER INSERTING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/   
    public static void afterInsertHandler(List<Opportunity> newList, Map<Id,Opportunity> newMap){

        if(Trigger_Opportunity_Helper.isAfterInsertEvent) return;
        Trigger_Opportunity_Helper.isAfterInsertEvent = True;        

        for(Opportunity Opp : newList){
            /**--- PROCESS 1: WHEN OPPORTUNITY TYPE IS SET TO "RENEWAL" AND OPPORTUNITY OWNERID IS NOT SAME AS RENEWALS_OWNER_ID__C THIS METHOD WILL UPDATE RENEWALS_OWNER__C FIELD OF ACCOUNT ---**/
            Trigger_Opportunity_Helper.updateRenewalsOwnerOnAccountOnOpptyCreation(Opp);
        }//END OF FOR LOOP OF OPPORTUNITY
        
        /**--- Below Method process the OpportunityAdallomTrigger trigger functionality ---**/
        Trigger_Opportunity_Helper.opportunityAdallomTrigger(newList, newMap, null, null);
        
        // APPS-22357 - Update Account From customer to Ex-customer 
         Trigger_Opportunity_Helper.updateSetAccounttypeInClosedLost(newList,newmap,null,null);
        // End of APPS-22357 - Update Account From customer to Ex-customer 

        /** -- FINALLY PEROFRM ALL DML OPERATIONS -- **/
        Trigger_Opportunity_Helper.FINALLY_DMLS();        

    }//END OF AFTER INSERT HANDLER
    
    /***-----------------------------------------------------------------------------------------------------------
    AFTER UPDATE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER UPDATING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/   
    public static void afterUpdateHandler(List<Opportunity> newList, Map<Id,Opportunity> newMap, List<Opportunity> oldList, Map<Id,Opportunity> oldMap){

        if(Trigger_Opportunity_Helper.isAfterUpdateEvent) return;
        Trigger_Opportunity_Helper.isAfterUpdateEvent = True;
      //#APPS-17919#-Start
                Trigger_Opportunity_Helper.getOpportunityMapOnAfterUpdate();
        //#APPS-17919#-End
          
        for(Opportunity opp : newlist) {

            /**--- PROCESS 1: WHEN OPPORTUNITY TYPE IS SET TO "RENEWAL" AND OPPORTUNITY OWNERID IS NOT SAME AS RENEWALS_OWNER_ID__C. THIS METHOD WILL UPDATE RENEWALS_OWNER__C FIELD OF ACCOUNT ---**/
            Trigger_Opportunity_Helper.updateRenewalsOwnerOnAccountOnOpptyCreation(opp);
            
            /**--- PROCESS 2: BELOW METHOD CHECKS DIFFERENT CRITERIA WHEN THE OPPORTUNITY IS CLOSED WON ---**/
            Trigger_Opportunity_Helper.closeWonOpportunityChecking(opp, oldMap);

            /**--- PROCESS 3: BELOW METHOD POPULATE THE OPPORTUNITY'S SALES REGION FROM PARENT ACCOUNTS SALES REGION ON CLOSED WON.SUCH AS LOCATION AND GEOGRAPHY ---**/            
            Trigger_Opportunity_Helper.updateGeoInfoOnOLIFromAccinAfterUpdateChecking(opp, oldMap);
            
            /**--- PROCESS 4: BELOW METHOD CHECK IS THE CUSRRENT OPPORTUNITY STAGE IS CLOSED LOST---**/
            Trigger_Opportunity_Helper.closeLostOpportunityChecking(opp, oldMap);  
  /**--- PROCESS: APPS-17919 Decommission Cross object formula fields that are not used on Opp Merge Three Workflow in a single rule**/            
            //#APPS-17919#-Start
            Trigger_Opportunity_Helper.workflowActions(opp, oldMap.get(opp.id),null); 
            //#APPS-17919#-End        

        }//END OF FOR LOOP OF OPPORTUNITY
        
        /**-- WHEN OPPORTUNITY IS CLOSED WON , SEND SURVEY EMAIL TO PRIMARY CONTACT ON QUOTE AND CONTACT PRESENT ON CUSTOMER SUCCESS MANAGEMENT HISTORY OBJECT ON RELATED ACCOUNT ---**/
        Trigger_Opportunity_Helper.sendSurveyInviteForRenewal(newList,oldMap);
        
        /**-- WHEN OPPORTUNITY IS CLOSED WON UPDATE BILL-TO AND SHIP-TO CONTACT FROM ACCOUNT ---**/
        Trigger_Opportunity_Helper.PopulateBillToAndShipToContacts(newList,oldMap);
        
        /**-- WHEN OPPORTUNITY TYPE IS SET TO "RENEWAL" AND OPPORTUNITY OWNERID IS NOT SAME AS RENEWALS_OWNER_ID__C UPDATE THE ACCOUNT RECORD --**/
        Trigger_Opportunity_Helper.mapAccountFieldsFromOpportunity(newList);
        
        /**-- THIS TRIGGER ALLOWS US TO CREATE MKT PAYMENT ON CLOSED WON OF THE OPPORTUNITY BASED ON THE RELATED OPPORTUNITY LINE ITEMS ---**/
        Trigger_Opportunity_Helper.mkt_AddPaymentTrigger();
        
        /**--- IN THE AFTER UPDATE TRIGGER WE WILL CHANGE ALL LOCATION__C, GEOGRAPHY__C  ON THE RELATED OPPORTUNITY LINE ITEMS BASED ON OPPORTUNITY’S. INTACCT ENTITY = “MARKETO-EMEA” OR MARKETO-US” ---**/
        Trigger_Opportunity_Helper.updateGeoInfoOnOLIFromAccinAfterUpdate();
        
        /**--- BELOW METHOD UPDATE THE PRIMARY MARKETO USER CHECK BOX ON CONTACT WHEN PRIMARY MARKETO USER ON OPPORTUNITY IS UPDATED --**/
        Trigger_Opportunity_Helper.updatePrimaryMarketoUserOnContact();

        /**--- BELOW METHOD UPDATED ALL THE OPPORTUNITY PRODUCT WHEN THE CURRENT OPPORTUNITY IS CLOSED WON ---**/
        Trigger_Opportunity_Helper.updateOpptyLines(); 

        //**--Below Method process the OpportunityAdallomTrigger trigger functionality
        Trigger_Opportunity_Helper.opportunityAdallomTrigger(newList, newMap, oldList, oldMap);

        /**--- WHEN OPPORTUNITY GETS CLOSED WON UPDATE THE CAM OWNER AND CAM GROUP ON ACCOUNT. PREVIOUSLY ACHIVED FROM THE CREATE CAM_ASSIGNMENT CLASS ---**/
        Trigger_Opportunity_Helper.populatecamOwnerandcamGroupOnAccount(newlist);        
        
        /***--- LEAGCY CODE IS USED:- IN FOLLOWING METHODS WE ARE USING OLD CODE ---**/
        Trigger_Opportunity_Helper.updateOpportunity(); //TO CREATE ASSET AND ENTITLMENT.      
        Trigger_Opportunity_Helper.cloneCloseLostOpportunity(); //TO PERFORM SOME OPERATIONS WHEN OPPORTUNITY IS CLOSED LOST.  

         /**--- BELOW METHOD USED TO PREVENT USER TO CHANGE THE INTACCT ENTITY ON OPPORTUNITY --**/
        if(!SBQQQuoteTriggerHandler.IS_Intacct_Entity_Updated_On_Opportunity){
            Trigger_Opportunity_Helper.validIntacctEntity(newList, oldMap); 
        }
                
        /** -------FINALLY PEROFRM ALL DML OPERATIONS --------**/
        Trigger_Opportunity_Helper.FINALLY_DMLS();
        //#APPS-17919#-Start
            Trigger_Opportunity_Helper.workflowActionsUpdation();
        //#APPS-17919#-Start
        
    /***--- RENEWAL MANAGEMENT: A NEW RENEWAL OPPORTUNUTY IS CREATED ---***/        
        /**-- WHEN THE NEW BUSINESS OPPORTUNITY IS CLOSED WON --**/
        Trigger_Opportunity_Helper.cloneNewBusinessOpportunity(newMap);
        /**-- NEW RENEWAL OPPORTUNITY WHEN THE RENEWAL OPPORTUNITY IS CLOSED WON --**/
        Trigger_Opportunity_Helper.cloneRenewalOpportunity(newMap);
        //System.assertEquals(1,2);
        
        //**************** Code added by Jade - 30th Aug 2016 ****************
        //Call to OpportunityAPORCalcRevisited() method for MDQ
        System.debug('%$%$%$%$%$%$%$ Calling OpportunityAPORCalcRevisited() Method %$%$%$%$%$%$%$');
        List<Opportunity> lstOpptysClosedWon = new List<Opportunity>();
        list<Opportunity> OpportunitiesToBeUpdated = new List<Opportunity>();
        for(Opportunity op: newlist){
            if(op.isWon == TRUE && op.isWon != oldMap.get(op.id).isWon && op.Type == 'Upsell/Crossell'){
                lstOpptysClosedWon.add(op);
            }
        }
        if(!lstOpptysClosedWon.isEmpty()){
            OpportunitiesToBeUpdated = Trigger_Opportunity_Helper.OpportunityAPORCalcRevisited(lstOpptysClosedWon,oldMap,'AFTER UPDATE');
        }
        if(!OpportunitiesToBeUpdated.isEmpty()){
            System.debug('!@!@@@###$$%%^^&**$@!!# In Handler: '+OpportunitiesToBeUpdated);
            update OpportunitiesToBeUpdated;
        }
        
        //*************** Method Call for YTD Blended Discount logic ****************
        //Method call Added By Jade on 22nd July 2016
        //This Method will be called on every Upsell/Xsell closed Won and will update the Prior Blended Discount on RNWL Quote
        YTDBlendedDiscountCalculator.UpsellClosedWonPriorBlendedDiscountCall(newList,oldMap);
        
        //*************Code added by Jade - 14th Jun 2017******************
        
        SFContactToIntacct.getOpportunityIds(newList,oldMap);
        
    }//END OF AFTER UPDATE HANDLER

    /***-----------------------------------------------------------------------------------------------------------
    AFTER DELETE HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER DELETING THE RECORDS
    ---------------------------------------------------------------------------------------------------------------***/   
    public static void afterDeleteHandler(List<Opportunity> oldList, Map<Id,Opportunity> oldMap){
        
        //Below Method process the OpportunityAdallomTrigger trigger functionality
        Trigger_Opportunity_Helper.opportunityAdallomTrigger(null, null, oldList, oldMap);
       
    }//END OF AFTER DELETE HANDLER

}//END OF CLASS