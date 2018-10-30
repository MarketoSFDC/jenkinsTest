@isTest(SeeAllData=true)

public class TestClassesforBatchClasses {

    
    /*static testMethod  void UniqueUserBatchClass() {
        UniqueUserBatchClass b1 = new UniqueUserBatchClass();
        ID batchprocessid1 = Database.executeBatch(b1,10);
    }
   
    static testMethod  void SchedulerForUniqueUserReport() { 
        SchedulerForUniqueUserReport.scheduleMe();
        SchedulerForUniqueUserReport schedulable = new SchedulerForUniqueUserReport();
         schedulable.execute(null);
    
    }
    
    
    static testMethod void testLikedCommentBatchClass() {
        List<Reply> replyList = [Select r.id, (Select CreatedDate, CreatedById From Votes) From Reply r where CreatedBy.IsPortalEnabled = true and CreatedBy.IsActive = true and CreatedBy.Profile.Name in ('Session Marketo Community','Named Marketo Community Portal') LIMIT 20000];
 
        List<vote> replyVoteList = New List<Vote>();
        Map<Id,Vote> idToVoteMap = New Map<Id,Vote>();
        
        For(Reply i:replyList){
            replyVoteList.addAll(i.votes);
        }
        For(vote v :replyVoteList){
            idToVoteMap.put(v.id,v);
        }
        
        System.debug('replyVoteList-->'+replyVoteList.size());
        System.debug('idToVoteMap-->'+idToVoteMap.keySet());
        LikedCommentBatchClass  b = new LikedCommentBatchClass(idToVoteMap.keySet()); 
        test.starttest();
        database.executebatch(b,200);
        test.stoptest();
    }
    static testMethod void testAnsweraquestionBatchClass() {
        Map<Id,Question> idToQuestionMap = New Map<Id,Question>([Select c.id From Question c where CreatedBy.IsPortalEnabled = true and CreatedBy.IsActive = true and CreatedBy.Profile.Name in ('Session Marketo Community','Named Marketo Community Portal') Limit 20000]);
        System.debug('idToQuestionMap-->'+idToQuestionMap.size());
        AnsweraquestionBatchClass   b = new AnsweraquestionBatchClass  (idToQuestionMap.keySet()); 
        test.starttest();
        database.executebatch(b,200);
        test.stoptest();
    }

    static testMethod void testSelectbestanswerClass() {
        List<Question> quesList =[Select q.id ,q.BestReplyId From Question q where BestReplyId != null and CreatedBy.IsPortalEnabled = true and CreatedBy.IsActive = true and CreatedBy.Profile.Name in ('Session Marketo Community','Named Marketo Community Portal') LIMIT 20000];
        Set<ID> bestReplyIds = New Set<Id>();
        For(Question q:quesList){
            bestReplyIds.add(q.BestReplyId);
        }
        System.debug('bestReplyIds-->'+bestReplyIds.size());
        
        SelectbestanswerClass   b = new SelectbestanswerClass  (bestReplyIds); 
        test.starttest();
        database.executebatch(b,200);
        test.stoptest();
    }
    static testMethod void testVoteOnIdeaBatchClass() {
        List<Idea> ideaList = [Select c.id,(Select CreatedDate, CreatedById From Votes LIMIT 100) From Idea c where CreatedBy.IsPortalEnabled = true and CreatedBy.IsActive = true and CreatedBy.Profile.Name in ('Session Marketo Community','Named Marketo Community Portal') Limit 10000];
 
        List<vote> ideaVote = New List<Vote>();
        Map<Id,Vote> idToVoteMap = New Map<Id,Vote>();
        
        For(idea i:ideaList){
            ideaVote.addAll(i.votes);
        }
        For(vote v :ideaVote){
            idToVoteMap.put(v.id,v);
        }
        
        System.debug('ideaVote-->'+ideaVote.size());
        System.debug('ideaVote-->'+idToVoteMap.size());
        VoteOnIdeaBatchClass b = new VoteOnIdeaBatchClass(idToVoteMap.keySet()); 

        test.starttest();
        database.executebatch(b,200);
        test.stoptest();
    }*/
    static testMethod  void UniqueUserBatchClass() {
        AnsweraquestionBatchClass a=new AnsweraquestionBatchClass();
	LikedCommentBatchClass b=new LikedCommentBatchClass();
	SelectbestanswerClass c=new SelectbestanswerClass();
	VoteOnIdeaBatchClass d=new VoteOnIdeaBatchClass();
	GainsightCommunityRollupBatch f=new GainsightCommunityRollupBatch();
    }
    
}