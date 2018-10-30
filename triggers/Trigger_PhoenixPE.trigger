/**********************************************************
Created By:   Tushar Misri, Grazitti Interactive
Created Date: 5th August, 2018
Purpose : Created to check the following:
          - Rubiks to Phoenix Converstion
          - Rubiks to Rubiks Converstion
          - Phoenix to Phoenix Converstion

**********************************************************/

trigger Trigger_PhoenixPE on PhoenixARR__e (after insert) {
    Trigger_PhoenixPE_Handler.afterInsertHandler(trigger.new);
}