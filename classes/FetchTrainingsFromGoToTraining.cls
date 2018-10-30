/**
THIS CLASS USED TO RETRIVE THE TRAINING FROM GOTO-TRAINING.
THE TRAINING INFOs IS SAVED IN "GOTO TRAINING SESSION" CUSTOM OBJECT
CREATED BY: GRAZITTI (NOVEMBER, 2014)
RELATED JIRA TICKET- https://resource.marketo.com/jira/browse/COMM-189
**/

global class FetchTrainingsFromGoToTraining implements Schedulable{
    
    /**This Constructure is called from Scheduler that update Training Key Session in Salesforce 
    from sheduled Training in GTT. **/
    global void execute(SchedulableContext SC) { 
        getTrainingsByCallout();
    }
    
    @future(callout=true)
    public static void getTrainingsByCallout(){
        GoToTrainingAuthenticatorWithUtils authentication = new GoToTrainingAuthenticatorWithUtils();
        if(authentication.isAuthenticated){
           string ORGANIZERKEY = authentication.ORGANIZERKEY;
           string ACCESSTOKEN  = authentication.ACCESSTOKEN;
            //Get request to fetch data of all scheduled trainings
            List<GenericJSonParser.SuperClass> trainings = returnGTT_trainings(ORGANIZERKEY, ACCESSTOKEN);
            //Organize GTT sessions to compare with SFDC session in next step
            Map<String,GenericJSonParser.SuperClass> sessionWithTrainingKeyMap = new Map<String,GenericJSonParser.SuperClass>();
            Set<String> trainingNamesToBeFiltered = new Set<String>();
            Set<Datetime> trainingStartDatesToBeFiltered = new Set<Datetime>();
            Set<Datetime> trainingEndDatesToBeFiltered   = new Set<Datetime>();
            
            for(GenericJSonParser.SuperClass trng : trainings){
               
               for(GenericJSonParser.Times sessionTimes : trng.trainingFromGTT.Times){
                   sessionWithTrainingKeyMap.put(trng.trainingFromGTT.name+'-'+sessionTimes.startDate+'-'+sessionTimes.endDate, trng);
                   sessionWithTrainingKeyMap.put(trng.trainingFromGTT.name+'-'+sessionTimes.startDate.addHours(1)+'-'+sessionTimes.endDate.addHours(1), trng);
                   trainingStartDatesToBeFiltered.add(sessionTimes.startDate);
                   trainingStartDatesToBeFiltered.add(sessionTimes.startDate.addHours(1));                 
                   trainingEndDatesToBeFiltered.add(sessionTimes.endDate);
                   trainingEndDatesToBeFiltered.add(sessionTimes.endDate.addHours(1));
               }
               trainingNamesToBeFiltered.add(trng.trainingFromGTT.name);
                
            }
            
            //Map SFDC session to GTT session
            List<GoTo_Training_Session__c > sessionsToBeUpdate = new List<GoTo_Training_Session__c >();
            for(lmsilt__Session__c session : [SELECT Id, lmsilt__Class__c, lmsilt__Event__c, lmsilt__Start_Date_Time__c,lmsilt__Time_Zone__c, lmsilt__End_Date_Time__c,
                                                (SELECT Id from GoTo_Training_Sessions__r Where GoTo_Training_Training_Key__c = null) 
                                                FROM lmsilt__Session__c where lmsilt__Start_Date_Time__c 
                                                IN : trainingStartDatesToBeFiltered AND lmsilt__End_Date_Time__c
                                                IN : trainingEndDatesToBeFiltered AND lmsilt__Event__c IN : trainingNamesToBeFiltered]){
                  
                  
                if(session.GoTo_Training_Sessions__r.isEmpty() && sessionWithTrainingKeyMap.ContainsKey(session.lmsilt__Event__c+'-'+session.lmsilt__Start_Date_Time__c+'-'+session.lmsilt__End_Date_Time__c)){
                    GoTo_Training_Session__c gttSession = new GoTo_Training_Session__c();
                    gttSession.GoTo_Training_Training_Key__c = sessionWithTrainingKeyMap.get(session.lmsilt__Event__c+'-'+session.lmsilt__Start_Date_Time__c+'-'+session.lmsilt__End_Date_Time__c).trainingFromGTT.trainingKey;
                    gttSession.SFDC_Session__c = session.Id;
                    gttSession.Time_Zone__c    = sessionWithTrainingKeyMap.get(session.lmsilt__Event__c+'-'+session.lmsilt__Start_Date_Time__c+'-'+session.lmsilt__End_Date_Time__c).trainingFromGTT.timeZone;
                    gttSession.Unique__c       = session.Id+'-'+sessionWithTrainingKeyMap.get(session.lmsilt__Event__c+'-'+session.lmsilt__Start_Date_Time__c+'-'+session.lmsilt__End_Date_Time__c).trainingFromGTT.trainingKey;
                    gttSession.Class__c        = session.lmsilt__Class__c;
                    system.debug(gttSession+'==sessionsToBeUpdate');
                    sessionsToBeUpdate.add(gttSession);
                }else{
                    system.debug(session.lmsilt__Event__c+' '+session.Id+'===>badnasib'+session.GoTo_Training_Sessions__r);
                } 
                
            }           
            
            //update all session's Training Key
            try{
               List<Database.UpsertResult> trainingupdated = Database.upsert(sessionsToBeUpdate, GoTo_Training_Session__c.Unique__c, false);
              // upsert sessionsToBeUpdate Unique__c;
            }catch(Exception e){LMS_Util.sendExceptionMail(e);}
            
        }
    }
    
    public static List<GenericJSonParser.SuperClass> returnGTT_trainings(String O_KEY, String A_TOKEN){
        String getScheduledTrainingsUrl  = GoToTrainingAuthenticatorWithUtils.gttTrainingApiBaseUrl+O_KEY+'/trainings?oauth_token='+A_TOKEN;
        HTTPResponse trainingsInResponse = GoToTrainingAuthenticatorWithUtils.makeAPIRequest(getScheduledTrainingsUrl,'GET');
        List<GenericJSonParser.SuperClass> trainings = GenericJSonParser.parse(trainingsInResponse.getBody(),'Training');
        return trainings;
    }

}