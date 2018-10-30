/**
THIS CLASS IS USED TO RETRIVE THE REGISTRATIONS OF THE TRAINING IN GOTO TRAINING.
DATA FROM GTT IS STORED UNDER CUSTOM OBJECT- "GTT_Registrant__c" UNDER CLASS AND EVENT OBJECT (LMS PACKAGE).
CREATED BY: GRAZITTI (NOVEMBER, 2014)
RELATED JIRA TICKET- https://resource.marketo.com/jira/browse/COMM-189
**/

global class FetchRegistrationFromGoToTraining implements Schedulable{
    
    public FetchRegistrationFromGoToTraining(String classId){          
        List<lmsilt__Class__c> courses = new  List<lmsilt__Class__c>([SELECT Id, (SELECT GoTo_Training_Training_Key__c FROM GoTo_Training_Sessions__r WHERE GoTo_Training_Training_Key__c != null LIMIT 1) FROM lmsilt__Class__c WHERE Id=: classId]);
        GoToTrainingAuthenticatorWithUtils authentication = new GoToTrainingAuthenticatorWithUtils(); 
        List<GTT_Registrant__c> registrantsToBeInsertedInSfdc = prepareRegistrationData(courses, authentication);
    }
    
    public FetchRegistrationFromGoToTraining(){         
    }
    
    /**This Constructure is called from Scheduler that stores Registration info in Salesforce from sheduled Training in GTT. **/
    global void execute(SchedulableContext SC) { 
        connectGTT_RetrieveInfo_SaveInSFDC();
    }
    
    @future(callout=true) 
    public static void connectGTT_RetrieveInfo_SaveInSFDC(){
        //GoTo_Training_Sessions  
        List<lmsilt__Class__c> coursesUnderWork = new List<lmsilt__Class__c>([SELECT lmsilt__Start_Date__c, (SELECT GoTo_Training_Training_Key__c FROM GoTo_Training_Sessions__r WHERE 
                                                                              GoTo_Training_Training_Key__c != null LIMIT 1) FROM lmsilt__Class__c WHERE lmsilt__Start_Date__c >= TODAY AND GTT_Synced_Date__c != TODAY]);
        
        GoToTrainingAuthenticatorWithUtils authentication = new GoToTrainingAuthenticatorWithUtils(); 
        
        if(authentication.isAuthenticated){             
             List<GTT_Registrant__c> registrantsToBeInsertedInSfdc =  prepareRegistrationData(coursesUnderWork, authentication);
             //Schedule this job for next other 100 records...
             /*if(!coursesUnderWork.isEmpty() && coursesUnderWork.size() > 33){
                FetchRegistrationFromGoToTraining scheduleForNextOne = new FetchRegistrationFromGoToTraining();
                DateTime nextScheduleTime = System.now().addMinutes(5);
                String sch = '0 '+nextScheduleTime.minute()+' '+nextScheduleTime.hour()+' '+nextScheduleTime.day() +' '+nextScheduleTime.month()+' ?';
                system.schedule('GotoTrainingRegistrationForNext100Events'+System.Now(), sch, scheduleForNextOne );
             }
             */
         }
    }
    
    public static List<GTT_Registrant__c> prepareRegistrationData(List<lmsilt__Class__c> courses, GoToTrainingAuthenticatorWithUtils authentication){
        integer i = 0;
        String ORGANIZERKEY = authentication.ORGANIZERKEY;
        String ACCESSTOKEN  = authentication.ACCESSTOKEN;  
        List<GTT_Registrant__c> registrantsToBeInsertedInSfdc = new List<GTT_Registrant__c>();
        for(lmsilt__Class__c course : courses){
            if(i>33) break; //we can make only 100 callout in a transaction
            if(!course.GoTo_Training_Sessions__r.isEmpty()){
                List<GenericJSonParser.SuperClass> registrationsInfo = FetchAttendanceFromGoToTraining.returnRegistrationsOfATrainingFromGTT(ORGANIZERKEY, course.GoTo_Training_Sessions__r[0].GoTo_Training_Training_Key__c, ACCESSTOKEN);
                for(GenericJSonParser.SuperClass registrant : registrationsInfo){
                    GTT_Registrant__c registrnt   = new GTT_Registrant__c();
                    registrnt.Name                = registrant.attendeeFromGTT.givenName+' '+registrant.attendeeFromGTT.surname;
                    registrnt.Student_Name__c     = registrant.attendeeFromGTT.givenName;
                    registrnt.Student_Surname__c  = registrant.attendeeFromGTT.surname;
                    registrnt.Student_Email__c    = registrant.attendeeFromGTT.email;
                    registrnt.Confirmation_Url__c = registrant.attendeeFromGTT.confirmationUrl;
                    registrnt.Join_URL__c         = registrant.attendeeFromGTT.joinUrl;
                    registrnt.Registrant_Status__c = registrant.attendeeFromGTT.status;
                    registrnt.Registration_Key__c  = registrant.attendeeFromGTT.registrantKey;
                    registrnt.Registration_Date__c = registrant.attendeeFromGTT.registrationDate;
                    registrnt.Class__c             = course.Id;
                    registrnt.GTT_Training_Key__c  = course.GoTo_Training_Sessions__r[0].GoTo_Training_Training_Key__c;
                    registrnt.Unique__c            = registrant.attendeeFromGTT.registrantKey+'-'+registrant.attendeeFromGTT.givenName+'-'+course.Id+'-'+registrant.attendeeFromGTT.registrationDate;
                    registrantsToBeInsertedInSfdc.add(registrnt);
                }
                i++;
            }
            course.GTT_Synced_Date__c = Date.Today();
        }  
        if(!registrantsToBeInsertedInSfdc.isEmpty()){
            try { 
                //upsert registrantsToBeInsertedInSfdc Unique__c; update courses;
                List<Database.UpsertResult> studentsupdated = Database.upsert(registrantsToBeInsertedInSfdc, GTT_Registrant__c.Unique__c, false);
                List<Database.SaveResult> corsesupdated     = Database.update(courses, false);
            }catch(Exception e){}
         }
        return registrantsToBeInsertedInSfdc;     
    }
}