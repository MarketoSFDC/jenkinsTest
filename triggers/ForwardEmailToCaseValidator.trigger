/**
* Modified by Cassandrea Steiner, Aug 29, 2018 - added a null check for parentIds to avoid running through this logic when it's irrelevant
* **/
Trigger ForwardEmailToCaseValidator on EmailMessage (before insert) {
    
    Id smSupportTypeId = '01250000000UK1EAAW';
    Id smFeedbackTypeId = '01250000000UKpsAAG';
    Id smFeedbackQueueID = '00G50000001R8aaEAC';
    Id smEscalationsQueueID = '00G50000001R8aQEAS';    
    
    list<case> supportCases = new list<case>();
    Map<Id, Case> parentCases = new Map<Id,Case>(); 
    List<Case> childSmSupportCases =  new List<Case>(); 
    
    Set <Id> parentIds = new Set<Id>();
    // Fetch all parent cases for email-messages in trigger
    for (EmailMessage em:Trigger.new) {
        if (em.parentid != null){
            parentIds.add(em.parentid);
        }
    }    
    if(!parentIds.isEmpty()){
        Map<Id, Case> cases = new Map<Id, Case>(
            [Select Id, Subject, Description, AccountId, ContactId, Contact.Email, recordTypeId, ParentId, Status, Situation_Account__c, Situation_Contact__c, Situation_Contact__r.Email From case where Id in :parentIds OR (ParentId IN : parentIds AND RecordTypeId =: smSupportTypeId)]);
        
        //Map<Id, Case> parentCases = new Map<Id,Case>(); 
        //new Map<Id, Case>([Select r.Id,r.Subject, r.Description, r.AccountId, r.ContactId,r.Contact.Email, r.recordTypeId From case r where  r.Id in :parentIds]);
        
        //List<Case> childSmSupportCases =  new List<Case>(); 
        //[Select Id, ParentId, Status From Case Where ParentId IN : parentIds AND RecordTypeId =: smSupportTypeId ];
        
        for(Case tmpCase : cases.values()) {
            if(parentIds.contains(tmpCase.Id)) {
                parentCases.put(tmpCase.Id, tmpCase);
            } else if(parentIds.contains(tmpCase.ParentId) && tmpCase.RecordTypeId == smSupportTypeId) {
                childSmSupportCases.Add(tmpCase);
            }        
        }
        
        
        System.Debug('________childSmSupportCases________'+childSmSupportCases);
        
        Map<Id,List<Case>> parentCaseToAllSitManSuppCases  = new Map<Id,List<Case>>();
        Map<Id,List<Case>> parentCaseToOpenSitManSuppCases = new Map<Id,List<Case>>();
        Map<Id,List<Case>> parentCaseToClosedSitManSuppCases = new Map<Id,List<Case>>();    
        
        If(!childSmSupportCases.isEmpty()) {
            for(Case tempCase :childSmSupportCases) {
                If(parentCaseToAllSitManSuppCases.containsKey(tempCase.ParentId)) {
                    parentCaseToAllSitManSuppCases.get(tempCase.ParentId).Add(tempCase);
                } else {                 
                    parentCaseToAllSitManSuppCases.put(tempCase.ParentId, new List<Case>{tempCase});                
                }                               
                If(tempCase.Status == 'Closed') {
                    System.Debug('_____________CASE STATUS IS CLOSED______AAITM_______');
                    if(parentCaseToClosedSitManSuppCases.containsKey(tempCase.ParentId)) {
                        parentCaseToClosedSitManSuppCases.get(tempCase.ParentId).add(tempCase);                    
                    } else {
                        parentCaseToClosedSitManSuppCases.put(tempCase.ParentId, new List<Case>{tempCase});                
                    }
                } else {
                    if(parentCaseToOpenSitManSuppCases.containsKey(tempCase.ParentId)) {
                        parentCaseToOpenSitManSuppCases.get(tempCase.ParentId).add(tempCase);                    
                    } else {
                        parentCaseToOpenSitManSuppCases.put(tempCase.ParentId, new List<Case>{tempCase});
                    }
                }             
            }
        }
        
        System.Debug('_____________parentCaseToAllSitManSuppCases______________'+parentCaseToAllSitManSuppCases);
        System.Debug('_____________parentCaseToClosedSitManSuppCases______________'+parentCaseToClosedSitManSuppCases);
    }
        List<Case> newCases = new List<Case>();    
        List<CaseComment> comments = new List<CaseComment>();    
        List<Id> tempCaseIds = new List<Id>();    
        List<Case> reOpenSMCases = new List<Case>();
        
        for (EmailMessage em:Trigger.new) {
            System.Debug('_____em.ToAddress______'+em.ToAddress + ' ' + em.parentId + ' ' + em.ID); 
            if (em.ToAddress != Null && (em.ToAddress.containsIgnoreCase('supportescalations@marketo.com') || em.ToAddress.containsIgnoreCase('marketo_support_escalations@marketo.com'))  && parentCases.containsKey(em.Parentid) &&  parentCases.get(em.Parentid).RecordTypeId != smSupportTypeId) 
            {                
                // Create New SM - Support record
                System.Debug('_____________FIRST SM CASE IS INSERTED FROM HERE______________');         
                String s1 = em.Subject;
                if(s1.contains('- (ref:_')) s1 =  em.Subject.substring(0,em.Subject.IndexOfIgnoreCase('- (ref:_')); 
                else if(s1.contains('- ref:_')) s1 =  em.Subject.substring(0,em.Subject.IndexOfIgnoreCase('- ref:_'));
                Case cs = new Case(Situation_Account__c=parentCases.get(em.Parentid).AccountId, SM_Contact_Email__c = parentCases.get(em.Parentid).Contact.Email , ContactId = parentCases.get(em.Parentid).ContactId, Situation_Contact__c=parentCases.get(em.Parentid).ContactId, Subject=s1, Description=em.TextBody, RecordTypeId=smSupportTypeId,ParentId = em.ParentId,OwnerId=smEscalationsQueueID);
                if(cs.Situation_Account__c == Null) {
                    cs.Situation_Account__c = parentCases.get(em.Parentid).Situation_Account__c;
                }
                if(cs.Situation_Contact__c == Null) {
                    cs.Situation_Contact__c = parentCases.get(em.Parentid).Situation_Contact__c;
                    cs.SM_Contact_Email__c = parentCases.get(em.Parentid).Situation_Contact__r.Email;
                }
                
                newCases.add(cs); 
                System.Debug('In supportescalations');            
            } 
            else if (em.ToAddress != Null && em.ToAddress.containsIgnoreCase('supportfeedback@marketo.com') && parentCases.containsKey(em.ParentId) && (parentCases.get(em.Parentid).RecordTypeId != smFeedbackTypeId)) 
            {
                // Create New SM - Feedback record
                Case cs = new Case(Situation_Account__c=parentCases.get(em.Parentid).AccountId, Situation_Contact__c=parentCases.get(em.Parentid).ContactId, Subject=em.Subject, Description=em.TextBody, RecordTypeId=smFeedbackTypeId,ParentID = em.ParentId, OwnerId=smFeedbackQueueID);
                //Added 21 Sep 2016, to support escalation from non support cases
                if(cs.Situation_Account__c == Null) {
                    cs.Situation_Account__c  = parentCases.get(em.Parentid).Situation_Account__c ;
                }
                if(cs.Situation_Contact__c == Null) {
                    cs.Situation_Contact__c = parentCases.get(em.Parentid).Situation_Contact__c;
                }
                
                System.Debug('In supportfeedback');
                newCases.add(cs);                
            }                
        }
        
        if(newCases.size() > 0)  upsert newCases;    
        if(!reOpenSMCases.isEmpty()) update reOpenSMCases;
        if(!comments.isEmpty()) insert comments;
}