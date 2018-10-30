public without sharing class HelperWithoutSharing {
    public static final String CURRENT_COOKIE_NAME = 'ShoppingCart';
    public static void DeleteSObjects(List<SObject> SObjects) {
        delete SObjects;
    }
    public static void InsertSObjects(List<SObject> SObjects) {
        insert SObjects;
    }
    public static void DeleteRoster(List<lmsilt__Roster__c> Rosters) {
        System.Debug('Rosters========='+Rosters);
        delete Rosters;
    }
    public static void RestartAssignJob(SchedulableContext sc) {
        try {
            System.abortJob(sc.getTriggerId());
        }
        catch (Exception e) {}
        MKT_AssignQueueProcessingScheduled.Schedule(1);
    }
    public static void StartAssignJob() {
        try {
            List<AsyncApexJob> StartedScheduledJobsList = [SELECT Status, MethodName, JobType, ApexClass.Name, ApexClassId FROM AsyncApexJob WHERE Jobtype = 'ScheduledApex' AND ( Status = 'Queued' OR Status = 'Processing' OR Status = 'Preparing') AND ApexClass.Name = 'MKT_AssignQueueProcessingScheduled'];
            if (StartedScheduledJobsList.size() == 0)
            MKT_AssignQueueProcessingScheduled.Schedule(1);
        }
        catch (Exception e) {}
    }
    public static void InsertAssignQueue(List<MKT_AssignQueue__c> AssignQueues) {
        insert AssignQueues;
    }
    public static void DeleteSessionsRoster(list<lmsilt__Roster__c> Rosters) {
        Set<Id> RSIds = new Set<Id>();
        System.Debug('Rosters========='+Rosters);
        if (Rosters.size() > 0) {
            for (lmsilt__Roster__c r : Rosters) {
                RSIds.add(r.Id);
            }
        }

        list<lmsilt__GoToTraining_Session__c> RSs = [SELECT Id FROM lmsilt__GoToTraining_Session__c WHERE Id/*lmsilt__Roster__c*/ IN:RSIds LIMIT 1000];
        delete RSs;
    }

    public static lmsilt__Class__c getClassByClassId(Id ClassId){
        return  [SELECT Id, lmsilt__Start_Date__c, lmsilt__End_Date__c, lmsilt__Total_hours__c, lmsilt__Event__c, lmsilt__Maximum_Capacity__c, lmsilt__Cancellation_Policy_lookup__c FROM lmsilt__Class__c WHERE Id=:ClassId];
    }

    public static Integer getCountStudentEnroled(Id ClassId) {
        return  [SELECT count() FROM lmsilt__Roster__c WHERE lmsilt__Class__c=:ClassId and lmsilt__Status__c = 'Enrolled'];
    }

    public static Integer getCountStudentWaitlisted(Id ClassId) {

        list<AggregateResult> c = [SELECT MAX(lmsilt__Waitlist_Priority__c) FROM lmsilt__Roster__c WHERE lmsilt__Class__c=:ClassId and lmsilt__Status__c = 'Waitlisted'];

        system.debug('429: c: '+c[0].get('expr0'));

        if (c[0].get('expr0') != NULL) {
            return Integer.valueOf(c[0].get('expr0'));
        } else {
            return NULL;
        }
    }

    public static void updateRoster(list<lmsilt__Roster__c> r){
        update r;
    }

    public static map<Id, list<lmsilt__Roster__c>> getWaitlistMapRostersByClassIds(Id clsId) {
        list<lmsilt__Roster__c> Rosters = new list<lmsilt__Roster__c>();

        Rosters = [SELECT Id, lmsilt__Waitlist_Priority__c, lmsilt__Class__c, lmsilt__Class__r.lmsilt__Event__c, lmsilt__Student__c FROM lmsilt__Roster__c WHERE lmsilt__Class__c = :clsId and lmsilt__Status__c = 'Waitlisted' ORDER BY lmsilt__Class__c, lmsilt__Waitlist_Priority__c];

        if (Rosters.size() == 0) {
            return NULL;
        }

        map<Id, list<lmsilt__Roster__c>> cls_listRoster = new map<Id, list<lmsilt__Roster__c>>();
        for (lmsilt__Roster__c r : Rosters) {
            if (cls_listRoster.containsKey(r.lmsilt__Class__c) == false) {
                list<lmsilt__Roster__c> rTmp = new list<lmsilt__Roster__c>();
                cls_listRoster.put(r.lmsilt__Class__c, rTmp);
            }

            cls_listRoster.get(r.lmsilt__Class__c).add(r);
        }

        return cls_listRoster;

    }

    public static Map<Id, Boolean> checkPrerequisitesMap(Set<Id> objIds) {

        Map<Id, Boolean> ObjId_Bool = new Map<Id, Boolean>();

        List<lmscons__Prerequisites__c> Pre = [
            SELECT
                RecordType.DeveloperName,
                Id,
                lmscons__Course_Child__c,
                lmscons__Course__c,
                lmscons__Course_Child__r.Name,
                lmscons__Curriculum_Child__c,
                lmscons__Curriculum__c,
                lmscons__Curriculum_Child__r.Name,
                lmscons__Learning_Path_Child__c,
                lmscons__Learning_Path__c,
                lmscons__Learning_Path_Child__r.Name,
                lmscons__Module_Child__c,
                lmscons__Module__c,
                lmscons__Module_Child__r.lmscons__Title__c,
                lmscons__Quiz_Child__c,
                lmscons__Quiz__c,
                lmscons__Quiz_Child__r.Name,
                lmsilt__Event_Child__c,
                lmsilt__Event__c,
                lmsilt__Event_Child__r.Name
            FROM
                lmscons__Prerequisites__c
            WHERE
                    (lmscons__Quiz__c IN:objIds
                OR
                    lmscons__Module__c IN:objIds
                OR
                    lmsilt__Event__c IN:objIds
                OR
                    lmscons__Course__c IN:objIds
                OR
                    lmscons__Learning_Path__c IN:objIds
                OR
                    lmscons__Curriculum__c IN:objIds)
                order by
                    lmscons__Curriculum__c,
                    lmscons__Learning_Path__c,
                    lmscons__Course__c,
                    lmscons__Module__c,
                    lmscons__Quiz__c,
                    lmsilt__Event__c
                LIMIT 10000];

        Set<Id> MIds = new Set<Id>();
        Set<Id> QIds = new Set<Id>();
        Set<Id> EIds = new Set<Id>();
        Set<Id> CIds = new Set<Id>();
        Set<Id> LPIds = new Set<Id>();
        Set<Id> CuIds = new Set<Id>();

        Map<String, Set<Id>> Type_Id = new Map<String, Set<Id>>();

        if (Pre.size() > 0) {
            for (lmscons__Prerequisites__c p : Pre) {
                Set<Id> tmpIds = new Set<Id>();
                Id tmpIdChild = null;

                if (p.lmscons__Module_Child__c != null) {
                    MIds.add(p.lmscons__Module_Child__c);
                    tmpIdChild = p.lmscons__Module_Child__c;
                }
                else if (p.lmscons__Course_Child__c != null) {
                    CIds.add(p.lmscons__Course_Child__c);
                    tmpIdChild = p.lmscons__Course_Child__c;
                }
                else if (p.lmscons__Quiz_Child__c != null) {
                    QIds.add(p.lmscons__Quiz_Child__c);
                    tmpIdChild = p.lmscons__Quiz_Child__c;
                }
                else if (p.lmsilt__Event_Child__c != null) {
                    EIds.add(p.lmsilt__Event_Child__c);
                    tmpIdChild = p.lmsilt__Event_Child__c;
                }
                else if (p.lmscons__Learning_Path_Child__c != null) {
                    LPIds.add(p.lmscons__Learning_Path_Child__c);
                    tmpIdChild = p.lmscons__Learning_Path_Child__c;
                }
                else if (p.lmscons__Curriculum_Child__c != null) {
                    CuIds.add(p.lmscons__Curriculum_Child__c);
                    tmpIdChild = p.lmscons__Curriculum_Child__c;
                }


                Id tmpId = null;
                if (p.lmscons__Curriculum__c != null) {
                    tmpId = p.lmscons__Curriculum__c;
                }
                else if (p.lmscons__Learning_Path__c != null) {
                    tmpId = p.lmscons__Learning_Path__c;
                }
                else if (p.lmscons__Course__c != null) {
                    tmpId = p.lmscons__Course__c;
                }
                else if (p.lmscons__Module__c != null) {
                    tmpId = p.lmscons__Module__c;
                }
                else if (p.lmsilt__Event__c != null) {
                    tmpId = p.lmsilt__Event__c;
                }
                else if (p.lmscons__Quiz__c != null) {
                    tmpId = p.lmscons__Quiz__c;
                }

                if (Type_Id.containsKey(tmpId)) {
                    Type_Id.get(tmpId).add(tmpIdChild);
                } else {
                    Type_Id.put(tmpId, tmpIds);
                    Type_Id.get(tmpId).add(tmpIdChild);
                }
            }
        }

        Map<Id, lmscons__Training_Path_Assignment_Progress__c> IdCourse_ObjCourseAssignment = new Map<Id, lmscons__Training_Path_Assignment_Progress__c>();
        if (CIds.size() > 0) {
            List<lmscons__Training_Path_Assignment_Progress__c> TPAs = [SELECT Id, lmscons__Training_Path__c, lmscons__Progress_Training_Path__c FROM lmscons__Training_Path_Assignment_Progress__c WHERE lmscons__Training_Path__c IN: CIds and lmscons__Transcript__r.lmscons__Trainee__c = :UserInfo.getUserId()];
            if (TPAs.size() > 0) {
                for (lmscons__Training_Path_Assignment_Progress__c tp : TPAs) {
                    IdCourse_ObjCourseAssignment.put(tp.lmscons__Training_Path__c, tp);
                }
            }
        }

        if (Type_Id.size() > 0) {
            List<lmscons__Transcript_Line__c> TLs = [
                                        SELECT Id,
                                            lmscons__Training_Content__c,
                                            lmscons__Quiz__c,
                                            lmsilt__Event__c,
                                            lmscons__Curriculum_Assignment__r.lmscons__Curriculum_Progress__c,
                                            lmscons__Curriculum_Assignment__r.lmscons__Curriculum__c,
                                            lmscons__Curriculum_Assignment__c,
                                            lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__c,
                                            lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path_Progress__c,
                                            lmscons__Learning_Path_Assignment__c,
                                            lmscons__Training_Path_Item__r.lmscons__Training_Path__c,
                                            lmscons__Training_Path_Item__c,
                                            lmscons__Percent_Complete__c
                                        FROM
                                            lmscons__Transcript_Line__c
                                        WHERE
                                            (lmscons__Training_Content__c IN:MIds
                                        OR
                                            lmscons__Quiz__c IN: QIds
                                        OR
                                            lmsilt__Event__c IN: EIds
                                        OR
                                            lmscons__Curriculum_Assignment__r.lmscons__Curriculum__c IN:CuIds
                                        OR
                                            lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__c IN:LPIds
                                        OR
                                            lmscons__Training_Path_Item__r.lmscons__Training_Path__c IN:CIds)
                                        and
                                            lmscons__Transcript__r.lmscons__Trainee__c = :UserInfo.getUserId()];
            for (Id pId : Type_Id.keySet()) {
                for (lmscons__Transcript_Line__c tl: TLs) {
                    if (Type_Id.get(pId).size() > 0) {
                        if (tl.lmscons__Quiz__c == null && tl.lmsilt__Event__c == null) {
                            if (Type_Id.get(pId).contains(tl.lmscons__Training_Content__c) && tl.lmscons__Percent_Complete__c==100.00){
                                Type_Id.get(pId).remove(tl.lmscons__Training_Content__c);
                            }
                        }
                        if (tl.lmscons__Quiz__c != null) {
                            if(Type_Id.get(pId).contains(tl.lmscons__Quiz__c) && tl.lmscons__Percent_Complete__c==100.00){
                                Type_Id.get(pId).remove(tl.lmscons__Quiz__c);
                            }
                        }
                        if (tl.lmsilt__Event__c != null) {
                            if(Type_Id.get(pId).contains(tl.lmsilt__Event__c) && tl.lmscons__Percent_Complete__c==100.00){
                                Type_Id.get(pId).remove(tl.lmsilt__Event__c);
                            }
                        }
                        if (tl.lmscons__Training_Path_Item__c != null) {
                            if (Type_Id.get(pId).contains(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c)){
                                if (IdCourse_ObjCourseAssignment.containsKey(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c)) {
                                    if (IdCourse_ObjCourseAssignment.get(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c).lmscons__Progress_Training_Path__c == 100.00) {
                                        Type_Id.get(pId).remove(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c);
                                    }
                                }
                            }
                        }
                        if (tl.lmscons__Learning_Path_Assignment__c != null) {
                            if (Type_Id.get(pId).contains(tl.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__c) && tl.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path_Progress__c==100.00){
                                Type_Id.get(pId).remove(tl.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__c);
                            }
                        }
                        if (tl.lmscons__Curriculum_Assignment__c != null) {
                            if (Type_Id.get(pId).contains(tl.lmscons__Curriculum_Assignment__r.lmscons__Curriculum__c) && tl.lmscons__Curriculum_Assignment__r.lmscons__Curriculum_Progress__c==100.00){
                                Type_Id.get(pId).remove(tl.lmscons__Curriculum_Assignment__r.lmscons__Curriculum__c);
                            }
                        }
                    }
                }
            }

        }
        for (Id pId : objIds) {
            if (Type_Id.containsKey(pId)) {
                if (Type_Id.get(pId).size() > 0) {
                    ObjId_Bool.put(pId, true);
                }
                else {
                    ObjId_Bool.put(pId, false);
                }
            }
            else {
                ObjId_Bool.put(pId, false);
            }
        }


        return ObjId_Bool;
    }

    public static List<lmscons__Prerequisites__c> checkPrerequisites(String objType, Id objId) {
        List<lmscons__Prerequisites__c> Pre = new List<lmscons__Prerequisites__c>();
        List<lmscons__Prerequisites__c> PreFinal = new List<lmscons__Prerequisites__c>();

        system.debug('129: objType: '+objType);
        system.debug('130: objId: '+objId);

        try {
            if(objId != null && objType != null) {
                Pre = new List<lmscons__Prerequisites__c>();
                if(objType=='Quiz') {
                    Pre = [SELECT RecordType.DeveloperName, Id, lmscons__Course_Child__c, lmscons__Course_Child__r.Name, lmscons__Curriculum_Child__c, lmscons__Curriculum_Child__r.Name, lmscons__Learning_Path_Child__c, lmscons__Learning_Path_Child__r.Name, lmscons__Module_Child__c, lmscons__Module_Child__r.lmscons__Title__c, lmscons__Quiz_Child__c, lmscons__Quiz_Child__r.Name, lmsilt__Event_Child__c, lmsilt__Event_Child__r.Name FROM lmscons__Prerequisites__c WHERE lmscons__Quiz__c=:objId LIMIT 5000];
                }
                else if (objType=='Module') {
                    Pre = [SELECT RecordType.DeveloperName, Id, lmscons__Course_Child__c, lmscons__Course_Child__r.Name, lmscons__Curriculum_Child__c, lmscons__Curriculum_Child__r.Name, lmscons__Learning_Path_Child__c, lmscons__Learning_Path_Child__r.Name, lmscons__Module_Child__c, lmscons__Module_Child__r.lmscons__Title__c, lmscons__Quiz_Child__c, lmscons__Quiz_Child__r.Name, lmsilt__Event_Child__c, lmsilt__Event_Child__r.Name FROM lmscons__Prerequisites__c WHERE lmscons__Module__c=:objId LIMIT 5000];
                }
                else if (objType=='Event') {
                    Pre = [SELECT RecordType.DeveloperName, Id, lmscons__Course_Child__c, lmscons__Course_Child__r.Name, lmscons__Curriculum_Child__c, lmscons__Curriculum_Child__r.Name, lmscons__Learning_Path_Child__c, lmscons__Learning_Path_Child__r.Name, lmscons__Module_Child__c, lmscons__Module_Child__r.lmscons__Title__c, lmscons__Quiz_Child__c, lmscons__Quiz_Child__r.Name, lmsilt__Event_Child__c, lmsilt__Event_Child__r.Name FROM lmscons__Prerequisites__c WHERE lmsilt__Event__c=:objId LIMIT 5000];
                }
                else if (objType=='Course') {
                    Pre = [SELECT RecordType.DeveloperName, Id, lmscons__Course_Child__c, lmscons__Course_Child__r.Name, lmscons__Curriculum_Child__c, lmscons__Curriculum_Child__r.Name, lmscons__Learning_Path_Child__c, lmscons__Learning_Path_Child__r.Name, lmscons__Module_Child__c, lmscons__Module_Child__r.lmscons__Title__c, lmscons__Quiz_Child__c, lmscons__Quiz_Child__r.Name, lmsilt__Event_Child__c, lmsilt__Event_Child__r.Name FROM lmscons__Prerequisites__c WHERE lmscons__Course__c=:objId LIMIT 5000];
                }
                else if (objType=='LP') {
                    Pre = [SELECT RecordType.DeveloperName, Id, lmscons__Course_Child__c, lmscons__Course_Child__r.Name, lmscons__Curriculum_Child__c, lmscons__Curriculum_Child__r.Name, lmscons__Learning_Path_Child__c, lmscons__Learning_Path_Child__r.Name, lmscons__Module_Child__c, lmscons__Module_Child__r.lmscons__Title__c, lmscons__Quiz_Child__c, lmscons__Quiz_Child__r.Name, lmsilt__Event_Child__c, lmsilt__Event_Child__r.Name FROM lmscons__Prerequisites__c WHERE lmscons__Learning_Path__c=:objId LIMIT 5000];
                }
                else if (objType=='Curriculum') {
                    Pre = [SELECT RecordType.DeveloperName, Id, lmscons__Course_Child__c, lmscons__Course_Child__r.Name, lmscons__Curriculum_Child__c, lmscons__Curriculum_Child__r.Name, lmscons__Learning_Path_Child__c, lmscons__Learning_Path_Child__r.Name, lmscons__Module_Child__c, lmscons__Module_Child__r.lmscons__Title__c, lmscons__Quiz_Child__c, lmscons__Quiz_Child__r.Name, lmsilt__Event_Child__c, lmsilt__Event_Child__r.Name FROM lmscons__Prerequisites__c WHERE lmscons__Curriculum__c=:objId LIMIT 5000];
                }

                Set<Id> MIds = new Set<Id>();
                Set<Id> QIds = new Set<Id>();
                Set<Id> EIds = new Set<Id>();
                Set<Id> CIds = new Set<Id>();
                Set<Id> LPIds = new Set<Id>();
                Set<Id> CuIds = new Set<Id>();

                if(Pre.size() > 0) {
                    for(lmscons__Prerequisites__c p : Pre) {
                        if(p.lmscons__Module_Child__c != null) {
                            MIds.add(p.lmscons__Module_Child__c);
                        }
                        else if (p.lmscons__Course_Child__c != null) {
                            CIds.add(p.lmscons__Course_Child__c);
                        }
                        else if (p.lmscons__Quiz_Child__c != null) {
                            QIds.add(p.lmscons__Quiz_Child__c);
                        }
                        else if (p.lmsilt__Event_Child__c != null) {
                            EIds.add(p.lmsilt__Event_Child__c);
                        }
                        else if (p.lmscons__Learning_Path_Child__c != null) {
                            LPIds.add(p.lmscons__Learning_Path_Child__c);
                        }
                        else if (p.lmscons__Curriculum_Child__c != null) {
                            CuIds.add(p.lmscons__Curriculum_Child__c);
                        }

                    }
                }

                Map<Id, lmscons__Training_Path_Assignment_Progress__c> IdCourse_ObjCourseAssignment = new Map<Id, lmscons__Training_Path_Assignment_Progress__c>();
                if(CIds.size() > 0) {
                    List<lmscons__Training_Path_Assignment_Progress__c> TPAs = [SELECT Id, lmscons__Training_Path__c, lmscons__Progress_Training_Path__c FROM lmscons__Training_Path_Assignment_Progress__c WHERE lmscons__Training_Path__c IN: CIds and lmscons__Transcript__r.lmscons__Trainee__c = :UserInfo.getUserId()];
                    if(TPAs.size() > 0) {
                        for(lmscons__Training_Path_Assignment_Progress__c tp : TPAs) {
                            IdCourse_ObjCourseAssignment.put(tp.lmscons__Training_Path__c, tp);
                        }
                    }
                }

                List<lmscons__Transcript_Line__c> TLs = [SELECT Id,
                                                    lmscons__Training_Content__c,
                                                    lmscons__Quiz__c,
                                                    lmsilt__Event__c,
                                                    lmscons__Curriculum_Assignment__r.lmscons__Curriculum_Progress__c,
                                                    lmscons__Curriculum_Assignment__r.lmscons__Curriculum__c,
                                                    lmscons__Curriculum_Assignment__c,
                                                    lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__c,
                                                    lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path_Progress__c,
                                                    lmscons__Learning_Path_Assignment__c,
                                                    lmscons__Training_Path_Item__r.lmscons__Training_Path__c,
                                                    lmscons__Training_Path_Item__c,
                                                    lmscons__Percent_Complete__c
                                                FROM
                                                    lmscons__Transcript_Line__c
                                                WHERE
                                                    (lmscons__Training_Content__c IN:MIds
                                                OR
                                                    lmscons__Quiz__c IN: QIds
                                                OR
                                                    lmsilt__Event__c IN: EIds
                                                OR
                                                    lmscons__Curriculum_Assignment__r.lmscons__Curriculum__c IN:CuIds
                                                OR
                                                    lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__c IN:LPIds
                                                OR
                                                    lmscons__Training_Path_Item__r.lmscons__Training_Path__c IN:CIds)
                                                and
                                                    lmscons__Transcript__r.lmscons__Trainee__c = :UserInfo.getUserId()];
                Set<Id> RemMIds = new Set<Id>();
                Set<Id> RemQIds = new Set<Id>();
                Set<Id> RemEIds = new Set<Id>();
                Set<Id> RemCIds = new Set<Id>();
                Set<Id> RemLPIds = new Set<Id>();
                Set<Id> RemCuIds = new Set<Id>();

                for(lmscons__Transcript_Line__c tl: TLs) {
                    if(MIds.size() > 0) {
                        if(tl.lmscons__Quiz__c == null && tl.lmsilt__Event__c == null) {
                            if(MIds.contains(tl.lmscons__Training_Content__c) && tl.lmscons__Percent_Complete__c==100.00){
                                RemMIds.add(tl.lmscons__Training_Content__c);
                                MIds.remove(tl.lmscons__Training_Content__c);
                            }
                        }
                    }

                    if(QIds.size() > 0) {
                        if(tl.lmscons__Quiz__c != null) {
                            if(QIds.contains(tl.lmscons__Quiz__c) && tl.lmscons__Percent_Complete__c==100.00){
                                RemQIds.add(tl.lmscons__Quiz__c);
                                QIds.remove(tl.lmscons__Quiz__c);
                            }
                        }
                    }
                    if(EIds.size() > 0) {
                        if(tl.lmsilt__Event__c != null) {
                            if(EIds.contains(tl.lmsilt__Event__c) && tl.lmscons__Percent_Complete__c==100.00){
                                RemEIds.add(tl.lmsilt__Event__c);
                                EIds.remove(tl.lmsilt__Event__c);
                            }
                        }
                    }

                    if(CIds.size() > 0) {
                        if(tl.lmscons__Training_Path_Item__c != null) {
                            if(CIds.contains(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c)){
                                if(IdCourse_ObjCourseAssignment.containsKey(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c)) {
                                    if(IdCourse_ObjCourseAssignment.get(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c).lmscons__Progress_Training_Path__c == 100.00) {
                                        RemCIds.add(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c);
                                        CIds.remove(tl.lmscons__Training_Path_Item__r.lmscons__Training_Path__c);
                                    }
                                }
                            }
                        }
                    }

                    if(LPIds.size() > 0) {
                        if(tl.lmscons__Learning_Path_Assignment__c != null) {
                            if(LPIds.contains(tl.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__c) && tl.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path_Progress__c==100.00){
                                RemLPIds.add(tl.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__c);
                                LPIds.remove(tl.lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__c);
                            }
                        }
                    }

                    if(CuIds.size() > 0) {
                        if(tl.lmscons__Curriculum_Assignment__c != null) {
                            if(CuIds.contains(tl.lmscons__Curriculum_Assignment__r.lmscons__Curriculum__c) && tl.lmscons__Curriculum_Assignment__r.lmscons__Curriculum_Progress__c==100.00){
                                RemCuIds.add(tl.lmscons__Curriculum_Assignment__r.lmscons__Curriculum__c);
                                CuIds.remove(tl.lmscons__Curriculum_Assignment__r.lmscons__Curriculum__c);
                            }
                        }
                    }
                }

                if(MIds.size() > 0 || QIds.size() > 0 || CIds.size() > 0 || LPIds.size() > 0 || CuIds.size() > 0 || EIds.size() > 0) {
                    for(lmscons__Prerequisites__c p : Pre) {
                        if(MIds.size() > 0 && p.lmscons__Module_Child__c != null) {
                            if(MIds.contains(p.lmscons__Module_Child__c)) {
                                PreFinal.add(p);
                            }
                        }

                        if(QIds.size() > 0 && p.lmscons__Quiz_Child__c != null) {
                            if(QIds.contains(p.lmscons__Quiz_Child__c)) {
                                PreFinal.add(p);
                            }
                        }

                        if(EIds.size() > 0 && p.lmsilt__Event_Child__c != null) {
                            if(EIds.contains(p.lmsilt__Event_Child__c)) {
                                PreFinal.add(p);
                            }
                        }

                        if(CIds.size() > 0 && p.lmscons__Course_Child__c != null) {
                            if(CIds.contains(p.lmscons__Course_Child__c)) {
                                PreFinal.add(p);
                            }
                        }

                        if(LPIds.size() > 0 && p.lmscons__Learning_Path_Child__c != null) {
                            if(LPIds.contains(p.lmscons__Learning_Path_Child__c)) {
                                PreFinal.add(p);
                            }
                        }

                        if(CuIds.size() > 0 && p.lmscons__Curriculum_Child__c != null) {
                            if(CuIds.contains(p.lmscons__Curriculum_Child__c)) {
                                PreFinal.add(p);
                            }
                        }
                    }
                }

                if(PreFinal.size() > 0) {
                    Pre.clear();
                    Pre.addall(PreFinal);
                }
                else {
                    return null;
                }

            }

        }
        catch (system.exception e) {
            system.debug(e);
            return null;
        }

        return Pre;
    }


    public static void upsertRoster(List<lmsilt__Roster__c> r){
        upsert r;
    }

    public static void updateILTAssignment(List<lmscons__Transcript_Line__c> ILTAssignmentList){
        update ILTAssignmentList;
    }

    public static void updateMeetings(Id ClassId) {
        List<lmsilt__Session__c> sess = [SELECT Id, lmsilt__Meeting__c, lmsilt__ILT_vILT__c, lmsilt__Meeting_Type__c  FROM lmsilt__Session__c WHERE lmsilt__Class__c = :ClassId];
        if(sess.size() > 0) {
            String query = ' (';
            Set<Id> ques = new Set<Id>();
            boolean updateWebEx = false;
            boolean updateGTT = false;
            for (lmsilt__Session__c s : sess) {
                if (s.lmsilt__Meeting__c != null && s.lmsilt__ILT_vILT__c == 'vILT' && s.lmsilt__Meeting_Type__c == 'WebEx') {
                    updateWebEx = true;
                    query += '\'' + s.Id + '\',';
                }
                if (s.lmsilt__Meeting__c != null && s.lmsilt__ILT_vILT__c == 'vILT' && s.lmsilt__Meeting_Type__c == 'GoToTraining') {
                    ques.add(s.Id);
                    updateGTT = true;
                    query += '\'' + s.Id + '\',';
                }
            }
            query = query.substring(0, query.length()-1) + ')';
            if(updateWebEx == true) {
                lmsilt.BatchUpdateWebEx b = new lmsilt.BatchUpdateWebEx();
                b.Query = 'SELECT Id FROM lmsilt__Session__c WHERE Id IN '+query;
                ID bid = Database.executeBatch(b,1);
            }
        }
    }


    public static List<lmscons__Transcript_Line__c> getAssignmentList(){
        return [Select
            lmscons__Learning_Path_Assignment__c,
            lmscons__Learning_Path_Assignment__r.lmscons__Due_Date__c,
            lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.lmscons__Duration__c,
            lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.MKT_Total_hours__c,
            lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.lmscons__Description__c,
            lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path_Progress__c,
            lmscons__Learning_Path_Assignment__r.lmscons__Status__c,
            lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.Name,
            lmscons__Learning_Path_Assignment__r.lmscons__Learning_Path__r.lmscons__Enforce_Sequence__c,
            lmscons__Learning_Path_Item__r.lmscons__Sequence__c,
            lmscons__Learning_Path_Item__r.lmscons__Module__r.lmscons__Title__c,
            lmscons__Learning_Path_Item__r.lmscons__Module__r.lmscons__Description__c,
            lmscons__Learning_Path_Item__r.lmscons__Course__r.Name,
            lmscons__Learning_Path_Item__r.lmscons__Course__r.lmscons__Description__c,
            lmscons__Curriculum_Assignment__c,
            lmscons__Curriculum_Assignment__r.lmscons__Curriculum_Progress__c,
            lmscons__Curriculum_Assignment__r.lmscons__Status__c ,
            lmscons__Curriculum_Assignment__r.lmscons__Due_Date__c,
            lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.lmscons__Duration__c,
            lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.MKT_Total_hours__c,
            lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.lmscons__Description__c,
            lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.Name,
            lmscons__Curriculum_Assignment__r.lmscons__Curriculum__r.lmscons__Enforce_Sequence__c,
            lmscons__Curriculum_Item__r.lmscons__Sequence__c,
            lmscons__Curriculum_Item__r.lmscons__Module__c,
            lmscons__Curriculum_Item__r.lmscons__Module__r.lmscons__Title__c,
            lmscons__Curriculum_Item__r.lmscons__Module__r.lmscons__Description__c,
            lmscons__Curriculum_Item__r.lmscons__Course__c,
            lmscons__Curriculum_Item__r.lmscons__Course__r.Name,
            lmscons__Curriculum_Item__r.lmscons__Course__r.lmscons__Description__c,
            lmscons__Curriculum_Item__r.lmscons__Learning_Path__c,
            lmscons__Curriculum_Item__r.lmscons__Learning_Path__r.Name,
            lmscons__Curriculum_Item__r.lmscons__Learning_Path__r.lmscons__Description__c,
            lmscons__Curriculum_Item__r.lmsilt__Event__c,
            lmscons__Curriculum_Item__r.lmsilt__Event__r.Name,
            lmscons__Curriculum_Item__r.lmsilt__Event__r.lmsilt__Description__c,
            lmscons__Curriculum_Item__r.lmscons__Quiz__c,
            lmscons__Curriculum_Item__r.lmscons__Quiz__r.Name,
            lmscons__Curriculum_Item__c,
            lmscons__Quiz__c,
            lmscons__Quiz__r.lmscons__Description__c,
            lmscons__Training_Content__r.lmscons__Quiz__c,
            lmscons__Learning_Path_Item__r.lmsilt__Development_Plan_Task__c,
            lmscons__Learning_Path_Item__r.lmsilt__Development_Plan_Task__r.Name,
            lmscons__Learning_Path_Item__r.lmsilt__Development_Plan_Task__r.lmsilt__Description__c,
            lmscons__Learning_Path_Item__r.lmsilt__Development_Plan_Task__r.lmsilt__URL__c,
            lmscons__Learning_Path_Item__r.lmscons__Quiz__c,
            lmscons__Learning_Path_Item__r.lmscons__Quiz__r.Name,
            lmscons__Learning_Path_Item__r.lmsilt__Event__c,
            lmscons__Learning_Path_Item__r.lmsilt__Event__r.Name,
            lmscons__Curriculum_Item__r.lmsilt__Development_Plan_Task__c,
            lmscons__Curriculum_Item__r.lmsilt__Development_Plan_Task__r.Name,
            lmscons__Curriculum_Item__r.lmsilt__Development_Plan_Task__r.lmsilt__Description__c,
            lmscons__Curriculum_Item__r.lmsilt__Development_Plan_Task__r.lmsilt__URL__c,
            lmscons__Training_Content__r.lmsilt__Development_Plan_Task__c,
            lmscons__Training_Content__r.lmsilt__Development_Plan_Task__r.Name,
            lmscons__Training_Content__r.lmsilt__Development_Plan_Task__r.lmsilt__Description__c,
            lmscons__Training_Content__r.lmsilt__Development_Plan_Task__r.lmsilt__URL__c,
            lmsilt__Development_Plan_Task__c,
            lmsilt__Development_Plan_Task__r.Name,
            lmscons__Training_Content__c,
            lmscons__Training_Content__r.lmscons__Duration__c,
            lmscons__Training_Content__r.MKT_Total_hours__c,
            lmscons__Training_Content__r.lmsilt__Module_Type__c,
            lmscons__Training_Content__r.lmsilt__Event__c,
            lmscons__Training_Content__r.lmsilt__Event__r.Name,
            lmscons__Training_Content__r.lmscons__Description__c,
            lmscons__Training_Content__r.lmscons__Title__c,
            lmscons__Training_Content__r.lmscons__Cornerstone_ID__c,
            lmscons__Training_Path_Item__r.lmscons__Sequence__c,
            lmscons__Training_Path_Item__r.lmscons__Training_Path__c,
            lmscons__Training_Path_Item__r.lmscons__Training_Path__r.lmscons__Enforce_Curriculum_Sequence__c,
            lmscons__Training_Path_Item__r.lmscons__Training_Path__r.Id,
            lmscons__Training_Path_Item__r.lmscons__Training_Path__r.lmscons__Duration__c,
            lmscons__Training_Path_Item__r.lmscons__Training_Path__r.MKT_Total_hours__c,
            lmscons__Training_Path_Item__r.lmscons__Training_Path__r.lmscons__Description__c,
            lmscons__Training_Path_Item__r.lmscons__Training_Path__r.Name,
            lmscons__Last_Launched_Date__c,
            lmscons__Completion_Date__c,
            lmscons__Transcript__c,
            lmscons__Status__c,
            lmscons__Percent_Complete__c,
            lmscons__Score__c,
            lmscons__Progress__c,
            lmscons__Due_Date__c,
            lmscons__Completed_Date__c,
            lmsilt__Class__c,
            lmsilt__Class__r.lmsilt__Total_hours__c,
            lmsilt__Class__r.MKT_Total_hours__c,
            lmsilt__Event__c,
            lmsilt__Event__r.Name,
            lmsilt__Event__r.lmsilt__Description__c,
            lmsilt__Roster__c,
            lmsilt__Roster__r.lmsilt__Status__c,
            lmsilt__Roster__r.lmsilt__Score__c,
            lmscons__Training_User_License__c,
            lmscons__Training_User_License__r.lmscons__User__c
            FROM lmscons__Transcript_Line__c
            WHERE
                lmscons__Training_Content__r.lmscons__Cornerstone_ID__c != null And
                lmscons__Transcript__r.lmscons__Trainee__c =: UserInfo.getUserID() and
                lmsilt__Dev_Plan_Assignment__c = null
                ORDER BY lmscons__Curriculum_Assignment__c,
                        lmscons__Curriculum_Item__r.lmscons__Sequence__c,
                        lmscons__Learning_Path_Assignment__c,
                        lmscons__Learning_Path_Item__r.lmscons__Sequence__c,
                        lmscons__Training_Path_Item__r.lmscons__Training_Path__c,
                        lmscons__Training_Path_Item__r.lmscons__Sequence__c
                ];
    }


    public static List<lmscons__Training_Path_Assignment_Progress__c> getCourseAssignmentList(Set<Id> TPSet){
        return [SELECT lmscons__Due_Date__c, lmscons__Training_Path__c, lmscons__StatusPicklist__c, lmscons__Progress_Training_Path__c, Id FROM lmscons__Training_Path_Assignment_Progress__c WHERE lmscons__Training_Path__c IN:TPSet and lmscons__Transcript__r.lmscons__Trainee__c =: UserInfo.getUserID()];
    }

    public static lmsilt__Event__c getEventDetails(Id EventIdDetails) {
        return [SELECT Id, Name, lmsilt__Description__c FROM lmsilt__Event__c WHERE Id = :EventIdDetails];
    }

    public static List<lmsilt__Session__c> getSessionByClassId(Id ClassId){
        return [SELECT Id, lmsilt__Start_Date_Time__c, lmsilt__ILT_vILT__c, lmsilt__Meeting_Type__c, lmsilt__Meeting__c, lmsilt__End_Date_Time__c, lmsilt__Session_Location__c, lmsilt__Session_Location__r.Name
                FROM lmsilt__Session__c
                WHERE lmsilt__Class__c = :ClassId];
    }

    public static List<lmsilt__Material__c> getMaterialWithAttachList(Id ClassIdDetails, Id EventIdDetails) {
        return [SELECT Id, lmsilt__Description__c, lmsilt__Instructions__c, Name, (SELECT Id, Name FROM Attachments)
                FROM lmsilt__Material__c
                WHERE lmsilt__Class__c = :ClassIdDetails OR lmsilt__Event__c =: EventIdDetails];
    }

    public static lmsilt__Roster__c getRosterByUserAndClass(Id ClassIdDetails) {
        return [SELECT lmsilt__Status__c, lmsilt__Attended__c, Id
                FROM lmsilt__Roster__c
                WHERE lmsilt__Student__c = :UserInfo.getUserId() AND lmsilt__Class__c = :ClassIdDetails];
    }

    public static List<lmsilt__Class__c> getClassListByEventId(Id EventIdDetails) {
        return [SELECT Id, Name, lmsilt__Start_Date__c, lmsilt__End_Date__c,
                    (SELECT Id, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, lmsilt__ILT_vILT__c, lmsilt__Session_Location__c, lmsilt__Session_Location__r.Name, lmsilt__Class__c, lmsilt__Event__c, lmsilt__Start_Date_Time__c, lmsilt__End_Date_Time__c
                    FROM lmsilt__Sessions__r
                    ORDER BY lmsilt__Start_Date_Time__c)
                FROM lmsilt__Class__c
                WHERE lmsilt__Event__c = :EventIdDetails];
    }

    public static List<lmscons__Transcript_Line__c> getTranscriptLineListByEventId(Id EventIdDetails) {
        return [SELECT Id, lmsilt__Class__c, lmsilt__Roster__c
                FROM lmscons__Transcript_Line__c
                WHERE lmsilt__Event__c = :EventIdDetails AND lmscons__Transcript__r.lmscons__Trainee__c =: userinfo.getUserId()];
    }

    public static List<lmsilt__Development_Plan_Assignment__c> getDevPlanAssignmentList() {
        return [SELECT Id, CreatedDate, lmsilt__Development_Plan__c, lmsilt__Development_Plan__r.lmsilt__Description__c, lmsilt__Development_Plan__r.Name, lmsilt__Transcript__c, lmsilt__Development_Plan__r.lmsilt__Start__c
                FROM lmsilt__Development_Plan_Assignment__c
                WHERE lmsilt__Transcript__r.lmscons__Trainee__c =: UserInfo.getUserID()];
    }

    public static lmsilt__Development_Plan_Task__c getDevPlanTask(Id TaskId) {
        return [SELECT l.lmsilt__User__c, l.lmsilt__Task_Manager__c, l.lmsilt__Description__c, l.Name, l.Id
                FROM lmsilt__Development_Plan_Task__c l
                WHERE l.Id =: TaskId];
    }

    public static lmscons__Transcript_Line__c getTranscriptLine(Id TrLineId) {
        return [SELECT Id, lmscons__Status__c, lmscons__Score__c
                FROM lmscons__Transcript_Line__c
                WHERE Id =: TrLineId];
    }

    public static List<lmsilt__Session__c> getILTSessionListByClsIds(Set<Id> ClassIds) {
        return [SELECT Id, lmsilt__Start_Date_Time__c, lmsilt__End_Date_Time__c, lmsilt__Class__r.Name, lmsilt__Class__r.lmsilt__Event__c, lmsilt__Meeting__r.lmsilt__Meetingkey__c
                FROM lmsilt__Session__c
                WHERE lmsilt__ILT_vILT__c = 'vILT' AND lmsilt__Class__c IN: ClassIds AND lmsilt__Meeting_Type__c != null AND lmsilt__Meeting__c != null];
    }

    public static void insertUserLicenseWOSH(List<lmscons__Training_User_License__c> user_licenses){
        insert user_licenses;
    }

    public static Id getTranscriptId(){
        ID tmpTra;
        try {
            tmpTra = [Select Id From lmscons__Transcript__c Where lmscons__Trainee__c =: userinfo.getUserId() LIMIT 1].Id;
        }
        catch (system.exception e) { }

        if(tmpTra != null){
            return tmpTra;
        }
        else {
            List<lmscons__Transcript__c> t = new List<lmscons__Transcript__c>();
            t.add( new lmscons__Transcript__c(
                lmscons__Trainee__c = userinfo.getUserId()
            ));

            if (t.size() > 0){
                if (lmscons__Transcript__c.lmscons__Trainee__c.getDescribe().isCreateAble()) {
                    insert t;
                }
                else {
                    throw new lmscons.SFDCAccessControlException(
                        'FLS Access Violation, //HelperWithoutSharing.cls [getTranscriptId]',
                        lmscons.SFDCAccessControlException.ExceptionType.FIELD_ACCESS_VIOLATION,
                        lmscons.SFDCAccessControlException.ExceptionReason.NO_CREATE,
                        lmscons__Transcript__c.SObjectType.getDescribe().getName(),
                        NULL
                    );
                }
                tmpTra = t[0].Id;
            }
            return tmpTra;
        }
    }

    public static map<String, Set<Id>> getIdModulesCoursesLPCuFromCatalogByProfileId() {
        Set<Id> idsQuizes = new Set<Id>();
        Set<Id> idsEvents = new Set<Id>();
        Set<Id> idsModules = new Set<Id>();
        Set<Id> idsCourses = new Set<Id>();
        Set<Id> idsLP = new Set<Id>();
        Set<Id> idsCurr = new Set<Id>();
        Set<Id> idsCatalogs = new Set<Id>();
        map<String, Set<Id>> rVal = new map<String, Set<Id>>();

        Set<String> Groups = getGroupsIds(new Set<Id>());

        // default groups logic
        String PublicGroupName = 'none';
        User curr_user = [select id, UserType, AccountId from User where Id=: UserInfo.getUserId()];

        if (curr_user.UserType.equalsIgnoreCase('Standard')) {
            PublicGroupName = 'All Internal Users';
        }
        else if (curr_user.UserType.equalsIgnoreCase('PowerPartner')) {
            PublicGroupName = 'All Partner Users';
        }
        else if (curr_user.UserType.equalsIgnoreCase('CSPLitePortal') || curr_user.UserType.equalsIgnoreCase('CustomerSuccess') || curr_user.UserType.equalsIgnoreCase('PowerCustomerSuccess')) {
            PublicGroupName = 'All Customer Portal Users';
        }

        List<lmscons__Catalog_Profile__c> cps = [select lmscons__Catalog__c from lmscons__Catalog_Profile__c where lmscons__Profile_Id__c LIKE:'%'+UserInfo.getProfileId()+'%'];
        List<lmscons__Catalog_Group__c> cgs = [select lmscons__Catalog__c from lmscons__Catalog_Group__c where lmscons__Group_Id__c IN : Groups OR lmscons__Group_Name__c =: PublicGroupName];

        system.debug('select lmscons__Catalog__c from lmscons__Catalog_Profile__c where lmscons__Profile_Id__c LIKE:%'+UserInfo.getProfileId()+'%');

        if (cps.size() > 0 || cgs.size() > 0) {
            for(lmscons__Catalog_Profile__c cp : cps){
                idsCatalogs.add(cp.lmscons__Catalog__c);
            }

            for (lmscons__Catalog_Group__c cg : cgs) {
                idsCatalogs.add(cg.lmscons__Catalog__c);
            }

            // Get ILT Events START -------

            for (lmsilt__Event_Catalog__c a : [Select Id, lmsilt__Event__r.lmsilt__Description__c, lmsilt__Event__r.Name, lmsilt__Event__r.Id, lmsilt__Event__c, lmsilt__Catalog__c From lmsilt__Event_Catalog__c where lmsilt__Catalog__c IN : idsCatalogs limit 1000]) {
                    idsEvents.add(a.lmsilt__Event__c);
                }
            rVal.put('Events', idsEvents);

            // Get ILT Events END -------

            for (lmscons__Catalog_Quiz__c ctq : [SELECT lmscons__Quiz__c FROM lmscons__Catalog_Quiz__c  WHERE lmscons__Catalog__c IN: idsCatalogs limit 10000]) idsQuizes.add(ctq.lmscons__Quiz__c);
            rVal.put('Quizes', idsQuizes);

            List<lmscons__Catalog_Training_Path__c> ctps = [select lmscons__Training_Path__c from lmscons__Catalog_Training_Path__c where lmscons__Catalog__c IN: idsCatalogs limit 1000];
            if(ctps.size()>0){
                for(lmscons__Catalog_Training_Path__c ctp : ctps){
                    idsCourses.add(ctp.lmscons__Training_Path__c);
                }
                rVal.put('Courses', idsCourses);
            }

            List<lmscons__Catalog_Course__c> ccs = [select lmscons__Training_Course__c from lmscons__Catalog_Course__c where lmscons__Catalog__c IN: idsCatalogs limit 1000];
            if(ccs.size()>0){
                for(lmscons__Catalog_Course__c cc : ccs){
                    idsModules.add(cc.lmscons__Training_Course__c);
                }
                rVal.put('Modules', idsModules);
            }

            /*Search Learning Path*/
            List<lmscons__Catalog_Learning_Path__c> clps = [select lmscons__Learning_Path__c from lmscons__Catalog_Learning_Path__c where lmscons__Catalog__c IN: idsCatalogs limit 1000];
            if(clps.size()>0){
                for(lmscons__Catalog_Learning_Path__c clp : clps){
                    idsLP.add(clp.lmscons__Learning_Path__c);
                }
                rVal.put('LP', idsLP);
            }

            /*Search Curriculum*/
            List<lmscons__Catalog_Curriculum__c> ccus = [select lmscons__Curriculum__c from lmscons__Catalog_Curriculum__c where lmscons__Catalog__c IN: idsCatalogs limit 1000];
            if(ccus.size()>0){
                for(lmscons__Catalog_Curriculum__c ccu : ccus){
                    idsCurr.add(ccu.lmscons__Curriculum__c);
                }
                rVal.put('Cu', idsCurr);
            }
        }
        return rVal;
    }

    public static map<String, Set<Id>> getIdModulesCoursesLPFromCurriculum(String CurId) {
        Set<Id> idsQuizes = new Set<Id>();
        Set<Id> idsEvents = new Set<Id>();
        Set<Id> idsModules = new Set<Id>();
        Set<Id> idsCourses = new Set<Id>();
        Set<Id> idsLP = new Set<Id>();
        map<String, Set<Id>> rVal = new map<String, Set<Id>>();

        List<lmscons__Curriculum_Item__c> curItems = [SELECT lmscons__Quiz__c, lmsilt__Event__c, lmscons__Module__c, lmscons__Learning_Path__c, lmscons__Course__c FROM lmscons__Curriculum_Item__c WHERE lmscons__Curriculum__c = : CurId];
        for(lmscons__Curriculum_Item__c curItem : curItems){
            if (curItem.lmscons__Quiz__c != NULL) {
                idsQuizes.Add(curItem.lmscons__Quiz__c);
            }
            else if (curItem.lmsilt__Event__c != NULL) {
                idsEvents.Add(curItem.lmsilt__Event__c);
            }
            else if (curItem.lmscons__Module__c != NULL) {
                idsModules.Add(curItem.lmscons__Module__c);
            }
            else if (curItem.lmscons__Course__c != NULL) {
                idsCourses.Add(curItem.lmscons__Course__c);
            }
            else if (curItem.lmscons__Learning_Path__c != NULL) {
                idsLP.Add(curItem.lmscons__Learning_Path__c);
            }
        }
        rVal.put('Events', idsEvents);
        rVal.put('Quizes', idsQuizes);
        rVal.put('Courses', idsCourses);
        rVal.put('Modules', idsModules);
        rVal.put('LP', idsLP);
        return rVal;
    }

    public static Set<Id> getIdsEventsFromCurriculum(String CurId) {
        Set<Id> idsEvents = new Set<Id>();

        List<lmscons__Curriculum_Item__c> curItems = [SELECT lmscons__Quiz__c, lmsilt__Event__c, lmscons__Module__c, lmscons__Learning_Path__c, lmscons__Course__c FROM lmscons__Curriculum_Item__c WHERE lmscons__Curriculum__c = : CurId];
        for (lmscons__Curriculum_Item__c curItem : curItems){
            if (curItem.lmsilt__Event__c != NULL) {
                idsEvents.Add(curItem.lmsilt__Event__c);
            }
        }
        return idsEvents;
    }

    public static Map<Id,lmscons__Transcript_Line__c> getAssignmentEvents() {
        Map<Id,lmscons__Transcript_Line__c> EventIdAssignmentMap = new Map<Id,lmscons__Transcript_Line__c>();

        for (lmscons__Transcript_Line__c tl : [SELECT Id, lmsilt__Event__c, lmsilt__Class__c FROM lmscons__Transcript_Line__c t WHERE lmscons__Training_User_License__r.lmscons__User__c =: UserInfo.getUserId() AND lmscons__Curriculum_Item__c = NULL AND lmscons__Learning_Path_Item__c = NULL AND lmscons__Training_Path_Item__c = NULL AND lmsilt__Event__c != NULL]){
            EventIdAssignmentMap.put(tl.lmsilt__Event__c, tl);
        }
        return EventIdAssignmentMap;
    }

    public static Map<Id, PricebookEntry> getProductsPrice(List<lmscons__Training_Path__c> ListCourses, List<lmscons__Learning_Path__c> ListLP, List<lmscons__Curriculum__c> ListCurr, List<lmsilt__Event__c> ListEvents, List<lmscons__Quiz__c> ListQuizes, List<lmscons__Training_Content__c> ListModules) {
        Set<Id> ProductIds = new Set<Id>();
        Map<Id, PricebookEntry> ProductIdPricebookEntry = new Map<Id, PricebookEntry>();
        Map<Id, List<PricebookEntry>> ProductIdListPricebookEntry = new Map<Id, List<PricebookEntry>>();
        if (ListCourses != NULL) {
            for (lmscons__Training_Path__c courseItem : ListCourses) {
                if (courseItem.Product__c != NULL && courseItem.Product__r.isActive == true) {
                    ProductIds.Add(courseItem.Product__c);
                }
            }
        }
        if (ListLP != NULL) {
            for (lmscons__Learning_Path__c lpItem : ListLP) {
                if (lpItem.Product__c != NULL && lpItem.Product__r.isActive == true) {
                    ProductIds.Add(lpItem.Product__c);
                }
            }
        }
        if (ListCurr != NULL) {
            for (lmscons__Curriculum__c currItem : ListCurr) {
                if (currItem.Product__c != NULL && currItem.Product__r.isActive == true) {
                    ProductIds.Add(currItem.Product__c);
                }
            }
        }
        if (ListQuizes != NULL) {
            for (lmscons__Quiz__c quizItem : ListQuizes) {
                if (quizItem.Product__c != NULL && quizItem.Product__r.isActive == true) {
                    ProductIds.Add(quizItem.Product__c);
                }
            }
        }
        if (ListEvents != NULL) {
            for (lmsilt__Event__c eventItem : ListEvents) {
                if (eventItem.Product__c != NULL && eventItem.Product__r.isActive == true) {
                    ProductIds.Add(eventItem.Product__c);
                }
            }
        }
        if (ListModules != NULL) {
            for (lmscons__Training_Content__c moduleItem : ListModules) {
                if (moduleItem.Product__c != NULL && moduleItem.Product__r.isActive == true) {
                    ProductIds.Add(moduleItem.Product__c);
                }
            }
        }
        MKT_Setting__c CustomSetting = MKT_Setting__c.getInstance();
        String DefaultCurrency = (UserInfo.getDefaultCurrency() == NULL) ? 'USD' : UserInfo.getDefaultCurrency();
        //List<Product2> ProductsList = [SELECT Id, Name, (SELECT Id, CurrencyIsoCode, Name, UnitPrice, Pricebook2.Name, Pricebook2.IsStandard FROM PricebookEntries WHERE Pricebook2Id != NULL AND Pricebook2.IsDeleted = false AND (Pricebook2.Name = :CustomSetting.PriceBookName__c OR Pricebook2.IsStandard = true) AND Pricebook2.IsActive = true AND IsDeleted = false AND IsActive = true ORDER BY Pricebook2.IsStandard DESC) FROM Product2 WHERE Id IN :ProductIds];
        for (PricebookEntry priceEntryItem : [SELECT Id, Pricebook2Id,Product2Id, CurrencyIsoCode, Name, UnitPrice, Pricebook2.Name, Pricebook2.IsStandard FROM PricebookEntry WHERE Pricebook2Id != NULL AND Pricebook2.IsDeleted = false AND (Pricebook2.Name = :CustomSetting.PriceBookName__c OR Pricebook2.IsStandard = true) AND Pricebook2.IsActive = true AND IsDeleted = false AND IsActive = true AND Product2Id IN :ProductIds ORDER BY Pricebook2.IsStandard DESC]) {
            if (ProductIdListPricebookEntry.containsKey(priceEntryItem.Product2Id)) {
                ProductIdListPricebookEntry.get(priceEntryItem.Product2Id).Add(priceEntryItem);
            }
            else {
                List<PricebookEntry> priceEntries = new List<PricebookEntry>();
                priceEntries.Add(priceEntryItem);
                ProductIdListPricebookEntry.put(priceEntryItem.Product2Id, priceEntries);
            }
        }
        for (Id Product2ItemID : ProductIdListPricebookEntry.keySet()) {
            if (ProductIdListPricebookEntry.get(Product2ItemID).size() > 0) {
                List<PricebookEntry> PricebookEntryListOfDefaultPrice = new List<PricebookEntry>();
                List<PricebookEntry> PricebookEntryListPrice = new List<PricebookEntry>();
                List<PricebookEntry> PricebookEntryListStandartPrice = new List<PricebookEntry>();

                for (PricebookEntry PricebookEntryItem : ProductIdListPricebookEntry.get(Product2ItemID)) {
                    if (PricebookEntryItem.Pricebook2.Name == CustomSetting.PriceBookName__c) {
                        PricebookEntryListOfDefaultPrice.Add(PricebookEntryItem);
                    }
                    else if (PricebookEntryItem.Pricebook2.IsStandard){
                        PricebookEntryListStandartPrice.Add(PricebookEntryItem);
                    }
                    else {
                        PricebookEntryListPrice.Add(PricebookEntryItem);
                    }
                }
                if (PricebookEntryListOfDefaultPrice.size() > 0) {
                    for (PricebookEntry PricebookEntryItem : PricebookEntryListOfDefaultPrice) {
                        if (PricebookEntryItem.CurrencyIsoCode == DefaultCurrency) {
                            ProductIdPricebookEntry.put(Product2ItemId, PricebookEntryItem);
                            break;
                        }
                    }
                    if (!ProductIdPricebookEntry.containsKey(Product2ItemId)) {
                        ProductIdPricebookEntry.put(Product2ItemId, PricebookEntryListOfDefaultPrice[0]);
                    }

                }
                if (ProductIdPricebookEntry.containsKey(Product2ItemId)) {
                    continue;
                }
                if (PricebookEntryListStandartPrice.size() > 0) {
                    for (PricebookEntry PricebookEntryItem : PricebookEntryListStandartPrice) {
                        if (PricebookEntryItem.CurrencyIsoCode == DefaultCurrency) {
                            ProductIdPricebookEntry.put(Product2ItemId, PricebookEntryItem);
                            break;
                        }
                    }
                    if (!ProductIdPricebookEntry.containsKey(Product2ItemId)) {
                        ProductIdPricebookEntry.put(Product2ItemId, PricebookEntryListStandartPrice[0]);
                    }
                }
                if (ProductIdPricebookEntry.containsKey(Product2ItemId)) {
                    continue;
                }

                if (PricebookEntryListPrice.size() > 0) {
                    for (PricebookEntry PricebookEntryItem : PricebookEntryListPrice) {
                        if (PricebookEntryItem.CurrencyIsoCode == DefaultCurrency) {
                            ProductIdPricebookEntry.put(Product2ItemId, PricebookEntryItem);
                            break;
                        }
                    }
                    if (!ProductIdPricebookEntry.containsKey(Product2ItemId)) {
                        ProductIdPricebookEntry.put(Product2ItemId, PricebookEntryListStandartPrice[0]);
                    }

                }

            }
        }

        /*List<PricebookEntry> PricebookEntryList = [SELECT Id, CurrencyIsoCode, Name, UnitPrice, Product2Id, Pricebook2.Name FROM PricebookEntry WHERE Pricebook2Id != NULL AND Pricebook2.IsDeleted = false AND (Pricebook2.Name = :CustomSetting.PriceBookName__c OR Pricebook2.IsStandard = true) AND Pricebook2.IsActive = true AND CurrencyIsoCode = :DefaultCurrency AND IsDeleted = false AND IsActive = true AND Product2Id IN :ProductIds ORDER BY Pricebook2.IsStandard DESC];
        for (PricebookEntry PricebookEntryItem : PricebookEntryList) {
            ProductIdPricebookEntry.put(PricebookEntryItem.Product2Id, PricebookEntryItem);
        }*/
        return ProductIdPricebookEntry;
    }
/*
    public static Map<String,Object> RegisterToken(MKT_ShoppingCart.PaymentInfo paymentObj) {
        //kumocomm__GatewayConfig__c DefaultGateway = //HelperWithoutSharing.getDefaultGateway();

        Map<String, Object> paymentData = new Map<String, Object> {
                //'PaymentType' => 'CreditCard'
                //'PaymentSource' => new Map<String,Object>{
                    //'Type' => paymentObj.PaymentSourceItem.kumocomm__CreditCardType__c,
                    //'CardNumber' => paymentObj.CardNumber,
                    //'ExpirationMonth' => paymentObj.PaymentSourceItem.kumocomm__CreditCardExpirationMonth__c,
                    //'ExpirationYear' => paymentObj.PaymentSourceItem.kumocomm__CreditCardExpirationYear__c,
                    //'Code' => paymentObj.PaymentSourceItem.kumocomm__CreditCardSecurityCode__c,
                    //'FirstName' => paymentObj.FirstName,
                    //'LastName' => paymentObj.LastName,
                    //'Last4Digits' => paymentObj.getCardEnding(),
                    //'PaymentType' => 'CreditCard'
               //},
                /*'Customer'=> new Map<String,Object>{
                    'FirstName' => paymentObj.FirstName,
                    'LastName' => paymentObj.LastName,
                    'Email' => paymentObj.Email,
                    'Phone' => paymentObj.Phone,
                    'ShippingFirstName' => paymentObj.FirstName,
                    'ShippingLastName' => paymentObj.LastName,
                    'ShipToName' => (paymentObj.FirstName + ' ' + paymentObj.LastName)
                }*//*
                //'MerchantSecurityKey' =>DefaultGateway.kumocomm__MerchantSecurityKey__c,
                //'MerchantSecurityCode'=>DefaultGateway.kumocomm__MerchantSecurityCode__c,
                //'MerchantReference'=>DefaultGateway.kumocomm__MerchantReference__c,
                //'MerchantPassword'=> DefaultGateway.kumocomm__MerchantPassword__c,
                //'MerchantId'=>DefaultGateway.kumocomm__MerchantId__c,
                //'GatewayId'=>DefaultGateway.ID,
                //'Amount' =>0,
                //'TransactionType'=> 'RegisterToken'
            };

            String SerializedPaymentData = JSON.serialize(paymentData);
            System.debug('serializedPaymentData======================'+serializedPaymentData);
            //String Response = kumocomm.GatewayPaymentService.registerTokenWebService(SerializedPaymentData);
            //System.debug('Response==========' + Response);
            //Map<String,Object> ResponseMap = (Map<String,Object>)JSON.deserializeUntyped(Response);
            //System.debug('ResponseMap==========' + Response);
        return paymentData;//ResponseMap
    }
*/
    //public static kumocomm__GatewayConfig__c getDefaultGateway() {
        //////////////////////Temporary cap
        //kumocomm__GatewayConfig__c kk = new kumocomm__GatewayConfig__c();
    /*    List<kumocomm__GatewayConfig__c> ActiveGateways = [
            SELECT Id, Name, RecordTypeId, RecordType.DeveloperName,kumocomm__Use_Tokenization__c
            FROM kumocomm__GatewayConfig__c
            WHERE kumocomm__Use_Tokenization__c = true/*, kumocomm__MerchantId__c, kumocomm__MerchantPassword__c*//*, kumocomm__MerchantReference__c, kumocomm__MerchantSecurityCode__c,*/ /*kumocomm__MerchantSecurityKey__c,*/ /*kumocomm__RequireAVS__c,*/ /*kumocomm__RequireCCV__c,*//* kumocomm__CancelURL__c*//*, kumocomm__ReturnURL__c,*/ /*kumocomm__Debug__c,*/ /*kumocomm__TestMode__c,*/ /*kumocomm__Active__c = true AND */
       /* ];
        if (ActiveGateways.size() > 1) {
            //throw new kumocomm.GatewayException('More than one active Gateway.');
        }
        if (ActiveGateways.size() == 0) {
            //throw new kumocomm.GatewayException('There are no active Gateways with enabled tokenization.');
        }
        //////////////////////Temporary cap*/
       // return kk;
    //}
    //public static List<kumocomm__GatewayConfig__c> getActiveGatewayList() {
        //////////////////////Temporary cap
        //List<kumocomm__GatewayConfig__c> aa = new List<kumocomm__GatewayConfig__c>();
      /*  List<kumocomm__GatewayConfig__c> ActiveGateways = [
            SELECT Id, Name, RecordTypeId, RecordType.DeveloperName,kumocomm__Use_Tokenization__c
            FROM kumocomm__GatewayConfig__c
            WHERE kumocomm__Use_Tokenization__c = true/*, kumocomm__MerchantId__c, kumocomm__MerchantPassword__c*//*, kumocomm__MerchantReference__c, kumocomm__MerchantSecurityCode__c,*/ /*kumocomm__MerchantSecurityKey__c,*/ /*kumocomm__RequireAVS__c,*/ /*kumocomm__RequireCCV__c,*//* kumocomm__CancelURL__c*//*, kumocomm__ReturnURL__c,*/ /*kumocomm__Debug__c,*/ /*kumocomm__TestMode__c,*/ /*kumocomm__Active__c = true AND */
        /*];
        //////////////////////Temporary cap*/
        //return aa;
   // }
    public static Boolean getIsUserUS() {
        return UserInfo.getDefaultCurrency() == 'USD';
    }
    public static void DeleteEmailWorkflows(List<MKT_Email_Workflow_in_CyberU__c> emailWorkflows) {
        delete emailWorkflows;
    }
    public static Boolean EnrollUserToClass(String UserID, String ClassID) {
        if (UserID == NULL || ClassID == NULL || UserID == '' || ClassID == '' ) return false;
        Savepoint sp = Database.setSavepoint();
        try {
            Set<ID> users_ids = new Set<ID>{
            ID.valueof(UserID)/*User_ID*/};
            Map<ID,Set<ID>> mm = new Map<ID,Set<ID>> {
            /*Class_ID*/ID.valueof(ClassID) => users_ids};

            Map<String, Object> assembly = new Map<String, Object> {
                'MethodName' => 'enrollUsersToClass',
                    'ClassUserData' => mm
            };

            Map<String, Object> result = lmsilt.ILTUtil.InvokePackageMethod(assembly);

            System.debug('#####RESULT######' + result);
            /*if (result!=NULL) {
                for (String key: result.keySet()){
                        System.debug('ClassID: '+key);
                        Map<String,String> mtemp = (Map<String,String>)result.get(key);//<= IN HERE
                for (String ckey: mtemp.keySet()){
                        System.debug(ckey + '  | ' + mtemp.get(ckey));
                }
                System.debug('<------------------------------------------->');
                }
            }*/
        }
        catch(Exception e) {
            Database.rollback(sp);
            return false;
        }
        return true;
    }
    public static PricebookEntry getPricebookEntryByProductId(Id prodId) {
        MKT_Setting__c CustomSetting = MKT_Setting__c.getInstance();
        String DefaultCurrency = (UserInfo.getDefaultCurrency() == NULL) ? 'USD' : UserInfo.getDefaultCurrency();
        List<PricebookEntry> PricebookEntryList = [SELECT Id, CurrencyIsoCode, Name, UnitPrice, Product2Id, Pricebook2.Name FROM PricebookEntry WHERE Pricebook2Id != NULL AND Pricebook2.IsDeleted = false AND (Pricebook2.Name = :CustomSetting.PriceBookName__c OR Pricebook2.IsStandard = true) AND Pricebook2.IsActive = true /*AND CurrencyIsoCode = :DefaultCurrency*/ AND IsDeleted = false AND IsActive = true AND Product2Id = :prodId ORDER BY Pricebook2.IsStandard DESC];
        if (PricebookEntryList.size() > 0) {
            List<PricebookEntry> PricebookEntryListOfDefaultPrice = new List<PricebookEntry>();
            List<PricebookEntry> PricebookEntryListPrice = new List<PricebookEntry>();
            for (PricebookEntry PricebookEntryItem : PricebookEntryList) {
                if (PricebookEntryItem.Pricebook2.Name == CustomSetting.PriceBookName__c) {
                    if (PricebookEntryItem.CurrencyIsoCode == DefaultCurrency) {
                        return PricebookEntryItem;
                    }
                    PricebookEntryListOfDefaultPrice.Add(PricebookEntryItem);
                }
                else {
                    PricebookEntryListPrice.Add(PricebookEntryItem);
                }
            }
            if (PricebookEntryListOfDefaultPrice.size() > 0) {
                return PricebookEntryListOfDefaultPrice[0];
            }
            else if (PricebookEntryListPrice.size() > 0){
                for (PricebookEntry PricebookEntryItem : PricebookEntryListPrice) {
                    if (PricebookEntryItem.CurrencyIsoCode == DefaultCurrency) {
                        return PricebookEntryItem;
                    }
                }
                return PricebookEntryListPrice[0];
            }
        }
        return NULL;
    }

    public static Boolean isAccessUser() {
    /*    if (Test.isRunningTest()) return true;
        CaseController caseControllerObj = new CaseController();
        /*if ( caseControllerObj.isSandbox == true || caseControllerObj.isPartnerSupported == true || caseControllerObj.isInactive == true) {
            return false;
        }
        else {
            return true;
        }*/
        return true;
    }

    public static void AddToCart(String idObjectToAdd, String TypeObj) {
       /* MKT_PaymentController paymentObj = new MKT_PaymentController();
        paymentObj.ObjId = idObjectToAdd;
        paymentObj.TypeObj = TypeObj;
        paymentObj.InitPaymentObjects();
        if (!paymentObj.EnrollPaymentError) {
            Boolean cartResult = paymentObj.AddToCart();
        }*/
    }
    public static void AddClassToCart(String EventId, String ClassId) {
        /*MKT_PaymentController paymentObj = new MKT_PaymentController();
        paymentObj.ObjId = EventId;
        paymentObj.TypeObj = lmsilt__Event__c.sObjectType.getDescribe().getLabel();
        paymentObj.ClassId = ClassId;
        paymentObj.InitPaymentObjects();
        if (!paymentObj.EnrollPaymentError) {
            Boolean cartResult = paymentObj.AddToCart();
        }*/
    }
    public static Id getOpportunityOwnerId () {
        Id OwnerId;
        try {
            MKT_Setting__c cs = MKT_Setting__c.getInstance();
            List<User> oppOwnerSettingList = [SELECT Id FROM User WHERE Id = :cs.MKT_Opportunity_Owner_Id__c AND IsActive = true LIMIT 1];
            if (oppOwnerSettingList.size() > 0) {
                OwnerId = oppOwnerSettingList[0].Id;
            }
            else {
                List<User> oppOwnerList = [SELECT Id FROM User WHERE Name = 'Marketo Administrator' AND Profile.Name = 'System Administrator' AND IsActive = true LIMIT 1];
                if (oppOwnerList.size() > 0) {
                    OwnerId = oppOwnerList[0].Id;
                }
            }
        }
        catch (Exception e) {
            return NULL;
        }
        return OwnerId;
    }
    public static Set<Id> CheckObjectProducts (Set<Id> ProductsIdsSet) {
        Set<Id> ResultProductsIdsSet = new Set<Id>();
        for (lmscons__Training_Content__c ModuleItem : [SELECT Id, Product__c FROM lmscons__Training_Content__c WHERE Product__c IN :ProductsIdsSet]) {
            ResultProductsIdsSet.Add(ModuleItem.Product__c);
        }
        for (lmscons__Quiz__c QuizItem : [SELECT Id, Product__c FROM lmscons__Quiz__c WHERE Product__c IN :ProductsIdsSet]) {
            ResultProductsIdsSet.Add(QuizItem.Product__c);
        }
        for (lmsilt__Event__c EventItem : [SELECT Id, Product__c FROM lmsilt__Event__c WHERE Product__c IN :ProductsIdsSet]) {
            ResultProductsIdsSet.Add(EventItem.Product__c);
        }
        for (lmscons__Training_Path__c CourseItem : [SELECT Id, Product__c FROM lmscons__Training_Path__c WHERE  Product__c IN :ProductsIdsSet]) {
            ResultProductsIdsSet.Add(CourseItem.Product__c);
        }
        for (lmscons__Learning_Path__c LPItem : [SELECT Id, Product__c FROM lmscons__Learning_Path__c WHERE  Product__c IN :ProductsIdsSet]) {
            ResultProductsIdsSet.Add(LPItem.Product__c);
        }
        for (lmscons__Curriculum__c CurrItem : [SELECT Id, Product__c FROM lmscons__Curriculum__c WHERE  Product__c IN :ProductsIdsSet]) {
            ResultProductsIdsSet.Add(CurrItem.Product__c);
        }

        return ResultProductsIdsSet;
    }
    public static void insertOpportunities (List<Opportunity> OpportunitiesList) {
        insert OpportunitiesList;
    }

    public static void insertOpportunityLineItems (List<OpportunityLineItem> OpportunityLineItemList) {
        insert OpportunityLineItemList;
    }

    public static void updateOpportunities (List<Opportunity> OpportunitiesList) {
        update OpportunitiesList;
    }
    public static String getCurrentSessionId() {
        Cookie temp = ApexPages.currentPage().getCookies().get(CURRENT_COOKIE_NAME);
        if (temp == null) {
            return null;
        }
        return temp.getValue();
    }
    public static String processPaymentWebService (String RequestString) {
        //return kumocomm.GatewayPaymentService.processPaymentWebService(RequestString);
        return '';
    }
    /*public static String getCurrentCartId() {
        User curUser = [SELECT Id, UserType, ContactId FROM USER WHERE Id = :UserInfo.getUserId() LIMIT 1];
        String CartId;
        if (curUser.ContactId != NULL) {
            //List<kumocomm__ShoppingCart__c> ShCartList = [SELECT Id FROM kumocomm__ShoppingCart__c WHERE kumocomm__Contact__c = :curUser.ContactId AND kumocomm__Status__c = 'Active' LIMIT 1];
            //if (ShCartList.size() > 0) {
             //   CartId = ShCartList[0].Id;
            //}
        }
        else {
            String SessionId = getCurrentSessionId();
            if (SessionId != NULL) {
                //List<kumocomm__ShoppingCart__c> ShCartList = [SELECT Id FROM kumocomm__ShoppingCart__c WHERE kumocomm__SessionKey__c = :SessionID AND kumocomm__Status__c = 'Active' LIMIT 1];
                //if (ShCartList.size() > 0) {
                  //  CartId = ShCartList[0].Id;
                //}
            }
        }

        return CartId;
    }*/
    public static Set<Id> CheckObjectProductsInCart(Set<Id> ProductsSet) {
        Set<Id> CartItemsProductsSet = new Set<Id>();
        //for (kumocomm__ShoppingCartItem__c cartItem : [SELECT Id, kumocomm__Product__c FROM kumocomm__ShoppingCartItem__c WHERE kumocomm__Product__c != NULL AND kumocomm__Status__c = 'In Cart' AND kumocomm__Product__c IN : ProductsSet]) {
            //CartItemsProductsSet.Add(cartItem.kumocomm__Product__c);
        //}
        return CartItemsProductsSet;
    }
    public static Integer getCurrentCartItemsCount() {
        String CartId = '';/*getCurrentCartId();*/
        Integer CartItemsCount = 0;
        if (CartId != NULL) {
           // for (kumocomm__ShoppingCartItem__c cartItem : [SELECT Id, kumocomm__Quantity__c FROM kumocomm__ShoppingCartItem__c WHERE kumocomm__Product__c != NULL AND kumocomm__Status__c = 'In Cart'/*kumocomm__ShoppingCart__c = :CartId AND */]) {
               // CartItemsCount += (Integer)cartItem.kumocomm__Quantity__c;
           // }
        }

        return CartItemsCount;
    }
    public static Set<Id> getCurrentCartItemsProductsSet() {
        Set<Id> CartItemsProductsSet = new Set<Id>();
        String CartId = '';/*getCurrentCartId();*/
        if (CartId != NULL) {
           // for (kumocomm__ShoppingCartItem__c cartItem : [SELECT Id, kumocomm__Product__c FROM kumocomm__ShoppingCartItem__c WHERE kumocomm__Product__c != NULL AND kumocomm__Status__c = 'In Cart'/*kumocomm__ShoppingCart__c = :CartId  AND */]) {
               // CartItemsProductsSet.Add(cartItem.kumocomm__Product__c);
            //}
        }
        return CartItemsProductsSet;
    }
   //public static Map<Id, kumocomm__ShoppingCartItem__c> getCurrentCartItemsProductsMap() {
        //Map<Id, kumocomm__ShoppingCartItem__c> CartItemsProductsMap = new Map<Id, kumocomm__ShoppingCartItem__c>();
       // String CartId = '';/*getCurrentCartId();*/
        //if (CartId != NULL) {
            //for (kumocomm__ShoppingCartItem__c cartItem : [SELECT Id, kumocomm__Product__c, kumocomm__Quantity__c, /*kumocomm__ShoppingCart__c,*/ kumocomm__Status__c, /*MKT_Class__c */FROM kumocomm__ShoppingCartItem__c WHERE kumocomm__Product__c != NULL AND kumocomm__Status__c = 'In Cart' /*kumocomm__ShoppingCart__c = :CartId AND */]) {
              //  CartItemsProductsMap.put(cartItem.kumocomm__Product__c, cartItem);
           // }
        //}
        //return CartItemsProductsMap;
    //}
    //public static Map<Id, kumocomm__ShoppingCartItem__c> getOrderItemsProductsMap() {
        //Map<Id, kumocomm__ShoppingCartItem__c> CartItemsProductsMap = new Map<Id, kumocomm__ShoppingCartItem__c>();
        //String CartId = '';/*getCurrentCartId();*/
        //if (CartId != NULL) {
           // for (kumocomm__ShoppingCartItem__c cartItem : [SELECT Id, kumocomm__Product__c, kumocomm__Quantity__c, /*kumocomm__ShoppingCart__c,*/ kumocomm__Status__c, /*MKT_Class__c */FROM kumocomm__ShoppingCartItem__c WHERE  kumocomm__Product__c != NULL AND kumocomm__Status__c = 'In Cart' /*kumocomm__ShoppingCart__c = :CartId AND*/]) {
                //CartItemsProductsMap.put(cartItem.kumocomm__Product__c, cartItem);
            //}
        //}
        //return CartItemsProductsMap;
    //}

    public static Set<Id> getPaidProductsSet (Set<Id> ProductsSet) {
        Set<Id> PaidProductsSet = new Set<Id>();
        User curUser = [SELECT Id, AccountId FROM User WHERE Id = : UserInfo.getUserId() LIMIT 1];
        if (curUser.AccountId == NULL) return PaidProductsSet;

        for (MKT_Payment__c PaymentItem : [SELECT Id, Product__c, Remaining_Seats__c FROM MKT_Payment__c WHERE Product__c IN : ProductsSet AND Remaining_Seats__c > 0 AND Account__c =: curUser.AccountId]) {
            PaidProductsSet.Add(PaymentItem.Product__c);
        }

        for (MKT_PaymentLicense__c PaymentItem : [SELECT Id, MKT_Payment__c, MKT_Payment__r.Product__c, MKT_Payment__r.Remaining_Seats__c FROM MKT_PaymentLicense__c WHERE MKT_Payment__r.Product__c IN : ProductsSet AND (MKT_Payment__r.Remaining_Seats__c > 0 OR User__c = :UserInfo.getUserId()) AND MKT_Payment__r.Account__c =: curUser.AccountId]) {
            PaidProductsSet.Add(PaymentItem.MKT_Payment__r.Product__c);
        }
        return PaidProductsSet;
    }
    public static String currencySymbol(String iso) {
        String symbol = '';
        if (iso=='ALL') { symbol='Lek'; }
        else if (iso=='USD') { symbol='$'; }
        else if (iso=='ARS') { symbol='$'; }
        else if (iso=='AWG') { symbol='ƒ'; }
        else if (iso=='AUD') { symbol='$'; }
        else if (iso=='BSD') { symbol='$'; }
        else if (iso=='BBD') { symbol='$'; }
        else if (iso=='BYR') { symbol='p.'; }
        else if (iso=='EUR') { symbol='€'; }
        else if  (iso=='BZD') { symbol='BZ$'; }
        else if (iso=='BMD') { symbol='$'; }
        else if (iso=='BOB') { symbol='$b'; }
        else if (iso=='BAM') { symbol='KM'; }
        else if (iso=='BWP') { symbol='P'; }
        else if (iso=='BRL') { symbol='R$'; }
        else if (iso=='GBP') { symbol='£'; }
        else if (iso=='BND') { symbol='$'; }
        else if (iso=='CAD') { symbol='$'; }
        else if (iso=='KYD') { symbol='$'; }
        else if (iso=='CLP') { symbol='$'; }
        else if (iso=='CNY') { symbol='¥'; }
        else if (iso=='COP') { symbol='$'; }
        else if (iso=='CRC') { symbol='¢'; }
        else if (iso=='HRK') { symbol='kn'; }
        else if (iso=='EUR') { symbol='€'; }
        else if (iso=='CZK') { symbol='Kc'; }
        else if (iso=='DKK') { symbol='kr'; }
        else if (iso=='DOP') { symbol='RD$'; }
        else if (iso=='XCD') { symbol='$'; }
        else if (iso=='EGP') { symbol='£'; }
        else if (iso=='SVC') { symbol='$'; }
        else if (iso=='GBP') { symbol='£'; }
        else if (iso=='EEK') { symbol='kr'; }
        else if (iso=='EUR') { symbol='€'; }
        else if (iso=='FKP') { symbol='£'; }
        else if (iso=='FJD') { symbol='$'; }
        else if (iso=='EUR') { symbol='€'; }
        else if (iso=='GHC') { symbol='¢'; }
        else if (iso=='GIP') { symbol='£'; }
        else if (iso=='EUR') { symbol='€'; }
        else if (iso=='GTQ') { symbol='Q'; }
        else if (iso=='GGP') { symbol='£'; }
        else if (iso=='GYD') { symbol='$'; }
        else if (iso=='EUR') { symbol='€'; }
        else if (iso=='HNL') { symbol='L'; }
        else if (iso=='HKD') { symbol='$'; }
        else if (iso=='HUF') { symbol='Ft'; }
        else if (iso=='ISK') { symbol='kr'; }
        else if (iso=='IDR') { symbol='Rp'; }
        else if (iso=='EUR') { symbol='€'; }
        else if (iso=='IMP') { symbol='£'; }
        else if (iso=='EUR') { symbol='€'; }
        else if (iso=='JMD') { symbol='J$'; }
        else if (iso=='JPY') { symbol='¥'; }
        else if (iso=='JEP') { symbol='£'; }
        else if (iso=='LVL') { symbol='Ls'; }
        else if (iso=='LBP') { symbol='£'; }
        else if (iso=='LRD') { symbol='$'; }
        else if (iso=='CHF') { symbol='CHF'; }
        else if (iso=='LTL') { symbol='Lt'; }
        else if (iso=='EUR') { symbol='€'; }
        else if (iso=='MYR') { symbol='RM'; }
        else if (iso=='EUR') { symbol='€'; }
        else if (iso=='MXN') { symbol='$'; }
        else if (iso=='MZN') { symbol='MT'; }
        else if (iso=='NAD') { symbol='$'; }
        else if (iso=='ANG') { symbol='ƒ'; }
        else if (iso=='EUR') { symbol='€'; }
        else if (iso=='NZD') { symbol='$'; }
        else if (iso=='NIO') { symbol='C$'; }
        else if (iso=='NOK') { symbol='kr'; }
        else if (iso=='PAB') { symbol='B/.'; }
        else if (iso=='PYG') { symbol='Gs'; }
        else if (iso=='PEN') { symbol='S/.'; }
        else if (iso=='PHP') { symbol='Php'; }
        else if (iso=='PLN') { symbol='zl'; }
        else if (iso=='RON') { symbol='lei'; }
        else if (iso=='SHP') { symbol='£'; }
        else if (iso=='SGD') { symbol='$'; }
        else if (iso=='EUR') { symbol='€'; }
        else if (iso=='SBD') { symbol='$'; }
        else if (iso=='SOS') { symbol='S'; }
        else if (iso=='ZAR') { symbol='R'; }
        else if (iso=='EUR') { symbol='€'; }
        else if (iso=='SEK') { symbol='kr'; }
        else if (iso=='CHF') { symbol='CHF'; }
        else if (iso=='SRD') { symbol='$'; }
        else if (iso=='SYP') { symbol='£'; }
        else if (iso=='TWD') { symbol='NT$'; }
        else if (iso=='TTD') { symbol='TT$'; }
        else if (iso=='TRY') { symbol='TL'; }
        else if (iso=='TRL') { symbol='£'; }
        else if (iso=='TVD') { symbol='$'; }
        else if (iso=='GBP') { symbol='£'; }
        else if (iso=='USD') { symbol='$'; }
        else if (iso=='UYU') { symbol='$U'; }
        else if (iso=='EUR') { symbol='€'; }
        else if (iso=='VEF') { symbol='Bs'; }
        else if (iso=='ZWD') { symbol='Z$'; }
        return symbol;
    }
    public static List<SelectOption> getStates() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','state'));
        options.add(new SelectOption('AK','Alaska'));
        options.add(new SelectOption('AL','Alabama'));
        options.add(new SelectOption('AR','Arkansas'));
        options.add(new SelectOption('AZ','Arizona'));
        options.add(new SelectOption('CA','California'));
        options.add(new SelectOption('CO','Colorado'));
        options.add(new SelectOption('CT','Connecticut'));
        options.add(new SelectOption('DC','District of Columbia'));
        options.add(new SelectOption('DE','Delaware'));
           
        options.add(new SelectOption('FL','Florida'));
        options.add(new SelectOption('GA','Georgia'));
        options.add(new SelectOption('HI','Hawaii'));
        options.add(new SelectOption('IA','Iowa'));
        options.add(new SelectOption('ID','Idaho'));
        options.add(new SelectOption('IL','Illinois'));
        options.add(new SelectOption('IN','Indiana'));
        options.add(new SelectOption('KS','Kansas'));
        options.add(new SelectOption('KY','Kentucky'));
        options.add(new SelectOption('LA','Louisiana'));
        options.add(new SelectOption('MA','Massachusetts'));
        options.add(new SelectOption('MD','Maryland'));
        options.add(new SelectOption('ME','Maine'));
        options.add(new SelectOption('MI','Michigan'));
        options.add(new SelectOption('MN','Minnesota'));
        options.add(new SelectOption('MO','Missouri'));
        options.add(new SelectOption('MS','Mississippi'));
        options.add(new SelectOption('MT','Montana'));
        options.add(new SelectOption('NC','North Carolina'));
        options.add(new SelectOption('ND','North Dakota'));
        options.add(new SelectOption('NE','Nebraska'));
        options.add(new SelectOption('NH','New Hampshire'));
        options.add(new SelectOption('NJ','New Jersey'));
        options.add(new SelectOption('NM','New Mexico'));
        options.add(new SelectOption('NV','Nevada'));
        options.add(new SelectOption('NY','New York'));
        options.add(new SelectOption('OH','Ohio'));
        options.add(new SelectOption('OK','Oklahoma'));
        options.add(new SelectOption('OR','Oregon'));
        options.add(new SelectOption('PA','Pennsylvania'));
        options.add(new SelectOption('RI','Rhode Island'));
        options.add(new SelectOption('SC','South Carolina'));
        options.add(new SelectOption('SD','South Dakota'));
        options.add(new SelectOption('TN','Tennessee'));
        options.add(new SelectOption('TX','Texas'));
        options.add(new SelectOption('UT','Utah'));
        options.add(new SelectOption('VA','Virginia'));
        options.add(new SelectOption('VT','Vermont'));
        options.add(new SelectOption('WA','Washington'));
        options.add(new SelectOption('WI','Wisconsin'));
        options.add(new SelectOption('WV','West Virginia'));
        options.add(new SelectOption('WY','Wyoming'));

        return options;
    }
    public static List<SelectOption> getCardTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('','Choose card'));
        options.add(new SelectOption('Visa','Visa'));
        options.add(new SelectOption('Mastercard','Mastercard'));
        options.add(new SelectOption('American Express','American Express'));
        options.add(new SelectOption('Discover','Discover Card'));
        //options.add(new SelectOption('JCB','JCB Card'));
        return options;
    }
    public static List<Messaging.SendEmailResult> sendEmail(String ContactEmail, String HTMLBody) {
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
        mail.setToAddresses(new String[] {ContactEmail});
        mail.setSubject('Order Confirmation');
        mail.setHtmlBody(HTMLBody);
        OrgWideEmailAddress[] owea = [SELECT Id FROM OrgWideEmailAddress WHERE Address = 'education@marketo.com'];
        if (owea.size() > 0) {
            mail.setOrgWideEmailAddressId(owea.get(0).Id);
        }
        List<Messaging.SendEmailResult> results = Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
        return results;
    }
    public static List<SelectOption> getYears() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('year','year'));
        for (Integer i = system.now().year(); i < system.now().addYears(7).year(); i++) {
            options.add(new SelectOption(String.valueOf(i),String.valueOf(i)));
        }
        return options;
    }
    public static Boolean showDownload(String modName) {
        modName = modName.toLowerCase();
        if (modName.endsWith('.docx') || (modName.contains('docx') && modName.contains('(') && modName.contains(')')) || modName.endsWith('.doc') || (modName.contains('doc') && modName.contains('(') && modName.contains(')')) || modName.endsWith('.png') || (modName.contains('png') && modName.contains('(') && modName.contains(')')) || modName.endsWith('.csv') || (modName.contains('csv') && modName.contains('(') && modName.contains(')')) || modName.endsWith('.pdf') || (modName.contains('pdf') && modName.contains('(') && modName.contains(')')) || modName.endsWith('.xls') || (modName.contains('xls') && modName.contains('(') && modName.contains(')')) || modName.endsWith('.ppt') || (modName.contains('ppt') && modName.contains('(') && modName.contains(')')) || modName.endsWith('.pptx') || (modName.contains('pptx') && modName.contains('(') && modName.contains(')'))  || modName.endsWith('.xlsx') || (modName.contains('xlsx') && modName.contains('(') && modName.contains(')'))) {
            return true;
        }
        return false;
    }
    public static String CheckNULL(String Arg) {
        return (Arg != NULL) ? Arg : '';
    }
    public static String GetResourceURL(String resourceName) {

        List<StaticResource> resourceList = [
        SELECT Name, NamespacePrefix, SystemModStamp
        FROM StaticResource
        WHERE Name = :resourceName
        ];

        if (resourceList.size() == 1) {
        String namespace = resourceList[0].NamespacePrefix;
        return Label.MKT_Marketo_Domen + '/resource/'
            + resourceList[0].SystemModStamp.getTime() + '/'
            + (namespace != null && namespace != '' ? namespace + '__' : '')
            + resourceName;
        } else return '';

    }
    public static DOM.Document PrepareIntacctXmlDoc(List<OpportunityLineItem> OpportunityLItems, String IntacctCustomerId, String Operation) {
        OpportunityLineItem OpportunityLItem = OpportunityLItems[0];
        if (Operation == 'CreateSOTransaction' && (IntacctCustomerId == NULL || IntacctCustomerId == '')) {
            return NULL;
        }

        DOM.Document RequestDocument = new DOM.Document();
        DOM.XmlNode Node_Request = RequestDocument.createRootElement('request', NULL, NULL);
        DOM.XmlNode Node_Control = Node_Request.addChildElement('control', NULL, NULL);
        DOM.XmlNode Node_senderid = Node_Control.addChildElement('senderid', NULL, NULL).addTextNode('marketo');
        DOM.XmlNode Node_password = Node_Control.addChildElement('password', NULL, NULL).addTextNode('AQcOKoXfmR');
        DOM.XmlNode Node_controlid = Node_Control.addChildElement('controlid', NULL, NULL).addTextNode('xml');
        DOM.XmlNode Node_uniqueid = Node_Control.addChildElement('uniqueid', NULL, NULL).addTextNode('false');
        DOM.XmlNode Node_dtdversion = Node_Control.addChildElement('dtdversion', NULL, NULL).addTextNode('3.0');

        DOM.XmlNode Node_Operation = Node_Request.addChildElement('operation', NULL, NULL);
        DOM.XmlNode Node_authentication = Node_Operation.addChildElement('authentication', NULL, NULL);
        DOM.XmlNode Node_login = Node_authentication.addChildElement('login', NULL, NULL);
        String useridVar = (Operation == 'CreateSOTransaction') ? 'SFDC' : 'YYbera';
        String upasswordVar = (Operation == 'CreateSOTransaction') ? 'Rdue1S&5+e4a' : 'Market0!';
        DOM.XmlNode Node_userid = Node_login.addChildElement('userid', NULL, NULL).addTextNode(useridVar);
        DOM.XmlNode Node_companyid = Node_login.addChildElement('companyid', NULL, NULL).addTextNode('marketo-copy');
        DOM.XmlNode Node_upassword = Node_login.addChildElement('password', NULL, NULL).addTextNode(upasswordVar);
        DOM.XmlNode Node_content = Node_Operation.addChildElement('content', NULL, NULL);
        DOM.XmlNode Node_function = Node_content.addChildElement('function', NULL, NULL);

        if (Operation == 'CheckCustomer' && IntacctCustomerId != NULL && IntacctCustomerId != '') {
            Node_function.setAttribute('controlid', 'CheckCustomerId');
            DOM.XmlNode Node_readByQuery = Node_function.addChildElement('readByQuery', NULL, NULL);
            DOM.XmlNode Node_object = Node_readByQuery.addChildElement('object', NULL, NULL).addTextNode('CUSTOMER');
            DOM.XmlNode Node_query = Node_readByQuery.addChildElement('query', NULL, NULL).addTextNode('CUSTOMERID = \''+IntacctCustomerId+'\'');
            DOM.XmlNode Node_pagesize = Node_readByQuery.addChildElement('pagesize', NULL, NULL).addTextNode('1');
            DOM.XmlNode Node_returnFormat = Node_readByQuery.addChildElement('returnFormat', NULL, NULL).addTextNode('xml');
        }
        if (Operation == 'ReadCustomer') {
            Node_function.setAttribute('controlid', 'ReadCustomer');
            DOM.XmlNode Node_read = Node_function.addChildElement('read', NULL, NULL);
            DOM.XmlNode Node_object = Node_read.addChildElement('object', NULL, NULL).addTextNode('CUSTOMER');
            DOM.XmlNode Node_keys = Node_read.addChildElement('keys', NULL, NULL);
            DOM.XmlNode Node_fields = Node_read.addChildElement('fields', NULL, NULL).addTextNode('*');
            DOM.XmlNode Node_returnFormat = Node_read.addChildElement('returnFormat', NULL, NULL).addTextNode('xml');
        }
        if (Operation == 'ReadMoreCustomer') {
            Node_function.setAttribute('controlid', 'ReadMoreCustomer');
            DOM.XmlNode Node_read = Node_function.addChildElement('read', NULL, NULL);
            DOM.XmlNode Node_object = Node_read.addChildElement('object', NULL, NULL).addTextNode('CUSTOMER');
        }
        if (Operation == 'CreateCustomer') {
            Node_function.setAttribute('controlid', 'CreateCustomer');
            DOM.XmlNode Node_create = Node_function.addChildElement('create', NULL, NULL);
            DOM.XmlNode Node_CUSTOMER = Node_create.addChildElement('CUSTOMER', NULL, NULL);
                DOM.XmlNode Node_NAME = Node_CUSTOMER.addChildElement('NAME', NULL, NULL).addTextNode(OpportunityLItem.Opportunity.Account.Name);
                DOM.XmlNode Node_ENTITY = Node_CUSTOMER.addChildElement('ENTITY', NULL, NULL).addTextNode('marketo-us');
                DOM.XmlNode Node_PARENTKEY = Node_CUSTOMER.addChildElement('PARENTKEY', NULL, NULL).addTextNode('');
                if (OpportunityLItem.Opportunity.Account.ParentId != NULL) {
                    DOM.XmlNode Node_PARENTID = Node_CUSTOMER.addChildElement('PARENTID', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Parent.IntacctID__c));
                    DOM.XmlNode Node_PARENTNAME = Node_CUSTOMER.addChildElement('PARENTNAME', NULL, NULL).addTextNode(OpportunityLItem.Opportunity.Account.Parent.Name);
                }

        }
        if (Operation == 'UpdateCustomer') {
            Node_function.setAttribute('controlid', 'UpdateCustomer');
            DOM.XmlNode Node_update = Node_function.addChildElement('update', NULL, NULL);
            DOM.XmlNode Node_CUSTOMER = Node_update.addChildElement('CUSTOMER', NULL, NULL);
                DOM.XmlNode Node_CUSTOMERID = Node_CUSTOMER.addChildElement('CUSTOMERID', NULL, NULL).addTextNode(IntacctCustomerId);
                DOM.XmlNode Node_NAME = Node_CUSTOMER.addChildElement('NAME', NULL, NULL).addTextNode(OpportunityLItem.Opportunity.Account.Name);
                DOM.XmlNode Node_ENTITY = Node_CUSTOMER.addChildElement('ENTITY', NULL, NULL).addTextNode('marketo-us');
                //DOM.XmlNode Node_PARENTKEY = Node_CUSTOMER.addChildElement('PARENTKEY', NULL, NULL).addTextNode('');
                if (OpportunityLItem.Opportunity.Account.ParentId != NULL) {
                    DOM.XmlNode Node_PARENTID = Node_CUSTOMER.addChildElement('PARENTID', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Parent.IntacctID__c));
                    DOM.XmlNode Node_PARENTNAME = Node_CUSTOMER.addChildElement('PARENTNAME', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Parent.Name));
                }

                DOM.XmlNode Node_DISPLAYCONTACT = Node_CUSTOMER.addChildElement('DISPLAYCONTACT', NULL, NULL);
                    DOM.XmlNode Node_CONTACTNAME = Node_DISPLAYCONTACT.addChildElement('CONTACTNAME', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Name));
                    DOM.XmlNode Node_COMPANYNAME = Node_DISPLAYCONTACT.addChildElement('COMPANYNAME', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Name));
                    DOM.XmlNode Node_PHONE1 = Node_DISPLAYCONTACT.addChildElement('PHONE1', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Phone));
                    DOM.XmlNode Node_EMAIL1 = Node_DISPLAYCONTACT.addChildElement('EMAIL1', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Accounting_Email__c));
                    DOM.XmlNode Node_URL1 = Node_DISPLAYCONTACT.addChildElement('URL1', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Website));
                    DOM.XmlNode Node_VISIBLE = Node_DISPLAYCONTACT.addChildElement('VISIBLE', NULL, NULL).addTextNode('true');
                    DOM.XmlNode Node_MAILADDRESS = Node_DISPLAYCONTACT.addChildElement('MAILADDRESS', NULL, NULL);
                        DOM.XmlNode Node_ADDRESS1 = Node_MAILADDRESS.addChildElement('ADDRESS1', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.BillingStreet));
                        DOM.XmlNode Node_CITY = Node_MAILADDRESS.addChildElement('CITY', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.BillingCity));
                        DOM.XmlNode Node_STATE = Node_MAILADDRESS.addChildElement('STATE', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.BillingState));
                        DOM.XmlNode Node_ZIP = Node_MAILADDRESS.addChildElement('ZIP', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.BillingPostalCode));
                        DOM.XmlNode Node_COUNTRY = Node_MAILADDRESS.addChildElement('COUNTRY', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.BillingCountry));
                DOM.XmlNode Node_CONTACTINFO = Node_CUSTOMER.addChildElement('CONTACTINFO', NULL, NULL);
                    DOM.XmlNode Node_CONTACTINFO_CONTACTNAME = Node_CONTACTINFO.addChildElement('CONTACTNAME', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Name));
                    DOM.XmlNode Node_CONTACTINFO_COMPANYNAME = Node_CONTACTINFO.addChildElement('COMPANYNAME', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Name));
                    DOM.XmlNode Node_CONTACTINFO_PHONE1 = Node_CONTACTINFO.addChildElement('PHONE1', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Phone));
                    DOM.XmlNode Node_CONTACTINFO_EMAIL1 = Node_CONTACTINFO.addChildElement('EMAIL1', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Accounting_Email__c));
                    DOM.XmlNode Node_CONTACTINFO_URL1 = Node_CONTACTINFO.addChildElement('URL1', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Website));
                    DOM.XmlNode Node_CONTACTINFO_VISIBLE = Node_CONTACTINFO.addChildElement('VISIBLE', NULL, NULL).addTextNode('true');
                    DOM.XmlNode Node_CONTACTINFO_MAILADDRESS = Node_CONTACTINFO.addChildElement('MAILADDRESS', NULL, NULL);
                        DOM.XmlNode Node_CONTACTINFO_ADDRESS1 = Node_CONTACTINFO_MAILADDRESS.addChildElement('ADDRESS1', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.BillingStreet));
                        DOM.XmlNode Node_CONTACTINFO_CITY = Node_CONTACTINFO_MAILADDRESS.addChildElement('CITY', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.BillingCity));
                        DOM.XmlNode Node_CONTACTINFO_STATE = Node_CONTACTINFO_MAILADDRESS.addChildElement('STATE', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.BillingState));
                        DOM.XmlNode Node_CONTACTINFO_ZIP = Node_CONTACTINFO_MAILADDRESS.addChildElement('ZIP', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.BillingPostalCode));
                        DOM.XmlNode Node_CONTACTINFO_COUNTRY = Node_CONTACTINFO_MAILADDRESS.addChildElement('COUNTRY', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.BillingCountry));

                DOM.XmlNode Node_BILLTO = Node_CUSTOMER.addChildElement('BILLTO', NULL, NULL);
                DOM.XmlNode Node_BILLTO_CONTACTNAME = Node_BILLTO.addChildElement('CONTACTNAME', NULL, NULL).addTextNode('B_'+IntacctCustomerId);
                DOM.XmlNode Node_BILLTO_FIRSTNAME = Node_BILLTO.addChildElement('FIRSTNAME', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Accounting_Contact_First_Name__c));
                DOM.XmlNode Node_BILLTO_LASTNAME = Node_BILLTO.addChildElement('LASTNAME', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Accounting_Contact_Last_Name__c));
                DOM.XmlNode Node_BILLTO_COMPANYNAME = Node_BILLTO.addChildElement('COMPANYNAME', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Name));
                DOM.XmlNode Node_BILLTO_VISIBLE = Node_BILLTO.addChildElement('VISIBLE', NULL, NULL).addTextNode('true');
                DOM.XmlNode Node_BILLTO_MAILADDRESS = Node_BILLTO.addChildElement('MAILADDRESS', NULL, NULL);
                        DOM.XmlNode Node_BILLTO_ADDRESS1 = Node_BILLTO_MAILADDRESS.addChildElement('ADDRESS1', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.BillingStreet));
                        DOM.XmlNode Node_BILLTO_CITY = Node_BILLTO_MAILADDRESS.addChildElement('CITY', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.BillingCity));
                        DOM.XmlNode Node_BILLTO_STATE = Node_BILLTO_MAILADDRESS.addChildElement('STATE', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.BillingState));
                        DOM.XmlNode Node_BILLTO_ZIP = Node_BILLTO_MAILADDRESS.addChildElement('ZIP', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.BillingPostalCode));
                        DOM.XmlNode Node_BILLTO_country = Node_BILLTO_MAILADDRESS.addChildElement('COUNTRY', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.BillingCountry));
                DOM.XmlNode Node_BILLTO_PRINTAS = Node_BILLTO.addChildElement('PRINTAS', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Name));

                DOM.XmlNode Node_SHIPTO = Node_CUSTOMER.addChildElement('SHIPTO', NULL, NULL);
                    DOM.XmlNode Node_SHIPTO_CONTACTNAME = Node_SHIPTO.addChildElement('CONTACTNAME', NULL, NULL).addTextNode('S_'+IntacctCustomerId);
                    DOM.XmlNode Node_SHIPTO_COMPANYNAME = Node_SHIPTO.addChildElement('COMPANYNAME', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Name));
                    DOM.XmlNode Node_SHIPTO_MAILADDRESS = Node_SHIPTO.addChildElement('MAILADDRESS', NULL, NULL);
                        DOM.XmlNode Node_SHIPTO_ADDRESS1 = Node_SHIPTO_MAILADDRESS.addChildElement('ADDRESS1', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.ShippingStreet));
                        DOM.XmlNode Node_SHIPTO_CITY = Node_SHIPTO_MAILADDRESS.addChildElement('CITY', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.ShippingCity));
                        DOM.XmlNode Node_SHIPTO_STATE = Node_SHIPTO_MAILADDRESS.addChildElement('STATE', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.ShippingState));
                        DOM.XmlNode Node_SHIPTO_ZIP = Node_SHIPTO_MAILADDRESS.addChildElement('ZIP', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.ShippingPostalCode));
                        DOM.XmlNode Node_SHIPTO_country = Node_SHIPTO_MAILADDRESS.addChildElement('COUNTRY', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.ShippingCountry));
                DOM.XmlNode Node_SHIPTO_PRINTAS = Node_SHIPTO.addChildElement('PRINTAS', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Name));
                DOM.XmlNode Node_SFDC_BILL_TO_ID = Node_CUSTOMER.addChildElement('SFDC_BILL_TO_ID', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.AccountID));

        }
        if (Operation == 'CreateSOTransaction') {
            Node_function.setAttribute('controlid', 'createSODoc');
            DOM.XmlNode Node_create_sotransaction = Node_function.addChildElement('create_sotransaction', NULL, NULL);
            DOM.XmlNode Node_transactiontype = Node_create_sotransaction.addChildElement('transactiontype', NULL, NULL).addTextNode('Sales Order New');
            //DOM.XmlNode Node_transactionid = Node_create_sotransaction.addChildElement('transactionid', NULL, NULL).addTextNode('Sales Order New-SO-#0100#');
            //DOM.XmlNode Node_documentnumber = Node_create_sotransaction.addChildElement('documentnumber', NULL, NULL).addTextNode('SO-#0100#');

            DOM.XmlNode Node_datecreated = Node_create_sotransaction.addChildElement('datecreated', NULL, NULL);
            DOM.XmlNode Node_year = Node_datecreated.addChildElement('year', NULL, NULL).addTextNode(String.ValueOf(date.today().year()));
            DOM.XmlNode Node_month = Node_datecreated.addChildElement('month', NULL, NULL).addTextNode(String.ValueOf(date.today().month()));
            DOM.XmlNode Node_day = Node_datecreated.addChildElement('day', NULL, NULL).addTextNode(String.ValueOf(date.today().day()));

            DOM.XmlNode Node_customerid = Node_create_sotransaction.addChildElement('customerid', NULL, NULL).addTextNode(IntacctCustomerId);

            DOM.XmlNode Node_referenceno = Node_create_sotransaction.addChildElement('referenceno', NULL, NULL).addTextNode(OpportunityLItem.Opportunity.Opportunity_Number__c + ' -- ' + OpportunityLItem.Opportunity.Name);
            DOM.XmlNode Node_datedue = Node_create_sotransaction.addChildElement('datedue', NULL, NULL);
            DOM.XmlNode Node_yeardue = Node_datedue.addChildElement('year', NULL, NULL).addTextNode(String.ValueOf(date.today().year()));
            DOM.XmlNode Node_monthdue = Node_datedue.addChildElement('month', NULL, NULL).addTextNode(String.ValueOf(date.today().month()));
            DOM.XmlNode Node_daydue = Node_datedue.addChildElement('day', NULL, NULL).addTextNode(String.ValueOf(date.today().day()));
            //DOM.XmlNode Node_shippingmethod = Node_create_sotransaction.addChildElement('shippingmethod', NULL, NULL).addTextNode('Credit Card');
            DOM.XmlNode Node_shipto = Node_create_sotransaction.addChildElement('shipto', NULL, NULL);
            DOM.XmlNode Node_contactname = Node_shipto.addChildElement('contactname', NULL, NULL).addTextNode('S_' + IntacctCustomerId);
            //DOM.XmlNode Node_contactname = Node_shipto.addChildElement('contactname', NULL, NULL).addTextNode('S_' + IntacctCustomerId);
            DOM.XmlNode Node_billto = Node_create_sotransaction.addChildElement('billto', NULL, NULL);
            DOM.XmlNode Node_contactnameBill = Node_billto.addChildElement('contactname', NULL, NULL).addTextNode('B_' + IntacctCustomerId);

            //DOM.XmlNode Node_transactionstate = Node_create_sotransaction.addChildElement('transactionstate', NULL, NULL).addTextNode('Pending');
            DOM.XmlNode Node_basecurr = Node_create_sotransaction.addChildElement('basecurr', NULL, NULL).addTextNode(OpportunityLItem.CurrencyIsoCode);
            DOM.XmlNode Node_currency = Node_create_sotransaction.addChildElement('currency', NULL, NULL).addTextNode(OpportunityLItem.CurrencyIsoCode);

            DOM.XmlNode Node_exchratedate = Node_create_sotransaction.addChildElement('exchratedate', NULL, NULL);
            DOM.XmlNode Node_exchyear = Node_exchratedate.addChildElement('year', NULL, NULL).addTextNode(String.ValueOf(date.today().year()));
            DOM.XmlNode Node_exchmonth = Node_exchratedate.addChildElement('month', NULL, NULL).addTextNode(String.ValueOf(date.today().month()));
            DOM.XmlNode Node_exchday = Node_exchratedate.addChildElement('day', NULL, NULL).addTextNode(String.ValueOf(date.today().day()));
            DOM.XmlNode Node_exchratetype = Node_create_sotransaction.addChildElement('exchratetype', NULL, NULL).addTextNode('Intacct Daily Rate');
            //DOM.XmlNode Node_exchrate = Node_create_sotransaction.addChildElement('exchrate', NULL, NULL).addTextNode('1');
            DOM.XmlNode Node_vsoepricelist = Node_create_sotransaction.addChildElement('vsoepricelist', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.PricebookEntry.Pricebook2.Name));
            DOM.XmlNode Node_customfields = Node_create_sotransaction.addChildElement('customfields', NULL, NULL);
            /*DOM.XmlNode Node_customfield = Node_customfields.addChildElement('customfield', NULL, NULL);
            DOM.XmlNode Node_customfieldname = Node_customfield.addChildElement('customfieldname', NULL, NULL).addTextNode('payment_id');
            DOM.XmlNode Node_customfieldvalue = Node_customfield.addChildElement('customfieldvalue', NULL, NULL).addTextNode('2194344506');*/
            DOM.XmlNode Node_customfieldRegion = Node_customfields.addChildElement('customfield', NULL, NULL);
            DOM.XmlNode Node_customfieldnameRegion = Node_customfieldRegion.addChildElement('customfieldname', NULL, NULL).addTextNode('Region');
            DOM.XmlNode Node_customfieldvalueRegion = Node_customfieldRegion.addChildElement('customfieldvalue', NULL, NULL).addTextNode('Americas');
            DOM.XmlNode Node_customfieldOpptyId = Node_customfields.addChildElement('customfield', NULL, NULL);
            DOM.XmlNode Node_customfieldnameOpptyId = Node_customfieldOpptyId.addChildElement('customfieldname', NULL, NULL).addTextNode('OPPORTUNITY_ID');
            DOM.XmlNode Node_customfieldvalueOpptyId = Node_customfieldOpptyId.addChildElement('customfieldvalue', NULL, NULL).addTextNode(OpportunityLItem.Opportunity.Id);
            // ITEMS //
            DOM.XmlNode Node_sotransitems = Node_create_sotransaction.addChildElement('sotransitems', NULL, NULL);

            for (OpportunityLineItem OpportunityLIt :OpportunityLItems) {
                DOM.XmlNode Node_sotransitem = Node_sotransitems.addChildElement('sotransitem', NULL, NULL);
                DOM.XmlNode Node_itemid = Node_sotransitem.addChildElement('itemid', NULL, NULL).addTextNode(CheckNULL(OpportunityLIt.PricebookEntry.ProductCode));
                DOM.XmlNode Node_itemdesc = Node_sotransitem.addChildElement('itemdesc', NULL, NULL).addTextNode(CheckNULL(OpportunityLIt.PricebookEntry.Name));
                //DOM.XmlNode Node_line_no = Node_sotransitem.addChildElement('line_no', NULL, NULL).addTextNode('0');//!!!!!!!
                DOM.XmlNode Node_quantity = Node_sotransitem.addChildElement('quantity', NULL, NULL).addTextNode(String.ValueOf(OpportunityLIt.Quantity));

                DOM.XmlNode Node_unit = Node_sotransitem.addChildElement('unit', NULL, NULL).addTextNode('Each');
                DOM.XmlNode Node_price = Node_sotransitem.addChildElement('price', NULL, NULL).addTextNode(String.valueOf(OpportunityLIt.UnitPrice));
                //DOM.XmlNode Node_retailprice = Node_sotransitem.addChildElement('retailprice', NULL, NULL).addTextNode('2200');
                //DOM.XmlNode Node_totalamount = Node_sotransitem.addChildElement('totalamount', NULL, NULL).addTextNode('2200');
                DOM.XmlNode Node_locationid = Node_sotransitem.addChildElement('locationid', NULL, NULL).addTextNode('marketo-us');

                DOM.XmlNode Node_customfieldsItem = Node_sotransitem.addChildElement('customfields', NULL, NULL);
                DOM.XmlNode Node_customfieldItem = Node_customfieldsItem.addChildElement('customfield', NULL, NULL);
                DOM.XmlNode Node_customfieldnameItem = Node_customfieldItem.addChildElement('customfieldname', NULL, NULL).addTextNode('payment_id');
                DOM.XmlNode Node_customfieldvalueItem = Node_customfieldItem.addChildElement('customfieldvalue', NULL, NULL).addTextNode('2194344506');
                DOM.XmlNode Node_customfieldRegionItem = Node_customfieldsItem.addChildElement('customfield', NULL, NULL);
                DOM.XmlNode Node_customfieldnameRegionItem = Node_customfieldRegionItem.addChildElement('customfieldname', NULL, NULL).addTextNode('Region');
                DOM.XmlNode Node_customfieldvalueRegionItem = Node_customfieldRegionItem.addChildElement('customfieldvalue', NULL, NULL).addTextNode('Americas');


                DOM.XmlNode Node_revrecstartdate = Node_sotransitem.addChildElement('revrecstartdate', NULL, NULL);
                DOM.XmlNode Node_revexchyear = Node_revrecstartdate.addChildElement('year', NULL, NULL).addTextNode(String.ValueOf(date.today().year()));
                DOM.XmlNode Node_revexchmonth = Node_revrecstartdate.addChildElement('month', NULL, NULL).addTextNode(String.ValueOf(date.today().month()));
                DOM.XmlNode Node_revexchday = Node_revrecstartdate.addChildElement('day', NULL, NULL).addTextNode(String.ValueOf(date.today().day()));

                DOM.XmlNode Node_revrecenddate = Node_sotransitem.addChildElement('revrecenddate', NULL, NULL);
                DOM.XmlNode Node_revendexchyear = Node_revrecenddate.addChildElement('year', NULL, NULL).addTextNode(String.ValueOf(date.today().year()));
                DOM.XmlNode Node_revendexchmonth = Node_revrecenddate.addChildElement('month', NULL, NULL).addTextNode(String.ValueOf(date.today().month()));
                DOM.XmlNode Node_revendexchday = Node_revrecenddate.addChildElement('day', NULL, NULL).addTextNode(String.ValueOf(date.today().day()));
                //DOM.XmlNode Node_exchrateItem = Node_sotransitem.addChildElement('exchrate', NULL, NULL).addTextNode('1');
                //DOM.XmlNode Node_trx_price = Node_sotransitem.addChildElement('trx_price', NULL, NULL).addTextNode('2200');
                //DOM.XmlNode Node_trx_value = Node_sotransitem.addChildElement('trx_value', NULL, NULL).addTextNode('2200');

                DOM.XmlNode Node_customeridItem = Node_sotransitem.addChildElement('customerid', NULL, NULL).addTextNode(IntacctCustomerId);
                DOM.XmlNode Node_classid = Node_sotransitem.addChildElement('classid', NULL, NULL).addTextNode('US');

            }


        }
        if (Operation == 'CreateBContact' || Operation == 'UpdateBContact') {
            DOM.XmlNode Node_create_contact;
            if(Operation == 'CreateBContact'){
                Node_function.setAttribute('controlid', 'CreateContact');
                Node_create_contact = Node_function.addChildElement('create_contact', NULL, NULL);
                DOM.XmlNode Node_contact_contactname = Node_create_contact.addChildElement('contactname', NULL, NULL).addTextNode('B_'+IntacctCustomerId);
            }
            else {
                Node_function.setAttribute('controlid', 'UpdateContact');
                Node_create_contact = Node_function.addChildElement('update_contact', NULL, NULL);
                Node_create_contact.setAttribute('contactname','B_'+IntacctCustomerId);
            }

            DOM.XmlNode Node_contact_printas = Node_create_contact.addChildElement('printas', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Name));
            DOM.XmlNode Node_contact_companyname = Node_create_contact.addChildElement('companyname', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Name));
            DOM.XmlNode Node_contact_prefix = Node_create_contact.addChildElement('prefix', NULL, NULL).addTextNode('');
            DOM.XmlNode Node_contact_firstname = Node_create_contact.addChildElement('firstname', NULL, NULL).addTextNode('');
            DOM.XmlNode Node_contact_lastname = Node_create_contact.addChildElement('lastname', NULL, NULL).addTextNode('');
            DOM.XmlNode Node_contact_initial = Node_create_contact.addChildElement('initial', NULL, NULL).addTextNode('');
            DOM.XmlNode Node_contact_PHONE1 = Node_create_contact.addChildElement('phone1', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Phone));
            DOM.XmlNode Node_contact_PHONE2 = Node_create_contact.addChildElement('phone2', NULL, NULL).addTextNode('');
            DOM.XmlNode Node_contact_CELLPHONE = Node_create_contact.addChildElement('cellphone', NULL, NULL).addTextNode('');
            DOM.XmlNode Node_contact_PAGER = Node_create_contact.addChildElement('pager', NULL, NULL).addTextNode('');
            DOM.XmlNode Node_contact_FAX = Node_create_contact.addChildElement('fax', NULL, NULL).addTextNode('');
            DOM.XmlNode Node_contact_EMAIL1 = Node_create_contact.addChildElement('email1', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Accounting_Email__c));
            DOM.XmlNode Node_contact_EMAIL2 = Node_create_contact.addChildElement('email2', NULL, NULL).addTextNode('');
            DOM.XmlNode Node_contact_URL1 = Node_create_contact.addChildElement('url1', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Website));
            DOM.XmlNode Node_contact_URL2 = Node_create_contact.addChildElement('url2', NULL, NULL).addTextNode('');
            DOM.XmlNode Node_contact_MAILADDRESS = Node_create_contact.addChildElement('mailaddress', NULL, NULL);
                        DOM.XmlNode Node_contact_ADDRESS1 = Node_contact_MAILADDRESS.addChildElement('address1', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.BillingStreet));
                        DOM.XmlNode Node_contact_ADDRESS2 = Node_contact_MAILADDRESS.addChildElement('address2', NULL, NULL).addTextNode('');
                        DOM.XmlNode Node_contact_CITY = Node_contact_MAILADDRESS.addChildElement('city', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.BillingCity));
                        DOM.XmlNode Node_contact_STATE = Node_contact_MAILADDRESS.addChildElement('state', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.BillingState));
                        DOM.XmlNode Node_contact_ZIP = Node_contact_MAILADDRESS.addChildElement('zip', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.BillingPostalCode));
                        DOM.XmlNode Node_contact_country = Node_contact_MAILADDRESS.addChildElement('country', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.BillingCountry));
        }
        if (Operation == 'CreateSContact' || Operation == 'UpdateSContact') {
            DOM.XmlNode Node_create_contact;
            if(Operation == 'CreateSContact'){
                Node_function.setAttribute('controlid', 'CreateContact');
                Node_create_contact = Node_function.addChildElement('create_contact', NULL, NULL);
                DOM.XmlNode Node_contact_contactname = Node_create_contact.addChildElement('contactname', NULL, NULL).addTextNode('S_'+IntacctCustomerId);
            }
            else {
                Node_function.setAttribute('controlid', 'UpdateContact');
                Node_create_contact = Node_function.addChildElement('update_contact', NULL, NULL);
                Node_create_contact.setAttribute('contactname','S_'+IntacctCustomerId);
            }
            //Node_function.setAttribute('controlid', 'CreateContact');
            //DOM.XmlNode Node_create_contact = Node_function.addChildElement('create_contact', NULL, NULL);
            //DOM.XmlNode Node_contact_contactname = Node_create_contact.addChildElement('contactname', NULL, NULL).addTextNode('S_'+IntacctCustomerId);
            DOM.XmlNode Node_contact_printas = Node_create_contact.addChildElement('printas', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Name));
            DOM.XmlNode Node_contact_companyname = Node_create_contact.addChildElement('companyname', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Name));
            DOM.XmlNode Node_contact_prefix = Node_create_contact.addChildElement('prefix', NULL, NULL).addTextNode('');
            DOM.XmlNode Node_contact_firstname = Node_create_contact.addChildElement('firstname', NULL, NULL).addTextNode('');
            DOM.XmlNode Node_contact_lastname = Node_create_contact.addChildElement('lastname', NULL, NULL).addTextNode('');
            DOM.XmlNode Node_contact_initial = Node_create_contact.addChildElement('initial', NULL, NULL).addTextNode('');
            DOM.XmlNode Node_contact_PHONE1 = Node_create_contact.addChildElement('phone1', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Phone));
            DOM.XmlNode Node_contact_PHONE2 = Node_create_contact.addChildElement('phone2', NULL, NULL).addTextNode('');
            DOM.XmlNode Node_contact_CELLPHONE = Node_create_contact.addChildElement('cellphone', NULL, NULL).addTextNode('');
            DOM.XmlNode Node_contact_PAGER = Node_create_contact.addChildElement('pager', NULL, NULL).addTextNode('');
            DOM.XmlNode Node_contact_FAX = Node_create_contact.addChildElement('fax', NULL, NULL).addTextNode('');
            DOM.XmlNode Node_contact_EMAIL1 = Node_create_contact.addChildElement('email1', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Accounting_Email__c));
            DOM.XmlNode Node_contact_EMAIL2 = Node_create_contact.addChildElement('email2', NULL, NULL).addTextNode('');
            DOM.XmlNode Node_contact_URL1 = Node_create_contact.addChildElement('url1', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.Website));
            DOM.XmlNode Node_contact_URL2 = Node_create_contact.addChildElement('url2', NULL, NULL).addTextNode('');
            DOM.XmlNode Node_contact_MAILADDRESS = Node_create_contact.addChildElement('mailaddress', NULL, NULL);
                        DOM.XmlNode Node_contact_ADDRESS1 = Node_contact_MAILADDRESS.addChildElement('address1', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.ShippingStreet));
                        DOM.XmlNode Node_contact_ADDRESS2 = Node_contact_MAILADDRESS.addChildElement('address2', NULL, NULL).addTextNode('');
                        DOM.XmlNode Node_contact_CITY = Node_contact_MAILADDRESS.addChildElement('city', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.ShippingCity));
                        DOM.XmlNode Node_contact_STATE = Node_contact_MAILADDRESS.addChildElement('state', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.ShippingState));
                        DOM.XmlNode Node_contact_ZIP = Node_contact_MAILADDRESS.addChildElement('zip', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.ShippingPostalCode));
                        DOM.XmlNode Node_contact_country = Node_contact_MAILADDRESS.addChildElement('country', NULL, NULL).addTextNode(CheckNULL(OpportunityLItem.Opportunity.Account.ShippingCountry));
        }


        return RequestDocument;
    }

    public static String GetIntacctResponseCustomerCount(HttpResponse res) {
        String result = '';
        if (res != NULL) {
            Dom.Document IntacctResp = res.getBodyDocument();
            DOM.XmlNode Node_RespRoot = IntacctResp.getRootElement();
            if (Node_RespRoot != NULL) {
                DOM.XmlNode Node_Operation = Node_RespRoot.getChildElement('operation', NULL);
                if (Node_Operation != NULL) {
                    DOM.XmlNode Node_Result = Node_Operation.getChildElement('result', NULL);
                    if (Node_Result != NULL) {
                        DOM.XmlNode Node_Data = Node_Result.getChildElement('data', NULL);
                        if (Node_Data != NULL) {
                            result = Node_Data.getAttributeValue('count', NULL);
                        }
                    }
                }
            }
        }
        if (Test.IsRunningTest())return '0';
        return result;
    }
    public static String GetIntacctResponseCustomerID(HttpResponse res) {
        String result = '';
        if (res != NULL) {
            Dom.Document IntacctResp = res.getBodyDocument();
            DOM.XmlNode Node_RespRoot = IntacctResp.getRootElement();
            if (Node_RespRoot != NULL) {
                DOM.XmlNode Node_Operation = Node_RespRoot.getChildElement('operation', NULL);
                if (Node_Operation != NULL) {
                    DOM.XmlNode Node_Result = Node_Operation.getChildElement('result', NULL);
                    if (Node_Result != NULL) {
                        DOM.XmlNode Node_Data = Node_Result.getChildElement('data', NULL);
                        if (Node_Data != NULL) {
                            String countR = Node_Data.getAttributeValue('count', NULL);
                            if (countR == '1') {
                                DOM.XmlNode Node_Customer = Node_Data.getChildElement('customer', NULL);
                                if (Node_Customer != NULL) {
                                    DOM.XmlNode Node_CUSTOMERID = Node_Customer.getChildElement('CUSTOMERID', NULL);
                                    return (Node_CUSTOMERID != NULL) ? Node_CUSTOMERID.getText() : '';
                                }
                            }
                        }
                    }
                }
            }
        }
        if (Test.IsRunningTest())return '0';
        System.Debug('result=========='+result);
        return result;
    }

    @future (callout=true)
    public static void processIntacctTransaction (String OpptyID, String IntacctCustomerId/*, String Operation*/) {
        System.Debug('IntacctCustomerId==================='+IntacctCustomerId);
        DOM.Document RequestDocument;
        String ResponseCustomerCount;
        List<OpportunityLineItem> OpportunityLItems;
        OpportunityLineItem OpportunityLItem;
        try {
                OpportunityLItems = [SELECT Id, CurrencyIsoCode, Full_Price__c, Line_Item_Price__c, UnitPrice, Quantity,
                                    PricebookEntry.ProductCode, PricebookEntry.Pricebook2Id, PricebookEntry.Name, PricebookEntry.Pricebook2.Name,
                                    Opportunity.Id, Opportunity.Name, Opportunity.Opportunity_Number__c, Opportunity.Account.Name,
                                    Opportunity.Account.CurrencyIsoCode, Opportunity.Account.ShippingCountry, Opportunity.Account.ShippingPostalCode,
                                    Opportunity.Account.ShippingState, Opportunity.Account.ShippingCity, Opportunity.Account.ShippingStreet, Opportunity.Account.BillingCountry,
                                    Opportunity.Account.BillingPostalCode, Opportunity.Account.BillingState, Opportunity.Account.BillingCity, Opportunity.Account.BillingStreet,
                                    Opportunity.AccountId, Opportunity.Account.ParentId, Opportunity.Account.Parent.Name, Opportunity.Account.OwnerId, Opportunity.Account.Parent.IntacctID__c, Opportunity.Account.Website,
                                    Opportunity.Account.Accounting_Email__c,Opportunity.Account.Phone,
                                    Opportunity.Account.Accounting_Contact_First_Name__c, Opportunity.Account.Accounting_Contact_Last_Name__c,
                                    Opportunity.Account.IntacctID__c
                                    FROM OpportunityLineItem WHERE OpportunityId = :OpptyID];
                OpportunityLItem = OpportunityLItems[0];
        }
        catch (Exception e){
            return;
        }
            if (IntacctCustomerId != NULL && IntacctCustomerId != '') {
                RequestDocument  = PrepareIntacctXmlDoc(OpportunityLItems, IntacctCustomerId, 'CheckCustomer');

                String sPostData = RequestDocument.toXmlString();
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setTimeout(60000);
                req.setEndpoint('https://www.intacct.com/ia/xml/xmlgw.phtml');
                req.setMethod('POST');
                req.SetHeader('Content-Type', 'x-intacct-xml-request');
                req.setBody(sPostData);
                System.debug('###Start send CheckCustomer');
                System.debug('###p_GatewayReq ='+req.getBody());

                //if (Test.isRunningTest()) return;

                HttpResponse res = (!Test.IsRunningTest()) ? http.send(req) : NULL;
                System.debug('###p_GatewayResponse ='+((!Test.IsRunningTest()) ? res.getBody() : 'Test'));
                ResponseCustomerCount = GetIntacctResponseCustomerCount(res);
                if (Test.isRunningTest()) ResponseCustomerCount = '0';
            }
            if (IntacctCustomerId == NULL || IntacctCustomerId == '' || ResponseCustomerCount == '0') {
                RequestDocument = PrepareIntacctXmlDoc(OpportunityLItems, IntacctCustomerId, 'CreateCustomer');
                String sPostData = RequestDocument.toXmlString();
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setTimeout(60000);
                req.setEndpoint('https://www.intacct.com/ia/xml/xmlgw.phtml');
                req.setMethod('POST');
                req.SetHeader('Content-Type', 'x-intacct-xml-request');
                req.setBody(sPostData);
                System.debug('###Start send CreateCustomer');
                System.debug('###p_GatewayReq ='+req.getBody());
                HttpResponse res = (!Test.IsRunningTest()) ? http.send(req) : NULL;
                System.debug('###p_GatewayResponse ='+((!Test.IsRunningTest()) ? res.getBody() : 'Test'));
                IntacctCustomerId = GetIntacctResponseCustomerID(res);
                if (Test.isRunningTest()) IntacctCustomerId = 'C-000288';
                if (IntacctCustomerId != NULL && IntacctCustomerId != ''){
                    RequestDocument = PrepareIntacctXmlDoc(OpportunityLItems, IntacctCustomerId, 'CreateBContact');
                    sPostData = RequestDocument.toXmlString();
                    http = new Http();
                    req = new HttpRequest();
                    req.setTimeout(60000);
                    req.setEndpoint('https://www.intacct.com/ia/xml/xmlgw.phtml');
                    req.setMethod('POST');
                    req.SetHeader('Content-Type', 'x-intacct-xml-request');
                    req.setBody(sPostData);
                    System.debug('###Start send CreateBContact');
                    System.debug('###p_GatewayReq ='+req.getBody());
                    //if (Test.isRunningTest()) return;
                    res = (!Test.IsRunningTest()) ? http.send(req) : NULL;
                    System.debug('###p_GatewayResponse ='+((!Test.IsRunningTest()) ? res.getBody() : 'Test'));

                    RequestDocument = PrepareIntacctXmlDoc(OpportunityLItems, IntacctCustomerId, 'CreateSContact');
                    sPostData = RequestDocument.toXmlString();
                    http = new Http();
                    req = new HttpRequest();
                    req.setTimeout(60000);
                    req.setEndpoint('https://www.intacct.com/ia/xml/xmlgw.phtml');
                    req.setMethod('POST');
                    req.SetHeader('Content-Type', 'x-intacct-xml-request');
                    req.setBody(sPostData);
                    System.debug('###Start send CreateBContact');
                    System.debug('###p_GatewayReq ='+((!Test.IsRunningTest()) ? req.getBody() : 'Test'));
                    //if (Test.isRunningTest()) return;
                    res = (!Test.IsRunningTest()) ? http.send(req) : NULL;
                    System.debug('###p_GatewayResponse ='+((!Test.IsRunningTest()) ? res.getBody() : 'Test'));


                }
                else return;
            }
            if (ResponseCustomerCount == '1') {
                RequestDocument = PrepareIntacctXmlDoc(OpportunityLItems, IntacctCustomerId, 'UpdateBContact');
                String sPostData = RequestDocument.toXmlString();
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setTimeout(60000);
                req.setEndpoint('https://www.intacct.com/ia/xml/xmlgw.phtml');
                req.setMethod('POST');
                req.SetHeader('Content-Type', 'x-intacct-xml-request');
                req.setBody(sPostData);
                System.debug('###Start send UpdateBContact');
                System.debug('###p_GatewayReq ='+req.getBody());
                //if (Test.isRunningTest()) return;
                HttpResponse res = (!Test.IsRunningTest()) ? http.send(req) : NULL;
                System.debug('###p_GatewayResponse ='+((!Test.IsRunningTest()) ? res.getBody() : 'Test'));

                RequestDocument = PrepareIntacctXmlDoc(OpportunityLItems, IntacctCustomerId, 'UpdateSContact');
                sPostData = RequestDocument.toXmlString();
                http = new Http();
                req = new HttpRequest();
                req.setTimeout(60000);
                req.setEndpoint('https://www.intacct.com/ia/xml/xmlgw.phtml');
                req.setMethod('POST');
                req.SetHeader('Content-Type', 'x-intacct-xml-request');
                req.setBody(sPostData);
                System.debug('###Start send UpdateSContact');
                System.debug('###p_GatewayReq ='+((!Test.IsRunningTest()) ? req.getBody() : 'Test'));
                //if (Test.isRunningTest()) return;
                res = (!Test.IsRunningTest()) ? http.send(req) : NULL;
                System.debug('###p_GatewayResponse ='+((!Test.IsRunningTest()) ? res.getBody() : 'Test'));


                RequestDocument  = PrepareIntacctXmlDoc(OpportunityLItems, IntacctCustomerId, 'UpdateCustomer');
                sPostData = RequestDocument.toXmlString();
                http = new Http();
                req = new HttpRequest();
                req.setTimeout(60000);
                req.setEndpoint('https://www.intacct.com/ia/xml/xmlgw.phtml');
                req.setMethod('POST');
                req.SetHeader('Content-Type', 'x-intacct-xml-request');
                req.setBody(sPostData);
                System.debug('###Start send UpdateCustomer');
                System.debug('###p_GatewayReq ='+req.getBody());
                //if (Test.isRunningTest()) return;
                res = (!Test.IsRunningTest()) ? http.send(req) : NULL;
                System.debug('###p_GatewayResponse ='+((!Test.IsRunningTest()) ? res.getBody() : 'Test'));
            }
            if (IntacctCustomerId != '' && IntacctCustomerId != NULL){
                RequestDocument  = PrepareIntacctXmlDoc(OpportunityLItems, IntacctCustomerId, 'createSOTransaction');
                String sPostData = RequestDocument.toXmlString();
                Http http = new Http();
                HttpRequest req = new HttpRequest();
                req.setTimeout(60000);
                req.setEndpoint('https://www.intacct.com/ia/xml/xmlgw.phtml');
                req.setMethod('POST');
                req.SetHeader('Content-Type', 'x-intacct-xml-request');
                req.setBody(sPostData);
                System.debug('###Start send createSOTransaction');
                System.debug('###p_GatewayReq ='+req.getBody());
                // if (Test.isRunningTest()) return;
                HttpResponse res = (!Test.IsRunningTest()) ? http.send(req) : NULL;
                System.debug('###p_GatewayResponse ='+((!Test.IsRunningTest()) ? res.getBody() : 'Test'));
                OpportunityLItem.Opportunity.Account.IntacctID__c  = IntacctCustomerId;
                update OpportunityLItem.Opportunity.Account;
            }


    }
    @future (callout=true)
    public static void createSOTransaction (String OpptyID, String IntacctCustomerId) {
        List<OpportunityLineItem> OpportunityLItems;
        OpportunityLineItem OpportunityLItem;
        if (IntacctCustomerId == NULL || IntacctCustomerId == '') {
            return;
        }
        try {
            OpportunityLItems = [SELECT Id, CurrencyIsoCode, Full_Price__c, Line_Item_Price__c, UnitPrice, Quantity, PricebookEntry.ProductCode, PricebookEntry.Pricebook2Id, PricebookEntry.Name, PricebookEntry.Pricebook2.Name,  Opportunity.Name, Opportunity.Opportunity_Number__c FROM OpportunityLineItem WHERE OpportunityId = :OpptyID];
            OpportunityLItem = OpportunityLItems[0];
        }
        catch (Exception e){
            return;
        }
        DOM.Document RequestDocument = new DOM.Document();
        DOM.XmlNode Node_Request = RequestDocument.createRootElement('request', NULL, NULL);
        DOM.XmlNode Node_Control = Node_Request.addChildElement('control', NULL, NULL);
        DOM.XmlNode Node_senderid = Node_Control.addChildElement('senderid', NULL, NULL).addTextNode('marketo');
        DOM.XmlNode Node_password = Node_Control.addChildElement('password', NULL, NULL).addTextNode('AQcOKoXfmR');
        DOM.XmlNode Node_controlid = Node_Control.addChildElement('controlid', NULL, NULL).addTextNode('xml');
        DOM.XmlNode Node_uniqueid = Node_Control.addChildElement('uniqueid', NULL, NULL).addTextNode('false');
        DOM.XmlNode Node_dtdversion = Node_Control.addChildElement('dtdversion', NULL, NULL).addTextNode('3.0');

        DOM.XmlNode Node_Operation = Node_Request.addChildElement('operation', NULL, NULL);
        DOM.XmlNode Node_authentication = Node_Operation.addChildElement('authentication', NULL, NULL);
        DOM.XmlNode Node_login = Node_authentication.addChildElement('login', NULL, NULL);
        DOM.XmlNode Node_userid = Node_login.addChildElement('userid', NULL, NULL).addTextNode('SFDC');
        DOM.XmlNode Node_companyid = Node_login.addChildElement('companyid', NULL, NULL).addTextNode('marketo-copy');
        DOM.XmlNode Node_upassword = Node_login.addChildElement('password', NULL, NULL).addTextNode('Rdue1S&5+e4a');

        DOM.XmlNode Node_content = Node_Operation.addChildElement('content', NULL, NULL);
        DOM.XmlNode Node_function = Node_content.addChildElement('function', NULL, NULL);
        Node_function.setAttribute('controlid', 'createSODoc');
        DOM.XmlNode Node_create_sotransaction = Node_function.addChildElement('create_sotransaction', NULL, NULL);
        DOM.XmlNode Node_transactiontype = Node_create_sotransaction.addChildElement('transactiontype', NULL, NULL).addTextNode('Sales Order New');
        //DOM.XmlNode Node_transactionid = Node_create_sotransaction.addChildElement('transactionid', NULL, NULL).addTextNode('Sales Order New-SO-#0100#');
        //DOM.XmlNode Node_documentnumber = Node_create_sotransaction.addChildElement('documentnumber', NULL, NULL).addTextNode('SO-#0100#');

        DOM.XmlNode Node_datecreated = Node_create_sotransaction.addChildElement('datecreated', NULL, NULL);
        DOM.XmlNode Node_year = Node_datecreated.addChildElement('year', NULL, NULL).addTextNode(String.ValueOf(date.today().year()));
        DOM.XmlNode Node_month = Node_datecreated.addChildElement('month', NULL, NULL).addTextNode(String.ValueOf(date.today().month()));
        DOM.XmlNode Node_day = Node_datecreated.addChildElement('day', NULL, NULL).addTextNode(String.ValueOf(date.today().day()));

        DOM.XmlNode Node_customerid = Node_create_sotransaction.addChildElement('customerid', NULL, NULL).addTextNode(IntacctCustomerId);

        DOM.XmlNode Node_referenceno = Node_create_sotransaction.addChildElement('referenceno', NULL, NULL).addTextNode(OpportunityLItem.Opportunity.Opportunity_Number__c + ' -- ' + OpportunityLItem.Opportunity.Name);
        DOM.XmlNode Node_datedue = Node_create_sotransaction.addChildElement('datedue', NULL, NULL);
        DOM.XmlNode Node_yeardue = Node_datedue.addChildElement('year', NULL, NULL).addTextNode(String.ValueOf(date.today().year()));
        DOM.XmlNode Node_monthdue = Node_datedue.addChildElement('month', NULL, NULL).addTextNode(String.ValueOf(date.today().month()));
        DOM.XmlNode Node_daydue = Node_datedue.addChildElement('day', NULL, NULL).addTextNode(String.ValueOf(date.today().day()));
        //DOM.XmlNode Node_shippingmethod = Node_create_sotransaction.addChildElement('shippingmethod', NULL, NULL).addTextNode('Credit Card');
        DOM.XmlNode Node_billto = Node_create_sotransaction.addChildElement('billto', NULL, NULL);
        DOM.XmlNode Node_contactnameBill = Node_billto.addChildElement('contactname', NULL, NULL).addTextNode('B_' + IntacctCustomerId);
        //DOM.XmlNode Node_shipto = Node_create_sotransaction.addChildElement('shipto', NULL, NULL);
        //DOM.XmlNode Node_contactname = Node_shipto.addChildElement('contactname', NULL, NULL).addTextNode('S_C-002771');//!!!!!!!
        //DOM.XmlNode Node_transactionstate = Node_create_sotransaction.addChildElement('transactionstate', NULL, NULL).addTextNode('Pending');
        DOM.XmlNode Node_basecurr = Node_create_sotransaction.addChildElement('basecurr', NULL, NULL).addTextNode(OpportunityLItem.CurrencyIsoCode);
        DOM.XmlNode Node_currency = Node_create_sotransaction.addChildElement('currency', NULL, NULL).addTextNode(OpportunityLItem.CurrencyIsoCode);

        DOM.XmlNode Node_exchratedate = Node_create_sotransaction.addChildElement('exchratedate', NULL, NULL);
        DOM.XmlNode Node_exchyear = Node_exchratedate.addChildElement('year', NULL, NULL).addTextNode(String.ValueOf(date.today().year()));
        DOM.XmlNode Node_exchmonth = Node_exchratedate.addChildElement('month', NULL, NULL).addTextNode(String.ValueOf(date.today().month()));
        DOM.XmlNode Node_exchday = Node_exchratedate.addChildElement('day', NULL, NULL).addTextNode(String.ValueOf(date.today().day()));
        DOM.XmlNode Node_exchratetype = Node_create_sotransaction.addChildElement('exchratetype', NULL, NULL).addTextNode('Intacct Daily Rate');
        //DOM.XmlNode Node_exchrate = Node_create_sotransaction.addChildElement('exchrate', NULL, NULL).addTextNode('1');
        DOM.XmlNode Node_vsoepricelist = Node_create_sotransaction.addChildElement('vsoepricelist', NULL, NULL).addTextNode(OpportunityLItem.PricebookEntry.Pricebook2.Name);

        // ITEMS //
        DOM.XmlNode Node_sotransitems = Node_create_sotransaction.addChildElement('sotransitems', NULL, NULL);

        for (OpportunityLineItem OpportunityLIt :OpportunityLItems) {
            DOM.XmlNode Node_sotransitem = Node_sotransitems.addChildElement('sotransitem', NULL, NULL);
            DOM.XmlNode Node_itemid = Node_sotransitem.addChildElement('itemid', NULL, NULL).addTextNode(OpportunityLIt.PricebookEntry.ProductCode);
            DOM.XmlNode Node_itemdesc = Node_sotransitem.addChildElement('itemdesc', NULL, NULL).addTextNode(OpportunityLIt.PricebookEntry.Name);
            //DOM.XmlNode Node_line_no = Node_sotransitem.addChildElement('line_no', NULL, NULL).addTextNode('0');//!!!!!!!
            DOM.XmlNode Node_quantity = Node_sotransitem.addChildElement('quantity', NULL, NULL).addTextNode(String.ValueOf(OpportunityLIt.Quantity));

            DOM.XmlNode Node_unit = Node_sotransitem.addChildElement('unit', NULL, NULL).addTextNode('Each');
            DOM.XmlNode Node_price = Node_sotransitem.addChildElement('price', NULL, NULL).addTextNode(String.valueOf(OpportunityLIt.UnitPrice));
            //DOM.XmlNode Node_retailprice = Node_sotransitem.addChildElement('retailprice', NULL, NULL).addTextNode('2200');
            //DOM.XmlNode Node_totalamount = Node_sotransitem.addChildElement('totalamount', NULL, NULL).addTextNode('2200');
            DOM.XmlNode Node_locationid = Node_sotransitem.addChildElement('locationid', NULL, NULL).addTextNode('marketo-us');
            DOM.XmlNode Node_revrecstartdate = Node_sotransitem.addChildElement('revrecstartdate', NULL, NULL);
            DOM.XmlNode Node_revexchyear = Node_revrecstartdate.addChildElement('year', NULL, NULL).addTextNode(String.ValueOf(date.today().year()));
            DOM.XmlNode Node_revexchmonth = Node_revrecstartdate.addChildElement('month', NULL, NULL).addTextNode(String.ValueOf(date.today().month()));
            DOM.XmlNode Node_revexchday = Node_revrecstartdate.addChildElement('day', NULL, NULL).addTextNode(String.ValueOf(date.today().day()));

            DOM.XmlNode Node_revrecenddate = Node_sotransitem.addChildElement('revrecenddate', NULL, NULL);
            DOM.XmlNode Node_revendexchyear = Node_revrecenddate.addChildElement('year', NULL, NULL).addTextNode(String.ValueOf(date.today().year()));
            DOM.XmlNode Node_revendexchmonth = Node_revrecenddate.addChildElement('month', NULL, NULL).addTextNode(String.ValueOf(date.today().month()));
            DOM.XmlNode Node_revendexchday = Node_revrecenddate.addChildElement('day', NULL, NULL).addTextNode(String.ValueOf(date.today().day()));
            //DOM.XmlNode Node_exchrateItem = Node_sotransitem.addChildElement('exchrate', NULL, NULL).addTextNode('1');
            //DOM.XmlNode Node_trx_price = Node_sotransitem.addChildElement('trx_price', NULL, NULL).addTextNode('2200');
            //DOM.XmlNode Node_trx_value = Node_sotransitem.addChildElement('trx_value', NULL, NULL).addTextNode('2200');

            DOM.XmlNode Node_customeridItem = Node_sotransitem.addChildElement('customerid', NULL, NULL).addTextNode(IntacctCustomerId);
            DOM.XmlNode Node_classid = Node_sotransitem.addChildElement('classid', NULL, NULL).addTextNode('US');

        }

        String sPostData = RequestDocument.toXmlString();
        Http http = new Http();
        HttpRequest req = new HttpRequest();
        req.setTimeout(60000);
        req.setEndpoint('https://www.intacct.com/ia/xml/xmlgw.phtml');
        req.setMethod('POST');
        req.SetHeader('Content-Type', 'x-intacct-xml-request');
        req.setBody(sPostData);
        System.debug('###Start send');
        System.debug('###p_GatewayReq ='+req.getBody());

        if (Test.isRunningTest()) return;

        HttpResponse res = http.send(req);
        System.debug('###p_GatewayResponse ='+res.getBody());
    }
    public static void RegisterforTrainingClass(Set<String> ClassIds) {
        Map<Id,Id> RosterIdsGTSessIds = new Map<Id,Id>();
        List<lmsilt__Session__c> sess = [SELECT Id, lmsilt__Meeting__c, lmsilt__ILT_vILT__c, lmsilt__Meeting_Type__c  FROM lmsilt__Session__c WHERE lmsilt__Class__c IN :ClassIds];
        if (sess.size() > 0) {
            String query = ' (';
            Set<Id> ques = new Set<Id>();
            Boolean updateWebEx = false;
            Boolean updateGTT = false;
            for (lmsilt__Session__c s : sess) {
                if (s.lmsilt__Meeting__c != NULL && s.lmsilt__ILT_vILT__c == 'vILT' && s.lmsilt__Meeting_Type__c == 'WebEx') {
                    updateWebEx = true;
                    query += '\'' + s.Id + '\',';
                }
                if (s.lmsilt__Meeting__c != NULL && s.lmsilt__ILT_vILT__c == 'vILT' && s.lmsilt__Meeting_Type__c == 'GoToTraining') {
                    updateGTT = true;
                    query += '\'' + s.Id + '\',';
                }
                ques.add(s.Id);
            }
            query = query.substring(0, query.length()-1) + ')';
                    List<lmsilt__Class__c> clsList = [SELECT
                                        Id,
                                        lmsilt__Event__c,
                                        (SELECT
                                            Id,
                                            IsDeleted,
                                            Name,
                                            CreatedDate,
                                            CreatedById,
                                            LastModifiedDate,
                                            LastModifiedById,
                                            SystemModstamp,
                                            lmsilt__ILT_vILT__c,
                                            lmsilt__Session_Location__c,
                                            lmsilt__Class__c,
                                            lmsilt__Event__c,
                                            lmsilt__Start_Date_Time__c,
                                            lmsilt__End_Date_Time__c,
                                            lmsilt__Meeting_Password__c,
                                            lmsilt__Meeting__c,
                                            lmsilt__Meeting_Type__c,
                                            lmsilt__Time_Zone__c
                                        FROM
                                            lmsilt__Sessions__r
                                        WHERE
                                            Id IN:ques),

                                        (SELECT
                                            Id,
                                            lmsilt__Roster__c,
                                            lmsilt__Session__c
                                        FROM
                                            lmsilt__GoToTraining_Sessions__r),

                                        (SELECT
                                            Id,
                                            IsDeleted,
                                            Name,
                                            CreatedDate,
                                            CreatedById,
                                            LastModifiedDate,
                                            LastModifiedById,
                                            lmsilt__Student__c,
                                            lmsilt__Registered__c,
                                            lmsilt__Status__c,
                                            lmsilt__Waitlist_Priority__c,
                                            lmsilt__Attended__c,
                                            lmsilt__Score__c,
                                            lmsilt__Class__c,
                                            lmsilt__Event__c
                                        FROM
                                            lmsilt__Rosters__r
                                        WHERE lmsilt__Status__c =: Label.lmsilt.Enrolled)
                                    FROM
                                        lmsilt__Class__c
                                    WHERE
                                        Id IN :ClassIds];

            Set<Id> sesIdsInGTTses = new Set<Id>();
            for (lmsilt__Class__c cls :clsList){
                if (cls.lmsilt__GoToTraining_Sessions__r.size() > 0) {
                    for (lmsilt__GoToTraining_Session__c g : cls.lmsilt__GoToTraining_Sessions__r) {
                        sesIdsInGTTses.add(g.lmsilt__Session__c);
                        if (g.lmsilt__Roster__c != NULL) {
                            RosterIdsGTSessIds.put(g.lmsilt__Roster__c, g.Id);
                        }
                    }
                }
            }

            System.debug('XXXcls' + clsList);
            System.debug('XXXRosterIdsGTSessIds' + RosterIdsGTSessIds);
            List<lmsilt__GoToTraining_Session__c> GTTSes = new List<lmsilt__GoToTraining_Session__c>();


            for (lmsilt__Class__c cls :clsList){
                if (cls.lmsilt__Sessions__r.size() > 0 && cls.lmsilt__Rosters__r.size() > 0) {
                    for (lmsilt__Session__c s : cls.lmsilt__Sessions__r) {
                        for (lmsilt__Roster__c r : cls.lmsilt__Rosters__r) {
                            if ((!RosterIdsGTSessIds.containsKey(r.Id)) || (!sesIdsInGTTses.contains(s.Id))) {

                            system.debug('1053: r: '+r);
                            GTTSes.add(new lmsilt__GoToTraining_Session__c(
                                lmsilt__Class__c = cls.Id,
                                lmsilt__Event__c = cls.lmsilt__Event__c,
                                lmsilt__Roster__c = r.Id,
                                lmsilt__Session__c = s.Id,
                                lmsilt__User__c = r.lmsilt__Student__c
                            ));
                            if (s.lmsilt__Meeting__c != NULL && s.lmsilt__ILT_vILT__c == 'vILT' && s.lmsilt__Meeting_Type__c == 'GoToTraining') {

                            }
                            system.debug('1063: r.Id: '+r.Id);

                            }
                        }
                    }
                }
            }
            insert GTTSes;
            List<String> listClassIds = new List<String>(ClassIds);
            String Classquery = ' (';
            for (String classItem : listClassIds) {
                Classquery += '\'' + classItem + '\',';
            }
            Classquery = Classquery.substring(0, Classquery.length()-1) + ')';
            if (updateWebEx == true) {
                String SerializeString = JSON.serialize('SELECT lmsilt__Session__r.lmsilt__Meeting_Type__c, lmsilt__Class__r.lmsilt__Maximum_Capacity__c, lmsilt__registrantKey__c, lmsilt__confirmationUrl__c, lmsilt__User__c, lmsilt__Session__c, lmsilt__Session__r.lmsilt__Meeting_Password__c, lmsilt__Session__r.lmsilt__Meeting__r.lmsilt__Meetingkey__c, lmsilt__Roster__r.lmsilt__Student__c, lmsilt__Roster__r.lmsilt__Student__r.Email, lmsilt__Roster__r.lmsilt__Student__r.LastName, lmsilt__Roster__r.lmsilt__Student__r.FirstName, lmsilt__Roster__c, lmsilt__JoinUrl__c, lmsilt__Event__c, lmsilt__Event__r.Name, lmsilt__Class__c, Name FROM lmsilt__GoToTraining_Session__c WHERE lmsilt__Class__c IN '+Classquery+' and lmsilt__Session__r.lmsilt__Meeting_Type__c=\'WebEx\'');
                MKT_AssignQueue__c AssignQueue = new MKT_AssignQueue__c();
                AssignQueue.MKT_ApexClassName__c = 'BatchRegisterForTraining';
                AssignQueue.MKT_Status__c = 'Pending';
                AssignQueue.MKT_SerializedData__c = SerializeString;
                //HelperWithoutSharing.InsertAssignQueue(new List<MKT_AssignQueue__c>{AssignQueue});
            }
            if (updateGTT == true) {
                String GTTQuery = 'SELECT lmsilt__Session__r.lmsilt__Meeting_Type__c, lmsilt__Class__r.lmsilt__Maximum_Capacity__c, lmsilt__registrantKey__c, lmsilt__confirmationUrl__c, lmsilt__User__c, lmsilt__Session__c, lmsilt__Session__r.lmsilt__Meeting__r.lmsilt__Meetingkey__c, lmsilt__Roster__r.lmsilt__Student__c, lmsilt__Roster__r.lmsilt__Student__r.Email, lmsilt__Roster__r.lmsilt__Student__r.LastName, lmsilt__Roster__r.lmsilt__Student__r.FirstName, lmsilt__Roster__c, lmsilt__JoinUrl__c, lmsilt__Event__c, lmsilt__Event__r.Name, lmsilt__Class__c, Name FROM lmsilt__GoToTraining_Session__c WHERE lmsilt__Class__c IN '+Classquery+'  and lmsilt__Session__r.lmsilt__Meeting_Type__c=\'GoToTraining\' AND lmsilt__JoinUrl__c = NULL order by lmsilt__Roster__c';
                String SerializeString = JSON.serialize(GTTQuery);
                MKT_AssignQueue__c AssignQueue = new MKT_AssignQueue__c();
                AssignQueue.MKT_ApexClassName__c = 'BatchRegisterForTraining';
                AssignQueue.MKT_Status__c = 'Pending';
                AssignQueue.MKT_SerializedData__c = SerializeString;
                //HelperWithoutSharing.InsertAssignQueue(new List<MKT_AssignQueue__c>{AssignQueue});
            }
        }
    }
    public static set<String> getGroupsIds(set<id> GRs){
        List<GroupMember> GMs = [select GroupId from GroupMember where UserOrGroupId=:UserInfo.getUserId() OR UserOrGroupId IN:GRs];
        system.debug('867: GMs: '+GMs);

        set<String> GrIds = new set<String>();

        if(GMs.size() > 0) {
            for(GroupMember gm : GMs) {
                GrIds.add(gm.GroupId);
            }
        }

        return GrIds;
    }
    public static void unRegisterforTraining(Id ClassId, Id Uid) {
        list<lmsilt__Session__c> sess = [select id, lmsilt__Meeting__c, lmsilt__ILT_vILT__c, lmsilt__Meeting_Type__c  from lmsilt__Session__c where lmsilt__Class__c = :ClassId];
        if(sess.size() > 0) {
                String query = ' (';
                String wequery = ' (';
                set<id> ques = new set<id>();
                boolean updateWebEx = false;
                boolean updateGTT = false;
                for (lmsilt__Session__c s : sess) {
                    if (s.lmsilt__Meeting__c != null && s.lmsilt__ILT_vILT__c == 'vILT' && s.lmsilt__Meeting_Type__c == 'WebEx') {
                        updateWebEx = true;
                        wequery += '\'' + s.id + '\',';
                    }
                    if (s.lmsilt__Meeting__c != null && s.lmsilt__ILT_vILT__c == 'vILT' && s.lmsilt__Meeting_Type__c == 'GoToTraining') {
                        ques.add(s.id);
                        updateGTT = true;
                        query += '\'' + s.id + '\',';
                    }
                }
                query = query.substring(0, query.length()-1) + ')';
                wequery = wequery.substring(0, wequery.length()-1) + ')';
                if(updateWebEx == true) {
                    lmsilt.BatchUnRegisterAttendee b = new lmsilt.BatchUnRegisterAttendee();
                    b.Query = 'select Class__r.Maximum_Capacity__c, registrantKey__c, confirmationUrl__c, User__c, Session__c, Session__r.Meeting__r.Meetingkey__c, Roster__r.Student__c, Roster__r.Student__r.Email, Roster__r.Student__r.LastName, Roster__r.Student__r.FirstName, Roster__c, JoinUrl__c, Event__c, Event__r.Name, Class__c, Name from GoToTraining_Session__c where Session__c IN '+wequery+' and User__c=\''+Uid+'\'';
                    ID bid = Database.executeBatch(b,1);
                }

                if(updateGTT == true) {
                    String GTTUnQuery = 'select Class__r.Maximum_Capacity__c, registrantKey__c, confirmationUrl__c, User__c, Session__c, Session__r.Meeting__r.Meetingkey__c, Roster__r.Student__c, Roster__r.Student__r.Email, Roster__r.Student__r.LastName, Roster__r.Student__r.FirstName, Roster__c, JoinUrl__c, Event__c, Event__r.Name, Class__c, Name from GoToTraining_Session__c where Session__c IN '+query+' and User__c=\''+Uid+'\'';
                    String SerializeString = JSON.serialize(GTTUnQuery);
                    MKT_AssignQueue__c AssignQueue = new MKT_AssignQueue__c();
                    AssignQueue.MKT_ApexClassName__c = 'BatchUnRegisterForTraining';
                    AssignQueue.MKT_Status__c = 'Pending';
                    AssignQueue.MKT_SerializedData__c = SerializeString;
                    //HelperWithoutSharing.InsertAssignQueue(new List<MKT_AssignQueue__c>{AssignQueue});

                    /*lmsilt.BatchUnRegisterForTraining b = new lmsilt.BatchUnRegisterForTraining();
                    b.Query = '
                    ID bid = Database.executeBatch(b,1);*/
                }
        }
    }

    public static map<String, Integer> getCountRosterByClassAndStatus(set<Id> clsIds, String Status) {

        map<String, Integer> cls_CountRoster = new map<String, Integer>();
        list<lmsilt__Roster__c> rList = new list<lmsilt__Roster__c>();
        if(Status == null) {
            rList = [select id, lmsilt__Class__r.lmsilt__Event__c, lmsilt__Class__c, lmsilt__Student__c, lmsilt__Status__c from lmsilt__Roster__c where lmsilt__Class__c IN :clsIds order by lmsilt__Class__c];
        } else {
            rList = [select id, lmsilt__Class__r.lmsilt__Event__c, lmsilt__Class__c, lmsilt__Student__c, lmsilt__Status__c from lmsilt__Roster__c where lmsilt__Class__c IN :clsIds and lmsilt__Status__c =: Status order by lmsilt__Class__c];
        }

        if(rList.size() == 0) {
            return null;
        }

        Integer i = 0;
        Id preClassId = null;
        for(lmsilt__Roster__c r : rList) {
            if(preClassId != r.lmsilt__Class__c){
                preClassId = r.lmsilt__Class__c;
                i = 0;
            }
            i++;
            cls_CountRoster.put(r.lmsilt__Class__c, i);
        }

        if(cls_CountRoster.size() == 0){
            return null;
        }

        return cls_CountRoster;
    }
    //-----------------------------------------------------------------------
    //--                          TEST METHODS                            ---
    //-----------------------------------------------------------------------
    
    
     public static User createTestUser(String ProfId, string fName, String lName, String cfsId) {
            String orgId = UserInfo.getOrganizationId();
            String dateString = String.valueof(Datetime.now()).replace(' ','').replace(':','').replace('-','');
            Integer randomInt = Integer.valueOf(math.rint(math.random()*1000000));
            String uniqueName = orgId + dateString + randomInt;
            User tuser = new User(  firstname = fName,
                                    lastName = lName,
                                    email = uniqueName + '@test' + orgId + '.org',
                                    Username = uniqueName + '@test' + orgId + '.org',
                                    EmailEncodingKey = 'ISO-8859-1',
                                    Alias = uniqueName.substring(18, 23),
                                    TimeZoneSidKey = 'America/Los_Angeles',
                                    LocaleSidKey = 'en_US',
                                    LanguageLocaleKey = 'en_US',
                                    ProfileId = profId,
                                    lmscons__Cornerstone_ID__c = 'cfsId'
                                    );
            return tuser;
    }
       
    static testMethod void testHelper(){
        Profile profile;
        try {
            profile = [SELECT Id FROM profile WHERE name='System Administrator'];
        } catch (system.exception e) {
            profile = [SELECT Id FROM profile WHERE Id=:UserInfo.getProfileId()];
        }
        /*User u = new User(alias = 'tes334t2', email='test23434@test.com', emailencodingkey='UTF-8', lastname='2te43st', languagelocalekey='en_US',
        localesidkey='en_US', profileid = profile.Id, timezonesidkey='America/Los_Angeles', username='test@test343SF111112d.com');
        insert u;*/
        User u = createTestUser(profile.Id, 'firstNameTest', 'secondNameTest','');
        insert u;
        try {
            lmscons__LMS_Consumer_Settings__c LCS = [SELECT Id FROM lmscons__LMS_Consumer_Settings__c LIMIT 1];
            system.debug(LCS);
        } catch(system.exception e) {
            lmscons__LMS_Consumer_Settings__c LCS = new lmscons__LMS_Consumer_Settings__c(lmscons__Default_License_Period__c='Months', lmscons__Default_License_Term__c = 12, lmscons__Cornerstone_Callback_URL__c='dep', lmscons__CyberUSecretSignKey__c='dep');
            insert LCS;
            system.debug(LCS);
        }
        System.runAs(u){

            /*Transcript create*/
            lmscons__Transcript__c tr = new lmscons__Transcript__c(lmscons__Trainee__c = UserInfo.getUserId());
            insert tr;

            lmscons__Training_Content__c TC = new lmscons__Training_Content__c(lmscons__Title__c = 'Empty Module');
            insert TC;
            lmscons__Training_Content__c TC2 = new lmscons__Training_Content__c();
            insert TC2;

            /*Module license create*/
            Date d = Date.valueOf(system.now());
            lmscons__Training_Content_License__c tcl = new lmscons__Training_Content_License__c(lmscons__Training_Content__c=tc.Id, lmscons__Expiration_Date__c=d, lmscons__Seats__c = 100);
            insert tcl;

            lmscons__Training_User_License__c tul = new lmscons__Training_User_License__c( lmscons__Content_License__c = tcl.Id, lmscons__User__c = u.Id, lmscons__Cornerstone_ID__c = 'af' );
            insert tul;

            List<lmscons__Training_User_License__c> liTrUL = new List<lmscons__Training_User_License__c>();

            lmscons__Quiz__c q= new lmscons__Quiz__c();
            insert q;
            lmscons__Quiz__c q2= new lmscons__Quiz__c();
            insert q2;
            list<lmscons__Question__c> Qss = new list<lmscons__Question__c>();
            lmscons__Question__c Qs = new lmscons__Question__c(Name = 'Test Question 7232012', lmscons__Type__c='True/False');
            Qss.add(Qs);
            //list<lmscons__Quiz_Statistic__c> Qsas = //HelperWithoutSharing.getQuizStatistics(Q.Id, Tr.Id);
            lmscons__Training_Path__c tp = new lmscons__Training_Path__c();
            insert tp;
            lmscons__Training_Path__c tp2 = new lmscons__Training_Path__c();
            insert tp2;

            list<lmscons__Training_Path_Item__c> tpiList = new list<lmscons__Training_Path_Item__c>();
            lmscons__Training_Path_Item__c ti = new lmscons__Training_Path_Item__c(lmscons__Training_Path__c = tp.Id, lmscons__Training_Content__c=tc.Id, lmscons__Sequence__c=1);
            tpiList.add(ti);
            lmscons__Training_Path_Item__c tpi = new lmscons__Training_Path_Item__c( lmscons__Training_Path__c = tp.Id, lmscons__Training_Content__c=tc2.Id, lmscons__Sequence__c = 2 );
            tpiList.add(tpi);
            insert tpiList;

            lmscons__Training_Path_Assignment_Progress__c tpa = new lmscons__Training_Path_Assignment_Progress__c(lmscons__Training_Path__c = tp.Id, lmscons__Transcript__c = tr.Id);
            insert tpa;
            list<lmscons__Training_Path_Assignment_Progress__c> TPAs = new list<lmscons__Training_Path_Assignment_Progress__c>();

            lmscons__Learning_Path__c lp = new lmscons__Learning_Path__c();
            insert lp;
            lmscons__Learning_Path__c lp2 = new lmscons__Learning_Path__c();
            insert lp2;

            lmscons__Learning_Path_Assignment__c lpa = new lmscons__Learning_Path_Assignment__c(lmscons__Transcript__c = tr.Id, lmscons__Learning_Path__c = lp.Id, lmscons__Learning_Path_Progress__c = 100);
            insert lpa;

            list<lmscons__Learning_Path_Assignment__c> listLPA= new list<lmscons__Learning_Path_Assignment__c>();

            Id RCModule3 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Learning_Path_Item__c' AND DeveloperName='Module' limit 1].Id;
        Id RCEvent3 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Learning_Path_Item__c' AND DeveloperName='Event' limit 1].Id;
        Id RCCourse3 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Learning_Path_Item__c' AND DeveloperName='Course' limit 1].Id;

        List<lmscons__Learning_Path_Item__c> LPIs = new List<lmscons__Learning_Path_Item__c>();
        lmscons__Learning_Path_Item__c LPI4 = new lmscons__Learning_Path_Item__c(lmscons__Learning_Path__c = lp.Id, lmscons__Module__c=tc.Id, RecordTypeId=RCModule3);
        LPIs.add(LPI4);
        lmscons__Learning_Path_Item__c LPI5 = new lmscons__Learning_Path_Item__c(lmscons__Learning_Path__c = lp.Id, lmscons__Course__c=tp.Id, RecordTypeId=RCCourse3);
        LPIs.add(LPI5);
        insert LPIs;

            lmscons__Curriculum__c cu = new lmscons__Curriculum__c();
            insert cu;
            lmscons__Curriculum__c cu2 = new lmscons__Curriculum__c();
            insert cu2;

            lmscons__Curriculum_Assignment__c cura = new lmscons__Curriculum_Assignment__c(lmscons__Transcript__c = tr.Id, lmscons__Curriculum__c = cu.Id, lmscons__Curriculum_Progress__c = 100);
            insert cura;
            list<lmscons__Curriculum_Assignment__c> listCA= new list<lmscons__Curriculum_Assignment__c>();

            LIST<lmscons__Curriculum_Item__c> CIList = new LIST<lmscons__Curriculum_Item__c>();

        Id RCModule5 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Curriculum_Item__c' AND DeveloperName='Module' limit 1].Id;
        Id RCEvent5 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Curriculum_Item__c' AND DeveloperName='Event' limit 1].Id;
        Id RCLP5 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Curriculum_Item__c' AND DeveloperName='Learning_Path2' limit 1].Id;
        Id RCCourse5 = [SELECT Id FROM RecordType WHERE SobjectType='lmscons__Curriculum_Item__c' AND DeveloperName='Course' limit 1].Id;


        List<lmscons__Curriculum_Item__c> CIs = new List<lmscons__Curriculum_Item__c>();
        lmscons__Curriculum_Item__c ci = new lmscons__Curriculum_Item__c(lmscons__Learning_Path__c = lp.Id, lmscons__Curriculum__c = cu.Id, RecordTypeId=RCLP5);
        CIs.add(ci);

        lmscons__Curriculum_Item__c ci2 = new lmscons__Curriculum_Item__c(lmscons__Course__c=tp.Id, lmscons__Curriculum__c = cu.Id, RecordTypeId=RCCourse5);
        CIs.add(ci2);

        lmscons__Curriculum_Item__c ci3 = new lmscons__Curriculum_Item__c(lmscons__Module__c=tc.Id, lmscons__Curriculum__c = cu.Id, RecordTypeId=RCModule5);
        CIs.add(ci3);
        insert CIs;




            list<lmscons__Transcript_Line__c> listTr = new list<lmscons__Transcript_Line__c>();

            lmsilt__Event__c e2 = new lmsilt__Event__c(lmsilt__Languages__c = 'English', Name='Test Event');
            insert e2;

            lmsilt__Event__c e3 = new lmsilt__Event__c(lmsilt__Languages__c = 'English', Name='Test Event2');
            insert e3;

            lmsilt__Meeting__c m = new lmsilt__Meeting__c(lmsilt__Meetingkey__c='123');
            insert m;

            lmsilt__Class__c cls = new lmsilt__Class__c(lmsilt__Event__c = e2.Id);
            insert cls;

            list<lmsilt__Class__c> liC = new list<lmsilt__Class__c>();

            lmsilt__Session__c ss = new lmsilt__Session__c(lmsilt__Meeting__c = m.Id, lmsilt__ILT_vILT__c = 'ILT', lmsilt__Class__c = cls.Id, lmsilt__Start_Date_Time__c = system.now().addDays(2), lmsilt__End_Date_Time__c=system.now().addDays(3));
            insert ss;

            lmscons__Curriculum_Item__c ci4 = new lmscons__Curriculum_Item__c(lmsilt__Event__c=e2.Id, lmscons__Curriculum__c = cu.Id, RecordTypeId=RCEvent5);
            insert ci4;
            //Session__c ss2 = new Session__c(Meeting__c = m.Id, ILT_vILT__c = 'vILT', Meeting_Type__c='WebEx', Class__c = cls.Id, Start_Date_Time__c = system.now().addDays(9), End_Date_Time__c=system.now().addDays(18));
            //insert ss2;

            list<lmsilt__Session__c> listS = new list<lmsilt__Session__c>();

            lmsilt__Roster__c r = new lmsilt__Roster__c(lmsilt__Student__c = u.Id, lmsilt__Class__c = cls.Id, lmsilt__Status__c='Enrolled');
            insert r;

            list<lmsilt__Roster__c> rstList = new list<lmsilt__Roster__c>();
            rstList.add(r);

            Group G = new Group(Name= 'testtest');
            insert G;

            GroupMember gm = new GroupMember(GroupId = g.Id, UserOrGroupId = u.Id);
            insert gm;

            //Contact c = [SELECT Id FROM Contact LIMIT 1];

            lmsilt__Instructor__c i = new lmsilt__Instructor__c(lmsilt__Session__c = ss.Id);
            insert i;

            list<lmsilt__Instructor__c> listInst = new list<lmsilt__Instructor__c>();

            lmsilt__Development_Plan__c DP = new lmsilt__Development_Plan__c();
            insert DP;

            lmsilt__Activity__c Act = new lmsilt__Activity__c(lmsilt__Development_Plan__c = DP.Id);
            insert Act;

            lmsilt__Learning__c AssignedLItem = new lmsilt__Learning__c(lmsilt__Activity__c = Act.Id, lmsilt__Event__c = e2.Id);
            insert AssignedLItem;

            list<lmsilt__Learning__c> listLrns= new list<lmsilt__Learning__c>();

            List<lmsilt__GoToTraining_Session__c> GTTSes = new List<lmsilt__GoToTraining_Session__c>();


            RecordType RTMod = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType='lmscons__Prerequisites__c' and DeveloperName='Module' LIMIT 1];
            RecordType RTQ = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType='lmscons__Prerequisites__c' and DeveloperName='Quiz' LIMIT 1];
            RecordType CTQ = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType='lmscons__Prerequisites__c' and DeveloperName='Course' LIMIT 1];
            RecordType LPTQ = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType='lmscons__Prerequisites__c' and DeveloperName='Learning_Path' LIMIT 1];
            RecordType CuTQ = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType='lmscons__Prerequisites__c' and DeveloperName='Curriculum' LIMIT 1];
            RecordType EvQ = [SELECT Id, DeveloperName FROM RecordType WHERE SobjectType='lmscons__Prerequisites__c' and DeveloperName='Event' LIMIT 1];

            lmscons__Prerequisites__c preMod = new lmscons__Prerequisites__c(lmscons__Module__c = TC.Id, lmscons__Module_Child__c = TC2.Id, recordType = RTMod);
            lmscons__Prerequisites__c preMod2 = new lmscons__Prerequisites__c(lmscons__Module__c = TC.Id, lmscons__Quiz_Child__c = q.Id, recordType = RTMod);
            lmscons__Prerequisites__c preMod3 = new lmscons__Prerequisites__c(lmscons__Module__c = TC.Id, lmscons__Course_Child__c = tp.Id, recordType = RTMod);
            lmscons__Prerequisites__c preMod4 = new lmscons__Prerequisites__c(lmscons__Module__c = TC.Id, lmscons__Learning_Path_Child__c = lp.Id, recordType = RTMod);
            lmscons__Prerequisites__c preMod5 = new lmscons__Prerequisites__c(lmscons__Module__c = TC.Id, lmscons__Curriculum_Child__c = cu.Id, recordType = RTMod);
            lmscons__Prerequisites__c preMod6 = new lmscons__Prerequisites__c(lmscons__Module__c = TC.Id, lmsilt__Event_Child__c = e2.Id, recordType = RTMod);
            lmscons__Prerequisites__c preQuiz = new lmscons__Prerequisites__c(lmscons__Quiz__c = q.Id , lmscons__Module_Child__c = TC.Id, recordType = RTQ);
            lmscons__Prerequisites__c preQuiz2 = new lmscons__Prerequisites__c(lmscons__Quiz__c = q.Id, lmscons__Quiz_Child__c = q2.Id, recordType = RTQ);
            lmscons__Prerequisites__c preQuiz3 = new lmscons__Prerequisites__c(lmscons__Quiz__c = q.Id, lmscons__Course_Child__c = tp.Id, recordType = RTQ);
            lmscons__Prerequisites__c preQuiz4 = new lmscons__Prerequisites__c(lmscons__Quiz__c = q.Id, lmscons__Learning_Path_Child__c = lp.Id, recordType = RTQ);
            lmscons__Prerequisites__c preQuiz5 = new lmscons__Prerequisites__c(lmscons__Quiz__c = q.Id, lmscons__Curriculum_Child__c = cu.Id, recordType = RTQ);
            lmscons__Prerequisites__c preQuiz6 = new lmscons__Prerequisites__c(lmscons__Quiz__c = q.Id, lmsilt__Event_Child__c = e2.Id, recordType = RTQ);
            lmscons__Prerequisites__c preEvent = new lmscons__Prerequisites__c(lmsilt__Event__c = e2.Id , lmsilt__Event_Child__c = e3.Id, recordType = EvQ);
            lmscons__Prerequisites__c preEvent2 = new lmscons__Prerequisites__c(lmsilt__Event__c = e2.Id, lmscons__Quiz_Child__c = q.Id, recordType = EvQ);
            lmscons__Prerequisites__c preEvent3 = new lmscons__Prerequisites__c(lmsilt__Event__c = e2.Id, lmscons__Course_Child__c = tp.Id, recordType = EvQ);
            lmscons__Prerequisites__c preEvent4 = new lmscons__Prerequisites__c(lmsilt__Event__c = e2.Id, lmscons__Learning_Path_Child__c = lp.Id, recordType = EvQ);
            lmscons__Prerequisites__c preEvent5 = new lmscons__Prerequisites__c(lmsilt__Event__c = e2.Id, lmscons__Curriculum_Child__c = cu.Id, recordType = EvQ);
            lmscons__Prerequisites__c preEvent6 = new lmscons__Prerequisites__c(lmsilt__Event__c = e2.Id, lmscons__Module_Child__c = TC.Id, recordType = EvQ);
            lmscons__Prerequisites__c preCourse = new lmscons__Prerequisites__c(lmscons__Course__c = tp.Id , lmscons__Module_Child__c = TC.Id, recordType = CTQ);
            lmscons__Prerequisites__c preCourse2 = new lmscons__Prerequisites__c(lmscons__Course__c = tp.Id , lmscons__Quiz_Child__c = q2.Id, recordType = CTQ);
            lmscons__Prerequisites__c preCourse3 = new lmscons__Prerequisites__c(lmscons__Course__c = tp.Id , lmscons__Course_Child__c = tp2.Id, recordType = CTQ);
            lmscons__Prerequisites__c preCourse4 = new lmscons__Prerequisites__c(lmscons__Course__c = tp.Id , lmscons__Learning_Path_Child__c = lp.Id, recordType = CTQ);
            lmscons__Prerequisites__c preCourse5 = new lmscons__Prerequisites__c(lmscons__Course__c = tp.Id , lmscons__Curriculum_Child__c = cu.Id, recordType = CTQ);
            lmscons__Prerequisites__c preCourse6 = new lmscons__Prerequisites__c(lmscons__Course__c = tp.Id , lmsilt__Event_Child__c = e2.Id, recordType = CTQ);
            lmscons__Prerequisites__c preLP = new lmscons__Prerequisites__c(lmscons__Learning_Path__c = lp.Id , lmscons__Module_Child__c = TC2.Id, recordType = LPTQ);
            lmscons__Prerequisites__c preLP2 = new lmscons__Prerequisites__c(lmscons__Learning_Path__c = lp.Id , lmscons__Quiz_Child__c = q2.Id, recordType = LPTQ);
            lmscons__Prerequisites__c preLP3 = new lmscons__Prerequisites__c(lmscons__Learning_Path__c = lp.Id , lmscons__Course_Child__c = tp.Id, recordType = LPTQ);
            lmscons__Prerequisites__c preLP4 = new lmscons__Prerequisites__c(lmscons__Learning_Path__c = lp.Id , lmscons__Learning_Path_Child__c = lp2.Id, recordType = LPTQ);
            lmscons__Prerequisites__c preLP5 = new lmscons__Prerequisites__c(lmscons__Learning_Path__c = lp.Id , lmscons__Curriculum_Child__c = cu.Id, recordType = LPTQ);
            lmscons__Prerequisites__c preLP6 = new lmscons__Prerequisites__c(lmscons__Learning_Path__c = lp.Id , lmsilt__Event_Child__c = e2.Id, recordType = LPTQ);
            lmscons__Prerequisites__c preCur = new lmscons__Prerequisites__c(lmscons__Curriculum__c = cu.Id , lmscons__Module_Child__c = TC.Id, recordType = CuTQ);
            lmscons__Prerequisites__c preCur2 = new lmscons__Prerequisites__c(lmscons__Curriculum__c = cu.Id, lmscons__Quiz_Child__c = q2.Id, recordType = CuTQ);
            lmscons__Prerequisites__c preCur3 = new lmscons__Prerequisites__c(lmscons__Curriculum__c = cu.Id, lmscons__Course_Child__c = tp.Id, recordType = CuTQ);
            lmscons__Prerequisites__c preCur4 = new lmscons__Prerequisites__c(lmscons__Curriculum__c = cu.Id, lmscons__Learning_Path_Child__c = lp.Id, recordType = CuTQ);
            lmscons__Prerequisites__c preCur5 = new lmscons__Prerequisites__c(lmscons__Curriculum__c = cu.Id, lmscons__Curriculum_Child__c = cu2.Id, recordType = CuTQ);
            lmscons__Prerequisites__c preCur6 = new lmscons__Prerequisites__c(lmscons__Curriculum__c = cu.Id, lmsilt__Event_Child__c = e2.Id, recordType = CuTQ);
            insert new List<lmscons__Prerequisites__c>{preMod,preMod2,preMod3,preMod4,preMod5,preMod6,preQuiz,preQuiz2,preQuiz3,preQuiz4,preQuiz5,preQuiz6,preEvent,preEvent2,preEvent3,preEvent4,preEvent5,preEvent6,preCourse,preCourse2,preCourse3,preCourse4,preCourse5,preCourse6, preLP,preLP2,preLP3,preLP4,preLP5,preLP6,preCur,preCur2,preCur3,preCur4,preCur5,preCur6};

            lmscons__Transcript_Line__c trl_mod = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Training_Content__c = tc.Id,lmscons__Cornerstone_ID__c = 'af', lmscons__Percent_Complete__c = 100);
            lmscons__Transcript_Line__c trl_quiz = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Quiz__c = q.Id,lmscons__Cornerstone_ID__c = 'af2', lmscons__Percent_Complete__c = 100);
            lmscons__Transcript_Line__c trl_event = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmsilt__Event__c = e2.Id,lmscons__Cornerstone_ID__c = 'af3', lmscons__Percent_Complete__c = 100);
            lmscons__Transcript_Line__c trl_lp = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Learning_Path_Assignment__c  = lpa.Id,lmscons__Cornerstone_ID__c = 'af4', lmscons__Percent_Complete__c = 100);
            lmscons__Transcript_Line__c trl_cur = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Curriculum_Assignment__c = cura.Id,lmscons__Cornerstone_ID__c = 'af5', lmscons__Percent_Complete__c = 100);
            lmscons__Transcript_Line__c trl_course = new lmscons__Transcript_Line__c (lmscons__Training_User_License__c = tul.Id,lmscons__Transcript__c = tr.Id,lmscons__Training_Path_Item__c = ti.Id,lmscons__Cornerstone_ID__c = 'af6', lmscons__Percent_Complete__c = 100);
            insert new List<lmscons__Transcript_Line__c> {trl_mod ,trl_quiz ,trl_event , trl_course, trl_lp, trl_cur };

            lmscons__Catalog__c cat1 = new lmscons__Catalog__c(Name = 'test');
            insert cat1;
            lmscons__Catalog_Profile__c catprof = new lmscons__Catalog_Profile__c(lmscons__Profile_Id__c = profile.Id, lmscons__Catalog__c = cat1.Id);
            insert catprof;
            lmscons__Catalog_Quiz__c catquiz = new  lmscons__Catalog_Quiz__c(lmscons__Catalog__c = cat1.Id, lmscons__Quiz__c = q.Id);
            insert catquiz;
            lmsilt__Event_Catalog__c catevent = new  lmsilt__Event_Catalog__c(lmsilt__Catalog__c = cat1.Id, lmsilt__Event__c = e2.Id);
            insert catevent;
            lmscons__Catalog_Course__c catmodule = new lmscons__Catalog_Course__c(lmscons__Catalog__c = cat1.Id, lmscons__Training_Course__c = tc.Id);
            insert catmodule;
            lmscons__Catalog_Training_Path__c cattp = new lmscons__Catalog_Training_Path__c(lmscons__Catalog__c = cat1.Id, lmscons__Training_Path__c = tp.Id);
            insert cattp;
            lmscons__Catalog_Learning_Path__c catlp = new lmscons__Catalog_Learning_Path__c(lmscons__Catalog__c = cat1.Id, lmscons__Learning_Path__c = lp.Id);
            insert catlp;
            lmscons__Catalog_Curriculum__c catcur = new lmscons__Catalog_Curriculum__c(lmscons__Catalog__c = cat1.Id, lmscons__Curriculum__c = cu.Id);
            insert catcur;


            test.startTest();


            Set<Id> objIds = new Set<Id>{TC.Id,q.Id, e2.Id, cu.Id, tp.Id, lp.Id};
            Map<Id, Boolean> checkPrerequisitesMapTest = checkPrerequisitesMap(objIds);
            System.assert(checkPrerequisitesMapTest.size() > 0);

            checkPrerequisites('Curriculum', cu.Id);
            checkPrerequisites('Event', e2.Id);
            checkPrerequisites('LP', lp.Id);
            checkPrerequisites('Course', tp.Id);
            checkPrerequisites('Quiz', q.Id);

            map<String, Set<Id>> getIdModulesCoursesLPFromCurriculumTest = getIdModulesCoursesLPFromCurriculum(cu.id);
            System.assert(getIdModulesCoursesLPFromCurriculumTest.size() > 0);
            map<String, Set<Id>> getIdModulesCoursesLPCuFromCatalogByProfileIdTest = getIdModulesCoursesLPCuFromCatalogByProfileId();
            System.assert(getIdModulesCoursesLPCuFromCatalogByProfileIdTest.size() > 0);

            Set<Id> getIdsEventsFromCurriculumTest = getIdsEventsFromCurriculum(cu.id);
            System.assert(getIdsEventsFromCurriculumTest.size() > 0);

            lmsilt__Event__c eventTest = getEventDetails(e2.Id);
            System.assert(eventTest != NULL);

            List<lmsilt__Class__c> ClassListTest = getClassListByEventId(e2.Id);
            System.assert(ClassListTest.size()>0);

            List<lmscons__Transcript_Line__c> trListTest = getTranscriptLineListByEventId(e2.Id);
            System.assert(trListTest.size()>0);

            lmscons__Transcript_Line__c trTest = getTranscriptLine(trListTest[0].Id);
            System.assert(trTest != NULL);
            Map<Id,lmscons__Transcript_Line__c> eventsMap = getAssignmentEvents();
            System.assert(eventsMap.size()>0);
            Set<Id> ClassIds = new Set<Id>();
            ClassIds.add(cls.Id);
            Set<Id> uids = new Set<Id>();
            uids.add(u.Id);
            Set<Id> grpIds = new Set<Id>();
            grpIds.add(G.Id);
            Set<Id> eids = new Set<Id>();
            eids.add(e2.Id);
            Set<Id> tps = new Set<Id>();
            tps.add(tpi.Id);
            Set<Id> ques = new Set<Id>();
            ques.add(ss.Id);
            Set<Id> Qids = new Set<Id>();
            Qids.add(Qs.Id);
            Set<Id> DevIds = new Set<Id>();
            DevIds.add(DP.Id);
            //RegisterforTraining(ClassIds, uids);
            //unRegisterforTraining(ClassIds, uids);
            //UpdateRosterAfterDeleteStudent(ClassIds);
            getGroupsIds(grpIds);
            r.lmsilt__Status__c = 'waitlist';
            update r;
            getWaitlistMapRostersByClassIds(cls.Id);
            //getRoster(e2.Id, u.Id);
            getSessionByClassId(cls.Id);
            getCountStudentEnroled(cls.Id);
            getCountStudentWaitlisted(cls.Id);
            //getAssignment(tc1.Id);
            updateMeetings(cls.Id);
            //RegisterforTrainingClass(cls.Id);
            getAssignmentList();
            upsertRoster(rstList);
            updateRoster(rstList);
            insertUserLicenseWOSH(liTrUL);
            getCourseAssignmentList(tps);
            getTranscriptId();
            getClassByClassId(cls.Id);
            DeleteRoster(rstList);
            //unRegisterforTraining(cls.Id, u.Id);
            List<SelectOption> listOpt = getStates();
            System.assert(listOpt.size() > 0);
            listOpt = getCardTypes();
            System.assert(listOpt.size() > 0);
            listOpt = getYears();
            currencySymbol('ZWD');
            System.assert(listOpt.size() > 0);
            test.stopTest();
        }
    }

}