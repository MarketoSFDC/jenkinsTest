public class CaseCommentController{

    public Id caseId{get;set;}
    private final List<CaseComment> cComment;
    
    public List<CaseComment> getCaseComment() {
        if(caseId != NULL){
            List<CaseComment> cComment = [SELECT CommentBody FROM CaseComment WHERE ParentId =: caseId AND  IsPublished = True ORDER BY LastModifiedDate DESC LIMIT 1];
            if(cComment!=NULL && cComment.size()>0) return cComment;
        }
        return Null;     
    }
}