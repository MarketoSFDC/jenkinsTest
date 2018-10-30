/**********************************************************
Created By:   Tushar Misri, Grazitti Interactive
Created Date: 5th August, 2018
Purpose : Created to check the following:
          - Rubiks to Phoenix Converstion
          - Rubiks to Rubiks Converstion
          - Phoenix to Phoenix Converstion

**********************************************************/

public class Trigger_PhoenixPE_Helper {
/***-----------------------------------------------------------------------------------------------------------
    AFTER INSERT HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER INSERTING THE RECORDS
---------------------------------------------------------------------------------------------------------------***/   
    public static void PerformActionOnQuoteRecord(List<PhoenixARR__e> newList){
          for(PhoenixARR__e pae : newList){
              phoenixRenewalARR.phoenixRenewalARRcalc(pae.Opportunity_Id__c);
              //phoenixRenewalARR.calculateARRFields(pae.Opportunity_Id__c, pae.Renewed_Contract_Id__c, pae.Triggering_Event__c);
          }
    }//End of afterInsertHandler Method
}