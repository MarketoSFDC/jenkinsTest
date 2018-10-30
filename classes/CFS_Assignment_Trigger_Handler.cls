public class CFS_Assignment_Trigger_Handler{
    public static void checkForSubAssignments(Map <Id, lmscons__Transcript_Line__c> triggernewmap){
        
        //establish variables
        List <lmscons__Transcript_Line__c> assignments = new List <lmscons__Transcript_Line__c>();
        List <lmscons__Training_Path_Assignment_Progress__c> courses = new List <lmscons__Training_Path_Assignment_Progress__c>();
        List <lmscons__Learning_Path_Assignment__c> learningPaths = new List <lmscons__Learning_Path_Assignment__c>();
        List <lmscons__Curriculum_Assignment__c> curriculums = new List <lmscons__Curriculum_Assignment__c>();
        Map <ID, lmscons__Transcript_Line__c> assignmentMap = new Map <ID, lmscons__Transcript_Line__c>();
        Map <ID, lmscons__Training_Path_Assignment_Progress__c> courseMap = new Map <ID, lmscons__Training_Path_Assignment_Progress__c>();
        Map <ID, lmscons__Learning_Path_Assignment__c> learningPathMap = new Map <ID, lmscons__Learning_Path_Assignment__c>();
        Map <ID, lmscons__Curriculum_Assignment__c> curriculumMap = new Map <ID, lmscons__Curriculum_Assignment__c>();
        
        //loop through assignments and create map of related learning object ids to assignments
        for (lmscons__Transcript_Line__c a : [
            SELECT Id, lmscons__Course_Assignment__c, lmscons__Learning_Path_Assignment__c, lmscons__Curriculum_Assignment__c, lmsilt__Dev_Plan_Assignment__c
            FROM lmscons__Transcript_Line__c
            WHERE Id in :triggernewmap.keyset()
        ]){
            a.Sub_Assignment__c = false;  
            if(a.lmscons__Course_Assignment__c!=null){
                //if there is a Course Assignment, then this is a sub-assignment
                a.Sub_Assignment__c = true;
                //check if there's also a learning path, curriculum, or dev plan assignment
                if(a.lmscons__Learning_Path_Assignment__c !=null || a.lmscons__Curriculum_Assignment__c !=null || a.lmsilt__Dev_Plan_Assignment__c !=null){
                    //if yes, add to a list to update the course as a sub-assignment
                    courses.add(new lmscons__Training_Path_Assignment_Progress__c(id=a.lmscons__Course_Assignment__c,Sub_Assignment__c=true));
                }
            }
            if(a.lmscons__Learning_Path_Assignment__c!=null){
                //if there is a Learning Path Assignment, then this is a sub-assignment
                a.Sub_Assignment__c = true;
                //check if there's also a curriculum or dev plan assignment
                if(a.lmscons__Curriculum_Assignment__c !=null || a.lmsilt__Dev_Plan_Assignment__c !=null){
                    //if there is a higher level assignment, check the "Sub-Assignment" checkbox on the record
                    learningPaths.add(new lmscons__Learning_Path_Assignment__c(id=a.lmscons__Learning_Path_Assignment__c,Sub_Assignment__c = true));
                }
            }
            if(a.lmscons__Curriculum_Assignment__c!=null){
                //if there is a Currriculum Assignment, then this is a sub-assignment
                a.Sub_Assignment__c = true;
                //check if there's also a dev plan assignment
                if(a.lmsilt__Dev_Plan_Assignment__c !=null){
                    //if there is a higher level assignment, check the "Sub-Assignment" checkbox on the record
                    curriculums.add(new lmscons__Curriculum_Assignment__c(id=a.lmscons__Curriculum_Assignment__c,Sub_Assignment__c = true));
                }
            }
            if(a.lmsilt__Dev_Plan_Assignment__c !=null){
                //if there is a Development Plan Assignment, then this is a sub-assignment
                a.Sub_Assignment__c = true;
            }
            if(a.Sub_Assignment__c == true){
                assignments.add(a);
            }
        }
        //assign lists to maps to remove duplicates, then update all the related assignment records
        courseMap.putall(courses);
        if(courseMap.size()>0){
            update courseMap.values();
        }
        learningPathMap.putall(learningPaths);
        if(learningPathMap.size()>0){
            update learningPathMap.values();
        }
        curriculumMap.putall(curriculums);
        if(curriculumMap.size()>0){
            update curriculumMap.values();
        }
        assignmentMap.putall(assignments);
        if(assignmentMap.size()>0){
            update assignmentMap.values();
        }
    }
}