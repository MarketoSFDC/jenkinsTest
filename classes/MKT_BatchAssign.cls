global class MKT_BatchAssign implements Database.Batchable<String/*kumocomm__OrderItem__c*/>, Database.Stateful {

    global List<String/*kumocomm__OrderItem__c*/> recs { get;set; }
    global Set<String> ClassIds { get;set; }

    global Iterable<String/*kumocomm__OrderItem__c*/> start(Database.BatchableContext BC) {
        //if (ClassIds == NULL) ClassIds = new Set<String>();
        //if (recs.Size() > 0 && recs[0].MKT_Class__c != NULL) ClassIds.Add(recs[0].MKT_Class__c);
        System.Debug('ClassIds===Start========'+ClassIds);
        return recs;
    }


    global void execute(Database.BatchableContext BC, List<String/*kumocomm__OrderItem__c*/> scope) {

        /*for (String/*kumocomm__OrderItem__c*/ /*orderItem : scope) {

            try {
                /*List<lmscons__Curriculum__c> currList = [SELECT Id FROM lmscons__Curriculum__c WHERE Product__c = :orderItem.kumocomm__Product__c];
                //List<lmscons__Learning_Path__c> lpList = [SELECT Id FROM lmscons__Learning_Path__c WHERE Product__c = :orderItem.kumocomm__Product__c];
                //List<lmscons__Training_Path__c> CourseList = [SELECT Id FROM lmscons__Training_Path__c WHERE Product__c = :orderItem.kumocomm__Product__c];
                //List<lmscons__Training_Content__c> ModuleList = [SELECT Id FROM lmscons__Training_Content__c WHERE Product__c = :orderItem.kumocomm__Product__c];
               // List<lmscons__Quiz__c> QuizList = [SELECT Id FROM lmscons__Quiz__c WHERE Product__c = :orderItem.kumocomm__Product__c];
                //List<lmsilt__Event__c> EventList = [SELECT Id FROM lmsilt__Event__c WHERE Product__c = :orderItem.kumocomm__Product__c];
                List<User> uList = [SELECT Id FROM User WHERE ContactId = :''/*orderItem.kumocomm__Order__r.kumocomm__Contact__c*/ /*LIMIT 1];
                if (currList.size() > 0) {lmsilt.ILTUtil.assignCurriculum(uList, currList[0]);}
                else if (lpList.size() > 0) {lmsilt.ILTUtil.assignLearningPath(uList, lpList[0]);}
                else if (CourseList.size() > 0) {lmsilt.ILTUtil.assignCourse(uList, CourseList[0]);}
                else if (ModuleList.size() > 0) {lmscons.LMSUtil.assignModule(uList, ModuleList[0]);}
                //else if (EventList.size() > 0) {if(orderItem.MKT_Class__c == NULL) lmsilt.ILTUtil.assignEvent(uList, EventList[0]);else HelperWithoutSharing.EnrollUserToClass(uList[0].Id, orderItem.MKT_Class__c);}
                else if (QuizList.size() > 0) {lmscons.LMSUtil.assignQuiz(uList, QuizList[0]);}*/
           /* } catch (Exception e) {/*orderItem.MKT_Assignment_Status_c__c = 'Error';*//*update orderItem;throw e;}
            /*orderItem.MKT_Assignment_Status_c__c = 'Completed';*/
            /*update orderItem;
        }*/

    }

    global void finish(Database.BatchableContext BC) {
        System.Debug('ClassIds=====Fin======'+ClassIds);
        HelperWithoutSharing.RegisterforTrainingClass (ClassIds);
    }

    global class applicationException extends Exception {}
}