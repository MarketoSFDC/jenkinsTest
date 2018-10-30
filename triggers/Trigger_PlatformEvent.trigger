/* ***********************************************************************************************
Created By  : Priyanka Shende, Jade Global Inc.
Created On  : 3rd November 2017
Description : Handle the different platform events and perform the action on each event 
* *********************************************************************************************** */

trigger Trigger_PlatformEvent on Integration_Event__e (after insert) {
    system.debug('Platfom Event Trigger Called');
    Trigger_PlatformEvent_Handler.afterInsertHandler(trigger.new);
    
}