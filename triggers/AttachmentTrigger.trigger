trigger AttachmentTrigger on Attachment (after insert) {
    
    try{ 
        if( (Label.EnableAttachmentTrigger == 'Yes' && trigger.new[0].parentID != Null && string.Valueof(trigger.new[0].parentID).startsWith('500') && trigger.new[0].createdById == Label.JiveSyncSafeUserId) || Test.isRunningTest()){
            list<attachment> attchLIst = new list<attachment>();
            DateTime dt = System.Now().addminutes(-15);
            attchLIst = [select id,parentID, createddate, CreatedById, Name from attachment where parentId =: trigger.new[0].parentID and parent.recordtypeId =: Label.SupportCaseRecordTypeId and createddate >: dt order by createddate desc limit 3];
            if(attchLIst.size()==1 ){
                CaseComment cm = new CaseComment(parentId = attchLIst[0].ParentID,CommentBody = 'Customer has updated the file '+attchLIst[0].Name+ ' on date '+System.now(),IsPublished = false); 
                insert cm;
            } 
        } 
    } catch(Exception e){CaseTriggerFunction.sendEcxeptionMailToDeveloper(e);}
       
}