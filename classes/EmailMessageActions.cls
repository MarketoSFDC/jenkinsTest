/********************************************
Updated By Grazitti Support on 2 Nov 2017
Lines - 24-26 , 33-37
Related Ticket - #00906383
***************************************/

public with sharing class EmailMessageActions{

    private static Boolean emailAction = false;    
    public static Boolean isEmailAction() {
        return emailAction;
    }

    public void doAfterInsert(List<EmailMessage> messages) {
        //collect all the caseIds
        //System.debug('Email messages=>' + messages);
        Set<Id> caseIds = new Set<Id>();
        Set<Id> parentIds = new Set<Id>();
        for(EmailMessage emailObj : messages) { 
            if (emailObj.ParentId != null) {
                if(emailObj.Incoming == false) {
                    caseIds.add(emailObj.ParentId);
                } else if((emailObj.Subject != null && emailObj.Subject.Contains('ref:_')) || (emailObj.TextBody  != null && emailObj.TextBody.Contains('ref:_'))) {
                    caseIds.add(emailObj.ParentId);
                }else if(emailObj.ToAddress == Label.ToutAppEmailAlias){
                    parentIds.add(emailObj.ParentId);
                }
            }            
        }
        Map<Id, Case> cases; 
        List<Case> caseListToUpdate = new List<Case>();
        cases = new Map<Id, Case>([Select Id,RecordTypeID,OnPortalAvailable__c,category__c  from Case where Id In :caseIds]);               
        List<CaseComment> comments = new List<CaseComment>{};
        if(parentIds.isEmpty() == False){
            for(Case cse : [select id,category__c from case where id IN :parentIds]){
                cse.category__c = 'ToutApp';
                caseListToUpdate.add(cse);
            }
            if(caseListToUpdate != null && caseListToUpdate.Size() > 0) Database.update(caseListToUpdate,false);
        }
        for(EmailMessage emailObj : messages){
            if(emailObj.ParentId == null)continue;
            if(cases.containsKey(emailObj.ParentId)){
                Boolean toPublish = true;
                Boolean isExclude= false;
                Boolean isPortalSupportCase= false;
                List<Id> RecTypeId = label.AllowPublicCommentRecrdType.split(';');
                    if(RecTypeId != null){
                    set<ID> exclRecId = new Set<ID>(RecTypeId);
                    if(exclRecId.contains(cases.get(emailObj.ParentId).RecordTypeID)){
                        isExclude = true;
                    }
                 }
                if(isExclude){
                    isPortalSupportCase = true;
                }       
                if(!isExclude && emailObj.Incoming == true){
                    toPublish = false;
                }
                if(isExclude&& emailObj.Incoming == true){
                    toPublish = true;
                }
                if(emailObj.FromAddress == 'mailer-daemon@salesforce.com'){
                    toPublish = false;
                }
                if(cases.get(emailObj.ParentId).RecordTypeID == Label.ProActiveCaseRecTypeId && cases.get(emailObj.ParentId).OnPortalAvailable__c == True){
                     toPublish = true;
                     isPortalSupportCase = true;
                }
                String commentBody = getEmailBody(emailObj,isPortalSupportCase);   
                comments.add(new CaseComment(ParentId = emailObj.ParentId,CommentBody = commentBody,IsPublished = toPublish));            
            }
        }        
        if(comments.size() > 0) {
            //update temporary field to prevent workflow rule from firing
            List<Case> caseList = [SELECT Id,Prevent_Comment_Notifications__c from Case WHERE Id in :caseIds];
            for(Case caseUpdate : caseList) {
                caseUpdate.Prevent_Comment_Notifications__c = true;
            }
            update caseList;            
            //make email actions true to stop updateCase trigger of comments
            emailAction = true;    
            try {         
                insert comments;                                    
            }
            catch (Exception ex) {
                String msgBody = 'Comment Insert Exception=>' + ex;
                System.debug(msgBody);                
            }
            for(Case caseUpdate : caseList) {
                caseUpdate.Prevent_Comment_Notifications__c = false;
            }
            update caseList;
        }
    }
    
    public String getEmailBody(EmailMessage emailObj,Boolean isPortalSupportCase) {
        String emailBody = (emailObj.TextBody == null) ? '' : emailObj.TextBody;
        System.debug('emailBody length ' + emailBody.length());
        String emailToAdd = emailObj.ToAddress;
        emailBody.replaceAll('(<br>)\\1+','<br>');    
        
        if((emailObj.Incoming == true && isPortalSupportCase) || Test.isRunningTest()) {
            emailBody = getEmailBody(emailBody).trim();
            emailBody = 'To: ' + emailToAdd + '\n' + 'From: ' + emailObj.FromAddress + '\n' + emailBody;
        }        
        Integer abbLength = 3970;        
        if(Blob.valueOf(emailBody).size() > 3970){
            while(Blob.valueOf(emailBody).size() > 3970) {
                abbLength = abbLength - 1;
                emailBody = emailBody.abbreviate(abbLength);
            }
            emailBody += '\n<EMAIL TRUNCATED>';            
        }        
        System.debug('emailBody length ' + emailBody.length());
        return emailBody;        
    }
    
     public String getEmailBody(String email) {
        // Normalize line breaks
        email.replaceAll('\r\n', '\n');
        Pattern p = Pattern.compile('(?m)^On .+<[^>]+> wrote:$');
        Matcher m = p.matcher(email);
        if(m.find()) {
            email = email.substring(0,m.start()-1) + '\n' + email.substring(m.start(), m.end()).replaceAll('\n', '') + email.substring(m.end()+1);
        }
        String[] lines = email.split('\n');
        String out = '';    
        Boolean firstLine = true;
        for (String line : lines) {     
            // Make sure the reply is not the first line of the message (workaround for Cirrus Insight in particular which starts with From:)
            if (!firstLine) { 
                line = line.trim();
                if (line.equals('--') || line.equals('-- ') || 
                    line.startsWith('-----Original Message-----') || 
                    line.startsWith('--------------- Original Message ---------------') ||
                    line.startsWith('---------- Forwarded message ----------') ||
                    line.startsWith('________________________________') || 
                    (line.startsWith('On ') && (line.endsWith(' wrote:') || line.endsWith(' wrote:>'))) ||
                    line.startsWith('From: ') ||
                    line.startsWith('Sent from my iPhone') ||
                    line.startsWith('>')) 
                { break;}
            }
            firstLine = false;
            out += line + '\n';            
        }
        System.debug ( 'output '+out);  
        return out.trim();
    }
    public static testmethod void testEmailMessageActions() {
        Test.StartTest();
        Case caseObj = new Case( Subject = 'Test', Description = 'Description Test', Status = 'New');
        insert caseObj;        
        CaseComment commentObj = new CaseComment( ParentId = caseObj.Id, CommentBody = 'test test test');
        insert commentObj;        
        EmailMessage emailObj = new EmailMessage( ParentId = caseObj.Id, subject = '(' + caseObj.Thread_ID__c + ')' , TextBody = 'test test test test  \r\ntest test test test  test');
        insert emailObj;    
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
        Attachment attach=new Attachment(Name='Unit Test Attachment',body=bodyBlob,parentId=emailObj.Id,ContentType = 'application/msword',IsPrivate = false, Description = 'Test'); 
        insert attach;      
        boolean chk = isEmailAction();  
        Test.StopTest();
    }     
    
    public static testmethod void testEmailMessageActions2() {
        Test.StartTest();    
        Case caseObj = new Case(Subject = 'Test1', Description = 'Description Test1', Status = 'New', recordTypeId = '01250000000UKpsAAG');
        insert caseObj;        
        EmailMessage emailObj = new EmailMessage( ToAddress = 'supportescalations@marketo.com', ParentId = caseObj.Id, subject = 'Test (' + caseObj.Thread_ID__c + ')' , TextBody = 'test test test test test test test test  test');
        insert emailObj;
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
        Attachment attach=new Attachment(Name='Unit Test Attachment',body=bodyBlob,parentId=emailObj.Id,ContentType = 'application/msword',IsPrivate = false, Description = 'Test'); 
        insert attach;    
        boolean chk = isEmailAction();                             
        Test.StopTest();                
    }
    
    public static testmethod void testEmailMessageActions3() {    
        Test.StartTest();
        Case caseObj = new Case(Subject = 'Test', Description = 'Description Test', Status = 'New');
        insert caseObj;        
        EmailMessage emailObj = new EmailMessage(ToAddress = 'supportfeedback@marketo.com', ParentId = caseObj.Id, subject = 'Test (' + caseObj.Thread_ID__c + ')' , TextBody = 'test test test test test test test test  test');
        insert emailObj;  
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body'); 
        Attachment attach=new Attachment(Name='Unit Test Attachment',body=bodyBlob,parentId=emailObj.Id,ContentType = 'application/msword',IsPrivate = false, Description = 'Test'); 
        insert attach;     
        boolean chk = isEmailAction();                             
        Test.StopTest();    
    }            
}