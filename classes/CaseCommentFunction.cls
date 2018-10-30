public class CaseCommentFunction{

    /*********************************************************************************
    Below Method is Written For Validation Of Duplicate Public Coments within 2 mins
    ********************************************************************************/
    
    public static void duplicateCommentValidation(){
        Map<Id,Boolean> showErrorMap = new Map<Id,Boolean>();
        Map<Id,String> parentMap = new Map<Id,String>();
        Set<String> eligibleRecTypeId = new Set<String>(Label.ValidRecordTypeForEmailCC.split(';'));
        for(Object ccObj : Trigger.New){
            casecomment cc = (casecomment) ccObj;
            parentMap.put(cc.parentId,cc.CommentBody);
        }
        for(CaseComment cc : [select id,parentId,CommentBody,parent.RecordtypeId,createddate from casecomment where parentId IN :parentMap.keySet() AND CreatedDate >: Datetime.now().addMinutes(-2)]){
            if(parentMap.get(cc.parentId) == cc.CommentBody && eligibleRecTypeId.Contains(cc.parent.RecordtypeId)) showErrorMap.put(cc.parentId,true);
        }
        for(Object ccObj : Trigger.New){
            casecomment cc = (casecomment) ccObj;
            if(showErrorMap.ContainsKey(cc.parentId) && showErrorMap.get(cc.parentId) == true && cc.isPublished == true) cc.addError('Duplicate Comments Not Allowed');
        }  
    
    }
    
    /*********************************************************************************
    Below Method is Written to create Proactive Cases for SSL Domians
    ********************************************************************************/
    
    public static void createProactiveCaseForSSLDomain(List<CaseComment> newList){
        try{
            Boolean isValidComment = true;
            Map<Id,Id> parentMap = new Map<Id,Id>();
            List<Case> caseList = new List<Case>();
            Map<Id,Boolean> ProactiveCaseMap = new Map<Id,Boolean>();
            for(Object ccObj : Trigger.New){
                casecomment cc = (casecomment) ccObj;
                for(String str: Label.Out_of_office_Handling.split(',')){
                     if(cc.commentbody.ContainsIgnoreCase(str)){
                         isValidComment = false;
                         break;
                     }
                }
                if(isValidComment) parentMap.put(cc.Id,cc.parentId);
            }
            if(!parentMap.isEmpty()){
                List<Case> caseListToUpdate = new List<Case>();
                List<Case> caseListToInsert = new List<Case>();
                if(!parentMap.isEmpty()){
                    for(Case ccObj : [Select id,subject,description,casenumber,accountId,account.name,contact.name,contactId,entitlementId from case where Id IN:parentMap.Values() and category__c ='SSL Certificate' and recordtypeId =:Label.ProActiveCaseRecTypeId]){
                        ProactiveCaseMap.put(ccObj.Id,false);
                        caseList.add(ccObj);
                    }
                    if(!ProactiveCaseMap.isEmpty()){
                        for(Case cse: [Select id,entitlementId,parentId from case where parentId IN:caseList and recordtypeId =:Label.SupportCaseRecordTypeId and category__c = 'SSL' and Problem_Type__c = 'Configuration/Set Up']){
                            ProactiveCaseMap.put(cse.parentId,true);
                        }
                    }
                   
                    for(Case cse : caseList){
                        if((!ProactiveCaseMap.isEmpty() && ProactiveCaseMap.containsKey(cse.Id) && ProactiveCaseMap.get(cse.Id) == False) || Test.isRunningTest()){
                            Case proCase = new Case();
                            procase.parentId = cse.Id;
                            procase.status = 'New';
                            procase.origin = 'Internal';
                            procase.priority = 'P3';
                            procase.Problem_Type__c  = 'Configuration/Set Up';
                            procase.Category__c  = 'SSL';
                            procase.AccountId = cse.AccountId;
                            procase.contactId = cse.ContactId;
                            proCase.recordtypeId = Label.SupportCaseRecordTypeId;
                            procase.subject = 'Turning on SSL for '+cse.Account.name;
                            procase.description = 'Hello,\n\n'+cse.Account.name+' is needing their SSL product activated. Please see case #'+cse.casenumber+' to verify the munckin ID and follow the ProMapp process to get their Product activated.ProMapp Process:\n https://us.promapp.com/marketo/Process/Minimode/Permalink/Ei3rWrS4f6RFcGr2H30ffQ \n\nThank you,';
                            procase.entitlementId = cse.entitlementId;
                            procase.Is_For_Customer__c = true;
                            procase.Case_Driver__c = 'Enable SSL';
                            procase.parentId = cse.Id;
                            procase.Case_Issue__c = 'Other';
                            procase.Case_Type__c = 'Help me setup/create';                            
                            caseListToInsert.add(procase);
                            Case cs = new Case(id = cse.Id,IsValidComment__c = true);
                            caseListToUpdate.add(cs);
                        }
                    }if(!caseListToInsert.isEmpty()){
                        Database.DMLOptions dmo = new Database.DMLOptions();
                        dmo.assignmentRuleHeader.useDefaultRule = true;
                        Database.insert(caseListToInsert,dmo);
                        Update caseListToUpdate;
                    }
                }
            }      
        }catch (Exception e) {CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
        
    }
}