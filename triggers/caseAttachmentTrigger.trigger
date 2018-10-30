trigger caseAttachmentTrigger on Case (after insert, after update) {
    
    for(Case c : Trigger.New)
    {
        if(c.localUID__c != NULL && c.caseid__c != NULL && c.fileName__c !=NULL)
        {
            pureCloudCaseAttachment.callOutAWS(c.localUID__c, c.caseID__c, c.filename__c);
        }
    }
    
}