public with sharing class CaseCommentExtension {
    private final Case caseRec;
    public CaseComment comment {get; set;}
    public string callfunc {get;set;}
    public string caseStatus;

    public CaseCommentExtension(ApexPages.StandardController controller) {
        caseRec = (Case)controller.getRecord();
        caseStatus = caseRec.status;
        comment = new CaseComment();      
    }

    public PageReference addPrivateComment(){
        try{
            if(caseRec != null){
                update caseRec;
            }
            CaseComment cmmntObj = new CaseComment(parentid = caseRec.id,CommentBody = comment.commentbody,isPublished = false);
            Insert cmmntObj; 
        }
        catch(Exception e){ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));}
        finally{comment.commentbody = '';}
         return null; 
    }
     public PageReference addPublicComment(){
        try{
            if(caseRec != null){
                update caseRec;
            }
            CaseComment cmmntObj = new CaseComment(parentid = caseRec.id,CommentBody = comment.commentbody,isPublished = true);
            Insert cmmntObj; 
        }
        catch(Exception e){ApexPages.addmessage(new ApexPages.message(ApexPages.severity.WARNING,e.getMessage()));}
        finally{comment.commentbody = '';}
         return null; 
    }
}