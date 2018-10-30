/**********************************************************
Created By:   Tushar Misri, Grazitti Interactive
Created Date: 5th August, 2018
Purpose : Created to check the following:
          - Rubiks to Phoenix Converstion
          - Rubiks to Rubiks Converstion
          - Phoenix to Phoenix Converstion

**********************************************************/

public class Trigger_PhoenixPE_Handler {
/***-----------------------------------------------------------------------------------------------------------
    AFTER INSERT HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER INSERTING THE RECORDS
---------------------------------------------------------------------------------------------------------------***/   
    public static void afterInsertHandler(List<PhoenixARR__e> newList){
        Trigger_PhoenixPE_Helper.PerformActionOnQuoteRecord(newList);      
    }
    //End of afterInsertHandler Method
}