trigger CFS_Assignment_Trigger on lmscons__Transcript_Line__c (before insert, before update, after insert, after update){

    if(Trigger.isAfter){    
        if(Trigger.isInsert ){
            CFS_Assignment_Trigger_Handler.checkForSubAssignments(trigger.newMap);
        }
    }
}