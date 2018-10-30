/**
 FetchAttendanceFromGoToTraining USED TO FETCH DATA FROM GTT TO SALESFORCE.
 USED FROM FOLLOWING PLACES - 
    1.BUTTON 'GET GOTOTRAINING ATTENDANCE' ON DETAIL LAYOUT OF SESSION RECORD IN SFDC.
    2.SCHEDULER THAT UPDATE TRAINING KEY OF SESSION IN SFDC FROM SCHEDULED TRAINING IN GTT.
CREATED BY: GRAZITTI (FEBRUARY, 2014)
RELATED JIRA TICKET- https://resource.marketo.com/jira/browse/COMM-189
**/

global class FetchAttendanceFromGoToTraining  implements Schedulable{
    /**public variables in GTT and Salesforce integration**/
    private static string ORGANIZERKEY = '';
    private static string ACCESSTOKEN  = '';
    
    
    public FetchAttendanceFromGoToTraining(){
    
    }
    public FetchAttendanceFromGoToTraining(String sessionId){
        List<GoTo_Training_Session__c> session = new List<GoTo_Training_Session__c>([SELECT GoTo_Training_Training_Key__c,
                                       GoTo_Training_Session_Start_Time__c,
                                       GoTo_Training_Session_End_Time__c, 
                                       Event__c ,
                                       Class__c,
                                       GTT_Organizer_Key__c,
                                       GTT_Organizer_Name__c,
                                       SFDC_Session__r.lmsilt__Start_Date_Time__c,
                                       SFDC_Session__r.lmsilt__End_Date_Time__c,
                                       SFDC_Session__c,
                                       Time_Zone__c,
                                       GoTo_Training_Session_Key__c,
                                       GoTo_Training_Session_Duration__c,Unique__c,
                                       GTT_Organizer_Email__c from GoTo_Training_Session__c
                                       WHERE SFDC_Session__c = :sessionId]);
        GoToTrainingAuthenticatorWithUtils authentication = new GoToTrainingAuthenticatorWithUtils();                               
        if(authentication.isAuthenticated){
            if(!session.isEmpty()){
                if(session[0].GoTo_Training_Training_Key__c != null){
                    prepareAttendanceData(session, authentication);
                }
            }else{
                List<lmsilt__Session__c> lmsSession = new List<lmsilt__Session__c>([SELECT lmsilt__Class__c, lmsilt__Start_Date_Time__c, lmsilt__Event__c, lmsilt__End_Date_Time__c
                                                          FROM lmsilt__Session__c WHERE Id=: sessionId LIMIT 1]);
                if(!lmsSession.isEmpty()){                                          
                    List<GoTo_Training_Session__c> targetSession = new List<GoTo_Training_Session__c>();
                    List<GenericJSonParser.SuperClass> trainings = FetchTrainingsFromGoToTraining.returnGTT_trainings(authentication.ORGANIZERKEY, authentication.ACCESSTOKEN);
                    for(GenericJSonParser.SuperClass trng : trainings) {
                        if(trng.trainingFromGTT.name == lmsSession[0].lmsilt__Event__c){
                           for(GenericJSonParser.Times sessionTimes : trng.trainingFromGTT.Times){
                               if((lmsSession[0].lmsilt__Start_Date_Time__c!= null && (sessionTimes.startDate == lmsSession[0].lmsilt__Start_Date_Time__c || sessionTimes.startDate == lmsSession[0].lmsilt__Start_Date_Time__c.addHours(1))) &&(lmsSession[0].lmsilt__End_Date_Time__c != null && (sessionTimes.endDate == lmsSession[0].lmsilt__End_Date_Time__c || sessionTimes.endDate == lmsSession[0].lmsilt__End_Date_Time__c.addHours(1)))){
                                   GoTo_Training_Session__c gttSession = new GoTo_Training_Session__c(
                                       GoTo_Training_Training_Key__c = trng.trainingFromGTT.trainingKey,
                                       SFDC_Session__c               = sessionId,
                                       Time_Zone__c                  = trng.trainingFromGTT.timeZone,
                                       Unique__c                     = sessionId+'-'+trng.trainingFromGTT.trainingKey,
                                       Class__c                      = lmsSession[0].lmsilt__Class__c 
                                   );
                                   targetSession.add(gttSession);
                               }
                           }
                       }
                    }
                    if(!targetSession.isEmpty()){
                        try{
                            upsert targetSession Unique__c;
                            prepareAttendanceData(session, authentication);
                        }catch(Exception e){
                        
                        }
                    }
                }            
            }
        }
        
    }
    
    global void execute(SchedulableContext SC) {    
        connectGTT_RetrieveAttendance_SaveInSFDC();
    }   
    /**THIS CONSTRUCTURE INVOKED FROM BUTTON 'GET GOTOTRAINING ATTENDANCE' ON DETAIL LAYOUT OF 
       SESSION RECORD IN SFDC.
    **/
        
    @future(callout=true) 
    public static void connectGTT_RetrieveAttendance_SaveInSFDC(){
        //GoTo_Training_Sessions  
       List<GoTo_Training_Session__c> sessions = new List<GoTo_Training_Session__c>([SELECT GoTo_Training_Training_Key__c,
                                       GoTo_Training_Session_Start_Time__c,
                                       GoTo_Training_Session_End_Time__c, 
                                       Event__c ,
                                       Class__c,
                                       GTT_Organizer_Key__c,
                                       GTT_Organizer_Name__c,
                                       SFDC_Session__r.lmsilt__Start_Date_Time__c,
                                       SFDC_Session__r.lmsilt__End_Date_Time__c,
                                       SFDC_Session__c,
                                       Time_Zone__c,
                                       GoTo_Training_Session_Key__c,
                                       GoTo_Training_Session_Duration__c,Unique__c,
                                       GTT_Organizer_Email__c from GoTo_Training_Session__c
                                       WHERE GoTo_Training_Training_Key__c != null AND Session_Status__c !='Attendance Sync Completed' AND Sync_Date__c !=: System.Today()
                                       ]);
                                       
        GoToTrainingAuthenticatorWithUtils authentication = new GoToTrainingAuthenticatorWithUtils(); 
        
        if(authentication.isAuthenticated){
             
             List<GoToTraining_Attendance__c> attendanceToBeInsertedInSfdc =  prepareAttendanceData(sessions, authentication);            
             //Schedule this job for next other 100 records...
            /* if(!sessions.isEmpty() && sessions.size() > 32){
                FetchAttendanceFromGoToTraining scheduleForNextOne = new FetchAttendanceFromGoToTraining();
                DateTime nextScheduleTime = System.now().addMinutes(5);
                String sch = '0 '+nextScheduleTime.minute()+' '+nextScheduleTime.hour()+' '+nextScheduleTime.day() +' '+nextScheduleTime.month()+' ?';
                system.schedule('GotoTrainingRegistrationForNext100Events'+System.Now(), sch, scheduleForNextOne );
             }*/                 
        }
    }
    
    public static List<GoToTraining_Attendance__c > prepareAttendanceData(List<GoTo_Training_Session__c> sessions, GoToTrainingAuthenticatorWithUtils authentication){
        
        ORGANIZERKEY = authentication.ORGANIZERKEY;
        ACCESSTOKEN  = authentication.ACCESSTOKEN;
        List<GoToTraining_Attendance__c> newAttendances = new List<GoToTraining_Attendance__c >();
        integer i = 0;
        for(GoTo_Training_Session__c session : sessions){        
            if(i>32) break;  
            
            String sessionStatus = '';   
            String TRAININGKEY = session.GoTo_Training_Training_Key__c; 
            String SESSIONKEY   = '';
            /**GET REGITRATION INFORMATION FOR A TRAINING**/                   
            List<GenericJSonParser.SuperClass> registrantFromGTT  = returnRegistrationsOfATrainingFromGTT(ORGANIZERKEY, TRAININGKEY, ACCESSTOKEN);
            if(!registrantFromGTT.isEmpty()){
                sessionStatus = 'Registration Synced Completed';
            }
            
            /**GET ALL SESSION BY A TRAINING**/
            Map<String, GenericJSonParser.SuperClass> attendee_VRSG_RegistrantMap = new Map<String, GenericJSonParser.SuperClass>();
            String getSessionsByTrainingURL = GoToTrainingAuthenticatorWithUtils.gttAttendanceApiBaseUrl+ORGANIZERKEY+'/trainings/'+TRAININGKEY+'?oauth_token='+ACCESSTOKEN;
            HTTPResponse sessionsInResponse = GoToTrainingAuthenticatorWithUtils.makeAPIRequest(getSessionsByTrainingURL,'GET');
            if(sessionsInResponse.getBody() != 'ERROR'){
                List<GenericJSonParser.SuperClass> sessionFromGTT = GenericJSonParser.parse(sessionsInResponse.getBody(),'Session');
                /**FIND OUT CURRENT SESSION FROM ALL SESSION OF GOTOTRAINING FETCHED ABOVE**/
                if(!sessionFromGTT.isEmpty()){
                    
                    List<GenericJSonParser.SuperClass> currentSessionOFGTT = new List<GenericJSonParser.SuperClass>();
                    for(GenericJSonParser.SuperClass gttSession : sessionFromGTT){
                      if(gttSession.sessionFromGTT.sessionStartTime != NULL && gttSession.sessionFromGTT.sessionEndTime != NULL && 
                         session.SFDC_Session__r.lmsilt__Start_Date_Time__c != NULL && session.SFDC_Session__r.lmsilt__End_Date_Time__c.date() !=NULL &&
                         gttSession.sessionFromGTT.sessionStartTime.date() == session.SFDC_Session__r.lmsilt__Start_Date_Time__c.date() && 
                         gttSession.sessionFromGTT.sessionEndTime.date()   == session.SFDC_Session__r.lmsilt__End_Date_Time__c.date()){
                             currentSessionOFGTT.add(gttSession);
                      }
                    }
                    
                    /**FETCH ATTENDANCE AND SESSION OF TRAININGS***/
                    if(!currentSessionOFGTT.isEmpty()) {
                        /**UPDATE CUSTOM SESSION IN SFDC**/
                        SESSIONKEY                           = currentSessionOFGTT [0].sessionFromGTT.sessionKey;
                        session.GoTo_Training_Session_Key__c = SESSIONKEY;                      
                        session.GoTo_Training_Session_Duration__c   = currentSessionOFGTT [0].sessionFromGTT.duration;
                        session.GoTo_Training_Session_End_Time__c   = currentSessionOFGTT [0].sessionFromGTT.sessionEndTime;
                        session.GoTo_Training_Session_Start_Time__c = currentSessionOFGTT [0].sessionFromGTT.sessionStartTime;
                        session.GTT_Organizer_Name__c  = currentSessionOFGTT [0].sessionFromGTT.Organizers[0].givenName;
                        session.GTT_Organizer_Key__c   = currentSessionOFGTT [0].sessionFromGTT.Organizers[0].organizerKey;
                        session.GTT_Organizer_Email__c = currentSessionOFGTT [0].sessionFromGTT.Organizers[0].email;
                                            
                        /**GET ATTENDANCE OF SESSION BY TRAINING**/
                        String attendeesURL = GoToTrainingAuthenticatorWithUtils.gttAttendanceApiBaseUrl+ORGANIZERKEY+'/sessions/'+SESSIONKEY+'/attendees?oauth_token='+ACCESSTOKEN;
                        HTTPResponse attendeeInResponse = GoToTrainingAuthenticatorWithUtils.makeAPIRequest(attendeesURL,'GET');
                        if(attendeeInResponse.getBody() != 'ERROR') {
                            sessionStatus = 'Attendance Sync Completed';
                            List<GenericJSonParser.SuperClass> attendeesFromGTT = GenericJSonParser.parse(attendeeInResponse.getBody(),'Attendee');
                            system.debug(attendeesFromGTT +'attendeeInResponse===');
                            
                            for(GenericJSonParser.SuperClass attendee : attendeesFromGTT){
                               if(attendee.attendeeFromGTT.email != null && attendee.attendeeFromGTT.email != currentSessionOFGTT [0].sessionFromGTT.Organizers[0].email){
                                   attendee_VRSG_RegistrantMap.put(attendee.attendeeFromGTT.email+'-'+attendee.attendeeFromGTT.givenName+'-'+attendee.attendeeFromGTT.surname,attendee);
                               }
                            }
                        }
                    }
                }else{
                    sessionStatus = 'Attendance Sync Completed';
                }
            }           
            /**PROCESS REGISTRATRION DATA AND ATTENDANCE DATA****/
            for(GenericJSonParser.SuperClass registrant : registrantFromGTT){
               if(registrant.attendeeFromGTT.email != null){
                   GoToTraining_Attendance__c newAttendanceDetail = new GoToTraining_Attendance__c(
                                            Status__c                = 'Registered',
                                            Registration_Session__c  = session.SFDC_Session__c,
                                            Class__c                 = session.Class__c,
                                            GoTo_Training_Session__c = session.Id,
                                            Registration_Status__c   = registrant.attendeeFromGTT.status,
                                            Confirmation_Url__c      = registrant.attendeeFromGTT.confirmationUrl,
                                            Join_Url__c              = registrant.attendeeFromGTT.joinUrl,
                                            Registration_Date__c     = registrant.attendeeFromGTT.registrationDate,
                                            Registrant_Key__c        = registrant.attendeeFromGTT.registrantKey,
                                            Attendee_Email__c = registrant.attendeeFromGTT.email,
                                            Attendee_Name__c  = registrant.attendeeFromGTT.givenName+' '+registrant.attendeeFromGTT.surname,
                                            Unique__c         = session.SFDC_Session__c+'-'+registrant.attendeeFromGTT.givenName+'-'+registrant.attendeeFromGTT.surname+'-'+registrant.attendeeFromGTT.email
                    );
                     if(attendee_VRSG_RegistrantMap.containsKey(registrant.attendeeFromGTT.email+'-'+registrant.attendeeFromGTT.givenName+'-'+registrant.attendeeFromGTT.surname)){
                        newAttendanceDetail.Session__c            = session.SFDC_Session__c;
                        newAttendanceDetail.Session_Join_Time__c  = attendee_VRSG_RegistrantMap.get(registrant.attendeeFromGTT.email+'-'+registrant.attendeeFromGTT.givenName+'-'+registrant.attendeeFromGTT.surname).attendeeFromGTT.sessionJoinTime;
                        newAttendanceDetail.Session_Leave_Time__c = attendee_VRSG_RegistrantMap.get(registrant.attendeeFromGTT.email+'-'+registrant.attendeeFromGTT.givenName+'-'+registrant.attendeeFromGTT.surname).attendeeFromGTT.sessionLeaveTime;
                        newAttendanceDetail.Time_in_Session__c    = attendee_VRSG_RegistrantMap.get(registrant.attendeeFromGTT.email+'-'+registrant.attendeeFromGTT.givenName+'-'+registrant.attendeeFromGTT.surname).attendeeFromGTT.timeInSession;
                        newAttendanceDetail.Status__c = 'Attended';
                    }
                    system.debug(newAttendanceDetail+'newAttendanceDetail==');
                    newAttendances.add(newAttendanceDetail);
               }
            }
            session.Sync_Date__c = System.Today(); 
            session.Session_Status__c = sessionStatus;   
            i++; 
        }
        /**UPDATE SESSION AND CREATE ATTENDANCE DATA**/
        try{
            //upsert newAttendances Unique__c;update sessions;
            List<Database.UpsertResult> attendeesupdated = Database.upsert(newAttendances, GoToTraining_Attendance__c.Unique__c, false);
            List<Database.SaveResult> corsesupdated = Database.update(sessions, false);
        }catch(Exception e){LMS_Util.sendExceptionMail(e);}
        
        return newAttendances;
    }
    
    public static List<GenericJSonParser.SuperClass> returnRegistrationsOfATrainingFromGTT(String O_KEY, String T_KEY, String A_TOKEN){
        /**GET REGITRATION INFORMATION FOR A TRAINING**/
        String getRegistrantByTrainingURL = GoToTrainingAuthenticatorWithUtils.gttRegistrationApiBaseUrl+O_KEY+'/trainings/'+T_KEY+'/registrants?oauth_token='+A_TOKEN;
        HTTPResponse regitrantInResponse  = GoToTrainingAuthenticatorWithUtils.makeAPIRequest(getRegistrantByTrainingURL,'GET');
        List<GenericJSonParser.SuperClass> registrantsFromGTT = GenericJSonParser.parse(regitrantInResponse.getBody(),'Attendee');
        return registrantsFromGTT;       
    }   
}