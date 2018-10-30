public class CaseArticleSearchLinkCls {
    boolean isPublic = true;
    public Case caseRecord{get;set;}
    public CaseComment cComment{get;set;}
    public string callfunc {get;set;}
    public CaseArticleSearchLinkCls(ApexPages.StandardController controller) {    
        String recId = ApexPages.currentPage().getParameters().get('id');
        Boolean isJiveArticle = ApexPages.currentPage().getParameters().get('docType').trim()=='Community'?false:true;
        if(ApexPages.currentPage().getParameters().get('public') != null && ApexPages.currentPage().getParameters().get('public') != '') isPublic = boolean.valueOf(ApexPages.currentPage().getParameters().get('public'));
        if(isPublic != NULL){
        if(recId.startsWithIgnoreCase('500')) {
            caseRecord = (Case)controller.getRecord();                                    
            cComment = new CaseComment(parentId = caseRecord.Id,isPublished = isPublic); 
            try{
                    if(ApexPages.currentPage().getParameters().get('artIds') != NULL) {
                    String articleId = ApexPages.currentPage().getParameters().get('artIds');
                    list<string> lol = new list<string>();
                    cComment.CommentBody = '';
                    if(articleId != ''){
                        for(string test: articleId.split(';')){
                            lol = test.split('_', 2); 
                            if(lol.size() > 1){
                                lol[0] = lol[0].replace(' ','+');
                                cComment.CommentBody += 'Title - '+lol[1]+'\nLink - ' +lol[0] +'\n\n';        
                            }
                            else{
                                cComment.CommentBody = 'Hi, Please review following article below : \n' +System.label.Confluence_ViewPage_BaseUrl + articleId+' .';                
                            }
                        }
                    }
                                 
                } else if(ApexPages.currentPage().getParameters().get('artId') != NULL) {
                    String articleId = ApexPages.currentPage().getParameters().get('artId');
                    list<string> lol = new list<string>();
                    cComment.CommentBody = '';
                    if(articleId != ''){
                        for(string test: articleId.split(';')){
                            lol = test.split('_', 2);   
                            if(lol.size() > 0){
                                lol[0] = lol[0].replace(' ','+');
                                cComment.CommentBody += 'Title - '+lol[1]+'\nLink - ' +lol[0] +'\n\n';        
                            }
                        }
                    }
                }
            }
            catch(Exception e){
                CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);
            }
        } }
    }    
    
    public pagereference saveCaseComment() {        
        if(cComment.Id != null){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Case Comment already inserted. Please close the add case comment popup page.'); 
            ApexPages.addMessage(myMsg);
            callfunc='<script> CloseAndReWfresh(); </script>';
            return null;
        }
        try {            
            insert cComment;            
            cComment = new CaseComment(parentId = caseRecord.Id,isPublished = true);
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO,'Case Comment successfully added.'); 
            ApexPages.addMessage(myMsg); 
            if(ApexPages.currentPage().getParameters().get('artIds') != NULL){
                 List<String> artLst = new List<String>();
                 String articleId = ApexPages.currentPage().getParameters().get('artIds');
                 artLst.addAll(ApexPages.currentPage().getParameters().get('artIds').split(';'));           
                if(artLst.isEmpty() == FALSE) {                                                             
                    Boolean isJiveArticle = ApexPages.currentPage().getParameters().get('docType').trim()=='Community'?false:true; 
                    Set<String> existingDocIds = new Set<String>();
                    List<Case_Confluence_Article__c> chkRecords = [SELECT ID,Unique_Url_Id__c From Case_Confluence_Article__c Where isJiveArticle__c = :isJiveArticle AND Case__c =:caseRecord.id AND Unique_Url_Id__c in :artLst];
                    for(Case_Confluence_Article__c chkRecord :  chkRecords) {
                        existingDocIds.Add(chkRecord.Unique_Url_Id__c);                
                    }
                    List<Case_Confluence_Article__c> caRecords = new List<Case_Confluence_Article__c>();
                    list<string> urlList = new list<string>();
                    for(string str: articleId.split(';')){
                        if(existingDocIds.Contains(str) == FALSE){
                            urlList = str.split('_');
                            if(urlList.size() > 1){
                                Case_Confluence_Article__c caRecord = new Case_Confluence_Article__c(Case__c=caseRecord.id,DocsUrlLink__c=urlList[0],isJiveArticle__c = isJiveArticle,Unique_Url_Id__c = str );                
                                caRecords.Add(caRecord);
                            }
                        }
                    }
                    if(caRecords.Size() > 0){
                        insert caRecords;
                    }                      
                }                                        
            }            
        } 
        catch(Exception ex) {
            system.debug('Exception is >>>>> ' +ex);
            ApexPages.addMessages(ex);
        }
        callfunc='<script> CloseAndReWfresh(); </script>';    
        return null;    
    }
}