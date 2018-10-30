trigger ContentDocumentLinkTriggerMain on ContentDocumentLink (after insert) {

    if(trigger.isAfter && trigger.isInsert){
        Trigger_ContentDocumentLink_Handler.afterInsertUpdateHandler(Trigger.new);
    }

}