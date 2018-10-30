/* ***********************************************************************************************
Company Name  :Jade Global Inc.
Created Date  :10th February 2018
Description : Call the LogPlatformEvent class to log Platform Event record into Integration Log Event Object 
* *********************************************************************************************** */
public class Trigger_PlatformEvent_Handler {
/***-----------------------------------------------------------------------------------------------------------
    AFTER INSERT HANDLER----PLACE HERE YOUR PROCESS TO BE EXECUTE AFTER INSERTING THE RECORDS
---------------------------------------------------------------------------------------------------------------***/   
    public static void afterInsertHandler(List<Integration_Event__e > newList){
        Trigger_PlatformEvent_Helper.MatchDispatcherRecord(newList);      
        system.debug('Trigger_PlatformEvent_Handler Called');
    }//End of afterInsertHandler Method
}