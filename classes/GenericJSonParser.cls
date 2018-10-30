public class GenericJSonParser{

    public class Training{
        public String name;
        public String description;
        public Organizer[] Organizers;       
        public string timeZone;
        public Times[] times;
        public string trainingKey;
        public Training() {
            this.name = '';
            this.timeZone = '';
            this.Organizers = new List<Organizer>();
            this.description = '';
            this.trainingKey = '';
            this.times = new List<Times>();
        } 
              
    }
    public class Session{
        public String sessionKey;
        public String trainingName;
        public Organizer[] Organizers;       
        public datetime sessionStartTime;
        public datetime sessionEndTime;
        public integer attendanceCount;
        public integer duration;
        public Session() {
            this.sessionKey = '';
            this.trainingName = '';
            this.Organizers = new List<Organizer>();
            this.attendanceCount = 0;
            this.attendanceCount = 0;
            
        } 
              
    }
    
    public class Attendee{
        public String givenName;
        public String surname;
        public String email;       
        public datetime sessionJoinTime;
        public datetime sessionLeaveTime;
        public integer timeInSession;
        //registrant variabes
        public String confirmationUrl;
        public String joinUrl;
        public String status;
        public String registrantKey;
        public datetime registrationDate;
        
        public Attendee() {
            this.givenName = '';
            this.surname = '';
            this.email = '';
            this.confirmationUrl= '';
            this.registrantKey= '';
            this.status= '';
            this.joinUrl= '';
            this.timeInSession = 0;
            
        } 
              
   }
    
    public class Organizer {
        public string email;
        public string givenName;
        public string organizerKey;
    
    }
    
    public class Times{
        public datetime endDate;
        public datetime startDate;
    }
    public class SuperClass{
        public Training trainingFromGTT;
        public Session sessionFromGTT;
        public Attendee attendeeFromGTT;
        public SuperClass(){
            trainingFromGTT = new Training();
            sessionFromGTT  = new Session();
            attendeeFromGTT = new Attendee();
        }
    }
    public static List<SuperClass> parse(String jsonString,String objectToStorePasedValue) {
         system.debug(jsonString+'jsonString===');
         if(jsonString != 'ERROR'){
            
             List<Training> deserializedJsonTrainings = new List<Training>();
             List<Session> deserializedJsonSessions = new List<Session>();
             List<Attendee> deserializedJsonAttendees = new List<Attendee>();
             List<SuperClass> superClasses = new List<SuperClass>();
             JSONParser parser = JSON.createParser(jsonString);
             
             while (parser.nextToken() != null) { 
             if (parser.getCurrentToken() == JSONToken.START_ARRAY) {       
               while (parser.nextToken() != null) {
                   if (parser.getCurrentToken() == JSONToken.START_OBJECT) {
                    SuperClass sc = new SuperClass();
                    if(objectToStorePasedValue == 'Training'){
                        Training tr = (Training)parser.readValueAs(Training.class);
                        sc.trainingFromGTT = tr;
                        deserializedJsonTrainings.add(tr);
                    }else If(objectToStorePasedValue == 'Session'){
                        Session se = (Session)parser.readValueAs(Session.class);
                        sc.sessionFromGTT= se;
                        deserializedJsonSessions.add(se);
                    }else{
                        Attendee at = (Attendee)parser.readValueAs(Attendee.class);
                        sc.attendeeFromGTT = at;
                        deserializedJsonAttendees.add(at);
                    }
                    superClasses.add(sc);
                  }
               }
              }
                 
             }
           
            return superClasses;
        }
        return new List<SuperClass>();
    }
    
}